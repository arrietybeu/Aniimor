-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformPaymentReconcileService.lua

local logger = require("SDK.Platform.PlatformLogger")
local TimerManager = require("Core.Timer.TimerManager")
local RechargeConst = require("GameApp.Recharge.RechargeConst")
local Const = require("Common.Const.Const")
local Time = require("Core.Common.Time")
local PlatformPaymentReconcileService = {}

PlatformPaymentReconcileService.CALL_INTERVAL = 30
PlatformPaymentReconcileService.POLL_INTERVAL = 300
PlatformPaymentReconcileService.state = {
	initialized = false
}

function PlatformPaymentReconcileService.nowSeconds()
	return Time.getSecond()
end

function PlatformPaymentReconcileService.canRun()
	local platform = pg and pg.global and pg.global.platform

	if not platform then
		return false
	end

	return platform:isConsoleFamily()
end

function PlatformPaymentReconcileService.shouldPoll()
	local recharge = pg and pg.game and pg.game.recharge

	if recharge then
		local state = recharge.getState and recharge:getState()

		if state == RechargeConst.STATE.PAYING then
			return true
		end

		if recharge.getPendingOrder and recharge:getPendingOrder() ~= nil then
			return true
		end
	end

	return pg and pg.me and Const.PlayerActionState and pg.me.actionState == Const.PlayerActionState.AFK
end

function PlatformPaymentReconcileService.reconcile(reason, ignoreInterval)
	if not PlatformPaymentReconcileService.canRun() then
		return false
	end

	local now = PlatformPaymentReconcileService.nowSeconds()
	local lastCallTime = PlatformPaymentReconcileService.state.lastCallTime
	local elapsed = lastCallTime ~= nil and now - lastCallTime or nil

	if not ignoreInterval and elapsed ~= nil and elapsed >= 0 and elapsed < PlatformPaymentReconcileService.CALL_INTERVAL then
		logger:debug("PlatformPaymentReconcileService: skip reconcilePayments reason=%s elapsed=%s", tostring(reason), tostring(elapsed))

		return false
	end

	if pg and pg.global and pg.global.sdkManager and pg.global.sdkManager.reconcilePayments then
		PlatformPaymentReconcileService.state.lastCallTime = now

		logger:info("PlatformPaymentReconcileService: call reconcilePayments reason=%s", tostring(reason))
		pg.global.sdkManager:reconcilePayments(reason)

		return true
	end

	logger:warn("PlatformPaymentReconcileService: sdkManager not ready reason=%s", tostring(reason))

	return false
end

function PlatformPaymentReconcileService.flushForegroundReconcile()
	local reason = PlatformPaymentReconcileService.state.pendingForegroundReason or "foreground"

	PlatformPaymentReconcileService.state.foregroundFrameId = nil
	PlatformPaymentReconcileService.state.pendingForegroundReason = nil

	PlatformPaymentReconcileService.reconcile(reason, true)
end

function PlatformPaymentReconcileService.onForeground(reason)
	if not PlatformPaymentReconcileService.canRun() then
		return
	end

	if PlatformPaymentReconcileService.state.foregroundFrameId ~= nil then
		logger:debug("PlatformPaymentReconcileService: coalesce foreground reconcile reason=%s pendingReason=%s", tostring(reason), tostring(PlatformPaymentReconcileService.state.pendingForegroundReason))

		return
	end

	PlatformPaymentReconcileService.state.pendingForegroundReason = reason or "foreground"
	PlatformPaymentReconcileService.state.foregroundFrameId = TimerManager.addNextFrameCb(PlatformPaymentReconcileService.flushForegroundReconcile)
end

function PlatformPaymentReconcileService.stopPolling()
	if PlatformPaymentReconcileService.state.pollTimerId ~= nil then
		TimerManager.removeTimer(PlatformPaymentReconcileService.state.pollTimerId)

		PlatformPaymentReconcileService.state.pollTimerId = nil
	end
end

function PlatformPaymentReconcileService.startPolling()
	if PlatformPaymentReconcileService.state.pollTimerId ~= nil then
		return
	end

	if not PlatformPaymentReconcileService.canRun() then
		return
	end

	PlatformPaymentReconcileService.state.pollTimerId = TimerManager.addRepeatTimer(PlatformPaymentReconcileService.POLL_INTERVAL, function()
		if PlatformPaymentReconcileService.shouldPoll() then
			PlatformPaymentReconcileService.reconcile("poll")
		end
	end)
end

function PlatformPaymentReconcileService:init()
	if PlatformPaymentReconcileService.state.initialized then
		return true
	end

	if not PlatformPaymentReconcileService.canRun() then
		return false
	end

	PlatformPaymentReconcileService.state.initialized = true

	PlatformPaymentReconcileService.startPolling()
	logger:info("PlatformPaymentReconcileService: initialized")

	return true
end

return PlatformPaymentReconcileService
