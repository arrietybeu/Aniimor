-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphEntityPauseAINode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphEntityPauseAINode = DialogueGraphFlowNode.extend("DialogueGraphEntityPauseAINode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE

function DialogueGraphEntityPauseAINode.run(ctx)
	local entityId = ctx:getInput("entityIdVInput")
	local staticId = ctx:getInput("staticIdVInput", 0)

	if string.isNilOrEmpty(entityId) and staticId == 0 then
		ctx:triggerFlow("Finish")

		return
	end

	if ctx:getInput("pauseVInput", true) then
		ctx:callCmd(NodeFunc.ENTITY_PAUSE_BT, entityId, staticId)
	else
		ctx:callCmd(NodeFunc.ENTITY_RESUME_BT, entityId, staticId)
	end

	ctx:triggerFlow("Finish")
end

return DialogueGraphEntityPauseAINode
