-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashShopAccessoryAdjust\\CashShopAccessoryAdjustCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local CashShopAccessoryAdjustModel = require("Guis.Panels.CashShopAccessoryAdjust.CashShopAccessoryAdjustModel")
local CashShopAccessoryAdjustView = require("Guis.Panels.CashShopAccessoryAdjust.CashShopAccessoryAdjustView")
local AvatarEditComponent = require("Guis.Panels.CashShopAccessoryAdjust.Component.AvatarEditComponent")
local PetAccessoryEditComponent = require("Guis.Panels.CashShopAccessoryAdjust.Component.PetAccessoryEditComponent")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local MessageName = require("Const.MessageName")
local TimeUtils = require("Common.Utils.TimeUtils")
local Utils = require("Common.Utils.Utils")
local ItemConst = require("Common.Const.ItemConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local CashShopAccessoryAdjustCtrl = Class.LightClass("CashShopAccessoryAdjustCtrl", UICtrl)

CashShopAccessoryAdjustCtrl.modelClz = CashShopAccessoryAdjustModel
CashShopAccessoryAdjustCtrl.viewClz = CashShopAccessoryAdjustView
CashShopAccessoryAdjustCtrl.messages = {
	[MessageName.CASH_SHOP_ON_BUY_ITEM] = {
		"onBuyItemResult",
		true
	}
}

function CashShopAccessoryAdjustCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.hostCtrl = info and info.cashShopCtrl or nil

	local adjustTransform = self.view.adjustUComponent and self.view.adjustUComponent.transform or nil

	self.avatarEditComponent = AvatarEditComponent.new(self.hostCtrl, adjustTransform)
	self.petAccessoryEditComponent = PetAccessoryEditComponent.new(self.hostCtrl, adjustTransform)

	self:addListener()
end

function CashShopAccessoryAdjustCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:updateAdjustContext(info and info.context or nil)
	self:openAvatarAdjust()
	self:refreshBottomBar()
end

function CashShopAccessoryAdjustCtrl:onDestroy()
	self.avatarEditComponent = nil
	self.petAccessoryEditComponent = nil
	self.hostCtrl = nil

	UICtrl.onDestroy(self)
end

function CashShopAccessoryAdjustCtrl:onHide()
	UICtrl.onHide(self)
	self:hideAvatarAdjust()
end

function CashShopAccessoryAdjustCtrl:addListener()
	if self.view.btnBackUButton then
		function self.view.btnBackUButton.luaClick()
			pg.global.ui:close(UIConst.UI_ID_CASH_ACCESSORY_ADJUST)
		end
	end

	if self.view.btnBuySaveUButton then
		function self.view.btnBuySaveUButton.luaClick()
			local data = self:_getCurCommodityData()
			local state = data and ClientCashShopUtils.getCommodityState(data) or 0
			local isOwned = state == ClientCashShopUtils.COMMODITY_STATE.POSSESS

			if isOwned or not data then
				self:saveAvatarAdjust()
			else
				local commodityId = self:_getCurrentCommodityId()
				local cost, errorCode = self:_getEffectiveCost(data)

				if errorCode then
					ClientCashShopUtils.showCommodityPriceCalcError(errorCode)

					return
				end

				ClientCashShopUtils.openBuyConfirm(commodityId, cost, 1)
			end
		end
	end
end

function CashShopAccessoryAdjustCtrl:setSelectedAccessory(accessoryId, slotId)
	self.model.selectedAccessoryId = accessoryId
	self.model.selectedSlotId = slotId

	if self.avatarEditComponent then
		self.avatarEditComponent:setSelectedAccessory(accessoryId, slotId)
	end
end

function CashShopAccessoryAdjustCtrl:setSelectedPetAccessory(accessoryId, genId, slotIdx)
	self.model.selectedPetAccessoryId = accessoryId
	self.model.selectedPetGenId = genId
	self.model.selectedPetSlotIdx = slotIdx or 1

	if self.petAccessoryEditComponent then
		self.petAccessoryEditComponent:setSelectedPetAccessory(accessoryId, genId, slotIdx)
	end
end

function CashShopAccessoryAdjustCtrl:resetEditContext()
	if self.avatarEditComponent and self.avatarEditComponent.resetEditContext then
		self.avatarEditComponent:resetEditContext()
	end

	if self.petAccessoryEditComponent and self.petAccessoryEditComponent.resetEditContext then
		self.petAccessoryEditComponent:resetEditContext()
	end
end

function CashShopAccessoryAdjustCtrl:updateAdjustContext(context)
	if not context then
		return
	end

	self:setSelectedAccessory(context.selectedAccessoryId, context.selectedSlotId)
	self:setSelectedPetAccessory(context.selectedPetAccessoryId, context.selectedPetGenId, context.selectedPetSlotIdx)
	self:resetEditContext()
	self:refreshBottomBar()
end

function CashShopAccessoryAdjustCtrl:openAvatarAdjust()
	local isPetEntity = false
	local isShowingPetMode = self.hostCtrl and self.hostCtrl.curComponent and self.hostCtrl.curComponent._showingPet == true

	if self.hostCtrl and self.hostCtrl.avatarComponent and self.hostCtrl.avatarComponent._isCurrentPetEntity then
		isPetEntity = self.hostCtrl.avatarComponent:_isCurrentPetEntity()
	end

	local playerAccessoryId = self.avatarEditComponent and self.avatarEditComponent.selectedAccessoryId or nil
	local playerSlotId = self.avatarEditComponent and self.avatarEditComponent.selectedSlotId or nil
	local petAccessoryId = self.petAccessoryEditComponent and self.petAccessoryEditComponent.selectedPetAccessoryId or nil
	local petGenId = self.petAccessoryEditComponent and self.petAccessoryEditComponent.selectedGenId or nil
	local petSlotIdx = self.petAccessoryEditComponent and self.petAccessoryEditComponent.selectedSlotIdx or nil
	local usePetEditor = isShowingPetMode or isPetEntity and not playerAccessoryId or not playerAccessoryId and petAccessoryId ~= nil

	if usePetEditor then
		if self.avatarEditComponent and self.avatarEditComponent.deactivateBindings then
			self.avatarEditComponent:deactivateBindings()
		end

		if self.avatarEditComponent and self.avatarEditComponent.resetEditContext then
			self.avatarEditComponent:resetEditContext()
		end

		if self.petAccessoryEditComponent then
			self.petAccessoryEditComponent:showAdjustPanel(petAccessoryId, petGenId, petSlotIdx)
		end

		return
	end

	if self.petAccessoryEditComponent and self.petAccessoryEditComponent.deactivateBindings then
		self.petAccessoryEditComponent:deactivateBindings()
	end

	if self.petAccessoryEditComponent and self.petAccessoryEditComponent.resetEditContext then
		self.petAccessoryEditComponent:resetEditContext()
	end

	if self.avatarEditComponent then
		self.avatarEditComponent:showAdjustPanel(playerAccessoryId, playerSlotId)
	end
end

function CashShopAccessoryAdjustCtrl:hideAvatarAdjust()
	if self.avatarEditComponent then
		self.avatarEditComponent:hideAdjustPanel()
	end

	if self.petAccessoryEditComponent then
		self.petAccessoryEditComponent:hideAdjustPanel()
	end
end

function CashShopAccessoryAdjustCtrl:saveAvatarAdjust(callBack, genId)
	if self.avatarEditComponent and self.avatarEditComponent.editing then
		self.avatarEditComponent:saveEdit(callBack)

		return
	end

	if self.petAccessoryEditComponent then
		local avatarComponent = self.hostCtrl and self.hostCtrl.avatarComponent

		self.petAccessoryEditComponent:saveEdit(function(success)
			if success and avatarComponent and avatarComponent.syncPetAccessoryFromServer then
				avatarComponent:syncPetAccessoryFromServer()
			end

			if callBack then
				callBack(success)
			end
		end, genId)
	end
end

function CashShopAccessoryAdjustCtrl:_getCurrentCommodityId()
	if self.hostCtrl and self.hostCtrl.curComponent then
		return self.hostCtrl.curComponent._selectedCommodityId
	end

	return nil
end

function CashShopAccessoryAdjustCtrl:_getCurCommodityData()
	local commodityId = self:_getCurrentCommodityId()

	if not commodityId then
		return nil
	end

	local raw = ClientCashShopUtils.getCommodityData(commodityId)

	if not raw then
		return nil
	end

	if not raw.commodityId then
		return setmetatable({
			commodityId = commodityId
		}, {
			__index = raw
		})
	end

	return raw
end

function CashShopAccessoryAdjustCtrl:onBuyItemResult(data)
	if not data or not data.success or data.commodityId ~= self:_getCurrentCommodityId() then
		return
	end

	local genId = data.genId

	if not genId or genId == 0 then
		local accessoryId = self.petAccessoryEditComponent and self.petAccessoryEditComponent.selectedPetAccessoryId

		if accessoryId then
			genId = self:_findPetJewelryGenId(accessoryId)
		end
	end

	if not genId or genId == 0 then
		pg.global.ui.tips:showTextTip(pg.getGameString("SHOP_PET_ADJUST_SAVE_FAIL"))
		self:refreshBottomBar()

		return
	end

	local avatarComponent = self.hostCtrl and self.hostCtrl.avatarComponent
	local slotIdx = self.petAccessoryEditComponent and self.petAccessoryEditComponent.selectedSlotIdx or 1

	if not avatarComponent or not avatarComponent.curPetId then
		pg.global.ui.tips:showTextTip(pg.getGameString("SHOP_PET_ADJUST_SAVE_FAIL"))
		self:refreshBottomBar()

		return
	end

	local setInfo = {
		{
			slotIdx,
			genId,
			true
		}
	}

	pg.me:serverMsg("RPC_CS_MultiSetPetJewelry", avatarComponent.curPetId, setInfo, function(res)
		if not res then
			pg.global.ui.tips:showTextTip(pg.getGameString("SHOP_PET_ADJUST_SAVE_FAIL"))
			self:refreshBottomBar()

			return
		end

		if self.petAccessoryEditComponent then
			self.petAccessoryEditComponent.selectedGenId = genId
		end

		self.model.selectedPetGenId = genId

		self:saveAvatarAdjust(function(success)
			if not success then
				pg.global.ui.tips:showTextTip(pg.getGameString("SHOP_PET_ADJUST_SAVE_FAIL"))
			else
				pg.global.ui:close(UIConst.UI_ID_CASH_ACCESSORY_ADJUST)
			end
		end, genId)
		self:refreshBottomBar()
	end)
end

function CashShopAccessoryAdjustCtrl:_findPetJewelryGenId(accessoryId)
	local bag = ItemUtils.getTypedBag(pg.me, ItemConst.INV_TYPE_PET_JEWELRY)

	if not bag then
		return nil
	end

	local allItems = bag:getAll()

	if not allItems then
		return nil
	end

	for genId, item in pairs(allItems) do
		if item.id == accessoryId then
			return genId
		end
	end

	return nil
end

function CashShopAccessoryAdjustCtrl:_getEffectiveCost(data)
	if not data then
		return nil
	end

	local commodityId = data.commodityId or self:_getCurrentCommodityId()

	if commodityId then
		local cost, errorCode = ClientCashShopUtils.getCommodityPrimaryCost(commodityId, 1)

		if cost or errorCode then
			return cost, errorCode
		end
	end

	local baseCost = data.cost and data.cost[1]
	local specialCostEntry = data.specialCost and data.specialCost[1]

	if specialCostEntry then
		local specialStart = Utils.getConfigTimeOfArea(data, "specialStartTime")
		local specialEnd = Utils.getConfigTimeOfArea(data, "specialEndTime")

		if specialStart and specialEnd and TimeUtils.isInRangeTimestamp(specialStart, specialEnd) then
			return specialCostEntry
		end
	end

	return baseCost
end

function CashShopAccessoryAdjustCtrl:refreshBottomBar()
	if not self.view then
		return
	end

	local data = self:_getCurCommodityData()
	local state = data and ClientCashShopUtils.getCommodityState(data) or 0
	local isOwned = state == ClientCashShopUtils.COMMODITY_STATE.POSSESS
	local cost = self:_getEffectiveCost(data)

	if self.view.iconUImage then
		self.view.iconUImage.url = LuaUIUtils.getIconByItemId(cost and cost[1])
	end

	if self.view.textUBaseText then
		ClientTextUtils.setText(self.view.textUBaseText, cost and cost[2] or 0)
	end

	if self.view.listCurrencyUList then
		local currencyList = cost and {
			{
				itemId = cost[1]
			}
		} or {}

		function self.view.listCurrencyUList.luaRenderItem(button, _, item)
			LuaUIUtils.setTopCurrencyItem(button, item.itemId)
		end

		self.view.listCurrencyUList:SetList(currencyList)
	end

	if self.view.layoutBoxCurrencyUWidget then
		self.view.layoutBoxCurrencyUWidget.gameObject:SetActiveEx(not isOwned)
	end

	if self.view.txtNameUBaseText then
		ClientTextUtils.setText(self.view.txtNameUBaseText, isOwned and pg.getGameString("SHOP_SAVE") or pg.getGameString("SHOP_BUY_SAVE"))
	end

	if self.view.tMPUBaseText then
		ClientTextUtils.setText(self.view.tMPUBaseText, pg.getGameString("SHOP_BACK"))
	end
end

return CashShopAccessoryAdjustCtrl
