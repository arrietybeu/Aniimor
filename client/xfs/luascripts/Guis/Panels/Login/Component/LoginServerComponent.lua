-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Login\\Component\\LoginServerComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientRepo = require("Core.Client.ClientRepo")
local Class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local HotkeyConst = require("Const.HotkeyConst")
local logger = LoggerManager.getLogger("LoginServerComponent")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local ClientUtils = require("Utils.ClientUtils")
local Time = require("Core.Common.Time")
local GlobalData = require("Core.Client.GlobalData")
local ClientTextUtils = require("Utils.ClientTextUtils")
local SDKLoginConfig = require("SDK.SDKLoginConfig")
local UIConst = require("Const.UIConst")
local PSServerConst = require("Const.PSServerConst")
local LoginServerComponent = Class.LightClass("LoginServerComponent", UIComponent)
local OVERSEA_SERVER_ID_KEY_FORMAT = "oversea_serverId_%s"
local OVERSEA_SERVER_NAME_KEY_FORMAT = "oversea_serverName_%s"
local LEGACY_OVERSEA_SERVER_ID_KEY = "oversea_serverId_$s"

function LoginServerComponent._getOverseaSDKServerCache(accountId)
	local serverIdKey = string.format(OVERSEA_SERVER_ID_KEY_FORMAT, accountId)
	local serverId = pg.global.prefsCacheUtils:getInt(serverIdKey, -1)
	local isLegacyCache = false

	if serverId == -1 then
		serverId = pg.global.prefsCacheUtils:getInt(LEGACY_OVERSEA_SERVER_ID_KEY, -1)
		isLegacyCache = serverId ~= -1
	end

	local serverNameKey = string.format(OVERSEA_SERVER_NAME_KEY_FORMAT, accountId)
	local serverName = pg.global.prefsCacheUtils:getString(serverNameKey, nil)

	return serverId, serverName, isLegacyCache
end

function LoginServerComponent:_saveOverseaSDKServerCache(accountId, serverId, serverName)
	if not self.overseaSDKNoPS then
		return
	end

	pg.global.prefsCacheUtils:setInt(string.format(OVERSEA_SERVER_ID_KEY_FORMAT, accountId), serverId)
	pg.global.prefsCacheUtils:setString(string.format(OVERSEA_SERVER_NAME_KEY_FORMAT, accountId), serverName)
end

function LoginServerComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.closeUButton = self.objectReference:GetRefValue("closeUButton")
	self.serverListUList = self.objectReference:GetRefValue("serverListUList")
end

function LoginServerComponent:initView()
	self.overseaSDKNoPS = SDKLoginConfig.isEnabled() and self.ctrl:isOverseasWithoutPS()
	self.overseaSDK = SDKLoginConfig.isEnabled() and self.ctrl:isOverseas()
	self.selectServerIndex = nil
	self._needSelectServer = self.overseaSDKNoPS
	self._isInit = nil

	if self.overseaSDKNoPS then
		self:initFromOverseaSDKCache()
	else
		self.selectServerId = pg.global.prefsCacheUtils:getInt("serverId", LOCAL_IP_ID)
		self.selectServerName = pg.global.prefsCacheUtils:getString("serverName", "LOCAL")
	end

	self:addListener()
	self:initRefreshAndSelectedServer()
end

function LoginServerComponent:addListener()
	self:bindHotKey(HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel, function()
		self.closeUButton.luaClick()
	end)

	function self.view.serverSelectUButton.luaClick()
		if self.ctrl.isInLogin then
			self.ctrl.showInLoginTip()

			return
		end

		self.view.rootUComponent:TryChangePage("server", "open")
		self:initRefreshAndSelectedServer()
	end

	function self.closeUButton.luaClick()
		self.view.rootUComponent:TryChangePage("server", "close")
	end

	function self.serverListUList.luaRenderItem(button, index, data)
		local txtName = button:Find("TxtName"):GetComponent("UBaseText")

		if data.ClusterId == Const.LOGIN_DUMMY_CLUSTERID then
			button:SetActiveQuickly(false)

			button.navForceNonInteractable = true
		end

		local displayName = data.ClusterName
		local prefix = Const.LOGIN_SERVER_NAME_PREFIX[data.LoginServerType]

		if not string.isNilOrEmpty(prefix) then
			displayName = string.format("%s %s", prefix, displayName)
		end

		local displayColor = txtName.color

		if data.LoginServerType == Const.LOGIN_SERVER_TYPE.SHARED then
			displayColor = Color.blue
		end

		local objectReference = button:GetComponent("ObjectReference")
		local stateUComponent = objectReference:GetRefValue("stateUComponent")

		stateUComponent:TryChangePage("State", data.Status)

		txtName.color = displayColor

		ClientTextUtils.setText(txtName, pg.getLocalizationText(displayName))
	end

	function self.serverListUList.luaClick(button, data)
		self:selectServer(data.index)
		self.view.rootUComponent:TryChangePage("server", "close")
	end
