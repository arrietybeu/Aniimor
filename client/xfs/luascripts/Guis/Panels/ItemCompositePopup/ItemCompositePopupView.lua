-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ItemCompositePopup\\ItemCompositePopupView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ItemCompositePopupView = Class.LightClass("ItemCompositePopupView", UIView)

function ItemCompositePopupView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnClose = self.objectReference:GetRefValue("btnClose")
	self.btnCancel = self.objectReference:GetRefValue("btnCancel")
	self.btnConfirm = self.objectReference:GetRefValue("btnConfirm")
	self.txtName = self.objectReference:GetRefValue("txtName")
	self.compoundList = self.objectReference:GetRefValue("compoundList")
	self.numSelector = self.objectReference:GetRefValue("numSelector")
	self.consumeNum = self.objectReference:GetRefValue("consumeNum")
	self.consumeIcon = self.objectReference:GetRefValue("consumeIcon")
	self.costUWidget = self.objectReference:GetRefValue("costUWidget")
	self.currencyUList = self.objectReference:GetRefValue("currencyUList")
end

function ItemCompositePopupView:registerObjects()
	return
end

function ItemCompositePopupView:initView()
	return
end

return ItemCompositePopupView
