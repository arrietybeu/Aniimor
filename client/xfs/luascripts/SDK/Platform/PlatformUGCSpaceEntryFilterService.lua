-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformUGCSpaceEntryFilterService.lua

local PlatformSocialService = require("SDK.Platform.PlatformSocialService")
local PlatformUGCService = require("SDK.Platform.PlatformUGCService")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformNoticeUtils = require("SDK.Platform.PlatformNoticeUtils")
local NoticeDef = require("Common.NoticeDef")
local logger = require("SDK.Platform.PlatformLogger")
local PlatformUGCSpaceEntryFilterService = {}

PlatformUGCSpaceEntryFilterService.REASON_UGC_DESTINATION_OWNER_MISSING = "ugc_destination_owner_missing"
PlatformUGCSpaceEntryFilterService.Decision = {
	Unknown = "unknown",
	Block = "block",
	Allow = "allow"
}
PlatformUGCSpaceEntryFilterService.REASON_CURRENT_NON_CONSOLE_FAMILY = "current_non_console_family"
PlatformUGCSpaceEntryFilterService.REASON_NON_UGC_DESTINATION = "non_ugc_destination"
PlatformUGCSpaceEntryFilterService.REASON_LOCAL_UGC_ALLOW = "local_ugc_privacy_allow"
PlatformUGCSpaceEntryFilterService.REASON_LOCAL_UGC_FALLBACK = "local_ugc_privacy_fallback"
PlatformUGCSpaceEntryFilterService.REASON_LOCAL_UGC_FRIENDS_ONLY = "local_ugc_privacy_friends_only"
PlatformUGCSpaceEntryFilterService.REASON_LOCAL_UGC_BLOCKED = "local_ugc_privacy_blocked"
PlatformUGCSpaceEntryFilterService.REASON_LOCAL_UGC_POLICY_MISSING = "local_ugc_policy_cache_missing"
PlatformUGCSpaceEntryFilterService.REASON_LOCAL_UGC_POLICY_UNKNOWN = "local_ugc_policy_unknown"
PlatformUGCSpaceEntryFilterService.REASON_TARGET_UGC_PERMISSION_DENIED = "target_ugc_permission_denied"
PlatformUGCSpaceEntryFilterService.REASON_TARGET_UGC_SWITCH_MISSING = "target_ugc_switch_missing"
PlatformUGCSpaceEntryFilterService.REASON_TARGET_UGC_SWITCH_UNKNOWN = "target_ugc_switch_unknown"
PlatformUGCSpaceEntryFilterService.REASON_PLATFORM_BLOCK_LIST = "platform_block_list"
PlatformUGCSpaceEntryFilterService.REASON_PLATFORM_BLOCK_LIST_PENDING = "platform_block_list_pending"
PlatformUGCSpaceEntryFilterService.REASON_PLATFORM_BLOCK_LIST_UNAVAILABLE = "platform_block_list_unavailable"
PlatformUGCSpaceEntryFilterService.REASON_PLATFORM_BLOCK_LIST_ERROR = "platform_block_list_error"

function PlatformUGCSpaceEntryFilterService.makeContext(decision, reason, extra)
	local context = {
		decision = decision,
		reason = reason
	}

	if type(extra) == "table" then
		for k, v in pairs(extra) do
			context[k] = v
		end
	end

	return context
end

function PlatformUGCSpaceEntryFilterService.isCurrentConsoleFamily()
	return type(PlatformIdentityUtils) == "table" and type(PlatformIdentityUtils.getCurrentPlatformFamily) == "function" and type(PlatformIdentityUtils.isConsoleFamily) == "function" and PlatformIdentityUtils.isConsoleFamily(PlatformIdentityUtils.getCurrentPlatformFamily()) == true
end

function PlatformUGCSpaceEntryFilterService.isUGCDestination(destinationContext)
	if type(destinationContext) ~= "table" then
		return false
	end

	local kind = tostring(destinationContext.destinationKind or "")

	return kind == "homeland"
end

