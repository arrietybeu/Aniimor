-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformConnectivityService.lua

local logger = require("SDK.Platform.PlatformLogger")
local TimerManager = require("Core.Timer.TimerManager")
local ClientUtils = require("Utils.ClientUtils")
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local PlatformConnectivityService = {}

PlatformConnectivityService.MAX_RETRY = 5
PlatformConnectivityService.RETRY_DELAY = 2
PlatformConnectivityService.state = {
	initialized = false,
	retryCount = 0,
	tipShown = false,
	callbackRegistered = false
}

function PlatformConnectivityService.isConnectivityHealthy(hint)
	return hint == "InternetAccess" or hint == "ConstrainedInternetAccess"
end

function PlatformConnectivityService.getConnectivityHint()
	if PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.GetNetworkConnectivityHint then
		local hint = PlatformBridgeLuaFacade.GetNetworkConnectivityHint()

		if type(hint) == "string" and hint ~= "" then
			return hint
		end
	end

	return "Unknown"
end

local checkConnectivity, handleDisconnected

local function endPremiumFeatureSession()
	local PremiumService = require("SDK.Platform.PlatformPremiumFeatureService")

	logger:info("平台网络断开：结束 PremiumFeatureSession。")
	PremiumService:endSession(function()
		return
	end, 0)
end

local function quitTeamSpeechChannel()
	local pgInst = rawget(_G, "pg")
	local me = pgInst and pgInst.me

	if not me or type(me.quitSpeechChannel) ~= "function" then
		return
	end

	local inSpeechChannel = pgInst.game and pgInst.game.speech and pgInst.game.speech:checkMemberInRoom(me.uid) == true

	if me.pendingSpeechRoomId or inSpeechChannel then
		me:quitSpeechChannel()
	end
end

local function isLoginGameState()
	local gameState = pg and pg.game and pg.game.gameState

	return gameState == nil or gameState == ClientConst.GS_CONNECT or gameState == ClientConst.GS_LOGIN
end

local function isPlayStationPlatform()
	return PlatformIdentityUtils.getCurrentPlatformFamily() == PlatformIdentityUtils.Family.PlayStation
end

local function isPlatformSignedIn()
	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.HasSignedInUser then
		return true
	end

	return PlatformBridgeLuaFacade.HasSignedInUser() == true
end

local function isPlatformSignedOut()
	local PlatformLoginService = require("SDK.Platform.PlatformLoginService")
	local state = PlatformLoginService and PlatformLoginService.state

	return state and state.signedOut == true
end

local function resumePremiumFeatureSessionIfNeeded(source)
	if isLoginGameState() then
		return
	end

	if isPlayStationPlatform() and (isPlatformSignedOut() or not isPlatformSignedIn()) then
		logger:warn("平台网络恢复：PSN 账号未登录，source=%s", tostring(source))
		ClientUtils.backToHome()

		return
	end

	local space = pg and pg.space
	local multiPlayerEnv = space and space.isMultiPlayerEnv and space:isMultiPlayerEnv()
	local me = pg and pg.me
	local selfInTeam = me and type(me.isInTeam) == "function" and me:isInTeam()

	if not multiPlayerEnv and not selfInTeam then
		return
	end

	local PremiumService = require("SDK.Platform.PlatformPremiumFeatureService")

	PremiumService:checkEligibility(function(success, code, message)
		if not success then
			logger:warn("平台网络恢复：PremiumFeatureSession 权限检查失败，source=%s code=%s message=%s", tostring(source), tostring(code), tostring(message))
			ClientUtils.backToHome()

			return true
		end

		PremiumService:beginSession("cross_play", function()
			return true
		end, 0)

		return true
	end, 0)
end

function PlatformConnectivityService.closeTip()
	if PlatformConnectivityService.state.retryTimer then
		TimerManager.removeTimer(PlatformConnectivityService.state.retryTimer)

		PlatformConnectivityService.state.retryTimer = nil
	end

	PlatformConnectivityService.state.retryCount = 0

	if PlatformConnectivityService.state.tipShown and pg and pg.global and pg.global.ui then
		pg.global.ui:close(UIConst.UI_ID_COMMON_CONFIRM)

		if pg.global.ui:checkUIOpen(UIConst.UI_ID_NET_LOADING) then
			pg.global.ui:close(UIConst.UI_ID_NET_LOADING)
		end
	end

	PlatformConnectivityService.state.tipShown = false
