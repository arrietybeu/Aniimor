-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformCrossPlatformService.lua

local logger = require("SDK.Platform.PlatformLogger")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformNoticeUtils = require("SDK.Platform.PlatformNoticeUtils")
local NoticeDef = require("Common.NoticeDef")
local EventConst = require("Common.Const.EventConst")
local ClientConst = require("Const.ClientConst")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local PlatformCrossPlatformService = {}

PlatformCrossPlatformService.Family = PlatformIdentityUtils.Family
PlatformCrossPlatformService.Context = {
	EnterWorld = "enter_world",
	Team = "team",
	Match = "match"
}
PlatformCrossPlatformService.TRANSIENT_INFRA_REASONS = {
	user_not_signed_in = true,
	runtime_not_ready = true
}

function PlatformCrossPlatformService.getCrossPlatformDefaultSettingValue(setting)
	if not setting or not setting.getDefaultSettingValue then
		return true
	end

	local settingFuncType = ClientConst.SettingFuncType

	if not settingFuncType then
		return true
	end

	return setting:getDefaultSettingValue(settingFuncType.CrossPlatform)
end

function PlatformCrossPlatformService.getCrossPlatformEnabledPreference()
	local setting = pg and pg.game and pg.game.setting or nil

	if setting and setting.getBool then
		local defaultValue = PlatformCrossPlatformService.getCrossPlatformDefaultSettingValue(setting)

		return setting:getBool(ClientConst.PrefKey.CrossPlatformEnabled, ToBool(defaultValue))
	end

	return true
end

function PlatformCrossPlatformService.setCrossPlatformEnabledPreference(enabled)
	local setting = pg and pg.game and pg.game.setting or nil

	if not setting then
		return
	end

	return setting:setBool(ClientConst.PrefKey.CrossPlatformEnabled, ToBool(enabled))
end

function PlatformCrossPlatformService.getMultiplayerPrivilegeFailureReason()
	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.GetLocalMultiplayerPrivilegeFailureReason then
		return string.Empty
	end

	return tostring(PlatformBridgeLuaFacade.GetLocalMultiplayerPrivilegeFailureReason() or "")
end

function PlatformCrossPlatformService.getCrossPlayPrivilegeFailureReason()
	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.GetLocalCrossPlayPrivilegeFailureReason then
		return string.Empty
	end

	return tostring(PlatformBridgeLuaFacade.GetLocalCrossPlayPrivilegeFailureReason() or "")
end

function PlatformCrossPlatformService.composeLocalPrivilegeFailureReason(requireCrossPlay)
	local multiplayerReason = PlatformCrossPlatformService.getMultiplayerPrivilegeFailureReason()

	if not string.isNilOrEmpty(multiplayerReason) then
		return multiplayerReason, false
	end

	if not requireCrossPlay then
		return string.Empty, false
	end

	local crossPlayReason = PlatformCrossPlatformService.getCrossPlayPrivilegeFailureReason()

	if string.isNilOrEmpty(crossPlayReason) then
		return string.Empty, false
	end

	return crossPlayReason, not PlatformCrossPlatformService.TRANSIENT_INFRA_REASONS[crossPlayReason]
end

function PlatformCrossPlatformService.isTransientInfraFailure(reason)
	return not string.isNilOrEmpty(reason) and PlatformCrossPlatformService.TRANSIENT_INFRA_REASONS[reason] == true
end

function PlatformCrossPlatformService.getSystemCrossPlatformBlockReason()
	local failureReason = PlatformCrossPlatformService.composeLocalPrivilegeFailureReason(true)

	if string.isNilOrEmpty(failureReason) or PlatformCrossPlatformService.isTransientInfraFailure(failureReason) then
		return string.Empty
	end

	return failureReason
end

