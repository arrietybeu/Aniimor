-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Login\\LoginCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local MessageName = require("Const.MessageName")
local UICtrl = require("Guis.UICtrl")
local LoginAccountComponent = require("Guis.Panels.Login.Component.LoginAccountComponent")
local LoginServerComponent = require("Guis.Panels.Login.Component.LoginServerComponent")
local LoginGamePadComponent = require("Guis.Panels.Login.Component.LoginGamePadComponent")
local LoginRepairComponent = require("Guis.Panels.Login.Component.LoginRepairComponent")
local SelectLanguageComponent = require("Guis.Panels.Login.Component.SelectLanguageComponent")
local Class = require("Core.Framework.Class")
local ClientUtils = require("Utils.ClientUtils")
local PSServerConst = require("Const.PSServerConst")
local ClientConst = require("Const.ClientConst")
local GlobalData = require("Core.Client.GlobalData")
local ClientSwitch = require("Common.ClientSwitch")
local LuaCSConst = require("Common.Const.LuaCSConst")
local SDKLoginConfig = require("SDK.SDKLoginConfig")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local NoticeDef = require("Common.NoticeDef")
local HotkeyConst = require("Const.HotkeyConst")
local TimerManager = require("Core.Timer.TimerManager")
local ClientXPartUtil = require("Utils.ClientXPartUtil")
local ClientXPartQuery = require("Utils.ClientXPartQuery")
local EventConst = require("Common.Const.EventConst")
local PlatformShellJoinService = require("SDK.Platform.PlatformShellJoinService")
local PlatformLoginService = require("SDK.Platform.PlatformLoginService")
local GameStringConfig = require("Data.gamestring_config_data")
local FuncMenuBottomListData = require("Data.func_menu_common_use_data")
local LoginCtrl = Class.LightClass("LoginCtrl", UICtrl)
local csXCloudPipeController = CS.FunPlus.WorldX.SDK.XCloudPipeController
local csSDKManager = CS.FunPlus.WorldX.SDK.SDKManager
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("LoginCtrl")
local LOGIN_STATE_WATCHDOG_SECONDS = 15
local SHELL_JOIN_AUTO_LOGIN_POLL_INTERVAL = 1
local VIDEO_PREPARE_FALLBACK_SECONDS = 1

LoginCtrl.RESOURCE_DOWNLOAD_REFRESH_INTERVAL = 1

local function isShellJoinAutoLoginPlatform()
	local platform = pg and pg.global and pg.global.platform

	if not platform then
		return false
	end

	local isPlayStation = type(platform.isPS) == "function" and platform:isPS() == true
	local isXbox = type(platform.isXbox) == "function" and platform:isXbox() == true

	return isPlayStation or isXbox
end

LoginCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	},
	[MessageName.SDK_LOGIN] = {
		"onSDKLogin",
		true
	},
	[MessageName.RESOURCE_DOWNLOAD_STATE_BEGIN] = {
		"onResourceDownloadStateBegin",
		true
	},
	[MessageName.RESOURCE_DOWNLOAD_STATE_CHANGED] = {
		"onResourceDownloadStateChanged",
		true
	},
	[MessageName.RESOURCE_DOWNLOAD_STATE_END] = {
		"onResourceDownloadStateEnd",
		true
	}
}

function LoginCtrl:onCreate(info)
	self.downSavedPartID = {}
	self.downCurrentPartID = nil
	self.downIsShowLoginControl = true
	self.downHaveShowConfirm = false

	local resourceDownload = pg and pg.game and pg.game.resourceDownload

	if not resourceDownload:isXPartEnabled() then
		self.downHaveShowConfirm = true
	end

	PSServerConst.resetAutoSelectServer()
	UICtrl.onCreate(self, info)

	self.loginAccountComponent = LoginAccountComponent.new(self, self.view.panelAccountTransform)

	local lastLoginName = pg.global.prefsCacheUtils:getString("loginName", "")

	self.view.inputField.characterLimit = 50
	self.view.inputField.text = lastLoginName

	if ClientConfigCloudEnable == "true" then
		-- block empty
	end

	self.selectSceneId = tonumber(pg.global.prefsCacheUtils:getString("lastSceneId", 0))
	self.loginServerComponent = LoginServerComponent.new(self, self.view.serverListTransform)
	self.loginRepairComponent = LoginRepairComponent.new(self, self.view.panelRepairTransform)

	local ServerListHelper = require("Utils.ServerListHelper")

	ServerListHelper.startPullServerList(false, function(category, errInfo)
		self:onServerListPullFailed(category, errInfo)
	end)

	appFacade.entityManager.loadNoGoEntity = true
	appFacade.entityManager.batchKccJob = true
	self.lastClickLoginTime = 0
	self.loginStateWatchdogSeq = 0
	self.loginIntervalTime = 5

	self.view.quitBtn:SetActive(not pg.global.platform:isConsole() and ClientConfigCloudEnable ~= "true")
	self:refreshAccountButtonVisible()
	self:refreshScanButtonVisible()

	function self.refreshOnlineIDTextHandler()
		self:refreshOnlineIDText()
	end

	if pg.global.eventEmitter then
		pg.global.eventEmitter:addEventListener(EventConst.PLATFORM_ONLINE_ID_CHANGED, self.refreshOnlineIDTextHandler)
		pg.global.eventEmitter:addEventListener(EventConst.PLATFORM_USER_SIGNED_IN, self.refreshOnlineIDTextHandler)
	end
end

function LoginCtrl:onDestroy()
	self:stopLoginStateWatchdog()
	self:stopShellJoinAutoLoginTimer()
	self:clearPendingSDKLoginCallback(true)
	self:stopResourceDownloadRefreshTimer()

	self._serverListErrorShowing = nil

	if self.refreshOnlineIDTextHandler and pg.global.eventEmitter then
		pg.global.eventEmitter:removeEventListener(EventConst.PLATFORM_ONLINE_ID_CHANGED, self.refreshOnlineIDTextHandler)
		pg.global.eventEmitter:removeEventListener(EventConst.PLATFORM_USER_SIGNED_IN, self.refreshOnlineIDTextHandler)

		self.refreshOnlineIDTextHandler = nil
	end

	self.loginAccountComponent = nil
	self.loginServerComponent = nil
	self.loginRepairComponent = nil

	pg.game.avatar:preloadShutdown()
end

