-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientPvpDungeon.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ClientDungeon = require("Entities.SpaceEntities.ClientDungeon")
local MessageName = require("Const.MessageName")
local ClientPvpDungeon = Class.Class("ClientPvpDungeon", ClientDungeon)

function ClientPvpDungeon:ctor(entityId)
	ClientPvpDungeon.super.ctor(self, entityId)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("ClientPvpDungeon create")
	end
end

function ClientPvpDungeon:init(dict)
	ClientPvpDungeon.super.init(self, dict)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("ClientPvpDungeon init", inspect(dict))
	end

	return true
end

function ClientPvpDungeon:onReady()
	return
end

function ClientPvpDungeon:onCounting()
	return
end

function ClientPvpDungeon:onResult(result)
	ClientPvpDungeon.super.onResult(self, result)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_result", inspect(result))
	end

	for playerId, passerBy in self.passerByMap:items() do
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("playerId=%d, result=%d, info=%s", playerId, passerBy.result, inspect(passerBy:getRawTable()))
		end
	end

	local selfInfo = self.passerByMap[pg.me.id]

	if selfInfo ~= nil then
		-- block empty
	end

	facade:sendMsgToUI(MessageName.PVP_RESULT, result)
end

return ClientPvpDungeon
