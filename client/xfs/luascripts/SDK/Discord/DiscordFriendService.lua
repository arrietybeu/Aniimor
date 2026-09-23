-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Discord\\DiscordFriendService.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Const = require("Common.Const.Const")
local MessageName = require("Const.MessageName")
local DiscordSocialUtils = require("Utils.DiscordSocialUtils")
local FuncIdConfigData = require("Data.func_index_config_data")
local logger = require("SDK.Platform.PlatformLogger")
local TimerManager = require("Core.Timer.TimerManager")
local DiscordFriendService = {}

DiscordFriendService.state = {
	friendPlayerInfoMap = {}
}

function DiscordFriendService.tryInitialize()
	if not pg.game.chat.hasInit then
		return
	end

	if not pg.me:checkFunctionUnlock(Const.FUNCTION_NAME.FRIEND) then
		return
	end

	if pg.global.sdkManager:isDiscordBound() ~= true then
		DiscordFriendService.clearFriendRuntimeData()

		return
	end

	DiscordSocialUtils.setJoinCallback(DiscordFriendService.onDiscordActivityJoin)

	if DiscordSocialUtils.isReady() then
		DiscordSocialUtils.refreshFriends()

		return
	end

	local requested, state = pg.global.sdkManager:ensureDiscordTokenValid()

	if not requested then
		logger:warn("DiscordFriendService: ensureDiscordTokenValid failed state=%s", tostring(state))
		DiscordFriendService.clearFriendRuntimeData()
	end
end

function DiscordFriendService.onChatSystemInitialized()
	DiscordFriendService.tryInitialize()
end

function DiscordFriendService.onFunctionUnlocksChanged(_, oldValue, newValue)
	local oldState = oldValue and oldValue[Const.FUNCTION_NAME.FRIEND] or nil
	local newState = newValue and newValue[Const.FUNCTION_NAME.FRIEND] or nil

	if newState ~= Const.FUNCTION_UNLOCK_STATE.UNLOCK or oldState == newState then
		return
	end

	DiscordFriendService.tryInitialize()
end

function DiscordFriendService.onDiscordFriendsUpdated(snapshot)
	DiscordFriendService.state.friendSnapshot = DiscordFriendService.copyFriendSnapshot(snapshot)

	DiscordFriendService.notifyRefreshFriends()
	DiscordFriendService.requestFriendPlayerInfos()
end

function DiscordFriendService.copyFriendSnapshot(snapshot)
	snapshot = type(snapshot) == "table" and snapshot or {}

	return {
		isReady = snapshot.isReady == true,
		onlinePlayingGame = DiscordFriendService.copyFriendList(snapshot.onlinePlayingGame),
		onlineElsewhere = DiscordFriendService.copyFriendList(snapshot.onlineElsewhere),
		offline = DiscordFriendService.copyFriendList(snapshot.offline)
	}
end

