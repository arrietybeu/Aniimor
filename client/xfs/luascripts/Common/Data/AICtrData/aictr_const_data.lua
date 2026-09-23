-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\AICtrData\\aictr_const_data.lua

local CTRConst = require("Common.AICt.CTRConst")
local data = {
	puppet_data = {
		partnerEnterCombatType = "int",
		ethnicGroup = "int",
		bornState = "string",
		petPrototypeId = "int",
		id = "int",
		beFollowMode = "int",
		ArriveRainShelterDialogId = "int",
		GotoRainShelterDialogId = "int",
		reactionRainPRTag = "string",
		reactionRainBehav = "string",
		baseFormPet = "int",
		enterWaterDeathDepthRatio = "float",
		catchFailureBehavType = "string",
		sleepRPTag = "string",
		sleepDayTime = "int",
		mimicryType = "int",
		mimicryOutBySkillElementList = "LuaTableTp",
		mimicryOutByChemList = "LuaTableTp",
		mimicryOutImpulseThreshold = "float",
		stage = "int",
		label = "int",
		perceptFullSpBehavType = "string",
		perceptFullSpBehavProtoId = "int",
		perceptFullBehavType = "string",
		brotherSensedEnterCombatType = "int",
		babyCatchedBrotherEnterCombatType = "int",
		babySensedBrotherEnterCombatType = "int",
		partnerEnterCombatDis = "float"
	},
	pet_data = {
		baseFormPet = "int",
		ethnicGroup = "int",
		beFollowMode = "int",
		petPrototypeId = "int"
	},
	getLogicState = {
		"LOCOMOTION",
		"SNEAK",
		"GROUND",
		"FLYING",
		"SWIMMING",
		"MIMICRY",
		"SWIMMIMICRY",
		"MIMICRYOUT",
		"SWIMMIMICRYOUT",
		"SPECIALMOVEIN",
		"SPECIALMOVEOUT"
	},
	getAnimState = {
		Behav_Happy = {
			{
				value = "Behav_Happy",
				name = "result"
			}
		},
		Behav_Eat = {
			{
				value = "Behav_EatStart",
				name = "1_start"
			},
			{
				value = "Behav_EatLoop",
				name = "2_loop"
			},
			{
				value = "Behav_EatEnd",
				name = "3_end"
			}
		}
	},
	foreachPreset = {
		entity = {
			elementType = "int",
			foreachKv = CTRConst.ForeachKV.MAP_KEY
		}
	},
	repeatTrigger = {
		eventTrigger = {
			Event_PER_ = "interactBehav",
			PercpetEntityReactionTrigger = "interactBehav",
			CommonClientMsgTrigger = "suffix",
			PlayerVarChangeTrigger = "in_filtKey",
			LevelMsgTrigger = "in_filtKey",
			GBPMsg_Common = "suffix",
			Event_Ability_ = "suffix",
			GBPMsg_ResPoint = "suffix"
		},
		messageTrigger = {}
	}
}

return data
