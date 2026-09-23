-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\QteTimeline\\QteTimelineView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local QteTimelineView = Class.LightClass("QteTimelineView", UIView)

function QteTimelineView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.progress = self.objectReference:GetRefValue("progress")
	self.btnAnim = self.objectReference:GetRefValue("btnAnim")
	self.rapidClickAnim = self.objectReference:GetRefValue("rapidClickAnim")
	self.clickBtn = self.objectReference:GetRefValue("clickBtn")
	self.txtHint = self.objectReference:GetRefValue("txtHint")
	self.keyHotKeyContent = self.objectReference:GetRefValue("keyHotKeyContent")
	self.rapidClickObjRef = self.objectReference:GetRefValue("rapidClickObjRef")
	self.widget = self.objectReference:GetRefValue("widget")
end

function QteTimelineView:registerObjects()
	return
end

function QteTimelineView:initView()
	return
end

return QteTimelineView
