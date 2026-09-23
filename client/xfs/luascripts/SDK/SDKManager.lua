-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\SDKManager.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local json = require("json")
local IDManager = require("Core.Common.IDManager")
local Class = require("Core.Framework.Class")
local ClientSwitch = require("Common.ClientSwitch")
local SDKLoginConfig = require("SDK.SDKLoginConfig")
local DiscordSocialUtils = require("Utils.DiscordSocialUtils")
local logger = LoggerManager.getLogger("SDKManager")
local csSDKManager = CS.FunPlus.WorldX.SDK.SDKManager
local ClientUtils = require("Utils.ClientUtils")
local csXCloudPipeController = CS.FunPlus.WorldX.SDK.XCloudPipeController
local MessageName = require("Const.MessageName")
local EventConst = require("Const.EventConst")
local Utils = require("Common.Utils.Utils")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local SOCIAL_TYPE_SUPPORT_RETRY_INTERVAL = 1
local ACCOUNT_INFO_RETRY_INTERVAL = 1
local DEVICE_DATA_RETRY_INTERVAL = 1
local HELP_CENTER_DISABLED_PKG_CHANNELS = {
	["harmony.official.Ahclx6"] = true,
	["PCBilibili.official.Anur8t"] = true,
	["bilibili.official.A6skit"] = true
}
local DOUYIN_CLOUD_GAME_PKG_CHANNEL = "douyin-cloud-game.official.Aw6vf9"
local SCREEN_RECORDING_COMPATIBILITY_KEY = "s_HasBuggyDepthOnlyPassWrongWithScreenRecording"
local SDKManager = Class.OldLightClass("SDKManager", nil, true)

local function showSdkLoginFailedTip(textKey)
	local loginCtrl = pg and pg.global and pg.global.ui and pg.global.ui.login

	if loginCtrl and loginCtrl.showLoginFailedTip then
		loginCtrl:showLoginFailedTip(textKey)

		return
	end

	if loginCtrl and loginCtrl.resetLoginState then
		loginCtrl:resetLoginState()
	end

	pg.global.showBubbleMessageRaw(pg.getGameString(textKey), 3)
end

local function refreshLoginButtonInteractable()
	local loginCtrl = pg and pg.global and pg.global.ui and pg.global.ui.login

	if loginCtrl and loginCtrl._refreshPlatformLoginButtonInteractable then
		loginCtrl:_refreshPlatformLoginButtonInteractable()
	end
end

local function getConsoleDeviceName()
	local platform = pg and pg.global and pg.global.platform

	if platform == nil or not platform:isConsole() then
		return nil
	end

	if platform:isXbox() then
		return platform:isXboxSeriesS() and "XSS" or "XSX"
	end

	return platform:isPS5Pro() and "PS5Pro" or "PS5"
end

local function getConsolePresetName()
	local setting = pg and pg.game and pg.game.setting

	if setting == nil or setting.getPreset == nil then
		return nil
	end

	local preset = setting:getPreset()

	if preset == 0 then
		return "Performance"
	elseif preset == 1 then
		return "Quality"
	end

	return nil
end

local function traceSDKInit(message, ...)
	local text = string.format(message, ...)

	print(text)

	if LoggerManager.checkLogger(LoggerConst.WARN) then
		logger:warn(text)
	end
end

local function logTrackingInfoSnapshot(source, sdkManager)
	local trackingInfo = sdkManager:getTrackingInfo()
	local vendorUid = "<nil_response>"
	local trackingInfoLen = 0

	if trackingInfo == nil then
		vendorUid = "<nil_response>"
	else
		trackingInfo = tostring(trackingInfo)
		trackingInfoLen = #trackingInfo

		if trackingInfo == "" then
			vendorUid = "<empty_response>"
		else
			local ok, decoded = pcall(json.decode, trackingInfo)

			if ok and type(decoded) == "table" and decoded.properties then
				local value = decoded.properties.vendor_uid

				if value == nil or value == "" then
					vendorUid = "<empty>"
				else
					vendorUid = tostring(value)
				end
			else
				vendorUid = trackingInfo
			end
		end
	end

	traceSDKInit("SDKManager:%s GetTrackingInfo(len=%s)=%s vendor_uid=%s", tostring(source), tostring(trackingInfoLen), tostring(trackingInfo), vendorUid)
end

local function extractVendorUid(trackingInfoStr)
	if trackingInfoStr == nil or trackingInfoStr == "" then
		return nil
	end

	local ok, decoded = pcall(json.decode, trackingInfoStr)

	if ok and type(decoded) == "table" and decoded.properties then
		local value = decoded.properties.vendor_uid

		if value ~= nil and value ~= "" then
			return tostring(value)
		end
	end

	return nil
end

local function ticketFingerprint(ticket)
	if ticket == nil then
		return "<nil>"
	end

	local s = tostring(ticket)
	local len = #s

	if len == 0 then
		return "<empty>"
	end

	local head = string.sub(s, 1, 12)
	local tail = len > 12 and string.sub(s, len - 7, len) or ""

	return string.format("len=%d head=%s tail=%s", len, head, tail)
end

local REFRESH_TICKET_TIMEOUT_SEC = 12
local LOCAL_LOGIN_CALLBACK_TIMEOUT_SEC = 15
local CLOUD_LOGIN_PIPE_RETRY_INTERVAL_SEC = 1
local CLOUD_LOGIN_PIPE_RETRY_MAX_SEC = 15
local CLOUD_LOGIN_CALLBACK_TIMEOUT_SEC = 15

SDKManager.LANGUAGE_TYPE_MAP = {
	[0] = "zh",
	"zh-tw",
	"en",
	"ko",
	"ja",
	"vi",
	"ru",
	"de",
	"fr",
	"es",
	"pt",
	"id",
	"th"
}

local TiktokData = {}

TiktokData.launch_id = ""
TiktokData.app_version = "1.0.0"
TiktokData.app_version_code = "100"
TiktokData.ip = "192.168.0.1"
TiktokData.model = "iPhone12,2"
TiktokData.idfa = ""
TiktokData.imei = ""
TiktokData.caid = "[{\"version\":\"20230330\",\"caid\":\"912ec803b2ce49e4a541068d495ab570\"},{\"version\":\"20220111\",\"caid\":\"e332a76c29654fcb7f6e6b31ced090c7\"}]"
TiktokData.oaid = "cexxx4c-3xxf-4xx9-9xx9-440xxxxxxx65"
TiktokData.encrypted_idfa = ""
TiktokData.encrypted_imei = ""
TiktokData.encrypted_caid = ""
TiktokData.encrypted_oaid = ""
TiktokData.os_version = "13.3"
TiktokData.device_brand = ""
TiktokData.device_manufacturer = ""

function SDKManager:ctor()
	self.isInit = false

	self:clear()
end

function SDKManager:clear()
	if ClientConfigCloudEnable == "true" then
		self:invalidateCloudSDKSessionCache()
	end

	if self._localLoginCallbackTimer ~= nil then
		TimerManager.removeTimer(self._localLoginCallbackTimer)

		self._localLoginCallbackTimer = nil
	end

	if self._cloudLoginRetryTimer ~= nil then
		TimerManager.removeTimer(self._cloudLoginRetryTimer)

		self._cloudLoginRetryTimer = nil
	end

	if self._cloudLoginCallbackTimer ~= nil then
		TimerManager.removeTimer(self._cloudLoginCallbackTimer)

		self._cloudLoginCallbackTimer = nil
	end

	self._loginAttemptSeq = (self._loginAttemptSeq or 0) + 1
	self._cloudLoginRetryElapsed = nil
	self.fpId = nil
	self.ticket = nil
	self.accountId = nil
	self.vendorUid = nil
	self.sessionKey = nil
	self.isAccountNew = 0
	self._lastEnterGameFpId = nil
	self.fnCallbackLogin = nil
	self.fnCallbackLoginFailed = nil
	self.fnCallbackInit = nil
	self.fnCallbackWebViewClosed = nil
	self.fnRefreshTicketCallBack = nil
	self._refreshTicket = false

	if self._refreshTicketTimer ~= nil then
		TimerManager.removeTimer(self._refreshTicketTimer)

		self._refreshTicketTimer = nil
	end

	self.fnCallbackLogout = nil
	self.trackingInfo = nil
	self.funtapCheckUserData = nil
	self.bindInfos = nil
	self.funStoreConfig = nil
	self.funStoreEnabled = false
	self.funStoreInitIdentity = nil
	self.discordSocialInfoNeedsRefresh = false
	self._discordSocialInfoRequesting = false
	self.discordSocialAccountId = nil
	self._discordJoinCallback = nil
	self._pendingDiscordJoinSecret = nil
	self._discordJoinBindRequested = false
	self._discordAuthorizationCallbacks = nil
	self.isLogin = false
	self._loginInProgress = false
