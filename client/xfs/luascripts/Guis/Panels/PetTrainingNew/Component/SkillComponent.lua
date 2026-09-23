-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTrainingNew\\Component\\SkillComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local SkillComponent = Class.LightClass("SkillComponent", UIComponent)
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

function SkillComponent:findObjects()
	self.objectReference = self.view.skillPanelUComponent.transform:GetComponent("ObjectReference")
	self.imgPetUImage = self.objectReference:GetRefValue("imgPetUImage")
	self.petName = self.objectReference:GetRefValue("petName")
	self.imgPet1UImage = self.objectReference:GetRefValue("imgPet1UImage")
	self.btnSkillPresetsUButton = self.objectReference:GetRefValue("btnSkillPresetsUButton")
	self.skillPresetName = self.objectReference:GetRefValue("skillPresetName")
	self.btnUniqueSkillUButton = self.objectReference:GetRefValue("btnUniqueSkillUButton")
	self.btnNormalSkill1UButton = self.objectReference:GetRefValue("btnNormalSkill1UButton")
	self.btnNormalSkill2UButton = self.objectReference:GetRefValue("btnNormalSkill2UButton")
	self.btnExploreSkillUButton = self.objectReference:GetRefValue("btnExploreSkillUButton")
	self.btnFeaturesUButton = self.objectReference:GetRefValue("btnFeaturesUButton")
	self.btnSwapUButton = self.objectReference:GetRefValue("btnSwapUButton")
	self.allSkillsList = self.objectReference:GetRefValue("allSkillsList")
	self.skillInfoUComponent = self.objectReference:GetRefValue("skillInfoUComponent")
	self.txtName = self.objectReference:GetRefValue("txtName")
	self.iconSkillUImage = self.objectReference:GetRefValue("iconSkillUImage")
	self.elementUButton = self.objectReference:GetRefValue("elementUButton")
	self.txtShortDetailsUSDFText = self.objectReference:GetRefValue("txtShortDetailsUSDFText")
	self.txtLongDetailsUSDFText = self.objectReference:GetRefValue("txtLongDetailsUSDFText")
	self.cost = self.objectReference:GetRefValue("cost")
	self.cd = self.objectReference:GetRefValue("cd")
	self.damageTypeUButton = self.objectReference:GetRefValue("damageTypeUButton")
	self.elementText = self.objectReference:GetRefValue("elementText")
	self.listTagUList = self.objectReference:GetRefValue("listTagUList")
	self.descUSDFText = self.objectReference:GetRefValue("descUSDFText")
	self.btnStudyUButton = self.objectReference:GetRefValue("btnStudyUButton")
	self.dropHotKeyContent = self.objectReference:GetRefValue("dropHotKeyContent")
	self.changeLHotKeyContent = self.objectReference:GetRefValue("changeLHotKeyContent")
	self.changeRHotKeyContent = self.objectReference:GetRefValue("changeRHotKeyContent")
	self.swapHotKeyContent = self.objectReference:GetRefValue("swapHotKeyContent")
	self.btnSwitchMaxUButton = self.objectReference:GetRefValue("btnSwitchMaxUButton")

	LuaUIUtils.setUIViewVisible(self.btnSwitchMaxUButton, false)
end

function SkillComponent:initView()
	function self.btnSkillPresetsUButton.luaClick()
		self:onClickSkillPresetsButton()
	end

	function self.btnSwapUButton.luaClick()
		self:modifySkill(self.curSelectedBtn.name, self.curSelectedSkillBtn.name)
	end

	function self.btnStudyUButton.luaClick()
		self:onStudyBtnClick()
	end

	self.dropHotKeyContent:SetHotKeyPaths("Raw/GamepadDPadDown")
	self.changeLHotKeyContent:SetHotKeyPaths("Raw/GamepadDPadLeft")
	self.changeRHotKeyContent:SetHotKeyPaths("Raw/GamepadDPadRight")
	self.swapHotKeyContent:SetHotKeyPaths("Raw/GamepadButtonWest")
	self.ctrl:bindHotKeyPerform("Raw/GamepadDPadDown", function()
		self.btnSkillPresetsUButton.luaClick()
	end, self.btnSkillPresetsUButton.gameObject)
	self.ctrl:bindHotKeyPerform("Raw/GamepadDPadLeft", function()
		self.btnNormalSkill1UButton.luaPress()
	end, self.btnNormalSkill1UButton.gameObject)
	self.ctrl:bindHotKeyPerform("Raw/GamepadDPadRight", function()
		self.btnNormalSkill2UButton.luaPress()
	end, self.btnNormalSkill2UButton.gameObject)
	self.ctrl:bindHotKeyPerform("Raw/GamepadButtonWest", function()
		self.btnSwapUButton.luaClick()
	end, self.btnSwapUButton.gameObject)
