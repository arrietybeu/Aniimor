-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\BallBtnComponent.lua

local Class = require("Core.Framework.Class")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local MessageName = require("Const.MessageName")
local ClientConst = require("Const.ClientConst")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local ClientUtils = require("Utils.ClientUtils")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local catch_config_data = require("Data.catch_config_data")
local HudSplicingCfg = require("Guis.Panels.HudV2.HudSplicingCfg")
local Time = require("Core.Common.Time")
local SceneData = require("Data.scene_data")
local BallBtnComponent = Class.LightClass("BallBtnComponent", HudBaseComponent)

BallBtnComponent.HUD_SKILL_HIDE_REASON_FAST_THROW = "fastThrow"
BallBtnComponent.CAPTURE_ENTRY_STATE = {
	IDLE = 0,
	FINISHING = 4,
	FAST_DRAGGING = 3,
	FAST_AIM = 2,
	PENDING = 1
}
BallBtnComponent.FAST_THROW_DRAG_THRESHOLD = 0.2
BallBtnComponent.FAST_THROW_READY_TIMEOUT = 2
BallBtnComponent.messages = {
	[MessageName.CATCH_MODE_CHANGE_UI] = {
		"onCatchModeChange",
		true
	},
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"refreshInfo",
		true
	},
	[MessageName.ON_NOTIFY_ITEM] = {
		"refreshInfo",
		true
	},
	[MessageName.ON_BACKPACK_QUICK_BALL_CHANGE] = {
		"onQuickBallChange",
		true
	},
	[MessageName.MODULE_ENABLE_CHANGED] = {
		"onModuleEnableChanged",
		true
	},
	[MessageName.INTERACT_GESTURE_STATE_CHANGE] = {
		"onInteractGestureStateChanged",
		true
	},
	[MessageName.CHARACTER_STATE_CHANGED] = {
		"onCharacterStateChanged",
		true
	},
	[MessageName.ON_PLAYER_START_RIFT] = {
		"refreshBallVisible",
		true
	},
	[MessageName.ON_PLAYER_END_RIFT] = {
		"refreshBallVisible",
		true
	},
	[MessageName.APP_FOCUS_CHANGED] = {
		"onAppFocusChanged",
		true
	}
}

function BallBtnComponent:onCtor(info)
	self.isInCancelMode = false
	self._captureEntryContext = nil
	self._captureEntryHandoffFrameId = nil
	self._captureEntryIgnoreNextClick = false
	self.selectedItemId = 0
end

function BallBtnComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.curBallBtn = objectReference:GetRefValue("curBallBtn")

	local btnRef = self.curBallBtn:GetComponent("ObjectReference")

	self.iconUImage = btnRef:GetRefValue("iconUImage")
	self.numCountUText = btnRef:GetRefValue("numCountUText")
	self.countDownUCountDown = btnRef:GetRefValue("countDownUCountDown")
	self.panelBallUComponent = btnRef:GetRefValue("panelBallUComponent")
	self.fastThrowJoyStick = btnRef:GetRefValue("fastThrowJoyStick")
	self.fastThrowBtnClose = btnRef:GetRefValue("fastThrowBtnClose")
end

function BallBtnComponent:initView()
	self:refreshInfo()
	self:refreshBallVisible()

	function self.curBallBtn.luaClick()
		if self._captureEntryIgnoreNextClick then
			self._captureEntryIgnoreNextClick = false

			return
		end

		if self.fastThrowJoyStick.isDragging then
			return
		end

		local _, ballExpandCurPage = self.panelBallUComponent:TryGetCurrentPage("BallExpand")

		if ballExpandCurPage ~= 0 then
			return
		end

		if self.selectedItemId == 0 then
			self.curBallBtn:InvokeCallback(CS.XGUI.EInvokeTime.User1)
		end

		if not self:checkCatchMode() then
			local controller = pg.game.controller

			controller:onHandleSwitchCatchMode(true)
		end
	end

	function self.curBallBtn.luaPress()
		self:_beginCaptureEntryGesture()
	end

	function self.curBallBtn.luaRelease()
		self:_finishCaptureEntryGesture("release")
	end

	function self.curBallBtn.luaEndLongPress()
		self:_finishCaptureEntryGesture("end_long_press")
	end

	function self.fastThrowBtnClose.luaHover()
		if self:checkFastThrowMode() then
			self:setCancelMode(true)
		end
	end

	function self.fastThrowBtnClose.luaUnhover()
		if self:checkFastThrowMode() then
			self:setCancelMode(false)
		end
	end

	function self.fastThrowJoyStick.luaValueChanged(x, y, size)
		self:_recordCaptureEntryJoystickSize(size)
	end

	function self.fastThrowJoyStick.luaDragUpdate(x, y)
		local context = self._captureEntryContext

		if context and (context.state == BallBtnComponent.CAPTURE_ENTRY_STATE.FAST_AIM or context.state == BallBtnComponent.CAPTURE_ENTRY_STATE.FAST_DRAGGING) and not self.isInCancelMode then
			pg.game.input:setViewAxisByDeltaPixel(x, y)
		end
	end

	function self.fastThrowJoyStick.luaJoyStickEndDrag()
		self:_finishCaptureEntryGesture("end_drag")
	end
