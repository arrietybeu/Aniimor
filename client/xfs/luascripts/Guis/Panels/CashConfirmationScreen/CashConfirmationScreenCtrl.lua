-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashConfirmationScreen\\CashConfirmationScreenCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("CashConfirmationScreenCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local CashConfirmationScreenCtrl = Class.LightClass("CashConfirmationScreenCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")

CashConfirmationScreenCtrl.messages = {}

function CashConfirmationScreenCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function CashConfirmationScreenCtrl:addListener()
	function self.view.btnConfirm.luaClick()
		logger:info("CashConfirmationScreenCtrl:addListener() - Confirm button clicked")
		pg.game.recharge:ConfirmPurchase(self.purchesInfo.packageId, self.purchesInfo.productId, self.purchesInfo.productDes, self.purchesInfo.categoryType, self.purchesInfo.callback, self.purchesInfo.giftUid, self.purchesInfo.giftDesc)
		self:dismiss()
	end
end

function CashConfirmationScreenCtrl:onDestroy()
	logger:info("CashConfirmationScreenCtrl:onDestroy()")
	UICtrl.onDestroy(self)
end

function CashConfirmationScreenCtrl:onOpen(info)
	logger:info("CashConfirmationScreenCtrl:onOpen info:%s", inspect(info))

	self.purchesInfo = info

	UICtrl.onOpen(self, info)
end

function CashConfirmationScreenCtrl:onShow()
	logger:info("CashConfirmationScreenCtrl:onShow()")
	ClientTextUtils.setText(self.view.textName, self.purchesInfo.productPayInfo.sdkInfo.displayName)
	ClientTextUtils.setText(self.view.scrollRect.content, self.purchesInfo.productPayInfo.sdkInfo.description)
	self.view.scrollRect:SetRightStickScrollConsoleBar("CONSOLE_BAR_SCROLL_VIEW", -3)
end

function CashConfirmationScreenCtrl:onHide()
	return
end

return CashConfirmationScreenCtrl
