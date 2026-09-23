-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\ReloadFilter.lua

local ReloadFilter = {
	ignoreModules = {
		"Bot/.*",
		"Bin/.*",
		"^Config/.*",
		"Core/.*",
		"Lib/.*",
		"Network/.*",
		"Utils/LuaCSharpArr",
		"Utils/LuaCSharpList",
		"Common/ClientSwitch",
		"Common/Math/.*",
		"Common/AI/Behaviac/.*",
		"Common/profiler",
		"Common/Utils/VoxelUtils.*",
		"Common/CommonSwitch.lua",
		"Common/Ability/CombatLogger.lua",
		"Common/Const/CharacterStateConst.lua",
		"Common/Const/PlayableConst.lua",
		"Entities/SpaceEntities/CommonComponent/AoiComponent.lua",
		"Entities/SpaceEntities/CommonComponent/PropInheritComponent.lua",
		"ServerSwitch.lua",
		"GameServer/GameLogicMetrics.lua",
		"Common/Utils/CalcUtils.lua",
		"Common/TestManager.lua"
	},
	impFiles = {
		"[Common.Const.CharacterStateConstImp]",
		"[Common.Data.PlayableConstImp]",
		"[GameApp.Controller.ControllerSystem]",
		"[GameApp.Chat.ChatSystem]"
	},
	deleteKeyModels = {
		"Common.Data.",
		"Data."
	},
	reloadAllfilterMap = {
		TestCase = true,
		GameServer = true,
		Common = true,
		Utils = true,
		Data = true,
		Entities = true,
		CustomTypesServerMethods = true,
		CustomTypes = true
	},
	reloadScriptfilterMap = {
		TestCase = true,
		GameServer = true,
		Common = true,
		Utils = true,
		Entities = true,
		CustomTypesServerMethods = true,
		CustomTypes = true
	},
	reloadDatafilterMap = {
		Data = true
	}
}

return ReloadFilter