end

function BallBtnComponent:isCaptureEntryGestureActive()
	return self._captureEntryContext ~= nil
end

function BallBtnComponent:_getHudCtrl()
	return self.ctrl and self.ctrl.ctrl
end

function BallBtnComponent:_getCaptureEntryHoldTime()
	return catch_config_data.MOBILE_LONG_PRESS_TIME or 0.2
end

function BallBtnComponent:_isApplicationFocused()
	return pg.game.isFocused
end

function BallBtnComponent:_beginCaptureEntryGesture()
	if self._captureEntryContext then
		return false
	end

	if self._captureEntryHandoffFrameId then
		self:killFrameTimer(self._captureEntryHandoffFrameId)

		self._captureEntryHandoffFrameId = nil
	end

	local hudItemId = self.selectedItemId or 0
	local context = {
		state = BallBtnComponent.CAPTURE_ENTRY_STATE.PENDING,
		pressTs = Time.realSecondCache,
		restoreHudItemId = ClientCaptureUtils.isPaidBall(hudItemId) and 0 or hudItemId
	}

	self._captureEntryContext = context
	self._captureEntryIgnoreNextClick = true

	if self.selectedItemId == 0 then
		self.curBallBtn:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	end

	context.timerId = self:startTimer(function()
		self:_onCaptureEntryHoldTimeout(context)
	end, self:_getCaptureEntryHoldTime())

	if not pg.game.controller:onHandleSwitchCatchMode(true) then
		self:_resetCaptureEntryGesture(context)

		return false
	end

	return true
end

function BallBtnComponent:_onCaptureEntryHoldTimeout(context)
	if not context or self._captureEntryContext ~= context or context.state ~= BallBtnComponent.CAPTURE_ENTRY_STATE.PENDING then
		return false
	end

	context.timerId = nil

	return self:_promoteCaptureEntryToFastAim(context)
end

function BallBtnComponent:_recordCaptureEntryJoystickSize(size)
	local context = self._captureEntryContext

	if not context then
		return
	end

	if context.state == BallBtnComponent.CAPTURE_ENTRY_STATE.PENDING and size >= BallBtnComponent.FAST_THROW_DRAG_THRESHOLD then
		self:_promoteCaptureEntryToFastAim(context)
	end

	if self._captureEntryContext ~= context then
		return
	end

	if context.state == BallBtnComponent.CAPTURE_ENTRY_STATE.FAST_AIM and size > 0 then
		context.state = BallBtnComponent.CAPTURE_ENTRY_STATE.FAST_DRAGGING

		self.panelBallUComponent:TryChangePage("BallExpand", 1)
	end
end

function BallBtnComponent:_promoteCaptureEntryToFastAim(context)
	if not context or self._captureEntryContext ~= context or context.state ~= BallBtnComponent.CAPTURE_ENTRY_STATE.PENDING then
		return false
	end

	context.fastAimRequested = true

	if not self:checkCatchMode() then
		return false
	end

	if context.timerId then
		self:killTimer(context.timerId)

		context.timerId = nil
	end

	context.fastAimRequested = nil
	context.state = BallBtnComponent.CAPTURE_ENTRY_STATE.FAST_AIM

	self:_setOtherHudVisible(false)

	if self._captureEntryContext ~= context then
		return false
	end

	self:_openFastThrowCapturePanel(context)

	return true
end

function BallBtnComponent:_openFastThrowCapturePanel(context)
	if not context or self._captureEntryContext ~= context then
		return false
	end

	local captureBall = pg.global.ui and pg.global.ui.captureBall

	if not captureBall then
		return false
	end

	captureBall:openOrShow()
	captureBall:setFastThrowMode(true)

	context.fastThrowCapturePanelOpened = true

	return true
