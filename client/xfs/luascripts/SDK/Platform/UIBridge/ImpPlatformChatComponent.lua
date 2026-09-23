-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformChatComponent.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local PlatformDisplayNameInjector = require("SDK.Platform.UIBridge.PlatformDisplayNameInjector")
local PlatformDisplayNameConfig = require("SDK.Platform.UIBridge.PlatformDisplayNameConfig")

M.CONFIG = PlatformDisplayNameConfig.UI_Node_ChatPanel_Message

function M.isSelfUid(uid)
	return not string.isNilOrEmpty(uid) and pg and pg.me and tostring(uid) == tostring(pg.me.uid)
end

function M.isFriendChatGroup(channelInfo)
	if type(channelInfo) ~= "table" then
		return false
	end

	local chatSystem = pg and pg.game and pg.game.chat

	if not chatSystem then
		return false
	end

	if channelInfo.type == chatSystem.channelType.Group then
		return true
	end

	return chatSystem.getFriendChatGroup and chatSystem:getFriendChatGroup(channelInfo.channelId) ~= nil
end

function M.getChatChannelName(playerId, playerInfo, rawName)
	if string.isNilOrEmpty(playerId) or M.isSelfUid(playerId) or string.isNilOrEmpty(rawName) then
		return rawName
	end

	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.ChatChannelName,
		uid = playerId,
		playerInfo = playerInfo,
		rawText = rawName
	})
end

function M.getVisibleChatChannelName(playerId, playerInfo, rawName)
	local displayName = M.getChatChannelName(playerId, playerInfo, rawName)

	if string.isNilOrEmpty(displayName) then
		return nil
	end

	return displayName
end

function M.getChatMessagePlayerName(data, playerInfo, rawName)
	if type(data) ~= "table" or string.isNilOrEmpty(data.playerId) or string.isNilOrEmpty(rawName) then
		return nil
	end

	if type(playerInfo) ~= "table" then
		return nil
	end

	local displayName = PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.ChatMessagePlayerName,
		uid = data.playerId,
		playerInfo = playerInfo,
		rawText = rawName
	})

	return PlatformDisplayNameInjector.getDisplayName({
		playerInfo = playerInfo,
		config = M.CONFIG,
		rawName = displayName
	})
end

function M.enableMessageNameRichText(button, isPopName)
	if PlatformDisplayNameInjector.isUnityNil(button) or not button.GetChild then
		return false
	end

	local ok, textNode = pcall(function()
		local nameRoot = button

		if isPopName then
			nameRoot = button:GetChild("Pop"):GetChild("Name")
		end

		return nameRoot:GetChild("TxtName"):GetComponent("UBaseText")
	end)

	if not ok then
		return false
	end

	return PlatformDisplayNameInjector.enableRichText(textNode)
end

function M:replyMessageName(data, playerInfo, rawName)
	if type(data) ~= "table" or string.isNilOrEmpty(data.playerId) or string.isNilOrEmpty(rawName) then
		return nil
	end

	local playerId = data.playerId

	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.ChatMessagePlayerName,
		uid = playerId,
		playerInfo = playerInfo,
		rawText = rawName
	})
end

function M:renderMessageRootPlayerName(button, data, playerInfo, rawName)
	M.enableMessageNameRichText(button, false)

	return M.getChatMessagePlayerName(data, playerInfo, rawName)
end

function M:renderMessagePopPlayerName(button, data, playerInfo, rawName)
	M.enableMessageNameRichText(button, true)

	return M.getChatMessagePlayerName(data, playerInfo, rawName)
end

function M:renderChannelLastMessagePlayerName(button, messageInfo, senderInfo, rawName)
	if type(messageInfo) ~= "table" or type(senderInfo) ~= "table" then
		return nil
	end

	local playerId = messageInfo.playerId

	if string.isNilOrEmpty(playerId) or M.isSelfUid(playerId) then
		return nil
	end

	if string.isNilOrEmpty(rawName) then
		return nil
	end

	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.ChatChannelLastMessagePlayerName,
		uid = playerId,
		playerInfo = senderInfo,
		rawText = rawName
	})
end

function M.renderChannelItemName(data, playerInfo, rawName)
	return M.getChatChannelName(data and data.playerId, playerInfo, rawName)
end

function M.renderGroupChannelDisplayName(data, rawName)
	local chatGroup = pg and pg.game and pg.game.chat and pg.game.chat:getFriendChatGroup(data and data.channelId)

	if chatGroup and pg.game.chat.getChatGroupDisplayName then
		return pg.game.chat:getChatGroupDisplayName(chatGroup, rawName)
	end

	return rawName
end

function M:refreshChatMessageTitleName(channelInfo, playerInfo, rawName)
	if M.isFriendChatGroup(channelInfo) then
		local chatGroup = pg and pg.game and pg.game.chat and pg.game.chat:getFriendChatGroup(channelInfo and channelInfo.channelId)

		if chatGroup and pg.game.chat.getChatGroupDisplayName then
			return pg.game.chat:getChatGroupDisplayName(chatGroup, rawName)
		end

		return rawName
	end

	local displayName = M.getVisibleChatChannelName(channelInfo and channelInfo.playerId, playerInfo, rawName)

	return displayName
end

return M
