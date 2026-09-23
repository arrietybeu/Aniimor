-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketSellPet\\TradeMarketSellPetModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("TradeMarketSellPetModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local Const = require("Common.Const.Const")
local TradeItemData = require("Data.trade_items_data")
local PetPriceFactorData = require("Data.pet_price_factor_data")
local TradeMarketUtils = require("Guis.Utils.TradeMarketUtils")
local TradeUtils = require("Common.Utils.TradeUtils")
local Time = require("Core.Common.Time")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local TradeMarketSellPetModel = Class.LightClass("TradeMarketSellPetModel", UIModel)
local PERFECT_PROPERTY_SCORE_STAGE = table.maxn(Const.STAGE_TO_RATING_STR)

function TradeMarketSellPetModel:getPetPriceFactorConfig(pet)
	local isPerfect = (pet.propertyScoreStage or 1) >= PERFECT_PROPERTY_SCORE_STAGE and 1 or 0

	for _, config in pairs(PetPriceFactorData) do
		if config.label == pet.label and (config.isPerfect or 0) == isPerfect then
			return config
		end
	end

	return nil
end

function TradeMarketSellPetModel:getCanSellPetData()
	local petList = {}

	if not pg.me or not pg.me.pets then
		return petList
	end

	local curOADate = TradeMarketUtils.getCurOADate()
	local curTimeTs = Time.secondCache or Time.getSecond()

	for _, pet in pairs(pg.me.pets) do
		local canSell, priceFactorConfig = self:canSell(pet, curOADate)

		if canSell then
			local petData = PetManagementDataHelper.setUpPetInfo(pet)
			local petManage = pg.game and pg.game.petManage
			local isCultivated = petManage and petManage.hasPetCultivation and petManage:hasPetCultivation(pet.id) or false
			local carryPosMap = pg.me.petCoreCarryPosMap
			local coreCarryPos = carryPosMap and carryPosMap:getItemPos(pet.id)
			local hasCarryItem = coreCarryPos and coreCarryPos:isValid() or false
			local needWash = isCultivated or hasCarryItem
			local frozenEndTs = TradeUtils.getPetTradeFreezeEndTs(pet)
			local isFrozen = curTimeTs < frozenEndTs
			local sellDisabledReasonKey

			if isFrozen then
				sellDisabledReasonKey = "TRADE_FREEZE_NO_SELL"
			elseif needWash then
				sellDisabledReasonKey = "TRADE_PET_HAS_RAISE_CANNOT_SELL"
			end

			petData.tradeConfig = TradeItemData[pet.templateId]
			petData.priceFactorConfig = priceFactorConfig
			petData.priceFactor = priceFactorConfig and priceFactorConfig.priceFactor or 1
			petData.isCultivated = isCultivated
			petData.hasCarryItem = hasCarryItem
			petData.needWash = needWash
			petData.isFrozen = isFrozen
			petData.frozenEndTs = isFrozen and frozenEndTs or nil
			petData.sellDisabledReasonKey = sellDisabledReasonKey
			petData.canSell = sellDisabledReasonKey == nil
			petList[#petList + 1] = petData
		end
	end

	return petList
end

function TradeMarketSellPetModel:getSellingData(listings)
	local sellingData = {}

	for _, listing in ipairs(listings or EMPTY_TABLE) do
		if listing.displayType == TradeMarketUtils.SubPageType.Pet then
			sellingData[#sellingData + 1] = listing
		end
	end

	local sellingCount = #sellingData
	local sellMaxCount = TradeMarketUtils.getPetSellMaxCount()

	for _ = sellingCount + 1, sellMaxCount do
		sellingData[#sellingData + 1] = {
			isEmpty = true
		}
	end

	return sellingData, sellingCount
end

function TradeMarketSellPetModel:canSell(pet, curOADate)
	if not pet or not pet.templateId then
		return false
	end

	if PetTransmogUtils.getTransmogProgress(pet.id) > 0 then
		return false
	end

	curOADate = curOADate or TradeMarketUtils.getCurOADate()

	local tradeConfig = TradeItemData[pet.templateId]

	if not tradeConfig or tradeConfig.displayType ~= TradeMarketUtils.SubPageType.Pet then
		return false
	end

	local startTime = tonumber(tradeConfig.startTime)

	if startTime and startTime > 0 and curOADate < startTime then
		return false
	end

	if tradeConfig.needCanTrade == 1 and not TradeUtils.isPetCanTrade(pet) then
		return false
	end

	local petBoxMap = pg.me and pg.me.petBoxMap
	local boxIndex = petBoxMap and pet.id and petBoxMap:getPetIndex(pet.id)
	local petBoxInfo = boxIndex and petBoxMap[boxIndex]

	if petBoxInfo and petBoxInfo:isLocked() then
		return false
	end

	local petManagementModel = pg.global.ui.petManagement.model
	local lockStatus = petManagementModel:getLockStatus(pet)

	if lockStatus.isValidFavorite or lockStatus.inBattle or lockStatus.inExplore or lockStatus.isSpecial or lockStatus.isInHomeland or lockStatus.isActivityDipatching or lockStatus.inRogue then
		return false
	end

	if pet.isTrial then
		return false
	end

	local priceFactorConfig = self:getPetPriceFactorConfig(pet)

	if tradeConfig.needUnlock == 1 and not priceFactorConfig then
		return false
	end

	if pet.isCatchReporting and pet:isCatchReporting() then
		return false
	end

	return true, priceFactorConfig
end

return TradeMarketSellPetModel
