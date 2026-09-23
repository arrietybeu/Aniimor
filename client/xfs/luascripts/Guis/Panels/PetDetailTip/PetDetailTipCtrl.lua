-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetDetailTip\\PetDetailTipCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PetDetailTipCtrl = Class.LightClass("PetDetailTipCtrl", UICtrl)
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local lume = require("Core.Common.lume")
local HotkeyConst = require("Const.HotkeyConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetResearchContentData = require("Data.pet_research_content_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local PetProtoTypeData = require("Data.pet_prototype_data")
local PetFeatureData = require("Data.pet_character_data")
local PetSkillData = require("Data.pet_skill_data")
local AbilityParamData = require("Data.ability_param_data")
local PetData = require("Data.pet_data")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local PetConfigData = require("Data.pet_config_data")
local AbilityConst = require("Common.Const.AbilityConst")
local PetManagementPreviewScene = require("GameApp.Scenes.UIScenes.PetManagementPreviewScene")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local AddressDataConst = require("Const.AddressDataConst")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local PetBasePrototypeToPrototypeMap = require("Data.pet_base_prototype_to_prototype_map")
local PetFormChangeData = require("Data.pet_form_change_data")
local UIConst = require("Const.UIConst")

PetDetailTipCtrl.messages = {}
PetDetailTipCtrl.SKILL_TYPE_NAME = {
	[0] = "TRANS_SKILL",
	"PHYSICAL_SKILL",
	"SP_SKILL"
}
PetDetailTipCtrl.SKILL_TYPE = {
	ultimate = "ultimate",
	normal = "normal",
	skill = "skill",
	appear = "appear"
}

local templateId = 1023300

local function bindTipSelected(button)
	function button.luaTooltipPopup(tipButton, isOpen)
		tipButton.isSelected = isOpen
	end
end

function PetDetailTipCtrl:onCreate(infos)
	UICtrl.onCreate(self, infos)

	templateId = infos.templateId or templateId
	self.templateIdList = infos.templateIdList
	self.fromResearch = infos.fromResearch
	self.fromRogue = infos.fromRogue
	self.fromRecommend = infos.fromRecommend
	self.needShowForm = infos.needShowForm
	self.fromCatchRogueGameId = infos.fromCatchRogueGameId

	if self.fromCatchRogueGameId and self.fromCatchRogueGameId ~= 0 then
		self.templateIdList = self.model:getCatchRogueTemplateIdList(self.fromCatchRogueGameId)
	end

	if PetResearchUtils.isKnownAndCaught(templateId) then
		self.view.btnPetManualDisplayUButton:TryChangePage("button", 0)
	else
		if PetData[templateId].hideGotoManual and PetData[templateId].hideGotoManual == 1 then
			self.view.btnPetManualUButton:SetActive(false)
			self.view.btnPetManualDisplayUButton:SetActive(false)
		else
			self.view.btnPetManualUButton:SetActive(true)
			self.view.btnPetManualDisplayUButton:SetActive(true)
		end

		self.view.btnPetManualDisplayUButton:TryChangePage("button", 4)
	end

	if not self.templateIdList or Utils.isEmptyTable(self.templateIdList) then
		self.view.titleUWidget:SetActive(false)
		self.view.btnCloseUButton:SetActive(true)
	else
		self.view.titleUWidget:SetActive(true)
		self.view.btnCloseUButton:SetActive(false)
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_TOWER_LEVEL_DETAIL) then
		self.view.btnPetManualUButton:SetActive(false)
		self.view.btnPetManualDisplayUButton:SetActive(false)
	end

	self.uiScene:setExRawImageProRef(self.view.rawImageRawImagePro, 1024, 1024)

	self.uiScene.scene.transform.position = Vector3(0, 500, 0)

	self:setPetRTInfo()
end

function PetDetailTipCtrl:onDestroy()
	UICtrl.onDestroy(self)

	PetResearchUtils.inDetailLoading = nil

	if self.fromResearch then
		local scene = pg.game.uiScene:getScene(UISceneConst.PET_RESEARCH_DETAIL_V3)

		if scene then
			scene:entActive(true)
		end
	end

	if self.fromRogue and pg.global.ui:containPanel(UIConst.UI_ID_TOWER_LEVEL_DETAIL) then
		pg.global.ui.towerLevelDetail:show()
	end

	if self.fromRecommend and pg.global.ui:containPanel(UIConst.UI_ID_RECOMMEND_PET) then
		pg.global.ui.recommendPet:show()
	end
