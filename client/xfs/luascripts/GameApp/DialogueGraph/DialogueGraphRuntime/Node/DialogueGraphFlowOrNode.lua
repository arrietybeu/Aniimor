-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphFlowOrNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphFlowOrNode = DialogueGraphFlowNode.extend("DialogueGraphFlowOrNode")

function DialogueGraphFlowOrNode.run(ctx)
	ctx:triggerFlow("Out")
end

return DialogueGraphFlowOrNode
