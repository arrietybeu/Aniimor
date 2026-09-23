-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandFacilitySelectPet\\HomelandFacilitySelectPetView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandFacilitySelectPetView = Class.LightClass("HomelandFacilitySelectPetView", UIView)

function HomelandFacilitySelectPetView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.petListTransform = self.objectReference:GetRefValue("petListTransform")
	self.petInfoPanelTransform = self.objectReference:GetRefValue("petInfoPanelTransform")
	self.okBtn = self.objectReference:GetRefValue("okBtn")
	self.btnBack = self.objectReference:GetRefValue("btnBack")
	self.okBtnText = self.objectReference:GetRefValue("okBtnText")
	self.allocateList = self.objectReference:GetRefValue("allocateList")
	self.titleText = self.objectReference:GetRefValue("titleText")
	self.hintText = self.objectReference:GetRefValue("hintText")
end

return HomelandFacilitySelectPetView
