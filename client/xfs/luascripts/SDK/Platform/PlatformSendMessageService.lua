-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformSendMessageService.lua

local PlatformCommunicationService = require("SDK.Platform.PlatformCommunicationService")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformSocialService = require("SDK.Platform.PlatformSocialService")
local Const = require("Common.Const.Const")
local logger = require("SDK.Platform.PlatformLogger")
local PlatformSendMessageService = {}

PlatformSendMessageService.DENIED_TIP_KEY_BY_CHANNEL = {}
PlatformSendMessageService.DENIED_TIP_KEY_BY_CHANNEL[PlatformCommunicationService.Channel.Text] = "PRIVACY_SETTING_MISSMATCH"
PlatformSendMessageService.DENIED_TIP_KEY_BY_CHANNEL[PlatformCommunicationService.Channel.Voice] = "PRIVACY_SETTING_MISSMATCH"

function PlatformSendMessageService.resolveMessageType(context)
	context = context or {}

	if context.messageType ~= nil then
		return context.messageType
	end

	if type(context.message) == "string" then
		return string.sub(context.message, 1, 1)
	end

	return nil
end

function PlatformSendMessageService.resolvePermissionChannel(context)
	local messageType = PlatformSendMessageService.resolveMessageType(context)

	if pg and pg.game and pg.game.chat and messageType == pg.game.chat.subMessageType.Audio then
		return PlatformCommunicationService.Channel.Voice
	end

	return PlatformCommunicationService.Channel.Text
end

function PlatformSendMessageService.isPrivateChat(channelType)
	if channelType == nil then
		return false
	end

	if Const and Const.CHAT_TYPE and channelType == Const.CHAT_TYPE.PRIVATE then
		return true
	end

	return pg and pg.game and pg.game.chat and channelType == pg.game.chat.channelType.Player
end

function PlatformSendMessageService.resolvePlayerInfo(context)
	context = context or {}

	if type(context.playerInfo) == "table" then
		return context.playerInfo
	end

	if not PlatformSendMessageService.isPrivateChat(context.channelType) and not PlatformSendMessageService.isPrivateChat(context.type) then
		return nil
	end

	local chatSystem = context.chatSystem

	if chatSystem and type(chatSystem.getPlayerInfo) == "function" then
		return chatSystem:getPlayerInfo(context.channelId)
	end

	if pg and pg.game and pg.game.chat and type(pg.game.chat.getPlayerInfo) == "function" and context.targetId ~= nil then
		return pg.game.chat:getPlayerInfo(context.targetId)
	end

	return nil
end

function PlatformSendMessageService.isPlatformFriend(playerInfo)
	return PlatformIdentityUtils and PlatformIdentityUtils.isPlatformFriend and PlatformIdentityUtils.isPlatformFriend(playerInfo) == true
end

function PlatformSendMessageService.supportsConsoleCommunication()
	return PlatformIdentityUtils and PlatformIdentityUtils.isConsoleFamily and PlatformIdentityUtils.isConsoleFamily(PlatformIdentityUtils.getCurrentPlatformFamily()) == true
end

function PlatformSendMessageService.isPlayStationPlatform()
	return PlatformIdentityUtils and PlatformIdentityUtils.getCurrentPlatformFamily() == PlatformIdentityUtils.Family.PlayStation
end

function PlatformSendMessageService.deny(channel, reason, policy, context)
	PlatformCommunicationService:notifyOutgoingCommunicationDenied(channel, reason, {
		notifyUser = true,
		deniedTipKey = PlatformSendMessageService.DENIED_TIP_KEY_BY_CHANNEL[channel]
	})
	logger:warn("platform_send_message_blocked channel=%s chatChannelType=%s setting=%s reason=%s", tostring(channel), tostring(context and context.channelType or ""), tostring(policy and policy.setting or ""), tostring(reason or ""))

	return false
end

function PlatformSendMessageService:init()
	return true
end

function PlatformSendMessageService:canSendMessage(context)
	context = context or {}

	local channel = PlatformSendMessageService.resolvePermissionChannel(context)

	if not PlatformSendMessageService.supportsConsoleCommunication() then
		return true
	end

	if context.isSystemMessage == true then
		return true
	end

	local isPrivateChat = PlatformSendMessageService.isPrivateChat(context.channelType) or PlatformSendMessageService.isPrivateChat(context.type)

	if PlatformSendMessageService.isPlayStationPlatform() and isPrivateChat then
		local playerInfo = PlatformSendMessageService.resolvePlayerInfo(context)

		if type(playerInfo) == "table" then
			local blocked = PlatformSocialService:peekPlatformUserBlockedByLocalUser(playerInfo)

			if blocked == true then
				return PlatformSendMessageService.deny(channel, "platform_block_list", nil, context)
			end
		end
	end

	local policy = PlatformCommunicationService:requireLocalCommunicationPolicy(channel)

	if not policy then
		logger:error("PlatformSendMessageService local communication policy missing, allow send: channel=%s messageType=%s channelType=%s channelId=%s chatType=%s targetId=%s", tostring(channel), tostring(PlatformSendMessageService.resolveMessageType(context)), tostring(context.channelType), tostring(context.channelId), tostring(context.type), tostring(context.targetId))

		return true
	end

	local Setting = PlatformCommunicationService.CommunicationSetting

	if policy.setting == Setting.Anyone or policy.setting == Setting.Fallback then
		return true
	end

	if policy.setting == Setting.Friends then
		local playerInfo = PlatformSendMessageService.resolvePlayerInfo(context)

		if isPrivateChat and PlatformSendMessageService.isPlatformFriend(playerInfo) then
			return true
		end

		return PlatformSendMessageService.deny(channel, "local_communication_friends_only", policy, context)
	end

	if policy.setting == Setting.Blocked then
		return PlatformSendMessageService.deny(channel, "local_communication_blocked", policy, context)
	end

	return PlatformSendMessageService.deny(channel, "local_communication_policy_invalid", policy, context)
end

return PlatformSendMessageService
