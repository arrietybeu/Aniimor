-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformPhotographyStudioInviteFilterService.lua

local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformSocialService = require("SDK.Platform.PlatformSocialService")
local PlatformTextCommunicationService = require("SDK.Platform.PlatformTextCommunicationService")
local logger = require("SDK.Platform.PlatformLogger")
local PlatformPhotographyStudioInviteFilterService = {}

PlatformPhotographyStudioInviteFilterService.Decision = {
	Allow = "allow",
	Pending = "pending",
	Block = "block"
}
PlatformPhotographyStudioInviteFilterService.REASON_ALLOWED = "photography_studio_invite_allowed"
PlatformPhotographyStudioInviteFilterService.REASON_CURRENT_NON_CONSOLE_FAMILY = "current_non_console_family"
PlatformPhotographyStudioInviteFilterService.REASON_LOCAL_COMMUNICATION_BLOCKED = "local_communication_blocked"
PlatformPhotographyStudioInviteFilterService.REASON_PLATFORM_BLOCK_LIST = "platform_block_list"
PlatformPhotographyStudioInviteFilterService.REASON_LOCAL_COMMUNICATION_POLICY_PENDING = "local_communication_policy_pending"
PlatformPhotographyStudioInviteFilterService.REASON_PLATFORM_BLOCK_LIST_PENDING = "platform_block_list_pending"
PlatformPhotographyStudioInviteFilterService.REASON_PLAYER_INFO_PENDING = "player_info_pending"

local function makeContext(decision, reason)
	return {
		decision = decision,
		reason = reason
	}
end

local function isCurrentSupportedPlatform()
	if type(PlatformIdentityUtils) ~= "table" or type(PlatformIdentityUtils.getCurrentPlatformFamily) ~= "function" then
		return false
	end

	local family = PlatformIdentityUtils.getCurrentPlatformFamily()
	local Family = PlatformIdentityUtils.Family or {}

	if family == Family.Xbox or family == "xbox" then
		return true
	end

	if family ~= Family.PlayStation and family ~= "playstation" then
		return false
	end

	return type(PlatformIdentityUtils.getCurrentRawPlatform) == "function" and string.upper(tostring(PlatformIdentityUtils.getCurrentRawPlatform() or "")) == "PS5"
end

local function peekLocalCommunicationPrivilege()
	if type(PlatformTextCommunicationService) ~= "table" or type(PlatformTextCommunicationService.peekLocalTextCommunicationPrivilege) ~= "function" then
		return nil
	end

	local ok, decision = pcall(PlatformTextCommunicationService.peekLocalTextCommunicationPrivilege, PlatformTextCommunicationService)

	if not ok then
		logger:warn("photography_studio_invite_local_communication_privilege_check_failed err=%s", tostring(decision))

		return nil
	end

	if decision == nil and type(PlatformTextCommunicationService.prefetchLocalTextCommunicationPrivilege) == "function" then
		local prefetchOk, prefetchError = pcall(PlatformTextCommunicationService.prefetchLocalTextCommunicationPrivilege, PlatformTextCommunicationService)

		if not prefetchOk then
			logger:warn("photography_studio_invite_local_communication_privilege_prefetch_failed err=%s", tostring(prefetchError))
		end
	end

	return decision
end

local function peekPlatformBlocked(playerInfo)
	if playerInfo == nil or type(PlatformSocialService) ~= "table" or type(PlatformSocialService.peekPlatformUserBlockedByLocalUser) ~= "function" or type(PlatformIdentityUtils.resolvePlatformUserId) ~= "function" then
		return nil
	end

	local identityOk, platformUserId = pcall(PlatformIdentityUtils.resolvePlatformUserId, playerInfo)

	if not identityOk or platformUserId == nil or tostring(platformUserId) == "" then
		return nil
	end

	if type(PlatformSocialService.isPlatformAvoidListReady) == "function" then
		local readyOk, ready = pcall(PlatformSocialService.isPlatformAvoidListReady)

		if not readyOk or ready ~= true then
			return nil
		end
	end

	local ok, blocked = pcall(PlatformSocialService.peekPlatformUserBlockedByLocalUser, PlatformSocialService, playerInfo)

	if not ok then
		logger:warn("photography_studio_invite_platform_block_check_failed err=%s", tostring(blocked))

		return nil
	end

	return blocked
end

local function evaluateLocalPrivacy(self, playerInfo)
	if not isCurrentSupportedPlatform() then
		return true, self.Decision.Allow, makeContext(self.Decision.Allow, self.REASON_CURRENT_NON_CONSOLE_FAMILY)
	end

	local privilegeDecision = peekLocalCommunicationPrivilege()
	local Decision = PlatformTextCommunicationService.Decision or {}

	if privilegeDecision == nil or privilegeDecision == Decision.Unknown or privilegeDecision == "unknown" then
		return false, self.Decision.Pending, makeContext(self.Decision.Pending, self.REASON_LOCAL_COMMUNICATION_POLICY_PENDING)
	end

	if privilegeDecision == Decision.Deny or privilegeDecision == "deny" then
		return false, self.Decision.Block, makeContext(self.Decision.Block, self.REASON_LOCAL_COMMUNICATION_BLOCKED)
	end

	if privilegeDecision ~= Decision.Allow and privilegeDecision ~= "allow" and privilegeDecision ~= Decision.Fallback and privilegeDecision ~= "fallback" then
		return false, self.Decision.Pending, makeContext(self.Decision.Pending, self.REASON_LOCAL_COMMUNICATION_POLICY_PENDING)
	end

	if playerInfo == nil then
		return false, self.Decision.Pending, makeContext(self.Decision.Pending, self.REASON_PLAYER_INFO_PENDING)
	end

	local platformBlocked = peekPlatformBlocked(playerInfo)

	if platformBlocked == nil then
		return false, self.Decision.Pending, makeContext(self.Decision.Pending, self.REASON_PLATFORM_BLOCK_LIST_PENDING)
	end

	if platformBlocked == true then
		return false, self.Decision.Block, makeContext(self.Decision.Block, self.REASON_PLATFORM_BLOCK_LIST)
	end

	return true, self.Decision.Allow, makeContext(self.Decision.Allow, self.REASON_ALLOWED)
end

function PlatformPhotographyStudioInviteFilterService:canReceiveInvite(playerInfo)
	return evaluateLocalPrivacy(self, playerInfo)
end

return PlatformPhotographyStudioInviteFilterService
