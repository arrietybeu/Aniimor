-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandPlacement\\HomelandPlacementCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("HomelandPlacementCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local Utils = require("Common.Utils.Utils")
local MessageName = require("Const.MessageName")
local ClientConst = require("Const.ClientConst")
local PetData = require("Data.pet_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local HomelandViewCtrlComponent = require("Guis.Panels.HomelandEditor.Component.HomelandViewCtrlComponent")
local HomelandEditorTopListComponent = require("Guis.Panels.HomelandEditor.Component.HomelandEditorTopListComponent")
local HomelandOperateData = require("Data.homeland_operate_data")
local HomeObjectData = require("Data.home_object_data")
local InteractData = require("Data.interact_data")
local HomelandConfigData = require("Data.homeland_config_data")
local HomeBuildData = require("Data.home_build_data")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local ClientHomelandUtils = require("Utils.ClientHomelandUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local ClientUtils = require("Utils.ClientUtils")
local NoticeDef = require("Common.NoticeDef")
local ItemUtils = require("Common.Utils.ItemUtils")
local GlobalData = require("Core.Client.GlobalData")
local CallbackHandler = require("Core.Common.CallbackHandler")
local AreaData = require("Data.homeland_area_data")
local AudioConst = require("Const.AudioConst")
local HomelandPlacementCtrl = Class.LightClass("HomelandPlacementCtrl", UICtrl)
local HomeSeasonUtils = require("Utils.HomeSeasonUtils")
local HomeEditorUtils = CS.FunPlus.WorldX.Home.HomeEditorUtils
local HomelandPlacemenSliderMode = {
	Rotation = 1,
	Scale = 2
}

HomelandPlacementCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	},
	[MessageName.HOMELAND_EDITOR_SETTING_REFRESH] = {
		"refreshSliderInfo",
		true
	},
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"onItemCountChanged",
		true
	},
	[MessageName.HOMELAND_ITEM_MAP_CHANGED] = {
		"onItemCountChanged",
		true
	}
}

function HomelandPlacementCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.isBlueprintPlace = info.isBlueprintPlace == true
	self.isBlueprintBuilding = false
	self.tickTimer = self:startTimer(function()
		self:onTick()
	end, 0.1, true)
	self.editor = info.editor or pg.game.home.editor
	self.carGroup = info.carGroup
	self.areaId = info.areaId
	self.displayMode = self.editor.displayHideMode
	self.cameraHeight = self.editor.cameraHeightLimit
	self.isFromMultiSelect = info.isFromMultiSelect

	if pg.global.ui.uiMgr:CheckIsMobileInteract() then
		self.view.operateMobileUContainer:LoadDefaultUrlManually(function(obj)
			local objectReference = obj:GetComponent("ObjectReference")

			self.moveJoyStick = objectReference:GetRefValue("joyStickUJoyStick")

			local cameraCtrlUWidget = objectReference:GetRefValue("cameraCtrlUWidget")

			LuaUIUtils.setUIVisible(cameraCtrlUWidget, false)
		end)
	end

	self.viewCtrlComponent = HomelandViewCtrlComponent(self, self.view.simpleViewCtrl, {
		isPlacement = true,
		joyStick = self.moveJoyStick
	})

	local viewCtrlComponent = self.viewCtrlComponent
	local editor = self.editor

	function viewCtrlComponent.simpleViewCtrl.luaCanStartTransformHandle(screenPos)
		if not viewCtrlComponent.enable then
			return false
		end

		local selectEnt, entityHitPoint = editor:trySelectRaycastEntity(screenPos, viewCtrlComponent.selectType, true, true)

		if not selectEnt then
			return true
		end

		if not entityHitPoint then
			return false
		end

		local cameraPositionX, cameraPositionY, cameraPositionZ = pg.global.cameraMgr:GetWorldCameraPositionEx()
		local handleHitPoint = viewCtrlComponent.simpleViewCtrl.transformHandleHitPoint
		local entityDistance = Vector3.SqrDistanceEx(entityHitPoint.x, entityHitPoint.y, entityHitPoint.z, cameraPositionX, cameraPositionY, cameraPositionZ)
		local handleDistance = Vector3.SqrDistanceEx(handleHitPoint.x, handleHitPoint.y, handleHitPoint.z, cameraPositionX, cameraPositionY, cameraPositionZ)

		return handleDistance <= entityDistance
	end

	self.viewCtrlComponent:setGamepadShowHint(true)
	self.viewCtrlComponent:setKeyHintInfo("HudHomelandEdit", "HudHomelandPlacementConsole")
	self.editor:setEnableEdit(self.uid, true)
	self:initPlaceInfo(info)
	self.viewCtrlComponent:initCameraHeight()
	ClientTextUtils.setText(self.view.txtDisplayUSDFText, pg.getGameString("HOME_BUILD_WALL_DISPLAY_DESC"))
	ClientTextUtils.setText(self.view.txtMetreUSDFText, pg.getGameString("HOME_BUILD_CAMERA_HEIGHT_DESC"))
	self.view.btnDisplayUButton:TryChangePage("Dispaly", self.displayMode)
	self.view.btnDisplayUButton:SetActive(not self.carGroup and self.areaId == Const.HOMELAND_AREA_TYPE.BUILD)

	self.tempHitEntities = {}

	local globalEditComponentConfig = {
		mode = Const.HOMELAND_EDITOR_MODE.PLACEMENT,
		editor = self.editor,
		getIsMultiSelectFunc = function()
			return self.isFromMultiSelect
		end,
		onMultiSelectFunc = function(switch)
			return self:onMutiSelectBtnClick()
		end
	}

	function self.view.btnAreaUButton.luaRenderTooltip(btn, tipPanel)
		self:renderAreaTooltip(btn, tipPanel)
	end

	function self.view.btnAreaUButton.luaTooltipPopup(_, isOpen)
		if not isOpen then
			self.areaTooltipPanel = nil
			self.areaTooltipTxtNumUSDFText = nil
		end
	end

	self.globalEditingComponent = HomelandEditorTopListComponent(self, self.view.globalEditingUWidget, globalEditComponentConfig)
	self.view.uIPbHomePlacementUWidget.navRegionForceCursorOn = true

	local furnitureCount = self.editInfo.entities and #self.editInfo.entities or 0

	self.view.btnSaveUButton:SetActive(self.isFromMultiSelect == true and furnitureCount >= 2)
end

function HomelandPlacementCtrl:checkVirtualMouseHoverSnapEnabled()
	return true
end

function HomelandPlacementCtrl:initPlaceInfo(info)
	self.editor:finishEdit()
	self:initEditInfo(info)

	self.inDragEntity = false
end

function HomelandPlacementCtrl:close()
	if self.view and self.view.objectEditRoot then
		self.view.objectEditRoot:SetVisible(false)
	end

	UICtrl.close(self)
end

function HomelandPlacementCtrl:onDestroy()
	facade:sendMsgToUI(MessageName.HOMELAND_EDITOR_SETTING_REFRESH, {
		mode = Const.HOMELAND_EDITOR_MODE.PLACEMENT
	})
	self.editor:finishEdit()

	self.viewCtrlComponent = nil
	self.sliderMode = nil
	self.sliderUSlider = nil
	self.txtValueUSDFText = nil
	self.adjustRotationMode = nil
	self.adjustScaleMode = nil
	self.editorErrorType = nil
	self.progressText = nil
	self.areaTooltipPanel = nil
	self.areaTooltipTxtNumUSDFText = nil
	self.isBlueprintBuilding = false

	self.editor:setEnableEdit(self.uid, false)

	if self.tickTimer then
		self:killTimer(self.tickTimer)

		self.tickTimer = nil
	end

	UICtrl.onDestroy(self)
end

function HomelandPlacementCtrl:getWhiteList()
	local whiteList = {}

	whiteList[UIConst.UI_ID_HOMELAND_EDITOR_TOPLOGO] = true

	return whiteList
end

function HomelandPlacementCtrl:addListener()
	function self.view.btnBack.luaClick()
		self:close()
	end

	function self.view.undoBtn.luaClick()
		self:onUndoBtnClick()
	end

	function self.view.redoBtn.luaClick()
		self:onRedoBtnClick()
	end

	function self.view.confirmBtn.luaClick()
		self:onConfirmBtnClick()
	end

	function self.view.cancelBtn.luaClick()
		self:onCancelBtnClick()
	end

	function self.view.withdrawBtn.luaClick()
		self:onWithdrawBtnClick()
	end

	function self.view.btnSaveUButton.luaClick()
		self:onSaveComposeBtnClick()
	end

	function self.view.tabBtnGridUButton.luaClick()
		pg.global.ui.homelandEditorSetting:open()
	end

	function self.view.btnDisplayUButton.luaClick()
		self.displayMode = (self.displayMode + 1) % 3

		self.view.btnDisplayUButton:TryChangePage("Dispaly", self.displayMode)
		self.editor:setDisplayHideMode(self.displayMode)
		self.editor:refreshHeightHide()

		if self.displayMode == 0 then
			pg.global.ui.tips:showTextTip(pg.getGameString("HOMELAND_EDITOR_FULL_DISPLAY"))
		elseif self.displayMode == 1 then
			pg.global.ui.tips:showTextTip(pg.getGameString("HOMELAND_EDITOR_SEMI_HIDDEN"))
		elseif self.displayMode == 2 then
			pg.global.ui.tips:showTextTip(pg.getGameString("HOMELAND_EDITOR_FULL_HIDDEN"))
		end
	end

	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = 0
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			if self.sliderMode ~= nil then
				self:dismissSlider()
			else
				self:close()
			end
		end
	end

	function self.view.listCurrencyUList.luaRenderItem(button, index, data)
		self.homeCoinItemTable[data.itemId] = button

		LuaUIUtils.setTopCurrencyItem(button, data.itemId)
	end

	local currencyData = {}

	table.insert(currencyData, {
		itemId = Const.HomeCoinItemId
	})
	table.insert(currencyData, {
		itemId = Const.HomeDecCoinItemId
	})

	self.homeCoinItemTable = {}

	self.view.listCurrencyUList:SetList(currencyData)
	self:initConsoleKeyBind()
	self:addNavFocusListener(CallbackHandler(self, "onNavFocusChange"))
	ClientTextUtils.setText(self.view.txtSaveUSDFText, pg.getGameString("HOMELAND_COMPOSE_SAVE_COMBINATION"))
end

function HomelandPlacementCtrl:onVisibleChange(visible)
	if visible then
		self:refreshDisplayMode()
		self.viewCtrlComponent:refreshCameraHeight()
	end
