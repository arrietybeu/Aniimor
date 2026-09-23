-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformChatCtrl.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")

function M:getAddFriendSuccessPlayerName(playerId, playerInfo, rawName)
	if not playerInfo then
		return false
	end

	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.FriendAddName,
		uid = tostring(playerId),
		playerInfo = playerInfo,
		rawText = rawName or playerInfo.playerName or ""
	})
end

return M
