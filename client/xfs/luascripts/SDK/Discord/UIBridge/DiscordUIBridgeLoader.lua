-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Discord\\UIBridge\\DiscordUIBridgeLoader.lua

if pg.isReloading then
	return
end

local DiscordUIBridgeLoader = {}

function DiscordUIBridgeLoader.safeRequire(modulePath)
	local success, result = pcall(require, modulePath)

	if not success then
		print("[DiscordUIBridgeLoader] safeRequire failed: " .. tostring(modulePath) .. " - " .. tostring(result))

		return nil
	end

	return result
end

function DiscordUIBridgeLoader.registerDynamicMembers(targetModulePath, hookModulePath, members)
	local hookModule = DiscordUIBridgeLoader.safeRequire(hookModulePath)

	if hookModule == nil then
		return nil
	end

	local targetModule = DiscordUIBridgeLoader.safeRequire(targetModulePath)

	if targetModule == nil then
		return nil
	end

	for _, member in ipairs(members) do
		local fieldName = member.fieldName
		local hookName = member.hookName or fieldName

		rawset(targetModule, fieldName, function(...)
			local currentHookModule = require(hookModulePath)
			local hookFunction = currentHookModule and currentHookModule[hookName]

			assert(type(hookFunction) == "function", string.format("[DiscordUIBridgeLoader] dynamic member missing: %s.%s", tostring(hookModulePath), tostring(hookName)))

			return hookFunction(...)
		end)
	end

	return targetModule
end

local hook = require("SDK.Discord.UIBridge.ImpDiscordFriendTabComponent")
local FriendTabComponent = require("Guis.Panels.Chat.Component.FriendTabComponent")
local ChatSystem = require("GameApp.Chat.ChatSystem")
local ClientFunctionUnlockComponent = require("Entities.SpaceEntities.PlayerComponent.ClientFunctionUnlockComponent")
local ClientTeamComponent = require("Entities.SpaceEntities.PlayerComponent.ClientTeamComponent")
local DiscordFriendService = require("SDK.Discord.DiscordFriendService")

rawset(FriendTabComponent, "_discordHooks", hook)
rawset(ChatSystem, "_discordHooks", DiscordFriendService)
rawset(ClientFunctionUnlockComponent, "_discordHooks", DiscordFriendService)
rawset(ClientTeamComponent, "_discordHooks", DiscordFriendService)
DiscordUIBridgeLoader.registerDynamicMembers("Guis.Panels.InfoPlayerCard.InfoPlayerCardCtrl", "SDK.Discord.UIBridge.ImpDiscordPlayerCardCtrl", {
	{
		fieldName = "setDiscordPlayerBaseInfoName"
	},
	{
		fieldName = "setDiscordPlayerBaseInfoOnlineID"
	},
	{
		fieldName = "setDiscordPlayerBaseInfo"
	},
	{
		fieldName = "addDiscordFriendInviteButton"
	},
	{
		fieldName = "inviteDiscordFriendToAddFriend"
	}
})
DiscordUIBridgeLoader.registerDynamicMembers("Guis.Panels.Chat.Component.FriendTabComponent", "SDK.Discord.UIBridge.ImpDiscordFriendTabComponent", {
	{
		fieldName = "refreshDiscordFriends"
	},
	{
		fieldName = "refreshDiscordFriendsPlayerInfo"
	}
})
DiscordUIBridgeLoader.registerDynamicMembers("GameApp.Chat.ChatSystem", "SDK.Discord.UIBridge.ImpDiscordChatSystem", {
	{
		fieldName = "onSDKAccountBindChanged"
	},
	{
		fieldName = "onDiscordStatusChanged"
	},
	{
		fieldName = "onDiscordSocialInfoUpdated"
	},
	{
		fieldName = "onDiscordSDKFriendsUpdated"
	},
	{
		fieldName = "onDiscordRichPresenceUpdated"
	},
	{
		fieldName = "onDiscordInviteSent"
	}
})

return DiscordUIBridgeLoader
