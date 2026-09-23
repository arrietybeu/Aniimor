-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotographyStudioEdit\\Component\\StudioFuncMenuUIComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local StudioFuncMenuUIComponent = Class.LightClass("StudioFuncMenuUIComponent", UIComponent)
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PhotographyStudioUtils = require("Utils.PhotographyStudioUtils")
local PhotographyAssetRedDotUtils = require("Utils.PhotographyAssetRedDotUtils")
local RedDotConst = require("Const.RedDotConst")
local HotkeyConst = require("Const.HotkeyConst")
local Utils = require("Common.Utils.Utils")
local AnimRecover = "VX_Node_Camera_Menu_Recover"
local LensComp = require("Guis.Panels.Photo.Component.PhotoFuncLensUIComponent")
local LightingComp = require("Guis.Panels.Photo.Component.PhotoFuncLightingUIComponent")
local FilterComp = require("Guis.Panels.Photo.Component.PhotoFuncFilterUIComponent")
local DIYComp = require("Guis.Panels.Photo.Component.PhotoFuncDIYUIComponent")
local PlayerPoseComp = require("Guis.Panels.PhotographyStudioEdit.Component.StudioFuncPlayerPoseUIComponent")
local PetPoseComp = require("Guis.Panels.PhotographyStudioEdit.Component.StudioFuncPetPoseUIComponent")
local GazeComp = require("Guis.Panels.Photo.Component.PhotoFuncGazeComponent")
local OrnamentComp = require("Guis.Panels.PhotographyStudioEdit.Component.StudioFuncOrnamentUIComponent")
local SceneComp = require("Guis.Panels.PhotographyStudioEdit.Component.StudioFuncSceneUIComponent")

StudioFuncMenuUIComponent.Funcs = {
	PetPose = 7,
	PlayerPose = 6,
	DIY = 5,
	Scene = 4,
	Ornament = 3,
	Filter = 2,
	Lighting = 1,
	Lens = 0,
	Gaze = 8
}
StudioFuncMenuUIComponent.CurOpenMenuTabs = {
	{
		label = "PHOTO_LENS_PARAM",
		funcId = StudioFuncMenuUIComponent.Funcs.Lens
	},
	{
		label = "PHOTO_LIGHTING",
		funcId = StudioFuncMenuUIComponent.Funcs.Lighting
	},
	{
		label = "PHOTO_FILTER",
		funcId = StudioFuncMenuUIComponent.Funcs.Filter
	},
	{
		tIndex = 1
	},
	{
		label = "PHOTO_STUDIO_ORNAMENT",
		funcId = StudioFuncMenuUIComponent.Funcs.Ornament
	},
	{
		label = "PHOTO_STUDIO_SCENE",
		funcId = StudioFuncMenuUIComponent.Funcs.Scene
	},
	{
		label = "PHOTO_DIY",
		funcId = StudioFuncMenuUIComponent.Funcs.DIY
	},
	{
		tIndex = 1
	},
	{
		label = "PHOTO_PLAYER_POSE",
		funcId = StudioFuncMenuUIComponent.Funcs.PlayerPose
	},
	{
		label = "PHOTO_PET_POSE",
		funcId = StudioFuncMenuUIComponent.Funcs.PetPose
	},
	{
		label = "PHOTO_GAZE",
		funcId = StudioFuncMenuUIComponent.Funcs.Gaze
	}
}

local FuncAssetType = {
	[StudioFuncMenuUIComponent.Funcs.Lighting] = PhotographyAssetRedDotUtils.AssetType.Lighting,
	[StudioFuncMenuUIComponent.Funcs.Filter] = PhotographyAssetRedDotUtils.AssetType.Filter,
	[StudioFuncMenuUIComponent.Funcs.Ornament] = PhotographyAssetRedDotUtils.AssetType.Ornament,
	[StudioFuncMenuUIComponent.Funcs.Scene] = PhotographyAssetRedDotUtils.AssetType.Background,
	[StudioFuncMenuUIComponent.Funcs.DIY] = PhotographyAssetRedDotUtils.AssetType.DIY,
	[StudioFuncMenuUIComponent.Funcs.PlayerPose] = PhotographyAssetRedDotUtils.AssetType.PlayerPose
}

StudioFuncMenuUIComponent.CameraParamTipType = {
	KeyValue = 1
}
StudioFuncMenuUIComponent.DefaultLabel = "PHOTO_LENS_PARAM"
StudioFuncMenuUIComponent.EMPTY_FUNCTION_PAGE = 10

function StudioFuncMenuUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.objectReference = objectReference
	self.titleUText = objectReference:GetRefValue("titleUText")
	self.funcTabUList = objectReference:GetRefValue("funcTabUList")
	self.lensUWidget = objectReference:GetRefValue("lensUWidget")
	self.lightingUComponent = objectReference:GetRefValue("lightingUComponent")
	self.filterUWidget = objectReference:GetRefValue("filterUWidget")
	self.ornamentUWidget = objectReference:GetRefValue("adornUWidget")
	self.sceneUWidget = objectReference:GetRefValue("sceneUWidget")
	self.dIYUWidget = objectReference:GetRefValue("dIYUWidget")
	self.playerPoseUWidget = objectReference:GetRefValue("playerPoseUWidget")
	self.petPoseUWidget = objectReference:GetRefValue("petPoseUWidget")
	self.gazeUComponent = objectReference:GetRefValue("gazeUComponent")
	self.cameraParameterUComponent = objectReference:GetRefValue("cameraParameterUComponent")
	self.btnExpandUButton = objectReference:GetRefValue("btnExpandUButton")
	self.panelAnimation = objectReference:GetRefValue("panelAnimation")
	self.dIYRootRectTransform = objectReference:GetRefValue("dIYRootRectTransform")
	self.petPoseRootRectTransform = objectReference:GetRefValue("petPoseRootRectTransform")
end

function StudioFuncMenuUIComponent:initView()
	self.showTipDuration = 3
	self.lastShowParamTipTime = 0
	self.curSelectTab = nil
	self.selectedFuncTabIndex = nil
	self.inputStateEnabled = false

	self:refreshStudioMode()
	self:initFuncComps()
	self:initFuncTabListeners()
	self.ctrl:bindHotKeyPerform("Photo/OpenPhotoFuncMenu", function()
		if self.ctrl.inLuaHoldPress or self.ctrl:isInGamepadModalGroup() or self.ctrl:isOrnamentEditing() then
			return true
		end

		local diyComp = self.funcComps[self.Funcs.DIY]

		if diyComp and diyComp.isAnyDIYFrameFocused and diyComp:isAnyDIYFrameFocused() then
			return true
		end

		self.view.btnMenuUButton:OnClickSimulate()
	end, self.view.btnMenuUButton.gameObject)

	function self.btnExpandUButton.luaClick()
		if pg.game.input:isUsingGamepad() and self.ctrl:isOrnamentEditing() then
			return
		end

		UIUtils.PlayAnimation(self.panelAnimation, AnimRecover, function()
			self:closeMenu()
		end)

		local curTab = self.funcComps[self.curSelectTab]

		if curTab and curTab.onDeselected then
			curTab:onDeselected()
		end
	end

	self.ctrl:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest, function()
		if self.ctrl:isOrnamentEditing() then
			self.ctrl:onClickRecycleOrnament()

			return true
		end

		if self.ctrl.inLuaHoldPress or self.ctrl:isInGamepadModalGroup() then
			return true
		end

		local diyComp = self.funcComps[self.Funcs.DIY]

		if diyComp and diyComp.isAnyDIYFrameFocused and diyComp:isAnyDIYFrameFocused() then
			return true
		end

		self.btnExpandUButton:OnClickSimulate()
	end, self.btnExpandUButton.gameObject)

	if pg.game.input:isUsingGamepad() then
		self:closeMenu()
	else
		self:openMenu()
	end
end

function StudioFuncMenuUIComponent:refreshStudioMode()
	local studioUid = self.ctrl and self.ctrl.studioUid
	local studioInfo = studioUid and pg.me:getStudioInfo(studioUid)
	local isMultiplayer = studioInfo and type(studioInfo.members) == "table" and #studioInfo.members > 0

	self.view.cameraMenuPanelUComponent:TryChangePage("Mode", isMultiplayer and 1 or 0)
end

function StudioFuncMenuUIComponent:initFuncComps()
	self.funcComps = {}

	local F = self.Funcs

	self:tryNewFuncComp(F.Lens, LensComp, self.lensUWidget)
	self:tryNewFuncComp(F.Lighting, LightingComp, self.lightingUComponent)
	self:tryNewFuncComp(F.Filter, FilterComp, self.filterUWidget)
	self:tryNewFuncComp(F.Ornament, OrnamentComp, self.ornamentUWidget)
	self:tryNewFuncComp(F.Scene, SceneComp, self.sceneUWidget)

	if self:isMaster() then
		self:tryNewFuncComp(F.DIY, DIYComp, self.dIYUWidget)
	end

	self:tryNewFuncComp(F.PlayerPose, PlayerPoseComp, self.playerPoseUWidget)
	self:tryNewFuncComp(F.PetPose, PetPoseComp, self.petPoseUWidget)
	self:tryNewFuncComp(F.Gaze, GazeComp, self.gazeUComponent, {
		hideNpcGaze = true
	})
