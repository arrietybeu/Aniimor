-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformFriendSetupCtrl.lua

local M = {}
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")

function M.getLatestPlayerInfo(uid)
	if pg and pg.game and pg.game.chat and pg.game.chat.getPlayerInfo then
		return pg.game.chat:getPlayerInfo(uid)
	end

	return nil
end

function M.getMappedFriendGroupUid(data, fallbackUid)
	if type(data) ~= "table" then
		return fallbackUid
	end

	local playerId = data.playerId or fallbackUid

	if string.isNilOrEmpty(playerId) then
		return nil
	end

	local playerInfo = data.playerInfo

	if data.isPlatformFriend == true or type(playerInfo) == "table" and playerInfo.isPlatformFriend == true then
		if data.hasMappedGameUid == true then
			return tostring(data.mappedGameUid or playerId)
		end

		if type(playerInfo) == "table" and playerInfo.hasMappedGameUid == true then
			return tostring(playerInfo.mappedGameUid or data.mappedGameUid or playerId)
		end

		return nil
	end

	return playerId
end

function M:prepareFriendSetupItem(data, friendData)
	if type(data) ~= "table" or type(friendData) ~= "table" then
		return
	end

	data.isPlatformFriend = friendData.isPlatformFriend
	data.mappedGameUid = friendData.mappedGameUid
	data.hasMappedGameUid = friendData.hasMappedGameUid
end

function M:getFriendGroupUid(data, fallbackUid)
	return M.getMappedFriendGroupUid(data, fallbackUid)
end

function M:renderFriendItemName(button, data, rawName)
	if type(data) ~= "table" or string.isNilOrEmpty(data.playerId) then
		return nil
	end

	local playerId = data.playerId
	local playerInfo = data.playerInfo or M.getLatestPlayerInfo(playerId)

	if type(playerInfo) ~= "table" then
		return nil
	end

	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.FriendSetupFriendName,
		uid = playerId,
		playerInfo = playerInfo,
		rawText = rawName or playerInfo.playerName or ""
	})
end

return M
