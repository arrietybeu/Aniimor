-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\EntityMixin\\ImpPlatformImpChatMail.lua

local M = {}
local MessageName = require("Const.MessageName")
local PlatformMailFilterService = require("SDK.Platform.PlatformMailFilterService")

M.pendingMailFilterChecks = {}
M.pendingMailSenderInfoQueries = {}

function M.normalizeMailId(mailId)
	if mailId == nil then
		return nil
	end

	local normalizedMailId = tostring(mailId)

	if string.isNilOrEmpty(normalizedMailId) then
		return nil
	end

	return normalizedMailId
end

function M.hasRawMail(chat, mailId)
	mailId = M.normalizeMailId(mailId)

	if string.isNilOrEmpty(mailId) or type(chat.ensureRawMails) ~= "function" then
		return false
	end

	local _, rawById = chat:ensureRawMails()

	return rawById[mailId] ~= nil
end

function M.getMailSenderInfo(mail)
	local uid = PlatformMailFilterService:getMailSenderUid(mail)

	if string.isNilOrEmpty(uid) then
		return false
	end

	return uid, pg and pg.game and pg.game.chat and pg.game.chat:getPlayerInfo(uid)
end

function M.requestMailSenderInfo(chat, uid, mailId)
	if string.isNilOrEmpty(uid) or M.pendingMailSenderInfoQueries[uid] then
		return false
	end

	if not pg or not pg.me or type(pg.me.queryPlayerInfo) ~= "function" then
		return false
	end

	M.pendingMailSenderInfoQueries[uid] = true

	pg.me:queryPlayerInfo(uid, nil, true, function(playerData)
		M.pendingMailSenderInfoQueries[uid] = nil

		if type(playerData) ~= "table" or not M.hasRawMail(chat, mailId) then
			return
		end

		if type(chat.refreshPlatformFilteredMails) == "function" then
			chat:refreshPlatformFilteredMails("mail_sender_info_resolved")
		end
	end)

	return true
end

function M.scheduleMailFilterCheck(chat, mail)
	local mailId = M.normalizeMailId(mail and (mail.MailId or mail.id))

	if string.isNilOrEmpty(mailId) or M.pendingMailFilterChecks[mailId] then
		return
	end

	local uid, senderInfo = M.getMailSenderInfo(mail)

	if string.isNilOrEmpty(uid) then
		return
	end

	if type(senderInfo) ~= "table" then
		M.requestMailSenderInfo(chat, uid, mailId)
	end

	function M.applyDecision()
		M.pendingMailFilterChecks[mailId] = nil

		if not M.hasRawMail(chat, mailId) then
			return
		end

		if type(chat.refreshPlatformFilteredMails) == "function" then
			chat:refreshPlatformFilteredMails("pending_mail_filter")
		end
	end

	M.pendingMailFilterChecks[mailId] = true

	local resolved = false
	local scheduled = false
	local timer = pg and pg.global and pg.global.timer

	if timer and type(timer.delayCall) == "function" then
		local attemptsLeft = 10

		function M.recheck()
			local _, latestSenderInfo = M.getMailSenderInfo(mail)

			if type(latestSenderInfo) ~= "table" then
				M.requestMailSenderInfo(chat, uid, mailId)
			end

			local _, decision = PlatformMailFilterService:evaluateMail(mail, latestSenderInfo)

			if decision ~= PlatformMailFilterService.Decision.Pending then
				resolved = true

				M.applyDecision()

				return
			end

			if attemptsLeft <= 1 then
				M.pendingMailFilterChecks[mailId] = nil

				return
			end

			attemptsLeft = attemptsLeft - 1

			timer:delayCall(0.5, M.recheck)
		end

		timer:delayCall(0.5, M.recheck)

		scheduled = true
	else
		scheduled = PlatformMailFilterService:resolvePendingMail(mail, senderInfo, function(decision)
			resolved = true

			if decision ~= PlatformMailFilterService.Decision.Pending then
				M.applyDecision()
			else
				M.pendingMailFilterChecks[mailId] = nil
			end
		end)
	end

	if not scheduled and not resolved then
		M.pendingMailFilterChecks[mailId] = nil
	end
end

function M:shouldShowMail(mail)
	local _, senderInfo = M.getMailSenderInfo(mail)
	local shouldFilter, decision = PlatformMailFilterService:shouldFilterMail(mail, senderInfo)
	local mailId = M.normalizeMailId(mail and (mail.MailId or mail.id))

	if shouldFilter and not string.isNilOrEmpty(mailId) then
		M.pendingMailFilterChecks[mailId] = nil
	end

	return not shouldFilter, decision
end

function M:onVisibleMailPending(mail, decision)
	if decision == PlatformMailFilterService.Decision.Pending then
		M.scheduleMailFilterCheck(self, mail)
	end
end

function M:onMailRemoved(mailId)
	mailId = M.normalizeMailId(mailId)

	if not string.isNilOrEmpty(mailId) then
		M.pendingMailFilterChecks[mailId] = nil
	end
end

function M:refreshPlatformFilteredMails(reason)
	if type(self.rebuildVisibleMails) ~= "function" then
		return false
	end

	self:rebuildVisibleMails()
	facade:SendMessageCommand(MessageName.RECV_MAIL)
	facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)

	return true
end

return M
