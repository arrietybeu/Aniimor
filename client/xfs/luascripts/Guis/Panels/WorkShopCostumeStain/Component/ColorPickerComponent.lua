-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\WorkShopCostumeStain\\Component\\ColorPickerComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local SliderBubbleComponent = require("Guis.Panels.AppearanceV2.Component.Common.SliderBubbleComponent")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local ColorPickerComponent = Class.LightClass("WorkShopCostumeStainGamePadComponent", UIComponent)
local lume = require("Core.Common.lume")
local TimerManager = require("Core.Timer.TimerManager")

function ColorPickerComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.colorUColorPicker = self.objectReference:GetRefValue("colorUColorPicker")
	self.backUButton = self.objectReference:GetRefValue("backUButton")
	self.resetUButton = self.objectReference:GetRefValue("resetUButton")
	self.handleUImage = self.objectReference:GetRefValue("handleUImage")
	self.btnGradientL = self.objectReference:GetRefValue("btnGradientL")
	self.btnGradientR = self.objectReference:GetRefValue("btnGradientR")
	self.gradientUButton = self.objectReference:GetRefValue("gradientUButton")
	self.bubbleUComponent = self.objectReference:GetRefValue("bubbleUComponent")
	self.rGBRectU2DSlider = self.objectReference:GetRefValue("rGBRectU2DSlider")
	self.btnDesaturateUButton = self.objectReference:GetRefValue("btnDesaturateUButton")
	self.component = self.transform:GetComponent("UComponent")
	self.onPress = false
end

function ColorPickerComponent:mergeGroupSupportsGradient()
	return self.ctrl.selectMergeGroup ~= nil and self.ctrl.selectMergeGroup.hasNormal == true and self.ctrl.selectMergeGroup.enableGradient == true
end

function ColorPickerComponent:shouldHideGradientUi()
	if self:mergeGroupSupportsGradient() then
		return false
	end

	return self.ctrl.selectMergeGroup ~= nil or self.ctrl.selectSecondUV ~= nil or self.ctrl.selectSimpleDye ~= nil
end

function ColorPickerComponent:refreshGradientBtnOpacity()
	if self.gradientUButton == nil then
		return
	end

	self.gradientUButton.renderOpacity = self:shouldHideGradientUi() and 0 or 1
end

function ColorPickerComponent:initView()
	function self.colorUColorPicker.luaValueChanged(colorCode)
		self:onColorChanged(colorCode)

		if self.showTimer then
			TimerManager.removeTimer(self.showTimer)
		end

		if not self.onPress then
			self.showTimer = TimerManager.addTimer(0.75, function()
				if not self.onPress then
					-- block empty
				end
			end)
		end
	end

	function self.colorUColorPicker.luaOnRelease()
		self.onPress = false
	end

	function self.colorUColorPicker.luaOnPress()
		self.onPress = true
	end

	function self.backUButton.luaClick()
		return
	end

	function self.resetUButton.luaClick()
		self:resetCsColorPick()
	end

	function self.btnGradientL.luaClick()
		if self:shouldHideGradientUi() then
			return
		end

		self.isGradient = false

		self:resetColorPick()
	end

	function self.btnGradientR.luaClick()
		if self:shouldHideGradientUi() then
			return
		end

		self.isGradient = true

		self:resetColorPick()
	end

	if self.btnDesaturateUButton ~= nil then
		self.btnDesaturateUButton.gameObject:SetActiveEx(false)
	end
end

function ColorPickerComponent:switchSelectState()
	if self.isGradient then
		self.btnGradientL:TryChangePage("GamePadFocus", 0)
		self.btnGradientR:TryChangePage("GamePadFocus", 1)
	else
		self.btnGradientL:TryChangePage("GamePadFocus", 1)
		self.btnGradientR:TryChangePage("GamePadFocus", 0)
	end
end

function ColorPickerComponent:onShow()
	self.component:TryChangePage("HaveGradient", 1)
	self.bubbleUComponent:SetActive(false)

	local colorAreas = AvatarUtils.getColorAreas(AvatarUtils.COLOR_PANEL.CLOTH_NORMAL_COLOR) or {
		0,
		1,
		0,
		1
	}

	self.rGBRectU2DSlider:SetMinMaxValue(colorAreas[1], colorAreas[2], colorAreas[3], colorAreas[4])
	self:refreshGradientBtnOpacity()
end

function ColorPickerComponent:selectDefaultColorTab()
	self:refreshGradientBtnOpacity()

	if self:mergeGroupSupportsGradient() then
		self.btnGradientL:OnClickSimulate()

		return
	end

	if self.ctrl.selectMergeGroup or self.ctrl.selectSimpleDye or self.ctrl.selectSecondUV then
		self.isGradient = false

		self.component:TryChangePage("HaveGradient", 1)
		self:resetColorPick()

		return
	end

	self.btnGradientL:OnClickSimulate()
end

