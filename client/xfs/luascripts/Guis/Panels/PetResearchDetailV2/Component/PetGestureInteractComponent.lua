-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchDetailV2\\Component\\PetGestureInteractComponent.lua

local lume = require("Core.Common.lume")
local PlayableConst = require("Common.Const.PlayableConst")
local SysConfigData = require("Data.sys_config_data")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local Const = require("Common.Const.Const")
local PartID = Const.ModelPartId
local PetResearchInteractDisplayData = require("Data.pet_research_interact_display_data")
local PetGestureInteractComponent = Class.LightClass("PetGestureInteractComponent", UIComponent)
local DIRECTION = {
	Left = 0,
	Down = 3,
	Up = 2,
	Right = 1
}

function PetGestureInteractComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.fingerUWidget = self.objectReference:GetRefValue("fingerUWidget")
	self.gestureFingerRoot = self.objectReference:GetRefValue("gestureRootUWidget")
	self.gestureAction = self.objectReference:GetRefValue("gestureAction")
	self.gestureActionWidget = self.objectReference:GetRefValue("gestureActionWidget")
	self.longPressSlider = self.objectReference:GetRefValue("longPressSlider")
end

function PetGestureInteractComponent:initView()
	self.gestureAction.handIconRoot = self.gestureFingerRoot.rectTransform
	self.gestureAction.windowsRoot = self.uWidget.rectTransform

	self.ctrl.petScene:enableIK(nil, false)

	self.longPressSlider.maxValue = 2

	function self.gestureAction.luaHorizontalSwipe(direction)
		if direction > 0 then
			self:onSwipePet(DIRECTION.Right)
		else
			self:onSwipePet(DIRECTION.Left)
		end
	end

	self.gestureAction.lookAtCamera = self.ctrl.petScene.uiSceneCamera
	self.gestureAction.lookAtTargetTrans = self.ctrl.petScene.lookAtTargetTransform

	function self.gestureAction.luaVerticalSwipe(direction)
		if direction > 0 then
			self:onSwipePet(DIRECTION.Up)
		else
			self:onSwipePet(DIRECTION.Down)
		end
	end

	function self.gestureAction.luaHorizontalStir()
		self:onHorizontalStir()
	end

	function self.gestureAction.luaHorizontalQuickStir()
		self:onHorizontalQuickStir()
	end

	function self.gestureAction.luaMultiClick(pos)
		self:onMultiClick(pos)
	end

	function self.gestureAction.luaTriggerPickUp()
		self:pickUpPet()
	end

	function self.gestureAction.luaInShake(delta)
		self:shakePet(delta)
	end

	function self.gestureAction.luaDuringLongPress(interval)
		self:duringLongPress(interval)
	end

	function self.gestureAction.luaEndLongPress(pos)
		self:endLongPress(pos)
	end

	function self.gestureAction.luaEndPickUp()
		self:endPickUp()
	end

	function self.gestureAction.luaClick(touchPos)
		self:onClick(touchPos)
	end

	function self.gestureAction.luaLongPress(touchPos)
		self:onStartLongPress(touchPos)
	end

	function self.gestureAction.luaLongPressBreak()
		self:onLongPressBreak()
	end

	function self.gestureAction.luaCheckRaycastEnt(screenPos)
		return self:checkPointToEnt(screenPos)
	end

	function self.gestureAction.luaMouseMoveStateChange(isMove)
		self:switchTipsTimer(isMove)

		if self.gestureAction.isEnterGesture then
			self:switchSleepTimer(isMove)
		end
	end

	function self.view.btnExitHideUIUButton.luaClick()
		self:changeGestureInteract(false)
	end

	self:refreshFingerVisible()
end

function PetGestureInteractComponent:switchGestureEnable(enabled)
	if enabled then
		self.ctrl.petScene:enableIK(nil, true)
	else
		self.ctrl.petScene:enableIK(nil, false)
	end
end

function PetGestureInteractComponent:switchTipsTimer(isMoving)
	if isMoving then
		self:clearTipsTimer()
		self.fingerUWidget:TryChangePage("Gesture", 0)
		self:refreshFingerVisible()
	else
		self:startTipsTimer()
	end
end

function PetGestureInteractComponent:switchSleepTimer(isMoving)
	if isMoving then
		self:clearSleepTimer()
	else
		self:startSleepTimer()
	end
end

function PetGestureInteractComponent:startTipsTimer()
	self:clearTipsTimer()

	self.tipsTimer = self:startTimer(function()
		local ret = lume.random(1, 8)

		self.fingerUWidget:TryChangePage("Gesture", ret)
		self.gestureFingerRoot:SetActiveFastest(true)
		self:startTipsTimer()
	end, SysConfigData.HandBookWaitTipTime)
