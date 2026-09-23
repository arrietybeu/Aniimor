-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientCaptureMainComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local class = require("Core.Framework.Class")
local InputCommand = require("GameApp.Input.InputCommand")
local QuickCatchContext = require("GameApp.Capture.Context.QuickCatchContext")
local BigBallQuickCatchContext = require("GameApp.Capture.Context.BigBallQuickCatchContext")
local BossCatchContext = require("GameApp.Capture.Context.BossCatchContext")
local MessageName = require("Const.MessageName")
local AudioConst = require("Const.AudioConst")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local Utils = require("Common.Utils.Utils")
local NoBallContext = require("GameApp.Capture.Context.NoBallContext")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local ClientConst = require("Const.ClientConst")
local AbilityConst = require("Common.Const.AbilityConst")
local castItemData = require("Data.cast_item_data")
local ItemEffectData = require("Data.item_effect_data")
local SysConfigData = require("Data.sys_config_data")
local VoxelConst = require("Common.Const.VoxelConst")
local EventConst = require("Const.EventConst")
local PetData = require("Data.pet_data")
local ThrowEnvItemContext = require("GameApp.Capture.Context.ThrowEnvItemContext")
local CaptureFsm = require("GameApp.Capture.CaptureFsm")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local UIConst = require("Const.UIConst")
local InteractionConst = require("Common.Const.InteractionConst")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local Time = require("Core.Common.Time")
local HotKeyConst = require("Const.HotkeyConst")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ClientLeylineFlowerCaptureRewardCtrl = require("GameApp.LeylineTree.ClientLeylineFlowerCaptureRewardCtrl")
local TimerManager = require("Core.Timer.TimerManager")
local ClientUtils = require("Utils.ClientUtils")
local PetFertilityConst = require("Const.PetFertilityConst")
local BossTitleTrapInvisibleOwner = require("Utils.BossTitleTrapInvisibleOwner")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local LeylineFlowerUtils = require("Common.Utils.LeylineFlowerUtils")
local CaptureStates = CaptureFsm.states
local ClientCaptureMainComponent = class.Component("ClientCaptureMainComponent")

function ClientCaptureMainComponent:ctor()
	self.noBallContext = NoBallContext.new(self)
	self.currentContext = self.noBallContext
	self.preloadedBall = {}
	self.captureBallVolumeId = nil
	self.captureBallVolumeIds = {}
end

function ClientCaptureMainComponent:EVENT_PostInitialized()
	local propList = self.invQuickSlotBall

	if propList and #propList > 0 then
		self:preloadBall(propList[1])
	end

	return true
end

function ClientCaptureMainComponent:throwEnvObj(envEntity)
	self:switchContext(ThrowEnvItemContext.new(self, envEntity))
end

function ClientCaptureMainComponent:throwItemFromBag(itemId)
	self:switchContext(ClientCaptureUtils.getThrowContext(self, itemId))
end

function ClientCaptureMainComponent:toggleCatchMode()
	return self.currentContext:exit()
end

function ClientCaptureMainComponent:isInCatchMode()
	return self.currentContext and self.currentContext.className ~= "NoBallContext"
end

function ClientCaptureMainComponent:isCaptureThrowing()
	local ctx = self.currentContext

	return ctx and (ctx.state == CaptureStates.T or ctx.fsm and ctx.fsm.state == CaptureStates.T) or false
end

function ClientCaptureMainComponent:isInQuickCapture()
	return self.currentContext.className == "QuickCatchContext"
end

function ClientCaptureMainComponent:isThrowItem()
	local context = self.currentContext

	return context and (context.className == "ThrowEnvItemContext" or context.className == "ParabolaThrowContext") or false
end

function ClientCaptureMainComponent:isInBossCatch()
	local context = self.currentContext

	return context and context.className == "BossCatchContext" or false
end

function ClientCaptureMainComponent:isInBigBallCatch()
	local context = self.currentContext

	return context and context.className == "DriveBallContext" or false
end

function ClientCaptureMainComponent:tick(deltaTime)
	if self:isInCatchMode() and not self:isInBossCatch() then
		local exclude = self:isThrowItem() and {
			INTERACT_ST = true
		} or {}

		if not self:checkEnterCatchMode(nil, exclude) then
			self:_cancel_CATCH_MODE_ST()
		end
	end

	if self.bossCatchDistanceToastShowing then
		local bossEntity = self.curBossCaptureActorId and pg.getEntityByActorId(self.curBossCaptureActorId)

		if not bossEntity or not pg.pawn or Vector3.Distance(pg.pawn:getPosition(), bossEntity:getPosition()) <= SysConfigData.BOSS_CATCH_START_DIST then
			pg.global.hideBubbleMessageById(NoticeDef.BOSS_CATCH_DISTANCE_TOAST)

			self.bossCatchDistanceToastShowing = nil
		end
	end
