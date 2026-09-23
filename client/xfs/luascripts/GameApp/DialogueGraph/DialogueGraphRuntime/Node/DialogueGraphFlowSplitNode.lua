-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphFlowSplitNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphFlowSplitNode = DialogueGraphFlowNode.extend("DialogueGraphFlowSplitNode")

function DialogueGraphFlowSplitNode.run(ctx)
	local portCount = ctx:getField("portCount", 2)

	if portCount < 0 then
		portCount = 0
	end

	for index = 0, portCount - 1 do
		ctx:triggerFlow(tostring(index))
	end
end

return DialogueGraphFlowSplitNode