end

function HomelandPlacementCtrl:refreshDisplayMode()
	self.displayMode = self.editor.displayHideMode

	self.view.btnDisplayUButton:TryChangePage("Dispaly", self.displayMode)
end

function HomelandPlacementCtrl:checkCommonQuit()
	if self.sliderMode ~= nil then
		return false
	end

	return UICtrl.checkCommonQuit(self)
end

function HomelandPlacementCtrl:onNavFocusChange()
	local inModal = pg.global.navMgr and pg.global.navMgr:IsInModalGroup() or false
	local inSliderMode = self.sliderMode ~= nil

	self.view.uIPbHomePlacementUWidget.navRegionForceCursorOn = not inModal and not inSliderMode

	pg.global.ui:refreshLockCursor()
end

function HomelandPlacementCtrl:refreshEditUIVisibilityForSliderMode()
	local hide = pg.game.input:isUsingGamepad() and self.sliderMode ~= nil

	if NotNil(self.view.globalEditingUWidget) then
		self.view.globalEditingUWidget:SetActive(not hide)
	end

	if NotNil(self.view.tabBarUWidget) then
		self.view.tabBarUWidget:SetActive(not hide)
	end

	if NotNil(self.view.stateWidget) then
		self.view.stateWidget:SetActive(not hide)
	end

	if NotNil(self.view.btnDisplayUButton) then
		local displayButtonEnabled = not self.carGroup and self.areaId == Const.HOMELAND_AREA_TYPE.BUILD

		self.view.btnDisplayUButton:SetActive(not hide and displayButtonEnabled)
	end
end

function HomelandPlacementCtrl:showItemCost(buyMoneyType, costNum)
	if not buyMoneyType or not costNum then
		return
	end

	if self.homeCoinItemTable and not IsNil(self.homeCoinItemTable[buyMoneyType]) then
		local button = self.homeCoinItemTable[buyMoneyType]
		local objectReference = button:GetComponent("ObjectReference")
		local reduceUContainer = objectReference:GetRefValue("reduceUContainer")

		self:showItemCostAnim(reduceUContainer, buyMoneyType, costNum)
	end
end

function HomelandPlacementCtrl:showItemCostAnim(container, buyMoneyType, costNum)
	if not container then
		return
	end

	if not container:CheckURLLoaded() then
		container:LoadDefaultUrlManually(function()
			self:showItemCostAnim(container, buyMoneyType, costNum)
		end)
	else
		local objectReference = container.content:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local textNumberUSDFText = objectReference:GetRefValue("textNumberUSDFText")

		iconUImage.url = LuaUIUtils.getIconByItemId(buyMoneyType)

		ClientTextUtils.setText(textNumberUSDFText, costNum)
		container:SetActive(false)
		container:SetActive(true)
		self:startTimer(function()
			if not IsNil(container) then
				container:SetActive(false)
			end
		end, 2)
	end
end

function HomelandPlacementCtrl:onTick()
	self:refreshPlaceState()
	self:RefreshLoadValue()
	self:refreshHistoryState()
	self:refreshBlueprintBuildGroupSplitButton()

	if self.placeConfig and self.placeConfig.isGroupPlace and self.editInfo and self.editInfo.editType == ClientConst.HomeEditType.PlaceOrnament then
		local pendingPlaceNum = self:getPendingPlaceOrnamentCount()

		if pendingPlaceNum ~= self.lastPendingPlaceNum then
			self.lastPendingPlaceNum = pendingPlaceNum

			self:refreshInfoText()
		end
	end
end

function HomelandPlacementCtrl:cancelPlacement()
	self:close()
end

function HomelandPlacementCtrl:tryQuickPlacement(entity)
	if not pg.game.home:getHomeEditorPlayerSetting(ClientConst.HomelandEditorSetting.QuickPlacement, true) then
		return false
	end

	if self.isFromMultiSelect then
		return false
	end

	if self.isBlueprintPlace then
		return false
	end

	if self.editInfo.editType == ClientConst.HomeEditType.PlaceOrnament or self.editInfo.editType == ClientConst.HomeEditType.PlacePet or self.editInfo.editType == ClientConst.HomeEditType.UpdatePet then
		return false
	end

	if not entity then
		return false
	end

	if Utils.isHomePet(entity) then
		return false
	end

	if not entity.canEntEdit or not entity:canEntEdit() then
		return false
	end

	if not entity.ornamentId or entity.ornamentId < 0 then
		return false
	end

	if self.areaId and entity.areaId ~= self.areaId then
		return false
	end

	return true
end

function HomelandPlacementCtrl:getQuickPlacementEditInfo(nextEntity)
	local nextEditInfo = {
		editType = ClientConst.HomeEditType.UpdateOrnament,
		editor = self.editor,
		carGroup = self.carGroup,
		areaId = self.areaId
	}
	local homeSpace = pg.me and pg.me.space

	if self.carGroup then
		homeSpace = self.carGroup.campCarEnt
	end

	if homeSpace and homeSpace.getHomeBlueprintBuildGroupByOrnamentId then
		local groupIndex = homeSpace:getHomeBlueprintBuildGroupByOrnamentId(nextEntity.ornamentId)

		if groupIndex then
			nextEditInfo.blueprintBuildGroupOrnamentId = nextEntity.ornamentId
		end
	end

	local editEntities = ClientHomelandUtils.collectOrnamentEditGroupEntities({
		nextEntity
	}, {
		editor = self.editor,
		areaId = self.areaId,
		homeSpace = homeSpace,
		getEntity = function(ornamentId)
			return self:getOrnamentEnt(ornamentId)
		end
	})

	if #editEntities > 1 then
		nextEditInfo.entities = editEntities
	else
		nextEditInfo.entity = nextEntity
	end

	return nextEditInfo
end

function HomelandPlacementCtrl:doQuickPlacement(nextEntity)
	local editorErrorType = self.editor:checkPlaceValid()

	if editorErrorType == Const.HomeEditorErrorType.Normal then
		self.editor:confirm(function()
			if self.editor then
				self.editor:showConfirmEffect()
			end

			self:initPlaceInfo(self:getQuickPlacementEditInfo(nextEntity))
		end)
	else
		self:initPlaceInfo(self:getQuickPlacementEditInfo(nextEntity))
	end
end

function HomelandPlacementCtrl:getOrnamentEnt(ornamentId)
	if self.carGroup then
		return self.carGroup:getHomeEntity(ornamentId)
	end

	return pg.game.home:getHomeEntity(ornamentId)
end

function HomelandPlacementCtrl:getCurrentBlueprintBuildGroup()
	if not self.blueprintBuildGroupOrnamentId then
		return
	end

	local homeSpace = pg.me and pg.me.space

	if self.carGroup then
		homeSpace = self.carGroup.campCarEnt
	end

	if not homeSpace or not homeSpace.getHomeBlueprintBuildGroupByOrnamentId then
		return
	end

	return homeSpace:getHomeBlueprintBuildGroupByOrnamentId(self.blueprintBuildGroupOrnamentId)
end

function HomelandPlacementCtrl:getHomeBlueprintGroupInfoList(entities)
	local homeSpace = pg.me and pg.me.space

	if self.carGroup then
		homeSpace = self.carGroup.campCarEnt
	end

	if not homeSpace or not homeSpace.getHomeBlueprintBuildGroupByOrnamentId then
		return {}
	end

	local groupInfoList = {}
	local groupIndexMap = {}

	for _, entity in ipairs(entities or EMPTY_TABLE) do
		local ornamentId = entity and entity.ornamentId

		if ornamentId then
			local groupIndex, groupInfo = homeSpace:getHomeBlueprintBuildGroupByOrnamentId(ornamentId)

			if groupIndex and groupInfo and not groupIndexMap[groupIndex] then
				groupIndexMap[groupIndex] = true

				local yawAngle = groupInfo.yawAngle or 0

				if not self.carGroup then
					local groupAreaId = groupInfo.areaId or self.areaId
					local defaultYawAngle = pg.game.home:getAreaOrnamentDefaultYaw(groupAreaId)

					yawAngle = (yawAngle - Utils.yawToYawAngleInt(defaultYawAngle)) % 36000
				end

				table.insert(groupInfoList, {
					groupIndex = groupIndex,
					yawAngle = yawAngle
				})
			end
		end
	end

	table.sort(groupInfoList, function(a, b)
		return a.groupIndex < b.groupIndex
	end)

	return groupInfoList
end

function HomelandPlacementCtrl:refreshBlueprintBuildGroupSplitButton()
	if not self.btnSplitUButton or IsNil(self.btnSplitUButton) then
		return
	end

	local groupIndex = self:getCurrentBlueprintBuildGroup()
	local active = self.editType == ClientConst.HomeEditType.UpdateOrnament and not self.isFromMultiSelect and not self.isBlueprintPlace and groupIndex ~= nil
	local isRequesting = pg.me and pg.me.isDeleteHomeBlueprintBuildGroupRequesting and pg.me:isDeleteHomeBlueprintBuildGroupRequesting()

	self.btnSplitUButton:SetActive(active)

	self.btnSplitUButton.interactable = active and not isRequesting
end

function HomelandPlacementCtrl:onBlueprintBuildGroupSplitBtnClick()
	if pg.me:isDeleteHomeBlueprintBuildGroupRequesting() then
		return
	end

	local groupIndex = self:getCurrentBlueprintBuildGroup()

	if not groupIndex then
		self:refreshBlueprintBuildGroupSplitButton()

		return
	end

	local canUndo = self.editor:getHistoryStatus()
	local shouldSave = canUndo and self.editor:checkPlaceValid() == Const.HomeEditorErrorType.Normal

	if shouldSave then
		self:doConfirm()
	end

	local requestView = self.view
	local requested = pg.me:deleteHomeBlueprintBuildGroup(groupIndex, function()
		if self.view == requestView then
			self:refreshBlueprintBuildGroupSplitButton()
		end
	end)

	if requested then
		self:refreshBlueprintBuildGroupSplitButton()
	end

	if not shouldSave then
		self:cancelPlacement()
	end
end

function HomelandPlacementCtrl:onCancelBtnClick()
	self:cancelPlacement()
end

function HomelandPlacementCtrl:onSaveComposeBtnClick()
	if not self.isFromMultiSelect then
		return
	end

	local furnitureCount = self.editInfo.entities and #self.editInfo.entities or 0

	if furnitureCount < 2 then
		pg.global.showBubbleMessageRaw(pg.getGameString("HOMELAND_COMPOSE_CREATE_MIN_FURNITURE_COUNT"))

		return
	end

	if self.editor:checkPlaceValid() == Const.HomeEditorErrorType.Normal then
		self:doConfirm(nil, true)
	else
		self:cancelPlacement()
		self.editor:finishEdit()
		pg.global.ui.homelandMultiSelect:openCreateComposeDetail()
	end
