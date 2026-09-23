-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Components\\AI\\Perceptibility\\NoImpVisionSensor.lua

local Class = require("Core.Framework.Class")
local puppetVisualAreaData = require("Data.puppet_visual_range_data")
local Utils = require("Common.Utils.Utils")
local AiConst = require("Common.Const.AiConst")
local PerceptibilityConst = require("Common.Const.PerceptibilityConst")
local AIUtils = require("Common.Utils.AIUtils")
local VisionAreaTemplateCache = require("Common.AI.VisionAreaTemplateCache")
local Const = require("Common.Const.Const")
local CallbackHandler = require("Core.Common.CallbackHandler")
local PuppetPerceptGroupDefineData = require("Data.puppet_percept_group_define_data")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local table_clear = table.clear
local table_clearArray = table.clearArray
local NoImpVisionSensor = Class.LiteClass("NoImpVisionSensor")
local NO_IMP_CLEN_USER_TYPE_SEARCH_MAP = {
	[Const.CLEN_USR_TYPE_PLAYER] = Const.SEARCH_USR_TYPE_ACTOR,
	[Const.CLEN_USR_TYPE_PET] = Const.SEARCH_USR_TYPE_ACTOR,
	[Const.CLEN_USR_TYPE_MONSTER] = Const.SEARCH_USR_TYPE_ACTOR,
	[Const.CLEN_USR_TYPE_CREATION] = Const.SEARCH_USR_TYPE_AI_INTERACT,
	[Const.CLEN_USR_TYPE_INTERACTOR] = Const.SEARCH_USR_TYPE_AI_INTERACT,
	[Const.CLEN_USR_TYPE_ENVOBJ] = Const.SEARCH_USR_TYPE_AI_INTERACT
}

function NoImpVisionSensor:ctor(entity)
	self.ent = entity
	self.VP_visionArea = {}
	self.VP_maxVisionDistance = 0
	self.perceivedNoImpMap = {
		[Const.SEARCH_USR_TYPE_ACTOR] = {},
		[Const.SEARCH_USR_TYPE_AI_INTERACT] = {}
	}
	self.perceivedFilterMap = {}
	self.tickTimer = nil
	self.groupId = nil
	self.groupVPName = PerceptibilityConst.PropertyName.visionAreaDefault
	self.groupData = AiConst.DefaultNullTable
	self.tickAllow = false
	self.tickCounter = 0
	self.tickInterval = 5
end

function NoImpVisionSensor:init(groupId)
	self:setPerceptibilityGroupDataId(groupId)
	self:clearNoImpPerceptibility()
	self:refreshNoImpPerceptibilityGroup()
end

function NoImpVisionSensor:destroy()
	self:clearNoImpPerceptibility()
	self:removeTickTimer()

	self.ent = nil
end

function NoImpVisionSensor:isValid()
	return self.groupData ~= nil
end

function NoImpVisionSensor:refreshSensor()
	local agent = self.ent.agent

	if not agent or not self:isValid() then
		return
	end

	local agentRootState = agent:getRootState()

	if PerceptibilityConst.NeedUpdatePerceptibilityOnAgentRootState[agentRootState] and not self.ent:checkPerceptibilityIsPause() and self:isValid() then
		self:addTickTimer()
	else
		self:removeTickTimer()
	end
end

function NoImpVisionSensor:clearNoImpPerceptibility()
	table_clear(self.perceivedNoImpMap[Const.SEARCH_USR_TYPE_ACTOR])
	table_clear(self.perceivedNoImpMap[Const.SEARCH_USR_TYPE_AI_INTERACT])
	table_clear(self.perceivedFilterMap)
end

function NoImpVisionSensor:addTickTimer()
	self.tickAllow = true
	self.tickCounter = 0
end

function NoImpVisionSensor:removeTickTimer()
	self.tickAllow = false
end

function NoImpVisionSensor:refreshNoImpPerceptibilityGroup()
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

