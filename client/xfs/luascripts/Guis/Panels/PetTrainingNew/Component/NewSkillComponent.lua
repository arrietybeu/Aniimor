-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTrainingNew\\Component\\NewSkillComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("NewSkillComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local NewSkillComponent = Class.LightClass("NewSkillComponent", UIComponent)
local AbilityConst = require("Common.Const.AbilityConst")
local TimerManager = require("Core.Timer.TimerManager")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local Lume = require("Core.Common.lume")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local ElementPropData = require("Data.element_prop_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetData = require("Data.pet_data")
local Utils = require("Common.Utils.Utils")
local PetSkData = require("Data.pet_skill_data")
local CallbackHandler = require("Core.Common.CallbackHandler")
local NoticeDef = require("Common.NoticeDef")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local GuidenceSubItemData = require("Data.guidence_sub_item_data")
local GlazeType = {
	Upgrade = 1,
	None = 0,
	Upgraded = 2
}
local CORE_CARRY_CERT_SKILL_TIP = "CARRY_CERT_SKILL_TIP"

function NewSkillComponent:ctor(ctrl, ucontent, extraInfo)
	self.newSkillUContent = ucontent
	self.imgPetUImage = extraInfo.imgPetUImage

	NewSkillComponent.super.ctor(self, ctrl, ucontent)
end

function NewSkillComponent:findObjects()
	self.objectReference = self.newSkillUContent.transform:GetComponent("ObjectReference")
	self.petName = self.objectReference:GetRefValue("petName")
	self.imgPet1UImage = self.objectReference:GetRefValue("imgPet1UImage")
	self.btnSkillPresetsUButton = self.objectReference:GetRefValue("btnSkillPresetsUButton")
	self.skillPresetName = self.objectReference:GetRefValue("skillPresetName")
	self.btnUniqueSkillUButton = self.objectReference:GetRefValue("btnUniqueSkillUButton")
	self.uniqueUWidget = self.objectReference:GetRefValue("uniqueUWidget")
	self.txtUniqueUSDFText = self.objectReference:GetRefValue("txtUniqueUSDFText")
	self.btnNormalSkill1UButton = self.objectReference:GetRefValue("btnNormalSkill1UButton")
	self.btnNormalSkill2UButton = self.objectReference:GetRefValue("btnNormalSkill2UButton")
	self.btnExploreSkillUButton = self.objectReference:GetRefValue("btnExploreSkillUButton")
	self.btnFeaturesUButton = self.objectReference:GetRefValue("btnFeaturesUButton")
	self.btnSwapUButton = self.objectReference:GetRefValue("btnSwapUButton")
	self.allSkillsList = self.objectReference:GetRefValue("allSkillsList")
	self.skillInfoUComponent = self.objectReference:GetRefValue("skillInfoUComponent")
	self.skillInfoTxtDetailsUSDFText = self.objectReference:GetRefValue("skillInfoTxtDetailsUSDFText")
	self.txtName = self.objectReference:GetRefValue("txtName")
	self.iconSkillUImage = self.objectReference:GetRefValue("iconSkillUImage")
	self.infoSkillElementUButton = self.objectReference:GetRefValue("infoSkillElementUButton")
	self.infoSkillClickButtonUButton = self.objectReference:GetRefValue("infoSkillClickButtonUButton")
	self.txtShortDetailsUSDFText = self.objectReference:GetRefValue("txtShortDetailsUSDFText")
	self.txtLongDetailsUSDFText = self.objectReference:GetRefValue("txtLongDetailsUSDFText")
	self.listTagUList = self.objectReference:GetRefValue("listTagUList")
	self.descUSDFText = self.objectReference:GetRefValue("descUSDFText")
	self.btnStudyUButton = self.objectReference:GetRefValue("btnStudyUButton")
	self.dropHotKeyContent = self.objectReference:GetRefValue("dropHotKeyContent")
	self.changeLHotKeyContent = self.objectReference:GetRefValue("changeLHotKeyContent")
	self.changeRHotKeyContent = self.objectReference:GetRefValue("changeRHotKeyContent")
	self.swapHotKeyContent = self.objectReference:GetRefValue("swapHotKeyContent")
	self.btnSwitchMaxUButton = self.objectReference:GetRefValue("btnSwitchMaxUButton")
	self.switchTxtNameUSDFText = self.objectReference:GetRefValue("switchTxtNameUSDFText")
	self.upLvTxtNameUSDFText = self.objectReference:GetRefValue("upLvTxtNameUSDFText")
	self.upedLvTxtNameUSDFText = self.objectReference:GetRefValue("upedLvTxtNameUSDFText")
	self.btnSwitchUButton = self.objectReference:GetRefValue("btnSwitchUButton")
	self.skillUniqRayBoxUWidget = self.objectReference:GetRefValue("skillUniqRayBoxUWidget")
	self.featureRayBoxUWidget = self.objectReference:GetRefValue("featureRayBoxUWidget")
	self.exploreRayBoxUWidget = self.objectReference:GetRefValue("exploreRayBoxUWidget")

	ClientTextUtils.setText(self.switchTxtNameUSDFText, pg.getGameString("PETSKILL_UPLV_SWITCH_TITLE"))
	ClientTextUtils.setText(self.upLvTxtNameUSDFText, pg.getGameString("PETSKILL_BTN_UPLV"))
	ClientTextUtils.setText(self.upedLvTxtNameUSDFText, pg.getGameString("PETSKILL_UPLV_UPGRADE_TITLE"))

	self.tagTypeUWidget = self.objectReference:GetRefValue("tagTypeUWidget")
	self.txtTypeUSDFText = self.objectReference:GetRefValue("txtTypeUSDFText")
	self.listAttributeUList = self.objectReference:GetRefValue("listAttributeUList")
	self.strengthenUWidget = self.objectReference:GetRefValue("strengthenUWidget")

	function self.btnSwitchUButton.luaClick()
		self:onClickSwitchSkillDesc()
	end

	LuaUIUtils.setUIViewVisible(self.btnSwitchMaxUButton, false)

	self.contactTipsUWidget = self.objectReference:GetRefValue("contactTipsUWidget")
	self.btnInfoUButton = self.objectReference:GetRefValue("btnInfoUButton")
	self.txtTipsUSDFText = self.objectReference:GetRefValue("txtTipsUSDFText")

	self.strengthenUWidget:SetActive(false)
	ClientTextUtils.setText(self.txtTipsUSDFText, pg.getGameString(CORE_CARRY_CERT_SKILL_TIP))

	local cfgHelpId = PetManagementDataHelper.PetCoreCarryContactHelpId
	local isConfigHelp = cfgHelpId and GuidenceSubItemData[cfgHelpId]

	self.btnInfoUButton:SetActive(isConfigHelp)

	if isConfigHelp then
		self.btnInfoUButton.enabledTooltip = false

		function self.btnInfoUButton.luaClick()
			pg.global.ui:open(UIConst.UI_ID_HELP, {
				helpId = cfgHelpId
			})
		end
	end
end

function NewSkillComponent:initView()
	function self.btnSkillPresetsUButton.luaClick()
		self:onClickSkillPresetsButton()
	end

	function self.btnSwapUButton.luaClick()
		self:modifySkill(self.curSelectedBtn.name, self.curSelectedSkillBtn.name)
	end

	function self.btnStudyUButton.luaClick()
		self:onStudyBtnClick()
	end
end

function NewSkillComponent:init(info)
	self.firstInForCurSelectedBtn = true
	self.firstInForCurSelectedSkillBtn = true
	self.curSelectedBtn = nil
	self.curSelectedSkillBtn = nil
	self.selectSkillData = nil
	self.petName.text, self.petInfo = self.model:getPetNameAndInfo(self.ctrl.petId)

	local icon = LuaUIUtils.getPetIcon(PetData[self.petInfo.templateId].iconName, LuaUIUtils.PET_ICON, self.petInfo.label, self.petInfo.gender)

	self.imgPetUImage:SetUrlWithCallback(icon, function()
		return
	end)
	self.imgPet1UImage:SetUrlWithCallback(icon, function()
		return
	end)
	self:setFeature(self.ctrl.petId)
	self:refreshSkillList(self.ctrl.petId)
	self:refreshAllSkills(self.ctrl.petId)

	if self.delayAutoSelectTimer then
		TimerManager.removeTimer(self.delayAutoSelectTimer)

		self.delayAutoSelectTimer = nil
	end

	self.delayAutoSelectTimer = TimerManager.addTimer(0.1, function()
		self.delayAutoSelectTimer = nil

		if self.curSelectedSkillBtn then
			return
		end

		local btns = self.allSkillsList:GetAllButtons()
		local data = self.model:getPetAllUnlockedSkill(self.ctrl.petId)

		for i = 0, btns.Length - 1 do
			local curBtnData = data[i + 1]

			if curBtnData and self.skillInfoData and curBtnData.paramId == self.skillInfoData.paramId then
				btns[i]:TryChangePage("Selected", 1)
			else
				btns[i]:TryChangePage("Selected", 0)
			end
		end
	end)
end

function NewSkillComponent:setFeature(petId)
	self.btnFeaturesUButton:TryChangePage("mute", 1)
	TimerManager.addTimer(0.1, function()
		self.featureRayBoxUWidget:SetActive(true)
	end)

	local featureInfo = self.model:getCurCharacter(petId)

	if featureInfo then
		local petInfo = pg.me:getPetInfo(petId)

		self.btnFeaturesUButton.enabledTooltip = true

		LuaUIUtils.setRenderFeatureToolTips(self.btnFeaturesUButton, featureInfo, petInfo)

		local objectReference = self.btnFeaturesUButton:GetComponent("ObjectReference")
		local iconFeatureUImage = objectReference:GetRefValue("iconFeatureUImage")

		self.btnFeaturesUButton:TryChangePage("IsRare", featureInfo.rare or 0)
		self.btnFeaturesUButton:TryChangePage("State", 1)

		iconFeatureUImage.url = featureInfo.icon
	else
		self.btnFeaturesUButton.enabledTooltip = false

		self.btnFeaturesUButton:TryChangePage("IsRare", 0)
		self.btnFeaturesUButton:TryChangePage("State", 0)
	end
end

function NewSkillComponent:refreshSkillList(petId)
	local ultSkillInfo = self.model:getPetSkillInfos(petId, AbilityConst.ULTIMATE_ABILITY)

	self.qSkillInfo = self.model:getPetSkillInfos(petId, AbilityConst.WEAPON_SKILL_ABILITY)
	self.eSkillInfo = self.model:getPetSkillInfos(petId, AbilityConst.WEAPON_SKILL_ABILITY2)

	local exploreSkillInfo = self.model:getPetSkillInfos(petId, AbilityConst.EXPLORE_ABILITY)

	self:renderSkillCmp(self.btnUniqueSkillUButton, ultSkillInfo, true)
	self.btnUniqueSkillUButton:TryChangePage("mute", 1)

	if self.delayTimer then
		TimerManager.removeTimer(self.delayTimer)

		self.delayTimer = nil
	end

	self.skillUniqRayBoxUWidget:SetActive(false)

	if ultSkillInfo then
		self.delayTimer = TimerManager.addTimer(0.1, function()
			self.delayTimer = nil

			self.skillUniqRayBoxUWidget:SetActive(true)
		end)
	end

	self:renderSkillCmp(self.btnNormalSkill1UButton, self.qSkillInfo)
	self:renderSkillCmp(self.btnNormalSkill2UButton, self.eSkillInfo)

	self.btnNormalSkill1UButton.name = "1"
	self.btnNormalSkill1UButton.draggable = self.qSkillInfo ~= nil
	self.btnNormalSkill2UButton.name = "2"
	self.btnNormalSkill2UButton.draggable = self.eSkillInfo ~= nil

	self:renderExploreSkillCmp(self.btnExploreSkillUButton, exploreSkillInfo)
	self.btnExploreSkillUButton:TryChangePage("mute", 1)

	if self.exploreRayBoxDelayTimer then
		TimerManager.removeTimer(self.exploreRayBoxDelayTimer)

		self.exploreRayBoxDelayTimer = nil
	end

	self.exploreRayBoxUWidget:SetActive(false)

	if exploreSkillInfo then
		self.exploreRayBoxDelayTimer = TimerManager.addTimer(0.1, function()
			self.exploreRayBoxDelayTimer = nil

			self.exploreRayBoxUWidget:SetActive(true)
		end)
	end

	if self.firstInForCurSelectedBtn then
		if self.btnNormalSkill1UButton.luaPress then
			self.btnNormalSkill1UButton.luaPress()
		end

		self.firstInForCurSelectedBtn = nil
	end

	TimerManager.addNextFrameCb(function()
		if not self.model then
			return
		end

		if self.model.IS_PVP_FAIL_MODE then
			local pvpPetSet = pg.global.ui.pvpPetSet
			local serverData = pvpPetSet.model.petsMap[petId].serverData

			ClientTextUtils.setText(self.skillPresetName, ClientTextUtils.concatByLanguage(pg.getGameString("ABILITY_PLAN"), serverData.curAbilityPreset))
		else
			local petInfo = pg.me:getPetInfo(petId)

			if not petInfo or not petInfo.abilityPresetMap then
				return
			end

			local presetName = petInfo.abilityPresetMap[petInfo.curAbilityPreset].name

			if presetName and presetName ~= "" then
				ClientTextUtils.setText(self.skillPresetName, presetName)
			else
				ClientTextUtils.setText(self.skillPresetName, ClientTextUtils.concatByLanguage(pg.getGameString("ABILITY_PLAN"), petInfo.curAbilityPreset))
			end
		end
	end)
end

function NewSkillComponent:renderSkillCmp(button, data, isUnique)
	if not data then
		LuaUIUtils.renderSkillHeadComp(button, nil, self.petInfo, true)

		button.luaTooltipPopup = nil

		if isUnique then
			self.uniqueUWidget:SetActive(false)
		end

		button:SetActive(not isUnique)

		return
	end

	button:SetActive(true)

	if isUnique then
		self.uniqueUWidget:SetActive(true)
		ClientTextUtils.setText(self.txtUniqueUSDFText, pg.getGameString("PETSKILL_ULTIMATE"))
	end

	local function onPress(pButton, pData)
		self.curSelectedBtn = pButton

		self:onSelectedBtnChanged(pData)
		self:refreshSkillInfo(pData)
	end

	local function onEndDrag(dropTarget)
		self.tipInfo = nil

		if not dropTarget or dropTarget.name ~= tostring(AbilityConst.WEAPON_SKILL_ABILITY) and dropTarget.name ~= tostring(AbilityConst.WEAPON_SKILL_ABILITY2) then
			self:modifySkill(tostring(data.abilityType), tostring(self.model.EMPTY_ABILITY_ID))

			return
		end

		self:modifySkill(dropTarget.name, tostring(data.abilityId))
	end

	LuaUIUtils.renderSkillHeadComp(button, data, self.petInfo, true, onPress, onEndDrag)
end

function NewSkillComponent:onSelectedBtnChanged(data)
	self.btnNormalSkill1UButton:TryChangePage("Selected", self.curSelectedBtn == self.btnNormalSkill1UButton and 1 or 0)
	self.btnNormalSkill2UButton:TryChangePage("Selected", self.curSelectedBtn == self.btnNormalSkill2UButton and 1 or 0)
	self:refreshReplaceBtnState(data)
end

function NewSkillComponent:onSelectedSkillBtnChanged(data)
	local btns = self.allSkillsList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		btns[i]:TryChangePage("Selected", 0)

		if self.curSelectedSkillBtn == btns[i] then
			self.curSelectedSkillBtn:TryChangePage("Selected", 1)
		end
	end

	self:refreshReplaceBtnState(data)
	self:refreshSkillInfo(data)
end

function NewSkillComponent:refreshReplaceBtnState(data)
	if not data then
		self.newSkillUContent:TryChangePage("BtnState", 3)

		return
	end

	if data.alreadyLearnt == nil and data.unLock == nil then
		self.newSkillUContent:TryChangePage("BtnState", self.curSelectedSkillBtn and self.curSelectedBtn and 2 or 3)

		return
	end

	if data.alreadyLearnt then
		self.newSkillUContent:TryChangePage("BtnState", self.curSelectedSkillBtn and self.curSelectedBtn and 2 or 3)
	elseif data.unLock then
		self.newSkillUContent:TryChangePage("BtnState", 1)
	else
		self.newSkillUContent:TryChangePage("BtnState", 0)
		ClientTextUtils.setText(self.descUSDFText, data.unlockRequirement and pg.getLocalizationText(data.unlockRequirement) or "")
	end
end

function NewSkillComponent:renderExploreSkillCmp(button, data)
	if not data then
		button.enabledTooltip = false

		button:SetActive(false)

		return
	end

	button:SetActive(true)
	button:TryChangePage("State", 0)
	button:TryChangePage("Element", 0)

	button.enabledTooltip = false

	local objectReference = button:GetComponent("ObjectReference")
	local iconNormalUImage = objectReference:GetRefValue("iconNormalUImage")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

	button:TryChangePage("State", 1)

	iconNormalUImage.url = LuaUIUtils.getSkillIcon(data.icon)

	ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.name))
