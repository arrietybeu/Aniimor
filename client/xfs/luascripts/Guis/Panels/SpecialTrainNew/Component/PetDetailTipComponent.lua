-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SpecialTrainNew\\Component\\PetDetailTipComponent.lua

local Class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetResearchContentData = require("Data.pet_research_content_data")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local PetFeatureData = require("Data.pet_character_data")
local PetSkillData = require("Data.pet_skill_data")
local AbilityParamData = require("Data.ability_param_data")
local PetData = require("Data.pet_data")
local Const = require("Common.Const.Const")
local PetConfigData = require("Data.pet_config_data")
local AbilityConst = require("Common.Const.AbilityConst")
local UIComponent = require("Guis.Helper.UIComponent")
local PetProtoTypeData = require("Data.pet_prototype_data")
local Utils = require("Common.Utils.Utils")
local UIConst = require("Const.UIConst")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local PetDetailTipComponent = Class.LightClass("PetDetailTipComponent", UIComponent)

PetDetailTipComponent.messages = {}
PetDetailTipComponent.SKILL_TYPE_NAME = {
	[0] = "TRANS_SKILL",
	"PHYSICAL_SKILL",
	"SP_SKILL"
}
PetDetailTipComponent.SKILL_TYPE = {
	skill = "skill",
	appear = "appear",
	ultimate = "ultimate",
	normal = "normal"
}

local templateId = 1023300

function PetDetailTipComponent:ctor(ctrl)
	self.ctrl = ctrl
	self.model = ctrl.model
	self.view = ctrl.view
	self.skillListData = nil
	self.selectedSkillId = nil

	self:findObjects()
end

function PetDetailTipComponent:findObjects()
	self.objectReference = self.view.detailRoot
	self.imgOrientationUImage = self.objectReference:GetRefValue("imgOrientationUImage")
	self.txtNumUBaseText = self.objectReference:GetRefValue("txtNumUBaseText")
	self.txtNameUBaseText = self.objectReference:GetRefValue("txtNameUBaseText")
	self.txtDetailsUBaseText = self.objectReference:GetRefValue("txtDetailsUBaseText")
	self.listElementUList = self.objectReference:GetRefValue("listElementUList")
	self.txtRecommendUBaseText = self.objectReference:GetRefValue("txtRecommendUBaseText")
	self.listRecommendUList = self.objectReference:GetRefValue("listRecommendUList")
	self.hpNumberUBaseText = self.objectReference:GetRefValue("hpNumberUBaseText")
	self.attackNumberUBaseText = self.objectReference:GetRefValue("attackNumberUBaseText")
	self.defendNumberUBaseText = self.objectReference:GetRefValue("defendNumberUBaseText")
	self.quickNumberUBaseText = self.objectReference:GetRefValue("quickNumberUBaseText")
	self.magicDefendNumberUBaseText = self.objectReference:GetRefValue("magicDefendNumberUBaseText")
	self.magicAttackNumberUBaseText = self.objectReference:GetRefValue("magicAttackNumberUBaseText")
	self.hpUWidget = self.objectReference:GetRefValue("hpUWidget")
	self.attackUWidget = self.objectReference:GetRefValue("attackUWidget")
	self.defendUWidget = self.objectReference:GetRefValue("defendUWidget")
	self.quickUWidget = self.objectReference:GetRefValue("quickUWidget")
	self.magicDefendUWidget = self.objectReference:GetRefValue("magicDefendUWidget")
	self.magicAttackUWidget = self.objectReference:GetRefValue("magicAttackUWidget")
	self.hpRateUWidget = self.objectReference:GetRefValue("hpRateUWidget")
	self.magicAttackRateUWidget = self.objectReference:GetRefValue("magicAttackRateUWidget")
	self.magicDefendRateUWidget = self.objectReference:GetRefValue("magicDefendRateUWidget")
	self.quickRateUWidget = self.objectReference:GetRefValue("quickRateUWidget")
	self.defendRateUWidget = self.objectReference:GetRefValue("defendRateUWidget")
	self.attackRateUWidget = self.objectReference:GetRefValue("attackRateUWidget")
	self.rawImgPetRawImagePro = self.objectReference:GetRefValue("rawImgPetRawImagePro")
	self.imgPetUImage = self.objectReference:GetRefValue("imgPetUImage")
	self.featureTxtTitle = self.objectReference:GetRefValue("featureTxtTitle")
	self.featureListUList = self.objectReference:GetRefValue("featureListUList")
	self.skillTxtTitle = self.objectReference:GetRefValue("skillTxtTitle")
	self.listSkillUList = self.objectReference:GetRefValue("listSkillUList")
	self.skillUniqueUButton = self.objectReference:GetRefValue("skillUniqueUButton")
	self.uniqueSkillName = self.objectReference:GetRefValue("uniqueSkillName")
	self.uniqueIconSkillUImage = self.objectReference:GetRefValue("uniqueIconSkillUImage")
	self.skillExploreUButton = self.objectReference:GetRefValue("skillExploreUButton")
	self.iconExploreSkillUImage = self.objectReference:GetRefValue("iconExploreSkillUImage")
	self.iconExploreSkillName = self.objectReference:GetRefValue("iconExploreSkillName")
	self.txtTitle2UBaseText = self.objectReference:GetRefValue("txtTitle2UBaseText")
	self.actionTxtTitle = self.objectReference:GetRefValue("actionTxtTitle")
	self.listAbilityUList = self.objectReference:GetRefValue("listAbilityUList")
	self.listSpecificUList = self.objectReference:GetRefValue("listSpecificUList")
	self.btnPetManualDisplayUButton = self.objectReference:GetRefValue("btnPetManualDisplayUButton")
	self.btnPetManualUButton = self.objectReference:GetRefValue("btnPetManualUButton")
	self.line2UWidget = self.objectReference:GetRefValue("line2UWidget")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.petListUList = self.objectReference:GetRefValue("listUList")

	self:addListener()
