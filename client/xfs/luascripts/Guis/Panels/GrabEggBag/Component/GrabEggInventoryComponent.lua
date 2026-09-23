-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggBag\\Component\\GrabEggInventoryComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("GrabEggInventoryComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local GrabEggInventoryComponent = Class.LightClass("GrabEggInventoryComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local ItemConst = require("Common.Const.ItemConst")
local MessageName = require("Const.MessageName")
local ItemUtils = require("Common.Utils.ItemUtils")
local UIConst = require("Const.UIConst")
local HotkeyConst = require("Const.HotkeyConst")
local NoticeDef = require("Common.NoticeDef")
local ItemData = require("Data.item_data")
local DecomposeComponent = require("Guis.Panels.Inventory.Component.DecomposeComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")

GrabEggInventoryComponent.messages = {
	[MessageName.GRAB_EGG_EQUIP_PROP] = {
		"event_onEquipPropChanged",
		true
	}
}

local function checkCanBringItem(data)
	if ItemUtils.isForbidRobEgg(data.itemId) then
		pg.global.showBubbleMessage(NoticeDef.ROB_EGG_BRING_FORBID_ITEM)

		return false
	end

	return true
end

function GrabEggInventoryComponent:findObjects()
	self.container = self.view.inventoryContainer
end

function GrabEggInventoryComponent:findContainerObjects()
	local objectReference = self.container.content.transform:GetComponent("ObjectReference")

	self.listTabMain = objectReference:GetRefValue("listTabMain")
	self.listTabThird = objectReference:GetRefValue("listTabThird")
	self.sortSelector = objectReference:GetRefValue("sortSelector")
	self.btnRecycle = objectReference:GetRefValue("btnRecycle")
	self.btnSort = objectReference:GetRefValue("btnSort")
	self.listProp = objectReference:GetRefValue("listProp")
	self.dragCoverUButton = objectReference:GetRefValue("dragCoverUButton")
	self.btnAllPutUButton = objectReference:GetRefValue("btnAllPutUButton")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")

	function self.listTabMain.luaRenderItem(button, index, data)
		self:onRenderMainTabItem(button, index, data)
	end

	function self.listTabMain.luaSelectedChanged(uList)
		self:onMainTabSelected(uList)
	end

	function self.listTabThird.luaRenderItem(button, index, data)
		self:onRenderThirdTabItem(button, index, data)
	end

	function self.listTabThird.luaSelectedChanged(uList)
		self:onThirdTabSelected(uList)
	end

	function self.listProp.luaRenderItem(button, index, data)
		self:onRenderPropItem(button, index, data)
	end

	function self.listProp.luaVirtualListRefreshCb()
		self.ctrl:refreshHoverDataFromPointer(self.listProp)
	end

	function self.sortSelector.luaSelectedChanged(selector)
		self.model:setSortIdxType(selector.selectedIndex)
		self:refreshPropList()
	end

	local groupInfos = self.model:getSortOptions()

	self.sortSelector:SetOptions(groupInfos)

	function self.btnSort.luaClick()
		self.model:setSortAscendingOrder(not self.model.sortIsAscending)
		self:refreshPropList()
	end

	function self.btnRecycle.luaClick()
		self.decomposeComp:onEnterDecomposeSate()
	end

	self:initDragArea()

	self.decomposeComp = DecomposeComponent.new(self, self.view.recyclePanelContainer, {
		isRobEggMode = true
	})

	function self.btnAllPutUButton.luaClick()
		self:onClickTransfer()
	end

	function self.btnBackUButton.luaClick()
		self:onClickReturnRoom()
	end
end

function GrabEggInventoryComponent:onDestroy()
	UIComponent.onDestroy(self)
end

function GrabEggInventoryComponent:initView()
	self.mainTabSelectIdx = 0
	self.thirdTabSelectIdx = 0
	self.isContainerLoading = false
end

function GrabEggInventoryComponent:initContainer(callback)
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
		self.container:SetActive(true)

		if callback then
			callback()
		end
	end)
