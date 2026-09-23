-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformLoginService.lua

local logger = require("SDK.Platform.PlatformLogger")
local EventConst = require("Common.Const.EventConst")
local PlatformShellInviteService = require("SDK.Platform.PlatformShellInviteService")
local PlatformPrivacyUtils = require("SDK.Platform.PlatformPrivacyUtils")
local PlatformRecentPlayerService = require("SDK.Platform.PlatformRecentPlayerService")
local PlatformSocialService = require("SDK.Platform.PlatformSocialService")
local PlatformAchievementService = require("SDK.Platform.PlatformAchievementService")
local PlatformAccountLinkingService = require("SDK.Platform.PlatformAccountLinkingService")
local PlatformShellActivityService = require("SDK.Platform.PlatformShellActivityService")
local PlatformShellJoinService = require("SDK.Platform.PlatformShellJoinService")
local PlatformTextCommunicationService = require("SDK.Platform.PlatformTextCommunicationService")
local PlatformCommunicationService = require("SDK.Platform.PlatformCommunicationService")
local PlatformUGCService = require("SDK.Platform.PlatformUGCService")
local PlatformTextMaskService = require("SDK.Platform.PlatformTextMaskService")
local PlatformImageMaskService = require("SDK.Platform.PlatformImageMaskService")
local SDKLoginConfig = require("SDK.SDKLoginConfig")
local TimerManager = require("Core.Timer.TimerManager")
local ClientUtils = require("Utils.ClientUtils")
local SysNoticeData = require("Data.sys_notice_data")
local NoticeDef = require("Common.NoticeDef")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local PlatformLoginService = {}

PlatformLoginService.NOT_SUPPORTED_RESULT = -1
PlatformLoginService.RUNTIME_NOT_READY_RESULT = -2
PlatformLoginService.state = {
	controllerReconnectConfirmShown = false,
	deviceAssociationCallbackRegistered = false,
	userCallbackRegistered = false,
	runtimeReadySynced = false,
	signedOut = false,
	activeUserId = "",
	signingIn = false,
	initialized = false
}

function PlatformLoginService.getBridgeDisplayName()
	if PlatformLoginService.isNativeSignInSkipped() then
		return ""
	end

	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.GetSignedInDisplayName then
		return ""
	end

	return tostring(PlatformBridgeLuaFacade.GetSignedInDisplayName() or "")
end

function PlatformLoginService.getUserId()
	if PlatformLoginService.isNativeSignInSkipped() then
		return pg.global.platform:getSdkFpId()
	end

	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.GetSignedInUserId then
		return ""
	end

	local userId = PlatformBridgeLuaFacade.GetSignedInUserId()

	if string.isNilOrEmpty(userId) then
		return ""
	end

	return tostring(userId)
end

function PlatformLoginService.hasBridgeSignedInUser()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.HasSignedInUser and PlatformBridgeLuaFacade.HasSignedInUser() == true
end

function PlatformLoginService.isNativeSignInSkipped()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.IsIdentitySkipped and PlatformBridgeLuaFacade.IsIdentitySkipped() == true
end

function PlatformLoginService.isPlatformSupported()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.IsSupported and PlatformBridgeLuaFacade.IsSupported()
end

function PlatformLoginService.supportsUserChangedCallback()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.SupportsUserChangedCallback and PlatformBridgeLuaFacade.SupportsUserChangedCallback() == true
end

function PlatformLoginService.resetActiveUser()
	PlatformLoginService.state.activeUserId = ""
end

function PlatformLoginService.hasSignedOut()
	return PlatformLoginService.state.signedOut == true
end

function PlatformLoginService.resetRecentPlayerState()
	PlatformRecentPlayerService:resetReportedState()
end

function PlatformLoginService.closeControllerReconnectConfirm()
	if not PlatformLoginService.state.controllerReconnectConfirmShown then
		return
	end

	PlatformLoginService.state.controllerReconnectConfirmShown = false

	if pg and pg.global and pg.global.ui and pg.global.ui.commonConfirm then
		pg.global.ui.commonConfirm:close()
	end
end

