-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ClientEffectUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local EffectConst = require("Const.EffectConst")
local abilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local EffectCommonMountData = require("Common.Data.Effect.effect_common_mount_data")
local ClientModelUtils = require("Utils.ClientModelUtils")
local AvatarPresetData = require("Data.avatar_preset_data")
local AppearanceSuitData = require("Data.appearance_suit_data")
local AddressDataConst = require("Const.AddressDataConst")
local PetFertilityConst = require("Const.PetFertilityConst")

if EffectCommonMountData == nil then
	EffectCommonMountData = require("Data.effect_common_mount_data")
end

local ClientEffectUtils = {}
local ShaderViewCommand = {
	RemoveMaterialEffectByFilterName = "RemoveMaterialEffectByFilterName",
	ApplyMaterialEffectByFilterName = "ApplyMaterialEffectByFilterName",
	RemoveMaterialEffect = "RemoveMaterialEffect",
	ApplyMaterialEffect = "ApplyMaterialEffect",
	PlayPresetWithFilterMark = "PlayPresetWithFilterMark",
	StopPreset = "StopPreset",
	PlayPreset = "PlayPreset"
}

function ClientEffectUtils.getEntityShaderView(entity, targetShaderView)
	if not IsNil(targetShaderView) then
		return targetShaderView
	end

	if not entity or not entity.eModel then
		return
	end

	local shaderView = entity.eModel.shaderView

	if IsNil(shaderView) then
		shaderView = entity.eModel.modelShaderView
	end

	if IsNil(shaderView) then
		return
	end

	return shaderView
end

function ClientEffectUtils.executeShaderViewCommandImmediately(entity, command, targetShaderView, ...)
	local shaderView = ClientEffectUtils.getEntityShaderView(entity, targetShaderView)

	if not shaderView then
		return false
	end

	if command == ShaderViewCommand.PlayPreset then
		shaderView:PlayPreset(...)
	elseif command == ShaderViewCommand.StopPreset then
		shaderView:StopPreset(...)
	elseif command == ShaderViewCommand.PlayPresetWithFilterMark then
		shaderView:PlayPresetWithFilterMark(...)
	elseif command == ShaderViewCommand.ApplyMaterialEffect then
		shaderView:ApplyMaterialEffect(...)
	elseif command == ShaderViewCommand.RemoveMaterialEffect then
		shaderView:RemoveMaterialEffect(...)
	elseif command == ShaderViewCommand.ApplyMaterialEffectByFilterName then
		shaderView:ApplyMaterialEffectByFilterName(...)
	elseif command == ShaderViewCommand.RemoveMaterialEffectByFilterName then
		shaderView:RemoveMaterialEffectByFilterName(...)
	else
		return false
	end

	return true
end

function ClientEffectUtils.executeShaderViewCommand(entity, commandInfo)
	return ClientEffectUtils.executeShaderViewCommandImmediately(entity, commandInfo.command, commandInfo.targetShaderView, unpack(commandInfo.args, 1, commandInfo.argCount))
end

