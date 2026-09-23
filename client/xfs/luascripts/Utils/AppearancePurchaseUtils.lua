-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\AppearancePurchaseUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local AppearanceData = require("Data.appearance_data")
local AppearanceSuitData = require("Data.appearance_suit_data")
local AppearanceJewelryPetData = require("Data.appearance_jewelry_pet_data")
local AvatarHairSuitData = require("Data.avatar_hair_suit_data")
local ShopmallAppearanceData = require("Data.shopmall_appearance")
local ShopmallCommodityData = require("Data.shopmall_commodity_data")
local ItemConditionConvertData = require("Data.item_condition_convert_data")
local TimeUtils = require("Common.Utils.TimeUtils")
local Utils = require("Common.Utils.Utils")
local ItemData = require("Data.item_data")
local ItemSourceData = require("Data.item_source_data")
local APPEARANCE_TYPE = {
	JEWELRY = 1,
	MAKEUP = 4,
	HAIR = 3,
	CLOTHING = 2
}
local CONDITION_MALE = 6
local CONDITION_FEMALE = 7
local AppearancePurchaseUtils = {}
local _appearanceToSuitCache, _jewelryToSuitsCache, _suitToCommodityCache, _genderVariantMapCache, _cachedDataVersion

local function _getCurrentDataVersion()
	local version = string.format("%s_%s_%s_%s_%s_%s_%s", tostring(AppearanceData), tostring(AppearanceSuitData), tostring(AppearanceJewelryPetData), tostring(AvatarHairSuitData), tostring(ShopmallAppearanceData), tostring(ShopmallCommodityData), tostring(ItemConditionConvertData))

	return version
end

local function _setSuitCommodityMapping(suitId, commodityId)
	if not suitId or not commodityId then
		return
	end

	if not _suitToCommodityCache[suitId] then
		_suitToCommodityCache[suitId] = commodityId

		return
	end

	local existingComInfo = ShopmallCommodityData[_suitToCommodityCache[suitId]]
	local newComInfo = ShopmallCommodityData[commodityId]

	if newComInfo and newComInfo.onSale == 1 and (not existingComInfo or existingComInfo.onSale ~= 1) then
		_suitToCommodityCache[suitId] = commodityId
	end
end

local function _getGenderVariantMap()
	if _genderVariantMapCache then
		return _genderVariantMapCache
	end

	local variantMap = {}

	local function bindVariant(a, b)
		a = tonumber(a)
		b = tonumber(b)

		if not a or not b or a <= 0 or b <= 0 then
			return
		end

		variantMap[a] = variantMap[a] or {
			[a] = true
		}
		variantMap[b] = variantMap[b] or {
			[b] = true
		}
		variantMap[a][b] = true
		variantMap[b][a] = true
	end

	for itemId, convertData in pairs(ItemConditionConvertData) do
		itemId = tonumber(itemId)

		if itemId and itemId > 0 then
			variantMap[itemId] = variantMap[itemId] or {
				[itemId] = true
			}

			if convertData.targetItem then
				for _, entry in ipairs(convertData.targetItem) do
					local condition = entry[1]

					if condition == CONDITION_MALE or condition == CONDITION_FEMALE then
						bindVariant(itemId, entry[2])
					end
				end
			end
		end
	end

	_genderVariantMapCache = variantMap

	return variantMap
end

local function _getGenderVariantIds(itemId)
	itemId = tonumber(itemId)

	if not itemId then
		return {}
	end

	local variants = _getGenderVariantMap()[itemId]

	if variants then
		return variants
	end

	return {
		[itemId] = true
	}
end

local function _mapSuitAndGenderVariantsToCommodity(suitId, commodityId)
	for variantId in pairs(_getGenderVariantIds(suitId)) do
		_setSuitCommodityMapping(variantId, commodityId)

		local suitInfo = AppearanceSuitData[variantId]

		if suitInfo and suitInfo.hair then
			_setSuitCommodityMapping(suitInfo.hair, commodityId)
		end
	end
end

