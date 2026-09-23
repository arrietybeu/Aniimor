-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphMultiEntityCancelLookAtNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphMultiEntityCancelLookAtNode = DialogueGraphFlowNode.extend("DialogueGraphMultiEntityCancelLookAtNode")

function DialogueGraphMultiEntityCancelLookAtNode.run(ctx)
	local entitys = ctx:getInput("cancelEntitysVInput")

	ctx:callCmd(NodeFunc.ENTITY_CANCEL_MULTI_LOOK_AT, entitys)
	ctx:triggerFlow("Out")
end

return DialogueGraphMultiEntityCancelLookAtNode
