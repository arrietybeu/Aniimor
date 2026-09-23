-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformCommunicationService.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformNoticeUtils = require("SDK.Platform.PlatformNoticeUtils")
local NoticeDef = require("Common.NoticeDef")
local logger = require("SDK.Platform.PlatformLogger")
local EventConst = require("Common.Const.EventConst")
local PlatformBridgeLuaFacade = CS and CS.FunPlus and CS.FunPlus.WorldX and CS.FunPlus.WorldX.SDK and CS.FunPlus.WorldX.SDK.Platform and CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade or nil
local PlatformCommunicationService = {}

PlatformCommunicationService.Channel = {
	Voice = "voice",
	Text = "text"
}
PlatformCommunicationService.Decision = {
	Deny = "deny",
	Unknown = "unknown",
	Allow = "allow",
	Fallback = "fallback"
}
PlatformCommunicationService.AudiencePolicy = {
	Everyone = "everyone",
	Fallback = "fallback",
	Blocked = "blocked",
	Unknown = "unknown",
	FriendsOnly = "friends_only"
}
PlatformCommunicationService.CommunicationSetting = {
	Friends = "friends",
	Anyone = "anyone",
	Fallback = "fallback",
	Blocked = "blocked",
	Unknown = "unknown"
}
PlatformCommunicationService.PermissionName = {
	LocalPrivacyText = "LocalCommunicatePrivacyText",
	Voice = "CommunicateUsingVoice",
	LocalPrivacyVoice = "LocalCommunicatePrivacyVoice",
	Text = "CommunicateUsingText"
}
PlatformCommunicationService.Reason = {
	CheckPending = "check_pending",
	CrossNetworkEveryone = "cross_network_everyone",
	PlatformUnsupported = "platform_unsupported",
	CrossNetworkFriendsOnly = "cross_network_friends_only",
	BridgeUnsupported = "bridge_unsupported",
	CrossNetworkBlocked = "cross_network_blocked",
	Allowed = "allowed",
	CrossNetworkUnknown = "cross_network_unknown"
}
PlatformCommunicationService.state = {
	lastTipReason = "",
	lastTipKey = "",
	privilegeRequestGeneration = 0,
	lastTipTime = 0,
	localSettingsByChannel = {},
	localSettingPendingByChannel = {},
	pendingCallbacksByPermission = {},
	pendingPrivilegeCallbacks = {},
	pendingLocalCommunicatePrivacyCallbacks = {}
}
PlatformCommunicationService.PermissionName = PlatformCommunicationService.PermissionName
PlatformCommunicationService.TIP_DEDUPE_INTERVAL = 1

function PlatformCommunicationService.getNow()
	local Time = package.loaded["Core.Common.Time"]

	return Time and Time.secondCache or os.time()
end

function PlatformCommunicationService.cloneTable(value)
	if type(value) ~= "table" then
		return value
	end

	local out = {}

	for k, v in pairs(value) do
		out[k] = v
	end

	return out
end

function PlatformCommunicationService.isSameSettingPolicy(a, b)
	if a == nil and b == nil then
		return true
	end

	if type(a) ~= "table" or type(b) ~= "table" then
		return false
	end

	return a.channel == b.channel and a.setting == b.setting and a.reason == b.reason and a.crossNetworkUserAllowed == b.crossNetworkUserAllowed and a.crossNetworkFriendAllowed == b.crossNetworkFriendAllowed and a.crossNetworkUserResult == b.crossNetworkUserResult and a.crossNetworkFriendResult == b.crossNetworkFriendResult and a.crossNetworkUserReason == b.crossNetworkUserReason and a.crossNetworkFriendReason == b.crossNetworkFriendReason
end

function PlatformCommunicationService.normalizeChannel(channel)
	if channel == PlatformCommunicationService.Channel.Voice then
		return PlatformCommunicationService.Channel.Voice
	end

	return PlatformCommunicationService.Channel.Text
end

