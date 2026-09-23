-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetManagementTidyUp\\PetManagementTidyUpView.lua

local UIView = require("Guis.UIView")
local Class = require("Core.Framework.Class")
local PetManagementTidyUpView = Class.LightClass("PetManagementTidyUpView", UIView)

function PetManagementTidyUpView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.sortOptionList = self.objectReference:GetRefValue("sortOptionList")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.root = self.objectReference:GetRefValue("root")
	self.btnCurrentUButton = self.objectReference:GetRefValue("btnCurrentUButton")
	self.btnAllUButton = self.objectReference:GetRefValue("btnAllUButton")
end

return PetManagementTidyUpView
