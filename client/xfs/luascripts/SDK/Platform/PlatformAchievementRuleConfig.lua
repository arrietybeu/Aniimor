-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformAchievementRuleConfig.lua

local json = require("json")
local logger = require("SDK.Platform.PlatformLogger")
local PlatformAchievementRuleData = require("Data.platform_achievement_rule_data")
local Utils = require("Common.Utils.Utils")
local PlatformAchievementRuleConfig = {
	_initDone = false,
	rules = {},
	rulesByEventKey = {},
	rulesByAchievementId = {}
}

PlatformAchievementRuleConfig.PLATFORM_ID = {
	XHH = 6,
	Google = 5,
	Epic = 4,
	Steam = 3,
	Xbox = 2,
	PlayStation = 1
}

function PlatformAchievementRuleConfig.getCurrentPlatformId()
	local platformId = PlatformAchievementRuleConfig.PLATFORM_ID

	if pg.global.platform:isPS() then
		return platformId.PlayStation
	end

	if pg.global.platform:isXbox() or pg.global.platform:isXboxPC() then
		return platformId.Xbox
	end

	if pg.global.platform:isSteam() then
		return platformId.Steam
	end

	if pg.global.platform:isEpic() then
		return platformId.Epic
	end

	if pg.global.platform:isGoogle() then
		return platformId.Google
	end

	if pg.global.platform:isXHH() then
		return platformId.XHH
	end

	return nil
end

function PlatformAchievementRuleConfig.isRuleSupportedOnCurrentPlatform(row)
	local platforms = row and row.platform or nil

	if not Utils.isTable(platforms) then
		return true
	end

	local currentPlatformId = PlatformAchievementRuleConfig.getCurrentPlatformId()
	local hasPlatform = false

	for _, platformId in pairs(platforms) do
		hasPlatform = true

		if currentPlatformId ~= nil and tonumber(platformId) == currentPlatformId then
			return true
		end
	end

	return not hasPlatform
end

local function getRowFieldIgnoreCase(row, ...)
	if type(row) ~= "table" and type(row) ~= "userdata" then
		return nil
	end

	local expected = {}

	for i = 1, select("#", ...) do
		local key = select(i, ...)
		local value = row[key]

		if value ~= nil then
			return value
		end

		expected[string.lower(key)] = true
	end

	for key, value in pairs(row) do
		if type(key) == "string" and expected[string.lower(key)] then
			return value
		end
	end

	return nil
end

function PlatformAchievementRuleConfig.buildRuleFromTableRow(trophyId, row)
	return {
		key = trophyId,
		achievementId = tostring(row.achievementId),
		achievementName = row.displayName or row.displayDesc or "",
		eventId = row.eventId,
		paramsJson = row.paramsJson,
		steamId = getRowFieldIgnoreCase(row, "steamId"),
		epicId = getRowFieldIgnoreCase(row, "epicid"),
		googleId = getRowFieldIgnoreCase(row, "googleid"),
		xhhId = getRowFieldIgnoreCase(row, "xhhid"),
		platform = row.platform
	}
end

function PlatformAchievementRuleConfig.decodeRuleParams(rule)
	if type(rule) ~= "table" then
		logger:error("平台成就规则解析失败：rule 不是 table")

		return nil
	end

	if type(rule.paramsJson) ~= "string" or rule.paramsJson == "" then
		logger:error("平台成就规则 paramsJson 缺失 key=%s", tostring(rule.key))

		return nil
	end

	local ok, params = pcall(json.decode, rule.paramsJson)

	if not ok or type(params) ~= "table" then
		logger:error("平台成就规则 paramsJson 解析失败 key=%s error=%s", tostring(rule.key), tostring(params))

		return nil
	end

	local targetValue = tonumber(params.targetValue)

	if targetValue == nil then
		logger:error("平台成就规则缺少 targetValue key=%s", tostring(rule.key))

		return nil
	end

	params.targetValue = targetValue
	rule._params = params

	return params
end