function PlatformCommunicationService.getPrivacyPermissionName(channel, forFriend)
	channel = PlatformCommunicationService.normalizeChannel(channel)

	if channel == PlatformCommunicationService.Channel.Voice then
		return forFriend and PlatformCommunicationService.PermissionName.LocalPrivacyVoice .. ":friend" or PlatformCommunicationService.PermissionName.LocalPrivacyVoice
	end

	return forFriend and PlatformCommunicationService.PermissionName.LocalPrivacyText .. ":friend" or PlatformCommunicationService.PermissionName.LocalPrivacyText
end

function PlatformCommunicationService.isBridgeSupported()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.IsSupported and PlatformBridgeLuaFacade.IsSupported() == true
end

function PlatformCommunicationService.supportsConsoleCommunication()
	return PlatformIdentityUtils and PlatformIdentityUtils.isConsoleFamily and PlatformIdentityUtils.isConsoleFamily(PlatformIdentityUtils.getCurrentPlatformFamily()) == true
end

function PlatformCommunicationService.makeSetting(setting, reason, extra)
	local policy = {
		channel = extra and extra.channel,
		setting = setting,
		reason = reason,
		updatedAt = PlatformCommunicationService.getNow()
	}

	if type(extra) == "table" then
		for k, v in pairs(extra) do
			policy[k] = v
		end
	end

	return policy
end

function PlatformCommunicationService.makeChannelSetting(channel, setting, reason, extra)
	extra = extra or {}
	extra.channel = PlatformCommunicationService.normalizeChannel(channel)

	return PlatformCommunicationService.makeSetting(setting, reason, extra)
end

function PlatformCommunicationService.makeUnsupportedPlatformSetting(channel)
	return PlatformCommunicationService.makeChannelSetting(channel, PlatformCommunicationService.CommunicationSetting.Fallback, PlatformCommunicationService.Reason.PlatformUnsupported)
end

function PlatformCommunicationService.formatLocalCommunicationPolicyDiagnostics(policy)
	if type(policy) ~= "table" then
		return "policy=nil"
	end

	return string.format("setting=%s userAllowed=%s userResult=%s userReason=%s friendAllowed=%s friendResult=%s friendReason=%s", tostring(policy.setting), tostring(policy.crossNetworkUserAllowed), tostring(policy.crossNetworkUserResult), tostring(policy.crossNetworkUserReason), tostring(policy.crossNetworkFriendAllowed), tostring(policy.crossNetworkFriendResult), tostring(policy.crossNetworkFriendReason))
end

function PlatformCommunicationService.makeLegacyPolicy(settingPolicy)
	local setting = settingPolicy and settingPolicy.setting
	local reason = settingPolicy and settingPolicy.reason or PlatformCommunicationService.Reason.CheckPending
	local Decision = PlatformCommunicationService.Decision
	local AudiencePolicy = PlatformCommunicationService.AudiencePolicy
	local Setting = PlatformCommunicationService.CommunicationSetting
	local decision = Decision.Unknown
	local audiencePolicy = AudiencePolicy.Unknown

	if setting == Setting.Anyone then
		decision = Decision.Allow
		audiencePolicy = AudiencePolicy.Everyone
	elseif setting == Setting.Friends then
		decision = Decision.Allow
		audiencePolicy = AudiencePolicy.FriendsOnly
	elseif setting == Setting.Blocked then
		decision = Decision.Deny
		audiencePolicy = AudiencePolicy.Blocked
	elseif setting == Setting.Fallback then
		decision = Decision.Fallback
		audiencePolicy = AudiencePolicy.Fallback
	end

	local policy = {
		decision = decision,
		audiencePolicy = audiencePolicy,
		reason = reason,
		updatedAt = settingPolicy and settingPolicy.updatedAt or PlatformCommunicationService.getNow(),
		communicationSetting = setting
	}

	if type(settingPolicy) == "table" then
		for k, v in pairs(settingPolicy) do
			if policy[k] == nil then
				policy[k] = v
			end
		end
	end

	return policy
end