end

function SDKManager:getFpId()
	return self.fpId
end

function SDKManager:getTicket()
	return self.ticket
end

function SDKManager:getAccountId()
	return self.accountId
end

function SDKManager:init()
	self:registerClientSwitchChangedListener()
	traceSDKInit("SDKManager:init start EnableSDKLogin=%s ClientConfigCloudEnable=%s hasPlatform=%s", tostring(SDKLoginConfig.isEnabled()), tostring(ClientConfigCloudEnable), tostring(pg ~= nil and pg.global ~= nil and pg.global.platform ~= nil))

	if csSDKManager.HasSdkInitResult() then
		self:onSDKInitCallback(csSDKManager.GetSdkInitResult())
	end

	if csSDKManager.HasSidebarFocusResult() then
		self:onSidebarFocusIn()
	end

	if csSDKManager.HasClientIPInfoResult() then
		self:onClientIPInfo()
	end

	if csSDKManager.HasFuntapCheckUserResult() then
		self:onFuntapCheckUser()
	end

	csXCloudPipeController.InitFromLua()

	if ClientSwitch.EnableGMESDK and not UNITY_EDITOR_OSX then
		pg.global.gmeManager:Init()
	end

	csSDKManager.XSDKInit()
	csSDKManager.XSDKStartup()
end

function SDKManager:_clearLoginTimers()
	if self._localLoginCallbackTimer ~= nil then
		TimerManager.removeTimer(self._localLoginCallbackTimer)

		self._localLoginCallbackTimer = nil
	end

	if self._cloudLoginRetryTimer ~= nil then
		TimerManager.removeTimer(self._cloudLoginRetryTimer)

		self._cloudLoginRetryTimer = nil
	end

	if self._cloudLoginCallbackTimer ~= nil then
		TimerManager.removeTimer(self._cloudLoginCallbackTimer)

		self._cloudLoginCallbackTimer = nil
	end

	self._cloudLoginRetryElapsed = nil
end

function SDKManager:_finishLoginAttempt()
	self:_clearLoginTimers()

	self._loginAttemptSeq = (self._loginAttemptSeq or 0) + 1
	self._loginInProgress = false
end

function SDKManager:isLoginInProgress()
	return self._loginInProgress == true
end

function SDKManager:_startLocalLoginCallbackTimeout(seq)
	traceSDKInit("SDKManager:local login waiting callback seq=%d timeout=%ss", seq, LOCAL_LOGIN_CALLBACK_TIMEOUT_SEC)

	self._localLoginCallbackTimer = TimerManager.addTimer(LOCAL_LOGIN_CALLBACK_TIMEOUT_SEC, function()
		self._localLoginCallbackTimer = nil

		if self._loginAttemptSeq ~= seq or not self._loginInProgress then
			return
		end

		traceSDKInit("SDKManager:local login callback timeout seq=%d timeout=%ss", seq, LOCAL_LOGIN_CALLBACK_TIMEOUT_SEC)

		self.fnCallbackLogin = nil

		self:_finishLoginAttempt()
		self:invokeLoginFailedCallback()
		showSdkLoginFailedTip("LOGIN_SDK_FAILED")
	end)
end

function SDKManager:_failCloudLogin(seq, reason)
	if self._loginAttemptSeq ~= seq then
		return
	end

	traceSDKInit("SDKManager:loginFromMobile failed reason=%s", tostring(reason))
	self:_finishLoginAttempt()
	self:invokeLoginFailedCallback()
	showSdkLoginFailedTip("LOGIN_SDK_FAILED")
end

function SDKManager:_startCloudLoginCallbackTimeout(seq)
	self._cloudLoginCallbackTimer = TimerManager.addTimer(CLOUD_LOGIN_CALLBACK_TIMEOUT_SEC, function()
		self._cloudLoginCallbackTimer = nil

		if self._loginAttemptSeq ~= seq or not self._loginInProgress then
			return
		end

		self:_failCloudLogin(seq, "CallbackTimeout")
	end)
end

function SDKManager:_trySendCloudLogin(seq)
	if self._loginAttemptSeq ~= seq or not self._loginInProgress then
		return false, "Cancelled"
	end

	local ok, result = pcall(function()
		if self:isCloudSDKMode() then
			csSDKManager.SetTrackingServiceInfo({
				game_version = tostring(ClientFullVersion or "")
			})
		end

		return csSDKManager.loginFromMobile()
	end)

	if not ok then
		return false, "CallException:" .. tostring(result)
	end

	local error = result == nil and "" or tostring(result)

	if error == "" then
		traceSDKInit("SDKManager:loginFromMobile request sent after %ss", tostring(self._cloudLoginRetryElapsed or 0))
		self:_startCloudLoginCallbackTimeout(seq)

		return true, nil
	end

	return false, error
end

function SDKManager:_scheduleCloudLoginRetry(seq)
	self._cloudLoginRetryTimer = TimerManager.addTimer(CLOUD_LOGIN_PIPE_RETRY_INTERVAL_SEC, function()
		self._cloudLoginRetryTimer = nil

		if self._loginAttemptSeq ~= seq or not self._loginInProgress then
			return
		end

		self._cloudLoginRetryElapsed = (self._cloudLoginRetryElapsed or 0) + CLOUD_LOGIN_PIPE_RETRY_INTERVAL_SEC

		local started, error = self:_trySendCloudLogin(seq)

		if started then
			return
		end

		if error ~= "PipeNotConnected" then
			self:_failCloudLogin(seq, error)

			return
		end

		if self._cloudLoginRetryElapsed >= CLOUD_LOGIN_PIPE_RETRY_MAX_SEC then
			self:_failCloudLogin(seq, error)

			return
		end

		self:_scheduleCloudLoginRetry(seq)
	end)
end

function SDKManager:login()
	if self:isCloudSDKMode() then
		return self:loginFromMobile()
	end

	if self._loginInProgress then
		return false, "LoginInProgress"
	end

	if not self.isInit then
		if (pg.global.platform:isXbox() or pg.global.platform:isXboxPC() or pg.global.platform:isPS()) and SDKLoginConfig.isEnabled() then
			csSDKManager.reInitFromLua()
			refreshLoginButtonInteractable()

			return false, "SDKReinitializing"
		end

		showSdkLoginFailedTip("LOGIN_SDK_INIT_FAILED")

		return false, "SDKNotInitialized"
	end

	if SDKLoginConfig.isEnabled() then
		self:_clearLoginTimers()

		self._loginAttemptSeq = (self._loginAttemptSeq or 0) + 1

		local seq = self._loginAttemptSeq

		self._loginInProgress = true

		self:_startLocalLoginCallbackTimeout(seq)
		csSDKManager.Login()

		return true, nil
	end

	return false
end

function SDKManager:tryRefreshTicket(callback)
	if self._refreshTicket then
		logger:warn("refreshTicket already in progress, ignored")

		return
	end

	self._refreshTicket = true
	self.fnRefreshTicketCallBack = callback
	self._refreshTicketSeq = (self._refreshTicketSeq or 0) + 1

	local seq = self._refreshTicketSeq

	self._refreshTicketTimer = TimerManager.addTimer(REFRESH_TICKET_TIMEOUT_SEC, function()
		if self._refreshTicketSeq ~= seq or not self._refreshTicket then
			return
		end

		traceSDKInit("SDKManager:refreshTicket TIMEOUT seq=%d, fallback to current ticket", seq)

		self._refreshTicketTimer = nil
		self._refreshTicket = false

		self:_finishLoginAttempt()

		if self.fnRefreshTicketCallBack then
			self.fnRefreshTicketCallBack()
		end

		self.fnRefreshTicketCallBack = nil
	end)

	self:login()
end

function SDKManager:logout()
	if SDKLoginConfig.isEnabled() then
		csSDKManager.Logout()
	end
end

