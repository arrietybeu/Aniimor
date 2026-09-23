-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformFriendIntimacyCtrl.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local PlatformNameMaskRefreshHelper = require("SDK.Platform.PlatformNameMaskRefreshHelper")

function M:refreshPlayerInfoName(rawName)
	if type(self.playerInfo) ~= "table" then
		return nil
	end

	local displayName = PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.FriendIntimacyName,
		uid = self.playerInfo.uid,
		playerInfo = self.playerInfo,
		rawText = rawName or ""
	})

	return displayName
end

function M:onCreate()
	PlatformNameMaskRefreshHelper.register(self, function(ctrl)
		if type(ctrl.refreshPlayerInfo) == "function" then
			ctrl:refreshPlayerInfo()
		end
	end)
end

function M:onDestroy()
	PlatformNameMaskRefreshHelper.unregister(self)
end

return M
