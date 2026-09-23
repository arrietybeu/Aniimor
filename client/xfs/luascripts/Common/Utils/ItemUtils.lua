-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\ItemUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local lume = require("Core.Common.lume")
local logger = LoggerManager.getLogger("ItemUtils")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local ItemConst = require("Common.Const.ItemConst")
local ItemTTLUtils = require("Common.Utils.ItemTTLUtils")
local NoticeDef = require("Common.NoticeDef")
local ItemData = require("Data.item_data")
local ItemEffectData = require("Data.item_effect_data")
local CastItemData = require("Data.cast_item_data")
local SysEventData = require("Data.sys_event_data")
local SysConfigData = require("Data.sys_config_data")
local PetEvolveItemSubData = require("Data.pet_evolve_item_sub_data")
local PlayerSkillData = require("Data.player_skill_data")
local PlayerSkillTreeData = require("Data.player_skill_tree_data")
local CommonMoneyMap = require("Data.common_money_map")
local PetReleaseData = require("Data.pet_release_data")
local PlayerSkillTreeData = require("Data.player_skill_tree_data")
local CoreCarryData = require("Data.core_carry_data")
local AssistCarryData = require("Data.assist_carry_data")
local PetConfigData = require("Data.pet_config_data")
local PetData = require("Data.pet_data")
local SocialTypeData = require("Data.social_type_data")
local ItemFormChangeMapData = require("Data.item_form_change_map")
local ItemConditionConvertData = require("Data.item_condition_convert_data")
local RobEggEquipData = require("Data.robegg_equip_data")
local RobEggItemIn = require("Data.rob_egg_item_in")
local ItemConstSourceData = require("Data.item_const_source_data")
local TimeUtils = require("Common.Utils.TimeUtils")
local Time = require("Core.Common.Time")
local FormulaData = require("Data.formula_data")
local RobEggBookAntiqueData = require("Data.egg_book_antique_data")
local RobEggCollectionRefine = require("Data.rob_egg_collection_calcine_data")
local RobEggCollectionRankData = require("Data.rob_egg_collection_calcine_rank_data")
local RobEggItemOut = require("Data.rob_egg_item_out")
local CollectItemData = require("Data.collect_item_data")
local RobEggCollectionTagData = require("Data.rob_egg_collection_tag_data")
local RobEggCollectionVariantModelData = require("Data.rob_egg_collection_variant_model_data")
local RobEggRepairKitData = require("Data.robegg_repair_kit_data")
local ItemUtils = {}
local pairs = pairs
local ipairs = ipairs
local math_min = math.min
local math_max = math.max
local math_ceil = math.ceil
local SUPPORTED_INV_FIELD_BY_ID = {
	[ItemConst.INV_TYPE_PLAYER] = "playerItemBag",
	[ItemConst.INV_TYPE_PET] = "petItemBag",
	[ItemConst.INV_TYPE_BALL] = "ballItemBag",
	[ItemConst.INV_TYPE_COMMON] = "commonItemBag",
	[ItemConst.INV_TYPE_TASK] = "taskItemBag",
	[ItemConst.INV_TYPE_PET_JEWELRY] = "petJewelryItemBag",
	[ItemConst.INV_TYPE_HOMELAND] = "homelandItemBag",
	[ItemConst.INV_TYPE_HOMELAND_FURNITURE] = "homelandFurnitureItemBag",
	[ItemConst.INV_TYPE_ROB_EGG] = "robEggItemBag",
	[ItemConst.INV_TYPE_ROB_EGG_WAREHOUSE] = "robEggWarehouseItemBag",
	[ItemConst.INV_TYPE_EQUIP_SLOTS] = "equipSlotsItemBag",
	[ItemConst.INV_TYPE_RESERVED] = "reservedItemBag",
	[ItemConst.INV_TYPE_FRAGMENT] = "fragmentItemBag"
}
local SUPPORTED_ITEM_CLASS_BY_INV_ID = {
	[ItemConst.INV_TYPE_PLAYER] = "CustomTypes.InventoryItem.PlayerItem",
	[ItemConst.INV_TYPE_PET] = "CustomTypes.InventoryItem.PetItem",
	[ItemConst.INV_TYPE_BALL] = "CustomTypes.InventoryItem.BallItem",
	[ItemConst.INV_TYPE_COMMON] = "CustomTypes.InventoryItem.CommonItem",
	[ItemConst.INV_TYPE_TASK] = "CustomTypes.InventoryItem.TaskItem",
	[ItemConst.INV_TYPE_PET_JEWELRY] = "CustomTypes.InventoryItem.PetJewelryItem",
	[ItemConst.INV_TYPE_HOMELAND] = "CustomTypes.InventoryItem.HomelandItem",
	[ItemConst.INV_TYPE_HOMELAND_FURNITURE] = "CustomTypes.InventoryItem.HomelandFurnitureItem",
	[ItemConst.INV_TYPE_ROB_EGG] = "CustomTypes.InventoryItem.RobEggItem",
	[ItemConst.INV_TYPE_ROB_EGG_WAREHOUSE] = "CustomTypes.InventoryItem.RobEggItem",
	[ItemConst.INV_TYPE_EQUIP_SLOTS] = "CustomTypes.InventoryItem.RobEggItem",
	[ItemConst.INV_TYPE_RESERVED] = "CustomTypes.InventoryItem.ReservedItem",
	[ItemConst.INV_TYPE_FRAGMENT] = "CustomTypes.InventoryItem.FragmentItem"
}
local INV_TYPES_WITH_PROPS = {
	[ItemConst.INV_TYPE_PLAYER] = true,
	[ItemConst.INV_TYPE_PET] = true,
	[ItemConst.INV_TYPE_BALL] = true,
	[ItemConst.INV_TYPE_COMMON] = true,
	[ItemConst.INV_TYPE_TASK] = true,
	[ItemConst.INV_TYPE_HOMELAND] = true,
	[ItemConst.INV_TYPE_HOMELAND_FURNITURE] = true,
	[ItemConst.INV_TYPE_ROB_EGG] = true,
	[ItemConst.INV_TYPE_ROB_EGG_WAREHOUSE] = true,
	[ItemConst.INV_TYPE_EQUIP_SLOTS] = true,
	[ItemConst.INV_TYPE_RESERVED] = true,
	[ItemConst.INV_TYPE_FRAGMENT] = true
}

function ItemUtils.getUseItemConsumeSource(itemId, source)
	if itemId == ItemConst.SHINY_CHANGE_ITEM_ID then
		return ItemConstSourceData.ITEM_SOURCE_SHINY_CHANGE_COST
	elseif itemId == ItemConst.SHINY_REFRESH_ITEM_ID then
		return ItemConstSourceData.ITEM_SOURCE_SHINY_PAY_CHANGE_COST
	end

	return source
end

function ItemUtils.getSupportedInvFieldById(invId)
	return SUPPORTED_INV_FIELD_BY_ID[invId]
end

function ItemUtils.isSupportedTypedInvId(invId)
	return SUPPORTED_INV_FIELD_BY_ID[invId] ~= nil
end

function ItemUtils.getTypedBag(playerEnt, invId)
	local fieldName = SUPPORTED_INV_FIELD_BY_ID[invId]

	return fieldName and playerEnt and playerEnt[fieldName] or nil
end

function ItemUtils.getTypedItemClassByInvId(invId)
	return SUPPORTED_ITEM_CLASS_BY_INV_ID[invId]
end

function ItemUtils.requireTypedItemClassByInvId(invId)
	local moduleName = SUPPORTED_ITEM_CLASS_BY_INV_ID[invId]

	if not moduleName then
		return nil
	end

	return require(moduleName)
end

function ItemUtils.invTypeHasProps(invId)
	return INV_TYPES_WITH_PROPS[invId] == true
end

function ItemUtils.restoreItemTTL(item, invId)
	if not item then
		return false
	end

	invId = invId or item.getInvID and item:getInvID()

	if not ItemUtils.isSupportedTypedInvId(invId) or invId == ItemConst.INV_TYPE_PET_JEWELRY then
		return true
	end

	return ItemTTLUtils.restoreFromProps(item, ItemData[item.id], Time.secondCache, invId)
end

function ItemUtils.eachSupportedTypedBag(playerEnt, callback)
	for invId, fieldName in pairs(SUPPORTED_INV_FIELD_BY_ID) do
		local bag = playerEnt and playerEnt[fieldName]

		if bag then
			callback(invId, bag, fieldName)
		end
	end
end

ItemUtils.MONEY_NAME = {
	[ItemConst.ITEM_SPECIAL_MONEY_COIN_BOUND] = "boundMoney",
	[ItemConst.ITEM_SPECIAL_MONEY_COIN] = "unboundMoney",
	[ItemConst.ITEM_SPECIAL_MONEY_CASH_BOUND] = "boundRmbMoney",
	[ItemConst.ITEM_SPECIAL_MONEY_CASH] = "unboundRmbMoney"
}
ItemUtils.INSENSITIVE_MONEY_TYPE = {
	[ItemConst.ITEM_SPECIAL_MONEY_COIN_INSENSITIVE] = {
		PRIMARY = ItemConst.ITEM_SPECIAL_MONEY_COIN_BOUND,
		SECONDARY = ItemConst.ITEM_SPECIAL_MONEY_COIN
	},
	[ItemConst.ITEM_SPECIAL_MONEY_CASH_INSENSITIVE] = {
		PRIMARY = ItemConst.ITEM_SPECIAL_MONEY_CASH_BOUND,
		SECONDARY = ItemConst.ITEM_SPECIAL_MONEY_CASH
	}
}
ItemUtils.NEGATIVE_MONEY_TYPE = {
	[ItemConst.ITEM_SPECIAL_MONEY_COIN_BOUND] = true,
	[ItemConst.ITEM_SPECIAL_MONEY_COIN] = true,
	[ItemConst.ITEM_SPECIAL_MONEY_CASH_BOUND] = true,
	[ItemConst.ITEM_SPECIAL_MONEY_CASH] = true,
	[ItemConst.ITEM_SPECIAL_ROGUE_COIN] = true,
	[ItemConst.ITEM_SPECIAL_MONEY_ROBEGG] = true,
	[ItemConst.ITEM_SPECIAL_MONEY_HOME_VOUCHER] = true,
	[ItemConst.ITEM_SPECIAL_MONEY_HOME] = true,
	[ItemConst.ITEM_SPECIAL_MONEY_PAW] = true,
	[ItemConst.ITEM_SPECIAL_RESEARCH_EIDEL] = true
}

