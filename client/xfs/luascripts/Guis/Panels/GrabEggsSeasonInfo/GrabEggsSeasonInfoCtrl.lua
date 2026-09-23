-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsSeasonInfo\\GrabEggsSeasonInfoCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local GrabEggsSeasonInfoCtrl = Class.LightClass("GrabEggsSeasonInfoCtrl", UICtrl)
local UIConst = require("Const.UIConst")
local RedDotConst = require("Const.RedDotConst")
local MessageName = require("Const.MessageName")
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TimeUtils = require("Common.Utils.TimeUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local NoticeDef = require("Common.NoticeDef")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local TimerManager = require("Core.Timer.TimerManager")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro

GrabEggsSeasonInfoCtrl.messages = {
	[MessageName.GRAB_EGG_REWARD_BOX_CHANGED] = {
		"onRewardBoxChanged",
		true
	},
	[MessageName.GRAB_EGG_RANK_CHANGED] = {
		"onRankChanged",
		true
	}
}

function GrabEggsSeasonInfoCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function GrabEggsSeasonInfoCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:onBackClick()
	end

	self:bindCloseButton(self.view.btnCloseUButton)

	local rewardPreviewCloseBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "rewardPreviewCloseBind")

	rewardPreviewCloseBind.isVirtual = true
	rewardPreviewCloseBind.priority = 1
	rewardPreviewCloseBind.actionPath = "Common/ClosePanelCommon"

	function rewardPreviewCloseBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" and self:tryCloseRewardPreview() then
			return false
		end

		return true
	end

	if self.view.btnRewardDetailUButton then
		function self.view.btnRewardDetailUButton.luaClick()
			self:showRewardPreview()
		end
	end

	if self.view.btnInfoUButton then
		self.view.btnInfoUButton.enabledTooltip = false

		function self.view.btnInfoUButton.luaClick()
			pg.global.ui.tips:openRogPopTips(Const.COMMON_POPUP_TIP_ID.GRAB_EGG_SEASON_BOX_INFO)
		end
	end

	if self.view.popupRewardBtnCloseUButton then
		function self.view.popupRewardBtnCloseUButton.luaClick()
			self:tryCloseRewardPreview()
		end
	end

	function self.view.popupRewardCloseUButton.luaClick()
		self:tryCloseRewardPreview()
	end

	function self.view.btnBackUButton.luaClick()
		self:tryCloseRewardPreview()
	end

	function self.view.popupRewardListUList.luaRenderItem(button, _, data)
		self:renderRewardPreviewItem(button, data)
	end

	self.slotButtons = {}

	function self.view.listRewardUList.luaRenderItem(button, index, data)
		self.slotButtons[index] = button

		self:renderRewardItem(button, index, data)
	end
end

function GrabEggsSeasonInfoCtrl:tryCloseRewardPreview()
	if self.rewardPreviewCloseGuard then
		return true
	end

	if not self.rewardPreviewVisible then
		return false
	end

	self.rewardPreviewCloseGuard = true

	TimerManager.addNextFrameCb(function()
		self.rewardPreviewCloseGuard = false
	end)
	self:setRewardPreviewVisible(false)

	return true
end

function GrabEggsSeasonInfoCtrl:onBackClick()
	if self:tryCloseRewardPreview() then
		return
	end

	self:close()
end

function GrabEggsSeasonInfoCtrl:onShow()
	self:setRewardPreviewVisible(false)
	self:startTimer(function()
		self:refreshBoxList()
	end, 0.75, false)
	self:refreshUI()
end

function GrabEggsSeasonInfoCtrl:refreshUI()
	local seasonInfo = self.model:getSeasonDisplayInfo()

	if seasonInfo then
		ClientTextUtils.setText(self.view.txtNumUSDFText, seasonInfo.numText)
		ClientTextUtils.setText(self.view.txtNameUSDFText, seasonInfo.name)
		ClientTextUtils.setText(self.view.text2USDFText, seasonInfo.timeText)
	end

	ClientTextUtils.setText(self.view.txtRewardDetailUSDFText, pg.getGameString("GRAB_EGG_SEASON_REWARD_PREVIEW"))
	ClientTextUtils.setText(self.view.txtRuleUSDFText, pg.getGameString("GRAB_EGG_SEASON_RULE"))
	ClientTextUtils.setText(self.view.txtTitleUSDFText, pg.getGameString("GRABEGG_LUCKYCHEST_TITLE"))
	ClientTextUtils.setText(self.view.txtResetUSDFText, pg.getGameString("GRABEGG_LUCKYCHEST_RESET"))

	local dailyInfo = self.model:getDailyBoxStatus()

	if dailyInfo then
		ClientTextUtils.setText(self.view.txtSubUSDFText, string.format(pg.getGameString("GRABEGG_LUCKYCHEST_OBTAI"), dailyInfo.acquired .. "/" .. dailyInfo.limit))
	end

	self:startDailyResetCount()

	local info = self.model:getRankDisplayInfo()

	if not info then
		return
	end

	self.view.iconUImage.url = info.icon:gsub("%.png$", "_small.png")

	ClientTextUtils.setText(self.view.tagNameUSDFText, info.name)
