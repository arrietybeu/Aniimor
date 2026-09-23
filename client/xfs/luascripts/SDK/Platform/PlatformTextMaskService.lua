-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformTextMaskService.lua

local PlatformTextCommunicationService = require("SDK.Platform.PlatformTextCommunicationService")
local PlatformUGCService = require("SDK.Platform.PlatformUGCService")
local PlatformSocialService = require("SDK.Platform.PlatformSocialService")
local PlatformNoticeUtils = require("SDK.Platform.PlatformNoticeUtils")
local NoticeDef = require("Common.NoticeDef")
local logger = require("SDK.Platform.PlatformLogger")
local PlatformTextMaskService = {}

PlatformTextMaskService.BLOCKED_CONTENT_NOTICE_ID = NoticeDef.PRIVACY_SETTING_MISSMATCH
PlatformTextMaskService.NO_PLAYER_SIGNATURE_KEY = "NO_PLAYER_SIGNATURE"
PlatformTextMaskService.PENDING_DECISION = "pending"

function PlatformTextMaskService.makeContext(decision, visible, reason)
	return {
		textDecision = decision,
		textVisible = visible ~= false,
		textReason = reason or string.Empty
	}
end

function PlatformTextMaskService.getChatSystem()
	return pg and pg.game and pg.game.chat or nil
end

function PlatformTextMaskService.getCachedPlayerInfo(uid)
	local chatSystem = PlatformTextMaskService.getChatSystem()

	if string.isNilOrEmpty(uid) or not chatSystem or not chatSystem.getPlayerInfo then
		return nil
	end

	return chatSystem:getPlayerInfo(uid)
end

function PlatformTextMaskService.resolveSeedPlayerInfo(uid, playerInfo)
	if type(playerInfo) == "table" then
		return playerInfo
	end

	return PlatformTextMaskService.getCachedPlayerInfo(uid)
end

function PlatformTextMaskService.isLocalPlayer(uid, playerInfo)
	local localUid = pg and pg.me and pg.me.uid
	local localPlayerId = pg and pg.me and pg.me.id

	if localUid == nil and localPlayerId == nil then
		return false
	end

	function PlatformTextMaskService.matchesLocalId(value)
		if value == nil then
			return false
		end

		return localUid ~= nil and tostring(value) == tostring(localUid) or localPlayerId ~= nil and tostring(value) == tostring(localPlayerId)
	end

	if PlatformTextMaskService.matchesLocalId(uid) then
		return true
	end

	return type(playerInfo) == "table" and (PlatformTextMaskService.matchesLocalId(playerInfo.uid) or PlatformTextMaskService.matchesLocalId(playerInfo.playerId))
end

function PlatformTextMaskService.peekPlatformBlocked(playerInfo)
	if type(PlatformSocialService.peekPlatformUserBlockedByLocalUser) ~= "function" then
		return false
	end

	return PlatformSocialService:peekPlatformUserBlockedByLocalUser(playerInfo)
end

function PlatformTextMaskService.peekIsPlatformFriend(playerInfo)
	if type(playerInfo) == "table" and playerInfo.isPlatformFriend == true then
		return true
	end

	if type(PlatformSocialService.peekIsPlatformFriend) == "function" then
		return PlatformSocialService:peekIsPlatformFriend(playerInfo)
	end

	return false
end

function PlatformTextMaskService.resolveLocalPolicyNow()
	if not PlatformUGCService or type(PlatformUGCService.peekLocalPolicy) ~= "function" then
		logger:error("text_mask local UGC policy service missing; allow by default")

		return PlatformUGCService and PlatformUGCService.LocalPolicy and PlatformUGCService.LocalPolicy.Fallback or "fallback"
	end

	return PlatformUGCService:peekLocalPolicy()
end

