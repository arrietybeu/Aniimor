-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsTalent\\GrabEggsTalentCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("GrabEggsTalentCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local RedDotConst = require("Const.RedDotConst")
local ItemConst = require("Common.Const.ItemConst")
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TimerManager = require("Core.Timer.TimerManager")
local STATE_PAGE = {
	unlocked = 3,
	["disabled-broadcast"] = 2,
	["unlocked-FX"] = 1,
	unlockable = 0,
	locked = 0
}
local LINE_PAGE = {
	right = "RightLine",
	left = "LeftLine",
	mid = "MidLine"
}
local TIP_STAGE = {
	["disabled-broadcast"] = 1,
	unlocked = 2,
	unlockable = 0,
	locked = 1
}
local ALL_TEXT = {
	PROGRESS = "GRAB_EGG_TALENT_PROGRESS",
	UNLOCK_COST = "GRAB_EGG_TALENT_UNLOCK_COST",
	BROADCAST = "GRAB_EGG_TALENT_UNAVAILABLE",
	TALENT_TREE_THREE = "GRAB_EGG_TALENT_RIGHTTITLE",
	FAIL_REASON_STATE = "GRAB_EGG_TALENT_FAIL_REASON_STATE",
	TALENT_TREE_TWO = "GRAB_EGG_TALENT_MIDTITLE",
	FAIL_REASON_ITEM = "GRAB_EGG_TALENT_FAIL_REASON_ITEM",
	TALENT_TREE_ONE = "GRAB_EGG_TALENT_LEFTTITLE",
	FAIL_REASON_COIN = "GRAB_EGG_TALENT_FAIL_REASON_COIN",
	TITLE_NAME = "GRAB_EGG_TALENT_TITLE",
	UNLOCKED = "GRAB_EGG_TALENT_UNLOCKED",
	UNLOCK_PRENODE = "GRAB_EGG_TALENT_UNLOCK_PRENODE",
	UNLOCK = "GRAB_EGG_TALENT_UNLOCK"
}
local ITEM_TIP_PADDING = 32
local GrabEggsTalentCtrl = Class.LightClass("GrabEggsTalentCtrl", UICtrl)

GrabEggsTalentCtrl.messages = {
	[MessageName.GRAB_EGG_TALENT_UNLOCKED] = {
		"refreshUI",
		true
	},
	[MessageName.MONEY_COUNT_CHANGE] = {
		"refreshUI",
		true
	},
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"refreshUI",
		true
	}
}

function GrabEggsTalentCtrl:checkOpenExtra()
	if not pg.me or not pg.me:grabEgg_isTalentEntryUnlocked() then
		return false, pg.getGameString("GRAB_EGG_TALENT_ENTRY_LOCKED_TIP")
	end

	return true
end

function GrabEggsTalentCtrl:refreshUI()
	self:refreshAll()
	self.view.listUList:SetList(self.model:getRows())
end

function GrabEggsTalentCtrl:_setConsoleBarCheck(show)
	pg.global.navMgr:SetConsoleBarState("ConsolrBar_Talent_isCheck", show)
	pg.global.navMgr:UpdateHotkeyActivationState()
end

function GrabEggsTalentCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self._focusTalentId = info and info[1]

	self:addListener()
	self:refreshAll()
	self:InitUI()
	self:_tryFocusTalent()
end

function GrabEggsTalentCtrl:_tryFocusTalent()
	local id = self._focusTalentId

	if not id then
		return
	end

	self._focusTalentId = nil

	local rowIdx, lineCol = self.model:getRowIndexByTalentId(id)

	if not rowIdx then
		return
	end

	self.view.listUList:GoToIndex(rowIdx - 1, true)
	TimerManager.addNextFrameCb(function()
		local ok, rowBtn = self.view.listUList:TryGetChildAt(rowIdx - 1)

		if not ok or not rowBtn then
			return
		end

		local listSkillUList = rowBtn:GetComponent("ObjectReference"):GetRefValue("listSkillUList")

		if not listSkillUList then
			return
		end

		local ok2, slotItem = listSkillUList:TryGetChildAt(lineCol - 1)

		if ok2 and slotItem and slotItem.enabledTooltip then
			slotItem:OpenTooltip()
		end
	end)
