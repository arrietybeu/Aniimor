-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchDetailV2\\Component\\PetSkillComponent.lua

local PetProtoTypeData = require("Data.pet_prototype_data")
local PetSkillData = require("Data.pet_skill_data")
local PetData = require("Data.pet_data")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local PetAvatarData = require("Data.pet_avatar_data")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Const = require("Common.Const.Const")
local PetConfigData = require("Data.pet_config_data")
local logger = LoggerManager.getLogger("PetSkillComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetFeatureData = require("Data.pet_character_data")
local Utils = require("Common.Utils.Utils")
local AbilityParamData = require("Data.ability_param_data")
local AbilityConst = require("Common.Const.AbilityConst")
local Class = require("Core.Framework.Class")
local HotkeyConst = require("Const.HotkeyConst")
local UIComponent = require("Guis.Helper.UIComponent")
local PetSkillComponent = Class.LightClass("PetSkillComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")

function PetSkillComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.windowUComponent = self.objectReference:GetRefValue("windowUComponent")
	self.btnChoiceUButton = self.objectReference:GetRefValue("btnChoiceUButton")
	self.explorationListUList = self.objectReference:GetRefValue("explorationListUList")
	self.fixedList = self.objectReference:GetRefValue("fixedList")
	self.skillList = self.objectReference:GetRefValue("skillList")
	self.hpRate = self.objectReference:GetRefValue("hpRate")
	self.magicAttackRate = self.objectReference:GetRefValue("magicAttackRate")
	self.magicDefendRate = self.objectReference:GetRefValue("magicDefendRate")
	self.quickRate = self.objectReference:GetRefValue("quickRate")
	self.defendRate = self.objectReference:GetRefValue("defendRate")
	self.attackRate = self.objectReference:GetRefValue("attackRate")
	self.hpNumberUText = self.objectReference:GetRefValue("hpNumberUText")
	self.magicAttackNumber = self.objectReference:GetRefValue("magicAttackNumber")
	self.attackNumber = self.objectReference:GetRefValue("attackNumber")
	self.magicDefendNumber = self.objectReference:GetRefValue("magicDefendNumber")
	self.defendNumber = self.objectReference:GetRefValue("defendNumber")
	self.quickNumber = self.objectReference:GetRefValue("quickNumber")
	self.petNameText = self.objectReference:GetRefValue("petNameText")
	self.featureList = self.objectReference:GetRefValue("featureList")
	self.featureText = self.objectReference:GetRefValue("featureText")
	self.featureName = self.objectReference:GetRefValue("featureName")
	self.petName = self.objectReference:GetRefValue("petName")
	self.petDesc = self.objectReference:GetRefValue("petDesc")
	self.keyRTHotKeyContent = self.objectReference:GetRefValue("keyRTHotKeyContent")
	self.keyLTHotKeyContent = self.objectReference:GetRefValue("keyLTHotKeyContent")
	self.btnSpecialsUButton = self.objectReference:GetRefValue("btnSpecialsUButton")
	self.btnAttributesUButton = self.objectReference:GetRefValue("btnAttributesUButton")
	self.skillDescUText = self.objectReference:GetRefValue("skillDescUText")
	self.hpUBaseText = self.objectReference:GetRefValue("hpUBaseText")
	self.magicAttack = self.objectReference:GetRefValue("magicAttack")
	self.attack = self.objectReference:GetRefValue("attack")
	self.magicDefend = self.objectReference:GetRefValue("magicDefend")
	self.defend = self.objectReference:GetRefValue("defend")
	self.quick = self.objectReference:GetRefValue("quick")
	self.exploreLayoutBoxULayoutBox = self.objectReference:GetRefValue("exploreLayoutBoxULayoutBox")
	self.exploreSkillList = self.objectReference:GetRefValue("exploreSkillList")
end

function PetSkillComponent:initView()
	self.tabIdx = self.model.TAB_IDX.ABILITY
	self.ctrl.tabMap[self.tabIdx] = self
	self.allList = {
		self.featureList,
		self.fixedList,
		self.explorationListUList,
		self.skillList
	}

	function self.featureList.luaRenderItem(button, idx, data)
		self:setFeatureList(button, idx, data)
	end

	function self.featureList.luaClick(button, data)
		self:DeselectAll(self.featureList)
	end

	function self.skillList.luaRenderItem(button, idx, data)
		self:setSkillList(button, idx, data)
	end

	function self.skillList.luaClick()
		self:DeselectAll(self.skillList)
	end

	function self.explorationListUList.luaClick()
		self:DeselectAll(self.explorationListUList)
	end

	function self.fixedList.luaClick()
		self:DeselectAll(self.fixedList)
	end

	function self.explorationListUList.luaRenderItem(button, idx, data)
		self:setActionSkillList(button, idx, data)
	end

	function self.fixedList.luaRenderItem(button, idx, data)
		self:setFixedSkillList(button, idx, data)
	end

	function self.exploreSkillList.luaRenderItem(button, idx, data)
		self:setExploreSkillList(button, idx, data)
	end

	self.tabList = {
		self.btnSpecialsUButton,
		self.btnAttributesUButton
	}
	self.tabCurNavIndex = 1

	self.keyLTHotKeyContent:SetHotKeyPaths(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadLT)
	LuaUIUtils.bindHotKey(self.transform.gameObject, HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadLT, function()
		self.tabCurNavIndex = math.clamp(self.tabCurNavIndex - 1, 1, #self.tabList)

		self:selectTab()
	end)
	self.keyRTHotKeyContent:SetHotKeyPaths(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRT)
	LuaUIUtils.bindHotKey(self.transform.gameObject, HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRT, function()
		self.tabCurNavIndex = math.clamp(self.tabCurNavIndex + 1, 1, #self.tabList)

		self:selectTab()
	end)
	ClientTextUtils.setText(self.hpUBaseText, pg.getGameString("ATTRIBUTE_HP_SIMPLE"))
	ClientTextUtils.setText(self.magicAttack, pg.getGameString("ATTRIBUTE_NAT"))
	ClientTextUtils.setText(self.attack, pg.getGameString("ATTRIBUTE_ATTACK"))
	ClientTextUtils.setText(self.magicDefend, pg.getGameString("ATTRIBUTE_SP_DEFINE"))
	ClientTextUtils.setText(self.defend, pg.getGameString("ATTRIBUTE_DEFINE"))
	ClientTextUtils.setText(self.quick, pg.getGameString("ATTRIBUTE_RECOVER"))
	ClientTextUtils.setText(self.featureText, pg.getGameString("FEATURE_DESC"))
	ClientTextUtils.setText(self.skillDescUText, pg.getGameString("SKILL_DESC"))
end

function PetSkillComponent:selectTab()
	self.tabList[self.tabCurNavIndex]:CheckPressController()

	if self.tabList[self.tabCurNavIndex].luaClick then
		self.tabList[self.tabCurNavIndex].luaClick()
	end
end

function PetSkillComponent:setFeatureList(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local icon = objectReference:GetRefValue("iconFeatureUImage")

	icon.url = data.icon

	button:TryChangePage("IsRare", data.rare and 1 or 0)
	button:TryChangePage("Lock", 0)
	LuaUIUtils.setRenderFeatureToolTips(button, data)
end

function PetSkillComponent:setSkillList(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local icon = objectReference:GetRefValue("icon")
	local elementUButton = objectReference:GetRefValue("elementUButton")
	local formIconUWidget = objectReference:GetRefValue("formIconUWidget")
	local elementWidgetUWidget = objectReference:GetRefValue("elementWidgetUWidget")

	icon.url = data.icon

	if data.isRare then
		button:TryChangePage("IsRare", 1)
	else
		button:TryChangePage("IsRare", 0)
	end

	local formName

	if data.unlockPetFormName ~= nil then
		formIconUWidget:SetActive(true)

		formName = data.unlockPetFormName
	else
		formIconUWidget:SetActive(false)
	end

	if data.unLock then
		button:TryChangePage("states", 1)
		LuaUIUtils.setElementButtonNew(elementUButton, data.elementType)

		button.enabledTooltip = true
	elseif data.showContentLocked then
		button:TryChangePage("states", 2)
		button:TryChangePage("Property", 1)
		LuaUIUtils.setElementButtonNew(elementUButton, data.elementType)

		button.enabledTooltip = true
	else
		button:TryChangePage("states", 0)

		button.enabledTooltip = false
	end

	if formName then
		LuaUIUtils.setRenderSKillTooTip(button, data, pg.getFormatText(pg.getGameString("FORM_SKILL_TIPS"), formName))
	else
		LuaUIUtils.setRenderSKillTooTip(button, data)
	end

	local vx = button:Find("VfxWidget"):GetComponent("UParticle")

	LuaUIUtils.setUIViewVisible(vx, false)
end

function PetSkillComponent:setFixedSkillList(button, idx, data)
	local icon = button:Find("Icon"):GetComponent("UImage")
	local name = button:Find("Text"):GetComponent("UBaseText")

	icon.url = data.icon

	ClientTextUtils.setText(name, data.displayName)

	if data.rare then
		button:TryChangePage("IsRare", 1)
	else
		button:TryChangePage("IsRare", 0)
	end

	button:TryChangePage("Property", 1)
	button:TryChangePage("states", 1)

	local elementButton = button:Find("Property"):GetComponent("UButton")

	LuaUIUtils.setElementButtonNew(elementButton, data.elementType)
	LuaUIUtils.setRenderSKillTooTip(button, data)
end

function PetSkillComponent:setExploreSkillList(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local qualityIconUImage = objectReference:GetRefValue("qualityIconUImage")
	local textUBaseText = objectReference:GetRefValue("textUBaseText")
	local exploreSkillIconUImage = objectReference:GetRefValue("exploreSkillIconUImage")

	button:TryChangePage("ExploreSkill", 0)
	ClientTextUtils.setText(textUBaseText, data.name)

	exploreSkillIconUImage.url = data.icon

	LuaUIUtils.setRenderExploreToolTips(button, data)
end

function PetSkillComponent:setExploreSkill()
	local exploreAbilityList = PetData[self.templateId].exploreAbilityList

	if exploreAbilityList then
		self.exploreLayoutBoxULayoutBox:SetActive(true)

		local explores = {}

		for _, id in ipairs(exploreAbilityList) do
			local item = {}
			local abilityParamData = pg.global.abilityMgr:getAbilityParamData(id)

			item.abilityId = id
			item.name = pg.getLocalizationText(abilityParamData.name)
			item.desc = pg.getLocalizationText(abilityParamData.desc)
			item.icon = abilityParamData.icon
			explores[#explores + 1] = item
		end

		self.exploreSkillList:SetList(explores)
	else
		self.exploreLayoutBoxULayoutBox:SetActive(false)
	end
end

function PetSkillComponent:DeselectAll(filterList)
	for _, list in ipairs(self.allList) do
		if list ~= filterList then
			list:DeselectAll()
		end
	end
end

function PetSkillComponent:setActionSkillList(button, idx, data)
	button:TryChangePage("Quality", data.level - 1)

	local objectReference = button:GetComponent("ObjectReference")
	local qualityIconUImage = objectReference:GetRefValue("qualityIconUImage")
	local textUBaseText = objectReference:GetRefValue("textUBaseText")

	button:TryChangePage("ExploreSkill", 2)

	qualityIconUImage.url = data.icon

	ClientTextUtils.setText(textUBaseText, pg.getLocalizationText(data.name))
	LuaUIUtils.setRenderSKillTooTip(button, data, nil, nil, true)
end

function PetSkillComponent:onDestroy()
	UIComponent.onDestroy(self)
end

function PetSkillComponent:refreshPetAbility(baseInfo)
	self.templateId = baseInfo.templateId
	self.baseTemplateId = Utils.getBasePetPrototypeId(baseInfo.templateId)

	local handbookInfo = pg.me.petHandbookMap

	self.sumResearchPoint = 0
	self.unlockResearchPoint = 0

	local petHandbookInfo = handbookInfo[self.baseTemplateId]
	local featureData = self:getPetFeatureData()

	self.featureList:SetList(featureData)

	local exploreData = self:getCurExploreSkillData()

	if #exploreData > 0 then
		self.explorationListUList:SetList(exploreData)
		self.windowUComponent:TryChangePage("Exploration", 0)
	else
		self.windowUComponent:TryChangePage("Exploration", 1)
	end

	local fixedSkillData = self:getFixedSkillData()

	self.fixedList:SetList(fixedSkillData)

	local combatSkillData = self:getPetCombatSkills(petHandbookInfo)

	self.skillList:SetList(combatSkillData)
	self:setExploreSkill()
	self:setRaceData()
	ClientTextUtils.setText(self.petName, baseInfo.name)
	ClientTextUtils.setText(self.petDesc, baseInfo.desc)
end

function PetSkillComponent:getPetFeatureData()
	local ret = {}
	local featureConfig = PetProtoTypeData[self.templateId].feature or {}

	for _, featureId in pairs(featureConfig) do
		local featureInfo = PetFeatureData[featureId]

		if featureInfo then
			local item = {}
			local researchPoint = PetResearchUtils.getRewardResearchPoint(featureInfo.reward or 0)

			self.sumResearchPoint = self.sumResearchPoint + researchPoint
			item.icon = featureInfo.icon
			item.featureId = featureId
			item.name = featureInfo.name
			item.desc = featureInfo.desc
			item.rare = featureInfo.rare == 1
			ret[#ret + 1] = item
		end
	end

	return ret
end

function PetSkillComponent:onSelectThisPage(cb)
	self.ctrl:setPageTitle("TITLE_SKILL")

	local baseInfo = self.ctrl:getSelectedPetInfo()

	if baseInfo.templateId ~= self.templateId then
		self:refreshPetAbility(baseInfo)
	end

	self.ctrl.petScene:trySwitchView(self.tabIdx, cb)
	self:refreshPageResearchPoint()
	self.ctrl.petScene:playPetPageAction(self.model.curPetTemplateId, self.tabIdx)
end

function PetSkillComponent:onDeselectThisTab()
	return
end

function PetSkillComponent:refreshPageResearchPoint()
	self.ctrl:setPageResearchPoint(self.unlockResearchPoint, self.sumResearchPoint)
end

function PetSkillComponent:getCurExploreSkillData()
	local ret = {}
	local petData = PetProtoTypeData[self.templateId] or {}

	for id, name in pairs(AbilityConst.SPECIFIC_ABILITY_INDEX_2_NAME) do
		if petData[name] then
			local exploreId = id
			local level = petData[name]
			local exploreItem = self.ctrl:getPetExploreSkillData(exploreId, level)

			if exploreItem then
				exploreItem.maxLevel = AbilityConst.SPECIFIC_ABILITY_INDEX_MAX
				ret[#ret + 1] = exploreItem
			end
		end
	end

	return ret
end

function PetSkillComponent:getFixedSkillData()
	local ret = {}
	local skillInfos = PetSkillData[self.baseTemplateId] or {}

	for skillId, info in pairs(skillInfos) do
		if self:checkSkillCanShow(info.needPetFormsUnlock) then
			local abParm = AbilityParamData[skillId]
			local skillType = abParm.skillType

			if skillType == Const.SkillType.Normal then
				local item = self.ctrl:getSkillItemById(abParm)

				item.displayName = "ATK"
				item.isRare = info.rarity
				item.skillOrder = 1
				item.paramId = skillId
				ret[#ret + 1] = item
			elseif skillType == Const.SkillType.Ultimate then
				local item = self.ctrl:getSkillItemById(abParm)

				item.displayName = "ULT"
				item.isRare = info.rarity
				item.skillOrder = 2
				item.paramId = skillId
				ret[#ret + 1] = item
			end
		end
	end

	table.sort(ret, function(a, b)
		return a.skillOrder < b.skillOrder
	end)

	return ret
end

function PetSkillComponent:getPetCombatSkills(petHandbookInfo)
	local res = {}
	local tpId = self.baseTemplateId
	local abData = PetSkillData[tpId]

	if abData == nil then
		return res
	end

	for k, v in pairs(abData) do
		if self:checkSkillCanShow(v.needPetFormsUnlock) then
			local abParm = AbilityParamData[k] or {}
			local tp = abParm.skillType

			if not Utils.isEmptyTable(abParm) and tp and tp == Const.SkillType.Skill and v.showInManual then
				local item = self.ctrl:getSkillItemById(abParm, v.reward)

				item.isRare = v.rarity
				item.unLock = petHandbookInfo.battleResearch:isUnlock(k)
				item.abId = k

				local researchPoint = PetResearchUtils.getRewardResearchPoint(v.reward or 0)

				self.sumResearchPoint = self.sumResearchPoint + researchPoint

				if item.unLock then
					self.unlockResearchPoint = self.unlockResearchPoint + researchPoint
				end

				if not item.unLock then
					item.unlockExDesc = string.format("<color=#ffe451>%s</color>", pg.getLocalizationText(v.unlockRequirement) or "")
				end

				item.researchPoint = researchPoint
				item.unlockPetFormName = self:getPetFormName(v.needPetFormsUnlock)
				item.showContentLocked = v.showContentLocked == 1

				local researchInfo = petHandbookInfo.battleResearch:getInfo(k)

				item.isNew = researchInfo and researchInfo.isNew
				item.skillOrder = v.skillOrder
				item.paramId = k
				res[#res + 1] = item
			end
		end
	end

	table.sort(res, function(a, b)
		return a.skillOrder < b.skillOrder
	end)

	return res
end

function PetSkillComponent:checkSkillCanShow(needPetFormsUnlock)
	if self.model.showTab == PetResearchUtils.PET_SHOW_TAB.SPECIES then
		return true
	end

	return not needPetFormsUnlock or table.contains(needPetFormsUnlock, self.templateId)
end

function PetSkillComponent:getPetFormName(unlockPetData)
	if unlockPetData == nil then
		return
	end

	local count = #unlockPetData

	if count == 1 then
		if PetAvatarData[unlockPetData[1]] then
			return LuaUIUtils.getPetFormNameByPrototypeId(unlockPetData[1])
		else
			return
		end
	end

	local ret = {}
	local map = {}

	for _, id in ipairs(unlockPetData) do
		if PetAvatarData[id] then
			local formName = LuaUIUtils.getPetFormNameByPrototypeId(id)

			if not map[formName] then
				map[formName] = true
				ret[#ret + 1] = formName
			end
		end
	end

	if #ret == 0 then
		return
	end

	return table.concat(ret, ",")
end

function PetSkillComponent:getAbilityResearchPoint()
	return {
		self.unlockResearchPoint,
		self.sumResearchPoint
	}
end

function PetSkillComponent:playAbilityNewLockVx(abilityId)
	local btns = self.skillList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		local btn = btns[i]
		local data = self.skillList:GetData(btn)

		if data and data.abId == abilityId then
			local vx = btn:Find("VfxWidget"):GetComponent("UParticle")

			LuaUIUtils.setUIViewVisible(vx, false)
			self:startTimer(function()
				LuaUIUtils.setUIViewVisible(vx, true)
			end, 1)
		end
	end
end

function PetSkillComponent:setRaceData()
	local res = {}
	local tpId = self.templateId
	local pData = PetProtoTypeData[tpId]

	if pData == nil then
		return res
	end

	local maxValue = PetConfigData.petSpeciesMax

	ClientTextUtils.setText(self.hpNumberUText, pData.species_hp_max_v)

	local rate = pData.species_hp_max_v / maxValue

	self.hpRate.transform.localScale = Vector3.New(rate, rate, rate)

	ClientTextUtils.setText(self.magicAttackNumber, pData.species_bp_atk_v)

	rate = pData.species_bp_atk_v / maxValue
	self.magicAttackRate.transform.localScale = Vector3.New(rate, rate, rate)

	ClientTextUtils.setText(self.magicDefendNumber, pData.species_def_mag_v)

	rate = pData.species_def_mag_v / maxValue
	self.magicDefendRate.transform.localScale = Vector3.New(rate, rate, rate)

	ClientTextUtils.setText(self.defendNumber, pData.species_def_v)

	rate = pData.species_def_v / maxValue
	self.defendRate.transform.localScale = Vector3.New(rate, rate, rate)

	ClientTextUtils.setText(self.attackNumber, pData.species_atk_v)

	rate = pData.species_atk_v / maxValue
	self.attackRate.transform.localScale = Vector3.New(rate, rate, rate)

	ClientTextUtils.setText(self.quickNumber, pData.species_ep_regen_force_v)

	rate = pData.species_ep_regen_force_v / maxValue
	self.quickRate.transform.localScale = Vector3.New(rate, rate, rate)
end

return PetSkillComponent
