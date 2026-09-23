-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FishingCaptureContract\\FishingCaptureContractCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientConst = require("Const.ClientConst")
local FishingCaptureConst = require("Common.Const.FishingCaptureConst")
local AudioConst = require("Const.AudioConst")
local HotkeyConst = require("Const.HotkeyConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local FishingCaptureContractCtrl = Class.LightClass("FishingCaptureContractCtrl", UICtrl)
local CONTRACT_PRESS_DURATION = 1.5
local CONTRACT_SUCCESS_DURATION = 1.1
local BUTTON_STATE_NORMAL = 0
local BUTTON_STATE_PRESSING = 1
local BUTTON_STATE_COMPLETED = 2

function FishingCaptureContractCtrl:addListener()
	self.view.btnContractUButton.luaClick = nil

	function self.view.btnContractUButton.luaPress()
		if pg.game.input:isUsingGamepad() then
			return
		end

		self:startContractPress()
	end

	function self.view.btnContractUButton.luaRelease()
		if pg.game.input:isUsingGamepad() then
			return
		end

		if not self.completed then
			self:stopContractPress(true)
		end
	end

	self:initContractProgressPress()
end

function FishingCaptureContractCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:stopContractSuccessTimer()

	if info and info.closeImmediately ~= nil then
		self.callback = nil

		self:dismiss()

		return
	end

	self.callback = info and info.callback
	self.completed = false
	self.needPlayEndBgm = true
	self.view.progressUProgress.minValue = 0
	self.view.progressUProgress.maxValue = 1

	self:stopContractPress(true)
	self:stopGamepadContractPress(true)
	ClientTextUtils.setText(self.view.txtNameUBaseText, pg.getGameString("FC_CONTRACT_LONG_PRESS"))
	pg.game.audio:playEvent(FishingCaptureConst.SFX_CONTRACT_SHOW)
end

function FishingCaptureContractCtrl:onHide()
	self:stopContractPress(false)
	self:stopGamepadContractPress(false)
	self:stopContractSuccessTimer()
	self:playContractEndBgm()
	UICtrl.onHide(self)
end

function FishingCaptureContractCtrl:playContractEndBgm()
	if not self.needPlayEndBgm then
		return
	end

	self.needPlayEndBgm = false

	pg.game.audio:playBgm(FishingCaptureConst.BGM_CONTRACT_END, AudioConst.BgmPriority.FishingCaptureCubeUI)
end

function FishingCaptureContractCtrl:startContractPress()
	if self.completed or self.pressTimer then
		return
	end

	self:changeButtonState(BUTTON_STATE_PRESSING)
	pg.game.audio:playEvent(FishingCaptureConst.SFX_CONTRACT_STAY)

	self.pressTimer = self:startTimer(function()
		self:updateContractPress()
	end, 0, true)
end

function FishingCaptureContractCtrl:stopContractPress(resetProgress)
	if self.pressTimer then
		self:killTimer(self.pressTimer)

		self.pressTimer = nil
	end

	pg.game.audio:stopEvent(FishingCaptureConst.SFX_CONTRACT_STAY)

	if resetProgress and self.view and self.view.progressUProgress then
		self.view.progressUProgress.value = 0

		self:changeButtonState(BUTTON_STATE_NORMAL)
	end
end

function FishingCaptureContractCtrl:stopContractSuccessTimer()
	if not self.successTimer then
		return
	end

	self:killTimer(self.successTimer)

	self.successTimer = nil
end

function FishingCaptureContractCtrl:changeButtonState(state)
	if not self.view or not self.view.rootUComponent then
		return
	end

	self.view.rootUComponent:TryChangePage("ButtonState", state)
end

function FishingCaptureContractCtrl:updateContractPress()
	local progress = self.view.progressUProgress.value + Time.unscaledDeltaTime / CONTRACT_PRESS_DURATION

	self.view.progressUProgress.value = math.min(progress, 1)

	if progress < 1 then
		return
	end

	self:completeContract()
end

function FishingCaptureContractCtrl:completeContract()
	if self.completed then
		return
	end

	self.completed = true

	self:stopContractPress(false)

	self.view.progressUProgress.value = 1

	self:changeButtonState(BUTTON_STATE_COMPLETED)
	pg.game.audio:stopEvent(FishingCaptureConst.SFX_CONTRACT_STAY)
	pg.game.audio:playEvent(FishingCaptureConst.SFX_CONTRACT_DOWN)

	self.successTimer = self:startTimer(function()
		self.successTimer = nil

		self:finishContract()
	end, CONTRACT_SUCCESS_DURATION)
end

function FishingCaptureContractCtrl:finishContract()
	local callback = self.callback

	self.callback = nil

	if callback then
		callback()
	end

	self:dismiss()
end

function FishingCaptureContractCtrl:initContractProgressPress()
	local contractProgressContainer = self.view.progressPressContainer

	if not NotNil(contractProgressContainer) or not self.view.btnContractHotKetContent then
		return
	end

	self.view.btnContractHotKetContent:SetHotKeyPaths(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonNorth)
	contractProgressContainer.gameObject:SetActiveEx(true)
	contractProgressContainer:LoadDefaultUrlManually(function()
		if not NotNil(self.view and self.view.btnContractUButton) then
			return
		end

		local contractProgress = contractProgressContainer.content

		if not NotNil(contractProgress) then
			self.contractProgress = nil

			return
		end

		self.contractProgress = contractProgress

		self.contractProgress.gameObject:SetActiveEx(true)
		self:setGamepadContractProgress(0)

		local hotKeyBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnContractUButton.gameObject, "contractLongPress")

		hotKeyBind.isVirtual = true
		hotKeyBind.priority = -1
		hotKeyBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonNorth

		function hotKeyBind.luaTrigger(inputInfo)
			if inputInfo.phase == "Canceled" then
				if self.gamepadPressTimer and not self.completed then
					self:stopGamepadContractPress(true)
				end

				return false
			end

			if not pg.game.input:isUsingGamepad() or self.completed then
				return false
			end

			if inputInfo.phase == "Performed" then
				self:startGamepadContractPress()
			end

			return false
		end
	end)
