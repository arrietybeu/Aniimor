-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformFriendTabComponent.lua

local M = {}
local ClientTextUtils = require("Utils.ClientTextUtils")
local PlatformTextCommunicationService = require("SDK.Platform.PlatformTextCommunicationService")
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformDisplayNameInjector = require("SDK.Platform.UIBridge.PlatformDisplayNameInjector")
local PlatformDisplayNameConfig = require("SDK.Platform.UIBridge.PlatformDisplayNameConfig")
local PlatformSocialService = require("SDK.Platform.PlatformSocialService")
local PlatformFriendListService = require("SDK.Platform.PlatformFriendListService")
local logger = require("SDK.Platform.PlatformLogger")
local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")

M.PLATFORM_UID_MAPPING_RETRY_INTERVAL = 30
M.PLATFORM_UID_MAPPING_MAX_CACHE_SECONDS = 14400
M.DEFAULT_PLATFORM_FAMILY = "unknown"
M.PLATFORM_FRIENDS_GROUP_ID = "platform_friends"
M.ADD_FRIEND_CONFIG = PlatformDisplayNameConfig.UI_Node_ChatPanel_Friend_Add
M.PLATFORM_CALLBACK_OWNER = "SDK.Platform.UIBridge.ImpPlatformFriendTabComponent"
M._activePlatformCallbackOwner = nil
M.ConsolePlatformType = {
	PlayStation = 2,
	Xbox = 1,
	None = 0
}
M.FriendChannelType = {
	Apply = 2,
	Friend = 1,
	AddFriend = 0,
	Group = 3
}

function M.getPlatformSocialService()
	return PlatformSocialService
end

function M.normalizePlatformFamily(platformFamily)
	platformFamily = tostring(platformFamily or "")

	if string.isNilOrEmpty(platformFamily) then
		return M.DEFAULT_PLATFORM_FAMILY
	end

	return platformFamily
end

function M.getPlatformUidMappingCacheKey(platformFamily, platformUserId)
	return M.normalizePlatformFamily(platformFamily) .. ":" .. tostring(platformUserId or "")
end

function M.getPlatformPlayerInfoCacheTime()
	return Time and Time.secondCache or os.time()
end

function M.isPlatformUidMappingCacheExpired(cacheEntry)
	if not cacheEntry or not cacheEntry.updatedAt then
		return true
	end

	local currentTime = M.getPlatformPlayerInfoCacheTime()

	return currentTime >= cacheEntry.updatedAt + M.PLATFORM_UID_MAPPING_MAX_CACHE_SECONDS
end

function M.isPlatformPlayerInfoCacheExpired(playerInfo)
	if not playerInfo or not playerInfo.platformInfoCachedAt then
		return true
	end

	local currentTime = M.getPlatformPlayerInfoCacheTime()

	return currentTime >= playerInfo.platformInfoCachedAt + M.PLATFORM_UID_MAPPING_MAX_CACHE_SECONDS
end

function M.isSelfUid(uid)
	return not string.isNilOrEmpty(uid) and pg and pg.me and tostring(uid) == tostring(pg.me.uid)
end

function M.trimPlatformText(value)
	if value == nil then
		return ""
	end

	return tostring(value):match("^%s*(.-)%s*$")
end

function M.getPlatformFriendFallbackName(friend)
	local platformFamily = M.normalizePlatformFamily(friend and friend.platformFamily or PlatformIdentityUtils.getCurrentPlatformFamily())
	local key = platformFamily == PlatformIdentityUtils.Family.PlayStation and "PS_FRIEND" or "XBOX_FRIEND"

	if pg and pg.getGameString then
		local text = pg.getGameString(key)

		if not string.isNilOrEmpty(text) and text ~= key then
			return text
		end
	end

	return "Platform Friend"
end

function M.buildPlatformPlayerName(friend)
	if friend == nil then
		return ""
	end

	local platformUserId = M.trimPlatformText(friend.platformUserId or friend.userId)
	local displayName = M.trimPlatformText(friend.displayName)

	if not string.isNilOrEmpty(displayName) and displayName ~= platformUserId then
		return displayName
	end

	return M.getPlatformFriendFallbackName(friend)
end

