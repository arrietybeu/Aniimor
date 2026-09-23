-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Chat\\ImpChatFriend.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ChatSystem = require("GameApp.Chat.ChatSystem")
local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local RedDotConst = require("Const.RedDotConst")
local logger = LoggerManager.getLogger("ChatSystem")
local TriggerConst = require("Common.Const.TriggerConst")
local Utils = require("Common.Utils.Utils")
local ClientConst = require("Const.ClientConst")
local Time = require("Core.Common.Time")
local FriendSourceData = require("Data.friend_source_data")
local FriendshipLevelData = require("Data.friendship_level_data")
local FriendshipLevelFuncData = require("Data.friendship_level_func_data")
local SysConfigData = require("Data.sys_config_data")
local json = require("json")
local PlatformHomeCampEntryFilterService = require("SDK.Platform.PlatformHomeCampEntryFilterService")
local PlatformNoticeUtils = require("SDK.Platform.PlatformNoticeUtils")
local PlatformSocialService = require("SDK.Platform.PlatformSocialService")
local LuaUIUtils = require("Utils.LuaUIUtils")

ChatSystem.AddFriendCD = 600
ChatSystem.AddFriendSource = {
	ChatChannel = 5,
	FaceToFace = 4,
	FriendRecommend = 3,
	SystemRecommend = 2,
	Search = 1,
	PlayerCard = 7,
	Team = 6
}

