-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\VitalityPetChoice\\VitalityPetChoiceCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetData = require("Data.pet_data")
local EnergyMatchThemeData = require("Data.energy_match_theme_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local CommonSwitch = require("Common.CommonSwitch")
local VitalityPetChoiceCtrl = Class.LightClass("VitalityPetChoiceCtrl", UICtrl)

VitalityPetChoiceCtrl.BonusType = {
	Position = "position",
	Personality = "personality",
	Attribute = "attribute",
	Evolution = "evolution",
	Ability = "ability",
	Form = "form"
}
VitalityPetChoiceCtrl.BONUS_TYPE_ATTRIBUTE = "attribute"
VitalityPetChoiceCtrl.TAG_BONUS_TYPE = "vitality"
VitalityPetChoiceCtrl.VITALITY_SORT_ID = 8
VitalityPetChoiceCtrl.SCORE_LIST_TYPES = {
	VitalityPetChoiceCtrl.BonusType.Ability,
	VitalityPetChoiceCtrl.BonusType.Attribute,
	VitalityPetChoiceCtrl.BonusType.Position,
	VitalityPetChoiceCtrl.BonusType.Form,
	VitalityPetChoiceCtrl.BonusType.Personality,
	VitalityPetChoiceCtrl.BonusType.Evolution
}

function VitalityPetChoiceCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	local phase = ActivityUtils.getNewEnergyTheme(pg.me)
	local themeId = ActivityUtils.getEnergyThemeId(pg.me)

	self.phase = phase
	self.themeId = themeId

	local uiTheme = self:getThemeData().uiTheme

	self.eventId = info.eventId
	self.boostMode = info.boostMode == true
	self.attrBonusType = self.TAG_BONUS_TYPE
	self.baseScore = self:getThemeData().baseScore or 0
	self.vitalitySortId = self.VITALITY_SORT_ID
	self.model.useVitalitySort = true
	self.model.isDescending = true
	self.petScoreMap = {}

	self:updateCleanFilterButton()

	if self.view.root then
		self.view.root:TryChangePage("style", uiTheme)
	end

	if self.view.textNameUSDFText then
		ClientTextUtils.setText(self.view.textNameUSDFText, pg.getLocalizationText(self:getThemeData().taskName))
	end

	self:refreshPetList()
	self.view.listFilterUList:SelectItem(0)
	self:initTitle()
	self:initTagList()
end

function VitalityPetChoiceCtrl:getThemeData()
	return EnergyMatchThemeData[self.phase] and EnergyMatchThemeData[self.phase][self.themeId] or {}
end

function VitalityPetChoiceCtrl:buildThemeTagData(bgBonusType)
	local themeData = self:getThemeData()
	local tagData = {}

	for index = 1, 3 do
		table.insert(tagData, {
			icon = themeData["bonusIcon" .. index],
			name = pg.getLocalizationText(themeData["bonusName" .. index]),
			showBG = themeData["bonusType" .. index] ~= bgBonusType
		})
	end

	return tagData
end

function VitalityPetChoiceCtrl:initTitle()
	self.view.suggestUList:SetList(self:buildThemeTagData(self.BONUS_TYPE_ATTRIBUTE))
end

function VitalityPetChoiceCtrl:initTagList()
	function self.view.listTagUList.luaRenderItem(button, _, data)
		local txtName = button:Find("Text"):GetComponent("USDFText")

		ClientTextUtils.setText(txtName, data.name)

		local imgIcon = button:Find("Icon"):GetComponent("UImage")

		imgIcon.url = data.icon

		local bgIcon = button:Find("BgIcon"):GetComponent("UImage")

		bgIcon.gameObject:SetActiveEx(data.showBG)
	end

	self.view.listTagUList:SetList(self:buildThemeTagData(self.attrBonusType))
end

function VitalityPetChoiceCtrl:renderPetInfoCard(data)
	if not data or not data.id then
		return
	end

	ClientTextUtils.setText(self.view.txtCurScore, data.scoreData.totalScore)
	self:refreshScoreFill(data.scoreData)
	self.view.scoreUList:SetList(data.scoreListData)
end

function VitalityPetChoiceCtrl:refreshScoreFill(scoreData)
	scoreData = scoreData or {}

	local totalScore = scoreData.totalScore or 0

	local function getFillAmount(score)
		if totalScore <= 0 then
			return 0
		end

		return math.min(math.max((score or 0) / totalScore, 0), 1)
	end

	if self.view.fill1ImagePro then
		if scoreData.newStarScore > 0 then
			self.view.fill1ImagePro.fillAmount = getFillAmount(scoreData.formBonusScore + scoreData.baseScore + scoreData.newStarScore)
		else
			self.view.fill1ImagePro.fillAmount = 0
		end
	end

	if self.view.fill2ImagePro then
		self.view.fill2ImagePro.fillAmount = getFillAmount(scoreData.formBonusScore + scoreData.baseScore)
	end

	if self.view.fill3ImagePro then
		self.view.fill3ImagePro.fillAmount = getFillAmount(scoreData.baseScore)
	end
end

function VitalityPetChoiceCtrl:refreshPetList()
	local petData = self.model:getPetData(self.phase, self.themeId)

	function self.view.listFilterUList.luaRenderItem(button, index, data)
		if data.tIndex == 0 then
			self:refreshPetItem(button, data)
		end
	end

	function self.view.listFilterUList.luaSelectedChanged(uList, isSelect)
		if isSelect then
			self:renderPetInfoCard(uList.selectedItem)
		end
	end

	self.view.listFilterUList:SetList(petData)
end

function VitalityPetChoiceCtrl:refreshPetItem(button, petInfo)
	local petData = PetData[petInfo.templateId]
	local objectReference = button:GetComponent("ObjectReference")
	local imgIcon = objectReference:GetRefValue("iconUImage")
	local iconEvolveUImage = objectReference:GetRefValue("iconEvolveUImage")
	local panelRatingUContainer = objectReference:GetRefValue("panelRatingUContainer")
	local starBgUImage = objectReference:GetRefValue("starBgUImage")

	if starBgUImage then
		local isNewStar = ActivityUtils.isEnergyMatchPetCaughtThisWeek(petInfo)

		starBgUImage:SetActive(isNewStar)
	end

	panelRatingUContainer:LoadDefaultUrlManually()

	local ratingUContainerReference = panelRatingUContainer.content:GetComponent("ObjectReference")
	local numCPUSDFText = ratingUContainerReference:GetRefValue("numCPUSDFText")

	imgIcon.url = LuaUIUtils.getPetIcon(petData.iconName, LuaUIUtils.PET_ICON)
	button.enabledTooltip = false
	self.petScoreMap[petInfo.id] = petInfo.scoreData
	petInfo.score = petInfo.scoreData.totalScore

	ClientTextUtils.setText(numCPUSDFText, petInfo.scoreData.totalScore)
	iconEvolveUImage.gameObject:SetActiveEx(false)

	petInfo.scoreListData = self:getScoreListData(petInfo.scoreData)

	if petInfo.isShiny then
		LuaUIUtils.renderPetHeadFlashBgAndFrame(objectReference, true, petInfo.shinyStyle or 0)
	else
		LuaUIUtils.renderPetHeadFlashBgAndFrame(objectReference, false)
	end
end

function VitalityPetChoiceCtrl:getScoreListData(scoreData)
	local scoreListData = {}

	scoreData = scoreData or {}

	for _, bonusType in ipairs(self.SCORE_LIST_TYPES) do
		table.insert(scoreListData, {
			name = scoreData[bonusType .. "Name"],
			score = scoreData[bonusType] or 0
		})
	end

	return scoreListData
end

function VitalityPetChoiceCtrl:updateCleanFilterButton()
	local isDefaultSort = self.model:getSelectSortId() == self.vitalitySortId and self.model:getSortSwitchStatus() == true

	self.view.btnCleanFilterUButton.gameObject:SetActiveEx(not isDefaultSort or not self.model:isDefaultFilter())
end

function VitalityPetChoiceCtrl:addListener()
	function self.view.btnBack.luaClick()
		self:close()
		facade:sendMsgToUI(MessageName.EVENT_GET_VITALITY_REWARD)
	end

	function self.view.btnInfoUButton.luaRenderTooltip(btn, popup)
		local objectReference = popup:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("GLAMOUR_EVENT_SCORE_INFO"))
	end

	function self.view.btnCleanFilterUButton.luaClick()
		self.model.useVitalitySort = true
		self.model.isDescending = true
		self.model.selectSortId = 0

		self.model:setFilter({})
		self:refreshPetList()
		self.view.listFilterUList:SelectItem(0)
		self:updateCleanFilterButton()
	end

	function self.view.scoreUList.luaRenderItem(button, index, data)
		local txt = button:Find("Text"):GetComponent("USDFText")

		ClientTextUtils.setText(txt, data.name .. ": " .. data.score)

		if data.score > self.baseScore then
			button:TryChangePage("Status", 1)
		else
			button:TryChangePage("Status", 0)
		end
	end

	function self.view.suggestUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local bgIconRectTransform = objectReference:GetRefValue("bgIconRectTransform")
		local txt = objectReference:GetRefValue("textUBaseText")
		local icon = objectReference:GetRefValue("iconUImage")

		ClientTextUtils.setText(txt, data.name)

		icon.url = data.icon

		bgIconRectTransform.gameObject:SetActiveEx(data.showBG)
	end

	function self.view.btnNextUButton.luaClick()
		local selectedItem = self.view.listFilterUList.selectedItem

		if not selectedItem then
			return
		end

		LuaUIUtils.openPetAppearancePanel()

		local appearanceData = {}

		appearanceData.enterPage = "pet"
		appearanceData.curPetId = selectedItem.id
		appearanceData.closeCallback = nil
		appearanceData.enableCameraMode = true
		appearanceData.phase = self.phase
		appearanceData.themeId = self.themeId
		appearanceData.petScoreData = self.petScoreMap[appearanceData.curPetId]
		appearanceData.vitalityEventId = self.eventId
		appearanceData.boostMode = self.boostMode

		if not CommonSwitch.APPEARAMCE then
			return
		end

		pg.global.ui:open(UIConst.UI_ID_APPEARANCE_V2, appearanceData)
	end

	function self.view.btnFilterUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_PET_MANAGEMENT_FILTER, {
			inVitality = true,
			sortId = self.model:getSelectSortId(),
			isDescending = self.model:getSortSwitchStatus(),
			filter = self.model:getFilter(),
			doFilterCallback = function(filter, sortId, isDescending, showLabelInfo)
				self.model.useVitalitySort = sortId == self.vitalitySortId
				self.model.isDescending = isDescending
				self.model.selectSortId = sortId

				self.model:setFilter(filter)

				PetManagementDataHelper.showLabelInfo = showLabelInfo

				self:refreshPetList()
				self.view.listFilterUList:SelectItem(0)
				self:updateCleanFilterButton()
			end
		})
	end
end

function VitalityPetChoiceCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function VitalityPetChoiceCtrl:onShow()
	UICtrl.onShow(self)
end

return VitalityPetChoiceCtrl
