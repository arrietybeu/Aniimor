-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Capture\\Context\\CameraThrowContext.lua

local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("CameraThrowContext")
local ThrowParabola = require("GameApp.Capture.ThrowParabola")
local ThrowBallContext = require("GameApp.Capture.Context.ThrowBallContext")
local InputCommand = require("GameApp.Input.InputCommand")
local PlayableEventConst = require("Const.PlayableEventConst")
local TimerManager = require("Core.Timer.TimerManager")
local CaptureFsm = require("GameApp.Capture.CaptureFsm")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local states = CaptureFsm.states
local CameraThrowContext = Class.LightClass("CameraThrowContext", ThrowBallContext)
local STUCK_GUARD_TIME = 1.5
local CONTINUOUS_THROW_INTERVAL = 0.05

function CameraThrowContext:ctor(player, itemId)
	ThrowBallContext.ctor(self, player, itemId)
end

function CameraThrowContext:_clearContinuousThrowTimer()
	if self._continuousThrowTimer then
		TimerManager.removeTimer(self._continuousThrowTimer)

		self._continuousThrowTimer = nil
	end
end

function CameraThrowContext:_setContinuousThrowWaitReason(reason)
	if self._continuousThrowWaitReason == reason then
		return
	end

	self._continuousThrowWaitReason = reason

	if reason then
		logger:info("@capture continuousThrow CT-06 wait, itemId=%s, reason=%s", tostring(self.itemId), tostring(reason))
	end
end

function CameraThrowContext:stopContinuousThrow(reason)
	local wasActive = self._continuousThrowHeld or self._continuousThrowTimer

	self._continuousThrowHeld = false

	self:_clearContinuousThrowTimer()
	self:_setContinuousThrowWaitReason(nil)

	if wasActive then
		logger:info("@capture continuousThrow CT-03 stop, itemId=%s, reason=%s", tostring(self.itemId), tostring(reason or "unknown"))
	end
end

function CameraThrowContext:startContinuousThrow()
	if self._continuousThrowHeld then
		return false
	end

	if not self.player or self.player.currentContext ~= self then
		return
	end

	if not self.ballData or self.ballData.proxy ~= "CatchBall" then
		return
	end

	self._continuousThrowHeld = true

	self:_setContinuousThrowWaitReason(nil)
	logger:info("@capture continuousThrow CT-01 start, itemId=%s", tostring(self.itemId))
	self:_scheduleContinuousThrow()

	return true
end

function CameraThrowContext:_scheduleContinuousThrow()
	if not self._continuousThrowHeld or self._continuousThrowTimer then
		return
	end

	self._continuousThrowTimer = TimerManager.addRepeatTimer(CONTINUOUS_THROW_INTERVAL, function()
		if not self._continuousThrowHeld then
			self:_clearContinuousThrowTimer()

			return
		end

		self:_tryContinuousThrow()
	end)
end

function CameraThrowContext:_tryContinuousThrow()
	if not self._continuousThrowHeld then
		self:_clearContinuousThrowTimer()

		return
	end

	if not self.player or self.player.currentContext ~= self then
		self:stopContinuousThrow("context_changed")

		return
	end

	if not self.ballData or self.ballData.proxy ~= "CatchBall" then
		self:stopContinuousThrow("special_ball")

		return
	end

	if self.state == states.T then
		self:_setContinuousThrowWaitReason("fsm_throwing")

		return
	end

	if self.throwTimer or self._triggerTimer or self._stuckTimer then
		self:_setContinuousThrowWaitReason("throw_guard")

		return
	end

	if not self:checkBallCanThrow() then
		self:stopContinuousThrow("ball_unavailable")

		return
	end

	if not self.ballEnt then
		if not ClientCaptureUtils.checkBallItem(self.itemId) then
			self:stopContinuousThrow("ball_depleted")

			return
		end

		self:_setContinuousThrowWaitReason("waiting_hold_ball")

		return
	end

	if not self.ballEnt:isBallReady() then
		self:_setContinuousThrowWaitReason("ball_not_ready")

		return
	end

	self:_setContinuousThrowWaitReason(nil)
	self:_clearContinuousThrowTimer()

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("@capture continuousThrow CT-02 dispatch, itemId=%s, ballUid=%s", tostring(self.itemId), tostring(self.ballEnt.ballUid))
	end

	self:throw()

	if self.state ~= states.T then
		self:_setContinuousThrowWaitReason("dispatch_rejected")
		self:_scheduleContinuousThrow()
	end
