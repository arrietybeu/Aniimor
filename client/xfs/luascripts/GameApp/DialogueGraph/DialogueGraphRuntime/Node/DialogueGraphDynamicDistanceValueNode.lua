-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphDynamicDistanceValueNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DynamicValueRuntime = require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.DynamicValueRuntime")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphDynamicDistanceValueNode = DialogueGraphFlowNode.extend("DialogueGraphDynamicDistanceValueNode")

function DialogueGraphDynamicDistanceValueNode.getDistance(ctx)
	local source = ctx:getInput("sourceTransVInput", nil)
	local target = ctx:getInput("targetTransVInput", nil)

	if source == nil or target == nil then
		return nil
	end

	local distanceType = tonumber(ctx:getInput("distanceTypeVInput", 2)) or 2
	local offset = tonumber(ctx:getInput("distanceOffsetVInput", 0)) or 0
	local scaleFactor = tonumber(ctx:getInput("scaleFactorVInput", 1)) or 1

	return DynamicValueRuntime.create(ctx, function(nodeId)
		return ctx:callCmd(NodeFunc.DYNAMIC_VALUE_CREATE_DISTANCE, nodeId, source, target, distanceType, offset, scaleFactor)
	end)
end

DialogueGraphDynamicDistanceValueNode.getDistanceAnimationVOutput = DialogueGraphDynamicDistanceValueNode.getDistance
DialogueGraphDynamicDistanceValueNode.getOut = DialogueGraphDynamicDistanceValueNode.getDistance

return DialogueGraphDynamicDistanceValueNode