function PlatformAchievementRuleConfig._initData()
	if PlatformAchievementRuleConfig._initDone then
		return
	end

	local ok = pcall(function()
		for trophyId, row in pairs(PlatformAchievementRuleData) do
			if Utils.isTable(row) and row.eventId and PlatformAchievementRuleConfig.isRuleSupportedOnCurrentPlatform(row) then
				local rule = PlatformAchievementRuleConfig.buildRuleFromTableRow(trophyId, row)

				table.insert(PlatformAchievementRuleConfig.rules, rule)
			end
		end
	end)

	if not ok then
		return
	end

	table.sort(PlatformAchievementRuleConfig.rules, function(a, b)
		return tonumber(a.achievementId) < tonumber(b.achievementId)
	end)

	local currentPlatformId = PlatformAchievementRuleConfig.getCurrentPlatformId()

	logger:info("平台成就 currentPlatformId =%s", tostring(currentPlatformId))

	for _, rule in ipairs(PlatformAchievementRuleConfig.rules) do
		PlatformAchievementRuleConfig.decodeRuleParams(rule)

		PlatformAchievementRuleConfig.rulesByAchievementId[tostring(rule.achievementId)] = rule

		if rule.eventId == "module_event_counter" then
			local eventKey = rule._params and rule._params.eventKey or nil

			if eventKey then
				PlatformAchievementRuleConfig.rulesByEventKey[eventKey] = PlatformAchievementRuleConfig.rulesByEventKey[eventKey] or {}

				table.insert(PlatformAchievementRuleConfig.rulesByEventKey[eventKey], rule)
			end
		end
	end

	PlatformAchievementRuleConfig._initDone = true
end

function PlatformAchievementRuleConfig.getRules()
	PlatformAchievementRuleConfig._initData()

	return PlatformAchievementRuleConfig.rules
end

function PlatformAchievementRuleConfig.getRuleParams(rule)
	PlatformAchievementRuleConfig._initData()

	if type(rule) ~= "table" then
		return nil
	end

	if type(rule._params) == "table" then
		return rule._params
	end

	return PlatformAchievementRuleConfig.decodeRuleParams(rule)
end

function PlatformAchievementRuleConfig.getRuleParam(rule, key, defaultValue)
	PlatformAchievementRuleConfig._initData()

	local params = PlatformAchievementRuleConfig.getRuleParams(rule)
	local value = params and params[key] or nil

	if value == nil then
		return defaultValue
	end

	return value
end

function PlatformAchievementRuleConfig.getRuleTargetValue(rule)
	PlatformAchievementRuleConfig._initData()

	return tonumber(PlatformAchievementRuleConfig.getRuleParam(rule, "targetValue", 0)) or 0
end

function PlatformAchievementRuleConfig.getRulesByEventKey(eventKey)
	PlatformAchievementRuleConfig._initData()

	return PlatformAchievementRuleConfig.rulesByEventKey[eventKey]
end

function PlatformAchievementRuleConfig.getRuleSteamId(achievementId)
	PlatformAchievementRuleConfig._initData()

	local rule = PlatformAchievementRuleConfig.rulesByAchievementId[tostring(achievementId)]

	return rule and rule.steamId or achievementId
end

function PlatformAchievementRuleConfig.getRuleEpicId(achievementId)
	PlatformAchievementRuleConfig._initData()

	local rule = PlatformAchievementRuleConfig.rulesByAchievementId[tostring(achievementId)]

	return rule and rule.epicId or achievementId
end

function PlatformAchievementRuleConfig.getRuleGoogleId(achievementId)
	PlatformAchievementRuleConfig._initData()

	local rule = PlatformAchievementRuleConfig.rulesByAchievementId[tostring(achievementId)]

	return rule and rule.googleId or achievementId
end

function PlatformAchievementRuleConfig.getRuleXHHId(achievementId)
	PlatformAchievementRuleConfig._initData()

	local rule = PlatformAchievementRuleConfig.rulesByAchievementId[tostring(achievementId)]

	return rule and rule.xhhId or achievementId
end

return PlatformAchievementRuleConfig
