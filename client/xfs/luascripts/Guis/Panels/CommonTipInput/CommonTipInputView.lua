-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonTipInput\\CommonTipInputView.lua

local logger = require("Core.Log.LoggerManager").getLogger("CommonTipInputView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CommonTipInputView = Class.LightClass("CommonTipInputView", UIView)

function CommonTipInputView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.txtName = objectReference:GetRefValue("txtName")
	self.btnConfirm = objectReference:GetRefValue("btnConfirm")
	self.btnConfirmTxtName = objectReference:GetRefValue("btnConfirmTxtName")
	self.btnCancel = objectReference:GetRefValue("btnCancel")
	self.btnCancelTxtName = objectReference:GetRefValue("btnCancelTxtName")
	self.errorTextUText = objectReference:GetRefValue("errorTextUText")
	self.placeHolderUText = objectReference:GetRefValue("placeHolderUText")
	self.inputField = objectReference:GetRefValue("inputField")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.nextTimeUWidget = objectReference:GetRefValue("nextTimeUWidget")
	self.nextTimeUButton = objectReference:GetRefValue("nextTimeUButton")
	self.nextTimeText = objectReference:GetRefValue("nextTimeText")
	self.btnCopyUButton = objectReference:GetRefValue("btnCopyUButton")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")

	local inputOC = self.inputField:GetComponent("ObjectReference")

	self.btnDeleteUButton = inputOC:GetRefValue("btnDeleteUButton")
end

function CommonTipInputView:registerObjects()
	return
end

function CommonTipInputView:initView()
	return
end

return CommonTipInputView
