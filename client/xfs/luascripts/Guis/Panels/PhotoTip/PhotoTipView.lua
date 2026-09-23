-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotoTip\\PhotoTipView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PhotoTipView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PhotoTipView = Class.LightClass("PhotoTipView", UIView)

function PhotoTipView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.pbReplaceTipUButton = self.objectReference:GetRefValue("pbReplaceTipUButton")
	self.photoUImage = self.objectReference:GetRefValue("photoUImage")
	self.replaceHotKeyContent = self.objectReference:GetRefValue("replaceHotKeyContent")
end

function PhotoTipView:registerObjects()
	return
end

function PhotoTipView:initView()
	self.photoUImage.url = nil
end

return PhotoTipView
