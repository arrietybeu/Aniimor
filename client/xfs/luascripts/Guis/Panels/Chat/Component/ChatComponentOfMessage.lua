-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Chat\\Component\\ChatComponentOfMessage.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local ChatComponent = require("Guis.Panels.Chat.Component.ChatComponent")
local ChatSystem = require("GameApp.Chat.ChatSystem")
local CallbackHandler = require("Core.Common.CallbackHandler")
local AbilityConst = require("Common.Const.AbilityConst")
local AttributeConst = require("Common.Const.AttributeConst")
local Const = require("Common.Const.Const")
local AppearanceVariableData = require("Data.appearance_variable_data")
local CardBackgroundData = require("Data.card_background_data")
local LevelData = require("Data.level_data")
local PlayerHeadFrameData = require("Data.player_head_frame_data")
local PlayerHeadIconData = require("Data.player_head_icon_data")
local AddressDataConst = require("Const.AddressDataConst")
local HotkeyConst = require("Const.HotkeyConst")
local MatchConst = require("Common.Const.MatchConst")
local UIConst = require("Const.UIConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local SysConfigData = require("Data.sys_config_data")
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HomeSeasonUtils = require("Utils.HomeSeasonUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local PetManagementUtils = require("Utils.PetManagementUtils")
local Utils = require("Common.Utils.Utils")
local json = require("json")
local NoticeDef = require("Common.NoticeDef")
local MessageName = require("Const.MessageName")
local PhotographyStudioUtils = require("Utils.PhotographyStudioUtils")
local PetInfoCardDisplayUtils = require("Guis.Utils.PetInfoCardDisplayUtils")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local PetCardSceneTextureWidth = 1024
local PetCardSceneTextureHeight = 1024
local PetCardSceneParams = {
	textureWidth = PetCardSceneTextureWidth,
	textureHeight = PetCardSceneTextureHeight
}
local MessageListScrollEpsilon = 0.1
local WordSizeOptions = {
	Big = 2,
	Normal = 1
}
local MessageWordType = {
	Reply = 2,
	Normal = 1
}
local HomeSeasonMutationGiftState = {
	Gifted = 2,
	CanGift = 1,
	NoButton = 0
}
local SubMessageType = ChatSystem.subMessageType
local playerMessagePageTypeMap = {
	[SubMessageType.Text] = 0,
	[SubMessageType.Audio] = 1,
	[SubMessageType.Emoji] = 2,
	[SubMessageType.DungeonInvite] = 3,
	[SubMessageType.PVPInvite] = 3,
	[SubMessageType.EnterWorld] = 3,
	[SubMessageType.Team] = 3,
	[SubMessageType.HomeCampInvite] = 3,
	[SubMessageType.Picture] = 10,
	[SubMessageType.FriendCard] = 9,
	[SubMessageType.JumpShared] = 5,
	[SubMessageType.PhotographyStudioInvite] = 3,
	[SubMessageType.HomeSeasonCelebrationInvite] = 3,
	[SubMessageType.HomeSeasonMutationGift] = 6,
	[SubMessageType.Gift] = 11
}
local WordSize = {
	[MessageWordType.Normal] = {
		[WordSizeOptions.Normal] = 60,
		[WordSizeOptions.Big] = 72
	},
	[MessageWordType.Reply] = {
		[WordSizeOptions.Normal] = 56,
		[WordSizeOptions.Big] = 68
	}
}

local function findHyperlinkButton(contentRect, fallbackButton)
	local current = contentRect

	while current do
		local button = current:GetComponent("UButton")

		if button then
			return button
		end

		current = current.parent
	end

	return fallbackButton
end

function ChatComponent:initChatMessageList()
	self:resetNewMessageCount()

	function self.view.messageListUList.luaDynamicRenderItem(button, index, data)
		self:renderMessageItemLayout(button, index, data)
	end

	function self.view.messageListUList.luaRenderItem(button, index, data)
		self:renderMessageItemLayout(button, index, data)

		if data.tIndex == pg.game.chat.messageType.OtherPlayer or data.tIndex == pg.game.chat.messageType.SelfPlayer then
			local objectReference = button:GetComponent("ObjectReference")
			local textUButton = objectReference:GetRefValue("textUButton")
			local textObjectReference = textUButton:GetComponent("ObjectReference")
			local btnAddUButton = textObjectReference:GetRefValue("btnAddUButton")
			local avatarUButton = objectReference:GetRefValue("avatarUButton")
			local playerInfo = pg.game.chat:getPlayerInfo(data.playerId)

			LuaUIUtils.renderPlayerAvatarButton(avatarUButton, {
				hideLevel = true,
				playerId = data.playerId,
				playerInfo = playerInfo,
				avatarType = LuaUIUtils.PLAYER_AVATAR_TYPE.CHAT,
				playSparkAnimation = self.ctrl.sparkAnimationPlayerUid == data.playerId
			})

			local isGroupOwner = self:isChatGroupOwnerMessage(data)

			button:TryChangePage("GroupOwner", isGroupOwner and 1 or 0)

			if data.isRepeat then
				btnAddUButton:SetActive(true)

				function btnAddUButton.luaClick()
					self:sendMessage(data.textContent, pg.game.chat.subMessageType.Text)
				end
			else
				btnAddUButton:SetActive(false)
			end

			function textUButton.luaRenderTooltip(btn, cmp)
				if self:checkTextIsHyperLink(data.extraInfo) then
					if data.extraInfo[Const.CHAT_EXTRA_TYPE.Pet] then
						self:renderPetInfoCard(data, cmp)
					elseif data.extraInfo[Const.CHAT_EXTRA_TYPE.Item] then
						LuaUIUtils.refreshItemInfo(cmp, data.extraInfo[Const.CHAT_EXTRA_TYPE.Item], textUButton)
					end
				else
					self:renderListOtherTooltip(cmp, data, btn)
				end
			end

			function textUButton.luaClick()
				if self:checkTextIsHyperLink(data.extraInfo) then
					self:handleTextMessageHyperlink(textUButton, button, data)
				elseif data.tIndex == pg.game.chat.messageType.OtherPlayer then
					textUButton:OpenTooltipWithUrl("$UI_Node_ChatPanel_Message_Extension.prefab")
				end
			end
		end
	end

	function self.view.messageListUList.luaDrag()
		self:handleMessageListUserScroll()
	end

	self:registerMessageListScrollEvent()

	function self.view.messageListUList.luaFinishLayout(uList)
		if self.needSetBottom then
			uList:GoToIndex(-1, true)

			if pg.global.navMgr.CurrentFocusedGroupName == "ListChat" then
				local itemData = uList.itemData
				local latestData = itemData and itemData.Count > 0 and itemData[itemData.Count - 1] or nil
				local btns = latestData and uList:GetAllButtons() or nil

				for i = 0, btns and btns.Length - 1 or -1 do
					local btn = btns[i]

					if uList:GetData(btn) == latestData then
						pg.global.navMgr:FocusItemInThis(btn)

						break
					end
				end
			end

			self.needSetBottom = false
		end

		self:finishMessageTranslationListRefresh(uList)
		self:refreshCurrentPageTranslationButton()
	end

	self:bindVisibleWatcher(self.view.messageListUList, function(btn, i, data)
		self:tryAutoTranslateVisibleAudioMessage(data)
		self:enqueueAudioMessage(btn, i, data)
		self:refreshCurrentPageTranslationButton()
	end)
	self:refreshChatMessageList()
end

function ChatComponent:tryAutoTranslateVisibleAudioMessage(msgData)
	if not self:checkAudioMessageCanTranslate(msgData) then
		return false
	end

	local currentLanguage = pg.game.setting:getLanguage()
	local translationState = self:getOrCreateMessageTranslationState(msgData)

	if translationState.autoTranslationRequestedLanguage == currentLanguage then
		return false
	end

	translationState.autoTranslationRequestedLanguage = currentLanguage

	local translationStarted = self:showMessageTranslation(msgData)

	if not translationStarted then
		translationState.autoTranslationRequestedLanguage = nil
	end

	return translationStarted
end

function ChatComponent:checkAudioMessageCanTranslate(msgData)
	return msgData.subType == pg.game.chat.subMessageType.Audio and self:checkMessageTranslationSourceCanTranslate(msgData)
end

function ChatComponent:registerMessageListScrollEvent()
	local messageListUList = self.view.messageListUList

	self.messageListScrollPosition = messageListUList.currentScrollPosition
	self.messageTranslationListRefreshing = false

	function self.messageListScrollCallback()
		self:onMessageListScrolled()
	end

	messageListUList:RegisterToScrollEvent(self.messageListScrollCallback)
end

function ChatComponent:onMessageListScrolled()
	local currentPosition = self.view.messageListUList.currentScrollPosition
	local previousPosition = self.messageListScrollPosition

	self.messageListScrollPosition = currentPosition

	if self.messageTranslationListRefreshing or previousPosition == nil then
		return
	end

	local horizontalOffset = math.abs(currentPosition.x - previousPosition.x)
	local verticalOffset = math.abs(currentPosition.y - previousPosition.y)
	local hasHorizontalOffset = horizontalOffset > MessageListScrollEpsilon
	local hasVerticalOffset = verticalOffset > MessageListScrollEpsilon

	if not hasHorizontalOffset and not hasVerticalOffset then
		return
	end

	self:handleMessageListUserScroll()
end

function ChatComponent:handleMessageListUserScroll()
	if self.view.messageListUList.normalizedScrollPosition.y < self.bottomViewHeight then
		self:resetNewMessageCount()
	end

	self:closeCurrentPageTranslationByScroll()
end

function ChatComponent:closeCurrentPageTranslationByScroll()
	if not self:resetCurrentPageTranslationState() then
		return
	end

	self.view.messageListUList:RefreshList()
	self:refreshCurrentPageTranslationButton()
	pg.global.showBubbleMessageRaw(pg.getGameString("AI_TRANSLATE_CURRENT_PAGE_CLOSED"))
end

function ChatComponent:onPositionCardClick(cardInfo)
	if pg.space and (pg.space.sceneId == 501 or pg.space.sceneId == 3000) then
		pg.game.map:openMapAndLocateTempMark(cardInfo.sceneId, cardInfo.pos[1], cardInfo.pos[2], cardInfo.pos[3], nil, pg.game.chat:getLocationText(cardInfo), nil, true)
	end
end

function ChatComponent:openFriendCard(friendCardUid)
	if string.isNilOrEmpty(friendCardUid) then
		return
	end

	self.ctrl:openPlayerInfoCard(friendCardUid)
end

function ChatComponent:renderListOtherTooltip(cmp, msgData, btn)
	local objectReference = cmp:GetComponent("ObjectReference")
	local extensionList = objectReference:GetRefValue("extensionList")

	function extensionList.luaRenderItem(button, index, data)
		local buttonObjectReference = button:GetComponent("ObjectReference")
		local txtNameUSDFText = buttonObjectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, pg.getGameString(data.label))

		function button.luaClick()
			if data.type == pg.game.chat.handleMassageType.Reply then
				self:replyMessage(msgData)
			elseif data.type == pg.game.chat.handleMassageType.Copy then
				self.view.chatUInputField.text = msgData.textContent
			elseif data.type == pg.game.chat.handleMassageType.Follow then
				self:sendMessage(msgData.textContent, pg.game.chat.subMessageType.Text)
			elseif data.type == pg.game.chat.handleMassageType.Report then
				self:reportChat(msgData)
			elseif data.type == pg.game.chat.handleMassageType.Translate then
				self:toggleMessageTranslation(msgData)
			end

			btn:CloseTooltip()
		end
	end

	extensionList:SetList(self:buildMessageFuncData(msgData))
end

function ChatComponent:buildMessageFuncData(msgData)
	local messageFuncData = {}

	for _, data in ipairs(pg.game.chat:getMessageFuncList()) do
		local displayData = self:getMessageFuncDisplayData(data, msgData)

		if displayData then
			messageFuncData[#messageFuncData + 1] = displayData
		end
	end

	return messageFuncData
end

function ChatComponent:getMessageFuncDisplayData(data, msgData)
	local isAudioMessage = msgData.subType == pg.game.chat.subMessageType.Audio
	local isAudioMessageFunc = data.type == pg.game.chat.handleMassageType.Report or data.type == pg.game.chat.handleMassageType.Translate

	if isAudioMessage and not isAudioMessageFunc then
		return nil
	end

	local isInvalidFollow = data.type == pg.game.chat.handleMassageType.Follow and not self:checkTextCanRepeat(msgData.extraInfo)

	if isInvalidFollow then
		return nil
	end

	if data.type ~= pg.game.chat.handleMassageType.Translate then
		return data
	end

	if not self:checkMessageCanTranslate(msgData) then
		return nil
	end

	return {
		label = self:getMessageTranslationLabel(msgData),
		type = data.type
	}
end

function ChatComponent:checkMessageCanTranslate(msgData)
	local subType = msgData.subType
	local isSupportedType = subType == pg.game.chat.subMessageType.Text or subType == pg.game.chat.subMessageType.Audio

	return isSupportedType and self:checkMessageTranslationSourceCanTranslate(msgData)
end

function ChatComponent:checkMessageTranslationSourceCanTranslate(msgData)
	local extraInfo = msgData.extraInfo
	local isOtherPlayerMessage = msgData.tIndex == pg.game.chat.messageType.OtherPlayer
	local hasHyperlink = self:checkTextIsHyperLink(extraInfo)

	if not isOtherPlayerMessage or hasHyperlink then
		return false
	end

	local sourceLanguage = extraInfo and extraInfo[Const.CHAT_EXTRA_TYPE.Language]

	return not string.isNilOrEmpty(sourceLanguage) and sourceLanguage ~= pg.game.setting:getLanguage() and not string.isNilOrEmpty(self:getMessageTranslationSourceText(msgData))
end

function ChatComponent:getMessageTranslationSourceText(msgData)
	if msgData.subType == pg.game.chat.subMessageType.Audio then
		return self:getAudioMessageInfo(msgData).text
	end

	return msgData.textContent
end

function ChatComponent:getAudioMessageInfo(msgData)
	local audioInfo = msgData.extraInfo[Const.CHAT_EXTRA_TYPE.Voice]

	return Utils.isTable(audioInfo) and audioInfo or json.decode(audioInfo)
end

function ChatComponent:getMessageTranslationLabel(msgData)
	if self:isMessageTranslationSelected(msgData) then
		return "AI_SHOW_ORIGINAL"
	end

	return "AI_TRANSLATE"
end

function ChatComponent:isMessageTranslationSelected(msgData)
	return self:isShowingMessageTranslation(msgData) or self:isMessageTranslationInProgress(msgData)
end

function ChatComponent:getMessageTranslationState(msgData)
	return self.messageTranslationStates[msgData]
end

function ChatComponent:getOrCreateMessageTranslationState(msgData)
	local translationState = self:getMessageTranslationState(msgData)

	if translationState ~= nil then
		return translationState
	end

	translationState = {}
	self.messageTranslationStates[msgData] = translationState

	return translationState
end

function ChatComponent:isShowingMessageTranslation(msgData)
	local translationState = self:getMessageTranslationState(msgData)

	return translationState ~= nil and translationState.showTranslated == true and translationState.translatedLanguage == pg.game.setting:getLanguage()
end

function ChatComponent:isMessageTranslationInProgress(msgData)
	local translationState = self:getMessageTranslationState(msgData)

	return translationState ~= nil and translationState.translationDisplayRequested == true and translationState.translationInProgress == true and translationState.translationTargetLanguage == pg.game.setting:getLanguage()
end

function ChatComponent:toggleMessageTranslation(msgData)
	self.pageTranslatedMessages[msgData] = nil

	if self:isMessageTranslationSelected(msgData) then
		self:hideMessageTranslation(msgData)

		return
	end

	self:showMessageTranslation(msgData)
end

function ChatComponent:showMessageTranslation(msgData)
	local translationStarted = self:selectMessageTranslation(msgData)

	self:refreshTranslatedMessageItem(msgData)

	return translationStarted
end

function ChatComponent:selectMessageTranslation(msgData)
	local currentLanguage = pg.game.setting:getLanguage()
	local translationState = self:getOrCreateMessageTranslationState(msgData)

	translationState.translationDisplayRequested = true

	local hasCurrentTranslation = translationState.translatedLanguage == currentLanguage and translationState.translatedText ~= nil

	if hasCurrentTranslation then
		translationState.showTranslated = true

		return true
	end

	local hasCurrentRequest = translationState.translationInProgress == true and translationState.translationTargetLanguage == currentLanguage

	if hasCurrentRequest then
		return true
	end

	translationState.showTranslated = true
	translationState.translationInProgress = true
	translationState.translationTargetLanguage = currentLanguage

	local sourceLanguage = msgData.extraInfo[Const.CHAT_EXTRA_TYPE.Language]
	local translationStarted = pg.game.chat:translateText(self:getMessageTranslationSourceText(msgData), sourceLanguage, CallbackHandler(self, "_onMessageTranslated", msgData, currentLanguage))

	if not translationStarted then
		translationState.translationDisplayRequested = false
		translationState.showTranslated = false
		translationState.translationInProgress = false
		translationState.translationTargetLanguage = nil
	end

	return translationStarted
end

function ChatComponent:hideMessageTranslation(msgData)
	self:clearMessageTranslationDisplay(msgData)
	self:refreshTranslatedMessageItem(msgData)
end

function ChatComponent:clearMessageTranslationDisplay(msgData)
	local translationState = self:getMessageTranslationState(msgData)

	if translationState == nil then
		return
	end

	translationState.translationDisplayRequested = false
	translationState.showTranslated = false
end

function ChatComponent:_onMessageTranslated(msgData, translatedLanguage, success, translatedText)
	local translationState = self:getMessageTranslationState(msgData)

	translationState.translationInProgress = false
	translationState.translationTargetLanguage = nil

	if success ~= true then
		self.pageTranslatedMessages[msgData] = nil

		self:clearMessageTranslationDisplay(msgData)
		self:refreshTranslatedMessageItem(msgData)

		return
	end

	translationState.translatedText = translatedText
	translationState.translatedLanguage = translatedLanguage
	translationState.showTranslated = translationState.translationDisplayRequested == true

	self:refreshTranslatedMessageItem(msgData)
end

function ChatComponent:refreshTranslatedMessageItem(msgData)
	if not self.view or not self.ctrl:checkUIShow() then
		return
	end

	self:tryRefreshChatMessageItem(msgData.messageId)
	self:refreshCurrentPageTranslationButton()
end

function ChatComponent:refreshMessageListForTranslation()
	self.messageTranslationListRefreshing = true

	self.view.messageListUList:RefreshList()
end

function ChatComponent:finishMessageTranslationListRefresh(messageListUList)
	if not self.messageTranslationListRefreshing then
		return
	end

	self.messageListScrollPosition = messageListUList.currentScrollPosition
	self.messageTranslationListRefreshing = false
end

function ChatComponent:checkTextIsHyperLink(extraInfo)
	if not extraInfo then
		return false
	end

	return extraInfo[Const.CHAT_EXTRA_TYPE.PositionCard] ~= nil or extraInfo[Const.CHAT_EXTRA_TYPE.Pet] ~= nil or extraInfo[Const.CHAT_EXTRA_TYPE.Item] ~= nil or extraInfo[Const.CHAT_EXTRA_TYPE.Picture] ~= nil or extraInfo[Const.CHAT_EXTRA_TYPE.FriendCard] ~= nil
end

function ChatComponent:checkTextCanRepeat(extraInfo)
	if not extraInfo then
		return true
	end

	return extraInfo[Const.CHAT_EXTRA_TYPE.PositionCard] == nil and extraInfo[Const.CHAT_EXTRA_TYPE.Pet] == nil and extraInfo[Const.CHAT_EXTRA_TYPE.Item] == nil and extraInfo[Const.CHAT_EXTRA_TYPE.Picture] == nil and extraInfo[Const.CHAT_EXTRA_TYPE.FriendCard] == nil and extraInfo[Const.CHAT_EXTRA_TYPE.Reply] == nil and extraInfo[Const.CHAT_EXTRA_TYPE.HomeSeasonMutationGift] == nil
end

function ChatComponent:renderMessageItemLayout(button, index, data)
	self:renderMessageItem(button, index, data)

	local messageType = pg.game.chat.messageType
	local isPlayerMessage = data.tIndex == messageType.OtherPlayer or data.tIndex == messageType.SelfPlayer

	if not isPlayerMessage then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local textUButton = objectReference:GetRefValue("textUButton")
	local textObjectReference = textUButton:GetComponent("ObjectReference")

	self:renderMessageTranslationLayout(textObjectReference, textUButton, data)
	self:renderReplyMessageLayout(textObjectReference, textUButton, data)
end

function ChatComponent:renderMessageTranslationLayout(textObjectReference, textUButton, data)
	local translatingUSDFText = textObjectReference:GetRefValue("translatingUSDFText")
	local translatedUSDFText = textObjectReference:GetRefValue("translatedUSDFText")

	ClientTextUtils.setText(translatingUSDFText, pg.getGameString("AI_TRANSLATING"))
	ClientTextUtils.setText(translatedUSDFText, pg.getGameString("AI_TRANSLATED"))
	self:renderMessageTranslationState(textUButton, data)
end

function ChatComponent:renderMessageTranslationState(messageButton, data)
	local isTranslating = self:isMessageTranslationInProgress(data)
	local isTranslationSelected = self:isMessageTranslationSelected(data)

	messageButton:TryChangePage("TranslateState", isTranslationSelected and 1 or 0)
	messageButton:TryChangePage("TranslateTpye", isTranslating and 0 or 1)
end

function ChatComponent:renderReplyMessageLayout(textObjectReference, textUButton, data)
	local txtExtendUSDFText = textObjectReference:GetRefValue("txtExtendUSDFText")
	local replyInfo = data.extraInfo and data.extraInfo[Const.CHAT_EXTRA_TYPE.Reply]

	textUButton:TryChangePage("Translate", replyInfo and 1 or 0)

	if not replyInfo then
		return
	end

	local replyPlayerName = replyInfo.playerName

	if not replyPlayerName then
		local replyPlayerInfo = replyInfo.playerInfo or pg.game.chat:getPlayerInfo(replyInfo.playerId)

		replyPlayerName = replyPlayerInfo and replyPlayerInfo.playerName
	end

	if not replyPlayerName then
		return
	end

	replyPlayerName = LuaUIUtils.getPlayerDisplayName(data.playerId, replyPlayerName)

	local extendText = string.isNilOrEmpty(replyPlayerName) and "" or replyPlayerName .. ":\n"

	ClientTextUtils.setText(txtExtendUSDFText, extendText .. replyInfo.textContent)

	txtExtendUSDFText.fontSize = WordSize[MessageWordType.Reply][self.wordSizeSetting]
end

function ChatComponent:renderPlayerMessageHeader(button, data, playerInfo, hooks)
	if not playerInfo then
		return
	end

	local playerName = LuaUIUtils.getPlayerDisplayName(data.playerId, playerInfo.playerName)

	if data.playerId == pg.me.uid then
		playerName = pg.me.playerName
	end

	playerName = hooks and hooks.renderMessageRootPlayerName and hooks.renderMessageRootPlayerName(self, button, data, playerInfo, playerName) or playerName
	button:GetChild("TxtName"):GetComponent("UBaseText").text = playerName
end

function ChatComponent:renderPlayerChatBubble(textObjectReference, chatBubbleId, playerId)
	local bubbleUImage = textObjectReference:GetRefValue("bubbleUImage")

	if not bubbleUImage then
		return
	end

	local isOtherPlayer = playerId ~= pg.me.uid

	bubbleUImage.url = pg.game.chat:GetChatBubbleRes(chatBubbleId, isOtherPlayer)
end

function ChatComponent:renderPlayerMessagePopName(button, messageEle, data, playerInfo, hooks)
	if not playerInfo then
		return
	end

	local popPlayerName = LuaUIUtils.getPlayerDisplayName(data.playerId, playerInfo.playerName)

	if data.playerId == pg.me.uid then
		popPlayerName = pg.me.playerName
	end

	popPlayerName = hooks and hooks.renderMessagePopPlayerName and hooks.renderMessagePopPlayerName(self, button, data, playerInfo, popPlayerName) or popPlayerName

	local ok, popNameNode = pcall(function()
		return messageEle:GetChild("Name"):GetChild("TxtName"):GetComponent("UBaseText")
	end)

	if ok and popNameNode and (type(IsNil) ~= "function" or not IsNil(popNameNode)) then
		popNameNode.text = popPlayerName
	end
end

function ChatComponent:isChatGroupOwnerMessage(data)
	if not data or data.channelType ~= pg.game.chat.channelType.Group then
		return false
	end

	local groupId = data.channelId or self.curSelectedChannelId
	local groupData = pg.game.chat:getFriendChatGroup(groupId)

	return groupData ~= nil and groupData.master == data.playerId
end

function ChatComponent:isPictureMessage(data)
	return data.subType == pg.game.chat.subMessageType.Picture or data.extraInfo and data.extraInfo[Const.CHAT_EXTRA_TYPE.Picture]
end

function ChatComponent:isPetMessage(data)
	if data == nil then
		return
	end

	return data.extraInfo and data.extraInfo[Const.CHAT_EXTRA_TYPE.Pet] ~= nil
end

function ChatComponent:addPictureSpriteCallback(imgKey, callback)
	self.pictureSpriteInfoMap = self.pictureSpriteInfoMap or {}

	local spriteInfo = self.pictureSpriteInfoMap[imgKey]

	if spriteInfo then
		if spriteInfo.sprite then
			callback(spriteInfo.sprite)
		else
			spriteInfo.callbacks[#spriteInfo.callbacks + 1] = callback
		end

		return
	end

	spriteInfo = {
		callbacks = {
			callback
		}
	}

	local function onPresetImgLoaded(sprite)
		local curSpriteInfo = self.pictureSpriteInfoMap and self.pictureSpriteInfoMap[imgKey]

		if not curSpriteInfo then
			return
		end

		local callbacks = curSpriteInfo.callbacks

		if sprite then
			curSpriteInfo.sprite = sprite
			curSpriteInfo.callbacks = nil
		else
			self.pictureSpriteInfoMap[imgKey] = nil
		end

		for _, callbackFunc in ipairs(callbacks) do
			callbackFunc(sprite)
		end
	end

	self.pictureSpriteInfoMap[imgKey] = spriteInfo

	pg.global.ui.photo.model:queryPresetImg(imgKey, onPresetImgLoaded)
end

function ChatComponent:renderPicturePhotoUImage(button, data, photoUImage)
	if not photoUImage then
		return
	end

	photoUImage.url = nil
	photoUImage.sprite = nil

	local pictureInfo = data and data.extraInfo and data.extraInfo[Const.CHAT_EXTRA_TYPE.Picture]
	local resId = pictureInfo and pictureInfo.resId

	if not string.isNilOrEmpty(resId) then
		photoUImage.url = resId

		return
	end

	local imgKey = pictureInfo and pictureInfo.imgKey
	local photoModel = pg.global.ui.photo and pg.global.ui.photo.model

	if string.isNilOrEmpty(imgKey) or not photoModel then
		return
	end

	local function onPictureSpriteLoaded(sprite)
		local currentData = button.dataFromUList
		local isCurrentMessage = currentData == data or currentData and currentData.messageData == data
		local isCurrentPresetImage = string.isNilOrEmpty(pictureInfo.resId) and pictureInfo.imgKey == imgKey

		if not isCurrentMessage or not isCurrentPresetImage then
			return
		end

		photoUImage.sprite = sprite
	end

	self:addPictureSpriteCallback(imgKey, onPictureSpriteLoaded)
end

function ChatComponent:renderTextMessageItem(ownerButton, messageEle, data)
	local textEle = messageEle:GetChild("Text")
	local textUSDFText = textEle:GetChild("TxtName"):GetComponent("USDFText")

	textUSDFText.disableTextLinkHotkey = true
	textUSDFText.luaOnHyperlinkClick = nil
	textUSDFText.luaResolveHyperlinkEffect = nil

	if self:checkTextIsHyperLink(data.extraInfo) then
		local textContent = pg.game.chat:getTextContentFromExtraInfo(data.extraInfo)

		if data.extraInfo and data.extraInfo[Const.CHAT_EXTRA_TYPE.Picture] then
			textContent = string.isNilOrEmpty(data.textContent) and pg.getGameString("PHOTO") or data.textContent
		end

		local hyperText = pg.getFormatText(pg.getGameString("HYPER_LINK"), textContent)
		local objectReference = ownerButton:GetComponent("ObjectReference")
		local textUButton = objectReference and objectReference:GetRefValue("textUButton")

		if textUButton then
			function textUSDFText.luaOnHyperlinkClick(action, _, contentRect)
				if not action then
					return
				end

				local triggerButton = findHyperlinkButton(contentRect, textUButton)

				self:handleTextMessageHyperlink(triggerButton, ownerButton, data)
			end

			function textUSDFText.luaResolveHyperlinkEffect()
				return self:resolveTextMessageHyperlinkEffect(data)
			end
		end

		ClientTextUtils.setText(textUSDFText, hyperText)
	else
		ClientTextUtils.setText(textUSDFText, self:getMessageTranslationDisplayText(data))
	end

	if self.wordSizeSetting == WordSizeOptions.Normal then
		textUSDFText.fontSize = WordSize[MessageWordType.Normal][WordSizeOptions.Normal]
	elseif self.wordSizeSetting == WordSizeOptions.Big then
		textUSDFText.fontSize = WordSize[MessageWordType.Normal][WordSizeOptions.Big]
	end
end

function ChatComponent:getMessageTranslationDisplayText(data)
	if self:isShowingMessageTranslation(data) then
		return self:getMessageTranslationState(data).translatedText
	end

	return self:getMessageTranslationSourceText(data)
end

function ChatComponent:resolveTextMessageHyperlinkEffect(data)
	local extraInfo = data and data.extraInfo

	if not extraInfo then
		return nil
	end

	if extraInfo[Const.CHAT_EXTRA_TYPE.Pet] or extraInfo[Const.CHAT_EXTRA_TYPE.Item] then
		return LuaUIUtils.HYPERLINK_EFFECT.TOOLTIP
	elseif extraInfo[Const.CHAT_EXTRA_TYPE.PositionCard] then
		return LuaUIUtils.HYPERLINK_EFFECT.OTHER
	end

	return nil
end

function ChatComponent:handleTextMessageHyperlink(triggerButton, ownerButton, data)
	local extraInfo = data and data.extraInfo

	if not extraInfo then
		return
	end

	if extraInfo[Const.CHAT_EXTRA_TYPE.PositionCard] then
		if data.tIndex == pg.game.chat.messageType.OtherPlayer then
			self:onPositionCardClick(extraInfo[Const.CHAT_EXTRA_TYPE.PositionCard])
		end
	elseif extraInfo[Const.CHAT_EXTRA_TYPE.Pet] then
		function triggerButton.luaRenderTooltip(_, cmp)
			self:renderPetInfoCard(data, cmp)
		end

		self:openPetCard(triggerButton, ownerButton, data)
	elseif extraInfo[Const.CHAT_EXTRA_TYPE.Item] then
		function triggerButton.luaRenderTooltip(_, cmp)
			LuaUIUtils.refreshItemInfo(cmp, extraInfo[Const.CHAT_EXTRA_TYPE.Item], triggerButton)
		end

		self:openItemCard(extraInfo[Const.CHAT_EXTRA_TYPE.Item], triggerButton)
	end
end

function ChatComponent:renderJumpSharedMessageItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textUButton = objectReference:GetRefValue("textUButton")
	local textObjectReference = textUButton:GetComponent("ObjectReference")
	local gotoUSDFText = textObjectReference:GetRefValue("gotoUSDFText")
	local btnClickToUButton = textObjectReference:GetRefValue("btnClickToUButton")

	ClientTextUtils.setText(gotoUSDFText, data.textContent or "")

	function btnClickToUButton.luaClick()
		local extraInfo = data.extraInfo or {}
		local confirmText = extraInfo.confirmText

		if string.isNilOrEmpty(confirmText) then
			confirmText = data.textContent or ""
		end

		local function okCb()
			self.model:invokeJumpFunction(data)
		end

		pg.global.ui:open(UIConst.UI_ID_COMMON_CONFIRM, {
			title = pg.getGameString("WARNING"),
			desc = confirmText,
			okCb = okCb
		})
	end
end

function ChatComponent:renderFriendCardMessageItem(button, data)
	local friendCardUid = data.extraInfo and data.extraInfo[Const.CHAT_EXTRA_TYPE.FriendCard]

	if string.isNilOrEmpty(friendCardUid) then
		return
	end

	local playerInfo = pg.game.chat:getPlayerInfo(friendCardUid)

	if playerInfo == nil then
		pg.game.chat:getPlayerInfoFromServer(friendCardUid, nil, function(serverPlayerInfo)
			if serverPlayerInfo == nil or self.view == nil then
				return
			end

			self:refreshChatMessageList()
		end)

		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local cardReference = objectReference:GetRefValue("cardObjectReference")
	local btnCardUButton = cardReference:GetRefValue("btnCardUButton")
	local btnAddFriendUButton = cardReference:GetRefValue("btnAddFriendUButton")
	local avatarObjectReference = cardReference:GetRefValue("avatarObjectReference")
	local txtNameUSDFText = cardReference:GetRefValue("txtNameUSDFText")
	local textUSDFText = cardReference:GetRefValue("textUSDFText")
	local cardUComponent = cardReference:GetRefValue("cardUComponent")

	ClientTextUtils.setText(textUSDFText, pg.getGameString("SHARED_FRIEND_CARD"))

	function btnCardUButton.luaClick()
		self:openFriendCard(friendCardUid)
	end

	self:renderFriendCardName(txtNameUSDFText, friendCardUid, playerInfo)
	self:renderFriendCardAvatar(avatarObjectReference, playerInfo)
	self:refreshFriendCardAddButton(cardUComponent, btnAddFriendUButton, friendCardUid)
end

function ChatComponent:renderFriendCardName(txtNameUSDFText, friendCardUid, playerInfo)
	local displayName = LuaUIUtils.getPlayerDisplayName(friendCardUid, playerInfo.playerName, true)

	ClientTextUtils.setText(txtNameUSDFText, displayName)
end

function ChatComponent:renderFriendCardAvatar(avatarObjectReference, playerInfo)
	local imgAvatarUImage = avatarObjectReference:GetRefValue("imgAvatarUImage")
	local frameUImage = avatarObjectReference:GetRefValue("frameUImage")
	local textLvUSDFText = avatarObjectReference:GetRefValue("textLvUSDFText")
	local headIconCfg = PlayerHeadIconData[playerInfo.headIcon]
	local headFrameCfg = PlayerHeadFrameData[playerInfo.headFrame] or PlayerHeadFrameData[1]

	if headIconCfg and imgAvatarUImage then
		imgAvatarUImage.url = headIconCfg.res
	end

	if headFrameCfg and frameUImage then
		frameUImage.url = headFrameCfg.res
	end

	if textLvUSDFText then
		ClientTextUtils.setText(textLvUSDFText, playerInfo.level)
	end
end

function ChatComponent:refreshFriendCardAddButton(cardUComponent, btnAddFriendUButton, friendCardUid)
	local isFriend = pg.game.chat:checkFriendList(friendCardUid)
	local isSelf = friendCardUid == pg.me.uid

	if isFriend or isSelf then
		cardUComponent:TryChangePage("State", 0)
		btnAddFriendUButton.gameObject:SetActiveEx(false)

		return
	end

	local canApplyFriend = pg.game.chat:checkAddFriendCD(friendCardUid)

	btnAddFriendUButton.gameObject:SetActiveEx(canApplyFriend)
	cardUComponent:TryChangePage("State", canApplyFriend and 0 or 1)

	function btnAddFriendUButton.luaClick()
		if not pg.game.chat:checkAddFriendCD(friendCardUid) then
			cardUComponent:TryChangePage("State", 1)
			btnAddFriendUButton.gameObject:SetActiveEx(false)

			return false
		end

		cardUComponent:TryChangePage("State", 1)
		btnAddFriendUButton.gameObject:SetActiveEx(false)
		pg.game.chat:applyFriend(friendCardUid, pg.game.chat.AddFriendSource.FriendRecommend, nil, true)

		return false
	end
end

function ChatComponent:renderHomeSeasonMutationGiftMessageItem(button, data)
	local cardInfo = data.extraInfo[Const.CHAT_EXTRA_TYPE.HomeSeasonMutationGift]
	local objectReference = button:GetComponent("ObjectReference")
	local giftUButton = objectReference:GetRefValue("giftUButton")
	local giftObjectReference = giftUButton:GetComponent("ObjectReference")
	local txtDetailsUSDFText = giftObjectReference:GetRefValue("txtDetailsUSDFText")
	local rewardItemUButton = giftObjectReference:GetRefValue("rewardItemUButton")
	local btnThanksUButton = giftObjectReference:GetRefValue("btnThanksUButton")
	local txtCanGetUSDFText = giftObjectReference:GetRefValue("txtCanGetUSDFText")
	local txtIsGetUSDFText = giftObjectReference:GetRefValue("txtIsGetUSDFText")
	local giftState = HomeSeasonMutationGiftState.NoButton

	if not string.isNilOrEmpty(cardInfo.requestId) and data.playerId ~= pg.me.uid and cardInfo.expireTs > Time.secondCache then
		local usedRequestMap = pg.me.homeSeasonMutationUsedHelpRequests or {}

		giftState = usedRequestMap[cardInfo.requestId] and HomeSeasonMutationGiftState.Gifted or HomeSeasonMutationGiftState.CanGift
	end

	giftUButton:TryChangePage("GiftState", giftState)
	ClientTextUtils.setText(txtDetailsUSDFText, pg.game.chat:getHomeSeasonMutationCardText(cardInfo))
	LuaUIUtils.renderRewardItem(rewardItemUButton, {
		num = 1,
		id = cardInfo.itemId
	}, "1")
	ClientTextUtils.setText(txtCanGetUSDFText, pg.getGameString("SEND_TEXT"))
	ClientTextUtils.setText(txtIsGetUSDFText, pg.getGameString("HOMELAND_SEASON_CROP_CHAT_GIFTED"))

	function btnThanksUButton.luaClick()
		if giftState == HomeSeasonMutationGiftState.CanGift then
			self:respondHomeSeasonMutationHelp(data, cardInfo, giftUButton)
		end
	end
end

function ChatComponent:respondHomeSeasonMutationHelp(data, cardInfo, giftUButton)
	if self.homeSeasonMutationRespondingRequestId then
		return
	end

	local usedRequestMap = pg.me.homeSeasonMutationUsedHelpRequests or {}

	if usedRequestMap[cardInfo.requestId] then
		giftUButton:TryChangePage("GiftState", HomeSeasonMutationGiftState.Gifted)

		return
	end

	local ownNum = HomeSeasonUtils.getHomeSeasonMutationItemCount(pg.me, cardInfo.itemId)

	pg.global.ui.commonUseConfirm:open({
		muteCheckEnough = true,
		hideCurrency = 1,
		title = pg.getGameString("HOME_PLANT_SEND_TITLE"),
		tipTop = pg.getGameString("HOMELAND_SEASON_CROP_SEND_CONFIRM_DESC"),
		data = {
			{
				cardInfo.itemId,
				1,
				ownNum = ownNum
			}
		},
		confirmCb = function()
			self.homeSeasonMutationRespondingRequestId = cardInfo.requestId

			pg.me:reqRespondHomeSeasonMutationHelp(cardInfo.requestId, function(result)
				self.homeSeasonMutationRespondingRequestId = nil

				if result ~= NoticeDef.SUCCESS then
					return
				end

				pg.global.showBubbleMessageRaw(pg.getGameString("HOMELAND_SEASON_CROP_GIFT_SUCCESS"))
				pg.game.chat:sendHomeSeasonMutationGiftChatCard(cardInfo.fromUid, cardInfo.itemId)
				facade:SendMessageCommand(MessageName.CHAT_MESSAGE_UPDATE_ITEM, {
					channelId = data.channelId,
					msgId = data.messageId
				})
			end)
		end
	})
end

function ChatComponent:renderEmojiMessageItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local emojiUContainer = objectReference:GetRefValue("emojiUContainer")
	local imgEmojiUImage = objectReference:GetRefValue("imgEmojiUImage")
	local emojiScaleDownAdapter = emojiUContainer.transform:GetComponent("UIScaleDownAdapter")
	local isEmoji = not data.extraInfo.emojiType or data.extraInfo.emojiType and data.extraInfo.emojiType ~= 1

	emojiUContainer.gameObject:SetActiveEx(isEmoji)
	imgEmojiUImage.gameObject:SetActiveEx(not isEmoji)

	if isEmoji then
		emojiUContainer:SetUrlWithCallback(data.extraInfo[Const.CHAT_EXTRA_TYPE.Emoji], function(content)
			local contentReference = content:GetComponent("ObjectReference")

			if contentReference then
				local widgetAnimation = contentReference:GetRefValue("widgetAnimation")

				emojiScaleDownAdapter.targetTransform = widgetAnimation.transform
			end

			content:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		end)
	else
		imgEmojiUImage.url = data.extraInfo[Const.CHAT_EXTRA_TYPE.Emoji]
	end
end

function ChatComponent:renderInviteMessageItem(listButton, messageEle, data)
	local btnTeamInvite = messageEle:GetChild("InviteInfo")

	self:handleInviteInfo(listButton, btnTeamInvite, data)
end

function ChatComponent:handleInviteInfo(listButton, inviteButton, data)
	local objectReference = inviteButton:GetComponent("ObjectReference")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
	local txtNumUBaseText = objectReference:GetRefValue("txtNumUBaseText")
	local txtInviteUBaseText = objectReference:GetRefValue("txtInviteUBaseText")

	inviteButton.luaClick = nil
	inviteButton.navForceInteractable = true

	if data.subType == pg.game.chat.subMessageType.DungeonInvite then
		self:renderDungeonInviteInfo(listButton, inviteButton, data, txtNameUBaseText, txtNumUBaseText, txtInviteUBaseText)
	elseif data.subType == pg.game.chat.subMessageType.PhotographyStudioInvite then
		inviteButton:TryChangePage("Type", 0)

		local inviteInfo = data.extraInfo and data.extraInfo[Const.CHAT_EXTRA_TYPE.PhotographyStudioInvite]
		local studioUid = inviteInfo and inviteInfo.studioUid
		local invitationUid = inviteInfo and inviteInfo.invitationUid or data.playerId
		local invitedUid = inviteInfo and inviteInfo.invitedUid
		local studioInfo = studioUid and pg.me:getStudioInfo(studioUid)
		local memberCount = studioInfo and #(studioInfo.members or {}) or 0
		local memberLimit = tonumber(AppearanceVariableData.STUDIO_INVITE_FRIEND_NUM) or 0

		ClientTextUtils.setText(txtNameUBaseText, pg.getGameString("PHOTO_STUDIO_CHAT_INVITE_TITLE"))
		ClientTextUtils.setText(txtNumUBaseText, memberCount, "/", memberLimit)
		ClientTextUtils.setText(txtInviteUBaseText, pg.getGameString("PHOTO_STUDIO_ACCEPT_INVITE_ACTION"))

		local isSelfMessage = data.playerId == pg.me.uid
		local invitationRecord, accepted

		if isSelfMessage then
			invitationRecord = invitedUid ~= nil and pg.me:getSentPhotographyStudioInvitation(studioUid, invitedUid)
			accepted = invitationRecord ~= nil and pg.me:isSentPhotographyStudioInvitationAccepted(studioUid, invitedUid)
		else
			invitationRecord = invitationUid ~= nil and pg.me:getReceivedPhotographyStudioInvitation(studioUid, invitationUid)
			accepted = invitationRecord ~= nil and pg.me:isReceivedPhotographyStudioInvitationAccepted(studioUid, invitationUid)
		end

		local lostEffectiveness = studioUid == nil or invitationRecord == nil or accepted and studioInfo == nil
		local interactable = not lostEffectiveness and (accepted or not isSelfMessage)

		inviteButton.interactable = interactable

		inviteButton:TryChangePage("LostEffectiveness", lostEffectiveness and 1 or 0)
		inviteButton:TryChangePage("PhotographBtn", accepted and 1 or 0)

		function inviteButton.luaClick()
			if not PhotographyStudioUtils.checkFunctionEnabled(true) then
				return
			end

			if studioUid == nil then
				return
			end

			if accepted then
				pg.global.ui:open(UIConst.UI_ID_APPEARANCE_V2, {
					enterPage = "photoStudioEdit",
					photographyStudioUid = studioUid
				}, function()
					local appearanceCtrl = pg.global.ui:tryGetCtrlByUid(UIConst.UI_ID_APPEARANCE_V2)

					if appearanceCtrl then
						appearanceCtrl:openPhotographyStudioEditor(studioUid)
					end
				end)

				return
			end

			if isSelfMessage or invitationUid == nil then
				return
			end

			pg.me:reqAcceptInvitePhotographyStudio(studioUid, invitationUid)
		end
	elseif data.subType == pg.game.chat.subMessageType.PVPInvite then
		inviteButton:TryChangePage("Type", 1)

		local playerInfo = pg.game.chat:getPlayerInfo(data.playerId)

		inviteButton.interactable = false

		ClientTextUtils.setText(txtNameUBaseText, string.format(pg.getGameString("PVP_COVENANT_TO_YOU"), LuaUIUtils.getPlayerDisplayName(data.playerId, playerInfo.playerName)))
	elseif data.subType == pg.game.chat.subMessageType.EnterWorld then
		inviteButton:TryChangePage("Type", 2)

		inviteButton.interactable = false

		ClientTextUtils.setText(txtNameUBaseText, pg.getGameString("ENTER_WORLD_REQUEST_TITLE"))
	elseif data.subType == pg.game.chat.subMessageType.HomeCampInvite then
		inviteButton:TryChangePage("Type", 6)

		local inviteInfo = data.extraInfo and data.extraInfo[Const.CHAT_EXTRA_TYPE.HomeCampInvite]

		ClientTextUtils.setText(txtNameUBaseText, pg.getGameString("HOME_CAMP"))
		ClientTextUtils.setText(txtNumUBaseText, inviteInfo.curCount or 0, "/", inviteInfo.maxCount or 0)
		ClientTextUtils.setText(txtInviteUBaseText, pg.getGameString("HOME_CAMP_INVITE"))

		local interactable = self:checkHomeCampInviteInfoState(inviteInfo)

		inviteButton.interactable = interactable

		inviteButton:TryChangePage("LostEffectiveness", interactable and 0 or 1)

		function inviteButton.luaClick()
			if data.playerId ~= pg.me.uid then
				self:checkAndOpenCampInvite(inviteInfo)
			end
		end
	elseif data.subType == pg.game.chat.subMessageType.HomeSeasonCelebrationInvite then
		inviteButton:TryChangePage("Type", 7)

		local inviteInfo = data.extraInfo and data.extraInfo[Const.CHAT_EXTRA_TYPE.HomeSeasonCelebrationInvite] or {}

		ClientTextUtils.setText(txtNameUBaseText, pg.getGameString("HOME_SEASON_CELEBRATION_TITLE"))
		ClientTextUtils.setText(txtNumUBaseText, "")
		ClientTextUtils.setText(txtInviteUBaseText, pg.getGameString("HOME_SEASON_CELEBRATION_INVITE_CARD_TITLE"))

		local hasInviteIdentity = inviteInfo.ownerUid ~= nil and tonumber(inviteInfo.sessionId or 0) > 0
		local isSelfMessage = data.playerId == pg.me.uid
		local interactable = hasInviteIdentity and not isSelfMessage

		inviteButton.interactable = interactable

		inviteButton:TryChangePage("LostEffectiveness", hasInviteIdentity and 0 or 1)

		function inviteButton.luaClick()
			if not interactable then
				return
			end

			pg.global.showConfirmMsgRaw(pg.getGameString("HOME_SEASON_CELEBRATION_TITLE"), pg.getGameString("HOME_SEASON_CELEBRATION_VISIT_CONFIRM_CONTENT"), function()
				pg.me:enterHomelandByUid(inviteInfo.ownerUid)
			end)
		end
	elseif data.subType == pg.game.chat.subMessageType.Team then
		inviteButton:TryChangePage("Type", 2)
		ClientTextUtils.setText(txtNameUBaseText, data.textContent)
		ClientTextUtils.setText(txtInviteUBaseText, pg.getGameString("TEAM_INVITE"))

		local function cb()
			local teamMembers = pg.game.chat:getPlayerTeamMemberCount(data.playerId)

			if teamMembers == 0 then
				teamMembers = 1
			end

			ClientTextUtils.setText(txtNumUBaseText, teamMembers, "/", 4)
		end

		cb()

		function inviteButton.luaClick()
			if data.playerId ~= pg.me.uid then
				local playerInfo = pg.game.chat:getPlayerInfo(data.playerId)

				pg.game.chat:recvEnterWorldInvite(data.playerId, playerInfo)
			end
		end
	end
end

function ChatComponent:renderDungeonInviteInfo(listButton, inviteButton, data, txtNameUBaseText, txtNumUBaseText, txtInviteUBaseText)
	inviteButton:TryChangePage("Type", 0)

	local teamInviteInfo = data.extraInfo and data.extraInfo[Const.CHAT_EXTRA_TYPE.TeamInvite]
	local dungeonSceneId = teamInviteInfo and tonumber(teamInviteInfo.dungeonId or "") or nil
	local dungeonConfig = dungeonSceneId and LevelData[dungeonSceneId]
	local maxMember = tonumber(dungeonConfig and dungeonConfig.playerNumMax) or 4
	local playerInfo = pg.game.chat:getPlayerInfo(data.playerId)
	local teamId = teamInviteInfo and teamInviteInfo.teamId or nil
	local latestMemberCount = self:getDungeonInviteMemberCount(teamId, playerInfo)
	local isValid, invalidReason = self:checkDungeonInviteInfoState(data, playerInfo, latestMemberCount, maxMember)
	local memberCount = 0

	if isValid or invalidReason == "teamFull" then
		memberCount = latestMemberCount
	end

	ClientTextUtils.setText(txtNameUBaseText, self:getDungeonInviteTitle(dungeonSceneId, dungeonConfig, teamInviteInfo and (teamInviteInfo.hardLv or teamInviteInfo.difficultLv)))

	if invalidReason == "expired" or memberCount == 0 then
		ClientTextUtils.setText(txtNumUBaseText, pg.getGameString("EXPIRED"))
	else
		ClientTextUtils.setText(txtNumUBaseText, memberCount, "/", maxMember)
	end

	ClientTextUtils.setText(txtInviteUBaseText, pg.getGameString("DUNGEON_INVITE"))
	self:applyDungeonInviteInfoState(inviteButton, data, isValid)

	function inviteButton.luaClick()
		self:startDungeonInviteClick(listButton, inviteButton, data, maxMember)
	end

	self:refreshDungeonInviteData(data, isValid)
end

function ChatComponent:checkDungeonInviteInfoState(data, playerInfo, memberCount, maxMember)
	local teamInviteInfo = data.extraInfo and data.extraInfo[Const.CHAT_EXTRA_TYPE.TeamInvite]

	if not teamInviteInfo then
		return false, "missingInviteInfo"
	end

	local inviteTime = tonumber(teamInviteInfo.inviteTime)
	local validTime = SysConfigData.TeamInviteValidTime or 180

	if not inviteTime or inviteTime + validTime <= Time.secondCache then
		return false, "expired"
	end

	local teamId = tostring(teamInviteInfo.teamId or "")
	local isSelfInvite = data.playerId == pg.me.uid
	local playerTeamId, teamDungeonSceneId, matchStatus

	if isSelfInvite then
		local currentTeamInfo = pg.me:getCurTeamInfo()

		playerTeamId = currentTeamInfo and currentTeamInfo.teamId
		teamDungeonSceneId = currentTeamInfo and currentTeamInfo.dungeonSceneId
		matchStatus = pg.me.matchStatus
	else
		playerTeamId = playerInfo and playerInfo.teamId
		teamDungeonSceneId = playerInfo and playerInfo.teamDungeonSceneId
		matchStatus = playerInfo and playerInfo.matchStatus
	end

	playerTeamId = tostring(playerTeamId or "")

	if string.isNilOrEmpty(teamId) or teamId ~= playerTeamId then
		return false, "teamChanged"
	end

	local dungeonSceneId = tonumber(teamInviteInfo.dungeonId)

	teamDungeonSceneId = tonumber(teamDungeonSceneId)

	if dungeonSceneId ~= teamDungeonSceneId then
		return false, "targetChanged"
	end

	local isInDungeon = matchStatus == MatchConst.MATCH_STATUS_IN_DUNGEON

	if isInDungeon then
		return false, "inDungeon"
	end

	memberCount = tonumber(memberCount)

	if memberCount ~= nil and memberCount <= 0 then
		return false, "teamDismissed"
	end

	local isTeamFull = memberCount ~= nil and memberCount >= tonumber(maxMember or 4)

	if isTeamFull then
		return false, "teamFull"
	end

	return true
end

function ChatComponent:applyDungeonInviteInfoState(inviteButton, data, isValid)
	local pendingClick = self.pendingDungeonInviteClick

	inviteButton.navForceInteractable = isValid == true
	inviteButton.interactable = isValid == true and data.playerId ~= pg.me.uid and not pg.me:isInTeam(true) and not pendingClick

	inviteButton:TryChangePage("LostEffectiveness", isValid and 0 or 1)
end

function ChatComponent:joinDungeonInviteTeam(data)
	local teamInviteInfo = data.extraInfo[Const.CHAT_EXTRA_TYPE.TeamInvite]
	local psnSessionId = teamInviteInfo.psnSessionId
	local canJoinPsnSession = not string.isNilOrEmpty(psnSessionId) and PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.SupportsMultiplayerActivity and PlatformBridgeLuaFacade.SupportsMultiplayerActivity() and PlatformBridgeLuaFacade.JoinPlayerSession

	if canJoinPsnSession then
		PlatformBridgeLuaFacade.JoinPlayerSession(psnSessionId, 0, nil)

		return
	end

	pg.me:requestJoinTeam(data.playerId)
end

function ChatComponent:isSameChatMessageData(leftData, rightData)
	if leftData == rightData then
		return true
	end

	if type(leftData) ~= "table" or type(rightData) ~= "table" then
		return false
	end

	return leftData.tIndex == rightData.tIndex and leftData.subType == rightData.subType and leftData.channelId == rightData.channelId and leftData.playerId == rightData.playerId and leftData.timeStamp == rightData.timeStamp and leftData.textContent == rightData.textContent
end

function ChatComponent:renderPictureMessageItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local btnLikeUButton = objectReference:GetRefValue("btnLikeUButton")
	local likeCountUSDFText = objectReference:GetRefValue("likeCountUSDFText")
	local btnPhotographUButton = objectReference:GetRefValue("btnPhotographUButton")
	local photoUImage = objectReference:GetRefValue("photoUImage")

	self:renderPicturePhotoUImage(button, data, photoUImage)
	ClientTextUtils.setText(likeCountUSDFText, data.likeCount or 0)
	btnLikeUButton:TryChangePage("Like", data.likedByMe == true and 1 or 0)

	function btnLikeUButton.luaClick()
		local messageData = self:getCurrentChatMessageData(button, index, data)
		local chatLikeInfo = self:getChatMessageLikeInfo(messageData)

		if not chatLikeInfo then
			return
		end

		if chatLikeInfo.likedByMe == true then
			return
		end

		pg.me:likeChatMessage(chatLikeInfo)
	end

	local function openPictureDetail()
		local messageData = self:getCurrentChatMessageData(button, index, data)

		self:onImageClick(messageData)

		return false
	end

	btnPhotographUButton.luaClick = openPictureDetail

	btnPhotographUButton:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonNorth, nil, openPictureDetail)
	btnPhotographUButton:SetHotkeyActiveOnlyInCurrentItem(true)
	btnPhotographUButton:SetHotkeyConsoleBar("CONSOLE_BAR_VIEW", 0, self.view.mainConsoleBarTransform)
end

function ChatComponent:getCurrentChatMessageData(button, index, fallbackData)
	local sourceData

	if type(index) == "number" then
		local messageListData = self:getChatMessageListData()

		sourceData = messageListData and messageListData[index]
	end

	local currentData

	if self.view and self.view.messageListUList and button then
		currentData = self.view.messageListUList:GetData(button)
	end

	local function isMatchedData(data)
		return type(data) == "table" and self:isSameChatMessageData(data, fallbackData)
	end

	if isMatchedData(sourceData) and sourceData.messageId ~= nil then
		return sourceData
	end

	if isMatchedData(currentData) and currentData.messageId ~= nil then
		return currentData
	end

	if isMatchedData(fallbackData) and fallbackData.messageId ~= nil then
		return fallbackData
	end

	return isMatchedData(sourceData) and sourceData or isMatchedData(currentData) and currentData or fallbackData
end

function ChatComponent:getInteractReplyMessageLocation(data)
	local channelId = self:getInteractReplyChannelId(data)
	local msgId = self:getInteractSourceMessageId(data)

	return channelId, msgId
end

function ChatComponent:getInteractSourceMessageId(data)
	local extraInfo = data and data.extraInfo

	if extraInfo.reply then
		return extraInfo.reply.replyTarget
	end

	return extraInfo.sourceMsgId
end

function ChatComponent:getChatTabTypeByChannelType(channelType)
	local channelInfo = pg.game.chat.channelTypeInfo[channelType]

	return channelInfo and channelInfo.cate
end

function ChatComponent:switchToChatTab(tabType)
	if self.ctrl.curTabType == tabType then
		return
	end

	if tabType == pg.game.chat.tabType.Chat then
		self.view.btnChatUButton:OnClickSimulate()
	elseif tabType == pg.game.chat.tabType.Public then
		self.view.btnPublicUButton:OnClickSimulate()
	elseif tabType == pg.game.chat.tabType.Notice then
		self.view.btnNoticeUButton:OnClickSimulate()
	end
end

function ChatComponent:selectChatChannel(channelId)
	for i, channelData in ipairs(self.channelListData or EMPTY_TABLE) do
		local targetChannelId = channelData.channelId or channelData.playerId

		if targetChannelId == channelId then
			self.curSelectedChannel = i

			self.view.channelListUList:SelectItem(i - 1)

			return true
		end
	end

	return false
end

function ChatComponent:jumpToChatMessage(channelId, messageId)
	if string.isNilOrEmpty(channelId) or messageId == nil then
		return false
	end

	local index = pg.game.chat:getMessageIndex(channelId, messageId)

	if not index then
		return false
	end

	local messageData = pg.game.chat:getMessageInfo(channelId, messageId)
	local tabType = self:getChatTabTypeByChannelType(messageData and messageData.channelType)

	if tabType then
		self:switchToChatTab(tabType)
	end

	local channelListUList = self.view and self.view.channelListUList
	local selectedItem = channelListUList and channelListUList.selectedItem
	local isCurrentChannel = selectedItem and (selectedItem.channelId == channelId or selectedItem.playerId == channelId)

	if not isCurrentChannel and not self:selectChatChannel(channelId) then
		return false
	end

	self.needSetBottom = false

	local messageListUList = self.view.messageListUList
	local targetIndex = index - 1

	messageListUList:GoToIndex(targetIndex, true)

	local hasTargetItem, targetItem = messageListUList:TryGetChildAt(targetIndex)

	if hasTargetItem and pg.game.input:isUsingGamepad() then
		pg.global.navMgr:FocusItemInThis(targetItem, CS.XGUI.Navigation.FocusEntryMode.Restore)
	end

	return true
end

function ChatComponent:jumpToInteractSourceMessage(channelId, messageId, playerId)
	if string.isNilOrEmpty(messageId) then
		if self.ctrl and not string.isNilOrEmpty(playerId) then
			self.ctrl:createNewChat(nil, playerId)

			return true
		end

		return false
	end

	if self:jumpToChatMessage(channelId, messageId) then
		return true
	end

	return false
end

function ChatComponent:getInteractMessagePlayerId(data)
	local playerIds = data and data.playerIds

	if type(playerIds) ~= "table" then
		return nil
	end

	return playerIds[#playerIds]
end

function ChatComponent:getInteractMessagePlayerName(data)
	local playerId = self:getInteractMessagePlayerId(data)
	local playerInfo = playerId and pg.game.chat:getPlayerInfo(playerId)

	if not playerInfo then
		return ""
	end

	local playerName = LuaUIUtils.getPlayerDisplayName(playerId, playerInfo.playerName)

	if #data.playerIds > 1 then
		return pg.getFormatText(pg.getGameString("CHAT_MANY_PEOPLE"), playerName, #data.playerIds)
	end

	return playerName
end

function ChatComponent:getInteractContentText(data)
	local extraInfo = data and data.extraInfo
	local interactionType = type(extraInfo) == "table" and extraInfo.interactionType or nil

	if interactionType == "like" then
		return pg.getGameString("CHAT_LIKE_MESSAGE")
	elseif interactionType == "reply" then
		return data.textContent or ""
	end

	return data and data.textContent or ""
end

function ChatComponent:renderInteractMessageContent(button, data, channelId, msgId, objectReference, sourceMessageData)
	local sourceUButton = objectReference:GetRefValue("sourceUButton")

	if sourceUButton then
		sourceUButton.luaRenderTooltip = nil
	end

	local isExpired = string.isNilOrEmpty(msgId) or sourceMessageData == nil

	if not isExpired and data.extraInfo.sourceEnum == Const.CHAT_LIKE_SOURCE_TYPE.Picture then
		self:renderInteractMessagePictureContent(button, data, sourceMessageData, channelId, msgId, objectReference)

		return
	end

	self:renderInteractMessageTextContent(button, data, channelId, msgId, isExpired, objectReference, sourceMessageData)
end

function ChatComponent:renderInteractMessagePictureContent(button, data, pictureMessageData, channelId, msgId, objectReference)
	local photographObjectReference = objectReference:GetRefValue("photographObjectReference")
	local replyUWidget = objectReference:GetRefValue("replyUWidget")

	replyUWidget:SetActive(false)
	button:TryChangePage("Type", 2)

	local sourcePlayerUSDFText = photographObjectReference:GetRefValue("txtNameUSDFText")
	local imglistUList = photographObjectReference:GetRefValue("listUList")

	if sourcePlayerUSDFText then
		ClientTextUtils.setText(sourcePlayerUSDFText, pg.getFormatText(pg.getGameString("CHAT_PLAYER_SAY_FORMAT"), pg.me.playerName, ""))
	end

	function imglistUList.luaRenderItem(imageButton, imageIndex, imageData)
		local objectReference = imageButton.transform:GetComponent("ObjectReference")

		if not objectReference then
			return
		end

		local imageUImage = objectReference:GetRefValue("imageUImage")

		self:renderPicturePhotoUImage(imageButton, imageData and imageData.messageData, imageUImage)
	end

	local buttonUButton = photographObjectReference:GetRefValue("buttonUButton")

	function buttonUButton.luaClick()
		self:jumpToInteractSourceMessage(channelId, msgId)
	end

	self:bindInteractMessageViewGamepad(buttonUButton)
	imglistUList:SetList({
		{
			tIndex = 0,
			messageData = pictureMessageData
		}
	})

	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

	ClientTextUtils.setText(txtNameUSDFText, self:getInteractContentText(data))
end

function ChatComponent:bindInteractMessageViewGamepad(viewUButton)
	viewUButton:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadConfirm)
	viewUButton:SetHotkeyActiveOnlyInCurrentItem(true)
	viewUButton:SetHotkeyConsoleBar("CONSOLE_BAR_VIEW", 0, self.view.mainConsoleBarTransform)
end

function ChatComponent:renderInteractMessageTextContent(button, data, channelId, msgId, isExpired, objectReference, sourceMessageData)
	button:TryChangePage("Type", 1)

	local isPetLikeMessage = data.interactionType == "like"
	local replyUWidget = objectReference:GetRefValue("replyUWidget")

	replyUWidget:SetActive(not isPetLikeMessage)

	local context = {
		channelId = channelId,
		msgId = msgId,
		expiredText = isExpired and pg.getGameString("CHAT_EXPIRED_MESSAGE") or nil,
		isPetLikeMessage = isPetLikeMessage,
		objectReference = objectReference,
		ownerButton = button,
		ownerData = data,
		sourceMessageData = sourceMessageData or {}
	}

	if data.extraInfo.sourceEnum == Const.CHAT_LIKE_SOURCE_TYPE.Pet then
		self:renderInteractMessagePetLikeContent(context)
	else
		self:renderInteractMessageTextDisplay(context)
	end

	local sourceUButton = objectReference:GetRefValue("sourceUButton")

	if not sourceUButton then
		return
	end

	self:bindInteractMessageSourceButton(sourceUButton, context)
end

function ChatComponent:renderInteractMessageTextDisplay(context)
	local objectReference = context.objectReference
	local textReplyTextPlus = objectReference:GetRefValue("textReplyTextPlus")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local replyInfo = context.ownerData.extraInfo.reply

	ClientTextUtils.setText(textReplyTextPlus, context.ownerData.textContent)
	self:renderInteractMessageSourceText(txtNameUSDFText, replyInfo and replyInfo.textContent or "", context.expiredText)
end

function ChatComponent:renderInteractMessagePetLikeContent(context)
	local objectReference = context.objectReference
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local sourceMessageData = context.sourceMessageData
	local petNameText = pg.game.chat:getTextContentFromExtraInfo(sourceMessageData.extraInfo)
	local sourceContent = pg.getFormatText(pg.getGameString("HYPER_LINK"), petNameText)

	self:renderInteractMessageSourceText(txtNameUSDFText, sourceContent, context.expiredText)
end

function ChatComponent:renderInteractMessageSourceText(txtNameUSDFText, sourceContent, expiredText)
	local resourceText = expiredText

	if not expiredText then
		resourceText = pg.getFormatText(pg.getGameString("CHAT_PLAYER_SAY_FORMAT"), pg.me.playerName, sourceContent)
	end

	ClientTextUtils.setText(txtNameUSDFText, resourceText)
end

function ChatComponent:bindInteractMessageSourceButton(sourceUButton, context)
	if context.expiredText then
		function sourceUButton.luaClick()
			pg.global.showBubbleMessageRaw(context.expiredText)
		end
	else
		function sourceUButton.luaClick()
			self:jumpToInteractSourceMessage(context.channelId, context.msgId)
		end
	end

	self:bindInteractMessageViewGamepad(sourceUButton)
end

function ChatComponent:renderInteractMessageItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local channelId, msgId = self:getInteractReplyMessageLocation(data)
	local sourceMessageData = pg.game.chat:getMessageInfo(channelId, msgId)

	self:renderInteractMessageBasicInfo(button, data, objectReference)
	self:renderInteractMessageContent(button, data, channelId, msgId, objectReference, sourceMessageData)
end

function ChatComponent:renderInteractMessageBasicInfo(button, data, objectReference)
	local avatarUButton = objectReference:GetRefValue("avatarUButton")
	local textPlayerTextPlus = objectReference:GetRefValue("textPlayerTextPlus")
	local textPathUSDFText = objectReference:GetRefValue("textPathUSDFText")
	local playerId = self:getInteractMessagePlayerId(data)
	local playerInfo = playerId and pg.game.chat:getPlayerInfo(playerId)

	if avatarUButton then
		LuaUIUtils.renderPlayerAvatarButton(avatarUButton, {
			hideLevel = true,
			canOpenInfoPlayerCard = true,
			playerId = playerId,
			playerInfo = playerInfo,
			avatarType = LuaUIUtils.PLAYER_AVATAR_TYPE.CHAT,
			playSparkAnimation = self.ctrl.sparkAnimationPlayerUid == playerId
		})

		avatarUButton.navForceNonInteractable = true

		avatarUButton:SetGamepadAction(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadStart)
		avatarUButton:SetHotkeyConsoleBar("CONSOLE_BAR_PROFILE", -2, self.view.mainConsoleBarTransform)
		avatarUButton:SetHotkeyForceHidden(true)

		if pg.game.input:isUsingGamepad() then
			self.ctrl:onNavFocusChange()
		end
	end

	if textPlayerTextPlus then
		ClientTextUtils.setText(textPlayerTextPlus, self:getInteractMessagePlayerName(data))
	end

	if textPathUSDFText then
		ClientTextUtils.setText(textPathUSDFText, self:getInteractPathText(data))
	end
end

function ChatComponent:getInteractPathText(data)
	if not data then
		return ""
	end

	if data.interactionType == "like" then
		if data.extraInfo.sourceEnum == Const.CHAT_LIKE_SOURCE_TYPE.Pet then
			return pg.getGameString("CHAT_LIKE_EMO_MESSAGE")
		end

		return pg.getGameString("CHAT_LIKE_IMAGE_MESSAGE")
	end

	if string.isNilOrEmpty(data.textContent) then
		return pg.getGameString("CHAT_LIKE_IMAGE_MESSAGE")
	end

	local channelId = self:getInteractReplyChannelId(data)
	local sourceType = self:getInteractSourceType(data)
	local channelName = self:getInteractChannelName(channelId, sourceType)

	return pg.getFormatText(pg.getGameString("CHAT_REQUEST_YOU"), channelName)
end

function ChatComponent:getInteractReplyChannelId(data)
	local extraInfo = data and data.extraInfo

	if extraInfo.replyType == "PRIVATE" then
		return extraInfo.replySender
	end

	local replyChannel = not string.isNilOrEmpty(extraInfo.replyChannel) and extraInfo.replyChannel or data.target

	if not string.isNilOrEmpty(replyChannel) then
		return replyChannel
	elseif not string.isNilOrEmpty(data.sourceGroupId) then
		return data.sourceGroupId
	elseif not string.isNilOrEmpty(extraInfo.liker) then
		return extraInfo.liker
	end

	return nil
end

function ChatComponent:getInteractSourceType(data)
	local extraInfo = data and data.extraInfo

	return extraInfo and (extraInfo.replyType or extraInfo.sourceType)
end

function ChatComponent:getInteractChannelName(channelId, sourceType)
	local isWorldChannel = channelId == pg.game.chat.channelType.World or pg.game.chat:isWorldChatGroupId(channelId)

	if isWorldChannel then
		return pg.game.chat:getWorldChatChannelName(channelId)
	elseif sourceType == Const.CHAT_TYPE.FRIEND or channelId == pg.game.chat.channelType.Friend then
		return pg.getGameString("CHAT_CHANNEL_FRIEND")
	elseif sourceType == Const.CHAT_TYPE.GROUP then
		local chatGroup = pg.game.chat:getFriendChatGroup(channelId)

		return chatGroup and pg.game.chat:getChatGroupDisplayName(chatGroup)
	elseif sourceType == Const.CHAT_TYPE.PRIVATE then
		local playerInfo = pg.game.chat:getPlayerInfo(channelId)

		return playerInfo and playerInfo.playerName or pg.getGameString("CHAT_CHANNEL_PRIVATE")
	end

	return nil
end

function ChatComponent:renderPlayerMessageContent(button, index, data, messageEle)
	local isPictureMessage = self:isPictureMessage(data)
	local messagePageType = playerMessagePageTypeMap[data.subType]

	if isPictureMessage then
		messagePageType = playerMessagePageTypeMap[SubMessageType.Picture]
	end

	button:TryChangePage("Type", messagePageType)

	if isPictureMessage then
		self:renderPictureMessageItem(button, index, data)
	elseif data.subType == SubMessageType.Text then
		self:renderTextMessageItem(button, messageEle, data)
	elseif data.subType == SubMessageType.JumpShared then
		self:renderJumpSharedMessageItem(button, data)
	elseif data.subType == SubMessageType.FriendCard then
		self:renderFriendCardMessageItem(button, data)
	elseif data.subType == SubMessageType.HomeSeasonMutationGift then
		self:renderHomeSeasonMutationGiftMessageItem(button, data)
	elseif data.subType == SubMessageType.Emoji then
		self:renderEmojiMessageItem(button, data)
	elseif data.subType == SubMessageType.Team then
		self:renderInviteMessageItem(button, messageEle, data)
	elseif data.subType == SubMessageType.Audio then
		self:renderAudioMessageItem(button, index, data)
	elseif data.subType == SubMessageType.DungeonInvite or data.subType == SubMessageType.PVPInvite or data.subType == SubMessageType.EnterWorld or data.subType == SubMessageType.PhotographyStudioInvite then
		self:renderInviteMessageItem(button, messageEle, data)
	elseif data.subType == SubMessageType.HomeCampInvite then
		self:renderInviteMessageItem(button, messageEle, data)
	elseif data.subType == SubMessageType.HomeSeasonCelebrationInvite then
		self:renderInviteMessageItem(button, messageEle, data)
	elseif data.subType == SubMessageType.Gift then
		self:renderGiftMessageItem(button, data)
	end
end

function ChatComponent:renderGiftMessageItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local lotteryGiftUButton = objectReference:GetRefValue("lotteryGiftUButton")
	local lotteryGiftObjectReference = lotteryGiftUButton:GetComponent("ObjectReference")
	local bgUImage = lotteryGiftObjectReference:GetRefValue("bgUImage")
	local txtNameUSDFText = lotteryGiftObjectReference:GetRefValue("txtNameUSDFText")

	bgUImage.url = data.extraInfo.bgUrl

	bgUImage.gameObject:SetActiveEx(true)
	ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("CHAT_GIFT_CLICK_RECEIVE"))

	function lotteryGiftUButton.luaClick()
		self.model:invokeGiftFunction(data)
	end
end

function ChatComponent:renderPlayerMessageItem(button, index, data)
	local playerInfo = pg.game.chat:getPlayerInfo(data.playerId)
	local hooks = ChatComponent._platformHooks

	LuaUIUtils.renderPlayerInfo(button, data.playerId)

	local objectReference = button:GetComponent("ObjectReference")
	local textUButton = objectReference:GetRefValue("textUButton")
	local textObjectReference = textUButton:GetComponent("ObjectReference")

	self:renderPlayerChatBubble(textObjectReference, data.chatBubble, data.playerId)
	self:renderPlayerMessageHeader(button, data, playerInfo, hooks)

	local playerEle = button:GetChild("PlayerInfo"):GetComponent("UButton")

	self.ctrl:handlePlayerTooltip(playerEle, data, nil, true, true)

	playerEle.enabledTooltip = false

	local messageEle = button:GetChild("Pop")

	self:renderPlayerMessagePopName(button, messageEle, data, playerInfo, hooks)
	self:renderPlayerMessageContent(button, index, data, messageEle)
end

function ChatComponent:renderSystemNoticeMessageItem(button, data)
	if data.customTag then
		button:TryChangePage("Tag", data.customTag)
	else
		button:TryChangePage("Tag", 3)
	end

	local contentEle = button.transform:Find("TxtName"):GetComponent("UBaseText")

	contentEle.luaOnHyperlinkClick = nil
	contentEle.luaResolveHyperlinkEffect = nil

	if data.hyperLinkClick then
		contentEle.enabledHyperlink = true

		function contentEle.luaOnHyperlinkClick(action, content, contentRect)
			data.hyperLinkClick(findHyperlinkButton(contentRect, button), action, content)
		end

		function contentEle.luaResolveHyperlinkEffect()
			return data.hyperLinkEffect
		end
	else
		contentEle.enabledHyperlink = false
	end

	ClientTextUtils.setText(contentEle, data.textContent)
end

function ChatComponent:renderMarqueeMessageItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

	ClientTextUtils.setText(txtNameUSDFText, data.textContent)
end

function ChatComponent:renderTipsMessageItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

	txtNameUSDFText.luaOnHyperlinkClick = nil
	txtNameUSDFText.luaResolveHyperlinkEffect = nil

	if data.hyperLinkClick then
		txtNameUSDFText.enabledHyperlink = true

		function txtNameUSDFText.luaOnHyperlinkClick(action, content, contentRect)
			data.hyperLinkClick(action, content)
		end

		function txtNameUSDFText.luaResolveHyperlinkEffect()
			return data.hyperLinkEffect
		end
	else
		txtNameUSDFText.enabledHyperlink = false
	end

	ClientTextUtils.setText(txtNameUSDFText, data.textContent)
end

function ChatComponent:renderMessageItem(button, index, data)
	if data.tIndex == pg.game.chat.messageType.OtherPlayer or data.tIndex == pg.game.chat.messageType.SelfPlayer then
		self:renderPlayerMessageItem(button, index, data)
	elseif data.tIndex == pg.game.chat.messageType.Interact then
		self:renderInteractMessageItem(button, index, data)
	elseif data.tIndex == pg.game.chat.messageType.SystemNotice then
		self:renderSystemNoticeMessageItem(button, data)
	elseif data.tIndex == pg.game.chat.messageType.TimeStamp then
		ClientTextUtils.setText(button:GetChild("TxtName"):GetComponent("UBaseText"), LuaUIUtils.timeStampToUtcString(data.timeStamp))
	elseif data.tIndex == pg.game.chat.messageType.Marquee then
		self:renderMarqueeMessageItem(button, data)
	elseif data.tIndex == pg.game.chat.messageType.Tips then
		self:renderTipsMessageItem(button, data)
	end
end

function ChatComponent:renderAudioMessageItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local voiceUButton = objectReference:GetRefValue("voiceUButton")
	local voiceObjectReference = voiceUButton:GetComponent("ObjectReference")
	local speechTimeUBaseText = voiceObjectReference:GetRefValue("speechTimeUBaseText")
	local vxVoiceAnimation = voiceObjectReference:GetRefValue("vxVoiceAnimation")
	local textUSDFText = voiceObjectReference:GetRefValue("textUSDFText")
	local vxVoiceUWidget = voiceObjectReference:GetRefValue("vxVoiceUWidget")

	self:renderMessageTranslationLayout(voiceObjectReference, voiceUButton, data)

	local audioInfo = self:getAudioMessageInfo(data)

	ClientTextUtils.setText(speechTimeUBaseText, (audioInfo.duration or 0) .. "\"")

	local displayText = self:getMessageTranslationDisplayText(data)

	ClientTextUtils.setText(textUSDFText, string.isNilOrEmpty(displayText) and pg.getGameString("CANNOT_RECOGNIZE_WORD") or displayText)

	function voiceUButton.luaClick()
		pg.global.gmeManager:PlayRecordedFile(audioInfo.fileID, function(code, filePath)
			pg.game.speech:onPlayFileComplete(filePath)
		end)
	end

	self:bindAudioMessageTooltip(voiceUButton, data)

	if not self.listeningStateListener then
		self.listeningStateListener = {}
	end

	if self.listeningStateListener[audioInfo.fileID] then
		pg.game.speech:removeListeningStateListener(self.listeningStateListener[audioInfo.fileID])
	end

	self.listeningStateListener[audioInfo.fileID] = function(isListening, filePath)
		if not self.view then
			return
		end

		if filePath == pg.global.gmeManager:getRecordedFilePath(audioInfo.fileID) then
			vxVoiceUWidget:InvokeCallback(isListening and CS.XGUI.EInvokeTime.User1 or CS.XGUI.EInvokeTime.User2)
		else
			vxVoiceUWidget:InvokeCallback(CS.XGUI.EInvokeTime.User2)
		end
	end

	pg.game.speech:addListeningStateListener(self.listeningStateListener[audioInfo.fileID])
end

function ChatComponent:bindAudioMessageTooltip(voiceUButton, data)
	local canOpenTooltip = data.tIndex == pg.game.chat.messageType.OtherPlayer

	voiceUButton.enabledLongPress = canOpenTooltip
	voiceUButton.enabledTooltip = canOpenTooltip
	voiceUButton.tooltipMode = CS.XGUI.ETooltipMode.LongPressWithClick
	voiceUButton.tooltipTemplateUrl = "$UI_Node_ChatPanel_Message_Extension.prefab"
	voiceUButton.luaRenderTooltip = nil

	if not canOpenTooltip then
		return
	end

	function voiceUButton.luaRenderTooltip(btn, cmp)
		self:renderListOtherTooltip(cmp, data, btn)
	end
end

function ChatComponent:openPetCard(triggerButton, ownerButton, ownerData)
	if not self.petCardUIScene then
		self.petCardUIScene = pg.game.uiScene:getScene(UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE)

		if not self.petCardUIScene then
			self.petCardUIScene = pg.game.uiScene:getUISceneInst(UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE, AddressDataConst.PET_MANAGEMENT_PREVIEW_SCENE_Prefab, nil, PetCardSceneParams)
		end

		self.petCardUIScene:bindUICtrlKey(self.ctrl.module)
	end

	if self.petCardUIScene:checkLoaded() then
		pg.game.uiScene:switchToScene(UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE, true, true, nil, self.ctrl.module)
		triggerButton:OpenTooltipWithUrl("$UI_Pop_PetInfo_Tips.prefab")

		return
	end

	self.pendingPetCardContext = {
		triggerButton = triggerButton,
		ownerButton = ownerButton,
		ownerData = ownerData
	}

	if self.inLoadPetCardUIScene then
		return
	end

	self.inLoadPetCardUIScene = true

	local function onPetCardSceneLoaded(succeed)
		self.inLoadPetCardUIScene = false

		local pendingContext = self.pendingPetCardContext

		self.pendingPetCardContext = nil

		local canOpenPetCard = succeed and self.petCardUIScene and self:isPetCardTriggerValid(pendingContext)

		if not canOpenPetCard then
			return
		end

		pg.game.uiScene:switchToScene(UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE, true, true, nil, self.ctrl.module)
		self.petCardUIScene:setLocalEnv()
		pendingContext.triggerButton:OpenTooltipWithUrl("$UI_Pop_PetInfo_Tips.prefab")
	end

	self.petCardUIScene:startLoad(onPetCardSceneLoaded, PetCardSceneParams)
end

function ChatComponent:isPetCardTriggerValid(context)
	if not context or not self.ctrl.view then
		return false
	end

	if IsNil(context.triggerButton) or IsNil(context.ownerButton) then
		return false
	end

	local currentData = self.view.messageListUList:GetData(context.ownerButton)

	return currentData == context.ownerData
end

function ChatComponent:renderPetInfoCard(messageData, component)
	local extraInfo = messageData.extraInfo[Const.CHAT_EXTRA_TYPE.Pet]
	local decodedExtraInfo = json.decode(decompress(extraInfo))

	self:m_normalizeSharePetInfo(decodedExtraInfo)

	local componentReference = component:GetComponent("ObjectReference")
	local panelTransform = componentReference:GetRefValue("panelTransform")
	local objectReference = panelTransform:GetComponent("ObjectReference")
	local btnLikeUButton = objectReference:GetRefValue("btnLikeUButton")
	local txtLikeUSDFText = objectReference:GetRefValue("txtLikeUSDFText")

	self:bindPetCardLikeButton(btnLikeUButton, txtLikeUSDFText, messageData)

	self.petInfoCardDisplayState = self.petInfoCardDisplayState or {}

	local function ensurePetPreviewUIScene(callback)
		callback(self.petCardUIScene)
	end

	PetInfoCardDisplayUtils.render(component, decodedExtraInfo, {
		state = self.petInfoCardDisplayState,
		ensurePetPreviewUIScene = ensurePetPreviewUIScene
	})
end

function ChatComponent:bindPetCardLikeButton(btnLikeUButton, txtLikeUSDFText, messageData)
	self.petCardLikeContext = {
		messageId = messageData.messageId,
		btnLikeUButton = btnLikeUButton,
		txtLikeUSDFText = txtLikeUSDFText
	}

	self:refreshPetCardLikeInfo(btnLikeUButton, txtLikeUSDFText, messageData)

	function btnLikeUButton.luaClick()
		if messageData.likedByMe == true then
			return
		end

		local chatLikeInfo = self:getChatMessageLikeInfo(messageData)

		if not chatLikeInfo then
			return
		end

		pg.me:likeChatMessage(chatLikeInfo)
	end
end

function ChatComponent:refreshPetCardLikeInfo(btnLikeUButton, txtLikeUSDFText, messageData)
	btnLikeUButton:SetActive(true)
	btnLikeUButton:TryChangePage("Like", messageData.likedByMe == true and 1 or 0)
	ClientTextUtils.setText(txtLikeUSDFText, messageData.likeCount or 0)
end

function ChatComponent:onChatMessageUpdateItem(info)
	local context = self.petCardLikeContext

	if not info or not context or context.messageId ~= info.msgId then
		return
	end

	if IsNil(context.btnLikeUButton) or IsNil(context.txtLikeUSDFText) then
		self.petCardLikeContext = nil

		return
	end

	local messageData = pg.game.chat:getMessageInfo(info.channelId, info.msgId)

	if not messageData then
		return
	end

	self:refreshPetCardLikeInfo(context.btnLikeUButton, context.txtLikeUSDFText, messageData)
end

function ChatComponent:m_normalizeSharePetInfo(petInfo)
	if not Utils.isTable(petInfo) then
		return
	end

	petInfo.name = pg.getLocalizationText(petInfo.name)

	self:m_normalizeNumberKeyTable(petInfo.basePropertyList)
	self:m_normalizeNumberKeyTable(petInfo.attributeCacheMap)
	self:m_normalizeNumberKeyTable(petInfo.calculatedAttributeMap)
	self:m_normalizeNumberKeyTable(petInfo.extraSrcMap)

	if petInfo.selectTransmogScheme then
		self:m_normalizeNumberKeyTable(petInfo.selectTransmogScheme.holeIds)
	end

	petInfo.ratingStribng = petInfo.ratingStribng or petInfo.ratingString

	self:m_buildSharePetSkillInfoMap(petInfo)

	local calculatedAttributeMap = petInfo.calculatedAttributeMap

	if type(calculatedAttributeMap) ~= "table" then
		return
	end

	for i = Const.BASE_PROPERTY_HP_IDX, Const.BASE_PROPERTY_ATK_MAG_IDX do
		local attrName = PetManagementUtils.getPetOldPropAttrConstName(i)
		local attrId = AttributeConst[attrName]

		if attrId and calculatedAttributeMap[attrId] == nil and calculatedAttributeMap[i] ~= nil then
			calculatedAttributeMap[attrId] = calculatedAttributeMap[i]
		end
	end
end

function ChatComponent:m_buildSharePetSkillInfoMap(petInfo)
	if type(petInfo) ~= "table" or type(petInfo.skillInfoMap) == "table" then
		return
	end

	local skillAbilityMap = petInfo.skillAbilityMap

	if type(skillAbilityMap) ~= "table" then
		return
	end

	petInfo.skillInfoMap = {
		ultimate = self:m_buildSharePetSkillInfo(skillAbilityMap, "ultimate", AbilityConst.ULTIMATE_ABILITY),
		q = self:m_buildSharePetSkillInfo(skillAbilityMap, "q", AbilityConst.WEAPON_SKILL_ABILITY),
		e = self:m_buildSharePetSkillInfo(skillAbilityMap, "e", AbilityConst.WEAPON_SKILL_ABILITY2),
		explore = self:m_buildSharePetSkillInfo(skillAbilityMap, "explore", AbilityConst.EXPLORE_ABILITY)
	}
end

function ChatComponent:m_buildSharePetSkillInfo(skillAbilityMap, fieldName, abilityType)
	local abilityId = tonumber(skillAbilityMap[fieldName] or skillAbilityMap[abilityType] or skillAbilityMap[tostring(abilityType)])

	if abilityId == nil or abilityId == 0 or abilityId == AbilityConst.ABILITY_ID_EMPTY then
		return nil
	end

	return PetManagementDataHelper.getSkillInfosByAbilityId(abilityId, abilityType)
end

function ChatComponent:m_normalizeNumberKeyTable(data)
	if type(data) ~= "table" then
		return
	end

	local convertList = {}

	for key, value in pairs(data) do
		if type(value) == "table" then
			self:m_normalizeNumberKeyTable(value)
		end

		local numberKey = type(key) == "string" and tonumber(key) or nil

		if numberKey then
			convertList[#convertList + 1] = {
				oldKey = key,
				newKey = numberKey,
				value = value
			}
		end
	end

	for _, info in ipairs(convertList) do
		if data[info.newKey] == nil then
			data[info.newKey] = info.value
		end

		data[info.oldKey] = nil
	end
end

function ChatComponent:openItemCard(extraInfo, button)
	button:OpenTooltipWithUrl("$UI_Pb_PropInfoPanel.prefab")
end

function ChatComponent:getChatMessageLikeInfo(data)
	if type(data) ~= "table" or data.messageId == nil or string.isNilOrEmpty(data.playerId) then
		return nil
	end

	local sourceEnum

	if self:isPictureMessage(data) then
		sourceEnum = Const.CHAT_LIKE_SOURCE_TYPE.Picture
	elseif self:isPetMessage(data) then
		sourceEnum = Const.CHAT_LIKE_SOURCE_TYPE.Pet
	else
		return nil
	end

	local channelType = data.channelType
	local likeInfo = {
		Liker = pg.me.uid,
		SourceMsgId = data.messageId,
		SourceSender = data.playerId,
		SourceEnum = sourceEnum,
		likeCount = data.likeCount or 0,
		likedByMe = data.likedByMe == true
	}

	if channelType == pg.game.chat.channelType.Player then
		if string.isNilOrEmpty(data.channelId) then
			return nil
		end

		likeInfo.SourceType = Const.CHAT_TYPE.PRIVATE
		likeInfo.Target = data.channelId
		likeInfo.GroupId = data.channelId
	elseif channelType == pg.game.chat.channelType.Friend then
		likeInfo.SourceType = Const.CHAT_TYPE.FRIEND
		likeInfo.Targets = pg.game.chat:getFriendIdList()
		likeInfo.GroupId = pg.game.chat.channelType.Friend
	elseif channelType == pg.game.chat.channelType.Group then
		if string.isNilOrEmpty(data.channelId) then
			return nil
		end

		likeInfo.SourceType = Const.CHAT_TYPE.GROUP
		likeInfo.GroupId = data.channelId
	elseif channelType == pg.game.chat.channelType.Near then
		likeInfo.SourceType = Const.CHAT_TYPE.NEARBY
		likeInfo.GroupId = pg.game.chat.channelType.Near
	elseif channelType == pg.game.chat.channelType.World then
		local groupId = data.channelId

		if groupId == pg.game.chat.channelType.World then
			groupId = pg.me.worldChatGroupId
		end

		if string.isNilOrEmpty(groupId) then
			return nil
		end

		likeInfo.SourceType = Const.CHAT_TYPE.GROUP
		likeInfo.GroupId = groupId
	elseif channelType == pg.game.chat.channelType.Home then
		local groupId = data.channelId

		if groupId == pg.game.chat.channelType.Home then
			groupId = pg.game.chat:getHomeCampGroupId()
		end

		if string.isNilOrEmpty(groupId) then
			return nil
		end

		likeInfo.SourceType = Const.CHAT_TYPE.GROUP
		likeInfo.GroupId = groupId
	else
		return nil
	end

	return likeInfo
end

function ChatComponent:getPicturePhotoInfo(data)
	local pictureInfo = data and data.extraInfo and data.extraInfo[Const.CHAT_EXTRA_TYPE.Picture]

	if type(pictureInfo) == "string" then
		if string.isNilOrEmpty(pictureInfo) then
			return nil
		end

		return {
			onlyShow = true,
			url = pictureInfo,
			title = pg.getGameString("PHOTO"),
			chatLikeInfo = self:getChatMessageLikeInfo(data)
		}
	end

	if type(pictureInfo) ~= "table" then
		return nil
	end

	local photoInfo = Utils.deepCopyTable(pictureInfo)

	photoInfo.url = photoInfo.url or photoInfo.imageUrl or photoInfo.imgUrl or photoInfo.picture
	photoInfo.title = photoInfo.title or photoInfo.name or pg.getGameString("PHOTO")

	local hasPhotoData = photoInfo.url or photoInfo.sprite or photoInfo.path or photoInfo.photoId or photoInfo.isInRes or photoInfo.imgKey

	if not hasPhotoData then
		return nil
	end

	photoInfo.onlyShow = true
	photoInfo.chatLikeInfo = self:getChatMessageLikeInfo(data)

	return photoInfo
end

function ChatComponent:onImageClick(data)
	local photoInfo = self:getPicturePhotoInfo(data)

	if not photoInfo then
		return
	end

	local playerInfo = pg.game.chat:getPlayerInfo(data.playerId)
	local chatLikeInfo = self:getChatMessageLikeInfo(data)

	pg.global.ui:open(UIConst.UI_ID_CHAT_PHOTOGRAPH, {
		mode = 0,
		photoInfo = photoInfo,
		playerName = playerInfo and playerInfo.playerName or "",
		likeCount = data.likeCount or 0,
		chatLikeInfo = chatLikeInfo
	})
end