end

function GrabEggsTalentCtrl:InitUI()
	self:_setConsoleBarCheck(true)
end

function GrabEggsTalentCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	if self.view.btnInfoUButton then
		self.view.btnInfoUButton.enabledTooltip = false

		function self.view.btnInfoUButton.luaClick()
			pg.global.ui.tips:openRogPopTips(Const.COMMON_POPUP_TIP_ID.GRAB_EGG_TALENT_INFO)
		end
	end

	self:bindCloseButton()

	function self.view.listUList.luaRenderItem(button, index, rowData)
		self:renderTalentItem(button, index, rowData)
	end

	self.view.listUList:SetList(self.model:getRows())
	self:_setConsoleBarCheck(true)
end

function GrabEggsTalentCtrl:renderTalentItem(button, index, rowData)
	local oc = button:GetComponent("ObjectReference")

	self:renderThreeLine(oc, rowData)

	local listSkillUList = oc:GetRefValue("listSkillUList")

	function listSkillUList.luaRenderItem(slotItem, slotIdx, slot)
		if slot.empty then
			slotItem.enabledTooltip = false
			slotItem.interactable = false

			if slot.lineThrough then
				slotItem:TryChangePage("MidLine", slot.lineThroughUnlocked and 1 or 0)
			else
				slotItem:TryChangePage("Empty", 1)
			end

			return
		end

		slotItem.enabledTooltip = slot.state ~= "disabled-broadcast"
		slotItem.interactable = slot.state ~= "disabled-broadcast"

		self:renderSlotItem(slotItem, slot)
	end

	listSkillUList:SetList(rowData.slots)
end

function GrabEggsTalentCtrl:renderThreeLine(oc, rowData)
	local lineInfo = self.model:getRowLines(rowData.lineId, rowData.row)

	for _, key in ipairs(self.model.LINE_KEYS) do
		local widget = oc:GetRefValue(key .. "UImage")
		local threeLineUWidget = oc:GetRefValue("threeLineUWidget")
		local info = lineInfo[key]

		if widget then
			widget.gameObject:SetActiveEx(info.show)

			if info.show then
				local prefix = key:match("^(%a-)Line")
				local pageName = LINE_PAGE[prefix]

				if pageName then
					threeLineUWidget:TryChangePage(pageName, info.unlocked and 1 or 0)
				end
			end
		end
	end
end

function GrabEggsTalentCtrl:renderSlotItem(slotItem, slot)
	slotItem:TryChangePage("Stage", STATE_PAGE[slot.state] or 0)

	slotItem.isSelected = self.selectedSlotItem == slotItem

	local iconImg = slotItem:GetComponent("ObjectReference"):GetRefValue("iconUImage")

	iconImg.url = slot.config.talentIcon

	local redDotPath = string.format(RedDotConst.RedDotPath.GRAB_EGG_MODE_TALENT_BTN_NODE, slot.id)

	pg.global.setRedDot(redDotPath, slotItem, self.model:nodeShowRedDot(slot.id), RedDotConst.RedDotStyle.UP_HIGH)

	function slotItem.luaTooltipPopup(_, flag)
		if flag then
			if self.selectedSlotItem and self.selectedSlotItem ~= slotItem then
				self.selectedSlotItem.isSelected = false
			end

			self.selectedSlotItem = slotItem

			self:_setConsoleBarCheck(false)
		else
			if self.selectedSlotItem == slotItem then
				self.selectedSlotItem = nil
			end

			if self.selectedSlotItem == nil then
				TimerManager.addNextFrameCb(function()
					if self.selectedSlotItem == nil then
						self:_setConsoleBarCheck(true)
					end
				end)
			end
		end

		slotItem.isSelected = flag
	end

	function slotItem.luaRenderTooltip(btn, cmp)
		self:renderTooltip(cmp, slot, slotItem)
	end
end

