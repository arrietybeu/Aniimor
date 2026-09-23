-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformAchievementService.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("SDK.Platform.PlatformLogger")
local TimerManager = require("Core.Timer.TimerManager")
local PlatformAchievementTriggerService = require("SDK.Platform.PlatformAchievementTriggerService")
local PlatformAchievementRuleConfig = require("SDK.Platform.PlatformAchievementRuleConfig")
local json = require("json")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local PlatformAchievementService = {}

PlatformAchievementService.EVENT_INITIAL_STATE_SYNCED = "initialStateSynced"
PlatformAchievementService.EVENT_ACHIEVEMENTS_UPDATED = "achievementsUpdated"
PlatformAchievementService.EVENT_ACHIEVEMENT_PROGRESS_UPDATED = "achievementProgressUpdated"
PlatformAchievementService.EVENT_ACHIEVEMENT_UNLOCKED = "achievementUnlocked"
PlatformAchievementService.POLL_INTERVAL = 0
PlatformAchievementService.STEAM_QUERY_TIMEOUT_MS = 10000
PlatformAchievementService.NOT_SUPPORTED_RESULT = -1
PlatformAchievementService.RUNTIME_NOT_READY_RESULT = -2
PlatformAchievementService.INVALID_ARGUMENT_RESULT = -3
PlatformAchievementService.state = {
	hasLoggedReadySnapshot = false,
	ownerUserId = "",
	initialStateSynced = false,
	initialized = false,
	managerReady = false,
	achievements = {},
	achievementIndex = {},
	listeners = {
		[PlatformAchievementService.EVENT_INITIAL_STATE_SYNCED] = {},
		[PlatformAchievementService.EVENT_ACHIEVEMENTS_UPDATED] = {},
		[PlatformAchievementService.EVENT_ACHIEVEMENT_PROGRESS_UPDATED] = {},
		[PlatformAchievementService.EVENT_ACHIEVEMENT_UNLOCKED] = {}
	}
}

function PlatformAchievementService.isPlatformSupported()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.IsSupported and PlatformBridgeLuaFacade.IsSupported()
end

function PlatformAchievementService.supportsAchievements()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.SupportsAchievements and PlatformBridgeLuaFacade.SupportsAchievements() == true
end

function PlatformAchievementService.isRuntimeReady()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.IsRuntimeInitialized and PlatformBridgeLuaFacade.IsRuntimeInitialized() == true
end

function PlatformAchievementService.isNativeSignInSkipped()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.IsIdentitySkipped and PlatformBridgeLuaFacade.IsIdentitySkipped() == true
end

function PlatformAchievementService.getSignedInUserId()
	if PlatformAchievementService.isNativeSignInSkipped() then
		if pg.global.platform.getSdkFpId then
			local sdkFpId = pg.global.platform:getSdkFpId()

			if not string.isNilOrEmpty(sdkFpId) then
				return tostring(sdkFpId)
			end
		end

		logger:warn("isNativeSignInSkipped but getSdkFpId is nil")

		return ""
	end

	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.GetSignedInUserId then
		return ""
	end

	local userId = PlatformBridgeLuaFacade.GetSignedInUserId()

	if string.isNilOrEmpty(userId) then
		return ""
	end

	return tostring(userId)
end

