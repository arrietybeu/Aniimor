-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\InfoPlayerMain\\InfoPlayerMainModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local UIModel = require("Guis.UIModel")
local Class = require("Core.Framework.Class")
local InfoPlayerMainModel = Class.LightClass("InfoPlayerMainModel", UIModel)
local PlayerHeadIconData = require("Data.player_head_icon_data")
local PlayerHeadFrameData = require("Data.player_head_frame_data")
local Const = require("Common.Const.Const")
local ShowTitleData = require("Data.show_title_data")
local FriendshipLevelFuncData = require("Data.friendship_level_func_data")
local CardBackgroundData = require("Data.card_background_data")
local ChatBubbleData = require("Data.chat_bubble_data")

function InfoPlayerMainModel:ctor()
	self:init()
end

function InfoPlayerMainModel:init()
	return
end

function InfoPlayerMainModel:getUnlockDict(curUnlock, data)
	local ret = {}

	for id, value in pairs(data or EMPTY_TABLE) do
		if value.defaultUnlock == 1 then
			ret[id] = true
		end
	end

	for id, value in pairs(curUnlock or EMPTY_TABLE) do
		ret[id] = value
	end

	return ret
end

function InfoPlayerMainModel:getChatBubbleList()
	local list = {}

	for id, data in next, ChatBubbleData do
		local isLock = self:isChatBubbleLock(id)

		if not isLock or self:isItemShow(data) then
			list[#list + 1] = {
				id = id,
				name = data.cardName,
				res = data.res,
				source = data.source,
				isLock = isLock
			}
		end
	end

	table.sort(list, function(a, b)
		if a.isLock ~= b.isLock then
			return not a.isLock
		end

		return a.id < b.id
	end)

	return list
end

function InfoPlayerMainModel:isChatBubbleLock(id)
	local data = ChatBubbleData[id]

	if data and data.defaultUnlock == 1 then
		return false
	end

	local unlockDict = pg.me.chatBubbleDicts

	return not unlockDict or unlockDict[id] ~= true
end

function InfoPlayerMainModel:getHeadList()
	local ret = {}
	local data = PlayerHeadIconData
	local curUnlock = self:getUnlockDict(pg.me.headIconDicts, data)

	for index, value in pairs(curUnlock) do
		if value and data[index] then
			ret[#ret + 1] = {
				id = index,
				icon = data[index].res,
				item = data[index].item
			}
		end
	end

	for id, value in pairs(data) do
		if not curUnlock[id] and self:isItemShow(value) then
			ret[#ret + 1] = {
				id = id,
				icon = value.res,
				item = value.item
			}
		end
	end

	return ret
end

function InfoPlayerMainModel:getFrameList()
	local ret = {}
	local data = PlayerHeadFrameData
	local curUnlock = self:getUnlockDict(pg.me.headFrameDicts, data)

	for index, value in pairs(curUnlock) do
		if value and data[index] then
			ret[#ret + 1] = {
				id = index,
				icon = data[index].res,
				item = data[index].item
			}
		end
	end

	for id, value in pairs(data) do
		if not curUnlock[id] and self:isItemShow(value) then
			ret[#ret + 1] = {
				id = id,
				icon = value.res,
				item = value.item
			}
		end
	end

	return ret
end

