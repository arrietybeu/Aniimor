-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformShellActivityService.lua

local logger = require("SDK.Platform.PlatformLogger")
local Const = require("Common.Const.Const")
local MatchConst = require("Common.Const.MatchConst")
local CommonSwitch = require("Common.CommonSwitch")
local IDManager = require("Core.Common.IDManager")
local SysConfigData = require("Data.sys_config_data")
local TimerManager = require("Core.Timer.TimerManager")
local PlatformShellTokenUtils = require("SDK.Platform.PlatformShellTokenUtils")
local PlatformInviteTokenService = require("SDK.Platform.PlatformInviteTokenService")
local PlatformShellConst = require("Common.Const.PlatformShellConst")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local PlatformShellActivityService = {}

PlatformShellActivityService.DEFAULT_JOIN_RESTRICTION = "public"
PlatformShellActivityService.NOT_JOINABLE_RESTRICTION = "invite_only"
PlatformShellActivityService.DEFAULT_CURRENT_PLAYERS = 1
PlatformShellActivityService.DEFAULT_MAX_PLAYERS = 4
PlatformShellActivityService.TOKEN_TYPE_ACTIVITY = PlatformShellConst.TokenType.JoinGameByShell
PlatformShellActivityService.ACTIVITY_TARGET_KEY = "open"
PlatformShellActivityService.ACTIVITY_TOKEN_FRESH_MARGIN = 30
PlatformShellActivityService.state = {
	suspendedWithActivity = false,
	platformJoinTokenRefreshing = false,
	activityInviteId = "",
	pendingPublish = false,
	published = false,
	publishSeq = 0,
	ownerUserId = "",
	initialized = false,
	lastActivitySourceReason = "",
	lastActivityToken = ""
}

function PlatformShellActivityService.isPlatformSupported()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.IsSupported and PlatformBridgeLuaFacade.IsSupported() == true
end

function PlatformShellActivityService.supportsMultiplayerActivity()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.SupportsMultiplayerActivity and PlatformBridgeLuaFacade.SupportsMultiplayerActivity() == true
end

function PlatformShellActivityService.isRuntimeReady()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.IsRuntimeInitialized and PlatformBridgeLuaFacade.IsRuntimeInitialized() == true
end

function PlatformShellActivityService.isPlayStationPlatform()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.GetPlatformFamily and PlatformBridgeLuaFacade.GetPlatformFamily() == "playstation"
end

function PlatformShellActivityService.getSignedInUserId()
	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.GetSignedInUserId then
		return ""
	end

	local userId = PlatformBridgeLuaFacade.GetSignedInUserId()

	if string.isNilOrEmpty(userId) then
		return ""
	end

	return tostring(userId)
end

function PlatformShellActivityService.cancelRepublishTimer()
	if PlatformShellActivityService.state.republishTimerId then
		TimerManager.removeTimer(PlatformShellActivityService.state.republishTimerId)

		PlatformShellActivityService.state.republishTimerId = nil
	end
end

function PlatformShellActivityService.clearCachedActivityToken()
	PlatformShellActivityService.state.lastActivityToken = ""
	PlatformShellActivityService.state.lastActivitySourceReason = ""
end

function PlatformShellActivityService.clearActivityInviteId()
	PlatformShellActivityService.state.activityInviteId = ""
end

function PlatformShellActivityService.getActivityTokenTtl()
	return tonumber(SysConfigData and SysConfigData.TEAM_TOKEN_EXPIREDTIME or 0) or 0
end

function PlatformShellActivityService.getActivityRepublishInterval()
	local ttl = PlatformShellActivityService.getActivityTokenTtl()

	if ttl > PlatformShellActivityService.ACTIVITY_TOKEN_FRESH_MARGIN then
		return ttl - PlatformShellActivityService.ACTIVITY_TOKEN_FRESH_MARGIN
	end

	return math.max(1, math.floor(ttl / 2))
end

function PlatformShellActivityService.ensureRepublishTimerInternal()
	if PlatformShellActivityService.state.republishTimerId then
		return
	end

	PlatformShellActivityService.state.republishTimerId = TimerManager.addRepeatTimer(PlatformShellActivityService.getActivityRepublishInterval(), function()
		PlatformShellActivityService.publishCurrentActivity("mpa_activity_token_renew", true, {
			forceRenewToken = true
		})
	end)
