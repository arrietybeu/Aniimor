-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientEffectComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local effectData = require("Data.effect_data")
local ClientEffectUtils = require("Utils.ClientEffectUtils")
local AppearanceEffectUtils = require("Utils.AppearanceEffectUtils")
local HandheldAppearanceUtils = require("Utils.HandheldAppearanceUtils")
local EffectConst = require("Const.EffectConst")
local Const = require("Common.Const.Const")
local EffectRemapData = require("Data.effect_remap_data")
local SkeletonTemplateData = require("Data.skeleton_template_data")
local LuaTimeline = require("GameApp.Timeline.LuaTimeline")
local SceneData = require("Data.scene_data")
local Utils = require("Common.Utils.Utils")
local SceneUtils = require("Common.Utils.SceneUtils")
local ClientAbilityUtils = require("Utils.ClientAbilityUtils")
local Lume = require("Core.Common.lume")
local MessageName = require("Const.MessageName")
local HitModelShakeData = require("Data.hit_model_shake_data")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local ShaderEffectShareData = require("GameApp.ShareData.Generated.ShaderEffectShareData")
local ShaderEffectData = require("GameApp.Effect.ShaderEffectData")
local ClientEffectComponent = Class.Component("ClientEffectComponent")
local ToBool = ToBool
local GameObject = CS.UnityEngine.GameObject
local NotNil = NotNil
local EffectManager = CS.FunPlus.WorldX.Manager.EffectManager

local function disableEffectLod(effectTrans)
	if IsNil(effectTrans) then
		return
	end

	local EffectLevelSettingType = typeof(CS.FunPlus.WorldX.GameApp.Effect.EffectLevelSetting)
	local lodComps = effectTrans:GetComponentsInChildren(EffectLevelSettingType, true)

	if not lodComps then
		return
	end

	for i = 0, lodComps.Length - 1 do
		local lodComp = lodComps[i]

		if NotNil(lodComp) then
			lodComp:IgnoreUnLoad()
			lodComp:SetEnableUpdate(false)
		end
	end
end

function ClientEffectComponent:ctor()
	self.attachedEffectIds = {}
	self.integratedToModelEffectIds = {}
	self.appearanceAttachEffectIds = {}
	self.attachEffectHiddenReasons = {}
	self.animationEventEffectsMap = {}
	self.effReplaceMap = {}
end

function ClientEffectComponent:init(dict)
	self.pendingBornEffect = dict.firstEnterSpace == true or self.clientVisible == false or self.isHideNpc == true
end

function ClientEffectComponent:_stopModelEffectsForPreDestroy()
	for effKey, effId in pairs(self.attachedEffectIds or EMPTY_TABLE) do
		self:stopEffectById(effId)
	end

	for effectId, _ in pairs(self.integratedToModelEffectIds or EMPTY_TABLE) do
		self:stopEffectById(effectId)
	end

	for effectKey, effectId in pairs(self.appearanceAttachEffectIds or EMPTY_TABLE) do
		self:stopEffectById(effectId)

		self.appearanceAttachEffectIds[effectKey] = nil
	end

	for animKey, info in pairs(self.animationEventEffectsMap or EMPTY_TABLE) do
		for eventConfigId, effectId in pairs(info) do
			self:stopEffectById(effectId)
		end
	end
end

function ClientEffectComponent:preDestroy()
	self:_stopModelEffectsForPreDestroy()
end

function ClientEffectComponent:destroy()
	self.pendingBornEffect = nil

	if self.resetVisibleTimer then
		self:removeTimer(self.resetVisibleTimer)

		self.resetVisibleTimer = nil
	end

	self.attachedEffectIds = nil
	self.integratedToModelEffectIds = nil
	self.appearanceAttachEffectIds = nil
	self.attachEffectHiddenReasons = nil
	self.animationEventEffectsMap = nil

	self:unPreloadEffects()

	if self.shaderEffectShare then
		ShaderEffectShareData.destroy(self.shaderEffectShare)

		self.shaderEffectShare = nil
	end
end

function ClientEffectComponent:start()
	self:preloadEffects()

	local beforeBornEffect = self:getConfigData().beforeBornEffect

	if beforeBornEffect then
		self:setActive(ClientConst.MODEL_VISIBLE_KEY.BORN_EFFECT, false)

		local eid = self:playEffect(beforeBornEffect, {
			endCallback = function()
				self:setActive(ClientConst.MODEL_VISIBLE_KEY.BORN_EFFECT, true)
			end
		})

		if not eid or eid == 0 then
			self:setActive(ClientConst.MODEL_VISIBLE_KEY.BORN_EFFECT, true)
		end
	end

	local masterEntity = self.getMasterEntity and self:getMasterEntity()

	if masterEntity and masterEntity.effReplaceMap then
		for key, map in pairs(masterEntity.effReplaceMap) do
			self:addReplaceEffKeys(key, map)
		end
	else
		for key, map in pairs(self.effReplaceMap or EMPTY_TABLE) do
			self:addReplaceEffKeys(key, map)
		end
	end
end

function ClientEffectComponent:EVENT_AddEComponent()
	if self.needCreateEffectComponent and self:needCreateEffectComponent() == false then
		return
	end

	self:addEModelComponent(Const.COMPONENT_INDEX_EFFECT)
end

function ClientEffectComponent:onEnterSpace()
	self:trySetEnemyState()
	self:refreshEmitterIntensity()
end

function ClientEffectComponent:EVENT_onModelLoaded()
	self:refreshEmitterIntensity()
end

