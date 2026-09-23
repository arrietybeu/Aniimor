-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CaptureBall\\Component\\CaptureBallMobileComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local CallbackHandler = require("Core.Common.CallbackHandler")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local ClientTextUtils = require("Utils.ClientTextUtils")
local EventConst = require("Const.EventConst")
local CaptureConst = require("Common.Const.CaptureConst")
local ItemConst = require("Common.Const.ItemConst")
local CaptureBallMobileComponent = Class.LightClass("CaptureBallMobileComponent", UIComponent)
local NORMAL_THROW_GESTURE_STATE = {
	PENDING = 1,
	IDLE = 0,
	AIMING = 3,
	ENTERING_AIM = 2
}

CaptureBallMobileComponent.messages = {
	[MessageName.APP_FOCUS_CHANGED] = {
		"onAppFocusChanged",
		true
	}
}

function CaptureBallMobileComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnThrow = objectReference:GetRefValue("btnThrow")
	self.catchJoystick = objectReference:GetRefValue("catchJoystick")
	self.btnThrowLeft = objectReference:GetRefValue("btnThrowLeft")
	self.btnCancelThrow = objectReference:GetRefValue("btnCancelThrow")
	self.rootWidget = objectReference:GetRefValue("rootWidget")
	self.ballPanelUWidget = objectReference:GetRefValue("ballPanelUWidget")
	self.ballPanelUList = objectReference:GetRefValue("ballPanelUList")
	self.panelCatchAni = objectReference:GetRefValue("rootAnimation")
	self.ballPanelSpecialUWidget = objectReference:GetRefValue("ballPanelSpecialUWidget")
	self.paidBallList = objectReference:GetRefValue("paidBallList")
	self.btnContinuousCaptureUWidget = objectReference:GetRefValue("btnContinuousCaptureUWidget")
	self.btnContinuousCatch = objectReference:GetRefValue("btnContinuousCatch")
	self.joyStickContinuousCatch = objectReference:GetRefValue("joyStickContinuousCatch")
	self.lockPanelUComponent = objectReference:GetRefValue("lockPanelUComponent")

	local lockPanelObjectReference = self.lockPanelUComponent:GetComponent("ObjectReference")

	self.btnAimUButton = lockPanelObjectReference:GetRefValue("btnAimUButton")
	self.btnSwitchUButton = lockPanelObjectReference:GetRefValue("btnSwitchUButton")
	self.btnCancelUButton = lockPanelObjectReference:GetRefValue("btnCancelUButton")
	self.isInCancelMode = false
	self._checkEdgeToastTicker = nil
	self.selectedItemId = 0
	self._isThrowItemMode = false
	self._isFastThrowMode = false
	self._normalThrowGestureState = NORMAL_THROW_GESTURE_STATE.IDLE
end

function CaptureBallMobileComponent:initView()
	if self.ctrl.curSelectCastItem then
		self.selectedItemId = self.ctrl.curSelectCastItem.itemId
	end

	self.rootWidget:TryChangePage("BtnShow", 2)
	self:initCatchPanel()
	self:_refreshLockPanelVisible()
	self:_syncLockStateFromCamera()

	self._checkEdgeToastTicker = self:startTimer(CallbackHandler(self, "checkEdgeToast"), 0.1, true)

	self:refreshBallPanelList()
	self:refreshThrowLeftVisible()
end

function CaptureBallMobileComponent:onShow()
	self.rootWidget:TryChangePage("BtnShow", 2)
	self.rootWidget:InvokeCallback(CS.XGUI.EInvokeTime.Show)
	self:_refreshLockPanelVisible()
	self:_syncLockStateFromCamera()
end

function CaptureBallMobileComponent:_setCaptureAimCameraDragMuted(muted)
	local mobileOperateCtrl = pg.global.ui:tryGetCtrlByUid(UIConst.UI_ID_HUD_MOBILE_OPERATE)
	local moveJoyStick = mobileOperateCtrl and mobileOperateCtrl.moveJoyStick

	if moveJoyStick and moveJoyStick.setCaptureAimCameraDragMuted then
		moveJoyStick:setCaptureAimCameraDragMuted(muted)
	end
end

function CaptureBallMobileComponent:_refreshCaptureAimCameraDragMute()
	local normalThrowActive = self._normalThrowGestureState ~= NORMAL_THROW_GESTURE_STATE.IDLE

	self:_setCaptureAimCameraDragMuted(normalThrowActive or self._continuousThrowPressed == true)
end

function CaptureBallMobileComponent:_resetContinuousThrowInputState()
	self._continuousThrowPressed = false

	self.rootWidget:TryChangePage("PressExpand", 0)
	self.btnContinuousCatch:TryChangePage("expand", 0)
	pg.game.input:setViewAxisByDelta(0, 0)
	self:_refreshCaptureAimCameraDragMute()
