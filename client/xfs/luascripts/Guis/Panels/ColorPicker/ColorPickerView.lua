-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ColorPicker\\ColorPickerView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ColorPickerView = Class.LightClass("ColorPickerView", UIView)

function ColorPickerView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.colorPickerTransform = self.objectReference:GetRefValue("colorPickerTransform")
	self.maskRayBoxTrans = self.objectReference:GetRefValue("maskRayBoxTrans")
	self.rGBRectU2DSlider = self.objectReference:GetRefValue("rGBRectU2DSlider")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.tMPUSDFText = self.objectReference:GetRefValue("tMPUSDFText")
end

function ColorPickerView:registerObjects()
	local objRef = self.colorPickerTransform:GetComponent("ObjectReference")

	self.confirmUButton = objRef:GetRefValue("confirmUButton")
	self.colorUColorPicker = objRef:GetRefValue("colorUColorPicker")
	self.backUButton = objRef:GetRefValue("backUButton")
	self.resetUButton = objRef:GetRefValue("resetUButton")
	self.handleUImage = objRef:GetRefValue("handleUImage")
	self.bubbleUComponent = objRef:GetRefValue("bubbleUComponent")
end

function ColorPickerView:initView()
	return
end

return ColorPickerView
