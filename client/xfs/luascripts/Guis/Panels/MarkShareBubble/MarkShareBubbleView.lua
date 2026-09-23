-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MarkShareBubble\\MarkShareBubbleView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local MarkShareBubbleView = Class.LightClass("MarkShareBubbleView", UIView)

function MarkShareBubbleView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.bubbleTransform = self.objectReference:GetRefValue("bubbleTransform")
end

function MarkShareBubbleView:initView()
	return
end

return MarkShareBubbleView
