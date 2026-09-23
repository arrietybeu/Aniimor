-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Photo\\Component\\PhotoFuncMenuUIComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PhotoFuncMenuUIComponent = Class.LightClass("PhotoFuncMenuUIComponent", UIComponent)
local PlayableConst = require("Common.Const.PlayableConst")
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local HotkeyConst = require("Const.HotkeyConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PhotographyAssetRedDotUtils = require("Utils.PhotographyAssetRedDotUtils")
local RedDotConst = require("Const.RedDotConst")
local CameraModeComp = require("Guis.Panels.Photo.Component.PhotoFuncCameraModeUIComponent")
local LensComp = require("Guis.Panels.Photo.Component.PhotoFuncLensUIComponent")
local LightingComp = require("Guis.Panels.Photo.Component.PhotoFuncLightingUIComponent")
local FilterComp = require("Guis.Panels.Photo.Component.PhotoFuncFilterUIComponent")
local DIYComp = require("Guis.Panels.Photo.Component.PhotoFuncDIYUIComponent")
local PlayerPoseComp = require("Guis.Panels.Photo.Component.PhotoFuncPlayerPoseUIComponent")
local PetPoseComp = require("Guis.Panels.Photo.Component.PhotoFuncPetPoseUIComponent")
local TemplateComp = require("Guis.Panels.Photo.Component.PhotoFuncTemplateUIComponent")
local WeatherComp = require("Guis.Panels.Photo.Component.PhotoFuncWeatherUIComponent")
local GazeComp = require("Guis.Panels.Photo.Component.PhotoFuncGazeComponent")
local AnimExpand = "VX_Node_Camera_Menu_EXpand"
local AnimRecover = "VX_Node_Camera_Menu_Recover"
local AnimMenuIn = "VX_Node_Camera_Menu_In"

PhotoFuncMenuUIComponent.Funcs = {
	PetPose = 6,
	PlayerPose = 5,
	DIY = 4,
	Filter = 3,
	Lighting = 2,
	Lens = 1,
	CameraMode = 0,
	Gaze = 9,
	Weather = 8,
	Template = 7
}
PhotoFuncMenuUIComponent.CurOpenMenuTabs = {
	{
		label = "PHOTO_TEMPLATE",
		funcId = PhotoFuncMenuUIComponent.Funcs.Template
	},
	{
		tIndex = 1
	},
	{
		label = "PHOTO_CAMERA_FUNCTION",
		funcId = PhotoFuncMenuUIComponent.Funcs.CameraMode
	},
	{
		label = "PHOTO_LENS_PARAM",
		funcId = PhotoFuncMenuUIComponent.Funcs.Lens
	},
	{
		label = "PHOTO_LIGHTING",
		funcId = PhotoFuncMenuUIComponent.Funcs.Lighting
	},
	{
		label = "PHOTO_FILTER",
		funcId = PhotoFuncMenuUIComponent.Funcs.Filter
	},
	{
		label = "PHOTO_WEATHER",
		funcId = PhotoFuncMenuUIComponent.Funcs.Weather
	},
	{
		label = "PHOTO_DIY",
		funcId = PhotoFuncMenuUIComponent.Funcs.DIY
	},
	{
		tIndex = 1
	},
	{
		label = "PHOTO_PLAYER_POSE",
		funcId = PhotoFuncMenuUIComponent.Funcs.PlayerPose
	},
	{
		label = "PHOTO_PET_POSE",
		funcId = PhotoFuncMenuUIComponent.Funcs.PetPose
	},
	{
		label = "PHOTO_GAZE",
		funcId = PhotoFuncMenuUIComponent.Funcs.Gaze
	}
}

local FuncAssetType = {
	[PhotoFuncMenuUIComponent.Funcs.Lighting] = PhotographyAssetRedDotUtils.AssetType.Lighting,
	[PhotoFuncMenuUIComponent.Funcs.Filter] = PhotographyAssetRedDotUtils.AssetType.Filter,
	[PhotoFuncMenuUIComponent.Funcs.DIY] = PhotographyAssetRedDotUtils.AssetType.DIY,
	[PhotoFuncMenuUIComponent.Funcs.PlayerPose] = PhotographyAssetRedDotUtils.AssetType.PlayerPose
}

PhotoFuncMenuUIComponent.CameraParamTipType = {
	KeyValue = 1
}
PhotoFuncMenuUIComponent.DefaultLabel = "PHOTO_CAMERA_FUNCTION"
PhotoFuncMenuUIComponent.Func2Area = {
	[PhotoFuncMenuUIComponent.Funcs.Template] = {
		1,
		5,
		2,
		5
	},
	[PhotoFuncMenuUIComponent.Funcs.CameraMode] = {
		0,
		0
	},
	[PhotoFuncMenuUIComponent.Funcs.Lens] = {
		0,
		1
	},
	[PhotoFuncMenuUIComponent.Funcs.Lighting] = {
		2,
		0
	},
	[PhotoFuncMenuUIComponent.Funcs.Filter] = {
		1,
		1,
		2,
		1
	},
	[PhotoFuncMenuUIComponent.Funcs.Weather] = {
		0,
		2
	},
	[PhotoFuncMenuUIComponent.Funcs.DIY] = {
		1,
		2,
		2,
		2
	},
	[PhotoFuncMenuUIComponent.Funcs.PlayerPose] = {
		1,
		3,
		2,
		3
	},
	[PhotoFuncMenuUIComponent.Funcs.PetPose] = {
		1,
		4,
		2,
		4
	},
	[PhotoFuncMenuUIComponent.Funcs.Gaze] = {
		1,
		6,
		2,
		6
	}
}

function PhotoFuncMenuUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.titleUText = objectReference:GetRefValue("titleUText")
	self.funcTabUList = objectReference:GetRefValue("funcTabUList")
	self.cameraUWidget = objectReference:GetRefValue("cameraUWidget")
	self.lensUWidget = objectReference:GetRefValue("lensUWidget")
	self.lightingUComponent = objectReference:GetRefValue("lightingUComponent")
	self.filterUWidget = objectReference:GetRefValue("filterUWidget")
	self.dIYUWidget = objectReference:GetRefValue("dIYUWidget")
	self.playerPoseUWidget = objectReference:GetRefValue("playerPoseUWidget")
	self.petPoseUWidget = objectReference:GetRefValue("petPoseUWidget")
	self.templateUWidget = objectReference:GetRefValue("templateUWidget")
	self.weatherUWidget = objectReference:GetRefValue("weatherUWidget")
	self.gazeUComponent = objectReference:GetRefValue("gazeUComponent")
	self.cameraParameterUComponent = objectReference:GetRefValue("cameraParameterUComponent")
	self.btnExpandUButton = objectReference:GetRefValue("btnExpandUButton")
	self.dIYRootRectTransform = objectReference:GetRefValue("dIYRootRectTransform")
	self.panelAnimation = objectReference:GetRefValue("panelAnimation")
	self.petPoseRootRectTransform = objectReference:GetRefValue("petPoseRootRectTransform")
	self.menuAnimation = objectReference:GetRefValue("menuAnimation")
end

function PhotoFuncMenuUIComponent:initView()
	self.defaultHiddenOpacity = 0.4
	self.hiddenKeys = {}
	self.showTipDuration = 3
	self.lastShowParamTipTime = 0
	self.inputBlocked = false
	self.photoBlocked = false
	self.cameraBlocked = false
	self.virtualCursorOn = false

	if self.curSelectPoseTab == nil then
		self.curSelectPoseTab = self.Funcs.PlayerPose
	end

	if not pg.game.controller:isInControlMainPlayer() then
		self.curSelectPoseTab = self.Funcs.PetPose
	end

	self.curSelectTab = nil
	self.uiHiddenState = false
	self.funcComps = {
		[self.Funcs.CameraMode] = CameraModeComp.new(self, self.cameraUWidget),
		[self.Funcs.Lens] = LensComp.new(self, self.lensUWidget, {
			addZ = self.ctrl.addZ,
			minusZ = self.ctrl.minusZ
		}),
		[self.Funcs.Lighting] = LightingComp.new(self, self.lightingUComponent),
		[self.Funcs.Filter] = FilterComp.new(self, self.filterUWidget),
		[self.Funcs.DIY] = DIYComp.new(self, self.dIYUWidget),
		[self.Funcs.PlayerPose] = PlayerPoseComp.new(self, self.playerPoseUWidget),
		[self.Funcs.PetPose] = PetPoseComp.new(self, self.petPoseUWidget),
		[self.Funcs.Template] = TemplateComp.new(self, self.templateUWidget),
		[self.Funcs.Weather] = WeatherComp.new(self, self.weatherUWidget),
		[self.Funcs.Gaze] = GazeComp.new(self, self.gazeUComponent)
	}

	function self.funcTabUList.luaRenderItem(button, index, data)
		local assetType = FuncAssetType[data.funcId]
		local functionPath = PhotographyAssetRedDotUtils.getFunctionPath(assetType or "none")

		pg.global.setPreViewRedDot(functionPath, button, function()
			if not assetType then
				return RedDotConst.RedDotStyle.NONE
			end

			return PhotographyAssetRedDotUtils.getRedDotStyle(assetType)
		end)

		if data.funcId then
			button:TryChangePage("FuncIcon", data.funcId)

			local lockState = self:checkFuncLock(data)

			button:TryChangePage("Lock", lockState and 0 or 1)

			button.visualInteractable = lockState
			button.skipInListSwitch = not lockState
		else
			button.skipInListSwitch = true
			button.visualInteractable = false
		end
	end

	function self.funcTabUList.luaClick(button, data)
		if not data.funcId then
			return
		end

		if not self:checkFuncLock(data) then
			self:showLockTip(data)

			return
		end

		local lastTab = self.funcComps[self.curSelectTab]

		if data.funcId ~= self.curSelectTab then
			self:refreshFunc(data)
		else
			self:refreshFunc(nil)
		end

		if lastTab and lastTab.onDeselected then
			lastTab:onDeselected()
		end
	end

	local isNormalOrSelfie = self.ctrl:checkIsNormalOrSelfie()

	self.view.center2Transform.gameObject:SetActiveEx(isNormalOrSelfie)
	self.view.followFrameUWidget:SetActive(not isNormalOrSelfie)
	self.view.btnMenuUButton:SetActive(isNormalOrSelfie)
	self.ctrl:bindHotKeyPerform("Photo/OpenPhotoFuncMenu", function()
		if self.ctrl.inLuaHoldPress then
			return true
		end

		local diyComp = self.funcComps and self.funcComps[self.Funcs.DIY]

		if diyComp and diyComp.isAnyDIYFrameFocused and diyComp:isAnyDIYFrameFocused() then
			return true
		end

		self.view.btnMenuUButton:OnClickSimulate()
	end, self.view.btnMenuUButton.gameObject)

	function self.btnExpandUButton.luaClick()
		UIUtils.PlayAnimation(self.panelAnimation, AnimRecover, function()
			self:closePhotoMenu()
		end)

		local curTab = self.funcComps[self.curSelectTab]

		if curTab and curTab.onDeselected then
			curTab:onDeselected()
		end
	end

	UIUtils.PlayAnimation(self.menuAnimation, AnimMenuIn)
	self.ctrl:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest, function()
		if self.ctrl.inLuaHoldPress then
			return true
		end

		local diyComp = self.funcComps and self.funcComps[self.Funcs.DIY]

		if diyComp and diyComp.isAnyDIYFrameFocused and diyComp:isAnyDIYFrameFocused() then
			return true
		end

		self.btnExpandUButton:OnClickSimulate()
	end, self.btnExpandUButton.gameObject)

	function self.view.btnMenuUButton.luaClick()
		if not self.ctrl:checkIsNormalOrSelfie() then
			return
		end

		self:tryHandleCurOpenTab()
		self.view.btnMenuUButton:TryChangePage("button", 5)
		self.view.rootComponent:TryChangePage("CameraMenu", 1)

		if pg.game.input:isUsingGamepad() and not self.curSelectTab then
			self.curSelectTab = self.Funcs.CameraMode
		end

		self:refreshInputState()
		self:initFuncTabList(self.CurOpenMenuTabs, self.curSelectTab)
		self:refreshDIYCanFocusStick()
		self.ctrl:refreshCanMoveCameraState()
	end

	if not pg.game.input:isUsingGamepad() then
		self.view.btnMenuUButton.luaClick()
	end

	ClientTextUtils.setText(self.titleUText, pg.getGameString(self.DefaultLabel))
	self.ctrl:refreshCanMoveCameraState()
