-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformAchievementTriggerService.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("SDK.Platform.PlatformLogger")
local Const = require("Common.Const.Const")
local TriggerConst = require("Common.Const.TriggerConst")
local TriggerUtils = require("Common.Utils.TriggerUtils")
local QuestCommonUtils = require("Common.Utils.QuestCommonUtils")
local EventConst = require("Const.EventConst")
local PlayerTitleData = require("Data.player_title_data")
local LevelData = require("Data.level_data")
local PetPrototypeData = require("Data.pet_prototype_data")
local PlatformAchievementRuleConfig = require("SDK.Platform.PlatformAchievementRuleConfig")
local PlatformAchievementTriggerService = {}
local getRuleParam = PlatformAchievementRuleConfig.getRuleParam
local getRuleTargetValue = PlatformAchievementRuleConfig.getRuleTargetValue
local getRulesByEventKey = PlatformAchievementRuleConfig.getRulesByEventKey

PlatformAchievementTriggerService._dungeonTempleMap = nil

function PlatformAchievementTriggerService.getDungeonTempleMap()
	if PlatformAchievementTriggerService._dungeonTempleMap then
		return PlatformAchievementTriggerService._dungeonTempleMap
	end

	PlatformAchievementTriggerService._dungeonTempleMap = {}

	for _, entry in pairs(LevelData) do
		if entry.dungeonId then
			PlatformAchievementTriggerService._dungeonTempleMap[entry.dungeonId] = entry.isTemple or 0
		end
	end

	return PlatformAchievementTriggerService._dungeonTempleMap
end

PlatformAchievementTriggerService.PERIODIC_EVALUATION_INTERVAL = 1
PlatformAchievementTriggerService.FAILED_RETRY_INTERVAL = 5
PlatformAchievementTriggerService.TEMP_DISABLED_TRIGGER_RULES = {}
PlatformAchievementTriggerService.state = {
	bindingComplete = false,
	nextEvaluateAt = 0,
	dirty = false,
	initialized = false,
	_loggedFirstEvaluation = false,
	_warnedNoPlayer = false,
	initialStateSynced = false,
	baselineSnapshotted = false,
	submittedForUserId = "",
	evaluationBlocked = false,
	boundAchievements = {},
	lastSubmittedPercent = {},
	lastSubmittedAbsolute = {},
	pendingWrites = {},
	failedWrites = {},
	localCounters = {},
	warnedBindings = {},
	warnedRuleEvaluationErrors = {},
	subscriptions = {},
	eventListeners = {},
	runtimeCounters = {}
}

function PlatformAchievementTriggerService.isNilOrEmpty(value)
	return value == nil or value == ""
end

function PlatformAchievementTriggerService.toNumber(value, defaultValue)
	local num = tonumber(value)

	if num == nil then
		return defaultValue or 0
	end

	return num
end

function PlatformAchievementTriggerService.clamp(value, minValue, maxValue)
	if value < minValue then
		return minValue
	end

	if maxValue < value then
		return maxValue
	end

	return value
end

function PlatformAchievementTriggerService.now()
	return os.clock()
end

function PlatformAchievementTriggerService.getPlayer()
	return pg and pg.me or nil
end

function PlatformAchievementTriggerService.containsValue(list, targetValue)
	if type(list) ~= "table" then
		return false
	end

	for _, value in ipairs(list) do
		if value == targetValue then
			return true
		end
	end

	return false
end

function PlatformAchievementTriggerService.tableCount(list)
	if not list then
		return 0
	end

	local count = list.Count

	if type(count) == "function" then
		count = list:Count()
	end

	if count ~= nil then
		return PlatformAchievementTriggerService.toNumber(count, 0)
	end

	local length = list.Length

	if type(length) == "function" then
		length = list:Length()
	end

	if length ~= nil then
		return PlatformAchievementTriggerService.toNumber(length, 0)
	end

	local luaLen = #list

	if luaLen and luaLen > 0 then
		return luaLen
	end

	if type(list) ~= "table" then
		return 0
	end

	local count = 0

	for _, _ in pairs(list) do
		count = count + 1
	end

	return count
end

function PlatformAchievementTriggerService.resetRuntimeState()
	PlatformAchievementTriggerService.state.dirty = false
	PlatformAchievementTriggerService.state.nextEvaluateAt = 0
	PlatformAchievementTriggerService.state.bindingComplete = false
	PlatformAchievementTriggerService.state.boundAchievements = {}
	PlatformAchievementTriggerService.state.pendingWrites = {}
	PlatformAchievementTriggerService.state.failedWrites = {}
	PlatformAchievementTriggerService.state.localCounters = {}
	PlatformAchievementTriggerService.state.warnedBindings = {}
	PlatformAchievementTriggerService.state.warnedRuleEvaluationErrors = {}
	PlatformAchievementTriggerService.state.runtimeCounters = {}
	PlatformAchievementTriggerService.state.initialStateSynced = false
	PlatformAchievementTriggerService.state.baselineSnapshotted = false
	PlatformAchievementTriggerService.state._warnedNoPlayer = false
	PlatformAchievementTriggerService.state._loggedFirstEvaluation = false
end

function PlatformAchievementTriggerService.buildAchievementLookups(achievements)
	local byId = {}
	local byName = {}
	local byDescription = {}

	for _, achievement in ipairs(achievements or EMPTY_TABLE) do
		if achievement then
			local achievementId = tostring(achievement.achievementId or "")
			local achievementName = tostring(achievement.name or "")
			local unlockedDescription = tostring(achievement.unlockedDescription or "")
			local lockedDescription = tostring(achievement.lockedDescription or "")

			if not PlatformAchievementTriggerService.isNilOrEmpty(achievementId) then
				byId[achievementId] = achievement
			end

			if not PlatformAchievementTriggerService.isNilOrEmpty(achievementName) and not byName[achievementName] then
				byName[achievementName] = achievement
			end

			if not PlatformAchievementTriggerService.isNilOrEmpty(unlockedDescription) and not byDescription[unlockedDescription] then
				byDescription[unlockedDescription] = achievement
			end

			if not PlatformAchievementTriggerService.isNilOrEmpty(lockedDescription) and not byDescription[lockedDescription] then
				byDescription[lockedDescription] = achievement
			end
		end
	end

	return byId, byName, byDescription
end

function PlatformAchievementTriggerService.getRuleEventId(rule)
	if type(rule) ~= "table" then
		return ""
	end

	return tostring(rule.eventId or "")
end

function PlatformAchievementTriggerService.getPlatformAbsoluteProgress(rule, achievement)
	if not achievement then
		return 0
	end

	local targetValue = getRuleTargetValue(rule)
	local currentValue = PlatformAchievementTriggerService.toNumber(achievement.currentProgressValue, 0)
	local platformTargetValue = PlatformAchievementTriggerService.toNumber(achievement.targetProgressValue, 0)
	local progressState = tostring(achievement.progressState or "")

	if progressState == "Achieved" or progressState == "Unlocked" then
		return targetValue
	end

	if platformTargetValue <= 0 then
		return 0
	end

	local ratio = currentValue / platformTargetValue

	return PlatformAchievementTriggerService.clamp(math.floor(ratio * targetValue + 0.0001), 0, targetValue)
