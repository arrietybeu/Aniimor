-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientLookAtComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local ClientUtils = require("Utils.ClientUtils")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local CallbackHandler = require("Core.Common.CallbackHandler")
local PetData = require("Data.pet_data")
local LuaCSharpArr = require("Utils.LuaCSharpArr")
local Const = require("Common.Const.Const")
local sysConfigData = require("Data.sys_config_data")
local Utils = require("Common.Utils.Utils")
local AbilityConst = require("Common.Const.AbilityConst")
local LookatPriorityData = require("Data.lookat_priority_data")
local SysConfigData = require("Data.sys_config_data")
local anim_tag_lookat_priority_data = require("Data.anim_tag_lookat_priority_data")
local anim_state_lookat_priority_data = require("Data.anim_state_lookat_priority_data")
local SearchEntTypes = 334
local IKTYPE_BLINK = 6
local ClientLookAtComponent = class.Component("ClientLookAtComponent")

function ClientLookAtComponent:ctor()
	self.lookAtEntities = LuaCSharpArr.New(10)
	self.lookAtEntitiesPriority = LuaCSharpArr.New(10)

	if Utils.isPlayer(self) then
		self.lookAtSourceRole = "Player"
	elseif Utils.isPet(self) then
		self.lookAtSourceRole = "Pet"
	elseif Utils.isPuppet(self) then
		self.lookAtSourceRole = "Monster"
	elseif Utils.isVirtualEntity(self) then
		self.lookAtSourceRole = "Player"
	end

	self.lookAtFields = {}
	self.lookAtFields.tick = 0
	self.lookAtFields.interval = 2
	self.disableLookAtForBuff = false
end

function ClientLookAtComponent:EVENT_OnAnimatorReady()
	if self.eModel == nil then
		return
	end

	self:addEModelComponent(Const.COMPONENT_INDEX_IK)

	local lookAtComponent = self.eModel.ikLookAtComponent

	if NotNil(lookAtComponent) then
		lookAtComponent.lookAtEntities = self.lookAtEntities:GetCSharpAccess()
		lookAtComponent.lookAtEntitiesPriority = self.lookAtEntitiesPriority:GetCSharpAccess()
		lookAtComponent.directionTargetPriority = LookatPriorityData[self.lookAtSourceRole].Direction or 0

		local isNetEnt = self.actorType == Const.ACTOR_TYPE_PLAYER and not self.isMainPlayer or self.actorType == Const.ACTOR_TYPE_PET and not self.isMainPet

		self.lookAtFields.abandon = isNetEnt or not self:getSceneEntityCfg("canLookAt") or Utils.isNpc(self)

		if self.lookAtFields.abandon then
			self.eModel:EnableRigComponent(Const.COMPONENT_INDEX_IK, lookAtComponent, false)

			self.lookAtFields.interval = 36000
		else
			self:refreshLookAtIKState()
		end
	end

	self.lookAtFields.abandonBlink = self:getSceneEntityCfg("abandonBlink") or false

	self.eModel:EnableIK(Const.COMPONENT_INDEX_IK, IKTYPE_BLINK, not self.lookAtFields.abandonBlink)
	self.eModel:AutoBlink(Const.COMPONENT_IDX_PLAYABLE, not self.lookAtFields.abandonBlink)
	self.eModel:SetupAutoBlink(Const.COMPONENT_IDX_PLAYABLE, 3, 5)
end

function ClientLookAtComponent:tick(deltaTime)
	if not self:canTickLookAt() then
		return
	end

	self.lookAtFields.tick = self.lookAtFields.tick + deltaTime

	if self.lookAtFields.tick < self.lookAtFields.interval then
		return
	end

	self.lookAtFields.tick = 0

	local count = self:entitiesInRangeWithTable(SysConfigData.defaultLookAtDist, SearchEntTypes, 10, self.lookAtEntities)

	for i = count + 1, #self.lookAtEntities do
		self.lookAtEntities[i] = nil
	end

	local actorId, entity

	for i = 1, #self.lookAtEntities do
		actorId = self.lookAtEntities[i]
		entity = pg.getEntityByActorId(actorId)

		if not entity:canBeLookAt() then
			self.lookAtEntitiesPriority[i] = 0
		else
			local basePriority, tagPriority, statePriority = self:getLookAtInfo(entity)

			self.lookAtEntitiesPriority[i] = math.max(basePriority, tagPriority, statePriority)
		end
	end

	for i = count + 1, #self.lookAtEntitiesPriority do
		self.lookAtEntitiesPriority[i] = nil
	end
end

