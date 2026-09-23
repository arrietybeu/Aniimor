-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTrainingNew\\Component\\TrainingComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local TrainingComponent = Class.LightClass("TrainingComponent", UIComponent)
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local PetLevelData = require("Data.pet_level_data")
local PetData = require("Data.pet_data")
local PetConfigData = require("Data.pet_config_data")
local ItemData = require("Data.item_data")
local UIConst = require("Const.UIConst")
local ItemUtils = require("Common.Utils.ItemUtils")
local ClientUtils = require("Utils.ClientUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local Utils = require("Common.Utils.Utils")
local PetRenameValidator = require("Utils.PetRenameValidator")
local NoticeDef = require("Common.NoticeDef")

function TrainingComponent:findObjects()
	self.objectReference = self.view.talentUComponent.transform:GetComponent("ObjectReference")
	self.petInfoUComponent = self.objectReference:GetRefValue("petInfoUComponent")
	self.hpUButton = self.objectReference:GetRefValue("hpUButton")
	self.atkUButton = self.objectReference:GetRefValue("atkUButton")
	self.defUButton = self.objectReference:GetRefValue("defUButton")
	self.spdUButton = self.objectReference:GetRefValue("spdUButton")
	self.sdefUButton = self.objectReference:GetRefValue("sdefUButton")
	self.stakUButton = self.objectReference:GetRefValue("stakUButton")
	self.btnRulesUButton = self.objectReference:GetRefValue("btnRulesUButton")
	self.btnResetUButton = self.objectReference:GetRefValue("btnResetUButton")
	self.btnDevelopUButton = self.objectReference:GetRefValue("btnDevelopUButton")
	self.txtNowUSDFText = self.objectReference:GetRefValue("txtNowUSDFText")
	self.txtTotalUSDFText = self.objectReference:GetRefValue("txtTotalUSDFText")
	self.talentUComponent = self.objectReference:GetRefValue("talentUComponent")
	self.ratingText = self.objectReference:GetRefValue("ratingText")
	self.rightPanelUComponent = self.objectReference:GetRefValue("rightPanelUComponent")
	self.developHotKeyContent = self.objectReference:GetRefValue("developHotKeyContent")
	self.lockingHotKeyContent = self.objectReference:GetRefValue("lockingHotKeyContent")
	self.rulesHotKeyContent = self.objectReference:GetRefValue("rulesHotKeyContent")
	self.resetHotKeyContent = self.objectReference:GetRefValue("resetHotKeyContent")

	local objectReference = self.petInfoUComponent:GetComponent("ObjectReference")

	self.petNameUText = objectReference:GetRefValue("petNameUText")
	self.petElementUList = objectReference:GetRefValue("petElementUList")
	self.numCPUText = objectReference:GetRefValue("numCPUText")
	self.btnRenameUButton = objectReference:GetRefValue("btnRenameUButton")
	self.btnFavoriteUButton = objectReference:GetRefValue("btnFavoriteUButton")
	self.numLevelUText = objectReference:GetRefValue("numLevelUText")
	self.expSlider = objectReference:GetRefValue("expSlider")
	self.typeImage = objectReference:GetRefValue("typeImage")
	self.typeDesc = objectReference:GetRefValue("typeDesc")
	self.name01USDFText = objectReference:GetRefValue("name01USDFText")
	self.nameShineUSDFText = objectReference:GetRefValue("nameShineUSDFText")
	self.listExploreAbilityUList = objectReference:GetRefValue("listExploreAbilityUList")
	self.listTagUList = objectReference:GetRefValue("listTagUList")

	function self.listTagUList.luaRenderItem(button, idx, data)
		LuaUIUtils.renderPetTagList(button, data)
		LuaUIUtils.setPetTagLabelToolTip(button, LuaUIUtils.getPetTagInfo(self.petInfo.templateId, self.petInfo.label, self.petInfo.bodySizeType, self.petInfo.shinyStyle))
	end

	self.propBtns = {
		self.hpUButton,
		self.atkUButton,
		self.defUButton,
		self.spdUButton,
		self.sdefUButton,
		self.stakUButton
	}
	self.txtGroup = {
		"ATTRIBUTE_HP",
		"ATTRIBUTE_ATTACK",
		"ATTRIBUTE_DEFINE",
		"ATTRIBUTE_RECOVER",
		"ATTRIBUTE_SP_DEFINE",
		"ATTRIBUTE_SP_ATTACK"
	}
	self.curSelectedPropIndex = nil
end

function TrainingComponent:initView()
	function self.btnRulesUButton.luaClick()
		self:onRulesBtnClick()
	end

	function self.btnResetUButton.luaClick()
		self:onResetBtnClick()
	end

	function self.btnFavoriteUButton.luaClick()
		self:onClickFavoriteBtn()
	end

	function self.btnRenameUButton.luaClick()
		self:showRename()
	end

	function self.btnDevelopUButton.luaClick()
		self:gradeUp()
	end

	self.developHotKeyContent:SetHotKeyPaths("Raw/GamepadButtonWest")
	self.lockingHotKeyContent:SetHotKeyPaths("Raw/GamepadRightStickPress")
	self.rulesHotKeyContent:SetHotKeyPaths("Raw/GamepadDPadRight")
	self.resetHotKeyContent:SetHotKeyPaths("Raw/GamepadButtonNorth")
	self.ctrl:bindHotKeyPerform("Raw/GamepadButtonWest", function()
		self.btnDevelopUButton.luaClick()
	end, self.btnDevelopUButton.gameObject)
	self.ctrl:bindHotKeyPerform("Raw/GamepadDPadRight", function()
		self.btnRulesUButton:OnClickSimulate()
	end, self.btnRulesUButton.gameObject)
	self.ctrl:bindHotKeyPerform("Raw/GamepadButtonNorth", function()
		self.btnResetUButton.luaClick()
	end, self.btnResetUButton.gameObject)
end

function TrainingComponent:init(info)
	self.petId = info.petId

	if info.pvpFailMode or info.onlyShowSkillPage then
		return
	end

	self:refreshPetName(pg.getLocalizationText(self.model:getPetName(self.petId)))
	self:renderValue()
	self:renderRatio()

	self.petInfo = self.model:setUpPetInfo(self.petId)

	self:renderPetInfoCard(self.petInfo)
	self:resetFavouriteBtnState(self.petInfo)
	self:renderProp(self.petInfo)
	self:refreshInfoPanel()
end

function TrainingComponent:renderValue()
	local leftNum, rightNum = self.model:getTrainingTimesData(self.petId)

	ClientTextUtils.setText(self.txtNowUSDFText, leftNum)
	ClientTextUtils.setText(self.txtTotalUSDFText, rightNum)
end

function TrainingComponent:renderRatio()
	local pageIndex, ratingStr = self.model:getPageIndexAndRatingStr(self.petId)

	self.talentUComponent:TryChangePage("Quality", pageIndex)
	ClientTextUtils.setText(self.ratingText, ratingStr)
end

function TrainingComponent:renderPetInfoCard(data)
	local petNameStr = pg.getLocalizationText(self.model:getPetName(self.petId))

	if pg.game.setting:getShowDebugId() then
		petNameStr = petNameStr .. tostring(data.templateId)
	end

	ClientTextUtils.setText(self.petNameUText, petNameStr)

	function self.petElementUList.luaRenderItem(button, _, data1)
		LuaUIUtils.setElementButtonNew(button, data1.element, true, data.templateId)
	end

	LuaUIUtils.renderPetCharList(self.listExploreAbilityUList, data.templateId)

	local tagDatas = LuaUIUtils.getPetTagList(data)

	self.listTagUList:SetList(tagDatas)
	self.petElementUList:SetList(data.elementNames)
	ClientTextUtils.setText(self.numCPUText, "CP ", data.cp)

	if data.gender == Const.GENDER_TYPE_MALE then
		self.petInfoUComponent:TryChangePage("Gender", 0)
	elseif data.gender == Const.GENDER_TYPE_FEMALE then
		self.petInfoUComponent:TryChangePage("Gender", 1)
	else
		self.petInfoUComponent:TryChangePage("Gender", 2)
	end

	ClientTextUtils.setText(self.numLevelUText, data.level)

	local maxExp = PetLevelData[data.level + 1] ~= nil and PetLevelData[data.level + 1].needExp or 0

	self.expSlider.value = maxExp == 0 and 1 or data.exp / maxExp

	self.petInfoUComponent:TryChangePage("isChange", data.isVariant and 1 or 0)

	local petType = PetData[data.templateId].functionId

	self.typeImage.url = PetConfigData.petFunctionIcon[petType]

	ClientTextUtils.setText(self.typeDesc, pg.getLocalizationText(PetConfigData[string.format("petFunctionText%s", petType)]) or "")
end

function TrainingComponent:onRulesBtnClick()
	function self.btnRulesUButton.luaRenderTooltip(_, component)
		local objectReference = component:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("PET_TRAINING_TIP"))
	end
