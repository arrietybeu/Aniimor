-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ShopGiftReceive\\ShopGiftReceiveView.lua

local logger = require("Core.Log.LoggerManager").getLogger("ShopGiftReceiveView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ShopGiftReceiveView = Class.LightClass("ShopGiftReceiveView", UIView)
local ClientTextUtils = require("Utils.ClientTextUtils")

function ShopGiftReceiveView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.giftCardObjectReference = objectReference:GetRefValue("giftCardObjectReference")
	self.giftCardUComponent = objectReference:GetRefValue("giftCardUComponent")
	self.videoPlayerUVideoPlayerX = objectReference:GetRefValue("videoPlayerUVideoPlayerX")
	objectReference = self.giftCardObjectReference
	self.btnAcceptUButton = objectReference:GetRefValue("btnAcceptUButton")
	self.textMessageUBaseText = objectReference:GetRefValue("textMessageUBaseText")
	self.textPlayerNameUBaseText = objectReference:GetRefValue("textPlayerNameUBaseText")
	self.playerHeadObjectReference = objectReference:GetRefValue("playerHeadObjectReference")
	self.listItemUList = objectReference:GetRefValue("listItemUList")
	self.textPlayerTittleUBaseText = objectReference:GetRefValue("textPlayerTittleUBaseText")
	self.characterUImage = objectReference:GetRefValue("characterUImage")
	self.textGiftNameUBaseText = objectReference:GetRefValue("textGiftNameUBaseText")
	self.textSubTitleUBaseText = objectReference:GetRefValue("textSubTitleUBaseText")
	self.itemIconUImage = objectReference:GetRefValue("itemIconUImage")
	self.itemBgUImage = objectReference:GetRefValue("itemBgUImage")
	self.itemNumUBaseText = objectReference:GetRefValue("itemNumUBaseText")
	self.txtBtnUBaseText = objectReference:GetRefValue("txtBtnUBaseText")
	self.itemUButton = objectReference:GetRefValue("itemUButton")
	self.btnHeadUButton = objectReference:GetRefValue("btnHeadUButton")
end

function ShopGiftReceiveView:registerObjects()
	return
end

function ShopGiftReceiveView:initView()
	ClientTextUtils.setText(self.textPlayerTittleUBaseText, pg.getGameString("SHOP_GIFT_DONOR"))
	ClientTextUtils.setText(self.txtBtnUBaseText, pg.getGameString("SHOP_GIFT_ACCEPT"))
end

return ShopGiftReceiveView
