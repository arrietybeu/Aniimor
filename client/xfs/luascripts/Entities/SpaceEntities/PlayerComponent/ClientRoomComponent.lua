-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientRoomComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local RoomConst = require("Common.Const.RoomConst")
local MessageName = require("Const.MessageName")
local ClientRoomComponent = class.Component("ClientRoomComponent")

function ClientRoomComponent:ctor()
	return
end

function ClientRoomComponent:init(avtDict)
	return true
end

function ClientRoomComponent:start()
	pg.game.pvp:checkPvpState()
end

function ClientRoomComponent:stop()
	return
end

function ClientRoomComponent:destroy()
	return
end

function ClientRoomComponent:playerGetReady(checkCb)
	self:serverMsg("RPC_CS_PlayerGetReady", "rpc_waitingEnterWorld", {}, checkCb)
end

function ClientRoomComponent:notifyPetSelectChange(args, checkCb)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_CS_NotifyPetSelectChange")
	end

	self:serverMsg("RPC_CS_NotifyPetSelectChange", "rpc_othersPetSelectChange", args, checkCb)
end

function ClientRoomComponent:rpc_otherPlayerConfirm()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("otherPlayerConfirm")
	end
end

function ClientRoomComponent:rpc_waitingEnterWorld(playerStatus, matchInfo)
	if playerStatus == RoomConst.ROOM_OTHER_PLAYER_READY then
		facade:sendMsgToUI(MessageName.PVP_ENEMY_GET_READY)
	elseif playerStatus == RoomConst.ROOM_ALL_PLAYER_READY then
		facade:sendMsgToUI(MessageName.PVP_BOTH_GET_READY, matchInfo)
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("waitingEnterWorld playerStatus = %s", playerStatus)
	end

	local _h = ClientRoomComponent._platformHooks

	if _h and _h.rpc_waitingEnterWorld then
		_h.rpc_waitingEnterWorld(self, playerStatus, matchInfo)
	end
end

function ClientRoomComponent:rpc_othersPetSelectChange(param)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("othersPetSelectChange param = %s", inspect(param))
	end

	facade:sendMsgToUI(MessageName.PVP_PET_SELECT, param)
end

function ClientRoomComponent:RPC_SC_RoomAbnormalExit(failParam)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_RoomAbnormalExit, failParam = %s", inspect(failParam))
	end

	pg.game.pvp:closeUnexpectedly()
end

return ClientRoomComponent