end

function PhotoFuncMenuUIComponent:onPhotoAssetViewed(assetType, subType)
	if subType ~= nil then
		pg.global.refreshRedDotState(PhotographyAssetRedDotUtils.getSubTabPath(assetType, subType))
	end

	pg.global.refreshRedDotState(PhotographyAssetRedDotUtils.getFunctionPath(assetType))
	self.funcTabUList:RefreshList()
end

function PhotoFuncMenuUIComponent:onPhotoAssetUnlockChanged()
	self.funcTabUList:RefreshList()

	local comp = self.funcComps[self.curSelectTab]

	if comp then
		if comp.refreshAssetUnlockState then
			comp:refreshAssetUnlockState()
		elseif comp.refreshPoseFunc and comp.curPoseType then
			comp:refreshPoseFunc(comp.curPoseType)
		elseif comp.listSecondUList then
			comp.listSecondUList:RefreshList()
		elseif comp.listUList then
			comp.listUList:RefreshList()
		end

		if comp.listFirstUList then
			comp.listFirstUList:RefreshList()
		end

		if comp.listTabUList then
			comp.listTabUList:RefreshList()
		end
	end

	for _, assetType in pairs(FuncAssetType) do
		pg.global.refreshRedDotState(PhotographyAssetRedDotUtils.getFunctionPath(assetType))
	end