function ClientEffectComponent:EVENT_OnModelRefreshed()
	self:stopAllIntegratedToModelEffect()
	ClientEffectUtils.applyCommonMountEffects(self)

	local defaultEffectWithPreset = self:getConfigData().defaultEffectWithPreset

	if defaultEffectWithPreset then
		self:playIntegratedToModelEffect(defaultEffectWithPreset)

		local preset = self:getConfigData().preset

		if preset then
			self.eModel:PlayPreset(Const.COMPONENT_INDEX_EFFECT, defaultEffectWithPreset, preset, 0, false)
		end
	end
end

function ClientEffectComponent:onSkeletonLoaded()
	if Utils.isPet(self) then
		local masterEntity = self:getMasterEntity()

		if masterEntity then
			pg.game.effect:getTeamLinkController():onSkeletonLoaded(masterEntity)
		end
	end
end

function ClientEffectComponent:EVENT_BeControlled()
	if not self.eModel then
		return false
	end

	self.eModel:OnEntityControlStateChange(Const.COMPONENT_INDEX_EFFECT)
end

function ClientEffectComponent:EVENT_LoseControlled()
	if not self.eModel then
		return false
	end

	self.eModel:OnEntityControlStateChange(Const.COMPONENT_INDEX_EFFECT)
end

function ClientEffectComponent:canPlayEffect()
	if not self.eModel then
		return false
	end

	return self.eModel:IsValid(Const.COMPONENT_INDEX_EFFECT)
end

function ClientEffectComponent:setDisableEffectLod(disableLod)
	if not self.eModel then
		return false
	end

	self.eModel:SetDisableEffectLod(Const.COMPONENT_INDEX_EFFECT, disableLod)
end

function ClientEffectComponent:preloadEffects()
	if not self.id then
		return
	end

	if self.getPreloadEffects then
		self.preloadEffectData = self:getPreloadEffects()

		if self.preloadEffectData then
			for _, preloadEffects in pairs(self.preloadEffectData) do
				pg.game.effect:preloadEntityEffect(self.id, preloadEffects)
			end
		end
	end
end

function ClientEffectComponent:extraPreloadEffect(effectId)
	pg.game.effect:preloadEntityEffect(self.id, effectId)
end

function ClientEffectComponent:extraUnPreloadEffect(effectId)
	pg.game.effect:unPreloadEntityEffect(self.id, effectId)
end

function ClientEffectComponent:isEffectPreloaded(effectId)
	local effectManager = pg.global and pg.global.effectMgr

	if not effectManager or not effectManager.IsPreLoadEffect then
		return false
	end

	return effectManager:IsPreLoadEffect(effectId) == true
end

function ClientEffectComponent:unPreloadEffects()
	if not self.id then
		return
	end

	pg.game.effect:unPreloadAllEntityEffect(self.id)
end

function ClientEffectComponent:getRealEffectKey(effectKey)
	local effectRemapInfo = EffectRemapData[effectKey]

	if not effectRemapInfo then
		return effectKey
	end

	local configData = self:getConfigData() or {}
	local skeletonTemplate = (SkeletonTemplateData[configData.prefabResID] or EMPTY_TABLE).skeletonTemplate

	effectKey = skeletonTemplate and (effectRemapInfo[skeletonTemplate] or EMPTY_TABLE).EffDataId or effectKey

	return effectKey
end

function ClientEffectComponent:isEffectBoundToBone(effectKey)
	if string.isNilOrEmpty(effectKey) then
		return false
	end

	effectKey = self:getRealEffectKey(effectKey)

	local configs = effectData[effectKey] or {}

	for _, config in ipairs(configs or EMPTY_TABLE) do
		if type(config.bone) == "string" and config.bone ~= "" then
			return true
		end
	end

	return false
end

function ClientEffectComponent:playEffect(effectKey, extInfo, forceSync, effectDataOverride)
	extInfo = extInfo or {}

	if not self:canPlayEffect() then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("can not playEffect", self:hasEModelComponent(Const.COMPONENT_INDEX_EFFECT))
		end

		return
	end

	effectKey = self:getRealEffectKey(effectKey)

	local sourceEffectData = effectData[effectKey] or {}
	local ed = effectDataOverride or HandheldAppearanceUtils.getCurrentHandheldEffectData(self, effectKey, sourceEffectData) or sourceEffectData

	if ed == nil then
		if ShaderEffectData[effectKey] then
			self:playShaderEffect(effectKey)
		end

		return 0
	end

	local effId

	for _, v in ipairs(ed) do
		local id = self:doPlayEffect(effectKey, v, extInfo, effId, forceSync)

		effId = ToBool(effId) and effId or id
	end

	return effId
end

function ClientEffectComponent:playEffectAt(effectKey, position, eulerAngles, extInfo, forceSync)
	extInfo = extInfo or {}
	extInfo.position = position
	extInfo.rotation = eulerAngles or Vector3.zero
	extInfo.mountType = EffectConst.MountType.World
	extInfo.followType = EffectConst.FollowType.Global

	return self:playEffect(effectKey, extInfo, forceSync)
end

function ClientEffectComponent:playEffectOn(effectKey, extInfo, trans, forceSync)
	extInfo = extInfo or {}
	extInfo.mountType = EffectConst.MountType.Custom
	extInfo.targetTrans = trans

	local effId = self:playEffect(effectKey, extInfo, forceSync)

	return effId
end

function ClientEffectComponent:playEffectRaw(resId, extraInfo)
	local rawInfo = {
		resID = resId
	}
	local effectId = self:doPlayEffect(resId, rawInfo, extraInfo)

	return effectId
end

