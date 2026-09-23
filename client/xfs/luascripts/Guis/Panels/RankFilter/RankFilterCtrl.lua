-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RankFilter\\RankFilterCtrl.lua

local Utils = require("Common.Utils.Utils")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local RankFilterCtrl = Class.LightClass("RankFilterCtrl", UICtrl)

function RankFilterCtrl:addListener()
	UICtrl.addListener(self)

	function self.view.btnCloseUButton.luaClick()
		self:dismiss()
	end

	function self.view.btnConfirmUButton.luaClick()
		self:confirmFilter()
	end

	function self.view.listFilterUList.luaRenderItem(button, _, data)
		self:renderFilterItem(button, data)
	end
end

function RankFilterCtrl:confirmFilter()
	self.onFiltersSelected(Utils.deepCopyTable(self.selectedFilterTypes))
	self:dismiss()
end

function RankFilterCtrl:renderFilterItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtTypeUText = objectReference:GetRefValue("txtTypeUText")
	local btnSwitchUButton = objectReference:GetRefValue("btnSwitchUButton")
	local selected = self.selectedFilterTypes[data.filterType] == true

	ClientTextUtils.setText(txtTypeUText, pg.getGameString(data.textKey))

	button.isSelected = selected

	button:TryChangePage("button", selected and 5 or 0)

	function button.luaClick()
		self:selectFilter(data.filterType)
	end

	btnSwitchUButton.luaClick = button.luaClick
end

function RankFilterCtrl:selectFilter(filterType)
	if filterType == self.allFilterType then
		self.selectedFilterTypes = {
			[filterType] = true
		}
	elseif self.selectedFilterTypes[filterType] == true then
		self.selectedFilterTypes[filterType] = nil

		if next(self.selectedFilterTypes) == nil then
			self.selectedFilterTypes[self.allFilterType] = true
		end
	else
		self.selectedFilterTypes[self.allFilterType] = nil
		self.selectedFilterTypes[filterType] = true
	end

	self.view.listFilterUList:RefreshList()
end

function RankFilterCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	local filterOptions = info.filterOptions

	self.allFilterType = info.allFilterType
	self.selectedFilterTypes = Utils.deepCopyTable(info.selectedFilterTypes)
	self.onFiltersSelected = info.onFiltersSelected

	ClientTextUtils.setText(self.view.titleUSDFText, pg.getGameString("GAMEPAD_FILTER"))
	ClientTextUtils.setText(self.view.txtConfirmUText, pg.getGameString("COMMON_CONFIRM"))
	self.view.listFilterUList:SetList(filterOptions)
end

function RankFilterCtrl:onDestroy()
	self.onFiltersSelected = nil

	UICtrl.onDestroy(self)
end

return RankFilterCtrl