end

function GrabEggInventoryComponent:showInventory(settlement)
	self.settlement = settlement

	self:initContainer(function()
		self:refreshMainTabList()

		local allData = self.listTabMain.itemData

		for index, data in pairs(allData) do
			if data.invId == ItemConst.INV_TYPE_ROB_EGG_WAREHOUSE then
				self.mainTabSelectIdx = index

				break
			end
		end

		self.listTabMain:SelectItem(self.mainTabSelectIdx)
		self.listTabMain:SetActive(false)

		self.sortSelector.selectedIndex = self.model:getInventorySortType()

		self.rootUComponent:TryChangePage("PlayerBagWidget", settlement and 1 or 0)
	end)
end

function GrabEggInventoryComponent:showTransfer()
	self:initContainer(function()
		self:refreshMainTabList()

		local allData = self.listTabMain.itemData

		for index, data in pairs(allData) do
			if data.invId == ItemConst.INV_TYPE_ROB_EGG_WAREHOUSE then
				self.mainTabSelectIdx = index

				break
			end
		end

		self.listTabMain:SelectItem(self.mainTabSelectIdx)
		self.listTabMain:SetActive(false)

		self.sortSelector.selectedIndex = self.model:getInventorySortType()

		self.rootUComponent:TryChangePage("PlayerBagWidget", 1)
	end)
end

function GrabEggInventoryComponent:initDragArea()
	self.dragCoverUButton.gameObject.name = self.model.INVENTORY_DRAG_AREA

	function self.dragCoverUButton.luaHover()
		if not self.dragCoverUButton.isAnyInstanceInDragging then
			return
		end

		local dragWidget = CS.XGUI.UComponent.draggingWidget
		local data = dragWidget.dataFromUList
		local invId = self.model:getInvIdOut(data.itemId)

		self:onDragInArea(invId, true)
		self.ctrl:refreshDragEquipPlaceState(nil)
	end

	function self.dragCoverUButton.luaUnhover()
		if not self.dragCoverUButton.isAnyInstanceInDragging then
			return
		end

		local dragWidget = CS.XGUI.UComponent.draggingWidget
		local data = dragWidget.dataFromUList
		local invId = self.model:getInvIdOut(data.itemId)

		self:onDragInArea(invId, false)
		self.ctrl:clearDragEquipPlaceState()
	end
end

function GrabEggInventoryComponent:refreshMainTabList()
	local mainTabList = self.model:getMainTabList()

	self.listTabMain:SetList(mainTabList)
end

function GrabEggInventoryComponent:refreshPropList()
	local thirdTabList = self.model:getThirdTabList()
	local haveThirdList = thirdTabList and next(thirdTabList) and true or false

	self.listTabThird:SetActive(haveThirdList)

	if haveThirdList then
		for i = 1, #thirdTabList do
			local data = thirdTabList[i]

			if i == 1 then
				data.tIndex = 0
			elseif i == #thirdTabList then
				data.tIndex = 2
			else
				data.tIndex = 1
			end
		end

		self.listTabThird:SetList(thirdTabList)
		self.listTabThird:SelectItem(self.thirdTabSelectIdx)
	else
		self:setPropList()
	end
end

function GrabEggInventoryComponent:refreshCurrentPropList()
	if not self.listProp then
		return
	end

	local selectedThirdTab = self.listTabThird and self.listTabThird.selectedItem or nil

	self:setPropList(selectedThirdTab and selectedThirdTab.paginationId or nil)
end

function GrabEggInventoryComponent:setPropList(thirdPageId)
	local propData = self.model:getInventoryPropList(thirdPageId)
	local displayCount = self.listProp:CalculateMainAxisFillCountByTIndex(1) * 7
	local dataCount = #propData

	for i = 1, displayCount - dataCount do
		propData[#propData + 1] = {
			tIndex = 1
		}
	end

	self.listProp:SetList(propData)