end

function PhotoFuncMenuUIComponent:closePhotoMenu()
	self.view.rootComponent:TryChangePage("CameraMenu", 0)
	self:refreshInputState()
	self:refreshDIYCanFocusStick()
	self.ctrl:refreshCanMoveCameraState()
end

function PhotoFuncMenuUIComponent:isMenuRaised()
	local _, page = self.view.rootComponent:TryGetCurrentPage("CameraMenu")

	return page == 1
end

function PhotoFuncMenuUIComponent:refreshInputState()
	local shouldBlock = self:isMenuRaised() and pg.game.input:isUsingGamepad()

	if self.inputBlocked ~= shouldBlock then
		self.inputBlocked = shouldBlock

		pg.game.input:enablePhotoInput(not shouldBlock, HotkeyConst.INPUT_BLOCK_FLAG.Photo)
		pg.game.input:enableCameraInput(not shouldBlock, HotkeyConst.INPUT_BLOCK_FLAG.Photo)

		if shouldBlock then
			local photoProcessor = pg.game.input:getInputMapProcessor(HotkeyConst.INPUT_MAP_ACTION_KEY.Photo)

			if photoProcessor then
				photoProcessor:reset()
			end
		end
	end

	if self.virtualCursorOn ~= shouldBlock then
		self.virtualCursorOn = shouldBlock

		self.ctrl:useVirtualCursor(shouldBlock)
	end