end

function BallBtnComponent:_finishCaptureEntryGesture(source)
	local context = self._captureEntryContext

	if not context or context.state == BallBtnComponent.CAPTURE_ENTRY_STATE.FINISHING then
		return false
	end

	if not self:_isApplicationFocused() then
		self._captureEntryIgnoreNextClick = false

		return self:_cancelCaptureEntryGesture(true)
	end

	if source == "end_drag" and (context.state == BallBtnComponent.CAPTURE_ENTRY_STATE.FAST_DRAGGING or context.fastAimRequested) then
		self._captureEntryIgnoreNextClick = false
	end

	if source ~= "end_drag" and self.fastThrowJoyStick and self.fastThrowJoyStick.isDragging then
		return false
	end

	if context.state == BallBtnComponent.CAPTURE_ENTRY_STATE.FAST_DRAGGING and source ~= "end_drag" then
		return false
	end

	if context.state == BallBtnComponent.CAPTURE_ENTRY_STATE.PENDING then
		local elapsed = Time.realSecondCache - context.pressTs

		if elapsed >= self:_getCaptureEntryHoldTime() then
			self:_promoteCaptureEntryToFastAim(context)

			if self._captureEntryContext ~= context then
				return false
			end
		end

		if context.state == BallBtnComponent.CAPTURE_ENTRY_STATE.PENDING then
			if context.fastAimRequested then
				context.pendingFinishSource = source

				return false
			end

			self:_openNormalCaptureFromEntry(context)

			return true
		end
	end

	if context.state == BallBtnComponent.CAPTURE_ENTRY_STATE.FAST_AIM or context.state == BallBtnComponent.CAPTURE_ENTRY_STATE.FAST_DRAGGING then
		context.state = BallBtnComponent.CAPTURE_ENTRY_STATE.FINISHING

		if self.isInCancelMode then
			return self:_cancelCaptureEntryGesture(true)
		end

		return self:_finishFastThrowGesture(context)
	end

	return false
end

function BallBtnComponent:_openNormalCaptureFromEntry(context)
	if not context or self._captureEntryContext ~= context then
		return false
	end

	local captureBall = pg.global.ui and pg.global.ui.captureBall

	if captureBall then
		captureBall:setFastThrowMode(false)
		captureBall:openOrShow()
	end

	self._captureEntryHandoffFrameId = self:startFrameTimer(function()
		self._captureEntryHandoffFrameId = nil

		local hudCtrl = self:_getHudCtrl()

		if hudCtrl and pg.me and pg.me:isInCatchMode() then
			hudCtrl:hide()
		end
	end, 1)

	self:_resetCaptureEntryGesture(context)

	return true
end

function BallBtnComponent:_resetCaptureEntryGesture(context)
	if not context or self._captureEntryContext ~= context then
		return false
	end

	if context.timerId then
		self:killTimer(context.timerId)

		context.timerId = nil
	end

	self:_clearCaptureEntryPendingThrow(context)

	self._captureEntryContext = nil

	return true
end

function BallBtnComponent:_clearCaptureEntryPendingThrow(context)
	if not context then
		return
	end

	if context.pendingThrowFrameId then
		self:killFrameTimer(context.pendingThrowFrameId)

		context.pendingThrowFrameId = nil
	end

	context.pendingThrowDeadline = nil
	context.pendingThrowContext = nil
end

function BallBtnComponent:_clearFastThrowHudOverlay()
	if pg.game and pg.game.input then
		pg.game.input:setViewAxisByDelta(0, 0)
	end

	self:setCancelMode(false)

	if self.panelBallUComponent then
		self.panelBallUComponent:TryChangePage("BallExpand", 0)
	end

	self:_setOtherHudVisible(true)
end

function BallBtnComponent:_restoreFastThrowHudPresentation(context)
	if context and context.presentationRestored then
		return false
	end

	if context then
		local throwContext = pg.me and pg.me.currentContext

		if not throwContext or not ClientCaptureUtils.isPaidBall(throwContext.itemId) then
			context.restoreHudItemId = nil
		end

		context.presentationRestored = true

		if context.restoreHudItemId ~= nil then
			self:_renderSelectedItem(context.restoreHudItemId)
		end
	end

	self:_closeFastThrowCapturePanel(context)
	self:_clearFastThrowHudOverlay()

	if pg.me and pg.me.finishFastThrowPresentation then
		pg.me:finishFastThrowPresentation()
	end

	local hudCtrl = self:_getHudCtrl()

	if hudCtrl then
		if hudCtrl.show then
			hudCtrl:show()
		end

		if hudCtrl.setIsInAim then
			hudCtrl:setIsInAim(false)
		end
	end

	return true
