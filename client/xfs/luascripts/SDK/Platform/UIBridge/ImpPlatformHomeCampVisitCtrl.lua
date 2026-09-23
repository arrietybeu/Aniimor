-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformHomeCampVisitCtrl.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")

function M:rendererFriendCampName(button, index, data, rawName)
	local playerInfo = data.playerInfo

	if not playerInfo then
		return nil
	end

	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.HomeCampVisitName,
		uid = data.uid,
		playerInfo = playerInfo,
		rawText = rawName or playerInfo.playerName or ""
	})
end

return M
