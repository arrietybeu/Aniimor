-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Data\\BehaviacData\\Meta\\MetaData.lua

local data = {
	{
		type = "WxAgent",
		base = "behaviacAgent",
		properties = {
			{
				name = "patrolWeight",
				defaultValue = 50
			},
			{
				name = "selfId",
				defaultValue = 0
			},
			{
				name = "distToTgt",
				defaultValue = 0
			},
			{
				name = "distToTgtForSkill",
				defaultValue = 0
			},
			{
				name = "jumpBackTimeline",
				defaultValue = 0
			},
			{
				name = "canWalkLeftOrRight",
				defaultValue = false
			},
			{
				name = "leaderId",
				defaultValue = 0
			},
			{
				name = "followTarget",
				defaultValue = 0
			},
			{
				name = "AI_IdleSpecialProb",
				defaultValue = 0
			},
			{
				name = "IdleMotionState",
				defaultValue = ""
			}
		}
	},
	{
		type = "CombatAgent",
		base = "WxAgent",
		properties = {
			{
				name = "combatReadyIsTurnToTarget",
				defaultValue = false
			},
			{
				name = "battlestage",
				defaultValue = 0
			},
			{
				name = "isCombatPrepareTrigger",
				defaultValue = false
			},
			{
				name = "minKeepBoxDist",
				defaultValue = 0
			},
			{
				name = "bestKeepBoxDist",
				defaultValue = 0
			},
			{
				name = "maxAttackDist",
				defaultValue = 0
			},
			{
				name = "attackStopBoxDist",
				defaultValue = 0
			},
			{
				name = "minAttackDist",
				defaultValue = 0
			},
			{
				name = "maxKeepBoxDist",
				defaultValue = 0
			},
			{
				name = "minBoxDist",
				defaultValue = 0
			},
			{
				name = "commonCombatSubtree",
				defaultValue = ""
			},
			{
				name = "tgt",
				defaultValue = 0
			},
			{
				name = "skillId",
				defaultValue = 0
			},
			{
				name = "sideWalkWeight",
				defaultValue = 50
			},
			{
				name = "attackWeight",
				defaultValue = 50
			},
			{
				name = "Param_ST_Monster_AutoCombat",
				defaultValue = "PBT_AutoCombat"
			},
			{
				name = "Param_ST_GoHome",
				defaultValue = "ST_GoHome"
			},
			{
				name = "Param_ST_Born",
				defaultValue = "PBT_Noop"
			},
			{
				name = "Param_ST_Combat_Prepare",
				defaultValue = "PBT_Combat_Prepare_Default"
			},
			{
				name = "Param_ST_Idle",
				defaultValue = "PBT_Noop"
			},
			{
				name = "Param_ST_Alert",
				defaultValue = "PBT_Noop"
			},
			{
				name = "Param_ST_Sensed",
				defaultValue = "PBT_Noop"
			},
			{
				name = "patrolWeight",
				defaultValue = 50
			},
			{
				name = "selfId",
				defaultValue = 0
			},
			{
				name = "distToTgt",
				defaultValue = 0
			},
			{
				name = "distToTgtForSkill",
				defaultValue = 0
			},
			{
				name = "jumpBackTimeline",
				defaultValue = 0
			},
			{
				name = "canWalkLeftOrRight",
				defaultValue = false
			},
			{
				name = "leaderId",
				defaultValue = 0
			},
			{
				name = "followTarget",
				defaultValue = 0
			},
			{
				name = "AI_IdleSpecialProb",
				defaultValue = 0
			},
			{
				name = "IdleMotionState",
				defaultValue = ""
			}
		}
	},
	{
		type = "PetAgent",
		base = "CombatAgent",
		properties = {
			{
				name = "masterId",
				defaultValue = 0
			},
			{
				name = "guideTargetActorId",
				defaultValue = 0
			},
			{
				name = "isEnterCombatByInvadeMode",
				defaultValue = false
			},
			{
				name = "afkFov",
				defaultValue = 0
			},
			{
				name = "switchedPet",
				defaultValue = false
			},
			{
				name = "combatReadyIsTurnToTarget",
				defaultValue = false
			},
			{
				name = "battlestage",
				defaultValue = 0
			},
			{
				name = "isCombatPrepareTrigger",
				defaultValue = false
			},
			{
				name = "minKeepBoxDist",
				defaultValue = 0
			},
			{
				name = "bestKeepBoxDist",
				defaultValue = 0
			},
			{
				name = "maxAttackDist",
				defaultValue = 0
			},
			{
				name = "attackStopBoxDist",
				defaultValue = 0
			},
			{
				name = "minAttackDist",
				defaultValue = 0
			},
			{
				name = "maxKeepBoxDist",
				defaultValue = 0
			},
			{
				name = "minBoxDist",
				defaultValue = 0
			},
			{
				name = "commonCombatSubtree",
				defaultValue = ""
			},
			{
				name = "tgt",
				defaultValue = 0
			},
			{
				name = "skillId",
				defaultValue = 0
			},
			{
				name = "sideWalkWeight",
				defaultValue = 50
			},
			{
				name = "attackWeight",
				defaultValue = 50
			},
			{
				name = "Param_ST_Monster_AutoCombat",
				defaultValue = "PBT_AutoCombat"
			},
			{
				name = "Param_ST_GoHome",
				defaultValue = "ST_GoHome"
			},
			{
				name = "Param_ST_Born",
				defaultValue = "PBT_Noop"
			},
			{
				name = "Param_ST_Combat_Prepare",
				defaultValue = "PBT_Combat_Prepare_Default"
			},
			{
				name = "Param_ST_Idle",
				defaultValue = "PBT_Noop"
			},
			{
				name = "Param_ST_Alert",
				defaultValue = "PBT_Noop"
			},
			{
				name = "Param_ST_Sensed",
				defaultValue = "PBT_Noop"
			},
			{
				name = "patrolWeight",
				defaultValue = 50
			},
			{
				name = "selfId",
				defaultValue = 0
			},
			{
				name = "distToTgt",
				defaultValue = 0
			},
			{
				name = "distToTgtForSkill",
				defaultValue = 0
			},
			{
				name = "jumpBackTimeline",
				defaultValue = 0
			},
			{
				name = "canWalkLeftOrRight",
				defaultValue = false
			},
			{
				name = "leaderId",
				defaultValue = 0
			},
			{
				name = "followTarget",
				defaultValue = 0
			},
			{
				name = "AI_IdleSpecialProb",
				defaultValue = 0
			},
			{
				name = "IdleMotionState",
				defaultValue = ""
			}
		}
	},
	{
		type = "PuppetAgent",
		base = "CombatAgent",
		properties = {
			{
				name = "behaviorActTgtId",
				defaultValue = 0
			},
			{
				name = "CounterInt_1",
				defaultValue = 0
			},
			{
				name = "fightCd",
				defaultValue = 0
			},
			{
				name = "atkCd",
				defaultValue = 0
			},
			{
				name = "skillCd",
				defaultValue = 0
			},
			{
				name = "combatReadyIsTurnToTarget",
				defaultValue = false
			},
			{
				name = "battlestage",
				defaultValue = 0
			},
			{
				name = "isCombatPrepareTrigger",
				defaultValue = false
			},
			{
				name = "minKeepBoxDist",
				defaultValue = 0
			},
			{
				name = "bestKeepBoxDist",
				defaultValue = 0
			},
			{
				name = "maxAttackDist",
				defaultValue = 0
			},
			{
				name = "attackStopBoxDist",
				defaultValue = 0
			},
			{
				name = "minAttackDist",
				defaultValue = 0
			},
			{
				name = "maxKeepBoxDist",
				defaultValue = 0
			},
			{
				name = "minBoxDist",
				defaultValue = 0
			},
			{
				name = "commonCombatSubtree",
				defaultValue = ""
			},
			{
				name = "tgt",
				defaultValue = 0
			},
			{
				name = "skillId",
				defaultValue = 0
			},
			{
				name = "sideWalkWeight",
				defaultValue = 50
			},
			{
				name = "attackWeight",
				defaultValue = 50
			},
			{
				name = "Param_ST_Monster_AutoCombat",
				defaultValue = "PBT_AutoCombat"
			},
			{
				name = "Param_ST_GoHome",
				defaultValue = "ST_GoHome"
			},
			{
				name = "Param_ST_Born",
				defaultValue = "PBT_Noop"
			},
			{
				name = "Param_ST_Combat_Prepare",
				defaultValue = "PBT_Combat_Prepare_Default"
			},
			{
				name = "Param_ST_Idle",
				defaultValue = "PBT_Noop"
			},
			{
				name = "Param_ST_Alert",
				defaultValue = "PBT_Noop"
			},
			{
				name = "Param_ST_Sensed",
				defaultValue = "PBT_Noop"
			},
			{
				name = "patrolWeight",
				defaultValue = 50
			},
			{
				name = "selfId",
				defaultValue = 0
			},
			{
				name = "distToTgt",
				defaultValue = 0
			},
			{
				name = "distToTgtForSkill",
				defaultValue = 0
			},
			{
				name = "jumpBackTimeline",
				defaultValue = 0
			},
			{
				name = "canWalkLeftOrRight",
				defaultValue = false
			},
			{
				name = "leaderId",
				defaultValue = 0
			},
			{
				name = "followTarget",
				defaultValue = 0
			},
			{
				name = "AI_IdleSpecialProb",
				defaultValue = 0
			},
			{
				name = "IdleMotionState",
				defaultValue = ""
			}
		}
	},
	{
		type = "PetBallAgent",
		base = "CombatAgent",
		properties = {
			{
				name = "combatReadyIsTurnToTarget",
				defaultValue = false
			},
			{
				name = "battlestage",
				defaultValue = 0
			},
			{
				name = "isCombatPrepareTrigger",
				defaultValue = false
			},
			{
				name = "minKeepBoxDist",
				defaultValue = 0
			},
			{
				name = "bestKeepBoxDist",
				defaultValue = 0
			},
			{
				name = "maxAttackDist",
				defaultValue = 0
			},
			{
				name = "attackStopBoxDist",
				defaultValue = 0
			},
			{
				name = "minAttackDist",
				defaultValue = 0
			},
			{
				name = "maxKeepBoxDist",
				defaultValue = 0
			},
			{
				name = "minBoxDist",
				defaultValue = 0
			},
			{
				name = "commonCombatSubtree",
				defaultValue = ""
			},
			{
				name = "tgt",
				defaultValue = 0
			},
			{
				name = "skillId",
				defaultValue = 0
			},
			{
				name = "sideWalkWeight",
				defaultValue = 50
			},
			{
				name = "attackWeight",
				defaultValue = 50
			},
			{
				name = "Param_ST_Monster_AutoCombat",
				defaultValue = "PBT_AutoCombat"
			},
			{
				name = "Param_ST_GoHome",
				defaultValue = "ST_GoHome"
			},
			{
				name = "Param_ST_Born",
				defaultValue = "PBT_Noop"
			},
			{
				name = "Param_ST_Combat_Prepare",
				defaultValue = "PBT_Combat_Prepare_Default"
			},
			{
				name = "Param_ST_Idle",
				defaultValue = "PBT_Noop"
			},
			{
				name = "Param_ST_Alert",
				defaultValue = "PBT_Noop"
			},
			{
				name = "Param_ST_Sensed",
				defaultValue = "PBT_Noop"
			},
			{
				name = "patrolWeight",
				defaultValue = 50
			},
			{
				name = "selfId",
				defaultValue = 0
			},
			{
				name = "distToTgt",
				defaultValue = 0
			},
			{
				name = "distToTgtForSkill",
				defaultValue = 0
			},
			{
				name = "jumpBackTimeline",
				defaultValue = 0
			},
			{
				name = "canWalkLeftOrRight",
				defaultValue = false
			},
			{
				name = "leaderId",
				defaultValue = 0
			},
			{
				name = "followTarget",
				defaultValue = 0
			},
			{
				name = "AI_IdleSpecialProb",
				defaultValue = 0
			},
			{
				name = "IdleMotionState",
				defaultValue = ""
			}
		}
	},
	{
		type = "VirtualAIAgent",
		base = "CombatAgent",
		properties = {
			{
				name = "combatReadyIsTurnToTarget",
				defaultValue = false
			},
			{
				name = "battlestage",
				defaultValue = 0
			},
			{
				name = "isCombatPrepareTrigger",
				defaultValue = false
			},
			{
				name = "minKeepBoxDist",
				defaultValue = 0
			},
			{
				name = "bestKeepBoxDist",
				defaultValue = 0
			},
			{
				name = "maxAttackDist",
				defaultValue = 0
			},
			{
				name = "attackStopBoxDist",
				defaultValue = 0
			},
			{
				name = "minAttackDist",
				defaultValue = 0
			},
			{
				name = "maxKeepBoxDist",
				defaultValue = 0
			},
			{
				name = "minBoxDist",
				defaultValue = 0
			},
			{
				name = "commonCombatSubtree",
				defaultValue = ""
			},
			{
				name = "tgt",
				defaultValue = 0
			},
			{
				name = "skillId",
				defaultValue = 0
			},
			{
				name = "sideWalkWeight",
				defaultValue = 50
			},
			{
				name = "attackWeight",
				defaultValue = 50
			},
			{
				name = "Param_ST_Monster_AutoCombat",
				defaultValue = "PBT_AutoCombat"
			},
			{
				name = "Param_ST_GoHome",
				defaultValue = "ST_GoHome"
			},
			{
				name = "Param_ST_Born",
				defaultValue = "PBT_Noop"
			},
			{
				name = "Param_ST_Combat_Prepare",
				defaultValue = "PBT_Combat_Prepare_Default"
			},
			{
				name = "Param_ST_Idle",
				defaultValue = "PBT_Noop"
			},
			{
				name = "Param_ST_Alert",
				defaultValue = "PBT_Noop"
			},
			{
				name = "Param_ST_Sensed",
				defaultValue = "PBT_Noop"
			},
			{
				name = "patrolWeight",
				defaultValue = 50
			},
			{
				name = "selfId",
				defaultValue = 0
			},
			{
				name = "distToTgt",
				defaultValue = 0
			},
			{
				name = "distToTgtForSkill",
				defaultValue = 0
			},
			{
				name = "jumpBackTimeline",
				defaultValue = 0
			},
			{
				name = "canWalkLeftOrRight",
				defaultValue = false
			},
			{
				name = "leaderId",
				defaultValue = 0
			},
			{
				name = "followTarget",
				defaultValue = 0
			},
			{
				name = "AI_IdleSpecialProb",
				defaultValue = 0
			},
			{
				name = "IdleMotionState",
				defaultValue = ""
			}
		}
	}
}

return data