end

function BallBtnComponent:_closeFastThrowCapturePanel(context)
	if not context or not context.fastThrowCapturePanelOpened then
		return false
	end

	context.fastThrowCapturePanelOpened = nil

	local captureBall = pg.global.ui and pg.global.ui.captureBall

	if captureBall then
		captureBall:setFastThrowMode(false)
		captureBall:hide()
	end

	return true
end

function BallBtnComponent:_finishFastThrowGesture(context)
	local throwContext = pg.me and pg.me.currentContext
	local throwResult = self:throwBall(throwContext)

	if throwResult then
		pg.game.controller:onHandleSwitchCatchMode(false)
	elseif throwResult == false then
		context.pendingThrowContext = throwContext
		context.pendingThrowDeadline = Time.realSecondCache + BallBtnComponent.FAST_THROW_READY_TIMEOUT

		self:_scheduleCaptureEntryPendingThrow(context)
	else
		self:_cancelCaptureEntryGesture(true)
	end

	self:_restoreFastThrowHudPresentation(context)

	return true
end

function BallBtnComponent:_scheduleCaptureEntryPendingThrow(context)
	if self._captureEntryContext ~= context or context.pendingThrowFrameId then
		return
	end

	context.pendingThrowFrameId = self:startFrameTimer(function()
		context.pendingThrowFrameId = nil

		self:_tryFinishCaptureEntryPendingThrow(context)
	end, 1)
end

function BallBtnComponent:_tryFinishCaptureEntryPendingThrow(context)
	if not context or self._captureEntryContext ~= context or context.state ~= BallBtnComponent.CAPTURE_ENTRY_STATE.FINISHING then
		return false
	end

	if not self:checkCatchMode() then
		self:_cancelCaptureEntryGesture(false)

		return false
	end

	if Time.realSecondCache >= context.pendingThrowDeadline then
		self:_cancelCaptureEntryGesture(true)

		return false
	end

	local throwResult = self:throwBall(context.pendingThrowContext)

	if throwResult then
		context.pendingThrowDeadline = nil
		context.pendingThrowContext = nil

		pg.game.controller:onHandleSwitchCatchMode(false)

		return true
	end

	if throwResult == nil then
		self:_cancelCaptureEntryGesture(true)

		return false
	end

	self:_scheduleCaptureEntryPendingThrow(context)

	return false
end

function BallBtnComponent:_cancelCaptureEntryGesture(exitCatchMode)
	if self._captureEntryHandoffFrameId then
		self:killFrameTimer(self._captureEntryHandoffFrameId)

		self._captureEntryHandoffFrameId = nil
	end

	local context = self._captureEntryContext

	if not context then
		return false
	end

	local shouldExitCatchMode = exitCatchMode and self:checkCatchMode()
	local fastThrowActive = context.state >= BallBtnComponent.CAPTURE_ENTRY_STATE.FAST_AIM

	if fastThrowActive then
		self:_restoreFastThrowHudPresentation(context)
	else
		if pg.game and pg.game.input then
			pg.game.input:setViewAxisByDelta(0, 0)
		end

		self:setCancelMode(false)

		if self.panelBallUComponent then
			self.panelBallUComponent:TryChangePage("BallExpand", 0)
		end
	end

	self:_resetCaptureEntryGesture(context)

	if shouldExitCatchMode and pg.game and pg.game.controller then
		pg.game.controller:onHandleSwitchCatchMode(false)
	end

	return true
end

function BallBtnComponent:refreshBallVisible()
	local visible = true

	if ClientUtils.isInDouYinOfflineScene() then
		visible = true
	else
		if pg.space:isRogueEnv() then
			visible = false
		end

		if pg.space and (pg.space:isNpcDuel() or pg.space:isBossRushEnv()) then
			visible = false
		end

		if pg.me and pg.me.isInRiftMode and pg.me:isInRiftMode() then
			visible = false
		end
	end

	self.curBallBtn:SetActive(visible)
end

function BallBtnComponent:setCancelMode(isInCancelMode)
	self.isInCancelMode = isInCancelMode

	local cancelState = 0

	if isInCancelMode then
		cancelState = 1

		pg.game.input:setViewAxisByDelta(0, 0)
	end

	self.fastThrowJoyStick:TryChangePage("CancelMode", cancelState)
