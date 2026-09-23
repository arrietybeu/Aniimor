-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\NpcDuelStateUtils.lua

local IntIntMap = require("CustomTypes.IntIntMap")
local NpcDuelData = require("Data.npc_duel_data")
local NpcDuelStateUtils = {}

NpcDuelStateUtils.State = {
	CANNOT_CHALLENGE = 0,
	FINISHED = 3,
	PARTIAL_PASSED = 2,
	CAN_CHALLENGE = 1
}

function NpcDuelStateUtils.isValidState(state)
	return state == NpcDuelStateUtils.State.CANNOT_CHALLENGE or state == NpcDuelStateUtils.State.CAN_CHALLENGE or state == NpcDuelStateUtils.State.PARTIAL_PASSED or state == NpcDuelStateUtils.State.FINISHED
end

function NpcDuelStateUtils.getInitStateInCfg(npcDuelId)
	local npcDuelConfig = NpcDuelData[npcDuelId]
	local firstVariantConfig = npcDuelConfig and npcDuelConfig[1] or nil
	local initState = firstVariantConfig and firstVariantConfig.initState or nil

	if NpcDuelStateUtils.isValidState(initState) then
		return initState
	end

	return NpcDuelStateUtils.State.CANNOT_CHALLENGE
end

function NpcDuelStateUtils.getState(playerNpcDuelComponent, npcDuelId)
	if not playerNpcDuelComponent or type(npcDuelId) ~= "number" or npcDuelId <= 0 then
		return NpcDuelStateUtils.State.CANNOT_CHALLENGE
	end

	local npcDuelState = playerNpcDuelComponent.npcDuelState
	local state = npcDuelState[npcDuelId]

	if state == nil then
		return NpcDuelStateUtils.getInitStateInCfg(npcDuelId)
	end

	if not NpcDuelStateUtils.isValidState(state) then
		return NpcDuelStateUtils.State.CANNOT_CHALLENGE
	end

	return state
end

function NpcDuelStateUtils.setNpcDuelState(playerNpcDuelComponent, npcDuelId, state)
	if not playerNpcDuelComponent or type(npcDuelId) ~= "number" or npcDuelId <= 0 then
		return false
	end

	if not NpcDuelStateUtils.isValidState(state) then
		return false
	end

	local oldState = NpcDuelStateUtils.getState(playerNpcDuelComponent, npcDuelId)
	local npcDuelState = playerNpcDuelComponent.npcDuelState

	npcDuelState[npcDuelId] = state

	if oldState ~= state then
		playerNpcDuelComponent:onNpcDuelStateChanged(npcDuelId, oldState, state)
	end

	return true
end

function NpcDuelStateUtils.setCanChallenge(playerNpcDuelComponent, npcDuelId)
	if not playerNpcDuelComponent or type(npcDuelId) ~= "number" or npcDuelId <= 0 then
		return false
	end

	local npcDuelState = playerNpcDuelComponent.npcDuelState
	local state = npcDuelState[npcDuelId]

	if state ~= nil and state ~= NpcDuelStateUtils.State.CANNOT_CHALLENGE then
		return false
	end

	local oldState = NpcDuelStateUtils.getState(playerNpcDuelComponent, npcDuelId)

	npcDuelState[npcDuelId] = NpcDuelStateUtils.State.CAN_CHALLENGE

	playerNpcDuelComponent:onNpcDuelStateChanged(npcDuelId, oldState, NpcDuelStateUtils.State.CAN_CHALLENGE)

	return true
end

return NpcDuelStateUtils
