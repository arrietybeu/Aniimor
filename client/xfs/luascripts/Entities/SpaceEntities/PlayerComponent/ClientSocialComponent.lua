-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientSocialComponent.lua

local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local SocialConst = require("Common.Const.SocialConst")
local PlatformSocialService = require("SDK.Platform.PlatformSocialService")
local ClientSocialComponent = Class.Component("ClientSocialComponent")

function ClientSocialComponent:ctor()
	self.curSocialInfo = nil
end

function ClientSocialComponent:RPC_SC_SocialQueryReply(soType, uid, replyInfoPkg)
	local success, replyInfo = unpack(replyInfoPkg)

	if not success then
		self.logger:error("RPC_SC_SocialQueryReply error", soType, uid, inspect(replyInfo))

		return
	end

	local funcName = SocialConst.SocialQueryDef[soType].clientRecvReplyFunc

	self[funcName](self, uid, replyInfo)
end

function ClientSocialComponent:RPC_SC_SocialInvite(soType, invitorUid, inviteInfo)
	pg.me:queryPlayerInfo(invitorUid, nil, true, function(invitorInfo)
		if PlatformSocialService:peekPlatformUserBlockedByLocalUser(invitorInfo) == true then
			return
		end

		local funcName = SocialConst.SocialInviteDef[soType].clientRecvInviteFunc

		self[funcName](self, invitorUid, inviteInfo)
	end)
end

function ClientSocialComponent:RPC_SC_SocialInviteReply(soType, inviteeUid, replyInfoPkg)
	local accept, replyInfo = unpack(replyInfoPkg)
	local funcName = SocialConst.SocialInviteDef[soType].clientRecvInviteReplyFunc

	self[funcName](self, inviteeUid, accept, replyInfo)
end

function ClientSocialComponent:RPC_SC_OnSocialStart(socialId, socialInfo)
	if self.curSocialId ~= socialId then
		self.logger:error("__social start error, curSocialId=%s, socialId=%s", self.curSocialId, socialId, "curSocialId must be sync first by server")

		return
	else
		self:_startSocial(socialInfo, false)
	end
end

function ClientSocialComponent:_startSocial(socialInfo, isResume)
	self.curSocialInfo = socialInfo

	local funcName = SocialConst.SocialProcessDef[self.curSocialInfo.socialType].clientStartSocialFunc

	self[funcName](self, socialInfo, isResume)
end

function ClientSocialComponent:onEnterSpace()
	if string.notNilOrEmpty(self.curSocialId) then
		self:sendSocialOperation(SocialConst.SB_CS_ResumeSocial, {})
		self.logger:debug("__social try resume, curSocialId=%s", self.curSocialId)
	end
end

function ClientSocialComponent:sendSocialOperation(op, params, callback)
	local socialId = self.curSocialId

	if string.isNilOrEmpty(socialId) then
		return
	end

	local localCallback = callback or function(result, resp)
		if (not result or ToInt(resp and resp.noticeId) ~= 0) and pg.logDebug() then
			self.logger:debug("__social operation reply, op=%s, params=%s, result=%s, resp=%s", op, inspect(params, {
				depth = 3
			}), result, inspect(resp, {
				depth = 3
			}))
		end
	end

	self:callService("SocialService", "CMD_ClientOperation", {
		self.uid,
		socialId,
		op,
		params
	}, localCallback, {
		hint = socialId
	})
end

function ClientSocialComponent:RPC_SC_SocialClientNotify(socialId, op, params)
	if self.curSocialId ~= socialId then
		self.logger:error("__social notify error, curSocialId=%s, socialId=%s", self.curSocialId, socialId, "curSocialId not match")

		return
	end

	if op == SocialConst.SB_SC_ResumeSocial then
		local socialInfo = params[1]

		self.logger:debug("__social resume success, curSocialId=%s, socialInfo=%s", self.curSocialId, inspect(socialInfo, {
			depth = 3
		}))
		self:_startSocial(socialInfo, true)

		return
	else
		local funcName = SocialConst.SocialProcessDef[self.curSocialInfo.socialType].clientNotifyFunc

		self[funcName](self, op, params)
	end
end

function ClientSocialComponent:RPC_SC_OnSocialEnd(socialId)
	if self.curSocialId ~= socialId then
		self.logger:error("__social end error, curSocialId=%s, socialId=%s", self.curSocialId, socialId, "curSocialId not match")

		return
	end

	local funcName = SocialConst.SocialProcessDef[self.curSocialInfo.socialType].clientEndSocialFunc

	self[funcName](self)

	self.curSocialInfo = nil
end

local function tryPlatformHook(methodName, self, ...)
	local _h = ClientSocialComponent._platformHooks

	return _h and _h[methodName] and _h[methodName](self, ...) == true
end

function ClientSocialComponent:syncPsnAuthCode(authCode)
	if string.isNilOrEmpty(authCode) then
		return
	end

	self:serverMsg("RPC_CS_SyncPsnAuthCode", authCode)
end

function ClientSocialComponent:RPC_SC_PsnAuthCodeRequired()
	tryPlatformHook("RPC_SC_PsnAuthCodeRequired", self)
end

return ClientSocialComponent