end

function BallBtnComponent:throwBall(expectedContext)
	if self:checkFastThrowMode() and pg.me and pg.me.tryFastCaptureThrow then
		return pg.me:tryFastCaptureThrow(expectedContext)
	end

	local controller = pg.game.controller

	if controller ~= nil then
		controller:onHandleThrow()

		return true
	end

	return false
end

function BallBtnComponent:onModuleEnableChanged(changeInfo)
	local moduleKey = changeInfo.moduleKey or ""

	if moduleKey == ClientConst.ModuleKey.BallAndItem then
		self:refreshUIVisible()
	end
end

function BallBtnComponent:refreshUIVisible()
	local uiVisible = self:getUIVisible()

	LuaUIUtils.setUIVisible(self.curBallBtn, uiVisible)
end

function BallBtnComponent:getUIVisible()
	if not pg.me or not pg.me.space then
		return false
	end

	if ClientUtils.isInDouYinOfflineScene() then
		return true
	end

	if pg.space and pg.space:isBossRushEnv() then
		return false
	end

	if pg.me:checkArkSceneState() then
		return false
	end

	local sceneData = SceneData[pg.me.space.sceneId]

	if sceneData and sceneData.forbiddenCatch == 1 then
		return false
	end

	if pg.me.forceControl then
		return false
	end

	if CharacterStateConst.isChildOfState(pg.pawn.characterState, CharacterStateConst.SWIMMING) then
		return false
	end

	if CharacterStateConst.isChildOfState(pg.pawn.characterState, CharacterStateConst.GLIDING) then
		return false
	end

	if CharacterStateConst.isChildOfState(pg.pawn.characterState, CharacterStateConst.FLYING) then
		return false
	end

	if CharacterStateConst.isChildOfState(pg.pawn.characterState, CharacterStateConst.CLIMBING) then
		return false
	end

	if not pg.game:checkModuleEnable(ClientConst.ModuleKey.BallAndItem) then
		return false
	end

	if pg.global.ui.hudV2 and pg.global.ui.hudV2.RD and pg.global.ui.hudV2.RD.interactGesture and pg.global.ui.hudV2.RD.interactGesture.transform then
		return false
	end

	if pg.me and pg.me.space and pg.me.space:isSpaceFollowMember(pg.me.uid) then
		return false
	end

	if pg.game.social.interactGestureComponent:checkInteractGesturePlaying() then
		return false
	end

	return true
end

function BallBtnComponent:_renderSelectedItem(itemId)
	self.selectedItemId = itemId or 0

	if self.selectedItemId ~= 0 then
		self.iconUImage.url = LuaUIUtils.getIconByItemId(self.selectedItemId)

		local itemCount = ClientUtils.getItemCountById(self.selectedItemId)

		ClientTextUtils.setText(self.numCountUText, itemCount)

		if itemCount > 0 then
			self.curBallBtn:TryChangePage("ItemState", 1)
		else
			self.curBallBtn:TryChangePage("ItemState", 0)
		end
	else
		ClientTextUtils.setText(self.numCountUText, 0)
		self.curBallBtn:TryChangePage("ItemState", 0)
	end
end

function BallBtnComponent:refreshSelectedItem(itemId)
	if not itemId then
		if not self:checkCurItemValid() then
			local itemList = self.model:getCapturePropInfos()
			local savedId = pg.global.prefsCacheUtils:getInt(ClientConst.PrefKey.CatchSelectItemId, nil)

			if savedId then
				for _, info in ipairs(itemList) do
					if info.itemId == savedId then
						itemId = savedId

						break
					end
				end
			end

			if not itemId then
				itemId = #itemList > 0 and itemList[1].itemId or 0
			end
		else
			itemId = self.selectedItemId
		end
	end

	self:_renderSelectedItem(itemId)
	pg.global.prefsCacheUtils:setInt(ClientConst.PrefKey.CatchSelectItemId, self.selectedItemId)

	if pg.game.controller.onHandleSwitchProp then
		pg.game.controller:onHandleSwitchProp()
	end
end

function BallBtnComponent:syncSelectedItem(itemId)
	local context = self._captureEntryContext

	if context and context.presentationRestored and context.restoreHudItemId ~= nil then
		return false
	end

	self:_renderSelectedItem(itemId)

	return true
end

function BallBtnComponent:selectValidItem()
	local itemList = self.model:getCapturePropInfos()
	local itemInfo = itemList[1]

	if itemInfo and itemInfo.itemId then
		self:refreshSelectedItem(itemInfo.itemId)
	end