function LoginCtrl:addListener()
	function self.view.btnScan.luaClick()
		pg.global.sdkManager:qrcodeLogin()
	end

	function self.view.button.luaClick()
		local _h = LoginCtrl._platformHooks

		if _h and _h.shouldBlockLoginClick and _h.shouldBlockLoginClick(self) then
			self:_refreshPlatformLoginButtonInteractable()

			return
		end

		if self.isInLogin then
			LoginCtrl.showInLoginTip()

			return
		end

		local curTime = os.time()

		if curTime - self.lastClickLoginTime < self.loginIntervalTime then
			ClientUtils.showBubbleMessageRaw(pg.getGameString("OPERATE_TOO_MANY"), 3)

			return
		end

		self.lastClickLoginTime = curTime

		self:onLoginClick()
	end

	function self.view.sceneSelector.luaSelectedChanged(list)
		self:onSwitchToScene(list.selectedItem)
	end

	function self.view.languageSelector.luaSelectedChanged(list)
		self:onLanguageSelect(list.selectedItem)
	end

	function self.view.inputFieldGamePadFocus.luaClick()
		if self.isInLogin then
			LoginCtrl.showInLoginTip()

			return
		end

		self.view.inputField:Select()
	end

	local testButton = false

	function self.view.settingBtn.luaClick()
		if testButton == true then
			print("@fjs loginctrl.settingBtn: try down part: fire(27)")
			pg.global.resMgr:XPartTryDownload(27, 0, 4096, 0)
			pg.global.resMgr:XPartHeadDownload(27, 0)

			return
		end

		pg.global.resMgr:DebugDump(10001)

		if self.isInLogin then
			LoginCtrl.showInLoginTip()

			return
		end

		self:openLoginSetting()
	end

	function self.view.serviceBtn.luaClick()
		if false then
			pg.global.resMgr:DebugDump(-65)

			return
		end

		if testButton == true then
			print("@fjs loginctrl.serviceBtn: try down part: novice(24)")
			pg.global.resMgr:XPartTryDownload(24, 0, 4096, 0)
			pg.global.resMgr:XPartHeadDownload(24, 0)

			return
		end

		if self.isInLogin then
			LoginCtrl.showInLoginTip()

			return
		end

		pg.global.ui.hudV2:openServicePanel()
	end

	function self.view.btnNotice.luaClick()
		if self.isInLogin then
			LoginCtrl.showInLoginTip()

			return
		end

		pg.global.ui.announcement.model:getAnnouncementData(true)
	end

	function self.view.quitBtn.luaClick()
		if testButton == true then
			print("@fjs loginctrl.quitBtn: try list part")

			local clientXPartUtil = require("Utils.ClientXPartUtil")

			clientXPartUtil.printAllPart()

			return
		end

		ClientUtils.gc()

		local quitQrCodeUrl, quitQrCodeTip = self.model:getQuitQrCodeUrlAndTip()

		pg.global.showConfirmMsgRaw(pg.getGameString("RELEASE_WARN"), pg.getGameString("QUIT_GAME"), function()
			appFacade.QuitGame()
		end, false, nil, nil, nil, {
			qrCodeUrl = quitQrCodeUrl,
			qrCodeTip = quitQrCodeTip
		})
	end

	function self.view.accountBtn.luaClick()
		if testButton == true then
			print("@fjs loginctrl.accountBtn: try down part: role(23)")
			pg.global.resMgr:XPartTryDownload(23, 0, 4096, 0)
			pg.global.resMgr:XPartHeadDownload(23, 0)

			return
		end

		if self.isInLogin then
			LoginCtrl.showInLoginTip()

			return
		end

		local isSDKMode = pg.global.sdkManager:isSDKMode()

		if isSDKMode then
			pg.global.sdkManager:openUserCenter()
		else
			self.view.rootUComponent:TryChangePage("Account", "Open")
			self.loginAccountComponent:tryActivateInputField()
		end
	end

	function self.view.btnPrompt.luaClick()
		if self.isInLogin then
			LoginCtrl.showInLoginTip()

			return
		end

		pg.global.ui:open(UIConst.UI_ID_AGE_RATING)
	end

	if ClientConfigAppCountry == "cn" then
		self.view.btnPrompt:SetActive(true)
		self.view.healthTip:SetActive(true)
		ClientTextUtils.setText(self.view.healthTip, pg.getGameString("LEGAL_LOGIN_TIP"))
	else
		self.view.btnPrompt:SetActive(false)
		self.view.healthTip:SetActive(false)
	end

	if self.view.selectServerUButton then
		function self.view.selectServerUButton.luaClick()
			if self.isInLogin then
				LoginCtrl.showInLoginTip()

				return
			end

			self.loginServerComponent:openSelectServerPanel(true)
		end
	end

	local videoPlayer = self.view.videoUVideoPlayer

	self.videoPrepared = videoPlayer == nil or videoPlayer.isPrepared == true

	if videoPlayer then
		function videoPlayer.luaVideoPrepared()
			local needCheckOverseaSDKCache = not self.videoPrepared

			self.videoPrepared = true

			self:stopVideoPrepareFallback()

			if needCheckOverseaSDKCache then
				self:tryCheckOverseaSDKCache()
			end
		end
	end
end

function LoginCtrl:openLoginSetting()
	local openSource = pg.global.ui.setting.model.OPEN_SOURCE.Login
	local snapshot
	local navMgr = CS.XGUI.Navigation.NavManager.Instance

	if navMgr and pg.game.input:isUsingGamepad() then
		snapshot = navMgr:SaveFocusStackSnapshot()
	end

	local function restoreFocus()
		if not snapshot then
			return
		end

		local mgr = CS.XGUI.Navigation.NavManager.Instance

		if not mgr then
			return
		end

		if not pg.game.input:isUsingGamepad() then
			return
		end

		mgr:RestoreFocusStackSnapshot(snapshot)
	end

	pg.global.ui.setting:open({
		openSource = openSource
	}, nil, restoreFocus)
end

function LoginCtrl:clearPendingSDKLoginCallback(clearShellJoinCluster)
	local callback = self._pendingSDKLoginCallback
	local sdkManager = pg and pg.global and pg.global.sdkManager

	if callback and sdkManager and sdkManager.fnCallbackLogin == callback then
		sdkManager.fnCallbackLogin = nil
	end

	self._pendingSDKLoginCallback = nil

	if clearShellJoinCluster == true then
		self._pendingShellJoinClusterId = nil
		self._pendingShellJoinClusterName = nil
	end