end

function PetDetailTipCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.objectReference.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:dismiss()
		end
	end

	function self.view.btnCloseUButton.luaClick()
		self:dismiss()
	end

	function self.view.btnBackUButton.luaClick()
		self:dismiss()
	end

	function self.view.listElementUList.luaRenderItem(button, index, data)
		button:TryChangePage("type", data.element)
	end

	function self.view.listRecommendUList.luaRenderItem(button, index, data)
		bindTipSelected(button)

		local objectReference = button.transform:GetComponent("ObjectReference")
		local image = objectReference:GetRefValue("icon")

		image.url = data.icon

		local elementAndPetPop = objectReference:GetRefValue("elementAndPetPop")

		button.enabledTooltip = true

		button:SetHorizontalAlignment(1)

		button.PopupTool.popupTemplate = elementAndPetPop

		self:renderPetTip(button, data.id)
	end

	function self.view.featureListUList.luaRenderItem(button, index, data)
		bindTipSelected(button)

		local featureData = PetFeatureData[data.feature]

		if not featureData then
			return
		end

		local coms = self.view:getItemComs(button)

		ClientTextUtils.setText(coms.name, pg.getLocalizationText(featureData.name))

		coms.image.url = featureData.icon

		button:TryChangePage("IsRare", featureData.rare and 1 or 0)
		LuaUIUtils.setRenderFeatureToolTips(button, featureData)
	end

	function self.view.listSkillUList.luaRenderItem(button, index, data)
		bindTipSelected(button)

		local abParm = AbilityParamData[data.skill] or {}
		local coms = self.view:getItemComs(button)

		ClientTextUtils.setText(coms.name, pg.getLocalizationText(abParm.name))

		coms.image.url = LuaUIUtils.getSkillIcon(abParm.icon)

		local abilityId = AbilityUtils.getAbilityIdByParamId(data.templateBaseId, data.skill)
		local data1 = {
			abilityId = abilityId
		}

		table.merge(data1, abParm)
		LuaUIUtils.setRenderSKillTooTip(button, data1)
	end

	function self.view.listAbilityUList.luaRenderItem(button, _, data)
		bindTipSelected(button)

		local objectReference = button.transform:GetComponent("ObjectReference")
		local name = objectReference:GetRefValue("name")

		button:TryChangePage("Char", data.icon - 1)
		ClientTextUtils.setText(name, data.name)
		button:TryChangePage("Quality", data.level - 1)
		LuaUIUtils.setPetActionTip(button, data)
	end

	bindTipSelected(self.view.skillUniqueUButton)
	bindTipSelected(self.view.skillExploreUButton)

	function self.view.listSpecificUList.luaRenderItem(button, _, data)
		local objectReference = button.transform:GetComponent("ObjectReference")
		local image = objectReference:GetRefValue("image")

		image.url = data.headRes or ""

		button:SetActive(data.headRes ~= "")

		button.isSelected = data.id == templateId

		function button.luaClick()
			templateId = data.id

			LuaUIUtils.setUIViewVisible(self.view.rawImageRawImagePro, false)
			self:setPetLeftInfo()
			self:setPetMiddleInfo()
			self:setPetRightInfo()
			self:setPetRTInfo()
		end
	end

	function self.view.titlePetList.luaRenderItem(button, index, data)
		local objectReference = button.transform:GetComponent("ObjectReference")
		local image = objectReference:GetRefValue("iconUImage")

		image.url = data.headRes or ""

		button:SetActive(data.headRes ~= "")

		button.isSelected = data.id == templateId or table.contains(PetBasePrototypeToPrototypeMap[data.id], templateId)

		function button.luaClick()
			templateId = data.id

			self:onShow()
			self:setPetRTInfo()
		end
	end

	function self.view.btnPetManualUButton.luaClick()
		if self.fromResearch then
			self:dismiss()
			pg.global.ui.petResearchDetailV2:gotoPage(UIConst.HANDBOOK_PAGE_IDX.SURVEY)

			return
		end

		PetResearchUtils.openResearchDetail(templateId, UIConst.HANDBOOK_PAGE_IDX.SURVEY, {
			closeCb = function()
				self:show()

				if self.uiScene then
					self.uiScene:entActive(true)
				end
			end
		}, function()
			self:hide()

			if self.uiScene then
				self.uiScene:entActive(false)
			end
		end)
	end

	ClientTextUtils.setText(self.view.skillTxtTitle, pg.getGameString("PET_DETAIL_LEARNABLE_SKILL_TITLE"))
	ClientTextUtils.setText(self.view.txtTitle2UBaseText, pg.getGameString("PET_DETAIL_EXPLORE_SKILL_TITLE"))
	ClientTextUtils.setText(self.view.actionTxtTitle, pg.getGameString("PET_DETAIL_ACTION_ABILITY_TITLE"))
