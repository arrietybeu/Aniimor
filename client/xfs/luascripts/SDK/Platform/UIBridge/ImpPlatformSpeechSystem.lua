-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformSpeechSystem.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local M = {}

M.PLATFORM_CALLBACK_OWNER = "SDK.Platform.UIBridge.ImpPlatformSpeechSystem"

local MessageName = require("Const.MessageName")
local PlatformUGCService = require("SDK.Platform.PlatformUGCService")
local PlatformChatFilterService = require("SDK.Platform.PlatformChatFilterService")
local PlatformSocialService = require("SDK.Platform.PlatformSocialService")
local PlatformCommunicationService = require("SDK.Platform.PlatformCommunicationService")
local TimerManager = require("Core.Timer.TimerManager")
local EventConst = require("Common.Const.EventConst")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")

M.SPEAKING_BLOCK_CHECK_INTERVAL = 5
M._speakingBlockCheckLastTime = {}
M._speakingBlockCheckTimerIds = {}
M.VOICE_PERMISSION_RETRY_INTERVAL = 5
M._voicePolicyState = nil

local function voiceContext()
	local manager = pg and pg.global and pg.global.gmeManager
	local roomId = manager and (manager.currentRoomId or manager.exitRoomRequesting and manager.exitRoomPreviousRoomId) or nil

	return pg and pg.me and tostring(pg.me.uid) or "", roomId
end

function M.resetVoicePolicyState()
	local state = M._voicePolicyState

	M._voicePolicyState = nil

	for _, member in pairs(state and state.members or EMPTY_TABLE) do
		TimerManager.removeTimer(member.retryTimerId)
	end

	PlatformChatFilterService.clearTargetPermissionCache(PlatformCommunicationService.Channel.Voice)
end

local function ensureVoicePolicyState()
	local ownerUid, roomId = voiceContext()
	local state = M._voicePolicyState

	if not state or state.ownerUid ~= ownerUid or state.roomId ~= roomId then
		M.resetVoicePolicyState()

		state = {
			ownerUid = ownerUid,
			roomId = roomId,
			members = {}
		}
		M._voicePolicyState = state
	end

	return state
end

function M.onVoiceTargetPermissionResolved()
	M.syncCurrentSpeechRoomVoicePolicy()
end

local function scheduleVoiceRetry(state, uid, member)
	local speech = M.getSpeechSystem()

	if member.retryTimerId or not state.roomId or not speech or not pg.me or not speech:checkMemberInRoom(pg.me.uid) or not speech:checkMemberInRoom(uid) then
		return
	end

	member.retryTimerId = TimerManager.addTimer(M.VOICE_PERMISSION_RETRY_INTERVAL, function()
		member.retryTimerId = nil

		local ownerUid, roomId = voiceContext()

		if M._voicePolicyState ~= state or state.members[tostring(uid)] ~= member or ownerUid ~= state.ownerUid or roomId ~= state.roomId then
			return
		end

		local currentSpeech = M.getSpeechSystem()

		if not currentSpeech or not pg.me or not currentSpeech:checkMemberInRoom(pg.me.uid) or not currentSpeech:checkMemberInRoom(uid) then
			return
		end

		PlatformChatFilterService.retryXboxVoicePermission(member.playerInfo)
		M.syncMemberRealtimeVoicePolicy(currentSpeech, uid)
	end)
end

