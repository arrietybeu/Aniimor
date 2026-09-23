-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Components\\StateClassify.lua

local LoggerManager = require("Core.Log.LoggerManager")
local log = LoggerManager.getLogger("StateClassify")
local CACHEABLE = "cacheable"
local REALTIME = "realtime"
local GROUP_CHAR = "char"
local GROUP_MASK = "mask"
local GROUP_BUFF = "buff"
local GROUP_KNOCK = "knock"
local GROUP_LIFE = "life"

local function C(group)
	return {
		class = CACHEABLE,
		group = group
	}
end

local function S()
	return {
		single = true,
		class = CACHEABLE
	}
end

local function R()
	return {
		class = REALTIME
	}
end

local STATE_CLASS = {
	SPRINT_ST = C(GROUP_CHAR),
	CLIMB_ACROSS_ST = C(GROUP_CHAR),
	CROUCH_ST = C(GROUP_CHAR),
	MOVE_STOP_ST = C(GROUP_CHAR),
	STRUGGLE_ST = C(GROUP_CHAR),
	SKILL_GLIDING_ST = C(GROUP_CHAR),
	FLY_ST = C(GROUP_CHAR),
	FLY_CHARGING_ST = C(GROUP_CHAR),
	TAKE_ROOT_ST = C(GROUP_CHAR),
	TAKE_ROOT_IN_ST = C(GROUP_CHAR),
	MIMICRY_ST = C(GROUP_CHAR),
	FOUR_WAY_MOVE_ST = C(GROUP_CHAR),
	WALKING_ATTACK_ST = C(GROUP_CHAR),
	SPEED_BURST_ST = C(GROUP_CHAR),
	SURF_ST = C(GROUP_CHAR),
	HOOK_SPRINT_ST = C(GROUP_CHAR),
	SKATEBOARD_ST = C(GROUP_CHAR),
	FIRST_AID_ST = C(GROUP_CHAR),
	PLAY_ANIMATION_SCRIPT_ST = C(GROUP_CHAR),
	MAGNESIS_ST = C(GROUP_CHAR),
	MAGNESIS_THROW_ST = C(GROUP_CHAR),
	MAGNESIS_GRABBING_ST = C(GROUP_CHAR),
	LATERAL_ATTACK_ST = C(GROUP_CHAR),
	STATICSPAWN_ST = C(GROUP_CHAR),
	SPECIAL_RIDE_BOSS_ST = C(GROUP_CHAR),
	RIDING_ST = C(GROUP_CHAR),
	SKILL_ST = C(GROUP_MASK),
	ATTACK_ST = C(GROUP_MASK),
	HIT_ST = C(GROUP_MASK),
	HIT_BACKSWING_ST = C(GROUP_MASK),
	CAST_ST = C(GROUP_MASK),
	CANCELLABLE_ST = C(GROUP_MASK),
	COMBO_ST = C(GROUP_MASK),
	BACKSWING_ST = C(GROUP_MASK),
	ABILITY_ST = C(GROUP_MASK),
	ULTIMATE_CAST_ST = C(GROUP_MASK),
	KEY_FRAME_BACKSWING_ST = C(GROUP_MASK),
	CHARM_ST = C(GROUP_BUFF),
	STUN_ST = C(GROUP_BUFF),
	FROZEN_ST = C(GROUP_BUFF),
	SLEEP_ST = C(GROUP_BUFF),
	PALSY_ST = C(GROUP_BUFF),
	SILENT_ST = C(GROUP_BUFF),
	CLOUD_CONFINE_ST = C(GROUP_BUFF),
	BREAK_ST = C(GROUP_BUFF),
	BREAKFALL_ST = C(GROUP_BUFF),
	KNOCK_UP_ST = C(GROUP_KNOCK),
	KNOCK_UP_START_LOOP_ST = C(GROUP_KNOCK),
	KNOCK_UP_END_ST = C(GROUP_KNOCK),
	KNOCK_BACK_ST = C(GROUP_KNOCK),
	DEAD_ST = C(GROUP_LIFE),
	FALLEN_ST = C(GROUP_LIFE),
	NEAR_DEAD_ST = C(GROUP_LIFE),
	FORCE_DISPLACEMENT_ST = S(),
	FORCE_DISPLACEMENT_NOT_BLOCK_INPUT_ST = S(),
	SKILL_AIM_ST = S(),
	IN_BALL_ST = S(),
	LEVEL_INTERACT_ST = S(),
	REBOUND_DASH_ST = S(),
	ABILITY_FOLLOW_TARGET_ST = S(),
	CAMOUFLAGE_ST = S(),
	SPECIAL_ATTACK_ST = S(),
	FAST_CARRY_EGG_ST = S(),
	BE_HUG_ENT_ST = S(),
	CONTROL_ENT_ST = S(),
	SOCIAL_INTERACT_ACTION_ST = S(),
	MULTI_INTERACT_ST = S(),
	HOME_INTERACT_ST = S(),
	FOGAREA_ST = S(),
	SPECIAL_DEFENSE_ST = S(),
	PLAY_SLOT_MACHINE_ST = S(),
	EXTRA_TEMP_PET_ST = S(),
	PET_PROTECTED_ST = S(),
	NOT_SUMMON_ST = S(),
	GM_OBSERVE_ST = S(),
	FALLEN_AID_ST = S(),
	FORCE_CONTROL_ST = S(),
	TMP_PET_TEAM_ST = S(),
	HUG_ENT_ST = S(),
	ABILITY_INDICATOR_SEL_POS_ST = S(),
	ABILITY_INDICATOR_AIM_ST = S(),
	ABILITY_INDICATOR_AIM_WALK_ST = S(),
	SCENT_TRACKING_ST = S(),
	TRIVIAL_ACTION_ST = S(),
	TRIVIAL_UPPER_ACTION_ST = S(),
	THORNS_HIT_ST = S(),
	FREEZE_HP_ST = S(),
	CHAIN_ATTACK_ST = S(),
	HIT_L_ST = S(),
	HIT_H_ST = S(),
	DUNGEON_MATCHING_ST = S(),
	DITTO_ENTER_ST = S(),
	MORPHLING_NO_ATTACK = S(),
	PEEP_ST = S(),
	APPEAR_DASH_ST = S(),
	MAGNESIS_READY_ST = S(),
	TE_PLOT_ST = S(),
	METAVERSE_ST = S(),
	ROGUE_ST = S(),
	ECO_HOME_ST = S(),
	SCENE_HOME_CAMP_ST = S(),
	SINGLEBOSS_ST = S(),
	FLYRIDE_ST = S(),
	TUTORIAL_NORMAL = S(),
	TUTORIAL_NOBATTLE = S(),
	TUTORIAL_BATTLE_ST = S(),
	TUTORIAL_BATTLE_ST_2 = S(),
	TUTORIAL_PLAYER_ST = S(),
	TUTORIAL_CALLPALS = S(),
	INFO_DISABLE_ST = S(),
	ATTACK_ST2 = S(),
	ATTACK_ST3 = S(),
	BE_FORCE_CONTROL_ST = S(),
	HORN_MATCHING_ST = S(),
	FLUTE_MATCHING_ST = S(),
	INFO_DISABLE_1_ST = S(),
	INFO_DISABLE_2_ST = S(),
	MULTIPLE_BATTLE_ST = S(),
	CATCH_TUTORIAL_1 = S(),
	CATCH_TUTORIAL_2 = S(),
	JUMP_DISABLE_ST = S(),
	CLIMB_DISABLE_ST = S(),
	CLIMB_DISABLE_ST2 = S(),
	GLIDE_DISABLE_ST = S(),
	CROUCH_DISABLE_ST = S(),
	DASH_SPRINT_DISABLE_ST = S(),
	NPCDUEL_STATE_1 = S(),
	REPAIR_GEAR_ST = S(),
	SHAPE_SHIFT_ST = S(),
	COMBAT_ST = S(),
	BURROW_ST = R(),
	BREAK_RECOVER_ST = R(),
	INTERACT_ST = R(),
	PVP_ST = R(),
	CARRY_EGG_ST = R(),
	SEGG_ST = R(),
	BEGG_ST = R(),
	CATCH_MODE_ST = R(),
	CONTROL_PET_ST = R(),
	CONTROL_EGG_ST = R(),
	EGG_MAN_ST = R(),
	PUSH_ST = R(),
	SKILL_MOTION_ST = R(),
	LIFT_ST = R(),
	EGG_BE_CARRIED_ST = R(),
	PLAY_ANIMATION_SCRIPT = R(),
	AFK_ST = R(),
	SOCIAL_ANIM_ST = R(),
	PAINT_AREA_CAM_ST = R(),
	FORCE_LOCK_CAMERA_ST = R(),
	NEXT_SKILL_ST = R(),
	AUTO_CAST_ST = R(),
	QTE_ST = R(),
	DIG_EGG_ST = R(),
	CUTSCENE_ST = R(),
	EXPLORE_DELAY_CANCEL_SWITCH_ST = R(),
	EXPLORE_SWITCH_ST = R(),
	BOSS_CAPTURE_ST = R(),
	PET_SPECIAL_VISION_ST = R(),
	CONTROLLING_PET_ST = R(),
	SWITCH_ANIM_ST = R(),
	CLIMB_ST = R(),
	GLIDE_ST = R(),
	SWIM_ST = R(),
	GAMEPLAY_PVP_PRE = R(),
	GAMEPLAY_PVP_ING = R(),
	BTPAUSEGM_ST = R(),
	CONDUCT_HIT_ST = R(),
	REVIVE_ST = R(),
	PATHFINDING_ST = R(),
	STORY_WALK_ST = R(),
	FALL_ST = R(),
	DASH_ST = R(),
	GROUND_ABILITY_ST = R(),
	HIDE_ST = R(),
	CHECK_ST = R(),
	WEAPON_ATTACH_ST = R(),
	HARVEST_ST = R()
}
local CACHEABLE_GROUPS = {
	GROUP_CHAR,
	GROUP_MASK,
	GROUP_BUFF,
	GROUP_KNOCK,
	GROUP_LIFE
}
local GROUP_STATES = {}
local CACHEABLE_SET = {}