function DiscordFriendService.copyFriendList(friends)
	local result = {}

	for _, friend in ipairs(friends or EMPTY_TABLE) do
		local copiedFriend = DiscordFriendService.copyFriend(friend)

		if copiedFriend and not string.isNilOrEmpty(copiedFriend.id) then
			result[#result + 1] = copiedFriend
		end
	end

	return result
end

function DiscordFriendService.copyFriend(friend)
	if type(friend) ~= "table" then
		return nil
	end

	return {
		id = tostring(friend.id or ""),
		displayName = friend.displayName,
		avatarUrl = friend.avatarUrl,
		status = friend.status,
		activityName = friend.activityName,
		activityState = friend.activityState,
		activityDetails = friend.activityDetails,
		applicationProfiles = DiscordFriendService.copyApplicationProfiles(friend.applicationProfiles)
	}
end

function DiscordFriendService.copyApplicationProfiles(profiles)
	local result = {}

	for _, profile in ipairs(profiles or EMPTY_TABLE) do
		result[#result + 1] = {
			providerType = profile.providerType,
			providerId = profile.providerId,
			providerIssuedUserId = profile.providerIssuedUserId,
			username = profile.username,
			avatarHash = profile.avatarHash,
			metadata = profile.metadata
		}
	end

	return result
end

function DiscordFriendService.getFriendSnapshot()
	return DiscordFriendService.state.friendSnapshot or DiscordFriendService.buildEmptyFriendSnapshot()
end

function DiscordFriendService.buildEmptyFriendSnapshot()
	return {
		isReady = false,
		onlinePlayingGame = {},
		onlineElsewhere = {},
		offline = {}
	}
end

function DiscordFriendService.requestFriendPlayerInfos()
	if not pg.game.chat.hasInit then
		return
	end

	DiscordFriendService.state.friendPlayerInfoMap = {}

	local discordUserIds = DiscordFriendService.getDiscordFriendUserIds(DiscordFriendService.getFriendSnapshot())

	if #discordUserIds == 0 or pg.me.queryDiscordFriendPlayerInfos == nil then
		return
	end

	if pg.me.queryDiscordFriendPlayerInfos then
		pg.me:queryDiscordFriendPlayerInfos(discordUserIds, function(playerInfoMap)
			DiscordFriendService.state.friendPlayerInfoMap = playerInfoMap or {}

			DiscordFriendService.notifyRefreshPlayerInfos()
		end)
	end
end

function DiscordFriendService.getDiscordFriendUserIds(snapshot)
	local result = {}
	local userIdSet = {}
	local friendGroups = {
		snapshot and snapshot.onlinePlayingGame or {},
		snapshot and snapshot.onlineElsewhere or {},
		snapshot and snapshot.offline or {}
	}

	for _, friends in ipairs(friendGroups) do
		for _, friend in ipairs(friends) do
			local discordUserId = tostring(friend and friend.id or "")

			if not string.isNilOrEmpty(discordUserId) and not userIdSet[discordUserId] then
				userIdSet[discordUserId] = true

				table.insert(result, discordUserId)
			end
		end
	end

	return result
end

function DiscordFriendService.getFriendPlayerInfoMap()
	return DiscordFriendService.state.friendPlayerInfoMap
end

function DiscordFriendService.notifyRefreshFriends()
	facade:SendMessageCommand(MessageName.DISCORD_FRIENDS_REFRESH, DiscordFriendService.getFriendSnapshot())
end

function DiscordFriendService.notifyRefreshPlayerInfos()
	facade:SendMessageCommand(MessageName.DISCORD_FRIEND_PLAYER_INFOS_REFRESH, {
		snapshot = DiscordFriendService.getFriendSnapshot(),
		playerInfoMap = DiscordFriendService.getFriendPlayerInfoMap()
	})
end

function DiscordFriendService.resetFriendData()
	DiscordFriendService.state.friendSnapshot = DiscordFriendService.buildEmptyFriendSnapshot()
	DiscordFriendService.state.friendPlayerInfoMap = {}
end

function DiscordFriendService.clearFriendRuntimeData()
	DiscordFriendService.resetFriendData()
	DiscordFriendService.notifyRefreshFriends()
end

function DiscordFriendService.shutdown()
	DiscordSocialUtils.clear()
	DiscordFriendService.finishPendingInviteRequest()
	DiscordFriendService.clearPublishedInvitePresenceRecord()

	DiscordFriendService.discordInviteCooldownExpireAt = 0

	DiscordFriendService.clearFriendRuntimeData()
end

function DiscordFriendService.onFriendSystemReset()
	DiscordFriendService.clearFriendRuntimeData()
end

function DiscordFriendService.onSDKAccountBindChanged()
	if pg.global.sdkManager:isDiscordBound() == false then
		DiscordFriendService.shutdown()

		return
	end

	DiscordFriendService.tryInitialize()
end

function DiscordFriendService.onDiscordStatusChanged(result)
	if type(result) ~= "table" then
		return
	end

	local status = result.status

	if status == "Ready" then
		return
	end

	if status == "Connecting" or status == "Reconnecting" or status == "Disconnecting" then
		return
	end

	if status == "Disconnected" or status == "InitializationFailed" or status == "TokenUpdateFailed" or status == "CallbackFailed" then
		logger:warn("DiscordFriendService: Discord unavailable status=%s error=%s", tostring(status), tostring(result.errorMessage or ""))
		DiscordFriendService.stopDiscordInviteFlow()
		DiscordFriendService.clearFriendRuntimeData()
	end
end

function DiscordFriendService.onDiscordSocialInfoUpdated(result)
	if type(result) ~= "table" then
		logger:warn("DiscordFriendService: onDiscordSocialInfoUpdated invalid result")
		DiscordFriendService.stopDiscordInviteFlow()
		DiscordFriendService.clearFriendRuntimeData()

		return
	end

	if result.success == true then
		return
	end

	logger:warn("DiscordFriendService: social info update failed state=%s code=%s message=%s", tostring(result.state or ""), tostring(result.code or ""), tostring(result.message or ""))
	DiscordFriendService.stopDiscordInviteFlow()
	DiscordFriendService.clearFriendRuntimeData()
end

DiscordFriendService.INVITE_ERROR_CODE = {
	CREATE_CONTEXT_FAILED = "DINV_03_CREATE_CONTEXT_FAILED",
	PENDING_INVITE_ERROR = "DINV_11_PENDING_INVITE_ERROR",
	TARGET_USER_ID_EMPTY = "DINV_02_TARGET_USER_ID_EMPTY",
	DISCORD_INVITE_IN_PROGRESS = "DISCORD_INVITE_IN_PROGRESS",
	DISCORD_NOT_READY = "DINV_01_DISCORD_NOT_READY",
	JOIN_SECRET_EMPTY = "DINV_09_JOIN_SECRET_EMPTY",
	INVITE_SEND_FAILED = "DINV_08_INVITE_SEND_FAILED",
	INVITE_REQUEST_REJECTED = "DINV_07_INVITE_REQUEST_REJECTED",
	PRESENCE_UPDATE_FAILED = "DINV_06_PRESENCE_UPDATE_FAILED",
	PRESENCE_REQUEST_REJECTED = "DINV_05_PRESENCE_REQUEST_REJECTED",
	DISCORD_INVITE_TIMEOUT = "DISCORD_INVITE_TIMEOUT",
	CONTEXT_DATA_INVALID = "DINV_04_CONTEXT_DATA_INVALID",
	PENDING_INVITE_PRESENCE_ERROR = "DINV_12_PENDING_INVITE_PRESENCE_ERROR"
}
DiscordFriendService.INVITE_TIMEOUT_SECONDS = 10
DiscordFriendService.FRIEND_INVITE_PRESENCE_TIMEOUT_SECONDS = 60
DiscordFriendService.TEAM_INVITE_PRESENCE_TIMEOUT_SECONDS = 300
DiscordFriendService.INVITE_FLOW_ERROR_KEY = "DISCORD_INVITE_FLOW_ERROR"
DiscordFriendService.pendingDiscordInvite = nil
DiscordFriendService.pendingDiscordInviteTimerId = nil
DiscordFriendService.publishedInvitePresence = nil
DiscordFriendService.publishedInvitePresenceTimerId = nil
DiscordFriendService.discordInviteCooldownExpireAt = 0

function DiscordFriendService.showDiscordInviteFailedTip(errorCode, errorDetail)
	logger:warn("Discord invite flow error code=%s detail=%s", tostring(errorCode or "DINV_UNKNOWN"), tostring(errorDetail or ""))

	local tipKey = DiscordFriendService.INVITE_FLOW_ERROR_KEY

	if errorCode == DiscordFriendService.INVITE_ERROR_CODE.DISCORD_INVITE_IN_PROGRESS or errorCode == DiscordFriendService.INVITE_ERROR_CODE.DISCORD_INVITE_TIMEOUT then
		tipKey = errorCode
	end

	pg.global.ui.tips:showTextTip(pg.getGameString(tipKey))
end

function DiscordFriendService.onDiscordActivityJoin(joinSecret)
	if string.isNilOrEmpty(joinSecret) then
		DiscordFriendService.showDiscordInviteFailedTip(DiscordFriendService.INVITE_ERROR_CODE.JOIN_SECRET_EMPTY)

		return
	end

	pg.me:serverMsg("RPC_CS_AcceptDiscordActivityInvite", joinSecret)
end

function DiscordFriendService.canInviteDiscordFriendToTeam()
	if not DiscordSocialUtils.isReady() then
		DiscordFriendService.showDiscordInviteFailedTip(DiscordFriendService.INVITE_ERROR_CODE.DISCORD_NOT_READY)

		return false
	end

	if not pg.me:checkFunctionUnlock(Const.FUNCTION_NAME.TEAM) then
		pg.global.ui.tips:showTextTip(pg.getLocalizationText(FuncIdConfigData[Const.FUNCTION_NAME.TEAM].unlockDesc))

		return false
	end

	if not pg.me:isMatchStatusInit() then
		pg.global.ui.tips:showTextTip(pg.getGameString("MATCHING_TEAM_INVITE_TIP"))

		return false
	end

	if not pg.me:isInTeam() then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_ERROR_NOT_IN_TEAM"))

		return false
	end

	if not pg.me:isTeamLeader() then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAMP_MEMBER_MEET_INVITE_TIP"))

		return false
	end

	if pg.me:isInTeam() and pg.me:isTeamFull() then
		pg.global.ui.tips:showTextTip(pg.getGameString("SELF_TEAM_FULL"))

		return false
	end

	return true
end

function DiscordFriendService.inviteDiscordFriendToTeam(playerInfo)
	if not DiscordFriendService.canInviteDiscordFriendToTeam() then
		return
	end

	DiscordFriendService.requestDiscordActivityInvite(playerInfo, Const.DiscordInviteType.TeamInvite)
end

function DiscordFriendService.inviteDiscordFriendToAddFriend(playerInfo)
	DiscordFriendService.requestDiscordActivityInvite(playerInfo, Const.DiscordInviteType.FriendInvite)
end

function DiscordFriendService.requestDiscordActivityShare(inviteType)
	local discordUserId = pg.global.sdkManager:getSocialBindId("discord")

	DiscordFriendService.requestDiscordActivityInvite({
		discordUserId = discordUserId
	}, inviteType, true)
end

function DiscordFriendService.requestDiscordActivityInvite(playerInfo, inviteType, presenceShare)
	if DiscordFriendService.pendingDiscordInvite then
		DiscordFriendService.showDiscordInviteFailedTip(DiscordFriendService.INVITE_ERROR_CODE.DISCORD_INVITE_IN_PROGRESS, DiscordFriendService.pendingDiscordInvite.stage)

		return
	end

	local currentTime = os.time()

	if currentTime < DiscordFriendService.discordInviteCooldownExpireAt then
		DiscordFriendService.showDiscordInviteFailedTip(DiscordFriendService.INVITE_ERROR_CODE.DISCORD_INVITE_IN_PROGRESS, "cooldown")

		return
	end

	if not DiscordSocialUtils.isReady() then
		DiscordFriendService.showDiscordInviteFailedTip(DiscordFriendService.INVITE_ERROR_CODE.DISCORD_NOT_READY)

		return
	end

	local targetUserId = tostring(playerInfo and playerInfo.discordUserId or "")

	if string.isNilOrEmpty(targetUserId) then
		DiscordFriendService.showDiscordInviteFailedTip(DiscordFriendService.INVITE_ERROR_CODE.TARGET_USER_ID_EMPTY)

		return
	end

	local stateText = inviteType == Const.DiscordInviteType.TeamInvite and pg.getGameString("DISCORD_TEAM_INVITE_TIPS") or pg.getGameString("DISCORD_FRIEND_INVITE_TIPS")
	local inviteMessage = inviteType == Const.DiscordInviteType.TeamInvite and pg.getGameString("DISCORD_TEAM_INVITE_TIPS") or pg.getGameString("DISCORD_FRIEND_INVITE_TIPS")

	DiscordFriendService.pendingDiscordInvite = {
		stage = "requesting_context",
		targetUserId = targetUserId,
		inviteType = inviteType,
		stateText = stateText,
		inviteMessage = inviteMessage,
		presenceShare = presenceShare == true
	}
	DiscordFriendService.discordInviteCooldownExpireAt = currentTime + DiscordFriendService.INVITE_TIMEOUT_SECONDS

	DiscordFriendService.startPendingDiscordInviteTimeout()
	pg.me:serverMsg("RPC_CS_CreateDiscordActivityInvite", inviteType, targetUserId)
end

function DiscordFriendService.onDiscordActivityInviteCreated(success, joinSecret, partyId, currentPartySize, maxPartySize, inviteType, targetDiscordUserId)
	local pendingInvite = DiscordFriendService.pendingDiscordInvite

	if not pendingInvite then
		logger:warn("Discord activity invite context result dropped: no pending invite")

		return
	end

	local responseTargetUserId = tostring(targetDiscordUserId or "")

	if inviteType ~= pendingInvite.inviteType or responseTargetUserId ~= pendingInvite.targetUserId then
		logger:warn("Discord activity invite context result dropped: request mismatch inviteType=%s targetUserId=%s", tostring(inviteType), responseTargetUserId)

		return
	end

	if pendingInvite.stage ~= "requesting_context" then
		logger:warn("Discord activity invite context result dropped: invalid stage=%s inviteType=%s targetUserId=%s", tostring(pendingInvite.stage), tostring(inviteType), responseTargetUserId)

		return
	end

	if success ~= true then
		DiscordFriendService.failPendingInviteRequest()
		DiscordFriendService.showDiscordInviteFailedTip(DiscordFriendService.INVITE_ERROR_CODE.CREATE_CONTEXT_FAILED)

		return
	end

	if string.isNilOrEmpty(joinSecret) or string.isNilOrEmpty(partyId) or tonumber(maxPartySize or 0) <= 0 then
		DiscordFriendService.failPendingInviteRequest()
		DiscordFriendService.showDiscordInviteFailedTip(DiscordFriendService.INVITE_ERROR_CODE.CONTEXT_DATA_INVALID)

		return
	end

	pendingInvite.joinSecret = joinSecret
	pendingInvite.partyId = partyId
	pendingInvite.currentPartySize = math.max(1, tonumber(currentPartySize or 1))
	pendingInvite.maxPartySize = math.max(1, tonumber(maxPartySize))
	pendingInvite.details = tostring(pg.me.playerName or "")
	pendingInvite.stage = "updating_presence"

	local updateSent = DiscordSocialUtils.updateRichPresence(pendingInvite.stateText, pendingInvite.details, pendingInvite.joinSecret, pendingInvite.currentPartySize, pendingInvite.maxPartySize, pendingInvite.partyId)

	if not updateSent then
		DiscordFriendService.failPendingInviteRequest()
		DiscordFriendService.showDiscordInviteFailedTip(DiscordFriendService.INVITE_ERROR_CODE.PRESENCE_REQUEST_REJECTED)

		return
	end
end

function DiscordFriendService.onDiscordRichPresenceUpdated(result)
	local pendingInvite = DiscordFriendService.pendingDiscordInvite

	if not pendingInvite or pendingInvite.stage ~= "updating_presence" then
		return
	end

	if type(result) ~= "table" or result.success ~= true then
		DiscordFriendService.failPendingInviteRequest()
		DiscordFriendService.showDiscordInviteFailedTip(DiscordFriendService.INVITE_ERROR_CODE.PRESENCE_UPDATE_FAILED, type(result) == "table" and result.errorMessage or "")

		return
	end

	DiscordFriendService.setPublishedInvitePresence(pendingInvite)

	if pendingInvite.presenceShare then
		DiscordFriendService.finishPendingInviteRequest()
		pg.global.ui.tips:showTextTip(pg.getGameString("DISCORD_SHARE_TIPS"))

		return
	end

	pendingInvite.stage = "sending_invite"

	local inviteSent = DiscordSocialUtils.sendInvite(pendingInvite.targetUserId, pendingInvite.inviteMessage)

	if not inviteSent then
		DiscordFriendService.clearPublishedInvitePresence()
		DiscordFriendService.failPendingInviteRequest()
		DiscordFriendService.showDiscordInviteFailedTip(DiscordFriendService.INVITE_ERROR_CODE.INVITE_REQUEST_REJECTED)
	end
end

function DiscordFriendService.onDiscordInviteSent(result)
	local pendingInvite = DiscordFriendService.pendingDiscordInvite

	if not pendingInvite or type(result) ~= "table" or tostring(result.targetUserId or "") ~= pendingInvite.targetUserId then
		return
	end

	if result.success == true then
		DiscordFriendService.finishPendingInviteRequest()
		pg.global.ui.tips:showTextTip(pg.getGameString("SEND_INVITE_SUCCESS"))

		return
	end

	DiscordFriendService.clearPublishedInvitePresence()
	DiscordFriendService.failPendingInviteRequest()
	DiscordFriendService.showDiscordInviteFailedTip(DiscordFriendService.INVITE_ERROR_CODE.INVITE_SEND_FAILED, result.errorMessage)
end

function DiscordFriendService.startPendingDiscordInviteTimeout()
	if DiscordFriendService.pendingDiscordInviteTimerId then
		TimerManager.removeTimer(DiscordFriendService.pendingDiscordInviteTimerId)
	end

	local pendingInvite = DiscordFriendService.pendingDiscordInvite

	DiscordFriendService.pendingDiscordInviteTimerId = TimerManager.addTimer(DiscordFriendService.INVITE_TIMEOUT_SECONDS, function()
		DiscordFriendService.onPendingDiscordInviteTimeout(pendingInvite)
	end)
end

function DiscordFriendService.onPendingDiscordInviteTimeout(pendingInvite)
	if DiscordFriendService.pendingDiscordInvite ~= pendingInvite then
		return
	end

	DiscordFriendService.pendingDiscordInviteTimerId = nil

	logger:warn("Discord activity invite timeout stage=%s targetUserId=%s inviteType=%s", tostring(pendingInvite.stage or ""), tostring(pendingInvite.targetUserId or ""), tostring(pendingInvite.inviteType or ""))

	if pendingInvite.stage == "updating_presence" or pendingInvite.stage == "sending_invite" then
		DiscordFriendService.clearPublishedInvitePresence()
	end

	DiscordFriendService.failPendingInviteRequest()
	DiscordFriendService.showDiscordInviteFailedTip(DiscordFriendService.INVITE_ERROR_CODE.DISCORD_INVITE_TIMEOUT, pendingInvite.stage)
end

function DiscordFriendService.finishPendingInviteRequest()
	if DiscordFriendService.pendingDiscordInviteTimerId then
		TimerManager.removeTimer(DiscordFriendService.pendingDiscordInviteTimerId)

		DiscordFriendService.pendingDiscordInviteTimerId = nil
	end

	DiscordFriendService.pendingDiscordInvite = nil
end

function DiscordFriendService.failPendingInviteRequest()
	DiscordFriendService.finishPendingInviteRequest()

	DiscordFriendService.discordInviteCooldownExpireAt = 0
end

function DiscordFriendService.setPublishedInvitePresence(invite)
	DiscordFriendService.clearPublishedInvitePresenceRecord()

	local publishedPresence = {
		inviteType = invite.inviteType,
		stateText = invite.stateText,
		details = invite.details,
		joinSecret = invite.joinSecret,
		partyId = invite.partyId,
		currentPartySize = invite.currentPartySize,
		maxPartySize = invite.maxPartySize,
		expireAt = invite.expireAt,
		presenceShare = invite.presenceShare
	}

	DiscordFriendService.publishedInvitePresence = publishedPresence

	local timeoutSeconds = invite.expireAt and invite.expireAt - os.time() or nil

	if invite.inviteType == Const.DiscordInviteType.FriendInvite then
		timeoutSeconds = DiscordFriendService.FRIEND_INVITE_PRESENCE_TIMEOUT_SECONDS
	elseif invite.inviteType == Const.DiscordInviteType.TeamInvite then
		timeoutSeconds = DiscordFriendService.TEAM_INVITE_PRESENCE_TIMEOUT_SECONDS
	end

	if timeoutSeconds and timeoutSeconds > 0 then
		DiscordFriendService.publishedInvitePresenceTimerId = TimerManager.addTimer(timeoutSeconds, function()
			if DiscordFriendService.publishedInvitePresence == publishedPresence then
				DiscordFriendService.publishedInvitePresenceTimerId = nil

				DiscordFriendService.clearPublishedInvitePresence()
			end
		end)
	end
end

function DiscordFriendService.clearPublishedInvitePresenceRecord()
	if DiscordFriendService.publishedInvitePresenceTimerId then
		TimerManager.removeTimer(DiscordFriendService.publishedInvitePresenceTimerId)

		DiscordFriendService.publishedInvitePresenceTimerId = nil
	end

	DiscordFriendService.publishedInvitePresence = nil
end

function DiscordFriendService.clearPublishedInvitePresence()
	local pendingInvite = DiscordFriendService.pendingDiscordInvite
	local shouldClearPresence = DiscordFriendService.publishedInvitePresence ~= nil or pendingInvite and (pendingInvite.stage == "updating_presence" or pendingInvite.stage == "sending_invite")

	DiscordFriendService.clearPublishedInvitePresenceRecord()

	if shouldClearPresence then
		DiscordSocialUtils.clearRichPresence()
	end
end

function DiscordFriendService.stopDiscordInviteFlow()
	DiscordFriendService.clearPublishedInvitePresence()
	DiscordFriendService.failPendingInviteRequest()
end

function DiscordFriendService.onLeaveTeam()
	local pendingInvite = DiscordFriendService.pendingDiscordInvite
	local publishedPresence = DiscordFriendService.publishedInvitePresence
	local hasPendingTeamInvite = pendingInvite and pendingInvite.inviteType == Const.DiscordInviteType.TeamInvite
	local hasPublishedTeamPresence = publishedPresence and publishedPresence.inviteType == Const.DiscordInviteType.TeamInvite

	if not hasPendingTeamInvite and not hasPublishedTeamPresence then
		return
	end

	logger:info("Discord team invite context invalidated: leave team")

	local shouldClearPresence = hasPublishedTeamPresence or hasPendingTeamInvite and (pendingInvite.stage == "updating_presence" or pendingInvite.stage == "sending_invite")

	if shouldClearPresence then
		DiscordFriendService.clearPublishedInvitePresence()
	end

	if hasPendingTeamInvite then
		DiscordFriendService.failPendingInviteRequest()
	end
end

function DiscordFriendService.onTeamInfoChanged(teamComponent)
	if teamComponent and teamComponent:isInTeam() and not teamComponent:isTeamLeader() then
		DiscordFriendService.onLeaveTeam()

		return
	end

	local pendingInvite = DiscordFriendService.pendingDiscordInvite

	if pendingInvite then
		return
	end

	local publishedPresence = DiscordFriendService.publishedInvitePresence
	local invitePresence = publishedPresence and publishedPresence.inviteType == Const.DiscordInviteType.TeamInvite and publishedPresence or nil

	if not invitePresence or string.isNilOrEmpty(invitePresence.joinSecret) then
		return
	end

	local teamInfo = teamComponent and teamComponent:getCurTeamInfo() or nil
	local partyId = tostring(teamInfo and teamInfo.teamId or "")

	if string.isNilOrEmpty(partyId) or partyId ~= tostring(invitePresence.partyId or "") then
		DiscordFriendService.onLeaveTeam()

		return
	end

	local currentPartySize = math.max(1, teamComponent:getTeamMemberCount(true))
	local maxPartySize = math.max(currentPartySize, tonumber(invitePresence.maxPartySize) or Const.TEAM_BASE.MAX_PLAYER_NUM)

	invitePresence.currentPartySize = currentPartySize

	local updateSent = DiscordSocialUtils.updateRichPresenceEx(invitePresence.stateText, invitePresence.details, invitePresence.joinSecret, currentPartySize, maxPartySize, {
		partyId = partyId
	})

	if not updateSent then
		logger:warn("Discord team invite presence sync rejected partyId=%s currentPartySize=%s maxPartySize=%s", partyId, tostring(currentPartySize), tostring(maxPartySize))
	end
end

return DiscordFriendService
