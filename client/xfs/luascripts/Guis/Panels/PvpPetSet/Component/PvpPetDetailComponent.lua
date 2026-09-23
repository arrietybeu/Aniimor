-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpPetSet\\Component\\PvpPetDetailComponent.lua

local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local PetDetailPropertyData = require("Data.pet_detail_property_data")
local PetResearchContentData = require("Data.pet_research_content_data")
local Const = require("Common.Const.Const")
local PetData = require("Data.pet_data")
local PetConfigData = require("Data.pet_config_data")
local TimerManager = require("Core.Timer.TimerManager")
local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local PvpPetDetailComponent = Class.LightClass("PvpPetDetailComponent", UIComponent)
local AbilityUtils = require("Common.Utils.AbilityUtils")
local PetLevelData = require("Data.pet_level_data")
local PetPropLevelMaxData = require("Data.pet_prop_level_max")
local AbilityConst = require("Common.Const.AbilityConst")
local ElementPropData = require("Data.element_prop_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetManagementPreviewScene = require("GameApp.Scenes.UIScenes.PetManagementPreviewScene")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local AddressDataConst = require("Const.AddressDataConst")
local PetManagementUtils = require("Utils.PetManagementUtils")
local PetResonaceStarComponent = require("Guis.Panels.PetTrainingNew.Component.SubNodeComps.PetResonaceStarComponent")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")

PvpPetDetailComponent.PROP_KEYS = {
	[Const.BASE_PROPERTY_HP_IDX] = {
		1,
		1
	},
	[Const.BASE_PROPERTY_ATK_IDX] = {
		2,
		1
	},
	[Const.BASE_PROPERTY_DEF_IDX] = {
		4,
		1
	},
	[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX] = {
		6,
		1
	},
	[Const.BASE_PROPERTY_DEF_MAG_IDX] = {
		5,
		1
	},
	[Const.BASE_PROPERTY_ATK_MAG_IDX] = {
		3,
		1
	}
}

function PvpPetDetailComponent:findObjects()
	self.attributeBtn = self.view.attributeBtn
	self.skillBtn = self.view.skillBtn
	self.infoBtn = self.view.infoBtn
	self.rightPanelUComponent = self.view.rightPanelUComponent
	self.btnEvolutionUButton = self.view.btnEvolutionUButton
	self.objectReference = self.rightPanelUComponent.transform:GetComponent("ObjectReference")
	self.panelAbilityUContainer = self.objectReference:GetRefValue("panelAbilityUContainer")
	self.panelSkillUContainer = self.objectReference:GetRefValue("panelSkillUContainer")
	self.panelInfoUContainer = self.objectReference:GetRefValue("panelInfoUContainer")
end

function PvpPetDetailComponent:findPanelAbilityUContainerObjects()
	self.panelAbilityUContainerObjectReference = self.panelAbilityUContainer.content.transform:GetComponent("ObjectReference")
	self.title = self.panelAbilityUContainerObjectReference:GetRefValue("title")
	self.detail = self.panelAbilityUContainerObjectReference:GetRefValue("detail")
	self.starUContainer = self.panelAbilityUContainerObjectReference:GetRefValue("starUContainer")
	self.titleObjectReference = self.title.transform:GetComponent("ObjectReference")
	self.petNameUText = self.titleObjectReference:GetRefValue("petNameUText")
	self.name01USDFText = self.titleObjectReference:GetRefValue("name01USDFText")
	self.nameShineUSDFText = self.titleObjectReference:GetRefValue("nameShineUSDFText")
	self.petElementUList = self.titleObjectReference:GetRefValue("petElementUList")
	self.numCPUText = self.titleObjectReference:GetRefValue("numCPUText")
	self.btnRenameUButton = self.titleObjectReference:GetRefValue("btnRenameUButton")
	self.btnFavoriteUButton = self.titleObjectReference:GetRefValue("btnFavoriteUButton")
	self.numLevelUText = self.titleObjectReference:GetRefValue("numLevelUText")
	self.expSlider = self.titleObjectReference:GetRefValue("expSlider")
	self.typeImage = self.titleObjectReference:GetRefValue("typeImage")
	self.typeDesc = self.titleObjectReference:GetRefValue("typeDesc")
	self.listTagUList = self.titleObjectReference:GetRefValue("listTagUList")
	self.detailObjectReference = self.detail.transform:GetComponent("ObjectReference")
	self.hpNum = self.detailObjectReference:GetRefValue("hpNum")
	self.atkNum = self.detailObjectReference:GetRefValue("atkNum")
	self.defNum = self.detailObjectReference:GetRefValue("defNum")
	self.regenNum = self.detailObjectReference:GetRefValue("regenNum")
	self.defMagNum = self.detailObjectReference:GetRefValue("defMagNum")
	self.atkMagNum = self.detailObjectReference:GetRefValue("atkMagNum")
	self.propNumGroup = {
		self.hpNum,
		self.atkNum,
		self.defNum,
		self.regenNum,
		self.defMagNum,
		self.atkMagNum
	}
	self.hpCmp = self.detailObjectReference:GetRefValue("hpCmp")
	self.atkCmp = self.detailObjectReference:GetRefValue("atkCmp")
	self.defCmp = self.detailObjectReference:GetRefValue("defCmp")
	self.regenCmp = self.detailObjectReference:GetRefValue("regenCmp")
	self.defMagCmp = self.detailObjectReference:GetRefValue("defMagCmp")
	self.atkMagCmp = self.detailObjectReference:GetRefValue("atkMagCmp")
	self.propCmpGroup = {
		self.hpCmp,
		self.atkCmp,
		self.defCmp,
		self.regenCmp,
		self.defMagCmp,
		self.atkMagCmp
	}
	self.hpLevelCmp = self.detailObjectReference:GetRefValue("hpLevelCmp")
	self.atkLevelCmp = self.detailObjectReference:GetRefValue("atkLevelCmp")
	self.defLevelCmp = self.detailObjectReference:GetRefValue("defLevelCmp")
	self.regenLevelCmp = self.detailObjectReference:GetRefValue("regenLevelCmp")
	self.defMagLevelCmp = self.detailObjectReference:GetRefValue("defMagLevelCmp")
	self.atkMagLevelCmp = self.detailObjectReference:GetRefValue("atkMagLevelCmp")
	self.propLevelCmpGroup = {
		self.hpLevelCmp,
		self.atkLevelCmp,
		self.defLevelCmp,
		self.regenLevelCmp,
		self.defMagLevelCmp,
		self.atkMagLevelCmp
	}
	self.hpLv = self.detailObjectReference:GetRefValue("hpLv")
	self.atkLv = self.detailObjectReference:GetRefValue("atkLv")
	self.defLv = self.detailObjectReference:GetRefValue("defLv")
	self.regenLv = self.detailObjectReference:GetRefValue("regenLv")
	self.defMagLv = self.detailObjectReference:GetRefValue("defMagLv")
	self.atkMagLv = self.detailObjectReference:GetRefValue("atkMagLv")
	self.propLevelGroup = {
		self.hpLv,
		self.atkLv,
		self.defLv,
		self.regenLv,
		self.defMagLv,
		self.atkMagLv
	}
	self.defaultRadar = self.detailObjectReference:GetRefValue("defaultRadar")
	self.addedRadar = self.detailObjectReference:GetRefValue("addedRadar")
	self.root = self.detailObjectReference:GetRefValue("root")
	self.ratingStr = self.detailObjectReference:GetRefValue("ratingStr")
	self.btnSwitchMaxUButton = self.detailObjectReference:GetRefValue("btnSwitchMaxUButton")
	self.characterUWidget = self.detailObjectReference:GetRefValue("characterUWidget")
	self.btnTalentUButton = self.detailObjectReference:GetRefValue("btnTalentUButton")
	self.accessListUList = self.detailObjectReference:GetRefValue("accessListUList")
	self.btnRareTraitUButton = self.detailObjectReference:GetRefValue("btnRareTraitUButton")
	self.btnDetailUButton = self.detailObjectReference:GetRefValue("btnDetailUButton")

	if NotNil(self.btnDetailUButton) then
		function self.btnDetailUButton.luaClick()
			PetManagementUtils._openPropertyPanel(self.petId)
		end
	end

	self.characterUWidget.gameObject:SetActiveEx(false)
end

function PvpPetDetailComponent:findPanelSkillUContainerObjects()
	self.panelSkillUContainerObjectReference = self.panelSkillUContainer.content.transform:GetComponent("ObjectReference")
	self.skillUWidget = self.panelSkillUContainerObjectReference:GetRefValue("skillUWidget")
	self.btnSkillPresetsUButton = self.panelSkillUContainerObjectReference:GetRefValue("btnSkillPresetsUButton")
	self.skillPresetName = self.panelSkillUContainerObjectReference:GetRefValue("skillPresetName")
	self.carryItemUComponent = self.panelSkillUContainerObjectReference:GetRefValue("carryItemUComponent")
	self.skillUWidgetObjectReference = self.skillUWidget.transform:GetComponent("ObjectReference")
	self.btnUniqueSkillUButton = self.skillUWidgetObjectReference:GetRefValue("btnUniqueSkillUButton")
	self.btnNormalSkill1UButton = self.skillUWidgetObjectReference:GetRefValue("btnNormalSkill1UButton")
	self.btnNormalSkill2UButton = self.skillUWidgetObjectReference:GetRefValue("btnNormalSkill2UButton")
	self.btnExploreSkillUButton = self.skillUWidgetObjectReference:GetRefValue("btnExploreSkillUButton")
	self.btnFeaturesUButton = self.skillUWidgetObjectReference:GetRefValue("btnFeaturesUButton")

	function self.btnSkillPresetsUButton.luaClick()
		self:onClickSkillPresetsButton()
	end
end

function PvpPetDetailComponent:findPanelInfoUContainerObjects()
	self.panelInfoUContainerObjectReference = self.panelInfoUContainer.content.transform:GetComponent("ObjectReference")
	self.petDesc = self.panelInfoUContainerObjectReference:GetRefValue("petDesc")
	self.beenText = self.panelInfoUContainerObjectReference:GetRefValue("beenText")
	self.infoPetName = self.panelInfoUContainerObjectReference:GetRefValue("infoPetName")
	self.txtDetailUSDFText = self.panelInfoUContainerObjectReference:GetRefValue("txtDetailUSDFText")
	self.rawImageRawImagePro = self.panelInfoUContainerObjectReference:GetRefValue("rawImageRawImagePro")
	self.nameShineUSDFText1 = self.panelInfoUContainerObjectReference:GetRefValue("nameShineUSDFText1")
	self.nameShineUSDFText2 = self.panelInfoUContainerObjectReference:GetRefValue("nameShineUSDFText2")
	self.uINodePetPanelInfoUComponent = self.panelInfoUContainerObjectReference:GetRefValue("uINodePetPanelInfoUComponent")
	self.btnPetManualUButton = self.panelInfoUContainerObjectReference:GetRefValue("btnPetManualUButton")
	self.textUSDFText = self.panelInfoUContainerObjectReference:GetRefValue("textUSDFText")

	if self.rawImageRawImageProData then
		self.rawImageRawImageProData:setRawImageProRef(self.rawImageRawImagePro)

		self.rawImageRawImageProData = nil
	end

	self.ctrl.uiScene:setRawImageProRef(self.rawImageRawImagePro)
	self.btnPetManualUButton.gameObject:SetActiveEx(false)
end

function PvpPetDetailComponent:initView()
	function self.btnEvolutionUButton.luaClick()
		self:onSkillClick(self.petId)
	end

	function self.attributeBtn.luaClick()
		self:chooseTabButton(0)
		self:switchPetInfoTopPages(0)
	end

	function self.skillBtn.luaClick()
		self:chooseTabButton(1)
		self:switchPetInfoTopPages(1)
	end

	function self.infoBtn.luaClick()
		self:chooseTabButton(2)
		self:switchPetInfoTopPages(2)
	end

	self.attributeBtn.luaClick()
end

function PvpPetDetailComponent:chooseTabButton(index)
	local buttons = {
		self.attributeBtn,
		self.skillBtn,
		self.infoBtn
	}

	for i = 1, #buttons do
		buttons[i]:TryChangePage("select", 0)
	end

	buttons[index + 1]:TryChangePage("select", 1)
end

function PvpPetDetailComponent:switchPetInfoTopPages(index)
	self.pageIndex = index

	self.rightPanelUComponent:TryChangePage("tabInfo", self.pageIndex)

	if self.pageIndex == 0 then
		if not self.panelAbilityUContainer:CheckURLLoaded() then
			self.panelAbilityUContainer:LoadDefaultUrlManually(function(obj)
				if IsNil(obj) then
					return
				end

				self:findPanelAbilityUContainerObjects()

				if self.panelAbilityUContainerData then
					self:renderPetInfoCard(self.panelAbilityUContainerData)
					self:setTotalAttribute(self.panelAbilityUContainerData)

					self.panelAbilityUContainerData = nil
				end
			end)
		end
	elseif self.pageIndex == 1 then
		if not self.panelSkillUContainer:CheckURLLoaded() then
			self.panelSkillUContainer:LoadDefaultUrlManually(function(obj)
				if IsNil(obj) then
					return
				end

				self:findPanelSkillUContainerObjects()

				if self.panelSkillUContainerData then
					self:setFeature(self.panelSkillUContainerData)
					self:refreshSkillList(self.panelSkillUContainerData)

					self.panelSkillUContainerData = nil
				end
			end)
		end
	elseif not self.panelInfoUContainer:CheckURLLoaded() then
		self.panelInfoUContainer:LoadDefaultUrlManually(function(obj)
			if IsNil(obj) then
				return
			end

			self:findPanelInfoUContainerObjects()

			if self.panelInfoUContainerData then
				self:refreshInfo(self.panelInfoUContainerData)

				self.panelInfoUContainerData = nil
			end
		end)
	end
end

function PvpPetDetailComponent:refreshPetInfoDetail(data)
	if data.empty or data.isEmpty then
		self.rightPanelUComponent:TryChangePage("tabInfo", 3)

		return
	else
		self:switchPetInfoTopPages(self.pageIndex or 0)

		self.petId = pg.game.pvp:isFairMode() and not self.ctrl.context.isRogue and data.configData.templateId or data.id
		self.templateId = data.configData.templateId

		if self.panelAbilityUContainer:CheckURLLoaded() then
			self:renderPetInfoCard(data)
			self:setTotalAttribute(data)
		else
			self.panelAbilityUContainerData = data
		end

		if self.panelSkillUContainer:CheckURLLoaded() then
			self:setFeature(data)
			self:refreshSkillList(data)
		else
			self.panelSkillUContainerData = data
		end

		if self.panelInfoUContainer:CheckURLLoaded() then
			self:refreshInfo(data)
		else
			self.panelInfoUContainerData = data
		end
	end
end

function PvpPetDetailComponent:renderPetInfoCard(data)
	self.petNameStr = data.configData.name

	self:refreshPetName(self.petNameStr)

	function self.petElementUList.luaRenderItem(button, _, data1)
		LuaUIUtils.setElementButtonNew(button, data1.element, true, self.templateId)
	end

	self.petElementUList:SetList(data.configData.elementNames)
	ClientTextUtils.setText(self.numCPUText, "CP ", data.configData.cp)

	if data.configData.gender == Const.GENDER_TYPE_MALE then
		self.rightPanelUComponent:TryChangePage("Gender", 0)
	elseif data.configData.gender == Const.GENDER_TYPE_FEMALE then
		self.rightPanelUComponent:TryChangePage("Gender", 1)
	else
		self.rightPanelUComponent:TryChangePage("Gender", 2)
	end

	ClientTextUtils.setText(self.numLevelUText, data.configData.level)

	local maxExp = PetLevelData[data.configData.level + 1] ~= nil and PetLevelData[data.configData.level + 1].needExp or 0

	self.expSlider.value = maxExp == 0 and 1 or (data.exp or 0) / maxExp

	if data.configData.isShiny then
		self.rightPanelUComponent:TryChangePage("isFlash", 1)
	else
		self.rightPanelUComponent:TryChangePage("isFlash", 0)
	end

	if data.configData.isBoss then
		self.title:TryChangePage("isBoss", 1)
	else
		self.title:TryChangePage("isBoss", 0)
	end

	if data.configData.isVariant then
		self.title:TryChangePage("isChange", 1)
	else
		self.title:TryChangePage("isChange", 0)
	end

	local petType = PetData[self.templateId].functionId

	self.typeImage.url = PetConfigData.petFunctionIcon[petType]

	ClientTextUtils.setText(self.typeDesc, pg.getLocalizationText(PetConfigData[string.format("petFunctionText%s", petType)]) or "")
	self:m_refreshStarUpContainer(self.petId)

	if self.listTagUList then
		function self.listTagUList.luaRenderItem(button, idx, data)
			LuaUIUtils.renderPetTagList(button, data)

			local templateId = data and data.templateId
			local label = data and data.label
			local bodySizeType = data and data.bodySizeType

			LuaUIUtils.setPetTagLabelToolTip(button, LuaUIUtils.getPetTagInfo(templateId, label, bodySizeType, data.shinyStyle))
		end
	end

	local tagDatas = LuaUIUtils.getPetTagList(data)

	if self.listTagUList then
		self.listTagUList:SetList(tagDatas)
	end
end

function PvpPetDetailComponent:m_refreshStarUpContainer(petId)
	local starUContainer = self.starUContainer

	if not petId or not starUContainer then
		return
	end

	local curResonanceInfo = PetManagementUtils.getPetStarUpInfo(petId)
	local stage = curResonanceInfo.resonanceStage or 0
	local level = curResonanceInfo.resonanceLevel or 0
	local curStageStarUrl = PetManagementUtils.getStarItemUrl(stage, true)

	starUContainer:SetUrlWithCallback(curStageStarUrl, function()
		if not petId or not starUContainer then
			return
		end

		local starUCont = starUContainer.content

		self.m_starComp = PetResonaceStarComponent.new(starUCont)

		if self.m_starComp then
			self.m_starComp:updateAndRefresh(petId, {
				stage = stage,
				lv = level,
				pos = UIConst.STARCOMP_POS.PETINFO
			})
		end
	end)
end

function PvpPetDetailComponent:setTotalAttribute(petInfo)
	if petInfo == nil then
		return
	end

	local baseProperty = petInfo.configData.basePropertyList
	local propertyEnhanced = petInfo.configData.propertyEnhanced
	local templateId = petInfo.configData.templateId
	local petData = PetData[templateId]
	local recommend = petData.recommend_attr
	local propLevels = pg.game.petManage:getPetPropLevels(petInfo)
	local defaultRatioGroup = {}
	local addedRatioGroup = {}
	local isTrained = 0

	for i = Const.BASE_PROPERTY_HP_IDX, Const.BASE_PROPERTY_ATK_MAG_IDX do
		local isMax = propLevels[i].isMax

		ClientTextUtils.setText(self.propNumGroup[i], baseProperty[i].total)
		ClientTextUtils.setText(self.propLevelGroup[i], baseProperty[i].indLv)

		self.propCmpGroup[i].luaTooltipPopup = function(_, flag)
			self.propCmpGroup[i]:TryChangePage("Selected", flag and 1 or 0)
		end
		self.propCmpGroup[i].luaRenderTooltip = function(_, component)
			PetManagementUtils.customRefreshBuffInfoTooltip(component, PetManagementDataHelper.BuffInfoToolTipType.Cultivate, {
				index = i,
				recommend = recommend,
				propertyEnhanced = propertyEnhanced,
				propLevel = propLevels[i]
			})
		end

		if baseProperty[i].iLvLn > 0 then
			self.propCmpGroup[i]:TryChangePage("State", 1)
			self.propLevelCmpGroup[i]:TryChangePage("State", 1)
		else
			self.propCmpGroup[i]:TryChangePage("State", 0)
			self.propLevelCmpGroup[i]:TryChangePage("State", 0)
		end

		if LuaUIUtils.tableContains(recommend, i) then
			self.propCmpGroup[i]:TryChangePage("GoodState", 1)
			self.propLevelCmpGroup[i]:TryChangePage("Updated", propertyEnhanced and 1 or 0)

			if propertyEnhanced then
				self.propLevelCmpGroup[i]:TryChangePage("State", 1)
			end
		else
			self.propCmpGroup[i]:TryChangePage("GoodState", 0)
			self.propLevelCmpGroup[i]:TryChangePage("Updated", 0)
		end

		if baseProperty[i].indLv >= PetPropLevelMaxData[i] then
			self.propCmpGroup[i]:TryChangePage("State", 2)
			self.propLevelCmpGroup[i]:TryChangePage("State", 2)
		end

		defaultRatioGroup[i] = (baseProperty[i].indLv - baseProperty[i].iLvLn) / PetPropLevelMaxData[i]
		addedRatioGroup[i] = baseProperty[i].indLv / PetPropLevelMaxData[i]

		if baseProperty[i].iLvLn and baseProperty[i].iLvLn > 0 then
			isTrained = isTrained + 1
		end
	end

	self.defaultRadar:SetSixProps(defaultRatioGroup[Const.BASE_PROPERTY_HP_IDX], defaultRatioGroup[Const.BASE_PROPERTY_ATK_IDX], defaultRatioGroup[Const.BASE_PROPERTY_DEF_IDX], defaultRatioGroup[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX], defaultRatioGroup[Const.BASE_PROPERTY_DEF_MAG_IDX], defaultRatioGroup[Const.BASE_PROPERTY_ATK_MAG_IDX])
	self.addedRadar:SetSixProps(defaultRatioGroup[Const.BASE_PROPERTY_HP_IDX], defaultRatioGroup[Const.BASE_PROPERTY_ATK_IDX], defaultRatioGroup[Const.BASE_PROPERTY_DEF_IDX], defaultRatioGroup[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX], defaultRatioGroup[Const.BASE_PROPERTY_DEF_MAG_IDX], defaultRatioGroup[Const.BASE_PROPERTY_ATK_MAG_IDX])
	self.addedRadar.transform.gameObject:SetActiveEx(isTrained > 0)
	self:ratioAttribute(petInfo)

	local featureInfo, _ = self.model:getFeatureInfo(pg.game.pvp:isFairMode() and petInfo.serverData.curCharacter or petInfo.serverData.characterInfo.curCharacter)

	if featureInfo and featureInfo.rare and featureInfo.rare == 1 then
		self.btnRareTraitUButton.gameObject:SetActiveEx(true)

		function self.btnRareTraitUButton.luaTooltipPopup(_, flag)
			self.btnRareTraitUButton.isSelected = flag

			self.btnRareTraitUButton:TryChangePage("button", flag and 5 or 0)
		end

		LuaUIUtils.setRenderFeatureToolTips(self.btnRareTraitUButton, featureInfo)
	else
		self.btnRareTraitUButton.gameObject:SetActiveEx(false)
	end
end

function PvpPetDetailComponent:ratioAttribute(petInfo)
	local pageIndex, ratingStr = 0, pg.getGameString("INTERFACE_DISPLAY_RATING_1")

	self.root:TryChangePage("Quality", pageIndex)
	ClientTextUtils.setText(self.ratingStr, pg.getGameString(ratingStr))
end

function PvpPetDetailComponent:refreshPetName(petName)
	ClientTextUtils.setText(self.petNameUText, petName)
	ClientTextUtils.setText(self.name01USDFText, petName)
	ClientTextUtils.setText(self.nameShineUSDFText, petName)
end

function PvpPetDetailComponent:setFeature(petInfo)
	local featureInfo = self.model:getFeatureInfo(pg.game.pvp:isFairMode() and petInfo.serverData.curCharacter or petInfo.serverData.characterInfo.curCharacter)

	if featureInfo then
		local objectReference = self.btnFeaturesUButton:GetComponent("ObjectReference")
		local iconFeatureUImage = objectReference:GetRefValue("iconFeatureUImage")

		self.btnFeaturesUButton:TryChangePage("IsRare", featureInfo.rare or 0)
		self.btnFeaturesUButton:TryChangePage("State", 1)

		iconFeatureUImage.url = featureInfo.icon
		self.btnFeaturesUButton.enabledTooltip = true

		function self.btnFeaturesUButton.luaRenderTooltip(_, component)
			local objectRef = component:GetComponent("ObjectReference")
			local txtName = objectRef:GetRefValue("txtName")
			local iconSkillUImage = objectRef:GetRefValue("iconSkillUImage")
			local txtShortDetailsUSDFText = objectRef:GetRefValue("txtShortDetailsUSDFText")
			local detailsUWidget = objectRef:GetRefValue("detailsUWidget")
			local maskImg = objectRef:GetRefValue("maskImg")

			component:TryChangePage("IsRare", featureInfo.rare or 0)
			component:TryChangePage("SkillType", 2)
			ClientTextUtils.setText(txtName, pg.getLocalizationText(featureInfo.name))

			iconSkillUImage.url = featureInfo.icon
			maskImg.url = featureInfo.icon

			detailsUWidget.gameObject:SetActiveEx(false)
			ClientTextUtils.setText(txtShortDetailsUSDFText, pg.getLocalizationText(featureInfo.desc))
		end
	else
		self.btnFeaturesUButton.enabledTooltip = false

		self.btnFeaturesUButton:TryChangePage("IsRare", 0)
		self.btnFeaturesUButton:TryChangePage("State", 0)
	end
end

function PvpPetDetailComponent:refreshSkillList(data)
	local ultSkillInfo = self.model:getPetSkillData(data, AbilityConst.ULTIMATE_ABILITY)
	local qSkillInfo = self.model:getPetSkillData(data, AbilityConst.WEAPON_SKILL_ABILITY)
	local eSkillInfo = self.model:getPetSkillData(data, AbilityConst.WEAPON_SKILL_ABILITY2)

	self.petInfo = pg.me:getPetInfo(data.id)

	self:renderSkillCmp(self.btnUniqueSkillUButton, ultSkillInfo, data.templateId)
	self:renderSkillCmp(self.btnNormalSkill1UButton, qSkillInfo, data.templateId)
	self:renderSkillCmp(self.btnNormalSkill2UButton, eSkillInfo, data.templateId)

	self.btnNormalSkill1UButton.draggable = false
	self.btnNormalSkill2UButton.draggable = false

	self:renderExploreSkillCmp(self.btnExploreSkillUButton, nil)
	TimerManager.addNextFrameCb(function()
		if pg.game.pvp:isFairMode() then
			ClientTextUtils.setText(self.skillPresetName, ClientTextUtils.concatByLanguage(pg.getGameString("ABILITY_PLAN"), data.serverData.curAbilityPreset))
		else
			local petInfo = pg.me:getPetInfo(data.id)
			local presetName = petInfo.abilityPresetMap[petInfo.curAbilityPreset].name

			if presetName and presetName ~= "" then
				ClientTextUtils.setText(self.skillPresetName, presetName)
			else
				ClientTextUtils.setText(self.skillPresetName, ClientTextUtils.concatByLanguage(pg.getGameString("ABILITY_PLAN"), petInfo.curAbilityPreset))
			end
		end
	end)
end

function PvpPetDetailComponent:renderSkillCmp(button, data, templateId)
	local firstTag = data and data.tagList and data.tagList[1]
	local skillName = data and (data.abilityType == AbilityConst.ULTIMATE_ABILITY and data.typeName or firstTag and firstTag.tagName)
	local isSuccess = LuaUIUtils.renderSkillCmpCommon(button, data, skillName, nil, nil, self.petInfo)

	if not isSuccess then
		return
	end

	button.enabledTooltip = true

	function button.luaRenderTooltip(_, component)
		local objectRef = component:GetComponent("ObjectReference")
		local txtName = objectRef:GetRefValue("txtName")
		local listTagUList = objectRef:GetRefValue("listTagUList")
		local elementUButton1 = objectRef:GetRefValue("elementUButton")
		local elementText = objectRef:GetRefValue("elementText")
		local damageTypeUButton = objectRef:GetRefValue("damageTypeUButton")
		local cost = objectRef:GetRefValue("cost")
		local cd = objectRef:GetRefValue("cd")
		local iconSkillUImage = objectRef:GetRefValue("iconSkillUImage")
		local txtShortDetailsUSDFText = objectRef:GetRefValue("txtShortDetailsUSDFText")
		local txtLongDetailsUSDFText = objectRef:GetRefValue("txtLongDetailsUSDFText")
		local detailsUWidget = objectRef:GetRefValue("detailsUWidget")

		component:TryChangePage("IsRare", ToInt(AbilityUtils.isRareAbilityId(data.abilityId, templateId)))
		component:TryChangePage("SkillType", 0)
		ClientTextUtils.setText(txtName, pg.getLocalizationText(data.name))

		iconSkillUImage.url = LuaUIUtils.getSkillIcon(data.icon)

		LuaUIUtils.setElementButtonNew(elementUButton1, data.elementType)
		detailsUWidget.gameObject:SetActiveEx(data.desc ~= nil)

		local skillDesc = LuaUIUtils.getSkillDesc(data, self.petInfo)

		ClientTextUtils.setText(txtLongDetailsUSDFText.content, skillDesc)
		ClientTextUtils.setText(txtShortDetailsUSDFText, skillDesc)
		ClientTextUtils.setText(cost, data.numberList[1].number)
		ClientTextUtils.setText(cd, data.numberList[2].number)
		damageTypeUButton:TryChangePage("Type", data.attackType)

		if elementText then
			ClientTextUtils.setText(elementText, pg.getLocalizationText(ElementPropData[data.elementType].name_ch))
		end

		function listTagUList.luaRenderItem(b, _, d)
			local objectReference1 = b:GetComponent("ObjectReference")
			local txtNameUText = objectReference1:GetRefValue("txtNameUText")

			ClientTextUtils.setText(txtNameUText, pg.getLocalizationText(d.tagName))
		end

		listTagUList:SetList(data.tagList)
	end
end

function PvpPetDetailComponent:renderExploreSkillCmp(button, data)
	button:TryChangePage("State", 0)
	button:TryChangePage("Element", 0)

	if not data then
		button.enabledTooltip = false

		button:SetActive(false)

		return
	end

	button:SetActive(true)
end

function PvpPetDetailComponent:refreshInfo(data)
	ClientTextUtils.setText(self.petDesc.content, PetResearchContentData[data.templateId] ~= nil and pg.getLocalizationText(PetResearchContentData[data.templateId].desc) or "EMPTY")
	ClientTextUtils.setText(self.txtDetailUSDFText, PetResearchContentData[data.templateId] ~= nil and pg.getLocalizationText(PetResearchContentData[data.templateId].desc) or "EMPTY")
	ClientTextUtils.setText(self.beenText, pg.getFormatText(pg.getGameString("BEEN_WITH"), 0))
	ClientTextUtils.setText(self.textUSDFText, "???")

	local formName = LuaUIUtils.getPetFormName(data.templateId)

	ClientTextUtils.setText(self.infoPetName, formName)

	if data.isShiny then
		self.uINodePetPanelInfoUComponent:TryChangePage("isFlash", 1)
	else
		self.uINodePetPanelInfoUComponent:TryChangePage("isFlash", 0)
	end

	if data.isBoss then
		self.uINodePetPanelInfoUComponent:TryChangePage("isBoss", 1)
	else
		self.uINodePetPanelInfoUComponent:TryChangePage("isBoss", 0)
	end

	if self.ctrl.uiScene.scene then
		if pg.game.pvp:isFairMode() and not self.ctrl.context.isRogue then
			self.ctrl.uiScene:previewPetByTId(self.petId)
		else
			self.ctrl.uiScene:previewPet(self.petId)
		end
	end
end

function PvpPetDetailComponent:onClickSkillPresetsButton()
	pg.global.ui:open(UIConst.UI_ID_PET_SKILL_REPLACE_QUICK, {
		notPetManagement = true,
		curPetId = self.petId,
		pvpFailMode = pg.game.pvp:isFairMode(),
		templateId = self.templateId
	})
end

function PvpPetDetailComponent:onSkillClick(petId)
	LuaUIUtils.tryOpenPetCultivateUI({
		onlyShowSkillPage = true,
		notPetManagement = true,
		petId = petId,
		pvpFailMode = not self.ctrl.context.isRogue and pg.game.pvp:isFairMode(),
		toPage = Const.PetCulPageIndex2Name[Const.PetCulPages.SKILL]
	})
end

return PvpPetDetailComponent
