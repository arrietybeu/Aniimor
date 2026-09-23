-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformPremiumFeatureService.lua

local logger = require("SDK.Platform.PlatformLogger")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local PlatformPremiumFeatureService = {}

function PlatformPremiumFeatureService.isFacadeReady()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.CheckPremiumEligibility and PlatformBridgeLuaFacade.BeginPremiumFeatureSession and PlatformBridgeLuaFacade.EndPremiumFeatureSession
end

function PlatformPremiumFeatureService.fireFallback(callback, success)
	if type(callback) == "function" then
		callback(success, success and 0 or -1, success and "" or "premium_feature_unavailable", "")
	end
end

function PlatformPremiumFeatureService:checkEligibility(callback, timeoutMs)
	if not PlatformPremiumFeatureService.isFacadeReady() then
		PlatformPremiumFeatureService.fireFallback(callback, true)

		return
	end

	PlatformBridgeLuaFacade.CheckPremiumEligibility(timeoutMs or 0, callback)
end

function PlatformPremiumFeatureService.isDisconnectTipShown()
	local PlatformConnectivityService = require("SDK.Platform.PlatformConnectivityService")
	local state = PlatformConnectivityService and PlatformConnectivityService.state

	return state and state.tipShown == true
end

function PlatformPremiumFeatureService:beginSession(featureType, callback, timeoutMs)
	if PlatformPremiumFeatureService.isDisconnectTipShown() then
		logger:info("断网提示弹窗显示中，跳过 PremiumFeatureSession begin，featureType=%s", tostring(featureType))

		if type(callback) == "function" then
			callback(false, 0, "network_disconnect_tip_shown", "")
		end

		return
	end

	self.activeFeatureType = "cross_play"

	if not PlatformPremiumFeatureService.isFacadeReady() then
		PlatformPremiumFeatureService.fireFallback(callback, true)

		return
	end

	PlatformBridgeLuaFacade.BeginPremiumFeatureSession("cross_play", timeoutMs or 0, callback)
end

function PlatformPremiumFeatureService:endSession(callback, timeoutMs)
	self.activeFeatureType = nil

	if not PlatformPremiumFeatureService.isFacadeReady() then
		PlatformPremiumFeatureService.fireFallback(callback, true)

		return
	end

	PlatformBridgeLuaFacade.EndPremiumFeatureSession(timeoutMs or 0, callback)
end

function PlatformPremiumFeatureService:isSupported()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.SupportsPremiumFeatures and PlatformBridgeLuaFacade.SupportsPremiumFeatures() == true
end

return PlatformPremiumFeatureService
