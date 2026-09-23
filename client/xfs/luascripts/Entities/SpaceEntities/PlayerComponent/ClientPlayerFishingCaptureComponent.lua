-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerFishingCaptureComponent.lua

local Class = require("Core.Framework.Class")
local OpDef = require("Common.OpDef")
local NoticeDef = require("Common.NoticeDef")
local FishingCaptureConst = require("Common.Const.FishingCaptureConst")
local MessageName = require("Const.MessageName")
local TimerManager = require("Core.Timer.TimerManager")
local UIConst = require("Const.UIConst")
local FishingCaptureActivityData = require("Data.fishing_capture_activity_data")
local Utils = require("Common.Utils.Utils")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local AIUtils = require("Common.Utils.AIUtils")
local AiConst = require("Common.Const.AiConst")
local ClientUtils = require("Utils.ClientUtils")
local PlayableConst = require("Common.Const.PlayableConst")
local AbilityConst = require("Common.Const.AbilityConst")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local ClientConst = require("Const.ClientConst")
local AudioConst = require("Const.AudioConst")
local Phase = FishingCaptureConst.Phase
local SettleReason = FishingCaptureConst.SettleReason
local ClientPlayerFishingCaptureComponent = Class.Component("ClientPlayerFishingCaptureComponent")

function ClientPlayerFishingCaptureComponent:ctor()
	self._escapeWaitTimer = nil
	self._contractSettlementData = nil
	self._curBossPermEffId = nil
	self._curBossPermEffKey = nil
	self._bossInitEffRetryTimer = nil
	self._bossReconnectRestoreTimer = nil
end

function ClientPlayerFishingCaptureComponent:onEnterSpace()
	local gamePhase = self:getFishingCaptureCurrentPhase()

	self:_restoreBossEffectOnReconnect()

	if gamePhase == Phase.SETTLE then
		ClientUtils.exitDungeon()
	end
end

function ClientPlayerFishingCaptureComponent:onLeaveSpace()
	pg.global.ui.tips:hideCountDown("fishingCapture")
	pg.global.ui.tips:hideBossCatchWarning()
	pg.global.ui.tips:hideBossCatchTips()
	self:_clearBossTitleInvisibleReason()
	self:_stopContractEndBgm()
end

function ClientPlayerFishingCaptureComponent:_stopContractEndBgm()
	pg.game.audio:stopBgm(AudioConst.BgmPriority.FishingCaptureCubeUI)
end

function ClientPlayerFishingCaptureComponent:preDestroy()
	self:_clearBossPermEffect()
end

function ClientPlayerFishingCaptureComponent:destroy()
	self:_setInputBlock(false)
	self:_clearBossTitleInvisibleReason()

	if self._inputBlockTimer then
		TimerManager.removeTimer(self._inputBlockTimer)

		self._inputBlockTimer = nil
	end

	if self._escapeWaitTimer then
		TimerManager.removeTimer(self._escapeWaitTimer)

		self._escapeWaitTimer = nil
	end

	pg.global.ui:close(UIConst.UI_ID_FISHING_CAPTURE_RESULT)
	self:_stopContractEndBgm()
end

function ClientPlayerFishingCaptureComponent:sendFishingCaptureOp(op, params, callback)
	local localCallback = callback or function(noticeId, noticeArgs)
		if noticeId ~= NoticeDef.SUCCESS then
			pg.global.showBubbleMessageById(noticeId, noticeArgs)
		end

		self.logger:debug("@fishingCapture sendFishingCaptureOp callback, op=%s, res=%s", OpDef.repr(op, params), NoticeDef.getRepr(noticeId, noticeArgs))
	end

	self:serverMsg("RPC_CS_FishingCaptureOp", op, params or {}, localCallback)
end

function ClientPlayerFishingCaptureComponent:RPC_SC_FishingCaptureNotify(op, params)
	if op == OpDef.OP.SC_FC_PhaseChange then
		self:onPhaseChange(params)
	elseif op == OpDef.OP.SC_FC_CaptureSuccess then
		self:onCaptureSuccess(params)
	elseif op == OpDef.OP.SC_FC_SettleResult then
		self:onSettleResult(params)
	end

	self.logger:debug("@fishingCapture RPC_SC_FishingCaptureNotify", OpDef.repr(op, params))
end

