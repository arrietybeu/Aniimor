-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Photo\\PhotoCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local bit = bit
local UIUtils = UIUtils
local UICtrl = require("Guis.UICtrl")
local NormalPhotoUIComponent = require("Guis.Panels.Photo.Component.NormalPhotoUIComponent")
local LockModelUIComponent = require("Guis.Panels.Photo.Component.LockModelUIComponent")
local QuickCaptureUIComponent = require("Guis.Panels.Photo.Component.QuickCaptureUIComponent")
local PhotoFuncMenuUIComponent = require("Guis.Panels.Photo.Component.PhotoFuncMenuUIComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local HotkeyConst = require("Const.HotkeyConst")
local ClientConst = require("Const.ClientConst")
local MessageName = require("Const.MessageName")
local PetData = require("Data.pet_data")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local PhotoCtrl = Class.LightClass("PhotoCtrl", UICtrl)
local GamePadNavigation = require("Utils.GamePadNavigation")
local EventConst = require("Const.EventConst")
local Const = require("Common.Const.Const")
local PhotoIdentifyData = require("Data.photo_identify_data")
local ResPointUtils = require("Common.Utils.ResPointUtils")
local Utils = require("Common.Utils.Utils")
local PetTraitData = require("Data.pet_trait_data")
local Time = require("Core.Common.Time")
local GmToolUtils = require("Utils.GmToolUtils")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local CallbackHandler = require("Core.Common.CallbackHandler")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local PhotoEntityTypeIdentification = require("Guis.Panels.Photo.PhotoEntityTypeIdentification")
local ClientTextUtils = require("Utils.ClientTextUtils")
local SUBJECT_TYPE_TO_MASK_BIT = {
	[PhotoEntityTypeIdentification.EntityType.SELF_PLAYER] = Const.PHOTO_SUBJECT_MASK.MAIN_CHAR,
	[PhotoEntityTypeIdentification.EntityType.OTHER_PLAYER] = Const.PHOTO_SUBJECT_MASK.FRIEND,
	[PhotoEntityTypeIdentification.EntityType.SELF_PET] = Const.PHOTO_SUBJECT_MASK.PET,
	[PhotoEntityTypeIdentification.EntityType.OTHER_PET] = Const.PHOTO_SUBJECT_MASK.PET,
	[PhotoEntityTypeIdentification.EntityType.NPC] = Const.PHOTO_SUBJECT_MASK.NPC
}
local PHOTO_TOPLOGO_KEEP_COMPONENTS = {
	[UIConst.TOPLOGO_COMPONENT.PHOTO] = true
}

PhotoCtrl.FRAME_OPACITY = 0.25
PhotoCtrl.messages = {
	[MessageName.PHOTO_TRAIT_RESEARCH] = {
		"refreshCapturePhotoInfo",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	},
	[MessageName.PHOTO_SCAN_CODE] = {
		"onScanQRCode",
		true
	},
	[MessageName.PHOTO_ASSET_UNLOCK_CHANGED] = {
		"onPhotoAssetUnlockChanged",
		true
	},
	[MessageName.VIDEO_QUALITY_CHANGED] = {
		"onVideoQualityChanged",
		true
	}
}
PhotoCtrl.ModeType = {
	TASK_DIALOGUE = "dialogue",
	PHOTO_IDENTIFY = "photoIdentify",
	QUICK_MODE = "quick",
	HOMELAND_MODE = "homeland",
	NORMAL_MODE = "normal"
}

function PhotoCtrl:open(info, cb, closeCb, sceneParams, onSceneLoadedCb, forceNoBlack)
	local isHomelandMode = info and info.photoMode == self.ModeType.HOMELAND_MODE

	if not self:checkUIOpen() and not isHomelandMode then
		pg.global.ui:closeAllNormalPanel()
	end

	UICtrl.open(self, info, cb, closeCb, sceneParams, onSceneLoadedCb, forceNoBlack)
end

function PhotoCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:setOtherTopLogoCompsVisible(false)

	if pg.game and pg.game.markShare then
		pg.game.markShare:setForceHide(pg.game.markShare.FORCE_HIDE_SOURCE.Photo, pg.game.markShare.FORCE_HIDE_SCOPE.All)
	end

	pg.game.camera.photoCameraMode.cameraMode:InitPhotoCamera()

	info = info or {}
	self.isSnapshot = info.snapshot
	self.usePhotoCallback = info.usePhotoCallback
	self.photoCameraTargetInfo = info.photoCameraTargetInfo
	self.cameraRotateRate = 4
	self.mouseLookActive = false
	self.lastTakePhotoTime = 0
	self.takePhotoInterval = 1000
	self.photoMode = info.photoMode or self.ModeType.NORMAL_MODE
	self.keepPetActionOnExit = false
	self.preset = info.preset
	self.lastAiTipTimes = {}
	self.aiTipInterval = 60

	self:initPictureQuality()
	self:startPhotoByMode(info)

	self.photoFuncMenuUIComponent = PhotoFuncMenuUIComponent.new(self, self.view.cameraMenuPanelUComponent.transform)

	self:refreshPhotoType()
	self:initNormalAdjustArgs()

	self.captureAITraitSuccess = false
	self.photoTraitInfo = nil
	self.updateTimer = self:startTimer(function()
		self:update()
	end, 0.1, true)
	pg.me.enableLockTarget = false

	local cb

	if info.snapshot then
		if self.view.safeBoxMobileUWidget then
			self.view.safeBoxMobileUWidget:SetActive(false)
		end

		function cb()
			self:snapshot()
		end
	end

	pg.global.ui:open(UIConst.UI_ID_PHOTO_LOGO, nil, cb)

	if self.preset then
		self:applyPreset(self.preset)
	end

	if self:isHomelandMode() and self.photoCameraTargetInfo then
		self:applyPhotoCameraTarget()
	end

	pg.global.navMgr:SetConsoleBarState("NotInFollowMode", not self:checkIsFollow())
end

function PhotoCtrl:snapshot()
	self:takePhoto(function()
		if self.autoCloseTimer then
			self:killTimer(self.autoCloseTimer)

			self.autoCloseTimer = nil
		end

		self.autoCloseTimer = self:startTimer(function()
			self:close()
		end, 3)
	end)
end

function PhotoCtrl:onDestroy()
	self:closePhotoLightDiy()

	local hudQuickPhoto = pg.global.ui.hudV2.quickPhoto

	if hudQuickPhoto then
		hudQuickPhoto:clearAllPhotoTopLogo()
	end

	self:setOtherTopLogoCompsVisible(true)
	self:restorePictureQuality()
	self:setMouseLookActive(false)

	if pg.game and pg.game.markShare then
		pg.game.markShare:setForceHide(pg.game.markShare.FORCE_HIDE_SOURCE.Photo, pg.game.markShare.FORCE_HIDE_SCOPE.None)
	end

	if self.photoCameraTargetObject then
		CS.UnityEngine.Object.Destroy(self.photoCameraTargetObject)

		self.photoCameraTargetObject = nil
	end

	self.usePhotoCallback = nil
	self.photoCameraTargetInfo = nil
	self.currentCaptureImageKey = nil
	self.photoComponent = nil
	self.photoMode = nil
	self.photoId = nil
	self.photoEnts = nil
	self.unlockedPhotoId = nil
	self.photoFuncMenuUIComponent = nil

	pg.global.navMgr:SetConsoleBarState("CanExcuteOpenCloseMenu", false)
	pg.global.navMgr:SetConsoleBarState("NotInFollowMode", false)
	self:clearPhotoUpdate()
	self:clearAutoHideTimer()
	self:tryClosePhotoTip()

	if self.needDelayClearCurPhotoAITrait then
		pg.global.ui.hudV2:tryClearCurPhotoAiTrait()
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PHOTO_LOGO) then
		pg.global.ui:close(UIConst.UI_ID_PHOTO_LOGO)
	end

	pg.me.enableLockTarget = true
	pg.global.mobileCameraMgr.luaCallBackPickImage = nil
	pg.global.qrCodeMgr.onScannedSuccess = nil
	pg.global.qrCodeMgr.onScannedFail = nil
	pg.game.input.hudShowVirtualMouseCursor = false
	self.gamepadMenuKeyProgressPress = nil

	UICtrl.onDestroy(self)
