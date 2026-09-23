-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformHomeCampEntryFilterService.lua

local PlatformSocialService = require("SDK.Platform.PlatformSocialService")
local PlatformUGCService = require("SDK.Platform.PlatformUGCService")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformNoticeUtils = require("SDK.Platform.PlatformNoticeUtils")
local NoticeDef = require("Common.NoticeDef")
local logger = require("SDK.Platform.PlatformLogger")
local PlatformHomeCampEntryFilterService = {}

PlatformHomeCampEntryFilterService.Decision = {
	Block = "block",
	Unknown = "unknown",
	Allow = "allow"
}
PlatformHomeCampEntryFilterService.REASON_SELF = "self_home_camp_content"
PlatformHomeCampEntryFilterService.REASON_CURRENT_NON_CONSOLE_FAMILY = "current_non_console_family"
PlatformHomeCampEntryFilterService.REASON_HOME_CAMP_OWNER_MISSING = "home_camp_owner_missing"
PlatformHomeCampEntryFilterService.REASON_PLATFORM_BLOCK_LIST = "platform_block_list"
PlatformHomeCampEntryFilterService.REASON_PLATFORM_BLOCK_LIST_PENDING = "platform_block_list_pending"
PlatformHomeCampEntryFilterService.REASON_PLATFORM_BLOCK_LIST_UNAVAILABLE = "platform_block_list_unavailable"
PlatformHomeCampEntryFilterService.REASON_PLATFORM_BLOCK_LIST_ERROR = "platform_block_list_error"
PlatformHomeCampEntryFilterService.REASON_LOCAL_UGC_ALLOW = "local_ugc_privacy_allow"
PlatformHomeCampEntryFilterService.REASON_LOCAL_UGC_FALLBACK = "local_ugc_privacy_fallback"
PlatformHomeCampEntryFilterService.REASON_LOCAL_UGC_FRIENDS_ONLY = "local_ugc_privacy_friends_only"
PlatformHomeCampEntryFilterService.REASON_LOCAL_UGC_BLOCKED = "local_ugc_privacy_blocked"
PlatformHomeCampEntryFilterService.REASON_LOCAL_UGC_POLICY_MISSING = "local_ugc_policy_cache_missing"
PlatformHomeCampEntryFilterService.REASON_LOCAL_UGC_POLICY_UNKNOWN = "local_ugc_policy_unknown"
PlatformHomeCampEntryFilterService.REASON_TARGET_UGC_BLOCKED = "target_ugc_permission_denied"
PlatformHomeCampEntryFilterService.REASON_TARGET_UGC_SWITCH_MISSING = "target_ugc_switch_missing"

function PlatformHomeCampEntryFilterService.makeContext(decision, reason, extra)
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

function PlatformHomeCampEntryFilterService.isLocalPlayer(uid, playerInfo)
	local localUid = pg and pg.me and pg.me.uid
	local localPlayerId = pg and pg.me and pg.me.id

	function PlatformHomeCampEntryFilterService.matchesLocalId(value)
		if value == nil then
			return false
		end

		return localUid ~= nil and tostring(value) == tostring(localUid) or localPlayerId ~= nil and tostring(value) == tostring(localPlayerId)
	end

	if PlatformHomeCampEntryFilterService.matchesLocalId(uid) then
		return true
	end

	return type(playerInfo) == "table" and (PlatformHomeCampEntryFilterService.matchesLocalId(playerInfo.uid) or PlatformHomeCampEntryFilterService.matchesLocalId(playerInfo.playerId))
end

function PlatformHomeCampEntryFilterService.peekPlatformBlocked(playerInfo)
	if type(playerInfo) ~= "table" then
		return false, PlatformHomeCampEntryFilterService.REASON_PLATFORM_BLOCK_LIST_UNAVAILABLE
	end

	if type(PlatformSocialService.peekPlatformUserBlockedByLocalUser) ~= "function" then
		return false, PlatformHomeCampEntryFilterService.REASON_PLATFORM_BLOCK_LIST_UNAVAILABLE
	end

	local ok, blocked = pcall(function()
		return PlatformSocialService:peekPlatformUserBlockedByLocalUser(playerInfo)
	end)

	if not ok then
		logger:warn("home_camp_entry_filter_platform_block_check_failed err=%s", tostring(blocked))

		return false, PlatformHomeCampEntryFilterService.REASON_PLATFORM_BLOCK_LIST_ERROR, blocked
	end

	if blocked == nil then
		return nil, PlatformHomeCampEntryFilterService.REASON_PLATFORM_BLOCK_LIST_PENDING
	end

	return blocked == true, nil
