-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\EntityMixin\\ImpPlatformClientTeamComponent.lua

local M = {}
local EventConst = require("Common.Const.EventConst")
local Const = require("Common.Const.Const")
local PlatformCommunicationService = require("SDK.Platform.PlatformCommunicationService")
local PlatformGameInviteFilterService = require("SDK.Platform.PlatformGameInviteFilterService")
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformShellInviteService = require("SDK.Platform.PlatformShellInviteService")
local PlatformRecentPlayerService = require("SDK.Platform.PlatformRecentPlayerService")
local PlatformInviteTokenService = require("SDK.Platform.PlatformInviteTokenService")
local PlatformShellActivityService = require("SDK.Platform.PlatformShellActivityService")
local PlatformShellJoinService = require("SDK.Platform.PlatformShellJoinService")
local PlatformShellConst = require("Common.Const.PlatformShellConst")
local PlatformPremiumFeatureService = require("SDK.Platform.PlatformPremiumFeatureService")
local PlatformCrossPlatformService = require("SDK.Platform.PlatformCrossPlatformService")
local PlatformHomeCampEntryFilterService = require("SDK.Platform.PlatformHomeCampEntryFilterService")
local PlatformSocialService = require("SDK.Platform.PlatformSocialService")
local NoticeDef = require("Common.NoticeDef")
local PlatformNoticeUtils = require("SDK.Platform.PlatformNoticeUtils")
local PlatformShellInviteDestinationQueryService = require("SDK.Platform.PlatformShellInviteDestinationQueryService")
local logger = require("SDK.Platform.PlatformLogger")

M.TEAM_JOIN_FAILED_NOTICE_IDS = {
	[NoticeDef.TEAM_MSG_TEAM_NOT_EXIST] = true,
	[NoticeDef.TEAM_MSG_DATA_ERROR] = true,
	[NoticeDef.TEAM_MSG_STATUS_NOT_NORMAL] = true,
	[NoticeDef.TEAM_MSG_MAX_PLAYER] = true,
	[NoticeDef.TEAM_MSG_NOT_IN_INVITE] = true,
	[NoticeDef.TEAM_MSG_PLAYER_MATCH_STATUS_NOT_INIT] = true,
	[NoticeDef.ERROR_REPEAT_JOIN_TEAM] = true,
	[NoticeDef.TEAM_REJECT_INVITE] = true,
	[NoticeDef.CROSS_PLATFORM_MISMATCH] = true,
	[NoticeDef.CROSS_PLATFORM_DISABLE_MATCHING] = true,
	[NoticeDef.CROSS_PLATFORM_DISABLE_TEAM] = true,
	[NoticeDef.CROSS_PLATFORM_DISABLE_WORLD] = true
}
M.lastKnownTeamLeaderUid = ""

function M.getPlatformRecentPlayerService()
	return PlatformRecentPlayerService
end

function M.shouldAllowInboundGameInvite(context)
	local allowed = PlatformGameInviteFilterService:shouldAllowInboundGameInvite(context)

	return allowed ~= false
end

function M.isPlatformBlockedSender(senderInfo)
	return PlatformSocialService:peekPlatformUserBlockedByLocalUser(senderInfo) == true
end

function M:isLocalConsoleInPreparingRoom()
	if self ~= pg.me then
		return false
	end

	if not PlatformIdentityUtils.isConsoleFamily(PlatformIdentityUtils.getCurrentPlatformFamily()) then
		return false
	end

	return type(self.isInPreparingRoom) == "function" and self:isInPreparingRoom() == true
end

function M.isVoicePolicyBlocked(policy)
	if type(policy) ~= "table" then
		return false
	end

	local Decision = PlatformCommunicationService.Decision or {}

	if policy.decision == Decision.Deny or policy.decision == "deny" then
		return true
	end

	local CommunicationSetting = PlatformCommunicationService.CommunicationSetting or {}

	if policy.setting ~= nil and (policy.setting == CommunicationSetting.Blocked or policy.setting == "blocked") then
		return true
	end

	return false
end

