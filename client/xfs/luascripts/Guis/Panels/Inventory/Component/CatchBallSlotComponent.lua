-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Inventory\\Component\\CatchBallSlotComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local CatchBallSlotComponent = Class.LightClass("CatchBallSlotComponent", UIComponent)
local ItemConst = require("Common.Const.ItemConst")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local TimerManager = require("Core.Timer.TimerManager")

function CatchBallSlotComponent:findObjects()
	self.container = self.view.ballPanel
	self.listProp = self.view.listProp
end

function CatchBallSlotComponent:initView()
	self.curSelectSlotType = ItemConst.QUICK_SLOT_BALL
	self.curSelectSlot = 1
	self.curDragSlotBtn = nil
	self.isContainerLoading = false
	self.slotPropsList = nil
	self.effectTimer = nil
	self.equipEffectSlotType = nil
	self.equipEffectIndex = nil
	self.unEquipEffectSlotType = nil
	self.unEquipEffectIndex = nil
end

function CatchBallSlotComponent:onDestroy()
	UIComponent.onDestroy(self)

	if self.effectTimer then
		TimerManager.removeTimer(self.effectTimer)

		self.effectTimer = nil
	end
end

function CatchBallSlotComponent:findContainerObjects()
	local objectReference = self.container.content.transform:GetComponent("ObjectReference")

	self.txtNum = objectReference:GetRefValue("txtNum")
	self.listBall = objectReference:GetRefValue("listBall")
	self.btnConfirm = objectReference:GetRefValue("btnConfirm")
	self.btnClose = objectReference:GetRefValue("btnClose")
	self.equipmentUComponent = objectReference:GetRefValue("equipmentUComponent")
	self.dragAreaL = objectReference:GetRefValue("dragAreaL")
	self.dragAreaR = objectReference:GetRefValue("dragAreaR")
	self.bulkOperationUWidget = objectReference:GetRefValue("bulkOperationUWidget")
	self.equipmentAnimation = objectReference:GetRefValue("equipmentAnimation")

	function self.listBall.luaRenderItem(button, idx, data)
		self:setUpPropSlot(button, idx, data)

		local objectReference = button:GetComponent("ObjectReference")
		local ballItemUButton = objectReference:GetRefValue("ballItemUButton")

		ballItemUButton.isSelected = false

		function ballItemUButton.luaSelectChanged(select)
			if not select then
				return
			end

			if self.curSelectBtn and self.curSelectBtn ~= ballItemUButton then
				self.curSelectBtn.isSelected = false
			end

			self.curSelectBtn = ballItemUButton

			self.listBall:SelectItem(idx)
		end
	end

	function self.listBall.luaSelectedChanged(uList, select)
		if not select then
			return
		end

		local selectedItem = uList.selectedItem

		if selectedItem.tIndex ~= 0 then
			return
		end

		self.curSelectSlotType = selectedItem.slotType
		self.curSelectSlot = selectedItem.slotIndex

		self:onBallSelected(selectedItem)
		self:refreshEquipBtnState()
	end

	function self.btnClose.luaClick()
		self:onExitCatchBallState()
	end

	function self.dragAreaL.luaClick()
		self:closeEquipPanel()
	end

	function self.dragAreaL.luaHover()
		if not self.dragAreaL.isAnyInstanceInDragging then
			return
		end

		self.equipmentUComponent:TryChangePage("Cancel", 1)
	end

	function self.dragAreaL.luaUnhover()
		if not self.dragAreaL.isAnyInstanceInDragging then
			return
		end

		self.equipmentUComponent:TryChangePage("Cancel", 0)
	end

	function self.dragAreaR.luaClick()
		self:closeEquipPanel()
	end

	function self.dragAreaR.luaHover()
		if not self.dragAreaL.isAnyInstanceInDragging then
			return
		end

		self.equipmentUComponent:TryChangePage("Cancel", 2)
	end

	function self.dragAreaR.luaUnhover()
		if not self.dragAreaL.isAnyInstanceInDragging then
			return
		end

		self.equipmentUComponent:TryChangePage("Cancel", 0)
	end

	self:closeEquipPanel()
end

function CatchBallSlotComponent:initContainer(callback)
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

function CatchBallSlotComponent:getBallSlotType(data)
	if data and data.catchBallSlotType then
		return data.catchBallSlotType
	end

	if data and data.itemId then
		return ItemUtils.getBallQuickSlotType(data.itemId)
	end

	return ItemConst.QUICK_SLOT_BALL
