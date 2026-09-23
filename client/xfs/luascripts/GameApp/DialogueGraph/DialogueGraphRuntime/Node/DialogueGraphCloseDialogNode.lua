-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphCloseDialogNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphCloseDialogNode = DialogueGraphFlowNode.extend("DialogueGraphCloseDialogNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE

function DialogueGraphCloseDialogNode.run(ctx)
	local resumeNpc = ctx:getInput("resumeNpcVInput", true)

	ctx:callCmd(NodeFunc.DIALOGUE_CLOSE_DIALOG, resumeNpc)
	ctx:triggerFlow("Out")
end

return DialogueGraphCloseDialogNode
