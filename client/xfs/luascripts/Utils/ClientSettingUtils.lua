-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ClientSettingUtils.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("SettingModel")
local SettingMapData = require("Data.setting_map_data")
local SettingFuncListData = require("Data.setting_func_list_data")
local ClientConst = require("Const.ClientConst")
local AudioConst = require("Const.AudioConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local SettingSelectorText = require("Data.setting_selector_text_data")
local Utils = require("Common.Utils.Utils")
local SettingConst = require("Const.SettingConst")
local Const = require("Common.Const.Const")
local EventConst = require("Const.EventConst")
local ClientUtils = require("Utils.ClientUtils")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local KeyboardLayoutAdapter = CS.FunPlus.WorldX.GameApp.Input.KeyboardLayoutAdapter
local ClientSettingUtils = {
	showUIParam = {
		Compass = "compass",
		Help = "help"
	},
	keyReplaceType = {
		Keyboard = 1,
		Gamepad = 2
	},
	logCache = {},
	SettingTabName = {
		Audio = "audio",
		Language = "language",
		Video = "video",
		Operate = "operate",
		Game = "game"
	}
}
local LARGE_SCREEN_MODE_KEY = "largeScreenMode"
local AnimationQualityConfig = {
	{
		Windows = {
			true,
			0.1,
			32,
			0.5,
			8,
			2,
			4,
			6,
			4,
			16,
			32
		},
		Android = {
			true,
			0.2,
			32,
			0.5,
			8,
			2,
			4,
			6,
			4,
			16,
			32
		},
		IOS = {
			true,
			0.2,
			32,
			0.5,
			8,
			2,
			4,
			6,
			4,
			16,
			32
		},
		PS5 = {
			true,
			0.6,
			32,
			0.5,
			8,
			1,
			2,
			4,
			10,
			30,
			60
		},
		XBOX = {
			true,
			0.6,
			32,
			0.5,
			8,
			1,
			2,
			4,
			10,
			30,
			60
		},
		Default = {
			true,
			0.6,
			32,
			0.5,
			8,
			1,
			2,
			4,
			10,
			30,
			60
		}
	},
	{
		Android = {
			true,
			0.6,
			32,
			0.5,
			4,
			1,
			2,
			3,
			16,
			40,
			60
		},
		IOS = {
			true,
			0.6,
			32,
			0.5,
			4,
			1,
			2,
			3,
			16,
			40,
			60
		},
		PS5 = {
			true,
			0.6,
			32,
			0.5,
			4,
			1,
			2,
			3,
			30,
			64,
			100
		},
		XBOX = {
			true,
			0.6,
			32,
			0.5,
			4,
			1,
			2,
			3,
			30,
			64,
			100
		},
		Default = {
			true,
			0.6,
			32,
			0.5,
			4,
			1,
			2,
			3,
			30,
			64,
			100
		}
	},
	{
		Android = {
			true,
			0.6,
			32,
			0.5,
			4,
			1,
			2,
			3,
			16,
			64,
			100
		},
		IOS = {
			true,
			0.6,
			32,
			0.5,
			4,
			1,
			2,
			3,
			16,
			64,
			100
		},
		XBOX = {
			false,
			2,
			8,
			0.5,
			2
		},
		PS5 = {
			false,
			2,
			8,
			0.5,
			2
		},
		Default = {
			false,
			2,
			8,
			0.5,
			2
		}
	}
}

function ClientSettingUtils.applySettingValue(funcType, ...)
	local visited = {}
	local args = {
		...
	}

	ClientSettingUtils._applySettingValue_inner(funcType, args, visited)

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_SETTING) then
		pg.global.ui.setting:refreshSettingListNoData()
	end
end

function ClientSettingUtils.applyPlayerSettingValue(funcType, value, funcParam)
	if funcType == ClientConst.SettingFuncType.VideoQuality then
		ClientSettingUtils.set_setVideoQuality(value, funcParam)
		pg.game.setting:applyPlayerVideoQualityRelation(pg.game.setting:getVideoQuality())
	elseif funcType == ClientConst.SettingFuncType.VSync then
		ClientSettingUtils.set_vSync(value, funcParam, true)
	elseif funcType == ClientConst.SettingFuncType.TargetFramerate then
		ClientSettingUtils.set_targetFramerate(value, funcParam, true)
	else
		return ClientSettingUtils.applySettingValue(funcType, value, funcParam)
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_SETTING) then
		pg.global.ui.setting:refreshSettingListNoData()
	end
end

function ClientSettingUtils.get_autoAcceptSpaceFollowRequire(optionDatas)
	local state = pg.game.setting:getAutoAcceptSpaceFollowRequire()

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, state)
end

function ClientSettingUtils.set_autoAcceptSpaceFollowRequire(value)
	pg.game.setting:setAutoAcceptSpaceFollowRequire(value)
end

function ClientSettingUtils.get_autoAcceptSpaceFollowInvite(optionDatas)
	local state = pg.game.setting:getAutoAcceptSpaceFollowInvite()

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, state)
end

function ClientSettingUtils.set_autoAcceptSpaceFollowInvite(value)
	pg.game.setting:setAutoAcceptSpaceFollowInvite(value)
end

function ClientSettingUtils._applySettingValue_inner(funcType, args, visited)
	if visited[funcType] then
		return
	end

	visited[funcType] = true

	local isTable = Utils.isTable(args)

	if isTable then
		ClientSettingUtils.setValueNoRefreshList(funcType, unpack(args))
	else
		ClientSettingUtils.setValueNoRefreshList(funcType, args)
	end

	local key = isTable and args[1] or args
	local relation = SettingMapData[funcType] and SettingMapData[funcType][key]

	if not relation then
		return
	end

	local relationTable = relation.relationTable or {}

	for _, value in ipairs(relationTable) do
		if Utils.isTable(value[2]) then
			if value[2][pg.game.setting.curPlatform] then
				ClientSettingUtils._applySettingValue_inner(value[1], value[2][pg.game.setting.curPlatform], visited)
			end
		else
			ClientSettingUtils._applySettingValue_inner(value[1], value[2], visited)
		end
	end
end

function ClientSettingUtils.applyRelationValue(funcType, key, needRefresh)
	local visited = {}

	visited[funcType] = true

	local relation = SettingMapData[funcType] and SettingMapData[funcType][key]

	if not relation then
		return
	end

	local relationTable = relation.relationTable or {}

	for _, value in ipairs(relationTable) do
		if Utils.isTable(value[2]) then
			if value[2][pg.game.setting.curPlatform] then
				ClientSettingUtils._applySettingValue_inner(value[1], value[2][pg.game.setting.curPlatform], visited)
			end
		else
			ClientSettingUtils._applySettingValue_inner(value[1], value[2], visited)
		end
	end

	if needRefresh and pg.global.ui:checkUIOpen(UIConst.UI_ID_SETTING) then
		pg.global.ui.setting:refreshSettingListNoData()
	end
end

function ClientSettingUtils.setValueNoRefreshList(func, ...)
	if ClientSettingUtils[func] then
		ClientSettingUtils[func](...)
	elseif ClientSettingUtils["set_" .. func] then
		ClientSettingUtils["set_" .. func](...)
	end
end

function ClientSettingUtils.setValue(func, ...)
	if ClientSettingUtils[func] then
		ClientSettingUtils[func](...)
	elseif ClientSettingUtils["set_" .. func] then
		ClientSettingUtils["set_" .. func](...)
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_SETTING) then
		pg.global.ui.setting:refreshSettingListNoData()
	end
end

function ClientSettingUtils.setDefault_crossPlatform()
	local _h = ClientSettingUtils._platformHooks

	if _h and _h.setDefault_crossPlatform then
		return _h.setDefault_crossPlatform()
	end
end

ClientSettingUtils.ACCOUNT_BIND_SOCIAL_TYPE = {
	[ClientConst.SettingFuncType.MobileAccountBind] = "mobile",
	[ClientConst.SettingFuncType.EmailAccountBind] = "email"
}

function ClientSettingUtils.getAccountBindId(funcType)
	local socialType = ClientSettingUtils.ACCOUNT_BIND_SOCIAL_TYPE[funcType]

	return pg.global.sdkManager:getSocialBindId(socialType)
end

function ClientSettingUtils.getAccountBindDisplayData(settingInfo)
	if settingInfo.funcType == ClientConst.SettingFuncType.SocialAccountBind then
		local socialType = settingInfo.funcParam[1]
		local isBound, displayText = pg.global.sdkManager:getSocialBindInfo(socialType)

		return isBound, displayText, isBound and 3 or 1, 1
	elseif settingInfo.funcType == ClientConst.SettingFuncType.EmailAccountBind then
		local displayText = ClientSettingUtils.getAccountBindId(settingInfo.funcType)
		local isBound = not string.isNilOrEmpty(displayText)

		return isBound, displayText, isBound and 2 or 1
	elseif settingInfo.funcType == ClientConst.SettingFuncType.MobileAccountBind then
		local displayText = ClientSettingUtils.getAccountBindId(settingInfo.funcType)

		return true, displayText, 2
	end

	return false, nil, 1
end

function ClientSettingUtils.handleAccountBindClick(settingInfo, isBound)
	local _h = ClientSettingUtils._platformHooks

	if _h and _h.handleAccountBindClick and _h.handleAccountBindClick(settingInfo.funcType) == true then
		return
	end

	if settingInfo.funcType ~= ClientConst.SettingFuncType.SocialAccountBind then
		pg.global.sdkManager:openUserCenter()

		return
	end

	local socialType = settingInfo.funcParam[1]

	if isBound then
		pg.global.sdkManager:unbindSocial(socialType)
	else
		pg.global.sdkManager:bindSocial(socialType)
	end
end

function ClientSettingUtils.get_crossPlatform(optionDatas)
	local _h = ClientSettingUtils._platformHooks

	if _h and _h.get_crossPlatform then
		return _h.get_crossPlatform(optionDatas)
	end

	return nil
end

