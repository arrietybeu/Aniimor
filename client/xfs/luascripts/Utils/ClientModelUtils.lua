-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ClientModelUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local puppetData = require("Data.puppet_data")
local petData = require("Data.pet_data")
local bit = bit
local Const = require("Common.Const.Const")
local PetData = require("Data.pet_data")
local AppearanceData = require("Data.appearance_data")
local AppearanceEffectUtils = require("Utils.AppearanceEffectUtils")
local ColorJewelryData = require("Data.appearance_color_jewelry_data")
local AppearancePointEnum = require("Data.appearance_point_enum")
local AvatarData = require("Data.avatar_data")
local AvatarPresetData = require("Data.avatar_preset_data")
local AppearanceVariableData = require("Data.appearance_variable_data")
local PetIndividuationData = require("Data.pet_individuation_data")
local AccessoryData = require("Data.appearance_jewelry_pet_data")
local AvatarAccessoryClassifyData = require("Data.Avatar.avatar_accessory_classify_data")
local HomeCarModifyTypeData = require("Data.home_car_modify_type_data")
local HomeCarModifyData = require("Data.home_car_modify_data")
local EggPatternColorData = require("Data.egg_pattern_color_data")
local ModelPrefabResId2AvatarName = require("Common.Data.model_prefab_res_id_2_avatar_name")
local AddressDataConst = require("Const.AddressDataConst")
local ClientModelUtils = {}
local DEFAULT_PERIPHERAL_ATTACH_BONE = "Bip001 L Hand"
local PERIPHERAL_POINT_MIN = AppearancePointEnum.FootPrint
local PERIPHERAL_POINT_MAX = AppearancePointEnum.Effect
local MERGED_FORM_ATTACH_BONE = "_BoneRoot"
local MERGED_FORM_PERIPHERAL_CONFIGS = {
	{
		variableKey = "MERGED_FORM_FOOT_DUST",
		defaultVisible = true,
		pointId = AppearancePointEnum.FootPrint
	},
	{
		variableKey = "MERGED_FORM_EFFECT",
		pointId = AppearancePointEnum.Effect
	}
}

function ClientModelUtils.refreshModels(entity, modelView)
	modelView:RefreshModels()

	if entity.refreshAppearanceAttachEffects then
		entity:refreshAppearanceAttachEffects()
	end
end

function ClientModelUtils.applyAppearancePart(entity, slotId, appearanceId, resId)
	local partModelInfo = entity.eModel.modelModelView.modelInfo.partModelInfo

	AppearanceEffectUtils.setAppearance(entity, slotId, appearanceId, resId)

	local currentResId = partModelInfo:GetPartResId(slotId)

	if appearanceId == 0 then
		if not string.isNilOrEmpty(currentResId) then
			partModelInfo:RemovePartItem(currentResId)
		end
	else
		local config = AppearanceData[appearanceId]

		if config and resId ~= currentResId then
			partModelInfo:ModifyPartItem(resId, require("Common.Utils.Utils").deepCopyTable(config.points))
		end
	end
end

function ClientModelUtils.selectAppearanceAccessory(entity, slotId, appearanceId)
	AppearanceEffectUtils.setAppearance(entity, slotId, nil)

	if not appearanceId or appearanceId == 0 then
		return
	end

	local modelInfo = entity.eModel.modelModelView.modelInfo
	local reactionKey = ClientModelUtils.getAccessoryReactionKeyAndKindKey(appearanceId, modelInfo:GetMakeUpPartAssetId())

	pg.global.avatarMgr.avatarMakeup:SelectAttach(reactionKey)

	local attachInfo = modelInfo:GetAttachModelInfo(reactionKey)

	if attachInfo then
		AppearanceEffectUtils.setAppearance(entity, slotId, appearanceId, attachInfo.resId)
	end

	return reactionKey
end

function ClientModelUtils.getAvatarData(avatarID)
	local avatarInfo = AvatarData[avatarID]

	return avatarInfo or {}
end

function ClientModelUtils.applyAvatarAppearance(modelInfo, curAvatarID, extraInfo)
	local data = AvatarData[curAvatarID] or {}

	ClientModelUtils.applyModelAppearance(modelInfo, data, extraInfo)
end

function ClientModelUtils.applyModelSimplePart(modelInfo, partItems)
	for partId, partInfo in pairs(partItems) do
		local newResId = partInfo.resId

		if newResId ~= nil and newResId ~= "" then
			modelInfo.partModelInfo:ModifyPartItem(newResId, {
				partId
			})

			if not partItems.isAvatarWearPart then
				modelInfo.partModelInfo.res2Items[partInfo.resId].isAvatarWearPart = false
			end
		end
	end
end

function ClientModelUtils.applyModelPart(modelInfo, partItems)
	for partId, partInfo in pairs(partItems) do
		local isHair = partId >= AppearancePointEnum.Fringe and partId <= AppearancePointEnum.Plait

		if not isHair then
			local newResId = partInfo.resId

			if newResId ~= nil and newResId ~= "" then
				modelInfo.partModelInfo:ModifyPartItem(newResId, {
					partId
				})

				if partInfo.isAvatarWearPart == false then
					for resId, item in pairs(modelInfo.partModelInfo.res2Items) do
						if resId == newResId then
							item.isAvatarWearPart = false

							break
						end
					end
				end
			end
		end
	end

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local curResId = modelInfo.partModelInfo:GetPartResId(partId)

		if partItems[partId] then
			local newResId = partItems[partId].resId

			if newResId ~= nil and newResId ~= "" then
				modelInfo.partModelInfo:ModifyPartItem(newResId, {
					partId
				})
			end
		elseif curResId ~= nil and curResId ~= "" then
			modelInfo.partModelInfo:RemovePartItem(curResId)
		end
	end
end

