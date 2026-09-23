-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CaptureBall\\Component\\CaptureBallPCComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local AddressDataConst = require("Const.AddressDataConst")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientUtils = require("Utils.ClientUtils")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local EventConst = require("Const.EventConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local CatchRoguePhaseData = require("Data.catch_rogue_phase_data")
local Utils = require("Common.Utils.Utils")
local MessageName = require("Const.MessageName")
local HotkeyConst = require("Const.HotkeyConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local TimerManager = require("Core.Timer.TimerManager")
local CaptureConst = require("Common.Const.CaptureConst")
local ItemConst = require("Common.Const.ItemConst")
local CaptureBallPCComponent = Class.LightClass("CaptureBallPCComponent", UIComponent)
local PERFORMED_CATCH_KEY = "Catch/SwitchCatchBall"
local SWITCH_BAR_KEYBOARD_PATH = "Bind/Skill3"
local SWITCH_BAR_KEYBOARD_ACTION_PATH = "Hud/SkillR"
local SWITCH_BAR_GAMEPAD_PATH = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadLeftStickPress
local SWITCH_BALL_ACTION_PATH = "Hud/BallSwitch"
local FOCUS_LONG_PRESS_DELAY = 0.55

CaptureBallPCComponent.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function CaptureBallPCComponent:ctor(ctrl, trans)
	UIComponent.ctor(self, ctrl, trans)
	self:addListener()
end

function CaptureBallPCComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listBtnUList = objectReference:GetRefValue("listBtnUList")
	self.ballBarObjectReference = objectReference:GetRefValue("ballBarObjectReference")
	self.ballPanelUWidget = objectReference:GetRefValue("ballPanelUWidget")
	self.panelSkillUWidget = objectReference:GetRefValue("panelSkillUWidget")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.btnCatchUButton = objectReference:GetRefValue("btnCatchUButton")
	self.btnAimUButton = objectReference:GetRefValue("btnAimUButton")
	self.propOpenUWidget = objectReference:GetRefValue("propOpenUWidget")
	self.propSpecialUWidget = objectReference:GetRefValue("propSpecialUWidget")
	self.paidBallListUList = objectReference:GetRefValue("paidBallListUList")
	self.paidKey = objectReference:GetRefValue("paidKey")
	self.paidTitle = objectReference:GetRefValue("paidTitle")
	self.normalBallKey = objectReference:GetRefValue("normalBallKey")
	self.normalBallTxt = objectReference:GetRefValue("normalBallTxt")
end

function CaptureBallPCComponent:registerObjects()
	local objectReference = self.ballBarObjectReference

	self.nameTxt = objectReference:GetRefValue("nameTxt")
	self.propUWidget = objectReference:GetRefValue("propUWidget")

	local ballRef = self.propUWidget.transform:GetComponent("ObjectReference")

	self.normalBallListUList = ballRef:GetRefValue("loopList")
	self.txtNumCur = ballRef:GetRefValue("txtNumCur")
	self.curBallUSDFText = ballRef:GetRefValue("curBallUSDFText")
end

function CaptureBallPCComponent:addListener()
	self:setOperateBtn()
end

function CaptureBallPCComponent:initView()
	function self.normalBallListUList.luaRenderItem(button, index, data)
		self:setListItemNodeData(button, data, index, CaptureConst.BALL_BAR_TYPE.NORMAL)
	end

	function self.paidBallListUList.luaRenderItem(button, index, data)
		self:setListItemNodeData(button, data, index, CaptureConst.BALL_BAR_TYPE.PAID)
	end

	self.ballSwitchKeyBind = KeyBindingPro.GetOrAddKeyBindingByName(self.transform.gameObject, "BallSwitch")
	self.ballSwitchKeyBind.isVirtual = true
	self.ballSwitchKeyBind.actionPath = SWITCH_BALL_ACTION_PATH

	function self.ballSwitchKeyBind.luaTrigger(inputInfo)
		if inputInfo.phase ~= "Performed" or pg.me:isInBossCatch() then
			return
		end

		local dir = inputInfo.valueVec2.y > 0 and -1 or 1
		local switchedIndex = self:_handleBallScrollSwitch(dir)

		if switchedIndex > 0 then
			pg.game.audio:triggerEvent("SFX_UI_HUD_ItemMenu_Choose")
		end
	end

	self.ctrl:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadDPadLeft, function()
		if pg.me:isInBossCatch() then
			return true
		end

		local switchedIndex = self:switchPreItem()

		if switchedIndex > 0 then
			pg.game.audio:triggerEvent("SFX_UI_HUD_ItemMenu_Choose")
		end

		return switchedIndex > 0
	end, self.transform.gameObject)
	self.ctrl:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadDPadRight, function()
		if pg.me:isInBossCatch() then
			return true
		end

		local switchedIndex = self:switchNextItem()

		if switchedIndex > 0 then
			pg.game.audio:triggerEvent("SFX_UI_HUD_ItemMenu_Choose")
		end

		return switchedIndex > 0
	end, self.transform.gameObject)
	self:_bindSwitchBarHotkeys()

	local catchBind = KeyBindingPro.GetOrAddKeyBindingByName(self.ctrl.view.widget.gameObject, "catchBind")

	catchBind.isVirtual = true
	catchBind.actionPath = "Catch/SwitchCatchMode"

	function catchBind.luaTrigger(inputInfo)
		self:handleSwitchCatchModeInput(inputInfo)
	end

	local catchFocusBind = KeyBindingPro.GetOrAddKeyBindingByName(self.ctrl.view.widget.gameObject, "catchFocusBind")

	catchFocusBind.isVirtual = true
	catchFocusBind.actionPath = "Catch/Focus"

	function catchFocusBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:_clearFocusLongPressTimer()

			self._focusLongPressTimer = TimerManager.addTimer(FOCUS_LONG_PRESS_DELAY, function()
				self._focusLongPressTimer = nil

				self:handleFocusCancelAction()
			end)
		elseif inputInfo.phase == "Canceled" and self._focusLongPressTimer then
			self:_clearFocusLongPressTimer()
			self:handleFocusAction()
		end
	end

	self:refreshInfo()
