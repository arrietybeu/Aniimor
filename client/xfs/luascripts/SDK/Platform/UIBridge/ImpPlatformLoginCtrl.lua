-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformLoginCtrl.lua

local M = {}
local PlatformDisplayNameInjector = require("SDK.Platform.UIBridge.PlatformDisplayNameInjector")
local PlatformDisplayNameConfig = require("SDK.Platform.UIBridge.PlatformDisplayNameConfig")
local PlatformLoginService = require("SDK.Platform.PlatformLoginService")
local SDKLoginConfig = require("SDK.SDKLoginConfig")
local csSDKManager = CS.FunPlus.WorldX.SDK.SDKManager

M.CONFIG = PlatformDisplayNameConfig.UI_Pb_Login_Panel

function M.hasBridgeDisplayName()
	return not string.isNilOrEmpty(PlatformLoginService.getBridgeDisplayName())
end

function M:getOnlineIDText()
	if pg.global.platform:isPS() then
		return ""
	end

	local currentUser = PlatformLoginService and PlatformLoginService:getCurrentUser()

	return PlatformDisplayNameInjector.getOnlineIDText({
		playerInfo = {
			platformDisplayName = currentUser and currentUser.displayName or ""
		},
		config = M.CONFIG
	})
end

function M:shouldBlockLoginClick()
	if not SDKLoginConfig.isEnabled() or not pg.global.platform:isConsoleFamily() then
		return false
	end

	return not csSDKManager.HasSdkInitResult()
end

function M:refreshLoginButtonInteractable()
	local button = self and self.view and self.view.button

	if not button then
		return
	end

	local interactable = not self.isInLogin and not M.shouldBlockLoginClick()

	button.interactable = interactable
	button.visualInteractable = interactable
end

return M