end

function GrabEggInventoryComponent:onRenderPropItem(button, index, data)
	LuaUIUtils.updateGrabEggBtnDragMode(self.listProp, button)
	LuaUIUtils.refreshGrabEggAntiqueTags(button, data)

	if not data.itemId then
		button.draggable = false

		LuaUIUtils.refreshGrabEggSkillChipIcon(button, nil)

		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
	local txtNumUText = objectReference:GetRefValue("txtNumUText")
	local durableUContainer = objectReference and objectReference:GetRefValue("durableUContainer")
	local itemId = data.itemId
	local itemData = ItemData[itemId]
	local isDecomposeState = self.model:isInOperationState(self.model.STATE_DECOMPOSE)

	itemIconUImage.url = data.icon

	ClientTextUtils.setText(txtNumUText, self.model:getItemCountText(data))
	LuaUIUtils.refreshGrabEggDurable(durableUContainer, data)
	button:TryChangePage("Quality", data.quality)
	LuaUIUtils.refreshGrabEggSkillChipIcon(button, itemId)

	button.draggable = not isDecomposeState

	local isLock = data.packSlot:hasStatus(ItemConst.ITEM_STATUS_LOCKED)

	if isDecomposeState then
		local isEquipped = data.bindCatchBallSlot and data.bindCatchBallSlot > 0

		if isLock or not itemData.resolveGetItem or isEquipped then
			button.interactable = false
		else
			button.interactable = true
		end
	elseif isLock then
		button.interactable = false
	else
		button.interactable = true

		local disable = self.model:checkItemDisable(data)

		button.visualInteractable = not disable
	end

	function button.luaEndDrag(dropWidget)
		LuaUIUtils.popupPropTip()
		button:TryChangePage("DragState", 0)
		self.ctrl:showMyBagDragArea(false)
		self.ctrl:refreshCanDragInState(button.dataFromUList, false)

		if UIUtils.IsNull(dropWidget) then
			return
		end

		dropWidget:TryChangePage("DragState", 0)

		if data.type == ItemConst.ITEM_TYPE.CHIP then
			local targetData = dropWidget.dataFromUList

			if targetData and targetData.isMyBag and not checkCanBringItem(data) then
				return
			end

			if targetData and targetData.chipSlotIdx and targetData.equipGenID then
				self.ctrl:registerDragEffect(self.ctrl.CompName.MyBag, targetData.equipSlotIndex * 10 + targetData.chipSlotIdx)
			end

			if self.model:dragChipToEquipSlot(data, targetData, false) then
				return
			end
		end

		if data.type == ItemConst.ITEM_TYPE.REPAIR_KIT then
			local targetData = dropWidget.dataFromUList

			if targetData and targetData.isMyBag and self.model:isEquipBagSlot(targetData.slotIndex) and (targetData.type == ItemConst.ITEM_TYPE.WEAPON or targetData.type == ItemConst.ITEM_TYPE.ARMOR) then
				self.model:tryRepairEquipWithKit(data, targetData)

				return
			end
		end

		local dropName = dropWidget.gameObject.name

		if dropName == self.model.BAG_DRAG_AREA then
			self:DragToMyBag(data)
		elseif dropWidget.dataFromUList and dropWidget.dataFromUList.isMyBag then
			if not checkCanBringItem(data) then
				return
			end

			self.ctrl:registerDragEffect(self.ctrl.CompName.MyBag, dropWidget.dataFromUList.slotIndex)
			self:DragToBagWithIndex(data, dropWidget.dataFromUList.slotIndex, dropWidget.dataFromUList)
		elseif dropWidget.dataFromUList then
			pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_CANT_PUT"))
		end
	end

	function button.luaBeginDrag()
		LuaUIUtils.popupPropTip()
		button:TryChangePage("DragState", 2)

		local dragWidget = CS.XGUI.UComponent.draggingWidget

		dragWidget:TryChangePage("DragState", 1)

		dragWidget.dataFromUList = button.dataFromUList

		self.ctrl:refreshCanDragInState(button.dataFromUList, true)
	end

	function button.luaClick()
		if self.model:isInOperationState(self.model.STATE_DECOMPOSE) then
			self.decomposeComp:tryAddDecompose(button, data)
		else
			self:onClickItem(button, data, self:getHoverBtnDataList(data))
		end
	end

	function button.luaDoubleClick()
		self:onDoubleClick(data)
	end

	function button.luaHover()
		self.model:setHoverData(data)

		if pg.game.input:isUsingGamepad() and self.model:isInOperationState(self.model.STATE_DECOMPOSE) and not pg.global.ui:checkUIOpen(UIConst.UI_ID_INVENTORY_DECOMPOSE) and button.luaClick then
			button.luaClick()
		end
	end

	function button.luaUnhover()
		if self.model then
			self.model:setHoverData(nil)
		end
	end

	function button.luaNavFocused()
		self.model:setHoverData(data)

		if self.model:isInOperationState(self.model.STATE_DECOMPOSE) then
			self.ctrl:clearBottomBarGamepad()
		else
			self.ctrl:refreshBottomBarGamepad(self:getHoverBtnDataList(data))
		end
	end

	function button.luaNavUnfocused()
		if self.ctrl then
			self.ctrl:clearBottomBarGamepad()
		end
	end
