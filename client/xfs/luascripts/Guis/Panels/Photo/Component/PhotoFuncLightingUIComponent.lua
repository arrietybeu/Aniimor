-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Photo\\Component\\PhotoFuncLightingUIComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("PhotoFuncLightingUIComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PhotoFuncLightingUIComponent = Class.LightClass("PhotoFuncLightingUIComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LightingData = require("Data.photo_lighting_data")
local AppearanceVariableData = require("Data.appearance_variable_data")
local HotkeyConst = require("Const.HotkeyConst")
local PhotographyStudioUtils = require("Utils.PhotographyStudioUtils")
local PhotographyAssetRedDotUtils = require("Utils.PhotographyAssetRedDotUtils")
local RedDotConst = require("Const.RedDotConst")
local UIConst = require("Const.UIConst")
local PhotoLightDiyModel = require("Guis.Panels.PhotoLightDiy.PhotoLightDiyModel")
local Utils = require("Common.Utils.Utils")
local playerLight = "Alight01"

PhotoFuncLightingUIComponent.LightMode = {
	Character = 1,
	Custom = 2
}
PhotoFuncLightingUIComponent.LightModeTabs = {
	{
		label = "PHOTO_LIGHT_CHARACTER",
		mode = PhotoFuncLightingUIComponent.LightMode.Character
	},
	{
		label = "PHOTO_LIGHT_CUSTOM",
		mode = PhotoFuncLightingUIComponent.LightMode.Custom
	}
}
PhotoFuncLightingUIComponent.CameraParamTipType = {
	KeyValue = 1
}

local AssetsId2Param = {
	[802101] = {
		defaultValue = 0.6,
		maxValue = 1.3,
		minValue = 0.2
	},
	[802102] = {
		defaultValue = 1.5,
		maxValue = 3,
		minValue = 0
	}
}

function PhotoFuncLightingUIComponent:onCtor(info)
	if not info then
		return
	end

	self.preset = info.preset
end

function PhotoFuncLightingUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.textNumUBaseText = objectReference:GetRefValue("textNumUBaseText")
	self.sliderUSlider = objectReference:GetRefValue("sliderUSlider")
	self.btnResetUButton = objectReference:GetRefValue("btnResetUButton")
	self.listFirstUList = objectReference:GetRefValue("listFirstUList")
	self.listSecondUList = objectReference:GetRefValue("listSecondUList")
	self.lightIntensitySliderUWidget = objectReference:GetRefValue("lightIntensitySliderUWidget")
	self.tabUWidget = objectReference:GetRefValue("tabUWidget")
	self.btnEditUButton = objectReference:GetRefValue("btnEditUButton")
end

function PhotoFuncLightingUIComponent:initView()
	self:initPhotoLight()
end

function PhotoFuncLightingUIComponent:onRefreshPhotoType()
	if not self.ctrl:isShowCameraMode() or self.curLightMode ~= self.LightMode.Character then
		return
	end

	self:setLight(self.sliderValue)
end

function PhotoFuncLightingUIComponent:getSelfEModel()
	local entity = self.ctrl:getSelfEntity()

	return entity and entity.eModel
end

function PhotoFuncLightingUIComponent:onDestroy()
	self.isDestroying = true

	self:releaseCameraLights()

	local eModel = self:getSelfEModel()

	if eModel then
		pgUtils.EnablePlayerLight(eModel, playerLight)
	end

	UIComponent.onDestroy(self)
end

function PhotoFuncLightingUIComponent:initPhotoLight()
	self.curLightMode = self.curLightMode or self.LightMode.Character

	local studioAssetsId = self.model:getStudioAssetsId()
	local param = AssetsId2Param[studioAssetsId]

	if param then
		self.maxValue = param.maxValue
		self.minValue = param.minValue
		self.defaultValue = param.defaultValue
	else
		self.maxValue = 3
		self.minValue = 0
		self.defaultValue = 1.5
	end

	self.showRate = 1

	if self.sliderValue == nil then
		self.sliderValue = self.defaultValue
	end

	self.sliderUSlider.maxValue = self.maxValue
	self.sliderUSlider.value = self.sliderValue

	local showText = string.format("%.1f", self.sliderValue * self.showRate)

	ClientTextUtils.setText(self.textNumUBaseText, showText)

	self.ctrl:getPhotoCameraMode().cameraMode.lightIntensityRate = self.sliderValue

	function self.sliderUSlider.luaValueChanged(newValue)
		self.sliderValue = newValue

		local showText = string.format("%.1f", self.sliderValue * self.showRate)

		ClientTextUtils.setText(self.textNumUBaseText, showText)
		self:setLight(newValue)
		self.ctrl:showParamTip(self.CameraParamTipType.KeyValue, pg.getGameString("PHOTO_LIGHT_INTENSITY"), showText)

		if self.ctrl.scheduleHistoryStep then
			self.ctrl:scheduleHistoryStep("lighting_intensity", 0.2)
		end
	end

	function self.listFirstUList.luaRenderItem(button, _, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

		ClientTextUtils.setText(txtNameUBaseText, pg.getGameString(data.label))
		PhotographyStudioUtils.bindTabEnterFirstItem(button, self.listSecondUList)
	end

	function self.listFirstUList.luaSelectedChanged(list, isSelected)
		if not isSelected then
			return
		end

		local data = list.selectedItem

		if data then
			self:switchLightMode(data.mode)
		end
	end

	function self.listSecondUList.luaRenderItem(button, index, data)
		button.luaNavFocused = nil
		button.luaNavUnfocused = nil

		if data.customNone then
			local itemPath = PhotographyAssetRedDotUtils.getItemPath(PhotographyAssetRedDotUtils.AssetType.Lighting, nil, "none")

			pg.global.setRedDot(itemPath, button, false, RedDotConst.RedDotStyle.NEW)
			button:TryChangePage("Lock", 0)

			button.interactable = true
			button.visualInteractable = true
			button.skipInListSwitch = false
			button.isSelected = self.curCustomLightSlot == nil

			return
		end

		if data.customSlot then
			local objectReference = button:GetComponent("ObjectReference")
			local iconUImage = objectReference:GetRefValue("iconUImage")
			local textNameUBaseText = objectReference:GetRefValue("textNameUBaseText")

			iconUImage.url = data.iconUrl or ""

			ClientTextUtils.setText(textNameUBaseText, data.name)
			button:TryChangePage("Lock", 2)

			button.interactable = true
			button.visualInteractable = true
			button.skipInListSwitch = false
			button.isSelected = self.curCustomLightSlot == data.slot

			return
		end

		if not data.id then
			local itemPath = PhotographyAssetRedDotUtils.getItemPath(PhotographyAssetRedDotUtils.AssetType.Lighting, nil, "none")

			pg.global.setRedDot(itemPath, button, false, RedDotConst.RedDotStyle.NEW)
			button:TryChangePage("Lock", 0)

			button.interactable = true
			button.visualInteractable = true
			button.skipInListSwitch = false
			button.isSelected = self.curLightId == nil

			return
		end

		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")

		iconUImage.url = data.icon or data.iconUrl

		local isUnLock = PhotographyAssetRedDotUtils.isAssetUnlocked(PhotographyAssetRedDotUtils.AssetType.Lighting, data.assetsId)
		local itemPath = PhotographyAssetRedDotUtils.getItemPath(PhotographyAssetRedDotUtils.AssetType.Lighting, nil, data.assetsId)

		pg.global.setRedDot(itemPath, button, PhotographyAssetRedDotUtils.isAssetNew(PhotographyAssetRedDotUtils.AssetType.Lighting, data.assetsId), RedDotConst.RedDotStyle.NEW)
		button:TryChangePage("Lock", isUnLock and 0 or 1)

		button.interactable = true
		button.visualInteractable = isUnLock
		button.skipInListSwitch = not isUnLock
		button.isSelected = self.curLightId == data.assetsId
	end

	function self.listSecondUList.luaClick(button, data)
		if data.customNone then
			self.curCustomLightSlot = nil
			self.customLightSchemeSnapshot = nil

			self.listSecondUList:RefreshList()
			self:applyCustomLightScheme(nil)
			self.lightIntensitySliderUWidget:SetActive(false)
			self:refreshEditButton()

			if self.ctrl.recordHistoryStep then
				self.ctrl:recordHistoryStep("lighting_select")
			end

			return
		elseif data.customSlot then
			self.curCustomLightSlot = data.slot
			self.customLightSchemeSnapshot = data.scheme

			self.listSecondUList:RefreshList()
			self:applyCustomLightScheme(data.scheme)
			self.lightIntensitySliderUWidget:SetActive(true)
			self:refreshEditButton()

			if self.ctrl.recordHistoryStep then
				self.ctrl:recordHistoryStep("lighting_select")
			end

			return
		elseif not data.id then
			self.curLightId = nil

			self.ctrl:getPhotoCameraMode().cameraMode:HiddenCameraLight()

			local eModel = self:getSelfEModel()

			if eModel then
				pgUtils.EnablePlayerLight(eModel, playerLight)
			end
		elseif not PhotographyAssetRedDotUtils.isAssetUnlocked(PhotographyAssetRedDotUtils.AssetType.Lighting, data.assetsId) then
			PhotographyStudioUtils.showLockedAssetTip(data.assetsId, button)

			return
		elseif data.assetsId ~= self.curLightId then
			self.curLightId = data.assetsId

			self.ctrl:getPhotoCameraMode().cameraMode:ApplyCameraLight(data.id)

			local eModel = self:getSelfEModel()

			if eModel then
				pgUtils.DisablePlayerLight(eModel, playerLight)
			end
		end

		if data.id then
			PhotographyAssetRedDotUtils.markAssetViewed(PhotographyAssetRedDotUtils.AssetType.Lighting, data.assetsId)
			self.listSecondUList:RefreshList()
			self.ctrl:onPhotoAssetViewed(PhotographyAssetRedDotUtils.AssetType.Lighting)
		end

		self.lightIntensitySliderUWidget:SetActive(self:validLightId())
		self:refreshEditButton()

		if self.ctrl.recordHistoryStep then
			self.ctrl:recordHistoryStep("lighting_select")
		end
	end

	function self.btnEditUButton.luaClick()
		self:openSelectedCustomLightEditor()
	end

	self:refreshEditButton()

	function self.btnResetUButton.luaClick()
		self.sliderUSlider.value = self.defaultValue
	end

	self:bindHotKey(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadDPadUp, function()
		self.btnResetUButton:OnClickSimulate()
	end, nil, self.btnResetUButton.gameObject)
	self:bindHotKey(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadLT, nil, function()
		self.sliderUSlider.normalizedValue = self.sliderUSlider.normalizedValue - 0.03
	end, self.sliderUSlider.gameObject)
	self:bindHotKey(HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRT, nil, function()
		self.sliderUSlider.normalizedValue = self.sliderUSlider.normalizedValue + 0.03
	end, self.sliderUSlider.gameObject)

	if self.preset then
		self:applyPreset(self.preset)
	end
end

function PhotoFuncLightingUIComponent:refreshUI()
	if not self.haveRefreshed then
		self.tabUWidget:SetActive(true)

		local cameraMode = self.ctrl:getPhotoCameraMode().cameraMode

		PhotoLightDiyModel:applySliderRanges(cameraMode)

		local lightPreset = cameraMode:GetPhotoLightDatas()
		local oriData = {}

		for i = 0, lightPreset.Length - 1 do
			oriData[lightPreset[i].id] = {
				id = lightPreset[i].id,
				iconUrl = lightPreset[i].url
			}
		end

		local listData = {
			{
				assetsId = -1,
				tIndex = 1
			}
		}

		for assetsId, data in pairs(LightingData) do
			local curData = oriData[data.res]

			if curData then
				curData.defaultUnlock = data.defaultUnlock
				curData.icon = data.icon
				curData.assetsId = assetsId
				listData[#listData + 1] = curData
			end
		end

		self.characterLightList = listData

		self:sortUnlockedAssetsFirst()

		self.customLightList = self:buildCustomLightList()

		self.listFirstUList:SetList(self.LightModeTabs)
		self.listFirstUList:SelectItem(self.curLightMode - 1)
		self:switchLightMode(self.curLightMode)

		self.haveRefreshed = true
	end

	if self.curLightMode == self.LightMode.Custom then
		if #self.customLightList > 0 then
			local selectedIndex = math.clamp(self.curCustomLightSlot or 0, 0, #self.customLightList - 1)

			self.listSecondUList:SelectItem(selectedIndex)
		end
	elseif not self:validLightId() then
		self.listSecondUList:SelectItem(0)
	else
		local dataList = self.listSecondUList.itemData

		for index, data in pairs(dataList) do
			if data.assetsId == self.curLightId then
				self.listSecondUList:SelectItem(index)

				break
			end
		end
	end

	self:refreshEditButton()

	local studioAssetsId = self.model:getStudioAssetsId()
	local param = AssetsId2Param[studioAssetsId]

	if param then
		if self.sliderValue == nil then
			self.sliderValue = param.defaultValue
		end

		self.sliderUSlider.maxValue = param.maxValue
		self.sliderUSlider.minValue = param.minValue
		self.sliderUSlider.value = math.clamp(self.sliderValue, param.minValue, param.maxValue)
	end
end

function PhotoFuncLightingUIComponent:applyPreset(preset)
	self:hideCustomLight()

	local customLightSlot = tonumber(preset.customLightSlot)
	local customLightCount = tonumber(pg.me.photoLightSchemeCount) or 0
	local customLightScheme

	if customLightSlot and customLightSlot >= 1 then
		if type(preset.customLightScheme) == "table" then
			customLightScheme = PhotoLightDiyModel:normalizeScheme(customLightSlot, Utils.deepCopyTable(preset.customLightScheme))
		elseif customLightSlot <= customLightCount then
			customLightScheme = PhotoLightDiyModel:normalizeScheme(customLightSlot, pg.me:getPhotoLightScheme(customLightSlot))
		end
	end

	if customLightScheme then
		self.curLightMode = self.LightMode.Custom
		self.curLightId = nil
		self.curCustomLightSlot = customLightSlot
		self.customLightSchemeSnapshot = customLightScheme

		if self.customLightList and self.customLightList[customLightSlot + 1] then
			local data = self.customLightList[customLightSlot + 1]

			data.scheme = customLightScheme
			data.name = customLightScheme.name
		end

		self.sliderValue = tonumber(preset.lightValue) or self.defaultValue
		self.ctrl:getPhotoCameraMode().cameraMode.lightIntensityRate = self.sliderValue

		self:applyCustomLightScheme(customLightScheme)
		self.lightIntensitySliderUWidget:SetActive(true)
		self.sliderUSlider:SetValueWithoutCallback(self.sliderValue)
		ClientTextUtils.setText(self.textNumUBaseText, string.format("%.1f", self.sliderValue * self.showRate))

		if self.haveRefreshed then
			self:refreshUI()
		end

		return
	end

	self.curCustomLightSlot = nil
	self.customLightSchemeSnapshot = nil
	self.curLightMode = self.LightMode.Character

	if not string.isNilOrEmpty(preset.lightId) and pg.me:isPhotoUnlock(preset.lightId) then
		self.curLightId = tonumber(preset.lightId)
		self.sliderValue = tonumber(preset.lightValue) or self.defaultValue

		local resId = self:getLightResId(self.curLightId)

		self.ctrl:getPhotoCameraMode().cameraMode:ApplyCameraLight(resId)
		self:setLight(self.sliderValue)
	else
		self:hideLight()
	end

	self.lightIntensitySliderUWidget:SetActive(self:validLightId())
	self.sliderUSlider:SetValueWithoutCallback(self.sliderValue)
	ClientTextUtils.setText(self.textNumUBaseText, string.format("%.1f", self.sliderValue * self.showRate))

	if self.haveRefreshed then
		self:refreshUI()
	end
end

function PhotoFuncLightingUIComponent:sortUnlockedAssetsFirst()
	if not self.characterLightList then
		return
	end

	PhotographyAssetRedDotUtils.sortUnlockedFirst(self.characterLightList, PhotographyAssetRedDotUtils.AssetType.Lighting, "assetsId")
end

function PhotoFuncLightingUIComponent:refreshAssetUnlockState()
	self:sortUnlockedAssetsFirst()

	if self.curLightMode == self.LightMode.Character then
		self.listSecondUList:SetList(self.characterLightList)
	end
end

function PhotoFuncLightingUIComponent:buildCustomLightList()
	local listData = {
		{
			customNone = true,
			tIndex = 1
		}
	}
	local count = tonumber(pg.me.photoLightSchemeCount) or 0

	for slot = 1, count do
		local scheme

		if slot == self.curCustomLightSlot and self.customLightSchemeSnapshot then
			scheme = self.customLightSchemeSnapshot
		else
			scheme = PhotoLightDiyModel:normalizeScheme(slot, pg.me:getPhotoLightScheme(slot))
		end

		listData[#listData + 1] = {
			customSlot = true,
			slot = slot,
			name = scheme.name,
			scheme = scheme,
			iconUrl = AppearanceVariableData.PHOTO_LIGHT_DEFAULT_ICON
		}
	end

	if self.curCustomLightSlot then
		if count > 0 then
			self.curCustomLightSlot = math.clamp(self.curCustomLightSlot, 1, count)
		else
			self.curCustomLightSlot = nil
		end
	end

	return listData
end

function PhotoFuncLightingUIComponent:switchLightMode(mode)
	self.curLightMode = mode

	if mode == self.LightMode.Custom then
		self.listSecondUList:SetList(self.customLightList)

		local scheme = self:getSelectedCustomLightScheme()

		self.lightIntensitySliderUWidget:SetActive(scheme ~= nil)
		self:applyCustomLightScheme(scheme)
		self:refreshEditButton()

		return
	end

	self:hideCustomLight()
	self.listSecondUList:SetList(self.characterLightList)
	self.lightIntensitySliderUWidget:SetActive(self:validLightId())

	if self:validLightId() then
		local resId = self:getLightResId(self.curLightId)

		self.ctrl:getPhotoCameraMode().cameraMode:ApplyCameraLight(resId)

		local eModel = self:getSelfEModel()

		if eModel then
			pgUtils.DisablePlayerLight(eModel, playerLight)
		end
	else
		self.ctrl:getPhotoCameraMode().cameraMode:HiddenCameraLight()

		local eModel = self:getSelfEModel()

		if eModel then
			pgUtils.EnablePlayerLight(eModel, playerLight)
		end
	end

	self:refreshEditButton()
end

function PhotoFuncLightingUIComponent:refreshEditButton()
	self.btnEditUButton:SetActive(self.curLightMode == self.LightMode.Custom and self.curCustomLightSlot ~= nil)
end

function PhotoFuncLightingUIComponent:openSelectedCustomLightEditor()
	if self.curLightMode ~= self.LightMode.Custom or not self.curCustomLightSlot then
		return
	end

	local data = self.customLightList[self.curCustomLightSlot + 1]

	if not data or not data.customSlot then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_PHOTO_LIGHT_DIY, {
		slot = data.slot,
		scheme = data.scheme,
		cameraMode = self.ctrl:getPhotoCameraMode().cameraMode,
		photoHostCtrl = self.ctrl.ctrl,
		applySchemeCallback = function(scheme)
			data.scheme = scheme

			if not self.isDestroying then
				self:applyCustomLightScheme(scheme)
			end
		end,
		saveSchemeCallback = function(scheme)
			data.scheme = scheme
			data.name = scheme.name

			if not self.isDestroying then
				self.listSecondUList:RefreshList()
			end
		end
	})
end

function PhotoFuncLightingUIComponent:getSelectedCustomLightScheme()
	if not self.curCustomLightSlot then
		return nil
	end

	if not self.customLightList then
		return self.customLightSchemeSnapshot
	end

	local data = self.customLightList[self.curCustomLightSlot + 1]

	return data and data.scheme
end

function PhotoFuncLightingUIComponent:applyCustomLightScheme(scheme)
	local cameraMode = self.ctrl:getPhotoCameraMode().cameraMode

	if not scheme then
		self:hideCustomLight()
		cameraMode:HiddenCameraLight()

		local eModel = self:getSelfEModel()

		if eModel then
			pgUtils.EnablePlayerLight(eModel, playerLight)
		end

		return
	end

	cameraMode:HiddenCameraLight()

	if not cameraMode.ApplyDiyCameraLight then
		return
	end

	for lightIndex = 1, PhotoLightDiyModel.LightCount do
		local lightData = scheme.lights[lightIndex]
		local color = lightData.color

		if cameraMode.ApplyDiyCameraLightTransform then
			cameraMode:ApplyDiyCameraLightTransform(lightIndex, lightData.distance, lightData.height, lightData.direction, lightData.tilt)
		end

		cameraMode:ApplyDiyCameraLight(lightIndex, lightData.enabled, lightData.intensity, color.r, color.g, color.b, lightData.colorIntensity)
	end

	local eModel = self:getSelfEModel()

	if eModel then
		pgUtils.DisablePlayerLight(eModel, playerLight)
	end
end

function PhotoFuncLightingUIComponent:hideCustomLight()
	local photoCameraMode = self.ctrl:getPhotoCameraMode()
	local cameraMode = photoCameraMode and photoCameraMode.cameraMode

	if cameraMode and cameraMode.HiddenDiyCameraLight then
		cameraMode:HiddenDiyCameraLight()
	end
end

function PhotoFuncLightingUIComponent:releaseCameraLights()
	local photoCameraMode = self.ctrl:getPhotoCameraMode()
	local cameraMode = photoCameraMode and photoCameraMode.cameraMode

	if cameraMode and cameraMode.ReleaseCameraLights then
		cameraMode:ReleaseCameraLights()
	end
end

function PhotoFuncLightingUIComponent:saveToPreset(preset)
	if self.curLightMode == self.LightMode.Custom then
		preset.lightId = nil
		preset.customLightSlot = self.curCustomLightSlot
		preset.lightValue = self.curCustomLightSlot and string.format("%.2f", self.ctrl:getPhotoCameraMode().cameraMode.lightIntensityRate) or nil

		return
	end

	preset.customLightSlot = nil
	preset.lightId = self.curLightId

	if string.isNilOrEmpty(self.curLightId) then
		preset.lightValue = nil

		return
	end

	preset.lightValue = string.format("%.2f", self.ctrl:getPhotoCameraMode().cameraMode.lightIntensityRate)
end

function PhotoFuncLightingUIComponent:setLight(value)
	local cameraMode = self.ctrl:getPhotoCameraMode().cameraMode

	cameraMode.lightIntensityRate = value

	if self.curLightMode == self.LightMode.Custom then
		self:applyCustomLightScheme(self:getSelectedCustomLightScheme())

		return
	end

	if self:validLightId() then
		local resId = self:getLightResId(self.curLightId)

		cameraMode:ApplyCameraLight(resId)
	end
end

function PhotoFuncLightingUIComponent:validLightId()
	return not string.isNilOrEmpty(self.curLightId)
end

function PhotoFuncLightingUIComponent:getLightResId(assetsId)
	assetsId = tonumber(assetsId)

	local data = LightingData[assetsId]

	return data and data.res
end

function PhotoFuncLightingUIComponent:hideLight()
	self.curLightId = nil

	self:hideCustomLight()
	self.ctrl:getPhotoCameraMode().cameraMode:HiddenCameraLight()

	local eModel = self:getSelfEModel()

	if eModel then
		pgUtils.EnablePlayerLight(eModel, playerLight)
	end

	self.lightIntensitySliderUWidget:SetActive(false)
	self:refreshEditButton()
end

return PhotoFuncLightingUIComponent