local function _checkAndClearCacheIfNeeded()
	local currentVersion = _getCurrentDataVersion()

	if _cachedDataVersion ~= currentVersion then
		_appearanceToSuitCache = nil
		_jewelryToSuitsCache = nil
		_suitToCommodityCache = nil
		_genderVariantMapCache = nil
		_cachedDataVersion = currentVersion
	end
end

local function _initAppearanceToSuitCache()
	_checkAndClearCacheIfNeeded()

	if _appearanceToSuitCache then
		return
	end

	_appearanceToSuitCache = {}

	for appearanceId, appearanceInfo in pairs(AppearanceData) do
		if appearanceInfo.type == APPEARANCE_TYPE.CLOTHING and appearanceInfo.suit then
			_appearanceToSuitCache[appearanceId] = appearanceInfo.suit
		elseif appearanceInfo.type == APPEARANCE_TYPE.HAIR and appearanceInfo.hairId then
			_appearanceToSuitCache[appearanceId] = appearanceInfo.hairId
		end
	end
end

local function _initJewelryToSuitsCache()
	_checkAndClearCacheIfNeeded()

	if _jewelryToSuitsCache then
		return
	end

	_jewelryToSuitsCache = {}

	for suitId, suitInfo in pairs(AppearanceSuitData) do
		if suitInfo.jewelryList then
			for _, jewelryId in ipairs(suitInfo.jewelryList) do
				if not _jewelryToSuitsCache[jewelryId] then
					_jewelryToSuitsCache[jewelryId] = {}
				end

				table.insert(_jewelryToSuitsCache[jewelryId], suitId)
			end
		end
	end
end

local function _initSuitToCommodityCache()
	_checkAndClearCacheIfNeeded()

	if _suitToCommodityCache then
		return
	end

	_suitToCommodityCache = {}

	for suitId, appearanceList in pairs(ShopmallAppearanceData) do
		local commodityId

		for comId, comInfo in pairs(ShopmallCommodityData) do
			if comInfo.itemId == suitId then
				commodityId = comId

				break
			end
		end

		if commodityId then
			_mapSuitAndGenderVariantsToCommodity(suitId, commodityId)
		end
	end
end

local function _getSuitIdByAppearanceId(appearanceId)
	_initAppearanceToSuitCache()

	return _appearanceToSuitCache[appearanceId]
end

local function _getSuitIdsByJewelryId(jewelryId)
	_initJewelryToSuitsCache()

	return _jewelryToSuitsCache[jewelryId] or {}
end

local function _getCommodityIdBySuitId(suitId)
	_initSuitToCommodityCache()

	return _suitToCommodityCache[suitId]
end

local function _isSuitId(id)
	return AppearanceSuitData[id] ~= nil or AvatarHairSuitData[id] ~= nil
end

local function _isHairSuitId(id)
	return AvatarHairSuitData[id] ~= nil
end

local function _getAppearanceType(id)
	if AppearanceData[id] then
		return AppearanceData[id].type
	end

	if AppearanceJewelryPetData[id] then
		return APPEARANCE_TYPE.JEWELRY
	end

	if AvatarHairSuitData[id] then
		return APPEARANCE_TYPE.HAIR
	end

	if AppearanceSuitData[id] then
		return APPEARANCE_TYPE.CLOTHING
	end

	return nil
end

local function _isCommodityOnSale(commodityInfo)
	if not commodityInfo then
		return false
	end

	if commodityInfo.onSale ~= 1 then
		return false
	end

	local startTime = Utils.getConfigTimeOfArea(commodityInfo, "startTime")
	local endTime = Utils.getConfigTimeOfArea(commodityInfo, "endTime")

	if startTime and endTime then
		return TimeUtils.isInRangeTimestamp(startTime, endTime)
	end

	return true
end

