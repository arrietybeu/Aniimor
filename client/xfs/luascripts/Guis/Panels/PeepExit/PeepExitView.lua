-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PeepExit\\PeepExitView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local SysConfigData = require("Data.sys_config_data")
local PeepExitView = Class.LightClass("PeepExitView", UIView)
local ToBool = ToBool

function PeepExitView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnSpecialUButton = self.objectReference:GetRefValue("btnSpecialUButton")
	self.btnObjectReference = self.btnSpecialUButton.transform:GetComponent("ObjectReference")
	self.txtNameUText = self.btnObjectReference:GetRefValue("txtNameUText")
	self.iconUImage = self.objectReference:GetRefValue("iconUImage")
	self.keyHotKeyContent = self.btnObjectReference:GetRefValue("keyHotKeyContent")
end

function PeepExitView:registerObjects()
	return
end

function PeepExitView:initView()
	return
end

return PeepExitView
