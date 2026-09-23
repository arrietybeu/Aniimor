-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Input\\Processor\\HudInputProcessor.lua

local Class = require("Core.Framework.Class")
local BaseInputProcessor = require("GameApp.Input.Processor.BaseInputProcessor")
local AbilityConst = require("Common.Const.AbilityConst")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local ConflictTypes = require("Common.ConflictTypes")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local UIConst = require("Const.UIConst")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local HotkeyConst = require("Const.HotkeyConst")
local pg = pg
local ToBool = ToBool
local HudInputProcessor = Class.LightClass("HudInputProcessor", BaseInputProcessor)
local LONG_PRESS_DELAY = 0.2
local CANCEL_GAMEPAD_MENU_PRESS_TIMEOUT = LONG_PRESS_DELAY + 0.1
local GAMEPAD_MENU_RELEASE_CLOSE_REASON = "GamepadMenuRelease"

function HudInputProcessor:ctor(path)
	HudInputProcessor.super.ctor(self, path)

	self.gamepadMenuTimer = nil
	self.gamepadMenuPressTime = 0
	self.cancelNextGamepadMenuPress = false
	self.cancelGamepadMenuPressUntilRelease = false
	self.cancelGamepadMenuPressTimer = nil
end

function HudInputProcessor:clearCancelGamepadMenuPressState()
	if self.cancelGamepadMenuPressTimer then
		TimerManager.removeTimer(self.cancelGamepadMenuPressTimer)

		self.cancelGamepadMenuPressTimer = nil
	end

	self.cancelNextGamepadMenuPress = false
	self.cancelGamepadMenuPressUntilRelease = false
end

function HudInputProcessor:cancelNextGamepadMenuAction()
	if self.cancelGamepadMenuPressTimer then
		TimerManager.removeTimer(self.cancelGamepadMenuPressTimer)

		self.cancelGamepadMenuPressTimer = nil
	end

	self.cancelNextGamepadMenuPress = true
	self.cancelGamepadMenuPressUntilRelease = true

	self:stopGamepadMenuLongPress()
	TimerManager.addNextFrameCb(function()
		self.cancelNextGamepadMenuPress = false
	end)

	self.cancelGamepadMenuPressTimer = TimerManager.addTimer(CANCEL_GAMEPAD_MENU_PRESS_TIMEOUT, function()
		self:clearCancelGamepadMenuPressState()
	end)
end

local function notifyGamepadMenuLongPressProgress(value)
	local hudV2 = pg.global.ui.hudV2

	if hudV2 and hudV2.setGamepadMenuLongPressProgress then
		hudV2:setGamepadMenuLongPressProgress(value)
	end

	local photoCtrl = pg.global.ui.photo

	if photoCtrl and photoCtrl.setGamepadMenuLongPressProgress then
		photoCtrl:setGamepadMenuLongPressProgress(value)
	end
end

function HudInputProcessor:stopGamepadMenuLongPress()
	if self.gamepadMenuTimer then
		TimerManager.removeTimer(self.gamepadMenuTimer)

		self.gamepadMenuTimer = nil
	end

	self.gamepadMenuPressTime = 0

	notifyGamepadMenuLongPressProgress(0)
end

local function canOpenGamepadMenu()
	if not pg.game.input:isUsingGamepad() then
		return false
	end

	local hudVisible = pg.global.ui.hudV2:checkUIVisible()
	local photoOpen = pg.global.ui:checkUIOpen(UIConst.UI_ID_PHOTO)

	if not hudVisible and not photoOpen then
		return false
	end

	if not pg.global.ui.hudV2:checkCanOpenGamepadMenu() then
		return false
	end

	if photoOpen then
		local photoCtrl = pg.global.ui.photo
		local settingWidget = photoCtrl and photoCtrl.view and photoCtrl.view.settingWidgetUWidget

		if not settingWidget or not settingWidget.gameObject.activeSelf then
			return false
		end
	end

	return true
end

