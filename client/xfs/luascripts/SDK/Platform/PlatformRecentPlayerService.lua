-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformRecentPlayerService.lua

local logger = require("SDK.Platform.PlatformLogger")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformPrivacyUtils = require("SDK.Platform.PlatformPrivacyUtils")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local PlatformRecentPlayerService = {}

PlatformRecentPlayerService.ENCOUNTER_TYPE_TEAMMATE = "teammate"
PlatformRecentPlayerService.ENCOUNTER_TYPE_OPPONENT = "opponent"
PlatformRecentPlayerService.MAX_WARN_ONCE_KEYS = 128
PlatformRecentPlayerService.state = {
	ownerUserId = "",
	enabled = false,
	initialized = false,
	warnOnceKeys = {},
	warnOnceKeyOrder = {},
	pendingQueryKeys = {}
}

function PlatformRecentPlayerService.isPlatformSupported()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.IsSupported and PlatformBridgeLuaFacade.IsSupported()
end

function PlatformRecentPlayerService.supportsRecentPlayers()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.SupportsRecentPlayers and PlatformBridgeLuaFacade.SupportsRecentPlayers() == true
end

function PlatformRecentPlayerService.isRuntimeReady()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.IsRuntimeInitialized and PlatformBridgeLuaFacade.IsRuntimeInitialized() == true
end

function PlatformRecentPlayerService.getSignedInUserId()
	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.GetSignedInUserId then
		return ""
	end

	local userId = PlatformBridgeLuaFacade.GetSignedInUserId()

	if string.isNilOrEmpty(userId) then
		return ""
	end

	return tostring(userId)
end

function PlatformRecentPlayerService.resetOwnerBoundState(clearOwner)
	PlatformRecentPlayerService.state.warnOnceKeys = {}
	PlatformRecentPlayerService.state.warnOnceKeyOrder = {}
	PlatformRecentPlayerService.state.pendingQueryKeys = {}

	if clearOwner ~= false then
		PlatformRecentPlayerService.state.ownerUserId = ""
	end
end

function PlatformRecentPlayerService.trimKeyedSet(indexTable, keyOrder, maxCount)
	while maxCount < #keyOrder do
		local removedKey = table.remove(keyOrder, 1)

		if removedKey ~= nil then
			indexTable[removedKey] = nil
		end
	end
end

function PlatformRecentPlayerService.bindSignedInUser()
	local ownerUserId = PlatformRecentPlayerService.getSignedInUserId()

	if string.isNilOrEmpty(ownerUserId) then
		PlatformRecentPlayerService.resetOwnerBoundState()

		return false
	end

	if PlatformRecentPlayerService.state.ownerUserId ~= ownerUserId then
		PlatformRecentPlayerService.resetOwnerBoundState(false)

		PlatformRecentPlayerService.state.ownerUserId = ownerUserId
	end

	return true
end

function PlatformRecentPlayerService.isValidEncounterType(encounterType)
	return encounterType == PlatformRecentPlayerService.ENCOUNTER_TYPE_TEAMMATE or encounterType == PlatformRecentPlayerService.ENCOUNTER_TYPE_OPPONENT
end

function PlatformRecentPlayerService.normalizeUserId(value)
	if value == nil then
		return nil
	end

	local text = tostring(value)

	if string.isNilOrEmpty(text) or text == "0" then
		return nil
	end

	return text
end

function PlatformRecentPlayerService.buildPendingQueryKey(encounterType, targetUid, sourceReason)
	return string.format("%s:%s:%s", tostring(encounterType), tostring(targetUid), tostring(sourceReason))
end

function PlatformRecentPlayerService.isSelfUserId(targetUserId)
	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.GetSignedInUserId then
		return false
	end

	local signedInUserId = PlatformRecentPlayerService.normalizeUserId(PlatformBridgeLuaFacade.GetSignedInUserId())

	return signedInUserId ~= nil and signedInUserId == PlatformRecentPlayerService.normalizeUserId(targetUserId)
end

