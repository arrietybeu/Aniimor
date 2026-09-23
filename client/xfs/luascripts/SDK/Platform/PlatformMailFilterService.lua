-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformMailFilterService.lua

local ClientRepo = require("Core.Client.ClientRepo")
local PlatformCommunicationService = require("SDK.Platform.PlatformCommunicationService")
local PlatformSocialService = require("SDK.Platform.PlatformSocialService")
local logger = require("SDK.Platform.PlatformLogger")
local PlatformMailFilterService = {}

PlatformMailFilterService.Decision = {
	Block = "block",
	Pending = "pending",
	Allow = "allow",
	Unknown = "unknown"
}
PlatformMailFilterService.REASON_NOT_GIFT_MAIL = "not_gift_mail"
PlatformMailFilterService.REASON_NO_SENDER_UID = "no_sender_uid"
PlatformMailFilterService.REASON_NO_PLAYER_INFO = "no_player_info"
PlatformMailFilterService.REASON_PLATFORM_BLOCK_LIST = "platform_block_list"
PlatformMailFilterService.REASON_PLATFORM_BLOCK_LIST_PENDING = "platform_block_list_pending"
PlatformMailFilterService.REASON_PLATFORM_BLOCK_LIST_UNAVAILABLE = "platform_block_list_unavailable"
PlatformMailFilterService.REASON_PLATFORM_BLOCK_LIST_ERROR = "platform_block_list_error"
PlatformMailFilterService.REASON_LOCAL_COMMUNICATION_BLOCKED = "local_communication_blocked"
PlatformMailFilterService.REASON_LOCAL_COMMUNICATION_FRIENDS_ONLY = "local_communication_friends_only"
PlatformMailFilterService.REASON_LOCAL_COMMUNICATION_POLICY_PENDING = "local_communication_policy_pending"
PlatformMailFilterService.REASON_LOCAL_COMMUNICATION_FRIEND_STATUS_PENDING = "local_communication_friend_status_pending"
PlatformMailFilterService.REASON_LOCAL_COMMUNICATION_UNKNOWN = "local_communication_unknown"
PlatformMailFilterService.DEFAULT_PENDING_RECHECK_INTERVAL = 0.5
PlatformMailFilterService.DEFAULT_PENDING_RECHECK_ATTEMPTS = 10

function PlatformMailFilterService.makeContext(decision, reason, extra)
	local context = {
		decision = decision,
		reason = reason
	}

	if type(extra) == "table" then
		for k, v in pairs(extra) do
			context[k] = v
		end
	end

	return context
end

function PlatformMailFilterService.getTimer()
	return pg and pg.global and type(pg.global.timer) == "table" and type(pg.global.timer.delayCall) == "function" and pg.global.timer or nil
end

function PlatformMailFilterService.decodeGiftInfo(giftInfo)
	if type(giftInfo) ~= "string" then
		return giftInfo
	end

	local ok, decoded = pcall(function()
		return ClientRepo.protoCodec:decode(giftInfo)
	end)

	if ok then
		return decoded
	end

	return nil
end

function PlatformMailFilterService:isGiftMail(mail)
	return type(mail) == "table" and type(mail.Params) == "table" and mail.Params.giftInfo ~= nil
end

function PlatformMailFilterService:getGiftMailSenderUid(mail)
	if not self:isGiftMail(mail) then
		return nil
	end

	local giftInfo = PlatformMailFilterService.decodeGiftInfo(mail.Params.giftInfo)

	if type(giftInfo) ~= "table" then
		return nil
	end

	if not string.isNilOrEmpty(giftInfo.giverUid) then
		return tostring(giftInfo.giverUid)
	end

	if type(giftInfo.customData) == "table" and not string.isNilOrEmpty(giftInfo.customData.giverUid) then
		return tostring(giftInfo.customData.giverUid)
	end

	return nil
end

function PlatformMailFilterService:getMailSenderUid(mail)
	return self:getGiftMailSenderUid(mail)
end

function PlatformMailFilterService.peekPlatformBlocked(playerInfo)
	if type(playerInfo) ~= "table" then
		return false, PlatformMailFilterService.REASON_NO_PLAYER_INFO
	end

	if type(PlatformSocialService.peekPlatformUserBlockedByLocalUser) ~= "function" then
		return false, PlatformMailFilterService.REASON_PLATFORM_BLOCK_LIST_UNAVAILABLE
	end

	local ok, blocked = pcall(function()
		return PlatformSocialService:peekPlatformUserBlockedByLocalUser(playerInfo)
	end)

	if not ok then
		logger:warn("mail_filter_platform_block_check_failed err=%s", tostring(blocked))

		return false, PlatformMailFilterService.REASON_PLATFORM_BLOCK_LIST_ERROR, blocked
	end

	return blocked, nil