end

local tabComs = {}

local function bindTipSelected(button)
	function button.luaTooltipPopup(tipButton, isOpen)
		tipButton.isSelected = isOpen
	end
end

function PetDetailTipComponent:getItemComs(btn)
	if tabComs[btn] == nil then
		local objectReference = btn.transform:GetComponent("ObjectReference")

		tabComs[btn] = {}
		tabComs[btn].itemObj = objectReference
		tabComs[btn].button = objectReference:GetRefValue("button")
		tabComs[btn].image = objectReference:GetRefValue("image")
		tabComs[btn].name = objectReference:GetRefValue("name")
	end

	return tabComs[btn]
end

function PetDetailTipComponent:addListener()
	function self.btnCloseUButton.luaClick()
		self.view.root:TryChangePage("Details", 0)
	end

	function self.listElementUList.luaRenderItem(button, index, data)
		button:TryChangePage("type", data.element)
	end

	function self.listRecommendUList.luaRenderItem(button, index, data)
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

	function self.featureListUList.luaRenderItem(button, index, data)
		bindTipSelected(button)

		local featureData = PetFeatureData[data.feature]

		if not featureData then
			return
		end

		local coms = self:getItemComs(button)

		ClientTextUtils.setText(coms.name, pg.getLocalizationText(featureData.name))

		coms.image.url = featureData.icon

		button:TryChangePage("IsRare", featureData.rare and 1 or 0)
		LuaUIUtils.setRenderFeatureToolTips(button, featureData)
	end

	function self.listSkillUList.luaRenderItem(button, index, data)
		bindTipSelected(button)

		local abParm = AbilityParamData[data.skill] or {}
		local coms = self:getItemComs(button)

		ClientTextUtils.setText(coms.name, pg.getLocalizationText(abParm.name))

		coms.image.url = LuaUIUtils.getSkillIcon(abParm.icon)

		local abilityId = AbilityUtils.getAbilityIdByParamId(data.templateBaseId, data.skill)
		local data1 = {
			abilityId = abilityId
		}

		table.merge(data1, abParm)
		LuaUIUtils.setRenderSKillTooTip(button, data1)
	end

	function self.listAbilityUList.luaRenderItem(button, _, data)
		bindTipSelected(button)

		local objectReference = button.transform:GetComponent("ObjectReference")
		local name = objectReference:GetRefValue("name")

		button:TryChangePage("Char", data.icon - 1)
		ClientTextUtils.setText(name, data.name)
		button:TryChangePage("Quality", data.level - 1)
		LuaUIUtils.setPetActionTip(button, data)
	end

	function self.listSpecificUList.luaRenderItem(button, _, data)
		local objectReference = button.transform:GetComponent("ObjectReference")
		local image = objectReference:GetRefValue("image")

		image.url = data.headRes
	end

	function self.btnPetManualUButton.luaClick()
		PetResearchUtils.openResearchDetail(templateId, UIConst.HANDBOOK_PAGE_IDX.SURVEY, {
			closeCb = function()
				if self.ctrl.uiScene then
					self.ctrl.uiScene:entActive(true)
				end

				self.view.root:TryChangePage("Details", 0)
				self.view.root:TryChangePage("Details", 1)
			end
		}, function()
			if self.ctrl.uiScene then
				self.ctrl.uiScene:entActive(false)
			end
		end)
	end

	bindTipSelected(self.skillUniqueUButton)
	bindTipSelected(self.skillExploreUButton)

	if IS_MOBILE then
		self.imgPetUImage:SetActive(true)
		LuaUIUtils.setUIViewVisible(self.rawImgPetRawImagePro, false)
	else
		self.imgPetUImage:SetActive(false)
		LuaUIUtils.setUIViewVisible(self.rawImgPetRawImagePro, true)
		self.ctrl.uiScene:setRawImageProRef(self.rawImgPetRawImagePro)
		self.ctrl:setPetRTInfo()
	end