function AppearancePurchaseUtils.GetPurchaseInfo(appearanceId)
	if not appearanceId then
		return nil
	end

	local suitId
	local appearanceType = _getAppearanceType(appearanceId)

	if _isSuitId(appearanceId) then
		suitId = appearanceId

		if _isHairSuitId(appearanceId) then
			appearanceType = APPEARANCE_TYPE.HAIR
		elseif not appearanceType then
			local suitInfo = AppearanceSuitData[appearanceId]

			if suitInfo and suitInfo.appearanceList and #suitInfo.appearanceList > 0 then
				appearanceType = _getAppearanceType(suitInfo.appearanceList[1])
			end
		end
	elseif appearanceType == APPEARANCE_TYPE.CLOTHING then
		suitId = _getSuitIdByAppearanceId(appearanceId)
	elseif appearanceType == APPEARANCE_TYPE.JEWELRY then
		local suitIds = _getSuitIdsByJewelryId(appearanceId)

		if #suitIds > 0 then
			for _, sid in ipairs(suitIds) do
				local commodityId = _getCommodityIdBySuitId(sid)

				if commodityId then
					suitId = sid

					break
				end
			end

			if not suitId then
				suitId = suitIds[1]
			end
		end
	elseif appearanceType == APPEARANCE_TYPE.HAIR then
		suitId = _getSuitIdByAppearanceId(appearanceId)
	elseif appearanceType == APPEARANCE_TYPE.MAKEUP then
		return nil
	else
		return nil
	end

	if not suitId then
		return nil
	end

	local commodityId = _getCommodityIdBySuitId(suitId)

	if not commodityId then
		return nil
	end

	local commodityInfo = ShopmallCommodityData[commodityId]

	if not commodityInfo then
		return nil
	end

	local isOnSale = _isCommodityOnSale(commodityInfo)
	local result = {
		canPurchase = isOnSale,
		commodityId = commodityId,
		suitId = suitId,
		itemId = commodityInfo.itemId,
		appearanceType = appearanceType,
		cost = commodityInfo.cost or {},
		isOnSale = isOnSale,
		isLimited = commodityInfo.limitNum and commodityInfo.limitNum > 0,
		limitNum = commodityInfo.limitNum,
		limitType = commodityInfo.limitType
	}

	if commodityInfo.specialCost and #commodityInfo.specialCost > 0 then
		local specialStartTime = Utils.getConfigTimeOfArea(commodityInfo, "specialStartTime")
		local specialEndTime = Utils.getConfigTimeOfArea(commodityInfo, "specialEndTime")

		if specialStartTime and specialEndTime and TimeUtils.isInRangeTimestamp(specialStartTime, specialEndTime) then
			result.isDiscount = true
			result.originalCost = commodityInfo.cost
			result.cost = commodityInfo.specialCost
		else
			result.isDiscount = false
		end
	else
		result.isDiscount = false
	end

	return result
end

function AppearancePurchaseUtils.GetPurchaseInfoBatch(appearanceIds)
	local result = {}

	for _, appearanceId in ipairs(appearanceIds or EMPTY_TABLE) do
		local info = AppearancePurchaseUtils.GetPurchaseInfo(appearanceId)

		if info then
			result[appearanceId] = info
		end
	end

	return result
end

function AppearancePurchaseUtils.CanPurchase(appearanceId)
	local info = AppearancePurchaseUtils.GetPurchaseInfo(appearanceId)

	return info and info.canPurchase or false
end

function AppearancePurchaseUtils.GetPriceText(appearanceId)
	local info = AppearancePurchaseUtils.GetPurchaseInfo(appearanceId)

	if not info or not info.cost or #info.cost == 0 then
		return nil
	end

	local costInfo = info.cost[1]

	if not costInfo or #costInfo < 2 then
		return nil
	end

	local currencyType = costInfo[1]
	local amount = costInfo[2]
	local ItemData = require("Data.item_data")
	local currencyName = ""

	if ItemData[currencyType] then
		currencyName = ItemData[currencyType].name or ""
	end

	return string.format("%d %s", amount, currencyName)
end

function AppearancePurchaseUtils.GetRequiredItems(appearanceId)
	local info = AppearancePurchaseUtils.GetPurchaseInfo(appearanceId)

	if not info or not info.cost or #info.cost == 0 then
		return nil
	end

	local result = {}

	for _, costInfo in ipairs(info.cost) do
		if costInfo and #costInfo >= 2 then
			table.insert(result, {
				itemId = costInfo[1],
				count = costInfo[2]
			})
		end
	end

	return #result > 0 and result or nil
end

