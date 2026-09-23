-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FriendSetup\\FriendSetupCtrl.lua

local HotkeyConst = require("Const.HotkeyConst")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local FriendSetupCtrl = Class.LightClass("FriendSetupCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local FriendshipLevelData = require("Data.friendship_level_data")
local SysConfigData = require("Data.sys_config_data")
local Const = require("Common.Const.Const")

function FriendSetupCtrl.innerSortFriendList(a, b)
	local onlineA = a.playerInfo.online and 1 or 0
	local onlineB = b.playerInfo.online and 1 or 0

	if onlineA ~= onlineB then
		return onlineB < onlineA
	end

	return pg.game.chat:getFriendship(a.playerId) > pg.game.chat:getFriendship(b.playerId)
end

FriendSetupCtrl.messages = {
	[MessageName.UPDATE_FRIEND_CUSTOM_INFO] = {
		"closePanel",
		true
	},
	[MessageName.UPDATE_CHAT_GROUP] = {
		"closePanel",
		true
	},
	[MessageName.UPDATE_FRIEND_GROUP] = {
		"closePanel",
		true
	},
	[MessageName.PLAYER_SPARK_CHANGE] = {
		"refreshPlayerSpark",
		true
	}
}

local SetupTypeTitle = {
	[0] = "CREATE_FRIEND_GROUP_TITLE",
	"EDIT_FRIEND_GROUP",
	"CHATGROUP_CREAT",
	"CHATGROUP_ADD_MEMBER",
	"CHATGROUP_REMOVE_MEMBER",
	"CHANGE_FRIEND_GROUP"
}
local SetupTypeConfirmText = {
	[0] = "CONFIRM_CREAT_GROUP",
	"CONFIRM_EDIT",
	"CONFIRM_CREAT_GROUP",
	"CONFIRM_INVITE",
	"CONFIRM_REMOVE",
	"CONFIRM_CHANGE"
}

function FriendSetupCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.setupType = info.setupType
	self.playerId = info.playerId
	self.groupId = info.groupId

	self:openFriendSetupPanel()
end

function FriendSetupCtrl:addListener()
	function self.view.bgCloseUButton.luaClick()
		self:closePanel()
	end

	function self.view.btnCloseUButton.luaClick()
		self:closePanel()
	end

	function self.view.setupListUList.luaRenderItem(button, index, data)
		if data.tIndex == 0 then
			self:renderFriendItem(button, index, data)
		elseif data.tIndex == 1 then
			self:renderGroupItem(button, index, data)
		end
	end

	function self.view.btnConfirmUButton.luaClick()
		self:onConfirmButtonClick()
	end

	function self.view.nameInputField.luaValueChanged(text)
		self.groupName, self.useSpace = ClientTextUtils.getValidName(text, SysConfigData.playerNameMaxLen)

		self.view.nameInputField:SetTextWithoutNotify(self.groupName)
		ClientTextUtils.setText(self.view.txtLimitUSDFText, self.useSpace .. "/" .. SysConfigData.playerNameMaxLen * 2)
	end

	local searchCompObjRef = self.view.searchInputField.transform:GetComponent("ObjectReference")
	local btnDeleteUButton = searchCompObjRef:GetRefValue("btnDeleteUButton")
	local placeHolderUSDFText = searchCompObjRef:GetRefValue("placeHolderUSDFText")

	ClientTextUtils.setText(placeHolderUSDFText, pg.getGameString("FRIEND_SEARCH_DESC"))

	function self.view.searchInputField.luaValueChanged(text)
		if string.len(text) > 0 then
			btnDeleteUButton:SetActive(true)
		else
			btnDeleteUButton:SetActive(false)
			self.view.setupListUList:SetList(self.friendDatas)
		end
	end

	function self.view.searchInputField.luaEndEdit(text)
		self:doSearch(text)
	end

	function self.view.btnSearchUButton.luaClick()
		self:doSearch(self.view.searchInputField.text)
	end

	function btnDeleteUButton.luaClick()
		self.view.searchInputField.text = ""
	end
end

function FriendSetupCtrl:renderFriendItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local avatarUButton = objectReference:GetRefValue("avatarUButton")
	local textNameUSDFText = objectReference:GetRefValue("textNameUSDFText")
	local intimateUImage = objectReference:GetRefValue("intimateUImage")
	local textOnlineUSDFText = objectReference:GetRefValue("textOnlineUSDFText")
	local checkBoxUButton = objectReference:GetRefValue("checkBoxUButton")
	local intimacyUButton = objectReference:GetRefValue("intimacyUButton")

	LuaUIUtils.renderPlayerAvatarButton(avatarUButton, {
		showOnlineState = true,
		hideLevel = true,
		playerId = data.playerId,
		playerInfo = data.playerInfo,
		avatarType = LuaUIUtils.PLAYER_AVATAR_TYPE.CHAT,
		playSparkAnimation = self.sparkAnimationPlayerUid == data.playerId
	})
	self:bindFriendIntimacyEvent(intimacyUButton, data)

	local rawName = LuaUIUtils.getPlayerDisplayName(data.playerId, data.playerInfo.playerName)
	local _h = FriendSetupCtrl._platformHooks

	rawName = _h and _h.renderFriendItemName and _h.renderFriendItemName(self, button, data, rawName) or rawName

	ClientTextUtils.setText(textNameUSDFText, rawName)

	local friendShipLevel = pg.game.chat:getFriendship(data.playerId)
	local hasFriendship = friendShipLevel and FriendshipLevelData[friendShipLevel]

	if hasFriendship then
		local friendshipIcon = FriendshipLevelData[friendShipLevel].levelIcon

		intimateUImage:SetActive(true)

		intimateUImage.url = friendshipIcon
	else
		intimateUImage:SetActive(false)
	end

	local lastLogoutTime = LuaUIUtils.getLastTimeStr(data.playerInfo.lastLogoutTime)

	button:TryChangePage("OnlineState", data.playerInfo.online and 0 or 1)
	ClientTextUtils.setText(textOnlineUSDFText, data.playerInfo.online and pg.getGameString("ONLINE") or lastLogoutTime)

	function checkBoxUButton.luaClick()
		if not self:checkCanSelect(data) then
			pg.global.showBubbleMessageRaw(pg.getGameString("CHAT_GROUP_MEMBER_OVERLIMIT"))

			return
		end

		data.isSelected = not data.isSelected

		checkBoxUButton:TryChangePage("Select", data.isSelected and 1 or 0)
		self:setSubTitle()
	end

	button.luaClick = checkBoxUButton.luaClick

	checkBoxUButton:TryChangePage("Select", data.isSelected and 1 or 0)

	if self.setupType == self.model.FriendSetupType.AddChatGroupMember then
		if data.isSelected then
			checkBoxUButton:TryChangePage("SelectState", 1)

			checkBoxUButton.interactable = false
			button.interactable = false
		end
	elseif self.setupType == self.model.FriendSetupType.RemoveChatGroupMember then
		checkBoxUButton:TryChangePage("SelectState", 2)
	end
end

function FriendSetupCtrl:bindFriendIntimacyEvent(intimacyUButton, data)
	intimacyUButton.luaClick = nil

	intimacyUButton:RemoveLuaGamepadHotkey()

	local function openFriendIntimacy()
		pg.global.ui:open(UIConst.UI_ID_FRIEND_INTIMACY, {
			notBackToPlayerCard = true,
			playerInfo = data.playerInfo,
			friendshipValue = pg.game.chat:getFriendIntimacy(data.playerId)
		})

		return false
	end

	intimacyUButton.luaClick = openFriendIntimacy

	intimacyUButton:SetGamepadLongPress(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest, nil, 0, openFriendIntimacy)
	intimacyUButton:SetHotkeyActiveOnlyInCurrentItem(true)
	intimacyUButton:SetHotkeyConsoleBar("CONSOLE_INTIMACY", 0)
end

function FriendSetupCtrl:checkCanSelect(data)
	if not data.isSelected and (self.setupType == self.model.FriendSetupType.CreateChatGroup or self.setupType == self.model.FriendSetupType.AddChatGroupMember) then
		local curCount = self.selectedCount - (self.chatGroup and #self.chatGroup.uids - 1 or 0)
		local totalCount = Const.CHAT.CHAT_GROUP_MAX_MEMBER_COUNT - (self.chatGroup and #self.chatGroup.uids or 1)

		if totalCount <= curCount then
			return false
		end
	end

	return true
end

function FriendSetupCtrl:refreshPlayerSpark(playerUid)
	self.sparkAnimationPlayerUid = playerUid

	self.view.setupListUList:RefreshList()

	self.sparkAnimationPlayerUid = nil
end

function FriendSetupCtrl:renderGroupItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local btnSelectUButton = objectReference:GetRefValue("btnSelectUButton")
	local textNowUSDFText = objectReference:GetRefValue("textNowUSDFText")

	ClientTextUtils.setText(txtNameUSDFText, data.groupLabel)
	button:TryChangePage("Now", self.originGroupId == data.id and 1 or 0)
	ClientTextUtils.setText(textNowUSDFText, pg.getGameString("CHAT_NOW_SELECT"))

	btnSelectUButton.isSelected = data.isSelected

	if data.isSelected then
		self.groupSelectedId = data.id
	end

	function button.luaClick()
		for _, group in ipairs(self.friendGroups) do
			if group.isSelected then
				group.isSelected = false

				break
			end
		end

		data.isSelected = true

		self.view.setupListUList:RefreshList()
	end

	btnSelectUButton.luaClick = button.luaClick
end

function FriendSetupCtrl:openFriendSetupPanel()
	self.view.widget:TryChangePage("Title", self.setupType)

	self.friendDatas = {}

	ClientTextUtils.setText(self.view.textTopTitleUSDFText, pg.getGameString(SetupTypeTitle[self.setupType]))
	ClientTextUtils.setText(self.view.btnConfirmTextUSDFText, pg.getGameString(SetupTypeConfirmText[self.setupType]))

	if self.setupType == self.model.FriendSetupType.CreateGroup or self.setupType == self.model.FriendSetupType.EditGroup or self.setupType == self.model.FriendSetupType.CreateChatGroup then
		local nameText = self.setupType == self.model.FriendSetupType.CreateChatGroup and pg.getGameString("GROUPCHAT_NAME_DESC") or pg.getGameString("GROUP_NAME_DESC")

		ClientTextUtils.setText(self.view.placeHolderUSDFText, nameText)
		ClientTextUtils.setText(self.view.txtLimitUSDFText, 0 .. "/" .. SysConfigData.playerNameMaxLen * 2)

		self.friendGroup = pg.game.chat:getFriendGroup(self.groupId)

		local friendListOptions

		if self.setupType == self.model.FriendSetupType.CreateGroup or self.setupType == self.model.FriendSetupType.EditGroup then
			friendListOptions = {
				rawOnly = true
			}
		end

		local friendList = pg.game.chat:getFriendList(friendListOptions)

		if self.friendGroup then
			self.view.nameInputField.text = self.friendGroup.groupLabel
		end

		for _, friendData in pairs(friendList) do
			local isSelected = pg.game.chat:getFriendCustomInfo(friendData.playerId).groupId == self.groupId
			local data = {
				tIndex = 0,
				playerId = friendData.playerId,
				playerInfo = pg.game.chat:getPlayerInfo(friendData.playerId),
				isSelected = isSelected
			}
			local _h = FriendSetupCtrl._platformHooks

			if _h and _h.prepareFriendSetupItem then
				_h.prepareFriendSetupItem(self, data, friendData)
			end

			self.friendDatas[#self.friendDatas + 1] = data
		end

		table.sort(self.friendDatas, self.innerSortFriendList)

		self.view.setupListUList.groupType = CS.XGUI.EGroupType.Check

		self.view.setupListUList:SetList(self.friendDatas)
		self:setSubTitle()
	elseif self.setupType == self.model.FriendSetupType.ChangeGroup then
		self.friendGroups = {}

		local friendGroupList = pg.game.chat:getFriendGroupList()

		self.originGroupId = pg.game.chat:checkBlackList(self.playerId) and Const.CHAT.CHAT_BLACK_LIST_GROUP_ID or pg.game.chat:getFriendCustomInfo(self.playerId).groupId

		for _, group in ipairs(friendGroupList) do
			if group.id ~= Const.CHAT.CHAT_BLACK_LIST_GROUP_ID then
				local isSelected = self.originGroupId == group.id

				self.friendGroups[#self.friendGroups + 1] = {
					tIndex = 1,
					id = group.id,
					groupLabel = group.groupLabel,
					isSelected = isSelected
				}
			end
		end

		self.view.setupListUList.groupType = CS.XGUI.EGroupType.Radio

		self.view.setupListUList:SetList(self.friendGroups)
	elseif self.setupType == self.model.FriendSetupType.AddChatGroupMember then
		self.chatGroup = pg.game.chat:getFriendChatGroup(self.groupId)

		local friendList = pg.game.chat:getFriendList()

		self.friendDatas = {}

		for _, friendData in pairs(friendList) do
			local isSelected = table.contains(self.chatGroup.uids, friendData.playerId)
			local data = {
				tIndex = 0,
				playerId = friendData.playerId,
				playerInfo = pg.game.chat:getPlayerInfo(friendData.playerId),
				isSelected = isSelected
			}
			local _h = FriendSetupCtrl._platformHooks

			if _h and _h.prepareFriendSetupItem then
				_h.prepareFriendSetupItem(self, data, friendData)
			end

			table.insert(self.friendDatas, data)
		end

		table.sort(self.friendDatas, self.innerSortFriendList)
		self:setSubTitle()

		self.view.setupListUList.groupType = CS.XGUI.EGroupType.Check

		self.view.setupListUList:SetList(self.friendDatas)
	elseif self.setupType == self.model.FriendSetupType.RemoveChatGroupMember then
		self.chatGroup = pg.game.chat:getFriendChatGroup(self.groupId)

		for _, uid in pairs(self.chatGroup.uids) do
			if uid ~= pg.me.uid then
				table.insert(self.friendDatas, {
					tIndex = 0,
					isSelected = false,
					playerId = uid,
					playerInfo = pg.game.chat:getPlayerInfo(uid)
				})
			end
		end

		table.sort(self.friendDatas, self.innerSortFriendList)
		self:setSubTitle()

		self.view.setupListUList.groupType = CS.XGUI.EGroupType.Check

		self.view.setupListUList:SetList(self.friendDatas)
	end
end

function FriendSetupCtrl:setSubTitle()
	self.selectedCount = 0

	for _, data in pairs(self.friendDatas) do
		if data.isSelected then
			self.selectedCount = self.selectedCount + 1
		end
	end

	local curCount = 0
	local totalCount = 0

	if self.setupType == self.model.FriendSetupType.CreateChatGroup or self.setupType == self.model.FriendSetupType.AddChatGroupMember then
		curCount = self.selectedCount - (self.chatGroup and #self.chatGroup.uids - 1 or 0)
		totalCount = Const.CHAT.CHAT_GROUP_MAX_MEMBER_COUNT - (self.chatGroup and #self.chatGroup.uids or 1)

		ClientTextUtils.setText(self.view.textTitleUSDFText, pg.getFormatText(pg.getGameString("CHOOSE_FRIEND_COUNT"), curCount, totalCount))
	else
		ClientTextUtils.setText(self.view.textTitleUSDFText, pg.getFormatText(pg.getGameString("CHOOSE_FRIEND_COUNT"), self.selectedCount, #self.friendDatas))
	end
end

function FriendSetupCtrl:doSearch(text)
	local ret = {}

	for _, data in pairs(self.friendDatas) do
		local remark = pg.game.chat:getFriendCustomInfo(data.playerId).remark or ""

		if string.find(data.playerId, text, 1, true) or string.find(data.playerInfo.playerName, text, 1, true) or string.find(remark, text, 1, true) then
			table.insert(ret, data)
		end
	end

	table.sort(ret, self.innerSortFriendList)
	self.view.setupListUList:SetList(ret)
end

function FriendSetupCtrl:onConfirmButtonClick()
	if self.setupType == self.model.FriendSetupType.CreateGroup then
		if string.isNilOrEmpty(self.groupName) then
			pg.global.showBubbleMessageRaw(pg.getGameString("GROUP_NAME_EMPTY"))

			return
		end

		self:createGroup()
	elseif self.setupType == self.model.FriendSetupType.EditGroup then
		if self.friendGroup.groupLabel ~= self.groupName and (self.groupId == Const.CHAT.CHAT_BLACK_LIST_GROUP_ID or self.groupId == Const.CHAT.CHAT_DEFAULT_LIST_GROUP_ID) then
			pg.global.showBubbleMessageRaw(pg.getGameString("EDIT_DEFAULT_GROUP_NAME_FAILED"))

			return
		end

		self:editGroup()
	elseif self.setupType == self.model.FriendSetupType.ChangeGroup then
		if self.originGroupId == self.groupSelectedId then
			pg.global.showBubbleMessageRaw(pg.getGameString("FRIEND_GROUP_NO_DIFFERENCE"))

			return
		end

		self:changeGroup()
	elseif self.setupType == self.model.FriendSetupType.CreateChatGroup then
		if string.isNilOrEmpty(self.groupName) then
			pg.global.showBubbleMessageRaw(pg.getGameString("GROUP_NAME_EMPTY"))

			return
		end

		self:createChatGroup()
	elseif self.setupType == self.model.FriendSetupType.AddChatGroupMember then
		self:addChatGroupMember()
	elseif self.setupType == self.model.FriendSetupType.RemoveChatGroupMember then
		self:removeChatGroupMember()
	end
end

function FriendSetupCtrl:createGroup()
	local selectedFriendUids = {}
	local _h = FriendSetupCtrl._platformHooks

	for _, data in pairs(self.friendDatas) do
		if data.isSelected then
			local playerId = data.playerId

			if _h and _h.getFriendGroupUid then
				playerId = _h.getFriendGroupUid(self, data, playerId)
			end

			if not string.isNilOrEmpty(playerId) then
				selectedFriendUids[#selectedFriendUids + 1] = playerId
			end
		end
	end

	pg.me:createFriendGroup(self.groupName, selectedFriendUids)
end

function FriendSetupCtrl:addChatGroupMember()
	local selectedFriendUids = {}

	for _, data in pairs(self.friendDatas) do
		if data.isSelected and not table.contains(self.chatGroup.uids, data.playerId) then
			selectedFriendUids[#selectedFriendUids + 1] = data.playerId
		end
	end

	pg.me:joinChatGroup(self.groupId, selectedFriendUids)
end

function FriendSetupCtrl:removeChatGroupMember()
	local selectedFriendUids = {}

	for _, data in pairs(self.friendDatas) do
		if data.isSelected then
			selectedFriendUids[#selectedFriendUids + 1] = data.playerId
		end
	end

	pg.me:leaveChatGroup(self.groupId, selectedFriendUids)
end

function FriendSetupCtrl:editGroup()
	if self.friendGroup.groupLabel ~= self.groupName then
		pg.me:editFriendGroupName(self.groupId, self.groupName)
	end

	local addedFriendUids = {}
	local removedFriendUids = {}
	local _h = FriendSetupCtrl._platformHooks

	for _, data in pairs(self.friendDatas) do
		local playerId = data.playerId

		if _h and _h.getFriendGroupUid then
			playerId = _h.getFriendGroupUid(self, data, playerId)
		end

		if data.isSelected then
			if not string.isNilOrEmpty(playerId) and pg.game.chat:getFriendCustomInfo(playerId).groupId ~= self.groupId then
				addedFriendUids[#addedFriendUids + 1] = playerId
			end
		elseif not string.isNilOrEmpty(playerId) and pg.game.chat:getFriendCustomInfo(playerId).groupId == self.groupId then
			removedFriendUids[#removedFriendUids + 1] = playerId
		end
	end

	if #addedFriendUids > 0 then
		pg.me:moveFriendToGroup(addedFriendUids, self.groupId)
	end

	if #removedFriendUids > 0 then
		pg.me:moveFriendToGroup(removedFriendUids, Const.CHAT.CHAT_DEFAULT_LIST_GROUP_ID)
	end
end

function FriendSetupCtrl:changeGroup()
	local playerId = self.playerId
	local _h = FriendSetupCtrl._platformHooks

	if _h and _h.getFriendGroupUid then
		playerId = _h.getFriendGroupUid(self, {
			playerId = self.playerId,
			playerInfo = pg.game.chat:getPlayerInfo(self.playerId)
		}, playerId)
	end

	pg.me:moveFriendToGroup({
		playerId
	}, self.groupSelectedId)
end

function FriendSetupCtrl:createChatGroup()
	local selectedFriendUids = {}

	for _, data in pairs(self.friendDatas) do
		if data.isSelected then
			selectedFriendUids[#selectedFriendUids + 1] = data.playerId
		end
	end

	pg.me:createChatGroup(selectedFriendUids, self.groupName)
end

function FriendSetupCtrl:closePanel()
	self.groupName = nil
	self.useSpace = nil
	self.playerId = nil
	self.groupSelectedId = nil
	self.friendDatas = nil
	self.setupType = nil
	self.groupId = nil
	self.chatGroup = nil

	self:close()
end

return FriendSetupCtrl
