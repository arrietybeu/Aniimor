-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientFluteComponent.lua

local class = require("Core.Framework.Class")
local GlobalData = require("Core.Client.GlobalData")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local SocialTypeData = require("Data.social_type_data")
local ClientUtils = require("Utils.ClientUtils")
local ClientFluteComponent = class.Component("ClientFluteComponent")

function ClientFluteComponent:ctor()
	return
end

function ClientFluteComponent:destroy()
	return
end

function ClientFluteComponent:RPC_SC_ReceiveFluteNotify(uid, reqId, pos, fluteGender, gender)
	self.logger:debug("@flute RPC_SC_ReceiveFluteNotify uid=%s reqId=%s pos=%s fluteGender=%s gender=%s", uid, reqId, inspect(pos), fluteGender, gender)
	pg.game.social:receiveFluteNotify(uid, reqId, pos, fluteGender, gender)
end

function ClientFluteComponent:RPC_SC_SendFluteNotifyResult(result, errNoticeId, reqId, startTs, notifyUids)
	self.logger:debug("@flute RPC_SC_SendFluteNotifyResult result=%s errNoticeId=%s reqId=%s startTs=%s matchUids=%s", result, errNoticeId, reqId, startTs, inspect(notifyUids))
	self:sendFluteNotifyResult(result, errNoticeId, reqId, startTs, notifyUids)
end

function ClientFluteComponent:sendFluteNotifyResult(result, errNoticeId, reqId, startTs, notifyUids)
	self.logger:debug("@flute sendFluteNotifyResult reqId=%s startTs=%s result=%s matchUids=%s", reqId, startTs, result, inspect(notifyUids))

	if not result then
		ClientUtils.showBubbleMessageById(errNoticeId)
	end

	if result == true then
		pg.game.social:playFluteCallback(reqId)
	end
end

function ClientFluteComponent:RPC_SC_ReplyFluteNotifyResult(result, errNoticeId, uid)
	self.logger:debug("@flute RPC_SC_ReplyFluteNotifyResult result=%s errNoticeId=%s uid=%s", result, errNoticeId, uid)
	self:replyFluteNotifyResult(result, errNoticeId, uid)
end

function ClientFluteComponent:replyFluteNotifyResult(result, errNoticeId, uid)
	self.logger:debug("@flute replyFluteNotifyResult result=%s errNoticeId=%s uid=%s", result, errNoticeId, uid)

	if not result then
		ClientUtils.showBubbleMessageById(errNoticeId)
	else
		pg.game.social:replyFluteNotifyCallBack()
	end
end

function ClientFluteComponent:receiveFluteNotifyReply(uid, pos)
	self.logger:debug("@flute receiveFluteNotifyReply uid=%s pos=%s", uid, inspect(pos))
	pg.game.social:receiveFluteNotifyReply(uid, pos)
end

function ClientFluteComponent:RPC_SC_AcceptFluteNotifyResult(result, errNoticeId, uid)
	self.logger:debug("@flute RPC_SC_AcceptFluteNotifyResult result=%s errNoticeId=%s uid=%s", result, errNoticeId, uid)
	self:acceptFluteNotifyResult(result, errNoticeId, uid)
end

function ClientFluteComponent:acceptFluteNotifyResult(result, errNoticeId, uid)
	self.logger:debug("@flute acceptFluteNotifyResult result=%s errNoticeId=%s uid=%s", result, errNoticeId, uid)

	if not result then
		ClientUtils.showBubbleMessageById(errNoticeId)
	end
end

function ClientFluteComponent:RPC_SC_FluteEnterRequestReceived(pos)
	self.logger:debug("@flute RPC_SC_FluteEnterRequestReceived  pos=%s", inspect(pos))
	pg.game.social:onAcceptFluteNotifyReply(pos)
end

function ClientFluteComponent:RPC_SC_OnFluteNotifyClosed()
	self.logger:debug("@flute RPC_SC_OnFluteNotifyClosed ")
	self:onFluteNotifyClosed()
end

function ClientFluteComponent:onFluteNotifyClosed()
	self.logger:debug("@flute onFluteNotifyClosed ")
	pg.game.social:onFluteNotifyClosed()
end

return ClientFluteComponent
