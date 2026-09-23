-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetManagementFilter\\PetManagementFilterCtrl.lua

local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientConst = require("Const.ClientConst")
local PetManagementFilterModel = require("Guis.Panels.PetManagementFilter.PetManagementFilterModel")
local PetManagementFilterCtrl = Class.LightClass("PetManagementFilterCtrl", UICtrl)

PetManagementFilterCtrl.messages = {}

function PetManagementFilterCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self.model:setInfo(info)

	self.filterType = info.filterType or UIConst.PET_SLOT_DISPLAY_TYPE.Normal
	self.inVitality = info.inVitality
	self.isAutoFilter = info.isAutoFilter
	self.noTab = info.noTab
	self.disableSessionCache = info.disableSessionCache
	self.sortId = info.sortId or 0

	if info.isDescending == true then
		self.isDescending = true
	elseif info.isDescending == false then
		self.isDescending = false
	else
		self.isDescending = true
	end

	self:clearFilter()

	if info.filter then
		self.filter = Utils.deepCopyTable(info.filter)
	end

	self.filter.isClimb = false
	self.filter.isGlide = false
	self.filter.isSwim = false

	if self.filterType == UIConst.PET_SLOT_DISPLAY_TYPE.Normal then
		self.filter.isInHomeland = nil
	end

	self.doFilterCallback = info.doFilterCallback

	local savedState = not self.disableSessionCache and PetManagementFilterModel.loadSessionState(self.filterType)

	if savedState then
		if savedState.filter then
			self.filter = Utils.deepCopyTable(savedState.filter)
			self.filter.isClimb = false
			self.filter.isGlide = false
			self.filter.isSwim = false

			if self.filterType == UIConst.PET_SLOT_DISPLAY_TYPE.Normal then
				self.filter.isInHomeland = nil
			end
		end

		self.sortId = savedState.sortId or 0
		self.isDescending = savedState.isDescending ~= false
	end

	self:setAllFilters()
	self:setAllSortOptions()

	self.view.inputFilterUInputField.text = self.filter.keyword

	self:chooseTab(true)
	self:checkBotButtonsStatus()

	if self.noTab and self.view.root then
		self.view.root:TryChangePage("NoTab", 1)
	end

	self.showLabelInfo = pg.global.prefsCacheUtils:getBool("filterShowLabelInfo", true, ClientConst.CACHE_TYPE_FLAG.USER)

	self.view.btnDisplayUButton:TryChangePage("Display", self.showLabelInfo and 1 or 0)
	self.view.widget:TryChangePage("NoInput", self.filterType ~= UIConst.PET_SLOT_DISPLAY_TYPE.TradeMarketPet and 0 or 1)
end

function PetManagementFilterCtrl:closePanel()
	pg.global.ui:close(UIConst.UI_ID_PET_MANAGEMENT_FILTER)
end

function PetManagementFilterCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:closePanel()
	end

	function self.view.btnSortUButton.luaClick()
		self:chooseTab(false)
	end

	function self.view.btnFilterUButton.luaClick()
		self:chooseTab(true)
	end

	function self.view.cleanBtn.luaClick()
		if not self.disableSessionCache then
			PetManagementFilterModel.clearSessionCache()
		end

		self:clearFilter()
		self:clearSort()
		self:setAllFilters()
		self:checkBotButtonsStatus()
	end

	function self.view.inputFilterUInputField.luaValueChanged(text)
		self.filter.keyword = text

		self:checkBotButtonsStatus()
	end

	function self.view.confirmBtn.luaClick()
		self:doFilter()
	end

	function self.view.btnDisplayUButton.luaClick()
		self.showLabelInfo = not self.showLabelInfo

		self.view.btnDisplayUButton:TryChangePage("Display", self.showLabelInfo and 1 or 0)
		pg.global.prefsCacheUtils:setBool("filterShowLabelInfo", self.showLabelInfo, ClientConst.CACHE_TYPE_FLAG.USER)
		pg.global.prefsCacheUtils:save()
	end
end

