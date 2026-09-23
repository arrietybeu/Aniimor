-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformInviteTokenService.lua

local logger = require("SDK.Platform.PlatformLogger")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local PlatformShellConst = require("Common.Const.PlatformShellConst")
local PlatformInviteTokenService = {}

PlatformInviteTokenService.TokenType = PlatformShellConst.TokenType
PlatformInviteTokenService.ErrorCode = {
	CLEARED = "cleared",
	INVALID_TOKEN_TYPE = "invalid_token_type",
	SUCCESS = "success",
	TIMEOUT = "timeout",
	SEND_FAILED = "send_failed"
}
PlatformInviteTokenService.REQUEST_TIMEOUT = 10
PlatformInviteTokenService.FRESH_MARGIN = 30
PlatformInviteTokenService.state = {
	tokensByKey = {}
}
PlatformInviteTokenService.state = PlatformInviteTokenService.state

function PlatformInviteTokenService.now()
	return Time and Time.secondCache or os.time()
end

function PlatformInviteTokenService.normalizeTokenType(tokenType)
	return tostring(tokenType or "")
end

function PlatformInviteTokenService.normalizeTargetKey(targetKey)
	return tostring(targetKey or "")
end

function PlatformInviteTokenService.getTokenState(tokenType, targetKey)
	local key = PlatformShellConst.makeTokenKey(tokenType, targetKey)

	PlatformInviteTokenService.state.tokensByKey[key] = PlatformInviteTokenService.state.tokensByKey[key] or {
		reqSeq = 0,
		expireSt = 0,
		token = "",
		reqSt = 0,
		tokenType = PlatformInviteTokenService.normalizeTokenType(tokenType),
		targetKey = PlatformInviteTokenService.normalizeTargetKey(targetKey),
		waiters = {}
	}

	return PlatformInviteTokenService.state.tokensByKey[key]
end

function PlatformInviteTokenService.isRequestInFlight(tokenState)
	if (tokenState.reqSt or 0) <= 0 then
		return false
	end

	return PlatformInviteTokenService.now() - tokenState.reqSt <= PlatformInviteTokenService.REQUEST_TIMEOUT
end

function PlatformInviteTokenService.cancelRequestTimeout(tokenState)
	if tokenState.timeoutTimerId then
		TimerManager.removeTimer(tokenState.timeoutTimerId)

		tokenState.timeoutTimerId = nil
	end
end

function PlatformInviteTokenService.clearRequestState(tokenState)
	tokenState.reqSt = 0

	PlatformInviteTokenService.cancelRequestTimeout(tokenState)
end

function PlatformInviteTokenService.flushWaiter(tokenState, token, errCode)
	local waiters = tokenState.waiters or {}

	tokenState.waiters = {}

	for _, callback in ipairs(waiters) do
		if type(callback) == "function" then
			local ok, err = xpcall(callback, debug.traceback, token or "", errCode)

			if not ok then
				logger:error("platform shell token waiter callback failed tokenType=%s targetKey=%s errCode=%s err=%s", tostring(tokenState and tokenState.tokenType or ""), tostring(tokenState and tokenState.targetKey or ""), tostring(errCode or ""), tostring(err))
			end
		end
	end
end

function PlatformInviteTokenService:getToken(tokenType, targetKey)
	tokenType = PlatformInviteTokenService.normalizeTokenType(tokenType)

	if string.isNilOrEmpty(tokenType) then
		return ""
	end

	local tokenState = PlatformInviteTokenService.state.tokensByKey[PlatformShellConst.makeTokenKey(tokenType, targetKey)]

	return tostring(tokenState and tokenState.token or "")
end

function PlatformInviteTokenService:isTokenFresh(tokenType, targetKey)
	local tokenState = PlatformInviteTokenService.getTokenState(tokenType, targetKey)

	if string.isNilOrEmpty(tokenState.token) then
		return false
	end

	local expireSt = tonumber(tokenState.expireSt or 0) or 0

	if expireSt <= PlatformInviteTokenService.FRESH_MARGIN then
		return false
	end

	return PlatformInviteTokenService.now() < expireSt - PlatformInviteTokenService.FRESH_MARGIN
end

function PlatformInviteTokenService.sendCreateTokenRpc(tokenType, targetKey, forceRenew)
	if not pg or not pg.me or not pg.me.serverMsg then
		logger:warn("platform shell token deferred send unavailable tokenType=%s targetKey=%s forceRenew=%s", tostring(tokenType or ""), tostring(targetKey or ""), tostring(forceRenew == true))

		return false
	end

	pg.me:serverMsg("RPC_CS_CreatePlatformShellInviteToken", PlatformInviteTokenService.normalizeTokenType(tokenType), PlatformInviteTokenService.normalizeTargetKey(targetKey), forceRenew == true)

	return true
