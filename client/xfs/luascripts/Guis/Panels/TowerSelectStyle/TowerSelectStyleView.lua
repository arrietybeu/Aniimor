-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerSelectStyle\\TowerSelectStyleView.lua

local logger = require("Core.Log.LoggerManager").getLogger("TowerSelectStyleView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TowerSelectStyleView = Class.LightClass("TowerSelectStyleView", UIView)

function TowerSelectStyleView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.backgroundUImage = self.objectReference:GetRefValue("backgroundUImage")
	self.styleUList = self.objectReference:GetRefValue("styleUList")
	self.btnSelectUButton = self.objectReference:GetRefValue("btnSelectUButton")
	self.itemObjectReference = self.objectReference:GetRefValue("itemObjectReference")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
end

function TowerSelectStyleView:registerObjects()
	self.styleIconUComponent = self.itemObjectReference:GetRefValue("styleIconUComponent")
	self.styleIconUImage = self.itemObjectReference:GetRefValue("styleIconUImage")
	self.styleNameUBaseText = self.itemObjectReference:GetRefValue("styleNameUBaseText")
	self.styleDescriptionUBaseText = self.itemObjectReference:GetRefValue("styleDescriptionUBaseText")
	self.styleItemUList = self.itemObjectReference:GetRefValue("styleItemUList")
	self.styleMainBuffUBaseText = self.itemObjectReference:GetRefValue("styleMainBuffUBaseText")
	self.randomAnimation = self.itemObjectReference:GetRefValue("randomAnimation")
	self.equipmentAnimation = self.itemObjectReference:GetRefValue("equipmentAnimation")
	self.styleIcon1UImage = self.itemObjectReference:GetRefValue("styleIcon1UImage")
	self.tooltipUButton = self.itemObjectReference:GetRefValue("tooltipUButton")
	self.styleMainUBaseText = self.itemObjectReference:GetRefValue("styleMainUBaseText")
end

function TowerSelectStyleView:initView()
	return
end

return TowerSelectStyleView