function PlatformCommunicationService.completeLocalSetting(channel, policy)
	channel = PlatformCommunicationService.normalizeChannel(channel)

	local baseline = PlatformCommunicationService.state.policyChangeBaselineByChannel
	local oldPolicy = baseline and baseline[channel] or PlatformCommunicationService.state.localSettingsByChannel[channel]

	if baseline then
		baseline[channel] = nil

		if next(baseline) == nil then
			PlatformCommunicationService.state.policyChangeBaselineByChannel = nil
		end
	end

	PlatformCommunicationService.state.localSettingsByChannel[channel] = policy

	local callbacks = PlatformCommunicationService.state.localSettingPendingByChannel[channel] or {}

	PlatformCommunicationService.state.localSettingPendingByChannel[channel] = nil

	for _, callback in ipairs(callbacks) do
		callback(PlatformCommunicationService.cloneTable(policy))
	end

	if not PlatformCommunicationService.isSameSettingPolicy(oldPolicy, policy) and pg and pg.global and pg.global.eventEmitter and EventConst and EventConst.PLATFORM_LOCAL_COMMUNICATION_POLICY_CHANGED then
		pg.global.eventEmitter:emit(EventConst.PLATFORM_LOCAL_COMMUNICATION_POLICY_CHANGED, {
			channel = channel,
			oldPolicy = oldPolicy and PlatformCommunicationService.makeLegacyPolicy(oldPolicy) or nil,
			newPolicy = PlatformCommunicationService.makeLegacyPolicy(policy),
			oldSetting = PlatformCommunicationService.cloneTable(oldPolicy),
			newSetting = PlatformCommunicationService.cloneTable(policy)
		})
	end
end

function PlatformCommunicationService.getPermissionBucket(container, permissionName)
	local bucket = container[permissionName]

	if not bucket then
		bucket = {}
		container[permissionName] = bucket
	end

	return bucket
end

function PlatformCommunicationService.dispatch(methodName, callback)
	local fn = PlatformBridgeLuaFacade and PlatformBridgeLuaFacade[methodName]

	if type(fn) ~= "function" then
		callback(false, -1, "method_unavailable:" .. methodName)

		return
	end

	fn(function(success, result, reason, payload)
		callback(success == true, result or 0, tostring(reason or ""), payload)
	end)
end

function PlatformCommunicationService.resolveLocalCommunicationSetting(userAllowed, friendAllowed)
	local Setting = PlatformCommunicationService.CommunicationSetting
	local Reason = PlatformCommunicationService.Reason

	if userAllowed == true then
		return Setting.Anyone, Reason.CrossNetworkEveryone
	end

	if friendAllowed == true then
		return Setting.Friends, Reason.CrossNetworkFriendsOnly
	end

	return Setting.Blocked, Reason.CrossNetworkBlocked
end

function PlatformCommunicationService.startLocalCommunicationSettingPrefetch(channel)
	channel = PlatformCommunicationService.normalizeChannel(channel)

	local Setting = PlatformCommunicationService.CommunicationSetting
	local Reason = PlatformCommunicationService.Reason
	local userPermissionName = PlatformCommunicationService.getPrivacyPermissionName(channel, false)
	local friendPermissionName = PlatformCommunicationService.getPrivacyPermissionName(channel, true)

	if not PlatformCommunicationService.isBridgeSupported() then
		PlatformCommunicationService.completeLocalSetting(channel, PlatformCommunicationService.makeChannelSetting(channel, Setting.Fallback, Reason.BridgeUnsupported))

		return
	end

	if not PlatformCommunicationService.supportsConsoleCommunication() then
		PlatformCommunicationService.completeLocalSetting(channel, PlatformCommunicationService.makeChannelSetting(channel, Setting.Fallback, Reason.PlatformUnsupported))

		return
	end

	if not PlatformCommunicationService:supportsLocalCommunicatePrivacy(userPermissionName) then
		PlatformCommunicationService.completeLocalSetting(channel, PlatformCommunicationService.makeChannelSetting(channel, Setting.Fallback, Reason.PlatformUnsupported))

		return
	end

	PlatformCommunicationService:dispatchLocalCommunicatePrivacyCheck(userPermissionName, function(userAllowed, userResult, userReason)
		PlatformCommunicationService:dispatchLocalCommunicatePrivacyCheck(friendPermissionName, function(friendAllowed, friendResult, friendReason)
			if userResult ~= 0 or friendResult ~= 0 then
				local policy = PlatformCommunicationService.makeChannelSetting(channel, Setting.Unknown, Reason.CrossNetworkUnknown, {
					crossNetworkUserAllowed = userAllowed,
					crossNetworkFriendAllowed = friendAllowed,
					crossNetworkUserResult = userResult,
					crossNetworkFriendResult = friendResult,
					crossNetworkUserReason = userReason,
					crossNetworkFriendReason = friendReason
				})

				logger:error("PlatformCommunicationService local communication policy check failed: channel=%s %s", tostring(channel), PlatformCommunicationService.formatLocalCommunicationPolicyDiagnostics(policy))
				PlatformCommunicationService.completeLocalSetting(channel, policy)

				return
			end

			local setting, reason = PlatformCommunicationService.resolveLocalCommunicationSetting(userAllowed, friendAllowed)

			PlatformCommunicationService.completeLocalSetting(channel, PlatformCommunicationService.makeChannelSetting(channel, setting, reason, {
				crossNetworkUserAllowed = userAllowed,
				crossNetworkFriendAllowed = friendAllowed,
				crossNetworkUserReason = userReason,
				crossNetworkFriendReason = friendReason
			}))
		end)
	end)