end

function GrabEggInventoryComponent:getHoverBtnDataList(data)
	local canBringItem = data.canCarryToRace and not ItemUtils.isForbidRobEgg(data.itemId)
	local canEquip = canBringItem and self.model:isEquipBagType(data.type, true)
	local isEquipItem = data.type == ItemConst.ITEM_TYPE.WEAPON or data.type == ItemConst.ITEM_TYPE.ARMOR
	local isCalcinationCollectible = ItemUtils.isRefineable(data.itemId)
	local antiqueData = isCalcinationCollectible and data.packSlot and data.packSlot.props and data.packSlot.props[ItemConst.ItemPropertyDef.AntiqueData] or nil
	local hasCalcinationCount = antiqueData and (antiqueData.affix_num or 0) < (antiqueData.max_affix_num or 0)

	return self.model:getItemBtnDataListByType(data, {
		[UIConst.GRAB_EGG_ITEM_USE_TYPE.CARRY] = not isCalcinationCollectible and canBringItem and data.type ~= ItemConst.ITEM_TYPE.BAG and data.type ~= ItemConst.ITEM_TYPE.EGG,
		[UIConst.GRAB_EGG_ITEM_USE_TYPE.CALCINATION] = hasCalcinationCount and true or false,
		[UIConst.GRAB_EGG_ITEM_USE_TYPE.EQUIP] = canEquip,
		[UIConst.GRAB_EGG_ITEM_USE_TYPE.REPAIR] = isEquipItem,
		[UIConst.GRAB_EGG_ITEM_USE_TYPE.SAFE_BOX] = canBringItem
	}, function()
		self:refreshCurrentPropList()
	end)
end

function GrabEggInventoryComponent:onRenderMainTabItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")

	iconUImage.url = data.icon
end

function GrabEggInventoryComponent:onMainTabSelected(uList)
	local sData = uList.selectedItem

	if not sData then
		return
	end

	self.mainTabSelectIdx = uList.selectedIndex

	self.model:setInventoryInvId(sData.invId)
	self:refreshPropList()
	self.decomposeComp:onTabSelectChanged()
end

function GrabEggInventoryComponent:onRenderThirdTabItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

	ClientTextUtils.setText(txtNameUBaseText, ClientTextUtils.getLocalizationText(data.nameHashId))
end