function M:syncTeamSpeechWithVoicePolicy(policy)
	if not self or self ~= pg.me then
		return
	end

	if M.isVoicePolicyBlocked(policy) then
		if self.pendingSpeechRoomId or pg.game and pg.game.speech and pg.game.speech:checkMemberInRoom(pg.me.uid) then
			self:quitSpeechChannel()
		end

		return
	end

	if pg.game and pg.game.setting and pg.game.setting:getTeamSpeechAutoEnter() and self:isInTeam() and pg.game.speech and not pg.game.speech:checkMemberInRoom(pg.me.uid) then
		self:joinSpeechChannel()
	end
end

function M:beforeJoinSpeechChannel(options)
	if pg.space == nil then
		return true
	end

	if PlatformCommunicationService:isLocalCommunicationAllowed(PlatformCommunicationService.Channel.Voice) then
		local ImpPlatformSpeechSystem = require("SDK.Platform.UIBridge.ImpPlatformSpeechSystem")

		ImpPlatformSpeechSystem.preMuteUnresolvedTeamMembers(self)

		return false
	end

	if type(options) == "table" and options.notifyDenied == true then
		PlatformCommunicationService:notifyOutgoingCommunicationDenied(PlatformCommunicationService.Channel.Voice, "team_speech_join", {
			notifyUser = true,
			deniedTipKey = "PLATFORM_SOCIAL_VOICE_PRIVILEGE_DENIED"
		})
	end

	return true
end

function M:bindVoicePolicyListener()
	if self ~= pg.me or self.platformVoicePolicyListener then
		return
	end

	if not pg or not pg.global or not pg.global.eventEmitter then
		return
	end

	function self.platformVoicePolicyListener(payload)
		if type(payload) ~= "table" or payload.channel ~= PlatformCommunicationService.Channel.Voice then
			return
		end

		M.syncTeamSpeechWithVoicePolicy(self, payload.newPolicy)
	end

	pg.global.eventEmitter:removeEventListener(EventConst.PLATFORM_LOCAL_COMMUNICATION_POLICY_CHANGED, self.platformVoicePolicyListener)
	pg.global.eventEmitter:addEventListener(EventConst.PLATFORM_LOCAL_COMMUNICATION_POLICY_CHANGED, self.platformVoicePolicyListener)
end

function M:unbindVoicePolicyListener()
	if not self.platformVoicePolicyListener then
		return
	end

	if pg and pg.global and pg.global.eventEmitter then
		pg.global.eventEmitter:removeEventListener(EventConst.PLATFORM_LOCAL_COMMUNICATION_POLICY_CHANGED, self.platformVoicePolicyListener)
	end

	self.platformVoicePolicyListener = nil
end

function M:init()
	M.bindVoicePolicyListener(self)
	PlatformCrossPlatformService:syncCurrentSettingToServer()
	M.syncTeamSpeechWithVoicePolicy(self, PlatformCommunicationService:peekLocalCommunicationPolicy(PlatformCommunicationService.Channel.Voice))
end

function M:destroy()
	M.unbindVoicePolicyListener(self)

	self.pendingPlatformEnterWorldInviteIdentityQueries = nil
end

function M:onLeaveTeam()
	PlatformInviteTokenService:clearAll()
	PlatformShellActivityService:clearCurrentActivity("leave_team")

	local space = pg and pg.space
	local multiPlayerEnv = space and space.multiPlayerEnv or false

	if not self:isInTeam() and not multiPlayerEnv then
		PlatformPremiumFeatureService:endSession()
	end
end

function M:handleSyncTeamInfo()
	PlatformShellActivityService:refreshCurrentTeamActivity("team_sync")

	local recentPlayerService = M.getPlatformRecentPlayerService()

	if recentPlayerService then
		recentPlayerService:reportTeamMembers(self.teamInfo, "team_sync")
	end

	if self:isInTeam() then
		local leaderUid = tostring(self.teamInfo and self.teamInfo.leaderUid or "")
		local isTeamLeaderChanged = not string.isNilOrEmpty(M.lastKnownTeamLeaderUid) and M.lastKnownTeamLeaderUid ~= leaderUid

		if self:isTeamLeader() then
			if isTeamLeaderChanged then
				PlatformShellActivityService:recreateCurrentTeamActivity("team_leader_changed")
			else
				PlatformShellActivityService:refreshCurrentTeamActivity("team_sync_leader")
			end
		elseif isTeamLeaderChanged then
			PlatformShellActivityService:clearCurrentActivity("team_leader_changed_not_leader")
		end

		M.lastKnownTeamLeaderUid = leaderUid
	else
		M.lastKnownTeamLeaderUid = ""
	end

	if self:isInTeam() and pg.space ~= nil and not PlatformShellJoinService:shouldDelayPremiumFeatureSessionUntilPlayerEnterScene() then
		PlatformPremiumFeatureService:beginSession("cross_play")
	end