function SDKManager:setLanguage(langIndex)
	if SDKLoginConfig.isEnabled() then
		csSDKManager.SetLanguage(self.LANGUAGE_TYPE_MAP[langIndex])
	end
end

function SDKManager:openSchema(schema)
	csSDKManager.OpenSchema(schema)
end

function SDKManager:openUrl(mod, key, url)
	csSDKManager.XOpenUrl(mod, key, url)
end

function SDKManager:enableUploadLog(value)
	if SDKLoginConfig.isEnabled() then
		csSDKManager.EnableUploadLog(value)
	end
end

function SDKManager:isSDKMode()
	local sdkMode = false

	if SDKLoginConfig.isEnabled() then
		sdkMode = true
	end

	if ClientConfigCloudEnable == "true" and ClientConfigSDKFromMobile == "true" then
		sdkMode = true
	end

	return sdkMode
end

function SDKManager:isCloudSDKMode()
	local cloudSdkMode = false

	if ClientConfigCloudEnable == "true" and ClientConfigSDKFromMobile == "true" then
		cloudSdkMode = true
	end

	return cloudSdkMode
end

function SDKManager:isDouyinCloudChannel()
	local channelName = rawget(_G, "ClientConfigSDKChannelName")

	return channelName == "douyin_cloud" or channelName == "douyin_cloud_game"
end

function SDKManager:loginFromMobile()
	if self._loginInProgress then
		return false, "LoginInProgress"
	end

	if not SDKLoginConfig.isEnabled() then
		return false, "SDKLoginDisabled"
	end

	self:_clearLoginTimers()

	self._loginAttemptSeq = (self._loginAttemptSeq or 0) + 1

	local seq = self._loginAttemptSeq

	self._loginInProgress = true
	self._cloudLoginRetryElapsed = 0

	local started, error = self:_trySendCloudLogin(seq)

	if started then
		return true, nil
	end

	if error == "PipeNotConnected" then
		traceSDKInit("SDKManager:loginFromMobile waiting for pipe")
		self:_scheduleCloudLoginRetry(seq)

		return true, nil
	end

	self:_failCloudLogin(seq, error)

	return false, error
end

function SDKManager:onSDKInitCallback(result)
	traceSDKInit("SDKManager:onSDKInitCallback result=%s", tostring(result))
	refreshLoginButtonInteractable()

	if result == 1 then
		if self.isInit then
			traceSDKInit("SDKManager:onSDKInitCallback ignored because SDK is already initialized")
			self:invokeInitCallback(result)

			return
		end

		if ClientConfigCloudEnable == "true" then
			self:invalidateCloudSDKSessionCache()
		end

		self.isInit = true

		DiscordSocialUtils.init()

		local langIndex = pg.languageType or 0

		self:setLanguage(langIndex)
		self:enableUploadLog(true)
		self:enableCustomLog(ClientSwitch.EnableCrashSightExceptionCustomLog)
		logTrackingInfoSnapshot("onSDKInitCallback", self)
		self:tryEnableDouyinCloudScreenRecordingCompatibility()

		local loginCtrl = pg and pg.global and pg.global.ui and pg.global.ui.login

		if loginCtrl and loginCtrl.refreshAccountButtonVisible then
			loginCtrl:refreshAccountButtonVisible()
		end

		if loginCtrl and loginCtrl.refreshServiceButtonVisible then
			loginCtrl:refreshServiceButtonVisible()
		end

		if loginCtrl and loginCtrl.retryPendingShellJoinSDKLogin then
			loginCtrl:retryPendingShellJoinSDKLogin()
		end

		traceSDKInit("SDKManager:onSDKInitCallback done, waiting for LoginCtrl:onShow to start SDK login")
	elseif result == -1 then
		traceSDKInit("SDKManager:onSDKInitCallback init result -1, need reinit")
	else
		traceSDKInit("SDKManager:onSDKInitCallback ignored because result ~= 1")
	end

	self:invokeInitCallback(result)
end

function SDKManager:invokeInitCallback(result)
	local callback = self.fnCallbackInit

	self.fnCallbackInit = nil

	if callback then
		callback(result)
	end
end

function SDKManager:invokeLoginFailedCallback()
	local callback = self.fnCallbackLoginFailed

	self.fnCallbackLoginFailed = nil

	if callback then
		callback()
	end
end

function SDKManager:onSDKLoginCallback(result, fpId, ticket, accountId, sessionKey, isNew, bindInfos)
	self:_finishLoginAttempt()

	if self:refreshTicketCallBack(result, fpId, ticket, accountId, sessionKey) then
		return
	end

	if result == 1 then
		if ClientConfigCloudEnable == "true" then
			self:invalidateCloudSDKSessionCache()
		end

		local shouldConnectDiscord = not self.isLogin or self.accountId ~= accountId

		self.isLogin = true
		self.fpId = fpId
		self.ticket = ticket
		self.accountId = accountId
		self.sessionKey = sessionKey

		if isNew == true then
			self.isAccountNew = 1
		end

		self.tmpAccountId = accountId
		self.bindInfos = bindInfos or {}
		self.discordSocialAccountId = self:getSocialBindId("discord")

		self:setCrashCustomKey({
			userId = accountId
		})

		local consoleDevice = getConsoleDeviceName()

		if consoleDevice ~= nil then
			local crashCustomData = {
				consoleDevice = consoleDevice
			}
			local consolePreset = getConsolePresetName()

			if consolePreset ~= nil then
				crashCustomData.consolePreset = consolePreset
			end

			self:setCrashCustomKey(crashCustomData)
		end

		self.trackingInfo = self:getTrackingInfo()
		self.vendorUid = extractVendorUid(self.trackingInfo)

		logTrackingInfoSnapshot("onSDKLoginCallback", self)
		self:tryEnableDouyinCloudScreenRecordingCompatibility()

		if pg.global.platform and pg.global.platform.initPlatformServicesAttached then
			traceSDKInit("SDKManager:onSDKLoginCallback calling pg.global.platform:initPlatformServicesAttached")
			pg.global.platform:initPlatformServicesAttached(self.vendorUid, fpId)
		else
			traceSDKInit("SDKManager:onSDKLoginCallback platform service entry missing")
		end

		if shouldConnectDiscord then
			self:_tryPrepareDiscordConnection()
		end

		self.fnCallbackLoginFailed = nil

		if self.fnCallbackLogin ~= nil then
			local fnCallback = self.fnCallbackLogin

			self.fnCallbackLogin = nil

			fnCallback()
		end

		facade:sendMsgToUI(MessageName.SDK_LOGIN)
		csSDKManager.PatchFlowSDKLog(30007, "is_new", tostring(isNew == true), "")
		self:reportAfFunnel("af_login")
		self:reportAdFunnel("ad_login")
	else
		logger:warn("SDK login callback failed result=%s", tostring(result))
		showSdkLoginFailedTip("LOGIN_SDK_FAILED")
		self:invokeLoginFailedCallback()
		self:clear()
	end
end

function SDKManager:onPlatformAchievementAccountChanging()
	logger:info("[platform] 平台成就 account changing callback received")

	local platform = pg and pg.global and pg.global.platform

	if platform and platform.shutdownAchievementServiceForAccountChange then
		local success, result = pcall(platform.shutdownAchievementServiceForAccountChange, platform)

		if not success then
			logger:error("[platform] 平台成就 account changing shutdown failed without blocking login: %s", tostring(result))

			return
		end

		logger:info("[platform] 平台成就 account changing shutdown result=%s", tostring(result))
	end
end

function SDKManager:onPlatformAchievementAccountReady()
	logger:info("[platform] 平台成就 account ready callback received")

	local platform = pg and pg.global and pg.global.platform

	if platform and platform.restartAchievementServiceForAccountChange then
		local success, result = pcall(platform.restartAchievementServiceForAccountChange, platform)

		if not success then
			logger:error("[platform] 平台成就 account ready restart failed without blocking login: %s", tostring(result))

			return
		end

		logger:info("[platform] 平台成就 account ready restart result=%s", tostring(result))
	end
end

