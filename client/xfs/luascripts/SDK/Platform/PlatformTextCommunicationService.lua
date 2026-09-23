-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformTextCommunicationService.lua

local logger = require("SDK.Platform.PlatformLogger")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformCommunicationService = require("SDK.Platform.PlatformCommunicationService")
local PlatformUGCService = require("SDK.Platform.PlatformUGCService")
local PlatformNoticeUtils = require("SDK.Platform.PlatformNoticeUtils")
local Time = require("Core.Common.Time")
local EventConst = require("Common.Const.EventConst")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local PlatformTextCommunicationService = {}

PlatformTextCommunicationService.PERMISSION_NAME = {
	LocalPrivacyText = "LocalCommunicatePrivacyText",
	Text = "CommunicateUsingText",
	LocalPrivacyVoice = "LocalCommunicatePrivacyVoice",
	Voice = "CommunicateUsingVoice"
}
PlatformTextCommunicationService.TIP_DEDUPE_INTERVAL = 1
PlatformTextCommunicationService.TIP_KEY_ALIAS = {
	PLATFORM_SOCIAL_UGC_PRIVILEGE_DENIED = "PRIVACY_SETTING_MISSMATCH"
}
PlatformTextCommunicationService.state = {
	lastTipTime = 0,
	lastTipReason = "",
	lastTipKey = "",
	localPrivilegeGeneration = 0,
	pendingCallbacksByPermission = {},
	pendingPrivilegeCallbacks = {},
	pendingLocalCommunicatePrivacyCallbacks = {},
	localPrivilegesByPermission = {},
	localPrivilegePendingByPermission = {}
}
PlatformTextCommunicationService.Decision = {
	Deny = "deny",
	Unknown = "unknown",
	Allow = "allow",
	Fallback = "fallback"
}
PlatformTextCommunicationService.LocalUserGeneratedContentPrivacy = {
	Fallback = "fallback",
	FriendsOnly = "friends_only",
	Allow = "allow",
	Blocked = "blocked"
}
PlatformTextCommunicationService.PermissionName = PlatformTextCommunicationService.PERMISSION_NAME

function PlatformTextCommunicationService.getNow()
	return Time and Time.secondCache or os.time()
end

function PlatformTextCommunicationService.isBridgeSupported()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.IsSupported and PlatformBridgeLuaFacade.IsSupported() == true
end

function PlatformTextCommunicationService.supportsPermission(permissionName)
	return PlatformCommunicationService:supportsPermission(permissionName)
end

function PlatformTextCommunicationService.supportsLocalCommunicatePrivacy(permissionName)
	return PlatformCommunicationService:supportsLocalCommunicatePrivacy(permissionName)
end

function PlatformTextCommunicationService.resolveTargetFamily(playerInfo)
	local family = PlatformIdentityUtils.resolvePlayerInfoFamily(playerInfo)

	if string.isNilOrEmpty(family) then
		return PlatformIdentityUtils.UnknownFamily
	end

	return tostring(family)
end

function PlatformTextCommunicationService.resolveTargetInfo(playerInfo)
	local currentFamily = PlatformIdentityUtils.getCurrentPlatformFamily()
	local targetFamily = PlatformTextCommunicationService.resolveTargetFamily(playerInfo)
	local targetUserId = PlatformIdentityUtils.resolvePlatformUserId(playerInfo)
	local hasPlatformUserId = not string.isNilOrEmpty(targetUserId)
	local sameFamilyConfirmed = hasPlatformUserId and PlatformIdentityUtils.isConsoleFamily(currentFamily) and targetFamily ~= PlatformIdentityUtils.UnknownFamily and targetFamily == currentFamily

	return {
		currentFamily = tostring(currentFamily or PlatformIdentityUtils.UnknownFamily),
		targetFamily = targetFamily,
		targetUserId = targetUserId,
		hasPlatformUserId = hasPlatformUserId,
		sameFamilyConfirmed = sameFamilyConfirmed
	}
end

function PlatformTextCommunicationService.getTipText(key)
	key = PlatformTextCommunicationService.TIP_KEY_ALIAS[key] or key

	return PlatformNoticeUtils.getText(key)
end

