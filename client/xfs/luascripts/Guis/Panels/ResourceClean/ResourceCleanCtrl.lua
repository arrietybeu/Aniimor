-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ResourceClean\\ResourceCleanCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TimerManager = require("Core.Timer.TimerManager")
local ResourceCleanCtrl = Class.LightClass("ResourceCleanCtrl", UICtrl)

ResourceCleanCtrl.TITLE_TEXT_KEY = "RESOURCE_CLEAN_TITLE"
ResourceCleanCtrl.SELECTED_TIP_TEXT_KEY = "RESOURCE_CLEAN_SELECTED_TIP"
ResourceCleanCtrl.EMPTY_TIP_TEXT_KEY = "RESOURCE_CLEAN_EMPTY_TIP"
ResourceCleanCtrl.EMPTY_SELECT_TIP_TEXT_KEY = "RESOURCE_CLEAN_EMPTY_SELECT_TIP"
ResourceCleanCtrl.CANCEL_TEXT_KEY = "RESOURCE_CLEAN_CANCEL"
ResourceCleanCtrl.CONFIRM_TEXT_KEY = "RESOURCE_CLEAN_CONFIRM"
ResourceCleanCtrl.SELECT_ALL_TEXT_KEY = "RESOURCE_CLEAN_SELECT_ALL"

function ResourceCleanCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.groupList = self.model:getDownloadedPackGroups()

	self:refreshList()
	self:refreshSelectedTips()
end

function ResourceCleanCtrl:addListener()
	if self.view.titleText then
		ClientTextUtils.setText(self.view.titleText, pg.getGameString(ResourceCleanCtrl.TITLE_TEXT_KEY))
	end

	if self.view.rightUpCornerCloseBtn then
		function self.view.rightUpCornerCloseBtn.luaClick()
			self:close()
		end
	end

	if self.view.cancelBtn then
		self:setButtonText(self.view.cancelBtn, ResourceCleanCtrl.CANCEL_TEXT_KEY)

		function self.view.cancelBtn.luaClick()
			self:close()
		end
	end

	if self.view.confirmBtn then
		self:setButtonText(self.view.confirmBtn, ResourceCleanCtrl.CONFIRM_TEXT_KEY)

		function self.view.confirmBtn.luaClick()
			self:onConfirmClean()
		end
	end

	if self.view.listUList then
		function self.view.listUList.luaRenderItem(button, index, data)
			self:renderGroupItem(button, data)
		end
	end
end

function ResourceCleanCtrl:refreshList()
	if self.view.listUList then
		self.view.listUList:SetList(self.groupList)
	end
end

function ResourceCleanCtrl:renderGroupItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	local listUList = objectReference:GetRefValue("listUList")
	local btnAllSelectedUButton = objectReference:GetRefValue("btnAllSelectedUButton")

	ClientTextUtils.setText(txtTitleUSDFText, self:getGroupTitleText(data))

	if btnAllSelectedUButton then
		data._allSelectedButton = btnAllSelectedUButton

		self:setButtonText(btnAllSelectedUButton, ResourceCleanCtrl.SELECT_ALL_TEXT_KEY)
		self:refreshCheckButton(btnAllSelectedUButton, self:isGroupAllSelected(data))

		function btnAllSelectedUButton.luaClick()
			self:onGroupAllSelectedClicked(data, listUList, btnAllSelectedUButton)
		end
	end

	if listUList then
		for _, item in ipairs(data.items) do
			item._groupData = data
		end

		function listUList.luaRenderItem(button1, index1, data1)
			self:renderPackItem(button1, data1)
		end

		listUList:SetList(data.items)
	end
end

function ResourceCleanCtrl:renderPackItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local btnCheckUButton = objectReference:GetRefValue("btnCheckUButton")

	ClientTextUtils.setText(txtNameUSDFText, self:getPackItemText(data))
	self:refreshCheckButton(btnCheckUButton, data.selected)

	local function onClick()
		data.selected = not data.selected

		self:refreshCheckButton(btnCheckUButton, data.selected, true)

		local groupData = data._groupData

		if groupData and groupData._allSelectedButton then
			self:refreshCheckButton(groupData._allSelectedButton, self:isGroupAllSelected(groupData), true)
		end

		self:refreshSelectedTips()
	end

	btnCheckUButton.luaClick = onClick
	button.luaClick = onClick