end

function LoginCtrl:retryPendingShellJoinSDKLogin()
	local clusterId = self._pendingShellJoinClusterId
	local clusterName = self._pendingShellJoinClusterName

	if string.isNilOrEmpty(clusterId) or self._pendingSDKLoginCallback then
		return false
	end

	self:onLoginClick(clusterId, clusterName)

	return true
end

function LoginCtrl:tryOpenLanguageSelection()
	if not self:isOverseas() or pg.global.prefsCacheUtils:getBool(ClientConst.PrefKey.LanguageSelectionConfirmed, false) then
		return false
	end

	if not self.selectLanguageComponent then
		self.selectLanguageComponent = SelectLanguageComponent.new(self, self.view.selectLanguageUComponent)
	end

	self.selectLanguageComponent:show()

	return true
end

function LoginCtrl:onLanguageSelectionConfirmed(loginView)
	if self.view ~= loginView or not self:checkUIVisible() or self.view.widget.isClosing then
		return
	end

	if not pg.global.prefsCacheUtils:getBool(ClientConst.PrefKey.LanguageSelectionConfirmed, false) then
		return
	end

	if self:tryCommandAutoLogin() then
		return
	end

	self:prepareOverseaServerSelection()
	self:tryStartAutoLogin()
end

function LoginCtrl:onLoginClick(shellJoinClusterId, shellJoinClusterName)
	if not string.isNilOrEmpty(shellJoinClusterId) then
		self._pendingShellJoinClusterId = tostring(shellJoinClusterId)

		if string.isNilOrEmpty(shellJoinClusterName) then
			-- block empty
		end

		self._pendingShellJoinClusterName = tostring(shellJoinClusterName)
	else
		shellJoinClusterId = self._pendingShellJoinClusterId
		shellJoinClusterName = self._pendingShellJoinClusterName
	end

	if self:tryOpenLanguageSelection() then
		return
	end

	CS.FunPlus.WorldX.Utils.LuaUtils.LuaTraceStart(3, "LuaLoginClick", 10, "")

	if SDKLoginConfig.isEnabled() then
		local accountId = pg.global.sdkManager:getAccountId()

		if accountId == nil then
			if self._pendingSDKLoginCallback then
				local sdkManager = pg.global.sdkManager
				local ownsCallback = sdkManager.fnCallbackLogin == self._pendingSDKLoginCallback

				if ownsCallback and sdkManager:isLoginInProgress() then
					return
				end

				self:clearPendingSDKLoginCallback()
			end

			local callback

			function callback()
				if self._pendingSDKLoginCallback ~= callback then
					return
				end

				self._pendingSDKLoginCallback = nil

				local pendingShellJoinClusterId = self._pendingShellJoinClusterId
				local pendingShellJoinClusterName = self._pendingShellJoinClusterName
				local resumeShellJoin = not string.isNilOrEmpty(pendingShellJoinClusterId)

				if resumeShellJoin and (not self.loginServerComponent or not self.loginServerComponent:selectServerByCluster(pendingShellJoinClusterId, pendingShellJoinClusterName)) then
					return
				end

				self._pendingShellJoinClusterId = nil
				self._pendingShellJoinClusterName = nil

				if resumeShellJoin or not self:isOverseasWithoutPS() then
					self:onLoginClick(pendingShellJoinClusterId, pendingShellJoinClusterName)
				end
			end

			self._pendingSDKLoginCallback = callback
			pg.global.sdkManager.fnCallbackLogin = callback

			if pg.global.sdkManager:isLoginInProgress() then
				return
			end

			local started, reason = pg.global.sdkManager:login()

			if started ~= true and reason ~= "LoginInProgress" then
				logger:warn("SDK login did not start, reason=%s", tostring(reason))
				self:clearPendingSDKLoginCallback()
			end

			return
		end

		self._pendingShellJoinClusterId = nil
		self._pendingShellJoinClusterName = nil
		GlobalData.UserName = accountId
	else
		if self.view.inputField.text == "" then
			ClientUtils.showBubbleMessageRaw(pg.getGameString("INPUT_NAME_WARNING"), 3)

			return
		end

		GlobalData.UserName = self.view.inputField.text
	end

	if not self.loginServerComponent:preparePSAutoSelectServer() then
		ClientUtils.showBubbleMessageRaw(pg.getGameString("STARTUP_SERVER_LIST_DATA_FAILED"), 3)

		return
	end

	if self.loginServerComponent.overseaSDKNoPS then
		if string.isNilOrEmpty(shellJoinClusterId) and pg.global.ui:checkUIOpen(UIConst.UI_ID_LOGIN_SELECT_SERVER) then
			return
		end

		self.loginServerComponent:checkOverseaSDKCache()
	end

	if not self.loginServerComponent:writeToGlobalData() then
		if not pg.global.ui:checkUIOpen(UIConst.UI_ID_LOGIN_SELECT_SERVER) then
			ClientUtils.showBubbleMessageRaw(pg.getGameString("SELECT_SERVER"), 3)
		end

		return
	end

	if UIPlatformName == "mobile" then
		local DefaultSceneConst = require("Common.Const.DefaultSceneConst")
		local inputSceneID = self.view.inputSceneID.text
		local defaultSceneID = tostring(DefaultSceneConst.DEFAULT_SCENE_ID)

		if defaultSceneID ~= inputSceneID then
			DefaultSceneConst.DEFAULT_SCENE_ID = tonumber(inputSceneID)
		end
	end

	local ClientRepo = require("Core.Client.ClientRepo")
	local targetServer = ClientRepo.netHandler:getTargetServer(GlobalData.ServerId)

	if targetServer == nil then
		ClientUtils.showBubbleMessageRaw(pg.getGameString("SERVER_LIST_EMPTY"), 3)

		return
	end

	assert(GlobalData.ServerId == targetServer.ClusterId)
	ClientRepo.loginAgent:removePullServerInfoTimer()

	if _G_IsDebugMode and ClientConfigUserNameNoServerID ~= "true" and not SDKLoginConfig.isEnabled() and not ClientSwitch.EnableUserNameDebugLogin and GlobalData.ServerId ~= 100 then
		GlobalData.UserName = GlobalData.UserName .. "-" .. tostring(GlobalData.ServerId)
	end

	pg.cmd.onLogin()
	pg.global.prefsCacheUtils:setString("loginName", self.view.inputField.text)
	pg.global.prefsCacheUtils:setString("lastSceneId", tonumber(self.selectSceneId))
	pg.global.prefsCacheUtils:save()
	csSDKManager.PatchFlowSDKLog(30013, "ServerUserPair", GlobalData.ServerId .. "|" .. GlobalData.UserName, "")
	self:switchLoginState(true)