end

function M:RPC_SC_TeamNoticeId(playerInfo, noticeId)
	if self:isInTeam() then
		return
	end

	if not M.TEAM_JOIN_FAILED_NOTICE_IDS[noticeId] then
		return
	end

	logger:info("team join failed, clear platform activity noticeId=%s", tostring(noticeId))
	PlatformShellActivityService:clearCurrentActivity("team_join_failed")
end

function M:RPC_SC_SyncDungeonTeamInfo(dungeonTeamInfo)
	local recentPlayerService = M.getPlatformRecentPlayerService()

	if recentPlayerService then
		local currentDungeonTeamInfo = dungeonTeamInfo

		if currentDungeonTeamInfo == nil and self.getSpaceDungeonTeamInfo then
			currentDungeonTeamInfo = self:getSpaceDungeonTeamInfo()
		end

		recentPlayerService:reportTeamMembers(currentDungeonTeamInfo, "dungeon_team_sync")
	end
end

function M.sendPlatformInvite(sendFn, uid, playerInfo, context)
	local handled = sendFn(playerInfo)

	if handled ~= true then
		logger:error("%s platform invite failed uid=%s currentFamily=%s targetFamily=%s hasPlatformUserId=%s", tostring(context), tostring(uid), tostring(PlatformIdentityUtils.getCurrentPlatformFamily()), tostring(PlatformIdentityUtils.resolvePlayerInfoFamily(playerInfo)), tostring(not string.isNilOrEmpty(PlatformIdentityUtils.resolvePlatformUserId(playerInfo))))
	end
end

function M.getPlayerInfoByUid(uid)
	return pg and pg.game and pg.game.chat and pg.game.chat.getPlayerInfo and pg.game.chat:getPlayerInfo(uid) or nil
end

function M.isKnownPlatformFamily(family)
	return not string.isNilOrEmpty(family) and family ~= PlatformIdentityUtils.UnknownFamily and family ~= (PlatformIdentityUtils.Family and PlatformIdentityUtils.Family.Other)
end

function M.isSameLocalPlatformFamilyTarget(playerInfo)
	local currentFamily = PlatformIdentityUtils.getCurrentPlatformFamily()
	local targetFamily = PlatformIdentityUtils.resolvePlayerInfoFamily(playerInfo)

	return M.isKnownPlatformFamily(currentFamily) and M.isKnownPlatformFamily(targetFamily) and currentFamily == targetFamily
end

function M.consumeTeamInviteWhenMissingPlatformFamily(uid, playerInfo, context, isCandidate)
	if not isCandidate then
		return false
	end

	if M.isKnownPlatformFamily(PlatformIdentityUtils.resolvePlayerInfoFamily(playerInfo)) then
		return false
	end

	return true
end

function M.sendTeamInvite(playerInfo, extraInfo)
	return PlatformShellInviteService:sendShellActivityInvite(PlatformShellConst.TokenType.InviteJoinTeam, playerInfo, extraInfo)
end

function M.sendTeamRequestJoinInvite(playerInfo)
	return PlatformShellInviteService:sendShellActivityInvite(PlatformShellConst.TokenType.RequestJoinTeam, playerInfo)
end

function M.sendEnterWorldInvite(playerInfo, inviteType)
	return PlatformShellInviteService:sendShellActivityInvite(PlatformShellConst.TokenType.InviteEnterWorld, playerInfo, {
		inviteWorldType = inviteType or Const.InviteWorldType.NORMAL_INVITE
	})
end

function M.getEnterWorldInviteIdentityQueryKey(uid, inviteType)
	return string.format("%s:%s", tostring(uid or ""), tostring(inviteType or Const.InviteWorldType.NORMAL_INVITE))
end

function M.hasCompletePlatformInviteIdentity(playerInfo)
	return M.isKnownPlatformFamily(PlatformIdentityUtils.resolvePlayerInfoFamily(playerInfo)) and not string.isNilOrEmpty(PlatformIdentityUtils.resolvePlatformUserId(playerInfo))