function ChatSystem:recvFriendList(result, resp)
	if not result.status then
		return
	end

	self:setSpecialFriendUId(resp.SpecialFriendId)

	local uids = {}

	self.friendList[2].subItems = {}
	self.friendIdSet = {}
	self.friendCustomList = {}
	self.friendIntimacyLimits = self.friendIntimacyLimits or {}
	self.friendIntimacyTodayLimits = self.friendIntimacyTodayLimits or {}
	self.friendSendGiftLimitCounts = {}
	self.friendshipPermissions = {}

	for _, item in ipairs(resp.Friends) do
		self:addFriendListItem(item.uid)

		uids[#uids + 1] = item.uid
		self.friendships[item.uid] = Utils.calFriendshipLevel(item.intimacy or 0)
		self.friendIntimacies[item.uid] = item.intimacy or 0
		self.friendIntimacyLimits[item.uid] = item.intimacyLimits or {}
		self.friendshipPermissions[item.uid] = item.permissions or {}
		self.friendIntimacyTodayLimits[item.uid] = item.intimacyTodayLimit or 0
		self.friendSendGiftLimitCounts[item.uid] = item.sendGiftLimitCount or 0

		self:setFriendCustomInfo(item.uid, item.groupId, item.remark)
	end

	self:initFriendGroup(resp.FriendGroups)
	pg.me:refreshFriendFuncSettings()
	pg.me:refreshFriendshipLevelLastShow()
	pg.me:queryPlayerInfoList(uids, self.queryPlayerInfoType.FriendList, true)
	pg.me:tryClientTrigger(TriggerConst.TRIGGER_TARGET_FRIENDS_NUM, TriggerConst.TRIGGER_ID_ANY)
	facade:SendMessageCommand(MessageName.RECV_FRIEND_LIST)
end

function ChatSystem:addFriendListItem(playerId)
	local friendList = self.friendList[2].subItems

	friendList[#friendList + 1] = {
		type = 0,
		tIndex = 0,
		playerId = playerId
	}
	self.friendIdSet[playerId] = true
end

function ChatSystem:setFriendSendGiftLimitCount(friendId, sendGiftLimitCount)
	self.friendSendGiftLimitCounts[friendId] = sendGiftLimitCount
end

function ChatSystem:recvFriendPermissionChanged(friendId, permissionId)
	local permissions = self.friendshipPermissions[friendId]

	if permissions == nil then
		permissions = {}
		self.friendshipPermissions[friendId] = permissions
	end

	permissions[tostring(permissionId)] = true

	facade:SendMessageCommand(MessageName.FRIEND_PERMISSION_CHANGED, {
		friendId = friendId,
		permissionId = permissionId
	})
end

function ChatSystem:isFriendshipPermissionUnlocked(friendId, permissionId)
	local funcData = FriendshipLevelFuncData[permissionId]

	if funcData == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("FriendshipLevelFuncData is missing, permissionId=%s, skipped", tostring(permissionId))
		end

		return false
	end

	local unlockValue

	for _, levelData in ipairs(FriendshipLevelData) do
		if table.contains(levelData.levelfunc, permissionId) then
			unlockValue = levelData.friendshipRange[1]

			break
		end
	end

	if unlockValue == nil or unlockValue > self:getFriendIntimacy(friendId) then
		return false
	end

	if funcData.cost == nil then
		return true
	end

	local permissions = self.friendshipPermissions[friendId]

	return permissions ~= nil and permissions[tostring(permissionId)] == true
end

function ChatSystem:setFriendCustomInfo(playerId, groupId, remark)
	if self.friendCustomList[playerId] == nil then
		self.friendCustomList[playerId] = {}
	end

	self.friendCustomList[playerId].remark = remark or self.friendCustomList[playerId].remark
	self.friendCustomList[playerId].groupId = groupId or self.friendCustomList[playerId].groupId

	if not self.friendCustomList[playerId].groupId then
		self.friendCustomList[playerId].groupId = Const.CHAT.CHAT_DEFAULT_LIST_GROUP_ID
	end

	facade:SendMessageCommand(MessageName.UPDATE_FRIEND_CUSTOM_INFO)
end

function ChatSystem:initFriendGroup(groups)
	self.friendGroupList = {}

	self:setFriendGroup(Const.CHAT.CHAT_DEFAULT_LIST_GROUP_ID, pg.getGameString("MY_FRIEND"))

	if groups then
		for _, group in ipairs(groups) do
			self:setFriendGroup(group.id, group.name)
		end
	end

	self:setFriendGroup(Const.CHAT.CHAT_BLACK_LIST_GROUP_ID, pg.getGameString("BLACK_LIST"), true)
end

function ChatSystem:setFriendGroup(groupId, groupName, isBlackList)
	local groupFriendData = {}

	if not isBlackList then
		for friendId, friend in pairs(self.friendCustomList) do
			if not pg.game.chat:checkBlackList(friendId) and friend.groupId == groupId then
				groupFriendData[#groupFriendData + 1] = {
					playerId = friendId
				}
			end
		end
	else
		local blackList = self:getBlackList()

		for _, blackId in ipairs(blackList) do
			groupFriendData[#groupFriendData + 1] = {
				playerId = blackId
			}

			self:setFriendCustomInfo(blackId, groupId)
		end
	end

	local groupIndex = #self.friendGroupList + 1

	for idx, group in ipairs(self.friendGroupList) do
		if group.id == groupId then
			groupIndex = idx

			break
		end
	end

	self.friendGroupList[groupIndex] = {
		subCount = 0,
		id = groupId,
		groupLabel = groupName,
		groupFriendData = groupFriendData,
		expand = #groupFriendData == 0 or pg.global.prefsCacheUtils:getBool(pg.me.uid .. ClientConst.PrefKey.FriendGroupListExpand .. groupId, true),
		totalCount = #groupFriendData,
		isBlackList = isBlackList
	}

	local function innerSort(a, b)
		if a.id == Const.CHAT.CHAT_DEFAULT_LIST_GROUP_ID then
			return true
		end

		if b.id == Const.CHAT.CHAT_DEFAULT_LIST_GROUP_ID then
			return false
		end

		if a.id == Const.CHAT.CHAT_BLACK_LIST_GROUP_ID then
			return false
		end

		if b.id == Const.CHAT.CHAT_BLACK_LIST_GROUP_ID then
			return true
		end

		return a.groupLabel < b.groupLabel
	end

	table.sort(self.friendGroupList, innerSort)

	self.friendGroupId2Index = {}

	for groupIdx, group in ipairs(self.friendGroupList) do
		self.friendGroupId2Index[tostring(group.id)] = groupIdx
	end
end

function ChatSystem:recvMoveFriendToGroup(friendIds, groupId)
	for _, friendId in ipairs(friendIds) do
		local originFriendGroup = self:getFriendGroup(self.friendCustomList[friendId] and self.friendCustomList[friendId].groupId or nil)

		if originFriendGroup then
			for memberIndex, member in ipairs(originFriendGroup.groupFriendData) do
				if member.playerId == friendId then
					table.remove(originFriendGroup.groupFriendData, memberIndex)

					break
				end
			end
		end

		local targetFriendGroup = self:getFriendGroup(groupId)

		targetFriendGroup.groupFriendData[#targetFriendGroup.groupFriendData + 1] = {
			playerId = friendId
		}

		self:setFriendCustomInfo(friendId, groupId)
		facade:SendMessageCommand(MessageName.UPDATE_FRIEND_CUSTOM_INFO)
	end
end

function ChatSystem:getFriendGroupList()
	return self.friendGroupList
end

function ChatSystem:getFriendGroup(groupId)
	if not groupId or not self.friendGroupId2Index[tostring(groupId)] then
		return nil
	end

	return self.friendGroupList[self.friendGroupId2Index[tostring(groupId)]]
end

function ChatSystem:getFriendCustomInfo(playerId)
	return self.friendCustomList[playerId] or {}
end

function ChatSystem:editFriendGroupName(groupId, groupName)
	local friendGroup = self:getFriendGroup(groupId)

	friendGroup.groupLabel = groupName

	local function innerSort(a, b)
		if a.id == Const.CHAT.CHAT_DEFAULT_LIST_GROUP_ID then
			return true
		end

		if b.id == Const.CHAT.CHAT_DEFAULT_LIST_GROUP_ID then
			return false
		end

		if a.id == Const.CHAT.CHAT_BLACK_LIST_GROUP_ID then
			return false
		end

		if b.id == Const.CHAT.CHAT_BLACK_LIST_GROUP_ID then
			return true
		end

		return a.groupLabel < b.groupLabel
	end

	table.sort(self.friendGroupList, innerSort)

	self.friendGroupId2Index = {}

	for groupIdx, group in ipairs(self.friendGroupList) do
		self.friendGroupId2Index[tostring(group.id)] = groupIdx
	end

	facade:SendMessageCommand(MessageName.RECV_FRIEND_LIST)
	facade:SendMessageCommand(MessageName.UPDATE_FRIEND_GROUP)
end

function ChatSystem:removeFriendCustomInfo(targetId)
	if not self.friendCustomList[targetId] then
		return
	end

	local friendGroup = self:getFriendGroup(self.friendCustomList[targetId].groupId)

	if friendGroup and friendGroup.groupFriendData then
		for idx, friend in ipairs(friendGroup.groupFriendData) do
			if friend.playerId == targetId then
				table.remove(friendGroup.groupFriendData, idx)

				break
			end
		end
	end

	self.friendCustomList[targetId] = nil
end

function ChatSystem:setSpecialFriendUId(specialFriendId)
	if string.isNilOrEmpty(specialFriendId) then
		self.specialFriendUId = nil
	else
		self.specialFriendUId = specialFriendId
	end
end

function ChatSystem:getSpecialFriendUId()
	return self.specialFriendUId
end

function ChatSystem:showVariantFriendInvite(playerId, onAccept, onReject, onTimeout)
	local function showInvite(playerInfo)
		if not playerInfo then
			return
		end

		pg.global.ui.tips:addHudNotice(playerId, playerInfo, "", SysConfigData.WAIT_APPLICANT_TIME, onAccept, onReject, onTimeout or onReject, {
			type = 8,
			tIndex = 1,
			funcName = Const.FUNCTION_NAME.FRIEND
		})
	end

	local playerInfo = self:getPlayerInfo(playerId)

	if playerInfo then
		showInvite(playerInfo)

		return
	end

	pg.me:queryPlayerInfo(playerId, nil, true, showInvite)
end

function ChatSystem:checkRecommendFilter(item)
	return item and item.AttributesMap and item.AttributesMap.playerName and string.find(item.AttributesMap.playerName, "-D$") == nil and string.find(item.AttributesMap.playerName, "^fp_account_cn:") == nil
end

function ChatSystem:getFriendRequestList()
	pg.me:fetchApplicants()

	return self.friendRequestList
end

function ChatSystem:recvFriendRequestList(result, resp)
	if not result.status then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("recvFriendRequestList error", result.errmsg)
		end

		return
	end

	local uids = {}

	for _, item in ipairs(resp.Applicants) do
		local isExist = false

		for _, friendReq in ipairs(self.friendRequestList) do
			if friendReq.playerId == item.uid then
				isExist = true

				break
			end
		end

		if not isExist then
			local applicantInfo = self:getPlayerInfo(item.uid)

			if PlatformSocialService:peekPlatformUserBlockedByLocalUser(applicantInfo) == true then
				if LoggerManager.checkLogger(LoggerConst.INFO) then
					logger:info("recvFriendRequestList skip blocked applicant", item.uid)
				end
			else
				local decodedInfo = json.decode(item.info)
				local sourceText = pg.getLocalizationText(FriendSourceData[decodedInfo.sourceId].friendsourceText)

				if not string.isNilOrEmpty(decodedInfo.channelName) then
					sourceText = pg.getFormatText(sourceText, decodedInfo.channelName)
				end

				self.friendRequestList[#self.friendRequestList + 1] = {
					type = 1,
					tIndex = 0,
					playerId = item.uid,
					sourceId = decodedInfo.sourceId,
					sourceText = sourceText
				}
				uids[#uids + 1] = item.uid
			end
		end
	end

	if #uids > 0 then
		pg.me:queryPlayerInfoList(uids, self.queryPlayerInfoType.RequestList, true)
	end
end

local function friendListSort(a, b)
	if a.status == b.status then
		return a.playerId < b.playerId
	end

	return a.status < b.status
end

function ChatSystem:recvQueryPlayerInfoList(type, info, result, resp)
	if not result.status then
		if _G.type(info) == "table" and _G.type(info.onCompleted) == "function" then
			info.onCompleted(false, resp)
		end

		return
	end

	for _, item in ipairs(resp.Results) do
		if item.AttributesMap then
			local playerData = item.AttributesMap

			playerData.stableAttributesDict = Utils.decodeFromStr(item.AttributesMap.stableAttributesStr) or {}
			playerData.uid = item.Uid

			self:setQueriedPlayerData(item.Uid, playerData)
		end
	end

	if type == self.queryPlayerInfoType.FriendList then
		self:refreshFriendStatus()
	elseif type == self.queryPlayerInfoType.FriendApply or type == self.queryPlayerInfoType.RequestList then
		facade:SendMessageCommand(MessageName.RECV_FRIEND_REQUEST_LIST)
	elseif type == self.queryPlayerInfoType.ShowVisitorInfo then
		facade:SendMessageCommand(MessageName.HOMECAR_VISITORS_INFO)
	elseif type == self.queryPlayerInfoType.ChatRecord then
		-- block empty
	end

	if type == self.queryPlayerInfoType.FriendApply then
		local decompressedInfo = json.decode(info)
		local sourceText = pg.getLocalizationText(FriendSourceData[decompressedInfo.sourceId].friendsourceText)

		if not string.isNilOrEmpty(decompressedInfo.channelName) then
			sourceText = pg.getFormatText(sourceText, decompressedInfo.channelName)
		end

		if self.refuseHudNoticeCount == nil or self.refuseHudNoticeCount < 2 then
			pg.global.ui.tips:addHudNotice(resp.Results[1].Uid, self.playerDatas[resp.Results[1].Uid], pg.getGameString("FRIEND_REQUEST"), 10, function()
				pg.me:acceptFriend(resp.Results[1].Uid)
			end, function()
				pg.me:refuseFriend(resp.Results[1].Uid, "")

				if self.refuseHudNoticeCount == nil then
					self.refuseHudNoticeCount = 1
				else
					self.refuseHudNoticeCount = self.refuseHudNoticeCount + 1
				end
			end, function()
				return
			end, {
				isFriendApply = true,
				funcName = Const.FUNCTION_NAME.FRIEND,
				sourceMsg = sourceText
			})
		end

		facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)
	end

	if _G.type(info) == "table" and _G.type(info.onCompleted) == "function" then
		info.onCompleted(true, resp)
	end
end

function ChatSystem:refreshFriendStatus()
	local onlineNum = 0
	local friendUids = {}

	self.friendIntimacyLimits = self.friendIntimacyLimits or {}

	for _, friend in ipairs(self.friendList[2].subItems) do
		local playerInfo = self.playerDatas[friend.playerId]

		if playerInfo then
			friend.status = playerInfo.online and 0 or 1
			friend.loginTime = playerInfo.loginTime
			friend.lastLogoutTime = playerInfo.lastLogoutTime

			if playerInfo.online then
				onlineNum = onlineNum + 1
			end
		else
			friend.status = 1
		end

		friendUids[#friendUids + 1] = friend.playerId
	end

	if #friendUids > 0 then
		pg.me:callService("FriendService", "batchChatQuery", {
			pg.me.uid,
			friendUids
		}, function(result, resp)
			if not result.status then
				for _, friendUid in ipairs(friendUids) do
					self.friendships[friendUid] = Utils.calFriendshipLevel(0)
					self.friendIntimacies[friendUid] = 0
					self.friendIntimacyLimits[friendUid] = {}
				end

				return
			end

			for _, item in ipairs(resp and resp.Results or EMPTY_TABLE) do
				self.friendships[item.Target] = Utils.calFriendshipLevel(item.Intimacy or 0)
				self.friendIntimacies[item.Target] = item.Intimacy or 0
			end
		end)
	end

	table.sort(self.friendList[2].subItems, friendListSort)

	self.friendList[1].label = onlineNum .. "/" .. #self.friendList[2].subItems

	pg.me:tryClientTrigger(TriggerConst.TRIGGER_TARGET_FRIENDS_NUM, TriggerConst.TRIGGER_ID_ANY)
	facade:SendMessageCommand(MessageName.RECV_FRIEND_LIST)
end

function ChatSystem:recvQueryPlayerInfo(uid, type, result, resp, cb, extraInfo)
	local succeeded = result and result.status == true

	if succeeded and resp.AttributesMap then
		local playerData = resp.AttributesMap

		playerData.stableAttributesDict = Utils.decodeFromStr(resp.AttributesMap.stableAttributesStr) or {}
		playerData.uid = uid

		self:setQueriedPlayerData(uid, playerData)
	end

	if type == self.queryPlayerInfoType.FriendAddSearch then
		local playerInfo = {}

		if succeeded and not string.isNilOrEmpty(uid) then
			playerInfo[1] = {
				type = 2,
				tIndex = 0,
				playerId = uid
			}
		end

		facade:SendMessageCommand(MessageName.RECV_QUERY_PLAYER_INFO, playerInfo)
	elseif type == self.queryPlayerInfoType.ChatRecord then
		self:tryCreatePrivateChat(uid)
	elseif type == self.queryPlayerInfoType.ShowPlayerInfo then
		if self:checkFriendList(uid) then
			facade:SendMessageCommand(MessageName.RECV_FRIEND_LIST, self.queryPlayerInfoType.ShowPlayerInfo)
		end
	elseif type == self.queryPlayerInfoType.ApplyTeam then
		self:teamHandleInner(uid, self.playerDatas[uid], extraInfo)
	end

	if cb then
		cb(self.playerDatas[uid], succeeded)
	end
end

function ChatSystem:recvAcceptFriend(applyId, result)
	if result.status then
		self:addFriendListItem(applyId)
		pg.game.chat:clearAddFriendCD(applyId)
		self:recvMoveFriendToGroup({
			applyId
		}, Const.CHAT.CHAT_DEFAULT_LIST_GROUP_ID)
		facade:SendMessageCommand(MessageName.ADD_FRIEND_SUCCESS, applyId)
		facade:SendMessageCommand(MessageName.RECV_FRIEND_LIST)
		facade:SendMessageCommand(MessageName.PLAYER_NAME_CHANGE, applyId)
		self:removeFriendRequest(applyId)
		self:refreshFriendStatus()
	end
end

function ChatSystem:recvRefuseFriend(applyId, result)
	if result.status then
		self:removeFriendRequest(applyId)
	end
end

function ChatSystem:removeFriendRequest(applyId)
	local needRemoveIndex = -1

	for index, item in ipairs(self.friendRequestList) do
		if item.playerId == applyId then
			needRemoveIndex = index

			break
		end
	end

	if needRemoveIndex ~= -1 then
		table.remove(self.friendRequestList, needRemoveIndex)
		facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)
	end

	facade:SendMessageCommand(MessageName.RECV_FRIEND_REQUEST_LIST)
end

function ChatSystem:recvAcceptAllFriends(result, resp)
	if result.status and resp.AcceptUids and #resp.AcceptUids > 0 then
		local acceptUids = {}

		for _, uid in ipairs(resp.AcceptUids) do
			self:addFriendListItem(uid)

			acceptUids[#acceptUids + 1] = uid
		end

		self:recvMoveFriendToGroup(acceptUids, Const.CHAT.CHAT_DEFAULT_LIST_GROUP_ID)

		self.friendRequestList = {}

		facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)
		facade:SendMessageCommand(MessageName.RECV_FRIEND_REQUEST_LIST)
		facade:SendMessageCommand(MessageName.RECV_FRIEND_LIST)
		self:refreshFriendStatus()
	else
		pg.global.ui.tips:showTextTip(pg.getGameString("FRIEND_NUM_LIMIT_TIP"))
	end
end

function ChatSystem:recvRefuseAllFriends(result)
	if result.status then
		self.friendRequestList = {}

		facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)
		facade:SendMessageCommand(MessageName.RECV_FRIEND_REQUEST_LIST)
	end
