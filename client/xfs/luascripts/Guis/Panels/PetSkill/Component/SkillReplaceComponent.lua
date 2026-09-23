-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetSkill\\Component\\SkillReplaceComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local SkillReplaceComponent = Class.LightClass("SkillReplaceComponent", UIComponent)
local AbilityConst = require("Common.Const.AbilityConst")
local TimerManager = require("Core.Timer.TimerManager")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local Lume = require("Core.Common.lume")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local ElementPropData = require("Data.element_prop_data")
local ClientTextUtils = require("Utils.ClientTextUtils")

function SkillReplaceComponent:findObjects()
	self.skillUContainerObjectReference = self.view.skillPresetUContainer.content.transform:GetComponent("ObjectReference")
	self.btnUniqueSkillUButton = self.skillUContainerObjectReference:GetRefValue("btnUniqueSkillUButton")
	self.btnNormalSkill1UButton = self.skillUContainerObjectReference:GetRefValue("btnNormalSkill1UButton")
	self.btnNormalSkill2UButton = self.skillUContainerObjectReference:GetRefValue("btnNormalSkill2UButton")
	self.btnExploreSkillUButton = self.skillUContainerObjectReference:GetRefValue("btnExploreSkillUButton")
	self.btnFeaturesUButton = self.skillUContainerObjectReference:GetRefValue("btnFeaturesUButton")
	self.objectReference = self.view.skillInfoUComponent.transform:GetComponent("ObjectReference")
	self.txtName = self.objectReference:GetRefValue("txtName")
	self.listTagUList = self.objectReference:GetRefValue("listTagUList")
	self.elementUButton = self.objectReference:GetRefValue("elementUButton")
	self.elementText = self.objectReference:GetRefValue("elementText")
	self.damageTypeUButton = self.objectReference:GetRefValue("damageTypeUButton")
	self.cost = self.objectReference:GetRefValue("cost")
	self.cd = self.objectReference:GetRefValue("cd")
	self.iconSkillUImage = self.objectReference:GetRefValue("iconSkillUImage")
	self.txtShortDetailsUSDFText = self.objectReference:GetRefValue("txtShortDetailsUSDFText")
	self.txtLongDetailsUSDFText = self.objectReference:GetRefValue("txtLongDetailsUSDFText")
	self.detailsUWidget = self.objectReference:GetRefValue("detailsUWidget")
end

function SkillReplaceComponent:initView()
	function self.view.btnSkillPresetsUButton.luaClick()
		self:onClickSkillPresetsButton()
	end

	function self.view.btnSwapUButton.luaClick()
		self:modifySkill(self.curSelectedBtn.name, self.curSelectedSkillBtn.name)
	end
end

function SkillReplaceComponent:init(id)
	self.firstInForCurSelectedBtn = true
	self.firstInForCurSelectedSkillBtn = true
	self.petId = id
	self.curSelectedBtn = nil
	self.curSelectedSkillBtn = nil

	self:setFeature(id)
	self:refreshSkillList(id)
	self:refreshAllSkills(id)
	self:refreshSkillInfo()
	self:onSelectedBtnChanged()
	self:onSelectedSkillBtnChanged()
end

function SkillReplaceComponent:setFeature(petId)
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

function SkillReplaceComponent:refreshSkillList(petId)
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
		if self.model.IS_PVP_FAIL_MODE then
			local pvpPetSet = pg.global.ui.pvpPetSet
			local serverData = pvpPetSet.model.petsMap[petId].serverData

			ClientTextUtils.setText(self.view.skillPresetName, ClientTextUtils.concatByLanguage(pg.getGameString("ABILITY_PLAN"), serverData.curAbilityPreset))
		else
			local petInfo = pg.me:getPetInfo(petId)

			if not petInfo or not petInfo.abilityPresetMap then
				return
			end

			local presetName = petInfo.abilityPresetMap[petInfo.curAbilityPreset].name

			if presetName and presetName ~= "" then
				ClientTextUtils.setText(self.view.skillPresetName, presetName)
			else
				ClientTextUtils.setText(self.view.skillPresetName, ClientTextUtils.concatByLanguage(pg.getGameString("ABILITY_PLAN"), petInfo.curAbilityPreset))
			end
		end
	end)