local function evaluateXboxVoicePolicy(playerInfo)
	local policy = M.getLocalVoiceCommunicationPolicy()
	local setting = policy and (policy.communicationSetting or policy.setting)

	if setting == "blocked" or policy and policy.decision == "deny" then
		return true
	end

	local platformBlocked = PlatformSocialService.peekPlatformUserBlockedByLocalUser and PlatformSocialService:peekPlatformUserBlockedByLocalUser(playerInfo)

	if platformBlocked == true or M.isBlockedByTarget(playerInfo) then
		return true
	end

	local targetFamily = PlatformIdentityUtils.resolvePlayerInfoFamily(playerInfo)

	if targetFamily == nil or targetFamily == PlatformIdentityUtils.UnknownFamily then
		return nil
	end

	if targetFamily == PlatformIdentityUtils.Family.Xbox then
		local decision = PlatformChatFilterService.getXboxTargetDecision(PlatformCommunicationService.Channel.Voice, playerInfo, M.onVoiceTargetPermissionResolved)

		if decision == PlatformChatFilterService.Decision.Block then
			return true
		end

		if decision == PlatformChatFilterService.Decision.Pending then
			return nil, true
		end

		if decision ~= PlatformChatFilterService.Decision.Allow then
			return nil
		end
	elseif M.isFriendOnlyBlocked(playerInfo, PlatformChatFilterService.Decision.Unknown) then
		return true
	end

	if platformBlocked == nil or not policy or setting == nil or setting == "unknown" then
		return nil
	end

	return false
end

function M.getUid(data)
	return data and data.uid or nil
end

function M.isSelfUid(uid)
	if uid == nil then
		return false
	end

	return tostring(uid) == tostring(pg.me.uid)
end

function M.getTeamMemberInfo(uid)
	if uid == nil or pg.me.getCurTeamInfo == nil then
		return nil
	end

	local teamInfo = pg.me:getCurTeamInfo()

	if teamInfo == nil or teamInfo.membersInfo == nil then
		return nil
	end

	return teamInfo.membersInfo[uid] or teamInfo.membersInfo[tostring(uid)]
end

function M.getChatPlayerInfo(uid)
	if uid == nil or pg.game.chat == nil or pg.game.chat.getPlayerInfo == nil then
		return nil
	end

	return pg.game.chat:getPlayerInfo(tostring(uid))
end

function M.hasPlatformIdentity(playerInfo)
	return playerInfo ~= nil and (playerInfo.platformUserId ~= nil or playerInfo.platformFamily ~= nil or playerInfo.platformInfo ~= nil or playerInfo.isPlatformFriend ~= nil)
end

function M.resolvePlayerInfo(data)
	local uid = M.getUid(data)

	if M.hasPlatformIdentity(data) then
		return data
	end

	local memberInfo = M.getTeamMemberInfo(uid)

	if M.hasPlatformIdentity(memberInfo) then
		return memberInfo
	end

	local chatPlayerInfo = M.getChatPlayerInfo(uid)

	if M.hasPlatformIdentity(chatPlayerInfo) then
		return chatPlayerInfo
	end

	return memberInfo or chatPlayerInfo or data
end

function M.isUGCBlocked(playerInfo)
	if PlatformUGCService.isVisibleForPlayer == nil then
		return false
	end

	local visible = PlatformUGCService:isVisibleForPlayer(playerInfo)

	return visible == false
end

function M.isPlatformBlocked(playerInfo)
	if PlatformSocialService.peekPlatformUserBlockedByLocalUser == nil then
		return false
	end

	return PlatformSocialService:peekPlatformUserBlockedByLocalUser(playerInfo) == true
end

function M.isPlatformFriend(playerInfo)
	return M.getPlatformFriendState(playerInfo) == true
end

function M.getPlatformFriendState(playerInfo)
	if playerInfo == nil then
		return false
	end

	if playerInfo.isPlatformFriend == true then
		return true
	end

	if playerInfo.isPlatformFriend == false then
		return false
	end

	if playerInfo.platformInfo and playerInfo.platformInfo.isPlatformFriend == true then
		return true
	end

	if playerInfo.platformInfo and playerInfo.platformInfo.isPlatformFriend == false then
		return false
	end

	if PlatformSocialService.peekIsPlatformFriend ~= nil then
		return PlatformSocialService:peekIsPlatformFriend(playerInfo)
	end

	return false
end

function M.getLocalVoiceCommunicationPolicy()
	if PlatformCommunicationService.peekLocalCommunicationPolicy == nil then
		return nil
	end

	return PlatformCommunicationService:peekLocalCommunicationPolicy(PlatformCommunicationService.Channel.Voice)
end

