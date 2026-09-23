-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\NpcDuelStart\\NpcDuelStartPetDetail.lua

local Class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local AbilityConst = require("Common.Const.AbilityConst")
local PetManagementUtils = require("Utils.PetManagementUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local Utils = require("Common.Utils.Utils")
local TimerManager = require("Core.Timer.TimerManager")
local PetResonaceStarComponent = require("Guis.Panels.PetTrainingNew.Component.SubNodeComps.PetResonaceStarComponent")
local PetData = require("Data.pet_data")
local PetConfigData = require("Data.pet_config_data")
local PetLevelData = require("Data.pet_level_data")
local Time = require("Core.Common.Time")
local HomeAbilityData = require("Data.home_ability_data")
local ClientHomelandUtils = require("Utils.ClientHomelandUtils")
local NpcDuelStartPetDetail = Class.LightClass("NpcDuelStartPetDetail")

function NpcDuelStartPetDetail:ctor(component, petData, ctrl)
	self.ctrl = ctrl
	self.petData = petData
	self.pageIndex = 0

	self:findObjects(component)
	self:initView()
	self:refreshPetInfoDetail(petData)
end

function NpcDuelStartPetDetail:getPetName(petId, withoutSuffix)
	local petInfo = pg.me:getPetInfo(petId)

	if petInfo.customName and petInfo.customName ~= "" then
		return petInfo.customName
	end

	local petConfig = PetData[petInfo.templateId]

	if withoutSuffix then
		return pg.getLocalizationTextWithoutSuffix(petConfig.name)
	end

	return pg.getLocalizationText(petConfig.name)
end

function NpcDuelStartPetDetail:findObjects(component)
	local popupObjectReference = component.transform:GetComponent("ObjectReference")
	local panelTransform = popupObjectReference:GetRefValue("panelTransform")

	self.rightPanelUComponent = panelTransform:GetComponent("UComponent")
	self.objectReference = self.rightPanelUComponent.transform:GetComponent("ObjectReference")
	self.panelAbilityUContainer = self.objectReference:GetRefValue("panelAbilityUContainer")
	self.panelSkillUContainer = self.objectReference:GetRefValue("panelSkillUContainer")
	self.panelInfoUContainer = self.objectReference:GetRefValue("panelInfoUContainer")
	self.attributeBtn = self.objectReference:GetRefValue("attributeBtn")
	self.skillBtn = self.objectReference:GetRefValue("skillBtn")
	self.infoBtn = self.objectReference:GetRefValue("infoBtn")
	self.panelControlUComponent = self.objectReference:GetRefValue("panelControlUComponent")
	self.tabContainerList = {
		self.panelAbilityUContainer,
		self.panelSkillUContainer,
		self.panelInfoUContainer
	}
end

function NpcDuelStartPetDetail:initView()
	function self.attributeBtn.luaClick()
		self:refreshSwitchPetInfoToPages(0)
	end

	function self.skillBtn.luaClick()
		self:refreshSwitchPetInfoToPages(1)
	end

	function self.infoBtn.luaClick()
		self:refreshSwitchPetInfoToPages(2)
	end

	self.infoBtn.interactable = false
end

function NpcDuelStartPetDetail:refreshSwitchPetInfoToPages(tabIndex, loadFinishCb)
	self:switchPetInfoTopPages(tabIndex, loadFinishCb)

	if tabIndex == 2 then
		self:tryRefreshPetPreview(true)
	end
end

function NpcDuelStartPetDetail:switchPetInfoTopPages(index, loadFinishCb)
	loadFinishCb = loadFinishCb or function()
		return
	end

	local pageIndex = index or 0

	self.pageIndex = pageIndex

	self.rightPanelUComponent:TryChangePage("tabInfo", pageIndex)

	local container = self.tabContainerList[pageIndex + 1]

	if container:CheckURLLoaded() then
		loadFinishCb()

		return
	end

	container:LoadDefaultUrlManually(function(obj)
		if IsNil(obj) then
			return
		end

		self:onPanelLoaded(pageIndex)
		self:renderPanel(pageIndex, self.petData)
		loadFinishCb()
	end)
end

function NpcDuelStartPetDetail:onPanelLoaded(index)
	if index == 0 then
		self:findPanelAbilityUContainerObjects()
	elseif index == 1 then
		self:findPanelSkillUContainerObjects()
	elseif index == 2 then
		self:findPanelInfoUContainerObjects()
	end
end

function NpcDuelStartPetDetail:renderPanel(index, data)
	if not data or data.empty or data.isEmpty then
		return
	end

	if index == 0 then
		self:renderAbilityPanel(data)
	elseif index == 1 then
		self:renderSkillPanel(data)
	elseif index == 2 then
		self:refreshInfo(data)
	end
end

function NpcDuelStartPetDetail:refreshPetInfoDetail(data, force)
	self.petData = data

	if not data or data.empty or data.isEmpty then
		self.rightPanelUComponent:TryChangePage("tabInfo", 3)

		return
	end

	self.petId = data.id
	self.templateId = data.templateId
	self.iconName = data.iconName
	self.label = data.label

	if self.panelAbilityUContainer:CheckURLLoaded() then
		self:onPanelLoaded(0)
		self:renderAbilityPanel(data)
	end

	if self.panelSkillUContainer:CheckURLLoaded() then
		self:onPanelLoaded(1)
		self:renderSkillPanel(data)
	end

	if self.panelInfoUContainer:CheckURLLoaded() then
		self:onPanelLoaded(2)
		self:refreshInfo(data, force)
	end

	self:switchPetInfoTopPages(self.pageIndex or 0)
end

function NpcDuelStartPetDetail:findPanelAbilityUContainerObjects()
	if self.panelAbilityUContainerObjectReference then
		return
	end

	self.panelAbilityUContainerObjectReference = self.panelAbilityUContainer.content.transform:GetComponent("ObjectReference")
	self.title = self.panelAbilityUContainerObjectReference:GetRefValue("title")
	self.detail = self.panelAbilityUContainerObjectReference:GetRefValue("detail")
	self.titleObjectReference = self.title.transform:GetComponent("ObjectReference")
	self.petNameUText = self.titleObjectReference:GetRefValue("petNameUText")
	self.name01USDFText = self.titleObjectReference:GetRefValue("name01USDFText")
	self.nameShineUSDFText = self.titleObjectReference:GetRefValue("nameShineUSDFText")
	self.petElementUList = self.titleObjectReference:GetRefValue("petElementUList")
	self.listExploreAbilityUList = self.titleObjectReference:GetRefValue("listExploreAbilityUList")
	self.listTagUList = self.titleObjectReference:GetRefValue("listTagUList")

	if self.listTagUList then
		function self.listTagUList.luaRenderItem(button, _, tagData)
			LuaUIUtils.renderPetTagList(button, tagData)
			LuaUIUtils.setPetTagLabelToolTip(button, LuaUIUtils.getPetTagInfo(tagData.templateId, tagData.label, tagData.bodySizeType))
		end
	end

	self.numCPUText = self.titleObjectReference:GetRefValue("numCPUText")
	self.btnRenameUButton = self.titleObjectReference:GetRefValue("btnRenameUButton")
	self.virtualRenameBtnUButton = self.titleObjectReference:GetRefValue("virtualRenameBtnUButton")
	self.btnFavoriteUButton = self.titleObjectReference:GetRefValue("btnFavoriteUButton")
	self.numLevelUText = self.titleObjectReference:GetRefValue("numLevelUText")
	self.expSlider = self.titleObjectReference:GetRefValue("expSlider")
	self.typeImage = self.titleObjectReference:GetRefValue("typeImage")
	self.typeDesc = self.titleObjectReference:GetRefValue("typeDesc")
	self.starUContainer = self.titleObjectReference:GetRefValue("starUContainer")

	self.btnRenameUButton:SetActive(false)
	self.virtualRenameBtnUButton:SetActive(false)
	self.btnFavoriteUButton:SetActive(false)

	self.detailObjectReference = self.detail.transform:GetComponent("ObjectReference")
	self.hpNum = self.detailObjectReference:GetRefValue("hpNum")

	local hpTitle = self.detailObjectReference:GetRefValue("hpTitle")
	local txtHPUSDFText = self.detailObjectReference:GetRefValue("txtHPUSDFText")

	self.atkNum = self.detailObjectReference:GetRefValue("atkNum")

	local atkTitle = self.detailObjectReference:GetRefValue("atkTitle")
	local txtATKUSDFText = self.detailObjectReference:GetRefValue("txtATKUSDFText")

	self.defNum = self.detailObjectReference:GetRefValue("defNum")

	local defTitle = self.detailObjectReference:GetRefValue("defTitle")
	local txtDEFUSDFText = self.detailObjectReference:GetRefValue("txtDEFUSDFText")

	self.regenNum = self.detailObjectReference:GetRefValue("regenNum")

	local regenTitle = self.detailObjectReference:GetRefValue("regenTitle")
	local txtSPDUSDFText = self.detailObjectReference:GetRefValue("txtSPDUSDFText")

	self.defMagNum = self.detailObjectReference:GetRefValue("defMagNum")

	local defMagTitle = self.detailObjectReference:GetRefValue("defMagTitle")
	local txtSDEFUSDFText = self.detailObjectReference:GetRefValue("txtSDEFUSDFText")

	self.atkMagNum = self.detailObjectReference:GetRefValue("atkMagNum")

	local atkMagTitle = self.detailObjectReference:GetRefValue("atkMagTitle")
	local txtSATKUSDFText = self.detailObjectReference:GetRefValue("txtSATKUSDFText")

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
	self.newRatioNodeUComp = self.detailObjectReference:GetRefValue("newRatioNodeUComp")
	self.btnSwitchMaxUButton = self.detailObjectReference:GetRefValue("btnSwitchMaxUButton")
	self.characterUWidget = self.detailObjectReference:GetRefValue("characterUWidget")
	self.btnTalentUButton = self.detailObjectReference:GetRefValue("btnTalentUButton")
	self.accessListUList = self.detailObjectReference:GetRefValue("accessListUList")
	self.btnRareTraitUButton = self.detailObjectReference:GetRefValue("btnRareTraitUButton")
	self.featureIcon = self.detailObjectReference:GetRefValue("featureIcon")
	self.btnDetailUButton = self.detailObjectReference:GetRefValue("btnDetailUButton")
	self.sixPropUIBinds = {
		{
			title = hpTitle,
			title2 = txtHPUSDFText,
			num = self.hpNum,
			cmp = self.hpCmp,
			levelCmp = self.hpLevelCmp
		},
		{
			title = atkTitle,
			title2 = txtATKUSDFText,
			num = self.atkNum,
			cmp = self.atkCmp,
			levelCmp = self.atkLevelCmp
		},
		{
			title = defTitle,
			title2 = txtDEFUSDFText,
			num = self.defNum,
			cmp = self.defCmp,
			levelCmp = self.defLevelCmp
		},
		{
			title = regenTitle,
			title2 = txtSPDUSDFText,
			num = self.regenNum,
			cmp = self.regenCmp,
			levelCmp = self.regenLevelCmp
		},
		{
			title = defMagTitle,
			title2 = txtSDEFUSDFText,
			num = self.defMagNum,
			cmp = self.defMagCmp,
			levelCmp = self.defMagLevelCmp
		},
		{
			title = atkMagTitle,
			title2 = txtSATKUSDFText,
			num = self.atkMagNum,
			cmp = self.atkMagCmp,
			levelCmp = self.atkMagLevelCmp
		}
	}

	local petInfo = pg.me:getPetInfo(self.petId)
	local propLevels = pg.game.petManage:getPetPropLevels(petInfo)

	for i, bind in ipairs(self.sixPropUIBinds) do
		local propLevel = propLevels[i]

		ClientTextUtils.setText(bind.title, pg.getLocalizationText(propLevel.l18nNameKey or ""))
		ClientTextUtils.setText(bind.title2, pg.getLocalizationText(propLevel.l18nNameKey or ""))
	end

	self.btnSwitchMaxUButton:SetActive(false)

	function self.btnDetailUButton.luaClick()
		self:openPropertyPanel()
	end
end

function NpcDuelStartPetDetail:refreshPetName(petName)
	if self.petNameUText then
		ClientTextUtils.setText(self.petNameUText, petName)
	end

	if self.name01USDFText then
		ClientTextUtils.setText(self.name01USDFText, petName)
	end

	if self.nameShineUSDFText then
		ClientTextUtils.setText(self.nameShineUSDFText, petName)
	end
end

function NpcDuelStartPetDetail:renderPetInfoCard(data)
	if not data then
		return
	end

	local petId = data.id or self.petId
	local templateId = data.templateId or self.templateId

	if not petId or not templateId then
		return
	end

	self.petNameStr = self:getPetName(petId)

	if pg.game.setting and pg.game.setting:getShowDebugId() then
		self.petNameStr = self.petNameStr .. tostring(templateId)
	end

	self:refreshPetName(self.petNameStr)

	if self.petElementUList then
		function self.petElementUList.luaRenderItem(button, _, itemData)
			LuaUIUtils.setElementButtonNew(button, itemData.element, true, templateId)
		end

		self.petElementUList:SetList(data.elementNames or {})
	end

	local pet = pg.me:getPetInfo(petId)

	if self.numCPUText then
		local cpText = data.cp or 0

		if pet and pet.isCatchReporting and pet:isCatchReporting() then
			cpText = "???"
		end

		ClientTextUtils.setText(self.numCPUText, ClientTextUtils.concatByLanguage(pg.getGameString("CP"), cpText))
	end

	if self.listExploreAbilityUList then
		LuaUIUtils.renderPetCharList(self.listExploreAbilityUList, templateId)
	end

	self:syncRightPanelState(data)

	if self.numLevelUText then
		ClientTextUtils.setText(self.numLevelUText, data.level or 0)
	end

	if self.expSlider then
		local level = data.level or 0
		local maxExp = PetLevelData[level + 1] ~= nil and PetLevelData[level + 1].needExp or 0

		self.expSlider.value = maxExp == 0 and 1 or (data.exp or 0) / maxExp
	end

	if self.listTagUList then
		self.listTagUList:SetList(LuaUIUtils.getPetTagList(data))
	end

	local petConfig = PetData[templateId] or {}
	local petType = petConfig.functionId

	if petType then
		if self.typeImage and PetConfigData.petFunctionIcon then
			self.typeImage.url = PetConfigData.petFunctionIcon[petType]
		end

		if self.typeDesc then
			local typeTextKey = PetConfigData[string.format("petFunctionText%s", petType)]

			ClientTextUtils.setText(self.typeDesc, typeTextKey and pg.getLocalizationText(typeTextKey) or "")
		end
	end
end

function NpcDuelStartPetDetail:setTotalAttribute(petId)
	if not self.propCmpGroup or not petId then
		return
	end

	local petInfo = pg.me:getPetInfo(petId)

	if not petInfo then
		return
	end

	local propertyEnhanced = Utils.isPetPropertyEnhanced(petInfo)
	local templateId = petInfo.templateId
	local petData = PetData[templateId] or {}
	local recommend = petData.recommend_attr or {}
	local propLevels = pg.game.petManage:getPetPropLevels(petInfo) or {}

	self.defaultRatioGroup = {}
	self.addedRatioGroup = {}

	if self.ctrl then
		self.ctrl.recordCurPetPropData = {}
	end

	local isTrained = 0

	for i = Const.BASE_PROPERTY_HP_IDX, Const.BASE_PROPERTY_ATK_MAG_IDX do
		local propLevel = propLevels[i]
		local baseAndActiveTotalLv = propLevel.baseAndActiveTotalLv or 0
		local complexBaseLv = propLevel.complexBaseLv or 0
		local max = propLevel.max or 1

		if max == 0 then
			max = 1
		end

		local val = math.ceil(propLevel.propDisplayVal or 0)
		local bind = self.sixPropUIBinds and self.sixPropUIBinds[i]

		if bind and bind.num then
			ClientTextUtils.setText(bind.num, val)
		end

		if self.ctrl and self.ctrl.recordCurPetPropData then
			self.ctrl.recordCurPetPropData[i] = val
		end

		if self.propLevelGroup and self.propLevelGroup[i] then
			ClientTextUtils.setText(self.propLevelGroup[i], baseAndActiveTotalLv)
		end

		local propCmp = self.propCmpGroup and self.propCmpGroup[i]
		local propLevelCmp = self.propLevelCmpGroup and self.propLevelCmpGroup[i]

		if propCmp then
			function propCmp.luaTooltipPopup(_, flag)
				propCmp:TryChangePage("Selected", flag and 1 or 0)
			end

			function propCmp.luaRenderTooltip(_, component)
				PetManagementUtils.customRefreshBuffInfoTooltip(component, PetManagementDataHelper.BuffInfoToolTipType.Cultivate, {
					index = i,
					recommend = recommend,
					propertyEnhanced = propertyEnhanced,
					propLevel = propLevel
				})
			end
		end

		local learnt = propLevel.learnt or 0
		local state = learnt > 0 and 1 or 0

		propCmp:TryChangePage("State", state)
		propLevelCmp:TryChangePage("State", state)

		if LuaUIUtils.tableContains(recommend, i) then
			propCmp:TryChangePage("GoodState", 1)
		else
			propCmp:TryChangePage("GoodState", 0)
		end

		propLevelCmp:TryChangePage("Updated", propertyEnhanced and 1 or 0)

		if propertyEnhanced then
			propLevelCmp:TryChangePage("State", 1)
		end

		if max <= baseAndActiveTotalLv then
			propCmp:TryChangePage("State", 2)
			propLevelCmp:TryChangePage("State", 2)
		end

		self.defaultRatioGroup[i] = complexBaseLv / max
		self.addedRatioGroup[i] = baseAndActiveTotalLv / max

		if learnt > 0 then
			isTrained = isTrained + 1
		end
	end

	if self.defaultRadar then
		self.defaultRadar:SetSixProps(self.defaultRatioGroup[Const.BASE_PROPERTY_HP_IDX], self.defaultRatioGroup[Const.BASE_PROPERTY_ATK_IDX], self.defaultRatioGroup[Const.BASE_PROPERTY_DEF_IDX], self.defaultRatioGroup[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX], self.defaultRatioGroup[Const.BASE_PROPERTY_DEF_MAG_IDX], self.defaultRatioGroup[Const.BASE_PROPERTY_ATK_MAG_IDX])
	end

	if self.addedRadar then
		self.addedRadar:SetSixProps(self.addedRatioGroup[Const.BASE_PROPERTY_HP_IDX], self.addedRatioGroup[Const.BASE_PROPERTY_ATK_IDX], self.addedRatioGroup[Const.BASE_PROPERTY_DEF_IDX], self.addedRatioGroup[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX], self.addedRatioGroup[Const.BASE_PROPERTY_DEF_MAG_IDX], self.addedRatioGroup[Const.BASE_PROPERTY_ATK_MAG_IDX])

		if self.addedRadar.transform and self.addedRadar.transform.gameObject then
			self.addedRadar.transform.gameObject:SetActiveEx(isTrained > 0)
		end
	end

	self:ratioAttribute(petInfo)

	local featureInfo = PetManagementDataHelper.getCurCharacter(petId)

	if featureInfo then
		self.btnTalentUButton:SetActive(true)

		if self.btnRareTraitUButton then
			self.btnRareTraitUButton:TryChangePage("Rare", featureInfo.rare == 1 and 1 or 0)
			LuaUIUtils.setRenderFeatureToolTips(self.btnRareTraitUButton, featureInfo, petInfo)
		end

		if self.featureIcon then
			self.featureIcon.url = featureInfo.icon
		end
	else
		self.btnTalentUButton:SetActive(false)
	end
end

function NpcDuelStartPetDetail:refreshGiftList(data)
	if self.btnTalentUButton then
		function self.btnTalentUButton.luaClick()
			local talentButton = self.btnTalentUButton
			local talentData = {}

			talentData.targetRect = talentButton
			talentData.autoHor = true
			talentData.type = UIConst.GIFT_TYPE.BATTLE
			talentData.showType = UIConst.GIFT_SHOW_TYPE.GIFT
			talentData.giftType = UIConst.GIFT_TYPE.HOME
			talentData.breedTalent = data.breedTalent
			talentData.petId = data.id
			talentData.extra = {
				openFun = function()
					talentButton.isSelected = true

					talentButton:TryChangePage("button", 5)
				end,
				closeFun = function()
					talentButton.isSelected = false

					talentButton:TryChangePage("button", 0)
				end
			}

			pg.global.ui:open(UIConst.UI_ID_PET_GIFT_TIPS, talentData)
		end
	end

	if self.accessListUList then
		function self.accessListUList.luaRenderItem(button, _, itemData)
			if not itemData or itemData.empty then
				return
			end

			local objectReference = button:GetComponent("ObjectReference")
			local iconUImage = objectReference:GetRefValue("iconUImage")
			local rayBoxUWidget = objectReference:GetRefValue("rayBoxUWidget")

			iconUImage.url = itemData.icon

			rayBoxUWidget.gameObject:SetActiveEx(false)
			button:TryChangePage("Quality", itemData.quality)
		end

		self.accessListUList:SetList(data.breedTalent or {})
	end
end

function NpcDuelStartPetDetail:renderAbilityPanel(data)
	local petInfo = pg.me:getPetInfo(data.id)

	self.petInfo = petInfo

	self:renderPetInfoCard(data)
	self:setTotalAttribute(petInfo.id)
	self:refreshGiftList(data)
	self:refreshStarUpContainer(data)
end

function NpcDuelStartPetDetail:syncRightPanelState(data)
	if data.gender == Const.GENDER_TYPE_MALE then
		self.rightPanelUComponent:TryChangePage("Gender", 0)
	elseif data.gender == Const.GENDER_TYPE_FEMALE then
		self.rightPanelUComponent:TryChangePage("Gender", 1)
	else
		self.rightPanelUComponent:TryChangePage("Gender", 2)
	end

	self.rightPanelUComponent:TryChangePage("isFlash", data.isShiny and 1 or 0)

	if self.title then
		self.title:TryChangePage("isBoss", data.isBoss and 1 or 0)
		self.title:TryChangePage("isChange", data.isVariant and 1 or 0)
	end
end

function NpcDuelStartPetDetail:addSkillGamepadListeners()
	return
end

function NpcDuelStartPetDetail:findPanelSkillUContainerObjects()
	if self.panelSkillUContainerObjectReference then
		return
	end

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
	self.txtUniqueUSDFText = self.skillUWidgetObjectReference:GetRefValue("txtUniqueUSDFText")
	self.uniqueUWidget = self.skillUWidgetObjectReference:GetRefValue("uniqueUWidget")

	ClientTextUtils.setText(self.txtUniqueUSDFText, pg.getGameString("PETSKILL_ULTIMATE"))

	function self.btnSkillPresetsUButton.luaClick()
		self:onClickSkillPresetsButton()
	end

	self:addSkillGamepadListeners()

	if self.ctrl and self.ctrl.refreshLeftPanelHotKeyVisible then
		self.ctrl:refreshLeftPanelHotKeyVisible()
	end
end

function NpcDuelStartPetDetail:setFeature(petId)
	local featureInfo = PetManagementDataHelper.getCurCharacter(petId)

	if featureInfo then
		local objectReference = self.btnFeaturesUButton:GetComponent("ObjectReference")
		local iconFeatureUImage = objectReference:GetRefValue("iconFeatureUImage")

		self.btnFeaturesUButton:TryChangePage("IsRare", featureInfo.rare or 0)
		self.btnFeaturesUButton:TryChangePage("State", 1)

		iconFeatureUImage.url = featureInfo.icon
		self.btnFeaturesUButton.enabledTooltip = true

		function self.btnFeaturesUButton.luaTooltipPopup(_, flag)
			self.btnFeaturesUButton:TryChangePage("Selected", flag and 1 or 0)
		end

		LuaUIUtils.setRenderFeatureToolTips(self.btnFeaturesUButton, featureInfo, pg.me:getPetInfo(petId))
	else
		self.btnFeaturesUButton.enabledTooltip = false

		self.btnFeaturesUButton:TryChangePage("IsRare", 0)
		self.btnFeaturesUButton:TryChangePage("State", 0)
	end
end

function NpcDuelStartPetDetail:refreshSkillList(petId)
	if not self.btnUniqueSkillUButton then
		return
	end

	local ultSkillInfo = PetManagementDataHelper.getPetSkillInfos(petId, AbilityConst.ULTIMATE_ABILITY)
	local qSkillInfo = PetManagementDataHelper.getPetSkillInfos(petId, AbilityConst.WEAPON_SKILL_ABILITY)
	local eSkillInfo = PetManagementDataHelper.getPetSkillInfos(petId, AbilityConst.WEAPON_SKILL_ABILITY2)
	local exploreSkillInfo = PetManagementDataHelper.getPetSkillInfos(petId, AbilityConst.EXPLORE_ABILITY)

	self.petInfo = pg.me:getPetInfo(petId)

	self:renderSkillCmp(self.btnUniqueSkillUButton, ultSkillInfo)
	self:renderSkillCmp(self.btnNormalSkill1UButton, qSkillInfo)

	self.btnNormalSkill1UButton.draggable = false

	self:renderSkillCmp(self.btnNormalSkill2UButton, eSkillInfo)

	self.btnNormalSkill2UButton.draggable = false

	self:renderExploreSkillCmp(self.btnExploreSkillUButton, exploreSkillInfo)
	TimerManager.addNextFrameCb(function()
		local petInfo = pg.me:getPetInfo(petId)

		if not petInfo or not petInfo.abilityPresetMap then
			return
		end

		local abilityPresetMap = petInfo.abilityPresetMap[petInfo.curAbilityPreset]
		local presetName = abilityPresetMap and abilityPresetMap.name or ""

		if presetName and presetName ~= "" then
			ClientTextUtils.setText(self.skillPresetName, presetName)
		else
			ClientTextUtils.setText(self.skillPresetName, ClientTextUtils.concatByLanguage(pg.getGameString("ABILITY_PLAN"), petInfo.curAbilityPreset))
		end
	end)
end

function NpcDuelStartPetDetail:renderSkillPanel(data)
	self:setCarryItem(data.id)
	self:setFeature(data.id)
	self:refreshSkillList(data.id)
end

function NpcDuelStartPetDetail:renderSkillCmp(button, data)
	local isSuccess = LuaUIUtils.renderSkillCmpCommon(button, data, nil, nil, nil, self.petInfo)
	local isEmpty = not isSuccess

	if self.ctrl and self.ctrl.setConsoleBarState and self.ctrl.CONSOLE_BAR_STATE then
		function button.luaHover()
			self.ctrl:setConsoleBarState(self.ctrl.CONSOLE_BAR_STATE.IN_EMPTY_SKILL, isEmpty)
		end

		function button.luaUnhover()
			self.ctrl:setConsoleBarState(self.ctrl.CONSOLE_BAR_STATE.IN_EMPTY_SKILL, false)
		end
	else
		button.luaHover = nil
		button.luaUnhover = nil
	end

	if not isSuccess then
		return
	end

	button.enabledTooltip = true

	function button.luaTooltipPopup(_, flag)
		button:TryChangePage("Selected", flag and 1 or 0)
	end

	LuaUIUtils.setRenderSKillTooTip(button, data, nil, self.petInfo)
end

function NpcDuelStartPetDetail:renderExploreSkillCmp(button, data)
	if not data then
		button.enabledTooltip = false
		button.luaHover = nil
		button.luaUnhover = nil
		button.luaTooltipPopup = nil

		self.uniqueUWidget:SetActive(false)
		button:SetActive(false)

		return
	end

	button:SetActive(true)

	local objectReference = button:GetComponent("ObjectReference")
	local iconNormalUImage = objectReference:GetRefValue("iconNormalUImage")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

	button:TryChangePage("State", 0)
	button:TryChangePage("Element", 0)

	local isEmpty = not data

	if self.ctrl and self.ctrl.setConsoleBarState and self.ctrl.CONSOLE_BAR_STATE then
		function button.luaHover()
			self.ctrl:setConsoleBarState(self.ctrl.CONSOLE_BAR_STATE.IN_EMPTY_SKILL, isEmpty)
		end

		function button.luaUnhover()
			self.ctrl:setConsoleBarState(self.ctrl.CONSOLE_BAR_STATE.IN_EMPTY_SKILL, false)
		end
	else
		button.luaHover = nil
		button.luaUnhover = nil
	end

	self.uniqueUWidget:SetActive(true)
	button:TryChangePage("State", 1)

	iconNormalUImage.url = LuaUIUtils.getSkillIcon(data.icon)

	ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.name))

	button.enabledTooltip = true

	function button.luaTooltipPopup(_, flag)
		button:TryChangePage("Selected", flag and 1 or 0)
	end

	LuaUIUtils.setRenderExploreToolTips(button, data)
