-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandCollectionCrop\\HomelandCollectionCropCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("HomelandCollectionCropCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local Time = require("Core.Common.Time")
local TimeUtils = require("Common.Utils.TimeUtils")
local Utils = require("Common.Utils.Utils")
local UIConst = require("Const.UIConst")
local RedDotConst = require("Const.RedDotConst")
local NoticeDef = require("Common.NoticeDef")
local HomeSeasonData = require("Data.home_season_data")
local HomeSeasonMutationCategoryData = require("Data.home_season_mutation_category_data")
local HomeSeasonMutationCollectionData = require("Data.home_season_mutation_collection_data")
local HomeSeasonMutationCollectionRewardData = require("Data.home_season_mutation_collection_reward_data")
local HomelandConfigData = require("Data.homeland_config_data")
local HomeSeasonConfigData = require("Data.home_season_config_data")
local HomeSeasonUtils = require("Utils.HomeSeasonUtils")
local CATEGORY_CARD_COUNT = 2
local REMAIN_TIME_REFRESH_INTERVAL = 1
local HomelandCollectionCropCtrl = Class.LightClass("HomelandCollectionCropCtrl", UICtrl)

HomelandCollectionCropCtrl.messages = {
	[MessageName.HOME_SEASON_MUTATION_COLLECTION_CHANGE] = {
		"onMutationCollectionChanged",
		true
	},
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"onMutationCropItemCountChanged",
		true
	},
	[MessageName.HOMELAND_ITEM_MAP_CHANGED] = {
		"onMutationCropItemCountChanged",
		true
	}
}

function HomelandCollectionCropCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.exchangeShopId = info and info.exchangeShopId or HomeSeasonConfigData.SeasonShopType or 51
	self.seasonId = pg.me and pg.me.homeSeasonId or 1
	self.isReceivingReward = false

	if not self.seasonId or self.seasonId == 0 then
		self:close()

		return
	end

	self.categoryList = self:getCategoryList()

	local seasonInfo = HomeSeasonData[self.seasonId] or {}

	self.seasonEndTime = Utils.getConfigTimeOfAreaByData(seasonInfo.endDayTime, seasonInfo.endDayTimeRefId)

	self:refreshCollectionCropPageInfo()
	self:startRemainTimeTimer()
end

function HomelandCollectionCropCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	function self.view.btnDecomposeUButton.luaClick()
		if not self:hasDecomposableCrop() then
			pg.global.showBubbleMessageRaw(pg.getGameString("HOMELAND_SEASON_CROP_NO_DECOMPOSABLE_CROP"))

			return
		end

		pg.global.ui:open(UIConst.UI_ID_HOME_SEASON_COLLECTIONCROP_DECOMPOSE)
	end

	function self.view.btnExchangeUButton.luaClick()
		if LuaUIUtils.checkFuncTemporaryDisable(UIConst.UI_ID_SHOP_MAIN) then
			return
		end

		pg.global.ui:open(UIConst.UI_ID_SHOP_MAIN, {
			shopTags = {
				self.exchangeShopId
			},
			shopTag = HomeSeasonConfigData.SeasonShopType or 51
		})
	end

	function self.view.listUList.luaRenderItem(button, index, data)
		self:renderRewardItem(button, index, data)
	end

	function self.view.card1UButton.luaClick()
		self:openCategoryDetail(1)
	end

	function self.view.card2UButton.luaClick()
		self:openCategoryDetail(2)
	end
end

function HomelandCollectionCropCtrl:hasDecomposableCrop()
	for itemId, collectionInfo in pairs(HomeSeasonMutationCollectionData) do
		if collectionInfo.seasonId == self.seasonId then
			local itemCount = ClientUtils.getItemCountById(itemId)

			if pg.me:isInSelfHomeland() then
				itemCount = itemCount + ClientUtils.getHomelandItemCountById(itemId)
			end

			if itemCount > 0 then
				return true
			end
		end
	end

	return false
end

function HomelandCollectionCropCtrl:refreshCategoryCardRedDot(index, categoryData)
	if not index or not categoryData then
		return
	end

	local cardButton = self.view["card" .. index .. "UButton"]
	local redDotPath = string.format(RedDotConst.RedDotPath.HOME_SEASON_MUTATION_CATEGORY_CARD, self.seasonId, index)
	local showRedDot = HomeSeasonUtils.hasCollectableHomeSeasonMutationCrop(pg.me, self.seasonId, categoryData.typeId) or false

	pg.global.setRedDot(redDotPath, cardButton, showRedDot, RedDotConst.RedDotStyle.POINT)
end

function HomelandCollectionCropCtrl:openCategoryDetail(index)
	local categoryData = self.categoryList and self.categoryList[index]

	if not categoryData then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_HOME_SEASON_COLLECTIONCROP_DETAIL, {
		typeId = categoryData.typeId
	})
