-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\PetManagementUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local TimeUtils = require("Common.Utils.TimeUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("PetManagementUtils")
local Const = require("Common.Const.Const")
local lume = require("Core.Common.lume")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local PetLevelData = require("Data.pet_level_data")
local PetData = require("Data.pet_data")
local PetConfigData = require("Data.pet_config_data")
local PetDetailPropertyData = require("Data.pet_detail_property_data")
local PetPropLevelMaxData = require("Data.pet_prop_level_max")
local Utils = require("Common.Utils.Utils")
local AbilityConst = require("Common.Const.AbilityConst")
local TimerManager = require("Core.Timer.TimerManager")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local PetResearchContentData = require("Data.pet_research_content_data")
local Time = require("Core.Common.Time")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local MessageName = require("Const.MessageName")
local SkillTagData = require("Data.skill_tag_data")
local AddressDataConst = require("Const.AddressDataConst")
local Lume = require("Core.Common.lume")
local ClientConst = require("Const.ClientConst")
local PetAttrConvertData = require("Data.pet_attr_convert_data")
local AttributeConst = require("Common.Const.AttributeConst")
local CoreCarryData = require("Data.core_carry_data")
local AttributeGroupData = require("Data.attribute_group_data")
local PriProConst = require("Common.Const.PrimaryPropertyConst")
local PetDisplayAttrNames = require("Data.pet_display_attr_names")
local PetAttributeCalcUtils = require("Common.Utils.PetAttributeCalcUtils")
local ResonanceData = require("Data.pet_resonance_data")
local FormulaData = require("Data.formula_data")
local NoticeDef = require("Common.NoticeDef")
local PetFamilyData = require("Data.pet_family_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local HomeCampUtils = require("Utils.HomeCampUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local PriProRevertData = require("Data.primaryproperty_revert_data")
local UICtrl = require("Guis.UICtrl")
local ClientUtils = require("Utils.ClientUtils")
local RecommendData = require("Data.pet_strength_recommend_data")
local CommonPetGroupData = require("Data.common_pet_group_data")
local RecommendPetData = require("Data.recommend_pet_data")
local PlayerHeadIconData = require("Data.player_head_icon_data")
local ItemUseChecker = require("Guis.Panels.Inventory.Helper.ItemUseChecker")
local CaptureUtils = require("Common.Utils.CaptureUtils")
local PetRenameValidator = require("Utils.PetRenameValidator")
local ClientHomelandUtils = require("Utils.ClientHomelandUtils")
local PetManagementUtils = {}

function PetManagementUtils.getDisplayBookNumberText(data)
	if not data or not data.bookNum or data.bookNum >= 9000 then
		return "No.???"
	end

	local displayNumber, isCustomNumber = PetResearchUtils.getDisplayNumberByTemplateId(data.templateId)

	displayNumber = displayNumber ~= "" and displayNumber or data.bookNum

	return isCustomNumber and displayNumber or string.format("No.%s", displayNumber)
end

local string_format = string.format
local math_floor = math.floor

function PetManagementUtils._setContextOwner(owner)
	PetManagementUtils.contextOwner = owner
end

function PetManagementUtils.isContextOwner(owner)
	if owner == nil then
		return true
	end

	return PetManagementUtils.contextOwner == owner
end

function PetManagementUtils.initTemplate(infoPanelTrans, midPanelTrans, param)
	PetManagementUtils.subDisplayType = UIConst.PET_SLOT_SUB_DISPLAY_TYPE.Normal
	PetManagementUtils.param = param

	PetManagementUtils._setContextOwner(param and param.owner or nil)
	PetManagementUtils._dealPreProcess()
	PetManagementUtils._renderInfoPanel(infoPanelTrans)
	PetManagementUtils._renderMidPanel(midPanelTrans)

	if PetManagementUtils.param.uiScene then
		PetManagementUtils.petManagementSceneCtrl = PetManagementUtils.param.uiScene

		PetManagementUtils._previewSceneProcess()
	end
end

function PetManagementUtils.initSimpleMidTemplate(midPanelTrans, param, isForbidAutoSelected, subDisplayType)
	PetManagementUtils.subDisplayType = subDisplayType or UIConst.PET_SLOT_SUB_DISPLAY_TYPE.Normal

	if isForbidAutoSelected then
		PetManagementUtils.selectSlot = nil
	end

	PetManagementUtils.onlyRenderMidPanel = true
	PetManagementUtils.param = param

	PetManagementUtils._setContextOwner(param and param.owner or nil)
	PetManagementUtils._dealPreProcess()
	PetManagementUtils._renderMidPanel(midPanelTrans)
end

function PetManagementUtils.initSimpleInfoTemplate(infoPanelTrans, param)
	PetManagementUtils.subDisplayType = UIConst.PET_SLOT_SUB_DISPLAY_TYPE.Normal
	PetManagementUtils.param = param

	PetManagementUtils._setContextOwner(param and param.owner or nil)
	PetManagementUtils._renderInfoPanel(infoPanelTrans)

	if PetManagementUtils.param.uiScene then
		PetManagementUtils.petManagementSceneCtrl = PetManagementUtils.param.uiScene

		PetManagementUtils._previewSceneProcess()
	end
end

function PetManagementUtils.showPetInfo(petInfo)
	PetManagementUtils._refreshPetInfoDetail(petInfo)
end

function PetManagementUtils._innerDestroy()
	for key, value in pairs(PetManagementUtils) do
		if type(value) ~= "function" then
			PetManagementUtils[key] = nil
		end
	end

	PetManagementUtils.onFilterListRenderFinished = nil
	PetManagementUtils.onNormalListRenderFinished = nil
	PetManagementUtils.onPetInfoPageChange = nil

	if PetManagementUtils.homeOpenTimerId then
		TimerManager.removeTimer(PetManagementUtils.homeOpenTimerId)
	end

	for _, timer in pairs(PetManagementUtils.m_filterTimers or EMPTY_TABLE) do
		if timer then
			TimerManager.removeTimer(timer)
		end
	end

	PetManagementUtils.m_filterTimers = nil

	PetManagementUtils.clearPetAttributeTimer()
end

function PetManagementUtils.destroyTemplate(owner)
	if owner ~= nil and not PetManagementUtils.isContextOwner(owner) then
		return false
	end

	PetManagementUtils._innerDestroy()

	PetResearchUtils.inDetailLoading = nil

	return true
end

function PetManagementUtils.initMsg(ctrl)
	if not ctrl.messages then
		ctrl.messages = {}
	end

	function ctrl:refreshPetBox(info)
		PetManagementUtils._refreshPetList()
		PetManagementUtils._refreshBoxSelector()
	end

	function ctrl:onPetCustomNameChanged(info)
		local petId = info.petId

		if petId == PetManagementUtils.petId then
			local name = PetManagementDataHelper.getPetName(petId)

			PetManagementUtils._refreshPetName(name)
		end
	end

	function ctrl:onBoxNameChanged(info)
		PetManagementUtils._refreshBoxSelector()
		PetManagementUtils._refreshSingleBoxSelectorItemName(info.index, info.newName)
	end

	function ctrl:onPetFavoriteChanged(info)
		TimerManager.addNextFrameCb(function()
			PetManagementUtils._resetBtnState()
			PetManagementUtils._refreshSingleCardFavoriteState(info[1], info[2])
			PetManagementUtils.refreshPetList()
		end)
	end

	function ctrl:onPetFavoriteTypeChanged(info)
		TimerManager.addNextFrameCb(function()
			local petId = info[1]
			local favoriteType = info[2] or 0

			PetManagementUtils._resetBtnState()
			PetManagementUtils._refreshSingleCardFavoriteState(petId, favoriteType > 0)
			PetManagementUtils.refreshPetList()

			local petInfo = pg.me:getPetInfo(petId)

			if petInfo then
				PetManagementUtils.onPetFavoriteChanged(petInfo)
			end
		end)
	end

	function ctrl:onPetCurAbilityChanged(info)
		local petId = info.petId

		if petId == PetManagementUtils.petId then
			PetManagementUtils._refreshSkillList(petId)
		end
	end

	function ctrl:event_CarryEquipped(info)
		PetManagementUtils._setCarryItem(info.petId)
	end

	function ctrl:event_CarryUnload(info)
		PetManagementUtils._setCarryItem(info.petId)
	end

	function ctrl.onPetTagAnimRecordUpdate()
		if PetManagementUtils.currentPetInfoData then
			PetManagementUtils._refreshPetTagList(PetManagementUtils.currentPetInfoData, true)
		end
	end

	function ctrl.onHomelandWishStarChanged()
		local petInfo = PetManagementUtils.currentPetInfoData

		if not petInfo or petInfo.id ~= PetManagementUtils.petId or not PetManagementUtils.panelInfoUContainer or not PetManagementUtils.panelInfoUContainer:CheckURLLoaded() or not PetManagementUtils.panelInfoUContainerObjectReference then
			return
		end

		LuaUIUtils.refreshHomeWishingStarOutput(PetManagementUtils.panelInfoUContainerObjectReference, petInfo)
	end

	ctrl.messages[MessageName.PET_BOX_MAP_UPDATE] = {
		"refreshPetBox",
		true
	}
	ctrl.messages[MessageName.PET_CUSTOM_NAME_CHANGED] = {
		"onPetCustomNameChanged",
		true
	}
	ctrl.messages[MessageName.ON_BOX_NAME_CHANGE] = {
		"onBoxNameChanged",
		true
	}
	ctrl.messages[MessageName.PET_FAVORITE_CHANGE] = {
		"onPetFavoriteChanged",
		true
	}
	ctrl.messages[MessageName.PET_FAVORITE_TYPE_CHANGE] = {
		"onPetFavoriteTypeChanged",
		true
	}
	ctrl.messages[MessageName.PLAYER_PET_CUR_ABILITY_CHANGED] = {
		"onPetCurAbilityChanged",
		true
	}
	ctrl.messages[MessageName.CARRY_EQUIP] = {
		"event_CarryEquipped",
		true
	}
	ctrl.messages[MessageName.CARRY_UNLOAD] = {
		"event_CarryUnload",
		true
	}
	ctrl.messages[MessageName.PET_TAG_ANIM_RECORD_UPDATE] = {
		"onPetTagAnimRecordUpdate",
		true
	}
	ctrl.messages[MessageName.HOMELAND_WISH_STAR_CHANGED] = {
		"onHomelandWishStarChanged",
		true
	}
end

function PetManagementUtils._renderInfoPanel(infoPanelTrans)
	PetManagementUtils._findInfoPanelObjects(infoPanelTrans)
	PetManagementUtils._rebindLoadedContainerObjects()
	PetManagementUtils._initInfoPanelView()
end

function PetManagementUtils._rebindLoadedContainerObjects()
	if PetManagementUtils.panelAbilityUContainer:CheckURLLoaded() then
		PetManagementUtils._findPanelAbilityUContainerObjects()
	end

	if PetManagementUtils.panelSkillUContainer:CheckURLLoaded() then
		PetManagementUtils._findPanelSkillUContainerObjects()
	end

	if PetManagementUtils.panelInfoUContainer:CheckURLLoaded() then
		PetManagementUtils._findPanelInfoUContainerObjects()
	end
end

function PetManagementUtils._findInfoPanelObjects(infoPanelTrans)
	PetManagementUtils.objectReference = infoPanelTrans:GetComponent("ObjectReference")
	PetManagementUtils.attributeBtn = PetManagementUtils.objectReference:GetRefValue("attributeBtn")
	PetManagementUtils.skillBtn = PetManagementUtils.objectReference:GetRefValue("skillBtn")
	PetManagementUtils.infoBtn = PetManagementUtils.objectReference:GetRefValue("infoBtn")
	PetManagementUtils.rightPanelUComponent = PetManagementUtils.objectReference:GetRefValue("rightPanelUComponent")
	PetManagementUtils.panelAbilityUContainer = PetManagementUtils.objectReference:GetRefValue("panelAbilityUContainer")
	PetManagementUtils.panelSkillUContainer = PetManagementUtils.objectReference:GetRefValue("panelSkillUContainer")
	PetManagementUtils.panelInfoUContainer = PetManagementUtils.objectReference:GetRefValue("panelInfoUContainer")
	PetManagementUtils.previewed = nil
end

function PetManagementUtils._findPanelAbilityUContainerObjects()
	PetManagementUtils.panelAbilityUContainerObjectReference = PetManagementUtils.panelAbilityUContainer.content.transform:GetComponent("ObjectReference")
	PetManagementUtils.title = PetManagementUtils.panelAbilityUContainerObjectReference:GetRefValue("title")
	PetManagementUtils.detail = PetManagementUtils.panelAbilityUContainerObjectReference:GetRefValue("detail")
	PetManagementUtils.titleObjectReference = PetManagementUtils.title.transform:GetComponent("ObjectReference")
	PetManagementUtils.petNameUText = PetManagementUtils.titleObjectReference:GetRefValue("petNameUText")
	PetManagementUtils.name01USDFText = PetManagementUtils.titleObjectReference:GetRefValue("name01USDFText")
	PetManagementUtils.nameShineUSDFText = PetManagementUtils.titleObjectReference:GetRefValue("nameShineUSDFText")
	PetManagementUtils.petElementUList = PetManagementUtils.titleObjectReference:GetRefValue("petElementUList")
	PetManagementUtils.numCPUText = PetManagementUtils.titleObjectReference:GetRefValue("numCPUText")
	PetManagementUtils.btnRenameUButton = PetManagementUtils.titleObjectReference:GetRefValue("btnRenameUButton")
	PetManagementUtils.btnFavoriteUButton = PetManagementUtils.titleObjectReference:GetRefValue("btnFavoriteUButton")
	PetManagementUtils.numLevelUText = PetManagementUtils.titleObjectReference:GetRefValue("numLevelUText")
	PetManagementUtils.expSlider = PetManagementUtils.titleObjectReference:GetRefValue("expSlider")
	PetManagementUtils.typeImage = PetManagementUtils.titleObjectReference:GetRefValue("typeImage")
	PetManagementUtils.typeDesc = PetManagementUtils.titleObjectReference:GetRefValue("typeDesc")
	PetManagementUtils.listTagUList = PetManagementUtils.titleObjectReference:GetRefValue("listTagUList")
	PetManagementUtils.starUContainer = PetManagementUtils.titleObjectReference:GetRefValue("starUContainer")
	PetManagementUtils.detailObjectReference = PetManagementUtils.detail.transform:GetComponent("ObjectReference")
	PetManagementUtils.hpNum = PetManagementUtils.detailObjectReference:GetRefValue("hpNum")
	PetManagementUtils.atkNum = PetManagementUtils.detailObjectReference:GetRefValue("atkNum")
	PetManagementUtils.defNum = PetManagementUtils.detailObjectReference:GetRefValue("defNum")
	PetManagementUtils.regenNum = PetManagementUtils.detailObjectReference:GetRefValue("regenNum")
	PetManagementUtils.defMagNum = PetManagementUtils.detailObjectReference:GetRefValue("defMagNum")
	PetManagementUtils.atkMagNum = PetManagementUtils.detailObjectReference:GetRefValue("atkMagNum")
	PetManagementUtils.propNumGroup = {
		PetManagementUtils.hpNum,
		PetManagementUtils.atkNum,
		PetManagementUtils.defNum,
		PetManagementUtils.regenNum,
		PetManagementUtils.defMagNum,
		PetManagementUtils.atkMagNum
	}
	PetManagementUtils.propTitleGroup = {
		PetManagementUtils.detailObjectReference:GetRefValue("hpTitle"),
		PetManagementUtils.detailObjectReference:GetRefValue("atkTitle"),
		PetManagementUtils.detailObjectReference:GetRefValue("defTitle"),
		PetManagementUtils.detailObjectReference:GetRefValue("regenTitle"),
		PetManagementUtils.detailObjectReference:GetRefValue("defMagTitle"),
		PetManagementUtils.detailObjectReference:GetRefValue("atkMagTitle")
	}
	PetManagementUtils.propTitle2Group = {
		PetManagementUtils.detailObjectReference:GetRefValue("txtHPUSDFText"),
		PetManagementUtils.detailObjectReference:GetRefValue("txtATKUSDFText"),
		PetManagementUtils.detailObjectReference:GetRefValue("txtDEFUSDFText"),
		PetManagementUtils.detailObjectReference:GetRefValue("txtSPDUSDFText"),
		PetManagementUtils.detailObjectReference:GetRefValue("txtSDEFUSDFText"),
		PetManagementUtils.detailObjectReference:GetRefValue("txtSATKUSDFText")
	}
	PetManagementUtils.hpCmp = PetManagementUtils.detailObjectReference:GetRefValue("hpCmp")
	PetManagementUtils.atkCmp = PetManagementUtils.detailObjectReference:GetRefValue("atkCmp")
	PetManagementUtils.defCmp = PetManagementUtils.detailObjectReference:GetRefValue("defCmp")
	PetManagementUtils.regenCmp = PetManagementUtils.detailObjectReference:GetRefValue("regenCmp")
	PetManagementUtils.defMagCmp = PetManagementUtils.detailObjectReference:GetRefValue("defMagCmp")
	PetManagementUtils.atkMagCmp = PetManagementUtils.detailObjectReference:GetRefValue("atkMagCmp")
	PetManagementUtils.propCmpGroup = {
		PetManagementUtils.hpCmp,
		PetManagementUtils.atkCmp,
		PetManagementUtils.defCmp,
		PetManagementUtils.regenCmp,
		PetManagementUtils.defMagCmp,
		PetManagementUtils.atkMagCmp
	}
	PetManagementUtils.hpLevelCmp = PetManagementUtils.detailObjectReference:GetRefValue("hpLevelCmp")
	PetManagementUtils.atkLevelCmp = PetManagementUtils.detailObjectReference:GetRefValue("atkLevelCmp")
	PetManagementUtils.defLevelCmp = PetManagementUtils.detailObjectReference:GetRefValue("defLevelCmp")
	PetManagementUtils.regenLevelCmp = PetManagementUtils.detailObjectReference:GetRefValue("regenLevelCmp")
	PetManagementUtils.defMagLevelCmp = PetManagementUtils.detailObjectReference:GetRefValue("defMagLevelCmp")
	PetManagementUtils.atkMagLevelCmp = PetManagementUtils.detailObjectReference:GetRefValue("atkMagLevelCmp")
	PetManagementUtils.propLevelCmpGroup = {
		PetManagementUtils.hpLevelCmp,
		PetManagementUtils.atkLevelCmp,
		PetManagementUtils.defLevelCmp,
		PetManagementUtils.regenLevelCmp,
		PetManagementUtils.defMagLevelCmp,
		PetManagementUtils.atkMagLevelCmp
	}
	PetManagementUtils.hpLv = PetManagementUtils.detailObjectReference:GetRefValue("hpLv")
	PetManagementUtils.atkLv = PetManagementUtils.detailObjectReference:GetRefValue("atkLv")
	PetManagementUtils.defLv = PetManagementUtils.detailObjectReference:GetRefValue("defLv")
	PetManagementUtils.regenLv = PetManagementUtils.detailObjectReference:GetRefValue("regenLv")
	PetManagementUtils.defMagLv = PetManagementUtils.detailObjectReference:GetRefValue("defMagLv")
	PetManagementUtils.atkMagLv = PetManagementUtils.detailObjectReference:GetRefValue("atkMagLv")
	PetManagementUtils.propLevelGroup = {
		PetManagementUtils.hpLv,
		PetManagementUtils.atkLv,
		PetManagementUtils.defLv,
		PetManagementUtils.regenLv,
		PetManagementUtils.defMagLv,
		PetManagementUtils.atkMagLv
	}
	PetManagementUtils.defaultRadar = PetManagementUtils.detailObjectReference:GetRefValue("defaultRadar")
	PetManagementUtils.addedRadar = PetManagementUtils.detailObjectReference:GetRefValue("addedRadar")
	PetManagementUtils.root = PetManagementUtils.detailObjectReference:GetRefValue("root")
	PetManagementUtils.newRatioNodeUComp = PetManagementUtils.detailObjectReference:GetRefValue("newRatioNodeUComp")
	PetManagementUtils.btnSwitchMaxUButton = PetManagementUtils.detailObjectReference:GetRefValue("btnSwitchMaxUButton")
	PetManagementUtils.characterUWidget = PetManagementUtils.detailObjectReference:GetRefValue("characterUWidget")
	PetManagementUtils.btnTalentUButton = PetManagementUtils.detailObjectReference:GetRefValue("btnTalentUButton")
	PetManagementUtils.accessListUList = PetManagementUtils.detailObjectReference:GetRefValue("accessListUList")
	PetManagementUtils.btnRareTraitUButton = PetManagementUtils.detailObjectReference:GetRefValue("btnRareTraitUButton")
	PetManagementUtils.featureIcon = PetManagementUtils.detailObjectReference:GetRefValue("featureIcon")
	PetManagementUtils.btnDetailUButton = PetManagementUtils.detailObjectReference:GetRefValue("btnDetailUButton")

	local hideF1 = PetManagementUtils.param and PetManagementUtils.param.hideBtnFavorite
	local ctrlConfig = PetManagementUtils.param and PetManagementUtils.param.ctrlConfig or {}
	local hideF2 = ctrlConfig.isForbidFavoriteBtn or false

	if hideF1 or hideF2 then
		PetManagementUtils.btnFavoriteUButton:SetActive(false)
	end

	function PetManagementUtils.btnFavoriteUButton.luaClick()
		PetManagementUtils._onClickFavoriteBtn()
	end

	function PetManagementUtils.btnRenameUButton.luaClick()
		PetRenameValidator.tryShowRenamePet(function()
			PetManagementDataHelper.showRename(PetManagementUtils.petId, PetManagementDataHelper.RENAME_FOR_PET)
		end)
	end

	function PetManagementUtils.btnSwitchMaxUButton.luaClick()
		PetManagementUtils._previewMaxLevel(true)
	end

	PetManagementUtils.characterUWidget.gameObject:SetActiveEx(true)

	function PetManagementUtils.btnTalentUButton.luaTooltipPopup(_, flag)
		PetManagementUtils.btnTalentUButton.isSelected = flag

		PetManagementUtils.btnTalentUButton:TryChangePage("button", flag and 5 or 0)
	end

	if PetManagementUtils.param and PetManagementUtils.param.extraLogic then
		PetManagementUtils.param.extraLogic()
	end
end

function PetManagementUtils.clearAbilityUContainerObjects()
	PetManagementUtils.panelAbilityUContainerObjectReference = nil
	PetManagementUtils.title = nil
	PetManagementUtils.detail = nil
	PetManagementUtils.titleObjectReference = nil
	PetManagementUtils.petNameUText = nil
	PetManagementUtils.name01USDFText = nil
	PetManagementUtils.nameShineUSDFText = nil
	PetManagementUtils.petElementUList = nil
	PetManagementUtils.numCPUText = nil
	PetManagementUtils.btnRenameUButton = nil
	PetManagementUtils.btnFavoriteUButton = nil
	PetManagementUtils.numLevelUText = nil
	PetManagementUtils.expSlider = nil
	PetManagementUtils.listTagUList = nil
	PetManagementUtils.typeImage = nil
	PetManagementUtils.typeDesc = nil
	PetManagementUtils.starUContainer = nil
	PetManagementUtils.m_starComp = nil
	PetManagementUtils.detailObjectReference = nil
	PetManagementUtils.hpNum = nil
	PetManagementUtils.atkNum = nil
	PetManagementUtils.defNum = nil
	PetManagementUtils.regenNum = nil
	PetManagementUtils.defMagNum = nil
	PetManagementUtils.atkMagNum = nil
	PetManagementUtils.propNumGroup = nil
	PetManagementUtils.propTitleGroup = nil
	PetManagementUtils.propTitle2Group = nil
	PetManagementUtils.hpCmp = nil
	PetManagementUtils.atkCmp = nil
	PetManagementUtils.defCmp = nil
	PetManagementUtils.regenCmp = nil
	PetManagementUtils.defMagCmp = nil
	PetManagementUtils.atkMagCmp = nil
	PetManagementUtils.propCmpGroup = nil
	PetManagementUtils.hpLevelCmp = nil
	PetManagementUtils.atkLevelCmp = nil
	PetManagementUtils.defLevelCmp = nil
	PetManagementUtils.regenLevelCmp = nil
	PetManagementUtils.defMagLevelCmp = nil
	PetManagementUtils.atkMagLevelCmp = nil
	PetManagementUtils.propLevelCmpGroup = nil
	PetManagementUtils.hpLv = nil
	PetManagementUtils.atkLv = nil
	PetManagementUtils.defLv = nil
	PetManagementUtils.regenLv = nil
	PetManagementUtils.defMagLv = nil
	PetManagementUtils.atkMagLv = nil
	PetManagementUtils.propLevelGroup = nil
	PetManagementUtils.defaultRadar = nil
	PetManagementUtils.addedRadar = nil
	PetManagementUtils.root = nil
	PetManagementUtils.newRatioNodeUComp = nil
	PetManagementUtils.btnSwitchMaxUButton = nil
	PetManagementUtils.characterUWidget = nil
	PetManagementUtils.btnTalentUButton = nil
	PetManagementUtils.accessListUList = nil
	PetManagementUtils.btnRareTraitUButton = nil
	PetManagementUtils.featureIcon = nil
	PetManagementUtils.btnDetailUButton = nil
end

function PetManagementUtils._findPanelSkillUContainerObjects()
	PetManagementUtils.panelSkillUContainerObjectReference = PetManagementUtils.panelSkillUContainer.content.transform:GetComponent("ObjectReference")
	PetManagementUtils.skillUWidget = PetManagementUtils.panelSkillUContainerObjectReference:GetRefValue("skillUWidget")
	PetManagementUtils.btnSkillPresetsUButton = PetManagementUtils.panelSkillUContainerObjectReference:GetRefValue("btnSkillPresetsUButton")
	PetManagementUtils.skillPresetName = PetManagementUtils.panelSkillUContainerObjectReference:GetRefValue("skillPresetName")
	PetManagementUtils.carryItemUComponent = PetManagementUtils.panelSkillUContainerObjectReference:GetRefValue("carryItemUComponent")

	local carryItemObjectReference = PetManagementUtils.carryItemUComponent:GetComponent("ObjectReference")

	PetManagementUtils.listGemsUList = carryItemObjectReference:GetRefValue("listGemsUList")
	PetManagementUtils.skillUWidgetObjectReference = PetManagementUtils.skillUWidget.transform:GetComponent("ObjectReference")
	PetManagementUtils.btnUniqueSkillUButton = PetManagementUtils.skillUWidgetObjectReference:GetRefValue("btnUniqueSkillUButton")
	PetManagementUtils.btnNormalSkill1UButton = PetManagementUtils.skillUWidgetObjectReference:GetRefValue("btnNormalSkill1UButton")
	PetManagementUtils.btnNormalSkill2UButton = PetManagementUtils.skillUWidgetObjectReference:GetRefValue("btnNormalSkill2UButton")
	PetManagementUtils.btnExploreSkillUButton = PetManagementUtils.skillUWidgetObjectReference:GetRefValue("btnExploreSkillUButton")
	PetManagementUtils.btnFeaturesUButton = PetManagementUtils.skillUWidgetObjectReference:GetRefValue("btnFeaturesUButton")

	local txtUniqueUSDFText = PetManagementUtils.skillUWidgetObjectReference:GetRefValue("txtUniqueUSDFText")

	ClientTextUtils.setText(txtUniqueUSDFText, pg.getGameString("PETSKILL_ULTIMATE"))

	function PetManagementUtils.btnSkillPresetsUButton.luaClick()
		PetManagementUtils._onClickSkillPresetsButton()
	end

	if PetManagementUtils.param and PetManagementUtils.param.extraLogic then
		PetManagementUtils.param.extraLogic()
	end
end

function PetManagementUtils.clearSkillUContainerObjects()
	PetManagementUtils.panelSkillUContainerObjectReference = nil
	PetManagementUtils.skillUWidget = nil
	PetManagementUtils.btnSkillPresetsUButton = nil
	PetManagementUtils.skillPresetName = nil
	PetManagementUtils.carryItemUComponent = nil
	PetManagementUtils.listGemsUList = nil
	PetManagementUtils.skillUWidgetObjectReference = nil
	PetManagementUtils.btnUniqueSkillUButton = nil
	PetManagementUtils.btnNormalSkill1UButton = nil
	PetManagementUtils.btnNormalSkill2UButton = nil
	PetManagementUtils.btnExploreSkillUButton = nil
	PetManagementUtils.btnFeaturesUButton = nil

	if PetManagementUtils.param and PetManagementUtils.param.extraLogic then
		PetManagementUtils.param.extraLogic = nil
	end
end

function PetManagementUtils._findPanelInfoUContainerObjects()
	PetManagementUtils.panelInfoUContainerObjectReference = PetManagementUtils.panelInfoUContainer.content.transform:GetComponent("ObjectReference")
	PetManagementUtils.petDesc = PetManagementUtils.panelInfoUContainerObjectReference:GetRefValue("petDesc")
	PetManagementUtils.beenText = PetManagementUtils.panelInfoUContainerObjectReference:GetRefValue("beenText")
	PetManagementUtils.infoPetName = PetManagementUtils.panelInfoUContainerObjectReference:GetRefValue("infoPetName")
	PetManagementUtils.infoPetNameExtra = PetManagementUtils.panelInfoUContainerObjectReference:GetRefValue("infoPetNameExtra")
	PetManagementUtils.txtDetailUSDFText = PetManagementUtils.panelInfoUContainerObjectReference:GetRefValue("txtDetailUSDFText")
	PetManagementUtils.rawImageRawImagePro = PetManagementUtils.panelInfoUContainerObjectReference:GetRefValue("rawImageRawImagePro")
	PetManagementUtils.nameShineUSDFText1 = PetManagementUtils.panelInfoUContainerObjectReference:GetRefValue("nameShineUSDFText1")
	PetManagementUtils.nameShineUSDFText2 = PetManagementUtils.panelInfoUContainerObjectReference:GetRefValue("nameShineUSDFText2")
	PetManagementUtils.uINodePetPanelInfoUComponent = PetManagementUtils.panelInfoUContainerObjectReference:GetRefValue("uINodePetPanelInfoUComponent")
	PetManagementUtils.accessListUListHome = PetManagementUtils.panelInfoUContainerObjectReference:GetRefValue("accessListUList")
	PetManagementUtils.btnTalentUButtonHome = PetManagementUtils.panelInfoUContainerObjectReference:GetRefValue("btnTalentUButton")
	PetManagementUtils.abilityListUList = PetManagementUtils.panelInfoUContainerObjectReference:GetRefValue("abilityListUList")
	PetManagementUtils.hobbyListUList = PetManagementUtils.panelInfoUContainerObjectReference:GetRefValue("hobbyListUList")
	PetManagementUtils.btnAbilityUButton = PetManagementUtils.panelInfoUContainerObjectReference:GetRefValue("btnAbilityUButton")
	PetManagementUtils.btnHobbyUButton = PetManagementUtils.panelInfoUContainerObjectReference:GetRefValue("btnHobbyUButton")
	PetManagementUtils.sourceUWidget = PetManagementUtils.panelInfoUContainerObjectReference:GetRefValue("sourceUWidget")
	PetManagementUtils.txtSourceUBaseText = PetManagementUtils.panelInfoUContainerObjectReference:GetRefValue("txtSourceUBaseText")
	PetManagementUtils.textUSDFText = PetManagementUtils.panelInfoUContainerObjectReference:GetRefValue("textUSDFText")
	PetManagementUtils.txtNumLiveUSDFText = PetManagementUtils.panelInfoUContainerObjectReference:GetRefValue("txtNumLiveUSDFText")
	PetManagementUtils.txtTitleLiveUSDFText = PetManagementUtils.panelInfoUContainerObjectReference:GetRefValue("txtTitleLiveUSDFText")
	PetManagementUtils.btnLiveUButton = PetManagementUtils.panelInfoUContainerObjectReference:GetRefValue("btnLiveUButton")

	if PetManagementUtils.rawImageRawImageProData then
		PetManagementUtils.rawImageRawImageProData:setRawImageProRef(PetManagementUtils.rawImageRawImagePro)

		PetManagementUtils.rawImageRawImageProData = nil
	end

	if PetManagementUtils.param and PetManagementUtils.param.extraLogic then
		PetManagementUtils.param.extraLogic()
	end
end

function PetManagementUtils.clearInfoUContainerObjects()
	PetManagementUtils.panelInfoUContainerObjectReference = nil
	PetManagementUtils.petDesc = nil
	PetManagementUtils.beenText = nil
	PetManagementUtils.infoPetName = nil
	PetManagementUtils.infoPetNameExtra = nil
	PetManagementUtils.txtDetailUSDFText = nil
	PetManagementUtils.rawImageRawImagePro = nil
	PetManagementUtils.nameShineUSDFText1 = nil
	PetManagementUtils.nameShineUSDFText2 = nil
	PetManagementUtils.uINodePetPanelInfoUComponent = nil
	PetManagementUtils.accessListUListHome = nil
	PetManagementUtils.btnTalentUButtonHome = nil
	PetManagementUtils.abilityListUList = nil
	PetManagementUtils.hobbyListUList = nil
	PetManagementUtils.btnAbilityUButton = nil
	PetManagementUtils.btnHobbyUButton = nil
	PetManagementUtils.sourceUWidget = nil
	PetManagementUtils.txtSourceUBaseText = nil
	PetManagementUtils.btnPetManualUButton = nil
	PetManagementUtils.textUSDFText = nil
	PetManagementUtils.txtNumLiveUSDFText = nil
	PetManagementUtils.txtTitleLiveUSDFText = nil
	PetManagementUtils.btnLiveUButton = nil

	if PetManagementUtils.param and PetManagementUtils.param.extraLogic then
		PetManagementUtils.param = nil
	end
end

function PetManagementUtils._initInfoPanelView()
	local restoreContext = PetManagementUtils._captureContextRestorer()

	function PetManagementUtils.attributeBtn.luaClick()
		restoreContext()
		PetManagementUtils._switchPetInfoTopPages(0)
	end

	function PetManagementUtils.skillBtn.luaClick()
		restoreContext()
		PetManagementUtils._switchPetInfoTopPages(1)
	end

	function PetManagementUtils.infoBtn.luaClick()
		restoreContext()
		PetManagementUtils._switchPetInfoTopPages(2)
	end

	PetManagementUtils.defaultSelectTabIndex = PetManagementUtils.param and PetManagementUtils.param.defaultSelectTabIndex or 0

	if PetManagementUtils.param.noNeedTabIndex then
		PetManagementUtils.defaultSelectTabIndex = nil
	end
end

function PetManagementUtils._chooseTabButton(index)
	return
end

function PetManagementUtils._switchPetInfoTopPages(index)
	PetManagementUtils.pageIndex = index or 0

	PetManagementUtils.rightPanelUComponent:TryChangePage("tabInfo", PetManagementUtils.pageIndex)

	if PetManagementUtils.pageIndex == 0 then
		if not PetManagementUtils.panelAbilityUContainer:CheckURLLoaded() then
			PetManagementUtils.panelAbilityUContainer:LoadDefaultUrlManually(function(obj)
				if IsNil(obj) then
					return
				end

				PetManagementUtils._findPanelAbilityUContainerObjects()

				if PetManagementUtils.panelAbilityUContainerData then
					PetManagementUtils._renderPetInfoCard(PetManagementUtils.panelAbilityUContainerData)
					PetManagementUtils._setTotalAttribute(PetManagementUtils.panelAbilityUContainerData.id)
					PetManagementUtils._resetBtnState()
					PetManagementUtils._previewMaxLevel()
					PetManagementUtils._refreshGiftList(PetManagementUtils.panelAbilityUContainerData)

					PetManagementUtils.panelAbilityUContainerData = nil
				end
			end)
		else
			PetManagementUtils._previewMaxLevel()
		end

		if PetManagementUtils.defaultRadar and PetManagementUtils.defaultRatioGroup then
			PetManagementUtils.defaultRadar:SetSixProps(PetManagementUtils.defaultRatioGroup[Const.BASE_PROPERTY_HP_IDX], PetManagementUtils.defaultRatioGroup[Const.BASE_PROPERTY_ATK_IDX], PetManagementUtils.defaultRatioGroup[Const.BASE_PROPERTY_DEF_IDX], PetManagementUtils.defaultRatioGroup[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX], PetManagementUtils.defaultRatioGroup[Const.BASE_PROPERTY_DEF_MAG_IDX], PetManagementUtils.defaultRatioGroup[Const.BASE_PROPERTY_ATK_MAG_IDX])
		end

		if PetManagementUtils.addedRadar and PetManagementUtils.addedRatioGroup then
			PetManagementUtils.addedRadar:SetSixProps(PetManagementUtils.addedRatioGroup[Const.BASE_PROPERTY_HP_IDX], PetManagementUtils.addedRatioGroup[Const.BASE_PROPERTY_ATK_IDX], PetManagementUtils.addedRatioGroup[Const.BASE_PROPERTY_DEF_IDX], PetManagementUtils.addedRatioGroup[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX], PetManagementUtils.addedRatioGroup[Const.BASE_PROPERTY_DEF_MAG_IDX], PetManagementUtils.addedRatioGroup[Const.BASE_PROPERTY_ATK_MAG_IDX])
		end
	elseif PetManagementUtils.pageIndex == 1 then
		if not PetManagementUtils.panelSkillUContainer:CheckURLLoaded() then
			PetManagementUtils.panelSkillUContainer:LoadDefaultUrlManually(function(obj)
				if IsNil(obj) then
					return
				end

				PetManagementUtils._findPanelSkillUContainerObjects()

				if PetManagementUtils.panelSkillUContainerData then
					PetManagementUtils._setCarryItem(PetManagementUtils.panelSkillUContainerData.id)
					PetManagementUtils._setFeature(PetManagementUtils.panelSkillUContainerData.id)
					PetManagementUtils._refreshSkillList(PetManagementUtils.panelSkillUContainerData.id)

					PetManagementUtils.panelSkillUContainerData = nil
				end
			end)
		end
	elseif PetManagementUtils.pageIndex == 2 and not PetManagementUtils.panelInfoUContainer:CheckURLLoaded() then
		PetManagementUtils.panelInfoUContainer:LoadDefaultUrlManually(function(obj)
			if IsNil(obj) then
				return
			end

			PetManagementUtils._findPanelInfoUContainerObjects()

			if PetManagementUtils.panelInfoUContainerData then
				PetManagementUtils._refreshInfo(PetManagementUtils.panelInfoUContainerData)

				PetManagementUtils.panelInfoUContainerData = nil
			end
		end)
	end

	if PetManagementUtils.onPetInfoPageChange then
		PetManagementUtils.onPetInfoPageChange(PetManagementUtils.pageIndex)
	end
end

function PetManagementUtils._refreshPetInfoDetail(data)
	if data.empty or data.isEmpty then
		PetManagementUtils.currentPetInfoData = nil
		PetManagementUtils.petId = nil

		PetManagementUtils.rightPanelUComponent:TryChangePage("tabInfo", 3)

		return
	else
		PetManagementUtils.currentPetInfoData = data

		PetManagementUtils._initPetTagAnimLastLabel(data.id, data.label)
		PetManagementUtils._switchPetInfoTopPages(PetManagementUtils.pageIndex)

		PetManagementUtils.petId = data.id
		PetManagementUtils.iconName = data.iconName
		PetManagementUtils.label = data.label
		PetManagementUtils.templateId = data.templateId

		if PetManagementUtils.panelAbilityUContainer:CheckURLLoaded() then
			PetManagementUtils._renderPetInfoCard(data)
			PetManagementUtils._setTotalAttribute(data.id)
			PetManagementUtils._resetBtnState()
			PetManagementUtils._previewMaxLevel()
			PetManagementUtils._refreshGiftList(data)
		else
			PetManagementUtils.panelAbilityUContainerData = data
		end

		if PetManagementUtils.panelSkillUContainer:CheckURLLoaded() then
			PetManagementUtils._setCarryItem(data.id)
			PetManagementUtils._setFeature(data.id)
			PetManagementUtils._refreshSkillList(data.id)
		else
			PetManagementUtils.panelSkillUContainerData = data
		end

		if PetManagementUtils.panelInfoUContainer:CheckURLLoaded() then
			PetManagementUtils._refreshInfo(data)
		else
			PetManagementUtils.panelInfoUContainerData = data
		end

		if PetManagementUtils.defaultSelectTabIndex then
			PetManagementUtils._chooseTabButton(PetManagementUtils.defaultSelectTabIndex)
			PetManagementUtils._switchPetInfoTopPages(PetManagementUtils.defaultSelectTabIndex)
		end
	end
end

function PetManagementUtils._getPetTagAnimRecordKey(petId, labelMask)
	return string_format("pet_tag_anim_%s_%s", tostring(petId), tostring(labelMask))
end

function PetManagementUtils._initPetTagAnimLastLabel(petId, label)
	if not petId then
		return
	end

	PetManagementUtils.m_petTagAnimLastLabelMap = PetManagementUtils.m_petTagAnimLastLabelMap or {}

	if PetManagementUtils.m_petTagAnimLastLabelMap[petId] == nil then
		PetManagementUtils.m_petTagAnimLastLabelMap[petId] = label or Const.PET_LABEL_MASK.NORMAL
	end
end

function PetManagementUtils._getPetTagLabelMask(tagData)
	if not tagData then
		return nil
	end

	if tagData.labelMask then
		return tagData.labelMask
	end

	if tagData.tIndex == 1 then
		if tagData.shinyIndex == 0 then
			return Const.PET_LABEL_MASK.SHINY
		elseif tagData.shinyIndex == 1 then
			return Const.PET_LABEL_MASK.MAGIC
		end
	elseif tagData.tIndex == 2 then
		local label = tagData.label

		if bit.band(label or 0, Const.PET_LABEL_MASK.ELITE) ~= 0 then
			return Const.PET_LABEL_MASK.ELITE
		elseif bit.band(label or 0, Const.PET_LABEL_MASK.BOSS) ~= 0 then
			return Const.PET_LABEL_MASK.BOSS
		end
	end

	return nil
end

function PetManagementUtils._isPetTagLabelAdded(oldLabel, newLabel, labelMask)
	if oldLabel == nil or not labelMask then
		return false
	end

	return bit.band(oldLabel or 0, labelMask) == 0 and bit.band(newLabel or 0, labelMask) ~= 0
end

function PetManagementUtils._canPlayPetTagFirstGotAnim(petId, labelMask)
	if not pg or not pg.me or not petId or not labelMask then
		return false
	end

	local recordKey = PetManagementUtils._getPetTagAnimRecordKey(petId, labelMask)

	return pg.me:getRedDotRecord(Const.CLIENT_KEY.PET_TAG_ANIM_RECORD, recordKey, true)
end

function PetManagementUtils._recordPetTagFirstGotAnim(petId, labelMask)
	if not pg or not pg.me or not petId or not labelMask then
		return
	end

	if pg.game.petManage:shouldSkipPetRedDotRecord(pg.me, petId) then
		return
	end

	local recordKey = PetManagementUtils._getPetTagAnimRecordKey(petId, labelMask)

	pg.me:setRedDotRecord(Const.CLIENT_KEY.PET_TAG_ANIM_RECORD, recordKey, false)
end

function PetManagementUtils._markFirstGotPetTagAnim(petId, newLabel, tagDatas)
	if not petId then
		return
	end

	PetManagementUtils.m_petTagAnimLastLabelMap = PetManagementUtils.m_petTagAnimLastLabelMap or {}

	local oldLabel = PetManagementUtils.m_petTagAnimLastLabelMap[petId]

	PetManagementUtils.m_petTagAnimLastLabelMap[petId] = newLabel or Const.PET_LABEL_MASK.NORMAL

	if oldLabel == nil or not tagDatas then
		return
	end

	for _, tagData in pairs(tagDatas) do
		local labelMask = PetManagementUtils._getPetTagLabelMask(tagData)

		if PetManagementUtils._isPetTagLabelAdded(oldLabel, newLabel, labelMask) and PetManagementUtils._canPlayPetTagFirstGotAnim(petId, labelMask) then
			tagData.playTagAnim = true
			tagData.playTagAnimPetId = petId
			tagData.playTagAnimLabelMask = labelMask
		end
	end
end

function PetManagementUtils._tryPlayPetTagAnim(button, data)
	if not button or not data or not data.playTagAnim then
		return
	end

	data.playTagAnim = false

	PetManagementUtils._recordPetTagFirstGotAnim(data.playTagAnimPetId, data.playTagAnimLabelMask)

	local anim = button:GetComponent("Animation")

	if anim then
		anim:Stop()
		anim:Play()
	end
end

function PetManagementUtils._refreshPetTagList(data, onlyIfPending)
	if not data or not PetManagementUtils.listTagUList then
		return false
	end

	local tagDatas = LuaUIUtils.getPetTagList(data) or {}

	PetManagementUtils._markFirstGotPetTagAnim(data.id, data.label, tagDatas)

	local hasPendingAnim = false

	for _, tagData in pairs(tagDatas) do
		if tagData.playTagAnim then
			hasPendingAnim = true

			break
		end
	end

	if onlyIfPending and not hasPendingAnim then
		return false
	end

	function PetManagementUtils.listTagUList.luaRenderItem(button, idx, tagData)
		LuaUIUtils.renderPetTagList(button, tagData)
		PetManagementUtils._tryPlayPetTagAnim(button, tagData)

		local templateId = tagData and tagData.templateId
		local label = tagData and tagData.label
		local bodySizeType = tagData and tagData.bodySizeType

		LuaUIUtils.setPetTagLabelToolTip(button, LuaUIUtils.getPetTagInfo(templateId, label, bodySizeType, data.shinyStyle))
	end

	PetManagementUtils.listTagUList:SetList(tagDatas)

	return true
end

function PetManagementUtils._renderPetInfoCard(data)
	PetManagementUtils.petNameStr = PetManagementDataHelper.getPetName(PetManagementUtils.petId)

	if pg.game.setting:getShowDebugId() then
		PetManagementUtils.petNameStr = PetManagementUtils.petNameStr .. tostring(data.templateId)
	end

	PetManagementUtils._refreshPetName(PetManagementUtils.petNameStr)

	function PetManagementUtils.petElementUList.luaRenderItem(button, _, data1)
		LuaUIUtils.setElementButtonNew(button, data1.element, true, data.templateId)
	end

	PetManagementUtils.petElementUList:SetList(data.elementNames)

	local pet = pg.me:getPetInfo(PetManagementUtils.petId)
	local cpValue = pet:isCatchReporting() and "???" or data.cp

	ClientTextUtils.setText(PetManagementUtils.numCPUText, ClientTextUtils.concatByLanguage(pg.getGameString("CP"), cpValue))

	if data.gender == Const.GENDER_TYPE_MALE then
		PetManagementUtils.rightPanelUComponent:TryChangePage("Gender", 0)
	elseif data.gender == Const.GENDER_TYPE_FEMALE then
		PetManagementUtils.rightPanelUComponent:TryChangePage("Gender", 1)
	else
		PetManagementUtils.rightPanelUComponent:TryChangePage("Gender", 2)
	end

	ClientTextUtils.setText(PetManagementUtils.numLevelUText, data.level)

	local maxExp = PetLevelData[data.level + 1] ~= nil and PetLevelData[data.level + 1].needExp or 0

	PetManagementUtils.expSlider.value = maxExp == 0 and 1 or data.exp / maxExp

	if data.isShiny then
		PetManagementUtils.rightPanelUComponent:TryChangePage("isFlash", 1)
	else
		PetManagementUtils.rightPanelUComponent:TryChangePage("isFlash", 0)
	end

	if data.isBoss then
		PetManagementUtils.title:TryChangePage("isBoss", 1)
	else
		PetManagementUtils.title:TryChangePage("isBoss", 0)
	end

	if data.isVariant then
		PetManagementUtils.title:TryChangePage("isChange", 1)
	else
		PetManagementUtils.title:TryChangePage("isChange", 0)
	end

	local titleObjectReference = PetManagementUtils.titleObjectReference
	local btnIsChangeUButton = titleObjectReference:GetRefValue("btnIsChangeUButton")
	local isChangeTipsUWidget = titleObjectReference:GetRefValue("isChangeTipsUWidget")

	isChangeTipsUWidget:SetActive(false)
	LuaUIUtils.bindVariantPetDetailButton(btnIsChangeUButton, isChangeTipsUWidget, data)

	local petType = PetData[PetManagementUtils.templateId].functionId

	PetManagementUtils.typeImage.url = PetConfigData.petFunctionIcon[petType]

	ClientTextUtils.setText(PetManagementUtils.typeDesc, pg.getLocalizationText(PetConfigData[string.format("petFunctionText%s", petType)]) or "")
	PetManagementUtils.m_refreshStarUpContainer(PetManagementUtils.petId, PetManagementUtils.starUContainer)
	PetManagementUtils._refreshPetTagList(data, false)
end

function PetManagementUtils.m_refreshStarUpContainer(petId, starUContainer, forbidToolTip)
	if not petId or not starUContainer then
		return
	end

	local curResonanceInfo = PetManagementUtils.getPetStarUpInfo(petId)
	local stage = curResonanceInfo.resonanceStage or 0
	local level = curResonanceInfo.resonanceLevel or 0
	local curStageStarUrl = PetManagementUtils.getStarItemUrl(stage)

	starUContainer:SetUrlWithCallback(curStageStarUrl, function()
		if not petId then
			return
		end

		local starUCont = starUContainer.content
		local PetResonaceStarComponent = require("Guis.Panels.PetTrainingNew.Component.SubNodeComps.PetResonaceStarComponent")

		PetManagementUtils.m_starComp = PetResonaceStarComponent.new(starUCont)

		if PetManagementUtils.m_starComp then
			PetManagementUtils.m_starComp:updateAndRefresh(petId, {
				stage = stage,
				lv = level,
				pos = UIConst.STARCOMP_POS.PETINFO
			}, forbidToolTip)
		end
	end)
end

function PetManagementUtils._setTotalAttribute(petId)
	local pet = pg.me:getPetInfo(petId)

	if pet == nil then
		return
	end

	local propLevels = pg.game.petManage:getPetPropLevels(pet)

	for i = Const.BASE_PROPERTY_HP_IDX, Const.BASE_PROPERTY_ATK_MAG_IDX do
		local propName = pg.getLocalizationText(propLevels[i].l18nNameKey or "")

		ClientTextUtils.setText(PetManagementUtils.propTitleGroup[i], propName)
		ClientTextUtils.setText(PetManagementUtils.propTitle2Group[i], propName)
	end

	PetManagementUtils.renderPetAttributeInner(pet, PetManagementUtils, nil, nil, PetManagementUtils.param)
	PetManagementUtils._ratioAttribute(pet)

	local featureInfo, _ = PetManagementDataHelper.getCurCharacter(petId)

	if featureInfo then
		PetManagementUtils.btnRareTraitUButton.gameObject:SetActiveEx(true)
		PetManagementUtils.btnRareTraitUButton:TryChangePage("Rare", featureInfo.rare == 1 and 1 or 0)

		function PetManagementUtils.btnRareTraitUButton.luaTooltipPopup(_, flag)
			PetManagementUtils.btnRareTraitUButton.isSelected = flag

			PetManagementUtils.btnRareTraitUButton:TryChangePage("button", flag and 5 or 0)
		end

		LuaUIUtils.setRenderFeatureToolTips(PetManagementUtils.btnRareTraitUButton, featureInfo, pet)

		PetManagementUtils.featureIcon.url = featureInfo.icon
	else
		PetManagementUtils.btnRareTraitUButton.gameObject:SetActiveEx(false)
	end
end

function PetManagementUtils._ratioAttribute(pet)
	if not pet or pet.isCatchReporting and pet:isCatchReporting() then
		PetManagementUtils.root:TryChangePage("NotVerified", 1)
	else
		PetManagementUtils.root:TryChangePage("NotVerified", 0)
	end

	if not PetManagementUtils.newRatioNodeUComp then
		return
	end

	PetManagementUtils.setPetRatioUINode(pet, PetManagementUtils.newRatioNodeUComp)
end

function PetManagementUtils.onClickFavoriteBtn(petId)
	if not petId then
		return
	end

	PetManagementUtils._onClickFavoriteBtn(petId)
end

function PetManagementUtils._onClickFavoriteBtn(petId)
	petId = petId or PetManagementUtils.petId

	PetManagementUtils.setRenderFavoriteToolTips(PetManagementUtils.btnFavoriteUButton, petId)
end

function PetManagementUtils._resetBtnState()
	local petInfo = pg.me:getPetInfo(PetManagementUtils.petId)

	if not petInfo then
		return
	end

	PetManagementUtils.refreshFavoriteBtn(PetManagementUtils.btnFavoriteUButton, petInfo.favoriteType)
end

function PetManagementUtils._previewMaxLevel(needModify)
	local pet = pg.me:getPetInfo(PetManagementUtils.petId)

	if pet == nil then
		return
	end

	if needModify then
		PetManagementUtils.previewed = not PetManagementUtils.previewed
	end

	PetManagementUtils.root:TryChangePage("MaxLevel", PetManagementUtils.previewed and 1 or 0)
	PetManagementUtils.addedRadar.transform.gameObject:SetActiveEx(true)

	if PetManagementUtils.previewed then
		Utils.genBasePropertyPreview(pet, Const.PROP_PREVIEW_MAX_LEVEL, {}, function(result)
			local addedRatioGroup = {}

			for i = Const.BASE_PROPERTY_HP_IDX, Const.BASE_PROPERTY_ATK_MAG_IDX do
				ClientTextUtils.setText(PetManagementUtils.propNumGroup[i], result[i].displayValue)
				ClientTextUtils.setText(PetManagementUtils.propLevelGroup[i], result[i].indLv)

				if result[i].iLvLn > 0 then
					PetManagementUtils.propCmpGroup[i]:TryChangePage("State", 1)
					PetManagementUtils.propLevelCmpGroup[i]:TryChangePage("State", 1)
				else
					PetManagementUtils.propCmpGroup[i]:TryChangePage("State", 0)
					PetManagementUtils.propLevelCmpGroup[i]:TryChangePage("State", 0)
				end

				if result[i].indLv >= PetPropLevelMaxData[i] then
					PetManagementUtils.propCmpGroup[i]:TryChangePage("State", 2)
					PetManagementUtils.propLevelCmpGroup[i]:TryChangePage("State", 2)
				end

				addedRatioGroup[i] = result[i].indLv / PetPropLevelMaxData[i]
			end

			PetManagementUtils.addedRadar:SetSixProps(addedRatioGroup[Const.BASE_PROPERTY_HP_IDX], addedRatioGroup[Const.BASE_PROPERTY_ATK_IDX], addedRatioGroup[Const.BASE_PROPERTY_DEF_IDX], addedRatioGroup[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX], addedRatioGroup[Const.BASE_PROPERTY_DEF_MAG_IDX], addedRatioGroup[Const.BASE_PROPERTY_ATK_MAG_IDX])
		end)
	else
		PetManagementUtils._setTotalAttribute(PetManagementUtils.petId)
	end
end

function PetManagementUtils._refreshPetName(petName)
	ClientTextUtils.setText(PetManagementUtils.petNameUText, petName)
	ClientTextUtils.setText(PetManagementUtils.name01USDFText, petName)
	ClientTextUtils.setText(PetManagementUtils.nameShineUSDFText, petName)

	if PetManagementUtils.infoPetNameExtra then
		ClientTextUtils.setText(PetManagementUtils.infoPetNameExtra, petName)
	end
end

function PetManagementUtils._refreshGiftList(data)
	local isForbidPetPropUseBtn = PetManagementUtils.param and PetManagementUtils.param.isForbidPetPropUseBtn

	function PetManagementUtils.btnTalentUButton.luaClick()
		local talentData = {}

		talentData.targetRect = PetManagementUtils.btnTalentUButton
		talentData.autoHor = true
		talentData.hierarchyMode = 2
		talentData.sortingOrder = 2
		talentData.type = UIConst.GIFT_TYPE.BATTLE
		talentData.showType = UIConst.GIFT_SHOW_TYPE.GIFT
		talentData.giftType = UIConst.GIFT_TYPE.HOME
		talentData.breedTalent = data.breedTalent

		if not isForbidPetPropUseBtn then
			talentData.petId = data.id
		end

		talentData.extra = {
			openFun = function()
				PetManagementUtils.btnTalentUButton.isSelected = true

				PetManagementUtils.btnTalentUButton:TryChangePage("button", 5)
			end,
			closeFun = function()
				PetManagementUtils.btnTalentUButton.isSelected = false

				PetManagementUtils.btnTalentUButton:TryChangePage("button", 0)
			end
		}

		pg.global.ui:open(UIConst.UI_ID_PET_GIFT_TIPS, talentData)
	end

	function PetManagementUtils.accessListUList.luaRenderItem(button, _, data1)
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

	PetManagementUtils.accessListUList:SetList(data.breedTalent)
end

function PetManagementUtils._setCarryItem(petId)
	PetManagementUtils.carryItemUComponent.gameObject:SetActiveEx(true)

	local objectReference = PetManagementUtils.carryItemUComponent:GetComponent("ObjectReference")
	local iconPropUImage = objectReference:GetRefValue("iconPropUImage")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local txtStrengthenUSDFText = objectReference:GetRefValue("txtStrengthenUSDFText")
	local carryData = pg.global.ui.petTrainingNew.model:getPetEquipCarry(petId)

	if not carryData then
		PetManagementUtils.carryItemUComponent:TryChangePage("Empty", 1)
	else
		PetManagementUtils.carryItemUComponent:TryChangePage("Empty", 0)

		local isRecommend = LuaUIUtils.checkCarryIsRecommend(petId, carryData.itemId)

		PetManagementUtils.carryItemUComponent:TryChangePage("GoodState", isRecommend and 1 or 0)
		PetManagementUtils.carryItemUComponent:TryChangePage("Quality", carryData.quality)

		iconPropUImage.url = carryData.icon

		ClientTextUtils.setText(txtNameUSDFText, carryData.name)
		ClientTextUtils.setText(txtStrengthenUSDFText, "+" .. carryData.cLevel)

		if PetManagementUtils.listGemsUList then
			LuaUIUtils.refreshCarryAssistInfo(PetManagementUtils.listGemsUList, nil, carryData, true)
		end
	end
end

function PetManagementUtils._setFeature(petId)
	local featureInfo, _ = PetManagementDataHelper.getCurCharacter(petId)
	local petInfo = pg.me:getPetInfo(petId)

	PetManagementUtils.renderPetFeature(PetManagementUtils.btnFeaturesUButton, featureInfo, petInfo)
end

function PetManagementUtils.renderSkill(petId, skillType, skillBtn)
	if skillType == AbilityConst.EXPLORE_ABILITY then
		local skillInfo = PetManagementDataHelper.getPetSkillInfos(petId, skillType)

		PetManagementUtils._renderExploreSkillCmp(skillBtn, skillInfo)
	elseif skillType == AbilityConst.ULTIMATE_ABILITY or skillType == AbilityConst.WEAPON_SKILL_ABILITY or skillType == AbilityConst.WEAPON_SKILL_ABILITY2 then
		local skillInfo = PetManagementDataHelper.getPetSkillInfos(petId, skillType)

		PetManagementUtils._renderSkillCmp(skillBtn, skillInfo, false, skillType == AbilityConst.ULTIMATE_ABILITY, pg.me:getPetInfo(petId))
	else
		return
	end
end

function PetManagementUtils.renderSkillWithAbilityId(abilityId, abilityType, skillBtn)
	local skillInfo = PetManagementDataHelper.getSkillInfosByAbilityId(abilityId, abilityType)

	if skillInfo.tags and skillInfo.tags[1] and SkillTagData[skillInfo.tags[1]] then
		skillInfo.tagName = SkillTagData[skillInfo.tags[1]].tagName
	end

	PetManagementUtils._renderSkillCmp(skillBtn, skillInfo, true)
end

function PetManagementUtils._refreshSkillList(petId)
	local ultSkillInfo = PetManagementDataHelper.getPetSkillInfos(petId, AbilityConst.ULTIMATE_ABILITY)
	local qSkillInfo = PetManagementDataHelper.getPetSkillInfos(petId, AbilityConst.WEAPON_SKILL_ABILITY)
	local eSkillInfo = PetManagementDataHelper.getPetSkillInfos(petId, AbilityConst.WEAPON_SKILL_ABILITY2)
	local exploreSkillInfo = PetManagementDataHelper.getPetSkillInfos(petId, AbilityConst.EXPLORE_ABILITY)
	local petInfo = pg.me:getPetInfo(petId)

	PetManagementUtils._renderSkillCmp(PetManagementUtils.btnUniqueSkillUButton, ultSkillInfo, false, true, petInfo)
	PetManagementUtils._renderSkillCmp(PetManagementUtils.btnNormalSkill1UButton, qSkillInfo, nil, nil, petInfo)

	PetManagementUtils.btnNormalSkill1UButton.draggable = false

	PetManagementUtils._renderSkillCmp(PetManagementUtils.btnNormalSkill2UButton, eSkillInfo, nil, nil, petInfo)

	PetManagementUtils.btnNormalSkill2UButton.draggable = false

	PetManagementUtils._renderExploreSkillCmp(PetManagementUtils.btnExploreSkillUButton, exploreSkillInfo)
	TimerManager.addNextFrameCb(function()
		local petInfo = pg.me:getPetInfo(petId)

		if not petInfo or not petInfo.abilityPresetMap then
			return
		end

		local presetName = petInfo.abilityPresetMap[petInfo.curAbilityPreset] and petInfo.abilityPresetMap[petInfo.curAbilityPreset].name

		if presetName and presetName ~= "" then
			ClientTextUtils.setText(PetManagementUtils.skillPresetName, presetName)
		else
			ClientTextUtils.setText(PetManagementUtils.skillPresetName, ClientTextUtils.concatByLanguage(pg.getGameString("ABILITY_PLAN"), petInfo.curAbilityPreset))
		end
	end)
end

function PetManagementUtils._renderSkillCmp(button, data, hideElement, isUnique, petInfo)
	if not data then
		button.enabledTooltip = false

		button:SetActive(false)

		return
	end

	button:SetActive(true)

	local objectReference = button:GetComponent("ObjectReference")
	local iconNormalUImage = objectReference:GetRefValue("iconNormalUImage")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local elementUButton = objectReference:GetRefValue("elementUButton")
	local skillNameUWidget = objectReference:GetRefValue("skillNameUWidget")
	local uniqueUWidget = objectReference:GetRefValue("uniqueUWidget")
	local txtUniqueUSDFText = objectReference:GetRefValue("txtUniqueUSDFText")

	button:TryChangePage("State", 0)
	button:TryChangePage("Element", 0)
	button:TryChangePage("State", 1)
	button:TryChangePage("IsRare", ToInt(AbilityUtils.isRareAbilityId(data.abilityId)))
	skillNameUWidget.gameObject:SetActiveEx(true)
	ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.name))

	if data.tagName then
		ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.tagName))
	end

	iconNormalUImage.url = LuaUIUtils.getSkillIcon(data.icon)

	if data.elementType and not hideElement then
		button:TryChangePage("Element", 1)
		LuaUIUtils.setElementButtonNew(elementUButton, data.elementType)
	end

	button.enabledTooltip = true

	function button.luaTooltipPopup(_, flag)
		button:TryChangePage("Selected", flag and 1 or 0)
	end

	LuaUIUtils.setRenderSKillTooTip(button, data, nil, petInfo)

	if uniqueUWidget and txtUniqueUSDFText then
		uniqueUWidget:SetActive(isUnique)
		ClientTextUtils.setText(txtUniqueUSDFText, isUnique and pg.getGameString("PETSKILL_ULTIMATE") or "")
	end
