-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Discord\\UIBridge\\ImpDiscordPlayerCardCtrl.lua

local M = {}
local ClientTextUtils = require("Utils.ClientTextUtils")
local PlatformDisplayNameConfig = require("SDK.Platform.UIBridge.PlatformDisplayNameConfig")
local PlatformDisplayNameInjector = require("SDK.Platform.UIBridge.PlatformDisplayNameInjector")
local TimerManager = require("Core.Timer.TimerManager")
local DiscordFriendService = require("SDK.Discord.DiscordFriendService")

M.DISPLAY_NAME_CONFIG = PlatformDisplayNameConfig.UI_Pb_InfoPlayer_Card
M.DISCORD_ICON = "UI_CharID_Discord"
M.ADD_FRIEND_RESPONSE_FUNC = "addFriend"
M.DISCORD_FRIEND_INVITE_RESPONSE_FUNC = "inviteDiscordFriendToAddFriend"
M.DISCORD_ADD_FRIEND_LABEL = "DISCORD_ADD_FRIEND"

function M:isDiscordPlayerCard()
	local playerInfo = self and self.playerInfo

	return playerInfo and playerInfo.isDiscordFriend == true and not string.isNilOrEmpty(playerInfo.discordUserId)
end

function M:setDiscordPlayerBaseInfoName(rawName)
	if not M.isDiscordPlayerCard(self) or string.isNilOrEmpty(self.playerInfo.playerName) then
		return rawName
	end

	local tag = string.format("<sprite name=\"%s\">", M.DISCORD_ICON)

	return tag .. PlatformDisplayNameInjector.COMMON_BLANK .. tostring(self.playerInfo.playerName)
end

function M:setDiscordPlayerBaseInfoOnlineID()
	if not M.isDiscordPlayerCard(self) then
		return
	end

	local onlineIDNode, activeNode = PlatformDisplayNameInjector.resolveOnlineIDNodes(self.view and self.view.infoPlayerPanelObjectReference, M.DISPLAY_NAME_CONFIG)

	if PlatformDisplayNameInjector.isUnityNil(onlineIDNode) then
		return
	end

	local onlineID = tostring(self.playerInfo.discordDisplayName or "")
	local hasOnlineID = not string.isNilOrEmpty(onlineID)

	PlatformDisplayNameInjector.setNodeActive(activeNode, hasOnlineID)
	ClientTextUtils.setText(onlineIDNode, hasOnlineID and onlineID or "")
end

function M:setDiscordPlayerBaseInfo()
	if not M.isDiscordPlayerCard(self) then
		return
	end

	M.setDiscordPlayerBaseInfoOnlineID(self)
end

function M:addDiscordFriendInviteButton(interactData)
	if not M.isDiscordPlayerCard(self) or type(interactData) ~= "table" then
		return
	end

	local addFriendIndex

	for index, data in ipairs(interactData) do
		if data.responseFunc == M.DISCORD_FRIEND_INVITE_RESPONSE_FUNC then
			return
		end

		if data.responseFunc == M.ADD_FRIEND_RESPONSE_FUNC then
			addFriendIndex = index
		end
	end

	if not addFriendIndex then
		return
	end

	local buttonData = {
		label = M.DISCORD_ADD_FRIEND_LABEL,
		responseFunc = M.DISCORD_FRIEND_INVITE_RESPONSE_FUNC,
		icon = interactData[addFriendIndex].icon
	}

	table.insert(interactData, addFriendIndex + 1, buttonData)
end

function M:inviteDiscordFriendToAddFriend()
	if not M.isDiscordPlayerCard(self) then
		return
	end

	DiscordFriendService.inviteDiscordFriendToAddFriend(self.playerInfo)
end

return M
