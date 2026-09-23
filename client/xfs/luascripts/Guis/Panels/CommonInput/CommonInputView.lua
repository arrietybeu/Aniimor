-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonInput\\CommonInputView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CommonInputView = Class.LightClass("CommonInputView", UIView)

function CommonInputView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.txtTitle = objectReference:GetRefValue("txtTitle")
	self.txtDetail = objectReference:GetRefValue("txtDetail")
	self.inputField = objectReference:GetRefValue("inputField")
	self.placeHolderUText = objectReference:GetRefValue("placeHolderUText")
	self.errorTextUText = objectReference:GetRefValue("errorTextUText")
	self.btnConfirm = objectReference:GetRefValue("btnConfirm")
	self.btnConfirmTxtName = objectReference:GetRefValue("btnConfirmTxtName")
	self.btnCancel = objectReference:GetRefValue("btnCancel")
	self.btnCancelTxtName = objectReference:GetRefValue("btnCancelTxtName")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")

	local inputOC = self.inputField and self.inputField:GetComponent("ObjectReference")

	self.btnDeleteUButton = inputOC and inputOC:GetRefValue("btnDeleteUButton")
end

function CommonInputView:registerObjects()
	return
end

function CommonInputView:initView()
	return
end

return CommonInputView
