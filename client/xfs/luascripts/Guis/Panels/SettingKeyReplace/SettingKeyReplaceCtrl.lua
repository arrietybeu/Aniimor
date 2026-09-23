-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SettingKeyReplace\\SettingKeyReplaceCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("SettingKeyReplaceCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientSettingUtils = require("Utils.ClientSettingUtils")
local TimerManager = require("Core.Timer.TimerManager")
local UIConst = require("Const.UIConst")
local SettingKeyReplaceCtrl = Class.LightClass("SettingKeyReplaceCtrl", UICtrl)
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HotkeyConst = require("Const.HotkeyConst")
local GamepadHotKeyData = require("Data.gamepad_hotkey_data")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro

SettingKeyReplaceCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function SettingKeyReplaceCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.curExpandedSelector = nil
	self.originItem = nil
	self.conflictItem = nil

	LuaUIUtils.setUIViewVisible(self.view.planUSelector.gameObject, false)
	self:initKeyList()
end

function SettingKeyReplaceCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.root.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Canceled" then
			if self.curExpandedSelector then
				self.curExpandedSelector:ClosePopup()

				self.curExpandedSelector = nil
			else
				self:dismiss()
			end
		end
	end

	function self.view.btnCloseUButton.luaClick()
		self:dismiss()
	end

	function self.view.btnReSetUButton.luaClick()
		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("HOTKEY_RESET_DEFAULT"), function()
			if pg.game.input:isUsingGamepad() then
				pg.game.input:resetAllHotkeys(pg.game.input.gamepadHotkeyManager)
			else
				pg.game.input:resetAllHotkeys(pg.game.input.keyboardHotkeyManager)
			end

			facade:SendMessageCommand(MessageName.HOTKEY_UPDATE)

			if self.view then
				self:initKeyList()
			end
		end)
	end
end

function SettingKeyReplaceCtrl:initKeyList()
	if pg.game.input:isUsingGamepad() then
		self:initGamepad()
	else
		self:initKeyboard()
	end
end

function SettingKeyReplaceCtrl:initKeyboard()
	function self.view.keyUList.luaRenderItem(button, index, data)
		if data.tIndex == 1 then
			local uList = button:GetChild("List"):GetComponent("UList")

			function uList.luaRenderItem(button2, index2, data2)
				button2:TryChangePage("Type", 0)
				ClientTextUtils.setText(button2:GetChild("TxtName"):GetComponent("UBaseText"), pg.getLocalizationText(data2.label))

				local hotKeyContent = button2:GetChild("Key"):GetComponent("HotKeyContent")

				hotKeyContent:SetHotKeyPaths(data2.actionNames[1])

				local _aN = data2.actionNames[1]
				local _cur = _aN and pg.game.input.keyboardHotkeyManager:GetActionPath(_aN) or nil
				local isModified = data2.defaultPath ~= nil and _cur ~= nil and _cur ~= data2.defaultPath

				button2:TryChangePage("active", isModified and 0 or 1)
			end

			function uList.luaClick(button2, data2)
				if pg.game.input:isUsingGamepad() then
					return
				end

				button2.interactable = false

				button2:TryChangePage("state", 1)

				local valid = pg.game.input:performHotkeyRebind(pg.game.input.keyboardHotkeyManager, data2.actionNames[1], function()
					button2:TryChangePage("Type", 0)
					button2:TryChangePage("state", 0)

					if LoggerManager.checkLogger(LoggerConst.DEBUG) then
						logger:debug("onCancel")
					end

					TimerManager.addTimer(0.1, function()
						button2.interactable = true
					end)
				end, function()
					SettingKeyReplaceCtrl.setKeyUListButtonKeyContent(button2, data2.actionNames[1])
					button2:TryChangePage("Type", 0)
					button2:TryChangePage("state", 0)

					if LoggerManager.checkLogger(LoggerConst.DEBUG) then
						logger:debug("SetHotKeyPaths onComplete")
					end

					TimerManager.addTimer(0.1, function()
						button2.interactable = true
					end)
					LuaUIUtils.sendCustomLog(Const.BILogName.SETTING, {
						pc_key = 1
					})
					facade:SendMessageCommand(MessageName.HOTKEY_UPDATE)
					self:refreshKeyboardList()
				end, function(conflictPaths, bindPath)
					if LoggerManager.checkLogger(LoggerConst.DEBUG) then
						logger:debug("SetHotKeyPaths onConflict: " .. conflictPaths[0])
					end

					pg.global.ui:open(UIConst.UI_ID_SETTING_KEY_ATTENTION, {
						state = 1,
						originPath = data2.actionNames,
						candidateValue = bindPath,
						conflictPaths = conflictPaths,
						confirmCallback = function()
							local valid = pg.game.input:setHotkeyRebind(pg.game.input.keyboardHotkeyManager, data2.actionNames[1], bindPath)

							LuaUIUtils.sendCustomLog(Const.BILogName.SETTING, {
								pc_key = 1
							})
							facade:SendMessageCommand(MessageName.HOTKEY_UPDATE)

							if LoggerManager.checkLogger(LoggerConst.DEBUG) then
								logger:debug("confirmCallback valid ", valid)
							end

							self:refreshKeyboardList()
						end,
						cancelCallback = function()
							return
						end
					})
					button2:TryChangePage("Type", 0)
					button2:TryChangePage("state", 0)
					TimerManager.addTimer(0.1, function()
						button2.interactable = true
					end)
				end, function()
					pg.global.ui.tips:showTextTip(pg.getGameString("ACTION_REPLACE_KEY_ERROR_TOAST"))
					pg.game.input.keyboardHotkeyManager:CancelRebindInputAction()
				end)

				if LoggerManager.checkLogger(LoggerConst.DEBUG) then
					logger:debug("valid ", valid)
				end
			end

			uList:SetList(data.subItems)
		end
	end

	self:refreshKeyboardList()
