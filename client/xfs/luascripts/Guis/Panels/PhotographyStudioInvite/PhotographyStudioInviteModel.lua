-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotographyStudioInvite\\PhotographyStudioInviteModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local AppearanceVariableData = require("Data.appearance_variable_data")
local FashionLevelData = require("Data.fashion_level_data")
local PlatformPhotographyStudioInviteFilterService = require("SDK.Platform.PlatformPhotographyStudioInviteFilterService")
local PhotographyStudioInviteModel = Class.LightClass("PhotographyStudioInviteModel", UIModel)

PhotographyStudioInviteModel.TabType = {
	Invited = 1,
	Invite = 0
}
PhotographyStudioInviteModel.GroupType = {
	InviteJoined = 1,
	InvitedPending = 5,
	InvitedJoined = 4,
	InviteUnavailable = 3,
	InviteAvailable = 2
}
PhotographyStudioInviteModel.ItemType = {
	InviteJoined = 5,
	InvitePending = 4,
	InvitedPending = 3,
	InvitedJoined = 0,
	InviteUnavailable = 2,
	InviteAvailable = 1
}

local function getRecordField(data, fieldName)
	if not data then
		return nil
	end

	local lowerFieldName = string.lower(string.sub(fieldName, 1, 1)) .. string.sub(fieldName, 2)

	return data[fieldName] ~= nil and data[fieldName] or data[lowerFieldName]
end

local function getUidKey(uid)
	return uid ~= nil and tostring(uid) or nil
end

local function isSameUid(left, right)
	return left ~= nil and right ~= nil and getUidKey(left) == getUidKey(right)
end

local function matchSearch(playerInfo, uid, searchText)
	if string.isNilOrEmpty(searchText) then
		return true
	end

	local keyword = string.lower(tostring(searchText))
	local playerName = string.lower(tostring(playerInfo and playerInfo.playerName or ""))
	local uidText = string.lower(tostring(uid or ""))

	return string.find(playerName, keyword, 1, true) ~= nil or string.find(uidText, keyword, 1, true) ~= nil
end

local function getAtime(data)
	return tonumber(getRecordField(data, "Atime")) or 0
end

local function sortPlayerItems(items)
	table.sort(items, function(left, right)
		if left.sortPriority ~= right.sortPriority then
			return left.sortPriority < right.sortPriority
		end

		if left.atime ~= right.atime then
			return left.atime > right.atime
		end

		return getUidKey(left.uid) < getUidKey(right.uid)
	end)
end

local function appendGroup(groups, groupType, labelKey, countText, items)
	if #items == 0 then
		return
	end

	groups[#groups + 1] = {
		groupType = groupType,
		label = pg.getGameString(labelKey),
		countText = tostring(countText or ""),
		items = items
	}
end

function PhotographyStudioInviteModel:getStudioInfo(studioUid)
	return studioUid and pg.me:getStudioInfo(studioUid) or nil
end

function PhotographyStudioInviteModel:isStudioMaster(studioUid)
	return studioUid ~= nil and pg.me:isStudioMaster(studioUid)
end

function PhotographyStudioInviteModel:getInviteCount(studioUid)
	local info = self:getStudioInfo(studioUid) or {}

	return #(info.members or {}), tonumber(AppearanceVariableData.STUDIO_INVITE_FRIEND_NUM) or 0
end

function PhotographyStudioInviteModel:getInvitedCount()
	local count = 0

	for _, record in ipairs(pg.me:getReceivedPhotographyStudioInvitations()) do
		if getRecordField(record, "Accepted") == true then
			count = count + 1
		end
	end

	local fashionData = FashionLevelData[pg.me.fashionRewardLevel] or {}

	return count, tonumber(fashionData.studioInvited) or 0
end

function PhotographyStudioInviteModel:getCount(tabType, studioUid)
	if tabType == self.TabType.Invite then
		return self:getInviteCount(studioUid)
	end

	return self:getInvitedCount()
end

function PhotographyStudioInviteModel:getTabRedDotCount(tabType, studioUid)
	if tabType == self.TabType.Invite then
		return pg.me:getUnreadPhotographyStudioAcceptedInviteCount(studioUid)
	end

	return pg.me:getUnreadPhotographyStudioInvitationCount()
end

