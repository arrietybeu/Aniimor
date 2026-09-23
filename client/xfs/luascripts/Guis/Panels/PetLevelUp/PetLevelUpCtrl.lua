-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetLevelUp\\PetLevelUpCtrl.lua

local UICtrl = require("Guis.UICtrl")
local TimerManager = require("Core.Timer.TimerManager")
local Const = require("Common.Const.Const")
local Class = require("Core.Framework.Class")
local PetLevelUpCtrl = Class.LightClass("PetLevelUpCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local EventConst = require("Const.EventConst")
local PetData = require("Data.pet_data")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local PetDetailPropertyData = require("Data.pet_detail_property_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetPropLevelMaxData = require("Data.pet_prop_level_max")
local PetManagementUtils = require("Utils.PetManagementUtils")
local PetAttributeCalcUtils = require("Common.Utils.PetAttributeCalcUtils")
local Utils = require("Common.Utils.Utils")

function PetLevelUpCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.pets = pg.me.pets

	self:insertData(info)
end

function PetLevelUpCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:closePanel()
	end
end

function PetLevelUpCtrl:closePanel()
	self:dismiss()
	pg.global.eventEmitter:emit(EventConst.ON_PET_LEVEL_UP_CLOSE_PANEL, {})
end

function PetLevelUpCtrl:insertData(data)
	if not data then
		return
	end

	local petInfo = self.pets[data.petId]

	if petInfo == nil then
		return
	end

	self.propCmpGroup = {
		[Const.BASE_PROPERTY_HP_IDX] = self.view.hpCmp,
		[Const.BASE_PROPERTY_ATK_IDX] = self.view.atkCmp,
		[Const.BASE_PROPERTY_DEF_IDX] = self.view.defCmp,
		[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX] = self.view.regenCmp,
		[Const.BASE_PROPERTY_DEF_MAG_IDX] = self.view.defMagCmp,
		[Const.BASE_PROPERTY_ATK_MAG_IDX] = self.view.atkMagCmp
	}
	self.propLevelCmpGroup = {
		[Const.BASE_PROPERTY_HP_IDX] = self.view.hpLevelCmp,
		[Const.BASE_PROPERTY_ATK_IDX] = self.view.atkLevelCmp,
		[Const.BASE_PROPERTY_DEF_IDX] = self.view.defLevelCmp,
		[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX] = self.view.regenLevelCmp,
		[Const.BASE_PROPERTY_DEF_MAG_IDX] = self.view.defMagLevelCmp,
		[Const.BASE_PROPERTY_ATK_MAG_IDX] = self.view.atkMagLevelCmp
	}
	self.propIdxOriGroup = {
		[Const.BASE_PROPERTY_HP_IDX] = self.view.hpNum,
		[Const.BASE_PROPERTY_ATK_IDX] = self.view.atkNum,
		[Const.BASE_PROPERTY_DEF_IDX] = self.view.defNum,
		[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX] = self.view.regenNum,
		[Const.BASE_PROPERTY_DEF_MAG_IDX] = self.view.defMagNum,
		[Const.BASE_PROPERTY_ATK_MAG_IDX] = self.view.atkMagNum
	}
	self.propIdxAddedGroup = {
		[Const.BASE_PROPERTY_HP_IDX] = self.view.hpValueAdd,
		[Const.BASE_PROPERTY_ATK_IDX] = self.view.atkValueAdd,
		[Const.BASE_PROPERTY_DEF_IDX] = self.view.defValueAdd,
		[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX] = self.view.regenValueAdd,
		[Const.BASE_PROPERTY_DEF_MAG_IDX] = self.view.defMagValueAdd,
		[Const.BASE_PROPERTY_ATK_MAG_IDX] = self.view.atkMagValueAdd
	}
	self.propLevelGroup = {
		[Const.BASE_PROPERTY_HP_IDX] = self.view.hpLv,
		[Const.BASE_PROPERTY_ATK_IDX] = self.view.atkLv,
		[Const.BASE_PROPERTY_DEF_IDX] = self.view.defLv,
		[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX] = self.view.regenLv,
		[Const.BASE_PROPERTY_DEF_MAG_IDX] = self.view.defMagLv,
		[Const.BASE_PROPERTY_ATK_MAG_IDX] = self.view.atkMagLv
	}

	self:setTotalAttribute(petInfo, data.oldProp)
	ClientTextUtils.setText(self.view.txtTitleUText, pg.getLocalizationText(self.model:getPetName(petInfo.id)))

	self.view.imgPetUImage.url = self.model:getPetIcon(petInfo.id)

	ClientTextUtils.setText(self.view.txtLevelUText, data.newLevel)

	for k, v in pairs(data.oldProp) do
		ClientTextUtils.setText(self.propIdxOriGroup[k], math.floor(v.total or 0))
	end

	local upTipsActive = data and data.ivUpNoticeText or false

	if upTipsActive then
		ClientTextUtils.setText(self.view.textUSDFText, data.ivUpNoticeText)
	end

	if NotNil(self.view.upTipsUWidget) then
		self.view.upTipsUWidget.gameObject:SetActiveEx(upTipsActive)
	end
end

function PetLevelUpCtrl:setTotalAttribute(petInfo, oldProp)
	if petInfo == nil then
		return
	end

	local baseProperty = petInfo.basePropertyList
	local propertyEnhanced = Utils.isPetPropertyEnhanced(petInfo)
	local attributeMap = PetAttributeCalcUtils.getAttributeMapByPetInfo(pg.me, petInfo)
	local templateId = petInfo.templateId
	local petData = PetData[templateId]
	local recommend = petData.recommend_attr
	local propLevels = pg.game.petManage:getPetPropLevels(petInfo)

	self.defaultRatioGroup = {}
	self.addedRatioGroup = {}

	local isTrained = 0

	for i = Const.BASE_PROPERTY_HP_IDX, Const.BASE_PROPERTY_ATK_MAG_IDX do
		local curValue = attributeMap[PetManagementDataHelper.CUR_PROP[i]] or 0

		if oldProp[i].total ~= curValue then
			self.propCmpGroup[i]:TryChangePage("Add", 1)
			self.propIdxAddedGroup[i]:SetText(math.floor(oldProp[i].total))
			self.propIdxAddedGroup[i]:SetEndNumber(math.floor(curValue))
			self.propIdxAddedGroup[i]:StartBeat()
		else
			self.propCmpGroup[i]:TryChangePage("Add", 0)
		end

		ClientTextUtils.setText(self.propLevelGroup[i], baseProperty[i].indLv)

		self.propCmpGroup[i].luaTooltipPopup = function(_, flag)
			self.propCmpGroup[i]:TryChangePage("Selected", flag and 1 or 0)
		end
		self.propCmpGroup[i].luaRenderTooltip = function(_, component)
			PetManagementUtils.customRefreshBuffInfoTooltip(component, PetManagementDataHelper.BuffInfoToolTipType.Cultivate, {
				index = i,
				recommend = recommend,
				propertyEnhanced = propertyEnhanced,
				propLevel = propLevels[i]
			})
		end

		if baseProperty[i].iLvLn > 0 then
			self.propCmpGroup[i]:TryChangePage("State", 1)
			self.propLevelCmpGroup[i]:TryChangePage("State", 1)
		else
			self.propCmpGroup[i]:TryChangePage("State", 0)
			self.propLevelCmpGroup[i]:TryChangePage("State", 0)
		end

		local goodStatePage = LuaUIUtils.tableContains(recommend, i) and 1 or 0
		local updatedPage = propertyEnhanced and 1 or 0

		self.propCmpGroup[i]:TryChangePage("GoodState", goodStatePage)
		self.propLevelCmpGroup[i]:TryChangePage("Updated", updatedPage)

		if updatedPage == 1 then
			self.propLevelCmpGroup[i]:TryChangePage("State", 1)
		end

		if baseProperty[i].indLv >= PetPropLevelMaxData[i] then
			self.propCmpGroup[i]:TryChangePage("State", 2)
			self.propLevelCmpGroup[i]:TryChangePage("State", 2)
		end

		self.defaultRatioGroup[i] = (baseProperty[i].indLv - baseProperty[i].iLvLn) / PetPropLevelMaxData[i]
		self.addedRatioGroup[i] = baseProperty[i].indLv / PetPropLevelMaxData[i]

		if baseProperty[i].iLvLn and baseProperty[i].iLvLn > 0 then
			isTrained = isTrained + 1
		end
	end

	self.view.defaultRadar:SetSixProps(self.defaultRatioGroup[Const.BASE_PROPERTY_HP_IDX], self.defaultRatioGroup[Const.BASE_PROPERTY_ATK_IDX], self.defaultRatioGroup[Const.BASE_PROPERTY_DEF_IDX], self.defaultRatioGroup[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX], self.defaultRatioGroup[Const.BASE_PROPERTY_DEF_MAG_IDX], self.defaultRatioGroup[Const.BASE_PROPERTY_ATK_MAG_IDX])
	self.view.addedRadar:SetSixProps(self.addedRatioGroup[Const.BASE_PROPERTY_HP_IDX], self.addedRatioGroup[Const.BASE_PROPERTY_ATK_IDX], self.addedRatioGroup[Const.BASE_PROPERTY_DEF_IDX], self.addedRatioGroup[Const.BASE_PROPERTY_EP_REGEN_FORCE_IDX], self.addedRatioGroup[Const.BASE_PROPERTY_DEF_MAG_IDX], self.addedRatioGroup[Const.BASE_PROPERTY_ATK_MAG_IDX])
	self.view.addedRadar.transform.gameObject:SetActiveEx(isTrained > 0)
end

return PetLevelUpCtrl