function M.isLocalVoiceCommunicationFriendsOnly()
	local policy = M.getLocalVoiceCommunicationPolicy()

	if policy == nil then
		return false
	end

	local setting = policy.communicationSetting or policy.setting
	local audiencePolicy = policy.audiencePolicy

	return setting == (PlatformCommunicationService.CommunicationSetting and PlatformCommunicationService.CommunicationSetting.Friends) or setting == "friends" or audiencePolicy == (PlatformCommunicationService.AudiencePolicy and PlatformCommunicationService.AudiencePolicy.FriendsOnly) or audiencePolicy == "friends_only"
end

function M.isFriendOnlyBlocked(playerInfo, targetDecision)
	if targetDecision == PlatformChatFilterService.Decision.Allow then
		return false
	end

	if targetDecision == PlatformChatFilterService.Decision.Block then
		return true
	end

	return M.isLocalVoiceCommunicationFriendsOnly() and M.getPlatformFriendState(playerInfo) == false
end

function M.shouldForceMuted(playerInfo, uid)
	if PlatformIdentityUtils.getCurrentPlatformFamily() == PlatformIdentityUtils.Family.Xbox then
		local state = ensureVoicePolicyState()
		local key = tostring(uid)
		local identity = tostring(PlatformIdentityUtils.resolvePlayerInfoFamily(playerInfo)) .. ":" .. tostring(PlatformIdentityUtils.resolvePlatformUserId(playerInfo))
		local member = state.members[key]

		if not member or member.identity ~= identity then
			if member then
				TimerManager.removeTimer(member.retryTimerId)

				local previousTarget = PlatformIdentityUtils.resolvePlatformUserId(member.playerInfo)

				if not string.isNilOrEmpty(previousTarget) then
					PlatformChatFilterService.clearTargetPermissionCache(PlatformCommunicationService.Channel.Voice, previousTarget)
				end
			end

			member = {
				identity = identity
			}
			state.members[key] = member
		end

		member.playerInfo = playerInfo

		local blocked, pending = evaluateXboxVoicePolicy(playerInfo)

		if blocked ~= nil then
			member.lastBlocked = blocked

			TimerManager.removeTimer(member.retryTimerId)

			member.retryTimerId = nil
		elseif not pending then
			scheduleVoiceRetry(state, uid, member)
		end

		return member.lastBlocked ~= false
	end

	local blocked = M.isLocalVoiceCommunicationBlocked()
	local platformBlocked = M.isPlatformBlocked(playerInfo)

	if blocked or platformBlocked then
		return true
	end

	local targetDecision = PlatformChatFilterService.getXboxTargetDecision(PlatformCommunicationService.Channel.Voice, playerInfo, M.syncCurrentSpeechRoomVoicePolicy)
	local friendOnlyBlocked = M.isFriendOnlyBlocked(playerInfo, targetDecision)
	local blockedByTarget = M.isBlockedByTarget(playerInfo)

	return friendOnlyBlocked or blockedByTarget
end

function M.isLocalVoiceCommunicationBlocked()
	if PlatformCommunicationService.isLocalCommunicationBlocked == nil then
		return false
	end

	return PlatformCommunicationService:isLocalCommunicationBlocked(PlatformCommunicationService.Channel.Voice) == true
end

function M.disableLocalRealtimeVoice()
	pg.global.gmeManager:EnableSpeaker(false, true)
	pg.global.gmeManager:EnableMic(false, true)
end

function M.syncLocalRealtimeVoicePolicy()
	if M.isLocalVoiceCommunicationBlocked() then
		M.disableLocalRealtimeVoice()
	end
end

function M.syncMemberRealtimeVoicePolicy(speechSystem, uid, forceApply)
	if uid == nil or M.isSelfUid(uid) then
		return
	end

	if not speechSystem:checkMemberInRoom(pg.me.uid) then
		return
	end

	if not speechSystem:checkMemberInRoom(uid) then
		return
	end

	local playerInfo = M.resolvePlayerInfo({
		uid = uid
	})

	speechSystem:updatePlatformMutedMembers(uid, M.shouldForceMuted(playerInfo, uid), forceApply)
end

function M.syncMembersRealtimeVoicePolicy(speechSystem, uids, forceApply)
	if uids == nil or #uids == 0 then
		return
	end

	for _, uid in ipairs(uids) do
		M.syncMemberRealtimeVoicePolicy(speechSystem, uid, forceApply)
	end
