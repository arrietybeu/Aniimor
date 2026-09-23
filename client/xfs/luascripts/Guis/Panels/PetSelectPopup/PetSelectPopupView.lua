-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetSelectPopup\\PetSelectPopupView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetSelectPopupView = Class.LightClass("PetSelectPopupView", UIView)

function PetSelectPopupView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.selectorUSelector = objectReference:GetRefValue("selectorUSelector")
	self.selectorNameUSDFText = objectReference:GetRefValue("selectorNameUSDFText")
	self.bgCloseUButton = objectReference:GetRefValue("bgCloseUButton")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.btnLeftUButton = objectReference:GetRefValue("btnLeftUButton")
	self.btnRightUButton = objectReference:GetRefValue("btnRightUButton")
	self.buttonSearchUButton = objectReference:GetRefValue("buttonSearchUButton")
	self.petListUWidget = objectReference:GetRefValue("petListUWidget")
	self.inputFieldUTMPInputField = objectReference:GetRefValue("inputFieldUTMPInputField")
	self.petDetailsUContainer = objectReference:GetRefValue("petDetailsUContainer")
	self.btnAllSelectedUButton = objectReference:GetRefValue("btnAllSelectedUButton")
	self.titleUSDFText = objectReference:GetRefValue("titleUSDFText")
end

return PetSelectPopupView
