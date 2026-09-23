-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\PlatformManager.lua

local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("PlatformManager")
local PlatformCrossPlatformService = require("SDK.Platform.PlatformCrossPlatformService")
local PlatformEntryPrivilegeService = require("SDK.Platform.PlatformEntryPrivilegeService")
local PlatformLoginService = require("SDK.Platform.PlatformLoginService")
local PlatformShellInviteService = require("SDK.Platform.PlatformShellInviteService")
local PlatformRecentPlayerService = require("SDK.Platform.PlatformRecentPlayerService")
local PlatformSocialService = require("SDK.Platform.PlatformSocialService")
local PlatformAchievementService = require("SDK.Platform.PlatformAchievementService")
local PlatformAccountLinkingService = require("SDK.Platform.PlatformAccountLinkingService")
local PlatformShellActivityService = require("SDK.Platform.PlatformShellActivityService")
local PlatformShellJoinService = require("SDK.Platform.PlatformShellJoinService")
local PlatformConnectivityService = require("SDK.Platform.PlatformConnectivityService")
local PlatformPLMService = require("SDK.Platform.PlatformPLMService")
local PlatformUGCService = require("SDK.Platform.PlatformUGCService")
local PlatformSendMessageService = require("SDK.Platform.PlatformSendMessageService")
local PlatformPaymentReconcileService = require("SDK.Platform.PlatformPaymentReconcileService")
local PlatformUtils = require("Common.Utils.PlatformUtils")
local EventConst = require("Common.Const.EventConst")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local DiscordSocialUtils = require("Utils.DiscordSocialUtils")
local PlatformManager = Class.Class("PlatformManager", nil, true)

PlatformManager._uiBridgeLoaded = {
	value = false
}
PlatformManager.PLATFORM_CALLBACK_EVENT = {
	FriendListChanged = "platform_friend_list_changed",
	UgcPolicyChanged = "platform_ugc_policy_changed"
}
PlatformManager.PLATFORM_THROTTLE_INTERVALS = {
	achievement = 0.1,
	social = 0.1,
	completionQueue = 0.033
}

function PlatformManager.isPlatformBridgeSupported()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.IsSupported and PlatformBridgeLuaFacade.IsSupported() == true
end

function PlatformManager.loadPlatformUIBridge()
	if PlatformManager._uiBridgeLoaded.value then
		return
	end

	PlatformManager._uiBridgeLoaded.value = true

	require("SDK.Platform.UIBridge.PlatformUIBridgeLoader")
end

function PlatformManager:loadPlatformUIBridgeAndRegisterSpeechPolicy()
	if not self:shouldLoadPlatformBridge() then
		return
	end

	PlatformManager.loadPlatformUIBridge()
	self:registerPlatformSpeechPolicyRefreshListener()
end

function PlatformManager:ctor()
	self:setPlatform()

	self._platformCallbackRegistry = self._platformCallbackRegistry or {}
	self._enableLog = true
end

PlatformManager.PC_RUNTIME_PLATFORMS = {
	LinuxPlayer = true,
	OSXPlayer = true,
	WindowsPlayer = true,
	LinuxEditor = true,
	OSXEditor = true,
	WindowsEditor = true
}
PlatformManager.EDITOR_RUNTIME_PLATFORMS = {
	LinuxEditor = true,
	OSXEditor = true,
	WindowsEditor = true
}

function PlatformManager.resolveRawPlatform()
	if type(UnityPlatform) == "string" and UnityPlatform ~= "" then
		return UnityPlatform
	end

	return ""
end

