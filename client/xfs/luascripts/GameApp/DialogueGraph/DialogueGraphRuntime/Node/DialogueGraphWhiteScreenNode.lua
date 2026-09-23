-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphWhiteScreenNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphWhiteScreenNode = DialogueGraphFlowNode.extend("DialogueGraphWhiteScreenNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE

function DialogueGraphWhiteScreenNode.run(ctx)
	local blendTime = ctx:getInput("blendVInput", 0)

	ctx:callCmd(NodeFunc.UI_SHOW_WHITE_SCREEN, blendTime)
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

return DialogueGraphWhiteScreenNode
