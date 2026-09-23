-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AppearanceV2\\Component\\PetComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local lume = require("Core.Common.lume")
local logger = LoggerManager.getLogger("Avatar")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local RedDotConst = require("Const.RedDotConst")
local Const = require("Common.Const.Const")
local PlayableConst = require("Common.Const.PlayableConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local UIComponent = require("Guis.Helper.UIComponent")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local ClientModelUtils = require("Utils.ClientModelUtils")
local AppearanceEffectUtils = require("Utils.AppearanceEffectUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local SlotOptionComponent = require("Guis.Panels.AppearanceV2.Component.Common.SlotOptionComponent")
local SliderBubbleComponent = require("Guis.Panels.AppearanceV2.Component.Common.SliderBubbleComponent")
local AppearanceJewelryPetData = require("Data.appearance_jewelry_pet_data")
local AvatarAccessoryClassifyData = require("Data.Avatar.avatar_accessory_classify_data")
local ItemData = require("Data.item_data")
local AddressDataConst = require("Const.AddressDataConst")
local HotkeyConst = require("Const.HotkeyConst")
local EnergyMatchThemeData = require("Data.energy_match_theme_data")
local Utils = require("Common.Utils.Utils")
local EnergyMatchAccessoriesData = require("Data.energy_match_accessories_data")
local EnergyAccessoriesTagData = require("Data.energy_accessories_tag_data")
local PetData = require("Data.pet_data")
local PetConfigData = require("Data.pet_config_data")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local MessageName = require("Const.MessageName")
local NoticeDef = require("Common.NoticeDef")
local PetJewelryOssCache = require("Utils.PetJewelryOssCache")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local EffectConst = require("Const.EffectConst")
local PetComponent = Class.LightClass("PetComponent", UIComponent)

PetComponent.messages = {
	[MessageName.PET_BOX_SELECTED] = {
		"onPetBoxSelected"
	}
}
PetComponent.MAPPING_LENGTH = 200

local ADJUST_OPTION_TYPE = {
	SNAP_POINT = 3,
	ALL_POINTS = 2,
	LOCK_POINT = 1
}
local ATTACH_POINT_POSITION_EPSILON_SQR = 1e-06
local PET_ACCESSORY_HIGHLIGHT_DURATION = 3
local PET_ACCESSORY_HIGHLIGHT_VOLUME_PRIORITY = 7
local ADJUST_MODE_LIST = {
	{
		mode = 1,
		text = "APPEARANCE_PET_ACCESSORY_ADJUST_MODE_NORMAL",
		tIndex = 0
	},
	{
		mode = 2,
		text = "APPEARANCE_PET_ACCESSORY_ADJUST_MODE_ADVANCED",
		tIndex = 2
	}
}
local ADJUST_OPTION_LIST = {
	{
		text = "APPEARANCE_PET_ACCESSORY_SNAP_POINT",
		icon = 2,
		optionType = ADJUST_OPTION_TYPE.SNAP_POINT
	},
	{
		text = "APPEARANCE_PET_ACCESSORY_LOCK_POINT",
		icon = 1,
		optionType = ADJUST_OPTION_TYPE.LOCK_POINT
	},
	{
		text = "APPEARANCE_PET_ACCESSORY_ALL_POINTS",
		icon = 0,
		optionType = ADJUST_OPTION_TYPE.ALL_POINTS
	}
}

function PetComponent:onCtor(info)
	self.curPetId = info.petId

	local pInfo = pg.me:getPetInfo(self.curPetId)

	self.curTemplateId = pInfo and pInfo.templateId or nil
end

function PetComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.outfitUButton = self.objectReference:GetRefValue("outfitUButton")
	self.tabUList = self.objectReference:GetRefValue("tabUList")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.slotOptionTransform = self.objectReference:GetRefValue("slotOptionTransform")
	self.rightTransform = self.objectReference:GetRefValue("rightTransform")
	self.presetCloseUButton = self.objectReference:GetRefValue("presetCloseUButton")
	self.presetUButton = self.objectReference:GetRefValue("presetUButton")
	self.presetTitleUBaseText = self.objectReference:GetRefValue("presetTitleUBaseText")
	self.presetNumUBaseText = self.objectReference:GetRefValue("presetNumUBaseText")
	self.presetUList = self.objectReference:GetRefValue("presetUList")
	self.presetPartUList = self.objectReference:GetRefValue("presetPartUList")
	self.coverPresetUButton = self.objectReference:GetRefValue("coverPresetUButton")
	self.sourceUList = self.objectReference:GetRefValue("sourceUList")
	self.bubbleUComponent = self.objectReference:GetRefValue("bubbleUComponent")
	self.petBoxUButton = self.objectReference:GetRefValue("petBoxUButton")
	self.petBoxIconUImage = self.petBoxUButton.transform:Find("Mask/Icon"):GetComponent("UImage")
	self.bottomTabUComponent = self.objectReference:GetRefValue("bottomTabUComponent")
	self.accessoryUComponent = self.objectReference:GetRefValue("accessoryUComponent")
	self.txtNameUBaseText = self.objectReference:GetRefValue("txtNameUBaseText")
	self.txtDetailsUBaseText = self.objectReference:GetRefValue("txtDetailsUBaseText")
	self.btnCompleteUButton = self.objectReference:GetRefValue("btnCompleteUButton")
	self.tag1Text = self.objectReference:GetRefValue("tag1Text")
	self.tag2Text = self.objectReference:GetRefValue("tag2Text")
	self.textNumber1UBaseText = self.objectReference:GetRefValue("textNumber1UBaseText")
	self.textNumber2UBaseText = self.objectReference:GetRefValue("textNumber2UBaseText")
	self.textSumNumberUBaseText = self.objectReference:GetRefValue("textSumNumberUBaseText")
	self.tag1LabelUComponent = self.objectReference:GetRefValue("tag1LabelUComponent")
	self.tag2LabelUComponent = self.objectReference:GetRefValue("tag2LabelUComponent")
	self.btnTryInfoUButton = self.objectReference:GetRefValue("btnTryInfoUButton")
	self.sourceUList2 = self.objectReference:GetRefValue("sourceList2UList")
	self.useUWidget = self.objectReference:GetRefValue("useUWidget")
	self.tagInfoUButton = self.objectReference:GetRefValue("tagInfoUButton")
	self.btnAdjustUButton = self.objectReference:GetRefValue("btnAdjustUButton")
	self.btnFashionValueIcon2UButton = self.objectReference:GetRefValue("btnFashionValueIcon2UButton")
	self.scrollRectUScrollRect = self.objectReference:GetRefValue("scrollRectUScrollRect")
	self.btnAutoMatchUButton = self.objectReference:GetRefValue("btnAutoMatchUButton")
	self.txtCurAccessoryNum = self.objectReference:GetRefValue("txtCurAccessoryNum")
	self.txtTotalNum = self.objectReference:GetRefValue("txtTotalNum")
	self.listRecommendTagsUList = self.objectReference:GetRefValue("listRecommendTagsUList")
	self.txtBtnAutoMatchUButton = self.objectReference:GetRefValue("txtBtnAutoMatchUButton")
	self.txtCurAccessoryTitle = self.objectReference:GetRefValue("txtCurAccessoryTitle")
	self.txtTotalTitle = self.objectReference:GetRefValue("txtTotalTitle")
	self.txtFashionTitle = self.objectReference:GetRefValue("txtFashionTitle")
	self.txtTagTitle = self.objectReference:GetRefValue("txtTagTitle")
	self.txtTags = self.objectReference:GetRefValue("txtTags")
end

function PetComponent:registerObjects()
	local objectReference = self.rightTransform:GetComponent("ObjectReference")

	self.nameUText = objectReference:GetRefValue("nameUText")
	self.designUButton = objectReference:GetRefValue("designUButton")
	self.titleUButton = objectReference:GetRefValue("titleUButton")
	self.operationUList = objectReference:GetRefValue("operationUList")
	self.cancelUButton = objectReference:GetRefValue("cancelUButton")
	self.saveUButton = objectReference:GetRefValue("saveUButton")
	self.adjustUComponent = objectReference:GetRefValue("adjustUComponent")
	self.btnAllUnlockUButton = objectReference:GetRefValue("btnAllUnlockUButton")
	self.colorAccessoryCloseUButton = objectReference:GetRefValue("colorAccessoryCloseUButton")
	self.colorAccessoryUList = objectReference:GetRefValue("colorAccessoryUList")
	self.colorAccessoryUButton = objectReference:GetRefValue("colorAccessoryUButton")
	self.colorAccessorySourceUButton = objectReference:GetRefValue("colorAccessorySourceUButton")
	self.detailsUBaseText = objectReference:GetRefValue("detailsUBaseText")
	self.workshopUButton = objectReference:GetRefValue("workshopUButton")
	self.backwardUButton = objectReference:GetRefValue("backwardUButton")
	self.forwardUButton = objectReference:GetRefValue("forwardUButton")
	self.colorAccessoryNumUBaseText = objectReference:GetRefValue("colorAccessoryNumUBaseText")
	self.btnAdsorptionSiteUButton = objectReference:GetRefValue("btnAdsorptionSiteUButton")
	self.btnAdsorptionSiteUButtonText = objectReference:GetRefValue("btnAdsorptionSiteUButtonText")
	self.btnExportUButton = objectReference:GetRefValue("btnExportUButton")
	self.btnFashionValueIconUButton = objectReference:GetRefValue("btnFashionValueIconUButton")
	self.btnFashionValue = objectReference:GetRefValue("btnFashionValue")
	self.btnBackAlterUButton = objectReference:GetRefValue("btnBackAlterUButton")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
	self.textSelectorTitleUBaseText = objectReference:GetRefValue("textSelectorTitleUBaseText")
	self.selectorPointUSelector = objectReference:GetRefValue("selectorPointUSelector")
	self.textPointUBaseText = objectReference:GetRefValue("textPointUBaseText")
	self.listAdjustModeUList = objectReference:GetRefValue("listAdjustModeUList")
	self.btnResetUButton = objectReference:GetRefValue("btnResetUButton")
	self.listAdjustOptionUList = objectReference:GetRefValue("listAdjustOptionUList")
	self.btnInfoAdjustUButton = objectReference:GetRefValue("btnInfoAdjustUButton")
	self.textAdjustInfoUBaseText = objectReference:GetRefValue("textAdjustInfoUBaseText")
	self.tabAdjustModeUWidget = objectReference:GetRefValue("tabAdjustModeUWidget")
	self.editUWidget = objectReference:GetRefValue("editUWidget")

	if pg.me.gmMode == 1 then
		self.btnExportUButton.gameObject:SetActiveEx(true)
	end
end

function PetComponent:initView()
	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
	self.curPetAccessMap = {}
	self.petEquipAccessMap = {}
	self.vitalitySelectedAccessMap = {}
	self.petAccessRefreshSeq = 0
	self.needDestroyDownloadSprite = {}

	self:initComponents()
	self.btnAdsorptionSiteUButton:SetActive(false)
	self.accessoryUComponent.gameObject:SetActiveEx(false)
	self.btnCompleteUButton.gameObject:SetActiveEx(false)
	self:refreshAdjustButtonVisible(false)
	self:setVitalityTtitle()
	self:setVitalityAccessoryScoreText(0)
	self:setVitalityTotalScoreText(0)
	ClientTextUtils.setText(self.tMPUSDFText, pg.getGameString("BACK_TO_PRE"))
end

function PetComponent:setVitalityTtitle()
	ClientTextUtils.setText(self.txtBtnAutoMatchUButton, pg.getGameString("GLAMOUR_EVENT_ONE_CLICK"))
	ClientTextUtils.setText(self.txtCurAccessoryTitle, pg.getGameString("GLAMOUR_EVENT_ACC_SINGLE"))
	ClientTextUtils.setText(self.txtTotalTitle, pg.getGameString("GLAMOUR_EVENT_ACC_TOTAL"))
	ClientTextUtils.setText(self.txtFashionTitle, pg.getGameString("GLAMOUR_EVENT_ACC"))
	ClientTextUtils.setText(self.txtTagTitle, pg.getGameString("GLAMOUR_EVENT_ACC_TAG"))
	ClientTextUtils.setText(self.txtTags, pg.getGameString("GLAMOUR_EVENT_ACC_TAG"))
end

function PetComponent:initComponents()
	self.slotOptionComponent = SlotOptionComponent.new(self, self.slotOptionTransform)
	self.bubbleComponent = SliderBubbleComponent.new(self, self.bubbleUComponent.transform, {
		type = 0
	})
end

function PetComponent:getFilterRule()
	local res = {}

	for _, info in pairs(self.model.accessDataList) do
		local classifyData = AvatarAccessoryClassifyData[info.resId]

		if classifyData then
			local isFound = false

			for _, resData in ipairs(res) do
				if resData.filterBy == classifyData.kind then
					isFound = true

					break
				end
			end

			if not isFound then
				table.insert(res, {
					text = pg.getLocalizationText(classifyData.displayName),
					filterBy = classifyData.kind,
					order = classifyData.order
				})
			end
		end
	end

	lume.sort(res, "order")
	table.insert(res, 1, {
		order = -1,
		filterBy = -1,
		text = pg.getGameString("ALL")
	})

	return res
end

function PetComponent:onEnterPage()
	if self.ctrl.curComponentName == "pet" then
		self.btnAdsorptionSiteUButton:SetActive(false)
	end

	if not PetJewelryOssCache.isReady() then
		PetJewelryOssCache.ensureLoaded(function()
			self:onEnterPage()
		end)

		return
	end

	self.slotOptionComponent:addListener()
	self.slotOptionComponent.hideUIUButton:SetActiveFastest(true)
	self.slotOptionComponent.roleHideUButton:SetActiveFastest(false)
	self.bottomTabUComponent:TryChangePage("Switch", "Pet")
	self:addListener()

	self.inVitality = self.ctrl.vitalityPhase and self.ctrl.vitalityThemeId

	if self.inVitality then
		self.needRecordDefaultAccessory = true

		local themeKeyId = pg.me.id .. "Vitality" .. self.ctrl.vitalityThemeId

		pg.global.prefsCacheUtils:setBool(themeKeyId, false)

		self.inGetVitalityScore = false
	end

	self.model:initAccessDataList(self.ctrl.vitalityPhase, self.ctrl.vitalityThemeId)
	self:showPetModel(self.curPetId)

	local filterRule = self:getFilterRule()

	self.slotOptionComponent:setFilterRule(filterRule, "kind")
	self.slotOptionComponent:reset()
	self.petBoxUButton.gameObject:SetActiveEx(not self.inVitality)
	self.tagInfoUButton.gameObject:SetActiveEx(self.inVitality)

	if self.inVitality then
		self.vitalitySelectedAccessMap = {}

		self.bottomTabUComponent:TryChangePage("Switch", 3)
		self.avatarScene:disableCamera()

		local themeData = EnergyMatchThemeData[self.ctrl.vitalityPhase][self.ctrl.vitalityThemeId]

		self.avatarScene:setBackground(AddressDataConst.UI_VITALITY_CONTEST_SCENE, themeData and themeData.bgNo or 1)
		self.view.backgroundSelectorUSelector.gameObject:SetActiveEx(false)
		self.btnFashionValueIcon2UButton.gameObject:SetActiveEx(false)
		self:refreshVitalityAccessoryShowState()
		self.accessoryUComponent.gameObject:SetActiveEx(true)
		self.btnCompleteUButton.gameObject:SetActiveEx(true)
		self.rootUComponent:TryChangePage("activity", 1)
		self:refreshVitalityScore()
		self:refreshVitalityRecommendTags()
	end

	self.adjustUComponent:TryChangePage("AllUnlock", 0)
end

function PetComponent:refreshPage()
	if self.inVitality then
		return
	end

	local data = self.model:getSelectAccessData()

	self:refreshBaseView(data)
	self:refreshAllList(data)
end

function PetComponent:onLeavePage()
	self.slotOptionComponent:removeListener()
	self:removeListener()

	if self.enableTick then
		self:showLit(false)
	end

	self.avatarScene.waitLoadEntity = false
	self.avatarScene.waitFreezeEntity = false
	self.avatarScene.checkAllEntityReadyWhiteList = nil

	local pInfo = pg.me:getPetInfo(self.curPetId)

	if pInfo then
		self.avatarScene:hideEntityWithId(pInfo.templateId)
	end
end

function PetComponent:addListener()
	function self.operationUList.luaRenderItem(button, index, data)
		if data.displayName then
			self.titleUButton:SetActiveFastest(true)
			self:refreshTitleButton(data.displayName)
		else
			self.titleUButton:SetActiveFastest(false)
		end

		AvatarUtils.renderOperationCollection(button, data, function(btn, idx, subData)
			if subData.tIndex == 0 then
				local min, max, cur = self:parseSliderInfoWithOpName(subData)

				subData.minValue = min
				subData.maxValue = max

				local function onSliderValueChanged(value)
					local newValue = AvatarUtils.parseSliderMapValue(subData.oldMin, subData.oldMax, subData.newMin, subData.newMax, value, true)

					self.model:setAccessTransWithOpName(newValue, subData.opName)

					local entity = self.avatarScene:getCurEntity()
					local instanceId = self.model:getSelectAccessInstanceId()

					if not self.model:isPetAccessorySimpleMode() and not self.isLock then
						local nearestBoneName = entity.eModel.modelView:GetNearestBoneName(instanceId)

						self.nearestBoneName = nearestBoneName
					end

					self.curAttachInstanceId = instanceId
					self.boneSliderChanged = not self.model:isPetAccessorySimpleMode()
				end

				local function onSliderRelease()
					if self.model:isPetAccessorySimpleMode() then
						self.model:recordOperationStep()
						self:refreshAdjustButtonState()

						return
					end

					local entity = self.avatarScene:getCurEntity()
					local instanceId = self.model:getSelectAccessInstanceId()
					local attachBone

					if self.isLock then
						attachBone = self.lockBoneName
					else
						attachBone = self.nearestBoneName
					end

					if string.isNilOrEmpty(attachBone) then
						attachBone = entity.eModel.modelView:GetNearestBoneName(instanceId)
					end

					if string.isNilOrEmpty(attachBone) then
						attachBone = self:getSavedBoneName()
					end

					if string.isNilOrEmpty(attachBone) then
						return
					end

					entity.eModel.modelView:RefreshAttachParent(instanceId, attachBone)
					self.model:setAccessAttachBone(attachBone)

					self.nearestBoneName = attachBone

					self.model:adjustTransform()

					self.curAttachInstanceId = instanceId

					self.model:recordOperationStep()
					self:refreshAdjustButtonState()
				end

				local function onSliderPress()
					if self.model:isPetAccessorySimpleMode() then
						return
					end

					local entity = self.avatarScene:getCurEntity()
					local instanceId = self.model:getSelectAccessInstanceId()

					entity.eModel.modelView:ResetAttachParentToRoot(instanceId)

					if not self.isLock then
						self.nearestBoneName = entity.eModel.modelView:GetNearestBoneName(instanceId)
					end

					self.curAttachInstanceId = instanceId
					self.boneSliderChanged = true
				end

				AvatarUtils.renderSlider(btn, subData, cur, onSliderValueChanged, onSliderRelease, onSliderPress, nil, 0.01)
			end
		end)
	end

	function self.btnAdsorptionSiteUButton.luaClick()
		self.isLock = not self.isLock

		self:refreshLockBtnStates()
	end

	function self.listAdjustModeUList.luaRenderItem(button, _, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

		ClientTextUtils.setText(txtNameUBaseText, pg.getGameString(data.text))

		button.visualInteractable = data.mode ~= self.model.PET_ACCESSORY_ADJUST_MODE.SIMPLE or self.model:hasPetAccessorySimpleMode()
	end

	function self.listAdjustModeUList.luaClick(_, data)
		if data.mode == self.model.PET_ACCESSORY_ADJUST_MODE.SIMPLE and not self.model:hasPetAccessorySimpleMode() then
			self:refreshAdjustModeView()

			return
		end

		if self.model:setPetAccessoryAdjustMode(data.mode) then
			self.nearestBoneName = self:getSavedBoneName()
			self.boneSliderChanged = nil

			self.operationUList:SetList(self.model.Operation.operations)
		end

		self:refreshAdjustModeView()
		self:refreshAdjustButtonState()
	end

	function self.selectorPointUSelector.luaSelectedChanged(selector)
		if self.refreshingAdjustUI then
			return
		end

		local point = selector.selectedItem

		if point and self.model:selectPetAccessoryPoint(point.pointIndex, nil, true) then
			self.nearestBoneName = point.boneName

			self.operationUList:SetList(self.model.Operation.operations)
			self:refreshAdjustButtonState()
			self:showPetAccessoryHighlight()
		end

		self:refreshPetAccessoryPointSelector()
	end

	function self.listAdjustOptionUList.luaRenderItem(button, _, data)
		local objectReference = button:GetComponent("ObjectReference")
		local textUBaseText = objectReference:GetRefValue("textUBaseText")

		ClientTextUtils.setText(textUBaseText, pg.getGameString(data.text))
		button:TryChangePage("Icon", data.icon)

		local enabled = data.optionType == ADJUST_OPTION_TYPE.LOCK_POINT and self.isLock or data.optionType == ADJUST_OPTION_TYPE.ALL_POINTS and self.showAllAttachPoints or data.optionType == ADJUST_OPTION_TYPE.SNAP_POINT

		button:TryChangePage("State", enabled and 0 or 1)
	end

	function self.listAdjustOptionUList.luaClick(_, data)
		if data.optionType == ADJUST_OPTION_TYPE.LOCK_POINT then
			self.isLock = not self.isLock

			self:refreshLockBtnStates()
		elseif data.optionType == ADJUST_OPTION_TYPE.ALL_POINTS then
			self.showAllAttachPoints = not self.showAllAttachPoints

			self:refreshAdjustOptionList()

			if not self.showAllAttachPoints then
				self:clearAdvancedAttachPointCaches()
			end
		elseif data.optionType == ADJUST_OPTION_TYPE.SNAP_POINT then
			local entity = self.avatarScene:getCurEntity()
			local modelView = entity and entity.eModel and entity.eModel.modelView
			local instanceId = self.model:getSelectAccessInstanceId()

			if modelView == nil or instanceId == nil then
				return
			end

			local boneName = self.isLock and self.lockBoneName or nil

			if string.isNilOrEmpty(boneName) then
				boneName = modelView:GetNearestBoneName(instanceId)
			end

			if self.model:snapPetAccessoryToAttachPoint(boneName) then
				self.nearestBoneName = boneName
				self.boneSliderChanged = true

				self.operationUList:SetList(self.model.Operation.operations)
				self:refreshAdjustButtonState()
			end
		end
	end

	function self.btnResetUButton.luaClick()
		if self.model:isPetAccessorySimpleMode() then
			if not self.model:resetSelectedPetAccessoryPoint() then
				return
			end
		else
			if not self.model:resetOperation() then
				return
			end

			self.model:setPetAccessoryAdjustMode(self.model.PET_ACCESSORY_ADJUST_MODE.ADVANCED, false)
			self.model:recordOperationStep()
		end

		self.nearestBoneName = self:getSavedBoneName()
		self.boneSliderChanged = nil

		self.operationUList:SetList(self.model.Operation.operations)
		self:refreshAdjustModeView()
		self:refreshAdjustButtonState()
	end

	function self.btnInfoAdjustUButton.luaClick()
		local helpId = PetConfigData.PET_ACCESSORY_ADJUST_HELP_ID

		if helpId then
			pg.global.ui:open(UIConst.UI_ID_HELP, {
				helpId = helpId
			})
		else
			pg.global.ui:open(UIConst.UI_ID_HELP)
		end
	end

	function self.btnTryInfoUButton.luaRenderTooltip(btn, popup)
		local objectReference = popup:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("VITALITY_ACCESSORY_TRY"))
	end

	function self.designUButton.luaClick()
		if self.ctrl.curComponentName == "player" then
			return
		end

		self:showAjust()
		self.ctrl:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel, function()
			self.cancelUButton.luaClick()

			return false
		end, self.rootUComponent.gameObject, "appearancePetAccessoryEscBind")
	end

	function self.cancelUButton.luaClick()
		self:hideAjust()
		self.ctrl:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel, function()
			return true
		end, self.rootUComponent.gameObject, "appearancePetAccessoryEscBind")
	end

	self.btnBackAlterUButton.luaClick = self.cancelUButton.luaClick

	function self.btnAdjustUButton.luaClick()
		if not self:refreshAdjustButtonVisible(self.model:getSelectAccessData() ~= nil) then
			return
		end

		self:showAjust()
		self.ctrl:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel, function()
			self.cancelUButton.luaClick()

			return false
		end, self.rootUComponent.gameObject, "appearancePetAccessoryEscBind")
	end

	function self.saveUButton.luaClick()
		local data = self.model:getSelectAccessData()

		if data.isPreview then
			pg.global.showBubbleMessageRaw(pg.getGameString("PET_ACCESSORY_SAVE_FAIL"), 3)

			return
		end

		self:cancelAdjustInit()
		self.model:adjustAccessTrans(function(res)
			if not res then
				return
			end

			pg.global.showBubbleMessageRaw(pg.getGameString("PET_ACCESSORY_SAVE_SUCCESS"), 3)
		end)
		self.model:commitOperationSnapshot()
		self.view.topbarUWidget:SetActiveFastest(true)

		if self.inVitality then
			self:hideAjust(false)
		else
			self.rootUComponent:TryChangePage("State", 2)
			self.model:clearOperationCache()
		end

		self.rootUComponent:TryChangePage("Edit", 0)
		self:showLit(false)
		self.ctrl:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel, function()
			return true
		end, self.rootUComponent.gameObject, "appearancePetAccessoryEscBind")
		self:passToRightInfoComponent(self.rootUComponent)
	end

	function self.sourceUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local detailUText = objectReference:GetRefValue("detailUText")

		ClientTextUtils.setText(detailUText, pg.getLocalizationText(data.text))
	end

	function self.sourceUList.luaClick(button, data)
		if data.func then
			data.func()
		end
	end

	function self.sourceUList2.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local detailUText = objectReference:GetRefValue("detailUText")

		ClientTextUtils.setText(detailUText, pg.getLocalizationText(data.text))
	end

	function self.sourceUList2.luaClick(button, data)
		if data.func then
			data.func()
		end
	end

	function self.tagInfoUButton.luaRenderTooltip(btn, popup)
		local tagList = self:getVitalityRecommendTagList()
		local tag1Name = tagList[1] and tagList[1].name or ""
		local tag2Name = tagList[2] and tagList[2].name or ""
		local tag3Name = tagList[3] and tagList[3].name or ""
		local objectReference = popup:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local tipText = pg.getGameString("VITALITY_ACCESSORY_RECOMMEND_DESC")
		local scoreText = pg.getFormatText(tipText, tag1Name, tag2Name, tag3Name)

		ClientTextUtils.setText(txtNameUSDFText, scoreText)
	end

	function self.listRecommendTagsUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local textUSDFText = objectReference:GetRefValue("textUSDFText")

		ClientTextUtils.setText(textUSDFText, data.name or "")
	end

	function self.petBoxUButton.luaClick()
		local info = {
			curPetId = self.curPetId,
			selectCallback = function(petId)
				PetJewelryOssCache.ensureLoaded(function()
					self:showPetModel(petId)
				end)
			end
		}

		pg.global.ui:open(UIConst.UI_ID_ACCESS_PET_BOX, info)
	end

	function self.outfitUButton.luaClick()
		self:openPetAccessoryPreset()
	end

	function self.btnExportUButton.luaClick()
		self.model:saveAccessTransToLocal(function(templateId, accessoryId)
			pg.global.showBubbleMessageRaw(string.format("导出成功，目录在Assets/Res/PetAccessoryConfig/%s.csv，别忘了提交", templateId))
		end)
	end

	function self.btnCompleteUButton.luaClick()
		if self.inGetVitalityScore then
			return
		end

		self.inGetVitalityScore = true

		local accessories = self:getAccessoryList(true)

		pg.me:reqGetVitalityScore(self.ctrl.vitalityEventId, self.curPetId, accessories)
	end

	function self.btnAutoMatchUButton.luaClick()
		self:onAutoMatchClick()
	end

	function self.backwardUButton.luaClick()
		if self.model:backwardOperation() then
			self.operationUList:SetList(self.model.Operation.operations)
			self:refreshAdjustModeView()
			self:refreshAdjustButtonState()
		end
	end

	function self.forwardUButton.luaClick()
		if self.model:forwardOperation() then
			self.operationUList:SetList(self.model.Operation.operations)
			self:refreshAdjustModeView()
			self:refreshAdjustButtonState()
		end
	end
