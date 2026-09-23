-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\LoginAgent.lua

local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local LoggerManager = require("Core.Log.LoggerManager")
local TimerManager = require("Core.Timer.TimerManager")
local ClientRepo = require("Core.Client.ClientRepo")
local CallbackHandler = require("Core.Common.CallbackHandler")
local GlobalData = require("Core.Client.GlobalData")
local lume = require("Core.Common.lume")
local Switch = require("Core.Common.Switch")
local ClientUtils = require("Utils.ClientUtils")
local SysConfigData = require("Data.sys_config_data")
local ServiceUtils = require("Common.Utils.ServiceUtils")
local Utils = require("Common.Utils.Utils")
local GameVersion = require("Common.GameVersion")
local ConfigVersion = require("Common.ConfigVersion")
local Const = require("Common.Const.Const")
local DefaultSceneConst = require("Common.Const.DefaultSceneConst")
local NoticeDef = require("Common.NoticeDef")
local IDManager = require("Core.Common.IDManager")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local PlatformEntryPrivilegeService = require("SDK.Platform.PlatformEntryPrivilegeService")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local SDKLoginConfig = require("SDK.SDKLoginConfig")
local PlatformShellActivityService = require("SDK.Platform.PlatformShellActivityService")
local logger = LoggerManager.getLogger("LoginAgent")
local csSDKManager = CS.FunPlus.WorldX.SDK.SDKManager
local LuaCSConst = require("Common.Const.LuaCSConst")
local ClientXPartUtil = require("Utils.ClientXPartUtil")
local json = require("json")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local AUTH_REFRESH_INTERVAL = 3600
local LoginAgent = class.Class("LoginAgent")

function LoginAgent:ctor()
	self.conf = {}
	self.queueNotifyCount = 0
	self.pullServerInfoTimer = nil
	self._authRefreshTimer = nil
	self._bindGlobalMsGateTimer = nil
	self._bindGlobalExtraMsGateTimer = nil
	self._needLastScene = false

	if EnableBotTest then
		self.botDefaultSceneId = nil
	end
end

function LoginAgent:init()
	self.conf = ClientRepo.confJson or {}

	self:_startAuthRefreshTimer()

	return true
end

function LoginAgent:_startAuthRefreshTimer()
	if self._authRefreshTimer then
		TimerManager.removeTimer(self._authRefreshTimer)
	end

	self._authRefreshTimer = TimerManager.addRepeatTimer(AUTH_REFRESH_INTERVAL, function()
		if GlobalData.Player and GlobalData.Player.refreshAuth then
			GlobalData.Player:refreshAuth()
		end
	end)
end

function LoginAgent:_showLoginFailedTip(textKey)
	local ui = pg and pg.global and pg.global.ui
	local avatarLoading = ui and ui.avatarLoading

	if avatarLoading and avatarLoading.close then
		avatarLoading:close()
	end

	local loginCtrl = ui and ui.login

	if loginCtrl and loginCtrl.showLoginFailedTip then
		loginCtrl:showLoginFailedTip(textKey)

		return
	end

	if loginCtrl and loginCtrl.resetLoginState then
		loginCtrl:resetLoginState()
	end

	ClientUtils.showBubbleMessageRaw(pg.getGameString(textKey or "SERVER_UNRESPONSIVE"), 3)
end

function LoginAgent:removePullServerInfoTimer()
	if self.pullServerInfoTimer ~= nil then
		TimerManager.removeTimer(self.pullServerInfoTimer)
	end

	self.pullServerInfoTimer = nil
end

function LoginAgent:logoutService()
	local userInfo = {
		sessionId = GlobalData.GlobalGateSessionId,
		gateId = GlobalData.GlobalGateId,
		serverId = GlobalData.ServerId
	}

	ServiceUtils.callService("RoleService", "CS_Logout", {
		GlobalData.UserName,
		self.token,
		userInfo
	}, nil, {
		hint = GlobalData.UserName
	})
end

function LoginAgent:logout()
	self:logoutService()
	ClientUtils.backToHome()
end

function LoginAgent:sdkLogin()
	return
end

