-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphSwitchBoolNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphSwitchBoolNode = DialogueGraphFlowNode.extend("DialogueGraphSwitchBoolNode")

function DialogueGraphSwitchBoolNode.run(ctx)
	local condition = ctx:getInput("conditionVInput", false) == true

	ctx:triggerFlow(condition and "True" or "False")
end

return DialogueGraphSwitchBoolNode
