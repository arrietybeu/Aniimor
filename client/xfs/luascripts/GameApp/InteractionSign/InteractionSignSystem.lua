-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\InteractionSign\\InteractionSignSystem.lua

local Class = require("Core.Framework.Class")
local SystemBase = require("GameApp.Core.SystemBase")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local MessageName = require("Const.MessageName")
local EventConst = require("Const.EventConst")
local Const = require("Common.Const.Const")
local HintAnimeBook = require("Data.hint_anime_book_data")
local HintAnime = require("Data.hint_anime_data")
local Utils = require("Common.Utils.Utils")
local CallbackHandler = require("Core.Common.CallbackHandler")
local EntityManager = require("Core.Common.EntityManager")
local InteractionSignUnitBase = require("GameApp.InteractionSign.InteractionSignUnitBase")
local logger = LoggerManager.getLogger("InteractionSignSystem")
local InteractionSignSystem = Class.LightClass("InteractionSignSystem", SystemBase)

InteractionSignSystem.DISTANCE_CHECK_INTERVAL = 0.2
InteractionSignSystem.DISTANCE_EXIT_PADDING = 1
InteractionSignSystem.STATIC_CANDIDATE_POSITION_CHECK_INTERVAL_TICKS = 5
InteractionSignSystem.STATIC_CANDIDATE_MOVE_THRESHOLD_SQR = 0.25
InteractionSignSystem.POSITION_MODE = {
	STATIC_CONFIRMED = 3,
	STATIC_CANDIDATE = 2,
	DYNAMIC = 1
}
InteractionSignSystem.DISTANCE_MODE = {
	THREE_DIMENSIONAL = 3,
	VERTICAL = 2,
	HORIZONTAL = 1
}
InteractionSignSystem.MAIN_BODY_TYPE = {
	NPC = "npc",
	INTERACTOR = "interactor",
	ENVOBJ = "envobj",
	CHEST = "chest",
	STATIC = "static",
	ACTOR = "actor"
}

local LEGACY_INTERACT_TYPE = "interact"
local EMPTY_MAIN_BODY_TYPE = ""
local VALID_MAIN_BODY_TYPES = {
	[EMPTY_MAIN_BODY_TYPE] = true,
	[InteractionSignSystem.MAIN_BODY_TYPE.ACTOR] = true,
	[InteractionSignSystem.MAIN_BODY_TYPE.STATIC] = true,
	[InteractionSignSystem.MAIN_BODY_TYPE.CHEST] = true,
	[InteractionSignSystem.MAIN_BODY_TYPE.INTERACTOR] = true,
	[InteractionSignSystem.MAIN_BODY_TYPE.NPC] = true,
	[InteractionSignSystem.MAIN_BODY_TYPE.ENVOBJ] = true
}

function InteractionSignSystem:createConfigIndexBucket()
	return {
		all = {},
		wildcard = {},
		byId = {}
	}
end

