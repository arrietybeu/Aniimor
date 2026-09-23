-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Net\\Etcd\\EntityInfo.lua

local class = require("Core.Framework.Class")
local EntityInfo = class.Class("EntityInfo")

function EntityInfo:ctor(name, entityId, serverName, clusterId, pid)
	self.name = name
	self.entityId = entityId
	self.mailbox = {
		entityId = entityId,
		serverName = serverName,
		clusterId = clusterId
	}
	self.pid = pid
end

function EntityInfo:repr()
	return string.format("EntityInfo (%s, %s, %s)", self.name, self.mailbox.entityId, self.pid)
end

function EntityInfo:meta()
	return {
		id = self.mailbox.entityId
	}
end

function EntityInfo:isFromSameProcess(sourceProcessInfo)
	if self.serverName == sourceProcessInfo.serverName and self.pid == sourceProcessInfo.pid then
		return true
	end

	return false
end

function EntityInfo:isSame(entityInfo)
	if self.name == entityInfo.name and self.mailbox.entityId == entityInfo.mailbox.entityId and self.mailbox.serverName == entityInfo.mailbox.serverName and self.mailbox.clusterId == entityInfo.mailbox.clusterId and self.pid == entityInfo.pid then
		return true
	end

	return false
end

return EntityInfo