end

function NewSkillComponent:refreshAllSkillsBtnState()
	local btns = self.allSkillsList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		self:refreshEquipmentStatus(btns[i], tonumber(btns[i].name))
	end
end

function NewSkillComponent:refreshEquipmentStatus(b, abilityId)
	local objectReference = b:GetComponent("ObjectReference")

	b:TryChangePage("Equipment", 0)

	if self.qSkillInfo and self.qSkillInfo.abilityId == abilityId then
		b:TryChangePage("Equipment", 1)
	elseif self.eSkillInfo and self.eSkillInfo.abilityId == abilityId then
		b:TryChangePage("Equipment", 1)
	end
end

function NewSkillComponent:refreshAllSkills(id)
	local data = self.model:getPetAllUnlockedSkill(id)
	local qSkillInfo = self.model:getPetSkillInfos(id, AbilityConst.WEAPON_SKILL_ABILITY)

	function self.allSkillsList.luaRenderItem(button, index, data1)
		button.enabledTooltip = false
		button.draggable = true

		self:renderSkillBtn(button, data1)

		if self.firstInForCurSelectedSkillBtn and not qSkillInfo and index == 0 then
			if button.luaPress then
				button.luaPress()
			end

			self.firstInForCurSelectedSkillBtn = nil
		end
	end

	self.allSkillsList:SetList(data)
