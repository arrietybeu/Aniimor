-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphFlowDialogSkipStartNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphFlowDialogSkipStartNode = DialogueGraphFlowNode.extend("DialogueGraphFlowDialogSkipStartNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE

function DialogueGraphFlowDialogSkipStartNode.run(ctx)
	ctx:callCmd(NodeFunc.DIALOGUE_ENABLE_SKIP, ctx:getInput("startSkipMsgVInput", false) == true)
	ctx:triggerFlow("fOutput")
end

return DialogueGraphFlowDialogSkipStartNode