function ClientLookAtComponent:canTickLookAt()
	if self.overrideLookAtEntity ~= nil then
		return false
	end

	if self.isInDialogue then
		return false
	end

	if pg.game.dialogue:isPlayingDialogueGraph() then
		return false
	end

	return true
end

function ClientLookAtComponent:clearTickLookAtInfo()
	for i = 1, #self.lookAtEntities do
		self.lookAtEntities[i] = nil
	end

	for i = 1, #self.lookAtEntitiesPriority do
		self.lookAtEntitiesPriority[i] = nil
	end
end

function ClientLookAtComponent:getLookAtRole(entity)
	if Utils.isPuppet(entity) then
		if Utils.isNpc(entity) then
			return ClientConst.LookAtTypeName.NpcStr
		else
			return ClientConst.LookAtTypeName.MonsterStr
		end
	elseif Utils.isPlayer(entity) then
		if self.master == entity then
			return ClientConst.LookAtTypeName.OwnPlayerStr
		else
			return ClientConst.LookAtTypeName.OtherPlayerStr
		end
	elseif Utils.isPet(entity) then
		if self == entity.master then
			return ClientConst.LookAtTypeName.OwnPetStr
		else
			return ClientConst.LookAtTypeName.OtherPetStr
		end
	elseif Utils.isEnvObj(entity) then
		return ClientConst.LookAtTypeName.EnvObjStr
	end

	return nil
end

function ClientLookAtComponent:getLookAtInfo(entity)
	local otherRole = self:getLookAtRole(entity)
	local basePriority = LookatPriorityData[self.lookAtSourceRole][otherRole] or 0
	local tagPriority = 0

	if entity.animTagMasks then
		local tagPriorityData = anim_tag_lookat_priority_data[otherRole] or {}
		local tagArray = tagPriorityData[1]
		local priorityArray = tagPriorityData[2]

		if tagArray then
			local index = entity.animTagMasks:GetLuaIndex(tagArray[1] or 0, tagArray[2] or 0, tagArray[3] or 0, tagArray[4] or 0)

			tagPriority = priorityArray[index] or 0
		end
	end

	if entity.fullBodyAnimTagMasks then
		local tagPriorityData = anim_tag_lookat_priority_data[otherRole] or {}
		local tagArray = tagPriorityData[1]
		local priorityArray = tagPriorityData[2]

		if tagArray then
			local index = entity.fullBodyAnimTagMasks:GetLuaIndex(tagArray[1] or 0, tagArray[2] or 0, tagArray[3] or 0, tagArray[4] or 0)

			tagPriority = math.max(priorityArray[index] or 0, tagPriority)
		end
	end

	local stateData = anim_state_lookat_priority_data[otherRole]
	local statePriority = 0

	if stateData then
		statePriority = stateData[entity.animKey] or 0
		statePriority = math.max(stateData[entity.fullBodyAnimKey] or 0, statePriority)
	end

	return basePriority, tagPriority, statePriority
end

function ClientLookAtComponent:destroy()
	self.lookAtEntities:DestroyCSharpAccess()
	self.lookAtEntitiesPriority:DestroyCSharpAccess()
end

function ClientLookAtComponent:EVENT_LoseControlled()
	local lookAtComponent = self.eModel.ikLookAtComponent

	if lookAtComponent then
		lookAtComponent.enableCameraLookAt = false
	end
end

function ClientLookAtComponent:EVENT_BeControlled()
	pg.game.camera.playerCameraMode:updateZoom()
end

function ClientLookAtComponent:notifyBuffTagChange(changeList, _newVal)
	if self.destroyed then
		return
	end

	if self.lookAtFields.abandon then
		return
	end

	for _, tagId in pairs(changeList) do
		if AbilityConst.MUTE_LOOK_AT_BUFF[tagId] then
			self:refreshLookAtIKState()

			return
		end
	end
end

function ClientLookAtComponent:hasMuteLookAtBuff()
	if self.actorBuff == nil then
		return false
	end

	for buffTag, _ in pairs(AbilityConst.MUTE_LOOK_AT_BUFF) do
		if self.actorBuff:hasTag(buffTag) then
			return true
		end
	end

	return false
end

function ClientLookAtComponent:refreshLookAtIKState()
	local lookAtComponent = self.eModel.ikLookAtComponent

	if IsNil(lookAtComponent) then
		return
	end

	if self.lookAtFields.abandon then
		return
	end

	local disableLookAt = self:hasMuteLookAtBuff()

	if self.disableLookAtForBuff ~= disableLookAt then
		self.disableLookAtForBuff = disableLookAt

		self.eModel:EnableRigComponent(Const.COMPONENT_INDEX_IK, lookAtComponent, not disableLookAt)
	end
end

return ClientLookAtComponent