end

function M:sendInGameEnterWorldInvite(uid, inviteType)
	self:serverMsg("RPC_CS_InviteSinglePlayer", uid, {
		type = inviteType or Const.InviteWorldType.NORMAL_INVITE
	})
	pg.global.ui.tips:showTextTip(pg.getGameString("SEND_INVITE_SUCCESS"))
end

function M:finishEnterWorldInviteIdentityQuery(queryContext, queriedPlayerInfo, succeeded)
	local pendingQueries = self.pendingPlatformEnterWorldInviteIdentityQueries

	if not pendingQueries or pendingQueries[queryContext.key] ~= queryContext then
		return
	end

	pendingQueries[queryContext.key] = nil

	local playerInfo = queriedPlayerInfo or M.getPlayerInfoByUid(queryContext.uid)
	local currentFamily = PlatformIdentityUtils.getCurrentPlatformFamily()
	local targetFamily = PlatformIdentityUtils.resolvePlayerInfoFamily(playerInfo)
	local targetPlatformUserId = PlatformIdentityUtils.resolvePlatformUserId(playerInfo)

	logger:info("invite enter world identity resolved uid=%s inviteType=%s querySucceeded=%s currentFamily=%s targetFamily=%s hasPlatformUserId=%s", tostring(queryContext.uid), tostring(queryContext.inviteType), tostring(succeeded == true), tostring(currentFamily or ""), tostring(targetFamily or ""), tostring(not string.isNilOrEmpty(targetPlatformUserId)))

	if targetFamily == currentFamily and not string.isNilOrEmpty(targetPlatformUserId) then
		M.sendPlatformInvite(function(targetInfo)
			return M.sendEnterWorldInvite(targetInfo, queryContext.inviteType)
		end, queryContext.uid, playerInfo, queryContext.context)

		return
	end

	if M.isKnownPlatformFamily(targetFamily) and targetFamily ~= currentFamily then
		M.sendInGameEnterWorldInvite(self, queryContext.uid, queryContext.inviteType)

		return
	end

	logger:error("invite enter world identity unresolved, suppress game invite uid=%s inviteType=%s querySucceeded=%s currentFamily=%s targetFamily=%s hasPlatformUserId=%s", tostring(queryContext.uid), tostring(queryContext.inviteType), tostring(succeeded == true), tostring(currentFamily or ""), tostring(targetFamily or ""), tostring(not string.isNilOrEmpty(targetPlatformUserId)))
	PlatformNoticeUtils.showTextTipById(NoticeDef.TEAM_INVITE_MEMBER_OFFLINE)
end

function M:queryAndSendEnterWorldInviteByPlatformIdentity(uid, inviteType, context)
	if not PlatformShellInviteService or type(PlatformShellInviteService.isSupported) ~= "function" or PlatformShellInviteService:isSupported() ~= true or not pg or not pg.me or type(pg.me.queryPlayerInfo) ~= "function" then
		return false
	end

	self.pendingPlatformEnterWorldInviteIdentityQueries = self.pendingPlatformEnterWorldInviteIdentityQueries or {}

	local key = M.getEnterWorldInviteIdentityQueryKey(uid, inviteType)

	if self.pendingPlatformEnterWorldInviteIdentityQueries[key] then
		logger:debug("invite enter world identity query already pending uid=%s inviteType=%s", tostring(uid), tostring(inviteType))

		return true
	end

	local queryContext = {
		key = key,
		uid = tostring(uid or ""),
		inviteType = inviteType or Const.InviteWorldType.NORMAL_INVITE,
		context = context
	}

	self.pendingPlatformEnterWorldInviteIdentityQueries[key] = queryContext

	logger:info("invite enter world identity missing, query before route uid=%s inviteType=%s currentFamily=%s", tostring(queryContext.uid), tostring(queryContext.inviteType), tostring(PlatformIdentityUtils.getCurrentPlatformFamily() or ""))
	pg.me:queryPlayerInfo(queryContext.uid, nil, true, function(playerInfo, succeeded)
		M.finishEnterWorldInviteIdentityQuery(self, queryContext, playerInfo, succeeded)
	end)

	return true