end

function PlatformMailFilterService.peekIsPlatformFriend(playerInfo)
	if type(playerInfo) ~= "table" then
		return nil
	end

	if type(PlatformSocialService.peekIsPlatformFriend) == "function" then
		return PlatformSocialService:peekIsPlatformFriend(playerInfo)
	end

	return playerInfo.isPlatformFriend == true
end

function PlatformMailFilterService.evaluateLocalCommunication(service, senderUid, playerInfo)
	local ok, policy = pcall(function()
		return PlatformCommunicationService:requireLocalCommunicationPolicy(PlatformCommunicationService.Channel.Text)
	end)

	if not ok then
		return false, service.Decision.Pending, PlatformMailFilterService.makeContext(service.Decision.Pending, PlatformMailFilterService.REASON_LOCAL_COMMUNICATION_POLICY_PENDING, {
			senderUid = senderUid,
			error = policy,
			channel = PlatformCommunicationService.Channel.Text
		})
	end

	if not policy then
		return false, service.Decision.Pending, PlatformMailFilterService.makeContext(service.Decision.Pending, PlatformMailFilterService.REASON_LOCAL_COMMUNICATION_POLICY_PENDING, {
			senderUid = senderUid,
			channel = PlatformCommunicationService.Channel.Text
		})
	end

	local setting = policy.setting
	local Setting = PlatformCommunicationService.CommunicationSetting

	if setting == Setting.Anyone or setting == Setting.Fallback then
		return false, service.Decision.Allow, PlatformMailFilterService.makeContext(service.Decision.Allow, policy.reason or "allowed", {
			senderUid = senderUid,
			channel = PlatformCommunicationService.Channel.Text,
			communicationSetting = setting,
			audiencePolicy = PlatformCommunicationService.AudiencePolicy.Everyone
		})
	end

	if setting == Setting.Blocked then
		return true, service.Decision.Block, PlatformMailFilterService.makeContext(service.Decision.Block, PlatformMailFilterService.REASON_LOCAL_COMMUNICATION_BLOCKED, {
			senderUid = senderUid,
			channel = PlatformCommunicationService.Channel.Text,
			communicationSetting = setting,
			audiencePolicy = PlatformCommunicationService.AudiencePolicy.Blocked
		})
	end

	if setting == Setting.Friends then
		local isPlatformFriend = PlatformMailFilterService.peekIsPlatformFriend(playerInfo)

		if isPlatformFriend == true then
			return false, service.Decision.Allow, PlatformMailFilterService.makeContext(service.Decision.Allow, policy.reason or "platform_friend", {
				senderUid = senderUid,
				channel = PlatformCommunicationService.Channel.Text,
				communicationSetting = setting,
				audiencePolicy = PlatformCommunicationService.AudiencePolicy.FriendsOnly
			})
		end

		if isPlatformFriend == nil then
			return false, service.Decision.Pending, PlatformMailFilterService.makeContext(service.Decision.Pending, PlatformMailFilterService.REASON_LOCAL_COMMUNICATION_FRIEND_STATUS_PENDING, {
				senderUid = senderUid,
				channel = PlatformCommunicationService.Channel.Text,
				communicationSetting = setting,
				audiencePolicy = PlatformCommunicationService.AudiencePolicy.FriendsOnly
			})
		end

		return true, service.Decision.Block, PlatformMailFilterService.makeContext(service.Decision.Block, PlatformMailFilterService.REASON_LOCAL_COMMUNICATION_FRIENDS_ONLY, {
			senderUid = senderUid,
			channel = PlatformCommunicationService.Channel.Text,
			communicationSetting = setting,
			audiencePolicy = PlatformCommunicationService.AudiencePolicy.FriendsOnly
		})
	end

	return false, service.Decision.Pending, PlatformMailFilterService.makeContext(service.Decision.Pending, PlatformMailFilterService.REASON_LOCAL_COMMUNICATION_UNKNOWN, {
		senderUid = senderUid,
		channel = PlatformCommunicationService.Channel.Text,
		communicationSetting = setting
	})
end

