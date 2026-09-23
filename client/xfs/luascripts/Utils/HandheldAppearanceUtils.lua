-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\HandheldAppearanceUtils.lua

local HandheldAppearanceUtils = {}
local AppearancePointEnum = require("Data.appearance_point_enum")
local AppearanceActionData = require("Data.appearance_action_data")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local APPEARANCE_TYPE_PERIPHERAL = 5
local HANDHELD_EFFECT_RESOURCE_PREFIX = "$E_P_"
local HANDHELD_EFFECT_PLACEHOLDER_MARKER = "_Acc_"
local HANDHELD_PRESET_PREFIX = "Eff_Avatar_Acc_"
local HANDHELD_PRESET_SUFFIX = "_PM"
local PREVIEW_EFFECT_CONTEXT_FIELD = "handheldAppearancePreviewEffectContext"
local previewEffectContextsByEntityId = {}

local function isHandheldEffectResource(resource)
	return resource and string.find(resource, HANDHELD_EFFECT_RESOURCE_PREFIX, 1, true) == 1
end

local function isHandheldEffectPlaceholderResource(resource)
	return isHandheldEffectResource(resource) and string.find(resource, HANDHELD_EFFECT_PLACEHOLDER_MARKER, 1, true) ~= nil
end

local function isHandheldPresetName(presetName)
	return type(presetName) == "string" and string.find(presetName, HANDHELD_PRESET_PREFIX, 1, true) == 1 and string.sub(presetName, -#HANDHELD_PRESET_SUFFIX) == HANDHELD_PRESET_SUFFIX
end

local function containsHandheldEffectResource(sourceEffectKey, sourceEffectData)
	if isHandheldEffectPlaceholderResource(sourceEffectKey) then
		return true
	end

	if not sourceEffectData then
		return false
	end

	for _, rawInfo in ipairs(sourceEffectData) do
		if rawInfo and isHandheldEffectPlaceholderResource(rawInfo.resID) then
			return true
		end
	end

	return false
end

local function containsPoint(points, targetPoint)
	if not points then
		return false
	end

	for _, point in ipairs(points) do
		if point == targetPoint then
			return true
		end
	end

	return false
end

local function normalizeActionIds(value)
	if type(value) == "number" then
		value = {
			value
		}
	elseif type(value) ~= "table" then
		return {}
	end

	local result = {}
	local seen = {}

	for _, actionId in ipairs(value) do
		if actionId and actionId > 0 and not seen[actionId] then
			result[#result + 1] = actionId
			seen[actionId] = true
		end
	end

	return result
end

function HandheldAppearanceUtils.isFootprintActionAllowed(item, actionId)
	actionId = actionId or 0

	if actionId <= 0 then
		return true
	end

	if not item then
		return false
	end

	local actionIds = item.actionIds or normalizeActionIds(item.action or item.action_id or item.actions or item.action_ids)

	for _, candidate in ipairs(actionIds) do
		if candidate == actionId then
			return true
		end
	end

	return false
end

local function matchesAction(config, actionId)
	if not config or not actionId then
		return false
	end

	for _, candidate in ipairs(config.actionIds or {}) do
		if candidate == actionId then
			return true
		end
	end

	return false
end

local function matchesAnimation(actionConfig, animationKey)
	if not actionConfig or animationKey == nil then
		return false
	end

	local targetText = tostring(animationKey)
	local targetId = AnimationUtils.getID(animationKey)

	local function matchesCandidate(value)
		if value == nil then
			return false
		end

		if tostring(value) == targetText then
			return true
		end

		local candidateId = AnimationUtils.getID(value)

		return targetId ~= 0 and candidateId == targetId
	end

	for _, candidate in ipairs(actionConfig.res1 or {}) do
		if matchesCandidate(candidate) then
			return true
		end
	end

	return matchesCandidate(actionConfig.resLoop) or matchesCandidate(actionConfig.res)
end

local function matchesActionEffectKey(actionConfig, effectKey)
	if not actionConfig or not effectKey then
		return false
	end

	local targetKey = string.lower(effectKey)

	local function matchesCandidate(value)
		if value == nil then
			return false
		end

		return string.lower(value) == targetKey
	end

	for _, candidate in ipairs(actionConfig.res1 or {}) do
		if matchesCandidate(candidate) then
			return true
		end
	end

	return matchesCandidate(actionConfig.resLoop) or matchesCandidate(actionConfig.res)
end

local function appendPeripherals(target, source)
	if not source then
		return
	end

	for key, config in pairs(source) do
		local id = config.id or key

		if id and config.type == APPEARANCE_TYPE_PERIPHERAL then
			target[id] = config
		end
	end
end

local function getPeripheralData()
	local result = {}
	local appearanceData = require("Data.appearance_data")

	appendPeripherals(result, appearanceData)

	return result
end

function HandheldAppearanceUtils.getConfigs()
	return getPeripheralData()
end

local function getModelView(entity)
	return entity and entity.eModel and (entity.eModel.modelView or entity.eModel.modelModelView) or nil
end

local function normalizeFlagOrDefault(value, defaultValue)
	if value == 0 or value == 1 then
		return value
	end

	return defaultValue
end

local function normalizeConfig(config, appearanceId)
	if not config or config.type ~= APPEARANCE_TYPE_PERIPHERAL or not containsPoint(config.points, AppearancePointEnum.HandHeld) then
		return nil
	end

	local id = config.id or appearanceId
	local actionIds = normalizeActionIds(config.action or config.action_id or config.actions or config.action_ids)

	if not id or id <= 0 or #actionIds == 0 or not config.res or config.res == "" then
		return nil
	end

	return {
		id = id,
		res = config.res,
		actionId = actionIds[1],
		actionIds = actionIds,
		allowMove = normalizeFlagOrDefault(config.allow_move, 0),
		loop = normalizeFlagOrDefault(config.loop, 0)
	}
end

function HandheldAppearanceUtils.getEquipped(entity)
	local appearanceId

	if entity and entity.getAppearanceConfigId then
		appearanceId = entity:getAppearanceConfigId(AppearancePointEnum.HandHeld, true, true)
	elseif entity and entity.curShow and entity.curShow.customShow then
		appearanceId = entity.curShow.customShow[AppearancePointEnum.HandHeld]
	end

	if not appearanceId or appearanceId <= 0 then
		return nil
	end

	return normalizeConfig(getPeripheralData()[appearanceId], appearanceId)
end

local handheldActionIds

local function getHandheldActionIds()
	if handheldActionIds then
		return handheldActionIds
	end

	local result = {}

	for appearanceId, rawConfig in pairs(getPeripheralData()) do
		local config = normalizeConfig(rawConfig, appearanceId)

		for _, configuredActionId in ipairs(config and config.actionIds or {}) do
			result[configuredActionId] = true
		end
	end

	handheldActionIds = result

	return result
end

function HandheldAppearanceUtils.isHandheldAction(actionId)
	return actionId ~= nil and actionId > 0 and getHandheldActionIds()[actionId] == true
end

function HandheldAppearanceUtils.canUseAction(entity, actionId)
	if not HandheldAppearanceUtils.isHandheldAction(actionId) then
		return nil
	end

	local customShow = entity and entity.curShow and entity.curShow.customShow
	local appearanceId = customShow and customShow[AppearancePointEnum.HandHeld]

	if not appearanceId or appearanceId <= 0 then
		return false
	end

	return matchesAction(normalizeConfig(getPeripheralData()[appearanceId], appearanceId), actionId)
end

function HandheldAppearanceUtils.buildEffectDataWithHandheldResource(sourceEffectData, handheldResource)
	if not sourceEffectData or not isHandheldEffectResource(handheldResource) then
		return sourceEffectData
	end

	local result = {}

	for index, rawInfo in ipairs(sourceEffectData) do
		if rawInfo and isHandheldEffectPlaceholderResource(rawInfo.resID) then
			local copiedInfo = {}

			for key, value in pairs(rawInfo) do
				copiedInfo[key] = value
			end

			copiedInfo.resID = handheldResource
			result[index] = copiedInfo
		else
			result[index] = rawInfo
		end
	end

	return result
end

local function getPreviewEffectContextKey(entity)
	if not entity or entity.id == nil then
		return nil
	end

	return tostring(entity.id)
end

function HandheldAppearanceUtils.setPreviewEffectContext(entity, resource, actionIds)
	if not entity or not isHandheldEffectResource(resource) then
		return false
	end

	local context = {
		res = resource,
		actionIds = normalizeActionIds(actionIds)
	}
	local contextKey = getPreviewEffectContextKey(entity)

	if contextKey then
		previewEffectContextsByEntityId[contextKey] = context
	end

	entity[PREVIEW_EFFECT_CONTEXT_FIELD] = context

	return true
end

function HandheldAppearanceUtils.clearPreviewEffectContext(entity)
	if not entity then
		return false
	end

	local contextKey = getPreviewEffectContextKey(entity)
	local existed = entity[PREVIEW_EFFECT_CONTEXT_FIELD] ~= nil or contextKey ~= nil and previewEffectContextsByEntityId[contextKey] ~= nil

	if contextKey then
		previewEffectContextsByEntityId[contextKey] = nil
	end

	entity[PREVIEW_EFFECT_CONTEXT_FIELD] = nil

	return existed
end

local function getPreviewEffectContext(entity)
	local contextKey = getPreviewEffectContextKey(entity)
	local context

	if contextKey then
		context = previewEffectContextsByEntityId[contextKey]
	else
		context = entity and entity[PREVIEW_EFFECT_CONTEXT_FIELD]
	end

	if not context or not isHandheldEffectResource(context.res) then
		return nil
	end

	return context
end

function HandheldAppearanceUtils.getCurrentHandheldEffectData(entity, sourceEffectKey, sourceEffectData)
	if not containsHandheldEffectResource(sourceEffectKey, sourceEffectData) then
		return nil
	end

	local context = getPreviewEffectContext(entity)

	if not context then
		return nil
	end

	local actionMatched = false

	for _, actionId in ipairs(context.actionIds or {}) do
		if matchesActionEffectKey(AppearanceActionData[actionId], sourceEffectKey) then
			actionMatched = true

			break
		end
	end

	if not actionMatched then
		return nil
	end

	return HandheldAppearanceUtils.buildEffectDataWithHandheldResource(sourceEffectData, context.res)
end

function HandheldAppearanceUtils.getEffectResourceForAnimation(entity, animationKey, sourceEffectKey, sourceEffectData)
	if animationKey == nil or not containsHandheldEffectResource(sourceEffectKey, sourceEffectData) then
		return nil
	end

	local context = getPreviewEffectContext(entity)
	local config = context == nil and HandheldAppearanceUtils.getEquipped(entity) or nil
	local actionIds = context and context.actionIds or config and config.actionIds or {}

	for _, actionId in ipairs(actionIds) do
		if matchesAnimation(AppearanceActionData[actionId], animationKey) then
			return context and context.res or config.res
		end
	end

	return nil
end

function HandheldAppearanceUtils.getPresetNameForAnimation(entity, animationKey, sourcePresetName)
	if animationKey == nil or not isHandheldPresetName(sourcePresetName) then
		return nil
	end

	local context = getPreviewEffectContext(entity)
	local config = context == nil and HandheldAppearanceUtils.getEquipped(entity) or nil
	local actionIds = context and context.actionIds or config and config.actionIds or {}
	local resource = context and context.res or config and config.res

	if not isHandheldEffectResource(resource) then
		return nil
	end

	for _, actionId in ipairs(actionIds) do
		if matchesAnimation(AppearanceActionData[actionId], animationKey) then
			return ""
		end
	end

	return nil
end

function HandheldAppearanceUtils.showForAction(entity, actionId)
	local config = HandheldAppearanceUtils.getEquipped(entity)

	if not actionId or actionId <= 0 or not config or not matchesAction(config, actionId) then
		return nil
	end

	return {
		actionId = actionId,
		appearanceId = config.id
	}
end

function HandheldAppearanceUtils.stopForAction(entity, token)
	if not token then
		return false
	end

	local actionId = token.actionId
	local appearanceId = token.appearanceId

	return actionId ~= nil and actionId > 0 and appearanceId ~= nil and appearanceId > 0
end

function HandheldAppearanceUtils.clear(entity)
	local modelView = getModelView(entity)

	return modelView and modelView:ClearHandheldAppearance() or false
end

function HandheldAppearanceUtils.shouldDisableMove(entity, actionId)
	local config = HandheldAppearanceUtils.getEquipped(entity)

	if not actionId or actionId <= 0 or not config or not matchesAction(config, actionId) then
		return nil
	end

	return config.allowMove ~= 1
end

function HandheldAppearanceUtils.getLoop(entity, actionId)
	local config = HandheldAppearanceUtils.getEquipped(entity)

	if not actionId or actionId <= 0 or not config or not matchesAction(config, actionId) then
		return nil
	end

	return config.loop
end

function HandheldAppearanceUtils.shouldStopOnMove(entity, actionId)
	return HandheldAppearanceUtils.shouldDisableMove(entity, actionId)
end

return HandheldAppearanceUtils
