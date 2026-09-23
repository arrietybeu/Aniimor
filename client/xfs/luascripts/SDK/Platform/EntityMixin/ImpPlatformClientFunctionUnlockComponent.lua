-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\EntityMixin\\ImpPlatformClientFunctionUnlockComponent.lua

local M = {}
local Const = require("Common.Const.Const")
local PlatformShellActivityService = require("SDK.Platform.PlatformShellActivityService")

function M:on_functionUnlocks_changed(oldv, newv)
	local oldState = oldv and oldv[Const.FUNCTION_NAME.TEAM]
	local newState = newv and newv[Const.FUNCTION_NAME.TEAM]

	if oldState == newState then
		return
	end

	PlatformShellActivityService:refreshCurrentTeamActivity("team_function_state_changed")
end

return M
