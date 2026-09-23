-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientChatComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local ChatPushData = require("Data.chat_push_data")
local MessageName = require("Const.MessageName")
local GlobalData = require("Core.Client.GlobalData")
local CallbackHandler = require("Core.Common.CallbackHandler")
local Utils = require("Common.Utils.Utils")
local UIConst = require("Const.UIConst")
local ChatSendResult = require("GameApp.Chat.ChatSendResult")
local ClientChatComponent = class.Component("ClientChatComponent")

function ClientChatComponent:ctor()
	return
end

function ClientChatComponent:init(avtDict)
	return true
end

function ClientChatComponent:destroy()
	return
end

function ClientChatComponent:_sensitiveWordsCheckImpl(text, success, failure, extraInfo)
	self:callService("ChatService", "textCheck", {
		self.uid,
		Const.TEXT_CHECK_TYPE.PERMANENT,
		text,
		extraInfo
	}, CallbackHandler(self, "_textCheckCallback", success, failure), {
		callerId = self.uid
	})
end

function ClientChatComponent:sensitiveWordsCheck(text, success, failure, extraInfo)
	local _h = ClientChatComponent._platformHooks

	if _h and _h.sensitiveWordsCheck then
		return _h.sensitiveWordsCheck(self, text, success, failure, extraInfo)
	end

	self:_sensitiveWordsCheckImpl(text, success, failure, extraInfo)
end

function ClientChatComponent:_textCheckCallback(success, failure, result, resp)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("_textCheckCallback;", inspect(result), resp.Text, resp.RiskLevel)
	end

	if not result.status or resp.RiskLevel ~= Const.RISK_LEVEL.PASS then
		pg.global.showBubbleMessageRaw(pg.getGameString("INPUT_TEXT_CONTAINS_SENSITIVE"), 2)

		if failure then
			failure(resp.RiskLevel, resp.Text)
		end
	elseif success then
		success(resp.Text)
	end
end

function ClientChatComponent:worldChatChannelStatus()
	self:callService("ChatService", "getGroupStatus", {
		Const.CHAT_ATTR_WORLD.group_base,
		{}
	}, CallbackHandler(self, "_worldChatChannelStatusCallback"), {
		callerId = self.uid
	})
end

function ClientChatComponent:_worldChatChannelStatusCallback(result, resp)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientChatComponent _worldChatChannelStatusCallback", self:repr(), inspect(result), inspect(resp.Groups))
	end
end

function ClientChatComponent:switchChatChannel(channelType, serialNo)
	self:serverMsg("RPC_CS_SwitchChannel", channelType, serialNo)
end

function ClientChatComponent:_chatSendPrivateImpl(targetId, message, extraInfo, messageData, blockSwitchChannel)
	extraInfo = extraInfo or {}

	local chatMessageType = extraInfo[Const.CHAT_EXTRA_TYPE.ChatType]
	local isSystemMessage = chatMessageType == Const.CHAT_MESSAGE_TYPE.System
	local canAddIntimacyByExtraType = true

	for _, extraType in ipairs(Const.NOT_INTIMACY_CHAT_EXTRA_TYPE) do
		if extraInfo[extraType] ~= nil then
			canAddIntimacyByExtraType = false

			break
		end
	end

	local isFriend = pg.game.chat:checkFriendList(targetId)

	extraInfo[Const.CHAT_EXTRA_TYPE.IsFriend] = isFriend

	local sent = self:chatSend(targetId, {}, "", Const.CHAT_TYPE.PRIVATE, message, extraInfo, messageData, blockSwitchChannel)
	local shouldAddIntimacy = canAddIntimacyByExtraType and sent == ChatSendResult.Success and isFriend and not isSystemMessage

	if shouldAddIntimacy then
		self:serverMsg("RPC_CS_AddIntimacyByChat", targetId)
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("chatSendPrivate;", targetId, message)
	end

	return sent
end

