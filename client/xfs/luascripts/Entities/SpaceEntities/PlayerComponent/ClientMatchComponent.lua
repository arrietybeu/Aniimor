-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientMatchComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local MatchConst = require("Common.Const.MatchConst")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local ClientMatchComponent = class.Component("ClientMatchComponent")

function ClientMatchComponent:ctor()
	return
end

function ClientMatchComponent:init(avtDict)
	return true
end

function ClientMatchComponent:destroy()
	return
end

function ClientMatchComponent:startPvpMatch(matchType, battleMode, checkCb)
	local _h = ClientMatchComponent._platformHooks

	if _h and _h.startPvpMatch and _h.startPvpMatch(self, matchType, battleMode, checkCb) then
		return
	end

	self:serverMsg("RPC_CS_StartMatch", matchType, battleMode, checkCb)
end

function ClientMatchComponent:cancelPvpMatch(checkCb)
	self:serverMsg("RPC_CS_StopMatch", checkCb)
end

function ClientMatchComponent:setTeamTemplate(res, recentId, fairMode, checkCb)
	self:serverMsg(fairMode and "RPC_CS_FairPVPModifyTeamInfo" or "RPC_CS_UnFairPVPModifyTeamInfo", res, recentId, checkCb)
end

function ClientMatchComponent:setPetInfo(res, templateId, checkCb)
	self:serverMsg("RPC_CS_FairPVPModifyPetInfo", res, templateId, checkCb)
end

function ClientMatchComponent:isMatchStatusInit()
	return self.matchState == Const.PLAYER_MATCH_STATUS.IDLE
end

function ClientMatchComponent:isMatchStatusInMatch()
	return self.matchStatus == MatchConst.MATCH_STATUS_IN_MATCH
end

function ClientMatchComponent:isMatchStateInInvite()
	return self.matchStatus == MatchConst.MATCH_STATUS_IN_INVITE
end

function ClientMatchComponent:isMatchStatusInNormalMatch()
	return self.matchStatus == MatchConst.MATCH_STATUS_IN_MATCH and (self.matchType == MatchConst.MatchTypePVP1V1_Fair or self.matchType == MatchConst.MatchTypePVP1V1_UnFair)
end

function ClientMatchComponent:isMatchStatusInCovenantMatch()
	return self.matchStatus == MatchConst.MATCH_STATUS_IN_MATCH and self.matchType == MatchConst.MatchTypeInvitePVP1V1_Fair
end

function ClientMatchComponent:isMatchStatusInModify()
	return self.matchStatus == MatchConst.MATCH_STATUS_IN_MODIFYTEAM
end

function ClientMatchComponent:isMatchStatusInRoom()
	return self.matchStatus == MatchConst.MATCH_STATUS_IN_ROOM
end

function ClientMatchComponent:isMatchStatusInDungeon()
	return self.matchStatus == MatchConst.MATCH_STATUS_IN_DUNGEON
end

function ClientMatchComponent:isMatchStatusInCovenantResult()
	return self.matchStatus == MatchConst.MATCH_STATUS_IN_DUNGEON and self.matchType == MatchConst.MatchTypeInvitePVP1V1_Fair
end

function ClientMatchComponent:isMatchStatusInCovenantAgain()
	return self.matchStatus == MatchConst.MATCH_STATUS_IN_MARKAGAIN
end

function ClientMatchComponent:on_matchStatus_changed(old, new)
	if new == MatchConst.MATCH_STATUS_IN_MATCH then
		pg.game.pvp:setCovenantState(true)
	elseif new == MatchConst.MATCH_STATUS_INIT or new == MatchConst.MATCH_STATUS_IN_ROOM then
		pg.global.ui.tips:onSetInviteState({
			state = "InviteHide"
		})
		pg.global.ui.tips:onSetInviteState({
			state = "PrepareHide"
		})
		pg.game.pvp:setCovenantState(false)
	end

	facade:sendMsgToUI(MessageName.PVP_MATCH_STATE_CHANGED)
end

function ClientMatchComponent:pvpBattleInvite(uid)
	if self:isInSpecialState() then
		return false
	end

	self:serverMsg("RPC_CS_PvpBattleInvite", uid)
end

function ClientMatchComponent:RPC_SC_PvpBattleInviteResult(inviteeUid, result, endTime)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_PvpBattleInviteResult: Player invite pvp battle inviteeUid = %s result = %s, endTime = %s", inviteeUid, result, endTime)
	end

	if result == MatchConst.INVITE_RESULT.SUCCESS then
		local Time = require("Core.Common.Time")

		pg.global.ui.tips:onSetInviteState({
			state = "InviteShow",
			mode = 1,
			endTime = endTime,
			duration = endTime - Time.secondCache
		})
		facade:sendMsgToUI(MessageName.PVP_RECEIVE_COVENANT, inviteeUid, endTime)
	elseif result == MatchConst.INVITE_RESULT.CHECK_FAILED then
		pg.global.ui.tips:onSetInviteState({
			state = "InviteHide"
		})
	elseif result == MatchConst.INVITE_RESULT.TIME_OUT then
		pg.global.ui.tips:onSetInviteState({
			state = "InviteHide"
		})
		facade:sendMsgToUI(MessageName.PVP_DETAIL_COVENANT_BATTLE, {
			state = 2,
			rivalUid = inviteeUid
		})
	end