end

function M.getSpeechSystem()
	return pg and pg.game and pg.game.speech
end

function M.getSpeechRoomMemberUids(speechSystem)
	local uids = {}

	if speechSystem == nil then
		return uids
	end

	local roomMembers

	if speechSystem.getSpeechRoomMembers ~= nil then
		roomMembers = speechSystem:getSpeechRoomMembers()
	else
		roomMembers = speechSystem.speechRoomMembers
	end

	if roomMembers == nil then
		return uids
	end

	for uid, _ in pairs(roomMembers) do
		table.insert(uids, uid)
	end

	return uids
end

function M.refreshSpeechRoomMemberState()
	if facade and facade.SendMessageCommand then
		facade:SendMessageCommand(MessageName.SPEECH_ROOM_MEMBER_STATE_CHANGE)
	end
end

function M.registerPlatformCallbacks()
	M.registerBlockListChangedListener()

	local platform = pg.global.platform

	if platform == nil or platform.registerPlatformCallback == nil then
		return false
	end

	local callbackEvents = platform.PLATFORM_CALLBACK_EVENT
	local eventKey = callbackEvents and callbackEvents.FriendListChanged or nil

	if type(eventKey) ~= "string" or eventKey == "" then
		return false
	end

	return platform:registerPlatformCallback(eventKey, M.PLATFORM_CALLBACK_OWNER, function()
		PlatformChatFilterService.clearTargetPermissionCache()
		M.syncCurrentSpeechRoomVoicePolicy()
	end) == true
end

function M.syncCurrentSpeechRoomVoicePolicy()
	local speechSystem = M.getSpeechSystem()

	if speechSystem == nil then
		return
	end

	M.syncMembersRealtimeVoicePolicy(speechSystem, M.getSpeechRoomMemberUids(speechSystem))
	M.refreshSpeechRoomMemberState()
end

function M.joinSpeechChannel()
	ensureVoicePolicyState()
	PlatformChatFilterService.clearTargetPermissionCache(PlatformCommunicationService.Channel.Voice)
	M.syncLocalRealtimeVoicePolicy()
	M.syncCurrentSpeechRoomVoicePolicy()
end

function M.quitSpeechChannel()
	M.resetVoicePolicyState()

	for _, timerId in pairs(M._speakingBlockCheckTimerIds) do
		TimerManager.removeTimer(timerId)
	end

	M._speakingBlockCheckTimerIds = {}
	M._speakingBlockCheckLastTime = {}
end

function M.updateSpeechRoomMembers(speechSystem, uids)
	M.syncLocalRealtimeVoicePolicy()

	local psnApplicable = M.isPsnBlockCheckApplicable()
	local resolvedUids = {}
	local unresolvedUids = {}
	local selfJoined = false

	for _, uid in ipairs(uids or EMPTY_TABLE) do
		M._speakingBlockCheckLastTime[tostring(uid)] = nil

		if speechSystem:checkMemberInRoom(uid) then
			if M.isSelfUid(uid) then
				selfJoined = true
			else
				local playerInfo = M.resolvePlayerInfo({
					uid = uid
				})

				if psnApplicable and not M.isRelationResolved(playerInfo) then
					speechSystem:updatePlatformMutedMembers(uid, true, true)
					M.startSpeakingBlockCheckTimer(uid)
					table.insert(unresolvedUids, uid)
				else
					table.insert(resolvedUids, uid)
				end
			end
		else
			M.stopSpeakingBlockCheckTimer(uid)

			if M.isSelfUid(uid) then
				M.quitSpeechChannel()
			end

			local state = M._voicePolicyState
			local member = state and state.members[tostring(uid)]

			if member then
				TimerManager.removeTimer(member.retryTimerId)

				local targetUserId = PlatformIdentityUtils.resolvePlatformUserId(member.playerInfo)

				if not string.isNilOrEmpty(targetUserId) then
					PlatformChatFilterService.clearTargetPermissionCache(PlatformCommunicationService.Channel.Voice, targetUserId)
				end

				state.members[tostring(uid)] = nil
			end
		end
	end

	M.requestPsnBlockStatesForJoiningMembers(unresolvedUids)

	if selfJoined and PlatformIdentityUtils.getCurrentPlatformFamily() == PlatformIdentityUtils.Family.Xbox then
		resolvedUids = M.getSpeechRoomMemberUids(speechSystem)
	end

	M.syncMembersRealtimeVoicePolicy(speechSystem, resolvedUids, true)