function PlatformManager.resolvePlatformFamily(raw)
	if UNITY_XBOXPC == true and PlatformManager.PC_RUNTIME_PLATFORMS[raw] == true then
		return PlatformUtils.Family.Xbox
	end

	if UNITY_GAMECORE == true and PlatformManager.PC_RUNTIME_PLATFORMS[raw] == true then
		return PlatformUtils.Family.Xbox
	end

	if raw == "GameCoreXboxOne" or raw == "GameCoreXboxSeries" or raw == "XboxOne" then
		return PlatformUtils.Family.Xbox
	end

	if raw == "PS4" or raw == "PS5" then
		return PlatformUtils.Family.PlayStation
	end

	if ClientConfigPublishPlatform == "steam" and PlatformManager.PC_RUNTIME_PLATFORMS[raw] == true then
		return PlatformUtils.Family.Steam
	end

	if ClientConfigPublishPlatform == "epic" and PlatformManager.PC_RUNTIME_PLATFORMS[raw] == true then
		return PlatformUtils.Family.Epic
	end

	if ClientConfigPublishPlatform == "xiaoheihe" and PlatformManager.PC_RUNTIME_PLATFORMS[raw] == true then
		return PlatformUtils.Family.XHH
	end

	if PlatformManager.PC_RUNTIME_PLATFORMS[raw] == true then
		return PlatformUtils.Family.Pc
	end

	if raw == "Android" then
		return PlatformUtils.Family.Android
	end

	if raw == "IPhonePlayer" then
		return PlatformUtils.Family.Ios
	end

	return PlatformUtils.Family.Other
end

function PlatformManager.resolveXboxHardwareVersion()
	if type(XboxHardwareVersion) == "string" and XboxHardwareVersion ~= "" then
		return XboxHardwareVersion
	end

	return ""
end

function PlatformManager.resolvePS5HardwareVersion()
	if type(PS5HardwareVersion) == "string" and PS5HardwareVersion ~= "" then
		return PS5HardwareVersion
	end

	return ""
end

function PlatformManager:setPlatform()
	self.raw = PlatformManager.resolveRawPlatform()
	self.family = PlatformManager.resolvePlatformFamily(self.raw)
	self.xboxHardwareVersion = PlatformManager.resolveXboxHardwareVersion()
	self.ps5HardwareVersion = PlatformManager.resolvePS5HardwareVersion()
end

function PlatformManager:getType()
	return self.raw
end

function PlatformManager:getRaw()
	return self.raw
end

function PlatformManager:getFamily()
	return self.family
end

function PlatformManager:isConsoleFamily()
	return PlatformUtils.isConsoleFamily(self.family)
end

function PlatformManager:shouldLoadPlatformBridge()
	return self:isConsoleFamily() or PlatformManager.isPlatformBridgeSupported()
end

function PlatformManager:shouldLoadDiscordBridge()
	return DiscordSocialUtils.isPlatformSupported() == true
end

function PlatformManager:isConsole()
	return self:isXbox() or self:isPS()
end

function PlatformManager:isPC()
	return PlatformManager.PC_RUNTIME_PLATFORMS[self.raw] == true and not self:isXboxPC()
end

function PlatformManager:isMobile()
	return self:isAndroid() or self.family == PlatformUtils.Family.Ios
end

function PlatformManager:isEditor()
	return PlatformManager.EDITOR_RUNTIME_PLATFORMS[self.raw] == true
end

function PlatformManager:isAndroid()
	return self.family == PlatformUtils.Family.Android
end

function PlatformManager:isIos()
	return self.family == PlatformUtils.Family.Ios
end

function PlatformManager:isXboxPC()
	return PlatformManager.PC_RUNTIME_PLATFORMS[self.raw] == true and (UNITY_XBOXPC == true or UNITY_GAMECORE == true)
end

function PlatformManager:isXbox()
	return UNITY_GAMECORE == true
end

function PlatformManager:isPS()
	return self.family == PlatformUtils.Family.PlayStation
end

function PlatformManager:getPSAccountCountryCode()
	if not self:isPS() or PlatformBridgeLuaFacade == nil or PlatformBridgeLuaFacade.GetPSAccountCountryCode == nil then
		return ""
	end

	local success, countryCode = pcall(PlatformBridgeLuaFacade.GetPSAccountCountryCode)

	if not success or type(countryCode) ~= "string" then
		logger:error("[platform] 获取 PS 账号国家/地区码失败: %s", tostring(countryCode))

		return ""
	end

	countryCode = string.upper(countryCode)

	if string.match(countryCode, "^[A-Z][A-Z]$") == nil then
		logger:error("[platform] PS 账号国家/地区码无效: %s", tostring(countryCode))

		return ""
	end

	return countryCode
end

function PlatformManager:isXboxSeriesS()
	return self:isXbox() and self.xboxHardwareVersion == "XboxSeriesS"
