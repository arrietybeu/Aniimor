-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetManagement\\Component\\DetailComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("DetailComponent")
local OpDef = require("Common.OpDef")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Time = require("Core.Common.Time")
local PetResearchContentData = require("Data.pet_research_content_data")
local Const = require("Common.Const.Const")
local PetData = require("Data.pet_data")
local PetConfigData = require("Data.pet_config_data")
local SceneData = require("Data.scene_data")
local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local DetailComponent = Class.LightClass("DetailComponent", UIComponent)
local PetEvolveData = require("Data.pet_evolve_data")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local TimerManager = require("Core.Timer.TimerManager")
local PetLevelData = require("Data.pet_level_data")
local PetPropLevelMaxData = require("Data.pet_prop_level_max")
local Utils = require("Common.Utils.Utils")
local AbilityConst = require("Common.Const.AbilityConst")
local PetDetailPropertyData = require("Data.pet_detail_property_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local UIConst = require("Const.UIConst")
local HomeAbilityData = require("Data.home_ability_data")
local PetFormChangeData = require("Data.pet_form_change_data")
local FunctionEnum = require("Data.function_unlock_enum")
local ClientHomelandUtils = require("Utils.ClientHomelandUtils")
local AddressDataConst = require("Const.AddressDataConst")
local PetResonaceStarComponent = require("Guis.Panels.PetTrainingNew.Component.SubNodeComps.PetResonaceStarComponent")
local PetCardCarryInfoComponent = require("Guis.Panels.PetTrainingNew.Component.SubNodeComps.PetCardCarryInfoComponent")
local NoticeDef = require("Common.NoticeDef")
local BaseProperty = require("CustomTypes.BaseProperty")
local PetRenameValidator = require("Utils.PetRenameValidator")
local MessageName = require("Const.MessageName")
local EMPTY_EVO_BRANCH_ID = "emptyEvoBID"
local PET_VARIANT_DETAIL_GUIDE_TEXT_KEY = "PET_VARIANT_DETAIL_GUIDE"

DetailComponent.messages = {
	[MessageName.HOMELAND_WISH_STAR_CHANGED] = {
		"onHomelandWishStarChanged"
	}
}

function DetailComponent:findObjects()
	self.rightPanelUComponent = self.view.rightPanelUComponent
	self.btnEvolutionUButton = self.view.btnEvolutionUButton
	self.btnEvoImgArrowUImage = self.view.btnEvoImgArrowUImage
	self.btnCultivateUButton = self.view.btnCultivateUButton
	self.btnLvUp = self.view.btnLvUp
	self.btnStudyUButton = self.view.btnStudyUButton
	self.btnCarry = self.view.btnCarry

	local objectReference = self.rightPanelUComponent.transform:GetComponent("ObjectReference")

	self.panelAbilityUContainer = objectReference:GetRefValue("panelAbilityUContainer")
	self.panelSkillUContainer = objectReference:GetRefValue("panelSkillUContainer")
	self.panelInfoUContainer = objectReference:GetRefValue("panelInfoUContainer")
	self.attributeBtn = objectReference:GetRefValue("attributeBtn")
	self.skillBtn = objectReference:GetRefValue("skillBtn")
	self.infoBtn = objectReference:GetRefValue("infoBtn")
	self.btnInheritUButton = objectReference:GetRefValue("btnInheritUButton")
	self.panelControlUComponent = objectReference:GetRefValue("panelControlUComponent")
	self.tabContainerList = {
		self.panelAbilityUContainer,
		self.panelSkillUContainer,
		self.panelInfoUContainer
	}

	self:showRightPanel(true)

	self.previewed = nil
end

function DetailComponent:addAbilityGamepadListeners()
	return
end

function DetailComponent:addSkillGamepadListeners()
	return
end

function DetailComponent:findPanelAbilityUContainerObjects()
	self.panelAbilityUContainerObjectReference = self.panelAbilityUContainer.content.transform:GetComponent("ObjectReference")
	self.title = self.panelAbilityUContainerObjectReference:GetRefValue("title")
	self.detail = self.panelAbilityUContainerObjectReference:GetRefValue("detail")

	local titleObjectReference = self.title.transform:GetComponent("ObjectReference")

	self.titleObjectReference = titleObjectReference
	self.petNameUText = titleObjectReference:GetRefValue("petNameUText")
	self.name01USDFText = titleObjectReference:GetRefValue("name01USDFText")
	self.nameShineUSDFText = titleObjectReference:GetRefValue("nameShineUSDFText")
	self.petElementUList = titleObjectReference:GetRefValue("petElementUList")
	self.listExploreAbilityUList = titleObjectReference:GetRefValue("listExploreAbilityUList")
	self.listTagUList = titleObjectReference:GetRefValue("listTagUList")
	self.numCPUText = titleObjectReference:GetRefValue("numCPUText")
	self.btnRenameUButton = titleObjectReference:GetRefValue("btnRenameUButton")
	self.virtualRenameBtnUButton = titleObjectReference:GetRefValue("virtualRenameBtnUButton")
	self.btnFavoriteUButton = titleObjectReference:GetRefValue("btnFavoriteUButton")
	self.numLevelUText = titleObjectReference:GetRefValue("numLevelUText")
	self.expSlider = titleObjectReference:GetRefValue("expSlider")
	self.typeImage = titleObjectReference:GetRefValue("typeImage")
	self.typeDesc = titleObjectReference:GetRefValue("typeDesc")
	self.starUContainer = titleObjectReference:GetRefValue("starUContainer")
	self.btnLevelUButton = titleObjectReference:GetRefValue("btnLevelUButton")
	self.isChangeTipsUWidget = titleObjectReference:GetRefValue("isChangeTipsUWidget")
	self.btnIsChangeUButton = titleObjectReference:GetRefValue("btnIsChangeUButton")

	local changeTipsObjectReference = self.isChangeTipsUWidget.transform:GetComponent("ObjectReference")
	local changeTipsTextUSDFText = changeTipsObjectReference:GetRefValue("textUSDFText")

	ClientTextUtils.setText(changeTipsTextUSDFText, pg.getGameString(PET_VARIANT_DETAIL_GUIDE_TEXT_KEY))

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
	self.maxHotKeyContent = self.detailObjectReference:GetRefValue("maxHotKeyContent")
	self.btnDetailUButton = self.detailObjectReference:GetRefValue("btnDetailUButton")

	if NotNil(self.btnDetailUButton) then
		function self.btnDetailUButton.luaClick()
			PetManagementUtils._openPropertyPanel(self.petId)
		end
	end

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

	if self.btnFavoriteUButton then
		PetManagementUtils.setRenderFavoriteToolTips(self.btnFavoriteUButton, self.petId)
	end

	function self.btnFavoriteUButton.luaClick()
		self:onClickFavoriteBtn()
	end

	function self.btnRenameUButton.luaClick()
		PetRenameValidator.tryShowRenamePet(function()
			self.ctrl:showRename(self.model.RENAME_FOR_PET)
		end)
	end

	if self.virtualRenameBtnUButton then
		function self.virtualRenameBtnUButton.luaClick()
			PetRenameValidator.tryShowRenamePet(function()
				self.ctrl:showRename(self.model.RENAME_FOR_PET)
			end)
		end

		self.virtualRenameBtnUButton:SetHotkeyConsoleBar("CONSOLE_BAR_RENAME", -2)
	end

	function self.btnSwitchMaxUButton.luaClick()
		self:previewMaxLevel(true)
	end

	self.characterUWidget.gameObject:SetActiveEx(true)

	function self.btnTalentUButton.luaTooltipPopup(_, flag)
		self.btnTalentUButton.isSelected = flag

		self.btnTalentUButton:TryChangePage("button", flag and 5 or 0)
	end

	function self.listTagUList.luaRenderItem(button, idx, data)
		LuaUIUtils.renderPetTagList(button, data)
		LuaUIUtils.setPetTagLabelToolTip(button, LuaUIUtils.getPetTagInfo(self.templateId, self.label, self.bodySizeType, self.shinyStyle))
	end

	function self.btnLevelUButton.luaClick()
		self:onPetLvUpClick()
	end

	self:addAbilityGamepadListeners()

	if self.ctrl and self.ctrl.refreshLeftPanelHotKeyVisible then
		self.ctrl:refreshLeftPanelHotKeyVisible()
	end
end

function DetailComponent:findPanelSkillUContainerObjects()
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

function DetailComponent:findPanelInfoUContainerObjects()
	self.panelInfoUContainerObjectReference = self.panelInfoUContainer.content.transform:GetComponent("ObjectReference")
	self.petDesc = self.panelInfoUContainerObjectReference:GetRefValue("petDesc")
	self.beenText = self.panelInfoUContainerObjectReference:GetRefValue("beenText")
	self.infoPetName = self.panelInfoUContainerObjectReference:GetRefValue("infoPetName")
	self.txtDetailUSDFText = self.panelInfoUContainerObjectReference:GetRefValue("txtDetailUSDFText")
	self.rawImageRawImagePro = self.panelInfoUContainerObjectReference:GetRefValue("rawImageRawImagePro")
	self.nameShineUSDFText1 = self.panelInfoUContainerObjectReference:GetRefValue("nameShineUSDFText1")
	self.nameShineUSDFText2 = self.panelInfoUContainerObjectReference:GetRefValue("nameShineUSDFText2")
	self.uINodePetPanelInfoUComponent = self.panelInfoUContainerObjectReference:GetRefValue("uINodePetPanelInfoUComponent")
	self.accessListUListHome = self.panelInfoUContainerObjectReference:GetRefValue("accessListUList")
	self.btnTalentUButtonHome = self.panelInfoUContainerObjectReference:GetRefValue("btnTalentUButton")
	self.abilityListUList = self.panelInfoUContainerObjectReference:GetRefValue("abilityListUList")
	self.hobbyListUList = self.panelInfoUContainerObjectReference:GetRefValue("hobbyListUList")
	self.btnAbilityUButton = self.panelInfoUContainerObjectReference:GetRefValue("btnAbilityUButton")
	self.btnHobbyUButton = self.panelInfoUContainerObjectReference:GetRefValue("btnHobbyUButton")
	self.sourceUWidget = self.panelInfoUContainerObjectReference:GetRefValue("sourceUWidget")
	self.txtSourceUBaseText = self.panelInfoUContainerObjectReference:GetRefValue("txtSourceUBaseText")
	self.textUSDFText = self.panelInfoUContainerObjectReference:GetRefValue("textUSDFText")
	self.listFunctionBtnUList = self.panelInfoUContainerObjectReference:GetRefValue("listFunctionBtnUList")
	self.txtNumLiveUSDFText = self.panelInfoUContainerObjectReference:GetRefValue("txtNumLiveUSDFText")
	self.txtTitleLiveUSDFText = self.panelInfoUContainerObjectReference:GetRefValue("txtTitleLiveUSDFText")
	self.btnLiveUButton = self.panelInfoUContainerObjectReference:GetRefValue("btnLiveUButton")

	self:tryRefreshPetPreview(true)

	function self.listFunctionBtnUList.luaRenderItem(button, idx, data)
		self:renderOperationBtn(button, idx, data)
	end

	if self.ctrl and self.ctrl.refreshLeftPanelHotKeyVisible then
		self.ctrl:refreshLeftPanelHotKeyVisible()
	end
end

function DetailComponent:refreshOperationList()
	local operationDatas = self:getOperationDatas()

	self.listFunctionBtnUList:SetList(operationDatas)
end

function DetailComponent:renderOperationBtn(button, idx, data)
	if data.tIndex == 1 then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local listUList = objectReference:GetRefValue("listUList")

	function listUList.luaRenderItem(button1, idx1, data1)
		local objectReference1 = button1:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference1:GetRefValue("txtNameUSDFText")
		local iconFunctionUImage = objectReference1:GetRefValue("iconFunctionUImage")

		iconFunctionUImage.url = data1.icon

		ClientTextUtils.setText(txtNameUSDFText, pg.getGameString(data1.name))

		button1.enabledTooltip = false

		if data1.checkDistribution then
			if next(LuaUIUtils.checkPetCanShowDistributionArea(self.templateId)) then
				button1:TryChangePage("status", 0)

				button1.luaClick = nil
				button1.enabledTooltip = true

				local info = {
					state = LuaUIUtils.PetInfoState.Catch,
					petPrototypeId = self.templateId
				}

				LuaUIUtils.renderPetTip(button1, info, nil, nil, true, {
					showDistributionBtn = true
				})
			else
				button1:TryChangePage("status", 1)

				function button1.luaClick()
					pg.global.showBubbleMessageRaw(pg.getGameString("NO_DISTRIBUTION_INFO"))
				end
			end
		else
			function button1.luaClick()
				data1.luaClick()
			end
		end

		if data1.disVisualInteractable then
			button1.visualInteractable = false
		else
			button1.visualInteractable = true
		end
	end

	listUList:SetList(data)
end

function DetailComponent:getOperationDatas()
	local group = {}
	local ret1 = {}

	ret1[#ret1 + 1] = {
		checkDistribution = true,
		name = "SHOW_DISTRIBUTION_AREA",
		icon = AddressDataConst.UI_PET_BOX_PET_INFO_DISTRIBUTION
	}

	if PetResearchUtils.isKnownAndCaught(self.templateId) and PetResearchUtils.isShowInDetail(self.templateId) then
		ret1[#ret1 + 1] = {
			name = "PET_INFO_RESEARCH",
			luaClick = function()
				PetResearchUtils.openResearchDetail(self.templateId, UIConst.HANDBOOK_PAGE_IDX.FORM, {
					closeCb = function()
						if self.ctrl.uiScene then
							self.ctrl.uiScene:entActive(true)
						end
					end,
					countryId = Utils.getPetCountryId(self.templateId),
					formTargetTemplateId = self.templateId,
					formTargetLabel = self.label,
					formTargetShinyStyle = self.shinyStyle
				}, function()
					if self.ctrl.uiScene then
						self.ctrl.uiScene:entActive(false)
					end
				end)
			end,
			icon = AddressDataConst.UI_PET_BOX_PET_INFO_PET_MANUAL
		}
	end

	group[#group + 1] = ret1
	group[#group + 1] = {
		tIndex = 1
	}

	local ret = {}

	if pg.game.chat:checkCanGivePetAway(self.petId) then
		ret[#ret + 1] = {
			name = "PET_INFO_GIVE_AWAY",
			luaClick = function()
				pg.game.chat:openSpaceFollowPetGivePanel(self.petId)
			end,
			icon = AddressDataConst.UI_PET_BOX_PET_INFO_GIVE
		}
	end

	local canChangeForm = Utils.petCanChangeForm(pg.me, self.templateId) ~= false

	if canChangeForm then
		ret[#ret + 1] = {
			name = "PET_INFO_CHANGE_FORM",
			luaClick = function()
				self:openPetChangeFormPanel()
			end,
			icon = AddressDataConst.UI_PET_BOX_PET_INFO_CHANGE_FORM
		}
	end

	if SceneData[pg.space.sceneId].canTakeOutPet then
		ret[#ret + 1] = {
			name = "PET_INFO_TAKE_OUT",
			luaClick = function()
				local player = pg.me

				player:tryCarryEnt(self.model.curSelectPetId, OpDef.OP.CS_PC_PetTakeOut, Const.CARRY_REQ_FROM_PET_MANAGEMENT)
			end,
			icon = AddressDataConst.UI_PET_BOX_PET_INFO_PET_TAKE_OUT
		}
	else
		ret[#ret + 1] = {
			disVisualInteractable = false,
			name = "PET_INFO_TAKE_OUT",
			luaClick = function()
				pg.global.showBubbleMessageRaw(pg.getGameString("SCENE_CANNOT_HUG_PET_TIPS"))
			end,
			icon = AddressDataConst.UI_PET_BOX_PET_INFO_PET_TAKE_OUT
		}
	end

	ret[#ret + 1] = {
		name = "PET_INFO_DRESS",
		luaClick = function()
			self:openPetAccessory()
		end,
		icon = AddressDataConst.UI_PET_BOX_PET_INFO_DRESS_UP
	}

	local canTransmog = pg.game.petTransmog.canPetTransmog(self.petId)

	if canTransmog then
		ret[#ret + 1] = {
			name = "PETTRANSMOGRIFY_BUTTON",
			luaClick = function()
				self:openTransmogPanel()
			end,
			icon = AddressDataConst.UI_PET_BOX_PET_INFO_PET_TRANSMOG
		}
	end

	group[#group + 1] = ret

	return group
end

function DetailComponent:initView()
	function self.btnCultivateUButton.luaClick()
		self:onCultivateClick(self.petId)
	end

	function self.btnEvolutionUButton.luaClick()
		self:m_trySetRedDotEvoNew()
		self:openEvolution()
	end

	function self.btnLvUp.luaClick()
		self:onPetLvUpClick()
	end

	function self.btnStudyUButton.luaClick()
		self:showSkillLearnPop(self.petId)
	end

	function self.attributeBtn.luaClick()
		self:refreshSwitchPetInfoToPages(0)
	end

	function self.skillBtn.luaClick()
		self:refreshSwitchPetInfoToPages(1)
	end

	function self.infoBtn.luaClick()
		self:refreshSwitchPetInfoToPages(2)
	end

	function self.btnCarry.luaClick()
		self:openPetCarryPanel()
	end

	if NotNil(self.btnInheritUButton) then
		function self.btnInheritUButton.luaClick()
			self:openPetInheritPanel()
		end

		local btnObjRef = self.btnInheritUButton:GetComponent("ObjectReference")
		local txtNameUText = btnObjRef:GetRefValue("txtNameUText")

		ClientTextUtils.setText(txtNameUText, pg.getGameString("PET_INFO_INHERITANCE"))
	end

	local petInfo = self.model:getSinglePetInfo(self.model.curSelectPetId)

	petInfo = petInfo or {
		isEmpty = true
	}

	self:refreshPetInfoDetail(petInfo)
end

function DetailComponent:refreshSwitchPetInfoToPages(tabIndex, loadFinishCb)
	self:switchPetInfoTopPages(tabIndex, loadFinishCb)

	self.prePageIdx = tabIndex

	local petInfo = self.model:getSinglePetInfo(self.petId or 0)

	self:resetBtnState(petInfo)

	if self.ctrl then
		self.ctrl:setConsoleBarState(self.ctrl.CONSOLE_BAR_STATE.IN_EMPTY_SKILL, false)

		if tabIndex == 2 then
			self.ctrl:requestPetPreviewScene()
		end
	end

	self.rightPanelUComponent:TryChangePage("Inherit", self.prePageIdx == 2 and 1 or 0)
end

function DetailComponent:onPetPreviewSceneReady()
	self:tryRefreshPetPreview(true)
end

function DetailComponent:tryRefreshPetPreview(force)
	local scene = self.ctrl and self.ctrl.uiScene

	if not scene or not scene:checkLoaded() or IsNil(scene.scene) then
		return
	end

	if not self.rawImageRawImagePro or IsNil(self.rawImageRawImagePro) then
		return
	end

	if not self.petId or self.ctrl:getRightPanelCurrentPage() ~= 2 then
		return
	end

	scene:setRawImageProRef(self.rawImageRawImagePro)
	scene:previewPet(self.petId, force)
end

function DetailComponent:reSortTabContainer(startIdx)
	if startIdx == 1 then
		return
	end

	local tempContainerList = {}

	tempContainerList[1] = self.tabContainerList[startIdx]

	local tempIconList = {}

	tempIconList[1] = self.tabIconList[startIdx]

	for idx = 2, 3 do
		startIdx = startIdx + 1

		if startIdx > 3 then
			startIdx = 1
		end

		tempContainerList[idx] = self.tabContainerList[startIdx]
		tempIconList[idx] = self.tabIconList[startIdx]
	end

	self.tabContainerList = tempContainerList
	self.tabIconList = tempIconList
	self.iconTab1.url = self.tabIconList[2]
	self.iconTab2.url = self.tabIconList[3]
end

function DetailComponent:switchPetInfoTopPages(index, loadFinishCb)
	loadFinishCb = loadFinishCb or function()
		return
	end

	local pageIdx = index
	local container = self.tabContainerList[pageIdx + 1]

	self.rightPanelUComponent:TryChangePage("tabInfo", pageIdx)

	if pageIdx == 0 then
		if not container:CheckURLLoaded() then
			container:LoadDefaultUrlManually(function(obj)
				if IsNil(obj) or IsNil(self.model) then
					return
				end

				self:findPanelAbilityUContainerObjects()

				if self.panelAbilityUContainerData then
					self:renderPetInfoCard(self.panelAbilityUContainerData)
					self:setTotalAttribute(self.panelAbilityUContainerData.id)
					self:resetBtnState(self.panelAbilityUContainerData)
					self:previewMaxLevel()
					self:refreshGiftList(self.panelAbilityUContainerData)
					self:refreshStarUpContainer(self.panelAbilityUContainerData)

					self.panelAbilityUContainerData = nil
				end

				loadFinishCb()
			end)
		else
			self:previewMaxLevel()
			loadFinishCb()
		end

		if self.defaultRadar and self.defaultRatioGroup then
			self.defaultRadar:SetSixProps(self.defaultRatioGroup[Const.BASE_PROPERTY_HP_IDX], self.defaultRatioGroup[Const.BASE_PROPERTY_ATK_IDX], self.defaultRatioGroup[Const.BASE_PROPERTY_DEF_IDX], self.defaultRatioGroup[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX], self.defaultRatioGroup[Const.BASE_PROPERTY_DEF_MAG_IDX], self.defaultRatioGroup[Const.BASE_PROPERTY_ATK_MAG_IDX])
		end

		if self.addedRadar and self.addedRatioGroup then
			self.addedRadar:SetSixProps(self.addedRatioGroup[Const.BASE_PROPERTY_HP_IDX], self.addedRatioGroup[Const.BASE_PROPERTY_ATK_IDX], self.addedRatioGroup[Const.BASE_PROPERTY_DEF_IDX], self.addedRatioGroup[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX], self.addedRatioGroup[Const.BASE_PROPERTY_DEF_MAG_IDX], self.addedRatioGroup[Const.BASE_PROPERTY_ATK_MAG_IDX])
		end
	elseif pageIdx == 1 then
		if not container:CheckURLLoaded() then
			container:LoadDefaultUrlManually(function(obj)
				if IsNil(obj) then
					return
				end

				self:findPanelSkillUContainerObjects()

				if self.panelSkillUContainerData then
					self:setCarryItem(self.panelSkillUContainerData.id)
					self:setFeature(self.panelSkillUContainerData.id)
					self:refreshSkillList(self.panelSkillUContainerData.id)

					self.panelSkillUContainerData = nil
				end

				loadFinishCb()
			end)
		else
			loadFinishCb()
		end
	elseif not container:CheckURLLoaded() then
		container:LoadDefaultUrlManually(function(obj)
			if IsNil(obj) then
				return
			end

			self:findPanelInfoUContainerObjects()

			if self.panelInfoUContainerData then
				self:refreshInfo(self.panelInfoUContainerData)

				self.panelInfoUContainerData = nil
			end

			loadFinishCb()
		end)
	else
		loadFinishCb()
	end

	self:refreshGotoCultivateUIBtnsActive()
end

function DetailComponent:refreshPetInfoDetail(data, force)
	if not data or data.empty or data.isEmpty then
		self.rightPanelUComponent:TryChangePage("tabInfo", 3)
		self.rightPanelUComponent:TryChangePage("Inherit", 0)

		return
	end

	self.petId = data.id
	self.iconName = data.iconName
	self.label = data.label
	self.shinyStyle = data.shinyStyle
	self.bodySizeType = data.bodySizeType
	self.templateId = data.templateId

	if self.btnFavoriteUButton then
		PetManagementUtils.setRenderFavoriteToolTips(self.btnFavoriteUButton, self.petId)
	end

	if self.panelAbilityUContainer:CheckURLLoaded() then
		self:renderPetInfoCard(data)
		self:setTotalAttribute(data.id)
		self:previewMaxLevel()
		self:refreshGiftList(data)
		self:refreshStarUpContainer(data)
	else
		self.panelAbilityUContainerData = data
	end

	if self.panelSkillUContainer:CheckURLLoaded() then
		self:setCarryItem(data.id)
		self:setFeature(data.id)
		self:refreshSkillList(data.id)
	else
		self.panelSkillUContainerData = data
	end

	if self.panelInfoUContainer:CheckURLLoaded() then
		self:refreshInfo(data, force)
	else
		self.panelInfoUContainerData = data
	end

	self:refreshSwitchPetInfoToPages(self.prePageIdx or 0)

	local TimerManager = require("Core.Timer.TimerManager")

	TimerManager.addNextFrameCb(function()
		self:refreshGotoCultivateUIBtnsActive()
	end)
end

function DetailComponent:renderPetInfoCard(data)
	self.petNameStr = self.model:getPetName(self.petId)

	local templateId = data.templateId

	if pg.game.setting:getShowDebugId() then
		self.petNameStr = self.petNameStr .. tostring(templateId)
	end

	self:refreshPetName(self.petNameStr)

	function self.petElementUList.luaRenderItem(button, _, data1)
		LuaUIUtils.setElementButtonNew(button, data1.element, true, data.templateId)
	end

	self.petElementUList:SetList(data.elementNames)

	local pet = pg.me:getPetInfo(self.petId)

	if pet:isCatchReporting() then
		ClientTextUtils.setText(self.numCPUText, ClientTextUtils.concatByLanguage(pg.getGameString("CP"), "???"))
	else
		ClientTextUtils.setText(self.numCPUText, ClientTextUtils.concatByLanguage(pg.getGameString("CP"), data.cp))
	end

	LuaUIUtils.renderPetCharList(self.listExploreAbilityUList, templateId)

	if data.gender == Const.GENDER_TYPE_MALE then
		self.rightPanelUComponent:TryChangePage("Gender", 0)
	elseif data.gender == Const.GENDER_TYPE_FEMALE then
		self.rightPanelUComponent:TryChangePage("Gender", 1)
	else
		self.rightPanelUComponent:TryChangePage("Gender", 2)
	end

	ClientTextUtils.setText(self.numLevelUText, data.level)

	local maxExp = PetLevelData[data.level + 1] ~= nil and PetLevelData[data.level + 1].needExp or 0

	self.expSlider.value = maxExp == 0 and 1 or data.exp / maxExp

	local tagDatas = LuaUIUtils.getPetTagList(data)

	self.listTagUList:SetList(tagDatas)

	if data.isVariant then
		self.title:TryChangePage("isChange", 1)
	else
		self.title:TryChangePage("isChange", 0)
	end

	local petType = PetData[self.templateId].functionId

	self.typeImage.url = PetConfigData.petFunctionIcon[petType]

	ClientTextUtils.setText(self.typeDesc, pg.getLocalizationText(PetConfigData[string.format("petFunctionText%s", petType)]) or "")
	self:refreshVariantPetNameTips(data)
end

function DetailComponent:refreshVariantPetNameTips(data)
	local isVariant = data.isVariantInteractPet == true

	self.btnRenameUButton:SetActive(false)

	if self.virtualRenameBtnUButton then
		self.virtualRenameBtnUButton:SetActive(false)
	end

	LuaUIUtils.bindVariantPetDetailButton(self.btnIsChangeUButton, self.isChangeTipsUWidget, data, function()
		self:onVariantPetNameClick()
	end)

	local tipsShown = pg.me:getPetVariantTipsShown()
	local keepTips = self.variantTipsPetId == data.id and self.isVariantTipsVisible == true
	local showTips = isVariant and (keepTips or not tipsShown)

	self.variantTipsPetId = data.id
	self.isVariantTipsVisible = showTips

	self.isChangeTipsUWidget:SetActive(showTips)

	if showTips and not tipsShown then
		pg.me:setPetVariantTipsShown(true)
	end
end

function DetailComponent:onVariantPetNameClick()
	self.isVariantTipsVisible = false

	self.isChangeTipsUWidget:SetActive(false)
end

function DetailComponent:onPetIntimacyChanged(info)
	if not info or info.petId ~= self.petId then
		return
	end

	if self.panelInfoUContainer:CheckURLLoaded() and self.panelInfoUContainerObjectReference then
		self:refreshOperationList()

		local petInfo = self.model:getSinglePetInfo(self.petId)

		if petInfo and not petInfo.empty and not petInfo.isEmpty then
			petInfo.fetter = info.intimacy

			LuaUIUtils.refreshPetIntimacy(self.panelInfoUContainerObjectReference, petInfo)
		end
	end
end

function DetailComponent:setTotalAttribute(petId)
	if not self.propCmpGroup then
		return
	end

	local petInfo = pg.me:getPetInfo(petId)

	if petInfo == nil then
		return
	end

	local baseProperty = petInfo.basePropertyList
	local propertyEnhanced = Utils.isPetPropertyEnhanced(petInfo)
	local templateId = petInfo.templateId
	local petData = PetData[templateId]
	local recommend = petData.recommend_attr
	local propLevels = pg.game.petManage:getPetPropLevels(petInfo)

	self.defaultRatioGroup = {}
	self.addedRatioGroup = {}

	local isTrained = 0

	self.ctrl.recordCurPetPropData = {}

	for i = Const.BASE_PROPERTY_HP_IDX, Const.BASE_PROPERTY_ATK_MAG_IDX do
		local propLevel = propLevels[i]
		local baseAndActiveTotalLv = propLevel and propLevel.baseAndActiveTotalLv or 0
		local complexBaseLv = propLevel and propLevel.complexBaseLv or 0
		local learnt = propLevel and propLevel.learnt or 0
		local max = propLevel and propLevel.max or 1
		local val = math.ceil(propLevel.propDisplayVal)
		local bindNumUI = self.sixPropUIBinds[i].num

		ClientTextUtils.setText(bindNumUI, val)

		self.ctrl.recordCurPetPropData[i] = val

		ClientTextUtils.setText(self.propLevelGroup[i], propLevel.baseAndActiveTotalLv)

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

		if learnt > 0 then
			self.propCmpGroup[i]:TryChangePage("State", 1)
			self.propLevelCmpGroup[i]:TryChangePage("State", 1)
		else
			self.propCmpGroup[i]:TryChangePage("State", 0)
			self.propLevelCmpGroup[i]:TryChangePage("State", 0)
		end

		if LuaUIUtils.tableContains(recommend, i) then
			self.propCmpGroup[i]:TryChangePage("GoodState", 1)
		else
			self.propCmpGroup[i]:TryChangePage("GoodState", 0)
		end

		self.propLevelCmpGroup[i]:TryChangePage("Updated", propertyEnhanced and 1 or 0)

		if propertyEnhanced then
			self.propLevelCmpGroup[i]:TryChangePage("State", 1)
		end

		if max <= baseAndActiveTotalLv then
			self.propCmpGroup[i]:TryChangePage("State", 2)
			self.propLevelCmpGroup[i]:TryChangePage("State", 2)
		end

		self.defaultRatioGroup[i] = complexBaseLv / max
		self.addedRatioGroup[i] = baseAndActiveTotalLv / max

		if learnt > 0 then
			isTrained = isTrained + 1
		end
	end

	self.defaultRadar:SetSixProps(self.defaultRatioGroup[Const.BASE_PROPERTY_HP_IDX], self.defaultRatioGroup[Const.BASE_PROPERTY_ATK_IDX], self.defaultRatioGroup[Const.BASE_PROPERTY_DEF_IDX], self.defaultRatioGroup[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX], self.defaultRatioGroup[Const.BASE_PROPERTY_DEF_MAG_IDX], self.defaultRatioGroup[Const.BASE_PROPERTY_ATK_MAG_IDX])
	self.addedRadar:SetSixProps(self.addedRatioGroup[Const.BASE_PROPERTY_HP_IDX], self.addedRatioGroup[Const.BASE_PROPERTY_ATK_IDX], self.addedRatioGroup[Const.BASE_PROPERTY_DEF_IDX], self.addedRatioGroup[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX], self.addedRatioGroup[Const.BASE_PROPERTY_DEF_MAG_IDX], self.addedRatioGroup[Const.BASE_PROPERTY_ATK_MAG_IDX])
	self.addedRadar.transform.gameObject:SetActiveEx(isTrained > 0)
	self:ratioAttribute(petInfo)

	local featureInfo, _ = self.model:getCurCharacter(petId)

	if featureInfo then
		self.btnTalentUButton:SetActive(true)

		if featureInfo.rare and featureInfo.rare == 1 then
			self.btnRareTraitUButton:TryChangePage("Rare", 1)
		else
			self.btnRareTraitUButton:TryChangePage("Rare", 0)
		end

		LuaUIUtils.setRenderFeatureToolTips(self.btnRareTraitUButton, featureInfo, petInfo)

		self.featureIcon.url = featureInfo.icon
	else
		self.btnTalentUButton:SetActive(false)
	end
end

function DetailComponent:ratioAttribute(pet)
	local pageIndex, ratingStr = pet:getPropRatingResult()

	if pet:isCatchReporting() then
		self.root:TryChangePage("NotVerified", 1)
	else
		self.root:TryChangePage("NotVerified", 0)
	end

	PetManagementUtils.setPetRatioUINode(pet, self.newRatioNodeUComp)
end

function DetailComponent:onClickFavoriteBtn()
	return
end

function DetailComponent:resetBtnState(data)
	self:m_newRefreshBtnState(data)
end

function DetailComponent:refreshCanEvolve(canEvolve)
	self.btnEvolutionUButton:TryChangePage("CanEvolution", canEvolve and 1 or 0)
end

function DetailComponent:refreshEvolveRedDot()
	if not self.petId or not self.templateId then
		return
	end

	local petInfo = pg.me:getPetInfo(self.petId)

	if not petInfo or not next(petInfo) then
		return
	end

	local evoStatusInfo = {}
	local evolveStatus = petInfo:getEvolveBranchesStatus(evoStatusInfo)

	if evolveStatus == UIConst.EvolveStatus.CAN_EVOLVE_FIRST and evoStatusInfo.branchId then
		local isNewEvo = self.model:redDot_GetPetEvoNewState(self.templateId, evoStatusInfo.branchId)

		self.model:redDot_SetPetEvoNewRedDot(self.templateId, evoStatusInfo.branchId, self.btnEvolutionUButton, isNewEvo)
	else
		self.model:redDot_SetPetEvoNewRedDot(self.templateId, EMPTY_EVO_BRANCH_ID, self.btnEvolutionUButton, false)
	end
end

function DetailComponent:refreshCanBreakThrough(needBreakthrough)
	self.btnLvUp:TryChangePage("CanBreakthrough", 0)
end

function DetailComponent:previewMaxLevel(needModify)
	local pet = pg.me:getPetInfo(self.petId)

	if pet == nil then
		return
	end

	if needModify then
		self.previewed = not self.previewed
	end

	self.root:TryChangePage("MaxLevel", self.previewed and 1 or 0)
	self.addedRadar.transform.gameObject:SetActiveEx(true)

	if self.previewed then
		Utils.genBasePropertyPreview(pet, Const.PROP_PREVIEW_MAX_LEVEL, {}, function(result)
			local addedRatioGroup = {}

			for i = Const.BASE_PROPERTY_HP_IDX, Const.BASE_PROPERTY_ATK_MAG_IDX do
				ClientTextUtils.setText(self.propNumGroup[i], result[i].displayValue)
				ClientTextUtils.setText(self.propLevelGroup[i], result[i].indLv)

				if result[i].iLvLn > 0 then
					self.propCmpGroup[i]:TryChangePage("State", 1)
					self.propLevelCmpGroup[i]:TryChangePage("State", 1)
				else
					self.propCmpGroup[i]:TryChangePage("State", 0)
					self.propLevelCmpGroup[i]:TryChangePage("State", 0)
				end

				if result[i].indLv >= PetPropLevelMaxData[i] then
					self.propCmpGroup[i]:TryChangePage("State", 2)
					self.propLevelCmpGroup[i]:TryChangePage("State", 2)
				end

				addedRatioGroup[i] = result[i].indLv / PetPropLevelMaxData[i]
			end

			self.addedRadar:SetSixProps(addedRatioGroup[Const.BASE_PROPERTY_HP_IDX], addedRatioGroup[Const.BASE_PROPERTY_ATK_IDX], addedRatioGroup[Const.BASE_PROPERTY_DEF_IDX], addedRatioGroup[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX], addedRatioGroup[Const.BASE_PROPERTY_DEF_MAG_IDX], addedRatioGroup[Const.BASE_PROPERTY_ATK_MAG_IDX])
		end)
	else
		self:setTotalAttribute(self.petId)
	end
end

function DetailComponent:showSkillLearnPop(petId)
	PetManagementUtils.onEvolveClick(petId, self.templateId, {
		toPage = Const.PetCulPageIndex2Name[Const.PetCulPages.SKILL]
	})
end

function DetailComponent:onInputDeviceChanged()
	if pg.game.input:isUsingGamepad() then
		if self.btnRenameUButton then
			self.btnRenameUButton.renderOpacity = 0.01
		end
	elseif self.btnRenameUButton then
		self.btnRenameUButton.renderOpacity = 1
	end
end

function DetailComponent:onCultivateClick(petId)
	PetManagementUtils.onEvolveClick(petId, self.templateId, {
		toPage = Const.PetCulPageIndex2Name[Const.PetCulPages.STARUP]
	})
end

function DetailComponent:openEvolution()
	local researchContentData = PetResearchContentData[self.templateId]

	if not researchContentData then
		pg.global.showBubbleMessageRaw(pg.getGameString("TRAINING_NOT_VALID"))

		return
	end

	local canEvolve = PetEvolveData[self.templateId] and PetEvolveData[self.templateId][1] and PetEvolveData[self.templateId][1].targetPetId

	if not canEvolve then
		pg.global.showBubbleMessageRaw(pg.getGameString("CURRENT_PET_CANT_EVOLUTION"), 2)

		return
	end

	pg.global.ui.petEvolution:open({
		petId = self.petId
	})
end

function DetailComponent:onPetLvUpClick()
	PetManagementUtils.onPetLvUpClick(self.petId, self.iconName, self.label, Utils.canLevelBreakthrough(self.petId))
end

function DetailComponent:refreshPetName(petName)
	ClientTextUtils.setText(self.petNameUText, petName)
	ClientTextUtils.setText(self.name01USDFText, petName)
	ClientTextUtils.setText(self.nameShineUSDFText, petName)
end

function DetailComponent:refreshGiftList(data)
	function self.btnTalentUButton.luaClick()
		local talentData = {}

		talentData.targetRect = self.btnTalentUButton
		talentData.autoHor = true
		talentData.type = UIConst.GIFT_TYPE.BATTLE
		talentData.showType = UIConst.GIFT_SHOW_TYPE.GIFT
		talentData.giftType = UIConst.GIFT_TYPE.HOME
		talentData.breedTalent = data.breedTalent
		talentData.petId = self.petId
		talentData.extra = {
			openFun = function()
				self.btnTalentUButton.isSelected = true

				self.btnTalentUButton:TryChangePage("button", 5)
			end,
			closeFun = function()
				self.btnTalentUButton.isSelected = false

				self.btnTalentUButton:TryChangePage("button", 0)
			end
		}

		pg.global.ui:open(UIConst.UI_ID_PET_GIFT_TIPS, talentData)
	end

	function self.accessListUList.luaRenderItem(button, _, data1)
		if data1.empty then
			return
		end

		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local rayBoxUWidget = objectReference:GetRefValue("rayBoxUWidget")

		iconUImage.url = data1.icon

		rayBoxUWidget.gameObject:SetActiveEx(false)
		button:TryChangePage("Quality", data1.quality)
	end

	self.accessListUList:SetList(data.breedTalent)
end

function DetailComponent:refreshOnCarryLockChange(isLocked)
	if self.m_petCarryInfoComp then
		self.m_petCarryInfoComp:refreshCarryItemTooltip()
	end
end

function DetailComponent:setCarryItem(petId, forbidToolTip)
	if IsNil(self.carryItemUComponent) then
		return
	end

	if self.m_petCarryInfoComp and self.m_petCarryInfoComp.carryItemUComponent ~= self.carryItemUComponent then
		self.m_petCarryInfoComp:onDestroy()

		self.m_petCarryInfoComp = nil
	end

	if not self.m_petCarryInfoComp then
		self.m_petCarryInfoComp = PetCardCarryInfoComponent.new(self.carryItemUComponent)
	end

	self.m_petCarryInfoComp:updateAndRefresh(petId, {
		forbidToolTip = forbidToolTip
	})
end

function DetailComponent:setFeature(petId)
	local featureInfo, featureId = self.model:getCurCharacter(petId)

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

function DetailComponent:refreshSkillList(petId)
	if not self.btnUniqueSkillUButton then
		return
	end

	local ultSkillInfo = self.model:getPetSkillInfos(petId, AbilityConst.ULTIMATE_ABILITY)
	local qSkillInfo = self.model:getPetSkillInfos(petId, AbilityConst.WEAPON_SKILL_ABILITY)
	local eSkillInfo = self.model:getPetSkillInfos(petId, AbilityConst.WEAPON_SKILL_ABILITY2)
	local exploreSkillInfo = self.model:getPetSkillInfos(petId, AbilityConst.EXPLORE_ABILITY)

	self.petInfo = pg.me:getPetInfo(petId)

	self:renderSkillCmp(self.btnUniqueSkillUButton, ultSkillInfo, true)
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

function DetailComponent:renderSkillCmp(button, data, isUniqueSkillType)
	local isSuccess = LuaUIUtils.renderSkillCmpCommon(button, data, nil, nil, nil, self.petInfo)
	local isEmpty = not isSuccess

	if isUniqueSkillType then
		self.uniqueUWidget:SetActive(false)
	else
		self.uniqueUWidget:SetActive(not isEmpty)
	end

	function button.luaHover()
		self.ctrl:setConsoleBarState(self.ctrl.CONSOLE_BAR_STATE.IN_EMPTY_SKILL, isEmpty)
	end

	function button.luaUnhover()
		self.ctrl:setConsoleBarState(self.ctrl.CONSOLE_BAR_STATE.IN_EMPTY_SKILL, false)
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

function DetailComponent:renderExploreSkillCmp(button, data)
	if not data then
		button.enabledTooltip = false
		button.luaHover = nil
		button.luaUnhover = nil
		button.luaTooltipPopup = nil

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

	function button.luaHover()
		self.ctrl:setConsoleBarState(self.ctrl.CONSOLE_BAR_STATE.IN_EMPTY_SKILL, isEmpty)
	end

	function button.luaUnhover()
		self.ctrl:setConsoleBarState(self.ctrl.CONSOLE_BAR_STATE.IN_EMPTY_SKILL, false)
	end

	button:TryChangePage("State", 1)

	iconNormalUImage.url = LuaUIUtils.getSkillIcon(data.icon)

	ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.name))

	button.enabledTooltip = true

	function button.luaTooltipPopup(_, flag)
		button:TryChangePage("Selected", flag and 1 or 0)
	end

	LuaUIUtils.setRenderExploreToolTips(button, data)
end

function DetailComponent:refreshInfo(data, force)
	ClientTextUtils.setText(self.petDesc.content, PetResearchContentData[data.templateId] ~= nil and pg.getLocalizationText(PetResearchContentData[data.templateId].desc) or "EMPTY")
	ClientTextUtils.setText(self.txtDetailUSDFText, PetResearchContentData[data.templateId] ~= nil and pg.getLocalizationText(PetResearchContentData[data.templateId].desc) or "EMPTY")
	ClientTextUtils.setText(self.beenText, pg.getFormatText(pg.getGameString("BEEN_WITH"), math.round((Time.secondCache * 1000 - data.time) / 1000 / 3600 / 24)))
	ClientTextUtils.setText(self.textUSDFText, PetManagementUtils.getDisplayBookNumberText(data))
	ClientTextUtils.setText(self.txtNumLiveUSDFText, ClientHomelandUtils.getPetComfortValueById(data.id))
	ClientTextUtils.setText(self.txtTitleLiveUSDFText, pg.getGameString("HOMELAND_COMPOSE_LIVE_VALUE") .. ":")

	function self.btnLiveUButton.luaRenderTooltip(btn, com)
		local objectReference = com.transform:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("HOMELAND_COMFORT_TIP"))
	end

	LuaUIUtils.bindHomeWishingStarOutput(self.panelInfoUContainerObjectReference, data)

	local petCubeItemId = data and data.cubeItemId

	LuaUIUtils.refreshPetPanelInfoCubeAndBackground(petCubeItemId, self.panelInfoUContainerObjectReference)

	local formName = LuaUIUtils.getPetFormName(data.templateId)

	ClientTextUtils.setText(self.infoPetName, formName or "")
	self:refreshOperationList()

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