end

function PetComponent:openPetAccessoryPreset()
	if self.inVitality and self.avatarScene then
		self:restoreVitalityPetSceneState()
	end

	pg.global.ui:open(UIConst.UI_ID_PET_ACCESSORY_PRESET, {
		petId = self.curPetId,
		selectCallback = function(petId)
			PetJewelryOssCache.ensureLoaded(function()
				self:showPetModel(petId)
			end)
		end
	}, nil, function()
		self:onPetAccessoryPresetClosed()
	end)
end

function PetComponent:onPetAccessoryPresetClosed()
	if self.inVitality and self.avatarScene then
		self:restoreVitalityPetSceneState()
	end
end

function PetComponent:restoreVitalityPetSceneState()
	if not self.avatarScene then
		return
	end

	if self.avatarScene.camera then
		self.avatarScene.camera.enabled = true
	end

	if self.avatarScene.CAMERA then
		self.avatarScene:enableCameraMode(self.avatarScene.CAMERA.PET)
	end

	local themeData = EnergyMatchThemeData[self.ctrl.vitalityPhase] and EnergyMatchThemeData[self.ctrl.vitalityPhase][self.ctrl.vitalityThemeId]

	self.avatarScene:setBackground(AddressDataConst.UI_VITALITY_CONTEST_SCENE, themeData and themeData.bgNo or 1)
