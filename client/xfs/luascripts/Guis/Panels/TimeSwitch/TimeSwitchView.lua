-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TimeSwitch\\TimeSwitchView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TimeSwitchView = Class.LightClass("TimeSwitchView", UIView)

function TimeSwitchView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.uIPbTimeSwitchUComponent = objectReference:GetRefValue("uIPbTimeSwitchUComponent")
	self.panelAnimation = objectReference:GetRefValue("panelAnimation")
	self.txtCurTimeDesc = objectReference:GetRefValue("txtCurTimeDesc")
	self.btnDusk = objectReference:GetRefValue("btnDusk")
	self.btnMatinal = objectReference:GetRefValue("btnMatinal")
	self.btnNight = objectReference:GetRefValue("btnNight")
	self.btnNoon = objectReference:GetRefValue("btnNoon")
	self.animTimeChange = objectReference:GetRefValue("animTimeChange")
	self.txtClose = objectReference:GetRefValue("txtClose")
end

function TimeSwitchView:registerObjects()
	return
end

function TimeSwitchView:initView()
	return
end

return TimeSwitchView