function DetailComponent:onHomelandWishStarChanged()
	if not self.petId or not self.model or self.model.curSelectPetId ~= self.petId or not self.panelInfoUContainer or not self.panelInfoUContainer:CheckURLLoaded() or not self.panelInfoUContainerObjectReference then
		return
	end

	local petInfo = self.model:getSinglePetInfo(self.petId)

	if petInfo and not petInfo.empty and not petInfo.isEmpty then
		LuaUIUtils.refreshHomeWishingStarOutput(self.panelInfoUContainerObjectReference, petInfo)
	end
end

function DetailComponent:refreshSource(data)
	local source = PetManagementDataHelper.getPetSource(data.id)
	local showSource = source ~= nil and source ~= ""

	self.sourceUWidget:SetActive(showSource)

	if showSource then
		local playerName = ""
		local playerInfo = pg.game.chat:getPlayerInfo(source)

		if playerInfo then
			playerName = playerInfo.playerName or ""
		end

		local _h = DetailComponent._platformHooks

		playerName = _h and _h.refreshSourcePlayerName and _h.refreshSourcePlayerName(self, data, source, playerName, playerInfo) or playerName

		local tip = string.gsub(pg.getGameString("PET_EXCHANGE_SOURCE"), "{0}", playerName)

		ClientTextUtils.setText(self.txtSourceUBaseText, tip)
	end
