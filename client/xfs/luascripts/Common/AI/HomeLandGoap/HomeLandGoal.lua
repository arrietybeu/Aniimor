-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\HomeLandGoap\\HomeLandGoal.lua

local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeLandGoal = {}

function HomeLandGoal.getNewGoal(goapName, expectedStates)
	local goal = {}

	goal.name = goapName
	goal.states = expectedStates

	return goal
end

function HomeLandGoal.state_entityNeedWork(entity)
	return entity.space.allocation[entity.id] == nil or entity.space.allocation[entity.id].opId == 0
end

function HomeLandGoal.state_moveToTarget(entity)
	local targetOrnamentId = entity.goap:getTargetOrnamentId()

	if targetOrnamentId == nil then
		return false
	end

	return HomeLandUtils.getSqrDistanceByOrnamentId(entity, targetOrnamentId) < 1
end

function HomeLandGoal.state_hasWorkTarget(entity)
	return entity.goap:getTargetOrnamentId() ~= nil
end

HomeLandGoal.StateList = {
	entityNeedWork = HomeLandGoal.state_entityNeedWork,
	moveToTarget = HomeLandGoal.state_moveToTarget,
	hasWorkTarget = HomeLandGoal.state_hasWorkTarget
}

function HomeLandGoal.checkPreconditionState(action, currentState)
	for state_name, expect_val in pairs(action.preconditions) do
		if currentState[state_name] ~= expect_val then
			return false
		end
	end

	return true
end

HomeLandGoal.GOAL_NAME = {
	MoveToTarget = "moveToTarget",
	EntityNeedWork = "entityNeedWork",
	HasWorkTarget = "hasWorkTarget"
}

return HomeLandGoal