end

function LoginCtrl:startLoginResourceDownload()
	if self.resourceDownloadRefreshTimer then
		return
	end

	self.loginDownloadArg = nil

	local resourceDownload = pg and pg.game and pg.game.resourceDownload

	if not resourceDownload:isXPartEnabled() then
		self:refreshLoginResourceDownload()

		return
	end

	self.resourceDownloadStarting = true
	self.resourceDownloadRefreshTimer = TimerManager.addRepeatTimer(self.RESOURCE_DOWNLOAD_REFRESH_INTERVAL, function()
		self:refreshLoginResourceDownload()
	end)

	self:refreshLoginResourceDownload()
end

function LoginCtrl:stopResourceDownloadRefreshTimer()
	if not self.resourceDownloadRefreshTimer then
		return
	end

	TimerManager.removeTimer(self.resourceDownloadRefreshTimer)

	self.resourceDownloadRefreshTimer = nil
end

function LoginCtrl:onResourceDownloadStateBegin()
	local isWaitMode = pg.global.resMgr:XPartWaitMode(0)

	print("@fjs trackXPart onResourceDownloadStateBegin, isWaitMode=", isWaitMode)

	if isWaitMode == 1 then
		self:startLoginResourceDownload()
	end
end

function LoginCtrl:onResourceDownloadStateEnd()
	print("@fjs trackXPart onResourceDownloadStateEnd")
end

function LoginCtrl:onResourceDownloadStateChanged()
	if not self.resourceDownloadRefreshTimer then
		return
	end

	self:refreshLoginResourceDownload()
end

function LoginCtrl:refreshLoginDownSavedPart()
	local resourceDownload = pg and pg.game and pg.game.resourceDownload
	local currentDetail
	local numNotReady = 0
	local downSavedPartID = self.downSavedPartID
	local sumCurByte = 0
	local sumAllByte = 0
	local sumLastCurByte = 0
	local partTitle = ""

	for idx, val in ipairs(downSavedPartID) do
		local clsid = val[1]
		local instid = val[2]
		local savePer = val[3]
		local detail = {}

		val[4] = detail

		local percent = pg.global.resMgr:XPartQueryDetail(clsid, instid, detail)

		if percent < LuaCSConst.XPartConst.PercentFull then
			numNotReady = numNotReady + 1

			if currentDetail == nil then
				currentDetail = detail
			end
		end

		sumCurByte = sumCurByte + detail.CurTotalByte
		sumAllByte = sumAllByte + detail.NumByte
		sumLastCurByte = sumLastCurByte + detail.LastCurByte

		local title = ClientXPartQuery.findPackTitleByDetail(detail)

		if partTitle == "" then
			partTitle = title
		else
			partTitle = partTitle .. "+" .. title
		end
	end

	local curSize = sumCurByte
	local totalSize = sumAllByte
	local progress = 0
	local useV2Percent = true

	if useV2Percent then
		curSize = curSize - sumLastCurByte
		totalSize = totalSize - sumLastCurByte
	end

	if totalSize > 0 then
		progress = curSize / totalSize
	end

	progress = math.max(0, math.min(progress, 1))

	if self.view.loadingProgressUProgress then
		self.view.loadingProgressUProgress.normalizedValue = progress
	end

	local rateByte = currentDetail and currentDetail.RateByte or 0
	local curTotalByte = currentDetail and currentDetail.CurTotalByte or 0

	ClientTextUtils.setText(self.view.txtPercentUSDFText, string.format("%d%%", math.floor(progress * 100 + 0.5)))

	local sizeText = resourceDownload:formatDownloadBytes(curSize) .. "/" .. resourceDownload:formatDownloadBytes(totalSize)
	local speedText = resourceDownload:formatDownloadBytes(rateByte) .. "/s"

	ClientTextUtils.setText(self.view.txtDetailsUSDFText, pg.getFormatText(pg.getGameString("DOWNLOAD_PROGRESS_DETAIL"), speedText, sizeText))

	local packHeadTitle = partTitle
	local timeLeft = resourceDownload:formatDownloadTime(rateByte, curSize, totalSize)

	if rateByte <= 0 and self.resourceDownloadStarting == true then
		local startWaitText = pg.getGameString("PACKAGE_DOWNLOAD_STARTING")

		ClientTextUtils.setText(self.view.txtTipsUSDFText, startWaitText)
		ClientTextUtils.setText(self.view.txtPercentUSDFText, "")
		ClientTextUtils.setText(self.view.txtDetailsUSDFText, "")
	else
		self.resourceDownloadStarting = false

		ClientTextUtils.setText(self.view.txtTipsUSDFText, string.format("%s %s %s", pg.getGameString("PACKAGE_DOWNLOAD_TITLE"), packHeadTitle, timeLeft))
	end

	if numNotReady <= 0 then
		print("@fjs refreshLoginDownSavedPart, compl")
		self.view.rootUComponent:TryChangePage("Tpye", 0)

		if self.resourceDownloadRefreshTimer then
			-- block empty
		end

		self:stopResourceDownloadRefreshTimer()

		self.downSavedPartID = {}

		self:loginTipDownLeftPartID()
	else
		self.view.rootUComponent:TryChangePage("Tpye", 1)
	end
end

