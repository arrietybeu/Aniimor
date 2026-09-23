-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphStopNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphStopNode = DialogueGraphFlowNode.extend("DialogueGraphStopNode")

function DialogueGraphStopNode.run(ctx)
	ctx:triggerFlow("Out")
end

return DialogueGraphStopNode