function PlatformRecentPlayerService.resolvePlatformUserId(playerInfo)
	return PlatformRecentPlayerService.normalizeUserId(PlatformIdentityUtils.resolvePlatformUserId(playerInfo))
end

function PlatformRecentPlayerService.resolvePlatformFamily(playerInfo)
	if type(PlatformIdentityUtils) ~= "table" or type(PlatformIdentityUtils.resolvePlayerInfoFamily) ~= "function" then
		return nil
	end

	local family = PlatformIdentityUtils.resolvePlayerInfoFamily(playerInfo)

	if type(PlatformIdentityUtils.normalizeFamily) == "function" then
		return PlatformIdentityUtils.normalizeFamily(family)
	end

	return family
end

function PlatformRecentPlayerService.getCurrentPlatformFamily()
	if type(PlatformIdentityUtils) ~= "table" or type(PlatformIdentityUtils.getCurrentPlatformFamily) ~= "function" then
		return nil
	end

	local family = PlatformIdentityUtils.getCurrentPlatformFamily()

	if type(PlatformIdentityUtils.normalizeFamily) == "function" then
		return PlatformIdentityUtils.normalizeFamily(family)
	end

	return family
end

function PlatformRecentPlayerService.isSameCurrentPlatformFamily(playerInfo)
	local currentFamily = PlatformRecentPlayerService.getCurrentPlatformFamily()
	local targetFamily = PlatformRecentPlayerService.resolvePlatformFamily(playerInfo)

	if string.isNilOrEmpty(currentFamily) or string.isNilOrEmpty(targetFamily) then
		return false
	end

	if currentFamily == PlatformIdentityUtils.UnknownFamily or targetFamily == PlatformIdentityUtils.UnknownFamily then
		return false
	end

	local familyConst = PlatformIdentityUtils.Family or {}

	if currentFamily == familyConst.Other or targetFamily == familyConst.Other then
		return false
	end

	return currentFamily == targetFamily
end

function PlatformRecentPlayerService.resolveUid(candidateUid, playerInfo)
	local uid = PlatformRecentPlayerService.normalizeUserId(candidateUid)

	if uid ~= nil then
		return uid
	end

	if type(playerInfo) ~= "table" then
		return nil
	end

	return PlatformRecentPlayerService.normalizeUserId(playerInfo.uid or playerInfo.playerId)
end

function PlatformRecentPlayerService.hasPlatformIdentity(playerInfo)
	return PlatformRecentPlayerService.resolvePlatformUserId(playerInfo) ~= nil
end

function PlatformRecentPlayerService.hasReportablePlatformIdentity(playerInfo)
	return PlatformRecentPlayerService.resolvePlatformUserId(playerInfo) ~= nil and PlatformRecentPlayerService.isSameCurrentPlatformFamily(playerInfo)
end

function PlatformRecentPlayerService.resolveChatPlayerInfo(uid)
	if string.isNilOrEmpty(uid) then
		return nil
	end

	if pg and pg.game and pg.game.chat and pg.game.chat.getPlayerInfo then
		local playerInfo = pg.game.chat:getPlayerInfo(tostring(uid))

		if type(playerInfo) == "table" and PlatformRecentPlayerService.hasReportablePlatformIdentity(playerInfo) then
			return playerInfo
		end
	end

	return nil
end

function PlatformRecentPlayerService.logWarnOnce(warnKey, message, ...)
	if PlatformRecentPlayerService.state.warnOnceKeys[warnKey] then
		return
	end

	PlatformRecentPlayerService.state.warnOnceKeys[warnKey] = true

	table.insert(PlatformRecentPlayerService.state.warnOnceKeyOrder, warnKey)
	PlatformRecentPlayerService.trimKeyedSet(PlatformRecentPlayerService.state.warnOnceKeys, PlatformRecentPlayerService.state.warnOnceKeyOrder, PlatformRecentPlayerService.MAX_WARN_ONCE_KEYS)
	logger:warn(message, ...)
end

