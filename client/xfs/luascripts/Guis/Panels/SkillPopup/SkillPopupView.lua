-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SkillPopup\\SkillPopupView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local SkillPopupView = Class.LightClass("SkillPopupView", UIView)

function SkillPopupView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootCmp = self.objectReference:GetRefValue("rootCmp")
	self.txtName = self.objectReference:GetRefValue("txtName")
	self.txtType = self.objectReference:GetRefValue("txtType")
	self.icon = self.objectReference:GetRefValue("icon")
	self.bg = self.objectReference:GetRefValue("bg")
	self.boxSkillFeatures = self.objectReference:GetRefValue("boxSkillFeatures")
	self.pbElement = self.objectReference:GetRefValue("pbElement")
	self.listTag = self.objectReference:GetRefValue("listTag")
	self.listPower = self.objectReference:GetRefValue("listPower")
	self.txtSkillInfo = self.objectReference:GetRefValue("txtSkillInfo")
	self.boxSkillFeature = self.objectReference:GetRefValue("boxSkillFeature")
	self.power = self.objectReference:GetRefValue("power")
	self.energy = self.objectReference:GetRefValue("energy")
end

return SkillPopupView
