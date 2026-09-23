-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphStartGuideNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphStartGuideNode = DialogueGraphFlowNode.extend("DialogueGraphStartGuideNode")

function DialogueGraphStartGuideNode.run(ctx)
	local guideId = ctx:getInput("guideIdVInput", 0)

	if guideId == 0 then
		ctx:triggerFlow("Start")
		ctx:triggerFlow("Finish")

		return
	end

	ctx:callCmd(NodeFunc.DIALOGUE_START_GUIDE, guideId, function()
		if ctx:tryConsumeRunToken() then
			ctx:triggerFlow("Finish")
		end
	end)
	ctx:triggerFlow("Start")
end

return DialogueGraphStartGuideNode