end

function TrainingComponent:onClickFavoriteBtn()
	PetManagementUtils.setRenderFavoriteToolTips(self.btnFavoriteUButton, self.petId)
end

function TrainingComponent:showRename()
	if not PetRenameValidator.canRenamePet() then
		pg.global.showBubbleMessage(NoticeDef.FORBID_CHANGE_PET_NAME)

		return
	end

	local title = pg.getGameString("RENAME_TIPS_PET")
	local id = self.petId
	local text = pg.getLocalizationText(self.model:getPetName(id))

	pg.global.ui.tips:setIsModel(true)
	pg.global.ui.tips:showCommonInput(title, function(newName)
		pg.me:serverMsg("RPC_CS_CustomPetName", id, newName)
		pg.global.ui.tips:setIsModel(false)
	end, function()
		pg.global.ui.tips:setIsModel(false)
	end, {
		characterLimit = 14,
		text = text or ""
	})
end

function TrainingComponent:resetFavouriteBtnState(petInfo)
	PetManagementUtils.refreshFavoriteBtn(self.btnFavoriteUButton, petInfo and petInfo.favorityType)
end

function TrainingComponent:refreshPetName(petName)
	ClientTextUtils.setText(self.petNameUText, petName)
	ClientTextUtils.setText(self.name01USDFText, petName)
	ClientTextUtils.setText(self.nameShineUSDFText, petName)