function PlatformCrossPlatformService.resolveLocalPrivilegeChain(requireCrossPlay, onResolved)
	function PlatformCrossPlatformService.complete(allowed, reason, isCrossPlayDenial)
		if type(onResolved) == "function" then
			onResolved(allowed == true, allowed == true and string.Empty or tostring(reason or ""), isCrossPlayDenial == true)
		end
	end

	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.ResolveLocalMultiplayerPrivilege then
		PlatformCrossPlatformService.complete(true, string.Empty, false)

		return false
	end

	function PlatformCrossPlatformService.resolveMultiplayerStep()
		PlatformBridgeLuaFacade.ResolveLocalMultiplayerPrivilege(0, function(allowed, _, reason)
			PlatformCrossPlatformService.complete(allowed == true, reason, false)
		end)
	end

	if not requireCrossPlay or not PlatformBridgeLuaFacade.ResolveLocalCrossPlayPrivilege then
		PlatformCrossPlatformService.resolveMultiplayerStep()

		return true
	end

	PlatformBridgeLuaFacade.ResolveLocalCrossPlayPrivilege(0, function(allowed, _, reason)
		if allowed ~= true then
			local resolvedReason = tostring(reason or "")

			PlatformCrossPlatformService.complete(false, resolvedReason, not PlatformCrossPlatformService.TRANSIENT_INFRA_REASONS[resolvedReason])

			return
		end

		PlatformCrossPlatformService.resolveMultiplayerStep()
	end)

	return true
end

PlatformCrossPlatformService.state = {
	initialized = false,
	crossPlayPrivilegeUiPending = false,
	firstCrossNetworkSessionShown = false
}

function PlatformCrossPlatformService.showCrossPlayPrivilegeUi()
	if PlatformIdentityUtils.getCurrentPlatformFamily() ~= PlatformIdentityUtils.Family.Xbox then
		return false
	end

	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.ResolveLocalCrossPlayPrivilege or PlatformCrossPlatformService.state.crossPlayPrivilegeUiPending then
		return false
	end

	PlatformCrossPlatformService.state.crossPlayPrivilegeUiPending = true

	logger:info("Dispatch Xbox CrossPlay privilege UI")

	local dispatched, dispatchError = pcall(function()
		PlatformBridgeLuaFacade.ResolveLocalCrossPlayPrivilege(0, function(allowed, code, reason)
			PlatformCrossPlatformService.state.crossPlayPrivilegeUiPending = false

			logger:info("Xbox CrossPlay privilege UI completed allowed=%s code=%s reason=%s", tostring(allowed), tostring(code), tostring(reason))

			if allowed == true then
				PlatformCrossPlatformService:revalidateAgainstSystemPrivilege()
				PlatformCrossPlatformService:syncCurrentSettingToServer()
			end
		end)
	end)

	if not dispatched then
		PlatformCrossPlatformService.state.crossPlayPrivilegeUiPending = false

		logger:warn("Show Xbox CrossPlay privilege UI failed: %s", tostring(dispatchError))
	end

	return dispatched
end

function PlatformCrossPlatformService.showNoticeTip(noticeId)
	if noticeId == nil then
		return
	end

	PlatformNoticeUtils.showTextTipById(noticeId)

	if noticeId == NoticeDef.CROSS_PLATFORM_MISMATCH then
		PlatformCrossPlatformService.showCrossPlayPrivilegeUi()
	end
end

function PlatformCrossPlatformService.ensureSettingChangedListenerRegistered()
	PlatformCrossPlatformService.state.settingChangedListener = PlatformCrossPlatformService.state.settingChangedListener or function(enabled)
		PlatformCrossPlatformService:_handleSettingChangedEvent(enabled)
	end

	if pg and pg.global and pg.global.eventEmitter and PlatformCrossPlatformService.state.settingChangedListener then
		pg.global.eventEmitter:removeEventListener(EventConst.PLATFORM_CROSS_PLATFORM_SETTING_CHANGED, PlatformCrossPlatformService.state.settingChangedListener)
		pg.global.eventEmitter:addEventListener(EventConst.PLATFORM_CROSS_PLATFORM_SETTING_CHANGED, PlatformCrossPlatformService.state.settingChangedListener)
	end
end

function PlatformCrossPlatformService.resolveFamilyFromPlayerInfo(playerInfo)
	return PlatformIdentityUtils.resolvePlayerInfoFamily(playerInfo)
end

