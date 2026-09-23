-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Capture\\Context\\ThrowBallContext.lua

local Class = require("Core.Framework.Class")
local logger = require("Core.Log.LoggerManager").getLogger("ThrowBallContext")
local castItemData = require("Data.cast_item_data")
local ItemEffectData = require("Data.item_effect_data")
local ThrowParabola = require("GameApp.Capture.ThrowParabola")
local InputCommand = require("GameApp.Input.InputCommand")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local Utils = require("Common.Utils.Utils")
local TimerManager = require("Core.Timer.TimerManager")
local CharacterUpperState = require("Common.Const.CharacterUpperState")
local PlayableEventConst = require("Const.PlayableEventConst")
local InputFsm = require("GameApp.Input.InputFsm")
local CaptureFsm = require("GameApp.Capture.CaptureFsm")
local NoticeDef = require("Common.NoticeDef")
local ConflictTypes = require("Common.ConflictTypes")
local ClientConst = require("Const.ClientConst")
local VoxelConst = require("Common.Const.VoxelConst")
local EventConst = require("Const.EventConst")
local CaptureConst = require("Common.Const.CaptureConst")
local PlayableConst = require("Common.Const.PlayableConst")
local commands = CaptureFsm.commands
local states = CaptureFsm.states
local NoBallContext = require("GameApp.Capture.Context.NoBallContext")
local TriggerUtils = require("Common.Utils.TriggerUtils")
local TriggerConst = require("Common.Const.TriggerConst")
local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")
local ThrowBallContext = Class.LightClass("ThrowBallContext", NoBallContext)

ThrowBallContext.CAPTURE_STEERING_TIME = 0.1

function ThrowBallContext._getHoldAnimKey(animType, isCrouch, isMoving)
	if isCrouch then
		if isMoving then
			return animType == 2 and PlayableConst.Crouch_HoldBigBall_Move or PlayableConst.Crouch_HoldBall_Move
		else
			return animType == 2 and PlayableConst.Crouch_HoldBigBall_Idle or PlayableConst.Crouch_HoldBall_Idle
		end
	elseif isMoving then
		return animType == 2 and PlayableConst.HoldBigBall_Move or PlayableConst.HoldBall_Move
	else
		return animType == 2 and PlayableConst.HoldBigBall_Idle or PlayableConst.HoldBall_Idle
	end
end

function ThrowBallContext:ctor(player, itemId)
	self.player = player
	self.eventEmitter = self.player.eventEmitter
	self.itemId = itemId
	self.castItemId = Utils.itemId2CastItemId(self.itemId)
	self.ballData = castItemData[self.castItemId]
end

function ThrowBallContext:enter(fromContext)
	self.player.eModel:ForceChangeToUpperState(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, CharacterUpperState.THROWHOLD)
	self:hold()

	if fromContext and fromContext.fsm then
		self.fsm = fromContext.fsm
	else
		self.fsm = InputFsm.new(CaptureFsm)
	end

	self.state = self.fsm.state

	if fromContext then
		self:process()
	end
end

function ThrowBallContext:exit()
	self.fsm:addCommand(commands.EnterExit)

	if self.state == states.T then
		return false
	end

	self:process()

	return true
end

function ThrowBallContext:throw()
	if not self:isThrowPreInputValid() then
		return
	end

	if not self:checkBallCanThrow() then
		return
	end

	self.fsm:addCommand(commands.Throw)

	if self.state == states.T then
		return
	end

	self:process()
end

function ThrowBallContext:switch()
	self.fsm:addCommand(commands.SwitchItem)

	if self.state == states.T then
		return
	end

	self:process()
end

function ThrowBallContext:isThrowPreInputValid()
	return self.state ~= states.T or self._isCurrentThrowFired == true
end

function ThrowBallContext:throwWithRpc(cb, failCallback, timeoutCallback)
	local catchMode = self.player:isInQuickCapture() and CaptureConst.CATCH_TYPE.Quick or CaptureConst.CATCH_TYPE.Normal

	self.player:serverMsg("RPC_CS_FireBall", self.ballEnt.itemId, self.ballEnt.ballUid, catchMode, function(code)
		if code ~= 0 then
			if pg.logError() then
				logger:error("@capture throwWithRpc fail! failCode: %s", code)
			end

			if code then
				pg.global.showBubbleMessageById(code)
			end

			if failCallback then
				if self.throwTimer then
					TimerManager.removeTimer(self.throwTimer)

					self.throwTimer = nil
				end

				failCallback(code)
			end

			return
		end

		if self.throwTimer and not self._triggerTimer then
			TimerManager.removeTimer(self.throwTimer)

			self.throwTimer = nil

			if cb then
				cb()
			end
		end
	end)

	self._triggerTimer = false
	self.throwTimer = TimerManager.addTimer(2, function()
		self._triggerTimer = true
		self.throwTimer = nil

		if timeoutCallback then
			timeoutCallback()

			return
		end

		self:exitCatchMode()
	end)
