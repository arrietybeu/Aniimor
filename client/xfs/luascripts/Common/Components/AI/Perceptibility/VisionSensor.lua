-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Components\\AI\\Perceptibility\\VisionSensor.lua

local Class = require("Core.Framework.Class")
local AiConst = require("Common.Const.AiConst")
local PerceptibilityConst = require("Common.Const.PerceptibilityConst")
local Const = require("Common.Const.Const")
local AIUtils = require("Common.Utils.AIUtils")
local VisionAreaTemplateCache = require("Common.AI.VisionAreaTemplateCache")
local CallbackHandler = require("Core.Common.CallbackHandler")
local Utils = require("Common.Utils.Utils")
local PuppetPerceptGroupDefineData = require("Data.puppet_percept_group_define_data")
local puppetVisualAreaData = require("Data.puppet_visual_range_data")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local TablePool = require("Common.Container.TablePool")
local ListPool = require("Common.Container.ListPool")
local AttributeConst = require("Common.Const.AttributeConst")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local pairs = pairs
local table_clear = table.clear
local VisionSensor = Class.LiteClass("VisionSensor")
local VISION_CLEN_USR_TYPE_MAP = {
	[Const.CLEN_USR_TYPE_PLAYER] = true,
	[Const.CLEN_USR_TYPE_BOT_PLAYER] = true
}

function VisionSensor:ctor(entity)
	self.ent = entity
	self.groupId = nil
	self.groupVPName = PerceptibilityConst.PropertyName.visionAreaDefault
	self.groupData = AiConst.DefaultNullTable
	self.attenuationMultiple = 1
	self.perceivedMap = {}
	self.perceivedStateMap = {}
	self.perceivedFilterMap = {}
	self.VP_visionArea = {}
	self.visualPerceivedMap = {}
	self.VP_maxVisionDistance = 0
	self.otherPerceptibilityMap = {}
	self.currentOtherPerceivedMap = {}
	self.OP_addNearbyTimerId = nil
	self.maxPerceivedActorId = 0
	self.maxPerceivedValue = 0
	self.maxPerceivePercent = 0
	self.tickAllow = false
	self.tickCounter = 0
	self.tickInterval = 2
end

function VisionSensor:destroy()
	self:clearVisualPerceptibility()
	self:clearOtherPerceptibility()
	self:removeTickTimer()

	self.ent = nil
end

function VisionSensor:init(groupId)
	self:setPerceptibilityGroupDataId(groupId)
	table_clear(self.perceivedMap)
	table_clear(self.perceivedFilterMap)
	self:clearVisualPerceptibility()
	self:clearOtherPerceptibility()
	self:refreshVisualPerceptibilityGroup()
end

function VisionSensor:isValid()
	return self.groupData ~= nil
end

function VisionSensor:refreshSensor()
	local agentRootState = AIUtils.getAIRootState(self.ent)

	if not PerceptibilityConst.DontNeedClearAllPerceptibilityOnAgentRootState[agentRootState] then
		self:clearAllPerceptibility()
	end

	if PerceptibilityConst.NeedUpdatePerceptibilityOnAgentRootState[agentRootState] and not self.ent:checkPerceptibilityIsPause() then
		self:addTickTimer()
	else
		self:removeTickTimer()
	end
end

function VisionSensor:addTickTimer()
	if not AIUtils.checkHasPerceptibility(self.ent) then
		self:removeTickTimer()

		return
	end

	self.tickAllow = true
	self.tickCounter = 0
end

function VisionSensor:removeTickTimer()
	self.tickAllow = false
end

function VisionSensor:updateVisionByAI()
	if not self.tickAllow then
		return
	end

	self.tickCounter = self.tickCounter + 1

	if self.tickCounter >= self.tickInterval then
		self.tickCounter = self.tickCounter - self.tickInterval

		self:updateVision()
	end
end

function VisionSensor:updateVision()
	if not self:checkPerceptibilityEnable() then
		return
	end

	if self.ent:isDead() then
		self:clearAllPerceptibility()

		return
	end

	if CharacterStateConst.isMimicryState(self.ent.characterState) and AIUtils.checkMimicryBlockPercept(self.ent) then
		self:clearAllPerceptibility()

		return
	end

	self:resetPerceivedMap()
	self:updateVisualPerceivedMap()
	self:updateOtherPerceivedMap()
	self:refreshMaxPerceivedValue()
	self.ent:onPerceptibilityUpdate()