end

function NpcDuelStartPetDetail:ratioAttribute(pet)
	if not self.newRatioNodeUComp then
		return
	end

	if self.root then
		self.root:TryChangePage("NotVerified", pet:isCatchReporting() and 1 or 0)
	end

	PetManagementUtils.setPetRatioUINode(pet, self.newRatioNodeUComp)
end

function NpcDuelStartPetDetail:openPropertyPanel()
	pg.global.ui:open(UIConst.UI_ID_PET_PROPERTY, {
		curPetId = self.petId
	})
end

function NpcDuelStartPetDetail:refreshStarUpContainer(data)
	self:m_refreshStarUpContainer(self.petId, self, self.starUContainer, data)
end

function NpcDuelStartPetDetail:m_refreshStarUpContainer(petId, uiObj, starUContainer, data)
	if not petId or not uiObj or not starUContainer then
		return
	end

	local curResonanceInfo = PetManagementUtils.getPetStarUpInfo(petId)

	if not curResonanceInfo then
		return
	end

	local stage = curResonanceInfo.resonanceStage or 0
	local level = curResonanceInfo.resonanceLevel or 0
	local curStageStarUrl = PetManagementUtils.getStarItemUrl(stage, true)

	starUContainer:SetUrlWithCallback(curStageStarUrl, function()
		if not petId or not uiObj or IsNil(uiObj.starUContainer) then
			return
		end

		local starUCont = uiObj.starUContainer.content

		uiObj.m_starComp = PetResonaceStarComponent.new(starUCont)

		if uiObj.m_starComp then
			uiObj.m_starComp:updateAndRefresh(petId, {
				stage = stage,
				lv = level
			})
		end
	end)
