-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\RobEggCollectionDisplayEffectUtils.lua

local ClientEffectUtils = require("Utils.ClientEffectUtils")
local ClientConst = require("Const.ClientConst")
local EffectConst = require("Const.EffectConst")
local Utils = require("Common.Utils.Utils")
local RobEggCollectionDisplayEffectUtils = {}
local EFFECT_IDS_FIELD = "_robEggCollectionDisplayCommonMountEffectIds"

local function findTransformRecursive(rootTransform, transformName)
	if IsNil(rootTransform) or not transformName or transformName == "" then
		return nil
	end

	if rootTransform.name == transformName then
		return rootTransform
	end

	for index = 0, rootTransform.childCount - 1 do
		local result = findTransformRecursive(rootTransform:GetChild(index), transformName)

		if NotNil(result) then
			return result
		end
	end

	return nil
end

local function getItemModelRootTransform(entity)
	local itemModel = entity and entity.eModel and entity.eModel.itemModel

	if NotNil(itemModel) then
		return itemModel.transform
	end

	return nil
end

local function getRawEffectResId(effectKey)
	if type(effectKey) ~= "string" or effectKey == "" then
		return effectKey
	end

	local resId = effectKey

	if string.sub(resId, 1, 1) ~= "$" then
		resId = "$" .. resId
	end

	if string.sub(resId, -7) ~= ".prefab" then
		resId = resId .. ".prefab"
	end

	return resId
end

local function getCommonMountEffectEntries(modelResId)
	local mountData = modelResId and ClientEffectUtils.getBestFitData(modelResId, nil)
	local entries = {}

	for _, info in pairs(mountData or {}) do
		if Utils.isTable(info) and Utils.isTable(info.resIdList) then
			for _, effectInfo in ipairs(info.resIdList) do
				local effectKey = Utils.isTable(effectInfo) and effectInfo.resId or nil

				if type(effectKey) == "string" and effectKey ~= "" then
					entries[#entries + 1] = {
						mountInfo = info,
						effectInfo = effectInfo,
						effectKey = effectKey
					}
				end
			end
		end
	end

	return entries
end

local function playCommonMountEffect(effectKey, extraInfo)
	if not pg.game or not pg.game.effect or not pg.global or not pg.global.effectMgr then
		return nil
	end

	local resId = getRawEffectResId(effectKey)
	local rawInfo = {
		duration = -1,
		staticSpeed = true,
		resID = resId,
		mountType = EffectConst.MountType.Custom,
		followType = EffectConst.FollowType.Global,
		scale = {
			1,
			1,
			1
		}
	}
	local effectConfigInfo = pg.game.effect:createEffectConfigInfo(rawInfo, extraInfo)

	return pg.global.effectMgr:PlayEffect(0, resId, effectConfigInfo, 0, true)
end

function RobEggCollectionDisplayEffectUtils.hasCommonMountEffects(modelResId)
	return #getCommonMountEffectEntries(modelResId) > 0
end

function RobEggCollectionDisplayEffectUtils.clearCommonMountEffects(entity)
	if not entity then
		return
	end

	local effectIds = entity[EFFECT_IDS_FIELD]

	entity[EFFECT_IDS_FIELD] = nil

	if not pg.game or not pg.game.effect then
		return
	end

	for _, effectId in ipairs(effectIds or {}) do
		pg.game.effect:stopEffect(nil, effectId)
	end
end

function RobEggCollectionDisplayEffectUtils.applyCommonMountEffects(entity, modelResId, onLoaded)
	if not entity or not modelResId or modelResId == "" then
		if onLoaded then
			onLoaded(false)
		end

		return false
	end

	local entries = getCommonMountEffectEntries(modelResId)

	if #entries == 0 then
		if onLoaded then
			onLoaded(false)
		end

		return false
	end

	local modelRootTransform = getItemModelRootTransform(entity)

	if IsNil(modelRootTransform) then
		if onLoaded then
			onLoaded(false)
		end

		return false
	end

	RobEggCollectionDisplayEffectUtils.clearCommonMountEffects(entity)

	local effectIds = {}
	local pendingCount = #entries
	local hasLoadedEffect = false
	local loadCompleted = false

	local function completeOneEffectLoad(success)
		if loadCompleted then
			return
		end

		hasLoadedEffect = hasLoadedEffect or success == true
		pendingCount = pendingCount - 1

		if pendingCount <= 0 then
			loadCompleted = true

			if onLoaded then
				onLoaded(hasLoadedEffect)
			end
		end
	end

	for _, entry in ipairs(entries) do
		local info = entry.mountInfo
		local effectInfo = entry.effectInfo
		local targetTransform = findTransformRecursive(modelRootTransform, info.bone) or modelRootTransform
		local extraInfo = {
			targetTrans = targetTransform,
			layer = ClientConst.LayerDefine.LAYER_UI_SCENE,
			position = effectInfo.offset_P,
			rotation = effectInfo.offset_R,
			scale = effectInfo.offset_S,
			loadCallback = function(effectItem)
				completeOneEffectLoad(NotNil(effectItem))
			end
		}
		local effectId = playCommonMountEffect(entry.effectKey, extraInfo)

		if effectId and effectId ~= 0 then
			effectIds[#effectIds + 1] = effectId
		else
			completeOneEffectLoad(false)
		end
	end

	if #effectIds > 0 then
		entity[EFFECT_IDS_FIELD] = effectIds

		return true
	end

	return false
end

return RobEggCollectionDisplayEffectUtils
