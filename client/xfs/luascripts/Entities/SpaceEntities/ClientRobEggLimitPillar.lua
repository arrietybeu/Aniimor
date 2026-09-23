-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientRobEggLimitPillar.lua

local class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local RobEggConst = require("Common.Const.RobEggConst")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientPawnEntity = require("Entities.ClientPawnEntity")
local PuppetData = require("Data.puppet_data")
local LIMITTIME_STATE = RobEggConst.LIMITTIME_STATE
local BROKEN_PREFAB_RES = "$P_Item_Props_GrabEgg_ChallengeTotemBroken.prefab"
local READY_EFFECT = {
	[true] = "Eff_Env_GrabEggBattle_LimitChallenge_Pruple01",
	[false] = "Eff_Env_GrabEggBattle_LimitChallenge_Red01"
}
local ACTIVE_EFFECT = {
	[true] = "Eff_Env_GrabEggBattle_LimitChallenge_Pruple02",
	[false] = "Eff_Env_GrabEggBattle_LimitChallenge_Red02"
}
local ACTIVE_PRESET = {
	[true] = "PM_ChallengeTotem_Pruple_Fre",
	[false] = "PM_ChallengeTotem_Red_Fre"
}
local ClientRobEggLimitPillar = class.Class("ClientRobEggLimitPillar", ClientPawnEntity)
local ClientAuthorityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAuthorityComponent")
local ClientTopLogoComponent = require("Entities.SpaceEntities.CommonComponent.ClientTopLogoComponent")
local ClientInanimateNpcInteractComponent = require("Entities.SpaceEntities.CommonComponent.ClientInanimateNpcInteractComponent")
local ClientDynamicFeatureComponent = require("Entities.SpaceEntities.CommonComponent.ClientDynamicFeatureComponent")
local ClientTrapEventComponent = require("Entities.SpaceEntities.CommonComponent.ClientTrapEventComponent")
local ClientRobEggLimitPillarComponents = {
	ClientAuthorityComponent,
	ClientTopLogoComponent,
	ClientInanimateNpcInteractComponent,
	ClientDynamicFeatureComponent,
	ClientTrapEventComponent
}

if EnableBotTest then
	ClientRobEggLimitPillarComponents = {
		ClientAuthorityComponent,
		ClientInanimateNpcInteractComponent,
		ClientDynamicFeatureComponent
	}
end

class.AddComponents(ClientRobEggLimitPillar, ClientRobEggLimitPillarComponents)

function ClientRobEggLimitPillar:ctor(entityId)
	ClientRobEggLimitPillar.super.ctor(self, entityId)

	self.actorType = Const.ACTOR_TYPE_STATICNPC
end

function ClientRobEggLimitPillar:init(bdict)
	ClientRobEggLimitPillar.super.init(self, bdict)

	if self.limitPillarState == nil and bdict.limitPillarState ~= nil then
		self.limitPillarState = bdict.limitPillarState
	end

	if self.isInitiative == nil and bdict.isInitiative ~= nil then
		self.isInitiative = bdict.isInitiative
	end

	local pdd = PuppetData[self.templateId] or {}

	self.forbiddenTopLogo = pdd.forbidTopLogo or false
	self.useHitBox = false
	self.bodyMass = pdd.mass
	self.bodyWeight = pdd.weight
	self.effs = pdd.effs
	self.entityCanMove = false
	self.pillarStateEffectId = nil
	self.pillarPresetName = nil
	self.pillarBrokenModel = self.limitPillarState == LIMITTIME_STATE.FINISH
	self.spPrefabResID = self.pillarBrokenModel and BROKEN_PREFAB_RES or nil

	return true
end

function ClientRobEggLimitPillar:start()
	ClientRobEggLimitPillar.super.start(self)
	self:refreshPillarState()

	if pg.me and pg.me.syncLimitTimePillarEntity then
		pg.me:syncLimitTimePillarEntity(self)
	end
end

function ClientRobEggLimitPillar:refreshAppearance(forceRefreshPlayable)
	if EnableBotTest then
		return
	end

	ClientRobEggLimitPillar.super.refreshAppearance(self, forceRefreshPlayable)
end

function ClientRobEggLimitPillar:onRefreshAppearance(configData, extraData, forceRefreshPlayable)
	ClientRobEggLimitPillar.super.onRefreshAppearance(self, configData, extraData, forceRefreshPlayable)

	local modelView = self.eModel.modelModelView

	if configData.keepPrefabLayer then
		modelView.keepPrefabLayer = true
	end

	if configData.needWait and not self:modelLoaded() then
		self.waitModelMark = true
		modelView.instPriority = ClientConst.InstantiatePriority.High

		pg.global.scene:markWaitEntity(self.id, true)
	end
