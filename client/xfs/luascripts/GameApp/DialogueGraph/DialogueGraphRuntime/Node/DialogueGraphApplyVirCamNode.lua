-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphApplyVirCamNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphApplyVirCamNode = DialogueGraphFlowNode.extend("DialogueGraphApplyVirCamNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE

function DialogueGraphApplyVirCamNode.run(ctx)
	local cameraId = ctx:getField("cameraId", 0)

	if cameraId == 0 then
		ctx:triggerFlow("Finish")
		ctx:triggerFlow("Out")

		return
	end

	local function finishCallback()
		if not ctx:tryConsumeRunToken() then
			return
		end

		ctx:triggerFlow("Finish")
	end

	ctx:callCmd(NodeFunc.CAMERA_APPLY_BLEND_TO_FIXED, cameraId, finishCallback)
	ctx:triggerFlow("Out")
end

return DialogueGraphApplyVirCamNode