end

function SkillReplaceComponent:renderSkillCmp(button, data)
	LuaUIUtils.renderSkillCmpCommon(button, data, nil, nil, nil, self.petInfo)

	button.enabledTooltip = false

	function button.luaPress()
		if button == self.curSelectedBtn then
			return
		else
			self.curSelectedBtn = button
		end

		self:onSelectedBtnChanged()
		self:refreshSkillInfo(data)
	end

	if not data then
		return
	end

	local templateId

	if self.model.IS_PVP_FAIL_MODE then
		local pvpPetSet = pg.global.ui.pvpPetSet

		templateId = pvpPetSet.model.petsMap[self.petId].templateId
	else
		local petInfo = pg.me:getPetInfo(self.petId)

		templateId = petInfo.templateId
	end

	button:TryChangePage("IsRare", ToInt(AbilityUtils.isRareAbilityId(data.abilityId, templateId)))

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

function SkillReplaceComponent:onSelectedBtnChanged()
	self.btnNormalSkill1UButton:TryChangePage("Selected", self.curSelectedBtn == self.btnNormalSkill1UButton and 1 or 0)
	self.btnNormalSkill2UButton:TryChangePage("Selected", self.curSelectedBtn == self.btnNormalSkill2UButton and 1 or 0)
	self:refreshReplaceBtnState()
end

function SkillReplaceComponent:onSelectedSkillBtnChanged(data)
	local btns = self.view.allSkillsList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		local objectReference = btns[i]:GetComponent("ObjectReference")
		local baseSkillUButton = objectReference:GetRefValue("baseSkillUButton")
		local advancedtSkill1UButton = objectReference:GetRefValue("advancedtSkill1UButton")
		local advancedtSkill2UButton = objectReference:GetRefValue("advancedtSkill2UButton")

		baseSkillUButton:TryChangePage("Selected", 0)
		advancedtSkill1UButton:TryChangePage("Selected", 0)
		advancedtSkill2UButton:TryChangePage("Selected", 0)

		if self.curSelectedSkillBtn == baseSkillUButton or self.curSelectedSkillBtn == advancedtSkill1UButton or self.curSelectedSkillBtn == advancedtSkill2UButton then
			self.curSelectedSkillBtn:TryChangePage("Selected", 1)
		end
	end

	self:refreshReplaceBtnState()
	self:refreshSkillInfo(data)
end

function SkillReplaceComponent:refreshReplaceBtnState()
	self.view.root:TryChangePage("showReplaceBtn", self.curSelectedSkillBtn and self.curSelectedBtn and 1 or 0)
end

function SkillReplaceComponent:renderExploreSkillCmp(button, data)
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

function SkillReplaceComponent:refreshAllSkillsBtnState()
	local btns = self.view.allSkillsList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		local objectReference = btns[i]:GetComponent("ObjectReference")
		local baseSkillUButton = objectReference:GetRefValue("baseSkillUButton")
		local advancedtSkill1UButton = objectReference:GetRefValue("advancedtSkill1UButton")
		local advancedtSkill2UButton = objectReference:GetRefValue("advancedtSkill2UButton")

		self:refreshEquipmentStatus(baseSkillUButton, tonumber(baseSkillUButton.name))
		self:refreshEquipmentStatus(advancedtSkill1UButton, tonumber(advancedtSkill1UButton.name))
		self:refreshEquipmentStatus(advancedtSkill2UButton, tonumber(advancedtSkill2UButton.name))
	end
end

function SkillReplaceComponent:refreshEquipmentStatus(b, abilityId)
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

