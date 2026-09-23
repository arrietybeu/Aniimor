-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformHomeCampInviteFriendCtrl.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")

function M:getMaskedPlayerName(data, playerInfo, rawName)
	if type(data) ~= "table" or type(playerInfo) ~= "table" or string.isNilOrEmpty(data.playerId) then
		return nil
	end

	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.HomeCampInviteFriendName,
		uid = data.playerId,
		playerInfo = playerInfo,
		rawText = rawName or playerInfo.playerName or ""
	})
end

return M
