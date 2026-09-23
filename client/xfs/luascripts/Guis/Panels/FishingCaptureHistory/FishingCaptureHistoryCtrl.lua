-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FishingCaptureHistory\\FishingCaptureHistoryCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("FishingCaptureHistoryCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local MessageName = require("Const.MessageName")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PuppetData = require("Data.puppet_data")
local PetData = require("Data.pet_data")
local FishingCaptureHistoryCtrl = Class.LightClass("FishingCaptureHistoryCtrl", UICtrl)

FishingCaptureHistoryCtrl.messages = {
	[MessageName.FISHING_CAPTURE_HISTORY_DATA] = {
		"onHistoryDataRefresh",
		true
	}
}

function FishingCaptureHistoryCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function FishingCaptureHistoryCtrl:addListener()
	function self.view.btnPreUButton.luaClick()
		if self.model:tryPrevPage() then
			self:refreshList()
		end
	end

	function self.view.btnNextUButton.luaClick()
		if self.model:tryNextPage() then
			self:refreshList()
		end
	end

	function self.view.listUList.luaRenderItem(button, index, data)
		self:renderItem(button, index, data)
	end

	function self.view.btnCloseUButton.luaClick()
		self:dismiss()
	end

	function self.view.btnCornerCloseUButton.luaClick()
		self:dismiss()
	end
end

function FishingCaptureHistoryCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:refreshStaticInfo()

	local history = pg.me and pg.me.fishingCaptureSettleHistory

	self.model:setHistoryList(history)
	self:refreshList()
end

function FishingCaptureHistoryCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function FishingCaptureHistoryCtrl:onHistoryDataRefresh()
	local history = pg.me and pg.me.fishingCaptureSettleHistory

	self.model:setHistoryList(history)
	self:refreshList()
end

function FishingCaptureHistoryCtrl:refreshStaticInfo()
	ClientTextUtils.setText(self.view.txtTitleUBaseText, pg.getGameString("FC_HISTORY_TITLE"))
	ClientTextUtils.setText(self.view.textUBaseText, pg.getGameString("FC_HISTORY_SUBTITLE"))
	ClientTextUtils.setText(self.view.txtNameUBaseText, pg.getGameString("FC_HISTORY_COL_RESULT"))
	ClientTextUtils.setText(self.view.txtCostUBaseText, pg.getGameString("FC_HISTORY_COL_COST"))
	ClientTextUtils.setText(self.view.txtTimeUBaseText, pg.getGameString("FC_HISTORY_COL_TIME"))
end

function FishingCaptureHistoryCtrl:refreshList()
	local isEmpty = self.model:isEmpty()

	self.view.widget:TryChangePage("Empty", isEmpty and 1 or 0)

	if not isEmpty then
		self.view.listUList:SetList(self.model:getCurrentPageData())
	end

	self:refreshPageButtons()
end

function FishingCaptureHistoryCtrl:refreshPageButtons()
	local cur, total = self.model:getPageInfo()

	self.view.btnPreUButton.interactable = cur > 1
	self.view.btnNextUButton.interactable = cur < total

	ClientTextUtils.setText(self.view.inputFieldUTMPInputField, string.format("%d / %d", cur, total))
end

function FishingCaptureHistoryCtrl:_iconSpriteName(itemId)
	local iconUrl = LuaUIUtils.getIconByItemId(itemId) or ""

	if #iconUrl > 5 then
		iconUrl = string.sub(iconUrl, 2, -5)
	end

	return iconUrl
end

function FishingCaptureHistoryCtrl:renderItem(button, index, entry)
	local ref = button:GetComponent("ObjectReference")
	local txtTimeUBaseText = ref:GetRefValue("txtTimeUBaseText")
	local list1UList = ref:GetRefValue("list1UList")
	local list2UList = ref:GetRefValue("list2UList")

	button:TryChangePage("BgType", index % 2 == 0 and "Nml" or "Light")

	local record = entry.record
	local rewardParts = {}

	if entry.petTemplateId then
		local petData = PetData[entry.petTemplateId]
		local petName = petData and petData.name and pg.getLocalizationText(petData.name) or ""

		if petName ~= "" then
			rewardParts[#rewardParts + 1] = {
				text = petName
			}
		end
	end

	if entry.sortedItemIds then
		for _, itemId in ipairs(entry.sortedItemIds) do
			local count = record.rewards and record.rewards[itemId] or 0

			rewardParts[#rewardParts + 1] = {
				text = string.format("<sprite name=\"%s_small\">%s", self:_iconSpriteName(itemId), pg.LocalizationNumber(count))
			}
		end
	end

	if #rewardParts == 0 then
		rewardParts[1] = {
			text = "—"
		}
	end

	if list1UList then
		function list1UList.luaRenderItem(cell, idx, data)
			self:_renderRichTextCell(cell, data)
		end

		list1UList:SetList(rewardParts)
	end

	local costParts = {}

	if record.ballUsedMap then
		for ballItemId, count in pairs(record.ballUsedMap) do
			costParts[#costParts + 1] = {
				text = string.format("<sprite name=\"%s_small\">%s", self:_iconSpriteName(ballItemId), pg.LocalizationNumber(count))
			}
		end
	end

	if #costParts == 0 then
		costParts[1] = {
			text = "—"
		}
	end

	if list2UList then
		function list2UList.luaRenderItem(cell, idx, data)
			self:_renderRichTextCell(cell, data)
		end

		list2UList:SetList(costParts)
	end

	local timeStr = ""

	if record.settleTime and record.settleTime > 0 then
		timeStr = LuaUIUtils.timeStampToUtcString(record.settleTime)
	end

	ClientTextUtils.setText(txtTimeUBaseText, timeStr)
end

function FishingCaptureHistoryCtrl:_renderRichTextCell(cell, data)
	if not cell then
		return
	end

	local ref = cell:GetComponent("ObjectReference")

	if not ref then
		return
	end

	local txtUBaseText = ref:GetRefValue("txtNumUSDFText")

	if txtUBaseText then
		ClientTextUtils.setText(txtUBaseText, data and data.text or "")
	end
end

return FishingCaptureHistoryCtrl
