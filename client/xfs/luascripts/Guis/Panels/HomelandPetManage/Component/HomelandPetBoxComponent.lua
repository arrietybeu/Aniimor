-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandPetManage\\Component\\HomelandPetBoxComponent.lua

local HomeAbilityData = require("Data.home_ability_data")
local lume = require("Core.Common.lume")
local UIConst = require("Const.UIConst")
local AddressDataConst = require("Const.AddressDataConst")
local RedDotConst = require("Const.RedDotConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HomeEventTextData = require("Data.home_event_text_data")
local HomelandOperateData = require("Data.homeland_operate_data")
local HomeEventTypeData = require("Data.home_event_type_data")
local Const = require("Common.Const.Const")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local PetManagementUtils = require("Utils.PetManagementUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local NoticeDef = require("Common.NoticeDef")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local PetData = require("Data.pet_data")
local PetFormTypeData = require("Data.pet_form_type_data")
local RogueUtils = require("Utils.RogueUtils")
local UIComponent = require("Guis.Helper.UIComponent")
local HomelandAreaData = require("Data.homeland_area_data")
local HomelandPetBoxComponent = Class.LightClass("HomelandPetBoxComponent", UIComponent)

HomelandPetBoxComponent.DEFAULT_AREA_ID = Const.HOMELAND_AREA_TYPE.PRODUCE
HomelandPetBoxComponent.BATCH_MODE = {
	MOVE_OUT = 2,
	PUT_IN = 1,
	NONE = 0
}
HomelandPetBoxComponent.APPEARANCE_TYPE = HomeLandUtils.HOME_VOUCHER_APPEARANCE_TYPE

function HomelandPetBoxComponent.sortAppearanceDistribution(left, right)
	if left.sortKey == right.sortKey then
		return left.id < right.id
	end

	return left.sortKey < right.sortKey
end

function HomelandPetBoxComponent.getFormQualityNameTextId(formQuality)
	for _, formTypeData in pairs(PetFormTypeData) do
		if formTypeData.formQuality == formQuality then
			return formTypeData.name
		end
	end

	return nil
end

function HomelandPetBoxComponent.sortAbilityInfo(left, right)
	return left.id < right.id
end

function HomelandPetBoxComponent.getAbilityDisplayState(count, requirement)
	if requirement <= 0 then
		return 0, "NmlT_D"
	end

	if requirement <= count then
		return 1, "Prg_G"
	end

	return 1, "NmlT_D"
end

function HomelandPetBoxComponent:onCtor(info)
	local areaId = info and info.areaId or HomelandPetBoxComponent.DEFAULT_AREA_ID

	self.currentAreaId = HomeLandUtils.isHomePetBoxAreaSupported(areaId) and areaId or HomelandPetBoxComponent.DEFAULT_AREA_ID
end

function HomelandPetBoxComponent:findObjects()
	return
end

function HomelandPetBoxComponent:initView()
	self.mulToMoveOut = {}
	self.mulToPutIn = {}
	self.abilityBtn = {}
	self.batchMode = HomelandPetBoxComponent.BATCH_MODE.NONE
	self.homePetDragToken = 0
	self.homePetListRefreshPending = false

	if not self.uWidget:CheckURLLoaded() then
		self.uWidget:LoadDefaultUrlManually(function()
			self:onContentLoaded()
		end)
	else
		self:onContentLoaded()
	end
end

function HomelandPetBoxComponent:onContentLoaded()
	local content = self.uWidget.content
	local objectReference = content:GetComponent("ObjectReference")

	self.txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	self.txtTotalUSDFText = objectReference:GetRefValue("txtTotalUSDFText")
	self.listPetHomeUList = objectReference:GetRefValue("listPetHomeUList")
	self.listElementQuantityUList = objectReference:GetRefValue("listElementQuantityUList")
	self.areaTabUWidget = LuaUIUtils.safeGetRefValue(objectReference, "areaTabUWidget")
	self.btnProduceAreaUButton = LuaUIUtils.safeGetRefValue(objectReference, "btnProduceAreaUButton")
	self.btnBuildAreaUButton = LuaUIUtils.safeGetRefValue(objectReference, "btnBuildAreaUButton")
	self.imgBuildAreaLockUImage = LuaUIUtils.safeGetRefValue(objectReference, "imgBuildAreaLockUImage")
	self.listPetAppearanceUList = LuaUIUtils.safeGetRefValue(objectReference, "listPetAppearanceUList")
	self.txtAbilityDistributionTitleUSDFText = LuaUIUtils.safeGetRefValue(objectReference, "txtAbilityDistributionTitleUSDFText")
	self.txtProduceAreaUSDFText = LuaUIUtils.safeGetRefValue(objectReference, "txtProduceAreaUSDFText")
	self.txtBuildAreaUSDFText = LuaUIUtils.safeGetRefValue(objectReference, "txtBuildAreaUSDFText")
	self.btnAbilityInfoUButton = LuaUIUtils.safeGetRefValue(objectReference, "btnAbilityInfoUButton")
	self.btnAbilityInfoKeyUContainer = LuaUIUtils.safeGetRefValue(objectReference, "btnAbilityInfoKeyUContainer")
	self.wishingStarULayoutBox = LuaUIUtils.safeGetRefValue(objectReference, "wishingStarULayoutBox")
	self.txtWishingStarOutputUSDFText = LuaUIUtils.safeGetRefValue(objectReference, "txtWishingStarOutputUSDFText")
	self.regionUIReady = self.areaTabUWidget ~= nil and self.btnProduceAreaUButton ~= nil and self.btnBuildAreaUButton ~= nil and self.imgBuildAreaLockUImage ~= nil and self.listPetAppearanceUList ~= nil and self.txtAbilityDistributionTitleUSDFText ~= nil and self.txtProduceAreaUSDFText ~= nil and self.txtBuildAreaUSDFText ~= nil

	if not self.regionUIReady then
		self.currentAreaId = Const.HOMELAND_AREA_TYPE.PRODUCE
		self.ctrl.currentPetAreaId = Const.HOMELAND_AREA_TYPE.PRODUCE
	end

	self.defaultAbilityDistributionTitle = self.txtAbilityDistributionTitleUSDFText and self.txtAbilityDistributionTitleUSDFText.text or ""
	self.btnHomeFilterUButton = objectReference:GetRefValue("btnHomeFilterUButton")
	self.btnOrganizeUButton = objectReference:GetRefValue("btnOrganizeUButton")
	self.rightInfoUComponent = objectReference:GetRefValue("rightInfoUComponent")
	self.btnFilterUButton = objectReference:GetRefValue("btnFilterUButton")
	self.btnCleanFilterUButton = objectReference:GetRefValue("btnCleanFilterUButton")
	self.btnMoveUButton = objectReference:GetRefValue("btnMoveUButton")
	self.btnMoveOutSelectAll = objectReference:GetRefValue("btnAllSelectedUButton")
	self.btnExitUButton = objectReference:GetRefValue("btnExitUButton")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.moveOutCount = objectReference:GetRefValue("moveOutCount")
	self.petListUComponent = objectReference:GetRefValue("petListUComponent")
	self.btnEnterPutIn = objectReference:GetRefValue("btnEnterPutIn")
	self.btnExitPutIn = objectReference:GetRefValue("btnExitPutIn")
	self.btnConfirmPutIn = objectReference:GetRefValue("btnConfirmPutIn")
	self.btnPutInAllSelected = objectReference:GetRefValue("btnPutInAllSelected")
	self.putInCount = objectReference:GetRefValue("putInCount")
	self.petTipPopupForm = objectReference:GetRefValue("petTipPopupForm")
	self.petTipPanelTransform = objectReference:GetRefValue("petTipPanelTransform")
	self.leftPetTipAnchor = objectReference:GetRefValue("leftPetTipAnchor")
	self.rightPetTipAnchor = objectReference:GetRefValue("rightPetTipAnchor")
	self.petUWidget = objectReference:GetRefValue("petUWidget")

	function self.btnOrganizeUButton.luaClick()
		self:organizeHomePet()
	end

	if self.regionUIReady then
		self.btnProduceAreaUButton.dropable = true
		self.btnBuildAreaUButton.dropable = true

		function self.btnProduceAreaUButton.luaClick()
			self.ctrl:switchPetArea(Const.HOMELAND_AREA_TYPE.PRODUCE)
		end

		function self.btnBuildAreaUButton.luaClick()
			if not HomeLandUtils.canUseHomePetBoxArea(pg.space, Const.HOMELAND_AREA_TYPE.BUILD) then
				self:refreshAreaTabState()
				pg.global.showBubbleMessage(NoticeDef.HOME_CAMP_WORLD_LOCKED)

				return
			end

			self.ctrl:switchPetArea(Const.HOMELAND_AREA_TYPE.BUILD)
		end
	end

	if self.btnAbilityInfoUButton then
		function self.btnAbilityInfoUButton.luaClick()
			if self.inBatchMode or self:isPetTipOpen() then
				return
			end

			self:openCurrentAbilityPopup()
		end
	end

	function self.btnEnterPutIn.luaClick()
		self:enterBatchPutIn()
	end

	function self.btnExitPutIn.luaClick()
		self:exitBatchPutIn()
	end

	function self.btnConfirmPutIn.luaClick()
		self:confirmBatchPutIn()
	end

	function self.btnHomeFilterUButton.luaClick()
		self:onFilterClick()
	end

	function self.btnFilterUButton.luaClick()
		self:onFilterClick()
	end

	function self.btnCleanFilterUButton.luaClick()
		self:onExitFilterClick()
	end

	self.petManagementDelegateTable = {
		gamepadPetBoxPageHandledByPrefab = true,
		luaBeginDrag = function()
			self.boxPetDropTargetActive = false
			self.boxPetGapPreviewActive = false
		end,
		luaDrag = function(data, pointerPosition)
			self:updateBoxPetGapDropPreview(data.id, pointerPosition)
		end,
		luaEndDrag = function(dropWidget, pointerWidget, rawPointerWidget, _, pointerPosition)
			local hadGapPreview = self.boxPetGapPreviewActive

			self.boxPetDropTargetActive = false
			self.boxPetGapPreviewActive = false

			self:endDragPetSlot(dropWidget, pointerWidget, rawPointerWidget, pointerPosition)

			if hadGapPreview then
				self:refreshAbilityList()
			end

			self.appearanceDistributionInfo = nil

			if self.boxPetAppearanceRefreshPending then
				self.boxPetAppearanceRefreshPending = nil

				PetManagementUtils.refreshPetList()
			end
		end,
		luaEnterDropWidget = function(data, target)
			self.boxPetDropTargetActive = true
			self.boxPetGapPreviewActive = false

			self:petSlotEnterDropWidget(data.id, target)
		end,
		luaExitDropWidget = function()
			self.boxPetDropTargetActive = false
			self.boxPetGapPreviewActive = false

			self:refreshAbilityList()
		end,
		luaClick = function(btn, idx, data)
			self:onClickPetHead(btn, data)
		end,
		getShowAppearanceTags = function()
			return self.currentAreaId == Const.HOMELAND_AREA_TYPE.BUILD
		end,
		renderExtraLogic = function(button, idx, data)
			if self.inBatchMode and data and not data.isEmpty and data.id and self.mulToPutIn[data.id] then
				button:TryChangePage("Batch", 1)
			else
				button:TryChangePage("Batch", 0)
			end

			local isCurSelected = data and not data.isEmpty and data.id and data.id == PetManagementUtils.curSelectPetId

			button.isSelected = isCurSelected or false
		end,
		onGamepadPetBoxPageSwitched = function()
			self.ctrl:focusDefaultPetListItem()
		end,
		onWishingStarOutputBound = function(button)
			self.wishingStarFocusButton = button

			if NotNil(button) and self.focusWishingStarOnPetTipOpen and self:isPetTipOpen() then
				self.ctrl:scheduleGamepadFocus(function()
					return self.wishingStarFocusButton
				end)
			end
		end
	}

	function self.btnPutInAllSelected.luaClick()
		if self.btnPutInAllSelected.isSelected then
			self.btnPutInAllSelected.isSelected = false

			self:deselectAllBoxPets()
		else
			self.btnPutInAllSelected.isSelected = true

			self:selectAllBoxPets()
		end
	end

	self:initPetManagementTemplate()

	function self.listElementQuantityUList.luaRenderItem(button, idx, data)
		self:renderAbilityList(button, data)
	end

	if self.listPetAppearanceUList then
		function self.listPetAppearanceUList.luaRenderItem(button, idx, data)
			self:renderAppearanceList(button, data)
		end
	end

	function self.listPetHomeUList.luaRenderItem(button, idx, data)
		self:renderPetList(button, idx, data)
	end

	function self.listPetHomeUList.luaClick(btn, data)
		if not data.isEmpty then
			if self.inBatchMode then
				local isSelect = false
				local petId = data.id

				if self.mulToMoveOut[petId] then
					btn:TryChangePage("Batch", 0)
				else
					btn:TryChangePage("Batch", 1)

					isSelect = true
				end

				self:onPetSelectChange(isSelect, petId)
			else
				self:showPetInfo(btn, data, false)
			end

			if NotNil(PetManagementUtils.selectedBtn) then
				PetManagementUtils.selectedBtn.isSelected = false
			end

			PetManagementUtils.selectedBtn = nil
		end
	end

	function self.btnMoveUButton.luaClick()
		self:enterBatchPutOut()
	end

	function self.btnExitUButton.luaClick()
		self:exitBatchMoveOut()
	end

	function self.btnConfirmUButton.luaClick()
		self:confirmBatchMoveOut()
	end

	function self.btnMoveOutSelectAll.luaClick()
		if self.btnMoveOutSelectAll.isSelected then
			self.btnMoveOutSelectAll.isSelected = false

			self:deSelectAllHomePets()
			self:calMoveOutBatchCount()
			self:refreshAbilityList()
		else
			self.btnMoveOutSelectAll.isSelected = true

			self:selectAllHomePets()
		end
	end

	self.listPetHomeUList.groupType = CS.XGUI.EGroupType.Radio

	self:refreshPetCount()
	self:refreshAreaTabState()
	self.txtBuildAreaUSDFText:SetSizeX(self.txtBuildAreaUSDFText:GetTargetWidth(-1))
	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.HOMELAND_PET_BOX_CAPACITY, self.petUWidget, function()
		return self.model:redDot_GetPetBoxCapacityState()
	end)
	self.model:redDot_RecordPetBoxCapacityRead()
	self:refreshHomePetList()
	self:refreshAbilityList()
	self.petTipPopupForm:SetActive(false)
	self.ctrl:focusDefaultPetListItem()
end

function HomelandPetBoxComponent:savePetManagementState()
	self.petManagementState = {
		boxId = PetManagementDataHelper.getSelectBoxId(),
		filter = PetManagementDataHelper.filter and Utils.deepCopyTable(PetManagementDataHelper.filter) or nil,
		sortId = PetManagementDataHelper.selectSortId,
		isDescending = PetManagementDataHelper.isDescending,
		showLabelInfo = PetManagementDataHelper.showLabelInfo,
		selectSlot = PetManagementUtils.selectSlot,
		petId = PetManagementUtils.curSelectPetId,
		inFilterMode = PetManagementUtils.inFilterMode
	}
end

function HomelandPetBoxComponent:initPetManagementTemplate(state)
	if state then
		PetManagementDataHelper.setSelectBoxId(state.boxId)
	end

	PetManagementUtils.setListButtonDelegateTable(self.petManagementDelegateTable, self)

	PetManagementUtils.displayType = UIConst.PET_SLOT_DISPLAY_TYPE.Homeland
	PetManagementUtils.dynamicUpdateDropWidget = true

	PetManagementUtils.initSimpleMidTemplate(self.petListUComponent, {
		owner = self,
		contextRestoreCb = function()
			self:restorePetManagementTemplate()
		end
	}, state ~= nil)

	if not state then
		return
	end

	PetManagementDataHelper.filter = state.filter
	PetManagementDataHelper.selectSortId = state.sortId
	PetManagementDataHelper.isDescending = state.isDescending
	PetManagementDataHelper.showLabelInfo = state.showLabelInfo
	PetManagementUtils.selectSlot = state.selectSlot
	PetManagementUtils.curSelectPetId = state.petId

	if state.inFilterMode then
		PetManagementUtils._startFilter()
	else
		PetManagementUtils.refreshPetList()
	end
end

function HomelandPetBoxComponent:restorePetManagementTemplate()
	if not self.ctrl or not self.petListUComponent then
		return
	end

	if PetManagementUtils.isContextOwner(self) and PetManagementUtils.delegateTable == self.petManagementDelegateTable and PetManagementUtils._hasMidPanelContext() then
		return
	end

	self:initPetManagementTemplate(self.petManagementState)
end

function HomelandPetBoxComponent:onDestroy()
	self.focusWishingStarOnPetTipOpen = nil
	self.wishingStarFocusButton = nil

	self:clearHomePetDragState()
	UIComponent.onDestroy(self)
	PetManagementUtils.destroyTemplate(self)
end

function HomelandPetBoxComponent:isPetTipOpen()
	return self.petTipPopupForm and self.petTipPopupForm.gameObject.activeSelf
end

function HomelandPetBoxComponent:closePetTip()
	if self.petTipPopupForm and self.petTipPopupForm.gameObject.activeSelf then
		self.petTipPopupForm:SetActive(false)
	end
end

function HomelandPetBoxComponent:organizeHomePet()
	local formatIdx = 1
	local petIndexList = {}

	for idx = 1, pg.space.petBoxMap:getSlotCount() do
		local petId = pg.space.petBoxMap:getPetId(self.currentAreaId, idx)

		if petId then
			if idx ~= formatIdx then
				petIndexList[#petIndexList + 1] = {
					petId = petId,
					fromSlotIndex = idx,
					formatIdx = formatIdx
				}
			end

			formatIdx = formatIdx + 1
		end
	end

	pg.me.space:updateHomelandPetIndexBatch(petIndexList, self.currentAreaId)
end

function HomelandPetBoxComponent:setCurrentAreaId(areaId)
	areaId = areaId or HomelandPetBoxComponent.DEFAULT_AREA_ID

	if self.currentAreaId == areaId or not HomeLandUtils.isHomePetBoxAreaSupported(areaId) or not self.regionUIReady and areaId ~= Const.HOMELAND_AREA_TYPE.PRODUCE then
		return false
	end

	if self.batchMode == HomelandPetBoxComponent.BATCH_MODE.PUT_IN then
		self:exitBatchPutIn()
	elseif self.batchMode == HomelandPetBoxComponent.BATCH_MODE.MOVE_OUT then
		self:exitBatchMoveOut()
	elseif self.inBatchMode then
		self.inBatchMode = false

		self.uWidget.content:TryChangePage("PutMove", 0)
	end

	self:closePetTip()

	self.currentAreaId = areaId

	if not self.draggingHomePetInfo and not PetManagementUtils.isPetBoxDragging then
		self.appearanceDistributionInfo = nil
	end

	self:refreshAreaTabState()

	if PetManagementUtils.isPetBoxDragging then
		self.boxPetAppearanceRefreshPending = true
	else
		PetManagementUtils.refreshPetList()
	end

	if self.listPetHomeUList then
		self:refreshHomePetList()
		self:refreshAbilityList()
		self.rightInfoUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end

	return true
end

function HomelandPetBoxComponent:refreshAreaTabState()
	if not self.regionUIReady then
		if self.areaTabUWidget then
			self.areaTabUWidget:SetActive(false)
		end

		return
	end

	self.areaTabUWidget:SetActive(true)

	local buildUnlocked = HomeLandUtils.canUseHomePetBoxArea(pg.space, Const.HOMELAND_AREA_TYPE.BUILD)

	self.btnProduceAreaUButton.isSelected = self.currentAreaId == Const.HOMELAND_AREA_TYPE.PRODUCE
	self.btnBuildAreaUButton.isSelected = buildUnlocked and self.currentAreaId == Const.HOMELAND_AREA_TYPE.BUILD

	self.btnBuildAreaUButton:TryChangePage("Locked", buildUnlocked and 0 or 1)
	self.imgBuildAreaLockUImage:SetActive(not buildUnlocked)
end

function HomelandPetBoxComponent:getRemainingPetCapacity()
	local space = pg.me and pg.me.space

	return space and space.petBoxMap and space.petBoxMap:getRemainingPetCount() or 0
end

function HomelandPetBoxComponent:deselectAllBoxPets()
	if self.inBatchMode then
		local boxId = PetManagementDataHelper.getSelectBoxId()
		local petBox = pg.me.petBoxMap[boxId]

		if not petBox then
			return
		end

		for idx = 1, petBox.slotCount do
			local petId = petBox[idx]

			if petId then
				self.mulToPutIn[petId] = nil
			end
		end

		PetManagementUtils.clearBatchSelect()
		self:preMovePetsToHome()
		self:refreshBatchPutInSelectCount()
	end
end

function HomelandPetBoxComponent:refreshOnPetChange(petId)
	self.appearanceDistributionInfo = nil

	if NotNil(PetManagementUtils.selectedBtn) then
		PetManagementUtils.selectedBtn.isSelected = false
	end

	PetManagementUtils.selectedBtn = nil

	PetManagementUtils._refreshPetList()
	self:refreshHomePetList()
	self:refreshPetCount()

	if self.batchMode == HomelandPetBoxComponent.BATCH_MODE.PUT_IN then
		self:exitBatchPutIn()
	elseif self.batchMode == HomelandPetBoxComponent.BATCH_MODE.MOVE_OUT then
		self:exitBatchMoveOut()
	end

	self:refreshAbilityList()
end

function HomelandPetBoxComponent:tryAddSelectPetToPutIn(petId, showMsg)
	if self.mulToPutIn[petId] then
		return true
	end

	local camMoveCount = self:getRemainingPetCapacity()
	local selectCount = 0

	for pId, _ in pairs(self.mulToPutIn) do
		selectCount = selectCount + 1
	end

	selectCount = selectCount + 1

	if camMoveCount < selectCount then
		if showMsg then
			pg.global.showBubbleMessage(NoticeDef.HOME_ERROR_PET_UPPER_LIMIT)
		end

		return false
	else
		self.mulToPutIn[petId] = true

		return true
	end
end

function HomelandPetBoxComponent:selectAllBoxPets()
	if self.inBatchMode then
		local boxId = PetManagementDataHelper.getSelectBoxId()
		local petBox = pg.me.petBoxMap[boxId]

		if not petBox then
			return
		end

		for idx = 1, petBox.slotCount do
			local petId = petBox[idx]

			if petId then
				local ret = self:tryAddSelectPetToPutIn(petId)

				if ret then
					PetManagementUtils.setSelectedPet(idx - 1, true)
					self:refreshBatchPutInSelectCount()
				else
					break
				end
			end
		end

		self:preMovePetsToHome()
	end
end

function HomelandPetBoxComponent:preMovePetsToHome()
	local finalPetIds = {}

	for pId, _ in pairs(self.mulToPutIn) do
		finalPetIds[#finalPetIds + 1] = pId
	end

	self:refreshAbilityList()
	self:tryMovePetToHome(finalPetIds)
end

function HomelandPetBoxComponent:updateBoxPetGapDropPreview(petId, pointerPosition)
	if self.boxPetDropTargetActive or not pointerPosition or not self.listPetHomeUList then
		return
	end

	local pointerInHomeList = CS.UnityEngine.RectTransformUtility.RectangleContainsScreenPoint(self.listPetHomeUList.rectTransform, pointerPosition, CS.XGUI.UWidget.uiCamera)

	if pointerInHomeList == self.boxPetGapPreviewActive then
		return
	end

	self.boxPetGapPreviewActive = pointerInHomeList

	if pointerInHomeList then
		local pet = pg.me and pg.me.pets and pg.me.pets[petId]

		if pet then
			local previewCountInfo = {}

			self:calPetHomeAbilityCount(pet, previewCountInfo, true)
			self:tipAbilityCount(previewCountInfo)
		end
	else
		self:refreshAbilityList()
	end
end

function HomelandPetBoxComponent:getDropAreaId(targetWidget)
	if not self.regionUIReady or not targetWidget or not targetWidget.gameObject then
		return
	end

	if targetWidget.gameObject == self.btnProduceAreaUButton.gameObject then
		return Const.HOMELAND_AREA_TYPE.PRODUCE
	elseif targetWidget.gameObject == self.btnBuildAreaUButton.gameObject then
		return Const.HOMELAND_AREA_TYPE.BUILD
	elseif self.listPetHomeUList and targetWidget.gameObject == self.listPetHomeUList.gameObject then
		return self.currentAreaId
	end
end

function HomelandPetBoxComponent:endDragPetSlot(dropWidget, pointerWidget, rawPointerWidget, pointerPosition)
	if not pointerWidget and self.listPetHomeUList then
		local pointerInHomeList = false

		if rawPointerWidget then
			local pointerTransform = rawPointerWidget.transform
			local listTransform = self.listPetHomeUList.transform

			if pointerTransform and listTransform then
				local currentTransform = pointerTransform

				while currentTransform ~= nil and currentTransform ~= listTransform do
					currentTransform = currentTransform.parent
				end

				pointerInHomeList = currentTransform == listTransform
			end
		end

		if not pointerInHomeList and pointerPosition then
			pointerInHomeList = CS.UnityEngine.RectTransformUtility.RectangleContainsScreenPoint(self.listPetHomeUList.rectTransform, pointerPosition, CS.XGUI.UWidget.uiCamera)
		end

		if pointerInHomeList then
			pointerWidget = self.listPetHomeUList
		end
	end

	if pointerWidget then
		local targetAreaId = self:getDropAreaId(pointerWidget)
		local targetName = pointerWidget.gameObject.name
		local info = string.split(targetName, self.model.HOME_SPLIT)

		if info[1] == self.model.HOME_TAG or targetAreaId ~= nil then
			local player = pg.me

			if not player then
				return
			end

			local slotIdx = info[2]

			if targetAreaId ~= nil then
				slotIdx = nil

				if not HomeLandUtils.canUseHomePetBoxArea(pg.space, targetAreaId) then
					pg.global.showBubbleMessage(NoticeDef.HOME_CAMP_WORLD_LOCKED)

					return
				end
			else
				targetAreaId = self.currentAreaId
			end

			local objectReference = dropWidget:GetComponent("ObjectReference")
			local petIdRectTransform = objectReference:GetRefValue("petIdRectTransform")
			local petId = petIdRectTransform.name
			local petPrepareInfoList = player.petPrepareList or {}
			local prepareFormationList = player.prepareFormationList
			local exploreFormation = prepareFormationList and prepareFormationList[1] and prepareFormationList[1].exploreFormation or {}
			local isCombatPet = lume.find(petPrepareInfoList, petId) ~= nil
			local isExplore = lume.find(exploreFormation, petId) ~= nil
			local isInRogue = RogueUtils.isPetInRogue(petId)

			if isInRogue then
				pg.global.ui.tips:showTextTip(pg.getGameString("PET_IN_ROGUE_BATTLE"))
			elseif isCombatPet or isExplore then
				pg.global.showConfirmMsgRaw(pg.getGameString("RELEASE_WARN"), pg.getGameString("HOME_BATTLE_PET_REMOVE_CHECK"), function()
					pg.me.space:addHomelandPet(petId, tonumber(slotIdx), targetAreaId)
				end)
			else
				pg.me.space:addHomelandPet(petId, tonumber(slotIdx), targetAreaId)
			end
		end
	end
end

function HomelandPetBoxComponent:showPetInfo(button, data, isRightSide)
	if self.inBatchMode then
		button.enabledTooltip = false

		return
	end

	self:savePetManagementState()

	if self.petTipPopupForm and self.petTipPanelTransform then
		local anchor = isRightSide and self.rightPetTipAnchor or self.leftPetTipAnchor

		if not anchor then
			return
		end

		self.focusWishingStarOnPetTipOpen = pg.game.input and pg.game.input:isUsingGamepad()
		self.wishingStarFocusButton = nil

		PetManagementUtils.initSimpleInfoTemplate(self.petTipPanelTransform, {
			defaultSelectTabIndex = 2,
			owner = self,
			isForbidPetPropUseBtn = not isRightSide,
			subDisplayType = UIConst.PET_SLOT_DISPLAY_TYPE.Homeland,
			uiScene = self.ctrl.uiScene,
			filterType = UIConst.PET_SLOT_DISPLAY_TYPE.Homeland
		})
		PetManagementUtils.showPetInfo(data)
		self.petTipPopupForm:SetActive(true)
		self.petTipPopupForm:SetModal(true)
		self.petTipPopupForm:SetPadding(40)
		self.petTipPopupForm:SetAutoVertical(false, true)
		self.petTipPopupForm:OpenPopup(anchor:GetComponent("RectTransform"), true)
		self.petTipPopupForm:SetAutoClose(true)

		function self.petTipPopupForm.luaCloseAction()
			self.focusWishingStarOnPetTipOpen = nil
			self.wishingStarFocusButton = nil

			self.petTipPopupForm:SetActive(false)
		end

		if self.focusWishingStarOnPetTipOpen then
			self.ctrl:scheduleGamepadFocus(function()
				if NotNil(self.wishingStarFocusButton) then
					return self.wishingStarFocusButton
				end

				return button
			end)
		else
			CS.XGUI.Navigation.NavManager.Instance:FocusItem(button)
		end

		return
	end

	function button.luaRenderTooltip(btn, cmp)
		local objectReference = cmp:GetComponent("ObjectReference")
		local panelTransform = objectReference:GetRefValue("panelTransform")

		PetManagementUtils.initSimpleInfoTemplate(panelTransform, {
			defaultSelectTabIndex = 2,
			owner = self,
			isForbidPetPropUseBtn = not isRightSide,
			subDisplayType = UIConst.PET_SLOT_DISPLAY_TYPE.Homeland,
			uiScene = self.ctrl.uiScene,
			filterType = UIConst.PET_SLOT_DISPLAY_TYPE.Homeland
		})
		PetManagementUtils.showPetInfo(data)

		objectReference = panelTransform:GetComponent("ObjectReference")
	end

	function button.luaTooltipPopup(_, isOpen)
		if not isOpen then
			PetManagementUtils.clearAbilityUContainerObjects()
			PetManagementUtils.clearInfoUContainerObjects()
			PetManagementUtils.clearPetAttributeTimer()
		end
	end

	button:SetPopupValidateTouch(function()
		return not pg.global.ui.petGiftTips:checkUIVisible()
	end)

	button.enabledTooltip = true

	button:OpenTooltip()
end

function HomelandPetBoxComponent:onClickPetHead(button, data)
	if self.inBatchMode then
		button.enabledTooltip = false

		local petId = data.id

		if not self.mulToPutIn[petId] then
			local ret = self:tryAddSelectPetToPutIn(petId, true)

			if ret then
				button:TryChangePage("Batch", 1)
			end
		else
			self.mulToPutIn[petId] = nil

			button:TryChangePage("Batch", 0)

			self.btnPutInAllSelected.isSelected = false
		end

		self:refreshBatchPutInSelectCount()
		self:preMovePetsToHome()
	else
		self:showPetInfo(button, data, true)
	end

	self:deSelectAllHomePets()
end

function HomelandPetBoxComponent:petSlotEnterDropWidget(petId, targetWidget)
	if not targetWidget then
		return
	end

	local targetAreaId = self:getDropAreaId(targetWidget)

	if targetAreaId ~= nil then
		if not HomeLandUtils.canUseHomePetBoxArea(pg.space, targetAreaId) then
			self:refreshAreaTabState()

			return
		end

		self.ctrl:switchPetArea(targetAreaId)

		if targetAreaId == Const.HOMELAND_AREA_TYPE.PRODUCE then
			self:tryMovePetToHome({
				petId
			})
		end

		return
	end

	local targetName = targetWidget.gameObject.name
	local info = string.split(targetName, self.model.HOME_SPLIT)

	if info[1] == self.model.HOME_TAG then
		self:tryMovePetToHome({
			petId
		}, tonumber(info[2]))
	end
end

function HomelandPetBoxComponent:enterBatchPutIn()
	self.inBatchMode = true
	self.batchMode = HomelandPetBoxComponent.BATCH_MODE.PUT_IN

	self.uWidget.content:TryChangePage("PutMove", 1)

	self.mulToPutIn = {}

	self:refreshBatchPutInSelectCount()
	PetManagementUtils.clearBatchSelect()

	self.btnPutInAllSelected.isSelected = false

	self.ctrl:refreshConsoleBarState()
end

function HomelandPetBoxComponent:confirmBatchPutIn()
	local petIds = {}
	local player = pg.me

	if not player then
		return
	end

	local hasCombatPet = false
	local hasExplore = false
	local petPrepareInfoList = player.petPrepareList or {}
	local prepareFormationList = player.prepareFormationList
	local exploreFormation = prepareFormationList and prepareFormationList[1] and prepareFormationList[1].exploreFormation or {}

	for petId, _ in pairs(self.mulToPutIn) do
		if not player:checkHomelandAddPet(petId) then
			player.space:onAddHomelandPetCallback(Const.HOMELAND_PET_OP_RETURN_CODE.ERROR_CHECK_FAIL, petId)
		elseif RogueUtils.isPetInRogue(petId) then
			pg.global.ui.tips:showTextTip(pg.getGameString("PET_IN_ROGUE_BATTLE"))
		else
			petIds[#petIds + 1] = petId
			hasCombatPet = hasCombatPet or lume.find(petPrepareInfoList, petId) ~= nil
			hasExplore = hasExplore or lume.find(exploreFormation, petId) ~= nil
		end
	end

	if #petIds > 0 then
		if hasCombatPet or hasExplore then
			pg.global.showConfirmMsgRaw(pg.getGameString("RELEASE_WARN"), pg.getGameString("HOME_BATTLE_PET_REMOVE_CHECK"), function()
				pg.me.space:addHomelandPetBatch(petIds, self.currentAreaId)
			end, false)
		else
			pg.me.space:addHomelandPetBatch(petIds, self.currentAreaId)
		end
	end
end

function HomelandPetBoxComponent:refreshBatchPutInSelectCount()
	local camMoveCount = self:getRemainingPetCapacity()
	local selectCount = 0

	for petId, _ in pairs(self.mulToPutIn) do
		selectCount = selectCount + 1
	end

	local countText = string.format("%d/%d", selectCount, camMoveCount)

	ClientTextUtils.setText(self.putInCount, ClientTextUtils.concatByLanguage(pg.getGameString("HOME_PET_PUT_IN_DESC"), countText))
end

function HomelandPetBoxComponent:exitBatchPutIn()
	self.inBatchMode = false
	self.batchMode = HomelandPetBoxComponent.BATCH_MODE.NONE

	self.uWidget.content:TryChangePage("PutMove", 0)

	self.mulToPutIn = {}

	PetManagementUtils.clearBatchSelect()
	PetManagementUtils.setSelectedPet(0)
	self:refreshAbilityList()
	self.ctrl:refreshConsoleBarState()
end

function HomelandPetBoxComponent:selectAllHomePets()
	for idx = 1, pg.space.petBoxMap:getSlotCount() do
		local petId = pg.space.petBoxMap:getPetId(self.currentAreaId, idx)

		if petId then
			local ret, button = self.listPetHomeUList:TryGetChildAt(idx - 1)

			if ret then
				local data = self.listPetHomeUList:GetData(button)

				data.selected = true
				self.mulToMoveOut[petId] = true

				button:TryChangePage("Batch", 1)
			end
		end
	end

	self:calMoveOutBatchCount()
end

function HomelandPetBoxComponent:deSelectAllHomePets()
	self.mulToMoveOut = {}

	self.listPetHomeUList:DeselectAll()
	self.listPetHomeUList:RefreshList()
end

function HomelandPetBoxComponent:enterBatchPutOut()
	self.inBatchMode = true
	self.batchMode = HomelandPetBoxComponent.BATCH_MODE.MOVE_OUT

	self.uWidget.content:TryChangePage("PutMove", 2)

	self.mulToMoveOut = {}

	self:deSelectAllHomePets()
	self:calMoveOutBatchCount()

	self.btnMoveOutSelectAll.isSelected = false

	self.ctrl:refreshConsoleBarState()
end

function HomelandPetBoxComponent:exitBatchMoveOut()
	self.inBatchMode = false
	self.batchMode = HomelandPetBoxComponent.BATCH_MODE.NONE

	self.uWidget.content:TryChangePage("PutMove", 0)

	self.listPetHomeUList.groupType = CS.XGUI.EGroupType.Radio

	self:deSelectAllHomePets()
	self:refreshAbilityList()
	self.listPetHomeUList:RefreshList()
	self.ctrl:refreshConsoleBarState()
end

function HomelandPetBoxComponent:confirmBatchMoveOut()
	local finalPets = {}

	for petId, _ in pairs(self.mulToMoveOut) do
		finalPets[#finalPets + 1] = petId
	end

	if #finalPets <= 0 then
		return
	end

	local remainSlots = pg.me.petBoxMap:getValidEmptySlot() or 0

	if remainSlots < #finalPets then
		pg.global.showBubbleMessage(NoticeDef.PET_BAG_FULL)

		return
	end

	pg.me.space:removeHomelandPetBatch(finalPets, -1, self.currentAreaId)
end

function HomelandPetBoxComponent:onPetSelectChange(isSelect, petId)
	if isSelect then
		self.mulToMoveOut[petId] = true
	else
		self.mulToMoveOut[petId] = nil
		self.btnMoveOutSelectAll.isSelected = false
	end

	self:calMoveOutBatchCount()
end

function HomelandPetBoxComponent:calMoveOutBatchCount()
	local finalIds = {}

	for pId, _ in pairs(self.mulToMoveOut) do
		finalIds[#finalIds + 1] = pId
	end

	local selectCount = #finalIds

	self:tryMoveHomePetToNormal(finalIds)

	self.moveOutCount.text = ClientTextUtils.concatByLanguage(pg.getGameString("HOME_PET_MOVE_OUT_DESC"), selectCount)
end

function HomelandPetBoxComponent:resetHomePetDragSourcePreview()
	local sourceButton = self.homePetDragSourceButton

	if IsNil(sourceButton) then
		return
	end

	local objectReference = sourceButton:GetComponent("ObjectReference")
	local visualRootUWidget = objectReference:GetRefValue("visualRootUWidget")
	local dragEmptyPreviewUImage = objectReference:GetRefValue("dragEmptyPreviewUImage")

	if NotNil(visualRootUWidget) then
		visualRootUWidget:SetActive(true)
	end

	if NotNil(dragEmptyPreviewUImage) then
		dragEmptyPreviewUImage:SetActive(false)
	end
end

function HomelandPetBoxComponent:showHomePetDragEmptyPreview(slotIdx)
	local sourceButton = self.homePetDragSourceButton

	if IsNil(sourceButton) then
		return false
	end

	local objectReference = sourceButton:GetComponent("ObjectReference")
	local visualRootUWidget = objectReference:GetRefValue("visualRootUWidget")
	local dragEmptyPreviewUImage = objectReference:GetRefValue("dragEmptyPreviewUImage")

	if IsNil(visualRootUWidget) or IsNil(dragEmptyPreviewUImage) then
		return false
	end

	sourceButton.name = self.model.HOME_TAG .. self.model.HOME_SPLIT .. slotIdx

	visualRootUWidget:SetActive(false)
	dragEmptyPreviewUImage:SetActive(true)

	return true
end

function HomelandPetBoxComponent:clearHomePetDragState(deferSourcePreviewReset)
	self.homePetDragToken = (self.homePetDragToken or 0) + 1
	self.appearanceDistributionInfo = nil
	self.draggingHomePetInfo = nil
	self.homePetDragSourceIndex = nil
	self.homePetDragListAreaId = nil

	if not deferSourcePreviewReset then
		self:resetHomePetDragSourcePreview()

		self.homePetDragSourceButton = nil
	end

	self.homePetDragReplicaWidget = nil
	self.homePetDragReplicaIconUImage = nil
end

function HomelandPetBoxComponent:beginHomePetDrag(button, idx, data)
	self:clearHomePetDragState()

	self.draggingHomePetInfo = {
		id = data.id,
		inFacility = data.inFacility
	}
	self.homePetDragSourceIndex = idx
	self.homePetDragListAreaId = data.areaId
	self.homePetDragSourceButton = button
	self.homePetDragReplicaWidget = button.replicaWidget

	local replicaWidget = self.homePetDragReplicaWidget

	if IsNil(replicaWidget) then
		return
	end

	local objectReference = replicaWidget:GetComponent("ObjectReference")
	local replicaIconUImage = objectReference and objectReference:GetRefValue("iconUImage")

	if IsNil(replicaIconUImage) then
		return
	end

	local dragToken = self.homePetDragToken
	local iconUrl = LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_ICON, data.label, data.gender)

	self.homePetDragReplicaIconUImage = replicaIconUImage
	replicaIconUImage.renderOpacity = 0
	replicaIconUImage.url = nil

	replicaIconUImage:SetUrlWithCallback(iconUrl, function()
		self:showHomePetDragReplica(dragToken, replicaWidget)
	end, function()
		self:showHomePetDragReplica(dragToken, replicaWidget)
	end)
end

function HomelandPetBoxComponent:showHomePetDragReplica(dragToken, replicaWidget)
	if not self.ctrl then
		return
	end

	self.ctrl:startFrameTimer(function()
		if self.homePetDragToken ~= dragToken or self.homePetDragReplicaWidget ~= replicaWidget or IsNil(replicaWidget) or IsNil(self.homePetDragReplicaIconUImage) or CS.XGUI.UComponent.rawDraggingWidget ~= self.homePetDragSourceButton then
			return
		end

		self.homePetDragReplicaIconUImage.renderOpacity = 1
	end, 1)
end

function HomelandPetBoxComponent:endHomePetDrag(dropWidget)
	local petInfo = self.draggingHomePetInfo

	if petInfo then
		petInfo.listAreaId = self.homePetDragListAreaId
	end

	local targetAreaId = self:getDropAreaId(dropWidget)
	local shouldSwitchArea = targetAreaId ~= nil and targetAreaId ~= self.currentAreaId and HomeLandUtils.canUseHomePetBoxArea(pg.space, targetAreaId)
	local shouldRefreshList = self.homePetListRefreshPending or shouldSwitchArea
	local canScheduleRefresh = shouldRefreshList and self.ctrl ~= nil and NotNil(self.listPetHomeUList)

	self:clearHomePetDragState(canScheduleRefresh)

	if petInfo then
		self:dragHomePetEnd(petInfo, dropWidget)
	end

	if not canScheduleRefresh then
		return
	end

	local dragToken = self.homePetDragToken

	self.ctrl:startFrameTimer(function()
		if self.homePetDragToken ~= dragToken or self.draggingHomePetInfo or not self.listPetHomeUList then
			return
		end

		self:resetHomePetDragSourcePreview()

		self.homePetDragSourceButton = nil

		if shouldSwitchArea then
			self.ctrl:switchPetArea(targetAreaId)
		elseif self.homePetListRefreshPending then
			self:refreshHomePetList()
		end
	end, 1)
end

function HomelandPetBoxComponent:renderPetList(button, idx, data)
	button.enabledTooltip = false

	local objectReference = button:GetComponent("ObjectReference")
	local visualRootUWidget = objectReference and objectReference:GetRefValue("visualRootUWidget")
	local dragEmptyPreviewUImage = objectReference and objectReference:GetRefValue("dragEmptyPreviewUImage")

	if NotNil(visualRootUWidget) then
		visualRootUWidget:SetActive(true)
	end

	if NotNil(dragEmptyPreviewUImage) then
		dragEmptyPreviewUImage:SetActive(false)
	end

	if data.tIndex == 1 then
		button.draggable = false
		button.interactable = false
		button.luaBeginDrag = nil
		button.luaEndDrag = nil
	elseif data.tIndex == 0 then
		button.draggable = true

		LuaUIUtils.renderHomePetHead(button, data, nil, {
			showAppearanceTags = data.areaId == Const.HOMELAND_AREA_TYPE.BUILD,
			hideWorkState = data.areaId == Const.HOMELAND_AREA_TYPE.BUILD,
			showEventState = data.areaId == Const.HOMELAND_AREA_TYPE.BUILD
		})

		function button.luaBeginDrag()
			self:beginHomePetDrag(button, idx, data)
		end

		function button.luaEndDrag(dropWidget)
			self:endHomePetDrag(dropWidget)
		end

		button.interactable = true
	end

	button.dropable = true
	button.name = self.model.HOME_TAG .. self.model.HOME_SPLIT .. data.slotIdx
	button.dynamicUpdateDropWidget = true

	function button.luaEnterDropWidget(target)
		local petInfo = self.draggingHomePetInfo

		if petInfo then
			self:onPetEnterDrop(petInfo.id, target)
		end
	end

	function button.luaExitDropWidget()
		self:refreshAbilityList()
	end

	button:TryChangePage("Batch", 0)

	if self.inBatchMode then
		local petId = data.id

		if self.mulToMoveOut[petId] then
			button:TryChangePage("Batch", 1)
		end
	end
end

function HomelandPetBoxComponent:onPetEnterDrop(petId, targetUWidget)
	if not targetUWidget then
		return
	end

	local targetAreaId = self:getDropAreaId(targetUWidget)

	if targetAreaId ~= nil then
		if not HomeLandUtils.canUseHomePetBoxArea(pg.space, targetAreaId) then
			self:refreshAreaTabState()

			return
		end

		local sourceAreaId = HomeLandUtils.getHomePetAreaId(pg.space, petId)

		if sourceAreaId == nil then
			return
		end

		if self.draggingHomePetInfo and self.filtering and targetAreaId ~= self.currentAreaId then
			return
		end

		self.ctrl:switchPetArea(targetAreaId)

		if targetAreaId == Const.HOMELAND_AREA_TYPE.PRODUCE and sourceAreaId ~= targetAreaId then
			self:tryMovePetToHome({
				petId
			})
		end

		return
	end

	local targetName = targetUWidget.gameObject.name
	local slotId = tonumber(targetName)

	if slotId then
		self:tryMoveHomePetToNormal({
			petId
		}, slotId)
	end
end

function HomelandPetBoxComponent:refreshHomePetList()
	local homePetDatas = self:getHomePetsBoxInfo()
	local sourceIndex = self.homePetDragSourceIndex
	local isDraggingHomePet = self.draggingHomePetInfo and sourceIndex ~= nil and NotNil(self.homePetDragSourceButton) and CS.XGUI.UComponent.rawDraggingWidget == self.homePetDragSourceButton

	if isDraggingHomePet then
		self.homePetListRefreshPending = true

		if self.filtering or self.listPetHomeUList.itemCount ~= #homePetDatas or sourceIndex >= #homePetDatas then
			return
		end

		local sourceData = homePetDatas[sourceIndex + 1]

		if sourceData.tIndex == 1 then
			if not self:showHomePetDragEmptyPreview(sourceData.slotIdx) then
				return
			end
		else
			self:resetHomePetDragSourcePreview()
		end

		self.homePetDragListAreaId = self.currentAreaId

		local needsSiblingReorder = false

		for dataIndex = #homePetDatas, 1, -1 do
			local data = homePetDatas[dataIndex]
			local listIndex = dataIndex - 1

			if listIndex ~= sourceIndex or sourceData.tIndex ~= 1 then
				if not needsSiblingReorder then
					local currentData = self.listPetHomeUList:GetData(listIndex)

					needsSiblingReorder = not currentData or currentData.tIndex ~= data.tIndex
				end

				self.listPetHomeUList:SetElement(listIndex, data)
			end
		end

		if needsSiblingReorder then
			for listIndex = 0, #homePetDatas - 1 do
				local success, button = self.listPetHomeUList:TryGetChildAt(listIndex)

				if success and NotNil(button) then
					button.transform:SetAsLastSibling()
				end
			end
		end

		return
	end

	if self.draggingHomePetInfo then
		self:clearHomePetDragState()
	elseif self.homePetDragSourceButton then
		self:resetHomePetDragSourcePreview()

		self.homePetDragSourceButton = nil
	end

	self.homePetListRefreshPending = false

	self.listPetHomeUList:SetList(homePetDatas)
end

function HomelandPetBoxComponent:tryMovePetToHome(petIds, slotIdx)
	local count = #petIds

	if count <= 0 then
		return
	end

	local pets = pg.me.pets
	local finalCountInfo = {}

	for _, petId in ipairs(petIds) do
		local pet = pets[petId]

		if pet then
			self:calPetHomeAbilityCount(pet, finalCountInfo, true)
		end
	end

	if count == 1 and slotIdx then
		local petId = pg.space.petBoxMap:getPetId(self.currentAreaId, slotIdx)
		local pet = pets[petId]

		if pet then
			self:calPetHomeAbilityCount(pet, finalCountInfo, false)
		end
	end

	self:tipAbilityCount(finalCountInfo)
end

function HomelandPetBoxComponent:tryMoveHomePetToNormal(petIds, slotIdx)
	local count = #petIds

	if count <= 0 then
		return
	end

	local pets = pg.me.pets
	local finalCountInfo = {}

	for _, petId in ipairs(petIds) do
		local pet = pets[petId]

		if pet then
			self:calPetHomeAbilityCount(pet, finalCountInfo, false)
		end
	end

	if count == 1 and slotIdx then
		local boxId = PetManagementDataHelper.getSelectBoxId()
		local petBox = pg.me.petBoxMap[boxId]
		local petId = petBox[slotIdx]
		local pet = pets[petId]

		if pet then
			self:calPetHomeAbilityCount(pet, finalCountInfo, true)
		end
	end

	self:tipAbilityCount(finalCountInfo)
end

function HomelandPetBoxComponent:tipAbilityCount(countInfo)
	if self.currentAreaId ~= Const.HOMELAND_AREA_TYPE.PRODUCE then
		return
	end

	for aId, finalCount in pairs(countInfo) do
		local abilityItem = self.abilityBtn[aId]

		if abilityItem then
			local btn, txt = unpack(abilityItem)
			local data = self.listElementQuantityUList:GetData(btn)
			local projectedCount = data.count + finalCount
			local activePage, textStyle = HomelandPetBoxComponent.getAbilityDisplayState(projectedCount, data.requirement)

			ClientTextUtils.setText(txt, string.format("<style=%s>%s</style>", textStyle, projectedCount))
			btn:TryChangePage("Active", activePage)
		end
	end
end

function HomelandPetBoxComponent:calPetHomeAbilityCount(pet, info, isAdd)
	if pet and self.currentAreaId == Const.HOMELAND_AREA_TYPE.PRODUCE then
		local addTemplate = pet.templateId
		local petData = PetData[addTemplate]
		local homeAbility = petData and petData.homeAbility

		if homeAbility then
			for id, _ in pairs(homeAbility) do
				if not info[id] then
					info[id] = isAdd and 1 or -1
				else
					info[id] = isAdd and info[id] + 1 or info[id] - 1
				end
			end
		end
	end
end

function HomelandPetBoxComponent:getAppearanceDistributionInfo()
	if self.appearanceDistributionInfo then
		return self.appearanceDistributionInfo
	end

	local result = {}
	local distributionMap = {}

	for id, rule in pairs(HomeLandUtils.getHomeVoucherAppearanceRules()) do
		local appearanceType = rule.appearanceType
		local appearanceValue = rule.appearanceValue
		local labelUrl, tagData, nameTextId, nameKey
		local isValidDisplayRule = true

		if appearanceType == HomelandPetBoxComponent.APPEARANCE_TYPE.FORM_QUALITY then
			labelUrl = AddressDataConst.UI_NODE_PET_TAG_FORM_NEW
			tagData = {
				tIndex = 0,
				formQuality = appearanceValue,
				iconSmall = rule.icon,
				iconBg = rule.iconBg
			}
			nameTextId = HomelandPetBoxComponent.getFormQualityNameTextId(appearanceValue)

			if not nameTextId then
				HomeLandUtils.logInvalidHomeVoucherAppearanceRule(id, "missing_form_quality_name", appearanceValue)

				isValidDisplayRule = false
			end
		elseif appearanceType == HomelandPetBoxComponent.APPEARANCE_TYPE.SHINY then
			labelUrl = AddressDataConst.UI_NODE_PET_TAG_FLASH
			tagData = {
				shinyIndex = 0,
				tIndex = 1,
				label = Const.PET_LABEL_MASK.SHINY,
				labelMask = Const.PET_LABEL_MASK.SHINY
			}

			if not string.isNilOrEmpty(rule.icon) then
				labelUrl = AddressDataConst.UI_NODE_PET_TAG_FORM_NEW
				tagData.iconSmall = rule.icon
				tagData.iconBg = rule.iconBg
			end

			nameKey = "PET_SHINY_LABEL_TITLE"
		else
			isValidDisplayRule = false
		end

		if isValidDisplayRule then
			local distributionKey = tostring(appearanceType) .. "_" .. tostring(appearanceValue)
			local distribution = {
				count = 0,
				id = id,
				appearanceType = appearanceType,
				appearanceValue = appearanceValue,
				tagData = tagData,
				labelUrl = labelUrl,
				nameTextId = nameTextId,
				nameKey = nameKey,
				multiplier = rule.rate,
				sortKey = rule.sort,
				icon = rule.icon,
				iconSmall = rule.iconSmall,
				iconBg = rule.iconBg
			}

			distributionMap[distributionKey] = distribution
			result[#result + 1] = distribution
		end
	end

	table.sort(result, HomelandPetBoxComponent.sortAppearanceDistribution)

	local pets = pg.me and pg.me.pets or {}
	local petBoxMap = pg.space and pg.space.petBoxMap

	if not petBoxMap then
		return result
	end

	for slotIndex = 1, petBoxMap:getSlotCount() do
		local petId = petBoxMap:getPetId(self.currentAreaId, slotIndex)
		local pet = petId and pets[petId]

		if pet then
			for _, appearanceInfo in ipairs(HomeLandUtils.getHomeVoucherAppearanceInfos(pet)) do
				local distributionKey = tostring(appearanceInfo.appearanceType) .. "_" .. tostring(appearanceInfo.appearanceValue)
				local distribution = distributionMap[distributionKey]

				if distribution then
					distribution.count = distribution.count + 1
				end
			end
		end
	end

	self.appearanceDistributionInfo = result

	return result
end

function HomelandPetBoxComponent:renderAppearanceList(button, data)
	function button.luaClick()
		self:openAppearanceAbilityPopup()
	end

	local objectReference = button:GetComponent("ObjectReference")
	local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	local formUContainer = objectReference:GetRefValue("formUContainer")

	ClientTextUtils.setText(txtNumUSDFText, data.count)
	button:TryChangePage("Active", data.count > 0 and 1 or 0)
	formUContainer:SetUrlWithCallback(data.labelUrl, function(content)
		if not content or button.dataFromUList ~= data then
			return
		end

		content.enabledTooltip = false

		LuaUIUtils.renderPetTagList(content, data.tagData)
	end)
end

function HomelandPetBoxComponent:refreshAbilityList()
	local isProduceArea = not self.regionUIReady or self.currentAreaId == Const.HOMELAND_AREA_TYPE.PRODUCE

	self:refreshWishingStarOutput()

	self.abilityBtn = {}

	self.listElementQuantityUList:SetActive(isProduceArea)

	if self.listPetAppearanceUList then
		self.listPetAppearanceUList:SetActive(not isProduceArea)
	end

	if self.btnAbilityInfoUButton then
		self.btnAbilityInfoUButton:SetActive(true)
	end

	if self.btnAbilityInfoKeyUContainer and self.btnAbilityInfoKeyUContainer.activeCtrlValid then
		self.btnAbilityInfoKeyUContainer:RefreshActiveCtrl()
	end

	if self.txtAbilityDistributionTitleUSDFText then
		local title = isProduceArea and self.defaultAbilityDistributionTitle or pg.getGameString("HOME_PET_APPEARANCE_DISTRIBUTION")

		ClientTextUtils.setText(self.txtAbilityDistributionTitleUSDFText, title)
	end

	if not isProduceArea then
		self.listElementQuantityUList:SetList({})
		self.listPetAppearanceUList:SetList(self:getAppearanceDistributionInfo())

		return
	end

	if self.listPetAppearanceUList then
		self.listPetAppearanceUList:SetList({})
	end

	if not self.abilityRequirementInfo then
		self.abilityRequirementInfo = HomeLandUtils.getHomeAbilityRequirement(pg.space)
	end

	local abilityInfo = {}

	for id, info in pairs(HomeAbilityData) do
		local item = {}

		item.id = id
		item.icon = info.icon
		item.iconColor = info.iconColor
		item.count = self:getAbilityPetCount(id)
		item.requirement = self.abilityRequirementInfo[id] or 0
		abilityInfo[#abilityInfo + 1] = item
	end

	table.sort(abilityInfo, HomelandPetBoxComponent.sortAbilityInfo)
	self.listElementQuantityUList:SetList(abilityInfo)
end

function HomelandPetBoxComponent:refreshWishingStarOutput()
	local isBuildArea = self.regionUIReady and self.currentAreaId == Const.HOMELAND_AREA_TYPE.BUILD

	if self.wishingStarULayoutBox then
		self.wishingStarULayoutBox:SetActive(isBuildArea)
	end

	if not isBuildArea or not self.txtWishingStarOutputUSDFText then
		return
	end

	local outputPerDay = 0
	local space = pg.space
	local petBoxMap = space.petBoxMap
	local buildBoxInfo = petBoxMap and petBoxMap[Const.HOMELAND_AREA_TYPE.BUILD]

	if buildBoxInfo then
		for _, petId in buildBoxInfo:items() do
			local petInfo = space.pets and space.pets[petId]

			if petInfo then
				local _, petOutputPerDay = HomeLandUtils.calcHomeVoucherPetOutputPerDay(petInfo)

				outputPerDay = outputPerDay + petOutputPerDay
			end
		end
	end

	ClientTextUtils.setText(self.txtWishingStarOutputUSDFText, LuaUIUtils.formatHomeWishingStarOutput(outputPerDay))
end

function HomelandPetBoxComponent:invalidateAbilityRequirement()
	self.abilityRequirementInfo = nil

	local isProduceArea = not self.regionUIReady or self.currentAreaId == Const.HOMELAND_AREA_TYPE.PRODUCE

	if isProduceArea and self.listElementQuantityUList then
		self:refreshAbilityList()
	end
end

function HomelandPetBoxComponent:getAbilityPetCount(abilityId)
	return self.abilityCountInfo[abilityId] or 0
end

function HomelandPetBoxComponent:dragHomePetEnd(petInfo, dropWidget)
	local petId = petInfo.id

	if not petId then
		return
	end

	if not dropWidget then
		return
	end

	local targetAreaId = self:getDropAreaId(dropWidget)

	if targetAreaId ~= nil then
		local sourceAreaId = HomeLandUtils.getHomePetAreaId(pg.space, petId)

		if sourceAreaId == nil then
			return
		end

		if targetAreaId == sourceAreaId then
			return
		end

		if not HomeLandUtils.canUseHomePetBoxArea(pg.space, targetAreaId) then
			pg.global.showBubbleMessage(NoticeDef.HOME_CAMP_WORLD_LOCKED)

			return
		end

		pg.me.space:updateHomelandPetIndex(petId, nil, targetAreaId)

		return
	end

	local targetName = dropWidget.gameObject.name
	local info = string.split(targetName, self.model.HOME_SPLIT)

	if info[1] == self.model.HOME_TAG then
		local slotIdx = info[2]

		pg.me.space:updateHomelandPetIndex(petId, tonumber(slotIdx), petInfo.listAreaId or self.currentAreaId)
	else
		local slotId = tonumber(targetName)

		if slotId then
			local boxId = PetManagementDataHelper.getSelectBoxId()

			if PetManagementUtils.inFilterMode then
				local targetData = dropWidget.dataFromUList

				if not targetData then
					return
				end

				if targetData.id then
					boxId, slotId = pg.me.petBoxMap:getPetIndex(targetData.id)

					if not boxId or not slotId then
						boxId = -1
						slotId = -1
					end
				elseif targetData.isEmpty then
					local remainSlots = pg.me.petBoxMap:getValidEmptySlot() or 0

					if remainSlots < 1 then
						pg.global.showBubbleMessage(NoticeDef.PET_BAG_FULL)
					else
						boxId = -1
						slotId = -1
					end
				else
					return
				end
			end

			if petInfo.inFacility then
				pg.global.showConfirmMsgRaw(pg.getGameString("RELEASE_WARN"), pg.getGameString("HOME_WORKING_PET_REMOVE_CHECK"), function()
					pg.me.space:removeHomelandPet(petId, boxId, slotId)
				end, false)
			else
				pg.me.space:removeHomelandPet(petId, boxId, slotId)
			end
		end
	end
end

function HomelandPetBoxComponent:renderAbilityList(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local imgBgImagePro = objectReference:GetRefValue("imgBgImagePro")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")

	iconUImage.url = data.icon

	imgBgImagePro:SetColorWithHtmlString(data.iconColor)

	local activePage, textStyle = HomelandPetBoxComponent.getAbilityDisplayState(data.count, data.requirement)

	button:TryChangePage("Active", activePage)
	ClientTextUtils.setText(txtNumUSDFText, string.format("<style=%s>%s</style>", textStyle, data.count))

	self.abilityBtn[data.id] = {
		button,
		txtNumUSDFText
	}

	function button.luaClick()
		self:openElementAbilityPopup()
	end
end

function HomelandPetBoxComponent:openElementAbilityPopup()
	pg.global.ui:open(UIConst.UI_ID_HOME_PET_ELEMENT_ABILITY, {
		abilityDistribution = self.abilityCountInfo,
		abilityRequirement = self.abilityRequirementInfo
	})
end

function HomelandPetBoxComponent:openAppearanceAbilityPopup()
	pg.global.ui:open(UIConst.UI_ID_HOME_PET_APPEARANCE_ABILITY, {
		appearanceAbilityList = self:getAppearanceDistributionInfo()
	})
end

function HomelandPetBoxComponent:openCurrentAbilityPopup()
	if self.regionUIReady and self.currentAreaId == Const.HOMELAND_AREA_TYPE.BUILD then
		self:openAppearanceAbilityPopup()

		return
	end

	self:openElementAbilityPopup()
end

function HomelandPetBoxComponent:refreshPetCount()
	local space = pg.me.space
	local petBoxMap = space and space.petBoxMap
	local produceCount = petBoxMap and petBoxMap:getAreaPetCount(Const.HOMELAND_AREA_TYPE.PRODUCE) or 0
	local buildCount = petBoxMap and petBoxMap:getAreaPetCount(Const.HOMELAND_AREA_TYPE.BUILD) or 0
	local totalCount = space and HomeLandUtils.getPetCurCount(space) or 0

	if self.regionUIReady then
		local produceAreaData = HomelandAreaData[Const.HOMELAND_AREA_TYPE.PRODUCE]
		local buildAreaData = HomelandAreaData[Const.HOMELAND_AREA_TYPE.BUILD]
		local produceAreaTitle = produceAreaData and pg.getLocalizationText(produceAreaData.name) or ""
		local buildAreaTitle = buildAreaData and pg.getLocalizationText(buildAreaData.name) or ""

		ClientTextUtils.setText(self.txtProduceAreaUSDFText, produceAreaTitle .. " " .. produceCount)
		ClientTextUtils.setText(self.txtBuildAreaUSDFText, buildAreaTitle .. " " .. buildCount)
	end

	self.txtNumUSDFText.text = totalCount .. "/"
	self.txtTotalUSDFText.text = petBoxMap and petBoxMap:getSlotCount() or 0
end

function HomelandPetBoxComponent:getHomePetsBoxInfo()
	if self.filtering then
		PetManagementDataHelper.filterTempProcess(self.filter)
	end

	local recordFilter = self.filter and PetManagementDataHelper.recordFilter and PetManagementDataHelper.recordFilter[self.filter.filterType]
	local hasRatingFilter = PetManagementDataHelper.checkExposeFilter(recordFilter)
	local pets = pg.me.pets
	local allocation = pg.space.allocation
	local facility = pg.space.facility
	local ornament = pg.space.ornament
	local spacePets = pg.space.pets
	local homePets = {}
	local emptySlots = {}

	self.abilityCountInfo = {}

	for idx = 1, pg.space.petBoxMap:getSlotCount() do
		local petId = pg.space.petBoxMap:getPetId(self.currentAreaId, idx)
		local pet = petId and pets[petId]

		if not pet then
			if not self.filtering then
				homePets[idx] = {
					tIndex = 1,
					isEmpty = true,
					slotIdx = idx
				}
			else
				emptySlots[#emptySlots + 1] = {
					tIndex = 1,
					isEmpty = true,
					slotIdx = idx
				}
			end
		else
			if self.currentAreaId == Const.HOMELAND_AREA_TYPE.PRODUCE then
				local petData = PetData[pet.templateId]
				local homeAbility = petData and petData.homeAbility

				if homeAbility then
					for id in pairs(homeAbility) do
						self.abilityCountInfo[id] = (self.abilityCountInfo[id] or 0) + 1
					end
				end
			end

			local tempFilter = self.filtering and self.filter and Utils.deepCopyTable(self.filter) or nil

			if pet ~= nil and (not tempFilter or PetManagementDataHelper.checkPetValidByFilter(pet, tempFilter)) then
				local petInfo = PetManagementDataHelper.setUpPetInfo(pet)

				if petInfo.isEmpty then
					local emptyPetInfo = {
						tIndex = 1,
						isEmpty = true,
						slotIdx = idx
					}

					if self.filtering then
						emptySlots[#emptySlots + 1] = emptyPetInfo
					else
						homePets[idx] = emptyPetInfo
					end
				elseif not tempFilter or not petInfo.isCatchReportingStatus or not hasRatingFilter then
					petInfo.slotIdx = idx
					petInfo.areaId = self.currentAreaId
					petInfo.tIndex = 0

					local allocationInfo = self.currentAreaId == Const.HOMELAND_AREA_TYPE.PRODUCE and allocation[petId] or nil

					if allocationInfo then
						local ornamentId = allocationInfo.ornamentId
						local facilityInfo = facility[ornamentId]

						if facilityInfo and allocationInfo.opId ~= 0 and facilityInfo.facilityState == allocationInfo.opId then
							local operateData = HomelandOperateData[allocationInfo.opId]

							if operateData then
								petInfo.inFacility = true
								petInfo.opUrl = HomelandOperateData[allocationInfo.opId].workingIcon
							end
						end
					end

					local homePetInfo = spacePets[petId]
					local eventInfo = homePetInfo and homePetInfo:getHomeEventInfo(pg.space)

					if eventInfo then
						local eventType = HomeEventTextData[eventInfo.textId] and HomeEventTextData[eventInfo.textId].eventType

						if eventType then
							local eventTypeData = HomeEventTypeData[eventType]

							if eventTypeData then
								petInfo.eventUrl = eventTypeData.statusIcon
							end
						end
					end

					if self.filtering then
						homePets[#homePets + 1] = petInfo
					else
						homePets[idx] = petInfo
					end
				end
			end
		end
	end

	if self.filtering then
		homePets = PetManagementDataHelper.sortTableBySortConditions(homePets, PetManagementDataHelper.recordFilter[self.filter.filterType])

		if #emptySlots > 0 then
			for i, v in ipairs(emptySlots) do
				homePets[#homePets + 1] = v
			end
		end

		PetManagementDataHelper.filterTempProcess(self.filter, true)
	end

	return homePets
end

function HomelandPetBoxComponent:onFilterClick()
	pg.global.ui:open(UIConst.UI_ID_PET_MANAGEMENT_FILTER, {
		filterType = UIConst.PET_SLOT_DISPLAY_TYPE.Homeland,
		sortId = self.selectSortId or 0,
		isDescending = self.isDescending or true,
		filter = self.filter,
		doFilterCallback = function(filter, sortId, isDescending, showLabelInfo)
			self.filtering = true

			self.rightInfoUComponent:TryChangePage("State", 1)

			self.filter = filter
			self.selectSortId = sortId
			self.isDescending = isDescending

			self:refreshHomePetList()
		end
	})
end

function HomelandPetBoxComponent:onExitFilterClick()
	self.filtering = false

	self.rightInfoUComponent:TryChangePage("State", 0)
	PetManagementDataHelper.initFilter(self.filter)
	self:refreshHomePetList()
end

return HomelandPetBoxComponent