end

function SkillComponent:init(info)
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
end

function SkillComponent:setFeature(petId)
	self.btnFeaturesUButton.enabledTooltip = false

	self.btnFeaturesUButton:TryChangePage("mute", 1)

	local featureInfo = self.model:getCurCharacter(petId)

	if featureInfo then
		local objectReference = self.btnFeaturesUButton:GetComponent("ObjectReference")
		local iconFeatureUImage = objectReference:GetRefValue("iconFeatureUImage")

		self.btnFeaturesUButton:TryChangePage("IsRare", featureInfo.rare or 0)
		self.btnFeaturesUButton:TryChangePage("State", 1)

		iconFeatureUImage.url = featureInfo.icon
	else
		self.btnFeaturesUButton:TryChangePage("IsRare", 0)
		self.btnFeaturesUButton:TryChangePage("State", 0)
	end
end

function SkillComponent:refreshSkillList(petId)
	local ultSkillInfo = self.model:getPetSkillInfos(petId, AbilityConst.ULTIMATE_ABILITY)

	self.qSkillInfo = self.model:getPetSkillInfos(petId, AbilityConst.WEAPON_SKILL_ABILITY)
	self.eSkillInfo = self.model:getPetSkillInfos(petId, AbilityConst.WEAPON_SKILL_ABILITY2)

	local exploreSkillInfo = self.model:getPetSkillInfos(petId, AbilityConst.EXPLORE_ABILITY)

	self.petInfo = pg.me:getPetInfo(petId)

	self:renderSkillCmp(self.btnUniqueSkillUButton, ultSkillInfo)
	self.btnUniqueSkillUButton:TryChangePage("mute", 1)
	self:renderSkillCmp(self.btnNormalSkill1UButton, self.qSkillInfo)
	self:renderSkillCmp(self.btnNormalSkill2UButton, self.eSkillInfo)

	self.btnNormalSkill1UButton.name = "1"
	self.btnNormalSkill1UButton.draggable = self.qSkillInfo ~= nil
	self.btnNormalSkill2UButton.name = "2"
	self.btnNormalSkill2UButton.draggable = self.eSkillInfo ~= nil

	self:renderExploreSkillCmp(self.btnExploreSkillUButton, exploreSkillInfo)
	self.btnExploreSkillUButton:TryChangePage("mute", 1)

	if self.firstInForCurSelectedBtn then
		self.btnNormalSkill1UButton.luaPress()

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

function SkillComponent:renderSkillCmp(button, data)
	LuaUIUtils.renderSkillCmpCommon(button, data, nil, nil, nil, self.petInfo)

	button.enabledTooltip = false

	function button.luaPress()
		self.curSelectedBtn = button

		self:onSelectedBtnChanged(data)
		self:refreshSkillInfo(data)
	end

	if not data then
		return
	end

	button:TryChangePage("IsRare", ToInt(AbilityUtils.isRareAbilityId(data.abilityId, self.petInfo.templateId)))

	function button.luaBeginDrag()
		button.replicaWidget.transform.localScale = Vector3(1.5, 1.5, 1.5)

		local objectReference1 = button.replicaWidget:GetComponent("ObjectReference")
		local iconSkillUImage1 = objectReference1:GetRefValue("iconSkillUImage")
		local elementUButton1 = objectReference1:GetRefValue("elementUButton")

		iconSkillUImage1.url = LuaUIUtils.getSkillIcon(data.icon)

		if data.elementType then
			button.replicaWidget:TryChangePage("Element", 1)
			LuaUIUtils.setElementButtonNew(elementUButton1, data.elementType)
		end
	end

	function button.luaEndDrag(dropTarget)
		self.tipInfo = nil

		if not dropTarget or dropTarget.name ~= tostring(AbilityConst.WEAPON_SKILL_ABILITY) and dropTarget.name ~= tostring(AbilityConst.WEAPON_SKILL_ABILITY2) then
			self:modifySkill(tostring(data.abilityType), tostring(self.model.EMPTY_ABILITY_ID))

			return
		end

		self:modifySkill(dropTarget.name, tostring(data.abilityId))
	end
