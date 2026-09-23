-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotoLightDiy\\PhotoLightDiyCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local lume = require("Core.Common.lume")
local PhotoLightDiyCtrl = Class.LightClass("PhotoLightDiyCtrl", UICtrl)
local UnityColor = CS.UnityEngine.Color

PhotoLightDiyCtrl.messages = {}

function PhotoLightDiyCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	info = info or {}
	self.slot = tonumber(info.slot) or 1

	local scheme = info.scheme

	if not scheme and pg.me then
		scheme = pg.me:getPhotoLightScheme(self.slot)
	end

	self.scheme = self.model:normalizeScheme(self.slot, scheme)
	self.currentLightIndex = 1
	self.cameraMode = info.cameraMode
	self.photoHostCtrl = info.photoHostCtrl
	self.applySchemeCallback = info.applySchemeCallback
	self.saveSchemeCallback = info.saveSchemeCallback

	self:refreshView()
	self:attachLightButtons()

	if self.photoHostCtrl then
		self.photoHostCtrl:setPhotoLightDiyUIHidden(true)
	end
end

function PhotoLightDiyCtrl:checkUILockCursor()
	if self.photoHostCtrl then
		return self.photoHostCtrl:checkUILockCursor()
	end

	return PhotoLightDiyCtrl.super.checkUILockCursor(self)
end

function PhotoLightDiyCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:closePanel()
	end

	function self.view.btnRenameUButton.luaClick()
		self:openRenamePopup()
	end

	function self.view.listTab3thUList.luaRenderItem(button, _, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

		ClientTextUtils.setText(txtNameUBaseText, string.format(pg.getGameString(data.label), data.lightIndex))
	end

	function self.view.listTab3thUList.luaSelectedChanged(list, isSelected)
		if not isSelected then
			return
		end

		local data = list.selectedItem

		if data then
			self.currentLightIndex = data.lightIndex

			for index, lightBtn in ipairs(self.lightButtons) do
				lightBtn.isSelected = index == self.currentLightIndex
			end

			self:refreshParamList()
		end
	end

	function self.view.listUList.luaRenderItem(button, _, data)
		if data.paramType == self.model.ParamType.Switch then
			self:renderSwitchItem(button, data)
		elseif data.paramType == self.model.ParamType.Slider then
			self:renderSliderItem(button, data)
		elseif data.paramType == self.model.ParamType.Color then
			self:renderColorItem(button, data)
		end
	end

	self.lightButtons = {
		self.view.light1UButton,
		self.view.light2UButton,
		self.view.light3UButton
	}
	self.lightButtonFollows = {}

	for lightIndex, button in ipairs(self.lightButtons) do
		local index = lightIndex
		local objectReference = button:GetComponent("ObjectReference")
		local textIndexUBaseText = objectReference:GetRefValue("textIndexUBaseText")
		local uSimplePosFollow = objectReference:GetRefValue("uSimplePosFollow")

		ClientTextUtils.setText(textIndexUBaseText, tostring(index))

		self.lightButtonFollows[index] = uSimplePosFollow

		function button.luaClick()
			self.view.listTab3thUList:SelectItem(index - 1)
		end
	end
end

function PhotoLightDiyCtrl:refreshView()
	self:refreshName()
	self.view.listTab3thUList:SetList(self.model.LightTabs)
	self.view.listTab3thUList:SelectItem(self.currentLightIndex - 1)
	self:refreshParamList()
	self:notifySchemeChanged()
end

function PhotoLightDiyCtrl:refreshName()
	ClientTextUtils.setText(self.view.textNameUBaseText, self.scheme.name)
end

function PhotoLightDiyCtrl:refreshParamList()
	self.view.listUList:SetList(self.model.ParamList)
end

function PhotoLightDiyCtrl:renderSwitchItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textTitleUBaseText = objectReference:GetRefValue("textTitleUBaseText")
	local selectorUSelector = objectReference:GetRefValue("selectorUSelector")
	local lightData = self.scheme.lights[self.currentLightIndex]

	ClientTextUtils.setText(textTitleUBaseText, pg.getGameString(data.label))

	local options = {}

	for index, option in ipairs(self.model.SwitchOptions) do
		options[index] = {
			enabled = option.enabled,
			label = pg.getGameString(option.label)
		}
	end

	selectorUSelector.luaSelectedChanged = nil

	selectorUSelector:SetOptions(options)
	selectorUSelector:ForceSelect(lightData.enabled and 0 or 1)

	function selectorUSelector.luaSelectedChanged(selector)
		local selectedItem = selector.selectedItem

		if selectedItem then
			lightData.enabled = selectedItem.enabled

			self:notifySchemeChanged()
		end
	end
end

function PhotoLightDiyCtrl:renderSliderItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textTitleUBaseText = objectReference:GetRefValue("textTitleUBaseText")
	local textNumUBaseText = objectReference:GetRefValue("textNumUBaseText")
	local sliderUSlider = objectReference:GetRefValue("sliderUSlider")
	local btnResetUButton = objectReference:GetRefValue("btnResetUButton")
	local lightData = self.scheme.lights[self.currentLightIndex]
	local formatText = "%." .. data.decimals .. "f"

	ClientTextUtils.setText(textTitleUBaseText, pg.getGameString(data.label))

	sliderUSlider.luaValueChanged = nil
	sliderUSlider.minValue = data.minValue
	sliderUSlider.maxValue = data.maxValue
	sliderUSlider.stepSize = data.stepSize

	sliderUSlider:SetValueWithoutCallback(lightData[data.key])
	ClientTextUtils.setText(textNumUBaseText, string.format(formatText, lightData[data.key]))

	function sliderUSlider.luaValueChanged(value)
		lightData[data.key] = value

		ClientTextUtils.setText(textNumUBaseText, string.format(formatText, value))
		self:notifySchemeChanged()
	end

	function btnResetUButton.luaClick()
		sliderUSlider.value = self.model:getLightDefaultValue(self.currentLightIndex, data)
	end
end

function PhotoLightDiyCtrl:renderColorItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textTitleUBaseText = objectReference:GetRefValue("textTitleUBaseText")
	local colorUColorPicker = objectReference:GetRefValue("colorUColorPicker")
	local btnResetUButton = objectReference:GetRefValue("btnResetUButton")
	local lightData = self.scheme.lights[self.currentLightIndex]
	local color = lightData.color

	ClientTextUtils.setText(textTitleUBaseText, pg.getGameString(data.label))

	colorUColorPicker.luaValueChanged = nil

	colorUColorPicker:SetColorWithoutNotify(UnityColor(color.r, color.g, color.b, 1))

	function colorUColorPicker.luaValueChanged(colorCode)
		local r, g, b = lume.color(colorCode)

		color.r = r
		color.g = g
		color.b = b

		self:notifySchemeChanged()
	end

	function btnResetUButton.luaClick()
		colorUColorPicker.color = UnityColor(1, 1, 1, 1)
	end
end

function PhotoLightDiyCtrl:openRenamePopup()
	pg.global.ui:open(UIConst.UI_ID_PLAYER_RENAME, {
		mode = "Rename",
		title = pg.getGameString("PHOTO_LIGHT_RENAME_TITLE"),
		maxLen = self.model.NameMaxLength,
		initialText = self.scheme.name,
		placeholder = pg.getGameString("PHOTO_LIGHT_RENAME_PLACEHOLDER"),
		confirmCallback = function(newName)
			self.scheme.name = newName

			self:refreshName()
		end
	})
end

function PhotoLightDiyCtrl:notifySchemeChanged()
	self:refreshLightButtons()

	if self.applySchemeCallback then
		self.applySchemeCallback(self.scheme)
	end
end

function PhotoLightDiyCtrl:refreshLightButtons()
	for lightIndex, button in ipairs(self.lightButtons) do
		local lightData = self.scheme.lights[lightIndex]

		button:TryChangePage("State", lightData.enabled and 1 or 0)
	end
end

function PhotoLightDiyCtrl:attachLightButtons()
	if not self.cameraMode then
		return
	end

	for lightIndex, uSimplePosFollow in ipairs(self.lightButtonFollows) do
		local lightTransform = self.cameraMode:GetDiyCameraLightTransform(lightIndex)

		if NotNil(lightTransform) then
			uSimplePosFollow:AttachToTrans(lightTransform)
		end
	end
end

function PhotoLightDiyCtrl:uploadScheme()
	if pg.me and pg.me.uploadPhotoLightScheme then
		pg.me:uploadPhotoLightScheme(self.slot, self.scheme)
	end

	if self.saveSchemeCallback then
		self.saveSchemeCallback(self.scheme)
	end
end

function PhotoLightDiyCtrl:onDestroy()
	if self.photoHostCtrl then
		self.photoHostCtrl:setPhotoLightDiyUIHidden(false)
	end

	self:uploadScheme()
	UICtrl.onDestroy(self)
end

return PhotoLightDiyCtrl
