-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\EntityCount\\EntityCountSystem.lua

local Class = require("Core.Framework.Class")
local SystemBase = require("GameApp.Core.SystemBase")
local SettingConst = require("Const.SettingConst")
local ClientConst = require("Const.ClientConst")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local EntityManager = require("Core.Common.EntityManager")
local LoggerConst = require("Core.Log.LoggerConst")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("EntityCountSystem")
local Time = require("Core.Common.Time")
local SysConfigData = require("Data.sys_config_data")
local PuppetData = require("Data.puppet_data")
local QuestEntityData = require("Data.Quest.quest_entity_data")
local BALANCE_TICK_DELAY = 0.5
local ENVOBJ_BALANCE_TICK_DELAY = 0.15
local NORMAL_TICK_DELAY = 1
local NEGATIVE_INFINITY = -math.huge
local EPSILON = 1e-06
local STATIC_ID_OPTIONAL_ENTITY_TYPES = {
	ClientPet = true,
	ClientPlayer = true
}

local function getNpcLoadConfigNumber(configKey, defaultValue)
	if IS_MOBILE then
		local mobileValue = SysConfigData[configKey .. "_MOBILE"]

		if mobileValue ~= nil then
			return mobileValue
		end
	end

	return SysConfigData[configKey] or defaultValue
end

local function calcNpcLoadWeight(playerPos, forwardX, forwardZ, forwardLengthSqr, npcPos, loadConfig)
	local offsetX = npcPos[1] - playerPos[1]
	local offsetZ = npcPos[3] - playerPos[3]
	local distanceSqr = offsetX * offsetX + offsetZ * offsetZ
	local inFront = false

	if distanceSqr <= EPSILON then
		inFront = true
	elseif forwardLengthSqr > EPSILON then
		local dot = forwardX * offsetX + forwardZ * offsetZ
		local dotSqr = dot * dot
		local thresholdSqr = loadConfig.cosHalfAngleSqr * forwardLengthSqr * distanceSqr

		if loadConfig.cosHalfAngle >= 0 then
			inFront = dot >= 0 and thresholdSqr <= dotSqr
		else
			inFront = dot >= 0 or dotSqr <= thresholdSqr
		end
	end

	local region

	if distanceSqr <= loadConfig.nearSqr then
		region = inFront and 1 or 2
	elseif inFront and distanceSqr <= loadConfig.frontSqr then
		region = 3
	elseif distanceSqr <= loadConfig.farSqr then
		region = 4
	else
		return NEGATIVE_INFINITY, 0, distanceSqr, inFront
	end

	local regionPriority = 4 - region
	local distanceWeight = loadConfig.maxRadiusSqr - distanceSqr
	local weight = regionPriority * loadConfig.regionBase + distanceWeight

	return weight, region, distanceSqr, inFront
end

local EntityCountSystem = Class.LightClass("EntityCountSystem", SystemBase)

function EntityCountSystem:onInit()
	self.entityTypeAlias = {
		ClientStaticNpc = "ClientPuppet",
		ClientSimpleMoveNpc = "ClientPuppet"
	}
	self.serverEntityType = {
		ClientPuppet = {
			"Puppet",
			"StaticNpc",
			"SimpleMoveNpc"
		},
		ClientPlayer = {
			"Player"
		},
		ClientPet = {
			"Pet"
		},
		ClientEnvObject = {
			"EnvObject"
		}
	}

	if not IS_MOBILE then
		BALANCE_TICK_DELAY = 0.2
	end

	self.entityCountLimit = Utils.deepCopyTable(SettingConst.EntityCountLimitHigh)

	local rNear = getNpcLoadConfigNumber("NPC_LOAD_R_NEAR", 30)
	local rFront = getNpcLoadConfigNumber("NPC_LOAD_R_FRONT", 120)
	local rFar = getNpcLoadConfigNumber("NPC_LOAD_R_FAR", 50)
	local halfAngle = getNpcLoadConfigNumber("NPC_LOAD_HALF_ANGLE", 55)
	local nearSqr = rNear * rNear
	local frontSqr = rFront * rFront
	local farSqr = rFar * rFar
	local maxRadiusSqr = math.max(frontSqr, farSqr)
	local cosHalfAngle = math.cos(halfAngle * math.pi / 180)

	self.npcLoadWeightConfig = {
		nearSqr = nearSqr,
		frontSqr = frontSqr,
		farSqr = farSqr,
		maxRadiusSqr = maxRadiusSqr,
		regionBase = maxRadiusSqr + 1,
		cosHalfAngle = cosHalfAngle,
		cosHalfAngleSqr = cosHalfAngle * cosHalfAngle
	}
	self.ignoreCountLimitStaticIdMap = {}

	local ignoreCountLimitStaticIds = SysConfigData.IGNORE_COUNT_LIMIT_STATIC_IDS

	if ignoreCountLimitStaticIds ~= nil then
		for i, v in ipairs(ignoreCountLimitStaticIds) do
			self.ignoreCountLimitStaticIdMap[v] = 1
		end
	end

	self:onClear()
