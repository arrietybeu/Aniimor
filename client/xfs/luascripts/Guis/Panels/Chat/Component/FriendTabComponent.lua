-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Chat\\Component\\FriendTabComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local CallbackHandler = require("Core.Common.CallbackHandler")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("FriendTabComponent")
local SettingSelectorTextData = require("Data.setting_selector_text_data")
local AddressDataConst = require("Const.AddressDataConst")
local FriendTabComponent = Class.LightClass("FriendTabComponent", UIComponent)
local ServiceUtils = require("Common.Utils.ServiceUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local FriendshipLevelData = require("Data.friendship_level_data")
local AvatarPresetData = require("Data.avatar_preset_data")
local ClientConst = require("Const.ClientConst")
local HotkeyConst = require("Const.HotkeyConst")
local RedDotConst = require("Const.RedDotConst")
local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local SysConfigData = require("Data.sys_config_data")
local FriendChannelType = {
	Apply = 2,
	Friend = 1,
	AddFriend = 0,
	Group = 3
}
local FriendChannelListData = {
	{
		tabName = "CHAT_TAB_FRIEND_LIST",
		type = 10,
		channelType = FriendChannelType.Friend
	},
	{
		tabName = "CHAT_TAB_GROUP",
		type = 13,
		channelType = FriendChannelType.Group
	},
	{
		tabName = "CHAT_TAB_ACCEPT_FRIEND",
		type = 11,
		channelType = FriendChannelType.Apply
	},
	{
		tabName = "CHAT_TAB_ADD_FRIEND",
		type = 14,
		channelType = FriendChannelType.AddFriend
	}
}

FriendTabComponent.messages = {
	[MessageName.UPDATE_FRIEND_CUSTOM_INFO] = {
		"refreshFriendList"
	},
	[MessageName.DISCORD_FRIENDS_REFRESH] = {
		"refreshDiscordFriends"
	},
	[MessageName.DISCORD_FRIEND_PLAYER_INFOS_REFRESH] = {
		"refreshDiscordFriendsPlayerInfo"
	}
}

function FriendTabComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.searchInputField = objectReference:GetRefValue("searchInputField")
	self.btnSearchUButton = objectReference:GetRefValue("btnSearchUButton")
	self.listRecommendUList = objectReference:GetRefValue("listRecommendUList")
	self.changeUButton = objectReference:GetRefValue("changeUButton")
	self.listFriendUList = objectReference:GetRefValue("listFriendUList")
	self.listApplyUList = objectReference:GetRefValue("listApplyUList")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.friendApplyListUComponent = objectReference:GetRefValue("friendApplyListUComponent")
	self.requestEmptyUButton = objectReference:GetRefValue("requestEmptyUButton")
	self.addFriendUComponent = objectReference:GetRefValue("addFriendUComponent")
	self.listFriendChannelUList = self.view.listFriendChannelUList
	self.btnRefuseAllUButton = objectReference:GetRefValue("btnRefuseAllUButton")
	self.btnAcceptAllUButton = objectReference:GetRefValue("btnAcceptAllUButton")
	self.friendListUComponent = objectReference:GetRefValue("friendListUComponent")
	self.btnGoAddUButton = objectReference:GetRefValue("btnGoAddUButton")
	self.btnSearchDeleteUButton = objectReference:GetRefValue("btnSearchDeleteUButton")
	self.listSearchUList = objectReference:GetRefValue("listSearchUList")
	self.btnGroupingUButton = objectReference:GetRefValue("btnGroupingUButton")
	self.btnGroupTextUSDFText = self.btnGroupingUButton.transform:GetComponent("ObjectReference"):GetRefValue("txtNameUText")
	self.groupChatListUList = objectReference:GetRefValue("groupChatListUList")
	self.groupListUComponent = objectReference:GetRefValue("groupListUComponent")
	self.btnGroupChatUButton = objectReference:GetRefValue("btnGroupChatUButton")
	self.btnGroupChatTextUSDFText = self.btnGroupChatUButton.transform:GetComponent("ObjectReference"):GetRefValue("txtNameUText")
	self.textTitleGroupNumUSDFText = objectReference:GetRefValue("textTitleGroupNumUSDFText")
	self.btnGroupChatEmptyUButton = objectReference:GetRefValue("btnGroupChatEmptyUButton")
	self.btnGroupChatEmptyTextUSDFText = self.btnGroupChatEmptyUButton.transform:GetComponent("ObjectReference"):GetRefValue("txtNameUText")
	self.txtGroupEmptyUSDFText = objectReference:GetRefValue("txtGroupEmptyUSDFText")
	self.placeHolderUSDFText = objectReference:GetRefValue("placeHolderUSDFText")
	self.textTitleGroupUSDFText = objectReference:GetRefValue("textTitleGroupUSDFText")
	self.addFriendTabUSDFText = objectReference:GetRefValue("addFriendTabUSDFText")
	self.searchListUTMPInputField = objectReference:GetRefValue("searchListUTMPInputField")
	self.inputKeyContent = objectReference:GetRefValue("inputKeyContent")
	self.textTitleUSDFText = objectReference:GetRefValue("textTitleUSDFText")
end

function FriendTabComponent:initView()
	self.rootUComponent:TryChangePage("State", 1)

	self.searchInputField.text = ""

	local changeObjectRef = self.changeUButton.transform:GetComponent("ObjectReference")
	local changeTextUText = changeObjectRef:GetRefValue("txtNameUText")

	ClientTextUtils.setText(changeTextUText, pg.getGameString("CHAT_RECOMMEND_CHANGE_BATCH"))
	ClientTextUtils.setText(self.placeHolderUSDFText, pg.getGameString("FRIEND_SEARCH_DESC"))
	ClientTextUtils.setText(self.textTitleGroupUSDFText, pg.getGameString("CHAT_GROUP"))
	ClientTextUtils.setText(self.btnGroupChatTextUSDFText, pg.getGameString("CHATGROUP_CREAT"))
	ClientTextUtils.setText(self.btnGroupChatEmptyTextUSDFText, pg.getGameString("CHATGROUP_CREAT"))
	ClientTextUtils.setText(self.addFriendTabUSDFText, pg.getGameString("CHAT_TAB_ADD_FRIEND"))

	local refuseAllObjectRef = self.btnRefuseAllUButton.transform:GetComponent("ObjectReference")
	local acceptAllObjectRef = self.btnAcceptAllUButton.transform:GetComponent("ObjectReference")
	local refuseAllTextUText = refuseAllObjectRef:GetRefValue("txtNameUText")
	local acceptAllTextUText = acceptAllObjectRef:GetRefValue("txtNameUText")

	ClientTextUtils.setText(refuseAllTextUText, pg.getGameString("CHAT_FRIEND_REFUSE_ALL"))
	ClientTextUtils.setText(acceptAllTextUText, pg.getGameString("CHAT_FRIEND_ACCEPT_ALL"))
	self:addListener()
	self:refreshScoredRecommendList()

	if pg.game.chat:getFriendRequestCount() > 0 then
		for _, channel in pairs(FriendChannelListData) do
			channel.selected = channel.channelType == FriendChannelType.Apply
		end
	else
		local cachedType = pg.global.prefsCacheUtils:getInt(pg.me.uid .. ClientConst.PrefKey.FriendChannelType, FriendChannelType.Friend)

		if cachedType == FriendChannelType.Apply or cachedType == FriendChannelType.AddFriend then
			cachedType = FriendChannelType.Friend
		end

		for _, channel in pairs(FriendChannelListData) do
			channel.selected = channel.channelType == cachedType
		end
	end

	self.listFriendChannelUList:SetList(FriendChannelListData)

	self.curPanelType = self.listFriendChannelUList.selectedItem.channelType

	local res, friendApplyButton = self.listFriendChannelUList:TryGetChildAt(2)

	if res then
		pg.global.setPreViewRedDot(RedDotConst.RedDotPath.CHAT_TAB_FRIEND, friendApplyButton, function()
			return self.model:redDot_GetFriendRequestState()
		end, function()
			return pg.game.chat:getFriendRequestCount()
		end)
	end

	local _h = FriendTabComponent._platformHooks

	if _h and _h.initView then
		_h.initView(self)
	end

	local _d = FriendTabComponent._discordHooks

	if _d and _d.initView then
		_d.initView(self)
	end
end

function FriendTabComponent:onDestroy()
	local _h = FriendTabComponent._platformHooks

	if _h and _h.onDestroy then
		_h.onDestroy(self)
	end

	UIComponent.onDestroy(self)
end

function FriendTabComponent:openAddFriendPanel()
	self.searchInputField.text = ""
	self.curPanelType = FriendChannelType.AddFriend

	self.listFriendChannelUList:SelectItem(3)

	local result, addFriendButton = self.listFriendChannelUList:TryGetChildAt(3)

	if result then
		pg.global.navMgr:FocusItem(addFriendButton, CS.XGUI.Navigation.FocusEntryMode.Restore)
	end
end

function FriendTabComponent:openFriendListPanel()
	self.searchInputField.text = ""
	self.curPanelType = FriendChannelType.Friend

	self.listFriendChannelUList:SelectItem(0)
end

function FriendTabComponent:addListener()
	function self.btnRefuseAllUButton.luaClick()
		pg.me:refuseAllFriends()
		pg.global.refreshRedDotState(RedDotConst.RedDotPath.CHAT_TAB_FRIEND)
	end

	function self.btnAcceptAllUButton.luaClick()
		pg.me:acceptAllFriends()
	end

	LuaUIUtils.bindInputFieldGamepad(self.searchInputField, self.inputKeyContent, self.btnSearchDeleteUButton)

	function self.btnGoAddUButton.luaClick()
		self:openAddFriendPanel()
	end

	function self.searchInputField.luaValueChanged(text)
		self.searchText = text

		self.btnSearchDeleteUButton:SetActive(not string.isNilOrEmpty(text))

		if self.curPanelType == FriendChannelType.Friend then
			self:doSearch()
		elseif self.curPanelType == FriendChannelType.AddFriend then
			self:resetAddFriendSearchState()
		end
	end

	function self.searchInputField.luaEndEdit(text)
		self.searchText = text

		self:doSearch()
	end

	function self.btnSearchUButton.luaClick()
		self:doSearch()
	end

	function self.requestEmptyUButton.luaClick()
		self:openAddFriendPanel()
	end

	function self.listRecommendUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local listTagUList = objectReference:GetRefValue("listTagUList")
		local addFriendUButton = objectReference:GetRefValue("addFriendUButton")
		local textNameUSDFText = objectReference:GetRefValue("textNameUSDFText")
		local avatarUButton = objectReference:GetRefValue("avatarUButton")
		local textStateUSDFText = objectReference:GetRefValue("textStateUSDFText")
		local textSignatureUSDFText = objectReference:GetRefValue("textSignatureUSDFText")
		local btnChatUButton = objectReference:GetRefValue("btnChatUButton")

		function listTagUList.luaRenderItem(tagBtn, tagIndex, tagData)
			local tagObjectReference = tagBtn:GetComponent("ObjectReference")
			local txtNameUSDFText = tagObjectReference:GetRefValue("txtNameUSDFText")

			ClientTextUtils.setText(txtNameUSDFText, pg.getGameString(tagData.label))
			tagBtn:TryChangePage("BgColour", tagData.tagQuality)
		end

		local tags = {}

		if pg.me.teamUidScores and pg.me.teamUidScores[data.playerId] and pg.me.teamUidScores[data.playerId] > 0 then
			table.insert(tags, {
				tagQuality = 0,
				label = "RECOMMEND_TEAM_TAG"
			})
		end

		if pg.me.parkingUidScores and pg.me.parkingUidScores[data.playerId] and pg.me.parkingUidScores[data.playerId] > 0 then
			table.insert(tags, {
				tagQuality = 0,
				label = "RECOMMEND_PARKING_TAG"
			})
		end

		table.insert(tags, {
			tagQuality = 1,
			label = "RECOMMEND_LEVEL_TAG"
		})
		listTagUList:SetList(tags)
		button:TryChangePage("Search", self.isSearch and 1 or 0)

		local addFriendState = 1

		if pg.game.chat:checkFriendList(data.playerId) or pg.me.uid == data.playerId then
			addFriendState = 2
		elseif pg.game.chat:checkAddFriendCD(data.playerId) == true then
			addFriendState = 0
		end

		button:TryChangePage("AddFriend", addFriendState)

		local playerInfo = pg.game.chat:getPlayerInfo(data.playerId)

		if playerInfo then
			LuaUIUtils.renderPlayerAvatarButton(avatarUButton, {
				canOpenInfoPlayerCard = true,
				showOnlineState = true,
				playerId = data.playerId,
				playerInfo = playerInfo,
				avatarType = LuaUIUtils.PLAYER_AVATAR_TYPE.CHAT,
				playSparkAnimation = self.ctrl.sparkAnimationPlayerUid == data.playerId
			})

			local presetData = AvatarPresetData[playerInfo.avatarPresetKey] or {}
			local templateId = presetData.templateId or 0

			if templateId == 3 then
				button:TryChangePage("Gender", 1)
			elseif templateId == 4 then
				button:TryChangePage("Gender", 0)
			else
				button:TryChangePage("Gender", 2)
			end

			local displayName = LuaUIUtils.getPlayerDisplayName(data.playerId, playerInfo.playerName, true)
			local _h = FriendTabComponent._platformHooks

			displayName = _h and _h.renderRecommendPlayerName and _h.renderRecommendPlayerName(self, button, index, data, playerInfo, displayName) or displayName

			ClientTextUtils.setText(textNameUSDFText, displayName)

			if _h and _h.renderRecommendPlayerOnlineID then
				_h.renderRecommendPlayerOnlineID(self, objectReference, textNameUSDFText, button, index, data, playerInfo)
			end

			local lastLogoutTime = LuaUIUtils.getLastTimeStr(playerInfo.lastLogoutTime)

			ClientTextUtils.setText(textStateUSDFText, playerInfo.online and pg.getGameString("ONLINE") or lastLogoutTime)

			local playerSignText = string.isNilOrEmpty(playerInfo.showSignature) and pg.getGameString("NO_PLAYER_SIGNATURE") or playerInfo.showSignature

			playerSignText = _h and _h.setPlayerBaseInfoSign and _h.setPlayerBaseInfoSign(playerInfo, playerSignText) or playerSignText

			ClientTextUtils.setText(textSignatureUSDFText, playerSignText)
		end

		function addFriendUButton.luaClick()
			pg.game.chat:applyFriend(data.playerId, self.isSearch and pg.game.chat.AddFriendSource.Search or pg.game.chat.AddFriendSource.SystemRecommend)
		end

		function btnChatUButton.luaClick()
			pg.global.ui.chat:createNewChat(nil, data.playerId)
		end
	end

	function self.changeUButton.luaClick()
		if self.recommendPlayerTime and self.recommendPlayerTime > 0 and self.recommendPlayerTime + Const.Friend.RECOMMEND_PLAYER_CD > Time.realSecondCache then
			pg.global.showBubbleMessageRaw(pg.getGameString("RECOMMEND_PLAYER_CD"), 3)

			return
		end

		self.recommendPlayerTime = Time.realSecondCache

		if self.recommendPlayerBatchOffset + 1 >= self.recommendPlayerBatchCount then
			self.recommendPlayerBatchOffset = 0
		else
			self.recommendPlayerBatchOffset = self.recommendPlayerBatchOffset + 1
		end

		self:refreshRecommendListWithOffset(self.recommendPlayerBatchOffset)
	end

	function self.listFriendUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local friendGroupExpandUButton = objectReference:GetRefValue("friendGroupExpandUButton")
		local friendGroupListUList = objectReference:GetRefValue("friendGroupListUList")
		local friendGroupTitleUSDFText = objectReference:GetRefValue("friendGroupTitleUSDFText")
		local txtCountUSDFText = objectReference:GetRefValue("txtCountUSDFText")
		local settingUButton = objectReference:GetRefValue("settingUButton")
		local emptyUSDFText = objectReference:GetRefValue("emptyUSDFText")

		button:TryChangePage("expand", data.expand and 1 or 0)

		function friendGroupExpandUButton.luaClick()
			data.expand = not data.expand

			pg.global.prefsCacheUtils:setBool(pg.me.uid .. ClientConst.PrefKey.FriendGroupListExpand .. data.id, data.expand)
			button:TryChangePage("expand", data.expand and 1 or 0)
		end

		function friendGroupListUList.luaRenderItem(button1, index1, data1)
			button1:TryChangePage("Blacklist", data.isBlackList and 1 or 0)
			self:renderFriendItem(button1, index1, data1)
		end

		ClientTextUtils.setText(friendGroupTitleUSDFText, pg.getGameString(data.groupLabel))
		button:TryChangePage("Empty", #data.groupFriendData == 0 and 1 or 0)
		button:TryChangePage("IsFriendList", data.id == Const.CHAT.CHAT_DEFAULT_LIST_GROUP_ID and #pg.game.chat:getFriendList() == 0 and 0 or 1)
		friendGroupListUList:SetList(data.groupFriendData)
		ClientTextUtils.setText(txtCountUSDFText, pg.getFormatText(pg.getGameString("COUNT_OF_TOTAL"), data.subCount, #data.groupFriendData))

		if data.id == Const.CHAT.CHAT_DEFAULT_LIST_GROUP_ID or data.id == Const.CHAT.CHAT_BLACK_LIST_GROUP_ID then
			settingUButton:SetActive(false)
			ClientTextUtils.setText(emptyUSDFText, pg.getGameString("FRIEND_LIST_EMPTY"))
		else
			settingUButton:SetActive(true)

			function settingUButton.luaRenderTooltip(btn, comp)
				local objRef = comp.transform:GetComponent("ObjectReference")
				local listOtherUList = objRef:GetRefValue("listOtherUList")

				function listOtherUList.luaRenderItem(settingBtn, settingIndex, settingData)
					local settingObjRef = settingBtn:GetComponent("ObjectReference")
					local txtNameUSDFText = settingObjRef:GetRefValue("txtNameUSDFText")

					ClientTextUtils.setText(txtNameUSDFText, settingData.funcLabel)

					function settingBtn.luaClick()
						settingData.func()
						settingUButton:CloseTooltip()
					end
				end

				local settingDatas = {
					{
						tIndex = 2,
						funcLabel = pg.getGameString("EDIT_FRIEND_GROUP"),
						func = function()
							pg.global.ui:open(UIConst.UI_ID_FRIEND_SETUP, {
								setupType = pg.global.ui.friendSetup.model.FriendSetupType.EditGroup,
								groupId = data.id
							})
						end
					},
					{
						tIndex = 2,
						funcLabel = pg.getGameString("DELETE_FRIEND_GROUP"),
						func = function()
							pg.global.showConfirmMsgRaw(pg.getGameString("DELETE_FRIEND_GROUP"), pg.getGameString("DELETE_FRIEND_GROUP_DESC"), function()
								pg.me:deleteFriendGroup(data.id)
							end)
						end
					}
				}

				listOtherUList:SetList(settingDatas)
			end
		end
	end

	function self.listApplyUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local avatarUButton = objectReference:GetRefValue("avatarUButton")
		local textNameUSDFText = objectReference:GetRefValue("textNameUSDFText")
		local textSignatureUSDFText = objectReference:GetRefValue("textSignatureUSDFText")
		local btnRefuseUButton = objectReference:GetRefValue("btnRefuseUButton")
		local btnConsentUButton = objectReference:GetRefValue("btnConsentUButton")
		local playerInfo = pg.game.chat:getPlayerInfo(data.playerId)

		LuaUIUtils.renderPlayerAvatarButton(avatarUButton, {
			canOpenInfoPlayerCard = true,
			showOnlineState = true,
			hideLevel = true,
			playerId = data.playerId,
			playerInfo = playerInfo,
			avatarType = LuaUIUtils.PLAYER_AVATAR_TYPE.CHAT,
			playSparkAnimation = self.ctrl.sparkAnimationPlayerUid == data.playerId
		})

		local displayName = LuaUIUtils.getPlayerDisplayName(data.playerId, playerInfo.playerName, true)
		local _h = FriendTabComponent._platformHooks

		displayName = _h and _h.renderApplyPlayerName and _h.renderApplyPlayerName(self, button, index, data, playerInfo, displayName) or displayName

		ClientTextUtils.setText(textNameUSDFText, displayName)

		local playerSignText = data.sourceText

		playerSignText = _h and _h.setPlayerBaseInfoSign and _h.setPlayerBaseInfoSign(playerInfo, playerSignText) or playerSignText

		ClientTextUtils.setText(textSignatureUSDFText, playerSignText)

		local presetData = pg.game.avatar:getAvatarPresetData(playerInfo.avatarPresetKey) or {}
		local templateId = presetData.templateId or 0

		if templateId == 3 then
			button:TryChangePage("Gender", 1)
		elseif templateId == 4 then
			button:TryChangePage("Gender", 0)
		else
			button:TryChangePage("Gender", 2)
		end

		function btnRefuseUButton.luaClick()
			pg.me:refuseFriend(data.playerId, "")
			pg.global.refreshRedDotState(RedDotConst.RedDotPath.CHAT_TAB_FRIEND)
			pg.global.ui.tips:removeTeamInviteNoticeByPlayerId(data.playerId)
		end

		function btnConsentUButton.luaClick()
			pg.me:acceptFriend(data.playerId)
			pg.global.refreshRedDotState(RedDotConst.RedDotPath.CHAT_TAB_FRIEND)
			pg.global.ui.tips:removeTeamInviteNoticeByPlayerId(data.playerId)
		end
	end

	function self.listFriendChannelUList.luaRenderItem(button, index, data)
		button:TryChangePage("Type", data.type)

		local objectReference = button:GetComponent("ObjectReference")
		local labelUSDFText = objectReference:GetRefValue("labelUSDFText")

		ClientTextUtils.setText(labelUSDFText, pg.getGameString(data.tabName))
	end

	function self.listFriendChannelUList.luaSelectedChanged(ulist, isSelected)
		if not isSelected then
			return
		end

		self.rootUComponent:TryChangePage("State", ulist.selectedItem.channelType)

		self.searchInputField.text = ""

		local tabItem = ulist.selectedItem

		self.curPanelType = tabItem.channelType

		ClientTextUtils.setText(self.textTitleUSDFText, pg.getGameString(tabItem.tabName))
		self:refreshFriendPanel(ulist.selectedItem.channelType)
		self:refreshFriendTillableState()

		if self.curPanelType ~= FriendChannelType.AddFriend then
			pg.global.prefsCacheUtils:setInt(pg.me.uid .. ClientConst.PrefKey.FriendChannelType, self.curPanelType)
		end
	end

	function self.listSearchUList.luaRenderItem(button, index, data)
		button:TryChangePage("Blacklist", data.isBlackList and 1 or 0)
		self:renderFriendItem(button, index, data)
	end

	function self.btnGroupingUButton.luaClick()
		if #pg.game.chat:getFriendGroupList() >= Const.CHAT.CHAT_GROUP_MAX_NUMBER + 2 + self:getPlatformGroupListCount() then
			pg.global.showBubbleMessageRaw(pg.getGameString("GROUP_NUMBER_OVER_LIMIT"))

			return
		end

		pg.global.ui:open(UIConst.UI_ID_FRIEND_SETUP, {
			setupType = pg.global.ui.friendSetup.model.FriendSetupType.CreateGroup
		})
	end

	function self.groupChatListUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
		local btnSettingUButton = objectReference:GetRefValue("btnSettingUButton")
		local btnDeleteUButton = objectReference:GetRefValue("btnDeleteUButton")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local txtLeaveUSDFText = objectReference:GetRefValue("txtLeaveUSDFText")
		local textInformationUSDFText = objectReference:GetRefValue("textInformationUSDFText")
		local groupName = data.chatGroupName
		local _h = FriendTabComponent._platformHooks

		groupName = _h and _h.renderChatGroupName and _h.renderChatGroupName(data, groupName) or groupName

		ClientTextUtils.setText(txtNameUSDFText, groupName)

		local messageInfo = pg.game.chat:getGroupChannelLastMessageOrSystemNotice(data.groupId)
		local lastMessageText = self:getGroupChatLastMessageText(messageInfo)

		lastMessageText = ClientTextUtils.removeRichText(lastMessageText)

		ClientTextUtils.setText(textInformationUSDFText, lastMessageText)

		if data.markForRemove then
			if data.notExist then
				ClientTextUtils.setText(txtLeaveUSDFText, pg.getFormatText(pg.getGameString("CHAT_GROUP_DISBANDED"), ""))
			else
				ClientTextUtils.setText(txtLeaveUSDFText, pg.getFormatText(pg.getGameString("CHAT_GROUP_REMOVED"), "", ""))
			end

			button:TryChangePage("GroupState", 1)

			function btnDeleteUButton.luaClick()
				pg.game.chat:removeChatGroup(data.groupId)
			end

			function button.luaClick()
				pg.game.chat:removeChatGroup(data.groupId)
			end
		else
			button:TryChangePage("GroupState", 0)
			ClientTextUtils.setText(txtNumUSDFText, pg.getFormatText(pg.getGameString("COUNT_OF_TOTAL"), #data.uids, Const.CHAT.CHAT_GROUP_MAX_MEMBER_COUNT))

			function btnSettingUButton.luaRenderTooltip(btn, popup)
				local extensionFuncList = self.ctrl.model:getExtensionFunctionList(pg.game.chat.channelType.Group, data.groupId, true)
				local popupObjRef = popup.transform:GetComponent("ObjectReference")
				local listOtherUList = popupObjRef:GetRefValue("listOtherUList")

				function listOtherUList.luaRenderItem(popupBtn, popupIndex, popupData)
					self:renderOtherSettingItem(popupBtn, popupIndex, popupData, data.groupId, btnSettingUButton)
				end

				listOtherUList:SetList(extensionFuncList)
			end

			function button.luaClick()
				pg.global.ui.chat:createNewGroupChat(data.groupId)
			end
		end

		iconUImage.url = AddressDataConst.CHAT_GROUP_HEAD_ICONS[data.headIconKey]
	end

	function self.btnGroupChatUButton.luaClick()
		if #pg.game.chat:getFriendChatGroupList() >= Const.CHAT.CHAT_CHAT_GROUP_MAX_NUMBER then
			pg.global.showBubbleMessageRaw(pg.getGameString("GROUP_NUMBER_OVER_LIMIT"))

			return
		end

		pg.global.ui:open(UIConst.UI_ID_FRIEND_SETUP, {
			setupType = pg.global.ui.friendSetup.model.FriendSetupType.CreateChatGroup
		})
	end

	function self.btnGroupChatEmptyUButton.luaClick()
		if #pg.game.chat:getFriendChatGroupList() >= Const.CHAT.CHAT_CHAT_GROUP_MAX_NUMBER then
			pg.global.showBubbleMessageRaw(pg.getGameString("GROUP_NUMBER_OVER_LIMIT"))

			return
		end

		pg.global.ui:open(UIConst.UI_ID_FRIEND_SETUP, {
			setupType = pg.global.ui.friendSetup.model.FriendSetupType.CreateChatGroup
		})
	end

	self:addSearchListListener()

	local _h = FriendTabComponent._platformHooks

	if _h and _h.addListener then
		_h.addListener(self)
	end

	local _d = FriendTabComponent._discordHooks

	if _d and _d.addListener then
		_d.addListener(self)
	end
end

function FriendTabComponent:addSearchListListener()
	local objectReference = self.searchListUTMPInputField:GetComponent("ObjectReference")
	local btnSearchUButton = objectReference:GetRefValue("btnSearchUButton")
	local btnDeleteUButton = objectReference:GetRefValue("btnDeleteUButton")
	local placeHolderUSDFText = objectReference:GetRefValue("placeHolderUSDFText")
	local keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")

	LuaUIUtils.bindInputFieldGamepad(self.searchListUTMPInputField, keyHotKeyContent, btnDeleteUButton)

	function self.searchListUTMPInputField.luaValueChanged(text)
		self.searchText = text

		btnDeleteUButton:SetActive(not string.isNilOrEmpty(text))

		if self.curPanelType == FriendChannelType.Friend then
			self:doSearch()
		end
	end

	function self.searchListUTMPInputField.luaEndEdit(text)
		self.searchText = text

		self:doSearch()
	end

	function btnSearchUButton.luaClick()
		self:doSearch()
	end

	ClientTextUtils.setText(placeHolderUSDFText, pg.getGameString("FRIEND_SEARCH_DESC"))
end

function FriendTabComponent:resetAddFriendSearchState()
	local needRefreshRecommend = self.isSearch == true

	self.isSearch = false

	self.changeUButton:SetActive(true)
	self.addFriendUComponent:TryChangePage("Search", 0)

	if needRefreshRecommend then
		self:refreshRecommendListWithOffset(self.recommendPlayerBatchOffset)
	end
end

function FriendTabComponent:renderOtherSettingItem(button, index, data, groupId, btnSettingUButton)
	if data.tIndex == 0 then
		local objectReference = button:GetComponent("ObjectReference")
		local textTitleUSDFText = objectReference:GetRefValue("textTitleUSDFText")
		local button1UButton = objectReference:GetRefValue("button1UButton")
		local button2UButton = objectReference:GetRefValue("button2UButton")
		local btnName1USDFText = objectReference:GetRefValue("btnName1USDFText")
		local btnName2USDFText = objectReference:GetRefValue("btnName2USDFText")

		ClientTextUtils.setText(textTitleUSDFText, pg.getLocalizationText(data.label))
		ClientTextUtils.setText(btnName1USDFText, pg.getLocalizationText(SettingSelectorTextData[data.widgetTxt[1]].name))
		ClientTextUtils.setText(btnName2USDFText, pg.getLocalizationText(SettingSelectorTextData[data.widgetTxt[2]].name))

		if data.checkFunc and self.ctrl.model[data.checkFunc] then
			if self.ctrl.model[data.checkFunc](self.ctrl.model, groupId, data.settingType) then
				button1UButton.isSelected = false
				button2UButton.isSelected = true
			else
				button1UButton.isSelected = true
				button2UButton.isSelected = false
			end
		end

		if data.func and self.ctrl.model[data.func] then
			function button1UButton.luaClick()
				self.ctrl.model[data.func](self.ctrl.model, groupId, false, data.settingType)

				button2UButton.isSelected = false
			end

			function button2UButton.luaClick()
				self.ctrl.model[data.func](self.ctrl.model, groupId, true, data.settingType)

				button1UButton.isSelected = false
			end
		end
	elseif data.tIndex == 2 or data.tIndex == 3 then
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.label))

		if data.func and self.ctrl.model[data.func] then
			function button.luaClick()
				self.ctrl.model[data.func](self.ctrl.model, groupId)
				btnSettingUButton:CloseTooltip()
			end
		end
	end
end

function FriendTabComponent:getGroupChatLastMessageText(messageInfo)
	if messageInfo == nil then
		return ""
	end

	if messageInfo.subType == pg.game.chat.subMessageType.Text or messageInfo.subType == pg.game.chat.subMessageType.Audio or messageInfo.subType == pg.game.chat.subMessageType.FriendCard or messageInfo.subType == pg.game.chat.subMessageType.Picture then
		if messageInfo.extraInfo then
			return pg.game.chat:getTextContentFromExtraInfo(messageInfo.extraInfo) or messageInfo.textContent or ""
		end

		return messageInfo.textContent or ""
	elseif messageInfo.subType == pg.game.chat.subMessageType.Emoji then
		return pg.getGameString("CHAT_BUBBLE_EMOJI")
	elseif messageInfo.subType == pg.game.chat.subMessageType.DungeonInvite then
		return pg.getGameString("TEAM_INVITE")
	elseif messageInfo.subType == pg.game.chat.subMessageType.PhotographyStudioInvite then
		return pg.getGameString("PHOTO_STUDIO_CHAT_INVITE_MESSAGE")
	end

	return messageInfo.textContent or ""
end

function FriendTabComponent:renderFriendItem(button, index, data)
	local _h = FriendTabComponent._platformHooks

	if _h and _h.beforeRenderFriendItem then
		_h.beforeRenderFriendItem(data)
	end

	local _d = FriendTabComponent._discordHooks

	if _d and _d.beforeRenderFriendItem then
		_d.beforeRenderFriendItem(data)
	end

	local objectReference = button:GetComponent("ObjectReference")
	local playerInfo = pg.game.chat:getPlayerInfo(data.playerId)

	self:renderFriendItemContent(button, index, data, playerInfo, objectReference)
	self:bindFriendItemEvents(button, data, playerInfo, objectReference)
end

function FriendTabComponent:renderFriendItemContent(button, index, data, playerInfo, objectReference)
	self:renderFriendItemIdentity(button, index, data, playerInfo, objectReference)
	self:renderFriendItemState(button, data, playerInfo, objectReference)
end

function FriendTabComponent:renderFriendItemIdentity(button, index, data, playerInfo, objectReference)
	local avatarUButton = objectReference:GetRefValue("avatarUButton")
	local nameUSDFText = objectReference:GetRefValue("nameUSDFText")
	local txtNameChangeCoverUSDFText = objectReference:GetRefValue("txtNameChangeCoverUSDFText")
	local txtNameChangeUSDFText = objectReference:GetRefValue("txtNameChangeUSDFText")
	local _h = FriendTabComponent._platformHooks
	local _d = FriendTabComponent._discordHooks

	LuaUIUtils.renderPlayerAvatarButton(avatarUButton, {
		canOpenInfoPlayerCard = true,
		showOnlineState = true,
		hideLevel = true,
		playerId = data.playerId,
		playerInfo = playerInfo,
		avatarType = LuaUIUtils.PLAYER_AVATAR_TYPE.CHAT,
		playSparkAnimation = self.ctrl.sparkAnimationPlayerUid == data.playerId
	})

	local playerName = LuaUIUtils.getPlayerDisplayName(data.playerId, playerInfo.playerName)

	playerName = _h and _h.renderFriendItemName and _h.renderFriendItemName(self, button, index, data, playerInfo, playerName) or playerName
	playerName = _d and _d.renderFriendItemName and _d.renderFriendItemName(self, button, index, data, playerInfo, playerName) or playerName

	ClientTextUtils.setText(nameUSDFText, playerName)
	ClientTextUtils.setText(txtNameChangeCoverUSDFText, playerName)
	ClientTextUtils.setText(txtNameChangeUSDFText, playerName)

	local presetData = pg.game.avatar:getAvatarPresetData(playerInfo.avatarPresetKey) or {}
	local templateId = presetData.templateId or 0

	if templateId == 3 then
		button:TryChangePage("Gender", 1)
	elseif templateId == 4 then
		button:TryChangePage("Gender", 0)
	else
		button:TryChangePage("Gender", 2)
	end

	local hideGender = _d and _d.shouldHideFriendItemGender and _d.shouldHideFriendItemGender(data)

	if hideGender then
		button:TryChangePage("Gender", 2)
	end
end

function FriendTabComponent:renderFriendItemState(button, data, playerInfo, objectReference)
	local onlineStateUSDFText = objectReference:GetRefValue("onlineStateUSDFText")
	local signatureUSDFText = objectReference:GetRefValue("signatureUSDFText")
	local intimateUImage = objectReference:GetRefValue("intimateUImage")
	local _h = FriendTabComponent._platformHooks
	local _d = FriendTabComponent._discordHooks
	local lastLogoutTime = LuaUIUtils.getLastTimeStr(playerInfo.lastLogoutTime)

	button:TryChangePage("OnlineState", playerInfo.online and 0 or 1)

	local onlineStateText = playerInfo.online and pg.getGameString("ONLINE") or lastLogoutTime

	ClientTextUtils.setText(onlineStateUSDFText, onlineStateText)

	local playerSignText = string.isNilOrEmpty(playerInfo.showSignature) and pg.getGameString("NO_PLAYER_SIGNATURE") or playerInfo.showSignature

	playerSignText = _h and _h.setPlayerBaseInfoSign and _h.setPlayerBaseInfoSign(playerInfo, playerSignText) or playerSignText

	ClientTextUtils.setText(signatureUSDFText, playerSignText)

	local friendShipLevel = pg.game.chat:getFriendship(data.playerId)
	local hasFriendship = friendShipLevel and FriendshipLevelData[friendShipLevel]

	if hasFriendship then
		local friendshipIcon = FriendshipLevelData[friendShipLevel].levelIcon

		intimateUImage:SetActive(true)

		intimateUImage.url = friendshipIcon
	else
		intimateUImage:SetActive(false)
	end

	button:TryChangePage("isChange", pg.game.chat.specialFriendUId == data.playerId and 1 or 0)
	button:TryChangePage("Home", playerInfo.homelandHasTillableFacility == true and 1 or 0)

	if _d and _d.afterRenderFriendItemContent then
		_d.afterRenderFriendItemContent(self, data, playerInfo, objectReference)
	end
end

function FriendTabComponent:bindFriendItemEvents(button, data, playerInfo, objectReference)
	local avatarUButton = objectReference:GetRefValue("avatarUButton")
	local teamUButton = objectReference:GetRefValue("teamUButton")
	local comeUButton = objectReference:GetRefValue("comeUButton")
	local blacklistUButton = objectReference:GetRefValue("blacklistUButton")
	local btnIntimateUButton = objectReference:GetRefValue("btnIntimateUButton")
	local loosenTheSoilUButton = objectReference:GetRefValue("loosenTheSoilUButton")
	local _h = FriendTabComponent._platformHooks
	local _d = FriendTabComponent._discordHooks

	function teamUButton.luaClick()
		pg.game.chat:teamHandle(data.playerId)
	end

	if _h and _h.afterAssignFriendTeamClick then
		_h.afterAssignFriendTeamClick(self, teamUButton, button, data, playerInfo)
	end

	function comeUButton.luaClick()
		pg.me:handleRemoteInviteSinglePlayer(data.playerId)
	end

	function loosenTheSoilUButton.luaClick()
		pg.game.chat:visitHome(data.playerId, playerInfo)
	end

	function button.luaClick()
		pg.global.ui.chat:createNewChat(nil, data.playerId)
	end

	local function openFriendIntimacy()
		pg.global.ui:open(UIConst.UI_ID_FRIEND_INTIMACY, {
			notBackToPlayerCard = true,
			playerInfo = playerInfo,
			friendshipValue = pg.game.chat:getFriendIntimacy(data.playerId)
		})

		return false
	end

	btnIntimateUButton.luaClick = openFriendIntimacy

	btnIntimateUButton:RemoveLuaGamepadHotkey()
	btnIntimateUButton:SetGamepadLongPress(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest, nil, 0, openFriendIntimacy)
	btnIntimateUButton:SetHotkeyActiveOnlyInCurrentItem(true)
	btnIntimateUButton:SetHotkeyConsoleBar("CONSOLE_INTIMACY", 0)

	if _h and _h.afterAssignFriendItemClick then
		_h.afterAssignFriendItemClick(self, button, data, playerInfo)
	end

	if _h and _h.afterAssignFriendAvatarClick then
		_h.afterAssignFriendAvatarClick(self, avatarUButton, playerInfo)
	end

	function blacklistUButton.luaClick()
		pg.me:delBlacklist(data.playerId)
	end

	if _h and _h.afterRenderFriendBlacklistButton then
		_h.afterRenderFriendBlacklistButton(self, blacklistUButton, button, data, playerInfo)
	end

	if _d and _d.bindFriendItemEvents then
		_d.bindFriendItemEvents(self, button, data, playerInfo, objectReference)
	end
end

function FriendTabComponent:refreshFriendPanel(type)
	type = type or self.curPanelType

	if type == FriendChannelType.Friend then
		self:refreshFriendList()
	elseif type == FriendChannelType.Apply then
		self:refreshFriendApplyList()
	elseif type == FriendChannelType.Group then
		self:refreshGroupChatList()
	end

	local _d = FriendTabComponent._discordHooks

	if _d and _d.refreshShareButton then
		_d.refreshShareButton(self)
	end
end

function FriendTabComponent:refreshFriendTillableState()
	if self.curPanelType ~= FriendChannelType.Friend then
		return
	end

	pg.me:queryFriendTillableStateList(self:_getFriendTillableStateUidList())
end

function FriendTabComponent:_getFriendTillableStateUidList()
	local uids = {}
	local uidSet = {}

	for _, group in ipairs(pg.game.chat:getFriendGroupList()) do
		for _, friend in ipairs(group.groupFriendData) do
			local uid = tostring(friend.mappedGameUid or friend.playerId or "")
			local canQuery = friend.hasMappedGameUid ~= false and not string.isNilOrEmpty(uid)

			if canQuery and not uidSet[uid] then
				uidSet[uid] = true
				uids[#uids + 1] = uid
			end
		end
	end

	return uids
end

function FriendTabComponent:refreshFriendList()
	local _h = FriendTabComponent._platformHooks
	local _d = FriendTabComponent._discordHooks
	local friendList = pg.game.chat:getFriendList() or {}

	if not string.isNilOrEmpty(self.searchText) then
		self.friendListUComponent:TryChangePage("Search", 1)

		local searchedFriends = {}

		local function innerSearch(friendId, isBlackList)
			local playerInfo = pg.game.chat:getPlayerInfo(friendId)
			local customInfo = pg.game.chat:getFriendCustomInfo(friendId)

			if playerInfo and friendId and (customInfo and not string.isNilOrEmpty(customInfo.remark) and string.find(customInfo.remark, self.searchText, 1, true) or string.find(friendId, self.searchText, 1, true) or string.find(playerInfo.playerName, self.searchText, 1, true)) then
				table.insert(searchedFriends, {
					playerId = friendId,
					playerInfo = playerInfo,
					isBlackList = isBlackList
				})
			end
		end

		local blackIds = pg.game.chat:getBlackList() or {}

		for _, friend in pairs(friendList) do
			innerSearch(friend.playerId, false)
		end

		for _, blackId in pairs(blackIds) do
			innerSearch(blackId, true)
		end

		self.friendListUComponent:TryChangePage("Empty", #searchedFriends > 0 and 0 or 1)
		self.listSearchUList:SetList(searchedFriends)

		return
	end

	self.friendListUComponent:TryChangePage("Search", 0)
	self.friendListUComponent:TryChangePage("Empty", #friendList > 0 and 0 or 1)

	local friendGroupList = pg.game.chat:getFriendGroupList()

	for _, group in ipairs(friendGroupList) do
		local groupFriendData = group.groupFriendData

		group.subCount = 0

		for _, friend in ipairs(groupFriendData) do
			friend.playerInfo = pg.game.chat:getPlayerInfo(friend.playerId)

			if friend.playerInfo and friend.playerInfo.online then
				group.subCount = group.subCount + 1
			end
		end

		table.sort(groupFriendData, function(a, b)
			local onlineA = a.playerInfo and a.playerInfo.online and 1 or 0
			local onlineB = b.playerInfo and b.playerInfo.online and 1 or 0

			if onlineA ~= onlineB then
				return onlineB < onlineA
			end

			local friendShipA = pg.game.chat:getFriendship(a.playerId) or 0
			local friendShipB = pg.game.chat:getFriendship(b.playerId) or 0

			if friendShipA ~= friendShipB then
				return friendShipB < friendShipA
			end

			return a.playerId < b.playerId
		end)
	end

	if _h and _h.injectFriendGroupList then
		_h.injectFriendGroupList(self, friendGroupList)
	end

	if _d and _d.injectFriendGroupList then
		_d.injectFriendGroupList(self, friendGroupList)
	end

	self.listFriendUList:SetList(friendGroupList)
	ClientTextUtils.setText(self.btnGroupTextUSDFText, pg.getFormatText(pg.getGameString("CREATE_FRIEND_GROUP"), #friendGroupList - 2 - self:getPlatformGroupListCount(), Const.CHAT.CHAT_GROUP_MAX_NUMBER))
end

function FriendTabComponent:refreshPlayerSpark()
	self.listRecommendUList:RefreshList()
	self.listFriendUList:RefreshList()
	self.listApplyUList:RefreshList()
	self.listSearchUList:RefreshList()
end

function FriendTabComponent:getPlatformGroupListCount()
	local _d = FriendTabComponent._discordHooks
	local discordGroupCount = _d and _d.getDiscordFriendGroupCount and _d.getDiscordFriendGroupCount() or 0

	return discordGroupCount
end

function FriendTabComponent:refreshGroupChatList()
	local friendChatGroupList = pg.game.chat:getFriendChatGroupList()
	local groupCount = 0

	for _, group in ipairs(friendChatGroupList) do
		if not group.markForRemove then
			groupCount = groupCount + 1
		end
	end

	ClientTextUtils.setText(self.textTitleGroupNumUSDFText, pg.getFormatText(pg.getGameString("COUNT_OF_TOTAL"), groupCount, Const.CHAT.CHAT_CHAT_GROUP_MAX_NUMBER))
	ClientTextUtils.setText(self.txtGroupEmptyUSDFText, pg.getGameString("CHAT_GROUP_EMPTY"))

	if #friendChatGroupList == 0 then
		self.groupListUComponent:TryChangePage("Empty", 1)

		return
	end

	self.groupListUComponent:TryChangePage("Empty", 0)
	self.groupChatListUList:SetList(friendChatGroupList)
end

function FriendTabComponent:refreshRecommendList(data)
	self.isSearch = true

	self.changeUButton:SetActive(string.isNilOrEmpty(self.searchText))

	if not string.isNilOrEmpty(self.searchText) then
		if data == nil or data[1] == nil or string.isNilOrEmpty(data[1].playerId) then
			self.addFriendUComponent:TryChangePage("Search", 2)
		else
			self.addFriendUComponent:TryChangePage("Search", 1)
		end
	else
		self.addFriendUComponent:TryChangePage("Search", 0)
	end

	self.listRecommendUList:SetList(data)
end

function FriendTabComponent:refreshRecommendListWithOffset(offset)
	local uids = {}
	local queryUids = {}

	if pg.me.recommendUids and #pg.me.recommendUids > 0 then
		for idx = offset * 10 + 1, offset * 10 + 10 do
			if pg.me.recommendUids[#pg.me.recommendUids][idx] then
				table.insert(uids, {
					playerId = pg.me.recommendUids[#pg.me.recommendUids][idx]
				})
				table.insert(queryUids, pg.me.recommendUids[#pg.me.recommendUids][idx])
			end
		end
	end

	pg.me:queryPlayerInfoList(queryUids, nil, true, nil, function()
		self.listRecommendUList:SetList(uids)
	end)
end

function FriendTabComponent:refreshFriendApplyList()
	local data = pg.game.chat.friendRequestList or {}

	self.friendApplyListUComponent:TryChangePage("Empty", #data > 0 and 0 or 1)
	self.listApplyUList:SetList(data)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.CHAT_TAB_FRIEND)
end

function FriendTabComponent:doSearch()
	if self.curPanelType == FriendChannelType.Friend then
		self:refreshFriendList()
	else
		if string.isNilOrEmpty(self.searchText) then
			return
		end

		if string.len(self.searchText) > SysConfigData.playerNameMaxLen and tonumber(self.searchText) then
			pg.me:queryPlayerInfo(self.searchText, pg.game.chat.queryPlayerInfoType.FriendAddSearch, true)
		else
			pg.me:queryPlayerInfoByName(self.searchText)
		end
	end
end

function FriendTabComponent:_doSearchCallback(result, resp)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("FriendTabComponent:_doSearchCallback called:", inspect(result), inspect(resp))
	end

	pg.me:queryPlayerInfo(resp.Uid, pg.game.chat.queryPlayerInfoType.FriendAddSearch, true)
end

function FriendTabComponent:getRecommendPlayerBatchCount()
	local offset = 1
	local res = 0

	if pg.me.recommendUids and #pg.me.recommendUids > 0 then
		while offset < #pg.me.recommendUids[#pg.me.recommendUids] do
			res = res + 1
			offset = offset + 10
		end
	end

	return res
end

function FriendTabComponent:refreshScoredRecommendList()
	if not pg.me.recommendUids or #pg.me.recommendUids <= 0 then
		return
	end

	if not string.isNilOrEmpty(self.searchText) then
		self.listRecommendUList:RefreshList()

		return
	end

	if not self.recommendPlayerBatchOffset then
		self.recommendPlayerBatchOffset = 0
	end

	self.recommendPlayerBatchCount = self:getRecommendPlayerBatchCount()

	self.changeUButton:SetActive(true)
	self:refreshRecommendListWithOffset(self.recommendPlayerBatchOffset)
end

return FriendTabComponent
