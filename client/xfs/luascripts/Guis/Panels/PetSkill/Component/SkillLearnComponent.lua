-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetSkill\\Component\\SkillLearnComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local SkillLearnComponent = Class.LightClass("SkillLearnComponent", UIComponent)
local LuaUIUtils = require("Utils.LuaUIUtils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local ElementPropData = require("Data.element_prop_data")
local Utils = require("Common.Utils.Utils")
local PetSkData = require("Data.pet_skill_data")
local CallbackHandler = require("Core.Common.CallbackHandler")
local NoticeDef = require("Common.NoticeDef")
local UIConst = require("Const.UIConst")
local ItemData = require("Data.item_data")
local AbilityConst = require("Common.Const.AbilityConst")
local ClientTextUtils = require("Utils.ClientTextUtils")

function SkillLearnComponent:findObjects()
	self.objectReference = self.view.learnSkillInfoUComponent.transform:GetComponent("ObjectReference")
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

function SkillLearnComponent:initView()
	function self.view.btnStudyUButton.luaClick()
		self:onStudyBtnClick()
	end

	function self.view.learnConsumeUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local icon = objectReference:GetRefValue("icon")
		local txtNum = objectReference:GetRefValue("txtNum")
		local itemConfig = ItemData[data[1]]

		icon.url = LuaUIUtils.getIconByIconId(itemConfig.icon)

		ClientTextUtils.setText(txtNum, data[2])
	end
end

function SkillLearnComponent:onDestroy()
	self.curSelectedSkillBtn = nil
	self.selectSkillData = nil

	UIComponent.onDestroy(self)
end

function SkillLearnComponent:init(petId)
	self.firstIn = true
	self.petId = petId
	self.curSelectedSkillBtn = nil
	self.selectSkillData = nil

	self:refreshSkillList(true)
	self:refreshSkillInfo()
	self:onSelectedSkillBtnChanged()
end

function SkillLearnComponent:refreshSkillList(needRefreshAni)
	self.qSkillInfo = self.model:getPetSkillInfos(self.petId, AbilityConst.WEAPON_SKILL_ABILITY)
	self.eSkillInfo = self.model:getPetSkillInfos(self.petId, AbilityConst.WEAPON_SKILL_ABILITY2)

	local learnData = self.model:getSkillLearnData(self.petId)

	self.view.skillLearnList:SetEnableCustomInterval(needRefreshAni)

	function self.view.skillLearnList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local baseSkillUButton = objectReference:GetRefValue("baseSkillUButton")
		local advancedtSkill1UButton = objectReference:GetRefValue("advancedtSkill1UButton")
		local advancedtSkill2UButton = objectReference:GetRefValue("advancedtSkill2UButton")

		button:TryChangePage("num", #data)

		if data[1] then
			self:renderSkillBtn(baseSkillUButton, data[1])
		end

		if data[2] then
			self:renderSkillBtn(advancedtSkill1UButton, data[2])
		end

		if data[3] then
			self:renderSkillBtn(advancedtSkill2UButton, data[3])
		end

		if index == 0 and self.firstIn and data[1] then
			baseSkillUButton.luaPress()

			self.firstIn = nil
		end
	end

	self.view.skillLearnList:SetList(learnData)
end

function SkillLearnComponent:renderSkillBtn(b, d)
	local objectReference1 = b:GetComponent("ObjectReference")
	local iconSkillUImage = objectReference1:GetRefValue("iconSkillUImage")
	local txtNameUSDFText1 = objectReference1:GetRefValue("txtNameUSDFText")
	local listTagUList = objectReference1:GetRefValue("listTagUList")
	local elementUButton = objectReference1:GetRefValue("elementUButton")
	local keyEquipmentHotKeyContent = objectReference1:GetRefValue("keyEquipmentHotKeyContent")

	b:TryChangePage("Equipment", 0)

	if self.qSkillInfo and self.qSkillInfo.abilityId == d.abilityId then
		keyEquipmentHotKeyContent:SetHotKeyPaths("Hud/SkillQ")
		b:TryChangePage("Equipment", 1)
	elseif self.eSkillInfo and self.eSkillInfo.abilityId == d.abilityId then
		keyEquipmentHotKeyContent:SetHotKeyPaths("Hud/SkillE")
		b:TryChangePage("Equipment", 1)
	end

	if d.abilityId == self.model.EMPTY_ABILITY_ID then
		b:TryChangePage("empty", 1)
		b:TryChangePage("Element", 0)
		b:TryChangePage("IsRare", 0)
		b:TryChangePage("SkillState", 0)

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

		if d.alreadyLearnt then
			b:TryChangePage("SkillState", 0)
		elseif d.unLock then
			b:TryChangePage("SkillState", 2)
		else
			b:TryChangePage("SkillState", 1)
		end
	end

	function b.luaPress()
		self:onSkillBtnClick(b, d)
	end

	b.name = d.abilityId
end

function SkillLearnComponent:onSkillBtnClick(b, d)
	if b == self.curSelectedSkillBtn then
		return
	else
		self.curSelectedSkillBtn = b
	end

	self:onSelectedSkillBtnChanged(d)
end

function SkillLearnComponent:onSelectedSkillBtnChanged(data)
	local btns = self.view.skillLearnList:GetAllButtons()

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

	self.selectSkillData = data

	self:refreshLearnBtnState()
	self:refreshSkillInfo(data)
end

function SkillLearnComponent:refreshLearnBtnState()
	if not self.curSelectedSkillBtn or not self.selectSkillData then
		self.view.root:TryChangePage("showLearnBtn", 0)
		ClientTextUtils.setText(self.view.skillLearnTip, pg.getGameString("SKILL_NOT_CHOOSE"))
		self.view.descUSDFText.gameObject:SetActiveEx(false)

		return
	end

	if self.selectSkillData.alreadyLearnt then
		self.view.root:TryChangePage("showLearnBtn", 0)
		ClientTextUtils.setText(self.view.skillLearnTip, pg.getGameString("SKILL_ALREADY_LEARNT"))
		self.view.descUSDFText.gameObject:SetActiveEx(false)
	elseif self.selectSkillData.unLock then
		self.view.root:TryChangePage("showLearnBtn", 1)
		self.view.learnConsumeUList:SetList(Utils.deepCopyTable(self.selectSkillData.consume))
	else
		self.view.root:TryChangePage("showLearnBtn", 0)
		ClientTextUtils.setText(self.view.skillLearnTip, pg.getGameString("SKILL_LOCKED"))
		self.view.descUSDFText.gameObject:SetActiveEx(true)
		ClientTextUtils.setText(self.view.descUSDFText, self.selectSkillData.unlockRequirement and pg.getLocalizationText(self.selectSkillData.unlockRequirement) or "")
	end
end

function SkillLearnComponent:refreshSkillInfo(data)
	if not self.curSelectedSkillBtn or not data then
		self.view.learnSkillInfoUComponent.gameObject:SetActiveEx(false)

		return
	end

	self.view.learnSkillInfoUComponent.gameObject:SetActiveEx(true)

	local pInfo = pg.me:getPetInfo(self.curPetId)

	self.view.learnSkillInfoUComponent:TryChangePage("IsRare", ToInt(AbilityUtils.isRareAbilityId(data.abilityId, pInfo.templateId)))
	ClientTextUtils.setText(self.txtName, pg.getLocalizationText(data.name))

	if pg.game.setting:getShowDebugId() then
		ClientTextUtils.setText(self.txtName, self.txtName.text, string.format("%s_%s", data.abilityId, AbilityUtils.getAbilityParamId(data.abilityId)))
	end

	self.iconSkillUImage.url = LuaUIUtils.getSkillIcon(data.icon)

	LuaUIUtils.setElementButtonNew(self.elementUButton, data.elementType)
	self.detailsUWidget.gameObject:SetActiveEx(data.desc ~= nil)

	local skillDesc = LuaUIUtils.getSkillDesc(data, pInfo)

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

function SkillLearnComponent:onStudyBtnClick()
	if not self.curSelectedSkillBtn then
		return
	end

	local pet = pg.me:getPetInfo(self.petId)

	if pet == nil then
		return
	end

	local data = self.selectSkillData

	if not data then
		return
	end

	local psdd = PetSkData[pet.templateId] and PetSkData[pet.templateId][data.paramId]

	if psdd == nil then
		return
	end

	local consume = psdd.learnSkillConsume
	local args = {
		title = pg.getGameString("LEARN_ABILITY")
	}

	args.data = consume or {}

	function args.confirmCb()
		pg.me:serverMsg("RPC_CS_LearnPetAbility", self.petId, data.paramId, CallbackHandler(self, "callbackOnLearnSkill"))
	end

	function args.cancelCb()
		return
	end

	pg.global.ui:open(UIConst.UI_ID_COMMON_USE_CONFIRM, args)
end

function SkillLearnComponent:callbackOnLearnSkill(result)
	if result == NoticeDef.SUCCESS then
		local pet = pg.me:getPetInfo(self.petId)

		LuaUIUtils.parseSkillBubbleMessage({
			isLearn = true,
			petTmpId = pet.templateId,
			skillId = AbilityUtils.getAbilityIdByParamId(pet.templateId, self.selectSkillData.paramId)
		})

		self.selectSkillData.alreadyLearnt = true

		self:refreshSkillList(false)
		self:refreshSkillInfo(self.selectSkillData)
		self:refreshLearnBtnState()
	else
		pg.global.showBubbleMessage(result)

		return
	end
end

return SkillLearnComponent
