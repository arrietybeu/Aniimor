-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientModelComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local ClientUtils = require("Utils.ClientUtils")
local ClientAbilityUtils = require("Utils.ClientAbilityUtils")
local Time = require("Core.Common.Time")
local EffectConst = require("Const.EffectConst")
local RigidbodyData = require("Data.rigidbody_data")
local ClientModelUtils = require("Utils.ClientModelUtils")
local PlayableEventConst = require("Const.PlayableEventConst")
local VoxelConst = require("Common.Const.VoxelConst")
local AddressDataConst = require("Const.AddressDataConst")
local SysConfigData = require("Data.sys_config_data")
local AudioConst = require("Const.AudioConst")
local MessageName = require("Const.MessageName")
local EventConst = require("Common.Const.EventConst")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local ClientModelComponent = class.Component("ClientModelComponent")

function ClientModelComponent:ctor()
	self.modelSwitchSyncEnts = {}
end

function ClientModelComponent:start()
	if self.eventEmitter then
		self.eventEmitter:addEventListener(PlayableEventConst.addCollideMinRadius, function()
			if self == pg.game.camera.targetPlayer then
				pg.game.camera.playerCameraMode.defaultCamera:addCollideMinRadius()
			end
		end)
	end

	self:refreshCameraHitCheckHeight()
end

function ClientModelComponent:init(dict)
	return true
end

function ClientModelComponent:EVENT_OnModelScaleChanged()
	self:refreshCameraHitCheckHeight()
end

function ClientModelComponent:EVENT_AddEComponent()
	if not self:hasEModelComponent(Const.COMPONENT_IDX_ITEM) then
		self:addEModelComponent(Const.COMPONENT_INDEX_MODEL)

		if pg.game.seamless:isModelViewLoadDisable(self) then
			self.eModel:EnableModelViewLoad(Const.COMPONENT_INDEX_MODEL, false)
		end
	end

	if self.isMainPet or self.isMainPlayer then
		self.eModel:AddShadowComp(ClientConst.ShadowPriority.MainPetPlayer)
	end
end

function ClientModelComponent:onAnimatorReady()
	self:postComponentMethod("EVENT_OnAnimatorReady")

	if self.onAnimatorReadyCallback then
		local cb = self.onAnimatorReadyCallback

		self.onAnimatorReadyCallback = nil

		cb(self)
	end
end

function ClientModelComponent:onSkeletonLoaded()
	self:postComponentMethod("onSkeletonLoaded")

	if self.onSkeletonLoadedCallback then
		self.onSkeletonLoadedCallback()

		self.onSkeletonLoadedCallback = nil
	end

	if self.actorType == Const.ACTOR_TYPE_PET or self.isMainPlayer then
		facade:SendMessageCommand(MessageName.ON_PAWN_SKELETON_LOADED)
	end

	facade:SendMessageCommand(MessageName.ON_SKELETON_LOADED, self.id)
end

function ClientModelComponent:onSkeletonUnloaded()
	self:postComponentMethod("onSkeletonUnloaded")
end

function ClientModelComponent:onAnimatorChanged()
	return
end

function ClientModelComponent:OnPlayableEvent(eventName)
	self.eventEmitter:emit(eventName)
end

function ClientModelComponent:destroy()
	if self._delaySetGrassTimer then
		self:removeTimer(self._delaySetGrassTimer)

		self._delaySetGrassTimer = nil
	end

	self.modelSwitchSyncEnts = {}

	self:ghostRemove()
end

function ClientModelComponent:setModelScale(modelScaleKey, modelScale)
	self.modelScaleMap = self.modelScaleMap or {}

	if modelScale == 1 or modelScale == nil then
		self.modelScaleMap[modelScaleKey] = nil
	else
		self.modelScaleMap[modelScaleKey] = modelScale
	end

	self:refreshModelScale()
end

function ClientModelComponent:refreshCameraHitCheckHeight()
	local scale = self.curModelScale or 1
	local modelHeight = self:getHeight() * scale + (SysConfigData.toplogoOffset or 0)

	if EnableBotTest then
		return
	end

	self.eModel.cameraHitCheckHeight = modelHeight
end

