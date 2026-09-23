-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformShellJoinService.lua

local logger = require("SDK.Platform.PlatformLogger")
local TimerManager = require("Core.Timer.TimerManager")
local Const = require("Common.Const.Const")
local FuncIdConfigData = require("Data.func_index_config_data")
local PlatformShellTokenUtils = require("SDK.Platform.PlatformShellTokenUtils")
local PlatformPrivacyUtils = require("SDK.Platform.PlatformPrivacyUtils")
local PlatformHomeCampEntryFilterService = require("SDK.Platform.PlatformHomeCampEntryFilterService")
local PlatformUGCSpaceEntryFilterService = require("SDK.Platform.PlatformUGCSpaceEntryFilterService")
local PlatformShellInviteDestinationQueryService = require("SDK.Platform.PlatformShellInviteDestinationQueryService")
local PlatformPlayerInfoQueryService = require("SDK.Platform.PlatformPlayerInfoQueryService")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformShellActivityService = require("SDK.Platform.PlatformShellActivityService")
local PlatformNoticeUtils = require("SDK.Platform.PlatformNoticeUtils")
local NoticeDef = require("Common.NoticeDef")
local EventConst = require("Common.Const.EventConst")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local PlatformShellJoinService = {}

PlatformShellJoinService.SHELL_JOIN_MULTIPLAYER_PRIVILEGE_TIMEOUT_SENTINEL = -1
PlatformShellJoinService.SHELL_JOIN_MULTIPLAYER_PRIVILEGE_TIMEOUT_SECONDS = 30
PlatformShellJoinService.TEAM_FUNCTION_NAME = Const.FUNCTION_NAME.TEAM
PlatformShellJoinService.CONNECTION_STRING_LOG_SAFE_FIELDS = {
	tokenType = true,
	inviteWorldType = true,
	contextType = true,
	clusterName = true,
	clusterId = true,
	serverId = true
}

local function clearActivityForDroppedEnterWorldToken(sourceReason, tokenType)
	if tokenType ~= PlatformShellTokenUtils.TokenType.InviteEnterWorld and tokenType ~= PlatformShellTokenUtils.TokenType.RequestEnterWorld and tokenType ~= PlatformShellTokenUtils.TokenType.InviteHomeCamp and tokenType ~= PlatformShellTokenUtils.TokenType.RequestHomeCamp then
		return
	end

	PlatformShellActivityService:clearCurrentActivity(sourceReason)
end

PlatformShellJoinService.state = {
	multiplayerPrivilegeUiPending = false,
	initialized = false,
	delayPremiumFeatureSessionUntilPlayerEnterScene = false,
	multiplayerPrivilegeRequestId = 0,
	selectedPreLoginConnectionString = "",
	ownerUserId = "",
	pendingTokens = {},
	pendingMultiplayerPrivilegeEvents = {}
}

function PlatformShellJoinService.showTextTipByIdAfterPlayerEnterScene(noticeId)
	if noticeId == nil then
		return
	end

	if pg and pg.me and pg.me.isInScene == true then
		PlatformNoticeUtils.showTextTipById(noticeId)

		return
	end

	PlatformShellJoinService.state.pendingTextTipNoticeId = noticeId
end

function PlatformShellJoinService:tryShowPendingTextTip()
	local noticeId = PlatformShellJoinService.state.pendingTextTipNoticeId

	if noticeId == nil then
		return false
	end

	PlatformShellJoinService.state.pendingTextTipNoticeId = nil

	if PlatformShellJoinService.state.pendingTextTipTimerId ~= nil then
		TimerManager.removeTimer(PlatformShellJoinService.state.pendingTextTipTimerId)
	end

	PlatformShellJoinService.state.pendingTextTipTimerId = TimerManager.addTimer(1, function()
		PlatformShellJoinService.state.pendingTextTipTimerId = nil

		PlatformNoticeUtils.showTextTipById(noticeId)
	end)

	return true
end

function PlatformShellJoinService:clearPendingTextTip()
	if PlatformShellJoinService.state.pendingTextTipTimerId ~= nil then
		TimerManager.removeTimer(PlatformShellJoinService.state.pendingTextTipTimerId)

		PlatformShellJoinService.state.pendingTextTipTimerId = nil
	end

	PlatformShellJoinService.state.pendingTextTipNoticeId = nil
end

function PlatformShellJoinService.markDelayPremiumFeatureSessionUntilPlayerEnterScene(tokenType)
	if tokenType ~= PlatformShellTokenUtils.TokenType.InviteEnterWorld then
		return
	end

	PlatformShellJoinService.state.delayPremiumFeatureSessionUntilPlayerEnterScene = true
end

function PlatformShellJoinService:shouldDelayPremiumFeatureSessionUntilPlayerEnterScene()
	return PlatformShellJoinService.state.delayPremiumFeatureSessionUntilPlayerEnterScene == true
end

function PlatformShellJoinService:clearDelayPremiumFeatureSessionUntilPlayerEnterScene()
	PlatformShellJoinService.state.delayPremiumFeatureSessionUntilPlayerEnterScene = false
end

function PlatformShellJoinService.isPlatformSupported()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.IsSupported and PlatformBridgeLuaFacade.IsSupported() == true
end

function PlatformShellJoinService.supportsMultiplayerActivity()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.SupportsMultiplayerActivity and PlatformBridgeLuaFacade.SupportsMultiplayerActivity() == true
end

function PlatformShellJoinService.isRuntimeReady()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.IsRuntimeInitialized and PlatformBridgeLuaFacade.IsRuntimeInitialized() == true
end

function PlatformShellJoinService.getSignedInUserId()
	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.GetSignedInUserId then
		return ""
	end

	local userId = PlatformBridgeLuaFacade.GetSignedInUserId()

	if string.isNilOrEmpty(userId) then
		return ""
	end

	return tostring(userId)
end

function PlatformShellJoinService.resetPendingMultiplayerPrivilegeEvents()
	PlatformShellJoinService.state.pendingMultiplayerPrivilegeEvents = {}
	PlatformShellJoinService.state.multiplayerPrivilegeUiPending = false
	PlatformShellJoinService.state.multiplayerPrivilegeRequestId = PlatformShellJoinService.state.multiplayerPrivilegeRequestId + 1
end

function PlatformShellJoinService.resetPendingTokens(clearOwner)
	PlatformShellJoinService.state.pendingTokens = {}
	PlatformShellJoinService.state.selectedPreLoginConnectionString = ""

	PlatformShellJoinService.resetPendingMultiplayerPrivilegeEvents()

	if clearOwner ~= false then
		PlatformShellJoinService.state.ownerUserId = ""
	end
