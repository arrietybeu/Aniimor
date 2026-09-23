-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformImageMaskService.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local PlatformTextCommunicationService = require("SDK.Platform.PlatformTextCommunicationService")
local PlatformUGCService = require("SDK.Platform.PlatformUGCService")
local PlatformSocialService = require("SDK.Platform.PlatformSocialService")
local logger = require("SDK.Platform.PlatformLogger")
local PlatformImageMaskService = {}

PlatformImageMaskService.PENDING_DECISION = "pending"

function PlatformImageMaskService.makeContext(decision, visible, reason)
	return {
		imageDecision = decision,
		imageVisible = visible ~= false,
		imageReason = reason or string.Empty
	}
end

function PlatformImageMaskService.getChatSystem()
	return pg and pg.game and pg.game.chat or nil
end

function PlatformImageMaskService.getCachedPlayerInfo(uid)
	local chatSystem = PlatformImageMaskService.getChatSystem()

	if string.isNilOrEmpty(uid) or not chatSystem or not chatSystem.getPlayerInfo then
		return nil
	end

	return chatSystem:getPlayerInfo(uid)
end

function PlatformImageMaskService.resolveSeedPlayerInfo(uid, playerInfo)
	if type(playerInfo) == "table" then
		return playerInfo
	end

	return PlatformImageMaskService.getCachedPlayerInfo(uid)
end

function PlatformImageMaskService.isLocalPlayer(uid, playerInfo)
	local localUid = pg and pg.me and pg.me.uid
	local localPlayerId = pg and pg.me and pg.me.id

	if localUid == nil and localPlayerId == nil then
		return false
	end

	function PlatformImageMaskService.matchesLocalId(value)
		if value == nil then
			return false
		end

		return localUid ~= nil and tostring(value) == tostring(localUid) or localPlayerId ~= nil and tostring(value) == tostring(localPlayerId)
	end

	if PlatformImageMaskService.matchesLocalId(uid) then
		return true
	end

	return type(playerInfo) == "table" and (PlatformImageMaskService.matchesLocalId(playerInfo.uid) or PlatformImageMaskService.matchesLocalId(playerInfo.playerId))
end

function PlatformImageMaskService.peekPlatformBlocked(playerInfo)
	if type(PlatformSocialService.peekPlatformUserBlockedByLocalUser) ~= "function" then
		return false
	end

	return PlatformSocialService:peekPlatformUserBlockedByLocalUser(playerInfo)
end

function PlatformImageMaskService.peekIsPlatformFriend(playerInfo)
	if type(playerInfo) == "table" and playerInfo.isPlatformFriend == true then
		return true
	end

	if type(PlatformSocialService.peekIsPlatformFriend) == "function" then
		return PlatformSocialService:peekIsPlatformFriend(playerInfo)
	end

	return false
end

function PlatformImageMaskService.evaluateVisibility(uid, playerInfo, action)
	local resolvedPlayerInfo = PlatformImageMaskService.resolveSeedPlayerInfo(uid, playerInfo)
	local Decision = PlatformTextCommunicationService.Decision or {
		Allow = "allow",
		Deny = "deny"
	}

	if PlatformImageMaskService.isLocalPlayer(uid, resolvedPlayerInfo) then
		return Decision.Allow, true, resolvedPlayerInfo, PlatformImageMaskService.makeContext(Decision.Allow, true, "local_player")
	end

	local blocked = PlatformImageMaskService.peekPlatformBlocked(resolvedPlayerInfo)

	if blocked == true then
		return Decision.Deny, false, resolvedPlayerInfo, PlatformImageMaskService.makeContext(Decision.Deny, false, "platform_user_blocked")
	elseif blocked == nil then
		logger:error("image_mask platform block list cache missing; allow by default")
	end

	local policy = PlatformUGCService and type(PlatformUGCService.peekLocalPolicy) == "function" and PlatformUGCService:peekLocalPolicy() or nil
	local Policy = PlatformUGCService and PlatformUGCService.LocalPolicy or {}

	if policy == nil then
		return PlatformImageMaskService.PENDING_DECISION, nil, resolvedPlayerInfo, PlatformImageMaskService.makeContext(PlatformImageMaskService.PENDING_DECISION, true, "local_ugc_policy_pending")
	end

	if policy == Policy.Blocked or policy == "blocked" or policy == "deny" then
		return Decision.Deny, false, resolvedPlayerInfo, PlatformImageMaskService.makeContext(Decision.Deny, false, "local_ugc_privacy_blocked")
	end

	if policy == Policy.FriendsOnly or policy == "friends_only" then
		local isFriend = PlatformImageMaskService.peekIsPlatformFriend(resolvedPlayerInfo)

		if isFriend == nil then
			logger:error("image_mask platform friend cache missing; allow by default")

			return Decision.Allow, true, resolvedPlayerInfo, PlatformImageMaskService.makeContext(Decision.Allow, true, "platform_friend_cache_missing")
		end

		local visible = isFriend == true
		local decision = visible and Decision.Allow or Decision.Deny

		if visible and PlatformUGCService and type(PlatformUGCService.resolveTargetVisibleDecision) == "function" then
			local targetVisible, targetContext = PlatformUGCService:resolveTargetVisibleDecision(resolvedPlayerInfo, "local_ugc_privacy_friends_only")
			local targetDecision = targetVisible and Decision.Allow or Decision.Deny

			return targetDecision, targetVisible, resolvedPlayerInfo, PlatformImageMaskService.makeContext(targetDecision, targetVisible, targetContext and targetContext.ugcReason or "local_ugc_privacy_friends_only")
		end

		return decision, visible, resolvedPlayerInfo, PlatformImageMaskService.makeContext(decision, visible, "local_ugc_privacy_friends_only")
	end

	local reason = (policy == Policy.Fallback or policy == "fallback") and "local_ugc_privacy_fallback" or "local_ugc_privacy_allow"

	if PlatformUGCService and type(PlatformUGCService.resolveTargetVisibleDecision) == "function" then
		local targetVisible, targetContext = PlatformUGCService:resolveTargetVisibleDecision(resolvedPlayerInfo, reason)
		local decision = targetVisible and Decision.Allow or Decision.Deny

		return decision, targetVisible, resolvedPlayerInfo, PlatformImageMaskService.makeContext(decision, targetVisible, targetContext and targetContext.ugcReason or reason)
	end

	return Decision.Allow, true, resolvedPlayerInfo, PlatformImageMaskService.makeContext(Decision.Allow, true, reason)