M.CONSOLE_PLATFORM_TYPE_BY_FAMILY = {
	[PlatformIdentityUtils.Family.Xbox] = M.ConsolePlatformType.Xbox,
	[PlatformIdentityUtils.Family.PlayStation] = M.ConsolePlatformType.PlayStation
}

function M:getConsolePlatformType()
	if self.consolePlatformType ~= nil then
		return self.consolePlatformType
	end

	local family = PlatformIdentityUtils.getCurrentPlatformFamily()

	self.consolePlatformType = M.CONSOLE_PLATFORM_TYPE_BY_FAMILY[family] or M.ConsolePlatformType.None

	return self.consolePlatformType
end

function M:openPlatformProfileEntry()
	local platformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade

	if platformBridgeLuaFacade.SupportsShowPlayerProfileCard() then
		local signedInUserId = platformBridgeLuaFacade.GetSignedInUserId()

		if not string.isNilOrEmpty(signedInUserId) then
			platformBridgeLuaFacade.ShowPlayerProfileCard(signedInUserId)

			return
		end
	end
end

function M:getPlatformUidMappingEntry(platformUserId, platformFamily)
	platformUserId = platformUserId and tostring(platformUserId) or ""
	platformFamily = M.normalizePlatformFamily(platformFamily or PlatformIdentityUtils.getCurrentPlatformFamily())

	if string.isNilOrEmpty(platformUserId) then
		return nil
	end

	self.platformUidMappingCache = self.platformUidMappingCache or {}

	local cacheKey = M.getPlatformUidMappingCacheKey(platformFamily, platformUserId)
	local cacheEntry = self.platformUidMappingCache[cacheKey]

	if cacheEntry and M.isPlatformUidMappingCacheExpired(cacheEntry) then
		self.platformUidMappingCache[cacheKey] = nil

		return nil
	end

	return cacheEntry
end

function M:getMappedGameUid(platformUserId, platformFamily)
	local cacheEntry = self:getPlatformUidMappingEntry(platformUserId, platformFamily)

	if cacheEntry and cacheEntry.hasMappedGameUid == true and not string.isNilOrEmpty(cacheEntry.gameUid) then
		return cacheEntry.gameUid, true
	end

	return nil, false
end

function M:setPlatformUidMappingCacheEntry(platformUserId, platformFamily, gameUid)
	platformUserId = platformUserId and tostring(platformUserId) or ""
	platformFamily = M.normalizePlatformFamily(platformFamily or PlatformIdentityUtils.getCurrentPlatformFamily())

	if string.isNilOrEmpty(platformUserId) then
		return
	end

	gameUid = gameUid and tostring(gameUid) or ""
	self.platformUidMappingCache = self.platformUidMappingCache or {}
	self.platformUidMappingCache[M.getPlatformUidMappingCacheKey(platformFamily, platformUserId)] = {
		platformUserId = platformUserId,
		platformFamily = platformFamily,
		gameUid = gameUid,
		hasMappedGameUid = not string.isNilOrEmpty(gameUid),
		updatedAt = M.getPlatformPlayerInfoCacheTime()
	}
end

function M:shouldQueryPlatformUidMapping(platformUserId, platformFamily)
	platformUserId = platformUserId and tostring(platformUserId) or ""
	platformFamily = M.normalizePlatformFamily(platformFamily or PlatformIdentityUtils.getCurrentPlatformFamily())

	if string.isNilOrEmpty(platformUserId) then
		return false
	end

	local cacheKey = M.getPlatformUidMappingCacheKey(platformFamily, platformUserId)

	self.platformUidMappingPending = self.platformUidMappingPending or {}

	if self.platformUidMappingPending[cacheKey] then
		return false
	end

	local cacheEntry = self:getPlatformUidMappingEntry(platformUserId, platformFamily)

	if cacheEntry == nil then
		return true
	end

	if cacheEntry.hasMappedGameUid == true then
		return false
	end

	return (cacheEntry.updatedAt or 0) + M.PLATFORM_UID_MAPPING_RETRY_INTERVAL <= M.getPlatformPlayerInfoCacheTime()
end

