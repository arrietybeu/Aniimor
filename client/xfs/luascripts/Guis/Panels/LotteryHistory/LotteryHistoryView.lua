-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LotteryHistory\\LotteryHistoryView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LotteryHistoryView = Class.LightClass("LotteryHistoryView", UIView)

function LotteryHistoryView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnCloseUButton = LuaUIUtils.safeGetRefValue(objectReference, "btnCloseUButton")
	self.txtTitleUBaseText = LuaUIUtils.safeGetRefValue(objectReference, "txtTitleUBaseText")
	self.btnCornerCloseUButton = LuaUIUtils.safeGetRefValue(objectReference, "btnCornerCloseUButton")
	self.textUBaseText = LuaUIUtils.safeGetRefValue(objectReference, "textUBaseText")
	self.txtNameUBaseText = LuaUIUtils.safeGetRefValue(objectReference, "txtNameUBaseText")
	self.txtCostUBaseText = LuaUIUtils.safeGetRefValue(objectReference, "txtCostUBaseText")
	self.txtTimeUBaseText = LuaUIUtils.safeGetRefValue(objectReference, "txtTimeUBaseText")
	self.listUList = LuaUIUtils.safeGetRefValue(objectReference, "listUList")
	self.numSelectorUNumSelector = LuaUIUtils.safeGetRefValue(objectReference, "numSelectorUNumSelector")
end

function LotteryHistoryView:registerObjects()
	if self.listUList then
		function self.listUList.luaRenderItem(button, index, data)
			self:renderHistoryItem(button, index, data)
		end
	end
end

function LotteryHistoryView:initView()
	ClientTextUtils.setText(self.textUBaseText, pg.getGameString("LOTTERY_HISTORY_DESC"))
	ClientTextUtils.setText(self.txtNameUBaseText, pg.getGameString("LOTTERY_HISTORY_TITLE_1"))
	ClientTextUtils.setText(self.txtCostUBaseText, pg.getGameString("LOTTERY_HISTORY_TITLE_2"))
	ClientTextUtils.setText(self.txtTimeUBaseText, pg.getGameString("LOTTERY_HISTORY_TITLE_3"))

	if self.txtTitleUBaseText then
		ClientTextUtils.setText(self.txtTitleUBaseText, pg.getGameString("LOTTERY_HISTORY"))
	end

	if self.listUList then
		self.listUList:SetList({})
	end
end

function LotteryHistoryView:renderHistoryItem(button, index, data)
	local objectReference = button and button:GetComponent("ObjectReference") or nil
	local txtQuality = LuaUIUtils.safeGetRefValue(objectReference, "txtQuality")
	local txtName = LuaUIUtils.safeGetRefValue(objectReference, "txtName")
	local txtTime = LuaUIUtils.safeGetRefValue(objectReference, "txtTime")

	if txtQuality then
		ClientTextUtils.setText(txtQuality, data and data.quality or "")
	end

	if txtName then
		ClientTextUtils.setText(txtName, data and data.name or "")
	end

	if txtTime then
		ClientTextUtils.setText(txtTime, data and data.time or "")
	end
end

function LotteryHistoryView:setHistoryList(historyList)
	historyList = historyList or {}

	if self.widget then
		self.widget:TryChangePage("Empty", #historyList == 0 and 1 or 0)
	end

	if self.listUList then
		self.listUList:SetList(historyList)
	end
end

return LotteryHistoryView