function PlatformLoginService.showControllerReconnectConfirm()
	if PlatformLoginService.state.controllerReconnectConfirmShown then
		return
	end

	if not pg or not pg.global or not pg.global.ui or not pg.global.ui.commonConfirm then
		logger:warn("控制器断开提示无法显示：commonConfirm 尚未就绪")

		return
	end

	PlatformLoginService.state.controllerReconnectConfirmShown = true

	local noticeCfg = SysNoticeData[NoticeDef.CONTROLLER_DISCONNECT]

	ClientUtils.showConfirmByConfig({
		showNextBtn = false,
		hideCancel = true,
		desc = noticeCfg and noticeCfg.text or "",
		extraInfo = {
			pauseGame = true,
			hideAllButtons = true,
			onSupersededCb = function()
				PlatformLoginService.state.controllerReconnectConfirmShown = false
			end
		}
	})
end

function PlatformLoginService.resetUserBoundPlatformState()
	PlatformUGCService:cancelDeferredServerSync("reset_user_bound_platform_state")
	PlatformShellInviteService:resetPendingState()
	PlatformRecentPlayerService:shutdown()
	PlatformSocialService:shutdown()
	PlatformAchievementService:shutdown()
	PlatformAccountLinkingService:shutdown()
	PlatformShellActivityService:shutdown()
	PlatformShellJoinService:shutdown()
	PlatformTextCommunicationService:clearPermissionCache({
		clearUGCService = false
	})
	PlatformTextMaskService:clearCache()
	PlatformImageMaskService:clearCache()
end

function PlatformLoginService:requestPlatformSuspend()
	if PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.RequestSuspend then
		return PlatformBridgeLuaFacade.RequestSuspend()
	end
end

function PlatformLoginService:isSupported()
	return PlatformLoginService.isPlatformSupported()
end

function PlatformLoginService:ensureRuntimeReady()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.IsRuntimeInitialized and PlatformBridgeLuaFacade.IsRuntimeInitialized() == true
end

function PlatformLoginService:isInitialized()
	return PlatformLoginService.state.initialized
end

function PlatformLoginService:isSignedIn()
	if PlatformLoginService.isNativeSignInSkipped() then
		return not string.isNilOrEmpty(PlatformLoginService.getUserId())
	end

	return self:isSupported() and self:ensureRuntimeReady() and PlatformLoginService.hasBridgeSignedInUser()
end

function PlatformLoginService:isShellJoinUserSessionReady()
	if not PlatformLoginService.state.initialized or PlatformLoginService.state.signingIn or not self:ensureRuntimeReady() then
		return false
	end

	local activeUserId = tostring(PlatformLoginService.state.activeUserId or "")
	local bridgeUserId = tostring(PlatformLoginService.getUserId() or "")

	return not string.isNilOrEmpty(activeUserId) and activeUserId == bridgeUserId
end

function PlatformLoginService:getCurrentUser()
	if not self:isSignedIn() then
		return nil
	end

	local userId = PlatformLoginService.getUserId()

	if string.isNilOrEmpty(userId) then
		return nil
	end

	return {
		displayName = PlatformLoginService.getBridgeDisplayName(),
		userId = userId
	}
end

function PlatformLoginService:syncBridgeUserState()
	if PlatformLoginService.isNativeSignInSkipped() then
		local userId = PlatformLoginService.getUserId()

		if string.isNilOrEmpty(userId) then
			if not string.isNilOrEmpty(PlatformLoginService.state.activeUserId) then
				logger:warn("FPX SDK 登录用户状态同步检测到 vendor uid 已失效，按签出处理。")
				self:onSignedOut()
			end

			return false, ""
		end

		return true, userId
	end

	if not self:isSupported() then
		PlatformLoginService.resetActiveUser()

		return false, ""
	end

	local hasUser = PlatformLoginService.hasBridgeSignedInUser()
	local userId = ""

	if hasUser then
		userId = PlatformLoginService.getUserId()

		if not string.isNilOrEmpty(userId) then
			local sdkVendorUid = ""

			if pg and pg.global and pg.global.platform and pg.global.platform.getSdkVendorUid then
				sdkVendorUid = pg.global.platform:getSdkVendorUid()
			end

			if not string.isNilOrEmpty(sdkVendorUid) and sdkVendorUid ~= userId then
				if PlatformPrivacyUtils:shouldRedactSensitiveLogs() then
					logger:warn("检测到平台 XUID 不匹配（已脱敏）")
				else
					logger:warn("平台 XUID 不匹配 native=%s sdk_vendor=%s", tostring(userId), tostring(sdkVendorUid))
				end
			end
		end
	elseif not string.isNilOrEmpty(PlatformLoginService.state.activeUserId) then
		logger:warn("平台用户状态同步检测到平台账号已签出。")
		self:onSignedOut()

		return false, ""
	end

	return hasUser, userId