end

function PhotoCtrl:restorePhotoCaptureUI()
	pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.TAKE_PHOTO)

	local photoLogo = pg.global.ui.photoLogo

	if photoLogo and photoLogo.view then
		photoLogo:hideLogo()
	end
end

function PhotoCtrl:transferCaptureResult(sprite)
	if IsNil(sprite) or IsNil(self.captureResultSprite) or self.captureResultSprite ~= sprite then
		return false
	end

	self.captureResultTransferred = true

	return true
end

function PhotoCtrl:setPhotoLightDiyUIHidden(hidden)
	if hidden then
		if self.photoLightDiyUIHidden then
			return
		end

		self.photoLightDiyUIHidden = true
		self.photoLightDiyRootOpacity = self.view.rootComponent.renderOpacity
		self.photoLightDiyLogoVisible = pg.global.ui:checkUIVisible(UIConst.UI_ID_PHOTO_LOGO) == true
		self.view.rootComponent.renderOpacity = 0

		if self.photoLightDiyLogoVisible then
			pg.global.ui:hide(UIConst.UI_ID_PHOTO_LOGO)
		end

		return
	end

	if not self.photoLightDiyUIHidden then
		return
	end

	self.photoLightDiyUIHidden = false
	self.view.rootComponent.renderOpacity = self.photoLightDiyRootOpacity
	self.photoLightDiyRootOpacity = nil

	local logoWasVisible = self.photoLightDiyLogoVisible

	self.photoLightDiyLogoVisible = nil

	if logoWasVisible and pg.global.ui:checkUIOpen(UIConst.UI_ID_PHOTO_LOGO) then
		pg.global.ui:show(UIConst.UI_ID_PHOTO_LOGO)
	end
end

function PhotoCtrl:closePhotoLightDiy()
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PHOTO_LIGHT_DIY) then
		pg.global.ui:closeImmediately(UIConst.UI_ID_PHOTO_LIGHT_DIY)
	end

	self:setPhotoLightDiyUIHidden(false)
end

function PhotoCtrl:setOtherTopLogoCompsVisible(visible)
	local entities = pg.getEntities()

	if not entities then
		return
	end

	for _, entity in pairs(entities) do
		if entity.setOtherCompsVisible then
			entity:setOtherCompsVisible(PHOTO_TOPLOGO_KEEP_COMPONENTS, UIConst.TOPLOGO_VISIBLE_KEY.PHOTO_PANEL, visible)
		end
	end
end

function PhotoCtrl:initPictureQuality()
	self.originalVideoQuality = pg.game.setting:getVideoQuality()
	self.pictureQualityApplied = false

	function self.view.pictureQualitySelectedUButton.luaSelectChanged(isSelected)
		if self.isRefreshingPictureQuality then
			return
		end

		pg.game.setting:setBool(ClientConst.PrefKey.PhotoTopVideoQuality, isSelected)
		self:setPictureQualityEnabled(isSelected)
	end

	local showPictureQuality = self.originalVideoQuality ~= Const.VIDEO_QUALITY.TOP

	self.view.pictureQualityUWidget:SetActive(showPictureQuality)

	if not showPictureQuality then
		return
	end

	local enabled = pg.game.setting:getBool(ClientConst.PrefKey.PhotoTopVideoQuality, false)

	self.isRefreshingPictureQuality = true
	self.view.pictureQualitySelectedUButton.isSelected = enabled
	self.isRefreshingPictureQuality = false

	self:setPictureQualityEnabled(enabled)
end

function PhotoCtrl:onVideoQualityChanged(videoQuality)
	if self.isChangingPictureQuality then
		return
	end

	self.originalVideoQuality = videoQuality
	self.pictureQualityApplied = false

	local showPictureQuality = videoQuality ~= Const.VIDEO_QUALITY.TOP

	self.view.pictureQualityUWidget:SetActive(showPictureQuality)

	if not showPictureQuality then
		return
	end

	pg.game.setting:setBool(ClientConst.PrefKey.PhotoTopVideoQuality, false)

	self.isRefreshingPictureQuality = true
	self.view.pictureQualitySelectedUButton.isSelected = false
	self.isRefreshingPictureQuality = false
