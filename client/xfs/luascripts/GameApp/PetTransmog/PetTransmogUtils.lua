-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\PetTransmog\\PetTransmogUtils.lua

local PetTransmogSoltData = require("Data.pet_transmog_solt_data")
local PetTransmogBaseData = require("Data.pet_transmog_base_data")
local PetTransmogSuitPerviewData = require("Data.pet_transmog_suit_perview_data")
local PetTransmogTypesetData = require("Data.pet_transmog_typeset_data")
local PetTransmogDefaultSuitData = require("Data.pet_transmog_default_suit_data")
local PetData = require("Data.pet_data")
local AppearancePointEnum = require("Data.appearance_point_enum")
local logger = require("Core.Log.LoggerManager").getLogger("PetTransmogUtils")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local PetTransmogUtils = {}
local TRANSMOG_COLOR_TYPE = 1
local TRANSMOG_COMPOSITE_PART_TYPES = {
	2,
	3,
	4
}
local TRANSMOG_PART_TYPE_TO_APPEARANCE_POINT = {
	[2] = AppearancePointEnum.Wing,
	[3] = AppearancePointEnum.Coat,
	[4] = AppearancePointEnum.Hat
}
local TRANSMOG_MODEL_RES_FORMAT_FALLBACK = "E_P_Parmon_Suit_{0}_{1}_{2}"

PetTransmogUtils.REPLACE_MODE = {
	SAVE_TEMP = 1,
	APPLY_CURR = 2
}
PetTransmogUtils.Tips = {
	"PETTRANSMOGRIFY_TIPS_PART_1",
	"PETTRANSMOGRIFY_TIPS_PART_2",
	"PETTRANSMOGRIFY_TIPS_PART_3",
	"PETTRANSMOGRIFY_TIPS_PART_4",
	"PETTRANSMOGRIFY_TIPS_PART_5"
}

function PetTransmogUtils.getBaseRaw(key)
	return PetTransmogBaseData[key]
end

function PetTransmogUtils.getBaseNumber(key, default)
	return tonumber(PetTransmogBaseData[key]) or default or 0
end

function PetTransmogUtils.getTransmogItemId()
	return PetTransmogUtils.getBaseNumber("need_item_id")
end

function PetTransmogUtils.getTransmogPointsId()
	return PetTransmogUtils.getBaseNumber("transmog_points_id")
end

function PetTransmogUtils.getTransmogSpecialItemId()
	return PetTransmogUtils.getBaseNumber("special_item_id")
end

function PetTransmogUtils.getSpecialSlotSuitId()
	return PetTransmogUtils.getBaseNumber("special_slotsuit_id")
end

function PetTransmogUtils.getMaxCustomCount()
	return PetTransmogUtils.getBaseNumber("UGC_num")
end

function PetTransmogUtils.getMaxTempCount()
	return PetTransmogUtils.getBaseNumber("temporary_num")
end

function PetTransmogUtils.getMaxLockNum()
	return PetTransmogUtils.getBaseNumber("lock_max_num")
end

function PetTransmogUtils.getTransmogSingleExp()
	return PetTransmogUtils.getBaseNumber("transmog_single_exp")
end

function PetTransmogUtils.isTransmogShopOpen()
	return PetTransmogUtils.getBaseNumber("transmog_shop_open") == 1
end

function PetTransmogUtils.getLockCost(lockNum)
	local n = lockNum or 0
	local map = PetTransmogUtils.getBaseRaw("cost_lock")
	local v = tonumber(map[n])

	if v then
		return v
	end

	return PetTransmogUtils.getBaseNumber("cost_normal")
end

function PetTransmogUtils.getSuitQualityValue(quality)
	local map = PetTransmogUtils.getBaseRaw("slotsuit_quality_value")

	return tonumber(map[quality]) or 0
end

function PetTransmogUtils.getSuitPreviewMap(petId)
	local pet = PetTransmogUtils.getPetInfo(petId)
	local templateId = pet and pet.templateId

	return templateId and PetTransmogSuitPerviewData[templateId] or nil
end

function PetTransmogUtils.getPreviewSchemeVideoPath(scheme)
	if not scheme then
		return nil
	end

	local videoPath = Utils.isOverseas() and scheme.videoUrlINT or scheme.videoUrl

	return not string.isNilOrEmpty(videoPath) and videoPath or nil
end

function PetTransmogUtils.getDefaultSuitPic(petId)
	local pet = PetTransmogUtils.getPetInfo(petId)
	local templateId = pet and pet.templateId
	local data = templateId and PetTransmogDefaultSuitData[templateId]

	return data and data.pic or nil
end

function PetTransmogUtils.getDefaultColorSlotId(petId)
	local pet = PetTransmogUtils.getPetInfo(petId)
	local templateId = pet and pet.templateId
	local data = templateId and PetTransmogDefaultSuitData[templateId]

	return data and data.defaultId or nil