end

function PlatformCommunicationService.getTipText(key)
	return PlatformNoticeUtils.getText(key)
end

function PlatformCommunicationService.maybeShowTip(tipKey, reason, notifyUser)
	if notifyUser ~= true or tipKey == nil or tipKey == "" then
		return
	end

	local now = PlatformCommunicationService.getNow()
	local normalizedTipKey = tostring(tipKey)

	if PlatformCommunicationService.state.lastTipKey == normalizedTipKey and PlatformCommunicationService.state.lastTipReason == tostring(reason or "") and now - PlatformCommunicationService.state.lastTipTime < PlatformCommunicationService.TIP_DEDUPE_INTERVAL then
		return
	end

	local content = PlatformCommunicationService.getTipText(tipKey)

	if string.isNilOrEmpty(content) then
		return
	end

	PlatformCommunicationService.state.lastTipKey = normalizedTipKey
	PlatformCommunicationService.state.lastTipReason = tostring(reason or "")
	PlatformCommunicationService.state.lastTipTime = now

	if pg and pg.global and pg.global.ui and pg.global.ui.tips then
		pg.global.ui.tips:showTextTip(content)
	end
end

function PlatformCommunicationService:supportsPermission(permissionName)
	if not PlatformCommunicationService.supportsConsoleCommunication() then
		return false
	end

	if not PlatformBridgeLuaFacade then
		return false
	end

	if permissionName == PlatformCommunicationService.PermissionName.Text then
		return PlatformBridgeLuaFacade.SupportsTextCommunicationPermission and PlatformBridgeLuaFacade.SupportsTextCommunicationPermission() == true
	end

	if permissionName == PlatformCommunicationService.PermissionName.Voice then
		return PlatformBridgeLuaFacade.SupportsVoiceCommunicationPermission and PlatformBridgeLuaFacade.SupportsVoiceCommunicationPermission() == true
	end

	return false
end

function PlatformCommunicationService:supportsLocalCommunicatePrivacy(permissionName)
	if not PlatformCommunicationService.supportsConsoleCommunication() then
		return false
	end

	if permissionName ~= PlatformCommunicationService.PermissionName.LocalPrivacyText and permissionName ~= PlatformCommunicationService.PermissionName.LocalPrivacyVoice and permissionName ~= PlatformCommunicationService.PermissionName.LocalPrivacyText .. ":friend" and permissionName ~= PlatformCommunicationService.PermissionName.LocalPrivacyVoice .. ":friend" then
		return false
	end

	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.SupportsLocalCommunicatePrivacyCheck and PlatformBridgeLuaFacade.SupportsLocalCommunicatePrivacyCheck() == true
end

