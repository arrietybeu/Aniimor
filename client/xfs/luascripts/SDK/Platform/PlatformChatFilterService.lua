-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformChatFilterService.lua

local PlatformCommunicationService = require("SDK.Platform.PlatformCommunicationService")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformSocialService = require("SDK.Platform.PlatformSocialService")
local logger = require("SDK.Platform.PlatformLogger")
local TimerManager = require("Core.Timer.TimerManager")
local PlatformChatFilterService = {}

PlatformChatFilterService.Decision = {
	Pending = "pending",
	Block = "block",
	Unknown = "unknown",
	Allow = "allow"
}
PlatformChatFilterService.REASON_PLATFORM_BLOCK_LIST = "platform_block_list"
PlatformChatFilterService.REASON_PLATFORM_BLOCK_LIST_PENDING = "platform_block_list_pending"
PlatformChatFilterService.REASON_PLATFORM_BLOCK_LIST_UNAVAILABLE = "platform_block_list_unavailable"
PlatformChatFilterService.REASON_PLATFORM_BLOCK_LIST_ERROR = "platform_block_list_error"
PlatformChatFilterService.REASON_PLATFORM_BLOCKED_BY_SENDER = "platform_blocked_by_sender"
PlatformChatFilterService.REASON_PLATFORM_BLOCKED_BY_SENDER_PENDING = "platform_blocked_by_sender_pending"
PlatformChatFilterService.REASON_PLATFORM_BLOCKED_BY_SENDER_UNAVAILABLE = "platform_blocked_by_sender_unavailable"
PlatformChatFilterService.REASON_NO_PLAYER_INFO = "no_player_info"
PlatformChatFilterService.REASON_LOCAL_COMMUNICATION_BLOCKED = "local_communication_blocked"
PlatformChatFilterService.REASON_LOCAL_COMMUNICATION_FRIENDS_ONLY = "local_communication_friends_only"
PlatformChatFilterService.REASON_LOCAL_COMMUNICATION_FRIENDS_ONLY_PUBLIC = "local_communication_friends_only_public_channel"
PlatformChatFilterService.REASON_LOCAL_COMMUNICATION_UNKNOWN = "local_communication_unknown"
PlatformChatFilterService.REASON_LOCAL_COMMUNICATION_POLICY_UNAVAILABLE = "local_communication_policy_unavailable"
PlatformChatFilterService.REASON_TARGET_COMMUNICATION_BLOCKED = "target_communication_blocked"
PlatformChatFilterService.REASON_TARGET_COMMUNICATION_PENDING = "target_communication_pending"
PlatformChatFilterService.state = {
	targetPermissionCache = {},
	targetPermissionRequests = {}
}
PlatformChatFilterService.VOICE_PERMISSION_TIMEOUT = 10
PlatformChatFilterService.DEFAULT_PENDING_RECHECK_INTERVAL = 0.5
PlatformChatFilterService.DEFAULT_PENDING_RECHECK_ATTEMPTS = 10
PlatformChatFilterService.PSN_BLOCK_RELATION_CACHE_TTL = 15

function PlatformChatFilterService.makeContext(decision, reason, extra)
	local context = {
		decision = decision,
		reason = reason
	}

	if type(extra) == "table" then
		for k, v in pairs(extra) do
			context[k] = v
		end
	end

	return context
end

function PlatformChatFilterService.getTimer()
	return pg and pg.global and type(pg.global.timer) == "table" and type(pg.global.timer.delayCall) == "function" and pg.global.timer or nil
end

function PlatformChatFilterService.peekPlatformBlocked(playerInfo)
	if type(playerInfo) ~= "table" then
		return false, PlatformChatFilterService.REASON_NO_PLAYER_INFO
	end

	if type(PlatformSocialService.peekPlatformUserBlockedByLocalUser) ~= "function" then
		return false, PlatformChatFilterService.REASON_PLATFORM_BLOCK_LIST_UNAVAILABLE
	end

	local ok, blocked = pcall(function()
		return PlatformSocialService:peekPlatformUserBlockedByLocalUser(playerInfo)
	end)

	if not ok then
		logger:warn("chat_filter_platform_block_check_failed err=%s", tostring(blocked))

		return false, PlatformChatFilterService.REASON_PLATFORM_BLOCK_LIST_ERROR, blocked
	end

	return blocked, nil
end

