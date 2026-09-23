-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\InventoryPetPropUse\\InventoryPetPropUseModel.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("InventoryPetPropUseModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local lume = require("Core.Common.lume")
local InventoryPetPropUseModel = Class.LightClass("InventoryPetPropUseModel", UIModel)
local PetConfigData = require("Data.pet_config_data")
local ItemUseCheckUtils = require("Common.Utils.ItemUseCheckUtils")
local Utils = require("Common.Utils.Utils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local PetCharacterData = require("Data.pet_character_data")
local ItemEffectData = require("Data.item_effect_data")
local SysConfigData = require("Data.sys_config_data")
local Const = require("Common.Const.Const")

function InventoryPetPropUseModel:getChangeLabelParams(itemId)
	local effect = ItemEffectData[itemId]
	local params = effect and effect.params

	if not params or #params < 2 then
		return nil
	end

	return params[1], params[2], params[3]
end

local function isSinglePetLabel(label)
	return type(label) == "number" and label > Const.PET_LABEL_MASK.NORMAL and bit.band(label, label - 1) == 0
end

local function getItemPetBlacklist(config, itemId)
	if not Utils.isTable(config) or config[1] ~= itemId then
		return nil
	end

	local blacklist = config[2]

	return Utils.isTable(blacklist) and blacklist or nil
end

function InventoryPetPropUseModel:getModifyPetLabelConfig(itemId)
	local effect = ItemEffectData[itemId]
	local params = effect and effect.params

	if not Utils.isTable(params) then
		return nil
	end

	local condition = params[1]
	local target = params[2]
	local consumeCount = params[3]

	if not Utils.isTable(condition) or not Utils.isTable(target) or type(consumeCount) ~= "number" or consumeCount <= 0 then
		return nil
	end

	local petPrototypeIds = condition[1]
	local formId = condition[2] or 0
	local conditionLabel = condition[3] or Const.PET_LABEL_MASK.NORMAL
	local targetLabel = target[1]
	local labelParam = target[2] or 0

	if petPrototypeIds ~= nil and not Utils.isTable(petPrototypeIds) then
		return nil
	end

	if type(formId) ~= "number" or type(conditionLabel) ~= "number" or type(labelParam) ~= "number" then
		return nil
	end

	if conditionLabel ~= Const.PET_LABEL_MASK.NORMAL and not isSinglePetLabel(conditionLabel) then
		return nil
	end

	if not isSinglePetLabel(targetLabel) then
		return nil
	end

	return {
		itemId = itemId,
		petPrototypeIds = petPrototypeIds,
		formId = formId,
		conditionLabel = conditionLabel,
		targetLabel = targetLabel,
		labelParam = labelParam,
		consumeCount = consumeCount
	}
end

function InventoryPetPropUseModel:isPetPrototypeAllowed(petInfo, petPrototypeIds)
	if not petPrototypeIds or not next(petPrototypeIds) then
		return true
	end

	for _, petPrototypeId in ipairs(petPrototypeIds) do
		if petInfo.petPrototypeId == petPrototypeId then
			return true
		end
	end

	return false
end

local function collectManagedPetIds()
	local ret = {}
	local petBoxMap = pg.me and pg.me.petBoxMap

	if not petBoxMap then
		return ret
	end

	for _, boxInfo in petBoxMap:items() do
		for _, petId in boxInfo:items() do
			if string.notNilOrEmpty(petId) then
				ret[petId] = true
			end
		end
	end

	return ret
end

function InventoryPetPropUseModel:isPetInManagementScope(petId, managedPetIds)
	if not petId then
		return false
	end

	if managedPetIds then
		return managedPetIds[petId] == true
	end

	local petBoxMap = pg.me and pg.me.petBoxMap

	return petBoxMap ~= nil and petBoxMap:getPetIndex(petId) ~= nil
end

function InventoryPetPropUseModel:checkModifyPetLabelOnPet(petId, config, managedPetIds)
	if not config then
		return false, "INVENTORY_PETPROP_CANTUSE", false
	end

	local petInfo = pg.me:getPetInfo(petId)

	if not petInfo then
		return false, "INVENTORY_PETPROP_CANTUSE", false
	end

	if not self:isPetInManagementScope(petId, managedPetIds) then
		return false, "INVENTORY_PETPROP_CANTUSE", false
	end

	local forbidKey = self:getHeraldryForbidKey(petId, config.targetLabel, config.itemId)

	if forbidKey then
		return false, forbidKey, false
	end

	if not self:isPetPrototypeAllowed(petInfo, config.petPrototypeIds) then
		return false, "INVENTORY_PETPROP_NOT_TARGET", false
	end

	if config.formId ~= 0 and Utils.getPetFormIdByPrototypeId(petInfo.petPrototypeId) ~= config.formId then
		return false, "INVENTORY_PETPROP_NOT_TARGET", false
	end

	local currentLabel = petInfo.label or Const.PET_LABEL_MASK.NORMAL

	if config.conditionLabel ~= Const.PET_LABEL_MASK.NORMAL and bit.band(currentLabel, config.conditionLabel) == 0 then
		return false, "INVENTORY_PETPROP_NOT_TARGET", false
	end

	local hasTargetLabel = bit.band(currentLabel, config.targetLabel) ~= 0

	if config.targetLabel == Const.PET_LABEL_MASK.SHINY then
		if hasTargetLabel and config.labelParam ~= 0 and petInfo.shinyStyle == config.labelParam then
			return false, nil, true
		end
	elseif hasTargetLabel then
		return false, nil, true
	end

	return true, nil, false
end

function InventoryPetPropUseModel:findUsablePetForModifyPetLabel(itemId)
	local config = self:getModifyPetLabelConfig(itemId)
	local pets = pg.me.pets

	if not config or not pets then
		return nil
	end

	local managedPetIds = collectManagedPetIds()

	if config.petPrototypeIds and next(config.petPrototypeIds) then
		for _, petPrototypeId in ipairs(config.petPrototypeIds) do
			for petId, petInfo in pairs(pets) do
				if petInfo.petPrototypeId == petPrototypeId and self:checkModifyPetLabelOnPet(petId, config, managedPetIds) then
					return petId
				end
			end
		end

		return nil
	end

	for petId in pairs(pets) do
		if self:checkModifyPetLabelOnPet(petId, config, managedPetIds) then
			return petId
		end
	end

	return nil
end

function InventoryPetPropUseModel:isPetInAllowedList(petId, allowedTemplateIds)
	if not allowedTemplateIds or #allowedTemplateIds == 0 then
		return true
	end

	local petInfo = pg.me:getPetInfo(petId)
	local templateId = petInfo and petInfo.templateId

	if not templateId then
		return false
	end

	for _, v in ipairs(allowedTemplateIds) do
		if v == templateId then
			return true
		end
	end

	return false
end

function InventoryPetPropUseModel:canUseChangeLabelOnPet(petId, targetLabel, allowedTemplateIds, itemId, managedPetIds)
	if not targetLabel then
		return false
	end

	if not self:isPetInManagementScope(petId, managedPetIds) then
		return false
	end

	if not self:isPetInAllowedList(petId, allowedTemplateIds) then
		return false
	end

	if self:getHeraldryForbidKey(petId, targetLabel, itemId) ~= nil then
		return false
	end

	local petInfo = pg.me:getPetInfo(petId)

	if not petInfo then
		return false
	end

	local curLabel = petInfo.label or 0

	if bit.band(curLabel, targetLabel) ~= 0 then
		return false
	end

	return true
end

function InventoryPetPropUseModel:canUseChangePetSizeTypeOnPet(petId, managedPetIds)
	if not self:isPetInManagementScope(petId, managedPetIds) then
		return false
	end

	local petInfo = pg.me:getPetInfo(petId)
	local label = petInfo and petInfo.label or 0

	return Utils.isLabelElite(label) or Utils.isLabelRainbow(label)
end

function InventoryPetPropUseModel:findUsablePetForChangePetSizeType()
	local pets = pg.me.pets

	if not pets then
		return nil
	end

	local managedPetIds = collectManagedPetIds()

	for petId in pairs(pets) do
		if self:canUseChangePetSizeTypeOnPet(petId, managedPetIds) then
			return petId
		end
	end

	return nil
end

function InventoryPetPropUseModel:findUsablePetForChangeLabel(itemId)
	local targetLabel, _, allowedTemplateIds = self:getChangeLabelParams(itemId)

	if not targetLabel then
		return nil
	end

	local pets = pg.me.pets

	if not pets then
		return nil
	end

	local managedPetIds = collectManagedPetIds()

	if allowedTemplateIds and #allowedTemplateIds > 0 then
		for _, templateId in ipairs(allowedTemplateIds) do
			for petId, petInfo in pairs(pets) do
				if petInfo.templateId == templateId and self:canUseChangeLabelOnPet(petId, targetLabel, allowedTemplateIds, itemId, managedPetIds) then
					return petId
				end
			end
		end

		return nil
	end

	for petId in pairs(pets) do
		if self:canUseChangeLabelOnPet(petId, targetLabel, nil, itemId, managedPetIds) then
			return petId
		end
	end

	return nil
end

function InventoryPetPropUseModel:getHeraldryForbidKey(petId, targetLabel, itemId)
	local petInfo = pg.me:getPetInfo(petId)
	local templateId = petInfo and petInfo.templateId

	if not templateId then
		return nil
	end

	local function hitList(list)
		if not list then
			return false
		end

		for _, v in ipairs(list) do
			if v ~= 0 and v == templateId then
				return true
			end
		end

		return false
	end

	if hitList(SysConfigData.UNUSABLE_HERALDRY_ALL_LIST) then
		return "INVENTORY_PETPROP_LABEL_FORBID"
	end

	if targetLabel == Const.PET_LABEL_MASK.SHINY and hitList(getItemPetBlacklist(SysConfigData.UNUSABLE_HERALDRY_SHINY_LIST, itemId)) then
		return "INVENTORY_PETPROP_SHINY_FORBID"
	end

	if targetLabel == Const.PET_LABEL_MASK.ELITE and hitList(SysConfigData.UNUSABLE_HERALDRY_ELITE_LIST) then
		return "INVENTORY_PETPROP_ELITE_FORBID"
	end

	if hitList(getItemPetBlacklist(SysConfigData.UNUSABLE_HERALDRY_SHINYSTYTLE_LIST, itemId)) then
		return "INVENTORY_PETPROP_SHINY_FORBID"
	end

	return nil
end

function InventoryPetPropUseModel:getEnhanceState(petId)
	local petInfo = pg.me:getPetInfo(petId)
	local res, state = ItemUseCheckUtils.check_propertyEnhance(petInfo)

	return state
end

function InventoryPetPropUseModel:getEnhanceData(petId)
	local maxEnhance = PetConfigData.individualPropEnhanceMax
	local attrs = PetManagementDataHelper.getIndividualLevel(petId)
	local allExceed4, hasExceed4 = true, false
	local allMax, hasMax = true, false
	local recommends = {}
	local isHasRecommend = false

	for k, v in pairs(attrs) do
		isHasRecommend = true
		recommends[#recommends + 1] = v
		v.id = k

		if maxEnhance <= v.baseLv then
			hasExceed4 = true
			v.state = 3
		else
			allExceed4 = false

			if v.indLv >= v.individualLevelMax then
				hasMax = true
				v.state = 2
			else
				allMax = false
				v.state = 1
			end
		end
	end

	local changeList = {}

	for k, v in ipairs(recommends) do
		local add = v.state == 3 and 0 or 1

		changeList[#changeList + 1] = {
			name = v.name,
			before = v.baseLv,
			add = add,
			beforeIsMax = maxEnhance <= v.baseLv,
			afterIsMax = maxEnhance <= v.baseLv + add,
			beforeBaseLv = v.baseLv
		}
	end

	if allExceed4 then
		if isHasRecommend then
			return false, changeList, pg.getGameString("USE_PROPERTY_PROP_U_MAX_TIP")
		else
			return false, changeList, pg.getGameString("NO_RECOMMENDED_PROP")
		end
	end

	return true, changeList
end

function InventoryPetPropUseModel:getCharacterRandomData(petId)
	local pet = pg.me:getPetInfo(petId)
	local content = ""
	local curCharacterId = pet.characterInfo.curCharacter
	local changeList = {}
	local oriData = PetCharacterData[curCharacterId]

	if not oriData then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			if not PetCharacterData then
				logger.error("[宠物_特性配置表.txt / 宠物_特性配置表] pet_character_data 没有导出 !!! ")
			else
				logger.error(string.format("[宠物_特性配置表.txt / 宠物_特性配置表] pet_character_data 没有导出 [curCharacterId:%s]; [petId:%s]", curCharacterId, petId))
			end
		end

		return false, changeList, "宠物_特性配置表 没配数据"
	end

	local data1 = lume.clone(oriData)

	data1.featureId = curCharacterId

	local characterList = Utils.getValidCharacterList(pet, true)

	if #characterList == 0 then
		content = pg.getGameString("CHARACTER_ONLY_TIP")
		changeList = {
			data1,
			data1
		}

		return false, changeList, content
	end

	local data2 = lume.clone(PetCharacterData[characterList[1]])

	data2.featureId = characterList[1]
	changeList = {
		data1,
		data2
	}

	if PetCharacterData[curCharacterId].rare == 1 then
		local curCharacterName = pg.getFormatText("<style=Q_5>{0}</style>", pg.getLocalizationText(PetCharacterData[curCharacterId].name))
		local targetCharacterName = pg.getFormatText("<style=Q_3>{0}</style>", pg.getLocalizationText(PetCharacterData[characterList[1]].name))

		content = pg.getFormatText(pg.getGameString("PET_CHARACTER_MODIFY_RARE"), curCharacterName, targetCharacterName)
	else
		local curCharacterName = pg.getFormatText("<style=Q_3>{0}</style>", pg.getLocalizationText(PetCharacterData[curCharacterId].name))
		local targetCharacterName = pg.getFormatText("<style=Q_5>{0}</style>", pg.getLocalizationText(PetCharacterData[characterList[1]].name))

		content = pg.getFormatText(pg.getGameString("PET_CHARACTER_MODIFY_COMMON"), curCharacterName, targetCharacterName)
	end

	return true, changeList, content
end

function InventoryPetPropUseModel:getPetDisplayData(petId)
	local petInfo = pg.me and pg.me:getPetInfo(petId)

	if not petInfo then
		return nil
	end

	return PetManagementDataHelper.setUpPetInfo(petInfo)
end

return InventoryPetPropUseModel
