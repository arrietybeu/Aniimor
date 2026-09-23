-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphEntityCancelLookAtNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local DialogueGraphEntityCancelLookAtNode = DialogueGraphFlowNode.extend("DialogueGraphEntityCancelLookAtNode")

function DialogueGraphEntityCancelLookAtNode.run(ctx)
	local entityId = ctx:getInput("entityIdVInput")
	local staticId = ctx:getInput("staticIdVInput")
	local entity = DialogueGraphUtils.getEntityById(entityId, staticId)

	if entity == nil then
		return false, string.format("找不到对应实体！EntityId:%s StaticId:%s", tostring(entityId), tostring(staticId)), true
	end

	ctx:callCmd(NodeFunc.ENTITY_CANCEL_LOOK_AT_ROLE, entity.id)
	ctx:triggerFlow("Out")
end

return DialogueGraphEntityCancelLookAtNode
