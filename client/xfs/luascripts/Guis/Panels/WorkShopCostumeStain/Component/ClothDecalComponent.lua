-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\WorkShopCostumeStain\\Component\\ClothDecalComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local SliderBubbleComponent = require("Guis.Panels.AppearanceV2.Component.Common.SliderBubbleComponent")
local ClothDecalComponent = Class.LightClass("ClothDecalComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")

ClothDecalComponent.Operation = {
	operations = {
		{
			opName = 1,
			minValue = -0.1,
			maxValue = 0.1,
			displayName = "左右移动",
			tIndex = 0,
			stepSize = 0,
			defaultValue = 0
		},
		{
			opName = 2,
			minValue = -0.25,
			maxValue = 0.25,
			displayName = "上下移动",
			tIndex = 0,
			stepSize = 0,
			defaultValue = 0
		},
		{
			opName = 3,
			minValue = -0.1,
			maxValue = 0.1,
			displayName = "前后移动",
			tIndex = 0,
			stepSize = 0,
			defaultValue = 0
		},
		{
			opName = 4,
			minValue = -180,
			maxValue = 180,
			displayName = "上下旋转",
			tIndex = 0,
			stepSize = 1,
			defaultValue = 0
		},
		{
			opName = 5,
			minValue = -180,
			maxValue = 180,
			displayName = "左右旋转",
			tIndex = 0,
			stepSize = 1,
			defaultValue = 90
		},
		{
			opName = 6,
			minValue = 0.1,
			maxValue = 10,
			displayName = "缩放",
			tIndex = 0,
			stepSize = 0.1,
			defaultValue = 1
		}
	}
}

function ClothDecalComponent:findObjects()
	return
end

function ClothDecalComponent:initView()
	function self.view.operationUList.luaRenderItem(button, _, data)
		self:onRenderOperationItem(button, data)
	end

	function self.view.decalSelectUList.luaRenderItem(button, _, data)
		self:onRenderDecalItem(button, data)
	end

	function self.view.decalSelectUList.luaSelectedChanged(uList)
		local selectedItem = uList.selectedItem

		if not selectedItem then
			self.view.rightPanelUComponent:TryChangePage("AppliqueChoose", "No")

			return
		end

		self.view.rightPanelUComponent:TryChangePage("AppliqueChoose", "Yes")
		self.view.applyUButton:SetActiveFastest(not selectedItem.equip)
		self.view.deleteUButton:SetActiveFastest(selectedItem.equip)
	end

	function self.view.applyUButton.luaClick()
		if not self.model:checkCanAddDecal(self.ctrl.selectAreaIdx) then
			pg.global.showBubbleMessageRaw("贴花已达上限", 2)

			return
		end

		local data = self.view.decalSelectUList.selectedItem

		data.equip = true

		self.model:setDecalTexIdx(self.ctrl.selectAreaIdx, data.index, self:getDefaultValue())
		self.view.decalSelectUList:RefreshList()
		self.view.applyUButton:SetActiveFastest(not data.equip)
		self.view.deleteUButton:SetActiveFastest(data.equip)
	end

	function self.view.deleteUButton.luaClick()
		local data = self.view.decalSelectUList.selectedItem

		data.equip = false

		self.model:unsetDecalTexIdx(self.ctrl.selectAreaIdx, data.index)
		self.view.decalSelectUList:RefreshList()
		self.view.applyUButton:SetActiveFastest(not data.equip)
		self.view.deleteUButton:SetActiveFastest(data.equip)
	end

	function self.view.editUButton.luaClick()
		local data = self.view.decalSelectUList.selectedItem

		data.equip = true

		self.model:setDecalTexIdx(self.ctrl.selectAreaIdx, data.index, self:getDefaultValue())
		self.view.decalSelectUList:RefreshList()
		self.view.applyUButton:SetActiveFastest(not data.equip)
		self.view.deleteUButton:SetActiveFastest(data.equip)
		self.view.rightPanelUComponent:TryChangePage("Info", "AppliqueEdit")
		self.view.operationUList:SetList(self.Operation.operations)
	end

	function self.view.closeUButton.luaClick()
		self.view.rightPanelUComponent:TryChangePage("Info", "Applique")
		self.view.btnApply:SetActiveFastest(true)
	end

	function self.view.conformUButton.luaClick()
		self.view.rightPanelUComponent:TryChangePage("Info", "Applique")
		self.view.btnApply:SetActiveFastest(true)
	end
end

function ClothDecalComponent:getDefaultValue()
	return {
		position = {
			0,
			0,
			0,
			0
		},
		rotation = {
			0,
			90,
			0,
			0
		}
	}
end

function ClothDecalComponent:selectDefaultDecalTab()
	local maskDataList = self.model:getMaskDataList(1)

	self.view.decalSelectUList:SetList(maskDataList)
end

function ClothDecalComponent:onRenderDecalItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")

	button:TryChangePage("IsWear", data.equip and 1 or 0)

	iconUImage.url = data.res
end

function ClothDecalComponent:onRenderOperationItem(button, data)
	if data.tIndex == 0 then
		self:onRenderSliderItem(button, data)
	end
end

function ClothDecalComponent:onRenderSliderItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local nameUText = objectReference:GetRefValue("nameUText")
	local sliderUSlider = objectReference:GetRefValue("sliderUSlider")
	local rootUComponent = objectReference:GetRefValue("rootUComponent")

	if data.displayName then
		ClientTextUtils.setText(nameUText, pg.getLocalizationText(data.displayName))
		rootUComponent:TryChangePage("title", "show")
	else
		rootUComponent:TryChangePage("title", "hide")
	end

	function sliderUSlider.luaValueChanged(v)
		self:onSliderValueChanged(data, v)
	end

	sliderUSlider:SetMinWithoutNotify(data.minValue)
	sliderUSlider:SetMaxWithoutNotify(data.maxValue)
	sliderUSlider:SetStepSizeWithoutNotify(data.stepSize)

	local item = self.view.decalSelectUList.selectedItem

	sliderUSlider.value = self.model:getDecalWithOpName(self.ctrl.selectAreaIdx, item.index, data.defaultValue, data.opName)
end

function ClothDecalComponent:onSliderValueChanged(data, newValue)
	local item = self.view.decalSelectUList.selectedItem

	self.model:setDecalWithOpName(self.ctrl.selectAreaIdx, item.index, -newValue, data.opName)
end

function ClothDecalComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return ClothDecalComponent
