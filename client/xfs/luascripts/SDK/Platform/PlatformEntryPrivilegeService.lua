-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformEntryPrivilegeService.lua

local logger = require("SDK.Platform.PlatformLogger")
local TimerManager = require("Core.Timer.TimerManager")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local PlatformEntryPrivilegeService = {}

PlatformEntryPrivilegeService.LOGIN_MULTIPLAYER_PRIVILEGE_TIMEOUT_SECONDS = 30
PlatformEntryPrivilegeService.state = {
	runtimeReady = false,
	initialized = false
}

function PlatformEntryPrivilegeService.isBridgeSupported()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.IsSupported and PlatformBridgeLuaFacade.IsSupported() == true
end

function PlatformEntryPrivilegeService.getMultiplayerPrivilegeFailureReason()
	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.GetLocalMultiplayerPrivilegeFailureReason then
		return string.Empty
	end

	return tostring(PlatformBridgeLuaFacade.GetLocalMultiplayerPrivilegeFailureReason() or "")
end

function PlatformEntryPrivilegeService:init(runtimeReady)
	PlatformEntryPrivilegeService.state.initialized = true
	PlatformEntryPrivilegeService.state.runtimeReady = runtimeReady == true

	return true
end

function PlatformEntryPrivilegeService:shutdown()
	PlatformEntryPrivilegeService.state.initialized = false
	PlatformEntryPrivilegeService.state.runtimeReady = false
end

function PlatformEntryPrivilegeService:isInitialized()
	return PlatformEntryPrivilegeService.state.initialized
end

function PlatformEntryPrivilegeService:checkLoginMultiplayerPrivilege(onResolved)
	local resolved = false
	local timeoutTimer

	function PlatformEntryPrivilegeService.complete(allowed, reason)
		if resolved then
			return
		end

		resolved = true

		if timeoutTimer then
			TimerManager.removeTimer(timeoutTimer)

			timeoutTimer = nil
		end

		if type(onResolved) == "function" then
			onResolved(allowed == true, reason or string.Empty)
		end
	end

	if not PlatformEntryPrivilegeService.isBridgeSupported() or not PlatformBridgeLuaFacade.ResolveLocalMultiplayerPrivilege then
		PlatformEntryPrivilegeService.complete(true, string.Empty)

		return
	end

	if PlatformEntryPrivilegeService.state.initialized and PlatformEntryPrivilegeService.state.runtimeReady ~= true then
		logger:warn("[entry_privilege] runtime not ready before login multiplayer privilege resolve, blocking entry")
		PlatformEntryPrivilegeService.complete(false, "runtime_not_ready")

		return
	end

	timeoutTimer = TimerManager.addTimer(PlatformEntryPrivilegeService.LOGIN_MULTIPLAYER_PRIVILEGE_TIMEOUT_SECONDS, function()
		timeoutTimer = nil

		if resolved then
			return
		end

		logger:warn("[entry_privilege] login multiplayer privilege resolve timeout, blocking entry")
		PlatformEntryPrivilegeService.complete(false, "resolve_timeout")
	end)

	PlatformBridgeLuaFacade.ResolveLocalMultiplayerPrivilege(0, function(allowed, _, reason)
		if allowed == true then
			local hardReason = PlatformEntryPrivilegeService.getMultiplayerPrivilegeFailureReason()

			if not string.isNilOrEmpty(hardReason) then
				logger:warn("[entry_privilege] resolve allowed but hard recheck denied, hardReason=%s", tostring(hardReason))
				PlatformEntryPrivilegeService.complete(false, hardReason)

				return
			end

			PlatformEntryPrivilegeService.complete(true, string.Empty)

			return
		end

		local failureReason = tostring(reason or "")

		if failureReason == "runtime_not_ready" then
			logger:warn("[entry_privilege] runtime not ready on supported platform, blocking entry")
		end

		PlatformEntryPrivilegeService.complete(false, failureReason)
	end)
end

return PlatformEntryPrivilegeService
