-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\VipJumpScanCode\\VipJumpScanCodeView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local VipJumpScanCodeView = Class.LightClass("VipJumpScanCodeView", UIView)

function VipJumpScanCodeView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.titleUBaseText = objectReference:GetRefValue("titleUBaseText")
	self.bgUTransform = objectReference:GetRefValue("bgUTransform")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.qrCodeURawImage = objectReference:GetRefValue("qrCodeURawImage")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
end

function VipJumpScanCodeView:registerObjects()
	return
end

function VipJumpScanCodeView:initView()
	return
end

return VipJumpScanCodeView