end

function DetailComponent:refreshGiftInfoList(data)
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

function DetailComponent:getHomeAbilityData()
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

function DetailComponent:openPetAccessory()
	LuaUIUtils.openPetAppearancePanel(self.petId, function()
		self:tryRefreshPetPreview(true)
	end)
end

function DetailComponent:openTransmogPanel()
	if not pg.me:isFunctionAndSwitchEnable("Pet_Transmog", true) then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_PET_TRANSMOG, {
		curPetId = self.petId
	})
end

function DetailComponent:openPropertyPanel()
	pg.global.ui:open(UIConst.UI_ID_PET_PROPERTY, {
		curPetId = self.petId
	})
end

function DetailComponent:onClickSkillPresetsButton()
	pg.global.ui:open(UIConst.UI_ID_PET_SKILL_REPLACE_QUICK, {
		curPetId = self.petId,
		templateId = self.templateId
	})
end

function DetailComponent:openPetCarryPanel()
	if pg.me:isFunctionAndSwitchEnable(FunctionEnum.PETEQUIPMENT, true) then
		PetManagementUtils.onEvolveClick(self.petId, self.templateId, {
			toPage = Const.PetCulPageIndex2Name[Const.PetCulPages.CARRY]
		})
	end
end

function DetailComponent:openPetChangeFormPanel()
	local pet = pg.me:getPetInfo(self.petId)
	local isMagic = Utils.isLabelMagic(pet.label)
	local targetTemplateId = Utils.getPetChangeTargetId(pg.me, self.templateId, isMagic)

	if targetTemplateId then
		local petInfo = PetManagementDataHelper.setUpPetInfo(pet)
		local needItemId = PetFormChangeData[targetTemplateId] and PetFormChangeData[targetTemplateId].needItem[1]

		pg.global.ui:open(UIConst.UI_ID_PET_CHANGE_FORM_SMALL, {
			withPetList = false,
			itemId = needItemId,
			petInfo = petInfo,
			targetTemplateId = targetTemplateId
		})
	end