function InfoPlayerMainModel:getShowTitleList(titleType)
	local ret = {}
	local curUnlock = self:getUnlockDict(pg.me.showTitleDicts, ShowTitleData)
	local tIndex = titleType == Const.SHOW_TITLE_TYPE.Background and 1 or 0

	for id, value in pairs(curUnlock) do
		local titleData = ShowTitleData[id]
		local isMatchingType = value and titleData ~= nil and (titleData.titleType == titleType or titleData.titleType == Const.SHOW_TITLE_TYPE.None)

		if isMatchingType then
			ret[#ret + 1] = self:_createShowTitleListData(id, tIndex, false)
		end
	end

	if titleType == Const.SHOW_TITLE_TYPE.Prefix then
		self:_appendFriendNamePrefixTitles(ret)
	end

	for id, titleData in pairs(ShowTitleData) do
		local isMatchingType = titleData.titleType == titleType or titleData.titleType == Const.SHOW_TITLE_TYPE.None

		if not curUnlock[id] and isMatchingType and self:isItemShow(titleData) then
			ret[#ret + 1] = self:_createShowTitleListData(id, tIndex, true)
		end
	end

	return ret
end

function InfoPlayerMainModel:_createShowTitleListData(titleId, tIndex, isLock)
	local titleData = ShowTitleData[titleId]

	return {
		titleId = titleId,
		titleText = titleData.titleText,
		bgRes = titleData.bgRes,
		tIndex = tIndex,
		isLock = isLock,
		sourceDec = titleData.sourceDec,
		titleType = titleData.titleType,
		item = titleData.item
	}
end

function InfoPlayerMainModel:_appendFriendNamePrefixTitles(titleList)
	for _, friend in ipairs(pg.game.chat:getFriendList() or EMPTY_TABLE) do
		local friendUid = tostring(friend.playerId or "")
		local playerInfo = pg.game.chat:getPlayerInfo(friend.playerId)
		local friendName = playerInfo and playerInfo.playerName or ""
		local canAppend = not string.isNilOrEmpty(friendUid) and not string.isNilOrEmpty(friendName) and self:_hasUnlockedFriendNamePrefix(friend.playerId)

		if canAppend then
			titleList[#titleList + 1] = {
				tIndex = 0,
				isFriendTitle = true,
				isLock = false,
				titleId = "friend_" .. friendUid,
				titleText = friendName,
				titleType = Const.SHOW_TITLE_TYPE.Prefix,
				friendUid = friendUid,
				friendName = friendName
			}
		end
	end
end

function InfoPlayerMainModel:_hasUnlockedFriendNamePrefix(friendUid)
	local permissionId = self:_getFriendNamePrefixPermissionId()

	return pg.game.chat:isFriendshipPermissionUnlocked(friendUid, permissionId)
end

function InfoPlayerMainModel:_getFriendNamePrefixPermissionId()
	if self._friendNamePrefixPermissionId ~= nil then
		return self._friendNamePrefixPermissionId
	end

	for permissionId, permissionData in pairs(FriendshipLevelFuncData) do
		if permissionData.type == Const.FriendshipPermissionType.FriendNamePrefix then
			self._friendNamePrefixPermissionId = permissionId

			break
		end
	end

	return self._friendNamePrefixPermissionId
end

function InfoPlayerMainModel:getCardBackGroundList()
	local ret = {}
	local data = CardBackgroundData
	local curUnlock = self:getUnlockDict(pg.me.cardBackgroundDicts, data)

	for index, value in pairs(curUnlock) do
		if value and data[index] then
			ret[#ret + 1] = {
				isLock = false,
				id = index,
				cardName = data[index].cardName,
				sourceDec = data[index].sourceDec,
				res = data[index].res,
				item = data[index].item
			}
		end
	end

	for id, value in pairs(data) do
		if not curUnlock[id] and self:isItemShow(value) then
			ret[#ret + 1] = {
				isLock = true,
				id = id,
				cardName = value.cardName,
				sourceDec = value.sourceDec,
				res = value.res,
				item = value.item
			}
		end
	end

	return ret
end

function InfoPlayerMainModel:isHeadIconLock(id)
	local data = PlayerHeadIconData[id]

	return data ~= nil and data.defaultUnlock ~= 1 and (pg.me.headIconDicts[id] == nil or pg.me.headIconDicts[id] == false)
end

function InfoPlayerMainModel:isHeadFrameLock(id)
	local data = PlayerHeadFrameData[id]

	return data ~= nil and data.defaultUnlock ~= 1 and (pg.me.headFrameDicts[id] == nil or pg.me.headFrameDicts[id] == false)
end

function InfoPlayerMainModel:isTitleLock(id)
	if id == Const.SHOW_TITLE_TYPE.None or not id then
		return false
	end

	local data = ShowTitleData[id]

	return data ~= nil and data.defaultUnlock ~= 1 and (pg.me.showTitleDicts[id] == nil or pg.me.showTitleDicts[id] == false)
end

function InfoPlayerMainModel:isCardBackgroundLock(id)
	local data = CardBackgroundData[id]

	return data ~= nil and data.defaultUnlock ~= 1 and (pg.me.cardBackgroundDicts[id] == nil or pg.me.cardBackgroundDicts[id] == false)
end

function InfoPlayerMainModel:isItemShow(data)
	if self:isLotteryOpen(data) == false then
		return false
	end

	return true
end

function InfoPlayerMainModel:isLotteryOpen(data)
	if data.drawId then
		local isOpen = true

		return isOpen
	end

	return true
end

return InfoPlayerMainModel