end

function PetComponent:onAutoMatchClick()
	if not self.inVitality then
		return
	end

	local slotCount = self.model:getSlotCount()

	if not slotCount or slotCount <= 0 then
		return
	end

	local accessories = self.model:filterAccesses(self.filterFunc)

	if not accessories or #accessories <= 0 then
		return
	end

	local curEnt = self.avatarScene:getCurEntity()
	local modelView = curEnt and curEnt.eModel and curEnt.eModel.modelView
	local modelInfo = modelView and modelView.modelInfo

	if not modelInfo then
		return
	end

	local selections = {}
	local setInfo = {}
	local used = {}

	for slot = 1, slotCount do
		local data = self:getAutoMatchFirstAccessory(accessories, used)

		if data then
			selections[#selections + 1] = {
				slot = slot,
				data = data
			}

			if not data.isTry then
				setInfo[#setInfo + 1] = {
					slot,
					data.genId,
					true
				}
			end

			used[self:getAutoMatchAccessoryKey(data)] = true
		end
	end

	if #selections <= 0 then
		return
	end

	if #setInfo > 0 then
		self.model:equipAccess2Server(setInfo, function(res)
			if not res then
				return
			end

			self:applyAutoMatchSelections(selections)
		end)
	else
		self:applyAutoMatchSelections(selections)
	end
end

function PetComponent:applyAutoMatchSelections(selections)
	local entity, modelView = self:getPetEntityAndModelView()

	if not modelView or not modelView.modelInfo then
		return
	end

	local modelInfo = modelView.modelInfo

	self.model:clearTryAccessData()

	self.vitalitySelectedAccessMap = {}

	for _, selection in ipairs(selections) do
		local slot = selection.slot
		local data = selection.data

		self.selectTabIdx = slot

		self.model:setSelectTabIndex(slot)

		local tabData = self.model:getTabInTabDataList(slot)

		if tabData then
			self.model:setPreviewData(tabData, data.isTry == true, data)

			if data.isTry then
				self.model:setSelectAccessData(data)
				self.model:equipTryAccessData(slot)
			else
				self.model:dropTryAccessData(slot)

				tabData.genId = data.genId
			end
		end

		local attachInfo = self.model:parseDefaultAccessInfo(data, self.modelSliderInfo)

		self:preparePetAccessChange(modelView, slot, attachInfo.instanceId)
		self:showPartAccessInternal(modelInfo, attachInfo, slot, false)
	end

	self:removeStalePetAccessAttaches(modelView)
	ClientModelUtils.refreshModels(entity, modelView)
	self:afterRefreshModel(modelView)
	self:scheduleStalePetAccessCleanup(modelView)
	self:refreshAllList()
	self:refreshAccessListView()
	self:refreshVitalityScore()
end

function PetComponent:getAutoMatchFirstAccessory(accessories, used)
	for _, data in ipairs(accessories) do
		if data.state == LuaUIUtils.SELECT_STATE.HAVE or data.state == LuaUIUtils.SELECT_STATE.TRY then
			local key = self:getAutoMatchAccessoryKey(data)

			if key and not used[key] then
				return data
			end
		end
	end
end

function PetComponent:getAutoMatchAccessoryKey(data)
	if not data then
		return nil
	end

	return data.genId and data.genId ~= 0 and tostring(data.genId) or tostring(data.accessoryId)
end

function PetComponent:refreshPetAccessoryPointSelector()
	local pointList = self.model:getPetAccessoryPointList() or EMPTY_TABLE
	local options = {}

	for _, point in ipairs(pointList) do
		options[#options + 1] = {
			label = point.isDefault and pg.getGameString(point.name) or pg.getLocalizationText(point.name),
			pointIndex = point.index,
			boneName = point.boneName
		}
	end

	local oldRefreshing = self.refreshingAdjustUI

	self.refreshingAdjustUI = true

	self.selectorPointUSelector:SetOptions(options)

	local selectedIndex = self.model:getSelectedPetAccessoryPointIndex()

	if selectedIndex and options[selectedIndex] then
		self.selectorPointUSelector:ForceSelect(selectedIndex - 1, false)
	end

	self.refreshingAdjustUI = oldRefreshing
end

function PetComponent:removePetAccessoryHighlightTimer()
	if self.petAccessoryHighlightTimer then
		TimerManager.removeTimer(self.petAccessoryHighlightTimer)

		self.petAccessoryHighlightTimer = nil
	end
end

function PetComponent:clearPetAccessoryHighlightMaterial()
	if self.petAccessoryHighlightShaderView and (self.petAccessoryHighlightMaterialActive or self.petAccessoryHighlightMaterialRequested) then
		self.petAccessoryHighlightShaderView:ResetMaterial()
	end

	self.petAccessoryHighlightShaderView = nil
	self.petAccessoryHighlightResId = nil
	self.petAccessoryHighlightMaterialActive = false
	self.petAccessoryHighlightMaterialRequested = false
end

function PetComponent:schedulePetAccessoryHighlightEnd(requestSeq)
	self:removePetAccessoryHighlightTimer()

	local timerId

	timerId = TimerManager.addTimer(PET_ACCESSORY_HIGHLIGHT_DURATION, function()
		if self.petAccessoryHighlightTimer ~= timerId then
			return
		end

		self.petAccessoryHighlightTimer = nil

		if requestSeq ~= self.petAccessoryHighlightRequestSeq then
			return
		end

		self.petAccessoryHighlightWanted = false

		self:clearPetAccessoryHighlightMaterial()
	end)
	self.petAccessoryHighlightTimer = timerId
end

function PetComponent:applyPetAccessoryHighlight(requestSeq)
	if requestSeq ~= self.petAccessoryHighlightRequestSeq or not self.petAccessoryHighlightWanted or not self.model:isPetAccessorySimpleMode() then
		return
	end

	local entity = self.avatarScene:getCurEntity()
	local modelView = entity and entity.eModel and entity.eModel.modelView
	local shaderView = modelView and modelView.shaderView
	local operationData = self.model:getOperationData()
	local resId = operationData and operationData.resId

	if shaderView == nil or string.isNilOrEmpty(resId) then
		return
	end

	if self.petAccessoryHighlightMaterialActive and self.petAccessoryHighlightShaderView == shaderView and self.petAccessoryHighlightResId == resId then
		self:schedulePetAccessoryHighlightEnd(requestSeq)

		return
	end

	if self.petAccessoryHighlightShaderView and self.petAccessoryHighlightShaderView ~= shaderView then
		self:clearPetAccessoryHighlightMaterial()
	end

	self.petAccessoryHighlightShaderView = shaderView
	self.petAccessoryHighlightResId = resId
	self.petAccessoryHighlightMaterialRequested = true

	shaderView:ChangeEffectMaterial({
		AddressDataConst.PET_ACCESSORY_HIGHLIGHT_MATERIAL
	}, function()
		if requestSeq ~= self.petAccessoryHighlightRequestSeq then
			if self.petAccessoryHighlightShaderView ~= shaderView or not self.petAccessoryHighlightWanted then
				shaderView:ResetMaterial()
			end

			return
		end

		if not self.petAccessoryHighlightWanted or not self.model:isPetAccessorySimpleMode() then
			shaderView:ResetMaterial()

			if self.petAccessoryHighlightShaderView == shaderView then
				self.petAccessoryHighlightShaderView = nil
				self.petAccessoryHighlightResId = nil
				self.petAccessoryHighlightMaterialActive = false
				self.petAccessoryHighlightMaterialRequested = false
			end

			return
		end

		self.petAccessoryHighlightMaterialRequested = false
		self.petAccessoryHighlightMaterialActive = true

		self:schedulePetAccessoryHighlightEnd(requestSeq)
	end, nil, resId)