end

function EntityCountSystem:onClear()
	self.serverLimitLevel = {}
	self.requestCreateMap = {}
	self.entityInfo = {}
	self.inBalancing = {}
	self.nextTickTime = {}

	for k, _ in pairs(self.entityCountLimit) do
		self.entityInfo[k] = {}
		self.requestCreateMap[k] = {}
		self.inBalancing[k] = true
		self.nextTickTime[k] = 0
	end

	self.requestCreateMap.other = {}
	self.entityTracingQuestInfo = {}
	self.entityTracingQuestSetDirty = true
end

function EntityCountSystem:_normalizeType(entityType)
	return self.entityTypeAlias[entityType] or entityType
end

function EntityCountSystem:setCountLimit(classType, limit)
	self.entityCountLimit[classType] = limit
end

function EntityCountSystem:setEntityCountLimitLevel(level)
	local newCountLimit = SettingConst.EntityCountLimitLevel[level]

	for k, v in pairs(newCountLimit) do
		self:setCountLimit(k, v)
	end
end

function EntityCountSystem:onSceneLoaded(sceneId, sceneName)
	return
end

function EntityCountSystem:needIgnore(entityType, staticId, displayLevel)
	if (staticId == nil or staticId == 0) and not STATIC_ID_OPTIONAL_ENTITY_TYPES[entityType] then
		return true
	end

	if self.ignoreCountLimitStaticIdMap[staticId] ~= nil then
		return true
	end

	if displayLevel >= 1 then
		return true
	end

	if self:hasTracingQuest(staticId) then
		return true
	end

	return false
end

function EntityCountSystem:addEntityInfo(entityId, entityType, staticId, pos, displayLevel, templateId)
	entityType = self:_normalizeType(entityType)

	if self.entityInfo[entityType] ~= nil then
		if entityType == "ClientPuppet" then
			local puppetData = PuppetData[templateId]

			if puppetData ~= nil and puppetData.appearanceToPrefabResID == nil and puppetData.prefabResID == nil then
				displayLevel = 1
			end
		end

		if self:needIgnore(entityType, staticId, displayLevel) then
			self:requestEntityToCreate(entityId, entityType, true)
		end

		self.entityInfo[entityType][entityId] = {
			staticId,
			pos,
			ClientConst.EntityCount.NOT_CREATED,
			displayLevel,
			templateId
		}
	else
		self:requestEntityToCreate(entityId, entityType, true)
	end
end

function EntityCountSystem:_markEntityState(entityId, state)
	for k, v in pairs(self.entityInfo) do
		if v[entityId] ~= nil then
			self.entityInfo[k][entityId][3] = state

			break
		end
	end

	for k, v in pairs(self.requestCreateMap) do
		if v[entityId] ~= nil then
			self.requestCreateMap[k][entityId] = nil

			break
		end
	end
end

function EntityCountSystem:markEntityCreated(entityId)
	self:_markEntityState(entityId, ClientConst.EntityCount.CREATED)
end

function EntityCountSystem:markEntityNotCreated(entityId)
	self:_markEntityState(entityId, ClientConst.EntityCount.NOT_CREATED)
end

function EntityCountSystem:removeEntityInfo(entityId)
	for k, v in pairs(self.entityInfo) do
		if v[entityId] ~= nil then
			self.entityInfo[k][entityId] = nil

			break
		end
	end

	for k, v in pairs(self.requestCreateMap) do
		if v[entityId] ~= nil then
			self.requestCreateMap[k][entityId] = nil

			break
		end
	end