function PlatformAchievementService:queryConfiguredSteamAchievements()
	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.QueryAchievement then
		logger:warn("FPX achievement/get bridge is unavailable")

		return
	end

	local steamIds = {}

	for _, rule in ipairs(PlatformAchievementRuleConfig.getRules()) do
		local platformAchievementId = self:getPlatformAchievementId(rule.achievementId)

		if not string.isNilOrEmpty(platformAchievementId) then
			table.insert(steamIds, tostring(platformAchievementId))
		end
	end

	logger:info("FPX achievement/get 开始批量查询 steamIdCount=%s", tostring(#steamIds))
	PlatformBridgeLuaFacade.QueryAchievement(steamIds, PlatformAchievementService.STEAM_QUERY_TIMEOUT_MS, function(success, result, message)
		if success then
			logger:info("FPX achievement/get 批量查询完成")
		else
			logger:warn("FPX achievement/get 批量查询失败 result=%s message=%s", tostring(result), tostring(message))
		end
	end)
end

function PlatformAchievementService.resetCachedAchievementState(clearOwner)
	PlatformAchievementService.state.achievements = {}
	PlatformAchievementService.state.achievementIndex = {}
	PlatformAchievementService.state.initialStateSynced = false
	PlatformAchievementService.state.hasLoggedReadySnapshot = false
	PlatformAchievementService.state.managerReady = false

	if clearOwner ~= false then
		PlatformAchievementService.state.ownerUserId = ""
	end
end

function PlatformAchievementService.bindSignedInUser()
	local ownerUserId = PlatformAchievementService.getSignedInUserId()

	if string.isNilOrEmpty(ownerUserId) then
		PlatformAchievementService.resetCachedAchievementState()

		return false
	end

	if PlatformAchievementService.state.ownerUserId ~= ownerUserId then
		PlatformAchievementService.resetCachedAchievementState(false)

		PlatformAchievementService.state.ownerUserId = ownerUserId
	end

	return true
end

function PlatformAchievementService.iterateCsCollection(collection, handler)
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
	end
end

function PlatformAchievementService.buildAchievementList(csAchievements)
	local list = {}
	local index = {}

	PlatformAchievementService.iterateCsCollection(csAchievements, function(csAchievement)
		if not csAchievement then
			return
		end

		local achievementId = tostring(csAchievement.AchievementId or "")

		if string.isNilOrEmpty(achievementId) then
			return
		end

		local entry = {
			achievementId = achievementId,
			name = csAchievement.Name or "",
			progressState = csAchievement.ProgressState or "",
			currentProgressValue = tostring(csAchievement.CurrentProgressValue or ""),
			targetProgressValue = tostring(csAchievement.TargetProgressValue or ""),
			unlockedDescription = csAchievement.UnlockedDescription or "",
			lockedDescription = csAchievement.LockedDescription or "",
			isSecret = csAchievement.IsSecret == true,
			isRevoked = csAchievement.IsRevoked == true,
			unlockedTimeUnixSeconds = tonumber(csAchievement.UnlockedTimeUnixSeconds or 0) or 0
		}

		table.insert(list, entry)

		index[achievementId] = entry
	end)
	table.sort(list, function(a, b)
		return tostring(a.achievementId) < tostring(b.achievementId)
	end)

	return list, index
end

function PlatformAchievementService.buildEventPayload(csEvent)
	if not csEvent then
		return nil
	end

	return {
		eventType = tostring(csEvent.EventType or ""),
		achievementId = tostring(csEvent.AchievementId or ""),
		progressState = tostring(csEvent.ProgressState or ""),
		currentProgressValue = tostring(csEvent.CurrentProgressValue or ""),
		targetProgressValue = tostring(csEvent.TargetProgressValue or "")
	}
end

function PlatformAchievementService.sanitizeLogValue(value)
	local text = tostring(value or "")

	text = string.gsub(text, "\r", "\\r")
	text = string.gsub(text, "\n", "\\n")

	return text
end

function PlatformAchievementService.logReadyAchievementSnapshot(achievements)
	if PlatformAchievementService.state.hasLoggedReadySnapshot then
		return
	end

	local achievementCount = achievements and #achievements or 0

	if not PlatformAchievementService.state.initialStateSynced and achievementCount <= 0 then
		return
	end

	PlatformAchievementService.state.hasLoggedReadySnapshot = true

	local achieved = {}
	local inProgress = {}
	local notStartedCount = 0
	local otherCount = 0

	for _, achievement in ipairs(achievements or EMPTY_TABLE) do
		local progressState = tostring(achievement.progressState or "")
		local name = PlatformAchievementService.sanitizeLogValue(achievement.name)

		if progressState == "Achieved" or progressState == "Unlocked" then
			table.insert(achieved, name)
		elseif progressState == "InProgress" then
			local current = tonumber(achievement.currentProgressValue) or 0
			local target = tonumber(achievement.targetProgressValue) or 0
			local percent = target > 0 and math.floor(current / target * 100 + 0.5) or 0

			table.insert(inProgress, string.format("%s(%d%%)", name, percent))
		elseif progressState == "NotStarted" then
			notStartedCount = notStartedCount + 1
		else
			otherCount = otherCount + 1
		end
	end

	local parts = {}

	if #achieved > 0 then
		table.insert(parts, string.format("Achieved=[%s]", table.concat(achieved, "、")))
	end

	if #inProgress > 0 then
		table.insert(parts, string.format("InProgress=[%s]", table.concat(inProgress, "、")))
	end

	if notStartedCount > 0 then
		table.insert(parts, string.format("NotStarted=%d", notStartedCount))
	end

	if otherCount > 0 then
		table.insert(parts, string.format("Other=%d", otherCount))
	end

	logger:info("平台成就快照就绪 count=%s [%s]", tostring(achievementCount), table.concat(parts, ", "))
end

function PlatformAchievementService.notifyListeners(eventName, payload)
	local bucket = PlatformAchievementService.state.listeners[eventName]

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

function PlatformAchievementService.stopPolling()
	if not PlatformAchievementService.state.pollTimerId then
		return
	end

	TimerManager.removeTimer(PlatformAchievementService.state.pollTimerId)

	PlatformAchievementService.state.pollTimerId = nil
end

function PlatformAchievementService.startPolling()
	if PlatformAchievementService.state.pollTimerId or not PlatformAchievementService.state.initialized then
		return
	end

	PlatformAchievementService.state.pollTimerId = TimerManager.addRepeatTimer(PlatformAchievementService.POLL_INTERVAL, function()
		PlatformAchievementService:_pumpAchievementEvents()
	end)
end

function PlatformAchievementService:isSupported()
	return PlatformAchievementService.isPlatformSupported() and PlatformAchievementService.supportsAchievements()
end

function PlatformAchievementService:_ensureReady()
	if not self:isSupported() then
		PlatformAchievementService.resetCachedAchievementState()

		return false
	end

	if not PlatformAchievementService.state.initialized then
		return self:init()
	end

	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.EnsureAchievementsManagerReady then
		return false
	end

	local managerReady = PlatformBridgeLuaFacade.EnsureAchievementsManagerReady()

	if managerReady ~= true then
		local canContinue = PlatformAchievementService.bindSignedInUser()

		return canContinue
	end

	return PlatformAchievementService.bindSignedInUser()
end

function PlatformAchievementService:_pumpAchievementEvents()
	local ready = self:_ensureReady()

	if PlatformAchievementService.state.initialized and not PlatformAchievementService.state.managerReady and PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.EnsureAchievementsManagerReady and PlatformBridgeLuaFacade.EnsureAchievementsManagerReady() == true then
		PlatformAchievementService.state.managerReady = true

		logger:info("平台成就管理器异步初始化完成")
	end

	if ready or PlatformAchievementService.state.initialized and PlatformAchievementService.state.managerReady then
		local events = PlatformBridgeLuaFacade.PumpAchievementEvents and PlatformBridgeLuaFacade.PumpAchievementEvents()

		if events then
			local refreshNeeded = false

			PlatformAchievementService.iterateCsCollection(events, function(csEvent)
				local payload = PlatformAchievementService.buildEventPayload(csEvent)

				if not payload then
					return
				end

				if payload.achievementId and payload.achievementId ~= "" then
					logger:info("收到平台成就事件 eventType=%s achievementId=%s progressState=%s current=%s target=%s", tostring(payload.eventType), tostring(payload.achievementId), tostring(payload.progressState), tostring(payload.currentProgressValue), tostring(payload.targetProgressValue))
				end

				if payload.eventType == "LocalUserInitialStateSynced" then
					PlatformAchievementService.state.initialStateSynced = true
					refreshNeeded = true

					PlatformAchievementService.notifyListeners(PlatformAchievementService.EVENT_INITIAL_STATE_SYNCED, payload)

					return
				end

				if payload.eventType == "AchievementProgressUpdated" then
					refreshNeeded = true

					PlatformAchievementService.notifyListeners(PlatformAchievementService.EVENT_ACHIEVEMENT_PROGRESS_UPDATED, payload)

					return
				end

				if payload.eventType == "AchievementUnlocked" then
					refreshNeeded = true

					PlatformAchievementService.notifyListeners(PlatformAchievementService.EVENT_ACHIEVEMENT_UNLOCKED, payload)

					return
				end

				refreshNeeded = true
			end)

			if refreshNeeded then
				self:refreshAchievements(true)
			end
		end
	end

	PlatformAchievementTriggerService:update()
end

function PlatformAchievementService:init(runtimeReady)
	if PlatformAchievementService.state.initialized then
		return true
	end

	if not self:isSupported() then
		return false
	end

	if runtimeReady ~= true and not PlatformAchievementService.isRuntimeReady() then
		return false
	end

	if not PlatformAchievementService.bindSignedInUser() then
		return false
	end

	if not PlatformBridgeLuaFacade or not PlatformBridgeLuaFacade.EnsureAchievementsManagerReady then
		logger:warn("平台不支持成就功能")

		return false
	end

	PlatformBridgeLuaFacade.EnsureAchievementsManagerReady()

	PlatformAchievementService.state.initialized = true

	PlatformAchievementService.startPolling()
	PlatformAchievementTriggerService:init(self)

	if pg.global.platform:useFPXAchievement() then
		self:queryConfiguredSteamAchievements()
	end

	self:_pumpAchievementEvents()
	PlatformAchievementTriggerService:update()
	logger:info("PlatformAchievementService 已启动（异步等待服务准备就绪）。")

	return true
end

function PlatformAchievementService:shutdown()
	if PlatformAchievementService.state.initialized then
		logger:info("PlatformAchievementService 开始关闭。")
	end

	PlatformAchievementTriggerService:shutdown()
	PlatformAchievementService.stopPolling()

	PlatformAchievementService.state.initialized = false
	PlatformAchievementService.state.managerReady = false

	PlatformAchievementService.resetCachedAchievementState()
end

function PlatformAchievementService:refreshAchievements(forceNotify)
	if not self:_ensureReady() then
		PlatformAchievementService.resetCachedAchievementState(false)

		return PlatformAchievementService.state.achievements
	end

	local achievements, index = PlatformAchievementService.buildAchievementList(PlatformBridgeLuaFacade.GetAchievementsSnapshot())

	PlatformAchievementService.state.achievements = achievements
	PlatformAchievementService.state.achievementIndex = index

	logger:info("刷新平台成就快照 count=%s forceNotify=%s", tostring(#achievements), tostring(forceNotify))
	PlatformAchievementService.logReadyAchievementSnapshot(achievements)

	if forceNotify or #PlatformAchievementService.state.listeners[PlatformAchievementService.EVENT_ACHIEVEMENTS_UPDATED] > 0 then
		PlatformAchievementService.notifyListeners(PlatformAchievementService.EVENT_ACHIEVEMENTS_UPDATED, PlatformAchievementService.state.achievements)
	end

	return PlatformAchievementService.state.achievements
end

function PlatformAchievementService:getAchievements()
	return PlatformAchievementService.state.achievements
end

function PlatformAchievementService:getOwnerUserId()
	return PlatformAchievementService.state.ownerUserId
end

function PlatformAchievementService:getAchievementById(achievementId)
	if string.isNilOrEmpty(achievementId) then
		return nil
	end

	return PlatformAchievementService.state.achievementIndex[tostring(achievementId)]
end

function PlatformAchievementService:updateAchievement(achievementId, currentValue, targetValue, externalCallback)
	if not self:isSupported() then
		if type(externalCallback) == "function" then
			externalCallback(false, PlatformAchievementService.NOT_SUPPORTED_RESULT, "achievement_not_supported")
		end

		return false
	end

	if not self:_ensureReady() then
		if type(externalCallback) == "function" then
			externalCallback(false, PlatformAchievementService.RUNTIME_NOT_READY_RESULT, "achievement_runtime_not_ready")
		end

		return false
	end

	if string.isNilOrEmpty(achievementId) then
		if type(externalCallback) == "function" then
			externalCallback(false, PlatformAchievementService.INVALID_ARGUMENT_RESULT, "achievement_id_invalid")
		end

		return false
	end

	currentValue = tonumber(currentValue)
	targetValue = tonumber(targetValue)

	if currentValue == nil or targetValue == nil then
		if type(externalCallback) == "function" then
			externalCallback(false, PlatformAchievementService.INVALID_ARGUMENT_RESULT, "achievement_progress_invalid")
		end

		return false
	end

	logger:info("上报平台标题托管成就 achievementId=%s currentValue=%s targetValue=%s", tostring(achievementId), tostring(currentValue), tostring(targetValue))
	PlatformBridgeLuaFacade.UpdateAchievement(tostring(achievementId), math.floor(currentValue), math.floor(targetValue), 0, function(success, result, message)
		if success then
			logger:info("平台标题托管成就上报成功 platformAchievementId=%s currentValue=%s targetValue=%s result=%s", tostring(achievementId), tostring(currentValue), tostring(targetValue), tostring(result))
		else
			logger:warn("平台标题托管成就上报失败 platformAchievementId=%s currentValue=%s targetValue=%s result=%s message=%s", tostring(achievementId), tostring(currentValue), tostring(targetValue), tostring(result), tostring(message))
		end

		if type(externalCallback) == "function" then
			externalCallback(success, result, message)
		end
	end)

	return true
end

function PlatformAchievementService:getPlatformAchievementId(achievementId)
	if pg.global.platform:isSteam() then
		return PlatformAchievementRuleConfig.getRuleSteamId(achievementId)
	elseif pg.global.platform:isEpic() then
		return PlatformAchievementRuleConfig.getRuleEpicId(achievementId)
	elseif pg.global.platform:isGoogle() then
		return PlatformAchievementRuleConfig.getRuleGoogleId(achievementId)
	elseif pg.global.platform:isXHH() then
		return PlatformAchievementRuleConfig.getRuleXHHId(achievementId)
	end

	return achievementId
end

function PlatformAchievementService:subscribe(eventName, callback)
	local bucket = PlatformAchievementService.state.listeners[eventName]

	if not bucket or type(callback) ~= "function" then
		return nil
	end

	table.insert(bucket, callback)

	return callback
end

function PlatformAchievementService:unsubscribe(eventName, callback)
	local bucket = PlatformAchievementService.state.listeners[eventName]

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

function PlatformAchievementService:onInitialStateSynced(callback)
	return self:subscribe(PlatformAchievementService.EVENT_INITIAL_STATE_SYNCED, callback)
end

function PlatformAchievementService:onAchievementsUpdated(callback)
	return self:subscribe(PlatformAchievementService.EVENT_ACHIEVEMENTS_UPDATED, callback)
end

function PlatformAchievementService:onAchievementProgressUpdated(callback)
	return self:subscribe(PlatformAchievementService.EVENT_ACHIEVEMENT_PROGRESS_UPDATED, callback)
end

function PlatformAchievementService:onAchievementUnlocked(callback)
	return self:subscribe(PlatformAchievementService.EVENT_ACHIEVEMENT_UNLOCKED, callback)
end

return PlatformAchievementService
