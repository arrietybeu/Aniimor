-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggBag\\GrabEggBagCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("GrabEggBagCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local GrabEggBagCtrl = Class.LightClass("GrabEggBagCtrl", UICtrl)
local InventoryComp = require("Guis.Panels.GrabEggBag.Component.GrabEggInventoryComponent")
local MyBgComp = require("Guis.Panels.GrabEggBag.Component.GrabEggMyBagComponent")
local SearchComp = require("Guis.Panels.GrabEggBag.Component.GrabEggSearchComponent")
local UIConst = require("Const.UIConst")
local ItemConst = require("Common.Const.ItemConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local TimerManager = require("Core.Timer.TimerManager")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HotkeyConst = require("Const.HotkeyConst")
local LuaMsgUtils = require("Utils.LuaMsgUtils")
local CallbackHandler = require("Core.Common.CallbackHandler")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local NoticeDef = require("Common.NoticeDef")
local GRAB_EGG_SHOP_CLASSIFY_ID = 35
local GOTO_STORE_TEXT_KEY = "GRAB_EGG_GOTO_STORE"

GrabEggBagCtrl.messages = {
	[MessageName.ITEM_GEN_COUNT_CHANGE] = {
		"event_PropGenCountChanged",
		true
	},
	[MessageName.GRAB_EGG_MY_BAG_SLOT] = {
		"event_MyBagNormalSlotChanged",
		false
	},
	[MessageName.GRAB_EGG_MY_BAG_EQUIP_SLOT] = {
		"event_MyBagEquipSlotChanged",
		false
	},
	[MessageName.GRAB_EGG_DISCOVERY_START] = {
		"event_discoveryBoxStart",
		true
	},
	[MessageName.GRAB_EGG_DISCOVERING] = {
		"event_discoveringBox",
		true
	},
	[MessageName.GRAB_EGG_DISCOVERY_FINISHED] = {
		"event_discoveryBoxFinished",
		true
	},
	[MessageName.GRAB_EGG_DISCOVERY_INTERRUPTED] = {
		"event_discoveryBoxInterrupted",
		true
	},
	[MessageName.GRAB_EGG_DISCOVERY_INFO] = {
		"event_discoveryBoxInfo",
		true
	},
	[MessageName.GRAB_EGG_CUR_LOAD] = {
		"event_curLoad",
		true
	},
	[MessageName.ENTER_TRIGGER_MULTI_INTERACT] = {
		"event_CollectionEnterTrigger",
		true
	},
	[MessageName.LEAVE_TRIGGER_MULTI_INTERACT] = {
		"event_CollectionLeaveTrigger",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"event_onInputDeviceChanged",
		true
	},
	[MessageName.GRAB_EGG_HARVEST] = {
		"event_onHarvestChanged",
		true
	},
	[MessageName.CURRENCY_CHANGE] = {
		"event_CurrencyChange",
		true
	},
	[MessageName.ON_HIT_WHEN_ROG_EGG] = {
		"event_onHitWhenRobEgg",
		false
	},
	[MessageName.GRAB_EGG_RESOURCE_BOX_DESTROYED] = {
		"event_onResourceBoxDestroyed",
		true
	},
	[MessageName.ENTER_LIFE_FALLEN] = {
		"event_onMainPlayerIncapacitated",
		true
	},
	[MessageName.PLAYER_HUB_LIFE_DEAD] = {
		"event_onMainPlayerIncapacitated",
		true
	}
}
GrabEggBagCtrl.CompName = {
	MyBag = 1,
	Search = 2
}

function GrabEggBagCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.dragEffectMap = {}
	self.inventoryComp = InventoryComp.new(self, self.view.inventoryContainer)
	self.myBagComp = MyBgComp.new(self, self.view.playerBagMineUWidget)
	self.searchComp = SearchComp.new(self, self.view.searchPanelContainer, info)
	self.bagType = nil

	local configData = pg.me:getConfigData()
	local gender = pg.me.gender or configData.gender

	if gender == 1 then
		self.view.rootUComponent:TryChangePage("Gender", 0)
	elseif gender == 2 then
		self.view.rootUComponent:TryChangePage("Gender", 1)
	else
		self.view.rootUComponent:TryChangePage("Gender", 2)
	end

	if pg.me and pg.me.space and not Utils.isRobEggSceneId(pg.me.space.sceneId) then
		pg.me:serverMsg("RPC_CS_OnOpenRobEggBag")
	end
end

function GrabEggBagCtrl:checkCanOpen(showNotice, info)
	if pg.me and pg.me:EGG_BE_CARRIED_ST() and self.model:isInGrabEggSpace() then
		pg.global.showBubbleMessageById(NoticeDef.ROB_EGG_FORBID_CUR_ACTION)

		return false
	end

	return UICtrl.checkCanOpen(self, showNotice, info)
end

function GrabEggBagCtrl:addListener()
	function self.view.btnBack.luaClick()
		self:dismiss()
	end

	function self.view.jumpUButton.luaClick()
		if LuaUIUtils.checkFuncTemporaryDisable(UIConst.UI_ID_SHOP_MAIN) then
			return
		end

		pg.global.ui:open(UIConst.UI_ID_SHOP_MAIN, {
			shopTags = {
				GRAB_EGG_SHOP_CLASSIFY_ID
			}
		})
	end

	local storeBtnObjectReference = self.view.jumpUButton.transform:GetComponent("ObjectReference")
	local storeBtnText = storeBtnObjectReference:GetRefValue("txtNameUText")

	ClientTextUtils.setText(storeBtnText, pg.getGameString(GOTO_STORE_TEXT_KEY))

	self.view.dropAreaUButton.gameObject.name = self.model.DISCARD_DRAG_AREA

	function self.view.dropAreaUButton.luaHover()
		if not self.model:isInGrabEggSpace() then
			return
		end

		if not self.view.dropAreaUButton.isAnyInstanceInDragging then
			return
		end

		self.view.dragDeleteUButton:TryChangePage("State", 1)
	end

	function self.view.dropAreaUButton.luaUnhover()
		if not self.model:isInGrabEggSpace() then
			return
		end

		if not self.view or not self.view.dropAreaUButton.isAnyInstanceInDragging then
			return
		end

		self.view.dragDeleteUButton:TryChangePage("State", 0)
	end

	self:bindHotKeyPerform("Common/GamepadCancel", function()
		self:onBtnClose()
	end)
	self:addNavFocusListener(CallbackHandler(self, "onNavFocusChange"))
end

function GrabEggBagCtrl:onNavFocusChange()
	if not pg.global.navMgr then
		return
	end

	local inRecycle = pg.global.navMgr.CurrentFocusedGroupName == "Recycle"

	pg.global.navMgr:SetNavGroupForceNonInteractable("BagItem", inRecycle)
	pg.global.navMgr:SetNavGroupForceNonInteractable("SafeBoxMain", inRecycle)
end

function GrabEggBagCtrl:onDestroy()
	if self.closeFunc then
		self.closeFunc()
	end

	self.model:setResourceData(nil, true)
	self.model:setBoxEntityId(nil)
	pg.global.ui:refreshLockCursor()
	UICtrl.onDestroy(self)
end

function GrabEggBagCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.searchComp.startReqInFlight = false

	self:initData(info)

	local isEmpty = false

	if self.bagType == UIConst.GRAB_EGG_BAG_TYPE.INVENTORY then
		self.inventoryComp:showInventory(self.settlement)
	elseif self.bagType == UIConst.GRAB_EGG_BAG_TYPE.RESOURCE_BOX then
		self.searchComp:showResourceBox()
	elseif self.bagType == UIConst.GRAB_EGG_BAG_TYPE.DEATH_BOX_PLAYER then
		self.searchComp:showDeathPlayerBox()
	elseif self.bagType == UIConst.GRAB_EGG_BAG_TYPE.DEATH_BOX_MONSTER then
		self.searchComp:showDeathMonsterBox()
	elseif self.bagType == UIConst.GRAB_EGG_BAG_TYPE.PLAYER_BAG then
		self.searchComp:showPlayerBag()
	elseif self.bagType == UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM then
		self.searchComp:showNearbyItems()
	else
		isEmpty = true
	end

	self.view.rootUComponent:TryChangePage("Empty", isEmpty and 1 or 0)

	local showStoreBtn = self.bagType == UIConst.GRAB_EGG_BAG_TYPE.INVENTORY and not self.model:isInGrabEggSpace()

	self.view.btnJumpUWidget:SetActive(showStoreBtn)

	if not info.reOpen then
		self.myBagComp:showUI()
		self:refreshCurrencyView()
	end

	self:refreshBottomBarPC()
end

function GrabEggBagCtrl:checkUIShowVirtualMouseCursor()
	return self.model:isInOperationState(self.model.STATE_DECOMPOSE)
end

function GrabEggBagCtrl:initData(info)
	self.bagType = info.bagType
	self.closeFunc = info.closeFunc

	self.model:setBagType(self.bagType)
	self.model:setResourceData(info.items)

	self.settlement = info.settlement

	self.model:setBoxEntityId(info.id)
end

function GrabEggBagCtrl:refreshCurrencyView()
	if self.bagType == UIConst.GRAB_EGG_BAG_TYPE.INVENTORY then
		self.view.currencyUWidget:SetActive(true)
		LuaUIUtils.setTopCurrencyItemList(self.view.listCurrency, UIConst.UI_ID_GRAB_EGGS_BAG, nil, {
			useShortItemNum = true
		})
	else
		self.view.currencyUWidget:SetActive(false)
	end
end

function GrabEggBagCtrl:refreshBottomBarPC()
	if pg.game.input:isUsingGamepad() then
		return
	end

	function self.view.keyListUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local btnTipsUText = objectReference:GetRefValue("btnTipsUText")
		local keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")

		keyHotKeyContent:SetHotKeyPaths(data.path)
		self:bindHotKeyPerform(data.path, data.func, self.view.gameObject)
		ClientTextUtils.setText(btnTipsUText, pg.getGameString(data.name))
	end

	local hotKeys = {
		{
			name = "BACK_TO_PRE",
			path = "Common/ClosePanelCommon",
			func = function()
				self:onBtnClose()
			end
		}
	}

	if self.model:isInGrabEggSpace() then
		table.insert(hotKeys, 1, {
			name = "GRAB_EGG_DISCARD",
			path = "Hud/ItemDiscard",
			func = function()
				self:onQuickDiscard()
			end
		})
	end

	self.view.keyListUList:SetList(hotKeys)

	local mouseRightBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.gameObject, "Raw/MouseRight")

	mouseRightBind.isVirtual = true
	mouseRightBind.actionPath = "Raw/MouseRight"

	function mouseRightBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Canceled" then
			self:quickTransferItem()
		end

		return true
	end

	self:bindHotKeyPerform("Hud/QuickTransferItem", function()
		self:quickTransferItem()
	end, self.view.gameObject)
end

function GrabEggBagCtrl:showInventoryDragArea(active, data)
	self.inventoryComp:showDragArea(active, data)
end

function GrabEggBagCtrl:showMyBagDragArea(active)
	self.myBagComp:showDragArea(active)
end

function GrabEggBagCtrl:showDiscardDragArea(active)
	self.searchComp:showDragArea(active)
end

function GrabEggBagCtrl:showTabEffect(invId)
	self.inventoryComp:showTabEffect(invId)
end

function GrabEggBagCtrl:showWeight(show)
	self.myBagComp:showWeight(show)

	if self.bagType == UIConst.GRAB_EGG_BAG_TYPE.RESOURCE_BOX or self.bagType == UIConst.GRAB_EGG_BAG_TYPE.DEATH_BOX_MONSTER or self.bagType == UIConst.GRAB_EGG_BAG_TYPE.PLAYER_BAG or self.bagType == UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM then
		self.searchComp:showWeight(show)
	end
end

function GrabEggBagCtrl:refreshCanDragInState(dragData, show)
	self.myBagComp:refreshCanDragInState(dragData, show)
end

function GrabEggBagCtrl:onQuickDiscard()
	self.model:discardHoverItem()
end

function GrabEggBagCtrl:refreshDragEquipPlaceState(targetData)
	local dragWidget = CS.XGUI.UComponent.draggingWidget

	if UIUtils.IsNull(dragWidget) then
		return
	end

	local dragData = dragWidget.dataFromUList

	if not self:isDragEquipSlotItem(dragData) then
		return
	end

	if self.model:getBagType() == UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM then
		dragWidget:TryChangePage("DragState", 0)

		return
	end

	local enough = self.model:checkEquipSwapPlaceEnough(dragData, targetData)

	dragWidget:TryChangePage("DragState", 0)
	dragWidget:TryChangePage("DragState", enough and 5 or 6)
end

function GrabEggBagCtrl:clearDragEquipPlaceState()
	local dragWidget = CS.XGUI.UComponent.draggingWidget

	if UIUtils.IsNull(dragWidget) then
		return
	end

	if not self:isDragEquipSlotItem(dragWidget.dataFromUList) then
		return
	end

	dragWidget:TryChangePage("DragState", 0)
end

function GrabEggBagCtrl:isDragEquipSlotItem(dragData)
	return dragData ~= nil and dragData.isMyBag and (dragData.slotIndex == ItemConst.ROB_EGG_EQUIP_SLOT.WEAPON or dragData.slotIndex == ItemConst.ROB_EGG_EQUIP_SLOT.ARMOR)
end

function GrabEggBagCtrl:refreshHoverDataFromPointer(list)
	if pg.game.input:isUsingGamepad() then
		return
	end

	local buttons = list and list:GetAllButtons()

	if not buttons then
		return
	end

	for i = 0, buttons.Length - 1 do
		local btn = buttons[i]

		if btn and btn.isPointerInside then
			self.model:setHoverData(btn.dataFromUList)

			return
		end
	end
end

function GrabEggBagCtrl:quickTransferItem()
	local data = self.model:getHoverData()

	if not data then
		return
	end

	if data.isMyBag then
		self.myBagComp:onDoubleClick(data)
	elseif self.bagType == UIConst.GRAB_EGG_BAG_TYPE.INVENTORY then
		self.inventoryComp:onDoubleClick(data)
	else
		self.searchComp:onDoubleClick(data)
	end
end

function GrabEggBagCtrl:getLoadState(weight)
	return self.model:getLoadState(weight)
end

function GrabEggBagCtrl:registerDragEffect(compName, slot)
	if not compName or not slot then
		return
	end

	if not self.dragEffectMap[compName] then
		self.dragEffectMap[compName] = {}
	end

	local timer = self.dragEffectMap[compName][slot]

	if timer then
		self:killTimer(timer)
	end

	self.dragEffectMap[compName][slot] = self:startTimer(function()
		self.dragEffectMap[compName][slot] = nil
	end, 1)
end

function GrabEggBagCtrl:unRegisterDragEffect(compName, slot)
	if not compName or not slot then
		return
	end

	if not self.dragEffectMap[compName] then
		return
	end

	local timer = self.dragEffectMap[compName][slot]

	if timer then
		self:killTimer(timer)

		self.dragEffectMap[compName][slot] = nil
	end
end

function GrabEggBagCtrl:checkNeedPlayDragEffect(compName, slot)
	return self.dragEffectMap[compName] and self.dragEffectMap[compName][slot] and true or false
end

function GrabEggBagCtrl:onBtnClose()
	if self.model:isInOperationState(self.model.STATE_DECOMPOSE) then
		self.inventoryComp.decomposeComp:onExitDecomposeSate()

		return
	end

	if pg.game.input:isUsingGamepad() then
		if pg.global.ui:checkUIVisible(UIConst.UI_ID_COMMON_ITEM_TIP) then
			LuaUIUtils.popupPropTip()
		else
			self:dismiss()
		end
	else
		self:dismiss()
	end
end

function GrabEggBagCtrl:refreshOwnerTag(button, ownerUid, forceSelf)
	if forceSelf then
		button:TryChangePage("OwnState", 2)

		return
	end

	if ownerUid == pg.me.uid then
		button:TryChangePage("OwnState", 2)
	else
		local teamOrder = pg.space and pg.space.getGrabEggTeamIndex and pg.space:getGrabEggTeamIndex(ownerUid) or 0

		if teamOrder and tonumber(teamOrder) > 0 then
			local objectReference = button:GetComponent("ObjectReference")
			local textPlayerNumUBaseText = objectReference:GetRefValue("textPlayerNumUBaseText")

			ClientTextUtils.setText(textPlayerNumUBaseText, string.format("%sP", teamOrder))
			button:TryChangePage("OwnState", 1)
		else
			button:TryChangePage("OwnState", 2)
		end
	end
end

function GrabEggBagCtrl:showDecomposeMask(show)
	self.myBagComp:showDecomposeMask(show)
end

function GrabEggBagCtrl:event_CurrencyChange()
	self:refreshCurrencyView()
end

function GrabEggBagCtrl:event_PropGenCountChanged(info)
	local invId = info.invId
	local genId = info.genId
	local changeType = info.changeType

	if invId == self.model.curInventoryInvId then
		if changeType == ItemConst.INV_GEN_CHANGE then
			self.inventoryComp:refreshGenCount(genId, changeType)
		else
			self.inventoryComp:refreshPropList()
		end
	else
		self.myBagComp:onRefreshSlotByGenId(genId, invId)
	end
end

function GrabEggBagCtrl:event_MyBagNormalSlotChanged(info)
	self.model:onBagSlotChangedDuringRepair(ItemConst.INV_TYPE_ROB_EGG, info.index)

	if self.view then
		self.myBagComp:onRefreshSlot(info.index, ItemConst.INV_TYPE_ROB_EGG)
	end
end

function GrabEggBagCtrl:event_MyBagEquipSlotChanged(info)
	self.model:onBagSlotChangedDuringRepair(ItemConst.INV_TYPE_EQUIP_SLOTS, info.index)

	if self.view then
		self.myBagComp:onRefreshSlot(info.index, ItemConst.INV_TYPE_EQUIP_SLOTS)
	end
end

function GrabEggBagCtrl:event_onHitWhenRobEgg()
	if self.model:isRepairingKit() then
		self.model:cancelRepairTimer()
	end
end

function GrabEggBagCtrl:event_onMainPlayerIncapacitated()
	self:dismiss()
end

function GrabEggBagCtrl:event_curLoad()
	self.myBagComp:refreshWeight()
end

function GrabEggBagCtrl:event_discoveryBoxStart(info)
	if info.id ~= self.model:getBoxEntityId() then
		return
	end

	self.searchComp:onStartSearch(info.pos, info.endTime)
end

function GrabEggBagCtrl:event_discoveringBox(info)
	if info.id ~= self.model:getBoxEntityId() then
		return
	end
end

function GrabEggBagCtrl:event_discoveryBoxFinished(info)
	if info.id ~= self.model:getBoxEntityId() then
		return
	end

	self.searchComp:onFinishSearch(info.pos)
end

function GrabEggBagCtrl:event_discoveryBoxInterrupted(info)
	if info.id ~= self.model:getBoxEntityId() then
		return
	end

	self.searchComp:onInterruptedSearch(info.pos)
end

function GrabEggBagCtrl:event_discoveryBoxInfo(info)
	if info.id ~= self.model:getBoxEntityId() then
		return
	end

	local oldData = self.model:getResourceData()
	local newData = info.items

	self.model:setResourceData(newData)

	if oldData and oldData.bagSlots and newData and newData.bagSlots then
		oldData = oldData.bagSlots
		newData = newData.bagSlots
	end

	if not oldData or #oldData ~= #newData then
		self.searchComp:onRefreshResourceData()
	else
		local slots = {}

		for k, v in pairs(newData) do
			if not Utils.isTableEqual(newData[k], oldData[k]) then
				slots[#slots + 1] = k
			end
		end

		self.searchComp:onRefreshResourceData(slots)
	end
end

function GrabEggBagCtrl:event_onResourceBoxDestroyed(info)
	if not info or info.id ~= self.model:getBoxEntityId() then
		return
	end

	self.model:setBoxEntityId(nil)
	self.model:setResourceData(nil, true)
	self.searchComp:onRefreshResourceData()
end

function GrabEggBagCtrl:event_CollectionEnterTrigger(info)
	if self.bagType ~= UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM then
		return
	end

	if not info or not next(info) then
		return
	end

	for k, data in pairs(info) do
		local entity = pg.getEntityByGlobalId(data.globalId)

		if Utils.isCollectItem(entity) then
			TimerManager.addNextFrameCb(function()
				self.model:setResourceData(pg.me:getNearbyCollectionList())
				self.searchComp:onRefreshResourceData()
			end)

			break
		end
	end
end

function GrabEggBagCtrl:event_CollectionLeaveTrigger(info)
	if self.bagType ~= UIConst.GRAB_EGG_BAG_TYPE.NEARBY_ITEM then
		return
	end

	if not info or not next(info) then
		return
	end

	local resourceData = self.model:getResourceData()

	if not resourceData then
		return
	end

	local map = {}

	for i = 1, #resourceData do
		local data = resourceData[i]

		map[data.entityId] = true
	end

	for k, data in pairs(info) do
		if map[data.globalId] then
			TimerManager.addNextFrameCb(function()
				self.model:setResourceData(pg.me:getNearbyCollectionList())
				self.searchComp:onRefreshResourceData()
			end)

			break
		end
	end
end

function GrabEggBagCtrl:event_onInputDeviceChanged()
	if pg.game.input:isUsingGamepad() then
		-- block empty
	else
		self:refreshBottomBarPC()
	end
end

function GrabEggBagCtrl:event_onHarvestChanged()
	if self.model:isInGrabEggSpace() then
		self.myBagComp:refreshValue()
	end
end

function GrabEggBagCtrl:getVirtualBtns()
	return {
		self.view.gamePadVirtualBtn1UButton,
		self.view.gamePadVirtualBtn2UButton,
		self.view.gamePadVirtualBtn3UButton,
		self.view.gamePadVirtualBtn4UButton
	}
end

function GrabEggBagCtrl:clearBottomBarGamepad()
	for _, btn in ipairs(self:getVirtualBtns()) do
		btn:RemoveLuaGamepadHotkey()
		btn:SetActive(false)
	end
end

function GrabEggBagCtrl:refreshBottomBarGamepad(btnDataList)
	if not pg.game.input:isUsingGamepad() then
		return
	end

	if self.settlement then
		self:clearBottomBarGamepad()

		return
	end

	local virtualBtns = self:getVirtualBtns()
	local index = 0

	if btnDataList then
		for _, data in ipairs(btnDataList) do
			local btn = virtualBtns[index + 1]

			if not btn then
				break
			end

			index = index + 1

			btn:SetActive(true)

			local function clickFunc()
				if data.confirmFunc then
					data.confirmFunc({})
				end

				return false
			end

			if data.isLongPress then
				btn:SetGamepadLongPress(data.path, nil, 0, clickFunc)
			else
				btn:SetGamepadAction(data.path, nil, clickFunc)
			end

			btn:SetHotkeyConsoleBar(data.name, -index)
		end
	end

	for i = index + 1, #virtualBtns do
		virtualBtns[i]:RemoveLuaGamepadHotkey()
		virtualBtns[i]:SetActive(false)
	end
end

function GrabEggBagCtrl:refreshBottomBarByFocus()
	if not pg.game.input:isUsingGamepad() then
		return
	end

	TimerManager.addNextFrameCb(function()
		if not self.view or not pg.global.navMgr then
			return
		end

		local focused = pg.global.navMgr.CurrentFocusedUContent

		if focused and focused.luaNavFocused then
			focused.luaNavFocused()
		else
			self:clearBottomBarGamepad()
		end
	end)
end

return GrabEggBagCtrl
