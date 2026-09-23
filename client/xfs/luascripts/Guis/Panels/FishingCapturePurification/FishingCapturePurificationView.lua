-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FishingCapturePurification\\FishingCapturePurificationView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local FishingCapturePurificationView = Class.LightClass("FishingCapturePurificationView", UIView)

function FishingCapturePurificationView:findObjects()
	UIView.findObjects(self)

	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnComfirmUButton = objectReference:GetRefValue("btnComfirmUButton")
	self.textUBaseText = objectReference:GetRefValue("textUBaseText")

	local btnContractObjRef = self.btnComfirmUButton and self.btnComfirmUButton:GetComponent("ObjectReference")

	if btnContractObjRef then
		self.btnComfirmTxt = btnContractObjRef:GetRefValue("txtNameUText")
	end
end

return FishingCapturePurificationView
