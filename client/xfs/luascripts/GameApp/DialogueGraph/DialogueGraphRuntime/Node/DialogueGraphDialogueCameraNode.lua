-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphDialogueCameraNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphDialogueCameraNode = DialogueGraphFlowNode.extend("DialogueGraphDialogueCameraNode")

function DialogueGraphDialogueCameraNode.run(ctx)
	local function finishCallback()
		if not ctx:tryConsumeRunToken() then
			return
		end

		ctx:triggerFlow("Finish")
	end

	ctx:delay(2, finishCallback)
	ctx:callCmd(NodeFunc.CAMERA_ENABLE_NPC_DIALOGUE_CAMERA, true, ctx:getInput("presetNameVInput"), ctx:getInput("targetEntityVInput"), finishCallback)
	ctx:triggerFlow("Out")
end

return DialogueGraphDialogueCameraNode