function ClientSettingUtils.set_crossPlatform(value)
	local _h = ClientSettingUtils._platformHooks

	if _h and _h.set_crossPlatform then
		return _h.set_crossPlatform(value)
	end
end

function ClientSettingUtils.getSettingRelationValue(func, param, key)
	local relation = SettingMapData[func] and SettingMapData[func][param]

	if not relation then
		return nil
	end

	local relationTable = relation.relationTable or {}

	for _, value in ipairs(relationTable) do
		if value[1] == key then
			if Utils.isTable(value[2]) then
				return value[2][pg.game.setting.curPlatform]
			else
				return value[2]
			end
		end
	end
end

function ClientSettingUtils.setRelationValue(func, param)
	local relation = SettingMapData[func] and SettingMapData[func][param]

	if not relation then
		return
	end

	local relationTable = relation.relationTable or {}

	for _, value in ipairs(relationTable) do
		if Utils.isTable(value[2]) then
			if value[2][pg.game.setting.curPlatform] then
				ClientSettingUtils.setValue(value[1], value[2][pg.game.setting.curPlatform])
			end
		else
			ClientSettingUtils.setValue(value[1], value[2])
		end
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_SETTING) then
		pg.global.ui.setting:refreshSettingListNoData()
	end
end

function ClientSettingUtils.getSliderMinMaxValue(settingInfo)
	if settingInfo.funcType == ClientConst.SettingFuncType.ClientPuppet then
		return pg.game.setting.entityCountMin.ClientPuppet, pg.game.setting.entityCountMax.ClientPuppet
	elseif settingInfo.funcType == ClientConst.SettingFuncType.ClientPet then
		return pg.game.setting.entityCountMin.ClientPet, pg.game.setting.entityCountMax.ClientPet
	elseif settingInfo.funcType == ClientConst.SettingFuncType.ClientPlayer then
		return pg.game.setting.entityCountMin.ClientPlayer, pg.game.setting.entityCountMax.ClientPlayer
	elseif settingInfo.funcType == ClientConst.SettingFuncType.ClientEnvObject then
		return pg.game.setting.entityCountMin.ClientEnvObject, pg.game.setting.entityCountMax.ClientEnvObject
	end

	return settingInfo.widgetParam[1], settingInfo.widgetParam[2]
end

function ClientSettingUtils.setLog(key, value)
	ClientSettingUtils.logCache[key] = value
end

function ClientSettingUtils.reportLog()
	for index, value in pairs(ClientSettingUtils.logCache) do
		LuaUIUtils.sendCustomLog(Const.BILogName.SETTING, {
			setting_id = index,
			operation_id = value
		})
	end

	ClientSettingUtils.logCache = {}
end

function ClientSettingUtils.getKeyReplaceType()
	return {
		{
			label = pg.getGameString("HOTKEY_KEYBOARD"),
			value = ClientSettingUtils.keyReplaceType.Keyboard
		},
		{
			label = pg.getGameString("HOTKEY_GAMEPAD"),
			value = ClientSettingUtils.keyReplaceType.Gamepad
		}
	}
end

function ClientSettingUtils.getGamepadPlanList()
	return {
		{
			label = "1",
			value = 1
		},
		{
			label = "2",
			value = 2
		},
		{
			label = "3",
			value = 3
		}
	}
end

ClientSettingUtils.gamepadShowKeyList = {
	"Bind/MoveGamepad",
	"Bind/MoveCameraGamepad",
	"Bind/Pet1",
	"Bind/Pet2",
	"Bind/Pet3",
	"Bind/Pet4",
	"Bind/SwitchPet",
	"Bind/Jump",
	"Bind/Sprint",
	"Bind/NormalAttack",
	"Bind/Interact",
	"Bind/TrackOpenSpecial",
	"Bind/LockTarget",
	"Bind/Skill1",
	"Bind/Skill2",
	"Bind/SwitchCatchMode",
	"Bind/SwitchPet",
	"Bind/OpenChat",
	"Bind/FunctionMenu"
}
ClientSettingUtils.gamepadShowKeyDefaultPathMap = {
	["Bind/MoveCameraGamepad"] = "<Gamepad>/rightStick",
	["Bind/OpenChat"] = "<Gamepad>/select",
	["Bind/MoveGamepad"] = "<Gamepad>/leftStick",
	["Bind/FunctionMenu"] = "<Gamepad>/start",
	["Bind/Interact"] = "<Gamepad>/buttonNorth"
}
ClientSettingUtils.gamepadShowKeyDescMap = {
	["Bind/MoveCameraGamepad"] = "CONSOLE_BAR_MOVE_CAMERA",
	["Bind/OpenChat"] = "CONSOLE_BAR_MAP",
	["Bind/MoveGamepad"] = "GAMEPAD_PLAYER_MOVE",
	["Bind/FunctionMenu"] = "GAMEPAD_OPEN_MENU",
	["Bind/Interact"] = 1424614952
}
ClientSettingUtils.gamepadGenericPathMap = {
	["<SwitchProControllerHID>/select"] = "<Gamepad>/select",
	["<DualShockGamepad>/touchpadButton"] = "<Gamepad>/select",
	["<GXDKGamepad>/select"] = "<Gamepad>/select",
	["<XInputController>/select"] = "<Gamepad>/select",
	["Hud/PetManagementButtonFun14"] = "<Gamepad>/dpad/right",
	["Hud/PetManagementButtonFun13"] = "<Gamepad>/dpad/left",
	["Hud/PetManagementButtonFun12"] = "<Gamepad>/dpad/down",
	["Hud/PetManagementButtonFun11"] = "<Gamepad>/dpad/up",
	["Hud/PetManagementButtonFun10"] = "<Gamepad>/rightShoulder",
	["Hud/PetManagementButtonFun9"] = "<Gamepad>/leftShoulder",
	["Hud/PetManagementButtonFun4"] = "<Gamepad>/buttonSouth",
	["Hud/PetManagementButtonFun3"] = "<Gamepad>/buttonEast",
	["Hud/PetManagementButtonFun2"] = "<Gamepad>/buttonNorth",
	["Hud/PetManagementButtonFun1"] = "<Gamepad>/buttonWest",
	["Hud/LeftStickMove"] = "<Gamepad>/leftStick",
	["Raw/GamepadRightStickMove"] = "<Gamepad>/rightStick",
	["Raw/GamepadLeftStickMove"] = "<Gamepad>/leftStick",
	["Raw/GamepadStart"] = "<Gamepad>/start",
	["Raw/GamepadSelect"] = "<Gamepad>/select",
	["Raw/GamepadDPadRight"] = "<Gamepad>/dpad/right",
	["Raw/GamepadDPadLeft"] = "<Gamepad>/dpad/left",
	["Raw/GamepadDPadDown"] = "<Gamepad>/dpad/down",
	["Raw/GamepadDPadUp"] = "<Gamepad>/dpad/up",
	["Raw/GamepadRightShoulder"] = "<Gamepad>/rightShoulder",
	["Raw/GamepadLeftShoulder"] = "<Gamepad>/leftShoulder",
	["Raw/GamepadRightTrigger"] = "<Gamepad>/rightTrigger",
	["Raw/GamepadLeftTrigger"] = "<Gamepad>/leftTrigger",
	["Raw/GamepadRightStickPress"] = "<Gamepad>/rightStickPress",
	["Raw/GamepadLeftStickPress"] = "<Gamepad>/leftStickPress",
	["Raw/GamepadButtonNorth"] = "<Gamepad>/buttonNorth",
	["Raw/GamepadButtonWest"] = "<Gamepad>/buttonWest",
	["Raw/GamepadButtonEast"] = "<Gamepad>/buttonEast",
	["Raw/GamepadButtonSouth"] = "<Gamepad>/buttonSouth"
}

function ClientSettingUtils.getGamepadGenericPath(path)
	if not path or path == "" then
		return nil
	end

	local genericPath = ClientSettingUtils.gamepadGenericPathMap[path]

	if genericPath then
		return genericPath
	end

	local controlPath = string.match(path, "^<[^>]+>/(.+)$")

	if controlPath then
		return "<Gamepad>/" .. controlPath
	end

	return path
end

function ClientSettingUtils.getGamepadShowKeyDesc(actionName, replaceModel)
	local desc = replaceModel and replaceModel.getGamepadDesc and replaceModel:getGamepadDesc(actionName) or nil

	if desc and desc ~= "" then
		return desc
	end

	return ClientSettingUtils.gamepadShowKeyDescMap[actionName]
end

function ClientSettingUtils.getGamepadShowKeyText(actionName, replaceModel)
	local desc = ClientSettingUtils.getGamepadShowKeyDesc(actionName, replaceModel)

	if not desc then
		return nil
	end

	if type(desc) == "string" then
		return pg.getGameString(desc)
	end

	return pg.getLocalizationText(desc)
end

