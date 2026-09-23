-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphEntityCastSkillNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphEntityCastSkillNode = DialogueGraphFlowNode.extend("DialogueGraphEntityCastSkillNode")

function DialogueGraphEntityCastSkillNode.run(ctx)
	local castEntityId = ctx:getInput("castEntityIdVInput")

	if ctx:inputPort() == "Stop" then
		ctx:callCmd(NodeFunc.ENTITY_ENTITY_CANCEL_CAST_ABILITY, castEntityId)

		return
	end

	local abilityId = ctx:getInput("abilityIdVInput", 0)

	if string.isNilOrEmpty(castEntityId) or abilityId <= 0 then
		return false, "cast entity id or ability id is invalid"
	end

	local targetEntityId = ctx:getInput("targetEntityIdVInput")

	ctx:callCmd(NodeFunc.ENTITY_ENTITY_CAST_ABILITY, castEntityId, abilityId, targetEntityId)
	ctx:triggerFlow("Out")
end

return DialogueGraphEntityCastSkillNode