end

function PlatformManager:isXboxSeriesX()
	return self:isXbox() and self.xboxHardwareVersion == "XboxSeriesX"
end

function PlatformManager:isPS5Base()
	return self:isPS() and self.ps5HardwareVersion == "PS5Base"
end

function PlatformManager:isPS5Pro()
	return self:isPS() and self.ps5HardwareVersion == "PS5Pro"
end

function PlatformManager:isSteam()
	return ClientConfigPublishPlatform == "steam"
end

function PlatformManager:isEpic()
	return ClientConfigPublishPlatform == "epic"
end

function PlatformManager:isXHH()
	return ClientConfigPublishPlatform == "xiaoheihe"
end

function PlatformManager:isWeGame()
	return ClientConfigPublishPlatform == "wegame"
end

function PlatformManager:useFPXAchievement()
	return self:isSteam() or self:isEpic() or self:isXHH() or self:isGoogle()
end

function PlatformManager:isGoogle()
	return ClientConfigPublishPlatform == "google"
end

function PlatformManager:bindPlatformServices()
	self.crossPlatformService = self.crossPlatformService or PlatformCrossPlatformService
	self.entryPrivilegeService = self.entryPrivilegeService or PlatformEntryPrivilegeService
	self.loginService = self.loginService or PlatformLoginService
	self.shellInviteService = self.shellInviteService or PlatformShellInviteService
	self.recentPlayerService = self.recentPlayerService or PlatformRecentPlayerService
	self.socialService = self.socialService or PlatformSocialService
	self.achievementService = self.achievementService or PlatformAchievementService
	self.accountLinkingService = self.accountLinkingService or PlatformAccountLinkingService
	self.teamActivityService = self.teamActivityService or PlatformShellActivityService
	self.shellJoinService = self.shellJoinService or PlatformShellJoinService
	self.connectivityService = self.connectivityService or PlatformConnectivityService
	self.plmService = self.plmService or PlatformPLMService
	self.ugcService = self.ugcService or PlatformUGCService
	self.sendMessageService = self.sendMessageService or PlatformSendMessageService
	self.paymentReconcileService = self.paymentReconcileService or PlatformPaymentReconcileService
end

function PlatformManager:registerPlatformCallback(eventKey, ownerKey, callbackFn)
	if type(eventKey) ~= "string" or eventKey == "" then
		return false
	end

	if type(ownerKey) ~= "string" or ownerKey == "" then
		return false
	end

	if type(callbackFn) ~= "function" then
		return false
	end

	self._platformCallbackRegistry = self._platformCallbackRegistry or {}
	self._platformCallbackRegistry[eventKey] = self._platformCallbackRegistry[eventKey] or {}
	self._platformCallbackRegistry[eventKey][ownerKey] = callbackFn

	return true
end

function PlatformManager:unregisterPlatformCallback(eventKey, ownerKey)
	local callbacksByEvent = self._platformCallbackRegistry and self._platformCallbackRegistry[eventKey]

	if callbacksByEvent == nil then
		return false
	end

	callbacksByEvent[ownerKey] = nil

	if next(callbacksByEvent) == nil then
		self._platformCallbackRegistry[eventKey] = nil
	end

	return true
end

function PlatformManager:dispatchPlatformCallbacks(eventKey, payload)
	local callbacksByEvent = self._platformCallbackRegistry and self._platformCallbackRegistry[eventKey]

	if callbacksByEvent == nil then
		return 0
	end

	local dispatchCount = 0

	for ownerKey, callbackFn in pairs(callbacksByEvent) do
		local ok, err = pcall(callbackFn, payload)

		if not ok then
			logger:error("[platform] 平台回调分发失败 eventKey=%s ownerKey=%s err=%s", tostring(eventKey), tostring(ownerKey), tostring(err))
		end

		dispatchCount = dispatchCount + 1
	end

	return dispatchCount
end

