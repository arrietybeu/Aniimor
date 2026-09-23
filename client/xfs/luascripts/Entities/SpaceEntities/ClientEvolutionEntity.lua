-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientEvolutionEntity.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local ClientVirtualEntity = require("Entities.ClientVirtualEntity")
local ClientConst = require("Const.ClientConst")
local MessageName = require("Const.MessageName")
local ClientModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelComponent")
local ClientModelTransmogComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelTransmogComponent")
local PetData = require("Data.pet_data")
local Const = require("Common.Const.Const")
local TaCharParamData = require("Data.ta_char_param_data")
local PlayableConst = require("Common.Const.PlayableConst")
local RigidbodyData = require("Data.rigidbody_data")
local EvolutionConst = require("Common.Const.EvolutionConst").PetEvolution
local ClientEvolutionEntity = Class.Class("ClientEvolutionEntity", ClientVirtualEntity)
local ClientVirtualComponents = {
	ClientModelComponent,
	ClientModelTransmogComponent
}

Class.AddComponents(ClientEvolutionEntity, ClientVirtualComponents)

function ClientEvolutionEntity:postInitializeComponents()
	ClientEvolutionEntity.super.postInitializeComponents(self)

	self.eModel.isMainAuthority = true
end

function ClientEvolutionEntity:setEvolutionScene(evolutionScene)
	self.evolutionScene = evolutionScene
end

function ClientEvolutionEntity:onModelRefreshed()
	if self._evolutionVisible == false then
		self:setModelLayer(ClientConst.LayerDefine.LAYER_DEFAULT)
	else
		self:setModelLayer(self._presentationLayer or ClientConst.LayerDefine.LAYER_CUTSCENE)
	end

	ClientEvolutionEntity.super.onModelRefreshed(self)
	facade:SendMessageCommand(MessageName.ON_MODEL_REFRESHED, self.id)
end

function ClientEvolutionEntity:setEvolutionAvatar(entityInfo, presentationOptions)
	self._presentationLayer = presentationOptions and presentationOptions.targetLayer or ClientConst.LayerDefine.LAYER_CUTSCENE
	self._evolutionVisible = nil
	self.inSoulEggSystem = entityInfo and entityInfo.inSoulEggSystem
	self.templateId = entityInfo.templateId
	self.label = entityInfo.label
	self.shinyStyle = entityInfo.shinyStyle
	self.gender = entityInfo.gender
	self.petInfo = entityInfo
	self.evolutionInfo = entityInfo
	self.isIgnoreEffectLod = true

	local petData = PetData[self.templateId]

	self:setConfigData(petData)
	self:refreshAppearance()
end

function ClientEvolutionEntity:refreshAppearance()
	if not self.evolutionInfo then
		ClientEvolutionEntity.super.refreshAppearance(self)

		return
	end

	local eModel = self.eModel
	local petData = PetData[self.templateId]
	local ClientModelUtils = require("Utils.ClientModelUtils")

	if eModel then
		local modelView = eModel.modelModelView
		local extraData = ClientModelUtils.getModelExtraInfo(petData, self.label or 0, self.gender, false, nil, self.evolutionInfo)

		self:postComponentMethod("EVENT_OnMergeAppearanceData", petData, extraData)
		ClientModelUtils.applyModelAppearance(modelView.modelInfo, petData, extraData)
		ClientModelUtils.applyAnimController(self, eModel, petData)
		modelView:RefreshModels()
		self:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)
		self:setModelLayer(self._presentationLayer)

		for _, effectInfo in ipairs(extraData.attachEffects or {}) do
			effectInfo.layer = self._presentationLayer
		end

		self:attachBaseEffects(extraData.attachEffects, self.isIgnoreEffectLod)
		self:refreshModelScale()
	end
end

function ClientEvolutionEntity:setEvolutionVisible(visible)
	if self.eModel == nil then
		return
	end

	self._evolutionVisible = visible

	self.eModel.modelShaderView:SetVisibleByMaterial(visible)

	if not visible then
		self:setModelLayer(ClientConst.LayerDefine.LAYER_DEFAULT)
		self:hideEffect()
	else
		self:setModelLayer(self._presentationLayer)
		self:showEffect()
	end
end

function ClientEvolutionEntity:setVEGShowTimer(timer, effectName, duration, offsetY, boder)
	local _, myPosY, _ = self.eModel:GetPositionAgentPosEx()

	self:addTimer(timer, function()
		self:setCameraOffset(offsetY)
		self:playEffect(effectName, {
			loadCallback = function(effectItem)
				if effectItem then
					self:setEvolutionVisible(true)
				end
			end
		})
	end)
