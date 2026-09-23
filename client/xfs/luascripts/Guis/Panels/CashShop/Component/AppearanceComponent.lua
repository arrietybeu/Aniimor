-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashShop\\Component\\AppearanceComponent.lua

local Class = require("Core.Framework.Class")
local CashShopContainerComponent = require("Guis.Panels.CashShop.Component.CashShopContainerComponent")
local CashShopConst = require("Const.CashShopConst")
local UIConst = require("Const.UIConst")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local ShopConstantData = require("Data.shopmall_constant_data")
local AppearanceComponent = Class.LightClass("AppearanceComponent", CashShopContainerComponent)

function AppearanceComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	CashShopContainerComponent.findObjects(self)

	local objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")

	self._subContainers = {
		[CashShopConst.ShopAvatarType.PROMINENT] = {
			ref = objectReference:GetRefValue("fashionUContainer")
		},
		[CashShopConst.ShopAvatarType.NORMAL] = {
			ref = objectReference:GetRefValue("accessoriesUContainer")
		}
	}
end

function AppearanceComponent:addListener()
	if not self:checkContentLoaded() then
		return
	end

	CashShopContainerComponent.addListener(self)
end

function AppearanceComponent:onEnterPage(tabId)
	self._pendingFocusFashionList = true

	CashShopContainerComponent.onEnterPage(self, tabId)
end

function AppearanceComponent:retryPage()
	CashShopContainerComponent.retryPage(self)

	if self:checkContentLoaded() then
		self:_hideGroupTab()
	end
end

function AppearanceComponent:_onContentLoaded()
	CashShopContainerComponent._onContentLoaded(self)
	self:_hideGroupTab()
end

function AppearanceComponent:_hideGroupTab()
	if self.listGroupTab then
		self.listGroupTab.gameObject:SetActiveEx(false)
	end
end

function AppearanceComponent:onBeforeExitPage()
	self:_clearFilterState()
	CashShopContainerComponent.onBeforeExitPage(self)
end

function AppearanceComponent:_onGroupSelected(data)
	self:_clearFilterState()
	self:_clearPreviewBeforeDisplaySwitch()
	CashShopContainerComponent._onGroupSelected(self, data)
end

function AppearanceComponent:_clearFilterState()
	self._filterState = nil
	self._filterStates = nil

	if self._subContainers then
		for _, info in pairs(self._subContainers) do
			if info._btnFilter then
				info._btnFilter:TryChangePage("filter", 0)
			end
		end
	end
end

function AppearanceComponent:_getDisplayCommodityList()
	local list = ClientCashShopUtils.getCommodityListByGroupId(self.categoryId)

	if self._filterState then
		list = ClientCashShopUtils.filterAndSortCommodityList(list, self._filterState)
	end

	list = self:_filterListByGender(list)
	list = self:_sortSoldOutToEnd(list)

	return list
end

function AppearanceComponent:refreshPage()
	local shopType = self._currentGroupData and self._currentGroupData.shopType or CashShopConst.ShopAvatarType.PROMINENT

	self:_switchSubContainer(shopType, function()
		CashShopContainerComponent.refreshPage(self)
		self:_consumePendingFashionFocus()
	end)
end

function AppearanceComponent:_consumePendingFashionFocus()
	if not self._pendingFocusFashionList then
		return
	end

	self._pendingFocusFashionList = nil

	if not pg.game.input:isUsingGamepad() or not pg.global.navMgr then
		return
	end

	local listUList = self.listUList

	self:startFrameTimer(function()
		local navMgr = pg.global.navMgr

		if not navMgr then
			return
		end

		if not navMgr:FocusGroupByName("ListFashion", false) and listUList then
			navMgr:FocusItemInThis(listUList)
		end
	end, 1)
end

function AppearanceComponent:_onSelectCommodityNotFound(commodityId)
	if not self._filterState then
		return false
	end

	self:_clearFilterState()

	self.ctrl._pendingNav = {
		commodityId = commodityId
	}

	self:refreshPage()

	return true
end

function AppearanceComponent:_shouldShowProductTabWidget(data, commodityInfo)
	if CashShopContainerComponent._shouldShowProductTabWidget(self, data, commodityInfo) then
		return true
	end

	local shopType = self._currentGroupData and self._currentGroupData.shopType or CashShopConst.ShopAvatarType.PROMINENT
	local itemId = self:_resolveCommodityItemId(data)
	local appearanceInfo = self:_getAppearanceInfoByGender(itemId)

	return shopType == CashShopConst.ShopAvatarType.NORMAL and appearanceInfo ~= nil and appearanceInfo[1] ~= nil and appearanceInfo[2] ~= nil
end

function AppearanceComponent:_switchSubContainer(showType, callback)
	CashShopContainerComponent._switchSubContainer(self, showType, function()
		local info = self._subContainers and self._subContainers[showType]

		if info and info.objectReference then
			self:_setupSubContainerButtons(info)
		end

		local avatarComponent = self.ctrl.avatarComponent

		if avatarComponent then
			local shopType = self._currentGroupData and self._currentGroupData.shopType or CashShopConst.ShopAvatarType.PROMINENT
			local constData = shopType == CashShopConst.ShopAvatarType.NORMAL and ShopConstantData.jewelry_background or ShopConstantData.avatar_background

			if constData then
				avatarComponent:setBackgroundByPrefab(constData.number)
			end
		end

		if callback then
			callback()
		end
	end)
end

function AppearanceComponent:_setupSubContainerButtons(info)
	if info._btnBound then
		return
	end

	info._btnBound = true

	local btnFilter = info.objectReference:GetRefValue("btnFilterUButton")

	if btnFilter then
		info._btnFilter = btnFilter

		function btnFilter.luaClick()
			local groupId = self._currentGroupId or self.categoryId

			if not self._filterStates then
				self._filterStates = {}
			end

			pg.global.ui:open(UIConst.UI_ID_CASH_FILTER, {
				groupId = groupId,
				previousState = self._filterStates[groupId],
				onConfirm = function(filterState)
					if filterState.isFiltering then
						self._filterState = filterState
						self._filterStates[groupId] = filterState

						btnFilter:TryChangePage("filter", 1)
						self:refreshPage()
					else
						local hadFilter = self._filterState ~= nil

						self._filterState = nil
						self._filterStates[groupId] = nil

						btnFilter:TryChangePage("filter", 0)

						if hadFilter then
							self:refreshPage()
						end
					end
				end,
				onReset = function()
					self._filterState = nil
					self._filterStates[groupId] = nil

					btnFilter:TryChangePage("filter", 0)
					self:refreshPage()
				end
			})
		end
	end

	local btnEllipses = info.objectReference:GetRefValue("btnEllipsesUButton")

	if btnEllipses then
		self:_setupEllipsesTooltip(btnEllipses)
	end
end

return AppearanceComponent
