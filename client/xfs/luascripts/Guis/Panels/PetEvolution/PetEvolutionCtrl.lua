-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetEvolution\\PetEvolutionCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("PetEvolutionCtrl")
local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local EvolutionComponent = require("Guis.Panels.PetEvolution.Component.EvolutionComponent")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local lume = require("Core.Common.lume")
local PetEvolveData = require("Data.pet_evolve_data")
local AddressDataConst = require("Const.AddressDataConst")
local Time = require("Core.Common.Time")
local CallbackHandler = require("Core.Common.CallbackHandler")
local UI_SELECT_MODEL = AddressDataConst.UI_SELECT_MODEL
local UI_SELECT_MODEL_2 = AddressDataConst.UI_SELECT_MODEL_2
local EVOLUTION_CAMERA_RESTORE_MAX_RETRY = 15
local EVOLUTION_CAMERA_RESTORE_CONFIRM_RETRY = 2

local function isTemplateEvolvable(templateId)
	local cfg = templateId and PetEvolveData[templateId]

	return cfg and cfg[1] and cfg[1].targetPetId and true or false
end

local PetEvolutionCtrl = Class.LightClass("PetEvolutionCtrl", UICtrl)

PetEvolutionCtrl.messages = {
	[MessageName.PET_LEVEL_CHANGED] = {
		"onPetLevelChanged",
		true
	},
	[MessageName.PLAYER_PET_EVOLVE_FINISHED] = {
		"onPetEvolveFinished",
		true
	},
	[MessageName.PLAYER_PET_EVOLVE_PROCESS_FINISH] = {
		"onProcessEvolution",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function PetEvolutionCtrl:onCreate(info)
	self.selectPetList = info and info.selectPetList or {}

	self:setPetInfo(info)

	self.model.IS_PVP_FAIL_MODE = info.pvpFailMode

	UICtrl.onCreate(self, info)
end

function PetEvolutionCtrl:setPetInfo(info)
	self.petId = info.petId
	self.petInfo = pg.me:getPetInfo(self.petId) or {}
end

function PetEvolutionCtrl:addListener()
	self.evolutionComponent = EvolutionComponent.new(self, self.view.evolutionUComponent)

	self.evolutionComponent:onPetSelectChange(self.petId)

	function self.view.btnBackUButton.luaClick()
		self:closePanel()
	end

	ClientTextUtils.setText(self.view.tMPUSDFText, pg.getGameString("PET_EVOLUTION_PAGE"))

	function self.view.tabPetList.luaRenderItem(button, index, data)
		self:onRenderTabPetItem(button, data)
	end

	function self.view.tabPetList.luaCheckCanSelected(data)
		return self:onTabCheckCanSelect(data)
	end

	function self.view.tabPetList.luaSelectedChanged(uList, select)
		if not select then
			return
		end

		self.petId = uList.selectedItem.id
		self.petInfo = pg.me:getPetInfo(self.petId) or {}

		self:onTabPetSelectChanged(uList)
	end

	self.view.widget:TryChangePage("Tab", 2)
	self:refreshSelectPet()
	self:addNavFocusListener(CallbackHandler(self, "onNavFocusChange"))
end

function PetEvolutionCtrl:refreshSelectPet()
	local inCombat = pg.global.ui.petManagement.model:checkPetInCurGroup(self.petId)

	if self.selectPetList and #self.selectPetList > 0 then
		inCombat = table.contains(self.selectPetList, self.petId)
	end

	if inCombat then
		local dataList = pg.global.ui.petManagement.model:getCurrentGroupInfo()

		self.view.tabPetList:SetList(dataList)
		self.view.tabLeft:TryChangePage("TeamIn", 1)

		local selectIdx = self:getPetTabIndex(dataList)

		if selectIdx == -1 then
			self:onSelectSingle()
		else
			self.view.tabPetList:SelectItem(selectIdx)
		end
	else
		self.view.tabLeft:TryChangePage("TeamIn", 0)

		self.singlePet = self.model:getSinglePetInfo(self.petId)

		self:onRenderTabPetItem(self.view.petManage, self.singlePet, true)
		self:refreshEntModel()
	end

	self.view.tabLeft:SetActive(false)
end

function PetEvolutionCtrl:onSelectSingle()
	if not self:checkPetTabCanSwitch(self.singlePet.id) then
		return
	end

	if self.model.IS_PVP_FAIL_MODE then
		return
	end

	self.view.petManage.isSelected = true

	self.view.tabPetList:DeselectAll()
	self:refreshEntModel()
end

function PetEvolutionCtrl:getPetTabIndex(dataList)
	if self.singlePet and self.petId == self.singlePet.id then
		return -1
	end

	local index = 1

	for i, v in ipairs(dataList) do
		if v.id == self.petId then
			index = i

			break
		end
	end

	return index - 1
end

function PetEvolutionCtrl:refreshEntModel()
	self._refreshEntModelVersion = (self._refreshEntModelVersion or 0) + 1

	local scene = self.uiScene

	scene:recycleEvolution()
	scene:generalPetEvolutionBranchGraph(self.petId)
	self:adjustSceneEnts()

	if self.evolutionComponent then
		self.evolutionComponent:refreshSelectedPetEvolve()
		self.evolutionComponent:refreshConsoleSelectList()
	end
end

function PetEvolutionCtrl:onTabCheckCanSelect(data)
	local canEvolve = self:checkEvolveValid(data.id)

	if not canEvolve then
		local frame = Time.frameCount

		if self._lastCantEvolveBubbleFrame ~= frame then
			self._lastCantEvolveBubbleFrame = frame

			pg.global.showBubbleMessageRaw(pg.getGameString("CURRENT_PET_CANT_EVOLUTION"), 2)
		elseif not pg.game.input:isUsingGamepad() then
			pg.global.showBubbleMessageRaw(pg.getGameString("CURRENT_PET_CANT_EVOLUTION"), 2)
		end
	end

	return canEvolve
end

function PetEvolutionCtrl:checkPetTabCanSwitch(petId)
	local canEvolve = self:checkEvolveValid(petId)

	if not canEvolve then
		pg.global.showBubbleMessageRaw(pg.getGameString("CURRENT_PET_CANT_EVOLUTION"), 2)
	end

	return canEvolve
end

function PetEvolutionCtrl:checkEvolveValid(petId)
	local pet = pg.me:getPetInfo(petId)
	local canEvolve = pet and isTemplateEvolvable(pet.templateId)

	self.view.widget:TryChangePage("Type", not canEvolve and 1 or 0)

	return canEvolve
end

function PetEvolutionCtrl:onRenderTabPetItem(button, data, single)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local imgBgBattle = objectReference:GetRefValue("imgBgBattle")
	local txtNum = objectReference:GetRefValue("txtNum")
	local umbralUContainer = objectReference:GetRefValue("umbralUContainer")

	iconUImage.url = LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_ICON, data.label, data.gender)

	if data.isShiny then
		if data.shinyStyle == Const.PET_SHINY_STYLE.BLACK then
			button:TryChangePage("isFlash", 2)
		elseif data.shinyStyle == Const.PET_SHINY_STYLE.WHITE then
			button:TryChangePage("isFlash", 3)
		else
			button:TryChangePage("isFlash", 1)
		end
	else
		button:TryChangePage("isFlash", 0)
	end

	if data.isDark then
		umbralUContainer:SetActive(true)
		umbralUContainer:LoadDefaultUrlManually()
	else
		umbralUContainer:SetActive(false)
	end

	if not single then
		imgBgBattle:SetActive(true)
		ClientTextUtils.setText(txtNum, data.index)
	else
		imgBgBattle:SetActive(false)
	end

	local canEvolve = isTemplateEvolvable(data.templateId)

	button:TryChangePage("Dis", canEvolve and 0 or 1)
end

function PetEvolutionCtrl:onTabPetSelectChanged(uList)
	local sData = uList.selectedItem

	self.evolutionComponent:onPetSelectChange(sData.id)
	self:refreshEntModel()
end

function PetEvolutionCtrl:adjustSceneEnts()
	local scene = self.uiScene

	scene:switchEvolveGraph(true)

	for templateId, ent in pairs(scene and scene.entPoolTable or EMPTY_TABLE) do
		if templateId ~= self.petInfo.templateId and ent.eModel then
			local shaderView = ent.eModel and ent.eModel.modelShaderView

			if shaderView then
				shaderView:ResetMaterial()
			end
		end
	end

	local childCount = scene.evolutionPos.childCount
	local startIndex = lume.count(scene.posTable)

	for i = startIndex, childCount - 1 do
		scene.evolutionPos:GetChild(i).localScale = Vector3.one
	end

	local curEnt = scene.entPoolTable[self.petInfo.templateId]

	if curEnt == nil then
		return
	end

	if not self.finalCamera then
		self.finalCamera = scene.evolutionCameraTransform.gameObject
	end

	self.finalCamera = scene.evolutionCameraTransform.gameObject

	scene.evolutionCameraTransform:GetChild(0).gameObject:SetActiveEx(true)

	local rotation, _ = scene:getPetTargetRotationPosition(self.petInfo.templateId)

	curEnt.eModel:SetTransformRotationByEulerAngle(rotation[1], rotation[2], rotation[3])
end

function PetEvolutionCtrl:onRenderTabItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local name1 = objectReference:GetRefValue("name1")
	local name2 = objectReference:GetRefValue("name2")

	ClientTextUtils.setText(name1, data.name)
	ClientTextUtils.setText(name2, data.name)

	button.name = data.tab
end

function PetEvolutionCtrl:onDestroy()
	self._evolutionCameraRestoreToken = (self._evolutionCameraRestoreToken or 0) + 1

	UICtrl.onDestroy(self)
end

function PetEvolutionCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function PetEvolutionCtrl:onShow()
	return
end

function PetEvolutionCtrl:onHide()
	return
end

function PetEvolutionCtrl:onPetLevelChanged(info)
	self:refreshSelectPet()
	self.evolutionComponent:onPetSelectChange(self.petId)
	self.evolutionComponent:refreshConsoleSelectList()
end

function PetEvolutionCtrl:onPetEvolveFinished(info)
	if LoggerManager.checkLogger(LoggerConst.WARN) then
		logger:warn("PetEvolutionCtrl:onPetEvolveFinished, infoPetId = %s", info and info.id or "nil")
	end

	info = info or {}
	info.petId = info.id or info.petId or self.petId

	self:setPetInfo(info)

	if self.evolutionComponent then
		self.evolutionComponent:onPetSelectChange(self.petId)
	end

	local refreshEntModelVersion = self._refreshEntModelVersion or 0

	self:refreshSelectPet()

	if refreshEntModelVersion == (self._refreshEntModelVersion or 0) then
		self:refreshEntModel()
	end
end

function PetEvolutionCtrl:onProcessEvolution(processState)
	self._evolutionCameraRestoreToken = (self._evolutionCameraRestoreToken or 0) + 1

	local restoreToken = self._evolutionCameraRestoreToken

	if processState then
		if IsNil(self.uiScene) then
			return
		end

		self.uiScene:setHandBookCameraVisible(false)

		return
	end

	self:_restoreEvolutionCamera(restoreToken, 0)
end

function PetEvolutionCtrl:_scheduleEvolutionCameraRestore(restoreToken, retryCount)
	if retryCount >= EVOLUTION_CAMERA_RESTORE_MAX_RETRY then
		return
	end

	self:startFrameTimer(function()
		self:_restoreEvolutionCamera(restoreToken, retryCount + 1)
	end, 1)
end

function PetEvolutionCtrl:_restoreEvolutionCamera(restoreToken, retryCount)
	if restoreToken ~= self._evolutionCameraRestoreToken or not self:checkUIOpen() or self:checkUIClosing() then
		return
	end

	if not self:checkUIShow() then
		self:_scheduleEvolutionCameraRestore(restoreToken, retryCount)

		return
	end

	local scene = self.uiScene

	if IsNil(scene) or scene.expire then
		local uiSceneSystem = pg.game.uiScene
		local currentScene = uiSceneSystem and uiSceneSystem:getScene(self._uiSceneName)

		if currentScene and not currentScene.expire then
			self.uiScene = currentScene
			scene = currentScene
		end
	end

	if IsNil(scene) or scene.expire then
		self:_scheduleEvolutionCameraRestore(restoreToken, retryCount)

		return
	end

	if not scene:checkLoaded() or not scene:checkLoadSucceed() then
		self:_scheduleEvolutionCameraRestore(restoreToken, retryCount)

		return
	end

	local uiSceneSystem = pg.game.uiScene
	local uiSceneStack = uiSceneSystem and uiSceneSystem.uiSceneStack
	local topScene = uiSceneStack and uiSceneStack[#uiSceneStack]
	local isTopScene = topScene and topScene.name == self._uiSceneName and topScene.ownerKey == self.module
	local hasOtherTopScene = topScene and not isTopScene

	if hasOtherTopScene then
		return
	end

	if uiSceneSystem and (scene.enable ~= true or not isTopScene) then
		uiSceneSystem:switchToScene(self._uiSceneName, self._uiSceneIgnoreDisableMainCamera, self._uiSceneOpenAdditive, self._uiSceneIgnoreResetUICamera, self.module)
	end

	local cameraRestored = scene:setHandBookCameraVisible(true)

	if cameraRestored and retryCount >= EVOLUTION_CAMERA_RESTORE_CONFIRM_RETRY then
		return
	end

	self:_scheduleEvolutionCameraRestore(restoreToken, retryCount)
end

function PetEvolutionCtrl:onNavFocusChange()
	self:refreshConsoleBarState()
end

function PetEvolutionCtrl:onInputDeviceChanged(deviceType)
	if self.evolutionComponent then
		self.evolutionComponent:refreshConsoleSelectList()
	end
end

function PetEvolutionCtrl:refreshConsoleBarState()
	if pg.global.navMgr then
		local focusDetail = pg.global.navMgr.CurrentFocusedGroupName == "BranchInfo"

		pg.global.navMgr:SetConsoleBarState("Cultivate_EvolutionChoose", focusDetail)
	end
end

return PetEvolutionCtrl
