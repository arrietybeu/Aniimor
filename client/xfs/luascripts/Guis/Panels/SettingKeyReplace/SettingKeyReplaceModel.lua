-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SettingKeyReplace\\SettingKeyReplaceModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local KeyboardHotKeyData = require("Data.keyboard_hotkey_data")
local GamepadHotkeyData = require("Data.gamepad_hotkey_data")
local GamepadManualResolver = require("GameApp.Input.GamepadManualResolver")
local SettingKeyReplaceModel = Class.LightClass("SettingKeyReplaceModel", UIModel)

function SettingKeyReplaceModel:getKeyboardDesc(actionName)
	for _, item in ipairs(KeyboardHotKeyData) do
		if item.actionName == actionName then
			return item.desc
		end
	end

	return ""
end

function SettingKeyReplaceModel:getKeyboardListWithChange()
	if self.keyboardHotkeyActionsWithChange and #self.keyboardHotkeyActionsWithChange > 0 then
		self.keyboardHotkeyActionsWithChange[2].subItems = {}

		for action, bindPath in pairs(pg.game.input.keyboardHotkeyManager.playerOverridePaths) do
			table.insert(self.keyboardHotkeyActionsWithChange[2].subItems, {
				tIndex = 0,
				actionNames = {
					action
				},
				label = self:getKeyboardDesc(action)
			})
		end

		return self.keyboardHotkeyActionsWithChange
	end

	self.keyboardHotkeyActionsWithChange = {}

	local keyboardList = self:getKeyboardList()

	for index, value in ipairs(keyboardList) do
		table.insert(self.keyboardHotkeyActionsWithChange, value)
	end

	local subItems = {}

	for action, bindPath in pairs(pg.game.input.keyboardHotkeyManager.playerOverridePaths) do
		table.insert(subItems, {
			tIndex = 0,
			actionNames = {
				action
			},
			label = self:getKeyboardDesc(action)
		})
	end

	table.insert(self.keyboardHotkeyActionsWithChange, 1, {
		tIndex = 1,
		subItems = subItems
	})
	table.insert(self.keyboardHotkeyActionsWithChange, 1, {
		tIndex = 0,
		label = pg.getGameString("HOTKEY_CHANGED")
	})

	return self.keyboardHotkeyActionsWithChange
end

function SettingKeyReplaceModel:getKeyboardList()
	self.keyboardHotkeyActions = {}

	local hotKeyType
	local subItems = {}
	local keys = {}

	for key, v in pairs(KeyboardHotKeyData) do
		table.insert(keys, {
			idx = key,
			_sort = v.keyorder
		})
	end

	table.sort(keys, function(a, b)
		return a._sort < b._sort
	end)

	for _, key in pairs(keys) do
		local item = KeyboardHotKeyData[key.idx]

		if hotKeyType == nil or string.sub(hotKeyType.label, 1, 10) ~= string.sub(pg.getLocalizationText(item.type), 1, 10) then
			if #subItems > 0 then
				table.insert(self.keyboardHotkeyActions, {
					tIndex = 1,
					subItems = subItems
				})
			end

			subItems = {}
			hotKeyType = {
				tIndex = 0,
				label = pg.getLocalizationText(item.type)
			}

			table.insert(self.keyboardHotkeyActions, hotKeyType)
		end

		table.insert(subItems, {
			tIndex = 0,
			actionNames = {
				item.actionName
			},
			label = item.desc,
			keycolor = item.keycolor,
			keyorder = item.keyorder,
			defaultPath = item.inputkey
		})
	end

	if #subItems > 0 then
		table.insert(self.keyboardHotkeyActions, {
			tIndex = 1,
			subItems = subItems
		})
	end

	return self.keyboardHotkeyActions
end

function SettingKeyReplaceModel:getGamepadDesc(actionName)
	for _, item in ipairs(GamepadHotkeyData) do
		if item.actionName[1] == actionName then
			return item.desc
		end
	end

	return ""
end

function SettingKeyReplaceModel:getGamepadList(planIndex)
	planIndex = planIndex or 1
	self["gamepadHotkeyActions" .. planIndex] = {}

	local hotKeyType
	local subItems = {}

	for _, item in ipairs(GamepadHotkeyData) do
		if hotKeyType == nil or string.sub(hotKeyType.label, 1, 10) ~= string.sub(pg.getLocalizationText(item.type), 1, 10) then
			if #subItems > 0 then
				table.insert(self["gamepadHotkeyActions" .. planIndex], {
					tIndex = 1,
					subItems = subItems
				})
			end

			subItems = {}
			hotKeyType = {
				tIndex = 0,
				label = pg.getLocalizationText(item.type)
			}

			table.insert(self["gamepadHotkeyActions" .. planIndex], hotKeyType)
		end

		if item.listkey then
			local replaceActionName = {}

			table.insert(replaceActionName, GamepadManualResolver.resolveBindingList(item.inputkey))

			for _, value in ipairs(item.listkey) do
				table.insert(replaceActionName, GamepadManualResolver.resolveBindingList(value))
			end

			table.insert(subItems, {
				tIndex = 0,
				actionNames = item.actionName,
				label = item.desc,
				frontActionName = item.frontkey,
				replaceActionName = replaceActionName
			})
		end
	end

	if #subItems > 0 then
		table.insert(self["gamepadHotkeyActions" .. planIndex], {
			tIndex = 1,
			subItems = subItems
		})
	end

	return self["gamepadHotkeyActions" .. planIndex]
end

return SettingKeyReplaceModel