function ClientModelComponent:EVENT_OnModelRefreshed()
	ClientModelUtils.applyModelSwitchTag(self)

	if self.isExtraTempPet and self:isExtraTempPet() then
		local player = self:getMasterEntity()

		if player.appearPresetDuration and player.loopPresetDuration then
			ClientEffectUtils.PlayPreset(self, AbilitySettingGlobalConstData.extraTempPetLoopPreset, player.loopPresetDuration, true, 0)
			ClientEffectUtils.PlayPreset(self, AbilitySettingGlobalConstData.extraTempPetAppearPreset, player.appearPresetDuration, true, 0)

			player.appearPresetDuration = nil
			player.loopPresetDuration = nil

			if player.appearExtraTempPetCallback then
				player.appearExtraTempPetCallback()
			end

			player.appearExtraTempPetCallback = nil

			pg.global.cameraMgr:AddVolumeEffect(10, AddressDataConst.ROGUE_TRANSFORM_SCREEN_LOOP, -1)
		end

		return
	end

	local configData = self:getConfigData()
	local preset = configData.preset
	local presetTime = configData.presetTime or 0
	local enablePresetBySubstr = configData.enablePresetBySubstr

	if preset then
		local disableWhenFinish = configData.disablePresetWhenFinish

		if disableWhenFinish == nil then
			disableWhenFinish = false
		end

		if not enablePresetBySubstr then
			ClientEffectUtils.PlayPreset(self, preset, presetTime, ToBool(disableWhenFinish), 0)
		else
			ClientEffectUtils.PlayPresetWithFilterMark(self, preset, presetTime, ToBool(disableWhenFinish), enablePresetBySubstr)
		end
	else
		self:playFadeInEffect()
	end

	self:refreshFootPrintVisible()

	if self.eventEmitter then
		self.eventEmitter:emit(EventConst.ENTITY_MODEL_REFRESHED)
	end
end

function ClientModelComponent:getBaseModelScale()
	return self.modelScaleMap[ClientConst.MODEL_SCALE_KEY.DEFAULT] or 1
end

function ClientModelComponent:getModelScale()
	if not self.modelScaleMap then
		return 1
	end

	local modelScale = 1

	for _, scale in pairs(self.modelScaleMap) do
		modelScale = modelScale * scale
	end

	return modelScale
end

function ClientModelComponent:getRealHeight()
	local modelHeight = self:getConfigData().modelHeight

	if not modelHeight then
		return 1.65
	end

	return modelHeight * (self.curModelScale or 1)
end

function ClientModelComponent:getCapsuleScale()
	if not self.modelScaleMap then
		return 1
	end

	local modelScale = 1

	for _, key in ipairs(ClientConst.CAPSULE_SCALE_KEYS) do
		local scale = self.modelScaleMap[key]

		if scale then
			modelScale = modelScale * scale
		end
	end

	return modelScale
end

function ClientModelComponent:refreshModelScale()
	if self.eModel then
		local modelScale = self:getModelScale()

		self:setScaleNumber(modelScale)

		if self.refreshCapsuleScale then
			local capsuleScale = self:getCapsuleScale()

			self:refreshCapsuleScale(capsuleScale)
		end
	end
end

function ClientModelComponent:getCommonMountPosition(mountData)
	if not self.eModel or IsNil(self.eModel.modelView) then
		return self:getPosition()
	end

	return self.eModel.skeletonView:GetCommonMountPos(mountData.bone, mountData.position or Vector3.zero, mountData.rotation or Vector3.zero, mountData.scale or Vector3(1, 1, 1))
end

function ClientModelComponent:refreshModelSwitchTag()
	if self.eModel then
		self.eModel:ApplySwitchTag(Const.COMPONENT_INDEX_MODEL, self.modelSwitchGroup, self.modelSwitchTag, 0)
	end
end

function ClientModelComponent:playModelScaleAnim(targetScale, duration, curve)
	if self.eModel then
		local modelView = self.eModel.modelView

		modelView:PlayModelScaleAnim(targetScale, duration, curve)
	end
end

function ClientModelComponent:playModelScaleXYZAnim(targetScale, duration, curveX, curveY, curveZ)
	if self.eModel then
		local modelView = self.eModel.modelView

		modelView:PlayModelScaleAnim(targetScale, duration, curveX or "", curveY or "", curveZ or "")
	end
end