function M:queryPlatformUidMapping(platformFamily, platformUserId, onResolved)
	if not pg or not pg.me or not pg.me.queryPlayerInfoByPlatformUserId or string.isNilOrEmpty(platformUserId) then
		return false
	end

	platformFamily = M.normalizePlatformFamily(platformFamily)

	local cacheKey = M.getPlatformUidMappingCacheKey(platformFamily, platformUserId)

	self.platformUidMappingPending = self.platformUidMappingPending or {}
	self.platformUidMappingPending[cacheKey] = true

	local selfRef = self

	pg.me:queryPlayerInfoByPlatformUserId(platformUserId, pg.game.chat.queryPlayerInfoType.FriendList, true, function(playerInfo)
		selfRef.platformUidMappingPending[cacheKey] = nil

		local gameUid = playerInfo and playerInfo.uid or ""

		selfRef:setPlatformUidMappingCacheEntry(platformUserId, platformFamily, gameUid)

		if onResolved then
			onResolved()
		end
	end)

	return true
end

function M:refreshPlatformUidMappingAsync(friends)
	if type(friends) ~= "table" or #friends == 0 then
		return
	end

	local platformFamily = M.normalizePlatformFamily(PlatformIdentityUtils.getCurrentPlatformFamily())
	local pendingUserIds = {}
	local dedupe = {}

	for _, friend in ipairs(friends) do
		local platformUserId = tostring(friend.platformUserId or friend.userId or friend.playerId or "")

		if not string.isNilOrEmpty(platformUserId) and not dedupe[platformUserId] and self:shouldQueryPlatformUidMapping(platformUserId, platformFamily) then
			dedupe[platformUserId] = true

			table.insert(pendingUserIds, platformUserId)
		end
	end

	if #pendingUserIds == 0 then
		return
	end

	local remaining = #pendingUserIds
	local selfRef = self

	local function onOneResolved()
		remaining = remaining - 1

		if remaining <= 0 and selfRef.curPanelType == M.FriendChannelType.Friend then
			selfRef:refreshFriendList()
		end
	end

	for _, platformUserId in ipairs(pendingUserIds) do
		if not self:queryPlatformUidMapping(platformFamily, platformUserId, onOneResolved) then
			onOneResolved()
		end
	end
end

function M:cachePlatformPlayerInfo(playerInfo)
	if not playerInfo then
		return
	end

	self.platformFriendSnapshot = self.platformFriendSnapshot or {}
	self.platformFriendSnapshotByPlatformUserId = self.platformFriendSnapshotByPlatformUserId or {}

	if not string.isNilOrEmpty(playerInfo.playerId) then
		self.platformFriendSnapshot[playerInfo.playerId] = playerInfo
	end

	if not string.isNilOrEmpty(playerInfo.uid) then
		self.platformFriendSnapshot[playerInfo.uid] = playerInfo
	end

	local platformUserId = PlatformIdentityUtils.resolvePlatformUserId(playerInfo)

	if not string.isNilOrEmpty(platformUserId) then
		self.platformFriendSnapshot[platformUserId] = playerInfo
		self.platformFriendSnapshotByPlatformUserId[platformUserId] = playerInfo
	end

	if playerInfo.hasMappedGameUid == true and not string.isNilOrEmpty(playerInfo.uid) and pg and pg.game and pg.game.chat then
		pg.game.chat:setPlayerData(playerInfo.uid, playerInfo)
	end
end

function M:cachePlatformFriendSnapshot(friendData)
	if not friendData or not friendData.playerInfo then
		return
	end

	self:cachePlatformPlayerInfo(friendData.playerInfo)
end

function M:convertPlatformFriendToPlayerInfo(friend)
	if not friend or not PlatformFriendListService.buildPlatformFriendEntry then
		return nil
	end

	local entry = PlatformFriendListService:buildPlatformFriendEntry(friend, {
		mappedOnly = false
	})

	return entry and entry.playerInfo or nil
end

function M:getRealtimePlatformPlayerInfo(friendId)
	local cachedInfo = self.platformFriendSnapshot and self.platformFriendSnapshot[friendId] or nil

	if cachedInfo and M.isPlatformPlayerInfoCacheExpired(cachedInfo) then
		return nil
	end

	return cachedInfo
end