function PlatformRecentPlayerService.reportRecentPlayer(targetUserId, encounterType, sourceReason)
	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.ReportRecentPlayer then
		return false
	end

	targetUserId = PlatformRecentPlayerService.normalizeUserId(targetUserId)

	if targetUserId == nil or not PlatformRecentPlayerService.isValidEncounterType(encounterType) or PlatformRecentPlayerService.isSelfUserId(targetUserId) then
		return false
	end

	PlatformBridgeLuaFacade.ReportRecentPlayer(targetUserId, encounterType, sourceReason or "", 0, function(success, result, message)
		if success then
			if PlatformPrivacyUtils:shouldRedactSensitiveLogs() then
				logger:info("上报 recent player 成功 encounterType=%s sourceReason=%s result=%s", tostring(encounterType), tostring(sourceReason), tostring(result))
			else
				logger:info("上报 recent player 成功 encounterType=%s targetUserId=%s sourceReason=%s result=%s", tostring(encounterType), tostring(targetUserId), tostring(sourceReason), tostring(result))
			end

			return
		end

		if PlatformPrivacyUtils:shouldRedactSensitiveLogs() then
			logger:warn("上报 recent player 失败 encounterType=%s sourceReason=%s result=%s message=%s", tostring(encounterType), tostring(sourceReason), tostring(result), tostring(message))
		else
			logger:warn("上报 recent player 失败 encounterType=%s targetUserId=%s sourceReason=%s result=%s message=%s", tostring(encounterType), tostring(targetUserId), tostring(sourceReason), tostring(result), tostring(message))
		end
	end)

	return true
end

function PlatformRecentPlayerService.isPvpMetadataKey(key)
	return key == "additionInfo" or key == "endTime"
end

function PlatformRecentPlayerService.collectPvpPlayerInfos(source, sourcePath, collector, candidateUid)
	if type(source) ~= "table" or type(collector) ~= "function" then
		return
	end

	if source.uid ~= nil then
		collector(source, sourcePath, source.uid or candidateUid)

		return
	end

	if candidateUid ~= nil then
		collector(source, sourcePath, candidateUid)

		return
	end

	for key, value in pairs(source) do
		if type(value) == "table" then
			local childPath = string.format("%s.%s", tostring(sourcePath), tostring(key))

			if value.uid ~= nil then
				collector(value, childPath, value.uid or key)
			elseif type(key) == "string" and not PlatformRecentPlayerService.isPvpMetadataKey(key) then
				local childCandidateUid

				if key ~= "roomInfo" and key ~= "matchInfo" and key ~= "matchInfos" then
					childCandidateUid = key
				end

				PlatformRecentPlayerService.collectPvpPlayerInfos(value, childPath, collector, childCandidateUid)
			else
				PlatformRecentPlayerService.collectPvpPlayerInfos(value, childPath, collector)
			end
		end
	end
end

function PlatformRecentPlayerService.logMissingIdentity(warnPrefix, sourceReason, targetUid, warnMessage)
	if PlatformPrivacyUtils:shouldRedactSensitiveLogs() then
		PlatformRecentPlayerService.logWarnOnce(string.format("%s:%s", tostring(warnPrefix), tostring(sourceReason)), warnMessage .. " sourceReason=%s", tostring(sourceReason))
	else
		PlatformRecentPlayerService.logWarnOnce(string.format("%s:%s:%s", tostring(warnPrefix), tostring(sourceReason), tostring(targetUid)), warnMessage .. " sourceReason=%s uid=%s", tostring(sourceReason), tostring(targetUid))
	end
end

function PlatformRecentPlayerService.reportResolvedPlayerInfo(playerInfo, targetUid, encounterType, sourceReason)
	local resolvedPlayerInfo = playerInfo
	local targetUserId = PlatformRecentPlayerService.resolvePlatformUserId(resolvedPlayerInfo)

	if targetUserId and not PlatformRecentPlayerService.isSameCurrentPlatformFamily(resolvedPlayerInfo) then
		return false
	end

	if not targetUserId then
		resolvedPlayerInfo = PlatformRecentPlayerService.resolveChatPlayerInfo(targetUid)
		targetUserId = PlatformRecentPlayerService.resolvePlatformUserId(resolvedPlayerInfo)

		if targetUserId and not PlatformRecentPlayerService.isSameCurrentPlatformFamily(resolvedPlayerInfo) then
			return false
		end
	end

	if targetUserId then
		return PlatformRecentPlayerService.reportRecentPlayer(targetUserId, encounterType, sourceReason)
	end

	return false
