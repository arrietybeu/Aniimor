-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Discord\\UIBridge\\ImpDiscordChatSystem.lua

local M = {}

function M.onSDKAccountBindChanged(chatSystem)
	local discordHooks = chatSystem._discordHooks

	if discordHooks and discordHooks.onSDKAccountBindChanged then
		discordHooks.onSDKAccountBindChanged()
	end
end

function M.onDiscordStatusChanged(chatSystem, result)
	local discordHooks = chatSystem._discordHooks

	if discordHooks and discordHooks.onDiscordStatusChanged then
		discordHooks.onDiscordStatusChanged(result)
	end
end

function M.onDiscordSocialInfoUpdated(chatSystem, result)
	local discordHooks = chatSystem._discordHooks

	if discordHooks and discordHooks.onDiscordSocialInfoUpdated then
		discordHooks.onDiscordSocialInfoUpdated(result)
	end
end

function M.onDiscordSDKFriendsUpdated(chatSystem, snapshot)
	local discordHooks = chatSystem._discordHooks

	if discordHooks and discordHooks.onDiscordFriendsUpdated then
		discordHooks.onDiscordFriendsUpdated(snapshot)
	end
end

function M.onDiscordRichPresenceUpdated(chatSystem, result)
	local discordHooks = chatSystem._discordHooks

	if discordHooks and discordHooks.onDiscordRichPresenceUpdated then
		discordHooks.onDiscordRichPresenceUpdated(result)
	end
end

function M.onDiscordInviteSent(chatSystem, result)
	local discordHooks = chatSystem._discordHooks

	if discordHooks and discordHooks.onDiscordInviteSent then
		discordHooks.onDiscordInviteSent(result)
	end
end

return M
