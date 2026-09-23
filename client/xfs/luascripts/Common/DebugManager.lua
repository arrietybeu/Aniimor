-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\DebugManager.lua

local EntityManager = require("Core.Common.EntityManager")
local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local GmConst = require("Common.Const.GmConst")
local DebugManager = {
	curTestName = ""
}

function DebugManager.setDepth(depth)
	DebugManager.inspectDepth = depth
end

function DebugManager.getDepth()
	return DebugManager.inspectDepth or pg.component == "game" and 2 or 1
end

function DebugManager.setNoMeta(noMeta)
	DebugManager.inspectNoMeta = ToBool(noMeta)
end

function DebugManager.getNoMeta()
	return DebugManager.inspectNoMeta or false
end

function DebugManager.getEntity(entityId)
	return EntityManager._entities[entityId]
end

function DebugManager.near(idOrEnt, range, maxCount)
	idOrEnt = idOrEnt or 1

	local ent = type(idOrEnt) == "table" and idOrEnt or DebugManager.player(idOrEnt)

	if not ent then
		return "invalid id or entity"
	end

	return ent.aoi:entitiesInRange(range or 10, -1, maxCount or 100)
end

function DebugManager.syncDump(idOrEnt)
	idOrEnt = idOrEnt or 1

	local ent = type(idOrEnt) == "table" and idOrEnt or DebugManager.player(idOrEnt)

	if not ent then
		return "invalid id or entity"
	end

	return ent.syncGroup:debugInfo()
end

function DebugManager.aoiLevel(idOrEnt)
	idOrEnt = idOrEnt or 1

	local ent = type(idOrEnt) == "table" and idOrEnt or DebugManager.player(idOrEnt)

	if not ent then
		return "invalid id or entity"
	end

	local res = {}
	local totalAoiLevel = Const.TRAP_EVENT_TO_AOI_LEVEL[0]
	local partRange = ent.aoiRange / 100 / totalAoiLevel

	for actorType, level in pairs(ent.aoiSettingLevel) do
		local entName = Const.ACTOR_TYPE_NAME[actorType] or string.format("UnknownActorType_%s", actorType)

		res[entName] = string.format("Level: %d, Range: %dm", level, partRange * level)
	end

	return res
end