end

function M.sendEnterWorldRequest(playerInfo)
	return PlatformShellInviteService:sendShellActivityInvite(PlatformShellConst.TokenType.RequestEnterWorld, playerInfo)
end

function M.sendSpaceFollowInvite(playerInfo)
	return PlatformShellInviteService:sendShellActivityInvite(PlatformShellConst.TokenType.InviteSpaceFollow, playerInfo, {
		forceTokenRenew = true
	})
end

function M.sendSpaceFollowRequestInvite(playerInfo)
	return PlatformShellInviteService:sendShellActivityInvite(PlatformShellConst.TokenType.ReuquestSpaceFollow, playerInfo)
end

function M:consumeSpaceFollowRequestWhenInTeam(uid, playerInfo)
	local currentFamily = PlatformIdentityUtils.getCurrentPlatformFamily()

	if self ~= pg.me or not PlatformIdentityUtils.isConsoleFamily(currentFamily) or not M.isSameLocalPlatformFamilyTarget(playerInfo) or not self:isInTeam() or self:isUidTeamMember(uid) then
		return false
	end

	PlatformNoticeUtils.showBubbleMessageById(NoticeDef.ERROR_REPEAT_JOIN_TEAM)
	logger:info("space follow request blocked while in team uid=%s currentFamily=%s", tostring(uid), tostring(currentFamily or ""))

	return true
end

function M.sendQuickTeamSpaceFollowInvite(playerInfo)
	return PlatformShellInviteService:sendShellActivityInvite(PlatformShellConst.TokenType.InviteQuickSpaceFollow, playerInfo)
end

function M.sendByPlatformFriend(uid, sendFn, context, extraInfo)
	local playerInfo = M.getPlayerInfoByUid(uid)

	if PlatformIdentityUtils.isPlatformFriend(playerInfo) then
		M.sendPlatformInvite(function(targetInfo)
			return sendFn(targetInfo, extraInfo)
		end, uid, playerInfo, context)

		return true
	end

	return false
end

function M:consumeTeamInviteForInvalidMatchStatus()
	if PlatformShellActivityService.isConsoleMatchStatusInit(self) then
		return false
	end

	pg.global.ui.tips:showTextTip(pg.getGameString("APPLY_TEAM_STATUS_ERROR"))

	return true
end

function M:sendTeamInviteByPlatformFriend(uid, extraInfo)
	local playerInfo = M.getPlayerInfoByUid(uid)
	local isPlatformFriend = PlatformIdentityUtils.isPlatformFriend(playerInfo)
	local shouldConsume = M.consumeTeamInviteWhenMissingPlatformFamily(uid, playerInfo, "inviteTeamMemberByPlatformFriend", isPlatformFriend)
	local handled = isPlatformFriend and M.isSameLocalPlatformFamilyTarget(playerInfo)

	if not shouldConsume and not handled then
		return false, false
	end

	if M.consumeTeamInviteForInvalidMatchStatus(self) then
		return true, false
	end

	if shouldConsume then
		return true, false
	end

	M.sendPlatformInvite(function(targetInfo)
		return M.sendTeamInvite(targetInfo, extraInfo)
	end, uid, playerInfo, "inviteTeamMemberByPlatformFriend")

	return true, true
end

function M:sendTeamInviteBySamePlatformFamily(uid, extraInfo)
	local playerInfo = M.getPlayerInfoByUid(uid)
	local hasPlatformUserId = not string.isNilOrEmpty(PlatformIdentityUtils.resolvePlatformUserId(playerInfo))
	local shouldConsume = M.consumeTeamInviteWhenMissingPlatformFamily(uid, playerInfo, "inviteTeamMemberBySamePlatformFamily", hasPlatformUserId)
	local handled = M.isSameLocalPlatformFamilyTarget(playerInfo)

	if not shouldConsume and not handled then
		return false, false
	end

	if M.consumeTeamInviteForInvalidMatchStatus(self) then
		return true, false
	end

	if shouldConsume then
		return true, false
	end

	M.sendPlatformInvite(function(targetInfo)
		return M.sendTeamInvite(targetInfo, extraInfo)
	end, uid, playerInfo, "inviteTeamMemberBySamePlatformFamily")

	return true, true
end

