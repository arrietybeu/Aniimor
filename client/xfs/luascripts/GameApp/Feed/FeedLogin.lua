-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Feed\\FeedLogin.lua

local ClientUtils = require("Utils.ClientUtils")
local ClientRepo = require("Core.Client.ClientRepo")
local GlobalData = require("Core.Client.GlobalData")
local ServerListHelper = require("Utils.ServerListHelper")
local NetworkClient = require("Network.Client")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local FeedLogin = {
	loginStarted = false
}

function FeedLogin.showFinishConfirm(okCb, cancelCb)
	pg.global.ui.commonConfirm:open({
		title = pg.getGameString("popup_common_tips"),
		desc = pg.getGameString("popup_common01"),
		okCb = okCb,
		cancelCb = cancelCb,
		extraInfo = {
			cancelBtnDesc = pg.getGameString("popup_common02"),
			okBtnDesc = pg.getGameString("popup_common03")
		}
	})
end

function FeedLogin.login(needGameLogin)
	if FeedLogin.loginStarted or not pg.global.sdkManager:getIsFeedScene() then
		return false
	end

	FeedLogin.loginStarted = true
	FeedLogin.needGameLogin = needGameLogin == true

	local sdkManager = pg.global.sdkManager

	if sdkManager:getAccountId() ~= nil then
		FeedLogin.loginDefaultServer()

		return true
	end

	if not sdkManager.isInit and not sdkManager:isCloudSDKMode() then
		sdkManager.fnCallbackInit = FeedLogin.onSdkInit

		return true
	end

	return FeedLogin.startSdkLogin()
end

function FeedLogin.onSdkInit(result)
	if result ~= 1 then
		FeedLogin.resetLogin()

		return
	end

	FeedLogin.startSdkLogin()
end

function FeedLogin.startSdkLogin()
	local sdkManager = pg.global.sdkManager

	sdkManager.fnCallbackInit = nil

	function sdkManager.fnCallbackLogin()
		FeedLogin.loginDefaultServer()
	end

	sdkManager.fnCallbackLoginFailed = FeedLogin.resetLogin

	local started, error = sdkManager:login()

	if started == true or error == "LoginInProgress" then
		return true
	end

	FeedLogin.resetLogin()

	return false
end

function FeedLogin.resetLogin()
	local sdkManager = pg.global.sdkManager

	sdkManager.fnCallbackInit = nil
	sdkManager.fnCallbackLogin = nil
	sdkManager.fnCallbackLoginFailed = nil
	FeedLogin.loginStarted = false
	FeedLogin.needGameLogin = nil

	pg.global.ui.avatarLoading:close()
end

function FeedLogin.loginDefaultServer()
	ServerListHelper.startPullServerList(false)

	local dirConf = ClientUtils.getDirConf()

	if dirConf == nil then
		FeedLogin.resetLogin()

		return
	end

	ClientRepo.loginAgent:getServerInfosByConfig(dirConf)

	local defaultServerName, defaultServerId = GlobalData.DefaultServerManager:getServerInfo()
	local configuredServer, groupServer, defaultServer, fallbackServer
	local serverGroup = ClientUtils.getServerListGroup()

	for _, server in ipairs(ClientRepo.netHandler:getServerList()) do
		if server.ClusterId ~= Const.LOGIN_DUMMY_CLUSTERID then
			fallbackServer = fallbackServer or server

			if ClientConfigServerName ~= "" and server.ClusterName == ClientConfigServerName then
				configuredServer = server
			end

			if serverGroup and string.lower(server.ClusterName) == string.lower(serverGroup) then
				groupServer = server
			end

			if server.ClusterId == defaultServerId and server.ClusterName == defaultServerName then
				defaultServer = server
			end
		end
	end

	local targetServer = configuredServer or groupServer or defaultServer or fallbackServer

	if targetServer == nil then
		FeedLogin.resetLogin()

		return
	end

	GlobalData.ServerId = targetServer.ClusterId
	GlobalData.ServerName = targetServer.ClusterName
	GlobalData.UserName = pg.global.sdkManager:getAccountId()

	ClientRepo.loginAgent:removePullServerInfoTimer()

	FREE_WALK = false

	if FeedLogin.needGameLogin then
		FeedLogin.needGameLogin = nil

		pg.global.ui:closeAllUIPanel({
			[UIConst.UI_ID_TIPS] = true,
			[UIConst.UI_ID_AVATAR_LOADING] = true,
			[UIConst.UI_ID_TOPLOGO] = true
		})
		pg.cmd.onLogin()

		return
	end

	NetworkClient.login()
end

return FeedLogin
