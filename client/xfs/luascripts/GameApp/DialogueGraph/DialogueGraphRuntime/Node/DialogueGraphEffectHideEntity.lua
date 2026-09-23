-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphEffectHideEntity.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphEffectHideEntity = DialogueGraphFlowNode.extend("DialogueGraphEffectHideEntity")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE

function DialogueGraphEffectHideEntity.run(ctx)
	local param = {
		nodeId = ctx:nodeId(),
		entityId = ctx:getInput("entityIdVInput", ""),
		staticId = ctx:getInput("staticIdVInput", 0),
		isFadeIn = ctx:getInput("isFadeInVInput", false),
		duration = ctx:getInput("durationVInput", 0.6),
		resetOnFinish = ctx:getInput("isResetValueInput", false)
	}

	ctx:callCmd(NodeFunc.ENTITY_PLAY_VISIBILITY_EFFECT, param, function()
		if not ctx:tryConsumeRunToken() then
			return
		end

		ctx:triggerFlow("Out")
	end)
end

return DialogueGraphEffectHideEntity
