-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FeedGameEntry\\FeedGameEntryView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local FeedGameEntryView = Class.LightClass("FeedGameEntryView", UIView)

function FeedGameEntryView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.entryUButton = objectReference:GetRefValue("entryUButton")
end

return FeedGameEntryView
