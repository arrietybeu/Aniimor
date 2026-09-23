-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Ability\\ClientPresetActionHelper.lua

local Const = require("Common.Const.Const")
local IsNil = IsNil
local ClientPresetActionHelper = {}

function ClientPresetActionHelper.getEModel(entity)
	if not entity or not entity.eModel then
		return nil
	end

	return entity.eModel
end

function ClientPresetActionHelper.playPresetForEntity(entity, actionData)
	local eModel = ClientPresetActionHelper.getEModel(entity)

	if not eModel then
		return false
	end

	if actionData.effectKey then
		eModel:PlayPreset(Const.COMPONENT_INDEX_EFFECT, actionData.effectKey, actionData.presetName, actionData.duration, actionData.disableWhenFinished)

		return true
	end

	local shaderView = eModel.modelShaderView

	if shaderView then
		ClientEffectUtils.PlayPreset(entity, actionData.presetName, actionData.duration, actionData.disableWhenFinished, actionData.loopCount or 0, nil, nil, nil, nil, actionData.renderNameFilter)
	end

	return true
end

function ClientPresetActionHelper.stopPresetForEntity(entity, actionData)
	local eModel = ClientPresetActionHelper.getEModel(entity)

	if not eModel then
		return false
	end

	local shaderView = eModel.modelShaderView

	if shaderView then
		ClientEffectUtils.StopPreset(entity, actionData.presetName)
	end

	return true
end

function ClientPresetActionHelper.syncToCutSceneEntities(targetEntity, actionData, operation)
	if actionData.syncToCutScene ~= true or not targetEntity.modelSwitchSyncEnts then
		return
	end

	for entity, _ in pairs(targetEntity.modelSwitchSyncEnts) do
		operation(entity, actionData)
	end
end

function ClientPresetActionHelper.playPreset(targetEntity, actionData)
	if not ClientPresetActionHelper.playPresetForEntity(targetEntity, actionData) then
		return false
	end

	ClientPresetActionHelper.syncToCutSceneEntities(targetEntity, actionData, ClientPresetActionHelper.playPresetForEntity)

	return true
end

function ClientPresetActionHelper.stopPreset(targetEntity, actionData)
	if not ClientPresetActionHelper.stopPresetForEntity(targetEntity, actionData) then
		return false
	end

	ClientPresetActionHelper.syncToCutSceneEntities(targetEntity, actionData, ClientPresetActionHelper.stopPresetForEntity)

	return true
end

return ClientPresetActionHelper