function GrabEggsTalentCtrl:renderTooltip(tipPrefab, slot, slotItem)
	local ref = tipPrefab:GetComponent("ObjectReference")

	tipPrefab:TryChangePage("Frame", slot.tIndex - 1)
	tipPrefab:TryChangePage("Stage", TIP_STAGE[slot.state] or 0)

	local iconUImage = ref:GetRefValue("iconUImage")

	if iconUImage then
		iconUImage.url = slot.config.talentIcon
	end

	local iconUImage = ref:GetRefValue("iconConsumeUImage")

	if iconUImage then
		iconUImage.url = LuaUIUtils.getIconByItemId(ItemConst.ITEM_SPECIAL_MONEY_ROBEGG)
	end

	ClientTextUtils.setText(ref:GetRefValue("skillNameUSDFText"), pg.getLocalizationText(slot.config.talentName))
	ClientTextUtils.setText(ref:GetRefValue("detailTextUSDFText"), pg.getLocalizationText(slot.config.des))

	local txt
	local have = pg.me:getItemCountById(ItemConst.ITEM_SPECIAL_MONEY_ROBEGG)
	local need = slot.config.baseCost or 0

	if have < need then
		txt = string.format("<color=#F67574>%d</color>", need)
	else
		txt = need
	end

	ClientTextUtils.setText(ref:GetRefValue("textUSDFText"), pg.getGameString(ALL_TEXT.UNLOCK_COST))
	ClientTextUtils.setText(ref:GetRefValue("txtNameUSDFText"), pg.getGameString(ALL_TEXT.UNLOCK))

	local info = LuaUIUtils.getItemInfoById(ItemConst.ITEM_SPECIAL_MONEY_ROBEGG)

	ClientTextUtils.setText(ref:GetRefValue("coinUSDFText"), pg.getLocalizationText(info.name))
	ClientTextUtils.setText(ref:GetRefValue("txtNumUSDFText"), txt)

	if TIP_STAGE[slot.state] == 1 then
		ClientTextUtils.setText(ref:GetRefValue("UnlockedTextUSDFText"), pg.getGameString(ALL_TEXT.UNLOCK_PRENODE))
	end

	if TIP_STAGE[slot.state] == 2 then
		ClientTextUtils.setText(ref:GetRefValue("UnlockedTextUSDFText"), pg.getGameString(ALL_TEXT.UNLOCKED))
	end

	local itemList = ref:GetRefValue("listUList")

	if itemList then
		function itemList.luaRenderItem(item, _, data)
			LuaUIUtils.renderItem(item, data)

			function item.luaClick()
				self:_openTooltipCostItemTip(tipPrefab, data)
			end

			local numTxt = item:GetComponent("ObjectReference"):GetRefValue("txtNumUText")

			if numTxt then
				local have = pg.me:getItemCountById(data.id)
				local need = data.num
				local txt

				if have < need then
					txt = string.format("<color=#F67574>%d</color>/%d", have, need)
				else
					txt = string.format("%d/%d", have, need)
				end

				ClientTextUtils.setText(numTxt, txt)
			end
		end

		local itemCostList = {}

		for i, pair in ipairs(slot.config.itemCost or EMPTY_TABLE) do
			itemCostList[i] = {
				hierarchyMode = 1,
				sortingOrder = 30001,
				id = pair[1],
				num = pair[2]
			}
		end

		local hasData = next(itemCostList) ~= nil

		itemList.transform.parent.gameObject:SetActiveEx(hasData and TIP_STAGE[slot.state] ~= 2)
		itemList:SetList(itemCostList)
	end

	self:_renderTooltipBtn(ref, slot, slotItem)
end

function GrabEggsTalentCtrl:_openTooltipCostItemTip(tipPrefab, data)
	if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
		pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)

		return
	end

	pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
		autoHor = true,
		id = data.id,
		num = data.num,
		targetRect = tipPrefab,
		hierarchyMode = data.hierarchyMode,
		sortingOrder = data.sortingOrder,
		verAlign = CS.XGUI.EVerticalAlignment.Top,
		padding = ITEM_TIP_PADDING
	})
end

