-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandCollectionCropDetail\\HomelandCollectionCropDetailCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandCollectionCropDetailCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local UIConst = require("Const.UIConst")
local NoticeDef = require("Common.NoticeDef")
local HomeSeasonMutationCategoryData = require("Data.home_season_mutation_category_data")
local HomeSeasonMutationCollectionData = require("Data.home_season_mutation_collection_data")
local HomeSeasonMutationCollectionByTypeData = require("Data.home_season_mutation_collection_by_type_data")
local HomelandConfigData = require("Data.homeland_config_data")
local HomelandCollectionCropDetailCtrl = Class.LightClass("HomelandCollectionCropDetailCtrl", UICtrl)

HomelandCollectionCropDetailCtrl.messages = {
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"onItemCountChanged",
		true
	},
	[MessageName.HOMELAND_ITEM_MAP_CHANGED] = {
		"onItemCountChanged",
		true
	}
}
HomelandCollectionCropDetailCtrl.ITEM_STATE = {
	CAN_COLLECT = 2,
	NOT_COLLECTED = 1,
	COLLECTED = 0,
	CAN_GIFT = 3
}

function HomelandCollectionCropDetailCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	info = info or {}
	self.seasonId = pg.me and pg.me.homeSeasonId or 1
	self.collectingItemId = nil
	self.typeId = info.typeId or 0
	self.categoryInfo = HomeSeasonMutationCategoryData[self.typeId]

	if not self.seasonId or self.seasonId == 0 or not self.categoryInfo then
		self:close()

		return
	end

	self.cropListData = self:getCropListData()

	self:refreshCollectionCropDetailInfo()
end

function HomelandCollectionCropDetailCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	function self.view.btnInfoUButton.luaClick()
		pg.global.ui.tips:openEventRuleDesc(pg.getGameString("HOMELAND_SEASON_CROP_RULE_DESC"), nil, nil, true)
	end

	function self.view.listUList.luaRenderItem(button, index, data)
		self:renderCropItem(button, data)
	end
end

function HomelandCollectionCropDetailCtrl:getCropListData()
	local cropListData = {}

	self.cropItemIdMap = {}

	local seasonTypeData = HomeSeasonMutationCollectionByTypeData[self.seasonId] or {}
	local itemIdList = seasonTypeData[self.typeId] or {}

	for _, itemId in ipairs(itemIdList) do
		local collectionInfo = HomeSeasonMutationCollectionData[itemId]

		if collectionInfo then
			self.cropItemIdMap[itemId] = true

			table.insert(cropListData, {
				itemId = itemId,
				name = collectionInfo.name,
				starNum = collectionInfo.starNum or 0
			})
		end
	end

	return cropListData
end

function HomelandCollectionCropDetailCtrl:getCropState(itemId)
	local collectedMap = pg.me.homeSeasonMutationCollectedMap or {}
	local isCollected = collectedMap[itemId] ~= nil
	local itemCount = ClientUtils.getItemCountById(itemId)

	if pg.me:isInSelfHomeland() then
		itemCount = itemCount + ClientUtils.getHomelandItemCountById(itemId)
	end

	if isCollected then
		return itemCount > 0 and self.ITEM_STATE.CAN_GIFT or self.ITEM_STATE.COLLECTED, itemCount
	end

	return itemCount > 0 and self.ITEM_STATE.CAN_COLLECT or self.ITEM_STATE.NOT_COLLECTED, itemCount
end

