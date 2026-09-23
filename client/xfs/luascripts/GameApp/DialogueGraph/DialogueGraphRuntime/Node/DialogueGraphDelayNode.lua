-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphDelayNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphDelayNode = DialogueGraphFlowNode.extend("DialogueGraphDelayNode")

function DialogueGraphDelayNode.run(ctx)
	local delayTime = ctx:getField("delayTime", 0)

	if delayTime > 0 then
		ctx:delay(delayTime, function()
			if not ctx:tryConsumeRunToken() then
				return
			end

			ctx:triggerFlow("Out")
		end)
	else
		ctx:triggerFlow("Out")
	end
end

return DialogueGraphDelayNode
