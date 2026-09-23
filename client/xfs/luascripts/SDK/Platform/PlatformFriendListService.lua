-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformFriendListService.lua

local Time = require("Core.Common.Time")
local MessageName = require("Const.MessageName")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformSocialService = require("SDK.Platform.PlatformSocialService")
local logger = require("SDK.Platform.PlatformLogger")
local PlatformFriendListService = {}

PlatformFriendListService.DEFAULT_PLATFORM_FAMILY = "unknown"
PlatformFriendListService.DEFAULT_AVATAR_PRESET_KEY = 110001
PlatformFriendListService.PLATFORM_UID_MAPPING_RETRY_INTERVAL = 30
PlatformFriendListService.PLATFORM_UID_MAPPING_MAX_CACHE_SECONDS = 14400
PlatformFriendListService.state = {
	buildDepth = 0,
	subscribed = false,
	uidMappingCache = {},
	uidMappingPending = {},
	uidMappingLogAt = {}
}

function PlatformFriendListService.getNow()
	return Time and Time.secondCache or os.time()
end

function PlatformFriendListService.normalizePlatformFamily(platformFamily)
	platformFamily = tostring(platformFamily or "")

	if string.isNilOrEmpty(platformFamily) then
		return PlatformFriendListService.DEFAULT_PLATFORM_FAMILY
	end

	return platformFamily
end

function PlatformFriendListService.trimPlatformText(value)
	if value == nil then
		return ""
	end

	return tostring(value):match("^%s*(.-)%s*$")
end

function PlatformFriendListService.getPlatformUidMappingCacheKey(platformFamily, platformUserId)
	return PlatformFriendListService.normalizePlatformFamily(platformFamily) .. ":" .. tostring(platformUserId or "")
end

function PlatformFriendListService._logUidMapping(source, platformFamily, platformUserId, gameUid, hasMappedGameUid, cacheKey)
	cacheKey = cacheKey or PlatformFriendListService.getPlatformUidMappingCacheKey(platformFamily, platformUserId)

	local now = PlatformFriendListService.getNow()

	if PlatformFriendListService.state.uidMappingLogAt[cacheKey] and now < PlatformFriendListService.state.uidMappingLogAt[cacheKey] + 60 then
		return
	end

	PlatformFriendListService.state.uidMappingLogAt[cacheKey] = now

	logger:info("[platform_friend_mapping] source=%s platformFamily=%s platformUserId=%s gameUid=%s hasMappedGameUid=%s", tostring(source or ""), tostring(platformFamily or ""), tostring(platformUserId or ""), tostring(gameUid or ""), tostring(hasMappedGameUid == true))
end

function PlatformFriendListService.isSelfUid(uid)
	return not string.isNilOrEmpty(uid) and pg and pg.me and tostring(uid) == tostring(pg.me.uid)
end

function PlatformFriendListService.copyTable(source)
	local target = {}

	if type(source) ~= "table" then
		return target
	end

	for key, value in pairs(source) do
		if value ~= nil then
			target[key] = value
		end
	end

	return target
end

function PlatformFriendListService.getFriendEntryGameUid(entry)
	if type(entry) ~= "table" then
		return ""
	end

	return tostring(entry.playerId or entry.uid or entry.userId or "")
end

function PlatformFriendListService.mergePlatformFriendInfo(gameEntry, platformEntry)
	if type(gameEntry) ~= "table" or type(platformEntry) ~= "table" then
		return
	end

	local platformInfo = platformEntry.playerInfo

	if type(platformInfo) ~= "table" then
		return
	end

	gameEntry.isPlatformFriend = true
	gameEntry.hasMappedGameUid = platformInfo.hasMappedGameUid == true
	gameEntry.mappedGameUid = platformInfo.mappedGameUid
	gameEntry.platformUserId = platformInfo.platformUserId
	gameEntry.platformFamily = platformInfo.platformFamily
	gameEntry.platform = platformInfo.platform
	gameEntry.os = platformInfo.os

	local playerInfo = gameEntry.playerInfo

	if type(playerInfo) ~= "table" then
		gameEntry.playerInfo = platformInfo

		return
	end

	playerInfo.isPlatformFriend = true
	playerInfo.hasMappedGameUid = platformInfo.hasMappedGameUid == true
	playerInfo.mappedGameUid = platformInfo.mappedGameUid
	playerInfo.platformUserId = platformInfo.platformUserId
	playerInfo.platformFamily = platformInfo.platformFamily
	playerInfo.platform = platformInfo.platform
	playerInfo.os = platformInfo.os
	playerInfo.platformInfoCachedAt = platformInfo.platformInfoCachedAt
