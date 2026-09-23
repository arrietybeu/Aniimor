-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FishingCaptureTicketExchange\\FishingCaptureTicketExchangeView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local FishingCaptureTicketExchangeView = Class.LightClass("FishingCaptureTicketExchangeView", UIView)

function FishingCaptureTicketExchangeView:findObjects()
	UIView.findObjects(self)

	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootUComponent = self.transform:GetComponent("UComponent")

	if not self.objectReference then
		return
	end

	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.backTxt = self.objectReference:GetRefValue("backTxt")
	self.btnGainUButton = self.objectReference:GetRefValue("btnGainUButton")

	local btnGainObjectReference = self.btnGainUButton:GetComponent("ObjectReference")

	self.btnGainTextPlus = btnGainObjectReference:GetRefValue("textTextPlus")
	self.ball1UContainer = self.objectReference:GetRefValue("ball1UContainer")
	self.ball2UContainer = self.objectReference:GetRefValue("ball2UContainer")
	self.textTitleUBaseText = self.objectReference:GetRefValue("textTitleUBaseText")
	self.ballNameTxt = self.objectReference:GetRefValue("ballNameTxt")
	self.ballNumTxt = self.objectReference:GetRefValue("ballNumTxt")
	self.btnCreateUButton = self.objectReference:GetRefValue("btnCreateUButton")
	self.btnReadyUWidget = self.objectReference:GetRefValue("btnReadyUWidget")

	local btnReadyObjectReference = self.btnReadyUWidget:GetComponent("ObjectReference")

	self.btnReadyNameTxt = btnReadyObjectReference:GetRefValue("txtNameUSDFText")
	self.btnCreateNumTxt = self.objectReference:GetRefValue("btnCreateNumTxt")
	self.btnCreateNameTxt = self.objectReference:GetRefValue("btnCreateNameTxt")
	self.btnCreateCostTxt = self.objectReference:GetRefValue("btnCreateCostTxt")
	self.listCurrencyUList = self.objectReference:GetRefValue("listCurrencyUList")
	self.imgBgUImage = self.objectReference:GetRefValue("imgBgUImage")
	self.titleKeyHotKeyContent = self.objectReference:GetRefValue("titleKeyHotKeyContent")
	self.scrollRectUScrollRect = self.objectReference:GetRefValue("scrollRectUScrollRect")
end

return FishingCaptureTicketExchangeView
