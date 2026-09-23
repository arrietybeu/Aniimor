-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonTipInput\\CommonTipInputCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("CommonTipInputCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local CommonTipInputCtrl = Class.LightClass("CommonTipInputCtrl", UICtrl)
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")

CommonTipInputCtrl.messages = {}

function CommonTipInputCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function CommonTipInputCtrl:addListener()
	function self.view.inputField.luaValueChanged(text)
		self:refreshInputBtn(string.isNilOrEmpty(text))
		ClientTextUtils.setText(self.view.errorTextUText, "")
	end

	function self.view.btnCopyUButton.luaClick()
		local clipboardText = UIUtils.ClipboardReader()

		if not string.isNilOrEmpty(clipboardText) then
			self.view.inputField.text = clipboardText
		end
	end

	function self.view.btnDeleteUButton.luaClick()
		self.view.inputField.text = ""
	end
end

function CommonTipInputCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function CommonTipInputCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.showInfo = info
end

function CommonTipInputCtrl:onShow()
	self:showInputInternal(self.showInfo.title, self.showInfo.cb, self.showInfo.cancelCb, self.showInfo.extraConfig)

	local loadCb = self.showInfo.loadCb

	if loadCb then
		loadCb()
	end
end

function CommonTipInputCtrl:showInputInternal(title, confirmCb, cancelCb, extraConfig)
	extraConfig = extraConfig or {}

	local characterLimit = extraConfig.characterLimit or 14

	if characterLimit > 0 then
		local patten = pg.getGameString("INPUT_FIELD_CHAR_RESTRICTION")

		ClientTextUtils.setText(self.view.placeHolderUText, pg.getFormatText(patten, tostring(characterLimit)))

		self.view.inputField.characterLimit = characterLimit
	else
		if string.isNilOrEmpty(extraConfig.placeHolderUText) then
			ClientTextUtils.setText(self.view.placeHolderUText, "")
		else
			ClientTextUtils.setText(self.view.placeHolderUText, pg.getGameString(extraConfig.placeHolderUText))
		end

		self.view.inputField.characterLimit = 0
	end

	ClientTextUtils.setText(self.view.inputField, extraConfig.text or "")
	self.view.errorTextUText:SetActive(false)
	self:refreshInputBtn(string.isNilOrEmpty(self.view.inputField.text))

	function self.view.btnConfirm.luaClick()
		local inputText = self.view.inputField.text

		if extraConfig.noSensitiveWordsCheck == true then
			if confirmCb then
				if confirmCb(inputText) then
					return
				end

				self:close()
			else
				self:close()
			end
		else
			pg.me:sensitiveWordsCheck(inputText, function(text)
				if confirmCb then
					if confirmCb(text) then
						return
					end

					self:close()
				else
					self:close()
				end
			end, function(errType)
				ClientTextUtils.setText(self.view.errorTextUText, pg.getGameString("INPUT_TEXT_CONTAINS_SENSITIVE"))
				self.view.errorTextUText:SetActive(true)
			end)
		end
	end

	function self.view.btnCancel.luaClick()
		self:close()

		if cancelCb then
			cancelCb()
		end
	end

	function self.view.btnCloseUButton.luaClick()
		self:close()

		if cancelCb then
			cancelCb()
		end
	end

	ClientTextUtils.setText(self.view.txtName, pg.getGameString(title))

	if not string.isNilOrEmpty(extraConfig.confirmBtnText) then
		ClientTextUtils.setText(self.view.btnConfirmTxtName, pg.getGameString(extraConfig.confirmBtnText))
	end

	if extraConfig and extraConfig.hint then
		self.view.nextTimeUWidget:SetActiveFastest(true)

		function self.view.nextTimeUButton.luaSelectChanged(isSelected)
			if extraConfig.hintCb then
				extraConfig.hintCb(isSelected)
			end
		end

		if extraConfig.hintDesc then
			ClientTextUtils.setText(self.view.nextTimeText, extraConfig.hintDesc)
		end
	else
		self.view.nextTimeUWidget:SetActiveFastest(false)
	end

	if not string.isNilOrEmpty(extraConfig.inputTitle) then
		ClientTextUtils.setText(self.view.textUSDFText, pg.getGameString(extraConfig.inputTitle))
	end

	self.view.textUSDFText:SetActiveFastest(not extraConfig.hideInputTitle)
end

function CommonTipInputCtrl:onHide()
	return
end

function CommonTipInputCtrl:showErrorMsg(errorMsg)
	ClientTextUtils.setText(self.view.errorTextUText, ClientTextUtils.getGameString(errorMsg))
	self.view.errorTextUText:SetActive(true)
end

function CommonTipInputCtrl:refreshInputBtn(isNoText)
	self.view.btnCopyUButton:SetActiveFastest(isNoText)
	self.view.btnDeleteUButton:SetActiveFastest(not isNoText)
end

function CommonTipInputCtrl:checkUIShowVirtualMouseCursor()
	return false
end

return CommonTipInputCtrl
