-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformDungeonInvitePopupCtrl.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")

function M:renderInvitePlayerName(data, playerInfo, rawName)
	if type(data) ~= "table" or tostring(data.Uid) == tostring(pg.me.uid) then
		return nil
	end

	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.DungeonInvitePopupPlayerName,
		uid = data.Uid,
		playerInfo = playerInfo,
		rawText = rawName or playerInfo and playerInfo.playerName or ""
	})
end

return M