end

function PlatformFriendListService.getPlatformFriendFallbackName(friend)
	local platformFamily = PlatformFriendListService.normalizePlatformFamily(friend and friend.platformFamily)
	local key

	if platformFamily == PlatformIdentityUtils.Family.PlayStation then
		key = "PS_FRIEND"
	elseif platformFamily == PlatformIdentityUtils.Family.Xbox then
		key = "XBOX_FRIEND"
	end

	if pg and pg.getGameString then
		local text = key and pg.getGameString(key) or ""

		if not string.isNilOrEmpty(text) and text ~= key then
			return text
		end
	end

	return "Platform Friend"
end

function PlatformFriendListService.buildPlatformPlayerName(friend)
	if friend == nil then
		return ""
	end

	local displayName = PlatformFriendListService.trimPlatformText(friend.displayName)

	if not string.isNilOrEmpty(displayName) then
		return displayName
	end

	return PlatformFriendListService.getPlatformFriendFallbackName(friend)
end

function PlatformFriendListService.emitFriendListRefresh()
	if facade and facade.SendMessageCommand then
		facade:SendMessageCommand(MessageName.RECV_FRIEND_LIST)
		facade:SendMessageCommand(MessageName.CHANNEL_LIST_UPDATE)
		facade:SendMessageCommand(MessageName.CHAT_MESSAGE_UPDATE, {})
		facade:SendMessageCommand(MessageName.FRIEND_CHAT_GROUP_UPDATE)
	end
end

function PlatformFriendListService.getPlatformUidMappingEntry(platformUserId, platformFamily)
	platformUserId = platformUserId and tostring(platformUserId) or ""
	platformFamily = PlatformFriendListService.normalizePlatformFamily(platformFamily)

	if string.isNilOrEmpty(platformUserId) then
		return nil
	end

	local cacheKey = PlatformFriendListService.getPlatformUidMappingCacheKey(platformFamily, platformUserId)
	local cacheEntry = PlatformFriendListService.state.uidMappingCache[cacheKey]

	if cacheEntry and cacheEntry.updatedAt and cacheEntry.updatedAt + PlatformFriendListService.PLATFORM_UID_MAPPING_MAX_CACHE_SECONDS <= PlatformFriendListService.getNow() then
		PlatformFriendListService.state.uidMappingCache[cacheKey] = nil

		return nil
	end

	return cacheEntry
end

function PlatformFriendListService.getMappedGameUid(platformUserId, platformFamily)
	local cacheEntry = PlatformFriendListService.getPlatformUidMappingEntry(platformUserId, platformFamily)

	if cacheEntry and cacheEntry.hasMappedGameUid == true and not string.isNilOrEmpty(cacheEntry.gameUid) then
		PlatformFriendListService._logUidMapping("cache_hit", cacheEntry.platformFamily, cacheEntry.platformUserId, cacheEntry.gameUid, cacheEntry.hasMappedGameUid)

		return cacheEntry.gameUid, true
	end

	return nil, false
end

function PlatformFriendListService.shouldQueryPlatformUidMapping(platformUserId, platformFamily)
	platformUserId = platformUserId and tostring(platformUserId) or ""
	platformFamily = PlatformFriendListService.normalizePlatformFamily(platformFamily)

	if string.isNilOrEmpty(platformUserId) then
		return false
	end

	local cacheKey = PlatformFriendListService.getPlatformUidMappingCacheKey(platformFamily, platformUserId)

	if PlatformFriendListService.state.uidMappingPending[cacheKey] then
		return false
	end

	local cacheEntry = PlatformFriendListService.getPlatformUidMappingEntry(platformUserId, platformFamily)

	if cacheEntry == nil then
		return true
	end

	if cacheEntry.hasMappedGameUid == true then
		return false
	end

	return (cacheEntry.updatedAt or 0) + PlatformFriendListService.PLATFORM_UID_MAPPING_RETRY_INTERVAL <= PlatformFriendListService.getNow()
