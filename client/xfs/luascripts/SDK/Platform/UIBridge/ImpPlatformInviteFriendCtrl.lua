-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformInviteFriendCtrl.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")

function M:renderFriendItemName(button, data, playerInfo, rawName)
	if type(data) ~= "table" or type(playerInfo) ~= "table" or string.isNilOrEmpty(data.playerId) then
		return nil
	end

	local playerId = data.playerId

	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.InviteFriendListName,
		uid = playerId,
		playerInfo = playerInfo,
		rawText = rawName or playerInfo.playerName or ""
	})
end

return M