end

function PlatformRecentPlayerService.queryAndReportPlayerInfo(targetUid, encounterType, sourceReason, warnPrefix, warnMessage)
	targetUid = PlatformRecentPlayerService.normalizeUserId(targetUid)

	if targetUid == nil then
		return false
	end

	local selfUid = tostring(pg and pg.me and pg.me.uid or "")

	if not string.isNilOrEmpty(selfUid) and targetUid == selfUid then
		return false
	end

	local pendingKey = PlatformRecentPlayerService.buildPendingQueryKey(encounterType, targetUid, sourceReason)

	if PlatformRecentPlayerService.state.pendingQueryKeys[pendingKey] then
		return false
	end

	if not pg or not pg.me or not pg.me.queryPlayerInfo then
		PlatformRecentPlayerService.logMissingIdentity(warnPrefix, sourceReason, targetUid, warnMessage)

		return false
	end

	PlatformRecentPlayerService.state.pendingQueryKeys[pendingKey] = true

	pg.me:queryPlayerInfo(targetUid, nil, true, function(queriedPlayerInfo)
		PlatformRecentPlayerService.state.pendingQueryKeys[pendingKey] = nil

		local resolvedPlayerInfo = queriedPlayerInfo

		if type(resolvedPlayerInfo) ~= "table" and pg and pg.game and pg.game.chat and pg.game.chat.getPlayerInfo then
			resolvedPlayerInfo = pg.game.chat:getPlayerInfo(targetUid)
		end

		if not PlatformRecentPlayerService.reportResolvedPlayerInfo(resolvedPlayerInfo, targetUid, encounterType, sourceReason) then
			PlatformRecentPlayerService.logMissingIdentity(warnPrefix, sourceReason, targetUid, warnMessage)
		end
	end)

	return true
end

function PlatformRecentPlayerService.reportPvpPlayerInfo(playerInfo, sourceReason, warnPrefix, warnMessage, candidateUid)
	local selfUid = tostring(pg and pg.me and pg.me.uid or "")
	local targetUid = PlatformRecentPlayerService.resolveUid(candidateUid, playerInfo)

	if not string.isNilOrEmpty(selfUid) and targetUid == selfUid then
		return false
	end

	if PlatformRecentPlayerService.reportResolvedPlayerInfo(playerInfo, targetUid, PlatformRecentPlayerService.ENCOUNTER_TYPE_OPPONENT, sourceReason) then
		return true
	end

	if PlatformRecentPlayerService.queryAndReportPlayerInfo(targetUid, PlatformRecentPlayerService.ENCOUNTER_TYPE_OPPONENT, sourceReason, warnPrefix, warnMessage) then
		return false
	end

	PlatformRecentPlayerService.logMissingIdentity(warnPrefix, sourceReason, targetUid, warnMessage)

	return false
end

function PlatformRecentPlayerService:isSupported()
	return PlatformRecentPlayerService.isPlatformSupported() and PlatformRecentPlayerService.supportsRecentPlayers()
end

function PlatformRecentPlayerService:init(runtimeReady)
	if PlatformRecentPlayerService.state.initialized and PlatformRecentPlayerService.state.enabled then
		return true
	end

	if not self:isSupported() then
		PlatformRecentPlayerService.state.enabled = false

		return false
	end

	if runtimeReady ~= true and not PlatformRecentPlayerService.isRuntimeReady() then
		PlatformRecentPlayerService.state.initialized = true
		PlatformRecentPlayerService.state.enabled = false

		return false
	end

	PlatformRecentPlayerService.state.initialized = true

	if not PlatformRecentPlayerService.bindSignedInUser() then
		PlatformRecentPlayerService.state.enabled = false

		return false
	end

	PlatformRecentPlayerService.state.enabled = true

	logger:info("PlatformRecentPlayerService 已启动。")

	return true
