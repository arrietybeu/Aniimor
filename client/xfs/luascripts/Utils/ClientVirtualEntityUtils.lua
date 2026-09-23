-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ClientVirtualEntityUtils.lua

local AppearanceCustomOne = require("CustomTypes.AppearanceCustomOne")
local ClientConst = require("Const.ClientConst")
local PetData = require("Data.pet_data")
local PetProtoTypeData = require("Data.pet_prototype_data")
local PuppetData = require("Data.puppet_data")
local ClientUtils = require("Utils.ClientUtils")
local Const = require("Common.Const.Const")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ClientSimpleVirtualEntity = require("Entities.ClientSimpleVirtualEntity")
local ClientSimpleVirtualPlayer = require("Entities.ClientSimpleVirtualPlayer")
local ClientSimpleVirtualPet = require("Entities.ClientSimpleVirtualPet")
local ClientSimpleVirtualNpc = require("Entities.ClientSimpleVirtualNpc")
local ClientTempVirtualNpc = require("Entities.ClientTempVirtualNpc")
local ClientPhotoPetVirtualEntity = require("Entities.ClientPhotoPetVirtualEntity")
local logger = LoggerManager.getLogger("ClientVirtualEntityUtils")
local AvatarPresetData = require("Data.avatar_preset_data")
local EModelUtils = require("Entities.Utils.EModelUtils")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local ClientVirtualEntityUtils = {}

local function parsePlayerCurShow(curShow)
	if type(curShow) == "string" then
		if string.isNilOrEmpty(curShow) then
			return nil
		end

		local curShowStr = decompressFromStr(curShow)

		if string.isNilOrEmpty(curShowStr) then
			return nil
		end

		return string.toTable(curShowStr)
	end

	return curShow
end

local function createAppearanceCustomOne(curShow)
	local curShowTable = parsePlayerCurShow(curShow)

	if not curShowTable then
		return nil
	end

	if curShowTable.__ClassType and curShowTable.__ClassType.typeName == "AppearanceCustomOne" then
		return curShowTable
	end

	return AppearanceCustomOne(curShowTable)
end

function ClientVirtualEntityUtils.copySimpleVirtualPlayerFrom(virtualEntData, finishedCallback)
	if not virtualEntData or not virtualEntData.copyEntity or not virtualEntData.copyEntity:hasEModelComponent(Const.COMPONENT_INDEX_MODEL) then
		return
	end

	local entity = ClientSimpleVirtualPlayer.new()

	entity:init(virtualEntData)
	entity:postInit(virtualEntData)
	entity:start()

	local modelView = entity.eModel.modelModelView

	if virtualEntData.position ~= nil and virtualEntData.rotation ~= nil then
		local rot = Quaternion.Euler(virtualEntData.rotation[1], virtualEntData.rotation[2], virtualEntData.rotation[3])

		EModelUtils.setAgentPositionAndRotation(entity, virtualEntData.position, rot)
	end

	if finishedCallback then
		function modelView.luaOnModelRefreshFinshed()
			finishedCallback(entity)
		end
	end

	return entity
end

function ClientVirtualEntityUtils.copySimpleVirtualPlayerAppearance(targetEntity, sourceEntity, syncLoad)
	if not targetEntity or not sourceEntity then
		return
	end

	local modelView = targetEntity.eModel.modelModelView

	modelView.modelInfo:CopyFrom(sourceEntity.eModel.modelModelView.modelInfo)
	require("Utils.AppearanceEffectUtils").copyAppearanceInfo(targetEntity, sourceEntity)

	modelView.modelInfo.physiqueModelInfo.isAlwaysAnimate = true

	require("Utils.ClientModelUtils").refreshModels(targetEntity, modelView)
end

function ClientVirtualEntityUtils.createSimpleVirtualNpc(virtualEntData)
	if not virtualEntData or not virtualEntData.templateId or not PuppetData[virtualEntData.templateId] then
		return
	end

	local entity = ClientSimpleVirtualNpc.new()

	entity:preInit(virtualEntData)
	entity:init(virtualEntData)
	entity:postInit(virtualEntData)
	entity:start()
	entity:refreshAppearance()

	return entity
end

function ClientVirtualEntityUtils.createTempVirtualNpc(virtualEntData)
	local ent
	local ret, err = xpcall(function()
		ent = ClientTempVirtualNpc.new()

		ent:preInit(virtualEntData)
		ent:init(virtualEntData)
		ent:postInit(virtualEntData)
		ent:start()

		if ent.enterSpace ~= nil then
			ent:enterSpace(pg.space)
		end

		ClientUtils.onClientEntityCreated(ent)
		ent:refreshAppearance()
	end, debug.traceback)

	if not ret then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error(err)
		end

		if virtualEntData.finishedCallback ~= nil then
			virtualEntData:finishedCallback(ent)
		end

		if virtualEntData.animatorReadyCallback ~= nil then
			virtualEntData:animatorReadyCallback(ent)
		end
	end

	return ent
end

function ClientVirtualEntityUtils.createVirtualPlayer(avatarConfig, curShow, avatarPresetKey)
	local entity = ClientSimpleVirtualPlayer.new()
	local curShowTable = createAppearanceCustomOne(curShow)
	local dict = {
		templateId = pg.game.avatar:getAvatarPresetData(avatarPresetKey).templateId,
		avatarPresetKey = avatarPresetKey,
		avatarConfig = avatarConfig,
		curShow = curShowTable
	}

	entity:init(dict)
	entity:postInit(dict)
	entity:start()

	return entity
end

