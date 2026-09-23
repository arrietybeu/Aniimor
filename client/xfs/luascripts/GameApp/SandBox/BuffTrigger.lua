-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\BuffTrigger.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local BuffTrigger = Class.LightClass("Sandbox.BuffTrigger", LevelItem)

function BuffTrigger:ctor(sandbox, spawnInfo, syncInfo)
	BuffTrigger.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function BuffTrigger:addBuff(entityId)
	local entity = pg.getEntity(entityId)

	if entity and entity.isMainAuthority then
		self:serverMsg("RPC_CS_AddBuff", entityId)
	end
end

function BuffTrigger:removeBuff(entityId)
	local entity = pg.getEntity(entityId)

	if entity and entity.isMainAuthority then
		self:serverMsg("RPC_CS_RemoveBuff", entityId)
	end
end

function BuffTrigger:destroy()
	BuffTrigger.super.destroy(self)
end

return BuffTrigger
