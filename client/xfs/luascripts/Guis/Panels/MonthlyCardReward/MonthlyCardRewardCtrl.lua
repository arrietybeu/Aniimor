-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MonthlyCardReward\\MonthlyCardRewardCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("MonthlyCardRewardCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local MessageName = require("Const.MessageName")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local SysConfigData = require("Data.sys_config_data")
local RedDotConst = require("Const.RedDotConst")
local MonthCardUtils = require("GameApp.MonthCard.MonthCardUtils")
local MonthlyCardRewardCtrl = Class.LightClass("MonthlyCardRewardCtrl", UICtrl)

MonthlyCardRewardCtrl.messages = {
	[MessageName.CASH_SHOP_REWARD_CHANGED] = {
		"refreshUI",
		true
	}
}

function MonthlyCardRewardCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function MonthlyCardRewardCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:InitTitle()
	self:refreshUI()
end

function MonthlyCardRewardCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function MonthlyCardRewardCtrl:addListener()
	if self.view.btnClose then
		function self.view.btnClose.luaClick()
			self:dismiss()
		end
	end

	if self.view.btnCloseUButton then
		function self.view.btnCloseUButton.luaClick()
			self:dismiss()
		end
	end

	if self.view.btnClaim then
		function self.view.btnClaim.luaClick()
			self:onClickClaim()
		end
	end

	function self.view.listReward.luaRenderItem(button, index, data)
		LuaUIUtils.renderRewardItem(button, data)
	end

	if self.view.btnInfoUButton then
		self.view.btnInfoUButton.tooltipId = pg.getGameString("MONTH_CARD_REWARD_STORAGE_TEXT_3")
	end
end

function MonthlyCardRewardCtrl:InitTitle()
	local view = self.view

	if view.txtTitle then
		ClientTextUtils.setText(view.txtTitle, pg.getGameString("MONTH_CARD_REWARD_STORAGE_TITLE"))
	end

	if view.txtBtnClaim then
		ClientTextUtils.setText(view.txtBtnClaim, pg.getGameString("MONTH_CARD_REWARD_STORAGE_BUTTON"))
	end
end

function MonthlyCardRewardCtrl:refreshUI()
	local view = self.view

	if not MonthCardUtils.isActivated() then
		view.rootUComponent:TryChangePage("State", 0)
		ClientTextUtils.setText(view.txtLock, pg.getGameString("MONTH_CARD_REWARD_STORAGE_TEXT_1"))
		ClientTextUtils.setText(view.txtLockContent, pg.getGameString("MONTH_CARD_REWARD_STORAGE_TEXT_2"))

		return
	end

	local storeNum = MonthCardUtils.getStoredRewardDays()

	if storeNum and storeNum > 0 then
		view.rootUComponent:TryChangePage("State", 1)

		local storeRewardList = {}

		for _, data in ipairs(SysConfigData.MONTH_CARD_REWARD_DAILY) do
			table.insert(storeRewardList, {
				id = data[1],
				num = data[2] * storeNum
			})
		end

		view.listReward:SetList(storeRewardList)
		pg.global.setRedDot(RedDotConst.RedDotPath.MONTH_STORE_REWARD_BUTTON, view.btnClaim, true, RedDotConst.RedDotStyle.REWARD)
	else
		view.rootUComponent:TryChangePage("State", 2)
		ClientTextUtils.setText(view.txtEmpty, pg.getGameString("MONTH_CARD_REWARD_STORAGE_TEXT_3"))
	end

	self:refreshConsoleBarState()
end

function MonthlyCardRewardCtrl:refreshConsoleBarState()
	local canShow = (MonthCardUtils.getStoredRewardDays() or 0) > 0

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canStickPress", canShow)
end

function MonthlyCardRewardCtrl:onClickClaim()
	pg.game.monthCard:requestClaimStoredReward()
end

return MonthlyCardRewardCtrl