end

function HomelandPlacementCtrl:onWithdrawBtnClick()
	if self.editInfo.editType == ClientConst.HomeEditType.UpdateOrnament then
		if self:isMultiEdit(self.editInfo) then
			if self.carGroup then
				self.editor:withdrawEnt()
				self:close()
			elseif not pg.game.home:tryShowRemoveFacilitiesConfirm(self.editInfo.entities, function()
				self.editor:withdrawEnt()
				self:close()
			end) then
				self.editor:withdrawEnt()
				self:close()
			end
		elseif self.carGroup then
			self.editor:withdrawEnt()
			self:close()
		elseif not pg.game.home:tryShowRemoveFacilityConfirm(self.editInfo.entity.ornamentId, self.editInfo.entity.homeTemplateId, function()
			self.editor:withdrawEnt()
			self:close()
		end) then
			self.editor:withdrawEnt()
			self:close()
		end
	elseif self.editInfo.editType == ClientConst.HomeEditType.UpdatePet then
		self.editor:withdrawEnt()
		self:close()
	end
end

function HomelandPlacementCtrl:checkCanPlaceNewOrnament(templateId)
	local curNum = self.editor:getEntityCurPlaceNum(templateId)
	local maxNum = self.editor:getEntityMaxPlaceNum(templateId)

	if not maxNum then
		return true
	end

	return curNum < maxNum
end

function HomelandPlacementCtrl:checkContinuePlace(count)
	if self.placeConfig.isGroupPlace then
		return false
	end

	if self.editInfo.editType == ClientConst.HomeEditType.PlaceOrnament then
		if self.carGroup then
			local maxCount = HomelandConfigData.HomeCampOrnamentMax or 30

			if maxCount <= HomeLandUtils.getCarGroupOrnamentCount() then
				return false
			end
		end

		if not self:checkCanPlaceNewOrnament(self.editInfo.homeTemplateId) then
			return false
		end

		if self.editor.templateEntity == nil then
			return false
		end

		local ownNum = ClientUtils.getItemCountById(self.editInfo.homeTemplateId)

		if pg.me:isInSelfHomeland() then
			ownNum = ownNum + ClientUtils.getHomelandItemCountById(self.editInfo.homeTemplateId)
		end

		local bagCount = count or 0

		if bagCount < ownNum then
			return true
		end

		if not self.itemLocked and pg.game.home:getHomeEditorPlayerSetting(ClientConst.HomelandEditorSetting.ContinuousPurchase, false) then
			local homeObjectData = HomeObjectData[self.editInfo.homeTemplateId]

			if homeObjectData.getWay == Const.HOMELAND_ORNAMENT_GET_WAY.BUY or homeObjectData.getWay == Const.HOMELAND_ORNAMENT_GET_WAY.REDEEM then
				return true
			end
		end
	end

	return false
end

function HomelandPlacementCtrl:initContinuePlaceInfo()
	self.editInfo.continuePlace = true
	self.editInfo.last2TimePlaceInfo = self.editInfo.lastTimePlaceInfo
	self.editInfo.lastTimePlaceInfo = {
		localPosition = self.editor:getLocalPosition(self.editor.templateEntity:getPosition()),
		localRotation = self.editor:getLocalRotation(self.editor.templateEntity:getRotation())
	}
	self.editInfo.initPosition = self.editor:getWorldPosition(self:getContinuePlaceLocalPosition())
	self.editInfo.initRotation = self.editor:getWorldRotation(self.editInfo.lastTimePlaceInfo.localRotation)

	self:initPlaceInfo(self.editInfo)
end

function HomelandPlacementCtrl:getContinuePlaceLocalPosition()
	local homeObjectData = HomeObjectData[self.editInfo.homeTemplateId]
	local boundSize = homeObjectData.boundSize
	local localPosition = self.editInfo.lastTimePlaceInfo.localPosition:Clone()
	local boundX = boundSize[1]
	local boundZ = boundSize[2]

	if Utils.checkRotationIsVertical(self.editInfo.lastTimePlaceInfo.localRotation) then
		boundZ = boundSize[1]
		boundX = boundSize[2]
	end

	if self.editInfo.last2TimePlaceInfo then
		local positionDiff = self.editInfo.lastTimePlaceInfo.localPosition - self.editInfo.last2TimePlaceInfo.localPosition

		if math.abs(positionDiff.x) > 2 + boundX or math.abs(positionDiff.z) > 2 + boundZ then
			localPosition.x = localPosition.x + boundX
		else
			positionDiff.x = math.clamp(positionDiff.x, -boundX - 2, boundX + 2)
			positionDiff.z = math.clamp(positionDiff.z, -boundZ - 2, boundZ + 2)
			positionDiff.y = math.clamp(positionDiff.y, -2, 2)
			localPosition.x = localPosition.x + positionDiff.x
			localPosition.z = localPosition.z + positionDiff.z
			localPosition.y = localPosition.y + positionDiff.y
		end
	else
		localPosition.x = localPosition.x + boundX

		if not self.editor:checkBoundInArea(localPosition, self.editInfo.lastTimePlaceInfo.localRotation, boundSize) then
			local directionOffsets = {
				{
					-boundX,
					0
				},
				{
					0,
					boundZ
				},
				{
					0,
					-boundZ
				}
			}

			for _, directionOffset in ipairs(directionOffsets) do
				local candidatePosition = self.editInfo.lastTimePlaceInfo.localPosition:Clone()

				candidatePosition.x = candidatePosition.x + directionOffset[1]
				candidatePosition.z = candidatePosition.z + directionOffset[2]

				if self.editor:checkBoundInArea(candidatePosition, self.editInfo.lastTimePlaceInfo.localRotation, boundSize) then
					localPosition = candidatePosition

					break
				end
			end
		end
	end

	return localPosition
end

function HomelandPlacementCtrl:onConfirmBtnClick()
	if self.isBlueprintPlace then
		self:doConfirmBlueprint()

		return
	end

	local editType = self.editInfo.editType
	local isGroupPlace = self.editor.placeConfig and self.editor.placeConfig.isGroupPlace
	local requireNum

	if editType == ClientConst.HomeEditType.PlaceOrnament then
		requireNum = 1

		if isGroupPlace then
			requireNum = self.editor.templateEntity:getGroupPlaceChildCount()
		end
	elseif editType == ClientConst.HomeEditType.UpdateOrnament and isGroupPlace then
		requireNum = self.editor.templateEntity:getGroupPlaceChildCount() - 1
	end

	if requireNum and requireNum > 0 then
		local ownNum = ClientUtils.getItemCountById(self.editInfo.homeTemplateId)

		if pg.me:isInSelfHomeland() then
			ownNum = ownNum + ClientUtils.getHomelandItemCountById(self.editInfo.homeTemplateId)
		end

		if requireNum <= ownNum or self.itemLocked then
			self:doConfirm()
		else
			local homeObjectData = HomeObjectData[self.editInfo.homeTemplateId]

			if homeObjectData.getWay == Const.HOMELAND_ORNAMENT_GET_WAY.BUY then
				self:requireBuyOrnament(requireNum - ownNum)
			elseif homeObjectData.getWay == Const.HOMELAND_ORNAMENT_GET_WAY.REDEEM then
				self:requireRedeemOrnament(requireNum - ownNum)
			elseif homeObjectData.getWay == Const.HOMELAND_ORNAMENT_GET_WAY.ACTIVITY then
				pg.global.showBubbleMessage(NoticeDef.HOME_ACTIVITY_ITEM_LACK)
			end
		end

		return
	end

	self:doConfirm()
end

function HomelandPlacementCtrl:checkBlueprintFurnitureEnough()
	local blueprintData = self.editInfo and self.editInfo.blueprintData
	local ornaments = blueprintData and blueprintData.ornaments

	if type(ornaments) ~= "table" or #ornaments <= 0 then
		return false
	end

	local requireCounts = {}

	for _, ornamentInfo in ipairs(ornaments) do
		local homeId = ornamentInfo and ornamentInfo.homeId

		if not homeId then
			return false
		end

		requireCounts[homeId] = (requireCounts[homeId] or 0) + 1
	end

	for homeId, requireCount in pairs(requireCounts) do
		local ownNum = ClientUtils.getItemCountById(homeId) or 0

		if pg.me:isInSelfHomeland() then
			ownNum = ownNum + ClientUtils.getHomelandItemCountById(homeId)
		end

		if ownNum < requireCount then
			return false
		end
	end

	return true
end

function HomelandPlacementCtrl:doConfirmBlueprint()
	if self.isBlueprintBuilding then
		return
	end

	if self.editor:checkPlaceValid() ~= Const.HomeEditorErrorType.Normal then
		return
	end

	if not self:checkBlueprintFurnitureEnough() then
		pg.global.showBubbleMessageRaw(pg.getGameString("HOMELAND_COMPOSE_FURNITURE_NOT_ENOUGH"))

		return
	end

	local blueprintId = self.editInfo.blueprintId
	local sourceType = self.editInfo.sourceType
	local templateEntity = self.editor.templateEntity

	if not sourceType or not blueprintId or blueprintId == "" or not templateEntity then
		pg.me:showBlueprintNotice(Const.HOME_BLUEPRINT_OP_RETURN_CODE.ERROR_PARAM)

		return
	end

	local localPosition = self.editor:getLocalPosition(templateEntity:getPosition())
	local localRotation = self.editor:getLocalRotation(templateEntity:getRotation())
	local targetPos3 = Utils.positionToPos3(localPosition)
	local targetYawAngle = Utils.yawToYawAngleInt(Utils.normalizeAngle(math.deg(localRotation:ToYaw())))
	local areaId = self.carGroup and -1 or self.areaId or 0

	self:dismissSlider()

	self.isBlueprintBuilding = true

	local requestView = self.view

	pg.me:buildHomeBlueprint(sourceType, blueprintId, targetPos3, targetYawAngle, areaId, function(isAccepted)
		if self.view ~= requestView then
			return
		end

		self.isBlueprintBuilding = false

		if isAccepted and self.view then
			self:close()
		end
	end)
end

