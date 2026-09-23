-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SettingOperation\\SettingOperationView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local SettingOperationView = Class.LightClass("SettingOperationView", UIView)

function SettingOperationView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.uIPbSettingOperationUComponent = self.objectReference:GetRefValue("uIPbSettingOperationUComponent")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.root = self.objectReference:GetRefValue("root")
	self.sliderUSlider = self.objectReference:GetRefValue("sliderUSlider")
	self.consoleKeyUList = self.objectReference:GetRefValue("consoleKeyUList")
end

function SettingOperationView:registerObjects()
	return
end

function SettingOperationView:initView()
	return
end

return SettingOperationView
