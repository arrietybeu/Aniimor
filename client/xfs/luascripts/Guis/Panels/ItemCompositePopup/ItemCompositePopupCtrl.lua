-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ItemCompositePopup\\ItemCompositePopupCtrl.lua

local MessageName = require("Const.MessageName")
local NoticeDef = require("Common.NoticeDef")
local ClientUtils = require("Utils.ClientUtils")
local ItemConst = require("Common.Const.ItemConst")
local ItemCompoundData = require("Data.item_compound_data")
local DropData = require("Data.drop_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ItemData = require("Data.item_data")
local Const = require("Common.Const.Const")
local ItemCompositePopupCtrl = Class.LightClass("ItemCompositePopupCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")

ItemCompositePopupCtrl.messages = {
	[MessageName.ITEM_COMPOUND_REFRESH] = {
		"onItemCompoundRefresh",
		true
	},
	[MessageName.CURRENCY_CHANGE] = {
		"refreshAll",
		true
	},
	[MessageName.MONEY_COUNT_CHANGE] = {
		"refreshAll",
		true
	}
}

function ItemCompositePopupCtrl:onCreate(info)
	self.compoundIdList = info.compoundList
	self.multi = 1

	UICtrl.onCreate(self, info)
end

function ItemCompositePopupCtrl:addListener()
	function self.view.btnClose.luaClick()
		self:close()
	end

	function self.view.compoundList.luaRenderItem(button, idx, data)
		self:setCompoundList(button, idx, data)
	end

	function self.view.compoundList.luaSelectedChanged(uList)
		self:setNumSelectedConfig()
		self:refreshCurrencyInfo()
		self:refreshTopCurrency()
	end

	function self.view.btnCancel.luaClick()
		self:close()
	end

	function self.view.btnConfirm.luaClick()
		self:tryCompoundItem()
	end

	self:setUpCompoundList()

	self.view.numSelector.value = self.multi

	function self.view.numSelector.luaValueChanged(value)
		self.multi = value

		self:refreshCurrencyInfo()
		self.view.compoundList:RefreshList()
	end

	self.view.compoundList:SelectItem(0)
end

function ItemCompositePopupCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function ItemCompositePopupCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function ItemCompositePopupCtrl:tryCompoundItem()
	if LuaUIUtils.checkCompositeCountLimit(self.view.compoundList.selectedItem, self.multi) then
		local compoundId = self.view.compoundList.selectedItem.compoundId

		pg.me:serverMsg("RPC_CS_ItemCompoundProduce", compoundId, self.multi)
	end
end

function ItemCompositePopupCtrl:onItemCompoundRefresh(result)
	if NoticeDef.SUCCESS ~= result[1] then
		local flag, res = self:checkFailureReason()

		if flag == 2 then
			ClientUtils.showBubbleMessageRaw(pg.getGameString("LOCK_TIPS", res))
		else
			ClientUtils.showBubbleMessageById(result[1])
		end
	else
		ClientUtils.showBubbleMessageRaw(pg.getGameString("COMPOUND_SUCCESS"))
	end

	self.view.compoundList:RefreshList()
	self:refreshCurrencyInfo()
	self:setNumSelectedConfig()
end

function ItemCompositePopupCtrl:refreshAll()
	self.view.compoundList:RefreshList()
	self:refreshCurrencyInfo()
	self:setNumSelectedConfig()
	self:refreshTopCurrency()
end

function ItemCompositePopupCtrl:checkFailureReason()
	local compoundId = self.view.compoundList.selectedItem.compoundId
	local rate = self.multi
	local flag = 0
	local itemId = 0
	local compoundData = ItemCompoundData[compoundId]

	for _, v in pairs(compoundData.material) do
		local lockCount, unlockCount = self:getMaterialCountInfo(v[1])
		local needCount = v[2] * rate

		if unlockCount > 0 and unlockCount < needCount then
			flag = 1
		elseif lockCount > 0 and lockCount < needCount then
			flag = 2
		end

		if flag ~= 0 then
			itemId = v[1]

			break
		end
	end

	if flag == 0 then
		local currencyId = compoundData.currency[1]
		local currencyNeedNum = compoundData.currency[2] * self.multi
		local currencyCount = ClientUtils.getItemCountById(currencyId)

		if currencyCount < currencyNeedNum then
			flag = 1
			itemId = currencyId
		end
	end

	if flag ~= 0 then
		local cData = LuaUIUtils.getItemClientInfoById(itemId)

		return flag, pg.getLocalizationText(cData.name)
	end

	return flag, ""
end

function ItemCompositePopupCtrl:checkCountLimit(compoundData)
	for _, materialInfo in ipairs(compoundData.material) do
		local materialId = materialInfo[1]
		local materialNeed = materialInfo[2]
		local _, unlockCount = self:getMaterialCountInfo(materialId)

		if unlockCount < materialNeed * self.multi then
			local itemInfo = LuaUIUtils.getItemClientInfoById(materialId)
			local itemName = pg.getLocalizationText(itemInfo.name)

			pg.global.showBubbleMessage(NoticeDef.SHOP_ITEM_NOT_ENOUGH, itemName)

			return false
		end
	end

	if compoundData.currency then
		local currencyId = compoundData.currency[1]
		local currencyNeedNum = compoundData.currency[2] * self.multi
		local currencyCount = ClientUtils.getItemCountById(currencyId)

		if currencyCount < currencyNeedNum then
			local itemInfo = LuaUIUtils.getItemClientInfoById(currencyId)
			local itemName = pg.getLocalizationText(itemInfo.name)

			pg.global.showBubbleMessage(NoticeDef.SHOP_ITEM_NOT_ENOUGH, itemName)

			return false
		end
	end

	return true
end

function ItemCompositePopupCtrl:setNumSelectedConfig()
	local compoundData = self.view.compoundList.selectedItem
	local maxCount = math.max(1, LuaUIUtils.getCompoundMaxCount(compoundData))

	self.view.numSelector.minValue = 1
	self.view.numSelector.maxValue = maxCount
	self.view.numSelector.value = 1
end

function ItemCompositePopupCtrl:refreshCurrencyInfo()
	local compoundData = self.view.compoundList.selectedItem
	local showCurrency = compoundData.currency and #compoundData.currency > 0

	self.view.costUWidget:SetActive(showCurrency)

	if not showCurrency then
		return
	end

	local currencyInfo = compoundData.currency
	local currencyId = currencyInfo[1]
	local currencyNeedNum = currencyInfo[2] * self.multi
	local currencyClient = LuaUIUtils.getItemClientInfoById(currencyId)
	local currencyCount = ClientUtils.getItemCountById(currencyId)

	self.view.consumeIcon.url = currencyClient.icon

	if currencyCount < currencyNeedNum then
		ClientTextUtils.setText(self.view.consumeNum, string.format("<color=#FF0000>%s</color>", currencyNeedNum))
	else
		ClientTextUtils.setText(self.view.consumeNum, currencyNeedNum)
	end
end

function ItemCompositePopupCtrl:setUpCompoundList()
	local compoundList = {}

	for _, compoundId in ipairs(self.compoundIdList) do
		local compoundData = ItemCompoundData[compoundId]
		local rewardId = compoundData.reward
		local rData = DropData[rewardId]

		if rData then
			compoundList[#compoundList + 1] = {
				material = compoundData.material,
				currency = compoundData.currency,
				product = rData.displayReward or {},
				compoundId = compoundId
			}
		end
	end

	table.sort(compoundList, function(a, b)
		return self:compareCompoundData(a, b)
	end)
	self.view.compoundList:SetList(compoundList)
end

function ItemCompositePopupCtrl:compareCompoundData(aData, bData)
	local aMax = LuaUIUtils.getCompoundMaxCount(aData)
	local bMax = LuaUIUtils.getCompoundMaxCount(bData)

	if aMax == bMax then
		local aProductId = aData.product[1] and aData.product[1][1]
		local bProductId = bData.product[1] and bData.product[1][1]
		local aInfo = ItemData[aProductId]
		local bInfo = ItemData[bProductId]

		if aInfo and bInfo then
			return aInfo.quality > bInfo.quality
		end
	end

	return bMax < aMax
end

function ItemCompositePopupCtrl:setCompoundList(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local listUList = objectReference:GetRefValue("listUList")
	local anim = objectReference:GetRefValue("arrowsAnimation")
	local listProductUList = objectReference:GetRefValue("listProductUList")

	UIUtils.PlayAnimation(anim, "VX_Node_Inventory_Compound_Arrow_In", function()
		anim:Play("VX_Node_Inventory_Compound_Arrow_Loop")
	end)

	local isSelected = data.selected

	function listUList.luaRenderItem(btn, i, d)
		if d.tIndex == 0 then
			LuaUIUtils.setCompoundCard(btn, d, false, isSelected, self.multi)
		end
	end

	local materialList = {}

	for _, materialInfo in ipairs(data.material) do
		materialList[#materialList + 1] = {
			propId = materialInfo[1],
			countNeed = materialInfo[2]
		}
	end

	for i = #materialList + 1, 4 do
		materialList[i] = {
			tIndex = 1
		}
	end

	listUList:SetList(materialList)

	function listProductUList.luaRenderItem(btn, i, d)
		if d.tIndex == 0 then
			LuaUIUtils.setCompoundCard(btn, d, true, isSelected, self.multi)
		end
	end

	local productList = {}

	for _, value in ipairs(data.product) do
		productList[#productList + 1] = {
			propId = value[1],
			countNeed = value[2]
		}
	end

	for i = #productList + 1, 2 do
		productList[i] = {
			tIndex = 1
		}
	end

	listProductUList:SetList(productList)
end

function ItemCompositePopupCtrl:getMaterialCountInfo(propId)
	local totalCount = ItemUtils.getItemCountById(pg.me, propId, true)
	local unlockCount = ItemUtils.getItemCountById(pg.me, propId, false)

	return totalCount - unlockCount, unlockCount
end

function ItemCompositePopupCtrl:refreshTopCurrency()
	local compoundData = self.view.compoundList.selectedItem
	local currencyList = {}

	for _, materialInfo in ipairs(compoundData.material) do
		local itemCfg = ItemData[materialInfo[1]]

		if itemCfg and itemCfg.type == Const.ITEM_TYPE.Currency then
			table.insert(currencyList, materialInfo[1])
		end
	end

	LuaUIUtils.setTopCurrencyItemList(self.view.currencyUList, nil, currencyList)
end

function ItemCompositePopupCtrl:onShow()
	return
end

function ItemCompositePopupCtrl:onHide()
	return
end

return ItemCompositePopupCtrl