function M.sendBySamePlatformFamily(uid, sendFn, context, extraInfo)
	local playerInfo = M.getPlayerInfoByUid(uid)

	if PlatformIdentityUtils.isSamePlatformFamilyUser(playerInfo) then
		M.sendPlatformInvite(function(targetInfo)
			return sendFn(targetInfo, extraInfo)
		end, uid, playerInfo, context)

		return true
	end

	return false
end

function M.canHandleOfflineShellInvite(playerInfo)
	if not PlatformShellInviteService or type(PlatformShellInviteService.isSupported) ~= "function" or PlatformShellInviteService:isSupported() ~= true then
		return false
	end

	local platformUserId = PlatformIdentityUtils.resolvePlatformUserId(playerInfo)

	if string.isNilOrEmpty(platformUserId) then
		return false
	end

	return PlatformIdentityUtils.isPlatformFriend(playerInfo) == true or PlatformIdentityUtils.isSamePlatformFamilyUser(playerInfo) == true
end

function M:inviteTeamMemberByPlatformFriend(uid, extraInfo)
	local ok = M.sendTeamInviteByPlatformFriend(self, uid, extraInfo)

	return ok
end

function M:inviteTeamMemberBySamePlatformFamily(uid, extraInfo)
	local ok = M.sendTeamInviteBySamePlatformFamily(self, uid, extraInfo)

	return ok
end

function M:requestJoinTeamByPlatformFriend(uid)
	return M.sendByPlatformFriend(uid, M.sendTeamRequestJoinInvite, "requestJoinTeamByPlatformFriend")
end

function M:requestJoinTeamBySamePlatformFamily(uid)
	return M.sendBySamePlatformFamily(uid, M.sendTeamRequestJoinInvite, "requestJoinTeamBySamePlatformFamily")
end

function M:beforeAcceptTeamInvite(uid)
	local inviterInfo = self.inviterInfoMap and self.inviterInfoMap[uid]
	local allowed = PlatformCrossPlatformService:checkTeamInvitePermission(inviterInfo)

	return allowed ~= true
end

function M:beforeReceiveTeamInvite(uid, inviterInfo, dungeonInfo)
	if not M.shouldAllowInboundGameInvite("team_invited") then
		return true
	end

	if M.isPlatformBlockedSender(inviterInfo) then
		return true
	end

	return M.shouldSuppressInboundTeamInvite(self, uid, inviterInfo)
end

function M:beforeReceiveJoinTeamRequest(uid, applicantInfo)
	if not M.shouldAllowInboundGameInvite("request_join_team") then
		return true
	end

	return M.isPlatformBlockedSender(applicantInfo)
end

function M:beforeReceiveEnterWorldRequest(uid, playerInfo)
	if not M.shouldAllowInboundGameInvite("receive_enter_world_request") then
		return true
	end

	if M.isPlatformBlockedSender(playerInfo) then
		return true
	end

	return M.onReceiveEnterWorldRequestInPreparingRoom(self, uid, playerInfo)
end

function M:beforeReceiveEnterWorldInvite(uid, playerInfo, inviteWorldParams)
	if not M.shouldAllowInboundGameInvite("receive_enter_world_invite") then
		return true
	end

	return M.isPlatformBlockedSender(playerInfo)
end

function M:shouldSuppressInboundTeamInvite(uid, inviterInfo)
	if not M.isLocalConsoleInPreparingRoom(self) then
		return false
	end

	return true
end

function M:onReceiveEnterWorldRequestInPreparingRoom(uid, playerInfo)
	if not M.isLocalConsoleInPreparingRoom(self) then
		return false
	end

	if pg.global.ui ~= nil and pg.global.ui.tips ~= nil then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_ALREADY_PREPARE"))
	end

	if type(self.handleEnterWorldRequest) == "function" then
		self:handleEnterWorldRequest(uid, false)
	end

	logger:info("[platform_enter_world] refuse enter-world request in preparing room uid=%s", tostring(uid))

	return true
end

function M.showHomeCampUgcDeniedTip(context)
	local noticeId = NoticeDef.CANNOT_ENTER_HOMECAMP

	if context and context.reason == PlatformHomeCampEntryFilterService.REASON_PLATFORM_BLOCK_LIST then
		noticeId = NoticeDef.PRIVACY_SETTING_MISSMATCH
	end

	PlatformNoticeUtils.showTextTipById(noticeId)