function ItemUtils.adjustCostIdNumsWithBoundCashFallback(player, costIdNums)
	if not player then
		return false, costIdNums
	end

	local needCoinBound = costIdNums[ItemConst.ITEM_SPECIAL_MONEY_COIN_BOUND] or 0

	if needCoinBound <= 0 then
		return true, costIdNums
	end

	local ownCoinBound = player:getMoneyNum(ItemConst.ITEM_SPECIAL_MONEY_COIN_BOUND)

	if ownCoinBound < 0 then
		return false, costIdNums
	end

	if needCoinBound <= ownCoinBound then
		return true, costIdNums
	end

	local deficit = needCoinBound - ownCoinBound
	local ownCashBound = player:getMoneyNum(ItemConst.ITEM_SPECIAL_MONEY_CASH_BOUND)

	if ownCashBound < deficit then
		return false, costIdNums
	end

	if ownCoinBound > 0 then
		costIdNums[ItemConst.ITEM_SPECIAL_MONEY_COIN_BOUND] = ownCoinBound
	else
		costIdNums[ItemConst.ITEM_SPECIAL_MONEY_COIN_BOUND] = nil
	end

	costIdNums[ItemConst.ITEM_SPECIAL_MONEY_CASH_BOUND] = (costIdNums[ItemConst.ITEM_SPECIAL_MONEY_CASH_BOUND] or 0) + deficit

	return true, costIdNums
end

