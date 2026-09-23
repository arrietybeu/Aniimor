-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Photo\\Component\\PhotoFuncFilterUIComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("PhotoFuncFilterUIComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PhotoFuncFilterUIComponent = Class.LightClass("PhotoFuncFilterUIComponent", UIComponent)
local FilterData = require("Data.photo_filter_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PhotographyStudioUtils = require("Utils.PhotographyStudioUtils")
local PhotographyAssetRedDotUtils = require("Utils.PhotographyAssetRedDotUtils")
local RedDotConst = require("Const.RedDotConst")
local oriValue = 0.5

local function getDisplayValue(value)
	return string.format("%.0f", value * 100)
end

function PhotoFuncFilterUIComponent:onCtor(info)
	if not info then
		return
	end

	self.preset = info.preset
end

function PhotoFuncFilterUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.sliderUSlider = objectReference:GetRefValue("sliderUSlider")
	self.textNumUBaseText = objectReference:GetRefValue("textNumUBaseText")
	self.listFirstUList = objectReference:GetRefValue("listFirstUList")
	self.listSecondUList = objectReference:GetRefValue("listSecondUList")
	self.btnResetUButton = objectReference:GetRefValue("btnResetUButton")
	self.sliderUWidget = objectReference:GetRefValue("sliderUWidget")
	self.tabUWidget = objectReference:GetRefValue("tabUWidget")
end

function PhotoFuncFilterUIComponent:initView()
	self:initFilter()
end

function PhotoFuncFilterUIComponent:onDestroy()
	self:clearLUT()
	UIComponent.onDestroy(self)
end

function PhotoFuncFilterUIComponent:initFilter()
	self.filterId = nil
	self.filterValueMap = {}
	self.curTab = nil
	self.type2FilterData = {}
	self.type2Name = {}

	self.model:getAssetsData(FilterData, self.type2FilterData, self.type2Name)

	for type, list in pairs(self.type2FilterData) do
		table.insert(list, 1, {
			tIndex = 1,
			noSelect = true
		})
	end

	self:sortUnlockedAssetsFirst()

	function self.sliderUSlider.luaValueChanged(newValue)
		ClientTextUtils.setText(self.textNumUBaseText, getDisplayValue(newValue))

		if self.filterId then
			self.filterValueMap[self.filterId] = newValue

			self:SetLUTIntensity(newValue)
		end

		if self.ctrl.scheduleHistoryStep then
			self.ctrl:scheduleHistoryStep("filter_intensity", 0.2)
		end
	end

	function self.listFirstUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

		ClientTextUtils.setText(txtNameUBaseText, pg.getLocalizationText(self.type2Name[data.type or 1]))

		local subTabPath = PhotographyAssetRedDotUtils.getSubTabPath(PhotographyAssetRedDotUtils.AssetType.Filter, data.type)

		pg.global.setPreViewRedDot(subTabPath, button, function()
			return PhotographyAssetRedDotUtils.getRedDotStyle(PhotographyAssetRedDotUtils.AssetType.Filter, data.type)
		end)

		function button.luaSelectChanged(selected)
			if not selected then
				return
			end

			if data.type == self.curTab then
				return
			end

			self.curTab = data.type

			local dataList = self.type2FilterData[self.curTab]

			self.listSecondUList:SetList(dataList)
		end

		PhotographyStudioUtils.bindTabEnterFirstItem(button, self.listSecondUList)
	end

	function self.listSecondUList.luaRenderItem(button, index, data)
		if not data.id then
			local itemPath = PhotographyAssetRedDotUtils.getItemPath(PhotographyAssetRedDotUtils.AssetType.Filter, self.curTab, "none")

			pg.global.setRedDot(itemPath, button, false, RedDotConst.RedDotStyle.NEW)
			button:TryChangePage("Lock", 0)

			button.interactable = true
			button.visualInteractable = true
			button.skipInListSwitch = false

			function button.luaClick()
				self.filterId = nil

				self:clearLUT()
				LuaUIUtils.setUIViewVisible(self.sliderUWidget, false)

				if self.ctrl.recordHistoryStep then
					self.ctrl:recordHistoryStep("filter_select")
				end
			end

			button.isSelected = self.filterId == nil

			return
		end

		local objectReference = button:GetComponent("ObjectReference")
		local iconUImage = objectReference:GetRefValue("iconUImage")

		if data.icon then
			iconUImage.url = data.icon
		end

		local isUnLock = PhotographyAssetRedDotUtils.isAssetUnlocked(PhotographyAssetRedDotUtils.AssetType.Filter, data.id)
		local itemPath = PhotographyAssetRedDotUtils.getItemPath(PhotographyAssetRedDotUtils.AssetType.Filter, data.type, data.id)

		pg.global.setRedDot(itemPath, button, PhotographyAssetRedDotUtils.isAssetNew(PhotographyAssetRedDotUtils.AssetType.Filter, data.id), RedDotConst.RedDotStyle.NEW)
		button:TryChangePage("Lock", isUnLock and 0 or 1)

		button.interactable = true
		button.visualInteractable = isUnLock
		button.skipInListSwitch = not isUnLock
		button.isSelected = self.filterId == data.id

		function button.luaClick()
			if not isUnLock then
				PhotographyStudioUtils.showLockedAssetTip(data.id, button)

				return
			end

			PhotographyAssetRedDotUtils.markAssetViewed(PhotographyAssetRedDotUtils.AssetType.Filter, data.id)
			self.listSecondUList:RefreshList()
			self.ctrl:onPhotoAssetViewed(PhotographyAssetRedDotUtils.AssetType.Filter, data.type)

			if self.filterId == data.id then
				return
			end

			self.filterId = data.id

			local intensity = self.filterValueMap[self.filterId] or oriValue

			self.sliderUSlider:SetValueWithoutCallback(intensity)
			ClientTextUtils.setText(self.textNumUBaseText, getDisplayValue(intensity))
			self:setLUT(data.res)
			self:SetLUTIntensity(intensity)
			LuaUIUtils.setUIViewVisible(self.sliderUWidget, true)

			if self.ctrl.recordHistoryStep then
				self.ctrl:recordHistoryStep("filter_select")
			end
		end
	end

	function self.btnResetUButton.luaClick()
		self.sliderUSlider.value = oriValue
	end

	self.sliderUSlider.maxValue = 1
	self.sliderUSlider.minValue = 0
	self.sliderUSlider.value = oriValue

	ClientTextUtils.setText(self.textNumUBaseText, getDisplayValue(oriValue))
	self:clearLUT()

	if self.preset then
		self:appPreset(self.preset)
	end
end

function PhotoFuncFilterUIComponent:refreshUI()
	if not self.haveRefreshed then
		local typeList = {}
		local selectedType = self.filterId and FilterData[tonumber(self.filterId)]

		selectedType = selectedType and selectedType.type

		local selectedTypeIndex = 0

		for type, _ in pairs(self.type2FilterData) do
			typeList[#typeList + 1] = {
				type = type
			}

			if type == selectedType then
				selectedTypeIndex = #typeList - 1
			end
		end

		LuaUIUtils.setUIViewVisible(self.sliderUWidget, false)
		self.listFirstUList:SetList(typeList)
		self.listFirstUList:DeselectAll()
		self.listFirstUList:SelectItem(selectedTypeIndex)
		self.tabUWidget:SetActive(#typeList > 1)

		self.haveRefreshed = true
	end

	if self.filterId then
		local dataList = self.listSecondUList.itemData

		for index, data in pairs(dataList) do
			if data.id == tonumber(self.filterId) then
				self.listSecondUList:SelectItem(index)

				break
			end
		end
	else
		self.listSecondUList:SelectItem(0)
	end
end

function PhotoFuncFilterUIComponent:appPreset(preset)
	if preset.filterId and pg.me:isPhotoUnlock(preset.filterId) then
		local filterData = FilterData[preset.filterId]

		if filterData then
			self.filterValueMap[preset.filterId] = preset.filterValue

			self:setLUT(filterData.res)
			self:SetLUTIntensity(preset.filterValue)
		end
	end
end

function PhotoFuncFilterUIComponent:applyPreset(preset)
	if not preset then
		return
	end

	if preset.filterId and pg.me:isPhotoUnlock(preset.filterId) then
		local filterData = FilterData[tonumber(preset.filterId)]

		if filterData then
			self.filterId = tonumber(preset.filterId)

			local intensity = preset.filterValue or oriValue

			self.filterValueMap[self.filterId] = intensity

			self.sliderUSlider:SetValueWithoutCallback(intensity)
			ClientTextUtils.setText(self.textNumUBaseText, getDisplayValue(intensity))
			self:setLUT(filterData.res)
			self:SetLUTIntensity(intensity)

			if self.haveRefreshed then
				self:refreshUI()
			end

			return
		end
	end

	self.filterId = nil

	self:clearLUT()

	if self.haveRefreshed then
		self:refreshUI()
	end
end

function PhotoFuncFilterUIComponent:saveToPreset(preset)
	preset.filterId = self.filterId

	if self.filterId then
		preset.filterValue = self.sliderUSlider.value
	else
		preset.filterValue = nil
	end
end

function PhotoFuncFilterUIComponent:sortUnlockedAssetsFirst()
	for _, dataList in pairs(self.type2FilterData) do
		PhotographyAssetRedDotUtils.sortUnlockedFirst(dataList, PhotographyAssetRedDotUtils.AssetType.Filter)
	end
end

function PhotoFuncFilterUIComponent:refreshAssetUnlockState()
	self:sortUnlockedAssetsFirst()

	if self.curTab then
		self.listSecondUList:SetList(self.type2FilterData[self.curTab])
	end
end

function PhotoFuncFilterUIComponent:setLUT(url)
	self.ctrl:getPhotoCameraMode().cameraMode:SetLUT(url)
end

function PhotoFuncFilterUIComponent:SetLUTIntensity(value)
	self.ctrl:getPhotoCameraMode().cameraMode:SetLUTIntensity(value)
end

function PhotoFuncFilterUIComponent:clearLUT()
	local photoCameraMode = self.ctrl and self.ctrl:getPhotoCameraMode()

	if photoCameraMode and photoCameraMode.cameraMode then
		photoCameraMode.cameraMode:clearLUT()
	end
end

return PhotoFuncFilterUIComponent