end

function PlatformAchievementTriggerService.toPlatformPercent(rule, absoluteValue)
	local targetValue = getRuleTargetValue(rule)

	if targetValue <= 0 then
		return 0
	end

	local percent = math.floor(absoluteValue / targetValue * 100 + 0.0001)

	return PlatformAchievementTriggerService.clamp(percent, 0, 100)
end

function PlatformAchievementTriggerService.evaluateSceneOrArea(rule, player)
	local sceneIds = getRuleParam(rule, "sceneIds")
	local areaIds = getRuleParam(rule, "areaIds")
	local currentSceneId = player.space and player.space.sceneId or 0
	local mainSceneId = currentSceneId

	if pg.game and pg.game.map and pg.game.map.convertSceneId then
		mainSceneId = pg.game.map:convertSceneId(currentSceneId)
	end

	if PlatformAchievementTriggerService.containsValue(sceneIds, currentSceneId) or PlatformAchievementTriggerService.containsValue(sceneIds, mainSceneId) then
		return 1
	end

	if player.getMapLayerData then
		local mapLayerData = player:getMapLayerData(currentSceneId)
		local areaId = mapLayerData and mapLayerData[5] or 0

		if PlatformAchievementTriggerService.containsValue(areaIds, areaId) then
			return 1
		end
	end

	return 0
end

function PlatformAchievementTriggerService.countPetBallHatchingSlots(player)
	local hatchSlotMap = player and player.hatchSlotMap

	if not hatchSlotMap then
		return 0
	end

	local totalCount = 0

	if type(hatchSlotMap.items) == "function" then
		for _, slotInfo in hatchSlotMap:items() do
			if slotInfo and slotInfo.status == Const.PET_BALL.HATCH_STATUS_START then
				totalCount = totalCount + 1
			end
		end

		return totalCount
	end

	for _, slotInfo in pairs(hatchSlotMap) do
		if slotInfo and slotInfo.status == Const.PET_BALL.HATCH_STATUS_START then
			totalCount = totalCount + 1
		end
	end

	return totalCount
end

function PlatformAchievementTriggerService.evaluateClientFallbackTriggerValue(trigger, arg, player)
	if trigger == TriggerConst.TRIGGER_TARGET_HOME_UNLOCK then
		return player.isHomelandUnlock and player.isHomeCampUnlocked and 1 or 0
	end

	if trigger == TriggerConst.TRIGGER_TARGET_CATCH_RAINBOW_PET then
		return PlatformAchievementTriggerService.toNumber(PlatformAchievementTriggerService.state.runtimeCounters.rainbowPetCatchCount, 0)
	end

	if trigger == TriggerConst.TRIGGER_TARGET_HAVE_RAINBOW_PET then
		local count = 0

		for _, petInfo in pairs(player.pets or EMPTY_TABLE) do
			local petPrototypeId = petInfo and petInfo.petPrototypeId
			local prototypeData = petPrototypeId and PetPrototypeData[petPrototypeId]
			local RAINBOW_FORM_ID = 5

			if prototypeData and prototypeData.formId == RAINBOW_FORM_ID and (not arg or arg == 0 or arg == petPrototypeId) then
				count = count + 1
			end
		end

		return count
	end

	if trigger == TriggerConst.TRIGGER_TARGET_LEYLINETREE_NOURISH_NUM or trigger == TriggerConst.TRIGGER_TARGET_LEYLINETREE_NOURISH_NUM_COUNT then
		if arg and arg ~= 0 then
			local treeInfo = player.leylineTreeInfoMap and player.leylineTreeInfoMap[arg]

			return PlatformAchievementTriggerService.toNumber(treeInfo and treeInfo.createPlentyCount, 0)
		end

		local totalCount = 0

		if player.leylineTreeInfoMap then
			for _, treeInfo in pairs(player.leylineTreeInfoMap) do
				totalCount = totalCount + PlatformAchievementTriggerService.toNumber(treeInfo and treeInfo.createPlentyCount, 0)
			end
		end

		return totalCount
	end

	if trigger == TriggerConst.TRIGGER_TARGET_GET_PET_TEMPLATE then
		if not player.triggerMap or not player.triggerMap.getTriggerCurrentCount then
			return 0
		end

		return PlatformAchievementTriggerService.toNumber(player.triggerMap:getTriggerCurrentCount(trigger, arg or 0), 0)
	end

	if trigger == TriggerConst.TRIGGER_TARGET_HOME_START_DISPATCH then
		if not player.triggerMap or not player.triggerMap.getTriggerCurrentCount then
			return 0
		end

		return PlatformAchievementTriggerService.toNumber(player.triggerMap:getTriggerCurrentCount(trigger, arg or 0), 0)
	end

	if trigger == TriggerConst.TRIGGER_TARGET_FRIEND_INTIMACY then
		if player.getFriendIntimacyLevelCount then
			return PlatformAchievementTriggerService.toNumber(player:getFriendIntimacyLevelCount(arg or 0), 0)
		end

		local friendships = pg.game and pg.game.chat and pg.game.chat.friendships

		if type(friendships) ~= "table" then
			return 0
		end

		local targetLevel = PlatformAchievementTriggerService.toNumber(arg, 0)
		local count = 0

		for _, level in pairs(friendships) do
			local lv = PlatformAchievementTriggerService.toNumber(level, -1)

			if lv >= 0 and targetLevel <= lv then
				count = count + 1
			end
		end

		return count
	end

	return nil
end

function PlatformAchievementTriggerService.evaluateTriggerValue(rule, player)
	local trigger = getRuleParam(rule, "trigger")
	local arg = getRuleParam(rule, "arg", 0)
	local extraArg = getRuleParam(rule, "extraArg")

	if trigger == nil then
		logger:warn("平台成就规则缺少 trigger key=%s", tostring(rule and rule.key))

		return 0
	end

	if PlatformAchievementTriggerService.TEMP_DISABLED_TRIGGER_RULES[trigger] then
		return 0
	end

	if pg and pg.component == "client" then
		local fallbackValue = PlatformAchievementTriggerService.evaluateClientFallbackTriggerValue(trigger, arg, player)

		if fallbackValue ~= nil then
			return math.max(0, PlatformAchievementTriggerService.toNumber(fallbackValue, 0))
		end
	end

	return math.max(0, PlatformAchievementTriggerService.toNumber(TriggerUtils.getStatusTriggerCurValue(player, trigger, arg, extraArg), 0))
end

