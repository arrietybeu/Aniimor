-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphCloseWhiteScreenNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphCloseWhiteScreenNode = DialogueGraphFlowNode.extend("DialogueGraphCloseWhiteScreenNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE

function DialogueGraphCloseWhiteScreenNode.run(ctx)
	local blendTime = ctx:getInput("blendOutTimeVInput", 0)

	ctx:callCmd(NodeFunc.UI_CLOSE_WHITE_SCREEN, blendTime)
	ctx:triggerFlow("DirectOut")

	if blendTime > 0 then
		ctx:delay(blendTime, function()
			if not ctx:tryConsumeRunToken() then
				return
			end

			ctx:triggerFlow("Out")
		end)
	else
		ctx:triggerFlow("Out")
	end
end

return DialogueGraphCloseWhiteScreenNode
