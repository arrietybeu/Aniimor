-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ChangeName\\ChangeNameView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ChangeNameView = Class.LightClass("ChangeNameView", UIView)

function ChangeNameView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.txtTitleUSDFText = self.objectReference:GetRefValue("txtTitleUSDFText")
	self.inputFieldUTMPInputField = self.objectReference:GetRefValue("inputFieldUTMPInputField")
	self.consumeListUList = self.objectReference:GetRefValue("consumeListUList")
	self.btnCancelUButton = self.objectReference:GetRefValue("btnCancelUButton")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
	self.tipsUSDFText = self.objectReference:GetRefValue("tipsUSDFText")
	self.txtLimitUSDFText = self.objectReference:GetRefValue("txtLimitUSDFText")
	self.textConsumeUSDFText = self.objectReference:GetRefValue("textConsumeUSDFText")
end

return ChangeNameView
