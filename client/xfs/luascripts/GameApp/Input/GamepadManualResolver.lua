-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Input\\GamepadManualResolver.lua

local InputDeviceType = CS.FunPlus.WorldX.Manager.InputDeviceType
local Utils = require("Common.Utils.Utils")
local KeyMap = {
	SelectButton = {
		SwitchPad = "<SwitchProControllerHID>/select",
		XBox = "<Gamepad>/select",
		_genericPath = "<Gamepad>/select",
		PSPad = "<DualShockGamepad>/touchpadButton"
	}
}
local PLACEHOLDER_PREFIX = "<GamepadManual>/"
local PLACEHOLDER_PREFIX_LEN = #PLACEHOLDER_PREFIX
local GamepadManualResolver = {}

local function toDeviceName(deviceType)
	if deviceType == InputDeviceType.PSPad then
		return "PSPad"
	elseif deviceType == InputDeviceType.SwitchPad then
		return "SwitchPad"
	end

	return "XBox"
end

local function getCurDeviceType()
	return pg.global.inputMgr.curDeviceType
end

local function toLuaTable(t)
	if type(t) ~= "table" and type(t) ~= "userdata" then
		return t
	end

	return Utils.deepCopyTable(t)
end

function GamepadManualResolver.isPlaceholder(path)
	return type(path) == "string" and string.sub(path, 1, PLACEHOLDER_PREFIX_LEN) == PLACEHOLDER_PREFIX
end

function GamepadManualResolver.resolvePath(path, deviceType)
	if not GamepadManualResolver.isPlaceholder(path) then
		return path
	end

	local placeholderName = string.sub(path, PLACEHOLDER_PREFIX_LEN + 1)
	local entry = KeyMap[placeholderName]

	if not entry then
		return path
	end

	local devName = toDeviceName(deviceType or getCurDeviceType())

	return entry[devName] or entry.XBox or path
end

function GamepadManualResolver.resolveBindingList(list, deviceType)
	list = toLuaTable(list)

	if type(list) ~= "table" then
		return list
	end

	local result = {}

	for i, v in ipairs(list) do
		result[i] = GamepadManualResolver.resolvePath(v, deviceType)
	end

	return result
end

function GamepadManualResolver.resolveExcelData(excelData, deviceType)
	excelData = toLuaTable(excelData)

	if type(excelData) ~= "table" then
		return excelData
	end

	for _, item in ipairs(excelData) do
		if type(item.inputkey) == "table" then
			item.inputkey = GamepadManualResolver.resolveBindingList(item.inputkey, deviceType)
		end

		if type(item.listkey) == "table" then
			local newListKey = {}

			for i, row in ipairs(item.listkey) do
				newListKey[i] = GamepadManualResolver.resolveBindingList(row, deviceType)
			end

			item.listkey = newListKey
		end
	end

	return excelData
end

function GamepadManualResolver.getPlaceholderActions(excelData)
	excelData = toLuaTable(excelData)

	local result = {}

	if type(excelData) ~= "table" then
		return result
	end

	for _, item in ipairs(excelData) do
		if type(item.inputkey) == "table" and type(item.actionName) == "table" then
			for i, key in ipairs(item.inputkey) do
				if GamepadManualResolver.isPlaceholder(key) then
					local actionName = item.actionName[i]

					if actionName then
						result[actionName] = string.sub(key, PLACEHOLDER_PREFIX_LEN + 1)
					end
				end
			end
		end
	end

	return result
end

local _pathToPlaceholderCache

function GamepadManualResolver.getPathToPlaceholderMap()
	if _pathToPlaceholderCache == nil then
		_pathToPlaceholderCache = {}

		for placeholderName, deviceMap in pairs(KeyMap) do
			for k, path in pairs(deviceMap) do
				if string.sub(k, 1, 1) ~= "_" then
					_pathToPlaceholderCache[path] = placeholderName
				end
			end
		end
	end

	return _pathToPlaceholderCache
end

function GamepadManualResolver.resolvePlaceholderName(placeholderName, deviceType)
	local entry = KeyMap[placeholderName]

	if not entry then
		return nil
	end

	local devName = toDeviceName(deviceType or getCurDeviceType())

	return entry[devName] or entry.XBox
end

function GamepadManualResolver.getGenericPathByDevicePath(path)
	local placeholderName = GamepadManualResolver.getPathToPlaceholderMap()[path]

	if not placeholderName then
		return nil
	end

	local entry = KeyMap[placeholderName]

	return entry and entry._genericPath or nil
end

return GamepadManualResolver