function HomelandPlacementCtrl:requireRedeemOrnament(buyNum)
	if pg.game.home.curLoginPlaceShowConfirmHint then
		local homeObjectData = HomeObjectData[self.editInfo.homeTemplateId]
		local ornamentName = pg.getLocalizationText(homeObjectData.name)
		local buyData = {}

		if homeObjectData.buyItemId1 then
			local ownNum = ItemUtils.getItemCountById(pg.me, homeObjectData.buyItemId1)

			if pg.me:isInSelfHomeland() then
				ownNum = ownNum + ClientUtils.getHomelandItemCountById(homeObjectData.buyItemId1)
			end

			table.insert(buyData, {
				homeObjectData.buyItemId1,
				homeObjectData.buyItemNum1 * buyNum,
				ownNum = ownNum
			})
		end

		if homeObjectData.buyItemId2 then
			local ownNum = ItemUtils.getItemCountById(pg.me, homeObjectData.buyItemId2)

			if pg.me:isInSelfHomeland() then
				ownNum = ownNum + ClientUtils.getHomelandItemCountById(homeObjectData.buyItemId2)
			end

			table.insert(buyData, {
				homeObjectData.buyItemId2,
				homeObjectData.buyItemNum2 * buyNum,
				ownNum = ownNum
			})
		end

		local ornamentText = pg.getFormatText(" <style=Hint_BgL>{0}</style>", ornamentName)

		pg.global.ui.commonUseConfirm:open({
			hideCurrency = 1,
			type = 1,
			showHint = true,
			title = pg.getGameString("CONFIRM_BUY"),
			tipTop = pg.getFormatText(pg.getGameString("HOME_PLACE_REDEEM_DESC"), ornamentText, buyNum),
			data = buyData,
			notEnoughCallback = function(itemId, itemNum)
				pg.global.showBubbleMessage(NoticeDef.HOME_REDEEM_LACK)
			end,
			confirmCb = function()
				pg.global.ui.commonUseConfirm:close()
				self:doRedeemOrnament(buyNum)
			end,
			cancelCb = function()
				pg.global.ui.commonUseConfirm:close()
			end,
			hintCb = function(isSelected)
				pg.game.home.curLoginPlaceShowConfirmHint = not isSelected
			end,
			hintText = pg.getGameString("LOGIN_NOT_SHOW_HINT")
		})
	else
		self:doRedeemOrnament(buyNum)
	end
end

function HomelandPlacementCtrl:doRedeemOrnament(buyNum)
	pg.me:serverMsg("RPC_CS_RedeemMultiOrnament", self.editInfo.homeTemplateId, buyNum, function(returnCode)
		if returnCode == 0 then
			pg.global.showBubbleMessage(NoticeDef.BUY_SUCCESS)
			self:doConfirm(true)
		else
			self:showRedeemRetNotice(returnCode)
		end
	end)
end

function HomelandPlacementCtrl:showRedeemRetNotice(returnCode)
	if returnCode == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.ERROR_ORNAMENT_BUY_COUNT_MAX then
		pg.global.showBubbleMessage(NoticeDef.HOME_ERROR_ORNAMENT_BUY_COUNT_MAX)

		return
	elseif returnCode == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.ERROR_ITEM_NOT_ENOUGH then
		pg.global.showBubbleMessage(NoticeDef.HOME_REDEEM_LACK)

		return
	end

	pg.global.showBubbleMessage(NoticeDef.BUY_FAILED)
end

function HomelandPlacementCtrl:requireBuyOrnament(buyNum)
	local homeObjectData = HomeObjectData[self.editInfo.homeTemplateId]
	local buyMoneyType = homeObjectData.buyMoneyType
	local buyMoneyNum = homeObjectData.buyMoneyNum

	if pg.space and pg.space.demoMode == true and Const.HOMELAND_DEMO_SHELL_BUY_ORNAMENT_IDS[self.editInfo.homeTemplateId] then
		buyMoneyType = Const.HOMELAND_DEMO_SHELL_ITEM_ID
		buyMoneyNum = Const.HOMELAND_DEMO_SHELL_BUY_ORNAMENT_PRICE
	end

	if pg.game.home.curLoginPlaceShowConfirmHint then
		local costText = LuaUIUtils.getItemCountConsumeShowText(buyMoneyType, buyMoneyNum * buyNum, true)
		local ornamentName = pg.getLocalizationText(homeObjectData.name)
		local ornamentText = pg.getFormatText(" <style=Hint_BgL>{0}</style>", ornamentName)

		pg.global.ui.commonUseConfirm:open({
			type = 4,
			showHint = true,
			title = pg.getGameString("CONFIRM_BUY"),
			tipTop = pg.getFormatText(pg.getGameString("HOME_PLACE_BUY_DESC"), ornamentText, buyNum, costText),
			data = {
				{
					buyMoneyType,
					buyMoneyNum
				}
			},
			notEnoughCallback = function(itemId, itemNum)
				if buyMoneyType == HomelandConfigData.homeCurrencyId then
					pg.global.showBubbleMessage(NoticeDef.HOME_COIN_LACK)
				elseif buyMoneyType == HomelandConfigData.homeVoucherId then
					pg.global.showBubbleMessage(NoticeDef.HOME_COIN_LACK_VOUCHER)
				elseif buyMoneyType == Const.HOMELAND_DEMO_SHELL_ITEM_ID then
					pg.global.showBubbleMessage(NoticeDef.ITEM_USE_OUT)
				end
			end,
			confirmCb = function()
				pg.global.ui.commonUseConfirm:close()
				self:doBuyOrnament(buyNum, buyMoneyNum * buyNum)
			end,
			cancelCb = function()
				pg.global.ui.commonUseConfirm:close()
			end,
			hintText = pg.getGameString("LOGIN_NOT_SHOW_HINT"),
			hintCb = function(isSelected)
				pg.game.home.curLoginPlaceShowConfirmHint = not isSelected
			end
		})
	else
		self:doBuyOrnament(buyNum, buyMoneyNum * buyNum)
	end
end

function HomelandPlacementCtrl:doBuyOrnament(buyNum, consumeCost)
	pg.me:serverMsg("RPC_CS_BuyMultiOrnament", self.editInfo.homeTemplateId, buyNum, function(returnCode)
		local homeObjectData = HomeObjectData[self.editInfo.homeTemplateId]
		local buyMoneyType = homeObjectData.buyMoneyType

		if pg.space and pg.space.demoMode == true and Const.HOMELAND_DEMO_SHELL_BUY_ORNAMENT_IDS[self.editInfo.homeTemplateId] then
			buyMoneyType = Const.HOMELAND_DEMO_SHELL_ITEM_ID
		end

		if returnCode == 0 then
			pg.global.showBubbleMessage(NoticeDef.BUY_SUCCESS)

			if self:checkContinuePlace(1) then
				self:showItemCost(buyMoneyType, consumeCost)
			else
				pg.global.ui.homelandEditor:showItemCost(buyMoneyType, consumeCost)
			end

			self:doConfirm(true)
		else
			self:showBuyRetNotice(returnCode, buyMoneyType)
		end
	end)
end

function HomelandPlacementCtrl:showBuyRetNotice(returnCode, buyMoneyType)
	if returnCode == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.ERROR_ORNAMENT_BUY_COUNT_MAX then
		pg.global.showBubbleMessage(NoticeDef.HOME_ERROR_ORNAMENT_BUY_COUNT_MAX)

		return
	elseif returnCode == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.ERROR_ITEM_NOT_ENOUGH then
		-- block empty
	end

	if buyMoneyType == HomelandConfigData.homeCurrencyId then
		pg.global.showBubbleMessage(NoticeDef.HOME_COIN_LACK)
	elseif buyMoneyType == HomelandConfigData.homeVoucherId then
		pg.global.showBubbleMessage(NoticeDef.HOME_COIN_LACK_VOUCHER)
	end
end

function HomelandPlacementCtrl:doConfirm(isBuy, isSaveCompose)
	local is_continuous_place = self.editInfo.continuePlace

	self.editor:confirm(function(operationType)
		if not self.isPet and operationType == Const.HOMELAND_ORNAMENT_OP_TYPE.ADD then
			pg.game.audio:triggerEvent(AudioConst.EVENT_HOME_ARCHITECTURE_PLACE)
		end

		if self.editor then
			self.editor:showConfirmEffect()
		end

		if isSaveCompose then
			self:close()
			self.editor:finishEdit()
			pg.global.ui.homelandMultiSelect:openCreateComposeDetail()
		elseif self:checkContinuePlace() then
			self:initContinuePlaceInfo()
		else
			if self.isFromMultiSelect then
				pg.global.ui.homelandMultiSelect:close()
			end

			self:close()
		end
	end)
	GlobalData.BILogger:customeLog("home_build_mode", {
		action_type = "edit_confirm",
		is_multiple_choice = 0,
		is_multiple_edit = self.isFromMultiSelect and 1 or 0,
		is_continuous_place = is_continuous_place and 1 or 0,
		is_continuous_buy = isBuy and is_continuous_place and 1 or 0
	})
end

function HomelandPlacementCtrl:updateCurrencyData()
	self.view.listCurrencyUList:RefreshList()
end

function HomelandPlacementCtrl:onItemCountChanged(data)
	self:updateCurrencyData()
	self:refreshInfoText()
end

function HomelandPlacementCtrl:onUndoBtnClick()
	self.editor:undo()
	self:refreshHistoryState()
	self:refreshEditInfo()
end

function HomelandPlacementCtrl:onRedoBtnClick()
	self.editor:redo()
	self:refreshHistoryState()
	self:refreshEditInfo()
end

function HomelandPlacementCtrl:onMutiSelectBtnClick()
	local canUndo, canRedo = self.editor:getHistoryStatus()

	if self.isFromMultiSelect then
		if not canUndo and not canRedo then
			pg.global.ui.homelandMultiSelect:closePanel()
			self:close()
		else
			pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("QUIT_EDIT_CONFIRM"), function()
				pg.global.ui.homelandMultiSelect:closePanel()
				self:close()
			end)

			return true
		end
	else
		local preSelectEntity, preSelectEntities

		if self.editType == ClientConst.HomeEditType.UpdateOrnament then
			if self.editInfo.entities then
				preSelectEntities = self.editInfo.entities
			else
				preSelectEntity = self.editInfo.entity
			end
		end

		if not canUndo and not canRedo then
			pg.global.ui.homelandMultiSelect:open({
				editor = self.editor,
				preSelectEntity = preSelectEntity,
				preSelectEntities = preSelectEntities,
				carGroup = self.carGroup,
				areaId = self.areaId
			})
			self:close()
		else
			pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("QUIT_EDIT_CONFIRM"), function()
				pg.global.ui.homelandMultiSelect:open({
					editor = self.editor,
					preSelectEntity = preSelectEntity,
					preSelectEntities = preSelectEntities,
					carGroup = self.carGroup,
					areaId = self.areaId
				})
				self:close()
			end)

			return true
		end
	end
