-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GuidePanel\\GuidePanelCtrl.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local UICtrl = require("Guis.UICtrl")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local Mathf = require("Common.Math.Mathf")
local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local GuideUtils = require("Utils.GuideUtils")
local GuideStepData = require("Data.guide_step_data")
local MessageName = require("Const.MessageName")
local GuideInputUtils = require("GameApp.Guide.GuideInputUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local KeyBindingBehavior = KeyBindingPro.KeyBindingBehavior
local logger = LoggerManager.getLogger("GuidePanelCtrl")
local Quaternion = Quaternion
local GuidePanelCtrl = Class.LightClass("GuidePanelCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local GUIDE_PANEL_DRAG_TWEEN_ID = "guidePanelDrag"
local ANIM_SHOW_DELAY_TIME = 0.083

GuidePanelCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function GuidePanelCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.aiCallORFinishAnimTime = 0.77
	self.defaultMaskAnimType = self.view.uGuide.maskAnimType

	self:init()
end

function GuidePanelCtrl:refreshMaskAnimType()
	self.view.uGuide.maskAnimType = self.stepInfo.maskAnimType or self.defaultMaskAnimType
end

function GuidePanelCtrl:onInputDeviceChanged(deviceType)
	self:refreshNextStepHotKeyContent()
	self:refreshGroupSkipHotKeyContent()
end

function GuidePanelCtrl:refreshNextStepHotKeyContent()
	if self.curStepCfg == nil or self.view == nil then
		return
	end

	local actionPath = self:getNextStepActionPath()

	if NotNil(self.guidePopupKeyHotKeyContent) then
		self.guidePopupKeyHotKeyContent:SetHotKeyPaths(actionPath)
	end

	local aiKeyHotKeyContent = self.view.aiCallOR:GetRefValue("keyHotKeyContent")

	if NotNil(aiKeyHotKeyContent) then
		aiKeyHotKeyContent:SetHotKeyPaths(actionPath)
	end
end

function GuidePanelCtrl:init()
	self.guideVXCache = {}
end

function GuidePanelCtrl:progressToValueSafely(progress, countDownTime)
	local ok, err = xpcall(function()
		progress:ProgressToValue(0, nil, countDownTime)
	end, function(errorInfo)
		if debug and debug.traceback then
			return debug.traceback(errorInfo)
		end

		return errorInfo
	end)

	if not ok and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("GuidePanelCtrl ProgressToValue failed", self.curStepId, countDownTime, err)
	end
end

function GuidePanelCtrl:addListener()
	GuideInputUtils.addNextStepBindings(self, self.view.widget.gameObject, "guideNextStep", 100)

	local keyboardSkipBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "guideGroupSkipKeyboardBind")

	keyboardSkipBinding.isVirtual = true
	keyboardSkipBinding.priority = 102
	keyboardSkipBinding.actionPath = GuideInputUtils.GROUP_SKIP_KEYBOARD_ACTION

	function keyboardSkipBinding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" and not pg.game.input:isUsingGamepad() and self.groupSkipEnabled then
			self:onGroupSkipClick()

			return false
		end

		return true
	end

	GuideInputUtils.addGamepadGroupSkipBinding(self, self.view.widget.gameObject, "guideGroupSkipGamepadBind")

	function self.view.virtualBtn.luaClick()
		local stepId = self.curStepId

		self:onSimulateClickTargetBtn(self.virtualBtnTargetTrans)

		if self.curStepId == stepId then
			local navMgr = pg.global.navMgr

			if pg.game.input:isUsingGamepad() and navMgr ~= nil and navMgr.IsVirtualMouseMode and self.stepInfo and self.stepInfo.onVirtualMouseConfirm and self.stepInfo.onVirtualMouseConfirm() then
				return
			end

			if NotNil(self.view) and self.view.uGuide.onCloseGuideStep then
				self.view.uGuide.onCloseGuideStep(self.curStepId, Const.GUIDE_STEP_FINISH_REASON.CLICK_VIRTUAL_BTN)
			end
		end
	end

	local nextBtnObj = self.view.aiCallOR:GetRefValue("nextBtn").gameObject

	GuideInputUtils.addNextStepBindings(self, nextBtnObj, "next", 101)
end

function GuidePanelCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:clearPopupTipTimer()
	self:clearGroupSkipHoldTimer()

	self.groupSkipGamepadPressConsumed = false
	self.stepInfo = info
	self.curStepId = info.stepId
	self.guidePopupMainCom = nil
	self.guidePopupStepId = nil
	self.groupSkipInputBlocked = info.canSkipGroup == true
	self.groupSkipEnabled = false

	if info.toastGuidePanel then
		self:refreshToastGuidePanel()
	elseif info.showMask then
		self:refreshGuideMaskPanel()
	else
		self:refreshGuidePanel()
	end
end

function GuidePanelCtrl:shouldPlaySameTypeGroupShow()
	local groupInfo = self.stepInfo and self.stepInfo.sameTypeStepGroupInfo

	return groupInfo == nil or not groupInfo.canPlayPanelAnim or groupInfo.isFirstStep
end

function GuidePanelCtrl:showGroupSkip()
	GuideInputUtils.showGroupSkip(self, logger, self.stepInfo and self.stepInfo.guideId, self.curStepId)
end

function GuidePanelCtrl:refreshGroupSkipHotKeyContent()
	GuideInputUtils.refreshGroupSkipHotKeyContent(self)
end

function GuidePanelCtrl:clearGroupSkipUI()
	GuideInputUtils.clearGroupSkipUI(self)
end

function GuidePanelCtrl:clearGroupSkipHoldTimer()
	GuideInputUtils.clearGroupSkipHoldTimer(self)
end

function GuidePanelCtrl:onGroupSkipClick()
	return GuideInputUtils.onGroupSkipClick(self)
end

function GuidePanelCtrl:refreshGuideMaskPanel()
	self:setIsModel(false)
	self.view.uGuide:PauseGuide(true)
	self:changeMaskPage(2)
	self.view.mainCom:TryChangePage("GuideType", 0)
	self.view.mainCom:TryChangePage("ShowAICall", 0)
end

function GuidePanelCtrl:refreshGuidePanel()
	self:clearPopupTipTimer()

	local stepCfg = GuideStepData[self.curStepId]

	self.curStepCfg = stepCfg

	self:setIsModel(false)

	function self.view.uGuide.onRenderGuidePopup(guideID, popup, arrowDir)
		self:refreshBerthTip(guideID, popup, arrowDir)
	end

	LuaUIUtils.setUIViewVisible(self.view.virtualBtn, false)

	self.virtualBtnTargetTrans = nil

	self:changeMaskPage(0)
	self.view.mainCom:TryChangePage("GuideType", stepCfg.type)

	if stepCfg.force == 1 then
		self:forceTakeOver(stepCfg)
	end

	self:refreshAICallPanel(stepCfg)

	if stepCfg.type == Const.GUIDE_TYPE.GT_FLOATING_AUTO then
		self:refreshTopTips(stepCfg)
		self.view.uGuide:PauseGuide(true)
		pg.game.audio:triggerEvent("UI_NoviceGuide_Tips")
	elseif stepCfg.type == Const.GUIDE_TYPE.GT_FLOATING_AI then
		self.view.uGuide:PauseGuide(true)
		pg.game.audio:triggerEvent("UI_NoviceGuide_DialogueAI")
	elseif stepCfg.type == Const.GUIDE_TYPE.GT_FLOATING_DRAG then
		self:setDragAnimPos()
		self:openDragGuide(stepCfg)
	elseif stepCfg.type == Const.GUIDE_TYPE.GT_FOCUS or stepCfg.type == Const.GUIDE_TYPE.GT_SPECIFIC_HIGHLIGHT then
		self:openFocusGuide(stepCfg)
	end

	self:showGuideVX(stepCfg)
	self:refreshEndCheck(stepCfg)
end

function GuidePanelCtrl:refreshBerthTip(guideID, popup, arrowDir)
	if self.view == nil or guideID ~= self.curStepId then
		return
	end

	local stepCfg = GuideStepData[guideID]

	if stepCfg == nil then
		return
	end

	local nextStepEnabled = self:isNextStepEnabled(stepCfg)

	popup.visibility = nextStepEnabled and CS.XGUI.EVisibility.SelfHitTestInvisible or CS.XGUI.EVisibility.HitTestInvisible

	local objectReference = popup:GetComponent("ObjectReference")
	local contentTxt = objectReference:GetRefValue("contentTxt")
	local mainCom = objectReference:GetRefValue("mainCom")
	local keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")
	local btnNext = objectReference:GetRefValue("btnNext")
	local progressCountDown = objectReference:GetRefValue("progressCountDown")

	self.guidePopupKeyHotKeyContent = keyHotKeyContent
	self.guidePopupMainCom = mainCom
	self.guidePopupStepId = guideID

	ClientTextUtils.setText(contentTxt, pg.getLocalizationText(stepCfg.msg))
	mainCom:TryChangePage("TipsType", 0)
	mainCom:TryChangePage("Next", 0)
	self:clearPopupTipTimer()

	local requestStepId = self.curStepId

	self.popupTipTimer = self:startTimer(function()
		self.popupTipTimer = nil

		if self.view == nil or self.curStepId ~= requestStepId or self.guidePopupStepId ~= requestStepId then
			return
		end

		if nextStepEnabled then
			mainCom:TryChangePage("Next", 1)
		end

		mainCom:InvokeCallback(CS.XGUI.EInvokeTime.Show)
	end, ANIM_SHOW_DELAY_TIME, false)

	keyHotKeyContent:SetHotKeyPaths(self:getNextStepActionPath())

	function btnNext.luaClick()
		self:onNextStepClick()
	end

	local isCountDown, countDownTime = self:checkIsCountDown(stepCfg)

	mainCom:TryChangePage("CountDown", isCountDown and 1 or 0)
	progressCountDown:Stop()

	if isCountDown then
		progressCountDown:Play(countDownTime)
	end
end

function GuidePanelCtrl:showGuideVX(stepCfg)
	if stepCfg.vxResId == nil or stepCfg.vxResId == "" then
		return
	end

	self.curGuideVX = self.guideVXCache[stepCfg.vxResId]

	if NotNil(self.curGuideVX) then
		LuaUIUtils.setUIViewVisible(self.curGuideVX, true)
		self:setGuideVXLocation(self.curGuideVX, stepCfg.vxLocation)

		return
	end

	self.vxLoadTaksId = pg.global.resMgr:GetInstanceFromCacheByLua(stepCfg.vxResId, function(vxObj, userData)
		self.vxLoadTaksId = nil

		if IsNil(vxObj) then
			return
		end

		self:setGuideVXLocation(vxObj, stepCfg.vxLocation)

		self.guideVXCache[stepCfg.vxResId] = vxObj
	end, 2, nil, self.view.guideVXRoot, false, 0, 1)
end

function GuidePanelCtrl:setGuideVXLocation(vxObj, location)
	local anchor = location[1] or 0
	local offsetX = location[2] or 0
	local offsetY = location[3] or 0
	local anchorMin, anchorMax, pivot

	if anchor == 0 then
		anchorMin = Vector2(0.5, 0.5)
		anchorMax = Vector2(0.5, 0.5)
		pivot = Vector2(0.5, 0.5)
	elseif anchor == 1 then
		anchorMin = Vector2(0.5, 1)
		anchorMax = Vector2(0.5, 1)
		pivot = Vector2(0.5, 1)
	elseif anchor == 2 then
		anchorMin = Vector2(0.5, 0)
		anchorMax = Vector2(0.5, 0)
		pivot = Vector2(0.5, 0)
	elseif anchor == 3 then
		anchorMin = Vector2(0, 0.5)
		anchorMax = Vector2(0, 0.5)
		pivot = Vector2(0, 0.5)
	elseif anchor == 4 then
		anchorMin = Vector2(1, 0.5)
		anchorMax = Vector2(1, 0.5)
		pivot = Vector2(1, 0.5)
	end

	self.view.guideVXRoot.anchorMin = anchorMin
	self.view.guideVXRoot.anchorMax = anchorMax
	self.view.guideVXRoot.pivot = pivot
	self.view.guideVXRoot.anchoredPosition = Vector2(offsetX, offsetY)
end

function GuidePanelCtrl:closeGuideVX()
	if self.vxLoadTaksId then
		pg.global.resMgr:TryCancelGOLoadAsyncTask(self.vxLoadTaksId)
	end

	if NotNil(self.curGuideVX) then
		LuaUIUtils.setUIViewVisible(self.curGuideVX, false)
	end

	self.vxLoadTaksId = nil
	self.curGuideVX = nil
end

function GuidePanelCtrl:unloadGuideVX()
	if self.vxLoadTaksId then
		pg.global.resMgr:TryCancelGOLoadAsyncTask(self.vxLoadTaksId)
	end

	for i, v in pairs(self.guideVXCache) do
		pg.global.resMgr:RemoveInstanceToCache(v, true)
	end

	self.vxLoadTaksId = nil
	self.guideVXCache = {}
end

function GuidePanelCtrl:openFocusGuide(stepCfg)
	local keyBindingPros

	if NotNil(self.stepInfo.targetBtnTrans) then
		keyBindingPros = self.stepInfo.targetBtnTrans:GetComponentsInChildren(typeof(KeyBindingPro))

		if keyBindingPros ~= nil then
			for i = 0, keyBindingPros.Length - 1 do
				keyBindingPros[i].enabled = false
			end
		end
	else
		local onCloseGuideStep = self.stepInfo.onCloseGuideStep

		self.stepInfo.onCloseGuideStep = nil

		if onCloseGuideStep then
			onCloseGuideStep(self.curStepId)
		end

		return
	end

	if stepCfg.directionMethod == Const.GUIDE_DIRECTION_TYPE.GUIDE_PORINT_TYPE_CONTROL then
		self.view.uGuide:InitFocus(self.stepInfo.targetBtnTrans)

		self.view.uGuide.useMaskHoleOnlyForFocus = stepCfg.type == Const.GUIDE_TYPE.GT_SPECIFIC_HIGHLIGHT
		self.view.uGuide.guideID = self.curStepId

		function self.view.uGuide.onCloseGuideStep(curStepId)
			if self.curStepId == nil or self.curStepId ~= curStepId then
				return
			end

			local onCloseGuideStep = self.stepInfo.onCloseGuideStep

			self.stepInfo.onCloseGuideStep = nil

			if onCloseGuideStep then
				onCloseGuideStep(curStepId)
			end
		end

		function self.view.uGuide.onIncorrectCloseGuide(curStepId, error_code)
			if self.curStepId == nil or self.curStepId ~= curStepId then
				if LoggerManager.checkLogger(LoggerConst.WARN) then
					logger:warn("[GuideFocusTargetLost] ignore stale callback, callbackStepId[%s] currentStepId[%s] errorCode[%s]", tostring(curStepId), tostring(self.curStepId), tostring(error_code))
				end

				return
			end

			local stepInfo = self.stepInfo

			if LoggerManager.checkLogger(LoggerConst.WARN) then
				local errorReason = {
					"目标控件已离开激活层级(activeInHierarchy=false)",
					"目标控件或父节点的缩放接近0(lossyScale≈0)",
					"实际显示控件的最终渲染透明度为0(actualRenderOpacity=0)"
				}
				local targetTrans = stepInfo and stepInfo.targetBtnTrans
				local targetWidget

				if NotNil(targetTrans) then
					targetWidget = targetTrans:GetComponent("UWidget")
				end

				logger:warn("[GuideFocusTargetLost] guideId[%s] callbackStepId[%s] currentStepId[%s] " .. "errorCode[%s] reason[%s] panelId[%s] directionParams[%s] targetName[%s] " .. "activeInHierarchy[%s] sourceActualRenderOpacity[%s] lossyScale[%s]", tostring(stepInfo and stepInfo.guideId), tostring(curStepId), tostring(self.curStepId), tostring(error_code), errorReason[error_code] or "未知错误", tostring(GuideUtils.getPanelId(stepCfg)), inspect(stepCfg.directionParams), NotNil(targetTrans) and tostring(targetTrans.name) or "nil", NotNil(targetTrans) and tostring(targetTrans.gameObject.activeInHierarchy) or "nil", NotNil(targetWidget) and tostring(targetWidget.actualRenderOpacity) or "nil", NotNil(targetTrans) and tostring(targetTrans.lossyScale) or "nil")
			end

			local onIncorrectCloseGuide = stepInfo and stepInfo.onIncorrectCloseGuide

			if stepInfo then
				stepInfo.onIncorrectCloseGuide = nil
			end

			if onIncorrectCloseGuide then
				onIncorrectCloseGuide(curStepId)
			end
		end

		if stepCfg.pressBlack == 1 then
			self.view.uGuide.guideMode = CS.XGUI.EGuideMode.Force
			self.view.uGuide.enabledWeakBackground = true
		else
			self.view.uGuide.guideMode = CS.XGUI.EGuideMode.Weak
			self.view.uGuide.enabledWeakBackground = false
		end

		self:refreshMaskAnimType()

		if self.stepInfo.addClickLinstener and stepCfg.pressBlack ~= 0 and stepCfg.force ~= 1 then
			self.view.uGuide:AddFocusBtnClickLinstener()
		end

		local dir = stepCfg.orientation

		if dir == nil or dir == 0 then
			self.view.uGuide:SetPopupDirection(CS.XGUI.EPopupDirection.AutoVertical)
		elseif dir == 1 then
			self.view.uGuide:SetPopupDirection(CS.XGUI.EPopupDirection.Up)
		elseif dir == 2 then
			self.view.uGuide:SetPopupDirection(CS.XGUI.EPopupDirection.Down)
		elseif dir == 3 then
			self.view.uGuide:SetPopupDirection(CS.XGUI.EPopupDirection.Left)
		elseif dir == 4 then
			self.view.uGuide:SetPopupDirection(CS.XGUI.EPopupDirection.Right)
		end

		self.view.uGuide.force = stepCfg.force == 1
		self.view.uGuide.canSkip = stepCfg.skip == 1

		self.view.uGuide:OpenGuide()
	end

	if keyBindingPros ~= nil then
		for i = 0, keyBindingPros.Length - 1 do
			keyBindingPros[i].enabled = true
		end
	end
end

function GuidePanelCtrl:openDragGuide(stepCfg)
	if not stepCfg then
		return
	end

	if stepCfg.directionMethod == Const.GUIDE_DIRECTION_TYPE.GUIDE_PORINT_TYPE_CONTROL then
		if stepCfg.force == 1 then
			self:forceTakeOver(stepCfg)
		else
			LuaUIUtils.setUIViewVisible(self.view.virtualBtn, false)
			self:setIsModel(false)
		end

		self.view.uGuide:InitDrag(self.stepInfo.targetBtnTransStart, self.stepInfo.targetBtnTransEnd)

		self.view.uGuide.useMaskHoleOnlyForFocus = false
		self.view.uGuide.guideID = self.curStepId

		function self.view.uGuide.onCloseGuideStep(curStepId)
			local onCloseGuideStep = self.stepInfo.onCloseGuideStep

			self.stepInfo.onCloseGuideStep = nil

			if onCloseGuideStep then
				onCloseGuideStep(curStepId)
			end
		end

		if stepCfg.pressBlack == 1 then
			self.view.uGuide.guideMode = CS.XGUI.EGuideMode.Force
			self.view.uGuide.enabledWeakBackground = true
		else
			self.view.uGuide.guideMode = CS.XGUI.EGuideMode.Weak
			self.view.uGuide.enabledWeakBackground = false
		end

		self:refreshMaskAnimType()

		self.view.uGuide.force = stepCfg.force == 1
		self.view.uGuide.canSkip = stepCfg.skip == 1

		self.view.uGuide:OpenGuide()
	end
end

function GuidePanelCtrl:pauseGuide(pause)
	self.view.uGuide:PauseGuide(pause)
end

function GuidePanelCtrl:setDragAnimPos()
	if self.view then
		local objectReference = self.view.guideDrag

		if not objectReference then
			return
		end

		local endWidget = objectReference:GetRefValue("endBtn")
		local startWidget = objectReference:GetRefValue("startBtn")
		local imgDragRoute = objectReference:GetRefValue("imgDragRoute")
		local imgDragRouteLong = objectReference:GetRefValue("imgDragRouteLong")
		local dragPosRect = objectReference:GetRefValue("dragPosRect")
		local targetBtnTransStart = self.stepInfo.targetBtnTransStart:GetComponent("UWidget")
		local targetBtnTransEnd = self.stepInfo.targetBtnTransEnd:GetComponent("UWidget")
		local imgDragRouteNew = objectReference:GetRefValue("imgDragRouteNew")

		if startWidget and endWidget and targetBtnTransStart and targetBtnTransEnd and dragPosRect then
			local startDis = startWidget.transform.position.x - endWidget.transform.position.x

			startWidget.transform.position = targetBtnTransStart.transform.position
			endWidget.transform.position = targetBtnTransEnd.transform.position
			dragPosRect.transform.position = targetBtnTransStart.transform.position

			local pointStart = startWidget.transform.position
			local pointEnd = endWidget.transform.position
			local pointX = pointStart.x - pointEnd.x
			local pointY = pointStart.y - pointEnd.y
			local length = math.sqrt(pointX * pointX, pointY * pointY)
			local lineBgSize = imgDragRoute.transform.sizeDelta

			imgDragRoute:SetActive(length / startDis <= 2.5)
			imgDragRouteLong:SetActive(length / startDis > 2.5)

			local newlength = length / startDis * lineBgSize.x
			local direction = startWidget.transform.position - endWidget.transform.position
			local angle = math.atan2(direction.y, direction.x) * Mathf.Rad2Deg

			imgDragRoute.transform.localRotation = Quaternion.Euler(0, 0, angle)
			imgDragRouteLong.transform.localRotation = Quaternion.Euler(0, 0, angle - 180)

			UIUtils.PlayAnimation(imgDragRouteNew, "VX_Guide_Drag_Start_In_New", function()
				return
			end)

			local moveTime = length / startDis > 2.5 and 2 or 0.8

			self:moveAnimation(pointStart, pointEnd, moveTime)
		end
	end
end

function GuidePanelCtrl:moveAnimation(startPos, endPos, moveTime)
	local tempStart = startPos
	local tempEnd = endPos
	local time = 0
	local duration = moveTime
	local objectReference = self.view.guideDrag

	if not objectReference then
		return
	end

	local imgDragRoute = objectReference:GetRefValue("imgDragHandle")
	local dragPosRect = objectReference:GetRefValue("dragPosRect")
	local imgDragRouteA = objectReference:GetRefValue("imgDragRoute")
	local imgDragRouteLong = objectReference:GetRefValue("imgDragRouteLong")
	local startWidget = objectReference:GetRefValue("startBtn")
	local imgDragRouteNew = objectReference:GetRefValue("imgDragRouteNew")

	if not imgDragRoute or not dragPosRect then
		return
	end

	local isplayAnim = false
	local isPlayEffectAnim = false

	dragPosRect.transform.position = tempStart
	self.updateTimer = self:startTimer(function()
		if time <= duration then
			isplayAnim = false

			if not isPlayEffectAnim then
				isPlayEffectAnim = true

				if moveTime > 0.8 then
					imgDragRouteLong:SetActive(false)
					imgDragRouteLong:SetActive(true)
					UIUtils.PlayAnimation(imgDragRouteNew, "VX_Node_Drag_Long_New", function()
						isplayAnim = true
					end)
				else
					imgDragRouteA:SetActive(false)
					imgDragRouteA:SetActive(true)
					UIUtils.PlayAnimation(imgDragRouteNew, "VX_Node_Drag_Short_New", function()
						isplayAnim = true
					end)
				end
			end

			local t = time / duration > 0 and time / duration or 0
			local easedT = self:easeOutQuad(t)
			local currentPosition = tempStart + (tempEnd - tempStart) * easedT

			dragPosRect.transform.position = currentPosition
			dragPosRect.transform.localPosition.z = 0
		elseif imgDragRouteNew and startWidget and isplayAnim then
			dragPosRect.transform.position = tempStart

			startWidget:SetActive(false)
			startWidget:SetActive(true)
			UIUtils.PlayAnimation(imgDragRouteNew, "VX_Guide_Drag_Start_In_New", function()
				return
			end)

			isPlayEffectAnim = false
			time = 0
		end

		time = time + 0.05
	end, 0, true)
end

function GuidePanelCtrl:easeOutQuad(t)
	return t * (2 - t)
end

function GuidePanelCtrl:getDisRate(tempStart, tempEnd)
	local num = 1
	local dis = Vector3.Distance(tempStart, tempEnd) / 18 + num

	return num * dis
end

function GuidePanelCtrl:clearUpdateTimer()
	if self.updateTimer then
		self:killTimer(self.updateTimer)

		self.updateTimer = nil
	end
end

function GuidePanelCtrl:clearCanClickSkipTimer()
	if self.canClickSkipTimer then
		self:killTimer(self.canClickSkipTimer)

		self.canClickSkipTimer = nil
	end
end

function GuidePanelCtrl:clearPopupTipTimer()
	if self.popupTipTimer then
		self:killTimer(self.popupTipTimer)

		self.popupTipTimer = nil
	end
end

function GuidePanelCtrl:refreshToastGuidePanel()
	self.view.uGuide:ChangeToForceMode()
	self:changeMaskPage(1)
	self:forceTakeOver(self.curStepCfg)
end

function GuidePanelCtrl:forceTakeOver(stepCfg)
	local endChecks = stepCfg.endCheck

	if endChecks == nil then
		LuaUIUtils.setUIViewVisible(self.view.virtualBtn, false)

		return
	end

	local addVirtualBtn = false
	local endCheckCount = #endChecks

	for i = 1, endCheckCount do
		local endCheck = endChecks[i]

		if endCheck == Const.GUIDE_STEP_END.GSC_CLICK_BTN then
			local arg = endCheckCount == 1 and stepCfg.endCheckArg or stepCfg.endCheckArg[i]

			if stepCfg.type == Const.GUIDE_TYPE.GT_SPECIFIC_HIGHLIGHT then
				addVirtualBtn = self:tryAddSpecificHighlightVirtualBtnBinding(arg) or addVirtualBtn
			else
				addVirtualBtn = true

				self:addVirtualBtnBinding(arg)
			end
		elseif endCheck == Const.GUIDE_STEP_END.GSC_INPUT_TRIGGERED then
			local arg = stepCfg.endCheckArg[i]

			if type(arg) == "table" then
				arg = stepCfg.endCheckArg[i][1]
			end

			self:addKeyBinding(arg)

			local navMgr = pg.global.navMgr

			if not addVirtualBtn and pg.game.input:isUsingGamepad() and navMgr ~= nil and navMgr.IsVirtualMouseMode and NotNil(self.stepInfo.targetBtnTrans) then
				addVirtualBtn = true

				self:addVirtualBtnBinding()
			end
		end
	end

	self:changeMaskPage(2)
	LuaUIUtils.setUIViewVisible(self.view.virtualBtn, addVirtualBtn)
end

function GuidePanelCtrl:refreshTopTips(stepCfg)
	local objectReference = self.view.topTipsOR
	local mainCom = objectReference:GetRefValue("mainCom")
	local tipTxt = objectReference:GetRefValue("tipText")
	local progressCountDown = objectReference:GetRefValue("progressCountDown")

	self.guidePopupMainCom = mainCom

	mainCom:TryChangePage("Type", 0)
	mainCom:TryChangePage("CountDown", self.stepInfo.isCountDown and 1 or 0)
	ClientTextUtils.setText(tipTxt, pg.getLocalizationText(stepCfg.msg))

	local isCountDown, countDownTime = self:checkIsCountDown(stepCfg)

	progressCountDown:Stop()

	if isCountDown then
		progressCountDown:Play(countDownTime)
	end

	if self:shouldPlaySameTypeGroupShow() then
		mainCom:InvokeCallback(CS.XGUI.EInvokeTime.Show)
	end
end

function GuidePanelCtrl:refreshAICallPanel(stepCfg)
	local isShow = stepCfg.aiCallText or stepCfg.type == Const.GUIDE_TYPE.GT_FLOATING_AI

	self.view.mainCom:TryChangePage("ShowAICall", 0)

	if isShow then
		self.view.mainCom:TryChangePage("ShowAICall", 1)
	end

	if not isShow then
		return
	end

	if self.curStepCfg.pressBlack == 1 then
		self:changeMaskPage(1)
	end

	local objectReference = self.view.aiCallOR
	local mainCom = objectReference:GetRefValue("mainCom")
	local contextTxt = objectReference:GetRefValue("contentTxt")
	local keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")
	local nextBtn = objectReference:GetRefValue("nextBtn")
	local progressCountDown = objectReference:GetRefValue("progressCountDown")

	function nextBtn.luaClick()
		self:closeAICallPanel()
	end

	if stepCfg.type == Const.GUIDE_TYPE.GT_FLOATING_AI then
		ClientTextUtils.setText(contextTxt, pg.getLocalizationText(stepCfg.msg))
	else
		ClientTextUtils.setText(contextTxt, pg.getLocalizationText(stepCfg.aiCallText))
	end

	mainCom:TryChangePage("Next", 0)
	keyHotKeyContent:SetHotKeyPaths(self:getNextStepActionPath())
	LuaUIUtils.setUIViewVisible(keyHotKeyContent, false)

	local isCountDown, countDownTime = self:checkIsCountDown(stepCfg)

	mainCom:TryChangePage("CountDown", isCountDown and 1 or 0)
	progressCountDown:Stop()

	if isCountDown then
		progressCountDown:Play(countDownTime)
	end

	if stepCfg.type == Const.GUIDE_TYPE.GT_FLOATING_AI then
		self:clearCanClickSkipTimer()

		local function showNextStep()
			if self:isNextStepEnabled(stepCfg) then
				mainCom:TryChangePage("Next", 1)
				LuaUIUtils.setUIViewVisible(keyHotKeyContent, true)
				keyHotKeyContent:SetHotKeyPaths(self:getNextStepActionPath())
			end

			if self:shouldPlaySameTypeGroupShow() then
				mainCom:InvokeCallback(CS.XGUI.EInvokeTime.Show)
			end
		end

		if self:shouldPlaySameTypeGroupShow() then
			self.canClickSkipTimer = self:startTimer(showNextStep, ANIM_SHOW_DELAY_TIME, false)
		else
			showNextStep()
		end
	end
end

function GuidePanelCtrl:isShowAICallPanel()
	if self.view == nil or self.curStepCfg == nil then
		return false
	end

	return self.curStepCfg.type == Const.GUIDE_TYPE.GT_FLOATING_AI
end

function GuidePanelCtrl:closeAICallPanel()
	if self.curStepCfg == nil or self.curStepCfg.type ~= Const.GUIDE_TYPE.GT_FLOATING_AI then
		return
	end

	if not self:isNextStepEnabled(self.curStepCfg) then
		return
	end

	local objectReference = self.view.aiCallOR
	local contextTxt = objectReference:GetRefValue("contentTxt")

	if contextTxt:IsRunningTypewriter() then
		contextTxt:TryFinishedStoryText()
	elseif self.stepInfo.onCloseGuideStep then
		self.stepInfo.onCloseGuideStep(self.curStepId)
	end
end

function GuidePanelCtrl:isNextStepEnabled(stepCfg)
	if self.stepInfo == nil or self.stepInfo.isNextStepEnabled == nil then
		return false
	end

	return self.stepInfo.isNextStepEnabled(stepCfg)
end

function GuidePanelCtrl:getNextStepActionPath()
	return GuideInputUtils.getNextStepActionPath()
end

function GuidePanelCtrl:getSkipGroupActionPath()
	return GuideInputUtils.getGroupSkipActionPath()
end

function GuidePanelCtrl:onNextStepClick()
	if self.stepInfo == nil or self.stepInfo.onNextStep == nil then
		return false
	end

	return self.stepInfo.onNextStep()
end

function GuidePanelCtrl:getCurrentGuideAnimMainCom()
	if self.curStepCfg == nil or self.view == nil then
		return nil
	end

	if self.curStepCfg.type == Const.GUIDE_TYPE.GT_FLOATING_AUTO then
		return self.view.topTipsOR:GetRefValue("mainCom")
	elseif self.curStepCfg.type == Const.GUIDE_TYPE.GT_FLOATING_AI then
		return self.view.aiCallOR:GetRefValue("mainCom")
	end

	if self.guidePopupStepId == self.curStepId then
		return self.guidePopupMainCom
	end

	return nil
end

function GuidePanelCtrl:playFinishedState()
	if self.curStepCfg == nil or self.view == nil then
		return false
	end

	local mainCom = self:getCurrentGuideAnimMainCom()

	if IsNil(mainCom) then
		return false
	end

	if self.curStepCfg.type == Const.GUIDE_TYPE.GT_FLOATING_AUTO then
		mainCom:TryChangePage("Type", 1)
		mainCom:TryChangePage("TipsType", 1)
		self.view.mainCom:TryChangePage("ShowAICall", 0)
		self:changeMaskPage(0)
	elseif self.curStepCfg.type == Const.GUIDE_TYPE.GT_FLOATING_AI then
		self.view.mainCom:TryChangePage("ShowAICall", 1)
		self:changeMaskPage(0)
	else
		mainCom:TryChangePage("TipsType", 1)
	end

	pg.game.audio:triggerEvent("UI_NoviceGuide_Finish")

	return true
end

function GuidePanelCtrl:playHide()
	local mainCom = self:getCurrentGuideAnimMainCom()

	if IsNil(mainCom) then
		return false
	end

	mainCom:InvokeCallback(CS.XGUI.EInvokeTime.Hide)

	return true
end

function GuidePanelCtrl:finshGuideStep()
	if self.curStepCfg == nil or self.view == nil then
		return
	end

	self:clearUpdateTimer()
	self:clearCanClickSkipTimer()
	self:clearPopupTipTimer()

	self.guidePopupKeyHotKeyContent = nil

	self:clearGroupSkipUI()
	self:clearGroupSkipHoldTimer()

	self.groupSkipGamepadPressConsumed = false
	self.groupSkipInputBlocked = false
	self.groupSkipEnabled = false

	self:closeGuideVX()
	self:removeCustomBtnClickLinster()

	self.curStepCfg = nil

	self.view.uGuide:OnCloseGuideStep()
end

function GuidePanelCtrl:onHide()
	self.guidePopupKeyHotKeyContent = nil
	self.guidePopupMainCom = nil
	self.guidePopupStepId = nil

	self:clearUpdateTimer()
	self:clearPopupTipTimer()

	local progressCountDown = self.view.aiCallOR:GetRefValue("progressCountDown")

	progressCountDown:Stop()
	self:clearGroupSkipUI()
	self:clearGroupSkipHoldTimer()

	self.groupSkipGamepadPressConsumed = false
	self.groupSkipInputBlocked = false
	self.groupSkipEnabled = false

	self.view.mainCom:TryChangePage("GuideType", 0)
	self.view.uGuide:PauseGuide(true)
end

function GuidePanelCtrl:onDestroy()
	UICtrl.onDestroy(self)
	self:clearUpdateTimer()
	self:clearCanClickSkipTimer()
	self:clearPopupTipTimer()
	self:clearGroupSkipHoldTimer()
	self:unloadGuideVX()
end

function GuidePanelCtrl:refreshEndCheck(stepCfg)
	local endCheckList = stepCfg.endCheck

	if endCheckList == nil then
		return
	end

	local endArgs = stepCfg.endCheckArg
	local endCheckCount = #endCheckList

	for i = 1, endCheckCount do
		local endCheck = endCheckList[i]
		local endArg = endCheckCount == 1 and endArgs or endArgs[i]

		if endCheck == Const.GUIDE_STEP_END.GSC_CLICK_BTN then
			if stepCfg.type ~= Const.GUIDE_TYPE.GT_FOCUS and stepCfg.type ~= Const.GUIDE_TYPE.GT_SPECIFIC_HIGHLIGHT then
				local btnTransEnd = GuideUtils.getFocusTarget(endArg)

				self:addCustomBtnClickListener(btnTransEnd)
			elseif stepCfg.type == Const.GUIDE_TYPE.GT_SPECIFIC_HIGHLIGHT then
				local hasVirtualBtn = self:tryAddSpecificHighlightVirtualBtnBinding(endArg)

				if not hasVirtualBtn then
					local btnTransEnd = GuideUtils.getFocusTarget(endArg)

					self:addCustomBtnClickListener(btnTransEnd)
				end
			elseif NotNil(self.stepInfo.targetBtnTrans) then
				local btn = self.stepInfo.targetBtnTrans:GetComponent("UButton")

				if IsNil(btn) then
					self:addVirtualBtnBinding(endArg)
				end
			end
		elseif endCheck == Const.GUIDE_STEP_END.GSC_INPUT_DRAG then
			-- block empty
		end
	end
end

function GuidePanelCtrl:refreshUIModel()
	self:setIsModel(pg.game.input:isUsingGamepad())

	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("界面设置成模态", self:getIsModel())
	end
end

function GuidePanelCtrl:addKeyBinding(actionMapKey)
	if actionMapKey == nil then
		return
	end

	if not pg.game.input:isUsingGamepad() and self.curStepCfg.directionMethod == Const.GUIDE_DIRECTION_TYPE.GUIDE_PORINT_TYPE_CONTROL then
		return
	end

	local confirmBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "guideTriggerActionBind")

	confirmBind.isVirtual = true
	confirmBind.priority = -999999999
	confirmBind.actionPath = actionMapKey

	function confirmBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			local navMgr = pg.global.navMgr

			if pg.game.input:isUsingGamepad() and navMgr ~= nil and navMgr.IsVirtualMouseMode and self.curStepCfg ~= nil and self.curStepCfg.directionMethod ~= Const.GUIDE_DIRECTION_TYPE.GUIDE_PORINT_TYPE_CONTROL then
				return false
			end

			if self.curStepCfg == nil or self.curStepCfg.directionMethod ~= Const.GUIDE_DIRECTION_TYPE.GUIDE_PORINT_TYPE_CONTROL then
				if string.sub(actionMapKey, 1, 4) == "Raw/" then
					local stepId = self.curStepId
					local onCloseGuideStep = self.stepInfo and self.stepInfo.onCloseGuideStep

					self:startTimer(function()
						if self.curStepId == stepId and self.curStepCfg ~= nil and self.stepInfo ~= nil and self.stepInfo.onCloseGuideStep == onCloseGuideStep and onCloseGuideStep ~= nil then
							onCloseGuideStep(stepId, Const.GUIDE_STEP_FINISH_REASON.ACTION_TRIGGERED)
						end
					end, 0, false)
				end

				return true
			end

			local stepId = self.curStepId
			local onCloseGuideStep = self.stepInfo and self.stepInfo.onCloseGuideStep
			local clicked = self:onSimulateClickTargetBtn()

			if clicked and self.curStepId == stepId and self.stepInfo ~= nil and self.stepInfo.onCloseGuideStep == onCloseGuideStep and onCloseGuideStep ~= nil then
				self.stepInfo.onCloseGuideStep = nil

				onCloseGuideStep(stepId, Const.GUIDE_STEP_FINISH_REASON.ACTION_TRIGGERED)
			end

			return not clicked
		else
			return true
		end
	end