end

function PlatformFriendListService.cachePlatformPlayerInfo(playerInfo)
	if type(playerInfo) ~= "table" or string.isNilOrEmpty(playerInfo.uid) then
		return playerInfo
	end

	if pg and pg.game and pg.game.chat and pg.game.chat.setPlayerData then
		return pg.game.chat:setPlayerData(playerInfo.uid, playerInfo)
	end

	return playerInfo
end

function PlatformFriendListService.getCachedGamePlayerInfo(gameUid)
	if string.isNilOrEmpty(gameUid) or not pg or not pg.game or not pg.game.chat or not pg.game.chat.getPlayerInfo then
		return nil
	end

	return pg.game.chat:getPlayerInfo(gameUid)
end

function PlatformFriendListService.resolveGameOnline(gameUid, playerInfo)
	if string.isNilOrEmpty(gameUid) then
		return false
	end

	if type(playerInfo) == "table" and playerInfo.online ~= nil then
		return playerInfo.online == true
	end

	local cachedPlayerInfo = PlatformFriendListService.getCachedGamePlayerInfo(gameUid)

	return type(cachedPlayerInfo) == "table" and cachedPlayerInfo.online == true
end

function PlatformFriendListService.syncFriendGameOnline(friend, gameUid, playerInfo)
	if type(friend) ~= "table" then
		return false
	end

	local online = PlatformFriendListService.resolveGameOnline(gameUid, playerInfo)

	friend.isOnline = online

	return online
end

function PlatformFriendListService.isMappedPlayerInfoCurrent(friend, gameUid, cachedPlayerInfo)
	if type(friend) ~= "table" or type(cachedPlayerInfo) ~= "table" then
		return false
	end

	local platformUserId = tostring(friend.platformUserId or friend.userId or "")
	local platformFamily = PlatformFriendListService.normalizePlatformFamily(friend.platformFamily)
	local avatarUrl = friend.avatarUrl or cachedPlayerInfo.avatarUrl or ""
	local platform = friend.platform or cachedPlayerInfo.platform or ""
	local os = friend.os or friend.platform or cachedPlayerInfo.os or ""

	return cachedPlayerInfo.playerId == gameUid and cachedPlayerInfo.uid == gameUid and cachedPlayerInfo.online == (friend.isOnline == true) and cachedPlayerInfo.loginTime ~= nil and cachedPlayerInfo.loginTime ~= false and cachedPlayerInfo.lastLogoutTime ~= nil and cachedPlayerInfo.lastLogoutTime ~= false and cachedPlayerInfo.avatarUrl == avatarUrl and cachedPlayerInfo.platformUserId == platformUserId and cachedPlayerInfo.platformFamily == platformFamily and cachedPlayerInfo.platform == platform and cachedPlayerInfo.os == os and cachedPlayerInfo.isPlatformFriend == true and cachedPlayerInfo.mappedGameUid == gameUid and cachedPlayerInfo.hasMappedGameUid == true and cachedPlayerInfo.headIcon ~= nil and cachedPlayerInfo.headIcon ~= false and cachedPlayerInfo.avatarPresetKey ~= nil and cachedPlayerInfo.avatarPresetKey ~= false and cachedPlayerInfo.level ~= nil and cachedPlayerInfo.level ~= false and cachedPlayerInfo.platformInfoCachedAt ~= nil and cachedPlayerInfo.platformInfoCachedAt ~= false
end

