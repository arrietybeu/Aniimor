-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GiftPackReward\\GiftPackRewardView.lua

local logger = require("Core.Log.LoggerManager").getLogger("GiftPackRewardView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local GiftPackRewardView = Class.LightClass("GiftPackRewardView", UIView)

function GiftPackRewardView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.textLimitUBaseText = objectReference:GetRefValue("textLimitUBaseText")
	self.listItemUList = objectReference:GetRefValue("listItemUList")
	self.txtTltleUBaseText = objectReference:GetRefValue("txtTltleUBaseText")
	self.textContentBaseText = objectReference:GetRefValue("textContentBaseText")
	self.costIconUImage = objectReference:GetRefValue("costIconUImage")
	self.costTextUBaseText = objectReference:GetRefValue("costTextUBaseText")
	self.btnBuyUButton = objectReference:GetRefValue("btnBuyUButton")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.giftUImage = objectReference:GetRefValue("giftUImage")
	self.root = objectReference:GetRefValue("root")

	local buyObjectReference = self.btnBuyUButton:GetComponent("ObjectReference")

	self.btnBuyConfirmUButton = buyObjectReference:GetRefValue("uIBtn1stConfirmUButton")
	self.btnBuyTxtNameUText = buyObjectReference:GetRefValue("txtNameUText")
	self.btnBuyKeyHotKeyContent = buyObjectReference:GetRefValue("keyHotKeyContent")
	self.btnCloseBGUButton = objectReference:GetRefValue("btnCloseBGUButton")
	self.timeUCountDown = objectReference:GetRefValue("timeUCountDown")
	self.tagUWidget = objectReference:GetRefValue("tagUWidget")
	self.tagTxt = objectReference:GetRefValue("tagTxt")
end

return GiftPackRewardView
