-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientMailComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local CallbackHandler = require("Core.Common.CallbackHandler")
local IDManager = require("Core.Common.IDManager")
local Const = require("Common.Const.Const")
local ClientUtils = require("Utils.ClientUtils")
local MessageName = require("Const.MessageName")
local ClientMailComponent = class.Component("ClientMailComponent")

function ClientMailComponent:ctor()
	return
end

function ClientMailComponent:init(avtDict)
	return true
end

function ClientMailComponent:destroy()
	return
end

function ClientMailComponent:getUserMailList(start, isInit)
	self:callService("MailService", "getUserMailList", {
		self.uid,
		start,
		Const.MAIL.PAGE_LIMIT
	}, CallbackHandler(self, "_getUserMailListCallback", isInit), {
		callerId = self.uid
	})
end

function ClientMailComponent:_getUserMailListCallback(isInit, result, resp)
	if result.status then
		-- block empty
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("%s ClientMailComponent _getUserMailListCallback failed;", self:repr(), inspect(result))
	end

	pg.game.chat:recvUserMailListCallback(result, resp, isInit)
end

function ClientMailComponent:getMailContent(mailId)
	local normalizedMailId = mailId

	mailId = IDManager.strToBytes(mailId)

	self:callService("MailService", "getMailContent", {
		self.uid,
		mailId
	}, CallbackHandler(self, "_getMailContentCallback", normalizedMailId), {
		callerId = self.uid
	})
end

function ClientMailComponent:_getMailContentCallback(mailId, result, resp)
	pg.game.chat:recvMailContentCallback(result, resp, mailId)
end

function ClientMailComponent:getMailContents(mailIds)
	if type(mailIds) ~= "table" or #mailIds == 0 then
		return
	end

	local normalizedMailIds = {}
	local mailIdBytes = {}

	for _, mailId in ipairs(mailIds) do
		normalizedMailIds[#normalizedMailIds + 1] = mailId
		mailIdBytes[#mailIdBytes + 1] = IDManager.strToBytes(mailId)
	end

	self:callService("MailService", "getMailContents", {
		self.uid,
		mailIdBytes
	}, CallbackHandler(self, "_getMailContentsCallback", normalizedMailIds), {
		callerId = self.uid
	})
end

function ClientMailComponent:_getMailContentsCallback(mailIds, result, resp)
	pg.game.chat:recvMailContentsCallback(result, resp, mailIds)
end

function ClientMailComponent:setMailHaveRead(mailId)
	mailId = IDManager.strToBytes(mailId)

	self:callService("MailService", "setMailHaveRead", {
		self.uid,
		mailId
	}, CallbackHandler(self, "_setMailHaveReadCallback"), {
		callerId = self.uid
	})
end

function ClientMailComponent:_setMailHaveReadCallback(result)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientMailComponent _setMailHaveReadCallback", self:repr(), inspect(result))
	end

	facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)
end

function ClientMailComponent:setAllMailHaveRead()
	self:callService("MailService", "setAllMailHaveRead", {
		self.uid
	}, CallbackHandler(self, "_setAllMailHaveReadCallback"), {
		callerId = self.uid
	})
end

function ClientMailComponent:_setAllMailHaveReadCallback(result)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientMailComponent _setAllMailHaveReadCallback", self:repr(), inspect(result))
	end
end

function ClientMailComponent:setMailGiftReceived(mailIds)
	for _, item in ipairs(mailIds) do
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("ClientMailComponent setMailGiftReceived: " .. item)
		end
	end

	self:serverMsg("RPC_CS_ReceiveMailGift", mailIds)
end

function ClientMailComponent:RPC_SC_ReceiveMailGift(mailIds)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientMailComponent RPC_SC_ReceiveMailGift", self:repr(), inspect(mailIds))
	end

	pg.game.chat:recvMailGift(mailIds)
end

function ClientMailComponent:setAllMailGiftReceived()
	self:serverMsg("RPC_CS_ReceiveAllMailGift")
end

function ClientMailComponent:deleteMail(mailIds)
	self:serverMsg("RPC_CS_DeleteMail", mailIds)
end

function ClientMailComponent:RPC_SC_DeleteMail(status, errmsg, mailIds)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientMailComponent RPC_SC_DeleteMail", self:repr(), inspect(mailIds), status, errmsg)
	end

	pg.game.chat:recvDeleteMail(status, errmsg, mailIds)
end

function ClientMailComponent:deleteReadedMail()
	self:serverMsg("RPC_CS_DeleteReadedMail")
end

function ClientMailComponent:RPC_SC_DeleteReadedMail(status, errmsg, deleteList)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientMailComponent RPC_SC_DeleteReadedMail", self:repr(), status, errmsg, inspect(deleteList))
	end

	pg.game.chat:recvDeleteReadedMail(status, errmsg, deleteList)
end

function ClientMailComponent:MailService_newMailNotice(mailInfo)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("Mailservice_newMailNotice", inspect(mailInfo))
	end

	pg.game.chat:recvNewMailNotice(mailInfo)
end

function ClientMailComponent:MailService_newGroupMailNotice(group)
	self:callService("MailService", "syncGroupMail", {
		self.uid,
		{
			group
		}
	}, CallbackHandler(self, "_newGroupMailNoticeCallback"), {
		callerId = self.uid
	})
end

function ClientMailComponent:_newGroupMailNoticeCallback(result)
	pg.game.chat:recvNewGroupMailNotice(result)
end

function ClientMailComponent:MailService_onMailDelete(mailInIds)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("MailService_onMailDelete", inspect(mailInIds))
	end

	pg.game.chat:recvDeleteMail(true, "", mailInIds)
end

function ClientMailComponent:RPC_SC_NotifyPullMail()
	self:getUserMailList(0)
end

function ClientMailComponent:RPC_SC_ShowMarqueeText(text, duration)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientMailComponent RPC_SC_ShowMarqueeText", self:repr())
	end

	pg.global.ui.tips:showMarqueeText(text, duration)
end

function ClientMailComponent:showMarqueeText(txtId, count)
	ClientUtils.addMarqueeText(txtId, count)
end

return ClientMailComponent