end

function NewSkillComponent:onSkillBtnClick(btn, data)
	self.curSelectedSkillBtn = btn

	self.allSkillsList:SetNavGroupDefaultItem(btn)
	self:onSelectedSkillBtnChanged(data)

	if data.alreadyLearnt then
		self.btnSwapUButton:TryChangePage("enable", 1)

		self.tipInfo = nil
	else
		self.btnSwapUButton:TryChangePage("enable", 0)

		self.tipInfo = pg.getGameString("SKILL_NOT_LEARNED_CAN_NOT_EQUIP")
	end
end

function NewSkillComponent:dragStateChanged()
	if self.ctrl and self.ctrl.onSkillCompDragStateChanged then
		self.ctrl:onSkillCompDragStateChanged()
	end
end

function NewSkillComponent:renderSkillBtn(b, d)
	local objectReference1 = b:GetComponent("ObjectReference")
	local iconSkillUImage = objectReference1:GetRefValue("iconSkillUImage")
	local txtNameUSDFText1 = objectReference1:GetRefValue("txtNameUSDFText")
	local listTagUList = objectReference1:GetRefValue("listTagUList")
	local elementUButton = objectReference1:GetRefValue("elementUButton")
	local coreUWidget = objectReference1:GetRefValue("coreUWidget")

	self:refreshEquipmentStatus(b, d.abilityId)

	local state = 0

	if d.abilityId == self.model.EMPTY_ABILITY_ID then
		b:TryChangePage("empty", 1)
		b:TryChangePage("Element", 0)
		b:TryChangePage("IsRare", 0)
		b:TryChangePage("Type", 0)

		b.draggable = false

		self:dragStateChanged()

		if coreUWidget then
			coreUWidget:SetActive(false)
		end
	else
		b:TryChangePage("empty", 0)

		local glazeType = LuaUIUtils.getSkillGlazeType(d)

		b:TryChangePage("IsRare", glazeType)
		b:TryChangePage("Type", self:getSkillGlazeType(d))

		if coreUWidget then
			coreUWidget:SetActive(d.rare == 1)
		end

		iconSkillUImage.url = LuaUIUtils.getSkillIcon(d.icon)

		ClientTextUtils.setText(txtNameUSDFText1, pg.getLocalizationText(d.name))

		function listTagUList.luaRenderItem(b1, _, d1)
			local objectReference2 = b1:GetComponent("ObjectReference")
			local txtNameUText = objectReference2:GetRefValue("txtNameUText")

			ClientTextUtils.setText(txtNameUText, pg.getLocalizationText(d1.tagName))
		end

		if d.tagShowList then
			listTagUList:SetList(d.tagShowList)
		else
			listTagUList:SetList(d.tagList)
		end

		if d.elementType then
			b:TryChangePage("Element", 1)
			LuaUIUtils.setElementButtonNew(elementUButton, d.elementType)
		end

		state = d.alreadyLearnt and 0 or d.unLock and 2 or 1
		b.draggable = true

		b:TryChangePage("SkillState", state)

		if state ~= 0 then
			b.draggable = false
		end

		self:dragStateChanged()
	end

	function b.luaPress()
		self:onSkillBtnClick(b, d)

		self.selectSkillData = d
	end

	b.name = d.abilityId

	function b.luaBeginDrag()
		b.replicaWidget.transform.localScale = Vector3(1.5, 1.5, 1.5)

		local objectReference = b.replicaWidget:GetComponent("ObjectReference")
		local iconSkillUImage1 = objectReference:GetRefValue("iconSkillUImage")
		local elementUButton1 = objectReference:GetRefValue("elementUButton")

		iconSkillUImage1.url = LuaUIUtils.getSkillIcon(d.icon)

		if d.elementType then
			b.replicaWidget:TryChangePage("Element", 1)
			LuaUIUtils.setElementButtonNew(elementUButton1, d.elementType)
		end

		b:TryChangePage("DragState", 2)
		b.replicaWidget:TryChangePage("DragState", 1)
	end

	function b.luaEndDrag(dropTarget)
		b:TryChangePage("DragState", 0)

		if not dropTarget or dropTarget.name ~= tostring(AbilityConst.WEAPON_SKILL_ABILITY) and dropTarget.name ~= tostring(AbilityConst.WEAPON_SKILL_ABILITY2) then
			return
		end

		if self.model:isAbilityIdLearnt(self.ctrl.petId, d.abilityId) then
			self.tipInfo = nil
		else
			self.tipInfo = pg.getGameString("SKILL_NOT_LEARNED_CAN_NOT_EQUIP")
		end

		self:modifySkill(dropTarget.name, tostring(d.abilityId))
	end

	local clickButtonUButton = objectReference1:GetRefValue("clickButtonUButton")

	function clickButtonUButton.luaClick()
		return
	end

	LuaUIUtils.setRenderSKillTooTip(clickButtonUButton, d, nil, self.petInfo)
