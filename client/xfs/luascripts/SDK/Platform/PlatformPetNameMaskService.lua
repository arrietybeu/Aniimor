-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformPetNameMaskService.lua

local PlatformTextCommunicationService = require("SDK.Platform.PlatformTextCommunicationService")
local PlatformUGCService = require("SDK.Platform.PlatformUGCService")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformSocialService = require("SDK.Platform.PlatformSocialService")
local logger = require("SDK.Platform.PlatformLogger")
local PlatformPetNameMaskService = {}

PlatformPetNameMaskService.Action = {
	PetExchangePetName = "ugc_pet_exchange_pet_name",
	PetCustomName = "ugc_pet_custom_name",
	TopLogoPetName = "ugc_pet_top_logo_name"
}

function PlatformPetNameMaskService.isNilOrEmpty(str)
	if string and type(string.isNilOrEmpty) == "function" then
		return string.isNilOrEmpty(str)
	end

	return str == nil or str == ""
end

function PlatformPetNameMaskService.isLocalPlayer(uid, playerInfo)
	local localUid = pg and pg.me and pg.me.uid
	local localPlayerId = pg and pg.me and pg.me.id

	if localUid == nil and localPlayerId == nil then
		return false
	end

	function PlatformPetNameMaskService.matchesLocalId(value)
		if value == nil then
			return false
		end

		return localUid ~= nil and tostring(value) == tostring(localUid) or localPlayerId ~= nil and tostring(value) == tostring(localPlayerId)
	end

	if PlatformPetNameMaskService.matchesLocalId(uid) then
		return true
	end

	return type(playerInfo) == "table" and (PlatformPetNameMaskService.matchesLocalId(playerInfo.uid) or PlatformPetNameMaskService.matchesLocalId(playerInfo.playerId))
end

function PlatformPetNameMaskService.getChatSystem()
	return pg and pg.game and pg.game.chat or nil
end

function PlatformPetNameMaskService.getCachedPlayerInfo(uid)
	local chatSystem = PlatformPetNameMaskService.getChatSystem()

	if PlatformPetNameMaskService.isNilOrEmpty(uid) or not chatSystem or not chatSystem.getPlayerInfo then
		return nil
	end

	return chatSystem:getPlayerInfo(uid)
end

function PlatformPetNameMaskService.resolveSeedPlayerInfo(uid, playerInfo)
	if type(playerInfo) == "table" then
		return playerInfo
	end

	return PlatformPetNameMaskService.getCachedPlayerInfo(uid)
end

function PlatformPetNameMaskService.markContext(context, isVisible, reason)
	context = context or {}
	context.petNameDecision = isVisible and PlatformUGCService.Decision.Allow or PlatformUGCService.Decision.Deny
	context.petNameVisible = isVisible

	if reason then
		context.petNameReason = reason
	end

	return context
end

function PlatformPetNameMaskService.isCurrentConsoleFamily()
	return PlatformIdentityUtils and type(PlatformIdentityUtils.getCurrentPlatformFamily) == "function" and type(PlatformIdentityUtils.isConsoleFamily) == "function" and PlatformIdentityUtils.isConsoleFamily(PlatformIdentityUtils.getCurrentPlatformFamily()) == true
end

function PlatformPetNameMaskService.isBlockedByLocalUser(playerInfo)
	return type(PlatformSocialService.isPlatformUserBlockedByLocalUser) == "function" and PlatformSocialService:isPlatformUserBlockedByLocalUser(playerInfo) == true
end

function PlatformPetNameMaskService.getLocalUgcPolicy()
	if not PlatformUGCService or type(PlatformUGCService.peekLocalPolicy) ~= "function" then
		logger:error("PlatformPetNameMaskService local UGC policy service missing; allow by default")

		return nil
	end

	return PlatformUGCService:peekLocalPolicy()
end

function PlatformPetNameMaskService.isPlatformFriend(playerInfo)
	return type(playerInfo) == "table" and playerInfo.isPlatformFriend == true
end

