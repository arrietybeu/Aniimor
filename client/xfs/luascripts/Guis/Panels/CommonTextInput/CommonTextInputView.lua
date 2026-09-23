-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonTextInput\\CommonTextInputView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CommonTextInputView = Class.LightClass("CommonTextInputView", UIView)

function CommonTextInputView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.txtTitleUSDFText = self.objectReference:GetRefValue("txtTitleUSDFText")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.inputFieldUTMPInputField = self.objectReference:GetRefValue("inputFieldUTMPInputField")
	self.btnCancelUButton = self.objectReference:GetRefValue("btnCancelUButton")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
	self.textNumUSDFText = self.objectReference:GetRefValue("textNumUSDFText")
end

return CommonTextInputView
