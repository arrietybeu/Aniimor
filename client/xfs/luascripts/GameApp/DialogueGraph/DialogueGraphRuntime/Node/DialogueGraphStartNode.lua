-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphStartNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphStartNode = DialogueGraphFlowNode.extend("DialogueGraphStartNode")

function DialogueGraphStartNode.run(ctx)
	ctx:triggerFlow("Start")
end

return DialogueGraphStartNode