function ClientVirtualEntityUtils.refreshPlayerEntityAppearance(entity, avatarConfig, curShow, avatarPresetKey)
	local modelView = entity.eModel.modelModelView

	if avatarConfig then
		local avatarConfigStr = decompressFromStr(avatarConfig)

		modelView.modelInfo:ParseCustomData(avatarConfigStr)

		local partChanged = modelView.modelInfo:ApplyCustomPartAssetIds()

		modelView.modelInfo:ProcessCustomData()

		if partChanged then
			modelView.modelInfo:ParseToModelInfo()
		end
	end

	if curShow then
		entity.curShow = createAppearanceCustomOne(curShow)
	end

	entity.avatarPresetKey = avatarPresetKey

	entity:refreshAppearance()

	local bodySize = modelView.modelInfo:GetBodySize()

	entity:setModelScale(ClientConst.MODEL_SCALE_KEY.AVATAR, bodySize)
end

function ClientVirtualEntityUtils.refreshPetEntityAppearance(entity, petAppearance)
	local appearanceData

	if petAppearance and petAppearance ~= "" then
		local infoStr = decompressFromStr(petAppearance)

		appearanceData = string.toTable(infoStr)
	end

	entity:setTempJewelryInfo(appearanceData or {})
end

function ClientVirtualEntityUtils.createPetVirtualEntity(tId, petAppearance, label, shinyStyle)
	local appearanceData

	if petAppearance and petAppearance ~= "" then
		local infoStr = decompressFromStr(petAppearance)

		appearanceData = string.toTable(infoStr)
	end

	return ClientVirtualEntityUtils.createPetVirtualEntityWithDic(tId, appearanceData, label, shinyStyle)
end

function ClientVirtualEntityUtils.getPetUISceneConfig(templateId)
	local petData = PetData[templateId]

	if petData then
		return petData, true
	end

	return PetProtoTypeData[templateId], false
end

function ClientVirtualEntityUtils.syncPetUISceneAppearanceSource(entity, petInfo)
	if not entity or not petInfo or not petInfo.templateId then
		return
	end

	local configData, isPetData = ClientVirtualEntityUtils.getPetUISceneConfig(petInfo.templateId)

	if not configData then
		return
	end

	entity:setConfigData(configData)

	entity.templateId = petInfo.templateId
	entity.label = petInfo.label
	entity.shinyStyle = petInfo.shinyStyle
	entity.gender = petInfo.gender
	entity.petInfo = isPetData and petInfo or nil

	return configData, isPetData
end

function ClientVirtualEntityUtils.createPetVirtualEntityWithPetId(petId, syncLoad)
	local petInfo = pg.me.pets[petId]

	if petInfo == nil then
		return nil
	end

	local appearanceData = pg.me.petJewelryInfos[petId]
	local entity = ClientVirtualEntityUtils.createPetVirtualEntityWithDic(petInfo.templateId, appearanceData, petInfo.label, petInfo.shinyStyle, petInfo.gender, syncLoad, petInfo, petId)

	PetTransmogUtils.applyAppliedTransmog(entity, petId)

	return entity
end

function ClientVirtualEntityUtils.createPetVirtualEntityWithDic(tId, appearanceData, label, shinyStyle, gender, syncLoad, petInfo, realPetId)
	local cData = PetData[tId]

	if cData == nil then
		return
	end

	local entity = ClientSimpleVirtualPet.new()
	local initInfo = {
		isIgnoreEffectLod = true,
		templateId = tId,
		label = label,
		shinyStyle = shinyStyle,
		gender = gender,
		tempJewelryInfo = appearanceData,
		syncLoad = syncLoad,
		realPetId = realPetId
	}

	if petInfo then
		entity.petInfo = petInfo
	end

	entity:init(initInfo)
	entity:postInit(initInfo)
	entity:start()
	entity:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)
	entity:setRendererLod(0)

	return entity
end

function ClientVirtualEntityUtils.createPetVirtualEntityByPetId(petId, entityCls, initDict)
	local pet = pg.me.pets[petId]

	if not pet then
		return
	end

	local cData = PetData[pet.templateId]

	if cData == nil then
		return
	end

	entityCls = entityCls or ClientSimpleVirtualEntity

	local entity = entityCls.new()

	if initDict then
		initDict.templateId = pet.templateId
		initDict.label = pet.label
		initDict.gender = pet.gender
		initDict.petJewelryInfo = pg.me.petJewelryInfos[petId]

		entity:preInit(initDict)
		entity:init(initDict)
		entity:postInit(initDict)
		entity:start()
		PetTransmogUtils.applyAppliedTransmog(entity, petId)
	else
		local initInfo = {}

		entity:init(initInfo)
		entity:postInit(initInfo)
		entity:start()
	end

	return entity
end

function ClientVirtualEntityUtils.createPhotoPetVirtualEntityWithPetId(petId, syncLoad)
	local petInfo = pg.me.pets[petId]

	if petInfo == nil then
		return nil
	end

	local appearanceData = pg.me.petJewelryInfos[petId]
	local tId = petInfo.templateId
	local cData = PetData[tId]

	if cData == nil then
		return
	end

	local entity = ClientPhotoPetVirtualEntity.new()
	local initInfo = {
		templateId = tId,
		label = petInfo.label,
		gender = petInfo.gender,
		shinyStyle = petInfo.shinyStyle,
		tempJewelryInfo = appearanceData,
		shinyEffectReplace = petInfo.shinyEffectReplace or "",
		realPetId = petId,
		syncLoad = syncLoad
	}

	entity:init(initInfo)
	entity:postInit(initInfo)
	entity:start()
	entity:setLodTickEnable(Const.LOD_TICK_KEY.DEFAULT, false)
	entity:setRendererLod(0)
	PetTransmogUtils.applyAppliedTransmog(entity, petId)

	return entity
end

return ClientVirtualEntityUtils