end

function CaptureBallPCComponent:_bindSwitchBarHotkeys()
	self.ctrl:bindHotKeyPerform(SWITCH_BAR_KEYBOARD_ACTION_PATH, function()
		return self:handleSwitchBarAction()
	end, self.transform.gameObject)
	self.ctrl:bindHotKeyPerform(SWITCH_BAR_GAMEPAD_PATH, function()
		return self:handleSwitchBarAction()
	end, self.transform.gameObject)
end

function CaptureBallPCComponent:renderOperateBtn(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local btnNormalKeyBindingPro = objectReference:GetRefValue("btnNormalKeyBindingPro")
	local keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")
	local specialUButton = objectReference:GetRefValue("specialUButton")
	local countDown = objectReference:GetRefValue("countDown")

	if txtNameUText then
		ClientTextUtils.setText(txtNameUText, data.name)
	end

	if iconUImage then
		iconUImage.url = data.icon
	end

	if idx == 1 then
		self.cancelBtnTxt = txtNameUText
		self.cancelKeyBindingPro = btnNormalKeyBindingPro
		btnNormalKeyBindingPro.actionPath = "Catch/SwitchCatchMode"
		btnNormalKeyBindingPro.isVirtual = true

		function btnNormalKeyBindingPro.luaTrigger(inputInfo)
			self:handleSwitchCatchModeInput(inputInfo)
		end

		self:refreshCancelHotKeyVisible()

		function button.luaClick()
			self:handleSwitchCatchModeAction()
		end
	elseif idx == 2 then
		self.focusBtn = button

		function button.luaClick()
			self:handleFocusAction()
		end

		function button.luaLongPress(pressTime)
			self:handleFocusCancelAction()
		end

		local focusKeyBind = btnNormalKeyBindingPro

		if focusKeyBind and focusKeyBind.keyBoardContent then
			focusKeyBind.keyBoardContent:SetHotKeyPaths("Catch/Focus")
		end
	elseif idx == 3 then
		self.catchBtnTxt = txtNameUText
		btnNormalKeyBindingPro.actionPath = "Catch/Throw"
		btnNormalKeyBindingPro.isVirtual = true

		function btnNormalKeyBindingPro.luaTrigger(inputInfo)
			if inputInfo.phase == "Performed" then
				self:handleContinuousCatchAction(true)
			elseif inputInfo.phase == "Canceled" then
				self:handleContinuousCatchAction(false)
			end
		end

		function button.luaClick()
			self:handleCatchAction()
		end
	end
end

function CaptureBallPCComponent:getOperateData()
	local ret = {}

	ret[#ret + 1] = {
		name = pg.getGameString("CANCEL_CATCH_MODE"),
		icon = AddressDataConst.UI_ICON_CATCH_CANCEL,
		btn = self.btnCloseUButton
	}
	ret[#ret + 1] = {
		name = pg.getGameString("FOCUS"),
		icon = AddressDataConst.UI_ICON_CATCH_AIM,
		btn = self.btnAimUButton
	}
	ret[#ret + 1] = {
		name = pg.getGameString("CATCH"),
		icon = AddressDataConst.UI_ICON_CATCH_THROW,
		btn = self.btnCatchUButton
	}

	return ret
end

function CaptureBallPCComponent:setOperateBtn()
	local datas = self:getOperateData()

	for i = 1, #datas do
		self:renderOperateBtn(datas[i].btn, i, datas[i])
	end
end

function CaptureBallPCComponent:refreshCancelHotKeyVisible()
	if self.cancelKeyBindingPro then
		local hideCancelHotKey = pg.game.input:isUsingGamepad() and pg.game.setting:getHoldToEnterCatchMode()

		self.cancelKeyBindingPro.gameObject:SetActiveEx(not hideCancelHotKey)
	end
end

function CaptureBallPCComponent:onDestroy()
	self._isDestroyed = true

	self:_stopContinuousThrowInput()
	self:_clearFocusLongPressTimer()
	UIComponent.onDestroy(self)
end

function CaptureBallPCComponent:onShow()
	self:refreshBallVisuals()
	self:refreshCancelHotKeyVisible()
end

function CaptureBallPCComponent:onHide()
	self:_stopContinuousThrowInput()
	self:_clearFocusLongPressTimer()
end

function CaptureBallPCComponent:handleFocusAction()
	if pg.game.controller == nil then
		return
	end

	if pg.game.input:isUsingGamepad() and not pg.me:isInCatchMode() then
		return
	end

	pg.global.eventEmitter:emit(EventConst.LOCK_ENITY_MSG, "switch", self)
end

function CaptureBallPCComponent:handleFocusCancelAction()
	if pg.me:isInCatchMode() and pg.game.controller and pg.game.controller.lockHelper.forceLockActorId ~= 0 then
		pg.global.eventEmitter:emit(EventConst.LOCK_ENITY_MSG, "cancel", self)
	end
end

function CaptureBallPCComponent:_clearFocusLongPressTimer()
	if self._focusLongPressTimer then
		TimerManager.removeTimer(self._focusLongPressTimer)

		self._focusLongPressTimer = nil
	end
end

function CaptureBallPCComponent:handleSwitchCatchModeInput(inputInfo)
	local useGamepadHold = pg.game.input:isUsingGamepad() and pg.game.setting:getHoldToEnterCatchMode()

	if useGamepadHold then
		if inputInfo.phase == "Performed" then
			self:handleSwitchCatchModeAction(true)
		elseif inputInfo.phase == "Canceled" then
			self:handleSwitchCatchModeAction(false)
		end
	elseif inputInfo.phase == "Performed" then
		self:handleSwitchCatchModeAction()
	end
end

function CaptureBallPCComponent:handleSwitchCatchModeAction(enable)
	if pg.me == nil or pg.me.space == nil then
		return
	end

	if pg.me.space:isRogueEnv() then
		return
	end

	local controller = pg.game.controller

	controller:onHandleSwitchCatchMode(enable)
end

function CaptureBallPCComponent:handleCatchAction()
	local controller = pg.game.controller

	if controller ~= nil then
		controller:onHandleThrow()
	end
end

function CaptureBallPCComponent:handleContinuousCatchAction(isStart)
	local controller = pg.game.controller

	if controller ~= nil then
		controller:onHandleContinuousThrow(isStart)
	end
end

function CaptureBallPCComponent:_stopContinuousThrowInput()
	local controller = pg.game.controller

	if controller ~= nil then
		controller:onHandleContinuousThrow(false)
	end
end

function CaptureBallPCComponent:onFocusChanged(focus)
	return
end

function CaptureBallPCComponent:setListItemNodeData(itemNode, itemInfo, index, barType)
	local orc = itemNode:GetComponent("ObjectReference")
	local itemIcon = orc:GetRefValue("itemIcon")
	local iNumb = orc:GetRefValue("num")
	local exclusiveUWidget = orc:GetRefValue("exclusiveUWidget")

	if not itemInfo or itemInfo.empty then
		itemNode:TryChangePage("PC_NULL", 1)

		itemNode.luaClick = nil

		return
	end

	itemNode:TryChangePage("PC_NULL", 0)

	if itemInfo and itemInfo.itemId then
		itemIcon.url = LuaUIUtils.getIconByItemId(itemInfo.itemId)

		local count = ClientUtils.getItemCountById(itemInfo.itemId)

		ClientTextUtils.setText(iNumb, count)

		if Utils.isPlayerInSpaceCatchRogueDungeon(pg.me) then
			local curGameId = pg.me:getCatchRogueCurGameId()
			local gameBallItemIds = curGameId and CatchRoguePhaseData[curGameId].gameBallType

			exclusiveUWidget:SetActive(gameBallItemIds and table.contains(gameBallItemIds, itemInfo.itemId) or false)
		else
			exclusiveUWidget:SetActive(false)
		end

		function itemNode.luaClick()
			self:_selectBallItemByClick((index or 0) + 1, barType)
		end
	else
		itemNode.luaClick = nil
	end
end

function CaptureBallPCComponent:_selectBallItemByClick(itemIndex, barType)
	local itemList = self.ctrl:getItemList(barType)
	local item = itemList and itemList[itemIndex]

	if not item or ClientUtils.getItemCountById(item.itemId) <= 0 then
		return 0
	end

	local switchedIndex = self.ctrl:selectItem(itemIndex, barType)

	if switchedIndex > 0 then
		pg.game.audio:triggerEvent("SFX_UI_HUD_ItemMenu_Choose")
	end

	return switchedIndex
end

function CaptureBallPCComponent:setItemNodeData(itemInfo)
	if not itemInfo then
		ClientTextUtils.setText(self.txtNumCur, 0)
		ClientTextUtils.setText(self.curBallUSDFText, "")

		return
	end

	ClientTextUtils.setText(self.txtNumCur, ClientUtils.getItemCountById(itemInfo.itemId))
	ClientTextUtils.setText(self.curBallUSDFText, pg.getLocalizationText(itemInfo.name))
end

function CaptureBallPCComponent:_findNextEnabledIndex(fromIndex, dir)
	local barType = self.ctrl:getActiveBar()
	local itemList = self.ctrl:getItemList(barType)
	local count = #itemList

	if count <= 1 or fromIndex <= 0 then
		return 0
	end

	for offset = 1, count - 1 do
		local index = (fromIndex - 1 + dir * offset) % count + 1
		local item = itemList[index]

		if item and ClientUtils.getItemCountById(item.itemId) > 0 then
			return index
		end
	end

	return 0
end

function CaptureBallPCComponent:_switchItem(dir)
	local targetIndex = self:_findNextEnabledIndex(self.ctrl:getCurIndex(), dir)

	if targetIndex <= 0 then
		return 0
	end

	return self.ctrl:selectItem(targetIndex, self.ctrl:getActiveBar())
end

function CaptureBallPCComponent:_handleBallScrollSwitch(dir)
	local activeBar = self.ctrl:getActiveBar()
	local itemList = self.ctrl:getItemList(activeBar)

	if #itemList == 1 then
		local list = activeBar == CaptureConst.BALL_BAR_TYPE.PAID and self.paidBallListUList or self.normalBallListUList
		local found, itemNode = list:TryGetChildAt(0)

		if found and itemNode then
			itemNode:InvokeCallback(CS.XGUI.EInvokeTime.User1)
		end

		return 0
	end

	if dir < 0 then
		return self:switchPreItem()
	end

	return self:switchNextItem()
end

function CaptureBallPCComponent:switchPreItem()
	return self:_switchItem(-1)
end

function CaptureBallPCComponent:switchNextItem()
	return self:_switchItem(1)
end

function CaptureBallPCComponent:handleSwitchBarAction()
	if pg.me:isInBossCatch() then
		return false
	end

	local switched = self.ctrl:switchActiveBar()

	if switched then
		pg.game.audio:triggerEvent("SFX_UI_HUD_ItemMenu_Choose")
	end

	return switched
end

function CaptureBallPCComponent:_setBarHotkey(keyBinding, active, itemCount)
	local visible = itemCount > 0 and (not active or not (itemCount <= 1))

	LuaUIUtils.setUIVisible(keyBinding, visible)

	if not visible then
		return
	end

	local content = keyBinding.keyBoardContent
	local objRef = keyBinding.transform:GetComponent("ObjectReference")
	local btnTipsUText = objRef:GetRefValue("btnTipsUText")

	if pg.game.input:isUsingGamepad() then
		if active then
			content:SetHotKeyRawText("<sprite name=UI_KeyCrossLeftRightBg_Xbox>")
		else
			content:SetHotKeyPaths(SWITCH_BAR_GAMEPAD_PATH)
		end
	elseif active then
		content:SetHotKeyPaths(PERFORMED_CATCH_KEY)
	else
		content:SetHotKeyPaths(SWITCH_BAR_KEYBOARD_PATH)
	end

	ClientTextUtils.setText(btnTipsUText, active and pg.getGameString("CATCH_HUD_SWITCH_CATCHBALL") or pg.getGameString("CATCH_HUD_SWITCH_CATCHSLOT"))
end

function CaptureBallPCComponent:refreshBarHotkeys()
	local activeBar = self.ctrl:getActiveBar()

	self:_setBarHotkey(self.normalBallKey, activeBar == CaptureConst.BALL_BAR_TYPE.NORMAL, #self.ctrl:getItemList(CaptureConst.BALL_BAR_TYPE.NORMAL))
	self:_setBarHotkey(self.paidKey, activeBar == CaptureConst.BALL_BAR_TYPE.PAID, #self.ctrl:getItemList(CaptureConst.BALL_BAR_TYPE.PAID))
end

function CaptureBallPCComponent:onInputDeviceChanged(deviceType)
	self:_stopContinuousThrowInput()
	self:refreshBarHotkeys()
	self:refreshCancelHotKeyVisible()
end

function CaptureBallPCComponent:refreshItemList()
	self.ctrl:refreshItemList()
end

function CaptureBallPCComponent:selectItem(itemIndex)
	return self.ctrl:selectItem(itemIndex)
end

function CaptureBallPCComponent:refreshInfo()
	self:refreshBallVisuals()
end

function CaptureBallPCComponent:refreshOpenState()
	self:refreshBallVisuals()
end

function CaptureBallPCComponent:refreshSelectItem()
	self:refreshBallVisuals()
end

function CaptureBallPCComponent:refreshSelectItemData(item)
	self:refreshBallVisuals()
end

function CaptureBallPCComponent._findItemIndex(itemList, selectedItem)
	if not selectedItem then
		return 0
	end

	for index, item in ipairs(itemList or EMPTY_TABLE) do
		if item.itemId == selectedItem.itemId then
			return index
		end
	end

	return 0
end

function CaptureBallPCComponent:_refreshListSelection(list, itemList, selectedItem, isActive)
	list:DeselectAll()

	if not isActive then
		return
	end

	local index = CaptureBallPCComponent._findItemIndex(itemList, selectedItem)

	if index > 0 then
		list:GoToIndexMinCost(index - 1)
	end
end

function CaptureBallPCComponent:_setBarTitle(titleText, itemInfo, isActive)
	if IsNil(titleText) then
		return
	end

	local visible = isActive and itemInfo ~= nil

	titleText:SetActive(visible)
	ClientTextUtils.setText(titleText, visible and pg.getLocalizationText(itemInfo.name) or "")
end

function CaptureBallPCComponent:_setPaidTitle(itemInfo, isActive)
	self:_setBarTitle(self.paidTitle, itemInfo, isActive)
end

function CaptureBallPCComponent:_setNormalTitle(itemInfo, isActive)
	self:_setBarTitle(self.normalBallTxt, itemInfo, isActive)
end

function CaptureBallPCComponent:_refreshBallPanelBackground(itemInfo, visible)
	return
end

function CaptureBallPCComponent:_refreshBallPanelVisible(state)
	local visible = not self._isThrowItemMode

	self.propOpenUWidget:SetActive(visible and #state.normalList > 0)
	self.propSpecialUWidget:SetActive(visible and #state.paidList > 0)
	self:_refreshBallPanelBackground(self.ctrl.curSelectCastItem, visible)
end

function CaptureBallPCComponent:refreshBallVisuals()
	local state = self.ctrl:getBarViewState()
	local normalActive = state.activeBar == CaptureConst.BALL_BAR_TYPE.NORMAL
	local paidActive = state.activeBar == CaptureConst.BALL_BAR_TYPE.PAID

	self.normalBallListUList:SetList(state.normalList)
	self.paidBallListUList:SetList(state.paidList)
	self:_refreshListSelection(self.normalBallListUList, state.normalList, state.normalSelectedItem, normalActive)
	self:_refreshListSelection(self.paidBallListUList, state.paidList, state.paidSelectedItem, paidActive)
	self.propOpenUWidget:TryChangePage("State", normalActive and 1 or 0)
	self.propSpecialUWidget:TryChangePage("State", paidActive and 1 or 0)
	self.propOpenUWidget:TryChangePage("Quantity", #state.normalList == 1 and 0 or 1)
	self.propSpecialUWidget:TryChangePage("Quantity", #state.paidList == 1 and 0 or 1)
	self:setItemNodeData(state.normalSelectedItem)
	self:_setNormalTitle(state.normalSelectedItem, normalActive)
	self:_setPaidTitle(state.paidSelectedItem, paidActive)
	self:_refreshBallPanelVisible(state)
	self:refreshBarHotkeys()
end

function CaptureBallPCComponent:onThrowItemMode(isThrow)
	self._isThrowItemMode = isThrow

	LuaUIUtils.setUIViewVisible(self.ballPanelUWidget.transform, not isThrow)
	self:_refreshBallPanelVisible(self.ctrl:getBarViewState())

	if self.focusBtn then
		self.focusBtn.ignoreLayout = isThrow

		LuaUIUtils.setUIViewVisible(self.focusBtn, not isThrow)
	end

	if self.cancelBtnTxt then
		ClientTextUtils.setText(self.cancelBtnTxt, isThrow and pg.getGameString("CANCEL_THROW_MODE") or pg.getGameString("CANCEL_CATCH_MODE"))
	end

	if self.catchBtnTxt then
		ClientTextUtils.setText(self.catchBtnTxt, isThrow and pg.getGameString("THROW") or pg.getGameString("CATCH"))
	end
end

return CaptureBallPCComponent