function ClientEffectComponent:playLinkVegEffect(effectKey, targetTrans)
	self:playEffect(effectKey, {
		linkEndTrans = targetTrans
	})
end

function ClientEffectComponent:playLinkEffect(effectKey, target, extraInfo)
	if not target or not self.eModel then
		return nil
	end

	if IsNil(target.csObj) and not target.eModel then
		return nil
	end

	local ed = effectData[effectKey] or {}

	if ed == nil then
		ed = {}
	end

	extraInfo = extraInfo or {}
	extraInfo.mountType = EffectConst.MountType.Link

	if ed[1] then
		if target.csObj then
			extraInfo.linkEndTrans = target.csObj.transform
			extraInfo.linkEndOffset = Vector3(0, 0, 0)
		elseif ed[1].linkEndBone and target.hasEModelComponent and target:hasEModelComponent(Const.COMPONENT_INDEX_MODEL) then
			if string.isNilOrEmpty(target.id) then
				return nil
			end

			local mountData = ClientEffectUtils.getBestFitCommonMount(target, ed[1].linkEndBone)

			if mountData then
				extraInfo.linkEndBone = mountData.bone
				extraInfo.linkEndEntId = target.id or ""
				extraInfo.linkEndOffset = mountData.position
			else
				extraInfo.linkEndBone = ed[1].linkEndBone
				extraInfo.linkEndEntId = target.id or ""
				extraInfo.linkEndOffset = ed[1].position
			end
		end

		if string.isNilOrEmpty(ed[1].bone) and not extraInfo.linkStartTrans and not extraInfo.linkStartTransActorId and not extraInfo.position then
			extraInfo.linkStartTransActorId = self.actorId

			local selfOff = self:getHeight() * 0.5

			extraInfo.position = Vector3(0, selfOff, 0)
		end
	end

	return self:playEffect(effectKey, extraInfo)
end

function ClientEffectComponent:playLinkEffectByDir(effectKey, dir, distance, extraInfo)
	if not dir or distance == 0 then
		return nil
	end

	local ed = effectData[effectKey] or {}

	if ed == nil then
		ed = {}
	end

	extraInfo = extraInfo or {}
	extraInfo.mountType = EffectConst.MountType.Link
	extraInfo.linkEndDir = dir
	extraInfo.linkEndDist = distance

	if ed[1] and string.isNilOrEmpty(ed[1].bone) and not extraInfo.linkStartTrans and not extraInfo.linkStartTransActorId then
		extraInfo.linkStartTransActorId = self.actorId

		local selfOff = self:getHeight() * 0.5

		extraInfo.position = Vector3(0, selfOff, 0)
	end

	return self:playEffect(effectKey, extraInfo)
end

function ClientEffectComponent:playLinkEffectToPos(effectKey, toPos, extraInfo)
	if not toPos or not effectKey then
		return nil
	end

	local ed = effectData[effectKey] or {}

	if ed == nil then
		return nil
	end

	extraInfo = extraInfo or {}
	extraInfo.mountType = EffectConst.MountType.Link
	extraInfo.linkEndOffset = toPos

	if ed[1] and string.isNilOrEmpty(ed[1].bone) and not extraInfo.linkStartTrans and not extraInfo.linkStartTransActorId then
		extraInfo.linkStartTransActorId = self.actorId

		local selfOff = self:getHeight() * 0.5

		extraInfo.position = Vector3(0, selfOff, 0)
	end

	return self:playEffect(effectKey, extraInfo)
end

local cacheEmptyTable = {}

function ClientEffectComponent:doPlayEffect(effectKey, rawInfo, extraInfo, customId, forceSync)
	if effectKey == nil then
		return
	end

	if not self:canPlayEffect() then
		return
	end

	Lume.clear(cacheEmptyTable)

	extraInfo = extraInfo or cacheEmptyTable
	extraInfo.entityId = self.id

	ClientEffectUtils.getEffectLevelInfo(effectKey, rawInfo, extraInfo)
	ClientEffectUtils.applyEffectCommonMountData(self, rawInfo, extraInfo)

	local effectConfigInfo = pg.game.effect:createEffectConfigInfo(rawInfo, extraInfo)
	local effId = self.eModel:PlayEffect(Const.COMPONENT_INDEX_EFFECT, effectKey, effectConfigInfo, customId or 0, forceSync or false)

	return effId
end

function ClientEffectComponent:playEffectOnAnimation(effectKey, animKey, eventConfigId, configData)
	local animInfo = self.animationEventEffectsMap[animKey]
	local oldEffectId = animInfo and animInfo[eventConfigId]
	local ed = effectData[effectKey] or {}
	local hasEffectData = next(ed) ~= nil
	local handheldResource = HandheldAppearanceUtils.getEffectResourceForAnimation(self, animKey, effectKey, ed)
	local effectDataOverride = handheldResource and hasEffectData and HandheldAppearanceUtils.buildEffectDataWithHandheldResource(ed, handheldResource) or nil

	if not self:canPlayEffect() then
		if ToBool(oldEffectId) then
			self:stopEffectById(oldEffectId, false, false)

			if animInfo then
				animInfo[eventConfigId] = nil
			end
		end

		return 0
	end

	local extraInfo = configData or {}

	if not string.isNilOrEmpty(configData.commonMount) then
		extraInfo.commonMount = configData.commonMount
		extraInfo.bone = nil
	end

	extraInfo.enableMpeLodDown = ClientAbilityUtils.checkEnableMpeLodDown(self)
	extraInfo.mpeLodDownLevel = EffectConst.MIN_LOD_DOWN_LEVEL

	local effectId

	if hasEffectData then
		effectId = self:playEffect(effectKey, extraInfo, handheldResource ~= nil, effectDataOverride)
	else
		effectId = self:playEffectRaw(handheldResource or effectKey, extraInfo)
	end

	if ToBool(oldEffectId) then
		self:stopEffectById(oldEffectId, false, false)
	end

	if ToBool(effectId) then
		if animInfo == nil then
			animInfo = {}
			self.animationEventEffectsMap[animKey] = animInfo
		end

		animInfo[eventConfigId] = effectId
	elseif animInfo then
		animInfo[eventConfigId] = nil
	end

	return effectId
