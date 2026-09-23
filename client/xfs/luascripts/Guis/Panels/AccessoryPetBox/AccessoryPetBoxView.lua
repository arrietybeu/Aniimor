-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AccessoryPetBox\\AccessoryPetBoxView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local AccessoryPetBoxView = Class.LightClass("AccessoryPetBoxView", UIView)

function AccessoryPetBoxView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnBack = self.objectReference:GetRefValue("btnBack")
	self.currencyList = self.objectReference:GetRefValue("currencyList")
	self.btnWorkshop = self.objectReference:GetRefValue("btnWorkshop")
	self.listAccessories = self.objectReference:GetRefValue("listAccessories")
	self.btnConfirm = self.objectReference:GetRefValue("btnConfirm")
	self.titleUComponent = self.objectReference:GetRefValue("titleUComponent")
	self.petName = self.objectReference:GetRefValue("petName")
	self.element = self.objectReference:GetRefValue("element")
	self.numCP = self.objectReference:GetRefValue("numCP")
	self.btnFavorite = self.objectReference:GetRefValue("btnFavorite")
	self.btnRename = self.objectReference:GetRefValue("btnRename")
	self.numLevel = self.objectReference:GetRefValue("numLevel")
	self.expSlider = self.objectReference:GetRefValue("expSlider")
	self.petList = self.objectReference:GetRefValue("petList")
	self.rootComponent = self.transform:GetComponent("UComponent")
	self.btnElementUButton = self.objectReference:GetRefValue("btnElementUButton")
end

function AccessoryPetBoxView:registerObjects()
	return
end

function AccessoryPetBoxView:initView()
	return
end

return AccessoryPetBoxView
