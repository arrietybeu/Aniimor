-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphAnimationCurveNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DynamicValueRuntime = require("GameApp.DialogueGraph.DialogueGraphRuntime.Core.DynamicValueRuntime")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphAnimationCurveNode = DialogueGraphFlowNode.extend("DialogueGraphAnimationCurveNode")

function DialogueGraphAnimationCurveNode.getAnimationCurve(ctx)
	local animationCurve = ctx:getField("animationCurve", nil)
	local evaluateType = ctx:getInput("evaluateTypeVInput", 0)

	return DynamicValueRuntime.create(ctx, function(nodeId)
		return ctx:callCmd(NodeFunc.DYNAMIC_VALUE_CREATE_ANIMATION_CURVE, nodeId, animationCurve, evaluateType)
	end)
end

DialogueGraphAnimationCurveNode.getAnimationCurveVOutput = DialogueGraphAnimationCurveNode.getAnimationCurve
DialogueGraphAnimationCurveNode.getOut = DialogueGraphAnimationCurveNode.getAnimationCurve

return DialogueGraphAnimationCurveNode
