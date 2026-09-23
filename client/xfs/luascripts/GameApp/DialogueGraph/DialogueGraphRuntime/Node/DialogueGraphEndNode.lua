-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphEndNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphEndNode = DialogueGraphFlowNode.extend("DialogueGraphEndNode")

function DialogueGraphEndNode.run(ctx)
	local retFlag = ctx:getField("retFlag", 0)

	ctx:finishGraph(retFlag)
end

return DialogueGraphEndNode