end

function GuidePanelCtrl:tryAddSpecificHighlightVirtualBtnBinding(endArg)
	local targetBtnTrans = GuideUtils.getFocusTarget(endArg)

	if IsNil(targetBtnTrans) then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("目标按钮为空，无法绑定虚拟按钮，检查是否为指定高亮引导！", self.curStepId)
		end

		return false
	end

	self.virtualBtnTargetTrans = targetBtnTrans

	LuaUIUtils.setUIViewVisible(self.view.virtualBtn, true)
	GuideUtils.rectSameAs(self.view.virtualBtn.rectTransform, targetBtnTrans:GetComponent("RectTransform"))

	return true
end

function GuidePanelCtrl:addVirtualBtnBinding(endArg)
	if endArg ~= nil then
		self.stepInfo.targetBtnTrans = GuideUtils.getFocusTarget(endArg)

		if IsNil(self.stepInfo.targetBtnTrans) then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("目标按钮为空，无法绑定虚拟按钮，检查是否为聚焦型引导！", self.curStepId)
			end

			return
		end
	end

	LuaUIUtils.setUIViewVisible(self.view.virtualBtn, true)

	local rect = self.stepInfo.targetBtnTrans:GetComponent("RectTransform")
	local virtualRect = self.view.virtualBtn.rectTransform

	GuideUtils.rectSameAs(virtualRect, rect)
