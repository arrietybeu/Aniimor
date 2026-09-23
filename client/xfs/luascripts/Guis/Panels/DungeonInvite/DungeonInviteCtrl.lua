-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DungeonInvite\\DungeonInviteCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local HotkeyConst = require("Const.HotkeyConst")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local DungeonInviteCtrl = Class.LightClass("DungeonInviteCtrl", UICtrl)
local LevelData = require("Data.level_data")
local Time = require("Core.Common.Time")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Const = require("Common.Const.Const")
local AddressDataConst = require("Const.AddressDataConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local FriendshipLevelData = require("Data.friendship_level_data")
local PlatformFriendListService = require("SDK.Platform.PlatformFriendListService")

DungeonInviteCtrl.messages = {
	[MessageName.RECV_FRIEND_LIST] = {
		"refreshUI",
		true
	},
	[MessageName.FRIEND_CHAT_GROUP_UPDATE] = {
		"refreshUI",
		true
	},
	[MessageName.SYNC_TEAM_INFO] = {
		"onChannelInviteTeamInfoChanged",
		true
	}
}
DungeonInviteCtrl.TabType = {
	Channel = 1,
	Friend = 0,
	Recent = 2
}
DungeonInviteCtrl.SHARE_ITEMS = {
	{
		tIndex = 0
	}
}

function DungeonInviteCtrl:onCreate(info)
	self.pendingChannelInvite = nil

	UICtrl.onCreate(self, info)

	self.selectTab = DungeonInviteCtrl.TabType.Friend
	self.searchText = ""
	self.recentPlaymates = {}
	self.hasRecentPlaymatesData = false
	self.isRequestingRecentPlaymates = false
	self.dungeonId = info and info.dungeonId or nil
	self.hardLv = info and (info.hardLv or info.difficultLv) or nil

	self:initUI()
end

function DungeonInviteCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.bgCloseUButton.luaClick()
		self:close()
	end

	function self.view.listTabUList.luaRenderItem(button, index, data)
		self:renderTabItem(button, data)
	end

	function self.view.listTabUList.luaSelectedChanged(uList, isSelected)
		if not isSelected then
			return
		end

		local data = uList.selectedItem

		if data then
			self:switchTab(data.tabType)
		end
	end

	function self.view.inputFieldUTMPInputField.luaValueChanged(text)
		self.searchText = text or ""

		self:refreshUI(self.selectTab)
	end

	function self.view.inputFieldUTMPInputField.luaEndEdit(text)
		self.searchText = text or ""

		self:refreshUI(self.selectTab)
	end

	function self.view.btnSearchUButton.luaClick()
		self.searchText = self.view.inputFieldUTMPInputField.text or ""

		self:refreshUI(self.selectTab)
	end

	function self.view.btnAddUButton.luaClick()
		self:close()
		pg.global.ui:open(UIConst.UI_ID_CHAT, {
			openAddFriend = true,
			initTab = pg.game.chat.tabType.Friend
		}, nil, nil, {
			ignoreDisableMainCamera = true
		})
	end

	if self.view.btnShareUButton then
		self.view.btnShareUButton.navForceNonInteractable = true

		function self.view.btnShareUButton.luaRenderTooltip(_, popup)
			self:renderDiscordShareTooltip(popup)
		end

		function self.view.btnShareUButton.luaTooltipPopup(_, isOpen)
			if not isOpen then
				self.view.btnShareUButton:SetSelected(false)
			end
		end
	end
end

function DungeonInviteCtrl:renderDiscordShareTooltip(popup)
	local objectReference = popup:GetComponent("ObjectReference")
	local titleTxt = objectReference:GetRefValue("textUSDFText")
	local shareListUList = objectReference:GetRefValue("shareListUList")

	function shareListUList.luaRenderItem(button)
		function button.luaClick()
			local DiscordFriendService = require("SDK.Discord.DiscordFriendService")

			DiscordFriendService.requestDiscordActivityShare(Const.DiscordInviteType.TeamInvite)
			self.view.btnShareUButton:CloseTooltip()
		end
	end

	shareListUList:SetList(DungeonInviteCtrl.SHARE_ITEMS)

	if titleTxt then
		ClientTextUtils.setText(titleTxt, tostring(pg.getGameString("DISCORD_SHARE_TITLE")))
	end
end

function DungeonInviteCtrl:renderTabItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local text = objectReference:GetRefValue("txtNameUBaseText")

	ClientTextUtils.setText(text, pg.getGameString(data.textKey))
end

function DungeonInviteCtrl:switchTab(tabType)
	if self.selectTab == tabType then
		return
	end

	self.selectTab = tabType
	self.view.inputFieldUTMPInputField.text = ""

	self:refreshUI(tabType)
end

function DungeonInviteCtrl:initUI()
	if self.view.btnShareUButton then
		self.view.btnShareUButton:SetActive(pg.global.sdkManager:isDiscordBound() == true)
	end

	function self.view.listInviteUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local playerNameUBaseText = objectReference:GetRefValue("playerNameUBaseText")
		local btnInviteUButton = objectReference:GetRefValue("btnInviteUButton")
		local iconChannelUImage = objectReference:GetRefValue("iconChannelUImage")
		local txtChannelUBaseText = objectReference:GetRefValue("txtChannelUBaseText")
		local countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")
		local textStateUSDFText = objectReference:GetRefValue("textStateUSDFText")
		local intimacyUImage = objectReference:GetRefValue("intimacyUImage")
		local textLvUSDFText = objectReference:GetRefValue("textLvUSDFText")
		local intimacyUButton = objectReference:GetRefValue("intimacyUButton")
		local playerHeadUWidget = objectReference:GetRefValue("playerHeadUWidget")

		button.enabledTooltip = self.selectTab ~= DungeonInviteCtrl.TabType.Channel

		pg.global.ui.chat:handlePlayerTooltip(button, data)

		local inviteInterval = 60
		local inviteKey = self.selectTab == DungeonInviteCtrl.TabType.Channel and self:getChannelInviteKey(data) or data.playerId
		local timeLimit = inviteKey and pg.game.chat.lastSendTeamInvite[inviteKey] or 0

		timeLimit = inviteInterval - (Time.realSecondCache - timeLimit)

		button:TryChangePage("Invite", timeLimit <= 0 and 0 or 1)
		button:TryChangePage("State", data.status or 1)

		if timeLimit > 0 then
			countDownUCountDown:Play(timeLimit, timeLimit)

			function countDownUCountDown.luaFinished()
				button:TryChangePage("Invite", 0)
			end
		end

		function btnInviteUButton.luaClick()
			self:onInviteButtonClick(button, countDownUCountDown, inviteInterval, data)
		end

		intimacyUButton.luaClick = nil

		intimacyUButton:RemoveLuaGamepadHotkey()
		intimacyUButton:SetHotkeyConsoleBar("", 0)
		button:TryChangePage("Type", self.selectTab == DungeonInviteCtrl.TabType.Channel and 1 or 0)

		if self.selectTab == DungeonInviteCtrl.TabType.Channel then
			iconChannelUImage.url = data.icon

			ClientTextUtils.setText(txtChannelUBaseText, data.name)
		else
			local playerInfo = pg.game.chat:getPlayerInfo(data.playerId)

			if playerInfo == nil then
				return
			end

			button:TryChangePage("State", playerInfo.online and 0 or 1)

			if self.selectTab == DungeonInviteCtrl.TabType.Friend then
				local function openFriendIntimacy()
					pg.global.ui:open(UIConst.UI_ID_FRIEND_INTIMACY, {
						notBackToPlayerCard = true,
						playerInfo = playerInfo,
						friendshipValue = pg.game.chat:getFriendIntimacy(data.playerId)
					})

					return false
				end

				intimacyUButton.luaClick = openFriendIntimacy

				intimacyUButton:SetGamepadLongPress(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest, nil, 0, openFriendIntimacy)
				intimacyUButton:SetHotkeyActiveOnlyInCurrentItem(true)
				intimacyUButton:SetHotkeyConsoleBar("CONSOLE_INTIMACY", 0)
			end

			local playerName = LuaUIUtils.getPlayerDisplayName(data.playerId, playerInfo.playerName or "")
			local _h = DungeonInviteCtrl._platformHooks

			playerName = _h and _h.renderInvitePlayerName and _h.renderInvitePlayerName(self, data, playerInfo, playerName) or playerName

			ClientTextUtils.setText(playerNameUBaseText, playerName)
			LuaUIUtils.renderPlayerAvatarImages(playerHeadUWidget, {
				playerInfo = playerInfo
			})

			local lastLogoutTime = LuaUIUtils.getLastTimeStr(playerInfo.lastLogoutTime)
			local stateText = playerInfo.online and pg.getGameString("ONLINE") or lastLogoutTime

			if self.selectTab == DungeonInviteCtrl.TabType.Recent then
				local dungeonName = self:getRecentDungeonName(data)

				if not string.isNilOrEmpty(dungeonName) then
					stateText = dungeonName
				end
			end

			ClientTextUtils.setText(textStateUSDFText, stateText)

			local friendShipLevel = pg.game.chat:getFriendship(data.playerId)
			local friendShipIcon = friendShipLevel > 0 and FriendshipLevelData[friendShipLevel] and FriendshipLevelData[friendShipLevel].levelIcon or ""

			intimacyUImage.url = friendShipIcon

			ClientTextUtils.setText(textLvUSDFText, playerInfo.level)
		end
	end

	ClientTextUtils.setText(self.view.txtEmptyUSDFText, pg.getGameString("DUNGEON_INVITE_SEARCH_EMPTY"))

	self.tabDatas = {
		{
			textKey = "FRIEND",
			tIndex = 0,
			tabType = DungeonInviteCtrl.TabType.Friend
		},
		{
			textKey = "CHAT_CHANNEL",
			tIndex = 1,
			tabType = DungeonInviteCtrl.TabType.Channel
		},
		{
			textKey = "RECENTLY_TEAMED_PLAYER",
			tIndex = 2,
			tabType = DungeonInviteCtrl.TabType.Recent
		}
	}

	self.view.listTabUList:SetList(self.tabDatas)
	self.view.listTabUList:SelectItem(0, false)
	self:refreshUI(self.selectTab)
	ClientTextUtils.setText(self.view.titleTextUSDFText, pg.getGameString("DUNGEON_INVITE_LIST"))
	ClientTextUtils.setText(self.view.txtEmptyUSDFText, pg.getGameString("DUNGEON_INVITE_SEARCH_EMPTY"))
	ClientTextUtils.setText(self.view.placeHolderUSDFText, pg.getGameString("FRIEND_SEARCH_DESC"))

	local txtAddUSDFText = self.view.btnAddUButton:GetComponent("ObjectReference"):GetRefValue("txtNameUText")

	ClientTextUtils.setText(txtAddUSDFText, pg.getGameString("CHAT_ADD_FRIENDS"))

	local _h = DungeonInviteCtrl._platformHooks

	if _h and _h.initUI then
		_h.initUI(self)
	end
end

function DungeonInviteCtrl:onInviteButtonClick(button, countDown, inviteInterval, data)
	if self.selectTab == DungeonInviteCtrl.TabType.Channel then
		self:prepareChannelDungeonInvite(data)

		return
	end

	pg.game.chat:teamHandle(data.playerId, nil, {
		dungeonSceneId = tonumber(self.dungeonId) or 0,
		hardLv = tonumber(self.hardLv) or 0
	})

	pg.game.chat.lastSendTeamInvite[data.playerId] = Time.realSecondCache

	self:startInviteButtonCooldown(button, countDown, inviteInterval)
end

function DungeonInviteCtrl:startInviteButtonCooldown(button, countDown, inviteInterval)
	button:TryChangePage("Invite", 1)
	countDown:Play(inviteInterval, inviteInterval)

	function countDown.luaFinished()
		button:TryChangePage("Invite", 0)
	end
end

function DungeonInviteCtrl:prepareChannelDungeonInvite(data)
	if self.pendingChannelInvite then
		return
	end

	if pg.me:isInTeam() and not pg.me:isTeamLeader() then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_ERROR_NOT_TEAM_LEADER"))

		return
	end

	local context = {
		channelType = data.channelType,
		channelId = data.channelId,
		initTab = data.initTab,
		initChannelType = data.initChannelType,
		initChannelId = data.initChannelId,
		initGroupBase = data.initGroupBase,
		initSecondTab = data.initSecondTab,
		inviteKey = self:getChannelInviteKey(data),
		dungeonId = tonumber(self.dungeonId) or 0,
		hardLv = tonumber(self.hardLv) or 0
	}

	self.pendingChannelInvite = context

	if self:isChannelInviteTeamReady(context) then
		self:sendChannelDungeonInvite(context)

		return
	end

	if not pg.me:isInTeam() then
		pg.me:createSingleTeam(context.dungeonId, context.hardLv)

		return
	end

	pg.me:applyTeamDungeon(context.dungeonId, context.hardLv, true)
end

function DungeonInviteCtrl:onChannelInviteTeamInfoChanged()
	local context = self.pendingChannelInvite

	if not context then
		return
	end

	if pg.me:isInTeam() and not pg.me:isTeamLeader() then
		self:finishChannelDungeonInvite(context)
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_ERROR_NOT_TEAM_LEADER"))

		return
	end

	if self:isChannelInviteTeamReady(context) then
		self:sendChannelDungeonInvite(context)
	end
end

function DungeonInviteCtrl:isChannelInviteTeamReady(context)
	if not pg.me:isInTeam() or not pg.me:isTeamLeader() then
		return false
	end

	local teamInfo = pg.me:getCurTeamInfo()
	local teamId = tostring(teamInfo and teamInfo.teamId or "")
	local dungeonId = tonumber(teamInfo and teamInfo.dungeonSceneId) or 0

	return not string.isNilOrEmpty(teamId) and dungeonId == context.dungeonId
end

function DungeonInviteCtrl:sendChannelDungeonInvite(context)
	local canSend = self.pendingChannelInvite == context and self:isChannelInviteTeamReady(context)

	if not canSend then
		return
	end

	local teamInfo = pg.me:getCurTeamInfo()
	local teamInviteInfo = {
		teamId = teamInfo.teamId,
		dungeonId = context.dungeonId,
		hardLv = context.hardLv,
		inviteTime = Time.secondCache
	}
	local sent = pg.game.chat:sendMessage(pg.getGameString("TEAM_INVITE"), pg.game.chat.subMessageType.DungeonInvite, context.channelType, context.channelId, {
		[Const.CHAT_EXTRA_TYPE.TeamInvite] = teamInviteInfo
	})

	self:finishChannelDungeonInvite(context)

	if not sent then
		return
	end

	pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_INVITE_SUCCESS"))

	if context.inviteKey then
		pg.game.chat.lastSendTeamInvite[context.inviteKey] = Time.realSecondCache
	end

	local openCallback

	if context.channelType == pg.game.chat.channelType.Group then
		function openCallback()
			pg.game.chat:tryCreateGroupChat(context.channelId, true)
		end
	end

	self:close()
	pg.global.ui:open(UIConst.UI_ID_CHAT, {
		initTab = context.initTab,
		initChannelType = context.initChannelType,
		initChannelId = context.initChannelId,
		initGroupBase = context.initGroupBase,
		initSecondTab = context.initSecondTab
	}, openCallback, nil, {
		openAdditive = true,
		ignoreDisableMainCamera = true
	})
end

function DungeonInviteCtrl:finishChannelDungeonInvite(context)
	if self.pendingChannelInvite ~= context then
		return
	end

	self.pendingChannelInvite = nil
end

function DungeonInviteCtrl:refreshUI(tabType)
	tabType = tabType or self.selectTab

	if tabType == DungeonInviteCtrl.TabType.Recent and not self.hasRecentPlaymatesData then
		self:requestRecentPlaymates()
		self:refreshTabSelected()
		self.view.rootUComponent:TryChangePage("Empty", 1)
		self.view.listInviteUList:SetList({})
		self.view.searchUWidget:SetActive(false)

		return
	end

	self:refreshTabSelected()

	local rawData = self:getInviteData(tabType)
	local data = self:filterInviteData(rawData)
	local emptyState = 0

	if #data <= 0 then
		emptyState = not string.isNilOrEmpty(self.searchText) and #(rawData or {}) > 0 and 2 or 1
	end

	self.view.rootUComponent:TryChangePage("Empty", emptyState)
	self.view.listInviteUList:SetList(data)
	self.view.searchUWidget:SetActive(tabType == DungeonInviteCtrl.TabType.Friend and #(rawData or {}) > 0)
end

function DungeonInviteCtrl:refreshTabSelected()
	if not self.tabDatas then
		return
	end

	for index, data in ipairs(self.tabDatas) do
		if data.tabType == self.selectTab then
			self.view.listTabUList:SelectItem(index - 1, false)

			break
		end
	end

	self.view.listTabUList:RefreshList()
end

function DungeonInviteCtrl:getInviteData(tabType)
	if tabType == DungeonInviteCtrl.TabType.Channel then
		local result = {}
		local groupList = pg.game.chat:getFriendChatGroupList() or {}

		for _, group in ipairs(groupList) do
			if not group.markForRemove and tostring(group.master) == tostring(pg.me.uid) then
				self:addFriendChatGroupInviteData(result, group)
			end
		end

		for _, group in ipairs(groupList) do
			if not group.markForRemove and tostring(group.master) ~= tostring(pg.me.uid) then
				self:addFriendChatGroupInviteData(result, group)
			end
		end

		for _, channel in ipairs(pg.game.chat:getWorldChannelListData()) do
			local isWorldChannel = channel.type == pg.game.chat.channelType.World and pg.game.chat:isWorldChatGroupId(channel.channelId)

			if isWorldChannel then
				result[#result + 1] = {
					tindex = 0,
					channelType = channel.type,
					name = pg.game.chat:getWorldChatChannelName(channel.channelId, channel.groupBase),
					icon = AddressDataConst.DUNGEON_INVITE_CHANNEL_WORLD,
					channelId = channel.channelId,
					initTab = pg.game.chat.tabType.Public,
					initChannelId = channel.channelId,
					initGroupBase = channel.groupBase
				}
			end
		end

		return result
	elseif tabType == DungeonInviteCtrl.TabType.Recent then
		return self:getRecentInviteData()
	else
		return pg.game.chat:getFriendList()
	end
end

function DungeonInviteCtrl:getRecentInviteData()
	local result = {}

	for _, data in ipairs(self.recentPlaymates or EMPTY_TABLE) do
		local playerInfo = pg.game.chat:getPlayerInfo(data.playerId)

		if playerInfo and playerInfo.online and not PlatformFriendListService.isGameFriendUid(pg.game.chat, data.playerId) then
			result[#result + 1] = data
		end
	end

	return result
end

function DungeonInviteCtrl:addFriendChatGroupInviteData(result, group)
	result[#result + 1] = {
		tindex = 0,
		channelType = pg.game.chat.channelType.Group,
		name = pg.game.chat:getChatGroupDisplayName(group),
		icon = AddressDataConst.CHAT_GROUP_HEAD_ICONS[group.headIconKey],
		channelId = group.groupId,
		initTab = pg.game.chat.tabType.Chat,
		initChannelId = group.groupId
	}
end

function DungeonInviteCtrl:getChannelInviteKey(data)
	return data and (data.channelId or data.channelType)
end

function DungeonInviteCtrl:filterInviteData(data)
	if string.isNilOrEmpty(self.searchText) then
		return data
	end

	local searchText = string.lower(tostring(self.searchText))
	local result = {}

	for _, item in ipairs(data or EMPTY_TABLE) do
		if self:isInviteDataMatchSearch(item, searchText) then
			result[#result + 1] = item
		end
	end

	return result
end

function DungeonInviteCtrl:isInviteDataMatchSearch(data, searchText)
	if self.selectTab == DungeonInviteCtrl.TabType.Channel then
		return string.find(string.lower(tostring(data.name or "")), searchText, 1, true) ~= nil
	end

	local playerId = tostring(data.playerId or "")

	if string.find(string.lower(playerId), searchText, 1, true) ~= nil then
		return true
	end

	local playerInfo = pg.game.chat:getPlayerInfo(data.playerId)
	local playerName = playerInfo and playerInfo.playerName or ""

	if string.find(string.lower(playerName), searchText, 1, true) ~= nil then
		return true
	end

	local customInfo = pg.game.chat:getFriendCustomInfo(data.playerId)
	local remark = customInfo and customInfo.remark or ""

	return string.find(string.lower(remark), searchText, 1, true) ~= nil
end

function DungeonInviteCtrl:getRecentDungeonName(data)
	local dungeonSceneId = tonumber(data and data.dungeonSceneId)
	local dungeonConfig = dungeonSceneId and LevelData[dungeonSceneId]

	if dungeonConfig and dungeonConfig.name then
		return pg.getLocalizationText(dungeonConfig.name)
	end

	return ""
end

function DungeonInviteCtrl:requestRecentPlaymates()
	if self.isRequestingRecentPlaymates then
		return
	end

	self.isRequestingRecentPlaymates = true

	pg.me:serverMsg("RPC_CS_GetRecentDungeonPlaymates", function(result)
		self.isRequestingRecentPlaymates = false

		self:onRecentPlaymatesResult(result)
	end)
end

function DungeonInviteCtrl:onRecentPlaymatesResult(result)
	local playmates = {}

	if result and result.playmates then
		playmates = result.playmates
	elseif result and result[1] and result[1].uid then
		playmates = result
	elseif result and result[1] then
		playmates = result[1]
	end

	table.sort(playmates, function(a, b)
		return (a.teamTime or 0) > (b.teamTime or 0)
	end)

	self.recentPlaymates = {}

	local queryUids = {}

	for _, playmate in ipairs(playmates) do
		local uid = tostring(playmate.uid or "")

		if not string.isNilOrEmpty(uid) then
			queryUids[#queryUids + 1] = uid
			self.recentPlaymates[#self.recentPlaymates + 1] = {
				status = 1,
				playerId = uid,
				dungeonSceneId = playmate.dungeonSceneId,
				hardLv = playmate.hardLv,
				teamTime = playmate.teamTime
			}
		end
	end

	if #queryUids > 0 then
		pg.me:queryPlayerInfoList(queryUids, nil, true, nil, function()
			self.hasRecentPlaymatesData = true

			if self.selectTab == DungeonInviteCtrl.TabType.Recent then
				self:refreshUI(self.selectTab)
			end
		end)

		return
	end

	self.hasRecentPlaymatesData = true

	if self.selectTab == DungeonInviteCtrl.TabType.Recent then
		self:refreshUI(self.selectTab)
	end
end

function DungeonInviteCtrl:onDestroy()
	if self.pendingChannelInvite then
		self:finishChannelDungeonInvite(self.pendingChannelInvite)
	end

	UICtrl.onDestroy(self)
end

function DungeonInviteCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function DungeonInviteCtrl:onShow()
	return
end

function DungeonInviteCtrl:onHide()
	return
end

return DungeonInviteCtrl
