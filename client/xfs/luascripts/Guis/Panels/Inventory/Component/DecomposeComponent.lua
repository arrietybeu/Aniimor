-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Inventory\\Component\\DecomposeComponent.lua

local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local ItemData = require("Data.item_data")
local UIComponent = require("Guis.Helper.UIComponent")
local TimerManager = require("Core.Timer.TimerManager")
local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local DecomposeComponent = Class.LightClass("DecomposeComponent", UIComponent)
local UIConst = require("Const.UIConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local ItemQuality = require("Data.item_quality")
local ItemConst = require("Common.Const.ItemConst")
local MessageName = require("Const.MessageName")
local logger = require("Core.Log.LoggerManager").getLogger("DecomposeComponent")

DecomposeComponent.messages = {
	[MessageName.ON_BACKPACK_QUICK_BALL_CHANGE] = {
		"clearCache"
	},
	[MessageName.ITEM_GEN_STATUS_LOCKED] = {
		"clearCache"
	}
}

function DecomposeComponent:onCtor(info)
	self.isRobEggMode = info and info.isRobEggMode or false
end

function DecomposeComponent:findObjects()
	if self.isRobEggMode then
		self.container = self.view.recyclePanelContainer
		self.listProp = self.ctrl.listProp
		self.listTab = self.ctrl.listTabMain
		self.listTabThird = self.ctrl.listTabThird
	else
		self.container = self.view.recyclePanel
		self.listProp = self.view.listProp
		self.listTab = self.view.listTabIconUList
		self.listTabThird = self.view.listTabThird
	end
end

function DecomposeComponent:findContainerObjects()
	local objectReference = self.container.content.transform:GetComponent("ObjectReference")

	self.listSel = objectReference:GetRefValue("listSel")
	self.listReward = objectReference:GetRefValue("listReward")
	self.sortSelector = objectReference:GetRefValue("sortSelector")
	self.btnSort = objectReference:GetRefValue("btnSort")
	self.recyclePreview = objectReference:GetRefValue("recyclePreview")
	self.btnCheck = objectReference:GetRefValue("btnCheck")
	self.txtLimitNum = objectReference:GetRefValue("txtLimitNum")
	self.btnConfirm = objectReference:GetRefValue("btnConfirm")
	self.btnClose = objectReference:GetRefValue("btnClose")
	self.inputField = objectReference:GetRefValue("inputField")
	self.imgBgBlack = objectReference:GetRefValue("imgBgBlack")
	self.btnClosePreview = objectReference:GetRefValue("btnClosePreview")
	self.numSelector = objectReference:GetRefValue("numSelector")
	self.listFilterUList = objectReference:GetRefValue("listFilterUList")
	self.selectorUPopupForm = objectReference:GetRefValue("selectorUPopupForm")

	function self.listProp.luaVirtualListRefreshCb()
		self:refreshAllIconsAndNums()
	end

	function self.listSel.luaRenderItem(button, index, data)
		self:setDestroyPanelSelectedListItem(button, index, data)
	end

	function self.listReward.luaRenderItem(button, index, data)
		self:setResolveResultListItem(button, index, data)
	end

	function self.btnClose.luaClick()
		if pg.game.input:isUsingGamepad() and self.recyclePreview and self.recyclePreview.gameObject.activeInHierarchy then
			self:displayDecomposePanelSelectedList()

			return
		end

		self:onExitDecomposeSate()
	end

	function self.btnCheck.luaClick()
		self:displayDecomposePanelSelectedList()
	end

	function self.btnConfirm.luaClick()
		if self.selectedGensCount <= 0 then
			pg.global.showBubbleMessageRaw(pg.getGameString("SELECT_NONE_TIP"))

			return
		end

		local props = self.model:getPropsByDecomposeSelectedList(self.selectedGensTable)

		pg.global.ui:open(UIConst.UI_ID_INVENTORY_DECOMPOSE, {
			selectedGensTable = self.selectedGensTable,
			propList = props,
			confirmCallback = function()
				self:onExitDecomposeSate()
			end
		})
		self:refreshSelectorState(false)
	end

	function self.btnSort.luaClick()
		self.model:setSortAscendingOrder(not self.model.sortIsAscending)
		self.ctrl:onTabSelectChanged()
	end

	function self.sortSelector.luaSelectedChanged(selector)
		self.model:setSortIdxType(selector.selectedIndex)
		self.ctrl:onTabSelectChanged()
	end

	function self.btnClosePreview.luaClick()
		self.recyclePreview:SetActive(false)
	end

	function self.numSelector.luaValueChanged(value)
		self:setSelectedCount(self.curSelectedGenId, value)
		self:refreshSelectorState(true)
		self:refreshAllIconsAndNums()
	end

	function self.listFilterUList.luaRenderItem(button, index, data)
		self:onRenderFilterItem(button, index, data)

		function button.luaSelectChanged()
			if self.isRefreshingFilterStates then
				return
			end

			self:onFilterItemClicked(data)
		end
	end

	function self.selectorUPopupForm.luaCloseAction()
		self.selectorUPopupForm:SetActive(false)

		if NotNil(self.curSelectedBtn) then
			self.curSelectedBtn.isSelected = false
			self.curSelectedBtn.enabledVisualSelect = false
		end
	end

	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:AddLuaFocusCursorMovedListener("InventoryDecomposeCancelState", function()
			self:refreshCtrlConsoleBar()
		end)
	end
end

function DecomposeComponent:getFocusedListPropData()
	local navMgr = CS.XGUI.Navigation.NavManager.Instance

	if not navMgr then
		return nil
	end

	local navItem = navMgr.CurrentFocusedUContent

	if not navItem then
		return nil
	end

	if self.listSel and self.recyclePreview and self.recyclePreview.gameObject.activeInHierarchy then
		local idx = self.listSel:GetChildIndex(navItem)

		if idx and idx >= 0 then
			local d = self.listSel.itemData

			if d then
				return d[idx]
			end
		end
	end

	if self.listProp then
		local idx = self.listProp:GetChildIndex(navItem)

		if idx and idx >= 0 then
			local d = self.listProp.itemData

			if d then
				return d[idx]
			end
		end
	end

	return nil
end

function DecomposeComponent:initView()
	self.curSelectedGenId = nil
	self.curPropData = nil
	self.selectedGensTable = {}
	self.selectedGensCount = 0
	self.isContainerLoading = false
	self.isRefreshingFilterStates = false
	self.decomposableItemsCache = nil
	self.tabButtonsCache = nil
	self.thirdTabButtonsCache = nil
	self.curSelectedBtn = nil
end

function DecomposeComponent:initContainer(callback)
	if self.isContainerLoading then
		return
	end

	if self.container:CheckURLLoaded() then
		if callback then
			callback()
		end

		return
	end

	self.isContainerLoading = true

	self.container:LoadDefaultUrlManually(function()
		self.isContainerLoading = false

		self:findContainerObjects()

		if callback then
			callback()
		end
	end)
end

function DecomposeComponent:findPackSlotByGenId(genId)
	local tabDataList = self.listTab.itemData
	local count = tabDataList.Count

	for i = 1, count do
		local tab = tabDataList[i - 1]
		local bag = ItemUtils.getTypedBag(pg.me, tab.invId)

		if bag and bag[genId] ~= nil then
			return bag[genId]
		end
	end

	return nil
end

function DecomposeComponent:setSelectedCount(genId, count)
	local old = self.selectedGensTable[genId]

	if count == nil or count <= 0 then
		if old ~= nil then
			self.selectedGensTable[genId] = nil
			self.selectedGensCount = self.selectedGensCount - 1
		end
	else
		if old == nil then
			self.selectedGensCount = self.selectedGensCount + 1
		end

		self.selectedGensTable[genId] = count
	end
end

function DecomposeComponent:onDestroy()
	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:RemoveLuaFocusCursorMovedListener("InventoryDecomposeCancelState")
	end

	UIComponent.onDestroy(self)
	self:onExitDecomposeSate()
end

function DecomposeComponent:setDestroyPanelSelectedListItem(button, index, data)
	LuaUIUtils.setPropCard(button, index, data, UIConst.INVENTORY_CARD.CARD_IDX)

	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")
	local btnDelUButton = objectReference:GetRefValue("btnDelUButton")

	txtNameUText.text = self.selectedGensTable[data.index] or ""

	btnDelUButton.gameObject:SetActiveEx(true)

	function btnDelUButton.luaClick()
		self:decreaseSelected(data.index, true)
	end

	function button.luaClick()
		self.curSelectedGenId = data.index
		self.curPropData = data

		if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
			pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
		else
			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
				id = data.itemId,
				num = data.itemNum,
				targetRect = button
			})
		end

		self:refreshSelectorState(true)
	end
