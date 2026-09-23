-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerDailyReward\\TowerDailyRewardCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("TowerDailyRewardCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local TowerDailyRewardCtrl = Class.LightClass("TowerDailyRewardCtrl", UICtrl)
local RogueUtils = require("Utils.RogueUtils")
local RogueDailyRewardData = require("Data.rogue_daily_reward_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")

TowerDailyRewardCtrl.messages = {
	[MessageName.ROGUE_DAILY_REWARD_UPDATE] = {
		"refreshCurReward",
		true
	}
}

function TowerDailyRewardCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:initUI()
end

function TowerDailyRewardCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	function self.view.getRewardUButton.luaClick()
		pg.me:getDailyReward()
	end

	function self.view.btnInfoUButton.luaClick()
		pg.global.ui.tips:openRogPopTips(Const.COMMON_POPUP_TIP_ID.ROGUE_DAILY_REWARD)
	end
end

function TowerDailyRewardCtrl:initUI()
	function self.view.rewardPreviewUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")

		self.rewardUList = objectReference:GetRefValue("rewardUList")
		self.conditionUBaseText = objectReference:GetRefValue("conditionUBaseText")
		self.curUBaseText = objectReference:GetRefValue("curUBaseText")

		button:TryChangePage("Stage", data.stage)

		if data.stage == 0 then
			ClientTextUtils.setText(self.curUBaseText, pg.getGameString("ROGUE_DAILY_REWARD_CUR"))
		end

		ClientTextUtils.setText(self.conditionUBaseText, data.desc)
		LuaUIUtils.setRewardListByDropId(self.rewardUList, data.dropId)
	end

	ClientTextUtils.setText(self.view.titleUBaseText, pg.getGameString("ROGUE_DAILY_REWARD_TITLE"))
	ClientTextUtils.setText(self.view.getRewardUText, pg.getGameString("OBTAIN_REWARD"))
	ClientTextUtils.setText(self.view.receivedUBaseText, pg.getGameString("ROGUE_DAILY_REWARD_RECEIVED"))

	self.dailyRewardLv = RogueUtils.getCurDailyRewardLevel()

	local data = {}

	for index, value in ipairs(RogueDailyRewardData) do
		local stage = index < self.dailyRewardLv and 2 or 1

		if index == self.dailyRewardLv then
			stage = 0
		end

		table.insert(data, {
			dropId = value.rewardId,
			desc = pg.getLocalizationText(value.title),
			stage = stage
		})
	end

	self.view.rewardPreviewUList:SetList(data)

	local gotoIndex = math.max(self.dailyRewardLv - 2, 0)

	self.view.rewardPreviewUList:GoToIndex(gotoIndex, true)
	self:refreshCurReward()

	function self.view.rewardPreviewUList.luaFinishRender()
		self:refreshGamepadDefaultFocus(self.dailyRewardLv)
	end
end

function TowerDailyRewardCtrl:refreshGamepadDefaultFocus(idx)
	local res, btn = self.view.rewardPreviewUList:TryGetChildAt(idx - 1)

	if res then
		local objRef = btn:GetComponent("ObjectReference")
		local defaultItem = objRef:GetRefValue("panelBtnUButton")

		pg.global.navMgr:FocusItem(defaultItem)
	end
end

function TowerDailyRewardCtrl:refreshCurReward()
	local dropDatas = {}

	if pg.me.rogueHarvestPendingRewards and #pg.me.rogueHarvestPendingRewards > 0 then
		self.view.rootUComponent:TryChangePage("Stage", 0)
		self.view.rewardUBaseText:SetActive(true)

		local rewardCount = #pg.me.rogueHarvestPendingRewards
		local rewardMax = 7
		local textTip = pg.getGameString("ROGUE_DAILY_REWARD_TIP")

		textTip = string.gsub(textTip, "{rewardCount}", rewardCount)
		textTip = string.gsub(textTip, "{rewardMax}", rewardMax)

		ClientTextUtils.setText(self.view.rewardUBaseText, textTip)

		for _, value in ipairs(pg.me.rogueHarvestPendingRewards) do
			table.insert(dropDatas, {
				canGet = true,
				dropId = value
			})
		end
	else
		self.view.rootUComponent:TryChangePage("Stage", 1)
		self.view.rewardUBaseText:SetActive(false)

		local dropId = RogueDailyRewardData[self.dailyRewardLv] and RogueDailyRewardData[self.dailyRewardLv].rewardId or 0

		table.insert(dropDatas, {
			dropId = dropId
		})
	end

	LuaUIUtils.setRewardListByDropIdsBatch(self.view.curRewardUList, dropDatas)
end

function TowerDailyRewardCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function TowerDailyRewardCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function TowerDailyRewardCtrl:onShow()
	return
end

function TowerDailyRewardCtrl:onHide()
	return
end

return TowerDailyRewardCtrl
