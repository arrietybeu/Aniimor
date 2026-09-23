-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphWaitUICloseNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphWaitUICloseNode = DialogueGraphFlowNode.extend("DialogueGraphWaitUICloseNode")

function DialogueGraphWaitUICloseNode.run(ctx)
	local uid = ctx:getInput("uidVInput", 0)

	if uid == 0 then
		ctx:triggerFlow("Finish")
		ctx:triggerFlow("Out")

		return
	end

	ctx:triggerFlow("Out")

	local waitDestroy = ctx:getInput("waitDestroyVInput", false) == true

	ctx:callCmd(NodeFunc.UI_WAIT_CLOSE, ctx:nodeId(), uid, waitDestroy, function()
		if ctx:tryConsumeRunToken() then
			ctx:triggerFlow("Finish")
		end
	end)
end

return DialogueGraphWaitUICloseNode
