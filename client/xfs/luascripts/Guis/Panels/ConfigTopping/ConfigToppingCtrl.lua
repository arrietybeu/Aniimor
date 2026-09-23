-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ConfigTopping\\ConfigToppingCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ConfigToppingCtrl = Class.LightClass("ConfigToppingCtrl", UICtrl)
local AddressDataConst = require("Const.AddressDataConst")
local ClientConst = require("Const.ClientConst")
local rectTransformUtility = CS.UnityEngine.RectTransformUtility
local LuaUIUtils = require("Utils.LuaUIUtils")
local GmToolUtils = require("Utils.GmToolUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")

ConfigToppingCtrl.messages = {
	[MessageName.SET_GM_TOPPING_MASK] = {
		"setMaskState",
		true
	}
}

local uiMgr = pg.global.uiMgr
local uiRootTrans = uiMgr.uiRootCanvasTrans
local sceneLayerTrans = uiMgr.sceneLayer
local panelLayerTrans = uiMgr.panelLayer
local popupLayerTrans = uiMgr.popupLayer
local infosLayerTrans = uiMgr.infosLayer

function ConfigToppingCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.uiCamera = CS.XGUI.UWidget.uiCamera
	self.enterCursonMode = pg.game.input.cursorMode

	self:initView(info)
end

function ConfigToppingCtrl:initView(info)
	if info and info.showCapture then
		self.view.transform:Find("CaptureTip").gameObject:SetActiveEx(true)

		return
	end

	self:initToppingGM()
end

function ConfigToppingCtrl:initToppingGM()
	local gmToppingNamesStr = pg.global.prefsCacheUtils:getString("gmToppingNames", "")
	local gmToppingNames = string.split(gmToppingNamesStr, "|")

	for i = 3, #GmToolUtils.gmFuncMap do
		local infoSet = GmToolUtils.gmFuncMap[i]

		for idx2, info in pairs(infoSet.funcList) do
			local key = info.cmdName or info.label

			if table.contains(gmToppingNames, key) then
				self:renderItem(info)
			end
		end
	end
end

