-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformShowTitleUtils.lua

local M = {}
local PlatformFriendListService = require("SDK.Platform.PlatformFriendListService")
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")

function M.isMissing(value)
	return value == nil or value == ""
end

function M.getFriendTitlePlayerInfo(friendUid)
	local chatSystem = pg and pg.game and pg.game.chat

	if chatSystem == nil or chatSystem.getPlayerInfo == nil then
		return nil
	end

	local playerInfo = chatSystem:getPlayerInfo(friendUid)

	if playerInfo ~= nil and not M.isMissing(playerInfo.platformUserId) and not M.isMissing(playerInfo.platformFamily) then
		return playerInfo
	end

	if PlatformFriendListService and PlatformFriendListService.getPlatformFriendEntries then
		PlatformFriendListService:getPlatformFriendEntries({
			mappedOnly = true
		})

		playerInfo = chatSystem:getPlayerInfo(friendUid)
	end

	return playerInfo
end

function M.resolveFriendPrefixName(friendUid, rawName)
	if not PlatformNameMaskService.isCurrentXboxFamily() and not PlatformNameMaskService.isCurrentPSNFamily() then
		return rawName
	end

	local playerInfo = M.getFriendTitlePlayerInfo(friendUid)

	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.FriendTitlePrefixName,
		uid = tostring(friendUid or ""),
		playerInfo = playerInfo,
		rawText = rawName or ""
	})
end

return M