function ClientModelComponent:setModelAnimSwitchTag(switchTag)
	self.eModel:OverrideSwitchTag(Const.COMPONENT_INDEX_MODEL, switchTag)

	for ent, _ in pairs(self.modelSwitchSyncEnts) do
		if ent.eModel then
			ent.eModel:OverrideSwitchTag(Const.COMPONENT_INDEX_MODEL, switchTag)
		end
	end
end

function ClientModelComponent:setModelSwitchTag(groupKey, switchTag)
	if not groupKey or type(groupKey) ~= "number" then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:debug("setModelSwitchTag groupKey invalid", groupKey)
		end

		return
	end

	self.modelSwitchGroup = groupKey
	self.modelSwitchTag = switchTag

	self:refreshModelSwitchTag()

	for ent, _ in pairs(self.modelSwitchSyncEnts) do
		if not ent.eModel then
			self.modelSwitchSyncEnts[ent] = nil
		else
			ent:setModelSwitchTag(groupKey, switchTag)
		end
	end
end

function ClientModelComponent:addModelSwitchSyncEnt(ent)
	self.modelSwitchSyncEnts[ent] = true

	ent:setModelSwitchTag(self.modelSwitchGroup, self.modelSwitchTag)

	if self.transmogData then
		for entity, _ in pairs(self.modelSwitchSyncEnts) do
			entity:setTransmogData(self.transmogData, self.transmogShinyEffects, self.transmogSignature)
			ClientAbilityUtils.refreshCutSceneAppearance(self, entity)
		end
	end
end

function ClientModelComponent:setModelOpacity(opacity)
	if self.eModel then
		local modelView = self.eModel.modelView

		modelView:SetOpacity(opacity)
	end
end

function ClientModelComponent:setVisibleWithDissolveEffect(key, blendTime, visible)
	self.setHideTimers = self.setHideTimers or {}

	local timerId = self.setHideTimers[key]

	if visible then
		self:setVisible(key, visible)

		if timerId then
			self:removeTimer(timerId)

			self.setHideTimers[key] = nil

			self:playSwitchAppearEffect(blendTime)
		end
	elseif blendTime > 0 then
		if timerId then
			return
		end

		self.setHideTimers[key] = self:addTimer(blendTime, function()
			self:setVisible(key, false)
		end)

		self:playSwitchDissolveEffect(blendTime, function()
			if self.setHideTimers[key] then
				self:setVisible(key, false)
			end
		end)
	else
		self:setVisible(key, visible)
	end
end

function ClientModelComponent:overrideMaterial(matName)
	if self.eModel then
		matName = matName or ""

		self.eModel.shaderView:SetOverrideMaterial(matName)
	end
end

function ClientModelComponent:replaceMaterial(oldMatName, matName)
	if self.eModel then
		oldMatName = oldMatName or ""
		matName = matName or ""

		self.eModel.shaderView:ReplaceMaterial(oldMatName, matName)
	end
end

function ClientModelComponent:changeAdditionMaterial(matName)
	if self.eModel then
		self.eModel.shaderView:ChangeEffectMaterial(matName)
	end
end

function ClientModelComponent:playHitRippleEffect(presetName, hitPos)
	if self.eModel then
		self.eModel.shaderView:SetShaderHitRippleEffect(presetName, hitPos)
	end
end

function ClientModelComponent:playPlayerDeadDissolveEffect(duration, vegOffset)
	local defaultDuration = SysConfigData.playerDeadDissolveEffectDuration or 3.2
	local defaultBorder = SysConfigData.playerDeadDissolveEffectBorder or 0.35

	duration = duration or defaultDuration
	vegOffset = vegOffset or 0.2

	self:playSwitchDissolveVegEffect(0.5, vegOffset)
	self:playSoundEvent("SFX_3C_Player_Die_Disperse")

	local globalDissolveStartOffset = 10
	local dissolveEndOffset = 10

	if self.eModel then
		local dissolveStartPosition = Vector3(0, 0, 0)
		local playerHeight = self:getHeight()

		dissolveStartPosition.x = -(dissolveStartPosition.x + playerHeight + globalDissolveStartOffset)

		local startValue = globalDissolveStartOffset
		local border = defaultBorder
		local endValue = playerHeight + globalDissolveStartOffset + dissolveEndOffset

		self.eModel.shaderView:TweenModelDissolveEffect(dissolveStartPosition, startValue, endValue, border, duration, function()
			if self.life == Const.LIFE_DEAD then
				self:stopAllAnimation()
				self:setVisible(ClientConst.MODEL_VISIBLE_KEY.PLAYER_DEAD, false)
			end
		end)
	end
