-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTrainingNew\\Component\\SubNodeComps\\PetSkillInfoComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("PetSkillInfoComponent")
local Class = require("Core.Framework.Class")
local PetSkillInfoComponent = Class.LiteClass("PetSkillInfoComponent")
local Utils = require("Common.Utils.Utils")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local TimerManager = require("Core.Timer.TimerManager")
local PetData = require("Data.pet_data")
local PetConfigData = require("Data.pet_config_data")
local ClientUtils = require("Utils.ClientUtils")
local PetLevelData = require("Data.pet_level_data")
local math_floor = math.floor
local string_format = string.format

function PetSkillInfoComponent:ctor(parentView, parentCtrl, uComponent)
	self.parentView = parentView
	self.parentCtrl = parentCtrl
	self.uComponent = uComponent

	local objectReference = self.uComponent:GetComponent("ObjectReference")

	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.iconSkillUImage = objectReference:GetRefValue("iconSkillUImage")
	self.elementUButton = objectReference:GetRefValue("elementUButton")
	self.listTagUList = objectReference:GetRefValue("listTagUList")
	self.listAttributeUList = objectReference:GetRefValue("listAttributeUList")
	self.txtLongDetailsUSDFText = objectReference:GetRefValue("txtLongDetailsUSDFText")
	self.longDescScrollRectUScrollRect = objectReference:GetRefValue("longDescScrollRectUScrollRect")
	self.btnStrengthenUButton = objectReference:GetRefValue("btnStrengthenUButton")
	self.btnReadyUWidget = objectReference:GetRefValue("btnReadyUWidget")
	self.btnSwitchUButton = objectReference:GetRefValue("btnSwitchUButton")
	self.switchTxtNameUSDFText = objectReference:GetRefValue("switchTxtNameUSDFText")
	self.infoSkillClickButtonUButton = objectReference:GetRefValue("infoSkillClickButtonUButton")
	self.imgRingRareUWidget = objectReference:GetRefValue("imgRingRareUWidget")
	self.iconRareUWidget = objectReference:GetRefValue("iconRareUWidget")
	self.txtDetailsUSDFText = objectReference:GetRefValue("txtDetailsUSDFText")
	self.tagTypeUWidget = objectReference:GetRefValue("tagTypeUWidget")
	self.txtTypeUSDFText = objectReference:GetRefValue("txtTypeUSDFText")

	ClientTextUtils.setText(self.switchTxtNameUSDFText, pg.getGameString("PETSKILL_UPLV_SWITCH_TITLE"))
	ClientTextUtils.setText(self.txtDetailsUSDFText, pg.getGameString("PETSKILL_DETAIL_TITLE"))

	function self.btnSwitchUButton.luaClick()
		self:onClickSwitchSkillDesc()
	end
end

function PetSkillInfoComponent:onClickSwitchSkillDesc()
	if not self.skillInfoData then
		return
	end

	if not self.skillInfoData.hasGlazePath and not self.skillInfoData.alreadyGlazed then
		return
	end

	if self.recordDescType == UIConst.GlazeSkillPos.After then
		self.recordDescType = UIConst.GlazeSkillPos.Before

		self:refreshSkillDesc(self.skillInfoData)
	else
		self.recordDescType = UIConst.GlazeSkillPos.After

		if not self.enhancedSkillInfoData then
			local enhancedParamId = self.skillInfoData.enhancedSkillId

			self.enhancedSkillInfoData = LuaUIUtils.buildEnhancedSkillInfo(enhancedParamId, self.petInfo.templateId, self.petInfo.petPrototypeId)
		end

		if self.enhancedSkillInfoData then
			self:refreshSkillDesc(self.enhancedSkillInfoData)
		end
	end
end

function PetSkillInfoComponent:refreshSkillDesc(data)
	local skillDesc = LuaUIUtils.getSkillDesc(data, self.petInfo)

	ClientTextUtils.setText(self.longDescScrollRectUScrollRect.content, skillDesc)
end

function PetSkillInfoComponent:renderPetSkillInfo(skillInfoData, petInfo, customData)
	self.skillInfoData = skillInfoData or self.skillInfoData
	self.petInfo = petInfo or petInfo
	self.customData = customData or {}
	self.pos = self.customData and self.customData.pos or UIConst.GlazeSkillPos.Before
	self.recordDescType = UIConst.GlazeSkillPos.Before
	self.enhancedSkillInfoData = nil

	if not self.skillInfoData then
		self.uComponent:SetActive(false)

		return
	end

	self.uComponent:SetActive(true)
	self.uComponent:TryChangePage("IsRare", ToInt(AbilityUtils.isRareAbilityId(self.skillInfoData.abilityId, self.petInfo.templateId)))
	ClientTextUtils.setText(self.txtNameUSDFText, pg.getLocalizationText(self.skillInfoData.name))

	if pg.game.setting:getShowDebugId() then
		ClientTextUtils.setText(self.txtNameUSDFText, self.txtNameUSDFText.text, string.format("%s_%s", self.skillInfoData.abilityId, AbilityUtils.getAbilityParamId(self.skillInfoData.abilityId)))
	end

	self.iconSkillUImage.url = LuaUIUtils.getSkillIcon(self.skillInfoData.icon)

	function self.infoSkillClickButtonUButton.luaClick()
		return
	end

	LuaUIUtils.setRenderSKillTooTip(self.infoSkillClickButtonUButton, self.skillInfoData, nil, self.petInfo)

	if self.skillInfoData.elementType then
		self.elementUButton:SetActive(true)
		LuaUIUtils.setElementButtonNew(self.elementUButton, self.skillInfoData.elementType)
	else
		self.elementUButton:SetActive(false)
	end

	LuaUIUtils.setRenderNewPetSkillAttrsList(self.listAttributeUList, skillInfoData, self.customData.compareSkillInfoData)
	self.uComponent:TryChangePage("Details", 1)

	local txtLongDetailsUBaseText = self.longDescScrollRectUScrollRect.content:GetComponent("UBaseText")
	local skillDesc = LuaUIUtils.getSkillDesc(self.skillInfoData, self.petInfo)

	LuaUIUtils.customRichTextData.petInfo = self.petInfo

	LuaUIUtils.customSetText(txtLongDetailsUBaseText, skillDesc, true, nil)

	LuaUIUtils.customRichTextData.petInfo = nil

	LuaUIUtils.generalRefreshSkillTags(self.tagTypeUWidget, self.listTagUList, self.skillInfoData, self.skillInfoData.tagList)

	if self.customData.showRealGlazeType then
		self.uComponent:TryChangePage("Type", self.pos == UIConst.GlazeSkillPos.After and 2 or 1)

		function self.btnStrengthenUButton.luaClick()
			self:onClickStrengthenBtn()
		end
	else
		self.uComponent:TryChangePage("Type", 0)
	end
end

function PetSkillInfoComponent:onClickStrengthenBtn(favoriteType)
	return
end

return PetSkillInfoComponent