end

function NewSkillComponent:onClickSkillPresetsButton()
	pg.global.ui:open(UIConst.UI_ID_PET_SKILL_REPLACE_QUICK, {
		curPetId = self.ctrl.petId,
		pvpFailMode = self.model.IS_PVP_FAIL_MODE,
		templateId = self.petInfo.templateId,
		notPetManagement = self.ctrl.notPetManagement
	})
end

function NewSkillComponent:modifySkill(curSelectedBtnName, curSelectedSkillBtnName)
	if self.model.IS_PVP_FAIL_MODE then
		local pvpPetSet = pg.global.ui.pvpPetSet
		local serverData = pvpPetSet.model.petsMap[self.ctrl.petId].serverData
		local presetInfo = serverData.abilityPresetMap[serverData.curAbilityPreset]
		local abilityType = tonumber(curSelectedBtnName)
		local curAbilityId = presetInfo[abilityType]
		local newAbilityId = tonumber(curSelectedSkillBtnName)

		if curAbilityId ~= 0 and newAbilityId ~= 0 then
			presetInfo[abilityType] = 0
		end

		local curAbilityType = presetInfo and newAbilityId ~= 0 and Lume.find(presetInfo, newAbilityId) or nil

		if curAbilityType ~= nil and curAbilityType ~= abilityType then
			presetInfo[curAbilityType] = curAbilityId
		end

		presetInfo[abilityType] = newAbilityId

		pvpPetSet:sendSavePetInfoMsg(self.ctrl.petId, 2)
	else
		if self.tipInfo then
			pg.global.showBubbleMessageRaw(self.tipInfo)

			return
		end

		local petInfo = pg.me:getPetInfo(self.ctrl.petId)

		pg.me:serverMsg("RPC_CS_PetModifyAbilityPreset", self.ctrl.petId, petInfo.curAbilityPreset, tonumber(curSelectedBtnName), tonumber(curSelectedSkillBtnName))
	end
