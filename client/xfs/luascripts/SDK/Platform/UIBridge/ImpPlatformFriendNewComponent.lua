-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformFriendNewComponent.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local PlatformFriendListService = require("SDK.Platform.PlatformFriendListService")

function M:renderFriendItemName(button, index, data, playerInfo, rawName)
	local playerId = data and data.playerId

	if string.isNilOrEmpty(playerId) then
		return
	end

	if not playerInfo then
		return
	end

	if data.isPlatformFriend == true then
		local gamertag = PlatformFriendListService:resolveGamertag(playerInfo)

		if not string.isNilOrEmpty(gamertag) then
			return gamertag
		end
	end

	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.FriendNewComponentName,
		uid = playerId,
		playerInfo = playerInfo,
		rawText = rawName or playerInfo.playerName or ""
	})
end

return M