end

function PetDetailTipCtrl:onShow()
	ClientTextUtils.setText(self.view.txtTitleUBaseText, pg.getGameString("FAMILY_PROP"))
	LuaUIUtils.setUIViewVisible(self.view.rawImageRawImagePro, false)

	if self.templateIdList then
		self.view.titlePetList:SetList(self.model:getTitlePetList(self.templateIdList))
	end

	self:setPetLeftInfo()
	self:setPetMiddleInfo()
	self:setPetRightInfo()

	if self.needShowForm then
		self:setPetPhysiqueInfo()
	end

	if self.fromRogue and pg.global.ui:containPanel(UIConst.UI_ID_TOWER_LEVEL_DETAIL) then
		pg.global.ui.towerLevelDetail:hide()
	end

	if self.fromRecommend and pg.global.ui:containPanel(UIConst.UI_ID_RECOMMEND_PET) then
		pg.global.ui.recommendPet:hide()
	end
end

function PetDetailTipCtrl:setPetLeftInfo()
	self:setPetInfo()
	self:setPartnerInfo()
	self:setAbilityInfo()
end

function PetDetailTipCtrl:setPetInfo()
	local confProtoData = PetProtoTypeData[templateId]
	local confResearchData = PetResearchContentData[templateId]
	local templateBaseId = Utils.getBasePetPrototypeId(templateId)
	local confBaseResearchData

	if templateBaseId and templateBaseId > 0 then
		confBaseResearchData = PetResearchContentData[templateBaseId]
	end

	if not confResearchData or not confProtoData and templateBaseId > 0 and not confBaseResearchData then
		return
	end

	if templateBaseId > 0 and not confBaseResearchData then
		return
	end

	local petType = PetData[templateId].functionId

	self.view.imgOrientationUImage.url = PetConfigData.petFunctionIcon[petType]

	local displayNumber, isCustomNumber = PetResearchUtils.getDisplayNumberByTemplateId(templateId)

	if displayNumber ~= "" then
		local numberPrefix = isCustomNumber and "" or "NO."

		ClientTextUtils.setText(self.view.txtNumUBaseText, numberPrefix .. displayNumber)
	end

	local name = confResearchData.name or confBaseResearchData.name

	ClientTextUtils.setText(self.view.txtNameUBaseText, pg.getLocalizationText(name))
	ClientTextUtils.setText(self.view.txtDetailsUBaseText, pg.getLocalizationText(confResearchData.desc))

	local elementNames = confProtoData.elementType
	local elements = {}

	for _, elementName in ipairs(elementNames) do
		elements[#elements + 1] = {
			element = elementName
		}
	end

	self.view.listElementUList:SetList(elements)
end

function PetDetailTipCtrl:setPartnerInfo()
	local confProtoData = PetProtoTypeData[templateId]

	if not confProtoData then
		return
	end

	local recommendPartners = confProtoData.recommendPartners
	local confData
	local partners = {}

	for id, partner in ipairs(recommendPartners) do
		confData = PetData[partner]

		if confData then
			partners[#partners + 1] = {
				icon = LuaUIUtils.getPetIcon(confData.iconName, LuaUIUtils.PET_ICON, 0),
				id = partner
			}
		end
	end

	self.view.listRecommendUList:SetList(partners)
end

