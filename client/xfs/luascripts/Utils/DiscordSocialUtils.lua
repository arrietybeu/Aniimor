-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\DiscordSocialUtils.lua

local DiscordSocialUtils = {}
local LoggerManager = require("Core.Log.LoggerManager")
local DiscordSocialConfig = require("Config.DiscordSocialConfig")
local logger = LoggerManager.getLogger("DiscordSocialUtils")
local CS = CS
local DiscordSocialManager
local SUPPORTED_RUNTIME_PLATFORMS = {
	LinuxPlayer = true,
	OSXPlayer = true,
	WindowsPlayer = true,
	LinuxEditor = true,
	OSXEditor = true,
	WindowsEditor = true,
	IPhonePlayer = true,
	Android = true
}

local function getDiscordSocialManager()
	if DiscordSocialManager then
		return DiscordSocialManager
	end

	local success, manager = pcall(function()
		return CS.FunPlus.WorldX.SDK.Discord.DiscordSocialManager
	end)

	if success then
		DiscordSocialManager = manager
	end

	return DiscordSocialManager
end

function DiscordSocialUtils.isPlatformSupported()
	return type(UnityPlatform) == "string" and SUPPORTED_RUNTIME_PLATFORMS[UnityPlatform] == true
end

function DiscordSocialUtils.init(clientId)
	if not DiscordSocialUtils.isPlatformSupported() then
		logger:info("Discord SDK is unsupported on current platform: %s", tostring(UnityPlatform))

		return false
	end

	local manager = getDiscordSocialManager()

	if not manager then
		logger:warn("Discord SDK is unavailable on current platform")

		return false
	end

	if not clientId then
		if not DiscordSocialConfig.enabled then
			manager.Clear()
			logger:info("Discord SDK is disabled in config")

			return false
		end

		if not DiscordSocialConfig.clientId or DiscordSocialConfig.clientId == "" then
			logger:error("Discord SDK is enabled but DiscordSocialClientId is empty")

			return false
		end

		clientId = DiscordSocialConfig.clientId
	end

	manager.InitSDK(clientId)
	logger:info("Discord SDK init requested (not yet ready)")

	return true
end

function DiscordSocialUtils.connectWithToken(accessToken)
	if not accessToken or accessToken == "" then
		logger:error("Access token is empty")

		return false
	end

	local manager = getDiscordSocialManager()

	if not manager then
		logger:warn("Discord SDK is unavailable on current platform")

		return false
	end

	manager.ConnectWithToken(accessToken)
	logger:info("Discord connection requested (async, check status later)")

	return true
end

function DiscordSocialUtils.startAuthorization(scopes, useCommunicationScopes)
	if not DiscordSocialUtils.init() then
		return false
	end

	local requestedScopes = scopes

	requestedScopes = requestedScopes or useCommunicationScopes and "__discord_default_communication__" or ""

	getDiscordSocialManager().StartAuthorization(requestedScopes)
	logger:info("Starting Discord authorization...")

	return true
end

function DiscordSocialUtils.startGameStatsAuthorization()
	return DiscordSocialUtils.startAuthorization(nil, true)
end

function DiscordSocialUtils.getOnlinePlayingGameFriends()
	if not DiscordSocialUtils.isReady() then
		logger:warn("Discord SDK not ready")

		return {}
	end

	return DiscordSocialManager.GetOnlinePlayingGameFriends()
end

function DiscordSocialUtils.getOnlineElsewhereFriends()
	if not DiscordSocialUtils.isReady() then
		logger:warn("Discord SDK not ready")

		return {}
	end

	return DiscordSocialManager.GetOnlineElsewhereFriends()
end

function DiscordSocialUtils.getOfflineFriends()
	if not DiscordSocialUtils.isReady() then
		logger:warn("Discord SDK not ready")

		return {}
	end

	return DiscordSocialManager.GetOfflineFriends()
end

function DiscordSocialUtils.getFriendSnapshot()
	local isReady = DiscordSocialUtils.isReady()
	local snapshot = {
		isReady = isReady,
		onlinePlayingGame = {},
		onlineElsewhere = {},
		offline = {}
	}

	if not isReady then
		logger:warn("Discord SDK not ready")

		return snapshot
	end

	snapshot.onlinePlayingGame = DiscordSocialManager.GetOnlinePlayingGameFriends()
	snapshot.onlineElsewhere = DiscordSocialManager.GetOnlineElsewhereFriends()
	snapshot.offline = DiscordSocialManager.GetOfflineFriends()

	return snapshot
end

function DiscordSocialUtils.onFriendsUpdated(snapshot)
	if not pg or not pg.global or not pg.global.sdkManager then
		return snapshot
	end

	return pg.global.sdkManager:onDiscordFriendsUpdated(snapshot)
end

function DiscordSocialUtils.onRichPresenceUpdated(success, errorMessage)
	if pg and pg.global and pg.global.sdkManager then
		pg.global.sdkManager:onDiscordRichPresenceUpdated(success, errorMessage)
	end