end

function SkillComponent:onSelectedBtnChanged(data)
	self.btnNormalSkill1UButton:TryChangePage("Selected", self.curSelectedBtn == self.btnNormalSkill1UButton and 1 or 0)
	self.btnNormalSkill2UButton:TryChangePage("Selected", self.curSelectedBtn == self.btnNormalSkill2UButton and 1 or 0)
	self:refreshReplaceBtnState(data)
end

function SkillComponent:onSelectedSkillBtnChanged(data)
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

function SkillComponent:refreshReplaceBtnState(data)
	if not data then
		self.view.skillPanelUComponent:TryChangePage("BtnState", 3)

		return
	end

	if data.alreadyLearnt == nil and data.unLock == nil then
		self.view.skillPanelUComponent:TryChangePage("BtnState", self.curSelectedSkillBtn and self.curSelectedBtn and 2 or 3)

		return
	end

	if data.alreadyLearnt then
		self.view.skillPanelUComponent:TryChangePage("BtnState", self.curSelectedSkillBtn and self.curSelectedBtn and 2 or 3)
	elseif data.unLock then
		self.view.skillPanelUComponent:TryChangePage("BtnState", 1)
	else
		self.view.skillPanelUComponent:TryChangePage("BtnState", 0)
		ClientTextUtils.setText(self.descUSDFText, data.unlockRequirement and pg.getLocalizationText(data.unlockRequirement) or "")
	end
end

function SkillComponent:renderExploreSkillCmp(button, data)
	button:TryChangePage("State", 0)
	button:TryChangePage("Element", 0)

	button.enabledTooltip = false

	if not data then
		button:SetActive(false)

		return
	end

	button:SetActive(true)
	button:TryChangePage("State", 1)

	local objectReference = button:GetComponent("ObjectReference")
	local iconNormalUImage = objectReference:GetRefValue("iconNormalUImage")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

	iconNormalUImage.url = LuaUIUtils.getSkillIcon(data.icon)

	ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.name))
end

function SkillComponent:refreshAllSkillsBtnState()
	local btns = self.allSkillsList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		self:refreshEquipmentStatus(btns[i], tonumber(btns[i].name))
	end
end

function SkillComponent:refreshEquipmentStatus(b, abilityId)
	local objectReference = b:GetComponent("ObjectReference")
	local keyEquipmentHotKeyContent = objectReference:GetRefValue("keyEquipmentHotKeyContent")

	b:TryChangePage("Equipment", 0)

	if self.qSkillInfo and self.qSkillInfo.abilityId == abilityId then
		keyEquipmentHotKeyContent:SetHotKeyPaths("Hud/SkillQ")
		b:TryChangePage("Equipment", 1)
	elseif self.eSkillInfo and self.eSkillInfo.abilityId == abilityId then
		keyEquipmentHotKeyContent:SetHotKeyPaths("Hud/SkillE")
		b:TryChangePage("Equipment", 1)
	end
end

function SkillComponent:refreshAllSkills(id)
	local data = self.model:getPetAllUnlockedSkill(id)
	local qSkillInfo = self.model:getPetSkillInfos(id, AbilityConst.WEAPON_SKILL_ABILITY)

	function self.allSkillsList.luaRenderItem(button, index, data1)
		button.enabledTooltip = false
		button.draggable = true

		self:renderSkillBtn(button, data1)

		if self.firstInForCurSelectedSkillBtn and not qSkillInfo and index == 0 then
			button.luaPress()

			self.firstInForCurSelectedSkillBtn = nil
		end
	end

	self.allSkillsList:SetList(data)
end

function SkillComponent:onSkillBtnClick(btn, data)
	self.curSelectedSkillBtn = btn

	self:onSelectedSkillBtnChanged(data)

	if data.alreadyLearnt then
		self.btnSwapUButton:TryChangePage("enable", 1)

		self.tipInfo = nil
	else
		self.btnSwapUButton:TryChangePage("enable", 0)

		self.tipInfo = pg.getGameString("SKILL_NOT_LEARNED_CAN_NOT_EQUIP")
	end
end

