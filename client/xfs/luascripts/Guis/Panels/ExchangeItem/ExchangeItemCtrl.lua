-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ExchangeItem\\ExchangeItemCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ExchangeItemCtrl = Class.LightClass("ExchangeItemCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local ItemEffectData = require("Data.item_effect_data")
local ItemCompoundData = require("Data.item_compound_data")
local GameStringConfig = require("Data.gamestring_config_data")
local Const = require("Common.Const.Const")
local ItemData = require("Data.item_data")
local MessageName = require("Const.MessageName")

ExchangeItemCtrl.messages = {
	[MessageName.MONEY_COUNT_CHANGE] = {
		"onMoneyNumChange",
		true
	}
}

function ExchangeItemCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.selectedPropData = info.propData
	self.effectData = ItemEffectData[self.selectedPropData.itemId]
	self.costID, self.costNum = ItemCompoundData[self.effectData.compoundID].material[2][1], ItemCompoundData[self.effectData.compoundID].material[2][2]
	self.costItem = LuaUIUtils.getItemClientInfoById(self.costID)
	self.costItemPossessNum = self.costItem.count
	self.currencyListData = {
		{
			itemId = self.costID
		}
	}

	self.view.costUWidget:SetActive(false)
	self:renderExchangeItems()
	self:renderCurrencyList()
end

function ExchangeItemCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:closePanel()
	end

	function self.view.btnConfirmUButton.luaClick()
		if self.costItemPossessNum >= self.view.numSelectorSliderUNumSelector.value * self.costNum then
			pg.me:serverMsg("RPC_CS_ItemCompoundProduce", self.effectData.compoundID, self.view.numSelectorSliderUNumSelector.value)
			self:closePanel()
		else
			pg.global.ui.tips:showTextTip(pg.getFormatText(pg.getGameString("COST_ITEM_NOT_ENOUGH"), pg.getLocalizationText(self.costItem.name)))
		end
	end

	function self.view.btnCancelUButton.luaClick()
		self:closePanel()
	end

	local confirmBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnConfirmUButton.gameObject, "confirmBind")

	confirmBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Confirm

	function self.view.currencyUList.luaRenderItem(button, index, data)
		if data.itemId == Const.CommonEnergyType_Stamina then
			LuaUIUtils.setTopCurrencyItem(button, data.itemId, true, LuaUIUtils.getVitalityMaxStoreNum())
		else
			LuaUIUtils.setTopCurrencyItem(button, data.itemId)
		end
	end

	function self.view.listItemFrontUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderRewardItem(button, {
			num = data.num,
			id = data.id
		})
	end

	function self.view.listItemBackUList.luaRenderItem(button, index, data)
		LuaUIUtils.renderRewardItem(button, {
			num = data.num,
			id = data.id
		})
	end
end

function ExchangeItemCtrl:renderExchangeItems()
	local obtainItemID, obtainItemRate = ItemCompoundData[self.effectData.compoundID].product[1], ItemCompoundData[self.effectData.compoundID].product[2]

	self.view.numSelectorSliderUNumSelector:SetAllValue(1, 1, self.selectedPropData.packSlot.count, 1)

	local numSelectorSliderObjRef = self.view.numSelectorSliderUNumSelector.transform:GetComponent("ObjectReference")
	local textMin = numSelectorSliderObjRef:GetRefValue("txtMin")
	local textMax = numSelectorSliderObjRef:GetRefValue("txtMax")

	self.view.listItemFrontUList:SetList({
		{
			num = self.view.numSelectorSliderUNumSelector.value,
			id = self.selectedPropData.itemId
		}
	})
	self.view.listItemBackUList:SetList({
		{
			num = self.view.numSelectorSliderUNumSelector.value * obtainItemRate,
			id = obtainItemID
		}
	})
	ClientTextUtils.setText(textMin, self.view.numSelectorSliderUNumSelector.minValue)
	ClientTextUtils.setText(textMax, self.view.numSelectorSliderUNumSelector.maxValue)

	function self.view.numSelectorSliderUNumSelector.luaValueChanged(inputInfo)
		self.view.listItemFrontUList:SetList({
			{
				num = self.view.numSelectorSliderUNumSelector.value,
				id = self.selectedPropData.itemId
			}
		})
		self.view.listItemBackUList:SetList({
			{
				num = self.view.numSelectorSliderUNumSelector.value * obtainItemRate,
				id = obtainItemID
			}
		})
	end

	local obtainItemCfg = ItemData[obtainItemID] or {}
	local costItemName, obtainItemName = pg.getLocalizationText(self.costItem.name), pg.getLocalizationText(obtainItemCfg.itemName)

	ClientTextUtils.setText(self.view.titleUSDFText, pg.getFormatText(pg.getGameString("ITEM_COMPOUND_TITLE"), obtainItemName))

	local costNumText = LuaUIUtils.getItemCountConsumeShowText(self.costID, self.costNum)

	ClientTextUtils.setText(self.view.describeUSDFText, pg.getFormatText(pg.getGameString("ITEM_COMPOUND_DES"), costItemName, costNumText, obtainItemRate, obtainItemName))
end

function ExchangeItemCtrl:renderCurrencyList()
	self.view.currencyUList:SetList(self.currencyListData)
end

function ExchangeItemCtrl:onMoneyNumChange()
	self.costItem = LuaUIUtils.getItemClientInfoById(self.costID)
	self.costItemPossessNum = self.costItem.count

	self.view.currencyUList:SetList(self.currencyListData)
end

return ExchangeItemCtrl
