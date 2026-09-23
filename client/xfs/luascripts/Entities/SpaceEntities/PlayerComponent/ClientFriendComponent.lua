-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientFriendComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local ClientFriendQueryConfig = require("Entities.SpaceEntities.PlayerComponent.ClientFriendQueryConfig")
local CallbackHandler = require("Core.Common.CallbackHandler")
local IDManager = require("Core.Common.IDManager")
local Const = require("Common.Const.Const")
local Time = require("Core.Common.Time")
local ServiceUtils = require("Common.Utils.ServiceUtils")
local MessageName = require("Const.MessageName")
local EventConst = require("Common.Const.EventConst")
local EntityManager = require("Core.Common.EntityManager")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local ClientConst = require("Const.ClientConst")
local NoticeDef = require("Common.NoticeDef")
local CommonSwitch = require("Common.CommonSwitch")
local AppearanceAction = require("Data.appearance_action_data")
local FriendshipLevelData = require("Data.friendship_level_data")
local FriendshipLevelFuncData = require("Data.friendship_level_func_data")
local PlatformInviteTokenService = require("SDK.Platform.PlatformInviteTokenService")
local PlatformShellInviteDestinationQueryService = require("SDK.Platform.PlatformShellInviteDestinationQueryService")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformSocialService = require("SDK.Platform.PlatformSocialService")
local DiscordFriendService = require("SDK.Discord.DiscordFriendService")
local PSN_BLOCK_REQUEST_COOLDOWN = 15
local FRIEND_TILLABLE_STATE_BATCH_LIMIT = 100
local ClientFriendComponent = class.Component("ClientFriendComponent")
local logger = LoggerManager.getLogger("ClientFriendComponent")
local FRIEND_FUNC_SETTING_TYPE_SET = {
	[Const.FriendshipPermissionType.EnterWorldAutoAccept] = true,
	[Const.FriendshipPermissionType.OnlineReminder] = true,
	[Const.FriendshipPermissionType.TeamAutoAccept] = true
}

local function getFriendFuncPermissionId(funcType)
	if FRIEND_FUNC_SETTING_TYPE_SET[funcType] ~= true then
		return
	end

	for _, levelData in ipairs(FriendshipLevelData) do
		for _, funcId in ipairs(levelData.levelfunc) do
			local funcData = FriendshipLevelFuncData[funcId]

			if funcData == nil then
				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error("FriendshipLevelFuncData is missing, funcId=%s, funcType=%s, skipped", tostring(funcId), tostring(funcType))
				end
			elseif funcData.type == funcType then
				return funcId
			end
		end
	end
end

local function getFriendFuncDefault(funcType)
	return funcType == Const.FriendshipPermissionType.OnlineReminder
end

local function tryPlatformHook(methodName, self, ...)
	local _h = ClientFriendComponent._platformHooks

	return _h and _h[methodName] and _h[methodName](self, ...) == true
end

function ClientFriendComponent:ctor()
	return
end

function ClientFriendComponent:init(avtDict)
	self.acceptAllFriendsTime = 0
	self.queryPlayerTime = 0
	self.friendTillableStateQueryTime = 0
	self.friendTillableStateQueryVersion = 0
	self.recommendPlayerTime = 0
	self.recommendCount = 0

	tryPlatformHook("onInit", self, avtDict)

	return true
end

function ClientFriendComponent:destroy()
	return
end

function ClientFriendComponent:RPC_SC_BindSocialMediaAccount(success, socialMediaType)
	self.logger:info("RPC_SC_BindSocialMediaAccount success=%s socialMediaType=%s", tostring(success), tostring(socialMediaType))
end

function ClientFriendComponent:RPC_SC_UnbindSocialMediaAccount(success, socialMediaType)
	self.logger:info("RPC_SC_UnbindSocialMediaAccount success=%s socialMediaType=%s", tostring(success), tostring(socialMediaType))
end

function ClientFriendComponent:RPC_SC_SyncPlatformShellInviteToken(tokenType, targetKey, token, expireSt)
	PlatformInviteTokenService:onSyncFromServer(tokenType, targetKey, token, expireSt)
end

function ClientFriendComponent:RPC_SC_PlatformShellInviteDestinationResult(requestId, ok, destinationContext)
	PlatformShellInviteDestinationQueryService:onServerResult(requestId, ok, destinationContext)
end

