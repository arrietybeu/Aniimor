-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Shop\\ShopBaseCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ShopBuyComponent = require("Guis.Panels.Shop.Component.ShopBuyComponent")
local ShopClassifyData = require("Data.shop_classify_data")
local ShopTagData = require("Data.shop_tag_data")
local ShopEventData = require("Data.shop_event_data")
local ItemConst = require("Common.Const.ItemConst")
local ItemData = require("Data.item_data")
local UIConst = require("Const.UIConst")
local CurrencyAutoChangeData = require("Data.currency_auto_change_data")
local Const = require("Common.Const.Const")
local CashShopConst = require("Const.CashShopConst")
local HotkeyConst = require("Const.HotkeyConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local ItemUtils = require("Common.Utils.ItemUtils")
local ShopBaseCtrl = Class.LightClass("ShopBaseCtrl", UICtrl)

function ShopBaseCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:_rebuildShopContext(info)
end

function ShopBaseCtrl:_rebuildShopContext(info)
	if self.shopBuyComponent then
		self.shopBuyComponent:onDestroy()
	end

	self.shopBuyComponent = ShopBuyComponent.new(self, info)
	self.isRogue = false

	if info then
		self.shopId = info.shopTags and info.shopTags[1] or nil
		self.npcGlobalId = info.npcGlobalId
		self.shopClassCfg = info.shopClassCfg or self.shopId and ShopClassifyData[self.shopId]
		self.isAFKShop = self.shopClassCfg and self.shopClassCfg.type == 2
	else
		self.shopId = nil
		self.isAFKShop = false
		self.shopClassCfg = nil
	end

	if self.view.backgroundUImage and self.shopClassCfg and not string.isNilOrEmpty(self.shopClassCfg.bgRes) then
		self.view.backgroundUImage.url = self.shopClassCfg.bgRes
	end
end

function ShopBaseCtrl:checkCanOpen(showNotice, info)
	local shopTags, locateShopTag, locateShopItemId, classifyId = self.model:getSellShopTags(info)

	if #shopTags > 0 then
		return true
	else
		pg.global.showBubbleMessageRaw(pg.getGameString("NO_SHOP_OPEN"), 1)

		return false
	end

	return true
end

function ShopBaseCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	local newShopId = info and info.shopTags and info.shopTags[1] or nil

	if newShopId ~= nil and newShopId ~= self.shopId then
		self:_rebuildShopContext(info)
		self:Init()
	end

	if info and info.onFishingCaptureShopOpened then
		info.onFishingCaptureShopOpened()
	end

	if info and (info.tabId or info.groupId or info.commodityId) then
		self:navigateTo(info.tabId, info.groupId, info.commodityId)
	end
end

function ShopBaseCtrl:navigateTo(tabId, groupId, commodityId)
	if not self.shopBuyComponent then
		return
	end

	if not tabId and commodityId then
		local commodityCfg = self.model:getShopItemConfig(commodityId)

		tabId = commodityCfg and commodityCfg.tag or nil
	end

	if tabId and not self.isRogue then
		local shopTags = self.shopBuyComponent.shopTags

		if not self.model:containsShopTag(shopTags or {}, tabId) or not self.model:isShopTagOpen(tabId) then
			pg.global.ui.tips:showTextTip(pg.getGameString("FUNCTION_NOT_OPEN"))

			return
		end
	end

	self.shopBuyComponent:navigateTo(tabId, groupId, commodityId)
end

function ShopBaseCtrl:onShow()
	self:addRelatedNpc(self.npcGlobalId)
end

function ShopBaseCtrl:onHide()
	self:removeRelatedNpc(self.npcGlobalId)
end

function ShopBaseCtrl:onDestroy()
	UICtrl.onDestroy(self)

	self.shopBuyComponent = nil
end

function ShopBaseCtrl:Init()
	self.shopBuyComponent:onShow()
end

function ShopBaseCtrl:getNavigationListenerName()
	return "Shop"
end

function ShopBaseCtrl:addListener()
	function self.view.btnExit.luaClick()
		self:dismiss()
	end

	function self.view.listCoins.luaRenderItem(button, index, data)
		self:onRefreshCurrencyItem(button, index, data)
	end

	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:AddLuaFocusCursorMovedListener(self:getNavigationListenerName(), function()
			self:refreshConsoleBarState()
		end)
	end
end

function ShopBaseCtrl:refreshConsoleBarState()
	if CS.XGUI.Navigation.NavManager.Instance then
		local groupName = CS.XGUI.Navigation.NavManager.Instance.CurrentFocusedGroupName
		local isInCurrency = groupName == "ListCurrency"

		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("isInCurrency", isInCurrency)
	end
end

function ShopBaseCtrl:refreshCurrency(shopTagType)
	local shopTagCfg = ShopTagData[shopTagType]

	if shopTagCfg then
		local relatedCurrencyIdSet = {}
		local shopItems = self.model:getBuyShopProps(shopTagType)

		for _, shopItem in ipairs(shopItems) do
			local cost = self.model:getBuyPriceInfo(shopItem.id, 1)

			if cost then
				for _, costInfo in ipairs(cost) do
					relatedCurrencyIdSet[costInfo[1]] = true
				end
			end
		end

		local currencyItems = {}

		for _, currencyId in ipairs(shopTagCfg.currency) do
			if relatedCurrencyIdSet[currencyId] then
				table.insert(currencyItems, {
					id = currencyId
				})
			end
		end

		self.view.listCoins:SetList(currencyItems)

		return currencyItems
	end

	return {}
end

function ShopBaseCtrl:onRefreshSellShopList(shopTagType)
	local items = self.model:getSellShopProps(shopTagType)

	self.view.listProp:SetList(items)

	local itemCount = #items

	if itemCount > 0 then
		self.view.listProp:SelectItem(0)
		self:onShowBuyShopItemDetail(items[1].id)
	end
end

function ShopBaseCtrl:onBuyItemsCallback(data)
	self.shopBuyComponent:onBuyItemsCallback(data.shopItemId)

	if self.isAFKShop then
		local shopEventCfg = ShopEventData[self.shopId]

		self:onShopBuyItemsCallback(data, shopEventCfg)
	end
end

function ShopBaseCtrl:onShopBuyItemsCallback(data, shopEventCfg)
	return
end

function ShopBaseCtrl:onMoneyChanged(data)
	local itemId = data.itemId or data.id
	local btns = self.view.listCoins:GetAllButtons()

	for i = 0, btns.Length - 1 do
		if btns[i].name == tostring(itemId) then
			local coms = self.view:getCurrencyItemComs(btns[i])

			ClientTextUtils.setText(coms.countTxt, self:_getCurrencyDisplayCount(itemId))

			break
		end
	end

	if self.shopBuyComponent then
		self.shopBuyComponent:onMoneyChanged(data)
	end
end

function ShopBaseCtrl:onHomelandWarehouseItemChanged(data)
	if self.shopBuyComponent then
		self.shopBuyComponent:onHomelandWarehouseItemChanged(data)
	end
end

function ShopBaseCtrl:onRefreshCurrencyItem(button, index, data)
	local coms = self.view:getCurrencyItemComs(button)
	local itemId = data.id

	coms.icon.url = LuaUIUtils.getIconByItemId(data.id, LuaUIUtils.ITEM_ICON_TYPE.ICON_SMALL)

	local count = pg.me:getItemCountById(data.id)

	ClientTextUtils.setText(coms.countTxt, self:_getCurrencyDisplayCount(itemId))

	button.name = tostring(data.id)

	function button.luaClick()
		pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
			id = data.id,
			num = count,
			targetRect = button
		})
	end

	local btnAdd = button:GetComponent("ObjectReference"):GetRefValue("btnAdd")
	local isRecharge = itemId == ItemConst.ITEM_SPECIAL_MONEY_CASH_BOUND
	local canAdd = CurrencyAutoChangeData[itemId] ~= nil or isRecharge

	button:RemoveLuaGamepadHotkey()

	if canAdd then
		button:SetGamepadLongPress(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonSouth, nil, 0, function()
			if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
				pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
			else
				pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
					id = itemId,
					num = pg.me:getItemCountById(itemId),
					targetRect = button
				})
			end

			return false
		end)
		button:SetHotkeyActiveOnlyInCurrentItem(true)
		button:SetHotkeyConsoleBar("GIFTPACK_TIPS", 0)
	end

	button:TryChangePage("IsAdd", canAdd and 1 or 0)

	if canAdd and btnAdd then
		function btnAdd.luaClick()
			if pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_ITEM_TIP) then
				pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
			end

			if canAdd then
				if isRecharge then
					if not LuaUIUtils.checkFuncCanOpen(Const.FUNCTION_IDS.CASHSHOP) then
						return
					end

					if pg.global.ui:checkUIOpen(UIConst.UI_ID_CASH_SHOP) then
						pg.global.ui.cashShop:navigateTo(CashShopConst.CategoryType.RECHARGE)
					elseif pg.global.platform:isPS() and RechargeUtils.isEmptyStore() then
						PlatformBridgeLuaFacade.ShowCommonMessageDialogEmptyStore()
					else
						pg.global.ui:open(UIConst.UI_ID_CASH_SHOP, {
							tabId = CashShopConst.CategoryType.RECHARGE
						})
					end
				else
					LuaUIUtils.openVitalityGot(itemId)
				end
			end
		end
	end