end

function PlatformShellActivityService.resetState(clearOwner)
	PlatformShellActivityService.state.publishSeq = PlatformShellActivityService.state.publishSeq + 1
	PlatformShellActivityService.state.published = false
	PlatformShellActivityService.state.pendingPublish = false

	PlatformShellActivityService.clearActivityInviteId()

	PlatformShellActivityService.state.platformJoinTokenRefreshing = false
	PlatformShellActivityService.state.suspendedWithActivity = false

	PlatformShellActivityService.cancelRepublishTimer()
	PlatformShellActivityService.clearCachedActivityToken()

	if clearOwner ~= false then
		PlatformShellActivityService.state.ownerUserId = ""
	end
end

function PlatformShellActivityService.resetLocalStateAfterShutdown()
	PlatformShellActivityService.state.published = false
	PlatformShellActivityService.state.pendingPublish = false

	PlatformShellActivityService.clearActivityInviteId()

	PlatformShellActivityService.state.platformJoinTokenRefreshing = false
	PlatformShellActivityService.state.suspendedWithActivity = false

	PlatformShellActivityService.cancelRepublishTimer()
	PlatformShellActivityService.clearCachedActivityToken()

	PlatformShellActivityService.state.ownerUserId = ""
end

function PlatformShellActivityService.bindSignedInUser()
	local ownerUserId = PlatformShellActivityService.getSignedInUserId()

	if string.isNilOrEmpty(ownerUserId) then
		PlatformShellActivityService.resetState()

		return false
	end

	if PlatformShellActivityService.state.ownerUserId ~= ownerUserId then
		local hasPreviousOwner = not string.isNilOrEmpty(PlatformShellActivityService.state.ownerUserId)

		if hasPreviousOwner then
			PlatformInviteTokenService:clear(PlatformShellActivityService.TOKEN_TYPE_ACTIVITY, PlatformShellActivityService.ACTIVITY_TARGET_KEY)
		end

		PlatformShellActivityService.resetState(false)

		PlatformShellActivityService.state.ownerUserId = ownerUserId
	end

	return true
end

function PlatformShellActivityService.getMaxPlayers()
	local maxPlayers = tonumber(SysConfigData.MAX_PLAYER_NUM or 0) or 0

	if maxPlayers > 0 then
		return maxPlayers
	end

	local teamBase = Const.TEAM_BASE or {}

	return tonumber(teamBase.MAX_PLAYER_NUM or 0) or 0
end

function PlatformShellActivityService.getResolvedMaxPlayers()
	local maxPlayers = PlatformShellActivityService.getMaxPlayers()

	if maxPlayers > 0 then
		return maxPlayers
	end

	return PlatformShellActivityService.DEFAULT_MAX_PLAYERS
end

function PlatformShellActivityService.normalizeCurrentPlayers(currentPlayers, maxPlayers)
	local resolvedCurrentPlayers = tonumber(currentPlayers or 0) or 0
	local resolvedMaxPlayers = tonumber(maxPlayers or 0) or PlatformShellActivityService.DEFAULT_MAX_PLAYERS

	if resolvedMaxPlayers < 1 then
		resolvedMaxPlayers = PlatformShellActivityService.DEFAULT_MAX_PLAYERS
	end

	if resolvedCurrentPlayers < 1 then
		resolvedCurrentPlayers = PlatformShellActivityService.DEFAULT_CURRENT_PLAYERS
	end

	if resolvedMaxPlayers < resolvedCurrentPlayers then
		resolvedCurrentPlayers = resolvedMaxPlayers
	end

	return resolvedCurrentPlayers, resolvedMaxPlayers
end

function PlatformShellActivityService.getSelfUid()
	return tostring(pg and pg.me and pg.me.uid or "")
end

function PlatformShellActivityService.isGameUserServerReady()
	local me = pg and pg.me

	return me ~= nil and not string.isNilOrEmpty(PlatformShellActivityService.getSelfUid()) and type(me.serverMsg) == "function" and me.server ~= nil and me.server ~= false