function SDKManager:refreshTicketCallBack(result, fpId, ticket, accountId, sessionKey)
	if self._refreshTicket then
		if self._refreshTicketTimer ~= nil then
			TimerManager.removeTimer(self._refreshTicketTimer)

			self._refreshTicketTimer = nil
		end

		if result == 1 then
			if ClientConfigCloudEnable == "true" and self.accountId ~= accountId then
				self:invalidateCloudSDKSessionCache()
			end

			self.isLogin = true
			self.fpId = fpId
			self.ticket = ticket
			self.accountId = accountId
			self.sessionKey = sessionKey
			self.tmpAccountId = accountId

			self:setCrashCustomKey({
				userId = accountId
			})

			self.trackingInfo = self:getTrackingInfo()
			self.vendorUid = extractVendorUid(self.trackingInfo)

			traceSDKInit("SDKManager:refreshTicket END newTicket{%s}", ticketFingerprint(self.ticket))
		else
			traceSDKInit("SDKManager:refreshTicket FAILED result=%s ", tostring(result))
		end

		self._refreshTicketSeq = (self._refreshTicketSeq or 0) + 1
		self._refreshTicket = false

		local cb = self.fnRefreshTicketCallBack

		self.fnRefreshTicketCallBack = nil

		if cb then
			cb()
		end

		return true
	end

	return false
end

function SDKManager:onSDKLogoutCallback(result)
	if result == 1 then
		if ClientConfigCloudEnable == "true" then
			self:invalidateCloudSDKSessionCache()
		end

		self.isLogin = false
		self.funtapCheckUserData = nil
		self.discordSocialInfoNeedsRefresh = false
		self._discordSocialInfoRequesting = false

		csSDKManager.ResetFuntapCheckUserResult()
		DiscordSocialUtils.clear()

		if self.fnCallbackLogout ~= nil then
			local fnCallback = self.fnCallbackLogout

			self.fnCallbackLogout = nil

			fnCallback()
		end

		facade:sendMsgToUI(MessageName.SDK_LOGOUT)

		self.tmpAccountId = nil

		ClientUtils.innerBackToHome()
		print("SDKManager:logout", debug.traceback())
	end
end

function SDKManager:buyProduct(params, callback)
	self.buyCallback = callback

	if ClientConfigCloudEnable == "true" then
		csXCloudPipeController.SendCloudHostFullFromLua(5002, "AppBuyReq", params)

		local testSendResp = false

		if testSendResp then
			TimerManager.addTimer(3, function()
				csXCloudPipeController.RecvCloudHostFullFromLua("{\"code\":5003,\"msg\":\"AppBuyRes\",\"SDKCode\":1}")
			end)
		end
	else
		csSDKManager.BuyProduct(params)
	end
end

function SDKManager:tryBuyProduct(productId, orderId, productName, productDesc, skuId, productIconUrl, giftUid, giftDesc, callbackUrl)
	local uid = pg.me:getCopyPlayerUid()
	local isBuy = csSDKManager.TryBuy(uid, productId, pg.me.serverArea, orderId, productName, productDesc, skuId, productIconUrl, giftUid, giftDesc, callbackUrl or "")

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("tryBuyProduct isBuy = %s self.fpId = %s productId = %s, ServerId = %s orderId = %s productName = %s productDesc = %s giftUid = %s giftDesc = %s sku_id = %s callbackUrl = %s", isBuy, uid, productId, pg.me.serverArea, orderId, productName, productDesc, giftUid, giftDesc, skuId, callbackUrl)
	end

	return isBuy
end

function SDKManager:hasBindType(bindType)
	for _, bindInfo in ipairs(self.bindInfos or EMPTY_TABLE) do
		if tonumber(bindInfo.bind_type) == bindType then
			return true
		end
	end

	return false
end

function SDKManager:canSteamBindEmail()
	return self:hasBindType(24) and not self:hasBindType(102)
end

function SDKManager:forceBindEmail()
	csSDKManager.ForceBind()
end

function SDKManager:onSDKBindCallback(result, bindInfos)
	self._discordJoinBindRequested = false

	if result == 1 then
		self.bindInfos = bindInfos or {}

		if ClientConfigCloudEnable == "true" then
			self:invalidateCloudAccountInfoCache()
		end

		facade:SendMessageCommand(MessageName.SDK_ACCOUNT_BIND_CHANGED)

		self.discordSocialAccountId = self:getSocialBindId("discord")

		self:_syncDiscordSocialAccountToServer()
		self:_requestDiscordSocialInfo()
	end
end

function SDKManager:onSDKUnbindCallback(result)
	if result == 1 then
		self._discordSocialInfoRequesting = false

		if ClientConfigCloudEnable == "true" then
			self:invalidateCloudAccountInfoCache()
		end

		facade:SendMessageCommand(MessageName.SDK_ACCOUNT_BIND_CHANGED)

		if not self:getSocialBindId("discord") then
			self.discordSocialAccountId = nil

			if pg and pg.me then
				pg.me:serverMsg("RPC_CS_UnbindSocialMediaAccount", "discord")
			end
		end
	end
end

function SDKManager:reconcilePayments(reason)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("reconcilePayments reason = %s", tostring(reason))
	end

	csSDKManager.ReconcilePayments()
end

function SDKManager:getTrackingProperties()
	local success, trackingInfo = pcall(function()
		return json.decode(self:getTrackingInfo())
	end)

	if success and Utils.isTable(trackingInfo) and Utils.isTable(trackingInfo.properties) then
		return trackingInfo.properties
	end

	return nil
end

function SDKManager:getPkgChannel()
	local properties = self:getTrackingProperties()

	if properties then
		return tostring(properties.pkg_channel or properties.channel_id or properties.sub_channel_id or "")
	end

	return ""
end

function SDKManager:getChannelId()
	local properties = self:getTrackingProperties()

	if properties then
		return tostring(properties.channel_id or "")
	end

	return ""
end

function SDKManager:isPkgChannel(channelOrSet)
	if channelOrSet == nil then
		return false
	end

	local pkgChannel = self:getPkgChannel()

	if pkgChannel == "" then
		return false
	end

	if Utils.isTable(channelOrSet) then
		return channelOrSet[pkgChannel] == true
	end

	return pkgChannel == tostring(channelOrSet)
end

function SDKManager:tryEnableDouyinCloudScreenRecordingCompatibility()
	if self:isPkgChannel(DOUYIN_CLOUD_GAME_PKG_CHANNEL) then
		CS.FunPlus.WorldX.Setting.VideoSetting.SetXRenderCompatibility(SCREEN_RECORDING_COMPATIBILITY_KEY, 1)
	end
end

function SDKManager:canOpenHelpCenter()
	if ClientConfigGameChannelName == "taiwan" or UNITY_OPENHARMONY then
		return false
	end

	return not self:isPkgChannel(HELP_CENTER_DISABLED_PKG_CHANNELS)
end

function SDKManager:initFunStore(params, backupDomains)
	self.funStoreConfig = nil
	self.funStoreEnabled = false
	self.funStoreInitIdentity = {
		uid = tostring(params.uid),
		accountId = tostring(params.account_id)
	}
	params.extend = params.extend or {}
	params.extend.pkg_channel = self:getPkgChannel()

	csSDKManager.InitFunStore(params, backupDomains or {})
end

function SDKManager:openFunStore(params, roleId, gameProject, language)
	params.extend.pkg_channel = self:getPkgChannel()

	local config = self.funStoreConfig or {}

	csSDKManager.OpenFunStore(params, tostring(roleId or ""), self.accountId or "", gameProject, language, config.pay_open_method or "", config.web_payment_methods_display_type or "")
end

function SDKManager:onSDKFunStoreInitCallback(result)
	local identity = self.funStoreInitIdentity

	self.funStoreInitIdentity = nil

	local currentUid = pg and pg.me and tostring(pg.me.uid) or nil
	local currentAccountId = tostring(self.accountId)

	if not identity or currentUid ~= identity.uid or currentAccountId ~= identity.accountId then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("initFunStore ignored stale callback")
		end

		return
	end

	local success, response = pcall(json.decode, result)

	if not success or not Utils.isTable(response) then
		self.funStoreConfig = nil
		self.funStoreEnabled = false

		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("initFunStore result parse failed")
		end

		return
	end

	local config = Utils.isTable(response.data) and response.data or nil

	self.funStoreConfig = config
	self.funStoreEnabled = tonumber(response.code) == 1 and config ~= nil and config.status == "open"

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("initFunStore callback code=%s status=%s enabled=%s", tostring(response.code), tostring(config and config.status), tostring(self.funStoreEnabled))
	end