end

function ClientEffectComponent:getPresetNameForAnimation(presetName, animKey)
	return HandheldAppearanceUtils.getPresetNameForAnimation(self, animKey, presetName) or presetName
end

function ClientEffectComponent:stopEffectByIdOnAnimation(animKey, eventConfigId, effectId, drop)
	if not ToBool(effectId) then
		return
	end

	local animInfo = self.animationEventEffectsMap and self.animationEventEffectsMap[animKey]

	if animInfo and animInfo[eventConfigId] == effectId then
		animInfo[eventConfigId] = nil
	end

	self:stopEffectById(effectId, false, drop)
end

function ClientEffectComponent:stopAllAnimationEventEffects()
	for animKey, info in pairs(self.animationEventEffectsMap) do
		for eventConfigId, effectId in pairs(info) do
			self:stopEffectById(effectId)

			self.animationEventEffectsMap[animKey][eventConfigId] = nil
		end
	end
end

function ClientEffectComponent:setEffectPosRot(effectId, pos, rot)
	if self.eModel then
		self.eModel:UpdateEffectPosRot(Const.COMPONENT_INDEX_EFFECT, effectId, pos, rot)
	end
end

function ClientEffectComponent:setEffectScale(effectId, scale)
	if self.eModel then
		self.eModel:UpdateEffectScale(Const.COMPONENT_INDEX_EFFECT, effectId, scale)
	end
end

function ClientEffectComponent:stopEffect(effectKey, reclaim, drop, checkRefCnt, linkActorId)
	if string.isNilOrEmpty(effectKey) then
		return
	end

	reclaim = reclaim or false
	checkRefCnt = checkRefCnt or false

	if self.eModel then
		if drop then
			self.eModel:DropEffect(Const.COMPONENT_INDEX_EFFECT, effectKey)
		end

		if linkActorId == nil or linkActorId == 0 then
			self.eModel:StopEffect(Const.COMPONENT_INDEX_EFFECT, effectKey, reclaim, checkRefCnt)
		else
			self.eModel:StopEffectWithLinkActorId(Const.COMPONENT_INDEX_EFFECT, effectKey, reclaim, checkRefCnt, linkActorId)
		end
	end
end

function ClientEffectComponent:getEffectPlayTime(effectKey)
	if string.isNilOrEmpty(effectKey) then
		return
	end

	if self.eModel then
		return self.eModel:GetEffectPlayTime(Const.COMPONENT_INDEX_EFFECT, effectKey)
	end

	return 0
end

function ClientEffectComponent:hideEffect()
	if self.eModel then
		self.eModel:HideEffect(Const.COMPONENT_INDEX_EFFECT)
	end
end

function ClientEffectComponent:showEffect()
	if self.eModel then
		self.eModel:ShowEffect(Const.COMPONENT_INDEX_EFFECT)
	end
end

function ClientEffectComponent:dropEffect(effectKey)
	if string.isNilOrEmpty(effectKey) then
		return
	end

	if self.eModel then
		self.eModel:DropEffect(Const.COMPONENT_INDEX_EFFECT, effectKey)
	end
end

function ClientEffectComponent:hasEffect(effectKey)
	if string.isNilOrEmpty(effectKey) then
		return
	end

	if self.eModel then
		return self.eModel:HasEffect(Const.COMPONENT_INDEX_EFFECT, effectKey)
	end
end

function ClientEffectComponent:setEffectAnimTrigger(effectKey, triggerName)
	if string.isNilOrEmpty(effectKey) or string.isNilOrEmpty(triggerName) then
		return
	end

	if self.eModel then
		self.eModel:SetEffectTrigger(Const.COMPONENT_INDEX_EFFECT, effectKey, triggerName)
	end
end

function ClientEffectComponent:setEffectMaterialPropertyInt(effectKey, propertyId, value, materialName)
	if string.isNilOrEmpty(effectKey) or not propertyId then
		return
	end

	if self.eModel then
		self.eModel:SetEffectMaterialPropertyInt(Const.COMPONENT_INDEX_EFFECT, effectKey, propertyId, value, materialName)
	end
end

function ClientEffectComponent:setEffectMaterialProperty(effectKey, propertyId, value, materialName)
	if string.isNilOrEmpty(effectKey) or not propertyId then
		return
	end

	if self.eModel then
		self.eModel:SetEffectMaterialProperty(Const.COMPONENT_INDEX_EFFECT, effectKey, propertyId, value, materialName)
	end
end

function ClientEffectComponent:setEffectMaterialPropertyVector(effectKey, propertyId, value, materialName)
	if string.isNilOrEmpty(effectKey) or not propertyId then
		return
	end

	if self.eModel then
		self.eModel:SetEffectMaterialPropertyVector(Const.COMPONENT_INDEX_EFFECT, effectKey, propertyId, value, materialName)
	end
end