end

function ClientCaptureMainComponent:_switchCaptureBallVolume(context)
	local volumeId

	if context then
		volumeId = tonumber(context and context.ballData and context.ballData.ballScreenEffect)
	end

	if volumeId and volumeId <= 0 then
		volumeId = nil
	end

	if self.captureBallVolumeId == volumeId then
		return
	end

	if self.captureBallVolumeId then
		pg.game.camera:enableVolumeEffect(self.captureBallVolumeId, false)
	end

	if volumeId then
		if not self.captureBallVolumeIds[volumeId] then
			pg.game.camera:addVolumeEffect(volumeId)

			self.captureBallVolumeIds[volumeId] = true
		end

		pg.game.camera:enableVolumeEffect(volumeId, true)
	end

	self.captureBallVolumeId = volumeId
end

function ClientCaptureMainComponent:_clearCaptureBallVolumes()
	for volumeId in pairs(self.captureBallVolumeIds) do
		pg.game.camera:delVolumeEffect(volumeId)
	end

	self.captureBallVolumeId = nil
	self.captureBallVolumeIds = {}
end

function ClientCaptureMainComponent:switchContext(context)
	local wasInCatchMode = self:isInCatchMode()

	context = context or self.noBallContext

	local fromContext = self.currentContext

	if not fromContext then
		return
	end

	fromContext:destroy()

	self.currentContext = context

	context:enter(fromContext)

	local isInCatchMode = self:isInCatchMode()

	if isInCatchMode then
		self:_switchCaptureBallVolume(self.currentContext)
	else
		self:_clearCaptureBallVolumes()
	end

	if self.isMainPlayer and wasInCatchMode ~= isInCatchMode then
		facade:SendMessageCommand(MessageName.MAIN_PLAYER_CATCH_MODE_CHANGE)

		if wasInCatchMode then
			facade:SendMessageCommand(MessageName.LEAVE_CATCH_MODE_ST)
		end
	end
end

function ClientCaptureMainComponent:onLeaveSpace()
	self:_exitCaptureOnLeave()
end

function ClientCaptureMainComponent:_exitCaptureOnLeave()
	self:_clearBossCaptureResumeTimer()
	self:_clearLuckyPetTipDelay()
	self:_forceClearBossTitleTrapInvisibleReason()

	if self.curBossCaptureActorId then
		self:finishBossCapture(self.curBossCaptureActorId)
	else
		self:forceExitCaptureMode()
	end
end

function ClientCaptureMainComponent:EVENT_LeaveScene()
	self:_exitCaptureOnLeave()
end

function ClientCaptureMainComponent:EVENT_AddEComponent()
	self:addEModelComponent(Const.COMPONENT_CATCH)
end

function ClientCaptureMainComponent:EVENT_ResetAllStateByEscape()
	if self.curBossCaptureActorId then
		self:cancelBossCapture(self.curBossCaptureActorId)
	elseif self:isInCatchMode() then
		self:forceExitCaptureMode()
	end
end

function ClientCaptureMainComponent:EVENT_OnPlayerDead()
	if self.curBossCaptureActorId then
		self:cancelBossCapture(self.curBossCaptureActorId)
	else
		self:forceExitCaptureMode()
	end
end

function ClientCaptureMainComponent:captureThrow()
	self.currentContext:throw()
end

function ClientCaptureMainComponent:tryFastCaptureThrow(expectedContext)
	local context = self.currentContext

	if expectedContext and context ~= expectedContext then
		return nil
	end

	if not context then
		return nil
	end

	local isDriveBallContext = context.className == "DriveBallContext"

	if context.className ~= "CameraThrowContext" and not isDriveBallContext then
		return nil
	end

	if context.state == CaptureStates.T or isDriveBallContext and context.throwed then
		return true
	end

	if not context.ballEnt or not context.ballEnt.isBallReady or not context.ballEnt:isBallReady() then
		return false
	end

	context:throw()

	if context.state == CaptureStates.T or isDriveBallContext and context.throwed then
		return true
	end

	return nil
end

function ClientCaptureMainComponent:finishFastThrowPresentation()
	local context = self.currentContext

	if not context or context.className ~= "CameraThrowContext" and context.className ~= "DriveBallContext" then
		return false
	end

	if context._fastThrowPresentationFinished then
		return false
	end

	context._fastThrowPresentationFinished = true

	pg.game.input:setEnableViewControlGyro(false)
	pg.game.camera.playerCameraMode:enableCatch(false)

	return true