end

function StudioFuncMenuUIComponent:tryNewFuncComp(funcId, compClass, container, extInfo)
	if IsNil(container) then
		return
	end

	self.funcComps[funcId] = compClass.new(self, container, extInfo)
end

function StudioFuncMenuUIComponent:initFuncTabListeners()
	if IsNil(self.funcTabUList) then
		return
	end

	function self.funcTabUList.luaRenderItem(button, index, data)
		local assetType = FuncAssetType[data.funcId]
		local functionPath = PhotographyAssetRedDotUtils.getFunctionPath(assetType or "studio_none")

		pg.global.setPreViewRedDot(functionPath, button, function()
			if not assetType then
				return RedDotConst.RedDotStyle.NONE
			end

			if assetType ~= PhotographyAssetRedDotUtils.AssetType.PlayerPose and not self:isMaster() then
				return RedDotConst.RedDotStyle.NONE
			end

			return PhotographyAssetRedDotUtils.getRedDotStyle(assetType)
		end)

		if data.funcId then
			button:TryChangePage("FuncIcon", data.funcId)

			local unlocked = self:checkFuncLock(data)

			button:TryChangePage("Lock", unlocked and 0 or 1)

			button.visualInteractable = unlocked
			button.skipInListSwitch = not unlocked
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

		if lastTab and lastTab.onDeselected then
			lastTab:onDeselected()
		end

		if data.funcId ~= self.curSelectTab then
			self.selectedFuncTabIndex = self.funcTabUList.selectedIndex

			self:refreshFunc(data)
		else
			self:refreshFunc(nil)
		end
	end
end

function StudioFuncMenuUIComponent:onPhotoAssetViewed(assetType, subType)
	if subType ~= nil then
		pg.global.refreshRedDotState(PhotographyAssetRedDotUtils.getSubTabPath(assetType, subType))
	end

	pg.global.refreshRedDotState(PhotographyAssetRedDotUtils.getFunctionPath(assetType))
	self.funcTabUList:RefreshList()
end

function StudioFuncMenuUIComponent:onPhotoAssetUnlockChanged()
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

function StudioFuncMenuUIComponent:openMenu()
	self:openMenuAt(self.curSelectTab or self.Funcs.Lens)
end

function StudioFuncMenuUIComponent:openMenuAt(funcId)
	if IsNil(self.funcTabUList) then
		return
	end

	self.view.rootComponent:TryChangePage("CameraMenu", 1)
	self:refreshInputState()
	self:initFuncTabList(self.CurOpenMenuTabs, funcId or self.Funcs.Lens)
	self:refreshDIYCanFocusStick()
	self.ctrl:refreshCanMoveCameraState()
end

function StudioFuncMenuUIComponent:closeMenu()
	self.view.rootComponent:TryChangePage("CameraMenu", 0)
	self:refreshInputState()
	self:refreshDIYCanFocusStick()
	self.ctrl:refreshCanMoveCameraState()
end

function StudioFuncMenuUIComponent:isMenuRaised()
	local _, page = self.view.rootComponent:TryGetCurrentPage("CameraMenu")

	return page == 1
end

function StudioFuncMenuUIComponent:setOrnamentEditingInputBlocked(blocked)
	if NotNil(self.funcTabUList) then
		self.funcTabUList.navGroupForceNonInteractable = blocked
	end
end

function StudioFuncMenuUIComponent:refreshInputState()
	local shouldBlock = self.inputStateEnabled and self:isMenuRaised() and pg.game.input:isUsingGamepad()

	if self.inputBlocked == shouldBlock then
		return
	end

	self.inputBlocked = shouldBlock

	if self.ctrl and self.ctrl.onStudioMenuInputStateChanged then
		self.ctrl:onStudioMenuInputStateChanged(shouldBlock)
	end

	pg.game.input:enablePhotoInput(not shouldBlock, HotkeyConst.INPUT_BLOCK_FLAG.Photo)
	pg.game.input:enableCameraInput(not shouldBlock, HotkeyConst.INPUT_BLOCK_FLAG.Photo)

	if shouldBlock then
		local photoProcessor = pg.game.input:getInputMapProcessor(HotkeyConst.INPUT_MAP_ACTION_KEY.Photo)

		if photoProcessor then
			photoProcessor:reset()
		end
	end