end

function PlatformHomeCampEntryFilterService.peekIsPlatformFriend(playerInfo)
	if type(playerInfo) ~= "table" then
		return false
	end

	if type(PlatformSocialService.peekIsPlatformFriend) == "function" then
		return PlatformSocialService:peekIsPlatformFriend(playerInfo) == true
	end

	return playerInfo.isPlatformFriend == true
end

function PlatformHomeCampEntryFilterService.peekLocalUgcPolicy()
	if type(PlatformUGCService.peekLocalPolicy) ~= "function" then
		return nil
	end

	local ok, policy = pcall(function()
		return PlatformUGCService:peekLocalPolicy()
	end)

	if not ok then
		logger:warn("home_camp_entry_filter_local_ugc_policy_check_failed err=%s", tostring(policy))

		return nil
	end

	return policy
end

function PlatformHomeCampEntryFilterService.resolveOwnerPlayerInfo(uid, ownerPlayerInfo)
	if type(ownerPlayerInfo) == "table" then
		return ownerPlayerInfo
	end

	if string.isNilOrEmpty(uid) then
		return ownerPlayerInfo
	end

	if pg and pg.game and pg.game.chat and pg.game.chat.getPlayerInfo then
		return pg.game.chat:getPlayerInfo(tostring(uid))
	end

	return ownerPlayerInfo
end

function PlatformHomeCampEntryFilterService.resolveTargetUgcVisible(playerInfo)
	if type(playerInfo) ~= "table" then
		return true, PlatformHomeCampEntryFilterService.makeContext(PlatformHomeCampEntryFilterService.Decision.Allow, PlatformHomeCampEntryFilterService.REASON_TARGET_UGC_SWITCH_MISSING)
	end

	if type(PlatformUGCService.resolveTargetVisibleDecision) ~= "function" then
		return true, PlatformHomeCampEntryFilterService.makeContext(PlatformHomeCampEntryFilterService.Decision.Allow, PlatformHomeCampEntryFilterService.REASON_TARGET_UGC_SWITCH_MISSING)
	end

	local ok, visible, context = pcall(function()
		return PlatformUGCService:resolveTargetVisibleDecision(playerInfo, PlatformHomeCampEntryFilterService.REASON_LOCAL_UGC_ALLOW)
	end)

	if not ok then
		logger:warn("[home_camp_entry] resolveTargetUgcVisible failed err=%s", tostring(visible))

		return true, PlatformHomeCampEntryFilterService.makeContext(PlatformHomeCampEntryFilterService.Decision.Allow, PlatformHomeCampEntryFilterService.REASON_TARGET_UGC_SWITCH_MISSING)
	end

	return visible, context
end

function PlatformHomeCampEntryFilterService.isCurrentConsoleFamily()
	if type(PlatformIdentityUtils) ~= "table" or type(PlatformIdentityUtils.getCurrentPlatformFamily) ~= "function" or type(PlatformIdentityUtils.isConsoleFamily) ~= "function" then
		return false
	end

	return PlatformIdentityUtils.isConsoleFamily(PlatformIdentityUtils.getCurrentPlatformFamily()) == true
end