function ClientSettingUtils.getGamepadTextList(root)
	local objectReference = root:GetComponent("ObjectReference")
	local gamepadTextMap = {}
	local keySelectUText = objectReference:GetRefValue("keySelectUText")

	if keySelectUText then
		keySelectUText.gameObject:SetActiveEx(true)
	end

	gamepadTextMap["<Gamepad>/select"] = keySelectUText
	gamepadTextMap["<Gamepad>/leftTrigger"] = objectReference:GetRefValue("keyLTUText")
	gamepadTextMap["<Gamepad>/leftShoulder"] = objectReference:GetRefValue("keyLBUText")
	gamepadTextMap["<Gamepad>/leftStick"] = objectReference:GetRefValue("keyLUText")
	gamepadTextMap["<Gamepad>/leftStickPress"] = objectReference:GetRefValue("keyLSUText")
	gamepadTextMap["<Gamepad>/dpad/down"] = objectReference:GetRefValue("keyDownUText")
	gamepadTextMap["<Gamepad>/dpad/left"] = objectReference:GetRefValue("keyLeftUText")
	gamepadTextMap["<Gamepad>/dpad/right"] = objectReference:GetRefValue("keyRightUText")
	gamepadTextMap["<Gamepad>/dpad/up"] = objectReference:GetRefValue("keyUpUText")

	local keyStartUText = objectReference:GetRefValue("keyStartUText")

	if keyStartUText then
		keyStartUText.gameObject:SetActiveEx(true)
	end

	gamepadTextMap["<Gamepad>/start"] = keyStartUText
	gamepadTextMap["<Gamepad>/rightTrigger"] = objectReference:GetRefValue("keyRTUText")
	gamepadTextMap["<Gamepad>/rightShoulder"] = objectReference:GetRefValue("keyRBUText")
	gamepadTextMap["<Gamepad>/buttonNorth"] = objectReference:GetRefValue("keyYUText")
	gamepadTextMap["<Gamepad>/buttonEast"] = objectReference:GetRefValue("keyBUText")
	gamepadTextMap["<Gamepad>/buttonWest"] = objectReference:GetRefValue("keyXUText")
	gamepadTextMap["<Gamepad>/buttonSouth"] = objectReference:GetRefValue("keyAUText")
	gamepadTextMap["<Gamepad>/rightStick"] = objectReference:GetRefValue("keyRUText")
	gamepadTextMap["<Gamepad>/rightStickPress"] = objectReference:GetRefValue("keyRSUText")

	return gamepadTextMap
end

ClientSettingUtils.keyboardList = {
	{
		"escape",
		"empty",
		"f1",
		"f2",
		"f3",
		"f4",
		"empty",
		"f5",
		"f6",
		"f7",
		"f8",
		"empty",
		"f9",
		"f10",
		"f11",
		"f12"
	},
	{
		"backquote",
		"1",
		"2",
		"3",
		"4",
		"5",
		"6",
		"7",
		"8",
		"9",
		"0",
		"minus",
		"equals",
		"backspace"
	},
	{
		"tab",
		"q",
		"w",
		"e",
		"r",
		"t",
		"y",
		"u",
		"i",
		"o",
		"p",
		"leftBracket",
		"rightBracket",
		"backslash"
	},
	{
		"capsLock",
		"a",
		"s",
		"d",
		"f",
		"g",
		"h",
		"j",
		"k",
		"l",
		"semicolon",
		"quote",
		"enter"
	},
	{
		"leftShift",
		"z",
		"x",
		"c",
		"v",
		"b",
		"n",
		"m",
		"comma",
		"period",
		"slash",
		"rightShift"
	},
	{
		"ctrl",
		"win",
		"alt",
		"space",
		"rightAlt",
		"win",
		"contextMenu",
		"rightCtrl"
	},
	{
		"leftButton",
		"rightButton"
	}
}
ClientSettingUtils.key2Index = {
	empty = 1,
	capsLock = 1,
	backslash = 1,
	ctrl = 1,
	rightShift = 2,
	backspace = 1,
	space = 2,
	tab = 1,
	leftShift = 1,
	enter = 2,
	rightCtrl = 1
}
ClientSettingUtils.keyListColorSort = {
	Green = 2,
	Grey = 1,
	Yellow = 5,
	White = 4,
	Purple = 3
}
ClientSettingUtils.key2PosIndex = {}

function ClientSettingUtils.getKeyboardKeyList()
	local keyList = {}

	for i, keys in ipairs(ClientSettingUtils.keyboardList) do
		keyList[i] = {}

		for j, key in ipairs(keys) do
			local showKey = key == "backquote" and "~" or KeyboardLayoutAdapter.ToDisplayPath(key)

			keyList[i][j] = {
				isEmpty = true,
				tIndex = ClientSettingUtils.key2Index[key] or 0,
				key = showKey
			}
			ClientSettingUtils.key2PosIndex[key] = {
				x = i,
				y = j
			}
		end
	end

	local keyboardHotkeyData = pg.global.ui.settingKeyReplace.model:getKeyboardList()
	local allKeys = {}

	for _, keyData in ipairs(keyboardHotkeyData) do
		if keyData.tIndex == 1 then
			for _, keyInfo in ipairs(keyData.subItems) do
				local curPath = pg.game.input.keyboardHotkeyManager:GetActionPath(keyInfo.actionNames[1])

				if curPath ~= "" then
					local key = string.sub(curPath, 12)

					if curPath == "<Mouse>/rightButton" or curPath == "<Mouse>/leftButton" then
						key = string.sub(curPath, 9)
					end

					local posIndex = ClientSettingUtils.key2PosIndex[key]

					if posIndex then
						local curItem = keyList[posIndex.x][posIndex.y]

						curItem.isEmpty = false
						curItem.color = keyInfo.keycolor or "White"
						curItem.keyorder = keyInfo.keyorder or 999
						curItem.desc = keyInfo.label

						if posIndex.x < 7 then
							local curItem2 = Utils.deepCopyTable(curItem)

							curItem2.tIndex = 0

							table.insert(allKeys, curItem2)
						end
					end
				end
			end
		end
	end

	table.sort(allKeys, function(a, b)
		return a.keyorder < b.keyorder
	end)

	return keyList, allKeys
end

function ClientSettingUtils.openKeyReplace()
	pg.global.ui:open(UIConst.UI_ID_SETTING_KEY_REPLACE)
end

function ClientSettingUtils.tryAddOption(optionData, value)
	for _, option in ipairs(optionData) do
		if option.value == value then
			return
		end
	end

	if value == pg.game.setting:get4KResolutionValue() and (not pg.game.setting:checkSupport4K() or not pg.game.setting:checkShow4K()) then
		return
	end

	table.insert(optionData, 1, {
		tIndex = 0,
		value = value,
		label = value
	})
end

local FrameGenerationOptionMode = {
	Three = 3,
	Two = 2,
	None = 0,
	One = 1,
	Dynamic = 6,
	Five = 5,
	Four = 4
}

local function isDynamicFrameGenerationSupported()
	if CS.FunPlus.WorldX.Setting.VideoSetting.CheckDynamicFrameGenerationSupport == nil then
		return false
	end

	return CS.FunPlus.WorldX.Setting.VideoSetting.CheckDynamicFrameGenerationSupport()
end