end

function StudioFuncMenuUIComponent:setInputStateEnabled(enabled)
	self.inputStateEnabled = enabled

	self:refreshInputState()
end

function StudioFuncMenuUIComponent:refreshDIYCanFocusStick()
	local diy = self.funcComps and self.funcComps[self.Funcs.DIY]

	if diy and diy.refreshCanFocusStickState then
		diy:refreshCanFocusStickState()
	else
		pg.global.navMgr:SetConsoleBarState("CanFocusStick", false)
	end
end

function StudioFuncMenuUIComponent:getDIYFocusStickActionPath()
	return HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadSelect
end

function StudioFuncMenuUIComponent:onInputDeviceChanged(deviceType)
	pg.game.input:resetAllActions()

	local photoProcessor = pg.game.input:getInputMapProcessor(HotkeyConst.INPUT_MAP_ACTION_KEY.Photo)

	if photoProcessor then
		photoProcessor:reset()
	end

	local cameraProcessor = pg.game.input:getInputMapProcessor(HotkeyConst.INPUT_MAP_ACTION_KEY.Camera)

	if cameraProcessor then
		cameraProcessor:setViewAxis(0, 0)
	end

	if not pg.game.input:isUsingGamepad() and not self:isMenuRaised() then
		self:openMenu()
	else
		self:refreshInputState()
	end

	if pg.game.input:isUsingGamepad() and self:isMenuRaised() then
		self:focusSelectedFuncTab()
	end

	local petPoseComp = self.funcComps[self.Funcs.PetPose]

	if petPoseComp and petPoseComp.onInputDeviceChanged then
		petPoseComp:onInputDeviceChanged(deviceType)
	end

	local ornamentComp = self.funcComps[self.Funcs.Ornament]

	if ornamentComp and ornamentComp.onInputDeviceChanged then
		ornamentComp:onInputDeviceChanged(deviceType)
	end
end

function StudioFuncMenuUIComponent:initFuncTabList(data, selectTab)
	self.funcTabUList:SetList(data)
	self.funcTabUList:DeselectAll()

	local fallbackIndex, fallbackData, selectedIndex, selectedData

	for index, value in ipairs(data) do
		local unlocked = value.funcId and self:checkFuncLock(value)

		if unlocked and not fallbackIndex then
			fallbackIndex = index - 1
			fallbackData = value
		end

		if unlocked and value.funcId == selectTab then
			selectedIndex = index - 1
			selectedData = value

			break
		end
	end

	selectedIndex = selectedIndex or fallbackIndex
	selectedData = selectedData or fallbackData
	self.selectedFuncTabIndex = selectedIndex

	if selectedIndex then
		self.funcTabUList:SelectItem(selectedIndex)
		self:refreshFunc(selectedData)
	else
		self:refreshFunc(nil)
	end

	self:focusSelectedFuncTab()
end

function StudioFuncMenuUIComponent:focusSelectedFuncTab()
	if not pg.game.input:isUsingGamepad() or not self:isMenuRaised() then
		return
	end

	local selectedIndex = self.funcTabUList.selectedIndex

	if selectedIndex == nil or selectedIndex < 0 then
		selectedIndex = self.selectedFuncTabIndex
	end

	if selectedIndex == nil or selectedIndex < 0 then
		return
	end

	self.selectedFuncTabIndex = selectedIndex

	local success, button = self.funcTabUList:TryGetChildAt(selectedIndex)

	if success then
		pg.global.navMgr:FocusItem(button)
	end
end

function StudioFuncMenuUIComponent:refreshFunc(data)
	if data and not self:checkFuncLock(data) then
		return
	end

	local newSelectTab = data and data.funcId or nil
	local isSwitchingTab = self.curSelectTab ~= nil and newSelectTab ~= self.curSelectTab

	if isSwitchingTab and self.ctrl then
		if self.ctrl.resetStudioEntityGamepadInput then
			self.ctrl:resetStudioEntityGamepadInput(true)
		end

		if pg.game.input:isUsingGamepad() and self.ctrl.clearSelectedStudioCharacterOrPet then
			self.ctrl:clearSelectedStudioCharacterOrPet()
		end
	end

	if not data then
		self.curSelectTab = nil
		self.selectedFuncTabIndex = nil

		ClientTextUtils.setText(self.titleUText, pg.getGameString(self.DefaultLabel))
		self.view.cameraMenuPanelUComponent:TryChangePage("FunctionTab", self.EMPTY_FUNCTION_PAGE)

		return
	end

	ClientTextUtils.setText(self.titleUText, pg.getGameString(data.label))
	self.view.cameraMenuPanelUComponent:TryChangePage("FunctionTab", newSelectTab)

	self.curSelectTab = newSelectTab

	local comp = self.funcComps[newSelectTab]

	if comp and comp.refreshUI then
		comp:refreshUI()
	end