function PhotographyStudioInviteModel:markTabRedDotRead(tabType, studioUid)
	if tabType == self.TabType.Invite then
		return pg.me:markPhotographyStudioAcceptedInvitesRead(studioUid)
	end

	return pg.me:markPhotographyStudioInvitationsRead()
end

function PhotographyStudioInviteModel:getTabs(studioUid)
	local tabs = {}

	if self:isStudioMaster(studioUid) then
		tabs[#tabs + 1] = {
			tabType = self.TabType.Invite,
			label = pg.getGameString("PHOTO_STUDIO_INVITE_TAB")
		}
	end

	tabs[#tabs + 1] = {
		tabType = self.TabType.Invited,
		label = pg.getGameString("PHOTO_STUDIO_INVITED_TAB")
	}

	local tabCount = #tabs

	for index, data in ipairs(tabs) do
		if tabCount == 1 then
			data.tIndex = 1
		elseif index == 1 then
			data.tIndex = 0
		elseif index == tabCount then
			data.tIndex = 2
		else
			data.tIndex = 1
		end
	end

	return tabs
end

function PhotographyStudioInviteModel:getSentRecordMap(studioUid)
	local result = {}

	for _, record in ipairs(pg.me:getSentPhotographyStudioInvitations()) do
		if isSameUid(getRecordField(record, "PhotographyStudioUid"), studioUid) then
			local uid = getRecordField(record, "InvitedUid")

			if uid then
				result[getUidKey(uid)] = record
			end
		end
	end

	return result
end

function PhotographyStudioInviteModel:buildPlayerItem(uid, playerId, itemType, record, studioUid, searchText, sortPriority, cantInvitedText)
	if uid == nil then
		return nil
	end

	playerId = playerId or uid

	local playerInfo = pg.game.chat:getPlayerInfo(playerId) or pg.game.chat:getPlayerInfo(uid)

	if not matchSearch(playerInfo, uid, searchText) then
		return nil
	end

	return {
		uid = uid,
		playerId = playerId,
		playerInfo = playerInfo,
		type = itemType,
		atime = getAtime(record),
		sortPriority = sortPriority or 0,
		studioUid = studioUid,
		record = record,
		cantInvitedText = cantInvitedText
	}
end