end

function ClientModelComponent:playPetDeadDissolveEffect(duration)
	local defaultDuration = SysConfigData.playerDeadDissolveEffectDuration or 3.2
	local defaultBorder = SysConfigData.playerDeadDissolveEffectBorder or 0.35

	duration = duration or defaultDuration

	local globalDissolveStartOffset = 10
	local dissolveEndOffset = 10

	if self.eModel then
		local dissolveStartPosition = Vector3(0, 0, 0)
		local playerHeight = self:getHeight()

		dissolveStartPosition.z = -(dissolveStartPosition.z + playerHeight + globalDissolveStartOffset)

		local startValue = globalDissolveStartOffset
		local border = defaultBorder
		local endValue = playerHeight + globalDissolveStartOffset + dissolveEndOffset

		self.eModel.shaderView:TweenModelDissolveEffect(dissolveStartPosition, startValue, endValue, border, duration, nil)
	end
end

function ClientModelComponent:playTeleportDissolveEffect(duration, vegOffset, callback)
	if pg.game.map.banTeleportEffectFlag then
		pg.game.map.banTeleportEffectFlag = nil

		if callback then
			callback()
		end

		return
	end

	local defaultDuration = 0.6

	duration = duration or defaultDuration
	vegOffset = vegOffset or 0.2

	self:playSwitchDissolveVegEffect(0.5, vegOffset)
	self:playSoundEvent("SFX_3C_Player_Die_Disperse")
	self:playSwitchDissolveEffect(duration, callback)
end

function ClientModelComponent:playTeleportAppearEffect(duration, callback, offsetY)
	if pg.game.map.banTeleportEffectFlag then
		pg.game.map.banTeleportEffectFlag = nil

		if callback then
			callback()
		end

		return
	end

	self:playSwitchAppearEffect(duration, callback, offsetY)
end

function ClientModelComponent:playSwitchDissolveEffect(duration, callback, offsetY)
	if self:getConfigData().disableAppearDissolve then
		return
	end

	offsetY = offsetY or 0

	local globalOffsetY = 10

	if self.eModel then
		local dissolveStartPosition = Vector3(0, 0, 0)
		local playerHeight = self:getHeight() + offsetY

		dissolveStartPosition.y = dissolveStartPosition.y + playerHeight + globalOffsetY

		local startValue = globalOffsetY
		local border = playerHeight
		local endValue = playerHeight + globalOffsetY

		self.eModel.shaderView:TweenModelDissolveEffect(dissolveStartPosition, startValue, endValue, border, duration, callback)
	end
end

function ClientModelComponent:playSwitchDissolveSurfaceEffect(duration, callback, offsetY)
	if self:getConfigData().disableAppearDissolve then
		return
	end

	offsetY = offsetY or 0

	local globalOffsetY = 0

	if self.eModel then
		local dissolveStartPosition = Vector3(0, 0, 0)
		local playerHeight = self:getHeight() + offsetY

		dissolveStartPosition.y = 0

		local startValue = globalOffsetY
		local border = playerHeight
		local endValue = playerHeight + globalOffsetY

		self.eModel.shaderView:PlayDissolveSurfaceEffectPreset(EffectConst.PRESET_NAME.IDYLL_DISSLOVE_INVERSE_1, dissolveStartPosition, endValue, startValue, border, duration, nil, callback)
	end
end

function ClientModelComponent:playSwitchAppearEffectRefresh(duration, callback, offsetY)
	if self:getConfigData().disableAppearDissolve then
		return
	end

	self:playSwitchAppearEffect(duration, callback, offsetY, true)
end

