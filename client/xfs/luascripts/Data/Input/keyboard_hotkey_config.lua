-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\Input\\keyboard_hotkey_config.lua

local data = {
	groupName = "Keyboard&Mouse",
	matchPaths = {
		"<Keyboard>",
		"<Mouse>"
	},
	hotkeyExcludes = {
		"<Keyboard>/ctrl",
		"<Keyboard>/leftCtrl",
		"<Keyboard>/rightCtrl",
		"<Keyboard>/alt",
		"<Keyboard>/leftAlt",
		"<Keyboard>/rightAlt",
		"<Keyboard>/escape",
		"<Keyboard>/anykey",
		"<Keyboard>/n"
	},
	hotkeyActions = {
		["Bind/MoveUp"] = {},
		["Bind/MoveDown"] = {},
		["Bind/MoveLeft"] = {},
		["Bind/MoveRight"] = {},
		["Bind/CameraZoom"] = {},
		["Bind/Sprint"] = {},
		["Bind/Jump"] = {},
		["Bind/Interact"] = {},
		["Bind/Lock"] = {},
		["Bind/ClimbJump"] = {},
		["Bind/SwitchPet"] = {},
		["Bind/Pet1"] = {},
		["Bind/Pet2"] = {},
		["Bind/Pet3"] = {},
		["Bind/Pet4"] = {},
		["Bind/NormalAttack"] = {},
		["Bind/Skill1"] = {},
		["Bind/Skill2"] = {},
		["Bind/Skill3"] = {},
		["Bind/ExploreSkill"] = {},
		["Bind/Aim"] = {},
		["Bind/SwitchCatchMode"] = {},
		["Bind/ItemModifier"] = {},
		["Bind/Item1"] = {},
		["Bind/Item2"] = {},
		["Bind/Item3"] = {},
		["Bind/Item4"] = {},
		["Bind/SpecialAbility"] = {},
		["Bind/OpenPetBall"] = {},
		["Bind/OpenSetup"] = {},
		["Bind/OpenHelp"] = {},
		["Bind/OpenOrb"] = {},
		["Bind/OpenMap"] = {},
		["Bind/OpenPet"] = {},
		["Bind/OpenInformation"] = {},
		["Bind/OpenBag"] = {},
		["Bind/OpenHandBook"] = {},
		["Bind/QuickPhoto"] = {},
		["Bind/OpenMission"] = {},
		["Bind/ShowCursor"] = {},
		["Bind/Confirm"] = {},
		["Bind/CancelBind"] = {},
		["Bind/OpenPetBall"] = {},
		["Bind/battlePass"] = {},
		["Bind/SwitchTeamNegative"] = {},
		["Bind/SwitchTeamPositive"] = {},
		["Bind/SwitchPetTeam"] = {},
		["Bind/SwitchPetMode"] = {},
		["Bind/SkillChainAttack"] = {},
		["Bind/ItemDetail"] = {},
		["Bind/VoiceChannel"] = {},
		["Bind/TrackOpenSpecial"] = {},
		["Bind/OpenSpecialTrain"] = {},
		["Bind/SwitchPage"] = {},
		["Bind/Extra1"] = {},
		["Bind/Service"] = {},
		["Bind/OpenSchoolGuide"] = {},
		["Bind/HomelandLog"] = {},
		["Bind/HomelandPet"] = {},
		["Bind/HomelandBuild"] = {},
		["Bind/HomelandStore"] = {},
		["Bind/Snapshot"] = {},
		["Bind/OpenEmotion"] = {},
		["Bind/HomelandFurnitureStore"] = {},
		["Bind/HomelandPlantBook"] = {},
		["Bind/HomelandMainPage"] = {},
		["Bind/Shop"] = {},
		["Bind/Rule"] = {},
		["Bind/HomelandManage"] = {}
	},
	relativeActions = {
		{
			target = "Player/Move",
			bindingIndex = 1,
			src = "Bind/MoveUp"
		},
		{
			target = "Player/Move",
			bindingIndex = 2,
			src = "Bind/MoveDown"
		},
		{
			target = "Player/Move",
			bindingIndex = 3,
			src = "Bind/MoveLeft"
		},
		{
			target = "Player/Move",
			bindingIndex = 4,
			src = "Bind/MoveRight"
		},
		{
			target = "Player/Jump",
			src = "Bind/Jump"
		},
		{
			target = "Player/StartSprint",
			src = "Bind/Sprint"
		},
		{
			target = "Player/ClimbJump",
			src = "Bind/ClimbJump"
		},
		{
			target = "Player/ClimbJump2",
			bindingIndex = 2,
			src = "Bind/Jump"
		},
		{
			target = "Player/SpecialAbility",
			src = "Bind/SpecialAbility"
		},
		{
			target = "Player/FastClimb",
			src = "Bind/Sprint"
		},
		{
			target = "Hud/Pet1",
			src = "Bind/Pet1"
		},
		{
			target = "Hud/Pet2",
			src = "Bind/Pet2"
		},
		{
			target = "Hud/Pet3",
			src = "Bind/Pet3"
		},
		{
			target = "Hud/Pet4",
			src = "Bind/Pet4"
		},
		{
			target = "Hud/SwitchPet",
			src = "Bind/SwitchPet"
		},
		{
			target = "Hud/ExitDelayExplore",
			src = "Bind/NormalAttack"
		},
		{
			target = "Hud/SkillQ",
			src = "Bind/Skill1"
		},
		{
			target = "Hud/SkillE",
			src = "Bind/Skill2"
		},
		{
			target = "Hud/SkillR",
			src = "Bind/Skill3"
		},
		{
			target = "Hud/ExploreSkill",
			src = "Bind/ExploreSkill"
		},
		{
			target = "Hud/Extra1",
			src = "Bind/Item1"
		},
		{
			target = "Hud/Extra2",
			src = "Bind/Item2"
		},
		{
			target = "Hud/Extra3",
			src = "Bind/Item3"
		},
		{
			target = "Hud/Extra4",
			src = "Bind/Item4"
		},
		{
			target = "Hud/NormalAttack",
			src = "Bind/NormalAttack"
		},
		{
			target = "Hud/Go",
			src = "Bind/Go"
		},
		{
			target = "Hud/Stop",
			src = "Bind/Stop"
		},
		{
			target = "Hud/BallMenu",
			src = "Bind/ItemModifier"
		},
		{
			target = "Hud/Interact",
			src = "Bind/Interact"
		},
		{
			target = "Hud/QteLeft",
			src = "Bind/Skill1"
		},
		{
			target = "Hud/QteRight",
			src = "Bind/Skill2"
		},
		{
			target = "Hud/QuickPhoto",
			src = "Bind/QuickPhoto"
		},
		{
			target = "Hud/OpenHandBook",
			src = "Bind/OpenHandBook"
		},
		{
			target = "Hud/PetFirstOpenPetHandBook",
			src = "Bind/OpenHandBook"
		},
		{
			target = "Hud/OpenBag",
			src = "Bind/OpenBag"
		},
		{
			target = "Hud/OpenInformation",
			src = "Bind/OpenInformation"
		},
		{
			target = "Hud/OpenPet",
			src = "Bind/OpenPet"
		},
		{
			target = "Hud/GetSinglePet",
			src = "Bind/OpenPet"
		},
		{
			target = "Hud/OpenMap",
			src = "Bind/OpenMap"
		},
		{
			target = "Hud/AIAssistantOpenMap",
			src = "Bind/OpenMap"
		},
		{
			target = "Hud/OpenMission",
			src = "Bind/OpenMission"
		},
		{
			target = "Hud/OpenHelp",
			src = "Bind/OpenHelp"
		},
		{
			target = "Hud/battlePass",
			src = "Bind/battlePass"
		},
		{
			target = "Hud/SwitchPetTeam",
			src = "Bind/SwitchPetTeam"
		},
		{
			target = "Hud/SwitchPetMode",
			src = "Bind/SwitchPetMode"
		},
		{
			target = "Hud/OpenPVP",
			src = "Bind/OpenPVP"
		},
		{
			target = "Hud/OpenPetBall",
			src = "Bind/OpenPetBall"
		},
		{
			target = "Hud/SkillChainAttack",
			src = "Bind/SkillChainAttack"
		},
		{
			target = "Hud/ItemDetail",
			src = "Bind/ItemDetail"
		},
		{
			target = "Hud/TeamSpeech",
			src = "Bind/VoiceChannel"
		},
		{
			target = "Hud/PushTalk",
			src = "Bind/VoiceChannel"
		},
		{
			target = "Hud/OpenOrb",
			src = "Bind/OpenOrb"
		},
		{
			target = "Hud/OpenPetBall",
			src = "Bind/OpenPetBall"
		},
		{
			target = "Hud/TrackOpenSpecial",
			src = "Bind/TrackOpenSpecial"
		},
		{
			target = "Hud/OpenSpecialTrain",
			src = "Bind/OpenSpecialTrain"
		},
		{
			target = "Hud/SwitchPage",
			src = "Bind/SwitchPage"
		},
		{
			target = "Hud/Extra1",
			src = "Bind/Extra1"
		},
		{
			target = "Hud/Service",
			src = "Bind/Service"
		},
		{
			target = "Hud/OpenSchoolGuide",
			src = "Bind/OpenSchoolGuide"
		},
		{
			target = "Hud/HomelandLog",
			src = "Bind/HomelandLog"
		},
		{
			target = "Hud/HomelandPet",
			src = "Bind/HomelandPet"
		},
		{
			target = "Hud/HomelandBuild",
			src = "Bind/HomelandBuild"
		},
		{
			target = "Hud/HomelandStore",
			src = "Bind/HomelandStore"
		},
		{
			target = "Hud/HomelandManage",
			src = "Bind/HomelandManage"
		},
		{
			target = "Hud/DungeonPhoto",
			src = "Bind/QuickPhoto"
		},
		{
			target = "Hud/Snapshot",
			src = "Bind/Snapshot"
		},
		{
			target = "Hud/OpenEmotion",
			src = "Bind/OpenEmotion"
		},
		{
			target = "Hud/HomelandFurnitureStore",
			src = "Bind/HomelandFurnitureStore"
		},
		{
			target = "Hud/HomelandPlantBook",
			src = "Bind/HomelandPlantBook"
		},
		{
			target = "Hud/HomelandMainPage",
			src = "Bind/HomelandMainPage"
		},
		{
			target = "Hud/HomelandDesign",
			src = "Bind/HomelandDesign"
		},
		{
			target = "Hud/HomelandSeason",
			src = "Bind/HomelandSeason"
		},
		{
			target = "Hud/Shop",
			src = "Bind/Shop"
		},
		{
			target = "Hud/Rule",
			src = "Bind/Rule"
		},
		{
			target = "Camera/ShowCursor",
			src = "Bind/ShowCursor"
		},
		{
			target = "Camera/CameraZoom",
			src = "Bind/CameraZoom"
		},
		{
			target = "Common/Confirm",
			src = "Bind/Confirm"
		},
		{
			target = "Common/Cancel",
			src = "Bind/CancelBind"
		},
		{
			target = "Skill/LockTarget",
			src = "Bind/Lock"
		},
		{
			target = "Skill/SupportSkill1",
			bindingIndex = 2,
			src = "Bind/Pet1"
		},
		{
			target = "Skill/SupportSkill2",
			bindingIndex = 2,
			src = "Bind/Pet2"
		},
		{
			target = "Skill/SupportSkill3",
			bindingIndex = 2,
			src = "Bind/Pet3"
		},
		{
			target = "Skill/SupportSkill4",
			bindingIndex = 2,
			src = "Bind/Pet4"
		},
		{
			target = "Skill/PutItem",
			src = "Bind/NormalAttack"
		},
		{
			target = "Pet/SwitchTeamNegative",
			src = "Bind/SwitchTeamNegative"
		},
		{
			target = "Pet/SwitchTeamPositive",
			src = "Bind/SwitchTeamPositive"
		},
		{
			target = "Catch/Throw",
			src = "Bind/NormalAttack"
		},
		{
			target = "Catch/SwitchCatchMode",
			src = "Bind/SwitchCatchMode"
		},
		{
			target = "Catch/Focus",
			src = "Bind/Lock"
		},
		{
			target = "BallDrive/Move",
			bindingIndex = 2,
			src = "Bind/MoveUp"
		},
		{
			target = "BallDrive/Move",
			bindingIndex = 3,
			src = "Bind/MoveDown"
		},
		{
			target = "BallDrive/Move",
			bindingIndex = 4,
			src = "Bind/MoveLeft"
		},
		{
			target = "BallDrive/Move",
			bindingIndex = 5,
			src = "Bind/MoveRight"
		},
		{
			target = "BallDrive/Cancel",
			src = "Bind/Skill2"
		},
		{
			target = "Temp/SupportSkill1",
			bindingIndex = 2,
			src = "Bind/Pet1"
		},
		{
			target = "Temp/SupportSkill2",
			bindingIndex = 2,
			src = "Bind/Pet2"
		},
		{
			target = "Temp/SupportSkill3",
			bindingIndex = 2,
			src = "Bind/Pet3"
		},
		{
			target = "Temp/SupportSkill4",
			bindingIndex = 2,
			src = "Bind/Pet4"
		}
	}
}

return data
