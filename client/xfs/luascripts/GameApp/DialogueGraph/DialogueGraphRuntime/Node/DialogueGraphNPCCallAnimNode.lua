-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphNPCCallAnimNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphNPCCallAnimNode = DialogueGraphFlowNode.extend("DialogueGraphNPCCallAnimNode")

function DialogueGraphNPCCallAnimNode.run(ctx)
	local function finishOnce()
		if not ctx:tryConsumeRunToken() then
			return
		end

		ctx:cancelTimeout()
		ctx:triggerFlow("Finish")
	end

	ctx:startTimeout(5, function()
		finishOnce()
	end)

	local npcTemplateId = ctx:getInput("npcIdVInput", 0)

	if ctx:getInput("plotPhoneVInput", false) == true then
		local disableAnimation = ctx:getInput("disableAniVInput", false) == true

		ctx:callCmd(NodeFunc.DIALOGUE_PLAY_PLOT_PHONE_CALL_ANIM, npcTemplateId, disableAnimation, function()
			finishOnce()
		end)
	elseif ctx:getInput("npcCallVInput", false) == true then
		ctx:callCmd(NodeFunc.DIALOGUE_PLAY_SIMPLE_NPC_CALL_ANIM, npcTemplateId, function()
			finishOnce()
		end)
	end
end

return DialogueGraphNPCCallAnimNode
