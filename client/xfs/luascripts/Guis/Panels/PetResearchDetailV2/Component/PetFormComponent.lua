-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchDetailV2\\Component\\PetFormComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("PetFormComponent")
local PetAvatarData = require("Data.pet_avatar_data")
local PetResearchContentData = require("Data.pet_research_content_data")
local PetBasePrototypeToPrototypeMap = require("Data.pet_base_prototype_to_prototype_map")
local Const = require("Common.Const.Const")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local PetSkillData = require("Data.pet_skill_data")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetFormData = require("Data.pet_form_skill_data")
local AttributeIdData = require("Data.attribute_id_data")
local AttributeConst = require("Common.Const.AttributeConst")
local PetData = require("Data.pet_data")
local UIConst = require("Const.UIConst")
local Class = require("Core.Framework.Class")
local AbilityParamData = require("Data.ability_param_data")
local PetPrototypeToBlockMap = require("Data.pet_prototype_to_block_map")
local MapBlockConfigData = require("Data.map_block_config_data")
local UIComponent = require("Guis.Helper.UIComponent")
local PetFormComponent = Class.LightClass("PetFormComponent", UIComponent)

function PetFormComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.formList = objectReference:GetRefValue("formList")
	self.progressText = objectReference:GetRefValue("progressText")
	self.progressUProgress = objectReference:GetRefValue("progressUProgress")
	self.btnApplyUButton = objectReference:GetRefValue("btnApplyUButton")
	self.formName = objectReference:GetRefValue("formName")
	self.formDesc = objectReference:GetRefValue("formDesc")
	self.formLockDesc = objectReference:GetRefValue("formLockDesc")
	self.formLockSkillUWidget = objectReference:GetRefValue("formLockSkillUWidget")
	self.derivedSkillUButton = objectReference:GetRefValue("derivedSkillUButton")
	self.skillLevelUSDFText = objectReference:GetRefValue("skillLevelUSDFText")
	self.btnFindCluesUButton = objectReference:GetRefValue("btnFindCluesUButton")
	self.buttonArrowUButton = objectReference:GetRefValue("buttonArrowUButton")
	self.abilityUButton = objectReference:GetRefValue("abilityUButton")
	self.btnDistributionUButton = objectReference:GetRefValue("btnDistributionUButton")
	self.scrollRectUScrollRect = objectReference:GetRefValue("scrollRectUScrollRect")
	self.listLeftUList = objectReference:GetRefValue("listLeftUList")
	self.listLRightUList = objectReference:GetRefValue("listLRightUList")
	self.normalUButton = objectReference:GetRefValue("normalUButton")
	self.btnHeadingUButton = objectReference:GetRefValue("btnHeadingUButton")
	self.textFromAbilityUSDFText = objectReference:GetRefValue("textFromAbilityUSDFText")
	self.formNewUButton = objectReference:GetRefValue("formNewUButton")
	self.natureUButton = objectReference:GetRefValue("natureUButton")
	self.textAbilityNameUSDFText = objectReference:GetRefValue("textAbilityNameUSDFText")
	self.textAbilityNumUSDFText = objectReference:GetRefValue("textAbilityNumUSDFText")
end