end

function DecomposeComponent:refreshSelectorState(isActive)
	if not isActive then
		self.numSelector:SetActive(false)
		self.sortSelector:SetActive(false)
		self.btnSort:SetActive(false)
		self:refreshCtrlConsoleBar(false)

		return
	end

	local stackCount = ItemUtils.getItemStackCount(self.curPropData.itemId)
	local showSelector = stackCount > 0

	self.numSelector:SetActive(showSelector)
	self.sortSelector:SetActive(not showSelector)
	self.btnSort:SetActive(not showSelector)

	if showSelector then
		local count = self.curPropData.packSlot and self.curPropData.packSlot.count or self.curPropData.count or 0

		self.numSelector:SetMaxValueWithoutNotify(count)
		self.numSelector:SetMinValueWithoutNotify(0)
		self.numSelector:SetValueWithoutNotify(self.selectedGensTable[self.curSelectedGenId] or 0)
	end

	self:refreshCtrlConsoleBar(true)
end

function DecomposeComponent:refreshCtrlConsoleBar(isActive)
	if not CS.XGUI.Navigation.NavManager.Instance then
		return
	end

	if isActive ~= nil then
		local isNumSelectHide = not self:getSelectorState(isActive) and self.ctrl.model:isInOperationState(self.ctrl.model.STATE_DECOMPOSE) or false

		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("isNumSelectHide", isNumSelectHide, true)
	end

	local canCancel = false

	if self.model:isInOperationState(self.model.STATE_DECOMPOSE) then
		local data = self:getFocusedListPropData()

		if data and self.selectedGensTable[data.index] then
			canCancel = true
		end
	end

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canCancelDecompose", canCancel)
end