function PetManagementFilterCtrl:chooseTab(isFilter)
	self.view.btnSortUButton.isSelected = not isFilter
	self.view.btnFilterUButton.isSelected = isFilter

	self.view.btnSortUButton:TryChangePage("button", isFilter and 0 or 5)
	self.view.btnFilterUButton:TryChangePage("button", isFilter and 5 or 0)
	self.view.root:TryChangePage("toptab", isFilter and 0 or 1)
end

function PetManagementFilterCtrl:setAllFilters()
	local function innerClick1(b, key)
		if self.filter[key] then
			self.filter[key] = false
			b.isSelected = false

			b:TryChangePage("button", 0)
			self:checkBotButtonsStatus()

			return
		end

		self.filter[key] = true
		b.isSelected = true

		b:TryChangePage("button", 5)
		self:checkBotButtonsStatus()
	end

	local function innerClick2(b, name)
		if self.filter.elements[name] ~= nil then
			self.filter.elements[name] = nil
			b.isSelected = false

			b:TryChangePage("button", 0)
			self:checkBotButtonsStatus()

			return
		end

		self.filter.elements[name] = name
		b.isSelected = true

		b:TryChangePage("button", 5)
		self:checkBotButtonsStatus()
	end

	local data = self.model:getAllFiltersInfo(self.filterType, true)

	function self.view.filterList.luaRenderItem(button, index, data1)
		if data1.tIndex == 0 then
			local objectReference = button:GetComponent("ObjectReference")
			local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")

			ClientTextUtils.setText(txtTitleUSDFText, data1.title)
		elseif data1.tIndex == 1 then
			local objectReference = button:GetComponent("ObjectReference")
			local listItemUList = objectReference:GetRefValue("listItemUList")

			function listItemUList.luaRenderItem(b, i, d)
				local objectReference1 = b:GetComponent("ObjectReference")
				local txtUSDFText = objectReference1:GetRefValue("txtUSDFText")
				local iconUImage = objectReference1:GetRefValue("iconUImage")

				ClientTextUtils.setText(txtUSDFText, d.name)

				iconUImage.url = d.icon

				if d.size then
					iconUImage:SetSize(Vector2(d.size, d.size))
				end

				b.isSelected = self.filter[d.key]

				b:TryChangePage("button", self.filter[d.key] and 5 or 0)

				function b.luaClick()
					innerClick1(b, d.key)
				end
			end

			listItemUList:SetList(data1.btnGroups)
		elseif data1.tIndex == 2 or data1.tIndex == 3 then
			local objectReference = button:GetComponent("ObjectReference")
			local listItemUList = objectReference:GetRefValue("listItemUList")

			function listItemUList.luaRenderItem(b, i, d)
				local objectReference1 = b:GetComponent("ObjectReference")
				local iconUImage = objectReference1:GetRefValue("iconUImage")

				iconUImage.url = d.icon

				if d.size then
					iconUImage:SetSize(Vector2(d.size, d.size))
				end

				local selectedKey = d.name or d.id

				if d.key then
					if string.find(d.key, "isFavoriteType") then
						b:TryChangePage("Type", 2)
					else
						b:TryChangePage("Type", 0)
					end

					b.isSelected = self.filter[d.key]

					b:TryChangePage("button", self.filter[d.key] and 5 or 0)
				else
					b:TryChangePage("Type", 1)

					b.isSelected = self.filter.elements[selectedKey] ~= nil

					b:TryChangePage("button", self.filter.elements[selectedKey] ~= nil and 5 or 0)
				end

				function b.luaClick()
					if d.key then
						innerClick1(b, d.key)
					else
						innerClick2(b, selectedKey)
					end
				end

				if data1.tIndex == 3 then
					local imgBgImagePro = objectReference1:GetRefValue("imgBgImagePro")

					imgBgImagePro:SetColorWithHtmlString(d.iconColor)
				end
			end

			listItemUList:SetList(data1.elementGroups)
		elseif data1.tIndex == 4 then
			self:renderPriceFilter(button, index, data1)
		end
	end

	self.view.filterList:SetList(data)
end

