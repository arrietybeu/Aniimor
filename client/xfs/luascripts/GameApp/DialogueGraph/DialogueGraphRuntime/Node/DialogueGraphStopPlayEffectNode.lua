-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphStopPlayEffectNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphStopPlayEffectNode = DialogueGraphFlowNode.extend("DialogueGraphStopPlayEffectNode")

function DialogueGraphStopPlayEffectNode.run(ctx)
	local effectId = ctx:getInput("effectIdVInput", 0)

	if effectId ~= 0 then
		local generatorId = ctx:getInput("generatorIdVInput", 0)

		ctx:callCmd(NodeFunc.EFFECT_STOP, generatorId, effectId)
	end

	ctx:triggerFlow("Finish")
end

return DialogueGraphStopPlayEffectNode