function DecomposeComponent:getSelectorState(isActive)
	return self.numSelector and isActive or false
end

function DecomposeComponent:decreaseSelected(genId, isClear)
	if genId == nil then
		return
	end

	if self.selectedGensTable[genId] == nil then
		return
	end

	local newCount = isClear and 0 or self.selectedGensTable[genId] - 1

	self:setSelectedCount(genId, newCount)

	if self.selectedGensTable[genId] == nil and self.curSelectedGenId == genId then
		self:refreshSelectorState(false)
	end

	self:refreshAllIconsAndNums()
end

function DecomposeComponent:increaseSelected(genId)
	if genId == nil then
		return
	end

	if self.curSelectedGenId == genId and self.selectedGensTable[genId] == nil then
		if pg.game.input:isUsingGamepad() then
			self:setSelectedCount(genId, 0)
		else
			self:setSelectedCount(genId, 1)
		end
	else
		if self.selectedGensTable[genId] == nil then
			return
		end

		local tempContainer = self:findPackSlotByGenId(genId)

		if tempContainer == nil then
			return
		end

		if self.selectedGensTable[genId] >= tempContainer.count then
			self:refreshSelectorState(true)

			return
		end

		if pg.game.input:isUsingGamepad() then
			self:setSelectedCount(genId, self.selectedGensTable[genId])
		else
			self:setSelectedCount(genId, self.selectedGensTable[genId] + 1)
		end
	end

	self:refreshSelectorState(true)
	self:refreshAllIconsAndNums()
end

function DecomposeComponent:nocreaseSelected(genId)
	if genId == nil then
		return
	end

	local hasSelected = self.selectedGensTable[genId] ~= nil

	self:refreshSelectorState(hasSelected)
	self:refreshAllIconsAndNums()
end

function DecomposeComponent:maxAndMinSelect(genId, isMax)
	if genId == nil then
		return
	end

	if self.curSelectedGenId == genId and self.selectedGensTable[genId] == nil then
		local count = self.curPropData.packSlot and self.curPropData.packSlot.count or self.curPropData.count or 0

		self:setSelectedCount(genId, isMax and count or 1)
	else
		if self.selectedGensTable[genId] == nil then
			return
		end

		local tempContainer = self:findPackSlotByGenId(genId)

		if tempContainer == nil then
			return
		end

		if isMax then
			if self.selectedGensTable[genId] >= tempContainer.count then
				return
			end

			self:setSelectedCount(genId, tempContainer.count)
		else
			self:setSelectedCount(genId, 1)
		end
	end

	self:refreshSelectorState(true)
	self.numSelector:SetValueWithoutNotify(self.selectedGensTable[genId])
	self:refreshAllIconsAndNums()
