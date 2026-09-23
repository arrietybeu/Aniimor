-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\EntityMixin\\ImpPlatformClientRoomComponent.lua

local M = {}
local RoomConst = require("Const.RoomConst")
local PlatformRecentPlayerService = require("SDK.Platform.PlatformRecentPlayerService")

function M.getPlatformRecentPlayerService()
	return PlatformRecentPlayerService
end

function M:rpc_waitingEnterWorld(playerStatus, matchInfo)
	if playerStatus == RoomConst.ROOM_ALL_PLAYER_READY then
		local recentPlayerService = M.getPlatformRecentPlayerService()

		if recentPlayerService then
			recentPlayerService:reportMatchReady(matchInfo, "pvp_match_ready")
		end
	end
end

return M