end

function CaptureBallMobileComponent:_stopContinuousThrowInput()
	self:_resetContinuousThrowInputState()

	local controller = pg.game.controller

	if controller and controller.onHandleContinuousThrow then
		controller:onHandleContinuousThrow(false)
	end
end

function CaptureBallMobileComponent:setCancelMode(isInCancelMode)
	self.isInCancelMode = isInCancelMode

	local cancelState = isInCancelMode and 1 or 0

	if isInCancelMode then
		pg.game.input:setViewAxisByDelta(0, 0)
	end

	self.uWidget:TryChangePage("CancelMode", cancelState)
end

function CaptureBallMobileComponent:_cancelThrowInput()
	self._normalThrowGestureState = NORMAL_THROW_GESTURE_STATE.IDLE

	self:_stopContinuousThrowInput()
	self:setCancelMode(false)
	self.uWidget:TryChangePage("expand", 0)

	self.catchJoystick.defaultOpacity = 0

	pg.game.input:setViewAxisByDelta(0, 0)
end

function CaptureBallMobileComponent:throwBall()
	if not pg.game.isFocused then
		self:_cancelThrowInput()

		return
	end

	if pg.game.controller ~= nil then
		pg.game.controller:onHandleThrow()
	end
end

function CaptureBallMobileComponent:_selectBallItem(index, barType)
	local itemList = self.ctrl:getItemList(barType)
	local item = itemList[index]

	if not item or ClientUtils.getItemCountById(item.itemId) <= 0 then
		return 0
	end

	local selectedIndex = self.ctrl:selectItem(index, barType)

	if selectedIndex > 0 and self._continuousThrowPressed then
		self:_resetContinuousThrowInputState()
	end

	return selectedIndex
end

function CaptureBallMobileComponent:_renderBallItem(list, button, index, data, barType)
	button:TryChangePage("Empty", data.itemId == -1 and 1 or 0)

	if data.itemId == -1 then
		button.luaClick = nil

		button:TryChangePage("State", 0)

		return
	end

	local icon = button:Find("Btn/Icon"):GetComponent("UImage")
	local count = button:Find("Btn/NumCount"):GetComponent("UBaseText")

	icon.url = LuaUIUtils.getIconByItemId(data.itemId)

	ClientTextUtils.setText(count, ClientUtils.getItemCountById(data.itemId))

	local selectedItem = self.ctrl:getSelectItem(barType)
	local selected = self.ctrl:getActiveBar() == barType and selectedItem and selectedItem.itemId == data.itemId

	button:TryChangePage("State", selected and 1 or 0)

	function button.luaClick()
		self:_selectBallItem(index + 1, barType)
	end
end

function CaptureBallMobileComponent:_refreshBallPanelBackground(itemInfo, visible)
	return
end

function CaptureBallMobileComponent:_refreshListSelection(list, itemList, selectedItem, isActive)
	list:DeselectAll()

	if not isActive or not selectedItem then
		return
	end

	for index, item in ipairs(itemList or EMPTY_TABLE) do
		if item.itemId == selectedItem.itemId then
			list:GoToIndexMinCost(index - 1)

			return
		end
	end
end