end

function ClientRobEggLimitPillar:refreshModel(configData, extraData)
	local modelView = self.eModel.modelModelView

	ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraData)
	modelView:RefreshModels()
end

function ClientRobEggLimitPillar:onModelRefreshed()
	ClientRobEggLimitPillar.super.onModelRefreshed(self)
	self:refreshPillarState(true)
end

function ClientRobEggLimitPillar:getModelExtraData(configData)
	local label = self:getLabel()
	local gender = self:getGender()
	local extraInfo = ClientModelUtils.getModelExtraInfo(configData, label or 0, gender or 0, true)

	if self.spPrefabResID then
		extraInfo.prefabResID = self.spPrefabResID
	end

	return extraInfo
end

function ClientRobEggLimitPillar:getTemplateData()
	return PuppetData[self.templateId] or {}
end

function ClientRobEggLimitPillar:getConfigData()
	return PuppetData[self.templateId] or {}
end

function ClientRobEggLimitPillar:tryGetNpcTrapEventId()
	return self.templateId
end

function ClientRobEggLimitPillar:checkShowEntityInteract()
	local configData = self:getConfigData()
	local state = self.limitPillarState or 0

	return configData.actionPrototypeIds ~= nil and state == 0
end

function ClientRobEggLimitPillar:onLimitPillarStateChange(ov, nv)
	self:refreshBrokenModel()
	self:refreshStateEffect()
	self:refreshInteractTrigger()
end

function ClientRobEggLimitPillar:onIsInitiativeChange(ov, nv)
	self:refreshStateEffect()
end

function ClientRobEggLimitPillar:refreshPillarState(forceRefreshEffect)
	self:refreshBrokenModel()
	self:refreshStateEffect(forceRefreshEffect)
	self:refreshInteractTrigger()
end

function ClientRobEggLimitPillar:syncLimitPillarState(state, isInitiative)
	if state ~= nil then
		self.limitPillarState = state
	end

	if isInitiative ~= nil then
		self.isInitiative = isInitiative
	end

	self:refreshPillarState(true)
end

function ClientRobEggLimitPillar:refreshBrokenModel()
	local needBroken = self.limitPillarState == LIMITTIME_STATE.FINISH

	if needBroken == self.pillarBrokenModel then
		return
	end

	self.pillarBrokenModel = needBroken
	self.spPrefabResID = needBroken and BROKEN_PREFAB_RES or nil

	self:refreshAppearance()
end

function ClientRobEggLimitPillar:refreshStateEffect(forceRefresh)
	if not self.eModel then
		return
	end

	local state = self.limitPillarState
	local isInitiative = ToBool(self.isInitiative)

	if state == nil or state == 0 then
		isInitiative = self:getConfigData().actionPrototypeIds ~= nil
	end

	local effectKey, presetName

	if state == LIMITTIME_STATE.FINISH then
		-- block empty
	elseif state == LIMITTIME_STATE.READY or state == LIMITTIME_STATE.BEGIN or state == LIMITTIME_STATE.REWARD then
		effectKey = ACTIVE_EFFECT[isInitiative]
		presetName = ACTIVE_PRESET[isInitiative]
	else
		effectKey = READY_EFFECT[isInitiative]
	end

	self:applyStateEffect(effectKey, forceRefresh)
	self:applyStatePreset(presetName, forceRefresh)
end

function ClientRobEggLimitPillar:applyStateEffect(effectKey, forceRefresh)
	if not forceRefresh and self.pillarStateEffectKey == effectKey then
		return
	end

	if self.pillarStateEffectId then
		self:stopEffectById(self.pillarStateEffectId)

		self.pillarStateEffectId = nil
	end

	self.pillarStateEffectKey = effectKey

	if effectKey then
		self.pillarStateEffectId = self:playEffect(effectKey)
	end
end

function ClientRobEggLimitPillar:applyStatePreset(presetName, forceRefresh)
	if not forceRefresh and self.pillarPresetName == presetName then
		return
	end

	local shaderView = self.eModel.modelShaderView

	if IsNil(shaderView) then
		return
	end

	if self.pillarPresetName then
		ClientEffectUtils.StopPreset(self, self.pillarPresetName)
	end

	self.pillarPresetName = presetName

	if presetName then
		ClientEffectUtils.PlayPreset(self, presetName, -1, false)
	end
end

function ClientRobEggLimitPillar:repr()
	return string.format("ClientRobEggLimitPillar(entityId=%s)", self.id)
end

function ClientRobEggLimitPillar:preDestroy()
	self:playDestroyEffect()
	ClientRobEggLimitPillar.super.preDestroy(self)
end

return ClientRobEggLimitPillar