function PlatformCommunicationService:dispatchPrivilegeCheck(permissionName, callback)
	if not PlatformCommunicationService.supportsConsoleCommunication() then
		if type(callback) == "function" then
			callback(true, 0, self.Reason.PlatformUnsupported)
		end

		return
	end

	local pendingCallbacks = PlatformCommunicationService.state.pendingPrivilegeCallbacks[permissionName]

	if pendingCallbacks then
		table.insert(pendingCallbacks, callback)

		return
	end

	local callbacks = {
		callback
	}

	PlatformCommunicationService.state.pendingPrivilegeCallbacks[permissionName] = callbacks

	local generation = PlatformCommunicationService.state.privilegeRequestGeneration
	local methodName

	if permissionName == PlatformCommunicationService.PermissionName.Text then
		methodName = "CheckTextCommunicationPrivilege"
	elseif permissionName == PlatformCommunicationService.PermissionName.Voice then
		methodName = "CheckVoiceCommunicationPrivilege"
	end

	if not methodName then
		PlatformCommunicationService.state.pendingPrivilegeCallbacks[permissionName] = nil

		for _, pendingCallback in ipairs(callbacks) do
			pendingCallback(true, 0, string.Empty)
		end

		return
	end

	PlatformCommunicationService.dispatch(methodName, function(allowed, result, reason)
		if generation ~= PlatformCommunicationService.state.privilegeRequestGeneration or PlatformCommunicationService.state.pendingPrivilegeCallbacks[permissionName] ~= callbacks then
			return
		end

		PlatformCommunicationService.state.pendingPrivilegeCallbacks[permissionName] = nil

		for _, pendingCallback in ipairs(callbacks) do
			pendingCallback(allowed, result, reason)
		end
	end)
end

function PlatformCommunicationService:dispatchPermissionCheck(permissionName, targetUserId, callback)
	if not PlatformCommunicationService.supportsConsoleCommunication() then
		if type(callback) == "function" then
			callback(true, 0, self.Reason.PlatformUnsupported)
		end

		return
	end

	local requestBuckets = PlatformCommunicationService.state.pendingCallbacksByPermission
	local pendingBucket = PlatformCommunicationService.getPermissionBucket(requestBuckets, permissionName)
	local pendingCallbacks = pendingBucket[targetUserId]

	if pendingCallbacks then
		table.insert(pendingCallbacks, callback)

		return
	end

	local callbacks = {
		callback
	}
	local ownerUid = pg and pg.me and tostring(pg.me.uid) or ""

	pendingBucket[targetUserId] = callbacks

	local function complete(allowed, result, reason)
		if PlatformCommunicationService.state.pendingCallbacksByPermission ~= requestBuckets or requestBuckets[permissionName] ~= pendingBucket or pendingBucket[targetUserId] ~= callbacks or ownerUid ~= (pg and pg.me and tostring(pg.me.uid) or "") then
			return
		end

		pendingBucket[targetUserId] = nil

		for _, pendingCallback in ipairs(callbacks) do
			pendingCallback(allowed, result, reason)
		end
	end

	local methodName

	if permissionName == PlatformCommunicationService.PermissionName.Text then
		methodName = "CheckTextCommunicationPermission"
	elseif permissionName == PlatformCommunicationService.PermissionName.Voice then
		methodName = "CheckVoiceCommunicationPermission"
	end

	local fn = methodName and PlatformBridgeLuaFacade and PlatformBridgeLuaFacade[methodName]

	if type(fn) ~= "function" then
		complete(false, -1, "permission_check_not_supported")

		return
	end

	fn(targetUserId, complete)
end

function PlatformCommunicationService:invalidatePermissionRequests(permissionName, targetUserId)
	local buckets = PlatformCommunicationService.state.pendingCallbacksByPermission

	if permissionName == nil then
		PlatformCommunicationService.state.pendingCallbacksByPermission = {}
	elseif targetUserId == nil then
		buckets[permissionName] = nil
	elseif buckets[permissionName] then
		buckets[permissionName][targetUserId] = nil
	end
end

