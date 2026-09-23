-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformHomeCarDecorationFilterService.lua

local PlatformSocialService = require("SDK.Platform.PlatformSocialService")
local PlatformUGCService = require("SDK.Platform.PlatformUGCService")
local logger = require("SDK.Platform.PlatformLogger")
local PlatformHomeCarDecorationFilterService = {}

PlatformHomeCarDecorationFilterService.Decision = {
	Block = "block",
	Unknown = "unknown",
	Allow = "allow"
}
PlatformHomeCarDecorationFilterService.REASON_SELF_HOME_CAR_DECORATION = "self_home_car_decoration"
PlatformHomeCarDecorationFilterService.REASON_PLATFORM_BLOCK_LIST = "platform_block_list"
PlatformHomeCarDecorationFilterService.REASON_PLATFORM_BLOCK_LIST_PENDING = "platform_block_list_pending"
PlatformHomeCarDecorationFilterService.REASON_PLATFORM_BLOCK_LIST_UNAVAILABLE = "platform_block_list_unavailable"
PlatformHomeCarDecorationFilterService.REASON_PLATFORM_BLOCK_LIST_ERROR = "platform_block_list_error"
PlatformHomeCarDecorationFilterService.REASON_LOCAL_UGC_ALLOW = "local_ugc_privacy_allow"
PlatformHomeCarDecorationFilterService.REASON_LOCAL_UGC_FALLBACK = "local_ugc_privacy_fallback"
PlatformHomeCarDecorationFilterService.REASON_LOCAL_UGC_FRIENDS_ONLY = "local_ugc_privacy_friends_only"
PlatformHomeCarDecorationFilterService.REASON_LOCAL_UGC_BLOCKED = "local_ugc_privacy_blocked"
PlatformHomeCarDecorationFilterService.REASON_LOCAL_UGC_POLICY_MISSING = "local_ugc_policy_cache_missing"
PlatformHomeCarDecorationFilterService.REASON_LOCAL_UGC_POLICY_UNKNOWN = "local_ugc_policy_unknown"
PlatformHomeCarDecorationFilterService.REASON_TARGET_UGC_PERMISSION_DENIED = "target_ugc_permission_denied"
PlatformHomeCarDecorationFilterService.REASON_TARGET_UGC_SWITCH_MISSING = "target_ugc_switch_missing"
PlatformHomeCarDecorationFilterService.REASON_TARGET_UGC_SWITCH_UNKNOWN = "target_ugc_switch_unknown"

function PlatformHomeCarDecorationFilterService.makeContext(decision, reason, extra)
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

function PlatformHomeCarDecorationFilterService:isLocalPlayer(uid, playerInfo, options)
	if options and options.isSelf == true then
		return true
	end

	local localUid = pg.me.uid
	local localPlayerId = pg.me.id

	if uid ~= nil and (localUid ~= nil and tostring(uid) == tostring(localUid) or localPlayerId ~= nil and tostring(uid) == tostring(localPlayerId)) then
		return true
	end

	if playerInfo == nil then
		return false
	end

	return localUid ~= nil and tostring(playerInfo.uid) == tostring(localUid) or localPlayerId ~= nil and tostring(playerInfo.playerId) == tostring(localPlayerId)
end