function PlatformAchievementTriggerService.evaluateSingleTriggerProgress(triggerRule, player)
	local trigger = triggerRule and triggerRule.trigger

	if trigger == nil then
		return 0
	end

	if PlatformAchievementTriggerService.TEMP_DISABLED_TRIGGER_RULES[trigger] then
		return 0
	end

	if pg and pg.component == "client" then
		local fallbackValue = PlatformAchievementTriggerService.evaluateClientFallbackTriggerValue(trigger, triggerRule.arg or 0, player)

		if fallbackValue ~= nil then
			return math.max(0, PlatformAchievementTriggerService.toNumber(fallbackValue, 0))
		end
	end

	return math.max(0, PlatformAchievementTriggerService.toNumber(TriggerUtils.getStatusTriggerCurValue(player, trigger, triggerRule.arg or 0, triggerRule.extraArg), 0))
end

function PlatformAchievementTriggerService.evaluateTriggerGroupValue(rule, player)
	local triggerGroup = getRuleParam(rule, "triggerGroup")

	if type(triggerGroup) ~= "table" or #triggerGroup == 0 then
		return nil
	end

	local logic = tostring(getRuleParam(rule, "logic", "AND"))
	local allMatched = true
	local anyMatched = false

	for _, triggerRule in ipairs(triggerGroup) do
		local currentValue = PlatformAchievementTriggerService.evaluateSingleTriggerProgress(triggerRule, player)
		local targetValue = PlatformAchievementTriggerService.toNumber(triggerRule and triggerRule.targetValue, 1)
		local matched = targetValue <= currentValue

		allMatched = allMatched and matched
		anyMatched = anyMatched or matched
	end

	if logic == "OR" then
		return anyMatched and getRuleTargetValue(rule) or 0
	end

	return allMatched and getRuleTargetValue(rule) or 0
end

function PlatformAchievementTriggerService.evaluateTriggerCurrentCount(rule, player)
	if not player.triggerMap or not player.triggerMap.getTriggerCurrentCount then
		return 0
	end

	local trigger = getRuleParam(rule, "trigger")
	local subKey = getRuleParam(rule, "subKey", 0)

	return math.max(0, PlatformAchievementTriggerService.toNumber(player.triggerMap:getTriggerCurrentCount(trigger, subKey), 0))
end

function PlatformAchievementTriggerService.evaluateLeylineActivePointCount(rule, player)
	local mapMarkStatusMap = player.mapMarkStatusMap

	if not mapMarkStatusMap or not mapMarkStatusMap.getTotalUnlockedCount then
		return 0
	end

	local spaceId = pg.space and pg.space.id

	return mapMarkStatusMap:getTotalUnlockedCount(Const.MAP_MARK_LEYLINETREE_TRANSMIT, 0, spaceId)
end

function PlatformAchievementTriggerService.evaluateQuestSet(rule, player)
	local completedCount = 0

	for _, questId in ipairs(getRuleParam(rule, "questIds", {}) or EMPTY_TABLE) do
		if QuestCommonUtils.questCompleted(player, questId) then
			completedCount = completedCount + 1
		end
	end

	return completedCount
end

function PlatformAchievementTriggerService.evaluateSimulationTrainPassSet(rule, player)
	local completedCount = 0
	local passCnt = player.rogueLevelPassCnt or {}

	for _, levelId in ipairs(getRuleParam(rule, "levelIds", {}) or EMPTY_TABLE) do
		if PlatformAchievementTriggerService.toNumber(passCnt[levelId], 0) > 0 then
			completedCount = completedCount + 1
		end
	end

	return completedCount
end

function PlatformAchievementTriggerService.evaluatePlayerTitle(rule, player)
	local titleId = getRuleParam(rule, "fallbackTitleId")

	if not titleId then
		return 0
	end

	local currentTitle = math.max(PlatformAchievementTriggerService.toNumber(player.starTitle, 0), PlatformAchievementTriggerService.toNumber(PlatformAchievementTriggerService.state.runtimeCounters.latestStarTitle, 0))

	return titleId <= currentTitle and 1 or 0
end

function PlatformAchievementTriggerService.evaluateSimulationTrainPassTotal(player)
	local totalCount = 0

	for _, passCount in pairs(player.rogueLevelPassCnt or EMPTY_TABLE) do
		totalCount = totalCount + PlatformAchievementTriggerService.toNumber(passCount, 0)
	end

	return totalCount
end

function PlatformAchievementTriggerService.evaluateDungeonPassTotal(rule, player)
	local isTemple = getRuleParam(rule, "isTemple")
	local excludedDungeonIds = getRuleParam(rule, "excludedDungeonIds") or {}
	local excludedSet = {}

	for _, dungeonId in ipairs(excludedDungeonIds) do
		excludedSet[dungeonId] = true
	end

	local totalCount = 0
	local passRecord = player.passRecord or {}

	if isTemple then
		for dungeonId, templeFlag in pairs(PlatformAchievementTriggerService.getDungeonTempleMap()) do
			if templeFlag == isTemple and not excludedSet[dungeonId] then
				totalCount = totalCount + PlatformAchievementTriggerService.toNumber(passRecord[dungeonId], 0)
			end
		end
	else
		for _, passCount in pairs(passRecord) do
			totalCount = totalCount + PlatformAchievementTriggerService.toNumber(passCount, 0)
		end
	end

	return totalCount
end

function PlatformAchievementTriggerService.evaluateCountryCollectRatePercent(rule, player)
	local countryId = getRuleParam(rule, "countryId")
	local rate = player.petHandbookMap and player.petHandbookMap:getCountryCollectRate(countryId) or 0

	return math.floor(math.max(0, PlatformAchievementTriggerService.toNumber(rate, 0)) * 100 + 0.0001)
end

function PlatformAchievementTriggerService.evaluateCustomTriggerValue(rule, player)
	local customTriggerId = getRuleParam(rule, "arg")
	local conditionPos = getRuleParam(rule, "extraArg", 1)

	if not customTriggerId or not player.triggerMap or not player.triggerMap.getConditionFinishCount then
		return 0
	end

	local currentValue = player.triggerMap:getConditionFinishCount(customTriggerId, conditionPos)

	return math.max(0, PlatformAchievementTriggerService.toNumber(currentValue, 0))
end