end

function HomelandPlacementCtrl:refreshHistoryState()
	local canUndo, canRedo = self.editor:getHistoryStatus()

	self.view.undoBtn.interactable = canUndo
	self.view.redoBtn.interactable = canRedo
end

function HomelandPlacementCtrl:refreshPlaceState()
	local editorErrorType = self.editor:checkPlaceValid()

	if editorErrorType == Const.HomeEditorErrorType.Normal then
		self.view.confirmBtn.interactable = true
	else
		self.view.confirmBtn.interactable = false
	end

	self:refreshErrorInfo(editorErrorType)

	if self.isPet then
		local btnWorldPetRef = self.view.btnWorldPet:GetComponent("ObjectReference")
		local workIcon = btnWorldPetRef:GetRefValue("workIcon")
		local workText = btnWorldPetRef:GetRefValue("workText")
		local petExchangeUWidget = btnWorldPetRef:GetRefValue("petExchangeUWidget")
		local petExchangeUButton = btnWorldPetRef:GetRefValue("petExchangeUButton")
		local templateEntity = self.editor.templateEntity

		if templateEntity.petRelateOperationId then
			workIcon:SetActive(true)
			workText:SetActive(true)

			local operationData = HomelandOperateData[templateEntity.petRelateOperationId] or {}
			local interactionId = operationData.interactionId

			if interactionId then
				local interactInfo = InteractData[interactionId]

				workIcon.url = operationData.workingIcon

				if templateEntity.petOperValid then
					ClientTextUtils.setText(workText, pg.getLocalizationText(interactInfo.actionName))
				else
					local infoText = pg.getFormatText(pg.getGameString("HOME_UNABLE_DO"), pg.getLocalizationText(interactInfo.actionName))

					ClientTextUtils.setText(workText, infoText)
				end
			else
				workIcon:SetActive(false)
				workText:SetActive(false)
			end

			if templateEntity.petOperValid and templateEntity.fitPersonality and templateEntity.fitPersonality ~= 0 then
				petExchangeUWidget:SetActive(true)
				LuaUIUtils.renderTalentItem(petExchangeUButton, templateEntity.fitPersonality)
			else
				petExchangeUWidget:SetActive(false)
			end
		else
			workIcon:SetActive(false)
			workText:SetActive(false)
		end
	end
end

function HomelandPlacementCtrl:refreshLoadProgressValue(data)
	self.view.progressUProgress.minValue = 0
	self.view.progressUProgress.maxValue = 1

	local progress = math.clamp(data, 0, 1)

	self.view.progressUProgress.value = progress
end

function HomelandPlacementCtrl:refreshLoadProgressColor(data)
	if data <= 0.6 then
		self.view.btnAreaUButton:TryChangePage("Load", 0)
	elseif data <= 0.9 then
		self.view.btnAreaUButton:TryChangePage("Load", 1)
	else
		self.view.btnAreaUButton:TryChangePage("Load", 2)
	end
end

function HomelandPlacementCtrl:renderAreaTooltip(btn, tipPanel)
	self.areaTooltipPanel = tipPanel

	local objectReference = tipPanel:GetComponent("ObjectReference")

	self.areaTooltipTxtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")

	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")

	if self.carGroup then
		ClientTextUtils.setText(txtTitleUSDFText, ClientTextUtils.pg.getGameString("HOME_CAMP"))
	elseif AreaData[self.areaId] and AreaData[self.areaId].name then
		ClientTextUtils.setText(txtTitleUSDFText, ClientTextUtils.getLocalizationText(AreaData[self.areaId].name))
	end

	self:refreshAreaTooltipProgressText()
end

function HomelandPlacementCtrl:refreshAreaTooltipProgressText()
	local txtNumUSDFText = self.areaTooltipTxtNumUSDFText

	if txtNumUSDFText == nil or IsNil(txtNumUSDFText) then
		return
	end

	ClientTextUtils.setText(txtNumUSDFText, self.progressText or "")
end

function HomelandPlacementCtrl:refreshAreaTooltip()
	local button = self.view.btnAreaUButton
	local tipPanel = self.areaTooltipPanel

	if not button.isTooltipOpen or tipPanel == nil or IsNil(tipPanel) then
		return
	end

	if button.luaRenderTooltip then
		button.luaRenderTooltip(button, tipPanel)
	end
end

function HomelandPlacementCtrl:refreshLoadType()
	if self.carGroup then
		self.view.btnAreaUButton:TryChangePage("Type", 2)

		return
	end

	if self.areaId == 0 then
		self.view.btnAreaUButton:TryChangePage("Type", 0)
	else
		self.view.btnAreaUButton:TryChangePage("Type", 1)
	end
end

function HomelandPlacementCtrl:RefreshLoadValue(areaId)
	local preview = self:getHomelandPreviewLoadValue(self:getPendingPlaceLoadValue(), areaId)
	local limitData = ClientHomelandUtils.getHomelandLoadValueLimit(self.areaId, self.carGroup)
	local progress = preview / limitData

	self.progressText = preview .. "/" .. limitData

	self:refreshAreaTooltip()
	self:refreshLoadProgressValue(progress)
	self:refreshLoadType()
	self:refreshLoadProgressColor(progress)

	return preview
end

function HomelandPlacementCtrl:getHomelandCurLoadValue(areaId)
	return ClientHomelandUtils.getHomelandCurLoadValue(areaId or self.areaId, self.carGroup)
end

function HomelandPlacementCtrl:getHomelandPreviewLoadValue(addLoadValue, areaId)
	return ClientHomelandUtils.getHomelandPreviewLoadValue(addLoadValue, areaId or self.areaId, self.carGroup)
end

function HomelandPlacementCtrl:getPendingPlaceOrnamentCount()
	return ClientHomelandUtils.getPendingPlaceOrnamentCount({
		editor = self.editor,
		editInfo = self.editInfo,
		isPet = self.isPet
	})
end

function HomelandPlacementCtrl:getPendingPlaceLoadValue()
	return ClientHomelandUtils.getPendingPlaceLoadValue({
		editor = self.editor,
		editInfo = self.editInfo,
		isPet = self.isPet
	})
end

function HomelandPlacementCtrl:isMultiEdit(info)
	if info and info.entities then
		return true
	end

	return false
end

function HomelandPlacementCtrl:initPlaceConfig(info, placeConfig)
	if info.editType == ClientConst.HomeEditType.UpdateOrnament or info.editType == ClientConst.HomeEditType.PlaceOrnament then
		if info.isBlueprintPlace then
			local blueprintData = info.blueprintData or {}

			for _, ornamentInfo in ipairs(blueprintData.ornaments or EMPTY_TABLE) do
				if ornamentInfo.homeId and HomeObjectData[ornamentInfo.homeId] then
					self:updateOrnamentPlaceConfig(ornamentInfo.homeId, placeConfig)
				end
			end

			placeConfig.allowThreeAxisRotation = nil
			placeConfig.allowThreeAxisScale = nil
			placeConfig.disableScale = true
			placeConfig.rotationStep = 90

			return
		end

		if info.editType == ClientConst.HomeEditType.UpdateOrnament then
			local editEntities = info.entities

			if not editEntities and info.entity then
				editEntities = {
					info.entity
				}
			end

			local homeBlueprintGroupInfoList = self:getHomeBlueprintGroupInfoList(editEntities)

			if #homeBlueprintGroupInfoList > 0 then
				placeConfig.homeBlueprintGroupInfoList = homeBlueprintGroupInfoList

				if not self.isFromMultiSelect and #homeBlueprintGroupInfoList == 1 then
					placeConfig.homeBlueprintGroupInitialYawAngle = homeBlueprintGroupInfoList[1].yawAngle
				end
			end
		end

		if self:isMultiEdit(info) then
			if info.editType == ClientConst.HomeEditType.UpdateOrnament then
				for _, entity in ipairs(info.entities) do
					self:updateOrnamentPlaceConfig(entity.homeTemplateId, placeConfig, entity)
				end
			end

			placeConfig.allowThreeAxisRotation = nil
			placeConfig.allowThreeAxisScale = nil
			placeConfig.disableScale = true
			placeConfig.rotationStep = 90
		else
			local homeTemplateId = info.homeTemplateId

			if info.editType == ClientConst.HomeEditType.UpdateOrnament then
				homeTemplateId = info.entity.homeTemplateId
			end

			self:updateOrnamentPlaceConfig(homeTemplateId, self.placeConfig, info.entity)

			local homeObjectData = HomeObjectData[homeTemplateId]

			if (info.editType == ClientConst.HomeEditType.PlaceOrnament or info.editType == ClientConst.HomeEditType.UpdateOrnament) and (homeObjectData.groupPlace or homeObjectData.groupPlaceDiagonal or homeObjectData.groupPlacePoint) and not self.carGroup then
				placeConfig.isGroupPlace = true
			end
		end
	end
end

function HomelandPlacementCtrl:updateOrnamentPlaceConfig(homeTemplateId, placeConfig, entity)
	local homeObjectData = HomeObjectData[homeTemplateId]

	if placeConfig.freeYAxis ~= false then
		if homeObjectData.canEditYAxis then
			placeConfig.freeYAxis = true
			placeConfig.yAxisUnit = homeObjectData.yAxisUnit or 0.25
		else
			placeConfig.freeYAxis = false
		end
	end

	if homeObjectData.allowThreeAxisRotation == 1 then
		placeConfig.allowThreeAxisRotation = true
	end

	if homeObjectData.allowThreeAxisScale == 1 then
		placeConfig.allowThreeAxisScale = true
	elseif homeObjectData.allowThreeAxisScale == 2 then
		placeConfig.disableScale = true
	end

	if entity and entity.eModel and entity.eModel:CheckPositionAgent() then
		local _csx, _csy, _csz = entity.eModel:GetPositionAgentLocalScaleEx()

		placeConfig.forceThreeAxisScale = self:needForceThreeAxisXYZ(_csx, _csy, _csz)
	end

	if homeObjectData.facilityId then
		placeConfig.allowThreeAxisRotation = false
		placeConfig.disableScale = true
	end

	placeConfig.minScale = homeObjectData.minScale
	placeConfig.maxScale = homeObjectData.maxScale
end