function ClientSettingUtils.getOptionsData(data)
	local optionDataText = {}
	local widgetTxt = data.info.widgetTxt or {}

	for _, textId in ipairs(widgetTxt) do
		optionDataText[#optionDataText + 1] = pg.getLocalizationText(SettingSelectorText[textId].name)
	end

	local optionData = {}
	local widgetParam = data.info.widgetParam or {}

	for idx, value in ipairs(widgetParam) do
		local option = {
			tIndex = 0,
			value = value,
			label = optionDataText[idx] or value
		}

		if data.info.widgetImage then
			option.img = data.info.widgetImage[idx]
		end

		optionData[#optionData + 1] = option
	end

	if data.info.funcType == "setResolution" then
		local defaultResolution = pg.game.setting:getDefaultResolution()
		local curResolutionStr = pg.game.setting:getResolution()
		local resolution4KStr = pg.game.setting:get4KResolutionValue()

		ClientSettingUtils.tryAddOption(optionData, defaultResolution)
		ClientSettingUtils.tryAddOption(optionData, curResolutionStr)
		ClientSettingUtils.tryAddOption(optionData, resolution4KStr)
	end

	if ClientConfigCloudEnable == "true" and data.info.funcType == ClientConst.SettingFuncType.TargetFramerate then
		local insertIndex = #optionData + 1

		for idx, option in ipairs(optionData) do
			if option.value == 45 then
				insertIndex = nil

				break
			elseif type(option.value) == "number" and option.value > 45 then
				insertIndex = idx

				break
			end
		end

		if insertIndex then
			table.insert(optionData, insertIndex, {
				value = 45,
				tIndex = 0,
				label = 45
			})
		end
	end

	local qualityRecommend = pg.game.setting:getVideoQualityRecommend()

	if pg.game.setting:isMobileRenderPlatform() and data.info.funcType == ClientConst.SettingFuncType.TargetFramerate and qualityRecommend == Const.VIDEO_QUALITY.LOW then
		local removeIndex = -1

		for idx, option in ipairs(optionData) do
			if option.value == 60 then
				removeIndex = idx
			end
		end

		if removeIndex > 0 then
			table.remove(optionData, removeIndex)
		end
	end

	if data.info.funcType == "antialiasing" then
		local len = #optionData

		for i = len, 1, -1 do
			if optionData[i].value == "DeepLearningSuperSampling" and not CS.FunPlus.WorldX.Setting.VideoSetting.CheckDlssSupport() then
				table.remove(optionData, i)
			elseif optionData[i].value == "TAAU" and not CS.FunPlus.WorldX.Setting.VideoSetting.CheckTAAUSupport() then
				table.remove(optionData, i)
			elseif optionData[i].value == "FidelityFXSuperResolution" and not CS.FunPlus.WorldX.Setting.VideoSetting.CheckFSRSupport() then
				table.remove(optionData, i)
			end
		end
	end

	if data.info.funcType == "frameGeneration" then
		local len = #optionData
		local maxCount = CS.FunPlus.WorldX.Setting.VideoSetting.MaxFrameGenerationCount()
		local supportDynamic = isDynamicFrameGenerationSupported()

		for i = len, 1, -1 do
			local mode = FrameGenerationOptionMode[optionData[i].value]

			if mode == nil then
				table.remove(optionData, i)
			elseif mode == FrameGenerationOptionMode.Dynamic then
				if not supportDynamic then
					table.remove(optionData, i)
				end
			elseif maxCount < mode then
				table.remove(optionData, i)
			end
		end
	end

	return optionData, optionDataText
end

function ClientSettingUtils.getCurOptionsIndex(optionDatas, state)
	for idx, option in ipairs(optionDatas) do
		if option.value == state then
			return idx - 1
		end
	end

	return 0
end

local NO_FUNC_TYPE = {}
local settingFuncTypeIndex

local function getSettingFuncTypeIndex()
	if settingFuncTypeIndex then
		return settingFuncTypeIndex
	end

	local ids = {}

	for id in pairs(SettingFuncListData) do
		ids[#ids + 1] = id
	end

	table.sort(ids)

	settingFuncTypeIndex = {}

	for _, id in ipairs(ids) do
		local info = SettingFuncListData[id]
		local key = info.funcType

		if key == nil then
			key = NO_FUNC_TYPE
		end

		local list = settingFuncTypeIndex[key]

		if list == nil then
			list = {}
			settingFuncTypeIndex[key] = list
		end

		list[#list + 1] = info
	end

	return settingFuncTypeIndex
end

function ClientSettingUtils.getDefaultSettingValue(funcType, funcParam)
	local list = getSettingFuncTypeIndex()[funcType == nil and NO_FUNC_TYPE or funcType]

	if list == nil then
		return nil
	end

	local fallbackValue

	for i = 1, #list do
		local info = list[i]
		local funcParamEqual = funcParam == info.funcParam

		if funcParam and info.funcParam then
			funcParamEqual = funcParam[1] == info.funcParam[1]
		end

		if funcParamEqual then
			if ClientUtils.checkIsOpenToCurPlatform(info) then
				return info.widgetDefaultValue
			end

			if info.platform == nil and info.realPlatform == nil then
				fallbackValue = info.widgetDefaultValue
			end
		end
	end

	return fallbackValue
end

function ClientSettingUtils.get_showUI(optionDatas, param)
	local state

	if param[1] == ClientSettingUtils.showUIParam.Help then
		state = pg.game.setting:getGuideLabelState()
	elseif param[1] == ClientSettingUtils.showUIParam.Compass then
		state = pg.game.setting:getCompassState()
	end

	for index, option in ipairs(optionDatas) do
		if option.value == state then
			return index - 1
		end
	end

	return -1
end

function ClientSettingUtils.set_showUI(value, param)
	if param == nil then
		return
	end

	if param[1] == ClientSettingUtils.showUIParam.Help then
		pg.game.setting:setGuideLabelState(value)
	elseif param[1] == ClientSettingUtils.showUIParam.Compass then
		pg.game.setting:setCompassState(value)
	end
end

function ClientSettingUtils.get_mainVol()
	return pg.game.setting:getVolume(AudioConst.VolumeType.All)
end

function ClientSettingUtils.set_mainVol(volume)
	pg.game.setting:setVolume(AudioConst.VolumeType.All, volume)
end

function ClientSettingUtils.get_musicVol()
	return pg.game.setting:getVolume(AudioConst.VolumeType.BGM)
end

function ClientSettingUtils.set_musicVol(volume)
	pg.game.setting:setVolume(AudioConst.VolumeType.BGM, volume)
end

function ClientSettingUtils.get_soundVol()
	return pg.game.setting:getVolume(AudioConst.VolumeType.Sfx)
end

function ClientSettingUtils.set_soundVol(volume)
	pg.game.setting:setVolume(AudioConst.VolumeType.Sfx, volume)
end

function ClientSettingUtils.get_voiceVol()
	return pg.game.setting:getVolume(AudioConst.VolumeType.Vox)
end

function ClientSettingUtils.set_voiceVol(volume)
	pg.game.setting:setVolume(AudioConst.VolumeType.Vox, volume)
end

function ClientSettingUtils.get_language(optionDatas)
	local curValue = pg.languageType or 0

	for idx, option in ipairs(optionDatas) do
		if ClientConst.LANGUAGE_TYPE_MAP[option.value] == curValue then
			return idx - 1
		end
	end

	return -1
end

function ClientSettingUtils.set_language(language, isGM)
	pg.global.ui:closeAllUIPanel({
		[UIConst.UI_ID_TOPLOGO] = true
	}, true, true)
	pg.game.setting:setLanguage(language)

	if pg.me then
		pg.me:pullScrollingtext()
	end

	pg.global.ui.setting:refreshAllData()
	pg.global.ui.loadProgress:open()
	LuaUIUtils.onPlayerCreate()
	pg.global.ui.topLogo:open()

	if not isGM then
		local showFuncMenu, showESC = pg.global.ui.funMenuExit.model:checkShowFunc()

		if showFuncMenu then
			pg.global.ui.funcMenu:open()
		elseif showESC then
			local hudCtrl = pg.global.ui.hudV2

			if hudCtrl and hudCtrl.onQuitBtnClick then
				hudCtrl:onQuitBtnClick()
			end
		end

		pg.global.ui.setting:open()
	end

	pg.global.ui.blackChange:open()
	pg.global.ui.blackBg:open()
	pg.global.eventEmitter:emit(EventConst.ON_MAP_RELOADED, {})
	pg.global.eventEmitter:emit(EventConst.ON_LANGUAGE_CHANGED, {})
end

function ClientSettingUtils.get_audioLanguage(optionDatas)
	local curAudioLanguage = pg.game.audio:getLanguage()

	for idx, option in ipairs(optionDatas) do
		if option.value == curAudioLanguage then
			return idx - 1
		end
	end

	return -1
end

function ClientSettingUtils.set_audioLanguage(language)
	pg.game.audio:setLanguage(language)
end

function ClientSettingUtils.get_autoMute(optionDatas)
	local enabled = pg.game.setting:getBool(ClientConst.PrefKey.LoseFocusAudio, false)

	if optionDatas then
		return ClientSettingUtils.getCurOptionsIndex(optionDatas, enabled and 1 or 0)
	end

	return enabled
end

function ClientSettingUtils.set_autoMute(enable)
	enable = ToBool(enable)

	pg.game.setting:setBoolImmediately(ClientConst.PrefKey.LoseFocusAudio, enable)
	pg.game.audio:setLoseFocusAudio(enable)
end

function ClientSettingUtils.set_languageLogin(language)
	pg.global.ui:closeAllUIPanel({
		[UIConst.UI_ID_TOPLOGO] = true
	}, true, true)
	pg.game.setting:setLanguage(language)
	pg.global.ui.setting:refreshAllData()
	pg.global.ui.loadProgress:open()
	pg.global.ui.topLogo:open()
	pg.global.ui.login:open()
	pg.global.ui.tips:open()
	pg.global.ui.blackChange:open()
	pg.global.ui.blackBg:open()
end

function ClientSettingUtils.get_languageLogin(optionDatas)
	return ClientSettingUtils.get_language(optionDatas)
end

function ClientSettingUtils.setDefault_animationQuality()
	local defaultValue = pg.game.setting:getVideoSettingDefaultValue("animationQuality") or 2

	pg.game.setting:setAnimationQuality(defaultValue, true)
end

function ClientSettingUtils.get_animationQuality(optionDatas)
	local quality = pg.game.setting:getAnimationQuality()

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, quality)
end

function ClientSettingUtils.set_animationQuality(value)
	pg.game.setting:setAnimationQuality(value, true)
end

function ClientSettingUtils.apply_animationQuality(value)
	local platformConfig = AnimationQualityConfig[value]

	if platformConfig == nil then
		logger:error("animationQuality miss in value", value)

		return false
	end

	local platform = pg.game.setting.curPlatform
	local config = platformConfig[platform]

	if config == nil then
		config = platformConfig.Default
	end

	if config == nil then
		logger:error("animationQuality miss in platform", platform)

		return false
	end

	local mgr = appFacade and appFacade.animationManager

	if mgr == nil then
		return false
	end

	mgr:EnableLod(config[1], config[2], config[3], config[4], config[5])

	if config[1] then
		mgr:UpdateLodConfig(config[6], config[7], config[8], config[9], config[10], config[11])
	end

	if value == 1 then
		logger:info("set animation quality low")
		mgr:UpdateQualityParams(false, 3)
	elseif value == 2 then
		mgr:UpdateQualityParams(true, 6)
	else
		mgr:UpdateQualityParams(true, 8)
	end

	return true
end

function ClientSettingUtils.setDefault_setScreenMode()
	local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.SetScreenMode)

	pg.game.setting:setString(ClientConst.PrefKey.PcScreenMode, defaultValue)
	pg.game.setting:setResolution()
end

function ClientSettingUtils.get_setScreenMode(optionDatas)
	local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.SetScreenMode)
	local screenMode = pg.game.setting:getString(ClientConst.PrefKey.PcScreenMode, defaultValue)

	for idx, option in ipairs(optionDatas) do
		if option.value == screenMode then
			return idx - 1
		end
	end

	return -1
end

function ClientSettingUtils.set_setScreenMode(value)
	pg.game.setting:setString(ClientConst.PrefKey.PcScreenMode, value)
	pg.game.setting:setResolution()
end

function ClientSettingUtils.setDefault_setResolution()
	pg.game.setting:setString(ClientConst.PrefKey.PcResolution, pg.game.setting:getDefaultResolution())
	pg.game.setting:setResolution()
end

function ClientSettingUtils.get_setResolution(optionDatas)
	local resolutionStr = pg.game.setting:getResolution()

	for idx, option in ipairs(optionDatas) do
		if option.value == resolutionStr then
			return idx - 1
		end
	end

	return 0
end

function ClientSettingUtils.set_setResolution(value)
	if string.startsWith(value, tostring(Const.PC_4K_WIDTH)) then
		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("RESOLUTION_WARNING_TIP_4K"), function()
			pg.game.setting:setString(ClientConst.PrefKey.PcResolution, value)
			pg.game.setting:setResolution()
		end, false, function()
			if pg.global.ui:checkUIOpen(UIConst.UI_ID_SETTING) then
				pg.global.ui.setting:refreshSettingListNoData()
			end
		end)
	else
		pg.game.setting:setString(ClientConst.PrefKey.PcResolution, value)
		pg.game.setting:setResolution()
	end
end

function ClientSettingUtils.setDefault_resolutionScale()
	pg.game.setting:resetResolutionScale()
end

function ClientSettingUtils.get_resolutionScale(optionDatas)
	local defaultValue = pg.game.setting:getVideoSettingDefaultValue(ClientConst.PrefKey.ResolutionScale) or ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.ResolutionScale) or 1
	local scale = pg.game.setting:getResolutionScale(defaultValue)

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, scale)
end

