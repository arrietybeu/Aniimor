-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SettingKeyReplace\\SettingKeyReplaceView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local SettingKeyReplaceView = Class.LightClass("SettingKeyReplaceView", UIView)

function SettingKeyReplaceView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.uIPbSettingOperationUComponent = self.objectReference:GetRefValue("uIPbSettingOperationUComponent")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.planUSelector = self.objectReference:GetRefValue("planUSelector")
	self.keyUList = self.objectReference:GetRefValue("keyUList")
	self.btnReSetUButton = self.objectReference:GetRefValue("btnReSetUButton")
	self.consoleKeyUList = self.objectReference:GetRefValue("consoleKeyUList")
	self.root = self.objectReference:GetRefValue("root")
end

function SettingKeyReplaceView:registerObjects()
	return
end

function SettingKeyReplaceView:initView()
	return
end

return SettingKeyReplaceView