function PlatformCrossPlatformService:init()
	if PlatformCrossPlatformService.state.initialized then
		PlatformCrossPlatformService.ensureSettingChangedListenerRegistered()
		self:revalidateAgainstSystemPrivilege()

		return true
	end

	PlatformCrossPlatformService.state.initialized = true

	PlatformCrossPlatformService.ensureSettingChangedListenerRegistered()
	self:revalidateAgainstSystemPrivilege()
	self:syncCrossPlatformEnabledToBridge(self:isCrossPlatformEnabled())

	return true
end

function PlatformCrossPlatformService:shutdown()
	if pg and pg.global and pg.global.eventEmitter and PlatformCrossPlatformService.state.settingChangedListener then
		pg.global.eventEmitter:removeEventListener(EventConst.PLATFORM_CROSS_PLATFORM_SETTING_CHANGED, PlatformCrossPlatformService.state.settingChangedListener)
	end

	PlatformCrossPlatformService.state.initialized = false
end

function PlatformCrossPlatformService:isCrossPlatformEnabled()
	local family = PlatformIdentityUtils.getCurrentPlatformFamily()

	if family == self.Family.Other then
		return true
	end

	if not PlatformCrossPlatformService.getCrossPlatformEnabledPreference() then
		return false
	end

	return string.isNilOrEmpty(PlatformCrossPlatformService.getSystemCrossPlatformBlockReason())
end

function PlatformCrossPlatformService:setCrossPlatformEnabled(enabled, force)
	if not force and self:isCrossPlatformSettingReadOnly() then
		return
	end

	local boolEnabled = ToBool(enabled)
	local oldValue = PlatformCrossPlatformService.getCrossPlatformEnabledPreference()

	PlatformCrossPlatformService.setCrossPlatformEnabledPreference(boolEnabled)

	if pg and pg.global and pg.global.prefsCacheUtils then
		pg.global.prefsCacheUtils:save()
	end

	if oldValue ~= boolEnabled then
		if pg and pg.global and pg.global.eventEmitter then
			pg.global.eventEmitter:emit(EventConst.PLATFORM_CROSS_PLATFORM_SETTING_CHANGED, boolEnabled)
		end

		if pg and pg.me and pg.me.serverMsg then
			pg.me:serverMsg("RPC_CS_SetCrossPlatformPermissions", boolEnabled)
		end
	end
end

function PlatformCrossPlatformService:syncCurrentSettingToServer()
	if not pg or not pg.me or not pg.me.serverMsg then
		return
	end

	local enabled = self:isCrossPlatformEnabled()

	logger:info("[crossplay] syncCurrentSettingToServer send enabled=%s family=%s", tostring(enabled), tostring(PlatformIdentityUtils.getCurrentPlatformFamily()))
	pg.me:serverMsg("RPC_CS_SetCrossPlatformPermissions", enabled and true or false)
end

function PlatformCrossPlatformService:revalidateAgainstSystemPrivilege()
	if self:isCrossPlatformSettingReadOnly() then
		local failureReason = PlatformCrossPlatformService.getSystemCrossPlatformBlockReason()
		local enabled = string.isNilOrEmpty(failureReason)

		if PlatformCrossPlatformService.getCrossPlatformEnabledPreference() ~= enabled then
			logger:info("revalidateAgainstSystemPrivilege: readonly platform sync cross-platform setting, enabled=%s, reason=%s", tostring(enabled), tostring(failureReason))
			self:setCrossPlatformEnabled(enabled, true)
		end

		return
	end

	if not PlatformCrossPlatformService.getCrossPlatformEnabledPreference() then
		return
	end

	local failureReason = PlatformCrossPlatformService.getSystemCrossPlatformBlockReason()

	if string.isNilOrEmpty(failureReason) then
		return
	end

	logger:info("revalidateAgainstSystemPrivilege: 系统级跨平台/联机特权失效，强制关闭 game-side toggle, reason=%s", tostring(failureReason))
	self:setCrossPlatformEnabled(false)
end

