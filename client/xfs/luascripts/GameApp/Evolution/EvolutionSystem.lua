-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Evolution\\EvolutionSystem.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("PetEvolutionSystem")
local SystemBase = require("GameApp.Core.SystemBase")
local Class = require("Core.Framework.Class")
local GlobalData = require("Core.Client.GlobalData")
local ClientUtils = require("Utils.ClientUtils")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local EventConst = require("Const.EventConst")
local LoggerManager = require("Core.Log.LoggerManager")
local CommonRepo = require("Core.Common.CommonRepo")
local UIConst = require("Const.UIConst")
local CameraConst = require("GameApp.Camera.CameraConst")
local MessageName = require("Const.MessageName")
local TimerManager = require("Core.Timer.TimerManager")
local EvolutionConst = require("Common.Const.EvolutionConst").PetEvolution
local SandboxConst = require("Common.Const.SandboxConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local TaCharParamData = require("Data.ta_char_param_data")
local EvolutionScene = require("GameApp.Evolution.EvolutionScene")
local PetData = require("Data.pet_data")
local PetEvolveData = require("Data.pet_evolve_data")
local bit = bit
local Vector3 = Vector3
local extraInfo = {
	layer = ClientConst.LayerDefine.LAYER_CUTSCENE
}
local EvolutionSystem = Class.LightClass("EvolutionSystem", SystemBase)

function EvolutionSystem:onCtor()
	EvolutionSystem.super.onCtor(self)

	self.evolutionTimerList = {}
	self._isInEvolution = false
	self._isFinishingEvolution = false
end

function EvolutionSystem:startEvolution(oldEntityInfo, newEntityInfo)
	self:_startEvolution(oldEntityInfo, newEntityInfo, false)
end

function EvolutionSystem:startPresentation(oldEntityInfo, newEntityInfo, closeCallback)
	self:_startEvolution(oldEntityInfo, newEntityInfo, true, closeCallback)
end

function EvolutionSystem:_startEvolution(oldEntityInfo, newEntityInfo, presentationOnly, closeCallback)
	self:finishEvolution()

	self.presentationOnly = presentationOnly == true
	self.presentationCloseCallback = closeCallback
	self.pos = EvolutionConst.Pos
	self.rot = Quaternion.identity
	self.oldEntityInfo = oldEntityInfo
	self.newEntityInfo = newEntityInfo
	self.bgEffectId = pg.game.effect:playEffectAt(nil, EvolutionConst.EvolutionSpaceEffectName, self.pos, self.rot:ToEulerAngles(), nil, extraInfo, true)
	self.petEvolveVirtualOldEntity = ClientUtils.createEvolutionEntity(oldEntityInfo, self.pos, self.rot)
	self.petEvolveVirtualNewEntity = ClientUtils.createEvolutionEntity(newEntityInfo, self.pos, self.rot)
	self._isInEvolution = true

	if not self.presentationOnly then
		self.evolutionTimerList[#self.evolutionTimerList + 1] = TimerManager.addTimer(EvolutionConst.EvolutionPetUIShowTime, function()
			pg.global.ui:open(UIConst.UI_ID_PET_EVOLVE_PET_SHOW, {
				closeCallback = CallbackHandler(self, "onClosePetEvolveShow"),
				petInfo = newEntityInfo
			})
		end)
	end

	self:setEvolveAbsolutelyControlCamera(true)
	self.petEvolveVirtualOldEntity:setEvolutionScene(self.evolutionScene)
	self.petEvolveVirtualNewEntity:setEvolutionScene(self.evolutionScene)
	self:setUIVisible(false)

	if self.presentationOnly then
		self:startShinyPresentation()
	else
		self:playPetEvolutionOldPrepare()
		self:playPetEvolutionNew()
	end

	pg.global.uiMgr:AddStreamingAnchor()

	if not self.presentationOnly then
		facade:SendMessageCommand(MessageName.PLAYER_PET_EVOLVE_PROCESS_FINISH, true)
	end
end

function EvolutionSystem:addPresentationTimer(context, delay, callback)
	local timer

	timer = TimerManager.addTimer(math.max(delay, 0), function()
		context.timers[timer] = nil

		if self.presentationContext == context and context.active then
			callback()
		end
	end)
	context.timers[timer] = true
end

function EvolutionSystem:clearPresentationTimers(context)
	for timer in pairs(context.timers) do
		TimerManager.removeTimer(timer)
	end

	table.clear(context.timers)
end

function EvolutionSystem:refreshPresentation(context)
	context.canClose = context.resultReady and (not context.skipped or context.closeDelayFinished)

	if context.refresh then
		context.refresh()
	end
end

function EvolutionSystem:startShinyPresentation()
	local context = {
		canClose = false,
		resultReady = false,
		canSkip = false,
		active = true,
		timers = {}
	}

	self.presentationContext = context

	function context.skip()
		self:skipShinyPresentation(context)
	end

	function context.onViewDestroyed()
		if self.presentationContext == context and context.active then
			context.closing = true

			self:finishEvolution()
		end
	end

	self.petEvolveVirtualOldEntity:setEvolutionVisible(true)
	self.petEvolveVirtualNewEntity:setEvolutionVisible(false)
	self.petEvolveVirtualOldEntity:playSoundEvent(EvolutionConst.SoundEventName)
	pg.global.ui:open(UIConst.UI_ID_PET_EVOLVE_PET_SHOW, {
		closeCallback = CallbackHandler(self, "onClosePetEvolveShow"),
		petInfo = self.newEntityInfo,
		presentationContext = context
	})
	self:addPresentationTimer(context, EvolutionConst.EvolutionDissolveOldMeshAnim.startTime, function()
		local oldEntity = self.petEvolveVirtualOldEntity

		oldEntity:playEffect(EvolutionConst.VEG_OLD.effectName)
		oldEntity:playPresentationDissolve(false, function()
			if not context.active or context.skipped then
				return
			end

			self:addPresentationTimer(context, EvolutionConst.ShinyPresentation.skipDelay, function()
				context.canSkip = not context.resultReady

				self:refreshPresentation(context)
			end)
		end, function()
			if not context.active or context.skipped then
				return
			end

			oldEntity:setEvolutionVisible(false)
		end)
	end)
	self:addPresentationTimer(context, EvolutionConst.EvolutionDissolveNewMeshAnim.startTime, function()
		self:playShinyPresentationNew(context)
	end)
end

function EvolutionSystem:playShinyPresentationNew(context)
	local newEntity = self.petEvolveVirtualNewEntity
	local dissolve = EvolutionConst.EvolutionDissolveNewMeshAnim

	newEntity:setEvolutionVisible(false)

	context.newEffectId = newEntity:playEffect(EvolutionConst.VEG_NEW.effectName)

	newEntity:playPresentationDissolve(true, function()
		if not context.active or context.skipped then
			return
		end

		newEntity:setEvolutionVisible(true)

		local animDelay = EvolutionConst.EvolutionAnimation.startTime - dissolve.startTime

		self:addPresentationTimer(context, animDelay, function()
			self:playShinyPresentationAnimation(context)
		end)
	end, function()
		if not context.active or context.skipped then
			return
		end

		self:completeShinyPresentation(context)
	end)
end

function EvolutionSystem:playShinyPresentationAnimation(context)
	if context.animationPlayed then
		return
	end

	context.animationPlayed = true

	local list = EvolutionConst.EvolutionAnimation.animStateList
	local cfg = list[math.random(1, #list)]

	if type(cfg) == "string" then
		self.petEvolveVirtualNewEntity:playAnimation(cfg)
	else
		self.petEvolveVirtualNewEntity:playCfgAnimation(cfg)
	end
end

function EvolutionSystem:completeShinyPresentation(context)
	if context.resultReady then
		return
	end

	if self.petEvolveVirtualOldEntity then
		self.petEvolveVirtualOldEntity:setEvolutionVisible(false)
	end

	local newPos = self.pos + Vector3(0, EvolutionConst.EvolutionSuccess.heightMulti * self.petEvolveVirtualNewEntity:getHeight(), 0)

	self.petSuccessEffectId = pg.game.effect:playEffectAt(nil, EvolutionConst.EvolutionSuccess.effectName, newPos, self.rot:ToEulerAngles(), nil, extraInfo)
	context.resultReady = true
	context.canSkip = false

	self:refreshPresentation(context)
end

function EvolutionSystem:skipShinyPresentation(context)
	if self.presentationContext ~= context or not context.active or not context.canSkip or context.skipped then
		return
	end

	context.skipped = true
	context.canSkip = false
	context.closeDelayFinished = false

	self:clearPresentationTimers(context)
	self:refreshPresentation(context)
	self:addPresentationTimer(context, EvolutionConst.ShinyPresentation.closeDelayAfterSkip, function()
		context.closeDelayFinished = true

		self:refreshPresentation(context)
	end)

	if self.petEvolveVirtualOldEntity then
		self.petEvolveVirtualOldEntity:stopSoundEvent(EvolutionConst.SoundEventName, 0.1)
		ClientUtils.safeDestroy(self.petEvolveVirtualOldEntity)

		self.petEvolveVirtualOldEntity = nil
	end

	local newEntity = self.petEvolveVirtualNewEntity

	if context.newEffectId then
		newEntity:stopEffectById(context.newEffectId)

		context.newEffectId = nil
	end

	newEntity:stopPresentationDissolve()

	local dissolve = EvolutionConst.EvolutionDissolveNewMeshAnim

	self:seekPresentationScene(dissolve.startTime + dissolve.duration)
	self:finishShinyPresentationSkip(context)
end

function EvolutionSystem:finishShinyPresentationSkip(context)
	if not context.active or context.resultReady then
		return
	end

	local newEntity = self.petEvolveVirtualNewEntity

	newEntity:stopPresentationDissolve()
	newEntity:setEvolutionVisible(true)
	self:playShinyPresentationSkipSound(context, EvolutionConst.EvolutionSuccess.startTime)
	self:playShinyPresentationAnimation(context)
	self:completeShinyPresentation(context)
end

function EvolutionSystem:playShinyPresentationSkipSound(context, startTime)
	if context.skipSoundPlayed then
		return
	end

	context.skipSoundPlayed = true

	local newEntity = self.petEvolveVirtualNewEntity

	newEntity:playSoundEvent(EvolutionConst.SoundEventName)
	pg.game.audio:seekEvent(EvolutionConst.SoundEventName, newEntity.eModel.audioEmitter, startTime)
end

function EvolutionSystem:seekPresentationScene(time)
	local scene = self.evolutionScene and self.evolutionScene.scene

	if scene and scene.cutscene then
		local director = scene.cutscene.prefabRoot:GetComponent(typeof(CS.UnityEngine.Playables.PlayableDirector))

		if director then
			director.time = time

			director:Evaluate()
		end
	end

	self:clearBgEffect()

	self.bgEffectId = pg.game.effect:playEffectAt(nil, EvolutionConst.EvolutionSpaceEffectName, self.pos, self.rot:ToEulerAngles(), nil, {
		layer = ClientConst.LayerDefine.LAYER_CUTSCENE,
		startTime = time
	}, true)
end

function EvolutionSystem:onClosePetEvolveShow()
	local presentationOnly = self.presentationOnly
	local presentationCloseCallback = self.presentationCloseCallback
	local newEntityInfo = self.newEntityInfo

	self:finishEvolution(not presentationOnly)

	if presentationOnly then
		if presentationCloseCallback then
			presentationCloseCallback(newEntityInfo)
		end

		return
	end

	if self:isEvolveToFinalBranch(self.oldEntityInfo, self.newEntityInfo) then
		pg.global.ui:close(UIConst.UI_ID_PET_EVOLUTION)
	else
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("PetEvolutionSystem:onClosePetEvolveShow, not evolve to final branch, petId = %s", self.newEntityInfo and self.newEntityInfo.id or "nil")
		end

		if self.delayTimer then
			TimerManager.removeTimer(self.delayTimer)

			self.delayTimer = nil
		end

		self.delayTimer = TimerManager.addTimer(0.1, function()
			facade:SendMessageCommand(MessageName.PLAYER_PET_EVOLVE_FINISHED, self.newEntityInfo)

			self.delayTimer = nil
		end)
	end
end

function EvolutionSystem:isEvolveToFinalBranch(oldEntityInfo, newEntityInfo)
	if not oldEntityInfo then
		return false
	end

	local tempId = newEntityInfo.templateId
	local targetEvoCfg = PetEvolveData[tempId] and PetEvolveData[tempId]
	local targetPetTempId

	if targetEvoCfg then
		for _, branch in pairs(targetEvoCfg) do
			if branch.targetPetId then
				targetPetTempId = branch.targetPetId

				break
			end
		end
	end

	return targetPetTempId == nil
end

function EvolutionSystem:isInEvolution()
	return self._isInEvolution
end

function EvolutionSystem:playPetEvolutionOldPrepare()
	if not self:isInEvolution() then
		return
	end

	self.petEvolveVirtualOldEntity:setEvolutionVisible(true)
	self.petEvolveVirtualOldEntity:setVEGCloseTimer(EvolutionConst.VEG_OLD.startTime, EvolutionConst.VEG_OLD.effectName, self.petEvolveVirtualNewEntity, EvolutionConst.EvolutionDissolveOldMeshAnim.border)

	local height = self.petEvolveVirtualOldEntity:getEvolutionHeight()

	self.petEvolveVirtualOldEntity:setDissolveEffect(EvolutionConst.EvolutionDissolveOldMeshAnim.startTime, EvolutionConst.EvolutionDissolveOldMeshAnim.resName, Vector3(0, EvolutionConst.TweenEvolutionDissolveHeight + height, 0) + self.pos, EvolutionConst.TweenEvolutionDissolveHeight, EvolutionConst.TweenEvolutionDissolveHeight + height + EvolutionConst.EvolutionDissolveOldMeshAnim.border, EvolutionConst.EvolutionDissolveOldMeshAnim.border, EvolutionConst.EvolutionDissolveOldMeshAnim.duration, EvolutionConst.EvolutionDissolveOldMeshAnim.voxelParam, false, 1)
	self.petEvolveVirtualOldEntity:playSoundEvent(EvolutionConst.SoundEventName)
end

function EvolutionSystem:playPetEvolutionNew()
	if not self.petEvolveVirtualNewEntity then
		return
	end

	self.petEvolveVirtualNewEntity:setEvolutionVisible(false)

	local offsetY = self.petEvolveVirtualNewEntity:getEntityOffsetY()
	local height = self.petEvolveVirtualNewEntity:getEvolutionHeight()
	local startValue, border, endValue

	if EvolutionConst.EvolutionDissolveNewMeshAnim.border > 0 then
		border = EvolutionConst.EvolutionDissolveNewMeshAnim.border
		startValue = EvolutionConst.TweenEvolutionDissolveHeight + height + border
		endValue = EvolutionConst.TweenEvolutionDissolveHeight
	elseif EvolutionConst.EvolutionDissolveNewMeshAnim.border == 0 then
		border = -1 * height
		startValue = EvolutionConst.TweenEvolutionDissolveHeight + height
		endValue = EvolutionConst.TweenEvolutionDissolveHeight
	else
		border = EvolutionConst.EvolutionDissolveNewMeshAnim.border
		startValue = EvolutionConst.TweenEvolutionDissolveHeight + height
		endValue = EvolutionConst.TweenEvolutionDissolveHeight
	end

	self.petEvolveVirtualNewEntity:setVEGShowTimer(EvolutionConst.VEG_NEW.startTime, EvolutionConst.VEG_NEW.effectName, EvolutionConst.VEG_NEW.duration, offsetY, border)

	local cfg = EvolutionConst.EvolutionAnimation.animStateList[math.random(1, #EvolutionConst.EvolutionAnimation.animStateList)]
	local cfgType = type(cfg)

	if cfgType == "string" then
		self.petEvolveVirtualNewEntity:playDelayAnimation(EvolutionConst.EvolutionAnimation.startTime, cfg)
	elseif cfgType == "table" then
		self.petEvolveVirtualNewEntity:playDelayCfgAnimation(EvolutionConst.EvolutionAnimation.startTime, cfg)
	end

	self.petEvolveVirtualNewEntity:setDissolveEffect(EvolutionConst.EvolutionDissolveNewMeshAnim.startTime, EvolutionConst.EvolutionDissolveNewMeshAnim.resName, Vector3(0, EvolutionConst.TweenEvolutionDissolveHeight + height, 0) + self.pos, startValue, endValue, border, EvolutionConst.EvolutionDissolveNewMeshAnim.duration, EvolutionConst.EvolutionDissolveNewMeshAnim.voxelParam, true, EvolutionConst.EvolutionDissolveNewMeshAnim.speed)

	self.evolutionTimerList[#self.evolutionTimerList + 1] = TimerManager.addTimer(EvolutionConst.EvolutionSuccess.startTime, function()
		local newPos = self.pos + Vector3(0, EvolutionConst.EvolutionSuccess.heightMulti * self.petEvolveVirtualNewEntity:getHeight(), 0)

		self.petSuccessEffectId = pg.game.effect:playEffectAt(nil, EvolutionConst.EvolutionSuccess.effectName, newPos, self.rot:ToEulerAngles(), nil, extraInfo)
	end)
end

function EvolutionSystem:finishEvolution(isProcessFinish)
	if self._isFinishingEvolution then
		return
	end

	self._isFinishingEvolution = true

	local presentationOnly = self.presentationOnly
	local context = self.presentationContext

	if context then
		context.active = false
		context.canSkip = false
		context.canClose = true
		context.closing = true
		context.refresh = nil

		self:clearPresentationTimers(context)

		self.presentationContext = nil
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PET_EVOLVE_PET_SHOW) then
		pg.global.ui:close(UIConst.UI_ID_PET_EVOLVE_PET_SHOW)
	end

	self:setEvolveAbsolutelyControlCamera(false)
	self:setUIVisible(true)

	if self.petEvolveVirtualNewEntity and not presentationOnly then
		facade:sendLuaEvent(SandboxConst.COMMON_EVENT.PET_EVOLUTION_COMPLETED, self.petEvolveVirtualNewEntity.templateId)

		local entity = pg.getEntity(self.petEvolveVirtualNewEntity:getEvolutionId())

		if entity and entity.eventEmitter then
			entity.eventEmitter:emit(EventConst.TOPLOGO_HEIGHT)
		end
	end

	self:clearPetEvolveVirtualEntity()
	self:clearBgEffect()
	self:clearPetSuccessEffect()
	self:changeEnv()
	pg.global.uiMgr:ClearStreamingAnchor()

	self._isInEvolution = false

	pg.game.input:refreshCursorState()

	if isProcessFinish and not presentationOnly then
		facade:SendMessageCommand(MessageName.PLAYER_PET_EVOLVE_PROCESS_FINISH, false)
	end

	self.presentationOnly = nil
	self.presentationCloseCallback = nil
	self._isFinishingEvolution = false
end

function EvolutionSystem:setEvolveAbsolutelyControlCamera(evolving)
	if not self:isInEvolution() then
		return
	end

	if evolving then
		if self.evolutionScene == nil then
			local cameraOffset = Vector3(0, self.petEvolveVirtualNewEntity:getEntityOffsetY(), 0)

			self.evolutionScene = EvolutionScene.new(EvolutionConst.CameraPrefab, self.pos + cameraOffset, self.rot)
		end

		self.evolutionScene:startLoad(CallbackHandler(self, "setUIVisible", false))
		self.evolutionScene:setCameraTarget(Vector3(0, self.petEvolveVirtualNewEntity:getEntityCameraTargetOffset(), 0))
	elseif self.evolutionScene then
		self.evolutionScene:destroy()

		self.evolutionScene = nil
	end
end

function EvolutionSystem:clearPetEvolveVirtualEntity()
	if self.petEvolveVirtualOldEntity then
		ClientUtils.safeDestroy(self.petEvolveVirtualOldEntity)

		self.petEvolveVirtualOldEntity = nil
	end

	if self.petEvolveVirtualNewEntity then
		ClientUtils.safeDestroy(self.petEvolveVirtualNewEntity)

		self.petEvolveVirtualNewEntity = nil
	end

	for i = 1, #self.evolutionTimerList do
		TimerManager.removeTimer(self.evolutionTimerList[i])
	end

	table.clearArray(self.evolutionTimerList)
end

function EvolutionSystem:clearPetSuccessEffect()
	if self.petSuccessEffectId then
		pg.game.effect:stopEffect(nil, self.petSuccessEffectId)

		self.petSuccessEffectId = nil
	end
end

function EvolutionSystem:clearBgEffect()
	if self.bgEffectId then
		pg.game.effect:stopEffect(nil, self.bgEffectId)

		self.bgEffectId = nil
	end
end

function EvolutionSystem:setUIVisible(visible)
	if not self:isInEvolution() then
		return
	end

	if visible then
		local ui = pg.global.ui

		ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.PET_EVOLVE)

		if pg.global.ui.petManagement then
			pg.global.ui.petManagement:refreshAll()
		end

		if ui:checkUIOpen(UIConst.UI_ID_PET_MANAGEMENT) == true then
			pg.game.camera:setWorldCameraEnable(true, ClientConst.CameraDisableReason.Evolution)
		else
			pg.game.camera:tryResetWorldCameraEnable(ClientConst.CameraDisableReason.Evolution)
		end
	else
		self.uiIsOpen = pg.global.ui.petTrainingNew:checkUIOpen()

		pg.global.ui.petTrainingNew:close()

		local ui = pg.global.ui

		ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.PET_EVOLVE, EvolutionConst.UIWhileList)
		pg.game.camera:setWorldCameraEnable(false, ClientConst.CameraDisableReason.Evolution)
	end
end

function EvolutionSystem:changeEnv()
	if self:isInEvolution() and self.uiIsOpen then
		appFacade.pipelineManager:TryRegisterEventForceEnvChange()
	end
end

function EvolutionSystem:debugTestPetEvolve()
	self:clearPetEvolveVirtualEntity()

	local petInfoOldInfo, petCurrentInfo

	for k, v in pairs(pg.me.pets) do
		if not petCurrentInfo then
			petCurrentInfo = pg.me:getPetInfo(k)
		else
			petInfoOldInfo = petInfoOldInfo or pg.me:getPetInfo(k)
		end
	end

	local petEnt = pg.me:getCurPetEntity()
	local pos = petEnt:getPositionClone()
	local rot = petEnt:getRotation()

	self:startEvolution(petInfoOldInfo, petCurrentInfo, pos, rot)
end

return EvolutionSystem