function PlatformHomeCarDecorationFilterService.peekPlatformBlocked(playerInfo)
	if type(playerInfo) ~= "table" then
		if PlatformSocialService.isPlatformSupported and PlatformSocialService.isPlatformSupported() then
			return nil, PlatformHomeCarDecorationFilterService.REASON_PLATFORM_BLOCK_LIST_PENDING
		end

		return false, PlatformHomeCarDecorationFilterService.REASON_PLATFORM_BLOCK_LIST_UNAVAILABLE
	end

	if type(PlatformSocialService.peekPlatformUserBlockedByLocalUser) ~= "function" then
		return false, PlatformHomeCarDecorationFilterService.REASON_PLATFORM_BLOCK_LIST_UNAVAILABLE
	end

	local ok, blocked = pcall(function()
		return PlatformSocialService:peekPlatformUserBlockedByLocalUser(playerInfo)
	end)

	if not ok then
		logger:warn("home_car_decoration_filter_platform_block_check_failed err=%s", tostring(blocked))

		return false, PlatformHomeCarDecorationFilterService.REASON_PLATFORM_BLOCK_LIST_ERROR, blocked
	end

	if blocked == nil then
		return nil, PlatformHomeCarDecorationFilterService.REASON_PLATFORM_BLOCK_LIST_PENDING
	end

	return blocked == true, nil
end

function PlatformHomeCarDecorationFilterService.peekIsPlatformFriend(playerInfo)
	if type(playerInfo) ~= "table" then
		return false
	end

	if type(PlatformSocialService.peekIsPlatformFriend) == "function" then
		return PlatformSocialService:peekIsPlatformFriend(playerInfo) == true
	end

	return playerInfo.isPlatformFriend == true
end

function PlatformHomeCarDecorationFilterService.peekLocalUgcPolicy()
	if type(PlatformUGCService.peekLocalPolicy) ~= "function" then
		return nil
	end

	local ok, policy = pcall(function()
		return PlatformUGCService:peekLocalPolicy()
	end)

	if not ok then
		logger:warn("home_car_decoration_filter_local_ugc_policy_check_failed err=%s", tostring(policy))

		return nil
	end

	return policy
end

function PlatformHomeCarDecorationFilterService.resolveTargetUgcVisible(playerInfo, allowReason)
	if not PlatformUGCService or type(PlatformUGCService.resolveTargetVisibleDecision) ~= "function" then
		return true, allowReason
	end

	local ok, visible, context = pcall(function()
		return PlatformUGCService:resolveTargetVisibleDecision(playerInfo, allowReason)
	end)

	if not ok then
		logger:warn("home_car_decoration_filter_target_ugc_visible_check_failed err=%s", tostring(visible))

		return true, allowReason
	end

	return visible ~= false, context and context.ugcReason or allowReason
end

