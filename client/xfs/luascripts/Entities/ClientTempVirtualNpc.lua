-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\ClientTempVirtualNpc.lua

local CommonConst = require("Common.Const.Const")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local ClientVirtualEntity = require("Entities.ClientVirtualEntity")
local ClientConst = require("Const.ClientConst")
local MessageName = require("Const.MessageName")
local ClientModelUtils = require("Utils.ClientModelUtils")
local AppearanceEffectUtils = require("Utils.AppearanceEffectUtils")
local Events = require("Common.Container.Events")
local Time = require("Core.Common.Time")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local PuppetData = require("Data.puppet_data")
local SysConfigData = require("Data.sys_config_data")
local NpcAvatarData = require("Data.npc_avatar_data")
local EModelUtils = require("Entities.Utils.EModelUtils")
local Const = require("Const.Const")
local ClientTempVirtualNpc = Class.Class("ClientTempVirtualNpc", ClientVirtualEntity)
local ClientPhysicsComponent = require("Entities.SpaceEntities.CommonComponent.ClientPhysicsComponent")
local ClientRVOComponent = require("Entities.SpaceEntities.CommonComponent.ClientRVOComponent")
local ClientModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelComponent")
local ClientMotionComponent = require("Entities.SpaceEntities.CommonComponent.ClientMotionComponent")
local ClientTopLogoComponent = require("Entities.SpaceEntities.CommonComponent.ClientTopLogoComponent")
local ClientSimpleLookAtComponent = require("Entities.SpaceEntities.CommonComponent.ClientSimpleLookAtComponent")
local ClientModelTransmogComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelTransmogComponent")
local ClientTempVirtualNpcComponents = {
	ClientPhysicsComponent,
	ClientTopLogoComponent,
	ClientModelComponent,
	ClientMotionComponent,
	ClientSimpleLookAtComponent,
	ClientModelTransmogComponent
}

Class.AddComponents(ClientTempVirtualNpc, ClientTempVirtualNpcComponents)

function ClientTempVirtualNpc:init(dict)
	ClientTempVirtualNpc.super.init(self, dict)

	self.dic = dict
	self.templateId = dict.templateId
	self.staticId = dict.staticId
	self.actorId = dict.actorId
	self.copyEntity = dict.copyEntity
	self.syncLoad = dict.syncLoad
	self.virtualTemplateActorType = dict.virtualTemplateActorType or Const.ACTOR_TYPE_PUPPET
	self.finishedCallback = dict.finishedCallback
	self.onAnimatorReadyCallback = dict.animatorReadyCallback
	self.eventEmitter = Events.new()
	self.forbiddenTopLogo = false
	self.topLogoType = ClientConst.TopLogoType.DialogueGraph
	self.topLogoLodTickInterval = 0.1
	self.allowFarTopLogo = true

	if Utils.isVirtualTwinPuppet(dict.templateId) then
		local twinPetChoiceIndex = pg.me and pg.me.twinPetChoiceIndex or 0

		if twinPetChoiceIndex ~= 0 then
			self.templateId = Utils.getVirtualTwinPuppetTemplateId(dict.templateId, twinPetChoiceIndex)
		end
	end

	local pData

	if self.copyEntity then
		pData = self.copyEntity:getConfigData()
	else
		pData = PuppetData[self.templateId]
	end

	self:setConfigData(pData)

	self.gender = dict.gender or self.copyEntity and self.copyEntity.gender or pData and pData.gender or 0
end

function ClientTempVirtualNpc:initializeComponents()
	ClientTempVirtualNpc.super.initializeComponents(self)

	local configData = self:getConfigData()

	self:addEModelComponent(CommonConst.COMPONENT_MOTION)
	self.eModel:SetOverrideSteering(Const.COMPONENT_MOTION, configData.turnMaxTime or SysConfigData.defaultTurnMaxTime)
	self:addEModelComponent(CommonConst.COMPONENT_INDEX_IK)
	self:addEModelComponent(CommonConst.COMPONENT_AUTO_PATH_FIND)
	self:addEModelComponent(CommonConst.COMPONENT_RVO)
	self:setNoCollision()
	self:setCollideEnable(ClientConst.MODEL_VISIBLE_KEY.DEFAULT, false)
end

function ClientTempVirtualNpc:postInitializeComponents()
	if self.eModel then
		self.eModel:PostInitialize()
	end

	self:applyMotionProp()
end

function ClientTempVirtualNpc:enterSpace(space)
	self.space = space

	self.space:onEntityJoin(self)
	self:onEnterSpace()
	self:reconcileTopLogoLodTimer()
end

function ClientTempVirtualNpc:onModelRefreshed()
	ClientTempVirtualNpc.super.onModelRefreshed(self)

	if self.modelLoadedCallback then
		self.modelLoadedCallback()
	end
end

function ClientTempVirtualNpc:refreshAppearance()
	if not self.eModel then
		return
	end

	self.appearanceEffectInfo = {}

	local configData = self:getConfigData()
	local label = self:getLabel() or 0
	local gender = self:getGender() or 0
	local modelView = self.eModel.modelModelView
	local bornScale = 1

	if self.copyEntity then
		bornScale = self.copyEntity.bornScale

		modelView.modelInfo:CopyFrom(self.copyEntity.eModel.modelModelView.modelInfo)
		AppearanceEffectUtils.copyAppearanceInfo(self, self.copyEntity)
	else
		local extraInfo = ClientModelUtils.getModelExtraInfo(configData, label, gender or 0, true)
		local result, realPrefabResID = AvatarUtils.refreshNPCModelData(configData)

		if not result then
			ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraInfo)

			if self.attachBaseEffects then
				self:attachBaseEffects(extraInfo.attachEffects)
			end

			if configData.appearanceResID then
				local npcAvatarData = NpcAvatarData[configData.appearanceResID] or {}
				local presetKey = npcAvatarData.avatarId

				if presetKey then
					modelView.modelInfo:ParseAvatarRuntimeData(presetKey)
					modelView.modelInfo:ParseToModelInfo()
				end
			end
		else
			extraInfo.prefabResID = realPrefabResID

			ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraInfo)
		end

		bornScale = ClientModelUtils.getBornScale(configData, label)
	end

	if self.dic.position ~= nil and self.dic.rotation ~= nil then
		local rot = Quaternion.Euler(self.dic.rotation[1], self.dic.rotation[2], self.dic.rotation[3])

		EModelUtils.setAgentPositionAndRotation(self, self.dic.position, rot)
	end

	modelView.modelInfo.physiqueModelInfo.isAlwaysAnimate = true

	if self.finishedCallback then
		function modelView.luaOnModelRefreshFinshed()
			self.finishedCallback(self)
		end
	end

	ClientModelUtils.refreshModels(self, modelView)
	self:setModelScale(ClientConst.MODEL_SCALE_KEY.DEFAULT, bornScale)
end

function ClientTempVirtualNpc:getLabel()
	return self.dic.label or self:getConfigData().label
end

function ClientTempVirtualNpc:getGender()
	return self.gender
end

function ClientTempVirtualNpc:destroy()
	self:reconcileTopLogoLodTimer(true)
	ClientTempVirtualNpc.super.destroy(self)
end

return ClientTempVirtualNpc