end

function LoginServerComponent:initRefreshAndSelectedServer(isFromPullCallback)
	if isFromPullCallback then
		self._isInit = true
	end

	self:refreshServerList()

	if self:refreshSelectedServer() and not self.overseaSDK then
		self:saveDomesticServerCache()
	end

	if self.ctrl and self.ctrl.tryAutoLoginByShellJoin then
		self.ctrl:tryAutoLoginByShellJoin()
	end
end

function LoginServerComponent:hasValidServerList()
	for _, server in ipairs(self.serverList or EMPTY_TABLE) do
		if server.ClusterId ~= Const.LOGIN_DUMMY_CLUSTERID then
			return true
		end
	end

	return false
end

function LoginServerComponent:refreshServerList()
	local dirConf, dirKey = ClientUtils.getDirConf()

	self.serverList = ClientRepo.netHandler:getServerList() or {}

	if not self._isInit and self:hasValidServerList() then
		self._isInit = true
	end

	self.sharedServerMap = {}

	for index, server in ipairs(self.serverList) do
		server.index = index

		if server.LoginServerType == Const.LOGIN_SERVER_TYPE.SHARED then
			self.sharedServerMap[server.ClusterId] = server
		end
	end

	for index, server in ipairs(self.serverList) do
		local sharedData = self.sharedServerMap[server.ClusterId]

		if sharedData ~= nil then
			local lastRefreshTs = sharedData.Custom and sharedData.Custom.lastRefreshTs or 0

			if Time.secondCache - lastRefreshTs > 2 * Const.DIRECTOYR_SERVER_PUSH_INTERVAL then
				server.Status = Const.SERVER_STATUS_CLOSE
			else
				server.Status = Const.SERVER_STATUS_FLUENT
			end
		elseif server.LoginServerType == Const.LOGIN_SERVER_TYPE.LOCAL then
			local isPortOpen = Utils.checkPort(LOCAL_IP_STR or "127.0.0.1", Const.LOCAL_SERVER_QUERY_STATUS_PORT, 0.1)

			server.Status = isPortOpen and Const.SERVER_STATUS_FLUENT or Const.SERVER_STATUS_CLOSE
		elseif server.LoginServerType == Const.LOGIN_SERVER_TYPE.PUBLIC then
			server.Status = Const.SERVER_STATUS_FLUENT
		end

		server.Status = server.Status or Const.SERVER_STATUS_CLOSE
	end

	if self.selectServerIndex == nil and self:hasValidServerList() then
		self.selectServerIndex = 1

		local forceServerName = ClientConfigServerName

		if forceServerName ~= "" then
			local server, index = lume.match(self.serverList, function(v)
				return v.ClusterName == forceServerName
			end)

			if server ~= nil then
				self.selectServerIndex = index
			end
		else
			local server, index = lume.match(self.serverList, function(v)
				return v.ClusterId == self.selectServerId and v.ClusterName == self.selectServerName
			end)

			if server ~= nil then
				self.selectServerIndex = index
			end
		end
	end

	local psServerIndex = self:isPSAutoSelectServer() and self:findUniqueServerIndex(self.serverList) or nil

	if psServerIndex then
		self.selectServerIndex = psServerIndex
	end

	self.serverListUList:SetList(self.serverList)

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_LOGIN_SELECT_SERVER) then
		pg.global.ui.loginSelectServer:setupServerList(self.serverList, psServerIndex)
	end

	if self._needWaitServerList then
		self._needWaitServerList = nil

		self:checkOverseaSDKCache()
	end