end

function PlatformShellActivityService.getTeamInfo()
	return pg and pg.me and pg.me.teamInfo or nil
end

function PlatformShellActivityService.isValidTeamInfo(teamInfo)
	return type(teamInfo) == "table" and not string.isNilOrEmpty(teamInfo.teamId)
end

function PlatformShellActivityService.countMembers(teamInfo)
	local count = 0
	local membersInfo = teamInfo and teamInfo.membersInfo

	if type(membersInfo) ~= "table" then
		return 0
	end

	for _, _ in pairs(membersInfo) do
		count = count + 1
	end

	return count
end

function PlatformShellActivityService.isSelfInTeam()
	local me = pg and pg.me

	if me and type(me.isInTeam) == "function" then
		return me:isInTeam() == true
	end

	return PlatformShellActivityService.isValidTeamInfo(PlatformShellActivityService.getTeamInfo())
end

function PlatformShellActivityService.isSelfTeamLeader()
	local me = pg and pg.me

	if me and type(me.isTeamLeader) == "function" then
		return me:isTeamLeader() == true
	end

	local teamInfo = PlatformShellActivityService.getTeamInfo()

	if not teamInfo then
		logger:warn("isSelfTeamLeader failed not teamInfo")

		return false
	end

	return PlatformShellActivityService.isValidTeamInfo(teamInfo) and PlatformShellActivityService.getSelfUid() == tostring(teamInfo.leaderUid or "")
end

function PlatformShellActivityService.isConsoleMatchStatusInit(player)
	return player ~= nil and player.isGuidancePlayer ~= true and player.matchStatus == MatchConst.MATCH_STATUS_INIT and type(player.isMatchStatusInit) == "function" and player:isMatchStatusInit()
end

function PlatformShellActivityService.resolveActivityJoinState()
	local me = pg and pg.me

	if not me or type(me.checkFunctionUnlock) ~= "function" or me:checkFunctionUnlock(Const.FUNCTION_NAME.TEAM) ~= true or CommonSwitch[Const.FUNCTION_NAME.TEAM] == false then
		return false, "team_function_locked"
	end

	if not PlatformShellActivityService.isConsoleMatchStatusInit(me) then
		return false, "match_status_not_idle"
	end

	if PlatformShellActivityService.isSelfInTeam() and not PlatformShellActivityService.isSelfTeamLeader() then
		return false, "not_team_leader"
	end

	return true, "joinable"
end

function PlatformShellActivityService.canAllowCrossPlatformJoin()
	return true
end

function PlatformShellActivityService.getActivityInviteId()
	if string.isNilOrEmpty(PlatformShellActivityService.state.activityInviteId) then
		PlatformShellActivityService.state.activityInviteId = IDManager.genStrID()
	end

	return PlatformShellActivityService.state.activityInviteId
end

function PlatformShellActivityService.buildCurrentActivity(platformJoinToken)
	platformJoinToken = tostring(platformJoinToken or "")

	if string.isNilOrEmpty(platformJoinToken) then
		return nil
	end

	local teamInfo = PlatformShellActivityService.getTeamInfo()
	local memberCount = PlatformShellActivityService.isValidTeamInfo(teamInfo) and PlatformShellActivityService.countMembers(teamInfo) or PlatformShellActivityService.DEFAULT_CURRENT_PLAYERS
	local currentPlayers, maxPlayers = PlatformShellActivityService.normalizeCurrentPlayers(memberCount, PlatformShellActivityService.getResolvedMaxPlayers())
	local joinable, joinUnavailableReason = PlatformShellActivityService.resolveActivityJoinState()
	local connectionString = PlatformShellTokenUtils.buildConnectionString(PlatformShellTokenUtils.TokenType.JoinGameByShell, {
		inviteId = PlatformShellActivityService.getActivityInviteId(),
		inviterPlatformUserId = PlatformShellActivityService.state.ownerUserId,
		inviterGameUid = PlatformShellActivityService.getSelfUid(),
		inviteToken = platformJoinToken,
		targetKey = PlatformShellActivityService.ACTIVITY_TARGET_KEY
	})

	return {
		groupId = "",
		connectionString = connectionString,
		currentPlayers = currentPlayers,
		maxPlayers = maxPlayers,
		allowCrossPlatformJoin = PlatformShellActivityService.canAllowCrossPlatformJoin(),
		joinRestriction = joinable and PlatformShellActivityService.DEFAULT_JOIN_RESTRICTION or PlatformShellActivityService.NOT_JOINABLE_RESTRICTION,
		joinable = joinable,
		joinUnavailableReason = joinUnavailableReason
	}
