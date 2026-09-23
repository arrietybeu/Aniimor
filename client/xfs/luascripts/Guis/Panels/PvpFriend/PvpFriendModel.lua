-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpFriend\\PvpFriendModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PvpFriendModel = Class.LightClass("PvpFriendModel", UIModel)
local MatchConst = require("Common.Const.MatchConst")

PvpFriendModel.PLAYER_STATE = {
	BUSY = 2,
	FREE = 1,
	OUTLINE = 0
}

function PvpFriendModel:getFriendDataList(onlyFreeFriend)
	local dataList = {}
	local friendData = pg.game.chat:getFriendList() or {}

	for _, v in pairs(friendData) do
		local pInfo = pg.game.chat:getPlayerInfo(v.playerId)

		if pInfo then
			local state = self:getPlayerState(pInfo)

			if not onlyFreeFriend or state == self.PLAYER_STATE.FREE then
				dataList[#dataList + 1] = {
					uid = v.playerId,
					name = pInfo.playerName,
					state = state
				}
			end
		end
	end

	return dataList
end

function PvpFriendModel:getPlayerState(data)
	if not data.online then
		return self.PLAYER_STATE.OUTLINE
	elseif data.matchStatus ~= MatchConst.MATCH_STATUS_INIT then
		return self.PLAYER_STATE.BUSY
	else
		return self.PLAYER_STATE.FREE
	end
end

return PvpFriendModel
