-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TargetElementPopup\\TargetElementPopupView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TargetElementPopupView = Class.LightClass("TargetElementPopupView", UIView)

function TargetElementPopupView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.petHeadUButton = self.objectReference:GetRefValue("petHeadUButton")

	local petHeadBtnObjRef = self.petHeadUButton:GetComponent("ObjectReference")

	self.petHeadIcon = petHeadBtnObjRef:GetRefValue("icon")
	self.txtLvUSDFText = self.objectReference:GetRefValue("txtLvUSDFText")
	self.txtNameUSDFText = self.objectReference:GetRefValue("txtNameUSDFText")
	self.listElementUList = self.objectReference:GetRefValue("listElementUList")
	self.listCommendUList = self.objectReference:GetRefValue("listCommendUList")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
end

return TargetElementPopupView