function PlatformChatFilterService.getChat()
	return pg and pg.game and pg.game.chat or nil
end

function PlatformChatFilterService.getMessagePermissionChannel(messageData)
	local chat = PlatformChatFilterService.getChat()

	if chat and messageData and messageData.subType == chat.subMessageType.Audio then
		return PlatformCommunicationService.Channel.Voice
	end

	return PlatformCommunicationService.Channel.Text
end

function PlatformChatFilterService.isXboxTargetCommunication(playerInfo)
	if PlatformIdentityUtils.getCurrentPlatformFamily() ~= PlatformIdentityUtils.Family.Xbox then
		return false
	end

	return PlatformIdentityUtils.resolvePlayerInfoFamily(playerInfo) == PlatformIdentityUtils.Family.Xbox
end

local function permissionOwnerUid()
	return pg and pg.me and tostring(pg.me.uid) or ""
end

local function subscribeTargetRequest(request, callback)
	if not request or type(callback) ~= "function" then
		return
	end

	for _, existing in ipairs(request.callbacks) do
		if existing == callback then
			return
		end
	end

	table.insert(request.callbacks, callback)
end

function PlatformChatFilterService.getXboxTargetDecision(channel, playerInfo, onResolved)
	if PlatformChatFilterService.state.permissionOwnerUid ~= permissionOwnerUid() then
		PlatformChatFilterService.clearTargetPermissionCache()
	end

	if not PlatformChatFilterService.isXboxTargetCommunication(playerInfo) then
		return PlatformChatFilterService.Decision.Unknown
	end

	local targetUserId = tostring(PlatformIdentityUtils.resolvePlatformUserId(playerInfo) or "")

	if string.isNilOrEmpty(targetUserId) then
		return PlatformChatFilterService.Decision.Unknown
	end

	local permissionName = channel == PlatformCommunicationService.Channel.Voice and PlatformCommunicationService.PermissionName.Voice or PlatformCommunicationService.PermissionName.Text
	local cacheKey = permissionName .. ":" .. targetUserId
	local cachedDecision = PlatformChatFilterService.state.targetPermissionCache[cacheKey]

	if cachedDecision ~= nil then
		if cachedDecision == PlatformChatFilterService.Decision.Pending then
			subscribeTargetRequest(PlatformChatFilterService.state.targetPermissionRequests[cacheKey], onResolved)
		end

		return cachedDecision
	end

	local cache = PlatformChatFilterService.state.targetPermissionCache
	local request = {
		callbacks = {},
		ownerUid = permissionOwnerUid()
	}

	subscribeTargetRequest(request, onResolved)

	PlatformChatFilterService.state.targetPermissionRequests[cacheKey] = request
	cache[cacheKey] = PlatformChatFilterService.Decision.Pending

	local function isCurrentRequest()
		return PlatformChatFilterService.state.targetPermissionCache == cache and PlatformChatFilterService.state.targetPermissionRequests[cacheKey] == request and not request.completed and permissionOwnerUid() == request.ownerUid
	end

	local function complete(allowed, result)
		if not isCurrentRequest() then
			return
		end

		TimerManager.removeTimer(request.timerId)

		request.timerId = nil
		request.completed = true

		if tonumber(result) == 0 then
			cache[cacheKey] = allowed == true and PlatformChatFilterService.Decision.Allow or PlatformChatFilterService.Decision.Block
		else
			cache[cacheKey] = PlatformChatFilterService.Decision.Unknown
		end

		local decision = cache[cacheKey]

		for _, callback in ipairs(request.callbacks) do
			if PlatformChatFilterService.state.targetPermissionCache ~= cache or PlatformChatFilterService.state.targetPermissionRequests[cacheKey] ~= request or permissionOwnerUid() ~= request.ownerUid then
				return
			end

			callback(decision)
		end

		if PlatformChatFilterService.state.targetPermissionCache == cache and PlatformChatFilterService.state.targetPermissionRequests[cacheKey] == request and permissionOwnerUid() == request.ownerUid and pg and pg.game and pg.game.chat and type(pg.game.chat.refreshPlatformFilteredChatMessages) == "function" then
			pg.game.chat:refreshPlatformFilteredChatMessages("target_permission_resolved")
		end
	end

	if channel == PlatformCommunicationService.Channel.Voice then
		request.timerId = TimerManager.addTimer(PlatformChatFilterService.VOICE_PERMISSION_TIMEOUT, function()
			if not isCurrentRequest() then
				return
			end

			PlatformCommunicationService:invalidatePermissionRequests(permissionName, targetUserId)
			complete(false, -1)
		end)
	end

	PlatformCommunicationService:dispatchPermissionCheck(permissionName, targetUserId, complete)

	return cache[cacheKey] or PlatformChatFilterService.Decision.Unknown