end

function HomelandCollectionCropCtrl:getCategoryList()
	local categoryList = {}

	for typeId, categoryInfo in pairs(HomeSeasonMutationCategoryData or EMPTY_TABLE) do
		if categoryInfo.seasonId == self.seasonId then
			categoryList[#categoryList + 1] = {
				typeId = typeId,
				name = categoryInfo.name,
				icon = categoryInfo.icon,
				maxCount = categoryInfo.num or 0
			}
		end
	end

	table.sort(categoryList, function(a, b)
		return a.typeId < b.typeId
	end)

	return categoryList
end

function HomelandCollectionCropCtrl:getRewardListData(currentTotalStar)
	local rewardReceivedMap = pg.me and pg.me.homeSeasonMutationRewardReceived or {}
	local rewardListData = {}
	local maxRewardStar = 0

	for rewardId, rewardInfo in pairs(HomeSeasonMutationCollectionRewardData or EMPTY_TABLE) do
		if rewardInfo.seasonId == self.seasonId then
			local needPoint = rewardInfo.needPoint or 0

			rewardListData[#rewardListData + 1] = {
				id = rewardId,
				numMax = needPoint,
				rewardId = rewardInfo.reward,
				isReceived = rewardReceivedMap[rewardId] == true,
				canReceive = needPoint <= currentTotalStar
			}
			maxRewardStar = math.max(maxRewardStar, needPoint)
		end
	end

	table.sort(rewardListData, function(a, b)
		if a.numMax == b.numMax then
			return a.id < b.id
		end

		return a.numMax < b.numMax
	end)

	local previousNeedPoint = 0

	for _, rewardData in ipairs(rewardListData) do
		rewardData.numMin = previousNeedPoint
		previousNeedPoint = rewardData.numMax
	end

	return rewardListData, maxRewardStar
end

function HomelandCollectionCropCtrl:refreshCollectionCropPageInfo()
	if not self.seasonId or self.seasonId == 0 then
		return
	end

	ClientTextUtils.setText(self.view.tMPUSDFText, pg.getGameString("HOMELAND_SEASON_CROP_TITLE"))
	ClientTextUtils.setText(self.view.txtDecomposeUSDFText, pg.getGameString("CONSOLE_BAR_DECOMPOSE"))
	ClientTextUtils.setText(self.view.txtExchangeUSDFText, pg.getGameString("HOMELAND_SEASON_CROP_EXCHANGE"))

	local countBySeasonType = pg.me.homeSeasonMutationCountBySeasonType or {}
	local starBySeason = pg.me.homeSeasonMutationStarBySeason or {}
	local categoryCountMap = countBySeasonType[self.seasonId] or {}
	local currentTotalStar = starBySeason[self.seasonId] or 0
	local rewardListData, maxRewardStar = self:getRewardListData(currentTotalStar)

	for index = 1, CATEGORY_CARD_COUNT do
		local categoryData = self.categoryList[index]
		local iconImage = self.view["iconUImage" .. index]
		local nameText = self.view["txtNameUSDFText" .. index]
		local progressText = self.view["txtNumUSDFText" .. index]
		local cardButton = self.view["card" .. index .. "UButton"]

		if categoryData then
			local collectedCount = categoryCountMap[categoryData.typeId] or 0

			cardButton:TryChangePage("Finish", collectedCount >= categoryData.maxCount and 1 or 0)

			if iconImage and nameText and progressText then
				iconImage.url = categoryData.icon or ""

				ClientTextUtils.setText(nameText, ClientTextUtils.getLocalizationText(categoryData.name))
				ClientTextUtils.setText(progressText, string.format("%d/%d", collectedCount, categoryData.maxCount))
			end
		else
			cardButton:TryChangePage("Finish", 0)

			if iconImage and nameText and progressText then
				iconImage.url = ""

				ClientTextUtils.setText(nameText, "")
				ClientTextUtils.setText(progressText, "")
			end
		end

		self:refreshCategoryCardRedDot(index, categoryData)
	end

	ClientTextUtils.setText(self.view.txtNumUSDFText, string.format("%d/%d", currentTotalStar, maxRewardStar))
	self.view.listCurrencyUList:SetActive(false)
	self.view.listUList:SetList(rewardListData)
	self:refreshRemainTime()
end

