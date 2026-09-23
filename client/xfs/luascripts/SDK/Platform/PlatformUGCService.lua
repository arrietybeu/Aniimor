-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformUGCService.lua

local logger = require("SDK.Platform.PlatformLogger")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local EventConst = require("Common.Const.EventConst")
local PlatformBridgeLuaFacade = CS and CS.FunPlus and CS.FunPlus.WorldX and CS.FunPlus.WorldX.SDK and CS.FunPlus.WorldX.SDK.Platform and CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade or nil
local PlatformUGCService = {}

PlatformUGCService.LocalPolicy = {
	Allow = "allow",
	FriendsOnly = "friends_only",
	Fallback = "fallback",
	Blocked = "blocked"
}
PlatformUGCService.TargetSwitch = {
	Allow = 0,
	FriendOnly = 1,
	Blocked = 2
}
PlatformUGCService.Decision = {
	Deny = "deny",
	Fallback = "fallback",
	Pending = "pending",
	Allow = "allow"
}
PlatformUGCService.Reason = {
	TargetSwitchMissing = "target_ugc_switch_missing",
	TargetPermissionFallback = "target_ugc_permission_fallback",
	TargetSwitchUnknown = "target_ugc_switch_unknown",
	TargetPermissionDenied = "target_ugc_permission_denied"
}
PlatformUGCService.state = {
	deferredServerSyncVersion = 0,
	deferredServerSyncInFlight = false,
	deferredServerSyncPending = false,
	initialized = false
}

function PlatformUGCService.isBridgeSupported()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.IsSupported and PlatformBridgeLuaFacade.IsSupported() == true
end

function PlatformUGCService.isConsoleFamily()
	return PlatformIdentityUtils and PlatformIdentityUtils.isConsoleFamily and PlatformIdentityUtils.isConsoleFamily(PlatformIdentityUtils.getCurrentPlatformFamily()) == true
end

function PlatformUGCService.supportsLocalPolicyCheckInternal()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.SupportsLocalUserGeneratedContentPrivacyCheck and PlatformBridgeLuaFacade.SupportsLocalUserGeneratedContentPrivacyCheck() == true
end

function PlatformUGCService.supportsPrivilegeCheck()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.SupportsUserGeneratedContentPermission and PlatformBridgeLuaFacade.SupportsUserGeneratedContentPermission() == true
end

function PlatformUGCService.normalizeLocalPolicy(allowed, reason)
	local Policy = PlatformUGCService.LocalPolicy

	reason = tostring(reason or "")

	if reason == "local_ugc_privacy_allow" then
		return Policy.Allow
	end

	if reason == "local_ugc_privacy_friends_only" then
		return Policy.FriendsOnly
	end

	if reason == "local_ugc_privacy_blocked" then
		return Policy.Blocked
	end

	if reason == "local_ugc_privacy_fallback" then
		return Policy.Fallback
	end

	if allowed == true then
		return Policy.Allow
	end

	return Policy.Fallback
end

function PlatformUGCService.completeLocalPolicy(policy)
	PlatformUGCService.state.cachedLocalPolicy = policy or PlatformUGCService.LocalPolicy.Fallback

	local callbacks = PlatformUGCService.state.pendingLocalPolicyCallbacks or {}

	PlatformUGCService.state.pendingLocalPolicyCallbacks = nil

	for _, callback in ipairs(callbacks) do
		callback(PlatformUGCService.state.cachedLocalPolicy)
	end
end

function PlatformUGCService.addPendingLocalPolicyCallback(callback)
	if type(callback) ~= "function" then
		return
	end

	if not PlatformUGCService.state.pendingLocalPolicyCallbacks then
		PlatformUGCService.state.pendingLocalPolicyCallbacks = {}
	end

	table.insert(PlatformUGCService.state.pendingLocalPolicyCallbacks, callback)
end