end

function ClientCaptureMainComponent:isFastThrowPresentationFinished()
	local context = self.currentContext

	return context ~= nil and context._fastThrowPresentationFinished == true
end

function ClientCaptureMainComponent:setContinuousCaptureThrow(isStart)
	local context = self.currentContext

	if not context then
		return nil
	end

	if not isStart then
		if context.stopContinuousThrow then
			context:stopContinuousThrow("input_canceled")
		end

		return nil
	end

	if context.className ~= "CameraThrowContext" or not context.ballData or context.ballData.proxy ~= "CatchBall" then
		return nil
	end

	if context.startContinuousThrow then
		return context:startContinuousThrow()
	end

	return nil
end

function ClientCaptureMainComponent:switchProp(force)
	local itemId

	if pg.global.ui:checkUIShow(UIConst.UI_ID_CATCHBOSS_NEW) then
		itemId = pg.global.ui.catchBossNew:getCurSelectPropId()
	elseif pg.global.ui:checkUIShow(UIConst.UI_ID_CATCHBOSS) then
		itemId = pg.global.ui.catchBoss:getCurSelectPropId()
	else
		itemId = pg.global.ui.hudV2:getCurSelectPropId()
	end

	self:preloadBall(itemId)

	if not force and not pg.game.controller:isInControlMainPlayer() then
		return
	end

	self.currentContext:switch()
end

function ClientCaptureMainComponent:preloadBall(itemId)
	if not itemId then
		return
	end

	if self.preloadedBall[itemId] then
		return
	end

	self.preloadedBall[itemId] = true

	local ballData = castItemData[Utils.itemId2CastItemId(itemId)]

	if not ballData then
		return
	end

	pg.global.resMgr:PreLoadInstance(ballData.model, 1)
end

function ClientCaptureMainComponent:onThrowBreak()
	self.currentContext:throwBreak()
end

function ClientCaptureMainComponent:onThrowEnd(breaked)
	self.currentContext:throwEnd(breaked)
end

function ClientCaptureMainComponent:beginLuckyPetTipDelay(sessionId)
	if sessionId == nil then
		return
	end

	self._luckyPetTipDelayEntries = self._luckyPetTipDelayEntries or {}

	if self._luckyPetTipDelayEntries[sessionId] ~= nil then
		return
	end

	local entry = {
		sessionId = sessionId
	}

	self._luckyPetTipDelayEntries[sessionId] = entry
end

function ClientCaptureMainComponent:_removeLuckyPetTipDelay(entry)
	if entry == nil then
		return
	end

	if entry.timerId ~= nil then
		self:removeTimer(entry.timerId)

		entry.timerId = nil
	end

	if self._luckyPetTipDelayEntries ~= nil then
		self._luckyPetTipDelayEntries[entry.sessionId] = nil
	end
end

function ClientCaptureMainComponent:_finishLuckyPetTipDelay(entry)
	local petInfos = entry and entry.petInfos

	self:_removeLuckyPetTipDelay(entry)

	if petInfos ~= nil then
		pg.global.ui.tips:pushPetGot(petInfos)
	end
end

function ClientCaptureMainComponent:_scheduleLuckyPetTips(entry)
	if entry == nil or entry.petInfos == nil or entry.deadline == nil or entry.timerId ~= nil then
		return
	end

	local remainDelay = math.max(0, entry.deadline - Time.realSecondCache)

	if remainDelay <= 0 then
		self:_finishLuckyPetTipDelay(entry)

		return
	end

	entry.timerId = self:addTimer(remainDelay, function()
		entry.timerId = nil

		self:_finishLuckyPetTipDelay(entry)
	end)
end

function ClientCaptureMainComponent:resolveLuckyPetTipDelay(sessionId, delaySeconds)
	local entry = self._luckyPetTipDelayEntries and self._luckyPetTipDelayEntries[sessionId]

	if entry == nil then
		return
	end

	if delaySeconds == nil then
		self:_finishLuckyPetTipDelay(entry)

		return
	end

	entry.deadline = Time.realSecondCache + delaySeconds

	self:_scheduleLuckyPetTips(entry)
end

function ClientCaptureMainComponent:cancelLuckyPetTipDelay(sessionId)
	local entry = self._luckyPetTipDelayEntries and self._luckyPetTipDelayEntries[sessionId]

	self:_removeLuckyPetTipDelay(entry)
end