function PlatformFriendListService.enrichMappedPlayerInfo(friend, gameUid, sourcePlayerInfo)
	if string.isNilOrEmpty(gameUid) then
		return nil
	end

	local platformUserId = tostring(friend.platformUserId or friend.userId or "")
	local platformFamily = PlatformFriendListService.normalizePlatformFamily(friend.platformFamily)
	local cachedPlayerInfo = PlatformFriendListService.getCachedGamePlayerInfo(gameUid)

	if sourcePlayerInfo == nil and PlatformFriendListService.isMappedPlayerInfoCurrent(friend, gameUid, cachedPlayerInfo) then
		return cachedPlayerInfo
	end

	local playerInfo = PlatformFriendListService.copyTable(cachedPlayerInfo)

	for key, value in pairs(PlatformFriendListService.copyTable(sourcePlayerInfo)) do
		playerInfo[key] = value
	end

	playerInfo.playerId = gameUid
	playerInfo.uid = gameUid
	playerInfo.online = friend.isOnline == true
	playerInfo.loginTime = playerInfo.loginTime or PlatformFriendListService.getNow()
	playerInfo.lastLogoutTime = playerInfo.lastLogoutTime or PlatformFriendListService.getNow()
	playerInfo.avatarUrl = friend.avatarUrl or playerInfo.avatarUrl or ""
	playerInfo.platformUserId = platformUserId
	playerInfo.platformFamily = platformFamily
	playerInfo.platform = friend.platform or playerInfo.platform or ""
	playerInfo.os = friend.os or friend.platform or playerInfo.os or ""
	playerInfo.isPlatformFriend = true
	playerInfo.mappedGameUid = gameUid
	playerInfo.hasMappedGameUid = true
	playerInfo.headIcon = playerInfo.headIcon or 1
	playerInfo.avatarPresetKey = playerInfo.avatarPresetKey or PlatformFriendListService.DEFAULT_AVATAR_PRESET_KEY
	playerInfo.level = playerInfo.level or "-"
	playerInfo.platformInfoCachedAt = PlatformFriendListService.getNow()

	logger:info("[platform_friend_enrich] write markers only(no gamertag) gameUid=%s platformFamily=%s platformUserId=%s isGameFriend=%s", tostring(gameUid), tostring(platformFamily), tostring(platformUserId), tostring(PlatformFriendListService.isGameFriendUid(pg and pg.game and pg.game.chat, gameUid)))

	return PlatformFriendListService.cachePlatformPlayerInfo(playerInfo)
end

function PlatformFriendListService.setPlatformUidMappingCacheEntry(friend, gameUid, playerInfo)
	local platformUserId = friend and tostring(friend.platformUserId or friend.userId or "") or ""
	local platformFamily = PlatformFriendListService.normalizePlatformFamily(friend and friend.platformFamily)

	if string.isNilOrEmpty(platformUserId) then
		return
	end

	gameUid = gameUid and tostring(gameUid) or ""

	local enrichedPlayerInfo
	local hasMappedGameUid = not string.isNilOrEmpty(gameUid)

	PlatformFriendListService.syncFriendGameOnline(friend, gameUid, playerInfo)

	if hasMappedGameUid then
		enrichedPlayerInfo = PlatformFriendListService.enrichMappedPlayerInfo(friend, gameUid, playerInfo)
	end

	PlatformFriendListService.state.uidMappingCache[PlatformFriendListService.getPlatformUidMappingCacheKey(platformFamily, platformUserId)] = {
		platformUserId = platformUserId,
		platformFamily = platformFamily,
		gameUid = gameUid,
		hasMappedGameUid = hasMappedGameUid,
		updatedAt = PlatformFriendListService.getNow()
	}

	PlatformFriendListService._logUidMapping("refresh_result", platformFamily, platformUserId, gameUid, hasMappedGameUid)

	return enrichedPlayerInfo
end

function PlatformFriendListService.queryPlatformUidMapping(friend)
	if not pg or not pg.me or not pg.me.queryPlayerInfoByPlatformUserId then
		return false
	end

	local platformUserId = tostring(friend.platformUserId or friend.userId or "")

	if string.isNilOrEmpty(platformUserId) then
		return false
	end

	local platformFamily = PlatformFriendListService.normalizePlatformFamily(friend.platformFamily)
	local cacheKey = PlatformFriendListService.getPlatformUidMappingCacheKey(platformFamily, platformUserId)

	PlatformFriendListService.state.uidMappingPending[cacheKey] = true

	PlatformFriendListService._logUidMapping("refresh_request", platformFamily, platformUserId, "", false, cacheKey)
	pg.me:queryPlayerInfoByPlatformUserId(platformUserId, pg.game.chat.queryPlayerInfoType.FriendList, true, function(playerInfo)
		PlatformFriendListService.state.uidMappingPending[cacheKey] = nil

		local gameUid = playerInfo and playerInfo.uid or ""

		PlatformFriendListService.setPlatformUidMappingCacheEntry(friend, gameUid, playerInfo)

		if not string.isNilOrEmpty(gameUid) then
			PlatformFriendListService.emitFriendListRefresh()
		end
	end)

	return true
