-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientHornComponent.lua

local class = require("Core.Framework.Class")
local GlobalData = require("Core.Client.GlobalData")
local Utils = require("Common.Utils.Utils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Const = require("Common.Const.Const")
local SocialTypeData = require("Data.social_type_data")
local ClientHornComponent = class.Component("ClientHornComponent")

function ClientHornComponent:ctor()
	self.cacheHornInfo = {}
end

function ClientHornComponent:destroy()
	self.cacheHornInfo = nil
end

function ClientHornComponent:EVENT_PostInitialized()
	local facePos = pg.game.social:getFacePos()

	if facePos then
		self:faceToPosition(facePos)
	end
end

function ClientHornComponent:reqSendHorn(invIdx, genId)
	if pg.me:isInTeam() then
		return
	end

	local reqInfo = {
		clientMsGate = {
			GlobalData.GlobalGateId,
			GlobalData.GlobalGateSessionId
		},
		friendUids = pg.me:getOnlineFriendList(SocialTypeData[Const.SOCIAL_TYPE.HORN].guidemaxNum)
	}

	self:serverMsg("RPC_CS_UseItem", invIdx, genId, 1, {
		reqInfo
	}, function(res, errorCode)
		if not res then
			pg.global.showBubbleMessage(errorCode)
		end
	end)
end

function ClientHornComponent:RPC_SC_ReqSendHornResult(reqRetInfo, flag, matchUids)
	self:reqSendHornResult(reqRetInfo, flag, matchUids)
end

function ClientHornComponent:reqSendHornResult(reqRetInfo, flag, matchUids)
	pg.game.social:onUseInviteItemResult(flag, reqRetInfo, matchUids)
end

function ClientHornComponent:reqStopHornAction()
	self:serverMsg("RPC_CS_ReqStopHornAction")
end

function ClientHornComponent:RPC_SC_OtherRequestEnterSpace(reqId, playerInfo)
	if pg.me:isInTeam() then
		return
	end

	pg.game.social:onOtherRequestEnterSpace(reqId, playerInfo)
end

function ClientHornComponent:RPC_SC_HornNotify(hornInfo)
	self:hornNotify(hornInfo)
end

function ClientHornComponent:hornNotify(hornInfo)
	if pg.me:isInTeam() then
		return
	end

	if self.space == nil or self.space.sceneId ~= 3000 and Utils.isSpacePhase(self.space.sceneId) ~= 3000 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("hornNotify failed player is not in main scene!", self:repr())
		end

		return
	end

	if self.clientSocialBossHatredMap ~= nil and #self.clientSocialBossHatredMap ~= 0 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("hornNotify failed cause clientSocialBossHatredMap!", self:repr())
		end

		return
	end

	if pg.game.cutscene:isInCutsceneState() then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("hornNotify failed cause player is in cutscene state!", self:repr())
		end

		return
	end

	pg.game.social:onInviteReceive(hornInfo)
end

function ClientHornComponent:ignoreHornNotify()
	self:serverMsg("RPC_CS_IgnoreHornNotify")
end

function ClientHornComponent:acceptHornNotify(hornInfo)
	if pg.me:isInTeam() then
		return
	end

	self.cacheHornInfo = hornInfo

	self:serverMsg("RPC_CS_AcceptHornNotify", hornInfo.uid, hornInfo.reqId)
end

function ClientHornComponent:RPC_SC_AcceptHornNotifyResult(flag, uid)
	self:acceptHornNotifyResult(flag, uid)
end

function ClientHornComponent:acceptHornNotifyResult(flag, uid)
	if pg.me:isInTeam() then
		return
	end

	if self.cacheHornInfo.uid ~= uid then
		return
	end

	pg.game.social:onAcceptInvitationResult(flag, self.cacheHornInfo.pos3)
end

return ClientHornComponent
