-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformSettingCtrl.lua

local M = {}
local PlatformCrossPlatformService = require("SDK.Platform.PlatformCrossPlatformService")

function M.isCrossPlatformSettingReadOnly()
	return PlatformCrossPlatformService:isCrossPlatformSettingReadOnly()
end

return M
