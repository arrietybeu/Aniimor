-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\InventoryPetPropUse\\InventoryPetPropUseCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("InventoryPetPropUseCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local InventoryPetPropUseCtrl = Class.LightClass("InventoryPetPropUseCtrl", UICtrl)
local ItemConst = require("Common.Const.ItemConst")
local NoticeDef = require("Common.NoticeDef")
local PetManagementUtils = require("Utils.PetManagementUtils")
local ClientUtils = require("Utils.ClientUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local LuaMsgUtils = require("Utils.LuaMsgUtils")
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local TimeUtils = require("Common.Utils.TimeUtils")
local PetShinyStyleData = require("Data.pet_shiny_style_data")
local BTN_PAGE_ENABLED = 0
local BTN_PAGE_DISABLED = 4
local ITEM_STATE_USABLE = 0
local ITEM_STATE_UNUSABLE = 1
local TRAIN_STATE_NORMAL = 0
local TRAIN_STATE_IMPROVED = 1
local TRAIN_STATE_MAX = 2
local TYPE_PAGE_NORMAL = 0
local TYPE_PAGE_CHANGE_LABEL = 1
local TYPE_PAGE_SAME_LABEL = 2
local PET_DETAIL_PAGE_ATTRIBUTE = 0
local PET_DETAIL_PAGE_INFO = 2
local LABEL_ICON_MAP = {
	[Const.PET_LABEL_MASK.NORMAL] = "$UI_Img_PetSbumit_CatchQuantity.png",
	[Const.PET_LABEL_MASK.SHINY] = "$UI_Img_Inventory_UseProp_Flash.png",
	[Const.PET_LABEL_MASK.ELITE] = "$UI_Img_PetSbumit_Hugesize.png"
}
local LABEL_NAME_KEY_MAP = {
	[Const.PET_LABEL_MASK.NORMAL] = "PET_LABEL_NORMAL",
	[Const.PET_LABEL_MASK.SHINY] = "PET_LABEL_SHINY",
	[Const.PET_LABEL_MASK.BOSS] = "FILTER_BOSS",
	[Const.PET_LABEL_MASK.ELITE] = "PET_LABEL_ELITE",
	[Const.PET_LABEL_MASK.VARIANT] = "FILTER_VARIANT",
	[Const.PET_LABEL_MASK.DARK] = "PET_DARK_LABEL_TITLE",
	[Const.PET_LABEL_MASK.RAINBOW] = "PET_ELITESIZE_LABEL_TITLE_MINI"
}
local SHINY_STYLE_ICON_MAP = {
	[Const.PET_SHINY_STYLE.BLACK] = "$UI_Img_Inventory_UseProp_FlashBlack.png",
	[Const.PET_SHINY_STYLE.WHITE] = "$UI_Img_Inventory_UseProp_FlashWhite.png"
}
local SHINY_STYLE_NAME_KEY_MAP = {
	[Const.PET_SHINY_STYLE.BLACK] = "INVENTORY_PETPROP_SHADOW_SHINY",
	[Const.PET_SHINY_STYLE.WHITE] = "INVENTORY_PETPROP_DAZZLING_SHINY"
}
local RANDOM_SHINY_STYLE_ICON = "$UI_Img_Inventory_UseProp_FlashRandom.png"
local LABEL_MATERIAL = "$VX_Mat_PetTag_Form_Color_01.mat"
local SHINY_ITEM_CONFIRM_CONFIG = {
	[ItemConst.SHINY_CHANGE_ITEM_ID] = {
		descKey = "INVENTORY_PETPROP_SHINY_CHANGE_CONFIRM",
		prefKey = ClientConst.PrefKey.InventoryPetShinyChangeTipTs
	},
	[ItemConst.SHINY_REFRESH_ITEM_ID] = {
		descKey = "INVENTORY_PETPROP_SHINY_REFRESH_CONFIRM",
		prefKey = ClientConst.PrefKey.InventoryPetShinyRefreshTipTs
	}
}

local function getLabelIconUrl(labelId)
	return LABEL_ICON_MAP[labelId] or LABEL_ICON_MAP[Const.PET_LABEL_MASK.NORMAL]
end

local function getLabelName(labelId)
	local key = LABEL_NAME_KEY_MAP[labelId]

	return key and ClientTextUtils.getGameString(key) or tostring(labelId)
end

local function getShinyStyleIconUrl(shinyStyle)
	return SHINY_STYLE_ICON_MAP[shinyStyle] or getLabelIconUrl(Const.PET_LABEL_MASK.SHINY)
end

local function getShinyStyleName(shinyStyle)
	local key = SHINY_STYLE_NAME_KEY_MAP[shinyStyle]

	return key and pg.getGameString(key) or getLabelName(Const.PET_LABEL_MASK.SHINY)
end

local function getConfiguredShinyStyleName(shinyStyle)
	local key = SHINY_STYLE_NAME_KEY_MAP[shinyStyle]

	if key then
		return pg.getGameString(key)
	end

	local styleData = PetShinyStyleData[shinyStyle]

	return styleData and pg.getLocalizationText(styleData.name) or getLabelName(Const.PET_LABEL_MASK.SHINY)
end

local function getTargetLabelDisplay(targetLabel, labelParam)
	if targetLabel ~= Const.PET_LABEL_MASK.SHINY then
		return getLabelIconUrl(targetLabel), getLabelName(targetLabel)
	end

	if labelParam and labelParam ~= 0 then
		return getShinyStyleIconUrl(labelParam), getConfiguredShinyStyleName(labelParam)
	end

	return RANDOM_SHINY_STYLE_ICON, pg.getGameString("INVENTORY_PETPROP_RANDOM_SHINY")
end

local function setLabelIcon(image, iconUrl, labelId)
	image.url = iconUrl

	if labelId == 0 then
		image.material = ""
	else
		image:SetMaterial(LABEL_MATERIAL)
	end
end

local ATTRI_TEMPLATE_CHANGE_PET_SIZE_TYPE = 1
local RANDOM_TO_TALENT_ITEM_COUNT = 4

local function buildChangePetSizeTypeItemData(petData)
	local normalText = pg.getGameString("USEITEM_TYPE_CHANGE_PET_SIZE_DESC2")
	local bossText = pg.getGameString("USEITEM_TYPE_CHANGE_PET_SIZE_DESC3")
	local beforeText = normalText
	local afterText = bossText
	local petInfo = petData and petData.id and pg.me:getPetInfo(petData.id)
	local bodySizeType = petInfo and petInfo.bodySizeType or petData and petData.bodySizeType

	if bodySizeType == Const.PET_BODY_SIZE_TYPE.NORMAL then
		beforeText = bossText
		afterText = normalText
	end

	return {
		tIndex = ATTRI_TEMPLATE_CHANGE_PET_SIZE_TYPE,
		title = pg.getGameString("USEITEM_TYPE_CHANGE_PET_SIZE_DESC1"),
		before = beforeText,
		after = afterText
	}
end

InventoryPetPropUseCtrl.messages = {
	[MessageName.PET_TALENT_LIST_CHANGED] = {
		"onPetTalentListChanged",
		true
	},
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"onItemCountMapChanged",
		true
	}
}

function InventoryPetPropUseCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.petData = nil
	self.propData = info.propData
	self.sType = info.sType
	self.targetPetId = info.petId
	self.modifyLabelConfig = self.sType == ItemConst.USEITEM_TYPE_MODIFY_PET_LABEL and self.model:getModifyPetLabelConfig(self.propData.itemId) or nil
	self.changeList = nil

	self:initUI()
end

function InventoryPetPropUseCtrl:addListener()
	function self.view.btnBack.luaClick()
		self:dismiss()
	end
end

function InventoryPetPropUseCtrl:onDestroy()
	UICtrl.onDestroy(self)
	PetManagementUtils.destroyTemplate(self)

	self.detailRefs = nil
end

function InventoryPetPropUseCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:initData(info)
end

function InventoryPetPropUseCtrl:onPostOpen(info, isReOpen)
	UICtrl.onPostOpen(self, info, isReOpen)

	if not isReOpen then
		return
	end

	self.petData = nil
	self.changeList = nil
	self.detailRefs = nil
	self.isSameLabel = false
	self.hideLabelInfo = false

	self.view.consumeUWidget:SetActive(true)
	PetManagementUtils.destroyTemplate(self)
	self:initUI()
end

function InventoryPetPropUseCtrl:onShow()
	TimerManager.addNextFrameCb(function()
		self.view.rootAnimation:Play()
	end)
end

function InventoryPetPropUseCtrl:onHide()
	return
end

function InventoryPetPropUseCtrl:afterInit()
	PetManagementUtils.initMsg(self)
end

function InventoryPetPropUseCtrl:initData(info)
	self.propData = info.propData
	self.sType = info.sType
	self.targetPetId = info.petId
	self.modifyLabelConfig = self.sType == ItemConst.USEITEM_TYPE_MODIFY_PET_LABEL and self.model:getModifyPetLabelConfig(self.propData.itemId) or nil
end

function InventoryPetPropUseCtrl:checkCanOpen(showNotice, info)
	if info and info.sType == ItemConst.USEITEM_TYPE_CHANGE_PET_LABEL then
		local usablePetId = self.model:findUsablePetForChangeLabel(info.propData.itemId)

		if not usablePetId then
			if showNotice then
				pg.global.ui.tips:showTextTip(pg.getGameString("INVENTORY_PETPROP_NO_AVAILABLE_PET"))
			end

			return false
		end
	elseif info and info.sType == ItemConst.USEITEM_TYPE_MODIFY_PET_LABEL then
		local usablePetId = self.model:findUsablePetForModifyPetLabel(info.propData.itemId)

		if not usablePetId then
			if showNotice then
				pg.global.ui.tips:showTextTip(pg.getGameString("INVENTORY_PETPROP_NO_AVAILABLE_PET"))
			end

			return false
		end
	elseif info and info.sType == ItemConst.USEITEM_TYPE_CHANGE_PET_SIZE_TYPE then
		local usablePetId = self.model:findUsablePetForChangePetSizeType()

		if not usablePetId then
			if showNotice then
				pg.global.ui.tips:showTextTip(pg.getGameString("INVENTORY_PETPROP_NO_AVAILABLE_PET"))
			end

			return false
		end
	end

	return UICtrl.checkCanOpen(self, showNotice, info)
end

function InventoryPetPropUseCtrl:initUI()
	function self.view.listCostUList.luaRenderItem(button, _, data)
		LuaUIUtils.renderItemWithCountCheck(button, data, nil, true)
	end

	local petIdToSelect = self.targetPetId

	if self.sType == ItemConst.USEITEM_TYPE_CHANGE_PET_SIZE_TYPE then
		if petIdToSelect and not self.model:canUseChangePetSizeTypeOnPet(petIdToSelect) then
			petIdToSelect = nil
		end

		if not petIdToSelect then
			petIdToSelect = self.model:findUsablePetForChangePetSizeType()
		end
	elseif self.sType == ItemConst.USEITEM_TYPE_MODIFY_PET_LABEL then
		if petIdToSelect and not self.model:checkModifyPetLabelOnPet(petIdToSelect, self.modifyLabelConfig) then
			petIdToSelect = nil
		end

		if not petIdToSelect then
			petIdToSelect = self.model:findUsablePetForModifyPetLabel(self.propData.itemId)
		end
	elseif not petIdToSelect and self.sType == ItemConst.USEITEM_TYPE_CHANGE_PET_LABEL then
		petIdToSelect = self.model:findUsablePetForChangeLabel(self.propData.itemId)
	end

	PetManagementUtils.destroyTemplate()
	PetManagementUtils.setListButtonDelegateTable({
		luaPress = function(button, index, petData)
			if self.sType == ItemConst.USEITEM_TYPE_CHANGE_PET_SIZE_TYPE and petData and petData.id and not self.model:canUseChangePetSizeTypeOnPet(petData.id) then
				return false
			end
		end,
		selectedChanged = function(data)
			if not self.petData or self.petData.id ~= data.id then
				self.view.widget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
			end

			self.petData = data

			self:refreshPropInfo(data)
		end,
		renderExtraLogic = function(button, index, petData)
			self:renderPetListItem(button, petData)
		end
	}, self)
	PetManagementUtils.initTemplate(self.view.petInfoPanelTransform, self.view.petListTransform, {
		defaultSelectTabIndex = 0,
		owner = self,
		uiScene = self.uiScene,
		selectPetId = petIdToSelect
	})

	if not petIdToSelect then
		PetManagementUtils.setSelectedPet(0)
	end
end

function InventoryPetPropUseCtrl:isCatchReporting(petId)
	local pet = pg.me:getPetInfo(petId)

	return pet ~= nil and pet:isCatchReporting()
end

function InventoryPetPropUseCtrl:getDetailRefs()
	if self.detailRefs then
		return self.detailRefs
	end

	local ref = self.view.scrollRect.content:GetComponent("ObjectReference")

	self.detailRefs = {
		btnFeatures1 = ref:GetRefValue("btnFeatures1"),
		btnFeatures2 = ref:GetRefValue("btnFeatures2"),
		txtFeaturesName1 = ref:GetRefValue("txtFeaturesName1"),
		txtFeaturesName2 = ref:GetRefValue("txtFeaturesName2"),
		usedUWidget = ref:GetRefValue("usedUWidget"),
		listAttri = ref:GetRefValue("listAttri"),
		txtTips = ref:GetRefValue("txtTips"),
		featureUWidget = ref:GetRefValue("featureUWidget"),
		txtDescUBaseText = ref:GetRefValue("txtDescUBaseText"),
		textUsedUBaseText = ref:GetRefValue("textUsedUBaseText"),
		labelIcon1UImage = ref:GetRefValue("labelIcon1UImage"),
		textLabel1UBaseText = ref:GetRefValue("textLabel1UBaseText"),
		labelIcon2UImage = ref:GetRefValue("labelIcon2UImage"),
		textLabel2UBaseText = ref:GetRefValue("textLabel2UBaseText"),
		curLabelIconUImage = ref:GetRefValue("curLabelIconUImage"),
		textAlreadyLabelUBaseText = ref:GetRefValue("textAlreadyLabelUBaseText")
	}

	return self.detailRefs
end

function InventoryPetPropUseCtrl:renderPetListItem(button, petData)
	button.draggable = false

	button:TryChangePage("isBoss", 0)

	local isPropertyEnhance = self.sType == ItemConst.USEITEM_TYPE_PROPERTY_ENHANCE
	local isCharacterRandom = self.sType == ItemConst.USEITEM_TYPE_PET_CHARACTER_RANDOM
	local isChangePetLabel = self.sType == ItemConst.USEITEM_TYPE_CHANGE_PET_LABEL
	local isModifyPetLabel = self.sType == ItemConst.USEITEM_TYPE_MODIFY_PET_LABEL
	local isChangePetSizeType = self.sType == ItemConst.USEITEM_TYPE_CHANGE_PET_SIZE_TYPE
	local isUsed = isPropertyEnhance and self.model:getEnhanceState(petData.id) == NoticeDef.ERROR_ALREADY_ENHANCED
	local canUse = not isUsed

	if canUse then
		if isPropertyEnhance then
			canUse = self.model:getEnhanceData(petData.id) and not self:isCatchReporting(petData.id)
		elseif isCharacterRandom then
			canUse = self.model:getCharacterRandomData(petData.id)
		elseif isChangePetLabel then
			local targetLabel, _, allowedTemplateIds = self.model:getChangeLabelParams(self.propData.itemId)

			canUse = targetLabel ~= nil and self.model:canUseChangeLabelOnPet(petData.id, targetLabel, allowedTemplateIds, self.propData.itemId)
		elseif isModifyPetLabel then
			canUse = self.model:checkModifyPetLabelOnPet(petData.id, self.modifyLabelConfig)
		elseif isChangePetSizeType then
			canUse = self.model:canUseChangePetSizeTypeOnPet(petData.id)
		end
	end

	local txtUsedUSDFText = button:GetComponent("ObjectReference"):GetRefValue("txtUsedUSDFText")

	if not canUse then
		local key = isUsed and "INVENTORY_PETPROP_USED" or "INVENTORY_PETPROP_CANTUSE"

		ClientTextUtils.setText(txtUsedUSDFText, ClientTextUtils.getGameString(key))
	end

	txtUsedUSDFText:SetActive(not canUse)
	button:TryChangePage("state", canUse and ITEM_STATE_USABLE or ITEM_STATE_UNUSABLE)
end

function InventoryPetPropUseCtrl:refreshPropInfo(petData)
	self.view.propInfoUWidget:SetActive(not petData.isEmpty)

	if petData.isEmpty then
		return
	end

	self:refreshPropHeader(petData)

	local refs = self:getDetailRefs()

	ClientTextUtils.setText(refs.txtDescUBaseText, pg.getLocalizationText(self.propData.funcRep))

	if self.sType == ItemConst.USEITEM_TYPE_CHANGE_PET_LABEL or self.sType == ItemConst.USEITEM_TYPE_MODIFY_PET_LABEL then
		self.view.propInfoUWidget:TryChangePage("type", TYPE_PAGE_CHANGE_LABEL)
	else
		self.view.propInfoUWidget:TryChangePage("type", TYPE_PAGE_NORMAL)
	end

	local canUse, tips

	if self.sType == ItemConst.USEITEM_TYPE_PROPERTY_ENHANCE then
		canUse, tips = self:refreshEnhanceView(petData, refs)
	elseif self.sType == ItemConst.USEITEM_TYPE_PET_CHARACTER_RANDOM then
		canUse, tips = self:refreshCharacterRandomView(petData, refs)
	elseif self.sType == ItemConst.USEITEM_TYPE_CHANGE_PET_LABEL then
		canUse, tips = self:refreshChangePetLabelView(petData, refs)
	elseif self.sType == ItemConst.USEITEM_TYPE_MODIFY_PET_LABEL then
		canUse, tips = self:refreshModifyPetLabelView(petData, refs)
	elseif self.sType == ItemConst.USEITEM_TYPE_CHANGE_PET_SIZE_TYPE then
		canUse, tips = self:refreshChangePetSizeTypeView(petData, refs)
	else
		canUse, tips = self:refreshRandomToTalentView(petData, refs)
	end

	self:refreshUseState(petData, refs, canUse, tips or "")
end

function InventoryPetPropUseCtrl:refreshPropHeader(petData)
	ClientTextUtils.setText(self.view.propName, pg.getLocalizationText(self.propData.name))
	ClientTextUtils.setText(self.view.typeName, pg.getLocalizationText(self.propData.typeName))

	if self.view.itemUContainer:CheckURLLoaded() then
		self:_renderItemCount(self.view.itemUContainer.content)
	else
		self.view.itemUContainer:LoadDefaultUrlManually(function(button)
			self:_renderItemCount(button)
		end)
	end

	self.view.propIcon.url = self.propData.icon
	self.view.imgPet.url = LuaUIUtils.getPetIcon(petData.iconName, LuaUIUtils.PET_CARD_ILLUSTRATE_BOOK)

	self.view.propInfoUWidget:TryChangePage("Quality", self.propData.quality)
end

function InventoryPetPropUseCtrl:_renderItemCount(button)
	local objectReference = button:GetComponent("ObjectReference")
	local countText = objectReference:GetRefValue("countText")

	ClientTextUtils.setText(countText, ClientUtils.getItemCountById(self.propData.itemId))
end

function InventoryPetPropUseCtrl:refreshEnhanceView(petData, refs)
	refs.featureUWidget:SetActive(false)

	local isUsed = self.model:getEnhanceState(petData.id) == NoticeDef.ERROR_ALREADY_ENHANCED

	if isUsed then
		self.changeList = nil

		refs.listAttri:SetActive(false)

		return false, pg.getGameString("INVENTORY_PETPROP_REASON_USED")
	end

	local canUse, changeList, tips = self.model:getEnhanceData(petData.id)

	if canUse and self:isCatchReporting(petData.id) then
		canUse = false
		tips = pg.getGameString("INVENTORY_PETPROP_REASON_REPORT")
	end

	self.changeList = changeList

	refs.listAttri:SetActive(canUse)

	if canUse then
		function refs.listAttri.luaRenderItem(button, index, data)
			self:refreshImproveItem(button, index, data)
		end

		refs.listAttri:SetList(changeList)
	end

	return canUse, tips
end

function InventoryPetPropUseCtrl:refreshCharacterRandomView(petData, refs)
	refs.listAttri:SetActive(false)

	local canUse, changeList, tips = self.model:getCharacterRandomData(petData.id)

	self.changeList = changeList

	refs.featureUWidget:SetActive(canUse)

	if canUse then
		local btns = {
			refs.btnFeatures1,
			refs.btnFeatures2
		}
		local txtNames = {
			refs.txtFeaturesName1,
			refs.txtFeaturesName2
		}

		for k, featureInfo in ipairs(changeList) do
			PetManagementUtils.renderPetFeature(btns[k], featureInfo)
			ClientTextUtils.setText(txtNames[k], pg.getLocalizationText(featureInfo.name))
		end
	end

	return canUse, tips
end

function InventoryPetPropUseCtrl:refreshRandomToTalentView(petData, refs)
	refs.featureUWidget:SetActive(false)

	self.changeList = {}

	local breedTalent = petData and petData.breedTalent or {}

	for index = 1, RANDOM_TO_TALENT_ITEM_COUNT do
		local itemData = breedTalent[index] and Utils.deepCopyTable(breedTalent[index]) or {
			empty = true
		}

		itemData.tIndex = 1
		self.changeList[#self.changeList + 1] = itemData
	end

	refs.listAttri:SetActive(true)

	function refs.listAttri.luaRenderItem(button, index, data)
		self:refreshRandomToTalentItem(button, index, data)
	end

	refs.listAttri:SetList(self.changeList)

	local tips = pg.getGameString("INVENTORY_PETPROP_RANDOM_TO_TALENT_TIPS") or "INVENTORY_PETPROP_RANDOM_TO_TALENT_TIPS"

	return true, tips
end

function InventoryPetPropUseCtrl:refreshChangePetSizeTypeView(petData, refs)
	refs.featureUWidget:SetActive(false)
	refs.listAttri:SetActive(false)

	self.changeList = nil
	self.isSameLabel = false
	self.hideLabelInfo = false

	if not self.model:canUseChangePetSizeTypeOnPet(petData.id) then
		return false, ClientTextUtils.getGameString("INVENTORY_PETPROP_CANTUSE")
	end

	local ownNum = ClientUtils.getItemCountById(self.propData.itemId) or 0

	if ownNum < 1 then
		return false, ClientTextUtils.getGameString("INVENTORY_PETPROP_CANTUSE")
	end

	self.changeList = {
		buildChangePetSizeTypeItemData(petData)
	}

	refs.listAttri:SetActive(true)

	function refs.listAttri.luaRenderItem(button, index, data)
		self:refreshChangePetSizeTypeItem(button, index, data)
	end

	refs.listAttri:SetList(self.changeList)

	return true, nil
end

function InventoryPetPropUseCtrl:refreshChangePetLabelView(petData, refs)
	refs.featureUWidget:SetActive(true)
	refs.listAttri:SetActive(false)
	self.view.consumeUWidget:SetActive(true)

	self.changeList = nil
	self.isSameLabel = false
	self.hideLabelInfo = false

	local targetLabel, costNum, allowedTemplateIds = self.model:getChangeLabelParams(self.propData.itemId)

	if not targetLabel or not costNum then
		return false, ClientTextUtils.getGameString("INVENTORY_PETPROP_CANTUSE")
	end

	local petInfo = pg.me:getPetInfo(petData.id)
	local curLabel = petInfo and petInfo.label or petData.label or 0
	local hasTargetLabel = bit.band(curLabel, targetLabel) ~= 0
	local isTargetShiny = targetLabel == Const.PET_LABEL_MASK.SHINY
	local targetIconUrl = isTargetShiny and RANDOM_SHINY_STYLE_ICON or getLabelIconUrl(targetLabel)
	local targetLabelName = isTargetShiny and pg.getGameString("INVENTORY_PETPROP_RANDOM_SHINY") or getLabelName(targetLabel)

	setLabelIcon(refs.labelIcon1UImage, getLabelIconUrl(0), 0)
	setLabelIcon(refs.labelIcon2UImage, targetIconUrl, targetLabel)
	ClientTextUtils.setText(refs.textLabel1UBaseText, getLabelName(0))
	ClientTextUtils.setText(refs.textLabel2UBaseText, targetLabelName)

	local ownNum = ClientUtils.getItemCountById(self.propData.itemId)

	self.view.listCostUList:SetList({
		{
			id = self.propData.itemId,
			num = costNum
		}
	})

	local forbidKey = self.model:getHeraldryForbidKey(petData.id, targetLabel, self.propData.itemId)

	if forbidKey then
		self.hideLabelInfo = true

		return false, ClientTextUtils.getGameString(forbidKey)
	end

	if not self.model:isPetInAllowedList(petData.id, allowedTemplateIds) then
		self.hideLabelInfo = true

		return false, ClientTextUtils.getGameString("INVENTORY_PETPROP_NOT_TARGET")
	end

	if hasTargetLabel then
		setLabelIcon(refs.curLabelIconUImage, getLabelIconUrl(targetLabel), targetLabel)

		local tipText = string.format(pg.getGameString("INVENTORY_PETPROP_ALREADY_LABEL"), getLabelName(targetLabel))

		ClientTextUtils.setText(refs.textAlreadyLabelUBaseText, tipText)
		self.view.propInfoUWidget:TryChangePage("type", TYPE_PAGE_SAME_LABEL)

		self.isSameLabel = true

		return false, nil
	end

	if ownNum < costNum then
		return false, ClientTextUtils.getGameString("INVENTORY_PETPROP_CANTUSE")
	end

	return true, nil
end

function InventoryPetPropUseCtrl:refreshModifyPetLabelView(petData, refs)
	refs.featureUWidget:SetActive(true)
	refs.listAttri:SetActive(false)
	self.view.consumeUWidget:SetActive(true)

	self.changeList = nil
	self.isSameLabel = false
	self.hideLabelInfo = false

	local config = self.modifyLabelConfig

	if not config then
		self.hideLabelInfo = true

		return false, ClientTextUtils.getGameString("INVENTORY_PETPROP_CANTUSE")
	end

	local targetIconUrl, targetLabelName = getTargetLabelDisplay(config.targetLabel, config.labelParam)
	local petInfo = pg.me:getPetInfo(petData.id)
	local currentLabel = petInfo and petInfo.label or petData.label or Const.PET_LABEL_MASK.NORMAL
	local hasShinyLabel = bit.band(currentLabel, Const.PET_LABEL_MASK.SHINY) ~= 0

	if config.targetLabel == Const.PET_LABEL_MASK.SHINY and hasShinyLabel then
		local currentShinyStyle = petInfo and petInfo.shinyStyle or petData.shinyStyle or 0

		setLabelIcon(refs.labelIcon1UImage, getShinyStyleIconUrl(currentShinyStyle), Const.PET_LABEL_MASK.SHINY)
		ClientTextUtils.setText(refs.textLabel1UBaseText, getShinyStyleName(currentShinyStyle))
	else
		setLabelIcon(refs.labelIcon1UImage, getLabelIconUrl(Const.PET_LABEL_MASK.NORMAL), Const.PET_LABEL_MASK.NORMAL)
		ClientTextUtils.setText(refs.textLabel1UBaseText, getLabelName(Const.PET_LABEL_MASK.NORMAL))
	end

	setLabelIcon(refs.labelIcon2UImage, targetIconUrl, config.targetLabel)
	ClientTextUtils.setText(refs.textLabel2UBaseText, targetLabelName)
	self.view.listCostUList:SetList({
		{
			id = self.propData.itemId,
			num = config.consumeCount
		}
	})

	local canUse, tipsKey, isSameTarget = self.model:checkModifyPetLabelOnPet(petData.id, config)

	if not canUse then
		if isSameTarget then
			setLabelIcon(refs.curLabelIconUImage, targetIconUrl, config.targetLabel)

			local tipText = string.format(pg.getGameString("INVENTORY_PETPROP_ALREADY_LABEL"), targetLabelName)

			ClientTextUtils.setText(refs.textAlreadyLabelUBaseText, tipText)
			self.view.propInfoUWidget:TryChangePage("type", TYPE_PAGE_SAME_LABEL)

			self.isSameLabel = true

			return false, nil
		end

		self.hideLabelInfo = true

		return false, ClientTextUtils.getGameString(tipsKey or "INVENTORY_PETPROP_CANTUSE")
	end

	local ownNum = ClientUtils.getItemCountById(self.propData.itemId) or 0

	if ownNum < config.consumeCount then
		return false, ClientTextUtils.getGameString("INVENTORY_PETPROP_CANTUSE")
	end

	return true, nil
end

function InventoryPetPropUseCtrl:refreshUseState(petData, refs, canUse, tips)
	if self.isSameLabel then
		refs.usedUWidget:SetActive(false)
	else
		refs.usedUWidget:SetActive(not canUse)
	end

	if self.hideLabelInfo then
		refs.featureUWidget:SetActive(false)
		self.view.consumeUWidget:SetActive(false)
	end

	local hasTips = canUse and not string.isNilOrEmpty(tips)

	refs.txtTips:SetActive(hasTips)

	if canUse then
		ClientTextUtils.setText(refs.txtTips, tips)
	else
		ClientTextUtils.setText(refs.textUsedUBaseText, tips)
	end

	if canUse then
		function self.view.btnUse.luaClick()
			self:onClickUseItem(petData.id)
		end
	else
		self.view.btnUse.luaClick = nil
	end

	self.view.btnUse.interactable = canUse

	self.view.btnUse:TryChangePage("button", canUse and BTN_PAGE_ENABLED or BTN_PAGE_DISABLED)
end

function InventoryPetPropUseCtrl:refreshImproveItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtName = objectReference:GetRefValue("txtName")
	local txtNumBefore = objectReference:GetRefValue("txtNumBefore")
	local txtNumAfter = objectReference:GetRefValue("txtNumAfter")
	local txtAdd = objectReference:GetRefValue("txtAdd")
	local trainBeforeUComponent = objectReference:GetRefValue("trainBeforeUComponent")
	local trainAfterUComponent = objectReference:GetRefValue("trainAfterUComponent")
	local after = data.before + data.add

	ClientTextUtils.setText(txtName, data.name)
	ClientTextUtils.setText(txtNumBefore, data.before)
	ClientTextUtils.setText(txtAdd, "+" .. tostring(data.add))
	ClientTextUtils.setText(txtNumAfter, after)
	button:TryChangePage("IsAdd", data.add > 0 and 1 or 0)

	local beforeBtnState = data.beforeIsMax and TRAIN_STATE_MAX or TRAIN_STATE_NORMAL
	local afterBtnState = TRAIN_STATE_NORMAL

	if data.afterIsMax then
		afterBtnState = TRAIN_STATE_MAX
	elseif data.add > 0 then
		afterBtnState = TRAIN_STATE_IMPROVED
	end

	trainBeforeUComponent:TryChangePage("State", beforeBtnState)
	trainAfterUComponent:TryChangePage("State", afterBtnState)
end

function InventoryPetPropUseCtrl:refreshRandomToTalentItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	local txtBeforeUSDFText = objectReference:GetRefValue("txtBeforeUSDFText")
	local txtAfterUSDFText = objectReference:GetRefValue("txtAfterUSDFText")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local iconObjectReference = objectReference:GetRefValue("iconObjectReference")
	local iconUButton = objectReference:GetRefValue("iconUButton")
	local iconUImage = iconObjectReference:GetRefValue("iconUImage")

	button:TryChangePage("State", 1)

	iconUImage.url = data.icon

	iconUButton:TryChangePage("Quality", data.quality)
	ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.name))
	ClientTextUtils.setText(txtAfterUSDFText, "???")