function PlatformMailFilterService:evaluateMail(mail, playerInfo)
	if not self:isGiftMail(mail) then
		return false, self.Decision.Allow, PlatformMailFilterService.makeContext(self.Decision.Allow, PlatformMailFilterService.REASON_NOT_GIFT_MAIL)
	end

	local senderUid = self:getMailSenderUid(mail)

	if string.isNilOrEmpty(senderUid) then
		return false, self.Decision.Unknown, PlatformMailFilterService.makeContext(self.Decision.Unknown, PlatformMailFilterService.REASON_NO_SENDER_UID)
	end

	if type(playerInfo) ~= "table" then
		return false, self.Decision.Pending, PlatformMailFilterService.makeContext(self.Decision.Pending, PlatformMailFilterService.REASON_NO_PLAYER_INFO, {
			senderUid = senderUid
		})
	end

	local blocked, reason, err = PlatformMailFilterService.peekPlatformBlocked(playerInfo)

	if blocked == true then
		return true, self.Decision.Block, PlatformMailFilterService.makeContext(self.Decision.Block, PlatformMailFilterService.REASON_PLATFORM_BLOCK_LIST, {
			senderUid = senderUid
		})
	end

	if blocked == nil then
		return false, self.Decision.Pending, PlatformMailFilterService.makeContext(self.Decision.Pending, PlatformMailFilterService.REASON_PLATFORM_BLOCK_LIST_PENDING, {
			senderUid = senderUid
		})
	end

	if reason == PlatformMailFilterService.REASON_PLATFORM_BLOCK_LIST_UNAVAILABLE or reason == PlatformMailFilterService.REASON_PLATFORM_BLOCK_LIST_ERROR then
		return false, self.Decision.Unknown, PlatformMailFilterService.makeContext(self.Decision.Unknown, reason, {
			senderUid = senderUid,
			error = err
		})
	end

	return PlatformMailFilterService.evaluateLocalCommunication(self, senderUid, playerInfo)
end

function PlatformMailFilterService:evaluateGiftMail(mail, playerInfo)
	if not self:isGiftMail(mail) then
		return false, self.Decision.Allow, PlatformMailFilterService.makeContext(self.Decision.Allow, PlatformMailFilterService.REASON_NOT_GIFT_MAIL)
	end

	return self:evaluateMail(mail, playerInfo)
end

function PlatformMailFilterService:shouldFilterMail(mail, playerInfo)
	local shouldFilter, decision, context = self:evaluateMail(mail, playerInfo)

	return shouldFilter == true, decision, context
end

function PlatformMailFilterService:shouldFilterGiftMail(mail, playerInfo)
	local shouldFilter, decision, context = self:evaluateGiftMail(mail, playerInfo)

	return shouldFilter == true, decision, context
end

function PlatformMailFilterService:resolvePendingMail(mail, playerInfo, onResolved, options)
	if type(onResolved) ~= "function" then
		return false
	end

	local _, decision, context = self:evaluateMail(mail, playerInfo)

	if decision ~= self.Decision.Pending then
		onResolved(decision, context)

		return false
	end

	local timer = PlatformMailFilterService.getTimer()

	if not timer then
		return false
	end

	options = options or {}

	local interval = options.interval or PlatformMailFilterService.DEFAULT_PENDING_RECHECK_INTERVAL
	local attemptsLeft = options.maxAttempts or PlatformMailFilterService.DEFAULT_PENDING_RECHECK_ATTEMPTS

	function PlatformMailFilterService.recheck()
		local _, currentDecision, currentContext = self:evaluateMail(mail, playerInfo)

		if currentDecision ~= self.Decision.Pending or attemptsLeft <= 1 then
			onResolved(currentDecision, currentContext)

			return
		end

		attemptsLeft = attemptsLeft - 1

		timer:delayCall(interval, PlatformMailFilterService.recheck)
	end

	timer:delayCall(interval, PlatformMailFilterService.recheck)

	return true
end

function PlatformMailFilterService:resolvePendingGiftMail(mail, playerInfo, onResolved, options)
	if not self:isGiftMail(mail) then
		if type(onResolved) == "function" then
			onResolved(self.Decision.Allow, PlatformMailFilterService.makeContext(self.Decision.Allow, PlatformMailFilterService.REASON_NOT_GIFT_MAIL))
		end

		return false
	end

	return self:resolvePendingMail(mail, playerInfo, onResolved, options)
end

return PlatformMailFilterService