end

function ClientMatchComponent:RPC_SC_RecivePvpBattleInvite(inviterUid, endTime)
	if self:isInSpecialState() then
		-- block empty
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_RecivePvpBattleInvite: Player accept invite pvp battle, inviterUid = %s", inviterUid)
	end

	local Time = require("Core.Common.Time")

	pg.global.ui.tips:onPvpInvite({
		endTime = endTime,
		duration = endTime - Time.secondCache,
		uid = inviterUid
	})
end

function ClientMatchComponent:acceptInvitePvpBattle(uid, accept)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("acceptInvitePvpBattle: Player accept pvp battle")
	end

	self:serverMsg("RPC_CS_AcceptPvpBattleInvite", uid, accept)
end

function ClientMatchComponent:RPC_SC_RecivePvpBattleInviteResult(inviteeUid)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_RecivePvpBattleInviteResult: Player refuse pvp battle")
	end

	pg.global.ui.tips:onSetInviteState({
		state = "InviteHide"
	})
	pg.global.showBubbleMessageRaw(pg.getGameString("MATCH_REJECTED"), 3)
	facade:sendMsgToUI(MessageName.PVP_DETAIL_COVENANT_BATTLE, {
		state = 0,
		rivalUid = uid
	})
end

function ClientMatchComponent:RPC_SC_ReciveAcceptPvpBattle(rivalUid, endTime)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_ReciveAcceptPvpBattle: Player accept pvp battle, rivalUid = %s, endTime = %s", rivalUid, endTime)
	end

	pg.game.pvp:setRivalUID(rivalUid)
	pg.global.ui.tips:onSetInviteState({
		mode = 2,
		state = "InviteShow"
	})

	local TimerManager = require("Core.Timer.TimerManager")

	TimerManager.addTimer(1, function()
		pg.global.ui.tips:onSetInviteState({
			state = "InviteHide"
		})

		local Time = require("Core.Common.Time")

		pg.global.ui.tips:onSetInviteState({
			state = "PrepareShow",
			endTime = endTime,
			duration = endTime - Time.secondCache,
			uid = rivalUid
		})

		local LuaUIUtils = require("Utils.LuaUIUtils")

		LuaUIUtils.openPVPMenu(1)
	end)
	facade:sendMsgToUI(MessageName.PVP_DETAIL_COVENANT_BATTLE, {
		state = 1,
		rivalUid = rivalUid
	})
end

function ClientMatchComponent:cancelPvpBattle()
	self:serverMsg("RPC_CS_CanclePvpBattle")
end

function ClientMatchComponent:RPC_SC_ReciveCancelPvpBattleResult(rivalUid, result)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_ReciveCancelPvpBattleResult: Player cancel pvp battle result = %s", result)
	end

	pg.global.ui.tips:onSetInviteState({
		state = "PrepareHide"
	})
	facade:sendMsgToUI(MessageName.PVP_MATCH_STATE_CHANGED)
	facade:sendMsgToUI(MessageName.PVP_MATCH_COVENANT_CANCEL)
end

function ClientMatchComponent:confirmInvitePVPTeamInfo(rivalUid)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("confirmInvitePVPTeamInfo: Player confirm pvp battle team info, rivalUid = %s", rivalUid)
	end

	self:serverMsg("RPC_CS_ConfirmInvitePVPTeamInfo", rivalUid)
end

function ClientMatchComponent:requestPvpBattleAgain(callback)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("requestPvpBattleAgain: Player request pvp battle again")
	end

	self:serverMsg("RPC_CS_PVPBattleAgain", callback)
end

function ClientMatchComponent:RPC_SC_ReciveRivalPvpAgain(info)
	local rivalUid, isAgain = info[1], info[2]

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_ReciveRivalPvpAgain: rivalUid = %s, isAgain = %s", rivalUid, isAgain)
	end

	facade:sendMsgToUI(MessageName.PVP_DETAIL_COVENANT_AGAIN, {
		uid = rivalUid,
		isAgain = isAgain
	})
end

function ClientMatchComponent:isInSpecialState()
	return
end

function ClientMatchComponent:onOtherInterface()
	return
end

function ClientMatchComponent:RPC_SC_EnterRoomSucc(roomPlayersInfo)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_EnterRoomSucc: Player enter room success, playersPresetInfo = %s, otherPlayerInfo = %s", roomPlayersInfo.playersPresetInfo, roomPlayersInfo.otherPlayerInfo)
	end

	pg.game.pvp:enterRoom(roomPlayersInfo)

	local _h = ClientMatchComponent._platformHooks

	if _h and _h.RPC_SC_EnterRoomSucc then
		_h.RPC_SC_EnterRoomSucc(self, roomPlayersInfo)
	end
end

function ClientMatchComponent:RPC_SC_SwitchMasterPet()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_SwitchMasterPet: switch pet")
	end

	facade:sendMsgToUI(MessageName.PVP_SWITCH_MASTER_PET)
end

return ClientMatchComponent