function ItemUtils.calcLevelCostBreakdown(costs, levelCost, curLevelCount, num, calcFinalOnePrice)
	for _, costItem in ipairs(costs) do
		costItem.totalPrice = 0
	end

	local lastNum = num
	local curCount = curLevelCount or 0
	local prevThreshold

	for _, levelCostRow in ipairs(levelCost) do
		if #levelCostRow ~= #costs + 1 then
			logger:error("calcLevelCostBreakdown fail levelCost dim error, #levelCostRow=%s, #costs=%s", #levelCostRow, #costs)

			return NoticeDef.SHOP_CONFIG_PARAM_ERROR, nil
		end

		if prevThreshold and prevThreshold >= levelCostRow[1] then
			logger:error("calcLevelCostBreakdown fail levelCost threshold not ascending, prev=%s, cur=%s", prevThreshold, levelCostRow[1])

			return NoticeDef.SHOP_CONFIG_PARAM_ERROR, nil
		end

		prevThreshold = levelCostRow[1]

		local count = levelCostRow[1] - 1
		local lastCount = curCount + lastNum - count

		if lastCount > 0 then
			if curCount < count then
				for _, costItem in ipairs(costs) do
					costItem.totalPrice = costItem.totalPrice + (count - curCount) * costItem.onePrice
				end

				lastNum = lastNum - (count - curCount)
				curCount = count
			end
		else
			break
		end

		for index, costItem in ipairs(costs) do
			local newOnePrice = levelCostRow[index + 1]

			if calcFinalOnePrice then
				local ok, finalOnePrice = calcFinalOnePrice(costItem.itemId, newOnePrice)

				if not ok then
					logger:error("calcLevelCostBreakdown fail finalOnePrice invalid itemId=%s onePrice=%s", costItem.itemId, newOnePrice)

					return NoticeDef.SHOP_CONFIG_PARAM_ERROR, nil
				end

				newOnePrice = finalOnePrice
			end

			costItem.onePrice = newOnePrice
		end
	end

	for _, costItem in ipairs(costs) do
		costItem.totalPrice = costItem.totalPrice + lastNum * costItem.onePrice
	end

	return NoticeDef.SUCCESS, costs
end

local bindTypeList = {
	Const.INV_BOUND_TYPE_INSENSITIVE,
	Const.INV_BOUND_TYPE_BOUND,
	Const.INV_BOUND_TYPE_UNBOUND
}
local bindTypeKeySet = {
	[Const.INV_BOUND_TYPE_BOUND] = true,
	[Const.INV_BOUND_TYPE_UNBOUND] = true,
	[Const.INV_BOUND_TYPE_INSENSITIVE] = true
}

function ItemUtils.isBind2BoundType(isBind)
	return Const.INV_BOUND_TYPE_BOUND
end

function ItemUtils.boundType2IsBind(boundType)
	return true
end

function ItemUtils.isLock2LockedType(isLock)
	return isLock and Const.ITEM_LOCKED_YES or Const.ITEM_LOCKED_NOT
end

function ItemUtils.lockedType2IsLock(lockedType)
	return lockedType == Const.ITEM_LOCKED_YES
end

function ItemUtils.calcDropNumWithRate(info, rate, roundFunc)
	roundFunc = roundFunc or math.round
	info[Const.INV_BOUND_TYPE_INSENSITIVE] = roundFunc(info[Const.INV_BOUND_TYPE_INSENSITIVE] * rate)
	info[Const.INV_BOUND_TYPE_BOUND] = roundFunc(info[Const.INV_BOUND_TYPE_BOUND] * rate)
	info[Const.INV_BOUND_TYPE_UNBOUND] = roundFunc(info[Const.INV_BOUND_TYPE_UNBOUND] * rate)
end

function ItemUtils.calcDropNumWithAttrPV(info, attrP, attrV, roundFunc)
	roundFunc = roundFunc or math.round
	info[Const.INV_BOUND_TYPE_INSENSITIVE] = roundFunc(info[Const.INV_BOUND_TYPE_INSENSITIVE] * (1 + attrP) + attrV)
	info[Const.INV_BOUND_TYPE_BOUND] = roundFunc(info[Const.INV_BOUND_TYPE_BOUND] * (1 + attrP) + attrV)
	info[Const.INV_BOUND_TYPE_UNBOUND] = roundFunc(info[Const.INV_BOUND_TYPE_UNBOUND] * (1 + attrP) + attrV)
end

function ItemUtils.multipleIdNumDict(idNumDict, multiples, roundFunc)
	roundFunc = roundFunc or math.round
	multiples = multiples or 1

	if not multiples or multiples < 0 then
		ALARM("multipleIdNumDict invalid, multiples=%s", tostring(multiples))

		return
	end

	local calcDropNumWithRate = ItemUtils.calcDropNumWithRate

	for _, v in pairs(idNumDict) do
		calcDropNumWithRate(v, multiples, roundFunc)
	end
end

local function safe_round_func(func)
	if func == math.ceil then
		return math.safe_ceil
	elseif func == math.floor then
		return math.safe_floor
	else
		return func or math.round
	end
end

function ItemUtils.multiplePetCreateInfo(petCreateInfo, multiples, roundFunc)
	roundFunc = safe_round_func(roundFunc)
	multiples = multiples or 1

	if not petCreateInfo or not next(petCreateInfo) then
		return
	end

	if not multiples or multiples < 1 or multiples > 100 then
		ALARM("multiplePetCreateInfo invalid, multiples=%s", tostring(multiples))

		return
	end

	local originPetCreateInfo = Utils.deepCopyTable(petCreateInfo)

	for i = 2, roundFunc(multiples) do
		lume.append(petCreateInfo, Utils.deepCopyTable(originPetCreateInfo))
	end
end

function ItemUtils.genItemCountBindInfo()
	return {
		[Const.INV_BOUND_TYPE_BOUND] = {
			[Const.ITEM_LOCKED_YES] = 0,
			[Const.ITEM_LOCKED_NOT] = 0
		},
		[Const.INV_BOUND_TYPE_UNBOUND] = {
			[Const.ITEM_LOCKED_YES] = 0,
			[Const.ITEM_LOCKED_NOT] = 0
		}
	}
end

function ItemUtils.modifyItemCountToRet(ret, itemId, countOffset, isLock)
	if not countOffset or countOffset == 0 then
		return ret
	end

	local countPair = ret[itemId]

	if not countPair then
		countPair = ItemUtils.genItemCountBindInfo()
		ret[itemId] = countPair
	end

	local boundType = Const.INV_BOUND_TYPE_BOUND
	local lockedType = ItemUtils.isLock2LockedType(isLock)

	countPair[boundType][lockedType] = (countPair[boundType][lockedType] or 0) + countOffset
end

function ItemUtils.getItemCountFromCountPair(countPair, includeLocked)
	if countPair == nil then
		return 0
	end

	local total = 0

	total = total + (countPair[Const.INV_BOUND_TYPE_BOUND] and countPair[Const.INV_BOUND_TYPE_BOUND][Const.ITEM_LOCKED_NOT] or 0)
	total = total + (countPair[Const.INV_BOUND_TYPE_UNBOUND] and countPair[Const.INV_BOUND_TYPE_UNBOUND][Const.ITEM_LOCKED_NOT] or 0)

	if includeLocked then
		total = total + (countPair[Const.INV_BOUND_TYPE_BOUND] and countPair[Const.INV_BOUND_TYPE_BOUND][Const.ITEM_LOCKED_YES] or 0)
		total = total + (countPair[Const.INV_BOUND_TYPE_UNBOUND] and countPair[Const.INV_BOUND_TYPE_UNBOUND][Const.ITEM_LOCKED_YES] or 0)
	end

	return total
end

function ItemUtils.getItemCountFromCountPairWithBind(countPair, includeLocked)
	if countPair == nil then
		return 0
	end

	local countInfo = countPair[ItemUtils.isBind2BoundType(true)]
	local total = countInfo and countInfo[Const.ITEM_LOCKED_NOT] or 0

	if includeLocked then
		total = total + (countInfo and countInfo[Const.ITEM_LOCKED_YES] or 0)
	end

	return total
end

function ItemUtils.genItemNumInfo(insensitive, bound, unbound)
	return {
		[Const.INV_BOUND_TYPE_INSENSITIVE] = insensitive or 0,
		[Const.INV_BOUND_TYPE_BOUND] = bound or 0,
		[Const.INV_BOUND_TYPE_UNBOUND] = unbound or 0
	}
end

function ItemUtils.addItemInfoToRet(ret, itemId, itemCount, bindType)
	bindType = bindType or Const.INV_BOUND_TYPE_INSENSITIVE

	if not itemCount or itemCount == 0 then
		return ret
	end

	local itemInfo = ret[itemId]

	if not itemInfo then
		itemInfo = ItemUtils.genItemNumInfo(0, 0, 0)
		ret[itemId] = itemInfo
	end

	itemInfo[bindType] = (itemInfo[bindType] or 0) + itemCount

	if ItemUtils.getItemCountFromNumInfo(itemInfo) == 0 then
		ret[itemId] = nil
	end

	return ret
end

function ItemUtils.itemList2Dict(itemInfoList, multiples, roundFunc)
	local idNumDict = ItemUtils.itemList2DictRaw(itemInfoList, multiples, roundFunc)

	return ItemUtils.formatIdNumBoundDict(idNumDict)
end

function ItemUtils.itemList2DictRaw(itemInfoList, multiples, roundFunc)
	if not itemInfoList or #itemInfoList == 0 then
		return {}
	end

	multiples = multiples or 1
	roundFunc = roundFunc or math.round

	local idNumDict = {}

	for _, itemInfo in ipairs(itemInfoList or EMPTY_TABLE) do
		local itemId, itemNum = itemInfo[1], itemInfo[2]

		idNumDict[itemId] = (idNumDict[itemId] or 0) + roundFunc(itemNum * multiples)
	end

	return idNumDict
end

function ItemUtils.mergeNumInfo(targetNumInfo, sourceNumInfo)
	for _, bindType in ipairs(bindTypeList) do
		if sourceNumInfo[bindType] then
			targetNumInfo[bindType] = (targetNumInfo[bindType] or 0) + sourceNumInfo[bindType]
		end
	end
end

function ItemUtils.mergeItemInfoResult(targetDict, sourceDict)
	for itemId, numberInfo in pairs(sourceDict) do
		for _, bindType in ipairs(bindTypeList) do
			if numberInfo[bindType] then
				ItemUtils.addItemInfoToRet(targetDict, itemId, numberInfo[bindType], bindType)
			end
		end
	end
end

function ItemUtils.exceptItemInfoResult(targetDict, exceptDict)
	for itemId, numberInfo in pairs(exceptDict) do
		for _, bindType in ipairs(bindTypeList) do
			if numberInfo[bindType] then
				ItemUtils.addItemInfoToRet(targetDict, itemId, -numberInfo[bindType], bindType)
			end
		end
	end
end

function ItemUtils.getItemCountFromNumInfo(numInfo)
	if type(numInfo) == "table" then
		return (numInfo[Const.INV_BOUND_TYPE_INSENSITIVE] or 0) + (numInfo[Const.INV_BOUND_TYPE_BOUND] or 0) + (numInfo[Const.INV_BOUND_TYPE_UNBOUND] or 0)
	else
		return numInfo or 0
	end
end

function ItemUtils.getItemCountTable(idNumBoundDict)
	local res = {}

	for itemId, numInfo in pairs(idNumBoundDict) do
		res[itemId] = ItemUtils.getItemCountFromNumInfo(numInfo)
	end

	return res
end

function ItemUtils.getItemCountTableFromNotifyList(notifyList)
	local result = {}

	for _, notifyInfo in ipairs(notifyList or EMPTY_TABLE) do
		for itemId, num in pairs(ItemUtils.getItemCountTable(notifyInfo[1])) do
			result[itemId] = (result[itemId] or 0) + num
		end
	end

	return result
end

function ItemUtils.genItemRangeNumInfo(insensitive, bound, unbound)
	return {
		[Const.INV_BOUND_TYPE_INSENSITIVE] = {
			insensitive,
			insensitive
		},
		[Const.INV_BOUND_TYPE_BOUND] = {
			bound,
			bound
		},
		[Const.INV_BOUND_TYPE_UNBOUND] = {
			unbound,
			unbound
		}
	}
end

function ItemUtils.addItemRangeInfoToRet(ret, itemId, minNum, maxNum, bindType, isMerge)
	bindType = bindType or Const.INV_BOUND_TYPE_INSENSITIVE

	if not itemId or not minNum or not maxNum then
		return ret
	end

	local itemRangeInfo = ret[itemId]

	if not itemRangeInfo then
		itemRangeInfo = ItemUtils.genItemRangeNumInfo(0, 0, 0)
		ret[itemId] = itemRangeInfo
	end

	local range = itemRangeInfo[bindType]

	if isMerge then
		range[1] = math_min(range[1], minNum)
		range[2] = math_max(range[2], maxNum)
	else
		range[1] = range[1] + minNum
		range[2] = range[2] + maxNum
	end

	return ret
end

function ItemUtils.getItemRangeFromRangeNumInfo(rangeNumInfo)
	if type(rangeNumInfo) == "table" then
		return {
			(rangeNumInfo[Const.INV_BOUND_TYPE_INSENSITIVE] and rangeNumInfo[Const.INV_BOUND_TYPE_INSENSITIVE][1] or 0) + (rangeNumInfo[Const.INV_BOUND_TYPE_BOUND] and rangeNumInfo[Const.INV_BOUND_TYPE_BOUND][1] or 0) + (rangeNumInfo[Const.INV_BOUND_TYPE_UNBOUND] and rangeNumInfo[Const.INV_BOUND_TYPE_UNBOUND][1] or 0),
			(rangeNumInfo[Const.INV_BOUND_TYPE_INSENSITIVE] and rangeNumInfo[Const.INV_BOUND_TYPE_INSENSITIVE][2] or 0) + (rangeNumInfo[Const.INV_BOUND_TYPE_BOUND] and rangeNumInfo[Const.INV_BOUND_TYPE_BOUND][2] or 0) + (rangeNumInfo[Const.INV_BOUND_TYPE_UNBOUND] and rangeNumInfo[Const.INV_BOUND_TYPE_UNBOUND][2] or 0)
		}
	else
		return {
			rangeNumInfo,
			rangeNumInfo
		}
	end
end

function ItemUtils.splitRangeInfo2NumInfo(itemRangeInfo)
	local minItemNum = {}
	local maxItemNum = {}

	for itemId, rangeInfo in pairs(itemRangeInfo) do
		for boundType, range in pairs(rangeInfo) do
			local minNum, maxNum = range[1], range[2]

			minItemNum[itemId] = minItemNum[itemId] or {
				0,
				0,
				0
			}
			minItemNum[itemId][boundType] = minItemNum[itemId][boundType] + minNum
			maxItemNum[itemId] = maxItemNum[itemId] or {
				0,
				0,
				0
			}
			maxItemNum[itemId][boundType] = maxItemNum[itemId][boundType] + maxNum
		end
	end

	return minItemNum, maxItemNum
end

function ItemUtils.checkIdNumDict(idNumDict)
	local getInvIdByItemId = ItemUtils.getInvIdByItemId
	local getItemCountFromNumInfo = ItemUtils.getItemCountFromNumInfo

	for itemId, numInfo in pairs(idNumDict) do
		if getInvIdByItemId(itemId) == nil then
			return false
		end

		if type(numInfo) == "table" then
			for k, _ in pairs(bindTypeKeySet) do
				if numInfo[k] == nil then
					ALARM(string.format("not have bindType:%s", tostring(k)))

					return false
				end
			end

			for k, _ in pairs(numInfo) do
				if not bindTypeKeySet[k] then
					ALARM(string.format("invalid bindType:%s", tostring(k)))

					return false
				end
			end
		elseif type(numInfo) ~= "number" then
			return false
		end

		if getItemCountFromNumInfo(numInfo) < 0 then
			return false
		end
	end

	return true
end

function ItemUtils.formatIdNumBoundDict(idNumDict, needCopy)
	local ret = {}
	local getItemCountFromNumInfo = ItemUtils.getItemCountFromNumInfo

	for k, v in pairs(idNumDict) do
		if type(v) == "number" then
			ret[k] = ItemUtils.genItemNumInfo(v, 0, 0)
		else
			ret[k] = needCopy and Utils.deepCopyTable(v) or v
		end

		if getItemCountFromNumInfo(ret[k]) == 0 then
			ret[k] = nil
		end
	end

	return ret
end

function ItemUtils.formatIdNumBoundDictInv(idNumDict, needCopy)
	local ret = {}

	for k, v in pairs(idNumDict) do
		local invId = ItemUtils.getInvIdByItemId(k)

		if invId ~= nil then
			ret[invId] = ret[invId] or {}

			local idNum = ret[invId]

			if type(v) == "number" then
				idNum[k] = ItemUtils.genItemNumInfo(v, 0, 0)
			else
				idNum[k] = needCopy and Utils.deepCopyTable(v) or v
			end
		else
			ALARM(string.format("item:%d no invId", k))
		end
	end

	return ret
end

function ItemUtils.negativeIdNumBoundDict(idNumDict)
	local ret = ItemUtils.formatIdNumBoundDict(idNumDict, true)

	for k, v in pairs(idNumDict) do
		for bindType, num in pairs(v) do
			if num and num > 0 then
				ret[k][bindType] = -num
			end
		end
	end

	return ret
end

function ItemUtils.positiveIdNumBoundDict(idNumDict)
	local ret = ItemUtils.formatIdNumBoundDict(idNumDict, true)

	for k, v in pairs(idNumDict) do
		for bindType, num in pairs(v) do
			if num and num < 0 then
				ret[k][bindType] = -num
			end
		end
	end

	return ret
end

function ItemUtils.getInvIdByItemId(itemId)
	local idd = ItemData[itemId]

	return idd and idd.invId
end

function ItemUtils.hasExpiredTimeItem(itemId)
	local idd = ItemData[itemId]

	return idd and idd.ttlType and idd.ttlType ~= 0
end

function ItemUtils.getItemStackCount(itemId)
	local idd = ItemData[itemId]
	local ied = ItemEffectData[itemId]

	if idd == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("config error, itemId=%s", tostring(itemId))
		end

		return 1
	end

	if ied and ied.reuseTimes and ied.reuseTimes > 1 then
		return 1
	end

	if ItemUtils.needGenPropertyOnInit(itemId) then
		return 1
	end

	return idd.stackcount or 1
end

function ItemUtils.isItemForceBound(itemId)
	local invId = ItemUtils.getInvIdByItemId(itemId)

	if invId == ItemConst.INV_TYPE_SPECIAL or invId == ItemConst.INV_TYPE_TASK or invId == ItemConst.INV_TYPE_AUTOUSE then
		return true
	end

	return false
end

function ItemUtils.isPetAppearanceItem(itemId)
	return ItemUtils.getInvIdByItemId(itemId) == ItemConst.INV_TYPE_PET_JEWELRY
end

function ItemUtils.getPetAppearanceCount(player)
	local bag = ItemUtils.getTypedBag(player, ItemConst.INV_TYPE_PET_JEWELRY)

	return bag and bag:getCount() or 0
end

function ItemUtils.solveBoundAndInvOnDel(idNumBoundDict, itemCountBindMap, canDelLocked)
	return ItemUtils.formatIdNumBoundDictInv(ItemUtils.solveBoundOnDel(idNumBoundDict, itemCountBindMap, canDelLocked))
end

function ItemUtils.solveBoundOnDel(idNumBoundDict, itemCountBindMap, canDelLocked)
	local idNumBoundDict = ItemUtils.formatIdNumBoundDict(idNumBoundDict, true)
	local INV_BOUND_TYPE_INSENSITIVE = Const.INV_BOUND_TYPE_INSENSITIVE
	local INV_BOUND_TYPE_BOUND = Const.INV_BOUND_TYPE_BOUND
	local INV_BOUND_TYPE_UNBOUND = Const.INV_BOUND_TYPE_UNBOUND

	for itemId, numberInfo in pairs(idNumBoundDict) do
		local totalNum = ItemUtils.getItemCountFromNumInfo(numberInfo)

		numberInfo[INV_BOUND_TYPE_INSENSITIVE] = nil
		numberInfo[INV_BOUND_TYPE_BOUND] = totalNum
		numberInfo[INV_BOUND_TYPE_UNBOUND] = 0
	end

	return idNumBoundDict
end

function ItemUtils.solveBoundAndInvOnAdd(idNumBoundDict)
	return ItemUtils.formatIdNumBoundDictInv(ItemUtils.solveBoundOnAdd(idNumBoundDict))
end

function ItemUtils.solveBoundOnAdd(idNumBoundDict)
	local idNumBoundDict = ItemUtils.formatIdNumBoundDict(idNumBoundDict, true)
	local INV_BOUND_TYPE_INSENSITIVE = Const.INV_BOUND_TYPE_INSENSITIVE
	local INV_BOUND_TYPE_BOUND = Const.INV_BOUND_TYPE_BOUND
	local INV_BOUND_TYPE_UNBOUND = Const.INV_BOUND_TYPE_UNBOUND

	for itemId, numberInfo in pairs(idNumBoundDict) do
		local totalNum = ItemUtils.getItemCountFromNumInfo(numberInfo)

		numberInfo[INV_BOUND_TYPE_INSENSITIVE] = nil
		numberInfo[INV_BOUND_TYPE_BOUND] = totalNum
		numberInfo[INV_BOUND_TYPE_UNBOUND] = 0
	end

	return idNumBoundDict
end

function ItemUtils.genItems(idNumBoundDict, extraPropDict, equipmentBindPetIdMap)
	local items = {}
	local factory = require("Common.ItemBag.ItemFactory").GetInstance()

	local function funcGenAndPushItem(itemId, itemCount)
		local idd = ItemData[itemId]

		if itemCount and itemCount ~= 0 and idd ~= nil then
			local equipmentBindPetId = equipmentBindPetIdMap and equipmentBindPetIdMap[itemId]

			if equipmentBindPetId and ItemUtils.isCoreCarryItem(itemId) then
				for _ = 1, itemCount do
					local _items = factory:createItems(itemId, 1, ItemUtils.genPropertyDictOnInit(itemId, equipmentBindPetId), idd.invId)

					lume.append(items, _items)
				end
			else
				local _items = factory:createItems(itemId, itemCount, extraPropDict, idd.invId)

				lume.append(items, _items)
			end
		end
	end

	for itemId, numberInfo in pairs(idNumBoundDict or EMPTY_TABLE) do
		assert(numberInfo[Const.INV_BOUND_TYPE_INSENSITIVE] == nil or numberInfo[Const.INV_BOUND_TYPE_INSENSITIVE] == 0)

		local boundNum = numberInfo[Const.INV_BOUND_TYPE_BOUND] or 0
		local unboundNum = numberInfo[Const.INV_BOUND_TYPE_UNBOUND] or 0
		local itemCount = boundNum + unboundNum

		if itemCount > 0 then
			funcGenAndPushItem(itemId, itemCount)
		end
	end

	return items
end

function ItemUtils.applyTradeData(items, tradeData)
	if not tradeData then
		return
	end

	for _, item in ipairs(items) do
		if item:getInvID() ~= ItemConst.INV_TYPE_PET_JEWELRY then
			item.props[ItemConst.ItemPropertyDef.TradeData] = Utils.deepCopyTable(tradeData)
		end
	end
end

function ItemUtils.genItemsWithTradeData(idNumBoundDict, extraPropDict, tradeData, equipmentBindPetIdMap)
	local items = ItemUtils.genItems(idNumBoundDict, extraPropDict, equipmentBindPetIdMap)

	ItemUtils.applyTradeData(items, tradeData)

	return items
end

function ItemUtils:canPileTradeData(other, now)
	local selfTradeData = self.props[ItemConst.ItemPropertyDef.TradeData]
	local otherTradeData = other.props[ItemConst.ItemPropertyDef.TradeData]
	local selfCanTrade = selfTradeData and selfTradeData.canTrade == true
	local otherCanTrade = otherTradeData and otherTradeData.canTrade == true

	if selfCanTrade ~= otherCanTrade then
		return false
	end

	local selfFreezeEndTs = selfTradeData and selfTradeData.freezeEndTs or 0
	local otherFreezeEndTs = otherTradeData and otherTradeData.freezeEndTs or 0

	return selfFreezeEndTs <= now and otherFreezeEndTs <= now or selfFreezeEndTs == otherFreezeEndTs
end

local function isNonEmptyItemContainer(value)
	if value == nil then
		return false
	end

	if type(value) == "table" and type(value.getRawTable) == "function" then
		value = value:getRawTable()
	end

	if type(value) == "table" then
		return next(value) ~= nil
	end

	return true
end

function ItemUtils.itemHasNonEmptyProps(item)
	return item ~= nil and isNonEmptyItemContainer(item:getProps())
end

function ItemUtils.itemHasNonEmptyExtraProp(item)
	return item ~= nil and isNonEmptyItemContainer(item:getExtraProp())
end

function ItemUtils.canPileItemObjects(selfItem, otherItem, now)
	if selfItem == nil or otherItem == nil or selfItem.id ~= otherItem.id then
		return false
	end

	if ItemUtils.itemHasNonEmptyProps(selfItem) or ItemUtils.itemHasNonEmptyProps(otherItem) or ItemUtils.itemHasNonEmptyExtraProp(selfItem) or ItemUtils.itemHasNonEmptyExtraProp(otherItem) then
		return false
	end

	if selfItem:getOwnerUid() ~= otherItem:getOwnerUid() then
		return false
	end

	if selfItem.vaildStartTime ~= otherItem.vaildStartTime or selfItem.vaildEndTime ~= otherItem.vaildEndTime then
		return false
	end

	return ItemUtils.canPileTradeData(selfItem, otherItem, now)
end

function ItemUtils.getMoneyNameByType(moneyType)
	local idd = ItemData[moneyType]

	if not idd or idd.invId ~= ItemConst.INV_TYPE_SPECIAL then
		return nil
	end

	local moneyName = ItemUtils.MONEY_NAME[moneyType]

	if moneyName then
		return moneyName
	end

	return CommonMoneyMap.commonMoneyType2Name[moneyType]
end

function ItemUtils.getMoneyNum(playerEnt, moneyType)
	local moneyNum = 0

	if CommonMoneyMap.commonMoneyType2Name[moneyType] then
		moneyNum = playerEnt.commonMoneyNums[moneyType]
	else
		moneyNum = playerEnt[ItemUtils.MONEY_NAME[moneyType]]
	end

	local negativeValue = playerEnt.moneyNegativeNums[moneyType] or 0

	return (moneyNum or 0) - negativeValue
end

function ItemUtils.getNegativeMoneyList(playerEnt)
	local result = {}

	for itemId in pairs(ItemUtils.NEGATIVE_MONEY_TYPE) do
		local count = ItemUtils.getItemCountById(playerEnt, itemId)

		if count < 0 then
			result[#result + 1] = {
				itemId = itemId,
				count = count
			}
		end
	end

	table.sort(result, function(a, b)
		return a.itemId > b.itemId
	end)

	return result
end

function ItemUtils.getLockMoneyNum(playerEnt, moneyType)
	return 0
end

function ItemUtils.getValidMoneyNum(playerEnt, moneyType)
	return ItemUtils.getMoneyNum(playerEnt, moneyType) - ItemUtils.getLockMoneyNum(playerEnt, moneyType)
end

function ItemUtils.getSpecialItemCount(playerEnt, itemId)
	if ItemUtils.getMoneyNameByType(itemId) ~= nil then
		return ItemUtils.getMoneyNum(playerEnt, itemId)
	elseif itemId == ItemConst.ITEM_SPECIAL_ACTION_POINT then
		return playerEnt.actionPoint
	elseif itemId == ItemConst.ITEM_SPECIAL_EXP_PLAYER then
		return playerEnt.exp
	elseif itemId == ItemConst.ITEM_SPECIAL_EXP_BP then
		return playerEnt.activityBattlePass and playerEnt.activityBattlePass.bpExp or 0
	elseif itemId == ItemConst.ITEM_SPECIAL_MONEY_ACTLITFIRE_NOTE then
		return playerEnt.activityLittleFirePerson and playerEnt.activityLittleFirePerson.notesPerson or 0
	elseif itemId == ItemConst.ITEM_SOECIAL_MONEY_SEASON_AP then
		return playerEnt.activitySeasonAchieve and playerEnt.activitySeasonAchieve.seasonAchivePoints or 0
	elseif playerEnt.commonEnergyNums[itemId] then
		return playerEnt.commonEnergyNums[itemId]
	else
		return nil
	end
end

function ItemUtils.getItemCountById(playerEnt, itemId, includeLocked)
	if ItemUtils.getInvIdByItemId(itemId) == ItemConst.INV_TYPE_SPECIAL then
		return ItemUtils.getSpecialItemCount(playerEnt, itemId) or 0
	else
		local countPair = playerEnt.itemCountBindMap[itemId]

		return countPair and ItemUtils.getItemCountFromCountPair(countPair, includeLocked) or 0
	end
end

function ItemUtils.getCanUseItemCountBindMapByItemDict(playerEnt, itemDict, includeExpired)
	local result = {}

	for itemId, _ in pairs(itemDict) do
		if not ItemUtils.hasExpiredTimeItem(itemId) or includeExpired then
			result[itemId] = playerEnt.itemCountBindMap[itemId]
		else
			result[itemId] = ItemUtils.genItemCountBindInfo()

			local invId = ItemUtils.getInvIdByItemId(itemId)
			local bag = invId and ItemUtils.getTypedBag(playerEnt, invId)

			if bag and bag.items then
				for _, item in bag:items() do
					if item.id == itemId and (includeExpired or item:canUse()) then
						ItemUtils.modifyItemCountToRet(result, item.id, item:getCount(), item:isStatusLocked())
					end
				end
			end
		end
	end

	return result
end

function ItemUtils.getItemCountByIdCanUse(playerEnt, itemId, includeLocked, includeExpired)
	if ItemUtils.getInvIdByItemId(itemId) == ItemConst.INV_TYPE_SPECIAL then
		return ItemUtils.getSpecialItemCount(playerEnt, itemId) or 0
	else
		local countPair = ItemUtils.getCanUseItemCountBindMapByItemDict(playerEnt, {
			[itemId] = true
		}, includeExpired)[itemId]

		return countPair and ItemUtils.getItemCountFromCountPair(countPair, includeLocked) or 0
	end
end

function ItemUtils.getItemCountByIdWithBindCanUse(playerEnt, itemId, isBind, includeLocked, includeExpired)
	if ItemUtils.getInvIdByItemId(itemId) == ItemConst.INV_TYPE_SPECIAL then
		return ItemUtils.getSpecialItemCount(playerEnt, itemId) or 0
	else
		local countPair = ItemUtils.getCanUseItemCountBindMapByItemDict(playerEnt, {
			[itemId] = true
		}, includeExpired)[itemId]

		return countPair and ItemUtils.getItemCountFromCountPairWithBind(countPair, includeLocked) or 0
	end
end

function ItemUtils.getItemCountByIdWithBind(playerEnt, itemId, isBind, includeLocked)
	if ItemUtils.getInvIdByItemId(itemId) == ItemConst.INV_TYPE_SPECIAL then
		return ItemUtils.getSpecialItemCount(playerEnt, itemId) or 0
	else
		local countPair = playerEnt.itemCountBindMap[itemId]

		return countPair and ItemUtils.getItemCountFromCountPairWithBind(countPair, includeLocked) or 0
	end
end

function ItemUtils.sumItemMapCount(itemMap, itemId)
	if itemId == 0 then
		local total = 0

		for _, v in pairs(itemMap) do
			total = total + v
		end

		return total
	end

	return itemMap[itemId] or 0
end

function ItemUtils.getBagItemCount(playerEnt, itemId)
	if itemId == 0 then
		local total = 0

		for _, countPair in pairs(playerEnt.itemCountBindMap) do
			total = total + ItemUtils.getItemCountFromCountPair(countPair)
		end

		return total
	end

	return ItemUtils.getItemCountById(playerEnt, itemId)
end

function ItemUtils.getWareHouseItemCount(playerEnt, itemId)
	if playerEnt:isInSelfHomeland() then
		return ItemUtils.sumItemMapCount(playerEnt.space.itemMap, itemId)
	end

	return playerEnt.statHomelandWarehouse and playerEnt.statHomelandWarehouse[itemId] or 0
end

function ItemUtils.getHomeBagAndWarehouseItemCount(playerEnt, itemId)
	return ItemUtils.getBagItemCount(playerEnt, itemId) + ItemUtils.getWareHouseItemCount(playerEnt, itemId)
end

function ItemUtils.getItem(playerEnt, invId, genId)
	local bag = invId and ItemUtils.getTypedBag(playerEnt, invId)

	if not bag then
		return nil, NoticeDef.INVENTOYR_INVALID_INVID
	end

	local item = bag[genId]

	if not item then
		return nil, NoticeDef.INVENTOYR_INVALID_GENID
	end

	return item
end

function ItemUtils.getItemsById(playerEnt, itemId)
	local invId = ItemUtils.getInvIdByItemId(itemId)

	if invId == ItemConst.INV_TYPE_SPECIAL then
		return nil
	end

	local bag = ItemUtils.getTypedBag(playerEnt, invId)

	return bag and bag:getItemsById(itemId)
end

function ItemUtils.getItemIdByGenId(playerEnt, invId, genId)
	if genId == nil then
		return nil
	end

	local item = ItemUtils.getItem(playerEnt, invId, genId)

	return item and item.id
end

function ItemUtils.getQuickSlotMaxCount(quickSlotType)
	local val = SysConfigData.QUICK_EQUIP_SLOT

	return val and val[quickSlotType] or 0
end

function ItemUtils.checkQuickSlotItemType(quickSlotType, itemId)
	local iedd = ItemEffectData[itemId]

	if not iedd or not iedd.sType then
		return false
	end

	local list

	if quickSlotType == ItemConst.QUICK_SLOT_BALL then
		list = SysConfigData.QUICK_EQUIP_BALL_SLOT
	elseif quickSlotType == ItemConst.QUICK_SLOT_ITEM then
		list = SysConfigData.QUICK_EQUIP_ITEM_SLOT
	end

	return ToBool(lume.find(list or {}, iedd.sType))
end

function ItemUtils.getBallQuickSlotType(itemId)
	local castItemId = Utils.itemId2CastItemId(itemId)
	local castItemData = castItemId and CastItemData[castItemId]

	if castItemData and castItemData.isSpecialSlot == 1 then
		return ItemConst.QUICK_SLOT_ELITE_BALL
	end

	return ItemConst.QUICK_SLOT_BALL
end

function ItemUtils.getEvolveNeedItemResult(player, itemConditions)
	local idNumDict = {}

	for _, needItemData in pairs(itemConditions or EMPTY_TABLE) do
		local needItem = needItemData[Const.PET_EVOLVE_ITEM_COND_POS_ITEM]
		local needItemId, needItemCount = needItem[1], needItem[2]

		idNumDict[needItemId] = (idNumDict[needItemId] or 0) + needItemCount
	end

	local success, resIdNumDict, altIdNumDict, replacedInfo = ItemUtils._getRealIdNumDictWithAlternative(player, idNumDict)

	return success, resIdNumDict, altIdNumDict, replacedInfo
end

function ItemUtils.getChangeFormNeedItemResult(player, needItemData)
	local needItemId, needItemCount = needItemData[1], needItemData[2]
	local idNumDict = {
		[needItemId] = needItemCount
	}
	local success, resIdNumDict, altIdNumDict, replacedInfo = ItemUtils._getRealIdNumDictWithAlternative(player, idNumDict)

	return success, resIdNumDict, altIdNumDict, replacedInfo
end

function ItemUtils.getBreakthrouthNeedItemResult(player, itemIds, itemNums)
	local idNumDict = {}

	for idx, itemId in ipairs(itemIds) do
		idNumDict[itemId] = (idNumDict[itemId] or 0) + (itemNums[idx] or 0)
	end

	local success, resIdNumDict, altIdNumDict, replacedInfo = ItemUtils._getRealIdNumDictWithAlternative(player, idNumDict)

	return success, resIdNumDict, altIdNumDict, replacedInfo
end

function ItemUtils._getRealIdNumDictWithAlternative(player, idNumDict)
	local altIdNumDict, replacedInfo = {}, {}
	local resIdNumDict = lume.clone(idNumDict)
	local resultFlag = 0

	for needId, needCount in pairs(idNumDict) do
		local realNeedCount = needCount + (altIdNumDict[needId] or 0)
		local hasCount = ItemUtils.getItemCountById(player, needId)

		if hasCount < realNeedCount then
			local altData = PetEvolveItemSubData[needId]

			if altData == nil then
				resultFlag = resultFlag + 1

				return resultFlag <= 0, idNumDict, altIdNumDict, replacedInfo
			end

			if altData.alternativeItem == nil or ToInt(altData.num) <= 0 or ToInt(altData.alternativeItemNum) <= 0 then
				if LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error("invalid alternativeItem config, itemId=%d", needId)
				end

				resultFlag = resultFlag + 1

				return resultFlag <= 0, idNumDict, altIdNumDict, replacedInfo
			end

			local beReplacedCount = realNeedCount - hasCount
			local altNeedId, altNeedCount = altData.alternativeItem, math_ceil(beReplacedCount / altData.num * altData.alternativeItemNum)
			local realAltNeedCount = altNeedCount + (altIdNumDict[altNeedId] or 0) + (resIdNumDict[altNeedId] or 0)
			local altHasCount = ItemUtils.getItemCountById(player, altNeedId)

			if realAltNeedCount <= altHasCount then
				altIdNumDict[altNeedId] = (altIdNumDict[altNeedId] or 0) + altNeedCount
				resIdNumDict[needId] = resIdNumDict[needId] - beReplacedCount
				replacedInfo[#replacedInfo + 1] = {
					oriItemId = needId,
					oriNum = beReplacedCount,
					newItemId = altNeedId,
					newNum = altNeedCount
				}
			else
				resultFlag = resultFlag + 1
			end
		end
	end

	for itemId, itemCount in pairs(altIdNumDict) do
		resIdNumDict[itemId] = (resIdNumDict[itemId] or 0) + itemCount
	end

	return resultFlag <= 0, resIdNumDict, altIdNumDict, replacedInfo
end

function ItemUtils.checkInSkillTree(nodeKey)
	local pstdd = PlayerSkillTreeData[nodeKey]

	return pstdd and ToInt(pstdd.column) > 0 and ToInt(pstdd.row) > 0
end

function ItemUtils.getResetSkillPaybackItemDict(player)
	local idNumDict = {}

	for nodeKey, nodeInfo in player.skillNodeMap:items() do
		if ItemUtils.checkInSkillTree(nodeKey) then
			for i = 1, nodeInfo.lv do
				local nodeLvConfig = PlayerSkillData[nodeKey] and PlayerSkillData[nodeKey][i]

				if nodeLvConfig ~= nil and nodeLvConfig.needItem then
					for itemId, count in pairs(nodeLvConfig.needItem) do
						idNumDict[itemId] = (idNumDict[itemId] or 0) + count
					end
				end
			end
		end
	end

	return idNumDict
end

function ItemUtils.getUseSkillPoint(player, abilityType, itemId)
	local count = 0

	for nodeKey, nodeInfo in player.skillNodeMap:items() do
		if abilityType == 0 or abilityType == (PlayerSkillTreeData[nodeKey] and PlayerSkillTreeData[nodeKey].abilityType) then
			for i = 1, nodeInfo.lv do
				local nodeLvConfig = PlayerSkillData[nodeKey] and PlayerSkillData[nodeKey][i]

				if nodeLvConfig and nodeLvConfig.needItem then
					count = count + (nodeLvConfig.needItem[itemId] or 0)
				end
			end
		end
	end

	return count
end

function ItemUtils.getBatchRecyclePetClientDisplayItem(player, petIds)
	local itemCountTable = ItemUtils.getBatchRecyclePetBackItem(player, petIds, true)
	local res = {}

	for itemId, num in pairs(itemCountTable) do
		res[#res + 1] = {
			itemId,
			num,
			hideOwnNum = true
		}
	end

	return res
end

function ItemUtils.getBatchRecyclePetBackItem(player, petIds, needCountTable)
	local res = {}

	for _, petId in pairs(petIds) do
		local temp = ItemUtils.getRecyclePetBackItem(player, petId)

		ItemUtils.mergeItemInfoResult(res, temp)
	end

	return needCountTable and ItemUtils.getItemCountTable(res) or res
end

function ItemUtils.getRecyclePetBackItem(player, petId, needCountTable)
	local petInfo = player.pets[petId]

	if petInfo == nil then
		return {}
	end

	local pdd = PetData[petInfo.templateId]

	if pdd == nil then
		return {}
	end

	local res = {}

	if pdd.releaseReward then
		local DropUtils = require("Common.Utils.DropUtils")
		local dropItems = DropUtils.getDropItemsBoundDict(player, pdd.releaseReward)

		ItemUtils.mergeItemInfoResult(res, dropItems)
	end

	local levelExpResetItems = petInfo:getLevelExpResetPayback()

	if next(levelExpResetItems) then
		ItemUtils.mergeItemInfoResult(res, levelExpResetItems)
	end

	local resonanceItems = petInfo:getResonanceItemsBack()

	if next(resonanceItems) then
		ItemUtils.mergeItemInfoResult(res, resonanceItems)
	end

	return needCountTable and ItemUtils.getItemCountTable(res) or res
end

function ItemUtils.getExchangePetBackItem(player, petId, needCountTable)
	local res = {}

	return needCountTable and ItemUtils.getItemCountTable(res) or res
end

function ItemUtils.mergeShinyExtraCost(costItems)
	local goldenCost = SysConfigData.PET_EXCHANGE_GOLDEN

	if not goldenCost or not goldenCost[1] or not goldenCost[2] or goldenCost[2] <= 0 then
		return
	end

	ItemUtils.mergeItemInfoResult(costItems, ItemUtils.itemList2Dict({
		goldenCost
	}))
end

function ItemUtils.simpleCheckItemCountEnough(player, idNumDict)
	for itemId, numInfo in pairs(idNumDict) do
		local itemNum = ItemUtils.getItemCountFromNumInfo(numInfo)

		if itemNum > ItemUtils.getItemCountById(player, itemId) then
			return false
		end
	end

	return true
end

function ItemUtils.isCoreCarryItem(itemId)
	return CoreCarryData[itemId] ~= nil
end

function ItemUtils.isAssistCarryItem(itemId)
	return AssistCarryData[itemId] ~= nil
end

function ItemUtils.isCoreCarryCostItem(itemId)
	return ItemData[itemId].type == ItemConst.ITEM_TYPE.CoreCarryCost
end

function ItemUtils.isRobEgg(itemid)
	return ItemData[itemid].type == ItemConst.ITEM_TYPE.EGG
end

function ItemUtils.needGenPropertyOnInit(itemId)
	if ItemUtils.isCoreCarryItem(itemId) then
		return true
	end

	if ItemUtils.isAssistCarryItem(itemId) then
		return true
	end

	return false
end

function ItemUtils.genPropertyDictOnInit(itemId, certifiedBaseFormPet)
	if ItemUtils.isCoreCarryItem(itemId) then
		local coreCarryInfo = require("CustomTypes.CoreCarryInfo")({
			itemId = itemId
		})

		coreCarryInfo:onFirstCreate()

		if certifiedBaseFormPet and certifiedBaseFormPet ~= 0 then
			coreCarryInfo.certifiedBaseFormPet = certifiedBaseFormPet
		end

		return coreCarryInfo:getRawTable()
	end

	if ItemUtils.isAssistCarryItem(itemId) then
		local assistCarryInfo = require("CustomTypes.AssistCarryInfo")({
			itemId = itemId
		})

		assistCarryInfo:onFirstCreate()

		return assistCarryInfo:getRawTable()
	end

	logger:error("genPropertyDictOnInit, itemId=%d", itemId)

	return {}
end

function ItemUtils.getPropertyWithType(item)
	if item == nil then
		return nil
	end

	if ItemUtils.isCoreCarryItem(item.id) then
		return require("CustomTypes.CoreCarryInfo")(item:getExtraProp())
	end

	if ItemUtils.isAssistCarryItem(item.id) then
		return require("CustomTypes.AssistCarryInfo")(item:getExtraProp())
	end

	logger:error("getPropertyWithType, itemId=%d", item.id)

	return nil
end

function ItemUtils.getCoreCarryConvertExp(item)
	if item == nil then
		return 0
	end

	local itemId = item.id
	local idd = ItemData[itemId]

	if idd == nil then
		return 0
	end

	local qualityExpMap = PetConfigData.coreCarryQualityExpMap

	if not ItemUtils.isCoreCarryItem(itemId) then
		return 0
	end

	local coreCarryInfo = ItemUtils.getPropertyWithType(item)

	if coreCarryInfo == nil then
		return 0
	end

	local baseExp = qualityExpMap and qualityExpMap[idd.quality] or 0
	local curTotalExp = coreCarryInfo.totalExp
	local returnRatio = PetConfigData.coreCarryExpReturnRatio or 0

	return math.safe_floor(baseExp + returnRatio * curTotalExp)
end

function ItemUtils.getCoreCarryConvertExpByItemId(itemId)
	local idd = ItemData[itemId]

	if idd == nil then
		return 0
	end

	if not ItemUtils.isCoreCarryCostItem(itemId) then
		return 0
	end

	local qualityExpMap = PetConfigData.coreCarryQualityExpMap

	return qualityExpMap and qualityExpMap[idd.quality] or 0
end

function ItemUtils.getItemPetExp(player, itemId)
	local iedd = ItemEffectData[itemId]

	if iedd == nil or iedd.sType ~= ItemConst.USEITEM_TYPE_PET_EXP then
		return 0
	end

	if pg.component == "client" then
		return iedd.petExp or 0
	end

	local DropUtils = require("Common.Utils.DropUtils")
	local itemRes = DropUtils.getDropItemsCountTable(player, iedd.reward)

	return itemRes and itemRes[ItemConst.ITEM_SPECIAL_EXP_PET] or 0
end

function ItemUtils.isSocialItem(itemId)
	for _, info in pairs(SocialTypeData) do
		if info.itemId == itemId then
			return true
		end
	end

	return false
end

function ItemUtils.isChangeFormItem(itemId)
	local iedd = ItemEffectData[itemId]

	return iedd and iedd.sType == ItemConst.USEITEM_TYPE_FORM_CHANGE_ITEM
end

function ItemUtils.checkSType(itemId, stype)
	local iedd = ItemEffectData[itemId]

	return iedd and iedd.sType == stype or false
end

function ItemUtils.petCanChangeFormByItem(player, sourceFormId, itemId)
	local basePetPrototypeId = Utils.getBasePetPrototypeId(sourceFormId)
	local targetIds = ItemFormChangeMapData[itemId][basePetPrototypeId]

	if not targetIds then
		return false
	end

	for index, targetId in ipairs(targetIds) do
		local canChange = Utils.petCanChangeForm(player, sourceFormId, targetId) ~= false

		if canChange then
			return true, targetId
		end
	end

	return false
end

function ItemUtils.refreshItemByConditionConvert(player, idNumBoundDict)
	local replaceIdMap = {}

	for itemId, numInfo in pairs(idNumBoundDict) do
		local itemNum = ItemUtils.getItemCountFromNumInfo(numInfo)
		local idd = ItemData[itemId]
		local iccd = ItemConditionConvertData[itemId]

		if idd and iccd then
			local modified = false

			for _, targetInfo in ipairs(iccd.targetItem) do
				local condId, replaceItemId = targetInfo[1], targetInfo[2]

				if player.triggerMap:isCompleteOrMeetCondition(condId) then
					replaceIdMap[itemId] = replaceItemId
					modified = true

					break
				end
			end

			if not modified then
				logger:debug("ItemUtils.refreshItemByConditionConvert, %s, itemId=%d, itemNum=%d, not modified", player:repr(), itemId, itemNum)
			end
		end
	end

	for itemId, replaceItemId in pairs(replaceIdMap) do
		local numInfo = idNumBoundDict[itemId]

		if numInfo then
			idNumBoundDict[itemId] = nil
			idNumBoundDict[replaceItemId] = idNumBoundDict[replaceItemId] or {}

			ItemUtils.mergeNumInfo(idNumBoundDict[replaceItemId], numInfo)
		end
	end

	return next(replaceIdMap) and replaceIdMap or nil
end

function ItemUtils.getReplacedItemCountTable(player, itemCountTable)
	local idNumBoundDict = ItemUtils.formatIdNumBoundDict(itemCountTable)
	local replaceIdMap = ItemUtils.refreshItemByConditionConvert(player, idNumBoundDict)

	if not replaceIdMap then
		return itemCountTable
	else
		return ItemUtils.getItemCountTable(idNumBoundDict), replaceIdMap
	end
end

function ItemUtils.getItemFinalNameStr(itemCfg)
	return pg.getLocalizationText(itemCfg and itemCfg.itemName or "") or ""
end

function ItemUtils.getIsGainedTheItem(itemId, finalCheck)
	if not itemId then
		return false
	end

	local hasCount = ItemUtils.getItemCountById(pg.me, itemId)

	if hasCount > 0 then
		return true
	end

	if not finalCheck then
		return false
	end

	return finalCheck(itemId)
end

function ItemUtils.getItemFinalNameStrByItemId(itemId)
	local itemCfg = ItemData[itemId]

	return pg.getLocalizationText(itemCfg and itemCfg.itemName or "") or ""
end

function ItemUtils.getRobEggDropReward(player, cfg, hardLv)
	local function getRewardIdByHardLevel(tbl)
		return tbl and tbl[hardLv]
	end

	local DropUtils = require("Common.Utils.DropUtils")
	local result = {}

	local function getReward(rewardNumber, rewardGroup)
		if not ToBool(rewardNumber) then
			return
		end

		local rewardIds = getRewardIdByHardLevel(rewardGroup)

		if not rewardIds then
			return
		end

		local idx = math.random(1, #rewardNumber)
		local times = rewardNumber[idx]

		for i = 1, times do
			for _, rewardId in ipairs(rewardIds) do
				local dropItems = DropUtils.getDropItemsBoundDict(player, rewardId)
				local idNumDict = ItemUtils.getItemCountTable(dropItems)

				for itemid, num in pairs(idNumDict) do
					result[itemid] = (result[itemid] or 0) + num
				end
			end
		end
	end

	getReward(cfg.rewardNumber, cfg.rewardGroup)
	getReward(cfg.rewardNumber2, cfg.rewardGroup2)

	local itemList = {}

	for itemId, count in pairs(result) do
		local itemCfg = ItemData[itemId]

		if itemCfg then
			if count <= itemCfg.stackcount then
				table.insert(itemList, {
					itemId = itemId,
					count = count
				})
			else
				local heapCnt = math.floor(count, itemCfg.stackcount)
				local restCnt = count % itemCfg.stackcount

				for i = 1, heapCnt do
					table.insert(itemList, {
						itemId = itemId,
						count = itemCfg.stackcount
					})
				end

				if ToBool(restCnt) then
					table.insert(itemList, {
						itemId = itemId,
						count = restCnt
					})
				end
			end
		end
	end

	lume.shuffle(itemList)

	return itemList
end

function ItemUtils.isStackable(itemId)
	local itemCfg = ItemData[itemId]

	if not itemCfg then
		return false
	end

	if itemCfg.type == ItemConst.ITEM_TYPE.WEAPON then
		return false
	end

	if itemCfg.type == ItemConst.ITEM_TYPE.ARMOR then
		return false
	end

	if itemCfg.type == ItemConst.ITEM_TYPE.REPAIR_KIT then
		return false
	end

	return itemCfg.stackcount > 1
end

function ItemUtils.mergeOwnerUid(ownerUid1, ownerUid2)
	if ownerUid1 == ownerUid2 then
		return ownerUid1
	end

	if not ToBool(ownerUid1) then
		return ownerUid2
	end

	return ownerUid1
end

function ItemUtils.copyItemProps(srcItem, dstItem, invId)
	if not srcItem or not dstItem then
		return false
	end

	dstItem.vaildStartTime = srcItem.vaildStartTime
	dstItem.vaildEndTime = srcItem.vaildEndTime

	dstItem:setProps(lume.clone(srcItem:getProps():getRawTable()))

	return ItemUtils.restoreItemTTL(dstItem, invId)
end

function ItemUtils.isEquip(itemid)
	local itemCfg = ItemData[itemid]

	if not itemCfg then
		return false
	end

	if itemCfg.type == ItemConst.ITEM_TYPE.WEAPON then
		return true
	end

	if itemCfg.type == ItemConst.ITEM_TYPE.ARMOR then
		return true
	end

	return false
end

function ItemUtils.isRepairKit(itemid)
	local itemCfg = ItemData[itemid]

	if not itemCfg then
		return false
	end

	if itemCfg.type == ItemConst.ITEM_TYPE.REPAIR_KIT then
		return true
	end

	return false
end

function ItemUtils.getRobEggInItemId(itemId)
	if not itemId then
		return nil
	end

	local itemOutCfg = RobEggItemOut[itemId]

	return itemOutCfg and itemOutCfg.inid or itemId
end

function ItemUtils.getRobEggInItemConfig(itemId)
	local inItemId = ItemUtils.getRobEggInItemId(itemId)

	return inItemId and ItemData[inItemId] or nil
end

function ItemUtils.getRobEggItemWeight(itemId)
	local itemCfg = ItemUtils.getRobEggInItemConfig(itemId)

	return itemCfg and itemCfg.weight or 0
end

function ItemUtils.getRobEggItemMaxDurability(itemId)
	local inItemId = ItemUtils.getRobEggInItemId(itemId)
	local itemCfg = ItemData[itemId] or ItemData[inItemId]
	local itemType = itemCfg and itemCfg.type

	if itemType == ItemConst.ITEM_TYPE.WEAPON or itemType == ItemConst.ITEM_TYPE.ARMOR then
		local equipCfg = RobEggEquipData[itemId] or RobEggEquipData[inItemId]

		return equipCfg and equipCfg.durabilityMax or nil
	elseif itemType == ItemConst.ITEM_TYPE.REPAIR_KIT then
		local repairKitCfg = RobEggRepairKitData[itemId] or RobEggRepairKitData[inItemId]

		return repairKitCfg and repairKitCfg.repairPoints or nil
	end

	return nil
end

function ItemUtils.isRefineable(itemid)
	local cfg = RobEggCollectionRefine[itemid]

	return ToBool(cfg)
end

function ItemUtils.isForbidRobEgg(itemid)
	local cfg = ItemData[itemid]

	if not cfg then
		return false
	end

	return ToBool(cfg.notCanBringIn) or false
end

function ItemUtils.isShowable(itemid)
	local cfg = RobEggBookAntiqueData[itemid]

	return ToBool(cfg)
end

function ItemUtils.throwItems(player, items, allThrow)
	local ServerUtils = require("GameServer.ServerUtils")

	if not ToBool(items) or not player then
		return
	end

	for idx = 1, #items do
		local throwItemInfo = items[idx]

		if ToBool(throwItemInfo) then
			local itemCfg = ItemData[throwItemInfo.id]

			if itemCfg then
				if allThrow then
					local dropResId = Utils.getBindingSceneObjectId(itemCfg.bindingId)

					if ToBool(dropResId) then
						local pos = ServerUtils.genSpaceRandomPosition(player.space.id, player:getPosition(), 1)

						player.space:createCollectItemEntity(player.id, dropResId, pos, Quaternion.identity, {
							itemid = throwItemInfo.id,
							count = throwItemInfo.count,
							ownerUid = throwItemInfo.ownerUid,
							props = throwItemInfo.props
						})
					end
				elseif player.space:isRobEgg() then
					local dropResId = Utils.getBindingSceneObjectId(itemCfg.bindingId)

					if ToBool(dropResId) then
						local pos = ServerUtils.genSpaceRandomPosition(player.space.id, player:getPosition(), 1)

						player.space:createCollectItemEntity(player.id, dropResId, pos, Quaternion.identity, {
							itemid = throwItemInfo.id,
							count = throwItemInfo.count,
							ownerUid = throwItemInfo.ownerUid,
							props = throwItemInfo.props
						})
					end
				else
					local cfg = RobEggItemIn[throwItemInfo.id]

					if cfg then
						player:addItemById(cfg.outid, throwItemInfo.count, ItemConstSourceData.ITEM_SOURCE_GRABEGG_CONVERSION_EXTERNAL)
					end
				end
			end
		end
	end

	items = {}
end

function ItemUtils.checkRepairRobEquip(equipItem, repairItem)
	if not ToBool(equipItem) then
		return Const.CheckFixEquipRet.InValid
	end

	local equipItemCfg = ItemData[equipItem.id]

	if not equipItemCfg then
		return Const.CheckFixEquipRet.InValid
	end

	local equipCfg = RobEggEquipData[equipItem.id]

	if not equipCfg then
		return Const.CheckFixEquipRet.InValid
	end

	local curDurability, maxDurability = equipItem:getDurability()

	if curDurability == maxDurability then
		return Const.CheckFixEquipRet.NoNeed
	end

	if maxDurability <= equipCfg.repairLimit then
		return Const.CheckFixEquipRet.TooHigh
	end

	local baseCost = equipCfg.baseLoss or 10
	local repairRation = (maxDurability - curDurability) * 100 / maxDurability
	local cost = math.ceil(baseCost * repairRation / 100)

	if ToBool(repairItem) then
		local repairItemCfg = ItemData[repairItem.id]

		if not repairItemCfg then
			return Const.CheckFixEquipRet.InValid
		end

		if repairItemCfg.quality < equipItemCfg.quality then
			local diff = equipItemCfg.quality - repairItemCfg.quality

			cost = cost * (equipCfg.levelPenalty[diff] or 1)
		end
	end

	local maxDurabilityAfterRepair = maxDurability - cost

	if maxDurabilityAfterRepair <= 0 or maxDurabilityAfterRepair <= curDurability then
		return Const.CheckFixEquipRet.TooLow
	end

	return Const.CheckFixEquipRet.OK
end

function ItemUtils.isSearching(uid, item)
	local value = item.discoverys[uid]

	if not value then
		return false
	end

	if value > Time.secondCache then
		return true
	end

	return false
end

function ItemUtils.isOpenUIType(itemId)
	local itemCfg = ItemData[itemId or 0]

	if not itemCfg then
		return false
	end

	local itemEffectCfg = ItemEffectData[itemId]

	for _, eventId in ipairs(itemEffectCfg and itemEffectCfg.eventId or EMPTY_TABLE) do
		local eventCfg = SysEventData[eventId]
		local eventType = eventCfg and eventCfg.eventType

		if eventType == "openUI" or eventType == "openUISuper" or eventType == "showIPContent" then
			return true
		end
	end

	return itemCfg.source and itemCfg.source[1] and itemCfg.source[1] == 507
end

function ItemUtils.getItemSimpleInfo(itemId, itemNum)
	local itemCfg = ItemData[itemId or 0]

	if not itemCfg then
		return {}
	end

	return {
		itemId = itemId,
		itemCount = itemNum or 0,
		name = pg.getLocalizationText(itemCfg.name) or "",
		icon = itemCfg.icon,
		quality = itemCfg.quality,
		type = itemCfg.type
	}
end

function ItemUtils.isRainbowItem(itemId)
	local cfg = ItemData[itemId]

	return cfg and cfg.quality == ItemConst.ITEM_QUALITY.RAINBOW
end

function ItemUtils.isGoldItem(itemId)
	local cfg = ItemData[itemId]

	return cfg and cfg.quality == ItemConst.ITEM_QUALITY.GOLD
end

function ItemUtils.isBlackRainbowEgg(eggItemId)
	local cfg = ItemData[eggItemId]

	if not cfg then
		return false
	end

	if not ToBool(cfg.eggtype) then
		return false
	end

	if cfg.quality == ItemConst.ITEM_QUALITY.RAINBOW then
		return true
	end

	return false
end

function ItemUtils.getDecomposeRewardCount(delItem, rewardCount)
	if not delItem or not ToBool(rewardCount) then
		return 0
	end

	if ItemUtils.isEquip(delItem.id) then
		local func = FormulaData[Const.FormulaId.RobEggEquipPrice]
		local equipCfg = RobEggEquipData[delItem.id]

		if func and equipCfg then
			local curDurability, maxDurability = delItem:getDurability()
			local realRewardCount = func.formula(rewardCount, maxDurability, equipCfg.durabilityMax, curDurability)

			return math.ceil(realRewardCount)
		end
	elseif ItemUtils.isRepairKit(delItem.id) then
		local func = FormulaData[Const.FormulaId.RobEggRepairKitPrice]

		if func then
			local v1, v2 = delItem:getRepairValue()
			local realRewardCount = func.formula(rewardCount, v1, v2)

			return math.ceil(realRewardCount)
		end
	elseif ItemUtils.isRefineable(delItem.id) then
		local refineData = delItem:getProps()[ItemConst.ItemPropertyDef.AntiqueData]

		if refineData then
			local cfg = RobEggCollectionRankData[refineData.degree]

			if cfg then
				return math.ceil(rewardCount * cfg.doubleMul) or 0
			end
		end
	end

	return rewardCount * delItem:getCount()
end

function ItemUtils.isEquipSlot(pos)
	return pos >= ItemConst.ROB_EGG_EQUIP_SLOT.MIN and pos <= ItemConst.ROB_EGG_EQUIP_SLOT.MAX
end

function ItemUtils.isSafeBoxSlot(pos)
	return pos >= ItemConst.ROB_EGG_SAFE_SLOT.MIN and pos <= ItemConst.ROB_EGG_SAFE_SLOT.MAX
end

function ItemUtils.isBagSlot(pos)
	return pos >= ItemConst.ROB_EGG_BAG_SLOT.MIN and pos <= ItemConst.ROB_EGG_BAG_SLOT.MAX
end

function ItemUtils.clearItemById(itemId, params)
	if pg.me == nil then
		return
	end

	local count = ItemUtils.getItemCountById(pg.me, itemId, true) or 0

	if count <= 0 then
		if pg.global and pg.global.ui and pg.global.ui.tips then
			pg.global.ui.tips:showTextTip("背包中没有该道具")
		end

		return
	end

	pg.me:doGmCmd("delItem", itemId, count)
end

function ItemUtils.isCommonMoney(itemId)
	local data = ItemData[itemId]

	return ItemUtils.getInvIdByItemId(itemId) == ItemConst.INV_TYPE_SPECIAL or data and data.commonMoney == 1
end

local function normalizeRobEggCollectionItem(itemOrData)
	if type(itemOrData) ~= "table" then
		return nil, itemOrData
	end

	local item = itemOrData.packSlot or itemOrData

	return item, item.id or item.itemId or itemOrData.itemId
end

local function getHiddenVariantModelIdFromAffixData(affixData)
	if type(affixData) ~= "table" or not affixData.affixId then
		return nil
	end

	local tagCfg = RobEggCollectionTagData[affixData.affixId]

	if not tagCfg or tagCfg.hiddenMark ~= 1 then
		return nil
	end

	local modelId = affixData.modelId

	return modelId and RobEggCollectionVariantModelData[modelId] and modelId or nil
end

local function getRobEggCollectionVariantModelId(itemOrData, nextAffixData)
	local item = normalizeRobEggCollectionItem(itemOrData)
	local serverAffixData = nextAffixData and (nextAffixData.nextAffixData or nextAffixData)
	local modelId = getHiddenVariantModelIdFromAffixData(serverAffixData)

	if modelId then
		return modelId
	end

	local props = item and item.props

	if not props then
		return nil
	end

	local antiqueData = props[ItemConst.ItemPropertyDef.AntiqueData]

	modelId = getHiddenVariantModelIdFromAffixData(item.nextAffixData) or getHiddenVariantModelIdFromAffixData(props.nextAffixData) or getHiddenVariantModelIdFromAffixData(antiqueData and antiqueData.nextAffixData)

	if modelId then
		return modelId
	end

	local affixNum = antiqueData and antiqueData.affix_num or 0

	for i = 1, affixNum do
		local affixData = props[ItemConst.ItemPropertyDef.AntiqueData .. i] or props[ItemConst.ItemPropertyDef.AntiqueAffix .. i]
		local affixModelId = getHiddenVariantModelIdFromAffixData(affixData)

		if affixModelId then
			modelId = affixModelId
		end
	end

	return modelId
end

function ItemUtils.getRobEggCollectionDisplayModel(itemOrData, nextAffixData)
	local _, itemId = normalizeRobEggCollectionItem(itemOrData)

	if not itemId then
		return nil, 1, nil
	end

	local variantModelId = getRobEggCollectionVariantModelId(itemOrData, nextAffixData)
	local variantCfg = variantModelId and RobEggCollectionVariantModelData[variantModelId]
	local itemOutCfg = RobEggItemOut[itemId]
	local inItemId = itemOutCfg and itemOutCfg.inid or itemId
	local collectCfg = CollectItemData[inItemId]
	local calcineCfg = RobEggCollectionRefine[itemId]
	local modelResId = variantCfg and variantCfg.model or collectCfg and collectCfg.model
	local modelScale = calcineCfg and calcineCfg.scale or collectCfg and collectCfg.modelScale or 1
	local itemParameter = calcineCfg and calcineCfg.itemParameter or nil

	return modelResId, modelScale, variantModelId, itemParameter
end

function ItemUtils.itemDictToBilogList(itemDict)
	local bilogList = {}

	for itemId, itemNum in pairs(itemDict) do
		bilogList[#bilogList + 1] = {
			item_id = tostring(itemId),
			item_num = itemNum
		}
	end

	return bilogList
end

return ItemUtils