function PlatformTextMaskService.evaluateVisibility(uid, playerInfo, action)
	local resolvedPlayerInfo = PlatformTextMaskService.resolveSeedPlayerInfo(uid, playerInfo)
	local Decision = PlatformTextCommunicationService.Decision or {
		Deny = "deny",
		Allow = "allow"
	}

	if PlatformTextMaskService.isLocalPlayer(uid, resolvedPlayerInfo) then
		return Decision.Allow, true, resolvedPlayerInfo, PlatformTextMaskService.makeContext(Decision.Allow, true, "local_player")
	end

	local blocked = PlatformTextMaskService.peekPlatformBlocked(resolvedPlayerInfo)

	if blocked == true then
		return Decision.Deny, false, resolvedPlayerInfo, PlatformTextMaskService.makeContext(Decision.Deny, false, "platform_user_blocked")
	elseif blocked == nil then
		logger:error("text_mask platform block list cache missing; allow by default")
	end

	local policy = PlatformTextMaskService.resolveLocalPolicyNow()
	local Policy = PlatformUGCService and PlatformUGCService.LocalPolicy or {}

	if policy == nil then
		return PlatformTextMaskService.PENDING_DECISION, nil, resolvedPlayerInfo, PlatformTextMaskService.makeContext(PlatformTextMaskService.PENDING_DECISION, true, "local_ugc_policy_pending")
	end

	if policy == Policy.Blocked or policy == "blocked" or policy == "deny" then
		return Decision.Deny, false, resolvedPlayerInfo, PlatformTextMaskService.makeContext(Decision.Deny, false, "local_ugc_privacy_blocked")
	end

	if policy == Policy.FriendsOnly or policy == "friends_only" then
		local isFriend = PlatformTextMaskService.peekIsPlatformFriend(resolvedPlayerInfo)

		if isFriend == nil then
			logger:error("text_mask platform friend cache missing; allow by default")

			return Decision.Allow, true, resolvedPlayerInfo, PlatformTextMaskService.makeContext(Decision.Allow, true, "platform_friend_cache_missing")
		end

		local visible = isFriend == true
		local decision = visible and Decision.Allow or Decision.Deny

		if visible and PlatformUGCService and type(PlatformUGCService.resolveTargetVisibleDecision) == "function" then
			local targetVisible, targetContext = PlatformUGCService:resolveTargetVisibleDecision(resolvedPlayerInfo, "local_ugc_privacy_friends_only")
			local targetDecision = targetVisible and Decision.Allow or Decision.Deny

			return targetDecision, targetVisible, resolvedPlayerInfo, PlatformTextMaskService.makeContext(targetDecision, targetVisible, targetContext and targetContext.ugcReason or "local_ugc_privacy_friends_only")
		end

		return decision, visible, resolvedPlayerInfo, PlatformTextMaskService.makeContext(decision, visible, "local_ugc_privacy_friends_only")
	end

	local reason = (policy == Policy.Fallback or policy == "fallback") and "local_ugc_privacy_fallback" or "local_ugc_privacy_allow"

	if PlatformUGCService and type(PlatformUGCService.resolveTargetVisibleDecision) == "function" then
		local targetVisible, targetContext = PlatformUGCService:resolveTargetVisibleDecision(resolvedPlayerInfo, reason)
		local decision = targetVisible and Decision.Allow or Decision.Deny

		return decision, targetVisible, resolvedPlayerInfo, PlatformTextMaskService.makeContext(decision, targetVisible, targetContext and targetContext.ugcReason or reason)
	end

	return Decision.Allow, true, resolvedPlayerInfo, PlatformTextMaskService.makeContext(Decision.Allow, true, reason)
end

function PlatformTextMaskService.isRequestGuardEnabled(options)
	return type(options.requestState) == "table" and options.requestKey ~= nil
end

function PlatformTextMaskService.nextRequestId(options)
	if not PlatformTextMaskService.isRequestGuardEnabled(options) then
		return nil
	end

	local requestId = (options.requestState[options.requestKey] or 0) + 1

	options.requestState[options.requestKey] = requestId

	return requestId
end

function PlatformTextMaskService.isBindingAlive(options, requestId)
	if type(options.isAlive) == "function" and options.isAlive() == false then
		return false
	end

	if requestId ~= nil and options.requestState[options.requestKey] ~= requestId then
		return false
	end

	return true
end

function PlatformTextMaskService:getBlockedContentText()
	return ""
end

function PlatformTextMaskService:getBlockedSignatureText()
	local text = pg and pg.getGameString and pg.getGameString(PlatformTextMaskService.NO_PLAYER_SIGNATURE_KEY) or ""

	if string.isNilOrEmpty(text) or text == PlatformTextMaskService.NO_PLAYER_SIGNATURE_KEY then
		return ""
	end

	return text
end

function PlatformTextMaskService:checkTextVisibilityNow(options)
	if type(options) ~= "table" then
		local Decision = PlatformTextCommunicationService.Decision or {
			Allow = "allow"
		}

		return Decision.Allow, true, nil, PlatformTextMaskService.makeContext(Decision.Allow, true, "invalid_options")
	end

	return PlatformTextMaskService.evaluateVisibility(options.uid, options.playerInfo, options.action)
end

function PlatformTextMaskService:bindText(options)
	if type(options) ~= "table" then
		return ""
	end

	local requestId = PlatformTextMaskService.nextRequestId(options)
	local rawText = options.rawText or ""
	local hiddenText = options.hiddenText

	if hiddenText == nil then
		hiddenText = self:getBlockedContentText()
	end

	local pendingText = options.pendingText

	if pendingText == nil then
		pendingText = rawText
	end

	local rawApply = options.apply

	function PlatformTextMaskService.applyDisplay(displayText, isVisible, playerInfo, context)
		if not PlatformTextMaskService.isBindingAlive(options, requestId) then
			return
		end

		if type(rawApply) == "function" then
			rawApply(displayText, isVisible, playerInfo, context or {})
		end
	end

	local decision, visible, resolvedInfo, context = self:checkTextVisibilityNow(options)

	if decision ~= PlatformTextMaskService.PENDING_DECISION then
		local display = visible ~= false and rawText or hiddenText

		PlatformTextMaskService.applyDisplay(display, visible ~= false, resolvedInfo, context)

		return display
	end

	PlatformTextMaskService.applyDisplay(pendingText, nil, resolvedInfo or options.playerInfo, context)

	if PlatformUGCService and type(PlatformUGCService.resolveLocalPolicy) == "function" then
		PlatformUGCService:resolveLocalPolicy(function()
			local finalDecision, finalVisible, finalInfo, finalContext = self:checkTextVisibilityNow(options)
			local display = finalVisible ~= false and rawText or hiddenText

			PlatformTextMaskService.applyDisplay(display, finalDecision ~= PlatformTextMaskService.PENDING_DECISION and finalVisible ~= false or false, finalInfo, finalContext)
		end)
	end

	return pendingText
end

function PlatformTextMaskService:clearCache()
	return
end

return PlatformTextMaskService
