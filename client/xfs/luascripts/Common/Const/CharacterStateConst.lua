-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\CharacterStateConst.lua

local CharacterStateConst = require("Common.Const.CharacterStateConstImp")
local PlayableConst = require("Common.Const.PlayableConst")
local ToBool = ToBool
local MidStateMap = {
	GLIDESTART = true,
	LAND = true,
	HIDEMIMICRYOUT = true,
	HIDEMIMICRYIN = true,
	SWIMMIMICRYOUT = true,
	SWIMMIMICRYIN = true,
	MIMICRYOUT = true,
	MIMICRYIN = true,
	GROUNDOUT = true,
	GROUNDIN = true,
	FLYCHARGING = true,
	FLYRISE = true,
	SPECIALMOVEOUT = true,
	SPECIALMOVEIN = true,
	SNEAKOUTBYHIT = true,
	SNEAKIN = true,
	SNEAKOUT = true
}
local NeedResetAIStateMap = {
	"GLIDING",
	"CLIMBING"
}
local _parentIndex = setmetatable({}, {
	__index = function(tbl, index)
		local parentState = index % 1024
		local curState = (index - parentState) / 1024
		local result = false

		while curState and curState ~= 0 and CharacterStateConst[curState] do
			if curState == parentState then
				result = true

				break
			end

			curState = CharacterStateConst[curState].parent
		end

		rawset(tbl, index, result)

		return result
	end
})

function CharacterStateConst.isChildOfState(state, parentState)
	return state and parentState and _parentIndex[state * 1024 + parentState]
end

function CharacterStateConst.isDifferentSubState(oldState, newState, parentState)
	return CharacterStateConst.isChildOfState(oldState, parentState) ~= CharacterStateConst.isChildOfState(newState, parentState)
end

function CharacterStateConst.isFirstEnterState(oldState, newState, parentState)
	if CharacterStateConst.isChildOfState(newState, parentState) then
		return CharacterStateConst.isDifferentSubState(newState, oldState, parentState)
	end
end

function CharacterStateConst.isExploreState(state)
	if CharacterStateConst.isChildOfState(state, CharacterStateConst.SWIMMING) then
		return true
	end

	if CharacterStateConst.isChildOfState(state, CharacterStateConst.CLIMBING) then
		return true
	end

	if CharacterStateConst.isChildOfState(state, CharacterStateConst.GLIDING) then
		return true
	end

	return false
end

function CharacterStateConst.isJumpState(state)
	if CharacterStateConst.isChildOfState(state, CharacterStateConst.JUMP) then
		return true
	end

	if CharacterStateConst.isChildOfState(state, CharacterStateConst.SWIMJUMP) then
		return true
	end

	return false
end

function CharacterStateConst.getParentState(state)
	while state and state ~= 0 do
		if CharacterStateConst[state].parent == 0 then
			return state
		end

		state = CharacterStateConst[state].parent
	end
end

function CharacterStateConst.isChildState(state)
	return CharacterStateConst[state] and CharacterStateConst[state].parent ~= 0
end

function CharacterStateConst.isMidTransitionState(state)
	return MidStateMap[CharacterStateConst[state].name] or CharacterStateConst[state].parent == 0 and not CharacterStateConst[state].isStateMachine
end

function CharacterStateConst.checkNeedResetAIAgent(motionState)
	for _, tStateName in ipairs(NeedResetAIStateMap) do
		local tStateValue = CharacterStateConst[tStateName]

		if CharacterStateConst.isChildOfState(motionState, tStateValue) then
			return true
		end
	end

	return false
end

local MIMICRY_STATES = {
	[CharacterStateConst.MIMICRY] = true,
	[CharacterStateConst.MIMICRYIN] = true,
	[CharacterStateConst.MIMICRYOUT] = true,
	[CharacterStateConst.SWIMMIMICRY] = true,
	[CharacterStateConst.SWIMMIMICRYIN] = true,
	[CharacterStateConst.SWIMMIMICRYOUT] = true,
	[CharacterStateConst.HIDEMIMICRY] = true,
	[CharacterStateConst.HIDEMIMICRYIN] = true,
	[CharacterStateConst.HIDEMIMICRYOUT] = true
}

function CharacterStateConst.isMimicryState(characterState)
	return MIMICRY_STATES[characterState] == true or MIMICRY_STATES[CharacterStateConst.getParentState(characterState)] == true
end

