-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformSocialService.lua

local logger = require("SDK.Platform.PlatformLogger")
local TimerManager = require("Core.Timer.TimerManager")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformUtils = require("Common.Utils.PlatformUtils")
local EventConst = require("Common.Const.EventConst")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local PlatformSocialService = {}

PlatformSocialService.EVENT_FRIENDS_UPDATED = "friendsUpdated"
PlatformSocialService.EVENT_PRESENCE_CHANGED = "presenceChanged"
PlatformSocialService.POLL_INTERVAL = 0
PlatformSocialService.FRIEND_SNAPSHOT_FIELDS = {
	"userId",
	"displayName",
	"avatarUrl",
	"platform",
	"platformFamily",
	"presenceState",
	"presenceText",
	"titleName",
	"isOnline",
	"isFavorite",
	"isFriend",
	"isTitleActive"
}
PlatformSocialService.state = {
	ownerUserId = "",
	enabled = false,
	listeners = {
		[PlatformSocialService.EVENT_FRIENDS_UPDATED] = {},
		[PlatformSocialService.EVENT_PRESENCE_CHANGED] = {}
	}
}

function PlatformSocialService.isPlatformSupported()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.IsSupported and PlatformBridgeLuaFacade.IsSupported()
end

function PlatformSocialService.getSignedInUserId()
	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.GetSignedInUserId then
		return ""
	end

	local userId = PlatformBridgeLuaFacade.GetSignedInUserId()

	if string.isNilOrEmpty(userId) then
		return ""
	end

	return tostring(userId)
end

function PlatformSocialService.resetCachedSocialState(clearOwner)
	PlatformSocialService.state.friendSnapshot = nil
	PlatformSocialService.state.friendIndex = nil

	if clearOwner ~= false then
		PlatformSocialService.state.ownerUserId = ""
	end
end

function PlatformSocialService.bindSignedInUser()
	local ownerUserId = PlatformSocialService.getSignedInUserId()

	if string.isNilOrEmpty(ownerUserId) then
		PlatformSocialService.resetCachedSocialState()

		return false
	end

	if PlatformSocialService.state.ownerUserId ~= ownerUserId then
		PlatformSocialService.resetCachedSocialState(false)

		PlatformSocialService.state.ownerUserId = ownerUserId
	end

	return true
end

function PlatformSocialService.iterateCsCollection(collection, handler)
	if not collection or type(handler) ~= "function" then
		return
	end

	local length = collection.Length

	if length then
		for i = 0, length - 1 do
			handler(collection[i])
		end

		return
	end

	local count = collection.Count

	if count then
		for i = 0, count - 1 do
			handler(collection[i])
		end

		return
	end

	for _, item in ipairs(collection) do
		handler(item)
	end
end

function PlatformSocialService.isPlatformAvoidListReady()
	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.IsPlatformAvoidListReady then
		return true
	end

	return PlatformBridgeLuaFacade.IsPlatformAvoidListReady() == true
end

function PlatformSocialService.isSocialFriendsSnapshotReady()
	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.IsSocialFriendsSnapshotReady then
		return true
	end

	return PlatformBridgeLuaFacade.IsSocialFriendsSnapshotReady() == true
end

function PlatformSocialService.resolvePlatformUserId(playerInfoOrUserId)
	if type(playerInfoOrUserId) == "table" then
		return PlatformIdentityUtils.resolvePlatformUserId(playerInfoOrUserId)
	end

	return playerInfoOrUserId
end

function PlatformSocialService.getFriendSortName(friend)
	local sortName = friend.displayName

	if string.isNilOrEmpty(sortName) then
		sortName = friend.userId
	end

	return tostring(sortName or "")
end

function PlatformSocialService.areFriendSnapshotsEqual(left, right)
	if left == right then
		return true
	end

	if type(left) ~= "table" or type(right) ~= "table" or #left ~= #right then
		return false
	end

	for index, leftFriend in ipairs(left) do
		local rightFriend = right[index]

		if type(rightFriend) ~= "table" then
			return false
		end

		for _, fieldName in ipairs(PlatformSocialService.FRIEND_SNAPSHOT_FIELDS) do
			if leftFriend[fieldName] ~= rightFriend[fieldName] then
				return false
			end
		end
	end

	return true
end

function PlatformSocialService.buildFriendList(csFriends)
	local list = {}
	local index = {}

	PlatformSocialService.iterateCsCollection(csFriends, function(csFriend)
		if not csFriend then
			return
		end

		local userId = tostring(csFriend.UserId or csFriend.userId or "")

		if string.isNilOrEmpty(userId) then
			return
		end

		local platform = csFriend.Platform or ""
		local entry = {
			isFriend = true,
			isOnline = false,
			userId = userId,
			displayName = csFriend.DisplayName or "",
			avatarUrl = csFriend.AvatarUrl or "",
			platform = platform,
			platformFamily = PlatformUtils.resolveRawPlatformFamily(platform),
			presenceState = csFriend.PresenceState or "Unknown",
			presenceText = csFriend.PresenceText or "",
			titleName = csFriend.TitleName or "",
			isFavorite = csFriend.IsFavorite == true,
			isTitleActive = csFriend.IsTitleActive == true
		}

		table.insert(list, entry)

		index[userId] = entry
	end)
	table.sort(list, function(a, b)
		if a.isOnline == b.isOnline then
			return PlatformSocialService.getFriendSortName(a) < PlatformSocialService.getFriendSortName(b)
		end

		return a.isOnline and not b.isOnline
	end)

	return list, index
