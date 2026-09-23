-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\SetVariable.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local SetVariable = DialogueGraphFlowNode.extend("SetVariable")

function SetVariable.run(ctx)
	local variableName = ctx:getField("variableName")
	local value = ctx:getInput("Value", ctx:getBlackboard(variableName))

	ctx:setBlackboard(variableName, value)
	ctx:triggerFlow("Out")
end

function SetVariable.getValue(ctx)
	local variableName = ctx:getField("variableName")

	return ctx:getBlackboard(variableName, nil)
end

return SetVariable