end

function PlatformInviteTokenService:ensureToken(tokenType, targetKey, callback, forceRenew)
	tokenType = PlatformInviteTokenService.normalizeTokenType(tokenType)
	targetKey = PlatformInviteTokenService.normalizeTargetKey(targetKey)

	if string.isNilOrEmpty(tokenType) then
		if type(callback) == "function" then
			callback("", self.ErrorCode.INVALID_TOKEN_TYPE)
		end

		return
	end

	local tokenState = PlatformInviteTokenService.getTokenState(tokenType, targetKey)

	if forceRenew ~= true and self:isTokenFresh(tokenType, targetKey) then
		if type(callback) == "function" then
			callback(tokenState.token, self.ErrorCode.SUCCESS)
		end

		return
	end

	if type(callback) == "function" then
		table.insert(tokenState.waiters, callback)
	end

	if PlatformInviteTokenService.isRequestInFlight(tokenState) then
		return
	end

	tokenState.reqSt = PlatformInviteTokenService.now()
	tokenState.reqSeq = (tokenState.reqSeq or 0) + 1

	local reqSeq = tokenState.reqSeq
	local sendOk = PlatformInviteTokenService.sendCreateTokenRpc(tokenType, targetKey, forceRenew)

	if not sendOk then
		PlatformInviteTokenService.clearRequestState(tokenState)
		PlatformInviteTokenService.flushWaiter(tokenState, "", self.ErrorCode.SEND_FAILED)

		return
	end

	PlatformInviteTokenService.cancelRequestTimeout(tokenState)

	tokenState.timeoutTimerId = TimerManager.addTimer(PlatformInviteTokenService.REQUEST_TIMEOUT, function()
		if tokenState.reqSeq ~= reqSeq then
			return
		end

		if (tokenState.reqSt or 0) <= 0 then
			return
		end

		PlatformInviteTokenService.clearRequestState(tokenState)
		logger:warn("platform shell token request timeout tokenType=%s targetKey=%s", tostring(tokenType or ""), tostring(targetKey or ""))
		PlatformInviteTokenService.flushWaiter(tokenState, "", PlatformInviteTokenService.ErrorCode.TIMEOUT)
	end)
end

function PlatformInviteTokenService:onSyncFromServer(tokenType, targetKey, token, expireSt)
	tokenType = PlatformInviteTokenService.normalizeTokenType(tokenType)
	targetKey = PlatformInviteTokenService.normalizeTargetKey(targetKey)

	local tokenState = PlatformInviteTokenService.getTokenState(tokenType, targetKey)

	tokenState.token = tostring(token or "")
	tokenState.expireSt = tonumber(expireSt or 0) or 0

	PlatformInviteTokenService.clearRequestState(tokenState)
	logger:info("platform shell token synced tokenType=%s targetKey=%s hasToken=%s tokenLen=%s expireSt=%s", tokenType, targetKey, tostring(not string.isNilOrEmpty(tokenState.token)), tostring(#tokenState.token), tostring(tokenState.expireSt))
	PlatformInviteTokenService.flushWaiter(tokenState, tokenState.token, self.ErrorCode.SUCCESS)
end

function PlatformInviteTokenService:clear(tokenType, targetKey)
	if string.isNilOrEmpty(tokenType) then
		for _, tokenState in pairs(PlatformInviteTokenService.state.tokensByKey) do
			PlatformInviteTokenService.clearRequestState(tokenState)
			PlatformInviteTokenService.flushWaiter(tokenState, "", self.ErrorCode.CLEARED)
		end

		PlatformInviteTokenService.state.tokensByKey = {}

		return
	end

	local key = PlatformShellConst.makeTokenKey(tokenType, targetKey)
	local tokenState = PlatformInviteTokenService.state.tokensByKey[key]

	if tokenState then
		PlatformInviteTokenService.clearRequestState(tokenState)
		PlatformInviteTokenService.flushWaiter(tokenState, "", self.ErrorCode.CLEARED)
	end

	PlatformInviteTokenService.state.tokensByKey[key] = nil
end

function PlatformInviteTokenService:clearAll()
	for _, tokenState in pairs(PlatformInviteTokenService.state.tokensByKey) do
		PlatformInviteTokenService.clearRequestState(tokenState)
		PlatformInviteTokenService.flushWaiter(tokenState, "", self.ErrorCode.CLEARED)
	end

	PlatformInviteTokenService.state.tokensByKey = {}
end

return PlatformInviteTokenService