end

function ThrowBallContext:throwBreak()
	self:process()
end

function ThrowBallContext:throwEnd(breaked)
	self:hold()

	if not breaked then
		self:throwBreak()
	end
end

function ThrowBallContext:hold()
	if self.ballEnt then
		return false
	end

	if not ClientCaptureUtils.checkBallItem(self.itemId) then
		local nextItemId = pg.global.ui.hudV2:getCurSelectPropId()

		if not ClientCaptureUtils.isPaidBall(self.itemId) and ClientCaptureUtils.isPaidBall(nextItemId) then
			self:exitCatchMode()

			return false
		end

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

function ThrowBallContext:process()
	self.state = self.fsm:read()

	if self.state == states.T then
		self._isCurrentThrowFired = false

		self:doThrow()
	elseif self.state == states.E then
		self:exitCatchMode()
	elseif self.state == states.S then
		self:doSwitch()
	end
end

function ThrowBallContext:exitCatchMode()
	self.player:switchContext()
end

function ThrowBallContext:doThrow()
	self.player.eModel:ForceChangeToUpperState(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, CharacterUpperState.EMPTY)
	self.player.eModel:ForceChangeToUpperState(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, CharacterUpperState.THROWRELEASE)
end

function ThrowBallContext:doSwitch()
	local itemId = pg.global.ui.hudV2:getCurSelectPropId()

	if itemId == self.itemId then
		self:process()

		return
	end

	local player = self.player
	local isCrouch = player:CROUCH_ST()
	local moveAxis = pg.game.controller.moveAxis
	local isMoving = moveAxis ~= nil and (moveAxis[1] ~= 0 or moveAxis[2] ~= 0)
	local oldAnimKey = ThrowBallContext._getHoldAnimKey(self.ballData.animType, isCrouch, isMoving)
	local context = ClientCaptureUtils.getThrowContext(player, itemId)

	player:switchContext(context)

	local newContext = player.currentContext

	if newContext and newContext.ballData then
		player:setSteering(ThrowBallContext.CAPTURE_STEERING_TIME, false, false)

		local newAnimKey = ThrowBallContext._getHoldAnimKey(newContext.ballData.animType, isCrouch, isMoving)

		if newAnimKey ~= oldAnimKey then
			player:playAnimation(newAnimKey)
		end
	end
end

function ThrowBallContext:createBall()
	self.envId = pg.game.envObj:genEnvId()
	self.ballEnt = self.player:SyncCaptureHoldBall(self.envId, self.itemId, true)

	self.player:serverMsg("RPC_CS_CaptureHoldBall", self.envId, self.itemId)
end

function ThrowBallContext:markCurrentThrowFired()
	self._isCurrentThrowFired = true
end

function ThrowBallContext:fireBall()
	self:markCurrentThrowFired()

	self.ballEnt = nil
end

function ThrowBallContext:_clear()
	if self.eventEmitter then
		self.eventEmitter:removeAllListeners(PlayableEventConst.fireBall)
	end

	if self.ballEnt then
		self.player:SyncCaptureClearBall(self.envId)
		self.player:serverMsg("RPC_CS_CaptureClearBall", self.envId)

		self.ballEnt = nil
	end

	if self.throwTimer then
		TimerManager.removeTimer(self.throwTimer)

		self.throwTimer = nil
	end
end

function ThrowBallContext:checkBallCanThrow()
	local emptySlotNum = TriggerUtils.getStatusTriggerCurValue(self.player, TriggerConst.TRIGGER_PET_REMAINDER_NUM)

	if emptySlotNum < 1 then
		if not self.lastNoticeTs or Time.realSecondCache - self.lastNoticeTs >= 1.5 then
			pg.global.showBubbleMessageById(NoticeDef.PET_EMPTY_REMAIN_CATCH_BALL)

			self.lastNoticeTs = Time.realSecondCache
		end

		return false
	end

	return ClientCaptureUtils.checkBallCanThrow(self.itemId)
end

function ThrowBallContext:destroy()
	self.player.eModel:ForceChangeToUpperState(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, CharacterUpperState.EMPTY)
	self:_clear()

	self.player = nil
	self.eventEmitter = nil
	self.itemId = nil
	self.castItemId = nil
	self.ballData = nil
	self.lastNoticeTs = nil
	self._isCurrentThrowFired = nil
end

return ThrowBallContext