function ClientPlayerFishingCaptureComponent:onPhaseChange(params)
	local phase = params and params.phase

	if phase == Phase.READY then
		self._contractSettlementData = nil

		self:_tryAttachBossInitialEffect()
	elseif phase == Phase.CAPTURE then
		self:_switchBossEffectToDeath()
	end
end

function ClientPlayerFishingCaptureComponent:onCaptureSuccess(params)
	if not params then
		return
	end

	self._contractSettlementData = params
end

function ClientPlayerFishingCaptureComponent:onSettleResult(params)
	pg.global.ui.tips:hideCountDown("fishingCapture")
	pg.global.ui.tips:hideBossCatchWarning()
	pg.global.ui.tips:hideBossCatchTips()

	if params.reason == SettleReason.CAPTURE_SUCCESS then
		if self._contractSettlementData then
			self._contractSettlementData.rewards = params.rewards
		end

		return
	else
		pg.me:forceExitCaptureMode()

		if pg.me and not CharacterStateConst.isChildOfState(pg.me.characterState, CharacterStateConst.LOCOMOTION) then
			AnimationUtils.playAnimationState(pg.me, CharacterStateConst.LOCOMOTION)
		end

		self:_setInputBlock(true)

		if params.reason == SettleReason.TIMEOUT then
			self:_playBossEscapeThen(function()
				self:_openFailResult(params)
			end, PlayableConst.Catch_End)
		elseif params.reason == SettleReason.BOSS_ESCAPE then
			pg.global.ui.tips:setBossTitleItemInvisibleReason("fishingCapture", false)
			self:_playBossEscapeThen(function()
				self:_openFailResult(params)
			end, PlayableConst.Die)
		elseif params.reason == SettleReason.PLAYER_QUIT or params.reason == SettleReason.PLAYER_DEAD then
			self:_openFailResult(params)
		else
			facade:SendMessageCommand(MessageName.FISHING_CAPTURE_SHOW_SETTLEMENT, params)
		end
	end
end

function ClientPlayerFishingCaptureComponent:onResultClose()
	self:_clearBossTitleInvisibleReason()
	ClientUtils.exitDungeon()
end

function ClientPlayerFishingCaptureComponent:onResultLoadingShown()
	self:_setInputBlock(false)
end

function ClientPlayerFishingCaptureComponent:_clearBossTitleInvisibleReason()
	local tips = pg.global and pg.global.ui and pg.global.ui.tips

	if tips and tips.setBossTitleItemInvisibleReason then
		tips:setBossTitleItemInvisibleReason("fishingCapture", true)
	end
end

function ClientPlayerFishingCaptureComponent:_playBossEscapeThen(callback, escapeAnim)
	local bossEnt = self:_getBossEnt()
	local waitSec = 2

	if bossEnt then
		if escapeAnim then
			bossEnt:stopAllAnimation()
		end

		if bossEnt.actorTimeline then
			bossEnt.actorTimeline:stopCombatActionTimeline()
		end

		if bossEnt.skillStateMgr then
			bossEnt.skillStateMgr:switchState(AbilityConst.SKILL_STATE_NONE)
		end

		if bossEnt.stopForceDisplacement then
			bossEnt:stopForceDisplacement()
		end

		AIUtils.pauseBt(bossEnt, AiConst.PauseBtReason.FishingCapture)

		if escapeAnim then
			bossEnt:playAnimation(escapeAnim, true)

			local clipLen = AnimationUtils.getPlayableClipLength(bossEnt, escapeAnim, 2)

			waitSec = math.min((clipLen or 2) - 0.2, 5)
		else
			waitSec = 2.7
		end
	end

	if self._escapeWaitTimer then
		TimerManager.removeTimer(self._escapeWaitTimer)

		self._escapeWaitTimer = nil
	end

	self._escapeWaitTimer = TimerManager.addTimer(waitSec, function()
		self._escapeWaitTimer = nil

		if bossEnt then
			bossEnt:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.BOSS_CATCH, false)
		end

		if callback then
			callback()
		end
	end)
end

function ClientPlayerFishingCaptureComponent:_openFailResult(params)
	self:_setInputBlock(false)
	pg.global.ui.deadPanel:open({
		hideCallForHelp = true,
		reason = params.reason,
		title = pg.getGameString("CHALLENGE_FAIL")
	})
end

function ClientPlayerFishingCaptureComponent:requestEnter(callback)
	self:sendFishingCaptureOp(OpDef.OP.CS_FC_Enter, {}, callback)