function ClientModelUtils.applyModelAppearance(modelInfo, data, extraInfo)
	data = data or {}

	modelInfo:ClearInfo()

	modelInfo.physiqueModelInfo.modelInfoPathID = data.modelInfoRef or ""
	modelInfo.physiqueModelInfo.animControllerAssetID = ClientModelUtils.getAnimController(data)

	local partItems

	if IsNil(extraInfo) then
		modelInfo.height = data.topbarHeight or data.modelHeight or 1.5
		modelInfo.physiqueModelInfo.modelPathID = data.prefabResID or data.modelResId or ""
		modelInfo.physiqueModelInfo.modelScale = data.modelScale or 1
		modelInfo.physiqueModelInfo.modelNeedBones = false
		partItems = data.partItems
	else
		modelInfo.height = extraInfo.topbarHeight or data.topbarHeight or data.modelHeight or 1.5
		modelInfo.physiqueModelInfo.modelPathID = extraInfo.prefabResID or data.prefabResID or data.modelResId or ""
		modelInfo.physiqueModelInfo.modelScale = extraInfo.modelScale or data.modelScale or 1
		modelInfo.physiqueModelInfo.modelNeedBones = extraInfo.modelNeedBones or false
		partItems = extraInfo.partItems or data.partItems
	end

	if partItems ~= nil then
		ClientModelUtils.applyModelPart(modelInfo, partItems)
	end
end

function ClientModelUtils.applyBaseModelAppearance(modelInfo, extraInfo)
	modelInfo:ClearInfo()

	if extraInfo == nil then
		return
	end

	modelInfo.height = extraInfo.topbarHeight or 1
	modelInfo.physiqueModelInfo.modelPathID = extraInfo.prefabResID or ""
	modelInfo.physiqueModelInfo.modelScale = extraInfo.modelScale or 1
	modelInfo.physiqueModelInfo.modelNeedBones = extraInfo.needBones or false
end

function ClientModelUtils.applyModelSwitchTag(ent)
	local configData = ent:getConfigData()
	local defaultSwitchTag = configData.defaultSwitchTag

	if not ToBool(ent.modelSwitchTag) and defaultSwitchTag then
		ent:setModelSwitchTag(defaultSwitchTag[1], defaultSwitchTag[2])
	elseif configData.useGenderModel then
		ent:setModelSwitchTag(0, ent.gender == 1 and "Male" or "Female")

		if ent._petMatForceUnKnow then
			return
		end

		local matEffKey = ent.gender == 1 and configData.maleMatEffKey or configData.femaleMatEffKey

		if matEffKey then
			ClientEffectUtils.ApplyMaterialEffectByFilterName(ent, matEffKey, "Body")
		end
	end
end

function ClientModelUtils.applyHomeCarAppearance(modelView, basicInfo, needUpgradeEffect)
	local HomeLandUtils = require("Common.Utils.HomeLandUtils")
	local modelInfo = modelView.modelInfo
	local modelLevel = HomeLandUtils.getHomeCarModelLevel(basicInfo.level)
	local carCompsLevel = basicInfo.carCompsLevel
	local rawShape = basicInfo.carShapeInfo
	local shapeInfo = {}

	for tabId, subTabId in pairs(rawShape) do
		shapeInfo[tabId] = subTabId
	end

	for _, partId in pairs(Const.HOME_CAR_BASE_PART) do
		if not shapeInfo[partId] then
			shapeInfo[partId] = 1
		end
	end

	local colorSubTabId = shapeInfo[Const.HOME_CAR_BASE_PART.Color]
	local colorModifyInfo = HomeCarModifyData[Const.HOME_CAR_BASE_PART.Color][colorSubTabId] or {}
	local homeCarResInfo = HomeLandUtils.getHomeCarResInfo(colorModifyInfo.partValue, modelLevel)

	if not homeCarResInfo then
		return
	end

	modelInfo.physiqueModelInfo.modelInfoPathID = ""
	modelInfo.physiqueModelInfo.modelPathID = homeCarResInfo.res

	modelView:InitAttachModel()
	modelInfo:RemoveAllAttach()

	for tabId, subTabId in pairs(shapeInfo) do
		if tabId ~= Const.HOME_CAR_BASE_PART.Color then
			local modifyInfo = HomeCarModifyData[tabId][subTabId] or {}
			local attachResInfo = HomeLandUtils.getHomeCarResInfo(modifyInfo.partValue)

			if attachResInfo then
				modelInfo:AddAttachInfo(attachResInfo.res, "HomeCar_" .. modifyInfo.partValue, attachResInfo.attach, Vector3.zero, Vector3.zero, Vector3.one)
			end
		end
	end

	local needEffect = true

	if basicInfo.isUIScene then
		if basicInfo.needShadow then
			-- block empty
		else
			needEffect = false
		end
	else
		for tabId, level in pairs(carCompsLevel) do
			local componentInfo = HomeLandUtils.getHomeCarComponentInfo(tabId, level)

			if componentInfo then
				modelInfo:AddAttachInfo(componentInfo.carModuleResId, "HomeCarDecoration_" .. tabId .. "_" .. level, componentInfo.attachId, Vector3.zero, Vector3.zero, Vector3.one)
			end
		end
	end

	if needEffect then
		modelInfo:AddAttachInfo(AddressDataConst.HOME_CAR_DOOR_EFFECT, "HomeCarDoorEffect", "HomeCarDoorEffect", Vector3.zero, Vector3.zero, Vector3.one)
	end

	if needUpgradeEffect and (basicInfo.upgradeEndTs or 0) > 0 then
		modelInfo:AddAttachInfo(AddressDataConst.HOME_CAR_UPGRADE_EFFECT, "HomeCarLevelEffect", "HomeCarLevelEffect", Vector3.zero, Vector3.zero, Vector3.one)
	end
end

function ClientModelUtils.applyHomeCarDecorationAppearance(modelView, basicInfo)
	local HomeLandUtils = require("Common.Utils.HomeLandUtils")
	local decorationResId = HomeLandUtils.getHomeCarDecorationRes(basicInfo.level, basicInfo.floor)

	if not decorationResId then
		return
	end

	local modelInfo = modelView.modelInfo
	local modelLevel = HomeLandUtils.getHomeCarModelLevel(basicInfo.level)
	local carCompsLevel = basicInfo.carCompsLevel

	modelInfo.physiqueModelInfo.modelInfoPathID = ""
	modelInfo.physiqueModelInfo.modelPathID = decorationResId

	modelView:InitAttachModel()
	modelInfo:RemoveAllAttach()

	for tabId, level in pairs(carCompsLevel) do
		local componentInfo = HomeLandUtils.getHomeCarComponentInfo(tabId, level)

		if componentInfo.floor == basicInfo.floor then
			modelInfo:AddAttachInfo(componentInfo.carModuleResId, tostring("HomeCarDecoration_" .. tabId .. "_" .. level), componentInfo.attachId, Vector3.zero, Vector3.zero, Vector3.one)
		end
	end