end

function PetGestureInteractComponent:startSleepTimer()
	self:clearSleepTimer()

	self.sleepTimer = self:startTimer(function()
		self.ctrl.petScene:playCurPetPhaseActionWithTime("Behav_SleepStart", "Behav_SleepLoop")
	end, SysConfigData.HandBookWaitSleepTime)
end

function PetGestureInteractComponent:clearSleepTimer()
	if self.sleepTimer then
		self:killTimer(self.sleepTimer)
	end

	self.sleepTimer = nil
end

function PetGestureInteractComponent:clearTipsTimer()
	if self.tipsTimer then
		self:killTimer(self.tipsTimer)
	end

	self.tipsTimer = nil
end

function PetGestureInteractComponent:onSwipePet(direction)
	local rotateCondition = self:tryGetInteractData("rotateCondition")

	if not rotateCondition then
		return
	end

	self:changeGestureInteract(true)

	if direction == DIRECTION.Left then
		self.fingerUWidget:TryChangePage("Gesture", 7, false, true, false)
		self:switchGestureEnable(false)

		self.fingerUWidget.transform.localRotation = Quaternion.Euler(0, 0, 0)
		self.inPlayable = true

		self.ctrl.petScene:playCurPetRotation(rotateCondition[1], rotateCondition[2], rotateCondition[3], function()
			self:resetIdleGesture()
		end)
	elseif direction == DIRECTION.Right then
		self.fingerUWidget:TryChangePage("Gesture", 7, false, true, false)
		self:switchGestureEnable(false)

		self.fingerUWidget.transform.localRotation = Quaternion.Euler(0, 180, 0)
		self.inPlayable = true

		self.ctrl.petScene:playCurPetRotation(rotateCondition[1], -rotateCondition[2], rotateCondition[3], function()
			self:resetIdleGesture()
		end)
	end
end

function PetGestureInteractComponent:resetIdleGesture()
	if not self.gestureAction.inLongPressProgress then
		self.fingerUWidget:TryChangePage("Gesture", 0)
	end

	self.fingerUWidget.transform.localRotation = Quaternion.Euler(0, 0, 0)
	self.inPlayable = false

	self:switchGestureEnable(true)
end

function PetGestureInteractComponent:tryGetInteractData(attrName, force)
	if self.inPlayable and not force then
		return
	end

	local templateId = self.model.curPetTemplateId
	local interactDisplayInfo = PetResearchInteractDisplayData[templateId]

	if not interactDisplayInfo then
		return false
	end

	return interactDisplayInfo[attrName]
end

function PetGestureInteractComponent:onHorizontalStir()
	local pettingAniInfo = self:tryGetInteractData("pettingCondition")

	if not pettingAniInfo then
		return
	end

	self:changeGestureInteract(true)
	self.fingerUWidget:TryChangePage("Gesture", 3, false, true, false)

	self.inPlayable = true

	self.ctrl.petScene:playCurPetPhaseActionWithTime(pettingAniInfo[1], pettingAniInfo[2], pettingAniInfo[3], pettingAniInfo[4], function()
		self:resetIdleGesture()
	end)
end

function PetGestureInteractComponent:onDestroy()
	UIComponent.onDestroy(self)
	self:clearTipsTimer()
	self:clearSleepTimer()
end

function PetGestureInteractComponent:onGestureDrag(pos)
	local localPos = pg.global.uiMgr:ScreenPointToLocalPoint(self.uWidget.transform, pos)

	self.gestureFingerRoot.rectTransform.anchoredPosition = localPos
end

function PetGestureInteractComponent:onHorizontalQuickStir()
	local madRotateCondition = self:tryGetInteractData("madRotateCondition")

	if not madRotateCondition then
		return
	end

	self:changeGestureInteract(true)
	self:switchGestureEnable(false)

	self.inPlayable = true

	self.ctrl.petScene:playCurPetPhaseActionWithTime(madRotateCondition[1], madRotateCondition[2], madRotateCondition[3], madRotateCondition[4], function()
		self:resetIdleGesture()
	end)
end

function PetGestureInteractComponent:onClick(touchPos)
	local ret = self.ctrl.petScene:checkPointToEnt(touchPos)

	if ret ~= self.clickPartId then
		self.gestureAction:ClearMultClickCoroutine()

		self.clickPartId = ret
	end

	self.fingerUWidget:TryChangePage("Gesture", 4, false, true, false)

	if self.clickPartId == PartID.Head then
		self:playPointAction("clickHeadCondition")
	elseif self.clickPartId == PartID.Spine then
		self:playPointAction("clickBellyCondition")
	elseif self.clickPartId == PartID.Hand or ret == PartID.Foot then
		self:playPointAction("clickHandCondition")
	end
