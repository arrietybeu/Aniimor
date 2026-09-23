-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\NourishTribute\\NourishTributeView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local NourishTributeView = Class.LightClass("NourishTributeView", UIView)

function NourishTributeView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.itemSelUButton = self.objectReference:GetRefValue("itemSelUButton")
	self.textTitleUSDFText = self.objectReference:GetRefValue("textTitleUSDFText")
	self.textSubUSDFText = self.objectReference:GetRefValue("textSubUSDFText")
	self.listPetUList = self.objectReference:GetRefValue("listPetUList")
	self.listPropUList = self.objectReference:GetRefValue("listPropUList")
	self.btnOKUButton = self.objectReference:GetRefValue("btnOKUButton")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.textConsumptionUSDFText = self.objectReference:GetRefValue("textConsumptionUSDFText")
	self.titleUSDFText = self.objectReference:GetRefValue("titleUSDFText")
	self.textAttractUSDFText = self.objectReference:GetRefValue("textAttractUSDFText")
	self.textChooseUSDFText = self.objectReference:GetRefValue("textChooseUSDFText")
end

return NourishTributeView