end

function ChatSystem:recvApplyFriend(result, targetId, info)
	if result.status then
		pg.global.ui.tips:showTextTip(pg.getGameString("CHAT_APPLY_FRIEND_SUCCESS"))

		local decompressedInfo = json.decode(info)

		if string.isNilOrEmpty(decompressedInfo.channelName) and decompressedInfo.sourceId == pg.game.chat.AddFriendSource.ChatChannel then
			decompressedInfo.sourceId = pg.game.chat.AddFriendSource.PlayerCard
		end

		local addFriendSourceInfo = FriendSourceData[decompressedInfo.sourceId]
		local randomTextId = math.random(1, 3)
		local addFriendText = ""

		if randomTextId == 1 then
			addFriendText = addFriendSourceInfo.addfriendchat1
		elseif randomTextId == 2 then
			addFriendText = addFriendSourceInfo.addfriendchat2
		elseif randomTextId == 3 then
			addFriendText = addFriendSourceInfo.addfriendchat3
		end

		addFriendText = pg.getLocalizationText(addFriendText)

		if decompressedInfo.sourceId == pg.game.chat.AddFriendSource.ChatChannel then
			addFriendText = pg.getFormatText(addFriendText, decompressedInfo.channelName or "")
		end

		if not decompressedInfo.skipCreateChat then
			pg.global.ui.chat:createNewChat(nil, targetId, true)
		end

		pg.game.chat:sendMessage(addFriendText, pg.game.chat.subMessageType.Text, pg.game.chat.channelType.Player, targetId, {
			[Const.CHAT_EXTRA_TYPE.ChatType] = Const.CHAT_MESSAGE_TYPE.System
		}, true, {
			skipTextPermissionCheck = true
		})
		pg.game.chat:setAddFriendCD(targetId)
		facade:SendMessageCommand(MessageName.RECV_SCORED_RECOMMEND_FRIEND_LIST)
	end
