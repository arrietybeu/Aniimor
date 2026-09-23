-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DirectPurchase\\DirectPurchaseCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local DirectPurchaseCtrl = Class.LightClass("DirectPurchaseCtrl", UICtrl)

DirectPurchaseCtrl.messages = {}

function DirectPurchaseCtrl:ctor()
	UICtrl.ctor(self)
end

local DIRECT_PURCHASE_BENEFITS = {
	{
		textKey = "Office_pay_gift1",
		icon = "$UI_Img_Popup_DirectPurchase_Icon1.png"
	},
	{
		textKey = "Office_pay_gift2",
		icon = "$UI_Img_Popup_DirectPurchase_Icon2.png"
	},
	{
		textKey = "Office_pay_gift3",
		icon = "$UI_Img_Popup_DirectPurchase_Icon3.png"
	}
}

function DirectPurchaseCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	local isFirstGuide = info and info.firstGuide == true
	local isRebateGuide = info and info.rebateGuide == true

	self.view.widget:TryChangePage("State", isRebateGuide and "Black" or "White")

	if isRebateGuide then
		ClientTextUtils.setText(self.view.titleUSDFText, pg.getFormatText(pg.getGameString("Office_pay_des2"), info.rewardNum or 0))
		ClientTextUtils.setText(self.view.rewardDescUSDFText, pg.getGameString("Office_pay_des3"))
	else
		ClientTextUtils.setText(self.view.titleUSDFText, pg.getGameString("Office_pay_title"))
		ClientTextUtils.setText(self.view.rewardDescUSDFText, pg.getGameString("Office_pay_des1"))
	end

	function self.view.listUList.luaRenderItem(button, _, data)
		button.icon.url = data.icon

		ClientTextUtils.setText(button.title, pg.getGameString(data.textKey))
	end

	self.view.listUList:SetList(DIRECT_PURCHASE_BENEFITS)
	self.view.nextTimeUWidget:SetActiveFastest(isRebateGuide)

	if isRebateGuide then
		self.view.nextTimeUButton.isSelected = false

		ClientTextUtils.setText(self.view.nextTimeUSDFText, pg.getGameString("Office_pay_tips3"))
		ClientTextUtils.setText(self.view.confirmBtn.title, pg.getGameString("Office_pay_button3"))
	end

	self:addListener(isFirstGuide, isRebateGuide, info and info.target)
end

function DirectPurchaseCtrl:addListener(isFirstGuide, isRebateGuide, target)
	function self.view.cancelBtn.luaClick()
		if isRebateGuide and self.view.nextTimeUButton.isSelected then
			pg.game.recharge:suppressDirectPurchaseRebateGuide()
		end

		self:dismiss()

		if isFirstGuide then
			pg.game.recharge:showDirectPurchaseTips(target)
		end
	end

	function self.view.confirmBtn.luaClick()
		if isRebateGuide then
			pg.game.recharge:confirmDirectPurchaseRebateGuide()
		else
			pg.game.recharge:confirmFirstDirectPurchaseGuide()
		end

		local cashShopCtrl = pg.global.ui:tryGetCtrlByUid(UIConst.UI_ID_CASH_SHOP)

		if cashShopCtrl then
			cashShopCtrl:refreshDirectPurchaseState()
		end

		self:dismiss()
	end
end

return DirectPurchaseCtrl