function M:requestPlatformPlayerInfo(entry)
	if not entry then
		return nil
	end

	local userId = entry.platformUserId or entry.userId or entry.playerId

	if not string.isNilOrEmpty(userId) then
		local platformEntries = PlatformFriendListService:getPlatformFriendEntries({
			mappedOnly = false
		})

		for _, platformEntry in ipairs(platformEntries) do
			local playerInfo = platformEntry and platformEntry.playerInfo

			if playerInfo and tostring(playerInfo.platformUserId or "") == tostring(userId) then
				self:cachePlatformPlayerInfo(playerInfo)

				return playerInfo
			end
		end
	end

	local socialService = M.getPlatformSocialService()

	if not socialService or not socialService:isSupported() then
		return nil
	end

	if not socialService:init() then
		return nil
	end

	local platformFriend = socialService:getFriendByUserId(userId)

	if not platformFriend then
		return nil
	end

	local playerInfo = self:convertPlatformFriendToPlayerInfo(platformFriend)

	self:cachePlatformPlayerInfo(playerInfo)

	return playerInfo
end

function M:fetchPlatformFriendList()
	local platformFriendList = PlatformFriendListService:getPlatformFriendEntries({
		mappedOnly = false
	})

	return platformFriendList
end

function M.isUnityObjectInvalid(value)
	return value == nil or type(IsNil) == "function" and IsNil(value)
end

function M:isFriendTabComponentAlive()
	if type(self) ~= "table" then
		return false
	end

	if type(self.refreshFriendList) ~= "function" then
		return false
	end

	if self.ctrl == nil or self.view == nil then
		return false
	end

	if M.isUnityObjectInvalid(self.gameObject) then
		return false
	end

	if M.isUnityObjectInvalid(self.rootUComponent) then
		return false
	end

	if M.isUnityObjectInvalid(self.friendListUComponent) then
		return false
	end

	if M.isUnityObjectInvalid(self.listFriendUList) then
		return false
	end

	return true
end

function M:initView()
	self.ugcFriendNameRequestState = self.ugcFriendNameRequestState or {}
	self.ugcFriendSignatureRequestState = self.ugcFriendSignatureRequestState or {}
	self.ugcFriendAvatarRequestState = self.ugcFriendAvatarRequestState or {}
	self.platformUidMappingCache = self.platformUidMappingCache or {}
	self.platformUidMappingPending = self.platformUidMappingPending or {}
	self.platformFriendSnapshot = self.platformFriendSnapshot or {}
	self.platformFriendSnapshotByPlatformUserId = self.platformFriendSnapshotByPlatformUserId or {}

	if self.rootUComponent then
		local desiredPlatformPage = self:getConsolePlatformType()

		self.rootUComponent:TryChangePage("PlatformType", desiredPlatformPage)
	end

	self.curPanelType = M.FriendChannelType.Friend

	self:registerPlatformCallbacks()
end

function M:addListener()
	local originalGroupRender = self.listFriendUList.luaRenderItem

	function self.listFriendUList.luaRenderItem(button, index, data)
		originalGroupRender(button, index, data)

		if data.isPlatformGroup then
			local objectReference = button:GetComponent("ObjectReference")
			local settingUButton = objectReference:GetRefValue("settingUButton")

			if settingUButton then
				settingUButton:SetActive(false)
			end
		end
	end
end

function M.resolveFriendTabName(action, uid, playerInfo, rawName)
	if M.isSelfUid(uid) then
		return nil
	end

	return PlatformNameMaskService.getMaskedDisplayName({
		action = action,
		uid = uid,
		playerInfo = playerInfo,
		rawText = rawName
	})
end

function M:renderRecommendPlayerName(button, index, data, playerInfo, rawName)
	return M.resolveFriendTabName(PlatformNameMaskService.Action.FriendRecommendName, data.playerId, playerInfo, rawName)
end

function M:renderRecommendPlayerOnlineID(objectReference, textNameUSDFText, button, index, data, playerInfo)
	local _, hasText = PlatformDisplayNameInjector.applyOnlineID({
		objectReference = objectReference,
		playerInfo = playerInfo,
		config = M.ADD_FRIEND_CONFIG
	})

	if M.ADD_FRIEND_CONFIG and M.ADD_FRIEND_CONFIG.hideGameName == true and hasText then
		ClientTextUtils.setText(textNameUSDFText, "")
	end
end