end

function InventoryPetPropUseCtrl:refreshChangePetSizeTypeItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	local txtBeforeUSDFText = objectReference:GetRefValue("txtBeforeUSDFText")
	local txtAfterUSDFText = objectReference:GetRefValue("txtAfterUSDFText")

	ClientTextUtils.setText(txtTitleUSDFText, data.title)
	ClientTextUtils.setText(txtBeforeUSDFText, data.before)
	ClientTextUtils.setText(txtAfterUSDFText, data.after)
end

function InventoryPetPropUseCtrl:onClickUseItem(petId)
	if self:isRareShinyStyleReroll(petId) then
		ClientUtils.showConfirmRaw(pg.getGameString("RELEASE_WARN"), pg.getGameString("INVENTORY_PETPROP_RARE_SHINY_CONFIRM"), function()
			self:useItem(petId)
		end)

		return
	end

	if self:showShinyItemUseConfirm(petId) then
		return
	end

	self:useItem(petId)
end

function InventoryPetPropUseCtrl:showShinyItemUseConfirm(petId)
	local config = SHINY_ITEM_CONFIRM_CONFIG[self.propData.itemId]

	if not config then
		return false
	end

	local prefsCacheUtils = pg.global.prefsCacheUtils
	local lastIgnoreTime = prefsCacheUtils:getInt(config.prefKey, 0, ClientConst.CACHE_TYPE_FLAG.USER)
	local currentTime = Time.secondCache
	local isIgnoredToday = lastIgnoreTime > 0 and TimeUtils.getAreaDayBegin(lastIgnoreTime) == TimeUtils.getAreaDayBegin(currentTime)

	if isIgnoredToday then
		return false
	end

	local ignoreToday = false

	ClientUtils.showConfirmRaw(pg.getGameString("INVENTORY_PETPROP_USE_CONFIRM_TITLE"), pg.getGameString(config.descKey), function()
		if ignoreToday then
			prefsCacheUtils:setInt(config.prefKey, Time.secondCache, ClientConst.CACHE_TYPE_FLAG.USER)
			prefsCacheUtils:save()
		end

		self:useItem(petId)
	end, nil, nil, nil, nil, {
		hint = true,
		hintDesc = string.format(pg.getGameString("DISABLE_HINT"), 1),
		hintCb = function(isSelected)
			ignoreToday = isSelected
		end
	})

	return true