end

function DiscordSocialUtils.onInviteSent(success, targetUserId, errorMessage)
	if pg and pg.global and pg.global.sdkManager then
		pg.global.sdkManager:onDiscordInviteSent(success, targetUserId, errorMessage)
	end
end

function DiscordSocialUtils.getAllOnlineFriends()
	local onlineInGame = DiscordSocialUtils.getOnlinePlayingGameFriends()
	local onlineElsewhere = DiscordSocialUtils.getOnlineElsewhereFriends()
	local allOnline = {}

	for i = 1, #onlineInGame do
		table.insert(allOnline, onlineInGame[i])
	end

	for i = 1, #onlineElsewhere do
		table.insert(allOnline, onlineElsewhere[i])
	end

	return allOnline
end

function DiscordSocialUtils.refreshFriends()
	if not DiscordSocialUtils.isReady() then
		logger:warn("Discord SDK not ready")

		return false
	end

	DiscordSocialManager.ManualRefreshFriends()

	return true
end

function DiscordSocialUtils.updateRichPresence(state, details, joinSecret, currentPartySize, maxPartySize, partyId)
	if not DiscordSocialUtils.isReady() then
		logger:warn("Discord SDK not ready")

		return false
	end

	if partyId and partyId ~= "" then
		DiscordSocialManager.UpdateRichPresenceEx(state, details, joinSecret, currentPartySize, maxPartySize, {
			partyId = partyId
		})
	else
		DiscordSocialManager.UpdateRichPresence(state, details, joinSecret, currentPartySize, maxPartySize)
	end

	return true
end

function DiscordSocialUtils.updateRichPresenceEx(state, details, joinSecret, currentPartySize, maxPartySize, config)
	if not DiscordSocialUtils.isReady() then
		logger:warn("Discord SDK not ready")

		return false
	end

	DiscordSocialManager.UpdateRichPresenceEx(state, details, joinSecret, currentPartySize, maxPartySize, config)

	return true
end

function DiscordSocialUtils.clearRichPresence()
	if not DiscordSocialUtils.isReady() then
		logger:warn("Discord SDK not ready")

		return false
	end

	DiscordSocialManager.ClearRichPresence()

	return true
end

function DiscordSocialUtils.sendInvite(targetUserId, message)
	if not DiscordSocialUtils.isReady() then
		logger:warn("Discord SDK not ready")

		return false
	end

	local inviteMessage = message

	if not inviteMessage or inviteMessage == "" then
		inviteMessage = "Join my game!"
	end

	DiscordSocialManager.SendActivityInvite(targetUserId, inviteMessage)

	return true
end

function DiscordSocialUtils.setJoinCallback(onJoin)
	if not pg or not pg.global or not pg.global.sdkManager then
		logger:error("Cannot register Discord join callback: pg.global is unavailable")

		return false
	end

	pg.global.sdkManager:setDiscordJoinCallback(onJoin)

	return true
end

function DiscordSocialUtils.onActivityJoin(joinSecret)
	if pg and pg.global and pg.global.sdkManager then
		pg.global.sdkManager:onDiscordActivityJoin(joinSecret)
	end
end

function DiscordSocialUtils.setAuthorizationCallbacks(onComplete, onFailed)
	if not pg or not pg.global or not pg.global.sdkManager then
		logger:error("Cannot register Discord authorization callbacks: pg.global is unavailable")

		return false
	end

	pg.global.sdkManager:setDiscordAuthorizationCallbacks(onComplete, onFailed)

	return true
end

function DiscordSocialUtils.onAuthorizationComplete(code, verifier, redirectUri)
	if pg and pg.global and pg.global.sdkManager then
		pg.global.sdkManager:onDiscordAuthorizationComplete(code, verifier, redirectUri)
	end
end

function DiscordSocialUtils.onAuthorizationFailed(errorMessage)
	if pg and pg.global and pg.global.sdkManager then
		pg.global.sdkManager:onDiscordAuthorizationFailed(errorMessage)
	end
end

function DiscordSocialUtils.clearAuthorizationCallbacks()
	if pg and pg.global and pg.global.sdkManager then
		pg.global.sdkManager:clearDiscordAuthorizationCallbacks()
	end
end

function DiscordSocialUtils.clearJoinCallback()
	if pg and pg.global and pg.global.sdkManager then
		pg.global.sdkManager:clearDiscordJoinCallback()
	end
end

function DiscordSocialUtils.isReady()
	local manager = getDiscordSocialManager()

	return manager ~= nil and manager.IsReady()
end

function DiscordSocialUtils.clear()
	DiscordSocialUtils.clearJoinCallback()
	DiscordSocialUtils.clearAuthorizationCallbacks()

	local manager = getDiscordSocialManager()

	if manager then
		manager.Clear()
	end

	logger:info("Discord SDK cleared")
end

return DiscordSocialUtils