end

local function _patchDefaultColor(petId, scheme)
	local colorIdx = Const.PetTransmogSlotType.Color

	if PetTransmogUtils.isHoleUnlocked(petId, colorIdx) then
		return scheme
	end

	if scheme and scheme.holeIds and scheme.holeIds[colorIdx] then
		return scheme
	end

	local defaultId = PetTransmogUtils.getDefaultColorSlotId(petId)

	if not defaultId then
		return scheme
	end

	local out = {}

	if scheme then
		for k, v in pairs(scheme) do
			out[k] = v
		end
	end

	local newHoleIds = {}

	if scheme and scheme.holeIds then
		for k, v in pairs(scheme.holeIds) do
			newHoleIds[k] = v
		end
	end

	newHoleIds[colorIdx] = defaultId
	out.holeIds = newHoleIds
	out._colorPatched = true

	return out
end

function PetTransmogUtils.toRawScheme(scheme)
	if not scheme or not scheme._colorPatched then
		return scheme
	end

	local colorIdx = Const.PetTransmogSlotType.Color
	local out = {}

	for k, v in pairs(scheme) do
		if k ~= "_colorPatched" then
			out[k] = v
		end
	end

	local newHoleIds = {}

	if scheme.holeIds then
		for k, v in pairs(scheme.holeIds) do
			if k ~= colorIdx then
				newHoleIds[k] = v
			end
		end
	end

	out.holeIds = next(newHoleIds) and newHoleIds or nil

	return out
end