function PlatformManager:unregisterPlatformSpeechPolicyRefreshListener()
	if self._platformSpeechPolicyRefreshEmitter and self._platformSpeechPolicyRefreshListener and self._platformSpeechPolicyRefreshEmitter.removeEventListener then
		self._platformSpeechPolicyRefreshEmitter:removeEventListener(EventConst.PLATFORM_FRIEND_LIST_CHANGED, self._platformSpeechPolicyRefreshListener)
	end

	if self._platformSpeechPolicyRefreshEmitter and self._platformUgcPolicyChangedListener and self._platformSpeechPolicyRefreshEmitter.removeEventListener then
		self._platformSpeechPolicyRefreshEmitter:removeEventListener(EventConst.PLATFORM_UGC_POLICY_CHANGED, self._platformUgcPolicyChangedListener)
	end

	self._platformSpeechPolicyRefreshEmitter = nil
	self._platformSpeechPolicyRefreshListener = nil
	self._platformUgcPolicyChangedListener = nil
end

function PlatformManager:registerPlatformSpeechPolicyRefreshListener()
	if not self:shouldLoadPlatformBridge() then
		return false
	end

	local emitter = pg.global.eventEmitter

	if emitter == nil or emitter.addEventListener == nil then
		return false
	end

	self:unregisterPlatformSpeechPolicyRefreshListener()

	local function listener(payload)
		self:dispatchPlatformCallbacks(PlatformManager.PLATFORM_CALLBACK_EVENT.FriendListChanged, payload)
	end

	local function ugcPolicyChangedListener(payload)
		self:dispatchPlatformCallbacks(PlatformManager.PLATFORM_CALLBACK_EVENT.UgcPolicyChanged, payload)
	end

	emitter:addEventListener(EventConst.PLATFORM_FRIEND_LIST_CHANGED, listener)
	emitter:addEventListener(EventConst.PLATFORM_UGC_POLICY_CHANGED, ugcPolicyChangedListener)

	self._platformSpeechPolicyRefreshEmitter = emitter
	self._platformSpeechPolicyRefreshListener = listener
	self._platformUgcPolicyChangedListener = ugcPolicyChangedListener

	return true
end

function PlatformManager:initDownstreamServices(runtimeReady)
	if self.loginService and self.loginService.init then
		self.loginService:init(runtimeReady)

		if self._enableLog then
			logger:info("[platform] 平台登录服务初始化完成 runtimeReady=%s", tostring(runtimeReady))
		end
	else
		logger:info("[platform] 平台登录服务初始化失败 runtimeReady=%s", tostring(runtimeReady))
	end

	if self.accountLinkingService and self.accountLinkingService.init then
		local initialized = self.accountLinkingService:init(runtimeReady)

		if self._enableLog then
			logger:info("[platform] 平台账户关联合规服务初始化完成 runtimeReady=%s initialized=%s", tostring(runtimeReady), tostring(initialized))
		end
	end

	if self.entryPrivilegeService and self.entryPrivilegeService.init then
		local initialized = self.entryPrivilegeService:init(runtimeReady)

		if self._enableLog then
			logger:info("[platform] 平台登录入口权限服务初始化完成 runtimeReady=%s initialized=%s", tostring(runtimeReady), tostring(initialized))
		end
	end

	if self.crossPlatformService and self.crossPlatformService.init then
		self.crossPlatformService:init()

		if self._enableLog then
			logger:info("[platform] 跨平台策略服务初始化完成。")
		end
	end

	if self.shellInviteService and self.shellInviteService.init then
		self.shellInviteService:init(runtimeReady)

		if self._enableLog then
			logger:info("[platform] 平台 Shell 邀请服务初始化完成 runtimeReady=%s", tostring(runtimeReady))
		end
	end

	if self.recentPlayerService and self.recentPlayerService.init then
		self.recentPlayerService:init(runtimeReady)

		if self._enableLog then
			logger:info("[platform] 平台最近玩家服务初始化完成 runtimeReady=%s", tostring(runtimeReady))
		end
	end

	if self.achievementService and self.achievementService.init then
		self.achievementService:init(runtimeReady)

		if self._enableLog then
			logger:info("[platform] 平台成就服务初始化完成 runtimeReady=%s", tostring(runtimeReady))
		end
	end

	if self.connectivityService and self.connectivityService.init then
		local initialized = self.connectivityService:init(runtimeReady)

		if self._enableLog then
			logger:info("[platform] Xbox Live 连接守护服务初始化完成 runtimeReady=%s initialized=%s", tostring(runtimeReady), tostring(initialized))
		end
	end

	if self.ugcService and self.ugcService.init then
		local initialized = self.ugcService:init(runtimeReady)

		if self._enableLog then
			logger:info("[platform] 平台 UGC 隐私同步服务初始化完成 runtimeReady=%s initialized=%s", tostring(runtimeReady), tostring(initialized))
		end
	end

	if self.plmService and self.plmService.init then
		local initialized = self.plmService:init()

		if self._enableLog then
			logger:info("[platform] 平台 PLM 服务初始化完成 initialized=%s", tostring(initialized))
		end
	end

	if self.sendMessageService and self.sendMessageService.init then
		local initialized = self.sendMessageService:init(runtimeReady)

		if self._enableLog then
			logger:info("[platform] 平台发送消息服务初始化完成 runtimeReady=%s initialized=%s", tostring(runtimeReady), tostring(initialized))
		end
	end

	if self.paymentReconcileService and self.paymentReconcileService.init then
		local initialized = self.paymentReconcileService:init(runtimeReady)

		if self._enableLog then
			logger:info("[platform] 支付补单服务初始化完成 initialized=%s", tostring(initialized))
		end
	end