end

function PlatformLoginService:registerUserChangeCallback()
	if PlatformLoginService.state.userCallbackRegistered or not self:isSupported() or not PlatformLoginService.supportsUserChangedCallback() then
		return
	end

	PlatformBridgeLuaFacade.RegisterUserChangedCallback(function(eventType, payloadJson)
		self:onUserChanged(eventType, payloadJson)
	end)

	PlatformLoginService.state.userCallbackRegistered = true
end

function PlatformLoginService:registerControllerChangedCallback()
	if PlatformLoginService.state.deviceAssociationCallbackRegistered or not self:isSupported() then
		return
	end

	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.RegisterControllerChangedCallback then
		logger:warn("平台不支持 RegisterControllerChangedCallback")

		return
	end

	PlatformBridgeLuaFacade.RegisterControllerChangedCallback(function(eventType)
		self:onControllerChanged(eventType)
	end)

	PlatformLoginService.state.deviceAssociationCallbackRegistered = true
end

function PlatformLoginService:onControllerChanged(eventType)
	if eventType == "ControllerDisconnected" then
		PlatformLoginService.showControllerReconnectConfirm()

		return
	end

	if eventType == "ControllerConnected" or eventType == "DeviceAssociationChanged" then
		PlatformLoginService.closeControllerReconnectConfirm()

		return
	end
end

function PlatformLoginService.emitUserSignedIn(sourceReason)
	if pg and pg.global and pg.global.eventEmitter then
		pg.global.eventEmitter:emit(EventConst.PLATFORM_USER_SIGNED_IN, {
			platformUserId = PlatformLoginService.getUserId(),
			sourceReason = sourceReason or "platform_signed_in"
		})
	end
end

function PlatformLoginService.activateSignedInUser(sourceReason)
	local resolvedSourceReason = sourceReason or "platform_signed_in"
	local userId = PlatformLoginService.getUserId()

	if not string.isNilOrEmpty(userId) then
		PlatformLoginService.state.activeUserId = userId
	end

	PlatformLoginService.state.signedOut = false

	PlatformRecentPlayerService:init()
	PlatformSocialService:init()
	PlatformAchievementService:init()
	PlatformAccountLinkingService:init()
	PlatformShellActivityService:init()
	PlatformShellInviteService:init()
	PlatformTextCommunicationService:prefetchLocalCommunicationPrivileges()
	PlatformCommunicationService:prefetchLocalCommunicationPolicy()
	PlatformUGCService:prefetchLocalPolicy("login")
	PlatformLoginService.emitUserSignedIn(resolvedSourceReason)
end

function PlatformLoginService:activateBridgeUserIfReady(sourceReason)
	if PlatformLoginService.state.signingIn then
		return false
	end

	if not self:ensureRuntimeReady() then
		return false
	end

	if not PlatformLoginService.isNativeSignInSkipped() and not PlatformLoginService.hasBridgeSignedInUser() then
		return false
	end

	local hasUser, userId = self:syncBridgeUserState()

	if not hasUser or string.isNilOrEmpty(userId) or PlatformLoginService.state.activeUserId == userId then
		return false
	end

	PlatformLoginService.resetUserBoundPlatformState()
	PlatformLoginService.activateSignedInUser(sourceReason or "platform_late_signed_in")

	return true
end

function PlatformLoginService:syncRuntimeReadyState()
	if not self:ensureRuntimeReady() then
		return false, false
	end

	self:registerUserChangeCallback()
	self:registerControllerChangedCallback()
	logger:info("开始同步 runtime ready 后的平台登录状态。")

	local hasUser, userId = self:syncBridgeUserState()

	if hasUser then
		if PlatformPrivacyUtils:shouldRedactSensitiveLogs() then
			logger:info("检测到已有平台用户，刷新平台社交状态。")
		else
			logger:info("检测到已有平台用户: %s (%s)，刷新平台社交状态。", tostring(PlatformLoginService.getBridgeDisplayName()), tostring(userId))
		end

		PlatformLoginService.resetUserBoundPlatformState()
		PlatformLoginService.activateSignedInUser()
	else
		logger:info("当前尚无平台用户，需要主动补平台用户句柄。")
	end

	return true, hasUser
