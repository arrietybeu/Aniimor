-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityResultPop\\PetFertilityResultPopCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local ItemData = require("Data.item_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetFertilityResultPopCtrl = Class.LightClass("PetFertilityResultPopCtrl", UICtrl)

PetFertilityResultPopCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function PetFertilityResultPopCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:Init()
end

function PetFertilityResultPopCtrl:onShow()
	return
end

function PetFertilityResultPopCtrl:onHide()
	return
end

function PetFertilityResultPopCtrl:onDestroy()
	self:destroy()
	UICtrl.onDestroy(self)
end

function PetFertilityResultPopCtrl:Init()
	self.eggInfo = pg.game.petBall.eggInfo

	if not self.eggInfo then
		return
	end

	self.view.fuyuEggUImage.url = ItemData[self.eggInfo.itemId].icon

	ClientTextUtils.setText(self.view.eggName, string.format("%s%s", self.eggInfo.eggName, pg.getLocalizationText(ItemData[self.eggInfo.itemId].itemName)))
	self.view.panelEggUComponent:TryChangePage("Flash", self.eggInfo.isShiny and 0 or 1)
	self.view.uIPopPetFertilityResultUComponent:TryChangePage("Flash", self.eggInfo.isShiny and 1 or 0)

	local isDoubleEggs = self.eggInfo.isDoubleEggs

	self.view.uIPopPetFertilityResultUComponent:TryChangePage("Double", isDoubleEggs and 1 or 0)

	if self.eggInfo.featureId then
		local featureInfo = self.model:getFeatrueInfo(self.eggInfo.featureId)

		if featureInfo then
			self.view.passionUComponent.gameObject:SetActiveEx(true)
			ClientTextUtils.setText(self.view.featureName, pg.getLocalizationText(featureInfo.name))
			ClientTextUtils.setText(self.view.featureDesc.content, pg.getLocalizationText(featureInfo.desc))

			self.view.iconUImage.url = featureInfo.icon

			self.view.passionUComponent:TryChangePage("isS", featureInfo.rare)
		else
			self.view.passionUComponent.gameObject:SetActiveEx(false)
		end
	else
		self.view.passionUComponent.gameObject:SetActiveEx(false)
	end

	function self.view.listGiftUList.luaRenderItem(button, index, data)
		self:renderTalentItem(button, index, data)
	end

	self.view.listGiftUList:SetList(self.eggInfo.talent)
end

function PetFertilityResultPopCtrl:renderTalentItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")
	local root = objectReference:GetRefValue("root")
	local uINodePetFertilityGiftCellAnimation = objectReference:GetRefValue("uINodePetFertilityGiftCellAnimation")
	local starGlowTransform = objectReference:GetRefValue("starGlowTransform")

	iconUImage.url = data.icon

	ClientTextUtils.setText(txtNameUText, pg.getLocalizationText(data.name))

	if data.quality >= 2 then
		root:TryChangePage("Quality", 3)
	else
		root:TryChangePage("Quality", data.quality)
	end

	root:TryChangePage("Selected", 0)

	if data.quality >= 2 then
		uINodePetFertilityGiftCellAnimation:Play("VX_Pb_PetFertility_GiftCell_Bar_In")
		starGlowTransform.gameObject:SetActiveEx(true)
	end

	function button.luaClick()
		pg.global.ui:open(UIConst.UI_ID_COMMON_CUSTOM_INFO_TIP, {
			autoHor = true,
			targetRect = button,
			icon = data.icon,
			name = data.name,
			desc = data.desc
		})
	end
end

function PetFertilityResultPopCtrl:destroy()
	pg.game.petBall.eggInfo = nil
end

function PetFertilityResultPopCtrl:addListener()
	function self.view.btnConfirmUButton.luaClick()
		self:goHatch()
	end

	function self.view.btnCancelUButton.luaClick()
		self:onConfirmEggClick()
	end
end

function PetFertilityResultPopCtrl:onConfirmEggClick()
	if pg.global.ui:checkUIShow(UIConst.UI_ID_PET_FERTILITY_RESULT) and pg.global.ui.petFertilityResult then
		pg.global.ui.petFertilityResult:closePanel()
	end

	self:closePanel()
end

function PetFertilityResultPopCtrl:goHatch()
	if pg.global.ui:checkUIShow(UIConst.UI_ID_PET_FERTILITY_RESULT) and pg.global.ui.petFertilityResult then
		pg.global.ui.petFertilityResult:closePanel()
	end

	self:closePanel()

	if pg.global.ui:checkUIShow(UIConst.UI_ID_PET_FERTILITY) then
		pg.global.ui.petFertility:onHatchNaviBarClick()
		pg.global.ui.petFertility.view.root:TryChangePage("TabState", 2)
	end
end

function PetFertilityResultPopCtrl:closePanel()
	pg.global.ui:close(UIConst.UI_ID_PET_FERTILITY_RESULT_POP)

	if pg.global.ui.petFertility then
		pg.global.ui.petFertility.view.root:TryChangePage("hideAll", 0)
	end
end

return PetFertilityResultPopCtrl
