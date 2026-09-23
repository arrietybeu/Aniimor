-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformGameApp.lua

local M = {}
local PlatformLoginService = require("SDK.Platform.PlatformLoginService")
local PlatformPaymentReconcileService = require("SDK.Platform.PlatformPaymentReconcileService")

function M:onAppFocus(focus)
	if focus and PlatformLoginService and PlatformLoginService.syncBridgeUserState then
		PlatformLoginService:syncBridgeUserState()
	end

	if focus then
		PlatformPaymentReconcileService.onForeground("app_focus")
	end
end

return M
