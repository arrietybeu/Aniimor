-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Chat\\ImpChatMessage.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local ChatSystem = require("GameApp.Chat.ChatSystem")
local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local RedDotConst = require("Const.RedDotConst")
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local BulletNoticeCommonData = require("Data.bullet_notice_common_data")
local ClientConst = require("Const.ClientConst")
local AddressDataConst = require("Const.AddressDataConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local json = require("json")
local PlayerForbidConst = require("Common.Const.PlayerForbidConst")
local ChatSendResult = require("GameApp.Chat.ChatSendResult")
local NoticeDef = require("Common.NoticeDef")
local CommonSwitch = require("Common.CommonSwitch")
local UIConst = require("Const.UIConst")
local HomelandDemoCmdImplement = require("GameApp.CmdSocket.HomelandDemoCmdImplement")
local HomeSeasonMutationCollectionData = require("Data.home_season_mutation_collection_data")
local demoChatLogger = require("Core.Log.LoggerManager").getLogger("ImpChatMessage")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade

local function fillTeamInvitePlayerSessionId(extraInfo)
	if type(extraInfo) ~= "table" then
		return
	end

	local inviteInfo = extraInfo[Const.CHAT_EXTRA_TYPE.TeamInvite]

	if type(inviteInfo) ~= "table" or not string.isNilOrEmpty(inviteInfo.psnSessionId) then
		return
	end

	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.GetCurrentPlayerSessionId then
		return
	end

	local psnSessionId = PlatformBridgeLuaFacade.GetCurrentPlayerSessionId()

	if not string.isNilOrEmpty(psnSessionId) then
		inviteInfo.psnSessionId = psnSessionId
	end
end

function ChatSystem:sendMessage(originText, messageType, channelType, channelId, extraInfo, blockSwitchChannel)
	if not CommonSwitch.CHAT then
		pg.global.showBubbleMessage(NoticeDef.COMMON_SWITCH_CLOSE_TIP)

		return
	end

	if LuaUIUtils.checkFeatureForbid(PlayerForbidConst.PLAYER_SWITCH.PLAYER_CHAT) then
		return false
	end

	if ClientTextUtils.containsRichText(originText) then
		pg.global.showBubbleMessageRaw(pg.getGameString("CONTENT_CONTAINS_RICH_TEXT"))

		return false
	end

	if not self:checkCanSendMessage(channelType, channelId, true) then
		return false
	end

	extraInfo = extraInfo or {}
	extraInfo[Const.CHAT_EXTRA_TYPE.Language] = pg.game.setting:getLanguage()

	fillTeamInvitePlayerSessionId(extraInfo)

	local newMessageData = {
		tIndex = pg.game.chat.messageType.SelfPlayer,
		subType = messageType,
		channelId = channelId,
		textContent = originText,
		playerId = pg.me.uid,
		timeStamp = os.time(),
		extraInfo = extraInfo,
		channelType = channelType,
		chatBubble = pg.me.chatBubble
	}
	local text = messageType .. originText
	local sent = true

	if channelType == pg.game.chat.channelType.World then
		sent = pg.me:chatSendGroup(channelId, text, extraInfo, newMessageData, blockSwitchChannel)
	elseif channelType == pg.game.chat.channelType.Near then
		sent = pg.me:chatSendNearby(text, extraInfo, newMessageData, blockSwitchChannel)
	elseif channelType == pg.game.chat.channelType.Team then
		if pg.me:getCurTeamInfo().teamId ~= "" then
			sent = pg.me:chatSendTeam(text, extraInfo, newMessageData, blockSwitchChannel)
		else
			return false
		end
	elseif channelType == pg.game.chat.channelType.Player then
		sent = pg.me:chatSendPrivate(channelId, text, extraInfo, nil, newMessageData, blockSwitchChannel)
	elseif channelType == pg.game.chat.channelType.Friend then
		sent = pg.me:chatSendFriendGroup(text, extraInfo, newMessageData, blockSwitchChannel)
	elseif channelType == pg.game.chat.channelType.Home then
		sent = pg.me:chatSendHomeland(text, extraInfo, newMessageData, blockSwitchChannel)
	elseif channelType == pg.game.chat.channelType.Group then
		local group = self:getFriendChatGroup(channelId)

		if group and group.markForRemove then
			pg.global.showBubbleMessageRaw(pg.getGameString("CHAT_GROUP_NOT_EXIST"))
			self:removeChannel(channelId)

			return false
		end

		sent = pg.me:chatSendGroup(channelId, text, extraInfo, newMessageData, blockSwitchChannel)
	elseif channelType == pg.game.chat.channelType.Vehicle then
		sent = pg.me:chatSendVehicle(channelId, text, extraInfo, newMessageData, blockSwitchChannel)
	else
		return false
	end

	if sent == ChatSendResult.Abort then
		return false
	end

	self:onSendMessageSuccess(channelType, channelId)

	local isDemoMode = pg.space ~= nil and pg.space.demoMode == true or pg.me ~= nil and pg.me.space ~= nil and pg.me.space.demoMode == true

	if not isDemoMode then
		return true
	end

	local ok, err = xpcall(function()
		local demoChatText, demoChatSource

		if messageType == pg.game.chat.subMessageType.Text then
			demoChatText, demoChatSource = originText, "text"
		elseif messageType == pg.game.chat.subMessageType.Audio then
			local voiceRaw = extraInfo and extraInfo[Const.CHAT_EXTRA_TYPE.Voice]
			local voiceInfo = type(voiceRaw) == "table" and voiceRaw or type(voiceRaw) == "string" and json.decode(voiceRaw) or nil

			demoChatText, demoChatSource = voiceInfo and voiceInfo.text or nil, "voice"
		end

		if demoChatText ~= nil then
			HomelandDemoCmdImplement._onPlayerChatMessageSent(demoChatText, {
				channelType = channelType,
				channelId = channelId
			}, demoChatSource)
		end
	end, debug.traceback)

	if not ok then
		demoChatLogger:warn("homelandDemo chat hook failed err=%s", tostring(err))
	end

	return true
end

function ChatSystem:sendJumpSharedMessage(originText, channelType, channelId, jumpType, extra, blockSwitchChannel)
	local extraInfo = extra or {}

	extraInfo.jumpType = jumpType

	return self:sendMessage(originText, self.subMessageType.JumpShared, channelType, channelId, extraInfo, blockSwitchChannel)
end

function ChatSystem:sendGiftMessage(channelType, channelId, giftType, bgUrl, extra, blockSwitchChannel)
	local extraInfo = extra or {}

	extraInfo.giftType = giftType
	extraInfo.bgUrl = bgUrl

	return self:sendMessage("", self.subMessageType.Gift, channelType, channelId, extraInfo, blockSwitchChannel)
end

function ChatSystem:getHomeSeasonMutationCardText(cardInfo)
	local collectionInfo = HomeSeasonMutationCollectionData[cardInfo.itemId]
	local cropName = ClientTextUtils.getLocalizationText(collectionInfo.name)
	local textKey = string.isNilOrEmpty(cardInfo.requestId) and "HOMELAND_SEASON_CROP_CHAT_GIFT_DESC" or "HOMELAND_SEASON_CROP_CHAT_HELP_DESC"
	local text = pg.getFormatText(pg.getGameString(textKey), cropName)

	return ClientTextUtils.removeRichText(text)
end

function ChatSystem:sendHomeSeasonMutationGiftChatCard(targetUid, itemId)
	local cardInfo = {
		itemId = itemId
	}

	return self:sendMessage(self:getHomeSeasonMutationCardText(cardInfo), self.subMessageType.HomeSeasonMutationGift, self.channelType.Player, targetUid, {
		[Const.CHAT_EXTRA_TYPE.HomeSeasonMutationGift] = cardInfo
	})
end

function ChatSystem:sendHomeSeasonMutationHelpChatCard(targetUid, cardInfo)
	return self:sendMessage(self:getHomeSeasonMutationCardText(cardInfo), self.subMessageType.HomeSeasonMutationGift, self.channelType.Player, targetUid, {
		[Const.CHAT_EXTRA_TYPE.HomeSeasonMutationGift] = cardInfo
	})
end

function ChatSystem:recvChatRecord(result, resp)
	if result.status then
		self.friendChatGroupList = {}
		self.friendChatGroupId2Index = {}

		pg.me:queryPlayerInfoList(resp.PrivateChatRecords, self.queryPlayerInfoType.ChatRecord, true)

		local historyItems = {}

		for _, uid in ipairs(resp.PrivateChatRecords) do
			historyItems = pg.me:fillChatHistoryItems(historyItems, uid, "", Const.CHAT_TYPE.PRIVATE, 0, 50)
		end

		self:loadCachedChatGroup()
		self:checkHasRemoved(resp.GroupChatRecords)

		for _, groupId in ipairs(resp.GroupChatRecords) do
			if not self:isWorldChatGroupId(groupId) and not self:isHomeCampGroupId(groupId) then
				pg.me:getChatGroupStatus(groupId)
			end

			if self:markChannelHistoryPreloaded(groupId) then
				historyItems = pg.me:fillChatHistoryItems(historyItems, pg.me.uid, groupId, Const.CHAT_TYPE.GROUP, 0, 50)
			end
		end

		historyItems = pg.me:fillChatHistoryItems(historyItems, pg.me.uid, "", Const.CHAT_TYPE.FRIEND, 0, 50)
		historyItems = pg.me:fillChatHistoryItems(historyItems, pg.me.uid, "", Const.CHAT_TYPE.INTERACTION, 0, 50)

		if #historyItems > 0 then
			pg.me:chatBatchHistory(historyItems)
		end

		pg.global.gmeManager:InitApp()
	end
end

function ChatSystem:recvChatHistory(extraParam, result, resp)
	if result.status then
		local chatMessageDatas = {}
		local hasInteractionMessage = false

		if resp.Messages then
			local buildHistoryCommonMessageData = ChatSystem.buildHistoryCommonMessageData

			for _, message in ipairs(resp.Messages) do
				if not self:checkBlackList(message.Sender) then
					if message.Type == Const.CHAT_TYPE.PRIVATE then
						local channelId = message.Sender == pg.me.uid and message.Receiver or message.Sender
						local messageData = buildHistoryCommonMessageData(self, message, channelId, pg.game.chat.channelType.Player)

						chatMessageDatas[#chatMessageDatas + 1] = messageData
					elseif message.Type == Const.CHAT_TYPE.GROUP then
						local channelType = self.channelType.Group

						if self:isWorldChatGroupId(message.GroupId) then
							channelType = self.channelType.World
						elseif self:isHomeCampGroupId(message.GroupId) then
							channelType = self.channelType.Home
						end

						local messageData = buildHistoryCommonMessageData(self, message, message.GroupId, channelType)

						chatMessageDatas[#chatMessageDatas + 1] = messageData
					elseif message.Type == Const.CHAT_TYPE.FRIEND then
						local messageData = buildHistoryCommonMessageData(self, message, ChatSystem.channelType.Friend, pg.game.chat.channelType.Friend)

						chatMessageDatas[#chatMessageDatas + 1] = messageData
					elseif message.Type == Const.CHAT_TYPE.INTERACTION then
						local messageData, isNewMessage = self:buildInteractionMessageData(message.Sender, message.Receiver, message.GroupId, message.Msg, message.ExtraInfo, message.MsgId, message.Time)

						if messageData then
							hasInteractionMessage = true

							if isNewMessage then
								chatMessageDatas[#chatMessageDatas + 1] = messageData
							end
						end
					end

					self:setPlayerData(message.Sender, message.SenderInfo, true)
				end
			end
		end

		if #chatMessageDatas > 0 then
			local _h = ChatSystem._platformHooks

			if _h and type(_h.filterChatHistoryMessages) == "function" then
				chatMessageDatas = _h.filterChatHistoryMessages(self, chatMessageDatas, extraParam, result, resp) or {}
			end
		end

		if #chatMessageDatas > 0 then
			local channelId = chatMessageDatas[1].channelId

			self:rebuildChannelMessageIdIndex(channelId)

			local curMessageDatas = self.chatMessageListData[channelId] or {}
			local channelMessageIndex = self.messageId2MessageInfo[channelId] or {}
			local mergedMessageDatas = {}
			local sameCurIndex = 0
			local firstHistoryMessageData = chatMessageDatas[1]

			for curIndex, curMessageData in ipairs(curMessageDatas) do
				local isSameMessage = curMessageData.messageId ~= nil and curMessageData.messageId == firstHistoryMessageData.messageId

				if curMessageData.messageId == nil and firstHistoryMessageData.messageId == nil then
					isSameMessage = curMessageData.playerId == firstHistoryMessageData.playerId and curMessageData.timeStamp == firstHistoryMessageData.timeStamp
				end

				if isSameMessage then
					sameCurIndex = curIndex

					break
				end
			end

			local curEndIndex = sameCurIndex > 0 and sameCurIndex - 1 or #(curMessageDatas or {})

			for index = 1, curEndIndex do
				mergedMessageDatas[#mergedMessageDatas + 1] = curMessageDatas[index]
			end

			for index = 1, #chatMessageDatas do
				mergedMessageDatas[#mergedMessageDatas + 1] = chatMessageDatas[index]
			end

			local keepCount = self:getChatMessageKeepCount(chatMessageDatas[1].channelType)

			self.chatMessageListData[channelId] = self:buildLimitedHistoryMessageList(mergedMessageDatas, keepCount)

			self:rebuildChannelMessageIdIndex(channelId)
		end

		if hasInteractionMessage then
			self:sortInteractionMessages()
			facade:SendMessageCommand(MessageName.CHAT_MESSAGE_UPDATE, {
				channelId = self.channelType.Interact
			})
		end

		if #chatMessageDatas > 0 or hasInteractionMessage then
			facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)
		end

		if extraParam and extraParam.playerId and #chatMessageDatas > 0 then
			self:tryCreatePrivateChat(extraParam.playerId, true)
		end

		if extraParam and extraParam.groupId and #chatMessageDatas > 0 then
			self:tryCreateGroupChat(extraParam.groupId, true)
		end

		if extraParam and extraParam.isWorldChannelChange then
			facade:SendMessageCommand(MessageName.CHAT_WORLD_CHANNEL_CHANGE, extraParam.selectionKey)
		end
	end
end

function ChatSystem:buildInteractionMessageData(sender, receiver, groupId, message, extraInfo, msgId, timeStamp)
	extraInfo = extraInfo or {}

	local interactionType = extraInfo.interactionType

	if interactionType ~= "reply" and interactionType ~= "like" then
		return nil, false
	end

	local hasMessageId = not string.isNilOrEmpty(msgId)

	if hasMessageId and self.interactionMessageIdSet[msgId] then
		return nil, false
	end

	if hasMessageId then
		self.interactionMessageIdSet[msgId] = true
	end

	local sourceMsgId = extraInfo.replyMsgId or extraInfo.sourceMsgId
	local messageData

	if interactionType == "like" and not string.isNilOrEmpty(sourceMsgId) then
		messageData = self.interactionSourceMsgId2MessageData[sourceMsgId]
	end

	if messageData then
		messageData.playerIds[#messageData.playerIds + 1] = sender
		messageData.timeStamp = math.max(messageData.timeStamp, timeStamp)

		return messageData, false
	end

	messageData = self:createInteractionMessageData(sender, receiver, groupId, message, extraInfo, msgId, interactionType, timeStamp)

	if interactionType == "like" and not string.isNilOrEmpty(sourceMsgId) then
		self.interactionSourceMsgId2MessageData[sourceMsgId] = messageData
	end

	return messageData, true
end

function ChatSystem:createInteractionMessageData(sender, receiver, groupId, message, extraInfo, msgId, interactionType, timeStamp)
	local messageType = self.subMessageType.Text
	local originText = message or ""

	if interactionType == "reply" then
		messageType, originText = self:getMessageTypeAndOriginText(message)
	end

	self.interactionMessageSequence = self.interactionMessageSequence + 1

	local messageData = {
		tIndex = self.messageType.Interact,
		subType = messageType,
		channelId = self.channelType.Interact,
		textContent = originText,
		playerIds = {
			sender
		},
		receiver = receiver,
		sourceGroupId = groupId,
		timeStamp = timeStamp,
		sequence = self.interactionMessageSequence,
		messageId = msgId,
		extraInfo = extraInfo,
		interactionType = interactionType,
		channelType = self.channelType.Interact
	}

	return messageData
end

function ChatSystem:buildHistoryCommonMessageData(message, channelId, channelType)
	local isSelfSend = message.Sender == pg.me.uid
	local messageType, originText = self:getMessageTypeAndOriginText(message.Msg)

	return {
		tIndex = isSelfSend and self.messageType.SelfPlayer or self.messageType.OtherPlayer,
		subType = messageType,
		textContent = originText,
		playerId = message.Sender,
		chatBubble = message.SenderInfo and message.SenderInfo.chatBubble or nil,
		timeStamp = message.Time,
		messageId = message.MsgId,
		extraInfo = message.ExtraInfo,
		likeCount = message.LikeCount or 0,
		likedByMe = message.LikedByMe == true,
		channelId = channelId,
		channelType = channelType
	}
end

function ChatSystem:_addNewMessageImpl(messageData, blockSwitchChannel, skipTimeStamp)
	if self:checkBlackList(messageData.playerId) then
		return
	end

	if self.chatMessageListData[messageData.channelId] == nil then
		self.chatMessageListData[messageData.channelId] = {}
	end

	if messageData.messageId ~= nil and self:getMessageIndex(messageData.channelId, messageData.messageId) then
		return
	end

	if not skipTimeStamp then
		self:tryInsertTimeStamp(messageData)
	end

	local channelMessages = self.chatMessageListData[messageData.channelId]

	channelMessages[#channelMessages + 1] = messageData

	if messageData.messageId ~= nil then
		self.messageId2MessageInfo = self.messageId2MessageInfo or {}
		self.messageId2MessageInfo[messageData.channelId] = self.messageId2MessageInfo[messageData.channelId] or {}
		self.messageId2MessageInfo[messageData.channelId][messageData.messageId] = #channelMessages
	end

	local channelOrderChanged = false
	local isPrivateOrGroup = messageData.channelType == self.channelType.Player or messageData.channelType == self.channelType.Group

	if isPrivateOrGroup then
		local previousChannelIndex = self:getChannelIndex(messageData.channelId)

		self:sortChannelByTime()

		local currentChannelIndex = self:getChannelIndex(messageData.channelId)

		channelOrderChanged = previousChannelIndex ~= currentChannelIndex
	end

	if blockSwitchChannel then
		return
	end

	facade:SendMessageCommand(MessageName.ADD_NEW_CHAT_MESSAGE, {
		channelId = messageData.channelId,
		messageData = messageData,
		channelOrderChanged = channelOrderChanged
	})
end

function ChatSystem:removeMessage(messageDataOrId, options)
	options = options or {}

	local targetMessageData = type(messageDataOrId) == "table" and messageDataOrId or nil
	local targetMessageId = targetMessageData and targetMessageData.messageId or messageDataOrId
	local targetChannelId = options.channelId or targetMessageData and targetMessageData.channelId or nil

	local function removeFromChannel(channelId, messageList)
		if type(messageList) ~= "table" then
			return false
		end

		for i = #messageList, 1, -1 do
			local messageData = messageList[i]
			local sameMessage = targetMessageData ~= nil and messageData == targetMessageData
			local sameMessageId = targetMessageId ~= nil and messageData and messageData.messageId == targetMessageId

			if sameMessage or sameMessageId then
				table.remove(messageList, i)
				self:rebuildChannelMessageIdIndex(channelId)

				if channelId ~= nil and (messageData.channelType == self.channelType.Player or messageData.channelType == self.channelType.Group) then
					self:sortChannelByTime()
				end

				if not options.silent then
					facade:SendMessageCommand(MessageName.CHAT_MESSAGE_UPDATE, {
						channelId = channelId
					})
				end

				if options.updateRedDot ~= false then
					facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)
				end

				return true
			end
		end

		return false
	end

	if targetChannelId ~= nil then
		return removeFromChannel(targetChannelId, self.chatMessageListData and self.chatMessageListData[targetChannelId])
	end

	for channelId, messageList in pairs(self.chatMessageListData or EMPTY_TABLE) do
		if removeFromChannel(channelId, messageList) then
			return true
		end
	end

	return false
end

function ChatSystem:updateChatMessageLike(channelId, msgId, likeCount, likedByMe)
	if msgId == nil or type(self.chatMessageListData) ~= "table" then
		return
	end

	local function updateMessageInChannel(targetChannelId)
		local messageList = self.chatMessageListData[targetChannelId]

		if type(messageList) ~= "table" then
			return false
		end

		local index = self:getMessageIndex(targetChannelId, msgId)
		local messageData = index and messageList[index] or nil

		if not messageData then
			return false
		end

		messageData.likeCount = likeCount

		if likedByMe ~= nil then
			messageData.likedByMe = likedByMe
		end

		facade:SendMessageCommand(MessageName.CHAT_MESSAGE_UPDATE_ITEM, {
			channelId = targetChannelId,
			msgId = msgId
		})

		return true
	end

	if channelId ~= nil and updateMessageInChannel(channelId) then
		return
	end

	for targetChannelId in pairs(self.chatMessageListData) do
		if updateMessageInChannel(targetChannelId) then
			return
		end
	end
end

function ChatSystem:getDeleteChatMessageChannelId(user, target, group, chatType)
	if chatType == Const.CHAT_TYPE.PRIVATE then
		if pg.me and user == pg.me.uid then
			return target
		end

		return user
	elseif chatType == Const.CHAT_TYPE.GROUP then
		return group
	elseif chatType == Const.CHAT_TYPE.WORLD then
		if group ~= nil and group ~= "" and type(group) ~= "table" then
			return group
		end

		if pg.me and not string.isNilOrEmpty(pg.me.worldChatGroupId) then
			return pg.me.worldChatGroupId
		end

		return self.channelType.World
	elseif chatType == Const.CHAT_TYPE.NEARBY then
		return self.channelType.Near
	elseif chatType == Const.CHAT_TYPE.FRIEND then
		return self.channelType.Friend
	elseif chatType == Const.CHAT_TYPE.MULTICAST then
		if group ~= nil and group ~= "" and type(group) ~= "table" then
			return group
		end

		if target ~= nil and target ~= "" and type(target) ~= "table" then
			return target
		end
	end

	return nil
end

function ChatSystem:deleteChatMessage(user, target, group, chatType, msgID)
	local channelId = self:getDeleteChatMessageChannelId(user, target, group, chatType)

	if channelId ~= nil and channelId ~= "" then
		if self:removeMessage(msgID, {
			channelId = channelId
		}) then
			return true
		end

		if chatType == Const.CHAT_TYPE.GROUP and channelId ~= self.channelType.World then
			return self:removeMessage(msgID, {
				channelId = self.channelType.World
			})
		end

		return false
	end

	return self:removeMessage(msgID)
end

function ChatSystem:addNewMessage(messageData, blockSwitchChannel, options, skipTimeStamp)
	local _h = ChatSystem._platformHooks

	if _h and _h.addNewMessage then
		return _h.addNewMessage(self, messageData, blockSwitchChannel, options, skipTimeStamp)
	end

	self:_addNewMessageImpl(messageData, blockSwitchChannel, skipTimeStamp)
end

function ChatSystem:addCommonSystemNotice(bulletId, ...)
	local bulletInfo = BulletNoticeCommonData[bulletId]
	local text = pg.getFormatText(pg.getLocalizationText(bulletInfo.txt), ...)
	local icon = bulletInfo.icon

	for _, tab in pairs(bulletInfo.channel) do
		local channelId = self.channelType.System
		local channelType = self.channelType.System

		if tab == self.tabType.Team then
			channelId = pg.me.teamId or self.channelType.Team
		elseif tab == self.tabType.Public then
			channelId = pg.me.worldChatGroupId
		elseif tab == self.tabType.Notice then
			channelId = self.channelType.System
		end

		local messageData = {
			isImportantSystemNotice = false,
			tIndex = self.messageType.SystemNotice,
			subType = self.subMessageType.Text,
			channelId = channelId,
			textContent = text,
			timeStamp = os.time(),
			channelType = channelType
		}

		self:addNewMessage(messageData, true)

		local settingAllowsBullet = pg.game.chat:checkChatSettingState(channelType, self.settingType.Bullet, channelId)
		local shouldShowBullet = bulletInfo.ignorRemoveChannel or settingAllowsBullet

		if shouldShowBullet then
			facade:SendMessageCommand(MessageName.ADD_NEW_CHAT_MESSAGE, {
				isCommonBullet = true,
				messageData = messageData,
				icon = icon,
				speed = bulletInfo.speed
			})
		end
	end
end

function ChatSystem:tryInsertTimeStamp(messageData)
	local lastMessage = self.chatMessageListData[messageData.channelId][#self.chatMessageListData[messageData.channelId]]

	if lastMessage and messageData.timeStamp - lastMessage.timeStamp > 300 then
		local timeStampMessage = {
			tIndex = ChatSystem.messageType.TimeStamp,
			timeStamp = messageData.timeStamp
		}

		table.insert(self.chatMessageListData[messageData.channelId], timeStampMessage)
	end
end

function ChatSystem:addNewChannel(channelInfo)
	channelInfo.createTimeStamp = channelInfo.createTimeStamp or Time.secondCache
	channelInfo.timeStamp = Time.secondCache
	self.channelListData[#self.channelListData + 1] = channelInfo

	self:trySwitchChannel(channelInfo.channelId)
end

function ChatSystem:recvBatchChatHistory(result, resp)
	if not result.status then
		return
	end

	for _, info in ipairs(resp.Results) do
		local extraParam = {}

		if info.Type == "PRIVATE" and not string.isNilOrEmpty(info.Target) and info.Target ~= pg.me.uid then
			extraParam.playerId = info.Target
		end

		local isNormalGroup = not string.isNilOrEmpty(info.GroupId) and not self:isWorldChatGroupId(info.GroupId) and not self:isHomeCampGroupId(info.GroupId)

		if isNormalGroup then
			extraParam.groupId = info.GroupId
		end

		self:recvChatHistory(extraParam, result, info)
	end
end

function ChatSystem:sortChannelByTime()
	local topChannelListData = {}
	local bottomChannelListData = {}

	for _, channelData in ipairs(self.channelListData) do
		local channelId = channelData.channelId
		local messageListData = self.chatMessageListData[channelId]
		local latestMessageTime

		if messageListData and #messageListData > 0 then
			latestMessageTime = messageListData[#messageListData].timeStamp
			channelData.timeStamp = latestMessageTime
		end

		if channelData.tIndex ~= 1 then
			channelData.sortTimeStamp = latestMessageTime or channelData.createTimeStamp or channelData.timeStamp or 0

			if self:checkTopChannel(channelData.channelId) then
				topChannelListData[#topChannelListData + 1] = channelData
			else
				bottomChannelListData[#bottomChannelListData + 1] = channelData
			end
		end
	end

	if #topChannelListData > 0 then
		topChannelListData = self:sortTimeDESC(topChannelListData)
	end

	if #bottomChannelListData > 0 then
		bottomChannelListData = self:sortTimeDESC(bottomChannelListData)
	end

	if #topChannelListData > 0 and #bottomChannelListData > 0 then
		topChannelListData[#topChannelListData + 1] = {
			tIndex = 1
		}
	end

	table.mergeList(topChannelListData, bottomChannelListData)

	self.channelListData = topChannelListData
end

function ChatSystem:tryCreatePrivateChat(playerId, shouldSelected)
	local hasExist = false

	if not self.chatMessageListData[playerId] then
		pg.me:chatHistory(playerId, "", Const.CHAT_TYPE.PRIVATE, 0, 50, {
			playerId = playerId
		})

		self.chatMessageListData[playerId] = {}
	end

	for i = 1, #self.channelListData do
		if self.channelListData[i].playerId == playerId then
			hasExist = true
		end
	end

	if not hasExist then
		local playerInfo = self:getPlayerInfo(playerId)

		if type(playerInfo) ~= "table" then
			if self.logger and self.logger.warn then
				self.logger:warn("tryCreatePrivateChat missing playerInfo playerId=%s", tostring(playerId))
			end

			return false
		end

		local channelInfo = {
			tIndex = 0,
			type = ChatSystem.channelType.Player,
			playerId = playerId,
			channelId = playerId,
			state = playerInfo.online and 0 or 1,
			label = playerInfo.playerName,
			loginTime = playerInfo.loginTime,
			lastLogoutTime = playerInfo.lastLogoutTime,
			id = playerId
		}

		self:addNewChannel(channelInfo)
	elseif shouldSelected then
		self:trySwitchChannel(playerId)
	end

	return true
end

function ChatSystem:tryCreateGroupChat(groupId, shouldSelect)
	if self:isWorldChatGroupId(groupId) or self:isHomeCampGroupId(groupId) then
		return
	end

	local hasExist = false

	if not self.chatMessageListData[groupId] then
		pg.me:chatHistory(pg.me.uid, groupId, Const.CHAT_TYPE.GROUP, 0, 50, {
			groupId = groupId
		})

		self.chatMessageListData[groupId] = {}
	end

	for i = 1, #self.channelListData do
		if self.channelListData[i].playerId == groupId or self.channelListData[i].channelId == groupId then
			hasExist = true
		end
	end

	if not hasExist then
		local chatGroupData = self:getFriendChatGroup(groupId)

		if chatGroupData then
			local channelInfo = {
				state = 1,
				tIndex = 0,
				type = ChatSystem.channelType.Group,
				channelId = groupId,
				label = chatGroupData.label,
				headIconKey = chatGroupData.headIconKey
			}

			self:addNewChannel(channelInfo)
		end
	elseif shouldSelect then
		self:trySwitchChannel(groupId)
	end
end

function ChatSystem:trySwitchChannel(selectedChannelId)
	self:sortChannelByTime()

	for _, channel in ipairs(self.channelListData) do
		local channelId = channel.channelId or channel.playerId

		if channelId == selectedChannelId then
			facade:SendMessageCommand(MessageName.CHANNEL_LIST_UPDATE, {
				selectionKey = "id:" .. tostring(selectedChannelId)
			})

			return
		end
	end
end

function ChatSystem:refreshChannelList(playerId)
	local playerInfo, channelInfo

	for i = 1, #self.channelListData do
		channelInfo = self.channelListData[i]

		if channelInfo.playerId == playerId then
			playerInfo = self.playerDatas[playerId]
			channelInfo.state = playerInfo.online and 0 or 1
			channelInfo.loginTime = playerInfo.loginTime
			channelInfo.lastLogoutTime = playerInfo.lastLogoutTime

			facade:SendMessageCommand(MessageName.CHANNEL_LIST_UPDATE)

			break
		end
	end
end

function ChatSystem:getChannelIndex(playerId)
	local index = -1

	for i = 1, #self.channelListData do
		if self.channelListData[i].channelId == playerId then
			index = i

			break
		end
	end

	return index
end

function ChatSystem:removeChannel(playerId)
	self:removeTopChannel(playerId)

	local index = self:getChannelIndex(playerId)

	if index ~= -1 then
		table.remove(self.channelListData, index)
		self:cleanChannelMessage(playerId)
		pg.me:chatRecordDelete(playerId)
		facade:SendMessageCommand(MessageName.CHANNEL_LIST_UPDATE)
	end
end

function ChatSystem:checkTopChannel(playerId)
	return table.contains(self.topChannels, playerId)
end

function ChatSystem:getTopChannelCount()
	local count = 0

	for _, channelData in pairs(self.channelListData) do
		local channelId = channelData.channelId

		if self:checkTopChannel(channelId) then
			count = count + 1
		end
	end

	return count
end

function ChatSystem:addTopChannel(playerId)
	if not table.contains(self.topChannels, playerId) then
		self.topChannels[#self.topChannels + 1] = playerId

		local topChannelKey = pg.me.uid .. ClientConst.PrefKey.ChatPrivateTopChannel

		pg.global.prefsCacheUtils:setString(topChannelKey, table.concat(self.topChannels, "|"))
		self:sortChannelByTime()
		facade:SendMessageCommand(MessageName.CHANNEL_LIST_UPDATE, {
			selectionKey = "id:" .. playerId
		})
	end
end

function ChatSystem:removeTopChannel(playerId, setBottom)
	local removeIndex = -1

	for index, channel in ipairs(self.topChannels) do
		if channel == playerId then
			removeIndex = index

			break
		end
	end

	if removeIndex ~= -1 then
		table.remove(self.topChannels, removeIndex)
		pg.global.prefsCacheUtils:setString(pg.me.uid .. ClientConst.PrefKey.ChatPrivateTopChannel, table.concat(self.topChannels, "|"))
		self:sortChannelByTime()
	end

	if not setBottom then
		return
	end

	facade:SendMessageCommand(MessageName.CHANNEL_LIST_UPDATE, {
		selectionKey = "id:" .. playerId
	})
end

function ChatSystem:recvChatSend(msgId, result, resp, extraInfo, messageData, blockSwitchChannel)
	if result.status then
		if not messageData then
			return
		end

		local _, message = self:getMessageTypeAndOriginText(resp.Message)

		messageData.messageId = msgId
		messageData.textContent = message

		self:showEntityMessageBubbleByUid(pg.me.uid, messageData)
		self:addNewMessage(messageData, blockSwitchChannel)
	elseif result.errmsg == Const.Friend.TID_MS_CHAT_SERVICE_CHATCONTENT_LENGTH then
		pg.global.showBubbleMessageRaw(pg.getGameString("CHAT_CONTENT_LENGTH_LIMIT"))
	elseif result.errmsg == "TID_MS_CHAT_SERVICE_IN_CHATBAN" then
		local banTo = tonumber(resp.BanTo)

		if not banTo or banTo < Time.secondCache then
			return
		end

		local banTimeLeft = LuaUIUtils.getCountDownString(banTo - Time.secondCache, UIConst.TimeType.Short, true)

		pg.global.showBubbleMessageRaw(pg.getFormatText(pg.getGameString("CHAT_BAN_TEXT"), banTimeLeft))
	elseif result.errmsg == "TID_MS_CHAT_SERVICE_CHAT_CONTAINS_SENSITIVE_WORD" then
		pg.global.showBubbleMessageRaw(pg.getGameString("INPUT_TEXT_CONTAINS_SENSITIVE"))
	end
end

function ChatSystem:getMessageTypeAndOriginText(message)
	local messageType = tonumber(string.sub(message, 1, 2))

	if messageType then
		return messageType, string.sub(message, 3)
	else
		return self.subMessageType.Text, message
	end
end

function ChatSystem:buildReceivedPlayerMessageData(sender, senderInfo, message, extraInfo, msgId, channelId, channelType)
	local chatBubbleId = senderInfo and senderInfo.chatBubble

	if chatBubbleId ~= nil then
		self.playerId2LatestChatBubbleId[sender] = chatBubbleId
	end

	local messageType, originText = self:getMessageTypeAndOriginText(message)

	self:syncDungeonInvitePlayerStateFromMessage(sender, messageType, extraInfo)

	return {
		tIndex = self.messageType.OtherPlayer,
		subType = messageType,
		channelId = channelId,
		textContent = originText,
		playerId = sender,
		chatBubble = chatBubbleId,
		timeStamp = os.time(),
		messageId = msgId,
		extraInfo = extraInfo,
		channelType = channelType
	}
end

function ChatSystem:syncDungeonInvitePlayerStateFromMessage(sender, messageType, extraInfo)
	if messageType ~= self.subMessageType.DungeonInvite then
		return
	end

	local inviteInfo = extraInfo and extraInfo[Const.CHAT_EXTRA_TYPE.TeamInvite]

	if not inviteInfo then
		return
	end

	self:setPlayerData(sender, {
		uid = sender,
		teamId = inviteInfo.teamId,
		teamDungeonSceneId = inviteInfo.dungeonId
	})
end

function ChatSystem:_recvPrivateChatPushImpl(sender, senderInfo, target, message, extraInfo, msgId)
	if pg.game.chat:checkBlackList(sender) then
		return
	end

	local messageData = self:buildReceivedPlayerMessageData(sender, senderInfo, message, extraInfo, msgId, sender, pg.game.chat.channelType.Player)

	pg.me:queryPlayerInfo(sender, nil, true, function(playerData)
		self:tryCreatePrivateChat(sender)
		self:addNewMessage(messageData)
		facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)
	end)
end

function ChatSystem:recvPrivateChatPush(sender, senderInfo, target, message, extraInfo, msgId)
	local _h = ChatSystem._platformHooks

	if _h and _h.recvPrivateChatPush then
		return _h.recvPrivateChatPush(self, sender, senderInfo, target, message, extraInfo, msgId)
	end

	self:_recvPrivateChatPushImpl(sender, senderInfo, target, message, extraInfo, msgId)
end

function ChatSystem:_recvGroupChatPushImpl(sender, senderInfo, groupId, message, extraInfo, channelType, msgId)
	if pg.game.chat:checkBlackList(sender) then
		return
	end

	if sender == pg.me.uid then
		return
	end

	self:setPlayerData(sender, senderInfo)

	local messageData = self:buildReceivedPlayerMessageData(sender, senderInfo, message, extraInfo, msgId, groupId, channelType)

	if channelType == self.channelType.Group then
		self:tryCreateGroupChat(groupId)
	end

	self:addNewMessage(messageData)
	pg.game.chat:showEntityMessageBubbleByUid(messageData.playerId, messageData)
	facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)
end

function ChatSystem:recvGroupChatPush(sender, senderInfo, groupId, message, extraInfo, channelType, msgId)
	local _h = ChatSystem._platformHooks

	if _h and _h.recvGroupChatPush then
		return _h.recvGroupChatPush(self, sender, senderInfo, groupId, message, extraInfo, channelType, msgId)
	end

	self:_recvGroupChatPushImpl(sender, senderInfo, groupId, message, extraInfo, channelType, msgId)
end

function ChatSystem:_recvFriendChatPushImpl(sender, senderInfo, message, extraInfo, msgId)
	if pg.game.chat:checkBlackList(sender) then
		return
	end

	if sender == pg.me.uid then
		return
	end

	self:setPlayerData(sender, senderInfo)

	local channelType = pg.game.chat.channelType.Friend
	local messageData = self:buildReceivedPlayerMessageData(sender, senderInfo, message, extraInfo, msgId, channelType, channelType)

	self:addNewMessage(messageData)
	facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)
end

function ChatSystem:recvFriendChatPush(sender, senderInfo, message, extraInfo, msgId)
	local _h = ChatSystem._platformHooks

	if _h and _h.recvFriendChatPush then
		return _h.recvFriendChatPush(self, sender, senderInfo, message, extraInfo, msgId)
	end

	self:_recvFriendChatPushImpl(sender, senderInfo, message, extraInfo, msgId)
end

function ChatSystem:_recvWorldChatPushImpl(sender, senderInfo, target, message, extraInfo, msgId)
	if pg.game.chat:checkBlackList(sender) then
		return
	end

	if sender == pg.me.uid then
		return
	end

	self:setPlayerData(sender, senderInfo)

	local messageData = self:buildReceivedPlayerMessageData(sender, senderInfo, message, extraInfo, msgId, self.channelType.World, pg.game.chat.channelType.World)

	self:addNewMessage(messageData)
	facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)
end

function ChatSystem:recvWorldChatPush(sender, senderInfo, target, message, extraInfo, msgId)
	local _h = ChatSystem._platformHooks

	if _h and _h.recvWorldChatPush then
		return _h.recvWorldChatPush(self, sender, senderInfo, target, message, extraInfo, msgId)
	end

	self:_recvWorldChatPushImpl(sender, senderInfo, target, message, extraInfo, msgId)
end

function ChatSystem:_recvNearbyChatPushImpl(sender, senderInfo, message, extraInfo, msgId)
	if pg.game.chat:checkBlackList(sender) then
		return
	end

	if sender == pg.me.uid then
		return
	end

	self:setPlayerData(sender, senderInfo)

	local messageData = self:buildReceivedPlayerMessageData(sender, senderInfo, message, extraInfo, msgId, self.channelType.Near, pg.game.chat.channelType.Near)

	pg.game.chat:showEntityMessageBubbleByUid(messageData.playerId, messageData)
	self:addNewMessage(messageData)
	facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)
end

function ChatSystem:recvNearbyChatPush(sender, senderInfo, message, extraInfo, msgId)
	local _h = ChatSystem._platformHooks

	if _h and _h.recvNearbyChatPush then
		return _h.recvNearbyChatPush(self, sender, senderInfo, message, extraInfo, msgId)
	end

	self:_recvNearbyChatPushImpl(sender, senderInfo, message, extraInfo, msgId)
end

local function compareInteractionMessages(leftMessage, rightMessage)
	local leftTimeStamp = leftMessage.timeStamp or 0
	local rightTimeStamp = rightMessage.timeStamp or 0

	if leftTimeStamp ~= rightTimeStamp then
		return leftTimeStamp < rightTimeStamp
	end

	local leftSequence = leftMessage.sequence or 0
	local rightSequence = rightMessage.sequence or 0

	return leftSequence < rightSequence
end

function ChatSystem:sortInteractionMessages()
	local messageList = self.chatMessageListData[self.channelType.Interact]

	if not messageList then
		return
	end

	table.sort(messageList, compareInteractionMessages)
	self:rebuildChannelMessageIdIndex(self.channelType.Interact)
end

function ChatSystem:recvInteractionChatPush(sender, senderInfo, receiver, groupId, message, extraInfo, msgId)
	local _h = ChatSystem._platformHooks

	if _h and _h.recvInteractionChatPush then
		return _h.recvInteractionChatPush(self, sender, senderInfo, receiver, groupId, message, extraInfo, msgId)
	end

	self:_recvInteractionChatPushImpl(sender, senderInfo, receiver, groupId, message, extraInfo, msgId)
end

function ChatSystem:_recvInteractionChatPushImpl(sender, senderInfo, receiver, groupId, message, extraInfo, msgId)
	if pg.game.chat:checkBlackList(sender) then
		return
	end

	local messageData, isNewMessage = self:buildInteractionMessageData(sender, receiver, groupId, message, extraInfo, msgId, os.time())

	if not messageData then
		return
	end

	self:setPlayerData(sender, senderInfo)

	if not isNewMessage then
		self:sortInteractionMessages()
		facade:SendMessageCommand(MessageName.CHAT_MESSAGE_UPDATE, {
			channelId = self.channelType.Interact
		})
		facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)

		return
	end

	self:addNewMessage(messageData, true, nil, true)
	self:sortInteractionMessages()
	facade:SendMessageCommand(MessageName.ADD_NEW_CHAT_MESSAGE, {
		channelId = self.channelType.Interact,
		messageData = messageData
	})
	facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)
end

function ChatSystem:recvSystemNotice(desc, customTag, hyperLinkClick, isImportant, hyperLinkEffect)
	local messageData = {
		tIndex = self.messageType.SystemNotice,
		subType = self.subMessageType.Text,
		channelId = self.channelType.System,
		customTag = customTag,
		textContent = desc,
		hyperLinkClick = hyperLinkClick,
		hyperLinkEffect = hyperLinkEffect,
		timeStamp = os.time(),
		channelType = pg.game.chat.channelType.System,
		isImportantSystemNotice = isImportant or false
	}

	self:addNewMessage(messageData)
end

function ChatSystem:recvChannelSystemNotice(channelId, channelType, desc, customTag, hyperLinkClick, isImportant, hyperLinkEffect)
	local messageData = {
		tIndex = self.messageType.SystemNotice,
		subType = self.subMessageType.Text,
		channelId = channelId,
		customTag = customTag,
		textContent = desc,
		hyperLinkClick = hyperLinkClick,
		hyperLinkEffect = hyperLinkEffect,
		timeStamp = os.time(),
		channelType = channelType,
		isImportantSystemNotice = isImportant or false
	}

	self:addNewMessage(messageData)
end

function ChatSystem:recvTipNotice(channelId, channelType, desc, customTag, hyperLinkClick, hyperLinkEffect)
	local messageData = {
		tIndex = self.messageType.Tips,
		subType = self.subMessageType.Text,
		channelId = channelId,
		customTag = customTag,
		textContent = desc,
		hyperLinkClick = hyperLinkClick,
		hyperLinkEffect = hyperLinkEffect,
		timeStamp = os.time(),
		channelType = channelType
	}

	self:addNewMessage(messageData)
end

function ChatSystem:recvWorldSystemNotice(desc, hyperLinkClick, hyperLinkEffect)
	local messageData = {
		customTag = 3,
		tIndex = self.messageType.SystemNotice,
		subType = self.subMessageType.Text,
		channelId = self.channelType.World,
		textContent = desc,
		hyperLinkClick = hyperLinkClick,
		hyperLinkEffect = hyperLinkEffect,
		timeStamp = os.time(),
		channelType = pg.game.chat.channelType.World
	}

	self:addNewMessage(messageData)
end

function ChatSystem:recvWorldMarqueeNotice(desc)
	local messageData = {
		tIndex = self.messageType.Marquee,
		subType = self.subMessageType.Text,
		channelId = self.channelType.World,
		textContent = desc,
		timeStamp = os.time(),
		channelType = self.channelType.World
	}

	self:addNewMessage(messageData)
end

function ChatSystem:getLocationText(cardInfo)
	local posInfo = ""
	local pos = {
		x = cardInfo.pos[1],
		y = cardInfo.pos[2],
		z = cardInfo.pos[3]
	}
	local curBlockAreaId = cardInfo.sceneId ~= 501 and pg.game.map:inWhichBlock(cardInfo.sceneId, false, pos, true) or nil

	if curBlockAreaId and curBlockAreaId > 0 then
		local MapBlockConfigData = require("Data.map_block_config_data")
		local areaName = ClientTextUtils.getLocalizationText(MapBlockConfigData[curBlockAreaId].areaName)

		posInfo = pg.getFormatText(pg.getGameString("CHAT_SEND_LOCATION_WORLD"), areaName, string.format("%.0f", cardInfo.pos[1]), string.format("%.0f", cardInfo.pos[2]), string.format("%.0f", cardInfo.pos[3]))
	elseif cardInfo.sceneId == 501 then
		posInfo = pg.getFormatText(pg.getGameString("CHAT_SEND_LOCATION_ARK"), pg.getGameString("CHAT_CHANNEL_ARK"), string.format("%.0f", cardInfo.pos[1]), string.format("%.0f", cardInfo.pos[2]), string.format("%.0f", cardInfo.pos[3]), cardInfo.lineNo or 1)
	end

	return posInfo
end

function ChatSystem:prefetchGroupMemberPsnBlockStates(uids)
	if not pg or not pg.me or type(pg.me.requestPsnBlockStates) ~= "function" then
		return
	end

	local platformIds = {}

	for _, uid in ipairs(uids) do
		if uid ~= pg.me.uid then
			local info = self:getPlayerInfo(uid)
			local platformId = info and info.platformUserId

			if not string.isNilOrEmpty(platformId) then
				platformIds[#platformIds + 1] = platformId
			end
		end
	end

	if #platformIds > 0 then
		pg.me:requestPsnBlockStates(platformIds)
	end
end

function ChatSystem:getChatGroupDisplayName(chatGroup, rawName)
	if type(chatGroup) ~= "table" then
		return rawName or ""
	end

	local groupName = rawName or chatGroup.chatGroupName or ""
	local _h = ChatSystem._platformHooks

	if _h and _h.getChatGroupDisplayName then
		local masterInfo = self:getPlayerInfo(chatGroup.master)

		groupName = _h.getChatGroupDisplayName(self, chatGroup.groupId, chatGroup.master, masterInfo, groupName) or groupName
	end

	return groupName
end

function ChatSystem:getChatNoticePlayerName(uid, playerInfo, rawName)
	local playerName = rawName or playerInfo and playerInfo.playerName or ""
	local _h = ChatSystem._platformHooks

	if _h and _h.renderChatGroupMemberNoticePlayerName then
		playerName = _h.renderChatGroupMemberNoticePlayerName(self, uid, playerInfo, playerName) or playerName
	else
		playerName = _h and _h.getChatNoticePlayerName and _h.getChatNoticePlayerName(self, uid, playerInfo, playerName) or playerName
	end

	return playerName
end

function ChatSystem:formatChatNoticePlayerLink(uid, playerInfo)
	local playerName = self:getChatNoticePlayerName(uid, playerInfo)

	return string.format("<link=\"%s\"><color=#5d90eb><u>%s</u></color></link>", uid, playerName)
end

function ChatSystem:updateChatGroup(operatorUid, groupId, uids, chatGroupName)
	if self:isWorldChatGroupId(groupId) or self:isHomeCampGroupId(groupId) then
		return
	end

	local groupIndex = self.friendChatGroupId2Index[groupId] or #self.friendChatGroupList + 1
	local isNewGroup = self.friendChatGroupId2Index[groupId] == nil
	local shouldNoticeGroupNameChange = false

	if not uids or #uids == 0 or not table.contains(uids, pg.me.uid) then
		if operatorUid == pg.me.uid then
			self:removeChatGroup(groupId)
		else
			local chatGroup = self.friendChatGroupList[groupIndex]

			if chatGroup then
				local operatorInfo = self:getPlayerInfo(operatorUid)

				if not uids or #uids == 0 then
					chatGroup.notExist = true
				end

				chatGroup.markForRemove = true

				if chatGroup.notExist then
					local displayGroupName = self:getChatGroupDisplayName(chatGroup, chatGroupName)
					local noticeText = pg.getFormatText(pg.getGameString("CHAT_GROUP_DISBANDED"), displayGroupName)

					self:recvSystemNotice(noticeText)
				else
					self:showChatGroupRemovedNotice(chatGroup, operatorUid, operatorInfo)
				end
			end
		end
	else
		local label = chatGroupName .. pg.getFormatText(pg.getGameString("COUNT_OF_TOTAL"), #uids, Const.CHAT.CHAT_GROUP_MAX_MEMBER_COUNT)

		if self.friendChatGroupList[groupIndex] and self.friendChatGroupList[groupIndex].chatGroupName ~= chatGroupName then
			local oldChatGroup = self.friendChatGroupList[groupIndex]
			local newChatGroup = {
				groupId = groupId,
				master = uids[1],
				chatGroupName = chatGroupName
			}
			local oldDisplayGroupName = self:getChatGroupDisplayName(oldChatGroup)
			local newDisplayGroupName = self:getChatGroupDisplayName(newChatGroup)
			local tipText = pg.getFormatText(pg.getGameString("CHANGE_GROUP_NAME_SUCCESS"), oldDisplayGroupName, newDisplayGroupName)

			pg.global.showBubbleMessageRaw(tipText)

			shouldNoticeGroupNameChange = true
		end

		local iconKey = self:getChatGroupHeadIconKey(groupIndex)

		self.friendChatGroupList[groupIndex] = {
			groupId = groupId,
			uids = uids,
			chatGroupName = chatGroupName,
			label = label,
			master = uids[1],
			headIconKey = iconKey
		}
		self.friendChatGroupId2Index[groupId] = groupIndex

		for _, channel in ipairs(self.channelListData) do
			if channel.channelId == groupId then
				channel.label = label

				break
			end
		end
	end

	pg.me:queryPlayerInfoList(uids, nil, true, nil, function()
		self:handleMemberChanged(operatorUid, groupId, uids, isNewGroup)
		self:prefetchGroupMemberPsnBlockStates(uids)

		if shouldNoticeGroupNameChange then
			local operatorInfo = self:getPlayerInfo(uids[1])
			local playerName = self:formatChatNoticePlayerLink(uids[1], operatorInfo)
			local displayGroupName = self:getChatGroupDisplayName(self:getFriendChatGroup(groupId), chatGroupName)
			local noticeText = pg.getFormatText(pg.getGameString("CHANGE_GROUP_NAME_MESSAGE"), playerName, displayGroupName)

			self:recvTipNotice(groupId, self.channelType.Group, noticeText, nil, function(action, content)
				if not action then
					return
				end

				LuaUIUtils.openInfoPlayerCard({
					playerId = action,
					openType = ClientConst.PlayerInfoOpenType.Chat
				})
			end, "other")
		end
	end)
	facade:SendMessageCommand(MessageName.FRIEND_CHAT_GROUP_UPDATE)

	if operatorUid == pg.me.uid and isNewGroup then
		pg.global.ui.chat:createNewGroupChat(groupId)
	end

	self:saveChatGroupCache()
end

function ChatSystem:getChatGroupHeadIconKey(groupIndex)
	local iconKey = self.friendChatGroupList[groupIndex] and self.friendChatGroupList[groupIndex].headIconKey or ""

	if not self.friendChatGroupList[groupIndex] or string.isNilOrEmpty(self.friendChatGroupList[groupIndex].headIconKey) then
		local keyOffset = math.random(1, #self.chatGroupHeadIconAvailableKeys)

		iconKey = self.chatGroupHeadIconAvailableKeys[keyOffset]

		table.remove(self.chatGroupHeadIconAvailableKeys, keyOffset)
	end

	return iconKey
end

function ChatSystem:saveChatGroupCache()
	local chatGroupForCache = {}

	for _, group in ipairs(self.friendChatGroupList) do
		local isNormalGroup = not self:isWorldChatGroupId(group.groupId) and not self:isHomeCampGroupId(group.groupId)

		if isNormalGroup then
			local info = string.format("%s|%s|%s|%s", group.groupId, group.chatGroupName, group.master, group.headIconKey)

			chatGroupForCache[#chatGroupForCache + 1] = info
		end
	end

	pg.global.prefsCacheUtils:setString(pg.me.uid .. ClientConst.PrefKey.ChatGroupBasicInfo, table.concat(chatGroupForCache, ","))
end

function ChatSystem:loadCachedChatGroup()
	local chatGroupForCache = pg.global.prefsCacheUtils:getString(pg.me.uid .. ClientConst.PrefKey.ChatGroupBasicInfo, ""):split(",")

	for _, group in ipairs(chatGroupForCache) do
		if not string.isNilOrEmpty(group) then
			local groupInfo = group:split("|")
			local groupId = groupInfo[1]
			local cachedGroupKey = pg.me.uid .. ClientConst.PrefKey.ChatGroupMember .. groupId
			local cachedUids = pg.global.prefsCacheUtils:getString(cachedGroupKey, ""):split("|")
			local label = groupInfo[2] .. pg.getFormatText(pg.getGameString("COUNT_OF_TOTAL"), #cachedUids, Const.CHAT.CHAT_GROUP_MAX_MEMBER_COUNT)
			local groupIndex = #self.friendChatGroupList + 1

			self.friendChatGroupList[groupIndex] = {
				groupId = groupId,
				uids = cachedUids,
				chatGroupName = groupInfo[2],
				label = label,
				master = groupInfo[3],
				headIconKey = tonumber(groupInfo[4])
			}

			for index, key in ipairs(self.chatGroupHeadIconAvailableKeys) do
				if key == tonumber(groupInfo[4]) then
					table.remove(self.chatGroupHeadIconAvailableKeys, index)

					break
				end
			end

			self.friendChatGroupId2Index[groupId] = groupIndex
		end
	end
end

function ChatSystem:checkHasRemoved(groupIds)
	for _, group in ipairs(self.friendChatGroupList) do
		if not self:isHomeCampGroupId(group.groupId) and not table.contains(groupIds, group.groupId) then
			group.markForRemove = true

			pg.me:getChatGroupStatus(group.groupId)
		end
	end
end

function ChatSystem:handleChatGroupNotExist(groupId)
	local groupIndex = self.friendChatGroupId2Index[groupId]

	if not groupIndex then
		return
	end

	local chatGroup = self.friendChatGroupList[groupIndex]

	chatGroup.notExist = true
	chatGroup.markForRemove = true

	if not chatGroup.leaveNoticeShown then
		chatGroup.leaveNoticeShown = true

		local displayGroupName = self:getChatGroupDisplayName(chatGroup)
		local noticeText = pg.getFormatText(pg.getGameString("CHAT_GROUP_DISBANDED"), displayGroupName)

		self:recvSystemNotice(noticeText)
	end

	facade:SendMessageCommand(MessageName.FRIEND_CHAT_GROUP_UPDATE)
end

function ChatSystem:showChatGroupRemovedNotice(chatGroup, operatorUid, operatorInfo)
	if chatGroup.leaveNoticeShown then
		return
	end

	chatGroup.leaveNoticeShown = true
	operatorUid = operatorUid or chatGroup.master

	local function showNotice(playerData)
		local operatorName = ""

		if playerData then
			operatorName = self:formatChatNoticePlayerLink(operatorUid, playerData)
		end

		local displayGroupName = self:getChatGroupDisplayName(chatGroup)
		local noticeText = pg.getFormatText(pg.getGameString("CHAT_GROUP_REMOVED"), operatorName, displayGroupName)

		self:recvSystemNotice(noticeText, nil, function(button, action, content)
			if not action then
				return
			end

			LuaUIUtils.openInfoPlayerCard({
				playerId = action,
				openType = ClientConst.PlayerInfoOpenType.Chat
			})
		end, false, "other")
	end

	if operatorInfo then
		showNotice(operatorInfo)
	elseif not string.isNilOrEmpty(operatorUid) then
		pg.me:queryPlayerInfo(operatorUid, nil, true, showNotice)
	else
		showNotice(nil)
	end
end

function ChatSystem:removeChatGroup(groupId)
	local groupIndex = self.friendChatGroupId2Index[groupId]

	if groupIndex then
		table.insert(self.chatGroupHeadIconAvailableKeys, self.friendChatGroupList[groupIndex].headIconKey)
		table.remove(self.friendChatGroupList, groupIndex)

		self.friendChatGroupId2Index = {}

		for index, group in ipairs(self.friendChatGroupList) do
			self.friendChatGroupId2Index[group.groupId] = index
		end

		self:removeChannel(groupId)
		self:saveChatGroupCache()
	end

	facade:SendMessageCommand(MessageName.FRIEND_CHAT_GROUP_UPDATE)
end

function ChatSystem:getFriendChatGroupList()
	return self.friendChatGroupList
end

function ChatSystem:getFriendChatGroup(groupId)
	return self.friendChatGroupList[self.friendChatGroupId2Index[groupId]]
end

function ChatSystem:handleMemberChanged(operatorUid, groupId, uids, isNewGroup)
	local cachedGroupKey = pg.me.uid .. ClientConst.PrefKey.ChatGroupMember .. groupId
	local addedPlayerName = {}
	local originUids = pg.global.prefsCacheUtils:getString(cachedGroupKey, ""):split("|")
	local hasCachedMember = false

	for _, uid in ipairs(originUids) do
		if not string.isNilOrEmpty(uid) then
			hasCachedMember = true

			break
		end
	end

	local useInitialGroupMembers = isNewGroup and not hasCachedMember and not string.isNilOrEmpty(operatorUid)

	for _, uid in ipairs(uids) do
		local isAddedMember = not table.contains(originUids, uid)

		if useInitialGroupMembers then
			isAddedMember = uid ~= operatorUid
		end

		if isAddedMember then
			local playerInfo = self:getPlayerInfo(uid)

			if playerInfo then
				addedPlayerName[#addedPlayerName + 1] = self:formatChatNoticePlayerLink(uid, playerInfo)
			end
		end
	end

	local chatGroup = self:getFriendChatGroup(groupId)

	if chatGroup and chatGroup.master == pg.me.uid and operatorUid ~= pg.me.uid then
		for _, uid in ipairs(originUids) do
			if not table.contains(uids, uid) then
				local playerInfo = self:getPlayerInfo(uid)

				if playerInfo and uid ~= pg.me.uid then
					local playerName = self:formatChatNoticePlayerLink(uid, playerInfo)
					local noticeText = ClientTextUtils.concatByLanguage(playerName, pg.getGameString("LEAVE_CHAT_GROUP_WARNING"))

					self:recvTipNotice(groupId, self.channelType.Group, noticeText, nil, function(action, content)
						if not action then
							return
						end

						LuaUIUtils.openInfoPlayerCard({
							playerId = action,
							openType = ClientConst.PlayerInfoOpenType.Chat
						})
					end, "other")
				end
			end
		end
	end

	if #addedPlayerName > 0 then
		local operatorInfo = self:getPlayerInfo(operatorUid)

		if operatorInfo then
			local operatorName = self:formatChatNoticePlayerLink(operatorUid, operatorInfo)
			local noticeText = pg.getFormatText(pg.getGameString("CHAT_GROUP_INVITE_MEMBERS"), operatorName, table.concat(addedPlayerName, pg.getGameString("INTERVAL_SYMBOL")))

			self:recvTipNotice(groupId, self.channelType.Group, noticeText, nil, function(action, content)
				if not action then
					return
				end

				LuaUIUtils.openInfoPlayerCard({
					playerId = action,
					openType = ClientConst.PlayerInfoOpenType.Chat
				})
			end, "other")
		end
	end

	pg.global.prefsCacheUtils:setString(pg.me.uid .. ClientConst.PrefKey.ChatGroupMember .. groupId, table.concat(uids, "|"))
end
