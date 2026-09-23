-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphDialogueCameraResetNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphDialogueCameraResetNode = DialogueGraphFlowNode.extend("DialogueGraphDialogueCameraResetNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE

function DialogueGraphDialogueCameraResetNode.run(ctx)
	ctx:callCmd(NodeFunc.CAMERA_ENABLE_NPC_DIALOGUE_CAMERA, false)
	ctx:triggerFlow("Out")
end

return DialogueGraphDialogueCameraResetNode
