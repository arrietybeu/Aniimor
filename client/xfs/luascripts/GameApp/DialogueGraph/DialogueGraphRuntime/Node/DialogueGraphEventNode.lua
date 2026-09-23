-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphEventNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local Utils = require("Common.Utils.Utils")
local DialogueGraphEventNode = DialogueGraphFlowNode.extend("DialogueGraphEventNode")

function DialogueGraphEventNode.run(ctx)
	local eventName = ctx:getField("eventName")
	local eventParam = ctx:getField("eventParam")

	eventParam = Utils.deepCopyTable(eventParam)

	ctx:callCmd(NodeFunc.DIALOGUE_DO_EVENT, eventName, eventParam)
	ctx:triggerFlow("Out")
end

return DialogueGraphEventNode
