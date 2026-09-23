-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphCameraResetNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphCameraResetNode = DialogueGraphFlowNode.extend("DialogueGraphCameraResetNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE

function DialogueGraphCameraResetNode.run(ctx)
	ctx:callCmd(NodeFunc.CAMERA_SET_DOF_ACTIVE, false)
	ctx:callCmd(NodeFunc.CAMERA_CANCEL_GRAPH_BLEND, ctx:getInput("blendTimeVInput", 0), true)
	ctx:triggerFlow("Out")
end

return DialogueGraphCameraResetNode