end

function PetComponent:showPetAccessoryHighlight()
	if not self.model:isPetAccessorySimpleMode() then
		return
	end

	self:removePetAccessoryHighlightTimer()

	self.petAccessoryHighlightRequestSeq = (self.petAccessoryHighlightRequestSeq or 0) + 1
	self.petAccessoryHighlightWanted = true

	local requestSeq = self.petAccessoryHighlightRequestSeq

	if self.petAccessoryHighlightEffectLoaded then
		self:applyPetAccessoryHighlight(requestSeq)

		return
	end

	if self.petAccessoryHighlightEffectLoading then
		return
	end

	self.petAccessoryHighlightEffectSeq = (self.petAccessoryHighlightEffectSeq or 0) + 1

	local effectSeq = self.petAccessoryHighlightEffectSeq

	self.petAccessoryHighlightEffectLoading = true

	local extraConfig = {
		duration = -1,
		followType = EffectConst.FollowType.Global,
		mountType = EffectConst.MountType.Camera,
		loadCallback = function(effectItem)
			if effectSeq ~= self.petAccessoryHighlightEffectSeq then
				return
			end

			local effectObj = effectItem and effectItem.effectObj

			if effectObj and not IsNil(effectObj) then
				local volume = effectObj:GetComponent(typeof(CS.UnityEngine.Rendering.Volume))

				if volume and not IsNil(volume) then
					volume.priority = PET_ACCESSORY_HIGHLIGHT_VOLUME_PRIORITY
				end
			end

			self.petAccessoryHighlightEffectLoading = false
			self.petAccessoryHighlightEffectLoaded = true

			if self.petAccessoryHighlightWanted then
				self:applyPetAccessoryHighlight(self.petAccessoryHighlightRequestSeq)
			end
		end
	}

	self.petAccessoryHighlightEffectId = pg.game.effect:playRawEffect(nil, AddressDataConst.PET_ACCESSORY_HIGHLIGHT_EFFECT, extraConfig)

	if not self.petAccessoryHighlightEffectId then
		self.petAccessoryHighlightEffectLoading = false
	end
end

function PetComponent:stopPetAccessoryHighlight()
	self.petAccessoryHighlightRequestSeq = (self.petAccessoryHighlightRequestSeq or 0) + 1
	self.petAccessoryHighlightEffectSeq = (self.petAccessoryHighlightEffectSeq or 0) + 1
	self.petAccessoryHighlightWanted = false
	self.petAccessoryHighlightEffectLoading = false
	self.petAccessoryHighlightEffectLoaded = false

	self:removePetAccessoryHighlightTimer()
	self:clearPetAccessoryHighlightMaterial()

	if self.petAccessoryHighlightEffectId then
		pg.game.effect:stopEffect(nil, self.petAccessoryHighlightEffectId)

		self.petAccessoryHighlightEffectId = nil
	end
end

function PetComponent:refreshAdjustOptionList()
	self.listAdjustOptionUList:SetList(ADJUST_OPTION_LIST)
end

function PetComponent:refreshAdjustModeView()
	local isSimpleMode = self.model:isPetAccessorySimpleMode()

	if not isSimpleMode then
		self:stopPetAccessoryHighlight()
	end

	local mode = self.model:getPetAccessoryAdjustMode()

	self.tabAdjustModeUWidget:SetActive(self.model:hasPetAccessorySimpleMode())

	self.nearestBoneName = self:getSavedBoneName()

	if self.isLock then
		self.lockBoneName = self.nearestBoneName
	end

	self.view.infoRightUComponent:TryChangePage("EditState", isSimpleMode and 0 or 1)
	ClientTextUtils.setText(self.textSelectorTitleUBaseText, pg.getGameString("APPEARANCE_PET_ACCESSORY_ATTACH_PART"))
	ClientTextUtils.setText(self.textPointUBaseText, pg.getGameString(isSimpleMode and "APPEARANCE_PET_ACCESSORY_POINT_LABEL" or "APPEARANCE_PET_ACCESSORY_ADVANCED_POINT_TIP"))
	ClientTextUtils.setText(self.textAdjustInfoUBaseText, pg.getGameString("APPEARANCE_PET_ACCESSORY_ADJUST_HELP"))
	self.listAdjustModeUList:SetList(ADJUST_MODE_LIST)

	if mode then
		self.listAdjustModeUList:SelectItem(mode - 1, false)
		self.listAdjustModeUList:SetUListSwitchCurrentIndex(mode - 1)
	end

	self:refreshPetAccessoryPointSelector()
	self:refreshAdjustOptionList()

	if isSimpleMode then
		self:clearAdvancedAttachPointCaches()
	else
		self:clearSimpleAttachPointCaches()
	end
end

function PetComponent:clearScreenPointCacheList(fieldName)
	local cacheKeys = self[fieldName]

	if cacheKeys then
		for _, cacheKey in ipairs(cacheKeys) do
			UIUtils.ClearScreenPointCache(cacheKey)
		end
	end

	self[fieldName] = nil
end

function PetComponent:clearSimpleAttachPointCaches()
	self:clearScreenPointCacheList("simpleAttachPointCacheKeys")
end

function PetComponent:clearAdvancedAttachPointCaches()
	self:clearScreenPointCacheList("advancedAttachPointCacheKeys")
end

function PetComponent:getAttachPointCacheKey(fieldName, prefix, index)
	local cacheKeys = self[fieldName]

	if cacheKeys == nil then
		cacheKeys = {}
		self[fieldName] = cacheKeys
	end

	local cacheKey = cacheKeys[index]

	if cacheKey == nil then
		cacheKey = prefix .. index
		cacheKeys[index] = cacheKey
	end

	return cacheKey
end

function PetComponent:trimAttachPointCaches(fieldName, count)
	local cacheKeys = self[fieldName]

	if cacheKeys == nil then
		return
	end

	for i = #cacheKeys, count + 1, -1 do
		UIUtils.ClearScreenPointCache(cacheKeys[i])

		cacheKeys[i] = nil
	end
end

function PetComponent:drawAttachPoint(cacheKey, worldPosition, state)
	UIUtils.DrawScreenPointWithWorldPosition(cacheKey, worldPosition, self.view.rootUComponent.transform, self.avatarScene.camera, function(go)
		go:GetComponent("UComponent"):TryChangePage("state", state)
	end)
end

function PetComponent:findAdvancedAttachPoint(worldPosition)
	for _, attachPoint in ipairs(self.advancedAttachBoneList) do
		if Vector3.SqrMagnitude(attachPoint.worldPosition - worldPosition) <= ATTACH_POINT_POSITION_EPSILON_SQR then
			return attachPoint
		end
	end
end

function PetComponent:buildAdvancedAttachBoneList()
	self.advancedAttachBoneList = {}

	local minDepth, maxDepth
	local entity = self.avatarScene:getCurEntity()
	local modelView = entity and entity.eModel and entity.eModel.modelView

	if modelView == nil then
		return
	end

	local boneNames = modelView:GetAttachBoneNames()

	for i = 0, boneNames.Length - 1 do
		local boneName = boneNames[i]
		local success, worldPosition = modelView:TryGetAttachPointWorldPosition(boneName, Vector3.zero)

		if success then
			local attachPoint = self:findAdvancedAttachPoint(worldPosition)

			if attachPoint == nil then
				attachPoint = {
					boneName = boneName,
					boneNames = {},
					worldPosition = worldPosition
				}
				self.advancedAttachBoneList[#self.advancedAttachBoneList + 1] = attachPoint
			end

			attachPoint.boneNames[boneName] = true
		end

		local converted, rootPosition = modelView:TryConvertAttachBoneLocalToRoot(boneName, Vector3.zero, Vector3.zero, 1)

		if converted then
			minDepth = minDepth and math.min(minDepth, rootPosition.z) or rootPosition.z
			maxDepth = maxDepth and math.max(maxDepth, rootPosition.z) or rootPosition.z
		end
	end

	return minDepth, maxDepth
end

function PetComponent:cancelAdjustInit()
	self.adjustInitSeq = (self.adjustInitSeq or 0) + 1
end

function PetComponent:showAjust()
	self:cancelAdjustInit()
	self:stopPetAccessoryHighlight()

	self.advancedAttachBoneList = nil
	self.showAllAttachPoints = false

	self.btnAdsorptionSiteUButton:SetActive(false)
	self.view.topbarUWidget:SetActiveFastest(false)

	if self.inVitality then
		self.accessoryUComponent.gameObject:SetActiveEx(false)
		self.btnCompleteUButton.gameObject:SetActiveEx(false)
		self.rootUComponent:TryChangePage("activity", 0)
	end

	self.rootUComponent:TryChangePage("State", 1)
	self.rootUComponent:TryChangePage("Edit", 1)
	self:showLit(true)

	local seq = self.adjustInitSeq

	TimerManager.addNextFrameCb(function()
		if seq ~= self.adjustInitSeq then
			return
		end

		self:refreshPetJewelrySliderDepthRange()
		self.model:initOperationData(self.modelSliderInfo)

		local instanceId = self.model:getSelectAccessInstanceId()

		self.curAttachInstanceId = instanceId
		self.nearestBoneName = self:getSavedBoneName()

		self.operationUList:SetList(self.model.Operation.operations)
		self:refreshIdleButton()

		self.isLock = false

		self:refreshLockBtnStates()
		self:refreshAdjustModeView()
		self:refreshAdjustButtonState()
	end)
	self:passToRightInfoComponent(self.rootUComponent)
end

function PetComponent:hideAjust(restoreChanges)
	self:cancelAdjustInit()
	self:stopPetAccessoryHighlight()
	self.view.topbarUWidget:SetActiveFastest(true)

	if self.inVitality then
		self.accessoryUComponent.gameObject:SetActiveEx(true)
		self.btnCompleteUButton.gameObject:SetActiveEx(true)
		self.rootUComponent:TryChangePage("State", 0)
		self.btnFashionValueIcon2UButton.gameObject:SetActiveEx(false)
		self.rootUComponent:TryChangePage("activity", 1)
	else
		self.rootUComponent:TryChangePage("State", 2)
	end

	self.rootUComponent:TryChangePage("Edit", 0)
	self:showLit(false)

	local data = self.model:getSelectAccessData()

	if data.isPreview then
		self:passToRightInfoComponent(self.rootUComponent)

		return
	end

	if restoreChanges ~= false then
		self.model:discardOperationData()
	else
		self.model:clearOperationCache()
	end

	self:passToRightInfoComponent(self.rootUComponent)
end

function PetComponent:removeListener()
	self.sourceUList.luaRenderItem = nil
	self.sourceUList.luaClick = nil
	self.listAdjustModeUList.luaRenderItem = nil
	self.listAdjustModeUList.luaClick = nil
	self.selectorPointUSelector.luaSelectedChanged = nil
	self.listAdjustOptionUList.luaRenderItem = nil
	self.listAdjustOptionUList.luaClick = nil
	self.btnResetUButton.luaClick = nil
	self.btnInfoAdjustUButton.luaClick = nil
end

function PetComponent:onDestroy()
	self:stopPetAccessoryHighlight()
	UIUtils.ClearScreenPointCache("petNearestBone")
	UIUtils.ClearScreenPointCache("petCurAttach")
	self:clearSimpleAttachPointCaches()
	self:clearAdvancedAttachPointCaches()

	for _, sprite in ipairs(self.needDestroyDownloadSprite) do
		pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)
	end

	UIComponent.onDestroy(self)
end

function PetComponent:refreshAdjustButtonState()
	if self.backwardUButton then
		self.backwardUButton.interactable = self.model:canBackwardOperation()
	end

	if self.forwardUButton then
		self.forwardUButton.interactable = self.model:canForwardOperation()
	end
end