end

function M:beforeAcceptEnterWorldInvite(uid)
	local key = tostring(uid)

	self.ugcInviteGateState = self.ugcInviteGateState or {}

	if self.ugcInviteGateState[key] == "allow" then
		self.ugcInviteGateState[key] = nil

		return false
	end

	if self.ugcInviteGateState[key] == "querying" then
		return true
	end

	local playerInfo = M.getPlayerInfoByUid(uid)
	local allowed, _, context = PlatformHomeCampEntryFilterService:canEnterHomeCamp(uid, playerInfo)

	if allowed then
		return false
	end

	self.ugcInviteGateState[key] = "querying"

	PlatformShellInviteDestinationQueryService:query({
		queryMode = PlatformShellConst.InGameEnterWorldDestinationQueryMode,
		inviterGameUid = key
	}, function(ok, destinationContext)
		local isUGC = not ok or destinationContext and destinationContext.destinationKind == "homeland"

		if isUGC then
			self.ugcInviteGateState[key] = nil

			M.showHomeCampUgcDeniedTip(context)
			logger:info("home_camp_ugc_invite_blocked uid=%s ok=%s destinationKind=%s reason=%s", key, tostring(ok), tostring(destinationContext and destinationContext.destinationKind or ""), tostring(context and context.reason or ""))

			return
		end

		self.ugcInviteGateState[key] = "allow"

		self:handleEnterWorldInvite(uid, true)
	end)

	return true
end

function M:beforeRequestEnterWorld(uid)
	local key = tostring(uid)

	self.ugcEnterWorldGateState = self.ugcEnterWorldGateState or {}

	if self.ugcEnterWorldGateState[key] == "querying" then
		return true
	end

	local playerInfo = M.getPlayerInfoByUid(uid)
	local allowed, _, context = PlatformHomeCampEntryFilterService:canEnterHomeCamp(uid, playerInfo)

	if allowed then
		return false
	end

	self.ugcEnterWorldGateState[key] = "querying"

	PlatformShellInviteDestinationQueryService:query({
		queryMode = PlatformShellConst.InGameEnterWorldDestinationQueryMode,
		inviterGameUid = key
	}, function(ok, destinationContext)
		self.ugcEnterWorldGateState[key] = nil

		local isUGC = not ok or destinationContext and destinationContext.destinationKind == "homeland"

		if isUGC then
			M.showHomeCampUgcDeniedTip(context)
			logger:info("home_camp_ugc_enter_world_blocked uid=%s ok=%s destinationKind=%s reason=%s", key, tostring(ok), tostring(destinationContext and destinationContext.destinationKind or ""), tostring(context and context.reason or ""))

			return
		end

		self:serverMsg("RPC_CS_RequestEnterWorld", uid)
	end)

	return true
end

function M:requestEnterWorldByPlatformFriend(uid)
	return M.sendByPlatformFriend(uid, function(playerInfo)
		return M.sendEnterWorldRequest(playerInfo)
	end, "requestEnterWorldByPlatformFriend")
end

function M:requestEnterWorldBySamePlatformFamily(uid)
	return M.sendBySamePlatformFamily(uid, function(playerInfo)
		return M.sendEnterWorldRequest(playerInfo)
	end, "requestEnterWorldBySamePlatformFamily")
end

function M:inviteEnterWorldByPlatformFriend(uid, inviteType)
	inviteType = inviteType or Const.InviteWorldType.NORMAL_INVITE

	local playerInfo = M.getPlayerInfoByUid(uid)

	if not PlatformIdentityUtils.isPlatformFriend(playerInfo) then
		return false
	end

	if M.isSameLocalPlatformFamilyTarget(playerInfo) and not string.isNilOrEmpty(PlatformIdentityUtils.resolvePlatformUserId(playerInfo)) then
		M.sendPlatformInvite(function(targetInfo)
			return M.sendEnterWorldInvite(targetInfo, inviteType)
		end, uid, playerInfo, "inviteEnterWorldByPlatformFriend")

		return true
	end

	if PlatformIdentityUtils.getCurrentPlatformFamily() ~= PlatformIdentityUtils.Family.Xbox or M.hasCompletePlatformInviteIdentity(playerInfo) then
		return false
	end

	return M.queryAndSendEnterWorldInviteByPlatformIdentity(self, uid, inviteType, "inviteEnterWorldByPlatformFriend")
