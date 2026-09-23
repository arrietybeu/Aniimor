-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonInput\\CommonInputCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local CommonInputCtrl = Class.LightClass("CommonInputCtrl", UICtrl)

CommonInputCtrl.messages = {}

function CommonInputCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.showInfo = info or {}
end

function CommonInputCtrl:addListener()
	if self.view.inputField then
		function self.view.inputField.luaValueChanged(text)
			self:onInputChanged(text)
		end
	end

	if self.view.btnDeleteUButton then
		function self.view.btnDeleteUButton.luaClick()
			self.view.inputField.text = ""

			self:onInputChanged("")
		end
	end

	if self.view.btnConfirm then
		function self.view.btnConfirm.luaClick()
			self:onConfirm()
		end
	end

	if self.view.btnCancel then
		function self.view.btnCancel.luaClick()
			self:onCancel()
		end
	end

	if self.view.btnCloseUButton then
		function self.view.btnCloseUButton.luaClick()
			self:onCancel()
		end
	end
end

function CommonInputCtrl:onShow()
	local info = self.showInfo

	ClientTextUtils.setText(self.view.txtTitle, pg.getGameString(info.title or "COMMON_TIP"))

	if self.view.txtDetail then
		ClientTextUtils.setText(self.view.txtDetail, info.detail and pg.getGameString(info.detail) or "")
	end

	if self.view.placeHolderUText then
		ClientTextUtils.setText(self.view.placeHolderUText, info.placeHolder or "")
	end

	if self.view.btnConfirmTxtName then
		ClientTextUtils.setText(self.view.btnConfirmTxtName, pg.getGameString(info.confirmBtnText or "CONFIRM"))
	end

	if self.view.errorTextUText then
		self.view.errorTextUText:SetActive(false)
	end

	if self.view.inputField then
		self.view.inputField.text = ""
	end

	self:onInputChanged("")
end

function CommonInputCtrl:onInputChanged(text)
	if self.view.errorTextUText then
		ClientTextUtils.setText(self.view.errorTextUText, "")
		self.view.errorTextUText:SetActive(false)
	end

	if self.view.btnDeleteUButton then
		self.view.btnDeleteUButton:SetActiveFastest(not string.isNilOrEmpty(text))
	end

	if self.view.btnConfirm then
		self.view.btnConfirm.interactable = self:_isInputValid(text)
	end
end

function CommonInputCtrl:_isInputValid(text)
	local needText = self.showInfo.requireText

	if string.isNilOrEmpty(needText) then
		return true
	end

	return text == needText
end

function CommonInputCtrl:onConfirm()
	local text = self.view.inputField and self.view.inputField.text or ""

	if not self:_isInputValid(text) then
		return
	end

	self:close()

	if self.showInfo.confirmCb then
		self.showInfo.confirmCb()
	end
end

function CommonInputCtrl:onCancel()
	self:close()

	if self.showInfo.cancelCb then
		self.showInfo.cancelCb()
	end
end

function CommonInputCtrl:checkUIShowVirtualMouseCursor()
	return false
end

return CommonInputCtrl