function GrabEggInventoryComponent:onThirdTabSelected(uList)
	local sData = uList.selectedItem

	if sData == nil then
		return
	end

	self.thirdTabSelectIdx = self.listTabThird.selectedIndex or 0

	local paginationId = sData.paginationId

	self:setPropList(paginationId)
	self.decomposeComp:onTabSelectChanged(true)
end

function GrabEggInventoryComponent:showItemWidget(active)
	local buttons = self.listProp:GetAllButtons()

	for i = 0, buttons.Length - 1 do
		local data = buttons[i].dataFromUList

		if data.itemId then
			local objectReference = buttons[i]:GetComponent("ObjectReference")
			local weightPanelUWidget = objectReference:GetRefValue("weightPanelUWidget")

			weightPanelUWidget:SetActive(active)
		end
	end
end

function GrabEggInventoryComponent:DragToMyBag(propData)
	if not checkCanBringItem(propData) then
		return
	end

	local type = propData.type

	if type == ItemConst.ITEM_TYPE.BAG then
		pg.me:serverMsg("RPC_CS_MoveRobEggItem", propData.invId, propData.genID, ItemConst.INV_TYPE_EQUIP_SLOTS, ItemConst.ROB_EGG_EQUIP_SLOT.BAG, 1)

		return
	end

	local emptyIndex, haveBag = self.model:getMyBagEmptyIndex(propData.type)

	if emptyIndex then
		local dragCount = self.model:getMaxCountCanDragInInventory(propData.itemId, propData.packSlot.count) or 1

		pg.me:serverMsg("RPC_CS_MoveRobEggItem", propData.invId, propData.genID, ItemConst.INV_TYPE_ROB_EGG, emptyIndex, dragCount)

		return
	end

	local safeIndex = self.model:getSafeBoxEmptyIndex()

	if safeIndex then
		if not self.model:checkSafeBoxOverweight(propData, nil) then
			pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_SAFE_BOX_OVERWEIGHT"))

			return
		end

		local dragCount = self.model:getMaxCountCanDragInInventory(propData.itemId, propData.packSlot.count) or 1

		pg.me:serverMsg("RPC_CS_MoveRobEggItem", propData.invId, propData.genID, ItemConst.INV_TYPE_EQUIP_SLOTS, safeIndex, dragCount)

		return
	end

	if haveBag then
		pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_FULL_1"))
	else
		pg.global.showBubbleMessageRaw(pg.getGameString("GRAB_EGG_FULL_2"))
	end
end

function GrabEggInventoryComponent:onDoubleClick(propData)
	if self.model:isInOperationState(self.model.STATE_DECOMPOSE) then
		return
	end

	if not checkCanBringItem(propData) then
		LuaUIUtils.popupPropTip()

		return
	end

	local type = propData.type

	if type == ItemConst.ITEM_TYPE.CHIP then
		if not self.model:doubleClickChipToEquipSlot(propData, false) then
			self:DragToMyBag(propData)
		end

		LuaUIUtils.popupPropTip()

		return
	end

	local equipIndex = self.model:getDoubleClickIndex(type, propData.itemId)

	if equipIndex then
		self:DragToBagWithIndex(propData, equipIndex)
	else
		self:DragToMyBag(propData)
	end

	LuaUIUtils.popupPropTip()
end

function GrabEggInventoryComponent:DragToBagWithIndex(propData, index, targetData)
	if not checkCanBringItem(propData) then
		return
	end

	if not self.model:checkDragRule(propData, targetData, index) then
		return
	end

	local dragCount = self.model:getMaxCountCanDragInInventory(propData.itemId, propData.packSlot.count) or 1

	pg.me:serverMsg("RPC_CS_MoveRobEggItem", propData.invId, propData.genID, targetData and targetData.invId or ItemConst.INV_TYPE_EQUIP_SLOTS, index, dragCount)
end

