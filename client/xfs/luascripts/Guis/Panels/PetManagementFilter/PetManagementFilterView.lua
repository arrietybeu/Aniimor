-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetManagementFilter\\PetManagementFilterView.lua

local UIView = require("Guis.UIView")
local Class = require("Core.Framework.Class")
local PetManagementFilterView = Class.LightClass("PetManagementFilterView", UIView)

function PetManagementFilterView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.sortOptionList = self.objectReference:GetRefValue("sortOptionList")
	self.filterList = self.objectReference:GetRefValue("filterList")
	self.cleanBtn = self.objectReference:GetRefValue("cleanBtn")
	self.confirmBtn = self.objectReference:GetRefValue("confirmBtn")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.btnSortUButton = self.objectReference:GetRefValue("btnSortUButton")
	self.btnFilterUButton = self.objectReference:GetRefValue("btnFilterUButton")
	self.root = self.objectReference:GetRefValue("root")
	self.inputFilterUInputField = self.objectReference:GetRefValue("inputFilterUInputField")
	self.btnDisplayUButton = self.objectReference:GetRefValue("btnDisplayUButton")
end

return PetManagementFilterView