end

function SDKManager:onSDKFunStoreOpenCallback(result)
	local recharge = pg.game and pg.game.recharge
	local isForcedDirectBuyChannel = recharge and recharge:isForcedDirectBuyChannel()
	local success, response = pcall(json.decode, result)

	if not success or not Utils.isTable(response) then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("openFunStore result parse failed")
		end

		if recharge and not isForcedDirectBuyChannel then
			recharge:resetState()
		end

		return
	end

	local data = Utils.isTable(response.data) and response.data or nil

	if not recharge then
		return
	end

	local payType = tonumber(response.code) == 1 and data and tonumber(data.payType) or nil

	if payType == 1 then
		recharge:onFunStoreFallbackToIap(data.productId)
	elseif not isForcedDirectBuyChannel then
		recharge:resetState(payType ~= nil and payType >= 2)
	end
end

function SDKManager:getFunStoreConfig()
	return self.funStoreConfig
end

function SDKManager:isFunStoreEnabled()
	return self.funStoreEnabled
end

function SDKManager:onSDKPayCallback(resCode)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("@zqd SDK 充值回调: " .. tostring(resCode))
	end

	if self.buyCallback then
		self.buyCallback(resCode)
	end

	self.buyCallback = nil
end

function SDKManager:enterGame(uid, roleName, lv, vipLv, serverId, serverName, roleCreateTime)
	self:_flushPendingDiscordJoin()
	self:_syncDiscordSocialAccountToServer()

	if pg.global.UWAGPMManager then
		pg.global.UWAGPMManager:setUserInfo(uid, lv)
	end

	local YiDunUtils = require("SDK.YiDunUtils")
	local yidunRoleInfo = {
		roleId = tostring(uid or "0"),
		roleName = roleName or "unknown",
		roleServer = serverName or "default_server",
		serverId = tonumber(serverId) or 1,
		roleLevel = tonumber(lv) or 1,
		roleAccount = self.accountId
	}

	YiDunUtils.setRoleInfo(yidunRoleInfo)

	if not SDKLoginConfig.isEnabled() then
		return
	end

	if self.fpId == self._lastEnterGameFpId then
		return
	end

	self._lastEnterGameFpId = self.fpId

	csSDKManager.EnterGame(self.fpId, uid, roleName, lv, vipLv, serverId, serverName, roleCreateTime)
	self:setCrashCustomKey({
		roleName = roleName,
		uid = uid,
		lv = lv,
		serverId = serverId,
		serverName = serverName,
		gameserver_id = serverId
	})
end

function SDKManager:loginGameCenter()
	if SDKLoginConfig.isEnabled() then
		csSDKManager.LoginGameCenter()
	end
end

function SDKManager:onSDKLoginGameCenterCallback(code, isAuth)
	return
end

function SDKManager:createRole(uid, roleName, lv, vipLv, serverId, serverName, roleCreateTime)
	if SDKLoginConfig.isEnabled() then
		csSDKManager.CreateRole(uid, roleName, lv, vipLv, serverId, serverName, roleCreateTime)
	end
end

function SDKManager:onSDKFPXPayBuyCallBack(result, eventName, callbackResponseCode, callbackResponseMessage)
	if result ~= 1 and eventName == "reconcile" then
		if tonumber(callbackResponseCode) == 120007 then
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				logger:debug("payment reconcile found no valid receipt code=%s msg=%s", tostring(callbackResponseCode), tostring(callbackResponseMessage))
			end
		else
			logger:warn("payment reconcile callback failed result=%s code=%s msg=%s", tostring(result), tostring(callbackResponseCode), tostring(callbackResponseMessage))
		end

		return
	end

	logger:info("onSDKFPXPayBuyCallBack result = %s", result)
	pg.game.recharge:onPayCallback(result)
end

function SDKManager:crashTest()
	csSDKManager.CrashTest()
end

function SDKManager:setUserId(userId)
	csSDKManager.SetUserId(userId)
end

function SDKManager:setCrashCustomKey(dataTable)
	csSDKManager.SetCrashCustomKey(dataTable)
end

function SDKManager:openUserCenter()
	if SDKLoginConfig.isEnabled() or ClientConfigCloudEnable == "true" and ClientConfigSDKFromMobile == "true" then
		csSDKManager.OpenUserCenter()
	elseif self.isLogin then
		self:logout()
	else
		self:login()
	end
end

function SDKManager:hasUserCenter()
	return csSDKManager.HasUserCenter()
end

function SDKManager:OpenHelpCenter(params)
	csSDKManager.OpenHelpCenter(params)
end

function SDKManager:OpenCustomerServiceCenter()
	if csSDKManager then
		csSDKManager.OpenCustomerServiceCenter()
	end
end

function SDKManager:OpenZCChat(isOverseas)
	if csSDKManager then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("@wkq SDK isOverseas: " .. tostring(isOverseas))
		end

		csSDKManager.OpenZCChat(isOverseas)
	end
end

function SDKManager:tracking(eventName, eventType, dataTable)
	csSDKManager.Tracking(eventName, eventType, dataTable)
end

function SDKManager:reportAfFunnel(eventName, extra)
	if not SDKLoginConfig.isEnabled() then
		return
	end

	extra = extra or {}

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("[AF] report event=" .. tostring(eventName))
	end

	if Utils.isOverseas() then
		csSDKManager.Tracking(eventName, 2, extra)
	end
end

function SDKManager:reportAdFunnel(eventName, extra)
	if not IS_MOBILE or not SDKLoginConfig.isEnabled() then
		return
	end

	extra = extra or {}

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("[AD] report event=" .. tostring(eventName))
	end

	if Utils.isOverseas() then
		csSDKManager.Tracking(eventName, 2, extra)
	end
end

function SDKManager:getTrackingInfo()
	if SDKLoginConfig.isEnabled() then
		return csSDKManager.GetTrackingInfo()
	else
		TiktokData.launch_id = IDManager.genB64ID()

		return json.encode(TiktokData)
	end
end

function SDKManager:getDeviceData()
	if not SDKLoginConfig.isEnabled() then
		return ""
	end

	if ClientConfigCloudEnable ~= "true" then
		return csSDKManager.GetDeviceData()
	end

	if self._cloudDeviceDataResolved then
		return self._cloudDeviceData or ""
	end

	local now = Time.getTickSecond()

	if self._cloudDeviceDataRetryAt and now < self._cloudDeviceDataRetryAt then
		return ""
	end

	local requestSuccess, deviceData = pcall(csSDKManager.GetDeviceData)

	if not requestSuccess or string.isNilOrEmpty(deviceData) then
		self._cloudDeviceDataRetryAt = Time.getTickSecond() + DEVICE_DATA_RETRY_INTERVAL

		if not self._cloudDeviceDataFailureLogged then
			logger:warn("GetDeviceData failed or returned empty: %s", tostring(deviceData))

			self._cloudDeviceDataFailureLogged = true
		end

		return ""
	end

	local decodeSuccess, decodedDeviceData = pcall(json.decode, deviceData)

	if not decodeSuccess or not Utils.isTable(decodedDeviceData) then
		self._cloudDeviceDataRetryAt = Time.getTickSecond() + DEVICE_DATA_RETRY_INTERVAL

		if not self._cloudDeviceDataFailureLogged then
			logger:warn("GetDeviceData parse failed")

			self._cloudDeviceDataFailureLogged = true
		end

		return deviceData
	end

	self._cloudDeviceData = deviceData
	self._cloudDeviceDataResolved = true
	self._cloudDeviceDataRetryAt = nil
	self._cloudDeviceDataFailureLogged = false

	return self._cloudDeviceData
end

function SDKManager:trackWeGame(action, status, ext)
	csSDKManager.TrackWeGame(action, status, ext)
end

function SDKManager:getWeGameDistributeId()
	return csSDKManager.GetWeGameDistributeID()
end

function SDKManager:isSupportNavigateToSidebar()
	return csSDKManager.IsSupportNavigateToSidebar()
end

function SDKManager:navigateToSidebar()
	csSDKManager.NavigateToSidebar()
end

function SDKManager:isFromSidebar()
	return csSDKManager.IsFromSidebar()
end

