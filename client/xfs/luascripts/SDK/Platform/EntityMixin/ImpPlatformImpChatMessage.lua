-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\EntityMixin\\ImpPlatformImpChatMessage.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local M = {}
local MessageName = require("Const.MessageName")
local PlatformChatFilterService = require("SDK.Platform.PlatformChatFilterService")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local logger = require("SDK.Platform.PlatformLogger")

function M:isHomelandGroup(groupId)
	return groupId == self:getHomeCampGroupId()
end

function M:shouldFilterInboundMessage(messageData)
	if pg.global.platform:isPS() then
		local shouldFilter = messageData and (messageData.tIndex == self.messageType.OtherPlayer or messageData.tIndex == self.messageType.SelfPlayer) and not string.isNilOrEmpty(messageData.playerId)

		return shouldFilter
	end

	return messageData and messageData.tIndex == self.messageType.OtherPlayer and not string.isNilOrEmpty(messageData.playerId)
end

function M:getChatGroupDisplayName(groupId, masterUid, masterInfo, rawName)
	if string.isNilOrEmpty(rawName) then
		return rawName
	end

	local _, isVisible = PlatformNameMaskService:checkNameVisibilityNow(masterUid, masterInfo, PlatformNameMaskService.Action.ChatGroupChannelName)

	if isVisible == false then
		return " "
	end

	return rawName
end

function M:getChatNoticePlayerName(uid, playerInfo, rawName)
	return M.renderChatGroupMemberNoticePlayerName(self, uid, playerInfo, rawName)
end

function M:ensurePlatformRawMessages()
	if type(self.platformRawChatMessageListData) ~= "table" then
		self.platformRawChatMessageListData = {}
	end

	if type(self.platformRawMessageId2MessageInfo) ~= "table" then
		self.platformRawMessageId2MessageInfo = {}
	end
end

function M.cloneMessageList(messages)
	local out = {}

	if type(messages) == "table" then
		for i, messageData in ipairs(messages) do
			out[i] = messageData
		end
	end

	return out
end

function M.areMessageListsEqual(left, right)
	local leftCount = type(left) == "table" and #left or 0
	local rightCount = type(right) == "table" and #right or 0

	if leftCount ~= rightCount then
		return false
	end

	for index = 1, leftCount do
		if left[index] ~= right[index] then
			return false
		end
	end

	return true
end

function M.makeRawMessageSet(messages)
	local set = {}

	if type(messages) == "table" then
		for _, messageData in ipairs(messages) do
			if type(messageData) == "table" then
				set[messageData] = true
			end
		end
	end

	return set
end

function M:addRawPlatformMessage(messageData)
	if type(messageData) ~= "table" or messageData.channelId == nil then
		return
	end

	M.ensurePlatformRawMessages(self)

	local channelId = messageData.channelId

	if type(self.platformRawChatMessageListData[channelId]) ~= "table" then
		self.platformRawChatMessageListData[channelId] = {}
	end

	table.insert(self.platformRawChatMessageListData[channelId], messageData)

	if messageData.messageId ~= nil then
		self.platformRawMessageId2MessageInfo[messageData.messageId] = messageData
	end
end

function M:addVisiblePlatformMessage(messageData, blockSwitchChannel, options, skipTimeStamp)
	self:_addNewMessageImpl(messageData, blockSwitchChannel, skipTimeStamp)

	if type(options) == "table" and type(options.onAdded) == "function" then
		options.onAdded(messageData)
	end
end

function M:rebuildMessageIdIndex()
	self.messageId2MessageInfo = {}

	for channelId, messageList in pairs(self.chatMessageListData or EMPTY_TABLE) do
		self.messageId2MessageInfo[channelId] = {}

		for i, messageData in ipairs(messageList) do
			if type(messageData) == "table" and messageData.messageId ~= nil then
				self.messageId2MessageInfo[channelId][messageData.messageId] = i
			end
		end
	end
end

function M.notifyChannelUpdates(channelIds)
	local count = 0

	for channelId in pairs(channelIds or EMPTY_TABLE) do
		count = count + 1

		facade:SendMessageCommand(MessageName.CHAT_MESSAGE_UPDATE, {
			channelId = channelId
		})
	end

	facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)

	return count