end

function PlatformLoginService:onUserChanged(eventType, payloadJson)
	if eventType == "SignedOut" then
		self:onSignedOut()

		return
	end

	if eventType == "OnlineIdChanged" then
		self:syncBridgeUserState()

		if pg and pg.global and pg.global.eventEmitter then
			pg.global.eventEmitter:emit(EventConst.PLATFORM_ONLINE_ID_CHANGED, payloadJson or "")
		end

		return
	end

	local previousUserId = PlatformLoginService.state.activeUserId
	local hasUser, userId = self:syncBridgeUserState()

	if not string.isNilOrEmpty(previousUserId) and previousUserId ~= userId and not string.isNilOrEmpty(userId) then
		logger:warn("平台用户已切换 previous→new: %s→%s，按 SignedOut 处理，等待系统接管。", tostring(previousUserId), tostring(userId))
		self:onSignedOut()

		return
	end

	if previousUserId ~= userId then
		PlatformLoginService.resetUserBoundPlatformState()
		PlatformLoginService.resetRecentPlayerState()
	end

	if hasUser then
		PlatformLoginService.activateSignedInUser("platform_user_changed")
	end
end

function PlatformLoginService:onSignedOut()
	logger:info("平台用户已签出，清理平台用户态，等待系统接管。")

	PlatformLoginService.state.signedOut = true

	self:onExternalLogoutSuccess(true)
	self:requestPlatformSuspend()
end

function PlatformLoginService:init(runtimeReady)
	if PlatformLoginService.state.initialized then
		if PlatformLoginService.state.runtimeReadySynced then
			PlatformLoginService.activateBridgeUserIfReady(self, "platform_runtime_ready_resync")

			return true
		end

		if runtimeReady == true or self:ensureRuntimeReady() then
			return self:onPlatformRuntimeInitialized()
		end

		return true
	end

	if not self:isSupported() then
		return false
	end

	PlatformLoginService.state.initialized = true

	if runtimeReady ~= true and not self:ensureRuntimeReady() then
		return true
	end

	self:onPlatformRuntimeInitialized()

	return true
end

function PlatformLoginService:signInSilent(externalCallback)
	return self:signIn(false, externalCallback)
end

function PlatformLoginService:signInWithUI(externalCallback)
	return self:signIn(true, externalCallback)
end

function PlatformLoginService:signIn(allowUI, externalCallback)
	if PlatformLoginService.isNativeSignInSkipped() then
		self:onSignInSuccess()

		if type(externalCallback) == "function" then
			externalCallback(true, 0, "fpx_sdk_signed_in")
		end

		logger:info("isNativeSignInSkipped onSignInSuccess")

		return true
	end

	if not self:isSupported() then
		if type(externalCallback) == "function" then
			externalCallback(false, PlatformLoginService.NOT_SUPPORTED_RESULT, "platform_not_supported")
		end

		return false
	end

	if not self:ensureRuntimeReady() then
		if type(externalCallback) == "function" then
			externalCallback(false, PlatformLoginService.RUNTIME_NOT_READY_RESULT, "runtime_not_ready")
		end

		return false
	end

	if PlatformLoginService.state.signingIn then
		logger:warn("平台登录仍在进行中，忽略新的请求。")

		return false
	end

	PlatformLoginService.state.signingIn = true

	PlatformBridgeLuaFacade.SignIn(allowUI == true, 0, function(success, result, message)
		PlatformLoginService.state.signingIn = false

		if success then
			self:onSignInSuccess()
		else
			self:onSignInFailed(result, message, allowUI)
		end

		if type(externalCallback) == "function" then
			externalCallback(success, result, message)
		end
	end)

	return true
end

function PlatformLoginService:onPlatformRuntimeInitialized()
	if not self:isSupported() then
		return false
	end

	if PlatformLoginService.state.runtimeReadySynced then
		return true
	end

	logger:info("平台 runtime 初始化完成，开始补平台用户句柄。")

	local runtimeReady, hasUser = self:syncRuntimeReadyState()

	if not runtimeReady then
		logger:warn("平台 runtime 初始化完成回调触发时，runtime 实际尚未就绪。")

		return false
	end

	PlatformLoginService.state.runtimeReadySynced = true

	if hasUser then
		return true
	end

	if PlatformLoginService.state.signingIn then
		return true
	end

	return self:signInSilent(function(success)
		if success then
			return
		end

		if SDKLoginConfig.isEnabled() then
			logger:warn("SDK 登录模式下静默补用户失败，跳过 UI 兜底以避免账号不一致。")

			return
		end

		logger:info("静默补用户失败，切换到 AllowingUI 登录兜底。")
		self:retrySignInWithUIUntilPicked(1)
	end)
