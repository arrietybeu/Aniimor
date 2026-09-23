-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Incubator\\IncubatorModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("IncubatorModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local IncubatorModel = Class.LightClass("IncubatorModel", UIModel)
local Lume = require("Core.Common.lume")
local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local NoticeDef = require("Common.NoticeDef")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TimeUtils = require("Common.Utils.TimeUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local UIConst = require("Const.UIConst")
local PetData = require("Data.pet_data")
local ItemData = require("Data.item_data")
local PetTalentData = require("Data.pet_talent_data")
local PetCharacterData = require("Data.pet_character_data")
local PetBallConfigData = require("Data.pet_ball_config_data")
local InteractionConst = require("Common.Const.InteractionConst")

IncubatorModel.RootPage_PutEgg = 0
IncubatorModel.RootPage_SpeedUp = 1
IncubatorModel.RootPage_Manger = 2
IncubatorModel.ItemType_Egg = 0
IncubatorModel.ItemType_SpeedUp = 1

function IncubatorModel:getRootPage(uiOpenParams)
	local ornamentId = uiOpenParams and uiOpenParams.ornamentId or 0
	local actionId = uiOpenParams and uiOpenParams.actionPrototypeId
	local hatchBoxStatus = HomeLandUtils.getHatchBoxStatus(ornamentId)

	if actionId and actionId == InteractionConst.INTERACT_HOME_HATCHBOX_SPEEDUP then
		if hatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHING or hatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHED then
			return IncubatorModel.RootPage_SpeedUp
		end
	elseif actionId and actionId == InteractionConst.INTERACT_HOME_HATCHBOX_PLACE then
		if hatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHING or hatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHED then
			return IncubatorModel.RootPage_Manger
		end
	elseif actionId and actionId == InteractionConst.INTERACT_HOME_HATCHBOX_SUC and (hatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHING or hatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHED) then
		return IncubatorModel.RootPage_Manger
	end

	return IncubatorModel.RootPage_PutEgg
end

function IncubatorModel:getListContEmptyDesc(pageIndex)
	if pageIndex == IncubatorModel.RootPage_PutEgg then
		return pg.getGameString("INCUBATOR_WITHOUT_EGG_DESC")
	elseif pageIndex == IncubatorModel.RootPage_SpeedUp then
		return pg.getGameString("INCUBATOR_WITHOUT_SPEEDUP_DESC")
	elseif pageIndex == IncubatorModel.RootPage_Manger then
		return pg.getGameString("INCUBATOR_WITHOUT_EGG_DESC")
	end

	return ""
end

function IncubatorModel:getEmptyHatchDesc()
	return pg.getGameString("INCUBATOR_EMPTY_HATCH_DESC")
end

function IncubatorModel:getHatchEggSortInfo()
	return {
		{
			name = pg.getGameString("DEFAULT_SORT")
		},
		{
			name = pg.getGameString("QUALITY")
		}
	}
end

function IncubatorModel:setHatchSortId(hatchSortId)
	self.hatchSortId = hatchSortId
end

function IncubatorModel:getHatchSortId(hatchSortId)
	return self.hatchSortId or 1
end

function IncubatorModel:reverseSetHatchDescending()
	self.hatchIsDescending = not self.hatchIsDescending
end

function IncubatorModel:getHatchDescending()
	return self.hatchIsDescending
end

function IncubatorModel:getOrnamentHatchInfo(ornamentId)
	return pg.me.space:getHatchBoxInfo(ornamentId)
end

function IncubatorModel:getSpeedUpItems()
	local ret = {}
	local player = pg.me
	local speedUpInfo = PetBallConfigData.itemSpeedUpInfo or {}

	for itemId, _ in pairs(speedUpInfo) do
		local items = ItemUtils.getItemsById(player, itemId) or {}

		for _, item in ipairs(items) do
			local itemCfg = ItemData[item.id]
			local retItem = {
				index = #ret + 1,
				genId = item.genID,
				id = item.id,
				count = item.count,
				icon = itemCfg and itemCfg.icon,
				quality = itemCfg and itemCfg.quality,
				eggName = itemCfg and itemCfg.itemName,
				eggDes = itemCfg and itemCfg.itemDes,
				funcRep = itemCfg and itemCfg.funcRep,
				isLock = item.isStatusLocked and item:isStatusLocked() or false,
				itemId = itemId
			}

			ret[#ret + 1] = retItem
		end
	end

	return ret
end

function IncubatorModel:getAllEggs()
	local ret = {}

	ItemUtils.eachSupportedTypedBag(pg.me, function(_, itemBag)
		for _, packSlot in itemBag:items() do
			local temp = self:getInfoByItem(packSlot)

			if temp then
				ret[#ret + 1] = temp
			end
		end
	end)

	if self.hatchSortId == 1 then
		table.sort(ret, function(a, b)
			if self.hatchIsDescending then
				return a.id > b.id
			else
				return a.id < b.id
			end
		end)
	elseif self.hatchSortId == 2 then
		table.sort(ret, function(a, b)
			if self.hatchIsDescending then
				return a.quality > b.quality
			else
				return a.quality < b.quality
			end
		end)
	end

	for i, v in ipairs(ret) do
		v.index = i
	end

	return ret
end

function IncubatorModel:getInfoByItem(item)
	local ret

	if Utils.isBreedPetEgg(item.id) then
		local extraProp = item:getExtraProp()

		if not extraProp or not next(extraProp) then
			return ret
		end

		local featureInfo = PetCharacterData[extraProp.characterId]
		local featureInfoNew = {}

		if featureInfo then
			featureInfoNew = {
				rare = featureInfo.rare or 0,
				desc = featureInfo.desc,
				name = featureInfo.name,
				icon = featureInfo.icon,
				characterId = extraProp.characterId
			}
		else
			featureInfoNew = featureInfo
		end

		local breedTalent = {}
		local talentList = extraProp.talentIds

		for i = 1, #talentList do
			local talentTemplateId = talentList[i]

			if talentTemplateId then
				local name = PetTalentData[talentTemplateId].talentName
				local icon = PetTalentData[talentTemplateId].talentIcon
				local quality = PetTalentData[talentTemplateId].rarity
				local id = talentTemplateId
				local group = PetTalentData[talentTemplateId].group
				local desc = PetTalentData[talentTemplateId].dec

				breedTalent[#breedTalent + 1] = {
					name = name,
					icon = icon,
					quality = quality,
					id = id,
					group = group,
					desc = desc
				}
			end
		end

		table.sort(breedTalent, function(a, b)
			return a.id < b.id
		end)

		ret = {
			isHatching = false,
			isNormalEgg = false,
			genId = item.genID,
			id = item.id,
			count = item.count,
			icon = ItemData[item.id].icon,
			quality = ItemData[item.id].quality,
			eggName = ItemData[item.id].itemName,
			eggDes = ItemData[item.id].itemDes,
			funcRep = ItemData[item.id].funcRep,
			basePropertyIndividualLevelList = extraProp.basePropertyIndividualLevelList,
			characterId = extraProp.characterId,
			talentIds = extraProp.talentIds,
			templateId = extraProp.templateId,
			petName = PetData[extraProp.templateId].name,
			petIcon = PetData[extraProp.templateId].iconName,
			templateIdFather = extraProp.templateIdFather,
			templateIdMother = extraProp.templateIdMother,
			label = extraProp.label,
			gender = extraProp.gender,
			isShiny = Utils.isLabelShiny(extraProp.label),
			featureInfo = featureInfoNew,
			breedTalent = breedTalent,
			isLock = item:isStatusLocked(),
			itemId = item.id
		}
	elseif Utils.isNormalPetEgg(item.id) then
		ret = {
			isHatching = false,
			isNormalEgg = true,
			genId = item.genID,
			id = item.id,
			count = item.count,
			icon = ItemData[item.id].icon,
			quality = ItemData[item.id].quality,
			eggName = ItemData[item.id].itemName,
			eggDes = ItemData[item.id].itemDes,
			funcRep = ItemData[item.id].funcRep,
			isLock = item.isStatusLocked and item:isStatusLocked() or false,
			itemId = item.id
		}
	end

	return ret
end

function IncubatorModel:setSelectedItemData(itemData)
	self.selectedItemData = itemData
end

function IncubatorModel:getSelectedItemData()
	return self.selectedItemData
end

function IncubatorModel:getPreviewIncubatroFinishTimeDesc(eggItemId, ornamentId)
	if Utils.isBreedPetEgg(eggItemId) or Utils.isNormalPetEgg(eggItemId) then
		local hatchTime, speedupTime = Utils.getFixedInitHatchTime(pg.me, eggItemId)
		local timeDesc = LuaUIUtils.getCountDownString(hatchTime, UIConst.TimeType.Short, true)
		local activitySpeed = speedupTime and speedupTime[Const.HatchSpeedUpReason.activty_petHatch]

		if activitySpeed and activitySpeed > 0 then
			timeDesc = string.format("<style=Hint_BgL>%s</style>", timeDesc)
		end

		return timeDesc
	end

	return ""
end

function IncubatorModel:setPreviewSpeedupTime(itemData, ornamentId)
	local speedUpInfo = PetBallConfigData.itemSpeedUpInfo or {}
	local itemId = itemData and itemData.itemId or 0
	local fixedReduction = speedUpInfo and speedUpInfo[itemId] and speedUpInfo[itemId][1] or 0
	local timeRateReduction = speedUpInfo and speedUpInfo[itemId] and speedUpInfo[itemId][2] or 0
	local ornamentHatchInfo = self:getOrnamentHatchInfo(ornamentId or 0)
	local eggItemId = ornamentHatchInfo and ornamentHatchInfo.item and ornamentHatchInfo.item.id or 0
	local hatchTime = Utils.getFixedInitHatchTime(pg.me, eggItemId)

	self.previewSpeedupTimeSecond = fixedReduction + hatchTime * timeRateReduction
end

function IncubatorModel:getPreviewSpeedupTimeDesc()
	if not self.previewSpeedupTimeSecond or self.previewSpeedupTimeSecond <= 0 then
		return ""
	end

	return "-" .. LuaUIUtils.getCountDownString(self.previewSpeedupTimeSecond, UIConst.TimeType.Short, true)
end

function IncubatorModel:getLimitSpeedupCntDesc(speedupInfo)
	if not speedupInfo then
		return ""
	end

	return string.format(pg.getGameString("%s/%s"), math.max(0, speedupInfo.dailyLimitCnt - speedupInfo.curUsedCnt), speedupInfo.dailyLimitCnt)
end

return IncubatorModel