end

function PlatformManager.configureThrottleIntervals()
	if PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.ConfigureThrottleIntervals then
		PlatformBridgeLuaFacade.ConfigureThrottleIntervals(PlatformManager.PLATFORM_THROTTLE_INTERVALS.completionQueue, PlatformManager.PLATFORM_THROTTLE_INTERVALS.social, PlatformManager.PLATFORM_THROTTLE_INTERVALS.achievement)
	end
end

function PlatformManager:initPlatformServices()
	self:bindPlatformServices()

	if pg.global.localHostMode > 0 then
		self._enableLog = false
	end

	if self._enableLog then
		logger:info("[platform]平台服务初始化调用 servicesInitialized=%s runtimeReady=%s raw=%s family=%s", tostring(self.servicesInitialized), tostring(self.runtimeReady), tostring(self.raw), tostring(self.family))
	end

	if self.servicesInitialized then
		if self._enableLog then
			logger:info("[platform] 平台服务已初始化，跳过 runtimeReady=%s", tostring(self.runtimeReady))
		end

		if self.runtimeReady == true then
			self:loadPlatformUIBridgeAndRegisterSpeechPolicy()

			return true
		end

		logger:info("[platform] 平台 runtime 尚未 ready，重试平台 runtime 初始化。")
	end

	if self._enableLog then
		logger:info("[platform] 平台服务初始化开始 raw=%s family=%s", tostring(self.raw), tostring(self.family))
	end

	local runtimeReady = false
	local platformSupported = false

	platformSupported = PlatformManager.isPlatformBridgeSupported()

	if self._enableLog then
		logger:info("[platform] 平台桥接检查 bridgeSupported=%s hasInitializeRuntime=%s", tostring(platformSupported), tostring(PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.InitializeRuntime ~= nil))
	end

	if platformSupported then
		PlatformManager.configureThrottleIntervals()
	end

	if platformSupported and PlatformBridgeLuaFacade.InitializeRuntime then
		runtimeReady = PlatformBridgeLuaFacade.InitializeRuntime() == true
	end

	if self._enableLog then
		logger:info("[platform] 平台 runtime 初始化结果 runtimeReady=%s", tostring(runtimeReady))
	end

	if platformSupported and not runtimeReady then
		logger:warn("[platform] 平台 runtime 初始化失败。")
	elseif self._enableLog then
		logger:info("[platform] 平台 runtime 初始化完成。")
	end

	self:initDownstreamServices(runtimeReady)

	self.servicesInitialized = true
	self.runtimeReady = self.runtimeReady == true or runtimeReady == true

	if self._enableLog then
		logger:info("[platform] 平台服务初始化完成 servicesInitialized=%s runtimeReady=%s", tostring(self.servicesInitialized), tostring(self.runtimeReady))
	end

	self:loadPlatformUIBridgeAndRegisterSpeechPolicy()

	return self.runtimeReady
end