function AppearancePurchaseUtils.GetPurchaseRewardItems(appearanceId)
	local info = AppearancePurchaseUtils.GetPurchaseInfo(appearanceId)

	if not info or not info.suitId then
		return nil
	end

	local suitId = info.suitId
	local result = {}
	local targetSuitId = suitId

	if AvatarHairSuitData[suitId] then
		for appearanceSuitId, suitInfo in pairs(AppearanceSuitData) do
			if suitInfo.hair == suitId then
				targetSuitId = appearanceSuitId

				break
			end
		end
	end

	if AppearanceSuitData[targetSuitId] then
		local suitInfo = AppearanceSuitData[targetSuitId]

		if suitInfo.appearanceList then
			for _, appearanceId in ipairs(suitInfo.appearanceList) do
				table.insert(result, {
					appearanceId,
					1,
					hideOwnNum = true
				})
			end
		end

		if suitInfo.jewelryList then
			for _, jewelryId in ipairs(suitInfo.jewelryList) do
				table.insert(result, {
					jewelryId,
					1,
					hideOwnNum = true
				})
			end
		end

		if suitInfo.hair then
			local hairSuitId = suitInfo.hair

			if AvatarHairSuitData[hairSuitId] then
				local hairSuitInfo = AvatarHairSuitData[hairSuitId]

				if hairSuitInfo.appearanceList then
					for _, hairPartId in ipairs(hairSuitInfo.appearanceList) do
						table.insert(result, {
							hairPartId,
							1,
							hideOwnNum = true
						})
					end
				end
			end
		end
	end

	if targetSuitId == suitId and AvatarHairSuitData[suitId] then
		local hairSuitInfo = AvatarHairSuitData[suitId]

		if hairSuitInfo.appearanceList then
			for _, hairPartId in ipairs(hairSuitInfo.appearanceList) do
				table.insert(result, {
					hairPartId,
					1,
					hideOwnNum = true
				})
			end
		end
	end

	return #result > 0 and result or nil
end

function AppearancePurchaseUtils.ClearCache()
	_appearanceToSuitCache = nil
	_jewelryToSuitsCache = nil
	_suitToCommodityCache = nil
	_genderVariantMapCache = nil
	_cachedDataVersion = nil
end

function AppearancePurchaseUtils.getItemSourceData(itemId)
	local itemData = ItemData[itemId]

	if not itemData then
		return {}
	end

	local filteredSource = itemData.source

	if not filteredSource or #filteredSource <= 0 then
		return {}
	end

	local dataList = {}
	local LuaUIUtils = require("Utils.LuaUIUtils")

	for _, idx in ipairs(filteredSource) do
		local sourceEntry = ItemSourceData[idx]

		if sourceEntry then
			local conditionPass = LuaUIUtils.checkItemSourceCondition(sourceEntry)

			if conditionPass or sourceEntry.showForce == 1 then
				local data = {}

				data.clueSeekID = idx

				table.merge(data, sourceEntry)

				data.conditionPass = conditionPass

				table.insert(dataList, data)
			end
		end
	end

	return dataList
end

function AppearancePurchaseUtils.renderAppearanceItemSourceList(list, sourceData)
	if not sourceData or #sourceData <= 0 then
		return
	end

	local ClientTextUtils = require("Utils.ClientTextUtils")
	local LuaUIUtils = require("Utils.LuaUIUtils")

	function list.luaRenderItem(button, _, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local arrowUImage = objectReference:GetRefValue("arrowUImage")

		ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.buttonTxt))
		LuaUIUtils.itemSourceTrigger(button, data)

		if data.type == LuaUIUtils.ITEM_SOURCE_TYPE_TIPS then
			arrowUImage.gameObject:SetActiveEx(false)
		else
			arrowUImage.gameObject:SetActiveEx(true)
		end
	end

	list:SetList(sourceData)
end

function AppearancePurchaseUtils.isItemClothesSuit(itemId)
	return AppearanceSuitData[itemId] ~= nil
end

function AppearancePurchaseUtils.isItemHairSuit(itemId)
	return AvatarHairSuitData[itemId] ~= nil
end

AppearancePurchaseUtils.APPEARANCE_TYPE = APPEARANCE_TYPE

return AppearancePurchaseUtils