end

function PlatformRecentPlayerService:shutdown()
	PlatformRecentPlayerService.state.initialized = false
	PlatformRecentPlayerService.state.enabled = false

	PlatformRecentPlayerService.resetOwnerBoundState()
end

function PlatformRecentPlayerService:resetReportedState()
	PlatformRecentPlayerService.resetOwnerBoundState(false)
end

function PlatformRecentPlayerService:_ensureReady()
	if not self:isSupported() then
		PlatformRecentPlayerService.resetOwnerBoundState()

		return false
	end

	if not PlatformRecentPlayerService.state.enabled then
		return self:init()
	end

	return PlatformRecentPlayerService.isRuntimeReady() and PlatformRecentPlayerService.bindSignedInUser()
end

function PlatformRecentPlayerService:reportTeamMembers(teamInfo, sourceReason)
	if not self:_ensureReady() then
		return false
	end

	local membersInfo = teamInfo and teamInfo.membersInfo

	if type(membersInfo) ~= "table" then
		return false
	end

	local selfUid = tostring(pg and pg.me and pg.me.uid or "")
	local memberCount = 0
	local reportedCount = 0
	local missingIdentityCount = 0

	for uid, memberInfo in pairs(membersInfo) do
		memberCount = memberCount + 1

		local targetUid = PlatformRecentPlayerService.resolveUid(uid, memberInfo)

		if not string.isNilOrEmpty(targetUid) and targetUid ~= selfUid then
			local reported = false

			reported = PlatformRecentPlayerService.reportResolvedPlayerInfo(memberInfo, targetUid, PlatformRecentPlayerService.ENCOUNTER_TYPE_TEAMMATE, sourceReason)

			if reported then
				reportedCount = reportedCount + 1
			else
				missingIdentityCount = missingIdentityCount + 1

				if not PlatformRecentPlayerService.queryAndReportPlayerInfo(targetUid, PlatformRecentPlayerService.ENCOUNTER_TYPE_TEAMMATE, sourceReason, "team", "recent player 跳过: team member 无平台身份") then
					PlatformRecentPlayerService.logMissingIdentity("team", sourceReason, targetUid, "recent player 跳过: team member 无平台身份")
				end
			end
		end
	end

	logger:info("recent player team report sourceReason=%s members=%s reported=%s missingIdentity=%s", tostring(sourceReason), tostring(memberCount), tostring(reportedCount), tostring(missingIdentityCount))

	return reportedCount > 0
end

function PlatformRecentPlayerService:reportPvpRoom(roomPlayersInfo, sourceReason)
	if not self:_ensureReady() then
		return false
	end

	if type(roomPlayersInfo) ~= "table" then
		return false
	end

	local reportCount = 0

	PlatformRecentPlayerService.collectPvpPlayerInfos(roomPlayersInfo, "roomPlayersInfo", function(playerInfo, _, candidateUid)
		if PlatformRecentPlayerService.reportPvpPlayerInfo(playerInfo, sourceReason, "pvp_room", "recent player 跳过: pvp room player 无平台身份", candidateUid) then
			reportCount = reportCount + 1
		end
	end)

	return reportCount > 0
end

function PlatformRecentPlayerService:reportMatchReady(matchInfo, sourceReason)
	if not self:_ensureReady() then
		return false
	end

	local reportCount = 0

	PlatformRecentPlayerService.collectPvpPlayerInfos(matchInfo, "matchInfo", function(playerInfo, _, candidateUid)
		if PlatformRecentPlayerService.reportPvpPlayerInfo(playerInfo, sourceReason, "match_ready", "recent player 跳过: matchInfo opponent 无平台身份", candidateUid) then
			reportCount = reportCount + 1
		end
	end)

	if reportCount == 0 then
		PlatformRecentPlayerService.logWarnOnce(string.format("match_ready:%s", tostring(sourceReason)), "recent player 跳过: matchInfo opponent 无平台身份 sourceReason=%s checked=matchInfo", tostring(sourceReason))
	end

	return reportCount > 0
end

return PlatformRecentPlayerService