end

function DetailComponent:showRightPanel(show)
	self.rightPanelUComponent.renderOpacity = show and 1 or 0
end

function DetailComponent:refreshStarUpContainer(data)
	self:m_refreshStarUpContainer(self.petId, self, self.starUContainer)
end

function DetailComponent:m_refreshStarUpContainer(petId, uiObj, starUContainer)
	if not petId or not uiObj or not starUContainer then
		return
	end

	local curResonanceInfo = PetManagementUtils.getPetStarUpInfo(petId)
	local stage = curResonanceInfo.resonanceStage or 0
	local level = curResonanceInfo.resonanceLevel or 0
	local curStageStarUrl = PetManagementUtils.getStarItemUrl(stage, true)

	starUContainer:SetUrlWithCallback(curStageStarUrl, function()
		if not petId or not uiObj then
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

function DetailComponent:m_newRefreshBtnState(data)
	if self.btnFavoriteUButton then
		PetManagementUtils.refreshFavoriteBtn(self.btnFavoriteUButton, data.favoriteType)
	end

	if not self.petId then
		self.btnEvolutionUButton:SetActive(false)

		return
	end

	local petInfo = pg.me:getPetInfo(self.petId)

	if not petInfo then
		self.btnEvolutionUButton:SetActive(false)

		return
	end

	if not self.prePageIdx or self.prePageIdx == 0 then
		local canEvolveConfig = PetEvolveData[self.templateId] and PetEvolveData[self.templateId][1] and PetEvolveData[self.templateId][1].targetPetId

		self:refreshCanEvolve(data.canEvolve)
		self:refreshCanBreakThrough(data.needBreakthrough)

		self.btnEvoImgArrowUImage.url = data.canEvolve and AddressDataConst.CAN_EVOLUTION_ARROW or AddressDataConst.CANT_EVOLUTION_ARROW

		local evoStatusInfo = {}
		local evolveStatus = petInfo and petInfo:getEvolveBranchesStatus(evoStatusInfo) or UIConst.EvolveStatus.CANNOT_EVOLVE
		local showEvoBtn = canEvolveConfig and 0 or 1

		self.panelControlUComponent:TryChangePage("Evolution", showEvoBtn)

		if canEvolveConfig then
			self.btnEvolutionUButton:TryChangePage("CanEvolution", evolveStatus)

			if showEvoBtn then
				self:refreshEvolveRedDot()
			end
		end
	else
		self.btnEvolutionUButton:SetActive(false)
		self.panelControlUComponent:TryChangePage("Evolution", 1)
	end
end

function DetailComponent:m_trySetRedDotEvoNew()
	if not self.petId or not self.templateId then
		return
	end

	local petInfo = pg.me:getPetInfo(self.petId)

	if not petInfo or not next(petInfo) then
		return
	end

	local canEvolveConfig = PetEvolveData[self.templateId] and PetEvolveData[self.templateId][1] and PetEvolveData[self.templateId][1].targetPetId

	if not canEvolveConfig then
		return
	end

	local evoStatusInfo = {}
	local evolveStatus = petInfo and petInfo:getEvolveBranchesStatus(evoStatusInfo) or UIConst.EvolveStatus.CANNOT_EVOLVE

	if evolveStatus == UIConst.EvolveStatus.CAN_EVOLVE_FIRST and evoStatusInfo.branchId then
		self.model:redDot_RecordPetEvoNewState(self.templateId, evoStatusInfo.branchId)
	end
end

function DetailComponent:openPetInheritPanel()
	local canInherit, errType = pg.game.petManage:checkInheritSourcePetLegal(pg.me, self.petId)

	if not canInherit then
		local errNoticeId = pg.game.petManage:getErrNoticeId(errType)

		if errNoticeId then
			pg.global.showBubbleMessageById(errNoticeId)
		end

		return
	end

	pg.game.petManage:resetInheritDataModel()
	pg.game.petManage:setInheritSourcePetId(self.petId)
	self.ctrl:pauseUIScene()
	pg.global.ui:open(UIConst.UI_ID_PET_INHERITANCE_MAIN, {
		petId = self.petId
	})
end

function DetailComponent:onDestroy()
	if self.m_petCarryInfoComp then
		self.m_petCarryInfoComp:onDestroy()

		self.m_petCarryInfoComp = nil
	end
end

function DetailComponent:refreshGotoCultivateUIBtnsActive()
	local isStarupOpen = LuaUIUtils.getIsCultivateSubCompUnLocked(Const.PetCulPageNames.STARUP)

	self.btnCultivateUButton:SetActive(isStarupOpen)

	local isCarryOpen = LuaUIUtils.getIsCultivateSubCompUnLocked(Const.PetCulPageNames.CARRY)

	self.btnCarry:SetActive(isCarryOpen)
end

return DetailComponent
