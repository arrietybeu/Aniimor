-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\VitalityGot\\VitalityGotView.lua

local logger = require("Core.Log.LoggerManager").getLogger("VitalityGotView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local VitalityGotView = Class.LightClass("VitalityGotView", UIView)

function VitalityGotView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.currencyItem = self.objectReference:GetRefValue("currencyItem")
	self.btnClose = self.objectReference:GetRefValue("btnClose")
	self.btnClose2 = self.objectReference:GetRefValue("btnClose2")
	self.btnCancel = self.objectReference:GetRefValue("btnCancel")
	self.btnConfirm = self.objectReference:GetRefValue("btnConfirm")
	self.itemListNew = self.objectReference:GetRefValue("itemList")

	local itemListTransform = self.itemListNew and self.itemListNew.transform.parent:Find("ItemList")

	self.itemList = itemListTransform and itemListTransform:GetComponent("UList")
	self.consumeTip = self.objectReference:GetRefValue("consumeTip")
	self.recoverTime = self.objectReference:GetRefValue("recoverTime")
end

function VitalityGotView:registerObjects()
	return
end

function VitalityGotView:initView()
	return
end

return VitalityGotView
