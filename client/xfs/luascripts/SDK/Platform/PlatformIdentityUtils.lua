-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformIdentityUtils.lua

local PlatformUtils = require("Common.Utils.PlatformUtils")
local PlatformBridgeLuaFacade = CS and CS.FunPlus and CS.FunPlus.WorldX and CS.FunPlus.WorldX.SDK and CS.FunPlus.WorldX.SDK.Platform and CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade or nil
local PlatformIdentityUtils = {}

PlatformIdentityUtils.Family = PlatformUtils.Family
PlatformIdentityUtils.UnknownFamily = PlatformUtils.UnknownFamily
PlatformIdentityUtils.normalizeFamily = PlatformUtils.normalizeFamily
PlatformIdentityUtils.isConsoleFamily = PlatformUtils.isConsoleFamily
PlatformIdentityUtils.resolvePlayerIdentity = PlatformUtils.resolvePlayerIdentity
PlatformIdentityUtils.normalizeAllowCrossNetwork = PlatformUtils.normalizeAllowCrossNetwork
PlatformIdentityUtils.normalizePlatformFamily = PlatformUtils.normalizePlatformFamily
PlatformIdentityUtils.isCrossNetworkCompatible = PlatformUtils.isCrossNetworkCompatible
PlatformIdentityUtils.resolvePlayerInfoFamily = PlatformUtils.resolvePlayerInfoFamily
PlatformIdentityUtils.resolvePlatformUserId = PlatformUtils.resolvePlatformUserId
PlatformIdentityUtils.hasPlatformUserId = PlatformUtils.hasPlatformUserId
PlatformIdentityUtils.FAMILY = PlatformIdentityUtils.Family

function PlatformIdentityUtils.isCurrentConsoleFamily()
	return PlatformIdentityUtils.isConsoleFamily(PlatformIdentityUtils.getCurrentPlatformFamily())
end

function PlatformIdentityUtils.resolveBridgeFamily()
	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.GetPlatformFamily then
		return nil
	end

	return PlatformIdentityUtils.normalizeFamily(PlatformBridgeLuaFacade.GetPlatformFamily())
end

function PlatformIdentityUtils.getCurrentRawPlatform()
	return PlatformUtils.getCurrentRawPlatform()
end

function PlatformIdentityUtils.resolvePlatformManagerFamily()
	local platform = pg and pg.global and pg.global.platform

	if not platform or type(platform.getFamily) ~= "function" then
		return nil
	end

	return PlatformIdentityUtils.normalizeFamily(platform:getFamily())
end

function PlatformIdentityUtils.getCurrentPlatformFamily()
	local bridgeFamily = PlatformIdentityUtils.resolveBridgeFamily()

	if bridgeFamily and bridgeFamily ~= PlatformIdentityUtils.FAMILY.Other then
		return bridgeFamily
	end

	local managerFamily = PlatformIdentityUtils.resolvePlatformManagerFamily()

	if managerFamily then
		return managerFamily
	end

	return bridgeFamily or PlatformIdentityUtils.FAMILY.Other
end

function PlatformIdentityUtils.isPlatformFriend(playerInfo)
	if not PlatformIdentityUtils.isCurrentConsoleFamily() then
		return false
	end

	return PlatformUtils.isPlatformFriend(playerInfo)
end

function PlatformIdentityUtils.isSamePlatformFamilyUser(playerInfo)
	local currentFamily = PlatformIdentityUtils.getCurrentPlatformFamily()

	if not PlatformIdentityUtils.isConsoleFamily(currentFamily) then
		return false
	end

	local targetFamily = PlatformIdentityUtils.resolvePlayerInfoFamily(playerInfo)

	if not PlatformIdentityUtils.isConsoleFamily(targetFamily) then
		return false
	end

	return targetFamily == currentFamily
end

function PlatformIdentityUtils.waitForSignedIn(callback, timeoutMs)
	if PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.WaitForSignedIn then
		PlatformBridgeLuaFacade.WaitForSignedIn(timeoutMs or 0, callback)

		return
	end

	if PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.HasSignedInUser then
		local hasUser = PlatformBridgeLuaFacade.HasSignedInUser() == true

		if type(callback) == "function" then
			callback(hasUser, hasUser and 0 or -24, hasUser and "" or "not_signed_in", "")
		end

		return
	end

	if type(callback) == "function" then
		callback(false, -1, "wait_for_signed_in_unavailable", "")
	end
end

function PlatformIdentityUtils.refreshPrivacyCaches(reason, source)
	local PlatformTextCommunicationService = require("SDK.Platform.PlatformTextCommunicationService")
	local PlatformSocialService = require("SDK.Platform.PlatformSocialService")
	local PlatformTextMaskService = require("SDK.Platform.PlatformTextMaskService")
	local PlatformImageMaskService = require("SDK.Platform.PlatformImageMaskService")
	local PlatformUGCService = require("SDK.Platform.PlatformUGCService")
	local PlatformCommunicationService = require("SDK.Platform.PlatformCommunicationService")
	local EventConst = require("Common.Const.EventConst")

	PlatformTextCommunicationService:clearPermissionCache({
		clearUGCService = false
	})
	PlatformSocialService:refreshPlatformFriendCache()
	PlatformTextMaskService:clearCache()
	PlatformImageMaskService:clearCache()
	PlatformUGCService:refreshLocalPolicy(reason, function(policy)
		if pg and pg.global and pg.global.eventEmitter and EventConst and EventConst.PLATFORM_NAME_MASK_POLICY_REFRESHED then
			pg.global.eventEmitter:emit(EventConst.PLATFORM_NAME_MASK_POLICY_REFRESHED, {
				reason = reason,
				source = source
			})
		end

		if pg and pg.global and pg.global.eventEmitter and EventConst and EventConst.PLATFORM_UGC_POLICY_CHANGED then
			pg.global.eventEmitter:emit(EventConst.PLATFORM_UGC_POLICY_CHANGED, {
				reason = reason,
				source = source,
				policy = policy
			})
		end
	end)
	PlatformTextCommunicationService:prefetchLocalCommunicationPrivileges()
	PlatformCommunicationService:refreshLocalCommunicationPolicy(function()
		if pg and pg.game and pg.game.chat and type(pg.game.chat.refreshPlatformFilteredChatMessages) == "function" then
			pg.game.chat:refreshPlatformFilteredChatMessages(reason)
		end

		if pg and pg.game and pg.game.chat and type(pg.game.chat.refreshPlatformFilteredMails) == "function" then
			pg.game.chat:refreshPlatformFilteredMails(reason)
		end
	end)
end

function PlatformIdentityUtils.refreshPrivacyCachesIfPS(reason, source)
	if PlatformIdentityUtils.getCurrentPlatformFamily() == PlatformIdentityUtils.Family.PlayStation then
		PlatformIdentityUtils.refreshPrivacyCaches(reason, source)
	end
end

function PlatformIdentityUtils.refreshPrivacyCachesIfNotPS(reason, source)
	if PlatformIdentityUtils.getCurrentPlatformFamily() ~= PlatformIdentityUtils.Family.PlayStation then
		PlatformIdentityUtils.refreshPrivacyCaches(reason, source)
	end
end

return PlatformIdentityUtils