function PlatformUGCSpaceEntryFilterService.resolveOwnerPlayerInfo(destinationContext, ownerPlayerInfo)
	if type(ownerPlayerInfo) == "table" then
		return ownerPlayerInfo
	end

	local ownerUid = destinationContext and destinationContext.ownerUid

	if string.isNilOrEmpty(ownerUid) then
		return ownerPlayerInfo
	end

	if pg and pg.game and pg.game.chat and pg.game.chat.getPlayerInfo then
		return pg.game.chat:getPlayerInfo(tostring(ownerUid))
	end

	return ownerPlayerInfo
end

function PlatformUGCSpaceEntryFilterService.safeReadField(value, key)
	if value == nil then
		return nil
	end

	local ok, result = pcall(function()
		return value[key]
	end)

	if ok then
		return result
	end

	return nil
end

function PlatformUGCSpaceEntryFilterService.normalizeBridgePlayerInfo(playerInfo)
	local platformInfo = PlatformUGCSpaceEntryFilterService.safeReadField(playerInfo, "platformInfo")

	if platformInfo ~= nil and type(platformInfo) ~= "table" then
		platformInfo = PlatformUGCSpaceEntryFilterService.normalizeBridgePlayerInfo(platformInfo)
	end

	local result = {
		uid = PlatformUGCSpaceEntryFilterService.safeReadField(playerInfo, "uid"),
		playerId = PlatformUGCSpaceEntryFilterService.safeReadField(playerInfo, "playerId"),
		platformUserId = PlatformUGCSpaceEntryFilterService.safeReadField(playerInfo, "platformUserId"),
		platformFamily = PlatformUGCSpaceEntryFilterService.safeReadField(playerInfo, "platformFamily"),
		platformDisplayName = PlatformUGCSpaceEntryFilterService.safeReadField(playerInfo, "platformDisplayName"),
		platform = PlatformUGCSpaceEntryFilterService.safeReadField(playerInfo, "platform"),
		os = PlatformUGCSpaceEntryFilterService.safeReadField(playerInfo, "os"),
		isPlatformFriend = PlatformUGCSpaceEntryFilterService.safeReadField(playerInfo, "isPlatformFriend"),
		isAllowedCrossPlatform = PlatformUGCSpaceEntryFilterService.safeReadField(playerInfo, "isAllowedCrossPlatform"),
		platformUGCSwitch = PlatformUGCSpaceEntryFilterService.safeReadField(playerInfo, "platformUGCSwitch"),
		platformInfo = platformInfo
	}

	for _, value in pairs(result) do
		if value ~= nil then
			return result
		end
	end

	return playerInfo
end

function PlatformUGCSpaceEntryFilterService.normalizePlayerInfo(playerInfo)
	if playerInfo == nil then
		return nil
	end

	local rawGetter = PlatformUGCSpaceEntryFilterService.safeReadField(playerInfo, "getRawTable")

	if type(rawGetter) == "function" then
		local ok, rawInfo = pcall(rawGetter, playerInfo)

		if ok and rawInfo ~= nil and rawInfo ~= playerInfo then
			return PlatformUGCSpaceEntryFilterService.normalizePlayerInfo(rawInfo)
		end
	end

	if type(playerInfo) == "table" then
		return playerInfo
	end

	return PlatformUGCSpaceEntryFilterService.normalizeBridgePlayerInfo(playerInfo)
end

function PlatformUGCSpaceEntryFilterService.peekLocalUgcPolicy()
	if not PlatformUGCService or type(PlatformUGCService.peekLocalPolicy) ~= "function" then
		return nil
	end

	local ok, policy = pcall(function()
		return PlatformUGCService:peekLocalPolicy()
	end)

	if not ok then
		logger:warn("ugc_space_entry_filter_local_policy_failed err=%s", tostring(policy))

		return nil
	end

	return policy
end

function PlatformUGCSpaceEntryFilterService.resolveTargetUgcVisible(playerInfo, allowReason)
	playerInfo = PlatformUGCSpaceEntryFilterService.normalizePlayerInfo(playerInfo)

	if not PlatformUGCService or type(PlatformUGCService.resolveTargetVisibleDecision) ~= "function" then
		return true, allowReason
	end

	local ok, visible, context = pcall(function()
		return PlatformUGCService:resolveTargetVisibleDecision(playerInfo, allowReason)
	end)

	if not ok then
		logger:warn("ugc_space_entry_filter_target_visible_failed err=%s", tostring(visible))

		return true, allowReason
	end

	return visible ~= false, context and context.ugcReason or allowReason