end

function PlatformSocialService.buildEventPayload(csEvent)
	if not csEvent then
		return nil
	end

	local payload = {
		eventType = csEvent.EventType or "",
		shouldRefresh = csEvent.ShouldRefreshFriends == true,
		result = csEvent.Result or 0,
		affectedUserIds = {}
	}

	PlatformSocialService.iterateCsCollection(csEvent.AffectedUserIds, function(userId)
		if not string.isNilOrEmpty(userId) then
			table.insert(payload.affectedUserIds, tostring(userId))
		end
	end)

	return payload
end

function PlatformSocialService.notifyListeners(eventName, payload)
	local bucket = PlatformSocialService.state.listeners[eventName]

	if not bucket then
		return
	end

	for idx = #bucket, 1, -1 do
		local callback = bucket[idx]

		if callback then
			local ok, err = xpcall(callback, debug.traceback, payload)

			if not ok then
				logger:error("%s 回调执行失败: %s", eventName, err)
			end
		end
	end
end

function PlatformSocialService.emitPlatformEvent(eventName, payload)
	if pg and pg.global and pg.global.eventEmitter and eventName then
		pg.global.eventEmitter:emit(eventName, payload or {})
	end
end

function PlatformSocialService.emitFriendListChanged(source, reason, affectedUserIds)
	PlatformSocialService.emitPlatformEvent(EventConst.PLATFORM_FRIEND_LIST_CHANGED, {
		source = source,
		reason = reason,
		affectedUserIds = affectedUserIds or {}
	})
end

function PlatformSocialService.emitBlockListChanged(source, reason, affectedUserIds)
	PlatformSocialService.emitPlatformEvent(EventConst.PLATFORM_BLOCK_LIST_CHANGED, {
		source = source,
		reason = reason,
		affectedUserIds = affectedUserIds or {}
	})
end

function PlatformSocialService.stopPolling()
	if not PlatformSocialService.state.pollTimerId then
		return
	end

	TimerManager.removeTimer(PlatformSocialService.state.pollTimerId)

	PlatformSocialService.state.pollTimerId = nil
end

function PlatformSocialService.startPolling()
	if PlatformSocialService.state.pollTimerId or not PlatformSocialService.state.enabled then
		return
	end

	PlatformSocialService.state.pollTimerId = TimerManager.addRepeatTimer(PlatformSocialService.POLL_INTERVAL, function()
		PlatformSocialService:_pumpSocialEvents()
	end)
end

function PlatformSocialService:isSupported()
	return PlatformSocialService.isPlatformSupported()
end

function PlatformSocialService:_ensureReady()
	if not self:isSupported() then
		PlatformSocialService.resetCachedSocialState()

		return false
	end

	if not PlatformSocialService.state.enabled then
		return self:initialize()
	end

	if not PlatformBridgeLuaFacade.EnsureSocialManagerReady() then
		PlatformSocialService.resetCachedSocialState()

		return false
	end

	return PlatformSocialService.bindSignedInUser()
end

function PlatformSocialService:_readFriendSnapshot(forceRefresh)
	if not self:_ensureReady() then
		return {}, {}, false
	end

	if not PlatformSocialService.isSocialFriendsSnapshotReady() then
		PlatformSocialService.resetCachedSocialState(false)

		return {}, {}, false
	end

	if forceRefresh ~= true and PlatformSocialService.state.friendSnapshot ~= nil then
		return PlatformSocialService.state.friendSnapshot, PlatformSocialService.state.friendIndex, true
	end

	local friends, index = PlatformSocialService.buildFriendList(PlatformBridgeLuaFacade.GetSocialFriendsSnapshot())

	PlatformSocialService.state.friendSnapshot = friends
	PlatformSocialService.state.friendIndex = index

	return friends, index, true
end