end

function ShopBaseCtrl:clearAFKShopTimers()
	if self.sleepTimer then
		self:killTimer(self.sleepTimer)

		self.sleepTimer = nil
	end

	if self.waitTimer then
		self:killTimer(self.waitTimer)

		self.waitTimer = nil
	end
end

function ShopBaseCtrl:removeNavigationListener()
	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:RemoveLuaFocusCursorMovedListener(self:getNavigationListenerName())
	end
end

function ShopBaseCtrl:onInputDeviceChanged(deviceType)
	self.shopBuyComponent:onInputDeviceChanged(deviceType)
end

function ShopBaseCtrl:onRefreshList()
	self.shopBuyComponent:onRefreshList()
end

function ShopBaseCtrl:_getCurrencyDisplayCount(itemId)
	local count = pg.me:getItemCountById(itemId)

	if ItemUtils.NEGATIVE_MONEY_TYPE[itemId] and count < 0 then
		return pg.getFormatText("<style=Debuff>{0}</style>", count)
	end

	return count
end

function ShopBaseCtrl:partitionBuyShopListItems(shopTagType, shopItems)
	return shopItems, {}
end

function ShopBaseCtrl:onBuyShopListRefreshed(shopTagType, extensionItems, selectedExtensionIndex)
	return
end

function ShopBaseCtrl:onBuyShopItemPreviewChanged(shopItemId)
	return
end

function ShopBaseCtrl:onShopTagItemRendered(button, index, data)
	return
end

function ShopBaseCtrl:onShopTagSelected(shopTagType)
	return
end

function ShopBaseCtrl:refreshVisibleShopList()
	if not self.shopBuyComponent or not self.shopBuyComponent.curShopTagType then
		return
	end

	local shopBuyComponent = self.shopBuyComponent

	shopBuyComponent:onRefreshBuyShopList(shopBuyComponent.curShopTagType, shopBuyComponent.curShopItemId, shopBuyComponent.paginationId)
	shopBuyComponent:refreshCurrentBuyShopItemDetail(false)
end

return ShopBaseCtrl
