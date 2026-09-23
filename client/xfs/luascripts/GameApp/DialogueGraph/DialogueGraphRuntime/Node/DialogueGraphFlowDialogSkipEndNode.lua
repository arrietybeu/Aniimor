-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphFlowDialogSkipEndNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphFlowDialogSkipEndNode = DialogueGraphFlowNode.extend("DialogueGraphFlowDialogSkipEndNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE

function DialogueGraphFlowDialogSkipEndNode.run(ctx)
	ctx:callCmd(NodeFunc.DIALOGUE_DISABLE_SKIP)
	ctx:triggerFlow("fOutput")
end

return DialogueGraphFlowDialogSkipEndNode