function PlatformCommunicationService:dispatchLocalCommunicatePrivacyCheck(permissionName, callback)
	if not PlatformCommunicationService.supportsConsoleCommunication() then
		if type(callback) == "function" then
			callback(true, 0, self.Reason.PlatformUnsupported)
		end

		return
	end

	local pendingCallbacks = PlatformCommunicationService.state.pendingLocalCommunicatePrivacyCallbacks[permissionName]

	if pendingCallbacks then
		table.insert(pendingCallbacks, callback)

		return
	end

	PlatformCommunicationService.state.pendingLocalCommunicatePrivacyCallbacks[permissionName] = {
		callback
	}

	local methodName

	if permissionName == PlatformCommunicationService.PermissionName.LocalPrivacyText then
		methodName = "CheckLocalTextCommunicatePrivacy"
	elseif permissionName == PlatformCommunicationService.PermissionName.LocalPrivacyVoice then
		methodName = "CheckLocalVoiceCommunicatePrivacy"
	elseif permissionName == PlatformCommunicationService.PermissionName.LocalPrivacyText .. ":friend" then
		methodName = "CheckLocalTextCommunicatePrivacyForCrossNetworkFriend"
	elseif permissionName == PlatformCommunicationService.PermissionName.LocalPrivacyVoice .. ":friend" then
		methodName = "CheckLocalVoiceCommunicatePrivacyForCrossNetworkFriend"
	end

	if not methodName then
		local callbacks = PlatformCommunicationService.state.pendingLocalCommunicatePrivacyCallbacks[permissionName] or {}

		PlatformCommunicationService.state.pendingLocalCommunicatePrivacyCallbacks[permissionName] = nil

		for _, pendingCallback in ipairs(callbacks) do
			pendingCallback(true, 0, string.Empty)
		end

		return
	end

	PlatformCommunicationService.dispatch(methodName, function(allowed, result, reason)
		local callbacks = PlatformCommunicationService.state.pendingLocalCommunicatePrivacyCallbacks[permissionName] or {}

		PlatformCommunicationService.state.pendingLocalCommunicatePrivacyCallbacks[permissionName] = nil

		for _, pendingCallback in ipairs(callbacks) do
			pendingCallback(allowed, result, reason)
		end
	end)
end

function PlatformCommunicationService:prefetchLocalCommunicationSetting(channel, onResolved)
	if type(channel) == "function" then
		onResolved = channel
		channel = nil
	end

	channel = PlatformCommunicationService.normalizeChannel(channel)

	if PlatformCommunicationService.state.localSettingsByChannel[channel] then
		if type(onResolved) == "function" then
			onResolved(PlatformCommunicationService.cloneTable(PlatformCommunicationService.state.localSettingsByChannel[channel]))
		end

		return false
	end

	if PlatformCommunicationService.state.localSettingPendingByChannel[channel] then
		if type(onResolved) == "function" then
			table.insert(PlatformCommunicationService.state.localSettingPendingByChannel[channel], onResolved)
		end

		return true
	end

	PlatformCommunicationService.state.localSettingPendingByChannel[channel] = {}

	if type(onResolved) == "function" then
		table.insert(PlatformCommunicationService.state.localSettingPendingByChannel[channel], onResolved)
	end

	PlatformCommunicationService.startLocalCommunicationSettingPrefetch(channel)

	return true
end

function PlatformCommunicationService:peekLocalCommunicationSetting(channel)
	channel = PlatformCommunicationService.normalizeChannel(channel)

	if not PlatformCommunicationService.supportsConsoleCommunication() then
		return PlatformCommunicationService.makeUnsupportedPlatformSetting(channel)
	end

	if PlatformCommunicationService.state.localSettingsByChannel[channel] then
		return PlatformCommunicationService.cloneTable(PlatformCommunicationService.state.localSettingsByChannel[channel])
	end

	return PlatformCommunicationService.makeChannelSetting(channel, self.CommunicationSetting.Unknown, self.Reason.CheckPending)
end

function PlatformCommunicationService:refreshLocalCommunicationSetting(channel, onResolved)
	if type(channel) == "function" then
		onResolved = channel
		channel = nil
	end

	channel = PlatformCommunicationService.normalizeChannel(channel)

	if not PlatformCommunicationService.supportsConsoleCommunication() then
		if type(onResolved) == "function" then
			onResolved(PlatformCommunicationService.makeUnsupportedPlatformSetting(channel))
		end

		return false
	end

	if PlatformCommunicationService.state.localSettingPendingByChannel[channel] then
		if type(onResolved) == "function" then
			table.insert(PlatformCommunicationService.state.localSettingPendingByChannel[channel], onResolved)
		end

		return true
	end

	PlatformCommunicationService.state.localSettingPendingByChannel[channel] = {}

	if type(onResolved) == "function" then
		table.insert(PlatformCommunicationService.state.localSettingPendingByChannel[channel], onResolved)
	end

	PlatformCommunicationService.startLocalCommunicationSettingPrefetch(channel)

	return true