function ClientSettingUtils.set_resolutionScale(value)
	pg.game.setting:setResolutionScale(value, true)
end

function ClientSettingUtils.get_autoLock(optionDatas)
	local state = pg.game.setting:getSkillAutoLock() and 1 or 0

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, state)
end

function ClientSettingUtils.set_autoLock(value)
	pg.game.setting:setSkillAutoLock(value == 1)
end

function ClientSettingUtils.get_attackForceLock(optionDatas)
	local state = pg.game.setting:getAttackForceLock() and 1 or 0

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, state)
end

function ClientSettingUtils.set_attackForceLock(value)
	pg.game.setting:setAttackForceLock(value)
end

function ClientSettingUtils.get_autoCast(optionDatas)
	local state = pg.game.setting:getAutoCast() and 1 or 0

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, state)
end

function ClientSettingUtils.set_autoCast(value)
	pg.game.setting:setAutoCast(value)
end

function ClientSettingUtils.get_closeProtagonistVoice(optionDatas)
	local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.ProtagonistVoice) or 0
	local state = pg.game.setting:getInt(ClientConst.PrefKey.ProtagonistVoice, defaultValue)

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, state)
end

function ClientSettingUtils.set_closeProtagonistVoice(value)
	pg.game.setting:setInt(ClientConst.PrefKey.ProtagonistVoice, value == 1 and 1 or 0)
end

function ClientSettingUtils.setDefault_closeProtagonistVoice()
	local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.ProtagonistVoice) or 0

	ClientSettingUtils.set_closeProtagonistVoice(defaultValue)
end

function ClientSettingUtils.get_mobileGamepadLayout(optionDatas)
	local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.MobileGamepadLayout) or 0
	local state = pg.game.setting:getInt(ClientConst.PrefKey.MobileGamepadLayout, defaultValue)

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, state)
end

function ClientSettingUtils.set_mobileGamepadLayout(value)
	local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.MobileGamepadLayout) or 0
	local oldValue = pg.game.setting:getInt(ClientConst.PrefKey.MobileGamepadLayout, defaultValue)

	local function applyValue()
		pg.game.setting:setInt(ClientConst.PrefKey.MobileGamepadLayout, value)
		pg.game.setting:save()

		if pg.game.input then
			pg.game.input:applyMobileGamepadLayoutSetting(value)
		end
	end

	if oldValue == value then
		applyValue()

		return
	end

	pg.global.showConfirmMsgRaw(nil, pg.getGameString("MOBILE_GAMEPAD_LAYOUT_SWITCH_CONFIRM"), function()
		applyValue()
		ClientUtils.backToHome()
	end, false, function()
		if pg.global.ui:checkUIOpen(UIConst.UI_ID_SETTING) then
			pg.global.ui.setting:refreshSettingListNoData()
		end
	end)
end

function ClientSettingUtils.setDefault_mobileGamepadLayout()
	ClientSettingUtils.set_mobileGamepadLayout(ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.MobileGamepadLayout) or 0)
end

function ClientSettingUtils.get_mobileJoystickMode(optionDatas)
	local state = pg.game.setting:getMobileJoystickMode()

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, state)
end

function ClientSettingUtils.set_mobileJoystickMode(value)
	pg.game.setting:setMobileJoystickMode(value)
end

function ClientSettingUtils.setDefault_mobileJoystickMode()
	local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.MobileJoystickMode) or ClientConst.MobileJoystickMode.Fixed

	ClientSettingUtils.set_mobileJoystickMode(defaultValue)
end

function ClientSettingUtils.getPhotoStorageMode()
	local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.PhotoStorageMode) or ClientConst.PhotoStorageMode.LocalAndCloud

	return pg.game.setting:getInt(ClientConst.PrefKey.PhotoStorageMode, defaultValue)
end

function ClientSettingUtils.isCloudGame()
	return ClientConfigCloudEnable == "true"
end

function ClientSettingUtils.getPhotoSyncingToPhoneText()
	return "正在保存到手机相册"
end

function ClientSettingUtils.shouldSavePhotoToLocal(storageMode)
	storageMode = storageMode or ClientSettingUtils.getPhotoStorageMode()

	return storageMode ~= ClientConst.PhotoStorageMode.Cloud
end

function ClientSettingUtils.shouldSavePhotoToCloud(storageMode)
	storageMode = storageMode or ClientSettingUtils.getPhotoStorageMode()

	return storageMode ~= ClientConst.PhotoStorageMode.Local
end

function ClientSettingUtils.getPhotoSaveSuccessText(storageMode, localPath)
	if ClientSettingUtils.isCloudGame() and storageMode ~= ClientConst.PhotoStorageMode.Cloud then
		if storageMode == ClientConst.PhotoStorageMode.LocalAndCloud then
			return "照片已保存到云端，正在保存到手机相册"
		end

		return ClientSettingUtils.getPhotoSyncingToPhoneText()
	else
		if storageMode == ClientConst.PhotoStorageMode.Cloud then
			return pg.getGameString("PHOTO_SAVE_TO_CLOUD")
		end

		if storageMode == ClientConst.PhotoStorageMode.LocalAndCloud then
			return string.format(pg.getGameString("PHOTO_SAVE_TO_LOCAL_AND_CLOUD"), localPath)
		end

		return string.format(pg.getGameString("PHOTO_SAVE_TO_LOCAL"), localPath)
	end
end

function ClientSettingUtils.getPhotoSaveFailureText(failureReason, localPath)
	if ClientSettingUtils.isCloudGame() and failureReason == "photo_upload_limit" and localPath and localPath ~= "" then
		return "云相册空间已满，正在保存到手机相册"
	else
		if failureReason ~= "photo_upload_limit" then
			return nil
		end

		if localPath and localPath ~= "" then
			return string.format(pg.getGameString("PHOTO_SAVE_LOCAL_CLOUD_CAPACITY_FULL"), localPath)
		end

		return pg.getGameString("PHOTO_ALBUM_CLOUD_CAPACITY_FULL")
	end
end

function ClientSettingUtils.get_photoStorageMode(optionDatas)
	return ClientSettingUtils.getCurOptionsIndex(optionDatas, ClientSettingUtils.getPhotoStorageMode())
end

function ClientSettingUtils.set_photoStorageMode(value)
	if value ~= ClientConst.PhotoStorageMode.Local and value ~= ClientConst.PhotoStorageMode.Cloud and value ~= ClientConst.PhotoStorageMode.LocalAndCloud then
		return
	end

	pg.game.setting:setInt(ClientConst.PrefKey.PhotoStorageMode, value)
end

function ClientSettingUtils.setDefault_photoStorageMode()
	local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.PhotoStorageMode) or ClientConst.PhotoStorageMode.LocalAndCloud

	ClientSettingUtils.set_photoStorageMode(defaultValue)
end

function ClientSettingUtils.set_aiHelperStrength(value)
	pg.game.setting:setAiHelperStrength(value)
end

function ClientSettingUtils.get_aiHelperStrength()
	return pg.game.setting:getAiHelperStrength()
end

function ClientSettingUtils.get_useExtendLockCamera(optionDatas)
	return ClientSettingUtils.getCurOptionsIndex(optionDatas, pg.game.setting:getLockCameraMode())
end

function ClientSettingUtils.set_useExtendLockCamera(value)
	pg.game.setting:setLockCameraMode(value)
end

function ClientSettingUtils.get_autoCameraWhenNoLock(optionDatas)
	local state = pg.game.setting:getAutoCameraWhenNoLock() and 1 or 0

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, state)
end

function ClientSettingUtils.set_autoCameraWhenNoLock(value)
	pg.game.setting:setAutoCameraWhenNoLock(ToBool(value))
end

function ClientSettingUtils.get_isForceLockTarget(optionDatas)
	local state = pg.game.controller.lockHelper.isUseLockOnCamera and 1 or 0

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, state)
end

function ClientSettingUtils.set_isForceLockTarget(value)
	pg.game.controller.lockHelper:setIsUseLockOnCamera(ToBool(value))
end

function ClientSettingUtils.get_aimSwitchMode()
	return pg.game.setting:getSkillAimSwitchMode() and 1 or 0
end

function ClientSettingUtils.set_aimSwitchMode(_, page)
	pg.game.setting:setSkillAimSwitchMode(not page == 0)
end

function ClientSettingUtils.setLightLv()
	pg.global.ui:open(UIConst.UI_ID_SETTING_OPERATION, {
		type = 0
	})
end

function ClientSettingUtils.setDefault_antialiasing()
	pg.game.setting:resetAntialiasingSetting()
end

function ClientSettingUtils.get_antialiasing(optionDatas)
	local antialiasing = pg.game.setting:getAntialiasing()

	for idx, option in ipairs(optionDatas) do
		if option.value == antialiasing then
			return idx - 1
		end
	end

	return -1
end

function ClientSettingUtils.set_antialiasing(value)
	pg.game.setting:setAntialiasing(value)
end

function ClientSettingUtils.setDefault_frameGeneration()
	pg.game.setting:resetFrameGenerationSetting()
end

function ClientSettingUtils.get_frameGeneration(optionDatas)
	local frameGeneration = pg.game.setting:getFrameGeneration()

	for idx, option in ipairs(optionDatas) do
		if option.value == frameGeneration then
			return idx - 1
		end
	end

	return -1
end

function ClientSettingUtils.set_frameGeneration(value)
	pg.game.setting:setFrameGeneration(value)
end

function ClientSettingUtils.setDefault_vSync()
	local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.VSync)

	pg.game.setting:setVSync(defaultValue)
end

function ClientSettingUtils.get_vSync(optionDatas)
	local state = pg.game.setting:getVSync()

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, state)
end

function ClientSettingUtils.set_vSync(value, funcParam, isPlayerOperation)
	if isPlayerOperation then
		pg.game.setting:markCloudGamePerformanceSettingUserModified(ClientConst.SettingFuncType.VSync)
	end

	pg.game.setting:setVSync(value, isPlayerOperation)
end

function ClientSettingUtils.setDefault_preset()
	local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.Preset)

	pg.game.setting:setPreset(defaultValue)