end

function PhotoCtrl:setVideoQualityForPictureQuality(videoQuality)
	self.isChangingPictureQuality = true

	pg.game.setting:setVideoQuality(videoQuality, false)

	self.isChangingPictureQuality = false
end

function PhotoCtrl:setPictureQualityEnabled(enabled)
	if self.originalVideoQuality == Const.VIDEO_QUALITY.TOP or self.pictureQualityApplied == enabled then
		return
	end

	local videoQuality = enabled and Const.VIDEO_QUALITY.TOP or self.originalVideoQuality

	self:setVideoQualityForPictureQuality(videoQuality)

	self.pictureQualityApplied = enabled
end

function PhotoCtrl:restorePictureQuality()
	if not self.pictureQualityApplied then
		return
	end

	self:setVideoQualityForPictureQuality(self.originalVideoQuality)

	self.pictureQualityApplied = false
end

function PhotoCtrl:onPhotoAssetUnlockChanged()
	if self.photoFuncMenuUIComponent then
		self.photoFuncMenuUIComponent:onPhotoAssetUnlockChanged()
	end
end

function PhotoCtrl:clearPhotoTip()
	if self.checkAIPhotoTip then
		self:killTimer(self.checkAIPhotoTip)

		self.checkAIPhotoTip = nil
	end

	self:tryClosePhotoTip()
end

