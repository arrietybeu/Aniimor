-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MultiChooseChest\\MultiChooseChestView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local MultiChooseChestView = Class.LightClass("MultiChooseChestView", UIView)

function MultiChooseChestView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.root = self.objectReference:GetRefValue("root")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.btnClose1UButton = self.objectReference:GetRefValue("btnClose1UButton")
	self.textUSDFText = self.objectReference:GetRefValue("textUSDFText")
	self.listUList = self.objectReference:GetRefValue("listUList")
	self.numSelector = self.objectReference:GetRefValue("numSelector")
	self.btnCancelUButton = self.objectReference:GetRefValue("btnCancelUButton")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
end

function MultiChooseChestView:initView()
	return
end

return MultiChooseChestView