function ConfigToppingCtrl:renderItem(info)
	local resKey = ""

	if info.style == 1 then
		if info.subStyle == 0 then
			resKey = AddressDataConst.UI_Node_Config_ItemChoice_RES
		elseif info.subStyle == 1 then
			resKey = AddressDataConst.UI_Node_Config_ChoiceCell_RES
		elseif info.subStyle == 2 then
			resKey = AddressDataConst.UI_Node_Config_ItemRefresh_RES
		end
	elseif info.style == 2 then
		if info.subStyle == 0 then
			resKey = AddressDataConst.UI_Node_Config_Confirm_RES
		end
	elseif info.style == 3 then
		resKey = AddressDataConst.UI_Node_Config_ItemMutil_RES
	end

	if resKey == "" then
		return
	end

	self.view:addPrefabWithPathAsync(self.view.transform, resKey, function(item)
		if IsNil(item.gameObject) then
			return
		end

		if info.style == 3 and pg.global.ui:runPlatformByMobile() then
			local scale = item.transform.localScale

			item.transform.localScale = CS.UnityEngine.Vector3(scale.x * 0.7, scale.y * 0.7, scale.z * 0.7)
		end

		ClientTextUtils.setText(item.transform:Find("TxtName"):GetComponent("UBaseText"), GmToolUtils.getGmGameString(info.label))

		local button = item.transform:GetComponent("UButton")

		button.replicaSelf = false

		if info.style == 1 then
			if info.subStyle == 0 then
				local switchButton = button:GetChild("BtnSwitch"):GetComponent("UButton")

				switchButton:TryChangePage("active", GmToolUtils[info.checkFunc]() and 0 or 1)

				function switchButton.luaClick()
					if info.func then
						local _, page = switchButton:TryGetCurrentPage("active")

						GmToolUtils[info.func](page == 1)
					end
				end
			elseif info.subStyle == 1 then
				local selectorIns = button:GetChild("SelectorSort")

				if selectorIns and info.dataFunc then
					local selector = selectorIns:GetComponent("USelector")

					selector.options = GmToolUtils[info.dataFunc]()

					selector:RefreshOptions()
					selector:RefreshSelector()

					function selector.luaOptionClick(optionButton, optionData)
						local func = info.func

						if func then
							if info.cmdName then
								GmToolUtils[func](info.cmdName, optionData)
							else
								GmToolUtils[func](optionData)
							end
						end
					end
				end
			elseif info.subStyle == 2 then
				button:GetChild("BtnConfirm"):GetComponent("UButton").luaClick = function()
					if info.func then
						GmToolUtils[info.func](info.cmdName)
					end
				end
			end
		elseif info.style == 2 then
			if info.subStyle == 0 then
				local input = button:GetChild("InputField"):GetComponent("UTMPInputField")

				ClientTextUtils.setText(input:Find("PlaceHolder"), info.tips or "")
				ClientTextUtils.setText(input, info.defaultValue or "")

				local confirmButton = button:GetChild("BtnConfirm"):GetComponent("UButton")

				function confirmButton.luaClick()
					if info.func then
						if info.cmdName then
							GmToolUtils[info.func](info.cmdName, {
								[0] = button
							})
						else
							GmToolUtils[info.func]({
								[0] = button
							})
						end
					end
				end
			end
		elseif info.style == 3 then
			local ulist = button:GetChild("List"):GetComponent("UList")

			function ulist.luaRenderItem(button, index, data2)
				if data2.tIndex == 1 then
					local selectorIns = button:GetChild("SelectorSort")

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
					end
				elseif data2.tIndex == 0 or data2.tIndex == 4 or data2.tIndex == 7 then
					local uInput = button:GetChild("InputField"):GetComponent("UTMPInputField")

					ClientTextUtils.setText(uInput:Find("PlaceHolder"), data2.tips or "")
					ClientTextUtils.setText(uInput, data2.defaultValue or "")

					function uInput.luaFocus()
						facade:SendMessageCommand(MessageName.INPUT_TEXT_STATE_CHANGE, true)
					end

					function uInput.luaBlur()
						facade:SendMessageCommand(MessageName.INPUT_TEXT_STATE_CHANGE, false)
					end

					local configButton = button:GetChild("BtnConfirm")

					if configButton and data2.func then
						configButton = configButton:GetComponent("UButton")

						configButton:SetActive(true)

						function configButton.luaClick()
							GmToolUtils.execFunc(data2, uInput.text)
						end
					elseif configButton then
						configButton.gameObject:SetActiveEx(false)
					end
				elseif data2.tIndex == 2 then
					local switchButton = button:GetChild("BtnSwitch"):GetComponent("UButton")

					switchButton:TryChangePage("active", data2.selected and 0 or 1)

					function switchButton.luaClick()
						if data2.func then
							local _, page = switchButton:TryGetCurrentPage("active")

							GmToolUtils[data2.func](page == 1)
						end
					end

					if data2.func and data2.actionPath then
						LuaUIUtils.bindHotKey(switchButton.gameObject, data2.actionPath, function()
							local _, page = switchButton:TryGetCurrentPage("active")

							GmToolUtils[data2.func](page == 1)
							switchButton:TryChangePage("active", GmToolUtils.openMask and 0 or 1)
						end)
					end
				elseif data2.tIndex == 3 then
					local confirmButton = button:GetChild("BtnConfirm"):GetComponent("UButton")
					local input = button:GetChild("InputField"):GetComponent("UTMPInputField")

					function confirmButton.luaClick()
						UIUtils.ClipboardWriter(input.text)
						pg.global.ui.tips:showTextTip(GmToolUtils.getGmGameString("GM_TOAST_COPY_SUCCESS"))
					end
				elseif data2.tIndex == 6 then
					local slider = button:GetChild("Slider"):GetComponent("USlider")
					local sliderText = button:GetChild("Text"):GetComponent("UBaseText")

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

			local confirmButton = button:GetChild("BtnConfirm"):GetComponent("UButton")

			function confirmButton.luaClick()
				if info.func then
					if info.cmdName then
						GmToolUtils[info.func](info.cmdName, ulist:GetAllButtons())
					else
						GmToolUtils[info.func](ulist:GetAllButtons())
					end
				end
			end

			if info.buttonText then
				ClientTextUtils.setText(confirmButton:GetChild("TxtName"), GmToolUtils.getGmGameString(info.buttonText))
			end

			self:refreshMultiListInfo(ulist, info)
		end

		function button.luaBeginDrag()
			self.view.transform:GetComponent("UComponent"):TryChangePage("State", 1)
		end

		function button.luaEndDrag(dropTarget)
			self.view.transform:GetComponent("UComponent"):TryChangePage("State", 0)

			local inArea = rectTransformUtility.RectangleContainsScreenPoint(self.view.areaDelRectTransform, UnityInput.mousePosition, self.uiCamera)

			if inArea then
				local gmToppingNamesStr = pg.global.prefsCacheUtils:getString("gmToppingNames", "")
				local key = info.cmdName or info.label
				local newstr = string.gsub(gmToppingNamesStr, "|" .. key, "")

				pg.global.prefsCacheUtils:setString("gmToppingNames", newstr)

				if info.label == "GM_LANGUAGE_REPLACE" then
					self.languageReplaceTransform = nil

					self:setMaskState(false)
				end

				CS.UnityEngine.GameObject.Destroy(item.gameObject)

				if newstr == "" then
					self:dismiss()
				end
			end
		end

		if info.label == "GM_LANGUAGE_REPLACE" then
			self.languageReplaceTransform = item.transform

			local maskEle = self.view.transform:Find("Mask")

			self:setMaskState(GmToolUtils.openMask)

			maskEle:GetComponent("UButton").luaClick = function()
				local topChild

				if uiRootTrans.childCount > 5 then
					topChild = uiRootTrans:GetChild(uiRootTrans.childCount - 1)
				elseif popupLayerTrans.childCount > 0 then
					topChild = popupLayerTrans:GetChild(popupLayerTrans.childCount - 1)
				elseif panelLayerTrans.childCount > 0 then
					topChild = panelLayerTrans:GetChild(panelLayerTrans.childCount - 1)
				elseif UNITY_EDITOR then
					topChild = sceneLayerTrans:Find("UI_Pb_Hud_Frame(Clone)-2") or sceneLayerTrans:Find("UI_Pb_Hud(Clone)-2")
				else
					topChild = sceneLayerTrans:Find("UI_Pb_Hud_Frame(Clone)") or sceneLayerTrans:Find("UI_Pb_Hud(Clone)")
				end

				local textComponentList = {}

				textComponentList[#textComponentList + 1] = topChild:GetComponentsInChildren(typeof(CS.XGUI.UBaseText))

				for i = 0, infosLayerTrans.childCount - 1 do
					local child = infosLayerTrans:GetChild(i)

					textComponentList[#textComponentList + 1] = child:GetComponentsInChildren(typeof(CS.XGUI.UBaseText))
				end

				if panelLayerTrans.childCount > 0 then
					textComponentList[#textComponentList + 1] = panelLayerTrans:GetChild(panelLayerTrans.childCount - 1):GetComponentsInChildren(typeof(CS.XGUI.UBaseText))
				end

				for i = 0, sceneLayerTrans.childCount - 1 do
					local child = sceneLayerTrans:GetChild(i)

					textComponentList[#textComponentList + 1] = child:GetComponentsInChildren(typeof(CS.XGUI.UBaseText))
				end

				for _, textComponents in ipairs(textComponentList) do
					for i = 1, textComponents.Length do
						local inArea = rectTransformUtility.RectangleContainsScreenPoint(textComponents[i - 1].transform, UnityInput.mousePosition, self.uiCamera)

						if inArea then
							local childButtons = button:GetChild("List"):GetComponent("UList"):GetAllButtons()

							GmToolUtils.curSelectedText = textComponents[i - 1]

							ClientTextUtils.setText(childButtons[0]:GetChild("InputField"):GetComponent("UTMPInputField"), textComponents[i - 1].text)

							local ids = {}

							if textComponents[i - 1].localizatinTextGmIds then
								for j = 1, textComponents[i - 1].localizatinTextGmIds.Length do
									ids[#ids + 1] = textComponents[i - 1].localizatinTextGmIds[j - 1]
								end
							end

							ClientTextUtils.setText(childButtons[2]:GetChild("InputField"):GetComponent("UTMPInputField"), table.concat(ids, "|"))

							break
						end
					end
				end
			end
		end

		if info.label == GmToolUtils.getGmGameString("GM_EMPTY_FUNC") then
			self.dofObj = item
			self.dofInfo = info
		end
	end)
end

function ConfigToppingCtrl:refreshMultiListInfo(ulist, info)
	local subItems = {}

	for _, subItemInfo in pairs(info.subItems) do
		local subItem = {}

		subItem.label = GmToolUtils.getGmGameString(subItemInfo.label)
		subItem.tIndex = subItemInfo.style
		subItem.tips = GmToolUtils.getGmGameString(subItemInfo.tips)
		subItem.func = subItemInfo.func
		subItem.actionPath = subItemInfo.actionPath

		if subItemInfo.style == 0 then
			local saveDefaultValue = GmToolUtils.getDefaultValue(subItemInfo)

			if saveDefaultValue and saveDefaultValue ~= "" then
				subItem.defaultValue = saveDefaultValue
			end
		end

		if subItemInfo.style == 1 then
			local dataFunc = subItemInfo.dataFunc

			subItem.itemData = GmToolUtils[dataFunc]()
		elseif subItemInfo.style == 2 then
			local checkFunc = subItemInfo.checkFunc

			subItem.selected = GmToolUtils[checkFunc]()
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

		subItems[#subItems + 1] = subItem
	end

	ulist:SetList(subItems)
end

function ConfigToppingCtrl:refreshDofParam()
	if not self.dofObj then
		return
	end

	local button = self.dofObj.transform:GetComponent("UButton")
	local ulist = button:GetChild("List"):GetComponent("UList")

	self:refreshMultiListInfo(ulist, self.dofInfo)
end

function ConfigToppingCtrl:addListener()
	return
end

function ConfigToppingCtrl:setMaskState(openMask)
	local maskEle = self.view.transform:Find("Mask")

	maskEle.gameObject:SetActiveEx(openMask)

	if openMask then
		pg.game.input:setCursorMode(ClientConst.CURSOR_MODE_NORMAL)

		if self.languageReplaceTransform then
			self.languageReplaceTransform:SetParent(maskEle, false)
		end
	else
		pg.game.input:setCursorMode(self.enterCursonMode)

		if self.languageReplaceTransform then
			self.languageReplaceTransform:SetParent(self.view.transform, false)
		end
	end

	CS.XGUI.UComponent.enabledLanguageReplace = openMask
end

function ConfigToppingCtrl:onDestroy()
	pg.game.input:setCursorMode(self.enterCursonMode)
	UICtrl.onDestroy(self)
	facade:SendMessageCommand(MessageName.INPUT_TEXT_STATE_CHANGE, false)
	self:setMaskState(false)
end

function ConfigToppingCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function ConfigToppingCtrl:onShow()
	return
end

function ConfigToppingCtrl:onHide()
	self:setMaskState(false)
end

return ConfigToppingCtrl
