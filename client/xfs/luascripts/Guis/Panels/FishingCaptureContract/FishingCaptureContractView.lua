-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FishingCaptureContract\\FishingCaptureContractView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local FishingCaptureContractView = Class.LightClass("FishingCaptureContractView", UIView)

function FishingCaptureContractView:findObjects()
	UIView.findObjects(self)

	self.rootUComponent = self.transform:GetComponent("UComponent")

	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnContractUButton = objectReference:GetRefValue("btnContractUButton")
	self.progressUProgress = objectReference:GetRefValue("progressUProgress")
	self.txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
	self.progressPressContainer = objectReference:GetRefValue("progressPressContainer")
	self.btnContractHotKetContent = objectReference:GetRefValue("btnContractHotKetContent")

	local btnContractObjRef = self.btnContractUButton and self.btnContractUButton:GetComponent("ObjectReference")

	if btnContractObjRef then
		self.btnContractTxt = btnContractObjRef:GetRefValue("txtNameUText")
	end
end

return FishingCaptureContractView