end

function CatchBallSlotComponent:getTargetSlotByPropData(data)
	local slotType = self:getBallSlotType(data)
	local slotIndex = data and data.bindCatchBallSlot

	if not slotIndex or slotIndex <= 0 then
		slotIndex = self.model:getFirstEmptyBallSlot(slotType) or 1
	end

	return slotType, slotIndex
end

function CatchBallSlotComponent:getSlotDisplayInfo(slotType, slotIndex)
	if self.listBall and self.listBall.itemData then
		for displayIndex, data in pairs(self.listBall.itemData) do
			if data.tIndex == 0 and data.slotType == slotType and data.slotIndex == slotIndex then
				return displayIndex, data
			end
		end
	end

	if self.slotPropsList then
		for index, data in ipairs(self.slotPropsList) do
			if data.tIndex == 0 and data.slotType == slotType and data.slotIndex == slotIndex then
				return index - 1, data
			end
		end
	end
end

function CatchBallSlotComponent:getSlotData(slotType, slotIndex)
	local _, data = self:getSlotDisplayInfo(slotType, slotIndex)

	return data
end

function CatchBallSlotComponent:getSlotButton(slotType, slotIndex)
	local displayIndex = self:getSlotDisplayInfo(slotType, slotIndex)

	if displayIndex == nil then
		return nil
	end

	local res, button = self.listBall:TryGetChildAt(displayIndex)

	if res then
		return button
	end
end

function CatchBallSlotComponent:onEnterCatchBallState()
	self:initContainer(function()
		if self.model:isInOperationState(self.model.STATE_CATCHBALL) then
			return
		end

		self.model:setOperationState(self.model.STATE_CATCHBALL)

		if self.ctrl and self.ctrl.module == "inventory" then
			pg.global.ui:refreshLockCursor()
		end

		self.container:SetActive(true)

		local selectListData = self.model:getSelectPropData()

		self.curSelectSlotType, self.curSelectSlot = self:getTargetSlotByPropData(selectListData)

		self:refreshBallList()
		self.ctrl:refreshPropList(false)
	end)
end

function CatchBallSlotComponent:onExitCatchBallState()
	if not self.model:isInOperationState(self.model.STATE_CATCHBALL) then
		return
	end

	self.curSelectSlotType = ItemConst.QUICK_SLOT_BALL
	self.curSelectSlot = 1
	self.curDragSlotBtn = nil

	self.model:setOperationState(self.model.STATE_NORMAL)

	if self.ctrl and self.ctrl.module == "inventory" then
		pg.global.ui:refreshLockCursor()
	end

	self.ctrl:refreshPropList(false)

	local allBtns = self.listBall:GetAllButtons()

	for i = 0, allBtns.Length - 1 do
		local data = allBtns[i].dataFromUList

		if data and data.tIndex == 0 then
			allBtns[i]:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		end
	end

	self.bulkOperationUWidget:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.Custom1, function()
		self.container:SetActive(false)
	end)
end

