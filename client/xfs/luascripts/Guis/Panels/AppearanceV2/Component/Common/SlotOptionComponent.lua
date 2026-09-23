-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AppearanceV2\\Component\\Common\\SlotOptionComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local ItemQuality = require("Data.item_quality")
local SlotOptionComponent = Class.LightClass("SlotOptionComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local GameConst = CS.FunPlus.WorldX.Const.GameConst

function SlotOptionComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.slotRootTransform = self.objectReference:GetRefValue("slotRootTransform")
	self.slotUList = self.objectReference:GetRefValue("slotUList")
	self.searchUButton = self.objectReference:GetRefValue("searchUButton")
	self.selectorUSelector = self.objectReference:GetRefValue("selectorUSelector")
	self.filterUButton = self.objectReference:GetRefValue("filterUButton")
	self.optionUList = self.objectReference:GetRefValue("optionUList")
	self.roleHideUButton = self.objectReference:GetRefValue("roleHideUButton")
	self.hideUIUButton = self.objectReference:GetRefValue("hideUIUButton")
	self.selectorUText = self.objectReference:GetRefValue("selectorUText")
	self.searchUInputField = self.objectReference:GetRefValue("searchUInputField")
	self.closeUButton = self.objectReference:GetRefValue("closeUButton")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
end

function SlotOptionComponent:initView()
	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
	self.curPresetKey = pg.game.avatar:getPresetKey(pg.me)
end

function SlotOptionComponent:onDestroy()
	UIComponent.onDestroy(self)
end

function SlotOptionComponent:addListener()
	function self.slotUList.luaRenderItem(button, index, data)
		AvatarUtils.renderSlotList(button, index, data)

		if self.ctrl.postRenderSlotList then
			self.ctrl:postRenderSlotList(button, index, data)
		end
	end

	function self.slotUList.luaSelectedChanged(uList)
		local data = uList.selectedItem

		if not data then
			return
		end

		if self.ctrl.onSlotSelectedChanged then
			self.ctrl:onSlotSelectedChanged(data)
		end
	end

	function self.slotUList.luaClick(button, data, navConfirm)
		if self.ctrl.onSlotClicked and not navConfirm then
			self.ctrl:onSlotClicked(self.slotUList.selectedItem, data)
		end
	end

	function self.optionUList.luaRenderItem(button, index, data)
		AvatarUtils.renderOptionList(button, index, data, {
			inVitality = self.ctrl.inVitality == true
		})

		if self.ctrl.postRenderOptionList then
			self.ctrl:postRenderOptionList(button, index, data)
		end
	end

	function self.optionUList.luaSelectedChanged(uList)
		local data = uList.selectedItem

		if self.ctrl.onOptionSelectedChanged then
			self.ctrl:onOptionSelectedChanged(data)
		end
	end

	function self.optionUList.luaClick(button, data)
		local slotData = self.slotUList.selectedItem or {}

		if self.ctrl.onOptionClicked then
			self.ctrl:onOptionClicked(slotData, self.optionUList.selectedItem, data, button)
		end
	end

	function self.selectorUSelector.luaRenderPopup(popup, uList)
		function uList.luaRenderItem(button, index, data)
			local objectReference = button:GetComponent("ObjectReference")
			local txtUText = objectReference:GetRefValue("txtUText")

			ClientTextUtils.setText(txtUText, pg.getLocalizationText(data.text))
		end

		uList:SetList(self.filterRule)
	end

	function self.selectorUSelector.luaSelectedChanged(uList)
		local slotData = self.slotUList.selectedItem or {}
		local selectorData = uList.selectedItem or {}

		ClientTextUtils.setText(self.selectorUText, pg.getLocalizationText(uList.selectedItem.text))

		if not self.ctrl.onFilterSelectedChanged then
			return
		end

		self.filterBy = selectorData.filterBy

		self.ctrl:onFilterSelectedChanged(slotData, function(info)
			if selectorData.filterBy ~= -1 then
				if self.filterClaim then
					return info[self.filterName] == selectorData.filterBy and info.claimed
				else
					return info[self.filterName] == selectorData.filterBy
				end
			else
				return true
			end
		end)
	end

	function self.filterUButton.luaClick()
		local slotData = self.slotUList.selectedItem or {}

		if not self.ctrl.onFilterClicked then
			return
		end

		self.filterClaim = not self.filterUButton.isSelected

		self.ctrl:onFilterClicked(slotData, function(info)
			if self.filterBy and self.filterBy ~= -1 then
				if self.filterClaim then
					return info[self.filterName] == self.filterBy and info.claimed
				else
					return info[self.filterName] == self.filterBy
				end
			elseif self.filterClaim then
				return info.claimed
			else
				return true
			end
		end)
	end

	function self.searchUButton.luaClick()
		self.rootUComponent:TryChangePage("IsSearch", "Yes")

		local slotData = self.slotUList.selectedItem or {}

		self.ctrl:onSearchChanged(slotData)
		CS.XGUI.Navigation.NavManager.Instance:FocusItem(self.searchUInputField)
	end

	self.searchUInputField.characterLimit = 14

	ClientTextUtils.setText(self.searchUInputField.placeHolder, pg.getGameString("AVATAR_SEARCH_PLACEHOLDER"))

	function self.searchUInputField.luaValueChanged(text)
		local slotData = self.slotUList.selectedItem or {}

		if not self.ctrl.onSearchChanged then
			return
		end

		self.ctrl:onSearchChanged(slotData, function(info)
			if string.isNilOrEmpty(text) then
				return true
			else
				local name = pg.getLocalizationText(info.name)
				local startPos = string.find(name, text)

				return startPos and true or false
			end
		end)
	end

	function self.closeUButton.luaClick()
		self.rootUComponent:TryChangePage("IsSearch", "No")
		ClientTextUtils.setText(self.searchUInputField, "")

		local slotData = self.slotUList.selectedItem or {}

		self.ctrl:onSearchChanged(slotData)
	end

	function self.hideUIUButton.luaClick()
		AvatarUtils.onHideUIClicked(self.hideUIUButton)
	end

	function self.roleHideUButton.luaClick()
		return
	end

	self.roleHideUButton.gameObject:SetActiveEx(false)
end

function SlotOptionComponent:removeListener()
	self.slotUList.luaRenderItem = nil
	self.slotUList.luaSelectedChanged = nil
	self.slotUList.luaClick = nil
	self.optionUList.luaRenderItem = nil
	self.optionUList.luaSelectedChanged = nil
	self.optionUList.luaClick = nil
	self.selectorUSelector.luaRenderPopup = nil
	self.selectorUSelector.luaSelectedChanged = nil
	self.filterUButton.luaClick = nil
	self.searchUButton.luaClick = nil
	self.searchUInputField.luaValueChanged = nil
	self.closeUButton.luaClick = nil
end

function SlotOptionComponent:getSlotData(index)
	return self.slotUList.itemData[index]
end

function SlotOptionComponent:getOptionData(index)
	return self.optionUList.itemData[index]
end

function SlotOptionComponent:setFilterRule(filters, filterName)
	self.filterName = filterName or "quality"
	self.filterRule = filters or self:getQualityFilters()

	self.selectorUSelector:SetOptions(self.filterRule)
end

function SlotOptionComponent:getQualityFilters()
	local res = {}

	table.insert(res, {
		filterBy = -1,
		text = pg.getGameString("ALL")
	})

	for index, info in ipairs(ItemQuality) do
		table.insert(res, {
			text = info.name,
			filterBy = index
		})
	end

	return res
end

function SlotOptionComponent:reset()
	self:resetSelector()
	self:resetSearch()
end

function SlotOptionComponent:resetSelector()
	self.selectorUSelector:ForceSelect(0)

	self.filterUButton.isSelected = false
end

function SlotOptionComponent:resetSearch()
	self.rootUComponent:TryChangePage("IsSearch", "No")
	ClientTextUtils.setText(self.searchUInputField, "")
end

return SlotOptionComponent