function ClientChatComponent:chatSendPrivate(targetId, message, extraInfo, options, messageData, blockSwitchChannel)
	local _h = ClientChatComponent._platformHooks

	if _h and _h.chatSendPrivate then
		return _h.chatSendPrivate(self, targetId, message, extraInfo, options, messageData, blockSwitchChannel)
	end

	return self:_chatSendPrivateImpl(targetId, message, extraInfo, messageData, blockSwitchChannel)
end

function ClientChatComponent:chatSendGroup(groupId, message, extraInfo, messageData, blockSwitchChannel)
	return self:chatSend("", {}, groupId, Const.CHAT_TYPE.GROUP, message, extraInfo, messageData, blockSwitchChannel)
end

function ClientChatComponent:chatSendFriendGroup(message, extraInfo, messageData, blockSwitchChannel)
	local targetIds = pg.game.chat:getFriendIdList()

	return self:chatSend(self.uid, targetIds, "", Const.CHAT_TYPE.FRIEND, message, extraInfo, messageData, blockSwitchChannel)
end

function ClientChatComponent:chatSendHomeland(message, extraInfo, messageData, blockSwitchChannel)
	local homelandKey = pg.game.chat:getHomeCampGroupId()

	return self:chatSendGroup(homelandKey, message, extraInfo, messageData, blockSwitchChannel)
end

function ClientChatComponent:chatSendWorld(message, extraInfo, messageData, blockSwitchChannel)
	return self:chatSend("", {}, pg.me.worldChatGroupId, Const.CHAT_TYPE.GROUP, message, extraInfo, messageData, blockSwitchChannel)
end

