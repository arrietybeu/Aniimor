-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Shop\\ShopBaseModel.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("ShopBaseModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ShopCommodityData = require("Data.shop_commodity_data")
local ItemShopData = require("Data.item_shop_data")
local ShopTagData = require("Data.shop_tag_data")
local ShopClassifyData = require("Data.shop_classify_data")
local ItemData = require("Data.item_data")
local lume = require("Core.Common.lume")
local ItemQuality = require("Data.item_quality")
local SysConfigData = require("Data.sys_config_data")
local ItemConst = require("Common.Const.ItemConst")
local TimeUtils = require("Common.Utils.TimeUtils")
local Time = require("Core.Common.Time")
local Utils = require("Common.Utils.Utils")
local CommonSwitch = require("Common.CommonSwitch")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemShowTypeData = require("Data.item_type_show_data")
local GameStringConfig = require("Data.gamestring_config_data")
local AttributeConst = require("Common.Const.AttributeConst")
local ItemThirdPageData = require("Data.item_third_page_data")
local LimitData = require("Data.limit_data")
local LimitRevertData = require("Data.shop_commodity_limitId_revert_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local Const = require("Common.Const.Const")
local ShopCommonHelper = require("Utils.ShopCommonHelper")
local ClientUtils = require("Utils.ClientUtils")
local HomeSeasonConfigData = require("Data.home_season_config_data")
local HomeSeasonUtils = require("Utils.HomeSeasonUtils")
local ShopBaseModel = Class.LightClass("ShopBaseModel", UIModel)
local shopCheckNewPropTag = "ShopCheckNewPropTag_%d"
local REFRESH_LIST_STATUS = {
	PENDING = 1,
	FAILED = 4,
	DISABLED = 3,
	READY = 2
}

ShopBaseModel.RogueBuffTagId = 12
ShopBaseModel.RogueBuffClassifyId = 10

local function sortFunc(a, b)
	local itemConfigA, shopConfigA = ShopBaseModel:getItemConfigByShopItemId(a.id)
	local itemConfigB, shopConfigB = ShopBaseModel:getItemConfigByShopItemId(b.id)
	local isUnlcokA = ShopBaseModel:isPropUnlock(a.id)
	local isUnlcokB = ShopBaseModel:isPropUnlock(b.id)

	if isUnlcokA ~= isUnlcokB then
		return isUnlcokA
	else
		local isSellOutA = ShopBaseModel:isPropSellOut(a.id)
		local isSellOutB = ShopBaseModel:isPropSellOut(b.id)

		if isSellOutA ~= isSellOutB then
			return not isSellOutA
		elseif shopConfigA.sort ~= shopConfigB.sort then
			return shopConfigA.sort < shopConfigB.sort
		else
			return a.id < b.id
		end
	end
end

function ShopBaseModel:getBuyShopProps(shopTag, locateShopItemId, paginationId)
	local items = {}
	local locateIndex = 0

	paginationId = paginationId or -1

	for k, v in pairs(ShopCommodityData) do
		if v.onSale == 1 and v.tag == shopTag and self:isPropInLimitTime(v) and self:isInRogueGoodsList(k, v) and (paginationId == -1 or v.paginationId == paginationId) and self:isItemOnSale(v) and self:isInRefreshList(shopTag, k) and not self:isPropHideByCondition(v) and (not v.dailyCloseSec or not v.dailyOpenSec or TimeUtils.isInDailyOpenTime(v.dailyOpenSec, v.dailyCloseSec)) then
			table.insert(items, {
				id = k
			})
		end
	end

	table.sort(items, sortFunc)

	if locateShopItemId ~= nil then
		for index, item in ipairs(items) do
			if item.id == locateShopItemId then
				locateIndex = index - 1

				break
			end
		end
	end

	return items, locateIndex
end

function ShopBaseModel:isConfigAvailableInArea(config, areaNo)
	return ShopCommonHelper.isConfigAvailableInArea(config, areaNo)
end

function ShopBaseModel:isItemOnSale(shopItemConfig)
	local areaNo = Utils.getServerArea()

	if not self:isConfigAvailableInArea(shopItemConfig, areaNo) then
		return false
	end

	local itemConfig = shopItemConfig and ItemData[shopItemConfig.itemId]

	return self:isConfigAvailableInArea(itemConfig, areaNo)
end

function ShopBaseModel:getSellShopProps(invenId)
	local items = {}
	local itemBag = ItemUtils.getTypedBag(pg.me, invenId) or {}

	for k, packSlot in itemBag:items() do
		local itemConfig = ItemData[packSlot.id]

		if itemConfig ~= nil and itemConfig.sellPrice ~= nil then
			table.insert(items, packSlot)
		end
	end

	local function sortFunc(a, b)
		return a.genID < b.genID
	end

	table.sort(items, sortFunc)

	return items
end

function ShopBaseModel:getThirdTabList(shopTag)
	if not self.shopTag2thirdTabList then
		self.shopTag2thirdTabList = {}
	end

	if not self.shopTag2thirdTabList[shopTag] then
		self.shopTag2thirdTabList[shopTag] = {}

		if ShopTagData[shopTag] and ShopTagData[shopTag].typePage then
			local thirdPageList = ShopTagData[shopTag].typePage
			local ret = self.shopTag2thirdTabList[shopTag]

			for _, id in ipairs(thirdPageList) do
				local curData = ItemThirdPageData[id]

				ret[#ret + 1] = {
					paginationId = id,
					nameHashId = curData.name
				}
			end

			table.sort(ret, function(a, b)
				local sortA = ItemThirdPageData[a.paginationId].displayPriority
				local sortB = ItemThirdPageData[b.paginationId].displayPriority

				return sortB < sortA
			end)
			table.insert(ret, 1, {
				paginationId = -1,
				nameHashId = GameStringConfig.ALL.desc
			})
		end
	end

	return self.shopTag2thirdTabList[shopTag]
end

function ShopBaseModel:getSellShopTags(param)
	local shopClassifyId = 0
	local temp = {}

	if param ~= nil and param.shopTags ~= nil and not Utils.isEmptyTable(param.shopTags) then
		shopClassifyId = param.shopTags[1]

		local shopTags = ShopClassifyData[shopClassifyId] and ShopClassifyData[shopClassifyId].classify or {}

		for i = 1, #shopTags do
			local tag = shopTags[i]

			if self:isShopTagOpen(tag) then
				table.insert(temp, {
					id = tag
				})
			end
		end
	elseif param ~= nil and param.shopTag ~= nil then
		if self:isShopTagOpen(param.shopTag) then
			table.insert(temp, {
				id = param.shopTag
			})
		end
	else
		for i, v in pairs(ShopTagData) do
			if self:isShopTagOpen(i) then
				table.insert(temp, {
					id = i
				})
			end
		end
	end

	local locateShopTag = param ~= nil and param.locateShopTag
	local locateShopItemId

	if param ~= nil then
		if param.shopTag ~= nil then
			locateShopTag = param.shopTag
		elseif param.shopItemId ~= nil then
			local shopItemConfig = self:getShopItemConfig(param.shopItemId)

			if shopItemConfig ~= nil and self:containsShopTag(temp, shopItemConfig.tag) then
				locateShopTag = shopItemConfig.tag
				locateShopItemId = param.shopItemId
			end
		elseif param.itemId ~= nil then
			local shopItems = ItemShopData[param.itemId]

			if shopItems ~= nil then
				for i = 1, #shopItems do
					local shopItemConfig = self:getShopItemConfig(shopItems[i])

					if shopItemConfig and self:containsShopTag(temp, shopItemConfig.tag) then
						locateShopItemId = shopItems[1]
						locateShopTag = shopItemConfig.tag

						break
					end
				end
			end
		end
	end

	local function SortFunc(a, b)
		local shopConfigA = ShopTagData[a.id]
		local shopConfigB = ShopTagData[b.id]

		return shopConfigA.sort < shopConfigB.sort
	end

	table.sort(temp, SortFunc)

	if temp and #temp > 0 and not self:isLocateShopTagValid(temp, locateShopTag) then
		locateShopTag = temp[1].id

		if locateShopItemId ~= nil then
			locateShopItemId = nil
		end
	end

	return temp, locateShopTag, locateShopItemId, shopClassifyId
end

function ShopBaseModel:containsShopTag(shopTags, tag)
	for i = 1, #shopTags do
		if shopTags[i].id == tag then
			return true
		end
	end

	return false
end

function ShopBaseModel:isLocateShopTagValid(shopTags, locateShopTag)
	return self:containsShopTag(shopTags, locateShopTag)
end

function ShopBaseModel:getShopTagConfig(shopTagId)
	return ShopTagData[shopTagId]
end

function ShopBaseModel:isShopTagOpen(shopTagId)
	local shopTagConfig = ShopTagData[shopTagId]

	if shopTagConfig == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("%d商品库配置不存在！", shopTagId)
		end

		return false
	end

	if self:isGmCloseShopTag(shopTagId) then
		return false
	end

	if shopTagId == HomeSeasonConfigData.SeasonShopType and not HomeSeasonUtils.isSeasonShopOpen(pg.me) then
		return false
	end

	local startTime, endTime = self:getShopTagLimitTime(shopTagConfig)

	if shopTagConfig.startTimeRefId and shopTagConfig.startTimeRefId ~= 0 and startTime == nil or shopTagConfig.endTimeRefId and shopTagConfig.endTimeRefId ~= 0 and endTime == nil then
		return false
	end

	local isOpen = TimeUtils.isInRangeTimestamp(startTime, endTime)

	return isOpen
end

function ShopBaseModel:getShopTagLimitTime(shopTagConfig)
	local startTime = Utils.getConfigTimeOfAreaByData(shopTagConfig.startTime, shopTagConfig.startTimeRefId)
	local endTime = Utils.getConfigTimeOfAreaByData(shopTagConfig.endTime, shopTagConfig.endTimeRefId)

	return startTime, endTime
end

function ShopBaseModel:isGmCloseShopTag(shopTagId)
	if CommonSwitch.SHOP_TAG and type(CommonSwitch.SHOP_TAG) == "table" then
		return CommonSwitch.SHOP_TAG[shopTagId] ~= nil
	end

	return false
end

function ShopBaseModel:isPropInLimitTime(itemShopConfig)
	local startTime, endTime = self:getShopItemLimitTime(itemShopConfig)

	if itemShopConfig.startTimeRefId and itemShopConfig.startTimeRefId ~= 0 and startTime == nil or itemShopConfig.endTimeRefId and itemShopConfig.endTimeRefId ~= 0 and endTime == nil then
		return false
	end

	if startTime ~= nil or endTime then
		local isIn = TimeUtils.isInRangeTimestamp(startTime, endTime)

		return isIn
	end

	return true
end

function ShopBaseModel:getShopItemLimitTime(shopItemConfig)
	local startTime = Utils.getConfigTimeOfAreaByData(shopItemConfig.startTime, shopItemConfig.startTimeRefId)
	local endTime = Utils.getConfigTimeOfAreaByData(shopItemConfig.endTime, shopItemConfig.endTimeRefId)

	return startTime, endTime
end

function ShopBaseModel:isShopItemInSpecialTime(shopItemConfig)
	local startTime = Utils.getConfigTimeOfAreaByData(shopItemConfig.specialStartTime, shopItemConfig.specialStartTimeRefId)
	local endTime = Utils.getConfigTimeOfAreaByData(shopItemConfig.specialEndTime, shopItemConfig.specialEndTimeRefId)

	if shopItemConfig.specialStartTimeRefId and shopItemConfig.specialStartTimeRefId ~= 0 and startTime == nil or shopItemConfig.specialEndTimeRefId and shopItemConfig.specialEndTimeRefId ~= 0 and endTime == nil then
		return false
	end

	return TimeUtils.isInRangeTimestamp(startTime, endTime)
end

function ShopBaseModel:isInRogueGoodsList(goodsId, itemShopConfig)
	if itemShopConfig.tag == self.RogueBuffTagId then
		return pg.me.randomGoodsList and table.contains(pg.me.randomGoodsList, goodsId)
	end

	return true
end

function ShopBaseModel:getLimitPropLeftTime(itemShopConfig)
	local startTime, endTime = self:getShopItemLimitTime(itemShopConfig)

	if endTime ~= nil then
		local leftTime = endTime - Time.secondCache

		return math.max(leftTime, 0)
	end

	return 0
end

function ShopBaseModel:getItemConfig(itemId)
	return ItemData[itemId]
end

function ShopBaseModel:isNewSellProp(shopItemId)
	local shopItemConfig = ShopCommodityData[shopItemId]

	if shopItemConfig.new ~= 1 or not self:isPropUnlock(shopItemId) then
		return false
	end

	local flag = pg.global.prefsCacheUtils:getInt(string.format(shopCheckNewPropTag, shopItemId), 0)

	return flag == 0
end

function ShopBaseModel:setCheckedNewProp(shopItemId)
	local shopItemConfig = ShopCommodityData[shopItemId]

	if shopItemConfig.new ~= 1 or not self:isPropUnlock(shopItemId) then
		return false
	end

	pg.global.prefsCacheUtils:setInt(string.format(shopCheckNewPropTag, shopItemId), 1)

	return true
end

function ShopBaseModel:deleteCheckedNewProp(shopItemId)
	local shopItemConfig = ShopCommodityData[shopItemId]

	if shopItemConfig.new == nil or shopItemConfig.new ~= 1 then
		return
	end

	pg.global.prefsCacheUtils:deleteKey(string.format(shopCheckNewPropTag, shopItemId))
end

function ShopBaseModel:getBuyLimit()
	return SysConfigData.SHOP_BUY_LIMIT
end

function ShopBaseModel:getBuyPriceInfo(shopItemId, buyCount)
	local shopItemConfig = self:getShopItemConfig(shopItemId)

	if shopItemConfig.specialCost ~= nil and self:isShopItemInSpecialTime(shopItemConfig) then
		local totalCost = Utils.deepCopyTable(shopItemConfig.specialCost)

		for i = 1, #totalCost do
			totalCost[i][2] = totalCost[i][2] * buyCount
		end

		return totalCost, shopItemConfig.cost
	end

	if shopItemConfig.cost == nil or #shopItemConfig.cost == 0 then
		return nil
	end

	local totalCost = Utils.deepCopyTable(shopItemConfig.cost)
	local hadBuyCount = pg.me.shopLevelCounts[shopItemId] or 0
	local totalCount = hadBuyCount + buyCount

	if shopItemConfig.levelCost == nil or #shopItemConfig.levelCost == 0 or totalCount < shopItemConfig.levelCost[1][1] then
		for j = 1, #totalCost do
			totalCost[j][2] = totalCost[j][2] * buyCount
		end
	else
		local lastPrice
		local totalPrice = {}

		for i = 1, #shopItemConfig.cost do
			table.insert(totalPrice, 0)
		end

		local levelCostCount = #shopItemConfig.levelCost

		for i = 1, levelCostCount do
			local levelCost = shopItemConfig.levelCost[i]
			local threshold = levelCost[1]

			if hadBuyCount < threshold then
				local curBuyCount = math.min(buyCount, threshold - hadBuyCount - 1)

				if lastPrice == nil then
					for j = 1, #shopItemConfig.cost do
						totalPrice[j] = totalPrice[j] + shopItemConfig.cost[j][2] * curBuyCount
					end
				else
					for j = 2, #lastPrice do
						totalPrice[j - 1] = totalPrice[j - 1] + lastPrice[j] * curBuyCount
					end
				end

				hadBuyCount = hadBuyCount + curBuyCount
				buyCount = buyCount - curBuyCount

				if buyCount == 0 then
					break
				end
			end

			lastPrice = levelCost

			if i == levelCostCount then
				for j = 2, #lastPrice do
					totalPrice[j - 1] = totalPrice[j - 1] + lastPrice[j] * buyCount
				end
			end
		end

		for i = 1, #totalCost do
			totalCost[i][2] = totalPrice[i]
		end
	end

	for i = 1, #totalCost do
		self:calcPriceOnRogue(totalCost[i])
	end

	return totalCost
end

function ShopBaseModel:calcPriceOnRogue(costArray)
	if not costArray or #costArray < 2 then
		return
	end

	if costArray[1] == ItemConst.ITEM_SPECIAL_ROGUE_COIN then
		local coinReduceP = pg.me.actorCombatAttribute:getAttribValue(AttributeConst.rogue_coin_cost_reduce_p)
		local coinReduceV = pg.me.actorCombatAttribute:getAttribValue(AttributeConst.rogue_coin_cost_reduce_v)

		costArray[2] = math.max(0, math.round(costArray[2] * (1 - coinReduceP) - coinReduceV))
	end
end

function ShopBaseModel:canBuyMaxCount(shopItemId)
	local shopItemConfig = self:getShopItemConfig(shopItemId)
	local canBuyMaxCount = math.min(ShopBaseModel:getBuyLimit(), self:getLeftBuyPropCount(shopItemId))
	local canBuyCount = canBuyMaxCount
	local specialCost = shopItemConfig.specialCost

	if specialCost ~= nil and self:isShopItemInSpecialTime(shopItemConfig) then
		for i = 1, #specialCost do
			local costItem = specialCost[i][1]
			local costCount = specialCost[i][2]
			local hadCount = self:getCostItemOwnCount(costItem)

			canBuyCount = math.min(math.floor(hadCount / costCount), canBuyCount)
		end

		return canBuyCount
	end

	if shopItemConfig.levelCost ~= nil then
		local hadBuyCount = pg.me.shopLevelCounts[shopItemId] or 0
		local cost = shopItemConfig.cost
		local hadItemCount = {}

		for i = 1, #cost do
			local costItem = cost[i][1]
			local hadCount = self:getCostItemOwnCount(costItem)

			table.insert(hadItemCount, hadCount)
		end

		local lastPrice
		local totalPrice = {}

		for i = 1, #shopItemConfig.cost do
			table.insert(totalPrice, 0)
		end

		local levelCostCount = #shopItemConfig.levelCost
		local lastThreshold = 0

		canBuyCount = 0

		for i = 1, levelCostCount do
			local levelCost = shopItemConfig.levelCost[i]
			local threshold = levelCost[1]

			if hadBuyCount < threshold then
				if lastPrice == nil then
					for k = 1, threshold - hadBuyCount - 1 do
						for j = 1, #shopItemConfig.cost do
							totalPrice[j] = totalPrice[j] + shopItemConfig.cost[j][2]

							if totalPrice[j] > hadItemCount[j] then
								return canBuyCount
							end
						end

						canBuyCount = canBuyCount + 1
					end
				else
					for k = lastThreshold, threshold - 1 do
						for j = 2, #lastPrice do
							totalPrice[j - 1] = totalPrice[j - 1] + lastPrice[j]

							if totalPrice[j - 1] > hadItemCount[j - 1] then
								return canBuyCount
							end
						end

						canBuyCount = canBuyCount + 1
					end
				end
			end

			lastThreshold = threshold
			lastPrice = levelCost

			if i == levelCostCount then
				for j = 2, #lastPrice do
					local curBuyCount = math.min(math.floor((hadItemCount[j - 1] - totalPrice[j - 1]) / lastPrice[j]), canBuyMaxCount - canBuyCount)

					return canBuyCount + curBuyCount
				end
			end
		end
	end

	local cost = shopItemConfig.cost

	if cost ~= nil then
		for i = 1, #cost do
			local costItem = cost[i][1]
			local costCount = cost[i][2]
			local hadCount = self:getCostItemOwnCount(costItem)

			canBuyCount = math.min(math.floor(hadCount / costCount), canBuyCount)
		end
	end

	return canBuyCount
end

function ShopBaseModel:isRareItem(itemId)
	local itemConfig = ItemData[itemId]

	if itemConfig and lume.find(SysConfigData.ITEM_QUALITY_WARN, itemConfig.quality) ~= nil then
		return true
	end

	return false
end

function ShopBaseModel:getItemDisplayType(itemConfig)
	return ItemShowTypeData[itemConfig.displayType].type
end

function ShopBaseModel:getItemConfigByShopItemId(shopItemId)
	local shopItemConfig = self:getShopItemConfig(shopItemId)

	return ItemData[shopItemConfig.itemId], shopItemConfig
end

function ShopBaseModel:getShopItemConfig(shopItemId)
	return ShopCommodityData[shopItemId]
end

function ShopBaseModel:prepareShopRefreshList(shopTags)
	self._refreshShopIds = {}
	self._refreshShopState = {}

	if not shopTags then
		return
	end

	for i = 1, #shopTags do
		local tag = shopTags[i]
		local tagId = Utils.isTable(tag) and tag.id or tag

		if tagId then
			local tagCfg = ShopTagData[tagId]
			local refreshType = tagCfg and tagCfg.refreshType or 0
			local refreshLimit = tagCfg and tagCfg.refreshLimit or 0

			if refreshType > 0 and refreshLimit > 0 then
				self._refreshShopState[tagId] = REFRESH_LIST_STATUS.PENDING
			end
		end
	end
end

function ShopBaseModel:setShopRefreshList(tagId, cidList)
	self._refreshShopIds = self._refreshShopIds or {}
	self._refreshShopState = self._refreshShopState or {}

	local set = {}

	if cidList then
		for i = 1, #cidList do
			set[cidList[i]] = true
		end
	end

	self._refreshShopIds[tagId] = set
	self._refreshShopState[tagId] = REFRESH_LIST_STATUS.READY
end

function ShopBaseModel:setShopRefreshDisabled(tagId)
	self._refreshShopIds = self._refreshShopIds or {}
	self._refreshShopState = self._refreshShopState or {}
	self._refreshShopIds[tagId] = nil
	self._refreshShopState[tagId] = REFRESH_LIST_STATUS.DISABLED
end

function ShopBaseModel:setShopRefreshRequestFailed(tagId)
	self._refreshShopIds = self._refreshShopIds or {}
	self._refreshShopState = self._refreshShopState or {}
	self._refreshShopIds[tagId] = {}
	self._refreshShopState[tagId] = REFRESH_LIST_STATUS.FAILED
end

function ShopBaseModel:clearShopRefreshList(tagId)
	if tagId then
		if self._refreshShopIds then
			self._refreshShopIds[tagId] = nil
		end

		if self._refreshShopState then
			self._refreshShopState[tagId] = nil
		end
	else
		self._refreshShopIds = {}
		self._refreshShopState = {}
	end
end

function ShopBaseModel:isInRefreshList(tagId, shopItemId)
	local state = self._refreshShopState and self._refreshShopState[tagId]

	if state == nil then
		return true
	end

	if state == REFRESH_LIST_STATUS.DISABLED then
		return true
	end

	if state ~= REFRESH_LIST_STATUS.READY then
		return false
	end

	local set = self._refreshShopIds and self._refreshShopIds[tagId]

	if set == nil then
		return false
	end

	return set[shopItemId] == true
end

function ShopBaseModel:getShopItemLimitInfo(shopItemCfg, curShopItemId)
	if shopItemCfg.limitId and LimitData[shopItemCfg.limitId] then
		local limitCfg = LimitData[shopItemCfg.limitId]
		local title = self:getLimitTitleString(limitCfg.type or 0) .. ":"
		local hadBuyCount = pg.me.shopGroupLimitCounts[shopItemCfg.limitId] or 0
		local totalCount = limitCfg.countLimit
		local desc = self:getLimitIdDesc(shopItemCfg.limitId)

		return true, title, hadBuyCount, totalCount, desc
	elseif shopItemCfg.limitType == Const.LIMIT_SCENE then
		local player = pg.me
		local space = player and player.space
		local curSceneId = space and space.sceneId or 0

		if space and space:isGrabEgg() then
			local dungeonSceneId = player:getDungeonSceneId()

			if dungeonSceneId and dungeonSceneId > 0 then
				curSceneId = dungeonSceneId
			end
		end

		local isSameScene = ShopCommonHelper.isHitSceneLimit(shopItemCfg, curSceneId)

		if shopItemCfg.limitNum and shopItemCfg.limitNum > 0 and isSameScene then
			local title = self:getLimitTitleString(shopItemCfg.limitType or 0) .. ":"
			local hadBuyCount = pg.me.sceneLimitCounts and pg.me.sceneLimitCounts[curShopItemId] or 0
			local totalCount = shopItemCfg.limitNum

			return true, title, hadBuyCount, totalCount
		end

		return false
	else
		local shopLimitExtraCounts = pg.me.shopLimitExtraCounts[curShopItemId] or 0

		if shopItemCfg.limitNum and shopItemCfg.limitNum + shopLimitExtraCounts > 0 then
			local title = self:getLimitTitleString(shopItemCfg.limitType or 0) .. ":"
			local hadBuyCount = pg.me.shopLimitCounts[curShopItemId] or 0
			local totalCount = shopItemCfg.limitNum + shopLimitExtraCounts

			return true, title, hadBuyCount, totalCount
		end
	end

	return false
end

function ShopBaseModel:getLimitIdDesc(limitId)
	local limitCfg = LimitData[limitId]
	local shopItemIds = LimitRevertData[limitId]

	if not limitCfg or not shopItemIds or #shopItemIds == 0 then
		return nil
	end

	local limitText = string.format("%s%d", self:getLimitTitleString(limitCfg.type or 0), limitCfg.countLimit)
	local itemFormatText = pg.getGameString("SHOP_LIMIT_ID_ITEN_DESC")
	local lines = {}

	for _, shopItemId in ipairs(shopItemIds) do
		local shopItemCfg = self:getShopItemConfig(shopItemId)

		if shopItemCfg then
			local shopTagCfg = self:getShopTagConfig(shopItemCfg.tag)
			local itemCfg = self:getDisplayItemConfig(shopItemCfg)

			if shopTagCfg and itemCfg then
				lines[#lines + 1] = {
					shopSort = shopTagCfg.sort or math.huge,
					itemSort = shopItemCfg.sort or math.huge,
					text = pg.getFormatText(itemFormatText, pg.getLocalizationText(shopTagCfg.name), pg.getLocalizationText(itemCfg.itemName))
				}
			end
		end
	end

	if #lines == 0 then
		return nil
	end

	table.sort(lines, function(a, b)
		if a.shopSort ~= b.shopSort then
			return a.shopSort < b.shopSort
		elseif a.itemSort ~= b.itemSort then
			return a.itemSort < b.itemSort
		else
			return a.shopItemId < b.shopItemId
		end
	end)

	local lineTexts = {}

	for i = 1, #lines do
		lineTexts[i] = lines[i].text
	end

	return pg.getFormatText(pg.getGameString("SHOP_LIMIT_ID_DESC"), limitText, table.concat(lineTexts, "\n"))
end

function ShopBaseModel:getDisplayItemConfig(shopItemCfg)
	local itemId = shopItemCfg.itemId

	if pg.me then
		local replacedItemCountTable = ItemUtils.getReplacedItemCountTable(pg.me, {
			[itemId] = shopItemCfg.itemNum or 1
		})

		itemId = next(replacedItemCountTable) or itemId
	end

	return self:getItemConfig(itemId)
end

function ShopBaseModel:getItemQualityInfoConfig()
	local items = {}

	for k, v in pairs(ItemQuality) do
		table.insert(items, {
			selected = false,
			id = k,
			name = v.name
		})
	end

	local function sortFunc(a, b)
		return a.id < b.id
	end

	table.sort(items, sortFunc)

	return items
end

function ShopBaseModel:isPropUnlock(shopItemId)
	local shopItemConfig = self:getShopItemConfig(shopItemId)

	if shopItemConfig.condition ~= nil and shopItemConfig.condition ~= 0 then
		return pg.me.triggerMap:isCompleteOrMeetCondition(shopItemConfig.condition)
	end

	return true
end

function ShopBaseModel:isPropHideByCondition(shopItemConfig)
	if not shopItemConfig or shopItemConfig.hideByCondition ~= 1 then
		return false
	end

	if shopItemConfig.condition == nil or shopItemConfig.condition == 0 then
		return false
	end

	if not pg.me or not pg.me.triggerMap then
		return false
	end

	return not pg.me.triggerMap:isCompleteOrMeetCondition(shopItemConfig.condition)
end

function ShopBaseModel:getPropUnlockDesc(shopItemConfig, overrideDescMap, overrideHandler)
	if shopItemConfig.condition ~= nil and shopItemConfig.condition ~= 0 then
		if shopItemConfig.showConditionNum == 1 then
			local numDesc = LuaUIUtils.getConditionTriggerNumDesc(shopItemConfig.condition)

			if numDesc ~= "" then
				return numDesc
			end
		end

		return LuaUIUtils.getConditionUnlockDesc(shopItemConfig.condition, overrideDescMap, overrideHandler)
	end

	return false
end

function ShopBaseModel:getLeftBuyPropCount(shopItemId)
	local buyCountLimit = self:getBuyLimit()
	local shopItemConfig = self:getShopItemConfig(shopItemId)
	local hasLimit, _, limitHadBuyCount, limitTotalCount = self:getShopItemLimitInfo(shopItemConfig, shopItemId)

	if hasLimit then
		return limitTotalCount - limitHadBuyCount
	end

	return buyCountLimit
end

function ShopBaseModel:isPropSellOut(shopItemId)
	local shopItemConfig = self:getShopItemConfig(shopItemId)
	local hasLimit, _, limitHadBuyCount, limitTotalCount = self:getShopItemLimitInfo(shopItemConfig, shopItemId)

	if hasLimit then
		return limitTotalCount <= limitHadBuyCount, limitTotalCount - limitHadBuyCount
	end

	return false, math.huge
end

function ShopBaseModel:isPropLimitNum(shopItemId)
	local shopItemConfig = self:getShopItemConfig(shopItemId)
	local hasLimit = self:getShopItemLimitInfo(shopItemConfig, shopItemId)

	return hasLimit
end

function ShopBaseModel:isPropInsufficient(shopItemId, buyCount)
	local ret, leftCount = self:isPropSellOut(shopItemId)

	if not ret and leftCount < buyCount then
		return true
	end

	return false
end

function ShopBaseModel:getCostItemOwnCount(itemId)
	local ownCount = pg.me:getItemCountById(itemId)
	local itemCfg = ItemData[itemId]

	if itemCfg and itemCfg.isHomeItem == 1 and pg.me:isInSelfHomeland() then
		ownCount = ownCount + ClientUtils.getHomelandItemCountById(itemId)
	end

	return ownCount
end

function ShopBaseModel:isCurrencyEnough(shopItemId, buyCount)
	local cost = self:getBuyPriceInfo(shopItemId, buyCount)

	if cost == nil or #cost > 0 and cost[1][2] == 0 then
		return true
	end

	local costIdNums = {}

	for i = 1, #cost do
		local costItem = cost[i][1]

		costIdNums[costItem] = (costIdNums[costItem] or 0) + cost[i][2]
	end

	local _, adjustedCostIdNums = ItemUtils.adjustCostIdNumsWithBoundCashFallback(pg.me, costIdNums)
	local notEnoughItems = {}
	local isEnough = true

	for costItem, costCount in pairs(adjustedCostIdNums) do
		local hadCount = self:getCostItemOwnCount(costItem)

		if hadCount < costCount then
			isEnough = false

			table.insert(notEnoughItems, costItem)
		end
	end

	return isEnough, notEnoughItems
end

function ShopBaseModel:getBoundCashExchangeNum(shopItemId, buyCount)
	local cost = self:getBuyPriceInfo(shopItemId, buyCount)

	if cost == nil then
		return nil
	end

	local needCoinBound = 0

	for i = 1, #cost do
		if cost[i][1] == ItemConst.ITEM_SPECIAL_MONEY_COIN_BOUND then
			needCoinBound = needCoinBound + cost[i][2]
		end
	end

	if needCoinBound <= 0 then
		return nil
	end

	local ownCoinBound = pg.me:getMoneyNum(ItemConst.ITEM_SPECIAL_MONEY_COIN_BOUND)

	if needCoinBound <= ownCoinBound then
		return nil
	end

	local deficit = needCoinBound - ownCoinBound
	local ownCashBound = pg.me:getMoneyNum(ItemConst.ITEM_SPECIAL_MONEY_CASH_BOUND)

	if ownCashBound < deficit then
		return nil
	end

	return deficit
end

function ShopBaseModel:isPropLocked(itemData)
	return itemData:hasStatus(ItemConst.ITEM_STATUS_LOCKED)
end

function ShopBaseModel:getSellPrice(itemId, count)
	local itemConfig = self:getItemConfig(itemId)

	if itemConfig ~= nil and itemConfig.sellPrice ~= nil then
		return itemConfig.sellPrice[2] * count, itemConfig.sellPrice[1]
	end

	return 0, 0
end

function ShopBaseModel:buyCommodity(shopClassifyId, commodityId, num)
	pg.me:buyCommodity(shopClassifyId, commodityId, num)
end

function ShopBaseModel:sellItemByGenId(inveId, items, costItem, totalPrice)
	pg.me:sellItemByGenId(inveId, items, costItem, totalPrice)
end

function ShopBaseModel:getGameString(key)
	local str = GameStringConfig[key]

	if str ~= nil then
		return pg.getLocalizationText(str.desc)
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("GameString获取不到！", key)
	end
end

function ShopBaseModel:getLimitTitleString(limitType)
	local str = ""

	if limitType == 1 then
		str = pg.getGameString("SHOP_ITEM_LIMIT_DAY")
	elseif limitType == 2 then
		str = pg.getGameString("SHOP_ITEM_LIMIT_WEEK")
	elseif limitType == 3 then
		str = pg.getGameString("SHOP_ITEM_LIMIT_MONTH")
	elseif limitType == 4 then
		str = pg.getGameString("SHOP_ITEM_LIMIT_SCENE")
	else
		str = pg.getGameString("SHOP_ITEM_LIMIT_FOREVER")
	end

	return str
end

return ShopBaseModel
