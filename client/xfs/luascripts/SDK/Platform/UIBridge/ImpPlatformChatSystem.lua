-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformChatSystem.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local PlatformFriendListService = require("SDK.Platform.PlatformFriendListService")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local logger = require("SDK.Platform.PlatformLogger")

function M:getFriendList(baseList, options)
	if options and options.rawOnly == true then
		return baseList
	end

	return PlatformFriendListService:getMergedFriendList(baseList) or baseList
end

function M:buildSelfPlayerData(me, playerData)
	if me == nil or playerData == nil then
		return playerData
	end

	local identity = PlatformIdentityUtils.resolvePlayerIdentity(me) or {}

	if not string.isNilOrEmpty(identity.platformDisplayName) then
		playerData.platformDisplayName = tostring(identity.platformDisplayName)
	end

	if not string.isNilOrEmpty(identity.platformUserId) then
		playerData.platformUserId = tostring(identity.platformUserId)
	end

	if not string.isNilOrEmpty(identity.platformFamily) then
		playerData.platformFamily = tostring(identity.platformFamily)
	end

	if not string.isNilOrEmpty(identity.platform) then
		playerData.platform = tostring(identity.platform)
	end

	if not string.isNilOrEmpty(identity.os) then
		playerData.os = tostring(identity.os)
	end

	if identity.isAllowedCrossPlatform ~= nil then
		playerData.isAllowedCrossPlatform = identity.isAllowedCrossPlatform
	end

	logger:info("ChatSystem buildSelfPlayerData self cache identity uid=%s missingDisplayName=%s missingUserId=%s missingFamily=%s", tostring(me.uid), tostring(string.isNilOrEmpty(playerData.platformDisplayName)), tostring(string.isNilOrEmpty(playerData.platformUserId)), tostring(string.isNilOrEmpty(playerData.platformFamily)))

	if string.isNilOrEmpty(identity.platformDisplayName) or string.isNilOrEmpty(identity.platformUserId) or string.isNilOrEmpty(identity.platformFamily) then
		logger:warn("ChatSystem buildSelfPlayerData missing self platform identity uid=%s missingDisplayName=%s missingUserId=%s missingFamily=%s; check login extraInfo/server Player PER sync", tostring(me.uid), tostring(string.isNilOrEmpty(identity.platformDisplayName)), tostring(string.isNilOrEmpty(identity.platformUserId)), tostring(string.isNilOrEmpty(identity.platformFamily)))
	end

	return playerData
end

function M:refreshTeamMiniChatMessage(messageData, playerInfo)
	local rawName = playerInfo and playerInfo.playerName

	if string.isNilOrEmpty(rawName) then
		return rawName
	end

	local displayName = PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.ChatMessagePlayerName,
		uid = messageData and messageData.playerId,
		playerInfo = playerInfo,
		rawText = rawName
	})

	return displayName
end

function M:resolveFriendshipUpdateName(friendUid, friendInfo, rawName)
	if not PlatformNameMaskService.isCurrentXboxFamily() and not PlatformNameMaskService.isCurrentPSNFamily() then
		return rawName
	end

	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.FriendshipToastName,
		uid = tostring(friendUid or ""),
		playerInfo = friendInfo,
		rawText = rawName or ""
	})
end

return M
