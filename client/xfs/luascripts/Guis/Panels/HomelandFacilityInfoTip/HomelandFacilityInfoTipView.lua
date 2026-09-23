-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandFacilityInfoTip\\HomelandFacilityInfoTipView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandFacilityInfoTipView = Class.LightClass("HomelandFacilityInfoTipView", UIView)

function HomelandFacilityInfoTipView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.workloadText = self.objectReference:GetRefValue("workloadText")
	self.petInfo = self.objectReference:GetRefValue("petInfo")
	self.petList = self.objectReference:GetRefValue("petList")
	self.electric = self.objectReference:GetRefValue("electric")
	self.environment = self.objectReference:GetRefValue("environment")
	self.baseInfo = self.objectReference:GetRefValue("baseInfo")
	self.petDetail = self.objectReference:GetRefValue("petDetail")
	self.electricText = self.objectReference:GetRefValue("electricText")
	self.electricWorkRatio = self.objectReference:GetRefValue("electricWorkRatio")
	self.electricBuff = self.objectReference:GetRefValue("electricBuff")
	self.envList = self.objectReference:GetRefValue("envList")
	self.electricInfo = self.objectReference:GetRefValue("electricInfo")
	self.rootCmp = self.transform:GetComponent("UPopupForm")
end

return HomelandFacilityInfoTipView
