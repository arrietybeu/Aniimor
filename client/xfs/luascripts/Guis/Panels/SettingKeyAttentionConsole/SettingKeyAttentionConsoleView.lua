-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SettingKeyAttentionConsole\\SettingKeyAttentionConsoleView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local SettingKeyAttentionConsoleView = Class.LightClass("SettingKeyAttentionConsoleView", UIView)

function SettingKeyAttentionConsoleView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.listUList = self.objectReference:GetRefValue("listUList")
	self.txtTltleUSDFText = self.objectReference:GetRefValue("txtTltleUSDFText")
	self.textUSDFText = self.objectReference:GetRefValue("textUSDFText")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
	self.btnCancelUButton = self.objectReference:GetRefValue("btnCancelUButton")

	local btnCancelOC = self.btnCancelUButton:GetComponent("ObjectReference")

	self.btnCancelTxtNameUText = btnCancelOC:GetRefValue("txtNameUText")

	local btnConfirmOC = self.btnConfirmUButton:GetComponent("ObjectReference")

	self.btnConfirmTxtNameUText = btnConfirmOC:GetRefValue("txtNameUText")
end

function SettingKeyAttentionConsoleView:registerObjects()
	return
end

function SettingKeyAttentionConsoleView:initView()
	return
end

return SettingKeyAttentionConsoleView