function PetDetailTipCtrl:setAbilityInfo()
	local pData = PetProtoTypeData[templateId]

	if pData == nil then
		return
	end

	ClientTextUtils.setText(self.view.hpNumberUBaseText, pData.species_hp_max_v)

	local rate = pData.species_hp_max_v / 100 > 1 and 1 or pData.species_hp_max_v / 100

	self.view.hpRateUWidget.transform.localScale = Vector3.New(rate, rate, rate)

	ClientTextUtils.setText(self.view.attackNumberUBaseText, pData.species_atk_v)

	rate = pData.species_atk_v / 100 > 1 and 1 or pData.species_atk_v / 100
	self.view.attackRateUWidget.transform.localScale = Vector3.New(rate, rate, rate)

	ClientTextUtils.setText(self.view.defendNumberUBaseText, pData.species_def_mag_v)

	rate = pData.species_def_v / 100 > 1 and 1 or pData.species_def_v / 100
	self.view.defendRateUWidget.transform.localScale = Vector3.New(rate, rate, rate)

	ClientTextUtils.setText(self.view.quickNumberUBaseText, pData.species_ep_regen_force_v)

	rate = pData.species_ep_regen_force_v / 100 > 1 and 1 or pData.species_ep_regen_force_v / 100
	self.view.quickRateUWidget.transform.localScale = Vector3.New(rate, rate, rate)

	ClientTextUtils.setText(self.view.magicDefendNumberUBaseText, pData.species_def_mag_v)

	rate = pData.species_def_mag_v / 100 > 1 and 1 or pData.species_def_mag_v / 100
	self.view.magicDefendRateUWidget.transform.localScale = Vector3.New(rate, rate, rate)

	ClientTextUtils.setText(self.view.magicAttackNumberUBaseText, pData.species_bp_atk_v)

	rate = pData.species_bp_atk_v / 100 > 1 and 1 or pData.species_bp_atk_v / 100
	self.view.magicAttackRateUWidget.transform.localScale = Vector3.New(rate, rate, rate)
end

function PetDetailTipCtrl:setPetMiddleInfo()
	self:setPetImageInfo()
	self:setPetBodyInfo()
end

function PetDetailTipCtrl:setPetImageInfo()
	return
end

function PetDetailTipCtrl:setPetBodyInfo()
	local data = PetProtoTypeData[templateId]

	if not data then
		return
	end

	LuaUIUtils.setUIViewVisible(self.view.rawImageRawImagePro, false)
end

function PetDetailTipCtrl:setPetPhysiqueInfo()
	local confProtoData = PetProtoTypeData[templateId]

	if confProtoData == nil then
		return
	end

	local baseId = Utils.getBasePetPrototypeId(templateId)
	local ids = PetBasePrototypeToPrototypeMap[baseId] or {}
	local idMap = {}
	local physiques = {}

	if not self.fromCatchRogueGameId then
		for index, id in ipairs(ids) do
			confProtoData = PetProtoTypeData[id]

			if confProtoData and (PetFormChangeData[id] or baseId == id) then
				physiques[#physiques + 1] = {
					headRes = LuaUIUtils.getPetIcon(confProtoData.iconName, LuaUIUtils.PET_ICON),
					id = id
				}
				idMap[id] = true
			end
		end
	end

	for index, id in ipairs(self.templateIdList) do
		local bId = Utils.getBasePetPrototypeId(id)

		confProtoData = PetProtoTypeData[id]

		if bId == baseId and not idMap[id] and confProtoData then
			physiques[#physiques + 1] = {
				headRes = LuaUIUtils.getPetIcon(confProtoData.iconName, LuaUIUtils.PET_ICON),
				id = id
			}
			idMap[id] = true
		end
	end

	table.sort(physiques, function(a, b)
		return a.id < b.id
	end)
	self.view.listSpecificUList:SetList(physiques)
end

function PetDetailTipCtrl:setPetRightInfo()
	self:setCharacteristicsInfo()
	self:setSkillInfo()
	self:setExplorationInfo()
	self:setActionsInfo()
end

function PetDetailTipCtrl:setCharacteristicsInfo()
	local data = PetProtoTypeData[templateId]

	if not data then
		return
	end

	local features = {}

	for _, feature in ipairs(data.feature or EMPTY_TABLE) do
		features[#features + 1] = {
			feature = feature
		}
	end

	self.view.featureListUList:SetList(features)
