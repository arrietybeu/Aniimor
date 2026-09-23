-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandSeasonCelebrationInvite\\HomelandSeasonCelebrationInviteModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local HomelandSeasonCelebrationInviteModel = Class.LightClass("HomelandSeasonCelebrationInviteModel", UIModel)

function HomelandSeasonCelebrationInviteModel:getFriends(searchText)
	local result = {}

	for _, friend in pairs(pg.game.chat:getFriendList() or EMPTY_TABLE) do
		local playerInfo = pg.game.chat:getPlayerInfo(friend.playerId)
		local playerId = tostring(friend.playerId or "")

		if playerInfo and (string.isNilOrEmpty(searchText) or string.find(playerInfo.playerName or "", searchText, 1, true) or string.find(playerId, searchText, 1, true)) then
			result[#result + 1] = friend
		end
	end

	return result
end

return HomelandSeasonCelebrationInviteModel