end

function PlatformFriendListService.refreshPlatformUidMappingAsync(friends)
	if type(friends) ~= "table" then
		return
	end

	for _, friend in ipairs(friends) do
		local platformUserId = tostring(friend.platformUserId or friend.userId or "")
		local platformFamily = PlatformFriendListService.normalizePlatformFamily(friend.platformFamily)

		if PlatformFriendListService.shouldQueryPlatformUidMapping(platformUserId, platformFamily) then
			PlatformFriendListService.queryPlatformUidMapping(friend)
		end
	end
end

function PlatformFriendListService.buildPlatformFriendEntryInternal(friend, mappedOnly)
	if type(friend) ~= "table" then
		return nil
	end

	local platformUserId = tostring(friend.platformUserId or friend.userId or "")

	if string.isNilOrEmpty(platformUserId) then
		return nil
	end

	local platformFamily = PlatformFriendListService.normalizePlatformFamily(friend.platformFamily)
	local mappedGameUid, hasMappedGameUid = PlatformFriendListService.getMappedGameUid(platformUserId, platformFamily)

	if mappedOnly and not hasMappedGameUid then
		return nil
	end

	local playerId = hasMappedGameUid and mappedGameUid or platformUserId

	if PlatformFriendListService.isSelfUid(playerId) then
		return nil
	end

	local playerInfo

	if hasMappedGameUid then
		PlatformFriendListService.syncFriendGameOnline(friend, mappedGameUid)

		playerInfo = PlatformFriendListService.enrichMappedPlayerInfo(friend, mappedGameUid)
	else
		local offlineTime = PlatformFriendListService.getNow()

		friend.isOnline = false
		playerInfo = {
			level = "-",
			headIcon = 1,
			isPlatformFriend = true,
			hasMappedGameUid = false,
			playerId = playerId,
			uid = playerId,
			playerName = PlatformFriendListService.buildPlatformPlayerName(friend),
			platformDisplayName = PlatformFriendListService.buildPlatformPlayerName(friend),
			online = friend.isOnline == true,
			loginTime = offlineTime,
			lastLogoutTime = offlineTime,
			platformUserId = platformUserId,
			platformFamily = platformFamily,
			platform = friend.platform or "",
			os = friend.os or friend.platform or "",
			avatarPresetKey = PlatformFriendListService.DEFAULT_AVATAR_PRESET_KEY,
			platformInfoCachedAt = PlatformFriendListService.getNow()
		}
	end

	if not playerInfo then
		return nil
	end

	return {
		type = 0,
		tIndex = 0,
		isPlatformFriend = true,
		playerId = playerId,
		uid = playerId,
		userId = playerId,
		status = playerInfo.online and 0 or 1,
		loginTime = playerInfo.loginTime,
		lastLogoutTime = playerInfo.lastLogoutTime,
		level = playerInfo.level,
		platformUserId = playerInfo.platformUserId,
		platformFamily = playerInfo.platformFamily,
		mappedGameUid = playerInfo.mappedGameUid,
		hasMappedGameUid = playerInfo.hasMappedGameUid == true,
		playerInfo = playerInfo
	}
end

