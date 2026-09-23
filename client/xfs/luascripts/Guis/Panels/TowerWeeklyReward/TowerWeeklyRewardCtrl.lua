-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerWeeklyReward\\TowerWeeklyRewardCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("TowerWeeklyRewardCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local RogueWeekBossRewardData = require("Data.rogue_week_boss_reward_data")
local DropData = require("Data.drop_data")
local ItemData = require("Data.item_data")
local UIConst = require("Const.UIConst")
local RogueUtils = require("Utils.RogueUtils")
local RedDotConst = require("Const.RedDotConst")
local Const = require("Common.Const.Const")
local RewardStateUtils = require("Common.Utils.RewardStateUtils")
local TowerWeeklyRewardCtrl = Class.LightClass("TowerWeeklyRewardCtrl", UICtrl)

TowerWeeklyRewardCtrl.messages = {
	[MessageName.ROGUE_WEEKLY_REWARD_UPDATE] = {
		"refreshReward",
		true
	}
}

function TowerWeeklyRewardCtrl:getManagedBlurEffect()
	return self.view and self.view.staticUIBlurEffect
end

function TowerWeeklyRewardCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:initializeManagedBlur()
	self:initUI()
end

function TowerWeeklyRewardCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	function self.view.btnClaimAllUButton.luaClick()
		pg.me:getRogueAllWeeklyReward()
	end

	function self.view.btnInfoUButton.luaClick()
		pg.global.ui.tips:openRogPopTips(Const.COMMON_POPUP_TIP_ID.ROGUE_WEEKLY_REWARD)
	end
end

function TowerWeeklyRewardCtrl:initUI()
	local killCount = pg.me.rogueWeeklyBossKillCount or 0
	local allCount = #RogueWeekBossRewardData

	killCount = math.min(killCount, allCount)

	local isFull = allCount <= killCount

	self.view.bossKillUButton:TryChangePage("status", isFull and 1 or 0)

	local color = isFull and "#e19c17" or "#30384a"
	local killText = string.format("<color=%s>%d</color><size=-6>/%d</size>", color, killCount, allCount)

	ClientTextUtils.setText(self.view.textKillCountUBaseText, killText)
	LuaUIUtils.setCountDownTime(self.view.weekUCountDown, RogueUtils.getWeeklyTime(), UIConst.TimeType.Short)

	self.view.progressUProgress.normalizedValue = killCount / allCount
	self.rewardBtns = {
		self.view.reward1UButton,
		self.view.reward2UButton,
		self.view.reward3UButton,
		self.view.reward4UButton,
		self.view.reward5UButton,
		self.view.reward6UButton
	}

	self:refreshReward()
end

function TowerWeeklyRewardCtrl:refreshReward()
	self.canGet = false

	for i, btn in ipairs(self.rewardBtns) do
		self:setRewardBtn(btn, i)
	end

	RewardStateUtils.applyClaimButton(self.view.btnClaimAllUButton, self.canGet, RedDotConst.RedDotPath.TOWER_WEEKLY_REWARD, true, "claimAll")
end

function TowerWeeklyRewardCtrl:setRewardBtn(btn, index)
	local objectReference = btn:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
	local countUBaseText = objectReference:GetRefValue("countUBaseText")
	local config = RogueWeekBossRewardData[index]

	ClientTextUtils.setText(txtNameUBaseText, config.startPoint)

	local dropConfig = DropData[config.rangeId]
	local displayReward = dropConfig.displayReward[1]
	local itemConfig = ItemData[displayReward[1]]

	iconUImage.url = LuaUIUtils.getIconByItemId(displayReward[1])

	ClientTextUtils.setText(countUBaseText, "x", displayReward[2])

	local quality = itemConfig.quality or 0

	quality = quality - 2
	quality = math.clamp(quality, 0, 3)

	btn:TryChangePage("Quality", quality)

	local canGet = pg.me.rogueWeeklyBossKillCount >= config.startPoint
	local hasGet = pg.me.rogueWeeklyBossRewardInfo and pg.me.rogueWeeklyBossRewardInfo[index] or false
	local state = RewardStateUtils.applyItemState(btn, {
		hasGet = hasGet,
		canGet = canGet and not hasGet
	}, "Status")

	self.canGet = self.canGet or state == RewardStateUtils.State.ReadyToClaim

	function btn.luaClick(navItem)
		if canGet and not hasGet then
			if navItem then
				return
			end

			pg.me:getRogueWeeklyReward(index)
		else
			if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
				pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)

				return
			end

			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
				id = displayReward[1],
				num = displayReward[2],
				targetRect = btn
			})
		end
	end

	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.TOWER_WEEKLY_REWARD_ITEM .. index, btn, function()
		return RogueUtils.getRedDotWeeklyRewardBtnState(index)
	end)
end

function TowerWeeklyRewardCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function TowerWeeklyRewardCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function TowerWeeklyRewardCtrl:onShow()
	return
end

function TowerWeeklyRewardCtrl:onHide()
	return
end

return TowerWeeklyRewardCtrl
