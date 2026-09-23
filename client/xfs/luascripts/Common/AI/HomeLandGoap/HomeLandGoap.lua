-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\HomeLandGoap\\HomeLandGoap.lua

local Class = require("Core.Framework.Class")
local HomeLandGoal = require("Common.AI.HomeLandGoap.HomeLandGoal")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeLandAction = require("Common.AI.HomeLandGoap.HomeLandAction")
local ListPool = require("Common.Container.ListPool")
local HomeLandGoap = Class.LiteClass("HomeLandGoap")
local Const = require("Common.Const.Const")
local lume = require("Core.Common.lume")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Logger = LoggerManager.getLogger("HomeLandGoap")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")

function HomeLandGoap:ctor(entity, goalList, actionList)
	self.entity = entity
	self.goal_list = goalList
	self.current_goal = nil
	self.current_plan = nil
	self.action_list = actionList
	self.current_stateMap = {}
	self.goalParams = {}
end

function HomeLandGoap:destroy()
	self.entity = nil
	self.goal_list = nil
	self.current_goal = nil
	self.current_plan = nil
	self.action_list = nil
	self.current_stateMap = nil
	self.goalParams = nil
end

function HomeLandGoap:_refreshWorkTarget()
	local allFacility = self.entity.space.facility
	local petPrototypeId = self.entity.petPrototypeId

	self:setTargetOrnamentId(nil)

	local closeDistance = math.maxFloat

	for ornamentId, facilityInfo in pairs(allFacility) do
		local operId = HomeLandUtils.getHomePetOperIdAtFacility(self.entity.space, ornamentId, self.entity.id, petPrototypeId)

		if operId ~= Const.HOMELAND_FACILITY_OP_TYPE.NONE then
			local dist = HomeLandUtils.getSqrDistanceByOrnamentId(self.entity, ornamentId)

			if dist < closeDistance then
				closeDistance = dist

				self:setTargetOrnamentId(ornamentId)
			end
		end
	end
end

function HomeLandGoap:getTargetOrnamentId()
	return self.goalParams.targetOrnamentId
end

function HomeLandGoap:setTargetOrnamentId(ornamentId)
	self.goalParams.targetOrnamentId = ornamentId
end

function HomeLandGoap:plan()
	if self.current_plan ~= nil and self:_execPlan(self.current_plan) then
		return
	end

	self:_refreshWorkTarget()

	local vaildGoal = ListPool.getList()

	for _, goal in ipairs(self.goal_list) do
		for state_name, expect_val in pairs(goal.states) do
			if not self:_checkState(state_name, expect_val) then
				table.insert(vaildGoal, goal)

				break
			end
		end
	end

	for _, goal in ipairs(vaildGoal) do
		local plan = self:_planForGoal(goal)

		if plan then
			self.current_goal = goal
			self.current_plan = plan

			self:_execPlan(plan)

			break
		end
	end
end

function HomeLandGoap:_execPlan(plan)
	local actionInfo = #plan > 0 and table.remove(plan, 1)

	if actionInfo then
		local operId = actionInfo.operId or actionInfo.getOperIdFunc(self.entity)

		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			Logger:debug("@cyj goap exec action:", self.entity.id, actionInfo.name, operId)
		end

		HomeLandUtils.allocateHomePetWork(self.entity, self.goalParams.targetOrnamentId, operId)

		return true
	else
		self.current_plan = nil
		self.current_goal = nil

		return false
	end
end

function HomeLandGoap:_checkState(state_name, expect_val)
	return HomeLandGoal.StateList[state_name](self.entity, expect_val) == expect_val
end

function HomeLandGoap._checkStateMapEqual(baseStateMap, targetStateMap)
	for state_name, expect_val in pairs(targetStateMap) do
		if baseStateMap[state_name] ~= expect_val then
			return false
		end
	end

	return true
end

function HomeLandGoap:_refreshCurrentStateList()
	for state_name, checker in pairs(HomeLandGoal.StateList) do
		self.current_stateMap[state_name] = checker(self.entity) or false
	end
end

function HomeLandGoap._getOpenListNode(costF, costG, costH, stateMap)
	local node = {}

	node.costF = costF
	node.costG = costG
	node.costH = costH
	node.actionList = {}
	node.stateMap = {}

	lume.mergeInPlace(node.stateMap, stateMap)

	return node
end

function HomeLandGoap._releaseOpenListNode(node)
	return
end

function HomeLandGoap._addOpenListNodeActionInfo(node, ...)
	lume.push(node.actionList, ...)
end

function HomeLandGoap._openListSortFunc(a, b)
	if a.costF < b.costF then
		return true
	elseif a.costF == b.costF and a.costH < b.costH then
		return true
	end

	return false
end

function HomeLandGoap.getHeuristic(action, goal_states)
	local cost = 0

	for state_name, expect_val in pairs(goal_states) do
		if action.preconditions[state_name] ~= expect_val then
			cost = cost + 1
		end
	end

	return cost
end

function HomeLandGoap:_planForGoal(goal)
	self:_refreshCurrentStateList()

	local goal_states = goal.states
	local open_list = ListPool.getList()
	local close_list = ListPool.getList()

	table.insert(open_list, HomeLandGoap._getOpenListNode(0, 0, 0, self.current_stateMap))

	local currentNode

	while #open_list > 0 do
		table.sort(open_list, HomeLandGoap._openListSortFunc)

		currentNode = table.remove(open_list, 1)

		local isInCloseList = false

		for _, node in ipairs(close_list) do
			if HomeLandGoap._checkStateMapEqual(node.stateMap, currentNode.stateMap) then
				isInCloseList = true

				break
			end
		end

		if not isInCloseList then
			if HomeLandGoap._checkStateMapEqual(currentNode.stateMap, goal_states) then
				break
			end

			table.insert(close_list, currentNode)

			for _, action in ipairs(self.action_list) do
				if HomeLandGoal.checkPreconditionState(action, currentNode.stateMap) then
					local costG = currentNode.costG + action.cost
					local costH = HomeLandGoap.getHeuristic(action, goal_states)
					local costF = costG + costH
					local node = HomeLandGoap._getOpenListNode(costF, costG, costH, currentNode.stateMap)

					HomeLandAction.applyEffect(action, node.stateMap)
					HomeLandGoap._addOpenListNodeActionInfo(node, unpack(currentNode.actionList), action)
					table.insert(open_list, node)
				end
			end
		end
	end

	for _, node in ipairs(open_list) do
		HomeLandGoap._releaseOpenListNode(node)
	end

	for _, node in ipairs(close_list) do
		HomeLandGoap._releaseOpenListNode(node)
	end

	ListPool.returnList(open_list)
	ListPool.returnList(close_list)

	if currentNode then
		return currentNode.actionList
	end
end

return HomeLandGoap
