-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphStopNPCCallAnimNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphStopNPCCallAnimNode = DialogueGraphFlowNode.extend("DialogueGraphStopNPCCallAnimNode")

function DialogueGraphStopNPCCallAnimNode.run(ctx)
	if ctx:getInput("plotPhoneVInput", false) == true then
		ctx:callCmd(NodeFunc.DIALOGUE_STOP_PLOT_PHONE_CALL_ANIM)
	elseif ctx:getInput("npcCallVInput", false) == true then
		ctx:callCmd(NodeFunc.DIALOGUE_STOP_SIMPLE_NPC_CALL_ANIM)
	end

	ctx:triggerFlow("Start")
end

return DialogueGraphStopNPCCallAnimNode
