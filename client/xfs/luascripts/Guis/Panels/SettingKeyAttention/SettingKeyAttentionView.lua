-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SettingKeyAttention\\SettingKeyAttentionView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local SettingKeyAttentionView = Class.LightClass("SettingKeyAttentionView", UIView)

function SettingKeyAttentionView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.listUList = self.objectReference:GetRefValue("listUList")
	self.txtTltleUSDFText = self.objectReference:GetRefValue("txtTltleUSDFText")
	self.textUSDFText = self.objectReference:GetRefValue("textUSDFText")
	self.btnCancelUButton = self.objectReference:GetRefValue("btnCancelUButton")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")

	local btnCancelOC = self.btnCancelUButton:GetComponent("ObjectReference")

	self.btnCancelTxtNameUText = btnCancelOC:GetRefValue("txtNameUText")

	local btnConfirmOC = self.btnConfirmUButton:GetComponent("ObjectReference")

	self.btnConfirmTxtNameUText = btnConfirmOC:GetRefValue("txtNameUText")
end

function SettingKeyAttentionView:registerObjects()
	return
end

function SettingKeyAttentionView:initView()
	return
end

return SettingKeyAttentionView
