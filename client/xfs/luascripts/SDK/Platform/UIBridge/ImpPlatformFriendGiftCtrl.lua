-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformFriendGiftCtrl.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")

function M:refreshUI(rawName)
	if type(self.playerInfo) ~= "table" then
		return nil
	end

	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.FriendGiftName,
		uid = self.info and self.info.playerId or self.playerInfo.uid,
		playerInfo = self.playerInfo,
		rawText = rawName or self.playerInfo.playerName or ""
	})
end

return M