end

function NewSkillComponent:refreshSkillInfoByAbilityId(petId, abilityId)
	if not petId or not abilityId then
		return
	end

	local qSkillInfo = self.model:getPetSkillInfos(petId, AbilityConst.WEAPON_SKILL_ABILITY)

	if qSkillInfo and qSkillInfo.paramId == abilityId then
		self.btnNormalSkill1UButton:luaPress()

		return
	end

	local eSkillInfo = self.model:getPetSkillInfos(petId, AbilityConst.WEAPON_SKILL_ABILITY2)

	if eSkillInfo and eSkillInfo.paramId == abilityId then
		self.btnNormalSkill2UButton:luaPress()
	end
end

function NewSkillComponent:refreshSkillInfo(data)
	self.skillInfoData = data or self.skillInfoData

	if not self.skillInfoData then
		self.skillInfoUComponent.gameObject:SetActiveEx(false)
		self.btnSwitchUButton:SetActive(false)
		self.contactTipsUWidget:SetActive(false)

		return
	end

	self.skillInfoUComponent.gameObject:SetActiveEx(true)
	self.skillInfoUComponent:TryChangePage("IsRare", ToInt(AbilityUtils.isRareAbilityId(self.skillInfoData.abilityId, self.petInfo.templateId)))
	ClientTextUtils.setText(self.txtName, pg.getLocalizationText(self.skillInfoData.name))

	if pg.game.setting:getShowDebugId() then
		ClientTextUtils.setText(self.txtName, self.txtName.text, string.format("%s_%s", self.skillInfoData.abilityId, AbilityUtils.getAbilityParamId(self.skillInfoData.abilityId)))
	end

	self.iconSkillUImage.url = LuaUIUtils.getSkillIcon(self.skillInfoData.icon)

	function self.infoSkillClickButtonUButton.luaClick()
		return
	end

	LuaUIUtils.setRenderSKillTooTip(self.infoSkillClickButtonUButton, self.skillInfoData, nil, self.petInfo)
	LuaUIUtils.setElementButtonNew(self.infoSkillElementUButton, self.skillInfoData.elementType)
	ClientTextUtils.setText(self.skillInfoTxtDetailsUSDFText, pg.getGameString("PETSKILL_DETAIL_TITLE"))
	self:refreshAttributeList(self.skillInfoData)
	self.skillInfoUComponent:TryChangePage("Details", 1)

	local txtLongDetailsUBaseText = self.txtLongDetailsUSDFText.content:GetComponent("UBaseText")
	local skillDesc = LuaUIUtils.getSkillDesc(self.skillInfoData, self.petInfo)

	LuaUIUtils.customSetText(txtLongDetailsUBaseText, skillDesc, true, nil)
	LuaUIUtils.generalRefreshSkillTags(self.tagTypeUWidget, self.listTagUList, self.skillInfoData, self.skillInfoData.tagList)

	local glazeType = self:getSkillGlazeType(self.skillInfoData)

	self.skillInfoUComponent:TryChangePage("Type", glazeType)
	self.strengthenUWidget:SetActive(false)
	self.contactTipsUWidget:SetActive(glazeType > GlazeType.None and not self.skillInfoData.alreadyGlazed)

	self.recordDescType = GlazeType.None
	self.pairedSkillInfoCache = nil

	self:refreshSwitchSkillDescButtonState()