end

function ClientSettingUtils.get_preset(optionDatas)
	local state = pg.game.setting:getPreset()

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, state)
end

function ClientSettingUtils.set_preset(value)
	pg.game.setting:setPreset(value)
end

ClientSettingUtils.RatioMap = {
	[0] = 0,
	0.4,
	1,
	1.2,
	1.4
}

function ClientSettingUtils.sliderStep_rumbleRatio()
	return 1
end

function ClientSettingUtils.get_rumbleRatio()
	local rumbleRatio = pg.game.input:getRumbleRatio()

	for key, value in pairs(ClientSettingUtils.RatioMap) do
		if value == rumbleRatio then
			return key
		end
	end

	return 2
end

function ClientSettingUtils.set_rumbleRatio(value)
	pg.game.input:setRumbleRatio(ClientSettingUtils.RatioMap[value] or 1)
end

function ClientSettingUtils.sliderStep_gyroscopeRatio()
	return 1
end

function ClientSettingUtils.get_gyroscopeRatio()
	local GyroscopeRatio = pg.game.input:getGyroscopeRatio()

	for key, value in pairs(ClientSettingUtils.RatioMap) do
		if value == GyroscopeRatio then
			return key
		end
	end

	return 2
end

function ClientSettingUtils.set_gyroscopeRatio(value)
	pg.game.input:setGyroscopeRatio(ClientSettingUtils.RatioMap[value] or 1)
end

function ClientSettingUtils.set_gamepadCursorSpeed(value)
	local cursorSpeed = ClientConst.GAMEPAD_CURSOR_SPEED_LEVEL[value]

	if cursorSpeed == nil then
		return
	end

	pg.game.setting:setGamepadCursorSpeed(value)
	pg.game.input:setVirtualMouseCursorSpeed(cursorSpeed)
end

function ClientSettingUtils.sliderStep_gamepadCursorSpeed()
	return 1
end

function ClientSettingUtils.get_gamepadCursorSpeed()
	return pg.game.setting:getGamepadCursorSpeed()
end

function ClientSettingUtils.get_holdToEnterCatchMode(optionDatas)
	local state = pg.game.setting:getHoldToEnterCatchMode() and 1 or 0

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, state)
end

function ClientSettingUtils.holdToEnterCatchMode(value)
	pg.game.setting:setHoldToEnterCatchMode(value)
end

function ClientSettingUtils.get_invertHorizontalLook(optionDatas)
	local state = pg.game.setting:getInvertHorizontalLook() and 1 or 0

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, state)
end

function ClientSettingUtils.set_invertHorizontalLook(value)
	pg.game.setting:setInvertHorizontalLook(value)
	pg.game.input:setInvertHorizontalLook(value)
end

function ClientSettingUtils.get_invertVerticalLook(optionDatas)
	local state = pg.game.setting:getInvertVerticalLook() and 1 or 0

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, state)
end

function ClientSettingUtils.set_invertVerticalLook(value)
	pg.game.setting:setInvertVerticalLook(value)
	pg.game.input:setInvertVerticalLook(value)
end

function ClientSettingUtils.get_invertHorizontalLookMouse(optionDatas)
	local state = pg.game.setting:getInvertHorizontalLookMouse() and 1 or 0

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, state)
end

function ClientSettingUtils.set_invertHorizontalLookMouse(value)
	pg.game.setting:setInvertHorizontalLookMouse(value)
	pg.game.input:setInvertHorizontalLookMouse(value)
end

function ClientSettingUtils.get_invertVerticalLookMouse(optionDatas)
	local state = pg.game.setting:getInvertVerticalLookMouse() and 1 or 0

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, state)
end

function ClientSettingUtils.set_invertVerticalLookMouse(value)
	pg.game.setting:setInvertVerticalLookMouse(value)
	pg.game.input:setInvertVerticalLookMouse(value)
end

function ClientSettingUtils.set_gamepadLeftStickDeadzone(value)
	pg.game.setting:setGamepadLeftStickDeadzone(value)
	pg.game.input:setGamepadLeftStickDeadzone(value)
end

function ClientSettingUtils.sliderStep_gamepadLeftStickDeadzone()
	return 1
end

function ClientSettingUtils.get_gamepadLeftStickDeadzone()
	return pg.game.setting:getGamepadLeftStickDeadzone()
end

function ClientSettingUtils.set_gamepadRightStickDeadzone(value)
	pg.game.setting:setGamepadRightStickDeadzone(value)
	pg.game.input:setGamepadRightStickDeadzone(value)
end

function ClientSettingUtils.sliderStep_gamepadRightStickDeadzone()
	return 1
end

function ClientSettingUtils.get_gamepadRightStickDeadzone()
	return pg.game.setting:getGamepadRightStickDeadzone()
end

function ClientSettingUtils.sliderStep_playerCountLimit()
	return 1
end

function ClientSettingUtils.sliderStep_puppetCountLimit()
	return 1
end

function ClientSettingUtils.sliderStep_petCountLimit()
	return 1
end

function ClientSettingUtils.sliderStep_envObjCountLimit()
	return 1
end

function ClientSettingUtils.get_puppetCountLimit()
	return pg.game.setting:getEntityCount(SettingConst.EntityCountLimitType.ClientPuppet)
end

function ClientSettingUtils.set_puppetCountLimit(value)
	pg.game.setting:setEntityCount(SettingConst.EntityCountLimitType.ClientPuppet, value)
end

function ClientSettingUtils.get_petCountLimit()
	return pg.game.setting:getEntityCount(SettingConst.EntityCountLimitType.ClientPet)
end

function ClientSettingUtils.set_petCountLimit(value)
	pg.game.setting:setEntityCount(SettingConst.EntityCountLimitType.ClientPet, value)
end

function ClientSettingUtils.get_playerCountLimit()
	return pg.game.setting:getEntityCount(SettingConst.EntityCountLimitType.ClientPlayer)
end

function ClientSettingUtils.set_playerCountLimit(value)
	pg.game.setting:setEntityCount(SettingConst.EntityCountLimitType.ClientPlayer, value)
end

function ClientSettingUtils.get_envObjCountLimit()
	return pg.game.setting:getEntityCount(SettingConst.EntityCountLimitType.ClientEnvObject)
end

function ClientSettingUtils.set_envObjCountLimit(value)
	pg.game.setting:setEntityCount(SettingConst.EntityCountLimitType.ClientEnvObject, value)
end

function ClientSettingUtils.get_targetFramerate(optionDatas)
	local value = pg.game.setting:getTargetFramerate()

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, value)
end

function ClientSettingUtils.set_targetFramerate(value, funcParam, isPlayerOperation)
	local operationUIDKey = isPlayerOperation and pg.game.setting:getUIDKey() or nil

	local function applyTargetFramerate()
		if operationUIDKey and operationUIDKey ~= pg.game.setting:getUIDKey() then
			return
		end

		if isPlayerOperation then
			pg.game.setting:markCloudGamePerformanceSettingUserModified(ClientConst.SettingFuncType.TargetFramerate)
		end

		pg.game.setting:setTargetFramerate(value, isPlayerOperation)
	end

	if pg.game.setting:isMobileRenderPlatform() and value >= 60 then
		pg.global.showConfirmMsgRaw(pg.getGameString("HIGH_TARGET_FRAMERATE_WARNING_TITLE"), pg.getGameString("HIGH_TARGET_FRAMERATE_WARNING_TIP"), function()
			applyTargetFramerate()
		end, false, function()
			if pg.global.ui:checkUIOpen(UIConst.UI_ID_SETTING) then
				pg.global.ui.setting:refreshSettingListNoData()
			end
		end)

		return
	end

	return applyTargetFramerate()
end

function ClientSettingUtils.set_autoEnterTeamSpeech(value)
	pg.game.setting:setTeamSpeechAutoEnter(value == 1)
end

function ClientSettingUtils.get_autoEnterTeamSpeech(optionDatas)
	local state = pg.game.setting:getTeamSpeechAutoEnter() and 1 or 0

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, state)
end

function ClientSettingUtils.set_teamSpeechSpeakType(value)
	pg.game.setting:setTeamSpeechFreeTalk(value == 1)
end

function ClientSettingUtils.get_teamSpeechSpeakType(optionDatas)
	local state = pg.game.setting:getTeamSpeechFreeTalk() and 1 or 0

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, state)
end

function ClientSettingUtils.set_speechInput()
	return
end

function ClientSettingUtils.get_speechInput()
	return
end

function ClientSettingUtils.set_speechOutput()
	return
end

function ClientSettingUtils.get_speechOutput()
	return
end

function ClientSettingUtils.set_micVol(volume)
	pg.game.setting:setMicVol(volume)
end

function ClientSettingUtils.get_micVol()
	return pg.game.setting:getMicVol()
end

function ClientSettingUtils.set_teamVol(volume)
	pg.game.setting:setTeamVol(volume)
end

function ClientSettingUtils.get_teamVol()
	return pg.game.setting:getTeamVol()
end

function ClientSettingUtils.get_commonVideoSettingBool(optionDatas, funcParam)
	local key = funcParam and funcParam[1]
	local state

	if key == LARGE_SCREEN_MODE_KEY then
		state = pg.game.setting:getLargeScreenMode()
	else
		state = pg.game.setting:getCommonVideoSettingValue(key)
	end

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, state and 1 or 0)
end

function ClientSettingUtils.set_commonVideoSettingBool(value, funcParam)
	local key = funcParam and funcParam[1]

	if key == LARGE_SCREEN_MODE_KEY then
		pg.game.setting:setLargeScreenMode(value == 1, true)

		return
	end

	pg.game.setting:setCommonVideoSettingValue(key, value == 1)
end

function ClientSettingUtils.get_commonVideoSettingInt(optionDatas, funcParam)
	if optionDatas then
		local state = pg.game.setting:getCommonVideoSettingValue(funcParam[1])

		return ClientSettingUtils.getCurOptionsIndex(optionDatas, state)
	end

	return pg.game.setting:getCommonVideoSettingValue(funcParam[1])
