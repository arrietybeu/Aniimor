-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketPetDetail\\TradeMarketPetDetailBaseCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("TradeMarketPetDetailBaseCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local Time = require("Core.Common.Time")
local TradeMarketUtils = require("Guis.Utils.TradeMarketUtils")
local InfiniteScrollList = require("Guis.Helper.InfiniteScrollList")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local Utils = require("Common.Utils.Utils")
local TradeItemData = require("Data.trade_items_data")
local PetData = require("Data.pet_data")
local TradeConst = require("Common.Const.TradeConst")
local NoticeDef = require("Common.NoticeDef")
local TradeMarketPetInfoComponent = require("Guis.Panels.TradeMarketSellPet.Component.TradeMarketSellPetDetailComponent")
local TradeMarketPetDetailBaseCtrl = Class.LightClass("TradeMarketPetDetailBaseCtrl", UICtrl)

TradeMarketPetDetailBaseCtrl.messages = {
	[MessageName.ON_GET_TRADE_LISTINGS] = {
		"onGetTradeListings",
		true
	}
}

local PET_LISTING_PAGE_LIMIT = 20
local PET_LISTING_REFRESH_INTERVAL = 30
local PET_LISTING_STATUS_LIST_MAP = {
	[TradeMarketUtils.ListTab.OnSale] = {
		TradeConst.LISTING_STATUS.SELLING,
		TradeConst.LISTING_STATUS.RUSH
	},
	[TradeMarketUtils.ListTab.OnNotice] = {
		TradeConst.LISTING_STATUS.NOTICE
	}
}

function TradeMarketPetDetailBaseCtrl:createPetDetailComponent()
	return TradeMarketPetInfoComponent.new(self)
end

function TradeMarketPetDetailBaseCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.petDetails = self:createPetDetailComponent()
end

function TradeMarketPetDetailBaseCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:dismiss()
	end

	function self.view.listTab3thUList.luaRenderItem(button, index, data)
		TradeMarketUtils.renderListTabItem(button, index, data)
	end

	function self.view.listTab3thUList.luaClick(button, data)
		self:refreshPetListOnClickTab(data)
	end

	function self.view.btnSortUButton.luaClick()
		self:openPetFilterPanel()
	end

	function self.view.listPetUList.luaRenderItem(button, index, data)
		TradeMarketUtils.renderMyOnSellPetItem(button, index, data)
	end

	ClientTextUtils.setText(self.view.txtTipsUSDFText, "")
end

function TradeMarketPetDetailBaseCtrl:closeImmediately()
	self:clearPetModel()
	UICtrl.closeImmediately(self)
end

function TradeMarketPetDetailBaseCtrl:onDestroy()
	if self.petInfiniteScrollList then
		self.petInfiniteScrollList:destroy()

		self.petInfiniteScrollList = nil
	end

	self.petListingRequests = nil
	self.petListingCache = nil
	self.petListingFilter = nil
	self.curPetInfo = nil
	self.curPetId = nil

	UICtrl.onDestroy(self)
end

function TradeMarketPetDetailBaseCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.petTemplateId = info.cfgId
	self.tradeItemCfg = TradeItemData[info.cfgId] or {}
	self.petName = TradeMarketUtils.getPetName(self.petTemplateId)
	self.tradeItemKey = string.format("%d:%d", TradeMarketUtils.SubPageType.Pet, self.petTemplateId)
	self.petListingRequests = {}
	self.petListingCache = {}
	self.petListingFilter = nil

	LuaUIUtils.setTopCurrencyItemList(self.view.listCurrencyUList, self.uid)

	self.petInfiniteScrollList = InfiniteScrollList.new(self.view.listPetUList, {
		onRequestNextPage = function(offset, requestToken, owner)
			self:requestPetListingsPage(offset, requestToken, owner)
		end,
		getItemKey = function(data)
			return data.listingId
		end
	})
	self.listTabData = TradeMarketUtils.getListTab(self.tradeItemCfg.isNotice == 1, false)

	self.view.listTab3thUList:SetList(self.listTabData)

	self.curListTabData = self.listTabData[1]

	if info.listingData and info.listingData.status == TradeConst.LISTING_STATUS.NOTICE then
		for _, tabData in ipairs(self.listTabData) do
			if tabData.tabIndex == TradeMarketUtils.ListTab.OnNotice then
				self.curListTabData = tabData

				break
			end
		end
	end

	self.curListTabIndex = self.curListTabData and self.curListTabData.tabIndex

	if self.curListTabData then
		self.view.listTab3thUList:SelectItem(self.curListTabData.index, false)
	end
end

function TradeMarketPetDetailBaseCtrl:onShow()
	UICtrl.onShow(self)
	self:refreshPetListOnClickTab(self.curListTabData or self.listTabData[1])
end

function TradeMarketPetDetailBaseCtrl:refreshPetListOnClickTab(tabData)
	if not tabData then
		return
	end

	self.curListTabData = tabData
	self.curListTabIndex = tabData.tabIndex

	self.view.listTab3thUList:SelectItem(tabData.index, false)

	self.petListingRequests = {}

	local cache = self.petListingCache and self.petListingCache[self.curListTabIndex]

	if self:isPetListingCacheFresh(cache) then
		self:refreshPetListingsFromCache(false)

		return
	end

	self:clearPetListingCache(self.curListTabIndex)
	self:onPetListingsChanged({})
	self.petInfiniteScrollList:reset(0)
end

function TradeMarketPetDetailBaseCtrl:requestPetListingsPage(offset, requestToken, owner)
	offset = offset or 0

	local tabIndex = self.curListTabIndex
	local statusList = self:getCurrentPetListingStatusList()
	local requestData = {
		requestToken = requestToken,
		owner = owner,
		tabIndex = tabIndex,
		statusList = statusList
	}

	self.petListingRequests[offset] = requestData

	pg.me:reqGetTradeListings(statusList, self.tradeItemKey, PET_LISTING_PAGE_LIMIT, offset, function(noticeCode)
		if not self.petListingRequests or self.petListingRequests[offset] ~= requestData then
			return
		end

		if noticeCode == NoticeDef.SUCCESS then
			return
		end

		self.petListingRequests[offset] = nil

		owner:rejectPage(requestToken)
	end)
end

function TradeMarketPetDetailBaseCtrl:onGetTradeListings(data)
	if not data or data.tradeItemKey ~= self.tradeItemKey or not self.petListingRequests then
		return
	end

	local offset = data.offset or 0
	local requestData = self.petListingRequests[offset]
	local statusList = data.statusList

	if not requestData or requestData.tabIndex ~= self.curListTabIndex or not self:isSamePetListingStatusList(requestData.statusList, statusList) then
		return
	end

	self.petListingRequests[offset] = nil

	local nextOffset = offset + (data.limit or PET_LISTING_PAGE_LIMIT)
	local hasMore = nextOffset < (data.total or 0)
	local accepted = requestData.owner:appendPage(requestData.requestToken, {}, nextOffset, hasMore)

	if accepted then
		self:updatePetListingCache(requestData.tabIndex, data.limit, offset, data.listings, data.total)
		self:refreshPetListingsFromCache(true)
	end
end

function TradeMarketPetDetailBaseCtrl:getCurrentPetListingStatusList()
	return PET_LISTING_STATUS_LIST_MAP[self.curListTabIndex] or {}
end

function TradeMarketPetDetailBaseCtrl:isCurrentPetListingStatus(status)
	for _, currentStatus in ipairs(self:getCurrentPetListingStatusList()) do
		if currentStatus == status then
			return true
		end
	end

	return false
end

function TradeMarketPetDetailBaseCtrl:isSamePetListingStatusList(left, right)
	if not Utils.isTable(left) or not Utils.isTable(right) or #left ~= #right then
		return false
	end

	local statusMap = {}

	for _, status in ipairs(left) do
		statusMap[status] = true
	end

	for _, status in ipairs(right) do
		if not statusMap[status] then
			return false
		end
	end

	return true
end

function TradeMarketPetDetailBaseCtrl:isPetListingCacheFresh(cache)
	return cache ~= nil and Time.realSecondCache - (cache.refreshTime or 0) < PET_LISTING_REFRESH_INTERVAL
end

function TradeMarketPetDetailBaseCtrl:clearPetListingCache(tabIndex)
	if not self.petListingCache then
		return
	end

	if tabIndex then
		self.petListingCache[tabIndex] = nil
	else
		self.petListingCache = {}
	end
end

function TradeMarketPetDetailBaseCtrl:updatePetListingCache(tabIndex, limit, offset, listings, total)
	if not self.petListingCache then
		return
	end

	limit = limit or PET_LISTING_PAGE_LIMIT
	offset = offset or 0
	listings = listings or {}

	local cache = self.petListingCache[tabIndex]

	if not cache or offset == 0 then
		cache = {
			items = {},
			itemIndexMap = {}
		}
		self.petListingCache[tabIndex] = cache
	end

	for _, listingData in ipairs(listings) do
		local listingId = listingData.listingId
		local itemIndex = listingId and cache.itemIndexMap[listingId]

		if itemIndex then
			cache.items[itemIndex] = listingData
		else
			cache.items[#cache.items + 1] = listingData

			if listingId then
				cache.itemIndexMap[listingId] = #cache.items
			end
		end
	end

	cache.total = total or #cache.items
	cache.nextOffset = offset + limit
	cache.hasMore = cache.nextOffset < cache.total

	if offset == 0 then
		cache.refreshTime = Time.realSecondCache
	end
end

function TradeMarketPetDetailBaseCtrl:filterPetListings(listings)
	local listingInfos = {}

	for _, listingData in ipairs(listings or EMPTY_TABLE) do
		if self:isCurrentPetListingStatus(listingData.status) then
			local listingInfo = self:getPetListingFilterInfo(listingData)

			if self:isPetListingMatched(listingInfo, self.petListingFilter) then
				listingInfos[#listingInfos + 1] = listingInfo
			end
		end
	end

	local ret = {}

	for _, listingInfo in ipairs(listingInfos) do
		ret[#ret + 1] = listingInfo.listingData
	end

	return ret
end

function TradeMarketPetDetailBaseCtrl:refreshPetListingsFromCache(keepPosition)
	local cache = self.petListingCache and self.petListingCache[self.curListTabIndex]

	if not cache or not self.petInfiniteScrollList then
		return
	end

	local listings = self:filterPetListings(cache.items)

	self.petInfiniteScrollList:setData(listings, cache.nextOffset, cache.hasMore, keepPosition)
	self:onPetListingsChanged(listings)

	if cache.hasMore and #listings == 0 then
		self.petInfiniteScrollList:requestNextPage()
	end

	self:showCurCountOnSale(cache.total)
end

function TradeMarketPetDetailBaseCtrl:isPetListingFollowed(listingData)
	local tradeItemKey = listingData and listingData.tradeItemKey or self.tradeItemKey

	return pg.me:isTradeItemFollow(tradeItemKey)
end

function TradeMarketPetDetailBaseCtrl:getPetListingFilterInfo(listingData)
	local pet = PetManagementDataHelper.convertTableToPetInfo(listingData.assetSnapshot)
	local templateId = pet and pet.templateId or self.petTemplateId
	local petConfig = PetData[templateId] or {}
	local _, elementNames = LuaUIUtils.getElementInfo(petConfig.elementType)
	local formTypeId = Utils.getPetFormIdByTemplateId(templateId)
	local rating = pet and pet:getPropRatingResult() or 0
	local isShiny = pet and Utils.isLabelShiny(pet.label) or false
	local isBoss = pet and Utils.isLabelElite(pet.label) or false
	local isMagic = pet and Utils.isLabelMagic(pet.label) or false
	local isRainbow = pet and Utils.isRainbowTypeByTemplateId(templateId) or false
	local isBlackRainbow = pet and Utils.isBlackRainbowTypeByTemplateId(templateId) or false

	return {
		listingData = listingData,
		templateId = templateId,
		unitPrice = listingData.unitPrice or 0,
		isFollow = self:isPetListingFollowed(listingData),
		rating = rating,
		isNormal = pet ~= nil and not isShiny and not isBoss and not isMagic and not isRainbow and not isBlackRainbow,
		isShiny = isShiny,
		isBoss = isBoss,
		isRainbow = isRainbow or isBlackRainbow,
		elementNames = elementNames or {},
		petType = petConfig.functionId,
		formTypeId = formTypeId
	}
end

function TradeMarketPetDetailBaseCtrl:isPetListingMatched(listingInfo, filter)
	if not filter then
		return true
	end

	if not string.isNilOrEmpty(filter.keyword) then
		local petName = TradeMarketUtils.getPetName(listingInfo.templateId)

		if string.find(petName, filter.keyword, 1, true) == nil then
			return false
		end
	end

	if filter.isFollow or filter.isNotFollow then
		local followMatched = filter.isFollow and listingInfo.isFollow or filter.isNotFollow and not listingInfo.isFollow

		if not followMatched then
			return false
		end
	end

	if filter.minPrice and listingInfo.unitPrice < filter.minPrice then
		return false
	end

	if filter.maxPrice and not filter.isPriceOver and listingInfo.unitPrice > filter.maxPrice then
		return false
	end

	local hasRarityFilter = filter.isNormal or filter.isShiny or filter.isBoss or filter.isRainbow

	if hasRarityFilter then
		local rarityMatched = filter.isNormal and listingInfo.isNormal or filter.isShiny and listingInfo.isShiny or filter.isBoss and listingInfo.isBoss or filter.isRainbow and listingInfo.isRainbow

		if not rarityMatched then
			return false
		end
	end

	if filter.elements and next(filter.elements) ~= nil then
		local elementMatched = false

		for _, elementData in ipairs(listingInfo.elementNames) do
			if filter.elements[elementData.element] ~= nil then
				elementMatched = true

				break
			end
		end

		if not elementMatched then
			return false
		end
	end

	local hasRatingFilter = filter.isRating1 or filter.isRating2 or filter.isRating3 or filter.isRating4

	if hasRatingFilter then
		local ratingMatched = filter.isRating1 and listingInfo.rating == 0 or filter.isRating2 and listingInfo.rating == 1 or filter.isRating3 and listingInfo.rating == 2 or filter.isRating4 and listingInfo.rating == 3

		if not ratingMatched then
			return false
		end
	end

	local hasRoleFilter = filter.isDPS or filter.isSup or filter.isHeal or filter.isBreak or filter.isEnergy

	if hasRoleFilter then
		local roleMatched = filter.isDPS and Utils.isMatchPetFuncType(listingInfo.petType, UIConst.NEW_PET_BATTLE_TYPE.DPS) or filter.isSup and Utils.isMatchPetFuncType(listingInfo.petType, UIConst.NEW_PET_BATTLE_TYPE.SUP) or filter.isHeal and Utils.isMatchPetFuncType(listingInfo.petType, UIConst.NEW_PET_BATTLE_TYPE.HEAL) or filter.isBreak and Utils.isMatchPetFuncType(listingInfo.petType, UIConst.NEW_PET_BATTLE_TYPE.BREAK) or filter.isEnergy and Utils.isMatchPetFuncType(listingInfo.petType, UIConst.NEW_PET_BATTLE_TYPE.ENERGY) or false

		if not roleMatched then
			return false
		end
	end

	local selectedFormTypeMap, hasFormFilter = PetManagementDataHelper.getSelectedFormTypeMap(filter)

	if hasFormFilter and not selectedFormTypeMap[listingInfo.formTypeId] then
		return false
	end

	return true
end

function TradeMarketPetDetailBaseCtrl:refreshPetDetail(petData, previewPetInfo)
	if self.uiScene then
		self.uiScene:switchBackground("T_LVUIBP_BackGroud_03_CA.png")
	end

	if not petData or petData.isEmpty then
		self.petDetails:refreshPetInfoDetail({
			isEmpty = true
		})

		if previewPetInfo and previewPetInfo.templateId then
			self:showPetModel(previewPetInfo)
		else
			self:clearPetModel()
		end

		return
	end

	local displayPetData = self.petDetails:refreshPetInfoDetail(petData)

	self:showPetModel(displayPetData or previewPetInfo or petData)
end

function TradeMarketPetDetailBaseCtrl:onPetListingsChanged(listings)
	return
end

function TradeMarketPetDetailBaseCtrl:showPetModel(petInfo)
	if not petInfo or not petInfo.templateId or not self.uiScene then
		return
	end

	if self.curPetInfo and self.curPetInfo.templateId ~= petInfo.templateId then
		self.uiScene:destroyPet(self.curPetInfo.templateId)
	end

	self.curPetInfo = petInfo
	self.curPetId = petInfo.id

	local scale, offset = self.model.getPetScaleAndOffset(petInfo.templateId)

	self.uiScene:showPetTemplate(petInfo, scale, offset)

	local entity = self.uiScene:getEntity(petInfo.templateId)

	if entity and self.petDetails.applyPetModelAppearance then
		self.petDetails:applyPetModelAppearance(entity, petInfo)
	end
end

function TradeMarketPetDetailBaseCtrl:clearPetModel()
	if self.curPetInfo and self.curPetInfo.templateId and self.uiScene then
		self.uiScene:destroyPet(self.curPetInfo.templateId)
	end

	self.curPetInfo = nil
	self.curPetId = nil
end

function TradeMarketPetDetailBaseCtrl:openPetFilterPanel()
	local minPrice = TradeMarketUtils.getFreePriceMin()
	local maxPrice = TradeMarketUtils.getFreePriceMax()

	pg.global.ui.petManagementFilter:open({
		disableSessionCache = true,
		noTab = true,
		filterType = UIConst.PET_SLOT_DISPLAY_TYPE.TradeMarketPet,
		minPriceLimit = minPrice,
		maxPriceLimit = maxPrice,
		filter = self.petListingFilter,
		doFilterCallback = function(filter)
			self:filterPets(filter)
		end
	})
end

function TradeMarketPetDetailBaseCtrl:filterPets(filter)
	self.petListingFilter = Utils.deepCopyTable(filter or {})

	self:clearPetListingCache()

	self.petListingRequests = {}

	self:onPetListingsChanged({})
	self.petInfiniteScrollList:reset(0)
end

function TradeMarketPetDetailBaseCtrl:showCurCountOnSale(count)
	ClientTextUtils.setText(self.view.txtTipsUSDFText, string.format(pg.getGameString("PETS_NUM_ON_SALE"), count, self.petName))
end

return TradeMarketPetDetailBaseCtrl
