-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphColorGradientNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DynamicValueRuntime = require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.DynamicValueRuntime")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local DialogueGraphColorGradientNode = DialogueGraphFlowNode.extend("DialogueGraphColorGradientNode")

function DialogueGraphColorGradientNode.getColorGradient(ctx)
	local sourceColor = DialogueGraphUtils.toColor(ctx:getInput("sourceColorVInput"))
	local targetColor = DialogueGraphUtils.toColor(ctx:getInput("targetColorVInput"))
	local animationCurve = ctx:getField("animationCurve")
	local evaluateType = ctx:getInput("evaluateTypeVInput", 0)
	local duration = ctx:getInput("durationVInput", 0)

	return DynamicValueRuntime.create(ctx, function(nodeId)
		return ctx:callCmd(NodeFunc.DYNAMIC_VALUE_CREATE_COLOR_GRADIENT, nodeId, sourceColor, targetColor, animationCurve, evaluateType, duration)
	end)
end

DialogueGraphColorGradientNode.getAnimationCurveVOutput = DialogueGraphColorGradientNode.getColorGradient
DialogueGraphColorGradientNode.getOut = DialogueGraphColorGradientNode.getColorGradient

return DialogueGraphColorGradientNode
