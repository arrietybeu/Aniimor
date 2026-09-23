-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonConfirm\\CommonConfirmCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UICtrl = require("Guis.UICtrl")
local CommonConfirmCtrl = Class.LightClass("CommonConfirmCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local HotkeyConst = require("Const.HotkeyConst")
local Const = require("Common.Const.Const")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro

CommonConfirmCtrl.ButtonTypeToPath = {
	[Const.ExitButtonType.END_AND_EXIT] = "Raw/GamepadButtonNorth",
	[Const.ExitButtonType.CONTINUE] = "Raw/GamepadButtonEast",
	[Const.ExitButtonType.TEMPORARY_EXIT] = "Raw/GamepadButtonWest",
	[Const.ExitButtonType.READJUST] = "Raw/GamepadSelect"
}
CommonConfirmCtrl.messages = {}

function CommonConfirmCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function CommonConfirmCtrl:addListener()
	return
end

function CommonConfirmCtrl:showConfirm(title, desc, okCb, hideCancel, cancelCb, showNextBtn, nextBtnCb, extraInfo, tickFunc, tickInterval)
	self.onSupersededCb = extraInfo and extraInfo.onSupersededCb or nil
	self.blockNextTip = extraInfo and extraInfo.blockNextTip or false

	if extraInfo and extraInfo.textLocalized then
		self.view.title.text = title or ""
	else
		ClientTextUtils.setText(self.view.title, pg.getLocalizationText(title or ""))
	end

	if extraInfo and extraInfo.textLocalized then
		self.view.subTitle.text = desc or ""
	else
		ClientTextUtils.setText(self.view.subTitle, pg.getLocalizationText(desc or ""))
	end

	if extraInfo and extraInfo.okBtnDesc then
		ClientTextUtils.setText(self.view.confirmBtnText, extraInfo.okBtnDesc)
	else
		ClientTextUtils.setText(self.view.confirmBtnText, pg.getGameString("COMMON_CONFIRM"))
	end

	if extraInfo and extraInfo.cancelBtnDesc then
		ClientTextUtils.setText(self.view.cancelBtnText, extraInfo.cancelBtnDesc)
	else
		ClientTextUtils.setText(self.view.cancelBtnText, pg.getGameString("COMMON_CANCEL"))
	end

	if extraInfo and extraInfo.nextBtnDesc then
		ClientTextUtils.setText(self.view.nextBtnText, extraInfo.nextBtnDesc)
	else
		ClientTextUtils.setText(self.view.nextBtnText, pg.getGameString("COMMON_CONFIRM"))
	end

	if extraInfo and extraInfo.okBtnType then
		self.view.confirmBtn:TryChangePage("Type", extraInfo.okBtnType)
	end

	if extraInfo and extraInfo.cancelType then
		self.view.cancelBtn:TryChangePage("Type", extraInfo.cancelType)
	end

	if extraInfo and extraInfo.nextBtnType then
		self.view.btnNextUButton:TryChangePage("Type", extraInfo.nextBtnType)
	end

	local showBgBlur

	showBgBlur = (not extraInfo or not extraInfo.hideBgBlur or false) and true

	if self.view.bgBlurUWidget and self.view.bgBlurUWidget.SetActive then
		self.view.bgBlurUWidget:SetActive(showBgBlur)
	end

	if extraInfo and extraInfo.hint then
		self.view.nextTimeUWidget:SetActiveFastestAndMarkIgnoreLayout(true)

		function self.view.nextTimeUButton.luaSelectChanged(isSelected)
			if extraInfo.hintCb then
				extraInfo.hintCb(isSelected)
			end
		end

		local nextTimeKeyBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.nextTimeUButton.gameObject, "nextTimeKeyBind")

		nextTimeKeyBind.isVirtual = true
		nextTimeKeyBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest
		nextTimeKeyBind.priority = 30000

		function nextTimeKeyBind.luaTrigger(inputInfo)
			if inputInfo.phase == "Performed" then
				self.view.nextTimeUButton.isSelected = not self.view.nextTimeUButton.isSelected
			end
		end

		if extraInfo.hintDesc then
			ClientTextUtils.setText(self.view.nextTimeText, extraInfo.hintDesc)
		end
	else
		self.view.nextTimeUWidget:SetActiveFastestAndMarkIgnoreLayout(false)
	end

	if pg.space then
		if extraInfo and extraInfo.pauseGame then
			pg.space:pauseGameByType(Const.GameTimeScaleType.COMMON_CONFIRM, -1)
		else
			pg.space:resumeGameByType(Const.GameTimeScaleType.COMMON_CONFIRM)
		end
	end

	if hideCancel == nil then
		hideCancel = false
	end

	function self.view.confirmBtn.luaClick()
		self:close()

		if okCb then
			okCb()
		end
	end

	if hideCancel then
		self.view.cancelBtn.gameObject:SetActiveEx(false)
	else
		self:bindHotKeyPerform("Common/ClosePanelCommon", function()
			self:close()

			if cancelCb and not extraInfo.escSpecial then
				cancelCb()
			end
		end, self.view.cancelBtn.gameObject)
		self.view.cancelBtn.gameObject:SetActiveEx(true)

		function self.view.cancelBtn.luaClick()
			self:close()

			if cancelCb then
				cancelCb()
			end
		end
	end

	self.view.btnNextUButton:SetActive(showNextBtn and true or false)
	self.view.nextBtnLockImage:SetActive(extraInfo and extraInfo.grayNextBtn and true or false)

	if showNextBtn then
		function self.view.btnNextUButton.luaClick()
			self:close()

			if nextBtnCb then
				nextBtnCb()
			end
		end
	end

	if extraInfo and extraInfo.okBtnKey then
		self:bindHotKeyPerform(CommonConfirmCtrl.ButtonTypeToPath[extraInfo.okBtnKey], function()
			self.view.confirmBtn:OnClickSimulate()
		end, self.view.confirmBtn.gameObject)
		self.view.confirmHotKeyContent:SetHotKeyPaths(CommonConfirmCtrl.ButtonTypeToPath[extraInfo.okBtnKey])
	else
		if hideCancel then
			if not extraInfo or not extraInfo.okBtnType then
				self.view.confirmBtn:TryChangePage("Type", 0)
			end

			self:bindHotKeyPerform("Common/Cancel", function()
				self.view.confirmBtn:OnClickSimulate()
			end, self.view.confirmBtn.gameObject)
		end

		self.view.confirmHotKeyContent:SetHotKeyPaths("Common/Confirm")
	end

	if extraInfo and extraInfo.cancelBtnKey then
		self.view.cancelBtn:SetGamepadAction(CommonConfirmCtrl.ButtonTypeToPath[extraInfo.cancelBtnKey], self.view.cancelHotKeyContent.gameObject)
	else
		self.view.cancelBtn:SetGamepadAction(CommonConfirmCtrl.ButtonTypeToPath[Const.ExitButtonType.CONTINUE], self.view.cancelHotKeyContent.gameObject)
	end

	if extraInfo and extraInfo.nextBtnKey then
		self.view.btnNextUButton:SetGamepadAction(CommonConfirmCtrl.ButtonTypeToPath[extraInfo.nextBtnKey], self.view.nextHotKeyContent.gameObject)
	else
		self.view.btnNextUButton:SetGamepadAction(CommonConfirmCtrl.ButtonTypeToPath[Const.ExitButtonType.CONTINUE], self.view.nextHotKeyContent.gameObject)
	end

	self:refreshRCode(extraInfo)

	if tickFunc then
		self.tickTimer = self:startTimer(tickFunc, tickInterval or 0.1, true)
	end

	if extraInfo and extraInfo.needPetIcon then
		self.view.imgPetUContainer:SetActive(true)
		self.view.imgPetUContainer:LoadDefaultUrlManually(function()
			return
		end)
	end
