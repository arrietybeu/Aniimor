-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\BehaviorTreePlanUtils.lua

local ConstValueReader = require("Common.AI.Behaviac.Parser.ConstValueReader")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local TablePool = require("Common.Container.TablePool")
local BehaviorTreePlanUtils = {}

function BehaviorTreePlanUtils.startEcologyPlan(rawData, agent, otherSubtreeParams, blackboardParams)
	if not rawData or string.isNilOrEmpty(rawData.templateKey) or not agent then
		return false
	end

	if not agent:tryChangeBehaviorState(BehaviorPathMapData.EnumNameMap[rawData.templateKey], true) then
		return false
	end

	BehaviorTreePlanUtils.setSubTreeLocalParams(rawData, agent, otherSubtreeParams)
	BehaviorTreePlanUtils.setBlackBoardProperties(agent, blackboardParams)

	return true
end

function BehaviorTreePlanUtils.startEcologyPlanByState(agent, behaviorState, subtreeParams, blackboardParams)
	if behaviorState == nil or not agent:tryChangeBehaviorState(behaviorState, true) then
		return false
	end

	agent:setSubTreeLocalParams(subtreeParams)
	BehaviorTreePlanUtils.setBlackBoardProperties(agent, blackboardParams)

	return true
end

function BehaviorTreePlanUtils.setSubTreeLocalParams(rawData, agent, otherSubtreeParams)
	local params = TablePool.getTable()

	if rawData and rawData.behaviorTreeTemplateParameters then
		for _, v in ipairs(rawData.behaviorTreeTemplateParameters) do
			local pName, pRealValue = v.name, v.realValue

			if pRealValue ~= nil then
				params[pName] = pRealValue
			else
				local pType, pValue = v.type, v.value

				params[pName] = ConstValueReader.readAnyType(pType, pValue)
			end
		end
	end

	if otherSubtreeParams then
		table.merge(params, otherSubtreeParams)
	end

	agent:setSubTreeLocalParams(params)
	TablePool.returnTable(params)
end

function BehaviorTreePlanUtils.setBlackBoardProperties(agent, blackboardParams)
	if blackboardParams then
		for key, value in pairs(blackboardParams) do
			agent:setBlackBoardProperty(key, value)
		end
	end
end

return BehaviorTreePlanUtils