end

function SettingKeyReplaceCtrl.setKeyUListButtonKeyContent(btn, actionName)
	if btn == nil then
		return
	end

	local hotKeyContent = btn:GetChild("Key"):GetComponent("HotKeyContent")

	hotKeyContent:SetHotKeyPaths(actionName)
end

function SettingKeyReplaceCtrl:refreshKeyboardList()
	local data = self.model:getKeyboardList()

	self.view.keyUList:SetList(data)
end

function SettingKeyReplaceCtrl:setItemHighlight(ulist, subItems, conflictPaths)
	for index, item in ipairs(subItems) do
		if item.actionNames[1] == conflictPaths[0] then
			local isExist, button = ulist:TryGetChildAt(index - 1)

			if isExist then
				button:TryChangePage("GamePadFocus", 1)

				if self.conflictItem then
					self.conflictItem:TryChangePage("GamePadFocus", 0)

					self.conflictItem = button
				end
			end
		end
	end
end

function SettingKeyReplaceCtrl:initGamepad(info)
	pg.game.input:rebindGamepadManualPlaceholders(pg.game.input:getCurDeviceType())

	function self.view.keyUList.luaRenderItem(button, index, data)
		if data.tIndex == 1 then
			local uList = button:GetChild("List"):GetComponent("UList")

			function uList.luaRenderItem(button2, index2, data2)
				ClientTextUtils.setText(button2:GetChild("TxtName"):GetComponent("UBaseText"), pg.getLocalizationText(data2.label))

				local text = pg.getLocalizationText(data2.label)

				button2:TryChangePage("Type", 2)

				local curKeyBinding = button2:GetChild("Key"):GetComponent("HotKeyContent")

				curKeyBinding:SetHotKeyCompositePaths({})

				local selector = button2:GetChild("Selector"):GetComponent("USelector")

				LuaUIUtils.setUIViewVisible(selector:GetChild("TxtName").gameObject, false)

				function selector.luaRenderPopup(popup, uList)
					self.curExpandedSelector = selector

					function uList.luaRenderItem(button3, index3, data3)
						data3.selected = false

						if button3.isSelected then
							button3.isSelected = false
						end

						button3:TryChangePage("active", 1)
						button3:TryChangePage("GamePadFocus", 0)

						if self:checkIsCurOption(data2.actionNames, data3.value) then
							button3:TryChangePage("GamePadFocus", 2)
						end

						local hotKeyContent = button3:GetChild("Key"):GetComponent("HotKeyContent")

						hotKeyContent.curGroup = pg.game.input.gamepadHotkeyManager.groupName
						hotKeyContent.useRawBindingPath = true
						hotKeyContent.splitString = "+"

						local paths = {}

						for index, path in ipairs(data3.value) do
							table.insert(paths, path)
						end

						hotKeyContent:SetHotKeyCompositePaths(paths)
					end
				end

				local _, options = self:getOptionsData(data2)

				selector.options = options
				selector.selectedIndex = -1

				function selector.luaOptionClick(button3, data3)
					self.curExpandedSelector = nil

					if self:checkIsCurOption(data2.actionNames, data3.value) then
						return
					end

					local function applyRebind()
						local valid = pg.game.input:setHotkeyRebind(pg.game.input.gamepadHotkeyManager, data2.actionNames[1], data3.value[1])

						if LoggerManager.checkLogger(LoggerConst.INFO) then
							logger:info("valid", valid)
						end

						if data2.actionNames[2] then
							valid = pg.game.input:setHotkeyRebind(pg.game.input.gamepadHotkeyManager, data2.actionNames[2], data3.value[2])

							if LoggerManager.checkLogger(LoggerConst.INFO) then
								logger:info("valid2", valid)
							end
						end

						LuaUIUtils.sendCustomLog(Const.BILogName.SETTING, {
							control_key = 1
						})
						facade:SendMessageCommand(MessageName.HOTKEY_UPDATE)
						self:refreshGamepadList()
					end

					local conflicts = self:collectGamepadConflicts(data2.actionNames, data3.value)

					if #conflicts == 0 then
						applyRebind()
					else
						pg.global.ui:open(UIConst.UI_ID_SETTING_KEY_ATTENTION_CONSOLE, {
							state = 1,
							originActionNames = data2.actionNames,
							candidateValue = data3.value,
							conflictActionPaths = conflicts,
							confirmCallback = applyRebind,
							cancelCallback = function()
								return
							end
						})
					end
				end

				local hotKeyContent = selector:GetChild("Key"):GetComponent("HotKeyContent")

				hotKeyContent.curGroup = pg.game.input.gamepadHotkeyManager.groupName

				local actionNames = {}

				if data2.frontActionName then
					table.insert(actionNames, data2.frontActionName)
				else
					hotKeyContent.splitString = "+"
				end

				for _, actionName in ipairs(data2.actionNames) do
					table.insert(actionNames, actionName)
				end

				hotKeyContent:SetHotKeyCompositePaths(actionNames)

				local mgr = pg.game.input.gamepadHotkeyManager
				local defaultOpt = data2.replaceActionName and data2.replaceActionName[1] or nil
				local curPath1 = data2.actionNames[1] and mgr:GetActionPath(data2.actionNames[1]) or nil
				local curPath2 = data2.actionNames[2] and mgr:GetActionPath(data2.actionNames[2]) or nil
				local isModified = defaultOpt ~= nil and (curPath1 ~= defaultOpt[1] or data2.actionNames[2] and curPath2 ~= defaultOpt[2] or false)

				button2:TryChangePage("active", isModified and 0 or 1)
			end

			uList:SetList(data.subItems)
		end
	end

	self:refreshGamepadList()