function SDKManager:onSidebarFocusIn()
	self.sidebarFocusData = csSDKManager.GetSidebarFocusTable()
	self.conversationShortId = self.sidebarFocusData.conversationShortId

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		local data = self.sidebarFocusData

		logger:info("[Sidebar] focusIn isFromSidebar=%s isLaunch=%s scene=%s feedGameChannel=%s", tostring(data.isFromSidebar), tostring(data.isLaunch), tostring(data.scene), tostring(data.feedGameChannel))
	end

	self:tryEnterFeedScene("focusInCallback")
end

function SDKManager:getSidebarFocusData()
	return self.sidebarFocusData
end

function SDKManager:getIsFromSidebar()
	return self.sidebarFocusData ~= nil and self.sidebarFocusData.isFromSidebar == true
end

function SDKManager:getConversationShortId()
	if self.conversationShortId ~= nil then
		return self.conversationShortId
	end

	local success, conversationShortId = pcall(function()
		return csSDKManager.GetSidebarFocusTable().conversationShortId
	end)

	if success then
		return conversationShortId
	end
end

function SDKManager:getLaunchOptionsSync()
	return csSDKManager.GetLaunchOptionsSync()
end

function SDKManager:requestLaunchOptions()
	pcall(function()
		if csSDKManager.RequestLaunchOptions then
			csSDKManager.RequestLaunchOptions()
		end
	end)
end

function SDKManager:onLaunchOptions(code, data)
	if code == 1 then
		self.conversationShortId = data and data.conversationShortId or ""
	end
end

function SDKManager:reportScene(scene)
	logger:info("[reportScene] scene=%s costSinceLaunch=%.2fs", tostring(scene), Time.realtimeSinceStartup)
	csSDKManager.ReportScene(scene)
end

function SDKManager:showWebView(parameters, callback)
	self.fnCallbackWebViewClosed = callback

	csSDKManager.ShowWebView(parameters)
end

function SDKManager:closeWebView()
	csSDKManager.CloseWebView()
end

function SDKManager:onSDKWebViewClosedCallback(result)
	local callback = self.fnCallbackWebViewClosed

	self.fnCallbackWebViewClosed = nil

	if callback then
		callback(result)
	end
end

function SDKManager:qrcodeLogin()
	csSDKManager.QrcodeLogin()
end

function SDKManager:onSDKQrcodeLoginCallback(result)
	local success, response = pcall(json.decode, result)

	if not success or not Utils.isTable(response) then
		return
	end

	local tipKey
	local code = tonumber(response.code)

	if code == 1 then
		tipKey = "SCAN_QA_TIPS1"
	elseif code == -2 then
		tipKey = "SCAN_QA_TIPS2"
	elseif code == -3 then
		tipKey = "SCAN_QA_TIPS3"
	end

	if tipKey then
		pg.global.showBubbleMessageRaw(pg.getGameString(tipKey), 3)
	end
end

function SDKManager:getIsFeedScene()
	if not SDKLoginConfig.isEnabled() then
		return false
	end

	local data = csSDKManager.GetSidebarFocusTable()

	logger:info("[getIsFeedScene] isLaunch = %s feedGameChannel = %s", data.isLaunch, data.feedGameChannel)

	return data ~= nil and data.feedGameChannel == 2
end

function SDKManager:tryEnterFeedScene(source)
	if not self:getIsFeedScene() then
		return false
	end

	if pg.game ~= nil and pg.game.tryEnterFeedScene ~= nil then
		return pg.game:tryEnterFeedScene(source)
	end

	return true
end

function SDKManager:onFeedStatusChange(status)
	self.feedStatusCache = status

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("[FeedGame] feedStatusChange status=%s", tostring(status))
	end
end

function SDKManager:getFeedStatus()
	return self.feedStatusCache
end

function SDKManager:onClientIPInfo()
	self.clientIPInfoData = csSDKManager.GetClientIPInfoTable()

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		local data = self.clientIPInfoData

		logger:info("[ClientIPInfo] code=%s ip=%s country=%s continent=%s", tostring(data.code), tostring(data.ip), tostring(data.country), tostring(data.continent))
	end
end

function SDKManager:getClientIPInfoData()
	return self.clientIPInfoData
end

function SDKManager:isClientIPCountry(country)
	return csSDKManager.IsClientIPCountry(country)
end

function SDKManager:funtapCheckUser()
	self.funtapCheckUserData = nil

	csSDKManager.ResetFuntapCheckUserResult()
	csSDKManager.FuntapCheckUser()
end

function SDKManager:funtapCallB()
	csSDKManager.FuntapCallB()
end

function SDKManager:isTapTapStoreEnabled()
	return csSDKManager.IsTapTapStoreEnabled()
end

function SDKManager:openTapTapStore()
	csSDKManager.OpenTapTapStore()
end

function SDKManager:getTapTapStoreGrade()
	csSDKManager.GetTapTapStoreGrade()
end

function SDKManager:checkTapTapUpdate()
	csSDKManager.CheckTapTapUpdate()
end

function SDKManager:onFuntapCheckUser()
	self.funtapCheckUserData = csSDKManager.GetFuntapCheckUserTable()

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		local data = self.funtapCheckUserData

		logger:info("[Funtap] checkUser code=%s uid=%s hasUserInfo=%s", tostring(data.code), tostring(data.uid), tostring(data.userInfo ~= nil))
	end
end

function SDKManager:getFuntapCheckUserData()
	return self.funtapCheckUserData
end

function SDKManager:getVendorUid()
	return self.vendorUid
end

function SDKManager:getSessionKey()
	return self.sessionKey
end

function SDKManager:isOverseasWithoutPS()
	return pg.global.platform:isOverseasWithoutPS()
end

function SDKManager:enableCustomLog(value)
	csSDKManager.SetCrashSightExceptionCustomLogEnabled(value == true)
end

function SDKManager:registerClientSwitchChangedListener()
	self:unregisterClientSwitchChangedListener()

	local emitter = pg and pg.global and pg.global.eventEmitter

	if emitter == nil or emitter.addEventListener == nil then
		return
	end

	function self._clientSwitchChangedListener(name, value)
		self:onClientSwitchChanged(name, value)
	end

	self._clientSwitchChangedEmitter = emitter

	emitter:addEventListener(EventConst.CLIENT_SWITCH_CHANGED, self._clientSwitchChangedListener)
end

function SDKManager:unregisterClientSwitchChangedListener()
	local emitter = self._clientSwitchChangedEmitter
	local listener = self._clientSwitchChangedListener

	if emitter ~= nil and emitter.removeEventListener ~= nil and listener ~= nil then
		emitter:removeEventListener(EventConst.CLIENT_SWITCH_CHANGED, listener)
	end

	self._clientSwitchChangedEmitter = nil
	self._clientSwitchChangedListener = nil
end

function SDKManager:onClientSwitchChanged(name, value)
	if name == "EnableCrashSightExceptionCustomLog" then
		self:enableCustomLog(value)
	end
end

function SDKManager:isDiscordBound()
	local accountData = self:getAccountInfoData()

	if not accountData then
		return nil
	end

	for _, bind in ipairs(accountData.social_bind or EMPTY_TABLE) do
		if bind.social_type == "discord" then
			return true
		end
	end

	return false
end

function SDKManager:_decodeSocialInfoResult(result, callbackName)
	if string.isNilOrEmpty(result) then
		logger:warn("%s returned empty result", callbackName)

		return nil
	end

	local success, response = pcall(json.decode, result)

	if not success or not Utils.isTable(response) then
		logger:warn("%s result parse failed", callbackName)

		return nil
	end

	return response
end

