-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformLoadProgressCtrl.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")

function M:resolveTeamMemberDisplayName(uid, playerInfo, rawName)
	if not PlatformNameMaskService.isCurrentXboxFamily() and not PlatformNameMaskService.isCurrentPSNFamily() then
		return rawName
	end

	local cachedPlayerInfo = pg and pg.game and pg.game.chat and pg.game.chat:getPlayerInfo(uid) or nil

	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.LoadingTeamMemberName,
		uid = tostring(uid or ""),
		playerInfo = cachedPlayerInfo or playerInfo,
		rawText = rawName or ""
	})
end

return M