end

function PetManagementUtils._renderExploreSkillCmp(button, data)
	if not data then
		button.enabledTooltip = false

		button:SetActive(false)

		return
	end

	button:SetActive(true)

	local objectReference = button:GetComponent("ObjectReference")
	local iconNormalUImage = objectReference:GetRefValue("iconNormalUImage")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

	button:TryChangePage("State", 0)
	button:TryChangePage("Element", 0)
	button:TryChangePage("State", 1)

	iconNormalUImage.url = LuaUIUtils.getSkillIcon(data.icon)

	ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.name))

	button.enabledTooltip = true

	function button.luaTooltipPopup(_, flag)
		button:TryChangePage("Selected", flag and 1 or 0)
	end

	LuaUIUtils.setRenderExploreToolTips(button, data)
end

function PetManagementUtils._refreshInfo(data)
	local isForbidPetPropUseBtn = PetManagementUtils.param and PetManagementUtils.param.isForbidPetPropUseBtn

	function PetManagementUtils.btnLiveUButton.luaRenderTooltip(btn, com)
		local objectReference = com.transform:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("HOMELAND_COMFORT_TIP"))
	end

	ClientTextUtils.setText(PetManagementUtils.txtTitleLiveUSDFText, pg.getGameString("HOMELAND_COMPOSE_LIVE_VALUE") .. ":")
	ClientTextUtils.setText(PetManagementUtils.txtNumLiveUSDFText, ClientHomelandUtils.getPetComfortValueById(data.id))

	local wishingStarButton = LuaUIUtils.bindHomeWishingStarOutput(PetManagementUtils.panelInfoUContainerObjectReference, data)
	local delegate = PetManagementUtils.delegateTable

	if delegate and delegate.onWishingStarOutputBound then
		delegate.onWishingStarOutputBound(wishingStarButton)
	end

	ClientTextUtils.setText(PetManagementUtils.petDesc.content, PetResearchContentData[data.templateId] ~= nil and pg.getLocalizationText(PetResearchContentData[data.templateId].desc) or "EMPTY")
	ClientTextUtils.setText(PetManagementUtils.txtDetailUSDFText, PetResearchContentData[data.templateId] ~= nil and pg.getLocalizationText(PetResearchContentData[data.templateId].desc) or "EMPTY")
	ClientTextUtils.setText(PetManagementUtils.beenText, pg.getFormatText(pg.getGameString("BEEN_WITH"), math.round((Time.secondCache * 1000 - data.time) / 1000 / 3600 / 24)))
	ClientTextUtils.setText(PetManagementUtils.textUSDFText, PetManagementUtils.getDisplayBookNumberText(data))

	local petCubeItemId = data and data.cubeItemId

	LuaUIUtils.refreshPetPanelInfoCubeAndBackground(petCubeItemId, PetManagementUtils.panelInfoUContainerObjectReference)

	local formName = LuaUIUtils.getPetFormName(data.templateId)

	ClientTextUtils.setText(PetManagementUtils.infoPetName, formName)
	PetManagementUtils._refreshPetName(PetManagementUtils.petNameStr)

	if data.isShiny then
		PetManagementUtils.uINodePetPanelInfoUComponent:TryChangePage("isFlash", 1)
	else
		PetManagementUtils.uINodePetPanelInfoUComponent:TryChangePage("isFlash", 0)
	end

	if data.isBoss then
		PetManagementUtils.uINodePetPanelInfoUComponent:TryChangePage("isBoss", 1)
	else
		PetManagementUtils.uINodePetPanelInfoUComponent:TryChangePage("isBoss", 0)
	end

	function PetManagementUtils.btnTalentUButtonHome.luaClick()
		local talentData = {}

		talentData.targetRect = PetManagementUtils.uINodePetPanelInfoUComponent
		talentData.autoHor = true
		talentData.type = UIConst.GIFT_TYPE.HOME
		talentData.showType = UIConst.GIFT_SHOW_TYPE.GIFT
		talentData.giftType = UIConst.GIFT_TYPE.HOME
		talentData.breedTalent = data.breedTalent

		if not isForbidPetPropUseBtn then
			talentData.petId = data.id
		end

		talentData.extra = {
			openFun = function()
				PetManagementUtils.btnTalentUButtonHome.isSelected = true

				PetManagementUtils.btnTalentUButtonHome:TryChangePage("button", 5)
			end,
			closeFun = function()
				if not PetManagementUtils.btnTalentUButtonHome then
					return
				end

				PetManagementUtils.btnTalentUButtonHome.isSelected = false

				PetManagementUtils.btnTalentUButtonHome:TryChangePage("button", 0)
			end
		}

		pg.global.ui:open(UIConst.UI_ID_PET_GIFT_TIPS, talentData)
	end

	function PetManagementUtils.btnAbilityUButton.luaClick()
		local abilityData = PetManagementUtils._getHomeAbilityData()
		local talentData = {}

		talentData.targetRect = PetManagementUtils.uINodePetPanelInfoUComponent
		talentData.autoHor = true
		talentData.showType = UIConst.GIFT_SHOW_TYPE.ABILITY
		talentData.abilityData = abilityData

		pg.global.ui:open(UIConst.UI_ID_PET_GIFT_TIPS, talentData)
	end

	if PetManagementUtils.petManagementSceneCtrl and PetManagementUtils.petManagementSceneCtrl.scene then
		PetManagementUtils.petManagementSceneCtrl:previewPet(PetManagementUtils.petId)
	end

	PetManagementUtils._refreshGiftInfoList(data)
	PetManagementUtils._refreshSource(data)