function M:renderApplyPlayerName(button, index, data, playerInfo, rawName)
	return M.resolveFriendTabName(PlatformNameMaskService.Action.FriendApplyName, data.playerId, playerInfo, rawName)
end

function M.resolvePlatformGamertag(playerInfo)
	if type(playerInfo) ~= "table" then
		return nil
	end

	local gamertag = PlatformFriendListService:resolveGamertag(playerInfo)

	if not string.isNilOrEmpty(gamertag) then
		logger:info("[platform_friend_tab] resolve gamertag for friend-tab platformUserId=%s gamertag=%s", tostring(PlatformIdentityUtils.resolvePlatformUserId(playerInfo)), tostring(gamertag))

		return gamertag
	end

	logger:info("[platform_friend_tab] gamertag unresolved platformUserId=%s, passthrough", tostring(PlatformIdentityUtils.resolvePlatformUserId(playerInfo)))

	return nil
end

function M:renderFriendItemName(button, index, data, playerInfo, rawName)
	if data and data.isPlatformFriend == true then
		local gamertag = M.resolvePlatformGamertag(playerInfo)

		if not string.isNilOrEmpty(gamertag) then
			return gamertag
		end
	end

	local displayName, isVisible, _, context = M.resolveFriendTabName(PlatformNameMaskService.Action.FriendListName, data.playerId, playerInfo, rawName)

	return displayName
end

function M:refreshFriendListOnUgcPolicyChanged(payload)
	local isAlive = M.isFriendTabComponentAlive(self)

	logger:info("[platform_friend_tab][ugc_policy_changed] received policy=%s source=%s componentAlive=%s refreshInvoked=%s", tostring(type(payload) == "table" and payload.policy or nil), tostring(type(payload) == "table" and payload.source or nil), tostring(isAlive), tostring(isAlive))

	if not isAlive then
		return
	end

	self:refreshFriendList()
end

function M:registerPlatformCallbacks()
	local platform = pg.global.platform

	if platform == nil or platform.registerPlatformCallback == nil then
		logger:info("[platform_friend_tab][ugc_policy_changed] register owner=%s eventKey=%s success=false reason=%s", tostring(M.PLATFORM_CALLBACK_OWNER), tostring(nil), "platform_callback_unavailable")

		return false
	end

	local callbackEvents = platform.PLATFORM_CALLBACK_EVENT
	local eventKey = callbackEvents and callbackEvents.UgcPolicyChanged or nil

	if type(eventKey) ~= "string" or eventKey == "" then
		logger:info("[platform_friend_tab][ugc_policy_changed] register owner=%s eventKey=%s success=false reason=%s", tostring(M.PLATFORM_CALLBACK_OWNER), tostring(eventKey), "event_key_missing")

		return false
	end

	local success = platform:registerPlatformCallback(eventKey, M.PLATFORM_CALLBACK_OWNER, function(payload)
		M.refreshFriendListOnUgcPolicyChanged(self, payload)
	end) == true

	if success then
		M._activePlatformCallbackOwner = self
	end

	logger:info("[platform_friend_tab][ugc_policy_changed] register owner=%s eventKey=%s success=%s reason=%s", tostring(M.PLATFORM_CALLBACK_OWNER), tostring(eventKey), tostring(success), success and "ok" or "register_failed")

	return success
end

function M:unregisterPlatformCallbacks()
	if M._activePlatformCallbackOwner ~= nil and M._activePlatformCallbackOwner ~= self then
		logger:info("[platform_friend_tab][ugc_policy_changed] unregister owner=%s success=false reason=%s", tostring(M.PLATFORM_CALLBACK_OWNER), "stale_owner")

		return false
	end

	local platform = pg.global.platform

	if platform == nil or platform.unregisterPlatformCallback == nil then
		logger:info("[platform_friend_tab][ugc_policy_changed] unregister owner=%s success=false reason=%s", tostring(M.PLATFORM_CALLBACK_OWNER), "platform_callback_unavailable")

		return false
	end

	local callbackEvents = platform.PLATFORM_CALLBACK_EVENT
	local eventKey = callbackEvents and callbackEvents.UgcPolicyChanged or nil

	if type(eventKey) ~= "string" or eventKey == "" then
		logger:info("[platform_friend_tab][ugc_policy_changed] unregister owner=%s eventKey=%s success=false reason=%s", tostring(M.PLATFORM_CALLBACK_OWNER), tostring(eventKey), "event_key_missing")

		return false
	end

	local success = platform:unregisterPlatformCallback(eventKey, M.PLATFORM_CALLBACK_OWNER) == true

	if success then
		M._activePlatformCallbackOwner = nil
	end

	logger:info("[platform_friend_tab][ugc_policy_changed] unregister owner=%s eventKey=%s success=%s reason=%s", tostring(M.PLATFORM_CALLBACK_OWNER), tostring(eventKey), tostring(success), success and "ok" or "unregister_failed")

	return success