end

function EntityCountSystem:requestEntityToCreate(entityId, entityType, force)
	entityType = self:_normalizeType(entityType)

	if self.serverEntityType[entityType] == nil then
		entityType = "other"
	end

	local isFound = false

	if not force then
		local info = self.entityInfo[entityType]

		if info ~= nil and info[entityId] ~= nil and info[entityId][3] == ClientConst.EntityCount.NOT_CREATED then
			info[entityId][3] = ClientConst.EntityCount.CREATING
			isFound = true
		end
	end

	if (isFound or force) and self.requestCreateMap[entityType][entityId] == nil then
		self.requestCreateMap[entityType][entityId] = Time.getTickSecond()

		self:sendRpc(entityId)
	end
end

function EntityCountSystem:sendRpc(entityId)
	if pg.me ~= nil then
		pg.me:serverMsg("RPC_CS_RequestCreateClientEntity", entityId)
	end
end

function EntityCountSystem:findNearestEntityId(entities)
	local playerPos = pg.playerPos
	local minEntityId
	local minDist = 16000000
	local dist

	for id, info in pairs(entities) do
		if info[3] == ClientConst.EntityCount.NOT_CREATED then
			dist = Utils.squareDistNoYAxis(playerPos, info[2])

			if dist < minDist then
				minDist = dist
				minEntityId = id
			end
		end
	end

	return minEntityId, minDist
end

function EntityCountSystem:findFarthestEntityId(entityType, entities)
	local playerPos = pg.playerPos
	local maxEntityId
	local maxDist = 0
	local dist

	for id, info in pairs(entities) do
		if info[3] == ClientConst.EntityCount.CREATED and not self:needIgnore(entityType, info[1], info[4]) then
			dist = Utils.squareDistNoYAxis(playerPos, info[2])

			if maxDist < dist then
				maxDist = dist
				maxEntityId = id
			end
		end
	end

	return maxEntityId, maxDist
end

function EntityCountSystem:findNearestAndFarthestEntityId(entityType, entities)
	local playerPos = pg.playerPos
	local minEntityId
	local minDist = 16000000
	local maxEntityId
	local maxDist = 0
	local dist

	for id, info in pairs(entities) do
		if info[3] == ClientConst.EntityCount.NOT_CREATED then
			dist = Utils.squareDistNoYAxis(playerPos, info[2])

			if dist < minDist then
				minDist = dist
				minEntityId = id
			end
		elseif info[3] == ClientConst.EntityCount.CREATED and not self:needIgnore(entityType, info[1], info[4]) then
			dist = Utils.squareDistNoYAxis(playerPos, info[2])

			if maxDist < dist then
				maxDist = dist
				maxEntityId = id
			end
		end
	end

	return minEntityId, minDist, maxEntityId, maxDist
end

function EntityCountSystem:getNpcLoadWeightContext()
	local playerPos = pg.playerPos
	local cameraMgr = pg.global and pg.global.cameraMgr

	if playerPos == nil or cameraMgr == nil then
		return nil
	end

	local forwardX, _, forwardZ = cameraMgr:GetWorldCameraForwardEx()

	forwardX = forwardX or 0
	forwardZ = forwardZ or 0

	local forwardLengthSqr = forwardX * forwardX + forwardZ * forwardZ

	return playerPos, forwardX, forwardZ, forwardLengthSqr
end