end

function PlatformUGCSpaceEntryFilterService.peekIsPlatformFriend(playerInfo)
	playerInfo = PlatformUGCSpaceEntryFilterService.normalizePlayerInfo(playerInfo)

	if playerInfo == nil then
		return false
	end

	if PlatformSocialService and type(PlatformSocialService.peekIsPlatformFriend) == "function" then
		return PlatformSocialService:peekIsPlatformFriend(playerInfo) == true
	end

	return type(playerInfo) == "table" and playerInfo.isPlatformFriend == true
end

function PlatformUGCSpaceEntryFilterService.peekPlatformBlocked(playerInfo)
	playerInfo = PlatformUGCSpaceEntryFilterService.normalizePlayerInfo(playerInfo)

	if playerInfo == nil or not PlatformSocialService or type(PlatformSocialService.peekPlatformUserBlockedByLocalUser) ~= "function" then
		return false, PlatformUGCSpaceEntryFilterService.REASON_PLATFORM_BLOCK_LIST_UNAVAILABLE
	end

	local ok, blocked = pcall(function()
		return PlatformSocialService:peekPlatformUserBlockedByLocalUser(playerInfo)
	end)

	if not ok then
		logger:warn("ugc_space_entry_filter_platform_block_check_failed err=%s", tostring(blocked))

		return false, PlatformUGCSpaceEntryFilterService.REASON_PLATFORM_BLOCK_LIST_ERROR, blocked
	end

	if blocked == nil then
		return nil, PlatformUGCSpaceEntryFilterService.REASON_PLATFORM_BLOCK_LIST_PENDING
	end

	return blocked == true, nil
end

function PlatformUGCSpaceEntryFilterService.showTip(text)
	if string.isNilOrEmpty(text) then
		return
	end

	if pg and pg.global and pg.global.ui and pg.global.ui.tips then
		pg.global.ui.tips:showTextTip(text)
	elseif pg and pg.global and pg.global.showBubbleMessage then
		pg.global.showBubbleMessage(text)
	end
end

