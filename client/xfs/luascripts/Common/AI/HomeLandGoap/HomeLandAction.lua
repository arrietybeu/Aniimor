-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\HomeLandGoap\\HomeLandAction.lua

local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeLandGoal = require("Common.AI.HomeLandGoap.HomeLandGoal")
local Const = require("Common.Const.Const")
local HomeLandAction = {}

function HomeLandAction.cloneAction(oldAction)
	local action = {}

	action.name = oldAction.name
	action.preconditions = oldAction.preconditions
	action.effects = oldAction.effects
	action.cost = oldAction.cost

	return action
end

function HomeLandAction.releaseAction(action)
	return
end

function HomeLandAction.applyEffect(action, newStateMap)
	for state_name, val in pairs(action.effects) do
		newStateMap[state_name] = val
	end

	return newStateMap
end

function HomeLandAction.getOperId(entity)
	local targetOrnamentId = entity.goap:getTargetOrnamentId()

	if targetOrnamentId == nil then
		return Const.HOMELAND_FACILITY_OP_TYPE.NONE
	end

	return HomeLandUtils.getHomePetOperIdAtFacility(entity.space, targetOrnamentId, entity.id, entity.petPrototypeId)
end

HomeLandAction.HomeLandActionList = {
	{
		name = "GoWorkAction",
		cost = 1,
		preconditions = {
			hasWorkTarget = true,
			entityNeedWork = true,
			moveToTarget = true
		},
		effects = {
			entityNeedWork = false
		},
		getOperIdFunc = HomeLandAction.getOperId
	},
	{
		name = "MoveToTargetAction",
		cost = 1,
		preconditions = {
			hasWorkTarget = true,
			moveToTarget = false
		},
		effects = {
			moveToTarget = true
		},
		operId = Const.HOMELAND_FACILITY_OP_TYPE.MOVING
	}
}

return HomeLandAction
