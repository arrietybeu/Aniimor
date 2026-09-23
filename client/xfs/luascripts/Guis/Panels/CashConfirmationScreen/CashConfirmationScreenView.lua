-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashConfirmationScreen\\CashConfirmationScreenView.lua

local logger = require("Core.Log.LoggerManager").getLogger("CashConfirmationScreenView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CashConfirmationScreenView = Class.LightClass("CashConfirmationScreenView", UIView)

function CashConfirmationScreenView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnConfirm = self.objectReference:GetRefValue("btnConfirm")
	self.scrollRect = self.objectReference:GetRefValue("scrollRect")
	self.textName = self.objectReference:GetRefValue("textName")
	self.textDes = self.objectReference:GetRefValue("textDes")
end

function CashConfirmationScreenView:registerObjects()
	return
end

function CashConfirmationScreenView:initView()
	return
end

return CashConfirmationScreenView