function PlatformUGCSpaceEntryFilterService:canEnterDestination(destinationContext, ownerPlayerInfo)
	destinationContext = destinationContext or {}

	if not PlatformUGCSpaceEntryFilterService.isUGCDestination(destinationContext) then
		return true, self.Decision.Allow, PlatformUGCSpaceEntryFilterService.makeContext(self.Decision.Allow, PlatformUGCSpaceEntryFilterService.REASON_NON_UGC_DESTINATION, destinationContext)
	end

	if not PlatformUGCSpaceEntryFilterService.isCurrentConsoleFamily() then
		return true, self.Decision.Allow, PlatformUGCSpaceEntryFilterService.makeContext(self.Decision.Allow, PlatformUGCSpaceEntryFilterService.REASON_CURRENT_NON_CONSOLE_FAMILY, destinationContext)
	end

	if string.isNilOrEmpty(destinationContext.ownerUid) then
		logger:error("ugc_space_entry_filter owner missing destinationKind=%s tokenType=%s inviterUid=%s", tostring(destinationContext.destinationKind or ""), tostring(destinationContext.tokenType or ""), tostring(destinationContext.inviterUid or ""))

		return false, self.Decision.Block, PlatformUGCSpaceEntryFilterService.makeContext(self.Decision.Block, self.REASON_UGC_DESTINATION_OWNER_MISSING, destinationContext)
	end

	ownerPlayerInfo = PlatformUGCSpaceEntryFilterService.resolveOwnerPlayerInfo(destinationContext, ownerPlayerInfo)

	local policy = PlatformUGCSpaceEntryFilterService.peekLocalUgcPolicy()
	local Policy = PlatformUGCService and PlatformUGCService.LocalPolicy or {}

	if policy == nil then
		logger:error("ugc_space_entry_filter local UGC policy cache missing uid=%s", tostring(destinationContext.ownerUid or ""))

		return true, self.Decision.Allow, PlatformUGCSpaceEntryFilterService.makeContext(self.Decision.Allow, PlatformUGCSpaceEntryFilterService.REASON_LOCAL_UGC_POLICY_MISSING, destinationContext)
	end

	if policy == Policy.Blocked or policy == "blocked" or policy == "deny" then
		return false, self.Decision.Block, PlatformUGCSpaceEntryFilterService.makeContext(self.Decision.Block, PlatformUGCSpaceEntryFilterService.REASON_LOCAL_UGC_BLOCKED, destinationContext)
	end

	if policy == Policy.FriendsOnly or policy == "friends_only" then
		if not PlatformUGCSpaceEntryFilterService.peekIsPlatformFriend(ownerPlayerInfo) then
			return false, self.Decision.Block, PlatformUGCSpaceEntryFilterService.makeContext(self.Decision.Block, PlatformUGCSpaceEntryFilterService.REASON_LOCAL_UGC_FRIENDS_ONLY, destinationContext)
		end
	elseif policy ~= Policy.Allow and policy ~= "allow" and policy ~= Policy.Fallback and policy ~= "fallback" then
		return true, self.Decision.Unknown, PlatformUGCSpaceEntryFilterService.makeContext(self.Decision.Unknown, PlatformUGCSpaceEntryFilterService.REASON_LOCAL_UGC_POLICY_UNKNOWN, destinationContext)
	end

	local blocked, blockReason, blockError = PlatformUGCSpaceEntryFilterService.peekPlatformBlocked(ownerPlayerInfo)

	if blocked == true then
		return false, self.Decision.Block, PlatformUGCSpaceEntryFilterService.makeContext(self.Decision.Block, PlatformUGCSpaceEntryFilterService.REASON_PLATFORM_BLOCK_LIST, destinationContext)
	end

	if type(destinationContext) ~= "table" then
		destinationContext = {}
	end

	if blockReason ~= nil then
		destinationContext.blockReason = blockReason
		destinationContext.blockError = blockError
	end

	local allowReason = PlatformUGCSpaceEntryFilterService.REASON_LOCAL_UGC_ALLOW

	if policy == Policy.FriendsOnly or policy == "friends_only" then
		allowReason = PlatformUGCSpaceEntryFilterService.REASON_LOCAL_UGC_FRIENDS_ONLY
	elseif policy == Policy.Fallback or policy == "fallback" then
		allowReason = PlatformUGCSpaceEntryFilterService.REASON_LOCAL_UGC_FALLBACK
	end

	local targetVisible, targetReason = PlatformUGCSpaceEntryFilterService.resolveTargetUgcVisible(ownerPlayerInfo, allowReason)

	if not targetVisible then
		return false, self.Decision.Block, PlatformUGCSpaceEntryFilterService.makeContext(self.Decision.Block, targetReason, destinationContext)
	end

	if targetReason == PlatformUGCSpaceEntryFilterService.REASON_TARGET_UGC_SWITCH_MISSING or targetReason == PlatformUGCSpaceEntryFilterService.REASON_TARGET_UGC_SWITCH_UNKNOWN then
		return true, self.Decision.Allow, PlatformUGCSpaceEntryFilterService.makeContext(self.Decision.Allow, targetReason, destinationContext)
	end

	if policy == Policy.FriendsOnly or policy == "friends_only" then
		return true, self.Decision.Allow, PlatformUGCSpaceEntryFilterService.makeContext(self.Decision.Allow, PlatformUGCSpaceEntryFilterService.REASON_LOCAL_UGC_FRIENDS_ONLY, destinationContext)
	end

	if policy == Policy.Fallback or policy == "fallback" then
		return true, self.Decision.Allow, PlatformUGCSpaceEntryFilterService.makeContext(self.Decision.Allow, PlatformUGCSpaceEntryFilterService.REASON_LOCAL_UGC_FALLBACK, destinationContext)
	end

	return true, self.Decision.Allow, PlatformUGCSpaceEntryFilterService.makeContext(self.Decision.Allow, PlatformUGCSpaceEntryFilterService.REASON_LOCAL_UGC_ALLOW, destinationContext)
end

return PlatformUGCSpaceEntryFilterService