end

function PetDetailTipComponent:onShow()
	self:setPetLeftInfo()
	self:setPetMiddleInfo()
	self:setPetRightInfo()
end

function PetDetailTipComponent:setPetLeftInfo()
	self:setPetInfo()
	self:setPartnerInfo()
	self:setAbilityInfo()
end

function PetDetailTipComponent:refreshResearchBtn()
	self.ctrl:startFrameTimer(function()
		if PetResearchUtils.isKnownAndCaught(templateId) then
			self.btnPetManualDisplayUButton:TryChangePage("button", 0)
		else
			if PetData[templateId].hideGotoManual and PetData[templateId].hideGotoManual == 1 then
				self.btnPetManualUButton:SetActive(false)
				self.btnPetManualDisplayUButton:SetActive(false)
			else
				self.btnPetManualUButton:SetActive(true)
				self.btnPetManualDisplayUButton:SetActive(true)
			end

			self.btnPetManualDisplayUButton:TryChangePage("button", 4)
		end
	end, 1)
end

function PetDetailTipComponent:setPetInfo()
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

	self.imgOrientationUImage.url = PetConfigData.petFunctionIcon[petType]

	local displayNumber, isCustomNumber = PetResearchUtils.getDisplayNumberByTemplateId(templateId)
	local numberPrefix = isCustomNumber and "" or "NO."

	ClientTextUtils.setText(self.txtNumUBaseText, numberPrefix .. displayNumber)

	local name = confResearchData.name or confBaseResearchData.name

	ClientTextUtils.setText(self.txtNameUBaseText, pg.getLocalizationText(name))
	ClientTextUtils.setText(self.txtDetailsUBaseText, pg.getLocalizationText(confResearchData.desc))

	local elementNames = confProtoData.elementType
	local elements = {}

	for _, elementName in ipairs(elementNames) do
		elements[#elements + 1] = {
			element = elementName
		}
	end

	self.listElementUList:SetList(elements)
end

function PetDetailTipComponent:setPartnerInfo()
	local confProtoData = PetProtoTypeData[templateId]
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

	self.listRecommendUList:SetList(partners)
end

function PetDetailTipComponent:setAbilityInfo()
	local pData = PetProtoTypeData[templateId]

	if pData == nil then
		return
	end

	ClientTextUtils.setText(self.hpNumberUBaseText, pData.species_hp_max_v)

	local rate = pData.species_hp_max_v / 100 > 1 and 1 or pData.species_hp_max_v / 100

	self.hpRateUWidget.transform.localScale = Vector3.New(rate, rate, rate)

	ClientTextUtils.setText(self.attackNumberUBaseText, pData.species_atk_v)

	rate = pData.species_atk_v / 100 > 1 and 1 or pData.species_atk_v / 100
	self.attackRateUWidget.transform.localScale = Vector3.New(rate, rate, rate)

	ClientTextUtils.setText(self.defendNumberUBaseText, pData.species_def_mag_v)

	rate = pData.species_def_v / 100 > 1 and 1 or pData.species_def_v / 100
	self.defendRateUWidget.transform.localScale = Vector3.New(rate, rate, rate)

	ClientTextUtils.setText(self.quickNumberUBaseText, pData.species_ep_regen_force_v)

	rate = pData.species_ep_regen_force_v / 100 > 1 and 1 or pData.species_ep_regen_force_v / 100
	self.quickRateUWidget.transform.localScale = Vector3.New(rate, rate, rate)

	ClientTextUtils.setText(self.magicDefendNumberUBaseText, pData.species_def_mag_v)

	rate = pData.species_def_mag_v / 100 > 1 and 1 or pData.species_def_mag_v / 100
	self.magicDefendRateUWidget.transform.localScale = Vector3.New(rate, rate, rate)

	ClientTextUtils.setText(self.magicAttackNumberUBaseText, pData.species_bp_atk_v)

	rate = pData.species_bp_atk_v / 100 > 1 and 1 or pData.species_bp_atk_v / 100
	self.magicAttackRateUWidget.transform.localScale = Vector3.New(rate, rate, rate)
