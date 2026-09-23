-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphEntityLookAtNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local NodeFunc = require("Const.DialogueGraphConst").NODE_FUNC_TYPE
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local DialogueGraphEntityLookAtNode = DialogueGraphFlowNode.extend("DialogueGraphEntityLookAtNode")

local function resolveEntityId(ctx, entityInput, staticInput)
	local entityId = ctx:getInput(entityInput)

	if not string.isNilOrEmpty(entityId) then
		return entityId
	end

	local staticId = ctx:getInput(staticInput, 0)
	local entity = DialogueGraphUtils.getEntityByStaticId(staticId)

	return entity and entity.id or nil
end

function DialogueGraphEntityLookAtNode.run(ctx)
	local sourceEntityId = ctx:getInput("entityIdVInput")
	local sourceStaticId = ctx:getInput("staticIdVInput", 0)
	local sourceEntity = DialogueGraphUtils.getEntityById(sourceEntityId, sourceStaticId)
	local entityId = sourceEntity and sourceEntity.id or nil
	local lookAtEntityId = resolveEntityId(ctx, "lookAtEntityIdVInput", "lookAtEntityStaticIdVInput")

	if string.isNilOrEmpty(entityId) or string.isNilOrEmpty(lookAtEntityId) then
		return false, string.format("找不到LookAt相关的实体！ entityId:%s lookAtEntityId:%s", entityId, lookAtEntityId), true
	end

	ctx:callCmd(NodeFunc.ENTITY_LOOK_AT_ROLE, entityId, lookAtEntityId)
	ctx:triggerFlow("Out")
end

return DialogueGraphEntityLookAtNode