end

function PlatformChatFilterService.clearTargetPermissionCache(channel, targetUserId)
	if PlatformChatFilterService.state.permissionOwnerUid ~= permissionOwnerUid() then
		channel, targetUserId = nil
	end

	local permissionName = channel and (channel == PlatformCommunicationService.Channel.Voice and PlatformCommunicationService.PermissionName.Voice or PlatformCommunicationService.PermissionName.Text)
	local prefix = permissionName and permissionName .. ":"
	local keyToClear = targetUserId and prefix and prefix .. tostring(targetUserId)
	local cache = PlatformChatFilterService.state.targetPermissionCache
	local requests = PlatformChatFilterService.state.targetPermissionRequests

	for key in pairs(cache) do
		if not prefix or keyToClear and key == keyToClear or not keyToClear and key:sub(1, #prefix) == prefix then
			local request = requests[key]

			if request then
				TimerManager.removeTimer(request.timerId)
			end

			requests[key] = nil
			cache[key] = nil
		end
	end

	if not channel then
		PlatformChatFilterService.state.targetPermissionCache = {}
		PlatformChatFilterService.state.targetPermissionRequests = {}
	end

	PlatformChatFilterService.state.permissionOwnerUid = permissionOwnerUid()

	PlatformCommunicationService:invalidatePermissionRequests(permissionName, targetUserId and tostring(targetUserId))
end

function PlatformChatFilterService.retryXboxVoicePermission(playerInfo)
	if not PlatformChatFilterService.isXboxTargetCommunication(playerInfo) then
		return
	end

	local targetUserId = PlatformIdentityUtils.resolvePlatformUserId(playerInfo)

	if string.isNilOrEmpty(targetUserId) then
		return
	end

	local key = PlatformCommunicationService.PermissionName.Voice .. ":" .. tostring(targetUserId)

	if PlatformChatFilterService.state.targetPermissionCache[key] ~= PlatformChatFilterService.Decision.Pending then
		PlatformChatFilterService.clearTargetPermissionCache(PlatformCommunicationService.Channel.Voice, targetUserId)
	end
end

function PlatformChatFilterService.isPrivateChannel(messageData)
	local chat = PlatformChatFilterService.getChat()

	return chat and messageData and messageData.channelType == chat.channelType.Player
end

function PlatformChatFilterService.shouldCheckBlockedBySender(messageData)
	local chat = PlatformChatFilterService.getChat()

	if not chat or not messageData then
		return false
	end

	if pg and pg.me and tostring(messageData.playerId) == tostring(pg.me.uid) then
		return false
	end

	return messageData.channelType == chat.channelType.Group or messageData.channelType == chat.channelType.Team or messageData.channelType == chat.channelType.World or messageData.channelType == chat.channelType.Near or messageData.channelType == chat.channelType.Home or messageData.channelType == chat.channelType.Friend or messageData.channelType == chat.channelType.Vehicle
end

function PlatformChatFilterService.evaluateBlockedBySender(playerInfo)
	if type(playerInfo) ~= "table" then
		return false, PlatformChatFilterService.REASON_NO_PLAYER_INFO
	end

	if not PlatformIdentityUtils or type(PlatformIdentityUtils.resolvePlatformUserId) ~= "function" then
		return false, PlatformChatFilterService.REASON_PLATFORM_BLOCKED_BY_SENDER_UNAVAILABLE
	end

	local platformUserId = PlatformIdentityUtils.resolvePlatformUserId(playerInfo)

	if string.isNilOrEmpty(platformUserId) then
		return false, PlatformChatFilterService.REASON_NO_PLAYER_INFO
	end

	if not pg or not pg.me then
		return false, PlatformChatFilterService.REASON_PLATFORM_BLOCKED_BY_SENDER_UNAVAILABLE
	end

	if type(pg.me.getPsnBlockRelation) == "function" then
		local relation, expired = pg.me:getPsnBlockRelation(platformUserId, PlatformChatFilterService.PSN_BLOCK_RELATION_CACHE_TTL)

		if relation ~= nil then
			if expired and type(pg.me.requestPsnBlockStates) == "function" then
				pg.me:requestPsnBlockStates({
					platformUserId
				})
			end

			return relation == "BLOCKED_BY" or relation == "BLOCKED_BOTH", nil
		end
	end

	if type(pg.me.requestPsnBlockStates) == "function" then
		pg.me:requestPsnBlockStates({
			platformUserId
		})

		return nil, PlatformChatFilterService.REASON_PLATFORM_BLOCKED_BY_SENDER_PENDING
	end

	return false, PlatformChatFilterService.REASON_PLATFORM_BLOCKED_BY_SENDER_UNAVAILABLE
end

function PlatformChatFilterService.peekIsPlatformFriend(playerInfo)
	if type(PlatformSocialService.peekIsPlatformFriend) == "function" then
		return PlatformSocialService:peekIsPlatformFriend(playerInfo) == true
	end

	return type(playerInfo) == "table" and playerInfo.isPlatformFriend == true
end

function PlatformChatFilterService.evaluateLocalCommunication(service, messageData, playerInfo)
	local channel = PlatformChatFilterService.getMessagePermissionChannel(messageData)
	local policy = PlatformCommunicationService:requireLocalCommunicationPolicy(channel)

	if type(policy) ~= "table" then
		return false, service.Decision.Unknown, PlatformChatFilterService.makeContext(service.Decision.Unknown, PlatformChatFilterService.REASON_LOCAL_COMMUNICATION_POLICY_UNAVAILABLE, {
			channel = channel
		})
	end

	local setting = policy.setting
	local Setting = PlatformCommunicationService.CommunicationSetting

	if setting == Setting.Fallback or setting == Setting.Anyone then
		return false, service.Decision.Allow, PlatformChatFilterService.makeContext(service.Decision.Allow, policy.reason or "allowed", {
			channel = channel,
			communicationSetting = setting,
			audiencePolicy = PlatformCommunicationService.AudiencePolicy.Everyone
		})
	end

	if setting == Setting.Blocked then
		return true, service.Decision.Block, PlatformChatFilterService.makeContext(service.Decision.Block, PlatformChatFilterService.REASON_LOCAL_COMMUNICATION_BLOCKED, {
			channel = channel,
			communicationSetting = setting,
			audiencePolicy = PlatformCommunicationService.AudiencePolicy.Blocked
		})
	end

	if setting == Setting.Friends then
		if PlatformChatFilterService.isPrivateChannel(messageData) and PlatformChatFilterService.peekIsPlatformFriend(playerInfo) then
			return false, service.Decision.Allow, PlatformChatFilterService.makeContext(service.Decision.Allow, policy.reason or "platform_friend", {
				channel = channel,
				communicationSetting = setting,
				audiencePolicy = PlatformCommunicationService.AudiencePolicy.FriendsOnly
			})
		end

		local reason = PlatformChatFilterService.isPrivateChannel(messageData) and PlatformChatFilterService.REASON_LOCAL_COMMUNICATION_FRIENDS_ONLY or PlatformChatFilterService.REASON_LOCAL_COMMUNICATION_FRIENDS_ONLY_PUBLIC

		return true, service.Decision.Block, PlatformChatFilterService.makeContext(service.Decision.Block, reason, {
			channel = channel,
			communicationSetting = setting,
			audiencePolicy = PlatformCommunicationService.AudiencePolicy.FriendsOnly
		})
	end

	return true, service.Decision.Block, PlatformChatFilterService.makeContext(service.Decision.Block, PlatformChatFilterService.REASON_LOCAL_COMMUNICATION_UNKNOWN, {
		channel = channel,
		communicationSetting = setting
	})
end

function PlatformChatFilterService:evaluateMessage(messageData, playerInfo)
	local blocked, reason, err = PlatformChatFilterService.peekPlatformBlocked(playerInfo)

	if blocked == true then
		return true, self.Decision.Block, PlatformChatFilterService.makeContext(self.Decision.Block, PlatformChatFilterService.REASON_PLATFORM_BLOCK_LIST)
	end

	if blocked == nil then
		return false, self.Decision.Pending, PlatformChatFilterService.makeContext(self.Decision.Pending, PlatformChatFilterService.REASON_PLATFORM_BLOCK_LIST_PENDING)
	end

	if reason == PlatformChatFilterService.REASON_NO_PLAYER_INFO or reason == PlatformChatFilterService.REASON_PLATFORM_BLOCK_LIST_UNAVAILABLE or reason == PlatformChatFilterService.REASON_PLATFORM_BLOCK_LIST_ERROR then
		return false, self.Decision.Unknown, PlatformChatFilterService.makeContext(self.Decision.Unknown, reason, {
			error = err
		})
	end

	local localBlocked, localDecision, localContext = PlatformChatFilterService.evaluateLocalCommunication(self, messageData, playerInfo)

	if localContext.communicationSetting == PlatformCommunicationService.CommunicationSetting.Blocked then
		return localBlocked, localDecision, localContext
	end

	local targetDecision = PlatformChatFilterService.getXboxTargetDecision(PlatformChatFilterService.getMessagePermissionChannel(messageData), playerInfo)

	if targetDecision == self.Decision.Block then
		return true, self.Decision.Block, PlatformChatFilterService.makeContext(self.Decision.Block, PlatformChatFilterService.REASON_TARGET_COMMUNICATION_BLOCKED)
	end

	if targetDecision == self.Decision.Pending then
		return false, self.Decision.Pending, PlatformChatFilterService.makeContext(self.Decision.Pending, PlatformChatFilterService.REASON_TARGET_COMMUNICATION_PENDING)
	end

	if targetDecision == self.Decision.Allow then
		return false, self.Decision.Allow, PlatformChatFilterService.makeContext(self.Decision.Allow, "target_permission_allowed")
	end

	if PlatformChatFilterService.shouldCheckBlockedBySender(messageData) then
		local blockedBySender, blockedBySenderReason = PlatformChatFilterService.evaluateBlockedBySender(playerInfo)

		if blockedBySender == true then
			return true, self.Decision.Block, PlatformChatFilterService.makeContext(self.Decision.Block, PlatformChatFilterService.REASON_PLATFORM_BLOCKED_BY_SENDER)
		end

		if blockedBySender == nil then
			return false, self.Decision.Pending, PlatformChatFilterService.makeContext(self.Decision.Pending, PlatformChatFilterService.REASON_PLATFORM_BLOCKED_BY_SENDER_PENDING)
		end

		if blockedBySenderReason == PlatformChatFilterService.REASON_PLATFORM_BLOCKED_BY_SENDER_UNAVAILABLE then
			return false, self.Decision.Unknown, PlatformChatFilterService.makeContext(self.Decision.Unknown, blockedBySenderReason)
		end
	end

	return localBlocked, localDecision, localContext
end

function PlatformChatFilterService:shouldFilterMessage(messageData, playerInfo)
	local shouldFilter, decision, context = self:evaluateMessage(messageData, playerInfo)

	return shouldFilter == true, decision, context
end

function PlatformChatFilterService:shouldRemoveAfterResolve(messageData, playerInfo)
	local shouldFilter, decision, context = self:evaluateMessage(messageData, playerInfo)

	return shouldFilter == true, decision, context
end

function PlatformChatFilterService:resolvePendingMessage(messageData, playerInfo, onResolved, options)
	if type(onResolved) ~= "function" then
		return false
	end

	local _, decision, context = self:evaluateMessage(messageData, playerInfo)

	if decision ~= self.Decision.Pending then
		onResolved(decision, context)

		return false
	end

	local timer = PlatformChatFilterService.getTimer()

	if not timer then
		return false
	end

	options = options or {}

	local interval = options.interval or PlatformChatFilterService.DEFAULT_PENDING_RECHECK_INTERVAL
	local attemptsLeft = options.maxAttempts or PlatformChatFilterService.DEFAULT_PENDING_RECHECK_ATTEMPTS

	function PlatformChatFilterService.recheck()
		local _, currentDecision, currentContext = self:evaluateMessage(messageData, playerInfo)

		if currentDecision ~= self.Decision.Pending or attemptsLeft <= 1 then
			onResolved(currentDecision, currentContext)

			return
		end

		attemptsLeft = attemptsLeft - 1

		timer:delayCall(interval, PlatformChatFilterService.recheck)
	end

	timer:delayCall(interval, PlatformChatFilterService.recheck)

	return true
end

return PlatformChatFilterService
