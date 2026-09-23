-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SettingKeyAttentionConsole\\SettingKeyAttentionConsoleCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local MessageName = require("Const.MessageName")
local ClientTextUtils = require("Utils.ClientTextUtils")
local GamepadHotKeyData = require("Data.gamepad_hotkey_data")
local SettingKeyAttentionConsoleCtrl = Class.LightClass("SettingKeyAttentionConsoleCtrl", UICtrl)

SettingKeyAttentionConsoleCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function SettingKeyAttentionConsoleCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.confirmCallback = info.confirmCallback
	self.cancelCallback = info.cancelCallback

	self:initUI(info)
end

function SettingKeyAttentionConsoleCtrl:addListener()
	function self.view.btnCancelUButton.luaClick()
		if self.cancelCallback then
			self.cancelCallback()
		end

		self:dismiss()
	end

	function self.view.btnConfirmUButton.luaClick()
		if self.confirmCallback then
			self.confirmCallback()
		end

		self:dismiss()
	end
end

function SettingKeyAttentionConsoleCtrl:initUI(info)
	if self.view.txtTltleUSDFText then
		ClientTextUtils.setText(self.view.txtTltleUSDFText, pg.getGameString("HOT_KEY_CONFLICT"))
	end

	self:initKeyConflict(info)
	ClientTextUtils.setText(self.view.btnCancelTxtNameUText, pg.getGameString("EXIT_GAME_CANCEL"))
	ClientTextUtils.setText(self.view.btnConfirmTxtNameUText, pg.getGameString("COMMON_CONFIRM"))
end

function SettingKeyAttentionConsoleCtrl:initKeyConflict(info)
	local mgr = pg.game.input.gamepadHotkeyManager
	local groupName = mgr.groupName
	local origin = info.originActionNames or {}
	local candidate = info.candidateValue or {}
	local conflictPath = info.conflictActionPaths and info.conflictActionPaths[0]

	local function pathsForActionNames(actionNames)
		local list = {}

		for _, an in ipairs(actionNames) do
			local p = mgr:GetActionPath(an)

			if p and p ~= "" then
				table.insert(list, p)
			end
		end

		return list
	end

	local originOldPaths = pathsForActionNames(origin)
	local conflictActionNames = conflictPath and self:fullActionNamesFor(conflictPath) or nil
	local rows = {
		{
			actionName = origin[1],
			lPaths = pathsForActionNames(origin),
			rPaths = candidate
		}
	}

	if conflictPath then
		rows[#rows + 1] = {
			actionName = conflictPath,
			lPaths = pathsForActionNames(conflictActionNames),
			rPaths = originOldPaths
		}
	end

	if self.view.textUSDFText then
		local originLabel = self:getActionShowName(origin[1]) or ""
		local conflictLabel = conflictPath and self:getActionShowName(conflictPath) or ""

		ClientTextUtils.setText(self.view.textUSDFText, pg.getFormatText(pg.getGameString("HOT_KEY_CONFLICT_DESC"), originLabel, conflictLabel))
		print(string.format("originLabel=%s, conflictLabel=%s", originLabel, conflictLabel))
	end

	function self.view.listUList.luaRenderItem(button, index, data)
		local objRef = button:GetComponent("ObjectReference")
		local txtL = objRef:GetRefValue("textNameLUSDFText")
		local keyL = objRef:GetRefValue("keyLHotKeyContent")
		local txtR = objRef:GetRefValue("textNameRUSDFText")
		local keyR = objRef:GetRefValue("keyRHotKeyContent")
		local label = self:getActionShowName(data.actionName)

		ClientTextUtils.setText(txtL, label)
		ClientTextUtils.setText(txtR, label)

		keyL.useRawBindingPath = true
		keyL.splitString = "+"

		keyL:SetHotKeyCompositePaths(data.lPaths)

		keyR.useRawBindingPath = true
		keyR.splitString = "+"

		keyR:SetHotKeyCompositePaths(data.rPaths)
	end

	self.view.listUList:SetList(rows)
end

function SettingKeyAttentionConsoleCtrl:getActionShowName(actionName)
	for _, item in ipairs(GamepadHotKeyData) do
		if item.actionName then
			for _, an in ipairs(item.actionName) do
				if an == actionName then
					return pg.getLocalizationText(item.desc)
				end
			end
		end
	end

	return ""
end

function SettingKeyAttentionConsoleCtrl:fullActionNamesFor(actionName)
	for _, item in ipairs(GamepadHotKeyData) do
		if item.actionName then
			for _, an in ipairs(item.actionName) do
				if an == actionName then
					return item.actionName
				end
			end
		end
	end

	return {
		actionName
	}
end

function SettingKeyAttentionConsoleCtrl:onInputDeviceChanged(deviceType)
	if not pg.game.input:isUsingGamepad() then
		self:close()
	end
end

function SettingKeyAttentionConsoleCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function SettingKeyAttentionConsoleCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function SettingKeyAttentionConsoleCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function SettingKeyAttentionConsoleCtrl:onShow()
	return
end

function SettingKeyAttentionConsoleCtrl:onHide()
	return
end

return SettingKeyAttentionConsoleCtrl