end

function StudioFuncMenuUIComponent:checkFuncLock(data)
	if data.funcId == self.Funcs.PlayerPose or data.funcId == self.Funcs.PetPose or data.funcId == self.Funcs.Gaze then
		return true
	end

	return self:isMaster()
end

function StudioFuncMenuUIComponent:isMaster()
	return self.ctrl and self.ctrl.isMaster == true
end

function StudioFuncMenuUIComponent:showLockTip(data)
	pg.global.showBubbleMessageRaw(pg.getGameString("FUNCTION_CANT_STATE"))
end

function StudioFuncMenuUIComponent:refreshLockState()
	if NotNil(self.funcTabUList) then
		self.funcTabUList:RefreshList()
	end
end

function StudioFuncMenuUIComponent:checkCanPetChangePos()
	return true
end

function StudioFuncMenuUIComponent:shouldKeepPetActionOnExit()
	return false
end

function StudioFuncMenuUIComponent:checkTimePause()
	return false
end

function StudioFuncMenuUIComponent:getPhotoCameraMode()
	local scene = self.ctrl and self.ctrl.getAvatarScene and self.ctrl:getAvatarScene()

	return scene and scene.studioFreeCameraMode
end

function StudioFuncMenuUIComponent:getHiddenLensTabs()
	return {
		[LensComp.Tabs.DOF] = true,
		[LensComp.Tabs.DOF_R] = true,
		[LensComp.Tabs.EXPOSURE] = true
	}
end

function StudioFuncMenuUIComponent:scrollLens(isAdd)
	if not self:isMaster() then
		return
	end

	local lens = self.funcComps and self.funcComps[self.Funcs.Lens]

	if not lens or not lens.onScrollAdjust then
		return
	end

	lens:onScrollAdjust(isAdd, self.curSelectTab ~= self.Funcs.Lens)
end

function StudioFuncMenuUIComponent:saveLocalViewToPreset(preset)
	local lens = self.funcComps and self.funcComps[self.Funcs.Lens]

	if lens and lens.saveToPreset then
		lens:saveToPreset(preset)
	end

	return preset
end

function StudioFuncMenuUIComponent:applyLocalViewPreset(preset)
	local lens = self.funcComps and self.funcComps[self.Funcs.Lens]

	if lens and lens.applyPreset then
		lens:applyPreset(preset)
	end
end

function StudioFuncMenuUIComponent:getSelfEntity()
	local scene = self.ctrl and self.ctrl.getAvatarScene and self.ctrl:getAvatarScene()

	return scene and scene:getCurEntity()
end

function StudioFuncMenuUIComponent:getSelfEModel()
	local entity = self:getSelfEntity()

	return entity and entity.eModel
end

function StudioFuncMenuUIComponent:isShowCameraMode()
	return true
end

function StudioFuncMenuUIComponent:showParamTip(type, name, value)
	if IsNil(self.cameraParameterUComponent) then
		return
	end

	if not self.showParamTipTimer then
		self.showParamTipTimer = self:startTimer(function()
			if self.lastShowParamTipTime and self.lastShowParamTipTime + self.showTipDuration < Time.secondCache then
				self.cameraParameterUComponent:TryChangePage("state", 1)

				if self.showParamTipTimer then
					self:killTimer(self.showParamTipTimer)

					self.showParamTipTimer = nil
				end
			end
		end, 1, true)
	end

	self.lastShowParamTipTime = Time.secondCache

	self.view.cameraMenuPanelUComponent:TryChangePage("ParameterTips", 1)
	self.cameraParameterUComponent:TryChangePage("state", 0)
	self.cameraParameterUComponent:TryChangePage("Type", type)

	if type == 1 then
		local oc = self.cameraParameterUComponent:GetComponent("ObjectReference")
		local valueUBaseText = oc:GetRefValue("valueUBaseText")
		local nameUBaseText = oc:GetRefValue("nameUBaseText")

		ClientTextUtils.setText(nameUBaseText, name)
		ClientTextUtils.setText(valueUBaseText, value)
	end