end

function ClientSettingUtils.set_commonVideoSettingInt(value, funcParam)
	pg.game.setting:setCommonVideoSettingValue(funcParam[1], math.floor(value + 0.5))
end

function ClientSettingUtils.get_commonVideoSettingFloat(optionDatas, funcParam)
	return pg.game.setting:getCommonVideoSettingValue(funcParam[1])
end

function ClientSettingUtils.set_commonVideoSettingFloat(value, funcParam)
	pg.game.setting:setCommonVideoSettingValue(funcParam[1], value)
end

function ClientSettingUtils.get_commonVideoSettingEnum(optionDatas, funcParam)
	local state = pg.game.setting:getCommonVideoSettingValue(funcParam[1])

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, state)
end

function ClientSettingUtils.set_commonVideoSettingEnum(value, funcParam)
	pg.game.setting:setCommonVideoSettingValue(funcParam[1], value)
end

local function setDefaultCommonVideoSetting(funcParam)
	local key = funcParam and funcParam[1]

	if not key then
		return
	end

	if key == ClientConst.PrefKey.ResolutionScale then
		pg.game.setting:resetResolutionScale()

		return
	end

	if key == LARGE_SCREEN_MODE_KEY then
		pg.game.setting:resetLargeScreenMode()

		return
	end

	local defaultValue = pg.game.setting:getVideoSettingDefaultValue(key)

	if defaultValue ~= nil then
		pg.game.setting:setCommonVideoSettingValue(key, defaultValue)
	end
end

ClientSettingUtils.setDefault_commonVideoSettingBool = setDefaultCommonVideoSetting
ClientSettingUtils.setDefault_commonVideoSettingInt = setDefaultCommonVideoSetting
ClientSettingUtils.setDefault_commonVideoSettingFloat = setDefaultCommonVideoSetting
ClientSettingUtils.setDefault_commonVideoSettingEnum = setDefaultCommonVideoSetting

function ClientSettingUtils.setDefault_setVideoQuality()
	pg.game.setting:getVideoLevelFromServer(false, true)
end

function ClientSettingUtils.get_setVideoQuality(optionDatas)
	local state = pg.game.setting:getVideoQuality()

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, state)
end

function ClientSettingUtils.set_setVideoQuality(value, funcParam)
	pg.game.setting:setVideoQuality(value)
end

function ClientSettingUtils.check_dlssModeInt()
	return pg.game.setting:getAntialiasing() == "DeepLearningSuperSampling"
end

function ClientSettingUtils.sliderStep_cameraRotateRate(info)
	return 1
end

function ClientSettingUtils.get_cameraRotateRate()
	local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.CameraRotateRate)

	return pg.game.setting:getInt(ClientConst.PrefKey.CameraRotateRate, defaultValue)
end

function ClientSettingUtils.setDefault_cameraRotateRate()
	local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.CameraRotateRate)

	ClientSettingUtils.set_cameraRotateRate(defaultValue)
end

function ClientSettingUtils.set_cameraRotateRate(value)
	pg.game.setting:setInt(ClientConst.PrefKey.CameraRotateRate, value)
	pg.game.camera.playerCameraMode:resetRotateSpeed()
end

function ClientSettingUtils.sliderStep_catchCameraYawRotateRate()
	return 1
end

function ClientSettingUtils.get_catchCameraYawRotateRate()
	local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.CatchCameraYawRotateRate)

	return pg.game.setting:getInt(ClientConst.PrefKey.CatchCameraYawRotateRate, defaultValue)
end

function ClientSettingUtils.setDefault_catchCameraYawRotateRate()
	local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.CatchCameraYawRotateRate)

	ClientSettingUtils.set_catchCameraYawRotateRate(defaultValue)
end

function ClientSettingUtils.set_catchCameraYawRotateRate(value)
	pg.game.setting:setInt(ClientConst.PrefKey.CatchCameraYawRotateRate, value)

	local playerCameraMode = pg.game.camera and pg.game.camera.playerCameraMode

	if playerCameraMode and playerCameraMode.catchCamera then
		playerCameraMode.catchCamera:resetRotateSpeed()
	end
end

function ClientSettingUtils.sliderStep_catchCameraPitchRotateRate()
	return 1
end

function ClientSettingUtils.get_catchCameraPitchRotateRate()
	local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.CatchCameraPitchRotateRate)

	return pg.game.setting:getInt(ClientConst.PrefKey.CatchCameraPitchRotateRate, defaultValue)
end

function ClientSettingUtils.setDefault_catchCameraPitchRotateRate()
	local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.CatchCameraPitchRotateRate)

	ClientSettingUtils.set_catchCameraPitchRotateRate(defaultValue)
end

function ClientSettingUtils.set_catchCameraPitchRotateRate(value)
	pg.game.setting:setInt(ClientConst.PrefKey.CatchCameraPitchRotateRate, value)

	local playerCameraMode = pg.game.camera and pg.game.camera.playerCameraMode

	if playerCameraMode and playerCameraMode.catchCamera then
		playerCameraMode.catchCamera:resetRotateSpeed()
	end
end

local WORLD_CAMERA_COLOR_GRADING_RATE = 0.01
local WORLD_CAMERA_COLOR_GRADING_MIN = -100
local WORLD_CAMERA_COLOR_GRADING_MAX = 100

local function getWorldCameraColorGradingValue(funcType, prefKey)
	local defaultValue = ClientSettingUtils.getDefaultSettingValue(funcType) or 0

	return pg.game.setting:getInt(prefKey, defaultValue)
end

local function setWorldCameraColorGradingValue(prefKey, value)
	value = math.clamp(tonumber(value) or 0, WORLD_CAMERA_COLOR_GRADING_MIN, WORLD_CAMERA_COLOR_GRADING_MAX)

	pg.game.setting:setInt(prefKey, value)
	ClientSettingUtils.applyWorldCameraColorGrading()
end

function ClientSettingUtils.applyWorldCameraColorGrading()
	local saturation = ClientSettingUtils.get_worldCameraSaturation() * WORLD_CAMERA_COLOR_GRADING_RATE
	local brightness = ClientSettingUtils.get_worldCameraBrightness() * WORLD_CAMERA_COLOR_GRADING_RATE
	local contrast = ClientSettingUtils.get_worldCameraContrast() * WORLD_CAMERA_COLOR_GRADING_RATE

	pg.global.cameraMgr:SetWorldCameraColorGrading(saturation, brightness, contrast)
end

function ClientSettingUtils.get_worldCameraSaturation()
	return getWorldCameraColorGradingValue(ClientConst.SettingFuncType.WorldCameraSaturation, ClientConst.PrefKey.WorldCameraSaturation)
end

function ClientSettingUtils.set_worldCameraSaturation(value)
	setWorldCameraColorGradingValue(ClientConst.PrefKey.WorldCameraSaturation, value)
end

function ClientSettingUtils.setDefault_worldCameraSaturation()
	ClientSettingUtils.set_worldCameraSaturation(ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.WorldCameraSaturation) or 0)
end

function ClientSettingUtils.get_worldCameraBrightness()
	return getWorldCameraColorGradingValue(ClientConst.SettingFuncType.WorldCameraBrightness, ClientConst.PrefKey.WorldCameraBrightness)
end

function ClientSettingUtils.set_worldCameraBrightness(value)
	setWorldCameraColorGradingValue(ClientConst.PrefKey.WorldCameraBrightness, value)
end

function ClientSettingUtils.setDefault_worldCameraBrightness()
	ClientSettingUtils.set_worldCameraBrightness(ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.WorldCameraBrightness) or 0)
end

function ClientSettingUtils.get_worldCameraContrast()
	return getWorldCameraColorGradingValue(ClientConst.SettingFuncType.WorldCameraContrast, ClientConst.PrefKey.WorldCameraContrast)
end

function ClientSettingUtils.set_worldCameraContrast(value)
	setWorldCameraColorGradingValue(ClientConst.PrefKey.WorldCameraContrast, value)
end

function ClientSettingUtils.setDefault_worldCameraContrast()
	ClientSettingUtils.set_worldCameraContrast(ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.WorldCameraContrast) or 0)
end

function ClientSettingUtils.getInfoStampOwnVisibilityValue()
	if pg.game and pg.game.markShare and pg.game.markShare.pendingMediaMarkerViewSetting ~= nil then
		return pg.game.markShare.pendingMediaMarkerViewSetting
	end

	if pg.me and pg.me.mediaMarkerViewSetting ~= nil then
		return pg.me.mediaMarkerViewSetting
	end

	local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.InfoStampOwnVisibility) or Const.MARKER_SETTINGS.DEFAULT

	return defaultValue
end

function ClientSettingUtils.get_infoStampOwnVisibility(optionDatas)
	return ClientSettingUtils.getCurOptionsIndex(optionDatas, ClientSettingUtils.getInfoStampOwnVisibilityValue())
end

function ClientSettingUtils.set_infoStampOwnVisibility(value)
	if pg.game and pg.game.markShare then
		pg.game.markShare:markMediaMarkerViewSettingDirty(value)
	end
end

function ClientSettingUtils.setDefault_infoStampOwnVisibility()
	local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.InfoStampOwnVisibility) or Const.MARKER_SETTINGS.DEFAULT

	ClientSettingUtils.set_infoStampOwnVisibility(defaultValue)
end

function ClientSettingUtils.getInfoStampSystemVisibleValue()
	local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.InfoStampSystemVisible) or 0

	return pg.game.setting:getInt(ClientConst.PrefKey.InfoStampSystemVisible, defaultValue)
end

function ClientSettingUtils.get_infoStampSystemVisible(optionDatas)
	return ClientSettingUtils.getCurOptionsIndex(optionDatas, ClientSettingUtils.getInfoStampSystemVisibleValue())
end

function ClientSettingUtils.set_infoStampSystemVisible(value)
	pg.game.setting:setInt(ClientConst.PrefKey.InfoStampSystemVisible, value)

	if pg.game and pg.game.markShare then
		pg.game.markShare:markSettingDirty()
	end