end

function M:shouldShowPlatformMessage(messageData, playerInfo)
	if not M.shouldFilterInboundMessage(self, messageData) then
		return true
	end

	local resolvedPlayerInfo = playerInfo or self:getPlayerInfo(messageData.playerId)

	if type(resolvedPlayerInfo) ~= "table" then
		return true
	end

	local shouldFilter, _, context = PlatformChatFilterService:shouldFilterMessage(messageData, resolvedPlayerInfo)

	return shouldFilter ~= true and context.reason ~= PlatformChatFilterService.REASON_TARGET_COMMUNICATION_PENDING
end

function M.makeInboundMessageCallbacks(selfRef, messageData, blockSwitchChannel, options, playerInfo, chatFilterDecision, skipTimeStamp)
	local callbacks = {}
	local added = false
	local pendingFilterResolveStarted = false
	local schedulePendingFilterResolve

	function callbacks.removeAddedMessage()
		if added and type(selfRef.removeMessage) == "function" then
			selfRef:removeMessage(messageData, {
				updateRedDot = true
			})
		end

		added = false
	end

	function callbacks.removeIfFiltered(latestPlayerInfo)
		local resolvedPlayerInfo = latestPlayerInfo or playerInfo
		local shouldRemove, decision = PlatformChatFilterService:shouldRemoveAfterResolve(messageData, resolvedPlayerInfo)

		if shouldRemove then
			callbacks.removeAddedMessage()

			return true
		end

		if decision == PlatformChatFilterService.Decision.Pending then
			schedulePendingFilterResolve(resolvedPlayerInfo)
		end

		return false
	end

	function schedulePendingFilterResolve(latestPlayerInfo)
		if pendingFilterResolveStarted then
			return
		end

		pendingFilterResolveStarted = true

		PlatformChatFilterService:resolvePendingMessage(messageData, latestPlayerInfo or playerInfo, function(decision)
			if decision == PlatformChatFilterService.Decision.Block then
				callbacks.removeAddedMessage()
			end
		end)
	end

	function callbacks.addMessageOnce()
		if added then
			return
		end

		selfRef:_addNewMessageImpl(messageData, blockSwitchChannel, skipTimeStamp)

		added = true

		if type(options.onAdded) == "function" then
			options.onAdded(messageData)
		end

		if chatFilterDecision == PlatformChatFilterService.Decision.Pending then
			schedulePendingFilterResolve(playerInfo)
		end
	end

	return callbacks
end

function M:addNewMessage(messageData, blockSwitchChannel, options, skipTimeStamp)
	options = options or {}

	if not M.shouldFilterInboundMessage(self, messageData) then
		M.addVisiblePlatformMessage(self, messageData, blockSwitchChannel, options, skipTimeStamp)

		return
	end

	M.addRawPlatformMessage(self, messageData)

	local playerInfo = options.playerInfo or self:getPlayerInfo(messageData.playerId)

	if type(playerInfo) ~= "table" then
		M.addVisiblePlatformMessage(self, messageData, blockSwitchChannel, options, skipTimeStamp)

		return
	end

	local chatFiltered, chatFilterDecision, chatFilterContext = PlatformChatFilterService:shouldFilterMessage(messageData, playerInfo)

	if chatFiltered then
		return
	end

	if chatFilterContext.reason == PlatformChatFilterService.REASON_TARGET_COMMUNICATION_PENDING then
		return
	end

	local callbacks = M.makeInboundMessageCallbacks(self, messageData, blockSwitchChannel, options, playerInfo, chatFilterDecision, skipTimeStamp)

	if chatFilterDecision == PlatformChatFilterService.Decision.Pending then
		callbacks.addMessageOnce()
	end

	if callbacks.removeIfFiltered(playerInfo) then
		return
	end

	callbacks.addMessageOnce()
end

