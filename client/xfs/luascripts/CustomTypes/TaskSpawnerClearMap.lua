-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\TaskSpawnerClearMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local TaskSpawnerClearMap = class.LiteClass("TaskSpawnerClearMap", CustomDict)

function TaskSpawnerClearMap:setSpawnerClear(sceneId, spawnerId, sourceKey, isClear)
	if not self[sceneId] then
		self[sceneId] = {}
	end

	if not self[sceneId][spawnerId] then
		self[sceneId][spawnerId] = {}
	end

	if isClear then
		self[sceneId][spawnerId][sourceKey] = true
	else
		self[sceneId][spawnerId][sourceKey] = nil
	end
end

function TaskSpawnerClearMap:isSpawnerClear(sceneId, spawnerId, sourceKey)
	if not self[sceneId] then
		return false
	end

	if not self[sceneId][spawnerId] then
		return false
	end

	return self[sceneId][spawnerId][sourceKey] == true
end

return TaskSpawnerClearMap
