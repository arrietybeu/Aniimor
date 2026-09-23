-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetVariantResult\\PetVariantResultCtrl.lua

local Const = require("Common.Const.Const")
local Lume = require("Core.Common.lume")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PetData = require("Data.pet_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local PetVariantResultCtrl = Class.LightClass("PetVariantResultCtrl", UICtrl)

function PetVariantResultCtrl:addListener()
	UICtrl.addListener(self)

	function self.view.btnCloseUButton.luaClick()
		self:close()
	end
end

function PetVariantResultCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:_refreshPetInfo(info)
end

function PetVariantResultCtrl:_refreshPetInfo(info)
	local petInfo = info.petInfo
	local petData = PetData[petInfo.templateId]
	local petName = petInfo.customName

	if string.isNilOrEmpty(petName) then
		petName = pg.getLocalizationText(petData.name)
	end

	ClientTextUtils.setText(self.view.variantNameUBaseText, petName)
	ClientTextUtils.setText(self.view.variantNameCoverUBaseText, petName)
	ClientTextUtils.setText(self.view.txtLevelUText, petInfo.level)
	self.view.upTipsUWidget.gameObject:SetActiveEx(false)

	local iconUrl = LuaUIUtils.getPetIcon(petData.iconName, LuaUIUtils.PET_ICON, petInfo.label, petInfo.gender)

	self.view.imgPetUImage.url = iconUrl

	self:_refreshProperties(petInfo, info.propListBeforeVariant)
end

function PetVariantResultCtrl:_refreshProperties(petInfo, beforeProperties)
	local individualPropUpMap, individualLevelUpMap = self:_generateAttributeUpMaps(petInfo, beforeProperties)

	PetManagementUtils.renderPetAttributeInner(petInfo, self.view.petAttributeRef, individualPropUpMap, individualLevelUpMap, {
		usePetManagementDisplayValue = true
	})
end

function PetVariantResultCtrl:_generateAttributeUpMaps(petInfo, beforeProperties)
	if not beforeProperties then
		return nil, nil
	end

	local beforePetInfo = self:_createBeforePetInfo(petInfo, beforeProperties)
	local beforePropLevels = pg.game.petManage:getPetPropLevels(beforePetInfo)
	local afterPropLevels = pg.game.petManage:getPetPropLevels(petInfo)
	local individualPropUpMap = {}
	local individualLevelUpMap = {}

	for index = Const.BASE_PROPERTY_HP_IDX, Const.BASE_PROPERTY_ATK_MAG_IDX do
		local beforePropLevel = beforePropLevels[index]
		local afterPropLevel = afterPropLevels[index]
		local propUp = math.ceil(afterPropLevel.propDisplayVal) - math.ceil(beforePropLevel.propDisplayVal)
		local levelUp = afterPropLevel.baseAndActiveTotalLv - beforePropLevel.baseAndActiveTotalLv

		if propUp ~= 0 then
			individualPropUpMap[index] = propUp
		end

		if levelUp ~= 0 then
			individualLevelUpMap[index] = levelUp
		end
	end

	return individualPropUpMap, individualLevelUpMap
end

function PetVariantResultCtrl:_createBeforePetInfo(petInfo, beforeProperties)
	return Lume.merge(petInfo, {
		calculatedAttributeMap = false,
		basePropertyList = beforeProperties
	})
end

return PetVariantResultCtrl
