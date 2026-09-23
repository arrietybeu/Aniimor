-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformFriendshipUpCtrl.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")

function M:initUI(rawName)
	if not self.playerInfo or not self.playerId then
		return nil
	end

	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.FriendshipUpName,
		uid = tostring(self.playerId),
		playerInfo = self.playerInfo,
		rawText = rawName or self.playerInfo.playerName or ""
	})
end

return M