function ClientEffectComponent:tweenEffectMaterialProperty(effectKey, propertyId, fromValue, toValue, duration, materialName)
	if string.isNilOrEmpty(effectKey) or not propertyId then
		return
	end

	if self.eModel then
		self.eModel:TweenEffectMaterialProperty(Const.COMPONENT_INDEX_EFFECT, effectKey, propertyId, fromValue, toValue, duration, materialName)
	end
end

function ClientEffectComponent:setEffectChildTransformActive(effectKey, childName, active)
	if string.isNilOrEmpty(effectKey) or string.isNilOrEmpty(childName) then
		return
	end

	if self.eModel then
		self.eModel:SetEffectChildTransformActive(Const.COMPONENT_INDEX_EFFECT, effectKey, childName, active)
	end
end

function ClientEffectComponent:stopEffectById(effectId, reclaim, drop)
	if effectId == nil then
		return
	end

	if reclaim == nil then
		reclaim = true
	end

	if self.eModel then
		if drop then
			self.eModel:DropEffectById(Const.COMPONENT_INDEX_EFFECT, effectId)
		end

		self.eModel:StopEffectById(Const.COMPONENT_INDEX_EFFECT, effectId, reclaim)
	end
end

function ClientEffectComponent:refreshEffectVisibleByCapture(visible)
	if self.eModel then
		self.eModel:RefreshEffectVisibleByCapture(Const.COMPONENT_INDEX_EFFECT, visible)
	end
end

function ClientEffectComponent:playModelShake(modelShakeId)
	if not modelShakeId then
		return
	end

	if self.useHitBox then
		return
	end

	local shakeModelData = HitModelShakeData[modelShakeId]
	local configData = self:getConfigData()

	if configData.disableModelShake then
		return
	end

	if self.eModel and shakeModelData and self ~= pg.pawn then
		local duration, frequency, randomness, fadeOut = 0, 0, 90, false
		local amplitudeX, amplitudeY, amplitudeZ = 0, 0, 0

		if shakeModelData.shakeLevel then
			if shakeModelData.shakeLevel == "Light" then
				duration = 0.08
				amplitudeX, amplitudeY, amplitudeZ = 0.04, 0.04, 0.04
				frequency = 40
			elseif shakeModelData.shakeLevel == "Medium" then
				duration = 0.12
				amplitudeX, amplitudeY, amplitudeZ = 0.06, 0.06, 0.06
				frequency = 50
			elseif shakeModelData.shakeLevel == "Heavy" then
				duration = 0.15
				amplitudeX, amplitudeY, amplitudeZ = 0.08, 0.08, 0.08
				frequency = 60
			end
		end

		if shakeModelData.duration then
			duration = shakeModelData.duration
		end

		if shakeModelData.amplitude then
			amplitudeX = shakeModelData.amplitude[1]
			amplitudeY = shakeModelData.amplitude[2]
			amplitudeZ = shakeModelData.amplitude[3]
		end

		if shakeModelData.frequency then
			frequency = shakeModelData.frequency
		end

		if shakeModelData.randomness then
			randomness = shakeModelData.randomness
		end

		if shakeModelData.fadeOut then
			fadeOut = shakeModelData.fadeOut
		end

		self.eModel:ShakeModel(Const.COMPONENT_INDEX_MODEL, duration, Vector3(amplitudeX, amplitudeY, amplitudeZ), frequency, randomness, fadeOut)
	end
end

function ClientEffectComponent:refreshAppearanceAttachEffects()
	local effectIds = self.appearanceAttachEffectIds

	if not effectIds then
		return
	end

	local effectKeys = AppearanceEffectUtils.getAttachEffectKeys(self)

	for realEffectKey, effectId in pairs(effectIds) do
		if effectKeys[realEffectKey] == nil then
			self:stopEffectById(effectId)

			effectIds[realEffectKey] = nil
		end
	end

	for realEffectKey, effectKey in pairs(effectKeys) do
		if effectIds[realEffectKey] == nil then
			local extInfo = {}

			ClientAbilityUtils.setEffectMpeLodInfo(extInfo, self)

			local effectId = self:playEffect(effectKey, extInfo)

			if effectId ~= nil and effectId ~= 0 then
				effectIds[realEffectKey] = effectId
			end
		end
	end

	self:refreshAttachEffectVisible()
end

function ClientEffectComponent:stopAllIntegratedToModelEffect()
	for effectId, _ in pairs(self.integratedToModelEffectIds) do
		self:stopEffectById(effectId)

		self.integratedToModelEffectIds[effectId] = nil
	end
end

function ClientEffectComponent:playIntegratedToModelEffect(effectKey, extInfo)
	extInfo = extInfo or {}
	extInfo.enableMpeLodDown = ClientAbilityUtils.checkEnableMpeLodDown(self)
	extInfo.mpeLodDownLevel = EffectConst.MIN_LOD_DOWN_LEVEL

	local effectId = self:playEffect(effectKey, extInfo)

	if effectId ~= nil and effectId ~= 0 then
		self.integratedToModelEffectIds[effectId] = effectKey

		self:refreshAttachEffectVisible()
	end
end

function ClientEffectComponent:EVENT_TimeScaleChanged(timeScale)
	self:applyEffectFreezeScale()
end

function ClientEffectComponent:setEffectTimeScale(timeScale, freezeScale)
	timeScale = timeScale or 1
	freezeScale = freezeScale or 1

	self.eModel:SetEffectTimeScale(Const.COMPONENT_INDEX_EFFECT, timeScale, freezeScale)
end

function ClientEffectComponent:applyEffectFreezeScale()
	if self.timeScale and self.eModel then
		local gameTimeScale = self:getGameTimeScale()

		self:setEffectTimeScale(gameTimeScale * (self.baseTimeScale or 1), self.frameFreezeScale or 1)
	end
