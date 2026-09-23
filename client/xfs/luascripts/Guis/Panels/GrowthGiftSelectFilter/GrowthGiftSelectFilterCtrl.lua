-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrowthGiftSelectFilter\\GrowthGiftSelectFilterCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local GrowthGiftSelectFilterCtrl = Class.LightClass("GrowthGiftSelectFilterCtrl", UICtrl)

GrowthGiftSelectFilterCtrl.messages = {}

function GrowthGiftSelectFilterCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.doFilterCallback = info and info.doFilterCallback
	self.selectedElements = {}
	self.selectedPetTypes = {}

	if info and info.selectedElements then
		for k, v in pairs(info.selectedElements) do
			self.selectedElements[k] = v
		end
	end

	if info and info.selectedPetTypes then
		for k, v in pairs(info.selectedPetTypes) do
			self.selectedPetTypes[k] = v
		end
	end

	self:setupFilterList()
	self:refreshActionButtons()
	ClientTextUtils.setText(self.view.txtType, pg.getGameString("PRISMANA_GIFTS_FILTER"))
end

function GrowthGiftSelectFilterCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:closePanel()
	end

	function self.view.cleanBtn.luaClick()
		self:clearSelection()
	end

	function self.view.confirmBtn.luaClick()
		self:doFilter()
	end
end

function GrowthGiftSelectFilterCtrl:setupFilterList()
	local filterListData = {
		{
			tIndex = 1,
			title = pg.getGameString("FILTER_ELEMENT")
		},
		{
			tIndex = 0,
			filterType = "element",
			items = self.model:getAllElements()
		},
		{
			tIndex = 1,
			title = pg.getGameString("FILTER_ROLE")
		},
		{
			tIndex = 2,
			filterType = "petType",
			items = self.model:getAllPetTypes()
		}
	}

	function self.view.filterList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")

		if data.tIndex == 1 then
			local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")

			ClientTextUtils.setText(txtTitleUSDFText, data.title)

			return
		end

		local listItemUList = objectReference:GetRefValue("listItemUList")

		if not listItemUList then
			return
		end

		function listItemUList.luaRenderItem(itemBtn, itemIdx, itemData)
			local itemRef = itemBtn:GetComponent("ObjectReference")
			local iconUImage = itemRef:GetRefValue("iconUImage")

			if iconUImage and itemData.icon then
				iconUImage.url = itemData.icon
			end

			if data.tIndex == 2 then
				local txtUSDFText = itemRef:GetRefValue("txtUSDFText")

				ClientTextUtils.setText(txtUSDFText, itemData.name)
			end

			local filterKey = itemData.type or itemData.name
			local selectedMap = data.filterType == "petType" and self.selectedPetTypes or self.selectedElements
			local selected = selectedMap[filterKey] ~= nil

			itemBtn.isSelected = selected

			itemBtn:TryChangePage("button", selected and 5 or 0)

			function itemBtn.luaClick()
				selectedMap = data.filterType == "petType" and self.selectedPetTypes or self.selectedElements

				if selectedMap[filterKey] ~= nil then
					selectedMap[filterKey] = nil
					itemBtn.isSelected = false

					itemBtn:TryChangePage("button", 0)
				else
					selectedMap[filterKey] = filterKey
					itemBtn.isSelected = true

					itemBtn:TryChangePage("button", 5)
				end

				self:refreshActionButtons()
			end
		end

		listItemUList:SetList(data.items)
	end

	self.view.filterList:SetList(filterListData)
end

function GrowthGiftSelectFilterCtrl:hasSelectedFilters()
	return next(self.selectedElements) ~= nil or next(self.selectedPetTypes) ~= nil
end

function GrowthGiftSelectFilterCtrl:refreshActionButtons()
	local hasSelected = self:hasSelectedFilters()
	local page = hasSelected and 0 or 4

	self.view.cleanBtn:TryChangePage("button", page)

	self.view.cleanBtn.interactable = hasSelected

	self.view.confirmBtn:TryChangePage("button", page)

	self.view.confirmBtn.interactable = hasSelected
end

function GrowthGiftSelectFilterCtrl:clearSelection()
	self.selectedElements = {}
	self.selectedPetTypes = {}

	local groupBtns = self.view.filterList:GetAllButtons()

	for i = 0, groupBtns.Length - 1 do
		local data = groupBtns[i].dataFromUList

		if data and (data.tIndex == 0 or data.tIndex == 2) then
			local groupRef = groupBtns[i]:GetComponent("ObjectReference")
			local listItemUList = groupRef:GetRefValue("listItemUList")

			if listItemUList then
				local itemBtns = listItemUList:GetAllButtons()

				for j = 0, itemBtns.Length - 1 do
					itemBtns[j].isSelected = false

					itemBtns[j]:TryChangePage("button", 0)
				end
			end
		end
	end

	self:refreshActionButtons()
end

function GrowthGiftSelectFilterCtrl:doFilter()
	if self.doFilterCallback then
		self.doFilterCallback(Utils.deepCopyTable(self.selectedElements), Utils.deepCopyTable(self.selectedPetTypes))
	end

	self:closePanel()
end

function GrowthGiftSelectFilterCtrl:closePanel()
	pg.global.ui:close(UIConst.UI_ID_GROW_GIFT_SELECT_FILTER)
end

function GrowthGiftSelectFilterCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function GrowthGiftSelectFilterCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function GrowthGiftSelectFilterCtrl:onShow()
	return
end

function GrowthGiftSelectFilterCtrl:onHide()
	return
end

return GrowthGiftSelectFilterCtrl