function LoginCtrl:refreshLoginResourceDownload()
	local resourceDownload = pg and pg.game and pg.game.resourceDownload

	if not resourceDownload:isXPartEnabled() then
		self.view.rootUComponent:TryChangePage("Tpye", 0)
		self:stopResourceDownloadRefreshTimer()

		return
	end

	if self.downSavedPartID ~= nil and #self.downSavedPartID > 0 then
		self:refreshLoginDownSavedPart()

		return
	end

	local currentDetail
	local queueCount = 0
	local isComplete = false

	currentDetail = ClientXPartQuery.getDownQueueDetail()

	local percent = currentDetail and currentDetail.Percent or LuaCSConst.XPartConst.PercentFull

	if percent >= LuaCSConst.XPartConst.PercentFull then
		isComplete = true
	end

	local curSize = currentDetail and tonumber(currentDetail.CurTotalByte) or 0
	local totalSize = currentDetail and tonumber(currentDetail.NumByte) or 0
	local progress = currentDetail and tonumber(currentDetail.Percent / LuaCSConst.XPartConst.PercentFull) or isComplete and 1 or 0
	local lastCurByte = currentDetail and currentDetail.LastCurByte or 0
	local oldCurSize = curSize
	local useV2Percent = true

	if useV2Percent then
		curSize = curSize - lastCurByte
		totalSize = totalSize - lastCurByte
	end

	if totalSize > 0 then
		progress = curSize / totalSize
	end

	if currentDetail ~= nil then
		local CurTotalByte = tonumber(currentDetail.CurTotalByte) or 0
		local CurByte = tonumber(currentDetail.CurByte) or 0
		local effectCurByte = math.max(CurTotalByte, CurByte)
		local numByte = tonumber(currentDetail.NumByte) or 0

		if numByte > 0 and numByte <= effectCurByte then
			progress = 1
		end
	end

	progress = math.max(0, math.min(progress, 1))

	if progress >= 1 then
		isComplete = true
	end

	if self.view.loadingProgressUProgress then
		self.view.loadingProgressUProgress.normalizedValue = progress
	end

	local rateByte = currentDetail and currentDetail.RateByte or 0

	if rateByte < 0 then
		rateByte = 0
	end

	self:switchDownLoginUI()
	ClientTextUtils.setText(self.view.txtPercentUSDFText, string.format("%.2f%%", progress * 100))

	local sizeText = resourceDownload:formatDownloadBytes(curSize) .. "/" .. resourceDownload:formatDownloadBytes(totalSize)
	local speedText = resourceDownload:formatDownloadBytes(rateByte) .. "/s"

	ClientTextUtils.setText(self.view.txtDetailsUSDFText, string.format("(%s) %s", speedText, sizeText))

	local packHeadTitle = ClientXPartQuery.findPackTitleByDetail(currentDetail)
	local timeLeft = resourceDownload:formatDownloadTime(rateByte, curSize, totalSize)

	if rateByte <= 0 and self.resourceDownloadStarting == true then
		local startWaitText = pg.getGameString("PACKAGE_DOWNLOAD_TITLE")

		ClientTextUtils.setText(self.view.txtTipsUSDFText, startWaitText)
		ClientTextUtils.setText(self.view.txtPercentUSDFText, "")
		ClientTextUtils.setText(self.view.txtDetailsUSDFText, "")
	else
		self.resourceDownloadStarting = false

		local curPartIndex = currentDetail.ItemIndex
		local allPartCount = currentDetail.ItemTotal
		local textPartNum = string.format("(%d/%d)", curPartIndex, allPartCount)

		ClientTextUtils.setText(self.view.txtTipsUSDFText, pg.getFormatText(pg.getGameString("DOWNLOADING_PROGRESS"), textPartNum))
	end

	if isComplete then
		print("@fjs refreshLoginResourceDownload: isComplete=true, stop")
		self.view.rootUComponent:TryChangePage("Tpye", 0)
		self:downShowLoginControl(true)

		if self.resourceDownloadRefreshTimer then
			-- block empty
		end

		self:stopResourceDownloadRefreshTimer()
	else
		self.view.rootUComponent:TryChangePage("Tpye", 1)
	end
end

function LoginCtrl:tryAutoLoginByShellJoin()
	if not isShellJoinAutoLoginPlatform() then
		return false
	end

	if self.isInLogin then
		return false
	end

	if not self.loginServerComponent then
		return false
	end

	if not PlatformLoginService:isShellJoinUserSessionReady() then
		if self._shellJoinPlatformLoginWaitLogged ~= true then
			self._shellJoinPlatformLoginWaitLogged = true

			logger:info("shell join auto login waits for platform user session")
		end

		return false
	end

	if self._shellJoinPlatformLoginWaitLogged == true then
		self._shellJoinPlatformLoginWaitLogged = nil

		logger:info("shell join auto login resumes after platform user session ready")
	end

	local intent = PlatformShellJoinService:peekPreLoginJoinIntent()

	if intent == nil then
		return false
	end

	if self._shellJoinAutoLoginConnectionString == intent.connectionString then
		return false
	end

	if not self.loginServerComponent:selectServerByCluster(intent.clusterId, intent.clusterName) then
		return false
	end

	logger:info("shell join auto login start: clusterId=%s clusterName=%s", tostring(intent.clusterId), tostring(intent.clusterName))

	self._shellJoinAutoLoginConnectionString = intent.connectionString

	self:stopShellJoinAutoLoginTimer()
	self:onLoginClick(intent.clusterId, intent.clusterName)

	return true
end

function LoginCtrl:startShellJoinAutoLoginTimer()
	if not isShellJoinAutoLoginPlatform() then
		return
	end

	if self.shellJoinAutoLoginTimer then
		return
	end

	self.shellJoinAutoLoginTimer = TimerManager.addRepeatTimer(SHELL_JOIN_AUTO_LOGIN_POLL_INTERVAL, function()
		if self:tryAutoLoginByShellJoin() then
			self:stopShellJoinAutoLoginTimer()
		end
	end)
end

function LoginCtrl:stopShellJoinAutoLoginTimer()
	if self.shellJoinAutoLoginTimer == nil then
		return
	end

	TimerManager.removeTimer(self.shellJoinAutoLoginTimer)

	self.shellJoinAutoLoginTimer = nil
end

function LoginCtrl:setLoginButtonText(textKey)
	local textConfig = GameStringConfig[textKey]

	if self.view and self.view.tMPUSDFText and textConfig and textConfig.desc then
		self.view.tMPUSDFText.textId = tostring(textConfig.desc)

		return
	end

	if self.view and self.view.tMPUSDFText then
		ClientTextUtils.setText(self.view.tMPUSDFText, ClientTextUtils.getGameString(textKey))
	end
end

function LoginCtrl:switchLoginState(isInLogin)
	self.isInLogin = isInLogin

	local pageId = isInLogin and 1 or 0

	self.view.button:TryChangePage("LoginState", pageId)

	self.view.button.visualInteractable = not isInLogin
	self.view.inputField.readOnly = isInLogin
	self.view.inputField.visualInteractable = not isInLogin

	if isInLogin then
		self:setLoginButtonText("Loging")
		self:startLoginStateWatchdog()
	else
		self:setLoginButtonText("LOGIN_START")
		self:stopLoginStateWatchdog()
	end

	self:_refreshPlatformLoginButtonInteractable()
end