end

function ClientEffectComponent:attachBaseEffects(effects, isIgnoreEffectLod)
	self.attachedEffectIds = self.attachedEffectIds or {}

	local attachedEffects = {}

	for _, effInfo in ipairs(effects) do
		local effKey = effInfo.effectKey

		if self.attachedEffectIds[effKey] == nil then
			effInfo.enableMpeLodDown = ClientAbilityUtils.checkEnableMpeLodDown(self)
			effInfo.mpeLodDownLevel = EffectConst.MIN_LOD_DOWN_LEVEL

			if isIgnoreEffectLod then
				function effInfo.loadCallback(effectItem)
					disableEffectLod(effectItem and effectItem.effectTrans)
				end
			end

			local effId = self:playEffect(effKey, effInfo)

			if effId ~= nil and effId ~= 0 then
				attachedEffects[effKey] = effId
			end
		else
			local effId = self.attachedEffectIds[effKey]

			attachedEffects[effKey] = effId

			if isIgnoreEffectLod then
				disableEffectLod(self:getEffectTransform(effId))
			end
		end
	end

	for effKey, effId in pairs(self.attachedEffectIds) do
		if attachedEffects[effKey] == nil then
			self:stopEffectById(effId)
		end
	end

	self.attachedEffectIds = attachedEffects

	self:refreshAttachEffectVisible()
end

function ClientEffectComponent:tempHideAttachEffect(duration)
	if not duration or not next(self.attachedEffectIds) and not next(self.integratedToModelEffectIds) and not next(self.appearanceAttachEffectIds) then
		return
	end

	self:setAttachEffectVisible(false)

	if self.resetVisibleTimer then
		self:removeTimer(self.resetVisibleTimer)

		self.resetVisibleTimer = nil
	end

	self.resetVisibleTimer = self:addTimer(duration, function()
		self:setAttachEffectVisible(true)
	end)
end

function ClientEffectComponent:setAttachEffectVisible(visible)
	self:setAttachEffectVisibleByReason(ClientConst.MODEL_VISIBLE_KEY.DEFAULT, visible)
end

function ClientEffectComponent:setAttachEffectVisibleByReason(reason, visible)
	reason = reason or ClientConst.MODEL_VISIBLE_KEY.DEFAULT
	self.attachEffectHiddenReasons = self.attachEffectHiddenReasons or {}

	local changed = false

	if visible or visible == nil then
		if self.attachEffectHiddenReasons[reason] then
			self.attachEffectHiddenReasons[reason] = nil
			changed = true
		end
	elseif not self.attachEffectHiddenReasons[reason] then
		self.attachEffectHiddenReasons[reason] = true
		changed = true
	end

	if changed then
		self:refreshAttachEffectVisible()
	end
end

function ClientEffectComponent:refreshAttachEffectVisible()
	if not self.eModel then
		return
	end

	local visible = self.attachEffectHiddenReasons == nil or next(self.attachEffectHiddenReasons) == nil

	for effKey, effId in pairs(self.attachedEffectIds or EMPTY_TABLE) do
		self.eModel:SetEffectVisibleById(Const.COMPONENT_INDEX_EFFECT, effId, visible)
	end

	for effId, effKey in pairs(self.integratedToModelEffectIds or EMPTY_TABLE) do
		self.eModel:SetEffectVisibleById(Const.COMPONENT_INDEX_EFFECT, effId, visible)
	end

	for _, effId in pairs(self.appearanceAttachEffectIds or EMPTY_TABLE) do
		self.eModel:SetEffectVisibleById(Const.COMPONENT_INDEX_EFFECT, effId, visible)
	end
end

function ClientEffectComponent:getEffectTransform(effId)
	if self.eModel then
		return self.eModel:GetEffect(Const.COMPONENT_INDEX_EFFECT, effId)
	end

	return nil
end

function ClientEffectComponent:getEffectAnimator(effId)
	if self.eModel then
		return self.eModel:GetEffectAnimator(Const.COMPONENT_INDEX_EFFECT, effId)
	end

	return nil
end

function ClientEffectComponent:playMoveToSelfEffect(effectKey, fromPos, fromRot, duration, faceToSelf)
	duration = math.max(duration or 0, 0.1)

	local effectAttachObj = GameObject("effectAttachObj")

	effectAttachObj.transform:SetParent(pg.global.effectMgr.worldEffectRoot)

	effectAttachObj.transform.position = fromPos
	effectAttachObj.transform.rotation = fromRot

	local extraInfo = {
		duration = duration
	}
	local effectId = self:playEffectOn(effectKey, extraInfo, effectAttachObj.transform)
	local timeline = LuaTimeline.new()

	timeline:setDuration(duration)
	timeline:createAndAddClip(0, duration, function(_, currTime)
		if self.eModel then
			local blendValue = currTime / duration
			local tpx, tpy, tpz = self.eModel:GetPositionAgentPosEx()
			local targetPosition = Vector3.New(tpx, tpy + self:getHeight() * 0.5, tpz)
			local blendPosition = Vector3.Lerp(fromPos, targetPosition, blendValue)

			effectAttachObj.transform.position = blendPosition

			if faceToSelf then
				local dir = targetPosition - blendPosition
				local dirRot = effectAttachObj.transform.rotation

				if Vector3.Magnitude(dir) > 0.001 then
					dirRot = Quaternion.LookRotation(dir, Vector3(0, 1, 0))
				end
			end
		else
			timeline:stop()
		end
	end)
	timeline:setStopCallback(function()
		self:stopEffectById(effectId, false, true)
		GameObject.Destroy(effectAttachObj)
	end)
	timeline:start()