end

function PhotoFuncMenuUIComponent:refreshDIYCanFocusStick()
	local diy = self.funcComps and self.funcComps[self.Funcs.DIY]

	if diy and diy.refreshCanFocusStickState then
		diy:refreshCanFocusStickState()
	end
end

function PhotoFuncMenuUIComponent:checkFuncLock(data)
	if data.funcId == PhotoFuncMenuUIComponent.Funcs.Template then
		return not self.ctrl:isHomelandMode()
	elseif data.funcId == PhotoFuncMenuUIComponent.Funcs.PlayerPose then
		return pg.game.controller:isInControlMainPlayer()
	elseif data.funcId == PhotoFuncMenuUIComponent.Funcs.PetPose then
		return self:isUnlockPetPoseComp()
	elseif data.funcId == PhotoFuncMenuUIComponent.Funcs.Weather then
		return Utils.isSceneWorld()
	end

	return true
end

function PhotoFuncMenuUIComponent:checkCanPetChangePos()
	if not self.ctrl:isInNormal() or not self:isUnlockPetPoseComp() then
		return false
	end

	return true
end

function PhotoFuncMenuUIComponent:isUnlockPetPoseComp()
	local curPetEntity = pg.me:getCurPetEntity()

	if not curPetEntity or curPetEntity and curPetEntity:isInCombat() or pg.me and pg.me:isControllingPet() then
		return false
	end

	return true