end

function NpcDuelStartPetDetail:refreshOnCarryLockChange(isLocked)
	if self.m_carryItemId and self.petId and NotNil(self.m_carryTooptip) and NotNil(self.m_rootUButton) then
		self:refreshCarryItemTooltip()
	end
end

function NpcDuelStartPetDetail:setCarryItem(petId, forbidToolTip)
	if not self.carryItemUComponent then
		return
	end

	self.carryItemUComponent.gameObject:SetActiveEx(true)

	local objectReference = self.carryItemUComponent:GetComponent("ObjectReference")
	local iconPropUImage = objectReference:GetRefValue("iconPropUImage")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local txtStrengthenUSDFText = objectReference:GetRefValue("txtStrengthenUSDFText")
	local listGemsUList = objectReference:GetRefValue("listGemsUList")
	local rootUButton = objectReference:GetRefValue("rootUButton")
	local carryData = pg.global.ui.petTrainingNew.model:getPetEquipCarry(petId)

	if not carryData then
		self.carryItemUComponent:TryChangePage("Empty", 1)

		if NotNil(rootUButton) then
			rootUButton.enabledTooltip = false
		end
	else
		self.carryItemUComponent:TryChangePage("Empty", 0)

		local isRecommend = LuaUIUtils.checkCarryIsRecommend(petId, carryData.itemId)

		self.carryItemUComponent:TryChangePage("GoodState", isRecommend and 1 or 0)
		self.carryItemUComponent:TryChangePage("Quality", carryData.quality)

		iconPropUImage.url = carryData.icon

		ClientTextUtils.setText(txtNameUSDFText, carryData.name)
		ClientTextUtils.setText(txtStrengthenUSDFText, "+" .. carryData.cLevel)
		LuaUIUtils.refreshCarryAssistInfo(listGemsUList, nil, carryData, true)

		local contactTransform = self.carryItemUComponent.transform:Find("Normal/LayoutName/Contact")

		LuaUIUtils.generalRefreshCarryCertifyComp(contactTransform, carryData.certifiedBaseFormPet)

		if rootUButton then
			rootUButton.enabledTooltip = not forbidToolTip

			if not forbidToolTip and carryData.itemId and carryData.itemId ~= 0 then
				function rootUButton.luaRenderTooltip(btn, tooltip)
					self.m_carryTooptip = tooltip
					self.m_carryItemId = carryData.itemId
					self.m_rootUButton = rootUButton

					self:refreshCarryItemTooltip(true)
				end
			else
				rootUButton.luaClick = nil
			end
		end
	end
