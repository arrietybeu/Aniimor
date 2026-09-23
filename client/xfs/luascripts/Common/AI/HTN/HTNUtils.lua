-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\HTN\\HTNUtils.lua

local AiConst = require("Common.Const.AiConst")
local Lume = require("Core.Common.lume")
local TablePool = require("Common.Container.TablePool")
local HTNUtils = {}

function HTNUtils.checkCondition(conditionMap, worldState)
	if not conditionMap then
		return true
	end

	for requireStateName, requireStateValue in pairs(conditionMap) do
		if worldState[requireStateName] ~= requireStateValue then
			return false
		end
	end

	return true
end

function HTNUtils.playEffect(effectMap, worldState)
	if not effectMap then
		return
	end

	for effectStateName, effectStateValue in pairs(effectMap) do
		worldState[effectStateName] = effectStateValue
	end
end

function HTNUtils.planPrimitiveTask(task, worldState, finalTaskList)
	return
end

function HTNUtils.tryRun(task, worldState, finalTaskList)
	if task.type == AiConst.HTNTaskType.Primitive then
		local copyWorldState = Lume.clone(worldState, TablePool.getTable())

		if HTNUtils.checkCondition(task.conditionMap, worldState) then
			HTNUtils.playEffect(task.effectMap, copyWorldState)
			TablePool.returnTable(worldState)

			finalTaskList[#finalTaskList + 1] = task

			return true, copyWorldState
		end

		TablePool.returnTable(copyWorldState)

		return false, worldState
	elseif task.type == AiConst.HTNTaskType.Compound then
		for _, method in ipairs(task.methodList) do
			if HTNUtils.checkCondition(method.conditionMap, worldState) then
				local ret = true
				local tCopyWorldState = Lume.clone(worldState, TablePool.getTable())

				for index, subTask in ipairs(method.subTaskList) do
					ret, tCopyWorldState = HTNUtils.tryRun(subTask, tCopyWorldState, finalTaskList)

					if not ret then
						while index > 1 do
							finalTaskList[#finalTaskList] = nil
							index = index - 1
						end

						break
					end
				end

				if ret then
					TablePool.returnTable(worldState)

					return true, tCopyWorldState
				else
					TablePool.returnTable(tCopyWorldState)
				end
			end
		end

		finalTaskList[#finalTaskList] = nil

		return false, worldState
	end

	return false, worldState
end

return HTNUtils