function PlatformUGCService.completePrivilege(allowed)
	PlatformUGCService.state.cachedPrivilegeAllowed = allowed == true

	local callbacks = PlatformUGCService.state.pendingPrivilegeCallbacks or {}

	PlatformUGCService.state.pendingPrivilegeCallbacks = nil

	for _, callback in ipairs(callbacks) do
		callback(PlatformUGCService.state.cachedPrivilegeAllowed)
	end
end

function PlatformUGCService:supportsLocalPolicyCheck()
	return PlatformUGCService.isBridgeSupported() and PlatformUGCService.supportsLocalPolicyCheckInternal()
end

function PlatformUGCService:supportsTargetPermissionCheck()
	return PlatformUGCService.isBridgeSupported() and PlatformUGCService.supportsPrivilegeCheck()
end

function PlatformUGCService:clearCache()
	self:cancelDeferredServerSync("clear_cache")

	PlatformUGCService.state.cachedLocalPolicy = nil
	PlatformUGCService.state.cachedPrivilegeAllowed = nil
	PlatformUGCService.state.pendingLocalPolicyCallbacks = nil
	PlatformUGCService.state.pendingPrivilegeCallbacks = nil
end

function PlatformUGCService.resolveTargetPlatformUserId(playerInfo)
	if not PlatformIdentityUtils or type(PlatformIdentityUtils.resolvePlatformUserId) ~= "function" then
		return nil
	end

	return PlatformIdentityUtils.resolvePlatformUserId(playerInfo)
end

function PlatformUGCService.resolveTargetSwitch(playerInfo)
	if playerInfo == nil then
		return nil
	end

	if PlatformIdentityUtils and type(PlatformIdentityUtils.resolvePlayerIdentity) == "function" then
		local identity = PlatformIdentityUtils.resolvePlayerIdentity(playerInfo)

		if identity and identity.platformUGCSwitch ~= nil then
			return tonumber(identity.platformUGCSwitch)
		end
	end

	local ok, targetSwitch = pcall(function()
		if playerInfo.platformUGCSwitch ~= nil then
			return playerInfo.platformUGCSwitch
		end

		if playerInfo.platformInfo ~= nil then
			return playerInfo.platformInfo.platformUGCSwitch
		end

		return nil
	end)

	if not ok then
		return nil
	end

	return tonumber(targetSwitch)
end

function PlatformUGCService.isTargetPlatformFriend(playerInfo)
	if PlatformIdentityUtils and type(PlatformIdentityUtils.isPlatformFriend) == "function" then
		return PlatformIdentityUtils.isPlatformFriend(playerInfo) == true
	end

	if playerInfo == nil then
		return false
	end

	local ok, isFriend = pcall(function()
		if playerInfo.isPlatformFriend ~= nil then
			return playerInfo.isPlatformFriend
		end

		if playerInfo.platformInfo ~= nil then
			return playerInfo.platformInfo.isPlatformFriend
		end

		return false
	end)

	return ok and isFriend == true
end

function PlatformUGCService.makeTargetAllowContext(reason)
	return true, {
		ugcVisible = true,
		ugcDecision = PlatformUGCService.Decision.Allow,
		ugcReason = reason
	}
end

function PlatformUGCService.makeTargetDenyContext(reason)
	return false, {
		ugcVisible = false,
		ugcDecision = PlatformUGCService.Decision.Deny,
		ugcReason = reason
	}
end

function PlatformUGCService.normalizeLocalPolicyToTargetSwitch(policy)
	local Policy = PlatformUGCService.LocalPolicy

	if policy == Policy.Allow or policy == "allow" then
		return PlatformUGCService.TargetSwitch.Allow
	end

	if policy == Policy.FriendsOnly or policy == "friends_only" then
		return PlatformUGCService.TargetSwitch.FriendOnly
	end

	if policy == Policy.Blocked or policy == "blocked" then
		return PlatformUGCService.TargetSwitch.Blocked
	end

	if policy == Policy.Fallback or policy == "fallback" then
		return PlatformUGCService.TargetSwitch.Allow
	end

	return nil
