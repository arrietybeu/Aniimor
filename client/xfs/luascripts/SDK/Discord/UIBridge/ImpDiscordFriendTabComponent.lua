-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Discord\\UIBridge\\ImpDiscordFriendTabComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local M = {}
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local DiscordSocialUtils = require("Utils.DiscordSocialUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local DiscordFriendService = require("SDK.Discord.DiscordFriendService")
local Time = require("Core.Common.Time")

M.DISCORD_FRIENDS_GROUP_ID = "discord_friends"
M.DISCORD_PLAYER_ID_PREFIX = "discord:"
M.DISCORD_FRIENDS_KEY = "DISCORD_FRIEND"
M.FRIEND_CHANNEL_TYPE = 1
M.SHARE_ITEMS = {
	{
		tIndex = 0
	}
}

function M.isDiscordFriend(data)
	return type(data) == "table" and data.isDiscordFriend == true
end

function M.isDiscordBound()
	return pg.global.sdkManager:isDiscordBound() == true
end

function M.shouldShowDiscordFriendGroup()
	return M.isDiscordBound() and DiscordSocialUtils.isReady()
end

function M.getDiscordFriendGroupCount()
	return M.shouldShowDiscordFriendGroup() and 1 or 0
end

function M.getDiscordFriendDisplayName(friend)
	local displayName = tostring(friend and friend.displayName or "")

	if not string.isNilOrEmpty(displayName) then
		return displayName
	end

	return pg.getGameString(M.DISCORD_FRIENDS_KEY)
end

function M:initView()
	M.refreshShareButton(self)

	if not M.isDiscordBound() then
		return
	end

	pg.global.sdkManager:ensureDiscordTokenValid()
end

function M:addListener()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnShareUButton = objectReference:GetRefValue("btnShareUButton")

	if self.btnShareUButton then
		function self.btnShareUButton.luaClick()
			self.listFriendChannelUList:DeselectAll()
			self.btnShareUButton:SetSelected(true)
		end

		function self.btnShareUButton.luaNavFocused()
			self.listFriendChannelUList:DeselectAll()
			self.btnShareUButton:SetSelected(false)
		end

		function self.btnShareUButton.luaRenderTooltip(_, popup)
			M.renderShareTooltip(self, popup)
		end

		function self.btnShareUButton.luaTooltipPopup(_, isOpen)
			if not isOpen then
				self.btnShareUButton:SetSelected(false)
			end
		end

		local originalChannelSelectedChanged = self.listFriendChannelUList.luaSelectedChanged

		function self.listFriendChannelUList.luaSelectedChanged(ulist, isSelected)
			originalChannelSelectedChanged(ulist, isSelected)

			if isSelected then
				self.btnShareUButton:SetSelected(false)
			end
		end
	end

	local originalGroupRender = self.listFriendUList.luaRenderItem

	function self.listFriendUList.luaRenderItem(button, index, data)
		originalGroupRender(button, index, data)

		if data.isDiscordGroup == true then
			local objectReference = button:GetComponent("ObjectReference")
			local settingUButton = objectReference:GetRefValue("settingUButton")

			if settingUButton then
				settingUButton:SetActive(false)
			end
		end
	end
end

function M:refreshShareButton()
	if self.btnShareUButton then
		self.btnShareUButton:SetActive(M.isDiscordBound())
	end
end

function M:renderShareTooltip(popup)
	local objectReference = popup:GetComponent("ObjectReference")
	local titleTxt = objectReference:GetRefValue("textUSDFText")
	local shareListUList = objectReference:GetRefValue("shareListUList")

	if shareListUList then
		function shareListUList.luaRenderItem(button)
			function button.luaClick()
				DiscordFriendService.requestDiscordActivityShare(Const.DiscordInviteType.FriendInvite)
				self.btnShareUButton:CloseTooltip()
			end
		end

		shareListUList:SetList(M.SHARE_ITEMS)
	end

	if titleTxt then
		ClientTextUtils.setText(titleTxt, tostring(pg.getGameString("DISCORD_SHARE_TITLE")))
	end
end

function M.beforeRenderFriendItem(data)
	if not M.isDiscordFriend(data) then
		return
	end

	if data.playerInfo and not string.isNilOrEmpty(data.playerId) then
		pg.game.chat:setPlayerData(data.playerId, data.playerInfo)
	end
end

function M:renderFriendItemName(button, index, data, playerInfo, rawName)
	if M.isDiscordFriend(data) and not string.isNilOrEmpty(playerInfo.discordDisplayName) then
		return playerInfo.discordDisplayName
	end

	return rawName
end

function M.shouldHideFriendItemGender(data)
	return M.isDiscordFriend(data) and data.hasMappedGameUid ~= true
end

function M:afterRenderFriendItemContent(data, playerInfo, objectReference)
	local isDiscordFriend = M.isDiscordFriend(data)
	local friendItemUButton = objectReference.transform:GetComponent("UButton")

	friendItemUButton:TryChangePage("AddFriend", isDiscordFriend and 1 or 0)

	if not isDiscordFriend then
		return
	end

	local comeUButton = objectReference:GetRefValue("comeUButton")
	local btnIntimateUButton = objectReference:GetRefValue("btnIntimateUButton")
	local intimateUImage = objectReference:GetRefValue("intimateUImage")

	comeUButton:SetActive(true)
	btnIntimateUButton:SetActive(false)
	intimateUImage:SetActive(false)
end

function M.buildDiscordPlayerInfo(friend)
	local discordUserId = tostring(friend and friend.id or "")
	local playerId = M.DISCORD_PLAYER_ID_PREFIX .. discordUserId
	local activityText = friend and (friend.activityDetails or friend.activityState or friend.activityName) or ""
	local currentTime = Time.secondCache

	return {
		hasMappedGameUid = false,
		isDiscordFriend = true,
		avatarPresetKey = 110001,
		headFrame = 0,
		headIcon = 1,
		level = "-",
		online = false,
		uid = playerId,
		playerId = playerId,
		playerName = M.getDiscordFriendDisplayName(friend),
		loginTime = currentTime,
		lastLogoutTime = currentTime,
		showSignature = activityText,
		discordUserId = discordUserId,
		discordDisplayName = M.getDiscordFriendDisplayName(friend),
		discordStatus = friend and friend.status or ""
	}
end

function M.appendDiscordFriends(result, friends, discordPlayerInfoMap)
	for _, friend in ipairs(friends or EMPTY_TABLE) do
		local playerInfo = M.buildDiscordPlayerInfo(friend)
		local gamePlayerInfo = discordPlayerInfoMap and discordPlayerInfoMap[playerInfo.discordUserId]

		if gamePlayerInfo then
			for key, value in pairs(gamePlayerInfo) do
				playerInfo[key] = value
			end

			local gameUid = tostring(gamePlayerInfo.uid or gamePlayerInfo.playerId or "")

			playerInfo.uid = gameUid
			playerInfo.playerId = gameUid
			playerInfo.discordUserId = tostring(friend.id or "")
			playerInfo.discordDisplayName = M.getDiscordFriendDisplayName(friend)
			playerInfo.discordStatus = friend.status or ""
			playerInfo.isDiscordFriend = true
			playerInfo.hasMappedGameUid = not string.isNilOrEmpty(gameUid)
			playerInfo.mappedGameUid = gameUid
		end

		table.insert(result, {
			isDiscordFriend = true,
			playerId = playerInfo.playerId,
			playerInfo = playerInfo,
			discordUserId = playerInfo.discordUserId,
			hasMappedGameUid = playerInfo.hasMappedGameUid == true,
			mappedGameUid = playerInfo.mappedGameUid
		})
	end
end

function M.buildDiscordFriendEntries(snapshot, discordPlayerInfoMap)
	local result = {}

	snapshot = snapshot or {}

	M.appendDiscordFriends(result, snapshot.onlinePlayingGame, discordPlayerInfoMap)
	M.appendDiscordFriends(result, snapshot.onlineElsewhere, discordPlayerInfoMap)
	M.appendDiscordFriends(result, snapshot.offline, discordPlayerInfoMap)

	return result
end

function M.compareDiscordFriend(a, b)
	local onlineA = a.playerInfo and a.playerInfo.online and 1 or 0
	local onlineB = b.playerInfo and b.playerInfo.online and 1 or 0

	if onlineA ~= onlineB then
		return onlineB < onlineA
	end

	local friendshipA = pg.game.chat:getFriendship(a.playerId) or 0
	local friendshipB = pg.game.chat:getFriendship(b.playerId) or 0

	if friendshipA ~= friendshipB then
		return friendshipB < friendshipA
	end

	return a.playerId < b.playerId
end

function M.sortDiscordFriends(discordFriends)
	table.sort(discordFriends, M.compareDiscordFriend)
end

function M:injectFriendGroupList(friendGroupList)
	if friendGroupList == nil then
		return
	end

	for index = #friendGroupList, 1, -1 do
		if friendGroupList[index].id == M.DISCORD_FRIENDS_GROUP_ID then
			table.remove(friendGroupList, index)
		end
	end

	if not M.shouldShowDiscordFriendGroup() then
		return
	end

	local snapshot = DiscordFriendService.getFriendSnapshot()
	local discordPlayerInfoMap = DiscordFriendService.getFriendPlayerInfoMap()
	local discordFriends = M.buildDiscordFriendEntries(snapshot, discordPlayerInfoMap)
	local onlineCount = 0

	for _, friend in ipairs(discordFriends) do
		if friend.playerInfo.online then
			onlineCount = onlineCount + 1
		end
	end

	table.insert(friendGroupList, 1, {
		expand = true,
		isDiscordGroup = true,
		id = M.DISCORD_FRIENDS_GROUP_ID,
		groupLabel = M.DISCORD_FRIENDS_KEY,
		groupFriendData = discordFriends,
		subCount = onlineCount
	})
	M.sortDiscordFriends(discordFriends)

	local chat = pg.game.chat

	if chat.friendGroupList == friendGroupList then
		chat.friendGroupId2Index = {}

		for groupIdx, group in ipairs(friendGroupList) do
			if group and group.id ~= nil then
				chat.friendGroupId2Index[tostring(group.id)] = groupIdx
			end
		end
	end
end

function M:refreshDiscordFriends()
	M.refreshShareButton(self)

	if self.curPanelType == M.FRIEND_CHANNEL_TYPE then
		self:refreshFriendList()
	end
end

function M:refreshDiscordFriendsPlayerInfo()
	if self.curPanelType == M.FRIEND_CHANNEL_TYPE then
		self:refreshFriendList()
	end
end

function M:bindFriendItemEvents(button, data, playerInfo, objectReference)
	if not M.isDiscordFriend(data) then
		return false
	end

	local avatarUButton = objectReference:GetRefValue("avatarUButton")
	local teamUButton = objectReference:GetRefValue("teamUButton")
	local comeUButton = objectReference:GetRefValue("comeUButton")
	local addFriendUButton = objectReference:GetRefValue("addFriendUButton")
	local blacklistUButton = objectReference:GetRefValue("blacklistUButton")
	local btnIntimateUButton = objectReference:GetRefValue("btnIntimateUButton")

	teamUButton:SetActive(true)

	function teamUButton.luaClick()
		DiscordFriendService.inviteDiscordFriendToTeam(playerInfo)
	end

	if addFriendUButton then
		function addFriendUButton.luaClick()
			DiscordFriendService.inviteDiscordFriendToAddFriend(playerInfo)
		end
	end

	comeUButton:SetActive(false)

	function comeUButton.luaClick()
		return
	end

	function button.luaClick()
		return
	end

	function avatarUButton.luaClick()
		local canOpenPlayerCard = playerInfo.hasMappedGameUid == true and not string.isNilOrEmpty(playerInfo.mappedGameUid or playerInfo.playerId)

		if canOpenPlayerCard then
			LuaUIUtils.openInfoPlayerCard({
				playerId = tostring(playerInfo.mappedGameUid or playerInfo.playerId),
				playerInfo = playerInfo
			})

			return
		end
	end

	function btnIntimateUButton.luaClick()
		return
	end

	blacklistUButton:SetActive(false)

	return true
end

return M