function PetManagementFilterCtrl:renderPriceFilter(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local inputMinUTMPInputField = objectReference:GetRefValue("inputMinUTMPInputField")
	local inputMaxUTMPInputField = objectReference:GetRefValue("inputMaxUTMPInputField")
	local doubleSliderUDoubleSlider = objectReference:GetRefValue("doubleSliderUDoubleSlider")
	local txtLimitUSDFText = objectReference:GetRefValue("txtLimitUSDFText")

	ClientTextUtils.setText(txtLimitUSDFText, pg.getGameString("MORE_THAN"))
	button:TryChangePage("TagUnlimited", self.filter.isPriceOver and 1 or 0)

	local minPrice = self.filter.minPrice or data.minPriceLimit
	local maxPrice = self.filter.maxPrice or data.maxPriceLimit

	inputMinUTMPInputField:SetTextWithoutNotify(minPrice)

	function inputMinUTMPInputField.luaValueChanged(txt)
		local number = tonumber(txt)

		if not number then
			return
		end

		self.filter.minPrice = number
		doubleSliderUDoubleSlider.enableValueChangedCallback = false
		doubleSliderUDoubleSlider.lowerValue = number
		doubleSliderUDoubleSlider.enableValueChangedCallback = true

		self:checkBotButtonsStatus()
	end

	inputMaxUTMPInputField:SetTextWithoutNotify(maxPrice)

	function inputMaxUTMPInputField.luaValueChanged(txt)
		local number = tonumber(txt)

		if not number then
			return
		end

		self.filter.maxPrice = number
		self.filter.isPriceOver = number > data.maxPriceLimit

		button:TryChangePage("TagUnlimited", self.filter.isPriceOver and 1 or 0)

		doubleSliderUDoubleSlider.enableValueChangedCallback = false
		doubleSliderUDoubleSlider.upperValue = self.filter.isPriceOver and data.maxPriceLimit + 1 or number
		doubleSliderUDoubleSlider.enableValueChangedCallback = true

		self:checkBotButtonsStatus()
	end

	doubleSliderUDoubleSlider.minValue = data.minPriceLimit
	doubleSliderUDoubleSlider.maxValue = data.maxPriceLimit + 1
	doubleSliderUDoubleSlider.enableValueChangedCallback = false
	doubleSliderUDoubleSlider.lowerValue = minPrice
	doubleSliderUDoubleSlider.upperValue = self.filter.isPriceOver and data.maxPriceLimit + 1 or maxPrice
	doubleSliderUDoubleSlider.enableValueChangedCallback = true
	doubleSliderUDoubleSlider.stepSize = 1

	function doubleSliderUDoubleSlider.luaLowerValueChanged(val)
		inputMinUTMPInputField:SetTextWithoutNotify(val)

		self.filter.minPrice = val

		self:checkBotButtonsStatus()
	end

	function doubleSliderUDoubleSlider.luaUpperValueChanged(val)
		local newVal = val

		if val > data.maxPriceLimit then
			newVal = data.maxPriceLimit

			button:TryChangePage("TagUnlimited", 1)

			self.filter.isPriceOver = true
		else
			button:TryChangePage("TagUnlimited", 0)

			self.filter.isPriceOver = false
		end

		inputMaxUTMPInputField:SetTextWithoutNotify(newVal)

		self.filter.maxPrice = newVal

		self:checkBotButtonsStatus()
	end
end

function PetManagementFilterCtrl:setAllSortOptions()
	function self.view.sortOptionList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtTypeUText = objectReference:GetRefValue("txtTypeUText")
		local btnSwitchUButton = objectReference:GetRefValue("btnSwitchUButton")

		ClientTextUtils.setText(txtTypeUText, data.name)

		button.isSelected = self.sortId == data.idx

		button:TryChangePage("button", self.sortId == data.idx and 5 or 0)
		btnSwitchUButton:TryChangePage("Sort", self.isDescending and 0 or 1)

		function button.luaClick()
			if self.sortId == data.idx then
				self.isDescending = not self.isDescending

				btnSwitchUButton:TryChangePage("Sort", self.isDescending and 0 or 1)
				self:checkBotButtonsStatus()

				return
			end

			self:deselectAllSortOptions()

			button.isSelected = true

			button:TryChangePage("button", 5)

			self.sortId = data.idx

			btnSwitchUButton:TryChangePage("Sort", self.isDescending and 0 or 1)
			self:checkBotButtonsStatus()
		end
	end

	self.view.sortOptionList:SetList(self.model:getAllSortsInfo(self.inVitality, self.filterType))
end

function PetManagementFilterCtrl:deselectAllSortOptions()
	local btns = self.view.sortOptionList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		btns[i].isSelected = false

		btns[i]:TryChangePage("button", 0)
	end
end

function PetManagementFilterCtrl:deselectAllFilters()
	local btns = self.view.filterList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		local tIndex = btns[i].dataFromUList.tIndex

		if tIndex == 1 or tIndex == 2 or tIndex == 3 then
			local objectReference = btns[i]:GetComponent("ObjectReference")
			local listItemUList = objectReference:GetRefValue("listItemUList")
			local btns1 = listItemUList:GetAllButtons()

			for j = 0, btns1.Length - 1 do
				btns1[j].isSelected = false

				btns1[j]:TryChangePage("button", 0)
			end
		end
	end
end

function PetManagementFilterCtrl:doFilter()
	if not self.isAutoFilter and not self.disableSessionCache then
		PetManagementFilterModel.saveSessionState(self.filterType, self.filter, self.sortId, self.isDescending)
	end

	if self.doFilterCallback then
		self.doFilterCallback(self.filter, self.sortId, self.isDescending, self.showLabelInfo)
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_TOWER_STAGE_INFO) then
		pg.global.ui.towerStageInfo.petFilterUIComponent:startFilter()
	end

	self:closePanel()