function HomelandCollectionCropDetailCtrl:renderCropItem(button, data)
	if not data then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local iconCropUImage = objectReference:GetRefValue("iconCropUImage")
	local listStarUList = objectReference:GetRefValue("listStarUList")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local txtTagUSDFText = objectReference:GetRefValue("txtTagUSDFText")
	local state, itemCount = self:getCropState(data.itemId)

	iconCropUImage.url = LuaUIUtils.getIconByItemId(data.itemId)

	local starData = {}

	for i = 1, data.starNum do
		table.insert(starData, {})
	end

	listStarUList:SetList(starData)
	ClientTextUtils.setText(txtNameUSDFText, ClientTextUtils.getLocalizationText(data.name))

	local stateText = ""

	if state == self.ITEM_STATE.CAN_COLLECT then
		stateText = pg.getGameString("HOMELAND_SEASON_CROP_STATE_CAN_COLLECT")
	elseif state == self.ITEM_STATE.CAN_GIFT then
		stateText = pg.getGameString("HOMELAND_SEASON_CROP_STATE_CAN_GIFT")
	end

	ClientTextUtils.setText(txtTagUSDFText, stateText)
	button:TryChangePage("State", state)

	function button.luaClick()
		local actionName
		local actionEnabled = true

		if state == self.ITEM_STATE.NOT_COLLECTED then
			actionName = pg.getGameString("HOMELAND_SEASON_CROP_ASK_FRIEND")
		elseif state == self.ITEM_STATE.CAN_COLLECT then
			actionName = pg.getGameString("HOMELAND_SEASON_CROP_COLLECT")
		else
			actionName = pg.getGameString("HOME_PLANT_SEND_BTN_NAME")
			actionEnabled = state == self.ITEM_STATE.CAN_GIFT
		end

		local tipData = {
			needShowBtnSelfTip = false,
			needShowReward = false,
			id = data.itemId,
			num = itemCount,
			targetRect = button,
			btnDataList = {
				{
					name = actionName,
					interactable = actionEnabled,
					confirmFunc = function()
						if state == self.ITEM_STATE.CAN_COLLECT then
							self:collectCrop(data.itemId)
						elseif state == self.ITEM_STATE.NOT_COLLECTED then
							self:openCropSend(data.itemId, UIConst.HOME_PLANTS_SEND_MODE.HELP)
						elseif state == self.ITEM_STATE.CAN_GIFT then
							self:openCropSend(data.itemId, UIConst.HOME_PLANTS_SEND_MODE.GIFT)
						end
					end
				}
			}
		}

		if state == self.ITEM_STATE.CAN_COLLECT then
			tipData.rewardViewText = pg.getGameString("CONSUME_LABEL")
			tipData.rewardViewItemList = {
				{
					tIndex = 0,
					type = 0,
					num = 1,
					id = data.itemId,
					ownNum = itemCount
				}
			}
		end

		pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, tipData)
	end
end

function HomelandCollectionCropDetailCtrl:openCropSend(itemId, mode)
	pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
	pg.global.ui:open(UIConst.UI_ID_HOME_PLANTS_SEND, {
		itemId = itemId,
		mode = mode
	})
end

function HomelandCollectionCropDetailCtrl:collectCrop(itemId)
	if self.collectingItemId then
		return
	end

	self.collectingItemId = itemId

	pg.me:reqRecordHomeSeasonMutation(itemId, function(result)
		self.collectingItemId = nil

		if result ~= NoticeDef.SUCCESS then
			return
		end

		if self.view and self.view.listUList then
			self.view.listUList:RefreshList()
		end

		pg.global.showBubbleMessageRaw(pg.getGameString("HOMELAND_SEASON_CROP_COLLECT_SUCCESS"))
		facade:sendMsgToUI(MessageName.HOME_SEASON_MUTATION_COLLECTION_CHANGE)
		pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
	end)
end

function HomelandCollectionCropDetailCtrl:refreshCollectionCropDetailInfo()
	ClientTextUtils.setText(self.view.tMPUSDFText, pg.getGameString("HOMELAND_SEASON_CROP_TITLE"))

	self.view.btnInfoUButton.enabledTooltip = false

	self.view.listCurrencyUList:SetActive(false)
	self.view.listUList:SetList(self.cropListData or {})
end

function HomelandCollectionCropDetailCtrl:onItemCountChanged(data)
	if not self.view or not data then
		return
	end

	local changedItemId = data.itemId or data.genId

	if not changedItemId then
		return
	end

	if self.cropItemIdMap[changedItemId] and self.view.listUList then
		self.view.listUList:RefreshList()
	end
end

function HomelandCollectionCropDetailCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function HomelandCollectionCropDetailCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function HomelandCollectionCropDetailCtrl:onHide()
	return
end

function HomelandCollectionCropDetailCtrl:onShow()
	return
end

return HomelandCollectionCropDetailCtrl