function DebugManager.space(id)
	local list = {}

	for entityId, entity in pairs(EntityManager._entities) do
		if pg.component == "game" then
			local Space = require("Entities.SpaceEntities.SpaceClass.Space")

			if Class.isInstanceOf(entity, Space) then
				list[#list + 1] = entityId
			end
		else
			local ClientSpace = require("Entities.SpaceEntities.ClientSpace")

			if Class.isInstanceOf(entity, ClientSpace) then
				list[#list + 1] = entityId
			end
		end
	end

	if type(id) == "number" and list[id] then
		return pg.getEntity(list[id])
	end

	if type(id) == "string" then
		for _, entityId in ipairs(list) do
			if id == entityId then
				return pg.getEntity(id)
			end
		end
	end

	return list
end

function DebugManager.player(id)
	local list = {}

	for entityId, entity in pairs(EntityManager._entities) do
		if entity.className == "Player" or entity.className == "PvpBotPlayer" or entity.className == "ClientPlayer" or entity.className == "ClientMainPlayer" then
			list[#list + 1] = entityId
		end
	end

	if type(id) == "number" and list[id] then
		return pg.getEntity(list[id])
	end

	if type(id) == "string" then
		for _, entityId in ipairs(list) do
			if id == entityId then
				return pg.getEntity(id)
			end
		end

		local player = DebugManager.getPlayerByUid(id)

		if player then
			return player
		end
	end

	return list
end

function DebugManager.puppet(id)
	local list = {}

	for entityId, entity in pairs(EntityManager._entities) do
		if entity.className == "Puppet" or entity.className == "ClientPuppet" then
			list[#list + 1] = entityId
		end
	end

	if type(id) == "number" and list[id] then
		return pg.getEntity(list[id])
	end

	if type(id) == "string" then
		for _, entityId in ipairs(list) do
			if id == entityId then
				return pg.getEntity(id)
			end
		end
	end

	return list
end

function DebugManager.pet(id)
	local list = {}

	for entityId, entity in pairs(EntityManager._entities) do
		if entity.className == "Pet" or entity.className == "ClientPet" then
			list[#list + 1] = entityId
		end
	end

	if type(id) == "number" and list[id] then
		return pg.getEntity(list[id])
	end

	if type(id) == "string" then
		for _, entityId in ipairs(list) do
			if id == entityId then
				return pg.getEntity(id)
			end
		end
	end

	return list
end

function DebugManager.envObj(id)
	local list = {}

	for entityId, entity in pairs(EntityManager._entities) do
		if entity.className == "EnvObject" or entity.className == "ClientEnvObject" then
			list[#list + 1] = entityId
		end
	end

	if type(id) == "number" and list[id] then
		return pg.getEntity(list[id])
	end

	if type(id) == "string" then
		for _, entityId in ipairs(list) do
			if id == entityId then
				return pg.getEntity(id)
			end
		end
	end

	return list
end

function DebugManager.clientEnvObj()
	local lume = require("Core.Common.lume")

	return lume.count(pg.game.envObj.entities)
end

function DebugManager.campCar(id)
	local list = {}

	for entityId, entity in pairs(EntityManager._entities) do
		if entity.className == "CampCar" or entity.className == "ClientCampCar" then
			list[#list + 1] = entityId
		end
	end

	if type(id) == "number" and list[id] then
		return pg.getEntity(list[id])
	end

	if type(id) == "string" then
		for _, entityId in ipairs(list) do
			if id == entityId then
				return pg.getEntity(id)
			end
		end
	end

	return list
end

function DebugManager.repo()
	if pg.component == "game" then
		return require("Core.Server.GameServerRepo")
	else
		return require("Core.Client.ClientRepo")
	end
end

function DebugManager.getPlayerByUid(uid)
	for entityId, entity in pairs(EntityManager._entities) do
		if (entity.className == "Player" or entity.className == "ClientPlayer" or entity.className == "ClientMainPlayer") and entity.uid == tostring(uid) then
			return entity
		end
	end
end

function DebugManager.getPlayerByUserName(username)
	for entityId, entity in pairs(EntityManager._entities) do
		if (entity.className == "Player" or entity.className == "ClientPlayer" or entity.className == "ClientMainPlayer") and entity.username == tostring(username) then
			return entity
		end
	end
end

function DebugManager.srvObj(serviceName, idSectionName, id)
	local GameServerRepo = require("Core.Server.GameServerRepo")
	local service = GameServerRepo.luaServiceManager:getService(serviceName)
	local chunks = service.shard.idToChunk
	local list = {}
	local map = {}

	for _, chunk in pairs(chunks) do
		for _, obj in pairs(chunk.srvObjs) do
			list[#list + 1] = obj[idSectionName]
			map[obj[idSectionName]] = obj
		end
	end

	if type(id) == "number" then
		return map[list[id]]
	end

	if type(id) == "string" then
		return map[id]
	end

	return list
end

function DebugManager.social(id)
	return DebugManager.srvObj("SocialService", "socialId", id)
end

function DebugManager.role(id)
	return DebugManager.srvObj("RoleService", "username", id)
end

function DebugManager.team(id)
	local GameServerRepo = require("Core.Server.GameServerRepo")
	local service = GameServerRepo.luaServiceManager:getService("TeamService")
	local chunks = service.shard.idToChunk
	local list = {}
	local map = {}

	for _, chunk in pairs(chunks) do
		for _, team in pairs(chunk.srvObjs) do
			list[#list + 1] = team.teamId
			map[team.teamId] = team
		end
	end

	if type(id) == "number" and list[id] then
		return map[list[id]]
	end

	if type(id) == "string" then
		return map[id]
	end

	return list
end

function DebugManager.room(id)
	local GameServerRepo = require("Core.Server.GameServerRepo")
	local service = GameServerRepo.luaServiceManager:getService("RoomService")
	local chunks = service.shard.idToChunk
	local list = {}
	local map = {}

	for _, chunk in pairs(chunks) do
		for _, room in pairs(chunk.srvObjs) do
			list[#list + 1] = room.roomId
			map[room.roomId] = room
		end
	end

	if type(id) == "number" and list[id] then
		return map[list[id]]
	end

	if type(id) == "string" then
		return map[id]
	end

	return list
end

function DebugManager.line()
	local services = pg.ent("LineService")

	for _, service in pairs(services) do
		return service.sceneId2LineInfo
	end
end

function DebugManager.lineLog()
	local services = pg.ent("LineService")

	for _, service in pairs(services) do
		return service:timerCheckLineInfoLog()
	end
end

function DebugManager.rpcLog(open, excludeList)
	local open = ToBool(open)
	local excludeList = excludeList or {
		"RPC_CS_Heartbeat",
		"RPC_SC_Heartbeat",
		"RPC_CS_SyncAIState",
		"RPC_CS_CharacterStateChange",
		"RPC_CS_RemoteSyncAIAction"
	}

	require("Core.Common.Switch").RpcLog = open

	if open and excludeList then
		local excludeMap = {}

		for _, rpcName in ipairs(excludeList) do
			excludeMap[rpcName] = true
		end

		GmConst.setName("RpcLogExclulde", excludeMap)
	end

	return "success"
end

function DebugManager.reload(type)
	local TimerManager = require("Core.Timer.TimerManager")

	if pg.component == "game" then
		do
			local funcName

			funcName = type == 1 and "reloadScript" or type == 2 and "reloadData" or "reloadAll"

			TimerManager.addNextFrameCb(function()
				pg.gmMgr()[funcName](pg.gmMgr())
			end)

			return string.format("%s, check server log for result! help:%s", funcName, "(1:script 2:data default:all)")
		end

		return
	end

	if not require("lfs").attributes(LUA_ROOT_PATH) then
		return string.format("%s path not found", LUA_ROOT_PATH)
	end

	TimerManager.addNextFrameCb(function()
		require("Utils.ClientUtils").refreshCodeAndData()
	end)

	return string.format("%s, check client log for result! path:%s", "reloadAll", LUA_ROOT_PATH)
end

function DebugManager.reloadFile(filePath)
	local TimerManager = require("Core.Timer.TimerManager")

	if not filePath or filePath == "" then
		return "usage: reloadFile <relative/path/to/file.lua>"
	end

	if not require("lfs").attributes(LUA_ROOT_PATH) then
		return string.format("%s path not found", LUA_ROOT_PATH)
	end

	TimerManager.addNextFrameCb(function()
		require("Utils.ClientUtils").reloadFile(filePath)
	end)

	return string.format("reloadFile: %s, check client log for result!", filePath)
end

function DebugManager.reloadRecent()
	local TimerManager = require("Core.Timer.TimerManager")

	if not require("lfs").attributes(LUA_ROOT_PATH) then
		return string.format("%s path not found", LUA_ROOT_PATH)
	end

	TimerManager.addNextFrameCb(function()
		require("Utils.ClientUtils").reloadRecentFiles()
	end)

	return "reloadRecent: check client log for result!"
end

function DebugManager.switchTest(name)
	DebugManager.curTestName = name

	return dofile(package.searchpath("Common.TestManager", package.path))
end

function DebugManager.isTesting(name)
	return name == DebugManager.curTestName
end

return DebugManager
