-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SettingKeyAttention\\SettingKeyAttentionCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local KeyboardHotKeyData = require("Data.keyboard_hotkey_data")
local SettingKeyAttentionCtrl = Class.LightClass("SettingKeyAttentionCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")

SettingKeyAttentionCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function SettingKeyAttentionCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.confirmCallback = info.confirmCallback
	self.cancelCallback = info.cancelCallback

	self:initUI(info)
end

function SettingKeyAttentionCtrl:addListener()
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

function SettingKeyAttentionCtrl:initUI(info)
	if self.view.txtTltleUSDFText then
		ClientTextUtils.setText(self.view.txtTltleUSDFText, pg.getGameString("HOT_KEY_CONFLICT"))
	end

	if info.state == 1 then
		self:initKeyConflict(info)
	end

	ClientTextUtils.setText(self.view.btnCancelTxtNameUText, pg.getGameString("EXIT_GAME_CANCEL"))
	ClientTextUtils.setText(self.view.btnConfirmTxtNameUText, pg.getGameString("COMMON_CONFIRM"))
end

function SettingKeyAttentionCtrl:initKeyConflict(info)
	local origin = info.originPath or {}
	local conflictPath = self:getVisibleConflictPath(info.conflictPaths)
	local candidateValue = info.candidateValue
	local originOldPaths = self:getActionPaths(origin)

	if self.view.textUSDFText then
		ClientTextUtils.setText(self.view.textUSDFText, pg.getFormatText(pg.getGameString("HOT_KEY_CONFLICT_DESC"), self:getActionShowName(origin[1]), self:getActionShowName(conflictPath)))
	end

	local data = {
		{
			actionName = origin[1],
			lPaths = originOldPaths,
			rPaths = self:normalizePathList(candidateValue)
		},
		{
			actionName = conflictPath,
			lPaths = self:getActionPaths({
				conflictPath
			}),
			rPaths = originOldPaths
		}
	}

	function self.view.listUList.luaRenderItem(button, index, item)
		local objRef = button:GetComponent("ObjectReference")
		local txtL = objRef:GetRefValue("textNameLUSDFText")
		local keyL = objRef:GetRefValue("keyLHotKeyContent")
		local txtR = objRef:GetRefValue("textNameRUSDFText")
		local keyR = objRef:GetRefValue("keyRHotKeyContent")
		local label = self:getActionShowName(item.actionName)

		ClientTextUtils.setText(txtL, label)
		ClientTextUtils.setText(txtR, label)

		keyL.useRawBindingPath = true
		keyL.splitString = "+"

		keyL:SetHotKeyCompositePaths(item.lPaths)

		keyR.useRawBindingPath = true
		keyR.splitString = "+"

		keyR:SetHotKeyCompositePaths(item.rPaths)
	end

	self.view.listUList:SetList(data)
end

function SettingKeyAttentionCtrl:getVisibleConflictPath(conflictPaths)
	if not conflictPaths then
		return nil
	end

	for index = 0, conflictPaths.Count - 1 do
		local conflictPath = conflictPaths[index]

		for _, item in pairs(KeyboardHotKeyData) do
			if item.actionName == conflictPath then
				return conflictPath
			end
		end
	end

	return conflictPaths[0]
end

function SettingKeyAttentionCtrl:getActionShowName(actionName)
	for _, item in pairs(KeyboardHotKeyData) do
		if item.actionName == actionName then
			return pg.getLocalizationText(item.desc)
		end
	end

	return ""
end

function SettingKeyAttentionCtrl:getActionPaths(actionNames)
	local paths = {}

	for _, actionName in ipairs(actionNames or EMPTY_TABLE) do
		local path = pg.game.input.keyboardHotkeyManager:GetActionPath(actionName)

		if path and path ~= "" then
			table.insert(paths, path)
		end
	end

	return paths
end

function SettingKeyAttentionCtrl:normalizePathList(path)
	if type(path) == "table" then
		return path
	end

	if path then
		return {
			path
		}
	end

	return {}
end

function SettingKeyAttentionCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function SettingKeyAttentionCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function SettingKeyAttentionCtrl:onInputDeviceChanged(deviceType)
	if pg.game.input:isUsingGamepad() then
		self:close()
	end
end

function SettingKeyAttentionCtrl:onShow()
	return
end

function SettingKeyAttentionCtrl:onHide()
	return
end

return SettingKeyAttentionCtrl
