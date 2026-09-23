-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformRankBaseDisplayRegistry.lua

local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local PlatformDisplayNameConfig = require("SDK.Platform.UIBridge.PlatformDisplayNameConfig")
local PlatformDisplayNameInjector = require("SDK.Platform.UIBridge.PlatformDisplayNameInjector")
local M = {}
local DISPLAY_NAME_CONFIG = PlatformDisplayNameConfig.UI_Pb_Ranking

function M.getRenderPlayerName(rankData, playerInfo, rawName)
	local displayName = PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.RankBasePlayerName,
		uid = rankData.MemberId,
		playerInfo = playerInfo,
		rawText = rawName
	})

	return PlatformDisplayNameInjector.getDisplayName({
		playerInfo = playerInfo,
		config = DISPLAY_NAME_CONFIG,
		rawName = displayName
	})
end

return M