end

function ClientModelUtils.addGhostTint(entity, modelInfo)
	if entity.isGhost then
		local player = pg.me
	end
end

function ClientModelUtils.applyPuppetAppearance(modelInfo, puppetId, extraInfo)
	local data = puppetData[puppetId] or {}

	if extraInfo == nil then
		extraInfo = ClientModelUtils.getModelExtraInfo(data, 0, 1)
	end

	ClientModelUtils.applyModelAppearance(modelInfo, data, extraInfo)
end

function ClientModelUtils.createTargetOnSlot(slotKey, virtualEnt)
	return
end

function ClientModelUtils.applyPetAppearance(modelInfo, petId, extraInfo)
	modelInfo:ClearInfo()

	local petInfo = petData[petId] or {}

	ClientModelUtils.applyModelAppearance(modelInfo, petInfo, extraInfo)
end

function ClientModelUtils.applyRobEggAppearance(modelInfo, modelPathID, modelScale)
	modelInfo:ClearInfo()

	modelInfo.height = 1.65
	modelInfo.physiqueModelInfo.modelPathID = modelPathID
	modelInfo.physiqueModelInfo.modelScale = modelScale or 1
end

function ClientModelUtils.applyEggModelMaterialEffect(entity, modelView, cfgData, patternColorType)
	if not entity or not modelView or not cfgData then
		return
	end

	local patternColorData = EggPatternColorData[patternColorType]
	local shellKey = patternColorData and patternColorData.shellKey

	if cfgData.bodyKey then
		ClientEffectUtils.ApplyMaterialEffectByFilterNameToShaderView(entity, modelView.shaderView, cfgData.bodyKey, "Body")
	end

	if shellKey then
		ClientEffectUtils.ApplyMaterialEffectByFilterNameToShaderView(entity, modelView.shaderView, shellKey, "Shell")
	end
end