end

function M.handlePlayerVoiceState(speechSystem, data, muted)
	local uid = M.getUid(data)

	if uid == nil or M.isSelfUid(uid) then
		return muted
	end

	if not speechSystem:checkMemberInRoom(pg.me.uid) then
		return muted
	end

	if not speechSystem:checkMemberInRoom(uid) then
		return muted
	end

	local playerInfo = M.resolvePlayerInfo(data)

	return M.shouldForceMuted(playerInfo, uid)
end

function M.isBlockedByTarget(playerInfo)
	if not pg or not pg.me then
		return false
	end

	if type(pg.me.getPsnBlockRelation) ~= "function" then
		return false
	end

	local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
	local platformUserId = PlatformIdentityUtils.resolvePlatformUserId(playerInfo)

	if string.isNilOrEmpty(platformUserId) then
		return false
	end

	local relation = pg.me:getPsnBlockRelation(platformUserId)

	if relation == nil then
		return false
	end

	local blocked = relation == "BLOCKED_BY" or relation == "BLOCKED_BOTH"

	return blocked
end

function M.triggerSpeakingBlockCheck(uid, playerInfo)
	local uidStr = tostring(uid)
	local now = os.time()
	local lastCheck = M._speakingBlockCheckLastTime[uidStr] or 0

	if now - lastCheck < M.SPEAKING_BLOCK_CHECK_INTERVAL then
		return false
	end

	if not pg or not pg.me then
		return false
	end

	local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
	local platformUserId = PlatformIdentityUtils.resolvePlatformUserId(playerInfo)

	if string.isNilOrEmpty(platformUserId) then
		return false
	end

	M._speakingBlockCheckLastTime[uidStr] = now

	if type(pg.me.requestPsnBlockStates) == "function" then
		pg.me:requestPsnBlockStates({
			platformUserId
		}, true)
	end

	return true
end

function M.stopSpeakingBlockCheckTimer(uid)
	local uidStr = tostring(uid)
	local timerId = M._speakingBlockCheckTimerIds[uidStr]

	if timerId == nil then
		return
	end

	TimerManager.removeTimer(timerId)

	M._speakingBlockCheckTimerIds[uidStr] = nil
end

function M.onSpeakingBlockCheckTimerTick(uid)
	local speechSystem = M.getSpeechSystem()

	if not speechSystem or not pg or not pg.me or not speechSystem:checkMemberInRoom(pg.me.uid) then
		M.stopSpeakingBlockCheckTimer(uid)

		return
	end

	if not speechSystem:checkMemberInRoom(uid) then
		M.stopSpeakingBlockCheckTimer(uid)

		return
	end

	M.syncMemberRealtimeVoicePolicy(speechSystem, uid)

	local isSpeaking = type(speechSystem.checkMemberSpeaking) == "function" and speechSystem:checkMemberSpeaking(uid) == true

	if not isSpeaking then
		M.stopSpeakingBlockCheckTimer(uid)

		return
	end

	local playerInfo = M.resolvePlayerInfo({
		uid = uid
	})

	M.triggerSpeakingBlockCheck(uid, playerInfo)
end

function M.startSpeakingBlockCheckTimer(uid)
	local uidStr = tostring(uid)

	if M._speakingBlockCheckTimerIds[uidStr] ~= nil then
		return
	end

	M._speakingBlockCheckTimerIds[uidStr] = TimerManager.addRepeatTimer(M.SPEAKING_BLOCK_CHECK_INTERVAL, function()
		M.onSpeakingBlockCheckTimerTick(uid)
	end)
end

