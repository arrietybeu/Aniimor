-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketPetDetail\\Component\\TradeMarketPetSnapshotDetailComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local AbilityConst = require("Common.Const.AbilityConst")
local AddressDataConst = require("Const.AddressDataConst")
local ClientConst = require("Const.ClientConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local PetManagementUtils = require("Utils.PetManagementUtils")
local TradeMarketPetSnapshotDetailComponent = Class.LightClass("TradeMarketPetSnapshotDetailComponent", UIComponent)
local PET_INFO_PAGE = {
	EMPTY = 3,
	INFO = 2,
	SKILL = 1,
	ATTRIBUTE = 0
}

local function getAbilityId(ability)
	if type(ability) == "table" then
		return tonumber(ability.abilityId)
	end

	return tonumber(ability)
end

local function getAbilityFromMap(abilityMap, abilityType)
	return abilityMap[abilityType] or abilityMap[tostring(abilityType)]
end

function TradeMarketPetSnapshotDetailComponent:onCtor()
	self._visible = true
end

function TradeMarketPetSnapshotDetailComponent:findObjects()
	self.petInfoPanelTransform = self.view.petInfoPanelObjectReference.transform
	self.panelAbilityUContainer = self.view.panelAbilityUContainer
	self.panelSkillUContainer = self.view.panelSkillUContainer
	self.panelInfoUContainer = self.view.panelInfoUContainer
	self.rightPanelUComponent = self.view.rightPanelUComponent
	self.attributeBtn = self.view.attributeBtn
	self.skillBtn = self.view.skillBtn
	self.infoBtn = self.view.infoBtn
end

function TradeMarketPetSnapshotDetailComponent:initView()
	self.petData = {
		isEmpty = true
	}
	self.pageIndex = PET_INFO_PAGE.ATTRIBUTE

	self:bindPetInfoTabs()
	self:initPetPreviewUIScene()
	self:refreshPetInfoDetail(self.petData)
end

function TradeMarketPetSnapshotDetailComponent:bindPetInfoTabs()
	function self.attributeBtn.luaClick()
		self:switchPetInfoPage(PET_INFO_PAGE.ATTRIBUTE)
	end

	function self.skillBtn.luaClick()
		self:switchPetInfoPage(PET_INFO_PAGE.SKILL)
	end

	function self.infoBtn.luaClick()
		self:switchPetInfoPage(PET_INFO_PAGE.INFO)
	end

	self.skillBtn.interactable = true
end

function TradeMarketPetSnapshotDetailComponent:initPetPreviewUIScene()
	self.petPreviewUISceneName = UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE
	self.petPreviewUIScene = pg.game.uiScene:getScene(self.petPreviewUISceneName)

	if not self.petPreviewUIScene then
		self.petPreviewUIScene = pg.game.uiScene:getUISceneInst(UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE, AddressDataConst.PET_MANAGEMENT_PREVIEW_SCENE_Prefab)
	end

	self.petPreviewUIScene:bindUICtrlKey(self.ctrl.module)

	if self.petPreviewUIScene:checkLoaded() then
		return
	end

	if not self.petPreviewUIScene:checkLoadStateIsNone() then
		self:waitPetPreviewUISceneLoaded()

		return
	end

	local loadingScene = self.petPreviewUIScene

	self.petPreviewUIScene:startLoad(function(succeed)
		if not succeed or not self.ctrl or self.petPreviewUIScene ~= loadingScene then
			return
		end

		self:onPetPreviewUISceneLoaded()
	end)
end

function TradeMarketPetSnapshotDetailComponent:waitPetPreviewUISceneLoaded()
	if self.waitPetPreviewUISceneFrameId then
		self:killFrameTimer(self.waitPetPreviewUISceneFrameId)
	end

	self.waitPetPreviewUISceneFrameId = self:startFrameTimer(function()
		self.waitPetPreviewUISceneFrameId = nil

		if not self.ctrl or not self.petPreviewUIScene then
			return
		end

		if not self.petPreviewUIScene:checkLoaded() then
			self:waitPetPreviewUISceneLoaded()

			return
		end

		self:onPetPreviewUISceneLoaded()
	end, 1)
end

function TradeMarketPetSnapshotDetailComponent:onPetPreviewUISceneLoaded()
	if not self:isPetPreviewUISceneReady() then
		return
	end

	self:scheduleActivatePetPreviewUIScene()

	if self.pageIndex == PET_INFO_PAGE.INFO then
		self:renderInfoPanel()
	end
end

function TradeMarketPetSnapshotDetailComponent:isPetPreviewUISceneReady()
	return self.petPreviewUIScene and self.petPreviewUIScene:checkLoaded() and self.petPreviewUIScene.scene and not IsNil(self.petPreviewUIScene.scene)
end

function TradeMarketPetSnapshotDetailComponent:scheduleActivatePetPreviewUIScene()
	if self.activatePetPreviewUISceneFrameId then
		self:killFrameTimer(self.activatePetPreviewUISceneFrameId)
	end

	self.activatePetPreviewUISceneFrameId = self:startFrameTimer(function()
		self.activatePetPreviewUISceneFrameId = nil

		if self.ctrl then
			self:activatePetPreviewUIScene()
		end
	end, 1)
end

function TradeMarketPetSnapshotDetailComponent:activatePetPreviewUIScene()
	if not self:isPetPreviewUISceneReady() then
		return
	end

	pg.game.uiScene:switchToScene(self.petPreviewUISceneName, true, true, true, self.ctrl.module)
	self.petPreviewUIScene:setLocalEnv()
end

function TradeMarketPetSnapshotDetailComponent:destroyPetPreviewUIScene()
	if not self.petPreviewUIScene then
		return
	end

	self.petPreviewUIScene:removeUICtrlKey(self.ctrl.module)
	pg.game.uiScene:switchOutScene(self.petPreviewUISceneName, self.petPreviewUIScene:checkHasUICtrlBind(), nil, self.ctrl.module)

	self.petPreviewUIScene = nil
	self.petPreviewUISceneName = nil
end

function TradeMarketPetSnapshotDetailComponent:buildPetSnapshotDisplayData(snapshot)
	local petData = PetManagementDataHelper.setUpPetInfoByTable(snapshot)
	local petInfo = petData and petData._petInfo

	if not petInfo then
		return {
			isEmpty = true
		}
	end

	local pageIndex, ratingString = petInfo:getPropRatingResult()

	petData.pageIndex = pageIndex
	petData.ratingString = ratingString
	petData.ratingStribng = ratingString
	petData.isCatchReporting = false
	petData.controlFeatureId = petData.characterInfo and petData.characterInfo.curCharacter or nil

	if petData.featureInfo and next(petData.featureInfo) == nil then
		petData.featureInfo = nil
	end

	petData.skillInfoMap = self:buildPetSkillInfoMap(petData)
	petData.skillPresetName = self:getPetSkillPresetName(petData)
	petData.carryData = snapshot.carryData
	petData.sourceDesc = snapshot.sourceDesc

	return petData
end

function TradeMarketPetSnapshotDetailComponent:buildPetSkillInfoMap(petData)
	local curAbilityMap = petData.curAbilityMap or {}
	local exploreAbilityList = petData.exploreAbilityList or {}
	local _, exploreAbilityId = next(exploreAbilityList)

	return {
		ultimate = self:buildPetSkillInfo(getAbilityId(getAbilityFromMap(curAbilityMap, AbilityConst.ULTIMATE_ABILITY)), AbilityConst.ULTIMATE_ABILITY),
		q = self:buildPetSkillInfo(getAbilityId(getAbilityFromMap(curAbilityMap, AbilityConst.WEAPON_SKILL_ABILITY)), AbilityConst.WEAPON_SKILL_ABILITY),
		e = self:buildPetSkillInfo(getAbilityId(getAbilityFromMap(curAbilityMap, AbilityConst.WEAPON_SKILL_ABILITY2)), AbilityConst.WEAPON_SKILL_ABILITY2),
		explore = self:buildPetSkillInfo(getAbilityId(exploreAbilityId), AbilityConst.EXPLORE_ABILITY)
	}
end

function TradeMarketPetSnapshotDetailComponent:buildPetSkillInfo(abilityId, abilityType)
	if not abilityId or abilityId == 0 or abilityId == AbilityConst.ABILITY_ID_EMPTY then
		return nil
	end

	return PetManagementDataHelper.getSkillInfosByAbilityId(abilityId, abilityType)
end

function TradeMarketPetSnapshotDetailComponent:getPetSkillPresetName(petData)
	local presetIndex = petData.curAbilityPreset or 1
	local presetMap = petData.abilityPresetMap or {}
	local presetInfo = presetMap[presetIndex] or presetMap[tostring(presetIndex)]

	if presetInfo and not string.isNilOrEmpty(presetInfo.name) then
		return presetInfo.name
	end

	return ClientTextUtils.concatByLanguage(pg.getGameString("ABILITY_PLAN"), presetIndex)
end

function TradeMarketPetSnapshotDetailComponent:refreshPetInfoDetail(snapshot)
	if not snapshot or snapshot.empty or snapshot.isEmpty then
		self.petData = {
			isEmpty = true
		}

		self.rightPanelUComponent:TryChangePage("tabInfo", PET_INFO_PAGE.EMPTY)

		return
	end

	self.petData = self:buildPetSnapshotDisplayData(snapshot)

	if self.petData.isEmpty then
		self.rightPanelUComponent:TryChangePage("tabInfo", PET_INFO_PAGE.EMPTY)

		return
	end

	self:switchPetInfoPage(self.pageIndex or PET_INFO_PAGE.ATTRIBUTE)

	return self.petData
end

function TradeMarketPetSnapshotDetailComponent:applyPetModelAppearance(entity, petInfo)
	if not entity or not petInfo or not petInfo.templateId then
		return
	end

	PetTransmogUtils.applySchemeTransmog(entity, petInfo.templateId, petInfo.selectTransmogScheme, true, true)
	entity:setModelLayer(ClientConst.LayerDefine.LAYER_UI_SCENE)
end

function TradeMarketPetSnapshotDetailComponent:setSelectedTab(index)
	self.attributeBtn:TryChangePage("select", index == PET_INFO_PAGE.ATTRIBUTE and 1 or 0)
	self.skillBtn:TryChangePage("select", index == PET_INFO_PAGE.SKILL and 1 or 0)
	self.infoBtn:TryChangePage("select", index == PET_INFO_PAGE.INFO and 1 or 0)
end

function TradeMarketPetSnapshotDetailComponent:switchPetInfoPage(index)
	if not self.petData or self.petData.isEmpty then
		self.rightPanelUComponent:TryChangePage("tabInfo", PET_INFO_PAGE.EMPTY)

		return
	end

	self.pageIndex = index

	self:setSelectedTab(index)
	self.rightPanelUComponent:TryChangePage("tabInfo", index)

	if index == PET_INFO_PAGE.ATTRIBUTE then
		self:renderAbilityPanel()
	elseif index == PET_INFO_PAGE.SKILL then
		self:renderSkillPanel()
	elseif index == PET_INFO_PAGE.INFO then
		self:renderInfoPanel()
	end
end

function TradeMarketPetSnapshotDetailComponent:renderAbilityPanel()
	local function renderAbilityContent(obj)
		if IsNil(obj) or not self.ctrl or not self.petData or self.petData.isEmpty then
			return
		end

		local abilityComp = obj:GetComponent("UComponent")

		LuaUIUtils.renderOtherPetPanelAbilityTitle(abilityComp, self.petData, true)
		LuaUIUtils.renderOtherPetPanelAbilityProperty(abilityComp, self.petData, true, function(newRatioNodeUComp)
			self:setPetRatioUINode(self.petData, newRatioNodeUComp)
		end)
	end

	if not self.panelAbilityUContainer:CheckURLLoaded() then
		self.panelAbilityUContainer:LoadDefaultUrlManually(renderAbilityContent)

		return
	end

	renderAbilityContent(self.panelAbilityUContainer.content)
end

function TradeMarketPetSnapshotDetailComponent:setPetRatioUINode(petInfo, newRatioNodeUComp)
	PetManagementUtils.setPetRatioUINode(petInfo, newRatioNodeUComp, true, true)
end

function TradeMarketPetSnapshotDetailComponent:renderSkillPanel()
	local function renderSkillContent(obj)
		if IsNil(obj) or not self.ctrl or not self.petData or self.petData.isEmpty then
			return
		end

		local objectReference = obj.transform:GetComponent("ObjectReference")
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
		local skillInfoMap = self.petData.skillInfoMap or {}

		if btnSkillPresetsUButton then
			btnSkillPresetsUButton.gameObject:SetActiveEx(false)
		end

		ClientTextUtils.setText(skillPresetName, self.petData.skillPresetName or "")
		PetManagementUtils._renderSkillCmp(btnUniqueSkillUButton, skillInfoMap.ultimate, false, true)
		PetManagementUtils._renderSkillCmp(btnNormalSkill1UButton, skillInfoMap.q)

		btnNormalSkill1UButton.draggable = false

		PetManagementUtils._renderSkillCmp(btnNormalSkill2UButton, skillInfoMap.e)

		btnNormalSkill2UButton.draggable = false

		PetManagementUtils._renderExploreSkillCmp(btnExploreSkillUButton, skillInfoMap.explore)
		PetManagementUtils.renderPetFeature(btnFeaturesUButton, self.petData.featureInfo)
		self:renderCarryItem(carryItemUComponent, self.petData.carryData)
	end

	if not self.panelSkillUContainer:CheckURLLoaded() then
		self.panelSkillUContainer:LoadDefaultUrlManually(renderSkillContent)

		return
	end

	renderSkillContent(self.panelSkillUContainer.content)
end

function TradeMarketPetSnapshotDetailComponent:renderCarryItem(carryItemUComponent, carryData)
	if not carryItemUComponent then
		return
	end

	carryItemUComponent.gameObject:SetActiveEx(true)

	local objectReference = carryItemUComponent:GetComponent("ObjectReference")
	local rootUButton = objectReference:GetRefValue("rootUButton")

	if not carryData then
		carryItemUComponent:TryChangePage("Empty", 1)

		if rootUButton then
			rootUButton.enabledTooltip = false
		end

		return
	end

	local iconPropUImage = objectReference:GetRefValue("iconPropUImage")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local txtStrengthenUSDFText = objectReference:GetRefValue("txtStrengthenUSDFText")
	local listGemsUList = objectReference:GetRefValue("listGemsUList")

	carryItemUComponent:TryChangePage("Empty", 0)
	carryItemUComponent:TryChangePage("GoodState", carryData.isRecommend and 1 or 0)
	carryItemUComponent:TryChangePage("Quality", carryData.quality or 0)

	iconPropUImage.url = carryData.icon

	ClientTextUtils.setText(txtNameUSDFText, carryData.name or "")
	ClientTextUtils.setText(txtStrengthenUSDFText, "+" .. (carryData.cLevel or 0))
	LuaUIUtils.refreshCarryAssistInfo(listGemsUList, nil, carryData, true)

	if rootUButton then
		rootUButton.enabledTooltip = false
	end
end

function TradeMarketPetSnapshotDetailComponent:renderInfoPanel()
	local function renderInfoContent(obj)
		if IsNil(obj) or not self.ctrl or not self.petData or self.petData.isEmpty then
			return
		end

		local infoComp = obj:GetComponent("UComponent")

		LuaUIUtils.renderOtherPetInfoPanel(infoComp, self.petData)

		if not self:isPetPreviewUISceneReady() then
			return
		end

		local objectReference = infoComp.transform:GetComponent("ObjectReference")
		local rawImageRawImagePro = objectReference:GetRefValue("rawImageRawImagePro")

		self.petPreviewUIScene:setRawImageProRef(rawImageRawImagePro)
		self.petPreviewUIScene:previewPetByTId(self.petData.templateId, true, self.petData.selectTransmogScheme, self.petData)
	end

	if not self.panelInfoUContainer:CheckURLLoaded() then
		self.panelInfoUContainer:LoadDefaultUrlManually(renderInfoContent)

		return
	end

	renderInfoContent(self.panelInfoUContainer.content)
end

function TradeMarketPetSnapshotDetailComponent:onShow()
	self:scheduleActivatePetPreviewUIScene()

	if self.pageIndex == PET_INFO_PAGE.INFO then
		self:renderInfoPanel()
	end
end

function TradeMarketPetSnapshotDetailComponent:onDestroy()
	if self.waitPetPreviewUISceneFrameId then
		self:killFrameTimer(self.waitPetPreviewUISceneFrameId)

		self.waitPetPreviewUISceneFrameId = nil
	end

	if self.activatePetPreviewUISceneFrameId then
		self:killFrameTimer(self.activatePetPreviewUISceneFrameId)

		self.activatePetPreviewUISceneFrameId = nil
	end

	self.attributeBtn.luaClick = nil
	self.skillBtn.luaClick = nil
	self.infoBtn.luaClick = nil
	self.petData = nil

	self:destroyPetPreviewUIScene()
	UIComponent.onDestroy(self)
end

return TradeMarketPetSnapshotDetailComponent