function CatchBallSlotComponent:refreshBallList(onlyChanged)
	if not self.model:isInOperationState(self.model.STATE_CATCHBALL) then
		return
	end

	local slotPropsList = {}
	local normalSlots = self.model:getQuickSlotItemInfos(ItemConst.QUICK_SLOT_BALL)

	for _, data in ipairs(normalSlots) do
		slotPropsList[#slotPropsList + 1] = data
	end

	local eliteSlots = self.model:getQuickSlotItemInfos(ItemConst.QUICK_SLOT_ELITE_BALL)

	for _, data in ipairs(eliteSlots) do
		slotPropsList[#slotPropsList + 1] = data
	end

	local oldData = self.listBall.itemData
	local canRefreshPartially = onlyChanged and oldData ~= nil and oldData.Count == #slotPropsList

	if canRefreshPartially then
		for i, data in ipairs(slotPropsList) do
			local index = i - 1
			local oldSlotData = oldData[index]

			if oldSlotData.itemId ~= data.itemId or oldSlotData.slotType ~= data.slotType or oldSlotData.slotIndex ~= data.slotIndex then
				self.listBall:SetElement(index, data)
			end
		end
	else
		self.listBall:SetList(slotPropsList)
	end

	self.slotPropsList = slotPropsList

	if self.curSelectSlotType ~= nil and self.curSelectSlot ~= nil then
		self:selectBallItem(self.curSelectSlotType, self.curSelectSlot)
	end

	local curEquipCount = 0

	for _, v in ipairs(slotPropsList) do
		if v.tIndex == 0 and v.itemId > 0 then
			curEquipCount = curEquipCount + 1
		end
	end

	local maxSlotCount = ItemUtils.getQuickSlotMaxCount(ItemConst.QUICK_SLOT_BALL) + ItemUtils.getQuickSlotMaxCount(ItemConst.QUICK_SLOT_ELITE_BALL)

	ClientTextUtils.setText(self.txtNum, string.format("%s/%s", curEquipCount, maxSlotCount))
	self:refreshEquipBtnState()
end

function CatchBallSlotComponent:refreshEquipBtnState()
	if not self.model:isInOperationState(self.model.STATE_CATCHBALL) then
		return
	end

	local objectReference = self.btnConfirm:GetComponent("ObjectReference")
	local name = objectReference:GetRefValue("txtNameUText")
	local selectListData = self.model:getSelectPropData()

	if not selectListData or selectListData.packSlot:hasStatus(ItemConst.ITEM_STATUS_LOCKED) then
		self.btnConfirm:SetActive(false)

		return
	end

	local selectSlotType = self:getBallSlotType(selectListData)

	if self.curSelectSlotType ~= selectSlotType then
		self.curSelectSlotType, self.curSelectSlot = self:getTargetSlotByPropData(selectListData)

		self:selectBallItem(self.curSelectSlotType, self.curSelectSlot)
	end

	local selectSlotData = self:getSlotData(self.curSelectSlotType, self.curSelectSlot)

	if not selectSlotData then
		self.btnConfirm:SetActive(false)

		return
	end

	self.btnConfirm:SetActive(true)

	if selectListData.itemId == selectSlotData.itemId then
		ClientTextUtils.setText(name, pg.getGameString("INVENTORY_CATCHBALL_UNLOAD"))

		function self.btnConfirm.luaClick()
			self.model:trySetupBallToQuickSlot(self.curSelectSlotType, self.curSelectSlot, self.model.EMPTY_ITEM_ID)
		end
	elseif selectSlotData.itemId == self.model.EMPTY_ITEM_ID then
		ClientTextUtils.setText(name, pg.getGameString("INVENTORY_CATCHBALL_EQUIP"))

		function self.btnConfirm.luaClick()
			self.model:trySetupBallToQuickSlot(self.curSelectSlotType, self.curSelectSlot, selectListData.itemId)
		end
	else
		ClientTextUtils.setText(name, pg.getGameString("INVENTORY_CATCHBALL_REPLACE"))

		function self.btnConfirm.luaClick()
			self.model:trySetupBallToQuickSlot(self.curSelectSlotType, self.curSelectSlot, selectListData.itemId)
		end
	end
end

function CatchBallSlotComponent:setUpPropSlot(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtOrder = objectReference:GetRefValue("txtOrder")
	local iconBall = objectReference:GetRefValue("iconBall")
	local txtNum = objectReference:GetRefValue("txtNum")
	local ballItemUButton = objectReference:GetRefValue("ballItemUButton")
	local txtOrder2 = objectReference:GetRefValue("txtOrder2")
	local noneUWidget = objectReference:GetRefValue("noneUWidget")
	local txtNoneName = objectReference:GetRefValue("txtNoneName")
	local isEmpty = data.itemId == 0

	button.gameObject.name = data.slotIndex

	ClientTextUtils.setText(txtOrder, data.slotIndex)
	ClientTextUtils.setText(txtOrder2, data.slotIndex)
	button:TryChangePage("State", 0)

	ballItemUButton.dragMode = 0

	function button.luaHover()
		if not button.isAnyInstanceInDragging then
			return
		end

		local bFromPropList = self.ctrl.curDragPropBtn ~= nil

		if bFromPropList then
			local propData = self.ctrl.curDragPropBtn.dataFromUList
			local propSlotType = self:getBallSlotType(propData)

			if propSlotType ~= data.slotType then
				button:TryChangePage("State", 0)

				return
			end

			local isSelf = propData.itemId == data.itemId
			local state

			state = isEmpty and 1 or isSelf and 3 or 2

			button:TryChangePage("State", state)

			local allBtns = self.listBall:GetAllButtons()

			for i = 0, allBtns.Length - 1 do
				local ballData = allBtns[i].dataFromUList

				if ballData and ballData.tIndex == 0 and ballData.slotType == data.slotType and ballData.itemId == propData.itemId and not isSelf then
					allBtns[i]:TryChangePage("State", 4)

					break
				end
			end
		else
			local dragData = self.curDragSlotBtn and self.curDragSlotBtn.dataFromUList

			if not dragData or dragData.slotType ~= data.slotType then
				button:TryChangePage("State", 0)

				return
			end

			local isSelf = self.curDragSlotBtn == button
			local state

			state = isEmpty and 1 or isSelf and 3 or 2

			button:TryChangePage("State", state)

			if self.curDragSlotBtn and not isSelf then
				self.curDragSlotBtn:TryChangePage("State", 4)
			end
		end

		local draggingWidget = CS.XGUI.UComponent.draggingWidget

		if not IsNil(draggingWidget) then
			draggingWidget:TryChangePage("State", 0)
		end
	end

	function button.luaUnhover()
		if not button.isAnyInstanceInDragging then
			return
		end

		local bFromPropList = self.ctrl.curDragPropBtn ~= nil

		if bFromPropList then
			button:TryChangePage("State", 0)

			local propData = self.ctrl.curDragPropBtn.dataFromUList
			local propSlotType = self:getBallSlotType(propData)

			if propSlotType ~= data.slotType then
				return
			end

			local isSelf = propData.itemId == data.itemId
			local allBtns = self.listBall:GetAllButtons()

			for i = 0, allBtns.Length - 1 do
				local ballData = allBtns[i].dataFromUList

				if ballData and ballData.tIndex == 0 and ballData.slotType == data.slotType and ballData.itemId == propData.itemId and not isSelf then
					allBtns[i]:TryChangePage("State", 0)

					break
				end
			end
		else
			button:TryChangePage("State", 0)

			local dragData = self.curDragSlotBtn and self.curDragSlotBtn.dataFromUList

			if self.curDragSlotBtn and dragData and dragData.slotType == data.slotType then
				self.curDragSlotBtn:TryChangePage("State", 0)
			end
		end
	end

	if isEmpty then
		ballItemUButton:TryChangePage("IsEmpty", 1)

		ballItemUButton.draggable = false
	else
		ballItemUButton:TryChangePage("IsEmpty", 0)

		iconBall.url = data.icon

		noneUWidget:SetActive(false)
		ClientTextUtils.setText(txtNum, ClientUtils.getItemCountById(data.itemId, true))

		ballItemUButton.draggable = true

		function ballItemUButton.luaBeginDrag()
			self.curDragSlotBtn = button

			self:openEquipPanel()
			button:TryChangePage("State", 3)

			local draggingWidget = CS.XGUI.UComponent.draggingWidget

			if not IsNil(draggingWidget) then
				draggingWidget:TryChangePage("State", 3)

				local objectReference = draggingWidget:GetComponent("ObjectReference")
				local iconBall = objectReference:GetRefValue("iconBall")

				iconBall.url = data.icon
			end
		end

		function ballItemUButton.luaEndDrag(dropWidget)
			local fromData = data
			local dropData = dropWidget and dropWidget.dataFromUList

			self.curDragSlotBtn = nil

			if not dropData or dropData.tIndex ~= 0 or dropData.slotType ~= fromData.slotType then
				button:TryChangePage("State", 0)
				self:closeEquipPanel()

				return
			end

			if fromData.slotIndex == dropData.slotIndex then
				self.model:tryModifyGroup(fromData.slotIndex, nil, fromData.slotType)
				self:setUnEquipEffectIndex(fromData.slotType, fromData.slotIndex)
			else
				self.model:tryModifyGroup(fromData.slotIndex, dropData.slotIndex, fromData.slotType)
				self:setEquipEffectIndex(fromData.slotType, dropData.slotIndex)
			end

			button:TryChangePage("State", 0)
			dropWidget:TryChangePage("State", fromData.slotIndex == dropData.slotIndex and 3 or 2)
		end
	end
end

function CatchBallSlotComponent:delCatchBall(sData)
	local slotType = self:getBallSlotType(sData)

	if not self.model:isInOperationState(self.model.STATE_CATCHBALL) then
		if sData.bindCatchBallSlot and sData.bindCatchBallSlot > 0 then
			self.model:tryModifyGroup(sData.bindCatchBallSlot, nil, slotType)
		end

		return
	end

	local allData = self.listBall.itemData

	for _, data in pairs(allData) do
		if data.tIndex == 0 and data.slotType == slotType and data.itemId == sData.itemId then
			self.model:tryModifyGroup(data.slotIndex, nil, data.slotType)

			break
		end
	end
end

function CatchBallSlotComponent:playEquipAnim(itemId)
	if self.equipEffectIndex then
		local button = self:getSlotButton(self.equipEffectSlotType, self.equipEffectIndex)

		if button then
			self:playEquipAnimByWidget(button, true)
			self:setEquipEffectIndex(nil, nil)
		end
	elseif self.unEquipEffectIndex then
		local button = self:getSlotButton(self.unEquipEffectSlotType, self.unEquipEffectIndex)

		if button then
			self:playEquipAnimByWidget(button, false)
			self:setUnEquipEffectIndex(nil, nil)
		end
	end
end

function CatchBallSlotComponent:playEquipAnimByWidget(widget, isEquip)
	if isEquip then
		widget:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.User1, function()
			self:closeEquipPanel()
		end)
		widget:InvokeCallback(CS.XGUI.EInvokeTime.User3)
	else
		widget:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.User2, function()
			self:closeEquipPanel()
		end)
	end
end

function CatchBallSlotComponent:selectBallItem(slotType, slotIndex)
	local displayIndex = self:getSlotDisplayInfo(slotType, slotIndex)

	if displayIndex == nil then
		return
	end

	self.curSelectSlotType = slotType
	self.curSelectSlot = slotIndex

	local res, button = self.listBall:TryGetChildAt(displayIndex)

	if res then
		local objectReference = button:GetComponent("ObjectReference")
		local ballItemUButton = objectReference:GetRefValue("ballItemUButton")

		ballItemUButton.isSelected = false
		ballItemUButton.isSelected = true
	else
		self.listBall:SelectItem(displayIndex)
	end
end

function CatchBallSlotComponent:onPropListSelectItem(itemId)
	local slotType = ItemUtils.getBallQuickSlotType(itemId)
	local allData = self.listBall.itemData

	self.listBall:DeselectAll()

	for displayIndex, data in pairs(allData) do
		if data.tIndex == 0 and data.slotType == slotType and data.itemId == itemId then
			if displayIndex ~= self.listBall.selectedIndex then
				self:selectBallItem(data.slotType, data.slotIndex)
			end

			return
		end
	end

	self:selectBallItem(slotType, self.model:getFirstEmptyBallSlot(slotType) or 1)
end

function CatchBallSlotComponent:onBallSelected(data)
	local isEmpty = data.tIndex ~= 0 or data.itemId == 0

	if isEmpty then
		return
	end

	local allData = self.listProp.itemData

	for idx, propData in pairs(allData) do
		if propData.itemId == data.itemId and self:getBallSlotType(propData) == data.slotType then
			self.listProp:SelectItem(idx)

			break
		end
	end
end

function CatchBallSlotComponent:openEquipPanel()
	self.equipmentUComponent:TryChangePage("IsDrag", 1)
	self.equipmentUComponent:TryChangePage("Cancel", 0)
	self.dragAreaL:SetActive(true)
	self.dragAreaR:SetActive(true)
end

function CatchBallSlotComponent:closeEquipPanel()
	self.equipmentUComponent:TryChangePage("IsDrag", 0)
	self.dragAreaL:SetActive(false)
	self.dragAreaR:SetActive(false)

	local allBtns = self.listBall:GetAllButtons()

	for i = 0, allBtns.Length - 1 do
		local data = allBtns[i].dataFromUList

		if data and data.tIndex == 0 then
			allBtns[i]:TryChangePage("State", 1)
			allBtns[i]:TryChangePage("State", 0)
		end
	end
end

function CatchBallSlotComponent:setEquipEffectIndex(slotType, index)
	self.equipEffectSlotType = slotType
	self.equipEffectIndex = index
end

function CatchBallSlotComponent:setUnEquipEffectIndex(slotType, index)
	self.unEquipEffectSlotType = slotType
	self.unEquipEffectIndex = index
end

return CatchBallSlotComponent