end

function InventoryPetPropUseCtrl:isRareShinyStyleReroll(petId)
	local targetLabel
	local targetShinyStyle = 0

	if self.sType == ItemConst.USEITEM_TYPE_CHANGE_PET_LABEL then
		targetLabel = self.model:getChangeLabelParams(self.propData.itemId)
	elseif self.sType == ItemConst.USEITEM_TYPE_MODIFY_PET_LABEL then
		local config = self.modifyLabelConfig

		targetLabel = config and config.targetLabel
		targetShinyStyle = config and config.labelParam or 0
	else
		return false
	end

	if targetLabel ~= Const.PET_LABEL_MASK.SHINY then
		return false
	end

	local petInfo = pg.me:getPetInfo(petId)

	if not petInfo or bit.band(petInfo.label or 0, Const.PET_LABEL_MASK.SHINY) == 0 then
		return false
	end

	if targetShinyStyle ~= 0 and targetShinyStyle == petInfo.shinyStyle then
		return false
	end

	local currentStyleData = PetShinyStyleData[petInfo.shinyStyle]

	return currentStyleData and currentStyleData.isRare == 1 or false
end

function InventoryPetPropUseCtrl:isShinyLabelItem()
	local targetLabel

	if self.sType == ItemConst.USEITEM_TYPE_CHANGE_PET_LABEL then
		targetLabel = self.model:getChangeLabelParams(self.propData.itemId)
	elseif self.sType == ItemConst.USEITEM_TYPE_MODIFY_PET_LABEL then
		targetLabel = self.modifyLabelConfig and self.modifyLabelConfig.targetLabel
	end

	return targetLabel == Const.PET_LABEL_MASK.SHINY