function PlatformTextCommunicationService.maybeShowTip(tipKey, reason, notifyUser)
	if notifyUser ~= true or string.isNilOrEmpty(tipKey) then
		return
	end

	local now = PlatformTextCommunicationService.getNow()

	if PlatformTextCommunicationService.state.lastTipKey == tipKey and PlatformTextCommunicationService.state.lastTipReason == tostring(reason or "") and now - PlatformTextCommunicationService.state.lastTipTime < PlatformTextCommunicationService.TIP_DEDUPE_INTERVAL then
		return
	end

	local content = PlatformTextCommunicationService.getTipText(tipKey)

	if string.isNilOrEmpty(content) then
		return
	end

	PlatformTextCommunicationService.state.lastTipKey = tipKey
	PlatformTextCommunicationService.state.lastTipReason = tostring(reason or "")
	PlatformTextCommunicationService.state.lastTipTime = now

	if pg and pg.global and pg.global.ui and pg.global.ui.tips then
		pg.global.ui.tips:showTextTip(content)
	end
end

function PlatformTextCommunicationService.logPermissionEvent(level, action, targetInfo, permissionName, reason, notifyUser, decision)
	local logFunc = level == "debug" and logger.debug or logger.warn
	local format = "platform_permission action=%s currentFamily=%s targetFamily=%s hasPlatformUserId=%s"
	local args = {
		tostring(action or ""),
		tostring(targetInfo and targetInfo.currentFamily or PlatformIdentityUtils.UnknownFamily),
		tostring(targetInfo and targetInfo.targetFamily or PlatformIdentityUtils.UnknownFamily),
		tostring(targetInfo and targetInfo.hasPlatformUserId == true)
	}

	if decision == PlatformTextCommunicationService.Decision.Fallback then
		format = format .. " sameFamilyConfirmed=%s permission=%s decision=fallback reason=%s notifyUser=%s"

		table.insert(args, tostring(targetInfo and targetInfo.sameFamilyConfirmed == true))
	else
		format = format .. " permission=%s reason=%s notifyUser=%s"
	end

	table.insert(args, tostring(permissionName or ""))
	table.insert(args, tostring(reason or ""))
	table.insert(args, tostring(notifyUser == true))
	logFunc(logger, format, unpack(args))
end

function PlatformTextCommunicationService.getUnavailableTipKey(options)
	if options and not string.isNilOrEmpty(options.unavailableTipKey) then
		return options.unavailableTipKey
	end

	return "PRIVACY_SETTING_MISSMATCH"
end

function PlatformTextCommunicationService.dispatchPrivilegeCheck(permissionName, callback)
	PlatformCommunicationService:dispatchPrivilegeCheck(permissionName, callback)
end

local function clonePrivilegePolicy(policy)
	if type(policy) ~= "table" then
		return policy
	end

	local copy = {}

	for key, value in pairs(policy) do
		copy[key] = value
	end

	return copy
end

local function isSamePrivilegePolicy(a, b)
	if a == nil or b == nil then
		return a == b
	end

	return a.decision == b.decision and a.allowed == b.allowed and a.result == b.result and a.reason == b.reason
end

local function completeLocalCommunicationPrivilege(permissionName, generation, policy)
	if generation ~= PlatformTextCommunicationService.state.localPrivilegeGeneration then
		return
	end

	local oldPolicy = PlatformTextCommunicationService.state.localPrivilegesByPermission[permissionName]

	PlatformTextCommunicationService.state.localPrivilegesByPermission[permissionName] = policy

	local callbacks = PlatformTextCommunicationService.state.localPrivilegePendingByPermission[permissionName] or {}

	PlatformTextCommunicationService.state.localPrivilegePendingByPermission[permissionName] = nil

	for _, callback in ipairs(callbacks) do
		callback(policy.decision, clonePrivilegePolicy(policy))
	end

	if not isSamePrivilegePolicy(oldPolicy, policy) and pg and pg.global and pg.global.eventEmitter and EventConst and EventConst.PLATFORM_LOCAL_COMMUNICATION_POLICY_CHANGED then
		pg.global.eventEmitter:emit(EventConst.PLATFORM_LOCAL_COMMUNICATION_POLICY_CHANGED, {
			permissionName = permissionName,
			oldPrivilege = clonePrivilegePolicy(oldPolicy),
			newPrivilege = clonePrivilegePolicy(policy)
		})
	end