function LoginAgent:verifyCb(retStatus, response)
	if retStatus == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("loginAgent verify callback retStatus is nil")
		end

		self:_showLoginFailedTip("LOGIN_SERVICE_UNAVAILABLE")

		return
	end

	if retStatus.status then
		if response == nil or response.Token == nil or response.Token == "" then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("loginAgent verify response invalid: response=%s", tostring(response))
			end

			self:_showLoginFailedTip("LOGIN_SERVICE_DATA_FAILED")

			return
		end

		if GlobalData.GlobalGateSessionId == nil or GlobalData.GlobalGateSessionId == "" or GlobalData.GlobalGateId == nil or GlobalData.GlobalGateId == "" then
			self:_showLoginFailedTip("LOGIN_SERVER_CONNECT_FAILED")

			return
		end

		self.token = response.Token

		local offlinePlayer = GlobalData.Player

		if offlinePlayer and offlinePlayer.isOfflineMainPlayer then
			local offlineSceneName = ClientUtils.getSceneName(offlinePlayer.sceneId)

			ClientUtils.safeDestroy(offlinePlayer)
			pg.global.resMgr:UnloadSceneForTransition(offlineSceneName)
		end

		local roleInfo
		local roleInfoData = response.RoleInfo

		if roleInfoData ~= nil then
			roleInfo = ClientRepo.protoCodec:decode(roleInfoData)

			if roleInfo == nil or next(roleInfo) == nil then
				csSDKManager.PatchFlowSDKLog(20008, "LoginCreateRole", "", "")
				ClientUtils.checkCreateUser()

				return
			end

			local uid, playerRole = table.firstOrDefault(roleInfo.players)

			if playerRole == nil then
				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error("loginAgent verify roleInfo.players is empty")
				end

				csSDKManager.PatchFlowSDKLog(20008, "LoginCreateRole", "", "")
				ClientUtils.checkCreateUser()

				return
			end

			local playerInitFail = not playerRole.clientPlayerCreateInited
			local isNewAccount = playerRole.avatarPresetKey

			if playerInitFail and isNewAccount then
				csSDKManager.PatchFlowSDKLog(20008, "LoginCreateRole", "", "")
				ClientUtils.checkCreateUser(playerRole.avatarPresetKey)

				return
			end
		else
			csSDKManager.PatchFlowSDKLog(20008, "LoginCreateRole", "", "")
			ClientUtils.checkCreateUser()

			return
		end

		print("@fjs verifyCb, roleInfo=", roleInfo.scene)
		csSDKManager.PatchFlowSDKLog(20008, "LoginLoadWorld", "", "")

		local sceneID = roleInfo.scene

		if sceneID == nil then
			sceneID = 0
		end

		local arg = {
			KeyFrom = LuaCSConst.XPartConst.KeyLogin2Scene,
			ToScene = sceneID
		}

		self:loginImp(arg)
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("loginAgent verify sdkinfo to loginService failed: %s", retStatus.errmsg)
		end

		local loginCtrl = pg and pg.global and pg.global.ui and pg.global.ui.login

		if loginCtrl and loginCtrl.resetLoginState then
			loginCtrl:resetLoginState()
		end

		ClientUtils.showBubbleMessageRaw(pg.getGameString("SERVER_LOGIN_FAIL"), 3)
	end
end

function LoginAgent:useNameCb(retStatus, response)
	if retStatus.status then
		if response.ErrorCode == "SUCCESS" then
			ClientUtils.createUserResult(true)
		else
			if LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("useName response failed: %s", response.ErrorCode)
			end

			ClientUtils.createUserResult(false, NoticeDef[response.ErrorCode])
		end
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("useName failed: %s", retStatus.errmsg)
		end

		ClientUtils.createUserResult(false, NoticeDef.TID_NAME_SERVICE_TIMEOUT)
	end
end

function LoginAgent:loginImp(arg)
	local function cbFunc()
		local clientRepo = require("Core.Client.ClientRepo")

		clientRepo.loginAgent:_callLoginImp(arg)
	end

	local clientXPartUtil = require("Utils.ClientXPartUtil")

	clientXPartUtil.hookLoginAgentLoginImp(arg, cbFunc)
end

function LoginAgent:_callLoginImp(arg)
	if self._loginImpPending then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("loginImp re-entered while privilege check pending, ignored")
		end

		return
	end

	self._loginImpPending = true

	PlatformEntryPrivilegeService:checkLoginMultiplayerPrivilege(function(allowed, reason)
		self._loginImpPending = nil

		if allowed then
			self:_doLoginImp()

			return
		end

		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("Multiplayer privilege denied at login, reason=%s", tostring(reason))
		end

		self:_showLoginFailedTip("LOGIN_PLATFORM_PRIVILEGE_FAILED")
		ClientUtils.backToHome()
	end)