end

function M:inviteEnterWorldBySamePlatformFamily(uid, inviteType)
	inviteType = inviteType or Const.InviteWorldType.NORMAL_INVITE

	local handled = M.sendBySamePlatformFamily(uid, function(playerInfo)
		return M.sendEnterWorldInvite(playerInfo, inviteType)
	end, "inviteEnterWorldBySamePlatformFamily")

	if handled then
		return true
	end

	local currentFamily = PlatformIdentityUtils.getCurrentPlatformFamily()

	if currentFamily ~= PlatformIdentityUtils.Family.Xbox then
		return false
	end

	local playerInfo = M.getPlayerInfoByUid(uid)

	if M.hasCompletePlatformInviteIdentity(playerInfo) then
		return false
	end

	return M.queryAndSendEnterWorldInviteByPlatformIdentity(self, uid, inviteType, "inviteEnterWorldBySamePlatformFamily")
end

function M:canHandleOfflineInviteEnterWorld(uid, inviteType, playerInfo)
	return M.canHandleOfflineShellInvite(playerInfo)
end

function M:reqSpaceFollowByPlatformFriend(uid)
	local playerInfo = M.getPlayerInfoByUid(uid)

	if not PlatformIdentityUtils.isPlatformFriend(playerInfo) then
		return false
	end

	if M.consumeSpaceFollowRequestWhenInTeam(self, uid, playerInfo) then
		return true
	end

	return M.sendByPlatformFriend(uid, M.sendSpaceFollowRequestInvite, "reqSpaceFollowByPlatformFriend")
end

function M:reqSpaceFollowBySamePlatformFamily(uid)
	local playerInfo = M.getPlayerInfoByUid(uid)

	if not PlatformIdentityUtils.isSamePlatformFamilyUser(playerInfo) then
		return false
	end

	if M.consumeSpaceFollowRequestWhenInTeam(self, uid, playerInfo) then
		return true
	end

	return M.sendBySamePlatformFamily(uid, M.sendSpaceFollowRequestInvite, "reqSpaceFollowBySamePlatformFamily")
end

function M:quickInviteSpaceFollowByPlatformFriend(uid)
	return M.sendByPlatformFriend(uid, M.sendQuickTeamSpaceFollowInvite, "quickInviteSpaceFollowByPlatformFriend")
end

function M:quickInviteSpaceFollowBySamePlatformFamily(uid)
	return M.sendBySamePlatformFamily(uid, M.sendQuickTeamSpaceFollowInvite, "quickInviteSpaceFollowBySamePlatformFamily")
end

function M:inviteSpaceFollowByPlatformFriend(uid)
	return M.sendByPlatformFriend(uid, M.sendSpaceFollowInvite, "inviteSpaceFollowByPlatformFriend")
end

function M:inviteSpaceFollowBySamePlatformFamily(uid)
	return M.sendBySamePlatformFamily(uid, M.sendSpaceFollowInvite, "inviteSpaceFollowBySamePlatformFamily")
end

function M.getSpaceFollowToastName(action, uid, playerInfo, rawName)
	if string.isNilOrEmpty(uid) or string.isNilOrEmpty(rawName) then
		return rawName
	end

	return PlatformNameMaskService.getMaskedDisplayName({
		action = action,
		uid = tostring(uid),
		playerInfo = playerInfo,
		rawText = rawName
	})
end

function M:notifyReqSpaceFollowRetName(receiverUid, playerInfo, rawName)
	return M.getSpaceFollowToastName(PlatformNameMaskService.Action.SpaceFollowRequestRetName, receiverUid, playerInfo, rawName or "")
end

function M:notifyInviteSpaceFollowRetName(receiverUid, playerInfo, rawName)
	return M.getSpaceFollowToastName(PlatformNameMaskService.Action.InviteSpaceFollowRetName, receiverUid, playerInfo, rawName or "")
end

function M:kickSpaceFollowName(followUid, playerInfo, rawName)
	return M.getSpaceFollowToastName(PlatformNameMaskService.Action.KickSpaceFollowName, followUid, playerInfo, rawName or "")
end

return M
