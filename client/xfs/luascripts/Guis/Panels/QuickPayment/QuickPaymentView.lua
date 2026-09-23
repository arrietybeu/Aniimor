-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\QuickPayment\\QuickPaymentView.lua

local logger = require("Core.Log.LoggerManager").getLogger("QuickPaymentView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local QuickPaymentView = Class.LightClass("QuickPaymentView", UIView)

function QuickPaymentView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnMask = objectReference:GetRefValue("btnMask")
	self.btnClose = objectReference:GetRefValue("btnClose")
	self.btnPay = objectReference:GetRefValue("btnPay")
	self.btnGotoRecharge = objectReference:GetRefValue("btnGotoRecharge")
	self.itemShow = objectReference:GetRefValue("itemShow")
	self.txtTitle = objectReference:GetRefValue("txtTitle")
	self.txtDesc = objectReference:GetRefValue("txtDesc")
	self.txtSlot = objectReference:GetRefValue("txtSlot")
	self.iconMainReward = objectReference:GetRefValue("iconMainReward")
	self.txtFirst = objectReference:GetRefValue("txtFirst")
	self.txtRewardName = objectReference:GetRefValue("txtRewardName")
	self.txtRewardNum = objectReference:GetRefValue("txtRewardNum")
	self.txtExtra = objectReference:GetRefValue("txtExtra")
	self.txtTips = objectReference:GetRefValue("txtTips")
	self.txtPrice = objectReference:GetRefValue("txtPrice")
	self.txtBtnGotoRecharge = objectReference:GetRefValue("txtBtnGotoRecharge")
	self.firstBgUImage = objectReference:GetRefValue("firstBgUImage")
end

function QuickPaymentView:registerObjects()
	return
end

function QuickPaymentView:initView()
	if pg.global.platform:isPS() then
		self.btnClose.gameObject:SetActiveEx(false)
	end
end

return QuickPaymentView