end

function PlatformUGCService.completeDeferredServerSync(source, policy)
	if PlatformUGCService.state.deferredServerSyncPending ~= true then
		return
	end

	logger:info("[platform_ugc_privacy] deferred server sync success requestReason=%s source=%s policy=%s version=%s", tostring(PlatformUGCService.state.deferredServerSyncReason or ""), tostring(source or ""), tostring(policy or PlatformUGCService.state.cachedLocalPolicy or ""), tostring(PlatformUGCService.state.deferredServerSyncVersion))

	PlatformUGCService.state.deferredServerSyncPending = false
	PlatformUGCService.state.deferredServerSyncInFlight = false
	PlatformUGCService.state.deferredServerSyncReason = nil
end

function PlatformUGCService:requestDeferredServerSync(reason)
	PlatformUGCService.state.deferredServerSyncVersion = (PlatformUGCService.state.deferredServerSyncVersion or 0) + 1
	PlatformUGCService.state.deferredServerSyncPending = true
	PlatformUGCService.state.deferredServerSyncInFlight = false
	PlatformUGCService.state.deferredServerSyncReason = reason or "login"

	logger:info("[platform_ugc_privacy] deferred server sync requested reason=%s policy=%s version=%s", tostring(PlatformUGCService.state.deferredServerSyncReason), tostring(PlatformUGCService.state.cachedLocalPolicy or ""), tostring(PlatformUGCService.state.deferredServerSyncVersion))

	return true
end

function PlatformUGCService:cancelDeferredServerSync(reason)
	local cancelled = PlatformUGCService.state.deferredServerSyncPending == true or PlatformUGCService.state.deferredServerSyncInFlight == true

	PlatformUGCService.state.deferredServerSyncVersion = (PlatformUGCService.state.deferredServerSyncVersion or 0) + 1
	PlatformUGCService.state.deferredServerSyncPending = false
	PlatformUGCService.state.deferredServerSyncInFlight = false
	PlatformUGCService.state.deferredServerSyncReason = nil

	if cancelled then
		logger:info("[platform_ugc_privacy] deferred server sync cancelled reason=%s version=%s", tostring(reason or ""), tostring(PlatformUGCService.state.deferredServerSyncVersion))
	end

	return cancelled
end

function PlatformUGCService:flushDeferredServerSync(source)
	if PlatformUGCService.state.deferredServerSyncPending ~= true then
		return false
	end

	if PlatformUGCService.state.deferredServerSyncInFlight == true then
		logger:debug("[platform_ugc_privacy] deferred server sync already in flight source=%s version=%s", tostring(source or ""), tostring(PlatformUGCService.state.deferredServerSyncVersion))

		return false
	end

	local version = PlatformUGCService.state.deferredServerSyncVersion
	local requestReason = PlatformUGCService.state.deferredServerSyncReason

	PlatformUGCService.state.deferredServerSyncInFlight = true

	logger:info("[platform_ugc_privacy] deferred server sync flush requestReason=%s source=%s policy=%s version=%s", tostring(requestReason or ""), tostring(source or ""), tostring(PlatformUGCService.state.cachedLocalPolicy or ""), tostring(version))

	local function onPolicyResolved(policy)
		if version ~= PlatformUGCService.state.deferredServerSyncVersion or PlatformUGCService.state.deferredServerSyncPending ~= true then
			logger:info("[platform_ugc_privacy] deferred server sync callback ignored source=%s callbackVersion=%s currentVersion=%s pending=%s", tostring(source or ""), tostring(version), tostring(PlatformUGCService.state.deferredServerSyncVersion), tostring(PlatformUGCService.state.deferredServerSyncPending))

			return
		end

		local synced = PlatformUGCService:syncCurrentSettingToServer(source or "player_enter_scene", policy)

		if version ~= PlatformUGCService.state.deferredServerSyncVersion then
			return
		end

		if synced ~= true then
			PlatformUGCService.state.deferredServerSyncInFlight = false

			logger:warn("[platform_ugc_privacy] deferred server sync failed; keep pending requestReason=%s source=%s policy=%s version=%s", tostring(requestReason or ""), tostring(source or ""), tostring(policy or ""), tostring(version))
		end
	end

	if PlatformUGCService.state.pendingLocalPolicyCallbacks then
		PlatformUGCService.addPendingLocalPolicyCallback(onPolicyResolved)
	else
		self:resolveLocalPolicy(onPolicyResolved)
	end

	return true