end

function ClientEffectComponent:createGhostEffect(effect, offsetPos, fadeoutTime, alpha)
	if self:hasEModelComponent(Const.COMPONENT_INDEX_EFFECT) then
		if not self.ghotEffects then
			self.ghotEffects = {}
		elseif #self.ghotEffects >= 3 then
			self:stopEffectById(self.ghotEffects[1])
		end

		local ghostEffect = effect
		local extInfo = {
			position = self:getPosition() + Quaternion.MulVec3(self:getRotation(), offsetPos),
			rotation = self:getRotation():ToEulerAngles(),
			mountType = EffectConst.MountType.World,
			followType = EffectConst.FollowType.Global,
			duration = fadeoutTime,
			loadCallback = function(effectItem)
				effectItem:ExecuteGhostEffectSet(fadeoutTime, alpha)
			end,
			endCallback = function(effectItem)
				local effectId = effectItem.effectId

				for idx, id in ipairs(self.ghotEffects) do
					if id == effectId then
						table.remove(self.ghotEffects, idx)

						break
					end
				end
			end
		}
		local id = self:playEffect(ghostEffect, extInfo)

		table.insert(self.ghotEffects, id)

		return id
	end

	return 0
end

function ClientEffectComponent:playScreenEffect(resId, duration)
	if self ~= pg.pawn then
		return
	end

	self.logger:debug("playScreenEffect", resId)
	facade:SendMessageCommand(MessageName.PLAY_SCREEN_EFFECT, resId)

	if duration > 0 then
		self:addTimer(duration, function()
			self:stopScreenEffect(resId)
		end)
	end
end

function ClientEffectComponent:stopScreenEffect(resId)
	self.logger:debug("stopScreenEffect", resId)
	facade:SendMessageCommand(MessageName.STOP_SCREEN_EFFECT, resId)
end

function ClientEffectComponent:setNightShine()
	local configData = self:getConfigData() or {}

	if configData.enableNightShine ~= nil then
		local enable = configData.enableNightShine and true or false

		if pg.timePeriod == Const.TimePeriod.Day or pg.timePeriod == Const.TimePeriod.Morning or pg.timePeriod == Const.TimePeriod.Dusk then
			enable = false
		end

		local shaderView = self.eModel.shaderView

		if shaderView then
			shaderView:SwitchEmissionColor(enable)
		end
	end
end

function ClientEffectComponent:setShinyStyle()
	if PetTransmogUtils.isTemplateTransmogable(self.templateId) then
		return
	end

	if self.playShinnyPreset then
		self:playShinnyPreset()
	end
end

function ClientEffectComponent:playShaderEffect(effectKey)
	local cfg = ShaderEffectData[effectKey]

	if not cfg then
		self.logger:error("playShaderEffect: 未配置的 shader 特效 key = %s", tostring(effectKey))

		return
	end

	local shaderView = self.eModel and self.eModel.shaderView

	if not shaderView or not cfg.recipeName then
		return
	end

	local share = self.shaderEffectShare

	if not share then
		share = ShaderEffectShareData.create()
		self.shaderEffectShare = share
	end

	share.recipeName = cfg.recipeName
	share.presetName = cfg.presetName or ""
	share.duration = cfg.duration or 0
	share.disableWhenFinished = cfg.disableWhenFinished and 1 or 0
	share.changeMatResId = cfg.changeMatResId or ""
	share.startValue = cfg.startValue or 0
	share.endValue = cfg.endValue or 0
	share.border = cfg.border or 0
	share.loopCnt = cfg.loopCnt or 0

	local pos = cfg.pos

	if pos then
		share.vec0 = {
			pos.x or pos[1] or 0,
			pos.y or pos[2] or 0,
			pos.z or pos[3] or 0
		}
	else
		share.vec0 = {
			0,
			0,
			0
		}
	end

	share.floatParam0 = cfg.height or cfg.floatParam0 or 0
	share.isWorldPosition = cfg.isWorldPosition and 1 or 0

	shaderView:PlayShaderEffect(share.shell)
end

function ClientEffectComponent:stopShaderEffect(effectKey, complete)
	local cfg = ShaderEffectData[effectKey]

	if not cfg then
		self.logger:error("stopShaderEffect: 未配置的 shader 特效 key = %s", tostring(effectKey))

		return
	end

	local shaderView = self.eModel and self.eModel.shaderView

	if shaderView then
		shaderView:StopShaderEffect(cfg.stopKey or cfg.recipeName, complete or false)
	end
end

function ClientEffectComponent:trySetEnemyState()
	if not Utils.isPetPuppet(self) and not Utils.isPlayer(self) and not Utils.isNpc(self) then
		return
	end

	self:stopEffect(EffectConst.ENEMY_CIRCLE_EFFECT_RES)
	self:stopEffect(EffectConst.PARTNER_CIRCLE_EFFECT_RES)
	self:stopEffect(EffectConst.SELF_CIRCLE_EFFECT_RES)

	if pg.me and pg.me.space then
		local showCampCircle = SceneData[pg.me.space.sceneId].showCampCircle

		if showCampCircle == nil then
			return
		end

		if showCampCircle[0] and (Utils.isPeopleNpc(self) or Utils.isPlayer(self)) then
			self:setCampEffect(showCampCircle[0])

			return
		end

		if showCampCircle[1] and (Utils.isPetNpc(self) or Utils.isPetPuppet(self)) then
			self:setCampEffect(showCampCircle[1])

			return
		end
	end