function ClientModelComponent:playSwitchAppearEffect(duration, callback, offsetY, disableDissolve)
	if self:getConfigData().disableAppearDissolve then
		return
	end

	if Utils.isSupportPet(self) then
		return
	end

	local masterEntity = self.getMasterEntity and self:getMasterEntity()

	if Utils.isPlayer(masterEntity) and masterEntity:EXTRA_TEMP_PET_ST() then
		ClientEffectUtils.PlayPreset(self, AbilitySettingGlobalConstData.switchFromExtraTempPetPreset, 1, true)
		pg.global.cameraMgr:DelVolumeEffect(AddressDataConst.ROGUE_TRANSFORM_SCREEN_LOOP)

		return
	end

	offsetY = offsetY or 0
	disableDissolve = disableDissolve or false

	local globalOffsetY = 10

	if self.eModel then
		local dissolveStartPosition = Vector3(0, 0, 0)
		local playerHeight = self:getHeight() + offsetY

		dissolveStartPosition.y = dissolveStartPosition.y + playerHeight + globalOffsetY

		local border = playerHeight
		local startValue = playerHeight - 0.1 + globalOffsetY
		local endValue = globalOffsetY

		self.eModel.shaderView:TweenModelDissolveEffect(dissolveStartPosition, startValue, endValue, border, duration, callback, disableDissolve)
	end
end

function ClientModelComponent:playSwitchAppearSurfaceEffect(duration, callback, offsetY, isWorldPosition, disableDissolve)
	if self:getConfigData().disableAppearDissolve then
		return
	end

	offsetY = offsetY or 0
	isWorldPosition = isWorldPosition or false
	disableDissolve = disableDissolve or false

	local globalOffsetY = 0

	if self.eModel then
		local dissolveStartPosition = Vector3(0, 0, 0)
		local playerHeight = self:getHeight() + offsetY

		dissolveStartPosition.y = 0

		local border = playerHeight
		local startValue = playerHeight - 0.1 + globalOffsetY
		local endValue = globalOffsetY

		self.eModel.shaderView:PlayDissolveSurfaceEffectPreset(EffectConst.PRESET_NAME.IDYLL_DISSLOVE_INVERSE_2, dissolveStartPosition, startValue, endValue, border, duration, nil, callback, isWorldPosition, disableDissolve)
	end
end

function ClientModelComponent:playSwitchFresnelEffect()
	if self:getConfigData().disableAppearDissolve then
		return
	end

	if self.eModel then
		local inTime = 0.2
		local keepTime = 0.4
		local outTime = 0.1
		local color = Color(5.9, 11.8, 95.9, 1)
		local range = Vector4(0.29, 0.68, 0, 0)

		self.eModel.shaderView:TweenSwitchFresnelEffect(inTime, keepTime, outTime, color, range)
	end
end

function ClientModelComponent:playSupportPetFresnelEffect(enable)
	if self.eModel then
		local shaderView = self.eModel.modelShaderView

		if shaderView then
			if enable then
				shaderView:PlaySurfaceEffect("Eff_Parmon_assist_01", 3, false, -1)
			else
				ClientEffectUtils.StopPreset(self, "Eff_Parmon_assist_01")
			end
		end
	end
end

function ClientModelComponent:setFresnelPMEnable(enable, presetName)
	if self.eModel then
		self.eModel.shaderView:SetFresnelPMEnabled(enable, presetName)
	end
end

function ClientModelComponent:setMultiPassRenderEnable(enable)
	if self.eModel then
		self.eModel.shaderView:SetMultiPassRenderEnable(enable)
	end
end

function ClientModelComponent:playCaptureDissolveEffect(hitPos, duration, callback)
	local defaultDuration = 0.6

	duration = duration or defaultDuration

	if self.eModel then
		self.eModel.shaderView:PlayCaptureDissolveEffect(hitPos, AddressDataConst.CATCH_MAGIC_CUBE, duration, callback)
	end
end

function ClientModelComponent:playFadeInEffect()
	if not self.isFadeIn then
		return
	end

	self.isFadeIn = nil

	ClientEffectUtils.PlayPreset(self, EffectConst.PRESET_NAME.DITHERING_FADE_REVERSE, 1, true)
end

function ClientModelComponent:playFadeOutEffect(onComplete)
	if not self.isFadeOut then
		return
	end

	self.isFadeOut = false

	local ret, errors = ClientUtils.tryWithLogError(function()
		ClientEffectUtils.PlayPreset(self, EffectConst.PRESET_NAME.DITHERING_FADE, 1, false, 0, nil, nil, function()
			if self.isFadeOut == nil then
				return
			end

			self.isFadeOut = nil

			if onComplete then
				onComplete()
			end
		end)
	end)

	if not ret and onComplete then
		onComplete()
	end
end