function PhotoCtrl:startPhotoByMode(info)
	if self.photoMode == self.ModeType.QUICK_MODE then
		self.photoId = info.quickPhotoId
		self.photoEnts = info.quickPhotoEnts
		self.photoComponent = QuickCaptureUIComponent.new(self)
	elseif self.photoMode == self.ModeType.HOMELAND_MODE then
		self.photoComponent = NormalPhotoUIComponent.new(self, nil)

		self.photoComponent:initHomelandMode()
	elseif self.photoMode == self.ModeType.NORMAL_MODE or self.photoMode == self.ModeType.PHOTO_IDENTIFY then
		self.photoComponent = NormalPhotoUIComponent.new(self, nil)

		if info.investigateId then
			self.photoComponent:applyInvestigateInfo({
				info.investigateId
			}, info.investigateCb)
		else
			local mergedTargetIds = {}
			local phaseId = pg.me.arkcarnCurPhaseId

			if phaseId and phaseId > 0 then
				local carnTargetIds = pg.game.event:getVotedPetTemplateIds()

				for _, id in ipairs(carnTargetIds or EMPTY_TABLE) do
					mergedTargetIds[#mergedTargetIds + 1] = id
				end
			end

			local activityData = ActivityUtils.getFormResearchConfig()
			local surveyTargetId = activityData and activityData.pet1

			if surveyTargetId and pg.me.formResearchFinish ~= true then
				mergedTargetIds[#mergedTargetIds + 1] = surveyTargetId
			end

			if #mergedTargetIds > 0 then
				self.photoComponent:applyInvestigateInfo(mergedTargetIds, nil)
			end
		end

		self.lockModeComponent = LockModelUIComponent.new(self)
	elseif self.photoMode == self.ModeType.TASK_DIALOGUE then
		self.photoComponent = NormalPhotoUIComponent.new(self)

		self.photoComponent:initDialogueMode()
	end

	if self.photoMode == self.ModeType.PHOTO_IDENTIFY then
		self.view.rootComponent:TryChangePage("MultiTerminal", 2)
		self.view.rootComponent:TryChangePage("Identification", 1)
		self.lockModeComponent:openLockModel()
	end

	self:refreshAITraitPhoto()
end

function PhotoCtrl:refreshAITraitPhoto()
	local quickPhoto = pg.global.ui.hudV2.quickPhoto

	if self.photoMode == self.ModeType.NORMAL_MODE and quickPhoto.curAITraitPhotoId then
		local photoCfg = PhotoIdentifyData[quickPhoto.curAITraitPhotoId]

		if photoCfg == nil then
			return
		end

		if quickPhoto.curAITraitPointState == quickPhoto.TraitPointState.Before then
			self:showAIPhotoTip(photoCfg.waitText)
		elseif quickPhoto.curAITraitPointState == quickPhoto.TraitPointState.Playing then
			self:showAIPhotoTip(photoCfg.showText)

			self.checkAIPhotoTip = self:startTimer(function()
				self:trySetPhotoTip(quickPhoto.curAITraitData)
			end, 1, true)
		elseif quickPhoto.curAITraitPointState == quickPhoto.TraitPointState.After then
			if not self.captureAITraitSuccess and photoCfg.failText then
				self:showAIPhotoTip(photoCfg.failText)
			end

			self:clearPhotoTip()
		end
	end
end

function PhotoCtrl:showAIPhotoTip(id)
	if self.lastAiTipTimes[id] and self.lastAiTipTimes[id] + self.aiTipInterval > Time.realSecondCache then
		return
	end

	self.lastAiTipTimes[id] = Time.realSecondCache

	pg.me:tryRefreshAiIds(true, id, false)
end

function PhotoCtrl:initNormalAdjustArgs()
	self.moveX = 0
	self.moveY = 0
	self.moveZ = 0
	self.addZ = false
	self.minusZ = false

	pg.game.input:getInputMapProcessor(HotkeyConst.INPUT_MAP_ACTION_KEY.Photo):reset()
end

function PhotoCtrl:clearPhotoUpdate()
	if self.updateTimer then
		self:killTimer(self.updateTimer)

		self.updateTimer = nil
	end
end

function PhotoCtrl:clearAutoHideTimer()
	if self.autoHidePhotoTimer then
		self:killTimer(self.autoHidePhotoTimer)

		self.autoHidePhotoTimer = nil
	end
end

function PhotoCtrl:onShow()
	local petChat = pg.global.ui.petChat.view

	if petChat ~= nil then
		petChat.root.renderOpacity = 0
	end
end

function PhotoCtrl:onHide()
	self:setMouseLookActive(false)
	pg.game.input:enableControlInput(true, HotkeyConst.INPUT_BLOCK_FLAG.Photo)
end

function PhotoCtrl:onVisibleChange(visible)
	if visible then
		self:refreshGuideLabel()
	else
		self:setMouseLookActive(false)
	end
end

function PhotoCtrl:checkUILockCursor()
	if not pg.global.ui:runPlatformByMobile() and not pg.game.input:isUsingGamepad() then
		return self:checkIsFollow() or self.mouseLookActive
	end

	return PhotoCtrl.super.checkUILockCursor(self)
end

function PhotoCtrl:setMouseLookActive(active)
	if self.mouseLookActive == active then
		return
	end

	self.mouseLookActive = active

	if not active then
		pg.game.input:setViewAxis(0, 0)
	end

	pg.global.ui:refreshLockCursor()
end

function PhotoCtrl:getWhiteList()
	local whiteList = {}

	whiteList[UIConst.UI_ID_TOPLOGO] = true
	whiteList[UIConst.UI_ID_BOTTOM_DIALOGUE] = true
	whiteList[UIConst.UI_ID_NPC_CALL] = true
	whiteList[UIConst.UI_ID_AI_ASSISTANT] = true

	return whiteList
end

function PhotoCtrl:checkTimePause()
	if self.photoComponent then
		return self.photoComponent.timePause
	end

	return false
end

function PhotoCtrl:addListener()
	local showCursorBlockBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "PhotoShowCursorBlock")

	showCursorBlockBind.isVirtual = true
	showCursorBlockBind.priority = -1
	showCursorBlockBind.actionPath = "Camera/ShowCursor"

	local followAltActive = false

	function showCursorBlockBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			followAltActive = self:checkIsFollow()
		end

		local allowShowCursor = self:checkIsFollow() or followAltActive

		if inputInfo.phase == "Canceled" then
			followAltActive = false
		end

		return allowShowCursor
	end

	local mouseRightLookBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "PhotoMouseRightLook")

	mouseRightLookBind.isVirtual = true
	mouseRightLookBind.priority = -1
	mouseRightLookBind.actionPath = "Raw/MouseRight"

	function mouseRightLookBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Canceled" then
			self:setMouseLookActive(false)

			return true
		end

		if pg.global.ui:runPlatformByMobile() then
			return
		end

		if inputInfo.phase == "Performed" and self:checkIsNormalOrSelfie() then
			self:setMouseLookActive(true)
		end

		return true
	end

	local homelandPhotoViewAxisBlockBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "HomelandPhotoViewAxisBlock")

	homelandPhotoViewAxisBlockBind.isVirtual = true
	homelandPhotoViewAxisBlockBind.priority = -1
	homelandPhotoViewAxisBlockBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Camera_ViewAxis

	function homelandPhotoViewAxisBlockBind.luaTrigger(inputInfo)
		if self:isHomelandMode() and not self.mouseLookActive and inputInfo.phase == "Performed" then
			pg.game.input:setViewAxis(0, 0)

			return false
		end

		return true
	end

	local closeBind2 = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "closeBind2")

	closeBind2.isVirtual = true
	closeBind2.priority = -1
	closeBind2.actionPath = LuaUIUtils.getFuncActionPath(Const.FUNCTION_IDS.TAKEPHOTO)

	function closeBind2.luaTrigger(inputInfo)
		if pg.game.input:isUsingGamepad() then
			return true
		end

		if inputInfo.phase == "Performed" then
			self:closePanel()
		end
	end

	function self.view.closeBtn.luaClick()
		self:closePanel()
	end

	local leftShoulderBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "leftShoulderBind")

	leftShoulderBind.isVirtual = true
	leftShoulderBind.priority = 99999
	leftShoulderBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadLeftShoulder

	function leftShoulderBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self.isLeftShoulderPressed = true
		elseif inputInfo.phase == "Canceled" then
			self.isLeftShoulderPressed = false

			local photoProcessor = pg.game.input:getInputMapProcessor(HotkeyConst.INPUT_MAP_ACTION_KEY.Photo)

			if photoProcessor then
				photoProcessor.moveZWeight = 0

				photoProcessor:handleMoveWeight()
			end
		end

		return true
	end

	self.view.settingMenuHotKeyContent:SetHotKeyPaths("Hud/GamepadMenu")
	self.view.settingMenuProgressPressContainerUContainer:SetActive(true)

	if self.view.settingMenuProgressPressContainerUContainer then
		self.view.settingMenuProgressPressContainerUContainer:LoadDefaultUrlManually(function()
			self.gamepadMenuKeyProgressPress = self.view.settingMenuProgressPressContainerUContainer.content

			self.gamepadMenuKeyProgressPress:ProgressToValue(0, nil)
		end)
	end

	self:bindHotKey(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadLT, function()
		if pg.game.input:isUsingGamepad() then
			return true
		end

		if self:checkIsFollow() then
			pg.game.camera:zoom(-1)

			return
		end

		self.view.zoomAdd.luaClick()
	end, function(time)
		if self:needBlockNormalBtn() then
			return true
		end

		if self:checkIsFollow() then
			pg.game.camera:zoom(-1)

			return
		end

		self.view.zoomAdd.luaLongPress(time)
	end)
	self:bindHotKey(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRT, function()
		if pg.game.input:isUsingGamepad() then
			return true
		end

		if self:checkIsFollow() then
			pg.game.camera:zoom(1)

			return
		end

		self.view.zoomDec.luaClick()
	end, function(time)
		if self:needBlockNormalBtn() then
			return true
		end

		if self:checkIsFollow() then
			pg.game.camera:zoom(1)

			return
		end

		self.view.zoomDec.luaLongPress(time)
	end)

	if not self:isHomelandMode() then
		self:bindHotKey("Photo/F3", function()
			if pg.game.input:isUsingGamepad() then
				return true
			end

			self.view.btnAppearanceUButton:OnClickSimulate()
		end, nil, self.view.btnAppearanceUButton.gameObject)

		function self.view.btnAppearanceUButton.luaClick()
			LuaUIUtils.openPlayerAppearancePanel(function()
				pg.game.camera.photoCameraMode:setActive(true)
			end, function()
				pg.game.camera.photoCameraMode:setActive(false)
			end)
		end

		self:bindHotKey("Photo/F2", function()
			if pg.game.input:isUsingGamepad() then
				return true
			end

			self.view.btnAlbumUButton:OnClickSimulate()
		end, nil, self.view.btnAlbumUButton.gameObject)

		function self.view.btnAlbumUButton.luaClick()
			pg.global.ui.album:open()
		end

		self:bindHotKey("Photo/F1", function()
			if pg.game.input:isUsingGamepad() then
				return true
			end

			self.view.btnSettingUButton:OnClickSimulate()
		end, nil, self.view.btnSettingUButton.gameObject)

		function self.view.btnSettingUButton.luaClick()
			pg.global.ui:open(UIConst.UI_ID_SETTING)
		end

		self:bindHotKey("Photo/F5", function()
			if pg.game.input:isUsingGamepad() then
				return true
			end

			self.view.btnScanCodeUButton:OnClickSimulate()
		end, nil, self.view.btnScanCodeUButton.gameObject)

		function self.view.btnScanCodeUButton.luaClick()
			self:_openScanCodePopup()
		end
	end

	self:addNavFocusListener(CallbackHandler(self, "onNavFocusChange"))
	pg.global.navMgr:SetConsoleBarState("CanExcuteOpenCloseMenu", false)
	self.view.btnBackMainUButton:SetGamepadLongPress("Common/GamepadCancel", self.view.backKeyHotkeyContent.GameObject)

	local closeCommonBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "closeCommonBind")

	closeCommonBind.isVirtual = true
	closeCommonBind.priority = -1
	closeCommonBind.actionPath = "Common/ClosePanelCommon"

	function closeCommonBind.luaTrigger(inputInfo)
		if pg.game.input:isUsingGamepad() then
			return true
		end

		if inputInfo.phase == "Performed" then
			if pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_ITEM_TIP) then
				pg.global.ui:closePanel(UIConst.UI_ID_COMMON_ITEM_TIP)
			end

			local buttonPoppingUpTooltip = pg.global.inputMgr:GetButtonPoppingUpToolTip()

			if buttonPoppingUpTooltip then
				buttonPoppingUpTooltip:ClosePopup()
			else
				self:closePanel()
			end
		end
	end