end

function PlatformShellActivityService.publishActivityDirect(activity, sourceReason, publishSeq, platformJoinToken)
	PlatformBridgeLuaFacade.SetMultiplayerActivity(activity.connectionString, activity.currentPlayers, activity.maxPlayers, activity.groupId, activity.allowCrossPlatformJoin, activity.joinRestriction, 0, function(success, result, message)
		if publishSeq ~= PlatformShellActivityService.state.publishSeq then
			return
		end

		PlatformShellActivityService.state.pendingPublish = false

		if success then
			PlatformShellActivityService.state.published = true
			PlatformShellActivityService.state.lastActivityToken = tostring(platformJoinToken or "")
			PlatformShellActivityService.state.lastActivitySourceReason = tostring(sourceReason or "")

			logger:info("SetMultiplayerActivity succeeded sourceReason=%s currentPlayers=%s maxPlayers=%s groupId=%s allowCrossPlatformJoin=%s joinRestriction=%s joinable=%s joinReason=%s connectionStringLen=%s", tostring(sourceReason), tostring(activity.currentPlayers), tostring(activity.maxPlayers), tostring(activity.groupId), tostring(activity.allowCrossPlatformJoin == true), tostring(activity.joinRestriction), tostring(activity.joinable == true), tostring(activity.joinUnavailableReason), tostring(string.len(tostring(activity.connectionString or ""))))

			return
		end

		PlatformShellActivityService.state.published = false

		PlatformShellActivityService.clearCachedActivityToken()
		logger:warn("SetMultiplayerActivity failed sourceReason=%s result=%s message=%s", tostring(sourceReason), tostring(result), tostring(message))
	end)
end

function PlatformShellActivityService.clearActivity(sourceReason, forceClear)
	local hasActivityToClear = PlatformShellActivityService.state.published or PlatformShellActivityService.state.pendingPublish or forceClear == true

	PlatformShellActivityService.state.pendingPublish = false
	PlatformShellActivityService.state.publishSeq = PlatformShellActivityService.state.publishSeq + 1

	local clearSeq = PlatformShellActivityService.state.publishSeq

	PlatformShellActivityService.clearCachedActivityToken()
	PlatformShellActivityService.clearActivityInviteId()

	PlatformShellActivityService.state.platformJoinTokenRefreshing = false

	if not hasActivityToClear then
		PlatformShellActivityService.state.published = false

		return true
	end

	PlatformBridgeLuaFacade.ClearMultiplayerActivity(tostring(sourceReason or ""), 0, function(success, result, message)
		if clearSeq ~= PlatformShellActivityService.state.publishSeq then
			return
		end

		if success then
			PlatformShellActivityService.state.published = false

			return
		end

		logger:warn("ClearMultiplayerActivity failed sourceReason=%s result=%s message=%s", tostring(sourceReason), tostring(result), tostring(message))
	end)

	return true
end

function PlatformShellActivityService.isTokenRequestFailed(errCode)
	return errCode ~= nil and errCode ~= PlatformInviteTokenService.ErrorCode.SUCCESS
end

function PlatformShellActivityService.shouldSkipActivityPublishForTeamMember()
	return PlatformShellActivityService.isPlayStationPlatform() and PlatformShellActivityService.isSelfInTeam() and not PlatformShellActivityService.isSelfTeamLeader()
end

function PlatformShellActivityService.clearActivityForNonLeader(sourceReason)
	PlatformShellActivityService.clearActivity(tostring(sourceReason or "team_member_not_leader"), true)
end