end

function PetDetailTipCtrl:setSkillInfo()
	local data = PetSkillData[templateId]
	local templateBaseId = Utils.getBasePetPrototypeId(templateId)

	if not data and templateBaseId and templateBaseId > 0 then
		data = PetSkillData[templateBaseId]
	end

	if not data then
		return
	end

	local skills = {}
	local ultimateSkill

	for id, skill in pairs(data) do
		if self.SKILL_TYPE.ultimate == skill.abilityType then
			ultimateSkill = id
		elseif (self.SKILL_TYPE.normal == skill.abilityType or self.SKILL_TYPE.skill == skill.abilityType) and skill.isShare == 1 and (not skill.needPetFormsUnlock or skill.needPetFormsUnlock and lume.find(skill.needPetFormsUnlock, templateId)) then
			if self.SKILL_TYPE.normal == skill.abilityType then
				table.insert(skills, 1, {
					skill = id,
					templateBaseId = templateBaseId
				})
			else
				skills[#skills + 1] = {
					skill = id,
					templateBaseId = templateBaseId
				}
			end
		end
	end

	self.view.listSkillUList:SetList(skills)

	local abParm = AbilityParamData[ultimateSkill]

	self.view.skillUniqueUButton:SetActive(false)
	self.view.line1UWidget:SetActive(false)

	if abParm then
		self.view.line1UWidget:SetActive(true)
		self.view.skillUniqueUButton:SetActive(true)
		ClientTextUtils.setText(self.view.uniqueSkillName, pg.getLocalizationText(abParm.name))

		self.view.uniqueIconSkillUImage.url = LuaUIUtils.getSkillIcon(abParm.icon)

		local abilityId = AbilityUtils.getAbilityIdByParamId(templateBaseId, ultimateSkill)
		local data1 = {
			abilityId = abilityId
		}

		table.merge(data1, abParm)
		LuaUIUtils.setRenderSKillTooTip(self.view.skillUniqueUButton, data1)
	end
end