end

function PlatformCommunicationService:prefetchLocalCommunicationPolicy(options, onResolved)
	if type(options) == "function" then
		onResolved = options
		options = nil
	end

	options = options or {}

	local channels = options.channel and {
		options.channel
	} or {
		self.Channel.Text,
		self.Channel.Voice
	}
	local remaining = #channels
	local results = {}

	if remaining == 0 then
		if type(onResolved) == "function" then
			onResolved(results)
		end

		return false
	end

	local started = false

	for _, rawChannel in ipairs(channels) do
		local channel = PlatformCommunicationService.normalizeChannel(rawChannel)
		local didStart = self:prefetchLocalCommunicationSetting(channel, function(settingPolicy)
			results[channel] = PlatformCommunicationService.makeLegacyPolicy(settingPolicy)
			remaining = remaining - 1

			if remaining == 0 and type(onResolved) == "function" then
				onResolved(results)
			end
		end)

		started = started or didStart
	end

	return started
end

function PlatformCommunicationService:peekLocalCommunicationPolicy(channel)
	return PlatformCommunicationService.makeLegacyPolicy(self:peekLocalCommunicationSetting(channel))
end

function PlatformCommunicationService:isLocalCommunicationAllowed(channel)
	if not PlatformCommunicationService.supportsConsoleCommunication() then
		return true
	end

	local policy = self:peekLocalCommunicationPolicy(channel)

	return policy and policy.decision == self.Decision.Allow
end

function PlatformCommunicationService:requireLocalCommunicationPolicy(channel)
	channel = PlatformCommunicationService.normalizeChannel(channel)

	if not PlatformCommunicationService.supportsConsoleCommunication() then
		return PlatformCommunicationService.makeUnsupportedPlatformSetting(channel)
	end

	local policy = PlatformCommunicationService.state.localSettingsByChannel[channel]

	if not policy then
		logger:error("PlatformCommunicationService local communication policy missing: channel=%s", tostring(channel))

		return nil
	end

	if policy.setting == self.CommunicationSetting.Unknown or policy.reason == self.Reason.CheckPending then
		logger:error("PlatformCommunicationService local communication policy not ready: channel=%s reason=%s %s", tostring(channel), tostring(policy.reason), PlatformCommunicationService.formatLocalCommunicationPolicyDiagnostics(policy))

		return nil
	end

	return PlatformCommunicationService.cloneTable(policy)
end

function PlatformCommunicationService:canSendOutgoingChat(channel, context)
	channel = PlatformCommunicationService.normalizeChannel(channel)
	context = context or {}

	if not PlatformCommunicationService.supportsConsoleCommunication() then
		local policy = PlatformCommunicationService.makeUnsupportedPlatformSetting(channel)

		return true, policy, policy.reason
	end

	local policy = self:requireLocalCommunicationPolicy(channel)

	if not policy then
		return false, nil, "local_communication_policy_unavailable"
	end

	local setting = policy.setting
	local Setting = self.CommunicationSetting

	if setting == Setting.Fallback then
		return true, policy, policy.reason or "fallback"
	end

	if context.isPrivate == true then
		if setting == Setting.Anyone then
			return true, policy, policy.reason or "allowed"
		end

		if setting == Setting.Friends then
			local isPlatformFriend = PlatformIdentityUtils and PlatformIdentityUtils.isPlatformFriend and PlatformIdentityUtils.isPlatformFriend(context.playerInfo) == true

			if isPlatformFriend then
				return true, policy, policy.reason or "platform_friend"
			end

			return false, policy, "local_communication_friends_only_target_not_platform_friend"
		end

		if setting == Setting.Blocked then
			return false, policy, "local_communication_blocked"
		end
	else
		if setting == Setting.Anyone or setting == Setting.Fallback then
			return true, policy, policy.reason or "allowed"
		end

		if setting == Setting.Friends then
			return false, policy, "local_communication_friends_only_public_channel"
		end

		if setting == Setting.Blocked then
			return false, policy, "local_communication_blocked"
		end
	end

	return false, policy, "local_communication_policy_invalid"