function PlatformShellActivityService.publishCurrentActivity(sourceReason, logInitFailure, options)
	options = options or {}
	sourceReason = sourceReason or "team_activity_refresh"

	if not PlatformShellActivityService:init() then
		if logInitFailure then
			logger:warn("MultiplayerActivity refresh skipped reason=init_failed sourceReason=%s supported=%s runtimeReady=%s", tostring(sourceReason), tostring(PlatformShellActivityService:isSupported()), tostring(PlatformShellActivityService.isRuntimeReady()))
		end

		return false
	end

	if not PlatformShellActivityService.isRuntimeReady() or not PlatformShellActivityService.bindSignedInUser() or not PlatformShellActivityService.isGameUserServerReady() then
		PlatformShellActivityService.clearActivity("game_user_not_ready")

		return false
	end

	if PlatformShellActivityService.shouldSkipActivityPublishForTeamMember() then
		PlatformShellActivityService.clearActivityForNonLeader(sourceReason .. "_not_team_leader")
		logger:info("MultiplayerActivity publish skipped reason=not_team_leader sourceReason=%s", tostring(sourceReason))

		return false
	end

	if PlatformShellActivityService.state.platformJoinTokenRefreshing then
		return PlatformShellActivityService.state.published or PlatformShellActivityService.state.pendingPublish
	end

	if options.reuseCachedActivityToken == true and options.forceRenewToken ~= true then
		local token = PlatformShellActivityService.state.lastActivityToken

		if string.isNilOrEmpty(token) and PlatformInviteTokenService.getToken then
			token = PlatformInviteTokenService:getToken(PlatformShellActivityService.TOKEN_TYPE_ACTIVITY, PlatformShellActivityService.ACTIVITY_TARGET_KEY)
		end

		if not string.isNilOrEmpty(token) and PlatformShellActivityService.isRuntimeReady() and PlatformShellActivityService.bindSignedInUser() then
			PlatformShellActivityService.state.pendingPublish = true
			PlatformShellActivityService.state.publishSeq = PlatformShellActivityService.state.publishSeq + 1

			local publishSeq = PlatformShellActivityService.state.publishSeq
			local activity = PlatformShellActivityService.buildCurrentActivity(token)

			if activity then
				PlatformShellActivityService.publishActivityDirect(activity, sourceReason, publishSeq, token)

				return true
			end

			PlatformShellActivityService.state.pendingPublish = false
		end
	end

	PlatformShellActivityService.state.platformJoinTokenRefreshing = true
	PlatformShellActivityService.state.pendingPublish = true
	PlatformShellActivityService.state.publishSeq = PlatformShellActivityService.state.publishSeq + 1

	local publishSeq = PlatformShellActivityService.state.publishSeq

	PlatformInviteTokenService:ensureToken(PlatformShellActivityService.TOKEN_TYPE_ACTIVITY, PlatformShellActivityService.ACTIVITY_TARGET_KEY, function(token, errCode)
		if publishSeq ~= PlatformShellActivityService.state.publishSeq then
			return
		end

		PlatformShellActivityService.state.platformJoinTokenRefreshing = false

		if PlatformShellActivityService.isTokenRequestFailed(errCode) or string.isNilOrEmpty(token) then
			PlatformShellActivityService.state.pendingPublish = false

			logger:warn("MultiplayerActivity token request failed tokenType=%s targetKey=%s sourceReason=%s errCode=%s hasLastToken=%s", tostring(PlatformShellActivityService.TOKEN_TYPE_ACTIVITY), tostring(PlatformShellActivityService.ACTIVITY_TARGET_KEY), tostring(sourceReason), tostring(errCode or "empty_token"), tostring(not string.isNilOrEmpty(PlatformShellActivityService.state.lastActivityToken)))

			return
		end

		if not PlatformShellActivityService.isRuntimeReady() or not PlatformShellActivityService.bindSignedInUser() or not PlatformShellActivityService.isGameUserServerReady() then
			if publishSeq == PlatformShellActivityService.state.publishSeq then
				PlatformShellActivityService.state.pendingPublish = false
			end

			PlatformShellActivityService.clearCachedActivityToken()
			logger:warn("MultiplayerActivity publish skipped reason=runtime_not_ready sourceReason=%s", tostring(sourceReason))

			return
		end

		if publishSeq ~= PlatformShellActivityService.state.publishSeq then
			return
		end

		if PlatformShellActivityService.shouldSkipActivityPublishForTeamMember() then
			PlatformShellActivityService.state.pendingPublish = false

			PlatformShellActivityService.clearActivityForNonLeader(sourceReason .. "_not_team_leader")
			logger:info("MultiplayerActivity publish skipped after token reason=not_team_leader sourceReason=%s", tostring(sourceReason))

			return
		end

		local activity = PlatformShellActivityService.buildCurrentActivity(token)

		if not activity then
			PlatformShellActivityService.state.pendingPublish = false

			PlatformShellActivityService.clearCachedActivityToken()
			logger:warn("MultiplayerActivity publish skipped reason=missing_platform_join_token sourceReason=%s", tostring(sourceReason))

			return
		end

		PlatformShellActivityService.publishActivityDirect(activity, sourceReason, publishSeq, token)
	end, options.forceRenewToken == true)

	return true