function PetFormComponent:initView()
	self.tabIdx = self.model.TAB_IDX.FORM
	self.ctrl.tabMap[self.tabIdx] = self

	function self.formList.luaRenderItem(button, idx, data)
		self:renderFormList(button, idx, data)
	end

	function self.formList.luaSelectedChanged(uList, isSelected)
		if isSelected then
			local slotItem = uList.selectedItem

			self:refreshLabelList(slotItem.templateId)
			self:setFormDetail()

			local validDistributionData = LuaUIUtils.checkPetCanShowDistributionArea(slotItem.templateId)

			if next(validDistributionData) then
				self.btnDistributionUButton.gameObject:SetActiveEx(true)
			else
				self.btnDistributionUButton.gameObject:SetActiveEx(false)
			end
		end
	end

	function self.btnApplyUButton.luaClick()
		local selectItem = self.formList.selectedItem
		local labelId, shinyStyleId, isOwned = self:getCurSelectAppearance()

		if selectItem and isOwned then
			self.ctrl:applyForm(selectItem.templateId, labelId, shinyStyleId)
		end
	end

	function self.listLeftUList.luaRenderItem(button, idx, data)
		self:renderLabelList(button, idx, data)
	end

	function self.listLeftUList.luaSelectedChanged(uList, isSelected)
		local slotItem = uList.selectedItem

		if isSelected and slotItem then
			self:onClickLabel(self.listLeftUList, self.listLRightUList)
		end
	end

	function self.listLRightUList.luaRenderItem(button, idx, data)
		self:renderLabelList(button, idx, data)
	end

	function self.listLRightUList.luaSelectedChanged(uList, isSelected)
		local slotItem = uList.selectedItem

		if isSelected and slotItem then
			self:onClickLabel(self.listLRightUList, self.listLeftUList)
		end
	end

	function self.normalUButton.luaClick()
		self:onClickNormal()
	end

	self.buttonArrowUButton.enabledTooltip = false

	function self.buttonArrowUButton.luaClick()
		local selectedItem = self.formList.selectedItem
		local templateId = selectedItem.templateId

		pg.global.ui:open(UIConst.UI_ID_PET_DETAIL, {
			fromResearch = true,
			templateId = templateId
		})
	end

	self:renderButtonName()

	function self.btnDistributionUButton.luaClick()
		local selectedItem = self.formList.selectedItem
		local templateId = selectedItem.templateId

		pg.game.map:showPetDistributionArea(templateId)
	end

	if self.scrollRectUScrollRect.content then
		local contentOC = self.scrollRectUScrollRect.content:GetComponent("ObjectReference")

		self.formDesc = contentOC:GetRefValue("text1USDFText")
		self.listConditionUList = contentOC:GetRefValue("listConditionUList")
		self.formLockDesc = contentOC:GetRefValue("text2USDFText")
		self.formLockSkillUWidget = contentOC:GetRefValue("formLockSkillUWidget")
		self.derivedSkillUButton = contentOC:GetRefValue("derivedSkillUButton")

		function self.listConditionUList.luaRenderItem(button, index, data)
			local itemObjRef = button:GetComponent("ObjectReference")
			local txtNameUBaseText1 = itemObjRef:GetRefValue("txtNameUBaseText")
			local txtValueUBaseText = itemObjRef:GetRefValue("txtValueUBaseText")

			ClientTextUtils.setText(txtNameUBaseText1, data.tName)
			ClientTextUtils.setText(txtValueUBaseText, data.tValue)
		end
	end
end

function PetFormComponent:renderButtonName()
	local objectReference = self.buttonArrowUButton:GetComponent("ObjectReference")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")

	ClientTextUtils.setText(txtNameUText, pg.getGameString("PET_FORM_DETAILS"))

	objectReference = self.btnDistributionUButton:GetComponent("ObjectReference")

	local txtNameUText1 = objectReference:GetRefValue("txtNameUText")

	ClientTextUtils.setText(txtNameUText1, pg.getGameString("SHOW_DISTRIBUTION_AREA"))
end

