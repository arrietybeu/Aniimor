-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\HTN\\HomeLandHTN.lua

local Class = require("Core.Framework.Class")
local Lume = require("Core.Common.lume")
local HomeLandHTNState = require("Common.AI.HTN.HomeLandHTNState")
local HomeLandHTNTask = require("Common.AI.HTN.HomeLandHTNTask")
local HTNUtils = require("Common.AI.HTN.HTNUtils")
local TablePool = require("Common.Container.TablePool")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local AiConst = require("Common.Const.AiConst")
local HomeLandHTN = Class.Class("HomeLandHTN")

function HomeLandHTN:ctor(entity)
	self.entity = entity
	self.worldState = TablePool.getTable()
	self.finalTaskList = {}
end

function HomeLandHTN:plan()
	return
end

function HomeLandHTN:_execTask()
	while #self.finalTaskList > 0 do
		local task = table.remove(self.finalTaskList)

		if task.type == AiConst.HTNTaskType.Primitive then
			if self:_reCheckTaskCondition(task) then
				task.taskFunc(self.entity, self.worldState)

				return true
			else
				return false
			end
		end
	end

	return false
end

function HomeLandHTN:_reCheckTaskCondition(task)
	if task.conditionMap then
		for stateEnum, v in pairs(task.conditionMap) do
			local stateFunc = HomeLandHTNState.StateFunction[stateEnum]
			local expectVal = stateFunc and stateFunc(self.entity, self.worldState) or false

			if expectVal ~= v then
				return false
			end
		end
	end

	return true
end

function HomeLandHTN:destroy()
	TablePool.returnTable(self.worldState)
end

return HomeLandHTN