function M.updateSpeakingMembers(speechSystem, uids)
	if not uids or #uids == 0 then
		return
	end

	for _, uid in ipairs(uids) do
		if not M.isSelfUid(uid) then
			local isSpeaking = type(speechSystem.checkMemberSpeaking) == "function" and speechSystem:checkMemberSpeaking(uid) == true

			if isSpeaking then
				local playerInfo = M.resolvePlayerInfo({
					uid = uid
				})

				M.triggerSpeakingBlockCheck(uid, playerInfo)
				M.startSpeakingBlockCheckTimer(uid)
			else
				M.stopSpeakingBlockCheckTimer(uid)
			end
		end
	end
end

function M.requestPsnBlockStatesForJoiningMembers(uids)
	if not uids or #uids == 0 then
		return
	end

	if not pg or not pg.me or type(pg.me.requestPsnBlockStates) ~= "function" then
		return
	end

	local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
	local platformUserIds = {}

	for _, uid in ipairs(uids) do
		if not M.isSelfUid(uid) then
			local playerInfo = M.resolvePlayerInfo({
				uid = uid
			})
			local platformUserId = PlatformIdentityUtils.resolvePlatformUserId(playerInfo)

			if not string.isNilOrEmpty(platformUserId) then
				table.insert(platformUserIds, platformUserId)
			end
		end
	end

	if #platformUserIds > 0 then
		pg.me:requestPsnBlockStates(platformUserIds)
	end
end

function M.registerBlockListChangedListener()
	if M._blockListChangedListenerRegistered then
		return
	end

	local emitter = pg.global.eventEmitter

	if not emitter or not emitter.addEventListener then
		return
	end

	emitter:addEventListener(EventConst.PLATFORM_BLOCK_LIST_CHANGED, function()
		PlatformChatFilterService.clearTargetPermissionCache(PlatformCommunicationService.Channel.Voice)
		M.syncCurrentSpeechRoomVoicePolicy()
	end)
	emitter:addEventListener(EventConst.PLATFORM_LOCAL_COMMUNICATION_POLICY_CHANGED, function(payload)
		if type(payload) == "table" and payload.channel == PlatformCommunicationService.Channel.Voice then
			PlatformChatFilterService.clearTargetPermissionCache(PlatformCommunicationService.Channel.Voice)
			M.syncCurrentSpeechRoomVoicePolicy()
		end
	end)

	M._blockListChangedListenerRegistered = true
end

function M.isRelationResolved(playerInfo)
	if not pg or not pg.me or type(pg.me.getPsnBlockRelation) ~= "function" then
		return false
	end

	local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
	local platformUserId = PlatformIdentityUtils.resolvePlatformUserId(playerInfo)

	if string.isNilOrEmpty(platformUserId) then
		return false
	end

	return pg.me:getPsnBlockRelation(platformUserId) ~= nil
end

function M.isPsnBlockCheckApplicable()
	if not pg or not pg.global or not pg.global.platform then
		return false
	end

	return pg.global.platform:isPS()
end

function M.preMuteUnresolvedTeamMembers(teamComponent)
	local speechSystem = M.getSpeechSystem()

	if not speechSystem or not teamComponent or type(teamComponent.getCurTeamInfo) ~= "function" then
		return
	end

	local teamInfo = teamComponent:getCurTeamInfo()

	if not teamInfo or not teamInfo.membersInfo then
		return
	end

	local psnApplicable = M.isPsnBlockCheckApplicable()
	local pendingUids = {}

	for uid, _ in pairs(teamInfo.membersInfo) do
		if not M.isSelfUid(uid) then
			local playerInfo = M.resolvePlayerInfo({
				uid = uid
			})
			local unresolved = psnApplicable and not M.isRelationResolved(playerInfo)

			if unresolved or M.shouldForceMuted(playerInfo, uid) then
				speechSystem:updatePlatformMutedMembers(uid, true)
			end

			if unresolved then
				M.startSpeakingBlockCheckTimer(uid)
				table.insert(pendingUids, uid)
			end
		end
	end

	if #pendingUids > 0 then
		M.requestPsnBlockStatesForJoiningMembers(pendingUids)
	end
end

return M
