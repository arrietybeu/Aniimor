-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformStringVerificationService.lua

local logger = require("SDK.Platform.PlatformLogger")
local Time = require("Core.Common.Time")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local PlatformStringVerificationService = {}

PlatformStringVerificationService.VERIFY_RESULT_CODE = {
	Success = 0,
	UnknownError = 3,
	TooLong = 2,
	Offensive = 1
}
PlatformStringVerificationService.CACHE_TTL = 5
PlatformStringVerificationService.state = {
	cachedResults = {},
	pendingCallbacksByText = {}
}
PlatformStringVerificationService.Decision = {
	Fallback = "fallback",
	Deny = "deny",
	Allow = "allow"
}
PlatformStringVerificationService.ResultCode = PlatformStringVerificationService.VERIFY_RESULT_CODE

function PlatformStringVerificationService.getNow()
	return Time and Time.secondCache or os.time()
end

function PlatformStringVerificationService.normalizeText(text)
	if text == nil then
		return ""
	end

	return tostring(text)
end

function PlatformStringVerificationService.isBridgeSupported()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.IsSupported and PlatformBridgeLuaFacade.IsSupported() == true
end

function PlatformStringVerificationService.supportsStringVerification()
	return PlatformStringVerificationService.isBridgeSupported() and PlatformBridgeLuaFacade.SupportsStringVerification and PlatformBridgeLuaFacade.VerifyString and PlatformBridgeLuaFacade.SupportsStringVerification() == true
end

function PlatformStringVerificationService.shouldCacheBridgeResult(allowed, result)
	if allowed == true then
		return true
	end

	return result == PlatformStringVerificationService.VERIFY_RESULT_CODE.Offensive or result == PlatformStringVerificationService.VERIFY_RESULT_CODE.TooLong
end

function PlatformStringVerificationService.getCachedResult(text)
	local cachedResult = PlatformStringVerificationService.state.cachedResults[text]

	if not cachedResult then
		return nil
	end

	if cachedResult.expireTime <= PlatformStringVerificationService.getNow() then
		PlatformStringVerificationService.state.cachedResults[text] = nil

		return nil
	end

	return cachedResult
end

function PlatformStringVerificationService.rememberResult(text, allowed, result, reason)
	if not PlatformStringVerificationService.shouldCacheBridgeResult(allowed, result) then
		return
	end

	PlatformStringVerificationService.state.cachedResults[text] = {
		allowed = allowed == true,
		result = tonumber(result) or PlatformStringVerificationService.VERIFY_RESULT_CODE.UnknownError,
		reason = tostring(reason or ""),
		expireTime = PlatformStringVerificationService.getNow() + PlatformStringVerificationService.CACHE_TTL
	}
end

function PlatformStringVerificationService.finalizePendingCallbacks(text, allowed, result, reason)
	local callbacks = PlatformStringVerificationService.state.pendingCallbacksByText[text] or {}

	PlatformStringVerificationService.state.pendingCallbacksByText[text] = nil

	for _, pendingCallback in ipairs(callbacks) do
		pendingCallback(allowed == true, result, reason)
	end
end

function PlatformStringVerificationService.dispatchBridgeVerification(text, callback)
	local cachedResult = PlatformStringVerificationService.getCachedResult(text)

	if cachedResult then
		callback(cachedResult.allowed, cachedResult.result, cachedResult.reason)

		return
	end

	local pendingCallbacks = PlatformStringVerificationService.state.pendingCallbacksByText[text]

	if pendingCallbacks then
		table.insert(pendingCallbacks, callback)

		return
	end

	PlatformStringVerificationService.state.pendingCallbacksByText[text] = {
		callback
	}

	PlatformBridgeLuaFacade.VerifyString(text, 0, function(allowed, result, reason)
		local normalizedAllowed = allowed == true
		local normalizedResult = tonumber(result) or PlatformStringVerificationService.VERIFY_RESULT_CODE.UnknownError
		local normalizedReason = tostring(reason or "")

		PlatformStringVerificationService.rememberResult(text, normalizedAllowed, normalizedResult, normalizedReason)
		PlatformStringVerificationService.finalizePendingCallbacks(text, normalizedAllowed, normalizedResult, normalizedReason)
	end)
end

function PlatformStringVerificationService.resolveDecision(allowed, result)
	if allowed == true then
		return PlatformStringVerificationService.Decision.Allow, true
	end

	if result == PlatformStringVerificationService.VERIFY_RESULT_CODE.Offensive or result == PlatformStringVerificationService.VERIFY_RESULT_CODE.TooLong then
		return PlatformStringVerificationService.Decision.Deny, false
	end

	return PlatformStringVerificationService.Decision.Fallback, true
end

function PlatformStringVerificationService.logDecision(level, text, decision, result, reason)
	local logFunc = level == "debug" and logger.debug or logger.warn

	logFunc(logger, "platform_string_verification decision=%s result=%s reason=%s textLength=%s", tostring(decision), tostring(result), tostring(reason or ""), tostring(#text))
end

function PlatformStringVerificationService:isSupported()
	return PlatformStringVerificationService.supportsStringVerification()
end

function PlatformStringVerificationService:verifyString(text, callback)
	if type(callback) ~= "function" then
		return false
	end

	local normalizedText = PlatformStringVerificationService.normalizeText(text)

	if string.isNilOrEmpty(normalizedText) then
		callback(true, self.Decision.Allow, PlatformStringVerificationService.VERIFY_RESULT_CODE.Success, "")

		return false
	end

	if not PlatformStringVerificationService.supportsStringVerification() then
		callback(true, self.Decision.Fallback, -1, "string_verification_not_supported")

		return false
	end

	PlatformStringVerificationService.dispatchBridgeVerification(normalizedText, function(allowed, result, reason)
		local decision, shouldProceed = PlatformStringVerificationService.resolveDecision(allowed, result)

		PlatformStringVerificationService.logDecision(decision == PlatformStringVerificationService.Decision.Allow and "debug" or "warn", normalizedText, decision, result, reason)
		callback(shouldProceed, decision, result, reason)
	end)

	return true
end

return PlatformStringVerificationService