end

function PlatformConnectivityService.scheduleRetry()
	if PlatformConnectivityService.state.retryTimer then
		TimerManager.removeTimer(PlatformConnectivityService.state.retryTimer)

		PlatformConnectivityService.state.retryTimer = nil
	end

	PlatformConnectivityService.state.retryTimer = TimerManager.addTimer(PlatformConnectivityService.RETRY_DELAY, checkConnectivity)
end

function PlatformConnectivityService.onRetry()
	PlatformConnectivityService.scheduleRetry()
end

function handleDisconnected()
	endPremiumFeatureSession()
	quitTeamSpeechChannel()

	if isPlayStationPlatform() then
		if isPlatformSignedOut() then
			logger:warn("平台网络断开：PSN 账号已签出，直接返回登录界面。")
			ClientUtils.backToHome()

			return
		end

		if not isLoginGameState() and not isPlatformSignedIn() then
			logger:warn("平台网络断开：PSN 账号未登录，直接返回登录界面。")
			ClientUtils.backToHome()

			return
		end
	end

	if PlatformConnectivityService.state.tipShown then
		return
	end

	PlatformConnectivityService.state.tipShown = true

	local family = PlatformIdentityUtils.getCurrentPlatformFamily()

	ClientUtils.showConsoleDisconnectTip(family, PlatformConnectivityService.onRetry, function()
		PlatformConnectivityService.closeTip()
		ClientUtils.backToHome()
	end)
	logger:info("平台网络断线提示弹窗已展示。")
end

function checkConnectivity()
	PlatformConnectivityService.state.retryTimer = nil

	if PlatformConnectivityService.isConnectivityHealthy(PlatformConnectivityService.getConnectivityHint()) then
		logger:info("平台网络连接恢复，关闭提示")
		PlatformConnectivityService.closeTip()
		resumePremiumFeatureSessionIfNeeded("retry_confirmed")

		return
	end

	PlatformConnectivityService.state.retryCount = PlatformConnectivityService.state.retryCount + 1

	logger:info("平台网络重连尝试 #%d 仍然离线。", PlatformConnectivityService.state.retryCount)

	if PlatformConnectivityService.state.retryCount >= PlatformConnectivityService.MAX_RETRY then
		logger:warn("平台网络重试次数已达上限，准备返回主界面。")
		PlatformConnectivityService.closeTip()
		ClientUtils.backToHome()

		return
	end

	PlatformConnectivityService.state.tipShown = false

	handleDisconnected()
end

function PlatformConnectivityService.handleConnected()
	if not PlatformConnectivityService.state.tipShown then
		return
	end

	PlatformConnectivityService.closeTip()
	resumePremiumFeatureSessionIfNeeded("network_connected")
end

function PlatformConnectivityService.onConnectivityChanged(eventType, hint)
	if not PlatformConnectivityService.state.initialized then
		return
	end

	if eventType == "NetworkDisconnected" then
		handleDisconnected()

		return
	end

	if eventType == "NetworkConnected" then
		PlatformConnectivityService.handleConnected()
	end
end

function PlatformConnectivityService.registerConnectivityCallback()
	if PlatformConnectivityService.state.callbackRegistered then
		return
	end

	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.RegisterConnectivityChangedCallback then
		return
	end

	PlatformBridgeLuaFacade.RegisterConnectivityChangedCallback(PlatformConnectivityService.onConnectivityChanged)

	PlatformConnectivityService.state.callbackRegistered = true
end

function PlatformConnectivityService:init(runtimeReady)
	if PlatformConnectivityService.state.initialized then
		return true
	end

	PlatformConnectivityService.state.initialized = true

	PlatformConnectivityService.registerConnectivityCallback()

	return true
end

return PlatformConnectivityService