function PlatformFriendListService.resolveGamertagInternal(playerInfo)
	if type(playerInfo) ~= "table" then
		return nil
	end

	local platformUserId = PlatformFriendListService.trimPlatformText(PlatformIdentityUtils.resolvePlatformUserId(playerInfo))

	if not string.isNilOrEmpty(platformUserId) and PlatformSocialService.getFriendByUserId then
		local friend = PlatformSocialService:getFriendByUserId(platformUserId)

		if type(friend) == "table" then
			local liveName = PlatformFriendListService.buildPlatformPlayerName(friend)

			if not string.isNilOrEmpty(liveName) then
				logger:info("[platform_friend_display] gamertag from live snapshot platformUserId=%s gamertag=%s", tostring(platformUserId), tostring(liveName))

				return liveName
			end
		else
			logger:info("[platform_friend_display] live snapshot miss platformUserId=%s, fallback to cached/identity", tostring(platformUserId))
		end
	end

	local gamertag = PlatformFriendListService.trimPlatformText(playerInfo.platformDisplayName)

	if not string.isNilOrEmpty(gamertag) then
		logger:info("[platform_friend_display] gamertag from playerInfo.platformDisplayName platformUserId=%s gamertag=%s", tostring(platformUserId), tostring(gamertag))

		return gamertag
	end

	local identity = PlatformIdentityUtils.resolvePlayerIdentity(playerInfo) or {}

	gamertag = PlatformFriendListService.trimPlatformText(identity.platformDisplayName)

	if not string.isNilOrEmpty(gamertag) then
		logger:info("[platform_friend_display] gamertag from identity resolve platformUserId=%s gamertag=%s", tostring(platformUserId), tostring(gamertag))

		return gamertag
	end

	logger:warn("[platform_friend_display] gamertag unresolved platformUserId=%s, passthrough game name", tostring(platformUserId))

	return nil
end

function PlatformFriendListService.isGameFriendUid(chatSystem, playerId)
	if string.isNilOrEmpty(playerId) or type(chatSystem) ~= "table" then
		return false
	end

	if type(chatSystem.checkFriendList) == "function" and chatSystem:checkFriendList(playerId) == true then
		return true
	end

	if type(chatSystem.getFriendIdList) == "function" then
		local target = tostring(playerId)
		local friendIds = chatSystem:getFriendIdList()

		if type(friendIds) == "table" then
			for _, friendId in ipairs(friendIds) do
				if tostring(friendId) == target then
					return true
				end
			end
		end
	end

	return false
end

function PlatformFriendListService.shouldAllowPurePlatformId(platformFamily, options)
	if platformFamily ~= PlatformIdentityUtils.Family.PlayStation then
		return true
	end

	return type(options) == "table" and options.allowPurePlatformId == true
end

function PlatformFriendListService.isPureConsolePlatformFriend(chatSystem, playerId, playerInfo, options)
	if type(playerInfo) ~= "table" or playerInfo.isPlatformFriend ~= true then
		return false
	end

	local platformFamily = PlatformIdentityUtils.normalizeFamily(playerInfo.platformFamily)

	if platformFamily ~= PlatformIdentityUtils.Family.Xbox and platformFamily ~= PlatformIdentityUtils.Family.PlayStation then
		return false
	end

	if not PlatformFriendListService.shouldAllowPurePlatformId(platformFamily, options) then
		logger:info("[platform_friend_display] skip pure platform id playerId=%s family=%s reason=missing_allow_tag", tostring(playerId), tostring(platformFamily))

		return false
	end

	if string.isNilOrEmpty(playerId) or type(chatSystem) ~= "table" or type(chatSystem.checkFriendList) ~= "function" then
		return false
	end

	local isGameFriend = PlatformFriendListService.isGameFriendUid(chatSystem, playerId)

	logger:info("[platform_friend_display] classify playerId=%s family=%s isPlatformFriend=true isGameFriend=%s => pureConsole=%s", tostring(playerId), tostring(platformFamily), tostring(isGameFriend), tostring(not isGameFriend))

	return not isGameFriend
end

