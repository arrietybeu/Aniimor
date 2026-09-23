-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformInteractionAnimationComponent.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")

function M:resolveInteractPlayerDisplayName(uid, playerInfo, rawName)
	local displayText = PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.InteractSwitchPlayerName,
		uid = uid,
		playerInfo = playerInfo,
		rawText = rawName
	})

	return displayText
end

return M