end

function LoginAgent:_enrichSdkInfo(sdkInfoJson)
	local sdkManager = pg.global.sdkManager
	local conversationShortId = sdkManager.getConversationShortId and sdkManager:getConversationShortId()

	if conversationShortId and conversationShortId ~= "" then
		sdkInfoJson.conversationShortId = conversationShortId
	end

	local deviceData = sdkManager:getDeviceData() or ""

	if deviceData ~= "" then
		local ok, deviceDataJson = pcall(json.decode, deviceData)

		if ok and Utils.isTable(deviceDataJson) then
			sdkInfoJson.deviceData = deviceDataJson
		elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("decode deviceData failed before login: %s", tostring(deviceData))
		end
	end

	local ipInfoData = sdkManager:getClientIPInfoData()

	if Utils.isTable(ipInfoData) then
		sdkInfoJson.ipInfoData = ipInfoData
	end

	local accountInfo = sdkManager:getAccountInfoData()

	if Utils.isTable(accountInfo) then
		sdkInfoJson.accountInfo = accountInfo
	end

	if ClientConfigSDKFromMobile == "true" then
		sdkInfoJson.accountid = sdkManager.fpId
		sdkInfoJson.fpid = sdkManager.accountId
		sdkInfoJson.xcloud = "true"
	end
end

function LoginAgent:_doLoginImp()
	local defaultScene = SysConfigData.sceneInit

	if EnableBotTest then
		defaultScene = self.botDefaultSceneId
	elseif DefaultSceneConst.DEFAULT_SCENE_ID ~= 0 then
		defaultScene = DefaultSceneConst.DEFAULT_SCENE_ID
	end

	local userInfo = {
		sessionId = GlobalData.GlobalGateSessionId,
		gateId = GlobalData.GlobalGateId,
		serverId = GlobalData.ServerId,
		DEFAULT_SCENE_ID = defaultScene,
		clientVersion = GameVersion,
		regionNo = GlobalData.LatencyDetectManager:getRegionNo(),
		clientConfigVersion = ConfigVersion.client
	}
	local sdkInfo = pg.global.sdkManager:getTrackingInfo() or ""

	if EnableBotTest then
		sdkInfo = ""
		userInfo.EnableBotServerTest = true
	end

	if sdkInfo ~= "" then
		local ok, sdkInfoJson = pcall(json.decode, sdkInfo)

		if ok and Utils.isTable(sdkInfoJson) then
			self:_enrichSdkInfo(sdkInfoJson)

			local weGameDistributeId = pg.global.sdkManager:getWeGameDistributeId()

			if weGameDistributeId and weGameDistributeId ~= "" then
				sdkInfoJson.distribute_id_wegame = weGameDistributeId
			end

			sdkInfo = json.encode(sdkInfoJson)
		else
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("decode sdkInfo failed before login: %s", tostring(sdkInfo))
			end

			if ClientConfigSDKFromMobile == "true" then
				self:_showLoginFailedTip("LOGIN_SDK_FAILED")

				return
			end
		end
	end

	local extraInfo = {
		avatarPresetKey = GlobalData.AvatarPresetKey,
		avatarConfig = GlobalData.AvatarConfig,
		gamePlatform = GlobalData.GamePlatform,
		playerName = GlobalData.PlayerName,
		templateId = GlobalData.TemplateId,
		playerTags = GlobalData.PlayerTags,
		language = GlobalData.Language,
		platformFamily = tostring(PlatformIdentityUtils.getCurrentPlatformFamily() or PlatformIdentityUtils.Family.Other)
	}
	local platformHooks = LoginAgent._platformHooks
	local enrichLoginExtraInfoHook = platformHooks and platformHooks._enrichLoginExtraInfo

	if enrichLoginExtraInfoHook then
		enrichLoginExtraInfoHook(self, extraInfo)
	end

	if _G_IsDebugMode then
		local SceneData = require("Data.scene_data")
		local GmToolUtils = require("Utils.GmToolUtils")
		local data = {}

		for sceneId, sceneInfo in pairs(SceneData) do
			data[sceneId] = sceneInfo.type
		end

		extraInfo.sceneTypes = data
		extraInfo.debugEnterSceneId = GlobalData.DebugEnterSceneId
		extraInfo.debugEnterScenePos3 = GlobalData.DebugEnterScenePos3
	end

	local requestId = ServiceUtils.callService("RoleService", "CS_Login", {
		GlobalData.UserName,
		self.token,
		userInfo,
		sdkInfo,
		extraInfo
	}, nil, {
		hint = GlobalData.UserName
	})

	if requestId == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("RoleService.CS_Login request failed: requestId is nil")
		end

		self:_showLoginFailedTip("LOGIN_SERVICE_UNAVAILABLE")

		return
	end

	self:tryInitClientDataHelpers()