end

function ClientEvolutionEntity:setVEGCloseTimer(timer, effectName, newEntity, boder)
	local _, myPosY, _ = self.eModel:GetPositionAgentPosEx()

	self:addTimer(timer, function()
		self:playEffect(effectName)
	end)
end

function ClientEvolutionEntity:setDissolveEffect(timer, resName, dissolveStartPos, startValue, endValue, border, duration, voxelParam, visible, speed)
	self:addTimer(timer, function()
		self.eModel.modelShaderView:TweenEvolutionDissolveEffect(dissolveStartPos, resName, startValue, endValue, duration, border, voxelParam, speed, function()
			if visible then
				self:setEvolutionVisible(true)
			end
		end, function()
			if not visible then
				self:setEvolutionVisible(false)
			end
		end)
	end)
end

function ClientEvolutionEntity:playDelayAnimation(timer, animName, needAutoTransition)
	self:addTimer(timer, function()
		local state = self:playAnimation(animName)

		if needAutoTransition then
			state:AddAutoTransition(0)
		end
	end)
end

function ClientEvolutionEntity:playPresentationDissolve(visible, onStarted, onComplete)
	local cfg = visible and EvolutionConst.EvolutionDissolveNewMeshAnim or EvolutionConst.EvolutionDissolveOldMeshAnim
	local height = self:getEvolutionHeight()
	local baseHeight = EvolutionConst.TweenEvolutionDissolveHeight
	local border = cfg.border
	local startValue, endValue = baseHeight, baseHeight + height + border

	if visible then
		startValue, endValue = baseHeight + height + math.max(border, 0), baseHeight

		if border == 0 then
			border = -height
		end
	end

	self.eModel.modelShaderView:TweenEvolutionDissolveEffect(Vector3(0, baseHeight + height, 0) + EvolutionConst.Pos, cfg.resName, startValue, endValue, cfg.duration, border, cfg.voxelParam, cfg.speed or 1, onStarted, onComplete)
end

function ClientEvolutionEntity:stopPresentationDissolve()
	local shaderView = self.eModel.modelShaderView

	shaderView:StopPreset("CharacterEdgeDissolve")
	shaderView:StopPreset("CharacterWireFrameDissolve")
	shaderView:StopCaptureDissolveEffect()
end

function ClientEvolutionEntity:playDelayCfgAnimation(timer, cfg)
	self:addTimer(timer, function()
		self:playCfgAnimation(cfg)
	end)
end

function ClientEvolutionEntity:playDelaySoundEvent(time, soundEventName)
	self:addTimer(time, function()
		self:playSoundEvent(soundEventName)
	end)
end

function ClientEvolutionEntity:setCameraOffset(offsetY)
	local cameraOffset = Vector3.New(0, offsetY, 0)
end

function ClientEvolutionEntity:showDelay(time, offsetY)
	self:addTimer(time, function()
		self:setCameraOffset(offsetY)
		self:setEvolutionVisible(true)
	end)
end

function ClientEvolutionEntity:getEvolutionHeight()
	local prefabResID = PetData[self.evolutionInfo.templateId].prefabResID

	if TaCharParamData[prefabResID] and TaCharParamData[prefabResID].aabbExtent then
		return TaCharParamData[prefabResID].aabbExtent[2] * 2
	end

	return RigidbodyData[PetData[self.evolutionInfo.templateId].rigidbody].height
end

function ClientEvolutionEntity:getEvolutionId()
	return self.evolutionInfo.id
end

function ClientEvolutionEntity:playEggIncubate(duration)
	local templateId = self:getConfigData().petPrototypeId or 0

	ClientEffectUtils.PlayPreset(self, "HatchSilhouette", duration, true)
end

function ClientEvolutionEntity:preloadAnimations(animations)
	if self:hasEModelComponent(Const.COMPONENT_IDX_PLAYABLE) and animations then
		local keys = {}

		for i = 1, #animations do
			local aniName = animations[i]

			if PlayableConst[aniName] ~= nil then
				table.insert(keys, PlayableConst[aniName])
			end
		end

		self.eModel:PreloadAnimations(Const.COMPONENT_IDX_PLAYABLE, keys)
	end
end

function ClientEvolutionEntity:getEntityOffsetY()
	return self:getHeight() * EvolutionConst.CameraOffset.multi + EvolutionConst.CameraOffset.add
end

function ClientEvolutionEntity:getEntityCameraTargetOffset()
	return self:getHeight() * EvolutionConst.CameraPivotOffset.multi + EvolutionConst.CameraPivotOffset.add
end

return ClientEvolutionEntity
