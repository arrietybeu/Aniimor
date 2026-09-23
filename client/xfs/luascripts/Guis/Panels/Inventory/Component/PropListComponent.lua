-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Inventory\\Component\\PropListComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local ItemConst = require("Common.Const.ItemConst")
local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local PropListComponent = Class.LightClass("PropListComponent", UIComponent)
local ItemData = require("Data.item_data")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local CatchRoguePhaseData = require("Data.catch_rogue_phase_data")
local Utils = require("Common.Utils.Utils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local ItemTTLUtils = require("Common.Utils.ItemTTLUtils")
local TradeUtils = require("Common.Utils.TradeUtils")
local ItemUtils = require("Common.Utils.ItemUtils")

function PropListComponent:onCtor(info)
	UIComponent.onCtor(self, info)

	self.thirdTabSelectIdx = 0
end

function PropListComponent:findObjects()
	return
end

function PropListComponent:initView()
	function self.view.listProp.luaRenderItem(button, index, data)
		self:onRenderPropItem(button, index, data)
	end

	function self.view.listProp.luaSelectedChanged(uList)
		self:onPropSelected(uList)
	end

	function self.view.listProp.luaCheckCanSelected(data)
		return data.tIndex == 0
	end

	function self.view.listProp.luaFinishLayout()
		self:refreshBallTabWidth()
	end

	function self.view.listTabThird.luaRenderItem(button, index, data)
		self:onRenderThirdTabItem(button, index, data)
	end

	function self.view.listTabThird.luaSelectedChanged(uList)
		self:onThirdTabSelected(uList)
	end

	function self.view.sortSelector.luaSelectedChanged(selector)
		if self.isRefreshingSortSelector then
			return
		end

		self.model:setSortIdxType(selector.selectedIndex)
		self:refreshPropList()
	end

	local groupInfos = self.model:getSortOptions()

	self.isRefreshingSortSelector = true

	self.view.sortSelector:SetOptions(groupInfos)

	self.isRefreshingSortSelector = false

	function self.view.btnSort.luaClick()
		self.model:setSortAscendingOrder(not self.model.sortIsAscending)
		self.view.btnSort:TryChangePage("Sort", self.model.sortIsAscending and 0 or 1)
		self:refreshPropList()
	end
end

function PropListComponent:onShow()
	self.view.btnSort:TryChangePage("Sort", self.model.sortIsAscending and 0 or 1)

	self.isRefreshingSortSelector = true
	self.view.sortSelector.selectedIndex = self.model:getSortIdxType()
	self.isRefreshingSortSelector = false

	if Utils.isPlayerInSpaceCatchRogueDungeon(pg.me) then
		self.view.btnSort:SetActiveQuickly(false)
		self.view.sortSelector:SetActiveQuickly(false)
	else
		self.view.btnSort:SetActiveQuickly(true)
		self.view.sortSelector:SetActiveQuickly(true)
	end

	self:scheduleTTLRefresh()
end

function PropListComponent:onHide()
	UIComponent.onHide(self)

	if self.ttlRefreshTimer then
		TimerManager.removeTimer(self.ttlRefreshTimer)

		self.ttlRefreshTimer = nil
	end
end

function PropListComponent:scheduleTTLRefresh()
	if self.ttlRefreshTimer then
		TimerManager.removeTimer(self.ttlRefreshTimer)

		self.ttlRefreshTimer = nil
	end

	local now = tonumber(Time.secondCache) or 0
	local nextChangeTime
	local hasTTLItem = false

	for _, data in pairs(self.view.listProp.itemData or EMPTY_TABLE) do
		local item = data.packSlot

		if item then
			local state = ItemTTLUtils.getState(item, now)
			local changeTime = state == ItemTTLUtils.STATE_NOT_STARTED and item.vaildStartTime or state == ItemTTLUtils.STATE_ACTIVE and item.vaildEndTime or nil

			hasTTLItem = hasTTLItem or changeTime ~= nil

			if changeTime and now < changeTime and (not nextChangeTime or changeTime < nextChangeTime) then
				nextChangeTime = changeTime
			end
		end
	end

	if hasTTLItem then
		nextChangeTime = math.min(nextChangeTime or now + 60, now + 60)
	end

	if nextChangeTime then
		self.ttlRefreshTimer = TimerManager.addTimer(nextChangeTime - now + 0.1, function()
			self.ttlRefreshTimer = nil

			self:refreshPropList(false)
		end)
	end
end

function PropListComponent:deselectAll()
	self.view.listProp:DeselectAll()
end

function PropListComponent:getFocusedListItemId()
	if not pg.game.input:isUsingGamepad() then
		return nil
	end

	local navMgr = CS.XGUI.Navigation.NavManager.Instance

	if not navMgr then
		return nil
	end

	local content = navMgr.CurrentFocusedUContent

	if IsNil(content) then
		return nil
	end

	local idx = self.view.listProp:GetChildIndex(content)

	if not idx or idx < 0 then
		return nil
	end

	local data = self.view.listProp.itemData and self.view.listProp.itemData[idx]

	return data and data.itemId or nil
end

function PropListComponent:tryRestoreFocusToItem(itemId)
	if not itemId or itemId <= 0 then
		return
	end

	if not pg.game.input:isUsingGamepad() then
		return
	end

	if self.pendingFocusItemId then
		return
	end

	self.pendingFocusItemId = itemId

	TimerManager.addNextFrameCb(function()
		local targetItemId = self.pendingFocusItemId

		self.pendingFocusItemId = nil

		if not self.view then
			return
		end

		local navMgr = CS.XGUI.Navigation.NavManager.Instance

		if not navMgr then
			return
		end

		local btns = self.view.listProp:GetAllButtons()

		if not btns then
			return
		end

		for i = 0, btns.Length - 1 do
			local data = btns[i].dataFromUList

			if data and data.itemId == targetItemId then
				navMgr:FocusItem(btns[i])

				return
			end
		end
	end)
end

function PropListComponent:onTabSelectChanged(restoreLastSelection)
	if not restoreLastSelection then
		self.thirdTabSelectIdx = 0
	end

	self:refreshPropList(not restoreLastSelection, restoreLastSelection)
end

function PropListComponent:refreshPropList(resetSelect, restoreLastSelection)
	if resetSelect == nil then
		resetSelect = true
	end

	local thirdTabList = self.model:getThirdTabList()
	local haveThirdList = thirdTabList and next(thirdTabList) and true or false

	self.view.rootComponent:TryChangePage("HaveTab", haveThirdList and 1 or 0)

	if haveThirdList then
		if restoreLastSelection and self.ctrl.oldThirdPageId then
			for i, data in ipairs(thirdTabList) do
				if data.paginationId == self.ctrl.oldThirdPageId then
					self.thirdTabSelectIdx = i - 1

					break
				end
			end
		end

		for i = 1, #thirdTabList do
			local data = thirdTabList[i]

			data.selected = false

			if i == 1 then
				data.tIndex = 0
			elseif i == #thirdTabList then
				data.tIndex = 2
			else
				data.tIndex = 1
			end
		end

		self.view.listTabThird:SetList(thirdTabList)
		self.view.listTabThird:SelectItem(self.thirdTabSelectIdx, false)

		self.thirdTabSelectIdx = self.view.listTabThird.selectedIndex or 0

		local sData = self.view.listTabThird.selectedItem

		if sData == nil then
			return
		end

		self.ctrl.oldThirdPageId = sData.paginationId

		self:setPropList(resetSelect, sData.paginationId)
		self.ctrl:onThirdTabSelectedChange()
	else
		self.ctrl.oldThirdPageId = nil

		self:setPropList(resetSelect)
	end
end

function PropListComponent:refreshBallTabWidth()
	if self.model:getInventoryInvId() ~= ItemConst.INV_TYPE_BALL then
		self.ballTabWidth = nil

		return
	end

	local listProp = self.view.listProp
	local paddings = listProp:GetPaddings()
	local availableWidth = listProp.rectTransform.rect.width - paddings[2] - paddings[3]

	if availableWidth <= 0 or self.ballTabWidth == availableWidth then
		return
	end

	self.ballTabWidth = availableWidth

	listProp:SetTemplateWidth(1, availableWidth)
	listProp:SetTemplateWidth(2, availableWidth)
end

function PropListComponent:appendBallCategory(displayList, ballList, name, state)
	if #ballList <= 0 then
		return
	end

	displayList[#displayList + 1] = {
		disabled = true,
		tIndex = state == 0 and 1 or 2,
		name = name,
		state = state
	}

	for _, data in ipairs(ballList) do
		displayList[#displayList + 1] = data
	end
end

function PropListComponent:buildPropDisplayList(propData)
	if self.model:getInventoryInvId() ~= ItemConst.INV_TYPE_BALL then
		self.ballTabWidth = nil

		return propData
	end

	local normalBallList = {}
	local specialBallList = {}

	for _, data in ipairs(propData) do
		data.tIndex = 0

		local slotType = data.catchBallSlotType or ItemUtils.getBallQuickSlotType(data.itemId)

		data.catchBallSlotType = slotType

		if slotType == ItemConst.QUICK_SLOT_ELITE_BALL then
			specialBallList[#specialBallList + 1] = data
		else
			normalBallList[#normalBallList + 1] = data
		end
	end

	local displayList = {}

	self:appendBallCategory(displayList, normalBallList, "INVENTORY_CATCHBALL_NORMAL_TAB", 0)
	self:appendBallCategory(displayList, specialBallList, "INVENTORY_CATCHBALL_SPECIAL_TAB", 1)

	return displayList
end

function PropListComponent:isSameBallDisplayItem(oldData, newData)
	if oldData.tIndex ~= newData.tIndex then
		return false
	end

	if newData.tIndex ~= 0 then
		return oldData.name == newData.name and oldData.state == newData.state
	end

	return oldData.genID == newData.genID and oldData.itemId == newData.itemId and oldData.bindCatchBallSlot == newData.bindCatchBallSlot and oldData.isCaptureBind == newData.isCaptureBind
end

function PropListComponent:refreshChangedBallItems()
	if self.model:getInventoryInvId() ~= ItemConst.INV_TYPE_BALL then
		return false
	end

	local displayData = self:buildPropDisplayList(self.model:getPropsByInv())
	local listProp = self.view.listProp
	local oldData = listProp.itemData

	if oldData == nil or oldData.Count ~= #displayData then
		return false
	end

	local selectedData = self.model:getSelectPropData()
	local selectedGenId = selectedData and selectedData.genID
	local selectedItemId = selectedData and selectedData.itemId
	local selectedIndex

	for i, newData in ipairs(displayData) do
		local index = i - 1

		if not self:isSameBallDisplayItem(oldData[index], newData) then
			listProp:SetElement(index, newData)
		end

		if newData.tIndex == 0 and (selectedGenId and newData.genID == selectedGenId or not selectedGenId and selectedItemId and newData.itemId == selectedItemId) then
			selectedIndex = index
		end
	end

	if selectedIndex ~= nil then
		local newSelectedData = displayData[selectedIndex + 1]

		if listProp.selectedIndex ~= selectedIndex then
			listProp:SelectItem(selectedIndex)
		else
			self.ctrl:showPropDetails(newSelectedData)
		end
	end

	return true
end

function PropListComponent:setPropList(resetSelect, thirdPageId)
	local propData = self.model:getPropsByInv(thirdPageId)

	self:refreshBallTabWidth()

	local displayData = self:buildPropDisplayList(propData)

	self.view.listProp:SetList(displayData)
	self:scheduleTTLRefresh()

	local isEmpty = #propData <= 0

	self.view.rootComponent:TryChangePage("isEmpty", isEmpty and 1 or 0)

	if isEmpty then
		self.ctrl.propDetail:hide()
	else
		local selectSlot
		local lastSelectData = self.model:getSelectPropData()
		local lastSelectGenId = lastSelectData and lastSelectData.genID or 0
		local lastSelectId = lastSelectData and lastSelectData.itemId or 0

		if not resetSelect then
			if lastSelectGenId ~= 0 then
				for i = 1, #displayData do
					local data = displayData[i]

					if data.genID == lastSelectGenId then
						selectSlot = i - 1

						break
					end
				end
			end

			if selectSlot == nil and lastSelectId ~= 0 then
				for i = 1, #displayData do
					local data = displayData[i]

					if data.itemId == lastSelectId then
						selectSlot = i - 1

						break
					end
				end
			end
		end

		if selectSlot == nil then
			for i = 1, #displayData do
				if displayData[i].tIndex == 0 then
					selectSlot = i - 1

					break
				end
			end
		end

		if selectSlot == nil then
			return
		end

		self.view.listProp:SelectItem(selectSlot, false)

		local selectedData = displayData[selectSlot + 1]

		if selectedData then
			self.ctrl:showPropDetails(selectedData)
		end
	end
end

function PropListComponent:showBallDragTip(show)
	if NotNil(self.view.ballDragUWidget) then
		if show then
			ClientTextUtils.setText(self.view.textDragUBaseText, pg.getGameString("INVENTORY_CATCHBALL_ADJUSTING"))
		end

		self.view.ballDragUWidget:SetActive(show)
	end

	if NotNil(self.view.btnUse1) then
		if show then
			self.view.btnUse1:SetActive(false)
		elseif self.curDragBallData then
			self.ctrl:showPropDetails(self.curDragBallData)
		end
	end
end

function PropListComponent:isBallSwapTarget(dragData, dropData)
	if not dragData or not dropData then
		return false
	end

	local fromSlot = dragData.bindCatchBallSlot
	local toSlot = dropData.bindCatchBallSlot

	if not fromSlot or fromSlot <= 0 or not toSlot or toSlot <= 0 then
		return false
	end

	local fromSlotType = dragData.catchBallSlotType or ItemUtils.getBallQuickSlotType(dragData.itemId)
	local toSlotType = dropData.catchBallSlotType or ItemUtils.getBallQuickSlotType(dropData.itemId)

	if fromSlotType ~= toSlotType then
		return false
	end

	return fromSlot ~= toSlot
end

function PropListComponent:refreshCatchBallOrder(container, bindSlot)
	if IsNil(container) then
		return
	end

	if not bindSlot or not (bindSlot > 0) then
		return
	end

	if container:CheckURLLoaded() then
		local objectReference = container.content:GetComponent("ObjectReference")
		local txtNumUBaseText = objectReference:GetRefValue("txtNumUBaseText")

		ClientTextUtils.setText(txtNumUBaseText, bindSlot)
	else
		container:LoadDefaultUrlManually(function()
			local objectReference = container.content:GetComponent("ObjectReference")
			local txtNumUBaseText = objectReference:GetRefValue("txtNumUBaseText")

			ClientTextUtils.setText(txtNumUBaseText, bindSlot)
		end)
	end
end

function PropListComponent:onRenderPropItem(button, index, data)
	button.visibility = CS.XGUI.EVisibility.Visible

	if data.tIndex ~= 0 then
		if self.ballTabWidth then
			button:SetSizeX(self.ballTabWidth)
		end

		button:TryChangePage("State", data.state)

		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

		ClientTextUtils.setText(txtNameUBaseText, pg.getGameString(data.name))

		return
	end

	LuaUIUtils.setPropCard(button, index, data, UIConst.INVENTORY_CARD.CARD_IDX)

	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")
	local uIComPropCardAnimation = objectReference:GetRefValue("uIComPropCardAnimation")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local catchBallUContainer = objectReference:GetRefValue("catchBallUContainer")
	local stateLockUWidget = objectReference:GetRefValue("stateLockUWidget")
	local disabledUImage = objectReference:GetRefValue("disabledUImage")
	local viewableWidget = objectReference:GetRefValue("viewableWidget")
	local exclusiveUContainer = objectReference:GetRefValue("exclusiveUContainer")
	local noneUWidget = objectReference:GetRefValue("noneUWidget")
	local txtNoneName = objectReference:GetRefValue("txtNoneName")
	local timeCountDownTransform = button.transform:Find("PanelCardRoot/PanelCard/Addon/TimeCountDown")
	local timeCountDownUContainer = NotNil(timeCountDownTransform) and timeCountDownTransform:GetComponent("UContainer")
	local ttlState = ItemTTLUtils.getState(data.packSlot, Time.secondCache)
	local ttlUnavailable = ttlState == ItemTTLUtils.STATE_NOT_STARTED or ttlState == ItemTTLUtils.STATE_EXPIRED
	local isCatchBallState = self.model:isInOperationState(self.model.STATE_CATCHBALL)
	local isLock = data.packSlot:hasStatus(ItemConst.ITEM_STATUS_LOCKED)
	local isEquipped = data.bindCatchBallSlot and data.bindCatchBallSlot > 0
	local canDrag = false
	local canDrop = false

	if data.invIdx == ItemConst.INV_TYPE_BALL then
		local inRogue = Utils.isPlayerInSpaceCatchRogueDungeon(pg.me)

		canDrag = isEquipped and not isLock and not inRogue
		canDrop = isEquipped and not inRogue
	end

	button.draggable = canDrag
	button.dropable = canDrop
	button.enabledLongPress = false

	if canDrag then
		button.enableDragOffset = false
		button.dragMode = 0
		button.dragStartPos = 1
		button.longPressAdsorb = false
		button.longPressDelay = 0
		button.longPressLoadingEnabled = false
	end

	LuaUIUtils.refreshCarryAssistInfo_Item(objectReference, data, false)

	if data.type ~= ItemConst.ITEM_TYPE_CARRY_CORE and data.type ~= ItemConst.ITEM_TYPE_CARRY_ASSISTED then
		local count = Utils.isPlayerInSpaceCatchRogueDungeon(pg.me) and data.count or data.packSlot.count

		ClientTextUtils.setText(txtNameUText, LuaUIUtils.formatStyledItemNum(count))
	end

	self:refreshCatchBallOrder(catchBallUContainer, data.bindCatchBallSlot)

	if exclusiveUContainer then
		if Utils.isPlayerInSpaceCatchRogueDungeon(pg.me) then
			local curGameId = pg.me:getCatchRogueCurGameId()
			local gameBallItemIds = curGameId and CatchRoguePhaseData[curGameId].gameBallType

			if gameBallItemIds and table.contains(gameBallItemIds, data.itemId) then
				exclusiveUContainer:SetActive(true)
				exclusiveUContainer:LoadDefaultUrlManually()
			else
				exclusiveUContainer:SetActive(false)
			end
		else
			exclusiveUContainer:SetActive(false)
		end
	end

	if NotNil(noneUWidget) then
		noneUWidget:SetActive(ttlUnavailable)
	end

	if ttlUnavailable and NotNil(txtNoneName) then
		ClientTextUtils.setText(txtNoneName, pg.getGameString(ttlState == ItemTTLUtils.STATE_NOT_STARTED and "NOT_AVAILABLE" or "EXPIRED"))
	end

	if NotNil(timeCountDownUContainer) then
		local showTTL = ttlState == ItemTTLUtils.STATE_ACTIVE

		timeCountDownUContainer.gameObject:SetActiveEx(showTTL)

		if showTTL then
			local function refreshCountDown()
				local contentTransform = timeCountDownUContainer.content.transform
				local txtNameTransform = contentTransform:Find("CountDown/TxtName")
				local txtName = txtNameTransform:GetComponent("USDFText")
				local countDownText = LuaUIUtils.formatItemTTLRemaining(data.packSlot, Time.secondCache)

				ClientTextUtils.setText(txtName, countDownText)
			end

			if timeCountDownUContainer:CheckURLLoaded() then
				refreshCountDown()
			else
				timeCountDownUContainer:LoadDefaultUrlManually(function()
					refreshCountDown()
				end)
			end
		end
	end

	stateLockUWidget.gameObject:SetActiveEx(isLock)

	local isViewable = data.packSlot.sType == ItemConst.USEITEM_TYPE_VIEWABLE

	viewableWidget.gameObject:SetActiveEx(isViewable)

	if self.model:isInOperationState(self.model.STATE_DECOMPOSE) then
		local itemId = tonumber(button.gameObject.name)
		local isEquipped = data.bindCatchBallSlot and data.bindCatchBallSlot > 0

		if isLock or ttlUnavailable or itemId ~= nil and ItemData[itemId].resolveGetItem == nil or isEquipped then
			button.interactable = false

			disabledUImage.gameObject:SetActiveEx(true)
		else
			button.interactable = true

			disabledUImage.gameObject:SetActiveEx(false)
		end
	elseif isCatchBallState then
		button.interactable = true

		disabledUImage.gameObject:SetActiveEx(isLock)
	else
		button.interactable = true

		disabledUImage.gameObject:SetActiveEx(false)
	end

	function button.luaBeginDrag()
		self.view.listProp:SelectItem(index)

		self.curDragBallData = data
		self.curDragHoverBtn = nil

		self:showBallDragTip(true)
		button:TryChangePage("DragState", 2)

		local draggingWidget = CS.XGUI.UComponent.draggingWidget

		if IsNil(draggingWidget) then
			return
		end

		draggingWidget:TryChangePage("DragState", 1)
	end

	function button.luaEndDrag(dropWidget)
		button:TryChangePage("DragState", 0)

		if NotNil(self.curDragHoverBtn) and self.curDragHoverBtn ~= button then
			self.curDragHoverBtn:TryChangePage("DragState", 0)
		end

		self.curDragHoverBtn = nil

		self:showBallDragTip(false)

		local dragData = self.curDragBallData

		self.curDragBallData = nil

		if IsNil(dropWidget) then
			return
		end

		dropWidget:TryChangePage("DragState", 0)

		local dropData = dropWidget.dataFromUList

		if self:isBallSwapTarget(dragData, dropData) then
			local slotType = dragData.catchBallSlotType or ItemUtils.getBallQuickSlotType(dragData.itemId)

			self.model:tryModifyGroup(dragData.bindCatchBallSlot, dropData.bindCatchBallSlot, slotType)
		end
	end

	function button.luaHover()
		if not button.isAnyInstanceInDragging then
			return
		end

		if not self:isBallSwapTarget(self.curDragBallData, data) then
			return
		end

		self.curDragHoverBtn = button

		button:TryChangePage("DragState", 4)

		local draggingWidget = CS.XGUI.UComponent.draggingWidget

		if not IsNil(draggingWidget) then
			draggingWidget:TryChangePage("DragState", 3)
		end
	end

	function button.luaUnhover()
		if not button.isAnyInstanceInDragging then
			return
		end

		local dragData = self.curDragBallData
		local dragSlotType = dragData and (dragData.catchBallSlotType or ItemUtils.getBallQuickSlotType(dragData.itemId))
		local slotType = data.catchBallSlotType or ItemUtils.getBallQuickSlotType(data.itemId)
		local isSelf = dragData and slotType == dragSlotType and data.bindCatchBallSlot == dragData.bindCatchBallSlot

		if self.curDragHoverBtn == button then
			self.curDragHoverBtn = nil
		end

		button:TryChangePage("DragState", isSelf and 2 or 0)

		local draggingWidget = CS.XGUI.UComponent.draggingWidget

		if not IsNil(draggingWidget) then
			draggingWidget:TryChangePage("DragState", 1)
		end
	end

	function button.luaClick(navConfirm)
		self.ctrl:showPropDetails(data)
		self.ctrl:tryAddDecompose(button, data, navConfirm)

		if data.invIdx == ItemConst.INV_TYPE_BALL then
			self.ctrl:refreshCatchBallBtnState()
		end
	end

	button.navForceInteractable = true

	function button.luaNavFocused()
		if self.model:isInOperationState(self.model.STATE_DECOMPOSE) and not button.interactable then
			self.ctrl:onDecomposeNavToDisabled()
		end
	end

	local cashShopTradableUContainer = objectReference:GetRefValue("cashShopTradableUContainer")

	if NotNil(cashShopTradableUContainer) then
		local isTradable = TradeUtils.isItemCanTrade(data.packSlot) == true

		cashShopTradableUContainer:SetActive(isTradable)

		if isTradable and not cashShopTradableUContainer:CheckURLLoaded() then
			cashShopTradableUContainer:LoadDefaultUrlManually()
		end
	end
end

function PropListComponent:onPropSelected(uList)
	local sData = uList.selectedItem

	if sData == nil or sData.tIndex ~= 0 then
		return
	end

	self.ctrl:showPropDetails(sData)
end

function PropListComponent:refreshPropStatusByGenId(genId)
	local allData = self.view.listProp.itemData

	for idx, data in pairs(allData) do
		if data.index == genId then
			self.view.listProp:RefreshElement(idx)

			break
		end
	end
end

function PropListComponent:refreshGenCount(genId)
	local allData = self.view.listProp.itemData
	local targetIdx, sData

	for idx, data in pairs(allData) do
		if data.packSlot and data.packSlot.genID == genId then
			targetIdx = idx
			sData = data

			break
		end
	end

	if targetIdx then
		self.view.listProp:RefreshElement(targetIdx)

		local selectedData = self.model:getSelectPropData()

		if selectedData and selectedData.index == genId then
			self.ctrl:showPropDetails(sData)
		end
	end
end

function PropListComponent:getButtonByIndex(index)
	local _, button = self.view.listProp:TryGetChildAt(index)

	return button
end

function PropListComponent:onRenderThirdTabItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

	ClientTextUtils.setText(txtNameUBaseText, ClientTextUtils.getLocalizationText(data.nameHashId))
end

function PropListComponent:onThirdTabSelected(uList)
	local sData = uList.selectedItem

	if sData == nil then
		return
	end

	self.thirdTabSelectIdx = self.view.listTabThird.selectedIndex or 0

	local paginationId = sData.paginationId

	self.ctrl.oldThirdPageId = paginationId

	self:setPropList(true, paginationId)
	self.ctrl:onThirdTabSelectedChange()
end

function PropListComponent:switchThirdTab(direction)
	local thirdTabList = self.model:getThirdTabList()

	if not thirdTabList or not next(thirdTabList) then
		return
	end

	local currentIdx = self.view.listTabThird.selectedIndex or 0
	local newIdx = currentIdx + direction
	local maxIdx = #thirdTabList - 1

	if newIdx < 0 then
		newIdx = maxIdx
	elseif maxIdx < newIdx then
		newIdx = 0
	end

	self.view.listTabThird:SelectItem(newIdx)
end

function PropListComponent:switchListBtnState(flag)
	local inRogue = Utils.isPlayerInSpaceCatchRogueDungeon(pg.me)
	local btns = self.view.listProp:GetAllButtons()

	for i = 0, btns.Length - 1 do
		local data = btns[i].dataFromUList

		if data and data.tIndex ~= 0 then
			btns[i].interactable = false
		else
			local objectReference = btns[i]:GetComponent("ObjectReference")
			local stateLockUWidget = objectReference:GetRefValue("stateLockUWidget")
			local disabledUImage = objectReference:GetRefValue("disabledUImage")
			local isEquipped = data.bindCatchBallSlot and data.bindCatchBallSlot > 0

			if flag then
				local itemId = tonumber(btns[i].gameObject.name)

				if stateLockUWidget.gameObject.activeInHierarchy == true or itemId ~= nil and ItemData[itemId].resolveGetItem == nil or isEquipped then
					btns[i].interactable = false

					disabledUImage.gameObject:SetActiveEx(true)
				else
					btns[i].interactable = true

					disabledUImage.gameObject:SetActiveEx(false)
				end

				btns[i].draggable = false
				btns[i].dropable = false
			else
				btns[i].interactable = true

				disabledUImage.gameObject:SetActiveEx(false)

				local isBallEquipped = data.invIdx == ItemConst.INV_TYPE_BALL and isEquipped and not inRogue

				btns[i].draggable = isBallEquipped and not stateLockUWidget.gameObject.activeInHierarchy
				btns[i].dropable = isBallEquipped
			end
		end
	end
end

return PropListComponent