function HomelandPlacementCtrl:initEditInfo(info)
	self.editType = info.editType
	self.isPet = false
	self.editInfo = info
	self.blueprintBuildGroupOrnamentId = info.blueprintBuildGroupOrnamentId
	self.placeConfig = {}

	self:initPlaceConfig(info, self.placeConfig)

	if info.editType == ClientConst.HomeEditType.UpdateOrnament then
		if self:isMultiEdit(info) then
			self.editor:startEditMulti(info.entities, self.placeConfig)
		else
			if not self.editInfo.homeTemplateId and info.entity then
				self.editInfo.homeTemplateId = info.entity.homeTemplateId
			end

			self.editor:startEdit(info.entity, self.placeConfig)
		end

		self.view.withdrawBtn:SetActive(true)
	elseif info.editType == ClientConst.HomeEditType.PlaceOrnament then
		if info.isBlueprintPlace then
			self.itemLocked = false

			self.editor:startEditBlueprint(info.blueprintData, {
				position = info.initPosition,
				rotation = info.initRotation
			}, self.placeConfig)

			local localRotation = self.editor:getLocalRotation(self.editor.templateEntity:getRotation())
			local yaw = Utils.normalizeAngle(math.deg(localRotation:ToYaw()))

			self.editor:setCachedEulerAngles(0, math.round(yaw), 0)
		else
			local entityData = {
				itemId = info.homeTemplateId
			}

			self.itemLocked = false

			local homeObjectData = HomeObjectData[info.homeTemplateId]

			if homeObjectData.unlockCondition then
				self.itemLocked = not pg.me.triggerMap:isCompleteOrMeetCondition(homeObjectData.unlockCondition)
			end

			self.editor:startEditNew(info.homeTemplateId, entityData, {
				position = info.initPosition,
				rotation = info.initRotation
			}, self.placeConfig)
		end

		self.view.withdrawBtn:SetActive(false)
	elseif info.editType == ClientConst.HomeEditType.PlacePet then
		local entityData = {
			petId = info.petId
		}

		self.editor:startEditNewPet(entityData, self.placeConfig)

		self.isPet = true

		self.view.withdrawBtn:SetActive(false)
	elseif info.editType == ClientConst.HomeEditType.UpdatePet then
		self.editor:startEdit(info.entity, self.placeConfig)

		self.isPet = true

		self.view.withdrawBtn:SetActive(true)
	end

	self.view.objectEditRoot:SetVisible(true)

	local targetEnt = self.editor.templateEntity

	self.view.objectEditRoot:AttachToTransById(targetEnt.id)

	if self.isPet then
		self.view.btnWorldPet:SetActive(true)
		self.view.btnWorldItemSimple:SetActive(false)
		self:initPetItemEditor()
	else
		self.view.btnWorldPet:SetActive(false)
		self.view.btnWorldItemSimple:SetActive(true)
		self:initWorldItemEditor()
	end

	if self.editInfo.moveCamera then
		self.editor:moveCameraToEditEntity()
	end

	self:refreshEditInfo()

	function self.viewCtrlComponent.onStartDrag(screenPos, buttonType)
		self:dismissSlider()

		if not pg.global.ui.uiMgr:CheckIsMobileInteract() and buttonType ~= ClientConst.InputButtonType.Left then
			return self.inDragEntity
		end

		table.clear(self.tempHitEntities)
		HomeEditorUtils.GetRaycastHitHomeEntities(screenPos, 300, self.tempHitEntities)

		self.inDragEntity = targetEnt:checkHitEntity(screenPos, self.tempHitEntities)

		if self.inDragEntity then
			self:onViewDragTemplate(screenPos)
		end

		return self.inDragEntity
	end

	function self.viewCtrlComponent.onEndDrag(screenPos)
		local inDragEntity = self.inDragEntity

		if self.inDragEntity then
			self.inDragEntity = false

			self.editor:onFinishDragTemplate(screenPos)
		end

		return inDragEntity
	end

	function self.viewCtrlComponent.onDrag(screenPos)
		if self.inDragEntity then
			self.editor:onDraggingTemplate(screenPos)
		end

		return self.inDragEntity
	end

	function self.viewCtrlComponent.onSelectEnt(entity)
		self:dismissSlider()

		if self:tryQuickPlacement(entity) then
			self:doQuickPlacement(entity)
		end
	end

	self:refreshPlaceState()
	self:refreshHotKeyContents()
	self:refreshEnvSimulateInfo()
end

function HomelandPlacementCtrl:onViewDragTemplate(screenPos)
	local useRaycastDrag, raycastDragPosOffset = self:getRaycastDragInfo(self.editor.templateEntity)

	self.editor:onStartDragTemplate(screenPos, useRaycastDrag, raycastDragPosOffset)
end

function HomelandPlacementCtrl:getRaycastDragInfo(templateEntity)
	if not self.placeConfig or not self.placeConfig.freeYAxis then
		return false
	end

	if not templateEntity then
		return false
	end

	local srcEntity

	if templateEntity.getChildEntities then
		if templateEntity.getGroupMainEntity then
			srcEntity = templateEntity:getGroupMainEntity()
		end
	else
		srcEntity = templateEntity
	end

	if not srcEntity then
		return false
	end

	return true, self:calcFirstAttachRootDragOffset(srcEntity)
end

function HomelandPlacementCtrl:calcFirstAttachRootDragOffset(entity)
	if not entity.homeTemplateId then
		return nil
	end

	local homeBuildInfo = HomeBuildData[entity.homeTemplateId]

	if not homeBuildInfo or not homeBuildInfo.attachRoots then
		return nil
	end

	local attachRootInfo = homeBuildInfo.attachRoots[1]

	if not attachRootInfo or not attachRootInfo.position then
		return nil
	end

	local rootOffset = Vector3.New(attachRootInfo.position[1], attachRootInfo.position[2], attachRootInfo.position[3])
	local scale = entity:getScale()

	if scale then
		rootOffset:MulVector3(scale)
	end

	local rotation = entity:getRotation()
	local worldOffset = rotation * rootOffset

	return worldOffset
end

function HomelandPlacementCtrl:refreshEnvSimulateInfo()
	if self.carGroup then
		self.view.widgetPrompt:SetActive(false)
		self.view.tabBtnGridUButton:SetActive(false)
	else
		local enableEnvSimulate = pg.game.home:checkEnableHomeSimulate()

		self.view.widgetPrompt:SetActive(enableEnvSimulate)
		self.view.tabBtnGridUButton:SetActive(false)
	end
end

function HomelandPlacementCtrl:initPetItemEditor()
	local objectReference = self.view.btnWorldPet:GetComponent("ObjectReference")
	local moveDragArea = objectReference:GetRefValue("dragArea")

	function moveDragArea.luaBeginDrag(screenPos)
		self.editor:onStartDragTemplate(screenPos)
	end

	function moveDragArea.luaDrag(screenPos)
		self.editor:onDraggingTemplate(screenPos)
	end

	function moveDragArea.luaEndDrag(screenPos)
		self.editor:onFinishDragTemplate(screenPos)
	end

	function moveDragArea.luaDragUpdate(screenPos)
		self.editor:onDraggingTemplate(screenPos)
	end

	local icon = objectReference:GetRefValue("icon")
	local petInfo = pg.me:getPetInfo(self.editInfo.petId)
	local templateId = petInfo.templateId
	local petData = PetData[templateId]

	icon.url = LuaUIUtils.getPetIcon(petData.iconName, LuaUIUtils.PET_ICON, petInfo.label, petInfo.gender)
end

function HomelandPlacementCtrl:initWorldItemEditor()
	local objectReference = self.view.btnWorldItemSimple:GetComponent("ObjectReference")
	local btnRotate = objectReference:GetRefValue("btnRotate")
	local btnMove = objectReference:GetRefValue("btnMove")
	local btnUpDown = objectReference:GetRefValue("btnUpDown")
	local textRotateUSDFText = objectReference:GetRefValue("textRotateUSDFText")
	local textScalingUSDFTexT = objectReference:GetRefValue("textScalingUSDFTexT")

	self.btnRotateCheckUButton = objectReference:GetRefValue("btnRotateCheckUButton")
	self.btnScalingCheckUButton = objectReference:GetRefValue("btnScalingCheckUButton")
	self.adjustSilderUContainer = objectReference:GetRefValue("adjustSilderUContainer")
	self.btnRotateHotKeyContent = objectReference:GetRefValue("btnRotateHotKeyContent")
	self.btnRotateCheckHotKeyContent = objectReference:GetRefValue("btnRotateCheckHotKeyContent")
	self.btnScaleCheckHotKeyContent = objectReference:GetRefValue("btnScaleCheckHotKeyContent")
	self.btnSplitUButton = objectReference:GetRefValue("btnSplitUButton")
	self.textSaveUSDFText = objectReference:GetRefValue("textSaveUSDFText")

	function btnMove.luaBeginDrag(screenPos)
		self:dismissSlider()
		self.editor:onStartDragTemplate(screenPos)
	end

	function btnMove.luaDrag(screenPos)
		self.editor:onDraggingTemplate(screenPos)
	end

	function btnMove.luaEndDrag(screenPos)
		self.editor:onFinishDragTemplate(screenPos)
	end

	function btnUpDown.luaBeginDrag(screenPos)
		self:dismissSlider()
		self.editor:onStartDragYAxis(screenPos)
	end

	function btnUpDown.luaDrag(screenPos)
		self.editor:onDraggingYAxis(screenPos)
	end

	function btnUpDown.luaEndDrag(screenPos)
		self.editor:onFinishDraggingYAxis(screenPos)
	end

	btnUpDown:SetActive(self.placeConfig.freeYAxis)
	btnRotate:SetActive(false)
	self.btnRotateCheckUButton:SetActive(true)

	function self.btnRotateCheckUButton.luaClick()
		self.btnRotateCheckUButton.isSelected = not self.btnRotateCheckUButton.isSelected
		self.btnScalingCheckUButton.isSelected = false

		self:refreshItemEditorSlider(self.btnRotateCheckUButton.isSelected, HomelandPlacemenSliderMode.Rotation)
	end

	self.btnScalingCheckUButton:SetActive(not self.placeConfig.disableScale and not self.placeConfig.isGroupPlace)

	function self.btnScalingCheckUButton.luaClick()
		self.btnScalingCheckUButton.isSelected = not self.btnScalingCheckUButton.isSelected
		self.btnRotateCheckUButton.isSelected = false

		self:refreshItemEditorSlider(self.btnScalingCheckUButton.isSelected, HomelandPlacemenSliderMode.Scale)
	end

	function self.btnSplitUButton.luaClick()
		self:onBlueprintBuildGroupSplitBtnClick()
	end

	self:refreshBlueprintBuildGroupSplitButton()
	ClientTextUtils.setText(textRotateUSDFText, pg.getGameString("ROTATE_TEXT"))
	ClientTextUtils.setText(textScalingUSDFTexT, pg.getGameString("MAP_SCROLL"))
	ClientTextUtils.setText(self.textSaveUSDFText, pg.getGameString("HOMELAND_COMPOSE_SPLIT"))
