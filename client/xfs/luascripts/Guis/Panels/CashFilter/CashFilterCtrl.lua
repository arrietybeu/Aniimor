-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashFilter\\CashFilterCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local CashFilterModel = require("Guis.Panels.CashFilter.CashFilterModel")
local CashFilterView = require("Guis.Panels.CashFilter.CashFilterView")
local CashFilterCtrl = Class.LightClass("CashFilterCtrl", UICtrl)

CashFilterCtrl.modelClz = CashFilterModel
CashFilterCtrl.viewClz = CashFilterView
CashFilterCtrl.messages = {}

function CashFilterCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self._onConfirm = info.onConfirm
	self._onReset = info.onReset

	self.model:setGroupId(info.groupId)
	self.model:restoreState(info.previousState)

	self._listData = self.model:buildListData()

	self.view:setupView()
	self:addListener()
	self.view:setListData(self._listData)
	self:_refreshConfirmButton()
end

function CashFilterCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function CashFilterCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function CashFilterCtrl:onShow()
	return
end

function CashFilterCtrl:onHide()
	return
end

function CashFilterCtrl:addListener()
	function self.view.btnBGClose.luaClick()
		self:dismiss()
	end

	function self.view.btnClose.luaClick()
		self:dismiss()
	end

	function self.view.btnConfirm.luaClick()
		self:_onConfirmClick()
	end

	function self.view.btnReset.luaClick()
		self:_onResetClick()
	end

	function self.view.listUList.luaRenderItem(button, index, data)
		self:_renderListItem(button, index, data)
	end

	function self.view.listUList.luaClick(button, data)
		self:_onListItemClick(button, data)
	end
end

function CashFilterCtrl:_renderListItem(button, index, data)
	local tIndex = data.tIndex

	if tIndex == 0 then
		self:_renderTitle(button, data)
	elseif tIndex == 1 then
		self:_renderFilterItem(button, data)
	elseif tIndex == 2 then
		self:_renderSortItem(button, data)
	end
end

function CashFilterCtrl:_renderTitle(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textUBaseText = objectReference:GetRefValue("textUBaseText")

	if textUBaseText then
		ClientTextUtils.setText(textUBaseText, data.name and pg.getLocalizationText(data.name) or "")
	end
end

function CashFilterCtrl:_renderFilterItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local textShow = objectReference:GetRefValue("textPriceUBaseText")

	if data.filterType == 2 then
		if iconUImage then
			iconUImage.gameObject:SetActiveEx(true)

			iconUImage.url = LuaUIUtils.getIconByItemId(data.currencyId)
		end

		if textShow then
			ClientTextUtils.setText(textShow, data.amount or 0)
		end
	else
		if iconUImage then
			iconUImage.gameObject:SetActiveEx(false)
		end

		if textShow then
			ClientTextUtils.setText(textShow, data.text and pg.getGameString(data.text) or "")
		end
	end

	local selected = self.model:isFilterItemSelected(data.filterId, data.itemIndex)

	button.isSelected = selected
end

function CashFilterCtrl:_renderSortItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local selectorUSelector = objectReference:GetRefValue("selectorUSelector")
	local btnSortUButton = objectReference:GetRefValue("btnSortUButton")
	local rootUComponent = objectReference:GetRefValue("rootUComponent")
	local initIndex = self.model:getSortKeyIndex()

	rootUComponent:TryChangePage("Sort", initIndex ~= 0 and 1 or 0)

	if selectorUSelector then
		local options = {}

		for i, opt in ipairs(data.options) do
			options[i] = {
				sortId = i,
				label = opt.text and pg.getGameString(opt.text) or ""
			}
		end

		selectorUSelector:SetOptions(options)
		selectorUSelector:ForceSelect(initIndex)

		if btnSortUButton then
			btnSortUButton.gameObject:SetActiveEx(initIndex ~= 0)
		end

		function selectorUSelector.luaSelectedChanged(uList)
			local selectedItem = uList.selectedItem

			if selectedItem then
				local idx = uList.selectedIndex + 1
				local opt = data.options[idx]

				if opt then
					self.model:setSortKey(opt.key)
				end

				local isDefault = uList.selectedIndex == 0

				if btnSortUButton then
					if isDefault then
						self.model:setSortAscending(true)
						self:_refreshSortButtonState(btnSortUButton)
					end

					btnSortUButton.gameObject:SetActiveEx(not isDefault)
					rootUComponent:TryChangePage("Sort", not isDefault and 1 or 0)
				end

				self:_refreshConfirmButton()
			end
		end
	end

	if btnSortUButton then
		self:_refreshSortButtonState(btnSortUButton)

		function btnSortUButton.luaClick()
			self.model:toggleSortOrder()
			self:_refreshSortButtonState(btnSortUButton)
		end
	end
end

function CashFilterCtrl:_refreshSortButtonState(btnSortUButton)
	if not btnSortUButton then
		return
	end

	self:startFrameTimer(function()
		local ascending = self.model:isSortAscending()

		btnSortUButton:TryChangePage("Sort", ascending and 0 or 1)
	end, 1)
end

function CashFilterCtrl:_onListItemClick(button, data)
	if data.tIndex ~= 1 then
		return
	end

	self.model:toggleFilterSelection(data.filterId, data.itemIndex)
	self.view.listUList:RefreshList()
	self:_refreshConfirmButton()
end

function CashFilterCtrl:_onConfirmClick()
	if self._onConfirm then
		local filterState = self.model:getFilterState()

		filterState.isFiltering = self.model:isFiltering()

		self._onConfirm(filterState)
	end

	self:dismiss()
end

function CashFilterCtrl:_onResetClick()
	self.model:resetSelections()

	if self._onReset then
		self._onReset()
	end

	self.view.listUList:RefreshList()
	self:_refreshConfirmButton()
end

function CashFilterCtrl:_refreshConfirmButton()
	local hasSelection = self.model:isFiltering()

	self.view.btnConfirm:TryChangePage("button", hasSelection and 0 or 4)
end

return CashFilterCtrl
