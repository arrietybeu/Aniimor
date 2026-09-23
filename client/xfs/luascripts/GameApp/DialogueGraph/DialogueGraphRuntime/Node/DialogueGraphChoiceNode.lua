-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphChoiceNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphChoiceNode = DialogueGraphFlowNode.extend("DialogueGraphChoiceNode")

function DialogueGraphChoiceNode.run(ctx)
	ctx:triggerFlow("Out")
end

return DialogueGraphChoiceNode
