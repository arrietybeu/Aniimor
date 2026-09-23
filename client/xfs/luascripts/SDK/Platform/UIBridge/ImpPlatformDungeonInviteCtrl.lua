-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformDungeonInviteCtrl.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")

M.CHANNEL_TAB_TYPE = 1

function M:renderInvitePlayerName(data, playerInfo, rawName)
	local channelTabType = self.TabType and self.TabType.Channel or M.CHANNEL_TAB_TYPE

	if self.selectTab == channelTabType or type(data) ~= "table" or string.isNilOrEmpty(data.playerId) or type(playerInfo) ~= "table" then
		return nil
	end

	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.DungeonInviteName,
		uid = data.playerId,
		playerInfo = playerInfo,
		rawText = rawName or playerInfo.playerName or ""
	})
end

return M
