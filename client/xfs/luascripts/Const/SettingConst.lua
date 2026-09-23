-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Const\\SettingConst.lua

local SettingConst = {
	EDeviceProfileType = {
		AndroidMid = "AndroidMid",
		AndroidHigh = "AndroidHigh",
		AndroidDefault = "AndroidDefault",
		IOSLow = "IOSLow",
		IOSMid = "IOSMid",
		IOSHight = "IOSHight",
		IOSDefault = "IOSDefault",
		WindowsLow = "WindowsLow",
		WindowsMid = "WindowsMid",
		WindowsHigh = "WindowsHigh",
		WindowsDefault = "WindowsDefault",
		EditorMac = "EditorMac",
		EditorWindows = "EditorWindows",
		Default = "Default",
		PlayStation5 = "PlayStation5",
		PlayStation4 = "PlayStation4",
		PlayStationDefault = "PlayStationDefault",
		AndoridLow = "AndoridLow"
	},
	EntityCountLimitLow = {
		ClientPlayer = 15,
		ClientEnvObject = 50,
		ClientPuppet = 15,
		ClientPet = 15
	},
	EntityCountLimitMiddle = {
		ClientPlayer = 50,
		ClientEnvObject = 100,
		ClientPuppet = 50,
		ClientPet = 50
	},
	EntityCountLimitHigh = {
		ClientPlayer = 100,
		ClientEnvObject = 200,
		ClientPuppet = 100,
		ClientPet = 100
	},
	EntityCountLimitType = {
		ClientPlayer = "ClientPlayer",
		ClientEnvObject = "ClientEnvObject",
		ClientPuppet = "ClientPuppet",
		ClientPet = "ClientPet"
	}
}

SettingConst.EntityCountLimitLevel = {
	SettingConst.EntityCountLimitLow,
	SettingConst.EntityCountLimitMiddle,
	SettingConst.EntityCountLimitHigh
}

return SettingConst