function ColorPickerComponent:resetCsColorPick()
	local color

	if self.ctrl.selectMergeGroup then
		color = self.model:getMergeGroupOriginColor(self.ctrl.selectMergeGroup.groupIndex, self.ctrl.selectMergeGroup.members, self.isGradient)
	elseif self.ctrl.selectSimpleDye then
		color = self.model:getSimpleDyeOriginColor(self.ctrl.selectSimpleDye.matName)
	elseif self.ctrl.selectSecondUV then
		local s = self.ctrl.selectSecondUV

		color = self.model:getSecondUVDyeOriginColor(s.matName, s.partIndex)
	else
		color = self.model:getOriginColor(self.ctrl.selectAreaIdx, self.isGradient)
	end

	self.colorUColorPicker:SetColorWithoutNotify(color)
	self:applyColorChange(color)
	self:setColorPack(color)
	self:setTabBtnColor(0)
end

function ColorPickerComponent:applyColorChange(color)
	if self.ctrl.selectMergeGroup then
		self.model:applyMergeGroupColors(self.ctrl.selectMergeGroup.members, color, self.isGradient, self.ctrl.selectMergeGroup.enableGradient == true)

		return
	end

	if self.ctrl.selectSimpleDye then
		self.model:setSimpleDyeColor(self.ctrl.selectSimpleDye.matName, color)

		return
	end

	if self.ctrl.selectSecondUV then
		local s = self.ctrl.selectSecondUV

		self.model:setSecondUVDyeColor(s.matName, s.partIndex, color)

		return
	end

	self.model:setMatAreaColor(self.ctrl.selectAreaIdx or 1, color, self.isGradient)
end

function ColorPickerComponent:onColorChanged(colorCode)
	local r, g, b, a = lume.color(colorCode)
	local color = Color(r, g, b, a)

	self:applyColorChange(color)
	self:setColorPack(color)
end

function ColorPickerComponent:resetColorPick()
	local color

	if self.ctrl.selectMergeGroup then
		color = self.model:getMergeGroupColor(self.ctrl.selectMergeGroup.groupIndex, self.ctrl.selectMergeGroup.members, self.isGradient)
	elseif self.ctrl.selectSimpleDye then
		color = self.model:getSimpleDyeColor(self.ctrl.selectSimpleDye.matName)
	elseif self.ctrl.selectSecondUV then
		local s = self.ctrl.selectSecondUV

		color = self.model:getSecondUVDyeColor(s.matName, s.partIndex)
	else
		color = self.model:getMatColor(self.ctrl.selectAreaIdx, self.isGradient)
	end

	self.colorUColorPicker:SetColorWithoutNotify(color)
	self:setColorPack(color)
	self:setTabBtnColor(0)
	self:switchSelectState()
end

function ColorPickerComponent:setColorPack(color)
	self.handleUImage.color = color

	self:setTabBtnColor(self.isGradient and 2 or 1)
	self.ctrl:refreshConsume()
end

function ColorPickerComponent:setTabBtnColor(tab)
	if self.ctrl.selectMergeGroup then
		if self:mergeGroupSupportsGradient() then
			local firstNormal = self.model:getFirstNormalMember(self.ctrl.selectMergeGroup.members)

			if firstNormal then
				if tab == 0 or tab == 1 then
					local color = self.model:getMatColor(firstNormal.areaIndex, false)

					self.btnGradientL.transform:Find("Color"):GetComponent("UImage").color = color
				end

				if tab == 0 or tab == 2 then
					local color = self.model:getMatColor(firstNormal.areaIndex, true)

					self.btnGradientR.transform:Find("Color"):GetComponent("UImage").color = color
				end

				return
			end
		end

		local color = self.model:getMergeGroupColor(self.ctrl.selectMergeGroup.groupIndex, self.ctrl.selectMergeGroup.members, false)

		self.btnGradientL.transform:Find("Color"):GetComponent("UImage").color = color
		self.btnGradientR.transform:Find("Color"):GetComponent("UImage").color = color

		return
	end

	if self.ctrl.selectSimpleDye then
		local color = self.model:getSimpleDyeColor(self.ctrl.selectSimpleDye.matName)

		self.btnGradientL.transform:Find("Color"):GetComponent("UImage").color = color
		self.btnGradientR.transform:Find("Color"):GetComponent("UImage").color = color

		return
	end

	if self.ctrl.selectSecondUV then
		local s = self.ctrl.selectSecondUV
		local color = self.model:getSecondUVDyeColor(s.matName, s.partIndex)

		self.btnGradientL.transform:Find("Color"):GetComponent("UImage").color = color
		self.btnGradientR.transform:Find("Color"):GetComponent("UImage").color = color

		return
	end

	if tab == 0 or tab == 1 then
		local color = self.model:getMatColor(self.ctrl.selectAreaIdx, false)
		local image = self.btnGradientL.transform:Find("Color"):GetComponent("UImage")

		image.color = color
	end

	if tab == 0 or tab == 2 then
		local color = self.model:getMatColor(self.ctrl.selectAreaIdx, true)
		local image = self.btnGradientR.transform:Find("Color"):GetComponent("UImage")

		image.color = color
	end
end

function ColorPickerComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return ColorPickerComponent