end

function PhotoFuncMenuUIComponent:refreshLockState()
	self.funcTabUList:RefreshList()
end

function PhotoFuncMenuUIComponent:showLockTip(data)
	if data.funcId == PhotoFuncMenuUIComponent.Funcs.PlayerPose then
		pg.global.showBubbleMessageRaw(pg.getGameString("FUNCTION_CANT_STATE"))

		return
	end

	if data.funcId == PhotoFuncMenuUIComponent.Funcs.PetPose then
		pg.global.showBubbleMessageRaw(pg.getGameString("FUNCTION_CANT_STATE"))

		return
	end

	if data.funcId == PhotoFuncMenuUIComponent.Funcs.Weather then
		pg.global.showBubbleMessageRaw(pg.getGameString("FUNCTION_CANT_STATE"))

		return
	end

	pg.global.showBubbleMessageRaw(pg.getGameString("FUNC_NOT_AVAILABLE"))
end

function PhotoFuncMenuUIComponent:setOpacity(key, needHidden)
	self.hiddenKeys[key] = needHidden

	local needHidden = false

	for _, value in pairs(self.hiddenKeys) do
		needHidden = needHidden or value
	end

	if self.ctrl.photoComponent.hide then
		self.view.cameraMenuPanelUComponent.renderOpacity = 0

		return
	end

	if self.uiHiddenState ~= needHidden then
		if needHidden == true then
			self.uiHiddenState = needHidden

			self.view.cameraMenuPanelUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		elseif not self.showFuncMenuTimer then
			self.showFuncMenuTimer = self:startTimer(function()
				self.showFuncMenuTimer = nil
				self.uiHiddenState = needHidden

				self.view.cameraMenuPanelUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
			end, 0.5)
		end
	elseif self.showFuncMenuTimer then
		self:killTimer(self.showFuncMenuTimer)

		self.showFuncMenuTimer = nil
	end
end

function PhotoFuncMenuUIComponent:update()
	self:updateComponents()
end

function PhotoFuncMenuUIComponent:updateComponents()
	if not self.funcComps then
		return
	end

	for k, comp in pairs(self.funcComps) do
		if comp.update then
			comp:update()
		end
	end
end

function PhotoFuncMenuUIComponent:onRefreshPhotoType()
	local isNormalOrSelfie = self.ctrl:checkIsNormalOrSelfie()
	local _, page = self.view.rootComponent:TryGetCurrentPage("CameraMenu")
	local selfActive = page == 1

	self.view.center2Transform.gameObject:SetActiveEx(isNormalOrSelfie)
	self.view.followFrameUWidget:SetActive(not isNormalOrSelfie)
	self.view.btnMenuUButton:SetActive(isNormalOrSelfie and not selfActive)

	if isNormalOrSelfie then
		if not selfActive and not pg.game.input:isUsingGamepad() then
			self.view.btnMenuUButton.luaClick()
		end
	else
		self:closePhotoMenu()
	end

	if not isNormalOrSelfie then
		self.view.btnMenuUButton:SetActive(false)
	end

	for k, comp in pairs(self.funcComps) do
		if comp.onRefreshPhotoType then
			comp:onRefreshPhotoType()
		end
	end
end

