-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Ability\\ReboundDashControl.lua

local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local CombatActionTool = require("Common.Ability.CombatActionTool")
local Utils = require("Common.Utils.Utils")
local AbilityConst = require("Common.Const.AbilityConst")
local ClientDebugUtils = require("Utils.ClientDebugUtils")
local ClientSwitch = require("Common.ClientSwitch")
local ClientConst = require("Const.ClientConst")
local EModelUtils = require("Entities.Utils.EModelUtils")
local Vector3 = Vector3
local Quaternion = Quaternion
local pg = pg
local cacheActorIds = {}
local ReboundDashControl = Class.LiteClass("ReboundDashControl")

function ReboundDashControl:ctor(owner)
	self.owner = owner
end

function ReboundDashControl:getClosestTarget(overridePos)
	local actionData = self.owner.reboundDashData.actionData
	local searchList = {}

	self:updateSearchList(actionData.filterEntityType, actionData.filterTemplateId, nil, searchList)
	self:updateSearchList(actionData.filterEntityType2, actionData.filterTemplateId2, nil, searchList)

	if actionData.isReboundPlayerPet then
		self:updateSearchList("PlayerPet", nil, nil, searchList)
	end

	table.sort(searchList, ReboundDashControl.cmpDis)

	local isNotNearby = self.lastReboundActorId ~= 0 and actionData.isNotNearby or false
	local entInfo = isNotNearby and (searchList[3] or searchList[2] or searchList[1]) or searchList[1]

	return entInfo and entInfo[2]
end

function ReboundDashControl:updateSearchList(filterEntityType, filterTemplateId, overridePos, searchList)
	local searchType = Const.SEARCH_USR_TYPE_ACTOR
	local actionData = self.owner.reboundDashData.actionData

	if filterEntityType then
		if filterEntityType == "Creation" then
			searchType = Const.SEARCH_USR_TYPE_CREATION
		elseif filterEntityType == "Puppet" then
			searchType = Const.SEARCH_USR_TYPE_MONSTER
		elseif filterEntityType == "EnvObject" then
			searchType = Const.SEARCH_USR_TYPE_ENVOBJ
		elseif filterEntityType == "PlayerPet" then
			searchType = Const.SEARCH_USR_TYPE_PLAYER + Const.SEARCH_USR_TYPE_PET
		end
	end

	local relation = actionData.filterRelation or Const.WORLD_PAIRS_CAMP_ENEMY
	local actorCnt = self.owner:entitiesInRangeWithTable(self.searchRadius, searchType, 100, cacheActorIds)
	local selfPos = overridePos or self.owner:getPosition()

	for i = 1, actorCnt do
		local ent = pg.getEntityByActorId(cacheActorIds[i])
		local checkCreationEnable = true

		if Utils.isCreation(ent) then
			checkCreationEnable = ToBool(ent:getConfigData().enableReboundDash)
		end

		local heightOffset = ent:getPosition().y - selfPos.y
		local inHeightRange = heightOffset < actionData.searchHeightUp and heightOffset > -actionData.searchHeightDown

		if checkCreationEnable and inHeightRange and Utils.checkValidLock(ent, true, true, true) and not Utils.isNpc(ent) and Utils.checkRelation(self.owner, ent, relation) and (not filterTemplateId or ent.templateId == filterTemplateId) and ent.actorId ~= self.lastReboundActorId and (self.actorSearchMap[ent.actorId] or 0) < self.actorMaxSearchCount then
			local sqrDis = Vector3.SqrDistance(selfPos, ent:getPosition())

			table.insert(searchList, {
				sqrDis,
				ent
			})
		end
	end
end

function ReboundDashControl.cmpDis(a, b)
	return a[1] < b[1]
end

function ReboundDashControl:enter()
	self.searchRadius = self.owner.reboundDashData.actionData.searchRadius
	self.moveSpeed = self.owner.reboundDashData.actionData.initSpeed
	self.acceleration = self.owner.reboundDashData.actionData.acceleration
	self.minSpeed = self.owner.reboundDashData.actionData.minSpeed
	self.maxSpeed = self.owner.reboundDashData.actionData.maxSpeed
	self.duration = self.owner.reboundDashData.actionData.duration
	self.radius = self.owner.reboundDashData.actionData.radius * self.owner.curModelScale
	self.height = self.owner.reboundDashData.actionData.height * self.owner.curModelScale
	self.maxCount = self.owner.reboundDashData.actionData.maxCount
	self.curCnt = 0
	self.lastHitActorId = 0
	self.lastReboundActorId = 0
	self.lastHitTime = 0
	self.reboundCount = 0
	self.isEnd = false
	self.actorSearchMap = {}
	self.actorMaxSearchCount = self.owner.reboundDashData.actionData.actorMaxSearchCount

	local targetEnt = pg.getEntityByActorId(CombatActionTool.parseActorId(self.owner.reboundDashData.combatContext, AbilityConst.COMBAT_TARGET_TYPE_TARGET))

	if targetEnt == nil then
		targetEnt = self:getClosestTarget()
	end

	if targetEnt == nil then
		self.moveDir = Quaternion.MulVec3(self.owner:getRotation(), Vector3.forward)
	else
		self.actorSearchMap[targetEnt.actorId] = 1
		self.moveDir = targetEnt:getPosition() - self.owner:getPosition()
		self.moveDir.y = 0

		Vector3.SetNormalize(self.moveDir)
	end

	self.waitDuration = nil
	self.lastReboundActorId = targetEnt and targetEnt.actorId or 0

	if self.owner.reboundDashData.actionData.waitTime == 0 then
		EModelUtils.setAgentRotation(self.owner, Quaternion.LookRotation(self.moveDir, Vector3.up), true)
	else
		self.waitDuration = self.owner.reboundDashData.actionData.waitTime
	end

	self.owner.eModel:SetComputeGravity(Const.COMPONENT_MOTION, ClientConst.GravityMask.SKill, true)
