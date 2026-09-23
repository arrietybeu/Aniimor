-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\EventTaskPanel\\EventTaskPanelView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local EventTaskPanelView = Class.LightClass("EventTaskPanelView", UIView)

function EventTaskPanelView:findObjects()
	UIView.findObjects(self)

	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnCloseAllUButton = self.objectReference:GetRefValue("btnCloseAllUButton")
	self.txtTltleUBaseText = self.objectReference:GetRefValue("txtTltleUBaseText")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.taskListUList = self.objectReference:GetRefValue("taskListUList")
end

return EventTaskPanelView