end

function DecomposeComponent:onEnterDecomposeSate()
	self:initContainer(function()
		if self.model:isInOperationState(self.model.STATE_DECOMPOSE) then
			return
		end

		self.model:setOperationState(self.model.STATE_DECOMPOSE)
		self.container:SetActive(true)
		self.recyclePreview:SetActive(false)

		self.txtLimitNum.text = "0/100"

		if not self.isRobEggMode then
			self.ctrl:showDetailLockBtn(false)
		end

		self:switchListBtnState(true)

		self.decomposableItemsCache = nil

		self:buildTabButtonsCache()
		self:buildThirdTabButtonsCache()
		self:refreshFilterList()
		self:refreshFilterStates()
		self:refreshSelectorState(false)

		if self.view.consoleBarTransform and self.ctrl and self.ctrl.ConsoleBarStateTwo then
			LuaUIUtils.setCommonConsoleBarList(self.view.consoleBarTransform, self.ctrl.ConsoleBarStateTwo)
		end

		self:tryOpenSelectorOnFocusedItem()
	end)
end

function DecomposeComponent:tryOpenSelectorOnFocusedItem()
	if not pg.game.input:isUsingGamepad() then
		return
	end

	local navMgr = CS.XGUI.Navigation.NavManager.Instance

	if not navMgr then
		return
	end

	local navItem = navMgr.CurrentFocusedUContent

	if IsNil(navItem) then
		return
	end

	if not navItem.interactable then
		return
	end

	if not self.listProp then
		return
	end

	local idx = self.listProp:GetChildIndex(navItem)

	if not idx or idx < 0 then
		return
	end

	local propData = self.listProp.itemData and self.listProp.itemData[idx]

	if not propData then
		return
	end

	self.curSelectedGenId = propData.index
	self.curPropData = propData

	self.selectorUPopupForm:SetActive(true)
	self.selectorUPopupForm:SetModal(false)
	self.selectorUPopupForm:OpenPopup(navItem)
	self:refreshSelectorState(true)
end

function DecomposeComponent:onExitDecomposeSate()
	if not self.model:isInOperationState(self.model.STATE_DECOMPOSE) then
		return
	end

	self.model:setOperationState(self.model.STATE_NORMAL)
	self.container:SetActive(false)
	self.ctrl:resetDecomposeStateList()

	self.curSelectedGenId = nil
	self.curPropData = nil
	self.selectedGensTable = {}
	self.selectedGensCount = 0
	self.decomposableItemsCache = nil

	self:resetFilterStates()
	self:resetTabIndicators()
	self:resetThirdTabIndicators()
	self:switchListBtnState(false)

	if not self.isRobEggMode then
		self.ctrl:showDetailLockBtn(true)
	end

	if self.view.consoleBarTransform and self.ctrl and self.ctrl.ConsoleBarStateOne then
		LuaUIUtils.setCommonConsoleBarList(self.view.consoleBarTransform, self.ctrl.ConsoleBarStateOne)
	end

	self:refreshCtrlConsoleBar(false)
end

function DecomposeComponent:switchListBtnState(flag)
	if not self.model:isInOperationState(self.model.STATE_DECOMPOSE) then
		flag = false
	end

	self.ctrl:switchListBtnState(flag)
end

function DecomposeComponent:displayDecomposePanelSelectedList()
	if self.recyclePreview.gameObject.activeInHierarchy == true then
		self.recyclePreview:SetActive(false)
		self.btnCheck:TryChangePage("button", 0)
	else
		self.recyclePreview:SetActive(true)
		self.selectorUPopupForm:SetActive(false)

		local props = self.model:getPropsByDecomposeSelectedList(self.selectedGensTable)

		self.listSel:SetList(props)

		local result = LuaUIUtils.getDecomposeResultList(self.selectedGensTable, props)

		self.listReward:SetList(result)
		self.btnCheck:TryChangePage("button", 6)
	end

	self:refreshSelectorState(false)