end

function SettingKeyReplaceCtrl:refreshGamepadList(planIndex)
	local data = self.model:getGamepadList(planIndex)

	self.view.keyUList:SetList(data)
end

function SettingKeyReplaceCtrl:getOptionsData(data)
	local optionData = {}
	local curPath = pg.game.input.gamepadHotkeyManager:GetActionPath(data.actionNames[1])
	local curPath2

	if data.actionNames[2] then
		curPath2 = pg.game.input.gamepadHotkeyManager:GetActionPath(data.actionNames[2])
	end

	local curSelectedIndex = -1

	for index, value in ipairs(data.replaceActionName) do
		table.insert(optionData, {
			value = value
		})

		if value[1] == curPath and value[2] == curPath2 then
			curSelectedIndex = index
		end
	end

	return curSelectedIndex - 1, optionData
end

function SettingKeyReplaceCtrl:collectGamepadConflicts(actionNames, value)
	local mgr = pg.game.input.gamepadHotkeyManager
	local visibleSet = {}

	for _, item in ipairs(GamepadHotKeyData) do
		if item.actionName then
			for _, an in ipairs(item.actionName) do
				visibleSet[an] = true
			end
		end
	end

	local seen, list = {}, {}

	local function pushFrom(actionName, bindPath)
		if not bindPath or bindPath == "" then
			return
		end

		local res = mgr:TryGetConflictActionPaths(actionName, bindPath)

		if not res then
			return
		end

		for i = 0, res.Count - 1 do
			local p = res[i]

			if p ~= actionNames[1] and p ~= actionNames[2] and not seen[p] and visibleSet[p] then
				seen[p] = true
				list[#list + 1] = p
			end
		end
	end

	pushFrom(actionNames[1], value[1])

	if actionNames[2] then
		pushFrom(actionNames[2], value[2])
	end

	return setmetatable(list, {
		__index = function(t, k)
			if type(k) == "number" then
				return rawget(t, k + 1)
			end
		end
	})
end

function SettingKeyReplaceCtrl:checkIsCurOption(actionNames, value)
	local curPath = pg.game.input.gamepadHotkeyManager:GetActionPath(actionNames[1])
	local curPath2

	if actionNames[2] then
		curPath2 = pg.game.input.gamepadHotkeyManager:GetActionPath(actionNames[2])
	end

	return curPath == value[1] and curPath2 == value[2]
end

function SettingKeyReplaceCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function SettingKeyReplaceCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function SettingKeyReplaceCtrl:onShow()
	return
end

function SettingKeyReplaceCtrl:onHide()
	return
end

function SettingKeyReplaceCtrl:onInputDeviceChanged(deviceType)
	self:initKeyList()
end

return SettingKeyReplaceCtrl