end

function LoginServerComponent:refreshSelectedServer()
	local server = self.serverList[self.selectServerIndex]

	if not server or server.ClusterId == nil or server.ClusterId == Const.LOGIN_DUMMY_CLUSTERID or string.isNilOrEmpty(server.ClusterName) then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("refreshSelectedServer default choice invalid, index=%d, serveId=%d, serverName=%s", self.selectServerIndex, self.selectServerId, self.selectServerName, inspect(self.serverList))
		end

		return false
	end

	if server.ClusterId == Const.LOGIN_LOCAL_CLUSTERID then
		server.ClusterId = LOCAL_IP_ID
	end

	self.selectServerId = server.ClusterId
	self.selectServerName = server.ClusterName

	if (UNITY_EDITOR or ClientConfigServerName ~= server.ClusterName) and server.LoginServerType == Const.LOGIN_SERVER_TYPE.PUBLIC then
		-- block empty
	end

	if self.overseaSDK then
		ClientTextUtils.setText(self.view.overseaServerNameUSDFText, server.ClusterName)
	else
		local serverTxtName = self.view.serverSelectUButton:Find("Widget/TxtName"):GetComponent("UBaseText")

		ClientTextUtils.setText(serverTxtName, server.ClusterName)
		self.view.stateUComponent:TryChangePage("State", server.Status)
	end

	self.ctrl:onServerSelected("refreshSelectedServer", self.serverList, self.selectServerIndex, self.selectServerId, self.selectServerName, server)

	return true
end

function LoginServerComponent:updateRecommendServer(serverId, serverName)
	local server, index = lume.match(self.serverList, function(v)
		return v.ClusterId == serverId and v.ClusterName == serverName
	end)

	if server == nil then
		return
	end

	self.recommendServerIndex = index

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_LOGIN_SELECT_SERVER) then
		pg.global.ui.loginSelectServer:refreshRecommendInfo()
	end
end

function LoginServerComponent:selectServerByCluster(clusterId, clusterName)
	local targetClusterId = tostring(clusterId or "")
	local targetClusterName = tostring(clusterName or "")

	if string.isNilOrEmpty(targetClusterId) then
		return false
	end

	local server, index = lume.match(self.serverList or {}, function(v)
		return tostring(v.ClusterId or "") == targetClusterId and (string.isNilOrEmpty(targetClusterName) or tostring(v.ClusterName or "") == targetClusterName) and v.ClusterId ~= Const.LOGIN_DUMMY_CLUSTERID
	end)

	if server == nil then
		logger:warn("selectServerByCluster failed: clusterId=%s clusterName=%s", targetClusterId, targetClusterName)

		return false
	end

	self.recommendServerIndex = index

	if not self:selectServer(index) then
		return false
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_LOGIN_SELECT_SERVER) and pg.global.ui.loginSelectServer.view then
		pg.global.ui.loginSelectServer:refreshRecommendInfo()
	end

	return true
end

function LoginServerComponent:writeToGlobalData()
	local server = self.serverList[self.selectServerIndex]

	if self._needSelectServer or not server or server.ClusterId == nil or server.ClusterId == Const.LOGIN_DUMMY_CLUSTERID or string.isNilOrEmpty(server.ClusterName) then
		return false
	end

	GlobalData.ServerId = server.ClusterId
	GlobalData.ServerName = server.ClusterName

	return true
end

function LoginServerComponent:isPSAutoSelectServer()
	if not self.overseaSDK or self.overseaSDKNoPS or not PSServerConst.isAutoSelectServerEnabled() then
		return false
	end

	return PSServerConst.getServerRegion(pg.global.platform:getPSAccountCountryCode()) ~= nil
end

function LoginServerComponent:findUniqueServerIndex(serverList)
	local serverIndex

	for index, server in ipairs(serverList) do
		if server.ClusterId ~= nil and server.ClusterId ~= Const.LOGIN_DUMMY_CLUSTERID and not string.isNilOrEmpty(server.ClusterName) then
			if serverIndex then
				return nil
			end

			serverIndex = index
		end
	end

	return serverIndex
end