function PlatformAchievementTriggerService.evaluateRuleAbsolute(rule, player)
	local eventId = PlatformAchievementTriggerService.getRuleEventId(rule)

	if eventId == "scene_or_area" then
		return PlatformAchievementTriggerService.evaluateSceneOrArea(rule, player)
	end

	if eventId == "trigger_value" then
		local triggerGroupValue = PlatformAchievementTriggerService.evaluateTriggerGroupValue(rule, player)

		if triggerGroupValue ~= nil then
			return triggerGroupValue
		end

		return PlatformAchievementTriggerService.evaluateTriggerValue(rule, player)
	end

	if eventId == "custom_trigger_value" then
		return PlatformAchievementTriggerService.evaluateCustomTriggerValue(rule, player)
	end

	if eventId == "trigger_current_count" then
		return PlatformAchievementTriggerService.evaluateTriggerCurrentCount(rule, player)
	end

	if eventId == "leyline_active_point_count" then
		return PlatformAchievementTriggerService.evaluateLeylineActivePointCount(rule, player)
	end

	if eventId == "quest_set" then
		return PlatformAchievementTriggerService.evaluateQuestSet(rule, player)
	end

	if eventId == "simulation_train_pass_set" then
		return PlatformAchievementTriggerService.evaluateSimulationTrainPassSet(rule, player)
	end

	if eventId == "player_title_by_name" then
		return PlatformAchievementTriggerService.evaluatePlayerTitle(rule, player)
	end

	if eventId == "module_event_counter" then
		return PlatformAchievementTriggerService.toNumber(PlatformAchievementTriggerService.state.localCounters[rule.key], 0)
	end

	if eventId == "simulation_train_pass_total" then
		return PlatformAchievementTriggerService.evaluateSimulationTrainPassTotal(player)
	end

	if eventId == "dungeon_pass_total" then
		return PlatformAchievementTriggerService.evaluateDungeonPassTotal(rule, player)
	end

	if eventId == "country_total_research_level" then
		local level = player.petHandbookMap and player.petHandbookMap:getCountryTotalLevel(getRuleParam(rule, "countryId"))

		return PlatformAchievementTriggerService.toNumber(level, 0)
	end

	if eventId == "country_collect_level" then
		local level = player.petHandbookMap and player.petHandbookMap:getCountryCollectLevel(getRuleParam(rule, "countryId"))

		return PlatformAchievementTriggerService.toNumber(level, 0)
	end

	if eventId == "country_collect_rate_percent" then
		return PlatformAchievementTriggerService.evaluateCountryCollectRatePercent(rule, player)
	end

	logger:warn("未知的平台成就规则类型: %s", eventId)

	return 0
end

function PlatformAchievementTriggerService.safeEvaluateRuleAbsolute(rule, player)
	local success, result = pcall(PlatformAchievementTriggerService.evaluateRuleAbsolute, rule, player)

	if success then
		return result
	end

	local ruleKey = tostring(rule and rule.key or "")
	local warnedRuleEvaluationErrors = PlatformAchievementTriggerService.state.warnedRuleEvaluationErrors or {}

	PlatformAchievementTriggerService.state.warnedRuleEvaluationErrors = warnedRuleEvaluationErrors

	if not warnedRuleEvaluationErrors[ruleKey] then
		warnedRuleEvaluationErrors[ruleKey] = true

		logger:error("平台成就规则评估异常，跳过当前规则 key=%s achievementId=%s eventId=%s error=%s", ruleKey, tostring(rule and rule.achievementId or ""), tostring(rule and rule.eventId or ""), tostring(result))
	end

	return nil
end

function PlatformAchievementTriggerService.getPlatformAchievementId(achievementId)
	if pg.global.platform:isSteam() then
		return PlatformAchievementRuleConfig.getRuleSteamId(achievementId)
	elseif pg.global.platform:isEpic() then
		return PlatformAchievementRuleConfig.getRuleEpicId(achievementId)
	elseif pg.global.platform:isGoogle() then
		return PlatformAchievementRuleConfig.getRuleGoogleId(achievementId)
	elseif pg.global.platform:isXHH() then
		return PlatformAchievementRuleConfig.getRuleXHHId(achievementId)
	else
		return achievementId
	end
end

function PlatformAchievementTriggerService.snapshotClientBaseline(player)
	for _, rule in ipairs(PlatformAchievementRuleConfig.getRules()) do
		local targetValue = getRuleTargetValue(rule)
		local evaluatedValue = PlatformAchievementTriggerService.safeEvaluateRuleAbsolute(rule, player)
		local absolute = evaluatedValue ~= nil and PlatformAchievementTriggerService.clamp(PlatformAchievementTriggerService.toNumber(evaluatedValue, 0), 0, targetValue) or nil

		if absolute ~= nil and targetValue > 0 and absolute > 0 and absolute < targetValue then
			PlatformAchievementTriggerService.state.lastSubmittedAbsolute[rule.key] = math.max(PlatformAchievementTriggerService.toNumber(PlatformAchievementTriggerService.state.lastSubmittedAbsolute[rule.key], 0), absolute)
			PlatformAchievementTriggerService.state.lastSubmittedPercent[rule.key] = math.max(PlatformAchievementTriggerService.toNumber(PlatformAchievementTriggerService.state.lastSubmittedPercent[rule.key], 0), PlatformAchievementTriggerService.toPlatformPercent(rule, absolute))
		end
	end
end

function PlatformAchievementTriggerService.rebindPlatformAchievements(achievements)
	local byId, byName, byDescription = PlatformAchievementTriggerService.buildAchievementLookups(achievements)
	local canWarn = type(achievements) == "table" and #achievements > 0
	local anyBound = false

	for _, rule in ipairs(PlatformAchievementRuleConfig.getRules()) do
		local platformAchievementId = PlatformAchievementTriggerService.getPlatformAchievementId(rule.achievementId)
		local achievement = byId[platformAchievementId] or byName[rule.achievementName] or byDescription[rule.achievementName]

		PlatformAchievementTriggerService.state.boundAchievements[rule.key] = achievement

		if achievement then
			anyBound = true

			local platformAbsolute = PlatformAchievementTriggerService.getPlatformAbsoluteProgress(rule, achievement)

			PlatformAchievementTriggerService.state.lastSubmittedAbsolute[rule.key] = math.max(PlatformAchievementTriggerService.toNumber(PlatformAchievementTriggerService.state.lastSubmittedAbsolute[rule.key], 0), platformAbsolute)
			PlatformAchievementTriggerService.state.lastSubmittedPercent[rule.key] = math.max(PlatformAchievementTriggerService.toNumber(PlatformAchievementTriggerService.state.lastSubmittedPercent[rule.key], 0), PlatformAchievementTriggerService.toPlatformPercent(rule, platformAbsolute))

			if PlatformAchievementTriggerService.getRuleEventId(rule) == "module_event_counter" then
				PlatformAchievementTriggerService.state.localCounters[rule.key] = math.max(PlatformAchievementTriggerService.toNumber(PlatformAchievementTriggerService.state.localCounters[rule.key], 0), platformAbsolute)
			end

			if PlatformAchievementTriggerService.getRuleEventId(rule) == "trigger_value" and getRuleParam(rule, "trigger") == TriggerConst.TRIGGER_TARGET_CATCH_RAINBOW_PET then
				local current = PlatformAchievementTriggerService.toNumber(PlatformAchievementTriggerService.state.runtimeCounters.rainbowPetCatchCount, 0)

				if current < platformAbsolute then
					PlatformAchievementTriggerService.state.runtimeCounters.rainbowPetCatchCount = platformAbsolute
				end
			end

			if PlatformAchievementTriggerService.getRuleEventId(rule) == "trigger_value" and getRuleParam(rule, "trigger") == TriggerConst.TRIGGER_TARGET_HATCH_EGG and getRuleParam(rule, "arg", 0) == 0 then
				local currentHatchCount = PlatformAchievementTriggerService.toNumber(PlatformAchievementTriggerService.state.runtimeCounters.petBallHatchSuccessCount, 0)

				if currentHatchCount < platformAbsolute then
					PlatformAchievementTriggerService.state.runtimeCounters.petBallHatchSuccessCount = platformAbsolute
				end
			end

			if PlatformAchievementTriggerService.getRuleEventId(rule) == "trigger_value" and getRuleParam(rule, "trigger") == TriggerConst.TRIGGER_TARGET_HATCH_EGG and getRuleParam(rule, "arg", 0) == 2 then
				local current = PlatformAchievementTriggerService.toNumber(PlatformAchievementTriggerService.state.runtimeCounters.petBallHatchSuccCountPlatformAbsolute, 0)

				if current < platformAbsolute then
					PlatformAchievementTriggerService.state.runtimeCounters.petBallHatchSuccCountPlatformAbsolute = platformAbsolute
				end
			end
		elseif canWarn and not PlatformAchievementTriggerService.state.warnedBindings[rule.key] then
			logger:warn("未能绑定平台成就 key=%s name=%s，等待平台快照返回实际成就。", tostring(rule.key), tostring(rule.achievementName))

			PlatformAchievementTriggerService.state.warnedBindings[rule.key] = true
		end
	end

	logger:info("rebindPlatformAchievements： bindingComplete")

	PlatformAchievementTriggerService.state.bindingComplete = anyBound
	PlatformAchievementTriggerService.state.dirty = true