function M:refreshPlatformFilteredChatMessages(reason)
	M.ensurePlatformRawMessages(self)

	local rawByChannel = self.platformRawChatMessageListData
	local oldByChannel = self.chatMessageListData or {}
	local changedChannelIds = {}
	local rebuilt = {}

	for channelId, rawMessages in pairs(rawByChannel) do
		local visibleMessages = {}
		local rawMessageSet = M.makeRawMessageSet(rawMessages)
		local seenRawMessages = {}

		for _, messageData in ipairs(oldByChannel[channelId] or EMPTY_TABLE) do
			if type(messageData) == "table" and rawMessageSet[messageData] then
				seenRawMessages[messageData] = true

				local playerInfo = messageData.playerId and self:getPlayerInfo(messageData.playerId) or nil

				if M.shouldShowPlatformMessage(self, messageData, playerInfo) then
					table.insert(visibleMessages, messageData)
				end
			elseif type(messageData) == "table" then
				table.insert(visibleMessages, messageData)
			end
		end

		for _, messageData in ipairs(rawMessages) do
			local playerInfo = messageData and messageData.playerId and self:getPlayerInfo(messageData.playerId) or nil

			if not seenRawMessages[messageData] and M.shouldShowPlatformMessage(self, messageData, playerInfo) then
				table.insert(visibleMessages, messageData)
			end
		end

		local oldMessages = oldByChannel[channelId]

		if M.areMessageListsEqual(oldMessages, visibleMessages) then
			rebuilt[channelId] = oldMessages or visibleMessages
		else
			rebuilt[channelId] = visibleMessages
			changedChannelIds[channelId] = true
		end
	end

	for channelId, messages in pairs(oldByChannel) do
		if rebuilt[channelId] == nil then
			rebuilt[channelId] = messages
		end
	end

	if next(changedChannelIds) == nil then
		logger:info("platform_chat_filter_refreshed reason=%s channels=0", tostring(reason or ""))

		return
	end

	self.chatMessageListData = rebuilt

	M.rebuildMessageIdIndex(self)

	local changedCount = M.notifyChannelUpdates(changedChannelIds)

	logger:info("platform_chat_filter_refreshed reason=%s channels=%s", tostring(reason or ""), tostring(changedCount))
end

function M:filterChatHistoryMessages(chatMessageDatas)
	if type(chatMessageDatas) ~= "table" then
		return chatMessageDatas
	end

	local visibleMessages = {}
	local batchIds = {}
	local seenBatchIds = {}

	for _, messageData in ipairs(chatMessageDatas) do
		if M.shouldFilterInboundMessage(self, messageData) then
			M.addRawPlatformMessage(self, messageData)

			local playerInfo = self:getPlayerInfo(messageData.playerId)
			local shouldFilter = false
			local context

			if type(playerInfo) == "table" then
				if PlatformChatFilterService.shouldCheckBlockedBySender(messageData) then
					local family = type(PlatformIdentityUtils.resolvePlayerInfoFamily) == "function" and PlatformIdentityUtils.resolvePlayerInfoFamily(playerInfo)
					local platformUserId = family == "playstation" and type(PlatformIdentityUtils.resolvePlatformUserId) == "function" and PlatformIdentityUtils.resolvePlatformUserId(playerInfo)

					if not string.isNilOrEmpty(platformUserId) then
						if not seenBatchIds[platformUserId] then
							seenBatchIds[platformUserId] = true
							batchIds[#batchIds + 1] = platformUserId
						end
					else
						shouldFilter = PlatformChatFilterService:shouldFilterMessage(messageData, playerInfo) == true
					end
				else
					shouldFilter = PlatformChatFilterService:shouldFilterMessage(messageData, playerInfo) == true
				end

				shouldFilter, _, context = PlatformChatFilterService:shouldFilterMessage(messageData, playerInfo)
			end

			if not shouldFilter and (context == nil or context.reason ~= PlatformChatFilterService.REASON_TARGET_COMMUNICATION_PENDING) then
				table.insert(visibleMessages, messageData)
			end
		else
			table.insert(visibleMessages, messageData)
		end
	end

	if #batchIds > 0 and pg and pg.me and type(pg.me.requestPsnBlockStates) == "function" then
		pg.me:requestPsnBlockStates(batchIds)
	end

	return visibleMessages
end

function M:recvPrivateChatPush(sender, senderInfo, target, message, extraInfo, msgId)
	if sender == pg.me.uid then
		return
	end

	self:setPlayerData(sender, senderInfo)

	local messageData = self:buildReceivedPlayerMessageData(sender, senderInfo, message, extraInfo, msgId, sender, pg.game.chat.channelType.Player)
	local playerData = self:getPlayerInfo(sender)

	pg.me:queryPlayerInfo(sender, nil, true, function(queriedData)
		self:tryCreatePrivateChat(sender)
		self:addNewMessage(messageData, nil, {
			playerInfo = queriedData or playerData,
			onAdded = function()
				facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)
			end
		})
	end)
