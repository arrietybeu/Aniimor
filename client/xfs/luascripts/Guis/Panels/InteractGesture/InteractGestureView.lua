-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\InteractGesture\\InteractGestureView.lua

local UIView = require("Guis.UIView")
local Class = require("Core.Framework.Class")
local InteractGestureView = Class.LightClass("InteractGestureView", UIView)

function InteractGestureView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listUList = objectReference:GetRefValue("listUList")
	self.bgCloseUButton = objectReference:GetRefValue("bgCloseUButton")
	self.consoleLayoutBox = objectReference:GetRefValue("layoutBoxTransform")
	self.btnConsoleClose = objectReference:GetRefValue("bUButton")
	self.btnConsoleSwitch = objectReference:GetRefValue("switchUButton")
	self.btnConsoleSelect = objectReference:GetRefValue("selectAUButton")
	self.listTabUList = objectReference:GetRefValue("listTabUList")
end

return InteractGestureView
