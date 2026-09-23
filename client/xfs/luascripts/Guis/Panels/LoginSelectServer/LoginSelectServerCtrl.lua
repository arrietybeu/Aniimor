-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LoginSelectServer\\LoginSelectServerCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("LoginSelectServerCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Const = require("Common.Const.Const")
local LoginSelectServerCtrl = Class.LightClass("LoginSelectServerCtrl", UICtrl)
local GlobalData = require("Core.Client.GlobalData")

LoginSelectServerCtrl.messages = {}

function LoginSelectServerCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function LoginSelectServerCtrl:addListener()
	function self.view.listServerUList.luaRenderItem(button, index, data)
		self:onRenderServerItem(button, index, data)
	end

	function self.view.listServerUList.luaClick(button, data)
		if self.selectBtn then
			self.selectBtn.isSelected = false
		end

		self.selectBtn = button
		button.isSelected = true
		self.selectServerIndex = data.index
		self._hasManualSelection = true
	end

	function self.view.btnSureUButton.luaClick()
		self:onClickSure()
	end
end

function LoginSelectServerCtrl:onDestroy()
	UICtrl.onDestroy(self)

	self.selectBtn = nil
	self.serverList = nil
	self.callback = nil
	self.selectServerIndex = nil
	self._hasManualSelection = nil
	self.recommendServerIndex = nil
	self.tempServerListData = nil
	self.tempSelectServerIndex = nil
end

function LoginSelectServerCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self._hasManualSelection = nil

	if self.tempServerListData then
		self:initServerList(self.tempServerListData)

		self.tempServerListData = nil

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("use temp serverListData")
		end
	else
		self:initServerList(info.serverList)
	end

	self.callback = info.callback
	self.selectServerIndex = self.tempSelectServerIndex or info.selectServerIndex
	self.tempSelectServerIndex = nil

	if not self.selectServerIndex then
		self:findRecommend()
	end
end

function LoginSelectServerCtrl:initServerList(serverList)
	self.serverList = {}

	for _, v in ipairs(serverList) do
		if v.ClusterId ~= Const.LOGIN_DUMMY_CLUSTERID then
			table.insert(self.serverList, v)
		end
	end
end

function LoginSelectServerCtrl:onShow()
	ClientTextUtils.setText(self.view.textTitleUSDFText, pg.getGameString("SELECT_SERVER_1"))
	ClientTextUtils.setText(self.view.txtNameUText, pg.getGameString("SELECT_SERVER_3"))
	self:refreshPanel()
end

function LoginSelectServerCtrl:setupServerList(serverList, selectServerIndex, preserveManualSelection)
	if self.view then
		self:initServerList(serverList)

		if preserveManualSelection and self._hasManualSelection and lume.match(self.serverList, function(v)
			return v.index == self.selectServerIndex
		end) then
			selectServerIndex = nil
		end

		if selectServerIndex then
			self.selectServerIndex = selectServerIndex
			self._hasManualSelection = nil
		end

		if not lume.match(self.serverList, function(v)
			return v.index == self.selectServerIndex
		end) then
			self._hasManualSelection = nil

			self:findRecommend()
		end

		self:refreshPanel()
	else
		self.tempServerListData = serverList
		self.tempSelectServerIndex = selectServerIndex or self.tempSelectServerIndex
	end
end

function LoginSelectServerCtrl:refreshRecommendInfo()
	self.view.listServerUList:RefreshList()
end

function LoginSelectServerCtrl:findRecommend()
	local defaultServer = GlobalData.DefaultServerManager

	if self.serverList then
		for _, v in ipairs(self.serverList) do
			if v.ClusterId == defaultServer.defaultClusterId and v.ClusterName == defaultServer.defaultClusterName then
				self.selectServerIndex = v.index

				return
			end
		end
	end

	local firstServer = self.serverList and self.serverList[1]

	self.selectServerIndex = firstServer and firstServer.index or nil
end

function LoginSelectServerCtrl:refreshPanel()
	self.view.listServerUList:SetList(self.serverList)
end

function LoginSelectServerCtrl:onRenderServerItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local recommendUWidget = objectReference:GetRefValue("recommendUWidget")
	local textRecommendUSDFText = objectReference:GetRefValue("textRecommendUSDFText")

	if data.ClusterId == Const.LOGIN_DUMMY_CLUSTERID then
		button:SetActiveQuickly(false)
	end

	ClientTextUtils.setText(textRecommendUSDFText, pg.getGameString("SELECT_SERVER_2"))
	ClientTextUtils.setText(txtNameUSDFText, pg.getGameString(data.ClusterName))

	local defaultServer = GlobalData.DefaultServerManager

	recommendUWidget:SetActiveFastest(data.ClusterId == defaultServer.defaultClusterId and data.ClusterName == defaultServer.defaultClusterName)

	if self.selectServerIndex == data.index then
		self.selectBtn = button
		button.isSelected = true
	else
		button.isSelected = false
	end
end

function LoginSelectServerCtrl:onClickSure()
	if not lume.match(self.serverList, function(v)
		return v.index == self.selectServerIndex
	end) then
		return
	end

	if self.callback then
		local fn = self.callback

		fn(self.selectServerIndex)

		self.callback = nil
	end

	self:dismiss()
end

return LoginSelectServerCtrl