end

function M:onDestroy()
	M.unregisterPlatformCallbacks(self)
end

function M.beforeRenderFriendItem(data)
	if data.playerInfo and not string.isNilOrEmpty(data.playerId) and pg.game.chat then
		pg.game.chat:setPlayerData(data.playerId, data.playerInfo)
	end
end

function M:afterAssignFriendItemClick(button, data, playerInfo)
	local shouldBlockConversation = playerInfo ~= nil and playerInfo.isPlatformFriend == true and playerInfo.hasMappedGameUid ~= true

	if shouldBlockConversation then
		function button.luaClick()
			return
		end
	end
end

function M:afterAssignFriendAvatarClick(avatarUButton, playerInfo)
	if playerInfo and playerInfo.isPlatformFriend == true then
		if playerInfo.hasMappedGameUid == true then
			return
		end

		if avatarUButton then
			function avatarUButton.luaClick()
				local platformUserId = not string.isNilOrEmpty(playerInfo.platformUserId) and tostring(playerInfo.platformUserId) or ""
				local platformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade

				if not string.isNilOrEmpty(platformUserId) and platformBridgeLuaFacade.SupportsShowPlayerProfileCard() then
					platformBridgeLuaFacade.ShowPlayerProfileCard(platformUserId)

					return
				end
			end
		end
	end
end

function M:afterRenderFriendBlacklistButton(blacklistUButton, button, data, playerInfo)
	if blacklistUButton then
		blacklistUButton:SetActive(data.isBlackList == true)
	end
end

function M:injectFriendGroupList(friendGroupList)
	if friendGroupList == nil then
		return
	end

	for index = #friendGroupList, 1, -1 do
		if friendGroupList[index].id == M.PLATFORM_FRIENDS_GROUP_ID then
			table.remove(friendGroupList, index)
		end
	end

	local platformFriends = self:fetchPlatformFriendList()

	if #platformFriends > 0 then
		local platformSubCount = 0

		for _, friend in ipairs(platformFriends) do
			if friend.playerInfo and friend.playerInfo.online then
				platformSubCount = platformSubCount + 1
			end
		end

		local consolePlatformType = self:getConsolePlatformType()
		local platformGroupLabel

		platformGroupLabel = consolePlatformType == M.ConsolePlatformType.Xbox and "XBOX_FRIEND" or consolePlatformType == M.ConsolePlatformType.PlayStation and "PS_FRIEND" or "XBOX_FRIEND"

		table.insert(friendGroupList, 1, {
			isPlatformGroup = true,
			expand = true,
			id = M.PLATFORM_FRIENDS_GROUP_ID,
			groupLabel = platformGroupLabel,
			groupFriendData = platformFriends,
			subCount = platformSubCount
		})
	end

	local chat = pg and pg.game and pg.game.chat or nil

	if chat ~= nil and chat.friendGroupList == friendGroupList then
		chat.friendGroupId2Index = {}

		for groupIdx, group in ipairs(friendGroupList) do
			if group and group.id ~= nil then
				chat.friendGroupId2Index[tostring(group.id)] = groupIdx
			end
		end
	end
end

function M.setPlayerBaseInfoSign(playerInfo, rawSign)
	return PlatformNameMaskService:getVisibleProfileSignature(playerInfo and (playerInfo.uid or playerInfo.playerId), playerInfo, rawSign)
end

function M.renderChatGroupName(data, rawName)
	if pg and pg.game and pg.game.chat and pg.game.chat.getChatGroupDisplayName then
		return pg.game.chat:getChatGroupDisplayName(data, rawName)
	end

	return rawName
end

return M