function ClientModelComponent:setMaterialProperty(propName, propValue)
	if self.eModel then
		self.eModel.shaderView:SetMaterialProperty(propName, propValue)
	end
end

function ClientModelComponent:onFootStepDown()
	local weight = self.footprintSfxLevel

	if not weight then
		return
	end

	if type(weight) ~= "number" then
		return
	end

	local cd = self.footprintInterval

	if cd < 0 then
		return
	end

	local tick = self.footprintSfxSoundTick or 0
	local curt = self:getCurrScaledTime()

	if cd < curt - tick then
		self.footprintSfxSoundTick = curt
	else
		return
	end

	self:playFootStepSoundEvent(weight)
end

function ClientModelComponent:EVENT_OnCharacterStateChange(oldState, newState)
	self:refreshFootPrintVisible()
end

function ClientModelComponent:EVENT_ContactVoxelChanged(contactVoxel, voxelState)
	self:refreshFootPrintVisible()
	self:refreshGrassState(contactVoxel, voxelState)
end

function ClientModelComponent:EVENT_OnModelVisibleChange()
	self:refreshFootPrintVisible()
end

function ClientModelComponent:isPeripheralFootEffectBlocked()
	local master = self.getMasterEntity and self:getMasterEntity()
	local isMergedFormLinking = self.checkPetInControl and self:checkPetInControl() and master and master.isInLinkAnim

	return isMergedFormLinking or self.DEAD_ST and self:DEAD_ST() or self.SPECIAL_VEHICLE_RIDE_ST and self:SPECIAL_VEHICLE_RIDE_ST() or self.SWIM_ST and self:SWIM_ST() or self.FLY_ST and self:FLY_ST()
end

function ClientModelComponent:refreshFootPrintVisible()
	if self.voxelCustomData == nil then
		return
	end

	local camouflageVisible = not self.isCamouflage
	local enablePeripheralFootEffect = camouflageVisible and self.visible and not self:isPeripheralFootEffectBlocked()
	local showFootPrint = self:checkShowFootPrint() and enablePeripheralFootEffect

	self.eModel:SetNewFootPrefab(Const.COMPONENT_INDEX_MODEL, showFootPrint, enablePeripheralFootEffect)
end

function ClientModelComponent:checkShowFootPrint()
	return bit.band(VoxelConst.FootStepMaterialVal, self.voxelCustomData) ~= 0
end

function ClientModelComponent:refreshGrassState(contactVoxel, voxelState)
	if pg.pawn ~= self and not self.isMainPet then
		return
	end

	local inGrass = false

	if self.space and bit.band(contactVoxel, VoxelConst.VoxelMaterialDef.CustomGrass) ~= 0 then
		inGrass = true
	end

	if self._delaySetGrassTimer then
		self:removeTimer(self._delaySetGrassTimer)

		self._delaySetGrassTimer = nil
	end

	if inGrass ~= self.inGrass then
		if inGrass == false then
			self._delaySetGrassTimer = self:addTimer(SysConfigData.exitSneakDelayTime or 0.5, function()
				self:_innerSetGrassState(inGrass)
			end)
		else
			self:_innerSetGrassState(inGrass)
		end
	end
end

function ClientModelComponent:_innerSetGrassState(inGrass)
	self.inGrass = inGrass

	self:refreshFootPrintVisible()

	if pg.pawn == self then
		if self.inGrass then
			self:playSoundEvent(AudioConst.EVENT_AMB_STEALTH_LOOP)
		else
			self:playSoundEvent(AudioConst.EVENT_STOP_AMB_STEALTH_LOOP)
		end

		facade:sendMsgToUI(MessageName.HIGH_GRASS_STATE_CHANGE)
	end
end

function ClientModelComponent:CreateFootPrint(footType, footScale, isContinuousFootprints)
	return
end

function ClientModelComponent:applyImpulseOnTargets(shapeKind, centerOffsetXYZ, rotationOffset, shapeArgs, physicsImpulse)
	ClientUtils.handleModelImpulseEvent(self, shapeKind, centerOffsetXYZ, rotationOffset, shapeArgs, physicsImpulse)
end

function ClientModelComponent:ghostFollow()
	pg.game.social:addGhost(self)
end

function ClientModelComponent:ghostRemove()
	pg.game.social:removeGhost(self)
end

return ClientModelComponent