end

function PlatformUGCService.registerLocalPolicyChangedListener()
	if PlatformUGCService.state.localPolicyChangedListener then
		return
	end

	local emitter = pg and pg.global and pg.global.eventEmitter

	if emitter == nil or type(emitter.addEventListener) ~= "function" then
		return
	end

	local function listener(payload)
		local policy = payload and payload.policy or nil

		PlatformUGCService:syncCurrentSettingToServer(payload and payload.source or "plm_privacy_refresh", policy)
	end

	emitter:addEventListener(EventConst.PLATFORM_UGC_POLICY_CHANGED, listener)

	PlatformUGCService.state.localPolicyChangedListener = listener
end

function PlatformUGCService.unregisterLocalPolicyChangedListener()
	local emitter = pg and pg.global and pg.global.eventEmitter
	local listener = PlatformUGCService.state.localPolicyChangedListener

	if emitter ~= nil and listener ~= nil and type(emitter.removeEventListener) == "function" then
		emitter:removeEventListener(EventConst.PLATFORM_UGC_POLICY_CHANGED, listener)
	end

	PlatformUGCService.state.localPolicyChangedListener = nil
end

function PlatformUGCService:syncCurrentSettingToServer(source, policy)
	if not pg or not pg.me or not pg.me.serverMsg then
		return false
	end

	if PlatformIdentityUtils and PlatformIdentityUtils.getCurrentPlatformFamily and PlatformIdentityUtils.getCurrentPlatformFamily() == PlatformIdentityUtils.Family.PlayStation then
		logger:info("[platform_ugc_privacy] syncCurrentSettingToServer skipped source=%s family=%s reason=psn_no_server_sync", tostring(source or ""), tostring(PlatformIdentityUtils.Family.PlayStation))
		PlatformUGCService.completeDeferredServerSync(source, policy)

		return true
	end

	local targetSwitch = PlatformUGCService.normalizeLocalPolicyToTargetSwitch(policy or PlatformUGCService.state.cachedLocalPolicy)

	if targetSwitch == nil then
		logger:warn("[platform_ugc_privacy] syncCurrentSettingToServer skipped source=%s policy=%s", tostring(source or ""), tostring(policy or PlatformUGCService.state.cachedLocalPolicy))

		return false
	end

	logger:info("[platform_ugc_privacy] syncCurrentSettingToServer source=%s switch=%s family=%s", tostring(source or ""), tostring(targetSwitch), tostring(PlatformIdentityUtils and PlatformIdentityUtils.getCurrentPlatformFamily and PlatformIdentityUtils.getCurrentPlatformFamily() or ""))
	pg.me:serverMsg("RPC_CS_SetPlatformUGCSwitch", targetSwitch)
	PlatformUGCService.completeDeferredServerSync(source, policy)

	return true
end

function PlatformUGCService:init(runtimeReady)
	PlatformUGCService.state.initialized = true

	PlatformUGCService.registerLocalPolicyChangedListener()

	if PlatformUGCService.state.cachedLocalPolicy ~= nil then
		return true
	end

	if PlatformUGCService.isBridgeSupported() and PlatformUGCService.isConsoleFamily() and PlatformUGCService.supportsLocalPolicyCheckInternal() then
		self:prefetchLocalPolicy("init")

		return true
	end

	PlatformUGCService.completeLocalPolicy(self.LocalPolicy.Fallback)

	return true