function SkillComponent:renderSkillBtn(b, d)
	local objectReference1 = b:GetComponent("ObjectReference")
	local iconSkillUImage = objectReference1:GetRefValue("iconSkillUImage")
	local txtNameUSDFText1 = objectReference1:GetRefValue("txtNameUSDFText")
	local listTagUList = objectReference1:GetRefValue("listTagUList")
	local elementUButton = objectReference1:GetRefValue("elementUButton")

	self:refreshEquipmentStatus(b, d.abilityId)

	local state = 0

	if d.abilityId == self.model.EMPTY_ABILITY_ID then
		b:TryChangePage("empty", 1)
		b:TryChangePage("Element", 0)
		b:TryChangePage("IsRare", 0)

		b.draggable = false
	else
		b:TryChangePage("empty", 0)
		b:TryChangePage("IsRare", d.rare)

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
end

function SkillComponent:onClickSkillPresetsButton()
	pg.global.ui:open(UIConst.UI_ID_PET_SKILL_REPLACE_QUICK, {
		curPetId = self.ctrl.petId,
		pvpFailMode = self.model.IS_PVP_FAIL_MODE,
		templateId = self.petInfo.templateId,
		notPetManagement = self.ctrl.notPetManagement
	})
end

function SkillComponent:modifySkill(curSelectedBtnName, curSelectedSkillBtnName)
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

function SkillComponent:refreshSkillInfo(data)
	self.skillInfoData = data or self.skillInfoData

	if not self.skillInfoData then
		self.skillInfoUComponent.gameObject:SetActiveEx(false)

		return
	end

	self.skillInfoUComponent.gameObject:SetActiveEx(true)
	self.skillInfoUComponent:TryChangePage("IsRare", ToInt(AbilityUtils.isRareAbilityId(self.skillInfoData.abilityId, self.petInfo.templateId)))
	ClientTextUtils.setText(self.txtName, pg.getLocalizationText(self.skillInfoData.name))

	if pg.game.setting:getShowDebugId() then
		ClientTextUtils.setText(self.txtName, self.txtName.text, string.format("%s_%s", self.skillInfoData.abilityId, AbilityUtils.getAbilityParamId(self.skillInfoData.abilityId)))
	end

	self.iconSkillUImage.url = LuaUIUtils.getSkillIcon(self.skillInfoData.icon)

	LuaUIUtils.setElementButtonNew(self.elementUButton, self.skillInfoData.elementType)

	local skillDesc = LuaUIUtils.getSkillDesc(self.skillInfoData, self.petInfo)

	LuaUIUtils.customRichTextData.petInfo = self.petInfo

	ClientTextUtils.setText(self.txtLongDetailsUSDFText.content, skillDesc)
	ClientTextUtils.setText(self.txtShortDetailsUSDFText, pg.getLocalizationText(self.skillInfoData.shortDesc) or "empty config")

	LuaUIUtils.customRichTextData.petInfo = nil

	local function inner()
		if self.model.showLongDesc then
			self.btnSwitchMaxUButton:TryChangePage("TextType", 1)
			self.skillInfoUComponent:TryChangePage("Details", 1)
		else
			self.btnSwitchMaxUButton:TryChangePage("TextType", 0)
			self.skillInfoUComponent:TryChangePage("Details", 0)
		end

		self.model.showLongDesc = true
	end

	inner()

	function self.btnSwitchMaxUButton.luaClick()
		self.model.showLongDesc = not self.model.showLongDesc

		inner()
	end

	ClientTextUtils.setText(self.cost, self.skillInfoData.numberList[1].number)
	ClientTextUtils.setText(self.cd, self.skillInfoData.numberList[2].number)
	self.damageTypeUButton:TryChangePage("Type", self.skillInfoData.attackType)
	ClientTextUtils.setText(self.elementText, pg.getLocalizationText(ElementPropData[self.skillInfoData.elementType].name_ch))

	function self.listTagUList.luaRenderItem(b, _, d)
		local objectReference1 = b:GetComponent("ObjectReference")
		local txtNameUText = objectReference1:GetRefValue("txtNameUText")

		ClientTextUtils.setText(txtNameUText, pg.getLocalizationText(d.tagName))
	end

	self.listTagUList:SetList(self.skillInfoData.tagList)
end

function SkillComponent:playRefreshAnim(index)
	if index == 1 then
		self.btnNormalSkill1UButton:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	elseif index == 2 then
		self.btnNormalSkill2UButton:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	end
end

function SkillComponent:onStudyBtnClick()
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

function SkillComponent:callbackOnLearnSkill(result)
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

function SkillComponent:onDestroy()
	self.curSelectedBtn = nil
	self.curSelectedSkillBtn = nil
	self.selectSkillData = nil

	UIComponent.onDestroy(self)
end

return SkillComponent
