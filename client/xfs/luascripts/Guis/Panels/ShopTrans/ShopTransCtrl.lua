-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ShopTrans\\ShopTransCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local ShopTransCtrl = Class.LightClass("ShopTransCtrl", UICtrl)

ShopTransCtrl.messages = {}

function ShopTransCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function ShopTransCtrl:onDestroy()
	if self.waitTimer then
		self:killTimer(self.waitTimer)

		self.waitTimer = nil
	end

	self._waitingCustomTransition = false
	self._transitionOutStarted = false

	UICtrl.onDestroy(self)
end

function ShopTransCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.shopInfo = info
end

function ShopTransCtrl:onShow()
	local shopClassCfg = self.shopInfo and self.shopInfo.shopClassCfg

	if shopClassCfg and shopClassCfg.maskRes then
		self.view.mask.url = shopClassCfg.maskRes
	end

	self._waitingCustomTransition = false
	self._transitionOutStarted = false

	local time = self.view.anim:GetClip("VX_Pb_Shop_ARKTransition_In").length

	UIUtils.PlayAnimation(self.view.anim, "VX_Pb_Shop_ARKTransition_In")

	self.waitTimer = self:startTimer(function()
		self.waitTimer = nil

		self:_onTransitionCovered()
	end, time)
end

function ShopTransCtrl:_onTransitionCovered()
	if self.shopInfo and self.shopInfo.onTransitionCovered then
		self._waitingCustomTransition = true

		self.shopInfo.onTransitionCovered(function()
			self:finishCustomTransition()
		end)

		return
	end

	local shopClassCfg = self.shopInfo.shopClassCfg

	if shopClassCfg.pic then
		pg.global.ui:changeUIScene(UIConst.UI_ID_SHOP_ARK, shopClassCfg.pic)
	end

	pg.global.ui:open(UIConst.UI_ID_SHOP_ARK, self.shopInfo, function()
		self.waitTimer = self:startTimer(function()
			self.waitTimer = nil

			self:_playTransitionOut()
		end, 0.01)
	end, nil, shopClassCfg)
end

function ShopTransCtrl:finishCustomTransition()
	if not self._waitingCustomTransition then
		return
	end

	self._waitingCustomTransition = false

	self:_playTransitionOut()
end

function ShopTransCtrl:_playTransitionOut()
	if self._transitionOutStarted then
		return
	end

	self._transitionOutStarted = true

	UIUtils.PlayAnimation(self.view.anim, "VX_Pb_Shop_ARKTransition_Out", function()
		self:dismiss()
	end)
end

function ShopTransCtrl:checkUIShowVirtualMouseCursor()
	return false
end

return ShopTransCtrl
