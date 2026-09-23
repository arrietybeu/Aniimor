-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Utils\\PetInfoCardDisplayUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local AbilityConst = require("Common.Const.AbilityConst")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local PetManagementUtils = require("Utils.PetManagementUtils")
local Utils = require("Common.Utils.Utils")
local PetInfoCardDisplayUtils = {}

PetInfoCardDisplayUtils.TAB_ATTRIBUTE = 0
PetInfoCardDisplayUtils.TAB_SKILL = 1
PetInfoCardDisplayUtils.TAB_INFO = 2
PetInfoCardDisplayUtils.ALL_TAB_LIST = {
	PetInfoCardDisplayUtils.TAB_ATTRIBUTE,
	PetInfoCardDisplayUtils.TAB_SKILL,
	PetInfoCardDisplayUtils.TAB_INFO
}

local PET_CARD_SCENE_TEXTURE_SIZE = 1024
local PET_CARD_RAW_IMAGE_SCALE = 1.5

local function buildPetSkillInfo(skillAbilityMap, fieldName, abilityType)
	local abilityId = tonumber(skillAbilityMap[fieldName] or skillAbilityMap[abilityType] or skillAbilityMap[tostring(abilityType)])
	local isEmptyAbility = abilityId == nil or abilityId == 0 or abilityId == AbilityConst.ABILITY_ID_EMPTY

	if isEmptyAbility then
		return nil
	end

	return PetManagementDataHelper.getSkillInfosByAbilityId(abilityId, abilityType)
end

local function normalizePetInfo(petInfo)
	petInfo.name = petInfo.name or LuaUIUtils.getPetNameByPetInfo(petInfo)
	petInfo.level = petInfo.level or 1
	petInfo.exp = petInfo.exp or 0
	petInfo.cp = petInfo.cp or 0
	petInfo.elementNames = petInfo.elementNames or {}
	petInfo.breedTalent = petInfo.breedTalent or {}
	petInfo.pageIndex = petInfo.pageIndex or 0
	petInfo.ratingStribng = petInfo.ratingStribng or petInfo.ratingString or "INTERFACE_DISPLAY_RATING_1"
	petInfo.controlFeatureId = petInfo.controlFeatureId or 0
	petInfo.bookNum = petInfo.bookNum or 0
	petInfo.time = petInfo.time or 0
	petInfo.basePropertyList = petInfo.basePropertyList or {}

	for i = Const.BASE_PROPERTY_HP_IDX, Const.BASE_PROPERTY_ATK_MAG_IDX do
		local property = petInfo.basePropertyList[i] or {}

		property.indLv = property.indLv or 0
		property.iLvLn = property.iLvLn or 0
		petInfo.basePropertyList[i] = property
	end

	local shouldBuildSkillInfoMap = not Utils.isTable(petInfo.skillInfoMap) and Utils.isTable(petInfo.skillAbilityMap)

	if shouldBuildSkillInfoMap then
		local skillAbilityMap = petInfo.skillAbilityMap

		petInfo.skillInfoMap = {
			ultimate = buildPetSkillInfo(skillAbilityMap, "ultimate", AbilityConst.ULTIMATE_ABILITY),
			q = buildPetSkillInfo(skillAbilityMap, "q", AbilityConst.WEAPON_SKILL_ABILITY),
			e = buildPetSkillInfo(skillAbilityMap, "e", AbilityConst.WEAPON_SKILL_ABILITY2),
			explore = buildPetSkillInfo(skillAbilityMap, "explore", AbilityConst.EXPLORE_ABILITY)
		}
	end
end

local function getPetSkillInfo(skillInfoMap, fieldName, abilityType)
	return skillInfoMap[fieldName] or skillInfoMap[abilityType] or skillInfoMap[tostring(abilityType)]
end

local function hasPetBreedTalent(breedTalent)
	for _, talentInfo in ipairs(breedTalent) do
		if not talentInfo.empty then
			return true
		end
	end

	return false
end

local function refreshPetBreedTalent(btnTalentUButton, accessListUList, breedTalent)
	local isVisible = hasPetBreedTalent(breedTalent)

	if not isVisible then
		accessListUList:SetList(EMPTY_TABLE)
	end

	accessListUList:SetActive(isVisible)
	btnTalentUButton:SetActive(isVisible)
end