end

function NpcDuelStartPetDetail:refreshCarryItemTooltip(isNewRender)
	if IsNil(self.m_carryTooptip) or not self.m_carryItemId or not self.petId then
		return
	end

	local paramInfo = pg.global.ui.petTrainingNew.model:getPetEquipCarry(self.petId)

	if not paramInfo then
		return
	end

	paramInfo.itemCount = paramInfo.ownNum
	paramInfo.petId = self.petId
	paramInfo.isGotoCarry = true
	paramInfo.showLock = true
	self.m_paramInfo = paramInfo

	function paramInfo.btnLockFunc()
		pg.game.petManage:sendRpcLockCarryItemStatus(self:getCarryParamInfo())
	end

	if isNewRender then
		LuaUIUtils.refreshItemInfo(self.m_carryTooptip, paramInfo, self.m_rootUButton)
	else
		self.m_carryTooptip:TryChangePage("Lock", paramInfo.isLocked and 1 or 0)
	end
end

function NpcDuelStartPetDetail:getCarryParamInfo()
	return self.m_paramInfo
end

function NpcDuelStartPetDetail:findPanelInfoUContainerObjects()
	if self.panelInfoUContainerObjectReference then
		return
	end

	if LuaUIUtils.getPetPanelInfoObjectReferences then
		self.panelInfoUContainerObjectReference, self.panelInfoDetailObjectReference = LuaUIUtils.getPetPanelInfoObjectReferences(self.panelInfoUContainer.content)
	else
		self.panelInfoUContainerObjectReference = self.panelInfoUContainer.content.transform:GetComponent("ObjectReference")
		self.panelInfoDetailObjectReference = self.panelInfoUContainerObjectReference
	end

	self.beenText = self.panelInfoUContainerObjectReference:GetRefValue("beenText")
	self.rawImageRawImagePro = self.panelInfoUContainerObjectReference:GetRefValue("rawImageRawImagePro")
	self.uINodePetPanelInfoUComponent = self.panelInfoUContainerObjectReference:GetRefValue("uINodePetPanelInfoUComponent")
	self.accessListUListHome = self.panelInfoDetailObjectReference:GetRefValue("accessListUList")
	self.btnTalentUButtonHome = self.panelInfoDetailObjectReference:GetRefValue("btnTalentUButton")
	self.abilityListUList = self.panelInfoDetailObjectReference:GetRefValue("abilityListUList")
	self.txtTitleTalentUSDFText = self.panelInfoDetailObjectReference:GetRefValue("txtTitleTalentUSDFText")
	self.btnAbilityUButton = self.panelInfoDetailObjectReference:GetRefValue("btnAbilityUButton")
	self.sourceUWidget = self.panelInfoDetailObjectReference:GetRefValue("sourceUWidget")
	self.txtSourceUBaseText = self.panelInfoDetailObjectReference:GetRefValue("txtSourceUBaseText")
	self.textUSDFText = self.panelInfoUContainerObjectReference:GetRefValue("textUSDFText")
	self.listFunctionBtnUList = self.panelInfoDetailObjectReference:GetRefValue("listFunctionBtnUList")
	self.txtNumLiveUSDFText = self.panelInfoDetailObjectReference:GetRefValue("txtNumLiveUSDFText")
	self.txtTitleLiveUSDFText = self.panelInfoDetailObjectReference:GetRefValue("txtTitleLiveUSDFText")
	self.btnLiveUButton = self.panelInfoDetailObjectReference:GetRefValue("btnLiveUButton")
	self.ballGetUWidget = self.panelInfoDetailObjectReference:GetRefValue("ballGetUWidget")
	self.iconBallUImage = self.panelInfoDetailObjectReference:GetRefValue("iconBallUImage")

	self.listFunctionBtnUList:SetActive(false)
	self:tryRefreshPetPreview(true)

	if self.ctrl and self.ctrl.refreshLeftPanelHotKeyVisible then
		self.ctrl:refreshLeftPanelHotKeyVisible()
	end