function PlatformHomeCampEntryFilterService:canEnterHomeCamp(ownerUid, ownerPlayerInfo, options)
	options = options or {}

	local uid = ownerUid or options.uid

	ownerPlayerInfo = PlatformHomeCampEntryFilterService.resolveOwnerPlayerInfo(uid, ownerPlayerInfo)

	if options.isSelf == true or PlatformHomeCampEntryFilterService.isLocalPlayer(uid, ownerPlayerInfo) then
		return true, self.Decision.Allow, PlatformHomeCampEntryFilterService.makeContext(self.Decision.Allow, PlatformHomeCampEntryFilterService.REASON_SELF, {
			uid = uid
		})
	end

	local targetVisible, targetContext = PlatformHomeCampEntryFilterService.resolveTargetUgcVisible(ownerPlayerInfo)

	if targetVisible == false then
		return false, self.Decision.Block, PlatformHomeCampEntryFilterService.makeContext(self.Decision.Block, PlatformHomeCampEntryFilterService.REASON_TARGET_UGC_BLOCKED, {
			uid = uid,
			targetReason = targetContext and targetContext.reason or nil
		})
	end

	if not PlatformHomeCampEntryFilterService.isCurrentConsoleFamily() then
		return true, self.Decision.Allow, PlatformHomeCampEntryFilterService.makeContext(self.Decision.Allow, PlatformHomeCampEntryFilterService.REASON_CURRENT_NON_CONSOLE_FAMILY, {
			uid = uid
		})
	end

	if string.isNilOrEmpty(uid) and type(ownerPlayerInfo) ~= "table" then
		return true, self.Decision.Allow, PlatformHomeCampEntryFilterService.makeContext(self.Decision.Allow, PlatformHomeCampEntryFilterService.REASON_HOME_CAMP_OWNER_MISSING)
	end

	local policy = PlatformHomeCampEntryFilterService.peekLocalUgcPolicy()
	local Policy = PlatformUGCService.LocalPolicy or {}

	if policy == nil then
		logger:error("home_camp_enter local UGC policy cache missing uid=%s", tostring(uid or ""))

		return true, self.Decision.Allow, PlatformHomeCampEntryFilterService.makeContext(self.Decision.Allow, PlatformHomeCampEntryFilterService.REASON_LOCAL_UGC_POLICY_MISSING, {
			uid = uid
		})
	end

	if policy == Policy.Blocked or policy == "blocked" or policy == "deny" then
		return false, self.Decision.Block, PlatformHomeCampEntryFilterService.makeContext(self.Decision.Block, PlatformHomeCampEntryFilterService.REASON_LOCAL_UGC_BLOCKED, {
			uid = uid
		})
	end

	if policy == Policy.FriendsOnly or policy == "friends_only" then
		if not PlatformHomeCampEntryFilterService.peekIsPlatformFriend(ownerPlayerInfo) then
			return false, self.Decision.Block, PlatformHomeCampEntryFilterService.makeContext(self.Decision.Block, PlatformHomeCampEntryFilterService.REASON_LOCAL_UGC_FRIENDS_ONLY, {
				uid = uid
			})
		end
	elseif policy ~= Policy.Allow and policy ~= "allow" and policy ~= Policy.Fallback and policy ~= "fallback" then
		return true, self.Decision.Unknown, PlatformHomeCampEntryFilterService.makeContext(self.Decision.Unknown, PlatformHomeCampEntryFilterService.REASON_LOCAL_UGC_POLICY_UNKNOWN, {
			uid = uid
		})
	end

	local blocked, blockReason, blockError = PlatformHomeCampEntryFilterService.peekPlatformBlocked(ownerPlayerInfo)

	if blocked == true then
		return false, self.Decision.Block, PlatformHomeCampEntryFilterService.makeContext(self.Decision.Block, PlatformHomeCampEntryFilterService.REASON_PLATFORM_BLOCK_LIST, {
			uid = uid
		})
	end

	local extra = {
		uid = uid
	}

	if blockReason ~= nil then
		extra.blockReason = blockReason
		extra.blockError = blockError
	end

	if policy == Policy.FriendsOnly or policy == "friends_only" then
		return true, self.Decision.Allow, PlatformHomeCampEntryFilterService.makeContext(self.Decision.Allow, PlatformHomeCampEntryFilterService.REASON_LOCAL_UGC_FRIENDS_ONLY, extra)
	end

	if policy == Policy.Fallback or policy == "fallback" then
		return true, self.Decision.Allow, PlatformHomeCampEntryFilterService.makeContext(self.Decision.Allow, PlatformHomeCampEntryFilterService.REASON_LOCAL_UGC_FALLBACK, extra)
	end

	return true, self.Decision.Allow, PlatformHomeCampEntryFilterService.makeContext(self.Decision.Allow, PlatformHomeCampEntryFilterService.REASON_LOCAL_UGC_ALLOW, extra)
end

return PlatformHomeCampEntryFilterService
