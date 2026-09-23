-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchDetailV2\\Component\\PetSurveyFormComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("PetSurveyFormComponent")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PetAvatarData = require("Data.pet_avatar_data")
local PetBasePrototypeToPrototypeMap = require("Data.pet_base_prototype_to_prototype_map")
local Const = require("Common.Const.Const")
local PetData = require("Data.pet_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetSurveyFormComponent = Class.LightClass("PetSurveyFormComponent", UIComponent)

function PetSurveyFormComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.closeTipBtnUButton = self.objectReference:GetRefValue("closeTipBtnUButton")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.uDarkUButton = self.objectReference:GetRefValue("uDarkUButton")
	self.title = self.objectReference:GetRefValue("title")
	self.scrollRectUScrollRect = self.objectReference:GetRefValue("scrollRectUScrollRect")

	local scrollContent = self.scrollRectUScrollRect.content
	local objectReference = scrollContent:GetComponent("ObjectReference")

	self.formTitleUWidget = objectReference:GetRefValue("formTitleUButton")
	self.formName = objectReference:GetRefValue("txtTitleUSDFText")
	self.formListUList = objectReference:GetRefValue("formListUList")
	self.avatarName = objectReference:GetRefValue("txtAvatarTitleUSDFText")
	self.labelList = objectReference:GetRefValue("avatarListUList")

	local uDarkUButtonReference = self.uDarkUButton:GetComponent("ObjectReference")

	self.uDarkUButtonTxtNameUText = uDarkUButtonReference:GetRefValue("txtNameUText")
end

function PetSurveyFormComponent:initView()
	ClientTextUtils.setText(self.title, pg.getGameString("SWITCH_PET_FORM"))

	function self.closeTipBtnUButton.luaClick()
		self:hideSurveyTip()
	end

	function self.btnCloseUButton.luaClick()
		self:hideSurveyTip()
	end

	function self.labelList.luaRenderItem(button, idx, data)
		self:renderLabelList(button, idx, data)
	end

	function self.labelList.luaSelectedChanged(ulist, selected)
		local selectedItem = ulist.selectedItem

		if selected and selectedItem then
			local shinyStyleId = selectedItem.labelId == Const.PET_LABEL_MASK.SHINY and (selectedItem.shinyStyleId or 0) or 0

			self:refreshFormList(selectedItem.labelId, shinyStyleId)
		end
	end

	function self.formListUList.luaRenderItem(button, idx, data)
		self:renderFormList(button, idx, data)
	end

	function self.formListUList.luaSelectedChanged(ulist, selected)
		local selectedItem = ulist.selectedItem

		if selected and selectedItem then
			local labelId, shinyStyleId = self:getSelectedAppearance()

			self:refreshLabelList(selectedItem.templateId, labelId, shinyStyleId)

			labelId, shinyStyleId = self:getSelectedAppearance()

			self:refreshFormList(labelId, shinyStyleId, selectedItem.templateId)
		end
	end

	ClientTextUtils.setText(self.avatarName, pg.getGameString("PET_LABEL_NAME"))
	ClientTextUtils.setText(self.formName, pg.getGameString("PET_FORM_NAME"))

	function self.uDarkUButton.luaClick()
		local selectForm = self.formListUList.selectedItem
		local labelId, shinyStyleId = self:getSelectedAppearance()

		if selectForm and selectForm.isGot then
			self.ctrl:applyForm(selectForm.templateId, labelId, shinyStyleId)
		end
	end
end

function PetSurveyFormComponent:getSelectedAppearance()
	local selectedLabel = self.labelList.selectedItem
	local labelId = selectedLabel and selectedLabel.labelId or self.model.formPetLabel or Const.PET_LABEL_MASK.NORMAL
	local shinyStyleId = labelId == Const.PET_LABEL_MASK.SHINY and (selectedLabel and selectedLabel.shinyStyleId or self.model.formPetShinyStyle or 0) or 0

	return labelId, shinyStyleId
end

function PetSurveyFormComponent:getInitialLabelIndex(labelDatas, labelId, shinyStyleId)
	local fallbackIdx

	for idx, data in ipairs(labelDatas) do
		if data.labelId == labelId then
			fallbackIdx = fallbackIdx or idx - 1

			if data.labelId ~= Const.PET_LABEL_MASK.SHINY or data.shinyStyleId == shinyStyleId then
				return idx - 1
			end
		end
	end

	return fallbackIdx or #labelDatas > 0 and 0 or nil
end

function PetSurveyFormComponent:onDestroy()
	UIComponent.onDestroy(self)
end

function PetSurveyFormComponent:showFormTip()
	self.view.widget:TryChangePage("FormTip", 1)
	self.ctrl.petScene:trySwitchView(self.model.TAB_IDX.SURVEY_FORM)
	self:refreshLabelList(self.model.formPetTemplateId, self.model.formPetLabel, self.model.formPetShinyStyle)

	if self.model.showTab == PetResearchUtils.PET_SHOW_TAB.SPECIES then
		self.formTitleUWidget:SetActive(true)
		self.formListUList:SetActive(true)

		local labelId, shinyStyleId = self:getSelectedAppearance()

		self:refreshFormList(labelId, shinyStyleId, self.model.formPetTemplateId)
	else
		self.formTitleUWidget:SetActive(false)
		self.formListUList:SetActive(false)
	end

	self:refreshApplyBtn()

	self.isShow = true
end

function PetSurveyFormComponent:refreshLabelList(templateId, labelId, shinyStyleId)
	local labelData, shinyData = {}, {}

	for _, data in ipairs(self.ctrl:getLabelDatas(templateId)) do
		if data.labelId == Const.PET_LABEL_MASK.SHINY then
			if self.ctrl:isShinyStyleOwned(data.templateId, data.shinyStyleId) then
				table.insert(shinyData, data)
			end
		else
			table.insert(labelData, data)
		end
	end

	table.sort(shinyData, function(left, right)
		return left.shinyStyleId < right.shinyStyleId
	end)

	for _, data in ipairs(shinyData) do
		table.insert(labelData, data)
	end

	self.labelList:SetList(labelData)

	local selectedIdx = self:getInitialLabelIndex(labelData, labelId, shinyStyleId)

	if selectedIdx then
		self.labelList:SelectItem(selectedIdx, false)
	end
end

function PetSurveyFormComponent:refreshFormTip()
	if self.isShow then
		self:showFormTip()
	end
end

function PetSurveyFormComponent:hideSurveyTip()
	self.view.widget:TryChangePage("FormTip", 0)
	self.ctrl.petScene:trySwitchView(self.ctrl.curTabIdx)

	if self.ctrl.curTabIdx == self.model.TAB_IDX.SURVEY then
		local baseInfo = self.ctrl:getSelectedPetInfo()

		self.ctrl.surveyPage:setPetBaseInfo(baseInfo)
		self.ctrl.petScene:restoreMainPetKnown()
		self.ctrl.petScene:setMainEntKnownState(true)
	end

	self.isShow = false
end

function PetSurveyFormComponent:renderLabelList(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textTagUSDFText = objectReference:GetRefValue("textTagUSDFText")
	local iconTagUImage = objectReference:GetRefValue("iconTagUImage")

	iconTagUImage.url = data.icon

	ClientTextUtils.setText(textTagUSDFText, pg.getLocalizationText(data.name))
end

function PetSurveyFormComponent:renderFormList(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textUSDFText = objectReference:GetRefValue("textUSDFText")
	local lockTextUSDFText = objectReference:GetRefValue("lockTextUSDFText")
	local formItemUWidget = objectReference:GetRefValue("formItemUWidget")
	local textDisUSDFText = objectReference:GetRefValue("textDisUSDFText")

	ClientTextUtils.setText(textUSDFText, data.formName)
	ClientTextUtils.setText(lockTextUSDFText, data.formName)
	ClientTextUtils.setText(textDisUSDFText, data.formName)
	button:TryChangePage("Unlock", data.isGot and 0 or 1)

	if data.formGot then
		formItemUWidget:SetActiveFastest(true)
		PetResearchUtils.renderFormItem(formItemUWidget, data.templateId, not data.isGot)
		button:TryChangePage("Dis", data.isGot and 0 or 1)
		lockTextUSDFText:SetActiveFastest(false)
	else
		formItemUWidget:SetActiveFastest(false)
		button:TryChangePage("Dis", 0)
		lockTextUSDFText:SetActiveFastest(true)
	end
end

function PetSurveyFormComponent:refreshFormList(label, shinyStyleId, selectedTemplateId)
	local selectedForm = self.formListUList.selectedItem

	selectedTemplateId = selectedTemplateId or selectedForm and selectedForm.templateId or self.model.formPetTemplateId

	local formDatas, selectedIdx = self:getFormDatas(label, shinyStyleId, selectedTemplateId)

	self.formListUList:SetList(formDatas)

	if selectedIdx then
		self.formListUList:SelectItem(selectedIdx, false)
		self:refreshMainPetModel()
	else
		self.formListUList:DeselectAll(false)
		self.ctrl.petScene:showMainPetFormUnKnown(self.model.formPetTemplateId)
	end

	self:refreshApplyBtn()
end

function PetSurveyFormComponent:refreshMainPetModel()
	local formData = self.formListUList.selectedItem
	local labelId, shinyStyleId = self:getSelectedAppearance()

	if formData then
		self:setShowPeteModel(formData, labelId, shinyStyleId)
	end
end

function PetSurveyFormComponent:setShowPeteModel(formData, labelId, shinyStyleId)
	if formData.isGot then
		self.ctrl.petScene:setMainEntKnownState(true)
		self.ctrl:setPetFormAppearance(formData.templateId, labelId, shinyStyleId)
	else
		self.ctrl.petScene:showMainPetFormUnKnown(formData.templateId)
	end
end

function PetSurveyFormComponent:getFormDatas(label, shinyStyleId, selectedTemplateId)
	local curTemplateId = Utils.getBasePetPrototypeId(self.model.curPetTemplateId)
	local petFormIdDatas = {}

	for _, petTemplateId in ipairs(PetBasePrototypeToPrototypeMap[curTemplateId] or EMPTY_TABLE) do
		if Utils.getPetCountryId(petTemplateId) == self.model.countryId then
			petFormIdDatas[#petFormIdDatas + 1] = petTemplateId
		end
	end

	local ret = {}
	local playerHandBookMap = pg.me.petHandbookMap

	selectedTemplateId = selectedTemplateId or self.model.formPetTemplateId

	local selectedIdx

	for idx, petTemplateId in ipairs(petFormIdDatas) do
		local item = {}

		item.isGot = false

		local pData = PetData[petTemplateId]
		local avatarData = PetAvatarData[petTemplateId]

		if avatarData then
			item.formName = LuaUIUtils.getPetFormNameByPrototypeId(petTemplateId)
			item.petName = pg.getLocalizationText(pData.name)

			local petHandBookInfo = playerHandBookMap[petTemplateId]

			if petHandBookInfo and petHandBookInfo:isCatched() then
				if label == Const.PET_LABEL_MASK.SHINY then
					item.isGot = self.ctrl:isShinyStyleOwned(petTemplateId, shinyStyleId)
				elseif label == Const.PET_LABEL_MASK.MAGIC then
					item.isGot = petHandBookInfo:isRainbowCatched()
				else
					item.isGot = petHandBookInfo:isCatched()
				end

				item.formGot = true
			else
				item.formName = pg.getGameString("UNKNOWN_FORM_NAME")
				item.formGot = false
			end

			if petTemplateId == selectedTemplateId then
				selectedIdx = #ret
			end

			item.templateId = petTemplateId
			item.baseProtoTemplate = pData.baseProtoTemplate
			ret[#ret + 1] = item
		end
	end

	selectedIdx = selectedIdx or #ret > 0 and 0 or nil

	return ret, selectedIdx
end

function PetSurveyFormComponent:refreshApplyBtn()
	local displayTemplateId, displayLabel, displayShinyStyle = PetResearchUtils.getPetDisplayFormLabelTemplateId(self.model.curPetTemplateId, self.model.showTab, self.model.countryId)
	local label, shinyStyleId = self:getSelectedAppearance()
	local selectedItem = self.formListUList.selectedItem
	local selectTemplate = selectedItem and selectedItem.templateId or self.templateId
	local isCurrentDisplay = selectTemplate == displayTemplateId and label == displayLabel and shinyStyleId == displayShinyStyle

	if not selectedItem or isCurrentDisplay or not selectedItem.isGot then
		self.uDarkUButton.interactable = false
	else
		self.uDarkUButton.interactable = true
	end

	local applyName = PetResearchUtils.ShowTabName[PetResearchUtils.getLastPetShowTab()]
	local btnText = pg.getFormatText(pg.getGameString("USE_FOR_PET_COLLECTION_TYPE"), pg.getGameString(applyName))

	ClientTextUtils.setText(self.uDarkUButtonTxtNameUText, btnText)
end

return PetSurveyFormComponent
