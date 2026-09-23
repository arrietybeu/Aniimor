-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformLoginAgent.lua

local M = {}
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local PlatformLoginService = require("SDK.Platform.PlatformLoginService")
local logger = require("SDK.Platform.PlatformLogger")

logger:info("[platform_identity_login] ImpPlatformLoginAgent loaded/registering hook")

function M.getSdkVendorUid()
	local sdkManager = pg and pg.global and pg.global.sdkManager

	if sdkManager and sdkManager.getVendorUid then
		local vendorUid = sdkManager:getVendorUid()

		if not string.isNilOrEmpty(vendorUid) then
			return tostring(vendorUid)
		end
	end

	local platform = pg and pg.global and pg.global.platform

	if platform and platform.getSdkVendorUid then
		local vendorUid = platform:getSdkVendorUid()

		if not string.isNilOrEmpty(vendorUid) then
			return tostring(vendorUid)
		end
	end

	return nil
end

function M:_enrichLoginExtraInfo(extraInfo)
	if type(extraInfo) ~= "table" then
		logger:warn("[platform_identity_login] enrich_skip invalid extraInfo type=%s", tostring(type(extraInfo)))

		return
	end

	local platformUserId, platformDisplayName

	if PlatformLoginService then
		local _platformUser = PlatformLoginService:getCurrentUser()

		if _platformUser and not string.isNilOrEmpty(_platformUser.userId) then
			platformUserId = tostring(_platformUser.userId)
		end

		if _platformUser and not string.isNilOrEmpty(_platformUser.displayName) then
			platformDisplayName = tostring(_platformUser.displayName)
		end
	end

	platformUserId = platformUserId or M.getSdkVendorUid()

	if not string.isNilOrEmpty(platformUserId) then
		extraInfo.platformUserId = platformUserId
	else
		logger:error("[platform_identity_login] missing platformUserId")
	end

	if not string.isNilOrEmpty(platformDisplayName) then
		extraInfo.platformDisplayName = platformDisplayName
	end

	if PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.GetCachedPlatformAuthCode then
		local authCode = PlatformBridgeLuaFacade.GetCachedPlatformAuthCode()

		if authCode and authCode ~= "" then
			extraInfo.psnAuthCode = authCode
		end
	end
end

logger:info("[platform_identity_login] hook_registered target=LoginAgent method=_enrichLoginExtraInfo")

return M
