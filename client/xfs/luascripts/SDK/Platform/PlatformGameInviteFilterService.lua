-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformGameInviteFilterService.lua

local PlatformCommunicationService = require("SDK.Platform.PlatformCommunicationService")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local logger = require("SDK.Platform.PlatformLogger")
local PlatformGameInviteFilterService = {}

function PlatformGameInviteFilterService.isConsoleLocalUser()
	return PlatformIdentityUtils and PlatformIdentityUtils.isConsoleFamily and PlatformIdentityUtils.isConsoleFamily(PlatformIdentityUtils.getCurrentPlatformFamily()) == true
end

function PlatformGameInviteFilterService:shouldAllowInboundGameInvite(context)
	if not PlatformGameInviteFilterService.isConsoleLocalUser() then
		return true, "platform_unsupported"
	end

	local policy = PlatformCommunicationService:peekLocalCommunicationSetting()
	local setting = policy and policy.setting

	if policy == nil or setting == nil or setting == PlatformCommunicationService.CommunicationSetting.Unknown or policy.reason == PlatformCommunicationService.Reason.CheckPending then
		logger:error("inbound_game_invite_policy_unavailable context=%s reason=%s", tostring(context or ""), tostring(policy and policy.reason or "local_communication_policy_unavailable"))

		return true, "local_communication_policy_unavailable"
	end

	if setting == PlatformCommunicationService.CommunicationSetting.Blocked then
		if pg.global.platform:isPS() then
			return true, policy and policy.reason or "allowed"
		end

		logger:info("inbound_game_invite_filtered context=%s reason=%s", tostring(context or ""), tostring(policy and policy.reason or "local_communication_blocked"))

		return false, policy and policy.reason or "local_communication_blocked"
	end

	return true, policy and policy.reason or "allowed"
end

return PlatformGameInviteFilterService