function ClientCaptureMainComponent:_showOrQueueCapturePetTips(sessionId, petInfos)
	local entry = self._luckyPetTipDelayEntries and self._luckyPetTipDelayEntries[sessionId]

	if entry == nil then
		pg.global.ui.tips:pushPetGot(petInfos)

		return
	end

	entry.petInfos = petInfos

	self:_scheduleLuckyPetTips(entry)
end

function ClientCaptureMainComponent:_clearLuckyPetTipDelay()
	for _, entry in pairs(self._luckyPetTipDelayEntries or EMPTY_TABLE) do
		if entry.timerId ~= nil then
			self:removeTimer(entry.timerId)

			entry.timerId = nil
		end
	end

	self._luckyPetTipDelayEntries = nil
end

function ClientCaptureMainComponent:RPC_SC_OnCaptureSuccess(clientPetInfos, sessionId)
	if self.space and Utils.isRobEggSceneId(self.space.sceneId) or pg.me:isInFishingCapture() then
		return
	end

	local validPetInfos = {}

	for _, clientPetInfo in ipairs(clientPetInfos) do
		local templateId = clientPetInfo.templateId
		local petdata = PetData[templateId]

		if petdata then
			clientPetInfo.headIconName = petdata.iconName
			clientPetInfo.name = petdata.name
			clientPetInfo.iconName = petdata.iconName
			clientPetInfo.elementTypes = petdata.elementType
			validPetInfos[#validPetInfos + 1] = clientPetInfo
		else
			self.logger:error("@capture RPC_SC_OnCaptureSuccess PetData missing, templateId=%s", tostring(templateId))
		end
	end

	self:_showOrQueueCapturePetTips(sessionId, validPetInfos)

	for _, clientPetInfo in ipairs(clientPetInfos) do
		if Utils.isRainbowTypeByTemplateId(clientPetInfo.templateId) then
			pg.global.eventEmitter:emit(EventConst.PLATFORM_ACHIEVEMENT_RAINBOW_PET_CAUGHT)

			break
		end
	end

	for _, clientPetInfo in ipairs(clientPetInfos) do
		if clientPetInfo.flowerStaticId and clientPetInfo.petStage and clientPetInfo.petPosX and clientPetInfo.petPosY and clientPetInfo.petPosZ then
			self:addTimer(0.5, function()
				self:_playLeylineFlowerCaptureBall(clientPetInfo)
			end)
		end
	end
end

function ClientCaptureMainComponent:EVENT_BeControlled()
	if self.quickCaptureAfterControlled then
		self:quickCapture(self.quickCaptureAfterControlled, true)

		self.quickCaptureAfterControlled = nil
	end

	if self.enterCaptureModeFromPet then
		self.enterCaptureModeFromPet = false

		pg.game.controller:setCatchModeEnable(true)
	end
end

function ClientCaptureMainComponent:EVENT_EnterScene()
	self:refreshBossCapture()
end

function ClientCaptureMainComponent:quickCapture(entId, fromPet)
	local nearestEnt = pg.getEntity(entId)

	if not nearestEnt then
		return false
	end

	local itemId

	itemId = pg.global.ui.hudV2:getCurSelectPropId()

	if ClientCaptureUtils.isPaidBall(itemId) then
		return false
	end

	if not ClientCaptureUtils.checkBallItem(itemId, true) then
		return false
	end

	local alreadyHolding = self:isInCatchMode()

	self:forceExitCaptureMode()

	local castItemId = Utils.itemId2CastItemId(itemId)
	local ballData = castItemData[castItemId]

	if ballData.proxy == "BigBall" then
		local context = BigBallQuickCatchContext.new(self, itemId)

		context:setTarget(nearestEnt, fromPet, alreadyHolding)
		self:switchContext(context)
	elseif ballData.proxy == "CatchBall" then
		local context = QuickCatchContext.new(self, itemId)

		context:setTarget(nearestEnt, fromPet, alreadyHolding)
		self:switchContext(context)
	else
		return false
	end

	if not self:FALL_ST() and not self:isInAir() then
		nearestEnt.lastQuickCaptureTime = Time.realSecondCache
	else
		self.logger:info("quickCapture skip CD by air state, entId=%s, FALL_ST=%s, isInAir=%s", tostring(entId), tostring(self:FALL_ST()), tostring(self:isInAir()), self:repr())
	end

	return true
end

function ClientCaptureMainComponent:bossCapture(entId)
	self.logger:debug("puppetdrop boss, bossCapture, entId=%d", entId, self:repr())

	local bossEntity = pg.getEntity(entId)

	if not bossEntity then
		self.logger:warn("catch boss no bossEntity entId=%d", entId, self:repr())

		return false
	end

	self._bossCatchCancelPendingActorId = nil

	self:setBossCaptureInteraction(false, bossEntity.actorId)

	local itemId = ClientCaptureUtils.getItemBossCatchValid(bossEntity)
	local isFree = ClientCaptureUtils.isBossCatchFreeBall(itemId)

	if not itemId or not isFree and not ClientCaptureUtils.checkBallItem(itemId, true) then
		self:cancelBossCapture(bossEntity.actorId)
		self.logger:warn("catch boss do not have ball item! entId=%d", entId, self:repr())

		return false
	end

	pg.game:setModuleEnable("CatchBoss", ClientConst.ModuleKey.PetLink, false)
	pg.game.input:enableControlInput(false, HotKeyConst.INPUT_BLOCK_FLAG.CatchBoss)
	self:forceExitCaptureMode()

	local castItemId = Utils.itemId2CastItemId(itemId)
	local ballData = castItemData[castItemId]
	local context = BossCatchContext.new(self, itemId)

	context:setTarget(bossEntity, nil, isFree)
	self:switchContext(context)

	return true
end

function ClientCaptureMainComponent:cancelBossCapture(actorId)
	self:_clearBossCaptureResumeTimer()

	self._bossCatchCancelPendingActorId = actorId

	self:_cancelBossCatchBallPerformance(actorId)
	pg.global.ui.tips:hideCountDown("BossCapture")
	pg.game.input:enableControlInput(true, HotKeyConst.INPUT_BLOCK_FLAG.CatchBoss)
	pg.game:setModuleEnable("CatchBoss", ClientConst.ModuleKey.PetLink, true)
	self:sendGroupDropChoice(actorId, Const.GROUP_DROP_CHOICE_GIVEUP, function(noticeId, noticeArgs)
		if noticeId == NoticeDef.SUCCESS then
			self:finishBossCapture(actorId)
		end
	end)
end

function ClientCaptureMainComponent:interruptBossCapture()
	pg.game.input:enableControlInput(true, HotKeyConst.INPUT_BLOCK_FLAG.CatchBoss)
	pg.game:setModuleEnable("CatchBoss", ClientConst.ModuleKey.PetLink, true)

	local resumeActorId = self.curBossCaptureActorId

	self:forceExitCaptureMode()

	if self.curBossCaptureActorId then
		self:setBossCaptureInteraction(true, self.curBossCaptureActorId)
	end

	if self.bossCatchDistanceToastShowing then
		pg.global.hideBubbleMessageById(NoticeDef.BOSS_CATCH_DISTANCE_TOAST)

		self.bossCatchDistanceToastShowing = nil
	end

	if PetFertilityConst.IsRecoverCatchBossNew then
		self:_scheduleBossCaptureResume(resumeActorId)
	end
end

function ClientCaptureMainComponent:_scheduleBossCaptureResume(actorId)
	if not actorId then
		return
	end

	local endTs = self.groupDropEndTsMap and self.groupDropEndTsMap[actorId]

	if not endTs or endTs <= Time.secondCache then
		return
	end

	if not pg.getEntityByActorId(actorId) then
		return
	end

	self:_clearBossCaptureResumeTimer()

	self._bossCatchResumePendingActorId = actorId
	self._bossCatchResumeTimerId = TimerManager.addRepeatTimer(0.3, function()
		local pendingActorId = self._bossCatchResumePendingActorId

		if not pendingActorId then
			self:_clearBossCaptureResumeTimer()

			return
		end

		if self:isInBossCatch() then
			self:_clearBossCaptureResumeTimer()

			return
		end

		local nowEndTs = self.groupDropEndTsMap and self.groupDropEndTsMap[pendingActorId]

		if not nowEndTs or nowEndTs <= Time.secondCache then
			self:_clearBossCaptureResumeTimer()

			return
		end

		if not pg.getEntityByActorId(pendingActorId) then
			self:_clearBossCaptureResumeTimer()

			return
		end

		local topPanelUid = pg.global.ui.getTopFirstPanel and pg.global.ui:getTopFirstPanel()

		if topPanelUid then
			return
		end

		local entity = pg.getEntityByActorId(pendingActorId)

		if not entity or not entity.id then
			self:_clearBossCaptureResumeTimer()

			return
		end

		self:_clearBossCaptureResumeTimer()
		self:bossCapture(entity.id)
	end)
end

function ClientCaptureMainComponent:_clearBossCaptureResumeTimer()
	if self._bossCatchResumeTimerId then
		TimerManager.removeTimer(self._bossCatchResumeTimerId)

		self._bossCatchResumeTimerId = nil
	end

	self._bossCatchResumePendingActorId = nil
end

function ClientCaptureMainComponent:setBossCaptureInteraction(isShow, actorId)
	local entity = pg.global.actorMgr.getEntity(actorId)

	if entity then
		local interactionDatas = {
			airBlock = 1,
			actionPrototypeId = 253,
			overrideType = InteractionConst.INTERACTION_TYPE_BOSS_CAPTURE,
			globalId = entity:getGlobalId()
		}
		local msg = isShow and MessageName.ENTER_TRIGGER or MessageName.LEAVE_TRIGGER

		facade:SendMessageCommand(msg, interactionDatas)
	end
end

function ClientCaptureMainComponent:startBossCapture(actorId)
	self.cacheBossCaptureActorId = nil

	if self.curBossCaptureActorId then
		self:cancelBossCapture(self.curBossCaptureActorId)

		self.curBossCaptureActorId = nil
	end

	self.curBossCaptureActorId = actorId

	if pg.me:isControllingPet() then
		local result = pg.me:requestSwitchToPlayer(Const.CLIENT_SWITCH_REASON.Catch, nil, function()
			self:realStartBossCapture(actorId)
		end)

		if not result then
			self:realStartBossCapture(actorId)
		end
	else
		self:realStartBossCapture(actorId)
	end
end

function ClientCaptureMainComponent:realStartBossCapture(actorId)
	local endts = self.groupDropEndTsMap[actorId]

	endts = endts or 0

	local remainTime = endts - Time.secondCache

	if remainTime > 0 then
		pg.global.ui.tips:showCountDown(remainTime, "BossCapture", {
			infoText = pg.getGameString("BOSS_DEATH_CATCH_COUNTDOWN")
		})
	end

	self:setBossCaptureInteraction(true, actorId)

	local bossEntity = pg.getEntityByActorId(actorId)

	if bossEntity and pg.pawn and SysConfigData.BOSS_CATCH_START_DIST and Vector3.Distance(pg.pawn:getPosition(), bossEntity:getPosition()) > SysConfigData.BOSS_CATCH_START_DIST then
		pg.global.showBubbleMessageById(NoticeDef.BOSS_CATCH_DISTANCE_TOAST)

		self.bossCatchDistanceToastShowing = true
	end
end

function ClientCaptureMainComponent:finishBossCapture(actorId)
	self:_clearBossCaptureResumeTimer()
	pg.game.input:enableControlInput(true, HotKeyConst.INPUT_BLOCK_FLAG.CatchBoss)
	pg.game:setModuleEnable("CatchBoss", ClientConst.ModuleKey.PetLink, true)
	pg.global.ui.tips:hideCountDown("BossCapture")

	if not self:isInBigBallCatch() then
		self:forceExitCaptureMode()
	end

	local ballEnt = self.bossCatchBallEnt

	if ballEnt and ballEnt.isBossSettlePending and ballEnt:isBossSettlePending() then
		-- block empty
	else
		self:_clearBossCatchBallTrapInvisible()

		if ballEnt then
			if not ballEnt.destroyed then
				ClientUtils.safeDestroy(ballEnt)
			end

			self.bossCatchBallEnt = nil
		end

		self._bossCatchBallTrapOwner = nil
	end

	if not actorId or self._bossCatchCancelPendingActorId == actorId then
		self._bossCatchCancelPendingActorId = nil
	end

	self.curBossCaptureActorId = nil

	if self.bossCatchDistanceToastShowing then
		pg.global.hideBubbleMessageById(NoticeDef.BOSS_CATCH_DISTANCE_TOAST)

		self.bossCatchDistanceToastShowing = nil
	end
end

function ClientCaptureMainComponent:refreshBossCapture()
	self.cacheBossCaptureActorId = nil

	if self.curBossCaptureActorId then
		self:finishBossCapture(self.curBossCaptureActorId)

		self.curBossCaptureActorId = nil
	end

	for actorId, endTs in pairs(self.groupDropEndTsMap or EMPTY_TABLE) do
		local entity = pg.getEntityByActorId(actorId)

		if entity then
			entity:onLifeDead()
			self:startBossCapture(actorId)

			break
		else
			self.cacheBossCaptureActorId = actorId

			break
		end
	end
end

function ClientCaptureMainComponent:onBossCatchBallCreated(ballEnt, actorId)
	if not ballEnt then
		return
	end

	self.bossCatchBallEnt = ballEnt
	self._bossCatchBallTrapOwner = ballEnt

	if actorId and self._bossCatchCancelPendingActorId == actorId and ballEnt.cancelBossCapturePerformance then
		ballEnt:cancelBossCapturePerformance()
	end
end

function ClientCaptureMainComponent:onBossCatchFireBall(ballEnt, actorId)
	self:onBossCatchBallCreated(ballEnt, actorId)
end

function ClientCaptureMainComponent:onBossCatchBallClear(ballEnt)
	if not ballEnt or self.bossCatchBallEnt ~= ballEnt then
		return
	end

	self:_clearBossCatchBallTrapInvisible()

	self.bossCatchBallEnt = nil

	if self._bossCatchBallTrapOwner == ballEnt then
		self._bossCatchBallTrapOwner = nil
	end
end

function ClientCaptureMainComponent:_cancelBossCatchBallPerformance(actorId)
	local ballEnt = self.bossCatchBallEnt

	if ballEnt and ballEnt.cancelBossCapturePerformance then
		ballEnt:cancelBossCapturePerformance()
	else
		self:_clearBossCatchBallTrapInvisible()
	end

	self:_clearBossTitleTrapInvisibleReason()
end

function ClientCaptureMainComponent:_clearBossCatchBallTrapInvisible()
	local ballEnt = self.bossCatchBallEnt

	if ballEnt and ballEnt.clearBossTitleTrapInvisible then
		ballEnt:clearBossTitleTrapInvisible()
	elseif self._bossCatchBallTrapOwner then
		BossTitleTrapInvisibleOwner.release(self._bossCatchBallTrapOwner)
	end

	self:_clearBossTitleTrapInvisibleReason()
end

function ClientCaptureMainComponent:_clearBossTitleTrapInvisibleReason()
	if self._bossCatchBallTrapOwner then
		BossTitleTrapInvisibleOwner.release(self._bossCatchBallTrapOwner)
	end
end

function ClientCaptureMainComponent:_forceClearBossTitleTrapInvisibleReason()
	BossTitleTrapInvisibleOwner.forceReleaseAll()
end

function ClientCaptureMainComponent:RPC_SC_OnCaptureBossMonster(entityId, result)
	self.logger:debug("@bossCapture RPC_SC_OnCaptureBossMonster, entityId=%s, result=%s", entityId, tostring(result), self:repr())

	local ballEnt = self.bossCatchBallEnt

	if not ballEnt or ballEnt.destroyed then
		self.logger:warn("RPC_SC_OnCaptureBossMonster: bossCatchBallEnt not found or destroyed, entityId=%s", entityId)

		return
	end

	local bossTarget = ballEnt.bossTarget

	if not bossTarget or bossTarget.id ~= entityId then
		self.logger:warn("RPC_SC_OnCaptureBossMonster: target mismatch, entityId=%s, currentTargetId=%s", entityId, bossTarget and bossTarget.id or "nil")

		return
	end

	ballEnt:onBossSettleResult(result)
end

function ClientCaptureMainComponent:RPC_SC_GroupDropNotify(actorId, op, params)
	if pg.me and pg.me:isInFishingCapture() then
		return
	end

	local entity = pg.getEntityByActorId(actorId)

	if op == Const.GROUP_DROP_NOTIFY_ENDTS then
		local endts = unpack(params)

		if endts ~= self.groupDropEndTsMap[actorId] then
			self.logger:warn("@bossCapture endts mismatch, server=%s, local=%s, actorId=%s", endts, self.groupDropEndTsMap[actorId], actorId)

			return
		end

		if entity and entity.needDoGroupReward then
			if self.isKillBossFrameFreezing then
				local killBossFreezeDuration = SysConfigData.killBossFreezeDuration or 3
				local killBossFreezeDelay = SysConfigData.killBossFreezeDelay or 0

				self:addTimer(killBossFreezeDuration + killBossFreezeDelay, function()
					self:startBossCapture(actorId)
				end)
			else
				self:startBossCapture(actorId)
			end
		end
	elseif op == Const.GROUP_DROP_NOTIFY_HIDE_BOSS then
		local reason = unpack(params)

		if entity and entity.needDoGroupReward then
			if reason == Const.GROUP_DROP_HIDE_CAPTURE_SUCCESS then
				entity:playBossCatchHide(false)
			elseif reason == Const.GROUP_DROP_HIDE_CAPTURE_FAILED then
				entity:playBossCatchHide()
			elseif reason == Const.GROUP_DROP_HIDE_GIVEUP then
				entity:playBossCatchHide()
			end
		end

		self:finishBossCapture(actorId)
	elseif op == Const.GROUP_DROP_NOTIFY_CHEST_CREATED then
		local chestActorId = unpack(params)
		local chestEnt = pg.getEntityByActorId(chestActorId)

		if chestEnt then
			local entityId = pg.getEntityByActorId(chestActorId).id

			self.logger:debug("puppetdrop boss, recv notify chest Create, actorId=%d, op=%d, params=%s, chestId:%s", actorId, op, table.tostring(params), entityId, self:repr())
		end
	end

	self.logger:debug("puppetdrop boss, recv notify, actorId=%d, op=%d, params=%s", actorId, op, table.tostring(params), self:repr())
end

function ClientCaptureMainComponent:sendGroupDropChoice(actorId, choice, callBack)
	if pg.me and pg.me:isInFishingCapture() then
		return
	end

	self:serverMsg("RPC_CS_GroupDropChoice", actorId, choice, function(noticeId, noticeArgs)
		self.logger:debug("puppetdrop boss, player choice callback, notice=%s", NoticeDef.getRepr(noticeId), self:repr())

		if callBack then
			callBack(noticeId, noticeArgs)
		end
	end)
	self.logger:debug("puppetdrop boss, player choice, actorId=%d, choice=%d", actorId, choice, self:repr())
end

function ClientCaptureMainComponent:on_groupDropEndTsMap_changed(ov, nv)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("puppetdrop boss, endts change, nv=%s", inspect(nv.getRawTable and nv:getRawTable() or nv, {
			newline = " "
		}), self:repr())
	end

	AbilityUtils.setAbilityInvalidTarget(self, AbilityConst.INVALID_TARGET_REASONS.GROUP_DROP_END, self.groupDropEndTsMap and #self.groupDropEndTsMap > 0)
end

function ClientCaptureMainComponent:forceExitCaptureMode()
	self:switchContext()
end

function ClientCaptureMainComponent:EVENT_OnCharacterStateChange(oldState, newState)
	if CharacterStateConst.isChildOfState(newState, CharacterStateConst.CROUCHING) and not CharacterStateConst.isChildOfState(oldState, CharacterStateConst.CROUCHING) then
		self:setCrouchEnabled(true)
	end

	if CharacterStateConst.isChildOfState(oldState, CharacterStateConst.CROUCHING) and not CharacterStateConst.isChildOfState(newState, CharacterStateConst.CROUCHING) then
		self:setCrouchEnabled(false)
	end
end

function ClientCaptureMainComponent:switchCrouch()
	if self:CROUCH_ST() and not self:check_cancel_CROUCH_ST() then
		return false
	end

	self.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.Crouch)
end

function ClientCaptureMainComponent:isInSneakCrouch()
	if not self:isControllingMaster() then
		return false
	end

	return self:CROUCH_ST() and self.inGrass
end

function ClientCaptureMainComponent:refreshCrouchGrass()
	return
end

function ClientCaptureMainComponent:setCrouchEnabled(enable)
	self:refreshCrouchGrass()

	if enable then
		AIControllerUtils.sendAIEvent(self:getCurPetEntity(), "Msg_MasterCrouch")
	end
end

function ClientCaptureMainComponent:preDestroy()
	self:_clearBossCaptureResumeTimer()
	self:_clearCaptureBallVolumes()

	if self.currentContext then
		self.currentContext:destroy()

		self.currentContext = nil
	end

	if self.noBallContext then
		self.noBallContext.player = nil
	end
end

function ClientCaptureMainComponent:destroy()
	self.currentContext = nil
	self.noBallContext = nil
end

function ClientCaptureMainComponent:_playLeylineFlowerCaptureBall(clientPetInfo)
	local flowerStaticId = clientPetInfo.flowerStaticId
	local petStage = clientPetInfo.petStage
	local petPosX = clientPetInfo.petPosX
	local petPosY = clientPetInfo.petPosY
	local petPosZ = clientPetInfo.petPosZ
	local flowerPos = LeylineFlowerUtils.getFlowerPositionByStaticId(flowerStaticId, pg.me.space.sceneId, pg.me.space.id)

	if not flowerPos then
		self.logger:warn("@leylineflower capture reward: flower position not found, staticId=%s", flowerStaticId)

		return
	end

	local petPos = Vector3(petPosX, petPosY, petPosZ)
	local flowerEntity = pg.me.space:getEntityByStaticId(flowerStaticId)

	if not flowerEntity then
		self.logger:warn("@leylineflower capture reward: flower entity not found, staticId=%s", flowerStaticId)

		return
	end

	ClientLeylineFlowerCaptureRewardCtrl.playCaptureBall(petPos, flowerEntity, petStage)
	self.logger:info("@leylineflower capture reward: play ball, staticId=%s, stage=%s", flowerStaticId, petStage)
end

return ClientCaptureMainComponent
