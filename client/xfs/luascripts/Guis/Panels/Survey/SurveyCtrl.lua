-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Survey\\SurveyCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local RedDotConst = require("Const.RedDotConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local SurveyCtrl = Class.LightClass("SurveyCtrl", UICtrl)
local logger = LoggerManager.getLogger("SurveyCtrl")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local ClientTextUtils = require("Utils.ClientTextUtils")
local GlobalData = require("Core.Client.GlobalData")

SurveyCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function SurveyCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	if info then
		self.model:parseDataServer(info)
	end

	self.info = self.model:getSurveyList()

	if #self.info < 1 then
		return
	end

	self.view.surveyList:SetList(self.info)
end

function SurveyCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function SurveyCtrl:addListener()
	local exitBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.view.objectReference.gameObject, "SurveyCtrl")

	exitBinding.actionPath = "Common/Cancel"
	exitBinding.isVirtual = true

	function exitBinding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self.view.btnClose.luaClick()
		end
	end

	function self.view.btnClose.luaClick(button, index, data)
		self:dismiss()
	end

	function self.view.surveyList.luaRenderItem(button, index, data)
		self:renderItemInfo(button, index, data)
	end
end

function SurveyCtrl:onShow()
	return
end

function SurveyCtrl:renderItemInfo(button, index, itemData)
	if itemData == nil then
		return
	end

	local itemsComs = self.view:getItemComs(button)

	if itemsComs == nil then
		return
	end

	local language = pg.game.setting and pg.game.setting:getLanguage() or nil
	local uid = pg.me and pg.me.uid or nil

	ClientTextUtils.setText(itemsComs.title, pg.getLocalizationText(Utils.getI18nText(uid, itemData.title, language)))

	local content = pg.getLocalizationText(Utils.getI18nText(uid, itemData.content, language))

	content = string.gsub(content or "", "\\n", "\n")

	ClientTextUtils.setText(itemsComs.tips, content)
	itemsComs.arrow:SetActive(false)

	function itemsComs.questItem.luaClick()
		pg.me:finishFirstDisplaySurvey(itemData.surveyId)

		local uid = pg.me.uid or pg.global.sdkManager:getAccountId()
		local url = string.format("%s?uid=%s", itemData.url, uid)
		local isConsole = pg.global.platform ~= nil and pg.global.platform:isConsole()

		if isConsole then
			local isCn = ClientConfigAppCountry == "cn"
			local qrUrl = isCn and "https://www.yimo.com/survey" or "https://www.aniimo.com/survey"

			url = string.format("%s?uid=%s", qrUrl, uid)
		end

		pg.global.sdkManager:openUrl("SurveyCtrl", "renderItemInfo.url", url)
		self:startTimer(function()
			pg.me:finishSurvey(itemData.surveyId)
			facade:sendMsgToUI(MessageName.RED_DOT_SURVEY_TREE)
			self:dismiss()
		end, 5)
		LuaUIUtils.sendCustomLog(Const.BILogName.SURVEY, {
			clickbanner = itemData.surveyId
		})
	end

	function itemsComs.rewardList.luaRenderItem(button, index, reward)
		LuaUIUtils.renderRewardItem(button, {
			id = reward.id,
			num = reward.num
		})
	end

	local rewardItems = {}

	if next(itemData.reward) ~= nil then
		for i, v in pairs(itemData.reward) do
			local reward = {}

			reward.id = tonumber(i)
			reward.num = v

			table.insert(rewardItems, reward)
		end
	end

	itemsComs.rewardList:SetList(rewardItems)
	LuaUIUtils.setUIViewVisible(itemsComs.rewardList, #rewardItems > 0)

	local isShowRedDot = self.model:redDot_GetSinglePointDotState(itemData.surveyId)
	local treePath = string.format(RedDotConst.RedDotPath.SURVEY_TREE_LIST_ITEM, itemData.surveyId or index)

	pg.global.setRedDot(treePath, itemsComs.questItem, isShowRedDot, RedDotConst.RedDotStyle.REWARD)
	LuaUIUtils.setUIViewVisible(itemsComs.time, itemData.time ~= 0)

	local time = math.round((itemData.time - Time.secondCache) / 3600)
	local timeStr = LuaUIUtils.getCountDownString(time, UIConst.TimeType.Short, true)

	ClientTextUtils.setText(itemsComs.time, string.format(pg.getGameString("SURVEY_COUNTDOWN_TEXT"), timeStr))
end

return SurveyCtrl