end

function PetManagementUtils._refreshSource(data)
	local source = PetManagementDataHelper.getPetSource(data.id)
	local showSource = source ~= nil and source ~= ""

	PetManagementUtils.sourceUWidget:SetActive(showSource)

	if showSource then
		local playerName = ""
		local playerInfo = pg.game.chat:getPlayerInfo(source)

		if playerInfo then
			playerName = playerInfo.playerName or ""
		end

		local _h = PetManagementUtils._platformHooks

		playerName = _h and _h.refreshSourcePlayerName and _h.refreshSourcePlayerName(PetManagementUtils, data, source, playerName, playerInfo) or playerName

		local tip = string.gsub(pg.getGameString("PET_EXCHANGE_SOURCE"), "{0}", playerName)

		ClientTextUtils.setText(PetManagementUtils.txtSourceUBaseText, tip)
	end
end

function PetManagementUtils._refreshGiftInfoList(data)
	function PetManagementUtils.accessListUListHome.luaRenderItem(button, _, itemData)
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

	PetManagementUtils.accessListUListHome:SetList(data.breedTalent)

	function PetManagementUtils.abilityListUList.luaRenderItem(button, _, itemData)
		LuaUIUtils.renderHomeAbility(button, itemData.id, itemData.level)
	end

	PetManagementUtils.abilityListUList:SetList(PetManagementUtils._getHomeAbilityData())
end

function PetManagementUtils._getHomeAbilityData()
	local homeAbility = PetData[PetManagementUtils.templateId].homeAbility
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

function PetManagementUtils._openPropertyPanel(inputPetId)
	local petId = inputPetId and inputPetId or PetManagementUtils.petId

	if not petId then
		return
	end

	local petInfo = pg.me:getPetInfo(petId)

	if not petInfo or petInfo:isCatchReporting() then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_PET_PROPERTY, {
		curPetId = petId
	}, function()
		if PetManagementUtils.delegateTable and PetManagementUtils.delegateTable.openPropertyPanelCb then
			PetManagementUtils.delegateTable.openPropertyPanelCb()
		end
	end)
end

function PetManagementUtils._onClickSkillPresetsButton()
	pg.global.ui:open(UIConst.UI_ID_PET_SKILL_REPLACE_QUICK, {
		notPetManagement = true,
		curPetId = PetManagementUtils.petId,
		templateId = PetManagementUtils.templateId
	})
end

function PetManagementUtils._previewSceneProcess()
	if PetManagementUtils.rawImageRawImagePro then
		PetManagementUtils.petManagementSceneCtrl:setRawImageProRef(PetManagementUtils.rawImageRawImagePro)
	else
		PetManagementUtils.rawImageRawImageProData = PetManagementUtils.petManagementSceneCtrl
	end
end

function PetManagementUtils._dealPreProcess()
	PetManagementDataHelper.selectSortId = nil
	PetManagementDataHelper.isDescending = nil
	PetManagementUtils.inFilterMode = false
	PetManagementDataHelper.filter = nil

	if PetManagementUtils.param and PetManagementUtils.param.selectPetId then
		local slot, box = LuaUIUtils.getPetBelongBoxAndSlotId(PetManagementUtils.param.selectPetId)

		if not slot or not box then
			return
		end

		PetManagementDataHelper.setSelectBoxId(box)

		PetManagementUtils.selectSlot = slot - 1
	end
end

function PetManagementUtils._renderMidPanel(midPanelTrans)
	PetManagementUtils._findMidPanelObjects(midPanelTrans)
	PetManagementUtils._initMidPanelView()
end

function PetManagementUtils._findMidPanelObjects(midPanelTrans)
	PetManagementUtils.minPanelObjectReference = midPanelTrans:GetComponent("ObjectReference")
	PetManagementUtils.midPanelUComponent = PetManagementUtils.minPanelObjectReference:GetRefValue("midPanelUComponent")
	PetManagementUtils.boxPetNew = PetManagementUtils.minPanelObjectReference:GetRefValue("boxPetNew")
	PetManagementUtils.boxPetFilterList = PetManagementUtils.minPanelObjectReference:GetRefValue("boxPetFilterList")
	PetManagementUtils.boxSelector = PetManagementUtils.minPanelObjectReference:GetRefValue("boxSelector")
	PetManagementUtils.btnLeftUButton = PetManagementUtils.minPanelObjectReference:GetRefValue("btnLeftUButton")
	PetManagementUtils.btnRightUButton = PetManagementUtils.minPanelObjectReference:GetRefValue("btnRightUButton")
	PetManagementUtils.btnFilterUButton = PetManagementUtils.minPanelObjectReference:GetRefValue("btnFilterUButton")
	PetManagementUtils.btnFilter1UButton = PetManagementUtils.minPanelObjectReference:GetRefValue("btnFilter1UButton")
	PetManagementUtils.btnCleanFilterUButton = PetManagementUtils.minPanelObjectReference:GetRefValue("btnCleanFilterUButton")
	PetManagementUtils.btnLeftHotKeyContent = PetManagementUtils.minPanelObjectReference:GetRefValue("btnLeftHotKeyContent")
	PetManagementUtils.btnRightHotKeyContent = PetManagementUtils.minPanelObjectReference:GetRefValue("btnRightHotKeyContent")

	local boxPbFilter2 = midPanelTrans:Find("ListControl/PbFilter2")

	PetManagementUtils.boxPbFilter2Go = boxPbFilter2 and boxPbFilter2.gameObject or nil
	PetManagementUtils.boxPetNewListContainers = {}

	for i = 0, 23 do
		PetManagementUtils.boxPetNewListContainers[i] = PetManagementUtils.boxPetNew.transform:GetChild(i).transform:GetComponent("UContainer")
	end
end

function PetManagementUtils._initMidPanelView()
	local restoreContext = PetManagementUtils._captureContextRestorer()

	function PetManagementUtils.btnLeftUButton.luaClick()
		restoreContext()
		PetManagementUtils._switchBoxPages(true)

		local delegate = PetManagementUtils.delegateTable

		if delegate and delegate.gamepadPetBoxPageHandledByPrefab and delegate.onGamepadPetBoxPageSwitched then
			delegate.onGamepadPetBoxPageSwitched()
		end
	end

	function PetManagementUtils.btnRightUButton.luaClick()
		restoreContext()
		PetManagementUtils._switchBoxPages(false)

		local delegate = PetManagementUtils.delegateTable

		if delegate and delegate.gamepadPetBoxPageHandledByPrefab and delegate.onGamepadPetBoxPageSwitched then
			delegate.onGamepadPetBoxPageSwitched()
		end
	end

	local delegate = PetManagementUtils.delegateTable

	if not delegate or not delegate.gamepadPetBoxPageHandledByPrefab then
		UICtrl.bindHotKeyPerform(nil, "Hud/LeftTriggerPagePrev", function()
			local currentDelegate = PetManagementUtils.delegateTable

			if not currentDelegate or not currentDelegate.canGamepadSwitchPetBoxPage or currentDelegate.canGamepadSwitchPetBoxPage() then
				PetManagementUtils.btnLeftUButton.luaClick()

				if currentDelegate and currentDelegate.onGamepadPetBoxPageSwitched then
					currentDelegate.onGamepadPetBoxPageSwitched()
				end
			end
		end, PetManagementUtils.btnLeftUButton.gameObject)
		UICtrl.bindHotKeyPerform(nil, "Hud/RightTriggerPageNxt", function()
			local currentDelegate = PetManagementUtils.delegateTable

			if not currentDelegate or not currentDelegate.canGamepadSwitchPetBoxPage or currentDelegate.canGamepadSwitchPetBoxPage() then
				PetManagementUtils.btnRightUButton.luaClick()

				if currentDelegate and currentDelegate.onGamepadPetBoxPageSwitched then
					currentDelegate.onGamepadPetBoxPageSwitched()
				end
			end
		end, PetManagementUtils.btnRightUButton.gameObject)

		if PetManagementUtils.btnLeftHotKeyContent then
			PetManagementUtils.btnLeftHotKeyContent:SetHotKeyPaths("Hud/LeftTriggerPagePrev")
			PetManagementUtils.btnRightHotKeyContent:SetHotKeyPaths("Hud/RightTriggerPageNxt")
		end
	end

	UICtrl.bindHotKeyPerform(nil, "Hud/InteractScroll", function(_, inputInfo)
		return PetManagementUtils._onPerformPetBoxScroll(inputInfo, restoreContext)
	end, PetManagementUtils.btnLeftUButton.gameObject, "petBoxScroll")

	function PetManagementUtils.btnFilterUButton.luaClick()
		restoreContext()
		PetManagementUtils._openFilterPanel()
	end

	function PetManagementUtils.btnFilter1UButton.luaClick()
		restoreContext()
		PetManagementUtils._openFilterPanel()
	end

	function PetManagementUtils.btnCleanFilterUButton.luaClick()
		restoreContext()
		PetManagementUtils._endFilter()
	end

	function PetManagementUtils.boxPetFilterList.luaRenderItem(button, index, data)
		if PetManagementUtils.displayType == UIConst.PET_SLOT_DISPLAY_TYPE.Homeland then
			PetManagementUtils._setHomeBoxPetListData(button, index, data)
		else
			PetManagementUtils._setBoxPetListData(button, index, data)
		end

		local ctrlConfig = PetManagementUtils.param and PetManagementUtils.param.ctrlConfig or {}
		local isForbidUBtnDrag = ctrlConfig.isForbidUBtnDrag or false

		if isForbidUBtnDrag then
			button.draggable = false
		end
	end

	PetManagementUtils.midPanelUComponent:TryChangePage("State", PetManagementUtils.inFilterMode and 1 or 0)
	PetManagementUtils._refreshPetList()
	PetManagementUtils._refreshBoxSelector()
end

function PetManagementUtils.setOnFilterListRenderFinishedCb(cb)
	PetManagementUtils.onFilterListRenderFinished = cb
end

function PetManagementUtils.setOnNormalListRenderFinishedCb(cb)
	PetManagementUtils.onNormalListRenderFinished = cb
end

function PetManagementUtils.setListButtonDelegateTable(t, owner)
	PetManagementUtils.delegateTable = t
	PetManagementUtils.delegateOwner = owner
end

function PetManagementUtils.refreshPetList(selectedIndex)
	PetManagementUtils._refreshPetList(selectedIndex)
end

function PetManagementUtils.tryAddCachePetsByBoxId(selectBoxId, petInfos, type)
	if not type then
		return
	end
end

function PetManagementUtils._hasPetListContext()
	if PetManagementUtils.inFilterMode then
		return PetManagementUtils.boxPetFilterList ~= nil
	end

	return PetManagementUtils.boxPetNewListContainers ~= nil
end

function PetManagementUtils._hasMidPanelContext()
	return PetManagementUtils.boxSelector ~= nil and PetManagementUtils._hasPetListContext()
end

function PetManagementUtils._hasInfoPanelContext()
	return PetManagementUtils.rightPanelUComponent ~= nil and PetManagementUtils.attributeBtn ~= nil and PetManagementUtils.skillBtn ~= nil and PetManagementUtils.infoBtn ~= nil and PetManagementUtils.panelAbilityUContainer ~= nil and PetManagementUtils.panelSkillUContainer ~= nil and PetManagementUtils.panelInfoUContainer ~= nil
end

function PetManagementUtils.hasTemplateContext(owner)
	if owner ~= nil and not PetManagementUtils.isContextOwner(owner) then
		return false
	end

	if owner ~= nil and PetManagementUtils.delegateOwner ~= owner then
		return false
	end

	return PetManagementUtils.hasAnyTemplateContext()
end

function PetManagementUtils.hasAnyTemplateContext()
	return PetManagementUtils.delegateTable ~= nil and PetManagementUtils._hasInfoPanelContext() and PetManagementUtils._hasMidPanelContext()
end

function PetManagementUtils.hasOtherTemplateContext(owner)
	return PetManagementUtils.contextOwner ~= owner and PetManagementUtils.hasAnyTemplateContext()
end

function PetManagementUtils._restoreContextIfNeeded(owner, contextRestoreCb)
	if owner == nil then
		return
	end

	if PetManagementUtils.hasTemplateContext(owner) then
		return
	end

	if PetManagementUtils.hasOtherTemplateContext(owner) then
		return
	end

	if contextRestoreCb then
		contextRestoreCb()
	end