end

function LoginAgent:tryInitClientDataHelpers()
	local PetManagementDataHelper = require("Utils.PetManagementDataHelper")

	if PetManagementDataHelper and PetManagementDataHelper.isInit then
		PetManagementDataHelper.init()
	end
end

function LoginAgent:loginClick()
	local ui = pg and pg.global and pg.global.ui
	local loginVisible = ui and ui:checkUIVisible(UIConst.UI_ID_LOGIN) or false

	if not loginVisible then
		self:doLoginClick()

		return
	end

	local PremiumService = require("SDK.Platform.PlatformPremiumFeatureService")

	PremiumService:checkEligibility(function(success, code, msg, payload)
		if success ~= true then
			if LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("premium eligibility check failed: code=%s msg=%s", tostring(code), tostring(msg))
			end

			PlatformShellActivityService:clearCurrentActivity("login_premium_denied")
			self:_showLoginFailedTip("LOGIN_PLATFORM_PREMIUM_FAILED")

			return
		end

		self:_fetchPlatformAuthToken(function()
			self:doLoginClick()
		end)
	end)
end

function LoginAgent:_fetchPlatformAuthToken(onComplete)
	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.FetchPlatformAuthorizationCode then
		if onComplete then
			onComplete()
		end

		return
	end

	local TIMEOUT_MS = 10000

	PlatformBridgeLuaFacade.FetchPlatformAuthorizationCode(TIMEOUT_MS, function(ok, errCode, msg, _payload)
		if ok then
			logger:info("平台 AuthToken 获取成功")
		else
			logger:warn("平台 AuthToken 获取失败: errCode=%s msg=%s", tostring(errCode), tostring(msg))
		end

		if ok ~= true then
			self:_showLoginFailedTip("LOGIN_PLATFORM_AUTH_FAILED")

			return
		end

		if onComplete then
			onComplete()
		end
	end)
end

function LoginAgent:doLoginClick()
	if SDKLoginConfig.isEnabled() then
		if pg.global.platform:isXbox() or pg.global.platform:isXboxPC() then
			pg.global.sdkManager:tryRefreshTicket(function()
				self:verifySdk()
			end)
		else
			self:verifySdk()
		end
	else
		self:verifyWithoutSdk()
	end
end

function LoginAgent:verifySdk()
	self._needLastScene = ClientXPartUtil.needCheck()

	local requestId = ServiceUtils.callService("LoginService", "verifySdk", {
		pg.global.sdkManager:getTicket(),
		self._needLastScene
	}, CallbackHandler(self, "verifyCb"))

	if requestId == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("LoginService.verifySdk request failed: requestId is nil")
		end

		self:_showLoginFailedTip("LOGIN_SERVICE_UNAVAILABLE")
	end
end

function LoginAgent:verifyWithoutSdk()
	self._needLastScene = ClientXPartUtil.needCheck()

	local requestId = ServiceUtils.callService("LoginService", "verifyWithoutSdk", {
		GlobalData.UserName,
		self._needLastScene
	}, CallbackHandler(self, "verifyCb"))

	if requestId == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("LoginService.verifyWithoutSdk request failed: requestId is nil")
		end

		self:_showLoginFailedTip("LOGIN_SERVICE_UNAVAILABLE")
	end
end

