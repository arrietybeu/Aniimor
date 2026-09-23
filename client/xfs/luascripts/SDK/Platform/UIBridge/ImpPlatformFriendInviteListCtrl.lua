-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformFriendInviteListCtrl.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")

function M:renderInvitePlayerName(button, data, rawName)
	if type(data) ~= "table" or string.isNilOrEmpty(data.playerId) then
		return nil
	end

	local playerInfo = data.playerInfo or pg.game.chat and pg.game.chat:getPlayerInfo(data.playerId) or nil

	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.FriendInviteListName,
		uid = data.playerId,
		playerInfo = playerInfo,
		rawText = rawName or ""
	})
end

return M