end

function GuidePanelCtrl:onDragFinish()
	local btn = self.stepInfo.targetBtnTransStart:GetComponent("UButton")

	if btn then
		btn:OnWidgetEndDrag()
		self.ctrl:onPropEndDrag(btn, dropWidget)
	end
end

function GuidePanelCtrl:onSimulateClickTargetBtn(targetBtnTrans)
	targetBtnTrans = targetBtnTrans or self.virtualBtnTargetTrans or self.stepInfo.targetBtnTrans

	if IsNil(targetBtnTrans) then
		return false
	end

	local btn = targetBtnTrans:GetComponent("UButton")

	if btn then
		btn:OnClickSimulate()

		return true
	end

	if LoggerManager.checkLogger(LoggerConst.WARN) then
		logger:warn("%d 引导指向的控件未包含 UButton 组件，将无法触发模拟点击功能 ,请检查 !!!", self.curStepId)
	end

	return false
end

function GuidePanelCtrl:addCustomBtnClickListener(btnTrans)
	if IsNil(btnTrans) then
		return
	end

	self.customEndCheckBtnTrans = btnTrans
	self.view.uGuide.guideID = self.curStepId

	function self.view.uGuide.onCloseGuideStep(curStepId)
		if self.curStepId == nil or self.curStepId ~= curStepId then
			return
		end

		local onCloseGuideStep = self.stepInfo.onCloseGuideStep

		self.stepInfo.onCloseGuideStep = nil

		if onCloseGuideStep then
			onCloseGuideStep(curStepId)
		end
	end

	self.view.uGuide:AddCustomBtnClickLinster(btnTrans)