end

function CommonConfirmCtrl:showConfirmByConfig(config)
	config = config or {}

	local title = config.title
	local desc = config.desc
	local okCb = config.okCb
	local hideCancel = config.hideCancel
	local cancelCb = config.cancelCb
	local showNextBtn = config.showNextBtn
	local nextBtnCb = config.nextBtnCb
	local extraInfo = config.extraInfo
	local tickFunc = config.tickFunc
	local tickInterval = config.tickInterval
	local hideAllButtons = extraInfo and extraInfo.hideAllButtons

	self.onSupersededCb = extraInfo and extraInfo.onSupersededCb or nil
	self.blockNextTip = extraInfo and extraInfo.blockNextTip or false
	self.view.confirmBtn.luaClick = nil
	self.view.cancelBtn.luaClick = nil
	self.view.btnNextUButton.luaClick = nil

	self.view.confirmBtn.gameObject:SetActiveEx(not hideAllButtons)
	self.view.confirmHotKeyContent.gameObject:SetActiveEx(not hideAllButtons)
	self.view.cancelHotKeyContent.gameObject:SetActiveEx(not hideAllButtons)
	self.view.nextHotKeyContent.gameObject:SetActiveEx(not hideAllButtons)

	local hasTitle = title ~= nil and title ~= ""

	self.view.title.gameObject:SetActiveEx(hasTitle)
	ClientTextUtils.setText(self.view.title, hasTitle and pg.getLocalizationText(title) or "")
	ClientTextUtils.setText(self.view.subTitle, pg.getLocalizationText(desc or ""))

	if extraInfo and extraInfo.okBtnDesc then
		ClientTextUtils.setText(self.view.confirmBtnText, extraInfo.okBtnDesc)
	else
		ClientTextUtils.setText(self.view.confirmBtnText, pg.getGameString("COMMON_CONFIRM"))
	end

	if extraInfo and extraInfo.cancelBtnDesc then
		ClientTextUtils.setText(self.view.cancelBtnText, extraInfo.cancelBtnDesc)
	else
		ClientTextUtils.setText(self.view.cancelBtnText, pg.getGameString("COMMON_CANCEL"))
	end

	if extraInfo and extraInfo.nextBtnDesc then
		ClientTextUtils.setText(self.view.nextBtnText, extraInfo.nextBtnDesc)
	else
		ClientTextUtils.setText(self.view.nextBtnText, pg.getGameString("COMMON_CONFIRM"))
	end

	if extraInfo and extraInfo.okBtnType then
		self.view.confirmBtn:TryChangePage("Type", extraInfo.okBtnType)
	end

	if extraInfo and extraInfo.cancelType then
		self.view.cancelBtn:TryChangePage("Type", extraInfo.cancelType)
	end

	if extraInfo and extraInfo.nextBtnType then
		self.view.btnNextUButton:TryChangePage("Type", extraInfo.nextBtnType)
	end

	if extraInfo and extraInfo.hideBgBlur then
		self.view.bgBlurUWidget:SetActive(false)
	else
		self.view.bgBlurUWidget:SetActive(true)
	end

	if not hideAllButtons and extraInfo and extraInfo.hint then
		self.view.nextTimeUWidget:SetActiveFastestAndMarkIgnoreLayout(true)

		function self.view.nextTimeUButton.luaSelectChanged(isSelected)
			if extraInfo.hintCb then
				extraInfo.hintCb(isSelected)
			end
		end

		local nextTimeKeyBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.nextTimeUButton.gameObject, "nextTimeKeyBind")

		nextTimeKeyBind.isVirtual = true
		nextTimeKeyBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest
		nextTimeKeyBind.priority = 30000

		function nextTimeKeyBind.luaTrigger(inputInfo)
			if inputInfo.phase == "Performed" then
				self.view.nextTimeUButton.isSelected = not self.view.nextTimeUButton.isSelected
			end
		end

		if extraInfo.hintDesc then
			ClientTextUtils.setText(self.view.nextTimeText, extraInfo.hintDesc)
		end
	else
		self.view.nextTimeUWidget:SetActiveFastestAndMarkIgnoreLayout(false)
	end

	if pg.space then
		if extraInfo and extraInfo.pauseGame then
			pg.space:pauseGameByType(Const.GameTimeScaleType.COMMON_CONFIRM, -1)
		else
			pg.space:resumeGameByType(Const.GameTimeScaleType.COMMON_CONFIRM)
		end
	end

	if hideCancel == nil then
		hideCancel = false
	end

	if hideAllButtons then
		self.view.cancelBtn.gameObject:SetActiveEx(false)
	elseif hideCancel then
		self.view.cancelBtn.gameObject:SetActiveEx(false)
	else
		self:bindHotKeyPerform("Common/ClosePanelCommon", function()
			self:close()

			if cancelCb and (not extraInfo or not extraInfo.escSpecial) then
				cancelCb()
			end
		end, self.view.cancelBtn.gameObject)
		self.view.cancelBtn.gameObject:SetActiveEx(true)

		function self.view.cancelBtn.luaClick()
			self:close()

			if cancelCb then
				cancelCb()
			end
		end
	end

	self.view.btnNextUButton:SetActive(not hideAllButtons and showNextBtn and true or false)
	self.view.nextBtnLockImage:SetActive(not hideAllButtons and extraInfo and extraInfo.grayNextBtn and true or false)

	if not hideAllButtons then
		function self.view.confirmBtn.luaClick()
			self:close()

			if okCb then
				okCb()
			end
		end
	end

	if not hideAllButtons and showNextBtn then
		function self.view.btnNextUButton.luaClick()
			self:close()

			if nextBtnCb then
				nextBtnCb()
			end
		end
	end

	if not hideAllButtons then
		if extraInfo and extraInfo.okBtnKey then
			self:bindHotKeyPerform(CommonConfirmCtrl.ButtonTypeToPath[extraInfo.okBtnKey], function()
				self.view.confirmBtn:OnClickSimulate()
			end, self.view.confirmBtn.gameObject)
			self.view.confirmHotKeyContent:SetHotKeyPaths(CommonConfirmCtrl.ButtonTypeToPath[extraInfo.okBtnKey])
		else
			if hideCancel then
				if not extraInfo or not extraInfo.okBtnType then
					self.view.confirmBtn:TryChangePage("Type", 0)
				end

				self:bindHotKeyPerform("Common/Cancel", function()
					self.view.confirmBtn:OnClickSimulate()
				end, self.view.confirmBtn.gameObject)
			end

			self.view.confirmHotKeyContent:SetHotKeyPaths("Common/Confirm")
		end

		if extraInfo and extraInfo.cancelBtnKey then
			self.view.cancelBtn:SetGamepadAction(CommonConfirmCtrl.ButtonTypeToPath[extraInfo.cancelBtnKey], self.view.cancelHotKeyContent.gameObject)
		else
			self.view.cancelBtn:SetGamepadAction(CommonConfirmCtrl.ButtonTypeToPath[Const.ExitButtonType.CONTINUE], self.view.cancelHotKeyContent.gameObject)
		end

		if extraInfo and extraInfo.nextBtnKey then
			self.view.btnNextUButton:SetGamepadAction(CommonConfirmCtrl.ButtonTypeToPath[extraInfo.nextBtnKey], self.view.nextHotKeyContent.gameObject)
		else
			self.view.btnNextUButton:SetGamepadAction(CommonConfirmCtrl.ButtonTypeToPath[Const.ExitButtonType.CONTINUE], self.view.nextHotKeyContent.gameObject)
		end
	end

	self:refreshRCode(extraInfo)

	if tickFunc then
		self.tickTimer = self:startTimer(tickFunc, tickInterval or 0.1, true)
	end

	if extraInfo and extraInfo.needPetIcon then
		self.view.imgPetUContainer:SetActive(true)
		self.view.imgPetUContainer:LoadDefaultUrlManually(function()
			return
		end)
	end
