-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonConfirm\\CommonConfirmView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CommonConfirmView = Class.LightClass("CommonConfirmView", UIView)

function CommonConfirmView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.title = self.objectReference:GetRefValue("title")
	self.subTitle = self.objectReference:GetRefValue("subTitle")
	self.cancelBtn = self.objectReference:GetRefValue("cancelBtn")
	self.confirmBtn = self.objectReference:GetRefValue("confirmBtn")
	self.btnNextUButton = self.objectReference:GetRefValue("btnNextUButton")
	self.nextTimeUWidget = self.objectReference:GetRefValue("nextTimeUWidget")
	self.nextTimeUButton = self.objectReference:GetRefValue("nextTimeUButton")
	self.bgBlurUWidget = self.objectReference:GetRefValue("bgBlurUWidget")
	self.nextBtnText = self.btnNextUButton:GetComponent("ObjectReference"):GetRefValue("txtNameUText")
	self.nextBtnLockImage = self.btnNextUButton:GetComponent("ObjectReference"):GetRefValue("lockUImage")
	self.cancelBtnText = self.cancelBtn:GetComponent("ObjectReference"):GetRefValue("txtNameUText")
	self.confirmBtnText = self.confirmBtn:GetComponent("ObjectReference"):GetRefValue("txtNameUText")
	self.nextTimeText = self.objectReference:GetRefValue("nextTimeText")
	self.qrCodeUWidget = self.objectReference:GetRefValue("qrCodeUWidget")
	self.qrCodeRawImage = self.objectReference:GetRefValue("qrCodeRawImage")
	self.qrCodeText = self.objectReference:GetRefValue("qrCodeText")
	self.confirmHotKeyContent = self.confirmBtn.transform:GetComponent("ObjectReference"):GetRefValue("keyHotKeyContent")
	self.cancelHotKeyContent = self.cancelBtn.transform:GetComponent("ObjectReference"):GetRefValue("keyHotKeyContent")
	self.nextHotKeyContent = self.btnNextUButton.transform:GetComponent("ObjectReference"):GetRefValue("keyHotKeyContent")
	self.imgPetUContainer = self.objectReference:GetRefValue("imgPetUContainer")
end

function CommonConfirmView:registerObjects()
	return
end

function CommonConfirmView:initView()
	self.qrCodeTex = nil
end

function CommonConfirmView:delayDestroyUIView()
	UIView.delayDestroyUIView(self)

	if self.qrCodeTex then
		CS.UnityEngine.Object.Destroy(self.qrCodeTex)

		self.qrCodeTex = nil
	end
end

return CommonConfirmView