end

function HomelandPlacementCtrl:refreshSliderInfo()
	if self.sliderMode then
		self:refreshItemEditorSlider(true, self.sliderMode)
	end
end

function HomelandPlacementCtrl:getPlaceErrorText(errorType)
	if not errorType or errorType == Const.HomeEditorErrorType.Normal then
		return
	elseif errorType == Const.HomeEditorErrorType.CrossBoundary then
		return pg.getGameString("HOMELAND_EDITOR_CROSSBOUNDARY")
	elseif errorType == Const.HomeEditorErrorType.Overlap then
		return pg.getGameString("HOMELAND_EDITOR_OVERLAP")
	elseif errorType == Const.HomeEditorErrorType.OverCameraHeight then
		return pg.getGameString("HOMELAND_EDITOR_OVERCAMERAHEIGHT")
	elseif errorType == Const.HomeEditorErrorType.OverLoad then
		return pg.getGameString("HOMELAND_EDITOR_OVERLOAD") or "HOMELAND_EDITOR_OVERLOAD"
	end

	return pg.getGameString("HOMELAND_EDITOR_ERRORNONE")
end

function HomelandPlacementCtrl:refreshErrorInfo(editorErrorType)
	if not self.view or not self.view.warningUContainer then
		return
	end

	if not self.view.warningUContainer:CheckURLLoaded() then
		self.view.warningUContainer:LoadDefaultUrlManually(function()
			self:refreshErrorInfo(editorErrorType)
		end)
	elseif editorErrorType ~= self.editorErrorType then
		self.editorErrorType = editorErrorType

		if editorErrorType == Const.HomeEditorErrorType.Normal then
			self.view.warningUContainer.content:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)

			return
		end

		self.view.warningUContainer:SetActive(false)

		local errorText = self:getPlaceErrorText(editorErrorType)

		if errorText then
			self.view.warningUContainer:SetActive(true)
			self.view.warningUContainer.content:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)

			local objectReference = self.view.warningUContainer.content:GetComponent("ObjectReference")
			local txtWarningUSDFText = objectReference:GetRefValue("txtWarningUSDFText")

			ClientTextUtils.setText(txtWarningUSDFText, errorText)
		end
	end
end

function HomelandPlacementCtrl:refreshItemEditorSlider(active, mode)
	if not self.adjustSilderUContainer or IsNil(self.adjustSilderUContainer) then
		return
	end

	self.adjustSilderUContainer:SetActive(active or false)

	if not active then
		self.sliderMode = nil
		self.sliderUSlider = nil
		self.txtValueUSDFText = nil

		self:onNavFocusChange()
		self:refreshEditUIVisibilityForSliderMode()

		return
	end

	self.sliderMode = mode

	self:onNavFocusChange()
	self:refreshEditUIVisibilityForSliderMode()

	if not self.adjustSilderUContainer:CheckURLLoaded() then
		self.adjustSilderUContainer:LoadDefaultUrlManually(function()
			self:refreshItemEditorSlider(active, mode)
		end)
	else
		local objectReference = self.adjustSilderUContainer.content:GetComponent("ObjectReference")
		local btnResetUButton = objectReference:GetRefValue("btnResetUButton")
		local adjustUWidget = objectReference:GetRefValue("adjustUWidget")
		local listAdjustUList = objectReference:GetRefValue("listAdjustUList")
		local closeKeyUButton = objectReference:GetRefValue("closeKeyUButton")
		local btnTipsUSDFText = objectReference:GetRefValue("btnTipsUSDFText")
		local btnLUButton = objectReference:GetRefValue("btnLUButton")
		local btnRUButton = objectReference:GetRefValue("btnRUButton")

		self.sliderUSlider = objectReference:GetRefValue("sliderUSlider")
		self.txtValueUSDFText = objectReference:GetRefValue("txtValueUSDFText")

		ClientTextUtils.setText(btnTipsUSDFText, pg.getGameString("BACK_TO_PRE"))

		function closeKeyUButton.luaClick()
			self:dismissSlider()
		end

		function btnLUButton.luaClick()
			self.sliderUSlider.value = math.clamp(self.sliderUSlider.value - self.sliderUSlider.stepSize, self.sliderUSlider.minValue, self.sliderUSlider.maxValue)
		end

		function btnRUButton.luaClick()
			self.sliderUSlider.value = math.clamp(self.sliderUSlider.value + self.sliderUSlider.stepSize, self.sliderUSlider.minValue, self.sliderUSlider.maxValue)
		end

		if mode == HomelandPlacemenSliderMode.Rotation then
			local rotationIndex = pg.game.home:getHomeEditorPlayerSetting(ClientConst.HomelandEditorSetting.RotationAngle, HomelandConfigData.rotationAngleIndex or 0)
			local rotationSwitch = pg.game.home:getHomeEditorPlayerSetting(ClientConst.HomelandEditorSetting.ThreeAxisRotation, false)
			local homeEditorRotationList = HomelandConfigData.homeEditorRotationList or {
				1,
				15,
				45,
				90
			}
			local rotationStep = homeEditorRotationList[rotationIndex + 1] or 90

			if self.placeConfig.rotationStep then
				rotationStep = self.placeConfig.rotationStep
			end

			local allowThreeAxisRotation = rotationSwitch and self.placeConfig.allowThreeAxisRotation and not self.placeConfig.isGroupPlace

			adjustUWidget:SetActive(allowThreeAxisRotation)

			if allowThreeAxisRotation then
				self.adjustRotationMode = self.adjustRotationMode or ClientConst.HandleAxis.Y

				local adjustList = {}

				table.insert(adjustList, {
					icon = "$UI_Home_Icon_Rotation_X.png",
					adjustMode = ClientConst.HandleAxis.X
				})
				table.insert(adjustList, {
					icon = "$UI_Home_Icon_Rotation_Y.png",
					adjustMode = ClientConst.HandleAxis.Y
				})
				table.insert(adjustList, {
					icon = "$UI_Home_Icon_Rotation_Z.png",
					adjustMode = ClientConst.HandleAxis.Z
				})

				function listAdjustUList.luaRenderItem(button, index, data)
					local objectReference = button:GetComponent("ObjectReference")
					local iconUImage = objectReference:GetRefValue("iconUImage")

					iconUImage.url = data.icon
					button.isSelected = data.adjustMode == self.adjustRotationMode

					function button.luaClick()
						self.adjustRotationMode = data.adjustMode

						self:setSliderRotationInfo()
					end
				end

				listAdjustUList:SetList(adjustList)
			else
				self.adjustRotationMode = ClientConst.HandleAxis.Y
			end

			self.sliderUSlider.minValue = 0
			self.sliderUSlider.maxValue = 360
			self.sliderUSlider.stepSize = rotationStep

			self:setSliderRotationInfo()

			function btnResetUButton.luaClick()
				if self.sliderMode ~= HomelandPlacemenSliderMode.Rotation then
					return
				end

				local baseValue = 0

				if not self.carGroup and self.adjustRotationMode == ClientConst.HandleAxis.Y then
					baseValue = pg.game.home:getAreaOrnamentDefaultYaw(self.areaId)
				end

				local rotation = self:getNewCacheRotation(baseValue)

				self.editor:setRotateOffset(rotation)
				self:refreshEditInfo()
			end

			function self.sliderUSlider.luaValueChanged(newValue)
				if self.sliderMode ~= HomelandPlacemenSliderMode.Rotation then
					return
				end

				local actualValue = newValue

				if not self.carGroup and self.adjustRotationMode == ClientConst.HandleAxis.Y then
					actualValue = Utils.normalizeAngle(newValue + pg.game.home:getAreaOrnamentDefaultYaw(self.areaId))
				end

				local rotation = self:getNewCacheRotation(actualValue)

				self.editor:setRotateOffset(rotation)
				ClientTextUtils.setText(self.txtValueUSDFText, newValue .. "°")
			end
		elseif mode == HomelandPlacemenSliderMode.Scale then
			local scaleSwitch = pg.game.home:getHomeEditorPlayerSetting(ClientConst.HomelandEditorSetting.ThreeAxisScaling, false)
			local forceThreeAxisScale = self:needForceThreeAxis(self.editor:getCachedScale())
			local effectiveThreeAxis = self.placeConfig.allowThreeAxisScale and (forceThreeAxisScale or scaleSwitch)

			self.sliderUSlider.minValue = self.placeConfig.minScale or HomelandConfigData.editorMinScale or 0.5
			self.sliderUSlider.maxValue = self.placeConfig.maxScale or HomelandConfigData.editorMaxScale or 2
			self.sliderUSlider.stepSize = HomelandConfigData.editorScaleStep or 0.1

			adjustUWidget:SetActive(effectiveThreeAxis)

			if effectiveThreeAxis then
				self.adjustScaleMode = self.adjustScaleMode or ClientConst.HandleAxis.X

				local adjustList = {}

				table.insert(adjustList, {
					icon = "$UI_Home_Icon_Move_X.png",
					adjustMode = ClientConst.HandleAxis.X
				})
				table.insert(adjustList, {
					icon = "$UI_Home_Icon_Move_Y.png",
					adjustMode = ClientConst.HandleAxis.Y
				})
				table.insert(adjustList, {
					icon = "$UI_Home_Icon_Move_Z.png",
					adjustMode = ClientConst.HandleAxis.Z
				})

				function listAdjustUList.luaRenderItem(button, index, data)
					local objectReference = button:GetComponent("ObjectReference")
					local iconUImage = objectReference:GetRefValue("iconUImage")

					iconUImage.url = data.icon
					button.isSelected = data.adjustMode == self.adjustScaleMode

					function button.luaClick()
						self.adjustScaleMode = data.adjustMode

						self:setSliderScaleInfo()
					end
				end

				listAdjustUList:SetList(adjustList)
			else
				self.adjustScaleMode = ClientConst.HandleAxis.X
			end

			self:setSliderScaleInfo()

			function btnResetUButton.luaClick()
				if self.sliderMode ~= HomelandPlacemenSliderMode.Scale then
					return
				end

				local scaleXYZ = self:getNewCacheScale(1, effectiveThreeAxis)

				self.editor:setScaleValue(scaleXYZ)
				self:setSliderScaleInfo()
			end

			function self.sliderUSlider.luaValueChanged(newValue)
				if self.sliderMode ~= HomelandPlacemenSliderMode.Scale then
					return
				end

				if newValue ~= self.sliderScaleValue then
					self.sliderScaleValue = newValue

					local scaleXYZ = self:getNewCacheScale(newValue, effectiveThreeAxis)

					self.editor:setScaleValue(scaleXYZ)
					ClientTextUtils.setText(self.txtValueUSDFText, "×" .. string.format("%.1f", newValue))
				end
			end
		end
	end
