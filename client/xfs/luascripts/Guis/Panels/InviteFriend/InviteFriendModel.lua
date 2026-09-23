-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\InviteFriend\\InviteFriendModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local InviteFriendModel = Class.LightClass("InviteFriendModel", UIModel)

function InviteFriendModel:getInviteFriendListData()
	local friendList = pg.game.chat.friendList or {}
	local subItems = pg.game.chat:getFriendList() or {}
	local ret = {}

	table.insert(ret, {
		tIndex = 0,
		label = friendList[1].label
	})

	for _, v in pairs(subItems) do
		table.insert(ret, {
			tIndex = 1,
			loginTime = v.loginTime,
			lastLogoutTime = v.lastLogoutTime,
			playerId = v.playerId,
			status = v.status,
			type = v.type,
			level = v.level,
			uid = v.uid
		})
	end

	return ret
end

function InviteFriendModel:getSearchedList(searchText)
	local friendList = pg.game.chat:getFriendList() or {}
	local ret = {}

	for _, v in pairs(friendList) do
		local playerInfo = pg.game.chat:getPlayerInfo(v.playerId)

		if playerInfo and playerInfo.playerName and string.find(playerInfo.playerName, searchText) then
			table.insert(ret, {
				tIndex = 1,
				loginTime = v.loginTime,
				lastLogoutTime = v.lastLogoutTime,
				playerId = v.playerId,
				status = v.status,
				type = v.type,
				level = v.level,
				uid = v.uid
			})
		end
	end

	return ret
end

function InviteFriendModel:getTitleData()
	local friendList = pg.game.chat.friendList or {}
	local ret = {}

	table.insert(ret, {
		tIndex = 0,
		label = friendList[1].label
	})

	return ret
end

function InviteFriendModel:getPanelTitleDesc()
	return pg.getGameString("PHOTO_WORLD_TIP_1")
end

function InviteFriendModel:getPanelTipInfo()
	return pg.getGameString("PHOTO_WORLD_TIP_2")
end

function InviteFriendModel:checkUidExistsInSpace(uid)
	local players = pg.global.entityMgr.getAllPlayers()

	if not next(players) then
		return false
	end

	for _, entInfo in pairs(players) do
		if entInfo.uid and entInfo.uid == uid then
			return true
		end
	end

	return false
end

return InviteFriendModel
