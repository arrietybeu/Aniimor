-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityHatchResult\\PetFertilityHatchResultCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetFertilityHatchResultCtrl = Class.LightClass("PetFertilityHatchResultCtrl", UICtrl)

PetFertilityHatchResultCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function PetFertilityHatchResultCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:Init(info)
end

function PetFertilityHatchResultCtrl:onOpen(info)
	return
end

function PetFertilityHatchResultCtrl:onShow()
	return
end

function PetFertilityHatchResultCtrl:onHide()
	return
end

function PetFertilityHatchResultCtrl:onDestroy()
	self:destroy()
	UICtrl.onDestroy(self)
end

function PetFertilityHatchResultCtrl:Init(info)
	self.petInfo = info.petInfo
	self.closeCallback = info.closeCallback

	self:showInfo()
end

function PetFertilityHatchResultCtrl:destroy()
	return
end

function PetFertilityHatchResultCtrl:addListener()
	function self.view.btnCancelUButton.luaClick()
		self:onCancelBtnClick()
	end

	function self.view.btnConfirmUButton.luaClick()
		self:onConfirmBtnClick()
	end
end

function PetFertilityHatchResultCtrl:closePanel()
	pg.global.ui:close(UIConst.UI_ID_PET_FERTILITY_HATCH_RESULT)
end

function PetFertilityHatchResultCtrl:onCancelBtnClick()
	if self.closeCallback then
		self.closeCallback()
	end

	self:closePanel()
	pg.game.uiScene:setMainSceneActive(false)
end

function PetFertilityHatchResultCtrl:onConfirmBtnClick()
	pg.global.ui:open(UIConst.UI_ID_PET_MANAGEMENT, nil, function()
		if pg.global.ui:checkUIShow(UIConst.UI_ID_PET_FERTILITY) then
			pg.global.ui.petFertility:closePanel()
		end

		if self.closeCallback then
			self.closeCallback()
		end

		self:closePanel()
	end)
end

function PetFertilityHatchResultCtrl:showInfo()
	local petInfo = self.model:setUpPetInfo(self.petInfo)

	ClientTextUtils.setText(self.view.name, self.model:getPetName(petInfo.id))

	if petInfo.gender == Const.GENDER_TYPE_MALE then
		self.view.leftPanel:TryChangePage("Gender", 0)
	elseif petInfo.gender == Const.GENDER_TYPE_FEMALE then
		self.view.leftPanel:TryChangePage("Gender", 1)
	else
		self.view.leftPanel:TryChangePage("Gender", 2)
	end

	function self.view.elementList.luaRenderItem(button, _, data1)
		LuaUIUtils.setElementButtonNew(button, data1.element)
	end

	self.view.elementList:SetList(petInfo.elementNames)

	self.view.level = petInfo.level

	if petInfo.featureInfo then
		self.view.passionUComponent.gameObject:SetActiveEx(true)
		self.view.passionUComponent:TryChangePage("isS", petInfo.featureInfo.rare or 0)
		ClientTextUtils.setText(self.view.featureDesc.content, petInfo.featureInfo.desc)
		ClientTextUtils.setText(self.view.featureName, petInfo.featureInfo.name)

		self.view.featureIcon.url = petInfo.featureInfo.icon
	else
		self.view.passionUComponent.gameObject:SetActiveEx(false)
	end

	function self.view.listGiftUList.luaRenderItem(button, _, data1)
		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local txtNameUText = objectReference:GetRefValue("txtNameUText")
		local root = objectReference:GetRefValue("root")

		iconUImage.url = data1.icon

		ClientTextUtils.setText(txtNameUText, data1.name)
		root:TryChangePage("Quality", data1.quality)
		root:TryChangePage("Selected", 0)

		function button.luaClick()
			pg.global.ui:open(UIConst.UI_ID_COMMON_CUSTOM_INFO_TIP, {
				autoHor = true,
				targetRect = button,
				icon = data1.icon,
				name = data1.name,
				desc = data1.desc
			})
		end
	end

	self.view.listGiftUList:SetList(petInfo.breedTalent)

	function self.view.propList.luaRenderItem(button, _, data1)
		local objectReference = button:GetComponent("ObjectReference")
		local titleUSDFText = objectReference:GetRefValue("titleUSDFText")
		local numUSDFText = objectReference:GetRefValue("numUSDFText")

		ClientTextUtils.setText(titleUSDFText, data1.title)
		ClientTextUtils.setText(numUSDFText, data1.value)
	end

	self.view.propList:SetList(petInfo.props)
end

return PetFertilityHatchResultCtrl
