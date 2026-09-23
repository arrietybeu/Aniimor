-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Picture\\PictureView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PictureView = Class.LightClass("PictureView", UIView)

function PictureView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.imageUImage = self.objectReference:GetRefValue("imageUImage")
	self.imageUImage2 = self.objectReference:GetRefValue("imageUImage2")
	self.animation = self.transform:Find("Adaption"):GetComponent("Animation")
end

return PictureView
