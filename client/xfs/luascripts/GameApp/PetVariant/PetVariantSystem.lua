-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\PetVariant\\PetVariantSystem.lua

local ClientUtils = require("Utils.ClientUtils")
local Const = require("Common.Const.Const")
local PlayableConst = require("Common.Const.PlayableConst")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local AddressDataConst = require("Const.AddressDataConst")
local ClientConst = require("Const.ClientConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local TimerManager = require("Core.Timer.TimerManager")
local PetData = require("Data.pet_data")
local SystemBase = require("GameApp.Core.SystemBase")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local PetVariantEntity = require("GameApp.PetVariant.PetVariantEntity")
local PetVariantScene = require("GameApp.PetVariant.PetVariantScene")
local logger = LoggerManager.getLogger("PetVariantSystem")
local LOVE_ANIMATION_TOTAL_DURATION = 3
local HEART_BOOM_EFFECT_END_LEAD_TIME = 0.3
local PET_VARIANT_ANIM_START = "Behav_LoveStart"
local PET_VARIANT_ANIM_LOOP = "Behav_LoveLoop"
local PET_VARIANT_ANIM_END = "Behav_LoveEnd"
local PET_VARIANT_END_ANIM = "Behav_HappyLoop"
local HUD_HIDE_KEY = "PetVariant"
local TIMELINE_PRESENTATION_DELAY_FRAME = 2
local PetVariantSystem = Class.LightClass("PetVariantSystem", SystemBase)

function PetVariantSystem:onCtor()
	PetVariantSystem.super.onCtor(self)

	self._isPlaying = false
end

function PetVariantSystem:startVariant(selfPetInfo, friendPetInfo, position, outputCamera, timelineFinishedCallback)
	self:finishVariant()

	local selfPetInfoValid = self:_isPetInfoValid(selfPetInfo)
	local friendPetInfoValid = self:_isPetInfoValid(friendPetInfo)

	if not selfPetInfoValid or not friendPetInfoValid then
		logger:error("startVariant invalid pet info, self=%s, friend=%s", inspect(selfPetInfo, {
			depth = 2
		}), inspect(friendPetInfo, {
			depth = 2
		}))

		return false
	end

	if IsNil(outputCamera) then
		logger:error("startVariant missing output camera")

		return false
	end

	local selfPetTransmogRefreshed, friendPetTransmogRefreshed

	self.selfPetEntity, selfPetTransmogRefreshed = self:_createPetEntity(selfPetInfo)
	self.friendPetEntity, friendPetTransmogRefreshed = self:_createPetEntity(friendPetInfo)

	if not self.selfPetEntity or not self.friendPetEntity then
		logger:error("startVariant failed to create pet entities")
		self:finishVariant()

		return false
	end

	self._isPlaying = true
	self.position = position
	self.outputCamera = outputCamera
	self.timelineFinishedCallback = timelineFinishedCallback
	self._readyPetEntities = {}
	self._loveAnimationFinishedEntities = {}
	self._heartBoomEffectTimerId = nil
	self._happyLoopStarted = false

	self:_setHudHidden(true)
	self:_waitForPetAnimator(self.selfPetEntity, selfPetTransmogRefreshed)
	self:_waitForPetAnimator(self.friendPetEntity, friendPetTransmogRefreshed)

	return self._isPlaying
end

function PetVariantSystem:_setHudHidden(hidden)
	local ui = pg.global.ui
	local hudCtrl = ui and ui.hudV2

	if hudCtrl then
		hudCtrl:setUIHide(HUD_HIDE_KEY, hidden)
	end

	local mobileOperateCtrl = ui and ui.mobileOperate

	if mobileOperateCtrl then
		mobileOperateCtrl:setUIHide(HUD_HIDE_KEY, hidden)
	end

	self._hudHidden = hidden or nil
end

function PetVariantSystem:_isPetInfoValid(petInfo)
	return petInfo ~= nil and PetData[petInfo.templateId] ~= nil
end

function PetVariantSystem:_createPetEntity(petInfo)
	local initInfo = {
		syncLoad = true,
		templateId = petInfo.templateId,
		label = petInfo.label,
		shinyStyle = petInfo.shinyStyle,
		gender = petInfo.gender,
		petInfo = petInfo
	}
	local entity = PetVariantEntity.new()

	entity:init(initInfo)
	entity:postInit(initInfo)
	entity:start()
	entity:setModelLayer(ClientConst.LayerDefine.LAYER_CUTSCENE)
	entity:setDisableEffectLod(true)
	entity:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)
	entity:setRendererLod(0)

	local transmogRefreshed = PetTransmogUtils.applySchemeTransmog(entity, petInfo.templateId, petInfo.selectTransmogScheme, true)

	return entity, transmogRefreshed
end

function PetVariantSystem:_waitForPetAnimator(entity, transmogRefreshed)
	if transmogRefreshed then
		entity.modelLoadedCallback = CallbackHandler(self, "_onPetModelLoaded", entity)

		return
	end

	self:_runWhenPetAnimatorReady(entity)
