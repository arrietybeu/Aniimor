-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandFacilityInfoDetail\\HomelandFacilityInfoDetailView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandFacilityInfoDetailView = Class.LightClass("HomelandFacilityInfoDetailView", UIView)

function HomelandFacilityInfoDetailView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.workloadText = self.objectReference:GetRefValue("workloadText")
	self.petInfo = self.objectReference:GetRefValue("petInfo")
	self.petList = self.objectReference:GetRefValue("petList")
	self.baseInfo = self.objectReference:GetRefValue("baseInfo")
	self.petDetail = self.objectReference:GetRefValue("petDetail")
	self.envList = self.objectReference:GetRefValue("envList")
	self.rootComponent = self.objectReference:GetRefValue("rootComponent")
	self.titleUWidget = self.objectReference:GetRefValue("titleUWidget")
	self.titleText = self.objectReference:GetRefValue("titleText")
end

return HomelandFacilityInfoDetailView
