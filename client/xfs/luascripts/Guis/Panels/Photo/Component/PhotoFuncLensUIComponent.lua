-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Photo\\Component\\PhotoFuncLensUIComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("PhotoFuncLensUIComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PhotoFuncLensUIComponent = Class.LightClass("PhotoFuncLensUIComponent", UIComponent)
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientSettingUtils = require("Utils.ClientSettingUtils")
local HotkeyConst = require("Const.HotkeyConst")

PhotoFuncLensUIComponent.Tabs = {
	SATURATION = 5,
	EXPOSURE = 4,
	DOF_R = 3,
	DOF = 2,
	FOV = 1,
	ROTATE = 9,
	VIGNETTE = 8,
	CONTRAST = 7,
	BRIGHTNESS = 6
}
PhotoFuncLensUIComponent.CameraParamTipType = {
	KeyValue = 1
}
PhotoFuncLensUIComponent.ConfigData = {
	[PhotoFuncLensUIComponent.Tabs.FOV] = {
		showRate = 10,
		maxValue = 10,
		defaultValue = 1.4,
		label = "FIELD_OF_VIEW",
		tabId = PhotoFuncLensUIComponent.Tabs.FOV
	},
	[PhotoFuncLensUIComponent.Tabs.DOF] = {
		adjust = 100,
		flip = true,
		showRate = -10,
		maxValue = 10,
		defaultValue = 10,
		startValue = 1,
		label = "DEPTH_OF_FIELD",
		tabId = PhotoFuncLensUIComponent.Tabs.DOF
	},
	[PhotoFuncLensUIComponent.Tabs.DOF_R] = {
		showRate = 100,
		maxValue = 1,
		defaultValue = 0.5,
		label = "DEPTH_OF_FIELD_RANGE",
		tabId = PhotoFuncLensUIComponent.Tabs.DOF_R
	},
	[PhotoFuncLensUIComponent.Tabs.EXPOSURE] = {
		maxValue = 1,
		showRate = 100,
		minValue = -1,
		defaultValue = 0,
		label = "PHOTO_EXPOSURE",
		tabId = PhotoFuncLensUIComponent.Tabs.EXPOSURE
	},
	[PhotoFuncLensUIComponent.Tabs.SATURATION] = {
		maxValue = 1,
		showRate = 100,
		minValue = -1,
		defaultValue = 0,
		label = "PHOTO_SATURATION",
		tabId = PhotoFuncLensUIComponent.Tabs.SATURATION
	},
	[PhotoFuncLensUIComponent.Tabs.BRIGHTNESS] = {
		maxValue = 1,
		showRate = 100,
		minValue = -1,
		defaultValue = 0,
		label = "PHOTO_BRIGHTNESS",
		tabId = PhotoFuncLensUIComponent.Tabs.BRIGHTNESS
	},
	[PhotoFuncLensUIComponent.Tabs.CONTRAST] = {
		maxValue = 1,
		showRate = 100,
		minValue = -1,
		defaultValue = 0,
		label = "PHOTO_CONTRAST",
		tabId = PhotoFuncLensUIComponent.Tabs.CONTRAST
	},
	[PhotoFuncLensUIComponent.Tabs.VIGNETTE] = {
		formatString = "%.2f",
		showRate = 12.5,
		maxValue = 0.8,
		defaultValue = 0,
		label = "PHOTO_VIGNETTE",
		tabId = PhotoFuncLensUIComponent.Tabs.VIGNETTE
	},
	[PhotoFuncLensUIComponent.Tabs.ROTATE] = {
		maxValue = 90,
		startValue = 0.5,
		showRate = 1,
		minValue = -90,
		defaultValue = 0,
		label = "ROTATE_TEXT",
		tabId = PhotoFuncLensUIComponent.Tabs.ROTATE
	}
}

local WORLD_CAMERA_SETTING_RATE = 0.01
local WorldCameraSettingGetterByTab = {
	[PhotoFuncLensUIComponent.Tabs.SATURATION] = ClientSettingUtils.get_worldCameraSaturation,
	[PhotoFuncLensUIComponent.Tabs.BRIGHTNESS] = ClientSettingUtils.get_worldCameraBrightness,
	[PhotoFuncLensUIComponent.Tabs.CONTRAST] = ClientSettingUtils.get_worldCameraContrast
}

function PhotoFuncLensUIComponent:getDefaultValue(tabId)
	local settingGetter = WorldCameraSettingGetterByTab[tabId]

	if settingGetter then
		return settingGetter() * WORLD_CAMERA_SETTING_RATE
	end

	return self.ConfigData[tabId].defaultValue
end

function PhotoFuncLensUIComponent:onCtor(info)
	if not info then
		return
	end

	self.preset = info.preset
	self.addZ = info.addZ
	self.minusZ = info.minusZ
end

function PhotoFuncLensUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.cameraParameterUComponent = objectReference:GetRefValue("cameraParameterUComponent")
	self.sliderUSlider = objectReference:GetRefValue("sliderUSlider")
	self.btnResetUButton = objectReference:GetRefValue("btnResetUButton")
	self.textNumUBaseText = objectReference:GetRefValue("textNumUBaseText")
	self.listUList = objectReference:GetRefValue("listUList")
	self.btnArrowLeftUButton = objectReference:GetRefValue("btnArrowLeftUButton")
	self.btnArrowRightUButton = objectReference:GetRefValue("btnArrowRightUButton")
	self.photoCameraZoomUpdateCurve = pg.global.cameraMgr.vcManager:GetPhotoCameraZoomUpdateCurve()
	self.photoCameraZoomUpdateCurveWildAngle = pg.global.cameraMgr.vcManager:GetPhotoCameraZoomUpdateCurveWideAngle()
	self.photoCameraZoomUpdateCurveFishEye = pg.global.cameraMgr.vcManager:GetPhotoCameraZoomUpdateCurveFishEye()
end

function PhotoFuncLensUIComponent:initView()
	self:initPhotoLens()
end

function PhotoFuncLensUIComponent:update()
	self:updateRotate()
end

function PhotoFuncLensUIComponent:onRefreshPhotoType()
	if not self.ctrl:isShowCameraMode() then
		return
	end

	self:refreshAllEffect()
end

function PhotoFuncLensUIComponent:onDestroy()
	self.listUList:UnRegisterToScrollEvent(self.funcListScroll)
	UIComponent.onDestroy(self)
end

function PhotoFuncLensUIComponent:initPhotoLens()
	self.curTab = self.Tabs.FOV
	self.zoomChangeRate = 0.2
	self.view.zoom.value = self.ConfigData[self.Tabs.FOV].defaultValue
	self.dofRangeMinUISize = 500
	self.dofRangeUISizeRate = 1600
	self.rotateZChangeRate = 1
	self.rotateValueShowRate = 1
	self.sliderValueByTab = {}

	for k, tab in pairs(self.Tabs) do
		self.sliderValueByTab[tab] = self.sliderValueByTab[tab] or self:getDefaultValue(tab)
	end

	self.btnArrowLeftUButton:SetActive(false)
	self.btnArrowRightUButton:SetActive(true)

	function self.view.zoom.luaValueChanged(value)
		self:setFov(value)

		if self.ctrl.scheduleHistoryStep then
			self.ctrl:scheduleHistoryStep("lens_adjust", 0.2)
		end
	end

	function self.view.zoomDec.luaClick()
		self:onZoomClick(false)
	end

	function self.view.zoomDec.luaLongPress(time)
		self:onZoomLongPress(false, time)
	end

	function self.view.zoomAdd.luaClick()
		self:onZoomClick(true)
	end

	function self.view.zoomAdd.luaLongPress(time)
		self:onZoomLongPress(true, time)
	end

	function self.btnResetUButton.luaClick()
		self.sliderUSlider.value = self:getDefaultValue(self.curTab)
	end

	self:bindHotKey(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadDPadUp, function()
		self.btnResetUButton:OnClickSimulate()
	end, nil, self.btnResetUButton.gameObject)
	self:bindHotKey(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadLT, nil, function()
		self.sliderUSlider.normalizedValue = self.sliderUSlider.normalizedValue - 0.03 * (self.ConfigData[self.curTab].showRate > 0 and 1 or -1)
	end, self.sliderUSlider.gameObject)
	self:bindHotKey(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRT, nil, function()
		self.sliderUSlider.normalizedValue = self.sliderUSlider.normalizedValue + 0.03 * (self.ConfigData[self.curTab].showRate > 0 and 1 or -1)
	end, self.sliderUSlider.gameObject)

	function self.funcListScroll(Vec2)
		self:onListScroll(Vec2)
	end

	self.listUList:RegisterToScrollEvent(self.funcListScroll)

	function self.listUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

		ClientTextUtils.setText(txtNameUBaseText, pg.getGameString(data.label))

		function button.luaSelectChanged(isSelected)
			if not isSelected then
				return
			end

			self.curTab = data.tabId

			local maxValue = data.maxValue
			local minValue = data.minValue or 0
			local curValue = self.sliderValueByTab[data.tabId]
			local showRate = data.showRate or 1
			local adjust = data.adjust or 0
			local formatString = data.formatString or "%d"
			local startValue = data.startValue or 0
			local flip = data.flip or false
			local showValue = string.format(formatString, curValue * showRate + adjust)

			ClientTextUtils.setText(self.textNumUBaseText, showValue)
			self.ctrl:showParamTip(self.CameraParamTipType.KeyValue, pg.getGameString(data.label), showValue)

			function self.sliderUSlider.luaValueChanged(newValue)
				self.sliderValueByTab[data.tabId] = newValue

				local showValue = string.format(formatString, newValue * showRate + adjust)

				ClientTextUtils.setText(self.textNumUBaseText, showValue)
				self.ctrl:showParamTip(self.CameraParamTipType.KeyValue, pg.getGameString(data.label), showValue)

				if self.ctrl.scheduleHistoryStep then
					self.ctrl:scheduleHistoryStep("lens_adjust", 0.2)
				end

				if data.tabId == self.Tabs.FOV then
					self:setFov(newValue)
				elseif data.tabId == self.Tabs.DOF then
					self:setDof(newValue)
				elseif data.tabId == self.Tabs.DOF_R then
					self:setDofR(newValue)
				elseif data.tabId == self.Tabs.EXPOSURE then
					self:setExposure(newValue)
				elseif data.tabId == self.Tabs.SATURATION then
					self:setSaturation(newValue)
				elseif data.tabId == self.Tabs.BRIGHTNESS then
					self:setBrightness(newValue)
				elseif data.tabId == self.Tabs.CONTRAST then
					self:setContrast(newValue)
				elseif data.tabId == self.Tabs.VIGNETTE then
					self:setVignette(newValue)
				elseif data.tabId == self.Tabs.ROTATE then
					self:setRotate(newValue)
				end
			end

			self.sliderUSlider.flip = flip
			self.sliderUSlider.maxValue = maxValue
			self.sliderUSlider.minValue = minValue
			self.sliderUSlider.customStartValue = startValue
			self.sliderUSlider.value = curValue
		end
	end

	if self.preset then
		self:applyPreset(self.preset)
	else
		self:refreshAllEffect()
	end
end

function PhotoFuncLensUIComponent:refreshUI()
	if not self.haveRefreshed then
		local hiddenTabs = self.ctrl.getHiddenLensTabs and self.ctrl:getHiddenLensTabs() or nil
		local tabListData = {}

		for k, config in pairs(self.ConfigData) do
			if not hiddenTabs or not hiddenTabs[config.tabId] then
				tabListData[#tabListData + 1] = config
			end
		end

		table.sort(tabListData, function(a, b)
			return a.tabId < b.tabId
		end)
		self.listUList:SetList(tabListData)
		self.listUList:DeselectAll()
		self.listUList:SelectItem(0)

		self.haveRefreshed = true
	end
end

function PhotoFuncLensUIComponent:applyPreset(preset)
	if preset then
		local cfg = self.ConfigData

		self.sliderValueByTab[self.Tabs.FOV] = preset.fov or cfg[self.Tabs.FOV].defaultValue
		self.sliderValueByTab[self.Tabs.DOF] = preset.dof or cfg[self.Tabs.DOF].defaultValue
		self.sliderValueByTab[self.Tabs.DOF_R] = preset.dofRange or cfg[self.Tabs.DOF_R].defaultValue
		self.sliderValueByTab[self.Tabs.EXPOSURE] = preset.exposure or cfg[self.Tabs.EXPOSURE].defaultValue
		self.sliderValueByTab[self.Tabs.SATURATION] = preset.saturation or self:getDefaultValue(self.Tabs.SATURATION)
		self.sliderValueByTab[self.Tabs.BRIGHTNESS] = preset.brightness or self:getDefaultValue(self.Tabs.BRIGHTNESS)
		self.sliderValueByTab[self.Tabs.CONTRAST] = preset.contrast or self:getDefaultValue(self.Tabs.CONTRAST)
		self.sliderValueByTab[self.Tabs.VIGNETTE] = preset.vignette or cfg[self.Tabs.VIGNETTE].defaultValue
		self.sliderValueByTab[self.Tabs.ROTATE] = preset.rotate or cfg[self.Tabs.ROTATE].defaultValue

		self:refreshAllEffect()
		self:refreshCurrentSliderValue()
	end
end

function PhotoFuncLensUIComponent:refreshCurrentSliderValue()
	local config = self.ConfigData[self.curTab]
	local value = self.sliderValueByTab[self.curTab]

	if not config or value == nil then
		return
	end

	self.sliderUSlider:SetValueWithoutCallback(value)

	local showRate = config.showRate or 1
	local adjust = config.adjust or 0
	local formatString = config.formatString or "%d"

	ClientTextUtils.setText(self.textNumUBaseText, string.format(formatString, value * showRate + adjust))
end

function PhotoFuncLensUIComponent:saveToPreset(preset)
	preset.fov = tonumber(string.format("%.1f", self.sliderValueByTab[self.Tabs.FOV]))
	preset.dof = tonumber(string.format("%.1f", self.sliderValueByTab[self.Tabs.DOF]))
	preset.dofRange = tonumber(string.format("%.1f", self.sliderValueByTab[self.Tabs.DOF_R]))
	preset.exposure = tonumber(string.format("%.1f", self.sliderValueByTab[self.Tabs.EXPOSURE]))
	preset.saturation = tonumber(string.format("%.1f", self.sliderValueByTab[self.Tabs.SATURATION]))
	preset.brightness = tonumber(string.format("%.1f", self.sliderValueByTab[self.Tabs.BRIGHTNESS]))
	preset.contrast = tonumber(string.format("%.1f", self.sliderValueByTab[self.Tabs.CONTRAST]))
	preset.vignette = tonumber(string.format("%.1f", self.sliderValueByTab[self.Tabs.VIGNETTE]))
	preset.rotate = tonumber(string.format("%.1f", self.sliderValueByTab[self.Tabs.ROTATE]))
end

function PhotoFuncLensUIComponent:refreshAllEffect()
	self:setFov(self.sliderValueByTab[self.Tabs.FOV])
	self:setDof(self.sliderValueByTab[self.Tabs.DOF])
	self:setDofR(self.sliderValueByTab[self.Tabs.DOF_R])
	self:setExposure(self.sliderValueByTab[self.Tabs.EXPOSURE])
	self:setSaturation(self.sliderValueByTab[self.Tabs.SATURATION])
	self:setBrightness(self.sliderValueByTab[self.Tabs.BRIGHTNESS])
	self:setContrast(self.sliderValueByTab[self.Tabs.CONTRAST])
	self:setVignette(self.sliderValueByTab[self.Tabs.VIGNETTE])
	self:setRotate(self.sliderValueByTab[self.Tabs.ROTATE])
end

function PhotoFuncLensUIComponent:onZoomClick(isAdd)
	if self.curTab ~= self.Tabs.FOV then
		return
	end

	self:adjustFov(self.zoomChangeRate * (isAdd and 1 or -1))
end

function PhotoFuncLensUIComponent:adjustFov(delta)
	self.view.zoom.useNodes = false

	local newValue = self.view.zoom.value + delta

	self.sliderValueByTab[self.Tabs.FOV] = newValue
	self.view.zoom.value = newValue
	self.view.zoom.useNodes = true

	local showValue = string.format("%d", math.clamp(newValue * self.ConfigData[self.Tabs.FOV].showRate, 0, 100))

	ClientTextUtils.setText(self.textNumUBaseText, showValue)
	self.ctrl:showParamTip(self.CameraParamTipType.KeyValue, pg.getGameString("FIELD_OF_VIEW"), showValue)
end

function PhotoFuncLensUIComponent:onZoomLongPress(isAdd, time)
	if self.curTab ~= self.Tabs.FOV then
		return
	end

	self.view.zoom.useNodes = false

	local newValue = self.view.zoom.value + self.zoomChangeRate * math.max(1, time) * (isAdd and 1 or -1)

	self.sliderValueByTab[self.Tabs.FOV] = newValue
	self.view.zoom.value = newValue
	self.view.zoom.useNodes = true

	local showValue = string.format("%d", newValue * self.ConfigData[self.Tabs.FOV].showRate)

	ClientTextUtils.setText(self.textNumUBaseText, showValue)
	self.ctrl:showParamTip(self.CameraParamTipType.KeyValue, pg.getGameString("FIELD_OF_VIEW"), showValue)
end

function PhotoFuncLensUIComponent:onScrollAdjust(isAdd, forceFov)
	if forceFov or self.curTab == self.Tabs.FOV then
		self:adjustFov(self.zoomChangeRate * (isAdd and 1 or -1))

		return
	end

	local config = self.ConfigData[self.curTab]

	if not config then
		return
	end

	local dir = config.showRate and config.showRate > 0 and 1 or -1

	self.sliderUSlider.normalizedValue = self.sliderUSlider.normalizedValue + 0.05 * (isAdd and 1 or -1) * dir
end

function PhotoFuncLensUIComponent:setFov(value)
	self.view.zoom:SetValueWithoutCallback(value)

	if self.curTab == self.Tabs.FOV then
		self.sliderUSlider:SetValueWithoutCallback(value)
	end

	if self.model:getCameraMode() == self.model.CameraModeIds.FreeCamera then
		value = self.photoCameraZoomUpdateCurve:Evaluate(value)
	elseif self.model:getCameraMode() == self.model.CameraModeIds.WideAngle then
		value = self.photoCameraZoomUpdateCurveWildAngle:Evaluate(value)
	elseif self.model:getCameraMode() == self.model.CameraModeIds.FishEye then
		value = self.photoCameraZoomUpdateCurveFishEye:Evaluate(value)
	end

	self.ctrl:getPhotoCameraMode():zoom(value)
end

function PhotoFuncLensUIComponent:setDof(value)
	self.ctrl:getPhotoCameraMode().cameraMode:SetDof(value)
end

function PhotoFuncLensUIComponent:setDofR(value)
	self:setDofRangeUIViewSize(self.dofRangeMinUISize + value * self.dofRangeUISizeRate)
	self.ctrl:getPhotoCameraMode().cameraMode:SetDofRange(value)
end

function PhotoFuncLensUIComponent:setDofRangeUIViewSize(value)
	self.view.center2Transform.sizeDelta = Vector2(value, value)
end

function PhotoFuncLensUIComponent:setExposure(value)
	self.ctrl:getPhotoCameraMode().cameraMode:SetExposure(value)
end

function PhotoFuncLensUIComponent:setSaturation(value)
	self.ctrl:getPhotoCameraMode().cameraMode:SetSaturation(value)
end

function PhotoFuncLensUIComponent:setBrightness(value)
	self.ctrl:getPhotoCameraMode().cameraMode:SetBrightness(value)
end

function PhotoFuncLensUIComponent:setContrast(value)
	self.ctrl:getPhotoCameraMode().cameraMode:SetContrast(value)
end

function PhotoFuncLensUIComponent:setVignette(value)
	self.ctrl:getPhotoCameraMode().cameraMode:SetVignette(value + 0.2)
end

function PhotoFuncLensUIComponent:setRotate(value)
	self.ctrl:getPhotoCameraMode():rotateZ(value)
end

function PhotoFuncLensUIComponent:refreshPhotoLens(isNormalOrSelfie)
	return
end

function PhotoFuncLensUIComponent:updateRotate()
	if self.curTab ~= self.Tabs.ROTATE then
		return
	end

	local newValue = self.sliderValueByTab[self.Tabs.ROTATE]
	local minRotateValue = self.ConfigData[self.Tabs.ROTATE].minValue
	local maxRotateValue = self.ConfigData[self.Tabs.ROTATE].maxValue

	if self.addZ then
		newValue = maxRotateValue < newValue + self.rotateZChangeRate and newValue < 180 and maxRotateValue or newValue + self.rotateZChangeRate
	end

	if self.minusZ then
		newValue = newValue - self.rotateZChangeRate > 180 and newValue - self.rotateZChangeRate < 360 + minRotateValue and minRotateValue or newValue - self.rotateZChangeRate
	end

	if self.sliderValueByTab[self.Tabs.ROTATE] ~= newValue then
		self.sliderUSlider.value = newValue
	end
end

function PhotoFuncLensUIComponent:onListScroll(Vec2)
	self.btnArrowLeftUButton:SetActive(Vec2.x > 0)
	self.btnArrowRightUButton:SetActive(Vec2.x < 1)
end

return PhotoFuncLensUIComponent
