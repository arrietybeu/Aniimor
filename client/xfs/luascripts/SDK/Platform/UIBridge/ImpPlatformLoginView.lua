-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformLoginView.lua

local LuaUIUtils = require("Utils.LuaUIUtils")
local SDKLoginConfig = require("SDK.SDKLoginConfig")
local ImpPlatformLoginView = {}

function ImpPlatformLoginView:initView()
	if pg.global.platform:isConsole() == true and SDKLoginConfig.isEnabled() then
		LuaUIUtils.setUIViewVisible(self.inputField, false)
		LuaUIUtils.setUIViewVisible(self.inputFieldGamePadFocus, false)
	end
end

return ImpPlatformLoginView