local characterStateDefaultAnimation = {
	[CharacterStateConst.IDLE] = PlayableConst.Idle,
	[CharacterStateConst.WALK] = PlayableConst.Walk,
	[CharacterStateConst.RUN] = PlayableConst.RunLoop,
	[CharacterStateConst.SPRINT] = PlayableConst.SprintLoop,
	[CharacterStateConst.JUMP] = PlayableConst.Jump,
	[CharacterStateConst.FALL] = PlayableConst.FallLoop,
	[CharacterStateConst.LAND] = PlayableConst.FallToGroundL,
	[CharacterStateConst.FLYRISE] = PlayableConst.FlyRise,
	[CharacterStateConst.FLYCHARGING] = PlayableConst.FlyCharging,
	[CharacterStateConst.FLYMOVE] = PlayableConst.FlyMove,
	[CharacterStateConst.FLYHOVER] = PlayableConst.FlyHover,
	[CharacterStateConst.SWIMIDLE] = PlayableConst.Swim_Idle,
	[CharacterStateConst.SWIMMOVE] = PlayableConst.Swim_Move
}
local characterStateDefaultState = {
	[CharacterStateConst.LOCOMOTION] = CharacterStateConst.IDLE,
	[CharacterStateConst.SWIMMING] = CharacterStateConst.SWIMIDLE,
	[CharacterStateConst.AIRING] = CharacterStateConst.FALL,
	[CharacterStateConst.FLYING] = CharacterStateConst.FLYHOVER
}

function CharacterStateConst.getDefaultAnimation(characterState)
	return characterStateDefaultAnimation[characterState] or PlayableConst.Idle
end

function CharacterStateConst.getDefaultState(characterState)
	local parentState = CharacterStateConst.getParentState(characterState)

	return characterStateDefaultState[parentState] or CharacterStateConst.IDLE
end

local characterParentStateRPCMap = {
	[CharacterStateConst.SPEEDBURST] = false,
	[CharacterStateConst.FLYING] = false,
	[CharacterStateConst.TAKEROOT] = false,
	[CharacterStateConst.SNEAKIN] = false,
	[CharacterStateConst.SNEAKOUT] = false,
	[CharacterStateConst.SNEAKOUTBYHIT] = false,
	[CharacterStateConst.SNEAK] = false,
	[CharacterStateConst.SWIMMING] = false,
	[CharacterStateConst.CLIMBING] = false,
	[CharacterStateConst.GLIDING] = false
}

function CharacterStateConst.getRPCState(ent, state)
	if CharacterStateConst.isMimicryState(state) then
		return state
	end

	local dynamicRPCState = ent.dynamicRPCStateMap and ent.dynamicRPCStateMap[state]

	if dynamicRPCState then
		return state
	end

	local parentState = ToBool(CharacterStateConst[state].parent) and CharacterStateConst[state].parent or state

	if ent.dynamicParentRPCStateMap and ent.dynamicParentRPCStateMap[parentState] then
		return parentState
	end

	local syncChildState = characterParentStateRPCMap[parentState]

	if syncChildState == nil then
		return nil
	end

	return syncChildState and state or parentState
end

local MidStateMap2Transition = {
	[CharacterStateConst.GROUND] = {
		[CharacterStateConst.GROUNDIN] = true,
		[CharacterStateConst.GROUNDOUT] = true
	},
	[CharacterStateConst.MIMICRY] = {
		[CharacterStateConst.MIMICRYIN] = true,
		[CharacterStateConst.MIMICRYOUT] = true
	},
	[CharacterStateConst.SWIMMIMICRY] = {
		[CharacterStateConst.SWIMMIMICRYIN] = true,
		[CharacterStateConst.SWIMMIMICRYOUT] = true
	},
	[CharacterStateConst.HIDEMIMICRY] = {
		[CharacterStateConst.HIDEMIMICRYIN] = true,
		[CharacterStateConst.HIDEMIMICRYOUT] = true
	},
	[CharacterStateConst.SNEAK] = {
		[CharacterStateConst.SNEAKIN] = true,
		[CharacterStateConst.SNEAKOUT] = true,
		[CharacterStateConst.SNEAKOUTBYHIT] = true
	},
	[CharacterStateConst.SPECIALMOVE] = {
		[CharacterStateConst.SPECIALMOVEIN] = true,
		[CharacterStateConst.SPECIALMOVEOUT] = true
	}
}

function CharacterStateConst.isChildOrTransitionOfState(state, parentState)
	if MidStateMap2Transition[parentState] and MidStateMap2Transition[parentState][state] then
		return true
	end

	return CharacterStateConst.isChildOfState(state, parentState)
end

return CharacterStateConst