function PlatformFriendListService:resolveDisplayPlayerInfo(chatSystem, playerId, playerInfo, options)
	if not PlatformFriendListService.isPureConsolePlatformFriend(chatSystem, playerId, playerInfo, options) then
		return playerInfo
	end

	local gamertag = PlatformFriendListService.resolveGamertagInternal(playerInfo)

	if string.isNilOrEmpty(gamertag) then
		logger:info("[platform_friend_display] pure platform id playerId=%s unresolved, passthrough game name=%s", tostring(playerId), tostring(playerInfo.playerName))

		return playerInfo
	end

	local displayInfo = PlatformFriendListService.copyTable(playerInfo)

	displayInfo.playerName = gamertag

	logger:info("[platform_friend_display] pure platform id playerId=%s override playerName: %s => %s", tostring(playerId), tostring(playerInfo.playerName), tostring(gamertag))

	return displayInfo
end

function PlatformFriendListService:resolveGamertag(playerInfo)
	return PlatformFriendListService.resolveGamertagInternal(playerInfo)
end

function PlatformFriendListService:ensureSubscribed()
	if not PlatformSocialService or not PlatformSocialService.isSupported or not PlatformSocialService:isSupported() then
		return false
	end

	if not PlatformSocialService.init or not PlatformSocialService:init() then
		return false
	end

	if not PlatformFriendListService.state.subscribed then
		if PlatformSocialService.refreshPlatformFriendCache then
			PlatformSocialService:refreshPlatformFriendCache()
		end

		if PlatformSocialService.onFriendsUpdated then
			PlatformFriendListService.state.friendsUpdatedSubscription = PlatformSocialService:onFriendsUpdated(function(friends)
				PlatformFriendListService.refreshPlatformUidMappingAsync(friends or {})
				PlatformFriendListService.emitFriendListRefresh()
			end)
		end

		PlatformFriendListService.state.subscribed = true
	end

	return true
end

function PlatformFriendListService:buildPlatformFriendEntry(friend, options)
	options = options or {}

	return PlatformFriendListService.buildPlatformFriendEntryInternal(friend, options.mappedOnly == true)
end

function PlatformFriendListService:getPlatformFriendEntries(options)
	options = options or {}

	if not self:ensureSubscribed() then
		return {}
	end

	local friends = PlatformSocialService:getFriends() or {}

	PlatformFriendListService.state.buildDepth = PlatformFriendListService.state.buildDepth + 1

	PlatformFriendListService.refreshPlatformUidMappingAsync(friends)

	local entries = {}
	local dedupe = {}

	for _, friend in ipairs(friends) do
		local entry = self:buildPlatformFriendEntry(friend, options)
		local playerId = entry and entry.playerId and tostring(entry.playerId) or ""

		if entry and not dedupe[playerId] then
			dedupe[playerId] = true

			table.insert(entries, entry)
		end
	end

	PlatformFriendListService.state.buildDepth = PlatformFriendListService.state.buildDepth - 1

	return entries
end

function PlatformFriendListService:getMergedFriendList(baseList)
	baseList = baseList or {}

	local merged = {}
	local existingGameUid = {}

	for _, item in ipairs(baseList) do
		table.insert(merged, item)

		local playerId = PlatformFriendListService.getFriendEntryGameUid(item)

		if not string.isNilOrEmpty(playerId) then
			existingGameUid[playerId] = item
		end
	end

	local platformEntries = self:getPlatformFriendEntries({
		mappedOnly = true
	})

	for _, entry in ipairs(platformEntries) do
		local playerId = PlatformFriendListService.getFriendEntryGameUid(entry)
		local hasMappedGameUid = entry and entry.playerInfo and entry.playerInfo.hasMappedGameUid == true

		if not string.isNilOrEmpty(playerId) and hasMappedGameUid and not PlatformFriendListService.isSelfUid(playerId) then
			if existingGameUid[playerId] then
				PlatformFriendListService.mergePlatformFriendInfo(existingGameUid[playerId], entry)
			else
				existingGameUid[playerId] = entry
				entry.playerId = playerId
				entry.uid = playerId
				entry.userId = playerId

				table.insert(merged, entry)
			end
		end
	end

	return merged
end

function PlatformFriendListService:_resetForTests()
	PlatformFriendListService.state.subscribed = false
	PlatformFriendListService.state.friendsUpdatedSubscription = nil
	PlatformFriendListService.state.uidMappingCache = {}
	PlatformFriendListService.state.uidMappingPending = {}
	PlatformFriendListService.state.buildDepth = 0
end

return PlatformFriendListService