end

function GrabEggsSeasonInfoCtrl:setRewardPreviewVisible(visible)
	self.rewardPreviewVisible = visible

	self.view.popupRewardUWidget:SetActive(visible)
end

function GrabEggsSeasonInfoCtrl:showRewardPreview()
	ClientTextUtils.setText(self.view.popupRewardTitleUSDFText, pg.getGameString("GRAB_EGG_SEASON_REWARD_PREVIEW"))
	self.view.popupRewardListUList:SetList(self.model:getBoxRewardPreviewList())
	self:setRewardPreviewVisible(true)
end

function GrabEggsSeasonInfoCtrl:renderRewardPreviewItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")

	if objectReference == nil or IsNil(objectReference) then
		return
	end

	local iconUImage = objectReference:GetRefValue("iconUImage")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local listUList = objectReference:GetRefValue("listUList")

	iconUImage.url = data.icon

	ClientTextUtils.setText(txtNameUSDFText, data.name)

	function listUList.luaRenderItem(rewardButton, _, rewardData)
		LuaUIUtils.renderRewardItem(rewardButton, rewardData, nil, nil, nil, nil, function(sourceData)
			local sourceParam = sourceData and sourceData.param
			local sourceEvent = sourceParam and sourceParam[1]
			local isOpenUI = sourceEvent == "openUI" or sourceEvent == "openUISuper"
			local openUIParam = isOpenUI and sourceParam[2]
			local isSelfJump = Utils.isTable(openUIParam) and openUIParam[1] == self.uid

			self:setRewardPreviewVisible(false)

			if not isSelfJump then
				self:close()
			end
		end)
	end

	listUList:SetList(data.rewards)
end

function GrabEggsSeasonInfoCtrl:startDailyResetCount()
	if self.dailyTimer then
		self:killTimer(self.dailyTimer)
	end

	local function refresh()
		local remainSec = TimeUtils.getServerNextDayBegin(Time.secondCache) - Time.secondCache

		if remainSec <= 0 then
			self:killTimer(self.dailyTimer)

			self.dailyTimer = nil

			return
		end

		ClientTextUtils.setText(self.view.textUSDFText, LuaUIUtils.getCountDownString(remainSec, UIConst.TimeType.Short, true))
	end

	refresh()

	self.dailyTimer = self:startTimer(refresh, 1, true)
end

function GrabEggsSeasonInfoCtrl:refreshDailyCount()
	local dailyInfo = self.model:getDailyBoxStatus()

	if dailyInfo then
		local s = pg.getFormatText("<b><style=Hint_BgL>{0}</style>/{1}</b>", dailyInfo.acquired, dailyInfo.limit)

		ClientTextUtils.setText(self.view.txtSubUSDFText, string.format(pg.getGameString("GRABEGG_LUCKYCHEST_OBTAI"), s))
	end
end

function GrabEggsSeasonInfoCtrl:refreshBoxList()
	self.slotButtons = {}
	self.currentSlots = self.model:buildBoxSlotList()

	self.view.listRewardUList:SetList(self.currentSlots)
	self:resetBoxTimer()
	self:refreshDailyCount()
end

function GrabEggsSeasonInfoCtrl:clearAllSlotRedDots()
	if not self.currentSlots then
		return
	end

	for i = 1, #self.currentSlots do
		local path = string.format(RedDotConst.RedDotPath.GRAB_EGG_MODE_REWARD_BOX_BIGITEM, i)

		pg.global.setRedDot(path, nil, false, RedDotConst.RedDotStyle.NONE)
	end
end