end

function PlatformShellJoinService.bindSignedInUser()
	local ownerUserId = PlatformShellJoinService.getSignedInUserId()

	if string.isNilOrEmpty(ownerUserId) then
		PlatformShellJoinService.resetPendingTokens(true)

		return false
	end

	if PlatformShellJoinService.state.ownerUserId ~= ownerUserId then
		PlatformShellJoinService.resetPendingTokens(false)

		PlatformShellJoinService.state.ownerUserId = ownerUserId
	end

	return true
end

function PlatformShellJoinService.normalizeConnectionStringLogField(key)
	local fieldName = tostring(key or "")
	local lowerName = string.lower(fieldName)

	if lowerName == "jointoken" or lowerName == "shellinvitetoken" then
		return "inviteToken"
	end

	return fieldName
end

function PlatformShellJoinService.formatConnectionStringForLog(connectionString)
	local source = tostring(connectionString or "")

	if source == "" then
		return "<empty>"
	end

	if not PlatformPrivacyUtils:shouldRedactSensitiveLogs() then
		return source
	end

	local parts = {}

	for token in string.gmatch(source, "[^&]+") do
		local equalIndex = string.find(token, "=", 1, true)

		if equalIndex and equalIndex > 1 then
			local key = string.sub(token, 1, equalIndex - 1)
			local normalizedKey = PlatformShellJoinService.normalizeConnectionStringLogField(key)

			if PlatformShellJoinService.CONNECTION_STRING_LOG_SAFE_FIELDS[normalizedKey] then
				parts[#parts + 1] = token
			else
				parts[#parts + 1] = key .. "=<redacted>"
			end
		else
			parts[#parts + 1] = "<redacted>"
		end
	end

	if #parts == 0 then
		return "<redacted>"
	end

	return table.concat(parts, "&")
end

function PlatformShellJoinService.stopPolling()
	if not PlatformShellJoinService.state.pollFrameCbId then
		return
	end

	TimerManager.delFrameCb(PlatformShellJoinService.state.pollFrameCbId)

	PlatformShellJoinService.state.pollFrameCbId = nil
end

function PlatformShellJoinService.startPolling()
	if PlatformShellJoinService.state.pollFrameCbId or not PlatformShellJoinService.state.initialized then
		return
	end

	PlatformShellJoinService.state.pollFrameCbId = TimerManager.addRepeatNextFrameCb(function()
		PlatformShellJoinService:_pumpShellJoinEvents()
		PlatformShellJoinService:_processPendingTokens()
	end)
end

function PlatformShellJoinService.showTeamUnlockTip()
	local funcConfig = FuncIdConfigData and FuncIdConfigData[PlatformShellJoinService.TEAM_FUNCTION_NAME]
	local unlockDesc = funcConfig and funcConfig.unlockDesc or nil

	if unlockDesc and pg and pg.global and pg.global.ui and pg.global.ui.tips then
		pg.global.ui.tips:showTextTip(pg.getLocalizationText(unlockDesc))
	end
end

function PlatformShellJoinService.isTeamFunctionUnlocked()
	return pg and pg.me and pg.me.checkFunctionUnlock and pg.me:checkFunctionUnlock(PlatformShellJoinService.TEAM_FUNCTION_NAME) == true or false
end

function PlatformShellJoinService.queuePendingToken(connectionString)
	if string.isNilOrEmpty(connectionString) then
		return
	end

	PlatformShellJoinService.state.pendingTokens[connectionString] = {
		serverNotConnectedLogged = false,
		matchStatusSyncingLogged = false,
		connectionString = connectionString,
		ugcDestinationQueryPending = string.Empty
	}
end

function PlatformShellJoinService.buildAutoLoginIntent(connectionString)
	local parsedFields = PlatformShellTokenUtils.parseConnectionString(connectionString)
	local clusterId = parsedFields and parsedFields.clusterId or nil

	if string.isNilOrEmpty(clusterId) then
		clusterId = parsedFields and parsedFields.serverId or nil
	end

	if string.isNilOrEmpty(clusterId) then
		return nil
	end

	return {
		connectionString = connectionString,
		clusterId = tostring(clusterId),
		clusterName = tostring(parsedFields and parsedFields.clusterName or "")
	}
end

function PlatformShellJoinService.isSameLoginServer(parsedFields)
	local inviterClusterId = tostring(parsedFields and parsedFields.clusterId or "")
	local inviterClusterName = tostring(parsedFields and parsedFields.clusterName or "")

	if not string.isNilOrEmpty(inviterClusterId) and not string.isNilOrEmpty(inviterClusterName) then
		local currentClusterId = PlatformShellTokenUtils.getClusterId()
		local currentClusterName = PlatformShellTokenUtils.getClusterName()

		return inviterClusterId == currentClusterId and inviterClusterName == currentClusterName, "cluster", inviterClusterId, inviterClusterName, currentClusterId, currentClusterName
	end

	local inviterServerId = tostring(parsedFields and parsedFields.serverId or "")
	local currentServerId = PlatformShellTokenUtils.getServerId()

	return inviterServerId == currentServerId, "legacy_server", inviterServerId, "", currentServerId, ""
end

function PlatformShellJoinService.getInviteEventList(events)
	local eventsList = {}

	if not events then
		return eventsList
	end

	local length = events.Length

	if length ~= nil then
		for i = 0, length - 1 do
			eventsList[#eventsList + 1] = events[i]
		end

		return eventsList
	end

	local count = events.Count

	if count ~= nil then
		for i = 0, count - 1 do
			eventsList[#eventsList + 1] = events[i]
		end

		return eventsList
	end

	if type(events) == "table" then
		for _, eventInfo in ipairs(events) do
			eventsList[#eventsList + 1] = eventInfo
		end
	end

	return eventsList
end

function PlatformShellJoinService.selectLatestShellJoinEvent(events, requiredConnectionString)
	local eventsList = PlatformShellJoinService.getInviteEventList(events)
	local required = tostring(requiredConnectionString or "")
	local seenConnectionStrings = {}
	local selectedEvent
	local uniqueValidCount = 0

	for _, eventInfo in ipairs(eventsList) do
		local connectionString = tostring(eventInfo and eventInfo.ConnectionString or "")

		if not string.isNilOrEmpty(connectionString) and not seenConnectionStrings[connectionString] then
			seenConnectionStrings[connectionString] = true

			local matchesRequired = string.isNilOrEmpty(required) or connectionString == required

			if matchesRequired and PlatformShellJoinService.buildAutoLoginIntent(connectionString) ~= nil then
				selectedEvent = eventInfo
				uniqueValidCount = uniqueValidCount + 1
			end
		end
	end

	return selectedEvent, #eventsList, uniqueValidCount
end

function PlatformShellJoinService.removePendingToken(connectionString)
	local tokenInfo = PlatformShellJoinService.state.pendingTokens[connectionString]

	if tokenInfo ~= nil and tokenInfo.playerInfoQueryUid ~= nil and tokenInfo.playerInfoQueryPurpose ~= nil and tokenInfo.playerInfoQueryRequestKey ~= nil then
		PlatformPlayerInfoQueryService:Clear(tokenInfo.playerInfoQueryUid, tokenInfo.playerInfoQueryPurpose, tokenInfo.playerInfoQueryRequestKey)
	end

	PlatformShellJoinService.state.pendingTokens[connectionString] = nil
end

function PlatformShellJoinService.logServerNotConnectedDeferred(connectionString, connectionStringLog)
	local tokenInfo = PlatformShellJoinService.state.pendingTokens[connectionString]

	if tokenInfo and tokenInfo.serverNotConnectedLogged then
		logger:debug("PlatformShellJoinService._processPendingTokens defer: server not connected connectionString=%s", connectionStringLog)

		return
	end

	if tokenInfo then
		tokenInfo.serverNotConnectedLogged = true
	end

	logger:info("PlatformShellJoinService._processPendingTokens defer: server not connected connectionString=%s", connectionStringLog)
end

function PlatformShellJoinService.showServerMismatchTip()
	PlatformNoticeUtils.showTextTipById(NoticeDef.CNNOT_ENTER_TEAM_SERVER_DISMATCH)
end

function PlatformShellJoinService.joinFields(fields)
	if type(fields) ~= "table" then
		return ""
	end

	return table.concat(fields, ",")
end

function PlatformShellJoinService.validateRequiredFields(parsedFields, connectionString)
	local ok, missingFields, requiredFields = PlatformShellTokenUtils.validateRequiredFields(parsedFields)

	if ok then
		return true
	end

	logger:error("PlatformShellJoinService._processPendingTokens drop: missing required fields missingFields=%s requiredFields=%s connectionString=%s", PlatformShellJoinService.joinFields(missingFields), PlatformShellJoinService.joinFields(requiredFields), PlatformShellJoinService.formatConnectionStringForLog(connectionString))

	if pg.global and pg.global.ui and pg.global.ui.tips then
		pg.global.ui.tips:showTextTip(pg.getGameString("INVITATION_EXPIRED"))
	end

	PlatformShellActivityService:clearCurrentActivity("shell_join_drop_missing_required_fields")

	return false
end

function PlatformShellJoinService.isGameServerConnected()
	if not pg or not pg.me or type(pg.me.isServerLost) ~= "function" then
		return false
	end

	return pg.me:isServerLost() ~= true
end

function PlatformShellJoinService.logShellInvitePayload(action, payload)
	logger:info("PlatformShellJoinService._processPendingTokens %s tokenType=%s contextType=%s inviterGameUid=%s serverId=%s inviteTokenLen=%s", tostring(action), tostring(payload and payload.tokenType or ""), tostring(payload and payload.contextType or ""), tostring(payload and payload.inviterGameUid or ""), tostring(payload and payload.serverId or ""), tostring(#tostring(payload and payload.inviteToken or "")))
end

function PlatformShellJoinService.sendShellInviteAccept(payload)
	PlatformShellJoinService.logShellInvitePayload("send_rpc", payload)
	PlatformShellJoinService.markDelayPremiumFeatureSessionUntilPlayerEnterScene(payload and payload.tokenType)
	pg.me:serverMsg("RPC_CS_AcceptPlatformShellInvite", payload)

	if pg.global.eventEmitter then
		pg.global.eventEmitter:emit(EventConst.PLATFORM_SHELL_INVITE_AUTO_ACCEPT, {
			tokenType = payload.tokenType,
			invitorUid = payload.inviterGameUid,
			inviterGameUid = payload.inviterGameUid,
			inviteId = payload.inviteId,
			inviteToken = payload.inviteToken,
			targetKey = payload.targetKey,
			serverId = payload.serverId,
			inviteWorldType = payload.inviteWorldType,
			inviteeUid = pg.me and pg.me.uid
		})
	end
end

function PlatformShellJoinService.isUGCDestinationContext(destinationContext)
	if destinationContext == nil then
		return false
	end

	local kind = tostring(destinationContext.destinationKind or "")

	return kind == "homeland"
end

function PlatformShellJoinService.buildUGCDestinationPendingKey(payload)
	return string.format("%s:%s:%s", tostring(payload and payload.tokenType or ""), tostring(payload and payload.inviteId or ""), tostring(payload and payload.inviteToken or ""))
end

function PlatformShellJoinService.resolveUGCDestinationOwnerInfo(destinationContext)
	if type(destinationContext) ~= "table" then
		return nil
	end

	local ownerUid = destinationContext.ownerUid

	if string.isNilOrEmpty(ownerUid) then
		return nil
	end

	if pg and pg.game and pg.game.chat and pg.game.chat.getPlayerInfo then
		return pg.game.chat:getPlayerInfo(tostring(ownerUid or ""))
	end

	return nil
end

function PlatformShellJoinService.acceptShellInviteAfterUGCCheck(connectionString, payload, destinationContext)
	local currentTokenInfo = PlatformShellJoinService.state.pendingTokens[connectionString]

	if currentTokenInfo then
		currentTokenInfo.ugcDestinationQueryPending = nil
	end

	if not PlatformShellJoinService.state.pendingTokens[connectionString] then
		return
	end

	local ownerPlayerInfo = PlatformShellJoinService.resolveUGCDestinationOwnerInfo(destinationContext)
	local allowed, _, context = PlatformUGCSpaceEntryFilterService:canEnterDestination(destinationContext, ownerPlayerInfo)

	if not allowed then
		PlatformShellJoinService.showTextTipByIdAfterPlayerEnterScene(NoticeDef.CANNOT_ENTER_HOMECAMP)
		clearActivityForDroppedEnterWorldToken("shell_join_drop_ugc_destination_entry_filter", payload.tokenType)
		PlatformShellJoinService.removePendingToken(connectionString)

		return
	end

	PlatformShellJoinService.sendShellInviteAccept(payload)
	PlatformShellJoinService.removePendingToken(connectionString)
end

function PlatformShellJoinService:_acceptShellInviteAfterResolvedDestination(connectionString, payload, destinationContext)
	destinationContext.source = destinationContext.source or "platform_shell_invite"
	destinationContext.tokenType = destinationContext.tokenType or payload.tokenType
	destinationContext.inviterUid = destinationContext.inviterUid or payload.inviterGameUid

	if not PlatformShellJoinService.isUGCDestinationContext(destinationContext) then
		local currentTokenInfo = PlatformShellJoinService.state.pendingTokens[connectionString]

		if currentTokenInfo then
			currentTokenInfo.ugcDestinationQueryPending = nil
		end

		if not PlatformShellJoinService.state.pendingTokens[connectionString] then
			return
		end

		PlatformShellJoinService.sendShellInviteAccept(payload)
		PlatformShellJoinService.removePendingToken(connectionString)

		return
	end

	local ownerUid = destinationContext.ownerUid

	if string.isNilOrEmpty(ownerUid) then
		logger:error("ugc_destination_owner_missing tokenType=%s inviterUid=%s destinationKind=%s spaceType=%s spaceId=%s", tostring(destinationContext.tokenType or ""), tostring(destinationContext.inviterUid or ""), tostring(destinationContext.destinationKind or ""), tostring(destinationContext.spaceType or ""), tostring(destinationContext.spaceId or ""))
		clearActivityForDroppedEnterWorldToken("shell_join_drop_ugc_destination_owner_missing", payload.tokenType)
		PlatformShellJoinService.removePendingToken(connectionString)

		return
	end

	local tokenInfo = PlatformShellJoinService.state.pendingTokens[connectionString]

	if tokenInfo ~= nil then
		tokenInfo.playerInfoQueryUid = ownerUid
		tokenInfo.playerInfoQueryPurpose = PlatformPlayerInfoQueryService.RequestPurpose.ShellJoinUGCOwner
		tokenInfo.playerInfoQueryRequestKey = connectionString
	end

	PlatformPlayerInfoQueryService:requestLatest(ownerUid, PlatformPlayerInfoQueryService.RequestPurpose.ShellJoinUGCOwner, {
		requestKey = connectionString
	}, function(ok, _, reason)
		if not PlatformShellJoinService.state.pendingTokens[connectionString] then
			return
		end

		if reason == PlatformPlayerInfoQueryService.Reason.Superseded then
			PlatformShellJoinService.removePendingToken(connectionString)

			return
		end

		if ok == true then
			PlatformShellJoinService.acceptShellInviteAfterUGCCheck(connectionString, payload, destinationContext)

			return
		end

		logger:warn("ugc_destination_owner_info_query_failed uid=%s", tostring(ownerUid))
		clearActivityForDroppedEnterWorldToken("shell_join_drop_ugc_destination_owner_info_query_failed", payload.tokenType)
		PlatformShellJoinService.removePendingToken(connectionString)
	end)
end

function PlatformShellJoinService.acceptShellInviteAfterDestinationPreflight(connectionString, payload)
	if not pg or not pg.me or type(pg.me.serverMsg) ~= "function" then
		logger:warn("ugc_destination_preflight_unavailable tokenType=%s", tostring(payload and payload.tokenType or ""))
		clearActivityForDroppedEnterWorldToken("shell_join_drop_ugc_destination_preflight_unavailable", payload.tokenType)
		PlatformShellJoinService.removePendingToken(connectionString)

		return true
	end

	local tokenInfo = PlatformShellJoinService.state.pendingTokens[connectionString]

	if not tokenInfo then
		return true
	end

	local pendingKey = PlatformShellJoinService.buildUGCDestinationPendingKey(payload)

	if tokenInfo.ugcDestinationQueryPending == pendingKey then
		logger:debug("ugc_destination_preflight_pending key=%s", tostring(pendingKey))

		return true
	end

	tokenInfo.ugcDestinationQueryPending = pendingKey

	PlatformShellInviteDestinationQueryService:query(payload, function(ok, destinationContext)
		if not PlatformShellJoinService.state.pendingTokens[connectionString] then
			return
		end

		local currentTokenInfo = PlatformShellJoinService.state.pendingTokens[connectionString]

		if currentTokenInfo then
			currentTokenInfo.ugcDestinationQueryPending = nil
		end

		if tostring(payload and payload.tokenType or "") == "InviteEnterPhotoWorld" then
			logger:info("[PHOTO_SHELL] invitee destination preflight result ok=%s kind=%s", tostring(ok), tostring(type(destinationContext) == "table" and destinationContext.destinationKind or "nil"))
		end

		if ok ~= true or type(destinationContext) ~= "table" then
			logger:warn("ugc_destination_preflight_failed tokenType=%s inviterUid=%s", tostring(payload and payload.tokenType or ""), tostring(payload and payload.inviterGameUid or ""))
			clearActivityForDroppedEnterWorldToken("shell_join_drop_ugc_destination_preflight_failed", payload.tokenType)
			PlatformShellJoinService.removePendingToken(connectionString)

			return
		end

		PlatformShellJoinService:_acceptShellInviteAfterResolvedDestination(connectionString, payload, destinationContext)
	end)

	return true
end

function PlatformShellJoinService:_acceptRequestEnterWorldAfterDestinationPreflight(connectionString, payload)
	return PlatformShellJoinService.acceptShellInviteAfterDestinationPreflight(connectionString, payload)
end

function PlatformShellJoinService.resolveHomeCampOwnerInfo(ownerUid)
	if pg and pg.game and pg.game.chat and pg.game.chat.getPlayerInfo then
		return pg.game.chat:getPlayerInfo(tostring(ownerUid or ""))
	end

	return nil
end

function PlatformShellJoinService.showHomeCampOwnerInfoFailedTip(reason, ownerUid)
	PlatformNoticeUtils.showTextTipById(NoticeDef.CANNOT_ENTER_HOMECAMP)
end

function PlatformShellJoinService.canAcceptHomeCampShellInvite(ownerUid, ownerPlayerInfo)
	local allowed, _, context = PlatformHomeCampEntryFilterService:canEnterHomeCamp(ownerUid, ownerPlayerInfo)

	if not allowed then
		PlatformNoticeUtils.showTextTipById(NoticeDef.CANNOT_ENTER_HOMECAMP)

		return false
	end

	return true
end

function PlatformShellJoinService.acceptHomeCampShellInviteAfterOwnerRefresh(connectionString, payload)
	local ownerUid = payload.inviterGameUid or ""
	local tokenInfo = PlatformShellJoinService.state.pendingTokens[connectionString]

	if not tokenInfo then
		return true
	end

	tokenInfo.playerInfoQueryUid = ownerUid
	tokenInfo.playerInfoQueryPurpose = PlatformPlayerInfoQueryService.RequestPurpose.ShellJoinHomeCampOwner
	tokenInfo.playerInfoQueryRequestKey = connectionString

	PlatformPlayerInfoQueryService:requestLatest(ownerUid, PlatformPlayerInfoQueryService.RequestPurpose.ShellJoinHomeCampOwner, {
		requestKey = connectionString
	}, function(ok, ownerPlayerInfo, reason)
		if not PlatformShellJoinService.state.pendingTokens[connectionString] then
			return
		end

		if reason == PlatformPlayerInfoQueryService.Reason.Superseded then
			PlatformShellJoinService.removePendingToken(connectionString)

			return
		end

		if ok ~= true then
			if reason == PlatformPlayerInfoQueryService.Reason.QueryUnavailable then
				logger:warn("home_camp_owner_info_query_unavailable uid=%s", tostring(ownerUid))
				PlatformShellJoinService.showHomeCampOwnerInfoFailedTip("home_camp_owner_info_query_unavailable", ownerUid)
				clearActivityForDroppedEnterWorldToken("shell_join_drop_home_camp_owner_info_query_unavailable", payload.tokenType)
				PlatformShellJoinService.removePendingToken(connectionString)

				return
			end

			if reason == PlatformPlayerInfoQueryService.Reason.QuerySkippedNoCache then
				logger:warn("home_camp_owner_info_query_skipped_no_cache uid=%s", tostring(ownerUid))
				PlatformShellJoinService.showHomeCampOwnerInfoFailedTip("home_camp_owner_info_missing_after_query", ownerUid)
				clearActivityForDroppedEnterWorldToken("shell_join_drop_home_camp_owner_info_missing_after_query", payload.tokenType)
				PlatformShellJoinService.removePendingToken(connectionString)

				return
			end

			if reason == PlatformPlayerInfoQueryService.Reason.RefreshedNoCache then
				logger:warn("home_camp_owner_info_missing_after_query uid=%s", tostring(ownerUid))
				PlatformShellJoinService.showHomeCampOwnerInfoFailedTip("home_camp_owner_info_missing_after_query", ownerUid)
				clearActivityForDroppedEnterWorldToken("shell_join_drop_home_camp_owner_info_missing_after_query", payload.tokenType)
				PlatformShellJoinService.removePendingToken(connectionString)

				return
			end

			logger:warn("home_camp_owner_info_query_failed uid=%s reason=%s", tostring(ownerUid), tostring(reason or ""))
			PlatformShellJoinService.showHomeCampOwnerInfoFailedTip("home_camp_owner_info_missing_after_query", ownerUid)
			clearActivityForDroppedEnterWorldToken("shell_join_drop_home_camp_owner_info_query_failed", payload.tokenType)
			PlatformShellJoinService.removePendingToken(connectionString)

			return
		end

		if reason == PlatformPlayerInfoQueryService.Reason.Cache then
			logger:debug("home_camp_owner_info_query_skipped_use_cache uid=%s", tostring(ownerUid))
		end

		if type(ownerPlayerInfo) ~= "table" then
			ownerPlayerInfo = PlatformShellJoinService.resolveHomeCampOwnerInfo(ownerUid)
		end

		if type(ownerPlayerInfo) ~= "table" then
			logger:warn("home_camp_owner_info_missing_after_query uid=%s", tostring(ownerUid))
			PlatformShellJoinService.showHomeCampOwnerInfoFailedTip("home_camp_owner_info_missing_after_query", ownerUid)
			clearActivityForDroppedEnterWorldToken("shell_join_drop_home_camp_owner_info_missing_after_query", payload.tokenType)
			PlatformShellJoinService.removePendingToken(connectionString)

			return
		end

		if not PlatformShellJoinService.canAcceptHomeCampShellInvite(ownerUid, ownerPlayerInfo) then
			clearActivityForDroppedEnterWorldToken("shell_join_drop_home_camp_entry_filter", payload.tokenType)
			PlatformShellJoinService.removePendingToken(connectionString)

			return
		end

		PlatformShellJoinService.sendShellInviteAccept(payload)
		PlatformShellJoinService.removePendingToken(connectionString)
	end)

	return true
end

function PlatformShellJoinService.dropForXboxTeamFunctionLocked(connectionString, tokenType, connectionStringLog, parsedFields, config)
	if PlatformIdentityUtils.getCurrentPlatformFamily() ~= PlatformIdentityUtils.Family.Xbox or not pg or not pg.me then
		return false
	end

	if PlatformShellJoinService.isTeamFunctionUnlocked() then
		return false
	end

	if PlatformShellJoinService.state.pendingTokens[connectionString] then
		PlatformShellJoinService.showTeamUnlockTip()
	end

	logger:info("PlatformShellJoinService._processPendingTokens drop: Xbox team function locked tokenType=%s connectionString=%s", tostring(tokenType), tostring(connectionStringLog))
	clearActivityForDroppedEnterWorldToken("shell_join_drop_xbox_team_function_locked", tokenType)
	PlatformShellJoinService.removePendingToken(connectionString)

	return "drop"
end

function PlatformShellJoinService.dropForTeamFunctionLocked(connectionString, tokenType, connectionStringLog, parsedFields, config)
	if PlatformShellJoinService.isTeamFunctionUnlocked() then
		return false
	end

	if PlatformShellJoinService.state.pendingTokens[connectionString] then
		PlatformShellJoinService.showTeamUnlockTip()
	end

	logger:info("PlatformShellJoinService._processPendingTokens drop: team function locked tokenType=%s connectionString=%s", tostring(tokenType), tostring(connectionStringLog))
	clearActivityForDroppedEnterWorldToken("shell_join_drop_team_function_locked", tokenType)
	PlatformShellJoinService.removePendingToken(connectionString)

	return true
end

function PlatformShellJoinService.dropForPreparingRoomConfirm(connectionString, tokenType, connectionStringLog, parsedFields, config)
	if not pg or not pg.me or type(pg.me.isInPreparingRoom) ~= "function" or not pg.me:isInPreparingRoom() then
		return false
	end

	local tokenInfo = PlatformShellJoinService.state.pendingTokens[connectionString]

	if not tokenInfo then
		return "handled"
	end

	if tokenInfo.preparingRoomConfirmState == "confirming" or tokenInfo.preparingRoomConfirmState == "leaving" then
		return "handled"
	end

	tokenInfo.preparingRoomConfirmState = "confirming"

	logger:info("PlatformShellJoinService._processPendingTokens preparing_room_confirm prompt tokenType=%s connectionString=%s", tostring(tokenType), tostring(connectionStringLog))

	local title = pg.getGameString and pg.getGameString("WARNING") or nil
	local content = pg.getGameString and pg.getGameString("LEAVE_TEAM_TIP") or ""

	pg.global.showConfirmMsgRaw(title, content, function()
		local currentTokenInfo = PlatformShellJoinService.state.pendingTokens[connectionString]

		if not currentTokenInfo then
			return
		end

		currentTokenInfo.preparingRoomConfirmState = "leaving"

		if pg and pg.me and type(pg.me.leaveTeam) == "function" then
			pg.me:leaveTeam()
		end
	end, nil, function()
		PlatformShellJoinService.removePendingToken(connectionString)
	end)

	return "handled"
end

function PlatformShellJoinService.dropForPreparingRoomEnterWorld(connectionString, tokenType, connectionStringLog, parsedFields, config)
	if not pg or not pg.me or type(pg.me.isInPreparingRoom) ~= "function" or not pg.me:isInPreparingRoom() then
		return false
	end

	if pg.global and pg.global.ui and pg.global.ui.tips then
		pg.global.ui.tips:showTextTip(pg.getGameString("TEAM_ALREADY_PREPARE"))
	end

	logger:info("PlatformShellJoinService._processPendingTokens drop: in preparing room, block enter-world tokenType=%s connectionString=%s", tostring(tokenType), tostring(connectionStringLog))
	clearActivityForDroppedEnterWorldToken("shell_join_drop_preparing_room", tokenType)
	PlatformShellJoinService.removePendingToken(connectionString)

	return "drop"
end

function PlatformShellJoinService.dropForAlreadyInTeam(connectionString, tokenType, connectionStringLog, parsedFields, config)
	if not pg.me.isInTeam or not pg.me:isInTeam() then
		return false
	end

	PlatformShellJoinService.removePendingToken(connectionString)

	return true
end

function PlatformShellJoinService.dropForMatchStatus(connectionString, tokenType, connectionStringLog, parsedFields, config)
	if pg.me.isGuidancePlayer == true then
		pg.global.ui.tips:showTextTip(pg.getGameString("APPLY_TEAM_STATUS_ERROR"))
		logger:info("PlatformShellJoinService._processPendingTokens drop: guidance player cannot join team tokenType=%s connectionString=%s", tostring(tokenType), tostring(connectionStringLog))
		PlatformShellJoinService.removePendingToken(connectionString)

		return true
	end

	local matchState = pg.me.matchState
	local matchStatus = pg.me.matchStatus

	if matchState == nil then
		local tokenInfo = PlatformShellJoinService.state.pendingTokens[connectionString]
		local logFunc = tokenInfo and tokenInfo.matchStatusSyncingLogged and logger.debug or logger.info

		if tokenInfo then
			tokenInfo.matchStatusSyncingLogged = true
		end

		logFunc(logger, "PlatformShellJoinService._processPendingTokens defer: match status syncing tokenType=%s matchState=%s matchStatus=%s connectionString=%s", tostring(tokenType), tostring(matchState), tostring(matchStatus), tostring(connectionStringLog))

		return "defer"
	end

	if PlatformShellActivityService.isConsoleMatchStatusInit(pg.me) then
		return false
	end

	if pg.global and pg.global.ui and pg.global.ui.tips then
		pg.global.ui.tips:showTextTip(pg.getGameString("APPLY_TEAM_STATUS_ERROR"))
	end

	logger:info("PlatformShellJoinService._processPendingTokens drop: match status not init tokenType=%s matchState=%s matchStatus=%s connectionString=%s", tostring(tokenType), tostring(matchState), tostring(matchStatus), tostring(connectionStringLog))
	clearActivityForDroppedEnterWorldToken("shell_join_drop_match_status", tokenType)
	PlatformShellJoinService.removePendingToken(connectionString)

	return true
end

function PlatformShellJoinService.checkHomeCampEntryFilter(connectionString, tokenType, connectionStringLog, parsedFields, config)
	local payload = config.buildPayload(parsedFields, tokenType)

	PlatformShellJoinService.acceptHomeCampShellInviteAfterOwnerRefresh(connectionString, payload)

	return "handled"
end

function PlatformShellJoinService.checkUGCDestinationEntryFilter(connectionString, tokenType, connectionStringLog, parsedFields, config)
	local payload = config.buildPayload(parsedFields, tokenType)

	PlatformShellJoinService.acceptShellInviteAfterDestinationPreflight(connectionString, payload)

	return "handled"
end

function PlatformShellJoinService.checkRequestEnterWorldDestinationEntryFilter(connectionString, tokenType, connectionStringLog, parsedFields, config)
	local payload = config.buildPayload(parsedFields, tokenType)

	PlatformShellJoinService:_acceptRequestEnterWorldAfterDestinationPreflight(connectionString, payload)

	return "handled"
end

PlatformShellJoinService.PRE_ACCEPT_DROP_CHECKS = {
	xboxTeamFunctionLocked = PlatformShellJoinService.dropForXboxTeamFunctionLocked,
	teamFunctionLocked = PlatformShellJoinService.dropForTeamFunctionLocked,
	preparingRoomConfirm = PlatformShellJoinService.dropForPreparingRoomConfirm,
	preparingRoomBlockEnterWorld = PlatformShellJoinService.dropForPreparingRoomEnterWorld,
	alreadyInTeam = PlatformShellJoinService.dropForAlreadyInTeam,
	matchStatus = PlatformShellJoinService.dropForMatchStatus,
	homeCampEntryFilter = PlatformShellJoinService.checkHomeCampEntryFilter,
	ugcDestinationEntryFilter = PlatformShellJoinService.checkUGCDestinationEntryFilter,
	requestEnterWorldDestinationEntryFilter = PlatformShellJoinService.checkRequestEnterWorldDestinationEntryFilter
}

function PlatformShellJoinService.dropForConfiguredChecks(connectionString, tokenType, config, connectionStringLog, parsedFields)
	local checkNames = config and config.preAcceptDropChecks or nil

	if type(checkNames) ~= "table" then
		return false
	end

	for _, checkName in ipairs(checkNames) do
		local checkFunc = PlatformShellJoinService.PRE_ACCEPT_DROP_CHECKS[checkName]

		if checkFunc then
			local result = checkFunc(connectionString, tokenType, connectionStringLog, parsedFields, config)

			if result == "handled" then
				return "handled"
			end

			if result == "defer" then
				return "defer"
			end

			if result == "drop" or result == true then
				if checkName == "alreadyInTeam" then
					return "drop", NoticeDef.PLATFORM_ERROR_ALREADY_IN_TEAM
				end

				return "drop"
			end
		end
	end

	return false
end

function PlatformShellJoinService.acceptPendingToken(connectionString, parsedFields, tokenType, config)
	local payload = config.buildPayload(parsedFields, tokenType)

	PlatformShellJoinService.sendShellInviteAccept(payload)
	PlatformShellJoinService.removePendingToken(connectionString)

	return "handled"
end

function PlatformShellJoinService:isSupported()
	return PlatformShellJoinService.isPlatformSupported() and PlatformShellJoinService.supportsMultiplayerActivity()
end

function PlatformShellJoinService:init(runtimeReady)
	if PlatformShellJoinService.state.initialized then
		return true
	end

	if not self:isSupported() then
		logger:warn("PlatformShellJoinService:init aborted: not supported isPlatformSupported=%s supportsMultiplayerActivity=%s", tostring(PlatformShellJoinService.isPlatformSupported()), tostring(PlatformShellJoinService.supportsMultiplayerActivity()))

		return false
	end

	if runtimeReady ~= true and not PlatformShellJoinService.isRuntimeReady() then
		logger:warn("PlatformShellJoinService:init aborted: runtime not ready runtimeReady=%s isRuntimeReady=%s", tostring(runtimeReady), tostring(PlatformShellJoinService.isRuntimeReady()))

		return false
	end

	if not PlatformShellJoinService.bindSignedInUser() then
		logger:warn("PlatformShellJoinService:init aborted: bindSignedInUser failed (no signed-in user)")

		return false
	end

	PlatformShellJoinService.state.initialized = true

	PlatformShellJoinService.startPolling()
	self:_pumpShellJoinEvents()
	self:_processPendingTokens()
	logger:info("PlatformShellJoinService:init success ownerUserId=%s", tostring(PlatformShellJoinService.state.ownerUserId))

	return true
end

function PlatformShellJoinService:shutdown()
	PlatformShellJoinService.stopPolling()

	PlatformShellJoinService.state.initialized = false

	self:clearPendingTextTip()
	self:clearDelayPremiumFeatureSessionUntilPlayerEnterScene()
	PlatformShellJoinService.resetPendingTokens(true)
end

function PlatformShellJoinService:peekPreLoginJoinIntent()
	if not self:isSupported() then
		return nil
	end

	if not PlatformShellJoinService.isRuntimeReady() then
		return nil
	end

	if not PlatformShellJoinService.bindSignedInUser() then
		return nil
	end

	if not PlatformBridgeLuaFacade.PeekShellJoinEvents then
		return nil
	end

	local selectedEvent, totalCount, uniqueValidCount = PlatformShellJoinService.selectLatestShellJoinEvent(PlatformBridgeLuaFacade.PeekShellJoinEvents())

	if not selectedEvent then
		return nil
	end

	local connectionString = tostring(selectedEvent.ConnectionString or "")
	local intent = PlatformShellJoinService.buildAutoLoginIntent(connectionString)

	if not intent then
		return nil
	end

	PlatformShellJoinService.state.selectedPreLoginConnectionString = connectionString

	logger:info("PlatformShellJoinService.peekPreLoginJoinIntent selected total=%s uniqueValid=%s connectionString=%s", tostring(totalCount), tostring(uniqueValidCount), PlatformShellJoinService.formatConnectionStringForLog(connectionString))

	return intent
end

function PlatformShellJoinService.shouldResolveMultiplayerPrivilege(csEvent)
	if PlatformIdentityUtils.getCurrentPlatformFamily() ~= PlatformIdentityUtils.Family.Xbox then
		return false
	end

	local eventType = tostring(csEvent and csEvent.EventType or "")

	return eventType == "ProtocolActivation" or eventType == "InviteAccepted"
end

function PlatformShellJoinService.resolveShellJoinMultiplayerPrivilege(onResolved)
	local resolved = false
	local timeoutTimer

	local function complete(allowed, reason)
		if resolved then
			return
		end

		resolved = true

		if timeoutTimer then
			TimerManager.removeTimer(timeoutTimer)

			timeoutTimer = nil
		end

		if type(onResolved) == "function" then
			onResolved(allowed == true, tostring(reason or ""))
		end
	end

	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.ResolveLocalMultiplayerPrivilege then
		complete(true, "")

		return
	end

	timeoutTimer = TimerManager.addTimer(PlatformShellJoinService.SHELL_JOIN_MULTIPLAYER_PRIVILEGE_TIMEOUT_SECONDS, function()
		timeoutTimer = nil

		complete(false, "resolve_timeout")
	end)

	PlatformBridgeLuaFacade.ResolveLocalMultiplayerPrivilege(PlatformShellJoinService.SHELL_JOIN_MULTIPLAYER_PRIVILEGE_TIMEOUT_SENTINEL, function(allowed, _, reason)
		if allowed == true and PlatformBridgeLuaFacade.GetLocalMultiplayerPrivilegeFailureReason then
			local hardReason = tostring(PlatformBridgeLuaFacade.GetLocalMultiplayerPrivilegeFailureReason() or "")

			if not string.isNilOrEmpty(hardReason) then
				complete(false, hardReason)

				return
			end
		end

		complete(allowed == true, reason)
	end)
end

function PlatformShellJoinService.enqueueShellJoinEventAfterMultiplayerPrivilege(csEvent)
	if not csEvent then
		return
	end

	local connectionString = tostring(csEvent.ConnectionString or "")

	if string.isNilOrEmpty(connectionString) then
		logger:warn("PlatformShellJoinService._pumpShellJoinEvents skipped: empty ConnectionString eventType=%s", tostring(csEvent.EventType))

		return
	end

	local connectionStringLog = PlatformShellJoinService.formatConnectionStringForLog(connectionString)

	if not PlatformShellJoinService.shouldResolveMultiplayerPrivilege(csEvent) then
		logger:info("PlatformShellJoinService._pumpShellJoinEvents enqueue connectionString=%s", connectionStringLog)
		PlatformShellJoinService.queuePendingToken(connectionString)

		return
	end

	local pendingEvents = PlatformShellJoinService.state.pendingMultiplayerPrivilegeEvents

	pendingEvents[#pendingEvents + 1] = {
		connectionString = connectionString,
		eventType = tostring(csEvent.EventType or "")
	}

	if PlatformShellJoinService.state.multiplayerPrivilegeUiPending then
		return
	end

	PlatformShellJoinService.state.multiplayerPrivilegeUiPending = true
	PlatformShellJoinService.state.multiplayerPrivilegeRequestId = PlatformShellJoinService.state.multiplayerPrivilegeRequestId + 1

	local requestId = PlatformShellJoinService.state.multiplayerPrivilegeRequestId
	local ownerUserId = PlatformShellJoinService.state.ownerUserId
	local dispatched, dispatchError = pcall(function()
		PlatformShellJoinService.resolveShellJoinMultiplayerPrivilege(function(allowed, reason)
			if requestId ~= PlatformShellJoinService.state.multiplayerPrivilegeRequestId then
				return
			end

			local resolvedEvents = PlatformShellJoinService.state.pendingMultiplayerPrivilegeEvents

			PlatformShellJoinService.state.pendingMultiplayerPrivilegeEvents = {}
			PlatformShellJoinService.state.multiplayerPrivilegeUiPending = false

			if PlatformShellJoinService.state.initialized ~= true or PlatformShellJoinService.state.ownerUserId ~= ownerUserId then
				return
			end

			if allowed ~= true then
				logger:info("PlatformShellJoinService dropped Xbox shell join after Multiplayer privilege denial reason=%s count=%s", tostring(reason or ""), tostring(#resolvedEvents))

				return
			end

			for _, resolvedEvent in ipairs(resolvedEvents) do
				PlatformShellJoinService.queuePendingToken(resolvedEvent.connectionString)
			end
		end)
	end)

	if dispatched then
		return
	end

	if requestId == PlatformShellJoinService.state.multiplayerPrivilegeRequestId then
		PlatformShellJoinService.state.pendingMultiplayerPrivilegeEvents = {}
		PlatformShellJoinService.state.multiplayerPrivilegeUiPending = false
	end

	logger:warn("PlatformShellJoinService failed to dispatch Multiplayer privilege UI error=%s", tostring(dispatchError))
end

function PlatformShellJoinService:_pumpShellJoinEvents()
	if not PlatformShellJoinService.state.initialized then
		return
	end

	if not PlatformShellJoinService.bindSignedInUser() then
		return
	end

	local events = PlatformBridgeLuaFacade.PumpShellJoinEvents and PlatformBridgeLuaFacade.PumpShellJoinEvents()

	if not events then
		return
	end

	local requiredConnectionString = PlatformShellJoinService.state.selectedPreLoginConnectionString
	local selectedEvent, totalCount, uniqueValidCount = PlatformShellJoinService.selectLatestShellJoinEvent(events, requiredConnectionString)

	PlatformShellJoinService.state.selectedPreLoginConnectionString = ""

	if not selectedEvent then
		if totalCount > 0 then
			logger:warn("PlatformShellJoinService._pumpShellJoinEvents dropped all events total=%s hasPreLoginSelection=%s", tostring(totalCount), tostring(not string.isNilOrEmpty(requiredConnectionString)))
		end

		return
	end

	logger:info("PlatformShellJoinService._pumpShellJoinEvents selected total=%s uniqueValid=%s dropped=%s connectionString=%s", tostring(totalCount), tostring(uniqueValidCount), tostring(math.max(totalCount - 1, 0)), PlatformShellJoinService.formatConnectionStringForLog(selectedEvent.ConnectionString))
	PlatformShellJoinService.enqueueShellJoinEventAfterMultiplayerPrivilege(selectedEvent)
end

function PlatformShellJoinService:_processPendingTokens()
	if not PlatformShellJoinService.state.initialized then
		return
	end

	if not PlatformShellJoinService.bindSignedInUser() then
		return
	end

	if not pg or not pg.me then
		return
	end

	local connectionStrings = {}

	for connectionString, _ in pairs(PlatformShellJoinService.state.pendingTokens) do
		connectionStrings[#connectionStrings + 1] = connectionString
	end

	for _, connectionString in ipairs(connectionStrings) do
		self:_processOneConnectString(connectionString)
	end
end

function PlatformShellJoinService:_processOneConnectString(connectionString)
	local parsedFields = PlatformShellTokenUtils.parseConnectionString(connectionString)
	local tokenType = parsedFields.tokenType
	local connectionStringLog = PlatformShellJoinService.formatConnectionStringForLog(connectionString)

	if tokenType == "InviteEnterPhotoWorld" then
		logger:info("[PHOTO_SHELL] invitee _processOneConnectString received inviterUid=%s serverId=%s", tostring(parsedFields and parsedFields.inviterGameUid or ""), tostring(parsedFields and parsedFields.serverId or ""))
	end

	if not PlatformShellJoinService.validateRequiredFields(parsedFields, connectionString) then
		logger:warn("PlatformShellJoinService._processPendingTokens tokenType empty, connectionString=%s", connectionStringLog)
		PlatformShellJoinService.removePendingToken(connectionString)

		return
	end

	if not PlatformShellJoinService.isGameServerConnected() then
		PlatformShellJoinService.logServerNotConnectedDeferred(connectionString, connectionStringLog)

		return
	end

	local sameLoginServer, compareMode, inviterId, inviterName, currentId, currentName = PlatformShellJoinService.isSameLoginServer(parsedFields)

	if not sameLoginServer then
		PlatformShellJoinService.showServerMismatchTip()
		logger:warn("PlatformShellJoinService._processPendingTokens drop: login server mismatch compareMode=%s inviterId=%s inviterName=%s currentId=%s currentName=%s connectionString=%s", tostring(compareMode), tostring(inviterId), tostring(inviterName), tostring(currentId), tostring(currentName), connectionStringLog)
		PlatformShellJoinService.removePendingToken(connectionString)

		return
	end

	if not PlatformShellTokenUtils.isKnownTokenType(tokenType) then
		logger:warn("PlatformShellJoinService._processPendingTokens branch=unknown_token_type connectionString=%s", connectionStringLog)
		PlatformShellJoinService.removePendingToken(connectionString)
	end

	local config = PlatformShellTokenUtils.getAcceptTokenConfig(tokenType)

	if not config then
		logger:warn("PlatformShellJoinService._processPendingTokens branch=missing_token_config connectionString=%s", connectionStringLog)
		PlatformShellJoinService.removePendingToken(connectionString)

		return
	end

	local checkResult, msgKey = PlatformShellJoinService.dropForConfiguredChecks(connectionString, tokenType, config, connectionStringLog, parsedFields)

	if not string.isNilOrEmpty(msgKey) then
		PlatformShellJoinService.showTextTipByIdAfterPlayerEnterScene(msgKey)
	end

	if checkResult == "drop" or checkResult == "handled" or checkResult == "defer" then
		return
	end

	PlatformShellJoinService.acceptPendingToken(connectionString, parsedFields, tokenType, config)
end

return PlatformShellJoinService
