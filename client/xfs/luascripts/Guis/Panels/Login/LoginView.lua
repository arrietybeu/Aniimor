-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Login\\LoginView.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local UIView = require("Guis.UIView")
local Class = require("Core.Framework.Class")
local LoginView = Class.LightClass("LoginView", UIView)
local Client = require("Network.Client")
local SDKLoginConfig = require("SDK.SDKLoginConfig")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local PSServerConst = require("Const.PSServerConst")
local UIConst = require("Const.UIConst")
local logger = LoggerManager.getLogger("LoginView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local CommonSwitch = require("Common.CommonSwitch")
local HIDDEN_OPERATION_TIMEOUT_SECONDS = 10
local HIDDEN_CLICK_TOP_LEFT = "T"
local HIDDEN_CLICK_BOTTOM_LEFT = "B"
local MIRROR_SERVER_SEQUENCE = "TTTTTBBBBB"
local PS_AUTO_SELECT_SERVER_SEQUENCE = "BBBBBTTTTT"
local ENABLE_SAVE_LOG_SEQUENCE = "TBTB"

local function isSequencePrefix(sequence, target)
	return string.sub(target, 1, #sequence) == sequence
end

function LoginView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.inputField = self.objectReference:GetRefValue("inputField")
	self.button = self.objectReference:GetRefValue("button")
	self.sceneSelector = self.objectReference:GetRefValue("sceneSelector")
	self.languageSelector = self.objectReference:GetRefValue("languageSelector")
	self.testButton = self.objectReference:GetRefValue("testButton")
	self.serverListTransform = self.objectReference:GetRefValue("serverListTransform")
	self.serverSelectUButton = self.objectReference:GetRefValue("serverSelectUButton")
	self.panelAccountTransform = self.objectReference:GetRefValue("panelAccountTransform")
	self.panelRepairTransform = self.objectReference:GetRefValue("panelRepairTransform")
	self.root = self.objectReference:GetRefValue("root")
	self.inputFieldGamePadFocus = self.objectReference:GetRefValue("inputFieldGamePadFocus")
	self.serverSelectGamePadFocus = self.objectReference:GetRefValue("serverSelectGamePadFocus")
	self.startGameGamePadFocus = self.objectReference:GetRefValue("startGameGamePadFocus")
	self.btnNotice = self.objectReference:GetRefValue("btnNotice")
	self.settingBtn = self.objectReference:GetRefValue("settingBtn")
	self.serviceBtn = self.objectReference:GetRefValue("btnService")
	self.accountBtn = self.objectReference:GetRefValue("accountBtn")
	self.btnScan = self.objectReference:GetRefValue("btnScanUButton")
	self.quitBtn = self.objectReference:GetRefValue("quitBtn")
	self.stateUComponent = self.objectReference:GetRefValue("stateUComponent")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.inputSceneID = self.objectReference:GetRefValue("inputSceneID")
	self.videoUVideoPlayer = self.objectReference:GetRefValue("videoUVideoPlayer")
	self.btnPrompt = self.objectReference:GetRefValue("btnPrompt")
	self.healthTip = self.objectReference:GetRefValue("healthTip")
	self.tMPUSDFText = self.objectReference:GetRefValue("tMPUSDFText")
	self.lIzi04OnceUWidget = self.objectReference:GetRefValue("lIzi04OnceUWidget")
	self.lIzi05OnceUWidget = self.objectReference:GetRefValue("lIzi05OnceUWidget")
	self.lIzi04UWidget = self.objectReference:GetRefValue("lIzi04UWidget")
	self.lIzi05UWidget = self.objectReference:GetRefValue("lIzi05UWidget")
	self.layoutBoxAnimation = self.objectReference:GetRefValue("layoutBoxAnimation")
	self.overseaServerNameUSDFText = self.objectReference:GetRefValue("overseaServerNameUSDFText")
	self.selectServerUButton = self.objectReference:GetRefValue("btnSelectServerUButton")
	self.topLeftBtnUButton = self.objectReference:GetRefValue("topLeftBtnUButton")
	self.bottomLeftBtnUButton = self.objectReference:GetRefValue("bottomLeftBtnUButton")
	self.versionUSDFText = self.objectReference:GetRefValue("versionUSDFText")
	self.txtTipsUSDFText = self.objectReference:GetRefValue("txtTipsUSDFText")
	self.txtDetailsUSDFText = self.objectReference:GetRefValue("txtDetailsUSDFText")
	self.txtPercentUSDFText = self.objectReference:GetRefValue("txtPercentUSDFText")
	self.loadingProgressUProgress = self.objectReference:GetRefValue("loadingProgressUProgress")
	self.txtRewardUSDFText = self.objectReference:GetRefValue("txtRewardUSDFText")
	self.selectLanguageUComponent = self.objectReference:GetRefValue("selectLanguageUComponent")
end

function LoginView:hideLoginWhenCloudXBOX()
	if self.root == nil then
		return
	end

	if ClientConfigCloudEnable ~= "true" then
		return
	end

	local windows = self.root.transform:Find("Windows")

	if windows == nil then
		return
	end

	windows.gameObject:SetActiveEx(false)
end

function LoginView:hideLoginExitBtnWhenConsole()
	if self.quitBtn == nil then
		return
	end

	self.quitBtn.gameObject:SetActiveEx(false)
end

function LoginView:resetHiddenOperationSequence()
	self.hiddenOperationSequence = ""
	self.hiddenOperationStartedAt = nil
end

function LoginView:togglePSAutoSelectServer()
	local platform = pg and pg.global and pg.global.platform

	if not platform or not platform:isOverseasWithPS() then
		return
	end

	local enabled = PSServerConst.toggleAutoSelectServer()
	local loginCtrl = pg.global.ui and pg.global.ui.login
	local serverComponent = loginCtrl and loginCtrl.loginServerComponent

	if serverComponent then
		serverComponent.selectServerIndex = nil
		serverComponent.selectServerId = nil
		serverComponent.selectServerName = nil
		serverComponent.serverList = {}
	end

	ClientUtils.pullServerList(true)
	ClientUtils.showBubbleMessageRaw(enabled and "PS Auto Select Server: ON" or "PS Auto Select Server: OFF", 3)
end

function LoginView:enableSaveLogBeforeLogin()
	if UNITY_EDITOR then
		return
	end

	local isMobile = ClientUtils.getAdaptionPlatform() == UIConst.PLATFORM.Mobile

	if not isMobile then
		return
	end

	CS.FunPlus.WorldX.Utils.LuaUtils.EnableSaveLog(true)
	ClientUtils.showBubbleMessageRaw(ClientTextUtils.getGameString("GM_ENABLE_CONSOLE_LOG_SAVE"), 3)
end

function LoginView:onHiddenOperationClick(click)
	local now = os.time()

	if self.hiddenOperationStartedAt == nil or now - self.hiddenOperationStartedAt > HIDDEN_OPERATION_TIMEOUT_SECONDS then
		self:resetHiddenOperationSequence()

		self.hiddenOperationStartedAt = now
	end

	local sequence = self.hiddenOperationSequence .. click

	if sequence == MIRROR_SERVER_SEQUENCE then
		self:resetHiddenOperationSequence()
		self:connectToMirrorServer()

		return
	end

	if sequence == PS_AUTO_SELECT_SERVER_SEQUENCE then
		self:resetHiddenOperationSequence()
		self:togglePSAutoSelectServer()

		return
	end

	if sequence == ENABLE_SAVE_LOG_SEQUENCE then
		self:resetHiddenOperationSequence()
		self:enableSaveLogBeforeLogin()

		return
	end

	if isSequencePrefix(sequence, MIRROR_SERVER_SEQUENCE) or isSequencePrefix(sequence, PS_AUTO_SELECT_SERVER_SEQUENCE) or isSequencePrefix(sequence, ENABLE_SAVE_LOG_SEQUENCE) then
		self.hiddenOperationSequence = sequence
		self.hiddenOperationStartedAt = now

		return
	end

	self.hiddenOperationSequence = click
	self.hiddenOperationStartedAt = now
end

function LoginView:initView()
	function self.testButton.luaClick()
		local pos = Vector3(2000, 0, 2000)
		local player = Client.createLocalPlayer(pos)

		pg.game.loading:enterOfflineScene(100, player)
	end

	LuaUIUtils.setUIViewVisible(self.inputField, not SDKLoginConfig.isEnabled())
	LuaUIUtils.setUIViewVisible(self.inputFieldGamePadFocus, not SDKLoginConfig.isEnabled())

	local DefaultSceneConst = require("Common.Const.DefaultSceneConst")

	ClientTextUtils.setText(self.inputSceneID, tostring(DefaultSceneConst.DEFAULT_SCENE_ID))
	LuaUIUtils.setUIViewVisible(self.inputSceneID, false)

	if UIPlatformName == "mobile" then
		-- block empty
	end

	if ClientConfigCloudEnable == "true" then
		LuaUIUtils.setUIViewVisible(self.inputSceneID, false)
	end

	if ClientConfigDebugHideAccount == true then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("fengjs LoginView: ClientConfigDebugHideAccount: hide inputField/serverSelectUButton")
		end

		LuaUIUtils.setUIViewVisible(self.serverSelectUButton, false)
		LuaUIUtils.setUIViewVisible(self.inputField, false)
		LuaUIUtils.setUIViewVisible(self.inputFieldGamePadFocus, false)
	end

	local _h = LoginView._platformHooks

	if _h and _h.initView then
		_h.initView(self)
	end

	if UNITY_PS5 then
		self:hideLoginExitBtnWhenConsole()
	end

	self:resetHiddenOperationSequence()

	if self.topLeftBtnUButton ~= nil then
		function self.topLeftBtnUButton.luaClick()
			self:onHiddenOperationClick(HIDDEN_CLICK_TOP_LEFT)
		end
	end

	if self.bottomLeftBtnUButton ~= nil then
		function self.bottomLeftBtnUButton.luaClick()
			self:onHiddenOperationClick(HIDDEN_CLICK_BOTTOM_LEFT)
		end
	end

	self.serviceBtn:SetActive(pg.global.sdkManager:canOpenHelpCenter())
end

function LoginView:connectToMirrorServer()
	local ClientConst = require("Const.ClientConst")

	ClientConst.OPEN_MIRROR_SERVER = true

	local ServerListHelper = require("Utils.ServerListHelper")

	ServerListHelper.reqServerList(true)
end

return LoginView