end

function PlatformAchievementTriggerService.getBindingCounts()
	local boundCount = 0
	local unboundCount = 0

	for _, rule in ipairs(PlatformAchievementRuleConfig.getRules()) do
		if PlatformAchievementTriggerService.state.boundAchievements[rule.key] then
			boundCount = boundCount + 1
		else
			unboundCount = unboundCount + 1
		end
	end

	return boundCount, unboundCount
end

function PlatformAchievementTriggerService.markDirty()
	PlatformAchievementTriggerService.state.dirty = true
end

function PlatformAchievementTriggerService.updateModuleCounter(ruleKey, targetValue, addValue)
	local currentValue = PlatformAchievementTriggerService.toNumber(PlatformAchievementTriggerService.state.localCounters[ruleKey], 0)

	if addValue and addValue > 0 then
		currentValue = currentValue + addValue
	else
		currentValue = targetValue
	end

	PlatformAchievementTriggerService.state.localCounters[ruleKey] = PlatformAchievementTriggerService.clamp(currentValue, 0, targetValue)

	PlatformAchievementTriggerService.markDirty()
end

function PlatformAchievementTriggerService.updateModuleCounterByEventKey(eventKey, defaultTargetValue, addValue)
	local rules = getRulesByEventKey(eventKey)

	if type(rules) ~= "table" then
		return
	end

	for _, rule in ipairs(rules) do
		local targetValue = getRuleTargetValue(rule)

		if targetValue <= 0 then
			targetValue = defaultTargetValue or 0
		end

		PlatformAchievementTriggerService.updateModuleCounter(rule.key, targetValue, addValue)
	end
end

function PlatformAchievementTriggerService.handlePhotoSaved(payload)
	if type(payload) ~= "table" then
		return
	end

	if payload.hasPlayerInView == true and type(payload.templateIds) == "table" and #payload.templateIds > 0 then
		PlatformAchievementTriggerService.updateModuleCounterByEventKey("human_pet_photo", 1)
	end

	if payload.isPhotoStudio == true and PlatformAchievementTriggerService.tableCount(payload.friendPlayerUidsInView) > 0 then
		PlatformAchievementTriggerService.updateModuleCounterByEventKey("studio_friend_photo", 1)
	end
end

function PlatformAchievementTriggerService.handleTakePhoto(payload)
	if type(payload) ~= "table" then
		return
	end

	if payload.hasPlayerInView == true then
		PlatformAchievementTriggerService.updateModuleCounterByEventKey("human_pet_photo", 1)
	end

	if payload.isPhotoStudio == true and PlatformAchievementTriggerService.tableCount(payload.friendPlayerUidsInView) > 0 then
		PlatformAchievementTriggerService.updateModuleCounterByEventKey("studio_friend_photo", 1)
	end
end

function PlatformAchievementTriggerService.handleVariantTriggered(payload)
	if type(payload) ~= "table" then
		return
	end

	if PlatformAchievementTriggerService.isNilOrEmpty(payload.newUid) then
		return
	end

	PlatformAchievementTriggerService.updateModuleCounterByEventKey("pet_exchange_variant", 1)
end

function PlatformAchievementTriggerService.handleBossKilled(payload)
	if type(payload) ~= "table" then
		return
	end

	PlatformAchievementTriggerService.updateModuleCounterByEventKey("boss_kill", 50, math.max(1, PlatformAchievementTriggerService.toNumber(payload.count, 1)))
end

function PlatformAchievementTriggerService.handleCostumeDyed(payload)
	if type(payload) ~= "table" then
		return
	end

	PlatformAchievementTriggerService.updateModuleCounterByEventKey("costume_dye", 1)
end

function PlatformAchievementTriggerService.handleRoguePassed(payload)
	PlatformAchievementTriggerService.markDirty()
end

function PlatformAchievementTriggerService.handleMeteorologyExperienced(payload)
	if type(payload) ~= "table" then
		return
	end

	PlatformAchievementTriggerService.updateModuleCounterByEventKey("rainbow_meteorology", 1, PlatformAchievementTriggerService.toNumber(payload.count, 1))
end

function PlatformAchievementTriggerService.handleHugPet(payload)
	PlatformAchievementTriggerService.updateModuleCounterByEventKey("hug_pet", 1, PlatformAchievementTriggerService.toNumber(payload and payload.count, 1))
end

function PlatformAchievementTriggerService.handleHomeCampDispatchFinished(payload)
	PlatformAchievementTriggerService.updateModuleCounterByEventKey("home_camp_dispatch_finish", 1, PlatformAchievementTriggerService.toNumber(payload and payload.count, 1))
end

function PlatformAchievementTriggerService.isAchievementEvaluationBlocked(rule)
	if PlatformAchievementTriggerService.state.evaluationBlocked == true then
		return true
	end

	local player = PlatformAchievementTriggerService.getPlayer()
	local triggerMap = player and player.triggerMap

	if triggerMap and triggerMap._isTriggerBlockedForGuidance then
		local blocked = triggerMap:_isTriggerBlockedForGuidance({
			virtualPlayerEnable = 0
		})

		if blocked then
			-- block empty
		end

		return blocked
	end

	return false