function ClientFriendComponent:RPC_SC_BatchResolveSocialAccounts(requestId, success, socialMediaType, accountUidMap)
	if not success then
		self:_notifyDiscordFriendPlayerInfos({})

		return
	end

	local uids = {}
	local uidSet = {}

	for _, mappedUid in pairs(accountUidMap or EMPTY_TABLE) do
		local uid = tostring(mappedUid or "")

		if not string.isNilOrEmpty(uid) and not uidSet[uid] then
			uidSet[uid] = true
			uids[#uids + 1] = uid
		end
	end

	if #uids == 0 then
		self:_notifyDiscordFriendPlayerInfos({})

		return
	end

	local info = {
		onCompleted = function(querySuccess, resp)
			self:_onDiscordFriendPlayerInfosQueried(accountUidMap, querySuccess, resp)
		end
	}

	self:queryPlayerInfoList(uids, nil, true, info)
end

local commonAttributesList = {
	"stableAttributesStr"
}

function ClientFriendComponent.getCommonAttributesList()
	return commonAttributesList
end

local function applyPlatformAttributesListHook(self, attributesList)
	local _h = ClientFriendComponent._platformHooks

	if _h and _h.appendFriendQueryAttributes then
		_h.appendFriendQueryAttributes(self, attributesList)
	end
end

local function createPlatformQueryAttributesList(self, attributesList)
	local queryAttributesList = lume.iclone(attributesList)

	applyPlatformAttributesListHook(self, queryAttributesList)

	return queryAttributesList
end

local function applyAttributesListHook(self, attributesList)
	lume.append(attributesList, commonAttributesList)
	applyPlatformAttributesListHook(self, attributesList)
end

function ClientFriendComponent:checkQueryPlayerCD()
	if self.queryPlayerTime > 0 and self.queryPlayerTime + Const.Friend.QUERY_PLAYER_CD > Time.realSecondCache then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("%s checkQueryPlayerCD in CD;", self:repr(), self.queryPlayerTime, Time.realSecondCache)
		end

		return false
	end

	self.queryPlayerTime = Time.realSecondCache

	return true
end

function ClientFriendComponent:queryPlayerInfo(uid, type, force, cb, extraInfo)
	if not force and not self:checkQueryPlayerCD() then
		return
	end

	local callback = CallbackHandler(self, "_queryPlayerInfoCallback", uid, type, cb, extraInfo)
	local attributesList = createPlatformQueryAttributesList(self, ClientFriendQueryConfig.queryPlayerInfo)

	self:callService("UserDataService", "getAttribute", {
		uid,
		attributesList
	}, callback, {
		callerId = self.uid
	})
end

function ClientFriendComponent:_queryPlayerInfoCallback(uid, type, cb, extraInfo, result, resp)
	pg.game.chat:recvQueryPlayerInfo(uid, type, result, resp, cb, extraInfo)
end

function ClientFriendComponent:queryPlayerInfoList(uids, type, force, info, cb)
	if not force and not self:checkQueryPlayerCD() then
		return
	end

	local callback = CallbackHandler(self, "_queryPlayerInfoListCallback", type, info, cb)
	local attributesList = createPlatformQueryAttributesList(self, ClientFriendQueryConfig.queryPlayerInfo)

	self:callService("UserDataService", "batchGetAttribute", {
		uids,
		attributesList
	}, callback, {
		callerId = self.uid
	})
end

function ClientFriendComponent:_queryPlayerInfoListCallback(type, info, cb, result, resp)
	pg.game.chat:recvQueryPlayerInfoList(type, info, result, resp)

	if cb then
		cb()
	end
end

function ClientFriendComponent:queryFriendTillableStateList(uids)
	if not uids or #uids == 0 then
		return false
	end

	local nextQueryTime = self.friendTillableStateQueryTime + Const.Friend.QUERY_PLAYER_CD

	if self.friendTillableStateQueryTime > 0 and nextQueryTime > Time.realSecondCache then
		return false
	end

	self.friendTillableStateQueryTime = Time.realSecondCache
	self.friendTillableStateQueryVersion = self.friendTillableStateQueryVersion + 1

	local batchCount = math.ceil(#uids / FRIEND_TILLABLE_STATE_BATCH_LIMIT)
	local queryContext = {
		succeeded = true,
		version = self.friendTillableStateQueryVersion,
		pendingCount = batchCount,
		results = {}
	}
	local attributesList = ClientFriendQueryConfig.queryFriendTillableStateList

	for batchIndex = 1, batchCount do
		local batchUids = {}
		local startIndex = (batchIndex - 1) * FRIEND_TILLABLE_STATE_BATCH_LIMIT + 1
		local endIndex = math.min(batchIndex * FRIEND_TILLABLE_STATE_BATCH_LIMIT, #uids)

		for uidIndex = startIndex, endIndex do
			batchUids[#batchUids + 1] = uids[uidIndex]
		end

		self:callService("UserDataService", "batchGetAttribute", {
			batchUids,
			attributesList
		}, CallbackHandler(self, "_queryFriendTillableStateListCallback", queryContext), {
			callerId = self.uid
		})
	end

	return true
end

function ClientFriendComponent:_queryFriendTillableStateListCallback(queryContext, result, resp)
	queryContext.pendingCount = queryContext.pendingCount - 1

	if not result.status then
		queryContext.succeeded = false
	else
		for _, item in ipairs(resp.Results) do
			queryContext.results[#queryContext.results + 1] = item
		end
	end

	if queryContext.pendingCount > 0 or not queryContext.succeeded then
		return
	end

	if queryContext.version ~= self.friendTillableStateQueryVersion then
		return
	end

	local stateChanged = false

	for _, item in ipairs(queryContext.results) do
		local itemChanged = pg.game.chat:setFriendTillableState(item.Uid, item.AttributesMap.homelandHasTillableFacility == true)

		stateChanged = itemChanged or stateChanged
	end

	if not stateChanged then
		return
	end

	facade:SendMessageCommand(MessageName.RECV_FRIEND_LIST)
end

function ClientFriendComponent:queryDungeonInvitePlayerStateList(uids, callback)
	if not uids or #uids == 0 then
		return false
	end

	local attributesList = ClientFriendQueryConfig.queryDungeonInvitePlayerStateList

	self:callService("UserDataService", "batchGetAttribute", {
		uids,
		attributesList
	}, CallbackHandler(self, "_queryDungeonInvitePlayerStateListCallback", callback), {
		callerId = self.uid
	})

	return true
end

function ClientFriendComponent:_queryDungeonInvitePlayerStateListCallback(callback, result, resp)
	local succeeded = result and result.status == true and resp and resp.Results ~= nil

	if callback then
		callback(succeeded == true, succeeded and resp.Results or nil)
	end
end

function ClientFriendComponent:queryBasicPlayerInfoList(uids, cb)
	if not uids or #uids == 0 then
		return false
	end

	local attributesList = ClientFriendQueryConfig.queryBasicPlayerInfoList

	self:callService("UserDataService", "batchGetAttribute", {
		uids,
		attributesList
	}, CallbackHandler(self, "_queryBasicPlayerInfoListCallback", cb), {
		callerId = self.uid
	})

	return true
end

function ClientFriendComponent:_queryBasicPlayerInfoListCallback(cb, result, resp)
	pg.game.chat:recvBasicPlayerInfoList(result, resp, cb)
end

function ClientFriendComponent:queryPlayerInfoByFuzzyName(name)
	if not self:checkQueryPlayerCD() then
		return
	end

	local attributesList = createPlatformQueryAttributesList(self, ClientFriendQueryConfig.queryPlayerInfoByFuzzyName)
	local callback = CallbackHandler(self, "_queryPlayerInfoByFuzzyNameCallback")

	self:callService("UserDataService", "getFuzzyNameAttribute", {
		name,
		attributesList,
		Const.Friend.RECOMMEND_PAGE_LIMIT
	}, callback, {
		callerId = self.uid
	})
end

function ClientFriendComponent:_queryPlayerInfoByFuzzyNameCallback(result, resp)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("%s ClientFriendComponent _queryPlayerInfoByFuzzyNameCallback", self:repr(), inspect(result), inspect(resp))
	end
end

function ClientFriendComponent:queryUidByPlatformUserId(platformUserId, cb)
	if string.isNilOrEmpty(platformUserId) then
		if cb then
			cb(nil)
		end

		return
	end

	self:callService("UserDataService", "getPlatformUserIdUser", {
		platformUserId
	}, CallbackHandler(self, "_queryUidByPlatformUserIdCallback", cb), {
		callerId = self.uid
	})
end

function ClientFriendComponent:_queryUidByPlatformUserIdCallback(cb, result, resp)
	local uid = result and result.status and resp and resp.Uid or nil

	if string.isNilOrEmpty(uid) then
		uid = nil
	end

	if cb then
		cb(uid)
	end
end

function ClientFriendComponent:queryPlayerInfoByPlatformUserId(platformUserId, queryType, force, cb, extraInfo)
	self:queryUidByPlatformUserId(platformUserId, function(uid)
		if string.isNilOrEmpty(uid) then
			if cb then
				cb(nil)
			end

			return
		end

		self:queryPlayerInfo(uid, queryType, force, cb, extraInfo)
	end)
end

function ClientFriendComponent:RPC_SC_GetRecommendPlayer(resp)
	facade:SendMessageCommand(MessageName.RECV_SCORED_RECOMMEND_FRIEND_LIST)
end

function ClientFriendComponent:getRandomOnlinePlayersInfo(count, callback)
	local GlobalData = require("Core.Client.GlobalData")
	local clusterId = GlobalData.ServerId

	ServiceUtils.callService("RoleService", "CS_GetRandomUids", {
		count,
		clusterId
	}, CallbackHandler(self, "_getRandomOnlineUidsCallback", callback), {
		hint = IDManager.genStrID()
	})
end

function ClientFriendComponent:_getRandomOnlineUidsCallback(callback, result, resp)
	if not result or result.status == false or not resp or resp.uids == nil then
		if callback then
			callback(false)
		end

		return
	end

	self:getUserdataByUids(resp.uids, callback)
end

function ClientFriendComponent:getUserdataByUids(uids, callback)
	if not uids or #uids == 0 then
		if callback then
			callback(true, {})
		end

		return
	end

	local attributesList = {
		"playerName",
		"level",
		"online",
		"starTitle",
		"loginTime",
		"lastLogoutTime",
		"teamId",
		"teamMembers",
		"matchStatus",
		"teamDungeonSceneId",
		"showPetInfo",
		"headIcon",
		"headFrame",
		"userName",
		"homelandKey"
	}

	applyAttributesListHook(self, attributesList)
	self:callService("UserDataService", "batchGetAttribute", {
		uids,
		attributesList,
		true
	}, CallbackHandler(self, "_getUserdataByUidsCallback", callback), {
		callerId = self.uid
	})
end

function ClientFriendComponent:_getUserdataByUidsCallback(callback, result, resp)
	if not result or result.status == false or not resp or resp.Results == nil then
		if callback then
			callback(false)
		end

		return
	end

	pg.game.chat:recvQueryPlayerInfoList(nil, nil, result, resp)

	if callback then
		callback(true, resp.Results)
	end
end

function ClientFriendComponent:fetchFriends(startIndex)
	self:callService("FriendService", "fetchFriends", {
		self.uid,
		startIndex,
		Const.Friend.PAGE_LIMIT
	}, CallbackHandler(self, "_fetchFriendsCallback"), {
		callerId = self.uid
	})
end

function ClientFriendComponent:_fetchFriendsCallback(result, resp)
	pg.game.chat:recvFriendList(result, resp)
end

function ClientFriendComponent:queryDiscordFriendPlayerInfos(discordUserIds, callback)
	if type(discordUserIds) ~= "table" or #discordUserIds == 0 then
		if callback then
			callback({})
		end

		return nil
	end

	local accountIds = {}

	for _, discordUserId in ipairs(discordUserIds) do
		discordUserId = tostring(discordUserId or "")

		if not string.isNilOrEmpty(discordUserId) then
			accountIds[#accountIds + 1] = discordUserId
		end
	end

	if #accountIds == 0 then
		if callback then
			callback({})
		end

		return nil
	end

	self.discordFriendPlayerInfoCallback = callback

	local requestId = lume.uuid()

	self:serverMsg("RPC_CS_BatchResolveSocialAccounts", requestId, "discord", accountIds)
end

function ClientFriendComponent:_onDiscordFriendPlayerInfosQueried(accountUidMap, success, resp)
	if not success then
		self:_notifyDiscordFriendPlayerInfos({})

		return
	end

	local playerInfoByUid = {}

	for _, item in ipairs(resp and resp.Results or EMPTY_TABLE) do
		local uid = tostring(item and item.Uid or "")

		if not string.isNilOrEmpty(uid) and type(item.AttributesMap) == "table" then
			playerInfoByUid[uid] = item.AttributesMap
		end
	end

	local playerInfoMap = {}

	for accountId, mappedUid in pairs(accountUidMap or EMPTY_TABLE) do
		local uid = tostring(mappedUid or "")

		if playerInfoByUid[uid] then
			playerInfoMap[tostring(accountId)] = playerInfoByUid[uid]
		end
	end

	self:_notifyDiscordFriendPlayerInfos(playerInfoMap)
end

function ClientFriendComponent:_notifyDiscordFriendPlayerInfos(playerInfoMap)
	if self.discordFriendPlayerInfoCallback then
		self.discordFriendPlayerInfoCallback(playerInfoMap or {})
	end
end

function ClientFriendComponent:RPC_SC_CreateDiscordActivityInviteResult(success, joinSecret, partyId, currentPartySize, maxPartySize, inviteType, targetDiscordUserId)
	DiscordFriendService.onDiscordActivityInviteCreated(success, joinSecret, partyId, currentPartySize, maxPartySize, inviteType, targetDiscordUserId)
end

function ClientFriendComponent:RPC_SC_FriendDataChanged()
	self:fetchFriends(0)
end

function ClientFriendComponent:unlockFriendshipPermission(friendId, permissionId)
	if pg.game.chat:isFriendshipPermissionUnlocked(friendId, permissionId) then
		return
	end

	self:serverMsg("RPC_CS_UnlockFriendshipPermission", friendId, permissionId)
end

function ClientFriendComponent:RPC_SC_FriendPermissionChanged(friendId, permissionId)
	pg.game.chat:recvFriendPermissionChanged(friendId, permissionId)
end

function ClientFriendComponent:fetchApplicants()
	self:callService("FriendService", "fetchApplicants", {
		self.uid
	}, CallbackHandler(self, "_fetchApplicantsCallback"), {
		callerId = self.uid
	})
end

function ClientFriendComponent:_fetchApplicantsCallback(result, resp)
	pg.game.chat:recvFriendRequestList(result, resp)
end

function ClientFriendComponent:applyFriend(targetId, info)
	if not CommonSwitch.CHAT then
		pg.global.showBubbleMessage(NoticeDef.COMMON_SWITCH_CLOSE_TIP)

		return
	end

	if not pg.game.chat:checkAddFriendCD(targetId) then
		pg.global.showBubbleMessageRaw(pg.getGameString("RECOMMEND_PLAYER_CD"), 3)

		return
	end

	pg.game.chat:setAddFriendCD(targetId)
	self:callService("FriendService", "apply", {
		self.uid,
		targetId,
		info
	}, CallbackHandler(self, "_applyFriendCallback", targetId, info), {
		callerId = self.uid
	})
end

function ClientFriendComponent:_applyFriendCallback(targetId, info, result)
	if not result or result.status == false then
		if result and result.errmsg == Const.Friend.TID_MS_FRIEND_APPLY_FRIEND_FULL then
			pg.global.ui.tips:showTextTip(pg.getGameString("FRIEND_NUM_LIMIT_TIP"))
		elseif result and result.errmsg == Const.Friend.TID_MS_FRIEND_APPLY_COOLDOWN then
			pg.global.showBubbleMessageRaw(pg.getGameString("RECOMMEND_PLAYER_CD"), 3)
		elseif result and result.errmsg == Const.Friend.TID_MS_FRIEND_APPLY_COUNT_LIMIT then
			pg.global.showBubbleMessageRaw(pg.getGameString("APPLY_FRIEND_COUNT_LIMIT"), 3)
		elseif result and result.errmsg == Const.Friend.TID_MS_FRIEND_APPLY_ALREADY_IN_APPLICATIONS then
			pg.global.showBubbleMessageRaw(pg.getGameString("TIP_MS_FRIEND_APPLY_ALREADY_IN_APPLICATIONS"), 3)
		elseif result and result.errmsg == Const.Friend.TID_MS_FRIEND_APPLY_TOO_FREQUENTLY then
			pg.global.showBubbleMessageRaw(pg.getGameString("APPLY_FRIEND_TOO_FREQUENTLY"), 3)
		elseif result and not string.isNilOrEmpty(result.errmsg) then
			pg.global.showBubbleMessageRaw(pg.getGameString(result.errmsg), 3)
		end

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("ClientFriendComponent _applyFriendCallback", self:repr(), inspect(result))
		end

		return
	end

	pg.game.chat:recvApplyFriend(result, targetId, info)
end

function ClientFriendComponent:acceptFriend(applyId)
	if not CommonSwitch.CHAT then
		pg.global.showBubbleMessage(NoticeDef.COMMON_SWITCH_CLOSE_TIP)

		return
	end

	self:callService("FriendService", "accept", {
		self.uid,
		applyId
	}, CallbackHandler(self, "_acceptFriendCallback", applyId), {
		callerId = self.uid
	})
end

function ClientFriendComponent:_acceptFriendCallback(applyId, result)
	if not result or result.status == false then
		if result and (result.errmsg == Const.Friend.TID_MS_FRIEND_ACCEPT_FRIEND_FULL_SELF or result.errmsg == Const.Friend.TID_MS_FRIEND_ACCEPT_FRIEND_FULL_OTHER) then
			pg.global.ui.tips:showTextTip(pg.getGameString("FRIEND_NUM_LIMIT_TIP"))
		end

		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("ClientFriendComponent _acceptFriendCallback", self:repr(), inspect(result))
		end

		return
	end

	pg.game.chat:recvAcceptFriend(applyId, result)
end

function ClientFriendComponent:refuseFriend(applyId, info)
	if not CommonSwitch.CHAT then
		pg.global.showBubbleMessage(NoticeDef.COMMON_SWITCH_CLOSE_TIP)

		return
	end

	self:callService("FriendService", "refuse", {
		self.uid,
		applyId,
		info
	}, CallbackHandler(self, "_refuseFriendCallback", applyId), {
		callerId = self.uid
	})
end

function ClientFriendComponent:_refuseFriendCallback(applyId, result)
	pg.game.chat:recvRefuseFriend(applyId, result)
end

function ClientFriendComponent:acceptAllFriends()
	if not CommonSwitch.CHAT then
		pg.global.showBubbleMessage(NoticeDef.COMMON_SWITCH_CLOSE_TIP)

		return
	end

	self:callService("FriendService", "acceptAll", {
		self.uid
	}, CallbackHandler(self, "_acceptAllFriendsCallback"), {
		callerId = self.uid
	})
end

function ClientFriendComponent:_acceptAllFriendsCallback(result, resp)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientFriendComponent _acceptAllFriendsCallback", self:repr(), inspect(result))
	end

	pg.game.chat:recvAcceptAllFriends(result, resp)
end

function ClientFriendComponent:refuseAllFriends()
	if not CommonSwitch.CHAT then
		pg.global.showBubbleMessage(NoticeDef.COMMON_SWITCH_CLOSE_TIP)

		return
	end

	self:callService("FriendService", "refuseAll", {
		self.uid
	}, CallbackHandler(self, "_refuseAllFriendsCallback"), {
		callerId = self.uid
	})
end

function ClientFriendComponent:_refuseAllFriendsCallback(result)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientFriendComponent _refuseAllFriendsCallback", self:repr(), inspect(result))
	end

	pg.game.chat:recvRefuseAllFriends(result)
end

function ClientFriendComponent:refuseBatchFriends(applyIds, info, isNotify)
	if not CommonSwitch.CHAT then
		pg.global.showBubbleMessage(NoticeDef.COMMON_SWITCH_CLOSE_TIP)

		return
	end

	self:callService("FriendService", "refuseBatch", {
		self.uid,
		applyIds,
		info,
		isNotify
	}, CallbackHandler(self, "_refuseBatchFriendsCallback"), {
		callerId = self.uid
	})
end

function ClientFriendComponent:_refuseBatchFriendsCallback(result)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientFriendComponent _refuseBatchFriendsCallback", self:repr(), inspect(result))
	end
end

function ClientFriendComponent:removeFriend(targetId)
	if not CommonSwitch.CHAT then
		pg.global.showBubbleMessage(NoticeDef.COMMON_SWITCH_CLOSE_TIP)

		return
	end

	self:callService("FriendService", "remove", {
		self.uid,
		targetId
	}, CallbackHandler(self, "_removeFriendCallback", targetId), {
		callerId = self.uid
	})
end

function ClientFriendComponent:_removeFriendCallback(targetId, result)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientFriendComponent _removeFriendCallback", self:repr(), inspect(result))
	end

	pg.game.chat:recvRemoveFriend(targetId, result)
end

function ClientFriendComponent:fetchBlacklist()
	self:callService("FriendService", "fetchBlacklist", {
		self.uid
	}, CallbackHandler(self, "_fetchBlacklistCallback"), {
		callerId = self.uid
	})
end

function ClientFriendComponent:_fetchBlacklistCallback(result, resp)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientFriendComponent _fetchBlacklistCallback", self:repr(), inspect(result), inspect(resp.Blacklist))
	end

	pg.game.chat:refreshBlackList(resp.Blacklist)
end

function ClientFriendComponent:addBlacklist(targetId)
	if not CommonSwitch.CHAT then
		pg.global.showBubbleMessage(NoticeDef.COMMON_SWITCH_CLOSE_TIP)

		return
	end

	self:callService("FriendService", "addBlacklist", {
		self.uid,
		targetId
	}, CallbackHandler(self, "_addBlacklistCallback", targetId), {
		callerId = self.uid
	})
end

function ClientFriendComponent:_addBlacklistCallback(targetId, result)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientFriendComponent _addBlacklistCallback", self:repr(), inspect(result))
	end

	pg.game.chat:recvAddBlacklist(targetId, result)
end

function ClientFriendComponent:delBlacklist(targetId, groupId)
	if not CommonSwitch.CHAT then
		pg.global.showBubbleMessage(NoticeDef.COMMON_SWITCH_CLOSE_TIP)

		return
	end

	groupId = groupId or Const.CHAT.CHAT_DEFAULT_LIST_GROUP_ID

	self:callService("FriendService", "delBlacklist", {
		self.uid,
		targetId
	}, CallbackHandler(self, "_delBlacklistCallback", targetId, groupId), {
		callerId = self.uid
	})
end

function ClientFriendComponent:_delBlacklistCallback(targetId, groupId, result)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientFriendComponent _delBlacklistCallback", self:repr(), inspect(result))
	end

	if not result.status then
		if result.errmsg == Const.Friend.TID_MS_FRIEND_APPLY_FRIEND_FULL then
			pg.global.showBubbleMessageRaw(pg.getGameString("FRIEND_NUM_LIMIT_TIP"))
		end

		return
	end

	pg.game.chat:recvDelBlacklist(targetId, result, groupId)
end

function ClientFriendComponent:setFriendRemark(targetId, remark)
	if not CommonSwitch.CHAT then
		pg.global.showBubbleMessage(NoticeDef.COMMON_SWITCH_CLOSE_TIP)

		return
	end

	if string.strlen(remark) > Const.Friend.REMARK_MAX_LENGTH * 2 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("ClientFriendComponent setFriendRemark remark too long", self:repr(), targetId, remark)
		end

		return
	end

	self:callService("ChatService", "textCheck", {
		self.uid,
		Const.TEXT_CHECK_TYPE.PERMANENT,
		remark
	}, CallbackHandler(self, "_setFriendRemarkTextCheckCallback", targetId, remark), {
		callerId = self.uid
	})
end

function ClientFriendComponent:_setFriendRemarkTextCheckCallback(targetId, remark, result, response)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientFriendComponent _setFriendRemarkTextCheckCallback", self:repr(), targetId, remark, inspect(result), inspect(response))
	end

	if result.status and response.RiskLevel == Const.RISK_LEVEL.PASS then
		self:callService("FriendService", "setRemark", {
			self.uid,
			targetId,
			remark
		}, CallbackHandler(self, "_setFriendRemarkCallback", targetId, remark), {
			callerId = self.uid
		})
	else
		pg.global.showBubbleMessageById(NoticeDef.TID_NAME_CHECK_FAILED)

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("ClientFriendComponent _setFriendRemarkTextCheckCallback text check not pass", self:repr(), targetId, remark, inspect(result), inspect(response))
		end

		return
	end
end

function ClientFriendComponent:_setFriendRemarkCallback(targetId, remark, result)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientFriendComponent _setFriendRemarkCallback", self:repr(), targetId, remark, inspect(result))
	end

	if result.status then
		pg.global.showBubbleMessageRaw(pg.getGameString(ClientConst.FRIEND_CUSTOMIZE_SUCCESS_TIP.SET_FRIEND_REMARK_SUCCESS))
		pg.game.chat:setFriendCustomInfo(targetId, nil, remark)

		if pg.global.ui:checkUIOpen(UIConst.UI_ID_CHANGE_NAME) then
			pg.global.ui.changeName:close()
		end
	else
		pg.global.showBubbleMessageRaw(pg.getGameString(result.errmsg))
	end
end

function ClientFriendComponent:createFriendGroup(groupName, uids)
	if not CommonSwitch.CHAT then
		pg.global.showBubbleMessage(NoticeDef.COMMON_SWITCH_CLOSE_TIP)

		return
	end

	if string.strlen(groupName) > Const.Friend.GROUP_NAME_MAX_LENGTH * 2 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("ClientFriendComponent createFriendGroup groupName too long", self:repr(), groupName)
		end

		return
	end

	self:callService("ChatService", "textCheck", {
		self.uid,
		Const.TEXT_CHECK_TYPE.PERMANENT,
		groupName
	}, CallbackHandler(self, "_createFriendGroupTextCheckCallback", groupName, uids), {
		callerId = self.uid
	})
end

function ClientFriendComponent:_createFriendGroupTextCheckCallback(groupName, uids, result, response)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientFriendComponent _createFriendGroupTextCheckCallback", self:repr(), groupName, inspect(result), inspect(response))
	end

	if result.status and response.RiskLevel == Const.RISK_LEVEL.PASS then
		self:callService("FriendService", "createFriendGroup", {
			self.uid,
			groupName
		}, CallbackHandler(self, "_createFriendGroupCallback", groupName, uids), {
			callerId = self.uid
		})
	else
		pg.global.showBubbleMessageById(NoticeDef.TID_NAME_CHECK_FAILED)

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("ClientFriendComponent _createFriendGroupTextCheckCallback text check not pass", self:repr(), groupName, inspect(result), inspect(response))
		end

		return
	end
end

function ClientFriendComponent:_createFriendGroupCallback(groupName, uids, result, resp)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientFriendComponent _createFriendGroupCallback", self:repr(), groupName, inspect(result), inspect(resp))
	end

	if result.status then
		pg.game.chat:setFriendGroup(resp.GroupId, groupName)

		if #uids > 0 then
			self:moveFriendToGroup(uids, resp.GroupId)
		else
			facade:SendMessageCommand(MessageName.UPDATE_FRIEND_CUSTOM_INFO)
		end

		pg.global.showBubbleMessageRaw(pg.getGameString("CREATE_FRIEND_GROUP_SUCCESS"))
	else
		pg.global.showBubbleMessageRaw(pg.getGameString(result.errmsg))
	end
end

function ClientFriendComponent:editFriendGroupName(groupId, newGroupName)
	if not CommonSwitch.CHAT then
		pg.global.showBubbleMessage(NoticeDef.COMMON_SWITCH_CLOSE_TIP)

		return
	end

	if string.strlen(newGroupName) > Const.Friend.GROUP_NAME_MAX_LENGTH * 2 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("ClientFriendComponent editFriendGroupName newGroupName too long", self:repr(), newGroupName)
		end

		return
	end

	self:callService("ChatService", "textCheck", {
		self.uid,
		Const.TEXT_CHECK_TYPE.PERMANENT,
		newGroupName
	}, CallbackHandler(self, "_editFriendGroupNameTextCheckCallback", groupId, newGroupName), {
		callerId = self.uid
	})
end

function ClientFriendComponent:_editFriendGroupNameTextCheckCallback(groupId, newGroupName, result, response)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientFriendComponent _editFriendGroupNameTextCheckCallback", self:repr(), groupId, newGroupName, inspect(result), inspect(response))
	end

	if result.status and response.RiskLevel == Const.RISK_LEVEL.PASS then
		self:callService("FriendService", "updateFriendGroup", {
			self.uid,
			groupId,
			newGroupName
		}, CallbackHandler(self, "_editFriendGroupNameCallback", groupId, newGroupName), {
			callerId = self.uid
		})
	else
		pg.global.showBubbleMessageById(NoticeDef.TID_NAME_CHECK_FAILED)

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("ClientFriendComponent _editFriendGroupNameTextCheckCallback text check not pass", self:repr(), groupId, newGroupName, inspect(result), inspect(response))
		end

		return
	end
end

function ClientFriendComponent:_editFriendGroupNameCallback(groupId, newGroupName, result)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientFriendComponent _editFriendGroupNameCallback", self:repr(), groupId, newGroupName, inspect(result))
	end

	if result.status then
		pg.global.showBubbleMessageRaw(pg.getGameString(ClientConst.FRIEND_CUSTOMIZE_SUCCESS_TIP.EDIT_FRIEND_GROUP_NAME_SUCCESS))
		pg.game.chat:editFriendGroupName(groupId, newGroupName)
	else
		pg.global.showBubbleMessageRaw(pg.getGameString(result.errmsg))
	end
end

function ClientFriendComponent:deleteFriendGroup(groupId)
	if not CommonSwitch.CHAT then
		pg.global.showBubbleMessage(NoticeDef.COMMON_SWITCH_CLOSE_TIP)

		return
	end

	self:callService("FriendService", "deleteFriendGroup", {
		self.uid,
		groupId
	}, CallbackHandler(self, "_deleteFriendGroupCallback", groupId), {
		callerId = self.uid
	})
end

function ClientFriendComponent:_deleteFriendGroupCallback(groupId, result)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientFriendComponent _deleteFriendGroupCallback", self:repr(), groupId, inspect(result))
	end

	if result.status then
		pg.global.showBubbleMessageRaw(pg.getGameString(ClientConst.FRIEND_CUSTOMIZE_SUCCESS_TIP.DELETE_FRIEND_GROUP_SUCCESS))
		pg.me:fetchFriends(0)
	else
		pg.global.showBubbleMessageRaw(pg.getGameString(result.errmsg))
	end
end

function ClientFriendComponent:moveFriendToGroup(targetIds, groupId)
	if not CommonSwitch.CHAT then
		pg.global.showBubbleMessage(NoticeDef.COMMON_SWITCH_CLOSE_TIP)

		return
	end

	groupId = groupId or 0

	self:callService("FriendService", "moveFriendToGroup", {
		self.uid,
		targetIds,
		groupId
	}, CallbackHandler(self, "_moveFriendToGroupCallback", targetIds, groupId), {
		callerId = self.uid
	})
end

function ClientFriendComponent:_moveFriendToGroupCallback(targetIds, groupId, result)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientFriendComponent _moveFriendToGroupCallback", self:repr(), targetIds, groupId, inspect(result))
	end

	if result.status then
		pg.global.showBubbleMessageRaw(pg.getGameString(ClientConst.FRIEND_CUSTOMIZE_SUCCESS_TIP.MOVE_FRIEND_TO_GROUP_SUCCESS))
		pg.game.chat:recvMoveFriendToGroup(targetIds, groupId)
	else
		pg.global.showBubbleMessageRaw(pg.getGameString(result.errmsg))
	end
end

function ClientFriendComponent:FriendService_onFriendApply(applyId, info)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientFriendComponent FriendService_onFriendApply", self:repr(), applyId, info)
	end

	local senderInfo = pg.game.chat and pg.game.chat:getPlayerInfo(applyId)

	if PlatformIdentityUtils.getCurrentPlatformFamily() == PlatformIdentityUtils.Family.PlayStation and PlatformSocialService:peekPlatformUserBlockedByLocalUser(senderInfo) == true then
		return
	end

	pg.game.chat:recvFriendApply(applyId, info)
end

function ClientFriendComponent:FriendService_onFriendAccept(acceptId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientFriendComponent FriendService_onFriendAccept", self:repr(), acceptId)
	end

	pg.game.chat:recvFriendAccept(acceptId)
end

function ClientFriendComponent:FriendService_onFriendRefuse(refuseId, info)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientFriendComponent FriendService_onFriendRefuse", self:repr(), refuseId, info)
	end

	pg.game.chat:recvFriendRefuse(refuseId, info)
end

function ClientFriendComponent:FriendService_onFriendRemove(removeId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientFriendComponent FriendService_onFriendRemove", self:repr(), removeId)
	end

	pg.game.chat:recvFriendRemove(removeId)
end

function ClientFriendComponent:FriendService_onFriendSyncStatus(syncId, info)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientFriendComponent FriendService_onFriendSyncStatus", self:repr(), syncId, info)
	end

	pg.game.chat:recvFriendSyncStatus(syncId, info)
end

function ClientFriendComponent:FriendService_onAddIntimacy(Uid, Target, Intimacy, IntimacyLimits, IntimacyTodayLimit)
	pg.game.chat:onFriendshipUpdate(Uid, Target, Intimacy, IntimacyLimits, IntimacyTodayLimit)
end

function ClientFriendComponent:FriendService_onSpecialFriendSet(specialFriendId)
	if pg.game.chat.specialFriendUId == specialFriendId then
		return
	end

	local function inner(playerId)
		if string.isNilOrEmpty(playerId) then
			return
		end

		local player = EntityManager.getEntityByUid(playerId)

		if not player then
			return
		end

		self:executeTopLogoComponentMethod(UIConst.TOPLOGO_COMPONENT.COMBAT, "refreshVariant")
	end

	local oldUid = pg.game.chat.specialFriendUId

	pg.game.chat:setSpecialFriendUId(specialFriendId)
	facade:SendMessageCommand(MessageName.VARIANT_FRIEND_CHANGED, {
		oldUid = oldUid or "",
		newUid = specialFriendId
	})
	inner(oldUid)
	inner(specialFriendId)

	if not string.isNilOrEmpty(specialFriendId) then
		pg.global.ui.friendshipUp:open({
			isVariant = true,
			playerId = specialFriendId
		}, nil, nil, {
			cameraPresetKey = 2,
			rtHeight = 606,
			rtWidth = 1024
		})
	end

	local _h = ClientFriendComponent._platformHooks

	if _h and _h.FriendService_onSpecialFriendSet then
		_h.FriendService_onSpecialFriendSet(self, specialFriendId)
	end
end

function ClientFriendComponent:getOnlineFriendList(count)
	local res = {}
	local friends = pg.game.chat:getFriendList()

	for _, friend in ipairs(friends) do
		local playerInfo = pg.game.chat:getPlayerInfo(friend.playerId)

		if playerInfo and playerInfo.online then
			table.insert(res, friend.playerId)

			if count and count <= #res then
				return res
			end
		end
	end

	return res
end

function ClientFriendComponent:isFriendFuncEnabled(friendUid, funcType)
	local permissionId = getFriendFuncPermissionId(funcType)
	local permissionUnlocked = permissionId ~= nil and pg.game.chat:isFriendshipPermissionUnlocked(friendUid, permissionId)

	if not permissionUnlocked then
		return false
	end

	local settings = self:getClientInfo(Const.CLIENT_KEY.FRIEND_FUNC_AUTO_CONSENT, "settings")
	local friendSettings = settings[friendUid]
	local value = friendSettings and friendSettings[tostring(funcType)]

	if value == nil then
		return getFriendFuncDefault(funcType)
	end

	return value == true
end

function ClientFriendComponent:setFriendFuncEnabled(friendUid, funcType, enabled)
	local permissionId = getFriendFuncPermissionId(funcType)
	local permissionUnlocked = permissionId ~= nil and pg.game.chat:isFriendshipPermissionUnlocked(friendUid, permissionId)

	if not permissionUnlocked then
		return false
	end

	local settings = self:getClientInfo(Const.CLIENT_KEY.FRIEND_FUNC_AUTO_CONSENT, "settings")
	local typeKey = tostring(funcType)
	local friendSettings = settings[friendUid]

	enabled = enabled == true

	if enabled == getFriendFuncDefault(funcType) then
		if friendSettings == nil or friendSettings[typeKey] == nil then
			return true
		end

		friendSettings[typeKey] = nil

		if next(friendSettings) == nil then
			settings[friendUid] = nil
		end
	else
		friendSettings = friendSettings or {}

		if friendSettings[typeKey] == enabled then
			return true
		end

		friendSettings[typeKey] = enabled
		settings[friendUid] = friendSettings
	end

	return self:setClientInfo(Const.CLIENT_KEY.FRIEND_FUNC_AUTO_CONSENT, "settings", settings)
end

function ClientFriendComponent:clearFriendFuncSettings(friendUid)
	local settings = self:getClientInfo(Const.CLIENT_KEY.FRIEND_FUNC_AUTO_CONSENT, "settings")

	if settings[friendUid] == nil then
		return true
	end

	settings[friendUid] = nil

	return self:setClientInfo(Const.CLIENT_KEY.FRIEND_FUNC_AUTO_CONSENT, "settings", settings)
end

function ClientFriendComponent:refreshFriendFuncSettings()
	local settings = self:getClientInfo(Const.CLIENT_KEY.FRIEND_FUNC_AUTO_CONSENT, "settings")
	local needRemove = {}

	for friendUid in pairs(settings) do
		if not pg.game.chat:checkFriendList(friendUid) then
			needRemove[#needRemove + 1] = friendUid
		end
	end

	if #needRemove == 0 then
		return true
	end

	for _, friendUid in ipairs(needRemove) do
		settings[friendUid] = nil
	end

	return self:setClientInfo(Const.CLIENT_KEY.FRIEND_FUNC_AUTO_CONSENT, "settings", settings)
end

function ClientFriendComponent:getFriendshipLevelLastShow(uid)
	local data = self:getClientInfo(Const.CLIENT_KEY.FRIEND, "friendship_pop")

	return data[uid] or 0
end

function ClientFriendComponent:setFriendshipLevelLastShow(uid, level)
	local data = self:getClientInfo(Const.CLIENT_KEY.FRIEND, "friendship_pop")

	data[uid] = level

	self:setClientInfo(Const.CLIENT_KEY.FRIEND, "friendship_pop", data)
end

function ClientFriendComponent:refreshFriendshipLevelLastShow()
	local data = self:getClientInfo(Const.CLIENT_KEY.FRIEND, "friendship_pop")
	local needRemove = {}

	for uid, value in pairs(data) do
		if pg.game.chat.friendships[uid] == nil then
			table.insert(needRemove, uid)
		end
	end

	for _, uid in ipairs(needRemove) do
		data[uid] = nil
	end

	self:setClientInfo(Const.CLIENT_KEY.FRIEND, "friendship_pop", data)
end

function ClientFriendComponent:RPC_SC_OnChangeVariantFriend(uid1, uid2, isSet)
	local friendUid

	if uid1 == self.uid then
		friendUid = uid2
	elseif uid2 == self.uid then
		friendUid = uid1
	end

	if friendUid == nil then
		self.logger:error("RPC_SC_OnChangeVariantFriend mismatch, uid1=%s, uid2=%s", uid1, uid2, self:repr())

		return
	end

	self.logger:debug("RPC_SC_OnChangeVariantFriend, uid=%s, friendUid=%s, isSet=%s", self.uid, friendUid, isSet)
end

function ClientFriendComponent:sendGifts(uid, gifts)
	self:serverMsg("RPC_CS_SendGift", uid, gifts, CallbackHandler(self, "_sendGiftsCallback", uid))
end

function ClientFriendComponent:_sendGiftsCallback(uid, result)
	if result then
		pg.global.ui.tips:showTextTip(pg.getGameString("SEND_FRIEDN_GIFT_SUCCESS"))
		pg.game.chat:sendMessage(pg.getGameString("RECV_FRIEND_GIFT_TIP"), pg.game.chat.subMessageType.Text, pg.game.chat.channelType.Player, uid, {
			[Const.CHAT_EXTRA_TYPE.ChatType] = Const.CHAT_MESSAGE_TYPE.System
		})
		pg.game.chat:tryCreatePrivateChat(uid)
		facade:sendMsgToUI(MessageName.SEND_FRIEND_GIFT_RESULT)
	end
end

function ClientFriendComponent:RPC_SC_FriendSendGiftLimitChanged(friendId, sendGiftLimitCount)
	pg.game.chat:setFriendSendGiftLimitCount(friendId, sendGiftLimitCount)
	facade:sendMsgToUI(MessageName.SEND_FRIEND_GIFT_RESULT, {
		friendId = friendId,
		sendGiftLimitCount = sendGiftLimitCount
	})
end

function ClientFriendComponent:queryPlayerInfoByName(name)
	pg.me:callService("NameService", "findName", {
		name
	}, CallbackHandler(self, "findNameCb"))
end

function ClientFriendComponent:findNameCb(retStatus, resp)
	if retStatus.status then
		self:queryPlayerInfo(resp.Uid, pg.game.chat.queryPlayerInfoType.FriendAddSearch, true)
	end
end

function ClientFriendComponent:inviteEnterPhotoWorld(uid)
	if not self.space or not self.space:isPhotoWorld() or not self.space:isPhotoWorldOwner(self.uid) then
		pg.global.ui.tips:showTextTip("not in photo world")

		return
	end

	if tryPlatformHook("inviteEnterPhotoWorldByShellActivity", self, uid) then
		return
	end

	self:serverMsg("RPC_CS_InviteEnterPhotoWorld", uid)
	pg.global.ui.tips:showTextTip(pg.getGameString("SEND_INVITE_SUCCESS"))
end

function ClientFriendComponent:RPC_SC_ReceiveEnterPhotoWorldRequest(playerInfo, worldInfo)
	print("RPC_SC_ReceiveEnterPhotoWorldRequest: ", inspect(playerInfo), inspect(worldInfo))
	pg.global.ui.tips:addHudNotice(playerInfo.uid, playerInfo, pg.getGameString("PHOTO_WORLD_TIP_1"), 10, function()
		self:handleEnterPhotoWorldRequest(playerInfo, worldInfo)
	end, function()
		return
	end, function()
		return
	end)
end

function ClientFriendComponent:handleEnterPhotoWorldRequest(playerInfo, worldInfo)
	if not self:isMatchStatusInit() or Utils.isSelfInSpaceDungeon() or pg.me:isInCombat() then
		pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_STUDIO_FORBID"))

		return
	end

	self:serverMsg("RPC_CS_HandleEnterPhotoWorldRequest", playerInfo, worldInfo)
end

local function getPsnBlockStateTime()
	return Time.realSecondCache or os.time()
end

function ClientFriendComponent:RPC_SC_SyncPsnBlockStates(response)
	if type(response) ~= "table" then
		return
	end

	if not self._psnBlockStates then
		self._psnBlockStates = {}
	end

	local states = response.blockStates or response

	self.logger:info("psn_block_states_received count=%s", tostring(type(states) == "table" and #states or "not_table"))

	if type(states) ~= "table" then
		return
	end

	local updateTime = getPsnBlockStateTime()

	for _, entry in ipairs(states) do
		if entry.accountId then
			local accountId = tostring(entry.accountId)

			self._psnBlockStates[accountId] = {
				relation = entry.relation or "NONE",
				updateTime = updateTime
			}
		end
	end

	if #states == 0 then
		return
	end

	if pg and pg.game and pg.game.chat and type(pg.game.chat.refreshPlatformFilteredChatMessages) == "function" then
		pg.game.chat:refreshPlatformFilteredChatMessages("psn_block_states_updated")
	end

	local hookResult = tryPlatformHook("onPsnBlockStatesUpdated", self)
end

function ClientFriendComponent:getPsnBlockRelation(accountId, ttl)
	if string.isNilOrEmpty(accountId) or not self._psnBlockStates then
		return nil
	end

	accountId = tostring(accountId)

	local state = self._psnBlockStates[accountId]

	if type(state) ~= "table" then
		return state
	end

	local expired = false

	if type(ttl) == "number" and type(state.updateTime) == "number" then
		expired = ttl <= getPsnBlockStateTime() - state.updateTime
	end

	return state.relation, expired
end

function ClientFriendComponent:isPsnBlockedBy(accountId)
	local relation = self:getPsnBlockRelation(accountId)

	return relation == "BLOCKED_BY" or relation == "BLOCKED_BOTH"
end

function ClientFriendComponent:requestPsnBlockStates(targetAccountIds, forceCheck, cooldownOverride)
	if PlatformIdentityUtils.getCurrentPlatformFamily() ~= PlatformIdentityUtils.Family.PlayStation then
		return
	end

	if type(targetAccountIds) ~= "table" or #targetAccountIds == 0 then
		return
	end

	local effectiveCooldown = type(cooldownOverride) == "number" and cooldownOverride >= 0 and cooldownOverride or PSN_BLOCK_REQUEST_COOLDOWN
	local now = getPsnBlockStateTime()
	local accountIds = {}
	local seen = {}
	local selfAccountId = self.platformUserId and tostring(self.platformUserId) or nil

	self._psnBlockStateLastRequestTime = self._psnBlockStateLastRequestTime or {}

	for _, rawAccountId in ipairs(targetAccountIds) do
		if not string.isNilOrEmpty(rawAccountId) then
			local accountId = tostring(rawAccountId)
			local relation, expired = self:getPsnBlockRelation(accountId, effectiveCooldown)
			local lastRequestTime = self._psnBlockStateLastRequestTime[accountId] or 0

			if accountId ~= selfAccountId and not seen[accountId] and (forceCheck or relation == nil or expired) and effectiveCooldown <= now - lastRequestTime then
				seen[accountId] = true
				self._psnBlockStateLastRequestTime[accountId] = now
				accountIds[#accountIds + 1] = accountId
			end
		end
	end

	if #accountIds == 0 then
		return
	end

	self.logger:info("psn_block_request_send count=%s ids=%s", tostring(#accountIds), table.concat(accountIds, ","))
	self:serverMsg("RPC_CS_RequestPsnBlockStates", accountIds)
end

return ClientFriendComponent