end

function ClientEffectComponent:setCampEffect(showCampCircle)
	if showCampCircle[1] and showCampCircle[1] ~= "" and (self.isMainPlayer or self.isMainPet) then
		self:playEffect(EffectConst.CIRCLE_EFFECT[showCampCircle[1]], {
			scale = self.bodySize or 1
		})

		return
	end

	if Utils.isPartner(pg.me, self) then
		if showCampCircle[2] and showCampCircle[2] ~= "" and Utils.isTeamPlayerOrPet(self) then
			self:playEffect(EffectConst.CIRCLE_EFFECT[showCampCircle[2]], {
				scale = self.bodySize or 1
			})
		elseif showCampCircle[3] and showCampCircle[3] ~= "" and not Utils.isTeamPlayerOrPet(self) then
			self:playEffect(EffectConst.CIRCLE_EFFECT[showCampCircle[3]], {
				scale = self.bodySize or 1
			})
		end

		return
	end

	if showCampCircle[4] and showCampCircle[4] ~= "" and Utils.isEnemy(pg.me, self) then
		self:playEffect(EffectConst.CIRCLE_EFFECT[showCampCircle[4]], {
			scale = self.bodySize or 1
		})
	end
end

function ClientEffectComponent:EVENT_OnEnterVehicle(vehicle, seatId)
	self:stopSelfCircleEffect()
end

function ClientEffectComponent:EVENT_OnExitVehicle(vehicle, seatId)
	self:playSelfCircleEffect()
end

function ClientEffectComponent:stopSelfCircleEffect()
	self:stopEffect(EffectConst.ENEMY_CIRCLE_EFFECT_RES)
	self:stopEffect(EffectConst.PARTNER_CIRCLE_EFFECT_RES)
	self:stopEffect(EffectConst.SELF_CIRCLE_EFFECT_RES)
end

function ClientEffectComponent:playSelfCircleEffect()
	self:trySetEnemyState()
end

function ClientEffectComponent:refreshEmitterIntensity()
	if self.space and self.staticId and self.staticId ~= 0 then
		local sceneEntityData = SceneUtils.getSceneEntityData(self.space.sceneId, self.space.id)
		local tEntityData = sceneEntityData[self.staticId]
		local intensity = (tEntityData or EMPTY_TABLE).intensity

		if intensity and intensity > 0 then
			self.eModel:SetEmitterIntensity(Const.COMPONENT_INDEX_EFFECT, intensity)
		end
	end
end

function ClientEffectComponent:playSBCutScene(resId, pos, rot, overrideState)
	rot = Quaternion.Euler(rot[1], rot[2], rot[3])

	self:setVisible(ClientConst.MODEL_VISIBLE_KEY.CUTSCENE_SELF, false)

	local extraData = ClientAbilityUtils.getSkillExCutSceneExtraData(self, overrideState, false)

	function extraData.endCallback()
		self:setVisible(ClientConst.MODEL_VISIBLE_KEY.CUTSCENE_SELF, true)
	end

	pg.game.cutscene:playCutscene(resId, resId, pos, rot, -1, false, extraData)
end

function ClientEffectComponent:EVENT_EnterScene()
	self:_tryPlayBornEffect()
end

function ClientEffectComponent:EVENT_OnAnimatorReady()
	self:_tryPlayBornEffect()
end

function ClientEffectComponent:EVENT_OnModelVisibleChange(visible)
	if visible then
		self:_tryPlayBornEffect()
	end
end

function ClientEffectComponent:_tryPlayBornEffect()
	if not self.pendingBornEffect or self.isDestroyed or not self.space or not self.isInScene or not self.eModel then
		return
	end

	if self.active == false or self.visible == false then
		return
	end

	local modelView = self.eModel.modelModelView

	if IsNil(modelView) or not modelView:IsAnimatorRead() then
		return
	end

	self.pendingBornEffect = nil

	self:_playBornEffect()
end

function ClientEffectComponent:_playBornEffect()
	local bornEffect = self:getConfigData().bornEffect

	if self.staticId and self.staticId ~= 0 then
		local sceneEntityData = SceneUtils.getSceneEntityData(self.space.sceneId, self.space.id)
		local sceneEntityInfo = sceneEntityData[self.staticId] or {}
		local sceneBornEffect = sceneEntityInfo.bornEffect

		if not string.isNilOrEmpty(sceneBornEffect) then
			bornEffect = sceneBornEffect
		end
	end

	if not string.isNilOrEmpty(bornEffect) then
		self:playEffect(bornEffect)
	end
end

function ClientEffectComponent:playPerformRecorder(resId, offset, bindEntity, callback)
	self.eModel:PlayPerformRecorderEffect(Const.COMPONENT_INDEX_EFFECT, resId, offset, bindEntity, callback)
end

function ClientEffectComponent:addReplaceEffKeys(key, replaceMap)
	if not key or not replaceMap then
		return
	end

	if self.effReplaceMap[key] then
		return
	end

	self.effReplaceMap[key] = replaceMap

	if self.eModel then
		self.eModel:AddReplaceEffKeys(Const.COMPONENT_INDEX_EFFECT, key)
	end

	EffectManager.AddReplacedEffectMap(key, replaceMap)
end

function ClientEffectComponent:removeReplaceEffKeys(key)
	if not key then
		return
	end

	if not self.effReplaceMap[key] then
		return
	end

	self.effReplaceMap[key] = nil

	if self.eModel then
		self.eModel:RemoveReplaceEffKeys(Const.COMPONENT_INDEX_EFFECT, key)
	end
end

return ClientEffectComponent
