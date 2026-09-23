-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Component\\ConfirmUIComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local ConfirmUIComponent = Class.LightClass("ConfirmUIComponent", UIComponent)
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")

function ConfirmUIComponent:findObjects()
	self.container = self.transform:GetComponent("UContainer")
end

function ConfirmUIComponent:registerObjectInner()
	self.objectReference = self.container.content:GetComponent("ObjectReference")
	self.title = self.objectReference:GetRefValue("title")
	self.subTitle = self.objectReference:GetRefValue("subTitle")
	self.cancelBtn = self.objectReference:GetRefValue("cancelBtn")
	self.confirmBtn = self.objectReference:GetRefValue("confirmBtn")
	self.btnNextUButton = self.objectReference:GetRefValue("btnNextUButton")
	self.cancelBtnText = self.cancelBtn:GetComponent("ObjectReference"):GetRefValue("txtNameUText")
	self.confirmBtnText = self.confirmBtn:GetComponent("ObjectReference"):GetRefValue("txtNameUText")
	self.nextTimeUWidget = self.objectReference:GetRefValue("nextTimeUWidget")
	self.nextTimeUButton = self.objectReference:GetRefValue("nextTimeUButton")
	self.nextBtnText = self.btnNextUButton:GetComponent("ObjectReference"):GetRefValue("txtNameUText")
end

function ConfirmUIComponent:initView()
	self:hide()
end

function ConfirmUIComponent:onHide()
	self.ctrl:componentSetIsModel("Confirm", false)
end

function ConfirmUIComponent:onShow()
	self.ctrl:componentSetIsModel("Confirm", true)
end

function ConfirmUIComponent:showConfirm(title, desc, okCb, hideCancel, cancelCb, showNextBtn, nextBtnCb, extraInfo)
	if not self.container:CheckURLLoaded() then
		self.container:LoadDefaultUrlManually(function()
			self:registerObjectInner()
			self:showConfirmInternal(title, desc, okCb, hideCancel, cancelCb, showNextBtn, nextBtnCb, extraInfo)
		end)
	else
		self:showConfirmInternal(title, desc, okCb, hideCancel, cancelCb, showNextBtn, nextBtnCb, extraInfo)
	end
end

function ConfirmUIComponent:showConfirmInternal(title, desc, okCb, hideCancel, cancelCb, showNextBtn, nextBtnCb, extraInfo)
	ClientTextUtils.setText(self.title, pg.getLocalizationText(title or ""))
	ClientTextUtils.setText(self.subTitle, pg.getLocalizationText(desc or ""))

	if extraInfo and extraInfo.okBtnDesc then
		ClientTextUtils.setText(self.confirmBtnText, extraInfo.okBtnDesc)
	else
		ClientTextUtils.setText(self.confirmBtnText, pg.getGameString("COMMON_CONFIRM"))
	end

	if extraInfo and extraInfo.cancelBtnDesc then
		ClientTextUtils.setText(self.cancelBtnText, extraInfo.cancelBtnDesc)
	else
		ClientTextUtils.setText(self.cancelBtnText, pg.getGameString("COMMON_CANCEL"))
	end

	if extraInfo and extraInfo.nextBtnDesc then
		ClientTextUtils.setText(self.nextBtnText, extraInfo.nextBtnDesc)
	else
		ClientTextUtils.setText(self.nextBtnText, pg.getGameString("COMMON_CONFIRM"))
	end

	if extraInfo and extraInfo.hint then
		self.nextTimeUWidget:SetActiveFastest(true)

		if extraInfo.hintCb then
			extraInfo.hintCb(self.nextTimeUButton.isSelected)
		end
	else
		self.nextTimeUWidget:SetActiveFastest(false)
	end

	if hideCancel == nil then
		hideCancel = false
	end

	function self.confirmBtn.luaClick()
		self:hide()

		if okCb then
			okCb()
		end
	end

	if hideCancel then
		self.cancelBtn.gameObject:SetActiveEx(false)
	else
		self.cancelBtn.gameObject:SetActiveEx(true)

		function self.cancelBtn.luaClick()
			self:hide()

			if cancelCb then
				cancelCb()
			end
		end
	end

	self.btnNextUButton:SetActive(showNextBtn and true or false)

	if showNextBtn then
		function self.btnNextUButton.luaClick()
			self:hide()

			if nextBtnCb then
				nextBtnCb()
			end
		end
	end

	self:show()
end

return ConfirmUIComponent
