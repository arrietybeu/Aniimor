-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformLuaUIUtils.lua

local M = {}
local PLATFORM_FUNC_SWITCH = {}

function M.checkPlatformFuncUnlock(funcName)
	if pg.global.platform:isXbox() or pg.global.platform:isXboxPC() then
		return PLATFORM_FUNC_SWITCH[funcName]
	end

	return nil
end

return M