end

function PetGestureInteractComponent:onMultiClick(touchPos)
	local ret = self.ctrl.petScene:checkPointToEnt(touchPos)

	if ret == PartID.Head then
		self:playPointAction("quickClickHeadCondition", true)
	elseif ret == PartID.Spine then
		self:playPointAction("quickClickBellyCondition", true)
	elseif ret == PartID.Hand or ret == PartID.Foot then
		self:playPointAction("quickClickHandCondition", true)
	end
end

function PetGestureInteractComponent:playPointAction(conditionName, force)
	local condition = self:tryGetInteractData(conditionName, force)

	if condition then
		self:switchGestureEnable(false)
		self:changeGestureInteract(true)

		self.inPlayable = true

		self.ctrl.petScene:playCurPetPhaseActionWithTime(condition[1], nil, nil, nil, function()
			self:resetIdleGesture()
		end)
	end
end

function PetGestureInteractComponent:duringLongPress(interval)
	self.longPressSlider.value = interval
end

function PetGestureInteractComponent:endLongPress(touchPos)
	local ret = self.ctrl.petScene:checkPointToEnt(touchPos)

	self.fingerUWidget:TryChangePage("Gesture", 5, false, true, false)

	if ret == PartID.Head then
		self:playPointAction("longClickHeadCondition")
	elseif ret == PartID.Spine then
		self:playPointAction("longClickBellyCondition")
	elseif ret == PartID.Hand or ret == PartID.Foot then
		self:playPointAction("longClickHandCondition")
	end
end

function PetGestureInteractComponent:onLongPressBreak()
	self:resetIdleGesture()
end

function PetGestureInteractComponent:onStartLongPress()
	self.longPressSlider.value = 0

	self.fingerUWidget:TryChangePage("Gesture", 6, false, true, false)
end

function PetGestureInteractComponent:changeGestureInteract(enabled)
	if enabled then
		self.view.rootComponent:TryChangePage("InteractPet", 1)

		self.gestureAction.isEnterGesture = true
		self.ctrl.curTabIdx = self.model.TAB_IDX.INTERACT
	else
		self.view.rootComponent:TryChangePage("InteractPet", 0)
		self.ctrl.petScene:enableIK(nil, false)

		self.gestureAction.isEnterGesture = false

		self.ctrl.petScene:stopPetActionByKey(PlayableConst.Struggle)
		self.ctrl.petScene:stopPetActionByKey(PlayableConst.Behav_SleepLoop)
		self.ctrl.petScene:entPosToZero()
		self.ctrl.petScene:entPosAngleToZero()
		self.ctrl.petScene:resetCurShowPetIdle()

		self.ctrl.curTabIdx = self.model.TAB_IDX.SURVEY
		self.gestureFingerRoot.localPosition = Vector3(0, 0, 0)
	end

	self.gestureAction:RefreshCursorVisible()
	self.ctrl.petScene:trySwitchView(self.ctrl.curTabIdx)

	if not enabled then
		self.ctrl:refreshCurTab()
	end

	self:refreshFingerVisible()
end

function PetGestureInteractComponent:refreshFingerVisible()
	self.gestureFingerRoot:SetActiveFastest(self.gestureAction.isEnterGesture)
end

function PetGestureInteractComponent:checkInGestureInteract()
	return self.gestureAction.isEnterGesture
end

function PetGestureInteractComponent:shakePet(delta)
	self.ctrl.petScene:createRagdoll()
	self.ctrl.petScene:enableRagdoll(true)
	self.ctrl.petScene:shakeCurPet(delta)
end

function PetGestureInteractComponent:endPickUp()
	local garbAndDropAni = self:tryGetInteractData("garbAndDropAni")

	self.fingerUWidget:TryChangePage("Gesture", 0)
	self:switchGestureEnable(true)
	self.ctrl.petScene:stopPetActionByKey(PlayableConst.Struggle)
	self.ctrl.petScene:enableRagdoll(false)

	self.inPlayable = true

	self.ctrl.petScene:playCurPetPhaseActionWithTime(garbAndDropAni, nil, nil, nil, function()
		self:resetIdleGesture()
	end)
	self.ctrl.petScene:entPosToZero()
end

function PetGestureInteractComponent:checkPointToEnt(screenPos)
	local ret = self.ctrl.petScene:checkPointToEnt(screenPos)

	return ret
end

function PetGestureInteractComponent:pickUpPet()
	local grabAni = self:tryGetInteractData("grabAni")

	self:changeGestureInteract(true)
	self.ctrl.petScene:playPetAction(nil, grabAni)

	self.inPlayable = true

	self.fingerUWidget:TryChangePage("Gesture", "Pinching", false, true, false)
end

return PetGestureInteractComponent
