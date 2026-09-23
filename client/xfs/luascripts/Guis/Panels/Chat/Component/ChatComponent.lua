-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Chat\\Component\\ChatComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local ChatComponent = Class.LightClass("ChatComponent", UIComponent)
local RedDotConst = require("Const.RedDotConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local ClientUtils = require("Utils.ClientUtils")
local FriendshipLevelData = require("Data.friendship_level_data")
local ChatEmojiTabData = require("Data.chat_emoji_tab_data")
local ChatEmojiData = require("Data.chat_emoji_data")
local Const = require("Common.Const.Const")
local ChatSettingData = require("Data.chat_setting_data")
local json = require("json")
local SettingSelectorTextData = require("Data.setting_selector_text_data")
local EventConst = require("Const.EventConst")
local SysConfigData = require("Data.sys_config_data")
local Time = require("Core.Common.Time")
local MessageName = require("Const.MessageName")
local ClientConst = require("Const.ClientConst")
local AddressDataConst = require("Const.AddressDataConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local SpeechComponent = require("Guis.Panels.Chat.Component.SpeechComponent")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local UICtrl = require("Guis.UICtrl")
local HomelandConfigData = require("Data.homeland_config_data")
local HomeCampConst = require("Common.Const.HomeCampConst")
local PlatformCommunicationService = require("SDK.Platform.PlatformCommunicationService")
local PlatformSendMessageService = require("SDK.Platform.PlatformSendMessageService")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeCampData = require("Data.home_camp_data")
local NoticeDef = require("Common.NoticeDef")
local AlbumCtrl = require("Guis.Panels.Album.AlbumCtrl")
local DungeonDifficultLevelData = require("Data.dungeon_difficult_level_data")
local LevelData = require("Data.level_data")

ChatComponent.InputTextType = {
	PET = 1,
	REPLY = 4,
	LOCATION = 3,
	PROP = 2
}

local ChannelTipShowTime = 10
local PrivateChannelMaxCount = 99
local DefaultMarkIcon = "$UI_Icon_Mark01.png"
local DUNGEON_INVITE_REFRESH_INTERVAL = 5
local DUNGEON_INVITE_LIST_REFRESH_DELAY = 0.05

function ChatComponent:getDungeonInviteTitle(dungeonSceneId, dungeonConfig, hardLv)
	local titleKey = dungeonConfig and dungeonConfig.name
	local title = titleKey and pg.getLocalizationText(titleKey) or pg.getGameString("TEAM_INVITE")

	hardLv = tonumber(hardLv or 0)

	local difficultConfigs = DungeonDifficultLevelData[dungeonSceneId]

	if hardLv > 0 and difficultConfigs and difficultConfigs[hardLv] then
		local difficultName = pg.getGameString("DUNGEON_DIFFICUITY_" .. hardLv)

		return ClientTextUtils.concatByLanguage(title, difficultName)
	end

	return title
end

ChatComponent.messages = {
	[MessageName.UPDATE_FRIEND_CUSTOM_INFO] = {
		"refreshFriendCustomInfo"
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged"
	},
	[MessageName.ON_PHOTOGRAPHY_STUDIO_CHANGED] = {
		"onPhotographyStudioInvitationsChanged"
	},
	[MessageName.ON_PHOTOGRAPHY_STUDIO_INVITATIONS_CHANGED] = {
		"onPhotographyStudioInvitationsChanged"
	},
	[MessageName.CHAT_MESSAGE_UPDATE_ITEM] = {
		"onChatMessageUpdateItem",
		true
	},
	[MessageName.TEAM_MEMBER_COUNT_QUERY_RESULT] = {
		"onTeamMemberCountQueryResult"
	}
}

function ChatComponent:findObjects()
	return
end

function ChatComponent:onPhotographyStudioInvitationsChanged()
	self:refreshChatMessageList(false)
end

function ChatComponent:getVoiceSendMessageContext(selectedItem)
	if not selectedItem then
		return nil
	end

	local playerInfo

	if selectedItem.playerId and pg and pg.game and pg.game.chat and type(pg.game.chat.getPlayerInfo) == "function" then
		playerInfo = pg.game.chat:getPlayerInfo(selectedItem.playerId)
	end

	return {
		messageType = pg.game.chat.subMessageType.Audio,
		channelType = selectedItem.type,
		channelId = selectedItem.channelId or selectedItem.playerId,
		targetId = selectedItem.playerId,
		playerInfo = playerInfo,
		chatSystem = pg.game.chat
	}
end

function ChatComponent:canSwitchToVoiceInput()
	local selectedItem = self.view and self.view.channelListUList and self.view.channelListUList.selectedItem

	if not selectedItem then
		return true
	end

	return PlatformSendMessageService:canSendMessage(self:getVoiceSendMessageContext(selectedItem))
end

function ChatComponent:onSwitchInputClicked()
	local _, page = self.view.bottomSendUComponent:TryGetCurrentPage("Switch")
	local nextPage = page == 1 and 0 or 1

	if nextPage == 1 and not self:canSwitchToVoiceInput() then
		return
	end

	self.view.bottomSendUComponent:TryChangePage("Switch", nextPage)
end

function ChatComponent:initView()
	self.channelListData = {}
	self.isRefreshingChannelListSelection = false
	self.showChannelTip = {}
	self.pvpInviteTimer = {}
	self.interactPlayerInfoRequested = {}
	self.interactPlayerInfoQuerying = false
	self.dungeonInviteMemberQueries = {}
	self.dungeonInviteMemberCounts = {}
	self.dungeonInviteMemberCountTimes = {}
	self.pendingDungeonInviteClick = nil
	self.dungeonInviteRefreshEnabled = true
	self.dungeonInviteListRefreshTimer = nil
	self.uiCamera = CS.XGUI.UWidget.uiCamera
	self.bottomViewHeight = 0.16
	self.wordSizeSetting = self:getWordSizeSetting()
	self.messageTranslationStates = {}
	self.pageTranslatedMessages = {}
	self.pageTranslationButtonTextKey = nil

	self:initChannelList()
	self:initChatMessageList()
	self:initChatInput()
	self:initBottomExpandPanel()

	local function refreshDungeonInviteCards()
		self:refreshDungeonInviteState()
	end

	self.dungeonInviteRefreshTimer = self:startTimer(refreshDungeonInviteCards, DUNGEON_INVITE_REFRESH_INTERVAL, true)

	function self.view.btnSwitchUButton.luaClick()
		self:onSwitchInputClicked()
	end

	function self.view.btnVoiceUButton.luaPress()
		self.speechPressTriggered = false

		if self.speechPressTimer then
			self:killTimer(self.speechPressTimer)

			self.speechPressTimer = nil
		end

		self.speechPressTimer = self:startTimer(function()
			self:startSpeaking()
		end, SysConfigData.AUDIO_PRESS_THRESHOLD or 0.5)
	end

	self:bindIntimacyButtonEvents()

	function self.view.btnVoiceUButton.luaRelease()
		self:endSpeaking()
	end

	function self.view.btnReplyUButton.luaClick()
		self.view.replyUWidget:SetActive(false)
		self:resetBottomInputState()
	end

	function self.view.bottomSearchUTMPInputField.luaValueChanged(text)
		local ret = {}

		for _, channel in pairs(self.channelListData) do
			if channel.playerId then
				local playerInfo = pg.game.chat:getPlayerInfo(channel.playerId)
				local remark = ""

				if pg.game.chat.friendCustomList[channel.playerId] and pg.game.chat.friendCustomList[channel.playerId].remark then
					remark = pg.game.chat.friendCustomList[channel.playerId].remark
				end

				if string.find(remark, text, 1, true) or string.find(playerInfo.playerName, text, 1, true) or string.find(channel.playerId, text, 1, true) then
					table.insert(ret, channel)
				end
			elseif channel.channelId and string.find(channel.label, text) then
				table.insert(ret, channel)
			end
		end

		ClientTextUtils.setText(self.view.expendNumUSDFText, pg.getFormatText(pg.getGameString("CURRENT_CHAT_EXPAND"), #ret, PrivateChannelMaxCount))
		self.view.channelListUList:SetList(ret)
	end

	function self.view.listOtherUList.luaRenderItem(button, index, data)
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

			if data.checkFunc and self[data.checkFunc] then
				if self[data.checkFunc](self, data.settingType) then
					button1UButton.isSelected = false
					button2UButton.isSelected = true
				else
					button1UButton.isSelected = true
					button2UButton.isSelected = false
				end
			end

			if data.func and self[data.func] then
				function button1UButton.luaClick()
					self[data.func](self, false, data.settingType)

					button2UButton.isSelected = false
				end

				function button2UButton.luaClick()
					self[data.func](self, true, data.settingType)

					button1UButton.isSelected = false
				end
			end
		elseif data.tIndex == 2 or data.tIndex == 3 then
			local objectReference = button:GetComponent("ObjectReference")
			local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

			ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.label))

			if data.func and self[data.func] then
				function button.luaClick()
					self.ctrl:hideExtensionFunc()
					self[data.func](self)
				end
			end
		elseif data.tIndex == 4 then
			self:renderPageTranslationSettingItem(button, data)
		end
	end

	self.view.btnSystemCheckUButton.isSelected = pg.global.prefsCacheUtils:getBool(pg.me.uid .. "ImportantSystemNotice", false)

	function self.view.btnSystemCheckUButton.luaSelectChanged(isSelected)
		pg.global.prefsCacheUtils:setBool(pg.me.uid .. "ImportantSystemNotice", isSelected)
		self:refreshChatMessageList()
	end

	function self.view.topOtherBtnCloseUButton.luaClick()
		self.ctrl:hideExtensionFunc()
	end

	function self.view.emojiCloseUButton.luaClick()
		self.showEmojiPanel = false

		self.view.emojiUWidget:SetActive(self.showEmojiPanel)
		self.view.addPanelUWidget:SetActive(false)
		self:setAddPanelUWidgetActive(false)
	end

	function self.view.extensionCloseUButton.luaClick()
		self.view.emojiUWidget:SetActive(false)

		self.showEmojiPanel = false

		self:setAddPanelUWidgetActive(false)
	end

	ClientTextUtils.setText(self.view.searchPlaceHolderUSDFText, pg.getGameString("CHAT_LIST_SEARCH_DESC"))
	ClientTextUtils.setText(self.view.textSystemCheckUSDFText, pg.getGameString("CHAT_SYSTEM_CHECK_TIP"))
	self.view.btnVoicePlayUButton:SetActive(false)

	local gamepadVoiceLongPressBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnVoiceUButton.gameObject, "gamepadVoiceLongPressBind")

	gamepadVoiceLongPressBind.isVirtual = true
	gamepadVoiceLongPressBind.priority = -1
	gamepadVoiceLongPressBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonNorth

	function gamepadVoiceLongPressBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			if self.speechPressTimer then
				self:killTimer(self.speechPressTimer)

				self.speechPressTimer = nil
			end

			self:startSpeaking()
		elseif inputInfo.phase == "Canceled" then
			self:endSpeaking()
		end
	end
end

function ChatComponent:onDestroy()
	self:unregisterMessageListScrollEvent()
end

function ChatComponent:unregisterMessageListScrollEvent()
	if self.messageListScrollCallback == nil then
		return
	end

	self.view.messageListUList:UnRegisterToScrollEvent(self.messageListScrollCallback)

	self.messageListScrollCallback = nil
end

function ChatComponent:renderPageTranslationSettingItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local btnOpenUButton = objectReference:GetRefValue("btnOpenUButton")
	local buttonObjectReference = btnOpenUButton:GetComponent("ObjectReference")
	local uIBtn1stConfirmUButton = buttonObjectReference:GetRefValue("uIBtn1stConfirmUButton")
	local txtNameUText = buttonObjectReference:GetRefValue("txtNameUText")
	local keyHotKeyContent = buttonObjectReference:GetRefValue("keyHotKeyContent")
	local buttonTextKey = self:getCurrentPageTranslationTextKey()

	self.pageTranslationButtonTextKey = buttonTextKey

	ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.label))
	ClientTextUtils.setText(txtNameUText, pg.getGameString(buttonTextKey))

	local actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadConfirm

	keyHotKeyContent:SetHotKeyPaths(actionPath)
	uIBtn1stConfirmUButton:SetGamepadAction(actionPath, keyHotKeyContent.gameObject)
	uIBtn1stConfirmUButton:SetHotkeyActiveOnlyInCurrentItem(true)

	function uIBtn1stConfirmUButton.luaClick()
		self[data.func](self)
	end
