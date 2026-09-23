-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FriendGiftBuy\\FriendGiftBuyView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local FriendGiftBuyView = Class.LightClass("FriendGiftBuyView", UIView)

function FriendGiftBuyView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.itemUButton = objectReference:GetRefValue("itemUButton")
	self.itemNameUSDFText = objectReference:GetRefValue("itemNameUSDFText")
	self.text1ConsumeUSDFText = objectReference:GetRefValue("text1ConsumeUSDFText")
	self.textConsumeUSDFText = objectReference:GetRefValue("textConsumeUSDFText")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.numSelectorUNumSelector = objectReference:GetRefValue("numSelectorUNumSelector")
	self.txtTltleUSDFText = objectReference:GetRefValue("txtTltleUSDFText")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.iconUImage = objectReference:GetRefValue("iconUImage")
end

return FriendGiftBuyView