function PetComponent:refreshAdjustButtonVisible(hasSelectedAccessory)
	local hasPet = not string.isNilOrEmpty(self.curPetId) and pg.me:getPetInfo(self.curPetId) ~= nil
	local visible = hasPet and hasSelectedAccessory == true

	self.btnAdjustUButton.gameObject:SetActiveEx(visible)

	return visible
end

function PetComponent:refreshLockBtnStates()
	if self.isLock then
		ClientTextUtils.setText(self.btnAdsorptionSiteUButtonText, pg.getGameString("ACCESSORY_BONE_ADSORPTION_ENABLED"))

		self.lockBoneName = self.nearestBoneName
	else
		ClientTextUtils.setText(self.btnAdsorptionSiteUButtonText, pg.getGameString("ACCESSORY_BONE_ADSORPTION_DISABLED"))

		self.lockBoneName = nil
	end

	self.btnAdsorptionSiteUButton:TryChangePage("Lock", self.isLock and 1 or 0)
	self:refreshAdjustOptionList()
end

function PetComponent:showLit(show)
	if show then
		self:setPetTPose()

		local instanceId = self.model:getSelectAccessInstanceId()

		self.curAttachInstanceId = instanceId
		self.nearestBoneName = self:getSavedBoneName()
		self.enableTick = true
		self.avatarScene.checkAllEntityReadyWhiteList = {
			self.avatarScene:getCurEntity()
		}
	else
		self.avatarScene.checkAllEntityReadyWhiteList = nil

		self:setPetIdle()

		self.enableTick = nil
		self.nearestBoneName = nil
		self.curAttachInstanceId = nil
		self.boneSliderChanged = nil
		self.advancedAttachBoneList = nil
		self.showAllAttachPoints = nil

		UIUtils.ClearScreenPointCache("petNearestBone")
		UIUtils.ClearScreenPointCache("petCurAttach")
		self:clearSimpleAttachPointCaches()
		self:clearAdvancedAttachPointCaches()
	end
end

function PetComponent:updatePetBone()
	if not self.enableTick then
		return
	end

	local entity = self.avatarScene:getCurEntity()

	if not entity then
		return
	end

	local modelView = entity.eModel.modelView
	local hasBoned = self.boneSliderChanged or self:checkCurAccessoryHasBoned()
	local isSimpleMode = self.model:isPetAccessorySimpleMode()
	local highlightedBoneName = hasBoned and self.nearestBoneName or nil
	local curAttachPos

	if self.curAttachInstanceId then
		curAttachPos = modelView:GetCurAttachPos(self.curAttachInstanceId)
	end

	if isSimpleMode then
		self:clearAdvancedAttachPointCaches()

		local selectedIndex = self.model:getSelectedPetAccessoryPointIndex()
		local drawCount = 0

		if selectedIndex then
			local success, worldPosition = self.model:getPetAccessoryPointWorldPosition(selectedIndex)

			if success then
				drawCount = drawCount + 1

				local cacheKey = self:getAttachPointCacheKey("simpleAttachPointCacheKeys", "petSimpleAttachPoint", drawCount)

				self:drawAttachPoint(cacheKey, worldPosition, 1)
			end
		end

		self:trimAttachPointCaches("simpleAttachPointCacheKeys", drawCount)
	else
		self:clearSimpleAttachPointCaches()

		if self.showAllAttachPoints then
			if self.advancedAttachBoneList == nil then
				self:buildAdvancedAttachBoneList()
			end

			local drawCount = 0

			for _, attachPoint in ipairs(self.advancedAttachBoneList or EMPTY_TABLE) do
				if highlightedBoneName == nil or not attachPoint.boneNames[highlightedBoneName] then
					local success, worldPosition = modelView:TryGetAttachPointWorldPosition(attachPoint.boneName, Vector3.zero)

					if success then
						drawCount = drawCount + 1

						local cacheKey = self:getAttachPointCacheKey("advancedAttachPointCacheKeys", "petAdvancedAttachPoint", drawCount)

						self:drawAttachPoint(cacheKey, worldPosition, 0)
					end
				end
			end

			self:trimAttachPointCaches("advancedAttachPointCacheKeys", drawCount)
		else
			self:clearAdvancedAttachPointCaches()
		end
	end

	if not isSimpleMode and highlightedBoneName then
		local nearestBonePos = modelView:GetBonePosByBoneName(highlightedBoneName)

		if nearestBonePos then
			UIUtils.DrawScreenPointWithWorldPosition("petNearestBone", nearestBonePos, self.view.rootUComponent.transform, self.avatarScene.camera, function(go)
				go:GetComponent("UComponent"):TryChangePage("state", 1)
			end)
		else
			UIUtils.ClearScreenPointCache("petNearestBone")
		end
	else
		UIUtils.ClearScreenPointCache("petNearestBone")
	end

	if curAttachPos then
		UIUtils.DrawScreenPointWithWorldPosition("petCurAttach", curAttachPos, self.view.rootUComponent.transform, self.avatarScene.camera, function(go)
			go:GetComponent("UComponent"):TryChangePage("state", 0)
		end)
	else
		UIUtils.ClearScreenPointCache("petCurAttach")
	end
end

function PetComponent:postRenderSlotList(button, index, data)
	local oc = button:GetComponent("ObjectReference")
	local iconUImage = oc:GetRefValue("iconUImage")
	local rootUComponent = oc:GetRefValue("rootUComponent")

	button:TryChangePage("Type", 1)

	if data.state == LuaUIUtils.SLOT_STATE.HAVE then
		if data.genId == nil and not data.isTry then
			rootUComponent:TryChangePage("state", 3)
		else
			rootUComponent:TryChangePage("Quality", data.quality)

			iconUImage.url = data.icon
		end
	end
end

function PetComponent:postRenderOptionList(button, index, data)
	if data.instanceId then
		local treePath = string.format(RedDotConst.RedDotPath.APPEARANCE_PET_OPTION_LIST_ITEM, data.instanceId)

		pg.global.setRedDot(treePath, button, data.showRedDot or false, RedDotConst.RedDotStyle.NEW_LEFT_EXPEND)
	end
end

function PetComponent:onSlotSelectedChanged(data)
	return
end

function PetComponent:onSlotClicked(oldData, data)
	if data.state == LuaUIUtils.SLOT_STATE.LOCKED then
		pg.global.showBubbleMessageById(NoticeDef.PET_APPEAR_SLOT_LOCK)

		return
	end

	if oldData and oldData == data and data.state == LuaUIUtils.SLOT_STATE.HAVE and data.genId and not data.isTry then
		local accessData = self.model:getAccessDataInDataList(data.genId)

		if accessData and accessData.refPetId == self.curPetId then
			self.selectTabIdx = data.tabIndex

			self:unloadPartAccess(accessData)

			return
		end
	end

	self:onFocusSlot(data)
end

function PetComponent:onOptionSelectedChanged(data)
	return
end

function PetComponent:setVitalityPrefs(id)
	if self.inVitality then
		local phaseKeyId = pg.me.id .. "Vitality" .. id

		pg.global.prefsCacheUtils:setBool(phaseKeyId, true)
	end
end

function PetComponent:onOptionClicked(slotData, oldData, data, button)
	self:clearSubListSelect()

	local extraInfo = {}

	if self:showVitalityTips() then
		extraInfo.hint = true
		extraInfo.hintDesc = pg.getGameString("VITALITY_OUTFIT_ACCESSORY_NOTIP")

		function extraInfo.hintCb(isSelected)
			if isSelected then
				self:setVitalityPrefs(self.ctrl.vitalityPhase)
			end
		end
	end

	if data.state == LuaUIUtils.SELECT_STATE.PET_WEAR then
		if data.refPetId == self.curPetId then
			self:checkUnloadOrSwitch(data)
		else
			local title = pg.getGameString("PET_ACCESSORY_CHANGE_TITLE")
			local content = pg.getGameString("PET_ACCESSORY_CHANGE_TEXT")

			if self:showVitalityTips() then
				title = pg.getGameString("VITALITY_OUTFIT_TIP_TITLE")
				content = pg.getGameString("VITALITY_OUTFIT_ACCESSORY_TIP")
			end

			pg.global.showConfirmMsgRaw(title, content, function()
				self.model:dropTryAccessData(self.selectTabIdx)
				self:equipPartAccess(data)

				if self:showVitalityTips() then
					self.outfitUButton:OnClickSimulate()
				end

				self:setVitalityPrefs(self.ctrl.vitalityThemeId)
			end, false, function()
				self:checkPreviewAccess(data)
				self:setVitalityPrefs(self.ctrl.vitalityThemeId)
			end, false, nil, extraInfo)
		end
	elseif data.state == LuaUIUtils.SELECT_STATE.HAVE then
		self.model:dropTryAccessData(self.selectTabIdx)
		self:equipPartAccess(data)

		if self:showVitalityTips() then
			pg.global.showConfirmMsgRaw(pg.getGameString("VITALITY_OUTFIT_TIP_TITLE"), pg.getGameString("VITALITY_OUTFIT_TIP_DESC"), function()
				self.outfitUButton:OnClickSimulate()
				self:setVitalityPrefs(self.ctrl.vitalityThemeId)
			end, false, function()
				self:setVitalityPrefs(self.ctrl.vitalityThemeId)
			end, false, nil, extraInfo)
		end
	elseif data.state == LuaUIUtils.SELECT_STATE.TRY then
		local tabData = self.model:getTabInTabDataList(self.selectTabIdx)

		if not tabData.isPreview or tabData.previewInstId ~= data.instanceId then
			local tabData = self.model:getTabInTabDataList(self.selectTabIdx)

			if data.tabIndex then
				self.model:dropTryAccessData(data.tabIndex)

				self.curPetAccessMap[data.tabIndex] = nil
				self.petEquipAccessMap[data.tabIndex] = nil

				self:clearVitalitySelectedAccessory(data.tabIndex)

				local lastTabData = self.model:getTabInTabDataList(data.tabIndex)

				self.model:setPreviewData(lastTabData, false, data)
			end

			local accessoryData = self.model:getAccessDataInDataList(tabData.genId)

			if accessoryData then
				self:checkUnloadOrSwitch(accessoryData)
			end
		end

		self:checkPreviewAccess(data)
		self:refreshVitalityScore()
	else
		self:checkPreviewAccess(data)
	end

	if data.showRedDot then
		local treePath = string.format(RedDotConst.RedDotPath.APPEARANCE_PET_OPTION_LIST_ITEM, string.format("%s_%s", data.accessoryId, data.genId))

		pg.me:setRedDotRecord(Const.CLIENT_KEY.APPEARANCE_PET_RED_DOT, treePath, false)

		data.showRedDot = false

		local index = self.slotOptionComponent.optionUList:GetChildIndex(button)

		self.slotOptionComponent.optionUList:SetElement(index, data)
	end

	self.curSelectAccessId = data.accessoryId

	self:showLit(false)
end

function PetComponent:showVitalityTips()
	if self.inVitality then
		local phaseKeyId = pg.me.id .. "Vitality" .. self.ctrl.vitalityPhase
		local themeKeyId = pg.me.id .. "Vitality" .. self.ctrl.vitalityThemeId
		local phaseValue = pg.global.prefsCacheUtils:getBool(phaseKeyId, false)

		if phaseValue then
			return false
		end

		local themeValue = pg.global.prefsCacheUtils:getBool(themeKeyId, false)

		return not themeValue and self.recordAccessory and #self.recordAccessory > 0
	end

	return false
end

function PetComponent:checkCurAccessoryHasBoned()
	return self:getSavedBoneName() ~= nil
end

function PetComponent:getSavedBoneName()
	return self.model.operationDATAS.attachBone
end

function PetComponent:onFilterSelectedChanged(slotData, filterFunc)
	self.filterFunc = filterFunc

	self:refreshAccessListView(filterFunc)
end

function PetComponent:onFilterClicked(slotData, filterFunc)
	self.filterFunc = filterFunc

	self:refreshAccessListView(filterFunc)
end

function PetComponent:onSearchChanged(slotData, filterFunc)
	self.filterFunc = filterFunc

	self:refreshAccessListView(filterFunc)
end

function PetComponent:onBuyItems(data)
	self:forceRefreshAccessList()
end

function PetComponent:onFocusSlot(data)
	self.selectTabIdx = data.tabIndex

	self.model:setSelectTabIndex(data.tabIndex)
	self:refreshAccessListView()
end

