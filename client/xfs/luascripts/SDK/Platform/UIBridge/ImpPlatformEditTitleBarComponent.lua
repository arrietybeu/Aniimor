-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformEditTitleBarComponent.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")

function M:resolveFriendTitleDisplayName(friendUid, rawName)
	if not PlatformNameMaskService.isCurrentXboxFamily() and not PlatformNameMaskService.isCurrentPSNFamily() then
		return rawName
	end

	local playerInfo = pg and pg.game and pg.game.chat and pg.game.chat:getPlayerInfo(friendUid) or nil

	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.FriendTitlePrefixName,
		uid = tostring(friendUid or ""),
		playerInfo = playerInfo,
		rawText = rawName or ""
	})
end

return M