end

function ChatSystem:applyFriend(playerId, sourceId, channelName, skipCreateChat)
	local sourceInfo = {
		sourceId = sourceId,
		channelName = channelName or nil,
		skipCreateChat = skipCreateChat or nil
	}
	local compressedSourceInfo = json.encode(sourceInfo)

	pg.me:applyFriend(playerId, compressedSourceInfo)
end

function ChatSystem:recvRemoveFriend(targetId, result)
	if result.status then
		pg.me:clearFriendFuncSettings(targetId)

		if self:removeFriendListItem(targetId) == true then
			self:removeFriendCustomInfo(targetId)

			self.friendships[targetId] = -1
			self.friendIntimacies[targetId] = -1

			if self.friendIntimacyLimits then
				self.friendIntimacyLimits[targetId] = nil
			end

			if self.friendIntimacyTodayLimits then
				self.friendIntimacyTodayLimits[targetId] = nil
			end

			self.friendSendGiftLimitCounts[targetId] = nil

			pg.me:setFriendshipLevelLastShow(targetId, 0)
			self:refreshFriendStatus()
			pg.global.ui.tips:showTextTip(pg.getGameString("CHAT_REMOVE_FRIEND_SUCCESS"))
			facade:SendMessageCommand(MessageName.RECV_FRIEND_LIST)
			facade:SendMessageCommand(MessageName.PLAYER_NAME_CHANGE, targetId)
			facade:SendMessageCommand(MessageName.REMOVE_CHANNEL, targetId)
		end
	end