end

function InventoryPetPropUseCtrl:onPetTalentListChanged(info)
	if not info then
		return
	end

	self:refreshRandomToTalentAfterUse(info.petId)
end

function InventoryPetPropUseCtrl:onItemCountMapChanged(info)
	if not info or not self.propData or info.itemId ~= self.propData.itemId or not self.view.itemUContainer:CheckURLLoaded() then
		return
	end

	self:_renderItemCount(self.view.itemUContainer.content)
end

function InventoryPetPropUseCtrl:refreshRandomToTalentAfterUse(petId)
	if self.sType ~= ItemConst.USEITEM_TYPE_RANDOM_TO_TALENT or not self.petData or self.petData.id ~= petId then
		return
	end

	local latestPetData = self.model:getPetDisplayData(petId)

	if not latestPetData then
		return
	end

	self.petData = latestPetData

	PetManagementUtils._refreshPetInfoDetail(latestPetData)
	self:refreshPropInfo(latestPetData)
	self.view.widget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
end

function InventoryPetPropUseCtrl:useItem(petId)
	local petData = self.petData
	local changeList = self.changeList

	self.view.btnUse:TryChangePage("button", BTN_PAGE_DISABLED)

	local playShinyPresentation = self:isShinyLabelItem()
	local oldPetInfo

	if playShinyPresentation then
		local petInfo = pg.me:getPetInfo(petId)

		oldPetInfo = petInfo and petInfo:getRawTable()
	end

	local useCount = 1

	if self.sType == ItemConst.USEITEM_TYPE_CHANGE_PET_LABEL then
		local _, costNum = self.model:getChangeLabelParams(self.propData.itemId)

		useCount = costNum or 1
	elseif self.sType == ItemConst.USEITEM_TYPE_MODIFY_PET_LABEL then
		useCount = self.modifyLabelConfig and self.modifyLabelConfig.consumeCount or 1
	end

	LuaMsgUtils.useItemById(self.propData.itemId, useCount, {
		petId = petId
	}, function()
		local presentationStarted = false

		if self.sType == ItemConst.USEITEM_TYPE_RANDOM_TO_TALENT then
			return
		elseif self.sType == ItemConst.USEITEM_TYPE_CHANGE_PET_LABEL or self.sType == ItemConst.USEITEM_TYPE_MODIFY_PET_LABEL then
			if self.petData then
				self:refreshPropInfo(self.petData)
			end

			if playShinyPresentation then
				if PetManagementUtils.pageIndex == PET_DETAIL_PAGE_INFO then
					PetManagementUtils._switchPetInfoTopPages(PET_DETAIL_PAGE_ATTRIBUTE)
				end

				local newPetInfo = pg.me:getPetInfo(petId)

				if oldPetInfo and newPetInfo then
					pg.game.evolution:startPresentation(oldPetInfo, newPetInfo, function()
						PetManagementUtils.selectPet(petId)
					end)

					presentationStarted = true
				end
			end
		elseif self.sType == ItemConst.USEITEM_TYPE_CHANGE_PET_SIZE_TYPE then
			self:openResultPanel(petData, changeList, "PET_CAHNGE_SIZE_SUC_TITLE")

			if self.petData then
				self:refreshPropInfo(self.petData)
			end
		else
			self:openResultPanel(petData, changeList)
		end

		if not presentationStarted then
			PetManagementUtils.selectPet(petId)
		end
	end)
end

function InventoryPetPropUseCtrl:openResultPanel(petData, changeList, titleStrKey)
	pg.global.ui:open(UIConst.UI_ID_PET_PROP_USE_RESULT, {
		petData = petData,
		changeList = changeList,
		sType = self.sType,
		openFunc = function()
			PetManagementUtils._previewMaxLevel()
		end,
		titleStrKey = titleStrKey
	})
end

return InventoryPetPropUseCtrl
