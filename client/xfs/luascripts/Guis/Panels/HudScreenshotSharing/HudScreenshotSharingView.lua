-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudScreenshotSharing\\HudScreenshotSharingView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HudScreenshotSharingView = Class.LightClass("HudScreenshotSharingView", UIView)

function HudScreenshotSharingView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.photoUImage = objectReference:GetRefValue("photoUImage")
	self.btnDownloadUButton = objectReference:GetRefValue("btnDownloadUButton")
	self.listBtnUList = objectReference:GetRefValue("listBtnUList")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
end

return HudScreenshotSharingView
