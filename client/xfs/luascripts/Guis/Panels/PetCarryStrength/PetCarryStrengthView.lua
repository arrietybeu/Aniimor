-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetCarryStrength\\PetCarryStrengthView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetCarryStrengthView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetCarryStrengthView = Class.LightClass("PetCarryStrengthView", UIView)

function PetCarryStrengthView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.txtName = self.objectReference:GetRefValue("txtName")
	self.iconCarry = self.objectReference:GetRefValue("iconCarry")
	self.txtLvNow = self.objectReference:GetRefValue("txtLvNow")
	self.txtLvAfter = self.objectReference:GetRefValue("txtLvAfter")
	self.expProgress = self.objectReference:GetRefValue("expProgress")
	self.expProgressAdd = self.objectReference:GetRefValue("expProgressAdd")
	self.txtExpAdd = self.objectReference:GetRefValue("txtExpAdd")
	self.txtExpNow = self.objectReference:GetRefValue("txtExpNow")
	self.listAttribute = self.objectReference:GetRefValue("listAttribute")
	self.selector = self.objectReference:GetRefValue("selector")
	self.btnAdd = self.objectReference:GetRefValue("btnAdd")
	self.listSelectItem = self.objectReference:GetRefValue("listSelectItem")
	self.btnStrength = self.objectReference:GetRefValue("btnStrength")
	self.btnBack = self.objectReference:GetRefValue("btnBack")
	self.selectPanel = self.objectReference:GetRefValue("selectPanel")
	self.btnClose2UButton = self.objectReference:GetRefValue("btnClose2UButton")
	self.txtAdd = self.objectReference:GetRefValue("txtAdd")
	self.rootComponent = self.transform:GetComponent("UComponent")
	self.consoleBarRectTransform = self.objectReference:GetRefValue("consoleBarRectTransform")
end

function PetCarryStrengthView:registerObjects()
	return
end

function PetCarryStrengthView:initView()
	return
end

return PetCarryStrengthView
