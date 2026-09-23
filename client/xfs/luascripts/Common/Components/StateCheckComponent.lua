-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Components\\StateCheckComponent.lua

local class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Const = require("Common.Const.Const")
local DungeonConst = require("Common.Const.DungeonConst")
local AbilityConst = require("Common.Const.AbilityConst")
local CommonSwitch = require("Common.CommonSwitch")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local StateConflictData = require("Data.state_conflict_data")
local SkillConflictData = require("Data.skill_state_conflict_data")
local NoticeDef = require("Common.NoticeDef")
local SceneData = require("Data.scene_data")
local Utils = require("Common.Utils.Utils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local StateClassify = require("Common.Components.StateClassify")
local DUNGEON_STATUS = DungeonConst.STATUS
local STATE_GROUP_STATES = StateClassify.GROUP_STATES
local STATE_CACHEABLE_SET = StateClassify.CACHEABLE_SET
local STATE_TO_BLOCK_EVENTS = StateClassify.STATE_TO_BLOCK_EVENTS
local EVENT_CACHEABLE_BLOCK = StateClassify.EVENT_CACHEABLE_BLOCK
local EVENT_REALTIME_BLOCK = StateClassify.EVENT_REALTIME_BLOCK
local EVENT_HAS_GROUP = StateClassify.EVENT_HAS_GROUP
local isStateCacheOn = CommonSwitch.StateCheckCacheMode and pg.component == "client"
local MASK_TO_DIRECT = {
	[AbilityConst.ACTION_MASK_IN_SKILL] = "SKILL_ST",
	[AbilityConst.ACTION_MASK_IN_ATTACK] = "ATTACK_ST",
	[AbilityConst.ACTION_MASK_IN_HIT] = "HIT_ST",
	[AbilityConst.ACTION_MASK_IN_HIT_BACKSWING] = "HIT_BACKSWING_ST",
	[AbilityConst.ACTION_MASK_IN_CAST] = "CAST_ST",
	[AbilityConst.ACTION_MASK_CANCELLABLE] = "CANCELLABLE_ST",
	[AbilityConst.ACTION_MASK_IN_COMBO] = "COMBO_ST",
	[AbilityConst.ACTION_MASK_IN_BACKSWING] = "BACKSWING_ST",
	[AbilityConst.ACTION_MASK_KEY_FRAME_BACKSWING] = "KEY_FRAME_BACKSWING_ST"
}
local MASK_TO_DERIVED = {
	[AbilityConst.ACTION_MASK_IN_SKILL] = {
		"ABILITY_ST"
	},
	[AbilityConst.ACTION_MASK_IN_ATTACK] = {
		"ABILITY_ST"
	}
}
local TAG_TO_STATE = {
	[AbilityConst.BUFF_TAG_CHARM] = "CHARM_ST",
	[AbilityConst.BUFF_TAG_STUN] = "STUN_ST",
	[AbilityConst.BUFF_TAG_FROZEN] = "FROZEN_ST",
	[AbilityConst.BUFF_TAG_SLEEP] = "SLEEP_ST",
	[AbilityConst.BUFF_TAG_PALSY] = "PALSY_ST",
	[AbilityConst.BUFF_TAG_SILENT] = "SILENT_ST",
	[AbilityConst.BUFF_TAG_CLOUD_CONFINE] = "CLOUD_CONFINE_ST",
	[AbilityConst.BUFF_TAG_BREAK] = "BREAK_ST",
	[AbilityConst.BUFF_TAG_BREAK_FALL] = "BREAKFALL_ST"
}
local KNOCK_STATE_BACK = AbilityConst.KNOCK_STATE_BACK
local KNOCK_STATE_UP_START = AbilityConst.KNOCK_STATE_UP_START
local KNOCK_STATE_UP_LOOP = AbilityConst.KNOCK_STATE_UP_LOOP
local KNOCK_STATE_UP_END = AbilityConst.KNOCK_STATE_UP_END
local LIFE_DEAD = Const.LIFE_DEAD
local LIFE_FALLEN = Const.LIFE_FALLEN
local LIFE_NEAR_DEAD = Const.LIFE_NEAR_DEAD
local CS_DEAD = CharacterStateConst.DEAD
local CS = CharacterStateConst
local CHAR_STATE_DESC = {
	CLIMB_ACROSS_ST = {
		kind = "childOf",
		parent = CS.CLIMBACROSS
	},
	CROUCH_ST = {
		kind = "childOf",
		parent = CS.CROUCHING
	},
	FLY_ST = {
		kind = "childOf",
		parent = CS.FLYING
	},
	FOUR_WAY_MOVE_ST = {
		kind = "childOf",
		parent = CS.FOURWAY
	},
	WALKING_ATTACK_ST = {
		kind = "childOf",
		parent = CS.WALKINGATTACK
	},
	SPEED_BURST_ST = {
		kind = "childOf",
		parent = CS.SPEEDBURST
	},
	HOOK_SPRINT_ST = {
		kind = "childOf",
		parent = CS.HOOKSPRINT
	},
	SKATEBOARD_ST = {
		kind = "childOf",
		parent = CS.SKATEBOARD
	},
	FIRST_AID_ST = {
		kind = "childOf",
		parent = CS.AID
	},
	PLAY_ANIMATION_SCRIPT_ST = {
		kind = "childOf",
		parent = CS.PLAYANIMATIONSCRIPT
	},
	MAGNESIS_ST = {
		kind = "childOf",
		parent = CS.MAGNESIS
	},
	LATERAL_ATTACK_ST = {
		kind = "childOf",
		parent = CS.LATERALATTACK
	},
	STATICSPAWN_ST = {
		kind = "childOf",
		parent = CS.STATICSPAWN
	},
	SKILL_GLIDING_ST = {
		kind = "equalSet",
		set = {
			[CS.SKILLGLIDING] = true
		}
	},
	FLY_CHARGING_ST = {
		kind = "equalSet",
		set = {
			[CS.FLYCHARGING] = true
		}
	},
	TAKE_ROOT_ST = {
		kind = "equalSet",
		set = {
			[CS.TAKEROOT] = true
		}
	},
	TAKE_ROOT_IN_ST = {
		kind = "equalSet",
		set = {
			[CS.TAKEROOTIN] = true
		}
	},
	STRUGGLE_ST = {
		kind = "equalSet",
		set = {
			[CS.STRUGGLE] = true
		}
	},
	MOVE_STOP_ST = {
		kind = "equalSet",
		set = {
			[CS.RUNSTOP] = true,
			[CS.SPRINTSTOP] = true
		}
	},
	MAGNESIS_THROW_ST = {
		kind = "equalSet",
		set = {
			[CS.MAGNESISTHROW] = true
		}
	},
	MAGNESIS_GRABBING_ST = {
		kind = "equalSet",
		set = {
			[CS.MAGNESISGRABIDLE] = true,
			[CS.MAGNESISGRABWALK] = true
		}
	},
	SPRINT_ST = {
		kind = "raw"
	},
	MIMICRY_ST = {
		kind = "raw"
	},
	SPECIAL_RIDE_BOSS_ST = {
		kind = "raw"
	},
	RIDING_ST = {
		kind = "raw"
	}
}
local CHAR_CHILDOF_BY_PARENT = {}
local CHAR_NON_CHILDOF = {}
local CHAR_DESC_PROBLEMS = {}

for stat, desc in pairs(CHAR_STATE_DESC) do
	if desc.kind == "childOf" then
		if desc.parent == nil then
			CHAR_DESC_PROBLEMS[#CHAR_DESC_PROBLEMS + 1] = string.format("[char-desc] %s 的 childOf parent 为 nil", stat)
		elseif CS.getParentState(desc.parent) ~= desc.parent then
			CHAR_DESC_PROBLEMS[#CHAR_DESC_PROBLEMS + 1] = string.format("[char-desc] %s 的 childOf parent=%s 非顶层状态（getParentState=%s），分桶短路会漏刷，应改用 equalSet/raw 或修正 parent", stat, tostring(desc.parent), tostring(CS.getParentState(desc.parent)))
		end

		local bucket = CHAR_CHILDOF_BY_PARENT[desc.parent]

		if not bucket then
			bucket = {}
			CHAR_CHILDOF_BY_PARENT[desc.parent] = bucket
		end

		bucket[#bucket + 1] = stat
	else
		CHAR_NON_CHILDOF[#CHAR_NON_CHILDOF + 1] = {
			stat = stat,
			desc = desc
		}
	end
end

local StateCheckComponent = class.Component("StateCheckComponent")

function StateCheckComponent:ctor()
	self.cancelFuns = {}
	self.checkCancelFuns = {}
	self.specialStateBanOperate = nil
	self.customCheckStates = {}
	self.stateCache = {}
	self.eventBlockCount = {}
	self.eventBlockCacheReady = {}
end

function StateCheckComponent:onEnterSpace()
	if self.space then
		self.specialStateBanOperate = SceneData[self.space.sceneId].specialStateBanOperate
	end

	if isStateCacheOn then
		self:updateStateCache("METAVERSE_ST")
		self:updateStateCache("ROGUE_ST")
		self:updateStateCache("ECO_HOME_ST")
		self:updateStateCache("SCENE_HOME_CAMP_ST")
		self:updateStateCache("SINGLEBOSS_ST")
		self:updateStateCache("FLYRIDE_ST")
		self:updateStateCache("TUTORIAL_NORMAL")
		self:updateStateCache("TUTORIAL_NOBATTLE")
		self:updateStateCache("TUTORIAL_BATTLE_ST")
		self:updateStateCache("TUTORIAL_BATTLE_ST_2")
		self:updateStateCache("TUTORIAL_PLAYER_ST")
		self:updateStateCache("TUTORIAL_CALLPALS")
		self:updateStateCache("INFO_DISABLE_ST")
		self:updateStateCache("ATTACK_ST2")
		self:updateStateCache("ATTACK_ST3")
		self:updateStateCache("BE_FORCE_CONTROL_ST")
		self:updateStateCache("HORN_MATCHING_ST")
		self:updateStateCache("FLUTE_MATCHING_ST")
		self:updateStateCache("INFO_DISABLE_1_ST")
		self:updateStateCache("INFO_DISABLE_2_ST")
		self:updateStateCache("MULTIPLE_BATTLE_ST")
		self:updateStateCache("CATCH_TUTORIAL_1")
		self:updateStateCache("CATCH_TUTORIAL_2")
		self:updateStateCache("JUMP_DISABLE_ST")
		self:updateStateCache("CLIMB_DISABLE_ST")
		self:updateStateCache("CLIMB_DISABLE_ST2")
		self:updateStateCache("GLIDE_DISABLE_ST")
		self:updateStateCache("CROUCH_DISABLE_ST")
		self:updateStateCache("DASH_SPRINT_DISABLE_ST")
		self:updateStateCache("NPCDUEL_STATE_1")
		self:updateStateCache("REPAIR_GEAR_ST")
	end
end

function StateCheckComponent:onLeaveSpace()
	self.specialStateBanOperate = nil

	if isStateCacheOn then
		self:setStateCacheValue("METAVERSE_ST", false)
		self:setStateCacheValue("ROGUE_ST", false)
		self:setStateCacheValue("ECO_HOME_ST", false)
		self:setStateCacheValue("SCENE_HOME_CAMP_ST", false)
		self:setStateCacheValue("SINGLEBOSS_ST", false)
		self:setStateCacheValue("FLYRIDE_ST", false)
		self:setStateCacheValue("TUTORIAL_NORMAL", false)
		self:setStateCacheValue("TUTORIAL_NOBATTLE", false)
		self:setStateCacheValue("TUTORIAL_BATTLE_ST", false)
		self:setStateCacheValue("TUTORIAL_BATTLE_ST_2", false)
		self:setStateCacheValue("TUTORIAL_PLAYER_ST", false)
		self:setStateCacheValue("TUTORIAL_CALLPALS", false)
		self:setStateCacheValue("INFO_DISABLE_ST", false)
	end
end

function StateCheckComponent:checkStatus(event, showMsg, exclude, noCancel, excludeCancel, refRetTable)
	if self:checkStatus_check(event, showMsg, exclude, refRetTable) then
		return self:checkStatus_cancel(event, excludeCancel, noCancel)
	end

	return false
end

function StateCheckComponent:rawCheckInState(stat)
	local func = self[stat]

	if func ~= nil and func(self) then
		return true
	end

	return Utils.hasEntityTag(self, stat) or self:checkScene(stat) or false
end

function StateCheckComponent:checkInState(stat)
	if not stat then
		return false
	end

	return self:checkInStateEx(stat)
end

function StateCheckComponent:checkInStateEx(stat)
	if isStateCacheOn and STATE_CACHEABLE_SET[stat] then
		local cache = self.stateCache
		local cached = cache[stat]

		if cached ~= nil then
			return cached
		end

		local value = self:rawCheckInState(stat)

		self:_writeStateCache(cache, stat, value)

		return value
	end

	return self:rawCheckInState(stat)
end

function StateCheckComponent:_writeStateCache(cache, stat, v)
	v = v and true or false

	local oldBlocking = cache[stat] == true

	cache[stat] = v

	if oldBlocking == v then
		return
	end

	local events = STATE_TO_BLOCK_EVENTS[stat]

	if not events then
		return
	end

	local counts = self.eventBlockCount

	if v then
		for i = 1, #events do
			local e = events[i]

			counts[e] = (counts[e] or 0) + 1
		end
	else
		for i = 1, #events do
			local e = events[i]
			local c = counts[e]

			if c then
				counts[e] = c - 1
			end
		end
	end
end

function StateCheckComponent:refreshStateGroup(group)
	if not isStateCacheOn then
		return
	end

	local list = STATE_GROUP_STATES[group]

	if not list then
		return
	end

	local cache = self.stateCache

	for i = 1, #list do
		local stat = list[i]

		self:_writeStateCache(cache, stat, self:rawCheckInState(stat))
	end
end

function StateCheckComponent:refreshKnockGroup(ks)
	if not isStateCacheOn then
		return
	end

	local cache = self.stateCache

	self:_writeStateCache(cache, "KNOCK_UP_ST", ks > KNOCK_STATE_BACK)
	self:_writeStateCache(cache, "KNOCK_UP_START_LOOP_ST", ks == KNOCK_STATE_UP_START or ks == KNOCK_STATE_UP_LOOP)
	self:_writeStateCache(cache, "KNOCK_UP_END_ST", ks == KNOCK_STATE_UP_END)
	self:_writeStateCache(cache, "KNOCK_BACK_ST", ks == KNOCK_STATE_BACK)
end

function StateCheckComponent:refreshLifeGroup(life)
	if not isStateCacheOn then
		return
	end

	local cache = self.stateCache

	self:_writeStateCache(cache, "FALLEN_ST", life == LIFE_FALLEN)
	self:_writeStateCache(cache, "NEAR_DEAD_ST", life == LIFE_NEAR_DEAD)
	self:_writeStateCache(cache, "DEAD_ST", life == LIFE_DEAD or self.characterState == CS_DEAD)
end

function StateCheckComponent:refreshMaskByChange(mask, value)
	if not isStateCacheOn then
		return
	end

	local cache = self.stateCache
	local direct = MASK_TO_DIRECT[mask]

	if direct then
		self:_writeStateCache(cache, direct, value)
	end

	local derived = MASK_TO_DERIVED[mask]

	if derived then
		for i = 1, #derived do
			self:_writeStateCache(cache, derived[i], self:rawCheckInState(derived[i]))
		end
	end

	self:_writeStateCache(cache, "ULTIMATE_CAST_ST", self:rawCheckInState("ULTIMATE_CAST_ST"))
end

function StateCheckComponent:refreshBuffByChange(changelist, isAdd)
	if not isStateCacheOn then
		return
	end

	local cache = self.stateCache
	local v = isAdd and true or false

	for i = 1, #changelist do
		local stat = TAG_TO_STATE[changelist[i]]

		if stat then
			self:_writeStateCache(cache, stat, v)
		end
	end
end

function StateCheckComponent:refreshCharGroup(oldState, newState)
	if not isStateCacheOn then
		return
	end

	local cache = self.stateCache
	local cs = self.characterState
	local np = CS.getParentState(newState)

	self:_refreshCharChildOfBucket(cache, cs, np)

	if oldState then
		local op = CS.getParentState(oldState)

		if op ~= np then
			self:_refreshCharChildOfBucket(cache, cs, op)
		end
	end

	for i = 1, #CHAR_NON_CHILDOF do
		local item = CHAR_NON_CHILDOF[i]
		local desc = item.desc

		if desc.kind == "equalSet" then
			self:_writeStateCache(cache, item.stat, desc.set[cs] == true)
		else
			self:_writeStateCache(cache, item.stat, self:rawCheckInState(item.stat))
		end
	end
end

function StateCheckComponent:_refreshCharChildOfBucket(cache, cs, parent)
	local bucket = parent and CHAR_CHILDOF_BY_PARENT[parent]

	if not bucket then
		return
	end

	for i = 1, #bucket do
		local stat = bucket[i]

		self:_writeStateCache(cache, stat, CS.isChildOfState(cs, CHAR_STATE_DESC[stat].parent))
	end
end

function StateCheckComponent:updateStateCache(stat)
	if not isStateCacheOn then
		return
	end

	if not STATE_CACHEABLE_SET[stat] then
		return
	end

	self:_writeStateCache(self.stateCache, stat, self:rawCheckInState(stat))
end

function StateCheckComponent:setStateCacheValue(stat, value)
	if not isStateCacheOn then
		return
	end

	if not STATE_CACHEABLE_SET[stat] then
		return
	end

	self:_writeStateCache(self.stateCache, stat, value)
end

function StateCheckComponent:_ensureEventBlockCacheReady(event)
	local ready = self.eventBlockCacheReady

	if ready[event] then
		return
	end

	local block = EVENT_CACHEABLE_BLOCK[event]

	if block then
		local cache = self.stateCache

		for i = 1, #block do
			local stat = block[i]

			if cache[stat] == nil then
				self:_writeStateCache(cache, stat, self:rawCheckInState(stat))
			end
		end
	end

	ready[event] = true
end

function StateCheckComponent:clearStateCache()
	self.stateCache = {}
	self.eventBlockCount = {}
	self.eventBlockCacheReady = {}
end

function StateCheckComponent:getCharDescProblems()
	return CHAR_DESC_PROBLEMS
end

function StateCheckComponent:_checkInState(event, stat, showLog, stateTable, refRetTable)
	if self:checkInStateEx(stat) then
		if showLog and stateTable.CMD_NAME_TABLE[event] and stateTable.STATE_NAME_TABLE[stat] then
			local eventName, isShowEvent = unpack(stateTable.CMD_NAME_TABLE[event])
			local stateName, isShowState = unpack(stateTable.STATE_NAME_TABLE[stat])

			if isShowEvent == 1 and isShowState == 1 then
				if pg.component == "game" and self.sendNotice then
					self:sendNotice(NoticeDef.STATE_CONFLICT_MSG, {
						stateName,
						eventName
					})
				elseif pg.component == "client" and self.showBubbleMessage then
					self:showBubbleMessage(NoticeDef.STATE_CONFLICT_MSG, pg.getGameString("SC_" .. stat), pg.getGameString("SC_" .. event))
				end
			end
		end

		if refRetTable then
			refRetTable.stat = stat
		end

		return true
	end

	return false
end

function StateCheckComponent:checkStatus_check(event, showMsg, exclude, refRetTable)
	local tableData = StateConflictData[event]

	if tableData == nil then
		return true
	end

	if isStateCacheOn then
		self:_ensureEventBlockCacheReady(event)

		if self:_isBlockedFast(event, exclude) then
			if showMsg or refRetTable then
				return self:_checkStatusFull(event, tableData, showMsg, exclude, refRetTable)
			end

			if LoggerManager.checkLogger(LoggerConst.DEBUG) and CommonSwitch.StateCheckDebugLog then
				self.logger:debug("checkStatus_check fast blocked", event)
			end

			return false
		end

		if EVENT_HAS_GROUP[event] then
			return self:_checkGroupOnly(event, tableData, showMsg, exclude)
		end

		return true
	end

	return self:_checkStatusFull(event, tableData, showMsg, exclude, refRetTable)
end

function StateCheckComponent:_isBlockedFast(event, exclude)
	if not exclude or not next(exclude) then
		if (self.eventBlockCount[event] or 0) > 0 then
			return true
		end
	else
		local cb = EVENT_CACHEABLE_BLOCK[event]

		if cb then
			local cache = self.stateCache

			for i = 1, #cb do
				local stat = cb[i]

				if cache[stat] and exclude[stat] == nil then
					return true
				end
			end
		end
	end

	local rb = EVENT_REALTIME_BLOCK[event]

	if rb then
		for i = 1, #rb do
			local stat = rb[i]

			if (not exclude or exclude[stat] == nil) and self:rawCheckInState(stat) then
				return true
			end
		end
	end

	return false
end

function StateCheckComponent:_checkGroupOnly(event, tableData, showMsg, exclude)
	local group = tableData.group

	if group then
		for _, stat in ipairs(group) do
			if (not exclude or exclude[stat] == nil) and self:_checkInState(event, stat, showMsg, StateConflictData) and not self:checkStatus_check_group(event, stat, exclude) then
				return false
			end
		end
	end

	return true
end

function StateCheckComponent:_checkStatusFull(event, tableData, showMsg, exclude, refRetTable)
	local block = tableData.block
	local group = tableData.group

	if block then
		for _, stat in ipairs(block) do
			if (not exclude or exclude[stat] == nil) and self:_checkInState(event, stat, showMsg, StateConflictData, refRetTable, exclude) then
				if LoggerManager.checkLogger(LoggerConst.DEBUG) and CommonSwitch.StateCheckDebugLog then
					self.logger:debug("checkStatus_check failed", event, stat)
				end

				return false
			end
		end
	end

	if group then
		for _, stat in ipairs(group) do
			if (not exclude or exclude[stat] == nil) and self:_checkInState(event, stat, showMsg, StateConflictData) and not self:checkStatus_check_group(event, stat, exclude, showMsg) then
				return false
			end
		end
	end

	return true
end

function StateCheckComponent:checkStatus_check_group(event, parentState, exclude, showMsg)
	local groupTable = SkillConflictData
	local table = groupTable[event]

	if Utils.tableIsEmptyOrNil(table) then
		return true
	end

	local block = table.block

	if block then
		for _, stat in ipairs(block) do
			if not exclude or exclude[stat] == nil then
				local func = self[stat]

				if func ~= nil and func(self, parentState) then
					if showMsg and groupTable.CMD_NAME_TABLE[event] and groupTable.STATE_NAME_TABLE[stat] and LoggerManager.checkLogger(LoggerConst.DEBUG) then
						self.logger:log2Tag("LuaVerbose", "checkStatus_check_group failed", stat, event)
					end

					return false
				end
			end
		end
	end

	return true
end

function StateCheckComponent:checkStatus_canCancel(event, cancel, group, exclude)
	if cancel then
		for _, stat in ipairs(cancel) do
			if not exclude or exclude[stat] == nil then
				local func = self:getCheckCancelMethod(stat)

				if func ~= nil and self:_checkInState(event, stat, false, StateConflictData) and not func(self, event) then
					return false
				end
			end
		end
	end

	if group then
		for _, stat in ipairs(group) do
			if self:_checkInState(event, stat, false, StateConflictData) and not self:checkStatus_canCancel_group(event, stat, exclude) then
				return false
			end
		end
	end

	return true
end

function StateCheckComponent:checkStatus_canCancel_group(event, parentState, exclude)
	local groupTable = SkillConflictData
	local table = groupTable[event]

	if Utils.tableIsEmptyOrNil(table) then
		return true
	end

	local cancel = table.cancel

	if cancel then
		for _, stat in ipairs(cancel) do
			if not exclude or exclude[stat] == nil then
				local func = self:getCheckCancelMethod(stat)

				if func ~= nil and self:_checkInState(event, stat, false, StateConflictData) and not func(self, event, parentState) then
					return false
				end
			end
		end
	end

	return true
end

function StateCheckComponent:getCheckCancelMethod(stName)
	local func = self.checkCancelFuns[stName]

	if func then
		return func
	else
		func = "check_cancel_" .. stName
		self.checkCancelFuns[stName] = self[func]

		return self.checkCancelFuns[stName]
	end
end

function StateCheckComponent:checkStatus_cancel(event, exclude, noCancel)
	local table = StateConflictData[event]

	if table == nil then
		return true
	end

	local cancel = table.cancel
	local group = table.group

	if not self:checkStatus_canCancel(event, cancel, group, exclude) then
		return false
	end

	if not noCancel then
		if cancel then
			for _, stat in ipairs(cancel) do
				if not exclude or exclude[stat] == nil then
					local func = self:getCancelMethod(stat)

					if func ~= nil then
						func(self, event)
					end
				end
			end
		end

		if group then
			for _, stat in ipairs(group) do
				if self:_checkInState(event, stat, false, StateConflictData) then
					self:checkStatus_cancel_group(event, stat, exclude)
				end
			end
		end
	end

	return true
end

function StateCheckComponent:checkStatus_cancel_group(event, parentState, exclude)
	local groupTable = SkillConflictData
	local table = groupTable[event]

	if Utils.tableIsEmptyOrNil(table) then
		return
	end

	local cancel = table.cancel

	if cancel then
		for _, stat in ipairs(cancel) do
			if not exclude or exclude[stat] == nil then
				local func = self:getCancelMethod(stat)

				if func ~= nil then
					func(self, event, parentState)
				end
			end
		end
	end
end

function StateCheckComponent:getCancelMethod(stName)
	local func = self.cancelFuns[stName]

	if func then
		return func
	else
		func = "_cancel_" .. stName
		self.cancelFuns[stName] = self[func]

		return self.cancelFuns[stName]
	end
end

function StateCheckComponent:COMBAT_ST()
	return self.isInCombat ~= nil and self:isInCombat()
end

function StateCheckComponent:ABILITY_ST()
	return self:SKILL_ST() or self:ATTACK_ST()
end

function StateCheckComponent:SKILL_ST()
	return self.getActionMask ~= nil and self:getActionMask(AbilityConst.ACTION_MASK_IN_SKILL)
end

function StateCheckComponent:ATTACK_ST()
	return self.getActionMask ~= nil and self:getActionMask(AbilityConst.ACTION_MASK_IN_ATTACK)
end

function StateCheckComponent:HIT_ST()
	return self.getActionMask ~= nil and self:getActionMask(AbilityConst.ACTION_MASK_IN_HIT)
end

function StateCheckComponent:HIT_BACKSWING_ST()
	return self.getActionMask ~= nil and self:getActionMask(AbilityConst.ACTION_MASK_IN_HIT_BACKSWING)
end

function StateCheckComponent:KEY_FRAME_BACKSWING_ST()
	return self.getActionMask ~= nil and self:getActionMask(AbilityConst.ACTION_MASK_KEY_FRAME_BACKSWING)
end

function StateCheckComponent:CAST_ST(parentState)
	return self.getActionMask ~= nil and self:getActionMask(AbilityConst.ACTION_MASK_IN_CAST)
end

function StateCheckComponent:ULTIMATE_CAST_ST(parentState)
	if not self:CAST_ST() then
		return false
	end

	local abilityId = self.getCastingAbilityId and self:getCastingAbilityId() or 0

	if abilityId == 0 then
		return false
	end

	return AbilityUtils.isUltimateAbility(abilityId)
end

function StateCheckComponent:CANCELLABLE_ST()
	return self.getActionMask ~= nil and self:getActionMask(AbilityConst.ACTION_MASK_CANCELLABLE)
end

function StateCheckComponent:COMBO_ST(parentState)
	return self.getActionMask ~= nil and self:getActionMask(AbilityConst.ACTION_MASK_IN_COMBO)
end

function StateCheckComponent:BACKSWING_ST(parentState)
	return self.getActionMask ~= nil and self:getActionMask(AbilityConst.ACTION_MASK_IN_BACKSWING)
end

function StateCheckComponent:BREAK_ST(parentState)
	return self.inBreak and self:inBreak() or false
end

function StateCheckComponent:BREAKFALL_ST(parentState)
	return self.inBreakFall and self:inBreakFall() or false
end

function StateCheckComponent:BREAK_RECOVER_ST()
	return self.inBreakRecover and self:inBreakRecover() or false
end

function StateCheckComponent:CHARM_ST(parentState)
	return self.actorBuff and self.actorBuff.hasTag and self.actorBuff:hasTag(AbilityConst.BUFF_TAG_CHARM) or false
end

function StateCheckComponent:STUN_ST()
	return self.actorBuff and self.actorBuff.hasTag and self.actorBuff:hasTag(AbilityConst.BUFF_TAG_STUN) or false
end

function StateCheckComponent:FROZEN_ST()
	return self.actorBuff and self.actorBuff.hasTag and self.actorBuff:hasTag(AbilityConst.BUFF_TAG_FROZEN) or false
end

function StateCheckComponent:SLEEP_ST()
	return self.actorBuff and self.actorBuff.hasTag and self.actorBuff:hasTag(AbilityConst.BUFF_TAG_SLEEP) or false
end

function StateCheckComponent:PALSY_ST()
	return self.actorBuff and self.actorBuff.hasTag and self.actorBuff:hasTag(AbilityConst.BUFF_TAG_PALSY) or false
end

function StateCheckComponent:KNOCK_UP_ST()
	return self.inKnockUp and self:inKnockUp() or false
end

function StateCheckComponent:KNOCK_UP_START_LOOP_ST()
	return self.inKnockUpStartLoop and self:inKnockUpStartLoop() or false
end

function StateCheckComponent:KNOCK_UP_END_ST()
	return self.inKnockUpEnd and self:inKnockUpEnd() or false
end

function StateCheckComponent:KNOCK_BACK_ST()
	return self.inKnockBack and self:inKnockBack() or false
end

function StateCheckComponent:SWIM_ST()
	local characterState = self.characterState

	if Utils.isPlayer(self) and self.isControllingPet and self:isControllingPet() then
		local pet = self.getCurPetEntity and self:getCurPetEntity()

		if pet then
			characterState = pet.characterState
		end
	end

	return CharacterStateConst.isChildOfState(characterState, CharacterStateConst.SWIMMING)
end

function StateCheckComponent:LIFT_ST()
	return self.isInLiftState and self:isInLiftState()
end

function StateCheckComponent:_cancel_LIFT_ST(event)
	if not self.isInLiftState or not self:isInLiftState() then
		return
	end

	if self.unLiftEntity then
		self:unLiftEntity(true)
	elseif self.liftEntity then
		self:liftEntity(nil)
	end
end

function StateCheckComponent:INTERACT_ST()
	return self.interactAction and self.interactAction.interactId ~= 0
end

function StateCheckComponent:MULTI_INTERACT_ST()
	return self.interactLevelItemPrototypeId and self.interactLevelItemPrototypeId ~= 0
end

function StateCheckComponent:HOME_INTERACT_ST()
	return self.interactHomePrototypeId and self.interactHomePrototypeId ~= 0
end

function StateCheckComponent:DEAD_ST()
	return self.isDead and self:isDead() or self.characterState == CharacterStateConst.DEAD
end

function StateCheckComponent:FAKE_DEAD_ST()
	return self.isFakeDead and self:isFakeDead() or self.isFakeDeadCanHit and self:isFakeDeadCanHit() or false
end

function StateCheckComponent:SKILL_AIM_ST()
	return self.inSkillAim
end

function StateCheckComponent:CONTROL_PET_ST()
	return self.isControllingPet and self:isControllingPet()
end

function StateCheckComponent:CONTROL_EGG_ST()
	return self.isControllingEgg and self:isControllingEgg()
end

function StateCheckComponent:EGG_BE_CARRIED_ST()
	if self:CONTROL_EGG_ST() then
		local controllingEgg = self.getCurControllingEgg and self:getCurControllingEgg()

		return controllingEgg and not string.isNilOrEmpty(controllingEgg.attachTargetId)
	end

	return false
end

function StateCheckComponent:FREEZE_HP_ST()
	return self.actorBuff and self.actorBuff.findOneBuffByTemplateId and self.actorBuff:findOneBuffByTemplateId(AbilityConst.BUFF_BUBBLE_FREEZE_HP_ID) ~= nil or false
end

function StateCheckComponent:GAMEPLAY_PVP_PRE()
	local space = self.space

	if space and space.isPvpEnv and space:isPvpEnv() then
		return space.status <= DUNGEON_STATUS.COUNT_DONW
	end

	return false
end

function StateCheckComponent:GAMEPLAY_PVP_ING()
	local space = self.space

	if space and space.isPvpEnv and space:isPvpEnv() then
		return space.status <= DUNGEON_STATUS.COUNT_DONW
	end

	return false
end

function StateCheckComponent:FORCE_CONTROL_ST()
	return self.forceControl
end

function StateCheckComponent:TMP_PET_TEAM_ST()
	return self.petTeamType ~= Const.PET_TEAM_TYPE_DEFAULT
end

function StateCheckComponent:SILENT_ST()
	return self.actorBuff and self.actorBuff.hasTag and self.actorBuff:hasTag(AbilityConst.BUFF_TAG_SILENT) or false
end

function StateCheckComponent:MIMICRY_ST()
	return CharacterStateConst.isMimicryState(self.characterState)
end

function StateCheckComponent:FLY_ST()
	return CharacterStateConst.isChildOfState(self.characterState, CharacterStateConst.FLYING)
end

function StateCheckComponent:FLY_CHARGING_ST()
	return self.characterState == CharacterStateConst.FLYCHARGING
end

function StateCheckComponent:BURROW_ST()
	if self.characterState == CharacterStateConst.SNEAKIN and self.considerAsBurrowST then
		return true
	end

	return CharacterStateConst.isChildOfState(self.characterState, CharacterStateConst.SNEAK)
end

function StateCheckComponent:TAKE_ROOT_ST()
	return self.characterState == CharacterStateConst.TAKEROOT
end

function StateCheckComponent:TAKE_ROOT_IN_ST()
	return self.characterState == CharacterStateConst.TAKEROOTIN
end

function StateCheckComponent:CHECK_ST(state)
	return CharacterStateConst.isChildOfState(self.characterState, state)
end

function StateCheckComponent:PVP_ST()
	return self.space and self.space.isPvpEnv and self.space:isPvpEnv() or false
end

function StateCheckComponent:BTPAUSEGM_ST()
	if self.AI then
		return self.AI.gmPause
	end

	return false
end

function StateCheckComponent:FOUR_WAY_MOVE_ST()
	return CharacterStateConst.isChildOfState(self.characterState, CharacterStateConst.FOURWAY)
end

function StateCheckComponent:WALKING_ATTACK_ST()
	return CharacterStateConst.isChildOfState(self.characterState, CharacterStateConst.WALKINGATTACK)
end

function StateCheckComponent:SPEED_BURST_ST()
	return CharacterStateConst.isChildOfState(self.characterState, CharacterStateConst.SPEEDBURST)
end

function StateCheckComponent:SKILL_GLIDING_ST()
	return self.characterState == CharacterStateConst.SKILLGLIDING
end

function StateCheckComponent:HUG_ENT_ST()
	return not string.isNilOrEmpty(self.carryObjId)
end

function StateCheckComponent:BE_HUG_ENT_ST()
	return not string.isNilOrEmpty(self.moveUser)
end

function StateCheckComponent:STORY_WALK_ST()
	local eModel = self.eModel

	if not eModel then
		return false
	end

	return eModel.InPerformanceWalk or false
end

function StateCheckComponent:NOT_SUMMON_ST()
	if Utils.isPet(self) then
		return not self.isSummon
	end

	return false
end

function StateCheckComponent:SKATEBOARD_ST()
	return CharacterStateConst.isChildOfState(self.characterState, CharacterStateConst.SKATEBOARD)
end

function StateCheckComponent:SKILL_MOTION_ST()
	return CharacterStateConst.isChildOfState(self.characterState, CharacterStateConst.SKILLMOTION) or self:SKATEBOARD_ST() or self:SKILL_GLIDING_ST() or self.moveByInputData ~= nil
end

function StateCheckComponent:HOOK_SPRINT_ST()
	return CharacterStateConst.isChildOfState(self.characterState, CharacterStateConst.HOOKSPRINT)
end

function StateCheckComponent:checkScene(stat)
	return self.customCheckStates[stat] or self.specialStateBanOperate == stat
end

function StateCheckComponent:checkArkSceneState()
	return self.specialStateBanOperate == Const.ARK_STATE_NAME
end

function StateCheckComponent:checkKnockUpState()
	return self:checkStatus("KNOCK_UP")
end

function StateCheckComponent:SPECIAL_ATTACK_ST()
	return self.specialAttackModeData ~= nil
end

function StateCheckComponent:THORNS_HIT_ST()
	local baseTimeline = self.actorTimeline and self.actorTimeline.baseTimeline
	local baseParams = baseTimeline and baseTimeline.timelineParams
	local baseHitParams = baseParams and baseParams.hitParams

	if baseTimeline and baseTimeline.isPlaying and baseParams and baseParams.timelineKind == AbilityConst.TIMELINE_HIT and baseHitParams and baseHitParams.isFromThorns then
		return true
	end

	local additiveTimeline = self.actorTimeline and self.actorTimeline.additiveTimeline
	local additiveParams = additiveTimeline and additiveTimeline.timelineParams
	local additiveHitParams = additiveParams and additiveParams.hitParams

	if additiveTimeline and additiveTimeline.isPlaying and additiveParams and additiveParams.timelineKind == AbilityConst.TIMELINE_HIT and additiveHitParams and additiveHitParams.isFromThorns then
		return true
	end

	return false
end

function StateCheckComponent:CONDUCT_HIT_ST()
	if self.getGameTime and self.lastConductTime then
		return self:getGameTime() - self.lastConductTime < (AbilitySettingGlobalConstData.conductDuration or 2)
	end

	return false
end

function StateCheckComponent:CHAIN_ATTACK_ST()
	return false
end

function StateCheckComponent:CAMOUFLAGE_ST()
	return self.isCamouflage
end

function StateCheckComponent:SPECIAL_DEFENSE_ST()
	if self.isInSpecialDefense then
		return self.isInSpecialDefense
	end

	return false
end

function StateCheckComponent:CARRY_EGG_ST()
	return ToBool(self.carryEggId)
end

function StateCheckComponent:PLAY_SLOT_MACHINE_ST()
	return self.isPlayingSlotMachine
end

function StateCheckComponent:HARVEST_ST()
	return self.isHarvesting
end

function StateCheckComponent:SPECIAL_RIDE_BOSS_ST()
	return CharacterStateConst.isChildOfState(self.characterState, CharacterStateConst.SPECIALRIDE) and self.characterState ~= CharacterStateConst.SPECIALRIDEIDLE
end

function StateCheckComponent:FOGAREA_ST()
	return self.inFogArea
end

function StateCheckComponent:EXTRA_TEMP_PET_ST()
	return self.isUsingExtraTempPet
end

function StateCheckComponent:FALLEN_ST()
	return self.life == Const.LIFE_FALLEN
end

function StateCheckComponent:NEAR_DEAD_ST()
	return self.life == Const.LIFE_NEAR_DEAD
end

function StateCheckComponent:FALLEN_AID_ST()
	return self.fallenAidEndTime and self.fallenAidEndTime ~= 0
end

function StateCheckComponent:CLOUD_CONFINE_ST()
	return self.actorBuff and self.actorBuff.hasTag and self.actorBuff:hasTag(AbilityConst.BUFF_TAG_CLOUD_CONFINE) or false
end

function StateCheckComponent:GM_OBSERVE_ST()
	return self.gmMode == Const.OBSERVE_MODE
end

function StateCheckComponent:SHAPE_SHIFT_ST()
	return self.inShapeShift
end

return StateCheckComponent
