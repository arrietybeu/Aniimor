-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SpecialEnergyBar\\SpecialEnergyBarView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local SpecialEnergyBarView = Class.LightClass("SpecialEnergyBarView", UIView)

function SpecialEnergyBarView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootUIFollowTrans = objectReference:GetRefValue("rootUIFollowTrans")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.energyUSlider = objectReference:GetRefValue("energyUSlider")
	self.imgNmlUImage = objectReference:GetRefValue("imgNmlUImage")
	self.imgFullUImage = objectReference:GetRefValue("imgFullUImage")
	self.rootAnimation = objectReference:GetRefValue("rootAnimation")
	self.cutLineRectTransform = objectReference:GetRefValue("cutLineRectTransform")
end

function SpecialEnergyBarView:registerObjects()
	return
end

function SpecialEnergyBarView:initView()
	return
end

return SpecialEnergyBarView