function PetFormComponent:renderLabelList(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textNameUSDFText = objectReference:GetRefValue("textNameUSDFText")
	local formUImage = objectReference:GetRefValue("formUImage")

	ClientTextUtils.setText(textNameUSDFText, pg.getLocalizationText(data.name))

	local typeIndex = 0

	if data.shinyStyleId == Const.PET_SHINY_STYLE.WHITE then
		typeIndex = 1
	elseif data.shinyStyleId == Const.PET_SHINY_STYLE.BLACK then
		typeIndex = 2
	end

	button:TryChangePage("Type", typeIndex)
end

function PetFormComponent:refreshLabelList(templateId)
	local labelData = self:getLabelDatas(templateId)

	table.sort(labelData, function(left, right)
		return left.shinyStyleId < right.shinyStyleId
	end)

	local leftData, rightData = {}, {}

	for _, info in ipairs(labelData) do
		if info.labelId == Const.PET_LABEL_MASK.SHINY and info.isGot then
			info.selected = false

			if info.shinyStyleId <= 5 or info.shinyStyleId == Const.PET_SHINY_STYLE.WHITE then
				table.insert(leftData, info)
			elseif info.shinyStyleId == Const.PET_SHINY_STYLE.BLACK then
				table.insert(rightData, 1, info)
			else
				table.insert(rightData, info)
			end
		end
	end

	self.listLeftUList:SetList(leftData)
	self.listLRightUList:SetList(rightData)
	self:restoreLabelSelection(leftData, rightData)
end

function PetFormComponent:onClickLabel(selectedList, otherList)
	local selectedData = selectedList.selectedItem

	if not selectedData then
		return
	end

	otherList:DeselectAll(false)
	self.normalUButton:SetSelected(false)

	self.selectedLabelData = selectedData

	self:setShowEntEModel()
end

function PetFormComponent:onClickNormal()
	self.listLeftUList:DeselectAll(false)
	self.listLRightUList:DeselectAll(false)
	self.normalUButton:SetSelected(true)

	self.selectedLabelData = nil

	self:setShowEntEModel()
end

function PetFormComponent:restoreLabelSelection(leftData, rightData)
	self.listLeftUList:DeselectAll(false)
	self.listLRightUList:DeselectAll(false)

	self.selectedLabelData = nil

	local formLabel = self.ctrl.formTargetLabel
	local shinyStyleId = self.ctrl.formTargetShinyStyle

	if formLabel == nil then
		formLabel = self.model.formPetLabel
		shinyStyleId = self.model.formPetShinyStyle
	end

	if Utils.isLabelShiny(formLabel) then
		for idx, data in ipairs(leftData) do
			if data.shinyStyleId == shinyStyleId then
				self.listLeftUList:SelectItem(idx - 1, false)
				self.normalUButton:SetSelected(false)

				self.selectedLabelData = data

				return
			end
		end

		for idx, data in ipairs(rightData) do
			if data.shinyStyleId == shinyStyleId then
				self.listLRightUList:SelectItem(idx - 1, false)
				self.normalUButton:SetSelected(false)

				self.selectedLabelData = data

				return
			end
		end
	end

	self.normalUButton:SetSelected(true)
end

function PetFormComponent:getCurSelectAppearance()
	if self.selectedLabelData then
		return self.selectedLabelData.labelId, self.selectedLabelData.shinyStyleId or 0, self.selectedLabelData.isGot
	end

	local selectedForm = self.formList.selectedItem

	return Const.PET_LABEL_MASK.NORMAL, 0, selectedForm and selectedForm.isGot or false
end

function PetFormComponent:getLabelDatas(templateId)
	local ret = self.ctrl:getLabelDatas(templateId)
	local petTemplateId = templateId
	local petHandBookInfo = pg.me.petHandbookMap[petTemplateId]

	for _, info in ipairs(ret) do
		local label = info.labelId

		if not petHandBookInfo then
			info.isGot = false
		elseif label == Const.PET_LABEL_MASK.SHINY then
			info.isGot = self.ctrl:isShinyStyleOwned(petTemplateId, info.shinyStyleId)
		elseif label == Const.PET_LABEL_MASK.MAGIC then
			info.isGot = petHandBookInfo:isRainbowCatched()
		else
			info.isGot = petHandBookInfo:isCatched()
		end

		if info.isGot then
			local baseHandBookInfo = pg.me.petHandbookMap[Utils.getBasePetPrototypeId(petTemplateId)]
			local researchPointReportMap = baseHandBookInfo.researchPointMap

			info.hadReport = researchPointReportMap:hasParams(Const.PET_RESEARCH.BI_SOURCE_AVATAR, {
				label
			})
		end
	end

	return ret
end

function PetFormComponent:onDestroy()
	UIComponent.onDestroy(self)
end

function PetFormComponent:onSelectThisPage(cb)
	self.ctrl:setPageTitle("TITLE_FORM")
	self.ctrl.petScene:trySwitchView(self.tabIdx, cb)

	if self.templateId == self.model.curPetTemplateId and not self.ctrl.formTargetTemplateId then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)

		return
	end

	self.templateId = self.model.curPetTemplateId

	self.ctrl.petScene:playPetPageAction(self.templateId, self.tabIdx)
	self:showFormInfo()
	self.formList:SelectItem(self.selectedIdx, false)

	local selectedForm = self.formList.selectedItem
	local selectedFormTemplateId = selectedForm and selectedForm.templateId or self.model.formPetTemplateId

	self:refreshLabelList(selectedFormTemplateId)

	local validDistributionData = LuaUIUtils.checkPetCanShowDistributionArea(selectedFormTemplateId)

	if next(validDistributionData) then
		self.btnDistributionUButton.gameObject:SetActiveEx(true)
	else
		self.btnDistributionUButton.gameObject:SetActiveEx(false)
	end

	self:setFormDetail()
	self:setCollectEntryProgress()

	self.ctrl.formTargetTemplateId = nil
	self.ctrl.formTargetLabel = nil
	self.ctrl.formTargetShinyStyle = nil