end

function DecomposeComponent:tryAddDecompose(button, propData, navConfirm)
	if not self.model:isInOperationState(self.model.STATE_DECOMPOSE) then
		return
	end

	if self.selectedGensCount >= 100 and not self.selectedGensTable[propData.index] then
		return
	end

	self.curSelectedGenId = propData.index
	self.curPropData = propData

	self:increaseSelected(propData.index)

	if not self.recyclePreview or not self.recyclePreview.gameObject.activeInHierarchy then
		self.selectorUPopupForm:SetActive(true)
		self.selectorUPopupForm:SetModal(false)
		self.selectorUPopupForm:OpenPopup(button)
	end

	if self.listProp.groupType == CS.XGUI.EGroupType.None then
		button.enabledVisualSelect = true
		button.isSelected = true
		self.curSelectedBtn = button
	end
end

function DecomposeComponent:noAddDecompose(propData)
	if not self.model:isInOperationState(self.model.STATE_DECOMPOSE) then
		return
	end

	if self.selectedGensCount >= 100 and not self.selectedGensTable[propData.index] then
		return
	end

	self.curSelectedGenId = propData.index
	self.curPropData = propData

	self:nocreaseSelected(propData.index)
end

function DecomposeComponent:onNavToDisabled()
	if not self.model:isInOperationState(self.model.STATE_DECOMPOSE) then
		return
	end

	self.selectorUPopupForm:SetActive(false)
	self:refreshSelectorState(false)
end

function DecomposeComponent:refreshSelectorByPropData(propData)
	local curCount = self.selectedGensTable[propData.index] or 0

	if curCount == 0 then
		self:refreshSelectorState(false)

		return
	end

	self.curSelectedGenId = propData.index
	self.curPropData = propData

	self:refreshSelectorState(true)
end

function DecomposeComponent:refreshAllIconsAndNums()
	self.ctrl:refreshBtnDecomposeState(self.selectedGensTable)

	if self.curSelectedGenId == nil then
		self.numSelector:SetValueWithoutNotify(0)
	else
		self.numSelector:SetValueWithoutNotify(self.selectedGensTable[self.curSelectedGenId] or 0)
	end

	ClientTextUtils.setText(self.txtLimitNum, tostring(self.selectedGensCount) .. "/100")

	if self.recyclePreview.gameObject.activeInHierarchy == true then
		local props = self.model:getPropsByDecomposeSelectedList(self.selectedGensTable)

		self.listSel:SetList(props)

		local result = LuaUIUtils.getDecomposeResultList(self.selectedGensTable, props)

		self.listReward:SetList(result)
	end

	self:refreshFilterStates()
	self:refreshTabIndicators()
	self:refreshThirdTabIndicators()
	self:refreshCtrlConsoleBar()
end

function DecomposeComponent:buildTabButtonsCache()
	self.tabButtonsCache = {}

	local tabButtons = self.listTab:GetAllButtons()

	if tabButtons == nil or tabButtons.Length == 0 then
		return
	end

	for i = 0, tabButtons.Length - 1 do
		local btn = tabButtons[i]
		local tabData = btn.dataFromUList

		if tabData then
			local objectReference = btn:GetComponent("ObjectReference")
			local imgAddUImage = objectReference:GetRefValue("imgAddUImage")

			if imgAddUImage then
				self.tabButtonsCache[#self.tabButtonsCache + 1] = {
					invId = tabData.invId,
					imgAddUImage = imgAddUImage
				}
			end
		end
	end
end

function DecomposeComponent:refreshTabIndicators()
	if not self.tabButtonsCache then
		return
	end

	for _, entry in ipairs(self.tabButtonsCache) do
		local hasSelected = false
		local bag = ItemUtils.getTypedBag(pg.me, entry.invId)

		if bag then
			for genId, _ in pairs(self.selectedGensTable) do
				if bag[genId] ~= nil then
					hasSelected = true

					break
				end
			end
		end

		entry.imgAddUImage:SetActive(hasSelected)
	end
end

function DecomposeComponent:resetTabIndicators()
	if not self.tabButtonsCache then
		return
	end

	for _, entry in ipairs(self.tabButtonsCache) do
		entry.imgAddUImage:SetActive(false)
	end

	self.tabButtonsCache = nil
