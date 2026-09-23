-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphTriggerCustomCallbackNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphTriggerCustomCallbackNode = DialogueGraphFlowNode.extend("DialogueGraphTriggerCustomCallbackNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE

function DialogueGraphTriggerCustomCallbackNode.run(ctx)
	local ret = ctx:getInput("retValueInput", 0)
	local key = ctx:getInput("keyValueInput")

	ctx:callCmd(NodeFunc.DIALOGUE_TRIGGER_CUSTOM_CALLBACK, ret, key)
	ctx:triggerFlow("fOutInput")
end

return DialogueGraphTriggerCustomCallbackNode
