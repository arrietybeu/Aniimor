-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformPLMService.lua

local logger = require("SDK.Platform.PlatformLogger")
local TimerManager = require("Core.Timer.TimerManager")
local PlatformCrossPlatformService = require("SDK.Platform.PlatformCrossPlatformService")
local GlobalData = require("Core.Client.GlobalData")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformPaymentReconcileService = require("SDK.Platform.PlatformPaymentReconcileService")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local PlatformPLMService = {}

PlatformPLMService.state = {
	pendingUnconstrainRefresh = false,
	pendingResumeRefresh = false,
	isSuspended = false,
	callbackRegistered = false,
	initialized = false,
	retryCount = 0
}
PlatformPLMService.RETRY_DELAY = 1
PlatformPLMService.RETRY_WARN_INTERVAL = 5

function PlatformPLMService.isPLMSupported()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.RegisterPLMCallbacks ~= nil
end

function PlatformPLMService.isPlatformPrivacyContextReady()
	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.IsPermissionContextReady then
		return true
	end

	return PlatformBridgeLuaFacade.IsPermissionContextReady() == true
end

function PlatformPLMService.refreshPlatformPrivacyCaches(source)
	if not PlatformPLMService.isPlatformPrivacyContextReady() then
		logger:info("PlatformPLMService: skip privacy cache refresh, permission context not ready source=%s", tostring(source))

		return false
	end

	PlatformIdentityUtils.refreshPrivacyCachesIfNotPS("plm_privacy_refresh", source)

	if source == "resume" then
		PlatformIdentityUtils.refreshPrivacyCachesIfPS("plm_privacy_refresh", source)
	end

	return true
end

function PlatformPLMService.stopRetryTimer()
	if PlatformPLMService.state.retryTimer ~= nil then
		TimerManager.removeTimer(PlatformPLMService.state.retryTimer)

		PlatformPLMService.state.retryTimer = nil
	end
end

local flushPendingPlatformRefresh

function PlatformPLMService.schedulePendingRefreshRetry()
	if PlatformPLMService.state.retryTimer ~= nil then
		return
	end

	PlatformPLMService.state.retryCount = PlatformPLMService.state.retryCount + 1

	if PlatformPLMService.state.retryCount % PlatformPLMService.RETRY_WARN_INTERVAL == 0 then
		logger:warn("PlatformPLMService: pending platform refresh still waiting retry=%s resume=%s unconstrain=%s", tostring(PlatformPLMService.state.retryCount), tostring(PlatformPLMService.state.pendingResumeRefresh), tostring(PlatformPLMService.state.pendingUnconstrainRefresh))
	end

	PlatformPLMService.state.retryTimer = TimerManager.addTimer(PlatformPLMService.RETRY_DELAY, function()
		PlatformPLMService.state.retryTimer = nil

		flushPendingPlatformRefresh()
	end)
end

function flushPendingPlatformRefresh()
	if not PlatformPLMService.state.pendingResumeRefresh and not PlatformPLMService.state.pendingUnconstrainRefresh then
		PlatformPLMService.stopRetryTimer()

		PlatformPLMService.state.retryCount = 0

		return false
	end

	local source = PlatformPLMService.state.pendingResumeRefresh and "resume" or "unconstrain"

	if not PlatformPLMService.refreshPlatformPrivacyCaches(source) then
		PlatformPLMService.schedulePendingRefreshRetry()

		return false
	end

	PlatformPLMService.stopRetryTimer()

	PlatformPLMService.state.retryCount = 0
	PlatformPLMService.state.pendingResumeRefresh = false
	PlatformPLMService.state.pendingUnconstrainRefresh = false

	PlatformCrossPlatformService:revalidateAgainstSystemPrivilege()

	return true
end

function PlatformPLMService.onSuspend()
	logger:info("PlatformPLMService: onSuspend - 应用正在挂起")

	PlatformPLMService.state.isSuspended = true
	PlatformPLMService.state.pendingResumeRefresh = false
	PlatformPLMService.state.pendingUnconstrainRefresh = false

	PlatformPLMService.stopRetryTimer()

	PlatformPLMService.state.retryCount = 0

	logger:info("PlatformPLMService: onSuspend 完成")
end

function PlatformPLMService.onResuming()
	logger:info("PlatformPLMService: onResuming - 应用正在恢复，刷新平台侧状态...")

	PlatformPLMService.state.isSuspended = false
	PlatformPLMService.state.pendingResumeRefresh = true

	flushPendingPlatformRefresh()
	PlatformPaymentReconcileService.onForeground("plm_resuming")
	logger:info("PlatformPLMService: onResuming 完成")
end

function PlatformPLMService.onConstrained()
	logger:info("PlatformPLMService: onConstrained - 应用失去焦点")

	if GlobalData and GlobalData.BILogger then
		GlobalData.BILogger:customeLog("session_pause", {
			switch_type = 1
		})
	end
end

function PlatformPLMService.onUnconstrained()
	logger:info("PlatformPLMService: onUnconstrained - 应用重新获得焦点")

	if GlobalData and GlobalData.BILogger then
		GlobalData.BILogger:customeLog("session_pause", {
			switch_type = 0
		})
	end

	PlatformPLMService.state.pendingUnconstrainRefresh = true

	flushPendingPlatformRefresh()
	PlatformPaymentReconcileService.onForeground("plm_unconstrained")
end

function PlatformPLMService.registerPLMCallbacks()
	if PlatformPLMService.state.callbackRegistered then
		return
	end

	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.RegisterPLMCallbacks then
		logger:warn("PlatformPLMService: 当前平台不支持 RegisterPLMCallbacks")

		return
	end

	PlatformBridgeLuaFacade.RegisterPLMCallbacks(PlatformPLMService.onSuspend, PlatformPLMService.onResuming, PlatformPLMService.onConstrained, PlatformPLMService.onUnconstrained)

	PlatformPLMService.state.callbackRegistered = true
end

function PlatformPLMService:init()
	if PlatformPLMService.state.initialized then
		return true
	end

	if not PlatformPLMService.isPLMSupported() then
		logger:debug("PlatformPLMService: 当前平台不支持 PLM，跳过初始化")

		return false
	end

	PlatformPLMService.state.initialized = true

	PlatformPLMService.registerPLMCallbacks()

	return true
end

function PlatformPLMService:isSuspended()
	return PlatformPLMService.state.isSuspended
end

return PlatformPLMService