function PetTransmogUtils.getPreviewSchemes(petId)
	local list = {}
	local suitMap = PetTransmogUtils.getSuitPreviewMap(petId)

	if not suitMap then
		return list
	end

	local pet = PetTransmogUtils.getPetInfo(petId)
	local templateId = pet and pet.templateId

	if not templateId then
		return list
	end

	local colorIdx = Const.PetTransmogSlotType.Color
	local flashIdx = Const.PetTransmogSlotType.Flash
	local lastSuitType = Const.PetTransmogSlotType.Max - 1
	local suitSlots, flashSlotId = {}

	for slotId, slot in pairs(PetTransmogSoltData) do
		if slot.petId == templateId then
			local slotType = slot.type

			if slotType and colorIdx <= slotType and slotType <= lastSuitType and slot.suitId then
				suitSlots[slot.suitId] = suitSlots[slot.suitId] or {}
				suitSlots[slot.suitId][slotType] = slotId
			elseif slotType == flashIdx and slot.effectSwitch == 1 then
				flashSlotId = slotId
			end
		end
	end

	local suitIds = {}

	for suitId, suit in pairs(suitMap) do
		if not suit.isHide or suit.isHide ~= 1 then
			suitIds[#suitIds + 1] = suitId
		end
	end

	table.sort(suitIds)

	for _, suitId in ipairs(suitIds) do
		local suit = suitMap[suitId]
		local holeIds, transmogValue = {}, 0
		local typeSlots = suitSlots[suitId]

		if typeSlots then
			for slotType = colorIdx, lastSuitType do
				local slotId = typeSlots[slotType]

				if slotId then
					holeIds[slotType] = slotId

					local slot = PetTransmogSoltData[slotId]

					if slot and slot.quality then
						transmogValue = transmogValue + PetTransmogUtils.getSuitQualityValue(slot.quality)
					end
				end
			end
		end

		if flashSlotId then
			holeIds[flashIdx] = flashSlotId

			local slot = PetTransmogSoltData[flashSlotId]

			if slot and slot.quality then
				transmogValue = transmogValue + PetTransmogUtils.getSuitQualityValue(slot.quality)
			end
		end

		list[#list + 1] = {
			suitId = suitId,
			name = pg.getLocalizationText(suit.name),
			quality = suit.quality or 0,
			holeIds = holeIds,
			transmogValue = transmogValue,
			pic = suit.pic,
			videoUrl = suit.videoUrl,
			videoUrlINT = suit.videoUrlINT
		}
	end

	return list
end

function PetTransmogUtils.getSlotConfig(slotId)
	return slotId and PetTransmogSoltData[slotId] or nil
end

local _suitZeroSlotIdsCache = {}

function PetTransmogUtils.getSuitZeroSlotIds(templateId)
	if not templateId then
		return {}
	end

	local cacheKey = tostring(templateId)
	local cached = _suitZeroSlotIdsCache[cacheKey]

	if cached then
		return cached
	end

	local map = {}

	for slotId, slot in pairs(PetTransmogSoltData) do
		if slot.suitId == 0 and slot.type and tostring(slot.petId) == cacheKey then
			map[slot.type] = slotId
		end
	end

	_suitZeroSlotIdsCache[cacheKey] = map

	return map
end

function PetTransmogUtils.getModelSplicePathConfig()
	return PetTransmogUtils.getBaseRaw("Model_Splice_Path_Config") or TRANSMOG_MODEL_RES_FORMAT_FALLBACK
end

function PetTransmogUtils.formatCompositeModelPath(templateId, partResource, colorResource)
	local path = PetTransmogUtils.getModelSplicePathConfig()

	path = string.gsub(path, "{0}", tostring(templateId or ""))
	path = string.gsub(path, "{1}", tostring(partResource or ""))
	path = string.gsub(path, "{2}", tostring(colorResource or ""))

	if string.sub(path, 1, 1) ~= "$" then
		path = "$" .. path
	end

	if not string.find(path, "%.prefab$") then
		path = path .. ".prefab"
	end

	return path
end

function PetTransmogUtils.formatTransmogEffectPath(templateId, partResource, colorResource, suffix)
	local path = tostring(PetTransmogUtils.getBaseRaw("Effect_Mingguang") or "")

	path = string.gsub(path, "{0}", tostring(templateId or ""))
	path = string.gsub(path, "{1}", tostring(partResource or ""))
	path = string.gsub(path, "{2}", tostring(colorResource or ""))
	path = string.gsub(path, "{3}", tostring(suffix or ""))

	if string.sub(path, 1, 1) ~= "$" then
		path = "$" .. path
	end

	if not string.find(path, "%.prefab$") then
		path = path .. ".prefab"
	end

	return path
end

function PetTransmogUtils.buildPartTransmogEffects(modelTemplateId, partData, colorResource, flashEnabled)
	if not partData or partData.isDefault then
		return nil
	end

	local cfg = PetTransmogUtils.getSlotConfig(partData.slotId)

	if not cfg then
		return nil
	end

	local effectList

	if flashEnabled then
		effectList = cfg.effectLight
	else
		effectList = cfg.effect
	end

	if not Utils.isTable(effectList) then
		return nil
	end

	local effects = {}

	for _, item in ipairs(effectList) do
		local suffix = item[1]

		if suffix and suffix ~= "" then
			effects[#effects + 1] = {
				effectResId = PetTransmogUtils.formatTransmogEffectPath(modelTemplateId, partData.resources, colorResource, suffix),
				effectBone = item[2] or ""
			}
		end
	end

	return next(effects) and effects or nil
end

function PetTransmogUtils.getSchemeModelPaths(templateId, scheme)
	local result = {}
	local holeIds = scheme and scheme.holeIds

	if not holeIds or not next(holeIds) or not PetTransmogUtils.getSchemeCompositeColorResource(templateId, scheme) then
		local petCfg = templateId and (PetData[templateId] or PetData[tonumber(templateId)])
		local path = petCfg and (petCfg.prefabResID or petCfg.modelResId)

		if path and path ~= "" then
			result[#result + 1] = {
				isBaseModel = true,
				holeIndex = 0,
				slotId = 0,
				path = path
			}
		end

		return result
	end

	local templateIdStr = tostring(templateId)

	for holeIndex, slotId in pairs(holeIds) do
		local cfg = PetTransmogUtils.getSlotConfig(slotId)

		if cfg and cfg.resources and cfg.resources ~= "" and (not templateId or not cfg.petId or tostring(cfg.petId) == templateIdStr) then
			result[#result + 1] = {
				holeIndex = holeIndex,
				slotId = slotId,
				path = cfg.resources,
				attachHp = cfg.attachHp or cfg.attach
			}
		end
	end

	table.sort(result, function(a, b)
		return (a.holeIndex or 0) < (b.holeIndex or 0)
	end)

	return result
end

function PetTransmogUtils.getSchemeCompositePartList(templateId, scheme, colorResource)
	local result = {}

	colorResource = colorResource or PetTransmogUtils.getSchemeCompositeColorResource(templateId, scheme)

	if not templateId or not colorResource then
		return result
	end

	local holeIds = scheme and scheme.holeIds
	local templateIdStr = tostring(templateId)
	local partMap = {}

	if holeIds then
		for holeIndex, slotId in pairs(holeIds) do
			local cfg = PetTransmogUtils.getSlotConfig(slotId)

			if cfg and cfg.resources and cfg.resources ~= "" and (not cfg.petId or tostring(cfg.petId) == templateIdStr) then
				partMap[cfg.type] = {
					holeIndex = holeIndex,
					slotId = slotId,
					type = cfg.type,
					resources = cfg.resources
				}
			end
		end
	end

	local zeroSlotIds = PetTransmogUtils.getSuitZeroSlotIds(templateId)

	for _, partType in ipairs(TRANSMOG_COMPOSITE_PART_TYPES) do
		local data = partMap[partType]

		if not data then
			local zeroCfg = PetTransmogUtils.getSlotConfig(zeroSlotIds[partType])

			if zeroCfg and zeroCfg.resources and zeroCfg.resources ~= "" then
				data = {
					isDefault = true,
					holeIndex = partType,
					slotId = zeroSlotIds[partType],
					type = partType,
					resources = zeroCfg.resources
				}
			end
		end

		if data then
			result[#result + 1] = data
		end
	end

	return result
end

function PetTransmogUtils.getSchemeCompositeColorResource(templateId, scheme)
	if not templateId then
		return nil
	end

	local holeIds = scheme and scheme.holeIds

	if holeIds and next(holeIds) then
		local templateIdStr = tostring(templateId)

		for _, slotId in pairs(holeIds) do
			local cfg = PetTransmogUtils.getSlotConfig(slotId)

			if cfg and cfg.type == TRANSMOG_COLOR_TYPE and cfg.resources and cfg.resources ~= "" and (not cfg.petId or tostring(cfg.petId) == templateIdStr) then
				return cfg.resources
			end
		end
	end

	local zeroColorSlotId = PetTransmogUtils.getSuitZeroSlotIds(templateId)[TRANSMOG_COLOR_TYPE]
	local zeroCfg = PetTransmogUtils.getSlotConfig(zeroColorSlotId)

	if zeroCfg and zeroCfg.resources and zeroCfg.resources ~= "" then
		return zeroCfg.resources
	end

	return nil
end

function PetTransmogUtils.isSchemeFlashEffectEnabled(templateId, scheme)
	local holeIds = scheme and scheme.holeIds
	local flashSlotId = holeIds and holeIds[Const.PetTransmogSlotType.Flash]

	if not flashSlotId then
		return false
	end

	local cfg = PetTransmogUtils.getSlotConfig(flashSlotId)

	return cfg ~= nil and cfg.type == Const.PetTransmogSlotType.Flash and cfg.effectSwitch == 1 and (not cfg.petId or tostring(cfg.petId) == tostring(templateId))
end

function PetTransmogUtils.getSchemeSuitEff(templateId, scheme, flashEnabled)
	if flashEnabled == nil then
		flashEnabled = PetTransmogUtils.isSchemeFlashEffectEnabled(templateId, scheme)
	end

	if not flashEnabled then
		return nil
	end

	local suitMap = templateId and PetTransmogSuitPerviewData[templateId]

	if not suitMap then
		return nil
	end

	for _, slotId in pairs(scheme.holeIds) do
		local cfg = PetTransmogUtils.getSlotConfig(slotId)

		if cfg and cfg.suitId then
			local entry = suitMap[cfg.suitId]
			local suitEff = entry and entry.suitEff

			return Utils.isTable(suitEff) and next(suitEff) and suitEff or nil
		end
	end

	return nil
end

function PetTransmogUtils.getSchemeTransmogData(templateId, scheme)
	local colorResource = PetTransmogUtils.getSchemeCompositeColorResource(templateId, scheme)

	if not colorResource then
		return nil
	end

	local partList = PetTransmogUtils.getSchemeCompositePartList(templateId, scheme, colorResource)

	if not partList or #partList <= 0 then
		return nil
	end

	local transmogData = {}
	local petCfg = templateId and PetData[templateId]
	local modelTemplateId = petCfg and petCfg.resId or templateId
	local flashEnabled = PetTransmogUtils.isSchemeFlashEffectEnabled(templateId, scheme)

	for _, partData in ipairs(partList) do
		local pointId = TRANSMOG_PART_TYPE_TO_APPEARANCE_POINT[partData.type]

		if pointId and partData.resources and partData.resources ~= "" then
			local resId = PetTransmogUtils.formatCompositeModelPath(modelTemplateId, partData.resources, colorResource)
			local effects = PetTransmogUtils.buildPartTransmogEffects(modelTemplateId, partData, colorResource, flashEnabled)

			transmogData[pointId] = {
				resId = resId,
				isLight = flashEnabled,
				effects = effects
			}
		end
	end

	local shinyEffectId = PetTransmogUtils.getSchemeSuitEff(templateId, scheme, flashEnabled)

	return next(transmogData) and transmogData or nil, shinyEffectId
end

function PetTransmogUtils.hasAppliedTransmog(petId)
	if not pg.me or not petId then
		return false
	end

	local pet = pg.me:getPetInfo(petId)

	if not pet then
		return false
	end

	local scheme = PetTransmogUtils.getSelectedScheme(pet)

	if not scheme or (scheme.index or 0) == 0 then
		return false
	end

	return PetTransmogUtils.isTemplateTransmogable(pet.templateId)
end

function PetTransmogUtils.isTemplateTransmogable(templateId)
	return templateId ~= nil and PetTransmogTypesetData[templateId] ~= nil
end

function PetTransmogUtils.getDisplayLabel(templateId, label)
	label = label or 0

	if PetTransmogUtils.isTemplateTransmogable(templateId) then
		return bit.band(label, bit.bnot(Const.PET_LABEL_MASK.SHINY))
	end

	return label
end

function PetTransmogUtils.getAppliedSchemeTransmogData(petId)
	local pet = PetTransmogUtils.getPetInfo(petId)

	if not pet then
		return nil
	end

	local appliedScheme = PetTransmogUtils.getSelectedScheme(pet)

	if not appliedScheme or (appliedScheme.index or 0) == 0 then
		return nil
	end

	local transmogData, transmogShinyEffects = PetTransmogUtils.getSchemeTransmogData(pet.templateId, appliedScheme)

	return transmogData, transmogShinyEffects, appliedScheme
end

function PetTransmogUtils.applyAppliedTransmog(entity, petId, clearWhenNone)
	if not entity or not entity.setTransmogData or not petId then
		return false
	end

	local pet = PetTransmogUtils.getPetInfo(petId)

	if not pet or not PetTransmogUtils.isTemplateTransmogable(pet.templateId) then
		return false
	end

	local scheme = PetTransmogUtils.getSelectedScheme(pet)
	local transmogData, shinyEffects

	if PetTransmogUtils.hasAppliedTransmog(petId) then
		transmogData, shinyEffects = PetTransmogUtils.getAppliedSchemeTransmogData(petId)
	end

	local targetSignature = "empty"

	if transmogData then
		targetSignature = PetTransmogUtils.getSchemeModelCacheKey(pet.templateId, scheme)
	end

	if entity.transmogSignature == targetSignature then
		return false
	end

	if not transmogData then
		if not clearWhenNone then
			return false
		end

		entity:setTransmogData(nil, nil, "empty")

		return true
	end

	if Utils.isTable(shinyEffects) and next(shinyEffects) then
		entity:setDisableEffectLod(true)
	end

	entity:setTransmogData(transmogData, shinyEffects, targetSignature)

	return true
end

function PetTransmogUtils.applySchemeTransmog(entity, templateId, scheme, clearWhenNone, useTemplateFallback)
	if not entity or not entity.setTransmogData then
		return false
	end

	if not PetTransmogUtils.isTemplateTransmogable(templateId) then
		return false
	end

	local transmogData, shinyEffects
	local hasScheme = scheme and (scheme.index or 0) ~= 0

	if hasScheme or useTemplateFallback then
		transmogData, shinyEffects = PetTransmogUtils.getSchemeTransmogData(templateId, scheme)
	end

	local targetSignature = "empty"

	if transmogData then
		targetSignature = PetTransmogUtils.getSchemeModelCacheKey(templateId, scheme)
	end

	local forceRefresh = useTemplateFallback and not hasScheme

	if entity.transmogSignature == targetSignature and not forceRefresh then
		return false
	end

	if not transmogData then
		if not clearWhenNone then
			return false
		end

		entity:setTransmogData(nil, nil, "empty")

		return true
	end

	if Utils.isTable(shinyEffects) and next(shinyEffects) then
		entity:setDisableEffectLod(true)
	end

	entity:setTransmogData(transmogData, shinyEffects, targetSignature, forceRefresh)

	return true
end

function PetTransmogUtils.getSchemeModelCacheKey(templateId, scheme, label, shinyStyle)
	local parts = {
		tostring(templateId or "nil")
	}
	local holeIds = scheme and scheme.holeIds

	if holeIds and next(holeIds) then
		local keys = {}

		for holeIndex in pairs(holeIds) do
			keys[#keys + 1] = holeIndex
		end

		table.sort(keys)

		for _, holeIndex in ipairs(keys) do
			parts[#parts + 1] = tostring(holeIndex) .. ":" .. tostring(holeIds[holeIndex] or 0)
		end
	else
		parts[#parts + 1] = "default"
	end

	if label then
		parts[#parts + 1] = label
	end

	if shinyStyle then
		parts[#parts + 1] = shinyStyle
	end

	return table.concat(parts, "_")
end

function PetTransmogUtils.getPetSlotMap(petId)
	local pet = PetTransmogUtils.getPetInfo(petId)
	local templateId = pet and pet.templateId

	return templateId and PetTransmogTypesetData[templateId] or nil
end

function PetTransmogUtils.getPetInfo(petId)
	if not pg.me or not petId then
		return nil
	end

	return pg.me:getPetInfo(petId)
end

function PetTransmogUtils.getTransmogInfo(petInfo)
	return petInfo and petInfo:getTransmogInfo() or nil
end

function PetTransmogUtils.getSelectedScheme(petInfo)
	return petInfo and petInfo.getSelectTransmogScheme and petInfo:getSelectTransmogScheme() or nil
end

function PetTransmogUtils.getCurrentScheme(petId)
	local transmogInfo = PetTransmogUtils.getTransmogInfo(PetTransmogUtils.getPetInfo(petId))

	return transmogInfo and transmogInfo.currTransmogScheme or nil
end

function PetTransmogUtils.getCurrentDisplayScheme(petId)
	return _patchDefaultColor(petId, PetTransmogUtils.getCurrentScheme(petId))
end

function PetTransmogUtils.getUseSpecialItemFlag(petId)
	local scheme = PetTransmogUtils.getCurrentScheme(petId)

	return scheme and scheme.useSpecialItemFlag == true or false
end

function PetTransmogUtils.getSchemeLockedSet(scheme)
	local set = {}
	local list = scheme and scheme.lockHolesList

	if list then
		for _, holeIndex in ipairs(list) do
			set[holeIndex] = true
		end
	end

	return set
end

function PetTransmogUtils.getSelectedSchemeId(petId)
	local scheme = PetTransmogUtils.getSelectedScheme(PetTransmogUtils.getPetInfo(petId))

	return scheme and scheme.index or nil
end

function PetTransmogUtils.getAppliedTransmogValue(petId)
	local scheme = PetTransmogUtils.getSelectedScheme(PetTransmogUtils.getPetInfo(petId))

	return scheme and scheme.transmogValue or 0
end

function PetTransmogUtils.getCurrentTransmogValue(petId)
	local scheme = PetTransmogUtils.getCurrentScheme(petId)

	return scheme and scheme.transmogValue or 0
end

function PetTransmogUtils.getTransmogProgress(petId)
	local transmogInfo = PetTransmogUtils.getTransmogInfo(PetTransmogUtils.getPetInfo(petId))

	return transmogInfo and transmogInfo.transmogProgress or 0
end

function PetTransmogUtils.getCurrentSuitInfo(petId)
	local scheme = PetTransmogUtils.getCurrentScheme(petId)
	local holeIds = scheme and scheme.holeIds

	if not holeIds then
		return nil
	end

	local commonSuitId

	for i = Const.PetTransmogSlotType.Color, Const.PetTransmogSlotType.Max - 1 do
		if not PetTransmogUtils.isHoleUnlocked(petId, i) then
			return nil
		end

		local cfg = PetTransmogUtils.getSlotConfig(holeIds[i])

		if not cfg or not cfg.suitId then
			return nil
		end

		if commonSuitId == nil then
			commonSuitId = cfg.suitId
		elseif cfg.suitId ~= commonSuitId then
			return nil
		end
	end

	local suitMap = PetTransmogUtils.getSuitPreviewMap(petId)
	local entry = suitMap and suitMap[commonSuitId]

	if not entry then
		return nil
	end

	return {
		suitId = commonSuitId,
		quality = entry.quality or 0,
		name = entry.name and pg.getLocalizationText(entry.name) or ""
	}
end

function PetTransmogUtils.getUnlockedHoles(petId)
	local transmogInfo = PetTransmogUtils.getTransmogInfo(PetTransmogUtils.getPetInfo(petId))

	return transmogInfo and transmogInfo.transmogUnlockSolts or nil
end

function PetTransmogUtils.isAllHolesUnlocked(petId)
	local list = PetTransmogUtils.getUnlockedHoles(petId)

	return list ~= nil and #list >= Const.PetTransmogSlotType.Max
end

function PetTransmogUtils.getSchemePhotoId(petId, schemeIndex)
	if petId == nil or schemeIndex == nil then
		return nil
	end

	return Utils.getAppearanceCustomPhotoId(petId, "transmogSecheme", schemeIndex)
end

function PetTransmogUtils.getCustomSchemes(petId)
	local transmogInfo = PetTransmogUtils.getTransmogInfo(PetTransmogUtils.getPetInfo(petId))
	local schemeMap = transmogInfo and transmogInfo.customTransmogSchemes
	local customCap = PetTransmogUtils.getMaxCustomCount()

	if customCap <= 0 then
		customCap = 5
	end

	local slotCount = customCap + 1
	local byIndex = {}
	local maxValue, recommendedIdx = 0

	if schemeMap then
		for _, s in pairs(schemeMap) do
			if s and s.index ~= nil then
				byIndex[s.index] = s

				local v = s.transmogValue or 0

				if maxValue < v then
					maxValue, recommendedIdx = v, s.index
				end
			end
		end
	end

	local selectedId = PetTransmogUtils.getSelectedSchemeId(petId)
	local allUnlocked = PetTransmogUtils.isAllHolesUnlocked(petId)
	local defaultPic = PetTransmogUtils.getDefaultSuitPic(petId)
	local list = {}

	for i = Const.PetTransmogCustomDefultSchemeIndex, slotCount do
		local scheme = byIndex[i]

		if i == Const.PetTransmogCustomDefultSchemeIndex then
			scheme = _patchDefaultColor(petId, scheme)
		end

		local exists = i == Const.PetTransmogCustomDefultSchemeIndex or scheme ~= nil
		local holeIds = scheme and scheme.holeIds or nil
		local quality = 0

		if holeIds and allUnlocked then
			local commonSuitId, suitQuality, isFullSuit = nil, nil, true

			for j = Const.PetTransmogSlotType.Color, Const.PetTransmogSlotType.Max - 1 do
				local cfg = PetTransmogUtils.getSlotConfig(holeIds[j])

				if not cfg or not cfg.suitId then
					isFullSuit = false

					break
				end

				if commonSuitId == nil then
					commonSuitId = cfg.suitId
					suitQuality = cfg.quality or 0
				elseif cfg.suitId ~= commonSuitId then
					isFullSuit = false

					break
				end
			end

			if isFullSuit and suitQuality then
				quality = suitQuality
			end
		end

		list[#list + 1] = {
			index = i,
			exists = exists,
			name = i == Const.PetTransmogCustomDefultSchemeIndex and pg.getGameString("PETTRANSMOGRIFY_DEFAULT") or pg.getFormatText(pg.getGameString("PETTRANSMOGRIFY_CUSTOM_NAME"), i - 1),
			quality = quality,
			transmogValue = scheme and scheme.transmogValue or 0,
			holeIds = holeIds,
			_colorPatched = scheme and scheme._colorPatched or nil,
			isApplying = exists and selectedId ~= nil and selectedId == i,
			isRecommended = exists and recommendedIdx == i,
			photoId = i ~= Const.PetTransmogCustomDefultSchemeIndex and PetTransmogUtils.getSchemePhotoId(petId, i) or nil,
			defaultPic = defaultPic
		}
	end

	table.sort(list, function(a, b)
		local pa = a.isApplying and 1 or a.exists and 2 or 3
		local pb = b.isApplying and 1 or b.exists and 2 or 3

		if pa ~= pb then
			return pa < pb
		end

		return (a.index or 0) < (b.index or 0)
	end)

	return list
end

function PetTransmogUtils.isCustomFull(petId)
	for _, s in ipairs(PetTransmogUtils.getCustomSchemes(petId)) do
		if s.index and s.index > Const.PetTransmogCustomDefultSchemeIndex and not s.exists then
			return false
		end
	end

	return true
end

function PetTransmogUtils.getFirstEmptyCustomIndex(petId)
	for _, s in ipairs(PetTransmogUtils.getCustomSchemes(petId)) do
		if s.index and s.index > Const.PetTransmogCustomDefultSchemeIndex and not s.exists then
			return s.index
		end
	end

	return nil
end

function PetTransmogUtils.getCustomSchemeDisplayName(customIndex)
	return pg.getFormatText(pg.getGameString("PETTRANSMOGRIFY_CUSTOM_NAME"), (customIndex or 0) - 1)
end

function PetTransmogUtils.getTempSchemes(petId)
	local transmogInfo = PetTransmogUtils.getTransmogInfo(PetTransmogUtils.getPetInfo(petId))
	local map = transmogInfo and transmogInfo.tempTransmogSchemes
	local list = {}

	if not map then
		return list
	end

	for _, scheme in pairs(map) do
		list[#list + 1] = scheme
	end

	table.sort(list, function(a, b)
		local va, vb = a.transmogValue or 0, b.transmogValue or 0

		if va ~= vb then
			return vb < va
		end

		return (a.createTime or 0) > (b.createTime or 0)
	end)

	return list
end

function PetTransmogUtils.getHoleCount()
	return Const.PetTransmogSlotType.Max
end

function PetTransmogUtils.getTransmogExpList()
	return PetTransmogUtils.getBaseRaw("transmog_exp")
end

function PetTransmogUtils.getMaxTransmogValue(petId)
	local expList = PetTransmogUtils.getTransmogExpList()

	if not expList or #expList == 0 then
		return 0
	end

	return expList[#expList]
end

function PetTransmogUtils.getTransmogSliderFill(progress)
	local expList = PetTransmogUtils.getTransmogExpList()
	local n = expList and #expList or 0

	if n <= 1 then
		return 0
	end

	progress = progress or 0

	if progress >= expList[n] then
		return 1
	end

	for i = 1, n - 1 do
		local lo, hi = expList[i], expList[i + 1]

		if progress < hi then
			local segFrac = lo < hi and (progress - lo) / (hi - lo) or 0

			if segFrac < 0 then
				segFrac = 0
			end

			return (i - 1 + segFrac) / (n - 1)
		end
	end

	return 1
end

function PetTransmogUtils.isHoleUnlocked(petId, holeIndex)
	if not holeIndex then
		return false
	end

	local list = PetTransmogUtils.getUnlockedHoles(petId)

	if not list then
		return false
	end

	for _, v in ipairs(list) do
		if v == holeIndex then
			return true
		end
	end

	return false
end

function PetTransmogUtils.getLockableHoleCount(petId)
	local list = PetTransmogUtils.getUnlockedHoles(petId)

	if not list then
		return 0
	end

	local count = 0

	for _, holeIndex in ipairs(list) do
		if holeIndex ~= Const.PetTransmogSlotType.Flash then
			count = count + 1
		end
	end

	return count
end

function PetTransmogUtils.canUseTransmogSpecialItem(petId)
	local specialItemId = PetTransmogUtils.getTransmogSpecialItemId()
	local gateHole = PetTransmogUtils.getSpecialSlotSuitId() + 1

	return specialItemId > 0 and not PetTransmogUtils.isHoleUnlocked(petId, gateHole)
end

function PetTransmogUtils.getItemOwnedCount(itemId)
	if not pg.me or not itemId or itemId <= 0 then
		return 0
	end

	return pg.me:getItemCountById(itemId, false) or 0
end

function PetTransmogUtils.getRollMaterialStatus(petId, needCount, useSpecialItemFlag)
	needCount = needCount or 0

	local needItemId = PetTransmogUtils.getTransmogItemId()
	local specialItemId = PetTransmogUtils.getTransmogSpecialItemId()
	local useSpecial = useSpecialItemFlag

	if useSpecial == nil then
		useSpecial = PetTransmogUtils.getUseSpecialItemFlag(petId)
	end

	useSpecial = useSpecial == true and PetTransmogUtils.canUseTransmogSpecialItem(petId)

	local needOwned = useSpecial and 0 or PetTransmogUtils.getItemOwnedCount(needItemId)
	local specialOwned = useSpecial and PetTransmogUtils.getItemOwnedCount(specialItemId) or 0
	local totalOwned = useSpecial and specialOwned or needOwned
	local lackCount = math.max(needCount - totalOwned, 0)
	local displayItemId = useSpecial and specialItemId or needItemId
	local specialUseCount = useSpecial and needCount or 0
	local needUseCount = useSpecial and 0 or needCount

	return {
		needItemId = needItemId,
		specialItemId = specialItemId,
		useSpecial = useSpecial,
		needOwned = needOwned,
		specialOwned = specialOwned,
		totalOwned = totalOwned,
		lackCount = lackCount,
		displayItemId = displayItemId,
		specialUseCount = specialUseCount,
		needUseCount = needUseCount
	}
end

function PetTransmogUtils.isHoleDisplayUnlocked(petId, holeIndex)
	if PetTransmogUtils.isHoleUnlocked(petId, holeIndex) then
		return true
	end

	if holeIndex == Const.PetTransmogSlotType.Color and PetTransmogUtils.getDefaultColorSlotId(petId) then
		return true
	end

	return false
end

function PetTransmogUtils.getHoleQuality(scheme, holeIndex)
	if not scheme or not scheme.holeIds then
		return 0
	end

	local slotId = scheme.holeIds[holeIndex]
	local cfg = PetTransmogUtils.getSlotConfig(slotId)

	return cfg and cfg.quality or 0
end

function PetTransmogUtils.getSlotName(petId, scheme, holeIndex)
	if not scheme or not scheme.holeIds then
		return ""
	end

	if holeIndex == Const.PetTransmogSlotType.Flash then
		local selSlotId = scheme.holeIds[holeIndex]
		local selCfg = selSlotId and PetTransmogSoltData[selSlotId]

		if selCfg and selCfg.effectSwitch == 1 then
			local suitId

			for _, sid in pairs(scheme.holeIds) do
				local cfg = PetTransmogSoltData[sid]

				if cfg and cfg.suitId then
					suitId = cfg.suitId

					break
				end
			end

			local suitMap = PetTransmogUtils.getSuitPreviewMap(petId)
			local entry = suitId and suitMap and suitMap[suitId]

			if entry and entry.name then
				return pg.getLocalizationText(entry.name)
			end
		end
	end

	local cfg = PetTransmogUtils.getSlotConfig(scheme.holeIds[holeIndex])

	return cfg and cfg.name and pg.getLocalizationText(cfg.name) or ""
end

function PetTransmogUtils.getHoleName(petId, holeIndex)
	local map = PetTransmogUtils.getPetSlotMap(petId)
	local slotWeights = map and map[holeIndex]

	if not slotWeights then
		return ""
	end

	local firstSlotId = next(slotWeights)
	local cfg = firstSlotId and PetTransmogSoltData[firstSlotId]

	return cfg and pg.getLocalizationText(cfg.typename) or ""
end

return PetTransmogUtils