function GrabEggsTalentCtrl:_renderTooltipBtn(ref, slot, slotItem)
	if slot.state ~= "unlockable" then
		return
	end

	local btnConfirm = ref:GetRefValue("btnConfirmUButton")

	if not btnConfirm then
		return
	end

	local canUnlockNow = self.model:canUnlock(slot.id)

	btnConfirm.interactable = canUnlockNow

	function btnConfirm.luaClick()
		local ok, reason = self.model:tryUnlock(slot.id)

		if ok then
			pg.game.audio:playEvent("SFX_UI_Unlock_Buff")
			self.model:markNodeRedDotRead(slot.id)

			if slotItem then
				slotItem:TryChangePage("Stage", STATE_PAGE["unlocked-FX"])
			end
		else
			if reason == "state" then
				pg.global.showBubbleMessageRaw(pg.getGameString(ALL_TEXT.FAIL_REASON_STATE), 2)
			end

			if reason == "coin" then
				pg.global.showBubbleMessageRaw(pg.getGameString(ALL_TEXT.FAIL_REASON_COIN), 2)
			end

			if reason == "item" then
				pg.global.showBubbleMessageRaw(pg.getGameString(ALL_TEXT.FAIL_REASON_ITEM), 2)
			end
		end
	end
end

function GrabEggsTalentCtrl:refreshAll()
	ClientTextUtils.setText(self.view.tMPUSDFText, pg.getGameString(ALL_TEXT.TITLE_NAME))
	ClientTextUtils.setText(self.view.textUSDFText, pg.getGameString(ALL_TEXT.BROADCAST))

	for lineId = 1, 3 do
		local progress = self.model:getLineProgress(lineId)
		local isOpen = self.model:isLineOpen(lineId)
		local mainText = self.view["text" .. lineId .. "USDFText"]
		local subText = self.view["text" .. lineId .. "SubUSDFText"]

		if lineId == 1 then
			ClientTextUtils.setText(mainText, pg.getGameString(ALL_TEXT.TALENT_TREE_ONE))
		end

		if lineId == 2 then
			ClientTextUtils.setText(mainText, pg.getGameString(ALL_TEXT.TALENT_TREE_TWO))
		end

		if lineId == 3 then
			ClientTextUtils.setText(mainText, pg.getGameString(ALL_TEXT.TALENT_TREE_THREE))
		end

		if subText then
			if isOpen then
				subText.supportRichText = true

				local s = pg.getFormatText("<b><style=Nml_L>{0}</style>/{1}</b>", progress.unlocked, progress.total)

				ClientTextUtils.setText(subText, s)
			else
				ClientTextUtils.setText(subText, pg.getGameString(ALL_TEXT.BROADCAST))
			end
		end
	end

	if self.view.listCurrencyUList then
		LuaUIUtils.setTopCurrencyItemList(self.view.listCurrencyUList, nil, {
			ItemConst.ITEM_SPECIAL_MONEY_ROBEGG
		})
	end
end

function GrabEggsTalentCtrl:renderCurrencyItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local countUText = objectReference:GetRefValue("countUText")

	if iconUImage then
		iconUImage.url = LuaUIUtils.getIconByItemId(ItemConst.ITEM_SPECIAL_MONEY_ROBEGG)
	end

	if countUText then
		ClientTextUtils.setText(countUText, pg.me:getMoneyNum(ItemConst.ITEM_SPECIAL_MONEY_ROBEGG))
	end

	function button.luaClick()
		if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
			pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)

			return
		end

		pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
			autoHor = true,
			id = ItemConst.ITEM_SPECIAL_MONEY_ROBEGG,
			num = pg.me:getMoneyNum(ItemConst.ITEM_SPECIAL_MONEY_ROBEGG),
			targetRect = button
		})
	end
end

function GrabEggsTalentCtrl:refreshConsoleBarState()
	local noSelection = self.selectedSlotItem == nil

	pg.global.navMgr:SetConsoleBarState("ConsolrBar_Talent_isCheck", noSelection)
end

function GrabEggsTalentCtrl:onDestroy()
	pg.global.navMgr:SetConsoleBarState("ConsolrBar_Talent_isCheck", true)
	UICtrl.onDestroy(self)
end

return GrabEggsTalentCtrl