end

function PlatformTextCommunicationService:peekLocalCommunicationPrivilege(permissionName)
	if not PlatformTextCommunicationService.isBridgeSupported() or not PlatformTextCommunicationService.supportsPermission(permissionName) then
		return self.Decision.Fallback
	end

	local policy = PlatformTextCommunicationService.state.localPrivilegesByPermission[permissionName]

	return policy and policy.decision or nil
end

function PlatformTextCommunicationService:prefetchLocalCommunicationPrivilege(permissionName, onResolved)
	if not PlatformTextCommunicationService.isBridgeSupported() or not PlatformTextCommunicationService.supportsPermission(permissionName) then
		if type(onResolved) == "function" then
			onResolved(self.Decision.Fallback)
		end

		return false
	end

	local cached = PlatformTextCommunicationService.state.localPrivilegesByPermission[permissionName]

	if cached then
		if type(onResolved) == "function" then
			onResolved(cached.decision, clonePrivilegePolicy(cached))
		end

		return false
	end

	local pending = PlatformTextCommunicationService.state.localPrivilegePendingByPermission[permissionName]

	if pending then
		if type(onResolved) == "function" then
			table.insert(pending, onResolved)
		end

		return true
	end

	PlatformTextCommunicationService.state.localPrivilegePendingByPermission[permissionName] = {}

	if type(onResolved) == "function" then
		table.insert(PlatformTextCommunicationService.state.localPrivilegePendingByPermission[permissionName], onResolved)
	end

	local generation = PlatformTextCommunicationService.state.localPrivilegeGeneration

	PlatformTextCommunicationService.dispatchPrivilegeCheck(permissionName, function(allowed, result, reason)
		local decision = PlatformTextCommunicationService.Decision.Unknown

		if result == 0 then
			decision = allowed == true and PlatformTextCommunicationService.Decision.Allow or PlatformTextCommunicationService.Decision.Deny
		end

		completeLocalCommunicationPrivilege(permissionName, generation, {
			decision = decision,
			allowed = allowed == true,
			result = result,
			reason = reason,
			updatedAt = PlatformTextCommunicationService.getNow()
		})
	end)

	return true
end

function PlatformTextCommunicationService:peekLocalTextCommunicationPrivilege()
	return self:peekLocalCommunicationPrivilege(PlatformTextCommunicationService.PERMISSION_NAME.Text)
end

function PlatformTextCommunicationService:prefetchLocalTextCommunicationPrivilege(onResolved)
	return self:prefetchLocalCommunicationPrivilege(PlatformTextCommunicationService.PERMISSION_NAME.Text, onResolved)
end

function PlatformTextCommunicationService.dispatchLocalCommunicatePrivacyCheck(permissionName, callback)
	PlatformCommunicationService:dispatchLocalCommunicatePrivacyCheck(permissionName, callback)
end

function PlatformTextCommunicationService:peekPermission(permissionName, playerInfo)
	if type(playerInfo) ~= "table" then
		return self.Decision.Fallback
	end

	if not PlatformTextCommunicationService.isBridgeSupported() or not PlatformTextCommunicationService.supportsPermission(permissionName) then
		return self.Decision.Fallback
	end

	local targetInfo = PlatformTextCommunicationService.resolveTargetInfo(playerInfo)

	if not targetInfo.sameFamilyConfirmed then
		return self.Decision.Fallback
	end

	return nil
end

function PlatformTextCommunicationService:peekTextPermission(playerInfo)
	return self:peekPermission(PlatformTextCommunicationService.PERMISSION_NAME.Text, playerInfo)
end

function PlatformTextCommunicationService:peekVoicePermission(playerInfo)
	return self:peekPermission(PlatformTextCommunicationService.PERMISSION_NAME.Voice, playerInfo)
end

function PlatformTextCommunicationService:peekLocalTextCommunicationPermission()
	if not PlatformTextCommunicationService.isBridgeSupported() or not PlatformTextCommunicationService.supportsPermission(PlatformTextCommunicationService.PERMISSION_NAME.Text) and not PlatformTextCommunicationService.supportsLocalCommunicatePrivacy(PlatformTextCommunicationService.PERMISSION_NAME.LocalPrivacyText) then
		return self.Decision.Fallback
	end

	return nil
