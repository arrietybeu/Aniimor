-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Config\\ConfigCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ConfigCtrl = Class.LightClass("ConfigCtrl", UICtrl)
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local rectTransformUtility = CS.UnityEngine.RectTransformUtility
local GmToolUtils = require("Utils.GmToolUtils")
local UIConst = require("Const.UIConst")
local TimerManager = require("Core.Timer.TimerManager")
local ClientTextUtils = require("Utils.ClientTextUtils")

ConfigCtrl.messages = {
	[MessageName.HIDDEN_UI] = {
		"closeUI",
		true
	}
}
ConfigCtrl.version = "version001"

function ConfigCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.defaultPetListHeight = 1616
	self.defaultPetListHeightDiff = 64
	self.oneScreenPetListSize = 21
	self.lastSearchValue = ""

	if not GmToolUtils.hasInitGmList then
		GmToolUtils.getGmList()
	end

	pg.global.ui:close(UIConst.UI_ID_CONFIG_TOPPING)

	local gmToppingNamesStr = pg.global.prefsCacheUtils:getString("gmToppingNames", "")

	if string.sub(gmToppingNamesStr, 1, 10) ~= ConfigCtrl.version then
		pg.global.prefsCacheUtils:setString("gmToppingNames", ConfigCtrl.version)
	end

	self.uiCamera = CS.XGUI.UWidget.uiCamera
	self.uiCamera.enabled = true
	self.rootComponent = self.view.transform:GetComponent("UComponent")
	self.curTypeIndex = 3

	if info and info.selectedIndex then
		for index, item in ipairs(GmToolUtils.gmFuncMap) do
			if item.label == info.selectedIndex then
				self.curTypeIndex = index

				break
			end
		end
	end

	self:refreshGmList()
	self:initSearch()
	self.view.btnSearchSwitchUButton:TryChangePage("active", GmToolUtils.checkSearchState() and 0 or 1)
end

function ConfigCtrl:closeUI()
	self:dismiss()
end

function ConfigCtrl:refreshGmList()
	self:initFuncTypeList()
	self:initFuncList()
end

function ConfigCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_CONFIG_TOPPING)
		self:dismiss()
	end

	function self.view.searchInputUInputField.luaValueChanged(value)
		if value == self.lastSearchValue then
			return
		end

		self.lastSearchValue = value

		if self.searchTimer then
			self:killTimer(self.searchTimer)

			self.searchTimer = nil
		end

		self.searchTimer = self:startTimer(function()
			local itemData = self:GetFuncListItemData()

			self.view:refreshFuncList(itemData)

			local showHistory = value == "" and 1 or 0

			self.view.inputUComponent:TryChangePage("History", showHistory)
		end, 0.3)
	end

	function self.view.sliderUSlider.luaValueChanged(alpha)
		self.view.uIPbConfigUComponent.renderOpacity = alpha
	end

	function self.view.btnSearchSwitchUButton.luaClick()
		GmToolUtils.setFullSearch(not GmToolUtils.fullSearch)

		local itemData = self:GetFuncListItemData()

		self.view:refreshFuncList(itemData)
	end
end

function ConfigCtrl:onDestroy()
	pgI18N.LocalizationText.ClearFixedLanguageCache()
	UICtrl.onDestroy(self)
end

function ConfigCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function ConfigCtrl:onShow()
	return
end

function ConfigCtrl:onHide()
	return
end