end

function HomelandPlacementCtrl:needForceThreeAxis(currentScale)
	if not currentScale then
		return false
	end

	return self:needForceThreeAxisXYZ(currentScale.x, currentScale.y, currentScale.z)
end

function HomelandPlacementCtrl:needForceThreeAxisXYZ(scaleX, scaleY, scaleZ)
	local epsilon = 0.001

	return epsilon < math.abs(scaleX - scaleY) or epsilon < math.abs(scaleX - scaleZ) or epsilon < math.abs(scaleY - scaleZ)
end

function HomelandPlacementCtrl:dismissSlider()
	if not IsNil(self.btnRotateCheckUButton) then
		self.btnRotateCheckUButton.isSelected = false
	end

	if not IsNil(self.btnScalingCheckUButton) then
		self.btnScalingCheckUButton.isSelected = false
	end

	self:refreshItemEditorSlider(false)
end

function HomelandPlacementCtrl:getCacheRotationValue()
	local cache = self.editor:getCachedEulerAngles()

	if self.adjustRotationMode == ClientConst.HandleAxis.X then
		return cache.x
	elseif self.adjustRotationMode == ClientConst.HandleAxis.Y then
		return cache.y
	elseif self.adjustRotationMode == ClientConst.HandleAxis.Z then
		return cache.z
	end
end

function HomelandPlacementCtrl:getNewCacheRotation(angle)
	local cache = self.editor:getCachedEulerAngles()
	local rotX = cache.x
	local rotY = cache.y
	local rotZ = cache.z

	if self.adjustRotationMode == ClientConst.HandleAxis.X then
		rotX = angle
	elseif self.adjustRotationMode == ClientConst.HandleAxis.Y then
		rotY = angle
	elseif self.adjustRotationMode == ClientConst.HandleAxis.Z then
		rotZ = angle
	end

	return {
		x = rotX,
		y = rotY,
		z = rotZ
	}
end

function HomelandPlacementCtrl:setSliderRotationInfo()
	if IsNil(self.sliderUSlider) or IsNil(self.txtValueUSDFText) then
		return
	end

	local value = self:getCacheRotationValue(self.adjustRotationMode)

	if not value then
		return
	end

	local displayValue = value

	if not self.carGroup and self.adjustRotationMode == ClientConst.HandleAxis.Y then
		displayValue = Utils.normalizeAngle(value - pg.game.home:getAreaOrnamentDefaultYaw(self.areaId))
	end

	self.sliderUSlider:SetValueWithoutCallback(displayValue)
	ClientTextUtils.setText(self.txtValueUSDFText, displayValue .. "°")
end

function HomelandPlacementCtrl:setSliderScaleInfo(scaleValue)
	if IsNil(self.sliderUSlider) or IsNil(self.txtValueUSDFText) then
		return
	end

	local currentScale = scaleValue or self:getCacheScaleValue()

	if not currentScale then
		return
	end

	self.sliderUSlider:SetValueWithoutCallback(currentScale)
	ClientTextUtils.setText(self.txtValueUSDFText, "×" .. string.format("%.1f", currentScale))

	self.sliderScaleValue = currentScale
end

function HomelandPlacementCtrl:getCacheScaleValue()
	local cache = self.editor:getCachedScale()

	if not cache then
		return nil
	end

	if self.adjustScaleMode == ClientConst.HandleAxis.X then
		return cache.x
	elseif self.adjustScaleMode == ClientConst.HandleAxis.Y then
		return cache.y
	elseif self.adjustScaleMode == ClientConst.HandleAxis.Z then
		return cache.z
	end
end

function HomelandPlacementCtrl:getNewCacheScale(value, threeAxisScale)
	if not threeAxisScale then
		return {
			x = value,
			y = value,
			z = value
		}
	end

	local cache = self.editor:getCachedScale()
	local sx, sy, sz = cache.x, cache.y, cache.z

	if self.adjustScaleMode == ClientConst.HandleAxis.X then
		sx = value
	elseif self.adjustScaleMode == ClientConst.HandleAxis.Y then
		sy = value
	elseif self.adjustScaleMode == ClientConst.HandleAxis.Z then
		sz = value
	end

	return {
		x = sx,
		y = sy,
		z = sz
	}
end

function HomelandPlacementCtrl:refreshEditInfo()
	if self.isPet then
		-- block empty
	else
		local targetEnt = self.editor.templateEntity

		if not IsNil(self.sliderUSlider) then
			if self.sliderMode == 1 then
				self:setSliderRotationInfo()
			elseif self.sliderMode == 2 then
				self:setSliderScaleInfo()
			end
		end
	end

	self:refreshInfoText()
end

function HomelandPlacementCtrl:refreshInfoText()
	if self.isBlueprintPlace then
		self.view.ownedWidget:SetActive(false)

		return
	end

	if self.isPet then
		self.view.ownedWidget:SetActive(false)
	elseif self.editInfo.editType == ClientConst.HomeEditType.PlaceOrnament then
		self.view.ownedWidget:SetActive(true)
		self.view.iconCurrencyUImage:SetActive(false)
		self.view.txtNumUSDFText:SetActive(false)

		local ownNum = ClientUtils.getItemCountById(self.editInfo.homeTemplateId)

		if pg.me:isInSelfHomeland() then
			ownNum = ownNum + ClientUtils.getHomelandItemCountById(self.editInfo.homeTemplateId)
		end

		local pendingPlaceNum = self:getPendingPlaceOrnamentCount()
		local buyNum = math.max(pendingPlaceNum - ownNum, 0)
		local showGetWay = false

		if buyNum > 0 and not self.itemLocked then
			local homeObjectData = HomeObjectData[self.editInfo.homeTemplateId]

			if homeObjectData.getWay == Const.HOMELAND_ORNAMENT_GET_WAY.BUY then
				local buyMoneyType = homeObjectData.buyMoneyType
				local buyMoneyNum = homeObjectData.buyMoneyNum

				if pg.space and pg.space.demoMode == true and Const.HOMELAND_DEMO_SHELL_BUY_ORNAMENT_IDS[self.editInfo.homeTemplateId] then
					buyMoneyType = Const.HOMELAND_DEMO_SHELL_ITEM_ID
					buyMoneyNum = Const.HOMELAND_DEMO_SHELL_BUY_ORNAMENT_PRICE
				end

				buyMoneyNum = buyMoneyNum * buyNum

				local hasNum = ClientUtils.getItemCountById(buyMoneyType)
				local requireText = hasNum < buyMoneyNum and "<style=Debuff>" .. buyMoneyNum .. "</style>" or tostring(buyMoneyNum)

				ClientTextUtils.setText(self.view.ownedText, pg.getGameString("HOMELAND_BUY_COST_NEW"))
				self.view.iconCurrencyUImage:SetActive(true)
				self.view.txtNumUSDFText:SetActive(true)

				local iconType = buyMoneyType == Const.HOMELAND_DEMO_SHELL_ITEM_ID and LuaUIUtils.ITEM_ICON_TYPE.ICON_NORMAL or LuaUIUtils.ITEM_ICON_TYPE.ICON_SMALL

				self.view.iconCurrencyUImage.url = LuaUIUtils.getIconByItemId(buyMoneyType, iconType)

				ClientTextUtils.setText(self.view.txtNumUSDFText, requireText)

				showGetWay = true
			elseif homeObjectData.getWay == Const.HOMELAND_ORNAMENT_GET_WAY.REDEEM then
				local canRedeem = true

				if homeObjectData.buyItemId1 and homeObjectData.buyItemNum1 then
					local ownCount = ClientUtils.getItemCountById(homeObjectData.buyItemId1)

					if pg.me:isInSelfHomeland() then
						ownCount = ownCount + ClientUtils.getHomelandItemCountById(homeObjectData.buyItemId1)
					end

					if ownCount < homeObjectData.buyItemNum1 * buyNum then
						canRedeem = false
					end
				end

				if homeObjectData.buyItemId2 and homeObjectData.buyItemNum2 then
					local ownCount = ClientUtils.getItemCountById(homeObjectData.buyItemId2)

					if pg.me:isInSelfHomeland() then
						ownCount = ownCount + ClientUtils.getHomelandItemCountById(homeObjectData.buyItemId2)
					end

					if ownCount < homeObjectData.buyItemNum2 * buyNum then
						canRedeem = false
					end
				end

				if canRedeem then
					ClientTextUtils.setText(self.view.ownedText, pg.getGameString("HOMELAND_REDEEM"))
				else
					ClientTextUtils.setText(self.view.ownedText, "<style=Debuff>" .. pg.getGameString("APPEARANCE_PAY_FAIL") .. "</style>")
				end

				showGetWay = true
			end
		end

		if not showGetWay then
			ClientTextUtils.setText(self.view.ownedText, pg.getFormatText(pg.getGameString("OWN_INFO_TEXT"), ownNum))
		end
	else
		self.view.ownedWidget:SetActive(false)
	end
end

function HomelandPlacementCtrl:onInputDeviceChanged(deviceType)
	if not self.viewCtrlComponent then
		return
	end

	self.viewCtrlComponent:refreshKeyHints()
	self:refreshHotKeyContents()
	self:refreshEditUIVisibilityForSliderMode()
end

function HomelandPlacementCtrl:initConsoleKeyBind()
	local gamepadMoveBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.view.gameObject, "gamepadMoveViewBinding")

	gamepadMoveBinding.isVirtual = true
	gamepadMoveBinding.actionPath = "Raw/GamepadDPad"

	function gamepadMoveBinding.luaTrigger(inputInfo)
		local deltaVec2 = inputInfo.valueVec2

		self.editor:handleMove(deltaVec2[1], deltaVec2[2])
	end
end

function HomelandPlacementCtrl:shopButtonClick()
	pg.global.ui:open(UIConst.UI_ID_HOMELAND_FURNITURE_STORE, {
		carGroup = self.carGroup
	})
end

function HomelandPlacementCtrl:refreshHotKeyContents()
	return
end

return HomelandPlacementCtrl