function LoginCtrl:startLoginStateWatchdog()
	self:stopLoginStateWatchdog()

	self.loginStateWatchdogSeq = (self.loginStateWatchdogSeq or 0) + 1

	local seq = self.loginStateWatchdogSeq

	self.loginStateWatchdogTimer = TimerManager.addTimer(LOGIN_STATE_WATCHDOG_SECONDS, function()
		self.loginStateWatchdogTimer = nil

		if self.loginStateWatchdogSeq ~= seq or not self.isInLogin then
			return
		end

		if self.checkUIOpen and not self:checkUIOpen() then
			return
		end

		if self.resourceDownloadRefreshTimer ~= nil then
			return
		end

		logger:warn("login state watchdog timeout, reset login state")
		self:resetLoginState()
		ClientUtils.showBubbleMessageRaw(pg.getGameString("SERVER_UNRESPONSIVE"), 3)
	end)
end

function LoginCtrl:stopLoginStateWatchdog()
	self.loginStateWatchdogSeq = (self.loginStateWatchdogSeq or 0) + 1

	if self.loginStateWatchdogTimer ~= nil then
		TimerManager.removeTimer(self.loginStateWatchdogTimer)

		self.loginStateWatchdogTimer = nil
	end
end

function LoginCtrl:showLoginFailedTip(textKey)
	self:resetLoginState()
	ClientUtils.showBubbleMessageRaw(pg.getGameString(textKey or "SERVER_UNRESPONSIVE"), 3)
end

function LoginCtrl.showInLoginTip()
	pg.global.ui.tips:showTextTip(pg.getGameString("CONNECTING_TO_SERVER"))
end

function LoginCtrl:onSwitchToScene(data)
	self.selectSceneId = tonumber(data.id)
end

local function isUnityNil(value)
	return value == nil or type(IsNil) == "function" and IsNil(value)
end

function LoginCtrl:_refreshPlatformLoginButtonInteractable()
	local _h = LoginCtrl._platformHooks

	if _h and _h.refreshLoginButtonInteractable then
		_h.refreshLoginButtonInteractable(self)
	end
end

function LoginCtrl:refreshOnlineIDText()
	self:_refreshPlatformLoginButtonInteractable()

	local objectReference = self.view and self.view.objectReference

	if not objectReference then
		return
	end

	local onlineIdNode = objectReference:GetRefValue("OnlineID")

	if isUnityNil(onlineIdNode) then
		return
	end

	local text = ""
	local _h = LoginCtrl._platformHooks

	if _h and _h.getOnlineIDText then
		text = _h.getOnlineIDText(self) or ""
	end

	local hasText = not string.isNilOrEmpty(text)

	if onlineIdNode.SetActive then
		onlineIdNode:SetActive(hasText)
	end

	ClientTextUtils.setText(onlineIdNode, hasText and text or "")
end

function LoginCtrl:refreshAccountButtonVisible()
	if not self.view or not self.view.accountBtn then
		return
	end

	if SDKLoginConfig.isEnabled() and ClientConfigCloudEnable ~= "true" then
		self.view.accountBtn:SetActive(pg.global.sdkManager.isInit == true and pg.global.sdkManager:hasUserCenter())
	end
end

function LoginCtrl:refreshServiceButtonVisible()
	self.view.serviceBtn:SetActive(pg.global.sdkManager:canOpenHelpCenter())
end

function LoginCtrl:refreshScanButtonVisible()
	self.view.btnScan:SetActive((UNITY_ANDROID == true or UNITY_IOS == true) and pg.global.sdkManager.isLogin == true)
end

function LoginCtrl:tryCommandAutoLogin()
	if CMDAutoLogin == "1" then
		function pg.global.sdkManager.fnCallbackLogin()
			self:onLoginClick()
		end

		csXCloudPipeController.CMDAutoLoginFromLua()

		return true
	end

	if CMDAutoLogin == "2" then
		self:autoLoginUserName(CMDFPSDKTicket)

		return true
	end

	return false
end

function LoginCtrl:prepareOverseaServerSelection()
	if not SDKLoginConfig.isEnabled() or not self:isOverseas() then
		return
	end

	if self.videoPrepared or self.view.videoUVideoPlayer.isPrepared == true then
		self.videoPrepared = true

		self:tryCheckOverseaSDKCache()
	else
		self:stopVideoPrepareFallback()
		self:startVideoPrepareFallback()
	end
end

function LoginCtrl:tryStartAutoLogin()
	local shellJoinAutoLoginStarted = self:tryAutoLoginByShellJoin()

	if not shellJoinAutoLoginStarted then
		self:startShellJoinAutoLoginTimer()

		if SDKLoginConfig.isEnabled() and not pg.global.sdkManager.isLogin and not pg.global.sdkManager:getIsFeedScene() then
			pg.global.sdkManager:login()
		end
	end
end

function LoginCtrl:onShow()
	self.view.rootUComponent:TryChangePage("Tpye", 0)
	ClientTextUtils.setText(self.view.txtTipsUSDFText, pg.getGameString("PACKAGE_DOWNLOAD_TITLE"))
	ClientTextUtils.setText(self.view.txtRewardUSDFText, pg.getGameString("NEW_VERSION_REWARD"))
	self:switchLoginState(false)
	ClientTextUtils.setText(self.view.overseaServerNameUSDFText, "")
	csSDKManager.PatchFlowSDKLog(30006, "", "", "")

	local overseaSDK = SDKLoginConfig.isEnabled() and self:isOverseas()

	self.view.rootUComponent:TryChangePage("kind", overseaSDK and 1 or 0)

	local languageSelectionOpened = self:tryOpenLanguageSelection()

	if not languageSelectionOpened and self:tryCommandAutoLogin() then
		return
	end

	self:refreshAccountButtonVisible()
	CS.FunPlus.WorldX.Utils.LuaUtils.LuaTraceStart(2, "Lua2Login", 0, "")

	if not SDKLoginConfig.isEnabled() then
		if ClientConfigCloudEnable == "true" then
			-- block empty
		else
			csSDKManager.XSDKAfterFPSDKInit()
		end
	elseif overseaSDK and not languageSelectionOpened then
		self:prepareOverseaServerSelection()
	end

	pg.game.setting:tryShowForbidden()
	pg.game.setting:tryShowMobileVideoQualityTip()
	self:refreshOnlineIDText()

	if not languageSelectionOpened then
		self:tryStartAutoLogin()
	end

	local versionStr = tostring(ClientFullVersion or "")

	ClientTextUtils.setText(self.view.versionUSDFText, string.format("Version: %s", versionStr))

	if not SDKLoginConfig.isEnabled() then
		self:onSDKLoginOrShow()
	end