end

function M:recvGroupChatPush(sender, senderInfo, groupId, message, extraInfo, channelType, msgId)
	if sender == pg.me.uid then
		return
	end

	local playerInfo = self:setPlayerData(sender, senderInfo)
	local effectiveChannelType = channelType

	if effectiveChannelType == nil then
		effectiveChannelType = M.isHomelandGroup(self, groupId) and pg.game.chat.channelType.Home or pg.game.chat.channelType.Group
	elseif effectiveChannelType == pg.game.chat.channelType.Group and M.isHomelandGroup(self, groupId) then
		effectiveChannelType = pg.game.chat.channelType.Home
	end

	local messageData = self:buildReceivedPlayerMessageData(sender, senderInfo, message, extraInfo, msgId, groupId, effectiveChannelType)

	if effectiveChannelType == pg.game.chat.channelType.Group then
		self:tryCreateGroupChat(groupId)
	end

	self:addNewMessage(messageData, nil, {
		playerInfo = playerInfo,
		onAdded = function(addedMessageData)
			pg.game.chat:showEntityMessageBubbleByUid(addedMessageData.playerId, addedMessageData)
			facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)
		end
	})
end

function M:recvFriendChatPush(sender, senderInfo, message, extraInfo, msgId)
	if sender == pg.me.uid then
		return
	end

	local playerInfo = self:setPlayerData(sender, senderInfo)
	local channelType = pg.game.chat.channelType.Friend
	local messageData = self:buildReceivedPlayerMessageData(sender, senderInfo, message, extraInfo, msgId, channelType, channelType)

	self:addNewMessage(messageData, nil, {
		playerInfo = playerInfo,
		onAdded = function()
			facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)
		end
	})
end

function M:recvWorldChatPush(sender, senderInfo, target, message, extraInfo, msgId)
	if sender == pg.me.uid then
		return
	end

	local playerInfo = self:setPlayerData(sender, senderInfo)
	local messageData = self:buildReceivedPlayerMessageData(sender, senderInfo, message, extraInfo, msgId, pg.me.worldChatGroupId, pg.game.chat.channelType.World)

	self:addNewMessage(messageData, nil, {
		playerInfo = playerInfo,
		onAdded = function()
			facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)
		end
	})
end

function M:recvNearbyChatPush(sender, senderInfo, message, extraInfo, msgId)
	if sender == pg.me.uid then
		return
	end

	local playerInfo = self:setPlayerData(sender, senderInfo)
	local channelType = pg.game.chat.channelType.Near
	local messageData = self:buildReceivedPlayerMessageData(sender, senderInfo, message, extraInfo, msgId, channelType, channelType)

	self:addNewMessage(messageData, nil, {
		playerInfo = playerInfo,
		onAdded = function(addedMessageData)
			pg.game.chat:showEntityMessageBubbleByUid(addedMessageData.playerId, addedMessageData)
			facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)
		end
	})
end

function M:renderChatGroupMemberNoticePlayerName(uid, playerInfo, rawName)
	if string.isNilOrEmpty(uid) or string.isNilOrEmpty(rawName) then
		return rawName
	end

	return PlatformNameMaskService.getMaskedDisplayName({
		action = PlatformNameMaskService.Action.ChatMessagePlayerName,
		uid = uid,
		playerInfo = playerInfo,
		rawText = rawName
	})
end

return M