end

function VisionSensor:clearAllPerceptibility()
	self:clearVisualPerceptibility()
	self:clearOtherPerceptibility()
	self.ent:onClearAllPerceptibility()
end

function VisionSensor:resetPerceivedMap()
	for actorId, _ in pairs(self.perceivedMap) do
		self.perceivedMap[actorId] = 0
	end

	for actorId, _ in pairs(self.perceivedFilterMap) do
		self.perceivedFilterMap[actorId] = nil
	end

	self:setMaxPerceivedValue(0, 0)
end

function VisionSensor:refreshVisualPerceptibilityGroup()
	if not Utils.checkIsAuthorityMaster(self.ent) then
		return
	end

	self.VP_visionArea = AiConst.DefaultNullTable
	self.VP_maxVisionDistance = 0

	if not self:isValid() then
		return
	end

	local vpGroupName = self.groupVPName
	local visionAreaList = self:getPerceptibilityGroupDataProperty(vpGroupName) or AiConst.DefaultNullTable
	local cachedGroup = VisionAreaTemplateCache.getOrCreate(self.groupId, vpGroupName, visionAreaList, puppetVisualAreaData)

	self.VP_visionArea = cachedGroup.visionAreas
	self.VP_maxVisionDistance = cachedGroup.maxVisionDistance
end