function PetComponent:forceRefreshAccessList()
	local accessories = self.model:initAccessDataList(self.ctrl.vitalityPhase, self.ctrl.vitalityThemeId)

	self.slotOptionComponent.optionUList:SetList(accessories)

	local curAccessId = self.curSelectAccessId or 0
	local index = 1

	for i, v in ipairs(accessories) do
		if v.accessoryId == curAccessId then
			index = i

			break
		end
	end

	local res, subBtn = self.slotOptionComponent.optionUList:TryGetChildAt(index - 1)

	if not res then
		return
	end

	subBtn:OnClickSimulate()
end

function PetComponent:refreshPetBoxIcon(petInfo)
	if not self.petBoxIconUImage or not petInfo then
		return
	end

	local petData = PetData[petInfo.templateId]

	if not petData or not petData.iconName then
		return
	end

	self.petBoxIconUImage.url = LuaUIUtils.getPetIcon(petData.iconName, LuaUIUtils.PET_ICON, petInfo.label, petInfo.gender)
end

function PetComponent:showPetModel(showPetId)
	self:refreshAdjustButtonVisible(false)

	if not string.isNilOrEmpty(self.curPetId) then
		local pInfo = pg.me:getPetInfo(self.curPetId)

		self.avatarScene:destroyPet(pInfo.templateId)
	end

	if string.isNilOrEmpty(showPetId) then
		return
	end

	self.curPetId = showPetId

	self.model:clearCacheData()

	local baseInfo = self.model:setPetProId(showPetId)

	if baseInfo == nil then
		return
	end

	self:refreshTabView()

	local pInfo = pg.me:getPetInfo(showPetId)

	self:refreshPetBoxIcon(pInfo)

	local petHeight = pInfo.height or 1

	self.adjustHeight = petHeight * 1.2
	self.modelSliderInfo = AvatarUtils.generatePetJewelrySlider(petHeight, baseInfo.scale, 1.5, pInfo.sizeLevel)

	self.avatarScene:showPetTemplate(pInfo, baseInfo.scale, baseInfo.offset)
end

function PetComponent:refreshPetJewelrySliderDepthRange()
	local minDepth, maxDepth = self:buildAdvancedAttachBoneList()

	AvatarUtils.refreshPetJewelrySliderDepthRange(self.modelSliderInfo, minDepth, maxDepth)
end

function PetComponent:refreshTabView()
	self.model:initTabDataList()
	self.rootUComponent:TryChangePage("State", 0)
	self.rootUComponent:TryChangePage("BtnType", 2)

	local slotData = self.model:getTabList()

	self.slotOptionComponent.slotUList:SetList(slotData)

	local selectedSlotIndex = 1

	for _, data in ipairs(slotData) do
		if data.state == LuaUIUtils.SLOT_STATE.HAVE and data.genId and not data.isPreview and not data.isTry then
			selectedSlotIndex = data.tabIndex

			break
		end
	end

	local res, btn = self.slotOptionComponent.slotUList:TryGetChildAt(selectedSlotIndex - 1)

	if not res and selectedSlotIndex ~= 1 then
		res, btn = self.slotOptionComponent.slotUList:TryGetChildAt(0)
	end

	if not res then
		return
	end

	btn:OnClickSimulate()
	self:passToRightInfoComponent(self.rootUComponent)
end

function PetComponent:refreshAllList(data)
	self.model:refreshTabDataList()
	self.slotOptionComponent.slotUList:SetList(self.model.tabDataList)
	self.model:refreshAccessDataList()
	self.slotOptionComponent.optionUList:RefreshList()
	self:checkRefreshOperationState(data)
end

function PetComponent:checkRefreshOperationState(data)
	if self.ctrl.vitalityPhase == nil or self.ctrl.vitalityThemeId == nil then
		if data ~= nil and data.refPetId and data.refPetId == self.curPetId and self.selectTabIdx == data.slot and data.state == LuaUIUtils.SELECT_STATE.PET_WEAR then
			self.rootUComponent:TryChangePage("detail", 0)
		else
			self.rootUComponent:TryChangePage("detail", 1)
		end

		self:passToRightInfoComponent(self.rootUComponent)
	end
end

function PetComponent:refreshAccessListView(filterFunc)
	filterFunc = filterFunc or self.filterFunc

	local accessories = self.model:filterAccesses(filterFunc)

	self.slotOptionComponent.optionUList:SetList(accessories)
	self:clearSubListSelect()

	local data = self.model:getTabInTabDataList(self.selectTabIdx)

	if not data or data.state ~= LuaUIUtils.SLOT_STATE.HAVE then
		return
	end

	local itemData

	if data.isPreview then
		itemData = self.model:getAccessDataInDataListWithInstId(data.previewInstId)
	else
		itemData = self.model:getAccessDataInDataList(data.genId)
	end

	if itemData then
		for index = 0, self.slotOptionComponent.optionUList.itemCount - 1 do
			local optionData = self.slotOptionComponent.optionUList:GetData(index)

			if optionData and optionData.instanceId == itemData.instanceId then
				self.slotOptionComponent.optionUList:SelectItem(index)

				break
			end
		end

		self:selectSubItem(itemData, true)
	end
end

function PetComponent:refreshBaseView(data)
	if not self.inVitality then
		ClientTextUtils.setText(self.nameUText, data.name)
		ClientTextUtils.setText(self.btnFashionValue, data.fashion)

		function self.btnFashionValueIconUButton.luaRenderTooltip(btn, prop)
			self.view:renderFashionTips(prop, data.fashion)
		end

		ClientTextUtils.setText(self.detailsUBaseText, pg.getLocalizationText(ItemData[data.accessoryId].itemDes or ""))

		local sourceList = self:getSourceList(data.accessoryId)

		self.sourceUList:SetList(sourceList)

		local extra = {}

		extra = {
			name = data.name,
			fashion = data.fashion,
			desc = pg.getLocalizationText(ItemData[data.accessoryId].itemDes or ""),
			id = data.accessoryId,
			claimed = data.owner,
			refreshCallback = function()
				local data1 = self.model:getSelectAccessData()

				if data1 ~= nil and data1.refPetId and data1.refPetId == self.curPetId and self.selectTabIdx == data1.slot and data1.state == LuaUIUtils.SELECT_STATE.PET_WEAR then
					self.rootUComponent:TryChangePage("detail", 0)
				else
					self.rootUComponent:TryChangePage("detail", 1)
				end

				extra.claimed = true

				self:passToRightInfoComponent(self.rootUComponent, extra)
				self:refreshPage()
			end
		}

		self:passToRightInfoComponent(self.rootUComponent, extra)
	end
end

function PetComponent:refreshTitleButton(displayName)
	local objectReference = self.titleUButton:GetComponent("ObjectReference")
	local titleUText = objectReference:GetRefValue("titleUText")
	local positionUText = objectReference:GetRefValue("positionUText")
	local refreshUButton = objectReference:GetRefValue("refreshUButton")

	ClientTextUtils.setText(titleUText, pg.getGameString("ACCESSORY_DEFAULT_POS"))
	ClientTextUtils.setText(positionUText, "")

	local selectItemData = self.model:getSelectAccessData()

	if selectItemData and selectItemData.resId then
		local classifyData = AvatarAccessoryClassifyData[selectItemData.resId] or {}

		if classifyData.displayName then
			ClientTextUtils.setText(positionUText, pg.getLocalizationText(classifyData.displayName))
		end
	end

	function refreshUButton.luaClick()
		self.model:resetOperation()
		self.model:recordOperationStep()
		self.operationUList:SetList(self.model.Operation.operations)
		self:refreshAdjustButtonState()
	end
end

function PetComponent:reEnterPanel()
	local data = self.model:getSelectAccessData()

	self:refreshBaseView(data)
	self:refreshAllList(data)
end

function PetComponent:getSourceList(accessoryId)
	local list = {}
	local accessoryData = AppearanceJewelryPetData[accessoryId] or {}

	if accessoryData.templateId then
		table.insert(list, {
			text = pg.getGameString("ACCESSORY_SOURCE_PET_HANDBOOK"),
			func = function()
				local petHandbookInfo = pg.me.petHandbookMap[accessoryData.templateId] or {}

				if petHandbookInfo:isCatched() then
					if self.inOpen == nil or self.inOpen == false then
						self.inOpen = true

						self:hide()

						local ret = PetResearchUtils.openPetResearchDetail({
							templateId = accessoryData.templateId
						}, function()
							self.inOpen = false

							pg.global.ui.petResearchProgressReward:open({
								templateId = accessoryData.templateId,
								onHideFunc = function()
									pg.global.ui.petResearchDetail:dismiss()
									self:show()
									self:reEnterPanel()
								end
							})
						end)

						if not ret then
							self.inOpen = false
						end
					end
				else
					pg.global.ui.tips:showTextTip(pg.getGameString("JEWELRY_PAT_SOURCE"))
				end
			end
		})
	end

	if accessoryData.shopClassifyId or accessoryData.shopId then
		table.insert(list, {
			text = pg.getGameString("ACCESSORY_SOURCE_SHOP"),
			func = function()
				pg.global.ui:open(UIConst.UI_ID_SHOP_MAIN, {
					shopTags = {
						accessoryData.shopClassifyId
					},
					shopTag = accessoryData.shopId
				}, nil, function()
					self:reEnterPanel()
				end)
			end
		})
	end

	return list
end

function PetComponent:getButtonIndexWithTmpId(instanceId)
	if string.isNilOrEmpty(instanceId) then
		return 0, nil
	end

	local btnList = self.slotOptionComponent.optionUList:GetAllButtons()

	for i = 0, btnList.Length - 1 do
		local data = btnList[i].dataFromUList

		if data.instanceId == instanceId then
			return i, btnList[i]
		end
	end

	return 0, nil
end

function PetComponent:clearSubListSelect()
	local btnList = self.slotOptionComponent.optionUList:GetAllButtons()

	for i = 0, btnList.Length - 1 do
		local v = btnList[i]

		v:TryChangePage("GamePadFocus", 0)
	end

	self.rootUComponent:TryChangePage("State", 0)
	self:refreshAdjustButtonVisible(false)
	self:setVitalityAccessoryScoreText(0)
	self:passToRightInfoComponent(self.rootUComponent)
end

function PetComponent:selectSubItem(data, isSelect)
	local _, button = self:getButtonIndexWithTmpId(data.instanceId)

	self:refreshAdjustButtonVisible(button ~= nil and isSelect and data ~= nil)

	if button then
		if self.inVitality then
			self.accessoryUComponent:TryChangePage("Show", isSelect and 1 or 0)

			if isSelect then
				self.btnCompleteUButton.gameObject:SetActiveEx(true)
			end
		end

		if isSelect then
			button:TryChangePage("GamePadFocus", 1)
			self.model:setSelectAccessData(data)
			self:checkRefreshOperationState(data)
			self:refreshBaseView(data)

			if not self.inVitality then
				self.rootUComponent:TryChangePage("State", 2)
			else
				self:refreshVitalityView(data)
			end

			if data.isTry then
				self.model:equipTryAccessData(self.selectTabIdx)
			end
		else
			button:TryChangePage("GamePadFocus", 0)

			if not self.inVitality then
				self.rootUComponent:TryChangePage("State", 0)
			end

			if data.isTry then
				self.model:dropTryAccessData(self.selectTabIdx)
				self:refreshAllList(data)
			end
		end

		self:passToRightInfoComponent(self.rootUComponent)
	end
end