function SkillReplaceComponent:refreshAllSkills(id)
	local data = self.model:getPetAllUnlockedSkill(id)
	local qSkillInfo = self.model:getPetSkillInfos(id, AbilityConst.WEAPON_SKILL_ABILITY)

	function self.view.allSkillsList.luaRenderItem(button, index, data1)
		local objectReference = button:GetComponent("ObjectReference")
		local baseSkillUButton = objectReference:GetRefValue("baseSkillUButton")
		local advancedtSkill1UButton = objectReference:GetRefValue("advancedtSkill1UButton")
		local advancedtSkill2UButton = objectReference:GetRefValue("advancedtSkill2UButton")

		button:TryChangePage("num", #data1)

		if data1[1] then
			self:renderSkillBtn(baseSkillUButton, data1[1])

			if self.firstInForCurSelectedSkillBtn and qSkillInfo and qSkillInfo.abilityId == data1[1].abilityId then
				baseSkillUButton.luaPress()

				self.firstInForCurSelectedSkillBtn = nil
			end
		end

		if data1[2] then
			self:renderSkillBtn(advancedtSkill1UButton, data1[2])

			if self.firstInForCurSelectedSkillBtn and qSkillInfo and qSkillInfo.abilityId == data1[2].abilityId then
				advancedtSkill1UButton.luaPress()

				self.firstInForCurSelectedSkillBtn = nil
			end
		end

		if data1[3] then
			self:renderSkillBtn(advancedtSkill2UButton, data1[3])

			if self.firstInForCurSelectedSkillBtn and qSkillInfo and qSkillInfo.abilityId == data1[3].abilityId then
				advancedtSkill2UButton.luaPress()

				self.firstInForCurSelectedSkillBtn = nil
			end
		end

		if self.firstInForCurSelectedSkillBtn and not qSkillInfo and index == 0 then
			baseSkillUButton.luaPress()

			self.firstInForCurSelectedSkillBtn = nil
		end
	end

	self.view.allSkillsList:SetList(data)
end

function SkillReplaceComponent:onSkillBtnClick(btn, data)
	if btn == self.curSelectedSkillBtn then
		return
	else
		self.curSelectedSkillBtn = btn
	end

	self:onSelectedSkillBtnChanged(data)

	if data.alreadyLearnt then
		self.view.btnSwapUButton:TryChangePage("enable", 1)

		self.tipInfo = nil
	else
		self.view.btnSwapUButton:TryChangePage("enable", 0)

		self.tipInfo = pg.getGameString("SKILL_NOT_LEARNED_CAN_NOT_EQUIP")
	end
end

function SkillReplaceComponent:renderSkillBtn(b, d)
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

		b.enabledTooltip = false
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

		b:TryChangePage("SkillState", state)
	end

	function b.luaPress()
		self:onSkillBtnClick(b, d)
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
	end

	function b.luaEndDrag(dropTarget)
		if not dropTarget or dropTarget.name ~= tostring(AbilityConst.WEAPON_SKILL_ABILITY) and dropTarget.name ~= tostring(AbilityConst.WEAPON_SKILL_ABILITY2) then
			return
		end

		if self.model:isAbilityIdLearnt(self.petId, d.abilityId) then
			self.tipInfo = nil
		else
			self.tipInfo = pg.getGameString("SKILL_NOT_LEARNED_CAN_NOT_EQUIP")
		end

		self:modifySkill(dropTarget.name, tostring(d.abilityId))
	end
end

function SkillReplaceComponent:onClickSkillPresetsButton()
	local templateId

	if self.model.IS_PVP_FAIL_MODE then
		local pvpPetSet = pg.global.ui.pvpPetSet

		templateId = pvpPetSet.model.petsMap[self.petId].templateId
	else
		local petInfo = pg.me:getPetInfo(self.petId)

		if not petInfo or not petInfo.abilityPresetMap then
			return
		end

		templateId = petInfo.templateId

		local presetName = petInfo.abilityPresetMap[petInfo.curAbilityPreset].name
	end

	pg.global.ui:open(UIConst.UI_ID_PET_SKILL_REPLACE_QUICK, {
		curPetId = self.petId,
		pvpFailMode = self.model.IS_PVP_FAIL_MODE,
		templateId = templateId,
		notPetManagement = self.ctrl.notPetManagement
	})
end

function SkillReplaceComponent:modifySkill(curSelectedBtnName, curSelectedSkillBtnName)
	if self.model.IS_PVP_FAIL_MODE then
		local pvpPetSet = pg.global.ui.pvpPetSet
		local serverData = pvpPetSet.model.petsMap[self.petId].serverData
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

		pvpPetSet:sendSavePetInfoMsg(self.petId, 2)
	else
		if self.tipInfo then
			pg.global.showBubbleMessageRaw(self.tipInfo)

			return
		end

		local petInfo = pg.me:getPetInfo(self.petId)

		pg.me:serverMsg("RPC_CS_PetModifyAbilityPreset", self.petId, petInfo.curAbilityPreset, tonumber(curSelectedBtnName), tonumber(curSelectedSkillBtnName))
	end
end

function SkillReplaceComponent:refreshSkillInfo(data)
	if not self.curSelectedSkillBtn or not data then
		self.view.skillInfoUComponent.gameObject:SetActiveEx(false)

		return
	end

	self.view.skillInfoUComponent.gameObject:SetActiveEx(true)

	local templateId

	if self.model.IS_PVP_FAIL_MODE then
		local pvpPetSet = pg.global.ui.pvpPetSet

		templateId = pvpPetSet.model.petsMap[self.petId].templateId
	else
		local petInfo = pg.me:getPetInfo(self.petId)

		templateId = petInfo.templateId
	end

	self.view.skillInfoUComponent:TryChangePage("IsRare", ToInt(AbilityUtils.isRareAbilityId(data.abilityId, templateId)))
	ClientTextUtils.setText(self.txtName, pg.getLocalizationText(data.name))

	if pg.game.setting:getShowDebugId() then
		ClientTextUtils.setText(self.txtName, self.txtName.text, string.format("%s_%s", data.abilityId, AbilityUtils.getAbilityParamId(data.abilityId)))
	end

	self.iconSkillUImage.url = LuaUIUtils.getSkillIcon(data.icon)

	LuaUIUtils.setElementButtonNew(self.elementUButton, data.elementType)
	self.detailsUWidget.gameObject:SetActiveEx(data.desc ~= nil)

	local skillDesc = LuaUIUtils.getSkillDesc(data, self.petInfo)

	ClientTextUtils.setText(self.txtLongDetailsUSDFText.content, skillDesc)
	ClientTextUtils.setText(self.txtShortDetailsUSDFText, skillDesc)
	ClientTextUtils.setText(self.cost, data.numberList[1].number)
	ClientTextUtils.setText(self.cd, data.numberList[2].number)
	self.damageTypeUButton:TryChangePage("Type", data.attackType)
	ClientTextUtils.setText(self.elementText, pg.getLocalizationText(ElementPropData[data.elementType].name_ch))

	function self.listTagUList.luaRenderItem(b, _, d)
		local objectReference1 = b:GetComponent("ObjectReference")
		local txtNameUText = objectReference1:GetRefValue("txtNameUText")

		ClientTextUtils.setText(txtNameUText, pg.getLocalizationText(d.tagName))
	end

	self.listTagUList:SetList(data.tagList)
end

function SkillReplaceComponent:playRefreshAnim(index)
	if index == 1 then
		self.btnNormalSkill1UButton:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	elseif index == 2 then
		self.btnNormalSkill2UButton:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	end
end

function SkillReplaceComponent:onDestroy()
	self.curSelectedBtn = nil
	self.curSelectedSkillBtn = nil

	UIComponent.onDestroy(self)
end

return SkillReplaceComponent