function GrabEggInventoryComponent:onClickItem(button, data, btnDataList)
	local haveBtnList = false

	if btnDataList then
		for k, v in pairs(btnDataList) do
			if v then
				haveBtnList = true

				break
			end
		end
	end

	local itemCount = (data.type == ItemConst.ITEM_TYPE.BAG or data.type == ItemConst.ITEM_TYPE.EGG) and 1 or data.packSlot.count

	LuaUIUtils.popupPropTip({
		showGrabEgg = true,
		showLock = false,
		fromParamCount = true,
		id = data.itemId,
		num = data.num,
		targetRect = button,
		itemId = data.itemId,
		itemCount = itemCount,
		invId = data.invId,
		genID = data.genID,
		showNumSelector = haveBtnList and itemCount > 1,
		btnDataList = btnDataList,
		weight = self.model:getWeightIn(data.itemId),
		oriData = data,
		extra = {
			closeFun = function()
				self.ctrl:refreshBottomBarByFocus()
			end
		}
	})
	self.ctrl:clearBottomBarGamepad()
end

function GrabEggInventoryComponent:onDragInArea(invId, dragIn)
	local btnList = self.listTabMain:GetAllButtons()

	for i = 0, btnList.Length - 1 do
		local button = btnList[i]
		local data = button.dataFromUList

		if data.invId == invId then
			if button.isSelected then
				button:TryChangePage("button", dragIn and 7 or 5)

				break
			end

			button:TryChangePage("button", dragIn and 2 or 0)

			break
		end
	end
end

function GrabEggInventoryComponent:showDragArea(active, data)
	if not self.container:CheckURLLoaded() then
		return
	end

	self.dragCoverUButton:SetActive(active)

	if not active and data then
		local invId = self.model:getInvIdOut(data.itemId)

		self:onDragInArea(invId, false)
	end
end

function GrabEggInventoryComponent:event_onEquipPropChanged(payload)
	if not payload or not self.listProp then
		return
	end

	local invId, genId = payload[1], payload[2]

	if invId ~= self.model.curInventoryInvId or not genId then
		return
	end

	local buttons = self.listProp:GetAllButtons()

	for i = 0, buttons.Length - 1 do
		local button = buttons[i]
		local data = button.dataFromUList

		if data and data.invId == invId and data.genID == genId then
			if data.type == ItemConst.ITEM_TYPE.WEAPON or data.type == ItemConst.ITEM_TYPE.ARMOR or data.type == ItemConst.ITEM_TYPE.REPAIR_KIT then
				local objectReference = button:GetComponent("ObjectReference")
				local durableUContainer = objectReference and objectReference:GetRefValue("durableUContainer")

				LuaUIUtils.refreshGrabEggDurable(durableUContainer, data)
			end

			return
		end
	end
end

function GrabEggInventoryComponent:refreshGenCount(genID)
	local allData = self.listProp.itemData
	local targetIdx, sData

	for idx, data in pairs(allData) do
		if data.genID == genID then
			targetIdx = idx
			sData = data

			break
		end
	end

	if targetIdx then
		self.listProp:RefreshElement(targetIdx)
	end
end

function GrabEggInventoryComponent:showTabEffect(invId)
	local btnList = self.listTabMain:GetAllButtons()

	for i = 0, btnList.Length - 1 do
		local button = btnList[i]
		local data = button.dataFromUList

		if data.invId == invId then
			local objectReference = button:GetComponent("ObjectReference")
			local animEffect = objectReference:GetRefValue("animEffect")

			animEffect:Stop()
			animEffect:Play()

			break
		end
	end
end

function GrabEggInventoryComponent:onTabSelectChanged()
	self:refreshPropList()
end

