-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandEditor\\HomelandEditorCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("HomelandEditorCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ItemData = require("Data.item_data")
local PetResearchContentData = require("Data.pet_research_content_data")
local Time = require("Core.Common.Time")
local Utils = require("Common.Utils.Utils")
local HomelandItemListComponent = require("Guis.Panels.HomelandEditor.Component.HomelandItemListComponent")
local HomelandViewCtrlComponent = require("Guis.Panels.HomelandEditor.Component.HomelandViewCtrlComponent")
local HomelandEditorTopListComponent = require("Guis.Panels.HomelandEditor.Component.HomelandEditorTopListComponent")
local HomeObjectData = require("Data.home_object_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local MessageName = require("Const.MessageName")
local ClientUtils = require("Utils.ClientUtils")
local ClientConst = require("Const.ClientConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local NoticeDef = require("Common.NoticeDef")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local RevertHomePlaceData = require("Data.revert_home_place_data")
local HomelandConfigData = require("Data.homeland_config_data")
local HomeTypeData = require("Data.home_type_data")
local CallbackHandler = require("Core.Common.CallbackHandler")
local AreaData = require("Data.homeland_area_data")
local ClientHomelandUtils = require("Utils.ClientHomelandUtils")
local HomeBlueprintConst = require("Common.Const.HomeBlueprintConst")
local AudioConst = require("Const.AudioConst")
local AddressDataConst = require("Const.AddressDataConst")
local HomeSeasonUtils = require("Utils.HomeSeasonUtils")
local HomelandEditType = {
	None = 0,
	PlaceOrnament = 1
}
local HomelandEditorCtrl = Class.LightClass("HomelandEditorCtrl", UICtrl)

HomelandEditorCtrl.messages = {
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"onItemChanged",
		true
	},
	[MessageName.HOMELAND_ITEM_MAP_CHANGED] = {
		"onItemChanged",
		true
	},
	[MessageName.HOMELAND_ORNAMENT_CHANGED] = {
		"onOrnamentChanged",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	},
	[MessageName.HOMELAND_STATHOMECAR_ORNAMENT_CHANGED] = {
		"onStatHomeCarOrnamentChanged",
		true
	},
	[MessageName.HOMELAND_STAT_HOMELAND_ORNAMENT_CHANGED] = {
		"onStatHomeLandOrnamentChanged",
		true
	},
	[MessageName.HOMELAND_PETS_CHANGE] = {
		"refreshPetList",
		true
	},
	[MessageName.HOMELAND_EDITOR_SETTING_REFRESH] = {
		"refreshTopList",
		true
	},
	[MessageName.HOMELAND_EDITOR_LOAD_REFRESH] = {
		"refreshLoad",
		true
	},
	[MessageName.HOMELAND_BLUEPRINT_BUILD_RESULT] = {
		"onBlueprintBuild",
		true
	},
	[MessageName.HOMELAND_DRAWING_UNLOCK_CHANGED] = {
		"onDrawingUnlockChanged",
		true
	},
	[MessageName.HOMELAND_WISH_STAR_CHANGED] = {
		"onHomelandWishStarChanged",
		true
	}
}
HomelandEditorCtrl.displayMode = 0
HomelandEditorCtrl.cameraHeight = 1
HomelandEditorCtrl.lastSelectionInfoMap = {}

function HomelandEditorCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	info = info or {}
	self.editor = info.editor or pg.game.home.editor
	self.carGroup = info.carGroup
	self.editType = HomelandEditType.None
	self.areaId = info.areaId
	self.restorePreviewTimerId = nil
	self.deferRestorePreview = false
	self.composeDetailRequestVersion = 0

	self:initEditArea()
	self.view.btnDisplayUButton:TryChangePage("Display", self.displayMode)
	self.view.btnDisplayUButton:SetActive(not self.carGroup and self.areaId == Const.HOMELAND_AREA_TYPE.BUILD)

	self.viewCtrlComponent = HomelandViewCtrlComponent(self, self.view.simpleViewCtrl, {
		joyStick = self.view.moveJoyStick
	})

	self.viewCtrlComponent:setKeyHintInfo("HudHomelandEdit", "HudHomelandEdit")

	self.itemListComponent = HomelandItemListComponent(self, self.view.bottomWidget, {
		carGroup = self.carGroup,
		dragView = self.view.simpleViewCtrl:GetComponent("UComponent")
	})

	local globalEditComponentConfig = {
		editor = self.editor,
		getIsMultiSelectFunc = function()
			return false
		end,
		onMultiSelectFunc = function(switch)
			pg.global.ui.homelandMultiSelect:open({
				editor = self.editor,
				carGroup = self.carGroup,
				areaId = self.areaId
			})
		end
	}

	self.globalEditingComponent = HomelandEditorTopListComponent(self, self.view.globalEditingUWidget, globalEditComponentConfig)

	function self.viewCtrlComponent.onSelectEnt(ent)
		self.itemListComponent.uWidget:TryChangePage("FoldList", 0)
		self:selectEntity(ent)
	end

	self.editor:setEditArea(self.areaId)
	self.editor:setEnableEdit(self.uid, true)
	self.viewCtrlComponent:initCameraHeight()
	ClientTextUtils.setText(self.view.txtDisplayUSDFText, pg.getGameString("HOME_BUILD_WALL_DISPLAY_DESC"))
	ClientTextUtils.setText(self.view.txtMetreUSDFText, pg.getGameString("HOME_BUILD_CAMERA_HEIGHT_DESC"))

	if not self.carGroup and self.areaId == Const.HOMELAND_AREA_TYPE.BUILD then
		self.view.btnDisplayUButton:TryChangePage("Dispaly", self.displayMode)
		self.editor:setDisplayHideMode(self.displayMode)
		self.editor:refreshHeightHide()
	end

	self:refreshEnvSimulateInfo()
	self:refreshDetailWindow()
	self:refreshLoadValue()

	function self.view.btnAreaUButton.luaRenderTooltip(btn, tipPanel)
		local objectReference = tipPanel:GetComponent("ObjectReference")
		local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
		local limitData = ClientHomelandUtils.getHomelandLoadValueLimit(self.areaId, self.carGroup)

		ClientTextUtils.setText(txtNumUSDFText, self.progressText or "0/" .. limitData)

		local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")

		if self.carGroup then
			ClientTextUtils.setText(txtTitleUSDFText, pg.getGameString("HOME_CAMP"))
		elseif AreaData[self.areaId] and AreaData[self.areaId].name then
			ClientTextUtils.setText(txtTitleUSDFText, ClientTextUtils.getLocalizationText(AreaData[self.areaId].name))
		end
	end
end

function HomelandEditorCtrl:getSelectionRecordKey()
	local areaId = self.areaId or 0

	if self.carGroup then
		return "car:" .. tostring(self.carGroup.playerUID) .. ":" .. tostring(self.carGroup.campId) .. ":" .. tostring(self.carGroup.placeId) .. ":" .. tostring(areaId)
	end

	return "homeland:" .. tostring(areaId)
end

function HomelandEditorCtrl:getOrCreateLastSelectionInfo()
	local recordKey = self:getSelectionRecordKey()
	local selectionInfo = HomelandEditorCtrl.lastSelectionInfoMap[recordKey]

	if not selectionInfo then
		selectionInfo = {}
		HomelandEditorCtrl.lastSelectionInfoMap[recordKey] = selectionInfo
	end

	return selectionInfo
end

function HomelandEditorCtrl:getLastSelectionInfo()
	return HomelandEditorCtrl.lastSelectionInfoMap[self:getSelectionRecordKey()]
end

function HomelandEditorCtrl:clearLastItemSelection(itemId)
	local recordKey = self:getSelectionRecordKey()
	local selectionInfo = HomelandEditorCtrl.lastSelectionInfoMap[recordKey]

	if selectionInfo and selectionInfo.itemId == itemId then
		HomelandEditorCtrl.lastSelectionInfoMap[recordKey] = nil
	end
end

function HomelandEditorCtrl:clearLastComposeSelection(sourceType, blueprintId)
	local recordKey = self:getSelectionRecordKey()
	local selectionInfo = HomelandEditorCtrl.lastSelectionInfoMap[recordKey]
	local composeInfo = selectionInfo and selectionInfo.composeInfo
	local isSameCompose = composeInfo and composeInfo.sourceType == sourceType and composeInfo.blueprintId == blueprintId

	if isSameCompose then
		HomelandEditorCtrl.lastSelectionInfoMap[recordKey] = nil
	end
end

function HomelandEditorCtrl:cancelRestorePreviewTimer()
	if not self.restorePreviewTimerId then
		return
	end

	self:killTimer(self.restorePreviewTimerId)

	self.restorePreviewTimerId = nil
end

function HomelandEditorCtrl:invalidateComposeDetailRequest()
	self.composeDetailRequestVersion = self.composeDetailRequestVersion + 1
end

function HomelandEditorCtrl:refreshLoad()
	self:refreshLoadValue()
end

function HomelandEditorCtrl:onBlueprintBuild(response)
	if response and response.flag == true then
		pg.game.audio:triggerEvent(AudioConst.EVENT_HOME_ARCHITECTURE_PLACE)
	end
end

function HomelandEditorCtrl:refreshLoadProgressValue(data)
	self.view.progressUProgress.minValue = 0
	self.view.progressUProgress.maxValue = 1

	local progress = math.clamp(data, 0, 1)

	self.view.progressUProgress.value = progress
end

function HomelandEditorCtrl:refreshLoadProgressColor(data)
	if data <= 0.6 then
		self.view.btnAreaUButton:TryChangePage("Load", 0)
	elseif data <= 0.9 then
		self.view.btnAreaUButton:TryChangePage("Load", 1)
	else
		self.view.btnAreaUButton:TryChangePage("Load", 2)
	end
end

function HomelandEditorCtrl:refreshLoadType()
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

function HomelandEditorCtrl:refreshLoadValue()
	local limitData = ClientHomelandUtils.getHomelandLoadValueLimit(self.areaId, self.carGroup)
	local progress = 0

	if self.carGroup then
		local campCarEnt = self.carGroup.campCarEnt

		if campCarEnt then
			local campCarLoadValue = campCarEnt.CampCarLoadValue or 0

			progress = campCarLoadValue / limitData
			self.progressText = campCarLoadValue .. "/" .. limitData
		end
	elseif pg.space.homeAreaStats and pg.space.homeAreaStats[self.areaId] then
		local loadValue = pg.space.homeAreaStats[self.areaId].loadValue

		progress = loadValue / limitData
		self.progressText = loadValue .. "/" .. limitData
	end

	self:refreshLoadProgressColor(progress)
	self:refreshLoadProgressValue(progress)
	self:refreshLoadType()
end

function HomelandEditorCtrl:onOpen(info)
	info = info or {}

	local areaId = info.areaId

	if areaId == nil and not self.carGroup then
		areaId = pg.game.home:getNearestAreaId(pg.me:getPosition(), true)
	end

	if areaId ~= nil and areaId ~= self.areaId then
		self.areaId = areaId

		self.editor:setEditArea(self.areaId)
		self:refreshTopWidgetVisibility()
		self.itemListComponent:updateHomeListData()
		self:refreshLoadValue()
	end

	local openType = info.type
	local openSubType = info.subType

	if openType then
		self.itemListComponent:setSelectTypeSubType(openType, openSubType)
	end
end

function HomelandEditorCtrl:onPostOpen(info, isReOpen)
	HomelandEditorCtrl.super.onPostOpen(self, info, isReOpen)

	if self.carGroup and pg.game.homeCar then
		pg.game.homeCar:startHomeCampSnapshotSchedule(self.carGroup)
	end

	self:cancelRestorePreviewTimer()
	self:invalidateComposeDetailRequest()

	info = info or {}

	if info.type then
		return
	end

	local selectionInfo = self:getLastSelectionInfo()

	if not selectionInfo then
		return
	end

	local composeInfo = selectionInfo.composeInfo

	if composeInfo then
		self.itemListComponent:locateCompose(composeInfo.sourceType, composeInfo.blueprintId)
	elseif selectionInfo.itemId then
		local itemId = selectionInfo.itemId

		self.deferRestorePreview = true

		local located = self.itemListComponent:locateItem(itemId)

		self.deferRestorePreview = false

		if located then
			self:refreshRestoreItemPreviewAfterCameraTransition(itemId)
		else
			self:clearLastItemSelection(itemId)
		end
	end
end

function HomelandEditorCtrl:refreshRestoreItemPreviewAfterCameraTransition(itemId)
	self:cancelRestorePreviewTimer()

	local blendTime = self.editor.rootCameraMode.cameraMode.blendTime

	self.restorePreviewTimerId = self:startTimer(function()
		self.restorePreviewTimerId = nil

		local selectionUnchanged = self._isOpen and self._curVisible and self.curItemId == itemId and self.curComposeData == nil

		if not selectionUnchanged then
			return
		end

		self.curPreviewId = nil

		self:refreshPreviewPrefab()
	end, blendTime)
end

function HomelandEditorCtrl:checkUILockCursor()
	if pg.game.input:isUsingGamepad() then
		return self.itemListComponent and self.itemListComponent.isExpand
	end

	return HomelandEditorCtrl.super.checkUILockCursor(self)
end

function HomelandEditorCtrl:checkUIShowVirtualMouseCursor()
	if pg.game.input:isUsingGamepad() then
		return not self.itemListComponent or not self.itemListComponent.isExpand
	end

	return false
end

function HomelandEditorCtrl:onDestroy()
	if self.carGroup and pg.game.homeCar then
		pg.game.homeCar:stopHomeCampSnapshotSchedule(self.carGroup)
	end

	self:cancelRestorePreviewTimer()
	self:invalidateComposeDetailRequest()

	self.deferRestorePreview = false
	self.homeCoinItemTable = {}
	self.btnFavoriteUButton = nil
	self.progressPressContainerUContainer = nil
	self.curItemId = nil
	self.curComposeData = nil
	self.curPreviewComposeData = nil
	self.petId = nil
	self.itemListComponent = nil
	self.viewCtrlComponent = nil
	self.progressText = nil

	if self.editor then
		self.cameraHeight = self.editor.cameraHeightLimit

		if not self.carGroup and self.areaId == Const.HOMELAND_AREA_TYPE.BUILD then
			self.displayMode = self.editor.displayHideMode
		end

		self.editor:destroyPreviewObject()
		self.editor:setDisplayHideMode(0)
		self.editor:refreshHeightHide()
		self.editor:setEnableEdit(self.uid, false)
	end

	UICtrl.onDestroy(self)
end

function HomelandEditorCtrl:addListener()
	function self.view.btnBack.luaClick()
		self:close()
	end

	function self.view.placeBtn.luaClick()
		local valid = self:onPlaceBtnClick()

		if valid then
			-- block empty
		end
	end

	function self.view.getBtn.luaClick()
		self:onGetBtnClick()
	end

	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = 0
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.KeyBoardCancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:close()
		end
	end

	local placeBind = self.view.placeBtn:GetComponent("KeyBindingPro")

	placeBind.actionPath = "Hud/HomelandPlace"

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

	local objectReference = self.view.itemInfo:GetComponent("ObjectReference")

	self.btnFavoriteUButton = objectReference:GetRefValue("btnFavoriteUButton")

	function self.btnFavoriteUButton.luaClick()
		self:onFavoriteButtonClick()
	end

	if self.view.btnInfoUButton then
		self.view.btnInfoUButton:SetActive(true)

		function self.view.btnInfoUButton.luaClick()
			self:onInfoButtonClick()
		end
	end

	function self.view.btnDisplayUButton.luaClick()
		self.displayMode = (self.displayMode + 1) % 3

		self.view.btnDisplayUButton:TryChangePage("Dispaly", self.displayMode)
		self.editor:setDisplayHideMode(self.displayMode)
		self.editor:setCameraHeightLimit(self.cameraHeight)
		self.editor:refreshHeightHide()

		if self.displayMode == 0 then
			pg.global.ui.tips:showTextTip(pg.getGameString("HOMELAND_EDITOR_FULL_DISPLAY"))
		elseif self.displayMode == 1 then
			pg.global.ui.tips:showTextTip(pg.getGameString("HOMELAND_EDITOR_SEMI_HIDDEN"))
		elseif self.displayMode == 2 then
			pg.global.ui.tips:showTextTip(pg.getGameString("HOMELAND_EDITOR_FULL_HIDDEN"))
		end
	end

	self:initConsoleKeys()
	self:addNavFocusListener(CallbackHandler(self, "onNavFocusChange"))
end

function HomelandEditorCtrl:initEditArea()
	if not self.areaId then
		if not self.carGroup then
			self.areaId = pg.game.home:getNearestAreaId(pg.me:getPosition(), true)
		else
			self.areaId = 0
		end
	end
end

function HomelandEditorCtrl:onQuitBtnClick()
	self:close()
end

function HomelandEditorCtrl:getWhiteList()
	local whiteList = {}

	whiteList[UIConst.UI_ID_HOMELAND_EDITOR_TOPLOGO] = true

	return whiteList
end

function HomelandEditorCtrl:onSelectItem(itemId, keepComposeRequest)
	self:cancelRestorePreviewTimer()

	if not keepComposeRequest then
		self:invalidateComposeDetailRequest()
	end

	if itemId then
		local selectionInfo = self:getOrCreateLastSelectionInfo()

		selectionInfo.itemId = itemId
		selectionInfo.composeInfo = nil
		self.curComposeData = nil

		if self.view and self.view.furnitureComposeUContainer then
			self.view.furnitureComposeUContainer:SetActive(false)
		end
	end

	self.curItemId = itemId

	self:refreshDetailWindow()
end

function HomelandEditorCtrl:selectItem(itemId)
	self.itemListComponent:selectItem(itemId, false)
end

function HomelandEditorCtrl:selectEntity(selectEnt)
	self:selectItem(nil)

	if self.curComposeData then
		self:closeComposeDetail()
	end

	if selectEnt then
		if Utils.isHomePet(selectEnt) then
			local petInfo = pg.space.pets[selectEnt.id]

			if petInfo then
				if Utils.checkHomePetStateValid(petInfo, pg.space) then
					pg.global.ui.homelandPlacement:open({
						editType = ClientConst.HomeEditType.UpdatePet,
						entity = selectEnt,
						petId = selectEnt.id,
						editor = self.editor,
						areaId = self.areaId,
						carGroup = self.carGroup
					})
				else
					pg.global.showBubbleMessage(NoticeDef.HOMELAND_PET_IN_REST)
				end
			end
		elseif selectEnt.canEntEdit and selectEnt:canEntEdit() then
			logger:info("xzt selectEntity 8888888", selectEnt.areaId, self.areaId)

			if not self.areaId or selectEnt.areaId == self.areaId then
				local homeSpace = pg.me and pg.me.space

				if self.carGroup then
					homeSpace = self.carGroup.campCarEnt
				end

				local blueprintBuildGroupOrnamentId

				if homeSpace and homeSpace.getHomeBlueprintBuildGroupByOrnamentId then
					local groupIndex = homeSpace:getHomeBlueprintBuildGroupByOrnamentId(selectEnt.ornamentId)

					if groupIndex then
						blueprintBuildGroupOrnamentId = selectEnt.ornamentId
					end
				end

				local editEntities = ClientHomelandUtils.collectOrnamentEditGroupEntities({
					selectEnt
				}, {
					editor = self.editor,
					areaId = self.areaId,
					homeSpace = homeSpace,
					getEntity = function(ornamentId)
						return self:getOrnamentEnt(ornamentId)
					end
				})

				pg.game.audio:triggerEvent(AudioConst.EVENT_HOME_ARCHITECTURE_SELECT)

				if #editEntities > 1 then
					pg.global.ui.homelandPlacement:open({
						editType = ClientConst.HomeEditType.UpdateOrnament,
						entities = editEntities,
						editor = self.editor,
						areaId = self.areaId,
						carGroup = self.carGroup,
						blueprintBuildGroupOrnamentId = blueprintBuildGroupOrnamentId
					})
				else
					pg.global.ui.homelandPlacement:open({
						editType = ClientConst.HomeEditType.UpdateOrnament,
						entity = selectEnt,
						editor = self.editor,
						areaId = self.areaId,
						carGroup = self.carGroup,
						blueprintBuildGroupOrnamentId = blueprintBuildGroupOrnamentId
					})
				end
			end
		end
	end
end

function HomelandEditorCtrl:getOrnamentEnt(ornamentId)
	if self.carGroup then
		return self.carGroup:getHomeEntity(ornamentId)
	end

	return pg.game.home:getHomeEntity(ornamentId)
end

function HomelandEditorCtrl:onVisibleChange(visible)
	if visible then
		self:refreshDisplayMode()
		self.viewCtrlComponent:refreshCameraHeight()
	end

	self:refreshPreviewPrefab()
	self:updateCurrencyData()
	self:refreshLoadValue()
end

function HomelandEditorCtrl:refreshDisplayMode()
	if not self.carGroup and self.areaId == Const.HOMELAND_AREA_TYPE.BUILD then
		self.displayMode = self.editor.displayHideMode

		self.view.btnDisplayUButton:TryChangePage("Dispaly", self.displayMode)
	end
end

function HomelandEditorCtrl:checkVirtualMouseHoverSnapEnabled()
	local isItemListExpand = self.itemListComponent and self.itemListComponent.isExpand

	return not isItemListExpand
end

function HomelandEditorCtrl:updateCurrencyData()
	self.view.listCurrencyUList:RefreshList()
end

function HomelandEditorCtrl:showItemCost(buyMoneyType, costNum)
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

function HomelandEditorCtrl:showItemCostAnim(container, buyMoneyType, costNum)
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

function HomelandEditorCtrl:refreshPreviewPrefab()
	if self.deferRestorePreview then
		return
	end

	local targetItemId = self.curItemId
	local targetComposeData = self.curComposeData
	local screenPos

	if self.itemListComponent and self.itemListComponent.curDragItemId then
		targetItemId = self.itemListComponent.curDragItemId
		targetComposeData = nil
		screenPos = self.itemListComponent.curDragItemPos
	end

	if not self._curVisible then
		targetItemId = nil
		targetComposeData = nil
	end

	if self.curPreviewId ~= targetItemId or self.curPreviewComposeData ~= targetComposeData then
		self.curPreviewId = targetItemId
		self.curPreviewComposeData = targetComposeData

		if targetItemId then
			self.editor:createPreviewObject(targetItemId)
		elseif targetComposeData then
			self.editor:createBlueprintPreviewObject(targetComposeData)
		else
			self.editor:destroyPreviewObject()
		end
	elseif screenPos then
		self.editor:updatePreviewObjectPosition(screenPos)
	end
end

function HomelandEditorCtrl:refreshPetDetailWindow(data)
	local requestPetId = data.id

	self.petId = requestPetId

	if not self.view.petInfoUContainer:CheckURLLoaded() then
		self.view.petInfoUContainer:LoadDefaultUrlManually(function()
			self.view:registerPetDetail(self.view.petInfoUContainer.content)
			self:onPetDetailLoad()

			if self.petId == requestPetId and self:isPetInCurrentEditArea(requestPetId) then
				self:showPetDetail(data)
			end
		end)
	elseif self:isPetInCurrentEditArea(requestPetId) then
		self:showPetDetail(data)
	else
		self:closePetDetail()
	end
end

function HomelandEditorCtrl:refreshComposeDetailWindow(data)
	self.composeDetailRequestVersion = self.composeDetailRequestVersion + 1

	local requestVersion = self.composeDetailRequestVersion

	if not self.view.furnitureComposeUContainer:CheckURLLoaded() then
		self.view.furnitureComposeUContainer:LoadDefaultUrlManually(function()
			self.view:registerComposeDetail(self.view.furnitureComposeUContainer.content)

			if requestVersion == self.composeDetailRequestVersion and self._isOpen then
				self:showComposeDetail(data)
			end
		end)
	else
		self:showComposeDetail(data)
	end
end

function HomelandEditorCtrl:refreshPetList()
	if self.itemListComponent then
		self.itemListComponent:refreshPetList()
	end
end

function HomelandEditorCtrl:onHomelandWishStarChanged()
	if not self.petId or not self.view or not self.view.petInfoUContainer or not self.view.petInfoUContainer:CheckURLLoaded() or not self.view.petInfoContent or not self:isPetInCurrentEditArea(self.petId) then
		return
	end

	local petInfo = pg.space and pg.space.pets and pg.space.pets[self.petId]

	if petInfo then
		LuaUIUtils.refreshHomeWishingStarOutput(self.view.petInfoContent:GetComponent("ObjectReference"), petInfo)
	end
end

function HomelandEditorCtrl:isPetInCurrentEditArea(petId)
	local space = pg.space

	if not space or not space.pets[petId] then
		return false
	end

	local areaId = space.petBoxMap and space.petBoxMap:getPetIndex(petId)

	if areaId == nil then
		areaId = HomeLandUtils.getHomePetAreaId(space, petId)
	end

	return areaId == self:getEditAreaId()
end

function HomelandEditorCtrl:refreshTopList(data)
	if self.globalEditingComponent then
		self.globalEditingComponent:refreshTopList()
	end
end

function HomelandEditorCtrl:onPetDetailLoad()
	function self.view.accessListUList.luaRenderItem(button, _, d)
		LuaUIUtils.renderRenderAccess(button, d)
	end

	function self.view.abilityListUList.luaRenderItem(button, _, itemData)
		LuaUIUtils.renderHomeAbility(button, itemData.id, itemData.level)
	end

	function self.view.btnPositionUButton.luaClick()
		self:posToCurPet()
	end

	function self.view.btnEditUButton.luaClick()
		local ent = pg.getEntity(self.petId)

		if ent then
			self:selectEntity(ent)
		end
	end
end

function HomelandEditorCtrl:posToCurPet()
	if not self.petId then
		return
	end

	local petInfo = pg.space.pets[self.petId]

	if petInfo and not Utils.checkHomePetStateValid(petInfo, pg.space) then
		pg.global.showBubbleMessage(NoticeDef.HOMELAND_PET_IN_REST)

		return
	end

	local selectEnt = pg.getEntity(self.petId)

	if selectEnt then
		self.editor:moveCameraToEditEntity(selectEnt)
	end
end

function HomelandEditorCtrl:closePetDetail()
	self.view.petInfoUContainer:SetActive(false)

	self.petId = nil
end

function HomelandEditorCtrl:closeItemDetail()
	self.view.itemInfo:SetActive(false)
end

function HomelandEditorCtrl:closeComposeDetail()
	self:invalidateComposeDetailRequest()
	self.view.furnitureComposeUContainer:SetActive(false)

	self.curComposeData = nil

	self:refreshPreviewPrefab()
end

function HomelandEditorCtrl:showComposeDetail(data)
	if not data then
		return
	end

	self.curComposeData = data

	if data.sourceType and data._id then
		local selectionInfo = self:getOrCreateLastSelectionInfo()

		selectionInfo.itemId = nil
		selectionInfo.composeInfo = {
			sourceType = data.sourceType,
			blueprintId = tostring(data._id)
		}
	end

	if self.itemListComponent then
		self.itemListComponent:selectItem(nil, true, true)
	else
		self.curItemId = nil

		self:refreshPreviewPrefab()
	end

	self.view.furnitureComposeUContainer:SetActive(true)

	local nameText = data.name or ""
	local descText = data.desc or ""

	if data.sourceType == UIConst.HOME_DESIGN_MODE.SYSTEMDESIGN then
		nameText = pg.getLocalizationText(nameText)
		descText = pg.getLocalizationText(descText)
	end

	ClientTextUtils.setText(self.view.txtNameUSDFText, nameText or "")
	ClientTextUtils.setText(self.view.txtTypeUSDFText, pg.getGameString("HOMELAND_COMPOSE_PLACE_TYPE"))

	local areaId = data.areaId or 0
	local areaData = AreaData[areaId] or {}

	ClientTextUtils.setText(self.view.txtDetailsUSDFText, ClientTextUtils.getLocalizationText(areaData.name))
	self.view.txtDetailsUSDFText:SetActive(false)
	self.view.txtTypeUSDFText:SetActive(false)
	ClientTextUtils.setText(self.view.txtBtnSetUSDFText, pg.getGameString("HOME_PET_PLACE"))
	ClientTextUtils.setText(self.view.txtLivabilityValueUSDFText, data.comfortValue or 0)
	ClientTextUtils.setText(self.view.txtLoadValueUSDFText, data.loadValue or 0)
	ClientTextUtils.setText(self.view.txtTiteSizeUSDFText, pg.getGameString("HOMELAND_COMPOSE_SIZE"))

	local rangeSize = data.size

	if not rangeSize or #rangeSize == 0 then
		rangeSize = {
			0,
			0,
			0
		}
	end

	ClientTextUtils.setText(self.view.txtSizeNumUSDFText, rangeSize[1] .. "×" .. rangeSize[2] .. "×" .. rangeSize[3])
	ClientTextUtils.setText(self.view.txtDescUSDFText, descText)

	self.view.iconComposeUImage.url = AddressDataConst.UI_HOME_COMPOSE_ICON

	function self.view.btnViewUButton.luaClick()
		local homeIdList = {}

		for _, info in ipairs(data.ornaments or EMPTY_TABLE) do
			if info.homeId then
				table.insert(homeIdList, info.homeId)
			end
		end

		pg.global.ui.homelandFurnitureComposeDetail:open({
			designIndex = data.sourceType,
			composeIndex = UIConst.HOME_COMPOSE_MODE.COMBINATION,
			carGroup = self.carGroup,
			detailData = {
				homeIdList = homeIdList,
				rangeSize = rangeSize,
				loadValue = data.loadValue,
				comfortValue = data.comfortValue,
				code = data._id or "",
				name = nameText,
				description = descText,
				ownerName = data.ownerName,
				coverImageKeys = data.coverImageKeys,
				image = data.image
			}
		})
	end

	function self.view.btnPlaceUButton.luaClick()
		self:placeComposeBlueprint(data)
	end
end

function HomelandEditorCtrl:placeComposeBlueprint(data)
	if self.itemListComponent and not self.itemListComponent:isComposeAreaAllowed(data) then
		pg.global.showBubbleMessageRaw(pg.getGameString("HOMELAND_COMPOSE_AREA_NOT_MATCH"))

		return false
	end

	local ornaments = data and data.ornaments

	if type(ornaments) ~= "table" or #ornaments <= 0 then
		pg.me:showBlueprintNotice(Const.HOME_BLUEPRINT_OP_RETURN_CODE.ERROR_PARAM)

		return false
	end

	for _, ornamentInfo in ipairs(ornaments) do
		local homeId = ornamentInfo and ornamentInfo.homeId

		if not homeId or not HomeObjectData[homeId] then
			pg.me:showBlueprintNotice(Const.HOME_BLUEPRINT_OP_RETURN_CODE.ERROR_PARAM)

			return false
		end
	end

	if not self.itemListComponent or self.itemListComponent:getComposePlaceCount(data) <= 0 then
		pg.global.showBubbleMessageRaw(pg.getGameString("HOMELAND_COMPOSE_FURNITURE_NOT_ENOUGH"))

		return false
	end

	local sourceType = data.sourceType

	if sourceType ~= HomeBlueprintConst.SOURCE_TYPE.UPLOADED and sourceType ~= HomeBlueprintConst.SOURCE_TYPE.SYSTEM and sourceType ~= HomeBlueprintConst.SOURCE_TYPE.SAVED_OTHER then
		pg.me:showBlueprintNotice(Const.HOME_BLUEPRINT_OP_RETURN_CODE.ERROR_PARAM)

		return false
	end

	local blueprintId = data._id

	if blueprintId == nil or tostring(blueprintId) == "" then
		pg.me:showBlueprintNotice(Const.HOME_BLUEPRINT_OP_RETURN_CODE.ERROR_PARAM)

		return false
	end

	local initPosition, initRotation

	if self.editor.previewEntity then
		initPosition = self.editor.previewEntity:getPosition():Clone()
		initRotation = self.editor.previewEntity:getRotation():Clone()
	end

	self:closeComposeDetail()
	pg.global.ui.homelandPlacement:open({
		isBlueprintPlace = true,
		editType = ClientConst.HomeEditType.PlaceOrnament,
		blueprintData = data,
		sourceType = sourceType,
		blueprintId = tostring(blueprintId),
		initPosition = initPosition,
		initRotation = initRotation,
		editor = self.editor,
		areaId = self.areaId,
		carGroup = self.carGroup
	})

	return true
end

function HomelandEditorCtrl:showPetDetail(data)
	self.petId = data.id

	local petId = self.petId
	local petInfo = pg.me.space.pets[petId]
	local templateId = petInfo.templateId

	function self.view.btnLiveUButton.luaRenderTooltip(btn, com)
		local objectReference = com.transform:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("HOMELAND_COMFORT_TIP"))
	end

	ClientTextUtils.setText(self.view.txtTitleLiveUSDFText, pg.getGameString("HOMELAND_COMPOSE_LIVE_VALUE") .. ":")
	ClientTextUtils.setText(self.view.txtNumLiveUSDFText, ClientHomelandUtils.getPetComfortValueById(data.id))
	LuaUIUtils.bindHomeWishingStarOutput(self.view.petInfoContent:GetComponent("ObjectReference"), data)
	ClientTextUtils.setText(self.view.txtDetailUSDFText, PetResearchContentData[data.templateId] ~= nil and pg.getLocalizationText(PetResearchContentData[data.templateId].desc) or "EMPTY")
	ClientTextUtils.setText(self.view.beenText, pg.getFormatText(pg.getGameString("BEEN_WITH"), math.round((Time.secondCache * 1000 - data.time) / 1000 / 3600 / 24)))

	local displayBookNumberText = "No.???"

	if data.bookNum and data.bookNum < 9000 then
		local displayNumber, isCustomNumber = PetResearchUtils.getDisplayNumberByTemplateId(data.templateId)

		displayNumber = displayNumber ~= "" and displayNumber or data.bookNum
		displayBookNumberText = isCustomNumber and displayNumber or string.format("No.%s", displayNumber)
	end

	ClientTextUtils.setText(self.view.textNO, displayBookNumberText)
	LuaUIUtils.setTalentBtn(self.view.btnTalentUButton, data.breedTalent)

	local formName = LuaUIUtils.getPetFormName(templateId)

	ClientTextUtils.setText(self.view.infoPetName, formName)

	local label = data.label
	local isBoss = Utils.isLabelElite(label)
	local isShiny = Utils.isLabelShiny(label)
	local isVariant = Utils.isLabelVariant(label)

	if isShiny then
		self.view.petInfoContent:TryChangePage("isFlash", 1)
	else
		self.view.petInfoContent:TryChangePage("isFlash", 0)
	end

	self.view.petInfoContent:TryChangePage("isBoss", isBoss and 1 or 0)
	self.view.petInfoContent:TryChangePage("isChange", isVariant and 1 or 0)
	self.view.accessListUList:SetList(data.breedTalent)
	self.view.abilityListUList:SetList(LuaUIUtils.getHomeAbilityData(templateId))
	self.view.petInfoUContainer:SetActive(true)

	if data.gender == Const.GENDER_TYPE_MALE then
		self.view.petInfoContent:TryChangePage("Gender", 0)
	elseif data.gender == Const.GENDER_TYPE_FEMALE then
		self.view.petInfoContent:TryChangePage("Gender", 1)
	else
		self.view.petInfoContent:TryChangePage("Gender", 2)
	end

	if data.customName and data.customName ~= "" then
		ClientTextUtils.setText(self.view.infoPetNameExtra, data.customName)

		if isVariant then
			ClientTextUtils.setText(self.view.nameShineUSDFText, data.customName)
			ClientTextUtils.setText(self.view.nameShineUSDFText1, data.customName)
		end
	else
		local nameTxt = pg.getLocalizationText(data.name)

		ClientTextUtils.setText(self.view.infoPetNameExtra, nameTxt)
		ClientTextUtils.setText(self.view.nameShineUSDFText, nameTxt)
		ClientTextUtils.setText(self.view.nameShineUSDFText1, nameTxt)
	end
end

function HomelandEditorCtrl:getFavList()
	if self.carGroup then
		return pg.me.favoriteCarOrnamentList
	end

	return pg.me.favoriteOrnamentList
end

function HomelandEditorCtrl:refreshDetailWindow()
	local templateId = self.curItemId

	self:refreshPreviewPrefab()

	if not templateId then
		self.view.itemInfo:SetActive(false)
		self.view.listCurrencyUList:SetActive(true)

		return
	end

	local itemData = ItemData[templateId] or {}

	self.view.itemInfo:SetActive(true)
	self.view.listCurrencyUList:SetActive(false)
	self.view.itemInfo:TryChangePage("Quality", itemData.quality)

	local objectReference = self.view.itemInfo:GetComponent("ObjectReference")
	local txtName = objectReference:GetRefValue("txtName")
	local icon = objectReference:GetRefValue("icon")
	local placeType = objectReference:GetRefValue("placeType")
	local artTitle = objectReference:GetRefValue("artTitle")
	local artNum = objectReference:GetRefValue("artNum")
	local descScroll = objectReference:GetRefValue("descScroll")
	local txtSpaceTipsUSDFText = objectReference:GetRefValue("txtSpaceTipsUSDFText")
	local textSpaceUSDFText = objectReference:GetRefValue("textSpaceUSDFText")
	local objectInfo = HomeObjectData[templateId] or {}

	self.isFavorite = false

	local favList = self:getFavList()

	if favList then
		for _, favItemId in pairs(favList) do
			if favItemId == self.curItemId then
				self.isFavorite = true

				break
			end
		end
	end

	local homeTypeData = HomeTypeData[objectInfo.type]

	if homeTypeData.disableFav then
		self.btnFavoriteUButton:SetActive(false)
	else
		self.btnFavoriteUButton:SetActive(true)
	end

	self.btnFavoriteUButton:TryChangePage("enable", self.isFavorite and 1 or 0)
	ClientTextUtils.setText(txtSpaceTipsUSDFText, pg.getGameString("HOME_PET_PLACE"))
	artTitle:SetActive(false)
	artNum:SetActive(false)
	ClientTextUtils.setText(txtName, pg.getLocalizationText(objectInfo.name))

	icon.url = LuaUIUtils.getIconByItemId(templateId)

	ClientTextUtils.setText(placeType, self:getPlaceTypeText(objectInfo.landType))

	local descRef = descScroll.content:GetComponent("ObjectReference")
	local numBox = descRef:GetRefValue("numBox")
	local numBox2 = descRef:GetRefValue("numBox2")
	local desc1 = descRef:GetRefValue("desc1")
	local desc2 = descRef:GetRefValue("desc2")
	local detailUComponent = descRef:GetRefValue("detailUComponent")
	local drawingSourceTree = descRef:GetRefValue("drawingSourceTree")
	local titleUSDFText = descRef:GetRefValue("titleUSDFText")
	local btnArrowUButton = descScroll.content:Find("Gain/Title/BtnArrow"):GetComponent("UButton")

	ClientTextUtils.setText(titleUSDFText, pg.getGameString("HOME_BOOK_GET_METHOD"))
	numBox:SetActive(false)
	numBox2:SetActive(false)
	ClientTextUtils.setText(desc2, pg.getLocalizationText(objectInfo.desc or ""))

	local unlockState = ClientHomelandUtils.getFurnitureUnlockState(templateId, false)

	desc1:SetActive(unlockState.isLocked)
	ClientTextUtils.setText(desc1, pg.getFormatText("<style=Debuff>{0}</style>", unlockState.lockText))

	local drawingSourceList = {}

	if unlockState.lockType == ClientHomelandUtils.HomelandUnlockType.Drawing then
		drawingSourceList = ClientHomelandUtils.getDrawingSourceList(unlockState.unlockItemId)

		ClientTextUtils.setText(titleUSDFText, ClientHomelandUtils.getDrawingSourceTitle(true))
	end

	detailUComponent:TryChangePage("OpenGetWay", #drawingSourceList > 0 and 1 or 0)
	self:renderSourceTree(drawingSourceTree, btnArrowUButton, drawingSourceList)

	local maxNum = self:getOrnamentMaxPlaceNum(templateId)
	local numValid = true

	if maxNum then
		numBox:SetActive(true)

		local numTitle = numBox:Find("Text"):GetComponent("USDFText")
		local numText = numBox:Find("Num"):GetComponent("USDFText")

		ClientTextUtils.setText(numTitle, pg.getGameString("HOMELAND_MAX_PLACE_NUM"))

		local placeItemCount = self:getOrnamentCurPlaceNum(templateId)
		local numInfo = placeItemCount .. "/" .. maxNum

		if maxNum <= placeItemCount then
			numValid = false
			numInfo = pg.getFormatText("<style=Debuff>{0}</style>", placeItemCount) .. "/" .. maxNum
		end

		ClientTextUtils.setText(numText, numInfo)
	end

	if numValid then
		local itemCount = ClientUtils.getItemCountById(templateId)

		if pg.me:isInSelfHomeland() then
			itemCount = itemCount + ClientUtils.getHomelandItemCountById(templateId)
		end

		numValid = itemCount > 0
	end

	local costItemId = objectInfo.buyMoneyType
	local costItemNum = objectInfo.buyMoneyNum

	if not costItemId or not costItemNum then
		self.view.getBtn.interactable = false
	else
		self.view.getBtn.interactable = true
	end

	local load = ClientHomelandUtils.getLoadValueById(templateId)
	local comfort = ClientHomelandUtils.getComfortValueById(templateId)

	self.txtLoadValueUSDFText = descRef:GetRefValue("txtLoadValueUSDFText")
	self.txtLivabilityValueUSDFText = descRef:GetRefValue("txtLivabilityValueUSDFText")

	ClientTextUtils.setText(self.txtLoadValueUSDFText, load)
	ClientTextUtils.setText(self.txtLivabilityValueUSDFText, comfort)
end

function HomelandEditorCtrl:renderSourceTree(drawingSourceTree, btnArrowUButton, drawingSourceList)
	function drawingSourceTree.luaRenderItem(button, index, data)
		local nameUBaseText = button:Find("Widget/TxtName"):GetComponent("UBaseText")

		ClientTextUtils.setText(nameUBaseText, pg.getLocalizationText(data.buttonTxt))
		LuaUIUtils.itemSourceTrigger(button, data, nil, data.clueSeekID)
	end

	local isSourceExpanded = false

	local function setSourceExpanded(expanded)
		isSourceExpanded = expanded

		drawingSourceTree:SetActive(expanded)
	end

	function btnArrowUButton.luaClick()
		if pg.game.input:isUsingGamepad() then
			local navMgr = CS.XGUI.Navigation.NavManager.Instance

			if navMgr then
				local isFocusIn = navMgr:IsFocusInNavGroupOf(drawingSourceTree)

				if isFocusIn then
					setSourceExpanded(false)
				else
					setSourceExpanded(true)
					navMgr:PushFocusNavGroupOf(drawingSourceTree)
				end
			end
		else
			setSourceExpanded(not isSourceExpanded)
		end
	end

	local hasSource = #drawingSourceList > 0

	if not hasSource then
		setSourceExpanded(false)
	end

	drawingSourceTree:SetList(drawingSourceList)
	setSourceExpanded(false)
end

function HomelandEditorCtrl:getPlaceTypeText(landType)
	landType = landType or 1

	return pg.getLocalizationText(pg.getGameString("HOMELAND_LAND_TYPE_" .. landType))
end

function HomelandEditorCtrl:getEditAreaId()
	return self.areaId or 0
end

function HomelandEditorCtrl:getOrnamentMaxPlaceNum(itemId)
	if self.carGroup then
		return self:getCarOrnamentMaxPlaceNum(itemId)
	end

	return self:getHomelandOrnamentMaxPlaceNum(itemId)
end

function HomelandEditorCtrl:getOrnamentCurPlaceNum(itemId)
	if self.carGroup then
		return self:getCarOrnamentCurPlaceNum(itemId)
	end

	return self:getHomelandOrnamentCurPlaceNum(itemId)
end

function HomelandEditorCtrl:getHomelandOrnamentMaxPlaceNum(itemId)
	return pg.me:getOrnamentAreaMaxPlaceNum(itemId, self:getEditAreaId())
end

function HomelandEditorCtrl:getHomelandOrnamentCurPlaceNum(itemId)
	return pg.me:getOrnamentAreaCurPlaceNum(itemId, self:getEditAreaId())
end

function HomelandEditorCtrl:getCarOrnamentMaxPlaceNum(itemId)
	return pg.me:getOrnamentMaxPlaceNum(itemId)
end

function HomelandEditorCtrl:getCarOrnamentCurPlaceNum(itemId)
	return pg.me:getOrnamentCarCurPlaceNum(itemId)
end

function HomelandEditorCtrl:getOrnamentBuyMaxPlaceNum(itemId)
	return pg.me:getOrnamentTotalMaxPlaceNum(itemId)
end

function HomelandEditorCtrl:onPlaceBtnClick()
	if not self:placeNewOrnament(self.curItemId) then
		return false
	end

	return true
end

function HomelandEditorCtrl:getOrnamentPlaceIdCurPlaceNum(templateId)
	local homeObjectInfo = HomeObjectData[templateId]

	if not homeObjectInfo then
		return 0
	end

	local count = pg.me:getOrnamentCurPlaceNum(templateId)

	if not homeObjectInfo.placeId then
		count = count + ClientUtils.getItemCountById(templateId)

		if pg.me:isInSelfHomeland() then
			count = count + ClientUtils.getHomelandItemCountById(templateId)
		end
	else
		local relatedTemplateIds = RevertHomePlaceData[homeObjectInfo.placeId]

		for _, relatedTemplateId in ipairs(relatedTemplateIds) do
			count = count + ClientUtils.getItemCountById(relatedTemplateId)

			if pg.me:isInSelfHomeland() then
				count = count + ClientUtils.getHomelandItemCountById(relatedTemplateId)
			end
		end
	end

	return count
end

function HomelandEditorCtrl:onGetBtnClick()
	local templateId = self.curItemId

	if not templateId then
		return
	end

	local objectInfo = HomeObjectData[templateId] or {}
	local unlockState = ClientHomelandUtils.getFurnitureUnlockState(templateId, false)

	if unlockState.conditionLocked then
		pg.global.showBubbleMessage(NoticeDef.HOME_ORNAMENT_UNLOCKED)

		return
	end

	if unlockState.drawingLocked then
		pg.global.ui.tips:showTextTip(unlockState.lockText)

		return
	end

	local maxNum = self:getOrnamentBuyMaxPlaceNum(templateId)

	if maxNum then
		local curOwnCount = self:getOrnamentPlaceIdCurPlaceNum(templateId)

		if maxNum <= curOwnCount then
			pg.global.showBubbleMessage(NoticeDef.HOME_ERROR_ORNAMENT_BUY_COUNT_MAX)

			return
		end
	end

	local costItemId = objectInfo.buyMoneyType
	local costItemNum = objectInfo.buyMoneyNum

	if pg.space and pg.space.demoMode == true and Const.HOMELAND_DEMO_SHELL_BUY_ORNAMENT_IDS[templateId] then
		costItemId = Const.HOMELAND_DEMO_SHELL_ITEM_ID
		costItemNum = Const.HOMELAND_DEMO_SHELL_BUY_ORNAMENT_PRICE
	end

	if not costItemId or not costItemNum then
		return
	end

	local costText = LuaUIUtils.getItemCountConsumeShowText(costItemId, costItemNum, true)

	pg.global.ui.commonUseConfirm:open({
		type = 4,
		title = pg.getGameString("CONFIRM_BUY"),
		tipTop = string.format(pg.getGameString("HOME_BUY_DESC"), costText),
		data = {
			{
				costItemId,
				costItemNum
			}
		},
		notEnoughCallback = function(itemId, itemNum)
			local itemInfo = LuaUIUtils.getItemClientInfoById(itemId)
			local itemName = pg.getLocalizationText(itemInfo.name)

			pg.global.showBubbleMessage(NoticeDef.SHOP_ITEM_NOT_ENOUGH, itemName)
		end,
		confirmCb = function()
			pg.global.ui.commonUseConfirm:close()
			pg.me:serverMsg("RPC_CS_BuyOrnament", templateId, function(returnCode)
				if returnCode == 0 then
					pg.global.showBubbleMessage(NoticeDef.BUY_SUCCESS)
				else
					self:showBuyRetNotice(returnCode)
				end
			end)
		end,
		cancelCb = function()
			pg.global.ui.commonUseConfirm:close()
		end
	})
end

function HomelandEditorCtrl:refreshEnvSimulateInfo()
	if self.carGroup then
		self.view.widgetPrompt:SetActive(true)

		local maxCount = HomelandConfigData.HomeCampOrnamentMax or 30
		local countText = string.format("%d/%d", HomeLandUtils.getCarGroupOrnamentCount(), maxCount)

		ClientTextUtils.setText(self.view.textUSDFText, ClientTextUtils.concatByLanguage(pg.getGameString("HOMECAR_CURRENTLY_PLACED_ORNAMENT"), countText))
	else
		self.view.widgetPrompt:SetActive(pg.game.home:checkEnableHomeSimulate())
		ClientTextUtils.setText(self.view.textUSDFText, pg.getGameString("HOMELAND_SIMULATE_ENVIROMENT"))
	end
end

function HomelandEditorCtrl:getFavOrnamentRPCName()
	if self.carGroup then
		return "RPC_CS_FavoriteCarOrnament"
	end

	return "RPC_CS_FavoriteOrnament"
end

function HomelandEditorCtrl:onFavoriteButtonClick()
	local maxFavoriteOrnamentCount = HomelandConfigData.maxFavoriteOrnamentCount or 20
	local favList = self:getFavList()
	local favoriteOrnamentCount = #favList

	if not self.isFavorite and maxFavoriteOrnamentCount <= favoriteOrnamentCount then
		pg.global.showBubbleMessage(NoticeDef.ADD_FAVORITE_ORNAMENT_ERROR)

		return
	end

	self.isFavorite = not self.isFavorite

	self.btnFavoriteUButton:TryChangePage("enable", self.isFavorite and 1 or 0)
	pg.me:serverMsg(self:getFavOrnamentRPCName(), self.curItemId, self.isFavorite and 1 or 0, function(returnCode)
		if returnCode == 0 then
			if self.itemListComponent.curType ~= self.itemListComponent.FavoriteTypeIndex then
				local favoritePlaceIds = self.itemListComponent:getFavPlaceIds()

				self.itemListComponent:refreshFavState(self.itemListComponent.itemList, self.itemListComponent.itemList.selectedIndex, HomeObjectData[self.curItemId].placeId == nil and self.isFavorite or favoritePlaceIds[HomeObjectData[self.curItemId].placeId] ~= nil)
				self.itemListComponent:refreshFavState(self.itemListComponent.foldListUList, self.itemListComponent.foldListUList.selectedIndex, self.isFavorite)
			else
				self.itemListComponent:refreshItemList()
			end
		end
	end)
end

function HomelandEditorCtrl:showBuyRetNotice(returnCode)
	if returnCode == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.ERROR_ORNAMENT_BUY_COUNT_MAX then
		pg.global.showBubbleMessage(NoticeDef.HOME_ERROR_ORNAMENT_BUY_COUNT_MAX)

		return
	end

	pg.global.showBubbleMessage(NoticeDef.BUY_FAILED)
end

function HomelandEditorCtrl:placeNewOrnament(itemId, keepPosition)
	local templateId = itemId
	local maxNum = self:getOrnamentMaxPlaceNum(templateId)

	if maxNum then
		local placeItemCount = self:getOrnamentCurPlaceNum(templateId)

		if maxNum <= placeItemCount then
			pg.global.showBubbleMessage(NoticeDef.HOME_ERROR_ORNAMENT_COUNT_MAX)

			return false
		end
	end

	local itemCount = ClientUtils.getItemCountById(templateId)

	if pg.me:isInSelfHomeland() then
		itemCount = itemCount + ClientUtils.getHomelandItemCountById(templateId)
	end

	if itemCount <= 0 then
		local homeObjectData = HomeObjectData[templateId]

		if homeObjectData.getWay == Const.HOMELAND_ORNAMENT_GET_WAY.ACTIVITY then
			pg.global.showBubbleMessage(NoticeDef.HOME_ACTIVITY_ITEM_LACK)

			return false
		end

		if homeObjectData.getWay == Const.HOMELAND_ORNAMENT_GET_WAY.OTHER then
			pg.global.showBubbleMessage(NoticeDef.HOME_ORNAMENT_NOT_ENOUGH)

			return false
		end

		local unlockState = ClientHomelandUtils.getFurnitureUnlockState(templateId, false)

		if unlockState.conditionLocked then
			pg.global.showBubbleMessage(NoticeDef.HOME_ORNAMENT_UNLOCKED)

			return false
		end

		if unlockState.drawingLocked then
			pg.global.ui.tips:showTextTip(unlockState.lockText)

			return false
		end
	end

	local maxCount = HomelandConfigData.HomeCampOrnamentMax or 30

	if self.carGroup and maxCount <= HomeLandUtils.getCarGroupOrnamentCount() then
		pg.global.showBubbleMessage(NoticeDef.HOME_CAR_CAMP_ORNAMENT_COUNT_MAX)

		return false
	end

	self:selectItem(nil)

	local homeTemplateId = itemId
	local initPosition

	if keepPosition and self.editor.previewEntity then
		initPosition = self.editor.previewEntity:getPosition()
	end

	pg.global.ui.homelandPlacement:open({
		editType = ClientConst.HomeEditType.PlaceOrnament,
		homeTemplateId = homeTemplateId,
		initPosition = initPosition,
		editor = self.editor,
		areaId = self.areaId,
		carGroup = self.carGroup
	})

	return true
end

function HomelandEditorCtrl:onItemChanged(data)
	if not self.view then
		return
	end

	self:updateCurrencyData()

	local itemId = data.itemId or data.genId

	if itemId then
		self:refreshDetailWindow()
		self.itemListComponent:refreshItemList()
	end
end

function HomelandEditorCtrl:onDrawingUnlockChanged(data)
	if not data.itemId then
		return
	end

	self:refreshDetailWindow()
	self.itemListComponent:refreshItemList()
	self.itemListComponent:refreshFoldList()
end

function HomelandEditorCtrl:onOrnamentChanged(data)
	return
end

function HomelandEditorCtrl:onStatHomeCarOrnamentChanged(data)
	self:refreshEnvSimulateInfo()
	self:refreshDetailWindow()
	self.itemListComponent:refreshItemList()
end

function HomelandEditorCtrl:onStatHomeLandOrnamentChanged(data)
	self:refreshDetailWindow()
	self.itemListComponent:refreshItemList()
end

function HomelandEditorCtrl:onInputDeviceChanged(deviceType)
	self.itemListComponent:onInputDeviceChanged(deviceType)
	self.viewCtrlComponent:refreshKeyHints()
	pg.global.ui:refreshLockCursor()
	self:refreshTopWidgetVisibility()
	self:refreshVirtualMouseHoverSnapEnabled()
end

function HomelandEditorCtrl:onExpandChange(isExpand)
	local inModal = pg.global.navMgr and pg.global.navMgr:IsInModalGroup() or false

	self.view.uIPbHomeEditorUWidget.navRegionForceCursorOn = not isExpand and not inModal

	pg.global.ui:refreshLockCursor()
	self:refreshTopWidgetVisibility()
	self:refreshVirtualMouseHoverSnapEnabled()
end

function HomelandEditorCtrl:refreshTopWidgetVisibility()
	local hide = pg.game.input:isUsingGamepad() and self.itemListComponent and self.itemListComponent.isExpand

	if NotNil(self.view.globalEditingUWidget) then
		self.view.globalEditingUWidget:SetActive(not hide)
	end

	if NotNil(self.view.listCurrencyUList) then
		self.view.listCurrencyUList:SetActive(not hide)
	end

	if NotNil(self.view.btnAreaUButton) then
		self.view.btnAreaUButton:SetActive(not hide)
	end

	if NotNil(self.view.btnDisplayUButton) then
		local displayButtonEnabled = not self.carGroup and self.areaId == Const.HOMELAND_AREA_TYPE.BUILD

		self.view.btnDisplayUButton:SetActive(not hide and displayButtonEnabled)
	end

	if NotNil(self.view.selectorMetreUSelector) then
		self.view.selectorMetreUSelector:SetActive(not hide)
	end
end

function HomelandEditorCtrl:onNavFocusChange()
	if self.itemListComponent then
		self:onExpandChange(self.itemListComponent.isExpand)
	end
end

function HomelandEditorCtrl:onInfoButtonClick()
	pg.global.ui.help:open({
		helpId = 693
	})
end

function HomelandEditorCtrl:shopButtonClick()
	self.itemListComponent.uWidget:TryChangePage("FoldList", 0)
	pg.global.ui:open(UIConst.UI_ID_HOMELAND_FURNITURE_STORE, {
		curItemId = self.curItemId,
		carGroup = self.carGroup,
		areaId = self.areaId
	})
end

function HomelandEditorCtrl:initConsoleKeys()
	local hotKeyContent = self.view.btnQuitHotKey:GetComponent("HotKeyContent")
	local quitPanelBindKey = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadCancel

	hotKeyContent:SetHotKeyPaths(quitPanelBindKey)
	LuaUIUtils.waitHotKeyContentObjectReference(self, hotKeyContent, function(objectReference)
		self.progressPressContainerUContainer = objectReference:GetRefValue("progressPressContainerUContainer")

		if not self.progressPressContainerUContainer then
			return
		end

		self.progressPressContainerUContainer:SetActive(true)
		self.progressPressContainerUContainer:LoadDefaultUrlManually(function()
			self.keyProgressPress = self.progressPressContainerUContainer.content

			self.keyProgressPress:ProgressToValue(0, nil)

			local quitPanelBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnBack.gameObject, "quitPanelBindKey")

			quitPanelBinding.isVirtual = true
			quitPanelBinding.actionPath = quitPanelBindKey
			quitPanelBinding.priority = 1

			function quitPanelBinding.luaTrigger(inputInfo)
				if pg.game.input:isUsingGamepad() then
					self:longClickLuafunction(inputInfo, quitPanelBindKey, 0.55, 0.25, CallbackHandler(self, "onQuitBtnClick"), self.keyProgressPress, function()
						self.keyProgressPress:ProgressToValue(0, nil)
					end)

					return false
				end
			end
		end)
	end)

	local gamepadMoveBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.view.gameObject, "gamepadMoveViewBinding")

	gamepadMoveBinding.isVirtual = true
	gamepadMoveBinding.actionPath = "Raw/GamepadDPad"

	function gamepadMoveBinding.luaTrigger(inputInfo)
		local deltaVec2 = inputInfo.valueVec2

		self.editor:handleMove(deltaVec2[1], deltaVec2[2])
	end
end

return HomelandEditorCtrl