end

function PlatformAchievementTriggerService.handleBeginBlockAchievementEvaluation()
	PlatformAchievementTriggerService.state.evaluationBlocked = true

	logger:info("PlatformAchievementTriggerService beginBlockAchievementEvaluation")
end

function PlatformAchievementTriggerService.handleEndBlockAchievementEvaluation()
	PlatformAchievementTriggerService.state.evaluationBlocked = false

	logger:info("PlatformAchievementTriggerService endBlockAchievementEvaluation")
	PlatformAchievementTriggerService.markDirty()
end

function PlatformAchievementTriggerService.handlePetBallHatchSlotStatusChanged(hatchSlotId, oldStatus, newStatus)
	if newStatus ~= Const.PET_BALL.HATCH_STATUS_SUCC then
		return
	end

	if oldStatus == Const.PET_BALL.HATCH_STATUS_SUCC then
		return
	end

	PlatformAchievementTriggerService.state.runtimeCounters.petBallHatchSuccessCount = PlatformAchievementTriggerService.toNumber(PlatformAchievementTriggerService.state.runtimeCounters.petBallHatchSuccessCount, 0) + 1

	PlatformAchievementTriggerService.markDirty()
end

function PlatformAchievementTriggerService.handleStarTitleChanged(newTitle)
	PlatformAchievementTriggerService.state.runtimeCounters.latestStarTitle = math.max(PlatformAchievementTriggerService.toNumber(PlatformAchievementTriggerService.state.runtimeCounters.latestStarTitle, 0), PlatformAchievementTriggerService.toNumber(newTitle, 0))

	PlatformAchievementTriggerService.markDirty()
end

function PlatformAchievementTriggerService.subscribeGlobalEvents()
	PlatformAchievementTriggerService.state.eventListeners.photoSaved = PlatformAchievementTriggerService.handlePhotoSaved
	PlatformAchievementTriggerService.state.eventListeners.takePhoto = PlatformAchievementTriggerService.handleTakePhoto
	PlatformAchievementTriggerService.state.eventListeners.variantTriggered = PlatformAchievementTriggerService.handleVariantTriggered
	PlatformAchievementTriggerService.state.eventListeners.bossKilled = PlatformAchievementTriggerService.handleBossKilled
	PlatformAchievementTriggerService.state.eventListeners.costumeDyed = PlatformAchievementTriggerService.handleCostumeDyed
	PlatformAchievementTriggerService.state.eventListeners.roguePassed = PlatformAchievementTriggerService.handleRoguePassed
	PlatformAchievementTriggerService.state.eventListeners.meteorologyExperienced = PlatformAchievementTriggerService.handleMeteorologyExperienced
	PlatformAchievementTriggerService.state.eventListeners.hugPet = PlatformAchievementTriggerService.handleHugPet
	PlatformAchievementTriggerService.state.eventListeners.homeCampDispatchFinished = PlatformAchievementTriggerService.handleHomeCampDispatchFinished
	PlatformAchievementTriggerService.state.eventListeners.petBallHatchSlotStatusChanged = PlatformAchievementTriggerService.handlePetBallHatchSlotStatusChanged
	PlatformAchievementTriggerService.state.eventListeners.starTitleChanged = PlatformAchievementTriggerService.handleStarTitleChanged
	PlatformAchievementTriggerService.state.eventListeners.beginBlockAchievementEvaluation = PlatformAchievementTriggerService.handleBeginBlockAchievementEvaluation
	PlatformAchievementTriggerService.state.eventListeners.endBlockAchievementEvaluation = PlatformAchievementTriggerService.handleEndBlockAchievementEvaluation

	function PlatformAchievementTriggerService.state.eventListeners.rainbowPetCaught()
		PlatformAchievementTriggerService.state.runtimeCounters.rainbowPetCatchCount = PlatformAchievementTriggerService.toNumber(PlatformAchievementTriggerService.state.runtimeCounters.rainbowPetCatchCount, 0) + 1

		PlatformAchievementTriggerService.markDirty()
	end

	pg.global.eventEmitter:addEventListener(EventConst.PLATFORM_ACHIEVEMENT_PHOTO_SAVED, PlatformAchievementTriggerService.state.eventListeners.photoSaved)
	pg.global.eventEmitter:addEventListener(EventConst.PLATFORM_ACHIEVEMENT_TAKE_PHOTO, PlatformAchievementTriggerService.state.eventListeners.takePhoto)
	pg.global.eventEmitter:addEventListener(EventConst.PLATFORM_ACHIEVEMENT_VARIANT_TRIGGERED, PlatformAchievementTriggerService.state.eventListeners.variantTriggered)
	pg.global.eventEmitter:addEventListener(EventConst.PLATFORM_ACHIEVEMENT_ELITE_KILLED, PlatformAchievementTriggerService.state.eventListeners.bossKilled)
	pg.global.eventEmitter:addEventListener(EventConst.PLATFORM_ACHIEVEMENT_COSTUME_DYED, PlatformAchievementTriggerService.state.eventListeners.costumeDyed)
	pg.global.eventEmitter:addEventListener(EventConst.PLATFORM_ACHIEVEMENT_ROGUE_PASSED, PlatformAchievementTriggerService.state.eventListeners.roguePassed)
	pg.global.eventEmitter:addEventListener(EventConst.PLATFORM_ACHIEVEMENT_METEOROLOGY_EXPERIENCED, PlatformAchievementTriggerService.state.eventListeners.meteorologyExperienced)
	pg.global.eventEmitter:addEventListener(EventConst.PLATFORM_ACHIEVEMENT_HUG_PET, PlatformAchievementTriggerService.state.eventListeners.hugPet)
	pg.global.eventEmitter:addEventListener(EventConst.PLATFORM_ACHIEVEMENT_HOME_CAMP_DISPATCH_FINISHED, PlatformAchievementTriggerService.state.eventListeners.homeCampDispatchFinished)
	pg.global.eventEmitter:addEventListener(EventConst.PET_BALL_MAP_HATCH_SLOT_STATUS_CHANGED, PlatformAchievementTriggerService.state.eventListeners.petBallHatchSlotStatusChanged)
	pg.global.eventEmitter:addEventListener(EventConst.PLATFORM_ACHIEVEMENT_STAR_TITLE_CHANGED, PlatformAchievementTriggerService.state.eventListeners.starTitleChanged)
	pg.global.eventEmitter:addEventListener(EventConst.PLATFORM_ACHIEVEMENT_RAINBOW_PET_CAUGHT, PlatformAchievementTriggerService.state.eventListeners.rainbowPetCaught)
	pg.global.eventEmitter:addEventListener(EventConst.PLATFORM_ACHIEVEMENT_BEGIN_BLOCK_EVALUATION, PlatformAchievementTriggerService.state.eventListeners.beginBlockAchievementEvaluation)
	pg.global.eventEmitter:addEventListener(EventConst.PLATFORM_ACHIEVEMENT_END_BLOCK_EVALUATION, PlatformAchievementTriggerService.state.eventListeners.endBlockAchievementEvaluation)