function CaptureBallMobileComponent:_refreshBallPanelVisible(state)
	local _, expandPage = self.uWidget:TryGetCurrentPage("expand")
	local visible = not self._isThrowItemMode and expandPage ~= 1

	self.ballPanelUWidget:SetActive(visible and #state.normalList > 0)
	self.ballPanelSpecialUWidget:SetActive(visible and #state.paidList > 0)
	self:_refreshBallPanelBackground(self.ctrl.curSelectCastItem, visible)
end

function CaptureBallMobileComponent:_refreshBarSelectedState(state)
	local normalActive = state.activeBar == CaptureConst.BALL_BAR_TYPE.NORMAL
	local paidActive = state.activeBar == CaptureConst.BALL_BAR_TYPE.PAID

	self.ballPanelUWidget:TryChangePage("State", normalActive and 1 or 0)
	self.ballPanelSpecialUWidget:TryChangePage("State", paidActive and 1 or 0)
end

function CaptureBallMobileComponent:refreshBallPanelList()
	local state = self.ctrl:getBarViewState()

	self.ballPanelUList:SetList(state.normalList)
	self.paidBallList:SetList(state.paidList)
	self:_refreshListSelection(self.ballPanelUList, state.normalList, state.normalSelectedItem, state.activeBar == CaptureConst.BALL_BAR_TYPE.NORMAL)
	self:_refreshListSelection(self.paidBallList, state.paidList, state.paidSelectedItem, state.activeBar == CaptureConst.BALL_BAR_TYPE.PAID)
	self:_refreshBallPanelVisible(state)
	self:_refreshBarSelectedState(state)
end

function CaptureBallMobileComponent:getCurSelectPropId()
	return self.selectedItemId ~= 0 and self.selectedItemId or nil
end

function CaptureBallMobileComponent:refreshSelectItemData(item)
	self.selectedItemId = item and item.itemId or 0

	self:refreshBallPanelList()
	self:refreshThrowLeftVisible()
end

function CaptureBallMobileComponent:refreshThrowLeftVisible()
	if IsNil(self.btnThrowLeft) then
		return
	end

	local isBigBall = ClientCaptureUtils.isBigBall(self.selectedItemId)

	LuaUIUtils.setUIViewVisible(self.btnThrowLeft, not self._isFastThrowMode and not isBigBall)
end

function CaptureBallMobileComponent:checkEdgeToast()
	if not self:checkPanelCatchLoaded() then
		return
	end

	local visible = not pg.global.ui.tips:isEdgeRunning({
		UIConst.UITipPriority.Edge_Quest
	}) and not pg.global.ui:checkUIShow(UIConst.UI_ID_PET_FIRST_SHOW)

	self.uWidget:TryChangePage("BtnLeft_State", visible and 0 or 1)
end

function CaptureBallMobileComponent:_enterNormalThrowAim()
	if self._normalThrowGestureState ~= NORMAL_THROW_GESTURE_STATE.PENDING then
		return
	end

	self._normalThrowGestureState = NORMAL_THROW_GESTURE_STATE.ENTERING_AIM

	self.uWidget:TryChangePage("expand", 1)

	if self._normalThrowGestureState == NORMAL_THROW_GESTURE_STATE.ENTERING_AIM then
		self._normalThrowGestureState = NORMAL_THROW_GESTURE_STATE.AIMING
	end
end

function CaptureBallMobileComponent:initCatchPanel()
	if not self:checkPanelCatchLoaded() then
		return
	end

	self.rootWidget:TryChangePage("PressExpand", 0)

	local function switchLockTarget()
		self:_emitLockEntityMsg("switch")
	end

	self.btnAimUButton.luaClick = switchLockTarget
	self.btnSwitchUButton.luaClick = switchLockTarget

	function self.btnCancelUButton.luaClick()
		self:_emitLockEntityMsg("cancel")
	end

	function self.btnCancelThrow.luaClick()
		if self:checkCatchMode() then
			UIUtils.PlayAnimation(self.panelCatchAni, "VX_Node_BattleUI_PanelCatch_Mobile_Out", function()
				pg.game.controller:onHandleSwitchCatchMode()
			end)
		end
	end

	function self.btnCancelThrow.luaHover()
		self:setCancelMode(true)
	end

	function self.btnCancelThrow.luaUnhover()
		self:setCancelMode(false)
	end

	function self.btnCancelThrow.luaRelease()
		self._normalThrowGestureState = NORMAL_THROW_GESTURE_STATE.IDLE

		self:_refreshCaptureAimCameraDragMute()
		self:setCancelMode(false)
		self.uWidget:TryChangePage("expand", 0)

		self.catchJoystick.defaultOpacity = 0

		pg.game.input:setViewAxisByDelta(0, 0)
	end

	function self.btnThrowLeft.luaClick()
		self:throwBall()
	end

	function self.btnThrow.luaPress()
		self._normalThrowGestureState = NORMAL_THROW_GESTURE_STATE.PENDING

		self:_refreshCaptureAimCameraDragMute()

		self.catchJoystick.defaultOpacity = 1

		self:setCancelMode(false)
	end

	function self.btnThrow.luaRelease()
		if self._normalThrowGestureState == NORMAL_THROW_GESTURE_STATE.ENTERING_AIM then
			return
		end

		if self._normalThrowGestureState ~= NORMAL_THROW_GESTURE_STATE.IDLE and not self.catchJoystick.isDragging then
			self._normalThrowGestureState = NORMAL_THROW_GESTURE_STATE.IDLE

			self:_refreshCaptureAimCameraDragMute()
			self.uWidget:TryChangePage("expand", 0)

			self.catchJoystick.defaultOpacity = 0

			self:throwBall()
		end
	end

	function self.btnThrow.luaBeginLongPress()
		self:_enterNormalThrowAim()
	end

	function self.catchJoystick.luaValueChanged(x, y)
		if x ~= 0 or y ~= 0 then
			self:_enterNormalThrowAim()
		end
	end

	function self.catchJoystick.luaDragUpdate(x, y)
		local ret, page = self.uWidget:TryGetCurrentPage("expand")

		if page == 1 and not self.isInCancelMode then
			pg.game.input:setViewAxisByDeltaPixel(x, y)
		end
	end

	function self.catchJoystick.luaJoyStickEndDrag()
		if self._normalThrowGestureState == NORMAL_THROW_GESTURE_STATE.ENTERING_AIM then
			return
		end

		local shouldThrow = self._normalThrowGestureState ~= NORMAL_THROW_GESTURE_STATE.IDLE and not self.isInCancelMode

		self._normalThrowGestureState = NORMAL_THROW_GESTURE_STATE.IDLE

		self:_refreshCaptureAimCameraDragMute()
		self.uWidget:TryChangePage("expand", 0)

		self.catchJoystick.defaultOpacity = 0

		if shouldThrow then
			self:throwBall()
		end

		pg.game.input:setViewAxisByDelta(0, 0)
		self:setCancelMode(false)
	end

	function self.btnContinuousCatch.luaPress()
		self._continuousThrowPressed = true

		self:_refreshCaptureAimCameraDragMute()
		self.rootWidget:TryChangePage("PressExpand", 1)
		self.btnContinuousCatch:TryChangePage("expand", 1)

		local controller = pg.game.controller

		if controller then
			controller:onHandleContinuousThrow(true)
		end
	end

	function self.btnContinuousCatch.luaRelease()
		if not self.joyStickContinuousCatch.isDragging then
			self:_stopContinuousThrowInput()
		end
	end

	function self.joyStickContinuousCatch.luaDragUpdate(x, y)
		if self._continuousThrowPressed then
			pg.game.input:setViewAxisByDeltaPixel(x, y)
		end
	end

	function self.joyStickContinuousCatch.luaJoyStickEndDrag()
		self:_stopContinuousThrowInput()
	end

	function self.ballPanelUList.luaRenderItem(button, index, data)
		self:_renderBallItem(self.ballPanelUList, button, index, data, CaptureConst.BALL_BAR_TYPE.NORMAL)
	end

	function self.paidBallList.luaRenderItem(button, index, data)
		self:_renderBallItem(self.paidBallList, button, index, data, CaptureConst.BALL_BAR_TYPE.PAID)
	end
end

function CaptureBallMobileComponent:onAppFocusChanged()
	if pg.game.isFocused then
		return
	end

	self:_cancelThrowInput()
end

function CaptureBallMobileComponent:checkPanelCatchLoaded()
	return not IsNil(self.uWidget)
end

function CaptureBallMobileComponent:checkCatchMode()
	return pg.me and pg.me:isInCatchMode()
end

function CaptureBallMobileComponent:_emitLockEntityMsg(msg)
	if not self:checkCatchMode() or self._isThrowItemMode then
		return
	end

	if pg.game.controller == nil then
		return
	end

	pg.global.eventEmitter:emit(EventConst.LOCK_ENITY_MSG, msg, self)
end

function CaptureBallMobileComponent:onCatchLockPuppetMsg(isLock)
	if IsNil(self.lockPanelUComponent) then
		return
	end

	self.lockPanelUComponent:TryChangePage("expand", isLock and 1 or 0)
end

function CaptureBallMobileComponent:_syncLockStateFromCamera()
	local playerCameraMode = pg.game.camera and pg.game.camera.playerCameraMode
	local catchCamera = playerCameraMode and playerCameraMode.catchCamera

	self:onCatchLockPuppetMsg(catchCamera ~= nil and catchCamera.target ~= nil)
end

function CaptureBallMobileComponent:_refreshLockPanelVisible()
	if IsNil(self.lockPanelUComponent) then
		return
	end

	local visible = not self._isThrowItemMode

	LuaUIUtils.setUIViewVisible(self.lockPanelUComponent, visible)
end

function CaptureBallMobileComponent:onThrowItemMode(isThrow)
	self._isThrowItemMode = isThrow

	self:_refreshBallPanelVisible(self.ctrl:getBarViewState())
	self:_refreshLockPanelVisible()
end

function CaptureBallMobileComponent:setFastThrowMode(enable)
	self._isFastThrowMode = enable

	self:_refreshBallPanelVisible(self.ctrl:getBarViewState())
	self:_refreshLockPanelVisible()
	LuaUIUtils.setUIViewVisible(self.btnThrow, not enable)
	LuaUIUtils.setUIViewVisible(self.btnThrowLeft, not enable)
	LuaUIUtils.setUIViewVisible(self.btnCancelThrow, not enable)
	LuaUIUtils.setUIViewVisible(self.btnContinuousCaptureUWidget, not enable)

	if not enable then
		self:refreshThrowLeftVisible()
	end
end

function CaptureBallMobileComponent:onHide()
	self:_cancelThrowInput()
end

function CaptureBallMobileComponent:onDestroy()
	self:_cancelThrowInput()
	UIComponent.onDestroy(self)

	if self._checkEdgeToastTicker then
		self:killTimer(self._checkEdgeToastTicker)

		self._checkEdgeToastTicker = nil
	end
end

return CaptureBallMobileComponent