function HomelandCollectionCropCtrl:renderRewardItem(button, index, data)
	if not data then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local rewardItemUButton = objectReference:GetRefValue("rewardItemUButton")
	local numUSDFText = objectReference:GetRefValue("numUSDFText")
	local progress2UProgress = objectReference:GetRefValue("progress2UProgress")
	local starBySeason = pg.me.homeSeasonMutationStarBySeason or {}
	local currentTotalStar = starBySeason[self.seasonId] or 0

	progress2UProgress.maxValue = 1
	progress2UProgress.minValue = 0

	if currentTotalStar >= data.numMax then
		progress2UProgress.value = 1
	elseif currentTotalStar < data.numMin or data.numMax <= data.numMin then
		progress2UProgress.value = 0
	else
		progress2UProgress.value = (currentTotalStar - data.numMin) / (data.numMax - data.numMin)
	end

	ClientTextUtils.setText(numUSDFText, data.numMax)

	local rewardList = LuaUIUtils.getRewardItemByDropId(data.rewardId[1])
	local renderData = rewardList[1]

	if not renderData then
		rewardItemUButton:SetActive(false)

		return
	end

	rewardItemUButton:SetActive(true)

	if data.isReceived then
		renderData.state = 1
	elseif data.canReceive then
		renderData.state = 2
	else
		renderData.state = 0
	end

	renderData.extraFunc = nil

	if data.canReceive and not data.isReceived then
		function renderData.extraFunc()
			self:receiveAllRewards()
		end
	end

	LuaUIUtils.renderRewardItem(rewardItemUButton, renderData)

	local redDotPath = string.format(RedDotConst.RedDotPath.HOME_SEASON_MUTATION_REWARD_ITEM, self.seasonId, data.id)
	local showRedDot = data.canReceive and not data.isReceived

	pg.global.setRedDot(redDotPath, rewardItemUButton, showRedDot, RedDotConst.RedDotStyle.REWARD)
end

function HomelandCollectionCropCtrl:receiveAllRewards()
	if self.isReceivingReward then
		return
	end

	local starBySeason = pg.me.homeSeasonMutationStarBySeason or {}
	local currentTotalStar = starBySeason[self.seasonId] or 0
	local rewardListData = self:getRewardListData(currentTotalStar)
	local rewardIds = {}

	for _, rewardData in ipairs(rewardListData) do
		if rewardData.canReceive and not rewardData.isReceived then
			table.insert(rewardIds, rewardData.id)
		end
	end

	if #rewardIds == 0 then
		return
	end

	self.isReceivingReward = true

	pg.me:reqReceiveHomeSeasonMutationReward(rewardIds, function(result)
		self.isReceivingReward = false

		if result ~= NoticeDef.SUCCESS then
			return
		end

		local redDotPath = string.format(RedDotConst.RedDotPath.HOME_SEASON_ITEM_COLLECT_ENTRY, self.seasonId)

		pg.global.refreshRedDotState(redDotPath)

		if self.view then
			self:refreshCollectionCropPageInfo()
		end
	end)
end

function HomelandCollectionCropCtrl:onMutationCollectionChanged()
	if not self.view then
		return
	end

	self:refreshCollectionCropPageInfo()
end

function HomelandCollectionCropCtrl:onMutationCropItemCountChanged(data)
	if not self.view or not data then
		return
	end

	local changedItemId = data.itemId or data.genId
	local collectionInfo = changedItemId and HomeSeasonMutationCollectionData[changedItemId]

	if not collectionInfo or collectionInfo.seasonId ~= self.seasonId then
		return
	end

	for index, categoryData in ipairs(self.categoryList) do
		if categoryData.typeId == collectionInfo.typeid then
			self:refreshCategoryCardRedDot(index, categoryData)

			return
		end
	end
end

function HomelandCollectionCropCtrl:refreshRemainTime()
	if not self.seasonId or self.seasonId == 0 then
		ClientTextUtils.setText(self.view.txtTipsUSDFText, "")
		self:stopRemainTimeTimer()

		return
	end

	local remainTime = 0

	if self.seasonEndTime then
		remainTime = math.max(0, self.seasonEndTime - (Time.secondCache or Time.getSecond()))
	end

	local remainTimeText = TimeUtils.getRemainTimeShort(remainTime)

	ClientTextUtils.setText(self.view.txtTipsUSDFText, pg.getFormatText(pg.getGameString("HOMELAND_SEASON_CROP_REMAIN_TIME"), remainTimeText))

	if remainTime <= 0 then
		self:stopRemainTimeTimer()
	end
end

function HomelandCollectionCropCtrl:startRemainTimeTimer()
	self:stopRemainTimeTimer()
	self:refreshRemainTime()

	if self.seasonEndTime and self.seasonEndTime > (Time.secondCache or Time.getSecond()) then
		self.remainTimeTimer = self:startTimer(function()
			if self.view then
				self:refreshRemainTime()
			end
		end, REMAIN_TIME_REFRESH_INTERVAL, true)
	end
end

function HomelandCollectionCropCtrl:stopRemainTimeTimer()
	if self.remainTimeTimer then
		self:killTimer(self.remainTimeTimer)

		self.remainTimeTimer = nil
	end
end

function HomelandCollectionCropCtrl:onDestroy()
	self:stopRemainTimeTimer()
	UICtrl.onDestroy(self)
end

return HomelandCollectionCropCtrl