end

function TrainingComponent:renderProp(petInfo)
	local propLevels = self.model:getPetPropLevels(petInfo)

	for i = Const.BASE_PROPERTY_HP_IDX, Const.BASE_PROPERTY_ATK_MAG_IDX do
		self:renderSpecificPropBtn(i, propLevels)
	end
end

function TrainingComponent:renderSpecificPropBtn(i, propLevels)
	self:renderSingleBtn(self.propBtns[i], propLevels, i)

	self.propBtns[i].luaClick = function()
		for _, v in pairs(self.propBtns) do
			v:TryChangePage("Selected", 0)
		end

		if self.curSelectedPropIndex == i then
			self.curSelectedPropIndex = nil

			self:refreshInfoPanel()

			return
		end

		self.curSelectedPropIndex = i

		self:refreshInfoPanel()
		self.propBtns[i]:TryChangePage("Selected", 1)
	end
end

function TrainingComponent:renderSingleBtn(btn, propLevels, index)
	local objectReference = btn:GetComponent("ObjectReference")
	local sliderBaseUSlider = objectReference:GetRefValue("sliderBaseUSlider")
	local sliderTrainUSlider = objectReference:GetRefValue("sliderTrainUSlider")
	local txtLevelUSDFText = objectReference:GetRefValue("txtLevelUSDFText")

	btn:TryChangePage("IsMax", propLevels[index].isMax and 1 or 0)

	local recommend = self.petInfo.recommend_attr

	if LuaUIUtils.tableContains(recommend, index) then
		btn:TryChangePage("GoodState", 1)
	else
		btn:TryChangePage("GoodState", 0)
	end

	sliderBaseUSlider.value = propLevels[index].base / propLevels[index].max
	sliderTrainUSlider.value = (propLevels[index].learnt + propLevels[index].base) / propLevels[index].max

	ClientTextUtils.setText(txtLevelUSDFText, propLevels[index].learnt + propLevels[index].base)
