-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\ClientOfflinePuppet.lua

local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")
local ClientModelEntity = require("Entities.ClientModelEntity")
local ClientModelUtils = require("Utils.ClientModelUtils")
local PuppetData = require("Data.puppet_data")
local SysConfigData = require("Data.sys_config_data")
local Utils = require("Common.Utils.Utils")
local RigidbodyData = require("Data.rigidbody_data")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local PlayableConst = require("Common.Const.PlayableConst")
local ActorManager = require("Core.Common.ActorManager")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local AbilityConst = require("Common.Const.AbilityConst")
local ClientOfflinePuppet = Class.Class("ClientOfflinePuppet", ClientModelEntity)
local ClientModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelComponent")
local ClientAnimationComponent = require("Entities.SpaceEntities.CommonComponent.ClientAnimationComponent")
local ClientPhysicsComponent = require("Entities.SpaceEntities.CommonComponent.ClientPhysicsComponent")
local ClientMotionComponent = require("Entities.SpaceEntities.CommonComponent.ClientMotionComponent")
local AIComponent = require("Common.Components.AIComponent")
local AIPlanComponent = require("Common.Components.AIPlanComponent")
local AdditiveAIComponent = require("Common.Components.AdditiveAIComponent")
local AIPlanDynamicComponent = require("Common.Components.AIPlanDynamicComponent")
local CharacterController = require("Common.Components.CharacterController")
local AutoPathFindComponent = require("Common.Components.AutoPathFindComponent")
local ClientAbilityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAbilityComponent")
local ClientVoxelComponent = require("Entities.SpaceEntities.CommonComponent.ClientVoxelComponent")
local ClientEffectComponent = require("Entities.SpaceEntities.PlayerComponent.ClientEffectComponent")
local ClientAudioComponent = require("Entities.SpaceEntities.CommonComponent.ClientAudioComponent")
local ClientOfflinePuppetComponents = {
	ClientModelComponent,
	ClientAnimationComponent,
	ClientAudioComponent,
	ClientPhysicsComponent,
	ClientMotionComponent,
	AIComponent,
	AIPlanComponent,
	AdditiveAIComponent,
	AIPlanDynamicComponent,
	CharacterController,
	AutoPathFindComponent,
	ClientAbilityComponent,
	ClientVoxelComponent,
	ClientEffectComponent
}

Class.AddComponents(ClientOfflinePuppet, ClientOfflinePuppetComponents)

function ClientOfflinePuppet:init(dict)
	self.actorType = Const.ACTOR_TYPE_VIRTUAL
	self.virtualTemplateActorType = Const.ACTOR_TYPE_PUPPET

	ClientOfflinePuppet.super.init(self, dict)

	self.staticId = dict.__Properties__.staticId
	self.templateId = dict.__Properties__.templateId
	self.bornPosition = dict.position
	self.authority = Const.AUTHORITY_MASTER

	local configData = self:getConfigData()

	self:setBtName(configData and configData.bTree)

	local isShiny = dict.__Properties__.isShiny

	if isShiny then
		self.label = bit.bor(self.label or 0, Const.PET_LABEL_MASK.SHINY)
		self.shinyStyle = math.random(1, 15)
	end

	self.hasBornState = dict.__Properties__.hasBornState
	self.motionState = dict.__Properties__.motionState

	return true
end

function ClientOfflinePuppet:initializeComponents()
	ClientOfflinePuppet.super.initializeComponents(self)

	local configData = self:getConfigData()

	self:addEModelComponent(Const.COMPONENT_MOTION)
	self.eModel:SetOverrideSteering(Const.COMPONENT_MOTION, configData.turnMaxTime or SysConfigData.defaultTurnMaxTime)
	self:addEModelComponent(Const.COMPONENT_INDEX_IK)
	self:addEModelComponent(Const.COMPONENT_AI_CONTROLLER)
	self:addEModelComponent(Const.COMPONENT_AUTO_PATH_FIND)
	self:addEModelComponent(Const.COMPONENT_RVO)
	self:initPuppetCapture()
end

function ClientOfflinePuppet:postInitializeComponents()
	ClientOfflinePuppet.super.postInitializeComponents(self)
	self:applyMotionProp()
end

function ClientOfflinePuppet:start()
	ClientOfflinePuppet.super.start(self)

	self.hatredMap = {}
	self.space = pg.me.space

	self:onEnterSpace()
end

function ClientOfflinePuppet:destroy()
	ClientOfflinePuppet.super.destroy(self)

	if self.actorId then
		ActorManager.removeEntity(self.actorId, self)
	end
end

function ClientOfflinePuppet:getTemplateData()
	return PuppetData[self.templateId] or {}
end

function ClientOfflinePuppet:getConfigData()
	return self:getTemplateData()
end

function ClientOfflinePuppet:refreshAppearance()
	if not self.eModel then
		return
	end

	local configData = self:getConfigData()
	local modelView = self.eModel.modelModelView
	local extraData = ClientModelUtils.getModelExtraInfo(configData, 0)

	ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraData)
	modelView:RefreshModels()
end

function ClientOfflinePuppet:onModelRefreshed()
	self:setShinyStyle()
	ClientOfflinePuppet.super.onModelRefreshed(self)
end

function ClientOfflinePuppet:checkVirtualAIEnable()
	return true
end

function ClientOfflinePuppet:getVirtualTemplateClass()
	return "ClientPuppet"
end

function ClientOfflinePuppet:serverMsgNoGC()
	return
end

function ClientOfflinePuppet:initPuppetCapture()
	local actorInfo = Utils.getEntityConfigData(self)
	local rigidbodyId = actorInfo.rigidbody

	if not rigidbodyId then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			self.logger:warn("initPuppetCapture rigidbodyId is nil", self.templateId)
		end

		return
	end

	local rigidbodyData = RigidbodyData[rigidbodyId]

	if not rigidbodyData then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			self.logger:warn("initPuppetCapture rigidbodyData is nil", self.templateId)
		end

		return
	end

	if self.eModel == nil then
		return
	end

	self.eModel:SetPuppetCatchExpand(Const.COMPONENT_IDX_PHYSX, rigidbodyData.radius * math.max(1.1, rigidbodyData.catch_radius_scale), rigidbodyData.height * 1.1)
end

function ClientOfflinePuppet:trapped()
	if self.eModel == nil then
		return
	end

	self.isTrapped = true

	AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.IS_TRAPPED, true)

	if self.updateStateCache then
		self:updateStateCache("IN_BALL_ST")
	end

	self:stopTick()
	self.eModel:SetColliderEnable(false)

	self.trappedAnimState = self:playRawAnimation(PlayableConst.Struggle, 0.6)

	if self.trappedAnimState then
		self:playRaiseUp(0.25, 1.5, 2)
	end
end

function ClientOfflinePuppet:cancelTrapped(ballMasterActorId)
	if self.eModel == nil then
		return
	end

	self.isTrapped = false

	AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.IS_TRAPPED, false)

	if self.updateStateCache then
		self:updateStateCache("IN_BALL_ST")
	end

	if self.trappedAnimState then
		self.trappedAnimState:Stop()

		self.trappedAnimState = nil
	end

	self:startTick()
	self.eModel:SetColliderEnable(true)
end

function ClientOfflinePuppet:getCurrScaledTime()
	return Time.realtimeSinceStartup
end

function ClientOfflinePuppet:setTimeScale()
	return
end

function ClientOfflinePuppet:getSelfTimeScale()
	return 1
end

return ClientOfflinePuppet