end

function PhotoCtrl:isFocusOnDIYFrame()
	local focused = pg.global.navMgr.CurrentFocusedUContent
	local diyRoot = self.photoFuncMenuUIComponent and self.photoFuncMenuUIComponent.dIYRootRectTransform

	if IsNil(focused) or IsNil(diyRoot) then
		return false
	end

	local t = focused.transform

	while not IsNil(t) do
		if t == diyRoot then
			return true
		end

		t = t.parent
	end

	return false
end

function PhotoCtrl:onLensScroll(isAdd)
	if self.photoFuncMenuUIComponent and self.photoFuncMenuUIComponent.scrollLens then
		self.photoFuncMenuUIComponent:scrollLens(isAdd)
	end
end

function PhotoCtrl:onNavFocusChange()
	local isInStick = self:isFocusOnDIYFrame()

	self:setFocusInStickState(isInStick)
	pg.global.navMgr:SetConsoleBarState("CanExcuteOpenCloseMenu", false)

	if self.photoFuncMenuUIComponent and self.photoFuncMenuUIComponent.refreshDIYCanFocusStick then
		self.photoFuncMenuUIComponent:refreshDIYCanFocusStick()
	end
end

function PhotoCtrl:setFocusInStickState(value)
	pg.global.navMgr:SetConsoleBarState("FocusInStick", value == true)
end

function PhotoCtrl:refreshCanMoveCameraState()
	local raised = self.photoFuncMenuUIComponent and self.photoFuncMenuUIComponent.isMenuRaised and self.photoFuncMenuUIComponent:isMenuRaised()

	pg.global.navMgr:SetConsoleBarState("CanMoveCamera", not raised)
end

function PhotoCtrl:closePanel()
	if self.photoMode == self.ModeType.TASK_DIALOGUE then
		return
	end

	fingerGestures.DeActive()

	local petChat = pg.global.ui.petChat.view

	if petChat ~= nil then
		petChat.root.renderOpacity = 1
	end

	self:close()
end

function PhotoCtrl:closeInDialogueMode()
	self.photoMode = nil

	self:closePanel()
end

function PhotoCtrl:update()
	if self.photoComponent then
		self.photoComponent:update()
	end

	if self.photoFuncMenuUIComponent then
		self.photoFuncMenuUIComponent:update()
	end
end