end

function ClientPlayerFishingCaptureComponent:requestExchangeCube(cubeType, callback)
	local params = {
		cubeType = cubeType
	}

	self:sendFishingCaptureOp(OpDef.OP.CS_FC_ExchangeTicket, params, function(noticeId, noticeArgs)
		local success = noticeId == NoticeDef.SUCCESS

		if not success then
			pg.global.showBubbleMessageById(noticeId, noticeArgs)
		end

		self.logger:debug("@fishingCapture requestExchangeCube callback, op=%s, res=%s", OpDef.repr(OpDef.OP.CS_FC_ExchangeTicket, params), NoticeDef.getRepr(noticeId, noticeArgs))

		if callback then
			callback(success, noticeId, noticeArgs)
		end
	end)
end

function ClientPlayerFishingCaptureComponent:requestStartBattle(callback)
	self:sendFishingCaptureOp(OpDef.OP.CS_FC_StartBattle, {}, callback)
end

function ClientPlayerFishingCaptureComponent:canConfirmFishingCaptureContract()
	if not self:isInFishingCapture() then
		return false
	end

	return self:getFishingCaptureCurrentPhase() == Phase.CAPTURE
end

function ClientPlayerFishingCaptureComponent:requestConfirmFishingCaptureContract(callback)
	if not self:canConfirmFishingCaptureContract() then
		return false
	end

	self:sendFishingCaptureOp(OpDef.OP.CS_FS_ForgeAPact, {}, function(noticeId, noticeArgs)
		local success = noticeId == NoticeDef.SUCCESS

		if not success then
			pg.global.showBubbleMessageById(noticeId, noticeArgs)
		end

		if callback then
			callback(success, noticeId, noticeArgs)
		end
	end)

	return true
end

function ClientPlayerFishingCaptureComponent:requestQuit(callback)
	if self:getFishingCaptureCurrentPhase() == Phase.SETTLE then
		ClientUtils.exitDungeon()
	else
		self:sendFishingCaptureOp(OpDef.OP.CS_FC_Quit, {}, callback)
	end
end

function ClientPlayerFishingCaptureComponent:getFishingCaptureContractSettlementData()
	return self._contractSettlementData
end

function ClientPlayerFishingCaptureComponent:isInFishingCapture()
	return pg.me and pg.me.space and Utils.isSpaceFishingCaptureDungeon(pg.me.space.spaceType) or false
end

function ClientPlayerFishingCaptureComponent:getFishingCaptureCurrentPhase()
	local space = pg.me and pg.me.space

	return space and space.gamePhase or Phase.READY
end

function ClientPlayerFishingCaptureComponent:getPhaseEndTs()
	local space = pg.me and pg.me.space

	return space and space.phaseEndTs or 0
end

function ClientPlayerFishingCaptureComponent:_getActivityConfig()
	local activityData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.FishingCapture)
	local phase = activityData and activityData:getCurPhase()

	if not phase or phase <= 0 then
		return nil
	end

	return FishingCaptureActivityData and FishingCaptureActivityData[phase]
end

function ClientPlayerFishingCaptureComponent:_getBossStaticId()
	local cfg = self:_getActivityConfig()

	return cfg and cfg.bossStaticId
end

function ClientPlayerFishingCaptureComponent:_getBossEnt()
	local bossStaticId = self:_getBossStaticId()

	if not bossStaticId then
		return nil
	end

	if pg.me and pg.me.space and pg.me.space.getEntityByStaticId then
		return pg.me.space:getEntityByStaticId(bossStaticId)
	end

	return nil
end

function ClientPlayerFishingCaptureComponent:_tryAttachBossInitialEffect()
	local cfg = self:_getActivityConfig()
	local itlEff = cfg and cfg.itlEff

	if not itlEff or itlEff == "" then
		return
	end

	local bossEnt = self:_getBossEnt()

	if bossEnt and bossEnt.playEffect then
		self:_attachBossPermEffect(bossEnt, itlEff)

		if self._bossInitEffRetryTimer then
			TimerManager.removeTimer(self._bossInitEffRetryTimer)

			self._bossInitEffRetryTimer = nil
		end

		return
	end

	if self._bossInitEffRetryTimer then
		return
	end

	self._bossInitEffRetryTimer = TimerManager.addTimer(0.5, function()
		self._bossInitEffRetryTimer = nil

		local gamePhase = self:getFishingCaptureCurrentPhase()

		if gamePhase == Phase.READY or gamePhase == Phase.BATTLE or gamePhase == Phase.TRANSITION or gamePhase == Phase.CAPTURE then
			self:_tryAttachBossInitialEffect()
		end
	end)