function LoginServerComponent:preparePSAutoSelectServer()
	if not self:isPSAutoSelectServer() then
		return true
	end

	local dirConf = ClientUtils.getDirConf()

	if not dirConf or not dirConf.localDirData then
		return false
	end

	local targetIndex = self:findUniqueServerIndex(dirConf.localDirData)

	if not targetIndex then
		return false
	end

	local targetServer = dirConf.localDirData[targetIndex]
	local targetServerId = targetServer.ClusterId == Const.LOGIN_LOCAL_CLUSTERID and LOCAL_IP_ID or targetServer.ClusterId
	local currentIndex = self:findUniqueServerIndex(self.serverList)
	local currentServer = self.serverList[self.selectServerIndex]

	if currentIndex and currentIndex == self.selectServerIndex and currentServer.ClusterId == targetServerId and currentServer.ClusterName == targetServer.ClusterName and self.selectServerId == currentServer.ClusterId and self.selectServerName == currentServer.ClusterName then
		return true
	end

	local serverList = ClientRepo.loginAgent:genPreConfigedServers(dirConf)

	ClientRepo.netHandler:setServerList(serverList)
	self:refreshServerList()

	return self:refreshSelectedServer()
end

function LoginServerComponent:checkOverseaSDKCache()
	if not self.overseaSDKNoPS or not pg.global.sdkManager.isLogin then
		return
	end

	local accountId = LoginServerComponent._getSDKAccountId()

	if accountId == nil then
		return
	end

	local cachedServerId, cachedServerName = LoginServerComponent._getOverseaSDKServerCache(accountId)
	local server, index

	if cachedServerId ~= Const.LOGIN_DUMMY_CLUSTERID and not string.isNilOrEmpty(cachedServerName) then
		server, index = lume.match(self.serverList, function(v)
			return v.ClusterId == cachedServerId and v.ClusterName == cachedServerName
		end)

		if server == nil and not self._isInit then
			self._needWaitServerList = true

			return
		end
	end

	self._needWaitServerList = nil

	if server then
		self:selectServer(index)

		if pg.global.ui:checkUIOpen(UIConst.UI_ID_LOGIN_SELECT_SERVER) then
			pg.global.ui.loginSelectServer:setupServerList(self.serverList, index, true)
		end
	elseif self._needSelectServer or not self:selectServer(self.selectServerIndex) then
		self:openSelectServerPanel()
	end
end

function LoginServerComponent:openSelectServerPanel(useCurrentSelection)
	self._needSelectServer = self.overseaSDKNoPS

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_LOGIN_SELECT_SERVER) then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_LOGIN_SELECT_SERVER, {
		serverList = self.serverList,
		selectServerIndex = useCurrentSelection and self.selectServerIndex or nil,
		callback = function(selectServerIndex)
			self:selectServer(selectServerIndex)
		end
	})
end

function LoginServerComponent:selectServer(index)
	self.selectServerIndex = index

	if not self:refreshSelectedServer() then
		return false
	end

	if self.overseaSDKNoPS then
		self._needSelectServer = false

		local accountId = pg.global.sdkManager.isLogin and LoginServerComponent._getSDKAccountId()

		if accountId then
			self:_saveOverseaSDKServerCache(accountId, self.selectServerId, self.selectServerName)
		end
	elseif not self.overseaSDK then
		self:saveDomesticServerCache()
	end

	return true
end

function LoginServerComponent:saveDomesticServerCache()
	pg.global.prefsCacheUtils:setInt("serverId", self.selectServerId)
	pg.global.prefsCacheUtils:setString("serverName", self.selectServerName)
end

function LoginServerComponent:initFromOverseaSDKCache()
	local accountId = LoginServerComponent._getSDKAccountId()

	if accountId == nil then
		return
	end

	local cachedServerId, cachedServerName = LoginServerComponent._getOverseaSDKServerCache(accountId)

	if cachedServerId ~= -1 and not string.isNilOrEmpty(cachedServerName) then
		self.selectServerId, self.selectServerName = cachedServerId, cachedServerName
	end
end

function LoginServerComponent._getSDKAccountId()
	local accountId = pg.global.sdkManager:getAccountId()

	if accountId == nil then
		return pg.global.sdkManager.tmpAccountId
	end

	return accountId
end

return LoginServerComponent