function PlatformSocialService:_pumpSocialEvents()
	if not self:_ensureReady() then
		return
	end

	local events = PlatformBridgeLuaFacade.PumpSocialEvents()

	if not events then
		return
	end

	local refreshNeeded = false

	PlatformSocialService.iterateCsCollection(events, function(csEvent)
		local payload = PlatformSocialService.buildEventPayload(csEvent)

		if not payload then
			return
		end

		logger:info("收到平台社交事件 eventType=%s result=%s shouldRefresh=%s affectedUsers=%s", tostring(payload.eventType), tostring(payload.result), tostring(payload.shouldRefresh), tostring(#payload.affectedUserIds))

		if payload.shouldRefresh then
			refreshNeeded = true

			PlatformSocialService.emitBlockListChanged("platform_social_event", payload.eventType, payload.affectedUserIds)
		end

		if #PlatformSocialService.state.listeners[PlatformSocialService.EVENT_PRESENCE_CHANGED] > 0 then
			PlatformSocialService.notifyListeners(PlatformSocialService.EVENT_PRESENCE_CHANGED, payload)
		end
	end)

	if refreshNeeded then
		logger:info("平台社交事件触发好友列表刷新。")
	end

	if refreshNeeded then
		self:refreshFriends(true)
	end
end

function PlatformSocialService:initialize()
	if PlatformSocialService.state.enabled then
		return true
	end

	if not self:isSupported() then
		return false
	end

	if not PlatformBridgeLuaFacade.EnsureSocialManagerReady() then
		logger:warn("平台社交模块尚未准备就绪")

		return false
	end

	if not PlatformSocialService.bindSignedInUser() then
		return false
	end

	PlatformSocialService.state.enabled = true

	PlatformSocialService.startPolling()
	self:_pumpSocialEvents()
	logger:info("PlatformSocialService 已启动。")

	return true
end

function PlatformSocialService:init()
	return self:initialize()
end

function PlatformSocialService:shutdown()
	if PlatformSocialService.state.enabled then
		logger:info("PlatformSocialService 开始关闭。")
	end

	PlatformSocialService.stopPolling()

	PlatformSocialService.state.enabled = false

	PlatformSocialService.resetCachedSocialState()
end

function PlatformSocialService:refreshFriends(forceNotify)
	local friends, _, ready = self:_readFriendSnapshot(true)

	if not ready then
		return friends
	end

	logger:info("刷新平台好友列表 count=%s forceNotify=%s", tostring(#friends), tostring(forceNotify))

	if forceNotify or #PlatformSocialService.state.listeners[PlatformSocialService.EVENT_FRIENDS_UPDATED] > 0 then
		PlatformSocialService.notifyListeners(PlatformSocialService.EVENT_FRIENDS_UPDATED, friends)
	end

	if forceNotify then
		PlatformSocialService.emitFriendListChanged("refreshFriends", "platform_friends_updated", {})
	end

	return friends
end

function PlatformSocialService:getFriends()
	local friends = self:_readFriendSnapshot()

	return friends
end

function PlatformSocialService:getFriendByUserId(userId)
	if string.isNilOrEmpty(userId) then
		return nil
	end

	local _, friendIndex, ready = self:_readFriendSnapshot()

	if not ready then
		return nil
	end

	return friendIndex[tostring(userId)]
end

function PlatformSocialService:peekPlatformUserBlockedByLocalUser(playerInfoOrUserId)
	if not self:isSupported() or not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.IsPlatformUserBlockedByLocalUser then
		return false
	end

	local targetUserId = PlatformSocialService.resolvePlatformUserId(playerInfoOrUserId)

	if string.isNilOrEmpty(targetUserId) then
		return false
	end

	if not PlatformSocialService.isPlatformAvoidListReady() then
		return nil
	end

	return PlatformBridgeLuaFacade.IsPlatformUserBlockedByLocalUser(tostring(targetUserId)) == true
end

function PlatformSocialService:isPlatformUserBlockedByLocalUser(playerInfoOrUserId)
	return self:peekPlatformUserBlockedByLocalUser(playerInfoOrUserId) == true
end

function PlatformSocialService:refreshPlatformFriendCache()
	local oldFriends = PlatformSocialService.state.friendSnapshot
	local friends, _, ready = self:_readFriendSnapshot(true)

	if ready == true then
		if not PlatformSocialService.areFriendSnapshotsEqual(oldFriends, friends) then
			PlatformSocialService.emitFriendListChanged("refreshPlatformFriendCache", "platform_friend_cache_changed", {})
		end

		PlatformSocialService.emitBlockListChanged("refreshPlatformFriendCache", "platform_block_cache_may_changed", {})
	end

	return ready == true
end

function PlatformSocialService:peekIsPlatformFriend(playerInfoOrUserId)
	local targetUserId = PlatformSocialService.resolvePlatformUserId(playerInfoOrUserId)

	if string.isNilOrEmpty(targetUserId) then
		return false
	end

	local _, friendIndex, ready = self:_readFriendSnapshot()

	if not ready then
		return nil
	end

	return friendIndex[tostring(targetUserId)] ~= nil
end

function PlatformSocialService:subscribe(eventName, callback)
	local bucket = PlatformSocialService.state.listeners[eventName]

	if not bucket or type(callback) ~= "function" then
		return nil
	end

	table.insert(bucket, callback)

	return callback
end

function PlatformSocialService:unsubscribe(eventName, callback)
	local bucket = PlatformSocialService.state.listeners[eventName]

	if not bucket or not callback then
		return
	end

	for idx = #bucket, 1, -1 do
		if bucket[idx] == callback then
			table.remove(bucket, idx)

			break
		end
	end
end

function PlatformSocialService:onFriendsUpdated(callback)
	return self:subscribe(PlatformSocialService.EVENT_FRIENDS_UPDATED, callback)
end

function PlatformSocialService:onPresenceChanged(callback)
	return self:subscribe(PlatformSocialService.EVENT_PRESENCE_CHANGED, callback)
end

return PlatformSocialService