local function renderPetCarryItem(carryItemUComponent, carryData)
	if not carryItemUComponent then
		return
	end

	carryItemUComponent.gameObject:SetActiveEx(true)

	local objectReference = carryItemUComponent:GetComponent("ObjectReference")
	local iconPropUImage = objectReference:GetRefValue("iconPropUImage")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local txtStrengthenUSDFText = objectReference:GetRefValue("txtStrengthenUSDFText")
	local listGemsUList = objectReference:GetRefValue("listGemsUList")
	local rootUButton = objectReference:GetRefValue("rootUButton")

	if not carryData then
		carryItemUComponent:TryChangePage("Empty", 1)

		if rootUButton then
			rootUButton.enabledTooltip = false
		end

		return
	end

	carryItemUComponent:TryChangePage("Empty", 0)
	carryItemUComponent:TryChangePage("GoodState", carryData.isRecommend and 1 or 0)
	carryItemUComponent:TryChangePage("Quality", carryData.quality)

	iconPropUImage.url = carryData.icon

	ClientTextUtils.setText(txtNameUSDFText, carryData.name)
	ClientTextUtils.setText(txtStrengthenUSDFText, "+" .. (carryData.cLevel or 0))
	LuaUIUtils.refreshCarryAssistInfo(listGemsUList, nil, carryData, true)

	if rootUButton then
		rootUButton.enabledTooltip = false
	end
end

local function renderPetSkillPanel(content, petInfo)
	local objectReference = content.transform:GetComponent("ObjectReference")
	local skillUWidget = objectReference:GetRefValue("skillUWidget")
	local btnSkillPresetsUButton = objectReference:GetRefValue("btnSkillPresetsUButton")
	local skillPresetName = objectReference:GetRefValue("skillPresetName")
	local carryItemUComponent = objectReference:GetRefValue("carryItemUComponent")
	local skillObjectReference = skillUWidget.transform:GetComponent("ObjectReference")
	local btnUniqueSkillUButton = skillObjectReference:GetRefValue("btnUniqueSkillUButton")
	local btnNormalSkill1UButton = skillObjectReference:GetRefValue("btnNormalSkill1UButton")
	local btnNormalSkill2UButton = skillObjectReference:GetRefValue("btnNormalSkill2UButton")
	local btnExploreSkillUButton = skillObjectReference:GetRefValue("btnExploreSkillUButton")
	local btnFeaturesUButton = skillObjectReference:GetRefValue("btnFeaturesUButton")
	local txtUniqueUSDFText = skillObjectReference:GetRefValue("txtUniqueUSDFText")
	local skillInfoMap = petInfo.skillInfoMap or {}

	if btnSkillPresetsUButton then
		btnSkillPresetsUButton.gameObject:SetActiveEx(false)
	end

	ClientTextUtils.setText(txtUniqueUSDFText, pg.getGameString("PETSKILL_ULTIMATE"))
	ClientTextUtils.setText(skillPresetName, petInfo.skillPresetName or "")
	PetManagementUtils._renderSkillCmp(btnUniqueSkillUButton, getPetSkillInfo(skillInfoMap, "ultimate", AbilityConst.ULTIMATE_ABILITY), false, true)
	PetManagementUtils._renderSkillCmp(btnNormalSkill1UButton, getPetSkillInfo(skillInfoMap, "q", AbilityConst.WEAPON_SKILL_ABILITY))

	btnNormalSkill1UButton.draggable = false

	PetManagementUtils._renderSkillCmp(btnNormalSkill2UButton, getPetSkillInfo(skillInfoMap, "e", AbilityConst.WEAPON_SKILL_ABILITY2))

	btnNormalSkill2UButton.draggable = false

	PetManagementUtils._renderExploreSkillCmp(btnExploreSkillUButton, getPetSkillInfo(skillInfoMap, "explore", AbilityConst.EXPLORE_ABILITY))
	PetManagementUtils.renderPetFeature(btnFeaturesUButton, petInfo.featureInfo)
	renderPetCarryItem(carryItemUComponent, petInfo.carryData)
end