end

function ClientSettingUtils.setDefault_infoStampSystemVisible()
	local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.InfoStampSystemVisible)

	ClientSettingUtils.set_infoStampSystemVisible(defaultValue)
end

function ClientSettingUtils.sliderStep_infoStampFriendCount()
	return 1
end

function ClientSettingUtils.get_infoStampFriendCount()
	local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.InfoStampFriendCount) or 60

	return pg.game.setting:getInt(ClientConst.PrefKey.InfoStampFriendCount, defaultValue)
end

function ClientSettingUtils.set_infoStampFriendCount(value)
	pg.game.setting:setInt(ClientConst.PrefKey.InfoStampFriendCount, value)

	if pg.game and pg.game.markShare then
		pg.game.markShare:markSettingDirty()
	end
end

function ClientSettingUtils.setDefault_infoStampFriendCount()
	local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.InfoStampFriendCount)

	ClientSettingUtils.set_infoStampFriendCount(defaultValue)
end

function ClientSettingUtils.sliderStep_infoStampStrangerCount()
	return 1
end

function ClientSettingUtils.get_infoStampStrangerCount()
	local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.InfoStampStrangerCount) or 10

	return pg.game.setting:getInt(ClientConst.PrefKey.InfoStampStrangerCount, defaultValue)
end

function ClientSettingUtils.set_infoStampStrangerCount(value)
	pg.game.setting:setInt(ClientConst.PrefKey.InfoStampStrangerCount, value)

	if pg.game and pg.game.markShare then
		pg.game.markShare:markSettingDirty()
	end
end

function ClientSettingUtils.setDefault_infoStampStrangerCount()
	local defaultValue = ClientSettingUtils.getDefaultSettingValue(ClientConst.SettingFuncType.InfoStampStrangerCount)

	ClientSettingUtils.set_infoStampStrangerCount(defaultValue)
end

function ClientSettingUtils.sliderStep_catchAbsorbSpeed_mouseKeyBoard()
	return 1
end

function ClientSettingUtils.get_catchAbsorbSpeed_mouseKeyBoard(optionDatas, funcParam)
	return pg.game.setting:getCatchAbsorbSpeed("mouseKeyBoard")
end

function ClientSettingUtils.set_catchAbsorbSpeed_mouseKeyBoard(value)
	pg.game.setting:setCatchAbsorbSpeed(value, "mouseKeyBoard")
end

function ClientSettingUtils.sliderStep_catchDampingRate_mouseKeyBoard()
	return 1
end

function ClientSettingUtils.get_catchDampingRate_mouseKeyBoard(optionDatas, funcParam)
	return pg.game.setting:getCatchDampingRate("mouseKeyBoard")
end

function ClientSettingUtils.set_catchDampingRate_mouseKeyBoard(value)
	pg.game.setting:setCatchDampingRate(value, "mouseKeyBoard")
end

function ClientSettingUtils.sliderStep_catchAbsorbSpeed_gamePad()
	return 1
end

function ClientSettingUtils.get_catchAbsorbSpeed_gamePad(optionDatas, funcParam)
	return pg.game.setting:getCatchAbsorbSpeed("gamePad")
end

function ClientSettingUtils.set_catchAbsorbSpeed_gamePad(value)
	pg.game.setting:setCatchAbsorbSpeed(value, "gamePad")
end

function ClientSettingUtils.sliderStep_catchDampingRate_gamePad()
	return 1
end

function ClientSettingUtils.get_catchDampingRate_gamePad(optionDatas, funcParam)
	return pg.game.setting:getCatchDampingRate("gamePad")
end

function ClientSettingUtils.set_catchDampingRate_gamePad(value)
	pg.game.setting:setCatchDampingRate(value, "gamePad")
end

function ClientSettingUtils.sliderStep_catchAbsorbSpeed_mobile()
	return 1
end

function ClientSettingUtils.get_catchAbsorbSpeed_mobile(optionDatas, funcParam)
	return pg.game.setting:getCatchAbsorbSpeed("mobile")
end

function ClientSettingUtils.set_catchAbsorbSpeed_mobile(value)
	pg.game.setting:setCatchAbsorbSpeed(value, "mobile")
end

function ClientSettingUtils.sliderStep_catchDampingRate_mobile()
	return 1
end

function ClientSettingUtils.get_catchDampingRate_mobile(optionDatas, funcParam)
	return pg.game.setting:getCatchDampingRate("mobile")
end

function ClientSettingUtils.set_catchDampingRate_mobile(value)
	pg.game.setting:setCatchDampingRate(value, "mobile")
end

function ClientSettingUtils.escape()
	ClientUtils.escape()
end

function ClientSettingUtils.reportProcessStuckDebug()
	pg.global.showConfirmMsgRaw(nil, pg.getGameString("DEADLOCK_REPORT_TIP"), function()
		local player = pg.me

		if player then
			player:reportProcessStuckDebug()
		end
	end, false, nil)
end

function ClientSettingUtils.set_resourceQuality(value, funcParam)
	pg.global.showConfirmMsgRaw(pg.getGameString("SWITCH_RESOURCE_QUALITY_TITLE"), pg.getGameString("SWITCH_RESOURCE_QUALITY_DESC"), function()
		ClientUtils.backToHome()
		pg.game.setting:setResourceQuality(value)
	end, nil)
end

function ClientSettingUtils.get_resourceQuality(optionDatas)
	local state = pg.game.setting:getResourceQuality()

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, state)
end

function ClientSettingUtils.handlePackItemClick(data)
	if pg.game.resourceDownload then
		pg.game.resourceDownload:requestDownloadPack(data)
	end
end

function ClientSettingUtils.get_isEnableManualClickForceLockEnemy(optionDatas)
	local state = pg.game.controller.lockHelper.isEnableManualClickForceLockEnemy and 1 or 0

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, state)
end

function ClientSettingUtils.set_isEnableManualClickForceLockEnemy(value)
	pg.game.controller.lockHelper:setIsEnableManualClickForceLockEnemy(ToBool(value))
end

function ClientSettingUtils.openExchangeCodeUI()
	pg.global.ui:open(UIConst.UI_ID_COMMON_TIP_INPUT, {
		title = "EXCHANGE_CODE_TITLE",
		cb = function(code)
			pg.me:reqExchangeCode(code)

			return true
		end,
		extraConfig = {
			confirmBtnText = "EXCHANGE_CODE_CONFIRM",
			noSensitiveWordsCheck = true,
			placeHolderUText = "EXCHANGE_CODE_INPUT",
			characterLimit = 0,
			hideInputTitle = true
		}
	})
end

function ClientSettingUtils.openUUNetwork()
	local UUBoosterManager = CS.FunPlus.WorldX.SDK.UU.UUBoosterManager

	if not UUBoosterManager then
		logger.error("UUBoosterManager class not found")
	end

	if not UUBoosterManager.OpenUU then
		logger.error("UUBoosterManager.OpenUU method not found")
	end

	UUBoosterManager.OpenUU()
end

function ClientSettingUtils.get_isShowResist(optionDatas)
	local state = pg.game.setting:getIsShowResist() and 1 or 0

	return ClientSettingUtils.getCurOptionsIndex(optionDatas, state)
end

function ClientSettingUtils.set_isShowResist(value)
	local value = ToBool(value) and 1 or 0

	pg.game.setting:setIsShowResist(value)
end

function ClientSettingUtils.openPrivacyPolicy()
	logger:info("ClientSettingUtils.openPrivacyPolicy")

	if not pg.global.platform:isPS() then
		-- block empty
	end

	PlatformBridgeLuaFacade.OpenUrlPredeterminedContent("https://pawprintstudio.com/privacy-policy/en")

	if false then
		pg.global.sdkManager:openUrl("ClientSettingUtils", "openPrivacyPolicy", "https://pawprintstudio.com/privacy-policy/en")
	end
end

function ClientSettingUtils.opentermsofService()
	logger:info("ClientSettingUtils.opentermsofService")

	if pg.global.platform:isPS() then
		PlatformBridgeLuaFacade.OpenUrlPredeterminedContent("https://pawprintstudio.com/terms-of-use")
	else
		pg.global.sdkManager:openUrl("ClientSettingUtils", "opentermsofService", "https://pawprintstudio.com/terms-of-use")
	end
end

function ClientSettingUtils.openFunTapCall()
	pg.global.sdkManager:funtapCallB()
end

function ClientSettingUtils.get_bloodType()
	local state = pg.game.setting:getBloodType()

	return state
end

function ClientSettingUtils.set_bloodType(value)
	value = ToBool(value) and 1 or 0

	local oldValue = pg.game.setting:getBloodType()

	pg.game.setting:setBloodType(value)

	if oldValue ~= value then
		pg.global.eventEmitter:emit(EventConst.SETTING_BLOOD_TYPE_CHANGED, value)
	end
end

local FOCUS_TARGET_LINE_SETTING_DEFAULT_VALUE = 0

function ClientSettingUtils.isFocusTargetLineOpenEnabled()
	return pg.game.setting:getInt(ClientConst.PrefKey.FocusTargetLineOpen, FOCUS_TARGET_LINE_SETTING_DEFAULT_VALUE) == 1
end

function ClientSettingUtils.get_focusTargetLineOpen(optionDatas)
	return ClientSettingUtils.getCurOptionsIndex(optionDatas, pg.game.setting:getInt(ClientConst.PrefKey.FocusTargetLineOpen, FOCUS_TARGET_LINE_SETTING_DEFAULT_VALUE))
end

function ClientSettingUtils.set_focusTargetLineOpen(value)
	pg.game.setting:setInt(ClientConst.PrefKey.FocusTargetLineOpen, value == 1 and 1 or 0)
end

function ClientSettingUtils.setDefault_focusTargetLineOpen()
	ClientSettingUtils.set_focusTargetLineOpen(FOCUS_TARGET_LINE_SETTING_DEFAULT_VALUE)
end

return ClientSettingUtils
