-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformHomeStationManageComponent.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")

function M.renderFriendStationPlayerName(_, _, _, data, playerInfo, rawName)
	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.HomeStationManageName,
		uid = data and data.uid,
		playerInfo = playerInfo,
		rawText = rawName or playerInfo and playerInfo.playerName or ""
	})
end

return M