end

function PetManagementUtils._captureContextRestorer()
	local owner = PetManagementUtils.contextOwner
	local contextRestoreCb = PetManagementUtils.param and PetManagementUtils.param.contextRestoreCb

	return function()
		PetManagementUtils._restoreContextIfNeeded(owner, contextRestoreCb)
	end
end

function PetManagementUtils._refreshPetList()
	if not PetManagementUtils._hasPetListContext() then
		return
	end

	PetManagementUtils.inFightPetInfos = PetManagementDataHelper.getGroupInfoById(PetManagementDataHelper.getSelectGroupId())

	local selectBoxId = PetManagementDataHelper.getSelectBoxId()
	local petInfos

	if PetManagementUtils.inFilterMode then
		petInfos = PetManagementDataHelper.getFilteredPetsInfo()
	else
		petInfos = PetManagementDataHelper.getBoxInfoById(selectBoxId)
	end

	PetManagementUtils.petInfos = petInfos

	local ctrlConfig = PetManagementUtils.param and PetManagementUtils.param.ctrlConfig or {}
	local isForbidUBtnDrag = ctrlConfig.isForbidUBtnDrag or false

	if PetManagementUtils.inFilterMode then
		function PetManagementUtils.boxPetFilterList.luaFinishRender(_)
			if PetManagementUtils.selectSlot then
				PetManagementUtils._refreshPetSelectedStatus(PetManagementUtils.selectSlot)
			end

			if PetManagementUtils.onFilterListRenderFinished then
				PetManagementUtils.onFilterListRenderFinished()
			end
		end

		PetManagementUtils.boxPetFilterList:SetList(petInfos)
	else
		local isHome = PetManagementUtils.displayType == UIConst.PET_SLOT_DISPLAY_TYPE.Homeland

		for i = 0, #PetManagementUtils.boxPetNewListContainers do
			local data = petInfos[i + 1]
			local isShowEmpty = PetManagementUtils._isShowHeadPetEmpty(data.id, data.isEmpty)

			if isShowEmpty then
				PetManagementUtils.boxPetNewListContainers[i].url = AddressDataConst.PET_EMPTY_SLOT
			elseif isHome then
				PetManagementUtils.boxPetNewListContainers[i].url = AddressDataConst.PET_HOME_MANAGE_SLOT
			else
				PetManagementUtils.boxPetNewListContainers[i].url = AddressDataConst.PET_NORMAL_SLOT
			end

			local uBtn = PetManagementUtils.boxPetNewListContainers[i].content:GetComponent("UButton")

			if isHome then
				PetManagementUtils._setHomeBoxPetListData(uBtn, i, data)
			else
				PetManagementUtils._setBoxPetListData(uBtn, i, data)
			end

			uBtn.dataFromUList = data

			if isForbidUBtnDrag then
				uBtn.draggable = false
			end
		end

		if PetManagementUtils.selectSlot then
			PetManagementUtils._refreshPetSelectedStatus(PetManagementUtils.selectSlot)
		end

		if PetManagementUtils.onNormalListRenderFinished then
			PetManagementUtils.onNormalListRenderFinished()
		end
	end
end

function PetManagementUtils.setSelectedPet(index, isMultiSelect)
	PetManagementUtils._refreshPetSelectedStatus(index, isMultiSelect)
end

function PetManagementUtils._isShowHeadPetEmpty(petId, isRealEmpty)
	return isRealEmpty
end

function PetManagementUtils._setHomeBoxPetListData(button, index, data)
	button.name = index + 1
	button.enabledTooltip = false

	local restoreContext = PetManagementUtils._captureContextRestorer()

	function button.luaPress()
		restoreContext()

		local needRefresh = true

		if PetManagementUtils.delegateTable and PetManagementUtils.delegateTable.luaPress then
			needRefresh = PetManagementUtils.delegateTable.luaPress(button, index, data) ~= false
		end

		if needRefresh then
			PetManagementUtils._refreshPetSelectedStatus(index)
		end
	end

	local isShowEmpty = PetManagementUtils._isShowHeadPetEmpty(data.id, data.isEmpty)

	if isShowEmpty then
		button.draggable = false

		return
	end

	function button.luaClick()
		restoreContext()

		if PetManagementUtils.delegateTable and PetManagementUtils.delegateTable.luaClick then
			PetManagementUtils.delegateTable.luaClick(button, index, data)
		end
	end

	function button.luaHover()
		restoreContext()

		if PetManagementUtils.delegateTable and PetManagementUtils.delegateTable.luaHover then
			PetManagementUtils.delegateTable.luaHover(button, index, data)
		end
	end

	function button.luaUnhover()
		restoreContext()

		if PetManagementUtils.delegateTable and PetManagementUtils.delegateTable.luaUnhover then
			PetManagementUtils.delegateTable.luaUnhover(button, index, data)
		end
	end

	function button.luaTryChangePage(name, pageIdx, lastPageIdx)
		restoreContext()

		if PetManagementUtils.delegateTable and PetManagementUtils.delegateTable.luaTryChangePage then
			PetManagementUtils.delegateTable.luaTryChangePage(name, pageIdx, lastPageIdx)
		end
	end

	function button.luaEnterDropWidget(target)
		restoreContext()

		if PetManagementUtils.delegateTable and PetManagementUtils.delegateTable.luaEnterDropWidget then
			PetManagementUtils.delegateTable.luaEnterDropWidget(data, target)
		end
	end

	function button.luaExitDropWidget()
		restoreContext()

		if PetManagementUtils.delegateTable and PetManagementUtils.delegateTable.luaExitDropWidget then
			PetManagementUtils.delegateTable.luaExitDropWidget()
		end
	end

	button.dynamicUpdateDropWidget = PetManagementUtils.dynamicUpdateDropWidget

	local getShowAppearanceTags = PetManagementUtils.delegateTable and PetManagementUtils.delegateTable.getShowAppearanceTags

	LuaUIUtils.renderHomePetHead(button, data, nil, {
		showAppearanceTags = getShowAppearanceTags and getShowAppearanceTags() or false
	})

	local objectReference = button:GetComponent("ObjectReference")
	local txtUsedUSDFText = objectReference:GetRefValue("txtUsedUSDFText")
	local showInGamePlayBattle = pg.game.petManage:getPetIsInGamePlayBattle(data.id)

	button:TryChangePage("state", showInGamePlayBattle and 1 or 0)

	if txtUsedUSDFText then
		txtUsedUSDFText:SetActive(showInGamePlayBattle)

		if showInGamePlayBattle then
			ClientTextUtils.setText(txtUsedUSDFText, pg.getGameString("NOT_CAN_REALSE_INBATTLE"))
		end
	end

	button.draggable = not showInGamePlayBattle

	function button.luaBeginDrag()
		restoreContext()

		PetManagementUtils.isPetBoxDragging = true

		if PetManagementUtils.delegateTable and PetManagementUtils.delegateTable.luaBeginDrag then
			PetManagementUtils.delegateTable.luaBeginDrag(button, index, data)
		end
	end

	function button.luaDrag(pointerPosition)
		restoreContext()

		if PetManagementUtils.delegateTable and PetManagementUtils.delegateTable.luaDrag then
			PetManagementUtils.delegateTable.luaDrag(data, pointerPosition)
		end
	end

	function button.luaEndDrag(dropWidget, rayBox, pointerPosition)
		PetManagementUtils.isPetBoxDragging = false

		restoreContext()

		if PetManagementUtils.delegateTable and PetManagementUtils.delegateTable.luaEndDrag then
			PetManagementUtils.delegateTable.luaEndDrag(button, dropWidget, rayBox, data, pointerPosition)
		end
	end

	local battleNum = -1

	for i, v in pairs(PetManagementUtils.inFightPetInfos) do
		if v.id == data.id then
			battleNum = i - 1

			break
		end
	end

	if PetManagementUtils.delegateTable and PetManagementUtils.delegateTable.renderExtraLogic then
		PetManagementUtils.delegateTable.renderExtraLogic(button, index, data)
	end
end

function PetManagementUtils._setBoxPetListData(button, index, data)
	button.name = index + 1
	button.dataFromUList = data
	button.enabledTooltip = false

	local restoreContext = PetManagementUtils._captureContextRestorer()

	function button.luaPress()
		restoreContext()

		local needRefresh = true

		if PetManagementUtils.delegateTable and PetManagementUtils.delegateTable.luaPress then
			needRefresh = PetManagementUtils.delegateTable.luaPress(button, index, data) ~= false
		end

		if needRefresh then
			PetManagementUtils._refreshPetSelectedStatus(index, nil, button, data)
		end
	end

	local isShowEmpty = PetManagementUtils._isShowHeadPetEmpty(data.id, data.isEmpty)

	if isShowEmpty then
		button.draggable = false

		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local battleNumUContainer = objectReference:GetRefValue("battleNumUContainer")
	local listCharUContainer = objectReference:GetRefValue("listCharUContainer")

	listCharUContainer:LoadDefaultUrlManually()

	local exploreSkillEquipped = listCharUContainer.content:GetComponent("UList")

	function button.luaClick()
		restoreContext()

		if PetManagementUtils.delegateTable and PetManagementUtils.delegateTable.luaClick then
			PetManagementUtils.delegateTable.luaClick(button, index, data)
		end
	end

	function button.luaHover()
		restoreContext()

		if PetManagementUtils.delegateTable and PetManagementUtils.delegateTable.luaHover then
			PetManagementUtils.delegateTable.luaHover(button, index, data)
		end
	end

	function button.luaUnhover()
		restoreContext()

		if PetManagementUtils.delegateTable and PetManagementUtils.delegateTable.luaUnhover then
			PetManagementUtils.delegateTable.luaUnhover(button, index, data)
		end
	end

	function button.luaTryChangePage(name, pageIdx, lastPageIdx)
		restoreContext()

		if PetManagementUtils.delegateTable and PetManagementUtils.delegateTable.luaTryChangePage then
			PetManagementUtils.delegateTable.luaTryChangePage(name, pageIdx, lastPageIdx)
		end
	end

	LuaUIUtils.renderPetHead(button, data)
	button:TryChangePage("isBoss", 0)

	if data.id and data.id == PetManagementUtils.curSelectPetId then
		button:TryChangePage("button", 5)

		button.isSelected = true
	else
		button:TryChangePage("button", 0)

		button.isSelected = false
	end

	button.draggable = true

	PetManagementUtils._showFilterLabel(button, data)

	function button.luaBeginDrag()
		restoreContext()

		PetManagementUtils.isPetBoxDragging = true

		local numCPUText = button.replicaWidget.gameObject:GetComponent("ObjectReference"):GetRefValue("numCPUSDFText")
		local pet = pg.me:getPetInfo(data.id)

		if pet and pet:isCatchReporting() then
			ClientTextUtils.setText(numCPUText, "???")
		else
			ClientTextUtils.setText(numCPUText, data.cp or "")
		end

		if PetManagementUtils.delegateTable and PetManagementUtils.delegateTable.luaBeginDrag then
			PetManagementUtils.delegateTable.luaBeginDrag(button, index, data)
		end
	end

	function button.luaDrag(pointerPosition)
		restoreContext()

		if PetManagementUtils.delegateTable and PetManagementUtils.delegateTable.luaDrag then
			PetManagementUtils.delegateTable.luaDrag(data, pointerPosition)
		end
	end

	function button.luaEndDrag(dropWidget, rayBox, pointerPosition)
		PetManagementUtils.isPetBoxDragging = false

		restoreContext()

		if PetManagementUtils.delegateTable and PetManagementUtils.delegateTable.luaEndDrag then
			PetManagementUtils.delegateTable.luaEndDrag(button, dropWidget, rayBox, data, pointerPosition)
		end
	end

	function exploreSkillEquipped.luaRenderItem(b, _, d)
		b:TryChangePage("Char", d.index - 1)
		b:TryChangePage("Quality", d.quality)
	end

	local explorePets = PetManagementDataHelper.getExploreGroupInfo()
	local exploreIndexes = {}

	for k, v in pairs(explorePets) do
		if v.id == data.id then
			exploreIndexes[#exploreIndexes + 1] = {
				index = k,
				quality = data.exploreSkillIndexLevel[k]
			}
		end
	end

	if #exploreIndexes <= 0 then
		exploreSkillEquipped.gameObject:SetActiveEx(false)
	else
		exploreSkillEquipped.gameObject:SetActiveEx(true)
		exploreSkillEquipped:SetList(exploreIndexes)
	end

	local battleNum = -1

	for i, v in pairs(PetManagementUtils.inFightPetInfos) do
		if v.id == data.id then
			battleNum = i - 1

			break
		end
	end

	if battleNum == -1 then
		if battleNumUContainer:CheckURLLoaded() then
			battleNumUContainer:DestroyContent()
		end
	elseif battleNumUContainer:CheckURLLoaded() then
		battleNumUContainer.content:TryChangePage("number", battleNum)
	else
		battleNumUContainer:LoadDefaultUrlManually(function(widget)
			widget:TryChangePage("number", battleNum)
		end)
	end

	if PetManagementUtils.delegateTable and PetManagementUtils.delegateTable.renderExtraLogic then
		PetManagementUtils.delegateTable.renderExtraLogic(button, index, data)
	end
end

function PetManagementUtils.clearBatchSelect()
	local buttons, lastIndex
	local petInfos = PetManagementUtils.petInfos

	buttons, lastIndex = PetManagementUtils._getPetListButtons()

	if not buttons or not petInfos then
		return
	end

	for i = 0, lastIndex do
		local isEmpty = petInfos[i + 1].isEmpty
		local uBtn = buttons[i]

		uBtn.draggable = not isEmpty
		uBtn.isSelected = false

		uBtn:TryChangePage("Batch", 0)
	end
end

function PetManagementUtils._getPetListButtons()
	local buttons, lastIndex

	if PetManagementUtils.inFilterMode then
		if not PetManagementUtils.boxPetFilterList then
			return
		end

		buttons = PetManagementUtils.boxPetFilterList:GetAllButtons()

		if not buttons or buttons.Length <= 0 then
			return
		end

		lastIndex = buttons.Length - 1
	else
		if not PetManagementUtils.boxPetNewListContainers then
			return
		end

		buttons = {}

		for i = 0, #PetManagementUtils.boxPetNewListContainers do
			local container = PetManagementUtils.boxPetNewListContainers[i]

			if not container or not container.content then
				return
			end

			buttons[i] = container.content:GetComponent("UButton")
		end

		lastIndex = #buttons
	end

	return buttons, lastIndex
end

function PetManagementUtils._refreshPetSelectedStatus(index, isMultiSelect, selectedButton, selectedData)
	local findIndex, buttons, lastIndex

	buttons, lastIndex = PetManagementUtils._getPetListButtons()

	if not buttons then
		return
	end

	if isMultiSelect ~= nil then
		local targetButton = selectedButton

		if not targetButton and PetManagementUtils.inFilterMode and index ~= nil then
			local _, btn = PetManagementUtils.boxPetFilterList:TryGetChildAt(index)

			targetButton = btn
		end

		targetButton = targetButton or buttons[index]

		if not targetButton then
			return
		end

		if isMultiSelect then
			targetButton:TryChangePage("Batch", 1)
		else
			targetButton:TryChangePage("Batch", 0)
		end
	else
		local selectData = selectedData
		local selectButton = selectedButton

		if PetManagementUtils.inFilterMode and selectData == nil and index ~= nil then
			selectData = PetManagementUtils.petInfos and PetManagementUtils.petInfos[index + 1]

			local _, btn = PetManagementUtils.boxPetFilterList:TryGetChildAt(index)

			selectButton = btn
		end

		for i = 0, lastIndex do
			buttons[i]:TryChangePage("button", 0)

			local isTarget

			if selectButton then
				isTarget = buttons[i] == selectButton
			elseif index ~= nil then
				isTarget = i == index
			end

			if isTarget then
				buttons[i].isSelected = true
				PetManagementUtils.selectedBtn = buttons[i]
				findIndex = i
			else
				buttons[i].isSelected = false
			end
		end

		local sData = selectData

		if not sData and findIndex and buttons[findIndex] then
			sData = buttons[findIndex].dataFromUList
		end

		if not sData then
			return
		end

		if not PetManagementUtils.onlyRenderMidPanel then
			PetManagementUtils._refreshPetInfoDetail(sData)
		end

		PetManagementUtils.curSelectPetId = sData.id

		if PetManagementUtils.delegateTable and PetManagementUtils.delegateTable.selectedChanged then
			local selectedBtn = selectButton or findIndex and buttons[findIndex]

			PetManagementUtils.delegateTable.selectedChanged(sData, selectedBtn)
		end
	end
end

function PetManagementUtils._refreshBoxSelector()
	if not PetManagementUtils.boxSelector then
		return
	end

	local petBoxMap = pg.me.petBoxMap
	local boxInfos = PetManagementDataHelper.getBoxInfos()
	local selectBoxId = PetManagementDataHelper.getSelectBoxId()
	local objRef = PetManagementUtils.boxSelector:GetComponent("ObjectReference")
	local boxName = objRef:GetRefValue("boxName")
	local lockUButton = objRef:GetRefValue("lockUButton")
	local txtNameUText = objRef:GetRefValue("txtNameUText")
	local customName = petBoxMap[selectBoxId].customName
	local count = petBoxMap[selectBoxId].count
	local slotCount = petBoxMap[selectBoxId].slotCount
	local lockStatus = petBoxMap[selectBoxId]:isLocked()
	local isHideLockIcon = PetManagementUtils.isHidePetBoxEditorLockIcon
	local countStr = string.format("(%d/%d)", count, slotCount)
	local boxNameContent = ""

	if customName and customName ~= "" then
		boxNameContent = string.format("%s %s", customName, countStr)
	else
		boxNameContent = string.format("%s %s %s", pg.getGameString("DEFAULT_PET_BOX_NAME"), selectBoxId, countStr)
	end

	ClientTextUtils.setText(boxName, boxNameContent)
	ClientTextUtils.setText(txtNameUText, boxNameContent)

	if isHideLockIcon then
		lockUButton:SetActive(false)

		lockUButton.luaClick = nil
	else
		lockUButton:SetActive(true)
		lockUButton:TryChangePage("Lock", lockStatus and 1 or 0)

		function lockUButton.luaClick()
			PetManagementUtils._boxLockBtnFunction(selectBoxId, true)
		end
	end

	PetManagementDataHelper.setBoxSelectorLuaRenderPopup(PetManagementUtils.boxSelector, {
		boxInfos = boxInfos,
		boxNameContent = boxNameContent,
		selectBoxId = selectBoxId,
		isHideLockIcon = isHideLockIcon and true or false,
		onRenderPopup = function(_, list)
			PetManagementUtils.boxSelectorTempList = list
		end,
		renderItemLockState = function(_, lockUButton1, boxIdx)
			lockUButton1:TryChangePage("Lock", petBoxMap[boxIdx]:isLocked() and 1 or 0)
		end,
		onSelectBox = function(boxIdx)
			PetManagementUtils._switchBoxToIdx(boxIdx)
		end,
		onLockBox = function(boxIdx)
			PetManagementUtils._boxLockBtnFunction(boxIdx)
		end,
		onRenameBox = function(boxIdx)
			PetManagementUtils.boxSelector:ClosePopup()
			PetManagementDataHelper.showRename(boxIdx, PetManagementDataHelper.RENAME_FOR_BOX)
		end
	})
	PetManagementUtils.boxSelector:SetOptions(boxInfos)

	if PetManagementUtils.boxSelector.isPopup then
		PetManagementUtils._refreshLockStatusWhenPopup()
	end
end

function PetManagementUtils._refreshSingleBoxSelectorItemName(index, newName)
	local popupInst = PetManagementUtils.boxSelector:GetPopupInstance()
	local objectReference = popupInst:GetComponent("ObjectReference")
	local listUList = objectReference:GetRefValue("listUList")
	local _, btn = listUList:TryGetChildAt(index - 1)
	local objectReference1 = btn:GetComponent("ObjectReference")
	local nameUText = objectReference1:GetRefValue("nameUText")

	ClientTextUtils.setText(nameUText, newName)
end

function PetManagementUtils._boxLockBtnFunction(boxId, ignorePopup)
	local boxPetInfo = pg.me.petBoxMap[boxId]

	local function popupFunc()
		local hintShowTs = pg.global.prefsCacheUtils:getInt("boxLockHintHideFlagTs", 0, ClientConst.CACHE_TYPE_FLAG.USER)

		if hintShowTs + 86400 <= Time.secondCache then
			if not ignorePopup then
				PetManagementUtils.boxSelector:InteractPopup(false)
			end

			pg.global.showConfirmMsgRaw(pg.getGameString("LOCK_BOX"), pg.getGameString("LOCK_BOX_TIPS"), function()
				pg.me:serverMsg("RPC_CS_PetBoxSwitchLocked", boxId, not boxPetInfo:isManualLocked())

				if not ignorePopup then
					PetManagementUtils.boxSelector:InteractPopup(true)
				end

				if PetManagementUtils.boxLockHintHideFlag then
					pg.global.prefsCacheUtils:setInt("boxLockHintHideFlagTs", Time.secondCache, ClientConst.CACHE_TYPE_FLAG.USER)
					pg.global.prefsCacheUtils:save()
				end
			end, nil, function()
				if not ignorePopup then
					PetManagementUtils.boxSelector:InteractPopup(true)
				end
			end, nil, nil, {
				hint = true,
				hintDesc = string.format(pg.getGameString("DISABLE_HINT"), 1),
				hintCb = function(isSelected)
					if isSelected then
						PetManagementUtils.boxLockHintHideFlag = true
					else
						PetManagementUtils.boxLockHintHideFlag = nil
					end
				end
			})
		else
			pg.me:serverMsg("RPC_CS_PetBoxSwitchLocked", boxId, not boxPetInfo:isManualLocked())
		end
	end

	PetManagementDataHelper.sendSwitchPetBoxManualLocked(boxId, popupFunc)
end

function PetManagementUtils._refreshLockStatusWhenPopup()
	if PetManagementUtils.boxSelectorTempList == nil then
		return
	end

	local petBoxMap = pg.me.petBoxMap
	local btns = PetManagementUtils.boxSelectorTempList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		local objectReference = btns[i]:GetComponent("ObjectReference")
		local lockUButton1 = objectReference:GetRefValue("lockUButton1")

		lockUButton1:TryChangePage("Lock", petBoxMap[btns[i].dataFromUList.idx]:isLocked() and 1 or 0)
	end
end

function PetManagementUtils._switchBoxToIdx(index)
	if not PetManagementUtils._hasMidPanelContext() then
		return
	end

	PetManagementUtils.selectSlot = nil

	PetManagementDataHelper.setSelectBoxId(index)
	PetManagementUtils._onBoxMapSequenceChanged()
	PetManagementUtils.boxSelector:ClosePopup()
end

function PetManagementUtils._getIndexOfSelectedBoxIdInSequence()
	local petBoxMapSequence = pg.me.petBoxMap.sequence:getRawTable()
	local boxId = PetManagementDataHelper.getSelectBoxId()
	local indexOfSequence

	for i = 1, #petBoxMapSequence do
		if boxId == petBoxMapSequence[i] then
			indexOfSequence = i

			return petBoxMapSequence, indexOfSequence
		end
	end

	return petBoxMapSequence, indexOfSequence
end

function PetManagementUtils._switchBoxPages(isPre)
	if PetManagementUtils.inFilterMode then
		return
	end

	if not PetManagementUtils._hasMidPanelContext() then
		return
	end

	local sequence, indexOfSequence = PetManagementUtils._getIndexOfSelectedBoxIdInSequence()

	if not indexOfSequence then
		return
	end

	local index = isPre and indexOfSequence - 1 or indexOfSequence + 1

	if index < 1 then
		index = #sequence
	end

	if index > #sequence then
		index = 1
	end

	PetManagementUtils._switchBoxToIdx(sequence[index])
end

function PetManagementUtils._isPetBoxDragging()
	if PetManagementUtils.isPetBoxDragging then
		return true
	end

	if pg and pg.global and pg.global.navMgr and pg.global.navMgr.IsDragging then
		return true
	end

	if CS and CS.XGUI and CS.XGUI.UComponent then
		local draggingWidget = CS.XGUI.UComponent.draggingWidget

		if draggingWidget ~= nil and (IsNil == nil or not IsNil(draggingWidget)) then
			return true
		end
	end

	return false
end

function PetManagementUtils._onPerformPetBoxScroll(inputInfo, restoreContext)
	if pg and pg.game and pg.game.input and pg.game.input.isUsingGamepad and pg.game.input:isUsingGamepad() then
		return true
	end

	if PetManagementUtils._isPetBoxDragging() then
		return true
	end

	if PetManagementUtils.inFilterMode then
		return true
	end

	if PetManagementUtils.boxSelector and PetManagementUtils.boxSelector.isPopup then
		return true
	end

	local isPre = PetManagementDataHelper.getSwitchBoxPageIsPre(inputInfo and inputInfo.valueVec2 and inputInfo.valueVec2.y)

	if isPre == nil then
		return true
	end

	if restoreContext then
		restoreContext()
	end

	PetManagementUtils._switchBoxPages(isPre)

	return false
end

function PetManagementUtils._onBoxMapSequenceChanged()
	PetManagementUtils._refreshPetList()
	PetManagementUtils._refreshBoxSelector()
end

function PetManagementUtils._refreshSingleCardFavoriteState(petId, show)
	local btns, lastIndex

	btns, lastIndex = PetManagementUtils._getPetListButtons()

	if not btns then
		return
	end

	for i = 0, lastIndex do
		if not btns[i].dataFromUList.isEmpty then
			local objectReference = btns[i]:GetComponent("ObjectReference")
			local iconFavUContainer = objectReference:GetRefValue("iconFavUContainer")
			local petIdDisplay = objectReference:GetRefValue("petIdDisplay")

			if petIdDisplay.gameObject.name == petId then
				if show then
					iconFavUContainer.content.gameObject:SetActiveEx(true)
					iconFavUContainer.content:InvokeCallback(CS.XGUI.EInvokeTime.User2)
				else
					iconFavUContainer.content:InvokeCallback(CS.XGUI.EInvokeTime.User1)
				end
			end
		end
	end
end

function PetManagementUtils.getCurFilterType()
	return PetManagementUtils.displayType or UIConst.PET_SLOT_DISPLAY_TYPE.Normal
end

function PetManagementUtils.isHomelandFilter()
	local curType = PetManagementUtils.getCurFilterType()

	return curType == UIConst.PET_SLOT_DISPLAY_TYPE.Homeland
end

function PetManagementUtils._openFilterPanel()
	pg.global.ui:open(UIConst.UI_ID_PET_MANAGEMENT_FILTER, {
		filterType = PetManagementUtils.getCurFilterType(),
		sortId = PetManagementDataHelper.getSelectSortId(),
		isDescending = PetManagementDataHelper.getSortSwitchStatus(),
		filter = PetManagementDataHelper.filter,
		doFilterCallback = function(filter, sortId, isDescending, showLabelInfo)
			PetManagementDataHelper.showLabelInfo = showLabelInfo
			PetManagementDataHelper.selectSortId = sortId
			PetManagementDataHelper.isDescending = isDescending

			PetManagementDataHelper.setFilter(filter)
			PetManagementUtils._startFilter()
		end
	})
	PetManagementUtils.boxSelector:ClosePopup()