end

function PlatformUGCService:shutdown()
	self:cancelDeferredServerSync("shutdown")
	PlatformUGCService.unregisterLocalPolicyChangedListener()

	PlatformUGCService.state.initialized = false
end

function PlatformUGCService:peekLocalPolicy()
	if not PlatformUGCService.isBridgeSupported() or not PlatformUGCService.supportsLocalPolicyCheckInternal() then
		return self.LocalPolicy.Fallback
	end

	return PlatformUGCService.state.cachedLocalPolicy
end

function PlatformUGCService:getLocalPolicy()
	local policy = self:peekLocalPolicy()

	if policy == nil then
		logger:error("PlatformUGCService local UGC policy cache missing")

		return self.LocalPolicy.Fallback
	end

	return policy
end

function PlatformUGCService:isLocalBlocked()
	return self:getLocalPolicy() == self.LocalPolicy.Blocked
end

function PlatformUGCService:peekLocalPrivilege()
	if not PlatformUGCService.isBridgeSupported() or not PlatformUGCService.supportsPrivilegeCheck() then
		return self.Decision.Fallback
	end

	if PlatformUGCService.state.cachedPrivilegeAllowed == nil then
		return nil
	end

	return PlatformUGCService.state.cachedPrivilegeAllowed and self.Decision.Allow or self.Decision.Deny
end

function PlatformUGCService:resolveLocalPrivilege(onResolved)
	if type(onResolved) ~= "function" then
		return false
	end

	if not PlatformUGCService.isBridgeSupported() or not PlatformUGCService.supportsPrivilegeCheck() then
		onResolved(true)

		return false
	end

	if PlatformUGCService.state.cachedPrivilegeAllowed ~= nil then
		onResolved(PlatformUGCService.state.cachedPrivilegeAllowed == true)

		return false
	end

	if PlatformUGCService.state.pendingPrivilegeCallbacks then
		table.insert(PlatformUGCService.state.pendingPrivilegeCallbacks, onResolved)

		return true
	end

	PlatformUGCService.state.pendingPrivilegeCallbacks = {
		onResolved
	}

	PlatformBridgeLuaFacade.CheckUserGeneratedContentPrivilege(function(allowed)
		PlatformUGCService.completePrivilege(allowed == true)
	end)

	return true
end

function PlatformUGCService:prefetchLocalPolicy(reason, onResolved)
	if not PlatformUGCService.isBridgeSupported() or not PlatformUGCService.isConsoleFamily() or not PlatformUGCService.supportsLocalPolicyCheckInternal() then
		PlatformUGCService.addPendingLocalPolicyCallback(onResolved)
		PlatformUGCService.completeLocalPolicy(self.LocalPolicy.Fallback)

		return false
	end

	if PlatformUGCService.state.pendingLocalPolicyCallbacks then
		PlatformUGCService.addPendingLocalPolicyCallback(onResolved)

		return true
	end

	PlatformUGCService.state.pendingLocalPolicyCallbacks = {}

	PlatformUGCService.addPendingLocalPolicyCallback(onResolved)
	PlatformBridgeLuaFacade.CheckLocalUserGeneratedContentPrivacy(function(allowed, result, callbackReason)
		local policy = PlatformUGCService.normalizeLocalPolicy(allowed == true, callbackReason)

		logger:debug("PlatformUGCService prefetch local policy reason=%s result=%s callbackReason=%s policy=%s", tostring(reason or ""), tostring(result or 0), tostring(callbackReason or ""), tostring(policy))
		PlatformUGCService.completeLocalPolicy(policy)
	end)
	self:resolveLocalPrivilege(function()
		return
	end)

	return true
end