end

function TrainingComponent:refreshInfoPanel()
	if not self.curSelectedPropIndex then
		self.rightPanelUComponent:TryChangePage("InfoState", 0)

		return
	end

	local objectReference = self.rightPanelUComponent:GetComponent("ObjectReference")
	local txtLevelNowUSDFText = objectReference:GetRefValue("txtLevelNowUSDFText")
	local txtLevelNextUSDFText = objectReference:GetRefValue("txtLevelNextUSDFText")
	local listUList = objectReference:GetRefValue("listUList")
	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	local talentUButton = objectReference:GetRefValue("talentUButton")
	local petInfo = pg.me:getPetInfo(self.petId)
	local baseProperty = petInfo.basePropertyList
	local propLevels = self.model:getPetPropLevels(petInfo)

	ClientTextUtils.setText(txtTitleUSDFText, string.format(pg.getGameString("PET_TRAINING_TIP1"), pg.getGameString(self.txtGroup[self.curSelectedPropIndex])))

	if baseProperty[self.curSelectedPropIndex].indLv >= Utils.getTotalIndividualLevelMax(self.curSelectedPropIndex) then
		self.rightPanelUComponent:TryChangePage("InfoState", 2)
	else
		self.rightPanelUComponent:TryChangePage("InfoState", 1)
		ClientTextUtils.setText(txtLevelNowUSDFText, baseProperty[self.curSelectedPropIndex].iLvLn)
		ClientTextUtils.setText(txtLevelNextUSDFText, baseProperty[self.curSelectedPropIndex].iLvLn + 1)

		self.toLevel = baseProperty[self.curSelectedPropIndex].indLv + 1

		local res = self.model:getIndividualLearnCost(self.petId, self.curSelectedPropIndex, self.toLevel)

		if res then
			local reachRequirement = true

			function listUList.luaFinishRender(_)
				self.rightPanelUComponent:InvokeCallback(reachRequirement and CS.XGUI.EInvokeTime.Custom1 or CS.XGUI.EInvokeTime.Custom2)

				if reachRequirement then
					self.btnDevelopUButton.interactable = true
				else
					self.btnDevelopUButton.interactable = false
				end
			end

			function listUList.luaRenderItem(button, _, data)
				local objectReference1 = button:GetComponent("ObjectReference")
				local itemIconUImage = objectReference1:GetRefValue("itemIconUImage")
				local txtNumUText = objectReference1:GetRefValue("txtNumUText")

				itemIconUImage.url = LuaUIUtils.getIconByItemId(data.id)

				local itemConfig = ItemData[data.id]

				button:TryChangePage("Quality", itemConfig.quality)

				local ownNum = ItemUtils.getItemCountById(pg.me, data.id)

				LuaUIUtils.renderConsumeText(txtNumUText, ownNum, data.num, 1)

				if ownNum >= data.num then
					-- block empty
				else
					reachRequirement = false
				end

				function button.luaClick()
					if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
						pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)

						return
					end

					pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
						id = data.id,
						num = ownNum,
						targetRect = button
					})
				end
			end

			listUList:SetList(res)
		end
	end

	local objectReference1 = talentUButton:GetComponent("ObjectReference")
	local sliderBaseUSlider = objectReference1:GetRefValue("sliderBaseUSlider")
	local sliderTrainUSlider = objectReference1:GetRefValue("sliderTrainUSlider")
	local txtLevelUSDFText = objectReference1:GetRefValue("txtLevelUSDFText")
	local sliderAddUSlider = objectReference1:GetRefValue("sliderAddUSlider")

	talentUButton:TryChangePage("IsMax", propLevels[self.curSelectedPropIndex].isMax and 1 or 0)

	local recommend = self.petInfo.recommend_attr

	if LuaUIUtils.tableContains(recommend, self.curSelectedPropIndex) then
		self.rightPanelUComponent:TryChangePage("GoodState", 1)
	else
		self.rightPanelUComponent:TryChangePage("GoodState", 0)
	end

	sliderBaseUSlider.value = propLevels[self.curSelectedPropIndex].base / propLevels[self.curSelectedPropIndex].max
	sliderTrainUSlider.value = (propLevels[self.curSelectedPropIndex].learnt + propLevels[self.curSelectedPropIndex].base) / propLevels[self.curSelectedPropIndex].max
	sliderAddUSlider.value = (propLevels[self.curSelectedPropIndex].learnt + propLevels[self.curSelectedPropIndex].base + 1) / propLevels[self.curSelectedPropIndex].max

	ClientTextUtils.setText(txtLevelUSDFText, propLevels[self.curSelectedPropIndex].learnt + propLevels[self.curSelectedPropIndex].base)