end

function PetManagementUtils._startFilter(forceHideNormalFilter)
	local petInfos = PetManagementDataHelper.getFilteredPetsInfo()

	if #petInfos <= 0 then
		pg.global.showBubbleMessageRaw(pg.getGameString("EMPTY_FILTER"))
		PetManagementUtils._endFilter()

		return
	end

	PetManagementUtils.inFilterMode = true

	PetManagementUtils._refreshPetList()
	PetManagementUtils._refreshBoxSelector()
	PetManagementUtils.midPanelUComponent:TryChangePage("State", 1)

	local timers = PetManagementUtils.m_filterTimers or {}

	if timers.endFilterTimer then
		TimerManager.removeTimer(timers.endFilterTimer)

		timers.endFilterTimer = nil
	end

	timers.endFilterTimer = TimerManager.addTimer(0.05, function()
		if NotNil(PetManagementUtils.boxPbFilter2Go) then
			PetManagementUtils.boxPbFilter2Go:SetActiveEx(not forceHideNormalFilter)
		end
	end)
	PetManagementUtils.m_filterTimers = timers
end

function PetManagementUtils._endFilter()
	PetManagementDataHelper.selectSortId = 0

	PetManagementDataHelper.setFilter({})

	PetManagementUtils.inFilterMode = false

	PetManagementUtils._refreshPetList()
	PetManagementUtils._refreshBoxSelector()
	PetManagementUtils.midPanelUComponent:TryChangePage("State", 0)
end

function PetManagementUtils.generatePetAttributeRef(button)
	local ret = {}
	local objectReference = button:GetComponent("ObjectReference")
	local hpNum = objectReference:GetRefValue("hpNum")
	local atkNum = objectReference:GetRefValue("atkNum")
	local defNum = objectReference:GetRefValue("defNum")
	local regenNum = objectReference:GetRefValue("regenNum")
	local defMagNum = objectReference:GetRefValue("defMagNum")
	local atkMagNum = objectReference:GetRefValue("atkMagNum")

	ret.propNumGroup = {
		hpNum,
		atkNum,
		defNum,
		regenNum,
		defMagNum,
		atkMagNum
	}

	local hpCmp = objectReference:GetRefValue("hpCmp")
	local atkCmp = objectReference:GetRefValue("atkCmp")
	local defCmp = objectReference:GetRefValue("defCmp")
	local regenCmp = objectReference:GetRefValue("regenCmp")
	local defMagCmp = objectReference:GetRefValue("defMagCmp")
	local atkMagCmp = objectReference:GetRefValue("atkMagCmp")

	ret.propCmpGroup = {
		hpCmp,
		atkCmp,
		defCmp,
		regenCmp,
		defMagCmp,
		atkMagCmp
	}

	local hpLevelCmp = objectReference:GetRefValue("hpLevelCmp")
	local atkLevelCmp = objectReference:GetRefValue("atkLevelCmp")
	local defLevelCmp = objectReference:GetRefValue("defLevelCmp")
	local regenLevelCmp = objectReference:GetRefValue("regenLevelCmp")
	local defMagLevelCmp = objectReference:GetRefValue("defMagLevelCmp")
	local atkMagLevelCmp = objectReference:GetRefValue("atkMagLevelCmp")

	ret.propLevelCmpGroup = {
		hpLevelCmp,
		atkLevelCmp,
		defLevelCmp,
		regenLevelCmp,
		defMagLevelCmp,
		atkMagLevelCmp
	}

	local hpLv = objectReference:GetRefValue("hpLv")
	local atkLv = objectReference:GetRefValue("atkLv")
	local defLv = objectReference:GetRefValue("defLv")
	local regenLv = objectReference:GetRefValue("regenLv")
	local defMagLv = objectReference:GetRefValue("defMagLv")
	local atkMagLv = objectReference:GetRefValue("atkMagLv")

	ret.propLevelGroup = {
		hpLv,
		atkLv,
		defLv,
		regenLv,
		defMagLv,
		atkMagLv
	}

	local hpUpUBaseText = objectReference:GetRefValue("hpUpUBaseText")
	local atkUpUBaseText = objectReference:GetRefValue("atkUpUBaseText")
	local defUpUBaseText = objectReference:GetRefValue("defUpUBaseText")
	local regenUpUBaseText = objectReference:GetRefValue("regenUpUBaseText")
	local defMsgUpUBaseText = objectReference:GetRefValue("defMsgUpUBaseText")
	local atkMsgUpUBaseText = objectReference:GetRefValue("atkMsgUpUBaseText")

	ret.propNumUpGroup = {
		hpUpUBaseText,
		atkUpUBaseText,
		defUpUBaseText,
		regenUpUBaseText,
		defMsgUpUBaseText,
		atkMsgUpUBaseText
	}
	ret.defaultRadar = objectReference:GetRefValue("defaultRadar")
	ret.addedRadar = objectReference:GetRefValue("addedRadar")
	ret.btnDetailUButton = objectReference:GetRefValue("btnDetailUButton")

	return ret
end

function PetManagementUtils.renderPetAttribute(pet, button, individualPropUpMap, individualLevelUpMap, extraInfo)
	PetManagementUtils.renderPetAttributeInner(pet, PetManagementUtils.generatePetAttributeRef(button), individualPropUpMap, individualLevelUpMap, extraInfo)
end

function PetManagementUtils.clearPetAttributeTimer()
	if PetManagementUtils.propLevelUpTimer then
		for _, timer in pairs(PetManagementUtils.propLevelUpTimer) do
			TimerManager.removeTimer(timer)
		end
	end
end

function PetManagementUtils.handleAttributeTimer(index)
	if PetManagementUtils.propLevelUpTimer == nil then
		PetManagementUtils.propLevelUpTimer = {}
	end

	if PetManagementUtils.propLevelUpTimer[index] then
		TimerManager.removeTimer(PetManagementUtils.propLevelUpTimer[index])
	end
end

function PetManagementUtils.renderPetAttributeInner(petInfo, refContainer, individualPropUpMap, individualLevelUpMap, extraInfo)
	if petInfo == nil then
		return
	end

	if not refContainer.propNumGroup then
		return
	end

	local baseProperty = petInfo.basePropertyList
	local propertyEnhanced = Utils.isPetPropertyEnhanced(petInfo)
	local templateId = petInfo.templateId
	local petData = PetData[templateId]
	local recommend = petData.recommend_attr
	local propLevels = pg.game.petManage:getPetPropLevels(petInfo)
	local isHideVx = extraInfo and extraInfo.isHideVx or false

	PetManagementUtils.defaultRatioGroup = {}
	PetManagementUtils.addedRatioGroup = {}

	local isTrained = 0

	for i = Const.BASE_PROPERTY_HP_IDX, Const.BASE_PROPERTY_ATK_MAG_IDX do
		local propLevelInfo = propLevels[i]
		local baseAndLearnMax = propLevelInfo.max or 1
		local displayBaseLevel = propLevelInfo.complexBaseLv or 0
		local baseAndActiveTotalLv = propLevelInfo.baseAndActiveTotalLv or 0
		local displayLearnLevel = propLevelInfo.learnt or 0
		local displayValue = baseProperty[i].displayValue
		local petManagementDisplayValue = propLevelInfo.propDisplayVal
		local legacyDisplayValue = displayValue ~= nil and displayValue or petManagementDisplayValue
		local totalValue = extraInfo and extraInfo.usePetManagementDisplayValue and math.ceil(petManagementDisplayValue) or math.floor(legacyDisplayValue)

		if refContainer.propNumUpGroup and individualPropUpMap and individualPropUpMap[i] then
			local increaseValue = math.floor(individualPropUpMap[i] or 0)
			local oldValue = totalValue - increaseValue

			ClientTextUtils.setText(refContainer.propNumGroup[i], math.max(oldValue, 0))

			if increaseValue > 0 then
				local curIndex = i + 10

				PetManagementUtils.handleAttributeTimer(curIndex)
				ClientTextUtils.setText(refContainer.propNumUpGroup[i], "+" .. increaseValue)

				PetManagementUtils.propLevelUpTimer[curIndex] = TimerManager.addTimer(1, function()
					PetManagementUtils.propLevelUpTimer[curIndex] = nil

					refContainer.propCmpGroup[curIndex - 10]:InvokeCallback(CS.XGUI.EInvokeTime.User1)
				end)
			end
		else
			ClientTextUtils.setText(refContainer.propNumGroup[i], totalValue)
		end

		if individualLevelUpMap and individualLevelUpMap[i] then
			local totalValue = baseAndActiveTotalLv
			local increaceValue = individualLevelUpMap[i]
			local oldValue = totalValue - increaceValue

			ClientTextUtils.setText(refContainer.propLevelGroup[i], oldValue)
			PetManagementUtils.handleAttributeTimer(i)

			local curIndex = i

			PetManagementUtils.propLevelUpTimer[curIndex] = TimerManager.addTimer(1, function()
				PetManagementUtils.propLevelUpTimer[curIndex] = nil

				refContainer.propLevelCmpGroup[curIndex]:InvokeCallback(CS.XGUI.EInvokeTime.User1)
				ClientTextUtils.setText(refContainer.propLevelGroup[curIndex], baseProperty[curIndex].indLv or 0)
			end)
		else
			ClientTextUtils.setText(refContainer.propLevelGroup[i], baseAndActiveTotalLv)
		end

		refContainer.propCmpGroup[i].luaTooltipPopup = function(_, flag)
			refContainer.propCmpGroup[i]:TryChangePage("Selected", flag and 1 or 0)
		end
		refContainer.propCmpGroup[i].luaRenderTooltip = function(_, component)
			PetManagementUtils.customRefreshBuffInfoTooltip(component, PetManagementDataHelper.BuffInfoToolTipType.Cultivate, {
				index = i,
				recommend = recommend,
				propertyEnhanced = propertyEnhanced,
				propLevel = propLevels[i]
			})
		end

		if displayLearnLevel > 0 then
			refContainer.propCmpGroup[i]:TryChangePage("State", 1)
			refContainer.propLevelCmpGroup[i]:TryChangePage("State", 1)
		else
			refContainer.propCmpGroup[i]:TryChangePage("State", 0)
			refContainer.propLevelCmpGroup[i]:TryChangePage("State", 0)
		end

		if LuaUIUtils.tableContains(recommend, i) then
			refContainer.propCmpGroup[i]:TryChangePage("GoodState", 1)
		else
			refContainer.propCmpGroup[i]:TryChangePage("GoodState", 0)
		end

		refContainer.propLevelCmpGroup[i]:TryChangePage("Updated", propertyEnhanced and 1 or 0)

		if propertyEnhanced then
			refContainer.propLevelCmpGroup[i]:TryChangePage("State", 1)
		end

		if baseAndLearnMax <= baseAndActiveTotalLv then
			refContainer.propCmpGroup[i]:TryChangePage("State", 2)
			refContainer.propLevelCmpGroup[i]:TryChangePage("State", 2)
		end

		PetManagementUtils.defaultRatioGroup[i] = displayBaseLevel / baseAndLearnMax
		PetManagementUtils.addedRatioGroup[i] = baseAndActiveTotalLv / baseAndLearnMax

		if displayLearnLevel > 0 then
			isTrained = isTrained + 1
		end

		if NotNil(PetManagementUtils.btnDetailUButton) then
			function PetManagementUtils.btnDetailUButton.luaClick()
				PetManagementUtils._openPropertyPanel(petInfo.id)
			end
		end
	end

	refContainer.defaultRadar:SetSixProps(PetManagementUtils.defaultRatioGroup[Const.BASE_PROPERTY_HP_IDX], PetManagementUtils.defaultRatioGroup[Const.BASE_PROPERTY_ATK_IDX], PetManagementUtils.defaultRatioGroup[Const.BASE_PROPERTY_DEF_IDX], PetManagementUtils.defaultRatioGroup[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX], PetManagementUtils.defaultRatioGroup[Const.BASE_PROPERTY_DEF_MAG_IDX], PetManagementUtils.defaultRatioGroup[Const.BASE_PROPERTY_ATK_MAG_IDX])
	refContainer.addedRadar:SetSixProps(PetManagementUtils.addedRatioGroup[Const.BASE_PROPERTY_HP_IDX], PetManagementUtils.addedRatioGroup[Const.BASE_PROPERTY_ATK_IDX], PetManagementUtils.addedRatioGroup[Const.BASE_PROPERTY_DEF_IDX], PetManagementUtils.addedRatioGroup[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX], PetManagementUtils.addedRatioGroup[Const.BASE_PROPERTY_DEF_MAG_IDX], PetManagementUtils.addedRatioGroup[Const.BASE_PROPERTY_ATK_MAG_IDX])
	refContainer.addedRadar.transform.gameObject:SetActiveEx(isTrained > 0)

	if isHideVx then
		for k, v in pairs(refContainer and refContainer.propCmpGroup or EMPTY_TABLE) do
			local vx = v and v.transform:Find("VX")

			if NotNil(vx) then
				vx:SetLocalScaleEx(0, 0, 0)
			end
		end
	end

	if NotNil(refContainer.btnDetailUButton) then
		function refContainer.btnDetailUButton.luaClick()
			PetManagementUtils._openPropertyPanel(petInfo.id)
		end
	end
end

function PetManagementUtils.renderPetFeature(button, featureInfo, petInfo)
	if featureInfo then
		local objectReference = button:GetComponent("ObjectReference")
		local iconFeatureUImage = objectReference:GetRefValue("iconFeatureUImage")

		button:TryChangePage("IsRare", featureInfo.rare or 0)
		button:TryChangePage("State", 1)

		iconFeatureUImage.url = featureInfo.icon
		button.enabledTooltip = true

		function button.luaTooltipPopup(_, flag)
			button:TryChangePage("Selected", flag and 1 or 0)
		end

		LuaUIUtils.setRenderFeatureToolTips(button, featureInfo, petInfo)
	else
		button.enabledTooltip = false

		button:TryChangePage("IsRare", 0)
		button:TryChangePage("State", 0)
	end
end

function PetManagementUtils.onEvolveClick(petId, petTemplateId, extraInfo)
	local researchContentData = PetResearchContentData[petTemplateId]

	if not researchContentData then
		pg.global.showBubbleMessageRaw(pg.getGameString("TRAINING_NOT_VALID"))

		return
	end

	PetResearchUtils.openBranchSelect(petId, nil, extraInfo)
end

function PetManagementUtils.onPetLvUpClick(petId, iconName, label, directToLevelBreak)
	local petData = pg.me:getPetInfo(petId)

	if petData == nil then
		return
	end

	label = label or petData.label

	local propList = {
		150001,
		150002,
		150003
	}
	local args = {
		title = pg.getGameString("USE_EXP_PROP"),
		petId = petId,
		iconName = iconName,
		label = label
	}

	args.selectList = propList

	function args.confirmCb(itemMap)
		return
	end

	args.directToLevelBreak = directToLevelBreak

	pg.global.ui:open(UIConst.UI_ID_COMMON_SELECT_USE, args)
end

function PetManagementUtils._innerSelectSlot(index)
	local btns = PetManagementUtils._getPetListButtons()

	if not btns or not btns[index - 1] then
		return
	end

	btns[index - 1].luaPress()
end

function PetManagementUtils.selectPet(petId)
	local slot, box = LuaUIUtils.getPetBelongBoxAndSlotId(petId)

	if not slot or not box then
		return
	end

	PetManagementUtils._switchBoxToIdx(box)
	PetManagementUtils._innerSelectSlot(slot)
end

function PetManagementUtils._showFilterLabel(btn, data)
	local sortCondition = PetManagementDataHelper.getSelectSortId()
	local objectReference = btn:GetComponent("ObjectReference")
	local panelCPUContainer = objectReference:GetRefValue("panelCPUContainer")
	local panelCharListUContainer = objectReference:GetRefValue("panelCharListUContainer")
	local txtBoxUImage = objectReference:GetRefValue("txtBoxUImage")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local petQualityUContainer = objectReference:GetRefValue("petQualityUContainer")
	local petRareUContainer = objectReference:GetRefValue("petRareUContainer")
	local petRareNmlUContainer = objectReference:GetRefValue("petRareNmlUContainer")

	if not PetManagementDataHelper.showLabelInfo then
		panelCPUContainer:SetActive(true)

		panelCharListUContainer.renderOpacity = 1
		txtBoxUImage.renderOpacity = 0

		petQualityUContainer:DestroyContent()
		petRareUContainer:DestroyContent()
		petRareNmlUContainer:DestroyContent()

		return
	end

	if PetManagementDataHelper.FILTER_LABEL_TYPE[sortCondition] == 0 then
		panelCPUContainer:SetActive(true)

		panelCharListUContainer.renderOpacity = 1
		txtBoxUImage.renderOpacity = 0

		petQualityUContainer:DestroyContent()
		petRareUContainer:DestroyContent()
		petRareNmlUContainer:DestroyContent()
	elseif PetManagementDataHelper.FILTER_LABEL_TYPE[sortCondition] == 1 then
		panelCPUContainer:SetActive(false)

		panelCharListUContainer.renderOpacity = 0
		txtBoxUImage.renderOpacity = 1

		petQualityUContainer:DestroyContent()
		petRareUContainer:DestroyContent()
		petRareNmlUContainer:DestroyContent()
		txtNameUSDFText:SetActive(true)

		if sortCondition == PetManagementDataHelper.SORT_IDX.TIME then
			local seconds = (Time.secondCache * 1000 - data.time) / 1000

			ClientTextUtils.setText(txtNameUSDFText, TimeUtils.getFormatStringDay(seconds))
		elseif sortCondition == PetManagementDataHelper.SORT_IDX.BOOK_NUM then
			ClientTextUtils.setText(txtNameUSDFText, PetManagementUtils.getDisplayBookNumberText(data))
		elseif sortCondition == PetManagementDataHelper.SORT_IDX.LEVEL then
			ClientTextUtils.setText(txtNameUSDFText, string.format("Lv.%s", data.level))
		else
			ClientTextUtils.setText(txtNameUSDFText, "")

			txtBoxUImage.renderOpacity = 0

			txtNameUSDFText:SetActive(true)
		end
	elseif PetManagementDataHelper.FILTER_LABEL_TYPE[sortCondition] == 2 then
		panelCPUContainer:SetActive(false)

		panelCharListUContainer.renderOpacity = 0
		txtBoxUImage.renderOpacity = 0

		if not data.isCatchReportingStatus then
			petQualityUContainer:LoadDefaultUrlManually()

			local ratingIndex = data.rating or 0

			petQualityUContainer.content:TryChangePage("Quality", ratingIndex)
			TimerManager.addNextFrameCb(function()
				if IsNil(petQualityUContainer) or IsNil(petQualityUContainer.content) then
					return
				end

				local textT = petQualityUContainer.content.transform:Find("Detail/Text")
				local text = textT and textT:GetComponent("USDFText")
				local ratingStr = Const.STAGE_TO_RATING_STR[ratingIndex + 1] or ""

				if NotNil(text) then
					ClientTextUtils.setText(text, pg.getGameString(ratingStr))
				end
			end)
		else
			petQualityUContainer:DestroyContent()
		end

		petRareUContainer:DestroyContent()
		petRareNmlUContainer:DestroyContent()
	else
		panelCPUContainer:SetActive(false)

		panelCharListUContainer.renderOpacity = 0
		txtBoxUImage.renderOpacity = 0

		petQualityUContainer:DestroyContent()

		if data.hasRareFeature == 1 then
			petRareUContainer:LoadDefaultUrlManually()
			petRareNmlUContainer:DestroyContent()
		else
			petRareUContainer:DestroyContent()
			petRareNmlUContainer:LoadDefaultUrlManually()
		end
	end
end

function PetManagementUtils.renderReleaseTips(petInfos, widgetTipsUWidget, txtTipsUSDFText, richTextColor, needCultivation)
	local shinyCount = 0
	local magicCount = 0
	local rainBowCount = 0
	local variantCount = 0
	local bossCount = 0
	local ratingCount = 0
	local rareFeatureCount = 0
	local darkCount = 0
	local cultivationCount = 0

	for _, petInfo in pairs(petInfos) do
		if petInfo.isShiny then
			shinyCount = shinyCount + 1
		end

		if petInfo.isRainbow then
			rainBowCount = rainBowCount + 1
		end

		if petInfo.isDark then
			darkCount = darkCount + 1
		end

		if petInfo.isVariant then
			variantCount = variantCount + 1
		end

		if petInfo.isBoss then
			bossCount = bossCount + 1
		end

		if petInfo.rating and petInfo.rating >= 2 and not petInfo.isCatchReportingStatus then
			ratingCount = ratingCount + 1
		end

		if petInfo.hasRareFeature == 1 then
			rareFeatureCount = rareFeatureCount + 1
		end

		if needCultivation and pg.game.petManage:hasPetCultivation(petInfo.id) then
			cultivationCount = cultivationCount + 1
		end
	end

	if shinyCount <= 0 and rainBowCount <= 0 and variantCount <= 0 and bossCount <= 0 and ratingCount <= 0 and rareFeatureCount <= 0 and magicCount < 1 and cultivationCount <= 0 then
		widgetTipsUWidget.gameObject:SetActiveEx(false)

		return
	end

	widgetTipsUWidget.gameObject:SetActiveEx(true)

	local numCount = Lume.count(petInfos)

	if richTextColor then
		numCount = string.format("<color=%s>%d</color>", richTextColor, numCount)
	else
		numCount = string.format("<style=Hint_BgL>%d</style>", numCount)
	end

	local txt = string.format(pg.getGameString("PET_MANAGEMENT_RELEASE_CHECK_1"), numCount)

	local function appendCountText(count, description)
		if count > 0 then
			local subNumCount = count

			if richTextColor then
				subNumCount = string.format("<color=%s>%d</color>", richTextColor, count)
			else
				subNumCount = string.format("<style=Hint_BgL>%d</style>", count)
			end

			txt = txt .. string.format(pg.getGameString("PET_MANAGEMENT_RELEASE_CHECK_2"), subNumCount, description)
		end
	end

	appendCountText(shinyCount, pg.getGameString("PET_MANAGEMENT_SHINY"))
	appendCountText(darkCount, pg.getGameString("PET_MANAGEMENT_DARK"))
	appendCountText(rainBowCount, pg.getGameString("PET_MANAGEMENT_RAINBOW"))
	appendCountText(variantCount, pg.getGameString("PET_MANAGEMENT_COLOUR"))
	appendCountText(bossCount, pg.getGameString("PET_MANAGEMENT_BOSS"))
	appendCountText(ratingCount, pg.getGameString("PET_MANAGEMENT_TALENT"))
	appendCountText(rareFeatureCount, pg.getGameString("PET_MANAGEMENT_FEATURE"))

	if needCultivation then
		appendCountText(cultivationCount, pg.getGameString("PET_MANAGEMENT_CULTIVATION"))
	end

	txt = txt:gsub("，%s*$", ""):gsub(",%s*$", "")

	ClientTextUtils.setText(txtTipsUSDFText, txt)

	return txt
end

function PetManagementUtils.getPetOldSixPropLevelInfos(petId)
	local petInfo = pg.me:getPetInfo(petId)
	local baseProperty = petInfo.basePropertyList
	local individualLevelTable = {}

	for i = Const.BASE_PROPERTY_HP_IDX, Const.BASE_PROPERTY_ATK_MAG_IDX do
		individualLevelTable[i] = {
			base = baseProperty[i].indLv - baseProperty[i].iLvLn,
			learnt = baseProperty[i].iLvLn,
			total = baseProperty[i].indLv,
			isMax = baseProperty[i].indLv >= PetPropLevelMaxData[i],
			max = PetPropLevelMaxData[i]
		}
	end

	return individualLevelTable
end

function PetManagementUtils.getPetCurDisplayAttrVal(petId, dispAttrName)
	if not petId or not dispAttrName or not pg.me then
		return nil
	end

	local dispAttrId = AttributeConst[dispAttrName]
	local petInfo = pg.me:getPetInfo(petId)
	local attributeMap = PetAttributeCalcUtils.getAttributeMapByPetInfo(pg.me, petInfo)
	local curValue = attributeMap[dispAttrId]

	return curValue
end

function PetManagementUtils.customRefreshBuffInfoTooltip(component, group, customData)
	local objectReference = component:GetComponent("ObjectReference")
	local buffNameUText = objectReference:GetRefValue("buffNameUText")
	local buffDetailUText = objectReference:GetRefValue("buffDetailUText")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local buffNumUText = objectReference:GetRefValue("buffNumUText")
	local txtAddUSDFText = objectReference:GetRefValue("txtAddUSDFText")
	local imgBgBaseUWidget = objectReference:GetRefValue("imgBgBaseUWidget")
	local txtTagBaseUSDFText = objectReference:GetRefValue("txtTagBaseUSDFText")
	local imgBgAddUWidget = objectReference:GetRefValue("imgBgAddUWidget")
	local txtTagAddUSDFText = objectReference:GetRefValue("txtTagAddUSDFText")

	iconUImage:SetActive(true)

	group = group or PetManagementDataHelper.BuffInfoToolTipType.Buff
	customData = customData or {}

	component:TryChangePage("GroupType", group - 1)
	component:TryChangePage("InfoState", 1)

	if group == PetManagementDataHelper.BuffInfoToolTipType.Buff then
		local buffName = customData.buffName or ""
		local buffDesc = customData.buffDesc or ""
		local buffIcon = customData.buffIcon or ""

		ClientTextUtils.setText(buffNameUText, buffName)
		ClientTextUtils.setText(buffDetailUText, buffDesc)

		iconUImage.url = buffIcon
	elseif group == PetManagementDataHelper.BuffInfoToolTipType.Quality then
		local quality = customData.quality or 0
		local buffName = pg.getLocalizationText(customData.buffName or "")
		local buffDesc = pg.getLocalizationText(customData.buffDesc or "")
		local buffIcon = customData.buffIcon or ""

		component:TryChangePage("Quality", quality)
		ClientTextUtils.setText(buffNameUText, buffName)
		ClientTextUtils.setText(buffDetailUText, buffDesc)

		iconUImage.url = buffIcon
	elseif group == PetManagementDataHelper.BuffInfoToolTipType.Cultivate then
		local index = customData.index or 0
		local recommend = customData.recommend or {}
		local propertyEnhanced = customData.propertyEnhanced or false
		local propLevel = customData.propLevel or {}
		local info = PetDetailPropertyData[index] and PetDetailPropertyData[index][1]

		if LuaUIUtils.tableContains(recommend, index) then
			component:TryChangePage("GoodState", 1)
		else
			component:TryChangePage("GoodState", 0)
		end

		component:TryChangePage("Updated", propertyEnhanced and 1 or 0)
		ClientTextUtils.setText(buffNameUText, pg.getLocalizationText(info.propName))
		ClientTextUtils.setText(buffDetailUText, pg.getLocalizationText(info.dec))

		iconUImage.url = info.icon
		propLevel = propLevel or {}

		ClientTextUtils.setText(txtAddUSDFText, string.format("+%d", propLevel.baseAndActiveTotalLv))
		ClientTextUtils.setText(txtTagBaseUSDFText, pg.getGameString("PET_BASE_VALUE_DESC") .. " " .. propLevel.complexBaseLv)
		ClientTextUtils.setText(txtTagAddUSDFText, pg.getGameString("PET_ADD_VALUE_DESC") .. " " .. propLevel.learnt)
		imgBgAddUWidget:SetActive(propLevel.baseAndActiveTotalLv > 0)
	end