local function bindPetHomeInfoClick(infoComp, petInfo)
	local objectReference = infoComp.transform:GetComponent("ObjectReference")
	local btnTalentUButton = objectReference:GetRefValue("btnTalentUButton")
	local btnAbilityUButton = objectReference:GetRefValue("btnAbilityUButton")
	local targetRect = objectReference:GetRefValue("uINodePetPanelInfoUComponent")

	function btnTalentUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_PET_GIFT_TIPS, {
			hierarchyMode = 2,
			autoHor = true,
			targetRect = targetRect,
			type = UIConst.GIFT_TYPE.HOME,
			showType = UIConst.GIFT_SHOW_TYPE.GIFT,
			giftType = UIConst.GIFT_TYPE.HOME,
			breedTalent = petInfo.breedTalent,
			petId = petInfo.id
		})
	end

	function btnAbilityUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_PET_GIFT_TIPS, {
			hierarchyMode = 2,
			autoHor = true,
			targetRect = targetRect,
			showType = UIConst.GIFT_SHOW_TYPE.ABILITY,
			abilityData = LuaUIUtils.getHomeAbilityData(petInfo.templateId)
		})
	end
end

local function renderPetPreview(scene, content, rawImageRawImagePro, petInfo)
	if not scene or IsNil(content) or IsNil(rawImageRawImagePro) then
		return
	end

	local shouldResetTexture = scene.textureWidth ~= PET_CARD_SCENE_TEXTURE_SIZE or scene.textureHeight ~= PET_CARD_SCENE_TEXTURE_SIZE

	if shouldResetTexture then
		scene:setExRawImageProRef(rawImageRawImagePro, PET_CARD_SCENE_TEXTURE_SIZE, PET_CARD_SCENE_TEXTURE_SIZE)

		scene.textureWidth = PET_CARD_SCENE_TEXTURE_SIZE
		scene.textureHeight = PET_CARD_SCENE_TEXTURE_SIZE
	else
		scene:setRawImageProRef(rawImageRawImagePro)
	end

	scene:previewPetByTId(petInfo.templateId, true, petInfo.selectTransmogScheme, petInfo)
end

local function renderPetInfoPanel(content, petInfo, options)
	local infoComp = content:GetComponent("UComponent")

	LuaUIUtils.renderOtherPetInfoPanel(infoComp, petInfo)

	local objectReference = infoComp.transform:GetComponent("ObjectReference")
	local btnTalentUButton = objectReference:GetRefValue("btnTalentUButton")
	local accessListUList = objectReference:GetRefValue("accessListUList")

	refreshPetBreedTalent(btnTalentUButton, accessListUList, petInfo.breedTalent)
	bindPetHomeInfoClick(infoComp, petInfo)

	if options.onInfoPanelRendered then
		options.onInfoPanelRendered(infoComp, petInfo)
	end

	local rawImageRawImagePro = objectReference:GetRefValue("rawImageRawImagePro")

	if IsNil(rawImageRawImagePro) then
		return
	end

	local sizeDelta = rawImageRawImagePro.transform.sizeDelta

	options.state.rawImageBaseSize = options.state.rawImageBaseSize or {
		x = sizeDelta.x,
		y = sizeDelta.y
	}

	rawImageRawImagePro.transform:SetSizeDeltaEx(options.state.rawImageBaseSize.x * PET_CARD_RAW_IMAGE_SCALE, options.state.rawImageBaseSize.y * PET_CARD_RAW_IMAGE_SCALE)

	local function onPetPreviewReady(scene)
		renderPetPreview(scene, content, rawImageRawImagePro, petInfo)
	end

	if options.ensurePetPreviewUIScene then
		options.ensurePetPreviewUIScene(onPetPreviewReady)
	end
end

local function renderTabContainer(container, renderContent)
	if container:CheckURLLoaded() then
		renderContent(container.content)

		return
	end

	local function onContentLoaded(content)
		if NotNil(content) then
			renderContent(content)
		end
	end

	container:LoadDefaultUrlManually(onContentLoaded)
end

local function getVisibleTabInfo(options)
	local visibleTabList = options.visibleTabList or PetInfoCardDisplayUtils.ALL_TAB_LIST
	local visibleTabSet = {}

	for _, tabIndex in ipairs(visibleTabList) do
		visibleTabSet[tabIndex] = true
	end

	local defaultTab = options.defaultTab or visibleTabList[1]

	return visibleTabSet, defaultTab
end

