-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Photo\\Component\\NormalPhotoUIComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local NoticeDef = require("Common.NoticeDef")
local PhotoIdentifyData = require("Data.photo_identify_data")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local fingerGestures = fingerGestures
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local TimeUtils = require("Common.Utils.TimeUtils")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local PhotoEntityTypeIdentification = require("Guis.Panels.Photo.PhotoEntityTypeIdentification")
local EModelUtils = require("Entities.Utils.EModelUtils")
local NormalPhotoUIComponent = Class.LightClass("NormalPhotoUIComponent", UIComponent)
local bit = bit
local lshift = bit.lshift
local bor = bit.bor
local ClientConst = require("Const.ClientConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HotkeyConst = require("Const.HotkeyConst")
local SysNoticeData = require("Data.sys_notice_data")
local TriggerConst = require("Common.Const.TriggerConst")
local TriggerData = require("Data.trigger_data")
local CustomTriggerData = require("Data.custom_trigger_data")
local CustomTriggerMapData = require("Data.custom_trigger_map_data")
local TriggerUtils = require("Common.Utils.TriggerUtils")
local ClientSettingUtils = require("Utils.ClientSettingUtils")
local logger = require("Core.Log.LoggerManager").getLogger("NormalPhotoUIComponent")

NormalPhotoUIComponent.PhotoType = {
	Selfie = "Selfie",
	Normal = "Normal",
	Follow = "Follow"
}
NormalPhotoUIComponent.PHOTO_EVENT_REFRESH_INTERVAL = 0.2

function NormalPhotoUIComponent:onCtor(info)
	if not info then
		return
	end

	self.preset = info.preset
end

function NormalPhotoUIComponent:ctor(ctrl, trans)
	UIComponent.ctor(self, ctrl, trans)
	LuaUIUtils.setUIViewVisible(self.view.boxSlider.content:Find("RayBox"):GetComponent("URayBox"), false)

	self.view.boxSlider.content:Find("TxtName"):GetComponent("UBaseText").text = "0°"
	self.needShowDialogue = false
	self.autoSaveRemainTime = 3
	self.petReportData = {}

	fingerGestures.Active()

	function fingerGestures.luaOnTouchStart(gesture)
		self.pickedUIElement = gesture.pickedUIElement ~= nil
	end

	function fingerGestures.luaOnTouchUp(gesture)
		self.pickedUIElement = false
	end

	function self.view.cameraCtrlDragUpdateListener.luaDragUpdate(x, y)
		self.isDraging = true

		if self.muteRotateCamera then
			return
		end

		if not pg.global.ui:runPlatformByMobile() then
			return
		end

		pg.game.input:setViewAxisByDeltaPixel(x * self.cameraRotateRate, y * self.cameraRotateRate)
	end

	function self.view.cameraCtrlDragUpdateListener.luaEndDrag()
		self.isDraging = false

		pg.game.input:setViewAxisByDeltaPixel(0, 0)
	end

	fingerGestures.EnablePinch(true)

	function fingerGestures.luaOnTouchUp2Fingers(gesture)
		self.muteRotateCamera = false
	end

	function fingerGestures.luaOnPinchIn(gesture)
		if gesture.touchCount >= 2 then
			if pg.global.inputMgr.moveAxis[1] ~= 0 or pg.global.inputMgr.moveAxis[2] ~= 0 or pg.global.inputMgr.moveAxis[3] ~= 0 then
				return
			end

			self.view.zoomDec.luaClick()

			self.muteRotateCamera = true

			pg.game.input:setViewAxisByDeltaPixel(0, 0)
		end
	end

	function fingerGestures.luaOnPinchOut(gesture)
		if gesture.touchCount >= 2 then
			if pg.global.inputMgr.moveAxis[1] ~= 0 or pg.global.inputMgr.moveAxis[2] ~= 0 or pg.global.inputMgr.moveAxis[3] ~= 0 then
				return
			end

			self.view.zoomAdd.luaClick()

			self.muteRotateCamera = true

			pg.game.input:setViewAxisByDeltaPixel(0, 0)
		end
	end

	pg.game.input:enablePhotoInput(true)
	LuaUIUtils.setUIViewVisible(self.view.quickCaptureEntry, false)
	self.view.animation:Play("UI_Prefab_Photograph_In")
	self:initPhotoEventConditions()
	self:setPhotoEventTopVisible(false)
end

function NormalPhotoUIComponent:findObjects()
	self.degreeText = self.view.boxSlider.content:Find("TxtName"):GetComponent("UBaseText")
end

function NormalPhotoUIComponent:onShow()
	self.view.btnReset.luaClick()
end

function NormalPhotoUIComponent:update()
	if not self.ctrl or not self.view then
		return
	end

	self:tryRefreshPhotoEventTop()

	if self.curPhotoType == self.PhotoType.Follow then
		self:tryUpdateInvestigateTarget()

		return
	end

	if pg.game.input.hudShowVirtualMouseCursor and pg.game.input:isUsingGamepad() then
		return
	end

	local hasMove = self.ctrl.moveX ~= 0 or self.ctrl.moveY ~= 0

	if self.moveState ~= hasMove then
		self:tryUpdateFocusDis()
	end

	self.moveState = hasMove

	self.ctrl.photoFuncMenuUIComponent:setOpacity("move", hasMove)
	pg.game.camera.photoCameraMode:move(self.ctrl.moveX * self.moveSpeedRate, self.ctrl.moveY * self.moveSpeedRate, self.ctrl.moveZ * self.moveSpeedRate)
	self:tryUpdateInvestigateTarget()
end

function NormalPhotoUIComponent:openPlayerLookAtFollow()
	self.openPlayerLookAtFollow = true
end

function NormalPhotoUIComponent:closePlayerLookAtFollow()
	self.openPlayerLookAtFollow = false

	pg.me:cancelLookAtRole(0.5)
end

function NormalPhotoUIComponent:updateLookAt()
	if self.openPlayerLookAtFollow then
		local worldPos = pg.game.camera.photoCameraMode.cameraMode:GetLookAtPos()

		pg.me:lookAtPos(worldPos, false)
	end
end

function NormalPhotoUIComponent:tryUpdateInvestigateTarget()
	if self._targetTemplateId then
		local entityInfos, _ = self:getPuppetInViewport(true, true)
		local worldPos

		for i = 1, #entityInfos do
			for _, targetId in pairs(self._targetTemplateId) do
				if targetId == entityInfos[i][1] then
					worldPos = entityInfos[i][2]

					break
				end
			end

			if worldPos then
				break
			end
		end

		if worldPos then
			self.view.targetAppearUWidget:SetActive(true)

			self._targetActive = true

			local cameraMgr = pg.global.cameraMgr
			local uiMgr = pg.global.uiMgr
			local lookAtCamera = cameraMgr.uiSceneCameraInst or cameraMgr.worldCameraInst
			local uiCamera = uiMgr.orthographicCamera
			local uiPos = UIUtils.WorldToUI(worldPos, lookAtCamera, uiCamera)

			uiPos = Vector4(uiPos.x / uiPos.w, uiPos.y / uiPos.w, uiPos.z / uiPos.w, 1)
			self.view.targetContent.position = uiPos
		elseif self._targetActive then
			self.view.targetAppearUWidget:SetActive(false)

			self._targetActive = false
		end
	end
end

function NormalPhotoUIComponent:initPhotoEventConditions()
	self.photoEventConditions = {}
	self.nextPhotoEventRefreshTime = 0

	local triggerData = TriggerData.TAKE_PHOTO_BY_POS_AND_OBJECT
	local triggerType = triggerData and triggerData.trigger
	local triggerRegisterMap = triggerType and CustomTriggerMapData[triggerType]

	if not triggerRegisterMap then
		return
	end

	local added = {}

	for _, registerKeys in pairs(triggerRegisterMap) do
		for _, registerKey in ipairs(registerKeys) do
			local customDataId, conditionIndex = TriggerConst.parseCustomTriggerKey(registerKey)
			local conditionKey = string.format("%d_%d", customDataId, conditionIndex)

			if not added[conditionKey] then
				local customData = CustomTriggerData[customDataId]
				local condition = customData and customData.condition and customData.condition[conditionIndex]

				if condition and condition[TriggerConst.CUSTOM_TRIGGER_NAME_POS] == "TAKE_PHOTO_BY_POS_AND_OBJECT" then
					self.photoEventConditions[#self.photoEventConditions + 1] = {
						customDataId = customDataId,
						extraArg = condition[TriggerConst.CUSTOM_TRIGGER_EXTAR_TARGET_POS]
					}
					added[conditionKey] = true
				end
			end
		end
	end
end

function NormalPhotoUIComponent:setPhotoEventTopVisible(visible)
	local eventTopUWidget = self.view and self.view.eventTopUWidget

	if eventTopUWidget then
		eventTopUWidget:SetActive(visible)
	end
end

function NormalPhotoUIComponent:isInPhotoEventRange(extraArg)
	return pg.me and TriggerUtils._checkPhotoPosition(extraArg, pg.space and pg.space.sceneId, pg.me:getPosition()) or false
end

function NormalPhotoUIComponent:tryRefreshPhotoEventTop()
	local now = Time.realtimeSinceStartup

	if now < (self.nextPhotoEventRefreshTime or 0) then
		return
	end

	self.nextPhotoEventRefreshTime = now + self.PHOTO_EVENT_REFRESH_INTERVAL

	local triggerMap = pg.me and pg.me.triggerMap

	if not triggerMap or not self.photoEventConditions or #self.photoEventConditions == 0 then
		self:setPhotoEventTopVisible(false)

		return
	end

	local subjectMask

	for _, condition in ipairs(self.photoEventConditions) do
		if triggerMap:isRegister(condition.customDataId) and self:isInPhotoEventRange(condition.extraArg) then
			local targetMask = math.max(tonumber(condition.extraArg[4]) or 0, 0)

			if targetMask == 0 then
				self:setPhotoEventTopVisible(true)

				return
			end

			subjectMask = subjectMask or self.ctrl:_computeSubjectMask()

			if TriggerUtils._checkPhotoByPosAndObject(condition.extraArg, {
				pg.space and pg.space.sceneId,
				pg.me:getPosition(),
				subjectMask
			}) then
				self:setPhotoEventTopVisible(true)

				return
			end
		end
	end

	self:setPhotoEventTopVisible(false)
end

function NormalPhotoUIComponent:tryUpdateFocusDis()
	if self.curPhotoType == self.PhotoType.Follow then
		return
	end

	pg.game.camera.photoCameraMode.cameraMode:TryChangeFocusDistance(self.curForcePos)
end

function NormalPhotoUIComponent:findMinAndMaxDistance(entityId)
	local ent = pg.getEntity(entityId)
	local photoIds = ent:getConfigData().photoIdentifyIds
	local min = 999
	local max = 0

	for _, pId in pairs(photoIds) do
		local pInfo = PhotoIdentifyData[pId]
		local showDisMin = pInfo.showDistance[1]
		local showDisMax = pInfo.showDistance[2]

		min = math.min(min, showDisMin)
		max = math.max(max, showDisMax)
	end

	return min, max
end

function NormalPhotoUIComponent:findIconDisplayDistanceSection(entity)
	local photoIds = entity:getConfigData().photoIdentifyIds
	local min = 999
	local max = 999

	for _, pId in pairs(photoIds) do
		local pInfo = PhotoIdentifyData[pId]
		local takeDisMin = pInfo.takePhotoDistance[1]
		local takeDisMax = pInfo.takePhotoDistance[2]

		min = math.min(min, takeDisMin)
		max = math.min(max, takeDisMax)
	end

	return min, max
end

function NormalPhotoUIComponent:onEntityEnterView(entityId, distance)
	self.inRangeEntities[entityId] = distance
	self.totalInRangeEntities[entityId] = distance
end

function NormalPhotoUIComponent:onEntityExitView(entityId)
	if self.view == nil then
		return
	end

	self.inRangeEntities[entityId] = nil
end

function NormalPhotoUIComponent:onHide()
	return
end

function NormalPhotoUIComponent:initView()
	self.moveSpeedRate = 3
	self.muteRotateCamera = false
	self.cameraRotateRate = 1
	self.defaultPhotoTypeIndex = 1
	self.curForcePos = Vector2(Screen.width / 2, Screen.height / 2)
	self.moveState = false
	self.inRangeEntities = {}
	self.totalInRangeEntities = {}
	self.hide = false
	self.photoTypeOrder = {
		self.PhotoType.Normal,
		self.PhotoType.Selfie,
		self.PhotoType.Follow
	}
	self.curPhotoTypeIndex = pg.global.prefsCacheUtils:getInt(ClientConst.PrefKey.PhotoTypeIndex, self.defaultPhotoTypeIndex)
	self.curPhotoType = self.photoTypeOrder[self.curPhotoTypeIndex]

	if self.ctrl:isHomelandMode() then
		self.curPhotoType = self.PhotoType.Normal

		self.view.btnCameraMode:SetActive(false)
	end

	if self.ctrl.isSnapshot or self:checkIsDialogue() then
		self.curPhotoType = self.PhotoType.Follow
	end

	self.lastPhotoType = self.curPhotoType
	self.ctrl.keepPetActionOnExit = self.curPhotoType == self.PhotoType.Follow
	self.sliderShowList = {
		0.2,
		2.5,
		5,
		7.5,
		10
	}
	self.timePause = false
	self.photoCameraZoomUpdateCurve = pg.global.cameraMgr.vcManager:GetPhotoCameraZoomUpdateCurve()

	function self.view.takePhotoBtn.luaClick()
		self.ctrl:takePhoto(self._takePhotoCb, not self:needConfirmPhoto())
	end

	self.ctrl:bindHotKeyPerform("Photo/Space", function()
		if pg.game.input:isUsingGamepad() then
			return true
		end

		if self.ctrl:needBlockNormalBtn() then
			return true
		end

		if not self.view.cameraBtnsUWidget.gameObject.activeInHierarchy then
			pg.global.showBubbleMessageRaw(pg.getLocalizationText(SysNoticeData[12071].text))

			return
		end

		self.view.takePhotoBtn:OnClickSimulate()
	end)

	function self.view.captureBtn.luaClick()
		pg.global.ui.albumPhoto:open({
			photoInfo = self:getCurPhotoSprite()
		})
	end

	self.ctrl:bindHotKeyPerform("Photo/F", function()
		if self.ctrl:needBlockNormalBtn() then
			return true
		end

		self.view.captureBtn:OnClickSimulate()
	end, self.view.captureBtn.gameObject)
	self.view.capturedBtnHotKeyContent:SetHotKeyPaths(self.view.captureBtn.transform:GetComponent("KeyBindingPro").actionPath)

	function self.view.joyStick.luaValueChangedWhileDragging()
		if self.view == nil then
			return
		end

		self:setJoyStickVisible(true)

		if self.view.joyStickArea.gameObject.activeInHierarchy == true then
			self.view.joyStick.transform:SetSiblingIndex(-1)
		end
	end

	function self.view.joyStick.luaValueChanged(x, y, z)
		if self.view == nil then
			return
		end

		if self.curPhotoType == self.PhotoType.Follow then
			pg.global.inputMgr:SetMoveAxis(x, y, z)

			return
		end

		self.ctrl.moveX = x
		self.ctrl.moveY = y
	end

	function self.view.joyStick.luaJoyStickEndDrag()
		if self.view == nil then
			return
		end

		self:setJoyStickVisible(false)

		if self.view.joyStickArea.gameObject.activeInHierarchy == true then
			self.view.boxSlider.transform:SetSiblingIndex(-1)
		end

		if self.curPhotoType == self.PhotoType.Follow then
			pg.global.inputMgr:SetMoveAxis(0, 0, 0)

			return
		end

		self.ctrl.moveX = 0
		self.ctrl.moveY = 0
	end

	function self.view.btnUpUButton.luaPress()
		self.ctrl.moveZ = 1
	end

	function self.view.btnUpUButton.luaRelease()
		self.ctrl.moveZ = 0
	end

	function self.view.btnDownUButton.luaPress()
		self.ctrl.moveZ = -1
	end

	function self.view.btnDownUButton.luaRelease()
		self.ctrl.moveZ = 0
	end

	function self.view.btnReset.luaClick()
		self:reset()
	end

	function self.view.btnHideUIUButton.luaClick()
		if self.hide ~= false then
			self.hide = false

			self.view.btnHideUIUButton:TryChangePage("Hide", 0)
		else
			self.hide = true

			self.view.btnHideUIUButton:TryChangePage("Hide", 1)
		end

		self.view.btnCameraMode.renderOpacity = self.hide and 0 or 1
		self.view.btnReset.renderOpacity = self.hide and 0 or 1
		self.view.joyStickArea.renderOpacity = self.hide and 0 or 1
		self.view.closeBtn.renderOpacity = self.hide and 0 or 1
		self.view.btnMenuUButton.renderOpacity = self.hide and 0 or 1
		self.view.btnPoseUButton.renderOpacity = self.hide and 0 or 1
		self.view.keys.renderOpacity = self.hide and 0 or 1
		self.view.center2UWidget.renderOpacity = self.hide and 0 or 1
		self.view.identificationBtnsUWidget.renderOpacity = self.hide and 0 or 1
		self.view.btnVideoTapeUButton.renderOpacity = self.hide and 0 or 1
		self.view.takePhotoBtn.renderOpacity = self.hide and 0 or 1
		self.view.cameraMenuPanelUComponent.renderOpacity = self.hide and 0 or 1
		self.view.btnTimePauseUButton.renderOpacity = self.hide and 0 or 1
		self.view.titleUWidget.renderOpacity = self.hide and 0 or 1
		self.view.btnPhotographUButton.renderOpacity = self.hide and 0 or 1
		self.view.btnScanCodeUButton.renderOpacity = self.hide and 0 or 1
		self.view.btnAppearanceUButton.renderOpacity = self.hide and 0 or 1
		self.view.btnAlbumUButton.renderOpacity = self.hide and 0 or 1
		self.view.btnSettingUButton.renderOpacity = self.hide and 0 or 1
		self.view.btnFocusUButton.renderOpacity = self.hide and 0 or 1
		self.view.pictureQualityUWidget.renderOpacity = self.hide and 0 or 1
	end

	function self.view.btnTimePauseUButton.luaClick()
		self.timePause = not self.timePause
		pg.game.camera.photoCameraMode.cameraMode.isUseTimeScale = not self.timePause

		if self.timePause then
			pg.space:pauseGameByType(Const.GameTimeScaleType.PHOTO, -1)
			self.ctrl.photoFuncMenuUIComponent:pausePhotoSubjects()
			pg.game.input:enableControlInput(false, HotkeyConst.INPUT_BLOCK_FLAG.PhotoTimePause)
		else
			pg.space:resumeGameByType(Const.GameTimeScaleType.PHOTO)
			self.ctrl.photoFuncMenuUIComponent:resumePhotoSubjects()
			pg.game.input:enableControlInput(true, HotkeyConst.INPUT_BLOCK_FLAG.PhotoTimePause)
		end

		self.view.btnTimePauseUButton:TryChangePage("Pause", self.timePause and 1 or 0)
	end

	self.view.btnTimePauseUButton.interactable = self:checkCanTimePause()

	function self.view.btnVideoTapeUButton.luaClick()
		pg.global.showBubbleMessageRaw(pg.getGameString("FUNC_NOT_AVAILABLE"))
	end

	function self.view.btnCameraMode.luaClick()
		self.view.changeLensAnimation:Stop()
		self.view.changeLensAnimation:Play("VX_Pb_Photograph_ChangeLens")

		self.curPhotoTypeIndex = self.curPhotoTypeIndex + 1

		if self.curPhotoTypeIndex > #self.photoTypeOrder then
			self.curPhotoTypeIndex = 1
		end

		local prefKey

		if self._targetTemplateId then
			prefKey = ClientConst.PrefKey.EventPhotoTypeIndex
		else
			prefKey = ClientConst.PrefKey.PhotoTypeIndex
		end

		pg.global.prefsCacheUtils:setInt(prefKey, self.curPhotoTypeIndex)

		self.curPhotoType = self.photoTypeOrder[self.curPhotoTypeIndex]

		self:refreshPhotoType(true)
	end

	function self.view.btnFocusUButton.luaClick()
		local lockModeComponent = self.ctrl.lockModeComponent

		if lockModeComponent then
			lockModeComponent:openLockModel()
		end
	end

	function self.view.btnFocusUButton.luaLongPress()
		local lockModeComponent = self.ctrl.lockModeComponent

		if lockModeComponent then
			lockModeComponent:closeLockModel()
		end
	end

	local function tryChangeFocusDis()
		self.ctrl:deselectAllDIY()

		if self.isDraging then
			return
		end

		self.curForcePos = UnityInput.mousePosition

		self:tryUpdateFocusDis()

		local _, pos = CS.UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(self.view.rootWindowsRectTransform, UnityInput.mousePosition, CS.XGUI.UWidget.uiCamera)

		self.view.center2Transform.anchoredPosition = pos
	end

	self.view.bgClickUButton.luaClick = tryChangeFocusDis
	self.view.mobileCameraCtrlUButton.luaClick = tryChangeFocusDis

	if ClientSettingUtils.isCloudGame() then
		ClientTextUtils.setText(self.view.captureTip, "")
	else
		ClientTextUtils.setText(self.view.captureTip, pg.getGameString("SAVED_LOCAL"))
	end

	if self.curPhotoType == self.PhotoType.Normal or self.curPhotoType == self.PhotoType.Selfie then
		pg.game.camera:enablePhoto(true, self.ctrl.preset)
		pg.game.input:enableControlInput(false, HotkeyConst.INPUT_BLOCK_FLAG.Photo)
	elseif self.curPhotoType == self.PhotoType.Follow and pg.global.ui:checkUIOpen(UIConst.UI_ID_FUNC_MENU) then
		pg.global.ui.funcMenu:close()
	end

	if self.preset then
		self:applyPreset(self.preset)
	else
		self:refreshMoveOperateUI()
		self:refreshPhotoType()
	end
end

function NormalPhotoUIComponent:refreshPhotoType(needDelay)
	if self.curPhotoType == self.PhotoType.Normal then
		pg.game.camera.photoCameraMode:closeFollowType()

		self.moveSpeedRate = 3

		pg.game.camera.photoCameraMode:setEnableCameraLookAt(false)
		self.view.btnCameraMode:TryChangePage("CameraMode", 0)
		self.ctrl:tryTriggerAllPetsAction()
	elseif self.curPhotoType == self.PhotoType.Selfie then
		pg.game.camera.photoCameraMode:closeFollowType()

		self.moveSpeedRate = 0.5

		pg.game.camera.photoCameraMode:setEnableCameraLookAt(true)
		self.view.btnCameraMode:TryChangePage("CameraMode", 1)
		self:startTimer(function()
			AIControllerUtils.sendAIEvent(pg.me:getCurPetEntity(), "Msg_MasterSelfieMode")
		end, 0.1)
		self.ctrl:stopAllPetAction(true)

		local lockModeComponent = self.ctrl.lockModeComponent

		if lockModeComponent then
			lockModeComponent:closeLockModel()
		end
	elseif self.curPhotoType == self.PhotoType.Follow then
		if self.hasRefreshedPhotoType and self.lastPhotoType ~= self.PhotoType.Follow then
			self.ctrl:resetAllPetAction()
		end

		pg.game.camera.photoCameraMode:openFollowType()
		self.view.btnCameraMode:TryChangePage("CameraMode", 2)
	end

	self.lastPhotoType = self.curPhotoType
	self.hasRefreshedPhotoType = true
	self.ctrl.keepPetActionOnExit = self.curPhotoType == self.PhotoType.Follow
	self.ctrl.shouldBlockAction = self.curPhotoType == self.PhotoType.Follow

	if self.changePhotoTypeTimer then
		self:killTimer(self.changePhotoTypeTimer)
	end

	if needDelay then
		self.changePhotoTypeTimer = self:startTimer(function()
			pg.game.camera.photoCameraMode.cameraMode:SwitchPhotoType(self.curPhotoType)
			self:refreshPhotoTypeUI()
		end, 0.6)
	else
		pg.game.camera.photoCameraMode.cameraMode:SwitchPhotoType(self.curPhotoType)
	end

	self.ctrl:refreshFishEyeEffect(self.curPhotoType)
	self.ctrl:refreshLockState()
end

function NormalPhotoUIComponent:refreshPhotoTypeUI()
	self.ctrl:onPhotoTypeUpdate()
	self:refreshMoveOperateUI()
end

function NormalPhotoUIComponent:refreshMoveOperateUI()
	local showMoveOperate = self.curPhotoType == self.PhotoType.Normal or self.curPhotoType == self.PhotoType.Selfie

	if pg.global.ui:runPlatformByMobile() then
		self.view.btnUpUButton:SetActive(showMoveOperate)
		self.view.btnDownUButton:SetActive(showMoveOperate)
	else
		self.view.keys:SetActive(showMoveOperate)
	end

	self.view.btnReset:SetActive(showMoveOperate)
end

function NormalPhotoUIComponent:applyPreset(preset)
	if not preset then
		return
	end

	if preset.photoType then
		self.curPhotoType = preset.photoType
	end

	local _pxa, _pya, _pza = pg.me.eModel:GetPositionAgentPosEx()
	local playerPos = Vector3.New(_pxa, _pya, _pza)

	if self.curPhotoType == self.PhotoType.Normal and preset.cameraPos and preset.cameraRot then
		if preset.playerRot then
			EModelUtils.setAgentRotation(pg.me, Quaternion.Euler(preset.playerRot.x, preset.playerRot.y, preset.playerRot.z))
		end

		self:startTimer(function()
			pg.game.camera.photoCameraMode:AsyncTrans(preset.cameraPos.x + playerPos.x, preset.cameraPos.y + playerPos.y, preset.cameraPos.z + playerPos.z, preset.cameraRot.x, preset.cameraRot.y, preset.cameraRot.z)
		end, 0.2)
	end

	self:refreshMoveOperateUI()
	self:refreshPhotoType()
end

function NormalPhotoUIComponent:saveToPreset(preset)
	preset.photoType = self.curPhotoType

	local pos = pg.game.camera.photoCameraMode:getFollowPosition()
	local rot = pg.game.camera.photoCameraMode:getFollowEulerAngles()
	local _pxb, _pyb, _pzb = pg.me.eModel:GetPositionAgentPosEx()
	local _exb, _eyb, _ezb = pg.me.eModel:GetPositionAgentEulerEx()

	preset.cameraPos = {
		x = pos.x - _pxb,
		y = pos.y - _pyb,
		z = pos.z - _pzb
	}
	preset.cameraRot = {
		x = rot.x,
		y = rot.y,
		z = rot.z
	}
	preset.playerPos = {
		x = _pxb,
		y = _pyb,
		z = _pzb
	}
	preset.playerRot = {
		x = _exb,
		y = _eyb,
		z = _ezb
	}
	preset.sceneId = pg.me.sceneId

	self:retainDecimalPlaces(preset.cameraPos)
	self:retainDecimalPlaces(preset.cameraRot)
	self:retainDecimalPlaces(preset.playerPos)
	self:retainDecimalPlaces(preset.playerRot)
end

function NormalPhotoUIComponent:retainDecimalPlaces(table)
	for k, v in pairs(table) do
		table[k] = tonumber(string.format("%.2f", v))
	end
end

function NormalPhotoUIComponent:checkCanTimePause()
	return not pg.space:isMultiPlayerEnv()
end

function NormalPhotoUIComponent:reset()
	if self.curPhotoType == self.PhotoType.Follow then
		return
	end

	if self.ctrl.photoCameraTargetInfo then
		self.ctrl:applyPhotoCameraTarget()

		return
	end

	self.view.boxSlider.content.transform.localEulerAngles = Vector3.New(0, 0, 0)

	pg.game.camera.photoCameraMode:reset()
end

function NormalPhotoUIComponent:onDestroy()
	if pg.space then
		pg.space:resumeGameTimeScaleRequestsByType(Const.GameTimeScaleType.PHOTO)
	end

	self._targetTemplateId = nil

	if self.timerId then
		self.ctrl:killTimer(self.timerId)

		self.timerId = nil
	end

	self.entityTable = {}

	pg.game.camera:enablePhoto(false)

	self.inRangeEntities = {}
	self.totalInRangeEntities = {}

	if self.openPlayerLookAtFollow then
		self.openPlayerLookAtFollow = false

		if pg.me then
			pg.me:cancelLookAtRole(0.5)
		end
	end

	pg.game.input:enablePhotoInput(false)
	pg.game.camera.photoCameraMode:clearFollowType()

	if self.timePause then
		self.timePause = false
		pg.game.camera.photoCameraMode.cameraMode.isUseTimeScale = true

		if pg.space then
			pg.space:resumeGameByType(Const.GameTimeScaleType.PHOTO)
		end

		self.ctrl.photoFuncMenuUIComponent:resumePhotoSubjects()
		pg.game.input:enableControlInput(true, HotkeyConst.INPUT_BLOCK_FLAG.PhotoTimePause)
	end

	pg.game.input:setEnabledViewCtrl(true, ClientConst.ViewControl.PHOTO)
	pg.global.inputMgr:SetInputActionEnabled(HotkeyConst.INPUT_MAP_ACTION_KEY.Camera_Zoom, true, HotkeyConst.INPUT_BLOCK_FLAG.Default)
	pg.game.input:enableControlInput(true, HotkeyConst.INPUT_BLOCK_FLAG.Photo)

	if self.dialogueKeyLeftConsoleForceInactive then
		self:setDialogueKeyLeftConsoleForceInactive(false)
	end

	UIComponent.onDestroy(self)
end

function NormalPhotoUIComponent:setJoyStickVisible(visible)
	if self.view == nil then
		return
	end

	self.view.boxSlider.renderOpacity = visible and 0 or 1
	self.view.btnJS.renderOpacity = visible and 0 or 1
end

function NormalPhotoUIComponent:findClosetEntityToScreenCenter()
	local min = 99999999
	local minEnt

	for entId, _ in pairs(self.inRangeEntities) do
		local photoEnt = pg.getEntity(entId)
		local pos = photoEnt:getPosition()
		local x, y = pg.global.cameraMgr:GetTargetViewportPosXYZ(pos[1], pos[2], pos[3])
		local distance = (x - 0.5)^2 + (y - 0.5)^2

		if distance < min then
			minEnt = photoEnt
			min = distance
		end
	end

	return minEnt
end

function NormalPhotoUIComponent:savePhoto(traitId, captureTime, imgUrl)
	if self.photoSaved == true then
		pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_HAS_SAVED"))

		return
	end

	local _pxc, _pyc, _pzc = pg.me.eModel:GetPositionAgentPosEx()
	local playerPos = Vector3.New(_pxc, _pyc, _pzc)
	local photoTime = captureTime or self.curPhotoInfo and self.curPhotoInfo.ts or os.time()
	local photoImgUrl = imgUrl or self.curPhotoImgUrl
	local photoInfo = pg.global.mobileCameraMgr:GetPetPhotoInfo(photoTime, playerPos, pg.me.space.sceneId, self.curTemplateIds, self.curGenderInfos, self.curGenderInfos)

	if not traitId then
		local storageMode = ClientSettingUtils.getPhotoStorageMode()
		local saveToLocal = ClientSettingUtils.shouldSavePhotoToLocal(storageMode)
		local saveToCloud = ClientSettingUtils.shouldSavePhotoToCloud(storageMode)

		if not saveToLocal then
			Utils.uploadPhotoToOSS(photoImgUrl, photoInfo.ts, function(success, failureReason)
				if success then
					pg.game.event:takePetPhoto(self.curTemplateIds, self.curPhotoType == self.PhotoType.Selfie, nil)

					self.curPhotoInfo = photoInfo
					self.curPhotoImgUrl = nil
					self.photoSaved = true

					pg.global.showBubbleMessageRaw(ClientSettingUtils.getPhotoSaveSuccessText(storageMode))
				else
					local failureText = ClientSettingUtils.getPhotoSaveFailureText(failureReason)

					if failureText then
						pg.global.showBubbleMessageRaw(failureText)
					end
				end
			end)

			return
		end

		pg.global.mobileCameraMgr:SaveImageToAlbum(photoInfo, function(photoPath)
			if photoPath and photoPath ~= "" then
				pg.game.event:takePetPhoto(self.curTemplateIds, self.curPhotoType == self.PhotoType.Selfie, photoPath)

				self.curPhotoInfo = photoInfo
				self.curPhotoImgUrl = nil
				self.photoSaved = true

				if saveToCloud then
					Utils.uploadPhotoToOSS(photoImgUrl, photoInfo.ts, function(success, failureReason)
						local resultText

						if success then
							resultText = ClientSettingUtils.getPhotoSaveSuccessText(storageMode, photoPath)
						else
							resultText = ClientSettingUtils.getPhotoSaveFailureText(failureReason, photoPath) or ClientSettingUtils.getPhotoSaveSuccessText(ClientConst.PhotoStorageMode.Local, photoPath)
						end

						pg.global.showBubbleMessageRaw(resultText)
					end)
				else
					pg.global.showBubbleMessageRaw(ClientSettingUtils.getPhotoSaveSuccessText(storageMode, photoPath))
				end
			else
				pg.global.showBubbleMessage(NoticeDef.SAVE_PHOTOGRAPH_FAILED_DISC_FULL)
			end
		end)

		return
	end

	self.curPhotoInfo = photoInfo
	self.photoSaved = true

	pg.global.showBubbleMessage(NoticeDef.SAVE_PHOTOGRAPH)
end

function NormalPhotoUIComponent:postPetInView()
	local res, genderInfos = self:getPuppetInViewport(self._targetTemplateId ~= nil)

	self.curGenderInfos = genderInfos
	self.curTemplateIds = res

	if #res > 0 and pg.me ~= nil then
		pg.me:serverMsg("RPC_CS_TakePhotePet")
		self:tryNotifyArkCarnPhotoSave(res)
	end
end

function NormalPhotoUIComponent:tryNotifyArkCarnPhotoSave(pets)
	local phaseId = pg.me.arkcarnCurPhaseId

	if not phaseId or not (phaseId > 0) then
		return
	end

	local targetPets = pg.game.event:getVotedPetTemplateIds()

	for _, petId in pairs(pets) do
		if table.contains(targetPets, petId) then
			pg.global.showBubbleMessageRaw(pg.getGameString("ARK_CARNIVAL_21"), 3)

			break
		end
	end
end

function NormalPhotoUIComponent:getCurPhotoSprite(needSave)
	local item = {}
	local ts = self.curPhotoInfo.ts

	item.timeStamp = ts
	item.position = self.curPhotoInfo.pos
	item.path = self.curPhotoInfo.path
	item.sceneId = self.curPhotoInfo.sceneId
	item.sprite = self.view.photoSprite
	item.preset = self.ctrl:saveToPreset()
	item.needSave = needSave
	item.imgKey = self.ctrl.currentCaptureImageKey

	if self.ctrl.usePhotoCallback then
		item.usePhotoCallback = self.ctrl.usePhotoCallback
		item.onlySave = true
	end

	local quickPhoto = pg.global.ui.hudV2.quickPhoto
	local traitId = quickPhoto.quickPhotoId or quickPhoto.curAITraitPhotoId

	if traitId then
		item.traitId = traitId
	end

	return item
end

function NormalPhotoUIComponent:openAlbumToSave(captureTime, imgUrl)
	local _pxd, _pyd, _pzd = pg.me.eModel:GetPositionAgentPosEx()
	local playerPos = Vector3.New(_pxd, _pyd, _pzd)
	local photoInfo = pg.global.mobileCameraMgr:GetPetPhotoInfo(captureTime or os.time(), playerPos, pg.me.space.sceneId, self.curTemplateIds, self.curGenderInfos, self.curGenderInfos)

	self.curPhotoInfo = photoInfo
	self.curPhotoImgUrl = imgUrl
	photoInfo = self:getCurPhotoSprite(true)
	self.curSprite = photoInfo.sprite

	pg.global.ui.albumPhoto:open({
		photoInfo = photoInfo
	})
end

function NormalPhotoUIComponent:getPuppetInViewport(sortByDistance, needAdjustPos)
	local res = {}
	local temp = {}
	local allEntities = pg.getEntities()
	local entityGenders = {}

	table.clear(self.petReportData)

	for id, entity in pairs(allEntities) do
		local isPet = Utils.isPet(entity) or Utils.isPuppet(entity) and entity:getConfigData().npcType == Const.NPC_TYPE.Pet

		if isPet and PhotoEntityTypeIdentification.isEntityVisibleForPhoto(entity) then
			local entPos = entity:getPosition()
			local nearHeight, _ = entity:getCameraHeightInfo()
			local modelHeight = entity:getConfigData().modelHeight or nearHeight
			local height = (nearHeight + modelHeight) / 2
			local adjustPos = Vector3(entPos.x, entPos.y + height / 2, entPos.z)
			local distance = Vector3.Distance(adjustPos, pg.game.camera.photoCameraMode:getFollowPosition())
			local templateId = entity:getConfigData().petPrototypeId or 0

			entity.gender = entity.gender or Const.GENDER_TYPE_NONE

			if entity.gender ~= Const.GENDER_TYPE_NONE then
				local gender = entity.gender

				if entityGenders[templateId] == nil then
					entityGenders[templateId] = {
						[gender] = true
					}
				elseif not entityGenders[templateId][gender] then
					entityGenders[templateId][gender] = true
				end
			end

			temp[#temp + 1] = {
				templateId = templateId,
				dis = distance,
				adjustPos = adjustPos,
				gender = entity.gender
			}

			local existingIndex

			for index, existingData in ipairs(self.petReportData) do
				if existingData.templateId == templateId and existingData.label == entity.label then
					existingIndex = index

					break
				end
			end

			if existingIndex then
				if distance < self.petReportData[existingIndex].dis then
					self.petReportData[existingIndex] = {
						templateId = templateId,
						label = entity.label,
						dis = distance
					}
				end
			else
				self.petReportData[#self.petReportData + 1] = {
					templateId = templateId,
					label = entity.label,
					dis = distance
				}
			end
		end
	end

	if sortByDistance then
		table.sort(temp, function(a, b)
			return a.dis <= b.dis
		end)
	end

	for i = 1, #temp do
		if needAdjustPos then
			res[#res + 1] = {
				temp[i].templateId,
				temp[i].adjustPos
			}
		else
			table.insert(res, temp[i].templateId)
		end
	end

	local genderFinal = {}

	for tId, genderInfo in pairs(entityGenders) do
		genderFinal[tId] = {}

		for gender, _ in pairs(genderInfo) do
			table.insert(genderFinal[tId], gender)
		end
	end

	return res, genderFinal
end

function NormalPhotoUIComponent:applyInvestigateInfo(templateIds, cb)
	self._targetTemplateId = templateIds

	function self._takePhotoCb()
		if self.curPhotoInfo then
			local templateIds = self.curTemplateIds
			local path = self.curPhotoInfo.path
			local sprite = self.curSprite
			local timeStamp = self.curPhotoInfo.ts
			local position = self.curPhotoInfo.pos
			local sceneId = self.curPhotoInfo.sceneId
			local genderInfos = self.curGenderInfos

			if cb then
				cb(templateIds, path, timeStamp, position, sceneId, genderInfos, sprite)
			end
		end
	end

	if not self.ctrl.isSnapshot then
		self.curPhotoTypeIndex = pg.global.prefsCacheUtils:getInt(ClientConst.PrefKey.EventPhotoTypeIndex, self.defaultPhotoTypeIndex)
		self.curPhotoType = self.photoTypeOrder[self.curPhotoTypeIndex]

		self:refreshPhotoType(true)
	end
end

function NormalPhotoUIComponent:checkIsDialogue()
	return self.ctrl.photoMode == self.ctrl.ModeType.TASK_DIALOGUE
end

function NormalPhotoUIComponent:needConfirmPhoto()
	return self.ctrl.photoMode == self.ctrl.ModeType.NORMAL_MODE or self.ctrl.usePhotoCallback ~= nil
end

function NormalPhotoUIComponent:initHomelandMode()
	self.view.btnAppearanceUButton:SetActive(false)
	self.view.btnAlbumUButton:SetActive(false)
	self.view.btnSettingUButton:SetActive(false)
	self.view.btnScanCodeUButton:SetActive(false)
	self.view.btnFocusUButton:SetActive(false)
	self.view.btnTimePauseUButton:SetActive(false)
end

function NormalPhotoUIComponent:setDialogueKeyLeftConsoleForceInactive(value)
	if self.view and self.view.keyLeftConsoleUWidget then
		self.view.keyLeftConsoleUWidget:SetForceInactive(CS.XGUI.ForceInactiveSource.Business, value)

		self.dialogueKeyLeftConsoleForceInactive = value
	end
end

function NormalPhotoUIComponent:initDialogueMode()
	self.view.widget:TryChangePage("PCSettingWidgetShow", 0)
	self.view.btnCameraMode:SetActive(false)
	self.view.btnFocusUButton:SetActive(false)
	self.view.btnVideoTapeUButton:SetActive(false)
	self.view.btnPhotographUButton:SetActive(false)
	self.view.btnTimePauseUButton:SetActive(false)
	self.view.btnReset:SetActive(false)
	self.view.zoom:SetActive(false)
	self.view.closeBtn:SetActive(false)
	self.view.titleUWidget:SetActive(false)
	self.view.operateMobileUWidget:SetActive(false)
	self:setDialogueKeyLeftConsoleForceInactive(true)

	function self._takePhotoCb()
		self:setDialogueKeyLeftConsoleForceInactive(false)
		self.ctrl:closeInDialogueMode()
		pg.game.input:setEnabledViewCtrl(true, ClientConst.ViewControl.PHOTO)
		pg.global.inputMgr:SetInputActionEnabled(HotkeyConst.INPUT_MAP_ACTION_KEY.Camera_Zoom, true, HotkeyConst.INPUT_BLOCK_FLAG.Default)
	end

	pg.game.input:enableControlInput(false, HotkeyConst.INPUT_BLOCK_FLAG.Photo)
	pg.game.input:setEnabledViewCtrl(false, ClientConst.ViewControl.PHOTO)
	pg.global.inputMgr:SetInputActionEnabled(HotkeyConst.INPUT_MAP_ACTION_KEY.Camera_Zoom, false, HotkeyConst.INPUT_BLOCK_FLAG.Default)
end

function NormalPhotoUIComponent:reportPhotoLog()
	local photoContent = PhotoEntityTypeIdentification.getIdentifiedTypesInViewport()
	local petList = {}

	if self.petReportData and #self.petReportData > 0 then
		table.sort(self.petReportData, function(a, b)
			return a.dis <= b.dis
		end)

		for i = 1, #self.petReportData do
			local petData = self.petReportData[i]

			petList[i] = {
				pet_id = tostring(petData.templateId),
				label = petData.label
			}
		end
	end

	local sceneId = tonumber(pg.space and pg.space.sceneId) or 0
	local areaId = 0

	if sceneId ~= 0 then
		local playerPos = pg.me:getPosition()

		areaId = tonumber(pg.game.map:inWhichBlock(sceneId, false, {
			x = playerPos[1],
			z = playerPos[3]
		})) or 0
	end

	local reportData = {
		content = photoContent,
		pet_list = petList,
		scene_id = sceneId,
		area_id = areaId,
		type = self.curPhotoTypeIndex
	}

	LuaUIUtils.sendCustomLog(Const.BILogName.PHOTO_POINT, reportData)
end

return NormalPhotoUIComponent