end

function PetManagementUtils.getPetOldPropConfigMaxLv(includePassiveExtra)
	local maxLv = 0

	if includePassiveExtra then
		for i = Const.BASE_PROPERTY_HP_IDX, Const.BASE_PROPERTY_ATK_MAG_IDX do
			maxLv = math.max(maxLv, PetPropLevelMaxData[i] or 1)
		end
	else
		maxLv = PetConfigData.individualPropMax or 1
	end

	return maxLv
end

function PetManagementUtils.getPetOldPropIconAndNameKey(propId)
	local info = PetDetailPropertyData[propId][1]

	return info.icon, info.propName
end

function PetManagementUtils.getPetOldPropAttrConstName(propId)
	local info = PetDetailPropertyData[propId][1]

	return info.displayProp
end

function PetManagementUtils.getNewPropExtraMaxLv()
	return PetConfigData.newPropExtraMaxLv or Const.NEW_PROP_SPECIAL_LV
end

function PetManagementUtils.getNewPropSpecailLv()
	return 5
end

function PetManagementUtils.getPetNewPropIdAndNames()
	local id2Names = {}
	local name2Ids = {}

	for name, cfg in pairs(PetAttrConvertData) do
		id2Names[cfg.id] = name
		name2Ids[name] = cfg.id
	end

	return id2Names, name2Ids
end

function PetManagementUtils.getPetNewPropAttrNameByNewId(newPropId)
	for name, cfg in pairs(PetAttrConvertData) do
		if cfg.id == newPropId then
			return name
		end
	end
end

function PetManagementUtils.getPetNewPropIdByAttrName(newPropAttrName)
	for name, cfg in pairs(PetAttrConvertData) do
		if name == newPropAttrName then
			return cfg.id
		end
	end
end

function PetManagementUtils.getPetNewSixPropAttrId(newPropId)
	local attrName = Const.NEW_BASE_PROP_IDX2ATTR_MAP[newPropId]

	return AttributeConst[attrName]
end

function PetManagementUtils.getPetNewSixPropCfg(newPropId)
	if not newPropId then
		return nil
	end

	for _, cfg in pairs(PetAttrConvertData) do
		if cfg.id == newPropId then
			return cfg
		end
	end

	return nil
end

function PetManagementUtils.getPetNewSixPropAtomAttrCfg(newPropId)
	if not newPropId then
		return nil
	end

	local atomAttrName = PetManagementUtils.getPetNewPropAttrNameByNewId(newPropId)

	if not atomAttrName then
		return nil
	end

	local refAttrId = Const.NEW_BASE_PROP_ATTR2REFID_MAP[atomAttrName]

	return AttributeGroupData[refAttrId]
end

function PetManagementUtils.getPetNewSixPropInfos(petId, isTemp)
	if not pg.me then
		return
	end

	local petInfo = pg.me:getPetInfo(petId)
	local primaryProperty = petInfo.primaryProperty
	local newSixPInfo = {
		potentialPointSum = primaryProperty and primaryProperty.potentialPointSum or 0,
		usedPotentialPointSum = primaryProperty and primaryProperty.usedPotentialPointSum or 0,
		isAutoAddStrengPoint = primaryProperty and primaryProperty.isAutoAddStrengPoint or true,
		firstCreate = primaryProperty and primaryProperty.firstCreate or false,
		detailPropInfos = {}
	}

	newSixPInfo.remainPotentialPointSum = newSixPInfo.potentialPointSum - newSixPInfo.usedPotentialPointSum

	local extraStrengPointSrctypeMap = primaryProperty and primaryProperty.extraStrengPoint or {}
	local parseExtraStrengPointMap = {}

	for originAttrId, map in pairs(extraStrengPointSrctypeMap) do
		if map and next(map) then
			local newPropId = PetManagementUtils.getExtraNewPropIdByOriginAttrId(originAttrId)

			parseExtraStrengPointMap[newPropId] = map
		end
	end

	for i, v in ipairs(Const.NEW_BASE_PROP_IDX2ATTR_MAP) do
		newSixPInfo.detailPropInfos[i] = {
			propertyStrengPoint = primaryProperty and primaryProperty.propertyStrengPoint and primaryProperty.propertyStrengPoint[i] or 0,
			extraStrengPointSrctypeMap = parseExtraStrengPointMap and parseExtraStrengPointMap[i] or {},
			propertyStrengMax = primaryProperty and primaryProperty.propertyStrengMax and primaryProperty.propertyStrengMax[i] or 0,
			extraStrengthLv = PetManagementUtils.getExtraStrengthLv(petId, i, parseExtraStrengPointMap and parseExtraStrengPointMap[i] or {}),
			propExtraStrengMax = PetManagementUtils.getNewPropExtraMaxLv(),
			propId = i
		}

		if isTemp then
			newSixPInfo.detailPropInfos[i].propertyStrengPoint = 0
			newSixPInfo.detailPropInfos[i].parseExtraStrengPointMap = {}
			newSixPInfo.usedPotentialPointSum = 0
			newSixPInfo.remainPotentialPointSum = newSixPInfo.potentialPointSum
		end
	end

	return newSixPInfo
end

function PetManagementUtils.getExtraNewPropIdByOriginAttrId(originAttrId)
	if not originAttrId then
		return nil
	end

	local attrName = AttributeConst.ID2NAME[originAttrId]

	if not attrName then
		return nil
	end

	local newPropId

	for _newPropId, _attrName in ipairs(PriProRevertData or EMPTY_TABLE) do
		if _attrName == attrName then
			newPropId = _newPropId

			break
		end
	end

	return newPropId
end

function PetManagementUtils.getPetNewSixPropInfo(petId, propId)
	if not pg.me then
		return
	end

	local infos = PetManagementUtils.getPetNewSixPropInfos(petId)
	local retInfo

	if infos then
		retInfo = {
			potentialPointSum = infos and infos.potentialPointSum or 0,
			usedPotentialPointSum = infos and infos.usedPotentialPointSum or 0,
			remainPotentialPointSum = infos and infos.potentialPointSum - infos.usedPotentialPointSum or 0,
			isAutoAddStrengPoint = infos and infos.isAutoAddStrengPoint or true,
			firstCreate = infos and infos.firstCreate or false,
			propertyStrengPoint = infos and infos.detailPropInfos[propId] and infos.detailPropInfos[propId].propertyStrengPoint or 0,
			extraStrengPointSrctypeMap = infos and infos.detailPropInfos[propId] and infos.detailPropInfos[propId].extraStrengPointSrctypeMap or {},
			propertyStrengMax = infos and infos.detailPropInfos[propId] and infos.detailPropInfos[propId].propertyStrengMax or 0,
			extraStrengthLv = infos and infos.detailPropInfos[propId] and infos.detailPropInfos[propId].extraStrengthLv or 0,
			propExtraStrengMax = infos and infos.detailPropInfos[propId] and infos.detailPropInfos[propId].propExtraStrengMax or PetManagementUtils.getNewPropExtraMaxLv(),
			propId = propId,
			propL10NName = pg.getGameString(PetManagementDataHelper.NEW_PROP_NAMES[propId])
		}
	end

	return retInfo
end

function PetManagementUtils.getPetNewPropUpLvConvertGains(newPropId, newPropLv)
	newPropLv = newPropLv or 1

	if not newPropId then
		return nil
	end

	local newPropName = PetManagementUtils.getPetNewPropAttrNameByNewId(newPropId)
	local newPropConvertCfg = PetAttrConvertData[newPropName]

	if not newPropConvertCfg or not newPropConvertCfg.addprops then
		return nil
	end

	local atomPropInfos = {}

	for _, prop in pairs(newPropConvertCfg.addprops or EMPTY_TABLE) do
		local attrId = AttributeConst[prop[2]]

		if attrId ~= nil then
			local value = math_floor(newPropLv / prop[1]) * prop[3]

			atomPropInfos[attrId] = atomPropInfos[attrId] or {}
			atomPropInfos[attrId].value = (atomPropInfos[attrId].value or 0) + value
			atomPropInfos[attrId].propl10nName = ClientTextUtils.getLocalizationText(prop[4]) or prop[2]
			atomPropInfos[attrId].valueType = prop[5] or Const.PET_CONVERT_VALTYPE.Direct
		end
	end

	return atomPropInfos
end

function PetManagementUtils.getPetNewPropUpLvConvertGains2(newPropId, newPropLv)
	newPropLv = newPropLv or 1

	if not newPropId then
		return nil
	end

	local newPropName = PetManagementUtils.getPetNewPropAttrNameByNewId(newPropId)
	local newPropConvertCfg = PetAttrConvertData[newPropName]

	if not newPropConvertCfg or not newPropConvertCfg.addprops then
		return nil
	end

	local atomPropInfos = {}

	for _, prop in pairs(newPropConvertCfg.addprops or EMPTY_TABLE) do
		local attrId = AttributeConst[prop[2]]

		if attrId ~= nil then
			local value = math_floor(newPropLv / prop[1]) * prop[3]

			atomPropInfos[attrId] = atomPropInfos[attrId] or {}
			atomPropInfos[attrId].value = (atomPropInfos[attrId].value or 0) + value
			atomPropInfos[attrId].propl10nName = ClientTextUtils.getLocalizationText(prop[4]) or prop[2]
			atomPropInfos[attrId].valueType = prop[5] or Const.PET_CONVERT_VALTYPE.Direct
		end
	end

	return atomPropInfos
end

function PetManagementUtils.getPetNewPropConvertRuleInfo(newPropId, maxConvertNum)
	if not newPropId then
		return nil
	end

	maxConvertNum = maxConvertNum or 1

	local newPropName = PetManagementUtils.getPetNewPropAttrNameByNewId(newPropId)
	local newPropConvertCfg = PetAttrConvertData[newPropName]

	if not newPropConvertCfg or not newPropConvertCfg.addprops then
		return nil
	end

	local atomPropInfos = {}

	for _, propInfo in ipairs(newPropConvertCfg.addprops or EMPTY_TABLE) do
		local gainScaler = propInfo and propInfo[1]

		if gainScaler == maxConvertNum then
			local propAttrName = propInfo and propInfo[2]
			local propVal = propInfo and propInfo[3] or 0
			local addPropVal = propVal
			local propL10nName = propInfo and pg.getLocalizationText(propInfo[4]) or ""
			local propValShowType = propInfo and propInfo[5]

			atomPropInfos[#atomPropInfos + 1] = {
				propId = newPropId,
				convertNum = addPropVal,
				value = addPropVal,
				propl10nName = propL10nName,
				valueType = propValShowType
			}
		end
	end

	return atomPropInfos
end

function PetManagementUtils.getPetNewPropConvertGainDesc(atomPropInfo)
	if not atomPropInfo then
		return ""
	end

	if atomPropInfo.valueType == Const.PET_CONVERT_VALTYPE.Direct then
		local fixedVal = math_floor(atomPropInfo.value)

		return "+" .. fixedVal .. atomPropInfo.propl10nName
	elseif atomPropInfo.valueType == Const.PET_CONVERT_VALTYPE.Ratio then
		local fixedVal = math_floor(atomPropInfo.value * 100)

		fixedVal = string.format("%.0f", fixedVal)

		return "+" .. fixedVal .. "%" .. atomPropInfo.propl10nName
	end
end

function PetManagementUtils.getPetNewPropConvertGainDesc2(atomPropInfo)
	if not atomPropInfo then
		return "", ""
	end

	if atomPropInfo.valueType == Const.PET_CONVERT_VALTYPE.Direct then
		local fixedVal = math_floor(atomPropInfo.value)

		return atomPropInfo.propl10nName .. ": ", "+" .. fixedVal
	elseif atomPropInfo.valueType == Const.PET_CONVERT_VALTYPE.Ratio then
		local fixedVal = math_floor(atomPropInfo.value * 100)

		fixedVal = string.format("%.0f", fixedVal)

		return atomPropInfo.propl10nName .. ": ", "+" .. fixedVal .. "%"
	end
end

function PetManagementUtils.getResetEffortCostInfo()
	local result = {}
	local resetCostCfg = PetConfigData.petPropLvResetCost or {}

	for itemId, costNum in pairs(resetCostCfg) do
		if itemId and costNum then
			table.insert(result, {
				itemId,
				costNum
			})
		end
	end

	return result
end

function PetManagementUtils.getAddedAtomPropInfo(petId, newPropId, addLvs)
	if not petId or not newPropId then
		return nil
	end

	local times = addLvs or 1
	local convertAtomInfos = PetManagementUtils.getPetNewPropUpLvConvertGains(newPropId)

	if not convertAtomInfos then
		return nil
	end

	local addedAtomPropInfos = {}

	for atomPropName, atomPropInfo in pairs(convertAtomInfos) do
		if atomPropInfo then
			local addedInfo = addedAtomPropInfos[atomPropName] or {}

			addedInfo.atomPropName = atomPropInfo.atomPropId or atomPropName
			addedInfo.valueType = atomPropInfo.valueType or 0
			addedInfo.propL10nName = atomPropInfo.propl10nName or ""

			if atomPropInfo.valueType == Const.PET_CONVERT_VALTYPE.Direct then
				addedInfo.value = (addedInfo.value or 0) + atomPropInfo.value * times
			elseif atomPropInfo.valueType == Const.PET_CONVERT_VALTYPE.Ratio then
				addedAtomPropInfos[atomPropName].value = (addedAtomPropInfos[atomPropName].value or 0) + (atomPropInfo.value or 0) * times
			end

			addedAtomPropInfos[atomPropName] = addedInfo
		end
	end

	return addedAtomPropInfos
end

function PetManagementUtils.getPreviewAddedAtomPropInfo(petId, newPropId, addLvs, isDelNoChangedAttr)
	local petInfo = pg.me:getPetInfo(petId)
	local previewAtomAttrsMap = Utils.primaryPropertyUpdate(petInfo, newPropId, addLvs)
	local allAttrs = PetManagementUtils.m_getPreviewAddedAtomPropInfo(petId, previewAtomAttrsMap)

	isDelNoChangedAttr = isDelNoChangedAttr == nil and true or isDelNoChangedAttr

	if isDelNoChangedAttr then
		for i = #allAttrs, 1, -1 do
			if allAttrs[i].diffV <= 0 then
				table.remove(allAttrs, i)
			end
		end
	end

	return allAttrs
end

function PetManagementUtils.getPreviewAddedAtomPropInfo2(petId, newPropId, addLvs, targetSLv)
	local newPropCfg = PetManagementUtils.getPetNewSixPropCfg(newPropId)

	if not newPropCfg then
		return nil
	end

	local addprops = newPropCfg and newPropCfg.addprops

	if not addprops or #addprops == 0 then
		return nil
	end

	local allAttrs = PetManagementUtils.m_getPreviewAddedAtomPropInfoNewProp(petId, newPropId, addprops, addLvs, targetSLv)

	return allAttrs
end

function PetManagementUtils.m_getPreviewAddedAtomPropInfo_backup(petId, previewAtomAttrsMap, maxLen)
	local petInfo = pg.me:getPetInfo(petId)
	local simulateCalProps = PetManagementDataHelper.SIMULATE_CAL_PROPS
	local curAtomAttrsMap = Utils.primaryPropertyUpdate(petInfo)
	local curAttrsMap = {}

	for k, v in pairs(simulateCalProps) do
		local directVAttrName = AttributeConst.ID2NAME[v[1]]
		local directV = curAtomAttrsMap[directVAttrName] or 0
		local ratioVAttrName = AttributeConst.ID2NAME[v[2]]
		local ratioV = 1 + (curAtomAttrsMap[ratioVAttrName] or 0)
		local simulateV = directV * ratioV

		curAttrsMap[k] = simulateV
	end

	previewAtomAttrsMap = previewAtomAttrsMap or {}

	local previewAttrsMap = {}

	for k, v in pairs(simulateCalProps) do
		local directVAttrName = AttributeConst.ID2NAME[v[1]]
		local directV = previewAtomAttrsMap[directVAttrName] or 0
		local ratioVAttrName = AttributeConst.ID2NAME[v[2]]
		local ratioV = 1 + (previewAtomAttrsMap[ratioVAttrName] or 0)
		local simulateV = directV * ratioV

		previewAttrsMap[k] = simulateV
	end

	local previewFinalAttrsMap = {}

	for i = 1, Const.BASE_PROPERTY_CNT do
		local oldV = curAttrsMap[i] or 0
		local newV = previewAttrsMap[i] or 0
		local diffV = math.max(0, newV - oldV)

		previewFinalAttrsMap[#previewFinalAttrsMap + 1] = {
			propId = i,
			oldV = oldV,
			diffV = math_floor(diffV),
			l10nName = pg.getGameString(PetManagementDataHelper.FINAL_PROP_NAMES[i])
		}
	end

	if maxLen and maxLen < #previewFinalAttrsMap then
		for i = maxLen + 1, #previewFinalAttrsMap do
			previewFinalAttrsMap[i] = nil
		end
	end

	return previewFinalAttrsMap
end

function PetManagementUtils.m_getPreviewAddedAtomPropInfo(petId, previewAtomAttrsMap, maxLen)
	local petInfo = pg.me:getPetInfo(petId)
	local curAtomAttrsMap = Utils.primaryPropertyUpdate(petInfo) or {}

	previewAtomAttrsMap = previewAtomAttrsMap or {}

	local previewFinalAttrsMap = {}

	for k, v in pairs(AttributeGroupData or EMPTY_TABLE) do
		local propName = v.attrs and v.attrs[1]

		if propName and previewAtomAttrsMap[propName] then
			local oldPropVal = curAtomAttrsMap[propName] or 0
			local newPropVal = previewAtomAttrsMap[propName] or 0
			local diffVal = math.max(0, newPropVal - oldPropVal)

			if diffVal > 0 then
				local propDispTxt = PetManagementUtils.m_getDisplayShowPropTxt(diffVal, v.showType)

				previewFinalAttrsMap[#previewFinalAttrsMap + 1] = {
					propId = k,
					oldV = oldPropVal,
					diffV = diffVal,
					oldVDispTxt = PetManagementUtils.m_getDisplayShowPropTxt(oldPropVal, v.showType),
					newVDispTxt = PetManagementUtils.m_getDisplayShowPropTxt(newPropVal, v.showType),
					l10nName = pg.getLocalizationText(v.name),
					propDispTxt = propDispTxt
				}
			end
		end
	end

	return previewFinalAttrsMap
end

function PetManagementUtils.m_getPreviewAddedAtomPropInfoStarup(petId, gainProps, maxLen)
	local previewAtomAttrsMap = {}
	local previewFinalAttrsMap = {}

	for _, propInfo in ipairs(gainProps or EMPTY_TABLE) do
		local atomPropId = propInfo and propInfo[1]
		local atomPropVal = propInfo and propInfo[2]

		if atomPropId and atomPropVal then
			local atomCfg = AttributeGroupData[atomPropId]

			if atomCfg then
				previewFinalAttrsMap[#previewFinalAttrsMap + 1] = {
					oldV = 0,
					diffV = 0,
					propId = atomPropId,
					oldVDispTxt = "+" .. PetManagementUtils.m_getDisplayShowPropTxt(0, atomCfg.showType),
					newVDispTxt = "+" .. PetManagementUtils.m_getDisplayShowPropTxt(atomPropVal, atomCfg.showType),
					l10nName = pg.getLocalizationText(atomCfg.name),
					propDispTxt = "+" .. PetManagementUtils.m_getDisplayShowPropTxt(atomPropVal, atomCfg.showType)
				}
			end
		end
	end

	return previewFinalAttrsMap
end

function PetManagementUtils.m_getPreviewAddedAtomPropInfoNewProp(petId, newPropId, addprops, addLvs, targetSLv)
	local previewAtomAttrsMap = {}
	local previewFinalAttrsMap = {}

	for _, propInfo in ipairs(addprops or EMPTY_TABLE) do
		local gainScaler = propInfo and propInfo[1]

		if gainScaler == 1 or gainScaler > 1 and targetSLv % gainScaler == 0 then
			local propAttrName = propInfo and propInfo[2]
			local propVal = propInfo and propInfo[3] or 0
			local addPropVal = propVal
			local propL10nName = propInfo and pg.getLocalizationText(propInfo[4]) or ""
			local propValShowType = propInfo and propInfo[5]

			previewFinalAttrsMap[#previewFinalAttrsMap + 1] = {
				oldV = 0,
				diffV = 0,
				propId = newPropId,
				oldVDispTxt = "+" .. PetManagementUtils.m_getDisplayShowPropTxt(0, propValShowType),
				newVDispTxt = "+" .. PetManagementUtils.m_getDisplayShowPropTxt(addPropVal, propValShowType),
				l10nName = propL10nName,
				propDispTxt = "+" .. PetManagementUtils.m_getDisplayShowPropTxt(addPropVal, propValShowType)
			}
		end
	end

	return previewFinalAttrsMap
end

function PetManagementUtils.m_getDisplayShowPropTxt(propVal, showType)
	propVal = propVal or 0

	local propDispTxt = ""

	if showType == 0 then
		propDispTxt = string.format("%d", propVal)
	elseif showType == 1 and type(propVal) == "number" then
		propDispTxt = string.format("%s%%", math.floor(propVal * 100))
	elseif showType == 2 then
		propDispTxt = Utils.m_customParseFloatPropVal(propVal)
	end

	return propDispTxt
end

function PetManagementUtils.getNextStrengthExtraAtomPropDesc(newPropId, curStrengthPoint)
	if not newPropId then
		return nil
	end

	local newPropConvertCfg = PetManagementUtils.getPetNewSixPropCfg(newPropId)

	if not newPropConvertCfg then
		return
	end

	local curStrengthPointMod5 = (curStrengthPoint or 0) % 5
	local minNeedPointCnt = 0
	local minNeedPointId = 0

	for propId, prop in pairs(newPropConvertCfg.addprops or EMPTY_TABLE) do
		local needPointCnt = prop[1] or 0

		if minNeedPointCnt < needPointCnt then
			minNeedPointCnt = needPointCnt
			minNeedPointId = propId
		end
	end

	if minNeedPointId == 0 or minNeedPointCnt == 0 then
		return nil
	end

	local needPoint = curStrengthPointMod5 < minNeedPointCnt and minNeedPointCnt - curStrengthPointMod5 or minNeedPointCnt
	local extraAddpropInfo = newPropConvertCfg.addprops[minNeedPointId] or {}
	local gainVal = extraAddpropInfo[3] or 0
	local valType = extraAddpropInfo[5] or Const.PET_CONVERT_VALTYPE.Direct
	local gainValStr = ""
	local gainAttrL10nName = ClientTextUtils.getLocalizationText(extraAddpropInfo[4]) or extraAddpropInfo[2]

	if valType == Const.PET_CONVERT_VALTYPE.Direct then
		local fixedVal = string.format("%.2f", gainVal)

		gainValStr = fixedVal .. gainAttrL10nName
	elseif valType == Const.PET_CONVERT_VALTYPE.Ratio then
		local fixedVal = math_floor(gainVal * 100)

		fixedVal = string.format("%.2f", fixedVal)
		gainValStr = fixedVal .. "%" .. gainAttrL10nName
	end

	return needPoint, gainValStr
end