function PhotoCtrl:takePhoto(cb, autoSave)
	if self.lastTakePhotoTime + self.takePhotoInterval > Time.realSecondCache * 1000 then
		return
	end

	local photoLogo = pg.global.ui.photoLogo
	local photoLogoReady = photoLogo and photoLogo.view

	autoSave = autoSave == nil or autoSave

	local captureTime = os.time()

	self.lastTakePhotoTime = Time.realSecondCache * 1000
	self.photoComponent.photoSaved = false

	pg.global.ui:hideAllUIByCustomKey(UIConst.UI_HIDE_KEY.TAKE_PHOTO, {
		[UIConst.UI_ID_PHOTO_LOGO] = true
	}, 5)

	if photoLogoReady and not GmToolUtils.closePhotoMark then
		photoLogo:showLogo()
	end

	if photoLogoReady then
		self.photoFuncMenuUIComponent:onBeginPhoto(photoLogo.view.transform)
	end

	local hudQuickPhoto = pg.global.ui.hudV2.quickPhoto

	if self.photoMode == self.ModeType.NORMAL_MODE and hudQuickPhoto.quickPhotoId then
		for _, ent in ipairs(hudQuickPhoto.quickPhotoEntities) do
			ent.eventEmitter:emit(EventConst.TOPLOGO_PHOTO, UIConst.PHOTO_TYPE.HIDDEN)
		end
	end

	local traitId

	local function restorePhotoUI()
		pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.TAKE_PHOTO)

		if photoLogoReady then
			photoLogo:hideLogo()
		end

		self.photoFuncMenuUIComponent:onEndPhoto(self.photoFuncMenuUIComponent.dIYRootRectTransform)
	end

	Utils.captureAndCheckPhoto(Const.PhotoCheckScene.Share, function(sprite, imgUrl, success, imageKey)
		if not success then
			restorePhotoUI()

			return
		end

		self.currentCaptureImageKey = imageKey

		local photoTitle = self.model:tryGetPhotoTitle()

		self.view:closeCapturePhoto()
		self.view:showCapturePhoto(sprite, photoTitle, not autoSave)

		if self.photoMode == self.ModeType.NORMAL_MODE or self.photoMode == self.ModeType.PHOTO_IDENTIFY or self.photoMode == self.ModeType.TASK_DIALOGUE then
			self.photoComponent:postPetInView()
			self.photoComponent:reportPhotoLog()
		end

		if autoSave then
			self.photoComponent:savePhoto(nil, captureTime, imgUrl)
			self:clearAutoHideTimer()

			self.autoHidePhotoTimer = self:startTimer(function()
				self.view:closeCapturePhoto()
			end, 3)
		else
			self.photoComponent:openAlbumToSave(captureTime, imgUrl)
		end

		local _h = PhotoCtrl._platformHooks

		if _h and _h.takePhoto then
			_h.takePhoto(self, traitId)
		end

		hudQuickPhoto:onQuickPhotoTaken(traitId)
		restorePhotoUI()

		if cb then
			cb()
		end
	end, function(sprite)
		self:resetInfo()

		traitId = self:tryCapturePhotoIdentify(sprite)

		return {
			photoNumber = traitId,
			subjectMask = self:_computeSubjectMask(),
			studioTmplId = Utils.isScenePhoto() and self.model:getStudioAssetsId() or nil
		}
	end)
end

function PhotoCtrl:applyPhotoCameraTarget()
	local info = self.photoCameraTargetInfo
	local center = info and info.center

	if not center then
		return false
	end

	if not self.photoCameraTargetObject then
		self.photoCameraTargetObject = CS.UnityEngine.GameObject("PhotoCameraTarget")
	end

	local centerPos = Vector3.New(center.x or 0, center.y or 0, center.z or 0)
	local size = info.size or {}
	local sizeX = math.max(tonumber(size.x) or 0, 0)
	local sizeY = math.max(tonumber(size.y) or 0, 0)
	local sizeZ = math.max(tonumber(size.z) or 0, 0)

	self.photoCameraTargetObject.transform.position = Vector3.New(centerPos.x, centerPos.y - sizeY * 0.5, centerPos.z)

	local horizontalRadius = math.max(math.sqrt(sizeX * sizeX + sizeZ * sizeZ) * 0.5, 1)
	local bottomRadius = math.max(15, horizontalRadius * 2 + 5)
	local topRadius = math.max(10, horizontalRadius + 5)
	local moveHeight = math.max(10, sizeY + 5)

	pg.game.camera.photoCameraMode:setMoveRange(self.photoCameraTargetObject.transform, bottomRadius, topRadius, moveHeight)

	local front = info.front or {}
	local groupFront = Vector3.New(front.x or 0, 0, front.z or 0)

	if Vector3.SqrMagnitude(groupFront) <= 0.01 then
		groupFront = Vector3.forward
	else
		groupFront:SetNormalize()
	end

	local distance = math.max(horizontalRadius * 2.4, sizeY * 1.4, 5)
	local cameraPos = centerPos + groupFront * distance

	cameraPos.y = cameraPos.y + 3

	local cameraRot = Quaternion.LookRotation(centerPos - cameraPos).eulerAngles

	pg.game.camera.photoCameraMode:AsyncTrans(cameraPos.x, cameraPos.y, cameraPos.z, cameraRot.x, cameraRot.y, cameraRot.z)

	return true
end

function PhotoCtrl:resetInfo()
	self.view.captureNewFeatures:SetActive(false)
	self.view.ecologyUWidget:SetActive(false)

	self.photoTraitInfo = nil
end

function PhotoCtrl:_computeSubjectMask()
	local mask = 0
	local types = PhotoEntityTypeIdentification.getIdentifiedTypesInViewport() or {}

	for _, t in ipairs(types) do
		local bitMask = SUBJECT_TYPE_TO_MASK_BIT[t]

		if bitMask then
			mask = bit.bor(mask, bitMask)
		end
	end

	return mask
end

function PhotoCtrl:refreshCapturePhotoInfo(info)
	local petName = PetData[info.templateId].name
	local iconUrl = self:getTraitIcon(info)

	if iconUrl then
		self.view.ecologyUWidget.transform:Find("Icon"):GetComponent("UImage").url = iconUrl
	end

	self.view.captureNewFeatures:SetActive(true)
	self.view.ecologyUWidget:SetActive(true)

	self.photoTraitInfo = {
		name = petName,
		detail = self.model:tryGetPhotoTitle(),
		iconUrl = iconUrl
	}

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PHOTO_SHOW) then
		pg.global.ui.photoShow:refreshPhotoShowInfo(self.photoTraitInfo)
	end
end

function PhotoCtrl:tryCapturePhotoIdentify(sprite)
	local quickPhoto = pg.global.ui.hudV2.quickPhoto

	if self.photoMode == self.ModeType.NORMAL_MODE and quickPhoto.curAITraitPhotoId then
		local photoCfg = PhotoIdentifyData[quickPhoto.curAITraitPhotoId]

		if photoCfg ~= nil and self:checkPhotoTraitIdentify(photoCfg, quickPhoto) and quickPhoto.curAITraitPointState == quickPhoto.TraitPointState.Playing then
			self.captureAITraitSuccess = true

			self:showAIPhotoTip(photoCfg.successText)

			self.needDelayClearCurPhotoAITrait = true

			self:clearPhotoTip()

			return quickPhoto.curAITraitPhotoId
		end
	elseif self.photoMode == self.ModeType.NORMAL_MODE and quickPhoto.quickPhotoId then
		for _, ent in ipairs(quickPhoto.quickPhotoEntities) do
			local pos = quickPhoto:getCheckPos(ent)

			if pos and pg.game.camera:checkInViewport(pos) then
				return quickPhoto.quickPhotoId
			end
		end
	end