end

function LoginCtrl:onSDKLoginOrShow()
	self:delayDownAllPartID()

	local isSdkEnable = SDKLoginConfig.isEnabled()

	if isSdkEnable == true then
		ClientXPartQuery.tryGetUserLastScene()
	end
end

function LoginCtrl:onServerListPullFailed(category, errInfo)
	if self._serverListErrorShowing then
		return
	end

	local ClientRepo = require("Core.Client.ClientRepo")
	local serverList = ClientRepo.netHandler and ClientRepo.netHandler:getServerList() or nil

	if category ~= "data" and category ~= "empty" and serverList ~= nil and #serverList > 0 then
		return
	end

	if self.checkUIOpen and not self:checkUIOpen() then
		return
	end

	local descKey = "STARTUP_SERVER_LIST_NETWORK_FAILED"

	if category == "data" then
		descKey = "STARTUP_SERVER_LIST_DATA_FAILED"
	elseif category == "empty" then
		descKey = "STARTUP_SERVER_LIST_EMPTY"
	end

	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("server list pull failed: category=%s, source=%s, detail=%s", tostring(category), tostring(errInfo and errInfo.source), tostring(errInfo and errInfo.detail))
	end

	self._serverListErrorShowing = true

	pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString(descKey), function()
		self._serverListErrorShowing = nil

		self:reqServerList(true)
	end, false, function()
		self._serverListErrorShowing = nil
	end, nil, nil, {
		okBtnDesc = pg.getGameString("NET_RECONNECT_RETRY"),
		cancelBtnDesc = pg.getGameString("COMMON_CANCEL")
	})
end

function LoginCtrl:reqServerList(force)
	local ServerListHelper = require("Utils.ServerListHelper")

	ServerListHelper.reqServerList(force, function(category, errInfo)
		self:onServerListPullFailed(category, errInfo)
	end)
end

function LoginCtrl:autoLoginUserName(userName)
	GlobalData.BlockBindSoulClientNotMatch = true
	self.view.inputField.text = userName

	print("autoLoginUserName: userName=[" .. userName .. "]")
	self:onLoginClick()
end

function LoginCtrl:isOverseas()
	return ClientConfigAppCountry ~= "cn"
end

function LoginCtrl:isOverseasWithoutPS()
	return pg.global.platform:isOverseasWithoutPS()
end

function LoginCtrl:tryCheckOverseaSDKCache()
	if not SDKLoginConfig.isEnabled() then
		return
	end

	if not self:isOverseasWithoutPS() then
		return
	end

	if not pg.global.prefsCacheUtils:getBool(ClientConst.PrefKey.LanguageSelectionConfirmed, false) then
		return
	end

	if pg.global.sdkManager.isLogin ~= true then
		return
	end

	if not self.videoPrepared or not self.loginServerComponent then
		return
	end

	self:checkOverseaSDKCache()
end

function LoginCtrl:startVideoPrepareFallback()
	if self.videoPrepared or self.videoPrepareFallbackTimer then
		return
	end

	self.videoPrepareFallbackTimer = self:startTimer(function()
		self.videoPrepareFallbackTimer = nil
		self.videoPrepared = true

		self:tryCheckOverseaSDKCache()
	end, VIDEO_PREPARE_FALLBACK_SECONDS)
end

function LoginCtrl:stopVideoPrepareFallback()
	if not self.videoPrepareFallbackTimer then
		return
	end

	self:killTimer(self.videoPrepareFallbackTimer)

	self.videoPrepareFallbackTimer = nil
end

function LoginCtrl:onSDKLogin()
	self:refreshAccountButtonVisible()
	self:refreshServiceButtonVisible()
	self:refreshScanButtonVisible()
	self:tryCheckOverseaSDKCache()

	if SDKLoginConfig.isEnabled() then
		self:onSDKLoginOrShow()
	end
end

function LoginCtrl:checkOverseaSDKCache()
	self.loginServerComponent:checkOverseaSDKCache()
end

function LoginCtrl:onHide()
	self:stopLoginStateWatchdog()
	self:stopShellJoinAutoLoginTimer()
	self:clearPendingSDKLoginCallback(true)
	self:stopVideoPrepareFallback()
	csSDKManager.PatchFlowSDKLog(20009, "LoginCreateRole", "", "")
end

function LoginCtrl:checkSkipBgmAttenuation()
	return true
end

function LoginCtrl:checkSkipMenuAttenuation()
	return true
end

function LoginCtrl:onLanguageSelect(data)
	return
end

function LoginCtrl:onInputDeviceChanged(deviceType)
	return
end

function LoginCtrl:resetLoginState()
	if self.view then
		self:switchLoginState(false)
		self.view.lIzi04OnceUWidget:SetActive(false)
		self.view.lIzi05OnceUWidget:SetActive(false)

		self.view.lIzi04UWidget.renderOpacity = 1
		self.view.lIzi05UWidget.renderOpacity = 1

		self.view.layoutBoxAnimation:Play("VX_Logging_Hover_Out")
	end
end

function LoginCtrl:resumeVideo()
	if self.view.videoUVideoPlayer then
		self.view.videoUVideoPlayer:ResumeVideo()
	end
end

function LoginCtrl:pauseVideo()
	if self.view.videoUVideoPlayer then
		self.view.videoUVideoPlayer:PauseVideo()
	end
end

function LoginCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function LoginCtrl:delayDownSavedPartID()
	if self.downSavedPartTimer ~= nil then
		TimerManager.removeTimer(self.downSavedPartTimer)

		self.downSavedPartTimer = nil
	end

	self.downSavedPartTimer = TimerManager.addTimer(1, function()
		self:loginTryDownSavedPartID()
	end)
end