do
	local enabled = {}

	for _, g in ipairs(CACHEABLE_GROUPS) do
		enabled[g] = true
		GROUP_STATES[g] = {}
	end

	for stat, info in pairs(STATE_CLASS) do
		if info.class == CACHEABLE then
			CACHEABLE_SET[stat] = true

			if info.group and enabled[info.group] then
				table.insert(GROUP_STATES[info.group], stat)
			end
		end
	end
end

local STATE_TO_BLOCK_EVENTS = {}
local EVENT_CACHEABLE_BLOCK = {}
local EVENT_REALTIME_BLOCK = {}
local EVENT_HAS_GROUP = {}

do
	local StateConflictData = require("Data.state_conflict_data")

	for event, tableData in pairs(StateConflictData) do
		if type(tableData) == "table" and (tableData.block or tableData.group) then
			local block = tableData.block

			if block then
				for _, stat in ipairs(block) do
					if CACHEABLE_SET[stat] then
						local evs = STATE_TO_BLOCK_EVENTS[stat]

						if not evs then
							evs = {}
							STATE_TO_BLOCK_EVENTS[stat] = evs
						end

						evs[#evs + 1] = event

						local cb = EVENT_CACHEABLE_BLOCK[event]

						if not cb then
							cb = {}
							EVENT_CACHEABLE_BLOCK[event] = cb
						end

						cb[#cb + 1] = stat
					else
						local rb = EVENT_REALTIME_BLOCK[event]

						if not rb then
							rb = {}
							EVENT_REALTIME_BLOCK[event] = rb
						end

						rb[#rb + 1] = stat
					end
				end
			end

			local group = tableData.group

			if group and #group > 0 then
				EVENT_HAS_GROUP[event] = true
			end
		end
	end

	local errorTable = {}

	for stateName, _ in pairs(StateConflictData.STATE_NAME_TABLE) do
		if STATE_CLASS[stateName] == nil then
			errorTable[stateName] = true
		end
	end

	local SkillConflictData = require("Data.skill_state_conflict_data")

	for stateName, _ in pairs(SkillConflictData.STATE_NAME_TABLE) do
		if STATE_CLASS[stateName] == nil then
			errorTable[stateName] = true
		end
	end

	if next(errorTable) and pg.component == "client" then
		local errorMsg = ""

		for stateName, _ in pairs(errorTable) do
			errorMsg = errorMsg .. stateName .. ","
		end

		errorMsg = errorMsg .. "这些状态需要在STATE_CLASS里面定义类型"

		local TimerManager = require("Core.Timer.TimerManager")

		TimerManager.addTimer(2, function()
			local ClientUtils = require("Utils.ClientUtils")

			ClientUtils.showConfirmRaw(pg.getGameString("WARNING"), errorMsg, nil, true)
		end)
	end
end

local StateClassify = {
	CACHEABLE = CACHEABLE,
	REALTIME = REALTIME,
	STATE_CLASS = STATE_CLASS,
	CACHEABLE_GROUPS = CACHEABLE_GROUPS,
	GROUP_STATES = GROUP_STATES,
	CACHEABLE_SET = CACHEABLE_SET,
	STATE_TO_BLOCK_EVENTS = STATE_TO_BLOCK_EVENTS,
	EVENT_CACHEABLE_BLOCK = EVENT_CACHEABLE_BLOCK,
	EVENT_REALTIME_BLOCK = EVENT_REALTIME_BLOCK,
	EVENT_HAS_GROUP = EVENT_HAS_GROUP
}

return StateClassify