end

function ResourceCleanCtrl:onGroupAllSelectedClicked(groupData, listUList, btnAllSelectedUButton)
	local selected = not self:isGroupAllSelected(groupData)

	for _, item in ipairs(groupData.items) do
		item.selected = selected
	end

	self:refreshCheckButton(btnAllSelectedUButton, selected, true)

	if listUList then
		listUList:RefreshList()
	end

	self:refreshSelectedTips()
end

function ResourceCleanCtrl:refreshCheckButton(button, selected, refreshNextFrame)
	if not button then
		return
	end

	button:SetSelected(selected == true)
	button:TryChangePage("button", selected and "s_normal" or "normal")

	if refreshNextFrame then
		TimerManager.addNextFrameCb(function()
			if button and not IsNil(button) then
				button:SetSelected(selected == true)
				button:TryChangePage("button", selected and "s_normal" or "normal")
			end
		end)
	end
end

function ResourceCleanCtrl:setButtonText(button, textKey)
	local text = self:findTextComponent(button and button.transform)

	if text then
		ClientTextUtils.setText(text, pg.getGameString(textKey))
	end
end

function ResourceCleanCtrl:findTextComponent(root)
	if not root then
		return nil
	end

	local text = root:GetComponent("USDFText") or root:GetComponent("UBaseText")

	if text then
		return text
	end

	for i = 0, root.childCount - 1 do
		local childText = self:findTextComponent(root:GetChild(i))

		if childText then
			return childText
		end
	end

	return nil
end

function ResourceCleanCtrl:getGroupTitleText(groupData)
	return groupData.name .. "(" .. self:formatSize(groupData.totalSize) .. ")"
end

function ResourceCleanCtrl:getPackItemText(itemData)
	return itemData.name .. "(" .. self:formatSize(itemData.totalSize) .. ")"
end

function ResourceCleanCtrl:formatSize(size)
	if pg.game.resourceDownload then
		return pg.game.resourceDownload:formatDownloadBytes(size or 0)
	end

	return "0B"
end

function ResourceCleanCtrl:isGroupAllSelected(groupData)
	if not groupData.items or #groupData.items <= 0 then
		return false
	end

	for _, item in ipairs(groupData.items) do
		if not item.selected then
			return false
		end
	end

	return true
end

function ResourceCleanCtrl:getSelectedItems()
	local selectedItems = {}
	local totalSize = 0

	for _, group in ipairs(self.groupList or EMPTY_TABLE) do
		for _, item in ipairs(group.items or EMPTY_TABLE) do
			if item.selected then
				selectedItems[#selectedItems + 1] = item
				totalSize = totalSize + (item.totalSize or 0)
			end
		end
	end

	return selectedItems, totalSize
end

function ResourceCleanCtrl:refreshSelectedTips()
	if not self.view.txtTipsUSDFText then
		return
	end

	local selectedItems, totalSize = self:getSelectedItems()

	if #self.groupList <= 0 then
		ClientTextUtils.setText(self.view.txtTipsUSDFText, pg.getGameString(ResourceCleanCtrl.EMPTY_TIP_TEXT_KEY))

		return
	end

	ClientTextUtils.setText(self.view.txtTipsUSDFText, pg.getFormatText(pg.getGameString(ResourceCleanCtrl.SELECTED_TIP_TEXT_KEY), #selectedItems, self:formatSize(totalSize)))
end

function ResourceCleanCtrl:onConfirmClean()
	local selectedItems = self:getSelectedItems()

	if #selectedItems <= 0 then
		pg.global.showBubbleMessageRaw(pg.getGameString(ResourceCleanCtrl.EMPTY_SELECT_TIP_TEXT_KEY))

		return
	end

	if pg.game.resourceDownload and pg.game.resourceDownload:requestCleanPackList(selectedItems) then
		self.groupList = self.model:getDownloadedPackGroups()

		self:refreshList()
		self:refreshSelectedTips()
	end
end

return ResourceCleanCtrl