function InteractionSignSystem:appendUniqueConfigIds(target, uniqueSet, source)
	if source == nil then
		return
	end

	for _, cfgId in ipairs(source) do
		if uniqueSet[cfgId] == nil then
			uniqueSet[cfgId] = true
			target[#target + 1] = cfgId
		end
	end
end

InteractionSignSystem.HIDE_KEY = {
	DIALOGUE_GRAPH = 1
}

function InteractionSignSystem:getMessageBindMap()
	return {
		[MessageName.HINT_ANIME_STATE] = "onHintAnimeStateChange",
		[MessageName.REFRESH_INTERACT_SIGN_DYNAMIC] = "onDynamicInteractionRefresh"
	}
end

function InteractionSignSystem:onCtor()
	self.signUnitList = {}
	self.pause = false
	self.hideFlags = {}
	self._signVisible = true
	self._entityContexts = {}
	self._entityIdToGlobalId = {}
	self._dynamicEntityGlobalIds = {}
	self._staticCandidateEntityGlobalIds = {}
	self._staticConfirmedEntityGlobalIds = {}
	self._candidateEntityCount = 0
	self._candidateEntityPeakCount = 0
	self._dynamicEntityCount = 0
	self._staticCandidateEntityCount = 0
	self._staticConfirmedEntityCount = 0
	self._distanceCheckSequence = 0
	self._staticCandidateSequence = 0
	self._onEntityEnterSpace = nil
	self._onEntityLeaveSpace = nil

	self:rebuildConfigIndex()
end

function InteractionSignSystem:onInit()
	self:registerEntityLifecycleListeners()
	self:registerExistingSpaceEntities()
end

function InteractionSignSystem:onDestroy()
	self:unregisterEntityLifecycleListeners()
	self:clearEntityContexts()
	self:clearUnits()

	self.signUnitList = nil
	self._entityContexts = nil
	self._entityIdToGlobalId = nil
	self._dynamicEntityGlobalIds = nil
	self._staticCandidateEntityGlobalIds = nil
	self._staticConfirmedEntityGlobalIds = nil
	self._configIndex = nil
	self._allConfigIds = nil
	self._noFuncConfigIds = nil
	self._defaultActiveConfigSet = nil
	self._funcConfigIndex = nil
	self._configMaxDistance = nil
	self._configMaxDistanceSqr = nil
	self._configExitDistanceSqr = nil
end

function InteractionSignSystem:onSceneUnloaded(sceneId, sceneName)
	self:clearEntityContexts()
	self:clearUnits()

	self.signUnitList = {}

	self:resetCandidateSpatialStats()
end

function InteractionSignSystem:resetCandidateSpatialStats()
	self._dynamicEntityGlobalIds = {}
	self._staticCandidateEntityGlobalIds = {}
	self._staticConfirmedEntityGlobalIds = {}
	self._candidateEntityCount = 0
	self._candidateEntityPeakCount = 0
	self._dynamicEntityCount = 0
	self._staticCandidateEntityCount = 0
	self._staticConfirmedEntityCount = 0
	self._distanceCheckSequence = 0
	self._staticCandidateSequence = 0
end

function InteractionSignSystem:getCandidateSpatialStats()
	return {
		candidateCount = self._candidateEntityCount,
		candidatePeakCount = self._candidateEntityPeakCount,
		dynamicCount = self._dynamicEntityCount,
		staticCandidateCount = self._staticCandidateEntityCount,
		staticConfirmedCount = self._staticConfirmedEntityCount
	}
end

function InteractionSignSystem:clearUnits()
	if self.signUnitList then
		for id in pairs(self.signUnitList) do
			self:removeInteractSignByGlobalId(id)
		end
	end
end

function InteractionSignSystem:registerEntityLifecycleListeners()
	if self._onEntityEnterSpace ~= nil then
		return
	end

	self._onEntityEnterSpace = CallbackHandler(self, "onEntityEnterSpace")
	self._onEntityLeaveSpace = CallbackHandler(self, "onEntityLeaveSpace")

	EntityManager.eventEmitter:addEventListener(EventConst.ENTITY_ENTER_SPACE, self._onEntityEnterSpace)
	EntityManager.eventEmitter:addEventListener(EventConst.ENTITY_LEAVE_SPACE, self._onEntityLeaveSpace)
end

function InteractionSignSystem:unregisterEntityLifecycleListeners()
	if self._onEntityEnterSpace == nil then
		return
	end

	EntityManager.eventEmitter:removeEventListener(EventConst.ENTITY_ENTER_SPACE, self._onEntityEnterSpace)
	EntityManager.eventEmitter:removeEventListener(EventConst.ENTITY_LEAVE_SPACE, self._onEntityLeaveSpace)

	self._onEntityEnterSpace = nil
	self._onEntityLeaveSpace = nil
end

function InteractionSignSystem:registerExistingSpaceEntities(space)
	local currentSpace = space

	if currentSpace == nil and pg.global and pg.global.scene then
		currentSpace = pg.global.scene.curSpace
	end

	if currentSpace == nil or currentSpace._globalId2Entity == nil then
		return
	end

	for _, ent in pairs(currentSpace._globalId2Entity) do
		self:onEntityEnterSpace(ent)
	end
end

function InteractionSignSystem:onSpaceCreated(space)
	self:registerExistingSpaceEntities(space)
end

function InteractionSignSystem.normalizeMainBodyType(mainBodyType)
	if string.isNilOrEmpty(mainBodyType) then
		return EMPTY_MAIN_BODY_TYPE
	end

	if mainBodyType == LEGACY_INTERACT_TYPE then
		return InteractionSignSystem.MAIN_BODY_TYPE.INTERACTOR
	end

	return mainBodyType
end

function InteractionSignSystem:_addConfigToIndex(configIndex, mainBodyType, mainBodyIds, cfgId)
	local bucket = configIndex[mainBodyType]

	if bucket == nil then
		bucket = self:createConfigIndexBucket()
		configIndex[mainBodyType] = bucket
	end

	bucket.all[#bucket.all + 1] = cfgId

	if mainBodyIds == nil or mainBodyIds[1] == nil then
		bucket.wildcard[#bucket.wildcard + 1] = cfgId

		return
	end

	for _, mainBodyId in ipairs(mainBodyIds) do
		local idConfigs = bucket.byId[mainBodyId]

		if idConfigs == nil then
			idConfigs = {}
			bucket.byId[mainBodyId] = idConfigs
		end

		idConfigs[#idConfigs + 1] = cfgId
	end
end

function InteractionSignSystem:sortConfigIndex(configIndex)
	for _, bucket in pairs(configIndex) do
		table.sort(bucket.all)
		table.sort(bucket.wildcard)

		for _, idConfigs in pairs(bucket.byId) do
			table.sort(idConfigs)
		end
	end
end

function InteractionSignSystem:rebuildConfigIndex()
	self._configIndex = {}
	self._allConfigIds = {}
	self._noFuncConfigIds = {}
	self._defaultActiveConfigSet = {}
	self._funcConfigIndex = {}
	self._configMaxDistance = {}
	self._configMaxDistanceSqr = {}
	self._configExitDistanceSqr = {}

	local invalidMainBodyTypes = {}

	for cfgId, cfgData in pairs(HintAnimeBook) do
		local mainBodyType = InteractionSignSystem.normalizeMainBodyType(cfgData.mainBodyType)

		if VALID_MAIN_BODY_TYPES[mainBodyType] then
			self._allConfigIds[#self._allConfigIds + 1] = cfgId

			self:_addConfigToIndex(self._configIndex, mainBodyType, cfgData.mainBodyID, cfgId)

			local funcId = cfgData.mainBodyFuncID
			local hasFuncId = funcId ~= nil and funcId > 0

			if hasFuncId then
				local funcConfigs = self._funcConfigIndex[funcId]

				if funcConfigs == nil then
					funcConfigs = {}
					self._funcConfigIndex[funcId] = funcConfigs
				end

				funcConfigs[#funcConfigs + 1] = cfgId
			else
				self._noFuncConfigIds[#self._noFuncConfigIds + 1] = cfgId

				if cfgData.notInheritParentState == nil or cfgData.notInheritParentState == 0 then
					self._defaultActiveConfigSet[cfgId] = true
				end
			end

			local maxDistance = 0
			local hintAnimeCfg = HintAnime[cfgData.hintAnimeID]
			local distGroup = hintAnimeCfg and hintAnimeCfg.distGroup

			if distGroup then
				for _, distanceData in ipairs(distGroup) do
					local distance = distanceData and distanceData[1]

					if distance and maxDistance < distance then
						maxDistance = distance
					end
				end
			end

			self._configMaxDistance[cfgId] = maxDistance
			self._configMaxDistanceSqr[cfgId] = maxDistance * maxDistance

			local exitDistance = maxDistance + InteractionSignSystem.DISTANCE_EXIT_PADDING

			self._configExitDistanceSqr[cfgId] = exitDistance * exitDistance
		elseif invalidMainBodyTypes[mainBodyType] == nil then
			invalidMainBodyTypes[mainBodyType] = true

			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("unsupported interaction sign mainBodyType: %s", tostring(mainBodyType))
			end
		end
	end

	table.sort(self._allConfigIds)
	table.sort(self._noFuncConfigIds)

	for _, funcConfigs in pairs(self._funcConfigIndex) do
		table.sort(funcConfigs)
	end

	self:sortConfigIndex(self._configIndex)
end

function InteractionSignSystem:_getEntityConfigIdsFromIndex(ent, configIndex)
	local configIds = {}
	local uniqueSet = {}

	if ent == nil or configIndex == nil then
		return configIds
	end

	for mainBodyType, bucket in pairs(configIndex) do
		local isMatchedType = InteractionSignSystem.checkEntityType(mainBodyType, ent)

		if isMatchedType then
			local entityId

			if mainBodyType == InteractionSignSystem.MAIN_BODY_TYPE.STATIC then
				entityId = ent.staticId
			else
				entityId = ent.templateId
			end

			self:appendUniqueConfigIds(configIds, uniqueSet, bucket.wildcard)

			if entityId ~= nil then
				self:appendUniqueConfigIds(configIds, uniqueSet, bucket.byId[entityId])
			end
		end
	end

	table.sort(configIds)

	return configIds
end

function InteractionSignSystem:getEntityConfigIds(ent)
	return self:_getEntityConfigIdsFromIndex(ent, self._configIndex)
end

function InteractionSignSystem:clearEntityContext(globalId, removeSigns)
	local context = self._entityContexts[globalId]

	if context == nil then
		return
	end

	if self._entityIdToGlobalId[context.entityId] == globalId then
		self._entityIdToGlobalId[context.entityId] = nil
	end

	self:removeEntityFromPositionModeCollection(globalId, context.positionMode)

	self._candidateEntityCount = math.max(0, self._candidateEntityCount - 1)
	self._entityContexts[globalId] = nil

	if removeSigns == true then
		self:removeInteractSignByGlobalId(globalId)
	end
end

function InteractionSignSystem:clearEntityContexts()
	if self._entityContexts == nil then
		return
	end

	local globalIds = {}

	for globalId, _ in pairs(self._entityContexts) do
		globalIds[#globalIds + 1] = globalId
	end

	for _, globalId in ipairs(globalIds) do
		self:clearEntityContext(globalId, true)
	end

	self._entityContexts = {}
	self._entityIdToGlobalId = {}
	self._dynamicEntityGlobalIds = {}
	self._staticCandidateEntityGlobalIds = {}
	self._staticConfirmedEntityGlobalIds = {}
	self._candidateEntityCount = 0
	self._dynamicEntityCount = 0
	self._staticCandidateEntityCount = 0
	self._staticConfirmedEntityCount = 0
end

function InteractionSignSystem:createConfigIdSet(configIds)
	local configIdSet = {}

	for _, cfgId in ipairs(configIds) do
		configIdSet[cfgId] = true
	end

	return configIdSet
end

function InteractionSignSystem:removeEntityFromPositionModeCollection(globalId, positionMode)
	if positionMode == InteractionSignSystem.POSITION_MODE.DYNAMIC then
		if self._dynamicEntityGlobalIds[globalId] then
			self._dynamicEntityGlobalIds[globalId] = nil
			self._dynamicEntityCount = math.max(0, self._dynamicEntityCount - 1)
		end
	elseif positionMode == InteractionSignSystem.POSITION_MODE.STATIC_CANDIDATE then
		if self._staticCandidateEntityGlobalIds[globalId] then
			self._staticCandidateEntityGlobalIds[globalId] = nil
			self._staticCandidateEntityCount = math.max(0, self._staticCandidateEntityCount - 1)
		end
	elseif positionMode == InteractionSignSystem.POSITION_MODE.STATIC_CONFIRMED and self._staticConfirmedEntityGlobalIds[globalId] then
		self._staticConfirmedEntityGlobalIds[globalId] = nil
		self._staticConfirmedEntityCount = math.max(0, self._staticConfirmedEntityCount - 1)
	end
end

function InteractionSignSystem:addEntityToPositionModeCollection(globalId, positionMode)
	if positionMode == InteractionSignSystem.POSITION_MODE.DYNAMIC then
		if self._dynamicEntityGlobalIds[globalId] == nil then
			self._dynamicEntityGlobalIds[globalId] = true
			self._dynamicEntityCount = self._dynamicEntityCount + 1
		end
	elseif positionMode == InteractionSignSystem.POSITION_MODE.STATIC_CANDIDATE then
		if self._staticCandidateEntityGlobalIds[globalId] == nil then
			self._staticCandidateEntityGlobalIds[globalId] = true
			self._staticCandidateEntityCount = self._staticCandidateEntityCount + 1
		end
	elseif positionMode == InteractionSignSystem.POSITION_MODE.STATIC_CONFIRMED and self._staticConfirmedEntityGlobalIds[globalId] == nil then
		self._staticConfirmedEntityGlobalIds[globalId] = true
		self._staticConfirmedEntityCount = self._staticConfirmedEntityCount + 1
	end
end

function InteractionSignSystem:setEntityPositionMode(globalId, context, positionMode)
	if context.positionMode == positionMode then
		self:addEntityToPositionModeCollection(globalId, positionMode)

		return
	end

	self:removeEntityFromPositionModeCollection(globalId, context.positionMode)

	context.positionMode = positionMode

	self:addEntityToPositionModeCollection(globalId, positionMode)
end

function InteractionSignSystem:isEntityDefinitelyDynamic(ent)
	if ent.entityCanMove ~= false then
		return true
	end

	local rigidBodyState = ent.serverPhysicsInfo and ent.serverPhysicsInfo.rigidBodyState

	return rigidBodyState == Const.RigidBodyState.NoneKinematic
end

function InteractionSignSystem:getInitialEntityPositionMode(ent)
	if self:isEntityDefinitelyDynamic(ent) then
		return InteractionSignSystem.POSITION_MODE.DYNAMIC
	end

	return InteractionSignSystem.POSITION_MODE.STATIC_CANDIDATE
end

function InteractionSignSystem:getEntityDistanceMode(ent)
	if ent.getPlayerDistance then
		return InteractionSignSystem.DISTANCE_MODE.HORIZONTAL
	end

	if ent.getPlayerYDistance then
		return InteractionSignSystem.DISTANCE_MODE.VERTICAL
	end

	return InteractionSignSystem.DISTANCE_MODE.THREE_DIMENSIONAL
end

function InteractionSignSystem:cacheEntityPosition(ent, context)
	local position = ent and ent.getPosition and ent:getPosition()

	if position == nil then
		return false
	end

	context.positionX = position.x
	context.positionY = position.y
	context.positionZ = position.z

	return context.positionX ~= nil and context.positionY ~= nil and context.positionZ ~= nil
end

function InteractionSignSystem:hasEntityMovedFromCachedPosition(ent, context)
	local position = ent and ent.getPosition and ent:getPosition()

	if position == nil or context.positionX == nil then
		return false
	end

	local deltaX = position.x - context.positionX
	local deltaY = position.y - context.positionY
	local deltaZ = position.z - context.positionZ
	local movedDistanceSqr = deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ

	if movedDistanceSqr <= InteractionSignSystem.STATIC_CANDIDATE_MOVE_THRESHOLD_SQR then
		return false
	end

	context.positionX = position.x
	context.positionY = position.y
	context.positionZ = position.z

	return true
end

function InteractionSignSystem:getNextStaticCandidateCheckSequence()
	self._staticCandidateSequence = self._staticCandidateSequence + 1

	local interval = InteractionSignSystem.STATIC_CANDIDATE_POSITION_CHECK_INTERVAL_TICKS

	return self._distanceCheckSequence + self._staticCandidateSequence % interval + 1
end

function InteractionSignSystem:initializeEntityPositionTracking(globalId, ent, context, isNewContext)
	context.distanceMode = self:getEntityDistanceMode(ent)

	self:cacheEntityPosition(ent, context)

	if isNewContext then
		self:setEntityPositionMode(globalId, context, self:getInitialEntityPositionMode(ent))
	elseif context.positionMode == InteractionSignSystem.POSITION_MODE.STATIC_CANDIDATE and self:isEntityDefinitelyDynamic(ent) then
		self:setEntityPositionMode(globalId, context, InteractionSignSystem.POSITION_MODE.DYNAMIC)
	else
		self:addEntityToPositionModeCollection(globalId, context.positionMode)
	end

	if context.positionMode == InteractionSignSystem.POSITION_MODE.STATIC_CANDIDATE then
		context.nextPositionCheckSequence = self:getNextStaticCandidateCheckSequence()
	else
		context.nextPositionCheckSequence = nil
	end
end

function InteractionSignSystem:setEntityPositionStaticConfirmed(globalId, isStaticConfirmed)
	local context = self._entityContexts[globalId]

	if context == nil then
		return false
	end

	local ent = pg.getEntity(context.entityId)

	if ent == nil or ent.getGlobalId == nil or ent:getGlobalId() ~= globalId then
		return false
	end

	if isStaticConfirmed then
		self:cacheEntityPosition(ent, context)

		context.nextPositionCheckSequence = nil

		self:setEntityPositionMode(globalId, context, InteractionSignSystem.POSITION_MODE.STATIC_CONFIRMED)
	else
		local positionMode = self:getInitialEntityPositionMode(ent)

		self:setEntityPositionMode(globalId, context, positionMode)

		if positionMode == InteractionSignSystem.POSITION_MODE.STATIC_CANDIDATE then
			context.nextPositionCheckSequence = self:getNextStaticCandidateCheckSequence()
		end
	end

	self:refreshEntityDistanceState(ent, context)

	return true
end

function InteractionSignSystem:onEntityEnterSpace(ent)
	if ent == nil or ent.getGlobalId == nil or ent.getPosition == nil then
		return
	end

	local configIds = self:getEntityConfigIds(ent)
	local globalId = ent:getGlobalId()
	local oldContext = self._entityContexts[globalId]

	if configIds[1] == nil then
		local mappedGlobalId = self._entityIdToGlobalId[ent.id]

		if mappedGlobalId then
			self:clearEntityContext(mappedGlobalId, true)
		end

		if oldContext and mappedGlobalId ~= globalId then
			self:clearEntityContext(globalId, true)
		end

		if ent == pg.me then
			self:refreshAllDynamicInteractionSigns()
		end

		return
	end

	local oldGlobalId = self._entityIdToGlobalId[ent.id]

	if oldGlobalId and oldGlobalId ~= globalId then
		self:clearEntityContext(oldGlobalId, true)
	end

	if oldContext and oldContext.entityId ~= ent.id then
		self:clearEntityContext(globalId, true)

		oldContext = nil
	end

	local isNewContext = oldContext == nil
	local context = oldContext or {}

	context.entityId = ent.id
	context.configIds = configIds
	context.configIdSet = self:createConfigIdSet(configIds)
	context.inRangeConfigIds = context.inRangeConfigIds or {}
	context.hintEventStates = context.hintEventStates or {}

	for cfgId in pairs(context.hintEventStates) do
		if context.configIdSet[cfgId] ~= true then
			context.hintEventStates[cfgId] = nil
		end
	end

	self._entityContexts[globalId] = context
	self._entityIdToGlobalId[ent.id] = globalId

	if isNewContext then
		self._candidateEntityCount = self._candidateEntityCount + 1
		self._candidateEntityPeakCount = math.max(self._candidateEntityPeakCount, self._candidateEntityCount)
	end

	self:initializeEntityPositionTracking(globalId, ent, context, isNewContext)
	self:refreshEntityDistanceState(ent, context)

	for _, cfgId in ipairs(configIds) do
		if self._defaultActiveConfigSet[cfgId] then
			self:refreshInteractSignPresentation(globalId, cfgId, HintAnimeBook[cfgId])
		end
	end

	self:refreshEntityDynamicInteractionSigns(ent, configIds)

	if ent == pg.me then
		self:refreshAllDynamicInteractionSigns()
	end
end

function InteractionSignSystem:onEntityLeaveSpace(ent)
	if ent == nil then
		return
	end

	local globalId = ent.getGlobalId and ent:getGlobalId() or self._entityIdToGlobalId[ent.id]
	local context = globalId and self._entityContexts[globalId]

	if context and context.entityId == ent.id then
		self:clearEntityContext(globalId, true)
	end
end

function InteractionSignSystem:isEntityPresentationReady(ent)
	return ent ~= nil and ent.getPosition ~= nil and ent.eModel ~= nil
end

function InteractionSignSystem:getEntityPlayerDistance(ent)
	if ent == nil or pg.pawn == nil then
		return nil
	end

	if ent.getPlayerDistance then
		local distance = ent:getPlayerDistance()

		if distance ~= nil then
			return distance
		end
	end

	if ent.getPlayerYDistance then
		local distance = ent:getPlayerYDistance()

		if distance ~= nil then
			return distance
		end
	end

	if ent.getPosition and pg.pawn.getPosition then
		return Vector3.Distance(ent:getPosition(), pg.pawn:getPosition())
	end

	return nil
end

function InteractionSignSystem:isConfigInRangeByDistanceSqr(cfgId, distanceSqr, wasInRange)
	local maxDistanceSqr = self._configMaxDistanceSqr[cfgId] or 0

	if maxDistanceSqr <= 0 then
		return true
	end

	if distanceSqr == nil then
		return false
	end

	if wasInRange then
		return distanceSqr <= self._configExitDistanceSqr[cfgId]
	end

	return distanceSqr <= maxDistanceSqr
end

function InteractionSignSystem:getCachedEntityPlayerDistanceSqr(context)
	if context.positionX == nil or pg.pawn == nil then
		return nil
	end

	local playerPosition = pg.me and pg.me.posRef

	if playerPosition == nil and pg.pawn.getPosition then
		playerPosition = pg.pawn:getPosition()
	end

	if playerPosition == nil then
		return nil
	end

	local deltaX = context.positionX - playerPosition.x
	local deltaY = context.positionY - playerPosition.y
	local deltaZ = context.positionZ - playerPosition.z

	if context.distanceMode == InteractionSignSystem.DISTANCE_MODE.HORIZONTAL then
		return deltaX * deltaX + deltaZ * deltaZ
	end

	if context.distanceMode == InteractionSignSystem.DISTANCE_MODE.VERTICAL then
		return deltaY * deltaY
	end

	return deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ
end

function InteractionSignSystem:refreshEntityRangeStates(globalId, context, ready, distanceSqr)
	if context == nil then
		return
	end

	for _, cfgId in ipairs(context.configIds) do
		local wasInRange = context.inRangeConfigIds[cfgId] == true
		local isInRange = ready and self:isConfigInRangeByDistanceSqr(cfgId, distanceSqr, wasInRange) or false

		if wasInRange ~= isInRange then
			context.inRangeConfigIds[cfgId] = isInRange or nil

			self:refreshInteractSignPresentation(globalId, cfgId, HintAnimeBook[cfgId])
		end
	end

	context.presentationReady = ready
end

function InteractionSignSystem:refreshDynamicEntityDistanceState(globalId, ent, context)
	local ready = self:isEntityPresentationReady(ent)
	local distance = ready and self:getEntityPlayerDistance(ent) or nil
	local distanceSqr = distance and distance * distance or nil

	self:refreshEntityRangeStates(globalId, context, ready, distanceSqr)
end

function InteractionSignSystem:refreshStaticCandidatePosition(globalId, ent, context, forceCheck)
	local nextCheckSequence = context.nextPositionCheckSequence or 0

	if not forceCheck and nextCheckSequence > self._distanceCheckSequence then
		return false
	end

	context.nextPositionCheckSequence = self._distanceCheckSequence + InteractionSignSystem.STATIC_CANDIDATE_POSITION_CHECK_INTERVAL_TICKS

	if self:isEntityDefinitelyDynamic(ent) or self:hasEntityMovedFromCachedPosition(ent, context) then
		context.nextPositionCheckSequence = nil

		self:setEntityPositionMode(globalId, context, InteractionSignSystem.POSITION_MODE.DYNAMIC)

		return true
	end

	if context.positionX == nil then
		self:cacheEntityPosition(ent, context)
	end

	return false
end

function InteractionSignSystem:refreshStaticCandidateEntityDistanceState(globalId, ent, context)
	local ready = self:isEntityPresentationReady(ent)
	local forcePositionCheck = ready and context.presentationReady ~= true

	if self:refreshStaticCandidatePosition(globalId, ent, context, forcePositionCheck) then
		self:refreshDynamicEntityDistanceState(globalId, ent, context)

		return
	end

	local distanceSqr = ready and self:getCachedEntityPlayerDistanceSqr(context) or nil

	self:refreshEntityRangeStates(globalId, context, ready, distanceSqr)
end

function InteractionSignSystem:refreshStaticConfirmedEntityDistanceState(globalId, ent, context)
	local ready = self:isEntityPresentationReady(ent)
	local distanceSqr = ready and self:getCachedEntityPlayerDistanceSqr(context) or nil

	self:refreshEntityRangeStates(globalId, context, ready, distanceSqr)
end

function InteractionSignSystem:refreshEntityDistanceState(ent, context)
	if ent == nil or context == nil or context.entityId ~= ent.id then
		return
	end

	local globalId = self._entityIdToGlobalId[ent.id]

	if globalId == nil then
		return
	end

	if context.positionMode == InteractionSignSystem.POSITION_MODE.STATIC_CANDIDATE then
		self:refreshStaticCandidateEntityDistanceState(globalId, ent, context)
	elseif context.positionMode == InteractionSignSystem.POSITION_MODE.STATIC_CONFIRMED then
		self:refreshStaticConfirmedEntityDistanceState(globalId, ent, context)
	else
		self:refreshDynamicEntityDistanceState(globalId, ent, context)
	end
end

function InteractionSignSystem:refreshPositionModeCollection(positionModeCollection, positionMode, invalidGlobalIds)
	for globalId in pairs(positionModeCollection) do
		local context = self._entityContexts[globalId]

		if context and context.positionMode == positionMode then
			local ent = pg.getEntity(context.entityId)

			if ent and ent.getGlobalId and ent:getGlobalId() == globalId then
				self:refreshEntityDistanceState(ent, context)
			else
				invalidGlobalIds[#invalidGlobalIds + 1] = globalId
			end
		end
	end
end

function InteractionSignSystem:refreshAllEntityDistanceStates()
	local invalidGlobalIds = {}

	self:refreshPositionModeCollection(self._dynamicEntityGlobalIds, InteractionSignSystem.POSITION_MODE.DYNAMIC, invalidGlobalIds)
	self:refreshPositionModeCollection(self._staticCandidateEntityGlobalIds, InteractionSignSystem.POSITION_MODE.STATIC_CANDIDATE, invalidGlobalIds)
	self:refreshPositionModeCollection(self._staticConfirmedEntityGlobalIds, InteractionSignSystem.POSITION_MODE.STATIC_CONFIRMED, invalidGlobalIds)

	for _, globalId in ipairs(invalidGlobalIds) do
		self:clearEntityContext(globalId, true)
	end
end

function InteractionSignSystem:onTick()
	if self.pause then
		return
	end

	self._distanceCheckSequence = self._distanceCheckSequence + 1

	self:refreshAllEntityDistanceStates()
end

function InteractionSignSystem:getEntityDynamicFuncIds(ent)
	local funcIds = {}

	if ent == nil then
		return funcIds
	end

	if pg.me and ent.getNpcSpecialInteractionData then
		local specialInteractionData = ent:getNpcSpecialInteractionData()

		if specialInteractionData then
			for _, interactionData in ipairs(specialInteractionData) do
				local actionPrototypeId = interactionData.actionPrototypeId

				if actionPrototypeId then
					funcIds[actionPrototypeId % 100000] = true
				end
			end
		end
	end

	if ent.customInteractIds then
		for _, interactConfigId in pairs(ent.customInteractIds) do
			funcIds[interactConfigId] = true
		end
	end

	return funcIds
end

function InteractionSignSystem:entityHasFuncId(ent, funcId)
	if ent == nil or funcId == nil or funcId <= 0 then
		return false
	end

	if ent.funcMenuId == funcId then
		return true
	end

	if ent.getNpcInteractionData then
		local interactionData = ent:getNpcInteractionData()

		if interactionData then
			for _, data in ipairs(interactionData) do
				if data.actionPrototypeId == funcId then
					return true
				end
			end
		end
	end

	if ent.getCarryInteractionListData then
		local carryInteractionData = ent:getCarryInteractionListData()

		if carryInteractionData and carryInteractionData.actionPrototypeId == funcId then
			return true
		end
	end

	if funcId == 1001 then
		if ent.randomDialogueTextData ~= nil and ent.canInteractRandomDialogueText then
			return true
		end

		if ent.allowRandomDialogueHandlePetEthnicGroup and ent.randomDialogueTextData == nil then
			return true
		end
	end

	local context = self._entityContexts[ent:getGlobalId()]

	if context and context.entityId == ent.id and context.dynamicFuncIds then
		return context.dynamicFuncIds[funcId] == true
	end

	return self:getEntityDynamicFuncIds(ent)[funcId] == true
end

function InteractionSignSystem:refreshEntityDynamicInteractionSigns(ent, configIds)
	if ent == nil then
		return
	end

	local globalId = ent:getGlobalId()
	local context = self._entityContexts[globalId]

	if context == nil or context.entityId ~= ent.id then
		return
	end

	self:refreshEntityDistanceState(ent, context)

	local dynamicFuncIds = self:getEntityDynamicFuncIds(ent)

	context.dynamicFuncIds = dynamicFuncIds

	local activeConfigIds = {}

	configIds = configIds or self:getEntityConfigIds(ent)

	for _, cfgId in ipairs(configIds) do
		local cfgData = HintAnimeBook[cfgId]
		local funcId = cfgData.mainBodyFuncID

		if funcId and funcId > 0 and dynamicFuncIds[funcId] and (cfgData.notInheritParentState == nil or cfgData.notInheritParentState == 0) then
			activeConfigIds[cfgId] = true
		end
	end

	local oldActiveConfigIds = context.dynamicConfigIds or {}

	context.dynamicConfigIds = activeConfigIds

	for cfgId in pairs(activeConfigIds) do
		if oldActiveConfigIds[cfgId] ~= true then
			self:refreshInteractSignPresentation(globalId, cfgId, HintAnimeBook[cfgId])
		end
	end

	for cfgId, _ in pairs(oldActiveConfigIds) do
		if activeConfigIds[cfgId] == nil then
			self:refreshInteractSignPresentation(globalId, cfgId, HintAnimeBook[cfgId])
		end
	end
end

function InteractionSignSystem:refreshAllDynamicInteractionSigns()
	for globalId, context in pairs(self._entityContexts) do
		local ent = pg.getEntity(context.entityId)

		if ent and ent.getGlobalId and ent:getGlobalId() == globalId then
			self:refreshEntityDynamicInteractionSigns(ent)
		end
	end
end

function InteractionSignSystem:addInteractSign(globalId, cfgId, cfgData)
	if globalId == nil or cfgId == nil then
		return
	end

	local unitGroup = self.signUnitList[globalId] or {}
	local isHas = unitGroup[cfgId]

	if isHas then
		return
	end

	local hintAnimeCfg = HintAnime[cfgData.hintAnimeID]

	if hintAnimeCfg == nil then
		return
	end

	local createInfo = {}

	createInfo.cfgId = cfgId
	createInfo.funcId = cfgData.mainBodyFuncID
	createInfo.checkBlock = cfgData.checkBlock == 1
	createInfo.skeletonName = cfgData.SocketSkeleton
	createInfo.offset = cfgData.offset

	if cfgData.mainBodyFuncID == nil or cfgData.mainBodyFuncID == 0 then
		createInfo.activeByFuncAction = false
	else
		createInfo.activeByFuncAction = true
	end

	createInfo.isShowInInteractDist = cfgData.isShowInInteractDist == 1
	createInfo.distanceGroup = hintAnimeCfg.distGroup
	createInfo.animeGroup = hintAnimeCfg.animeGroup
	createInfo.prefabPath = hintAnimeCfg.bindingPrefab
	createInfo.interactAnimeGroup = hintAnimeCfg.canInteractAnime

	local unit = InteractionSignUnitBase.new(globalId, createInfo)

	if self.signUnitList[globalId] == nil then
		self.signUnitList[globalId] = {}
	end

	self.signUnitList[globalId][cfgId] = unit

	facade:sendMsgToUI(MessageName.UI_ADD_INTERACTION_SIGN, {
		globalId = globalId,
		cfgId = cfgId,
		unitData = unit
	})
end

function InteractionSignSystem:isInteractSignLogicallyActive(context, cfgId)
	if context == nil or cfgId == nil then
		return false
	end

	local hintEventState = context.hintEventStates and context.hintEventStates[cfgId]

	if hintEventState ~= nil then
		return hintEventState
	end

	if self._defaultActiveConfigSet[cfgId] then
		return true
	end

	return context.dynamicConfigIds ~= nil and context.dynamicConfigIds[cfgId] == true
end

function InteractionSignSystem:refreshInteractSignPresentation(globalId, cfgId, cfgData)
	if globalId == nil or cfgId == nil then
		return
	end

	local context = self._entityContexts[globalId]
	local logicalActive = self:isInteractSignLogicallyActive(context, cfgId)
	local inRange = context ~= nil and context.inRangeConfigIds[cfgId] == true

	if logicalActive and inRange then
		self:addInteractSign(globalId, cfgId, cfgData)
	else
		self:removeOneInteractSign(globalId, cfgId)
	end
end

function InteractionSignSystem:setHintEventState(globalId, cfgId, cfgData, isActive)
	if globalId == nil or cfgId == nil then
		return
	end

	local context = self._entityContexts[globalId]

	if context == nil or context.configIdSet[cfgId] ~= true then
		return
	end

	context.hintEventStates = context.hintEventStates or {}
	context.hintEventStates[cfgId] = isActive == true

	self:refreshInteractSignPresentation(globalId, cfgId, cfgData)
end

function InteractionSignSystem:removeInteractSignByGlobalId(globalId)
	if globalId == nil then
		return
	end

	local unit = self.signUnitList[globalId]

	if unit then
		self.signUnitList[globalId] = nil

		facade:sendMsgToUI(MessageName.UI_REMOVE_INTERACTION_SIGN, {
			globalId = globalId
		})
	end
end

function InteractionSignSystem:removeOneInteractSign(globalId, cfgId)
	if globalId == nil or cfgId == nil then
		return
	end

	local unitGroup = self.signUnitList[globalId]

	if unitGroup and unitGroup[cfgId] then
		unitGroup[cfgId] = nil

		if next(unitGroup) == nil then
			self.signUnitList[globalId] = nil
		end

		facade:sendMsgToUI(MessageName.UI_REMOVE_INTERACTION_SIGN, {
			globalId = globalId,
			cfgId = cfgId
		})
	end
end

function InteractionSignSystem.checkTableId(cfgIds, checkData)
	if cfgIds == nil or cfgIds[1] == nil then
		return true
	end

	if checkData == nil then
		return false
	end

	for _, val in ipairs(cfgIds) do
		if val == checkData then
			return true
		end
	end

	return false
end

function InteractionSignSystem.checkEntityType(cfgEntityType, ent)
	if ent == nil then
		return false
	end

	cfgEntityType = InteractionSignSystem.normalizeMainBodyType(cfgEntityType)

	if cfgEntityType == EMPTY_MAIN_BODY_TYPE then
		return true
	end

	if cfgEntityType == InteractionSignSystem.MAIN_BODY_TYPE.ACTOR then
		return ent.getPosition ~= nil
	elseif cfgEntityType == InteractionSignSystem.MAIN_BODY_TYPE.STATIC then
		return ent.staticId ~= nil
	elseif cfgEntityType == InteractionSignSystem.MAIN_BODY_TYPE.NPC then
		return ent.actorType == Const.ACTOR_TYPE_PUPPET
	elseif cfgEntityType == InteractionSignSystem.MAIN_BODY_TYPE.ENVOBJ then
		return ent.actorType == Const.ACTOR_TYPE_ENVOBJ
	elseif cfgEntityType == InteractionSignSystem.MAIN_BODY_TYPE.CHEST then
		return ent.actorType == Const.ACTOR_TYPE_INTERACTOR and ent.chestType ~= nil
	elseif cfgEntityType == InteractionSignSystem.MAIN_BODY_TYPE.INTERACTOR then
		return ent.actorType == Const.ACTOR_TYPE_INTERACTOR
	end

	return false
end

function InteractionSignSystem.checkEntity(mainBodyType, mainBodyID, ent)
	if ent == nil then
		return false
	end

	mainBodyType = InteractionSignSystem.normalizeMainBodyType(mainBodyType)

	if mainBodyType == InteractionSignSystem.MAIN_BODY_TYPE.STATIC then
		return InteractionSignSystem.checkEntityType(mainBodyType, ent) and InteractionSignSystem.checkTableId(mainBodyID, ent.staticId)
	end

	return InteractionSignSystem.checkEntityType(mainBodyType, ent) and InteractionSignSystem.checkTableId(mainBodyID, ent.templateId)
end

function InteractionSignSystem:refreshVisible()
	self._signVisible = Utils.tableIsEmptyOrNil(self.hideFlags)
end

function InteractionSignSystem:getSignVisible()
	return self._signVisible
end

function InteractionSignSystem:onDynamicInteractionRefresh(info)
	if info == nil or info.ent == nil then
		return
	end

	self:refreshEntityDynamicInteractionSigns(info.ent)
end

function InteractionSignSystem:_getHintStateCandidateIds(entityType, entityId, funcId)
	local candidateIds = {}
	local uniqueSet = {}
	local normalizedType = InteractionSignSystem.normalizeMainBodyType(entityType)
	local hasEntityId = entityId ~= nil and entityId > 0

	if normalizedType ~= EMPTY_MAIN_BODY_TYPE then
		local typeBucket = self._configIndex[normalizedType]

		self:appendUniqueConfigIds(candidateIds, uniqueSet, typeBucket and typeBucket.all)

		local wildcardTypeBucket = self._configIndex[EMPTY_MAIN_BODY_TYPE]

		self:appendUniqueConfigIds(candidateIds, uniqueSet, wildcardTypeBucket and wildcardTypeBucket.all)
	elseif hasEntityId then
		for _, bucket in pairs(self._configIndex) do
			self:appendUniqueConfigIds(candidateIds, uniqueSet, bucket.wildcard)
			self:appendUniqueConfigIds(candidateIds, uniqueSet, bucket.byId[entityId])
		end
	else
		self:appendUniqueConfigIds(candidateIds, uniqueSet, self._allConfigIds)
	end

	local hasFuncId = funcId ~= nil and funcId > 0

	if hasFuncId then
		local filteredIds = {}

		for _, cfgId in ipairs(candidateIds) do
			local cfgFuncId = HintAnimeBook[cfgId].mainBodyFuncID

			if cfgFuncId == nil or cfgFuncId == 0 or cfgFuncId == funcId then
				filteredIds[#filteredIds + 1] = cfgId
			end
		end

		candidateIds = filteredIds
	end

	table.sort(candidateIds)

	return candidateIds
end

function InteractionSignSystem:onHintAnimeStateChange(args)
	if args == nil then
		return
	end

	local entityType = args[1]
	local entityId = args[2]
	local hintAnimeBookId = args[3]
	local funcId = args[4]
	local isActive = args[5] == 1

	if hintAnimeBookId and hintAnimeBookId > 0 then
		local cfgData = HintAnimeBook[hintAnimeBookId]

		if cfgData == nil then
			return
		end

		self:tryActiveSignForEntities(hintAnimeBookId, cfgData, entityType, entityId, funcId, isActive)
	else
		for _, cfgId in ipairs(self:_getHintStateCandidateIds(entityType, entityId, funcId)) do
			self:tryActiveSignForEntities(cfgId, HintAnimeBook[cfgId], entityType, entityId, funcId, isActive)
		end
	end
end

function InteractionSignSystem:setSignVisible(key, isShow)
	if isShow then
		self.hideFlags[key] = nil
	else
		self.hideFlags[key] = true
	end

	self:refreshVisible()
end

function InteractionSignSystem:tryActiveSignForEntities(cfgId, cfg, entityType, entityId, funcId, isActive)
	local res, retType, retIds, retFuncId = InteractionSignSystem.tryGetMixedArgs(cfg, entityType, entityId, funcId)

	if res == true then
		for globalId, context in pairs(self._entityContexts) do
			local ent = pg.getEntity(context.entityId)

			if ent and ent.getGlobalId and ent:getGlobalId() == globalId and context.configIdSet[cfgId] and InteractionSignSystem.checkEntity(retType, retIds, ent) and (retFuncId == 0 or retFuncId == nil or isActive == false or self:entityHasFuncId(ent, retFuncId)) then
				self:changeInteractSign(globalId, cfgId, cfg, isActive)
			end
		end
	end
end

function InteractionSignSystem:changeInteractSign(globalId, cfgId, cfgData, isActive)
	local context = self._entityContexts[globalId]
	local ent = context and pg.getEntity(context.entityId)

	if ent then
		self:refreshEntityDistanceState(ent, context)
	end

	self:setHintEventState(globalId, cfgId, cfgData, isActive)
end

function InteractionSignSystem.tryGetMixedArgs(cfg, entityType, entityId, funcId)
	local retType
	local cfgEntityType = InteractionSignSystem.normalizeMainBodyType(cfg.mainBodyType)
	local eventEntityType = InteractionSignSystem.normalizeMainBodyType(entityType)

	if cfgEntityType == EMPTY_MAIN_BODY_TYPE then
		retType = eventEntityType
	elseif eventEntityType == EMPTY_MAIN_BODY_TYPE then
		retType = cfgEntityType
	elseif eventEntityType == cfgEntityType then
		retType = eventEntityType
	else
		return false
	end

	local cfgIds = cfg.mainBodyID
	local retIds
	local hasCfgIds = cfgIds and #cfgIds > 0
	local hasId = entityId and entityId > 0

	if hasCfgIds == true and hasId == true then
		local isFind = false

		for _, idA in ipairs(cfgIds) do
			if idA == entityId then
				isFind = true

				break
			end
		end

		if isFind == false then
			return false
		end

		retIds = {
			entityId
		}
	elseif hasCfgIds == true then
		retIds = cfgIds
	elseif hasId == true then
		retIds = {
			entityId
		}
	else
		retIds = {}
	end

	local hasCfgFuncId = cfg.mainBodyFuncID and cfg.mainBodyFuncID > 0
	local hasFuncId = funcId and funcId > 0
	local retFuncId

	if hasCfgFuncId and hasFuncId then
		if cfg.mainBodyFuncID == funcId then
			retFuncId = funcId
		else
			return false
		end
	elseif hasCfgFuncId == true then
		retFuncId = cfg.mainBodyFuncID
	else
		retFuncId = funcId
	end

	return true, retType, retIds, retFuncId
end

return InteractionSignSystem