end

function PetFormComponent:onDeselectThisTab()
	self.ctrl.petScene:restoreMainPetKnown()
	self.ctrl.petScene:setMainEntKnownState(true)
end

function PetFormComponent:showFormInfo()
	local formDatas = self:getPetFormDatas()

	self.formList:SetList(formDatas)
end

function PetFormComponent:renderFormList(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local petName = objectReference:GetRefValue("petName")
	local formName = objectReference:GetRefValue("formName")
	local formItemUWidget = objectReference:GetRefValue("formItemUWidget")

	ClientTextUtils.setText(petName, data.petName)
	ClientTextUtils.setText(formName, data.formName)

	iconUImage.url = data.icon

	button:TryChangePage("State", data.isGot and 0 or 1)
	button:TryChangePage("ShineCard", 1)

	if data.unlockSkillId then
		self.formLockSkillUWidget:SetActiveFastest(true)

		local abParm = AbilityParamData[data.unlockSkillId]
		local skillData = self.ctrl:getSkillItemById(abParm)
		local learnData = PetSkillData[self.templateId] or {}

		skillData.isRare = learnData[data.unlockSkillId] and learnData[data.unlockSkillId].rarity

		self.ctrl:renderSkillBtn(self.derivedSkillUButton, skillData)
	else
		self.formLockSkillUWidget:SetActiveFastest(false)
	end

	if data.isGot then
		formItemUWidget:SetActiveFastest(true)
		PetResearchUtils.renderFormItem(formItemUWidget, data.templateId)
	else
		formItemUWidget:SetActiveFastest(false)
	end
end

function PetFormComponent:getPetFormDatas()
	local baseTemplateId = Utils.getBasePetPrototypeId(self.templateId)
	local petFormIdDatas = {}

	for _, petTemplateId in ipairs(PetBasePrototypeToPrototypeMap[baseTemplateId] or EMPTY_TABLE) do
		if Utils.getPetCountryId(petTemplateId) == self.model.countryId then
			petFormIdDatas[#petFormIdDatas + 1] = petTemplateId
		end
	end

	local ret = {}
	local playerHandBookMap = pg.me.petHandbookMap

	self.collectedCount = 0

	local displayTemplateId = self.model.formPetTemplateId
	local formTargetTemplateId = self.ctrl.formTargetTemplateId

	if formTargetTemplateId and Utils.getBasePetPrototypeId(formTargetTemplateId) == baseTemplateId and Utils.getPetCountryId(formTargetTemplateId) == self.model.countryId then
		displayTemplateId = formTargetTemplateId
	end

	self.selectedIdx = 0

	for idx, petTemplateId in ipairs(petFormIdDatas) do
		local item = {}
		local pData = PetData[petTemplateId]
		local avatarData = PetAvatarData[petTemplateId]

		if avatarData ~= nil then
			item.formName = LuaUIUtils.getPetFormNameByPrototypeId(petTemplateId)
			item.petName = pg.getLocalizationText(pData.name)

			local petHandBookInfo = playerHandBookMap[petTemplateId]

			if petHandBookInfo and petHandBookInfo:isCatched() then
				item.isGot = petHandBookInfo:isCatched()
				item.isGotShiny = petHandBookInfo:isShinyCatched()
				item.isGotMagic = petHandBookInfo:isRainbowCatched()

				if petTemplateId ~= self.templateId then
					self.collectedCount = self.collectedCount + 1
				end

				if item.isGotShiny then
					item.icon = LuaUIUtils.getPetIcon(pData.iconName, LuaUIUtils.PET_CARD_ILLUSTRATE_BOOK, Const.PET_LABEL_MASK.SHINY)
				end

				if item.isGotMagic then
					item.icon = LuaUIUtils.getPetIcon(pData.iconName, LuaUIUtils.PET_CARD_ILLUSTRATE_BOOK, Const.PET_LABEL_MASK.MAGIC)
				end
			else
				item.formName = pg.getGameString("UNKNOWN_FORM_NAME")
				item.unlockSkillId = PetFormData[petTemplateId]
				item.clue = pg.getLocalizationText(avatarData[0].clue)

				local isFriendCatch, friendId, blockId = PetResearchUtils.checkFriendCatch(petTemplateId)

				if isFriendCatch then
					item.friendId = friendId
					item.blockId = blockId
				end
			end

			if not item.icon then
				item.icon = LuaUIUtils.getPetIcon(pData.iconName, LuaUIUtils.PET_CARD_ILLUSTRATE_BOOK)
			end

			item.templateId = petTemplateId
			item.baseProtoTemplate = pData.baseProtoTemplate
			item.deriveDesc = pg.getLocalizationText(avatarData[0].deriveDesc or "")

			local newIndex = #ret + 1

			ret[newIndex] = item

			if petTemplateId == displayTemplateId then
				self.selectedIdx = newIndex - 1
			end
		else
			logger:warn("formId 形态 空：", petTemplateId)
		end
	end

	return ret
end

function PetFormComponent:getFormAbilityCount()
	local count = 0
	local baseTemplateId = Utils.getBasePetPrototypeId(self.templateId)

	for _, formPrototypeId in ipairs(PetBasePrototypeToPrototypeMap[baseTemplateId] or EMPTY_TABLE) do
		local entryData = PetResearchUtils.getPetFormAbilityInfo(formPrototypeId, self.model.countryId)

		if entryData then
			count = count + 1
		end
	end

	return count
end

function PetFormComponent:setCollectEntryProgress()
	local activeFormAbilityMap

	self.activeFormAbilityEffectMap, activeFormAbilityMap = PetResearchUtils.getActivePetFormAbilityEffects(self.templateId, self.model.countryId)

	local activeCount = 0

	for _ in pairs(activeFormAbilityMap) do
		activeCount = activeCount + 1
	end

	self.collectedCount = activeCount

	function self.btnHeadingUButton.luaRenderTooltip(_, popup)
		self:renderAbilityTips(popup)
	end

	self.maxCollectedCount = self:getFormAbilityCount()

	if self.maxCollectedCount == 0 then
		self.uWidget:TryChangePage("Form", 2)
		self.formLockDesc:SetActiveFastest(false)

		return
	end

	local petData = PetData[self.templateId]
	local petName = petData and pg.getLocalizationText(petData.name) or ""

	ClientTextUtils.setText(self.progressText, string.format(pg.getGameString("PET_FORM_RESEARCH_RESULT"), petName))

	self.progressUProgress.maxValue = self.maxCollectedCount
	self.progressUProgress.value = self.collectedCount

	self.formLockDesc:SetActiveFastest(true)
	ClientTextUtils.setText(self.skillLevelUSDFText, string.format("%d/%d", self.collectedCount, self.maxCollectedCount))
end

function PetFormComponent.sortAbilityEffectData(left, right)
	return left.sortId < right.sortId
end

function PetFormComponent:renderAbilityTips(button)
	local objectReference = button:GetComponent("ObjectReference")
	local iconSkillUImage = objectReference:GetRefValue("iconSkillUImage")
	local skillLevelUSDFText = objectReference:GetRefValue("skillLevelUSDFText")
	local textUSDFText = objectReference:GetRefValue("textUSDFText")
	local text2USDFText = objectReference:GetRefValue("text2USDFText")
	local listUList = objectReference:GetRefValue("listUList")

	ClientTextUtils.setText(textUSDFText, pg.getGameString("FORM_RESEARCH_RESULT"))

	local petData = PetData[self.templateId]

	ClientTextUtils.setText(text2USDFText, petData and pg.getLocalizationText(petData.name) or "")
	ClientTextUtils.setText(skillLevelUSDFText, string.format("%d/%d", self.collectedCount, self.maxCollectedCount))

	function listUList.luaRenderItem(btn, idx, d)
		self:renderOneAbility(btn, idx, d)
	end

	local listData = {}

	for attrType, attrValue in pairs(self.activeFormAbilityEffectMap or EMPTY_TABLE) do
		local attrData = AttributeIdData[attrType]

		if attrData then
			listData[#listData + 1] = {
				name = attrData.chShortName or attrData.chName,
				value = "+" .. Utils.formatAttrDesc(attrValue, 1, true),
				sortId = AttributeConst[attrType] or 0
			}
		end
	end

	table.sort(listData, PetFormComponent.sortAbilityEffectData)
	listUList:SetList(listData)
end

function PetFormComponent:renderOneAbility(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textNameUSDFText = objectReference:GetRefValue("textNameUSDFText")
	local textNumUSDFText = objectReference:GetRefValue("textNumUSDFText")

	ClientTextUtils.setText(textNameUSDFText, pg.getLocalizationText(data.name))
	ClientTextUtils.setText(textNumUSDFText, data.value)
end

function PetFormComponent:refreshSelectedFormAbility(formPrototypeId, isGot)
	local entryData, isActive = PetResearchUtils.getPetFormAbilityInfo(formPrototypeId, self.model.countryId)

	ClientTextUtils.setText(self.textFromAbilityUSDFText, string.format(pg.getGameString("FORM_RESEARCH_BONUS"), LuaUIUtils.getPetFormNameByPrototypeId(formPrototypeId)))
	PetResearchUtils.renderFormItem(self.formNewUButton, formPrototypeId, not isActive)
	self.btnHeadingUButton:TryChangePage("Activate", isActive and 1 or 0)

	if entryData and isGot then
		self.btnHeadingUButton:TryChangePage("State", 0)
		self.natureUButton:TryChangePage("TextColor", 1)

		local attrData = AttributeIdData[entryData.attrType]
		local attrName = attrData and (attrData.chShortName or attrData.chName) or entryData.name

		ClientTextUtils.setText(self.textAbilityNameUSDFText, pg.getLocalizationText(attrName))
		ClientTextUtils.setText(self.textAbilityNumUSDFText, "+" .. Utils.formatAttrDesc(entryData.attrValue, 1, true))
	else
		self.btnHeadingUButton:TryChangePage("State", 1)
		self.natureUButton:TryChangePage("TextColor", 0)
	end
end

function PetFormComponent:setFormDetail()
	local selectedItem = self.formList.selectedItem
	local templateId = selectedItem.templateId

	ClientTextUtils.setText(self.formDesc, pg.getLocalizationText(PetResearchContentData[templateId].desc))
	self:refreshSelectedFormAbility(templateId, selectedItem.isGot)

	if selectedItem.isGot then
		self.uWidget:TryChangePage("Form", 0)
		ClientTextUtils.setText(self.formLockDesc, selectedItem.deriveDesc)

		local conditionData = self:_getPetConditionData(templateId)

		self.listConditionUList:SetActiveFastest(#conditionData > 0)
		self.listConditionUList:SetList(conditionData)

		local isRainbow = Utils.isAnyRainbowType(templateId)

		self.uWidget:TryChangePage("IsRainbow", isRainbow and 1 or 0)
	else
		ClientTextUtils.setText(self.formLockDesc, selectedItem.clue)
		self.uWidget:TryChangePage("Form", 1)
		self.listConditionUList:SetActiveFastest(false)
	end

	self:setShowEntEModel()
	ClientTextUtils.setText(self.formName, selectedItem.formName)

	self.btnDistributionUButton.enabledTooltip = false

	if selectedItem.friendId then
		self.btnFindCluesUButton:SetActiveFastest(true)
		LuaUIUtils.renderFriendCatchTip(self.btnFindCluesUButton, {
			friendId = selectedItem.friendId,
			smallAreaId = selectedItem.blockId,
			petPrototypeId = selectedItem.templateId
		})
	else
		self.btnFindCluesUButton:SetActiveFastest(false)
	end
end

function PetFormComponent:setShowEntEModel()
	local label, shinyStyleId, isOwned = self:getCurSelectAppearance()
	local selectedItem = self.formList.selectedItem

	if selectedItem then
		if isOwned then
			self.ctrl.petScene:setMainEntKnownState(true)
			self.ctrl:setPetFormAppearance(selectedItem.templateId, label, shinyStyleId)
		else
			self.ctrl.petScene:showMainPetFormUnKnown(selectedItem.templateId)
		end
	end

	self:refreshApplyBtn()
end

function PetFormComponent:refreshApplyBtn()
	local displayTemplateId, displayLabel, displayShinyStyle = PetResearchUtils.getPetDisplayFormLabelTemplateId(self.templateId, self.model.showTab, self.model.countryId)
	local selectedItem = self.formList.selectedItem
	local label, shinyStyleId, isOwned = self:getCurSelectAppearance()
	local selectTemplate = selectedItem and selectedItem.templateId or self.templateId
	local isCurrentDisplay = selectTemplate == displayTemplateId and label == displayLabel and shinyStyleId == displayShinyStyle

	if isCurrentDisplay or not isOwned then
		self.btnApplyUButton.interactable = false
	else
		self.btnApplyUButton.interactable = true
	end
end

function PetFormComponent:_getPetConditionData(petPrototypeId)
	local petInfoData = {}
	local petData = PetData[petPrototypeId]
	local areaNameText = ""
	local blocks = PetPrototypeToBlockMap[petPrototypeId]

	if blocks then
		local areaNames = {}

		for _, smallAreaId in ipairs(blocks) do
			local smallAreaCfg = MapBlockConfigData[smallAreaId]
			local isCatch = LuaUIUtils.checkPetCatch(smallAreaId, petPrototypeId)
			local isFind = LuaUIUtils.checkPetFind(smallAreaId, petPrototypeId)
			local isFriendCatch = LuaUIUtils.checkFriendCatch(smallAreaId, petPrototypeId)

			if smallAreaCfg and (isCatch or isFind or isFriendCatch) then
				table.insert(areaNames, pg.getLocalizationText(smallAreaCfg.areaName))
			end
		end

		areaNameText = table.concat(areaNames, " \\ ")
	else
		areaNameText = pg.getGameString("PET_MANUAL_NO_DISTRIBUTION")
	end

	if not string.isNilOrEmpty(areaNameText) then
		table.insert(petInfoData, {
			tIndex = 0,
			tName = pg.getGameString("PET_AREA_NAME"),
			tValue = areaNameText
		})
	end

	if petData.condition then
		table.insert(petInfoData, {
			tIndex = 0,
			tName = pg.getGameString("PET_WEATHER_CONDITION"),
			tValue = pg.getLocalizationText(petData.condition)
		})
	end

	if petData.clue then
		table.insert(petInfoData, {
			tIndex = 0,
			tName = pg.getGameString("PET_CLUE_CONDITION"),
			tValue = pg.getLocalizationText(petData.clue)
		})
	end

	if petData.rules then
		table.insert(petInfoData, {
			tIndex = 0,
			tName = pg.getGameString("PET_RULES_CONDITION"),
			tValue = pg.getLocalizationText(petData.rules)
		})
	end

	return petInfoData
end

return PetFormComponent