function PlatformCrossPlatformService:requestEnableCrossPlatform(onResolved)
	if self:isCrossPlatformSettingReadOnly() then
		if type(onResolved) == "function" then
			onResolved(false, "cross_platform_setting_readonly")
		end

		return
	end

	function PlatformCrossPlatformService.applyResult(allowed, failureReason, isCrossPlayDenial)
		if allowed == true then
			self:setCrossPlatformEnabled(true)
		else
			self:showMatchPermissionDeniedToast(isCrossPlayDenial)
		end

		if type(onResolved) == "function" then
			onResolved(allowed == true, failureReason)
		end
	end

	local dispatched = PlatformCrossPlatformService.resolveLocalPrivilegeChain(true, function(allowed, reason, isCrossPlayDenial)
		PlatformCrossPlatformService.applyResult(allowed == true, reason, isCrossPlayDenial)
	end)

	if not dispatched then
		return
	end
end

function PlatformCrossPlatformService:isCrossPlatformSettingReadOnly()
	local platform = pg and pg.global and pg.global.platform

	return platform and platform.isConsole and platform:isConsole() and (not platform.isPS or not platform:isPS())
end

function PlatformCrossPlatformService:getPlayerInfoFamily(playerInfo)
	return PlatformCrossPlatformService.resolveFamilyFromPlayerInfo(playerInfo)
end

function PlatformCrossPlatformService:canInteractWithFamily(targetFamily)
	if string.isNilOrEmpty(targetFamily) then
		return true
	end

	if self:isCrossPlatformEnabled() then
		return true
	end

	return targetFamily == PlatformIdentityUtils.getCurrentPlatformFamily()
end

function PlatformCrossPlatformService:showMatchPermissionDeniedToast(isCrossPlayDenial)
	return
end

function PlatformCrossPlatformService:showPermissionDeniedToast(context, isCrossPlayDenial)
	if isCrossPlayDenial ~= true then
		return
	end

	if context == self.Context.Match then
		self:showMatchPermissionDeniedToast(true)

		return
	end

	self:showFamilyConflictToast()
end

function PlatformCrossPlatformService:showFamilyConflictToast()
	PlatformCrossPlatformService.showNoticeTip(NoticeDef.CROSS_PLATFORM_MISMATCH)
end

function PlatformCrossPlatformService:getLocalPermissionFailureReason(targetFamily)
	local selfFamily = PlatformIdentityUtils.getCurrentPlatformFamily()
	local requireCrossPlay = PlatformCrossPlatformService.getCrossPlatformEnabledPreference() and (string.isNilOrEmpty(targetFamily) or targetFamily ~= selfFamily)

	return PlatformCrossPlatformService.composeLocalPrivilegeFailureReason(requireCrossPlay)
end

function PlatformCrossPlatformService:resolveLocalPermission(targetFamily, onResolved)
	if type(onResolved) ~= "function" then
		local failureReason = self:getLocalPermissionFailureReason(targetFamily)

		return string.isNilOrEmpty(failureReason), failureReason
	end

	local selfFamily = PlatformIdentityUtils.getCurrentPlatformFamily()
	local requireCrossPlay = PlatformCrossPlatformService.getCrossPlatformEnabledPreference() and (string.isNilOrEmpty(targetFamily) or targetFamily ~= selfFamily)

	PlatformCrossPlatformService.resolveLocalPrivilegeChain(requireCrossPlay, function(allowed, reason, isCrossPlayDenial)
		onResolved(allowed == true, reason, isCrossPlayDenial == true)
	end)

	return true
end

function PlatformCrossPlatformService:checkMatchPermission(onResolved)
	local failureReason, isCrossPlayDenial = self:getLocalPermissionFailureReason(nil)
	local allowed = string.isNilOrEmpty(failureReason)

	if not allowed then
		self:showMatchPermissionDeniedToast(isCrossPlayDenial)
	end

	if type(onResolved) == "function" then
		onResolved(allowed, allowed and string.Empty or failureReason)
	end

	return allowed
end

