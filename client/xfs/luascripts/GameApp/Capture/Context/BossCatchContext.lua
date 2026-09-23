-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Capture\\Context\\BossCatchContext.lua

local Class = require("Core.Framework.Class")
local logger = require("Core.Log.LoggerManager").getLogger("BossCatchContext")
local castItemData = require("Data.cast_item_data")
local ItemEffectData = require("Data.item_effect_data")
local ThrowParabola = require("GameApp.Capture.ThrowParabola")
local ThrowBallContext = require("GameApp.Capture.Context.ThrowBallContext")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local InputCommand = require("GameApp.Input.InputCommand")
local EventConst = require("Const.EventConst")
local ClientConst = require("Const.ClientConst")
local SysConfigData = require("Data.sys_config_data")
local CallbackHandler = require("Core.Common.CallbackHandler")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local CharacterUpperState = require("Common.Const.CharacterUpperState")
local ConflictTypes = require("Common.ConflictTypes")
local Const = require("Common.Const.Const")
local PlayableEventConst = require("Const.PlayableEventConst")
local CaptureFsm = require("GameApp.Capture.CaptureFsm")
local InputFsm = require("GameApp.Input.InputFsm")
local HotKeyConst = require("Const.HotkeyConst")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local Vector3 = Vector3
local MessageName = require("Const.MessageName")
local BossCatchContext = Class.LightClass("BossCatchContext", ThrowBallContext)

function BossCatchContext:ctor(player, itemId)
	ThrowBallContext.ctor(self, player, itemId)

	self.target = nil
end

function BossCatchContext:enter(fromContext)
	self:enableCatchMode(true, false, true)
	ThrowBallContext.enter(self)

	self.player.eModel.AlwaysLookForward = true
	self.player.eModel.ThrowAnimType = self.ballData.animType

	pg.game.camera.playerCameraMode.catchCamera:setTarget(self.target)
	pg.global.ui:open(UIConst.UI_ID_CATCHBOSS_NEW, {
		bossEntity = self.target
	})
	facade:sendMsgToUI(MessageName.START_CATCH_BOSS)
end

function BossCatchContext:setTarget(target, alreadyHolding, isFree)
	self.target = target
	self.alreadyHolding = alreadyHolding
	self.isFree = isFree == true
	self.targetCatchEndTs = pg.me.groupDropEndTsMap[target.actorId] or 0
end

function BossCatchContext:hold()
	if self.ballEnt then
		return false
	end

	if not self.isFree and not ClientCaptureUtils.checkBallItem(self.itemId) then
		if not ClientCaptureUtils.hasBall() then
			self:exitCatchMode()

			return false
		else
			self:doSwitch()

			return false
		end
	end

	self:_clear()
	self:createBall()
	self.eventEmitter:onceEventListener(PlayableEventConst.fireBall, function()
		self:fireBall()
	end)

	return true
end

function BossCatchContext:createBall()
	self.envId = pg.game.envObj:genEnvId()
	self.ballEnt = self.player:SyncCaptureHoldBall(self.envId, self.itemId, true, true)

	if self.ballEnt and self.player.onBossCatchBallCreated then
		self.player:onBossCatchBallCreated(self.ballEnt, self.target and self.target.actorId)
	end

	self.player:serverMsg("RPC_CS_CaptureHoldBall", self.envId, self.itemId)
end

function BossCatchContext:fireBall()
	if self.ballEnt then
		pg.me:onBossCatchFireBall(self.ballEnt, self.target and self.target.actorId)

		if self.ballEnt.isBossCapturePerformanceCancelled and self.ballEnt:isBossCapturePerformanceCancelled() then
			pg.global.ui.tips:hideCountDown("BossCapture")

			return
		end

		self.ballEnt:bossQuickFire(self.target, SysConfigData.BREAKCATCH_INITSPEED, self.itemId, self.isFree)
	end

	pg.global.ui.tips:hideCountDown("BossCapture")
end

function BossCatchContext:doThrow()
	if self.waitThrowTimer then
		TimerManager.removeTimer(self.waitThrowTimer)

		self.waitThrowTimer = nil
	end

	self.waitThrowTimer = TimerManager.addRepeatTimer(0.1, function()
		if not self.ballEnt or self.ballEnt.destroyed then
			TimerManager.removeTimer(self.waitThrowTimer)

			self.waitThrowTimer = nil

			return
		end

		if self.ballEnt.isModelLoaded then
			TimerManager.removeTimer(self.waitThrowTimer)

			self.waitThrowTimer = nil

			pg.global.ui:close(UIConst.UI_ID_CATCHBOSS_NEW)
			ThrowBallContext.doThrow(self)
		end
	end)
end

function BossCatchContext:throwEnd(breaked)
	self.player.eModel:ForceChangeToUpperState(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, CharacterUpperState.EMPTY)

	self.waitExitTimer = TimerManager.addRepeatTimer(1, function()
		TimerManager.removeTimer(self.waitExitTimer)

		self.waitExitTimer = nil

		if pg.me:isInBossCatch() then
			self:exitCatchMode()
			pg.game.input:enableControlInput(true, HotKeyConst.INPUT_BLOCK_FLAG.CatchBoss)
		end
	end)
end

function BossCatchContext:exit()
	return false
end

function BossCatchContext:doSwitch()
	local itemId
	local isFree = false

	if pg.global.ui:checkUIShow(UIConst.UI_ID_CATCHBOSS_NEW) then
		itemId = pg.global.ui.catchBossNew:getCurSelectPropId()
		isFree = pg.global.ui.catchBossNew:isCurSelectFree()
	elseif pg.global.ui:checkUIShow(UIConst.UI_ID_CATCHBOSS) then
		itemId = pg.global.ui.catchBoss:getCurSelectPropId()
	end

	if not itemId then
		self:process()

		return
	end

	if itemId == self.itemId then
		self.isFree = isFree == true

		self:process()

		return
	end

	if not isFree and not ClientCaptureUtils.checkBallItem(itemId, true) then
		return
	end

	if self.player:CROUCH_ST() then
		self.player.eModel:ForceChangeToState(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, CharacterStateConst.CROUCHIDLE)
	else
		self.player.eModel:ForceChangeToState(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, CharacterStateConst.IDLE)
	end

	self.itemId = itemId
	self.isFree = isFree == true
	self.castItemId = Utils.itemId2CastItemId(self.itemId)
	self.ballData = castItemData[self.castItemId]

	if self.ballData then
		self.player.eModel.ThrowAnimType = self.ballData.animType
	end

	self:_clear()
	self:createBall()
	self.eventEmitter:onceEventListener(PlayableEventConst.fireBall, function()
		self:fireBall()
	end)
end

function BossCatchContext:destroy()
	if self.waitThrowTimer then
		TimerManager.removeTimer(self.waitThrowTimer)

		self.waitThrowTimer = nil
	end

	if self.waitExitTimer then
		TimerManager.removeTimer(self.waitExitTimer)

		self.waitExitTimer = nil
	end

	pg.global.ui:close(UIConst.UI_ID_CATCHBOSS_NEW)
	pg.global.ui:close(UIConst.UI_ID_CATCHBOSS)

	self.player.eModel.AlwaysLookForward = false
	self.target = nil

	ThrowBallContext.destroy(self)
end

function BossCatchContext:_clear()
	self.eventEmitter:removeAllListeners(PlayableEventConst.fireBall)

	if self.ballEnt and not self.ballEnt.fired then
		self.player:SyncCaptureClearBall(self.envId)
		self.player:serverMsg("RPC_CS_CaptureClearBall", self.envId)

		self.ballEnt = nil
	end
end

return BossCatchContext