end

function StudioFuncMenuUIComponent:tryTriggerAllPetsAction()
	local petPose = self.funcComps[self.Funcs.PetPose]

	if petPose and petPose.tryTriggerAllPetsAction then
		petPose:tryTriggerAllPetsAction()
	end
end

function StudioFuncMenuUIComponent:getPetEntity(entityId)
	local petPose = self.funcComps[self.Funcs.PetPose]

	return petPose and petPose:getPetEntity(entityId)
end

function StudioFuncMenuUIComponent:getCreatedPets()
	local petPose = self.funcComps[self.Funcs.PetPose]

	if not petPose then
		return nil
	end

	local pets = petPose:getCreatedPets()

	if not self:isMaster() then
		return pets
	end

	local remotePets = petPose:buildStudioPetMiniList()

	for _, data in ipairs(remotePets) do
		if data.entity and data.visible ~= false then
			pets[#pets + 1] = data.entity
		end
	end

	return pets
end

function StudioFuncMenuUIComponent:getStudioPetGazeData(entity)
	local gaze = self.funcComps[self.Funcs.Gaze]

	if not gaze or not entity or not gaze.petGazeType or gaze.petGazeType[entity.id] == nil then
		return nil
	end

	return gaze and gaze:getStudioPetGazeData(entity)
end

function StudioFuncMenuUIComponent:getStudioPetPoseId(entity)
	if not entity then
		return nil
	end

	return entity.studioPetPoseId
end

function StudioFuncMenuUIComponent:applyStudioPetGaze(entity, gazeType, gazePos)
	local gaze = self.funcComps[self.Funcs.Gaze]

	if gaze then
		gaze:applyStudioPetGaze(entity, gazeType, gazePos)
	end
end

function StudioFuncMenuUIComponent:createPresetPets(preset)
	local petPose = self.funcComps[self.Funcs.PetPose]

	return petPose and petPose:createPresetPets(preset)
end

function StudioFuncMenuUIComponent:savePets()
	local petPose = self.funcComps[self.Funcs.PetPose]

	return petPose and petPose:savePets() or {}
end

function StudioFuncMenuUIComponent:removeHiddenPetsFromPlayers(players)
	local petPose = self.funcComps and self.funcComps[self.Funcs.PetPose]

	if petPose and petPose.removeHiddenPetsFromPlayers then
		petPose:removeHiddenPetsFromPlayers(players)
	end
end

function StudioFuncMenuUIComponent:applyPets(pets)
	local petPose = self.funcComps[self.Funcs.PetPose]

	if petPose then
		petPose:applyPets(pets)
	end
end

function StudioFuncMenuUIComponent:getStudioPets()
	return self:getCreatedPets() or {}
end

function StudioFuncMenuUIComponent:isStudioPetEntityVisible(entity)
	local petPose = self.funcComps[self.Funcs.PetPose]

	if petPose and petPose.isStudioPetEntityVisible then
		return petPose:isStudioPetEntityVisible(entity)
	end

	return nil
end

function StudioFuncMenuUIComponent:onStudioEntitySelected(entity)
	local ornament = self.funcComps[self.Funcs.Ornament]

	if ornament and ornament.onStudioEntitySelected then
		ornament:onStudioEntitySelected(entity)
	end

	local petPose = self.funcComps[self.Funcs.PetPose]

	if petPose and petPose.onStudioEntitySelected then
		petPose:onStudioEntitySelected(entity)
	end

	local playerPose = self.funcComps[self.Funcs.PlayerPose]

	if playerPose and playerPose.onStudioEntitySelected then
		playerPose:onStudioEntitySelected(entity)
	end
end

function StudioFuncMenuUIComponent:getOrnamentComponent()
	return self.funcComps and self.funcComps[self.Funcs.Ornament] or nil
end

function StudioFuncMenuUIComponent:isOrnamentEditing()
	return self.ctrl and self.ctrl.isOrnamentEditing and self.ctrl:isOrnamentEditing() or false
end

function StudioFuncMenuUIComponent:enterOrnamentEdit(entity)
	if self.ctrl and self.ctrl.enterOrnamentEdit then
		self.ctrl:enterOrnamentEdit(entity)
	end
end

function StudioFuncMenuUIComponent:exitOrnamentEdit(restoreFocus)
	if self.ctrl and self.ctrl.exitOrnamentEdit then
		self.ctrl:exitOrnamentEdit(restoreFocus)
	end
end

function StudioFuncMenuUIComponent:getSelectedStudioOrnament()
	return self.ctrl and self.ctrl.getSelectedStudioOrnament and self.ctrl:getSelectedStudioOrnament() or nil
end

function StudioFuncMenuUIComponent:refreshOrnamentConsoleBarState()
	if self.ctrl and self.ctrl.refreshOrnamentConsoleBarState then
		self.ctrl:refreshOrnamentConsoleBarState()
	end
end

function StudioFuncMenuUIComponent:onOrnamentNavFocusChange()
	local ornament = self:getOrnamentComponent()

	if ornament and ornament.onNavFocusChange then
		ornament:onNavFocusChange()
	end
end

function StudioFuncMenuUIComponent:refreshStudioPlayerList(selectSelfEntity)
	local playerPose = self.funcComps[self.Funcs.PlayerPose]

	if playerPose and playerPose.refreshStudioPlayerList then
		playerPose:refreshStudioPlayerList(selectSelfEntity)
	end
end

function StudioFuncMenuUIComponent:refreshStudioActiveEditState()
	local playerPose = self.funcComps[self.Funcs.PlayerPose]

	if playerPose and playerPose.refreshStudioPlayerEditState then
		playerPose:refreshStudioPlayerEditState()
	end

	local petPose = self.funcComps[self.Funcs.PetPose]

	if petPose and petPose.refreshStudioPetEditState then
		petPose:refreshStudioPetEditState()
	end
end

function StudioFuncMenuUIComponent:isStudioPlayerEntityVisible(entity)
	local playerPose = self.funcComps[self.Funcs.PlayerPose]

	if playerPose and playerPose.isStudioPlayerEntityVisible then
		return playerPose:isStudioPlayerEntityVisible(entity)
	end

	return nil
end

function StudioFuncMenuUIComponent:enforceStudioPetQuota()
	local petPose = self.funcComps[self.Funcs.PetPose]

	if petPose and petPose.enforceQuota then
		petPose:enforceQuota()
	end
end

function StudioFuncMenuUIComponent:getAvatarScene()
	return self.ctrl and self.ctrl.getAvatarScene and self.ctrl:getAvatarScene()
end

function StudioFuncMenuUIComponent:getStudioUid()
	return self.ctrl and self.ctrl.studioUid
end

function StudioFuncMenuUIComponent:getStudioMasterUid()
	local studioUid = self:getStudioUid()

	return studioUid and pg.me:getStudioMasterUid(studioUid) or pg.me.uid
end

function StudioFuncMenuUIComponent:refreshPlaceHotspots()
	if self.ctrl and self.ctrl.refreshPlaceHotspots then
		self.ctrl:refreshPlaceHotspots()
	end
end

function StudioFuncMenuUIComponent:selectStudioEntity(entity)
	if self.ctrl and self.ctrl.selectStudioEntity then
		self.ctrl:selectStudioEntity(entity)
	end
end

function StudioFuncMenuUIComponent:placeStudioPetAtScreenCenter(petId)
	if self.ctrl and self.ctrl.placeStudioPetAtScreenCenter then
		self.ctrl:placeStudioPetAtScreenCenter(petId)
	end
end

function StudioFuncMenuUIComponent:placeStudioEntityAtScreenCenter(entityId)
	if self.ctrl and self.ctrl.placeStudioEntityAtScreenCenter then
		self.ctrl:placeStudioEntityAtScreenCenter(entityId)
	end
end

function StudioFuncMenuUIComponent:getPlayerCurAnimName()
	local playerPose = self.funcComps[self.Funcs.PlayerPose]

	return playerPose and playerPose:getCurAnimName()
end

function StudioFuncMenuUIComponent:saveToPreset(preset)
	for _, comp in pairs(self.funcComps) do
		if comp.saveToPreset then
			comp:saveToPreset(preset)
		end
	end

	if preset.customLightSlot then
		local lighting = self.funcComps[self.Funcs.Lighting]
		local scheme = lighting and lighting:getSelectedCustomLightScheme()

		preset.customLightScheme = scheme and Utils.deepCopyTable(scheme) or nil
	else
		preset.customLightScheme = nil
	end

	return preset
end

function StudioFuncMenuUIComponent:savePlayerToPreset(preset)
	local playerPose = self.funcComps[self.Funcs.PlayerPose]

	if playerPose and playerPose.saveToPreset then
		playerPose:saveToPreset(preset)
	end

	local gaze = self.funcComps[self.Funcs.Gaze]

	if gaze and gaze.savePlayerToPreset then
		gaze:savePlayerToPreset(preset)
	end

	return preset
end

function StudioFuncMenuUIComponent:applyPlayerPreset(preset)
	local playerPose = self.funcComps[self.Funcs.PlayerPose]

	if playerPose and playerPose.applyPreset then
		playerPose:applyPreset(preset)
	end

	local gaze = self.funcComps[self.Funcs.Gaze]

	if gaze and gaze.applyPreset then
		gaze:applyPreset(preset)
	end
end

function StudioFuncMenuUIComponent:recordHistoryStep(operationType)
	if self.ctrl and self.ctrl.recordStudioHistoryStep then
		self.ctrl:recordStudioHistoryStep(operationType)
	end
end

function StudioFuncMenuUIComponent:scheduleHistoryStep(operationType, delay)
	if self.ctrl and self.ctrl.scheduleStudioHistoryStep then
		self.ctrl:scheduleStudioHistoryStep(operationType, delay)
	end
end

function StudioFuncMenuUIComponent:isApplyingHistory()
	return self.ctrl and self.ctrl.isApplyingStudioHistory and self.ctrl:isApplyingStudioHistory() or false
end

function StudioFuncMenuUIComponent:applyPreset(preset, preserveOrnamentPreview)
	if not preset then
		return
	end

	for funcId, comp in pairs(self.funcComps) do
		if comp.applyPreset and (funcId ~= self.Funcs.Ornament or not preserveOrnamentPreview) then
			comp:applyPreset(preset)
		end
	end

	if not self:isMaster() then
		self:refreshReadonlyDIY(preset.diyInfo)
	end
end

function StudioFuncMenuUIComponent:refreshReadonlyDIY(diyInfo)
	if IsNil(self.dIYRootRectTransform) then
		return
	end

	self.readonlyDIYObjs = PhotographyStudioUtils.renderReadonlyDIY(self.view, self.dIYRootRectTransform, diyInfo, self.readonlyDIYObjs)
end

function StudioFuncMenuUIComponent:clearReadonlyDIY()
	if self.readonlyDIYObjs then
		PhotographyStudioUtils.clearReadonlyDIY(self.view, self.readonlyDIYObjs)

		self.readonlyDIYObjs = nil
	end
end

function StudioFuncMenuUIComponent:deselectAllDIY()
	local diyComp = self.funcComps and self.funcComps[self.Funcs.DIY]

	if diyComp then
		diyComp:deselectAllDIY()
	end
end

function StudioFuncMenuUIComponent:onBeginPhoto(root)
	local ornamentComp = self.funcComps and self.funcComps[self.Funcs.Ornament]

	if ornamentComp then
		ornamentComp:onBeginPhoto()
	end

	local diyComp = self.funcComps and self.funcComps[self.Funcs.DIY]

	if diyComp then
		diyComp:onBeginPhoto(root)

		return
	end

	if self.readonlyDIYObjs then
		for _, obj in pairs(self.readonlyDIYObjs) do
			if NotNil(obj) then
				obj.transform:SetParent(root, false)
			end
		end
	end
end

function StudioFuncMenuUIComponent:onEndPhoto(root)
	local ornamentComp = self.funcComps and self.funcComps[self.Funcs.Ornament]

	if ornamentComp then
		ornamentComp:onEndPhoto()
	end

	local diyComp = self.funcComps and self.funcComps[self.Funcs.DIY]

	if diyComp then
		diyComp:onEndPhoto(root)

		return
	end

	if self.readonlyDIYObjs and NotNil(root) then
		for _, obj in pairs(self.readonlyDIYObjs) do
			if NotNil(obj) then
				obj.transform:SetParent(root, false)
			end
		end

		root.gameObject:SetActiveEx(false)
		root.gameObject:SetActiveEx(true)
	end
end

function StudioFuncMenuUIComponent:update()
	if not self.funcComps then
		return
	end

	for _, comp in pairs(self.funcComps) do
		if comp.update then
			comp:update()
		end
	end
end

function StudioFuncMenuUIComponent:onDestroy()
	self:setInputStateEnabled(false)

	if self.showParamTipTimer then
		self:killTimer(self.showParamTipTimer)

		self.showParamTipTimer = nil
	end

	self:clearReadonlyDIY()
	UIComponent.onDestroy(self)
end

return StudioFuncMenuUIComponent