end

function PlatformAchievementTriggerService.unsubscribeGlobalEvents()
	if not pg or not pg.global or not pg.global.eventEmitter then
		return
	end

	if PlatformAchievementTriggerService.state.eventListeners.photoSaved then
		pg.global.eventEmitter:removeEventListener(EventConst.PLATFORM_ACHIEVEMENT_PHOTO_SAVED, PlatformAchievementTriggerService.state.eventListeners.photoSaved)
	end

	if PlatformAchievementTriggerService.state.eventListeners.takePhoto then
		pg.global.eventEmitter:removeEventListener(EventConst.PLATFORM_ACHIEVEMENT_TAKE_PHOTO, PlatformAchievementTriggerService.state.eventListeners.takePhoto)
	end

	if PlatformAchievementTriggerService.state.eventListeners.variantTriggered then
		pg.global.eventEmitter:removeEventListener(EventConst.PLATFORM_ACHIEVEMENT_VARIANT_TRIGGERED, PlatformAchievementTriggerService.state.eventListeners.variantTriggered)
	end

	if PlatformAchievementTriggerService.state.eventListeners.bossKilled then
		pg.global.eventEmitter:removeEventListener(EventConst.PLATFORM_ACHIEVEMENT_ELITE_KILLED, PlatformAchievementTriggerService.state.eventListeners.bossKilled)
	end

	if PlatformAchievementTriggerService.state.eventListeners.costumeDyed then
		pg.global.eventEmitter:removeEventListener(EventConst.PLATFORM_ACHIEVEMENT_COSTUME_DYED, PlatformAchievementTriggerService.state.eventListeners.costumeDyed)
	end

	if PlatformAchievementTriggerService.state.eventListeners.roguePassed then
		pg.global.eventEmitter:removeEventListener(EventConst.PLATFORM_ACHIEVEMENT_ROGUE_PASSED, PlatformAchievementTriggerService.state.eventListeners.roguePassed)
	end

	if PlatformAchievementTriggerService.state.eventListeners.meteorologyExperienced then
		pg.global.eventEmitter:removeEventListener(EventConst.PLATFORM_ACHIEVEMENT_METEOROLOGY_EXPERIENCED, PlatformAchievementTriggerService.state.eventListeners.meteorologyExperienced)
	end

	if PlatformAchievementTriggerService.state.eventListeners.hugPet then
		pg.global.eventEmitter:removeEventListener(EventConst.PLATFORM_ACHIEVEMENT_HUG_PET, PlatformAchievementTriggerService.state.eventListeners.hugPet)
	end

	if PlatformAchievementTriggerService.state.eventListeners.homeCampDispatchFinished then
		pg.global.eventEmitter:removeEventListener(EventConst.PLATFORM_ACHIEVEMENT_HOME_CAMP_DISPATCH_FINISHED, PlatformAchievementTriggerService.state.eventListeners.homeCampDispatchFinished)
	end

	if PlatformAchievementTriggerService.state.eventListeners.petBallHatchSlotStatusChanged then
		pg.global.eventEmitter:removeEventListener(EventConst.PET_BALL_MAP_HATCH_SLOT_STATUS_CHANGED, PlatformAchievementTriggerService.state.eventListeners.petBallHatchSlotStatusChanged)
	end

	if PlatformAchievementTriggerService.state.eventListeners.starTitleChanged then
		pg.global.eventEmitter:removeEventListener(EventConst.PLATFORM_ACHIEVEMENT_STAR_TITLE_CHANGED, PlatformAchievementTriggerService.state.eventListeners.starTitleChanged)
	end

	if PlatformAchievementTriggerService.state.eventListeners.rainbowPetCaught then
		pg.global.eventEmitter:removeEventListener(EventConst.PLATFORM_ACHIEVEMENT_RAINBOW_PET_CAUGHT, PlatformAchievementTriggerService.state.eventListeners.rainbowPetCaught)
	end

	if PlatformAchievementTriggerService.state.eventListeners.beginBlockAchievementEvaluation then
		pg.global.eventEmitter:removeEventListener(EventConst.PLATFORM_ACHIEVEMENT_BEGIN_BLOCK_EVALUATION, PlatformAchievementTriggerService.state.eventListeners.beginBlockAchievementEvaluation)
	end

	if PlatformAchievementTriggerService.state.eventListeners.endBlockAchievementEvaluation then
		pg.global.eventEmitter:removeEventListener(EventConst.PLATFORM_ACHIEVEMENT_END_BLOCK_EVALUATION, PlatformAchievementTriggerService.state.eventListeners.endBlockAchievementEvaluation)
	end

	PlatformAchievementTriggerService.state.eventListeners = {}
end

function PlatformAchievementTriggerService.unsubscribePlatformEvents()
	local platformService = PlatformAchievementTriggerService.state.platformService

	if not platformService then
		return
	end

	if PlatformAchievementTriggerService.state.subscriptions.achievementsUpdated then
		platformService:unsubscribe("achievementsUpdated", PlatformAchievementTriggerService.state.subscriptions.achievementsUpdated)
	end

	if PlatformAchievementTriggerService.state.subscriptions.initialStateSynced then
		platformService:unsubscribe("initialStateSynced", PlatformAchievementTriggerService.state.subscriptions.initialStateSynced)
	end

	PlatformAchievementTriggerService.state.subscriptions = {}
end