end

function BallBtnComponent:refreshInfo()
	local captureBallCtrl = pg.global.ui and pg.global.ui.captureBall
	local inCaptureMode = pg.me and pg.me.isInCatchMode and pg.me:isInCatchMode()
	local captureBallItemListInitialized = captureBallCtrl and (captureBallCtrl.itemListInitialized == true or captureBallCtrl.itemListInitialized == nil and captureBallCtrl.normalItemList ~= nil)

	if inCaptureMode and captureBallCtrl and captureBallCtrl.getCurSelectPropId then
		if captureBallItemListInitialized then
			self:syncSelectedItem(captureBallCtrl:getCurSelectPropId())
		else
			self:_renderSelectedItem(self.selectedItemId)
		end
	else
		self:refreshSelectedItem()
	end

	self:refreshUIVisible()
end

function BallBtnComponent:checkCurItemValid()
	if self.selectedItemId ~= 0 then
		local count = ClientUtils.getItemCountById(self.selectedItemId)
		local itemList = self.model:getCapturePropInfos()

		for _, itemInfo in ipairs(itemList) do
			if itemInfo.itemId == self.selectedItemId then
				return count > 0
			end
		end
	end

	return false
end

function BallBtnComponent:_setOtherHudVisible(visible)
	if visible then
		pg.global.ui.hudV2:restoreBaseComponentsState(BallBtnComponent.HUD_SKILL_HIDE_REASON_FAST_THROW)

		return
	end

	local componentNames = {}

	for _, componentName in pairs(HudSplicingCfg.componentName) do
		if componentName ~= HudSplicingCfg.componentName.mobileBallBtn then
			componentNames[#componentNames + 1] = componentName
		end
	end

	componentNames[#componentNames + 1] = HudSplicingCfg.LayoutName.LD

	pg.global.ui.hudV2:hideBaseComponentsWithState(componentNames, BallBtnComponent.HUD_SKILL_HIDE_REASON_FAST_THROW)
end

function BallBtnComponent:onCatchModeChange(enable)
	if enable then
		if self:isCaptureEntryGestureActive() then
			local context = self._captureEntryContext

			if context.state == BallBtnComponent.CAPTURE_ENTRY_STATE.PENDING and context.fastAimRequested then
				self:_promoteCaptureEntryToFastAim(context)

				if self._captureEntryContext ~= context then
					return
				end

				if context.pendingFinishSource then
					local source = context.pendingFinishSource

					context.pendingFinishSource = nil

					self:_finishCaptureEntryGesture(source)
				end
			end

			pg.global.ui.interact:onCatchModeChange()

			return
		end

		local captureBall = pg.global.ui and pg.global.ui.captureBall

		if captureBall then
			captureBall:setFastThrowMode(false)
			captureBall:openOrShow()
		end
	elseif not self:_cancelCaptureEntryGesture(false) then
		self:setCancelMode(false)

		if self.panelBallUComponent then
			self.panelBallUComponent:TryChangePage("BallExpand", 0)
		end
	end

	pg.global.ui.interact:onCatchModeChange()
end

function BallBtnComponent:checkFastThrowMode()
	local context = self._captureEntryContext

	return pg.me and pg.me:isInCatchMode() and context and context.state >= BallBtnComponent.CAPTURE_ENTRY_STATE.FAST_AIM or false
end

function BallBtnComponent:checkCatchMode()
	return pg.me and pg.me:isInCatchMode()
end

function BallBtnComponent:getCurSelectPropId()
	return self.selectedItemId
end

function BallBtnComponent:onQuickBallChange()
	self:refreshInfo()
end

function BallBtnComponent:onDestroy()
	if pg.me then
		self:_cancelCaptureEntryGesture(true)
	end

	HudBaseComponent.onDestroy(self)
end

function BallBtnComponent:onAppFocusChanged(focus)
	if not focus then
		self._captureEntryIgnoreNextClick = false

		self:_cancelCaptureEntryGesture(true)
	end
end

function BallBtnComponent:onInteractGestureStateChanged()
	self:refreshUIVisible()
end

function BallBtnComponent:onCharacterStateChanged()
	self:refreshUIVisible()
end

function BallBtnComponent:playShowAnim()
	if self.uWidget then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Show)
	end
end

function BallBtnComponent:playHideAnim()
	if self.uWidget then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Hide)
	end
end

return BallBtnComponent