end

function CommonConfirmCtrl:refreshRCode(extraInfo)
	if self.view.qrCodeTex then
		CS.UnityEngine.Object.Destroy(self.view.qrCodeTex)

		self.view.qrCodeTex = nil
	end

	if extraInfo and extraInfo.qrCodeUrl then
		ClientTextUtils.setText(self.view.qrCodeText, extraInfo.qrCodeTip)

		self.view.qrCodeTex = pg.global.qrCodeMgr:DrawQRCode(self.view.qrCodeRawImage, extraInfo.qrCodeUrl, true, true, 0)

		self.view.qrCodeUWidget:SetActiveFastest(true, true)
	else
		self.view.qrCodeUWidget:SetActiveFastest(false)
	end
end

function CommonConfirmCtrl:resetTickTimer(tickFunc, tickInterval)
	self:killTimer(self.tickTimer)

	self.tickTimer = self:startTimer(tickFunc, tickInterval or 0.1, true)
end

function CommonConfirmCtrl:onDestroy()
	self:clearDescHyperlink()

	self.onSupersededCb = nil
	self.blockNextTip = false

	self:killTimer(self.tickTimer)

	self.tickTimer = nil

	if pg.space then
		pg.space:resumeGameByType(Const.GameTimeScaleType.COMMON_CONFIRM)
	end

	UICtrl.onDestroy(self)
