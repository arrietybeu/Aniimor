-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformHomeCampReportCtrl.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")

function M:renderPlayerName(data, rawName, isHomeName)
	local uid = data and data.uid

	if string.isNilOrEmpty(uid) then
		return nil
	end

	local playerInfo = data.playerInfo
	local action = isHomeName and PlatformNameMaskService.Action.HomeCampCustomName or PlatformNameMaskService.Action.AccusationName

	return PlatformNameMaskService.getMaskedDisplayName({
		action = action,
		uid = uid,
		playerInfo = playerInfo,
		rawText = rawName or playerInfo and playerInfo.playerName or ""
	})
end

return M