end

function DecomposeComponent:buildThirdTabButtonsCache()
	self.thirdTabButtonsCache = nil

	if not self.listTabThird then
		return
	end

	local thirdTabButtons = self.listTabThird:GetAllButtons()

	if thirdTabButtons == nil or thirdTabButtons.Length == 0 then
		return
	end

	self.thirdTabButtonsCache = {}

	for i = 0, thirdTabButtons.Length - 1 do
		local btn = thirdTabButtons[i]
		local tabData = btn.dataFromUList

		if tabData then
			local objectReference = btn:GetComponent("ObjectReference")
			local imgAddUImage = objectReference:GetRefValue("imgAddUImage")

			if imgAddUImage then
				self.thirdTabButtonsCache[#self.thirdTabButtonsCache + 1] = {
					paginationId = tabData.paginationId,
					imgAddUImage = imgAddUImage
				}
			end
		end
	end
end

function DecomposeComponent:refreshThirdTabIndicators()
	if not self.thirdTabButtonsCache then
		self:buildThirdTabButtonsCache()
	end

	if not self.thirdTabButtonsCache then
		return
	end

	local curInvId = self.model:getInventoryInvId()
	local bag = ItemUtils.getTypedBag(pg.me, curInvId)

	for _, entry in ipairs(self.thirdTabButtonsCache) do
		local hasSelected = false

		if bag then
			for genId, _ in pairs(self.selectedGensTable) do
				local packSlot = bag[genId]

				if packSlot then
					if entry.paginationId == -1 then
						hasSelected = true

						break
					else
						local configData = ItemData[packSlot.id]

						if configData and configData.paginationId == entry.paginationId then
							hasSelected = true

							break
						end
					end
				end
			end
		end

		entry.imgAddUImage:SetActive(hasSelected)
	end
end

function DecomposeComponent:resetThirdTabIndicators()
	if not self.thirdTabButtonsCache then
		return
	end

	for _, entry in ipairs(self.thirdTabButtonsCache) do
		entry.imgAddUImage:SetActive(false)
	end

	self.thirdTabButtonsCache = nil
end

function DecomposeComponent:setResolveResultListItem(button, index, data)
	local objectReference = button.gameObject.transform:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("itemIconUImage")
	local txtNumUText = objectReference:GetRefValue("txtNumUText")
	local item = LuaUIUtils.getItemClientInfoById(data.itemId)

	iconUImage.url = item.icon

	ClientTextUtils.setText(txtNumUText, data.itemNum)
	button:TryChangePage("Quality", data.quality)

	function button.luaClick()
		if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
			pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
		else
			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
				id = data.itemId,
				num = data.itemNum,
				targetRect = button
			})
		end
	end
end

function DecomposeComponent:onTabSelectChanged(isThird)
	if not self.model:isInOperationState(self.model.STATE_DECOMPOSE) then
		return
	end

	if not self.container:CheckURLLoaded() then
		return
	end

	self.decomposableItemsCache = nil

	if not isThird then
		self.thirdTabButtonsCache = nil
	end

	self:refreshAllIconsAndNums()

	local buttons = self.listProp:GetAllButtons()

	if buttons.Length > 0 then
		local propData = buttons[0].dataFromUList

		self:refreshSelectorByPropData(propData)
	else
		self.curSelectedGenId = nil
		self.curPropData = nil

		self:refreshSelectorState(false)
	end
end

function DecomposeComponent:onRenderFilterItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

	ClientTextUtils.setText(txtNameUBaseText, pg.getLocalizationText(data.name))
	button:TryChangePage("Stage", 0)
	self:buildDecomposableItemsCache()

	local items = self.decomposableItemsCache[data.quality]
	local hasItems = items ~= nil and #items > 0

	data.disabled = not hasItems
	button.interactable = hasItems

	if hasItems then
		button:TryChangePage("Quality", index)
	else
		button:TryChangePage("Quality", 6)
	end
end

function DecomposeComponent:refreshFilterList()
	local dataList = {}

	for i = 1, #ItemQuality do
		dataList[i] = {
			name = ItemQuality[i].name,
			quality = i
		}
	end

	self.listFilterUList:SetList(dataList)
end