function ClientEffectUtils.executeOrQueueShaderViewCommand(entity, command, targetShaderView, ...)
	if not entity then
		return false
	end

	if entity.isWaitTransmogCallback then
		local commandInfo = {
			command = command,
			targetShaderView = targetShaderView,
			args = {
				...
			},
			argCount = select("#", ...)
		}

		entity.waitTransmogCallbackList = entity.waitTransmogCallbackList or {}
		entity.waitTransmogCallbackList[#entity.waitTransmogCallbackList + 1] = commandInfo

		return true
	end

	return ClientEffectUtils.executeShaderViewCommandImmediately(entity, command, targetShaderView, ...)
end

function ClientEffectUtils.executeWaitTransmogCallbackList(entity)
	if not entity then
		return
	end

	entity.isWaitTransmogCallback = false

	local commandList = entity.waitTransmogCallbackList

	entity.waitTransmogCallbackList = nil

	if not commandList then
		return
	end

	for i = 1, #commandList do
		ClientEffectUtils.executeShaderViewCommand(entity, commandList[i])
	end
end

function ClientEffectUtils.PlayPreset(entity, ...)
	return ClientEffectUtils.executeOrQueueShaderViewCommand(entity, ShaderViewCommand.PlayPreset, nil, ...)
end

function ClientEffectUtils.PlayPresetImmediately(entity, ...)
	return ClientEffectUtils.executeShaderViewCommandImmediately(entity, ShaderViewCommand.PlayPreset, nil, ...)
end

function ClientEffectUtils.StopPreset(entity, ...)
	return ClientEffectUtils.executeOrQueueShaderViewCommand(entity, ShaderViewCommand.StopPreset, nil, ...)
end

function ClientEffectUtils.PlayPresetWithFilterMark(entity, ...)
	return ClientEffectUtils.executeOrQueueShaderViewCommand(entity, ShaderViewCommand.PlayPresetWithFilterMark, nil, ...)
end

function ClientEffectUtils.ApplyMaterialEffect(entity, ...)
	return ClientEffectUtils.executeOrQueueShaderViewCommand(entity, ShaderViewCommand.ApplyMaterialEffect, nil, ...)
end

function ClientEffectUtils.StopMaterialEffect(entity, ...)
	return ClientEffectUtils.executeOrQueueShaderViewCommand(entity, ShaderViewCommand.RemoveMaterialEffect, nil, ...)
end

function ClientEffectUtils.ApplyMaterialEffectByFilterName(entity, ...)
	return ClientEffectUtils.executeOrQueueShaderViewCommand(entity, ShaderViewCommand.ApplyMaterialEffectByFilterName, nil, ...)
end

function ClientEffectUtils.ApplyMaterialEffectByFilterNameToShaderView(entity, targetShaderView, ...)
	return ClientEffectUtils.executeOrQueueShaderViewCommand(entity, ShaderViewCommand.ApplyMaterialEffectByFilterName, targetShaderView, ...)
end

function ClientEffectUtils.RemoveMaterialEffectByFilterName(entity, ...)
	return ClientEffectUtils.executeOrQueueShaderViewCommand(entity, ShaderViewCommand.RemoveMaterialEffectByFilterName, nil, ...)
end

function ClientEffectUtils.getEffectLevelInfo(effectKey, rawInfo, extraInfo)
	local effectCategory = extraInfo.effectCategory or EffectConst.EFFECT_CATEGORY.MISC

	extraInfo.isImportant = extraInfo.isImportant or rawInfo.important

	local EFFECT_CATEGORY = EffectConst.EFFECT_CATEGORY

	if effectCategory == EFFECT_CATEGORY.MAIN_PLAYER or effectCategory == EFFECT_CATEGORY.MONSTER_BOSS then
		extraInfo.isImportant = true
	end

	extraInfo.effectLevel = 1
end

function ClientEffectUtils.getBestFitData(prefabResID, commonMountKey)
	local avatarName = ClientModelUtils.getModelAvatarName(prefabResID)
	local mountData = avatarName and EffectCommonMountData[avatarName]

	if not mountData and commonMountKey then
		mountData = EffectCommonMountData[commonMountKey]
	end

	mountData = mountData or EffectCommonMountData[prefabResID]

	return mountData
end

function ClientEffectUtils.getBestFitCommonMount(ent, effectPos)
	local configData = ent:getConfigData()

	if not configData then
		return nil
	end

	local prefabResID = ClientModelUtils.getModelPrefabResId(configData, 0, ent.gender or 0)
	local mountData = ClientEffectUtils.getBestFitData(prefabResID, configData.commonMountKey)

	if not mountData then
		return nil
	end

	mountData = mountData and (not mountData[effectPos] and mountData.ref and EffectCommonMountData[mountData.ref] or mountData)

	return mountData[effectPos]
end

function ClientEffectUtils.getBestFitCommonMountBoneName(ent, effectPos)
	local mountData = ClientEffectUtils.getBestFitCommonMount(ent, effectPos)

	return mountData and mountData.bone or effectPos
end

function ClientEffectUtils.applyEffectCommonMountData(ent, rawInfo, extraInfo)
	local effectPos = extraInfo.commonMount or rawInfo.commonMount

	if string.isNilOrEmpty(effectPos) then
		return
	end

	if not string.isNilOrEmpty(extraInfo.bone) then
		return
	end

	local partMountData = ClientEffectUtils.getBestFitCommonMount(ent, effectPos)

	if partMountData then
		local scale = partMountData.scale or {
			1,
			1,
			1
		}
		local baseScale = extraInfo.scale or rawInfo.scale or {
			1,
			1,
			1
		}
		local finalScale = {}

		for i = 1, 3 do
			if type(baseScale) == "number" then
				finalScale[i] = scale[i] * baseScale
			else
				finalScale[i] = scale[i] * baseScale[i]
			end
		end

		table.merge(extraInfo, partMountData or {})

		extraInfo.scale = finalScale
	end
end

function ClientEffectUtils.applyCommonMountEffects(ent)
	local configData = ent:getConfigData()

	if configData then
		local prefabResID = ClientModelUtils.getModelPrefabResId(configData, 0, ent.gender or 0)

		ClientEffectUtils.applyCommonMountEffectsInData(ent, prefabResID, configData.commonMountKey)
	end

	local modelView = ent.eModel.modelModelView

	if modelView then
		local modelInfo = modelView.modelInfo

		if modelInfo then
			for resId, partInfo in pairs(modelInfo.partModelInfo.res2Items) do
				ClientEffectUtils.applyCommonMountEffectsInData(ent, partInfo.resId, nil)
			end

			for resId, attachInfo in pairs(modelInfo.attachModelInfos) do
				ClientEffectUtils.applyCommonMountEffectsForAttach(ent, attachInfo.resId, attachInfo)
			end
		end
	end
end

function ClientEffectUtils.applyCommonMountEffectsInData(ent, resId, cmRef)
	if not resId then
		return false
	end

	local mountData = ClientEffectUtils.getBestFitData(resId, cmRef)

	if not mountData then
		return false
	end

	local extraInfo = {}

	for effectPos, info in pairs(mountData) do
		if ToBool(info.resIdList) then
			for _, effectInfo in ipairs(info.resIdList) do
				local effectKey = effectInfo.resId

				extraInfo.bone = info.bone
				extraInfo.position = effectInfo.offset_P
				extraInfo.rotation = effectInfo.offset_R
				extraInfo.scale = effectInfo.offset_S

				ent:playIntegratedToModelEffect(effectKey, extraInfo)
			end
		end
	end

	return true
end

function ClientEffectUtils.applyCommonMountEffectsForAttach(ent, resId, attachInfo)
	if not resId then
		return false
	end

	local mountData = ClientEffectUtils.getBestFitData(resId, nil)

	if not mountData then
		return false
	end

	local extraInfo = {}

	for effectPos, info in pairs(mountData) do
		if ToBool(info.resIdList) then
			for _, effectInfo in ipairs(info.resIdList) do
				local effectKey = effectInfo.resId

				if not info.bone or info.bone == "" then
					extraInfo.bone = attachInfo.attachHp
					extraInfo.attachInstanceId = nil
					extraInfo.position = effectInfo.offset_P + attachInfo.localOffset
					extraInfo.rotation = effectInfo.offset_R + attachInfo.localRotation
					extraInfo.scale = effectInfo.offset_S

					local attachScale = attachInfo.scale
					local scale = extraInfo.scale

					if not scale then
						extraInfo.scale = {
							attachInfo.scale.x,
							attachInfo.scale.y,
							attachInfo.scale.z
						}
					else
						extraInfo.scale = {}
						extraInfo.scale[1] = scale[1] * attachInfo.scale.x
						extraInfo.scale[2] = scale[2] * attachInfo.scale.y
						extraInfo.scale[3] = scale[3] * attachInfo.scale.z
					end
				else
					extraInfo.bone = info.bone
					extraInfo.attachInstanceId = attachInfo.instanceId
					extraInfo.position = effectInfo.offset_P
					extraInfo.rotation = effectInfo.offset_R
					extraInfo.scale = effectInfo.offset_S
				end

				ent:playIntegratedToModelEffect(effectKey, extraInfo)
			end
		end
	end

	return true
end

return ClientEffectUtils