function ConfigCtrl:initFuncTypeList()
	if not GmToolUtils.hasInitGmList then
		return
	end

	function self.view.listUList.luaRenderItem(button, index, data)
		button:TryChangePage("Type", data.type)
	end

	local itemData = {}

	for idx, info in pairs(GmToolUtils.gmFuncMap) do
		local item = {}

		item.label = GmToolUtils.getGmGameString(info.label)
		item.type = info.type
		item.tIndex = 0
		item.state = 0
		itemData[#itemData + 1] = item
	end

	if self.view then
		function self.view.listUList.luaClick(button, data)
			local curTypeIndex = self.view.listUList:GetChildIndex(button) + 1

			self.curTypeIndex = curTypeIndex

			local itemData = self:GetFuncListItemData()

			self.view:refreshFuncList(itemData)
		end

		self.view:refreshFuncTypeList(itemData)

		self.funcTypeItemData = itemData

		self:RefreshFuncTypeListState(self.curTypeIndex)
	end
end

function ConfigCtrl:initFuncList()
	if not GmToolUtils.hasInitGmList then
		return
	end

	function self.view.itemListUList.luaRenderItem(button, index, data)
		self:luaRenderItem(button, index, data)
	end

	self:refreshFuncList()
end

function ConfigCtrl:refreshFuncList()
	local itemData = self:GetFuncListItemData()

	if self.view then
		self.view:refreshFuncList(itemData)
	end
end

function ConfigCtrl:GetCurTypeIndex()
	local _, min, max = self.view.itemListUList:TryGetVisualRange()
	local index = math.min(min + 1, max)
	local curTypeIndex = 1

	for i = 1, #self.funcTypeStartIndexs do
		if i == #self.funcTypeStartIndexs then
			curTypeIndex = i
		elseif index >= self.funcTypeStartIndexs[i] and index < self.funcTypeStartIndexs[i + 1] then
			curTypeIndex = i

			break
		end
	end

	return curTypeIndex
end

function ConfigCtrl:RefreshFuncTypeListState(curTypeIndex)
	if self.curTypeIndex ~= -1 then
		local item = self.funcTypeItemData[self.curTypeIndex]

		item.selected = false

		self.view.listUList:SetElement(self.curTypeIndex - 1, item)
	end

	local newSelectDara = self.funcTypeItemData[curTypeIndex]

	newSelectDara.selected = true

	self.view.listUList:SetElement(curTypeIndex - 1, newSelectDara)

	self.curTypeIndex = curTypeIndex
end

function ConfigCtrl:luaRenderItem(button, index, data)
	local subList = button:GetChild("List")

	if subList then
		local ulist = subList:GetComponent("UList")

		if data.tIndex == 1 and #data.items > 0 then
			function ulist.luaRenderItem(button, index, data)
				if data.state == 3 then
					self:setItemInteractable(button, false)
				end

				if data.tIndex == 0 then
					local switchButton = button:GetChild("BtnSwitch"):GetComponent("UButton")

					switchButton:TryChangePage("active", data.selected and 0 or 1)

					function switchButton.luaClick()
						if data.func then
							local _, page = switchButton:TryGetCurrentPage("active")

							GmToolUtils.execFunc(data, page == 1)
						end
					end
				elseif data.tIndex == 1 then
					local selectorIns = button:GetChild("SelectorSort")

					if selectorIns then
						local selector = selectorIns:GetComponent("USelector")

						selector.options = data.itemData

						selector:RefreshOptions()
						selector:RefreshSelector()

						function selector.luaOptionClick(optionButton, optionData)
							local func = data.func

							if func then
								if data.cmdName then
									GmToolUtils.execFunc(data, data.cmdName, optionData)
								else
									GmToolUtils.execFunc(data, optionData)
								end
							end
						end

						if data.selectedFun then
							selector:ForceSelect(GmToolUtils[data.selectedFun]())
						else
							selector.selectedIndex = -1

							ClientTextUtils.setText(selector:GetChild("PlaceHolder"):GetComponent("UBaseText"), "")
						end
					end
				elseif data.tIndex == 2 then
					local confirmButton = button:GetChild("BtnConfirm"):GetComponent("UButton")

					if data.buttonText then
						ClientTextUtils.setText(confirmButton:GetChild("TxtName"), data.buttonText)
					end

					function confirmButton.luaClick()
						if data.func then
							if data.cmdName then
								GmToolUtils.execFunc(data, data.cmdName)
							else
								GmToolUtils.execFunc(data)
							end
						end
					end
				end

				button:TryChangePage("State", data.state)

				function button.luaDrag()
					self:itemDrag(button)
				end

				function button.luaEndDrag(dropWidget)
					self:itemDragEnd(button, data)
				end

				self:itemLongPressHandle(button, data)
			end

			ulist:SetList(data.items)
		elseif data.tIndex == 2 and #data.items > 0 then
			function ulist.luaRenderItem(button2, index2, data2)
				if data2.tIndex == 0 then
					local input = button2:GetChild("InputField"):GetComponent("UTMPInputField")

					input.luaValueChanged = nil

					ClientTextUtils.setText(input:Find("PlaceHolder"), data2.tips or "")
					ClientTextUtils.setText(input, data2.defaultValue or "")

					local confirmButton = button2:GetChild("BtnConfirm"):GetComponent("UButton")

					function input.luaValueChanged(value)
						local canExec = self:CheckInput({
							[0] = button2
						}, {
							data2
						})

						self:setItemInteractable(button2, canExec)
						self:TryChangeInputPage(input, data2)
					end

					self:registerInputFieldEvent(input, data2)

					function confirmButton.luaClick()
						if data2.func then
							if data2.cmdName then
								GmToolUtils.execFunc(data2, data2.cmdName, {
									[0] = button2
								})
							else
								GmToolUtils.execFunc(data2, {
									[0] = button2
								})
							end
						end
					end

					self:setItemInteractable(button2, self:CheckInput({
						[0] = button2
					}, {
						data2
					}))
				end

				if data2.state == 3 then
					self:setItemInteractable(button2, false)
				end

				button2:TryChangePage("State", data2.state)

				function button2.luaDrag()
					self:itemDrag(button2)
				end

				function button2.luaEndDrag(dropWidget)
					self:itemDragEnd(button2, data2)
				end

				self:itemLongPressHandle(button2, data2)
			end

			ulist:SetList(data.items)
		elseif data.tIndex == 4 and data.itemData then
			local function renderImageItem(button2, index2, data2)
				local icon = button2:Find("Mask/Icon"):GetComponent("UImage")

				if UNITY_EDITOR and data2.prefabResId then
					pgUtils.SetPrefabPreview(icon, data2.prefabResId)
				else
					icon.url = data2.iconUrl
				end

				ClientTextUtils.setText(button2:Find("TxtID"):GetComponent("UBaseText"), data2.id)

				function button2.luaRenderTooltip(subButton, popup)
					local popUList = popup:GetChild("List"):GetComponent("UList")

					function popUList.luaRenderItem(subButton2, subIndex, subData2)
						if subData2.tIndex == 0 then
							local input = subButton2:GetChild("InputField"):GetComponent("UTMPInputField")

							input.luaValueChanged = nil

							ClientTextUtils.setText(input:Find("PlaceHolder"), subData2.tips or "")
							ClientTextUtils.setText(input, subData2.defaultValue or "")

							function input.luaValueChanged(value)
								local canExec = self:CheckInput(popUList:GetAllButtons(), data.subItems)

								self:setItemInteractable(popup, canExec)
								self:TryChangeInputPage(input, subData2)
							end

							self:registerInputFieldEvent(input, subData2)
						end
					end

					popUList:SetList(data.subItems)
					self:setItemInteractable(popup, self:CheckInput(popUList:GetAllButtons(), data.subItems))

					popup:GetChild("BtnConfirm"):GetComponent("UButton").luaClick = function()
						if data.func then
							GmToolUtils.execFunc(data, data2, popUList:GetAllButtons())
						end
					end
				end

				function button2.luaTooltipPopup(subButton, isOpen)
					subButton:TryChangePage("Check", isOpen and 2 or 0)
				end
			end

			ulist.luaRenderItem = renderImageItem

			function ulist.luaFinishRender()
				self:startTimer(function()
					button:SetSizeY(self.defaultPetListHeight)
				end, 0.1)
			end

			local uListSearch = button:GetChild("ListSearch"):GetComponent("UList")

			uListSearch.luaRenderItem = renderImageItem

			function uListSearch.luaFinishRender(uListSearch_)
				self:startTimer(function()
					button:SetSizeY(uListSearch_.rectTransform.rect.size.y + self.defaultPetListHeightDiff)
				end, 0.1)
			end

			local useSearchList = #data.itemData < self.oneScreenPetListSize

			ulist.gameObject:SetActiveEx(not useSearchList)
			uListSearch.gameObject:SetActiveEx(useSearchList)

			if useSearchList then
				uListSearch:SetList(data.itemData)
			else
				ulist:SetList(data.itemData)
			end
		elseif data.tIndex == 3 and #data.subItems > 0 then
			local confirmButton = button:GetChild("BtnConfirm"):GetComponent("UButton")

			function ulist.luaRenderItem(subButton, index, data2)
				if data2.tIndex == 1 then
					local selectorIns = subButton:GetChild("SelectorSort")

					if selectorIns then
						local selector = selectorIns:GetComponent("USelector")

						selector.options = data2.itemData

						selector:RefreshOptions()
						selector:RefreshSelector()

						function selector.luaOptionClick(optionButton, optionData)
							local func = data2.func

							if func then
								if data2.cmdName then
									GmToolUtils.execFunc(data2, data2.cmdName, optionData)
								else
									GmToolUtils.execFunc(data2, optionData)
								end
							end
						end

						if data2.selectedFun then
							selector:ForceSelect(GmToolUtils[data2.selectedFun]())
						else
							selector.selectedIndex = -1
						end
					end
				elseif data2.tIndex == 0 or data2.tIndex == 4 or data2.tIndex == 7 then
					local input = subButton:GetChild("InputField"):GetComponent("UTMPInputField")

					input.luaValueChanged = nil

					ClientTextUtils.setText(input:Find("PlaceHolder"), data2.tips or "")
					ClientTextUtils.setText(input, data2.defaultValue or "")

					function input.luaValueChanged(value)
						local canExec = self:CheckInput(ulist:GetAllButtons(), data.subItems)

						self:setItemInteractable(button, canExec)
						self:TryChangeInputPage(input, data2)
					end

					self:registerInputFieldEvent(input, data2)

					local configButton = subButton:GetChild("BtnConfirm")

					if configButton and data2.func then
						configButton = configButton:GetComponent("UButton")

						configButton:SetActive(true)

						function configButton.luaClick()
							GmToolUtils.execFunc(data2, input.text)
						end
					elseif configButton then
						configButton.gameObject:SetActiveEx(false)
					end
				elseif data2.tIndex == 2 then
					local switchButton = subButton:GetChild("BtnSwitch"):GetComponent("UButton")

					switchButton:TryChangePage("active", data2.selected and 0 or 1)

					function switchButton.luaClick()
						if data2.func then
							local _, page = switchButton:TryGetCurrentPage("active")

							GmToolUtils[data2.func](page == 1)
						end
					end
				elseif data2.tIndex == 3 then
					local confirmButton = subButton:GetChild("BtnConfirm"):GetComponent("UButton")
					local input = subButton:GetChild("InputField"):GetComponent("UTMPInputField")

					function confirmButton.luaClick()
						UIUtils.ClipboardWriter(input.text)
						pg.global.ui.tips:showTextTip(GmToolUtils.getGmGameString("GM_TOAST_COPY_SUCCESS"))
					end
				elseif data2.tIndex == 5 then
					local bugImageList = subButton:GetChild("List"):GetComponent("UList")

					local function refreshBugImageList()
						local bugImages = {}

						for _, sprite in ipairs(GmToolUtils.bugReportImageList) do
							table.insert(bugImages, {
								tIndex = 0,
								sprite = sprite
							})
						end

						table.insert(bugImages, {
							tIndex = 1
						})
						bugImageList:SetList(bugImages)
					end

					function bugImageList.luaRenderItem(button3, index3, data3)
						if data3.tIndex == 0 then
							button3:GetChild("BugImage"):GetComponent("UImage").sprite = data3.sprite
							button3:GetChild("Del"):GetComponent("UButton").luaClick = function()
								local sprite = table.remove(GmToolUtils.bugReportImageList, index3 + 1)

								if sprite then
									pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)
								end

								refreshBugImageList()
							end
						elseif data3.tIndex == 1 then
							button3:GetChild("AddButton"):GetComponent("UButton").luaClick = function()
								self:dismiss()
								pg.global.ui:open(UIConst.UI_ID_CONFIG_TOPPING, {
									showCapture = true
								})
							end
						end
					end

					refreshBugImageList()
				elseif data2.tIndex == 6 then
					local slider = subButton:GetChild("Slider"):GetComponent("USlider")
					local sliderText = subButton:GetChild("Text"):GetComponent("UBaseText")

					slider.luaValueChanged = nil
					slider.minValue = data2.minValue
					slider.maxValue = data2.maxValue
					slider.value = data2.curValue
					slider.stepSize = data2.step

					if slider.stepSize == 1 then
						ClientTextUtils.setText(sliderText, string.format("%d", data2.curValue))
					else
						ClientTextUtils.setText(sliderText, string.format("%.1f", data2.curValue))
					end

					function slider.luaValueChanged(value)
						if data2.func then
							GmToolUtils[data2.func](value, data2.funcParam)
						end

						if slider.stepSize == 1 then
							ClientTextUtils.setText(sliderText, string.format("%d", value))
						else
							ClientTextUtils.setText(sliderText, string.format("%.1f", value))
						end
					end
				end
			end

			if data.state == 3 then
				self:setItemInteractable(button, false)
			end

			function confirmButton.luaClick()
				if data.func then
					if data.cmdName then
						GmToolUtils.execFunc(data, data.cmdName, ulist:GetAllButtons())
					else
						GmToolUtils.execFunc(data, ulist:GetAllButtons())
					end
				end
			end

			if data.buttonText then
				ClientTextUtils.setText(confirmButton:GetChild("TxtName"), data.buttonText)
			end

			button:TryChangePage("State", data.state)

			function button.luaDrag()
				self:itemDrag(button)
			end

			function button.luaEndDrag(dropWidget)
				self:itemDragEnd(button, data)
			end

			ulist:SetList(data.subItems)
			self:setItemInteractable(button, self:CheckInput(ulist:GetAllButtons(), data.subItems))
			self:itemLongPressHandle(button, data)
		end
	end