function PlatformUGCService:resolveLocalPolicy(onResolved)
	if type(onResolved) ~= "function" then
		return false
	end

	local policy = self:peekLocalPolicy()

	if policy ~= nil then
		onResolved(policy)

		return false
	end

	if PlatformUGCService.state.pendingLocalPolicyCallbacks then
		table.insert(PlatformUGCService.state.pendingLocalPolicyCallbacks, onResolved)

		return true
	end

	PlatformUGCService.state.pendingLocalPolicyCallbacks = {
		onResolved
	}

	if not PlatformUGCService.isBridgeSupported() or not PlatformUGCService.isConsoleFamily() or not PlatformUGCService.supportsLocalPolicyCheckInternal() then
		PlatformUGCService.completeLocalPolicy(self.LocalPolicy.Fallback)

		return false
	end

	PlatformBridgeLuaFacade.CheckLocalUserGeneratedContentPrivacy(function(allowed, result, callbackReason)
		local resolvedPolicy = PlatformUGCService.normalizeLocalPolicy(allowed == true, callbackReason)

		logger:debug("PlatformUGCService resolve local policy result=%s callbackReason=%s policy=%s", tostring(result or 0), tostring(callbackReason or ""), tostring(resolvedPolicy))
		PlatformUGCService.completeLocalPolicy(resolvedPolicy)
	end)

	return true
end

function PlatformUGCService:refreshLocalPolicy(reason, onResolved)
	PlatformUGCService.state.cachedPrivilegeAllowed = nil
	PlatformUGCService.state.pendingPrivilegeCallbacks = nil

	if PlatformUGCService.state.pendingLocalPolicyCallbacks then
		PlatformUGCService.addPendingLocalPolicyCallback(onResolved)

		return true
	end

	return self:prefetchLocalPolicy(reason, onResolved)
end

function PlatformUGCService:isVisibleForPlayer(playerInfo)
	local policy = self:getLocalPolicy()

	if policy == self.LocalPolicy.Blocked then
		return false, {
			ugcReason = "local_ugc_privacy_blocked",
			ugcVisible = false,
			ugcDecision = self.Decision.Deny
		}
	end

	if policy == self.LocalPolicy.FriendsOnly then
		if type(playerInfo) == "table" and playerInfo.isPlatformFriend == true then
			return self:resolveTargetVisibleDecision(playerInfo, "local_ugc_privacy_friends_only")
		end

		return false, {
			ugcReason = "local_ugc_privacy_friends_only",
			ugcVisible = false,
			ugcDecision = self.Decision.Deny
		}
	end

	return self:resolveTargetVisibleDecision(playerInfo, policy == self.LocalPolicy.Fallback and "local_ugc_privacy_fallback" or "local_ugc_privacy_allow")
end

function PlatformUGCService:resolveTargetVisibleDecision(playerInfo, allowReason)
	local targetSwitch = PlatformUGCService.resolveTargetSwitch(playerInfo)

	if targetSwitch == nil then
		return PlatformUGCService.makeTargetAllowContext(self.Reason.TargetSwitchMissing)
	end

	if targetSwitch == self.TargetSwitch.Blocked then
		return PlatformUGCService.makeTargetDenyContext(self.Reason.TargetPermissionDenied)
	end

	if targetSwitch == self.TargetSwitch.FriendOnly then
		if PlatformUGCService.isTargetPlatformFriend(playerInfo) then
			return PlatformUGCService.makeTargetAllowContext(allowReason)
		end

		return PlatformUGCService.makeTargetDenyContext(self.Reason.TargetPermissionDenied)
	end

	if targetSwitch == self.TargetSwitch.Allow then
		return PlatformUGCService.makeTargetAllowContext(allowReason)
	end

	logger:error("PlatformUGCService target UGC switch unknown value=%s", tostring(targetSwitch))

	return PlatformUGCService.makeTargetAllowContext(self.Reason.TargetSwitchUnknown)
end

return PlatformUGCService