function PetManagementUtils.getPetDisplayAttrsIds()
	local retIds = {}

	for attrName, _ in pairs(PetDisplayAttrNames) do
		local attrId = AttributeConst[attrName]

		retIds[#retIds + 1] = attrId
	end

	return retIds
end

function PetManagementUtils.getExtraStrengthLv(petId, newPropId, extraStrengPointSrctypeMap)
	if not petId or not newPropId then
		return 0
	end

	local totalExtraStrengPoint = 0

	for srcType, extraStrengPoint in pairs(extraStrengPointSrctypeMap or EMPTY_TABLE) do
		if srcType == AbilityConst.EXCEPT_EXTRA_ATTR_SRCTYPE then
			break
		end

		totalExtraStrengPoint = totalExtraStrengPoint + (extraStrengPoint or 0)
	end

	return totalExtraStrengPoint
end

function PetManagementUtils.getExtraStrengthLvInfos(petId, newPropId)
	if not petId or not newPropId then
		return
	end

	local petNewSixPropInfos = PetManagementUtils.getPetNewSixPropInfos(petId)

	if not petNewSixPropInfos or not petNewSixPropInfos.detailPropInfos then
		return
	end

	if not petNewSixPropInfos.detailPropInfos[newPropId] then
		return
	end

	if not petNewSixPropInfos.detailPropInfos[newPropId].extraStrengPointSrctypeMap then
		return
	end

	local srcTypeMap = petNewSixPropInfos.detailPropInfos[newPropId].extraStrengPointSrctypeMap or {}
	local parseInfos = PetManagementUtils.mergeExtraStrengthLvInfos(srcTypeMap)

	return parseInfos
end

function PetManagementUtils.mergeExtraStrengthLvInfos(srcMap)
	if not srcMap then
		return
	end

	local parseInfos = {}

	for srcType, extraLv in pairs(srcMap) do
		if extraLv and srcType ~= AbilityConst.EXCEPT_EXTRA_ATTR_SRCTYPE then
			local finalStrKey = AbilityConst.EXTRA_SRCTYPE_STRKEY_OTHER

			for strKey, v in pairs(AbilityConst.EXTRA_SRCTYPE_STRKEYS) do
				if table.contains(v, srcType) then
					finalStrKey = strKey

					break
				end
			end

			parseInfos[finalStrKey] = parseInfos[finalStrKey] or 0
			parseInfos[finalStrKey] = parseInfos[finalStrKey] + extraLv
		end
	end

	return parseInfos
end

function PetManagementUtils.getNewPropReachNextLvNeedPotentialPoint(petId, strengthLv)
	if not pg.me or not petId or not strengthLv then
		return 0
	end

	if strengthLv <= 0 then
		return 0
	end

	local maxLv = PetManagementUtils.getNewPropMaxStrengthLv(petId)

	if not maxLv then
		return 0
	end

	if maxLv < strengthLv then
		return 0
	end

	return FormulaData[3020].formula(strengthLv, math_floor)
end

function PetManagementUtils.getNewPropMaxStrengthLv(petId)
	local max = 30

	if not pg.me or not petId then
		return max
	end

	local petInfo = pg.me:getPetInfo(petId)

	if not petInfo then
		return max
	end

	local level = petInfo.level
	local stage = petInfo.stage
	local maxLv = FormulaData[3021].formula(level, stage, petInfo.propertyScoreStage)

	return maxLv
end

function PetManagementUtils.getNewPropRangeLvChangePotentialPoint(petId, newPropId, startLv, endLv)
	if not petId or not newPropId or not startLv or not endLv then
		return 0
	end

	local minLv = math.min(startLv, endLv)
	local maxLv = math.max(startLv, endLv)
	local pointSum = 0

	for lv = minLv + 1, maxLv do
		local point = PetManagementUtils.getNewPropReachNextLvNeedPotentialPoint(petId, lv)

		pointSum = pointSum + point
	end

	if endLv < startLv then
		return -pointSum
	end

	return pointSum
end

function PetManagementUtils.getNewPropCostPPointCanReachedLv(petId, newPropId, startLv, costPPoint)
	if not petId or not newPropId or type(startLv) ~= "number" or type(costPPoint) ~= "number" then
		return 0
	end

	startLv = math.max(0, startLv)
	costPPoint = math.max(0, costPPoint)

	local maxLv = PetManagementUtils.getNewPropMaxStrengthLv(petId)

	if not maxLv or type(maxLv) ~= "number" or maxLv <= 0 then
		return startLv
	end

	maxLv = math.max(0, maxLv)

	if maxLv <= startLv or costPPoint <= 0 then
		return startLv
	end

	local accumulatedCost = 0
	local reachableLv = startLv

	for lv = startLv + 1, maxLv do
		local needPoint = PetManagementUtils.getNewPropReachNextLvNeedPotentialPoint(petId, lv)

		needPoint = type(needPoint) == "number" and needPoint >= 0 and needPoint or 0

		if costPPoint < accumulatedCost + needPoint then
			break
		end

		accumulatedCost = accumulatedCost + needPoint
		reachableLv = lv

		if maxLv <= reachableLv then
			break
		end
	end

	return math.min(reachableLv, maxLv)
end

function PetManagementUtils.getPPointProgressRatios(manualSLv, manualMaxLv, extraLv)
	local manualSLvPro = math.clamp(LuaUIUtils.safeDiv(manualSLv + extraLv, manualMaxLv), 0, 1)
	local extraLvPro = math.clamp(LuaUIUtils.safeDiv(extraLv, manualMaxLv), 0, 1)
	local allSLv = manualSLv + extraLv
	local specialSLvPro = math.floor(allSLv / PetManagementUtils.getNewPropSpecailLv()) * PetManagementUtils.getNewPropSpecailLv() / manualMaxLv
	local extraLvPro2 = math.clamp(LuaUIUtils.safeDiv(extraLv, PetManagementUtils.getNewPropExtraMaxLv()), 0, 1)

	return manualSLvPro, extraLvPro, specialSLvPro, extraLvPro2
end

function PetManagementUtils.getPPointBatchManuProgressRatios(manualSLv, manualMaxLv, extraLv)
	local manualSLvPro = math.clamp(LuaUIUtils.safeDiv(manualSLv, manualMaxLv), 0, 1)
	local extraLvPro = math.clamp(LuaUIUtils.safeDiv(extraLv, PetManagementUtils.getNewPropExtraMaxLv()), 0, 1)
	local specialSLvPro = math.floor(manualSLv / PetManagementUtils.getNewPropExtraMaxLv()) * PetManagementUtils.getNewPropExtraMaxLv() / manualMaxLv

	return manualSLvPro, extraLvPro, specialSLvPro
end

function PetManagementUtils.tryReqBatchAllocateEffort(petId, batchPropInfos, isNotice, isRecommend)
	local isChanged = false
	local realInfos = PetManagementUtils.getPetNewSixPropInfos(petId)
	local realDetailInfos = realInfos and realInfos.detailPropInfos or {}
	local parseBatchInfos = {}

	for i, v in ipairs(batchPropInfos) do
		local newPropId = PetManagementUtils.getPetNewPropIdByAttrName(v.propAttrName)

		parseBatchInfos[newPropId] = v.propLv
	end

	for newPropId, propAttrName in ipairs(Const.NEW_BASE_PROP_IDX2ATTR_MAP) do
		local realStrengthLv = realDetailInfos and realDetailInfos[newPropId] and realDetailInfos[newPropId].propertyStrengPoint or 0
		local changeStrengthLv = parseBatchInfos[newPropId] or 0

		if changeStrengthLv ~= realStrengthLv then
			isChanged = true

			break
		end
	end

	if not isChanged then
		if isNotice then
			pg.global.showBubbleMessageById(NoticeDef.PET_NEW_PROP_WITHOUT_CHANGE)
		end

		return
	end

	PetManagementUtils.reqResetEffort(petId, function()
		PetManagementUtils.m_reqBatchAllocateEffort(petId, batchPropInfos)
	end)

	if isRecommend then
		PetManagementUtils.redDot_RecordState(Const.CLIENT_KEY.PET_RECORD_APPLIED_RECOMMEND, petId)
	end
end

function PetManagementUtils.m_reqBatchAllocateEffort(petId, batchPropInfos)
	if not petId or not batchPropInfos then
		return
	end

	for i = 1, #batchPropInfos do
		local propAttrName = batchPropInfos[i].propAttrName
		local addLv = batchPropInfos[i].propLv

		PetManagementUtils.reqAllocateEffort(petId, propAttrName, addLv)
	end
end

function PetManagementUtils.reqAllocateEffort(petId, propAttrName, addLv)
	if not petId or not propAttrName or not addLv then
		return
	end

	pg.me:serverMsg("RPC_CS_AllocateEffort", petId, propAttrName, addLv, function(noticeId)
		if noticeId == NoticeDef.SUCCESS then
			facade:sendMsgToUI(MessageName.PET_NEW_PROP_CHANGE, {
				petId = petId
			})
		end
	end)
end

function PetManagementUtils.tryReqResetEffort(petId, isFree, sucCallback)
	if not petId then
		return
	end

	local realInfos = PetManagementUtils.getPetNewSixPropInfos(petId)
	local sum = realInfos and realInfos.potentialPointSum or 0
	local used = realInfos and realInfos.usedPotentialPointSum or 0

	if realInfos and sum == 0 or used == 0 then
		pg.global.showBubbleMessageById(NoticeDef.PET_NEW_PROP_WITHOUT_ALLOCATED)
	elseif isFree then
		PetManagementUtils.autoAllocatePoint(petId, sucCallback)
	else
		PetManagementUtils.reqResetEffort(petId, sucCallback)
	end
end

function PetManagementUtils.reqResetEffort(petId, sucCallback)
	if not petId then
		return
	end

	pg.me:serverMsg("RPC_CS_ResetEffort", petId, function(noticeId)
		if noticeId == NoticeDef.SUCCESS then
			facade:sendMsgToUI(MessageName.PET_NEW_PROP_CHANGE, {
				petId = petId
			})

			if sucCallback then
				sucCallback()
			end
		end
	end)
end

function PetManagementUtils.autoAllocatePoint(petId, sucCallback)
	if not petId then
		return
	end

	pg.me:serverMsg("RPC_CS_autoAllocatePoint", petId, function(noticeId)
		if noticeId == NoticeDef.SUCCESS then
			PetManagementUtils.redDot_RecordFreeResetPPointsState()
			facade:sendMsgToUI(MessageName.PET_NEW_PROP_CHANGE, {
				petId = petId
			})

			if sucCallback then
				sucCallback()
			end
		end
	end)
end

function PetManagementUtils.popupResetAllocatePoint(petId, totalUsedPPoint, sucCallBack)
	if not petId then
		return
	end

	local isFree = PetManagementUtils.redDot_GetFreeResetPPointsState(petId)

	if isFree then
		ClientUtils.showConfirmRaw(pg.getGameString("RELEASE_WARN"), pg.getGameString("PET_NEW_ATTR_APLLY_TIPS_FIRST_FREE"), function()
			PetManagementUtils.tryReqResetEffort(petId, true, sucCallBack)
		end)
	else
		local fStr = pg.getGameString("PET_NEW_ATTR_APLLY_TIPS1")

		fStr = (not fStr or fStr == "PET_NEW_ATTR_APLLY_TIPS1") and "ResetNeedCost%s" or fStr

		local resetCostInfo = PetManagementUtils.getResetEffortCostInfo()

		pg.global.showCommonTipUse(pg.getGameString("RELEASE_WARN"), string_format(fStr, totalUsedPPoint or 0), resetCostInfo, function()
			PetManagementUtils.tryReqResetEffort(petId, false, sucCallBack)
		end)
	end
end

function PetManagementUtils.redDot_GetFreeResetPPointsRedDotKey()
	return "recordFreeResetPPoints"
end

function PetManagementUtils.redDot_GetFreeResetPPointsState(petId)
	if not petId then
		return false
	end

	local petInfo = pg.me and pg.me:getPetInfo(petId)

	if not petInfo then
		return false
	end

	local primaryProperty = petInfo.primaryProperty

	return primaryProperty and ToBool(primaryProperty.isAutoAddStrengPoint)
end

function PetManagementUtils.redDot_RecordFreeResetPPointsState()
	pg.me:setRedDotRecord(Const.CLIENT_KEY.PET_CULTIVATE_FREE_FIRST_RESET_PPOINT, PetManagementUtils.redDot_GetFreeResetPPointsRedDotKey(), false)
end

function PetManagementUtils.getStarItemUrl(stage, isTag)
	return LuaUIUtils.getStarItemUrl(stage, isTag)
end

function PetManagementUtils.getPetNextResonanceCfg(petId, stage, level)
	local stageData = ResonanceData[stage]

	if stageData == nil then
		return
	end

	local maxStage, maxLv = PetManagementUtils.getResonanceMaxStageLv()

	if stageData[level + 1] == nil then
		stage = stage + 1
		level = 0

		if ResonanceData[stage] == nil or ResonanceData[stage][level] == nil then
			return ResonanceData[maxStage][maxLv], maxStage, maxLv
		end

		stageData = ResonanceData[stage]
	else
		level = level + 1
	end

	return stageData[level] or ResonanceData[maxStage][maxLv], stage or maxStage, level or maxLv
end

function PetManagementUtils.getPetPrevResonanceCfg(petId, stage, level)
	local prevStage = 0
	local prevLv = 0

	for stageId, stageLvsCfg in ipairs(ResonanceData or EMPTY_TABLE) do
		local stageLvsIds = table.keys(stageLvsCfg or {})

		table.sort(stageLvsIds)

		for _, lvId in pairs(stageLvsIds or EMPTY_TABLE) do
			if stageId == stage and lvId == level then
				return prevStage, prevLv
			end

			prevLv = lvId
			prevStage = stageId
		end
	end

	return prevStage, prevLv
end

function PetManagementUtils.getPetResonanceCfg(stage, level)
	local stageData = ResonanceData[stage]

	if stageData == nil then
		return
	end

	return stageData[level]
end

function PetManagementUtils.getPetMaxSLvResonanceCfg()
	local maxStage, maxLv = PetManagementUtils.getResonanceMaxStageLv()

	return ResonanceData[maxStage][maxLv]
end

function PetManagementUtils.isMaxedResonance(stage, level)
	if stage == PetManagementUtils.getResonanceMaxStageLv(stage) and PetManagementUtils.getResonanceStageMaxLv(stage, level) == level then
		return true
	end

	return false
end

function PetManagementUtils.getResonanceMaxStageLv()
	local maxStage = 0

	for k, v in pairs(ResonanceData or EMPTY_TABLE) do
		maxStage = math.max(maxStage, k)
	end

	local maxLv = 0

	for j, m in pairs(ResonanceData[maxStage] or EMPTY_TABLE) do
		maxLv = math.max(maxLv, j)
	end

	return maxStage, maxLv
end

function PetManagementUtils.getResonanceStageMaxLv(stage)
	local maxLv = 0
	local maxStageCfg = ResonanceData and ResonanceData[stage] or {}

	for k, v in pairs(maxStageCfg) do
		maxLv = math.max(maxLv, k)
	end

	return maxLv
end

function PetManagementUtils.getPetResonanceState(petId)
	local curResonanceInfo = PetManagementUtils.getPetStarUpInfo(petId)

	if not curResonanceInfo then
		return PetManagementDataHelper.RESONANCE_STATE.NORMAL
	end

	local stage = curResonanceInfo.resonanceStage or 0
	local level = curResonanceInfo.resonanceLevel or 0

	if stage == 0 and level == 0 then
		return PetManagementDataHelper.RESONANCE_STATE.NORMAL
	end

	if PetManagementUtils.isMaxedResonance(stage, level) then
		return PetManagementDataHelper.RESONANCE_STATE.MAXED
	end

	local checkMaxStage = PetManagementUtils.getResonanceMaxStageLv()
	local checkMaxLv = PetManagementUtils.getResonanceStageMaxLv(stage)

	if checkMaxLv == level then
		if stage + 1 == checkMaxStage then
			return PetManagementDataHelper.RESONANCE_STATE.WAIT_MAX_UP
		else
			return PetManagementDataHelper.RESONANCE_STATE.WAIT_MIN_UP
		end
	end

	return PetManagementDataHelper.RESONANCE_STATE.NORMAL
end

function PetManagementUtils.getPetNextResonanceSLvCosts(petId, curStage, curLv)
	if not petId then
		return
	end

	local resonanceInfo = PetManagementUtils.getPetStarUpInfo(petId)

	if not resonanceInfo then
		return
	end

	local nextResonanceCfg, nextStage, nextLevel = PetManagementUtils.getPetNextResonanceCfg(petId, curStage, curLv)

	if not nextResonanceCfg or not nextStage or not nextLevel then
		return
	end

	local petInfo = pg.me and pg.me:getPetInfo(petId)
	local petConfig = petInfo and petInfo:getConfigData()
	local ethnicGroup = petConfig and petConfig.ethnicGroup or 0
	local familyData = PetFamilyData[ethnicGroup]
	local familyNumDict = {}

	for _, req in ipairs(Utils.getPetResonanceFamilyItemDIct(ethnicGroup, nextResonanceCfg.itemNum)) do
		familyNumDict[req[1]] = (familyNumDict[req[1]] or 0) + req[3]
	end

	local familyItems = {}

	for itemId, num in pairs(familyNumDict) do
		table.insert(familyItems, {
			itemId,
			num,
			ItemUtils.getItemCountById(pg.me, itemId)
		})
	end

	local extraItemsCfg = nextResonanceCfg.extraItems or {}
	local extraItems = {}

	for i, v in ipairs(extraItemsCfg) do
		if v then
			local itemHasNum = ItemUtils.getItemCountById(pg.me, v[1] or 0)

			table.insert(extraItems, {
				v[1] or 0,
				v[2] or 0,
				itemHasNum
			})
		end
	end

	local apparencdItemId = familyData and familyData.enhanceClothes or 0
	local apparencdItem

	if nextResonanceCfg.needApparence then
		apparencdItem = {
			apparencdItemId,
			1
		}
	end

	local costList = {
		familyItem = familyItems,
		extraItems = extraItems,
		apparencdItem = apparencdItem
	}

	costList.allItems = {}

	for _, v in ipairs(familyItems) do
		if v[2] > 0 then
			table.insert(costList.allItems, v)
		end
	end

	if #costList.extraItems > 0 then
		for i, v in ipairs(costList.extraItems) do
			if v and v[2] > 0 then
				table.insert(costList.allItems, v)
			end
		end
	end

	local elementItemNum = nextResonanceCfg.elementItemNum or 0

	if elementItemNum > 0 then
		local mainElementName = petConfig and LuaUIUtils.getElementName(petConfig.mainElementType)
		local elementItemMap = PetConfigData.petElementItemId
		local elementItemId = mainElementName and elementItemMap and elementItemMap[mainElementName]

		if elementItemId and elementItemId > 0 then
			local totalItemNum = elementItemNum
			local itemHasNum
			local insertIndex = #costList.allItems + 1

			for i = #costList.allItems, 1, -1 do
				local itemInfo = costList.allItems[i]

				if itemInfo and itemInfo[1] == elementItemId then
					totalItemNum = totalItemNum + (itemInfo[2] or 0)
					itemHasNum = itemHasNum or itemInfo[3]
					insertIndex = i

					table.remove(costList.allItems, i)
				end
			end

			itemHasNum = itemHasNum or ItemUtils.getItemCountById(pg.me, elementItemId)

			table.insert(costList.allItems, insertIndex, {
				elementItemId,
				totalItemNum,
				itemHasNum
			})
		end
	end

	costList.conditionDescKey = nextResonanceCfg.conditionDesc or ""

	return costList
end

function PetManagementUtils.getStarUpSLvProgress(checkStage, checkLv)
	if not checkStage or not checkLv then
		return 0
	end

	local checkStageCfg = ResonanceData and ResonanceData[checkStage] or {}

	if not checkStageCfg then
		return 0
	end

	local maxLv = #checkStageCfg

	if maxLv <= checkLv then
		return 1
	end

	if checkLv <= 0 then
		return 0
	end

	return math.clamp(checkLv / (maxLv - 1.01), 0, 1)
end

function PetManagementUtils.compareStarUpSLv(stageA, lvA, stageB, lvB)
	return stageB * 100 + lvB - (stageA * 100 + lvA)
end

function PetManagementUtils.getBreakStageL10nDesc(stage)
	if not stage then
		return false
	end

	local stageCfg = ResonanceData and ResonanceData[stage]

	if not stageCfg then
		return ""
	end

	local fStr = pg.getGameString("PET_STARUP_BREAK_SUC_TIP")

	fStr = (not fStr or fStr == "PET_STARUP_BREAK_SUC_TIP") and "SucBreakStarUp%s" or fStr

	local breakDesc = string.format(fStr, tostring(stage))

	return breakDesc
end

function PetManagementUtils.getPetStarUpInfo(petId)
	local petInfo = pg.me and pg.me:getPetInfo(petId)

	if not petInfo then
		return
	end

	return petInfo.resonanceInfo
end

function PetManagementUtils.getPetCurStarSLv(petId)
	local info = PetManagementUtils.getPetStarUpInfo(petId)

	if not info then
		return
	end

	return info.resonanceStage, info.resonanceLevel
end

function PetManagementUtils.getPetFinalTargeResonanceStagelvDisplayAttrs2(petId, targetStage, targetLv)
	local resonanceInfo = PetManagementUtils.getPetStarUpInfo(petId)

	if not resonanceInfo then
		return
	end

	targetStage = targetStage or 0
	targetLv = targetLv or 0

	local accumulatedMap = {}

	for stageId, stageLvsCfg in ipairs(ResonanceData or EMPTY_TABLE) do
		if targetStage < stageId then
			break
		end

		local stageLvsIds = table.keys(stageLvsCfg or {})

		table.sort(stageLvsIds)

		for _, lvId in ipairs(stageLvsIds) do
			if stageId == targetStage and targetLv < lvId then
				break
			end

			local lvCfg = stageLvsCfg[lvId]
			local lvProps = lvCfg and lvCfg.props or {}

			for _, propInfo in ipairs(lvProps) do
				local atomPropId = propInfo and propInfo[1]
				local atomPropVal = propInfo and propInfo[2]

				if atomPropId and atomPropVal then
					accumulatedMap[atomPropId] = (accumulatedMap[atomPropId] or 0) + atomPropVal
				end
			end
		end
	end

	local accumulatedGainProps = {}

	for atomPropId, atomPropVal in pairs(accumulatedMap) do
		accumulatedGainProps[#accumulatedGainProps + 1] = {
			atomPropId,
			atomPropVal
		}
	end

	table.sort(accumulatedGainProps, function(a, b)
		return (a[1] or 0) < (b[1] or 0)
	end)

	return PetManagementUtils.m_getPreviewAddedAtomPropInfoStarup(petId, accumulatedGainProps)
end

function PetManagementUtils.getPetTargeResonanceStagelvDisplayAttrs2(petId, curStage, curLv, maxLen)
	local resonanceInfo = PetManagementUtils.getPetStarUpInfo(petId)

	if not resonanceInfo then
		return
	end

	local nextResonanceCfg, nextStage, nextLevel = PetManagementUtils.getPetNextResonanceCfg(petId, curStage, curLv)

	if not nextResonanceCfg or not nextStage or not nextLevel then
		return
	end

	local gainProps = nextResonanceCfg.props or {}

	if not gainProps or #gainProps == 0 then
		return
	end

	return PetManagementUtils.m_getPreviewAddedAtomPropInfoStarup(petId, gainProps, maxLen)
end

function PetManagementUtils.getPetTargeResonanceStagelvDisplayAttrs(petId, curStage, curLv, maxLen)
	local resonanceInfo = PetManagementUtils.getPetStarUpInfo(petId)

	if not resonanceInfo then
		return
	end

	local nextResonanceCfg, nextStage, nextLevel = PetManagementUtils.getPetNextResonanceCfg(petId, curStage, curLv)

	if not nextResonanceCfg or not nextStage or not nextLevel then
		return
	end

	local gainProps = nextResonanceCfg.props or {}

	if not gainProps or #gainProps == 0 then
		return
	end

	local petInfo = pg.me and pg.me:getPetInfo(petId)

	if not petInfo then
		return
	end

	local nextResonanceAttrsMap = Utils.primaryPropertyUpdate(petInfo, nil, nil, nextStage, nextLevel)

	if not nextResonanceAttrsMap then
		return
	end

	return PetManagementUtils.m_getPreviewAddedAtomPropInfo(petId, nextResonanceAttrsMap, maxLen)
end

function PetManagementUtils.getPetL10nName(petId)
	local petName
	local pet = pg.me:getPetInfo(petId)

	if pet.customName and pet.customName ~= "" then
		petName = pet.customName
	else
		local pData = PetData[pet.templateId] or {}

		petName = pData.name
	end

	local l10nName = petName and pg.getLocalizationText(petName) or ""

	if pg.game.setting:getShowDebugId() then
		l10nName = l10nName .. tostring(pet.templateId)
	end

	return l10nName
end

function PetManagementUtils.reqUpgradeResonance(petId, callback)
	if not petId then
		if callback then
			callback()
		end

		return
	end

	local oldStage, oldLv = PetManagementUtils.getPetCurStarSLv(petId)

	pg.me:serverMsg("RPC_CS_UpgradeResonance", petId, function(noticeId)
		local info

		if noticeId == NoticeDef.SUCCESS then
			local newStage, newLv = PetManagementUtils.getPetCurStarSLv(petId)

			info = {
				petId = petId,
				oldStage = oldStage,
				oldLv = oldLv,
				newStage = newStage,
				newLv = newLv
			}

			facade:sendMsgToUI(MessageName.PET_RESONANCE_CHANGE, info)
		end

		if callback then
			callback(noticeId, info)
		end
	end)
end

function PetManagementUtils.debugPopBreakPop(stage, lv)
	facade:sendMsgToUI(MessageName.PET_RESONANCE_CHANGE_DEBUG, {
		stage = stage,
		lv = lv
	})
end

function PetManagementUtils.renderFightPetSupport(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local btnDelUButton = objectReference:GetRefValue("btnDelUButton")
	local nameUText = objectReference:GetRefValue("nameUText")
	local hpBarUHealthbar = objectReference:GetRefValue("hpBarUHealthbar")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local elementsUList = objectReference:GetRefValue("elementsUList")
	local iconOrientationUImage = objectReference:GetRefValue("iconOrientationUImage")
	local nameShineUSDFText = objectReference:GetRefValue("nameShineUSDFText")
	local nameShineUSDFText1 = objectReference:GetRefValue("nameShineUSDFText1")
	local deleteHotKeyContent = objectReference:GetRefValue("deleteHotKeyContent")
	local skillUWidget = objectReference:GetRefValue("skillUWidget")
	local skillNameUWidget = objectReference:GetRefValue("skillNameUWidget")
	local iconSkillUImage = objectReference:GetRefValue("iconSkillUImage")
	local skillCostNumUSDFText = objectReference:GetRefValue("skillCostNumUSDFText")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local flshIconUButton = objectReference:GetRefValue("flshIconUButton")

	function elementsUList.luaRenderItem(btn, idx, eleData)
		LuaUIUtils.setElementButtonNew(btn, eleData.element)
	end

	local coreAbilityInfo = LuaUIUtils.getCoreAbilityInfo(data)

	if coreAbilityInfo then
		skillUWidget.gameObject:SetActiveEx(true)
		skillNameUWidget.gameObject:SetActiveEx(true)

		iconSkillUImage.url = LuaUIUtils.getSkillIcon(coreAbilityInfo.icon)

		ClientTextUtils.setText(skillCostNumUSDFText, coreAbilityInfo.epCost or 0)

		local name = ""

		if coreAbilityInfo.tagShowList and #coreAbilityInfo.tagShowList > 0 then
			name = coreAbilityInfo.tagShowList[1].tagName
		end

		ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(name))
	else
		skillUWidget.gameObject:SetActiveEx(false)
		skillNameUWidget.gameObject:SetActiveEx(false)
	end

	iconOrientationUImage.url = data.petTypeUrl

	if data.isShiny then
		button:TryChangePage("isFlash", 1)
		flshIconUButton:TryChangePage("Type", 0)
	elseif data.isMagic then
		button:TryChangePage("isFlash", 2)
		flshIconUButton:TryChangePage("Type", 1)
	else
		button:TryChangePage("isFlash", 0)
	end

	PetManagementDataHelper.tryChangePetHeadBossTagPage(button, data.label)
	button:TryChangePage("isChange", data.isVariant and 1 or 0)
	iconUImage:SetUrlWithCallback(LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_ICON, data.label, data.gender), function()
		return
	end)
	elementsUList:SetList(data.elementNames)

	if data.gender == Const.GENDER_TYPE_MALE then
		button:TryChangePage("Gender", 0)
	elseif data.gender == Const.GENDER_TYPE_FEMALE then
		button:TryChangePage("Gender", 1)
	else
		button:TryChangePage("Gender", 2)
	end

	if data.customName and data.customName ~= "" then
		ClientTextUtils.setText(nameUText, data.customName)
		ClientTextUtils.setText(nameShineUSDFText, data.customName)
		ClientTextUtils.setText(nameShineUSDFText1, data.customName)
	else
		ClientTextUtils.setText(nameUText, pg.getLocalizationText(data.name))
		ClientTextUtils.setText(nameShineUSDFText, pg.getLocalizationText(data.name))
		ClientTextUtils.setText(nameShineUSDFText1, pg.getLocalizationText(data.name))
	end

	local hpRatio = data.hpRatio or 1

	hpBarUHealthbar.maxHp = 1
	hpBarUHealthbar.hp = hpRatio

	button:TryChangePage("Dead", hpRatio <= 0 and 1 or 0)
end

function PetManagementUtils.getPetRecommendList(petId)
	if not petId then
		return
	end

	local petInfo = pg.me:getPetInfo(petId)

	if not petInfo then
		return
	end

	local petCfg = PetData[petInfo.templateId]

	if not petCfg then
		return
	end

	local recommendIds = petCfg.recommend_addprop
	local recommendRatios = petCfg.recommend_userpercent

	if not recommendIds or not recommendRatios then
		return
	end

	local recommendSuitInfos = {}

	for i, recommendId in ipairs(recommendIds) do
		local newTempPropInfo = PetManagementUtils.getPetNewSixPropInfos(petId, true)

		newTempPropInfo.recommendId = recommendId
		newTempPropInfo.recommendRatio = recommendRatios[i]

		PetManagementUtils.caculateRecommendPPoints(petId, newTempPropInfo)

		newTempPropInfo.index = i

		table.insert(recommendSuitInfos, newTempPropInfo)
	end

	return recommendSuitInfos
end

