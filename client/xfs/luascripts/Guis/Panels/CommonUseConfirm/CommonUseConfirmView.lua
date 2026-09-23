-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonUseConfirm\\CommonUseConfirmView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CommonUseConfirmView = Class.LightClass("CommonUseConfirmView", UIView)

function CommonUseConfirmView:findObjects()
	self.component = self.transform:GetComponent("UComponent")
end

function CommonUseConfirmView:registerObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.iTitle = self.objectReference:GetRefValue("iTitle")
	self.iPropList = self.objectReference:GetRefValue("iPropList")
	self.btnCancel = self.objectReference:GetRefValue("btnCancel")
	self.btnConfirm = self.objectReference:GetRefValue("btnConfirm")
	self.iTipTop = self.objectReference:GetRefValue("iTipTop")
	self.iTipBot = self.objectReference:GetRefValue("iTipBot")
	self.root = self.objectReference:GetRefValue("root")
	self.countUBaseText = self.objectReference:GetRefValue("countUBaseText")
	self.listCurrencyUList = self.objectReference:GetRefValue("listCurrencyUList")
	self.nextTimeUWidget = self.objectReference:GetRefValue("nextTimeUWidget")
	self.btnCheckUButton = self.objectReference:GetRefValue("btnCheckUButton")
	self.hintTextUSDFText = self.objectReference:GetRefValue("hintTextUSDFText")
	self.consoleBarUWidget = self.objectReference:GetRefValue("consoleBarUWidget")
	self.btnTipsUSDFText = self.objectReference:GetRefValue("btnTipsUSDFText")
	self.layoutBoxUWidget = self.objectReference:GetRefValue("layoutBoxUWidget")
end

function CommonUseConfirmView:initView()
	return
end

return CommonUseConfirmView
