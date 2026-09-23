-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\InventoryItemUse\\InventoryItemUseView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local InventoryItemUseView = Class.LightClass("InventoryItemUseView", UIView)

function InventoryItemUseView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnClose1 = self.objectReference:GetRefValue("btnClose1")
	self.btnClose2 = self.objectReference:GetRefValue("btnClose2")
	self.petList = self.objectReference:GetRefValue("petList")
	self.sliderAdd = self.objectReference:GetRefValue("sliderAdd")
	self.sliderNow = self.objectReference:GetRefValue("sliderNow")
	self.imgPet = self.objectReference:GetRefValue("imgPet")
	self.btnCancal = self.objectReference:GetRefValue("btnCancal")
	self.btnConfirm = self.objectReference:GetRefValue("btnConfirm")
	self.propList = self.objectReference:GetRefValue("propList")
	self.numSelector = self.objectReference:GetRefValue("numSelector")
	self.txtWarning = self.objectReference:GetRefValue("txtWarning")
	self.txtLevelNow = self.objectReference:GetRefValue("txtLevelNow")
	self.txtLevelMax = self.objectReference:GetRefValue("txtLevelMax")
	self.btnRulesUButton = self.objectReference:GetRefValue("btnRulesUButton")
	self.btnPetUButton = self.objectReference:GetRefValue("btnPetUButton")
	self.txtLevelMinus = self.objectReference:GetRefValue("txtLevelMinus")
	self.txtLevelAdd = self.objectReference:GetRefValue("txtLevelAdd")
	self.rootComponent = self.transform:GetComponent("UComponent")
end

function InventoryItemUseView:registerObjects()
	return
end

function InventoryItemUseView:initView()
	return
end

return InventoryItemUseView