function PhotoFuncMenuUIComponent:initFuncTabList(data, selectTab)
	self.funcTabUList:SetList(data)
	self.funcTabUList:DeselectAll()

	for index, value in ipairs(data) do
		if value.funcId and value.funcId == selectTab then
			self.funcTabUList:SelectItem(index - 1)
			self:refreshFunc(value)

			break
		end
	end
end

function PhotoFuncMenuUIComponent:refreshFunc(data)
	if not data then
		self.curSelectTab = nil

		ClientTextUtils.setText(self.titleUText, pg.getGameString(self.DefaultLabel))
		self.view.cameraMenuPanelUComponent:TryChangePage("FunctionTab", 10)

		return
	end

	local newSelectTab = data.funcId

	ClientTextUtils.setText(self.titleUText, pg.getGameString(data.label))
	self.view.cameraMenuPanelUComponent:TryChangePage("FunctionTab", newSelectTab)

	self.curSelectTab = newSelectTab

	local comp = self.funcComps[newSelectTab]

	if not comp then
		return
	end

	if comp.refreshUI then
		comp:refreshUI()
	end
end

function PhotoFuncMenuUIComponent:isShowCameraMode()
	return self.ctrl:checkIsNormalOrSelfie()
end

function PhotoFuncMenuUIComponent:getPhotoCameraMode()
	return pg.game.camera.photoCameraMode
end

function PhotoFuncMenuUIComponent:scrollLens(isAdd)
	local lens = self.funcComps and self.funcComps[self.Funcs.Lens]

	if not lens or not lens.onScrollAdjust then
		return
	end

	lens:onScrollAdjust(isAdd, self.curSelectTab ~= self.Funcs.Lens)
end

function PhotoFuncMenuUIComponent:getSelfEntity()
	return pg.me
end

function PhotoFuncMenuUIComponent:showParamTip(type, name, value)
	if not self.showParamTipTimer then
		self.showParamTipTimer = self:startTimer(function()
			if self.lastShowParamTipTime and self.lastShowParamTipTime + self.showTipDuration < Time.realSecondCache then
				self.cameraParameterUComponent:TryChangePage("state", 1)

				if self.showParamTipTimer then
					self:killTimer(self.showParamTipTimer)

					self.showParamTipTimer = nil
				end
			end
		end, 1, true)
	end

	self.lastShowParamTipTime = Time.realSecondCache

	self.view.cameraMenuPanelUComponent:TryChangePage("ParameterTips", 1)
	self.cameraParameterUComponent:TryChangePage("state", 0)
	self.cameraParameterUComponent:TryChangePage("Type", type)

	if type == 1 then
		local objectReference = self.cameraParameterUComponent:GetComponent("ObjectReference")
		local valueUBaseText = objectReference:GetRefValue("valueUBaseText")
		local nameUBaseText = objectReference:GetRefValue("nameUBaseText")

		ClientTextUtils.setText(nameUBaseText, name)
		ClientTextUtils.setText(valueUBaseText, value)
	end
end

function PhotoFuncMenuUIComponent:tryHandleCurOpenTab()
	self.view.btnMenuUButton:TryChangePage("button", 0)
end

function PhotoFuncMenuUIComponent:tryDeSelectCurOpenTab()
	self.view.btnMenuUButton.isSelected = false
end

function PhotoFuncMenuUIComponent:applyPreset(preset)
	if not preset then
		return
	end

	for k, comp in pairs(self.funcComps) do
		if comp.applyPreset then
			comp:applyPreset(preset)
		end
	end
end

function PhotoFuncMenuUIComponent:saveToPreset(preset)
	for k, comp in pairs(self.funcComps) do
		if comp.saveToPreset then
			comp:saveToPreset(preset)
		end
	end

	return preset
end

function PhotoFuncMenuUIComponent:tryTriggerAllPetsAction()
	self.funcComps[self.Funcs.PetPose]:tryTriggerAllPetsAction()
end

function PhotoFuncMenuUIComponent:onBeginPhoto(root)
	self.funcComps[self.Funcs.DIY]:onBeginPhoto(root)
end

function PhotoFuncMenuUIComponent:onEndPhoto(root)
	self.funcComps[self.Funcs.DIY]:onEndPhoto(root)