end

function PhotoCtrl:checkPhotoTraitIdentify(photoCfg, quickPhoto)
	if not photoCfg.matchEntities then
		return true
	end

	local allEntitys = pg.getEntities()

	for id, entity in pairs(allEntitys) do
		if Utils.isPuppet(entity) and entity:getConfigData().petPrototypeId == photoCfg.matchEntities[1][1] then
			local entityCheckPos = quickPhoto:getCheckPos(entity)

			if entityCheckPos and pg.game.camera:checkInViewportFull(entityCheckPos) then
				return true
			end
		end
	end

	return false
end

function PhotoCtrl:trySetPhotoTip(data)
	if not data or not data.memberActorIds then
		return
	end

	local minDist = 100000
	local minDistEntity
	local cameraPos = pg.game.camera.photoCameraMode.cameraMode:GetPivotLocation()

	for _, id in ipairs(data.memberActorIds) do
		local entity = pg.getEntityByActorId(id)

		if entity then
			local entityCheckPos = pg.global.ui.hudV2.quickPhoto:getCheckPos(entity)
			local dist = Utils.distance(entityCheckPos, cameraPos)

			if dist < minDist and pg.game.camera:checkInViewportFull(entityCheckPos) then
				if entity == self.showPhotoTipEntity then
					return
				end

				minDist = dist
				minDistEntity = entity
			end
		end
	end

	if minDistEntity then
		self:tryClosePhotoTip()

		if minDistEntity.ensureTopLogoItem and minDistEntity:ensureTopLogoItem("photo") and minDistEntity.ensureToplogoComponent and minDistEntity:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.PHOTO, "photo_tip") then
			self.showPhotoTipEntity = minDistEntity

			minDistEntity.eventEmitter:emit(EventConst.TOPLOGO_PHOTO, UIConst.PHOTO_TYPE.TIP, true)
		end
	end
end

function PhotoCtrl:tryClosePhotoTip()
	if self.showPhotoTipEntity then
		self.showPhotoTipEntity.eventEmitter:emit(EventConst.TOPLOGO_PHOTO, UIConst.PHOTO_TYPE.TIP, false)

		self.showPhotoTipEntity = nil
	end
end

function PhotoCtrl:getTraitIcon(info)
	local traitCfg = PetTraitData[info.templateId]

	if traitCfg and traitCfg[info.traitId] then
		return traitCfg[info.traitId].traitsImg
	end
end

function PhotoCtrl:isInSelfie()
	return self:checkUIOpen() and self.photoComponent.curPhotoType == self.photoComponent.PhotoType.Selfie
end

function PhotoCtrl:checkIsNormalOrSelfie()
	if self.photoComponent then
		return self.photoComponent.curPhotoType == self.photoComponent.PhotoType.Normal or self.photoComponent.curPhotoType == self.photoComponent.PhotoType.Selfie
	end

	return false
end

function PhotoCtrl:isInNormal()
	return self.photoComponent and self.photoComponent.curPhotoType == self.photoComponent.PhotoType.Normal
end

function PhotoCtrl:isHomelandMode()
	return self.photoMode == self.ModeType.HOMELAND_MODE
end

function PhotoCtrl:tryTriggerAllPetsAction()
	if self.photoFuncMenuUIComponent then
		self.photoFuncMenuUIComponent:tryTriggerAllPetsAction()
	end
end

function PhotoCtrl:deselectAllDIY()
	if self.photoFuncMenuUIComponent then
		self.photoFuncMenuUIComponent:deselectAllDIY()
	end
end

function PhotoCtrl:checkIsFollow()
	if self.photoComponent then
		return self.photoComponent.curPhotoType == self.photoComponent.PhotoType.Follow
	end

	return false
end

function PhotoCtrl:onPhotoTypeUpdate()
	if self.photoFuncMenuUIComponent then
		self.photoFuncMenuUIComponent:onRefreshPhotoType()
	end

	if self.lockModeComponent and not self:checkIsNormalOrSelfie() then
		self.lockModeComponent:closeLockModel()
	end

	self:tryCloseOtherUI()
	pg.global.navMgr:SetConsoleBarState("NotInFollowMode", not self:checkIsFollow())
	pg.global.ui:refreshLockCursor()
end

function PhotoCtrl:tryCloseOtherUI()
	if self:checkIsFollow() and pg.global.ui:checkUIOpen(UIConst.UI_ID_FUNC_MENU) then
		pg.global.ui.funcMenu:close()
	end
end

function PhotoCtrl:savePhotoPreset(key)
	if string.isNilOrEmpty(key) then
		return
	end

	if not pg.space then
		return
	end

	local luaPreset = self:saveToPreset()
	local cSharpPreset = pg.game.camera.photoCameraMode.cameraMode:GetPhotoPreset(key, luaPreset.sceneId)
	local playerPos = luaPreset.playerPos
	local playerRot = luaPreset.playerRot
	local cameraPos = luaPreset.cameraPos
	local cameraRot = luaPreset.cameraRot

	cSharpPreset:SetPlayerInfo(Vector3(playerPos.x, playerPos.y, playerPos.z), Vector3(playerRot.x, playerRot.y, playerRot.z), luaPreset.playerPoseId, luaPreset.gazeType)
	cSharpPreset:SetCameraFunc(Vector3(cameraPos.x, cameraPos.y, cameraPos.z), Vector3(cameraRot.x, cameraRot.y, cameraRot.z), luaPreset.photoType, luaPreset.photoCameraMode)
	cSharpPreset:SetLensParam(luaPreset.fov, luaPreset.dof, luaPreset.dofRange, luaPreset.exposure, luaPreset.saturation, luaPreset.brightness, luaPreset.contrast, luaPreset.vignette, luaPreset.rotate)

	if luaPreset.lightId then
		cSharpPreset:SetLighting(luaPreset.lightId, luaPreset.lightValue)
	end

	if luaPreset.filterId then
		cSharpPreset:SetFilter(luaPreset.filterId, luaPreset.filterValue)
	end

	cSharpPreset:SetWeatherAndTime(luaPreset.weatherId, luaPreset.timeId)

	local diyInfoList = luaPreset.diyInfo

	if not IsNil(diyInfoList) then
		for k, info in ipairs(diyInfoList) do
			local pos = info.position

			cSharpPreset:AddDIYInfo(info.id, Vector2(pos.x, pos.y), info.rotation, info.scale)
		end
	end

	local petInfoList = luaPreset.petInfo

	if not IsNil(petInfoList) then
		for k, info in ipairs(petInfoList) do
			local pos = info.position
			local rot = info.rotation

			cSharpPreset:AddPetInfo(info.id, Vector3(pos.x, pos.y, pos.z), Vector3(rot.x, rot.y, rot.z), info.petPoseId or 0, info.gazeType or 1)
		end
	end

	cSharpPreset:SaveToConfig()
