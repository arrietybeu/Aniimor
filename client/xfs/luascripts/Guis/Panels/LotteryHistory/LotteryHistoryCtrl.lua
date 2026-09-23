-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LotteryHistory\\LotteryHistoryCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local Utils = require("Common.Utils.Utils")
local LotteryHistoryModel = require("Guis.Panels.LotteryHistory.LotteryHistoryModel")
local LotteryHistoryCtrl = Class.LightClass("LotteryHistoryCtrl", UICtrl)

LotteryHistoryCtrl.modelClz = LotteryHistoryModel
LotteryHistoryCtrl.messages = {}

function LotteryHistoryCtrl:addListener()
	if self.view.btnCloseUButton then
		function self.view.btnCloseUButton.luaClick()
			self:dismiss()
		end
	end

	if self.view.btnCornerCloseUButton then
		function self.view.btnCornerCloseUButton.luaClick()
			self:dismiss()
		end
	end

	if self.view.numSelectorUNumSelector then
		function self.view.numSelectorUNumSelector.luaValueChanged(pageIndex)
			if self._lockPageSelector then
				return
			end

			self.model:setPageIndex(pageIndex)
			self:refreshHistoryPage()
		end
	end
end

function LotteryHistoryCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	local drawId = Utils.isTable(info) and info.drawId or nil
	local pageSize

	if self.view.listUList and self.view.listUList.GetPageCapacity then
		pageSize = self.view.listUList:GetPageCapacity()
	end

	self.model:setPageSize(pageSize)
	self.model:refreshHistory(drawId)
	self:syncPageSelector()
	self:refreshHistoryPage()
end

function LotteryHistoryCtrl:syncPageSelector()
	local pageSelector = self.view.numSelectorUNumSelector

	if not pageSelector then
		return
	end

	self._lockPageSelector = true

	pageSelector:SetAllValue(self.model:getPageIndex(), 1, self.model:getTotalPages(), 1)

	self._lockPageSelector = false
end

function LotteryHistoryCtrl:refreshHistoryPage()
	self.view:setHistoryList(self.model:getCurrentPageList())
end

return LotteryHistoryCtrl