end

function ClientPlayerFishingCaptureComponent:_attachBossPermEffect(bossEnt, effKey)
	if not bossEnt or not bossEnt.playEffect then
		return
	end

	if not effKey or effKey == "" then
		return
	end

	if self._curBossPermEffId and bossEnt.stopEffectById then
		bossEnt:stopEffectById(self._curBossPermEffId)
	end

	self._curBossPermEffId = nil
	self._curBossPermEffKey = nil

	local effId = bossEnt:playEffect(effKey)

	if effId and effId ~= 0 then
		self._curBossPermEffId = effId
		self._curBossPermEffKey = effKey
	end
end

function ClientPlayerFishingCaptureComponent:_clearBossPermEffect()
	if self._bossInitEffRetryTimer then
		TimerManager.removeTimer(self._bossInitEffRetryTimer)

		self._bossInitEffRetryTimer = nil
	end

	if self._bossReconnectRestoreTimer then
		TimerManager.removeTimer(self._bossReconnectRestoreTimer)

		self._bossReconnectRestoreTimer = nil
	end

	if not self._curBossPermEffId then
		return
	end

	local bossEnt = self:_getBossEnt()

	if bossEnt and bossEnt.stopEffectById then
		bossEnt:stopEffectById(self._curBossPermEffId)
	end

	self._curBossPermEffId = nil
	self._curBossPermEffKey = nil
end

function ClientPlayerFishingCaptureComponent:_switchBossEffectToDeath()
	local cfg = self:_getActivityConfig()
	local effKey = cfg and cfg.deathEff

	if not effKey or effKey == "" then
		return
	end

	if self._curBossPermEffKey == effKey and self._curBossPermEffId then
		return
	end

	local bossEnt = self:_getBossEnt()

	if bossEnt then
		self:_attachBossPermEffect(bossEnt, effKey)
	end
end

function ClientPlayerFishingCaptureComponent:_restoreBossEffectOnReconnect()
	local gamePhase = self:getFishingCaptureCurrentPhase()

	if gamePhase ~= Phase.READY and gamePhase ~= Phase.BATTLE and gamePhase ~= Phase.TRANSITION and gamePhase ~= Phase.CAPTURE then
		if self._bossReconnectRestoreTimer then
			TimerManager.removeTimer(self._bossReconnectRestoreTimer)

			self._bossReconnectRestoreTimer = nil
		end

		return
	end

	local cfg = self:_getActivityConfig()
	local effKey

	if gamePhase == Phase.CAPTURE then
		effKey = cfg and cfg.deathEff
	else
		effKey = cfg and cfg.itlEff
	end

	if not effKey or effKey == "" then
		return
	end

	local bossEnt = self:_getBossEnt()

	if bossEnt and bossEnt.playEffect then
		self:_attachBossPermEffect(bossEnt, effKey)

		if self._bossReconnectRestoreTimer then
			TimerManager.removeTimer(self._bossReconnectRestoreTimer)

			self._bossReconnectRestoreTimer = nil
		end

		return
	end

	if self._bossReconnectRestoreTimer then
		return
	end

	self._bossReconnectRestoreTimer = TimerManager.addTimer(0.5, function()
		self._bossReconnectRestoreTimer = nil

		self:_restoreBossEffectOnReconnect()
	end)
end

local FC_INPUT_BLOCK_KEY = "FishingCaptureEffect"
local FC_INPUT_BLOCK_MAX_SEC = 15

function ClientPlayerFishingCaptureComponent:_setInputBlock(block)
	pg.game.input:setBlockInput(FC_INPUT_BLOCK_KEY, block)

	if self._inputBlockTimer then
		TimerManager.removeTimer(self._inputBlockTimer)

		self._inputBlockTimer = nil
	end

	if block then
		self._inputBlockTimer = TimerManager.addTimer(FC_INPUT_BLOCK_MAX_SEC, function()
			self._inputBlockTimer = nil

			self.logger:warn("@fishingCapture input block safety timeout, force unblock")
			pg.game.input:setBlockInput(FC_INPUT_BLOCK_KEY, false)
		end)
	end
end

return ClientPlayerFishingCaptureComponent