local function createTabRenderMap(petInfo, options)
	local function onRatioNodeReady(newRatioNodeUComp)
		PetManagementUtils.setPetRatioUINode(petInfo, newRatioNodeUComp, true, true)
	end

	local function renderAttributeContent(content)
		local abilityComp = content:GetComponent("UComponent")

		LuaUIUtils.renderOtherPetPanelAbilityTitle(abilityComp, petInfo, true)
		LuaUIUtils.renderOtherPetPanelAbilityProperty(abilityComp, petInfo, true, onRatioNodeReady)

		local objectReference = abilityComp:GetComponent("ObjectReference"):GetRefValue("detail"):GetComponent("ObjectReference")
		local btnTalentUButton = objectReference:GetRefValue("btnTalentUButton")
		local accessListUList = objectReference:GetRefValue("accessListUList")

		refreshPetBreedTalent(btnTalentUButton, accessListUList, petInfo.breedTalent)
	end

	local function renderSkillContent(content)
		renderPetSkillPanel(content, petInfo)
	end

	local function renderInfoContent(content)
		renderPetInfoPanel(content, petInfo, options)
	end

	return {
		[PetInfoCardDisplayUtils.TAB_ATTRIBUTE] = renderAttributeContent,
		[PetInfoCardDisplayUtils.TAB_SKILL] = renderSkillContent,
		[PetInfoCardDisplayUtils.TAB_INFO] = renderInfoContent
	}
end

local function selectTab(tabButtons, tabContainers, renderTabMap, tabIndex)
	for index = PetInfoCardDisplayUtils.TAB_ATTRIBUTE, PetInfoCardDisplayUtils.TAB_INFO do
		local button = tabButtons[index]

		button:TryChangePage("select", index == tabIndex and 1 or 0)
	end

	for index = PetInfoCardDisplayUtils.TAB_ATTRIBUTE, PetInfoCardDisplayUtils.TAB_INFO do
		local container = tabContainers[index]

		container:SetActive(index == tabIndex)
	end

	renderTabContainer(tabContainers[tabIndex], renderTabMap[tabIndex])
end

local function bindTabButton(button, tabIndex, tabButtons, tabContainers, renderTabMap)
	function button.luaClick()
		selectTab(tabButtons, tabContainers, renderTabMap, tabIndex)
	end
end

local function bindTabs(tabButtons, tabContainers, renderTabMap, visibleTabSet, defaultTab)
	for tabIndex = PetInfoCardDisplayUtils.TAB_ATTRIBUTE, PetInfoCardDisplayUtils.TAB_INFO do
		local button = tabButtons[tabIndex]

		button:SetActive(visibleTabSet[tabIndex] == true)

		button.interactable = true

		bindTabButton(button, tabIndex, tabButtons, tabContainers, renderTabMap)
	end

	selectTab(tabButtons, tabContainers, renderTabMap, defaultTab)
end

function PetInfoCardDisplayUtils.render(component, petInfo, options)
	if IsNil(component) or not Utils.isTable(petInfo) then
		return false
	end

	options = options or {}
	options.state = options.state or {}

	normalizePetInfo(petInfo)

	local componentReference = component:GetComponent("ObjectReference")
	local panelTransform = componentReference:GetRefValue("panelTransform")
	local objectReference = panelTransform:GetComponent("ObjectReference")
	local tabButtons = {
		[PetInfoCardDisplayUtils.TAB_ATTRIBUTE] = objectReference:GetRefValue("attributeBtn"),
		[PetInfoCardDisplayUtils.TAB_SKILL] = objectReference:GetRefValue("skillBtn"),
		[PetInfoCardDisplayUtils.TAB_INFO] = objectReference:GetRefValue("infoBtn")
	}
	local tabContainers = {
		[PetInfoCardDisplayUtils.TAB_ATTRIBUTE] = objectReference:GetRefValue("panelAbilityUContainer"),
		[PetInfoCardDisplayUtils.TAB_SKILL] = objectReference:GetRefValue("panelSkillUContainer"),
		[PetInfoCardDisplayUtils.TAB_INFO] = objectReference:GetRefValue("panelInfoUContainer")
	}
	local visibleTabSet, defaultTab = getVisibleTabInfo(options)
	local renderTabMap = createTabRenderMap(petInfo, options)

	bindTabs(tabButtons, tabContainers, renderTabMap, visibleTabSet, defaultTab)

	return true
end

return PetInfoCardDisplayUtils