function DecomposeComponent:buildDecomposableItemsCache()
	if self.decomposableItemsCache then
		return
	end

	local cache = {}
	local itemDataList = self.listProp.itemData

	if itemDataList then
		local count = itemDataList.Count

		for i = 0, count - 1 do
			local propData = itemDataList[i]
			local itemId = propData.itemId
			local configData = ItemData[itemId]

			if configData and configData.resolveGetItem ~= nil then
				local quality = configData.quality

				if quality >= 1 and quality <= 6 then
					local packSlot = propData.packSlot

					if packSlot then
						local isLock = packSlot:hasStatus(ItemConst.ITEM_STATUS_LOCKED)
						local isBind = LuaUIUtils.tableContains(pg.me.invQuickSlotItem, packSlot.id) or LuaUIUtils.tableContains(pg.me.invQuickSlotBall, packSlot.id) or LuaUIUtils.tableContains(pg.me.invEliteSlotBall, packSlot.id)

						if not isLock and not isBind then
							if not cache[quality] then
								cache[quality] = {}
							end

							local list = cache[quality]

							list[#list + 1] = {
								genId = packSlot.genID,
								count = packSlot.count,
								itemId = itemId
							}
						end
					end
				end
			end
		end
	end

	self.decomposableItemsCache = cache
end

function DecomposeComponent:getAllDecomposableItemsByQuality(quality)
	self:buildDecomposableItemsCache()

	return self.decomposableItemsCache[quality] or {}
end

function DecomposeComponent:onFilterItemClicked(data)
	if not self.model:isInOperationState(self.model.STATE_DECOMPOSE) then
		return
	end

	local quality = data.quality
	local items = self:getAllDecomposableItemsByQuality(quality)

	if #items == 0 then
		return
	end

	local hasAnySelected = false

	for _, item in ipairs(items) do
		if self.selectedGensTable[item.genId] then
			hasAnySelected = true

			break
		end
	end

	if hasAnySelected then
		for _, item in ipairs(items) do
			self:setSelectedCount(item.genId, nil)
		end
	else
		for _, item in ipairs(items) do
			if self.selectedGensCount < 100 then
				self:setSelectedCount(item.genId, item.count)
			end
		end
	end

	self.curSelectedGenId = nil
	self.curPropData = nil

	self:refreshSelectorState(false)
	self:refreshAllIconsAndNums()
end

function DecomposeComponent:refreshFilterStates()
	if not self.container:CheckURLLoaded() then
		return
	end

	local buttons = self.listFilterUList:GetAllButtons()

	if buttons == nil or buttons.Length == 0 then
		return
	end

	self:buildDecomposableItemsCache()

	self.isRefreshingFilterStates = true

	local cache = self.decomposableItemsCache

	for i = 0, buttons.Length - 1 do
		local btn = buttons[i]
		local data = btn.dataFromUList

		if data then
			local items = cache[data.quality]
			local hasItems = items and #items > 0

			data.disabled = not hasItems
			btn.interactable = hasItems and true or false

			if not hasItems then
				btn.isSelected = false

				btn:TryChangePage("Stage", 0)
				btn:TryChangePage("Quality", 6)
			else
				local selectedCount = 0
				local fullCount = 0

				for _, item in ipairs(items) do
					local sel = self.selectedGensTable[item.genId]

					if sel and sel > 0 then
						selectedCount = selectedCount + 1

						if sel >= item.count then
							fullCount = fullCount + 1
						end
					end
				end

				if selectedCount == 0 then
					btn.isSelected = false

					btn:TryChangePage("Stage", 0)
				elseif fullCount == #items then
					btn.isSelected = true

					btn:TryChangePage("Stage", 0)
				else
					btn.isSelected = true

					btn:TryChangePage("Stage", 1)
				end

				btn:TryChangePage("Quality", i)
			end
		end
	end

	self.isRefreshingFilterStates = false
end

function DecomposeComponent:resetFilterStates()
	if not self.container:CheckURLLoaded() then
		return
	end

	local buttons = self.listFilterUList:GetAllButtons()

	if buttons == nil then
		return
	end

	self.isRefreshingFilterStates = true

	for i = 0, buttons.Length - 1 do
		buttons[i].isSelected = false
	end

	self.isRefreshingFilterStates = false
end

function DecomposeComponent:clearCache()
	self.decomposableItemsCache = nil
end

return DecomposeComponent