function SDKManager:_connectDiscordWithSocialInfo(socialInfo)
	local accessToken = Utils.isTable(socialInfo) and socialInfo.access_token or nil

	if string.isNilOrEmpty(accessToken) then
		logger:warn("Discord social info returned no access_token")

		return false
	end

	local expireAt = tonumber(socialInfo.expire_at)

	logger:info("[DiscordSocial] credential received socialType=%s socialId=%s tokenLength=%s expireAt=%s expiresIn=%s", tostring(socialInfo.social_type or ""), tostring(socialInfo.social_id or ""), tostring(#accessToken), tostring(expireAt or ""), tostring(expireAt and expireAt - os.time() or ""))

	if not DiscordSocialUtils.init() then
		return false
	end

	return DiscordSocialUtils.connectWithToken(accessToken)
end

function SDKManager:_notifyDiscordSocialInfoUpdated(success, state, code, message)
	facade:SendMessageCommand(MessageName.DISCORD_SOCIAL_INFO_UPDATED, {
		success = success == true,
		state = state or "failed",
		code = tonumber(code) or 0,
		message = message or ""
	})
end

function SDKManager:_prepareDiscordConnection()
	local isDiscordBound = self:isDiscordBound()

	if isDiscordBound == nil then
		return
	end

	if isDiscordBound then
		if not self.discordSocialInfoNeedsRefresh then
			self:_requestDiscordSocialInfo()
		end

		return
	end

	if not string.isNilOrEmpty(self._pendingDiscordJoinSecret) and not self._discordJoinBindRequested then
		self._discordJoinBindRequested = true

		self:bindSocial("discord")
		logger:info("Discord invite detected for an unbound account; binding requested")
	end
end

function SDKManager:_tryPrepareDiscordConnection()
	local success, errorMessage = pcall(self._prepareDiscordConnection, self)

	if not success then
		self._discordJoinBindRequested = false

		logger:error("Discord connection preparation failed without blocking game flow: %s", tostring(errorMessage))
	end
end

function SDKManager:_flushPendingDiscordJoin()
	if not pg or not pg.me or string.isNilOrEmpty(self._pendingDiscordJoinSecret) or type(self._discordJoinCallback) ~= "function" then
		return false
	end

	if not DiscordSocialUtils.isReady() then
		return false
	end

	local pendingSecret = self._pendingDiscordJoinSecret

	self._pendingDiscordJoinSecret = nil

	local callbackSuccess, callbackError = pcall(self._discordJoinCallback, pendingSecret)

	if not callbackSuccess then
		self._pendingDiscordJoinSecret = pendingSecret

		logger:error("Discord Join callback failed: %s", tostring(callbackError))

		return false
	end

	return true
end

function SDKManager:onDiscordStatusChanged(status, errorMessage, errorDetail)
	facade:SendMessageCommand(MessageName.DISCORD_STATUS_CHANGED, {
		status = status or "",
		isReady = status == "Ready",
		errorMessage = errorMessage or "",
		errorDetail = errorDetail or ""
	})

	if status == "Ready" then
		self:_flushPendingDiscordJoin()
	end
end

function SDKManager:onDiscordFriendsUpdated(snapshot)
	snapshot = snapshot or DiscordSocialUtils.getFriendSnapshot()

	facade:SendMessageCommand(MessageName.DISCORD_FRIENDS_UPDATED, snapshot)

	return snapshot
end

function SDKManager:onDiscordRichPresenceUpdated(success, errorMessage)
	facade:SendMessageCommand(MessageName.DISCORD_RICH_PRESENCE_UPDATED, {
		success = success == true,
		errorMessage = errorMessage or ""
	})
end

function SDKManager:onDiscordInviteSent(success, targetUserId, errorMessage)
	facade:SendMessageCommand(MessageName.DISCORD_INVITE_SENT, {
		success = success == true,
		targetUserId = tostring(targetUserId or ""),
		errorMessage = errorMessage or ""
	})
end

function SDKManager:setDiscordJoinCallback(callback)
	self._discordJoinCallback = callback

	self:_flushPendingDiscordJoin()
end

function SDKManager:onDiscordActivityJoin(joinSecret)
	if string.isNilOrEmpty(joinSecret) then
		logger:warn("Ignored empty Discord Join secret")

		return
	end

	self._pendingDiscordJoinSecret = joinSecret

	if self.isLogin and not DiscordSocialUtils.isReady() then
		self:_tryPrepareDiscordConnection()
	end

	self:_flushPendingDiscordJoin()
end

function SDKManager:clearDiscordJoinCallback()
	self._discordJoinCallback = nil
	self._pendingDiscordJoinSecret = nil
	self._discordJoinBindRequested = false
end

function SDKManager:setDiscordAuthorizationCallbacks(onComplete, onFailed)
	self._discordAuthorizationCallbacks = {
		onComplete = onComplete,
		onFailed = onFailed
	}
end

function SDKManager:onDiscordAuthorizationComplete(code, verifier, redirectUri)
	local callbacks = self._discordAuthorizationCallbacks

	if callbacks and type(callbacks.onComplete) == "function" then
		callbacks.onComplete(code, verifier, redirectUri)
	end
end

function SDKManager:onDiscordAuthorizationFailed(errorMessage)
	local callbacks = self._discordAuthorizationCallbacks

	if callbacks and type(callbacks.onFailed) == "function" then
		callbacks.onFailed(errorMessage)
	end
end

function SDKManager:clearDiscordAuthorizationCallbacks()
	self._discordAuthorizationCallbacks = nil
end

function SDKManager:_syncDiscordSocialAccountToServer()
	if not pg or not pg.me then
		return
	end

	if string.isNilOrEmpty(self.discordSocialAccountId) then
		pg.me:serverMsg("RPC_CS_UnbindSocialMediaAccount", "discord")

		return
	end

	pg.me:serverMsg("RPC_CS_BindSocialMediaAccount", "discord", self.discordSocialAccountId)
end

function SDKManager:onSDKGetSocialInfoCallback(result)
	self._discordSocialInfoRequesting = false

	if not self.isLogin then
		return
	end

	local response = self:_decodeSocialInfoResult(result, "getSocialInfo")

	if not response then
		self:_notifyDiscordSocialInfoUpdated(false, "failed", 0, "getSocialInfo result parse failed")

		return
	end

	local code = tonumber(response.code) or 0

	if code == 1 then
		local socialId = Utils.isTable(response.data) and tostring(response.data.social_id or "") or ""

		if string.isNilOrEmpty(self.discordSocialAccountId) or not string.isNilOrEmpty(socialId) and socialId ~= self.discordSocialAccountId then
			logger:warn("Ignored stale Discord social info callback socialId=%s", socialId)

			return
		end

		self.discordSocialInfoNeedsRefresh = false

		local requested = self:_connectDiscordWithSocialInfo(response.data)

		self:_notifyDiscordSocialInfoUpdated(requested, requested and "connecting" or "failed", code, response.msg)
	elseif code == 130004 then
		self.discordSocialInfoNeedsRefresh = true

		logger:warn("Discord social authorization needs refresh")
		self:_notifyDiscordSocialInfoUpdated(false, "authorization_required", code, response.msg)
	else
		logger:warn("getSocialInfo failed code=%s msg=%s", tostring(code), tostring(response.msg or ""))
		self:_notifyDiscordSocialInfoUpdated(false, "failed", code, response.msg)
	end
end

function SDKManager:_requestDiscordSocialInfo()
	if self._discordSocialInfoRequesting then
		return true, "refreshing"
	end

	self._discordSocialInfoRequesting = true

	logger:info("[DiscordSocial] requesting getSocialInfo")

	local requestSuccess, requestError = pcall(csSDKManager.GetSocialInfo, "discord")

	if not requestSuccess then
		self._discordSocialInfoRequesting = false

		logger:error("[DiscordSocial] getSocialInfo request failed: %s", tostring(requestError))

		return false, "failed"
	end

	return true, "refreshing"
end

function SDKManager:ensureDiscordTokenValid()
	if not self.isLogin then
		logger:warn("[DiscordSocial] getSocialInfo skipped: not logged in")

		return false, "not_logged_in"
	end

	local isDiscordBound = self:isDiscordBound()

	if isDiscordBound == nil then
		logger:warn("[DiscordSocial] getSocialInfo skipped: account info unavailable")

		return false, "failed"
	end

	if not isDiscordBound then
		logger:warn("[DiscordSocial] getSocialInfo skipped: Discord is not bound")

		return false, "not_bound"
	end

	if self.discordSocialInfoNeedsRefresh then
		logger:warn("[DiscordSocial] getSocialInfo skipped: authorization refresh required")

		return false, "authorization_required"
	end

	return self:_requestDiscordSocialInfo()
end

function SDKManager:refreshDiscordSocialInfo()
	if not self.isLogin then
		return false
	end

	local requestSuccess, requestError = pcall(csSDKManager.RefreshSocial, "discord")

	if not requestSuccess then
		logger:error("[DiscordSocial] refreshSocial request failed: %s", tostring(requestError))

		return false
	end

	return true
end

function SDKManager:onSDKRefreshSocialCallback(result)
	if not self.isLogin then
		return
	end

	local response = self:_decodeSocialInfoResult(result, "refreshSocial")

	if not response then
		self:_notifyDiscordSocialInfoUpdated(false, "failed", 0, "refreshSocial result parse failed")

		return
	end

	local code = tonumber(response.code) or 0

	if code == 1 then
		self.discordSocialInfoNeedsRefresh = false

		local requested = self:_connectDiscordWithSocialInfo(response.data)

		self:_notifyDiscordSocialInfoUpdated(requested, requested and "connecting" or "failed", code, response.msg)
	else
		logger:warn("refreshSocial failed code=%s msg=%s", tostring(code), tostring(response.msg or ""))
		self:_notifyDiscordSocialInfoUpdated(false, "failed", code, response.msg)
	end
end

function SDKManager:getAccountInfoData()
	if ClientConfigCloudEnable == "true" then
		local accountId = tostring(self.accountId or "")

		if self._cloudAccountInfoAccountId ~= accountId then
			self:invalidateCloudAccountInfoCache()

			self._cloudAccountInfoAccountId = accountId
		end

		if self._cloudAccountInfoResolved then
			return self._cloudAccountInfoData
		end

		local now = Time.getTickSecond()

		if self._cloudAccountInfoRetryAt and now < self._cloudAccountInfoRetryAt then
			return nil
		end
	end

	local requestSuccess, accountInfo = pcall(csSDKManager.GetAccountInfo)

	if not requestSuccess then
		if ClientConfigCloudEnable ~= "true" or not self._cloudAccountInfoFailureLogged then
			logger:error("GetAccountInfo failed: %s", tostring(accountInfo))
		end

		if ClientConfigCloudEnable == "true" then
			self._cloudAccountInfoRetryAt = Time.getTickSecond() + ACCOUNT_INFO_RETRY_INTERVAL
			self._cloudAccountInfoFailureLogged = true
		end

		return nil
	end

	if string.isNilOrEmpty(accountInfo) then
		if ClientConfigCloudEnable == "true" then
			self._cloudAccountInfoRetryAt = Time.getTickSecond() + ACCOUNT_INFO_RETRY_INTERVAL

			if not self._cloudAccountInfoFailureLogged then
				logger:warn("GetAccountInfo returned empty")

				self._cloudAccountInfoFailureLogged = true
			end
		end

		return nil
	end

	local success, accountData = pcall(json.decode, accountInfo)

	if not success or not Utils.isTable(accountData) then
		if ClientConfigCloudEnable ~= "true" or not self._cloudAccountInfoFailureLogged then
			logger:warn("GetAccountInfo parse failed")
		end

		if ClientConfigCloudEnable == "true" then
			self._cloudAccountInfoRetryAt = Time.getTickSecond() + ACCOUNT_INFO_RETRY_INTERVAL
			self._cloudAccountInfoFailureLogged = true
		end

		return nil
	end

	if ClientConfigCloudEnable == "true" then
		self._cloudAccountInfoData = accountData
		self._cloudAccountInfoResolved = true
		self._cloudAccountInfoRetryAt = nil
		self._cloudAccountInfoFailureLogged = false
	end

	return accountData
end

function SDKManager:getSocialBindInfo(socialType)
	local accountData = self:getAccountInfoData()

	if not accountData then
		return false, nil
	end

	for _, bindInfo in ipairs(accountData.social_bind or EMPTY_TABLE) do
		if bindInfo.social_type == socialType then
			local socialInfo = bindInfo.social_info

			if not Utils.isTable(socialInfo) then
				return false, nil
			end

			local displayText = socialInfo.email

			if string.isNilOrEmpty(displayText) then
				displayText = socialInfo.name
			end

			local var_156_0 = true

			if string.isNilOrEmpty(displayText) then
				-- block empty
			end

			return var_156_0, (tostring(displayText))
		end
	end

	return false, nil
end

function SDKManager:getSocialBindId(socialType)
	local accountData = self:getAccountInfoData()

	if not accountData then
		return nil
	end

	for _, bindInfo in ipairs(accountData.social_bind or EMPTY_TABLE) do
		if bindInfo.social_type == socialType then
			local socialInfo = bindInfo.social_info

			if not Utils.isTable(socialInfo) then
				return nil
			end

			local bindValue = socialType == "email" and socialInfo.email or socialInfo.id

			if string.isNilOrEmpty(bindValue) then
				-- block empty
			end

			return (tostring(bindValue))
		end
	end

	return nil
end

function SDKManager:invalidateCloudAccountInfoCache()
	if ClientConfigCloudEnable ~= "true" then
		return
	end

	self._cloudAccountInfoData = nil
	self._cloudAccountInfoResolved = false
	self._cloudAccountInfoRetryAt = nil
	self._cloudAccountInfoFailureLogged = false
	self._cloudAccountInfoAccountId = nil
end

function SDKManager:invalidateCloudDeviceDataCache()
	if ClientConfigCloudEnable ~= "true" then
		return
	end

	self._cloudDeviceData = nil
	self._cloudDeviceDataResolved = false
	self._cloudDeviceDataRetryAt = nil
	self._cloudDeviceDataFailureLogged = false
end

function SDKManager:invalidateCloudSDKSessionCache()
	if ClientConfigCloudEnable ~= "true" then
		return
	end

	self:invalidateSocialTypeSupportCache()
	self:invalidateCloudAccountInfoCache()
	self:invalidateCloudDeviceDataCache()
end

function SDKManager:invalidateSocialTypeSupportCache()
	if ClientConfigCloudEnable ~= "true" then
		return
	end

	self._socialTypeSupportSet = nil
	self._socialTypeSupportResolved = false
	self._socialTypeSupportRetryAt = nil
	self._socialTypeSupportFailureLogged = false
end

function SDKManager:getSupportedSocialTypeSet()
	if ClientConfigCloudEnable ~= "true" then
		return nil
	end

	if self._socialTypeSupportResolved then
		return self._socialTypeSupportSet
	end

	local now = Time.getTickSecond()

	if self._socialTypeSupportRetryAt and now < self._socialTypeSupportRetryAt then
		return nil
	end

	local requestSuccess, socialList = pcall(csSDKManager.GetSocialList)

	if not requestSuccess or string.isNilOrEmpty(socialList) then
		self._socialTypeSupportRetryAt = Time.getTickSecond() + SOCIAL_TYPE_SUPPORT_RETRY_INTERVAL

		if not self._socialTypeSupportFailureLogged then
			logger:warn("GetSocialList failed or returned empty")

			self._socialTypeSupportFailureLogged = true
		end

		return nil
	end

	local decodeSuccess, supportedTypes = pcall(json.decode, socialList)

	if not decodeSuccess or not Utils.isTable(supportedTypes) then
		self._socialTypeSupportRetryAt = Time.getTickSecond() + SOCIAL_TYPE_SUPPORT_RETRY_INTERVAL

		if not self._socialTypeSupportFailureLogged then
			logger:warn("GetSocialList parse failed")

			self._socialTypeSupportFailureLogged = true
		end

		return nil
	end

	local supportedTypeSet = {}

	for _, supportedType in pairs(supportedTypes) do
		supportedTypeSet[supportedType] = true
	end

	self._socialTypeSupportSet = supportedTypeSet
	self._socialTypeSupportResolved = true
	self._socialTypeSupportRetryAt = nil
	self._socialTypeSupportFailureLogged = false

	return self._socialTypeSupportSet
end

function SDKManager:isSocialTypeSupported(socialType)
	if string.isNilOrEmpty(socialType) then
		return false
	end

	if ClientConfigCloudEnable ~= "true" then
		local socialList = csSDKManager.GetSocialList()

		if string.isNilOrEmpty(socialList) then
			return false
		end

		local success, supportedTypes = pcall(json.decode, socialList)

		if not success or not Utils.isTable(supportedTypes) then
			logger:warn("GetSocialList parse failed")

			return false
		end

		return table.contains(supportedTypes, socialType)
	end

	local supportedTypeSet = self:getSupportedSocialTypeSet()

	return supportedTypeSet ~= nil and supportedTypeSet[socialType] == true
end

function SDKManager:bindSocial(socialType)
	csSDKManager.BindSocial(socialType)
end

function SDKManager:unbindSocial(socialType)
	csSDKManager.UnbindSocial(socialType)
end

return SDKManager
