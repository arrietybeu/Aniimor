-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GamepadMenu\\GamepadMenuView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local GamepadMenuView = Class.LightClass("GamepadMenuView", UIView)

function GamepadMenuView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.menu = self.objectReference:GetRefValue("gameWheel")
	self.hotKeyContent = self.objectReference:GetRefValue("hotKey")
	self.funcName = self.objectReference:GetRefValue("funcName")
	self.zoomInHotKey = self.objectReference:GetRefValue("zoomInHotKey")
	self.zoomOutHotKey = self.objectReference:GetRefValue("zoomOutHotKey")
end

function GamepadMenuView:registerObjects()
	return
end

function GamepadMenuView:initView()
	return
end

return GamepadMenuView
