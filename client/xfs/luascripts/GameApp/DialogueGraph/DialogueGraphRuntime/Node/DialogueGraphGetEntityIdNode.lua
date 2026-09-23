-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\DialogueGraph\\DialogueGraphRuntime\\Node\\DialogueGraphGetEntityIdNode.lua

local DialogueGraphFlowNode = require("GameApp.DialogueGraph.DialogueGraphRuntime.Node.DialogueGraphFlowNode")
local DialogueGraphGetEntityIdNode = DialogueGraphFlowNode.extend("DialogueGraphGetEntityIdNode")
local DialogueGraphUtils = require("GameApp.DialogueGraph.DialogueGraphUtils")
local EntityType = require("Const.DialogueGraphConst").EntityType

local function getEntityId(entity)
	return entity and (entity.id or entity.entityId) or nil
end

function DialogueGraphGetEntityIdNode.getEntityID(ctx)
	local entityType = ctx:getField("entityType", EntityType.Player) or EntityType.Player
	local entity

	if entityType == EntityType.Player then
		entity = pg.pawn
	elseif entityType == EntityType.PlayerPet then
		entity = pg.me:getCurPetEntity()
	elseif entityType == EntityType.Puppet or entityType == EntityType.VirtualEntity then
		local staticId = ctx:getInput("staticIdVInput", 0)

		entity = DialogueGraphUtils.getEntityByStaticId(staticId)
	elseif entityType == EntityType.Pawn then
		entity = pg.pawn
	end

	return getEntityId(entity)
end

return DialogueGraphGetEntityIdNode