function PlatformAchievementTriggerService.trySubmitAchievement(rule, boundAchievement, desiredAbsolute)
	if not boundAchievement then
		return
	end

	if PlatformAchievementTriggerService.isAchievementEvaluationBlocked(rule) then
		return
	end

	if not PlatformAchievementTriggerService.state.initialStateSynced then
		return
	end

	local platformAbsolute = PlatformAchievementTriggerService.getPlatformAbsoluteProgress(rule, boundAchievement)
	local platformPercent = PlatformAchievementTriggerService.toPlatformPercent(rule, platformAbsolute)
	local desiredPercent = PlatformAchievementTriggerService.toPlatformPercent(rule, desiredAbsolute)

	if desiredPercent <= 0 then
		return
	end

	local submittedAbsolute = math.max(platformAbsolute, PlatformAchievementTriggerService.toNumber(PlatformAchievementTriggerService.state.lastSubmittedAbsolute[rule.key], 0))
	local submittedPercent = math.max(platformPercent, PlatformAchievementTriggerService.toNumber(PlatformAchievementTriggerService.state.lastSubmittedPercent[rule.key], 0))
	local useFpxAchievement = pg.global.platform:useFPXAchievement()
	local targetValue = getRuleTargetValue(rule)
	local reachedComplete = targetValue > 0 and targetValue <= desiredAbsolute
	local platformUnlocked = targetValue > 0 and targetValue <= platformAbsolute
	local alreadySubmittedComplete = targetValue > 0 and targetValue <= PlatformAchievementTriggerService.toNumber(PlatformAchievementTriggerService.state.lastSubmittedAbsolute[rule.key], 0)

	if useFpxAchievement and reachedComplete and not platformUnlocked and not alreadySubmittedComplete then
		-- block empty
	elseif desiredAbsolute <= submittedAbsolute or desiredPercent <= submittedPercent then
		return
	end

	local pendingWrite = PlatformAchievementTriggerService.state.pendingWrites[rule.key]

	if pendingWrite and desiredPercent <= pendingWrite.percent then
		return
	end

	local failedWrite = PlatformAchievementTriggerService.state.failedWrites[rule.key]

	if failedWrite and failedWrite.percent == desiredPercent and PlatformAchievementTriggerService.now() - failedWrite.time < PlatformAchievementTriggerService.FAILED_RETRY_INTERVAL then
		return
	end

	PlatformAchievementTriggerService.state.pendingWrites[rule.key] = {
		absolute = desiredAbsolute,
		percent = desiredPercent
	}

	PlatformAchievementTriggerService.state.platformService:updateAchievement(boundAchievement.achievementId, desiredAbsolute, getRuleTargetValue(rule), function(success)
		local pending = PlatformAchievementTriggerService.state.pendingWrites[rule.key]

		if pending and pending.percent == desiredPercent then
			PlatformAchievementTriggerService.state.pendingWrites[rule.key] = nil
		end

		if success then
			PlatformAchievementTriggerService.state.failedWrites[rule.key] = nil
			PlatformAchievementTriggerService.state.lastSubmittedPercent[rule.key] = desiredPercent
			PlatformAchievementTriggerService.state.lastSubmittedAbsolute[rule.key] = desiredAbsolute
		else
			PlatformAchievementTriggerService.state.failedWrites[rule.key] = {
				percent = desiredPercent,
				time = PlatformAchievementTriggerService.now()
			}
		end
	end)
end

function PlatformAchievementTriggerService:init(platformService)
	if PlatformAchievementTriggerService.state.initialized then
		return true
	end

	if not platformService then
		return false
	end

	local currentUserId = platformService.getOwnerUserId and platformService:getOwnerUserId() or ""

	if currentUserId ~= PlatformAchievementTriggerService.state.submittedForUserId then
		PlatformAchievementTriggerService.state.lastSubmittedAbsolute = {}
		PlatformAchievementTriggerService.state.lastSubmittedPercent = {}
		PlatformAchievementTriggerService.state.submittedForUserId = currentUserId
	end

	PlatformAchievementTriggerService.resetRuntimeState()

	PlatformAchievementTriggerService.state.platformService = platformService
	PlatformAchievementTriggerService.state.initialized = true

	function PlatformAchievementTriggerService.state.subscriptions.initialStateSynced()
		PlatformAchievementTriggerService.state.initialStateSynced = true

		PlatformAchievementTriggerService.markDirty()
	end

	function PlatformAchievementTriggerService.state.subscriptions.achievementsUpdated(achievements)
		PlatformAchievementTriggerService.rebindPlatformAchievements(achievements)
	end

	platformService:onInitialStateSynced(PlatformAchievementTriggerService.state.subscriptions.initialStateSynced)
	platformService:onAchievementsUpdated(PlatformAchievementTriggerService.state.subscriptions.achievementsUpdated)

	if pg and pg.global and pg.global.eventEmitter then
		PlatformAchievementTriggerService.subscribeGlobalEvents()
	end

	PlatformAchievementTriggerService.rebindPlatformAchievements(platformService:getAchievements() or {})
	PlatformAchievementTriggerService.markDirty()

	return true
end

function PlatformAchievementTriggerService:shutdown()
	if not PlatformAchievementTriggerService.state.initialized then
		return
	end

	PlatformAchievementTriggerService.unsubscribePlatformEvents()
	PlatformAchievementTriggerService.unsubscribeGlobalEvents()

	PlatformAchievementTriggerService.state.initialized = false
	PlatformAchievementTriggerService.state.platformService = nil

	PlatformAchievementTriggerService.resetRuntimeState()
end

function PlatformAchievementTriggerService:update()
	if not PlatformAchievementTriggerService.state.initialized or not PlatformAchievementTriggerService.state.platformService then
		return
	end

	local currentTime = PlatformAchievementTriggerService.now()

	if not PlatformAchievementTriggerService.state.dirty and currentTime < PlatformAchievementTriggerService.state.nextEvaluateAt then
		return
	end

	local player = PlatformAchievementTriggerService.getPlayer()

	if not player then
		if not PlatformAchievementTriggerService.state._warnedNoPlayer then
			logger:warn("update 跳过：pg.me 尚未就绪")

			PlatformAchievementTriggerService.state._warnedNoPlayer = true
		end

		return
	end

	if not PlatformAchievementTriggerService.state.bindingComplete and PlatformAchievementTriggerService.state.platformService then
		local achievements = PlatformAchievementTriggerService.state.platformService:getAchievements()

		if achievements and #achievements > 0 then
			PlatformAchievementTriggerService.rebindPlatformAchievements(achievements)
		end
	end

	if pg.global.platform:useFPXAchievement() and not PlatformAchievementTriggerService.state.baselineSnapshotted and PlatformAchievementTriggerService.state.initialStateSynced then
		PlatformAchievementTriggerService.snapshotClientBaseline(player)

		PlatformAchievementTriggerService.state.baselineSnapshotted = true

		logger:info("FPXAchievement baselineSnapshotted")
	end

	PlatformAchievementTriggerService.state.dirty = false
	PlatformAchievementTriggerService.state.nextEvaluateAt = currentTime + PlatformAchievementTriggerService.PERIODIC_EVALUATION_INTERVAL

	for _, rule in ipairs(PlatformAchievementRuleConfig.getRules()) do
		local evaluatedValue = PlatformAchievementTriggerService.safeEvaluateRuleAbsolute(rule, player)

		if evaluatedValue ~= nil then
			local desiredAbsolute = PlatformAchievementTriggerService.clamp(PlatformAchievementTriggerService.toNumber(evaluatedValue, 0), 0, getRuleTargetValue(rule))
			local boundAchievement = PlatformAchievementTriggerService.state.boundAchievements[rule.key]

			PlatformAchievementTriggerService.trySubmitAchievement(rule, boundAchievement, desiredAbsolute)
		end
	end

	if not PlatformAchievementTriggerService.state._loggedFirstEvaluation then
		local boundCount, unboundCount = PlatformAchievementTriggerService.getBindingCounts()

		logger:info("首次成就评估完成 bound=%s unbound=%s", tostring(boundCount), tostring(unboundCount))

		PlatformAchievementTriggerService.state._loggedFirstEvaluation = true
	end
end

return PlatformAchievementTriggerService
