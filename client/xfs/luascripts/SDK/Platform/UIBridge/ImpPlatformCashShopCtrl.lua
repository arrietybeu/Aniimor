-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformCashShopCtrl.lua

local M = {}

function M:shouldShowWebPayButton()
	return not pg.global.platform:isXbox() and not pg.global.platform:isXboxPC() and not pg.global.platform:isPS()
end

return M