end

function ChatSystem:removeFriendListItem(playerId)
	local friendList = self.friendList[2].subItems

	for index, item in ipairs(friendList) do
		if item.playerId == playerId then
			table.remove(friendList, index)

			self.friendIdSet[playerId] = nil

			return true
		end
	end

	return false
end

function ChatSystem:recvAddBlacklist(targetId, result)
	if result.status and not table.contains(self.blackList, targetId) then
		self:removeChannel(targetId)

		self.blackList[#self.blackList + 1] = targetId

		facade:SendMessageCommand(MessageName.BLACK_LIST_UPDATE)
		pg.global.ui.tips:showTextTip(pg.getGameString("CHAT_ADD_BLACK_LIST_SUCCESS"))
		self:removeFriendCustomInfo(targetId)
		pg.me:fetchFriends(0)
		pg.global.prefsCacheUtils:setInt(pg.me.uid .. ClientConst.PrefKey.FriendshipValue .. targetId, 0)
		pg.global.prefsCacheUtils:setInt(pg.me.uid .. ClientConst.PrefKey.FriendshipLevel .. targetId, 0)
	elseif result.errmsg == "TID_MS_FRIEND_BLACKLIST_CAPACITY_FULL" then
		pg.global.showBubbleMessageRaw(pg.getGameString("TIP_MS_FRIEND_BLACKLIST_CAPACITY_FULL"))
	end
end

function ChatSystem:recvDelBlacklist(targetId, result, groupId)
	if result.status then
		local needRemoveIndex = -1

		for index, playerId in ipairs(self.blackList) do
			if playerId == targetId then
				needRemoveIndex = index

				break
			end
		end

		if needRemoveIndex ~= -1 then
			table.remove(self.blackList, needRemoveIndex)
			pg.global.ui.tips:showTextTip(pg.getGameString("CHAT_DEL_BLACK_LIST_SUCCESS"))
			facade:SendMessageCommand(MessageName.BLACK_LIST_UPDATE)
			pg.me:fetchFriends(0)
		end
	end
end

function ChatSystem:recvFriendApply(applyId, info)
	for _, friendReq in ipairs(self.friendRequestList) do
		if friendReq.playerId == applyId then
			return
		end
	end

	local decompressedInfo = json.decode(info)
	local sourceText = pg.getLocalizationText(FriendSourceData[decompressedInfo.sourceId].friendsourceText)

	if not string.isNilOrEmpty(decompressedInfo.channelName) then
		sourceText = pg.getFormatText(sourceText, decompressedInfo.channelName)
	end

	self.friendRequestList[#self.friendRequestList + 1] = {
		type = 1,
		tIndex = 0,
		playerId = applyId,
		sourceId = decompressedInfo.sourceId,
		sourceText = sourceText
	}

	pg.me:queryPlayerInfoList({
		applyId
	}, self.queryPlayerInfoType.FriendApply, true, info)
end

function ChatSystem:recvFriendAccept(acceptId)
	self:removeFriendRequest(acceptId)
	pg.global.ui.tips:showTextTip(pg.getGameString("CHAT_ADD_BLACK_LIST_SUCCESS"))
	facade:SendMessageCommand(MessageName.ADD_FRIEND_SUCCESS, acceptId)
	facade:SendMessageCommand(MessageName.RECV_FRIEND_LIST)
	facade:SendMessageCommand(MessageName.PLAYER_NAME_CHANGE, acceptId)
	pg.me:fetchFriends(0)
	pg.game.chat:clearAddFriendCD(acceptId)
end

function ChatSystem:recvFriendRefuse(refuseId, info)
	return
end

function ChatSystem:recvFriendRemove(removeId)
	pg.me:clearFriendFuncSettings(removeId)

	if self:removeFriendListItem(removeId) == true then
		self.friendships[removeId] = -1
		self.friendIntimacies[removeId] = -1

		if self.friendIntimacyLimits then
			self.friendIntimacyLimits[removeId] = nil
		end

		if self.friendIntimacyTodayLimits then
			self.friendIntimacyTodayLimits[removeId] = nil
		end

		self.friendSendGiftLimitCounts[removeId] = nil

		pg.me:setFriendshipLevelLastShow(removeId, 0)
		self:removeFriendCustomInfo(removeId)
		self:refreshFriendStatus()
		facade:SendMessageCommand(MessageName.RECV_FRIEND_LIST)
		facade:SendMessageCommand(MessageName.PLAYER_NAME_CHANGE, removeId)
	end
end

function ChatSystem:recvFriendSyncStatus(playerId, info)
	local playerData = self.playerDatas[playerId]

	if playerData == nil then
		return
	end

	local isOnline = info == Const.FriendStatus.Online
	local shouldRemind = playerData.online == false and isOnline and pg.me:isFriendFuncEnabled(playerId, Const.FriendshipPermissionType.OnlineReminder)

	if isOnline then
		playerData.loginTime = Time.secondCache
	else
		playerData.lastLogoutTime = Time.secondCache
	end

	playerData.online = isOnline

	if shouldRemind then
		pg.global.ui.tips:pushFriendOnLineItem({
			uid = playerId
		})
	end

	self:refreshChannelList(playerId)
	self:refreshFriendStatus()
end

function ChatSystem:checkBlackList(playerId)
	return self:checkBlack(playerId)
end

function ChatSystem:checkFriendList(playerId)
	return self.friendIdSet[playerId] == true
end

function ChatSystem:getFriendIdList()
	local friendIds = {}

	for _, item in ipairs(self.friendList[2].subItems) do
		friendIds[#friendIds + 1] = item.playerId
	end

	return friendIds
end

function ChatSystem:setFriendTillableState(playerId, hasTillableFacility)
	local playerInfo = self:getPlayerInfo(playerId)

	if not playerInfo then
		return false
	end

	local oldState = playerInfo.homelandHasTillableFacility == true
	local newState = hasTillableFacility == true

	playerInfo.homelandHasTillableFacility = newState

	return oldState ~= newState
end

function ChatSystem:visitHome(playerId, playerInfo, confirmCallback)
	local allowed = PlatformHomeCampEntryFilterService:canEnterHomeCamp(playerId, playerInfo)

	if not allowed then
		PlatformNoticeUtils.showTextTipById(NoticeDef.CANNOT_ENTER_HOMECAMP)

		return
	end

	local function enterHomeland()
		if pg.me and pg.me.space and Utils.isSpaceDungeon(pg.me.space.spaceType) then
			pg.global.ui.tips:showTextTip(pg.getGameString("APPLY_TEAM_STATUS_ERROR"))

			return
		end

		if confirmCallback then
			confirmCallback()
		end

		pg.me:enterHomelandByUid(playerId)
	end

	local confirmKey = playerInfo.homelandHasTillableFacility == true and "HOMELAND_VISIT_TILLABLE_CONFIRM" or "HOMELAND_VISIT_CONFIRM"

	pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString(confirmKey), enterHomeland)
end

function ChatSystem:syncTeamMembersInfo(teamInfo)
	if teamInfo and teamInfo.membersInfo then
		for uid, info in pairs(teamInfo.membersInfo) do
			info.uid = uid

			self:setPlayerData(uid, info)
		end

		self:prefetchTeamMemberPsnBlockStates(teamInfo.membersInfo)
	end
end

function ChatSystem:prefetchTeamMemberPsnBlockStates(membersInfo)
	if not pg or not pg.me or type(pg.me.requestPsnBlockStates) ~= "function" then
		return
	end

	local uids = {}

	for uid, _ in pairs(membersInfo) do
		if uid ~= pg.me.uid then
			uids[#uids + 1] = uid
		end
	end

	if #uids == 0 then
		return
	end

	pg.me:queryPlayerInfoList(uids, nil, true, nil, function()
		local platformIds = {}

		for _, uid in ipairs(uids) do
			local info = self:getPlayerInfo(uid)
			local platformId = info and info.platformUserId

			if not string.isNilOrEmpty(platformId) then
				platformIds[#platformIds + 1] = platformId
			end
		end

		if #platformIds > 0 then
			pg.me:requestPsnBlockStates(platformIds)
		end
	end)
end

function ChatSystem:onFriendshipUpdate(uid, targetId, value, intimacyLimits, intimacyTodayLimit)
	local friendshipLevel = Utils.calFriendshipLevel(value)
	local friendUid = uid

	if uid == pg.me.uid then
		friendUid = targetId
	end

	local lastFriendshipLevel = self.friendships[friendUid]
	local friendshipValueDelta = value - (self.friendIntimacies[friendUid] or 0)
	local levelUp = lastFriendshipLevel and lastFriendshipLevel < friendshipLevel
	local friendInfo = self:getPlayerInfo(friendUid)

	if friendInfo and friendInfo.playerName and friendshipValueDelta and friendshipValueDelta > 0 then
		local displayName = LuaUIUtils.getPlayerDisplayName(friendUid, friendInfo.playerName, true)
		local hooks = ChatSystem._platformHooks

		displayName = hooks and hooks.resolveFriendshipUpdateName and hooks.resolveFriendshipUpdateName(self, friendUid, friendInfo, displayName) or displayName

		local tip = pg.getFormatText(pg.getGameString("FRIENDSHIIP_LEVEL_UP_TOAST"), displayName or "", friendshipValueDelta or 0)

		pg.global.ui.tips:showTextTip(tip)
	end

	self.friendships[friendUid] = friendshipLevel
	self.friendIntimacies[friendUid] = value
	self.friendIntimacyLimits = self.friendIntimacyLimits or {}
	self.friendIntimacyLimits[friendUid] = intimacyLimits or self.friendIntimacyLimits[friendUid] or {}
	self.friendIntimacyTodayLimits = self.friendIntimacyTodayLimits or {}
	self.friendIntimacyTodayLimits[friendUid] = intimacyTodayLimit or self.friendIntimacyTodayLimits[friendUid] or 0

	facade:SendMessageCommand(MessageName.FRIENDSHIP_UPDATE, {
		friendUid = friendUid,
		levelUp = levelUp,
		friendshipValueDelta = friendshipValueDelta
	})
end

function ChatSystem:setAddFriendCD(playerId)
	if self._addFriendCDCache == nil then
		self._addFriendCDCache = {}
	end

	self._addFriendCDCache[pg.me.uid .. playerId] = Time.realSecondCache
end

function ChatSystem:checkAddFriendCD(playerId)
	if self._addFriendCDCache == nil or self._addFriendCDCache[pg.me.uid .. playerId] == nil then
		return true
	elseif self._addFriendCDCache[pg.me.uid .. playerId] > 0 and self._addFriendCDCache[pg.me.uid .. playerId] + ChatSystem.AddFriendCD < Time.realSecondCache then
		self._addFriendCDCache[pg.me.uid .. playerId] = nil

		return true
	end

	return false
end

function ChatSystem:clearAddFriendCD(playerId)
	if self._addFriendCDCache then
		self._addFriendCDCache[pg.me.uid .. playerId] = nil
	end
end