function PhotographyStudioInviteModel:getInviteGroups(studioUid, searchText)
	local groups = {}
	local joinedItems = {}
	local availableItems = {}
	local unavailableItems = {}
	local handledUidMap = {}
	local sentRecordMap = self:getSentRecordMap(studioUid)
	local info = self:getStudioInfo(studioUid) or {}
	local requiredLevel = tonumber(AppearanceVariableData.STUDIO_INVITE_FRIEND_LV) or 0
	local inviteLimit = tonumber(AppearanceVariableData.STUDIO_INVITE_FRIEND_NUM) or 0
	local isStudioFull = type(info.members) == "table" and inviteLimit <= #info.members
	local cantInvitedIntimacyText, cantInvitedStudioFullText

	local function appendPlayer(items, uid, playerId, itemType, record, sortPriority, cantInvitedText)
		local item = self:buildPlayerItem(uid, playerId, itemType, record, studioUid, searchText, sortPriority, cantInvitedText)

		if item then
			items[#items + 1] = item
		end
	end

	for _, member in ipairs(info.members or EMPTY_TABLE) do
		local uid = type(member) == "table" and member.uid or member
		local uidKey = getUidKey(uid)

		if uidKey then
			handledUidMap[uidKey] = true

			appendPlayer(joinedItems, uid, uid, self.ItemType.InviteJoined, sentRecordMap[uidKey], 0)
		end
	end

	for _, friend in pairs(pg.game.chat:getFriendList() or EMPTY_TABLE) do
		local playerId = friend.playerId or friend.uid
		local playerInfo = pg.game.chat:getPlayerInfo(playerId)
		local uid = playerInfo and playerInfo.uid or friend.uid or playerId
		local uidKey = getUidKey(uid)

		if uidKey and not handledUidMap[uidKey] then
			handledUidMap[uidKey] = true

			local record = sentRecordMap[uidKey]

			if record and getRecordField(record, "Accepted") == true then
				appendPlayer(joinedItems, uid, playerId, self.ItemType.InviteJoined, record, 0)
			elseif record then
				appendPlayer(availableItems, uid, playerId, self.ItemType.InvitePending, record, 0)
			else
				local friendshipLevel = tonumber(pg.game.chat:getFriendship(playerId)) or 0

				if requiredLevel <= friendshipLevel then
					if isStudioFull then
						cantInvitedStudioFullText = cantInvitedStudioFullText or pg.getGameString("PHOTO_STUDIO_CANT_INVITE_STUDIO_FULL")

						appendPlayer(unavailableItems, uid, playerId, self.ItemType.InviteUnavailable, nil, 0, cantInvitedStudioFullText)
					else
						appendPlayer(availableItems, uid, playerId, self.ItemType.InviteAvailable, nil, 1)
					end
				else
					cantInvitedIntimacyText = cantInvitedIntimacyText or string.format(pg.getGameString("PHOTO_STUDIO_CANT_INVITE_INTIMACY"), requiredLevel)

					appendPlayer(unavailableItems, uid, playerId, self.ItemType.InviteUnavailable, nil, 0, cantInvitedIntimacyText)
				end
			end
		end
	end

	for uidKey, record in pairs(sentRecordMap) do
		if not handledUidMap[uidKey] then
			local uid = getRecordField(record, "InvitedUid")

			if getRecordField(record, "Accepted") == true then
				appendPlayer(joinedItems, uid, uid, self.ItemType.InviteJoined, record, 0)
			else
				appendPlayer(availableItems, uid, uid, self.ItemType.InvitePending, record, 0)
			end
		end
	end

	sortPlayerItems(joinedItems)
	sortPlayerItems(availableItems)
	sortPlayerItems(unavailableItems)

	local inviteCount, inviteLimit = self:getInviteCount(studioUid)

	appendGroup(groups, self.GroupType.InviteJoined, "PHOTO_STUDIO_GROUP_JOINED_CURRENT", string.format("%s/%s", inviteCount, inviteLimit), joinedItems)
	appendGroup(groups, self.GroupType.InviteAvailable, "PHOTO_STUDIO_GROUP_INVITABLE", #availableItems, availableItems)
	appendGroup(groups, self.GroupType.InviteUnavailable, "PHOTO_STUDIO_GROUP_UNINVITABLE", #unavailableItems, unavailableItems)

	return groups
end

function PhotographyStudioInviteModel:getInvitedGroups(searchText)
	local groups = {}
	local joinedItems = {}
	local pendingItems = {}

	for _, record in ipairs(pg.me:getReceivedPhotographyStudioInvitations()) do
		local uid = getRecordField(record, "InvitationUid")
		local studioUid = getRecordField(record, "PhotographyStudioUid")

		if getRecordField(record, "Accepted") == true then
			local item = self:buildPlayerItem(uid, uid, self.ItemType.InvitedJoined, record, studioUid, searchText, 0)

			if item then
				joinedItems[#joinedItems + 1] = item
			end
		else
			local playerInfo = pg.game.chat:getPlayerInfo(uid)
			local canReceiveInvite = PlatformPhotographyStudioInviteFilterService:canReceiveInvite(playerInfo)

			if canReceiveInvite then
				local item = self:buildPlayerItem(uid, uid, self.ItemType.InvitedPending, record, studioUid, searchText, 0)

				if item then
					pendingItems[#pendingItems + 1] = item
				end
			end
		end
	end

	sortPlayerItems(joinedItems)
	sortPlayerItems(pendingItems)

	local invitedCount, invitedLimit = self:getInvitedCount()

	appendGroup(groups, self.GroupType.InvitedJoined, "PHOTO_STUDIO_GROUP_JOINED", string.format("%s/%s", invitedCount, invitedLimit), joinedItems)
	appendGroup(groups, self.GroupType.InvitedPending, "PHOTO_STUDIO_GROUP_RECEIVED", #pendingItems, pendingItems)

	return groups
end

function PhotographyStudioInviteModel:getList(tabType, studioUid, searchText)
	if tabType == self.TabType.Invite then
		return self:getInviteGroups(studioUid, searchText)
	end

	return self:getInvitedGroups(searchText)
end

function PhotographyStudioInviteModel:getInvitationUid(record)
	return getRecordField(record, "InvitationUid")
end

return PhotographyStudioInviteModel
