-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeBookCropDetail\\HomeBookCropDetailModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local HomeBookDataUtils = require("Utils.HomeBookDataUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local AddressDataConst = require("Const.AddressDataConst")
local ClientConst = require("Const.ClientConst")
local ItemData = require("Data.item_data")
local ItemSourceData = require("Data.item_source_data")
local HomelandFormulaData = require("Data.homeland_formula_data")
local HomelandFormulaDataReverse = require("Data.homeland_formula_data_reverse")
local HomelandFacilityDataReverse = require("Data.homeland_facility_data_reverse")
local HomeObjectData = require("Data.home_object_data")
local FormulaRandomData = require("Data.homeland_formula_random_data")
local HomelandFormulaReverseData = require("Data.homeland_formula_random_reverse_data")
local ClientHomelandUtils = require("Utils.ClientHomelandUtils")
local ProductItemData = require("Data.home_handbook_product_data")
local HomeBookCropDetailModel = Class.LightClass("HomeBookCropDetailModel", UIModel)

function HomeBookCropDetailModel:getLocalizedText(textId)
	return textId and pg.getLocalizationText(textId) or ""
end

function HomeBookCropDetailModel:isCropEntry(entryId)
	local entry = HomeBookDataUtils.getEntity(entryId)

	return entry ~= nil and entry.sourceType == "item" and ItemData[entryId] ~= nil
end

function HomeBookCropDetailModel:sortCropEntryIds(leftEntryId, rightEntryId)
	local leftCollected = pg.me and pg.me:isHomeHandbookItemCollected(leftEntryId) or false
	local rightCollected = pg.me and pg.me:isHomeHandbookItemCollected(rightEntryId) or false

	if leftCollected ~= rightCollected then
		return leftCollected
	end

	return HomeBookDataUtils.compareEntrySort(leftEntryId, rightEntryId)
end

function HomeBookCropDetailModel:getFormulaData(entry, itemConfig)
	return HomelandFormulaData[itemConfig.fomulaId] or HomelandFormulaData[entry.formulaId] or HomelandFormulaData[entry.id]
end

function HomeBookCropDetailModel:getSourceInfo(entry, itemConfig)
	local formulaId = entry.id
	local reverseInfo = HomelandFormulaReverseData[entry.id]

	if reverseInfo and reverseInfo.rType ~= 0 then
		formulaId = reverseInfo.formulaId
	end

	if HomelandFormulaData[formulaId] then
		for _, facilityId in ipairs(HomelandFacilityDataReverse[formulaId] or EMPTY_TABLE) do
			local objectConfig = HomeObjectData[facilityId]

			if objectConfig then
				return self:getLocalizedText(objectConfig.name), objectConfig.plotIconId
			end
		end
	elseif itemConfig.source and #itemConfig.source > 0 then
		local config = ItemSourceData[itemConfig.source[1]]

		if config then
			return self:getLocalizedText(config.buttonTxt), ""
		end
	end

	return "", ""
end

function HomeBookCropDetailModel:buildEnvironmentInfo(formulaData)
	if not formulaData then
		return nil
	end

	local environmentNames = {}
	local icon

	if formulaData.temperatureRequire then
		environmentNames[#environmentNames + 1] = HomeLandUtils.getTempLevelText(formulaData.temperatureRequire)
		icon = ClientConst.TemperatureBuffIcon[formulaData.temperatureRequire] or AddressDataConst.HOME_TOPLOGO_ICON_TEMPERATURE
	end

	if formulaData.lightRequire then
		environmentNames[#environmentNames + 1] = pg.getGameString("SUFFICIENT")
		icon = icon or ClientConst.LightBuffIcon[formulaData.lightRequire] or AddressDataConst.HOME_TOPLOGO_ICON_LIGHT
	end

	if #environmentNames == 0 then
		return nil
	end

	local requirementText = formulaData.forceEnvRequire == 1 and pg.getGameString("HOMELAND_TIPS_ENV_REQUIRE") or pg.getGameString("HOMELAND_TIPS_ENV_RECOMMEND")

	return {
		tIndex = 0,
		title = pg.getGameString("HOME_BOOK_ENVIRONMENT"),
		text = string.format("%s：%s", requirementText, table.concat(environmentNames, " / ")),
		icon = icon
	}
end

function HomeBookCropDetailModel:getConsumables(entry, formulaData)
	local result = {}

	for index = 1, 3 do
		local itemId = formulaData and formulaData["consumable" .. index]
		local itemNum = formulaData and formulaData["consumableNum" .. index]

		if itemId and ItemData[itemId] and itemId ~= entry.id then
			result[#result + 1] = {
				id = itemId,
				num = itemNum or 1
			}
		end
	end

	return result
end

function HomeBookCropDetailModel:getMachinableItems(itemId, formulaData)
	local rawItemId = itemId

	if formulaData and formulaData.outputs and formulaData.outputs[1] then
		rawItemId = formulaData.outputs[1][1]
	end

	local outputIdSet = {}

	for _, formulaId in ipairs(HomelandFormulaDataReverse[rawItemId] or EMPTY_TABLE) do
		local outputFormula = HomelandFormulaData[formulaId]

		if outputFormula and not HomeLandUtils.isElectricFormula(formulaId) and HomeLandUtils.isHomelandFormulaTimeValid(formulaId) then
			local outputMap = HomeLandUtils.getFormulaOutputMap(outputFormula)

			if next(outputMap) then
				for outputItemId in pairs(outputMap) do
					if ItemData[outputItemId] then
						outputIdSet[outputItemId] = true
					end
				end
			elseif outputFormula.previewItemId and ItemData[outputFormula.previewItemId] then
				outputIdSet[outputFormula.previewItemId] = true
			end
		end
	end

	local result = {}

	for outputItemId in pairs(outputIdSet) do
		result[#result + 1] = {
			num = 1,
			id = outputItemId
		}
	end

	table.sort(result, function(left, right)
		return left.id < right.id
	end)

	return result
end

function HomeBookCropDetailModel:buildInfoList(entry, itemConfig, formulaData)
	local sourceText, sourceIcon = self:getSourceInfo(entry, itemConfig)
	local result = {
		{
			tIndex = 0,
			title = pg.getGameString("ITEM_SOURCE"),
			text = sourceText,
			icon = sourceIcon
		}
	}
	local environmentInfo = self:buildEnvironmentInfo(formulaData)

	if environmentInfo then
		result[#result + 1] = environmentInfo
	end

	local consumables = self:getConsumables(entry, formulaData)

	if #consumables > 0 then
		result[#result + 1] = {
			tIndex = 1,
			title = pg.getGameString("HOMELAND_RAW_MATERIALS"),
			items = consumables
		}
	end

	if not HomeLandUtils.isMutationItem(entry.id) then
		local machinableItems = self:getMachinableItems(entry.id, formulaData)

		if #machinableItems > 0 then
			result[#result + 1] = {
				tIndex = 1,
				title = pg.getGameString("HOMELAND_TIPS_WORKABLE"),
				items = machinableItems
			}
		end
	end

	for _, infoData in ipairs(result) do
		if infoData.tIndex == 1 then
			infoData.isFirstItemList = true

			break
		end
	end

	return result
end

function HomeBookCropDetailModel:selectEntry(entryId, navigationEntryIds)
	if not entryId or not self:isCropEntry(entryId) then
		return false
	end

	local entry = HomeBookDataUtils.getEntity(entryId)
	local entryIds = {}

	if navigationEntryIds then
		for _, siblingId in ipairs(navigationEntryIds) do
			if self:isCropEntry(siblingId) then
				entryIds[#entryIds + 1] = siblingId
			end
		end
	else
		for _, sibling in ipairs(HomeBookDataUtils.getEntriesByThirdType(entry.thirdType)) do
			if self:isCropEntry(sibling.id) then
				entryIds[#entryIds + 1] = sibling.id
			end
		end

		table.sort(entryIds, function(leftEntryId, rightEntryId)
			return self:sortCropEntryIds(leftEntryId, rightEntryId)
		end)
	end

	local currentIndex = 1

	for index, siblingId in ipairs(entryIds) do
		if siblingId == entryId then
			currentIndex = index

			break
		end
	end

	self.entryIds = entryIds
	self.currentIndex = currentIndex

	return #entryIds > 0
end

function HomeBookCropDetailModel:setDetailInfo(info)
	info = info or {}
	self.entryIds = {}
	self.currentIndex = 1

	self:selectEntry(info.entryId or info.id, info.entryIds)
end

function HomeBookCropDetailModel:move(offset)
	local count = #(self.entryIds or {})

	if count <= 1 then
		return false
	end

	self.currentIndex = (self.currentIndex - 1 + offset) % count + 1

	return true
end

function HomeBookCropDetailModel:getCurrentEntryId()
	return self.entryIds and self.entryIds[self.currentIndex]
end

function HomeBookCropDetailModel:getMutationPreviewData(entryId)
	local reverseInfo = HomelandFormulaReverseData[entryId]

	if not reverseInfo or reverseInfo.rType == 0 then
		return nil
	end

	local randomInfo = FormulaRandomData[reverseInfo.formulaId] and FormulaRandomData[reverseInfo.formulaId][reverseInfo.rType]

	if not randomInfo or not randomInfo.modelPrefab or randomInfo.modelPrefab == "" then
		return nil
	end

	local productConfig = ProductItemData[entryId]

	return ClientHomelandUtils.getPreviewDataByConfig(productConfig, randomInfo.modelPrefab)
end

function HomeBookCropDetailModel:getDetailData()
	local entryId = self:getCurrentEntryId()
	local entry = entryId and HomeBookDataUtils.getEntity(entryId)
	local itemConfig = entryId and ItemData[entryId]

	if not entry or not itemConfig then
		return nil
	end

	local formulaData = self:getFormulaData(entry, itemConfig)
	local isCollected = pg.me and pg.me:isHomeHandbookItemCollected(entryId) or false
	local thirdTypeConfig = HomeBookDataUtils.getThirdType(entry.thirdType)

	return {
		id = entryId,
		title = self:getLocalizedText(thirdTypeConfig and thirdTypeConfig.name),
		name = self:getLocalizedText(itemConfig.itemName),
		icon = entry.config.icon or itemConfig.icon,
		tag = isCollected and pg.getGameString("HOMELAND_PLOT_UNLOCKED") or pg.getGameString("HOMELAND_ITEM_LOCKED"),
		desc = self:getLocalizedText(itemConfig.itemDes),
		addGrade = entry.addGrade or 0,
		isCollected = isCollected,
		infoList = self:buildInfoList(entry, itemConfig, formulaData),
		modelData = self:getMutationPreviewData(entryId),
		canCycle = #self.entryIds > 1
	}
end

function HomeBookCropDetailModel:getAutoCollectData(entryId)
	local isHomeHandbookItemCollected = pg.me and pg.me:isHomeHandbookItemCollected(entryId)

	if not HomeLandUtils.isMutationItem(entryId) or not isHomeHandbookItemCollected then
		return nil
	end

	local space = pg.me and pg.me.space
	local switchMap = space and space.plantAutoCollectSwitch
	local switchValue = switchMap and switchMap[entryId]

	if switchValue == nil and switchMap then
		switchValue = switchMap[HomeLandUtils.getMutationCollectType(entryId)]
	end

	return {
		itemId = entryId,
		text = pg.getFormatText(pg.getGameString("HOMELAND_VARIATION_PLANT_AUTO"), self:getLocalizedText(ItemData[entryId].itemName)),
		isOn = switchValue ~= false
	}
end

return HomeBookCropDetailModel