end

function PetDetailTipComponent:setPetMiddleInfo()
	self:setPetImageInfo()
	self:setPetBodyInfo()
	self:setPetPhysiqueInfo()
end

function PetDetailTipComponent:setPetImageInfo()
	if IS_MOBILE then
		self.imgPetUImage:SetActive(true)
		LuaUIUtils.setUIViewVisible(self.rawImgPetRawImagePro, false)
	else
		self.imgPetUImage:SetActive(false)
		LuaUIUtils.setUIViewVisible(self.rawImgPetRawImagePro, true)
		self.ctrl.uiScene:setRawImageProRef(self.rawImgPetRawImagePro)
		self.ctrl:setPetRTInfo()
	end
end

function PetDetailTipComponent:setPetBodyInfo()
	return
end

function PetDetailTipComponent:setPetPhysiqueInfo()
	local confProtoData = PetProtoTypeData[templateId]

	if confProtoData == nil then
		return
	end

	local physiques = {}
	local baseFormPet = confProtoData.baseFormPet

	physiques[#physiques + 1] = {
		headRes = confProtoData.headRes
	}

	for id, proto in pairs(PetProtoTypeData) do
		if proto.baseFormPet == baseFormPet and id ~= templateId then
			physiques[#physiques + 1] = {
				headRes = confProtoData.headRes
			}
		end
	end

	self.listSpecificUList:SetActive(false)
	self.petListUList:SetActive(false)
end

function PetDetailTipComponent:setPetRightInfo()
	self:setCharacteristicsInfo()
	self:setSkillInfo()
	self:setActionsInfo()
	self:setExplorationInfo()
end

function PetDetailTipComponent:setCharacteristicsInfo()
	local data = PetProtoTypeData[templateId]

	if not data then
		return
	end

	local features = {}

	for _, feature in ipairs(data.feature) do
		features[#features + 1] = {
			feature = feature
		}
	end

	self.featureListUList:SetList(features)
end

function PetDetailTipComponent:setSkillInfo()
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

	self.listSkillUList:SetList(skills)

	local abParm = AbilityParamData[ultimateSkill]

	if abParm then
		ClientTextUtils.setText(self.uniqueSkillName, pg.getLocalizationText(abParm.name))

		self.uniqueIconSkillUImage.url = LuaUIUtils.getSkillIcon(abParm.icon)

		local abilityId = AbilityUtils.getAbilityIdByParamId(templateBaseId, ultimateSkill)
		local data1 = {
			abilityId = abilityId
		}

		table.merge(data1, abParm)
		LuaUIUtils.setRenderSKillTooTip(self.skillUniqueUButton, data1)
	end
end

function PetDetailTipComponent:setActionsInfo()
	local exploreAbilityList = PetData[templateId].exploreAbilityList

	if exploreAbilityList then
		self.line2UWidget:SetActive(self.showLine2)
		self.skillExploreUButton:SetActive(true)

		local explores = {}

		for _, id in ipairs(exploreAbilityList) do
			local item = {}
			local abilityParamData = pg.global.abilityMgr:getAbilityParamData(id)

			item.abilityId = id
			item.name = pg.getLocalizationText(abilityParamData.name)
			item.desc = pg.getLocalizationText(abilityParamData.desc)
			item.icon = abilityParamData.icon
			explores[#explores + 1] = item

			ClientTextUtils.setText(self.iconExploreSkillName, pg.getLocalizationText(item.name))

			self.iconExploreSkillUImage.url = LuaUIUtils.getSkillIcon(item.icon)
		end
	else
		self.line2UWidget:SetActive(false)
		self.skillExploreUButton:SetActive(false)
	end
end

function PetDetailTipComponent:setExplorationInfo()
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

	self.showLine2 = res and #res > 0

	self.listAbilityUList:SetList(res)
end

function PetDetailTipComponent:renderPetTip(button, key)
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
			LuaUIUtils.setElementButtonNew(button1, data1.element)
		end

		listTagUList:SetList(elementNames)
	end
end

function PetDetailTipComponent:onDestroy()
	for k in next, tabComs do
		tabComs[k] = nil
	end
end

return PetDetailTipComponent