end

function PetManagementFilterCtrl:clearSort()
	self.sortId = 0
	self.isDescending = true

	self:deselectAllSortOptions()
end

function PetManagementFilterCtrl:clearFilter()
	self.filter = {
		isEnergy = false,
		isRating1 = false,
		isClimb = false,
		keyword = "",
		isInExplore = false,
		isNotInBattle = false,
		isInBattle = false,
		isNone = false,
		isRating4 = false,
		isRating3 = false,
		isRating2 = false,
		isSwim = false,
		isGlide = false,
		isBreak = false,
		isHeal = false,
		isSup = false,
		isDPS = false,
		isFavoriteType10 = false,
		isFavoriteType9 = false,
		isFavoriteType8 = false,
		isFavoriteType7 = false,
		isFavoriteType6 = false,
		isFavoriteType5 = false,
		isFavoriteType4 = false,
		isFavoriteType3 = false,
		isFavoriteType2 = false,
		isFavoriteType1 = false,
		isFavoriteType0 = false,
		isDark = false,
		isRainbow = false,
		isBoss = false,
		isShiny = false,
		isNormal = false,
		filterType = self.filterType,
		elements = {}
	}

	self:deselectAllFilters()
end

function PetManagementFilterCtrl:checkBotButtonsStatus()
	local noSort = true

	if self.sortId > 0 and self.sortId <= 7 then
		noSort = false
	elseif self.sortId == 9 then
		noSort = false
	elseif self.sortId == 10 then
		noSort = false
	elseif self.inVitality and self.sortId == 8 then
		noSort = false
	end

	local noFilter = true

	for k, v in pairs(self.filter) do
		if k == "keyword" then
			if not string.isNilOrEmpty(v) then
				noFilter = false

				break
			end
		elseif k == "elements" then
			if next(v) ~= nil then
				noFilter = false

				break
			end
		elseif k == "minPrice" or k == "maxPrice" then
			if v ~= nil then
				noFilter = false

				break
			end
		elseif v == true then
			noFilter = false

			break
		end
	end

	if noSort and noFilter then
		self.view.cleanBtn.interactable = false
		self.view.confirmBtn.interactable = self.filterType == UIConst.PET_SLOT_DISPLAY_TYPE.TradeMarketPetOverview or self.filterType == UIConst.PET_SLOT_DISPLAY_TYPE.TradeMarketPet
	else
		self.view.cleanBtn.interactable = true
		self.view.confirmBtn.interactable = true
	end
end

return PetManagementFilterCtrl