end

function NewSkillComponent:playRefreshAnim(index)
	if index == 1 then
		self.btnNormalSkill1UButton:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	elseif index == 2 then
		self.btnNormalSkill2UButton:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	end
end

function NewSkillComponent:onStudyBtnClick()
	if not self.curSelectedSkillBtn then
		return
	end

	local pet = pg.me:getPetInfo(self.ctrl.petId)

	if pet == nil then
		return
	end

	local data = self.selectSkillData

	if not data then
		return
	end

	local id = Utils.getBasePetPrototypeId(pet.templateId)
	local psdd = PetSkData[id] and PetSkData[id][data.paramId]

	if psdd == nil then
		return
	end

	local consume = psdd.learnSkillConsume
	local args = {
		title = pg.getGameString("LEARN_ABILITY")
	}

	args.data = consume or {}

	function args.confirmCb()
		pg.me:serverMsg("RPC_CS_LearnPetAbility", self.ctrl.petId, data.paramId, CallbackHandler(self, "callbackOnLearnSkill"))
	end

	function args.cancelCb()
		return
	end

	pg.global.ui:open(UIConst.UI_ID_COMMON_USE_CONFIRM, args)
end

function NewSkillComponent:callbackOnLearnSkill(result)
	if result == NoticeDef.SUCCESS then
		local pet = pg.me:getPetInfo(self.ctrl.petId)

		LuaUIUtils.parseSkillBubbleMessage({
			isLearn = true,
			petTmpId = pet.templateId,
			skillId = AbilityUtils.getAbilityIdByParamId(pet.templateId, self.selectSkillData.paramId)
		})

		self.selectSkillData.alreadyLearnt = true
		self.tipInfo = nil

		self:refreshSkillList(self.ctrl.petId)
		self:refreshAllSkills(self.ctrl.petId)
		self:refreshSkillInfo(self.selectSkillData)
		self:refreshReplaceBtnState(self.selectSkillData)
	else
		pg.global.showBubbleMessage(result)
	end
