-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FishingCaptureHistory\\FishingCaptureHistoryView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local FishingCaptureHistoryView = Class.LightClass("FishingCaptureHistoryView", UIView)

function FishingCaptureHistoryView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.txtTitleUBaseText = objectReference:GetRefValue("txtTitleUBaseText")
	self.btnCornerCloseUButton = objectReference:GetRefValue("btnCornerCloseUButton")
	self.textUBaseText = objectReference:GetRefValue("textUBaseText")
	self.txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
	self.txtCostUBaseText = objectReference:GetRefValue("txtCostUBaseText")
	self.txtTimeUBaseText = objectReference:GetRefValue("txtTimeUBaseText")
	self.listUList = objectReference:GetRefValue("listUList")
	self.btnNextUButton = objectReference:GetRefValue("btnPreUButton")
	self.btnPreUButton = objectReference:GetRefValue("btnNextUButton")
	self.inputFieldUTMPInputField = objectReference:GetRefValue("inputFieldUTMPInputField")
	self.widget = self.transform:GetComponent("UWidget")
end

function FishingCaptureHistoryView:registerObjects()
	return
end

function FishingCaptureHistoryView:initView()
	return
end

return FishingCaptureHistoryView