end

function PlatformShellActivityService:isSupported()
	return PlatformShellActivityService.isPlatformSupported() and PlatformShellActivityService.supportsMultiplayerActivity()
end

function PlatformShellActivityService:init(runtimeReady)
	if PlatformShellActivityService.state.initialized then
		return true
	end

	if not self:isSupported() then
		return false
	end

	if runtimeReady ~= true and not PlatformShellActivityService.isRuntimeReady() then
		return false
	end

	PlatformShellActivityService.state.initialized = true

	PlatformShellActivityService.bindSignedInUser()

	return true
end

function PlatformShellActivityService:shutdown()
	local hasActivityToClear = PlatformShellActivityService.state.published or PlatformShellActivityService.state.pendingPublish

	if hasActivityToClear and self:isSupported() and PlatformShellActivityService.isRuntimeReady() and not string.isNilOrEmpty(PlatformShellActivityService.state.ownerUserId) then
		PlatformShellActivityService.clearActivity("shutdown")
	end

	PlatformShellActivityService.state.initialized = false

	PlatformShellActivityService.resetLocalStateAfterShutdown()
end

function PlatformShellActivityService:clearCurrentActivity(sourceReason)
	if not PlatformShellActivityService.isPlayStationPlatform() or not self:isSupported() or not PlatformShellActivityService.isRuntimeReady() then
		return false
	end

	sourceReason = sourceReason or "clear_activity"

	local result = PlatformShellActivityService.clearActivity(sourceReason, true)

	if result and (not PlatformShellActivityService.isSelfInTeam() or PlatformShellActivityService.isSelfTeamLeader()) then
		PlatformShellActivityService.publishCurrentActivity("login_activity_after_clear", false, {
			forceRenewToken = true
		})
	end

	return result
end

function PlatformShellActivityService:publishLoginActivity()
	return PlatformShellActivityService.publishCurrentActivity("login_activity", false, {
		forceRenewToken = true
	})
end

function PlatformShellActivityService:ensureRepublishTimer()
	if not self:init() then
		return false
	end

	PlatformShellActivityService.ensureRepublishTimerInternal()

	return true
end

function PlatformShellActivityService:refreshCurrentTeamActivity(sourceReason)
	return PlatformShellActivityService.publishCurrentActivity(sourceReason or "team_activity_refresh", true)
end

function PlatformShellActivityService:recreateCurrentTeamActivity(sourceReason)
	if not PlatformShellActivityService.isPlayStationPlatform() or not self:isSupported() or not PlatformShellActivityService.isRuntimeReady() then
		return false
	end

	sourceReason = sourceReason or "team_activity_recreate"

	local result = PlatformShellActivityService.clearActivity(sourceReason, true)

	if result then
		PlatformShellActivityService.publishCurrentActivity(sourceReason, true, {
			forceRenewToken = true
		})
	end

	return result
end

function PlatformShellActivityService:onSuspend()
	PlatformShellActivityService.state.suspendedWithActivity = PlatformShellActivityService.state.published or PlatformShellActivityService.state.pendingPublish
end

function PlatformShellActivityService:onResume()
	PlatformShellActivityService.state.suspendedWithActivity = false
end

return PlatformShellActivityService
