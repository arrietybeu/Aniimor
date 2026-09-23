-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformShellInviteDestinationQueryService.lua

local logger = require("SDK.Platform.PlatformLogger")
local TimerManager = require("Core.Timer.TimerManager")
local PlatformShellInviteDestinationQueryService = {}

PlatformShellInviteDestinationQueryService.REQUEST_TIMEOUT = 10
PlatformShellInviteDestinationQueryService.state = {
	nextRequestId = 0,
	pendingCallbacks = {}
}

function PlatformShellInviteDestinationQueryService.nextRequestId()
	PlatformShellInviteDestinationQueryService.state.nextRequestId = PlatformShellInviteDestinationQueryService.state.nextRequestId + 1

	return tostring(PlatformShellInviteDestinationQueryService.state.nextRequestId)
end

function PlatformShellInviteDestinationQueryService.finishRequest(requestId, ok, destinationContext)
	requestId = tostring(requestId or "")

	local pending = PlatformShellInviteDestinationQueryService.state.pendingCallbacks[requestId]

	if not pending then
		logger:debug("platform_shell_invite_destination_query_result_dropped requestId=%s", requestId)

		return
	end

	PlatformShellInviteDestinationQueryService.state.pendingCallbacks[requestId] = nil

	if pending.timeoutTimerId then
		TimerManager.removeTimer(pending.timeoutTimerId)

		pending.timeoutTimerId = nil
	end

	local callback = pending.callback

	callback(ok == true, destinationContext)
end

function PlatformShellInviteDestinationQueryService.dispatchResult(requestId, ok, destinationContext)
	PlatformShellInviteDestinationQueryService.finishRequest(requestId, ok, destinationContext)
end

function PlatformShellInviteDestinationQueryService:query(payload, callback)
	local requestId = PlatformShellInviteDestinationQueryService.nextRequestId()

	if type(callback) == "function" then
		local pending = {
			callback = callback
		}

		PlatformShellInviteDestinationQueryService.state.pendingCallbacks[requestId] = pending
		pending.timeoutTimerId = TimerManager.addTimer(PlatformShellInviteDestinationQueryService.REQUEST_TIMEOUT, function()
			logger:warn("platform_shell_invite_destination_query_timeout requestId=%s", requestId)
			PlatformShellInviteDestinationQueryService.finishRequest(requestId, false)
		end)
	end

	local queryPayload = {}

	if type(payload) == "table" then
		for key, value in pairs(payload) do
			queryPayload[key] = value
		end
	end

	queryPayload.requestId = requestId

	pg.me:serverMsg("RPC_CS_QueryPlatformShellInviteDestination", queryPayload, function(ok, destinationContext)
		if ok ~= nil then
			PlatformShellInviteDestinationQueryService.dispatchResult(requestId, ok, destinationContext)
		end
	end)

	return requestId
end

function PlatformShellInviteDestinationQueryService:onServerResult(requestId, ok, destinationContext)
	PlatformShellInviteDestinationQueryService.dispatchResult(requestId, ok, destinationContext)
end

function PlatformShellInviteDestinationQueryService:_resetForTests()
	for _, pending in pairs(PlatformShellInviteDestinationQueryService.state.pendingCallbacks) do
		if pending.timeoutTimerId then
			TimerManager.removeTimer(pending.timeoutTimerId)
		end
	end

	PlatformShellInviteDestinationQueryService.state.nextRequestId = 0
	PlatformShellInviteDestinationQueryService.state.pendingCallbacks = {}
end

return PlatformShellInviteDestinationQueryService
