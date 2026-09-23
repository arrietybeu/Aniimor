-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandCollectionCrop\\HomelandCollectionCropView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandCollectionCropView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandCollectionCropView = Class.LightClass("HomelandCollectionCropView", UIView)

function HomelandCollectionCropView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
	self.listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")
	self.card1UButton = objectReference:GetRefValue("card1UButton")
	self.iconUImage1 = objectReference:GetRefValue("icon1UImage")
	self.txtNameUSDFText1 = objectReference:GetRefValue("txtName1USDFText")
	self.txtNumUSDFText1 = objectReference:GetRefValue("txtNum1USDFText")
	self.card2UButton = objectReference:GetRefValue("card2UButton")
	self.iconUImage2 = objectReference:GetRefValue("icon2UImage")
	self.txtNameUSDFText2 = objectReference:GetRefValue("txtName2USDFText")
	self.txtNumUSDFText2 = objectReference:GetRefValue("txtNum2USDFText")
	self.btnDecomposeUButton = objectReference:GetRefValue("btnDecomposeUButton")
	self.txtDecomposeUSDFText = objectReference:GetRefValue("txtDecomposeUSDFText")
	self.btnExchangeUButton = objectReference:GetRefValue("btnExchangeUButton")
	self.txtExchangeUSDFText = objectReference:GetRefValue("txtExchangeUSDFText")
	self.txtTipsUSDFText = objectReference:GetRefValue("txtTipsUSDFText")
	self.txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	self.listUList = objectReference:GetRefValue("listUList")
end

function HomelandCollectionCropView:registerObjects()
	return
end

function HomelandCollectionCropView:initView()
	return
end

return HomelandCollectionCropView