function PetComponent:refreshVitalityScore()
	if self.inVitality then
		local themeData = EnergyMatchThemeData[self.ctrl.vitalityPhase][self.ctrl.vitalityThemeId]
		local accessories = self:getAccessoryList(true)
		local sumScore, accessoryScoreData = ActivityUtils.caculateAccessories(accessories, themeData, self.ctrl.vitalityPhase, pg.me)

		self.accessoryScoreData = accessoryScoreData

		self:setVitalityTotalScoreText(sumScore)
		self:updateVitalityCompleteButton(#accessories)
	end
end

function PetComponent:updateVitalityCompleteButton(accessoryCount)
	if not self.inVitality then
		return
	end

	self.btnCompleteUButton.gameObject:SetActiveEx(true)
end

function PetComponent:setVitalityAccessoryScoreText(score)
	ClientTextUtils.setText(self.txtCurAccessoryNum, score or 0)
end

function PetComponent:setVitalityTotalScoreText(score)
	ClientTextUtils.setText(self.textSumNumberUBaseText, score or 0)
	ClientTextUtils.setText(self.txtTotalNum, score or 0)
end

function PetComponent:getVitalityRecommendTagList()
	local tagList = {}

	if not self.inVitality then
		return tagList
	end

	local themeData = EnergyMatchThemeData[self.ctrl.vitalityPhase] and EnergyMatchThemeData[self.ctrl.vitalityPhase][self.ctrl.vitalityThemeId]

	for _, tagId in ipairs(themeData and themeData.accessoryTheme or EMPTY_TABLE) do
		local tagData = EnergyAccessoriesTagData[tagId]

		if tagData then
			table.insert(tagList, {
				tagId = tagId,
				name = pg.getLocalizationText(tagData.tagName)
			})
		end
	end

	return tagList
end

function PetComponent:refreshVitalityRecommendTags()
	if not self.inVitality or not self.listRecommendTagsUList then
		return
	end

	self.listRecommendTagsUList:SetList(self:getVitalityRecommendTagList())
end

function PetComponent:hasCurrentPetAccessory()
	if next(self.petEquipAccessMap or EMPTY_TABLE) then
		return true
	end

	local petJewelryInfo = pg.me.petJewelryInfos and pg.me.petJewelryInfos[self.curPetId]
	local customShow = petJewelryInfo and petJewelryInfo.customShow

	if not customShow then
		return false
	end

	for _, genId in customShow:items() do
		if genId then
			return true
		end
	end

	return false
end

function PetComponent:refreshVitalityAccessoryShowState()
	if not self.inVitality then
		return
	end

	local data = self:getCurrentPetAccessoryData()

	self.accessoryUComponent:TryChangePage("Show", data and 1 or 0)

	if data then
		self:refreshVitalityView(data)
	end
end

function PetComponent:getCurrentPetAccessoryData()
	local petJewelryInfo = pg.me.petJewelryInfos and pg.me.petJewelryInfos[self.curPetId]
	local customShow = petJewelryInfo and petJewelryInfo.customShow

	if customShow then
		for _, genId in customShow:items() do
			local data = self.model:getAccessDataInDataList(genId)

			if data then
				return data
			end
		end
	end

	for _, instanceId in pairs(self.petEquipAccessMap or EMPTY_TABLE) do
		local data = self.model:getAccessDataInDataListWithInstId(instanceId)

		if data then
			return data
		end
	end

	return nil
end

function PetComponent:getAccessoryList(ignorePreview)
	local accessories = {}

	if self.inVitality then
		for _, accessoryId in pairs(self.vitalitySelectedAccessMap or EMPTY_TABLE) do
			table.insert(accessories, accessoryId)
		end

		return accessories
	end

	for index, access in pairs(self.petEquipAccessMap) do
		local underscorePos = string.find(access, "_")
		local result = access

		if underscorePos then
			result = string.sub(access, underscorePos + 1)
		end

		local accessoryId = tonumber(result)
		local accessoryTab = self.model:getTabInTabDataList(index)

		if ignorePreview and accessoryTab then
			if accessoryTab.isPreview or accessoryTab.isTry then
				if accessoryTab.isTry then
					table.insert(accessories, accessoryId)
				end
			else
				table.insert(accessories, accessoryId)
			end
		else
			table.insert(accessories, accessoryId)
		end
	end

	return accessories
end

function PetComponent:setVitalitySelectedAccessory(slot, accessoryId)
	if not self.inVitality or not slot or not accessoryId then
		return
	end

	self.vitalitySelectedAccessMap = self.vitalitySelectedAccessMap or {}
	self.vitalitySelectedAccessMap[slot] = tonumber(accessoryId)
end

function PetComponent:clearVitalitySelectedAccessory(slot)
	if not self.inVitality or not slot or not self.vitalitySelectedAccessMap then
		return
	end

	self.vitalitySelectedAccessMap[slot] = nil
end

function PetComponent:refreshVitalityView(data)
	if not data then
		return
	end

	ClientTextUtils.setText(self.txtNameUBaseText, data.name)
	ClientTextUtils.setText(self.scrollRectUScrollRect.content:GetComponent("USDFText"), pg.getLocalizationText(ItemData[data.accessoryId].itemDes or ""))

	local themeData = EnergyMatchThemeData[self.ctrl.vitalityPhase][self.ctrl.vitalityThemeId]
	local sumScore, accessoryScoreData = ActivityUtils.caculateAccessories({
		data.accessoryId
	}, themeData, self.ctrl.vitalityPhase, pg.me)

	self:setVitalityAccessoryScoreText(sumScore)
	ClientTextUtils.setText(self.textNumber1UBaseText, data.fashion or 0)
	ClientTextUtils.setText(self.textNumber2UBaseText, accessoryScoreData.tagScore)

	local accessoriesData = EnergyMatchAccessoriesData[data.accessoryId]

	if accessoriesData then
		for index, tagId in pairs(accessoriesData.accessoryTag) do
			if index == 1 then
				ClientTextUtils.setText(self.tag1Text, pg.getLocalizationText(EnergyAccessoriesTagData[tagId].tagName))
			else
				ClientTextUtils.setText(self.tag2Text, pg.getLocalizationText(EnergyAccessoriesTagData[tagId].tagName))
			end
		end

		self.tag1LabelUComponent.gameObject:SetActiveEx(#accessoriesData.accessoryTag >= 1)
	else
		self.tag1LabelUComponent.gameObject:SetActiveEx(false)
		self.tag2LabelUComponent.gameObject:SetActiveEx(false)
	end

	local sourceList = self:getSourceList(data.accessoryId)

	self.sourceUList2:SetList(sourceList)
	self.useUWidget.gameObject:SetActiveEx(data.state == LuaUIUtils.SELECT_STATE.TRY)
end

function PetComponent:getMatchTagCount(accessoryId)
	local themeData = EnergyMatchThemeData[self.ctrl.vitalityPhase][self.ctrl.vitalityThemeId]
	local accessoriesData = EnergyMatchAccessoriesData[accessoryId]
	local matchTagCount = 0

	if themeData and accessoriesData then
		for _, accessoryId in pairs(themeData.accessoryTheme) do
			for _, curAccessoryId in pairs(accessoriesData.accessoryTag) do
				if accessoryId == curAccessoryId then
					matchTagCount = matchTagCount + 1
				end
			end
		end
	end

	return matchTagCount
end

PetComponent.STALE_PET_ACCESS_CLEANUP_DELAYS = {
	0.05,
	0.2
}
PetComponent.UNOWNED_PREVIEW_DEBOUNCE = 0.3

function PetComponent:getPetEntityAndModelView()
	local entity = self.avatarScene and self.avatarScene:getCurEntity()

	if not entity or not entity.eModel then
		return nil, nil
	end

	return entity, entity.eModel.modelView
end

function PetComponent:buildValidPetAccessInstanceIdSet()
	local validIds = {}

	for _, instanceId in pairs(self.curPetAccessMap) do
		if instanceId then
			validIds[instanceId] = true
		end
	end

	return validIds
end

function PetComponent:syncPetAccessValidIds(entity)
	entity = entity or self.avatarScene and self.avatarScene:getCurEntity()

	if entity then
		entity._validPetAccessInstanceIds = self:buildValidPetAccessInstanceIdSet()
	end
end

function PetComponent:removeStalePetAccessAttaches(modelView)
	if not modelView or IsNil(modelView) or not modelView.modelInfo then
		return
	end

	local validIds = self:buildValidPetAccessInstanceIdSet()
	local runtimeAttachInfos = modelView:GetAllRuntimeAttachModelInfos()

	if not runtimeAttachInfos then
		return
	end

	local modelInfo = modelView.modelInfo

	for instanceId, _ in pairs(runtimeAttachInfos) do
		if not validIds[instanceId] then
			modelInfo:RemoveAttachInfoWithId(instanceId)
		end
	end
end

function PetComponent:clearSlotPetAccessRecord(slot)
	self.curPetAccessMap[slot] = nil
	self.petEquipAccessMap[slot] = nil

	self:clearVitalitySelectedAccessory(slot)
end

function PetComponent:detachSlotPetAccess(modelView, slot)
	if not modelView or not modelView.modelInfo then
		return
	end

	local instanceId = self.curPetAccessMap[slot]

	self:clearSlotPetAccessRecord(slot)
	AppearanceEffectUtils.setPetAccessory(self.avatarScene:getCurEntity(), slot, nil)

	if instanceId then
		modelView.modelInfo:RemoveAttachInfoWithId(instanceId)
	end
end

function PetComponent:preparePetAccessChange(modelView, slot, nextInstanceId)
	if slot and nextInstanceId then
		self.curPetAccessMap[slot] = nextInstanceId
	end

	self:syncPetAccessValidIds()

	if modelView then
		self:removeStalePetAccessAttaches(modelView)
	end
end

function PetComponent:applyPetAccessAndRefresh(modelView, modelInfo, slot, attachInfo, isPreview, skipVitalitySelect)
	self:preparePetAccessChange(modelView, slot, attachInfo.instanceId)
	self:showPartAccessInternal(modelInfo, attachInfo, slot, isPreview, skipVitalitySelect)

	local entity = self.avatarScene:getCurEntity()

	ClientModelUtils.refreshModels(entity, modelView)
	self:afterRefreshModel(modelView)
end

function PetComponent:scheduleStalePetAccessCleanup(modelView)
	if not modelView then
		return
	end

	local seq = self.petAccessRefreshSeq or 0

	local function cleanupIfCurrent()
		if seq ~= self.petAccessRefreshSeq then
			return
		end

		self:removeStalePetAccessAttaches(modelView)
	end

	TimerManager.addNextFrameCb(cleanupIfCurrent)

	for _, delay in ipairs(PetComponent.STALE_PET_ACCESS_CLEANUP_DELAYS) do
		TimerManager.addTimer(delay, cleanupIfCurrent)
	end
end

function PetComponent:checkUnloadOrSwitch(data)
	if data.slot == self.selectTabIdx then
		self:unloadPartAccess(data)
	else
		self:switchPartAccess(data)
	end
end

function PetComponent:unloadPartAccess(data)
	if not self:checkCanUnload(data.refPetId, data.genId) then
		return
	end

	local setInfo = {
		{
			self.selectTabIdx,
			data.genId,
			false
		}
	}

	self.model:equipAccess2Server(setInfo, function(res)
		if not res then
			return
		end

		pg.global.showBubbleMessageRaw(pg.getGameString("PET_ACCESSORY_UNEQUIP_SUCCESS"), 3)
		self:unloadPartAccessCallback(data)
	end)
end

function PetComponent:unloadPartAccessCallback(data)
	local tabData = self.model:getTabInTabDataList(self.selectTabIdx)

	self.model:setPreviewData(tabData, false, data)
	self:selectSubItem(data, false)
	self:refreshAllList(data)
	self:checkClearOldPreview()

	local entity, modelView = self:getPetEntityAndModelView()

	if not modelView then
		return
	end

	self:detachSlotPetAccess(modelView, self.selectTabIdx)
	self:syncPetAccessValidIds(entity)
	self:removeStalePetAccessAttaches(modelView)
	ClientModelUtils.refreshModels(entity, modelView)
	self:afterRefreshModel(modelView)
	self:refreshVitalityScore()
end

function PetComponent:checkCanUnload(petId, genId)
	if petId ~= self.curPetId then
		return false
	end

	local data = self.model:getTabInTabDataList(self.selectTabIdx)

	if not data then
		return false
	end

	if data.genId == nil or genId == nil then
		return false
	end

	return data.genId == genId
end

function PetComponent:equipPartAccess(data)
	local setInfo = {
		{
			self.selectTabIdx,
			data.genId,
			true
		}
	}

	self.model:equipAccess2Server(setInfo, function(res)
		if not res then
			return
		end

		pg.global.showBubbleMessageRaw(pg.getGameString("PET_ACCESSORY_EQUIP_SUCCESS"), 3)
		self:equipAccessCallback(data)
	end)
end

function PetComponent:equipAccessCallback(data)
	local tabData = self.model:getTabInTabDataList(self.selectTabIdx)

	self.model:setPreviewData(tabData, false, data)
	self:selectSubItem(data, true)
	self:refreshAllList(data)
	self:checkClearOldPreview()

	local _, modelView = self:getPetEntityAndModelView()

	if not modelView then
		return
	end

	local attachInfo = self:parseServerCacheAccessInfo(data)

	self:applyPetAccessAndRefresh(modelView, modelView.modelInfo, self.selectTabIdx, attachInfo)
end

function PetComponent:switchPartAccess(data)
	local setInfo = {
		{
			self.selectTabIdx,
			data.genId,
			true
		}
	}

	self.model:equipAccess2Server(setInfo, function(res)
		if not res then
			return
		end

		pg.global.showBubbleMessageRaw(pg.getGameString("PET_ACCESSORY_EQUIP_SUCCESS"), 3)
		self:switchPartAccessCallback(data)
	end)
end

function PetComponent:switchPartAccessCallback(data)
	local oldSlot = data.slot

	self:selectSubItem(data, false)
	self:refreshAllList(data)
	self:checkClearOldPreview()

	local _, modelView = self:getPetEntityAndModelView()

	if not modelView then
		return
	end

	self:detachSlotPetAccess(modelView, self.selectTabIdx)

	if self.selectTabIdx ~= oldSlot then
		self:detachSlotPetAccess(modelView, oldSlot)
	end

	local attachInfo = self:parseServerCacheAccessInfo(data)

	self:applyPetAccessAndRefresh(modelView, modelView.modelInfo, self.selectTabIdx, attachInfo)
end

function PetComponent:parseServerCacheAccessInfo(data)
	return self.model:getServerCacheAccessInfo(data, self.modelSliderInfo)
end

function PetComponent:shouldDebounceUnownedPreview(data)
	if not data or data.state ~= LuaUIUtils.SELECT_STATE.LOCKED then
		return false
	end

	local now = Time.realSecondCache
	local last = self._unownedPreviewDebounce

	if last and last.instanceId == data.instanceId and now - last.time < PetComponent.UNOWNED_PREVIEW_DEBOUNCE then
		return true
	end

	self._unownedPreviewDebounce = {
		instanceId = data.instanceId,
		time = now
	}

	return false
end

function PetComponent:checkPreviewAccess(data)
	if self:shouldDebounceUnownedPreview(data) then
		return
	end

	local tabData = self.model:getTabInTabDataList(self.selectTabIdx)

	if tabData.isPreview and tabData.previewInstId == data.instanceId then
		self:previewUnloadAccess(data)
	else
		self:previewEquipAccess(data)
	end
end

function PetComponent:previewEquipAccess(data)
	local tabData = self.model:getTabInTabDataList(self.selectTabIdx)

	self.model:setPreviewData(tabData, true, data)
	self:selectSubItem(data, true)
	self:refreshAllList(data)

	local _, modelView = self:getPetEntityAndModelView()

	if not modelView then
		return
	end

	local attachInfo = self:parseServerCacheAccessInfo(data)
	local isPreview = data.isPreview and not data.isTry

	self:applyPetAccessAndRefresh(modelView, modelView.modelInfo, self.selectTabIdx, attachInfo, isPreview)
	self:scheduleStalePetAccessCleanup(modelView)
end

function PetComponent:previewUnloadAccess(data)
	self:refreshAllList(data)

	local tabData = self.model:getTabInTabDataList(self.selectTabIdx)

	self.model:setPreviewData(tabData, false, data)

	local curEnt = self.avatarScene:getCurEntity()
	local modelView = curEnt.eModel.modelView
	local modelInfo = modelView.modelInfo
	local slot = self.selectTabIdx

	AppearanceEffectUtils.setPetAccessory(curEnt, slot, nil)

	local oldInstanceId = self.curPetAccessMap[self.selectTabIdx]

	if oldInstanceId then
		self.curPetAccessMap[self.selectTabIdx] = nil
		self.petEquipAccessMap[self.selectTabIdx] = nil

		self:clearVitalitySelectedAccessory(self.selectTabIdx)
		modelInfo:RemoveAttachInfoWithId(oldInstanceId)
	end

	self:selectSubItem(data, false)

	if tabData.genId then
		local jerInfo = pg.me.petJewelryInfos[self.curPetId]
		local equippedData = self.model:getAccessDataInDataList(tabData.genId)
		local slotInfo = jerInfo and jerInfo[slot]
		local serverInfo = equippedData and PetJewelryOssCache.getSavedTransform(self.curPetId, equippedData.accessoryId, slotInfo)

		if serverInfo then
			data = self:equipServerAccess(modelView, slot, serverInfo, tabData.genId, true)
		else
			local genId = jerInfo.customShow[slot]

			data = self:equipDefaultAccess(modelView, slot, genId, true)
		end

		if data then
			self:selectSubItem(data, true)
		end
	end

	modelView:RefreshAttachModel()
	curEnt:refreshAppearanceAttachEffects()
	self:afterRefreshModel(modelView)
	self:refreshVitalityScore()
end

function PetComponent:checkClearOldPreview()
	local tabData = self.model:getTabInTabDataList(self.selectTabIdx)

	if not tabData.isPreview then
		return
	end

	local data = self.model:getSelectAccessData()

	self.model:setPreviewData(tabData, false, data)

	local curEnt = self.avatarScene:getCurEntity()
	local modelView = curEnt.eModel.modelView
	local modelInfo = modelView.modelInfo
	local oldInstanceId = self.curPetAccessMap[self.selectTabIdx]

	if oldInstanceId then
		modelInfo:RemoveAttachInfoWithId(oldInstanceId)
	end
end

function PetComponent:showPartAccessInternal(modelInfo, attachInfo, slot, isPreview, skipVitalitySelect)
	self.curPetAccessMap[slot] = attachInfo.instanceId

	if not isPreview then
		self.petEquipAccessMap[slot] = attachInfo.instanceId
	end

	self:syncPetAccessValidIds()

	local scale = Vector3.New(attachInfo.scale, attachInfo.scale, attachInfo.scale)

	modelInfo:AddAttachInfo(attachInfo.resId, attachInfo.instanceId, attachInfo.attachHp, attachInfo.localPosition, attachInfo.localRotation, scale, false)
	AppearanceEffectUtils.setPetAccessory(self.avatarScene:getCurEntity(), slot, attachInfo.accessoryId, attachInfo.instanceId, attachInfo.resId)

	if self.inVitality then
		if not isPreview and not skipVitalitySelect then
			self:setVitalitySelectedAccessory(slot, attachInfo.accessoryId)
		end

		self:refreshVitalityScore()
	end
end

function PetComponent:refreshIdleButton()
	local entity = self.avatarScene:getCurEntity()
	local state = entity:getCurrentPlayableState(PlayableConst.AnimationLayer.HUMAN_LAYER_BASE)
end

function PetComponent:onBtnPetIdle()
	local entity = self.avatarScene:getCurEntity()
	local state = entity:getCurrentPlayableState(PlayableConst.AnimationLayer.HUMAN_LAYER_BASE)

	if state then
		if state:GetSpeed() ~= 0 then
			state:SetSpeed(0)
		else
			state:SetSpeed(1)
		end
	end
end

function PetComponent:setPetIdle()
	self.avatarScene.waitFreezeEntity = false
	self.avatarScene.waitLoadEntity = false

	local entity = self.avatarScene:getCurEntity()
	local state = entity:getCurrentPlayableState(PlayableConst.AnimationLayer.HUMAN_LAYER_BASE)

	if state then
		state:SetSpeed(1)

		state.Time = 1
	end
end

function PetComponent:setPetTPose()
	self.avatarScene.waitLoadEntity = true
	self.avatarScene.waitFreezeEntity = true

	local entity = self.avatarScene:getCurEntity()
	local state = entity and entity:getCurrentPlayableState(PlayableConst.AnimationLayer.HUMAN_LAYER_BASE)

	if state then
		state.Time = 0

		state:SetSpeed(0)
	end
end

function PetComponent:parseSliderInfoWithOpName(data)
	local opName = data.opName
	local min, max, cur
	local info = self.modelSliderInfo

	if opName == 1 then
		cur = self.model:getAccessTransWithOpName(opName, info.defaultPos.x)
		min = info.minOffset.x
		max = info.maxOffset.x
	elseif opName == 2 then
		cur = self.model:getAccessTransWithOpName(opName, info.defaultPos.y)
		min = info.minOffset.y
		max = info.maxOffset.y
	elseif opName == 3 then
		cur = self.model:getAccessTransWithOpName(opName, info.defaultPos.z)
		min = info.minOffset.z
		max = info.maxOffset.z
	elseif opName == 5 or opName == 6 or opName == 7 then
		cur = self.model:getAccessTransWithOpName(opName, 0)
		min = -info.mapRotLength
		max = info.mapRotLength
	elseif opName == 8 then
		cur = self.model:getAccessTransWithOpName(opName, 1)
		min = info.minScale
		max = info.maxScale
	end

	if self.model:isPetAccessorySimpleMode() and opName >= 1 and opName <= 3 then
		local offsetRange = math.abs(info.maxOffset.x - info.minOffset.x) * 0.5

		min = -offsetRange
		max = offsetRange
	end

	data.oldMin = min
	data.oldMax = max
	data.newMin = -info.mapPosLength
	data.newMax = info.mapPosLength

	local newCur = AvatarUtils.parseSliderMapValue(min, max, data.newMin, data.newMax, cur)

	return data.newMin, data.newMax, newCur
end

function PetComponent:onModelSkeletonLoaded()
	if not self.model or not self.avatarScene then
		return
	end

	local entity = self.avatarScene:getCurEntity()

	if entity == nil or not entity.eModel then
		return
	end

	self:refreshPetJewelrySliderDepthRange()
	self.model:setAvatarScene(self.avatarScene)

	local petJewelryInfo = pg.me.petJewelryInfos[self.curPetId]

	if petJewelryInfo == nil then
		return
	end

	for slot, genId in petJewelryInfo.customShow:items() do
		local data = self.model:getAccessDataInDataList(genId)
		local tabData = self.model:getTabInTabDataList(slot)

		if data and not tabData.isPreview then
			self.curPetAccessMap[slot] = data.instanceId
			self.petEquipAccessMap[slot] = data.instanceId

			self:setVitalitySelectedAccessory(slot, data.accessoryId)
		end
	end

	if self.needRecordDefaultAccessory then
		self.recordAccessory = {}

		for _, id in pairs(self.curPetAccessMap) do
			table.insert(self.recordAccessory, id)
		end
	end

	self.needRecordDefaultAccessory = false

	self:syncPetAccessValidIds(entity)
	self:refreshVitalityAccessoryShowState()
	self:refreshVitalityScore()
end

function PetComponent:equipDefaultAccess(modelView, slot, genId, skipVitalitySelect)
	local modelInfo = modelView.modelInfo
	local data = self.model:getAccessDataInDataList(genId)

	if not data then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("@zqd equip pet access with default data error!", tostring(genId))
		end

		return
	end

	local attachInfo = self.model:parseDefaultAccessInfo(data, self.modelSliderInfo)

	self:showPartAccessInternal(modelInfo, attachInfo, slot, nil, skipVitalitySelect)

	return data
end

function PetComponent:equipServerAccess(modelView, slot, v, genId, skipVitalitySelect)
	local data = self.model:getAccessDataInDataList(genId)

	if not data then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("@zqd equip pet access with server data error!", tostring(genId))
		end

		return
	end

	local instanceId = data.instanceId or "error"
	local attachInfo = self:parseServerAccess(v, instanceId)
	local modelInfo = modelView.modelInfo

	self:showPartAccessInternal(modelInfo, attachInfo, slot, nil, skipVitalitySelect)

	return data
end

function PetComponent:parseServerAccess(info, instanceId)
	local targetPos = Vector3.New(info.posX, info.posY, info.posZ)
	local targetRot = Vector3.New(info.rotX, info.rotY, info.rotZ)
	local targetScl = info.scale
	local attachInfo = {
		accessoryId = info.configId,
		instanceId = instanceId,
		attachHp = info.attachBone,
		resId = AppearanceJewelryPetData[info.configId].res,
		localPosition = targetPos,
		localRotation = targetRot,
		scale = targetScl
	}

	return attachInfo
end

function PetComponent:onPetBoxSelected(petId)
	self:showPetModel(petId)
end

function PetComponent:afterRefreshModel(modelView)
	self.petAccessRefreshSeq = (self.petAccessRefreshSeq or 0) + 1

	local seq = self.petAccessRefreshSeq

	modelView:SetAllAttachTransformRefreshedCb(function()
		if seq ~= self.petAccessRefreshSeq then
			return
		end

		local entity = self.avatarScene:getCurEntity()

		if not entity then
			return
		end

		self:removeStalePetAccessAttaches(modelView)
		self:syncPetAccessValidIds(entity)
	end)
end

function PetComponent:passToRightInfoComponent(originCmp, extra)
	return self.ctrl:passToRightInfoComponent(originCmp, extra)
end

return PetComponent
