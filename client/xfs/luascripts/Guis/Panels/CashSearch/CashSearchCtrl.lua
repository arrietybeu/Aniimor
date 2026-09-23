-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashSearch\\CashSearchCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local CashSearchModel = require("Guis.Panels.CashSearch.CashSearchModel")
local CashSearchView = require("Guis.Panels.CashSearch.CashSearchView")
local SysConfigData = require("Data.sys_config_data")
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local CashSearchCtrl = Class.LightClass("CashSearchCtrl", UICtrl)

CashSearchCtrl.modelClz = CashSearchModel
CashSearchCtrl.viewClz = CashSearchView
CashSearchCtrl.messages = {}

function CashSearchCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self.model:setTabId(info.tabId)
	self.model:setDisplayGender(info.gender)
	self.view:setupSearchView()
	self:addListener()
end

function CashSearchCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:_showHistory()
end

function CashSearchCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function CashSearchCtrl:onShow()
	return
end

function CashSearchCtrl:onHide()
	return
end

function CashSearchCtrl:addListener()
	function self.view.btnBGClose.luaClick()
		self:dismiss()
	end

	function self.view.btnClose.luaClick()
		self:dismiss()
	end

	if self.view.inputFieldUTMPInputField then
		function self.view.inputFieldUTMPInputField.luaValueChanged(text)
			self:_onInputChanged(text)
		end
	end

	if self.view.btnDeleteUButton then
		self.view.btnDeleteUButton.gameObject:SetActiveEx(false)

		function self.view.btnDeleteUButton.luaClick()
			self.view:setInputText("")
		end
	end

	function self.view.listUList.luaRenderItem(button, index, data)
		self:_renderListItem(button, index, data)

		function button.luaClick()
			self:_onListItemClick(button, data)
		end
	end
end

function CashSearchCtrl:_onInputChanged(text)
	if self.view.btnDeleteUButton then
		self.view.btnDeleteUButton.gameObject:SetActiveEx(text ~= nil and text ~= "")
	end

	if not text or text == "" then
		self:_showHistory()
	else
		local listData = self.model:search(text)

		if #listData == 0 then
			self.view:setListData({}, true)
		else
			self.view:setListData(listData)
		end
	end
end

function CashSearchCtrl:_showHistory()
	local historyList = self.model:getSearchHistoryList()

	if #historyList == 0 then
		local emptyHeader = {
			{
				tIndex = 0,
				subText = "SHOP_SEARCH_LIST_NONE",
				isGameString = true,
				tabName = "SHOP_SEARCH_LIST"
			}
		}

		self.view:setListData(emptyHeader)
	else
		table.insert(historyList, 1, {
			tIndex = 0,
			isGameString = true,
			tabName = "SHOP_SEARCH_LIST"
		})
		self.view:setListData(historyList)
	end
end

function CashSearchCtrl:_renderListItem(button, index, data)
	local tIndex = data.tIndex

	if tIndex == 0 then
		self:_renderGroupTitle(button, data)
	elseif tIndex == 1 or tIndex == 2 then
		self:_renderCommodityItem(button, data)
	elseif tIndex == 3 then
		self:_renderHistoryItem(button, data)
	end
end

function CashSearchCtrl:_renderGroupTitle(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textUBaseText = objectReference:GetRefValue("textUBaseText")
	local text1UBaseText = objectReference:GetRefValue("text1UBaseText")

	if textUBaseText then
		if data.isGameString then
			ClientTextUtils.setText(textUBaseText, pg.getGameString(data.tabName))
		else
			ClientTextUtils.setText(textUBaseText, pg.getLocalizationText(data.tabName))
		end
	end

	if text1UBaseText then
		if data.subText then
			text1UBaseText.gameObject:SetActiveEx(true)
			ClientTextUtils.setText(text1UBaseText, pg.getGameString(data.subText))
		else
			text1UBaseText.gameObject:SetActiveEx(false)
		end
	end
end

function CashSearchCtrl:_renderCommodityItem(button, data)
	ClientCashShopUtils.renderCommodityItem(button, data)

	local keyword = self.model:getKeyword()

	if not keyword or keyword == "" then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local txtTitle = objectReference:GetRefValue("txtTitle")

	if not txtTitle then
		return
	end

	local titleText = data.name and pg.getLocalizationText(data.name) or LuaUIUtils.getNameByItemId(data.itemId)

	if not titleText or titleText == "" then
		return
	end

	local highlight = SysConfigData.SHOPMALL_SEARCH_HIGHLIGHT

	if not highlight then
		return
	end

	local lowerTitle = string.lower(titleText)
	local lowerKeyword = string.lower(keyword)
	local result = ""
	local lastEnd = 1
	local startIdx, endIdx = string.find(lowerTitle, lowerKeyword, 1, true)

	while startIdx do
		result = result .. string.sub(titleText, lastEnd, startIdx - 1)
		result = result .. pg.getFormatText(highlight, string.sub(titleText, startIdx, endIdx))
		lastEnd = endIdx + 1
		startIdx, endIdx = string.find(lowerTitle, lowerKeyword, lastEnd, true)
	end

	result = result .. string.sub(titleText, lastEnd)

	ClientTextUtils.setText(txtTitle, result)
end

function CashSearchCtrl:_renderHistoryItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

	if txtNameUBaseText then
		ClientTextUtils.setText(txtNameUBaseText, data.keyword or "")
	end
end

function CashSearchCtrl:_onListItemClick(button, data)
	if self._handlingClick then
		return
	end

	self._handlingClick = true

	local tIndex = data.tIndex

	if tIndex == 1 or tIndex == 2 then
		local keyword = self.model:getKeyword()

		self.model:addSearchHistory(keyword)

		local tabId = self.model:getTabId()
		local groupId = data.tabGroupId
		local commodityId = data.commodityId

		self:dismiss()
		self:startFrameTimer(function()
			if not ClientCashShopUtils.canOpenCashShop() then
				return
			end

			if pg.global.ui:checkUIOpen(UIConst.UI_ID_CASH_SHOP) then
				pg.global.ui.cashShop:navigateTo(tabId, groupId, commodityId)
			elseif pg.global.platform:isPS() and RechargeUtils.isEmptyStore() then
				PlatformBridgeLuaFacade.ShowCommonMessageDialogEmptyStore()
			else
				pg.global.ui:open(UIConst.UI_ID_CASH_SHOP, {
					tabId = tabId,
					groupId = groupId,
					commodityId = commodityId
				})
			end
		end, 1)
	elseif tIndex == 3 then
		self.model:addSearchHistory(data.keyword)
		self.view:setInputText(data.keyword)
	end

	self._handlingClick = false
end

return CashSearchCtrl