function LoginCtrl:delayDownAllPartID()
	if ClientXPartQuery._loginDownloadRunning == true then
		return
	end

	local resourceDownload = pg and pg.game and pg.game.resourceDownload

	if not resourceDownload:isXPartEnabled() then
		return
	end

	if self.downAllPartTimer ~= nil then
		TimerManager.removeTimer(self.downAllPartTimer)

		self.downAllPartTimer = nil
	end

	local runSpecialPartMode = ClientXPartQuery.tryRunSpecialPartMode()

	if runSpecialPartMode ~= nil then
		print("@fjs LoginCtrl:delayDownAllPartID: runSpecialPartMode=", runSpecialPartMode)

		ClientXPartQuery._loginDownloadRunning = true

		return
	end

	print("@fjs LoginCtrl:delayDownAllPartID: enter std partmode")

	local skipDownAllPart = false

	if skipDownAllPart == true then
		return
	end

	local notCompletePartID = ClientXPartUtil.getNotCompletePartID()

	if #notCompletePartID <= 0 then
		return
	end

	local netstate = ClientXPartQuery.getNetworkType()

	print("@fjs LoginCtrl.delayDownPartID: netstate=", netstate)

	if netstate == 1 then
		local textTipTitle = pg.getGameString("PACKEG_DOWNLOAD_TITLE")
		local textTipContent = pg.getGameString("PACKEG_DOWNLOAD_DESC_3")
		local textBtnYes = pg.getGameString("START_DOWNLOAD")
		local textBtnNot = pg.getGameString("STOP_DOWNLOAD")
		local extraInfo = {}

		extraInfo.okBtnDesc = textBtnYes
		extraInfo.cancelBtnDesc = textBtnNot

		pg.global.showConfirmMsgRaw(textTipTitle, textTipContent, function()
			self:downShowConfirmCellYes()
		end, false, function()
			self:downShowConfirmCellNot()
		end, false, nil, extraInfo)
	else
		self:delayStartDownAllPartID()
	end
end

function LoginCtrl:delayStartDownAllPartID()
	self.downAllPartTimer = TimerManager.addTimer(1, function()
		ClientXPartUtil.startDownAllPartID()
	end)
end

function LoginCtrl:downShowConfirmCellYes()
	self:delayStartDownAllPartID()
end

function LoginCtrl:downShowConfirmCellNot()
	print("LoginCtrl: downShowConfirmCellNot")
	ClientXPartQuery.setAllowCellNetwork(-1)
	ClientXPartQuery.startCheckNetworkTimer()
end

function LoginCtrl:loginTryDownSavedPartID()
	local skipAll = false

	skipAll = false

	if skipAll then
		return
	end

	local downSavedPartID = ClientXPartUtil.tryDownSavedPartID()

	self.downSavedPartID = downSavedPartID

	print(string.format("@fjs loginTryDownSavedPartID: [%s]", table.val_to_str(downSavedPartID)))

	local num = #downSavedPartID

	if num <= 0 then
		self:loginTipDownLeftPartID()

		return
	end

	self:startLoginResourceDownload()
end

function LoginCtrl:loginTipDownLeftPartID()
	local leftPartID = ClientXPartUtil.tryGetLeftPartID()

	print(string.format("@fjs loginTipDownLeftPartID: ", debug.traceback()))

	local num = #leftPartID

	if num <= 0 then
		return
	end

	local downCurrentPartID = ClientXPartUtil.getCurrentWaitPartID()

	if downCurrentPartID ~= nil then
		print(string.format("@fjs loginTipDownLeftPartID: downCurrentPartID ~= nil skip"))

		return
	end

	local tipDetail = ClientXPartUtil.formatLeftPartID(leftPartID)
	local tipTitle = "资源下载提示"
	local tipText = "是否启动静默下载剩余资产" .. tipDetail

	pg.global.showConfirmMsgRaw(tipTitle, tipText, function()
		ClientXPartUtil.tryDownLeftPartID()
	end)
end

function LoginCtrl:switchDownLoginUI()
	local specialPartMode = ClientXPartQuery.isSpecialPartMode()

	if specialPartMode == true then
		return
	end

	local isDownMaxToLocal = ClientXPartQuery.getIsDownMaxToLocal()

	if isDownMaxToLocal == true then
		if true or self.downIsShowLoginControl == false then
			self:downShowLoginControl(true)
		end

		local haveGetServerUserSceneID = ClientXPartQuery.haveGetServerUserSceneID()

		if haveGetServerUserSceneID == true and self.downHaveShowConfirm == false then
			self:downShowConfirmDialog()
		end
	elseif true or self.downIsShowLoginControl == true then
		self:downShowLoginControl(false)
	end
end

function LoginCtrl:downShowConfirmDialog(force)
	if force == false and self.downHaveShowConfirm == true then
		return
	end

	self.downHaveShowConfirm = true

	print("@fjs downShowConfirmDialog")

	local textContinueDownload = pg.getGameString("CONTINUE_DOWNLOAD")
	local textPlayWithDownload = pg.getGameString("PLAY_WITH_DOWNLOAD")
	local textDialogTitle = pg.getGameString("PACKEG_DOWNLOAD_TITLE")
	local textDialogContent = pg.getGameString("PLAY_WITH_DOWNLOAD_TIPS")
	local extraInfo = {}

	extraInfo.cancelBtnDesc = textContinueDownload
	extraInfo.okBtnDesc = textPlayWithDownload

	pg.global.showConfirmMsgRaw(textDialogTitle, textDialogContent, function()
		self:downShowConfirmButtonPlayWith()
	end, false, function()
		self:downShowConfirmButtonContinue()
	end, false, nil, extraInfo)
end

function LoginCtrl:downShowConfirmButtonPlayWith()
	print("@fjs LoginCtrl:downShowConfirmButtonPlayWith")
	ClientXPartUtil._setWaitMode(-1)
	self:pressLoginButton("downShowConfirmButtonPlayWith")
end

function LoginCtrl:downShowConfirmButtonContinue()
	print("@fjs LoginCtrl:downShowConfirmButtonContinue")
	ClientXPartUtil._setWaitMode(1)
end

function LoginCtrl:downShowLoginControl(show)
	local success, kind = self.view.rootUComponent:TryGetCurrentPage("kind")

	if not success then
		return
	end

	self.downIsShowLoginControl = show

	self.view.startGameGamePadFocus.gameObject:SetActiveEx(show)

	if kind == 1 then
		self.view.selectServerUButton:SetActive(show)
	else
		self.view.inputField:SetActive(show)
		self.view.serverSelectUButton:SetActive(show)
	end
end

function LoginCtrl:pressLoginButton(fr)
	print("@fjs pressLoginButton, fr=", fr)
	self:onLoginClick()
end

function LoginCtrl:onServerSelected(fr, servList, idx, servId, servName, server)
	ClientXPartQuery.tryGetUserLastScene()
end

return LoginCtrl