end

function PlatformLoginService:retrySignInWithUIUntilPicked(attempt)
	self:signInWithUI(function(uiSuccess, uiResult, uiMessage)
		if uiSuccess then
			logger:info("平台登录 UI 兜底成功 attempt=%s", tostring(attempt))

			return
		end

		if attempt % 5 == 0 then
			logger:warn("平台登录 UI 兜底已重试 %s 次仍未选中账户 result=%s reason=%s", tostring(attempt), tostring(uiResult), tostring(uiMessage))
		end

		TimerManager.addTimer(1, function()
			self:retrySignInWithUIUntilPicked(attempt + 1)
		end)
	end)
end

function PlatformLoginService:onExternalLogoutSuccess(resetBridgeState)
	logger:info("收到外部 SDK 登出回调，开始清理平台状态 resetBridgeState=%s", tostring(resetBridgeState))
	PlatformLoginService.resetUserBoundPlatformState()

	PlatformLoginService.state.signingIn = false
	PlatformLoginService.state.runtimeReadySynced = false

	PlatformLoginService.resetActiveUser()

	if resetBridgeState ~= false and PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.ResetUserState then
		PlatformBridgeLuaFacade.ResetUserState()
	end

	return true
end

function PlatformLoginService:onSignInSuccess()
	PlatformLoginService.resetUserBoundPlatformState()

	local _, userId = self:syncBridgeUserState()

	if PlatformPrivacyUtils:shouldRedactSensitiveLogs() then
		logger:info("平台登录成功 hasDisplayName=%s hasUserId=%s", tostring(not string.isNilOrEmpty(PlatformLoginService.getBridgeDisplayName())), tostring(not string.isNilOrEmpty(userId)))
	else
		logger:info("平台登录成功: %s (%s)", tostring(PlatformLoginService.getBridgeDisplayName()), tostring(userId))
	end

	PlatformLoginService.activateSignedInUser()
end

function PlatformLoginService:onSignInFailed(result, message, allowUI)
	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.HasSignedInUser or PlatformBridgeLuaFacade.HasSignedInUser() ~= true then
		PlatformLoginService.resetUserBoundPlatformState()
		PlatformLoginService.resetActiveUser()
	end

	logger:warn("平台登录失败 allowUI=%s result=%s reason=%s", tostring(allowUI), tostring(result), tostring(message))
end

function PlatformLoginService:shutdown()
	PlatformUGCService:cancelDeferredServerSync("platform_login_shutdown")
	PlatformLoginService.closeControllerReconnectConfirm()
	PlatformShellInviteService:shutdown()
	PlatformRecentPlayerService:shutdown()
	PlatformSocialService:shutdown()
	PlatformAchievementService:shutdown()
	PlatformAccountLinkingService:shutdown()
	PlatformShellActivityService:shutdown()
	PlatformShellJoinService:shutdown()
	PlatformTextMaskService:clearCache()
	PlatformImageMaskService:clearCache()

	if PlatformLoginService.state.userCallbackRegistered and PlatformLoginService.supportsUserChangedCallback() and PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.RegisterUserChangedCallback then
		PlatformBridgeLuaFacade.RegisterUserChangedCallback(nil)
	end

	if PlatformLoginService.state.deviceAssociationCallbackRegistered and PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.RegisterControllerChangedCallback then
		PlatformBridgeLuaFacade.RegisterControllerChangedCallback(nil)
	end

	PlatformLoginService.state.userCallbackRegistered = false
	PlatformLoginService.state.deviceAssociationCallbackRegistered = false
	PlatformLoginService.state.initialized = false
	PlatformLoginService.state.signingIn = false
	PlatformLoginService.state.runtimeReadySynced = false

	PlatformLoginService.resetActiveUser()

	if PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.ResetUserState then
		PlatformBridgeLuaFacade.ResetUserState()
	end
end

return PlatformLoginService