function PlatformPetNameMaskService.resolveLocalUgcVisibility(resolvedPlayerInfo)
	local policy = PlatformPetNameMaskService.getLocalUgcPolicy()
	local Policy = PlatformUGCService and PlatformUGCService.LocalPolicy or {}
	local Decision = PlatformUGCService.Decision

	if policy == nil then
		logger:error("PlatformPetNameMaskService local UGC policy cache missing; allow by default")

		return Decision.Allow, true, PlatformPetNameMaskService.markContext({
			ugcReason = "local_ugc_policy_cache_missing",
			ugcVisible = true,
			ugcDecision = Decision.Allow
		}, true, "local_ugc_policy_cache_missing")
	end

	if policy == Policy.Blocked or policy == "blocked" then
		return Decision.Deny, false, PlatformPetNameMaskService.markContext({
			ugcReason = "local_ugc_privacy_blocked",
			ugcVisible = false,
			ugcDecision = Decision.Deny
		}, false, "local_ugc_privacy_blocked")
	end

	if policy == Policy.FriendsOnly or policy == "friends_only" then
		local visible = PlatformPetNameMaskService.isPlatformFriend(resolvedPlayerInfo)
		local decision = visible and Decision.Allow or Decision.Deny

		if visible and PlatformUGCService and type(PlatformUGCService.resolveTargetVisibleDecision) == "function" then
			local targetVisible, targetContext = PlatformUGCService:resolveTargetVisibleDecision(resolvedPlayerInfo, "local_ugc_privacy_friends_only")
			local targetDecision = targetVisible and Decision.Allow or Decision.Deny

			return targetDecision, targetVisible, PlatformPetNameMaskService.markContext({
				ugcDecision = targetDecision,
				ugcVisible = targetVisible,
				ugcReason = targetContext and targetContext.ugcReason or "local_ugc_privacy_friends_only"
			}, targetVisible, targetContext and targetContext.ugcReason or "local_ugc_privacy_friends_only")
		end

		return decision, visible, PlatformPetNameMaskService.markContext({
			ugcReason = "local_ugc_privacy_friends_only",
			ugcDecision = decision,
			ugcVisible = visible
		}, visible, "local_ugc_privacy_friends_only")
	end

	local reason = (policy == Policy.Fallback or policy == "fallback") and "local_ugc_privacy_fallback" or "local_ugc_privacy_allow"

	if PlatformUGCService and type(PlatformUGCService.resolveTargetVisibleDecision) == "function" then
		local targetVisible, targetContext = PlatformUGCService:resolveTargetVisibleDecision(resolvedPlayerInfo, reason)
		local targetDecision = targetVisible and Decision.Allow or Decision.Deny

		return targetDecision, targetVisible, PlatformPetNameMaskService.markContext({
			ugcDecision = targetDecision,
			ugcVisible = targetVisible,
			ugcReason = targetContext and targetContext.ugcReason or reason
		}, targetVisible, targetContext and targetContext.ugcReason or reason)
	end

	return Decision.Allow, true, PlatformPetNameMaskService.markContext({
		ugcVisible = true,
		ugcDecision = Decision.Allow,
		ugcReason = reason
	}, true, reason)
end

function PlatformPetNameMaskService:peekPetNameVisibility(uid, playerInfo)
	if not PlatformPetNameMaskService.isCurrentConsoleFamily() then
		return PlatformUGCService.Decision.Allow, true, playerInfo, PlatformPetNameMaskService.markContext({}, true, "non_console_family")
	end

	local resolvedPlayerInfo = PlatformPetNameMaskService.resolveSeedPlayerInfo(uid, playerInfo)

	if PlatformPetNameMaskService.isLocalPlayer(uid, resolvedPlayerInfo) then
		return PlatformUGCService.Decision.Allow, true, resolvedPlayerInfo, PlatformPetNameMaskService.markContext({}, true, "local_player")
	end

	if PlatformPetNameMaskService.isBlockedByLocalUser(resolvedPlayerInfo) then
		return PlatformUGCService.Decision.Deny, false, resolvedPlayerInfo, PlatformPetNameMaskService.markContext({
			ugcDecision = PlatformUGCService.Decision.Deny
		}, false, "local_block_list")
	end

	local decision, visible, context = PlatformPetNameMaskService.resolveLocalUgcVisibility(resolvedPlayerInfo)

	return decision, visible, resolvedPlayerInfo, context
end

function PlatformPetNameMaskService:resolvePetNameVisibility(action, uid, playerInfo, onResolved)
	local decision, visible, resolvedPlayerInfo, context = self:peekPetNameVisibility(uid, playerInfo)

	if type(onResolved) == "function" then
		onResolved(visible ~= false, resolvedPlayerInfo, context or {})
	end

	return false
end

function PlatformPetNameMaskService.getMaskedDisplayPetName(options)
	if type(options) ~= "table" then
		return "", true, nil, PlatformPetNameMaskService.markContext({}, true, "invalid_options")
	end

	local customName = options.customName or ""
	local configName = options.configName or ""
	local decision, visible, resolvedInfo, context = PlatformPetNameMaskService:peekPetNameVisibility(options.uid, options.playerInfo)

	if visible == false then
		return "", false, resolvedInfo, context
	end

	if PlatformPetNameMaskService.isNilOrEmpty(customName) then
		return configName, true, options.playerInfo, PlatformPetNameMaskService.markContext({}, true, "config_name")
	end

	if not PlatformPetNameMaskService.isCurrentConsoleFamily() then
		return customName, true, options.playerInfo, PlatformPetNameMaskService.markContext({}, true, "non_console_family")
	end

	return customName, true, resolvedInfo, context
end

return PlatformPetNameMaskService
