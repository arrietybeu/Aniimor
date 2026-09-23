-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\WorkShopSavePreset\\WorkShopSavePresetView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local WorkShopSavePresetView = Class.LightClass("WorkShopSavePresetView", UIView)

function WorkShopSavePresetView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.txtTitle = self.objectReference:GetRefValue("txtTitle")
	self.txtPartName = self.objectReference:GetRefValue("txtPartName")
	self.txtPresetNum = self.objectReference:GetRefValue("txtPresetNum")
	self.inputField = self.objectReference:GetRefValue("inputField")
	self.btnCancel = self.objectReference:GetRefValue("btnCancel")
	self.btnConfirm = self.objectReference:GetRefValue("btnConfirm")
	self.rootComponent = self.transform:GetComponent("UComponent")
end

function WorkShopSavePresetView:registerObjects()
	return
end

function WorkShopSavePresetView:initView()
	return
end

return WorkShopSavePresetView
