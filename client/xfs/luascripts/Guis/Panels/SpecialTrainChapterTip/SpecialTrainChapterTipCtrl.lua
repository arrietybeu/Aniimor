-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SpecialTrainChapterTip\\SpecialTrainChapterTipCtrl.lua

local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local SpecialTrainChapterTipCtrl = Class.LightClass("SpecialTrainChapterTipCtrl", UICtrl)
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local Time = require("Core.Common.Time")
local LuaUIUtils = require("Utils.LuaUIUtils")
local QuestUtils = require("GameApp.Quest.QuestUtils")

SpecialTrainChapterTipCtrl.OPEN_TYPE = {
	START = 1,
	FINISH = 2
}

local START_AIN_TIMER = 2

function SpecialTrainChapterTipCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function SpecialTrainChapterTipCtrl:addListener()
	function self.view.backGroundCloseUButton.luaClick(button, index, data)
		self:dismiss()

		if self.closeCallback then
			self.closeCallback()
		end
	end

	local exitBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.view.rootUComponent.gameObject, "SpecialTrainChapterTipCtrl")

	exitBinding.actionPath = "Common/Cancel"
	exitBinding.isVirtual = true

	function exitBinding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self.view.backGroundCloseUButton.luaClick()
		end
	end
end

function SpecialTrainChapterTipCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	if info ~= nil then
		self.chapterId = info.chapterId or 1
		self.openType = info.openType or self.OPEN_TYPE.START
		self.closeCallback = info.closeCallback
	end

	self:showPanel()
end

function SpecialTrainChapterTipCtrl:showPanel()
	local chapterConfig = QuestUtils.getChapterConfig(self.chapterId)

	self.view.rootUComponent:TryChangePage("ContentState", self.openType == self.OPEN_TYPE.START and 0 or 1)

	local titleText = string.format("%s %s", pg.getLocalizationText(chapterConfig.chapterName), pg.getLocalizationText(chapterConfig.chapterTitleDes))

	ClientTextUtils.setText(self.view.textUBaseText, titleText)

	if self.openType == self.OPEN_TYPE.START then
		self:setChapterStart()
	else
		self:setChapterFinish()
	end

	ClientTextUtils.setText(self.view.rewardBtnTipsUSDFText, pg.getGameString("CONSOLE_BAR_REWARD_DETAILS"))
	ClientTextUtils.setText(self.view.closeUSDFText, pg.getGameString("CONSOLE_BAR_RETURN"))
end

function SpecialTrainChapterTipCtrl:setChapterStart()
	local chapterConfig = QuestUtils.getChapterConfig(self.chapterId)

	if chapterConfig then
		ClientTextUtils.setText(self.view.textTitleUSDFText, pg.getGameString("SPECIAL_TRAIN_NEW_CHAPTER_UNLOCK"))
		ClientTextUtils.setText(self.view.textUSDFText, pg.getLocalizationText(chapterConfig.chapterName))
	end

	self.view.textInfoUSDFText:SetActive(false)
	self:startTimer(function()
		self:dismiss()

		if self.closeCallback then
			self.closeCallback()
		end
	end, START_AIN_TIMER)
end

function SpecialTrainChapterTipCtrl:setChapterFinish()
	local chapterConfig = QuestUtils.getChapterConfig(self.chapterId)

	function self.view.listRewardUList.luaRenderItem(button, index, data)
		button.templateKey = "normal"

		LuaUIUtils.renderRewards(button, index, data)
	end

	local rewardItems = {}
	local temp = LuaUIUtils.getRewardItemByDropId(chapterConfig.rewardId)

	if temp ~= nil and #temp > 0 then
		for i = 1, #temp do
			table.insert(rewardItems, temp[i])
		end
	end

	self.view.listRewardUList:SetList(rewardItems)
	ClientTextUtils.setText(self.view.rewardText, ClientTextUtils.concatByLanguage(pg.getLocalizationText(chapterConfig.chapterName), pg.getGameString("SPECIAL_TRAIN_CHAPTER_FINISH")))

	local timestamp = Time.getSecond()
	local dateTable = os.date("*t", timestamp)
	local timeText = string.format("%d/%02d/%02d", dateTable.year, dateTable.month, dateTable.day)

	ClientTextUtils.setText(self.view.dateText, timeText)
end

function SpecialTrainChapterTipCtrl:onHide()
	return
end

function SpecialTrainChapterTipCtrl:onClosePanel()
	self:dismiss()

	if self.closeCallback then
		self.closeCallback()
	end
end

function SpecialTrainChapterTipCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

return SpecialTrainChapterTipCtrl