function GrabEggInventoryComponent:resetDecomposeStateList()
	local buttons = self.listProp:GetAllButtons()

	for i = 0, buttons.Length - 1 do
		local data = buttons[i].dataFromUList

		if data.itemId then
			local objectReference = buttons[i]:GetComponent("ObjectReference")
			local btnCancelUButton = objectReference:GetRefValue("btnCancelUButton")
			local selectedNumUWidget = objectReference:GetRefValue("selectedNumUWidget")
			local imgCheckOneUImage = objectReference:GetRefValue("imgCheckOneUImage")
			local txtSelectedNumUBaseText = objectReference:GetRefValue("txtSelectedNumUBaseText")

			btnCancelUButton:SetActive(false)

			btnCancelUButton.luaClick = nil

			ClientTextUtils.setText(txtSelectedNumUBaseText, 0)
			selectedNumUWidget:SetActive(false)
			imgCheckOneUImage:SetActive(false)
			txtSelectedNumUBaseText:SetActive(false)
		end
	end
end

function GrabEggInventoryComponent:switchListBtnState(flag)
	local btns = self.listProp:GetAllButtons()

	for i = 0, btns.Length - 1 do
		local data = btns[i].dataFromUList
		local itemId = data.itemId

		if itemId then
			local objectReference = btns[i]:GetComponent("ObjectReference")
			local stateLockUWidget = objectReference:GetRefValue("stateLockUWidget")
			local imgDisableUImage = objectReference:GetRefValue("imgDisableUImage")
			local isEquipped = data.bindCatchBallSlot and data.bindCatchBallSlot > 0
			local itemData = ItemData[itemId]

			if flag then
				local isLock = data.packSlot:hasStatus(ItemConst.ITEM_STATUS_LOCKED)

				if isLock or not itemData.resolveGetItem or isEquipped then
					btns[i].interactable = false
				else
					btns[i].interactable = true
				end

				btns[i].draggable = false
			else
				btns[i].interactable = true
				btns[i].draggable = true

				local disable = self.model:checkItemDisable(data)

				btns[i].visualInteractable = not disable
			end
		end
	end

	self.ctrl:showDecomposeMask(flag)

	if pg.global.navMgr then
		pg.global.navMgr:SetNavGroupForceNonInteractable("RobotEquipment", flag)
	end

	if flag then
		self.ctrl:clearBottomBarGamepad()
	else
		self.ctrl:refreshBottomBarByFocus()
	end
end

function GrabEggInventoryComponent:refreshBtnDecomposeState(selectedGensTable)
	local buttons = self.listProp:GetAllButtons()

	for i = 0, buttons.Length - 1 do
		local data = buttons[i].dataFromUList

		if data.itemId then
			local objectReference = buttons[i]:GetComponent("ObjectReference")
			local btnCancelUButton = objectReference:GetRefValue("btnCancelUButton")
			local selectedNumUWidget = objectReference:GetRefValue("selectedNumUWidget")
			local imgCheckOneUImage = objectReference:GetRefValue("imgCheckOneUImage")
			local txtSelectedNumUBaseText = objectReference:GetRefValue("txtSelectedNumUBaseText")
			local num = selectedGensTable[data.genID] or 0

			btnCancelUButton:SetActive(num > 0)

			if num > 0 then
				function btnCancelUButton.luaClick()
					self.decomposeComp:decreaseSelected(data.genID, true)
				end
			else
				btnCancelUButton.luaClick = nil
			end

			ClientTextUtils.setText(txtSelectedNumUBaseText, num)
			selectedNumUWidget:SetActive(num > 0)

			local stackCount = ItemUtils.getItemStackCount(buttons[i].dataFromUList.itemId)

			if stackCount == 1 then
				imgCheckOneUImage:SetActive(true)
				txtSelectedNumUBaseText:SetActive(false)
			else
				imgCheckOneUImage:SetActive(false)
				txtSelectedNumUBaseText:SetActive(true)
			end
		end
	end
end

function GrabEggInventoryComponent:onClickTransfer()
	pg.me:serverMsg("RPC_CS_FetchAllRobEggBag")
end

function GrabEggInventoryComponent:onClickReturnRoom()
	self.ctrl:onBtnClose()
end

return GrabEggInventoryComponent