end

function NewSkillComponent:onDestroy()
	if self.delayTimer then
		TimerManager.removeTimer(self.delayTimer)

		self.delayTimer = nil
	end

	if self.exploreRayBoxDelayTimer then
		TimerManager.removeTimer(self.exploreRayBoxDelayTimer)

		self.exploreRayBoxDelayTimer = nil
	end

	self.curSelectedBtn = nil
	self.curSelectedSkillBtn = nil
	self.selectSkillData = nil

	UIComponent.onDestroy(self)
end

function NewSkillComponent:getSkillGlazeType(d)
	if not d then
		return GlazeType.None
	end

	if d.hasGlazePath then
		if d.alreadyGlazed then
			return GlazeType.Upgraded
		else
			return GlazeType.Upgrade
		end
	end

	return GlazeType.None
end

function NewSkillComponent:onClickSwitchSkillDesc()
	if not self.skillInfoData then
		return
	end

	if not self.skillInfoData.hasGlazePath and not self.skillInfoData.alreadyGlazed then
		return
	end

	if self.recordDescType == GlazeType.Upgraded then
		self.recordDescType = GlazeType.None

		self:refreshSwitchSkillDesc(self.skillInfoData)
		ClientTextUtils.setText(self.switchTxtNameUSDFText, pg.getGameString("PETSKILL_UPLV_SWITCH_TITLE"))
	else
		ClientTextUtils.setText(self.switchTxtNameUSDFText, pg.getGameString("PETSKILL_UPLV_SWITCH_TITLE2"))

		self.recordDescType = GlazeType.Upgraded

		if not self.pairedSkillInfoCache then
			local templateId = self.petInfo.templateId
			local petPrototypeId = self.petInfo.petPrototypeId

			if self.skillInfoData.alreadyGlazed and self.skillInfoData.originParamId ~= self.skillInfoData.paramId then
				self.pairedSkillInfoCache = LuaUIUtils.buildEnhancedSkillInfo(self.skillInfoData.originParamId, templateId, petPrototypeId)
			else
				self.pairedSkillInfoCache = LuaUIUtils.buildEnhancedSkillInfo(self.skillInfoData.enhancedSkillId, templateId, petPrototypeId)
			end
		end

		if self.pairedSkillInfoCache then
			self:refreshSwitchSkillDesc(self.pairedSkillInfoCache)
		end
	end
end

function NewSkillComponent:refreshSwitchSkillDescButtonState()
	local showSwitchButton = self:getSkillGlazeType(self.skillInfoData) == GlazeType.Upgrade

	self.btnSwitchUButton:SetActive(showSwitchButton)

	if showSwitchButton then
		ClientTextUtils.setText(self.switchTxtNameUSDFText, pg.getGameString("PETSKILL_UPLV_SWITCH_TITLE"))
	end
end

function NewSkillComponent:refreshSwitchSkillDesc(data)
	local skillDesc = LuaUIUtils.getSkillDesc(data, self.petInfo)

	ClientTextUtils.setText(self.txtLongDetailsUSDFText.content, skillDesc)
	self:refreshAttributeList(data)
end

function NewSkillComponent:refreshAttributeList(skillInfoData)
	LuaUIUtils.setRenderNewPetSkillAttrsList(self.listAttributeUList, skillInfoData)
end

return NewSkillComponent