end

function FishingCaptureContractCtrl:setGamepadContractProgress(value)
	if self.view and NotNil(self.view.progressUProgress) then
		self.view.progressUProgress.value = value
	end

	if NotNil(self.contractProgress) then
		self.contractProgress:ProgressToValue(value, nil, 0)
	end
end

function FishingCaptureContractCtrl:startGamepadContractPress()
	if self.completed or self.pressTimer or self.gamepadPressTimer then
		return
	end

	self.gamepadPressTime = 0

	self:setGamepadContractProgress(0)
	self:changeButtonState(BUTTON_STATE_PRESSING)

	self.gamepadPressTimer = self:startTimer(function()
		self:updateGamepadContractPress()
	end, 0, true)

	pg.game.input:playRumbleByName(ClientConst.RumbleLayer.CATCH, "BossCatch_SignContract")
	pg.game.audio:playEvent(FishingCaptureConst.SFX_CONTRACT_STAY)
end

function FishingCaptureContractCtrl:stopGamepadContractPress(resetProgress)
	if self.gamepadPressTimer then
		self:killTimer(self.gamepadPressTimer)

		self.gamepadPressTimer = nil
	end

	pg.game.audio:stopEvent(FishingCaptureConst.SFX_CONTRACT_STAY)

	self.gamepadPressTime = 0

	if resetProgress then
		self:setGamepadContractProgress(0)
		self:changeButtonState(BUTTON_STATE_NORMAL)
	end
end

function FishingCaptureContractCtrl:updateGamepadContractPress()
	self.gamepadPressTime = (self.gamepadPressTime or 0) + Time.unscaledDeltaTime

	local progress = self.gamepadPressTime / CONTRACT_PRESS_DURATION

	self:setGamepadContractProgress(math.min(progress, 1))

	if progress < 1 then
		return
	end

	self:stopGamepadContractPress(false)
	self:completeContract()
end

return FishingCaptureContractCtrl