function PlatformManager:shutdownAchievementServiceForAccountChange()
	if not self:isGoogle() then
		logger:warn("[platform] 平台成就 account changing ignored: platform is not Google")

		return false
	end

	self:bindPlatformServices()

	if self.achievementService and self.achievementService.shutdown then
		self.achievementService:shutdown()
		logger:info("[platform] 平台成就 Google achievement service shutdown completed")
	end

	return true
end

function PlatformManager:restartAchievementServiceForAccountChange()
	if not self:isGoogle() then
		logger:warn("[platform] 平台成就 account ready ignored: platform is not Google")

		return false
	end

	self:bindPlatformServices()

	if not self.achievementService or not self.achievementService.init then
		logger:warn("[platform] 平台成就 Google achievement service restart failed: service unavailable")

		return false
	end

	if self.achievementService.shutdown then
		self.achievementService:shutdown()
	end

	local result = self.achievementService:init(self.runtimeReady == true)

	if self._enableLog then
		logger:info("[platform] 平台成就 Google achievement service restart completed runtimeReady=%s result=%s", tostring(self.runtimeReady), tostring(result))
	end

	return result
end

function PlatformManager:initPlatformServicesAttached(sdkVendorUid, sdkFpId)
	self:bindPlatformServices()

	if type(sdkVendorUid) == "string" and sdkVendorUid ~= "" then
		self.sdkVendorUid = sdkVendorUid
	else
		self.sdkVendorUid = nil
	end

	if type(sdkFpId) == "string" and sdkFpId ~= "" then
		self.sdkFpId = sdkFpId
	else
		self.sdkFpId = nil
	end

	if self._enableLog then
		logger:info("[platform] 平台服务附加初始化调用 servicesInitialized=%s raw=%s family=%s", tostring(self.servicesInitialized), tostring(self.raw), tostring(self.family))
	end

	if self.servicesInitialized then
		logger:info("[platform] 平台服务已初始化，附加初始化检查 runtimeReady=%s", tostring(self.runtimeReady))

		if self.runtimeReady == true then
			self:loadPlatformUIBridgeAndRegisterSpeechPolicy()

			return true
		end

		logger:info("[platform] 平台 runtime 尚未 ready，重试附加初始化。")
	end

	if self._enableLog then
		logger:info("[platform] 平台服务初始化开始 (attached mode) raw=%s family=%s", tostring(self.raw), tostring(self.family))
	end

	local runtimeReady = false
	local platformSupported = false

	platformSupported = PlatformManager.isPlatformBridgeSupported()

	if self._enableLog then
		logger:info("[platform] 平台附加初始化桥接检查 bridgeSupported=%s", tostring(platformSupported))
	end

	if platformSupported then
		PlatformManager.configureThrottleIntervals()
	end

	if platformSupported and PlatformBridgeLuaFacade.InitializeRuntimeAttached then
		runtimeReady = PlatformBridgeLuaFacade.InitializeRuntimeAttached() == true
	end

	if self._enableLog then
		logger:info("[platform] 平台附加初始化 runtime 结果 runtimeReady=%s", tostring(runtimeReady))
	end

	if platformSupported and not runtimeReady then
		logger:warn("[platform] 平台 runtime 附加初始化失败。")
	elseif self._enableLog then
		logger:info("[platform] 平台 runtime 附加初始化完成。")
	end

	self:initDownstreamServices(runtimeReady)

	self.servicesInitialized = true
	self.runtimeReady = self.runtimeReady == true or runtimeReady == true

	if self._enableLog then
		logger:info("[platform] 平台服务附加初始化完成 servicesInitialized=%s runtimeReady=%s", tostring(self.servicesInitialized), tostring(self.runtimeReady))
	end

	self:loadPlatformUIBridgeAndRegisterSpeechPolicy()

	return self.runtimeReady
end

function PlatformManager:getSdkVendorUid()
	return self.sdkVendorUid or ""
end

function PlatformManager:getSdkFpId()
	return self.sdkFpId or ""
end

function PlatformManager:isOverseasWithoutPS()
	return ClientConfigAppCountry ~= "cn" and not self:isPS()
end

function PlatformManager:isOverseasWithPS()
	return ClientConfigAppCountry ~= "cn" and self:isPS()
end

return PlatformManager