function EntityCountSystem:findPuppetWeightCandidates(entities, playerPos, forwardX, forwardZ, forwardLengthSqr)
	local createEntityId
	local createWeight = NEGATIVE_INFINITY
	local destroyEntityId
	local destroyWeight = math.huge
	local ignoreCreatedCount = 0
	local loadConfig = self.npcLoadWeightConfig

	for entityId, info in pairs(entities) do
		local entityState = info[3]

		if self:needIgnore("ClientPuppet", info[1], info[4]) then
			if entityState == ClientConst.EntityCount.CREATED then
				ignoreCreatedCount = ignoreCreatedCount + 1
			end
		else
			local npcPos = info[2]

			if entityState == ClientConst.EntityCount.CREATED then
				local entity = EntityManager.getEntity(entityId)

				if entity ~= nil then
					local currentPos = entity:getPosition()

					npcPos = currentPos
				end
			end

			local weight = calcNpcLoadWeight(playerPos, forwardX, forwardZ, forwardLengthSqr, npcPos, loadConfig)

			if entityState == ClientConst.EntityCount.NOT_CREATED then
				if createWeight < weight then
					createEntityId = entityId
					createWeight = weight
				end
			elseif entityState == ClientConst.EntityCount.CREATED and weight < destroyWeight then
				destroyEntityId = entityId
				destroyWeight = weight
			end
		end
	end

	return createEntityId, createWeight, destroyEntityId, destroyWeight, ignoreCreatedCount
end

function EntityCountSystem:getIgnoreCreatedCount(entityType, entities)
	local count = 0

	for _, info in pairs(entities) do
		if info[3] == ClientConst.EntityCount.CREATED and self:needIgnore(entityType, info[1], info[4]) then
			count = count + 1
		end
	end

	return count
end

function EntityCountSystem:getCountedPendingCreateCount(entityType, entities)
	local count = 0
	local pendingMap = self.requestCreateMap[entityType]

	if pendingMap == nil then
		return count
	end

	for entityId, _ in pairs(pendingMap) do
		local info = entities[entityId]

		if not self:needIgnore(entityType, info[1], info[4]) then
			count = count + 1
		end
	end

	return count
end

function EntityCountSystem:getDisplayLevel1CountByType()
	local ret = {}

	for k, entities in pairs(self.entityInfo) do
		local count = 0

		for _, info in pairs(entities) do
			if info[3] == ClientConst.EntityCount.CREATED and info[4] >= 1 then
				count = count + 1
			end
		end

		ret[k] = count
	end

	return ret
end

function EntityCountSystem:sortEntityDistAndCreateForType(k, v)
	local newBalance = false
	local serverCount = 0

	for _, serverType in ipairs(self.serverEntityType[k]) do
		serverCount = serverCount + pg.global.entityMgr.getEntityCountByType(serverType)
	end

	local curCount = serverCount + self:getCountedPendingCreateCount(k, v) - self:getIgnoreCreatedCount(k, v)
	local limit = self.entityCountLimit[k]

	if curCount < limit then
		local createEntityId, minDist = self:findNearestEntityId(v)

		if createEntityId ~= nil then
			self:requestEntityToCreate(createEntityId, k, false)

			newBalance = true
		end
	elseif curCount == limit then
		local createEntityId, minDist, destroyEntityId, maxDist = self:findNearestAndFarthestEntityId(k, v)

		if minDist < maxDist then
			if createEntityId ~= nil then
				self:requestEntityToCreate(createEntityId, k, false)

				newBalance = true
			end

			if destroyEntityId ~= nil then
				self:destroyEntity(destroyEntityId, k)

				newBalance = true
			end
		end
	elseif limit < curCount then
		local destroyEntityId, maxDist = self:findFarthestEntityId(k, v)

		if destroyEntityId ~= nil then
			self:destroyEntity(destroyEntityId, k)

			newBalance = true
		end
	end

	self.inBalancing[k] = newBalance
end

function EntityCountSystem:sortPuppetWeightAndCreate(entities)
	local playerPos, forwardX, forwardZ, forwardLengthSqr = self:getNpcLoadWeightContext()

	if playerPos == nil then
		self:sortEntityDistAndCreateForType("ClientPuppet", entities)

		return
	end

	local createEntityId, createWeight, destroyEntityId, destroyWeight, ignoreCreatedCount = self:findPuppetWeightCandidates(entities, playerPos, forwardX, forwardZ, forwardLengthSqr)
	local serverCount = 0

	for _, serverType in ipairs(self.serverEntityType.ClientPuppet) do
		serverCount = serverCount + pg.global.entityMgr.getEntityCountByType(serverType)
	end

	local curCount = serverCount + self:getCountedPendingCreateCount("ClientPuppet", entities) - ignoreCreatedCount
	local limit = self.entityCountLimit.ClientPuppet
	local newBalance = false

	if curCount < limit then
		if createEntityId ~= nil and createWeight > NEGATIVE_INFINITY then
			self:requestEntityToCreate(createEntityId, "ClientPuppet", false)

			newBalance = true
		end
	elseif curCount == limit then
		if createEntityId ~= nil and destroyEntityId ~= nil and destroyWeight < createWeight then
			self:requestEntityToCreate(createEntityId, "ClientPuppet", false)
			self:destroyEntity(destroyEntityId, "ClientPuppet")

			newBalance = true
		end
	elseif destroyEntityId ~= nil then
		self:destroyEntity(destroyEntityId, "ClientPuppet")

		newBalance = true
	end

	self.inBalancing.ClientPuppet = newBalance
