-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\EntityMixin\\ImpPlatformClientMatchComponent.lua

local M = {}
local EventConst = require("Common.Const.EventConst")
local MatchConst = require("Common.Const.MatchConst")
local PlatformRecentPlayerService = require("SDK.Platform.PlatformRecentPlayerService")

function M.getPlatformRecentPlayerService()
	return PlatformRecentPlayerService
end

function M:RPC_SC_EnterRoomSucc(roomPlayersInfo)
	local recentPlayerService = M.getPlatformRecentPlayerService()

	if recentPlayerService then
		recentPlayerService:reportPvpRoom(roomPlayersInfo, "pvp_enter_room")
	end
end

return M