end

function PhotoCtrl:saveToPreset()
	local preset = {}

	if self.photoComponent and self.photoComponent.applyPreset then
		self.photoComponent:saveToPreset(preset)
	end

	if self.photoFuncMenuUIComponent then
		self.photoFuncMenuUIComponent:saveToPreset(preset)
	end

	return preset
end

function PhotoCtrl:applyPreset(preset)
	if self.photoComponent and self.photoComponent.applyPreset then
		self.photoComponent:applyPreset(preset)
	end

	if self.photoFuncMenuUIComponent then
		self.photoFuncMenuUIComponent:applyPreset(preset)
	end
end

function PhotoCtrl:onInputDeviceChanged(deviceType)
	if self.photoFuncMenuUIComponent then
		self.photoFuncMenuUIComponent:onInputDeviceChanged(deviceType)
	end

	if self.photoComponent and self.photoComponent.refreshMoveOperateUI then
		self.photoComponent:refreshMoveOperateUI()
	end
end

function PhotoCtrl:_checkValidScanCode(codeStr)
	return codeStr ~= nil and #codeStr == 16
end

function PhotoCtrl:_openScanCodePopup()
	if not pg.global.platform or not pg.global.platform:isConsole() then
		pg.global.ui:open(UIConst.UI_ID_PHOTO_SCAN_CODE)

		return
	end

	pg.global.ui.tips:showCommonInput("PHOTO_SCAN_IMPORT", function(codeStr)
		if self:_checkValidScanCode(codeStr) then
			local qrText = Utils.genPhotoPresetUniqueId(false, codeStr)

			facade:sendMsgToUI(MessageName.PHOTO_SCAN_CODE, {
				notDecode = true,
				qrText = qrText
			})

			return false
		else
			pg.global.ui.commonTipInput:showErrorMsg("PHOTO_ERROR_CODE")

			return true
		end
	end, nil, {
		noSensitiveWordsCheck = true,
		characterLimit = 0,
		hideInputTitle = true
	}, function()
		local view = pg.global.ui.commonTipInput.view

		ClientTextUtils.setText(view.txtName, "输入拍照码")
		ClientTextUtils.setText(view.placeHolderUText, "请输入拍照码")
	end)
end

function PhotoCtrl:onScanQRCode(info)
	self.model:getPresetByQRCode(info.qrText, function(preset)
		local pos = preset.playerPos

		if self.model:isArriveTrackPos(preset.sceneId, pos.x, pos.y, pos.z) then
			pg.me:pawnAutoPathFinding(Vector3(pos.x, pos.y, pos.z), function()
				if pg.global.ui:checkUIVisible(UIConst.UI_ID_PHOTO) then
					self:applyPreset(preset)
					pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_TEMPLATE_USED"))
				end
			end, AutoPathFindUtils.PathFindType.Voxel)
		else
			self:applyPreset(preset)
			pg.global.showBubbleMessageRaw(pg.getGameString("PHOTO_TEMPLATE_POS"))
		end

		pg.global.ui:close(UIConst.UI_ID_PHOTO_SCAN_CODE)
	end, info.notDecode)
end

function PhotoCtrl:refreshFishEyeEffect(photoType)
	if self.photoFuncMenuUIComponent then
		self.photoFuncMenuUIComponent:refreshFishEyeEffect(photoType)
	end
end

function PhotoCtrl:refreshPhotoType()
	if self.photoComponent and self.photoComponent.refreshPhotoType then
		self.photoComponent:refreshPhotoType()
	end
end

function PhotoCtrl:stopAllPetAction(stopBt)
	if self.photoFuncMenuUIComponent then
		self.photoFuncMenuUIComponent:stopAllPetAction(stopBt)
	end
end

function PhotoCtrl:resetAllPetAction()
	if self.photoFuncMenuUIComponent then
		self.photoFuncMenuUIComponent:resetAllPetAction()
	end
end

function PhotoCtrl:refreshLockState()
	if self.photoFuncMenuUIComponent then
		self.photoFuncMenuUIComponent:refreshLockState()
	end
end

function PhotoCtrl:clearTemplateCache()
	self.model:clearTemplateCache()
end

function PhotoCtrl:refreshGuideLabel()
	local state = pg.game.setting:getGuideLabelState()

	self.view.rootComponent:TryChangePage("guideLabel", 1 - state)
end

function PhotoCtrl:needBlockNormalBtn()
	if self.photoFuncMenuUIComponent then
		return self.photoFuncMenuUIComponent:needBlockGamepad()
	end

	return false
end

function PhotoCtrl:useVirtualCursor(bUse)
	bUse = false

	pg.game.input:setHudVirtualMouseCursor(bUse)

	if bUse then
		self:initNormalAdjustArgs()
	end
end

function PhotoCtrl:setGamepadMenuLongPressProgress(value)
	local progress = self.gamepadMenuKeyProgressPress

	if not progress then
		return
	end

	progress:ProgressToValue(value or 0, nil, 0)
end

return PhotoCtrl
