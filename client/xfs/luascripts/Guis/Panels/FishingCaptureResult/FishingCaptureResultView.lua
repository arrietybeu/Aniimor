-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FishingCaptureResult\\FishingCaptureResultView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local FishingCaptureResultView = Class.LightClass("FishingCaptureResultView", UIView)

function FishingCaptureResultView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackCloseUButton = objectReference:GetRefValue("btnBackCloseUButton")
	self.petUImage = objectReference:GetRefValue("petUImage")
	self.textPetNameUBaseText = objectReference:GetRefValue("textPetNameUBaseText")
	self.listElementUList = objectReference:GetRefValue("listElementUList")
	self.listTagUList = objectReference:GetRefValue("listTagUList")
	self.petTypeIcon = objectReference:GetRefValue("petTypeIcon")
	self.petTypeName = objectReference:GetRefValue("petTypeName")
	self.tipsUBaseText = objectReference:GetRefValue("tipsUBaseText")
	self.btnPetQualityUButton = objectReference:GetRefValue("btnPetQualityUButton")
	self.stageTxt = objectReference:GetRefValue("stageTxt")
end

return FishingCaptureResultView