function PetDetailTipCtrl:setActionsInfo()
	local exploreAbilityList = PetData[templateId].exploreAbilityList

	if exploreAbilityList then
		self.view.line2UWidget:SetActive(self.showLine2)
		self.view.skillExploreUButton:SetActive(true)

		local explores = {}

		for _, id in pairs(exploreAbilityList) do
			local item = {}
			local abilityParamData = pg.global.abilityMgr:getAbilityParamData(id)

			item.abilityId = id
			item.name = pg.getLocalizationText(abilityParamData.name)
			item.desc = pg.getLocalizationText(abilityParamData.desc)
			item.icon = abilityParamData.icon
			explores[#explores + 1] = item

			ClientTextUtils.setText(self.view.iconExploreSkillName, pg.getLocalizationText(item.name))

			self.view.iconExploreSkillUImage.url = LuaUIUtils.getSkillIcon(item.icon)
			self.view.skillExploreUButton.enabledTooltip = true
			self.view.skillExploreUButton.isSelected = false

			LuaUIUtils.setRenderExploreToolTips(self.view.skillExploreUButton, item)
		end
	else
		self.view.line2UWidget:SetActive(false)
		self.view.skillExploreUButton:SetActive(false)
	end
end

function PetDetailTipCtrl:setExplorationInfo()
	local res = {}
	local petData = PetData[templateId]

	if petData == nil then
		return
	end

	local climb = AbilityConst.SPECIFIC_ABILITY_INDEX_2_NAME[1]

	if petData[climb] then
		res[#res + 1] = {
			icon = 1,
			level = petData[climb],
			actionName = climb,
			name = pg.getGameString(LuaUIUtils.EXPLORE_SKILL_NAME[climb]),
			desc = PetConfigData.climbInfo
		}
	end

	local fly = AbilityConst.SPECIFIC_ABILITY_INDEX_2_NAME[5]

	if petData[fly] then
		res[#res + 1] = {
			icon = 2,
			level = petData[fly],
			actionName = fly,
			name = pg.getGameString(LuaUIUtils.EXPLORE_SKILL_NAME[fly]),
			desc = PetConfigData.flyInfo
		}
	end

	local swim = AbilityConst.SPECIFIC_ABILITY_INDEX_2_NAME[3]

	if petData[swim] then
		res[#res + 1] = {
			icon = 3,
			level = petData[swim],
			actionName = swim,
			name = pg.getGameString(LuaUIUtils.EXPLORE_SKILL_NAME[swim]),
			desc = PetConfigData.swimInfo
		}
	end

	if res and #res > 0 then
		self.showLine2 = true

		self.view.listAbilityUList:SetList(res)
		self.view.listAbilityUList:SetActive(true)
	else
		self.showLine2 = false

		self.view.listAbilityUList:SetList({})
		self.view.listAbilityUList:SetActive(false)
	end
end

function PetDetailTipCtrl:setPetRTInfo()
	if self.uiScene then
		LuaUIUtils.setUIViewVisible(self.view.rawImageRawImagePro, true)
		self.uiScene:previewPetByTId(templateId, false)

		if templateId == 1023300 then
			local rawImage = self.view.rawImageRawImagePro

			if rawImage and rawImage.rectTransform then
				rawImage.rectTransform.anchoredPosition = Vector2(734, 390)
			end

			local entity = self.uiScene.curEntity

			if entity and entity.eModel then
				local rot = Quaternion.Euler(0, 8, 0)

				entity.eModel:SetTransformLocalRotation(rot[1], rot[2], rot[3], rot[4])
				entity.eModel:SetTransformLocalPosition(0.5, -0.34, 0)
				entity:setScaleNumber(0.64)
			end
		end
	end
end

function PetDetailTipCtrl:openPreviewScene()
	self.petManagementSceneCtrl = PetManagementPreviewScene.new(UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE, AddressDataConst.PET_MANAGEMENT_PREVIEW_SCENE_Prefab, nil, {
		uiId = UIConst.UI_ID_PET_DETAIL
	})

	self.petManagementSceneCtrl:startLoad(function()
		self.petManagementSceneCtrl.scene.transform.position = Vector3(0, 500, 0)

		pg.game.uiScene:switchToScene(self:getUISceneName())

		if self.view.rawImageRawImagePro then
			self.petManagementSceneCtrl:setRawImageProRef(self.view.rawImageRawImagePro)
		end

		self:setPetRTInfo()
	end, {
		textureHeight = 1024,
		textureWidth = 1024
	})
end

function PetDetailTipCtrl:closePreviewScene()
	pg.game.uiScene:switchOutScene(self:getUISceneName())
end

function PetDetailTipCtrl:renderPetTip(button, key)
	function button.luaRenderTooltip(btn, cmp)
		local objectReference = cmp:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local iconPetUImage = objectReference:GetRefValue("iconPetUImage")
		local listTagUList = objectReference:GetRefValue("listTagUList")
		local txtOrientationUSDFText = objectReference:GetRefValue("txtOrientationUSDFText")
		local txtContentUSDFText = objectReference:GetRefValue("txtContentUSDFText")

		cmp:TryChangePage("Type", 0)

		local petType = PetData[key].functionId

		ClientTextUtils.setText(txtOrientationUSDFText, pg.getLocalizationText(PetConfigData[string.format("petFunctionText%s", petType)]) or "")
		ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(PetData[key].name))
		ClientTextUtils.setText(txtContentUSDFText, PetResearchContentData[key] ~= nil and pg.getLocalizationText(PetResearchContentData[key].desc) or "EMPTY")

		iconPetUImage.url = LuaUIUtils.getPetIcon(PetData[key].iconName, LuaUIUtils.PET_ICON)

		local _, elementNames = LuaUIUtils.getElementInfo(PetData[key].elementType)

		function listTagUList.luaRenderItem(button1, _, data1)
			LuaUIUtils.setElementButtonNew(button1, data1.element, nil, nil, {
				eleBtnClickFunc = function(elementName)
					if button then
						button:CloseTooltip(true)
					end
				end
			})
		end

		listTagUList:SetList(elementNames)
	end
end

function PetDetailTipCtrl:getUISceneName()
	return UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE .. UIConst.UI_ID_PET_DETAIL
end

return PetDetailTipCtrl
