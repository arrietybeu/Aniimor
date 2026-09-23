-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphCloseBlackScreenNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphCloseBlackScreenNode = DialogueGraphFlowNode.extend("DialogueGraphCloseBlackScreenNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE

function DialogueGraphCloseBlackScreenNode.run(ctx)
	local blendOutTime = ctx:getInput("blendOutTimeVInput", 0)

	ctx:callCmd(NodeFunc.UI_CLOSE_BLACK_SCREEN, blendOutTime)
	ctx:triggerFlow("DirectOut")

	if blendOutTime > 0 then
		ctx:delay(blendOutTime, function()
			if not ctx:tryConsumeRunToken() then
				return
			end

			ctx:triggerFlow("Out")
		end)
	else
		ctx:triggerFlow("Out")
	end
end

return DialogueGraphCloseBlackScreenNode
