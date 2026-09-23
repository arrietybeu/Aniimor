-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FishingCapturePetalSource\\FishingCapturePetalSourceView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local FishingCapturePetalSourceView = Class.LightClass("FishingCapturePetalSourceView", UIView)

function FishingCapturePetalSourceView:findObjects()
	UIView.findObjects(self)

	self.objectReference = self.transform:GetComponent("ObjectReference")

	if not self.objectReference then
		return
	end

	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.itemIconUImage = self.objectReference:GetRefValue("itemIconUImage")
	self.itemNameUBaseText = self.objectReference:GetRefValue("itemNameUBaseText")
	self.itemCountUBaseText = self.objectReference:GetRefValue("itemCountUBaseText")
	self.itemDescUBaseText = self.objectReference:GetRefValue("itemDescUBaseText")
	self.groupTabUList = self.objectReference:GetRefValue("groupTabUList")
	self.channelUList = self.objectReference:GetRefValue("channelUList")
	self.groupTabUWidget = self.objectReference:GetRefValue("groupTabUWidget")
	self.emptyUWidget = self.objectReference:GetRefValue("emptyUWidget")
	self.backTxt = self.objectReference:GetRefValue("backTxt")
end

return FishingCapturePetalSourceView
