-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GamepadMenuNew\\GamepadMenuNewView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local GamepadMenuNewView = Class.LightClass("GamepadMenuNewView", UIView)

function GamepadMenuNewView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.wheelLoopList = self.objectReference:GetRefValue("wheelULoopList")
	self.zoomInButton = self.objectReference:GetRefValue("zoomInUButton")
	self.zoomOutButton = self.objectReference:GetRefValue("zoomOutUButton")
	self.switchLeftWheelButton = self.objectReference:GetRefValue("leftWheelUButton")
	self.switchRightWheelButton = self.objectReference:GetRefValue("rightWheelUButton")
	self.releaseButton = self.objectReference:GetRefValue("releaseUButton")
	self.functionWheelTitle = self.objectReference:GetRefValue("title")
end

function GamepadMenuNewView:registerObjects()
	return
end

function GamepadMenuNewView:initView()
	return
end

return GamepadMenuNewView