end

function CameraThrowContext:_onContinuousThrowRpcFailed(code)
	logger:warn("@capture continuousThrow CT-04 rpcFailed, itemId=%s, code=%s", tostring(self.itemId), tostring(code))
	self:stopContinuousThrow("rpc_failed")

	if self.player and self.player.currentContext == self then
		self:exitCatchMode()
	end
end

function CameraThrowContext:_onContinuousThrowRpcTimeout()
	logger:warn("@capture continuousThrow CT-05 rpcTimeout, itemId=%s", tostring(self.itemId))
	self:stopContinuousThrow("rpc_timeout")

	if self.player and self.player.currentContext == self then
		self:exitCatchMode()
	end
end

function CameraThrowContext:enter(fromContext)
	self.player.eModel.AlwaysLookForward = true
	self.player.eModel.ThrowAnimType = self.ballData.animType

	local notifyUI = not fromContext or fromContext.className ~= self.className

	self:enableCatchMode(true, nil, nil, notifyUI)
	ThrowBallContext.enter(self, fromContext)
end

function CameraThrowContext:throw()
	if not self.ballEnt then
		return
	end

	if not self.ballEnt:isBallReady() then
		return
	end

	ThrowBallContext.throw(self)
end

function CameraThrowContext:hold()
	local success = ThrowBallContext.hold(self)

	if success and self._continuousThrowHeld then
		self:_scheduleContinuousThrow()
	end

	return success
end

function CameraThrowContext:doThrow()
	if not self.ballEnt or not self.ballEnt:isBallReady() then
		self.state = self.fsm.start

		return
	end

	local function cb()
		ThrowBallContext.doThrow(self)
		self:_startStuckGuard()
		self.eventEmitter:onceEventListener(PlayableEventConst.holdBall, function()
			self:hold()
		end)
	end

	local failCallback, timeoutCallback

	if self._continuousThrowHeld then
		function failCallback(code)
			self:_onContinuousThrowRpcFailed(code)
		end

		function timeoutCallback()
			self:_onContinuousThrowRpcTimeout()
		end
	end

	self:throwWithRpc(cb, failCallback, timeoutCallback)
end

function CameraThrowContext:throwEnd(breaked)
	self:_clearStuckGuard()

	if breaked then
		self:stopContinuousThrow("throw_break")
	end

	ThrowBallContext.throwEnd(self, breaked)
end

function CameraThrowContext:doSwitch()
	self:stopContinuousThrow("switch_item")
	ThrowBallContext.doSwitch(self)
end

function CameraThrowContext:_startStuckGuard()
	self:_clearStuckGuard()

	self._stuckTimer = TimerManager.addTimer(STUCK_GUARD_TIME, function()
		self:_onStuckGuard()
	end)
end

function CameraThrowContext:_clearStuckGuard()
	if self._stuckTimer then
		TimerManager.removeTimer(self._stuckTimer)

		self._stuckTimer = nil
	end
end

function CameraThrowContext:_onStuckGuard()
	self._stuckTimer = nil

	if self.state ~= states.T then
		return
	end

	if pg.logError() then
		logger:error("@capture CameraThrowContext stuck in T state, force recover. itemId=%s", self.itemId)
	end

	self.fsm:clear()

	self.state = self.fsm.state

	self:throwEnd(false)
end

function CameraThrowContext:fireBall()
	if self.ballEnt then
		local v = self.ballData.maxV

		self.ballEnt:fire(v)
	end

	ThrowBallContext.fireBall(self)
end

function CameraThrowContext:_clear()
	if self.eventEmitter then
		self.eventEmitter:removeAllListeners(PlayableEventConst.holdBall)
	end

	ThrowBallContext._clear(self)
end

function CameraThrowContext:destroy()
	self:stopContinuousThrow("context_destroy")
	self:_clearStuckGuard()

	self.player.eModel.AlwaysLookForward = false

	ThrowBallContext.destroy(self)
end

return CameraThrowContext
