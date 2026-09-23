-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\AppearanceEffectUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local AppearanceData = require("Data.appearance_data")
local PetAccessoryData = require("Data.appearance_jewelry_pet_data")
local AppearancePointEnum = require("Data.appearance_point_enum")
local AppearanceEffectUtils = {}

function AppearanceEffectUtils.createInfo(appearanceId, config, resId)
	local effectIds = config and config.attachEffects

	if not effectIds or #effectIds == 0 then
		return nil
	end

	return {
		appearanceId = appearanceId,
		effectIds = effectIds,
		resId = resId or config.res
	}
end

function AppearanceEffectUtils.createAppearanceInfo(appearanceId, resId)
	return AppearanceEffectUtils.createInfo(appearanceId, AppearanceData[appearanceId], resId)
end

function AppearanceEffectUtils.setAppearance(entity, slotId, appearanceId, resId)
	entity.appearanceEffectInfo = entity.appearanceEffectInfo or {}
	entity.appearanceEffectInfo[slotId] = AppearanceEffectUtils.createAppearanceInfo(appearanceId, resId)
end

function AppearanceEffectUtils.setPetAccessory(entity, slotId, accessoryId, attachInstanceId, resId)
	local info = AppearanceEffectUtils.createInfo(accessoryId, PetAccessoryData[accessoryId], resId)

	if info then
		info.attachInstanceId = attachInstanceId
	end

	entity.appearanceEffectInfo = entity.appearanceEffectInfo or {}
	entity.appearanceEffectInfo[slotId] = info
end

function AppearanceEffectUtils.replaceRange(entity, firstSlot, lastSlot, entries)
	entity.appearanceEffectInfo = entity.appearanceEffectInfo or {}
	entries = entries or EMPTY_TABLE

	for slotId = firstSlot, lastSlot do
		entity.appearanceEffectInfo[slotId] = entries[slotId]
	end
end

function AppearanceEffectUtils.clearAppearance(entity, slotId, appearanceId)
	local entries = entity.appearanceEffectInfo
	local info = entries and entries[slotId]

	if info and info.appearanceId == appearanceId then
		entries[slotId] = nil
	end
end

function AppearanceEffectUtils.setPartAppearance(entity, appearanceId, isApply)
	local config = AppearanceData[appearanceId]

	for _, slotId in ipairs(config and config.points or EMPTY_TABLE) do
		local isClothes = slotId >= AppearancePointEnum.Coat and slotId <= AppearancePointEnum.Shoes
		local isHair = slotId >= AppearancePointEnum.Fringe and slotId <= AppearancePointEnum.Plait

		if isClothes or isHair then
			if isApply then
				AppearanceEffectUtils.setAppearance(entity, slotId, appearanceId)
			else
				AppearanceEffectUtils.clearAppearance(entity, slotId, appearanceId)
			end
		end
	end
end

function AppearanceEffectUtils.copyAppearanceInfo(targetEntity, sourceEntity)
	local entries = {}

	for slotId, info in pairs(sourceEntity.appearanceEffectInfo or EMPTY_TABLE) do
		entries[slotId] = {
			appearanceId = info.appearanceId,
			effectIds = info.effectIds,
			resId = info.resId,
			attachInstanceId = info.attachInstanceId
		}
	end

	targetEntity.appearanceEffectInfo = entries
end

function AppearanceEffectUtils.isModelAttached(ent, modelInfo, info, slotId)
	if info.attachInstanceId then
		for instanceId, attachInfo in pairs(modelInfo.attachModelInfos) do
			if instanceId == info.attachInstanceId then
				return attachInfo.resId == info.resId
			end
		end

		return false
	end

	if slotId >= AppearancePointEnum.Jewelry1 and slotId <= AppearancePointEnum.Jewelry10 then
		for _, attachInfo in pairs(modelInfo.attachModelInfos) do
			if attachInfo.resId == info.resId then
				return true
			end
		end

		return false
	end

	local partResource = modelInfo.partModelInfo:GetPartResId(slotId)

	if not string.isNilOrEmpty(info.resId) and partResource == info.resId then
		return true
	end

	return false
end

function AppearanceEffectUtils.getAttachEffectKeys(ent)
	local effectKeys = {}
	local modelView = ent.eModel and ent.eModel.modelModelView
	local modelInfo = modelView and modelView.modelInfo

	if not modelInfo then
		return effectKeys
	end

	for slotId, info in pairs(ent.appearanceEffectInfo or EMPTY_TABLE) do
		if AppearanceEffectUtils.isModelAttached(ent, modelInfo, info, slotId) then
			for _, effectKey in ipairs(info.effectIds) do
				effectKeys[ent:getRealEffectKey(effectKey)] = effectKey
			end
		end
	end

	return effectKeys
end

return AppearanceEffectUtils
