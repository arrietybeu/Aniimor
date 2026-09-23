-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\RobEggCollectionVisualUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local ItemConst = require("Common.Const.ItemConst")
local RobEggCollectionRefine = require("Data.rob_egg_collection_calcine_data")
local RobEggItemOut = require("Data.rob_egg_item_out")
local CollectItemData = require("Data.collect_item_data")
local RobEggCollectionTagData = require("Data.rob_egg_collection_tag_data")
local RobEggCollectionVariantModelData = require("Data.rob_egg_collection_variant_model_data")
local RobEggCollectionVisualUtils = {}
local TAG_EFFECT_IDS_FIELD = "_robEggCollectionTagEffectIds"
local VISUAL_DATA_MARKER = "_isRobEggCollectionVisualData"

local function normalizeCollectionData(collectionItemOrData)
	if type(collectionItemOrData) ~= "table" then
		return nil, collectionItemOrData
	end

	local collectionData = collectionItemOrData.packSlot or collectionItemOrData

	return collectionData, collectionData.id or collectionData.itemId or collectionData.itemid or collectionItemOrData.itemId or collectionItemOrData.itemid
end

local function addTagEffect(effectKeys, effectKeySet, affixData)
	if type(affixData) ~= "table" or not affixData.affixId then
		return
	end

	local tagCfg = RobEggCollectionTagData[affixData.affixId]
	local effectKey = tagCfg and tagCfg.effect

	if type(effectKey) ~= "string" or effectKey == "" or effectKeySet[effectKey] then
		return
	end

	effectKeySet[effectKey] = true
	effectKeys[#effectKeys + 1] = effectKey
end

local function getTagEffectKeys(collectionData, extraAffixData)
	local effectKeys = {}
	local effectKeySet = {}
	local props = collectionData and collectionData.props
	local antiqueData = props and props[ItemConst.ItemPropertyDef.AntiqueData]
	local affixNum = antiqueData and antiqueData.affix_num or 0

	for i = 1, affixNum do
		local affixData = props[ItemConst.ItemPropertyDef.AntiqueData .. i] or props[ItemConst.ItemPropertyDef.AntiqueAffix .. i]

		addTagEffect(effectKeys, effectKeySet, affixData)
	end

	local pendingAffixData = extraAffixData and (extraAffixData.nextAffixData or extraAffixData)

	addTagEffect(effectKeys, effectKeySet, pendingAffixData)

	return effectKeys
end

local function getHiddenVariantModelIdFromAffixData(affixData)
	if type(affixData) ~= "table" or not affixData.affixId then
		return nil
	end

	local tagCfg = RobEggCollectionTagData[affixData.affixId]

	if not tagCfg or tagCfg.hiddenMark ~= 1 then
		return nil
	end

	local modelId = affixData.modelId

	return modelId and RobEggCollectionVariantModelData[modelId] and modelId or nil
end

local function getVariantModelId(collectionData, nextAffixData)
	local serverAffixData = nextAffixData and (nextAffixData.nextAffixData or nextAffixData)
	local modelId = getHiddenVariantModelIdFromAffixData(serverAffixData)

	if modelId then
		return modelId
	end

	local props = collectionData and collectionData.props

	if not props then
		return nil
	end

	local antiqueData = props[ItemConst.ItemPropertyDef.AntiqueData]

	modelId = getHiddenVariantModelIdFromAffixData(collectionData.nextAffixData) or getHiddenVariantModelIdFromAffixData(props.nextAffixData) or getHiddenVariantModelIdFromAffixData(antiqueData and antiqueData.nextAffixData)

	if modelId then
		return modelId
	end

	local affixNum = antiqueData and antiqueData.affix_num or 0

	for i = 1, affixNum do
		local affixData = props[ItemConst.ItemPropertyDef.AntiqueData .. i] or props[ItemConst.ItemPropertyDef.AntiqueAffix .. i]
		local affixModelId = getHiddenVariantModelIdFromAffixData(affixData)

		if affixModelId then
			modelId = affixModelId
		end
	end

	return modelId
end

function RobEggCollectionVisualUtils.getVisualData(collectionItemOrData, nextAffixData)
	local collectionData, itemId = normalizeCollectionData(collectionItemOrData)
	local variantModelId = getVariantModelId(collectionData, nextAffixData)
	local variantCfg = variantModelId and RobEggCollectionVariantModelData[variantModelId]
	local itemOutCfg = itemId and RobEggItemOut[itemId]
	local inItemId = itemOutCfg and itemOutCfg.inid or itemId
	local collectCfg = inItemId and CollectItemData[inItemId]
	local calcineCfg = itemId and RobEggCollectionRefine[itemId]

	return {
		[VISUAL_DATA_MARKER] = true,
		itemId = itemId,
		modelResId = variantCfg and variantCfg.model or collectCfg and collectCfg.model,
		modelScale = calcineCfg and calcineCfg.scale or collectCfg and collectCfg.modelScale or 1,
		variantModelId = variantModelId,
		itemParameter = calcineCfg and calcineCfg.itemParameter or nil,
		effectKeys = getTagEffectKeys(collectionData, nextAffixData)
	}
end

local function ensureVisualData(collectionItemOrVisualData, nextAffixData)
	if type(collectionItemOrVisualData) == "table" and collectionItemOrVisualData[VISUAL_DATA_MARKER] then
		return collectionItemOrVisualData
	end

	return RobEggCollectionVisualUtils.getVisualData(collectionItemOrVisualData, nextAffixData)
end

function RobEggCollectionVisualUtils.clearTagEffects(entity)
	local effectIds = entity and entity[TAG_EFFECT_IDS_FIELD]

	if not effectIds then
		return
	end

	if entity.stopEffectById then
		for _, effectId in pairs(effectIds) do
			if effectId and effectId ~= 0 then
				entity:stopEffectById(effectId)
			end
		end
	end

	entity[TAG_EFFECT_IDS_FIELD] = nil
end

function RobEggCollectionVisualUtils.refreshTagEffects(entity, collectionItemOrData, extraAffixData, forceSync)
	if not entity or not entity.eModel or not entity.playEffect then
		return false
	end

	local visualData = ensureVisualData(collectionItemOrData, extraAffixData)
	local effectKeys = visualData.effectKeys
	local desiredEffectKeys = {}

	for _, effectKey in ipairs(effectKeys) do
		desiredEffectKeys[effectKey] = true
	end

	local effectIds = entity[TAG_EFFECT_IDS_FIELD] or {}

	for effectKey, effectId in pairs(effectIds) do
		if not desiredEffectKeys[effectKey] then
			if effectId and effectId ~= 0 and entity.stopEffectById then
				entity:stopEffectById(effectId)
			end

			effectIds[effectKey] = nil
		end
	end

	local allEffectsReady = true

	for _, effectKey in ipairs(effectKeys) do
		if not effectIds[effectKey] then
			local effectId = entity:playEffect(effectKey, nil, forceSync == true)

			if effectId and effectId ~= 0 then
				effectIds[effectKey] = effectId
			else
				allEffectsReady = false
			end
		end
	end

	entity[TAG_EFFECT_IDS_FIELD] = effectIds

	return allEffectsReady
end

function RobEggCollectionVisualUtils.refreshEntity(entity, collectionItemOrData, nextAffixData, forceSync)
	local visualData = ensureVisualData(collectionItemOrData, nextAffixData)
	local allEffectsReady = RobEggCollectionVisualUtils.refreshTagEffects(entity, visualData, nil, forceSync)

	return visualData, allEffectsReady
end

return RobEggCollectionVisualUtils