end

function ConfigCtrl:checkSearch(labelValue, filterString)
	local start = string.find(labelValue, "<localizationidtag")

	if start and start > 0 then
		labelValue = string.sub(labelValue, 1, start - 1)
	end

	local filterTable = string.split(filterString, " ")

	for _, filter in ipairs(filterTable) do
		if not string.find(labelValue, filter) then
			return false
		end
	end

	return true
end

function ConfigCtrl:checkGmFuncShow(info)
	local showFunc = info and info.showFunc

	if not showFunc then
		return true
	end

	if not GmToolUtils[showFunc] then
		return false
	end

	return GmToolUtils[showFunc]()
end

function ConfigCtrl:GetFuncListItemData()
	self.funcTypeStartIndexs = {}

	local filterString = string.lower(self.view.searchInputUInputField.text)
	local itemData = {}
	local gmToppingNamesStr = pg.global.prefsCacheUtils:getString("gmToppingNames", "")
	local gmToppingNames = string.split(gmToppingNamesStr, "|")

	local function parseFunc(idx, infoSet)
		if idx == self.curTypeIndex or GmToolUtils.fullSearch and filterString and filterString ~= "" then
			local tempItemData = {}

			self.funcTypeStartIndexs[#self.funcTypeStartIndexs + 1] = #itemData

			local twoCellSet = {}

			twoCellSet.tIndex = 2
			twoCellSet.items = {}

			local threeCellSet = {}

			threeCellSet.tIndex = 1
			threeCellSet.items = {}

			local curStyle = -1

			for idx2, info in pairs(infoSet.funcList) do
				local labelValue = GmToolUtils.getGmGameString(info.label)

				if info.cmdName then
					labelValue = labelValue .. " - " .. info.cmdName
				end

				if self:checkGmFuncShow(info) and (info.subSearch or filterString == nil or filterString == "" or self:checkSearch(string.lower(labelValue), filterString)) then
					curStyle = info.style

					local item = {}

					item.originInfo = info
					item.label = labelValue
					item.func = info.func
					item.cmdName = info.cmdName

					local toppingKey = info.cmdName or info.label

					item.state = table.contains(gmToppingNames, toppingKey) and 3 or 0

					if curStyle == 1 then
						item.tIndex = info.subStyle

						if info.subStyle == 0 then
							local checkFunc = info.checkFunc

							if checkFunc and GmToolUtils[checkFunc] then
								item.selected = GmToolUtils[checkFunc]()
							end
						elseif info.subStyle == 1 then
							local dataFunc = info.dataFunc

							item.itemData = GmToolUtils[dataFunc]()
							item.tips = GmToolUtils.getGmGameString(info.tips)
							item.selectedFun = info.selectedFun
						elseif info.subStyle == 2 then
							item.buttonText = GmToolUtils.getGmGameString(info.buttonText)
						end

						threeCellSet.items[#threeCellSet.items + 1] = item
					elseif curStyle == 2 then
						item.tIndex = info.subStyle
						item.tips = GmToolUtils.getGmGameString(info.tips)
						item.defaultValue = info.defaultValue
						item.saveKey = info.saveKey

						local saveDefaultValue = GmToolUtils.getDefaultValue(info)

						if saveDefaultValue and saveDefaultValue ~= "" then
							item.defaultValue = saveDefaultValue
						end

						item.paramType = info.paramType
						twoCellSet.items[#twoCellSet.items + 1] = item
					elseif curStyle == 3 or curStyle == 4 then
						item.tIndex = info.style
						item.buttonText = GmToolUtils.getGmGameString(info.buttonText)

						if info.dataFunc then
							local itemData = GmToolUtils[info.dataFunc]() or {}

							if filterString == nil or filterString == "" then
								item.itemData = itemData
							else
								item.itemData = {}

								for i = 1, #itemData do
									local label = itemData[i].label

									if type(label) ~= "string" then
										label = tostring(label)
									end

									label = string.lower(label)

									local id = itemData[i].id

									if type(id) ~= "string" then
										id = tostring(id)
									end

									id = string.lower(id)

									if self:checkSearch(label, filterString) or self:checkSearch(id, filterString) then
										item.itemData[#item.itemData + 1] = itemData[i]
									end
								end
							end
						end

						item.subItems = {}

						for _, subItemInfo in pairs(info.subItems) do
							local subItem = {}

							subItem.label = GmToolUtils.getGmGameString(subItemInfo.label)
							subItem.tIndex = subItemInfo.style
							subItem.tips = GmToolUtils.getGmGameString(subItemInfo.tips)
							subItem.id = subItemInfo.id
							subItem.paramType = subItemInfo.paramType
							subItem.defaultValue = subItemInfo.defaultValue
							subItem.saveKey = subItemInfo.saveKey
							subItem.selectedFun = subItemInfo.selectedFun

							local saveDefaultValue = GmToolUtils.getDefaultValue(subItemInfo)

							if saveDefaultValue and saveDefaultValue ~= "" then
								subItem.defaultValue = saveDefaultValue
							end

							subItem.func = subItemInfo.func

							if subItemInfo.style == 1 then
								local dataFunc = subItemInfo.dataFunc

								subItem.itemData = GmToolUtils[dataFunc]()
							elseif subItemInfo.style == 2 then
								local checkFunc = subItemInfo.checkFunc

								if checkFunc then
									subItem.selected = GmToolUtils[checkFunc]()
								end
							elseif subItemInfo.style == 6 then
								subItem.minValue = subItemInfo.minValue
								subItem.maxValue = subItemInfo.maxValue
								subItem.curValue = subItemInfo.minValue
								subItem.step = subItemInfo.step or 0.1
								subItem.funcParam = subItemInfo.funcParam

								if subItemInfo.getValueFunc then
									subItem.curValue = GmToolUtils[subItemInfo.getValueFunc](subItemInfo.funcParam)
								end
							end

							item.subItems[#item.subItems + 1] = subItem
						end

						if item.itemData and #item.itemData > 0 and self.curTypeIndex == 1 then
							local itemTitle = {}

							itemTitle.label = item.label
							itemTitle.tIndex = 0
							tempItemData[#tempItemData + 1] = itemTitle
						end

						if item.itemData == nil or #item.itemData > 0 then
							tempItemData[#tempItemData + 1] = item
						end
					end
				end
			end

			if #tempItemData > 0 or #twoCellSet.items > 0 or #threeCellSet.items > 0 then
				if GmToolUtils.fullSearch and filterString and filterString ~= "" then
					local itemTitle = {}

					itemTitle.label = GmToolUtils.getGmGameString(infoSet.label)
					itemTitle.tIndex = 0
					itemData[#itemData + 1] = itemTitle
				end

				if #twoCellSet.items > 0 then
					itemData[#itemData + 1] = twoCellSet
				end

				if #threeCellSet.items > 0 then
					itemData[#itemData + 1] = threeCellSet
				end

				for i = 1, #tempItemData do
					if tempItemData[i].tIndex == 3 then
						itemData[#itemData + 1] = tempItemData[i]
					end
				end

				for i = 1, #tempItemData do
					if tempItemData[i].tIndex ~= 3 then
						itemData[#itemData + 1] = tempItemData[i]
					end
				end
			end
		end
	end

	local infoSet = GmToolUtils.gmFuncMap[self.curTypeIndex]

	if infoSet then
		parseFunc(self.curTypeIndex, infoSet)
	end

	for idx, infoSet in pairs(GmToolUtils.gmFuncMap) do
		if idx ~= self.curTypeIndex then
			parseFunc(idx, infoSet)
		end
	end

	return itemData
end

function ConfigCtrl:itemDrag(button)
	local inArea = rectTransformUtility.RectangleContainsScreenPoint(self.view.itemListUList.rectTransform, UnityInput.mousePosition, self.uiCamera)

	button.replicaWidget:GetComponent("UComponent"):TryChangePage("State", inArea and 0 or 1)
end

function ConfigCtrl:itemDragEnd(button, data)
	local inArea = rectTransformUtility.RectangleContainsScreenPoint(self.view.itemListUList.rectTransform, UnityInput.mousePosition, self.uiCamera)

	if not inArea then
		local gmToppingNames = pg.global.prefsCacheUtils:getString("gmToppingNames", "")
		local key = data.cmdName or data.originInfo.label

		if not string.find(gmToppingNames, key) then
			pg.global.prefsCacheUtils:setString("gmToppingNames", gmToppingNames .. "|" .. key)
			GmToolUtils.addRecentlyUse(data)
			button:TryChangePage("State", 3)
			self:setItemInteractable(button, false)
		end
	end
end

function ConfigCtrl:itemLongPressHandle(button, data)
	function button.luaBeginLongPress()
		local hasAdd = false

		for idx2, info in pairs(GmToolUtils.gmFuncMap[2].funcList) do
			if info.label == data.originInfo.label then
				hasAdd = true

				break
			end
		end

		button:TryChangePage("Favorite", hasAdd and 2 or 0)
	end

	button:GetChild("BtnFavorite"):GetComponent("UButton").luaClick = function()
		GmToolUtils.gmFuncMap[2].funcList[#GmToolUtils.gmFuncMap[2].funcList + 1] = data.originInfo

		local key = data.cmdName or data.label
		local gmFavoriteStr = pg.global.prefsCacheUtils:getString("gmFavorite", "")

		pg.global.prefsCacheUtils:setString("gmFavorite", gmFavoriteStr .. "|" .. key)
		button:TryChangePage("Favorite", 1)
		pg.global.ui.tips:showTextTip(GmToolUtils.getGmGameString("GM_TOAST_ADD_SUCCESS"))
	end
	button:GetChild("BtnUnFavorite"):GetComponent("UButton").luaClick = function()
		local dataIndex = -1

		for index, info in ipairs(GmToolUtils.gmFuncMap[2].funcList) do
			if info.label == data.originInfo.label then
				dataIndex = index

				break
			end
		end

		if dataIndex ~= -1 then
			table.remove(GmToolUtils.gmFuncMap[2].funcList, dataIndex)
		end

		local key = data.cmdName or data.label
		local gmFavoriteStr = pg.global.prefsCacheUtils:getString("gmFavorite", "")
		local newstr = string.gsub(gmFavoriteStr, "|" .. key, "")

		pg.global.prefsCacheUtils:setString("gmFavorite", newstr)
		button:TryChangePage("Favorite", 1)
		pg.global.ui.tips:showTextTip(GmToolUtils.getGmGameString("GM_TOAST_REMOVE_SUCCESS"))

		local itemData = self:GetFuncListItemData()

		self.view:refreshFuncList(itemData)
	end
end

function ConfigCtrl:setItemInteractable(button, interactable)
	local confirmButton = button:GetChild("BtnConfirm")

	if confirmButton then
		confirmButton:GetComponent("UButton").interactable = interactable
	end

	local switchButton = button:GetChild("BtnSwitch")

	if switchButton then
		switchButton:GetComponent("UButton").interactable = interactable
	end

	local selector = button:GetChild("SelectorSort")

	if selector then
		selector:GetComponent("USelector").interactable = interactable
	end
end

function ConfigCtrl:CheckInput(inputButtons, dataList)
	local res = true

	for index, data in ipairs(dataList) do
		if data.tIndex == 0 then
			local input = inputButtons[index - 1]:GetChild("InputField"):GetComponent("UTMPInputField")
			local canExec = self:CheckInputSingle(input.text, data)

			res = res and canExec
		end
	end

	return res
end

function ConfigCtrl:CheckInputSingle(inputValue, data)
	if data.paramType == "string" and inputValue == "" then
		return false
	elseif data.paramType == "number" and tonumber(inputValue) == nil then
		return false
	end

	return true
end

function ConfigCtrl:TryChangeInputPage(input, data)
	local canExec = self:CheckInputSingle(input.text, data)

	input:TryChangePage("button", canExec and 3 or 5)

	data.checkFalse = not canExec
end

function ConfigCtrl:registerInputFieldEvent(uInput, data)
	function uInput.luaFocus()
		self:TrySetInputError(uInput, data)
	end

	function uInput.luaBlur()
		self:TrySetInputError(uInput, data)
		self:trySaveDefaultValue(uInput, data)
	end

	function uInput.luaHover()
		self:TrySetInputError(uInput, data)
	end

	function uInput.luaUnhover()
		self:TrySetInputError(uInput, data)
	end

	function uInput.luaClick()
		self:TrySetInputError(uInput, data)
	end
end

function ConfigCtrl:TrySetInputError(input, data)
	if data.checkFalse then
		input:TryChangePage("button", 5)
	end
end

function ConfigCtrl:trySaveDefaultValue(uInput, data)
	if data.saveKey and uInput.text ~= "" then
		pg.global.prefsCacheUtils:setString(data.saveKey, uInput.text)
	end
end

function ConfigCtrl:initSearch()
	function self.view.searchHistoryList.luaRenderItem(button, index, data)
		function button.luaPress()
			if data.tIndex == 0 then
				ClientTextUtils.setText(self.view.searchInputUInputField, data.label)
				self.view.inputUComponent:TryChangePage("History", 0)
			elseif data.tIndex == 1 then
				self.openAllHistory = true

				self.view.searchHistoryList:SetList(self:getSearchHistoryListData())
			end
		end
	end

	function self.view.searchInputUInputField.luaFocus()
		local _, page = self.view.inputUComponent:TryGetCurrentPage("History")

		if page == 1 then
			return
		end

		self.view.searchHistoryList:SetList(self:getSearchHistoryListData(7))
		self.view.inputUComponent:TryChangePage("History", 1)
	end

	function self.view.searchInputUInputField.luaBlur()
		self:startTimer(function()
			if self.openAllHistory then
				self.view.searchInputUInputField:Focus()

				self.openAllHistory = false

				return
			end

			self.view.inputUComponent:TryChangePage("History", 0)

			local searchText = self.view.searchInputUInputField.text

			if searchText == "" then
				return
			end

			local searchHistory = pg.global.prefsCacheUtils:getString("searchHistory", "")

			if string.find(searchHistory, searchText) then
				return
			end

			local newSearchHistory = searchHistory == "" and searchText or searchText .. "|" .. searchHistory

			pg.global.prefsCacheUtils:setString("searchHistory", newSearchHistory)
		end, 0.1)
	end
end

function ConfigCtrl:getSearchHistoryListData(maxNum)
	local searchHistory = pg.global.prefsCacheUtils:getString("searchHistory", "")
	local searchHistoryList = string.split(searchHistory, "|")

	maxNum = maxNum or #searchHistoryList

	local max = math.min(#searchHistoryList, maxNum)
	local data = {}

	for i = 1, max do
		if searchHistoryList[i] ~= "" then
			data[#data + 1] = {
				tIndex = 0,
				label = searchHistoryList[i]
			}
		end
	end

	if max < #searchHistoryList then
		data[#data + 1] = {
			tIndex = 1
		}
	end

	return data
end

return ConfigCtrl