function PlatformCrossPlatformService:checkPlayerInteraction(playerInfo, context, onResolved)
	local targetFamily = self:getPlayerInfoFamily(playerInfo)

	if type(onResolved) ~= "function" then
		local failureReason, isCrossPlayDenial = self:getLocalPermissionFailureReason(targetFamily)

		if string.isNilOrEmpty(failureReason) then
			return true
		end

		self:showPermissionDeniedToast(context, isCrossPlayDenial)

		return false
	end

	local failureReason, isCrossPlayDenial = self:getLocalPermissionFailureReason(targetFamily)

	if not string.isNilOrEmpty(failureReason) then
		self:showPermissionDeniedToast(context, isCrossPlayDenial)
		onResolved(false, failureReason)
	else
		onResolved(true, string.Empty)
	end

	return true
end

function PlatformCrossPlatformService:checkTeamInvitePermission(inviterInfo)
	if type(inviterInfo) ~= "table" then
		return true, string.Empty
	end

	local localInfo = {
		platformFamily = PlatformIdentityUtils.getCurrentPlatformFamily(),
		isAllowedCrossPlatform = self:isCrossPlatformEnabled()
	}

	if PlatformIdentityUtils.isCrossNetworkCompatible(localInfo, inviterInfo) then
		return true, string.Empty
	end

	self:showFamilyConflictToast()

	return false, "family_mismatch"
end

function PlatformCrossPlatformService:checkPlayerInteractionByUid(uid, context, onResolved)
	if string.isNilOrEmpty(uid) or not pg or not pg.game or not pg.game.chat then
		if type(onResolved) == "function" then
			onResolved(true, string.Empty)
		end

		return true
	end

	local playerInfo = pg.game.chat:getPlayerInfo(uid)

	if not playerInfo then
		if type(onResolved) == "function" then
			onResolved(true, string.Empty)
		end

		return true
	end

	return self:checkPlayerInteraction(playerInfo, context, onResolved)
end

function PlatformCrossPlatformService:onCrossPlatformSettingChanged(enabled)
	enabled = enabled == true or enabled == 1

	if enabled then
		return
	end

	if not pg or not pg.me then
		return
	end

	if pg.me.isMatchStatusInNormalMatch and pg.me:isMatchStatusInNormalMatch() then
		pg.me:cancelPvpMatch()
	end

	if pg.me.isInTeam and pg.me:isInTeam() then
		pg.me:leaveTeam()

		return
	end

	if pg.me.isInMatching and pg.me:isInMatching() then
		pg.me:cancelTeamMatching()
	end

	if pg.me.isInLeaderWorld and pg.me:isInLeaderWorld() then
		pg.me:leaveLeaderWorld()
	end
end

function PlatformCrossPlatformService:syncCrossPlatformEnabledToBridge(enabled)
	enabled = enabled == true or enabled == 1

	if PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.SetCrossPlatformEnabled then
		PlatformBridgeLuaFacade.SetCrossPlatformEnabled(enabled)
	end
end

function PlatformCrossPlatformService:_handleSettingChangedEvent(enabled)
	enabled = enabled == true or enabled == 1

	self:syncCrossPlatformEnabledToBridge(enabled)
	self:onCrossPlatformSettingChanged(enabled)
end

function PlatformCrossPlatformService:buildReservedMatchFlags()
	return {
		crossPlatformEnabled = self:isCrossPlatformEnabled(),
		selfFamily = PlatformIdentityUtils.getCurrentPlatformFamily()
	}
end

function PlatformCrossPlatformService:tryHandleIncomingCrossPlatformConflict(context, payload)
	if type(payload) ~= "table" then
		return false
	end

	local targetFamily = PlatformIdentityUtils.normalizeFamily(payload.platformFamily)

	if string.isNilOrEmpty(targetFamily) then
		return false
	end

	if not self:canInteractWithFamily(targetFamily) then
		self:showFamilyConflictToast()

		return true
	end

	local failureReason, isCrossPlayDenial = self:getLocalPermissionFailureReason(targetFamily)

	if string.isNilOrEmpty(failureReason) then
		return false
	end

	self:showPermissionDeniedToast(context, isCrossPlayDenial)

	return true
end

return PlatformCrossPlatformService