end

function PlatformCommunicationService:notifyOutgoingCommunicationDenied(channel, reason, options)
	options = options or {}
	channel = PlatformCommunicationService.normalizeChannel(channel)

	if not PlatformCommunicationService.supportsConsoleCommunication() then
		return
	end

	local tipKey = options.deniedTipKey

	if string.isNilOrEmpty(tipKey) then
		tipKey = NoticeDef.PRIVACY_SETTING_MISSMATCH
	end

	PlatformCommunicationService.maybeShowTip(tipKey, reason, options.notifyUser ~= false)
end

function PlatformCommunicationService:isLocalCommunicationBlocked(channel)
	if not PlatformCommunicationService.supportsConsoleCommunication() then
		return false
	end

	local policy = self:requireLocalCommunicationPolicy(channel)

	return policy ~= nil and policy.setting == self.CommunicationSetting.Blocked
end

function PlatformCommunicationService:clearPrivilegeRequests()
	PlatformCommunicationService.state.privilegeRequestGeneration = PlatformCommunicationService.state.privilegeRequestGeneration + 1
	PlatformCommunicationService.state.pendingPrivilegeCallbacks = {}
end

function PlatformCommunicationService:clearCache()
	PlatformCommunicationService.state.localSettingsByChannel = {}
	PlatformCommunicationService.state.localSettingPendingByChannel = {}
	PlatformCommunicationService.state.policyChangeBaselineByChannel = nil
	PlatformCommunicationService.state.pendingCallbacksByPermission = {}

	self:clearPrivilegeRequests()

	PlatformCommunicationService.state.pendingLocalCommunicatePrivacyCallbacks = {}
end

function PlatformCommunicationService:refreshLocalCommunicationPolicy(onResolved)
	if not PlatformCommunicationService.supportsConsoleCommunication() then
		local results = {}

		results[self.Channel.Text] = PlatformCommunicationService.makeLegacyPolicy(PlatformCommunicationService.makeUnsupportedPlatformSetting(self.Channel.Text))
		results[self.Channel.Voice] = PlatformCommunicationService.makeLegacyPolicy(PlatformCommunicationService.makeUnsupportedPlatformSetting(self.Channel.Voice))

		if type(onResolved) == "function" then
			onResolved(results)
		end

		return false
	end

	local previousSettings = {}

	for channel, policy in pairs(PlatformCommunicationService.state.localSettingsByChannel or EMPTY_TABLE) do
		previousSettings[channel] = PlatformCommunicationService.cloneTable(policy)
	end

	PlatformCommunicationService.state.policyChangeBaselineByChannel = previousSettings

	local channels = {
		self.Channel.Text,
		self.Channel.Voice
	}
	local remaining = #channels
	local results = {}

	for _, rawChannel in ipairs(channels) do
		local channel = PlatformCommunicationService.normalizeChannel(rawChannel)

		self:refreshLocalCommunicationSetting(channel, function(settingPolicy)
			results[channel] = PlatformCommunicationService.makeLegacyPolicy(settingPolicy)
			remaining = remaining - 1

			if remaining == 0 and type(onResolved) == "function" then
				onResolved(results)
			end
		end)
	end

	return true
end

function PlatformCommunicationService:getDebugSnapshot()
	local textSetting = PlatformCommunicationService.cloneTable(PlatformCommunicationService.state.localSettingsByChannel[self.Channel.Text])
	local voiceSetting = PlatformCommunicationService.cloneTable(PlatformCommunicationService.state.localSettingsByChannel[self.Channel.Voice])

	return {
		localCommunication = textSetting,
		text = textSetting and PlatformCommunicationService.makeLegacyPolicy(textSetting) or nil,
		voice = voiceSetting and PlatformCommunicationService.makeLegacyPolicy(voiceSetting) or nil
	}
end

return PlatformCommunicationService