end

function PlatformTextCommunicationService:resolveLocalUserGeneratedContentPrivacy(onResolved)
	return PlatformUGCService:resolveLocalPolicy(onResolved)
end

function PlatformTextCommunicationService:resolveLocalTextCommunicationPermission(onResolved)
	if type(onResolved) ~= "function" then
		return false
	end

	local supportsTextPrivilege = PlatformTextCommunicationService.isBridgeSupported() and PlatformTextCommunicationService.supportsPermission(PlatformTextCommunicationService.PERMISSION_NAME.Text)
	local supportsTextPrivacy = PlatformTextCommunicationService.isBridgeSupported() and PlatformTextCommunicationService.supportsLocalCommunicatePrivacy(PlatformTextCommunicationService.PERMISSION_NAME.LocalPrivacyText)

	if not supportsTextPrivilege and not supportsTextPrivacy then
		onResolved(true)

		return false
	end

	function PlatformTextCommunicationService.resolvePrivacy()
		if not supportsTextPrivacy then
			onResolved(true)

			return
		end

		PlatformTextCommunicationService.dispatchLocalCommunicatePrivacyCheck(PlatformTextCommunicationService.PERMISSION_NAME.LocalPrivacyText, function(allowed)
			onResolved(allowed == true)
		end)
	end

	if supportsTextPrivilege then
		PlatformTextCommunicationService.dispatchPrivilegeCheck(PlatformTextCommunicationService.PERMISSION_NAME.Text, function(allowed)
			if allowed ~= true then
				onResolved(false)

				return
			end

			PlatformTextCommunicationService.resolvePrivacy()
		end)
	else
		PlatformTextCommunicationService.resolvePrivacy()
	end

	return true
end

function PlatformTextCommunicationService:isLocalTextCommunicationDenied()
	if not PlatformTextCommunicationService.isBridgeSupported() then
		return false
	end

	return PlatformCommunicationService:isLocalCommunicationBlocked(PlatformCommunicationService.Channel.Text)
end

function PlatformTextCommunicationService:isLocalVoiceCommunicationDenied()
	if not PlatformTextCommunicationService.isBridgeSupported() then
		return false
	end

	return PlatformCommunicationService:isLocalCommunicationBlocked(PlatformCommunicationService.Channel.Voice)
end

function PlatformTextCommunicationService:prefetchLocalCommunicationPrivileges()
	if not PlatformTextCommunicationService.isBridgeSupported() then
		return
	end

	if not PlatformIdentityUtils.isConsoleFamily(PlatformIdentityUtils.getCurrentPlatformFamily()) then
		return
	end

	if PlatformTextCommunicationService.supportsPermission(PlatformTextCommunicationService.PERMISSION_NAME.Text) then
		self:prefetchLocalCommunicationPrivilege(PlatformTextCommunicationService.PERMISSION_NAME.Text)
	end

	if PlatformTextCommunicationService.supportsPermission(PlatformTextCommunicationService.PERMISSION_NAME.Voice) then
		self:prefetchLocalCommunicationPrivilege(PlatformTextCommunicationService.PERMISSION_NAME.Voice)
	end
end

function PlatformTextCommunicationService:clearPermissionCache(options)
	options = options or {}
	PlatformTextCommunicationService.state.pendingCallbacksByPermission = {}
	PlatformTextCommunicationService.state.pendingPrivilegeCallbacks = {}
	PlatformTextCommunicationService.state.pendingLocalCommunicatePrivacyCallbacks = {}

	PlatformCommunicationService:clearPrivilegeRequests()

	PlatformTextCommunicationService.state.localPrivilegeGeneration = PlatformTextCommunicationService.state.localPrivilegeGeneration + 1
	PlatformTextCommunicationService.state.localPrivilegesByPermission = {}
	PlatformTextCommunicationService.state.localPrivilegePendingByPermission = {}

	if options.clearUGCService ~= false then
		PlatformUGCService:clearCache()
	end
end

return PlatformTextCommunicationService