function ClientChatComponent:chatSendNearby(message, extraInfo, messageData, blockSwitchChannel)
	local targetIds = {}
	local actorIds = self:entitiesInRange(Const.CHAT.NEARBY_RADIUS, Const.SEARCH_USR_TYPE_PLAYER + Const.SEARCH_USR_TYPE_PLAYER_GHOST)

	for _, actorId in ipairs(actorIds) do
		local ent = pg.getEntityByActorId(actorId)

		targetIds[#targetIds + 1] = ent.uid
	end

	return self:chatSend("", targetIds, "", Const.CHAT_TYPE.NEARBY, message, extraInfo, messageData, blockSwitchChannel)
end

function ClientChatComponent:chatSendTeam(message, extraInfo, messageData, blockSwitchChannel)
	local currentTeam = self:getCurTeamInfo()

	if not currentTeam or not currentTeam.teamId then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("chat send team no teamId;", self:repr(), message)
		end

		return ChatSendResult.Abort
	end

	local teamInfo = self:getShowTeamInfo()
	local targetIds = table.keys(teamInfo.membersInfo)

	extraInfo = extraInfo or {}
	extraInfo.teamId = currentTeam.teamId

	return self:chatSend("", targetIds, "", Const.CHAT_TYPE.MULTICAST, message, extraInfo, messageData, blockSwitchChannel)
end

function ClientChatComponent:getMountedVehicleActorId()
	return tonumber(self.onVehicleActorId) or 0
end

function ClientChatComponent:isUidOnMyVehicle(uid)
	local vehicleActorId = self:getMountedVehicleActorId()

	if vehicleActorId == 0 then
		return false
	end

	local ent = pg.getEntityByUid(uid)

	if ent == nil then
		return false
	end

	return pg.game.chat:isSameVehicleChatScope(tonumber(ent.onVehicleActorId), vehicleActorId) == true
end

function ClientChatComponent:chatSendVehicle(vehicleActorId, message, extraInfo, messageData, blockSwitchChannel)
	vehicleActorId = tonumber(vehicleActorId) or 0

	local onVehicleActorId = self:getMountedVehicleActorId()

	if vehicleActorId == 0 or onVehicleActorId ~= vehicleActorId then
		return ChatSendResult.Abort
	end

	extraInfo = extraInfo or {}

	pg.game.chat:fillVehicleChatExtraInfo(extraInfo, vehicleActorId)

	local targetIds = pg.game.chat:getVehicleChatTargetIds(vehicleActorId, false)

	if #targetIds == 0 then
		return ChatSendResult.FakeSend
	end

	return self:chatSend("", targetIds, "", Const.CHAT_TYPE.MULTICAST, message, extraInfo, messageData, blockSwitchChannel)
end

local function encodeChatBiValue(value)
	local json = require("json")

	if type(value) ~= "table" then
		return value
	end

	if json and type(json.encode) == "function" then
		local ok, encoded = pcall(json.encode, value)

		if ok then
			return encoded
		end
	end

	if type(inspect) == "function" then
		return inspect(value)
	end

	return tostring(value)
end

function ClientChatComponent:chatSend(targetId, targetIds, groupId, type, message, extraInfo, messageData, blockSwitchChannel)
	local clientIPInfoData = pg.global.sdkManager:getClientIPInfoData()
	local senderInfo = {
		playerName = pg.me.playerName,
		headIcon = pg.me.headIcon,
		headFrame = pg.me.headFrame,
		starTitle = pg.me.starTitle,
		level = pg.me.level,
		chatBubble = pg.me.chatBubble,
		PcPayTotalMoney = pg.me.PcPayTotalMoney,
		Ip = clientIPInfoData and clientIPInfoData.ip or ""
	}
	local _h = ClientChatComponent._platformHooks

	if _h and _h.enrichSenderInfo then
		_h.enrichSenderInfo(self, senderInfo)
	end

	if extraInfo == nil then
		extraInfo = {
			[""] = 0
		}
	end

	local chatMessageType = extraInfo[Const.CHAT_EXTRA_TYPE.ChatType] or Const.CHAT_MESSAGE_TYPE.Self

	extraInfo[Const.CHAT_EXTRA_TYPE.ChatType] = nil

	local chatFlow = chatMessageType == Const.CHAT_MESSAGE_TYPE.System and "system_chat_flow" or "player_chat_flow"

	if _h and _h.checkSendMessagePolicy then
		local canSend = _h.checkSendMessagePolicy(self, {
			message = message,
			type = type,
			targetId = targetId,
			targetIds = targetIds,
			groupId = groupId,
			extraInfo = extraInfo,
			isSystemMessage = chatMessageType == Const.CHAT_MESSAGE_TYPE.System
		})

		if not canSend then
			return ChatSendResult.Abort
		end
	end

	local requestExtraInfo = {}

	for key, value in pairs(extraInfo) do
		requestExtraInfo[key] = value
	end

	requestExtraInfo[Const.CHAT_EXTRA_TYPE.ChatType] = chatMessageType

	self:callService("ChatService", "chat", {
		self.uid,
		senderInfo,
		targetId,
		targetIds,
		groupId,
		type,
		message,
		requestExtraInfo
	}, CallbackHandler(self, "_chatSendCallback", extraInfo, messageData, blockSwitchChannel), {
		callerId = self.uid
	})
	GlobalData.BILogger:customeLog(chatFlow, {
		chat_sender = self.uid,
		chat_target = targetId,
		chat_targets = encodeChatBiValue(targetIds),
		chat_content = message,
		chat_channel = type,
		chat_groupId = groupId,
		chat_extraInfo = encodeChatBiValue(extraInfo)
	})

	return ChatSendResult.Success
end

function ClientChatComponent:_chatSendCallback(extraInfo, messageData, blockSwitchChannel, result, resp)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientChatComponent _chatSendCallback", self:repr(), inspect(result), resp.Message)
	end

	pg.game.chat:recvChatSend(resp.MsgId, result, resp, extraInfo, messageData, blockSwitchChannel)
end

function ClientChatComponent:chatSendPositionCard(channelType, channelId)
	self:serverMsg("RPC_CS_GetChatPositionCard", CallbackHandler(self, "_chatSendPositionCardCallback", channelType, channelId))
end

function ClientChatComponent:_chatSendPositionCardCallback(channelType, channelId, cardInfo)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientChatComponent _chatSendPositionCardCallback", self:repr(), inspect(cardInfo))
	end

	if cardInfo then
		pg.game.chat:sendMessage(pg.getGameString("LOCATION"), pg.game.chat.subMessageType.Text, channelType, channelId, {
			[Const.CHAT_EXTRA_TYPE.PositionCard] = cardInfo
		})
	end
end

function ClientChatComponent:chatGoPositionCard(cardInfo)
	self:serverMsg("RPC_CS_GoChatPositionCard", cardInfo)
end

function ClientChatComponent:chatRecord()
	self:callService("ChatService", "chatRecord", {
		self.uid,
		""
	}, CallbackHandler(self, "_chatRecordCallback"), {
		callerId = self.uid
	})
end

function ClientChatComponent:_chatRecordCallback(result, resp)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientChatComponent _chatRecordCallback", self:repr(), inspect(result), inspect(resp.PrivateChatRecords), inspect(resp.GroupChatRecords))
	end

	pg.game.chat:recvChatRecord(result, resp)
end

function ClientChatComponent:chatRecordDelete(deleteUid)
	self:callService("ChatService", "chatRecord", {
		self.uid,
		deleteUid
	}, CallbackHandler(self, "_chatRecordDeleteCallback"), {
		callerId = self.uid
	})
end

function ClientChatComponent:_chatRecordDeleteCallback(result)
	return
end

function ClientChatComponent:chatHistory(targetId, groupId, type, start, limit, extraParam)
	if self:isChatHistoryQueryBlocked(groupId) then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientChatComponent chatHistory", self:repr())
	end

	self:callService("ChatService", "history", {
		self.uid,
		targetId,
		groupId,
		type,
		start,
		limit
	}, CallbackHandler(self, "_chatHistoryCallback", extraParam), {
		callerId = self.uid
	})
end

function ClientChatComponent:isChatHistoryQueryBlocked(groupId)
	local isCn = ClientConfigAppCountry == "cn"

	return isCn and pg.game.chat:isLanguageChatGroupId(groupId)
end

function ClientChatComponent:_chatHistoryCallback(extraParam, result, resp)
	pg.game.chat:recvChatHistory(extraParam, result, resp)
end

function ClientChatComponent:fillChatHistoryItems(items, targetId, groupId, type, start, limit)
	items = items or {}

	if self:isChatHistoryQueryBlocked(groupId) then
		return items
	end

	local item = {
		targetId,
		groupId,
		type,
		start,
		limit
	}

	table.insert(items, item)

	return items
end

function ClientChatComponent:chatBatchHistory(historyItems)
	self:callService("ChatService", "batchHistory", {
		self.uid,
		historyItems
	}, CallbackHandler(self, "_chatBatchHistoryCallback"), {
		callerId = self.uid
	})
end

function ClientChatComponent:_chatBatchHistoryCallback(result, resp)
	pg.game.chat:recvBatchChatHistory(result, resp)
end

function ClientChatComponent:_createChatGroupImpl(members, chatGroupName)
	self:callService("ChatService", "createChatGroup", {
		self.uid,
		members,
		chatGroupName
	}, CallbackHandler(self, "_createChatGroupCallback", members), {
		callerId = self.uid
	})
end

function ClientChatComponent:createChatGroup(members, chatGroupName)
	local _h = ClientChatComponent._platformHooks

	if _h and _h.createChatGroup then
		_h.createChatGroup(self, members, chatGroupName)

		return
	end

	self:_createChatGroupImpl(members, chatGroupName)
end

function ClientChatComponent:_createChatGroupCallback(members, result, resp)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientChatComponent _createChatGroupCallback", self:repr(), inspect(result), inspect(resp))
	end

	if not result.status then
		if result.errmsg == "TID_MS_CHAT_SERVICE_USER_CHATGROUP_LIMIT" or result.errmsg == "TID_MS_CHAT_SERVICE_CHAT_DIRTYCHECK" or result.errmsg == "TID_MS_CHAT_SERVICE_CREATE_CHATGROUP" or result.errmsg == "TID_MS_CHAT_SERVICE_CHATGROUP_MEMBER_MIN" or result.errmsg == "TID_MS_CHAT_SERVICE_CHATGROUP_MEMBER_MAX" or result.errmsg == "TID_MS_CHAT_SERVICE_CREATE_CHATGROUP" then
			pg.global.showBubbleMessageRaw(pg.getGameString(result.errmsg))
		end
	else
		local notIncludedMemberCount = 0

		for _, member in ipairs(members) do
			if not resp.SuccessMembers or not table.contains(resp.SuccessMembers, member) then
				notIncludedMemberCount = notIncludedMemberCount + 1
			end
		end

		if notIncludedMemberCount > 0 then
			pg.global.showBubbleMessageRaw(pg.getFormatText(pg.getGameString("CREATE_CHAT_GROUP_PARTLY_SUCCESS"), notIncludedMemberCount))
		else
			pg.global.showBubbleMessageRaw(pg.getGameString("CREATE_CHAT_GROUP_SUCCESS"))
		end

		facade:SendMessageCommand(MessageName.UPDATE_CHAT_GROUP)
	end
end

function ClientChatComponent:joinChatGroup(groupId, members)
	self:callService("ChatService", "joinChatGroup", {
		self.uid,
		groupId,
		members
	}, CallbackHandler(self, "_joinChatGroupCallback", members), {
		callerId = self.uid
	})
end

function ClientChatComponent:_joinChatGroupCallback(members, result, resp)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientChatComponent _joinChatGroupCallback", self:repr(), inspect(result), inspect(resp))
	end

	if result.status then
		local notIncludedMemberCount = 0

		for _, member in ipairs(members) do
			if not resp.SuccessMembers or not table.contains(resp.SuccessMembers, member) then
				notIncludedMemberCount = notIncludedMemberCount + 1
			end
		end

		if notIncludedMemberCount > 0 then
			pg.global.showBubbleMessageRaw(pg.getFormatText(pg.getGameString("JOIN_CHAT_GROUP_PARTLY_SUCCESS"), notIncludedMemberCount))
		else
			pg.global.showBubbleMessageRaw(pg.getGameString("JOIN_CHAT_GROUP_SUCCESS"))
		end

		facade:SendMessageCommand(MessageName.UPDATE_CHAT_GROUP)
	elseif result.errmsg == "TID_MS_CHAT_SERVICE_USER_CHATGROUP_LIMIT" or result.errmsg == "TID_MS_CHAT_SERVICE_CHAT_DIRTYCHECK" or result.errmsg == "TID_MS_CHAT_SERVICE_CREATE_CHATGROUP" or result.errmsg == "TID_MS_CHAT_SERVICE_CHATGROUP_MEMBER_MIN" or result.errmsg == "TID_MS_CHAT_SERVICE_CHATGROUP_MEMBER_MAX" or result.errmsg == "TID_MS_CHAT_SERVICE_CREATE_CHATGROUP" then
		pg.global.showBubbleMessageRaw(pg.getGameString(result.errmsg))
	end
end

function ClientChatComponent:leaveChatGroup(groupId, members)
	self:callService("ChatService", "leaveChatGroup", {
		self.uid,
		groupId,
		members
	}, CallbackHandler(self, "_leaveChatGroupCallback", groupId, members), {
		callerId = self.uid
	})
end

function ClientChatComponent:_leaveChatGroupCallback(groupId, members, result, resp)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientChatComponent _leaveChatGroupCallback", self:repr(), inspect(result), inspect(resp))
	end

	facade:SendMessageCommand(MessageName.UPDATE_CHAT_GROUP)

	if result.status then
		local group = pg.game.chat:getFriendChatGroup(groupId)

		if #members == 1 and members[1] == pg.me.uid then
			local displayGroupName = pg.game.chat:getChatGroupDisplayName(group)

			pg.global.showBubbleMessageRaw(pg.getFormatText(pg.getGameString("LEAVE_CHAT_GROUP_SUCCESS"), displayGroupName))
		else
			pg.global.showBubbleMessageRaw(pg.getGameString("REMOVE_CHAT_GROUP_MEMBER_SUCCESS"))
		end
	end
end

function ClientChatComponent:deleteChatGroup(groupId)
	self:callService("ChatService", "deleteChatGroup", {
		self.uid,
		groupId
	}, CallbackHandler(self, "_deleteChatGroupCallback"), {
		callerId = self.uid
	})
end

function ClientChatComponent:_deleteChatGroupCallback(result, resp)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientChatComponent _deleteChatGroupCallback", self:repr(), inspect(result), inspect(resp))
	end

	if result.status then
		pg.global.showBubbleMessageRaw(pg.getGameString("DELETE_CHAT_GROUP_SUCCESS"))
	end
end

function ClientChatComponent:getChatGroupStatus(groupId)
	self:callService("ChatService", "getChatGroupStatus", {
		groupId
	}, CallbackHandler(self, "_getChatGroupStatusCallback", groupId), {
		callerId = self.uid
	})
end

function ClientChatComponent:_getChatGroupStatusCallback(groupId, result, resp)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientChatComponent _getChatGroupStatusCallback", self:repr(), inspect(result), resp.ChatGroupName, inspect(resp.Members))
	end

	if result.status then
		pg.game.chat:updateChatGroup(nil, groupId, resp.Members, resp.ChatGroupName)
	elseif result.errmsg == "TID_MS_CHAT_SERVICE_FIND_CHATGROUP" then
		pg.game.chat:handleChatGroupNotExist(groupId)
	end
end

function ClientChatComponent:_setChatGroupStatusImpl(groupId, chatGroupName)
	self:callService("ChatService", "setChatGroupStatus", {
		self.uid,
		groupId,
		chatGroupName
	}, CallbackHandler(self, "_setChatGroupStatusCallback"), {
		callerId = self.uid
	})
end

function ClientChatComponent:setChatGroupStatus(groupId, chatGroupName)
	local _h = ClientChatComponent._platformHooks

	if _h and _h.setChatGroupStatus then
		_h.setChatGroupStatus(self, groupId, chatGroupName)

		return
	end

	self:_setChatGroupStatusImpl(groupId, chatGroupName)
end

function ClientChatComponent:_setChatGroupStatusCallback(result, resp)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientChatComponent _setChatGroupStatusCallback", self:repr(), inspect(result), inspect(resp))
	end

	if not result.status then
		if result.errmsg == "TID_MS_CHAT_SERVICE_CHAT_DIRTYCHECK" then
			pg.global.showBubbleMessageRaw(pg.getGameString(result.errmsg))
		end
	elseif pg.global.ui:checkUIOpen(UIConst.UI_ID_CHANGE_NAME) then
		pg.global.ui.changeName:close()
	end
end

function ClientChatComponent:reportChat(reportInfo)
	if not Utils.isTable(reportInfo) then
		return
	end

	self:serverMsg("RPC_CS_ReportChat", reportInfo)
end

function ClientChatComponent:ChatService_onPrivateChat(sender, senderInfo, target, message, extraInfo, msgId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ChatService_onPrivateChat", sender, inspect(senderInfo), target, message, inspect(extraInfo), msgId)
	end

	pg.game.chat:recvPrivateChatPush(sender, senderInfo, target, message, extraInfo, msgId)
end

function ClientChatComponent:ChatService_onDeleteChatMessage(user, target, group, chatType, msgID)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ChatService_onDeleteChatMessage", user, target, group, chatType, msgID)
	end

	pg.game.chat:deleteChatMessage(user, target, group, chatType, msgID)
end

function ClientChatComponent:ChatService_onGroupChat(sender, senderInfo, groupId, message, extraInfo, msgId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ChatService_onGroupChat", sender, inspect(senderInfo), groupId, message, inspect(extraInfo), msgId)
	end

	local channelType = pg.game.chat.channelType.Group

	if pg.game.chat:isWorldChatGroupId(groupId) then
		channelType = pg.game.chat.channelType.World
	elseif pg.game.chat:isHomeCampGroupId(groupId) then
		channelType = pg.game.chat.channelType.Home
	end

	pg.game.chat:recvGroupChatPush(sender, senderInfo, groupId, message, extraInfo, channelType, msgId)
end

function ClientChatComponent:ChatService_onWorldChat(sender, senderInfo, groupId, message, extraInfo, msgId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ChatService_onWorldChat", sender, inspect(senderInfo), groupId, message, inspect(extraInfo), msgId)
	end

	pg.game.chat:recvWorldChatPush(sender, senderInfo, groupId, message, extraInfo, msgId)
end

function ClientChatComponent:ChatService_onNearbyChat(sender, senderInfo, message, extraInfo, msgId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ChatService_onNearbyChat", sender, inspect(senderInfo), message, inspect(extraInfo), msgId)
	end

	pg.game.chat:recvNearbyChatPush(sender, senderInfo, message, extraInfo, msgId)
end

function ClientChatComponent:ChatService_onFriendChat(sender, senderInfo, message, extraInfo, msgId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ChatService_onFriendChat", sender, inspect(senderInfo), message, inspect(extraInfo), msgId)
	end

	pg.game.chat:recvFriendChatPush(sender, senderInfo, message, extraInfo, msgId)
end

function ClientChatComponent:ChatService_onMulticastChat(sender, senderInfo, message, extraInfo, msgId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ChatService_onMulticastChat", sender, inspect(senderInfo), inspect(extraInfo), message, inspect(extraInfo), msgId)
	end

	if extraInfo ~= nil and extraInfo.teamId ~= nil then
		pg.game.chat:recvGroupChatPush(sender, senderInfo, extraInfo.teamId, message, extraInfo, pg.game.chat.channelType.Team, msgId)
	elseif extraInfo ~= nil and extraInfo.vehicleActorId ~= nil then
		local vehicleActorId = tonumber(extraInfo.vehicleActorId) or 0
		local onVehicleActorId = self:getMountedVehicleActorId()

		if vehicleActorId ~= 0 and pg.game.chat:isSameVehicleChatScope(vehicleActorId, onVehicleActorId, extraInfo) == true then
			pg.game.chat:recvGroupChatPush(sender, senderInfo, vehicleActorId, message, extraInfo, pg.game.chat.channelType.Vehicle, msgId)
		end
	end
end

function ClientChatComponent:ChatService_onChatGroupUpdate(uid, groupId, uids, chatGroupName)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ChatService_onChatGroupUpdate", groupId, inspect(uids), chatGroupName)
	end

	pg.game.chat:updateChatGroup(uid, groupId, uids, chatGroupName)
end

function ClientChatComponent:RPC_SC_SendPlayerChat(uid, msgId, info)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_SendPlayerChat uid=%s, msgId=%d", uid, msgId)
	end

	info = info or {}

	if msgId and ChatPushData[msgId] then
		pg.game.chat:tryCreatePrivateChat(uid)

		local text = pg.getLocalizationText(ChatPushData[msgId].triggerText)
		local infoIdx = 1

		text = string.gsub(text, "{%d+}", function(placeholder)
			local value = info[infoIdx]

			infoIdx = infoIdx + 1

			if type(value) == "number" then
				local localizationText = pg.getLocalizationText(value)

				value = string.isNilOrEmpty(localizationText) and value or localizationText
			end

			return value or placeholder
		end)

		pg.game.chat:sendMessage(text, pg.game.chat.subMessageType.Text, pg.game.chat.channelType.Player, uid, {
			[Const.CHAT_EXTRA_TYPE.ChatType] = Const.CHAT_MESSAGE_TYPE.System
		}, nil, {
			skipTextPermissionCheck = true,
			notifyUser = false
		})
	end
end

function ClientChatComponent:RPC_SC_SendPlayerText(uid, text)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_SendPlayerText uid=%s, text=%s", uid, text)
	end

	pg.game.chat:sendMessage(text, pg.game.chat.subMessageType.Text, pg.game.chat.channelType.Player, uid, {
		[Const.CHAT_EXTRA_TYPE.ChatType] = Const.CHAT_MESSAGE_TYPE.System
	}, nil, {
		skipTextPermissionCheck = true,
		notifyUser = false
	})
end

function ClientChatComponent:notifyPlayerTyping(uids, type)
	self:serverMsg("RPC_CS_NotifyPlayerTyping", uids, type)
end

function ClientChatComponent:RPC_SC_PlayerTyping(uid, type)
	pg.game.chat:showEntityMessageTypingByUid(uid, type)
end

function ClientChatComponent:on_voiceSignature_changed(oldv, newv)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("on_voiceSignature_changed ov:%s, nv:%s", inspect(oldv), inspect(newv))
	end

	facade:SendMessageCommand(MessageName.PLAYER_VOICE_SIGNATURE_CHANGE, newv)
end

function ClientChatComponent:likeChatMessage(chatLikeInfo)
	local isInvalidLikeInfo = string.isNilOrEmpty(chatLikeInfo.Liker) or string.isNilOrEmpty(chatLikeInfo.SourceType) or chatLikeInfo.SourceMsgId == nil or string.isNilOrEmpty(chatLikeInfo.SourceSender) or chatLikeInfo.SourceEnum == nil

	if isInvalidLikeInfo then
		return
	end

	local channelId = chatLikeInfo.SourceType == Const.CHAT_TYPE.PRIVATE and chatLikeInfo.Target or chatLikeInfo.GroupId

	self:callService("ChatService", "likeChatMessage", {
		self.uid,
		chatLikeInfo.SourceType,
		chatLikeInfo.SourceMsgId,
		chatLikeInfo.SourceSender,
		chatLikeInfo.SourceEnum,
		chatLikeInfo.Target or "",
		chatLikeInfo.GroupId or "",
		chatLikeInfo.Targets or {}
	}, CallbackHandler(self, "_likeChatMessageCallback", channelId), {
		callerId = self.uid
	})
end

function ClientChatComponent:_likeChatMessageCallback(channelId, result, resp)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientChatComponent _likeChatMessageCallback", self:repr(), inspect(result), inspect(resp))
	end

	channelId = resp.ChannelId or channelId

	pg.game.chat:updateChatMessageLike(channelId, resp.MsgId, resp.LikeCount, resp.LikedByMe)
end

function ClientChatComponent:ChatService_onInteractionChat(sender, senderInfo, receiver, groupId, message, extraInfo, msgId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ChatService_onInteractionChat", sender, inspect(senderInfo), receiver, groupId, message, inspect(extraInfo), msgId)
	end

	pg.game.chat:recvInteractionChatPush(sender, senderInfo, receiver, groupId, message, extraInfo, msgId)
end

function ClientChatComponent:ChatService_onChatMessageLike(liker, sourceType, sourceMsgId, channelId, likeCount)
	if likeCount == nil then
		likeCount = channelId
		channelId = nil
	end

	if (channelId == nil or channelId == "") and sourceType == Const.CHAT_TYPE.FRIEND then
		channelId = pg.game.chat.channelType.Friend
	end

	local likedByMe = liker == self.uid and true or nil

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ChatService_onChatMessageLike", sourceMsgId, channelId, likedByMe)
	end

	pg.game.chat:updateChatMessageLike(channelId, sourceMsgId, likeCount, likedByMe)
end

return ClientChatComponent
