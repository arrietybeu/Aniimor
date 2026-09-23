-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\ActorManager.lua

local ActorManager = {}

ActorManager.entities = {}
ActorManager.uid2Ent = {}

function ActorManager.getEntity(actorId)
	return ActorManager.entities[actorId]
end

function ActorManager.addEntity(actorId, entity, uid)
	ActorManager.entities[actorId] = entity

	if ToBool(uid) then
		ActorManager.uid2Ent[uid] = entity
	end
end

function ActorManager.removeEntity(actorId, entity)
	if actorId == nil or actorId == 0 then
		return
	end

	local ent = ActorManager.entities[actorId]

	if ent ~= entity then
		return
	end

	if ent and ent.uid then
		ActorManager.uid2Ent[ent.uid] = nil
	end

	ActorManager.entities[actorId] = nil
end

return ActorManager
