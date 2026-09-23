-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphBlackScreenNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphBlackScreenNode = DialogueGraphFlowNode.extend("DialogueGraphBlackScreenNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE

function DialogueGraphBlackScreenNode.run(ctx)
	local blendTime = ctx:getInput("blendVInput", 0)

	ctx:callCmd(NodeFunc.UI_SHOW_BLACK_SCREEN, blendTime)
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

return DialogueGraphBlackScreenNode