end

function ChatComponent:getCurrentPageTranslationTextKey()
	if self:hasCurrentPageTranslation() or self:isCurrentPageTranslated() then
		return "AI_SHOW_ORIGINAL"
	end

	return "AI_TRANSLATE_CURRENT_PAGE"
end

function ChatComponent:hasCurrentPageTranslation()
	return next(self.pageTranslatedMessages) ~= nil
end

function ChatComponent:isCurrentPageTranslated()
	local hasTranslatableMessage = false

	for _, messageData in ipairs(self:getCurrentPageMessageData()) do
		if self:checkMessageCanTranslate(messageData) then
			hasTranslatableMessage = true

			if not self:isMessageTranslationSelected(messageData) then
				return false
			end
		end
	end

	return hasTranslatableMessage
end

function ChatComponent:getCurrentPageMessageData()
	local messageListUList = self.view.messageListUList
	local success, minIndex, maxIndex = messageListUList:TryGetVisualRange()

	if not success then
		return {}
	end

	local currentPageData = {}

	for index = minIndex, maxIndex do
		local hasChild = messageListUList:TryGetChildAt(index)

		if hasChild then
			currentPageData[#currentPageData + 1] = messageListUList.itemData[index]
		end
	end

	return currentPageData
end

function ChatComponent:translateCurrentPage()
	if self:hasCurrentPageTranslation() or self:isCurrentPageTranslated() then
		self:showCurrentPageOriginal()

		return
	end

	self:startCurrentPageTranslation()
end

function ChatComponent:startCurrentPageTranslation()
	local hasTranslatableMessage = false
	local hasTranslationSelected = false
	local currentPageMessageData = self:getCurrentPageMessageData()

	for _, messageData in ipairs(currentPageMessageData) do
		local canTranslate = self:checkMessageCanTranslate(messageData)

		hasTranslatableMessage = hasTranslatableMessage or canTranslate

		local shouldTranslate = canTranslate and not self:isMessageTranslationSelected(messageData)
		local translationStarted = shouldTranslate and self:selectMessageTranslation(messageData)

		if translationStarted and self:isMessageTranslationSelected(messageData) then
			self.pageTranslatedMessages[messageData] = true
			hasTranslationSelected = true
		end
	end

	if not hasTranslatableMessage then
		pg.global.showBubbleMessageRaw(pg.getGameString("AI_TRANSLATE_CURRENT_PAGE_EMPTY"))

		return
	end

	if not hasTranslationSelected then
		return
	end

	self:refreshMessageListForTranslation()
	self:refreshCurrentPageTranslationButton()
	pg.global.showBubbleMessageRaw(pg.getGameString("AI_TRANSLATE_CURRENT_PAGE"))
end

function ChatComponent:showCurrentPageOriginal()
	local currentPageMessageData = self:getCurrentPageMessageData()
	local hasTranslationHidden = self:resetCurrentPageTranslationState()

	for _, messageData in ipairs(currentPageMessageData) do
		local shouldShowOriginal = self:checkMessageCanTranslate(messageData) and self:isMessageTranslationSelected(messageData)

		if shouldShowOriginal then
			self:clearMessageTranslationDisplay(messageData)

			hasTranslationHidden = true
		end
	end

	if not hasTranslationHidden then
		return
	end

	self.view.messageListUList:RefreshList()
	self:refreshCurrentPageTranslationButton()
end

function ChatComponent:refreshCurrentPageTranslationButton()
	local buttonTextKey = self:getCurrentPageTranslationTextKey()

	if buttonTextKey == self.pageTranslationButtonTextKey then
		return
	end

	self.pageTranslationButtonTextKey = buttonTextKey

	self.view.listOtherUList:RefreshList()
end

function ChatComponent:resetCurrentPageTranslationState()
	if next(self.pageTranslatedMessages) == nil then
		return false
	end

	for messageData in next, self.pageTranslatedMessages do
		self:clearMessageTranslationDisplay(messageData)
	end

	self.pageTranslatedMessages = {}
	self.pageTranslationButtonTextKey = nil

	return true
end

function ChatComponent:refreshDungeonInviteState()
	local currentTime = Time.realSecondCache

	self:expireDungeonInviteMemberQueries(currentTime)
	self:expireDungeonInviteClick(currentTime)
	self:refreshVisibleDungeonInviteCards()
end

function ChatComponent:expireDungeonInviteMemberQueries(currentTime)
	for teamId, pendingQuery in next, self.dungeonInviteMemberQueries do
		if currentTime >= pendingQuery.expireAt then
			self:expireDungeonInviteMemberQuery(teamId, pendingQuery)
		end
	end
end

function ChatComponent:expireDungeonInviteClick(currentTime)
	local context = self.pendingDungeonInviteClick

	if not context or not context.expireAt or currentTime < context.expireAt then
		return
	end

	self:finishDungeonInviteClick(context, context.expireTipKey)
end

function ChatComponent:refreshVisibleDungeonInviteCards()
	local messageListUList = self.view and self.view.messageListUList

	if not self.dungeonInviteRefreshEnabled or not messageListUList then
		return
	end

	local playerIds = {}
	local playerIdSet = {}
	local teamIds = {}
	local hasNewInvalidCard = false
	local buttons = messageListUList:GetAllButtons()

	for i = 0, buttons.Length - 1 do
		local button = buttons[i]
		local data = messageListUList:GetData(button)
		local isDungeonInvite = data and data.subType == pg.game.chat.subMessageType.DungeonInvite and button.gameObject.activeInHierarchy

		if isDungeonInvite then
			local inviteButton = button:GetChild("Pop"):GetChild("InviteInfo")
			local _, lostEffectiveness = inviteButton:TryGetCurrentPage("LostEffectiveness")
			local isValid, teamId, invalidReason = self:getDungeonInviteRefreshInfo(data)
			local wasEffective = lostEffectiveness == 0

			if wasEffective and not isValid then
				hasNewInvalidCard = true
			end

			local shouldQueryPlayerInfo = data.playerId ~= pg.me.uid and not playerIdSet[data.playerId] and teamId ~= "0" and invalidReason ~= "expired" and invalidReason ~= "missingInviteInfo"

			if shouldQueryPlayerInfo then
				playerIdSet[data.playerId] = true
				playerIds[#playerIds + 1] = data.playerId
			end

			if isValid and not string.isNilOrEmpty(teamId) then
				teamIds[teamId] = true
			end
		end
	end

	self:queryDungeonInvitePlayerInfoList(playerIds)

	for teamId in pairs(teamIds) do
		self:queryDungeonInviteMemberCount(teamId, true)
	end

	if hasNewInvalidCard then
		self:refreshDungeonInviteMessageList()
	end
end

function ChatComponent:getDungeonInviteRefreshInfo(data)
	local inviteInfo = data.extraInfo and data.extraInfo[Const.CHAT_EXTRA_TYPE.TeamInvite]
	local dungeonSceneId = inviteInfo and tonumber(inviteInfo.dungeonId or "") or nil
	local dungeonConfig = dungeonSceneId and LevelData[dungeonSceneId]
	local maxMember = tonumber(dungeonConfig and dungeonConfig.playerNumMax) or 4
	local playerInfo = pg.game.chat:getPlayerInfo(data.playerId)
	local teamId = inviteInfo and tostring(inviteInfo.teamId or "") or ""
	local memberCount = self:getDungeonInviteMemberCount(teamId, playerInfo)
	local isValid, invalidReason = self:checkDungeonInviteInfoState(data, playerInfo, memberCount, maxMember)

	return isValid, teamId, invalidReason
end

function ChatComponent:queryDungeonInvitePlayerInfoList(playerIds)
	if #playerIds == 0 then
		return
	end

	local ownerView = self.view

	local function onCompleted(succeeded, results)
		local canRefresh = succeeded == true and self.dungeonInviteRefreshEnabled and self.view == ownerView

		if canRefresh then
			self:setDungeonInvitePlayerStates(results)
			self:refreshDungeonInviteMessageList()
		end
	end

	pg.me:queryDungeonInvitePlayerStateList(playerIds, onCompleted)
end

function ChatComponent:setDungeonInvitePlayerStates(results)
	for _, item in ipairs(results) do
		local attributes = item.AttributesMap

		if attributes then
			pg.game.chat:setDungeonInvitePlayerState(item.Uid, attributes)
		end
	end
end

function ChatComponent:refreshDungeonInviteData(data, isValid)
	local inviteInfo = data.extraInfo and data.extraInfo[Const.CHAT_EXTRA_TYPE.TeamInvite]

	if not inviteInfo then
		return
	end

	if not isValid then
		return
	end

	self:queryDungeonInviteMemberCount(inviteInfo.teamId, false)
end

function ChatComponent:queryDungeonInvitePlayerState(playerId, callback)
	local ownerView = self.view

	local function onCompleted(succeeded, results)
		local isCurrentView = self.dungeonInviteRefreshEnabled and self.view == ownerView

		if not isCurrentView then
			return
		end

		if succeeded == true then
			self:setDungeonInvitePlayerStates(results)
		end

		callback(pg.game.chat:getPlayerInfo(playerId), succeeded)
	end

	return pg.me:queryDungeonInvitePlayerStateList({
		playerId
	}, onCompleted)
end

function ChatComponent:getDungeonInviteMemberCount(teamId, playerInfo)
	teamId = tostring(teamId or "")

	local currentTeamInfo = pg.me:getCurTeamInfo()
	local currentTeamId = tostring(currentTeamInfo and currentTeamInfo.teamId or "")
	local isCurrentTeam = pg.me:isInTeam() and currentTeamId == teamId

	if isCurrentTeam then
		return pg.me:getTeamMemberCount()
	end

	local playerTeamId = tostring(playerInfo and playerInfo.teamId or "")
	local playerTeamMemberCount = playerInfo and not string.isNilOrEmpty(teamId) and playerTeamId == teamId and tonumber(playerInfo.teamMembers) or nil

	return self.dungeonInviteMemberCounts[teamId] or playerTeamMemberCount or 1
end

function ChatComponent:queryDungeonInviteMemberCount(teamId, force)
	teamId = tostring(teamId or "")

	if string.isNilOrEmpty(teamId) then
		return false
	end

	local currentTeamInfo = pg.me:getCurTeamInfo()

	if pg.me:isInTeam(true) then
		if tostring(currentTeamInfo and currentTeamInfo.teamId or "") == teamId then
			self.dungeonInviteMemberCounts[teamId] = pg.me:getTeamMemberCount()
			self.dungeonInviteMemberCountTimes[teamId] = Time.realSecondCache

			return true
		end

		return false
	end

	if self.dungeonInviteMemberQueries[teamId] then
		return true
	end

	if self.dungeonInviteMemberCounts[teamId] == 0 then
		return false
	end

	local lastQueryTime = self.dungeonInviteMemberCountTimes[teamId]
	local hasFreshCount = not force and lastQueryTime and lastQueryTime + DUNGEON_INVITE_REFRESH_INTERVAL > Time.realSecondCache

	if hasFreshCount then
		return true
	end

	local pendingQuery = {
		expireAt = Time.realSecondCache + DUNGEON_INVITE_REFRESH_INTERVAL
	}

	self.dungeonInviteMemberQueries[teamId] = pendingQuery

	if not pg.me:queryTeamMemberCount(teamId) then
		self.dungeonInviteMemberQueries[teamId] = nil

		return false
	end

	return true
end

function ChatComponent:expireDungeonInviteMemberQuery(teamId, pendingQuery)
	if self.dungeonInviteMemberQueries[teamId] ~= pendingQuery then
		return
	end

	self.dungeonInviteMemberQueries[teamId] = nil

	local clickContext = self.pendingDungeonInviteClick
	local isWaitingMember = clickContext and clickContext.stage == "member" and clickContext.teamId == teamId

	if isWaitingMember then
		self:finishDungeonInviteClick(clickContext, "INVITATION_EXPIRED")
	end
end

function ChatComponent:onTeamMemberCountQueryResult(info)
	if not self.dungeonInviteRefreshEnabled then
		return
	end

	local teamId = tostring(info and info.teamId or "")
	local memberCount = tonumber(info and info.memberCount)

	if string.isNilOrEmpty(teamId) or not memberCount or memberCount < 0 then
		return
	end

	self.dungeonInviteMemberQueries[teamId] = nil
	self.dungeonInviteMemberCounts[teamId] = memberCount
	self.dungeonInviteMemberCountTimes[teamId] = Time.realSecondCache

	local clickContext = self.pendingDungeonInviteClick
	local isWaitingMember = clickContext and clickContext.stage == "member" and clickContext.teamId == teamId

	if isWaitingMember then
		self:finishDungeonInviteClickWithMemberCount(clickContext, memberCount)

		return
	end

	self:refreshDungeonInviteMessageList()
end

function ChatComponent:refreshDungeonInviteMessageList()
	local messageListUList = self.view and self.view.messageListUList
	local cannotRefresh = not self.dungeonInviteRefreshEnabled or not messageListUList or self.dungeonInviteListRefreshTimer

	if cannotRefresh then
		return
	end

	local function refreshMessageList()
		self.dungeonInviteListRefreshTimer = nil

		local canRefresh = self.dungeonInviteRefreshEnabled and self.view and self.view.messageListUList == messageListUList

		if canRefresh then
			messageListUList:RefreshList()
		end
	end

	self.dungeonInviteListRefreshTimer = self:startTimer(refreshMessageList, DUNGEON_INVITE_LIST_REFRESH_DELAY)
end

function ChatComponent:startDungeonInviteClick(listButton, inviteButton, data, maxMember)
	local canStart = data.playerId ~= pg.me.uid and not pg.me:isInTeam(true) and not self.pendingDungeonInviteClick and self:isDungeonInviteListDataCurrent(listButton, data)

	if not canStart then
		return
	end

	local context = {
		stage = "player",
		expireTipKey = "INVITATION_EXPIRED",
		listButton = listButton,
		data = data,
		expireAt = Time.realSecondCache + DUNGEON_INVITE_REFRESH_INTERVAL,
		maxMember = maxMember
	}

	self.pendingDungeonInviteClick = context
	inviteButton.interactable = false

	local function onPlayerInfo(playerInfo, succeeded)
		self:onDungeonInvitePlayerInfoResult(context, playerInfo, succeeded)
	end

	local querySent = self:queryDungeonInvitePlayerState(data.playerId, onPlayerInfo)

	if not querySent then
		self:finishDungeonInviteClick(context, "INVITATION_EXPIRED")
	end
end

function ChatComponent:onDungeonInvitePlayerInfoResult(context, playerInfo, succeeded)
	if self.pendingDungeonInviteClick ~= context then
		return
	end

	context.expireAt = nil
	context.expireTipKey = nil

	if not self:isDungeonInviteListDataCurrent(context.listButton, context.data) then
		self:finishDungeonInviteClick(context)

		return
	end

	if not succeeded then
		self:finishDungeonInviteClick(context, "INVITATION_EXPIRED")

		return
	end

	local isValid = self:checkDungeonInviteInfoState(context.data, playerInfo, nil, context.maxMember)

	if not isValid then
		self:finishDungeonInviteClick(context, "INVITATION_EXPIRED")

		return
	end

	local inviteInfo = context.data.extraInfo[Const.CHAT_EXTRA_TYPE.TeamInvite]

	context.stage = "member"
	context.teamId = tostring(inviteInfo.teamId)
	context.playerInfo = playerInfo

	if not self:queryDungeonInviteMemberCount(context.teamId, true) then
		self:finishDungeonInviteClick(context, "INVITATION_EXPIRED")
	end
end

function ChatComponent:finishDungeonInviteClickWithMemberCount(context, memberCount)
	local isCurrentClick = self.pendingDungeonInviteClick == context and self:isDungeonInviteListDataCurrent(context.listButton, context.data)

	if not isCurrentClick then
		self:finishDungeonInviteClick(context)

		return
	end

	if pg.me:isInTeam(true) then
		self:finishDungeonInviteClick(context, "INVITATION_EXPIRED")

		return
	end

	local isValid, invalidReason = self:checkDungeonInviteInfoState(context.data, context.playerInfo, memberCount, context.maxMember)

	if not isValid then
		local tipKey = invalidReason == "teamFull" and "OTHER_TEAM_FULL" or "INVITATION_EXPIRED"

		self:finishDungeonInviteClick(context, tipKey)

		return
	end

	self:joinDungeonInviteTeam(context.data)

	context.stage = "joined"
	context.expireAt = Time.realSecondCache + DUNGEON_INVITE_REFRESH_INTERVAL

	self:refreshDungeonInviteMessageList()
end

function ChatComponent:finishDungeonInviteClick(context, tipKey)
	if self.pendingDungeonInviteClick ~= context then
		return
	end

	self.pendingDungeonInviteClick = nil

	if tipKey and self:isDungeonInviteListDataCurrent(context.listButton, context.data) then
		pg.global.ui.tips:showTextTip(pg.getGameString(tipKey))
	end

	self:refreshDungeonInviteMessageList()
end

function ChatComponent:isDungeonInviteListDataCurrent(listButton, data)
	local messageListUList = self.view and self.view.messageListUList

	return messageListUList and listButton and listButton.gameObject.activeInHierarchy and messageListUList:GetData(listButton) == data
end

function ChatComponent:bindIntimacyButtonEvents()
	local intimacyButton = self.view.btnImgLikabilityUButton
	local selectedItem = self.view.channelListUList.selectedItem
	local playerId = selectedItem and selectedItem.playerId
	local isFriendPlayerChannel = selectedItem and selectedItem.type == pg.game.chat.channelType.Player and playerId and pg.game.chat:checkFriendList(playerId)

	local function openFriendIntimacy()
		if not isFriendPlayerChannel then
			return false
		end

		pg.global.ui:open(UIConst.UI_ID_FRIEND_INTIMACY, {
			notBackToPlayerCard = true,
			playerInfo = pg.game.chat:getPlayerInfo(playerId),
			friendshipValue = pg.game.chat:getFriendIntimacy(playerId)
		})

		return false
	end

	intimacyButton.luaClick = openFriendIntimacy

	intimacyButton:RemoveLuaGamepadHotkey()

	if not isFriendPlayerChannel then
		self.view.imgLikabilityUImage.gameObject:SetActiveEx(false)

		return
	end

	intimacyButton:SetGamepadLongPress(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest, nil, 0, openFriendIntimacy)
	intimacyButton:SetHotkeyConsoleBar("CONSOLE_INTIMACY", 0, self.view.mainConsoleBarTransform)
end

function ChatComponent:startSpeaking()
	self.speechPressTimer = nil
	self.speechPressTriggered = true

	if not self.speechComponent then
		self.speechComponent = SpeechComponent.new(self, self.view.voicePanelUWidget)
	else
		self.speechComponent:refreshSpeechPanel(true)
	end
end

function ChatComponent:endSpeaking()
	if self.speechPressTimer then
		self:killTimer(self.speechPressTimer)

		self.speechPressTimer = nil
		self.speechPressTriggered = false

		return
	end

	if self.speechPressTriggered and self.speechComponent then
		self.speechComponent:handleTriggerFunc()
	end

	self.speechPressTriggered = false
end

function ChatComponent:cancelSpeechRecording()
	if self.speechPressTimer then
		self:killTimer(self.speechPressTimer)

		self.speechPressTimer = nil
	end

	self.speechPressTriggered = false

	if self.speechComponent then
		self.speechComponent:cancelRecording()
	end
end

function ChatComponent:getWordSizeSetting()
	local size = pg.global.prefsCacheUtils:getString(pg.me.uid .. ChatSettingData[pg.game.chat.settingType.Word].tab .. pg.game.chat.settingType.Word, 1)

	if size == nil then
		return 1
	end

	return tonumber(size)
end

function ChatComponent:renderChannelListItem(button, data)
	if data.tIndex and data.tIndex == 1 then
		return
	end

	local function selectChannelItem()
		if not pg.game.input:isUsingGamepad() or self.ctrl.expend or button.isSelected then
			return
		end

		button:OnClickSimulate(true)
	end

	button.luaNavFocused = selectChannelItem

	local objectReference = button:GetComponent("ObjectReference")
	local avatar = objectReference:GetRefValue("avatarUButton")
	local imgLikabilityUImage = objectReference:GetRefValue("imgLikabilityUImage")
	local imgEmblemUImage = objectReference:GetRefValue("imgEmblemUImage")
	local txtNameChangeUSDFText = objectReference:GetRefValue("txtNameChangeUSDFText")
	local nameCoverUSDFText = objectReference:GetRefValue("nameCoverUSDFText")
	local groupHeadIconUImage = objectReference:GetRefValue("groupHeadIconUImage")
	local textNameUSDFText = objectReference:GetRefValue("textNameUSDFText")
	local labelUSDFText = objectReference:GetRefValue("labelUSDFText")
	local txtNameUBaseText = button:GetChild("TxtName"):GetComponent("UBaseText")

	avatar.luaNavFocused = selectChannelItem

	local channelDisplayName = self:renderChannelListItemBase(button, data, avatar, labelUSDFText)

	channelDisplayName = self:renderChannelListItemPlayer(data, avatar, txtNameUBaseText, imgLikabilityUImage, imgEmblemUImage, txtNameChangeUSDFText, nameCoverUSDFText, channelDisplayName)

	self:renderChannelListItemChannel(button, data, groupHeadIconUImage, textNameUSDFText, txtNameUBaseText, channelDisplayName)
end

function ChatComponent:renderChannelListItemBase(button, data, avatar, labelUSDFText)
	button:TryChangePage("Type", tonumber(data.type))
	avatar:TryChangePage("State", data.state + 1)

	local isSpecialFriend = pg.game.chat.specialFriendUId and pg.game.chat.specialFriendUId == data.playerId

	button:TryChangePage("isChange", isSpecialFriend and 1 or 0)

	local channelName

	if data.type == pg.game.chat.channelType.World then
		channelName = pg.game.chat:getWorldChatChannelName(data.channelId, data.groupBase, data.shortLabel)
	else
		channelName = pg.getGameString(data.shortLabel or data.label)
	end

	ClientTextUtils.setText(labelUSDFText, channelName)

	return channelName
end

function ChatComponent:renderChannelListItemPlayer(data, avatar, txtNameUBaseText, imgLikabilityUImage, imgEmblemUImage, txtNameChangeUSDFText, nameCoverUSDFText, channelDisplayName)
	local playerInfo = pg.game.chat:getPlayerInfo(data.playerId)

	if not playerInfo then
		return channelDisplayName
	end

	LuaUIUtils.renderPlayerAvatarButton(avatar, {
		hideLevel = true,
		playerId = data.playerId,
		playerInfo = playerInfo,
		avatarType = LuaUIUtils.PLAYER_AVATAR_TYPE.CHAT,
		playSparkAnimation = self.ctrl.sparkAnimationPlayerUid == data.playerId
	})

	local friendShipLevel = pg.game.chat:getFriendship(data.playerId)
	local hasFriendship = friendShipLevel and FriendshipLevelData[friendShipLevel]

	if hasFriendship then
		local friendshipIcon = FriendshipLevelData[friendShipLevel].levelIcon

		imgLikabilityUImage.url = friendshipIcon
	end

	imgLikabilityUImage.gameObject:SetActiveEx(hasFriendship)

	imgEmblemUImage.url = LuaUIUtils.getStarIcon(playerInfo.starTitle)

	local hooks = ChatComponent._platformHooks
	local playerName = LuaUIUtils.getPlayerDisplayName(data.playerId, playerInfo.playerName)

	playerName = hooks and hooks.renderChannelItemName and hooks.renderChannelItemName(data, playerInfo, playerName) or playerName
	txtNameUBaseText.text = playerName

	ClientTextUtils.setText(txtNameChangeUSDFText, playerName)
	ClientTextUtils.setText(nameCoverUSDFText, playerName)

	return playerName
end

function ChatComponent:renderChannelListItemChannel(button, data, groupHeadIconUImage, textNameUSDFText, txtNameUBaseText, channelDisplayName)
	if data.tIndex ~= 0 then
		return
	end

	channelDisplayName = self:getChannelListGroupDisplayName(data, channelDisplayName, groupHeadIconUImage)

	ClientTextUtils.setText(textNameUSDFText, channelDisplayName)

	txtNameUBaseText.text = channelDisplayName

	self:renderChannelLastMessage(button, pg.game.chat:getChannelLastMessage(data.channelId))
	self:bindChannelListItemRedDot(button, data)
end

function ChatComponent:getChannelListGroupDisplayName(data, channelDisplayName, groupHeadIconUImage)
	if data.type ~= pg.game.chat.channelType.Group then
		return channelDisplayName
	end

	local friendChatGroup = pg.game.chat:getFriendChatGroup(data.channelId)
	local chatGroupName = friendChatGroup and friendChatGroup.chatGroupName

	if not string.isNilOrEmpty(chatGroupName) then
		channelDisplayName = chatGroupName
	end

	groupHeadIconUImage.url = AddressDataConst.CHAT_GROUP_HEAD_ICONS[data.headIconKey]

	local _h = ChatComponent._platformHooks

	channelDisplayName = _h and _h.renderGroupChannelDisplayName and _h.renderGroupChannelDisplayName(data, channelDisplayName) or channelDisplayName

	return channelDisplayName
end

function ChatComponent:bindChannelListItemRedDot(button, data)
	local channelTabType = pg.game.chat.channelTypeInfo[data.type].cate
	local treePath = string.format(RedDotConst.RedDotPath.CHAT_TAB_MESSAGE_LIST_ITEM, channelTabType, data.channelId or data.playerId)
	local shouldShowRedDot = channelTabType ~= pg.game.chat.tabType.Public
	local messageNum = 0

	local function getRedDotStyle()
		if shouldShowRedDot and messageNum > 0 then
			return RedDotConst.RedDotStyle.NUM
		end

		return RedDotConst.RedDotStyle.NONE
	end

	local function getRedDotNumber()
		if not shouldShowRedDot or data.type == pg.game.chat.channelType.System then
			messageNum = 0
		elseif data.type == pg.game.chat.channelType.Interact then
			messageNum = pg.game.chat:getInteractUnreadCount()
		else
			messageNum = self.model:redDot_GetMessageNumb(data.channelId or data.playerId)
		end

		return messageNum
	end

	pg.global.setPreViewRedDot(treePath, button, getRedDotStyle, getRedDotNumber)
end

function ChatComponent:initChannelList()
	function self.view.channelListUList.luaRenderItem(button, index, data)
		self:renderChannelListItem(button, data)
	end

	function self.view.channelListUList.luaClick(button, data, navConfirm)
		if self.ctrl.expend and navConfirm then
			return
		end

		if self.ctrl.expend then
			data.selected = false

			local selectionKey = self.model:getChannelSelectionKey(data)

			self:refreshChannelList(pg.game.chat.tabType.Chat, selectionKey)
			self.view.btnExpendUButton:OnClickSimulate()
		end

		local friendChatGroup = pg.game.chat:getFriendChatGroup(data.channelId)

		if friendChatGroup and friendChatGroup.markForRemove then
			pg.global.showBubbleMessageRaw(pg.getGameString("CHAT_GROUP_NOT_EXIST"))
			pg.game.chat:removeChannel(data.channelId)
		end
	end

	function self.view.channelListUList.luaSelectedChanged(uList, isSelect)
		if pg.global.platform:isConsoleFamily() and self.isRefreshingChannelListSelection then
			return
		end

		if self.ctrl.expend or not isSelect then
			return
		end

		self:refreshChannelListGamepadDefaultFocus()

		self.curSelectedChannel = uList.selectedIndex + 1

		local shouldShowChannelTip = false
		local shouldResetChannelTip = false
		local nextChannelId = uList.selectedItem.channelId or uList.selectedItem.playerId

		if nextChannelId ~= self.curSelectedChannelId then
			self:resetCurrentPageTranslationState()
		end

		self.curSelectedChannelId = nextChannelId

		if self.curSelectedChannelId ~= self._selectedChannelIdCache then
			shouldResetChannelTip = true
			self.needSetBottom = true

			if self.ctrl.extensionVisible then
				self.view.btnPrivateOtherUButton:OnClickSimulate()
			end
		end

		self._selectedChannelIdCache = self.curSelectedChannelId
		self.curSelectedChannelType = uList.selectedItem.type

		self:refreshPositionData(self.curSelectedChannelType)
		self:refreshChatMessageList()
		self:refreshChatMessageTitle(uList.selectedItem)
		self:refreshChatInput(uList.selectedItem)
		ClientTextUtils.setText(self.view.txtEmptyUBaseText, pg.getGameString("CHAT_NO_MESSAGE"))
		self.view.btnGoUButton:SetActive(false)
		self.view.listMembersUList:SetList({})
		self.view.personalTopAddBtn.gameObject:SetActiveEx(false)
		self.view.widget:TryChangePage("IsPrivate", uList.selectedItem.playerId and 0 or 1)

		local channelType = uList.selectedItem.type
		local isMessageOnlyChannel = self:isMessageOnlyChannelType(channelType)

		self.view.bottomSendUComponent:SetActive(not isMessageOnlyChannel)
		self.view.topInfoRectTransform.gameObject:SetActiveEx(true)

		if self:isPublicChannelType(channelType) then
			shouldShowChannelTip = self:handleWorldChannelSelectedChanged(uList)
		elseif self:isPrivateChannelType(channelType) then
			shouldShowChannelTip = self:handlePrivateChannelSelectedChanged(uList)
		elseif isMessageOnlyChannel then
			self:handleNoticeChannelSelectedChanged(uList)
		end

		self:bindIntimacyButtonEvents()

		local otherFuncList = self.model:getExtensionFunctionList(uList.selectedItem.type, self.curSelectedChannelId)

		if otherFuncList and #otherFuncList > 0 then
			self.view.btnPrivateOtherUButton:SetActive(true)
			self.view.listOtherUList:SetList(otherFuncList)
		else
			self.view.btnPrivateOtherUButton:SetActive(false)
		end

		self:resetBottomInputState()
		self:checkSendButtonState()
		self:refreshChannelTip(channelType, shouldShowChannelTip, shouldResetChannelTip)

		if isSelect and pg.global.gmeManager:getCurPlayingChannel() ~= self.curSelectedChannelId then
			pg.game.speech:stopPlayAudioFile()
		end

		if isSelect and CS.XGUI.Navigation.NavManager.Instance.CurrentFocusedGroupName == "SecondTab" then
			CS.XGUI.Navigation.NavManager.Instance:FocusGroupByName("SecondTab")
		end
	end

	if self.curSelectedChannel == nil or self.curSelectedChannel > #self.channelListData then
		self.curSelectedChannel = 1
	end

	local channelInfo = self.channelListData[self.curSelectedChannel]

	self:refreshChatMessageTitle(channelInfo)

	self.needSetBottom = true
end

function ChatComponent:refreshChannelTip(channelType, shouldShowChannelTip, shouldResetChannelTip)
	local selectedChannelId = self.curSelectedChannelId

	if shouldResetChannelTip then
		self.view.channelTipUWidget:SetActive(false)

		for _, channelTip in next, self.showChannelTip do
			if channelTip.timer then
				self.ctrl:killTimer(channelTip.timer)

				channelTip.timer = nil
			end
		end
	end

	if channelType == pg.game.chat.channelType.Friend then
		ClientTextUtils.setText(self.view.textTipsUSDFText, pg.getGameString("CHAT_FRIEND_CHANNEL_TIP"))
		self.view.channelTipUWidget:SetActive(true)

		return
	end

	local selectedChannelTip = self.showChannelTip[selectedChannelId]
	local hasShownChannelTip = selectedChannelTip and selectedChannelTip.alreadyShow == true

	if not shouldShowChannelTip or hasShownChannelTip then
		return
	end

	ClientTextUtils.setText(self.view.textTipsUSDFText, pg.getGameString("CHAT_PRIVATE_CHANNEL_TIP"))
	self.view.channelTipUWidget:SetActive(true)

	selectedChannelTip = {
		alreadyShow = true
	}
	self.showChannelTip[selectedChannelId] = selectedChannelTip
	selectedChannelTip.timer = self.ctrl:startTimer(function()
		selectedChannelTip.timer = nil

		if self.curSelectedChannelId == selectedChannelId then
			self.view.channelTipUWidget:SetActive(false)
		end
	end, ChannelTipShowTime)
end

function ChatComponent:isMessageOnlyChannelType(channelType)
	return channelType == pg.game.chat.channelType.System or channelType == pg.game.chat.channelType.Interact
end

function ChatComponent:isPrivateChannelType(channelType)
	return channelType == pg.game.chat.channelType.Player or channelType == pg.game.chat.channelType.Group
end

function ChatComponent:isPublicChannelType(channelType)
	return channelType == pg.game.chat.channelType.World or channelType == pg.game.chat.channelType.Near or channelType == pg.game.chat.channelType.Team or channelType == pg.game.chat.channelType.Home or channelType == pg.game.chat.channelType.Friend
end

function ChatComponent:handleNoticeChannelSelectedChanged(uList)
	if uList.selectedItem.type == pg.game.chat.channelType.System then
		ClientTextUtils.setText(self.view.txtEmptyUBaseText, pg.getGameString("CHAT_SYSTEM_NO_MESSAGE"))
	elseif uList.selectedItem.type == pg.game.chat.channelType.Interact then
		ClientTextUtils.setText(self.view.txtEmptyUBaseText, pg.getGameString("CHAT_INTERACT_NO_MESSAGE"))
	end
end

function ChatComponent:handleWorldChannelSelectedChanged(uList)
	local shouldShowChannelTip = false
	local isTeamChannelType = uList.selectedItem.type == pg.game.chat.channelType.Team
	local teamData = {}
	local isInTeam = pg.me:isInTeam()

	if isTeamChannelType then
		if isInTeam then
			for _, info in pairs(pg.me:getCurTeamInfo().membersInfo) do
				local data = {}

				data.headIcon = info.headIcon
				data.isTeamLeader = pg.me:isUidTeamLeader(info.uid)
				data.uid = info.uid

				table.insert(teamData, data)
			end

			local function sort(a, b)
				return a.isTeamLeader
			end

			self.view.txtNumUBaseText.text = #teamData .. "/4"

			table.sort(teamData, sort)
			self.view.listMembersUList:SetList(teamData)
			self.view.personalTopAddBtn.gameObject:SetActiveEx(#teamData < 4)
		else
			ClientTextUtils.setText(self.view.txtEmptyUBaseText, pg.getGameString("CHAT_NO_TEAM"))
			self.view.btnGoUButton:SetActive(true)
			ClientTextUtils.setText(self.view.btnGoTextUSDFText, pg.getGameString("GO_CREATE_TEAM"))
			self.view.bottomSendUComponent:SetActive(false)
			self.view.topInfoRectTransform.gameObject:SetActiveEx(false)
		end
	end

	if self.curSelectedChannelId == pg.game.chat.channelType.Friend then
		shouldShowChannelTip = true
	end

	if uList.selectedItem.type == pg.game.chat.channelType.Home and not pg.me.isHomeCampUnlocked then
		self.view.topInfoRectTransform.gameObject:SetActiveEx(false)
		ClientTextUtils.setText(self.view.txtEmptyUBaseText, pg.getGameString("CHAT_NO_HOME"))
		self.view.bottomSendUComponent.gameObject:SetActiveEx(false)
		self.view.btnGoUButton:SetActive(true)
		ClientTextUtils.setText(self.view.btnGoTextUSDFText, pg.getGameString("GO_CREATE_HOME"))
	end

	return shouldShowChannelTip
end

function ChatComponent:handlePrivateChannelSelectedChanged(uList)
	local shouldShowChannelTip = false
	local playerInfo = pg.game.chat:getPlayerInfo(uList.selectedItem.playerId)

	if playerInfo ~= nil then
		local friendShipLevel = pg.game.chat:getFriendship(uList.selectedItem.playerId)
		local hasFriendship = friendShipLevel and FriendshipLevelData[friendShipLevel]

		if hasFriendship then
			local friendshipIcon = FriendshipLevelData[friendShipLevel].levelIcon

			self.view.imgLikabilityUImage.url = friendshipIcon
		else
			shouldShowChannelTip = true
		end

		self.view.imgLikabilityUImage.gameObject:SetActiveEx(hasFriendship)

		local lastLogoutTime = LuaUIUtils.getLastTimeStr(playerInfo.lastLogoutTime)

		self.view.panelUComponent:TryChangePage("OnlineState", playerInfo.online and 0 or 1)
		ClientTextUtils.setText(self.view.playerStateUSDFText, playerInfo.online and pg.getGameString("ONLINE") or lastLogoutTime)
	else
		self.view.imgLikabilityUImage.gameObject:SetActiveEx(false)
	end

	return shouldShowChannelTip
end

function ChatComponent:refreshChannelList(curTab, selection)
	self.channelListData = self.model:getTabChannelListData(curTab)

	local isConsoleFamily = pg.global.platform:isConsoleFamily()

	if isConsoleFamily then
		self.isRefreshingChannelListSelection = true
	end

	self.view.channelListUList:SetList(self.channelListData)

	local channelCount = 0

	for _, data in ipairs(self.channelListData) do
		if data.tIndex == 0 and self:isPrivateChannelType(data.type) then
			channelCount = channelCount + 1
		end
	end

	ClientTextUtils.setText(self.view.expendNumUSDFText, pg.getFormatText(pg.getGameString("CURRENT_CHAT_EXPAND"), channelCount, PrivateChannelMaxCount))

	local selectedChannelIndex = self:resolveSelectedChannelIndex(selection)

	self.curSelectedChannel = selectedChannelIndex

	self:refreshChatInput(self.channelListData[selectedChannelIndex])

	if #self.channelListData > 0 then
		local selectItemIndex = selectedChannelIndex - 1

		if isConsoleFamily then
			self.view.channelListUList:SelectItem(selectItemIndex, false)
		else
			self.view.channelListUList:SelectItem(selectItemIndex)
		end

		self.view.channelListUList:GoToIndex(selectItemIndex, true)

		if isConsoleFamily then
			self.isRefreshingChannelListSelection = false

			if self.ctrl.expend then
				self:refreshChatMessageList()
			else
				self.view.channelListUList.luaSelectedChanged(self.view.channelListUList, true)
			end
		else
			self:refreshChatMessageList()
		end

		self.view.secondTabRectTransform.gameObject:SetActiveEx(true)
		self.view.privateUComponent:TryChangePage("PrivateState", 0)
	else
		if isConsoleFamily then
			self.isRefreshingChannelListSelection = false
		end

		self.view.noMessageRectTransform.gameObject:SetActiveEx(false)
		self.view.bottomSendUComponent.gameObject:SetActiveEx(false)
		self.view.topInfoRectTransform.gameObject:SetActiveEx(false)
		self.view.secondTabRectTransform.gameObject:SetActiveEx(false)
		self.view.privateUComponent:TryChangePage("PrivateState", 1)
		self.view.channelTipUWidget:SetActive(false)
		self.view.messageListUList:SetList({})

		self.curSelectedChannelId = -1
		self.curSelectedChannelType = nil
	end
end

function ChatComponent:resolveSelectedChannelIndex(selection)
	local selectedChannelIndex = tonumber(selection)

	if selectedChannelIndex == nil and not string.isNilOrEmpty(selection) then
		selectedChannelIndex = self.model:findChannelIndex(self.channelListData, selection)
	end

	local selectedChannelData = selectedChannelIndex and self.channelListData[selectedChannelIndex]
	local isInvalidSelection = selectedChannelIndex == nil or selectedChannelData == nil or selectedChannelData.type == nil

	if isInvalidSelection then
		selectedChannelIndex = self:getFirstSelectableChannelIndex()
	end

	local selectedChannel = self.channelListData[selectedChannelIndex]

	self.curSelectedChannelId = selectedChannel and (selectedChannel.channelId or selectedChannel.playerId) or -1

	return selectedChannelIndex
end

function ChatComponent:getFirstSelectableChannelIndex()
	for index, channelData in ipairs(self.channelListData) do
		if channelData.type ~= nil then
			return index
		end
	end

	return 1
end

function ChatComponent:refreshFriendState()
	local playerId = self.curSelectedChannelId

	if playerId ~= nil then
		local playerInfo = pg.game.chat:getPlayerInfo(playerId)

		if playerInfo then
			local isFriend = pg.game.chat:checkFriendList(playerId)

			self.view.chatBoxTopAddBtn.gameObject:SetActiveEx(not isFriend)

			local friendShipLevel = pg.game.chat:getFriendship(playerId)
			local hasFriendship = friendShipLevel and FriendshipLevelData[friendShipLevel]

			if hasFriendship then
				local friendshipIcon = FriendshipLevelData[friendShipLevel].levelIcon

				self.view.imgLikabilityUImage.url = friendshipIcon
			end

			self.view.imgLikabilityUImage.gameObject:SetActiveEx(hasFriendship)
		end
	end

	self:bindIntimacyButtonEvents()
end

local lastVisible = {}
local scrollCb

local function updateVisible(list, onEnter, onExit)
	local ok, minIndex, maxIndex = list:TryGetVisualRange()

	if not ok then
		return
	end

	local nowVisible = {}

	for i = minIndex, maxIndex do
		local okChild, btn = list:TryGetChildAt(i)

		if okChild and btn then
			nowVisible[i] = list.itemData[i]

			if lastVisible[i] ~= list.itemData[i] then
				onEnter(btn, i, list.itemData[i])
			end
		end
	end

	if onExit then
		for i, btn in pairs(lastVisible) do
			if nowVisible[i] == nil then
				onExit(btn, i)
			end
		end
	end

	lastVisible = nowVisible
end

function ChatComponent:bindVisibleWatcher(list, onEnter, onExit)
	function scrollCb(_)
		updateVisible(list, onEnter, onExit)
	end

	list:RegisterToScrollEvent(scrollCb)
	updateVisible(list, onEnter, onExit)
end

function ChatComponent:unbindVisibleWatcher(list)
	if scrollCb then
		list:UnRegisterToScrollEvent(scrollCb)

		scrollCb = nil
	end

	lastVisible = {}
end

function ChatComponent:enqueueAudioMessage(button, index, data)
	if data.playerId == pg.me.uid then
		return
	end

	if data.subType ~= pg.game.chat.subMessageType.Audio then
		return
	end

	if PlatformCommunicationService:isLocalCommunicationBlocked(PlatformCommunicationService.Channel.Voice) then
		return
	end

	local voiceInfo = type(data.extraInfo[Const.CHAT_EXTRA_TYPE.Voice]) == "table" and data.extraInfo[Const.CHAT_EXTRA_TYPE.Voice] or json.decode(data.extraInfo[Const.CHAT_EXTRA_TYPE.Voice])

	if not voiceInfo then
		return
	end

	local isAutoPlay = self:checkChannelSettingState(pg.game.chat.settingType.AudioPlay)
	local alreadyPlayed = pg.global.prefsCacheUtils:getBool(ClientConst.PrefKey.ChatAudioAlreadyPlayed .. pg.me.uid .. voiceInfo.fileID, false)

	if not isAutoPlay or alreadyPlayed then
		return
	end

	pg.global.gmeManager:PlayRecordedFileSequence(voiceInfo.fileID, self.curSelectedChannelId, function(code, filePath)
		pg.game.speech:onPlayFileComplete(filePath)
	end)
end

function ChatComponent:replyMessage(data)
	self.view.replyUWidget:SetActive(true)

	local playerInfo = pg.game.chat:getPlayerInfo(data.playerId)
	local playerName = LuaUIUtils.getPlayerDisplayName(data.playerId)
	local _h = ChatComponent._platformHooks

	playerName = _h and _h.replyMessageName and _h.replyMessageName(self, data, playerInfo, playerName) or playerName

	ClientTextUtils.setText(self.view.replyTextUSDFText, pg.getFormatText(pg.getGameString("CHAT_MESSAGE_REPLY_AND"), playerName))

	self.replyMsgInfo = {
		playerId = data.playerId,
		textContent = data.textContent,
		playerName = playerInfo.playerName,
		sourceSender = data.playerId,
		replyTarget = data.messageId
	}
	self.inputTextType = self.InputTextType.REPLY
end

function ChatComponent:reportChat(data)
	local reportInfo = self.ctrl:buildChatReportInfo(data)

	reportInfo.uid = reportInfo.uid or data.playerId
	reportInfo.name = LuaUIUtils.getPlayerDisplayName(data.playerId)
	reportInfo.character = reportInfo.character or reportInfo.name
	reportInfo.msgId = reportInfo.msgId or data.msgId or 0

	pg.global.ui:open(UIConst.UI_ID_ACCUSATION, {
		playerName = LuaUIUtils.getPlayerDisplayName(data.playerId),
		playerId = data.playerId,
		reportInfo = reportInfo,
		reportText = self.ctrl:getChatReportText(data)
	})
end

function ChatComponent:resetBottomInputState()
	self.view.replyUWidget:SetActive(false)

	self.showEmojiPanel = false

	self.view.emojiUWidget:SetActive(false)
	self:setAddPanelUWidgetActive(false)

	self.replyMsgInfo = nil
	self.inputTextType = nil
end

function ChatComponent:setAddPanelUWidgetActive(isActive)
	self.showAddPanel = isActive

	self.view.addPanelUWidget:SetActive(isActive)
end

function ChatComponent:tryPreloadInteractPlayerInfo(data)
	if self.curSelectedChannelId ~= pg.game.chat.channelType.Interact then
		return false
	end

	if self.interactPlayerInfoQuerying then
		return true
	end

	local requestedPlayerIds = self.interactPlayerInfoRequested or {}

	self.interactPlayerInfoRequested = requestedPlayerIds

	local playerIds = {}

	for _, messageData in ipairs(data or EMPTY_TABLE) do
		if messageData.tIndex == pg.game.chat.messageType.Interact then
			local playerId = self:getInteractMessagePlayerId(messageData)
			local needsPlayerInfo = not string.isNilOrEmpty(playerId) and pg.game.chat:getPlayerInfo(playerId) == nil and not requestedPlayerIds[playerId]

			if needsPlayerInfo then
				requestedPlayerIds[playerId] = true
				playerIds[#playerIds + 1] = playerId
			end
		end
	end

	if #playerIds == 0 then
		return false
	end

	self.interactPlayerInfoQuerying = true

	local function refreshAfterQuery()
		self.interactPlayerInfoQuerying = false

		local isInteractChannel = self.curSelectedChannelId == pg.game.chat.channelType.Interact

		if self.view == nil or not isInteractChannel then
			return
		end

		self:refreshChatMessageList()
	end

	local querySent = pg.game.chat:getBasicPlayerInfoListFromServer(playerIds, refreshAfterQuery)

	if querySent then
		return true
	end

	self.interactPlayerInfoQuerying = false

	for _, playerId in ipairs(playerIds) do
		requestedPlayerIds[playerId] = nil
	end

	return false
end

function ChatComponent:clearListeningStateListener()
	if not self.listeningStateListener then
		return
	end

	for fileID, listener in pairs(self.listeningStateListener) do
		pg.game.speech:removeListeningStateListener(listener)
	end

	self.listeningStateListener = {}
end

function ChatComponent:checkInviteCampUnlocked(inviteInfo)
	local _, _, sceneId, lineId = Utils.parseSpaceInstanceServiceKey(inviteInfo.campKey)
	local staticId = HomeLandUtils.getHomeCampStaticId(sceneId)
	local campInfo = HomeCampData[staticId] or {}

	if not ClientUtils.checkHomeCampUnlock(staticId) then
		if campInfo then
			pg.global.showBubbleMessage(NoticeDef.HOME_CAMP_INVITE_ACCEPT_NOT_UNLOCK_MAP, campInfo.name)
		end

		return false
	end

	return true
end

function ChatComponent:checkAndOpenCampInvite(inviteInfo)
	if not self:checkInviteCampUnlocked(inviteInfo) then
		return
	end

	if inviteInfo.isOwner then
		pg.global.ui.homeCampInviteCard:showOwnerInviteMessage({
			playerId = inviteInfo.playerId,
			campKey = inviteInfo.campKey,
			campUid = inviteInfo.campUid,
			inviteId = inviteInfo.inviteId
		})
	else
		pg.global.ui.homeCampInviteCard:showNormalInviteMessage({
			playerId = inviteInfo.playerId,
			campKey = inviteInfo.campKey,
			campUid = inviteInfo.campUid,
			inviteId = inviteInfo.inviteId
		})
	end
end

function ChatComponent:checkHomeCampInviteInfoState(data)
	local inviteTime = data.inviteTime
	local inviteId = data.inviteId
	local validTime = HomelandConfigData.HomeCampInviteValidTime or HomeCampConst.INVITE_CARD_EXPIRE_SECONDS

	if validTime > 0 then
		if not inviteTime then
			return false
		end

		if inviteTime + validTime <= Time.secondCache then
			return false
		end
	end

	local usedInviteIds = pg.me and pg.me.usedCampInviteIds

	if inviteId and usedInviteIds and usedInviteIds[tostring(inviteId)] then
		return false
	end

	return true
end

function ChatComponent:refreshChatMessageList(isNewMessage)
	local data = self:getChatMessageListData()
	local selectedItem = self.view.channelListUList.selectedItem

	if self.newMessageChannelId ~= self.curSelectedChannelId or self.needSetBottom then
		self:resetNewMessageCount()
	end

	self.newMessageChannelId = self.curSelectedChannelId

	if self:tryPreloadInteractPlayerInfo(data) then
		return
	end

	local hasRepeat = false

	for i = #data, 1, -1 do
		local lastMsgIndex = i - 1

		if i >= 3 and data[i - 1].tIndex == pg.game.chat.messageType.TimeStamp then
			lastMsgIndex = i - 2
		end

		if i >= 2 and self:checkIsRepeatMsg(data[i], data[lastMsgIndex]) and (i == #data or not self:checkIsRepeatMsg(data[i], data[i + 1])) and not hasRepeat then
			data[i].isRepeat = true
			hasRepeat = true
		else
			data[i].isRepeat = false
		end
	end

	self:refreshNewMessageTip(isNewMessage, #data)
	self:refreshNoMessageVisible(#data)

	local chatMsgType = pg.game.chat.messageType

	for _, messageData in ipairs(data) do
		local t = messageData.tIndex

		if t ~= chatMsgType.OtherPlayer and t ~= chatMsgType.SelfPlayer and t ~= chatMsgType.SystemNotice and t ~= chatMsgType.Tips then
			messageData.size = -1
		end
	end

	local showImportantSystemNoticeOnly = pg.global.prefsCacheUtils:getBool(pg.me.uid .. "ImportantSystemNotice", false)

	if showImportantSystemNoticeOnly and self.curSelectedChannelId == pg.game.chat.channelType.System then
		local systemMsg = {}

		for _, messageData in pairs(data) do
			if messageData.isImportantSystemNotice then
				table.insert(systemMsg, messageData)
			end
		end

		self.view.messageListUList:SetList(systemMsg)
	else
		self.view.messageListUList:SetList(data)
	end

	function self.view.messageListUList.luaFinishRender()
		self:refreshMessageListGamepadDefaultFocus()
	end

	if selectedItem and selectedItem.channelId then
		self.model:redDot_SetMessageNumb(selectedItem.channelId)

		local channelTypeInfo = pg.game.chat.channelTypeInfo[selectedItem.type]
		local channelTabType = channelTypeInfo.cate
		local treePath = string.format(RedDotConst.RedDotPath.CHAT_TAB_MESSAGE_LIST_ITEM, channelTabType, selectedItem.channelId)

		pg.global.refreshRedDotState(treePath)

		if channelTabType == pg.game.chat.tabType.Chat then
			pg.global.refreshRedDotState(RedDotConst.RedDotPath.CHAT_TAB_MESSAGE)
		elseif channelTabType == pg.game.chat.tabType.Notice then
			pg.global.refreshRedDotState(RedDotConst.RedDotPath.CHAT_TAB_NOTICE)
		end
	end
end

function ChatComponent:refreshNoMessageVisible(messageCount)
	local channelType = self.curSelectedChannelType
	local isInteractEmpty = channelType == pg.game.chat.channelType.Interact and messageCount == 0
	local isTeamUnavailable = channelType == pg.game.chat.channelType.Team and not pg.me:isInTeam()
	local isHomeUnavailable = channelType == pg.game.chat.channelType.Home and not pg.me.isHomeCampUnlocked
	local shouldShow = isInteractEmpty or isTeamUnavailable or isHomeUnavailable

	self.view.noMessageRectTransform.gameObject:SetActiveEx(shouldShow)
end

function ChatComponent:refreshNewMessageTip(isNewMessage, messageCount)
	if not isNewMessage or self.needSetBottom then
		return
	end

	local isAwayFromBottom = messageCount > 7 and self.view.messageListUList.normalizedScrollPosition.y > self.bottomViewHeight

	if not isAwayFromBottom then
		self:resetNewMessageCount()

		self.needSetBottom = true

		return
	end

	self.newMessageCount = self.newMessageCount + 1

	self.view.bottomSendUComponent:TryChangePage("ClickToNew", 1)
	ClientTextUtils.setText(self.view.txtNewMsgUSDFText, pg.getFormatText(pg.getGameString("CHAT_MACH_MESSAGE"), self.newMessageCount))
end

function ChatComponent:resetNewMessageCount()
	self.newMessageCount = 0

	self.view.bottomSendUComponent:TryChangePage("ClickToNew", 0)
end

function ChatComponent:refreshChannelListGamepadDefaultFocus()
	local selectedIndex = self.view.channelListUList.selectedIndex

	if selectedIndex < 0 then
		return
	end

	local res, btn = self.view.channelListUList:TryGetChildAt(selectedIndex)

	if res then
		self.view.channelListUList:SetNavGroupDefaultItemInThis(btn)
	end
end

function ChatComponent:refreshMessageListGamepadDefaultFocus()
	local list = self:getChatMessageListData()
	local defaultItem

	for i = #list, 1, -1 do
		local res, btn = self.view.messageListUList:TryGetChildAt(i - 1)

		if res then
			defaultItem = btn

			break
		end
	end

	self.view.messageListUList:SetNavGroupDefaultItemInThis(defaultItem)
end

function ChatComponent:refreshFriendCustomInfo()
	self:refreshChatMessageList()
	self:refreshChatMessageTitle(self.view.channelListUList.selectedItem)
end

function ChatComponent:refreshPlayerSpark()
	self.view.channelListUList:RefreshList()
	self.view.messageListUList:RefreshList()
end

function ChatComponent:tryRefreshChatMessageItem(msgId)
	if msgId == nil then
		return false
	end

	local showImportantSystemNoticeOnly = pg.global.prefsCacheUtils:getBool(pg.me.uid .. "ImportantSystemNotice", false)

	if showImportantSystemNoticeOnly and self.curSelectedChannelId == pg.game.chat.channelType.System then
		return false
	end

	local index = pg.game.chat:getMessageIndex(self.curSelectedChannelId, msgId)
	local chatMessageList = self:getChatMessageListData()
	local data = index and chatMessageList[index] or nil

	if not data then
		return false
	end

	self.view.messageListUList:RefreshElement(index - 1)

	return true
end

function ChatComponent:checkIsRepeatMsg(msg1, msg2)
	if msg1.tIndex ~= pg.game.chat.messageType.OtherPlayer and msg1.tIndex ~= pg.game.chat.messageType.SelfPlayer or msg2.tIndex ~= pg.game.chat.messageType.OtherPlayer and msg2.tIndex ~= pg.game.chat.messageType.SelfPlayer then
		return false
	end

	if not self:checkTextCanRepeat(msg1.extraInfo) or not self:checkTextCanRepeat(msg2.extraInfo) then
		return false
	end

	if msg1.textContent == msg2.textContent and not string.isNilOrEmpty(msg1.textContent) and not string.isNilOrEmpty(msg2.textContent) then
		return true
	end

	return false
end

function ChatComponent:getChatMessageListData()
	local data = pg.game.chat:getChatMessageListData()

	return data[self.curSelectedChannelId] or {}
end

function ChatComponent:initBottomExpandPanel()
	function self.view.btnBottomAddUButton.luaClick()
		self.view.emojiUWidget:SetActive(false)

		self.showEmojiPanel = false

		self:setAddPanelUWidgetActive(not self.showAddPanel)
	end

	function self.view.btnBottomEmojiUButton.luaClick()
		if self.showEmojiPanel then
			self.showEmojiPanel = false
		else
			self.showEmojiPanel = true
		end

		self.view.emojiUWidget:SetActive(self.showEmojiPanel)
		self.view.addPanelUWidget:SetActive(false)
		self:setAddPanelUWidgetActive(false)
		self.view.listEmojiUList:RefreshList()
	end

	function self.view.listEmojiUList.luaRenderItem(button, index, data)
		self:onRenderEmojiItem(button, index, data)
	end

	function self.view.listEmojiTabUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")

		iconUImage.url = data.tabRes
	end

	function self.view.listEmojiTabUList.luaSelectedChanged(uList, selected)
		self.view.listEmojiUList:SetList(uList.selectedItem.emojiList)
	end

	function self.view.extendFuncList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local imageIconUImage = objectReference:GetRefValue("imageIconUImage")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		imageIconUImage.url = data.icon

		ClientTextUtils.setText(txtNameUSDFText, pg.getGameString(data.label))

		function button.luaClick()
			self[data.func](self)
		end
	end

	self.positionData = {
		{
			icon = "$UI_Img_Inventory_TabIcon_Place.png",
			func = "copyLocationText",
			label = "LOCATION"
		},
		{
			icon = "$UI_Img_Inventory_TabIcon_Pet.png",
			func = "showPetInfoPanel",
			label = "PET"
		},
		{
			icon = "$UI_Img_Inventory_TabIcon_2.png",
			func = "showItemInfoPanel",
			label = "PROP"
		},
		{
			icon = "$UI_Img_Inventory_TabIcon_History.png",
			func = "showHistoryMessagePanel",
			label = "HISTORY_MESSAGE"
		},
		{
			icon = "$UI_Img_ChatPanel_Pet_Photograph.png",
			func = "showAlbumPanel",
			label = "PICTURE"
		},
		{
			func = "showFriendCardPanel",
			checkShowFunc = "checkFriendCardShow",
			icon = "$UI_Img_ChatPanel_Pet_Crad.png",
			label = "FRIEND_CARD",
			channelTypes = {
				pg.game.chat.channelType.Friend,
				pg.game.chat.channelType.Team,
				pg.game.chat.channelType.Player
			}
		}
	}

	self:setEmojiList()
end

function ChatComponent:checkFriendCardShow(channelType)
	if channelType ~= pg.game.chat.channelType.Player then
		return true
	end

	return pg.game.chat:checkFriendList(self.curSelectedChannelId)
end

function ChatComponent:refreshPositionData(channelType)
	local filteredPositionData = {}
	local channelTypes, isChannelMatched, canShow

	for _, data in ipairs(self.positionData) do
		channelTypes = data.channelTypes
		isChannelMatched = channelTypes == nil or table.contains(channelTypes, channelType)
		canShow = data.checkShowFunc == nil or self[data.checkShowFunc](self, channelType)

		if isChannelMatched and canShow then
			filteredPositionData[#filteredPositionData + 1] = data
		end
	end

	self.view.extendFuncList:SetList(filteredPositionData)
end

function ChatComponent:setEmojiList()
	local emojiData = {}

	for index, data in ipairs(ChatEmojiData) do
		if not data.itemId or data.itemId and ClientUtils.getItemCountById(data.itemId, true) > 0 then
			if not emojiData[data.emojiTab] then
				emojiData[data.emojiTab] = {
					emojiList = {}
				}
			end

			table.insert(emojiData[data.emojiTab].emojiList, {
				index = index,
				emojiCfg = data
			})
		end
	end

	local ret = {}

	for index, tab in pairs(emojiData) do
		tab.emojiTab = index
		tab.tabRes = ChatEmojiTabData[index].tabRes
		tab.tIndex = 1
		ret[#ret + 1] = tab
	end

	ret[1].tIndex = 0

	if #ret > 1 then
		ret[#ret].tIndex = 2
	end

	self.view.listEmojiTabUList:SetList(ret)
	self.view.listEmojiTabUList:SelectItem(0)
end

function ChatComponent:copyLocationText()
	local curSelectedChannelData = self.view.channelListUList.selectedItem

	if not pg.game.chat:checkCanSendMessage(curSelectedChannelData.type, self.curSelectedChannelId, true) then
		return
	end

	self:checkSendButtonState()
	self:resetBottomInputState()
	pg.me:chatSendPositionCard(curSelectedChannelData.type, self.curSelectedChannelId)
end

function ChatComponent:showPetInfoPanel()
	self:resetBottomInputState()
	self.ctrl.petShareComponent:refreshPetList(1)
end

function ChatComponent:showHistoryMessagePanel()
	self:resetBottomInputState()
	self.ctrl.historyComponent:refreshHistoryInformationList(self.curSelectedChannelId)
end

function ChatComponent:showItemInfoPanel()
	self:resetBottomInputState()
	self.ctrl.itemComponent:refreshItemList()
end

function ChatComponent:showAlbumPanel()
	self:resetBottomInputState()
	pg.global.ui.album:open({
		investigation = true,
		mode = AlbumCtrl.Mode.ChatPicture,
		investigateCb = function(templateIds, path, timeStamp, position, sceneId, genderInfos, photoInfo)
			self:sendAlbumPicture(photoInfo or {
				templateIds = templateIds,
				path = path,
				timeStamp = timeStamp,
				position = position,
				sceneId = sceneId,
				templateGenders = genderInfos
			})
		end
	})
end

function ChatComponent:showFriendCardPanel()
	self:resetBottomInputState()

	local friendCardOpenType = self.ctrl.friendNewComponent.OpenType.FriendCard

	self.ctrl.friendNewComponent:refreshFriendList(friendCardOpenType)
end

function ChatComponent:isAlbumPictureSelectable(photoInfo)
	if not photoInfo then
		return false
	end

	return photoInfo.isInRes and not string.isNilOrEmpty(photoInfo.resId) or photoInfo.isOSS and not string.isNilOrEmpty(photoInfo.ossPhotoKey) or not string.isNilOrEmpty(photoInfo.path) and not photoInfo.photoId
end

function ChatComponent:getAlbumPictureExtraInfo(photoInfo, imgKey)
	local pictureInfo = {
		title = pg.getGameString("PHOTO"),
		timeStamp = photoInfo.timeStamp,
		position = photoInfo.position,
		sceneId = photoInfo.sceneId
	}

	if photoInfo.isInRes then
		pictureInfo.url = photoInfo.resId
		pictureInfo.isInRes = true
		pictureInfo.resId = photoInfo.resId
	else
		pictureInfo.imgKey = imgKey
		pictureInfo.templateIds = photoInfo.templateIds
	end

	return {
		[Const.CHAT_EXTRA_TYPE.Picture] = pictureInfo
	}
end

function ChatComponent:onSendAlbumPictureFailed()
	self._isUploadingAlbumPicture = false

	pg.global.showBubbleMessageRaw(pg.getGameString("FAILED"))
end

function ChatComponent:sendAlbumPictureByKey(photoInfo, pictureKey)
	self._isUploadingAlbumPicture = false

	if string.isNilOrEmpty(pictureKey) then
		self:onSendAlbumPictureFailed()

		return
	end

	local extraInfo = self:getAlbumPictureExtraInfo(photoInfo, pictureKey)

	self:sendMessage(pg.getGameString("PHOTO"), pg.game.chat.subMessageType.Picture, nil, nil, extraInfo)
end

function ChatComponent:uploadAlbumPictureSprite(photoInfo, sprite)
	if not sprite then
		self:onSendAlbumPictureFailed()

		return
	end

	pg.me:addPhotoImgSprite(sprite, function(key, result)
		pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)

		if result == true then
			self:sendAlbumPictureByKey(photoInfo, key)
		else
			self:onSendAlbumPictureFailed()
		end
	end)
end

function ChatComponent:sendAlbumPicture(photoInfo)
	if self._isUploadingAlbumPicture then
		return
	end

	if not self:isAlbumPictureSelectable(photoInfo) then
		self:onSendAlbumPictureFailed()

		return
	end

	if photoInfo.isInRes then
		local extraInfo = self:getAlbumPictureExtraInfo(photoInfo)

		self:sendMessage(pg.getGameString("PHOTO"), pg.game.chat.subMessageType.Picture, nil, nil, extraInfo)

		return
	end

	self._isUploadingAlbumPicture = true

	if photoInfo.isOSS then
		pg.me:getOSSPhotoPictureKey(photoInfo.ossPhotoKey, function(pictureKey)
			self:sendAlbumPictureByKey(photoInfo, pictureKey)
		end)

		return
	end

	local sprite = pg.global.mobileCameraMgr:GetSpriteByFilePath(photoInfo.path)

	self:uploadAlbumPictureSprite(photoInfo, sprite)
end

function ChatComponent:sendFriendCard(playerId)
	if string.isNilOrEmpty(playerId) then
		return
	end

	self:sendMessage(pg.getGameString("FRIEND_CARD"), pg.game.chat.subMessageType.FriendCard, nil, nil, {
		[Const.CHAT_EXTRA_TYPE.FriendCard] = playerId
	})
end

function ChatComponent:initChatInput()
	function self.view.chatUInputField.luaEndEdit(text)
		self.view.btnConfirmUButton.luaClick()
	end

	function self.view.chatUInputField.luaValueChanged(text)
		local validText = ClientTextUtils.getValidName(text, SysConfigData.CHAT_LIMIT_MAX or 50)

		self.view.chatUInputField:SetTextWithoutNotify(validText)
	end

	function self.view.btnConfirmUButton.luaClick()
		local inputText = self.view.chatUInputField.text

		if inputText == "" then
			return
		end

		if self.inputTextType == self.InputTextType.REPLY then
			self:sendMessage(inputText, pg.game.chat.subMessageType.Text, nil, nil, {
				[Const.CHAT_EXTRA_TYPE.Reply] = self.replyMsgInfo
			})
		else
			self:sendMessage(inputText, pg.game.chat.subMessageType.Text)
		end

		ClientTextUtils.setText(self.view.chatUInputField, "")
		self.ctrl:tryFocusChatInputField(true)
	end

	local objectReference = self.view.btnConfirmUButton:GetComponent("ObjectReference")

	self.confirmButtonText = objectReference:GetRefValue("txtNameUText")

	ClientTextUtils.setText(self.view.textVoiceUSDFText, pg.getGameString("VOICE_RECORD_BUTTON"))
end

function ChatComponent:sendMessage(originText, messageType, channelType, channelId, extraInfo)
	self.needSetBottom = true

	if self.view then
		local curSelectedChannelData = self.view.channelListUList.selectedItem

		channelType = curSelectedChannelData.type
		channelId = curSelectedChannelData.channelId or curSelectedChannelData.playerId
	end

	pg.game.chat:sendMessage(originText, messageType, channelType, channelId, extraInfo)
	self:checkSendButtonState()
	self:resetBottomInputState()
end

function ChatComponent:refreshChatMessageTitle(channelInfo)
	if channelInfo == nil or channelInfo.tIndex ~= 0 then
		return
	end

	local playerId = channelInfo.playerId
	local channelName = channelInfo.label

	if channelInfo.type == pg.game.chat.channelType.World then
		channelName = pg.game.chat:getWorldChatChannelName(channelInfo.channelId, channelInfo.groupBase, channelInfo.label)
	elseif playerId == nil then
		channelName = pg.getGameString(channelInfo.label)
	end

	if playerId ~= nil then
		self.view.panelUComponent:TryChangePage("isChange", pg.game.chat.specialFriendUId == playerId and 1 or 0)

		local isFriend = pg.game.chat:checkFriendList(playerId)

		self.view.chatBoxTopAddBtn.gameObject:SetActiveEx(not isFriend)

		if not isFriend then
			if not pg.game.chat:checkAddFriendCD(playerId) then
				self.view.chatBoxTopAddBtn:TryChangePage("button", 4)

				self.view.chatBoxTopAddBtn.interactable = false
			else
				self.view.chatBoxTopAddBtn:TryChangePage("button", 0)

				self.view.chatBoxTopAddBtn.interactable = true
			end

			function self.view.chatBoxTopAddBtn.luaClick()
				self.view.chatBoxTopAddBtn:TryChangePage("button", 4)

				self.view.chatBoxTopAddBtn.interactable = false

				pg.game.chat:applyFriend(playerId, pg.game.chat.AddFriendSource.ChatChannel, pg.getGameString("CHAT_CHANNEL_PRIVATE"))
			end
		end

		local playerInfo = pg.game.chat:getPlayerInfo(channelInfo.playerId)

		if playerInfo then
			channelName = LuaUIUtils.getPlayerDisplayName(channelInfo.playerId, playerInfo.playerName)

			local _h = ChatComponent._platformHooks

			if _h and _h.refreshChatMessageTitleName then
				channelName = _h.refreshChatMessageTitleName(self, channelInfo, playerInfo, channelName) or channelName
			end
		end
	else
		self.view.panelUComponent:TryChangePage("isChange", 0)
		self.view.chatBoxTopAddBtn.gameObject:SetActiveEx(false)

		if not self:isPublicChannelType(channelInfo.type) then
			local _h = ChatComponent._platformHooks

			channelName = _h and _h.refreshChatMessageTitleName and _h.refreshChatMessageTitleName(self, channelInfo, nil, channelName) or channelName
		end
	end

	self.currentChannelDisplayName = channelName

	ClientTextUtils.setText(self.view.channelNameUText, channelName)
	ClientTextUtils.setText(self.view.txtNameChangeUSDFText, channelName)
	ClientTextUtils.setText(self.view.nameCoverUSDFText, channelName)

	local playerTitle = self.view.channelNameUText:GetChild("Emblem")

	LuaUIUtils.setUIViewVisible(playerTitle, channelInfo.playerId ~= nil)
end

function ChatComponent:refreshChatInput(channelInfo)
	if channelInfo then
		self:refreshChatInformVisible(channelInfo)

		local enableChat = true
		local isNoticeChannel = channelInfo.type == pg.game.chat.channelType.System or channelInfo.type == pg.game.chat.channelType.Interact

		if isNoticeChannel then
			enableChat = false
		end

		self.view.bottomSendUComponent:TryChangePage("Disable", enableChat and 0 or 1)
	end
end

function ChatComponent:refreshChatInformVisible(channelInfo)
	if not self.view.chatInformUWidget then
		return
	end

	local visible = channelInfo and channelInfo.type == pg.game.chat.channelType.System

	self.view.chatInformUWidget:SetActive(visible)
end

function ChatComponent:tryRefreshChannelLastMessage(curChannelId)
	for i = 1, #self.channelListData do
		local channelData = self.channelListData[i]
		local channelId = channelData.channelId or channelData.playerId

		if channelId == curChannelId then
			local isExist, button = self.view.channelListUList:TryGetChildAt(i - 1)

			if isExist then
				self:renderChannelLastMessage(button, pg.game.chat:getChannelLastMessage(curChannelId))
			end

			break
		end
	end
end

function ChatComponent:renderChannelLastMessage(button, messageInfo)
	local lastText = button:GetChild("LastText"):GetComponent("UBaseText")
	local lastMessageStr = ""
	local senderInfo

	if messageInfo == nil then
		ClientTextUtils.setText(lastText, "")
	else
		if messageInfo.channelType == pg.game.chat.channelType.Group then
			senderInfo = pg.game.chat:getPlayerInfo(messageInfo.playerId)

			if senderInfo and senderInfo.playerName then
				local senderPlayerName = senderInfo.playerName
				local _h = ChatComponent._platformHooks

				senderPlayerName = _h and _h.renderChannelLastMessagePlayerName and _h.renderChannelLastMessagePlayerName(self, button, messageInfo, senderInfo, senderPlayerName) or senderPlayerName
				lastMessageStr = senderPlayerName .. ":"
			end
		end

		local subType = messageInfo.subType
		local isContentMessage = subType == pg.game.chat.subMessageType.Text or subType == pg.game.chat.subMessageType.Audio or subType == pg.game.chat.subMessageType.FriendCard or subType == pg.game.chat.subMessageType.Picture or subType == pg.game.chat.subMessageType.JumpShared or subType == pg.game.chat.subMessageType.HomeSeasonMutationGift

		if isContentMessage then
			if messageInfo.extraInfo then
				local extraText = pg.game.chat:getTextContentFromExtraInfo(messageInfo.extraInfo)

				lastMessageStr = lastMessageStr .. (extraText or messageInfo.textContent)
			else
				lastMessageStr = lastMessageStr .. messageInfo.textContent
			end
		elseif messageInfo.subType == pg.game.chat.subMessageType.Emoji then
			lastMessageStr = lastMessageStr .. pg.getGameString("CHAT_BUBBLE_EMOJI")
		elseif messageInfo.subType == pg.game.chat.subMessageType.DungeonInvite then
			lastMessageStr = lastMessageStr .. pg.getGameString("TEAM_INVITE")
		elseif messageInfo.subType == pg.game.chat.subMessageType.PhotographyStudioInvite then
			lastMessageStr = lastMessageStr .. pg.getGameString("PHOTO_STUDIO_CHAT_INVITE_MESSAGE")
		end
	end

	ClientTextUtils.setText(lastText, lastMessageStr)
end

function ChatComponent:openSwitchChannelPanel()
	local channelData = self.view.channelListUList.selectedItem

	self.ctrl.switchChannelComponent:refreshChannelList(channelData.groupBase, channelData.channelId)
end

function ChatComponent:openTeamGameplayPanel()
	pg.global.ui:open(UIConst.UI_ID_TEAM_ROOM_DUNGEON_SELECT)
end

function ChatComponent:removeChannel(channelId)
	channelId = channelId or self.curSelectedChannelId

	pg.game.chat:removeChannel(channelId)
	self.view.channelTipUWidget:SetActive(false)

	if self.showChannelTip[channelId] and self.showChannelTip[channelId].timer then
		self.ctrl:killTimer(self.showChannelTip[channelId].timer)

		self.showChannelTip[channelId].timer = nil
	end
end

function ChatComponent:setChatOnTop(isTop)
	if isTop then
		pg.game.chat:addTopChannel(self.curSelectedChannelId)
	else
		pg.game.chat:removeTopChannel(self.curSelectedChannelId, true)
	end
end

function ChatComponent:openGroupChatManage()
	pg.global.ui:open(UIConst.UI_ID_FRIEND_GROUP_SETUP, {
		groupId = self.curSelectedChannelId
	})
end

function ChatComponent:checkChatOnTop()
	return pg.game.chat:checkTopChannel(self.curSelectedChannelId)
end

function ChatComponent:setRemark()
	local playerId = tostring(self.curSelectedChannelId)
	local initialInputText = tostring(self.currentChannelDisplayName or "")

	pg.global.ui:open(UIConst.UI_ID_CHANGE_NAME, {
		editType = 1,
		initialInputText = initialInputText,
		playerId = playerId
	})
end

function ChatComponent:changeFriendGroup()
	local friendGroupList = pg.game.chat:getFriendGroupList()

	if #friendGroupList <= 2 then
		pg.global.showBubbleMessageRaw(pg.getGameString("NO_EXTRA_FRIEND_GROUP"))

		return
	end

	pg.global.ui:open(UIConst.UI_ID_FRIEND_SETUP, {
		playerId = self.curSelectedChannelId,
		setupType = pg.global.ui.friendSetup.model.FriendSetupType.ChangeGroup
	})
end

function ChatComponent:setChannelSettingState(isOn, settingType)
	pg.game.chat:setChatSettingState(self.curSelectedChannelType, settingType, isOn, self.curSelectedChannelId)
end

function ChatComponent:checkChannelSettingState(settingType)
	return pg.game.chat:checkChatSettingState(self.curSelectedChannelType, settingType, self.curSelectedChannelId)
end

function ChatComponent:setChannelSettingStateById(isOn, settingType)
	local keyId = pg.me.uid .. ClientConst.PrefKey.ChatChannelSetting .. settingType .. self.curSelectedChannelId
	local newValue = isOn and 1 or 0

	pg.global.prefsCacheUtils:setInt(keyId, newValue)
end

function ChatComponent:checkChannelSettingStateById(settingType)
	local keyId = pg.me.uid .. ClientConst.PrefKey.ChatChannelSetting .. settingType .. self.curSelectedChannelId
	local savedValue = pg.global.prefsCacheUtils:getInt(keyId, 0)

	return savedValue == 1
end

function ChatComponent:checkSendButtonState()
	local sendCD = pg.game.chat:getWorldMessageCD()

	self:setSendButtonState(sendCD)

	local isWorldChannel = pg.game.chat:isWorldChatGroupId(self.curSelectedChannelId)

	if sendCD > 0 and isWorldChannel and not self.confirmTimer then
		local function updateSendButtonState()
			sendCD = pg.game.chat:getWorldMessageCD()

			self:setSendButtonState(sendCD)
		end

		self.confirmTimer = self.ctrl:startTimer(updateSendButtonState, 1, true)
	end
end

function ChatComponent:setSendButtonState(sendCD)
	local isWorldChannel = pg.game.chat:isWorldChatGroupId(self.curSelectedChannelId)

	if not isWorldChannel then
		self.view.btnConfirmUButton.interactable = true

		ClientTextUtils.setText(self.confirmButtonText, pg.getGameString("SEND"))

		if self.confirmTimer then
			self.ctrl:killTimer(self.confirmTimer)

			self.confirmTimer = nil
		end

		return
	end

	if sendCD <= 0 then
		self.view.btnConfirmUButton.interactable = true

		ClientTextUtils.setText(self.confirmButtonText, pg.getGameString("SEND"))

		if self.confirmTimer then
			self.ctrl:killTimer(self.confirmTimer)

			self.confirmTimer = nil
		end

		return
	end

	self.view.btnConfirmUButton.interactable = false

	ClientTextUtils.setText(self.confirmButtonText, sendCD)
end

function ChatComponent:onRenderEmojiItem(button, index, itemData)
	local objectReference = button:GetComponent("ObjectReference")
	local emojiUContainer = objectReference:GetRefValue("emojiUContainer")
	local imgEmojiUImage = objectReference:GetRefValue("imgEmojiUImage")
	local emojiScaleDownAdapter = emojiUContainer.transform:GetComponent("UIScaleDownAdapter")
	local data = itemData.emojiCfg
	local isEmoji = not data.emojiType or data.emojiType and data.emojiType ~= 1

	emojiUContainer.gameObject:SetActiveEx(isEmoji)
	imgEmojiUImage.gameObject:SetActiveEx(not isEmoji)

	if isEmoji then
		emojiUContainer:SetUrlWithCallback(data.res, function(content)
			local contentReference = content:GetComponent("ObjectReference")

			if contentReference then
				local widgetAnimation = contentReference:GetRefValue("widgetAnimation")

				if widgetAnimation then
					emojiScaleDownAdapter.targetTransform = widgetAnimation.transform
				end
			end

			content:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		end)
	else
		imgEmojiUImage.url = data.res
	end

	function button.luaClick()
		self:sendMessage(data.res, pg.game.chat.subMessageType.Emoji, nil, nil, {
			[Const.CHAT_EXTRA_TYPE.Emoji] = data.res,
			emojiType = data.emojiType
		})
	end
end

function ChatComponent:redDot_RefreshChannelList()
	self.view.channelListUList:RefreshList()
end

function ChatComponent:onClose()
	self:resetCurrentPageTranslationState()

	local channelRecordKey = pg.me.uid .. ClientConst.PrefKey.ChatChannelRecord
	local selectedItem = self.view.channelListUList.selectedItem
	local selectionKey = self.model:getChannelSelectionKey(selectedItem) or ""
	local isNonChannelTab = self.ctrl.curTabType == pg.game.chat.tabType.Friend or self.ctrl.curTabType == pg.game.chat.tabType.Mail

	if isNonChannelTab then
		selectionKey = ""
	end

	local channelRecord = "v2|" .. self.ctrl.curTabType .. "|" .. selectionKey

	pg.global.prefsCacheUtils:setString(channelRecordKey, channelRecord)

	self.pendingPetCardContext = nil
	self.petCardLikeContext = nil
	self.inLoadPetCardUIScene = false
	self.pictureSpriteInfoMap = nil

	if self.petCardUIScene then
		self.petCardUIScene:removeUICtrlKey(self.ctrl.module)

		local hasCtrlBind = self.petCardUIScene:checkHasUICtrlBind()

		pg.game.uiScene:switchOutScene(UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE, hasCtrlBind, nil, self.ctrl.module)

		self.petCardUIScene = nil
	end

	if self.confirmTimer then
		self.ctrl:killTimer(self.confirmTimer)

		self.confirmTimer = nil
	end

	for _, channelTipInfo in pairs(self.showChannelTip) do
		self.ctrl:killTimer(channelTipInfo.timer)

		channelTipInfo.timer = nil
	end

	self:cancelSpeechRecording()

	self.speechComponent = nil

	pg.game.speech:stopPlayAudioFile()
	self:unbindVisibleWatcher(self.view.messageListUList)
	self:clearListeningStateListener()
	self:clearDungeonInviteRefreshState()
end

function ChatComponent:clearDungeonInviteRefreshState()
	self.dungeonInviteRefreshEnabled = false

	if self.dungeonInviteRefreshTimer then
		self:killTimer(self.dungeonInviteRefreshTimer)

		self.dungeonInviteRefreshTimer = nil
	end

	if self.dungeonInviteListRefreshTimer then
		self:killTimer(self.dungeonInviteListRefreshTimer)

		self.dungeonInviteListRefreshTimer = nil
	end

	self.dungeonInviteMemberQueries = {}
	self.dungeonInviteMemberCounts = {}
	self.dungeonInviteMemberCountTimes = {}
	self.pendingDungeonInviteClick = nil
end

function ChatComponent:onInputDeviceChanged()
	self:endSpeaking()
	self.view.bottomSendUComponent:TryChangePage("Switch", 0)
	self:bindIntimacyButtonEvents()
end

return ChatComponent