function PetManagementUtils.caculateRecommendPPoints(petId, newTempPropInfo)
	local petInfo = pg.me:getPetInfo(petId)

	if not petInfo then
		return
	end

	local pData = PetData[petInfo.templateId] or {}
	local recommendAttrs = pData.recommend_attr
	local recommendId = newTempPropInfo.recommendId
	local recommendCfg = RecommendData[recommendId]
	local recommendAttrWeight = recommendCfg and recommendCfg.recommendPropWeight
	local normalWeights = recommendCfg and recommendCfg.weight

	if recommendAttrWeight then
		local flag = true

		while flag and newTempPropInfo.remainPotentialPointSum > 0 do
			flag = false

			for i, _ in pairs(recommendAttrWeight) do
				local newPropId = recommendAttrs[i]

				flag = newPropId and newTempPropInfo.remainPotentialPointSum > 0 and PetManagementUtils.tryAddStrengPointSum(petId, newPropId, 1, newTempPropInfo) or flag
			end
		end
	end

	if normalWeights then
		local flag = true

		while flag and newTempPropInfo.remainPotentialPointSum > 0 do
			flag = false

			for newPropId, weight in ipairs(normalWeights) do
				flag = weight > 0 and newTempPropInfo.remainPotentialPointSum > 0 and PetManagementUtils.tryAddStrengPointSum(petId, newPropId, weight, newTempPropInfo) or flag
			end
		end
	end

	if newTempPropInfo.remainPotentialPointSum > 0 then
		local flag = true

		while flag and newTempPropInfo.remainPotentialPointSum > 0 do
			flag = false

			for newPropId, propAttrName in ipairs(Const.NEW_BASE_PROP_IDX2ATTR_MAP) do
				flag = newTempPropInfo.remainPotentialPointSum > 0 and PetManagementUtils.tryAddStrengPointSum(petId, newPropId, 1, newTempPropInfo) or flag
			end
		end
	end
end

function PetManagementUtils.tryAddStrengPointSum(petId, newPropId, addLv, newTempPropInfo)
	if newPropId == nil then
		return false
	end

	local curNewPropDetailInfo = newTempPropInfo and newTempPropInfo.detailPropInfos and newTempPropInfo.detailPropInfos[newPropId]

	if not curNewPropDetailInfo then
		return false
	end

	local strengthenPoint = curNewPropDetailInfo.propertyStrengPoint or nil

	if strengthenPoint == nil then
		return false
	end

	if strengthenPoint >= (curNewPropDetailInfo.propertyStrengMax or 0) then
		return
	end

	local addedLv = strengthenPoint + addLv

	if addedLv > (curNewPropDetailInfo.propertyStrengMax or 0) then
		addLv = curNewPropDetailInfo.propertyStrengMax - strengthenPoint
	end

	local needPotentialPoint = 0

	for i = strengthenPoint + 1, strengthenPoint + addLv do
		needPotentialPoint = needPotentialPoint + FormulaData[3020].formula(i, math_floor)
	end

	if needPotentialPoint + newTempPropInfo.usedPotentialPointSum > newTempPropInfo.potentialPointSum then
		return false
	end

	strengthenPoint = strengthenPoint + addLv
	curNewPropDetailInfo.propertyStrengPoint = strengthenPoint
	newTempPropInfo.usedPotentialPointSum = newTempPropInfo.usedPotentialPointSum + needPotentialPoint
	newTempPropInfo.remainPotentialPointSum = newTempPropInfo.potentialPointSum - newTempPropInfo.usedPotentialPointSum
	curNewPropDetailInfo.m_usedPotentialPointSum = (curNewPropDetailInfo.m_usedPotentialPointSum or 0) + needPotentialPoint
	newTempPropInfo.detailPropInfos[newPropId] = curNewPropDetailInfo

	return true
end

function PetManagementUtils.isPetNewPropApplied(petId, checkSuitInfo)
	if not petId or not checkSuitInfo then
		return false
	end

	local petInfo = pg.me:getPetInfo(petId)

	if not petInfo then
		return false
	end

	local realInfos = PetManagementUtils.getPetNewSixPropInfos(petId)

	if not realInfos then
		return false
	end

	local realDetailInfos = realInfos.detailPropInfos

	if not realDetailInfos then
		return false
	end

	local checkDetailSuitInfos = checkSuitInfo.detailPropInfos

	if not checkDetailSuitInfos then
		return false
	end

	for newPropId, checkDetailInfo in pairs(checkDetailSuitInfos) do
		local realDetailInfo = realDetailInfos[newPropId]

		if not realDetailInfo then
			return false
		end

		if realDetailInfo.propertyStrengPoint ~= checkDetailInfo.propertyStrengPoint then
			return false
		end
	end

	if realInfos.potentialPointSum == 0 or realInfos.usedPotentialPointSum == 0 then
		return false
	end

	return true
end

function PetManagementUtils.getIsAppliedgRecommend(petId)
	if not petId then
		return false
	end

	return not PetManagementUtils.redDot_GetState(Const.CLIENT_KEY.PET_RECORD_APPLIED_RECOMMEND, petId)
end

function PetManagementUtils.redDot_GetState(redKey, petId)
	local isValid = pg.me:getRedDotRecord(redKey, redKey .. "_" .. petId, true)

	return isValid
end

function PetManagementUtils.redDot_RecordState(redKey, petId)
	pg.me:setRedDotRecord(redKey, redKey .. "_" .. petId, false)
end

local PetHandbookConfigData = require("Data.pet_handbook_config_data")
local ItemConst = require("Common.Const.ItemConst")

PetManagementUtils.FavoriteTypes = {
	HEAL = 3,
	SUP = 2,
	DPS = 1,
	NULL = 0,
	SHINNY_STAR = 10,
	HIGH_VALUE = 9,
	RARE_STAR = 8,
	LOVE_STAR = 7,
	FIVE_STAR = 6,
	ENERGY = 5,
	BREAK = 4
}

function PetManagementUtils.getPetFavoriteIconUrl(favoriteType)
	favoriteType = favoriteType or 0

	local PetHandbookConfigData = require("Data.pet_handbook_config_data")

	favoriteType = math.clamp(favoriteType, 0, PetHandbookConfigData.favoriteTypeMax - 1)

	return AddressDataConst["FAVORITE_STAR_ICON_" .. favoriteType]
end

function PetManagementUtils.setRenderFavoriteToolTips(button, petId)
	function button.luaRenderTooltip(_, component)
		PetManagementUtils._onRenderFavoritePopup(component, petId)

		PetManagementUtils._favoritePopup = component
	end
end

function PetManagementUtils._onRenderFavoritePopup(component, petId)
	local objectRef = component:GetComponent("ObjectReference")
	local txtTitleUSDFText = objectRef:GetRefValue("txtTitleUSDFText")

	ClientTextUtils.setText(txtTitleUSDFText, pg.getGameString("PET_FAVORITE_MARK"))

	local listUList = objectRef:GetRefValue("listUList")

	function listUList.luaRenderItem(subBtn, index, data)
		function subBtn.luaClick()
			local setType = data.isTaged and 0 or data.type

			pg.me:serverMsg("RPC_CS_PetModifyFavoriteType", petId, setType)
		end

		local objectRefrence = subBtn:GetComponent("ObjectReference")
		local iconUImage = objectRefrence:GetRefValue("iconUImage")

		iconUImage.url = PetManagementUtils.getPetFavoriteIconUrl(data.type)

		local rootUButton = objectRefrence:GetRefValue("uINodePetManagemengtMarkCellUButton")

		rootUButton.isSelected = data.isTaged
	end

	local favoriteList = PetManagementUtils.getFavoriteList(petId)

	listUList:SetList(favoriteList)
end

function PetManagementUtils.getFavoriteList(petId)
	if not petId then
		return {}
	end

	local petInfo = pg.me:getPetInfo(petId)
	local favoriteType = petInfo.favoriteType

	favoriteType = math.clamp(favoriteType, 0, PetHandbookConfigData.favoriteTypeMax - 1)

	local favoriteList = {}

	for favType = 0, PetHandbookConfigData.favoriteTypeMax - 1 do
		local index = favType

		favoriteList[index] = {
			type = favType,
			isTaged = favoriteType == favType
		}
	end

	return favoriteList
end

function PetManagementUtils.refreshFavoriteBtn(button, favoriteTtype, iconUImageRefKey)
	favoriteTtype = favoriteTtype or 0

	button:TryChangePage("enable", favoriteTtype > 0 and 1 or 0)
	button:TryChangePage("Favorite", favoriteTtype > 0 and 1 or 0)

	local refObj = button:GetComponent("ObjectReference")
	local iconUImage = refObj and refObj:GetRefValue(iconUImageRefKey or "iconUImage")

	if iconUImage then
		iconUImage.url = PetManagementUtils.getPetFavoriteIconUrl(favoriteTtype)
	end
end

function PetManagementUtils.onPetFavoriteChanged(petInfo)
	local petId = petInfo and petInfo.id or PetManagementUtils.petId

	if PetManagementUtils._favoritePopup then
		PetManagementUtils._onRenderFavoritePopup(PetManagementUtils._favoritePopup, petId)
	end
end

function PetManagementUtils.buildCommonPetTemplateIdSet(refKey)
	local groupData = refKey and CommonPetGroupData[refKey]

	if not groupData then
		return nil
	end

	local ids = {}

	for _, templateList in pairs(groupData) do
		for _, id in ipairs(templateList) do
			ids[id] = true
		end
	end

	return ids
end

function PetManagementUtils.buildRecommendPetTemplateIdSet(refKey)
	if not refKey then
		return nil
	end

	local ids = {}

	for _, recommendId in ipairs(refKey) do
		local recommendPet = RecommendPetData[recommendId]

		if recommendPet then
			for _, info in ipairs(recommendPet.petSet) do
				for _, petId in ipairs(info[2]) do
					ids[petId] = true
				end
			end
		end
	end

	return ids
end

function PetManagementUtils.setPetRatioUINode(petInfo, refUComp, forbidTooltip, isDecodeJson, isPlayCrownVx)
	if not petInfo then
		return
	end

	local isForbidPetPropUseBtn = PetManagementUtils.param and PetManagementUtils.param.isForbidPetPropUseBtn

	if not forbidTooltip then
		local ctrlConfig = PetManagementUtils.param and PetManagementUtils.param.ctrlConfig or {}
		local ctrlForbid = ctrlConfig.isForbidRatioToolTip or false

		if ctrlForbid then
			forbidTooltip = true
		end
	end

	if not petInfo.id and not forbidTooltip then
		return
	end

	local petId = petInfo.id
	local refObjComp = refUComp and refUComp.transform
	local refObj = refObjComp and refObjComp:GetComponent("ObjectReference")
	local uIPetInfoPanelQualityUComponent = refObj and refObj:GetRefValue("uIPetInfoPanelQualityUComponent")

	if not uIPetInfoPanelQualityUComponent then
		return
	end

	local txtNameUSDFText = refObj and refObj:GetRefValue("txtNameUSDFText")
	local btnTipsUButton = refObj and refObj:GetRefValue("btnTipsUButton")
	local iconPurpleUImage = refObj and refObj:GetRefValue("iconPurpleUImage")
	local iconUImage = refObj and refObj:GetRefValue("iconUImage")
	local particleStarUWidget = refObj and refObj:GetRefValue("particleStarUWidget")
	local iconMaxUWidget = refObj and refObj:GetRefValue("iconMaxUWidget")
	local glassesTs = iconUImage and iconUImage.transform and iconUImage.transform:Find("IconGlasses")
	local isCatchReporting = true

	if isDecodeJson then
		isCatchReporting = petInfo.isCatchReporting == true or petInfo.isCatchReportingStatus == true
	else
		isCatchReporting = petInfo:isCatchReporting() or petInfo.isCatchReportingStatus == true
	end

	if isCatchReporting then
		uIPetInfoPanelQualityUComponent:TryChangePage("NotVerified", 1)
		uIPetInfoPanelQualityUComponent:TryChangePage("IsMax", UIConst.PET_CROWN_STATE.NONE)
	else
		uIPetInfoPanelQualityUComponent:TryChangePage("NotVerified", 0)

		local PetInfo = require("CustomTypes.PetInfo")
		local pageIndex, ratingStr = 0, ""

		if not isDecodeJson then
			pageIndex, ratingStr = petInfo:getPropRatingResult()

			TimerManager.addNextFrameCb(function()
				local isShowShineTip = pg.game.petManage:getIsShowShineTip(petInfo)

				LuaUIUtils.safeSetUWidgetActive(iconPurpleUImage, isShowShineTip)
				LuaUIUtils.safeSetUWidgetActive(iconUImage, not isShowShineTip)
				LuaUIUtils.safeSetUWidgetActive(particleStarUWidget, pageIndex == 3 or isShowShineTip)

				local isShowMaxShine = pageIndex == 3 and pg.game.petManage:getIsShowMaxShineTip(petInfo) or false

				LuaUIUtils.safeSetGameObjectActive(glassesTs and glassesTs.gameObject, isShowMaxShine)
			end)
		else
			pageIndex, ratingStr = PetInfo.staticGetPropRatingResult(petInfo)

			LuaUIUtils.safeSetUWidgetActive(iconPurpleUImage, false)
			LuaUIUtils.safeSetUWidgetActive(iconUImage, true)
			LuaUIUtils.safeSetUWidgetActive(particleStarUWidget, false)
			LuaUIUtils.safeSetGameObjectActive(glassesTs and glassesTs.gameObject, false)
		end

		ratingStr = pg.getGameString(ratingStr)

		uIPetInfoPanelQualityUComponent:TryChangePage("Quality", pageIndex)
		ClientTextUtils.setText(txtNameUSDFText, ratingStr)

		local maxPageIndex = pg.game.petManage:getPetCrownStatePageIndex(petInfo)

		LuaUIUtils.safeTryChangePage(uIPetInfoPanelQualityUComponent, "IsMax", maxPageIndex)

		if maxPageIndex == 1 and isPlayCrownVx then
			iconMaxUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		end
	end

	if btnTipsUButton then
		btnTipsUButton.enabledTooltip = not forbidTooltip

		if not forbidTooltip then
			function btnTipsUButton.luaRenderTooltip(_, component)
				local objectReference = component:GetComponent("ObjectReference")
				local newRatioNodeUComp = objectReference:GetRefValue("newRatioNodeUComp")
				local petIconUImage = objectReference:GetRefValue("petIconUImage")
				local txtTipsUSDFText = objectReference:GetRefValue("txtTipsUSDFText")
				local txtBaseUSDFText = objectReference:GetRefValue("txtBaseUSDFText")
				local txtLvUSDFText = objectReference:GetRefValue("txtLvUSDFText")
				local listUList = objectReference:GetRefValue("listUList")
				local btnUseUComponent = objectReference:GetRefValue("btnUseUComponent")
				local btnUWidget = objectReference:GetRefValue("btnUWidget")

				btnUWidget:SetActive(not isForbidPetPropUseBtn)

				local iconPropUImage = objectReference:GetRefValue("iconPropUImage")
				local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
				local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
				local useTxtTipsUSDFText = objectReference:GetRefValue("useTxtTipsUSDFText")
				local rayBoxUWidget = objectReference:GetRefValue("rayBoxUWidget")
				local btnUseUButton = objectReference:GetRefValue("btnUseUButton")
				local tipsUWidget = objectReference:GetRefValue("tipsUWidget")
				local descUWidget = objectReference:GetRefValue("descUWidget")
				local txtDescUSDFText = objectReference:GetRefValue("txtDescUSDFText")

				PetManagementUtils.setPetRatioUINode(petInfo, newRatioNodeUComp)

				local templateId = petInfo.templateId
				local petData = PetData[templateId]
				local iconUrl = LuaUIUtils.getPetIcon(petData.iconName, LuaUIUtils.PET_ICON, petInfo.label, petInfo.gender)

				petIconUImage.url = iconUrl

				local maxLv = PetManagementUtils.getPetOldPropConfigMaxLv()
				local maxLvStr = pg.getGameString("PET_RATIO_MAX")

				ClientTextUtils.setText(txtTipsUSDFText, string.format(maxLvStr, maxLv))
				ClientTextUtils.setText(txtBaseUSDFText, pg.getGameString("PET_RATIO_BASE"))
				ClientTextUtils.setText(txtLvUSDFText, pg.getGameString("PET_RATIO_LEARN"))

				local propLevels = pg.game.petManage:getPetPropLevels(petInfo)

				function listUList.luaRenderItem(button, index, data)
					local objectReference = button:GetComponent("ObjectReference")
					local iconAttriUImage = objectReference:GetRefValue("iconAttriUImage")
					local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
					local txtTotalUSDFText = objectReference:GetRefValue("txtTotalUSDFText")
					local imgFillBaseUImage = objectReference:GetRefValue("imgFillBaseUImage")
					local imgFillAddUImage = objectReference:GetRefValue("imgFillAddUImage")
					local txtBaseUSDFText = objectReference:GetRefValue("txtBaseUSDFText")
					local txtAddUSDFText = objectReference:GetRefValue("txtAddUSDFText")

					iconAttriUImage.url = data and data.iconUrl or ""

					ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data and data.l18nNameKey or ""))
					ClientTextUtils.setText(txtTotalUSDFText, data and data.baseAndActiveTotalLv or 0)

					local baseRatio = (data and data.complexBaseLv or 0) / (data and data.max or 1)

					imgFillBaseUImage.fillAmount = baseRatio

					local addRatio = (data and data.learnt or 0) / (data and data.max or 1) + baseRatio

					imgFillAddUImage.fillAmount = addRatio

					ClientTextUtils.setText(txtBaseUSDFText, data and data.complexBaseLv or 0)
					ClientTextUtils.setText(txtAddUSDFText, data and data.learnt and data.learnt > 0 and "+" .. data.learnt or "0")
				end

				listUList:SetList(propLevels)

				local usedCount, maxCount = pg.game.petManage:getPetPropLevelMaxInfo(petId)
				local isReachedMax = maxCount <= usedCount

				btnUseUComponent:TryChangePage("Limit", isReachedMax and 1 or 0)

				if not isReachedMax then
					TimerManager.addNextFrameCb(function()
						local showShineTip = pg.game.petManage:getIsShowShineTip(petInfo)

						tipsUWidget:SetActive(showShineTip)
					end)
				end

				rayBoxUWidget:SetActive(not isReachedMax)

				local name = isReachedMax and pg.getGameString("PET_USE_ITEM_ENHANCE_PROP_REACHEDMAX") or pg.getGameString("PET_USE_ITEM_ENHANCE_PROP")

				ClientTextUtils.setText(txtNameUSDFText, name or "")
				ClientTextUtils.setText(txtNumUSDFText, usedCount .. "/" .. maxCount)
				ClientTextUtils.setText(useTxtTipsUSDFText, pg.getGameString("PET_USE_ITEM_ENHANCE_PROP_TIP") or "")

				local itemSimpleInfo = PetManagementUtils.getPetEnhancePropUseItemUIInfo()

				iconPropUImage.url = itemSimpleInfo.icon or ""

				if not isReachedMax and not isForbidPetPropUseBtn then
					function btnUseUButton.luaClick()
						local itemId = PetConfigData.PET_ENHANCE_PROP_ITEMID or 151000
						local haveCount = ItemUtils.getItemCountById(pg.me, itemId) or 0

						if haveCount < 1 then
							pg.global.showBubbleMessageById(NoticeDef.ITEM_COUNT_LACK)

							return
						end

						local retItems = LuaUIUtils.getInventoryProps(2, nil, itemId)

						pg.global.ui:open(UIConst.UI_ID_INVENTORY_PET_PROP_USE, {
							propData = retItems and retItems[1],
							sType = ItemConst.USEITEM_TYPE_PROPERTY_ENHANCE,
							petId = petId
						})
					end
				else
					btnUseUButton.luaClick = nil
				end

				local curExtraCntByEvent = petInfo and petInfo.propertyCountByEvent or 0
				local maxExtraCntByEvent = PetConfigData.individualPropEnhanceTimesMax or 0

				if curExtraCntByEvent > 0 then
					descUWidget:SetActive(true)

					local fStr = pg.getGameString("PET_EVENT_ENHANCE_PROP")

					fStr = (not fStr or fStr == "" or fStr == "PET_EVENT_ENHANCE_PROP") and "PET_EVENT_ENHANCE_PROP: %s/%s" or fStr

					ClientTextUtils.setText(txtDescUSDFText, string.format(fStr, curExtraCntByEvent, maxExtraCntByEvent))
				else
					descUWidget:SetActive(false)
				end
			end
		end
	end
end

function PetManagementUtils.getPetEnhancePropUseItemUIInfo()
	local itemId = PetConfigData.PET_ENHANCE_PROP_ITEMID or 151000
	local simpleInfo = ItemUtils.getItemSimpleInfo(itemId)

	return simpleInfo
end

function PetManagementUtils.learnPetPropLevel(petId, propIndex, toLevel, cb)
	pg.me:serverMsg("RPC_CS_LearnPetPropLevel", petId, propIndex, toLevel, function(noticeId)
		if noticeId == NoticeDef.SUCCESS then
			facade:sendMsgToUI(MessageName.PET_PROP_LEARN_CHANGE, {
				petId = petId,
				propIndex = propIndex,
				toLevel = toLevel
			})
		end
	end)
end

function PetManagementUtils.generateBaseData(playerInfo, petInfo)
	local headIcon = playerInfo.headIcon or 1
	local petName = petInfo.customName

	if petName == nil or petName == "" then
		petName = ""

		local pData = PetData[petInfo.templateId] or {}

		if pData then
			petName = pg.getLocalizationText(pData.name)
		end
	end

	local data = {
		avatarIcon = PlayerHeadIconData[headIcon].res,
		playerName = playerInfo.playerName,
		petName = petName,
		petCp = Utils.getCpValue(petInfo) or 0,
		petLevel = petInfo.level,
		petExp = petInfo.exp or 0,
		templateId = petInfo.templateId,
		resonanceInfo = petInfo.resonanceInfo
	}

	return data
end

function PetManagementUtils.getPetSimpleInfo(petId)
	local petInfo = pg.me:getPetInfo(petId)

	if not petInfo then
		return
	end

	local templateId = petInfo.templateId
	local petPrototypeId = petInfo.petPrototypeId
	local petData = PetData[templateId]
	local petHandbookMap = pg.me.petHandbookMap or {}
	local petHandbookInfo = petHandbookMap[petPrototypeId] or {}
	local isRare = Utils.isLabelShiny(petInfo.label)
	local _, elementNames = LuaUIUtils.getElementInfo(petData.elementType)
	local petSimpleInfo = {
		elementTypes = petData.elementType,
		gender = petInfo.gender,
		genderIcon = petInfo.gender == Const.GENDER_TYPE_MALE and AddressDataConst.UI_PET_INFO_GENDER_MALE or AddressDataConst.UI_PET_INFO_GENDER_FEMALE,
		headIconName = petData.iconName,
		iconName = petData.iconName,
		id = petInfo.id,
		isBoss = Utils.isLabelElite(petInfo.label),
		isVariant = Utils.isLabelVariant(petInfo.label),
		isNew = not petHandbookInfo:isCatched(),
		isRare = isRare,
		isRareNew = isRare and not petHandbookInfo:isShinyCatched(),
		label = petInfo.label,
		lv = petInfo.level,
		name = petInfo.customName and petInfo.customName ~= "" and petInfo.customName or pg.getLocalizationText(petData.name),
		templateId = templateId,
		cpValue = petInfo:getCpValue() or 0,
		elementNames = elementNames or {}
	}

	return petSimpleInfo
end

function PetManagementUtils.getIsUnlockCarrySlot(curLv)
	return curLv >= PetManagementUtils.getUnlockCarrySlotFuncMaxLv()
end

function PetManagementUtils.getUnlockCarrySlotFuncMaxLv()
	return PetConfigData.PET_TRAIN_CARRY_UNLOCK_MAXLV or 15
end

function PetManagementUtils.getPetCarryInfo(petId)
	local pCarryInfo = {}
	local petInfo = pg.me:getPetInfo(petId)

	if petInfo == nil then
		return pCarryInfo
	end

	local carryPosMap

	if pg.me.tempPets and pg.me.tempPets[petId] == petInfo then
		carryPosMap = pg.me.tempPetCoreCarryPosMap
	elseif pg.me.pets and pg.me.pets[petId] == petInfo then
		carryPosMap = pg.me.petCoreCarryPosMap
	end

	local carry = carryPosMap and carryPosMap:getItemPos(petId)
	local invId = carry and carry:invId() or 0
	local genId = carry and carry:genId() or 0

	pCarryInfo.isEquipped = genId ~= 0
	pCarryInfo.genID = genId
	pCarryInfo.invId = invId

	return pCarryInfo
end

function PetManagementUtils.refreshPetStarupPopInfo(petId, refUComp, extraInfo)
	local forbidCultivateWay = extraInfo.forbidCultivateWay or false
	local objectReference = refUComp:GetComponent("ObjectReference")
	local starUContainer = objectReference:GetRefValue("starUContainer")
	local txtLvUSDFText = objectReference:GetRefValue("txtLvUSDFText")
	local btnCultivateUButton = objectReference:GetRefValue("btnCultivateUButton")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local listUList = objectReference:GetRefValue("listUList")
	local emptyTxtUSDFText = objectReference:GetRefValue("emptyTxtUSDFText")

	PetManagementUtils.m_refreshStarUpContainer(petId, starUContainer, true)

	local curStarStage, curStar = PetManagementUtils.getPetCurStarSLv(petId)

	curStarStage = curStarStage or 0
	curStar = curStar or 0

	local lvFStr = pg.getGameString("PET_STARUP_POP_LV")

	lvFStr = (not lvFStr or lvFStr == "PET_STARUP_POP_LV") and "%dStage-%dstar" or lvFStr

	ClientTextUtils.setText(txtLvUSDFText, string_format(lvFStr, curStarStage, curStar))

	function btnCultivateUButton.luaClick()
		LuaUIUtils.tryOpenPetCultivateUI({
			toPage = Const.PetCulPageNames.STARUP,
			petId = petId
		})
	end

	ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("PET_GOTO_STARUP"))

	if forbidCultivateWay then
		TimerManager.addNextFrameCb(function()
			btnCultivateUButton:SetActive(false)
		end)
	end

	function listUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, data.l10nName)
		ClientTextUtils.setText(txtNumUSDFText, data.newVDispTxt)
	end

	local finalAttrs = PetManagementUtils.getPetFinalTargeResonanceStagelvDisplayAttrs2(petId, curStarStage, curStar)

	listUList:SetList(finalAttrs)

	if #finalAttrs == 0 then
		ClientTextUtils.setText(emptyTxtUSDFText, pg.getGameString("PET_STARUP_POP_NO_ATTR"))
	else
		ClientTextUtils.setText(emptyTxtUSDFText, "")
	end

	local isMax = PetManagementUtils.isMaxedResonance(curStarStage, curStar)

	refUComp:TryChangePage("Max", isMax and 1 or 0)
end

function PetManagementUtils.getBoxLockState(boxInfo)
	local BoxLockState = PetManagementDataHelper.BoxLockState

	if boxInfo:isTempLocked() then
		return BoxLockState.TEMP_LOCKED
	elseif boxInfo:isLocked() then
		return BoxLockState.LOCKED
	end

	return BoxLockState.UNLOCKED
end

function PetManagementUtils.setIsHidePetBoxEditorLockIcon(isHide)
	PetManagementUtils.isHidePetBoxEditorLockIcon = isHide
end

return PetManagementUtils