function NoImpVisionSensor:updateNoImpVisionByAI()
	if not self.tickAllow then
		return
	end

	self.tickCounter = self.tickCounter + 1

	if self.tickCounter >= self.tickInterval then
		self.tickCounter = self.tickCounter - self.tickInterval

		self:updateNoImpVision()
	end
end

function NoImpVisionSensor:updateNoImpVision()
	if not self:isValid() then
		return
	end

	table_clear(self.perceivedFilterMap)

	local parmonList = self.perceivedNoImpMap[Const.SEARCH_USR_TYPE_ACTOR]

	table_clearArray(parmonList)

	local aiInteractList = self.perceivedNoImpMap[Const.SEARCH_USR_TYPE_AI_INTERACT]

	table_clearArray(aiInteractList)

	local candidates = self.ent:getPerceptibilityRangeCandidates()

	for actorId, clenUsrType in pairs(candidates) do
		local searchUserType = NO_IMP_CLEN_USER_TYPE_SEARCH_MAP[clenUsrType]

		if searchUserType then
			local entity = pg.getEntityByActorId(actorId)

			if entity and (clenUsrType ~= Const.CLEN_USR_TYPE_PET or entity.isSummon) and self:checkEntityNoImpVisionPerceived(actorId, entity) then
				if searchUserType == Const.SEARCH_USR_TYPE_ACTOR then
					parmonList[#parmonList + 1] = actorId
				else
					aiInteractList[#aiInteractList + 1] = actorId
				end
			end
		end
	end

	self.ent:onNoImpPerceptibilityUpdate()
end

function NoImpVisionSensor:checkEntityNoImpVisionPerceived(entityActorId, entity)
	entity = entity or pg.getEntityByActorId(entityActorId)

	if not entity or entity.id == self.id then
		return false
	end

	local result, reason = self:filterNoImpVisionEntity(entity)

	if result then
		return true
	else
		self.perceivedFilterMap[entityActorId] = reason or 0

		return false
	end
end

function NoImpVisionSensor:filterNoImpVisionEntity(entity)
	if Utils.isPeopleNpc(self.ent) then
		return false
	end

	if Utils.isPuppet(self.ent) or Utils.isPet(self.ent) then
		local result, reason

		result, reason = AIUtils.filterHighVisionPerceivedFunc(self, entity)

		if result == false then
			return false, reason
		end

		result, reason = AIUtils.filterNoImpVisionPerceivedIsResponseFunc(self, entity)

		if result == false then
			return false, reason
		end

		result, reason = AIUtils.filterControllingPetPlayer(self, entity)

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

		result, reason = AIUtils.filterPosFuncNoImp(self, entity)

		if result == false then
			return false, reason
		end

		result, reason = AIUtils.filterVisionPerceivedRayCastFunc(self, entity)

		if result == false then
			return false, reason
		end

		return true
	else
		return false
	end
end

function NoImpVisionSensor:getPerceptibilityGroupDataProperty(propertyName)
	return self.groupData[propertyName]
end

function NoImpVisionSensor:setPerceptibilityGroupDataId(groupDataId)
	self.groupId = groupDataId
	self.groupData = groupDataId and PuppetPerceptGroupDefineData[groupDataId]

	if not self.groupData and LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.ent.logger:error("当前Entity的groupId不存在 @zxc", self.ent.id, self.ent.templateId, self.groupId)
	end
end

function NoImpVisionSensor:setVPGroupName(vpGroupName)
	if self.groupVPName == vpGroupName then
		return
	end

	self.groupVPName = vpGroupName

	self:refreshNoImpPerceptibilityGroup()
end

function NoImpVisionSensor:checkPerceptibilityRayCast()
	return self.groupData.rayCastingSwitch == 1
end

function NoImpVisionSensor:checkPerceptibilityInvisible()
	return self.groupData.invisibleSwitch == 1
end

function NoImpVisionSensor:checkPerceptibilityTallGrassSwitch()
	return self.groupData.tallGrassSwitch == 1
end

return NoImpVisionSensor
