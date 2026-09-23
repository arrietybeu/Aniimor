-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandPlateInfo\\HomelandPlateInfoView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandPlateInfoView = Class.LightClass("HomelandPlateInfoView", UIView)

function HomelandPlateInfoView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.txtTitleTextPlus = self.objectReference:GetRefValue("txtTitleTextPlus")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.picUImage = self.objectReference:GetRefValue("picUImage")
	self.scrollRectUScrollRect = self.objectReference:GetRefValue("scrollRectUScrollRect")
	self.btnOKUButton = self.objectReference:GetRefValue("btnOKUButton")
	self.listCurrencyUList = self.objectReference:GetRefValue("listCurrencyUList")
	self.listCoinUList = self.objectReference:GetRefValue("listCoinUList")
	self.itemListUList = self.objectReference:GetRefValue("itemListUList")
	self.textUSDFText = self.objectReference:GetRefValue("textUSDFText")
end

function HomelandPlateInfoView:registerObjects()
	return
end

function HomelandPlateInfoView:initView()
	return
end

return HomelandPlateInfoView