end

function ReboundDashControl:tick(deltaSeconds)
	if self.waitDuration then
		self.waitDuration = self.waitDuration - deltaSeconds

		if self.waitDuration <= 0 then
			self.waitDuration = nil

			EModelUtils.setAgentRotation(self.owner, Quaternion.LookRotation(self.moveDir, Vector3.up), true)
		else
			return
		end
	end

	if self.isEnd or not self.owner.reboundDashData then
		return
	end

	local isEnd = false

	if self.duration - deltaSeconds < 0 then
		deltaSeconds = self.duration
		isEnd = true
	end

	self.duration = self.duration - deltaSeconds

	local nextSpeed = self.moveSpeed + self.acceleration * deltaSeconds

	nextSpeed = math.clamp(nextSpeed, self.minSpeed, self.maxSpeed)

	local nextPos = self.owner:getPosition() + self.moveDir * ((self.moveSpeed + nextSpeed) * 0.5 * deltaSeconds)
	local _, castPos = pg.global.physicsMgr:ReboundDashCast(self.radius, self.height, self.owner:getPosition(), nextPos, self.owner.eModel, function(hitActorId, distance, hitPos)
		return self:onHitActor(hitActorId, distance, hitPos)
	end)

	self.moveSpeed = nextSpeed

	local offset = castPos - self.owner:getPosition()

	if self.isEnd or self.duration <= 0 then
		EModelUtils.clearDisplacementVelocitySource(self.owner, Const.DisplacementVelocitySource.ReboundDash)
		EModelUtils.setMotionDisplacementOffset(self.owner, offset, true)
	else
		EModelUtils.setDisplacementVelocitySourceByOffset(self.owner, Const.DisplacementVelocitySource.ReboundDash, offset, deltaSeconds, true, false)
	end

	if ClientSwitch.EnableDrawAbilityGizmo then
		ClientDebugUtils.drawDebugMesh(castPos + Vector3.up * self.height * 0.5, nil, AbilityConst.LX_GEOMETRY_TYPE_CAPSULE, {
			self.radius,
			self.height
		}, 0.5)
	end

	if not self.isEnd and self.duration <= 0 then
		self:onEnd()
	end
end

function ReboundDashControl:onEnd()
	if self.isEnd then
		return
	end

	EModelUtils.clearDisplacementVelocitySource(self.owner, Const.DisplacementVelocitySource.ReboundDash)

	self.isEnd = true

	self.owner:serverMsgNoGC("RPC_CS_ReboundDashEnd")
	self.owner:endReboundDash()
	self.owner.eModel:ClearGravityMask(Const.COMPONENT_MOTION, ClientConst.GravityMask.SKill, false)
end

function ReboundDashControl:onHitActor(hitActorId, distance, hitPos)
	if hitActorId == self.lastHitActorId and self.owner:getGameTime() - self.lastHitTime < 0.5 then
		return false
	end

	local hitEnt = pg.getEntityByActorId(hitActorId)
	local actionData = self.owner.reboundDashData.actionData
	local hitActorRelation = actionData.filterRelation or Const.WORLD_PAIRS_CAMP_ENEMY

	if Utils.checkRelation(self.owner, hitEnt, hitActorRelation) then
		self.lastHitActorId = hitActorId
		self.lastReboundActorId = self.lastHitActorId

		self.owner:serverMsgNoGC("RPC_CS_ReboundDashHitActor", hitActorId, Vector3.getRawTable(hitPos))
		self.owner:onReboundDashHitActor(hitActorId, hitPos)
	end

	self.owner:onMovementHitBlocked(hitActorId)

	local filterRelation = actionData.filterRelation or Const.WORLD_PAIRS_CAMP_ENEMY

	if not Utils.checkRelation(self.owner, hitEnt, filterRelation) then
		return false
	end

	if self.reboundCount >= self.maxCount then
		self:onEnd()

		return true
	end

	local nextPos = self.owner:getPosition() + self.moveDir * distance
	local nextClosestEnt = self:getClosestTarget(nextPos)

	if not nextClosestEnt then
		self:onEnd()

		return true
	end

	self.lastReboundActorId = nextClosestEnt.actorId
	self.actorSearchMap[nextClosestEnt.actorId] = (self.actorSearchMap[nextClosestEnt.actorId] or 0) + 1
	self.reboundCount = self.reboundCount + 1
	self.moveSpeed = self.owner.reboundDashData.actionData.reboundInitSpeed
	self.acceleration = self.owner.reboundDashData.actionData.reboundAcceleration
	self.minSpeed = self.owner.reboundDashData.actionData.reboundMinSpeed
	self.maxSpeed = self.owner.reboundDashData.actionData.reboundMaxSpeed
	self.duration = self.owner.reboundDashData.actionData.reboundDuration
	self.curCnt = 0
	self.lastHitTime = self.owner:getGameTime()
	self.moveDir = nextClosestEnt:getPosition() - nextPos
	self.moveDir.y = 0

	Vector3.SetNormalize(self.moveDir)
	EModelUtils.setAgentRotation(self.owner, Quaternion.LookRotation(self.moveDir, Vector3.up), true)

	return true
end

return ReboundDashControl