end

function NpcDuelStartPetDetail:refreshInfo(data, force)
	ClientTextUtils.setText(self.beenText, pg.getFormatText(pg.getGameString("BEEN_WITH"), math.round((Time.secondCache * 1000 - data.time) / 1000 / 3600 / 24)))
	ClientTextUtils.setText(self.textUSDFText, PetManagementUtils.getDisplayBookNumberText(data))
	ClientTextUtils.setText(self.txtNumLiveUSDFText, ClientHomelandUtils.getPetComfortValueById(data.id))
	ClientTextUtils.setText(self.txtTitleLiveUSDFText, pg.getGameString("HOMELAND_COMPOSE_LIVE_VALUE") .. ":")
	ClientTextUtils.setText(self.txtTitleTalentUSDFText, pg.getLocalizationText(UIConst.PET_INFO_TEXT_ID.PERSONALITY_TITLE) .. ":")

	function self.btnLiveUButton.luaRenderTooltip(btn, com)
		local objectReference = com.transform:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("HOMELAND_COMFORT_TIP"))
	end

	LuaUIUtils.bindHomeWishingStarOutput(self.panelInfoDetailObjectReference, data)

	local petCubeItemId = data and data.cubeItemId

	if LuaUIUtils.refreshPetPanelInfoCubeAndBackground then
		LuaUIUtils.refreshPetPanelInfoCubeAndBackground(petCubeItemId, self.panelInfoUContainerObjectReference)
	elseif LuaUIUtils.refreshPetFertilityCubeInfo and self.ballGetUWidget and self.iconBallUImage then
		LuaUIUtils.refreshPetFertilityCubeInfo(petCubeItemId, self.ballGetUWidget, self.iconBallUImage)
	end

	if LuaUIUtils.refreshPetIntimacy then
		LuaUIUtils.refreshPetIntimacy(self.panelInfoUContainerObjectReference, data)
	end

	function self.btnTalentUButtonHome.luaClick()
		local talentData = {}

		talentData.targetRect = self.uINodePetPanelInfoUComponent
		talentData.autoHor = true
		talentData.type = UIConst.GIFT_TYPE.HOME
		talentData.showType = UIConst.GIFT_SHOW_TYPE.GIFT
		talentData.giftType = UIConst.GIFT_TYPE.HOME
		talentData.breedTalent = data.breedTalent
		talentData.petId = self.petId
		talentData.extra = {
			openFun = function()
				self.btnTalentUButtonHome.isSelected = true

				self.btnTalentUButtonHome:TryChangePage("button", 5)
			end,
			closeFun = function()
				self.btnTalentUButtonHome.isSelected = false

				self.btnTalentUButtonHome:TryChangePage("button", 0)
			end
		}

		pg.global.ui:open(UIConst.UI_ID_PET_GIFT_TIPS, talentData)
	end

	function self.btnAbilityUButton.luaClick()
		local abilityData = self:getHomeAbilityData()
		local talentData = {}

		talentData.targetRect = self.uINodePetPanelInfoUComponent
		talentData.autoHor = true
		talentData.showType = UIConst.GIFT_SHOW_TYPE.ABILITY
		talentData.abilityData = abilityData

		pg.global.ui:open(UIConst.UI_ID_PET_GIFT_TIPS, talentData)
	end

	self:tryRefreshPetPreview(force)
	self:refreshGiftInfoList(data)
	self:refreshSource(data)