function GrabEggsSeasonInfoCtrl:renderRewardItem(button, index, data)
	local redDotPath = string.format(RedDotConst.RedDotPath.GRAB_EGG_MODE_REWARD_BOX_BIGITEM, index)

	pg.global.setRedDot(redDotPath, button, data.isReady == true, RedDotConst.RedDotStyle.REWARD)

	if data.isLocked then
		button:TryChangePage("Stage", 0)

		function button.luaClick()
			local rankName = self.model:getSlotUnlockRankName(index + 1)

			pg.global.showBubbleMessage(NoticeDef.ROB_EGG_CHEST_UNLOCK_TIP, rankName)
		end

		return
	end

	if data.isFull then
		button:TryChangePage("Stage", 4)

		function button.luaClick()
			pg.global.showBubbleMessage(NoticeDef.ROB_EGG_CHEST_MAX_DAILY_TIP)
		end

		return
	end

	if data.isEmpty then
		button:TryChangePage("Stage", 1)

		function button.luaClick()
			pg.global.showBubbleMessage(NoticeDef.ROB_EGG_CHEST_GET_TIP)
		end

		return
	end

	if data.isReady then
		button:TryChangePage("Stage", 3)

		function button.luaClick()
			pg.me:serverMsg("RPC_CS_OpenRobEggLevelRewardBox", data.rewardId)
		end

		local oc = button:GetComponent("ObjectReference")
		local textUSDFText = oc:GetRefValue("textUSDFText")
		local iconUImage = oc:GetRefValue("iconUImage")

		iconUImage.url = data.icon

		ClientTextUtils.setText(textUSDFText, pg.getGameString("GRABEGG_LUCKYCHEST_CANGETCHEST"))
	else
		button:TryChangePage("Stage", 2)
		self:updateSlotCountDown(button, data, index)

		local oc = button:GetComponent("ObjectReference")
		local iconUImage = oc:GetRefValue("iconUImage")

		iconUImage.url = data.icon

		function button.luaClick()
			pg.global.showBubbleMessage(NoticeDef.ROB_EGG_CHEST_OPEN_TIP, LuaUIUtils.getCountDownString(data.remainSec, UIConst.TimeType.Short, true))
		end
	end
end

function GrabEggsSeasonInfoCtrl:resetBoxTimer(slots)
	self:killBoxTimer()

	if not self:hasCountingDownSlot() then
		return
	end

	self.boxtimer = self:startTimer(function()
		self:tickCountDown()
	end, 1, true)
end

function GrabEggsSeasonInfoCtrl:hasCountingDownSlot()
	if not self.currentSlots then
		return false
	end

	for _, slot in pairs(self.currentSlots) do
		if slot.id and not slot.isReady then
			return true
		end
	end

	return false
end

function GrabEggsSeasonInfoCtrl:updateSlotCountDown(button, data, index)
	local oc = button:GetComponent("ObjectReference")
	local sliderNmlUSlider = oc:GetRefValue("sliderNmlUSlider")
	local textUSDFText = oc:GetRefValue("textUSDFText")

	if data.isReady then
		button:TryChangePage("Stage", 3)

		if index then
			local redDotPath = string.format(RedDotConst.RedDotPath.GRAB_EGG_MODE_REWARD_BOX_BIGITEM, index)

			pg.global.setRedDot(redDotPath, button, true, RedDotConst.RedDotStyle.REWARD)
		end

		function button.luaClick()
			pg.me:serverMsg("RPC_CS_OpenRobEggLevelRewardBox", data.rewardId)
		end

		if sliderNmlUSlider then
			ClientTextUtils.setText(textUSDFText, pg.getGameString("GRABEGG_LUCKYCHEST_CANGETCHEST"))
		end

		return
	end

	if sliderNmlUSlider then
		sliderNmlUSlider.value = 1 - data.remainSec / data.totalSec
	end

	ClientTextUtils.setText(textUSDFText, LuaUIUtils.getCountDownString(data.remainSec, UIConst.TimeType.Short, true))
end

function GrabEggsSeasonInfoCtrl:tickCountDown()
	if not self.currentSlots then
		return
	end

	local stillCounting = false

	for i, slot in ipairs(self.currentSlots) do
		if slot.id and not slot.isReady then
			local box = pg.me.rewardBoxList and pg.me.rewardBoxList[i]

			if box and box.id ~= 0 then
				local remainSec = math.max(0, (box.timestamp or 0) - Time.secondCache)

				slot.remainSec = remainSec
				slot.isReady = remainSec <= 0

				local btn = self.slotButtons[i - 1]

				if btn then
					self:updateSlotCountDown(btn, slot, i - 1)
				end

				if not slot.isReady then
					stillCounting = true
				end
			end
		end
	end

	if not stillCounting then
		self:killBoxTimer()
	end
end

function GrabEggsSeasonInfoCtrl:killBoxTimer()
	if self.boxtimer then
		self:killTimer(self.boxtimer)

		self.boxtimer = nil
	end
end

function GrabEggsSeasonInfoCtrl:onRewardBoxChanged()
	self:refreshBoxList()
end

function GrabEggsSeasonInfoCtrl:onRankChanged()
	self:refreshBoxList()
end

function GrabEggsSeasonInfoCtrl:onDestroy()
	self:killBoxTimer()

	self.currentSlots = nil
	self.slotButtons = nil

	if self.dailyTimer then
		self:killTimer(self.dailyTimer)

		self.dailyTimer = nil
	end

	UICtrl.onDestroy(self)
end

return GrabEggsSeasonInfoCtrl