end

function GuidePanelCtrl:removeCustomBtnClickLinster()
	if IsNil(self.customEndCheckBtnTrans) then
		return
	end

	self.view.uGuide:RemoveCustomBtnClickLinster(self.customEndCheckBtnTrans)

	self.customEndCheckBtnTrans = nil
end

function GuidePanelCtrl:changeMaskPage(page)
	self.view.mainCom:TryChangePage("ShowMask", page)
end

function GuidePanelCtrl:checkIsCountDown(stepCfg)
	local countDownTime = stepCfg.stepOneTime
	local isCountDown = countDownTime ~= nil
	local endChecks = stepCfg.endCheck

	if endChecks ~= nil then
		for i = 1, #endChecks do
			local endCheck = endChecks[i]

			if endCheck == Const.GUIDE_STEP_END.GSC_COUNT_DOWN then
				local endCheckArgs = stepCfg.endCheckArg

				if endCheckArgs ~= nil then
					local endCheckArg = endCheckArgs[i]

					if endCheckArg ~= nil then
						if type(endCheckArg) == "table" then
							countDownTime = endCheckArg[1]
						elseif type(endCheckArg) == "number" then
							countDownTime = endCheckArg
						end
					end
				end
			end
		end
	end

	if isCountDown == true and countDownTime == nil then
		logger:error(" %d 引导步配置的倒计时结束参数有问题 ,请检查 !!!", self.curStepId)
	end

	isCountDown = countDownTime ~= nil

	return isCountDown, countDownTime
end

return GuidePanelCtrl