function VisionSensor:updateVisualPerceivedMap()
	if not self:isValid() then
		return
	end

	local visualEntityMap = TablePool.getTable()
	local needAttenuationList = ListPool.getList(3)
	local needAddPerceivedList = ListPool.getList(3)

	self:getVisualEntityMap(visualEntityMap)

	for actorId, _ in pairs(self.perceivedMap) do
		if visualEntityMap[actorId] == nil then
			needAttenuationList[#needAttenuationList + 1] = actorId
		end
	end

	for actorId, entity in pairs(visualEntityMap) do
		local visualFlag = self:checkEntityVisionPerceived(actorId, entity)

		if visualFlag then
			needAddPerceivedList[#needAddPerceivedList + 1] = actorId
		else
			needAttenuationList[#needAttenuationList + 1] = actorId
		end
	end

	self:refreshPerceivedStateMap(needAttenuationList, needAddPerceivedList)

	for actorId, _state in pairs(self.perceivedStateMap) do
		if _state == PerceptibilityConst.VisionState.addPerceivedValue then
			local vpVisionAreaMultiple = AIUtils.getVisionPerceivedAreaMultiFunc(self, actorId)

			if vpVisionAreaMultiple then
				if AiConst.AI_DEBUG.PERCEPTIBILITY and (AiConst.AI_DEBUG.ENT_ID == 0 or self.ent.actorId == AiConst.AI_DEBUG.ENT_ID) then
					self.ent.logger:info("checkEntityPerceivedEffectValue: entityActorId=%d,valueChange= %f,environmentMatch= %f,VisionValueChangeRatio = %f, vpVisionAreaMultiple=%f", actorId, self:getPerceptibilityGroupValueChange(), self:getEntityEnvironmentMatch(actorId), self:getVisionValueChangeRatio(actorId), vpVisionAreaMultiple)
				end

				local addV = self.ent:getPerceptibilityGroupValueChange() * self.ent:getEntityEnvironmentMatch(actorId) * self.ent:getVisionValueChangeRatio(actorId) * vpVisionAreaMultiple

				self:addVisualPerceivedValue(actorId, addV)
			else
				self:addVisualPerceivedValue(actorId, 0)
			end
		elseif _state == PerceptibilityConst.VisionState.subPerceivedValue then
			self:addVisualPerceivedValue(actorId, self:getPerceptibilityGroupAttenuation())
		else
			self:addVisualPerceivedValue(actorId, 0)
		end
	end

	ListPool.returnList(needAttenuationList, 3)
	ListPool.returnList(needAddPerceivedList, 3)
	TablePool.returnTable(visualEntityMap)
end

function VisionSensor:refreshPerceivedStateMap(needAttenuationList, needAddPerceivedList)
	for _, actorId in ipairs(needAttenuationList) do
		local curState = self.perceivedStateMap[actorId]

		if not curState or curState == PerceptibilityConst.VisionState.addPerceivedValue then
			self.perceivedStateMap[actorId] = self:getPerceiveStateTime()
		end
	end

	for _, actorId in ipairs(needAddPerceivedList) do
		if not self.perceivedStateMap[actorId] then
			self.perceivedStateMap[actorId] = PerceptibilityConst.VisionState.addPerceivedValue
		end
	end

	for actorId, _state in pairs(self.perceivedStateMap) do
		if _state > PerceptibilityConst.VisionState.subPerceivedValue then
			self.perceivedStateMap[actorId] = math.max(_state - 1, PerceptibilityConst.VisionState.addPerceivedValue)
		end
	end
end

function VisionSensor:addVisualPerceivedValue(actorId, value)
	value = value * self.ent:getFinalTimeScale()

	if value > 0 then
		local targetEntity = pg.getEntityByActorId(actorId)

		targetEntity:updatePerceivedPosition(self.ent.actorId)
	end

	local maxValue = self:getPerceptibilityGroupDataProperty(PerceptibilityConst.PropertyName.valueMax)
	local tVisualPerceivedValue = math.min(self:getVisualPerceivedValue(actorId) + value, maxValue)

	self.visualPerceivedMap[actorId] = tVisualPerceivedValue

	if self:getVisualPerceivedValue(actorId) <= math.epsilon then
		self:removeVisualPerceivedValue(actorId)
	else
		self:updatePerceivedEntity(actorId, tVisualPerceivedValue)
	end
end

function VisionSensor:removeVisualPerceivedValue(actorId)
	self.visualPerceivedMap[actorId] = nil

	self:removePerceivedEntity(actorId)
end

function VisionSensor:clearVisualPerceptibility()
	local index, value = next(self.visualPerceivedMap)

	while index do
		self:removeVisualPerceivedValue(index)

		index, value = next(self.visualPerceivedMap)
	end
end

function VisionSensor:getVisualEntityMap(refTable)
	local candidates = self.ent:getPerceptibilityRangeCandidates()

	for actorId, clenUsrType in pairs(candidates) do
		if VISION_CLEN_USR_TYPE_MAP[clenUsrType] then
			local entity = pg.getEntityByActorId(actorId)

			if entity then
				refTable[actorId] = entity
			end
		end
	end

	return refTable
end

function VisionSensor:getVisualPerceivedMap()
	return self.visualPerceivedMap
end

function VisionSensor:getVisualPerceivedValue(actorId)
	return self.visualPerceivedMap[actorId] or 0
end

function VisionSensor:checkEntityVisionPerceived(entityActorId, entity)
	entity = entity or pg.getEntityByActorId(entityActorId)

	if not entity then
		return false
	end

	if entity == self.ent or entity.id and entity.id == self.ent.id then
		return false
	end

	local result, reason = self:filterVisionEntity(entity)

	if result then
		return true
	else
		self.perceivedFilterMap[entityActorId] = reason or 0

		return false
	end
end

function VisionSensor:filterVisionEntity(entity)
	local result, reason

	result, reason = AIUtils.filterHighVisionPerceivedFunc(self, entity)

	if result == false then
		return false, reason
	end

	result, reason = AIUtils.filterVisionPerceivedIsResponseFunc(self, entity)

	if result == false then
		return false, reason
	end

	result, reason = AIUtils.filterVisionPerceivedSameSpeciesFunc(self, entity)

	if result == false then
		return false, reason
	end

	if reason then
		result, reason = AIUtils.filterVisionPerceivedFriendFunc(self, entity)

		if result == false then
			return false, reason
		end
	end

	result, reason = AIUtils.filterVisionPerceivedAffinityFunc(self, entity)

	if result == false then
		return false, reason
	end

	result, reason = AIUtils.filterVisionPerceivedInvisibleFunc(self, entity)

	if result == false then
		return false, reason
	end

	result, reason = AIUtils.filterVisionPerceivedTallGrassFunc(self, entity)

	if result == false then
		return false, reason
	end

	result, reason = AIUtils.filterDeadEntityFunc(entity)

	if result == false then
		return false, reason
	end

	result, reason = AIUtils.filterVisionPerceivedHighGrassRegionFunc(self, entity)

	if result == false then
		return false, reason
	end

	result, reason = AIUtils.filterVisionPerceivedBeAttachedFunc(self, entity)

	if result == false then
		return false, reason
	end

	result, reason = AIUtils.filterVisionPerceivedSmokeFunc(self, entity)

	if result == false then
		return false, reason
	end

	result, reason = AIUtils.filterPosFunc(self, entity)

	if result == false then
		return false, reason
	end

	result, reason = AIUtils.filterVisionPerceivedRayCastFunc(self, entity)

	if result == false then
		return false, reason
	end

	return true
end

function VisionSensor:clearOtherPerceivedMap()
	for actorId, _ in pairs(self.otherPerceptibilityMap) do
		self:removeOtherPerceivedMap(actorId)
	end
end

function VisionSensor:removeOtherPerceivedMap(actorId)
	self.otherPerceptibilityMap[actorId] = nil

	self:removePerceivedEntity(actorId)
end

function VisionSensor:clearCurrentOtherPerceivedMap()
	table.clear(self.currentOtherPerceivedMap)
end

function VisionSensor:updateOtherPerceivedMap()
	local tOtherPerceptibilityMap = self.otherPerceptibilityMap
	local tCurrentOtherPerceivedMap = self.currentOtherPerceivedMap

	for actorId, v in pairs(tOtherPerceptibilityMap) do
		if tCurrentOtherPerceivedMap[actorId] == nil then
			local tState = self.perceivedStateMap[actorId]

			if tState == PerceptibilityConst.VisionState.subPerceivedValue then
				self:updateOtherPerceptibilityValue(actorId, v + self:getPerceptibilityGroupAttenuation())
			else
				self:updateOtherPerceptibilityValue(actorId, v)
			end
		end
	end

	for actorId, addPerceivedValue in pairs(tCurrentOtherPerceivedMap) do
		local tV = self.otherPerceptibilityMap[actorId] or 0

		self:updateOtherPerceptibilityValue(actorId, tV + addPerceivedValue)
	end

	self:clearCurrentOtherPerceivedMap()
end

function VisionSensor:updateOtherPerceptibilityValue(actorId, otherPerceptibilityValue)
	if otherPerceptibilityValue > 0 then
		local targetEntity = pg.getEntityByActorId(actorId)

		targetEntity:updatePerceivedPosition(self.ent.actorId)
	end

	local maxValue = self:getPerceptibilityGroupDataProperty(PerceptibilityConst.PropertyName.valueMax)
	local currentOtherPerceivedValue = math.min(otherPerceptibilityValue, maxValue)

	if currentOtherPerceivedValue <= math.epsilon then
		self:removeOtherPerceivedMap(actorId)
	else
		self.otherPerceptibilityMap[actorId] = currentOtherPerceivedValue

		self:updatePerceivedEntity(actorId, currentOtherPerceivedValue)
	end
end

function VisionSensor:clearOtherPerceptibility()
	self:clearOtherPerceivedMap()
	self:clearCurrentOtherPerceivedMap()
end

function VisionSensor:addBallComingNearByTimer(delay, entityActorId)
	if not self:checkPerceptibilityEnable() then
		return
	end

	if AIUtils.checkPuppetFriendly(self.ent, entityActorId) or AIUtils.checkPuppetAffinity(self.ent, entityActorId) then
		return
	end

	if self.OP_addNearbyTimerId == nil then
		self.OP_addNearbyTimerId = self.ent:addTimer(delay, CallbackHandler(self, "addBallComingNearbyPerceptibilityCallback", entityActorId))
	end
end

function VisionSensor:addBallComingHitPerceptibility(entityActorId)
	if not self:checkPerceptibilityEnable() then
		return
	end

	if AIUtils.checkPuppetFriendly(self.ent, entityActorId) or AIUtils.checkPuppetAffinity(self.ent, entityActorId) then
		return
	end

	self:removeOnceNearByTimer()
	self:addOncePerceptibility(entityActorId, self:getBallHitAddValue())
end

function VisionSensor:addBallComingNearbyPerceptibilityCallback(entityActorId)
	self:removeOnceNearByTimer()
	self:addOncePerceptibility(entityActorId, self:getBallNearbyAddValue())
end

function VisionSensor:removeOnceNearByTimer()
	if self.OP_addNearbyTimerId ~= nil then
		self.ent:removeTimer(self.OP_addNearbyTimerId)

		self.OP_addNearbyTimerId = nil
	end
end

function VisionSensor:addDeformationTerrorPerceptibility(entityActorId)
	if not self:checkPerceptibilityEnable() then
		return
	end

	self:addOncePerceptibility(entityActorId, self:getDeformationTerrorAddValue(entityActorId))
end

function VisionSensor:addOncePerceptibility(entityActorId, oncePerceptibilityValue)
	local entity = pg.getEntityByActorId(entityActorId)

	if entity ~= nil and not entity:isDead() then
		self.currentOtherPerceivedMap[entityActorId] = oncePerceptibilityValue
	end

	self.perceivedStateMap[entityActorId] = self:getPerceiveStateTime()
end

function VisionSensor:removePerceivedEntity(actorId)
	local tOtherPerceivedMap = self.otherPerceptibilityMap
	local tVisualPerceivedMap = self.visualPerceivedMap

	if tOtherPerceivedMap[actorId] == nil and tVisualPerceivedMap[actorId] == nil then
		local entity = pg.getEntityByActorId(actorId)

		if entity ~= nil and entity.onRemoveResponsePerceptibility then
			entity:onRemoveResponsePerceptibility(self.ent.actorId)
		end

		self.perceivedMap[actorId] = nil
		self.perceivedStateMap[actorId] = nil
	end

	return false
end

function VisionSensor:updatePerceivedEntity(actorId, perceptibilityValue)
	local currentPerceptibilityValue = self.perceivedMap[actorId] or 0
	local maxValue = self:getPerceptibilityGroupDataProperty(PerceptibilityConst.PropertyName.valueMax)

	self.perceivedMap[actorId] = math.max(math.min(currentPerceptibilityValue + perceptibilityValue, maxValue), 0)
end

function VisionSensor:setPerceptibilityGroupDataId(groupDataId)
	if AIUtils.checkHasPerceptibility(self.ent) then
		self.groupId = groupDataId
		self.groupData = groupDataId and PuppetPerceptGroupDefineData[groupDataId]

		if not self.groupData and LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.ent.logger:error("当前Entity的groupId不存在 @zxc", self.ent.id, self.ent.templateId, self.groupId)
		end
	end
end

function VisionSensor:checkPerceptibilityEnable()
	return self.groupId
end

function VisionSensor:getPerceptibilityGroupDataProperty(propertyName)
	return self.groupData[propertyName]
end

function VisionSensor:getPerceptibilityEnvMatch(motionType, envType)
	local groupData = self.groupData

	return groupData and groupData[motionType] and groupData[motionType][envType]
end

function VisionSensor:getPerceptibilityVisionType()
	return self.groupData.visionType or PerceptibilityConst.VisionType.Sight
end

function VisionSensor:getBallNearbyAddValue()
	return self.groupData.ballNearbyAddValue or 0
end

function VisionSensor:getBallHitAddValue()
	return self.groupData.ballHitAddValue or 0
end

function VisionSensor:getPerceptibilityGroupValueChange()
	return self.groupData.valueChange or 0
end

function VisionSensor:getPerceptibilityGroupAttenuation()
	return (self.groupData.attenuation or 0) * self.attenuationMultiple
end

function VisionSensor:setAttenuationMultiple(multiple)
	self.attenuationMultiple = multiple or 1
end

function VisionSensor:getPerceptibilityGroupData()
	return self.groupData
end

function VisionSensor:checkPerceptibilityRayCast()
	return self.groupData.rayCastingSwitch == 1
end

function VisionSensor:checkPerceptibilityInvisible()
	return self.groupData.invisibleSwitch == 1
end

function VisionSensor:checkPerceptibilityTallGrassSwitch()
	return self.groupData.tallGrassSwitch == 1
end

function VisionSensor:getDeformationTerrorAddValue(entityActorId)
	local _, vpVisionAreaIndex = AIUtils.getVisionPerceivedAreaMultiFunc(self, entityActorId)

	if vpVisionAreaIndex then
		local maxValue = self:getPerceptibilityGroupDataProperty(PerceptibilityConst.PropertyName.valueMax)

		return self.VP_visionArea[vpVisionAreaIndex].deformationTerrorFlag * maxValue
	end

	return 0
end

function VisionSensor:getPerceptibilityEnvMatch(motionType, envType)
	local groupData = self:getPerceptibilityGroupData()

	return groupData and groupData[motionType] and groupData[motionType][envType]
end

function VisionSensor:setVPGroupName(vpGroupName)
	if self.groupVPName == vpGroupName then
		return
	end

	self.groupVPName = vpGroupName

	self:refreshVisualPerceptibilityGroup()
end

function VisionSensor:getVisionValueChangeRatio(actorId)
	local entity = pg.getEntityByActorId(actorId)

	if entity.actorCombatAttribute == nil then
		return 1
	end

	return entity.actorCombatAttribute:getAttribRatioValue(AttributeConst.vision_value_change_ratio_v) or 1
end

function VisionSensor:getEntityEnvironmentMatch(actorId)
	local entity = pg.getEntityByActorId(actorId)
	local entityEnvironmentMatch = 1
	local entityPos = entity:getPosition()

	if entityPos == nil or not Utils.isPlayer(entity) then
		return 1
	end

	if entity.checkPRSneak and entity:checkPRSneak() then
		local entityEnvironment = entity:checkPREnvironment()

		entityEnvironmentMatch = self:getPerceptibilityEnvMatch(PerceptibilityConst.PropertyName.playerCrounch, entityEnvironment)
	elseif entity.PR_run and entity:checkPRRun() then
		local entityEnvironment = entity:checkPREnvironment()

		entityEnvironmentMatch = self:getPerceptibilityEnvMatch(PerceptibilityConst.PropertyName.playerRun, entityEnvironment)
	elseif entity.checkPRSprint and entity:checkPRSprint() then
		local entityEnvironment = entity:checkPREnvironment()

		entityEnvironmentMatch = self:getPerceptibilityEnvMatch(PerceptibilityConst.PropertyName.playerSprint, entityEnvironment)
	elseif entity.checkPRIdle and entity:checkPRIdle() then
		local entityEnvironment = entity:checkPREnvironment()

		entityEnvironmentMatch = self:getPerceptibilityEnvMatch(PerceptibilityConst.PropertyName.playerIdle, entityEnvironment)
	end

	return entityEnvironmentMatch or 1
end

function VisionSensor:refreshMaxPerceivedValue()
	local maxPerceivedValue, maxPerceivedActorId = 0, 0

	for actorId, value in pairs(self.perceivedMap) do
		if maxPerceivedValue < value then
			maxPerceivedValue = value
			maxPerceivedActorId = actorId
		end
	end

	self:setMaxPerceivedValue(maxPerceivedActorId, maxPerceivedValue)
end

function VisionSensor:setMaxPerceivedValue(actorId, value)
	self.maxPerceivedValue = value
	self.maxPerceivedActorId = actorId

	if value > 0 then
		local startValue = self:getPerceptibilityGroupDataProperty(PerceptibilityConst.PropertyName.valueShowStart)
		local endValue = self:getPerceptibilityGroupDataProperty(PerceptibilityConst.PropertyName.valueShowEnd)

		self.maxPerceivePercent = math.min(math.max((value - startValue) / (endValue - startValue), 0), 1)
	else
		self.maxPerceivePercent = 0
	end
end

function VisionSensor:getMaxPerceivePercent()
	return self.maxPerceivePercent
end

function VisionSensor:getMaxPerceivedValue()
	return self.maxPerceivedValue
end

function VisionSensor:getMaxPerceivedActorId()
	return self.maxPerceivedActorId
end

function VisionSensor:getPerceiveStateTime()
	local attenuationWaitSecond = self:getPerceptibilityGroupDataProperty(PerceptibilityConst.PropertyName.attenuationWait)

	return attenuationWaitSecond and attenuationWaitSecond / AiConst.PERCEPTIBILITY_INTERVAL or PerceptibilityConst.VisionState.subPerceivedValue
end

return VisionSensor