function HudInputProcessor:handleGamepadMenuAction(inputInfo)
	if inputInfo.phase == "Checked" then
		if self.cancelGamepadMenuPressUntilRelease then
			return true
		end

		if not canOpenGamepadMenu() then
			return true
		end
	elseif inputInfo.phase == "Performed" then
		if self.cancelNextGamepadMenuPress or self.cancelGamepadMenuPressUntilRelease then
			self.cancelNextGamepadMenuPress = false

			self:stopGamepadMenuLongPress()

			return true
		end

		if not canOpenGamepadMenu() then
			pg.global.ui.gamepadMenuNew:setMenuOpen(false)

			return true
		end

		self:stopGamepadMenuLongPress()

		if pg.game.input.gamepadInputMode == HotkeyConst.GAMEPAD_INPUT_CONTROL_MODE.CombineMode then
			self.gamepadMenuTimer = TimerManager.addRepeatTimer(0, function()
				if not canOpenGamepadMenu() then
					self:stopGamepadMenuLongPress()
					pg.global.ui.gamepadMenuNew:setMenuOpen(false)

					return
				end

				self.gamepadMenuPressTime = self.gamepadMenuPressTime + Time.unscaledDeltaTime

				local progress = self.gamepadMenuPressTime / LONG_PRESS_DELAY

				if progress > 1 then
					progress = 1
				end

				notifyGamepadMenuLongPressProgress(progress)

				if self.gamepadMenuPressTime >= LONG_PRESS_DELAY then
					self:stopGamepadMenuLongPress()
					pg.global.ui.gamepadMenuNew:setMenuOpen(true)
				end
			end)
		else
			pg.global.ui.gamepadMenuNew:setMenuOpen(true)
		end
	elseif inputInfo.phase == "Canceled" then
		if self.cancelGamepadMenuPressUntilRelease then
			self:clearCancelGamepadMenuPressState()
			self:stopGamepadMenuLongPress()

			return true
		end

		if pg.game.input.gamepadInputMode == HotkeyConst.GAMEPAD_INPUT_CONTROL_MODE.CombineMode and self.gamepadMenuTimer ~= nil then
			self:stopGamepadMenuLongPress()
			pg.game.input:triggerWaitAction(inputInfo.inputControl, {
				"Hud/GamepadMenu"
			})
		elseif pg.global.ui.gamepadMenuNew.isOpen then
			pg.global.ui.gamepadMenuNew:setMenuOpen(false, GAMEPAD_MENU_RELEASE_CLOSE_REASON)
		end
	end
end

function HudInputProcessor:handleGamepadMenuLeftStickAction(inputInfo)
	local gamepadMenuNew = pg.global.ui.gamepadMenuNew

	if gamepadMenuNew and gamepadMenuNew.handlePostReleaseStick and gamepadMenuNew:handlePostReleaseStick(inputInfo) then
		return false
	end

	return true
end

function HudInputProcessor:handleGamepadConfigMenuAction(inputInfo)
	return true
end

function HudInputProcessor:handleExitGhostEyeAction(inputInfo)
	if inputInfo.phase == "Performed" and pg.me and pg.me:isInGhostEyeState() then
		pg.me:exitGhostEyeState()
	end

	return true
end

function HudInputProcessor:handleOpenVlogAction(inputInfo)
	if inputInfo.phase == "Performed" then
		self:handleOpenVlogActionPerformed(inputInfo)
	elseif inputInfo.phase == "Canceled" then
		self:handleOpenVlogActionCanceled(inputInfo)
	end

	return true
end

function HudInputProcessor:handleOpenVlogActionPerformed(inputInfo)
	if pg.global.ui:runPlatformByPC() then
		if self.vlogLongPressTimer then
			TimerManager.removeTimer(self.vlogLongPressTimer)

			self.vlogLongPressTimer = nil
		end

		self.vlogLongPressTimer = TimerManager.addTimer(LONG_PRESS_DELAY, function()
			self.vlogLongPressTimer = nil
		end)
	end
end

function HudInputProcessor:handleOpenVlogActionCanceled(inputInfo)
	if pg.global.ui:runPlatformByPC() and self.vlogLongPressTimer then
		TimerManager.removeTimer(self.vlogLongPressTimer)

		self.vlogLongPressTimer = nil
	end
end

return HudInputProcessor