function ClientModelUtils.getModelPrefabResId(data, label, gender, extraFix)
	local modelPostFix = ""

	if extraFix then
		modelPostFix = modelPostFix .. extraFix
	else
		if data.useShinyModel == 1 and not data.shinyStyleColorId and bit.band(label, Const.PET_LABEL_MASK.SHINY) ~= 0 then
			modelPostFix = modelPostFix .. "_Shiny"
		end

		if data.useDemonicModel and bit.band(label, Const.PET_LABEL_MASK.MAGIC) ~= 0 then
			modelPostFix = modelPostFix .. "_Demonic"
		end
	end

	local prefabResID = data.prefabResID
	local offset = 7

	if modelPostFix and string.len(modelPostFix) > 0 then
		local ext = string.sub(prefabResID, #prefabResID - offset + 1)

		if ext == ".prefab" then
			prefabResID = string.sub(prefabResID, 1, #prefabResID - offset) .. modelPostFix .. ext
		end

		return prefabResID
	end

	return prefabResID
end

function ClientModelUtils.getModelAvatarName(prefabResID)
	if not prefabResID then
		return nil
	end

	return ModelPrefabResId2AvatarName[prefabResID]
end

function ClientModelUtils.getEnvObjectAttachEffects(data)
	local attachEffects = {}

	for _, eff in ipairs(data.effs or EMPTY_TABLE) do
		attachEffects[#attachEffects + 1] = {
			effectKey = eff
		}
	end

	return attachEffects
end

function ClientModelUtils.getModelExtraInfo(data, label, gender, canAttachEffs, extraFix, petInfo)
	local extraData = {}
	local attachEffects = {}
	local isShiny = bit.band(label, Const.PET_LABEL_MASK.SHINY) ~= 0

	if isShiny and data.effectResIDShiny then
		local attachEffectInfo = {}

		attachEffectInfo.effectKey = data.effectResIDShiny
		attachEffectInfo.scale = data.effectScaleShiny
		attachEffectInfo.position = data.effectOffsetShiny
		attachEffects[#attachEffects + 1] = attachEffectInfo

		if petInfo and not string.isNilOrEmpty(petInfo.shinyEffectReplace) then
			local effectKeyParts = string.split(attachEffectInfo.effectKey, "_")
			local replaceRes = tostring(petInfo.shinyEffectReplace)

			if (#effectKeyParts == 3 or #effectKeyParts == 4) and replaceRes ~= "" then
				effectKeyParts[3] = replaceRes

				local newEffectKey = table.concat(effectKeyParts, "_")
				local newResId = "$" .. newEffectKey .. ".prefab"

				if pg and pg.global and pg.global.resMgr and pg.global.resMgr:CheckAssetExist(newResId) then
					attachEffectInfo.effectKey = newEffectKey
				end
			end
		end
	end

	if bit.band(label, Const.PET_LABEL_MASK.BOSS) ~= 0 and data.effectResIDBoss then
		local attachEffectInfo = {}

		attachEffectInfo.effectKey = data.effectResIDBoss
		attachEffectInfo.scale = data.effectScaleBoss
		attachEffectInfo.position = data.effectOffsetBoss
		attachEffects[#attachEffects + 1] = attachEffectInfo
	end

	if bit.band(label, Const.PET_LABEL_MASK.ELITE) ~= 0 and data.effectResIDElite then
		local attachEffectInfo = {}

		attachEffectInfo.effectKey = data.effectResIDElite
		attachEffectInfo.scale = data.effectScaleElite
		attachEffectInfo.position = data.effectOffsetElite
		attachEffects[#attachEffects + 1] = attachEffectInfo
	end

	if not isShiny and bit.band(label, Const.PET_LABEL_MASK.DARK) ~= 0 and data.effectResIDDemonic then
		local attachEffectInfo = {}

		attachEffectInfo.effectKey = data.effectResIDDemonic
		attachEffectInfo.scale = data.effectScaleDemonic
		attachEffectInfo.position = data.effectOffsetDemonic
		attachEffects[#attachEffects + 1] = attachEffectInfo
	end

	extraData.prefabResID = ClientModelUtils.getModelPrefabResId(data, label, gender, extraFix)

	if canAttachEffs ~= false then
		for _, eff in ipairs(data.effs or EMPTY_TABLE) do
			attachEffects[#attachEffects + 1] = {
				effectKey = eff
			}
		end
	end

	extraData.attachEffects = attachEffects

	return extraData
end

function ClientModelUtils.initHairModelInfo(entity, overrideCurShow)
	if not entity.eModel then
		return
	end

	local modelView = entity.eModel.modelModelView
	local hairParts = ClientModelUtils.getModelHairParts(entity, overrideCurShow)

	for slotId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local part = hairParts[slotId]

		AppearanceEffectUtils.setAppearance(entity, slotId, part and part.hairPartId)
	end

	ClientModelUtils.applyModelPart(modelView.modelInfo, hairParts)

	local hairCustomDatas = ClientModelUtils.getModelHairCustomDatas(overrideCurShow or entity.curShow)

	for partId, hairCustomData in pairs(hairCustomDatas) do
		modelView.modelInfo:ParseHairCustomData(partId, hairCustomData)
		modelView.modelInfo:ProcessHairCustomData(partId)
	end
end

function ClientModelUtils.initClothesModelInfo(entity, overrideCurShow)
	if not entity.eModel then
		return
	end

	local Utils = require("Common.Utils.Utils")
	local modelView = entity.eModel.modelModelView
	local clothesParts = ClientModelUtils.getModelClothesParts(entity, overrideCurShow)

	AppearanceEffectUtils.replaceRange(entity, AppearancePointEnum.Coat, AppearancePointEnum.Shoes)

	for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		local clothesId = clothesParts[partId]

		if clothesId then
			local clothesData = AppearanceData[clothesId] or {}

			AppearanceEffectUtils.setAppearance(entity, partId, clothesId, clothesData.res)
			modelView.modelInfo.partModelInfo:ModifyPartItem(clothesData.res, Utils.deepCopyTable(clothesData.points))
		else
			local curResId = modelView.modelInfo.partModelInfo:GetPartResId(partId)

			modelView.modelInfo.partModelInfo:RemovePartItem(curResId)
		end
	end
end

function ClientModelUtils.initAttachModelInfo(entity)
	if not entity.eModel then
		return
	end

	local modelView = entity.eModel.modelModelView

	modelView.modelInfo:RemoveAllAttach()

	local attachInfoList, effectInfo = ClientModelUtils.getModelAttachInfoList(entity)

	AppearanceEffectUtils.replaceRange(entity, AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10, effectInfo)
	ClientModelUtils.addModelAttachList(modelView.modelInfo, attachInfoList)
end

function ClientModelUtils.refreshAvatarMakeup(entity)
	if not entity or not entity.eModel then
		return
	end

	local customData

	if entity.copyEntity and pg.global.avatarMgr then
		local ok, customDataStr = pcall(pg.global.avatarMgr.GetCustomDataString, pg.global.avatarMgr)

		if ok and not string.isNilOrEmpty(customDataStr) then
			customData = customDataStr
		end
	end

	if not customData then
		if not entity.avatarConfig or entity.avatarConfig == "" then
			return
		end

		customData = decompressFromStr(entity.avatarConfig)
	end

	local modelView = entity.eModel.modelModelView

	if IsNil(modelView) or IsNil(modelView.modelInfo) then
		return
	end

	if IsNil(modelView.shaderView) then
		return
	end

	modelView.modelInfo:ParseCustomData(customData)
	modelView.modelInfo:ProcessCustomData()

	if entity.copyEntity then
		modelView:RefreshDecal()
	end

	modelView:RefreshMakeup()
end

function ClientModelUtils.setupDefaultHairRes(modelInfo, presetKey)
	local presetData = pg.game.avatar:getAvatarPresetData(presetKey)

	if presetData and presetData.body then
		modelInfo.defaultHairResId = AppearanceVariableData["FACE_HAIR_DEFAULT_" .. presetData.body] or ""
	end
end

function ClientModelUtils.initModelInfoByConfig(entity, presetKey)
	if not entity or not entity.eModel then
		return
	end

	local modelView = entity.eModel.modelModelView
	local configData = entity:getConfigData()

	modelView.modelInfo:ParseAvatarRuntimeData(presetKey)

	if entity.avatarConfig then
		modelView.modelInfo:ParseCustomData(decompressFromStr(entity.avatarConfig))
		modelView.modelInfo:ApplyCustomPartAssetIds()
	end

	modelView.modelInfo:ParseToModelInfo()

	modelView.modelInfo.physiqueModelInfo.modelInfoPathID = configData.modelInfoRef or ""
	modelView.modelInfo.physiqueModelInfo.animControllerAssetID = ClientModelUtils.getAnimController(configData)

	ClientModelUtils.setupDefaultHairRes(modelView.modelInfo, presetKey)

	if entity.avatarConfig then
		modelView.modelInfo:ProcessCustomData()
	end
end

function ClientModelUtils.initModelInfoByCustomData(entity, presetKey, configData, extraData)
	if not entity or not entity.eModel then
		return
	end

	entity.appearanceEffectInfo = {}

	local configDataModelScale = configData and configData.modelScale and configData.modelScale or 1
	local modelScale = extraData and extraData.modelScale or configDataModelScale

	entity.eModel.modelModelView.modelInfo.physiqueModelInfo.modelScale = modelScale

	ClientModelUtils.initModelInfoByConfig(entity, presetKey)
	ClientModelUtils.initHairModelInfo(entity)
	ClientModelUtils.initClothesModelInfo(entity)
	ClientModelUtils.initAttachModelInfo(entity)
end

function ClientModelUtils.getModelHairParts(entity, overrideCurShow, overrideCustomShow)
	if not entity then
		return {}
	end

	local res = {}
	local curShow = overrideCurShow or entity.curShow

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		if curShow then
			local hairPartId = overrideCustomShow and overrideCustomShow[partId] or curShow.customShow[partId]

			if hairPartId and hairPartId ~= 0 then
				local hairPartData = AppearanceData[hairPartId] or {}

				res[partId] = {
					resId = hairPartData.res,
					hairPartId = hairPartId
				}
			end
		end
	end

	return res
end

function ClientModelUtils.getModelHairCustomDatas(curShow)
	if not curShow then
		return {}
	end

	local res = {}

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local hairCustomData = curShow.hairInfo[partId]

		if hairCustomData and hairCustomData ~= "" then
			res[partId] = decompressFromStr(hairCustomData)
		else
			res[partId] = ""
		end
	end

	return res
end

function ClientModelUtils.getModelHairCustomData(curShow, partId)
	local hairCustomData = curShow.hairInfo and curShow.hairInfo[partId]

	if hairCustomData and hairCustomData ~= "" then
		return decompressFromStr(hairCustomData)
	else
		return ""
	end
end

function ClientModelUtils.applyHairCustomData(entity, curShow, partId)
	if not entity.eModel or IsNil(curShow) then
		return
	end

	local modelView = entity.eModel.modelModelView
	local modelInfo = modelView.modelInfo
	local hairCustomData = ClientModelUtils.getModelHairCustomData(curShow, partId)

	modelInfo:ParseHairCustomData(partId, hairCustomData)
	modelInfo:ProcessHairCustomData(partId)

	if modelView.partModel:IsPartModelLoaded(partId) then
		modelView:ApplyHairCustomData(partId)
	end
end

function ClientModelUtils.getModelClothesParts(entity, overrideCurShow)
	if not entity then
		return {}
	end

	local res = {}
	local curShow = overrideCurShow or entity.curShow

	for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		if curShow then
			local clothesId = curShow.customShow[partId]

			if clothesId ~= 0 then
				res[partId] = clothesId
			end
		end
	end

	return res
end

function ClientModelUtils.getClothStainDataList(curShow)
	local res = {}

	for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		if curShow and curShow.clothesDesigns then
			local unit = curShow.clothesDesigns[partId]

			if unit then
				res[partId] = ClientModelUtils.parseStainMatInfo(unit:getRawTable())
			end
		end
	end

	return res
end

function ClientModelUtils.parseStainMatInfo(unit)
	local res = {
		stainList = {},
		decalList = {}
	}

	if not string.isNilOrEmpty(unit.stainMatMap) then
		local stainMap = string.toTable(decompressFromStr(unit.stainMatMap))

		for k, v in pairs(stainMap) do
			if type(v) == "table" and v.secondUVDyeInfo == nil and v.secondUVDyeParts ~= nil then
				v.secondUVDyeInfo = {
					dyeEnable = true,
					enabled = true,
					dyePartCount = table.maxn(v.secondUVDyeParts),
					dyeParts = v.secondUVDyeParts
				}
			elseif type(v) == "table" and v.secondUVDyeInfo ~= nil and v.secondUVDyeParts ~= nil and v.secondUVDyeInfo.dyeParts == nil then
				v.secondUVDyeInfo.enabled = v.secondUVDyeInfo.enabled ~= false
				v.secondUVDyeInfo.dyeEnable = v.secondUVDyeInfo.dyeEnable ~= false
				v.secondUVDyeInfo.dyePartCount = v.secondUVDyeInfo.dyePartCount or table.maxn(v.secondUVDyeParts)
				v.secondUVDyeInfo.dyeParts = v.secondUVDyeParts
			end

			if type(v) == "table" and v.simpleDyeInfo == nil and v.simpleDyeColor ~= nil then
				v.simpleDyeInfo = {
					enabled = true,
					desaturateEnable = v.simpleDyeDesaturate or 0,
					dyeColor = v.simpleDyeColor,
					dyeBrightness = v.simpleDyeBrightness or 1
				}
			end

			local mat = {
				matName = k
			}

			table.merge(mat, v)

			res.stainList[#res.stainList + 1] = mat

			local max = table.maxn(mat.matAreas)

			for i = 1, max do
				if mat.matAreas[i] == nil then
					mat.matAreas[i] = {}
				end
			end
		end
	end

	if not string.isNilOrEmpty(unit.decalMatMap) then
		local decalMap = string.toTable(decompressFromStr(unit.decalMatMap))

		for k, v in pairs(decalMap) do
			local mat = {
				matName = k
			}

			table.merge(mat, v)

			res.decalList[#res.decalList + 1] = mat

			local max = table.maxn(mat.matDecals)

			for i = 1, max do
				if mat.matDecals[i] == nil then
					mat.matDecals[i] = {}
				end
			end
		end
	end

	return res
end

function ClientModelUtils.applyClothesStainInfo(entity, curShow)
	for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		if curShow and curShow.clothesDesigns then
			local unit = curShow.clothesDesigns[partId]

			if unit then
				ClientModelUtils.applyClothStainInfo(entity, partId, unit)
			end
		end
	end
end

function ClientModelUtils.applyClothStainInfo(entity, part, unit)
	local shaderView = entity.eModel.modelShaderView
	local rawTable = unit:getRawTable()

	if rawTable.isChange == false then
		shaderView:ApplyPreset(part, "Default1")

		return
	end

	local unitData = ClientModelUtils.parseStainMatInfo(rawTable)

	shaderView:ApplyServerMatInfo(part, unitData)
end

function ClientModelUtils.applyOutfitClothesStain(entity, outfitId)
	if not entity or not entity.eModel then
		return
	end

	local clothesDesigns, outfitCustom

	if outfitId then
		outfitCustom = pg.me.appearanceCustom[outfitId]
		clothesDesigns = outfitCustom and outfitCustom.clothesDesigns
	else
		clothesDesigns = entity.curShow and entity.curShow.clothesDesigns
	end

	if not clothesDesigns then
		return
	end

	local partModel = entity.eModel.modelModelView.partModel
	local appliedStainSlots = {}

	for slotId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		local clothesId

		if outfitId then
			clothesId = outfitCustom and outfitCustom.customShow[slotId]
		elseif entity.getAppearanceConfigId then
			clothesId = entity:getAppearanceConfigId(slotId)
		else
			clothesId = entity.curShow.customShow[slotId]
		end

		if not clothesId or clothesId == 0 then
			-- block empty
		else
			local clothesData = AppearanceData[clothesId] or {}
			local stainSlotId = slotId

			if clothesData.points and #clothesData.points > 0 then
				stainSlotId = clothesData.points[1]
			end

			if appliedStainSlots[stainSlotId] then
				-- block empty
			else
				appliedStainSlots[stainSlotId] = true

				if not partModel:IsPartModelLoaded(stainSlotId) then
					-- block empty
				else
					local design = clothesDesigns[stainSlotId] or clothesDesigns[slotId]

					if design then
						ClientModelUtils.applyClothStainInfo(entity, stainSlotId, design)
					end
				end
			end
		end
	end
end

function ClientModelUtils.getPartRendererVisibilityList(entity)
	local res = {}

	if entity and entity.curShow then
		local GameConst = CS.FunPlus.WorldX.Const.GameConst
		local isShowBag = entity.curShow.isShowBag

		table.insert(res, {
			partId = GameConst.PART_TOP,
			slotId = GameConst.SLOT_BAG,
			visible = isShowBag
		})
	end

	return res
end

function ClientModelUtils.applyPartRendererVisibility(entity, actions)
	if not entity then
		return
	end

	for _, action in ipairs(actions) do
		entity.eModel.modelModelView.partModel:SetSubRendererVisibility(action.partId, action.slotId, action.visible)
	end
end

function ClientModelUtils.getPeripheralAttachInfo(entity, configId)
	local config = configId and AppearanceData[configId]

	if not config or config.type ~= 5 or not config.res or config.res == "" then
		return nil
	end

	local peripheralPointId

	for _, pointId in ipairs(config.points) do
		if pointId and pointId >= PERIPHERAL_POINT_MIN and pointId <= PERIPHERAL_POINT_MAX then
			peripheralPointId = pointId

			break
		end
	end

	if not peripheralPointId then
		return nil
	end

	if peripheralPointId == AppearancePointEnum.HandHeld then
		return nil
	end

	local attachBone = config.socket

	if not attachBone or attachBone == "" then
		attachBone = DEFAULT_PERIPHERAL_ATTACH_BONE
	end

	return {
		forceXRendererVisible = true,
		accessoryId = configId,
		resId = config.res,
		instanceId = string.format("__appearance_peripheral_%d__:%s", peripheralPointId, config.res),
		attachHp = attachBone,
		position = Vector3.zero,
		euler = Vector3.zero,
		scale = Vector3.one
	}
end

function ClientModelUtils.getModelAttachInfoList(entity, outfitId)
	if not entity or not entity.curShow then
		return {}
	end

	local attachInfo = {}
	local effectInfo = {}
	local outfitCustom = outfitId and entity.appearanceCustom and entity.appearanceCustom[outfitId]

	for slotId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		local accessoryId

		if outfitId then
			if outfitCustom then
				accessoryId = outfitCustom.customShow[slotId]
			end
		else
			accessoryId = entity.curShow.customShow[slotId]

			if entity.getAppearanceConfigId then
				accessoryId = entity:getAppearanceConfigId(slotId)
			end
		end

		if accessoryId and accessoryId ~= 0 then
			local outfitJewelryInfo = outfitCustom and outfitCustom[slotId]
			local info = ClientModelUtils.getModelAttachInfo(entity, accessoryId, slotId, outfitJewelryInfo)

			table.insert(attachInfo, info)

			effectInfo[slotId] = AppearanceEffectUtils.createAppearanceInfo(accessoryId, info.resId)
		end
	end

	local addedPeripheralIds = {}

	for pointId = PERIPHERAL_POINT_MIN, PERIPHERAL_POINT_MAX do
		local peripheralId

		if outfitId and entity.appearanceCustom and entity.appearanceCustom[outfitId] then
			peripheralId = entity.appearanceCustom[outfitId].customShow[pointId]
		elseif entity.getAppearanceConfigId then
			peripheralId = entity:getAppearanceConfigId(pointId, true, true)
		else
			peripheralId = entity.curShow.customShow[pointId]
		end

		if peripheralId and peripheralId ~= 0 and not addedPeripheralIds[peripheralId] then
			local peripheralInfo = ClientModelUtils.getPeripheralAttachInfo(entity, peripheralId)

			if peripheralInfo then
				addedPeripheralIds[peripheralId] = true

				table.insert(attachInfo, peripheralInfo)
			end
		end
	end

	return attachInfo, effectInfo
end

function ClientModelUtils.getColorJewelryId(curShow, configId)
	local colorJewelryId = 0

	if curShow and curShow[configId] then
		colorJewelryId = curShow[configId].colorJewelryId
	end

	return colorJewelryId
end

function ClientModelUtils.getModelResId(configId, colorAccessoryId)
	return colorAccessoryId and colorAccessoryId ~= 0 and ColorJewelryData[colorAccessoryId].res or AppearanceData[configId].res
end

function ClientModelUtils.getAccessoryReactionKeyAndKindKey(accessoryId, partAssetId)
	if not accessoryId or accessoryId == 0 then
		return
	end

	local avatarEachAccessoryClassifyData = require(string.format("Data.Avatar.avatar_%s_accessory_classify_data", partAssetId))
	local data = AppearanceData[accessoryId] or {}
	local resId = data.res

	if resId then
		local classifyData = avatarEachAccessoryClassifyData[resId]

		if classifyData then
			return classifyData.id, classifyData.kind
		end
	end
end

function ClientModelUtils.getModelAttachInfo(entity, accessoryId, slotId, jewelryInfoOverride)
	local AppearanceJewelryInfo = require("CustomTypes.AppearanceJewelryInfo")
	local attachInfo = {
		accessoryId = accessoryId
	}

	if jewelryInfoOverride and (jewelryInfoOverride.configId == 0 or jewelryInfoOverride.configId == accessoryId) then
		local colorJewelryId = jewelryInfoOverride.colorJewelryId or 0

		attachInfo.resId = ClientModelUtils.getModelResId(accessoryId, colorJewelryId)
		attachInfo.attachHp = jewelryInfoOverride.attachBone
		attachInfo.position = Vector3(jewelryInfoOverride.posX, jewelryInfoOverride.posY, jewelryInfoOverride.posZ)
		attachInfo.euler = Vector3(jewelryInfoOverride.rotX, jewelryInfoOverride.rotY, jewelryInfoOverride.rotZ)
		attachInfo.scale = Vector3.one * jewelryInfoOverride.scale
		attachInfo.colorJewelryId = colorJewelryId

		return attachInfo
	end

	local jewelryLastInfos = entity.jewelryLastInfos or {}
	local lastInfoStr = jewelryLastInfos[accessoryId]

	if not string.isNilOrEmpty(lastInfoStr) then
		local jewelryInfo = AppearanceJewelryInfo.new()

		jewelryInfo:toTable(accessoryId, lastInfoStr)

		attachInfo.resId = ClientModelUtils.getModelResId(accessoryId, jewelryInfo.colorJewelryId)
		attachInfo.attachHp = jewelryInfo.attachBone
		attachInfo.position = Vector3(jewelryInfo.posX, jewelryInfo.posY, jewelryInfo.posZ)
		attachInfo.euler = Vector3(jewelryInfo.rotX, jewelryInfo.rotY, jewelryInfo.rotZ)
		attachInfo.scale = Vector3.one * jewelryInfo.scale
		attachInfo.colorJewelryId = jewelryInfo.colorJewelryId

		return attachInfo
	end

	local slotInfo = slotId and entity.curShow and entity.curShow[slotId]

	if slotInfo and (slotInfo.configId == 0 or slotInfo.configId == accessoryId) then
		local colorJewelryId = slotInfo.colorJewelryId or 0

		attachInfo.resId = ClientModelUtils.getModelResId(accessoryId, colorJewelryId)
		attachInfo.attachHp = slotInfo.attachBone
		attachInfo.position = Vector3(slotInfo.posX, slotInfo.posY, slotInfo.posZ)
		attachInfo.euler = Vector3(slotInfo.rotX, slotInfo.rotY, slotInfo.rotZ)
		attachInfo.scale = Vector3.one * slotInfo.scale
		attachInfo.colorJewelryId = colorJewelryId
	end

	return attachInfo
end

function ClientModelUtils.addModelAttachList(modelInfo, attachInfoList)
	if not attachInfoList then
		return
	end

	for _, attachInfo in ipairs(attachInfoList) do
		ClientModelUtils.addModelAttach(modelInfo, attachInfo)
	end
end

function ClientModelUtils.addModelAttach(modelInfo, attachInfo)
	if attachInfo.resId then
		if attachInfo.instanceId then
			modelInfo:AddAttachInfo(attachInfo.resId, attachInfo.instanceId, attachInfo.attachHp, attachInfo.position, attachInfo.euler, attachInfo.scale, false)
		else
			modelInfo:AddSingletonAttachInfo(attachInfo.resId, attachInfo.attachHp, attachInfo.position, attachInfo.euler, attachInfo.scale)
		end

		if attachInfo.forceXRendererVisible then
			for instanceId, modelAttachInfo in pairs(modelInfo.attachModelInfos) do
				if instanceId == (attachInfo.instanceId or attachInfo.resId) then
					modelAttachInfo.forceXRendererVisible = true

					break
				end
			end
		end
	else
		local reactionKey = ClientModelUtils.getAccessoryReactionKeyAndKindKey(attachInfo.accessoryId, modelInfo:GetMakeUpPartAssetId())

		modelInfo:AddDefaultSingletonAttachInfo(reactionKey)
	end
end

function ClientModelUtils.addMergedFormPeripheralAttachments(entity, modelInfo)
	if not entity.checkPetInControl or not entity:checkPetInControl() then
		return
	end

	local master = entity:getMasterEntity()

	if not master then
		return
	end

	if master.isInLinkAnim then
		return
	end

	for _, peripheralConfig in ipairs(MERGED_FORM_PERIPHERAL_CONFIGS) do
		local variableKey = peripheralConfig.variableKey
		local pointId = peripheralConfig.pointId
		local variableValue = AppearanceVariableData[variableKey]

		if variableValue == 1 or variableValue == nil and peripheralConfig.defaultVisible then
			local appearanceId = master.curShow.customShow[pointId]
			local attachInfo = ClientModelUtils.getPeripheralAttachInfo(master, appearanceId)

			if attachInfo then
				attachInfo.attachHp = MERGED_FORM_ATTACH_BONE

				ClientModelUtils.addModelAttach(modelInfo, attachInfo)
			end
		end
	end
end

function ClientModelUtils.removeModelAttach(modelInfo, resId)
	if not resId then
		return
	end

	modelInfo:RemoveAttachInfo(resId)
end

function ClientModelUtils.addPetAttachInfo(modelInfo, resId, instanceId, attachHp, localPosition, localRotation, scale)
	modelInfo:AddAttachInfo(resId, instanceId, attachHp, localPosition, localRotation, scale, false)
end

function ClientModelUtils.showPetAccesses(ent)
	if not ent.petJewelryInfo or not ent.petJewelryInfo.customPet then
		return
	end

	local PetJewelryOssCache = require("Utils.PetJewelryOssCache")
	local realPetId = ent.id

	for slot, accessoryId in ent.petJewelryInfo.customPet:items() do
		local slotInfo = ent.petJewelryInfo[slot]
		local savedInfo = PetJewelryOssCache.getSavedTransform(realPetId, accessoryId, slotInfo)

		if savedInfo then
			ClientModelUtils.addPetModelAttach(ent, slot, savedInfo)
		else
			ClientModelUtils.addPetDefaultModelAttach(ent, slot, accessoryId)
		end
	end
end

function ClientModelUtils.showPetTempAccesses(ent)
	if not ent.tempJewelryInfo or not ent.tempJewelryInfo.customPresets then
		return
	end

	local PetJewelryOssCache = require("Utils.PetJewelryOssCache")
	local realPetId = ent.realPetId

	for slot, accessoryId in pairs(ent.tempJewelryInfo.customPresets) do
		if accessoryId and accessoryId ~= 0 then
			local slotInfo = ent.tempJewelryInfo[slot]
			local savedInfo = ent.useTempJewelrySnapshot and slotInfo or PetJewelryOssCache.getSavedTransform(realPetId, accessoryId, slotInfo)

			if savedInfo then
				ClientModelUtils.addPetModelAttach(ent, slot, savedInfo)
			else
				ClientModelUtils.addPetDefaultModelAttach(ent, slot, accessoryId)
			end
		end
	end
end

function ClientModelUtils.addPetModelAttach(ent, slot, info)
	local resId = AccessoryData[info.configId].res
	local instanceId = string.format("%d_%d", slot, info.configId)
	local attachHp = info.attachBone
	local localPosition = Vector3.New(info.posX, info.posY, info.posZ)
	local localRotation = Vector3.New(info.rotX, info.rotY, info.rotZ)
	local scale = Vector3.New(info.scale, info.scale, info.scale)
	local modelView = ent.eModel.modelModelView

	modelView.modelInfo:AddAttachInfo(resId, instanceId, attachHp, localPosition, localRotation, scale, false)
	AppearanceEffectUtils.setPetAccessory(ent, slot, info.configId, instanceId)
end

function ClientModelUtils.addPetDefaultModelAttach(ent, slot, accessoryId)
	local instanceId = string.format("%d_%d", slot, accessoryId)
	local itemData = AccessoryData[accessoryId]

	if not itemData then
		return
	end

	local resId = itemData.res
	local modelView = ent.eModel.modelModelView
	local petTemplateId = ent.templateId
	local Utils = require("Common.Utils.Utils")

	if Utils.isHomePet(ent) and ent.petInfo then
		petTemplateId = ent.petInfo.templateId
	end

	local petData = PetData[petTemplateId]
	local refId = petData and petData.refId or petTemplateId
	local t = pgUtils.GetAccessoryConfigFromLocal(petTemplateId, accessoryId)

	t = t or pgUtils.GetAccessoryConfigFromLocal(refId, accessoryId)

	if t then
		ClientModelUtils.addPetAttachInfo(modelView.modelInfo, resId, instanceId, t.attachHp, t.localPosition, t.localRotation, Vector3.New(t.scale, t.scale, t.scale))
	else
		local halfHeight = ent.adjustHeight / 2
		local startOffset = Vector3.New(halfHeight, ent.adjustHeight, 0)

		modelView.modelInfo:AddAttachInfo(resId, instanceId, nil, startOffset, Vector3.zero, Vector3.one)
	end

	AppearanceEffectUtils.setPetAccessory(ent, slot, accessoryId, instanceId)
end

function ClientModelUtils.addModelPart(modelInfo, configId)
	if not configId then
		return
	end

	local appearanceData = AppearanceData[configId]

	if not appearanceData then
		return
	end

	local Utils = require("Common.Utils.Utils")

	modelInfo.partModelInfo:ModifyPartItem(appearanceData.res, Utils.deepCopyTable(appearanceData.points))
end

function ClientModelUtils.removeModelPart(modelInfo, configId)
	if not configId then
		return
	end

	local appearanceData = AppearanceData[configId]

	if not appearanceData then
		return
	end

	modelInfo.partModelInfo:RemovePartItem(appearanceData.res)
end

function ClientModelUtils.applyAnimController(entity, eModel, configData, forceRefreshPlayable)
	eModel:SetControllerAsset(Const.COMPONENT_IDX_PLAYABLE, ClientModelUtils.getAnimController(configData))
end

function ClientModelUtils.getAnimController(configData)
	if configData then
		return configData.animController
	end

	return nil
end

function ClientModelUtils.getEntityAnimController(entityType, templateId)
	local configData

	if entityType == "Puppet" then
		configData = puppetData[templateId]
	elseif entityType == "Pet" then
		configData = petData[templateId]
	elseif entityType == "Player" then
		configData = AvatarData[templateId]
	end

	if configData then
		return ClientModelUtils.getAnimController(configData)
	end
end

function ClientModelUtils.applyIndividuation(entity, individuationIds)
	if not individuationIds then
		return
	end

	for typeId, individuationId in pairs(individuationIds) do
		local individuationData = PetIndividuationData[individuationId] or {}

		if individuationData.animState then
			local animName = "Appearance_" .. individuationData.animState

			entity:playAnimation(animName)
		end
	end
end

function ClientModelUtils.applyIndividuationTrans(ent, oldIndividuationId, newIndividuationId)
	local oldData = PetIndividuationData[oldIndividuationId] or {}
	local newData = PetIndividuationData[newIndividuationId] or {}

	if newData.animState then
		if oldData.animState then
			local animName = "Appearance_" .. oldData.animState .. "_To_" .. newData.animState

			if ent:hasPlayableOverrideConfig(animName) then
				ent:playAnimation(animName)
			else
				animName = "Appearance_" .. newData.animState

				ent:playAnimation(animName)
			end
		else
			local animName = "Appearance_" .. newData.animState

			ent:playAnimation(animName)
		end
	end
end

function ClientModelUtils.getBornScale(pdd, label)
	if pdd.modelScaleRange == nil then
		return 1
	end

	local minRange, maxRange = unpack(pdd.modelScaleRange or {})

	minRange = minRange or 0
	maxRange = maxRange or 1

	local Utils = require("Common.Utils.Utils")
	local rand = Utils.formulaSafeCall(0, pdd.randomFormula)
	local sign = math.random() < 0.5 and -1 or 1
	local bornScale = (maxRange - minRange) / 2 * rand * sign + (maxRange + minRange) / 2

	if Utils.isLabelBoss(label) then
		bornScale = pdd.scaleBoss or 1
	elseif Utils.isLabelElite(label) then
		bornScale = pdd.scaleElite or 1
	end

	local lume = require("Core.Common.lume")

	return lume.round(bornScale, 0.01)
end

return ClientModelUtils