end

function PlatformImageMaskService.isRequestGuardEnabled(options)
	return type(options.requestState) == "table" and options.requestKey ~= nil
end

function PlatformImageMaskService.nextRequestId(options)
	if not PlatformImageMaskService.isRequestGuardEnabled(options) then
		return nil
	end

	local requestId = (options.requestState[options.requestKey] or 0) + 1

	options.requestState[options.requestKey] = requestId

	return requestId
end

function PlatformImageMaskService.isBindingAlive(options, requestId)
	if type(options.isAlive) == "function" and options.isAlive() == false then
		return false
	end

	if requestId ~= nil and options.requestState[options.requestKey] ~= requestId then
		return false
	end

	return true
end

function PlatformImageMaskService:checkImageVisibilityNow(options)
	if type(options) ~= "table" then
		local Decision = PlatformTextCommunicationService.Decision or {
			Allow = "allow"
		}

		return Decision.Allow, true, nil, PlatformImageMaskService.makeContext(Decision.Allow, true, "invalid_options")
	end

	return PlatformImageMaskService.evaluateVisibility(options.uid, options.playerInfo, options.action)
end

function PlatformImageMaskService:resolveImageVisibility(options, onResolved)
	if type(options) ~= "table" then
		if type(onResolved) == "function" then
			onResolved(true, nil, PlatformImageMaskService.makeContext((PlatformTextCommunicationService.Decision or EMPTY_TABLE).Allow or "allow", true, "invalid_options"))
		end

		return false
	end

	local decision, visible, resolvedInfo, context = self:checkImageVisibilityNow(options)

	if decision ~= PlatformImageMaskService.PENDING_DECISION then
		if type(onResolved) == "function" then
			onResolved(visible ~= false, resolvedInfo, context or {})
		end

		return false
	end

	if PlatformUGCService and type(PlatformUGCService.resolveLocalPolicy) == "function" then
		PlatformUGCService:resolveLocalPolicy(function()
			local _, finalVisible, finalInfo, finalContext = self:checkImageVisibilityNow(options)

			if type(onResolved) == "function" then
				onResolved(finalVisible ~= false, finalInfo, finalContext or {})
			end
		end)

		return true
	end

	if type(onResolved) == "function" then
		onResolved(false, resolvedInfo, context or {})
	end

	return false
end

function PlatformImageMaskService.applyVisible(options, requestId, rawApply, onBlocked, isVisible, playerInfo, context)
	if not PlatformImageMaskService.isBindingAlive(options, requestId) then
		return
	end

	local visible = isVisible == true

	if not visible and type(onBlocked) == "function" then
		onBlocked(playerInfo, context or {})
	elseif type(rawApply) == "function" then
		rawApply(visible, playerInfo, context or {})
	end
end

function PlatformImageMaskService:bindImage(options)
	if type(options) ~= "table" then
		return false
	end

	local rawApply = options.apply
	local onBlocked = options.onBlocked

	if type(rawApply) ~= "function" and type(onBlocked) ~= "function" then
		return false
	end

	local requestId = PlatformImageMaskService.nextRequestId(options)
	local pendingVisible = options.pendingVisible

	if pendingVisible == nil then
		pendingVisible = true
	end

	local decision, visible, resolvedInfo, context = self:checkImageVisibilityNow(options)

	if decision ~= PlatformImageMaskService.PENDING_DECISION then
		local vis = visible ~= false

		PlatformImageMaskService.applyVisible(options, requestId, rawApply, onBlocked, vis, resolvedInfo, context)

		return vis
	end

	PlatformImageMaskService.applyVisible(options, requestId, rawApply, onBlocked, pendingVisible == true, resolvedInfo or options.playerInfo, context)

	if PlatformUGCService and type(PlatformUGCService.resolveLocalPolicy) == "function" then
		PlatformUGCService:resolveLocalPolicy(function()
			local finalDecision, finalVisible, finalInfo, finalContext = self:checkImageVisibilityNow(options)

			PlatformImageMaskService.applyVisible(options, requestId, rawApply, onBlocked, finalDecision ~= PlatformImageMaskService.PENDING_DECISION and finalVisible ~= false, finalInfo, finalContext)
		end)
	end

	return pendingVisible == true
end

function PlatformImageMaskService:clearCache()
	return
end

return PlatformImageMaskService
