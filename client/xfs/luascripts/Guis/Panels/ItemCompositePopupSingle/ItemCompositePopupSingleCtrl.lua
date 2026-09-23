-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ItemCompositePopupSingle\\ItemCompositePopupSingleCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("ItemCompositePopupSingleCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ItemCompoundData = require("Data.item_compound_data")
local DropData = require("Data.drop_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local ClientUtils = require("Utils.ClientUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ItemData = require("Data.item_data")
local NoticeDef = require("Common.NoticeDef")
local Const = require("Common.Const.Const")
local ItemCompositePopupSingleCtrl = Class.LightClass("ItemCompositePopupSingleCtrl", UICtrl)

ItemCompositePopupSingleCtrl.messages = {
	[MessageName.ITEM_COMPOUND_REFRESH] = {
		"onItemCompoundRefresh",
		true
	},
	[MessageName.ON_NOTIFY_ITEM] = {
		"refreshAll",
		true
	}
}

function ItemCompositePopupSingleCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.compoundId = info.compoundId
	self.isTTLExchange = info.isTTLExchange == true
	self.compoundCfg = ItemCompoundData[self.compoundId]

	if not self.compoundCfg then
		return
	end

	local rData = DropData[self.compoundCfg.reward]

	self.compoundData = {
		material = self.compoundCfg.material,
		currency = self.compoundCfg.currency,
		product = rData.displayReward or {},
		compoundId = self.compoundId
	}

	for _, materialInfo in ipairs(self.compoundCfg.material) do
		local itemConfig = ItemData[materialInfo[1]]

		if itemConfig and tonumber(itemConfig.ttlChangeItem) == self.compoundId then
			self.ttlExchangeMaterial = materialInfo

			break
		end
	end

	self.multi = 1
	self.craftFunc = info.craftFunc

	self:initUI()
end

function ItemCompositePopupSingleCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.btnCancelUButton.luaClick()
		self:close()
	end

	function self.view.btnConfirmUButton.luaClick()
		self:tryCompoundItem()
	end

	function self.view.numSelector.luaValueChanged(value)
		self.multi = value

		self:refreshCompositeItems()
		self:refreshCurrencyInfo()
		self:refreshTTLExchangeDescription()
	end
end

function ItemCompositePopupSingleCtrl:onItemCompoundRefresh(result)
	if NoticeDef.SUCCESS ~= result[1] then
		ClientUtils.showBubbleMessageById(result[1])
	else
		ClientUtils.showBubbleMessageRaw(pg.getGameString("COMPOUND_SUCCESS"))
	end

	self:setNumSelectedConfig()
	self:refreshCompositeItems()
	self:refreshCurrencyInfo()
	self:refreshTopCurrency()
end

function ItemCompositePopupSingleCtrl:refreshAll()
	self:setNumSelectedConfig()
	self:refreshCompositeItems()
	self:refreshCurrencyInfo()
	self:refreshTopCurrency()
end

function ItemCompositePopupSingleCtrl:initUI()
	self.view.titleUSDFText.text = pg.getLocalizationText(self.compoundData.name)
	self.view.describeUSDFText.text = pg.getLocalizationText(self.compoundData.describe)

	function self.view.listItemFrontUList.luaRenderItem(button, idx, data)
		if data.tIndex == 0 then
			LuaUIUtils.setCompoundCard(button, data, false, true, self.multi)
		end
	end

	function self.view.listItemBackUList.luaRenderItem(button, idx, data)
		if data.tIndex == 0 then
			LuaUIUtils.setCompoundCard(button, data, true, true, self.multi)
		end
	end

	self:setNumSelectedConfig()
	self:refreshCompositeItems()
	self:refreshCurrencyInfo()
	self:refreshTopCurrency()

	if not self.compoundData.product or #self.compoundData.product == 0 then
		return
	end

	local obtainItemID, obtainItemRate = self.compoundData.product[1][1], self.compoundData.product[1][2]
	local itemCfg = ItemData[obtainItemID]
	local obtainItemName = pg.getLocalizationText(itemCfg.itemName)

	ClientTextUtils.setText(self.view.titleUSDFText, pg.getFormatText(pg.getGameString("ITEM_COMPOUND_TITLE"), obtainItemName))

	local costEnergyCountText = ""
	local costEnergyName = ""

	for _, value in ipairs(self.compoundData.material) do
		if value[1] == Const.CommonEnergyType_Stamina then
			local costEnergyCount = value[2]

			costEnergyCountText = LuaUIUtils.getItemCountConsumeShowText(Const.CommonEnergyType_Stamina, costEnergyCount)
			costEnergyName = pg.getLocalizationText(ItemData[value[1]].itemName)

			break
		end
	end

	ClientTextUtils.setText(self.view.describeUSDFText, pg.getFormatText(pg.getGameString("ITEM_COMPOUND_DES"), costEnergyName, costEnergyCountText, obtainItemRate, obtainItemName))
	self:refreshTTLExchangeDescription()
end

function ItemCompositePopupSingleCtrl:refreshTTLExchangeDescription()
	if not self.isTTLExchange then
		return
	end

	ClientTextUtils.setText(self.view.titleUSDFText, pg.getGameString("CONVERT"))

	if not self.ttlExchangeMaterial or not self.compoundData.product or #self.compoundData.product == 0 then
		return
	end

	local sourceId, sourceCount = self.ttlExchangeMaterial[1], self.ttlExchangeMaterial[2] * self.multi
	local targetId, targetCount = self.compoundData.product[1][1], self.compoundData.product[1][2] * self.multi
	local sourceName = pg.getLocalizationText(ItemData[sourceId].itemName)
	local targetName = pg.getLocalizationText(ItemData[targetId].itemName)

	ClientTextUtils.setText(self.view.describeUSDFText, string.format("消耗%d个%s，可兑换%d个%s", sourceCount, sourceName, targetCount, targetName))
end

function ItemCompositePopupSingleCtrl:setNumSelectedConfig()
	local maxCount = math.max(1, LuaUIUtils.getCompoundMaxCount(self.compoundData))

	self.view.numSelector.minValue = 1
	self.view.numSelector.maxValue = maxCount
	self.view.numSelector.value = 1

	ClientTextUtils.setText(self.view.txtMin, 1)
	ClientTextUtils.setText(self.view.txtMax, maxCount)
end

function ItemCompositePopupSingleCtrl:tryCompoundItem()
	if LuaUIUtils.checkCompositeCountLimit(self.compoundData, self.multi) then
		if self.craftFunc then
			self.craftFunc()
		end

		pg.me:serverMsg("RPC_CS_ItemCompoundProduce", self.compoundId, self.multi)
	end
end

function ItemCompositePopupSingleCtrl:refreshCompositeItems()
	local materialList = {}

	for _, materialInfo in ipairs(self.compoundData.material) do
		materialList[#materialList + 1] = {
			propId = materialInfo[1],
			countNeed = materialInfo[2],
			compoundId = self.compoundId
		}
	end

	self.view.listItemFrontUList:SetList(materialList)

	local productList = {}

	for _, value in ipairs(self.compoundData.product) do
		productList[#productList + 1] = {
			propId = value[1],
			countNeed = value[2]
		}
	end

	self.view.listItemBackUList:SetList(productList)
end

function ItemCompositePopupSingleCtrl:refreshCurrencyInfo()
	local compoundData = self.compoundData
	local showCurrency = compoundData.currency and #compoundData.currency > 0

	self.view.costUWidget:SetActive(showCurrency)

	if not showCurrency then
		return
	end

	local currencyInfo = compoundData.currency
	local currencyId = currencyInfo[1]
	local currencyNeedNum = currencyInfo[2] * self.multi
	local currencyCount = ClientUtils.getItemCountById(currencyId)
	local cfgData = ItemData[currencyId]

	self.view.consumeIcon.url = LuaUIUtils.getIconByIconId(cfgData.icon)

	if currencyCount < currencyNeedNum then
		ClientTextUtils.setText(self.view.consumeNum, string.format("<color=#FF0000>%s</color>", currencyNeedNum))
	else
		ClientTextUtils.setText(self.view.consumeNum, currencyNeedNum)
	end
end

function ItemCompositePopupSingleCtrl:refreshTopCurrency()
	local currencyList = {}

	for _, materialInfo in ipairs(self.compoundData.material) do
		local itemCfg = ItemData[materialInfo[1]]

		if itemCfg and itemCfg.type == Const.ITEM_TYPE.Currency then
			table.insert(currencyList, materialInfo[1])
		end
	end

	LuaUIUtils.setTopCurrencyItemList(self.view.currencyUList, nil, currencyList)
end

function ItemCompositePopupSingleCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function ItemCompositePopupSingleCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function ItemCompositePopupSingleCtrl:onShow()
	return
end

function ItemCompositePopupSingleCtrl:onHide()
	return
end

return ItemCompositePopupSingleCtrl
