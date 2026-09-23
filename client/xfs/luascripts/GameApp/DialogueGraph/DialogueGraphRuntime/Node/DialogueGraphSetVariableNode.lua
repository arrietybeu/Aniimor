-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphSetVariableNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphSetVariableNode = DialogueGraphFlowNode.extend("DialogueGraphSetVariableNode")

function DialogueGraphSetVariableNode.run(ctx)
	local variableName = ctx:getField("variableName")
	local value = ctx:getInput("valueVInput")

	ctx:setBlackboard(variableName, value)
	ctx:triggerFlow("Out")
end

function DialogueGraphSetVariableNode.getValue(ctx)
	local variableName = ctx:getField("variableName")

	return ctx:getBlackboard(variableName)
end

return DialogueGraphSetVariableNode
