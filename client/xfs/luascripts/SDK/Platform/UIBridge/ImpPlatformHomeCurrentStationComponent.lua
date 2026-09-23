-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformHomeCurrentStationComponent.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")

function M.renderCurrentStationPlayerName(_, _, playerData, playerInfo, rawName)
	local uid = playerData and playerData.playerUid

	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.HomeStationManageName,
		uid = uid,
		playerInfo = playerInfo,
		rawText = rawName or playerInfo and playerInfo.playerName or ""
	})
end

return M