end

function PetVariantSystem:_onPetModelLoaded(entity)
	entity.modelLoadedCallback = nil

	self:_runWhenPetAnimatorReady(entity)
end

function PetVariantSystem:_runWhenPetAnimatorReady(entity)
	if not self._isPlaying or entity.destroyed or not entity.eModel then
		return
	end

	local modelView = entity.eModel.modelModelView

	if NotNil(modelView) and modelView:IsAnimatorRead() then
		self:_onPetAnimatorReady(entity)

		return
	end

	entity.onAnimatorReadyCallback = CallbackHandler(self, "_onPetAnimatorReady", entity)
end

function PetVariantSystem:_onPetAnimatorReady(entity)
	entity.onAnimatorReadyCallback = nil

	if not self._isPlaying or entity.destroyed then
		return
	end

	self._readyPetEntities[entity] = true

	local allPetsReady = self._readyPetEntities[self.selfPetEntity] and self._readyPetEntities[self.friendPetEntity]

	if not allPetsReady then
		return
	end

	self:_startVariantScene()
end

function PetVariantSystem:_startVariantScene()
	if not self._isPlaying or self.scene then
		return
	end

	self.scene = PetVariantScene.new(AddressDataConst.PET_VARIANT_TIMELINE, self.position, Quaternion.identity, self.outputCamera)

	local timelineFinishedCallback = self.timelineFinishedCallback

	self.timelineFinishedCallback = nil

	local started = self.scene:startPlay(CallbackHandler(self, "_onSceneReady"), timelineFinishedCallback)

	if not started then
		logger:error("startVariant failed to load timeline")
		self:finishVariant()
	end
end

function PetVariantSystem:_onSceneReady(scene)
	local selfAnchor, friendAnchor = scene:getPetAnchors()

	if IsNil(selfAnchor) or IsNil(friendAnchor) then
		logger:error("pet variant timeline anchors missing, self=%s, friend=%s", tostring(selfAnchor), tostring(friendAnchor))

		return false
	end

	self:_attachPetEntity(self.selfPetEntity, selfAnchor)
	self:_attachPetEntity(self.friendPetEntity, friendAnchor)

	self._startPetPresentationFrameId = TimerManager.addSpecificFrameCb(TIMELINE_PRESENTATION_DELAY_FRAME, false, CallbackHandler(self, "_startPetPresentation", selfAnchor, friendAnchor))

	return true
end

function PetVariantSystem:_attachPetEntity(entity, anchor)
	entity.eModel:SetTransformParent(anchor, false)
	entity.eModel:SetTransformLocalPosition()
	entity.eModel:SetTransformLocalRotation(0, 0, 0, 1)
	entity.eModel:SetTransformLocalScale()
end

function PetVariantSystem:_startPetPresentation(selfAnchor, friendAnchor)
	TimerManager.delFrameCb(self._startPetPresentationFrameId)

	self._startPetPresentationFrameId = nil

	self:_syncPetEntityPosition(self.selfPetEntity, selfAnchor)
	self:_syncPetEntityPosition(self.friendPetEntity, friendAnchor)

	if not self:_facePetsToEachOther() then
		logger:error("pet variant failed to face pets to each other")
		self:finishVariant()

		return
	end

	self:_showPetNames()

	local selfAnimationPlayed, selfAnimationDuration = self:_playPetLoveAnimation(self.selfPetEntity)
	local friendAnimationPlayed, friendAnimationDuration = self:_playPetLoveAnimation(self.friendPetEntity)
	local animationsPlayed = selfAnimationPlayed and friendAnimationPlayed

	if animationsPlayed then
		local sharedAnimationDuration = math.max(selfAnimationDuration, friendAnimationDuration)

		self:_startHeartBoomEffectTimer(sharedAnimationDuration)
	end
end

function PetVariantSystem:_syncPetEntityPosition(entity, anchor)
	local position = anchor.position

	entity:onSyncPos(position.x, position.y, position.z)
end

function PetVariantSystem:_facePetsToEachOther()
	local selfPosition = self.selfPetEntity:getPosition()
	local friendPosition = self.friendPetEntity:getPosition()
	local selfToFriend = friendPosition - selfPosition
	local friendToSelf = selfPosition - friendPosition

	selfToFriend.y = 0
	friendToSelf.y = 0

	if Vector3.SqrMagnitude(selfToFriend) < math.epsilon then
		return false
	end

	local selfRotation = Quaternion.LookRotation(selfToFriend, Vector3.up)
	local friendRotation = Quaternion.LookRotation(friendToSelf, Vector3.up)

	self.selfPetEntity:setRotation(selfRotation, true)
	self.friendPetEntity:setRotation(friendRotation, true)

	return true
end

function PetVariantSystem:_showPetNames()
	self.selfPetEntity:showNormalName()
	self.friendPetEntity:showNormalName()
end

