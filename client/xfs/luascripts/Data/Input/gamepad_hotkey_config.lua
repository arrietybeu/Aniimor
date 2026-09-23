-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Data\\Input\\gamepad_hotkey_config.lua

local data = {
	groupName = "Gamepad",
	matchPaths = {
		"<Gamepad>"
	},
	hotkeyExcludes = {
		"<Gamepad>/rightStick/up",
		"<Gamepad>/rightStick/down",
		"<Gamepad>/rightStick/left",
		"<Gamepad>/rightStick/right",
		"<Gamepad>/leftStick/up",
		"<Gamepad>/leftStick/down",
		"<Gamepad>/leftStick/left",
		"<Gamepad>/leftStick/right",
		"<Gamepad>/start",
		"<Gamepad>/select",
		"<Gamepad>/anykey"
	},
	hotkeyActions = {
		["Bind/Sprint"] = {},
		["Bind/Jump"] = {},
		["Bind/ClimbJump"] = {},
		["Bind/Interact"] = {},
		["Bind/Lock"] = {},
		["Bind/NormalAttack"] = {},
		["Bind/MoveGamepad"] = {},
		["Bind/ViewAxisGamepad"] = {},
		["Bind/Pet1"] = {},
		["Bind/Pet2"] = {},
		["Bind/Pet3"] = {},
		["Bind/Pet4"] = {},
		["Bind/GamepadSkillModifier"] = {
			group = "default,skill"
		},
		["Bind/Skill1"] = {
			group = "default,skill"
		},
		["Bind/Skill2"] = {
			group = "default,skill"
		},
		["Bind/Skill3"] = {
			group = "default,skill"
		},
		["Bind/ExploreSkill"] = {
			group = "default,skill"
		},
		["Bind/ExploreSkillButton1"] = {
			group = "exploreSkill, combineButton1"
		},
		["Bind/ExploreSkillButton2"] = {
			group = "exploreSkill, combineButton2"
		},
		["Bind/SkillChainAttackButton1"] = {
			group = "chainSkill, combineButton1"
		},
		["Bind/SkillChainAttackButton2"] = {
			group = "chainSkill, combineButton2"
		},
		["Bind/FunctionMenu"] = {},
		["Bind/Chat"] = {},
		["Bind/ItemModifier"] = {
			group = "ItemModifier"
		},
		["Bind/ItemModifier2"] = {
			group = "ItemModifier"
		},
		["Bind/Confirm"] = {
			group = "Common"
		},
		["Bind/Cancel"] = {
			group = "Common"
		},
		["Bind/CombineBallAndItemMenu"] = {},
		["Bind/CombineBallAndItemUse"] = {},
		["Bind/SwitchCatchMode"] = {},
		["Bind/SwitchPet"] = {},
		["Bind/TrackOpenSpecial"] = {},
		["Bind/LockTarget"] = {},
		["Bind/OpenChat"] = {}
	},
	relativeActions = {
		{
			src = "Bind/Jump",
			target = "Player/Jump"
		},
		{
			src = "Bind/Jump",
			target = "Player/SpecialAbility"
		},
		{
			src = "Bind/Sprint",
			target = "Player/StartSprint"
		},
		{
			src = "Bind/Sprint",
			target = "Catch/GamepadExitCatch"
		},
		{
			src = "Bind/Sprint",
			target = "BallDrive/Cancel"
		},
		{
			src = "Bind/NormalAttack",
			target = "Hud/ExitDelayExplore"
		},
		{
			src = "Bind/NormalAttack",
			target = "Hud/NormalAttack"
		},
		{
			src = "Bind/TrackOpenSpecial",
			target = "Hud/TrackOpenSpecial"
		},
		{
			src = "Bind/TrackOpenSpecial",
			target = "Hud/TrackCloseSpecial"
		},
		{
			src = "Bind/TrackOpenSpecial",
			target = "Hud/SwitchPage"
		},
		{
			src = "Bind/TrackOpenSpecial",
			target = "Hud/TempleHelp"
		},
		{
			src = "Bind/TrackOpenSpecial",
			target = "Hud/ResetPuzzle"
		},
		{
			src = "Bind/LockTarget",
			target = "Skill/LockTarget"
		},
		{
			src = "Bind/LockTarget",
			target = "Catch/Focus"
		},
		{
			src = "Bind/LockTarget",
			target = "Common/TabSwitch"
		},
		{
			bindingIndex = 2,
			target = "Hud/ExploreSkill",
			src = "Bind/ExploreSkillButton1"
		},
		{
			bindingIndex = 3,
			target = "Hud/ExploreSkill",
			src = "Bind/ExploreSkillButton2"
		},
		{
			bindingIndex = 2,
			target = "Hud/SkillChainAttack",
			src = "Bind/SkillChainAttackButton1"
		},
		{
			bindingIndex = 3,
			target = "Hud/SkillChainAttack",
			src = "Bind/SkillChainAttackButton2"
		},
		{
			src = "Bind/Pet1",
			target = "Hud/Pet1"
		},
		{
			src = "Bind/Skill1",
			target = "Hud/SkillQ"
		},
		{
			bindingIndex = 2,
			target = "Hud/SkillR",
			src = "Bind/Skill1"
		},
		{
			src = "Bind/Skill1",
			target = "Hud/VehicleSkillQ"
		},
		{
			bindingIndex = 2,
			target = "Hud/VehicleSkillR",
			src = "Bind/Skill1"
		},
		{
			src = "Bind/Pet2",
			target = "Hud/Pet2"
		},
		{
			src = "Bind/Skill2",
			target = "Hud/SkillE"
		},
		{
			bindingIndex = 3,
			target = "Hud/SkillR",
			src = "Bind/Skill2"
		},
		{
			src = "Bind/Skill2",
			target = "Hud/VehicleSkillE"
		},
		{
			bindingIndex = 3,
			target = "Hud/VehicleSkillR",
			src = "Bind/Skill2"
		},
		{
			src = "Bind/Pet3",
			target = "Hud/Pet3"
		},
		{
			src = "Bind/SwitchCatchMode",
			target = "Catch/SwitchCatchMode"
		},
		{
			src = "Bind/SwitchCatchMode",
			target = "Hud/GamepadHomelandLT"
		},
		{
			src = "Bind/Pet4",
			target = "Hud/Pet4"
		},
		{
			src = "Bind/SwitchPet",
			target = "Hud/SwitchPet"
		},
		{
			src = "Bind/SwitchPet",
			target = "Catch/Throw"
		},
		{
			src = "Bind/SwitchPet",
			target = "Hud/GamepadHomelandRT"
		},
		{
			src = "Bind/Confirm",
			target = "Common/Confirm"
		},
		{
			src = "Bind/Confirm",
			target = "Hud/PetManagementButtonFun4"
		},
		{
			src = "Bind/Confirm",
			target = "Raw/GamepadButtonSouth"
		},
		{
			src = "Bind/Confirm",
			target = "Common/GamepadConfirmLowPriority"
		},
		{
			src = "Bind/Confirm",
			target = "Common/GamepadConfirm"
		},
		{
			src = "Bind/Confirm",
			target = "Skill/Grab"
		},
		{
			src = "Bind/Confirm",
			target = "Hud/HitMusic"
		},
		{
			src = "Bind/Confirm",
			target = "Photo/Space"
		},
		{
			src = "Bind/Confirm",
			target = "Fly/GlideRise"
		},
		{
			src = "Bind/Cancel",
			target = "Common/Cancel"
		},
		{
			src = "Bind/Cancel",
			target = "Hud/PetManagementButtonFun3"
		},
		{
			src = "Bind/Cancel",
			target = "Raw/GamepadButtonEast"
		},
		{
			src = "Bind/Cancel",
			target = "Common/GamepadCancelLowPriority"
		},
		{
			src = "Bind/Cancel",
			target = "Common/GamepadCancel"
		},
		{
			src = "Bind/Cancel",
			target = "Common/ClosePanelCommon"
		},
		{
			src = "Bind/Cancel",
			target = "Skill/CancelGrab"
		},
		{
			src = "Bind/Cancel",
			target = "Hud/QuitExploreState"
		},
		{
			src = "Bind/Cancel",
			target = "Hud/VehicleSkillT"
		},
		{
			src = "Bind/Skill2",
			target = "Skill/PutItem"
		}
	},
	waitCombineActions = {
		"Player/Jump",
		"Player/StartSprint",
		"Player/SpecialAbility",
		"Player/ClimbJump",
		"Hud/NormalAttack",
		"Hud/SkillQ",
		"Hud/SkillE",
		"Hud/Interact",
		"Hud/ItemDetail",
		"Hud/GamepadInteract",
		"Hud/GamepadInteractSwitch",
		"Hud/CombineBallAndItemMenu",
		"Hud/CombineBallAndItemUse",
		"Hud/GamepadMenu",
		"Skill/LockTarget",
		"Catch/Throw",
		"Hud/OpenChat",
		"Hud/OpenSetup",
		"Hud/TrackOpenSpecial",
		"Hud/HelpTipEnter",
		"Hud/OpenEmotion",
		"Hud/ActivateVirtualMouse",
		"Hud/DeleteInfoStamp",
		"Hud/ExitCarryEgg",
		"Hud/ExitDelayExplore",
		"Hud/GamepadSwitchRightWheel",
		"Hud/GamepadZoomOut",
		"Hud/HomelandRecycle",
		"Hud/HomelandRedo",
		"Hud/InfoStampGoCourse",
		"Hud/LikeInfoStamp",
		"Hud/PetManagementButtonFun1",
		"Hud/PetManagementButtonFun10",
		"Hud/QteRight",
		"Hud/RightShoulder",
		"Hud/VehicleSkillE",
		"Hud/GetSinglePet",
		"Hud/SwitchPet",
		"Catch/SwitchCatchMode",
		"Hud/QteC",
		"Hud/QuitDungeonGamepad",
		"Fly/Drop",
		"Fly/Rise"
	}
}

return data