end

function TrainingComponent:onResetBtnClick()
	local payBack = self.model:getPayBackInfo(self.petId)

	if #payBack <= 0 then
		pg.global.showBubbleMessageRaw(pg.getGameString("PROP_RESET_FAILD"))

		return
	end

	local itemCount = ClientUtils.getItemCountById(2)
	local str = itemCount < PetConfigData.petPropLvResetCost[2] and string.format("<color=#ff7676>%s</color>", PetConfigData.petPropLvResetCost[2]) or PetConfigData.petPropLvResetCost[2]

	pg.global.showCommonTipUse(pg.getGameString("PROP_RESET"), string.format(pg.getGameString("PROP_RESET_TIP"), str), payBack, function()
		self.ctrl:resetPetPropLevel(self.petId, function()
			self:refresh()

			if pg.global.ui.petManagement then
				pg.global.ui.petManagement:refreshAll()
			end
		end)
	end, function()
		return
	end, true)
end

function TrainingComponent:gradeUp()
	self.ctrl:learnPetPropLevel(self.petId, self.curSelectedPropIndex, self.toLevel, function()
		self:refresh()

		if pg.global.ui.petManagement then
			pg.global.ui.petManagement:refreshAll()
		end

		local baseProperty = pg.me:getPetInfo(self.petId).basePropertyList

		if baseProperty[self.curSelectedPropIndex].indLv < Utils.getTotalIndividualLevelMax(self.curSelectedPropIndex) then
			self.rightPanelUComponent:InvokeCallback(CS.XGUI.EInvokeTime.User1)
		end
	end)
end

function TrainingComponent:refresh()
	local petInfo = self.model:setUpPetInfo(self.petId)

	self:renderValue()
	self:renderRatio()
	self:renderPetInfoCard(petInfo)
	self:refreshInfoPanel()

	local propLevels = self.model:getPetPropLevels(pg.me:getPetInfo(self.petId))

	for i = Const.BASE_PROPERTY_HP_IDX, Const.BASE_PROPERTY_ATK_MAG_IDX do
		self:renderSpecificPropBtn(i, propLevels)
	end
end

function TrainingComponent:onDestroy()
	self.curSelectedPropIndex = nil
	self.toLevel = nil

	UIComponent.onDestroy(self)
end

return TrainingComponent