end

function NpcDuelStartPetDetail:onHomelandWishStarChanged()
	if not self.petId or not self.panelInfoUContainer or not self.panelInfoUContainer:CheckURLLoaded() or not self.panelInfoDetailObjectReference then
		return
	end

	local petInfo = pg.me:getPetInfo(self.petId)

	if petInfo and not petInfo.empty and not petInfo.isEmpty then
		LuaUIUtils.refreshHomeWishingStarOutput(self.panelInfoDetailObjectReference, petInfo)
	end
end

function NpcDuelStartPetDetail:tryRefreshPetPreview(force)
	local ctrl = self.ctrl

	if not ctrl or not self.rawImageRawImagePro or IsNil(self.rawImageRawImagePro) or not self.petId or self.pageIndex ~= 2 then
		return
	end

	if ctrl.isPetPreviewUISceneReady and ctrl:isPetPreviewUISceneReady() then
		ctrl:activatePetPreviewUIScene()
		ctrl.petPreviewUIScene:setRawImageProRef(self.rawImageRawImagePro)
		ctrl.petPreviewUIScene:previewPet(self.petId, force)

		return
	end

	if ctrl.ensurePetPreviewUIScene then
		ctrl:ensurePetPreviewUIScene(function(scene)
			if not scene or not self.rawImageRawImagePro or IsNil(self.rawImageRawImagePro) or self.pageIndex ~= 2 then
				return
			end

			scene:setRawImageProRef(self.rawImageRawImagePro)
			scene:previewPet(self.petId, force)
		end)
	end