function PetVariantSystem:_startHeartBoomEffectTimer(animationDuration)
	local delay = math.max(animationDuration - HEART_BOOM_EFFECT_END_LEAD_TIME, 0)

	self._heartBoomEffectTimerId = self:startTimer(CallbackHandler(self, "_onHeartBoomEffectTimeout"), delay)
end

function PetVariantSystem:_onHeartBoomEffectTimeout()
	self._heartBoomEffectTimerId = nil

	local canPlayHeartBoomEffect = self._isPlaying and not self.selfPetEntity.destroyed and not self.friendPetEntity.destroyed

	if not canPlayHeartBoomEffect then
		return
	end

	self.selfPetEntity:playVariantHeartBoomEffect()
	self.friendPetEntity:playVariantHeartBoomEffect()
	pg.game.audio:playEvent("SFX_UI_Friend_Colour")
end

function PetVariantSystem:_playPetLoveAnimation(entity)
	local animationDuration = self:_getPetLoveAnimationDuration(entity)
	local animationCfg = {
		PET_VARIANT_ANIM_START,
		PET_VARIANT_ANIM_LOOP,
		PET_VARIANT_ANIM_END,
		{
			false,
			animationDuration
		}
	}
	local state = entity:playCfgAnimation(animationCfg)

	if not state then
		logger:error("pet variant failed to play love animation")

		return false
	end

	entity.eModel:RegisterSleEndCallback(Const.COMPONENT_IDX_PLAYABLE, CallbackHandler(self, "_onPetLoveAnimationFinished", entity))

	return true, animationDuration
end

function PetVariantSystem:_getPetLoveAnimationDuration(entity)
	local startDuration = AnimationUtils.getPlayableClipLength(entity, PET_VARIANT_ANIM_START, 0)
	local endDuration = AnimationUtils.getPlayableClipLength(entity, PET_VARIANT_ANIM_END, 0)

	return math.max(LOVE_ANIMATION_TOTAL_DURATION, startDuration + endDuration)
end

function PetVariantSystem:_onPetLoveAnimationFinished(entity)
	if not self._isPlaying or entity.destroyed then
		return
	end

	self._loveAnimationFinishedEntities[entity] = true

	self:_tryPlayPetHappyAnimations()
end

function PetVariantSystem:_tryPlayPetHappyAnimations()
	local loveAnimationsFinished = self._loveAnimationFinishedEntities and self._loveAnimationFinishedEntities[self.selfPetEntity] and self._loveAnimationFinishedEntities[self.friendPetEntity]
	local canPlayHappyAnimations = self._isPlaying and not self._happyLoopStarted and loveAnimationsFinished

	if not canPlayHappyAnimations then
		return
	end

	self._happyLoopStarted = true

	local selfAnimationPlayed = self:_playPetHappyAnimation(self.selfPetEntity)
	local friendAnimationPlayed = self:_playPetHappyAnimation(self.friendPetEntity)

	if not selfAnimationPlayed or not friendAnimationPlayed then
		return
	end

	self.selfPetEntity:switchToVariantName()
	self.friendPetEntity:switchToVariantName()
end

function PetVariantSystem:_playPetHappyAnimation(entity)
	if not self._isPlaying or entity.destroyed or not entity.eModel then
		return false
	end

	local state = entity:playAnimation(PET_VARIANT_END_ANIM, true, nil, true, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)

	if not state then
		logger:error("pet variant failed to play happy loop animation")

		return false
	end

	return true
end

function PetVariantSystem:finishVariant()
	self._isPlaying = false
	self.position = nil
	self.outputCamera = nil
	self.timelineFinishedCallback = nil

	if self._startPetPresentationFrameId then
		TimerManager.delFrameCb(self._startPetPresentationFrameId)

		self._startPetPresentationFrameId = nil
	end

	if self._heartBoomEffectTimerId then
		self:killTimer(self._heartBoomEffectTimerId)

		self._heartBoomEffectTimerId = nil
	end

	if self.selfPetEntity then
		self.selfPetEntity.modelLoadedCallback = nil
		self.selfPetEntity.onAnimatorReadyCallback = nil

		ClientUtils.safeDestroy(self.selfPetEntity)

		self.selfPetEntity = nil
	end

	if self.friendPetEntity then
		self.friendPetEntity.modelLoadedCallback = nil
		self.friendPetEntity.onAnimatorReadyCallback = nil

		ClientUtils.safeDestroy(self.friendPetEntity)

		self.friendPetEntity = nil
	end

	self._readyPetEntities = nil
	self._loveAnimationFinishedEntities = nil
	self._happyLoopStarted = nil

	local scene = self.scene

	self.scene = nil

	if scene then
		scene:destroy()
	end

	if self._hudHidden then
		self:_setHudHidden(false)
	end
end

function PetVariantSystem:onClear()
	self:finishVariant()
end

function PetVariantSystem:onDestroy()
	self:finishVariant()
end

return PetVariantSystem