function LoginAgent:genPreConfigedServers(dirConf)
	if dirConf == nil then
		return {}
	end

	local preConfigedServers = {}
	local template = {
		StartTime = 0,
		ClusterName = "",
		ClusterId = Const.LOGIN_DUMMY_CLUSTERID,
		Status = Const.SERVER_STATUS_CLOSE,
		Custom = {}
	}

	for _, data in ipairs(dirConf.localDirData) do
		local server = lume.merge(template, data)

		if Const.LOGIN_LOCAL_CLUSTERID == server.ClusterId then
			server.ClusterId = LOCAL_IP_ID
			server.LoginServerType = Const.LOGIN_SERVER_TYPE.LOCAL
		elseif data.isShared then
			server.LoginServerType = Const.LOGIN_SERVER_TYPE.SHARED
		else
			server.LoginServerType = Const.LOGIN_SERVER_TYPE.PUBLIC
		end

		preConfigedServers[#preConfigedServers + 1] = server
	end

	local loginCtrl = pg.global.ui.login
	local uiColCount = loginCtrl and loginCtrl.loginServerComponent and loginCtrl.loginServerComponent.colCount or 3
	local dummyCount = uiColCount - #preConfigedServers % uiColCount + uiColCount

	for i = 1, dummyCount do
		local server = lume.merge(template, {})

		server.ClusterId = Const.LOGIN_DUMMY_CLUSTERID
		server.LoginServerType = Const.LOGIN_SERVER_TYPE.DUMMY
		preConfigedServers[#preConfigedServers + 1] = server
	end

	return preConfigedServers
end

function LoginAgent:getServerInfosByConfig(dirConf)
	local serverList = self:genPreConfigedServers(dirConf)

	if #serverList == 0 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("loginAgent get empty serverList")
		end

		return
	end

	ClientRepo.netHandler:setServerList(serverList)

	local loginCtrl = pg.global.ui.login

	if loginCtrl and loginCtrl.loginServerComponent then
		loginCtrl.loginServerComponent:initRefreshAndSelectedServer(true)
	end
end

function LoginAgent:notifyQueueInfo(queueInfo)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("notifyQueueInfo: seq = %d, total= %d, waiting = %d", queueInfo.sequence, queueInfo.total, queueInfo.waiting)
	end

	self.queueNotifyCount = self.queueNotifyCount + 1

	if self.queueNotifyCount > 3 then
		self.queueNotifyCount = 0

		ServiceUtils.callService("RoleService", "CS_Update", {
			GlobalData.UserName
		}, nil, {
			hint = GlobalData.UserName
		})
	end

	local ClientTextUtils = require("Utils.ClientTextUtils")
	local LuaUIUtils = require("Utils.LuaUIUtils")

	self.sequenceReal = queueInfo.sequence

	local sequence = self.realInfo ~= true and self.sequenceReal + 5 or self.sequenceReal
	local total = self.realInfo ~= true and queueInfo.total + 5 or queueInfo.total

	self.realInfo = true

	local waiting = queueInfo.waiting
	local timeText = LuaUIUtils.getLoginWaitingCountDownFormateText(waiting)
	local infoStr = string.format(pg.getGameString("LOGIN_WAITING_DESCRIPTION"), sequence, total, timeText)

	local function tickFunc()
		if pg.global.ui.commonConfirm and pg.global.ui.commonConfirm.view then
			ClientTextUtils.setText(pg.global.ui.commonConfirm.view.subTitle, infoStr)

			waiting = waiting - 1 <= 0 and 0 or waiting - 1
			timeText = LuaUIUtils.getLoginWaitingCountDownFormateText(waiting)

			if sequence > self.sequenceReal then
				local curSequence = sequence - math.floor(sequence / waiting)

				sequence = curSequence < self.sequenceReal and self.sequenceReal or curSequence
			end

			infoStr = string.format(pg.getGameString("LOGIN_WAITING_DESCRIPTION"), sequence, total, timeText)
		end
	end

	if pg.global.ui.commonConfirm and pg.global.ui.commonConfirm.view then
		pg.global.ui.commonConfirm:resetTickTimer(tickFunc, 1)

		return
	end

	ClientUtils.showConfirmRawTicking(pg.getGameString("LOGIN_WAITING_TITLE"), infoStr, function()
		ClientUtils.backToHome()

		if pg.global.ui.commonConfirm and pg.global.ui.commonConfirm.tickTimer then
			pg.global.ui.commonConfirm:killTimer(pg.global.ui.commonConfirm.tickTimer)

			pg.global.ui.commonConfirm.tickTimer = nil
		end
	end, true, nil, nil, nil, {
		okBtnDesc = pg.getGameString("CONSOLE_COMMON_CANCEL")
	}, tickFunc, 1)
end

function LoginAgent:bindGlobalMsGate(uid, msAuth)
	if msAuth == nil or msAuth == "" then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("bindGlobalMsGate msAuth error for %s", uid)
		end

		self:_showLoginFailedTip("LOGIN_MSGATE_BIND_FAILED")

		return
	end

	local clusterId = 0

	if ClientRepo.netHandler ~= nil then
		clusterId = ClientRepo.netHandler.clusterId
	end

	ClientRepo.globalMsProxy:bind(uid, IDManager.strToBytes(msAuth), clusterId, CallbackHandler(self, "bindGlobalMsGateCb", uid, msAuth))
end

function LoginAgent:bindGlobalMsGateCb(uid, msAuth, retStatus, response)
	if retStatus.status then
		GlobalData.LastBindMsUid = uid
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("%s bindGlobalMsGate micro-service clientGate failed: %s", uid, retStatus.errmsg)
		end

		if retStatus.errmsg == "ERR_PARAM_AUTH_INVALID" then
			if GlobalData.Player and GlobalData.Player.refreshAuth then
				GlobalData.Player:refreshAuth()
			end
		elseif retStatus.errmsg ~= "ERR_CONN_ALREADY_BINDED" then
			self._bindGlobalMsGateTimer = TimerManager.addTimer(10, CallbackHandler(self, "_bindGlobalMsGateTimeoutHandler", uid, msAuth))
		end
	end
end

function LoginAgent:_bindGlobalMsGateTimeoutHandler(uid, msAuth)
	self._bindGlobalMsGateTimer = nil

	self:bindGlobalMsGate(uid, msAuth)
end

function LoginAgent:_stopBindGlobalMsGateTimer()
	if self._bindGlobalMsGateTimer then
		TimerManager.removeTimer(self._bindGlobalMsGateTimer)

		self._bindGlobalMsGateTimer = nil
	end
end

function LoginAgent:bindExtraGlobalMsGate(uid, msAuth)
	if ClientRepo.extraGlobalMsProxy == nil then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("start bindExtraGlobalMsGate for %s", uid)
	end

	if msAuth == nil or msAuth == "" then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("bindExtraGlobalMsGate msAuth error for %s", uid)
		end

		return
	end

	local clusterId = 0

	if ClientRepo.netHandler ~= nil then
		clusterId = ClientRepo.netHandler.clusterId
	end

	ClientRepo.extraGlobalMsProxy:bind(uid, IDManager.strToBytes(msAuth), clusterId, CallbackHandler(self, "bindExtraGlobalMsGateCb", uid, msAuth))
end

function LoginAgent:bindExtraGlobalMsGateCb(uid, msAuth, retStatus, response)
	if retStatus.status then
		GlobalData.LastBindExtraMsUid = uid

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("%s bindExtraGlobalMsGate micro-service clientGate success", uid)
		end
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("%s bindExtraGlobalMsGate micro-service clientGate failed: %s", uid, retStatus.errmsg)
		end

		if retStatus.errmsg == "ERR_PARAM_AUTH_INVALID" then
			if GlobalData.Player and GlobalData.Player.refreshAuth then
				GlobalData.Player:refreshAuth()
			end
		elseif retStatus.errmsg ~= "ERR_CONN_ALREADY_BINDED" then
			self._bindExtraGlobalMsGateTimer = TimerManager.addTimer(10, CallbackHandler(self, "_bindExtraGlobalMsGateTimeoutHandler", uid, msAuth))
		end
	end
end

function LoginAgent:_bindExtraGlobalMsGateTimeoutHandler(uid, msAuth)
	self._bindExtraGlobalMsGateTimer = nil

	self:bindExtraGlobalMsGate(uid, msAuth)
end

function LoginAgent:_stopBindExtraGlobalMsGateTimer()
	if self._bindExtraGlobalMsGateTimer then
		TimerManager.removeTimer(self._bindExtraGlobalMsGateTimer)

		self._bindExtraGlobalMsGateTimer = nil
	end
end

function LoginAgent:verifySdkBotTest(ticket)
	ServiceUtils.callService("LoginService", "verifySdk", {
		ticket
	}, CallbackHandler(self, "verifyCb"))
end

return LoginAgent