end

function NpcDuelStartPetDetail:getHomeAbilityData()
	local homeAbility = PetData[self.templateId].homeAbility
	local abilityData = {}

	if not homeAbility then
		return abilityData
	end

	for id, ability in pairs(homeAbility) do
		local data = {}

		data.id = id
		data.level = ability

		table.insert(abilityData, data)
	end

	return abilityData
end

function NpcDuelStartPetDetail:refreshGiftInfoList(data)
	function self.accessListUListHome.luaRenderItem(button, _, itemData)
		if itemData.empty then
			return
		end

		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local rayBoxUWidget = objectReference:GetRefValue("rayBoxUWidget")

		iconUImage.url = itemData.icon

		rayBoxUWidget.gameObject:SetActiveEx(false)
		button:TryChangePage("Quality", itemData.quality)
	end

	self.accessListUListHome:SetList(data.breedTalent)

	function self.abilityListUList.luaRenderItem(button, _, itemData)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local numLevelTextPlus = objectReference:GetRefValue("numLevelTextPlus")
		local iconBG = objectReference:GetRefValue("imgBgImagePro")
		local homeAbilityData = HomeAbilityData[itemData.id]

		ClientTextUtils.setText(numLevelTextPlus, itemData.level)

		iconUImage.url = homeAbilityData.icon

		iconBG:SetColorWithHtmlString(homeAbilityData.iconColor)
	end

	self.abilityListUList:SetList(self:getHomeAbilityData())
end

function NpcDuelStartPetDetail:refreshSource(data)
	local source = PetManagementDataHelper.getPetSource(data.id)
	local showSource = source ~= nil and source ~= ""

	self.sourceUWidget:SetActive(showSource)

	if showSource then
		local playerName = ""
		local playerInfo = pg.game.chat:getPlayerInfo(source)

		if playerInfo then
			playerName = playerInfo.playerName or ""
		end

		local hooks = NpcDuelStartPetDetail._platformHooks

		playerName = hooks and hooks.refreshSourcePlayerName and hooks.refreshSourcePlayerName(self, data, source, playerName, playerInfo) or playerName

		local tip = string.gsub(pg.getGameString("PET_EXCHANGE_SOURCE"), "{0}", playerName)

		ClientTextUtils.setText(self.txtSourceUBaseText, tip)
	end
end

function NpcDuelStartPetDetail:onClickSkillPresetsButton()
	pg.global.ui:open(UIConst.UI_ID_PET_SKILL_REPLACE_QUICK, {
		curPetId = self.petId,
		templateId = self.templateId
	})
end

return NpcDuelStartPetDetail