end

function CommonConfirmCtrl:onOpen(info)
	if self.blockNextTip then
		return
	end

	if self.onSupersededCb then
		local cb = self.onSupersededCb

		self.onSupersededCb = nil

		cb()
	end

	UICtrl.onOpen(self, info)

	if info and info.UseConfig then
		self:showConfirmByConfig(info)
	else
		self:showConfirm(info.title, info.desc, info.okCb, info.hideCancel, info.cancelCb, info.showNextBtn, info.nextBtnCb, info.extraInfo, info.tickFunc, info.tickInterval)
	end

	self:refreshDescHyperlink(info and info.extraInfo)
end

function CommonConfirmCtrl:refreshDescHyperlink(extraInfo)
	self:clearDescHyperlink()

	local hyperLinkClick = extraInfo and extraInfo.hyperLinkClick

	self.view.subTitle.enabledHyperlink = hyperLinkClick ~= nil

	if not hyperLinkClick then
		return
	end

	self.descHyperlinkCleanup = extraInfo.hyperLinkCleanup

	function self.view.subTitle.luaOnHyperlinkClick(action, content, contentRect)
		hyperLinkClick(action, content, contentRect, self.view.confirmBtn)
	end

	if extraInfo.hyperLinkEffect ~= nil then
		function self.view.subTitle.luaResolveHyperlinkEffect()
			return extraInfo.hyperLinkEffect
		end
	end
end

function CommonConfirmCtrl:clearDescHyperlink()
	if self.descHyperlinkCleanup then
		self.descHyperlinkCleanup()

		self.descHyperlinkCleanup = nil
	end

	self.view.subTitle.enabledHyperlink = false
	self.view.subTitle.luaOnHyperlinkClick = nil
	self.view.subTitle.luaResolveHyperlinkEffect = nil
end

function CommonConfirmCtrl:onShow()
	return
end

function CommonConfirmCtrl:onHide()
	self:clearDescHyperlink()
end

function CommonConfirmCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function CommonConfirmCtrl:setDesc(text)
	ClientTextUtils.setText(self.view.subTitle, pg.getLocalizationText(text or ""))
end

return CommonConfirmCtrl