end

function EntityCountSystem:destroyEntity(entityId, classType)
	if self.entityInfo[classType] ~= nil and self.entityInfo[classType][entityId] ~= nil then
		pg.me:_destroyClientEntity(entityId)
		self:markEntityNotCreated(entityId)
	end
end

function EntityCountSystem:destroyOneFarthestEntity()
	local destroyEntityId, destroyClassType
	local maxDist = 0

	for classType, entities in pairs(self.entityInfo) do
		local entityId, dist = self:findFarthestEntityId(classType, entities)

		if entityId ~= nil and maxDist < dist then
			destroyEntityId = entityId
			destroyClassType = classType
			maxDist = dist
		end
	end

	if destroyEntityId ~= nil then
		self:destroyEntity(destroyEntityId, destroyClassType)
	end

	return destroyEntityId
end

function EntityCountSystem:checkEntityCreate()
	local current = Time.getTickSecond()

	for k, v in pairs(self.requestCreateMap) do
		for id, time in pairs(v) do
			if current > time + 5 then
				self:sendRpc(id)

				self.requestCreateMap[k][id] = current
			end
		end
	end
end

function EntityCountSystem:onTick()
	local currentTime = Time.getTickSecond()
	local anyTicked = false

	for k, v in pairs(self.entityInfo) do
		if currentTime >= (self.nextTickTime[k] or 0) then
			if k == "ClientPuppet" then
				self:sortPuppetWeightAndCreate(v)
			else
				self:sortEntityDistAndCreateForType(k, v)
			end

			local delay

			if self.inBalancing[k] then
				delay = k == "ClientEnvObject" and ENVOBJ_BALANCE_TICK_DELAY or BALANCE_TICK_DELAY
			else
				delay = NORMAL_TICK_DELAY
			end

			self.nextTickTime[k] = currentTime + delay
			anyTicked = true
		end
	end

	if anyTicked then
		self:checkEntityCreate()
	end
end

function EntityCountSystem:refreshEntityPositionData(entittId, pos)
	for k, v in pairs(self.entityInfo) do
		local entity = v[entittId]

		if entity then
			entity[2] = pos
		end
	end
end

function EntityCountSystem:hasTracingQuest(staticId)
	if self.entityTracingQuestSetDirty then
		self:rebuildEntityTracingQuestInfo()
	end

	return self.entityTracingQuestInfo[staticId] == true
end

function EntityCountSystem:rebuildEntityTracingQuestInfo()
	table.clear(self.entityTracingQuestInfo)

	if pg.me == nil then
		return
	end

	local function addStaticId(questId)
		if questId == nil then
			return
		end

		local questData = QuestUtils.getQuestData(questId)
		local entityInfos = QuestEntityData[questId]

		if questData ~= nil and entityInfos ~= nil then
			for _, entityInfo in pairs(entityInfos) do
				if entityInfo.staticId ~= nil and entityInfo.staticId ~= 0 and entityInfo.state == questData.state then
					self.entityTracingQuestInfo[entityInfo.staticId] = true
				end
			end
		end
	end

	addStaticId(pg.me.curTraceTempQuest)
	addStaticId(pg.me.curTraceQuest)
	addStaticId(pg.me.curTraceStoryQuest)
	addStaticId(pg.me.curTraceSecondQuest)

	self.entityTracingQuestSetDirty = false
end

function EntityCountSystem:markEntityTracingQuestDirty()
	self.entityTracingQuestSetDirty = true
end

return EntityCountSystem