function PlatformHomeCarDecorationFilterService:evaluateHomeCarDecoration(playerInfo, options)
	options = options or {}

	local uid = options.uid

	if self:isLocalPlayer(uid, playerInfo, options) then
		return false, self.Decision.Allow, PlatformHomeCarDecorationFilterService.makeContext(self.Decision.Allow, PlatformHomeCarDecorationFilterService.REASON_SELF_HOME_CAR_DECORATION, {
			uid = uid
		})
	end

	local blocked, blockReason, blockError = PlatformHomeCarDecorationFilterService.peekPlatformBlocked(playerInfo)

	if blocked == true then
		return true, self.Decision.Block, PlatformHomeCarDecorationFilterService.makeContext(self.Decision.Block, PlatformHomeCarDecorationFilterService.REASON_PLATFORM_BLOCK_LIST, {
			uid = uid
		})
	end

	if blocked == nil then
		return true, self.Decision.Unknown, PlatformHomeCarDecorationFilterService.makeContext(self.Decision.Unknown, blockReason, {
			uid = uid
		})
	end

	local blockContext

	if blockReason ~= nil then
		blockContext = {
			blockReason = blockReason,
			blockError = blockError
		}
	end

	local policy = PlatformHomeCarDecorationFilterService.peekLocalUgcPolicy()
	local Policy = PlatformUGCService.LocalPolicy or {}

	if policy == nil then
		logger:error("home_car_decoration_filter local UGC policy cache missing")

		return false, self.Decision.Allow, PlatformHomeCarDecorationFilterService.makeContext(self.Decision.Allow, PlatformHomeCarDecorationFilterService.REASON_LOCAL_UGC_POLICY_MISSING, blockContext)
	end

	if policy ~= Policy.Blocked and policy ~= "blocked" and policy ~= "deny" then
		if policy == Policy.FriendsOnly or policy == "friends_only" then
			if not PlatformHomeCarDecorationFilterService.peekIsPlatformFriend(playerInfo) then
				return true, self.Decision.Block, PlatformHomeCarDecorationFilterService.makeContext(self.Decision.Block, PlatformHomeCarDecorationFilterService.REASON_LOCAL_UGC_FRIENDS_ONLY, blockContext)
			end
		elseif policy ~= Policy.Allow and policy ~= "allow" and policy ~= Policy.Fallback and policy ~= "fallback" then
			return false, self.Decision.Unknown, PlatformHomeCarDecorationFilterService.makeContext(self.Decision.Unknown, PlatformHomeCarDecorationFilterService.REASON_LOCAL_UGC_POLICY_UNKNOWN, blockContext)
		end

		local allowReason = PlatformHomeCarDecorationFilterService.REASON_LOCAL_UGC_ALLOW

		if policy == Policy.FriendsOnly or policy == "friends_only" then
			allowReason = PlatformHomeCarDecorationFilterService.REASON_LOCAL_UGC_FRIENDS_ONLY
		elseif policy == Policy.Fallback or policy == "fallback" then
			allowReason = PlatformHomeCarDecorationFilterService.REASON_LOCAL_UGC_FALLBACK
		end

		local targetVisible, targetReason = PlatformHomeCarDecorationFilterService.resolveTargetUgcVisible(playerInfo, allowReason)

		if not targetVisible then
			return true, self.Decision.Block, PlatformHomeCarDecorationFilterService.makeContext(self.Decision.Block, targetReason, blockContext)
		end

		if targetReason == PlatformHomeCarDecorationFilterService.REASON_TARGET_UGC_SWITCH_MISSING or targetReason == PlatformHomeCarDecorationFilterService.REASON_TARGET_UGC_SWITCH_UNKNOWN then
			return false, self.Decision.Allow, PlatformHomeCarDecorationFilterService.makeContext(self.Decision.Allow, targetReason, blockContext)
		end
	end

	if policy == Policy.Allow or policy == "allow" then
		return false, self.Decision.Allow, PlatformHomeCarDecorationFilterService.makeContext(self.Decision.Allow, PlatformHomeCarDecorationFilterService.REASON_LOCAL_UGC_ALLOW, blockContext)
	end

	if policy == Policy.Fallback or policy == "fallback" then
		return false, self.Decision.Allow, PlatformHomeCarDecorationFilterService.makeContext(self.Decision.Allow, PlatformHomeCarDecorationFilterService.REASON_LOCAL_UGC_FALLBACK, blockContext)
	end

	if policy == Policy.FriendsOnly or policy == "friends_only" then
		return false, self.Decision.Allow, PlatformHomeCarDecorationFilterService.makeContext(self.Decision.Allow, PlatformHomeCarDecorationFilterService.REASON_LOCAL_UGC_FRIENDS_ONLY, blockContext)
	end

	if policy == Policy.Blocked or policy == "blocked" or policy == "deny" then
		return true, self.Decision.Block, PlatformHomeCarDecorationFilterService.makeContext(self.Decision.Block, PlatformHomeCarDecorationFilterService.REASON_LOCAL_UGC_BLOCKED, blockContext)
	end

	return false, self.Decision.Unknown, PlatformHomeCarDecorationFilterService.makeContext(self.Decision.Unknown, PlatformHomeCarDecorationFilterService.REASON_LOCAL_UGC_POLICY_UNKNOWN, blockContext)
end

function PlatformHomeCarDecorationFilterService:shouldShowHomeCarDecoration(playerInfo, options)
	local shouldHide, decision, context = self:evaluateHomeCarDecoration(playerInfo, options)

	return shouldHide ~= true, decision, context
end

return PlatformHomeCarDecorationFilterService
