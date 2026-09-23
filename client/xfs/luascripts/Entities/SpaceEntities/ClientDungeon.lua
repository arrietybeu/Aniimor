-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientDungeon.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ClientSpace = require("Entities.SpaceEntities.ClientSpace")
local DungeonConst = require("Common.Const.DungeonConst")
local MessageName = require("Const.MessageName")
local Time = require("Core.Common.Time")
local ClientDungeon = Class.Class("ClientDungeon", ClientSpace)
local STATUS_HANDLER = DungeonConst.STATUS_HANDLER

function ClientDungeon:ctor(entityId)
	ClientDungeon.super.ctor(self, entityId)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("ClientDungeon create")
	end
end

function ClientDungeon:init(dict)
	ClientDungeon.super.init(self, dict)

	return true
end

function ClientDungeon:on_status_changed(oldv, newv)
	self:onStatusChange(oldv, newv)
	facade:sendMsgToUI(MessageName.DUNGEON_STATE_CHANGE, newv)
end

function ClientDungeon:onStatusChange(old, new)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("ClientDungeon status change, old=%d, new=%d, end_ts=%d", old, new, self.end_ts)
	end

	local remainSecond = self.end_ts - Time.secondCache
	local func = self[STATUS_HANDLER[self.status]]

	if func then
		func(self, {})
	end
end

function ClientDungeon:on_end_ts_changed(oldV, newV)
	self:onEndTsChange(oldV, newV)
end

function ClientDungeon:onEndTsChange(oldV, newV)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("ClientDungeon EndTs change, old=%d, new=%d", oldV, newV)
	end
end

function ClientDungeon:on_result_changed(oldv, newv)
	self:onResultChange(oldv, newv)
end

function ClientDungeon:onResultChange(oldv, new)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("ClientDungeon result change, old=%d, new=%d, end_ts=%d", oldv, new, self.end_ts)
	end
end

function ClientDungeon:on_passerByDisplayInfo(oldv, newv, playerId)
	local passerByInfo = self.passerByMap[playerId]
	local oldDict = passerByInfo.displayInfoDict or {}
	local newDict = passerByInfo:getDisplayInfo(true)

	self:onDisplayInfoChange(oldDict, newDict)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("on_passerByDisplayInfo_changed", inspect(oldDict), inspect(newDict), playerId, self:repr())
	end
end

function ClientDungeon:on_passerByPetCombatInfo_changed(oldv, newv, playerId, petId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("on_passerByPetCombatInfo_changed", inspect(oldv), inspect(newv), playerId, petId)
	end

	facade:sendMsgToUI(MessageName.PVP_PET_STATE_CHANGE, {
		pId = playerId,
		petId = petId,
		pInfo = newv
	})
end

function ClientDungeon:onDisplayInfoChange(old, new, playerId)
	return
end

function ClientDungeon:onStatusInit(params)
	return
end

function ClientDungeon:onStatusPlayerReady(params)
	facade:sendMsgToUI(MessageName.DUNGEON_PLAYER_READY)
end

function ClientDungeon:onStatusCountDown(params)
	return
end

function ClientDungeon:onStatusPlaying(params)
	facade:sendMsgToUI(MessageName.DUNGEON_START_PLAYING)
end

function ClientDungeon:onStatusReward(params)
	return
end

function ClientDungeon:onStatusClosed(params)
	return
end

function ClientDungeon:onResult(result)
	return
end

function ClientDungeon:RPC_SC_OnResult(result)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_result", inspect(result))
	end

	self:onResult(result)
end

function ClientDungeon:getStateRemainTime()
	if self.isPausing then
		return self.stateRemainTime
	else
		return math.max(0, self.end_ts - Time.secondCache)
	end
end

return ClientDungeon