end

function PhotoFuncMenuUIComponent:deselectAllDIY()
	self.funcComps[self.Funcs.DIY]:deselectAllDIY()
end

function PhotoFuncMenuUIComponent:setPetVisible(visible)
	self.funcComps[self.Funcs.PetPose]:showAllPets(visible)
end

function PhotoFuncMenuUIComponent:getPetEntity(entityId)
	return self.funcComps[self.Funcs.PetPose]:getPetEntity(entityId)
end

function PhotoFuncMenuUIComponent:getCreatedPets()
	return self.funcComps[self.Funcs.PetPose]:getCreatedPets()
end

function PhotoFuncMenuUIComponent:createPresetPets(preset)
	return self.funcComps[self.Funcs.PetPose]:createPresetPets(preset)
end

function PhotoFuncMenuUIComponent:refreshFishEyeEffect(photoType)
	self.funcComps[self.Funcs.CameraMode]:refreshFishEyeEffect(photoType)
end

function PhotoFuncMenuUIComponent:stopAllPetAction(stopBt)
	self.funcComps[self.Funcs.PetPose]:stopAllPetAction(stopBt)
end

function PhotoFuncMenuUIComponent:resetAllPetAction()
	self.funcComps[self.Funcs.PetPose]:resetAllPetAction()
end

function PhotoFuncMenuUIComponent:shouldKeepPetActionOnExit()
	return self.ctrl.keepPetActionOnExit
end

function PhotoFuncMenuUIComponent:pausePhotoSubjects()
	self.funcComps[self.Funcs.PlayerPose]:pausePhotoSubject()
	self.funcComps[self.Funcs.PetPose]:pausePhotoSubjects()
end

function PhotoFuncMenuUIComponent:resumePhotoSubjects()
	self.funcComps[self.Funcs.PlayerPose]:resumePhotoSubject()
	self.funcComps[self.Funcs.PetPose]:resumePhotoSubjects()
end

function PhotoFuncMenuUIComponent:checkTimePause()
	return self.ctrl:checkTimePause()
end

function PhotoFuncMenuUIComponent:getPlayerCurAnimName()
	return self.funcComps[self.Funcs.PlayerPose]:getCurAnimName()
end

function PhotoFuncMenuUIComponent:hideLight()
	self.funcComps[self.Funcs.Lighting]:hideLight()
end

function PhotoFuncMenuUIComponent:onDestroy()
	self:tryHandleCurOpenTab()
	pg.game.input:enablePhotoInput(true, HotkeyConst.INPUT_BLOCK_FLAG.Photo)
	pg.game.input:enableCameraInput(true, HotkeyConst.INPUT_BLOCK_FLAG.Photo)
	pg.global.navMgr:SetConsoleBarState("CanMoveCamera", false)
	UIComponent.onDestroy(self)
end

function PhotoFuncMenuUIComponent:onInputDeviceChanged(deviceType)
	pg.game.input:resetAllActions()

	local photoProcessor = pg.game.input:getInputMapProcessor(HotkeyConst.INPUT_MAP_ACTION_KEY.Photo)

	if photoProcessor then
		photoProcessor:reset()
	end

	local cameraProcessor = pg.game.input:getInputMapProcessor(HotkeyConst.INPUT_MAP_ACTION_KEY.Camera)

	if cameraProcessor then
		cameraProcessor:setViewAxis(0, 0)
	end

	self:refreshInputState()

	local petPoseComp = self.funcComps[self.Funcs.PetPose]

	if petPoseComp then
		petPoseComp:onInputDeviceChanged(deviceType)
	end
end

function PhotoFuncMenuUIComponent:needBlockGamepad()
	local _, page = self.view.rootComponent:TryGetCurrentPage("CameraMenu")

	if pg.game.input:isUsingGamepad() and page == 1 then
		return true
	end

	return false
end

function PhotoFuncMenuUIComponent:getHiddenLensTabs()
	return {
		[LensComp.Tabs.EXPOSURE] = true
	}
end

return PhotoFuncMenuUIComponent
