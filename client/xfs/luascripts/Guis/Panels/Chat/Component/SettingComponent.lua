-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Chat\\Component\\SettingComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local SettingComponent = Class.LightClass("SettingComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local LuaUIUtils = require("Utils.LuaUIUtils")
local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local SettingSelectorTextData = require("Data.setting_selector_text_data")
local SettingTypeData = require("Data.setting_type_data")
local ChatSettingData = require("Data.chat_setting_data")
local ChatBubbleData = require("Data.chat_bubble_data")
local Utils = require("Common.Utils.Utils")
local EditComponent = require("Guis.Panels.InfoPlayerMain.Component.EditComponent")
local WidgetTypeToTIndex = {
	0,
	1,
	nil,
	nil,
	nil,
	2,
	1
}
local CloseAllTextIndex = 42

function SettingComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listInformationUList = objectReference:GetRefValue("listInformationUList")
	self.listNoticeUList = objectReference:GetRefValue("listNoticeUList")
	self.bgCloseUButton = objectReference:GetRefValue("bgCloseUButton")
	self.listBalloonsUList = objectReference:GetRefValue("listBalloonsUList")
	self.tabUList = objectReference:GetRefValue("tabUList")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
end

function SettingComponent:initView()
	function self.bgCloseUButton.luaClick()
		self:close()
	end

	function self.btnCloseUButton.luaClick()
		self:close()
	end

	local closeCommonBind = KeyBindingPro.GetOrAddKeyBindingByName(self.bgCloseUButton.gameObject, "closeCommonBind")

	closeCommonBind.isVirtual = true
	closeCommonBind.priority = 1
	closeCommonBind.actionPath = "Common/ClosePanelCommon"

	function closeCommonBind.luaTrigger(inputInfo)
		self.bgCloseUButton.luaClick()
	end

	function self.tabUList.luaRenderItem(button, index, data)
		self:renderTabItem(button, index, data)
	end

	function self.tabUList.luaSelectedChanged(uList, select)
		if not select then
			return
		end

		self.uWidget:TryChangePage("List", uList.selectedIndex)
	end

	function self.listInformationUList.luaRenderItem(button, index, data)
		self:renderSettingListItem(button, index, data)
	end

	function self.listNoticeUList.luaRenderItem(button, index, data)
		self:renderSettingListItem(button, index, data)
	end

	function self.listBalloonsUList.luaRenderItem(button, index, data)
		self:renderSettingListEffectItem(button, index, data)
	end

	self.tabUList:SetList({
		{
			name = "CHAT_SETTING_INFO",
			tIndex = 0
		},
		{
			name = "CHAT_SETTING_NOTICE",
			tIndex = 1
		},
		{
			name = "CHAT_SETTING_EFFECT",
			tIndex = 2
		}
	})
	self.tabUList:SelectItem(0)
end

function SettingComponent:close()
	self.view.panelUComponent:TryChangePage("ShowPopup", 0)
end

function SettingComponent:refreshSettingList()
	self.view.panelUComponent:TryChangePage("ShowPopup", 2)
	self.listInformationUList:SetList(self:getSettingData("message"))
	self.listNoticeUList:SetList(self:getSettingData("messageInform"))
	self.listBalloonsUList:SetList(self:getSettingData("messagePerform"))
end

function SettingComponent:getSettingData(cate)
	local settingDatas = {}

	for _, settingTab in pairs(SettingTypeData) do
		if cate == settingTab.cate then
			local tab = {
				tIndex = settingTab.cateType,
				tab = settingTab.tab,
				cate = settingTab.cate,
				tabName = settingTab.tabName,
				items = {}
			}

			for index, settingItem in ipairs(ChatSettingData) do
				if settingItem.tab == settingTab.tab then
					table.insert(tab.items, {
						id = index,
						tab = settingItem.tab,
						name = settingItem.name,
						widgetType = WidgetTypeToTIndex[settingItem.widgetType],
						optionType = settingItem.optionType,
						widgetParam = settingItem.widgetParam,
						widgetDefaultValue = settingItem.widgetDefaultValue,
						widgetTxt = self:getVisibleSettingWidgetTxtList(settingItem),
						buttonFunc = settingItem.buttonFunc
					})
				end
			end

			if #tab.items ~= 0 then
				table.insert(settingDatas, tab)
			end
		end
	end

	return settingDatas
end

function SettingComponent:getVisibleSettingWidgetTxtList(settingItem)
	local audioPlayTab = ChatSettingData[pg.game.chat.settingType.AudioPlay].tab

	if settingItem.tab ~= audioPlayTab or ClientConfigAppCountry ~= "cn" then
		return settingItem.widgetTxt
	end

	local languageWidgetTxt = pg.game.chat:getChatSettingWidgetTxt(pg.game.chat.channelType.World, Const.CHAT_ATTR_LANGUAGE.group_base)
	local visibleWidgetTxtList = {}

	for _, widgetTxt in ipairs(settingItem.widgetTxt) do
		if widgetTxt ~= languageWidgetTxt then
			visibleWidgetTxtList[#visibleWidgetTxtList + 1] = widgetTxt
		end
	end

	return visibleWidgetTxtList
end

function SettingComponent:renderTabItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
	local imgAddUImage = objectReference:GetRefValue("imgAddUImage")

	ClientTextUtils.setText(txtNameUBaseText, pg.getGameString(data.name))
end

function SettingComponent:renderSettingListItem(button, index, data)
	if data.tIndex == 0 then
		self:renderCheckSettingListItem(button, index, data)
	else
		self:renderCommonSettingListItem(button, index, data)
	end
end

function SettingComponent:renderSettingListEffectItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local listSettingsUList = objectReference:GetRefValue("listSettingsUList")
	local settingItems = {}

	settingItems[#settingItems + 1] = {
		tIndex = 0,
		name = data.tabName
	}

	for _, settingItem in ipairs(data.items) do
		settingItems[#settingItems + 1] = {
			id = settingItem.id,
			tab = settingItem.tab,
			name = self:getChatChildTabName(settingItem.tab),
			tIndex = settingItem.widgetType,
			buttonFunc = settingItem.buttonFunc
		}
	end

	function listSettingsUList.luaRenderItem(childButton, childIndex, childData)
		if childData.tIndex == 0 then
			local objectReference = childButton:GetComponent("ObjectReference")
			local textTtileUSDFText = objectReference:GetRefValue("textTtileUSDFText")

			ClientTextUtils.setText(textTtileUSDFText, pg.getLocalizationText(childData.name))
		else
			local objectReference = childButton:GetComponent("ObjectReference")
			local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
			local name = self:getSettingEffectItemName(childData)

			ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(name))

			local funcName = self:getButtonFuncName(childData.buttonFunc)
			local clickFunc = self[funcName]

			function childButton.luaClick()
				if clickFunc then
					clickFunc(self)
				end
			end
		end
	end

	listSettingsUList:SetList(settingItems)
end

function SettingComponent:getButtonFuncName(buttonFunc)
	if buttonFunc ~= nil then
		return buttonFunc[1]
	end

	return buttonFunc
end

function SettingComponent:getSettingEffectItemName(childData)
	if childData.tab ~= "chatBubble" then
		return childData.name
	end

	local chatBubble = pg.me.chatBubble

	if chatBubble == nil or chatBubble == 0 then
		chatBubble = pg.game.chat:GetDefaultChatBubbleId()
	end

	local chatBubbleCfg = ChatBubbleData[chatBubble]

	return chatBubbleCfg and chatBubbleCfg.cardName or childData.name
end

function SettingComponent:getChatChildTabName(tab)
	if tab == "chatBubble" then
		return "默认"
	end
end

function SettingComponent:openChatBubblePanel()
	self.view.panelUComponent:TryChangePage("ShowPopup", 0)
	pg.global.ui:open(UIConst.UI_ID_INFO_PLAYER_MAIN, {
		openType = ClientConst.PlayerInfoOpenType.Edit,
		playerId = pg.me.uid,
		defaultEditTabIndex = EditComponent.tabIndex.ChatBubble
	})
end

function SettingComponent:renderCheckSettingListItem(button, index, data)
	local curSettingItemKey = pg.me.uid .. data.tab .. data.items[1].id
	local checkBoxStateStr = pg.global.prefsCacheUtils:getString(curSettingItemKey, Utils.concatTableOrUserdata(data.items[1].widgetDefaultValue, "|"))
	local checkBoxState = string.split(checkBoxStateStr, "|")
	local objectReference = button:GetComponent("ObjectReference")
	local nullUButton = objectReference:GetRefValue("nullUButton")
	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	local listCheckUList = objectReference:GetRefValue("listCheckUList")

	ClientTextUtils.setText(txtTitleUSDFText, pg.getLocalizationText(data.tabName))

	local checkItems = {}

	for _, txt in ipairs(data.items[1].widgetTxt) do
		if txt ~= CloseAllTextIndex then
			table.insert(checkItems, {
				id = txt,
				txt = SettingSelectorTextData[txt].name,
				selected = table.contains(checkBoxState, tostring(txt))
			})
		end
	end

	listCheckUList.groupType = data.items[1].optionType

	function nullUButton.luaSelectChanged(isSelected)
		if isSelected then
			listCheckUList:DeselectAll(false)
		else
			listCheckUList:SelectAll(false)
		end
	end

	function listCheckUList.luaRenderItem(button2, index2, data2)
		local objRef = button2:GetComponent("ObjectReference")
		local txtNameUSDFText = objRef:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data2.txt))
		button2:TryChangePage("Type", 1)
	end

	function listCheckUList.luaSelectedChanged(list)
		local changedCheckBoxState = {}

		for _, listData in pairs(list.itemData) do
			if listData.selected then
				changedCheckBoxState[#changedCheckBoxState + 1] = listData.id
			end
		end

		if #changedCheckBoxState == 0 then
			nullUButton:SetSelected(true)

			changedCheckBoxState[#changedCheckBoxState + 1] = CloseAllTextIndex
		else
			nullUButton:SetSelected(false)
		end

		pg.global.prefsCacheUtils:setString(curSettingItemKey, Utils.concatTableOrUserdata(changedCheckBoxState, "|"))
	end

	listCheckUList:SetList(checkItems)

	nullUButton.isSelected = table.contains(checkBoxState, tostring(CloseAllTextIndex))
end

function SettingComponent:renderCommonSettingListItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	local listUList = objectReference:GetRefValue("listUList")

	ClientTextUtils.setText(txtTitleUSDFText, pg.getLocalizationText(data.tabName))

	local settingItems = {}

	for _, settingItem in ipairs(data.items) do
		table.insert(settingItems, {
			id = settingItem.id,
			name = settingItem.name,
			tIndex = settingItem.widgetType,
			widgetParam = settingItem.widgetParam,
			widgetDefaultValue = settingItem.widgetDefaultValue,
			widgetTxt = settingItem.widgetTxt
		})
	end

	function listUList.luaRenderItem(button2, index2, data2)
		local curSettingItemKey = pg.me.uid .. data.tab .. data2.id
		local settingItemValue = pg.global.prefsCacheUtils:getString(curSettingItemKey, data2.widgetDefaultValue)

		if data2.tIndex == 0 then
			local objRef = button2:GetComponent("ObjectReference")
			local textTitleUSDFText = objRef:GetRefValue("textTitleUSDFText")
			local selectorUSelector = objRef:GetRefValue("selectorUSelector")
			local placeHolderUSDFText = objRef:GetRefValue("placeHolderUSDFText")

			ClientTextUtils.setText(textTitleUSDFText, pg.getLocalizationText(data2.name))
			ClientTextUtils.setText(placeHolderUSDFText, pg.getLocalizationText(SettingSelectorTextData[data2.widgetTxt[tonumber(settingItemValue)]].name))

			function selectorUSelector.luaRenderPopup(popup, uList)
				function uList.luaRenderItem(button3, index3, data3)
					local selectorListObjRef = button3:GetComponent("ObjectReference")
					local txtUText = selectorListObjRef:GetRefValue("txtUText")

					ClientTextUtils.setText(txtUText, pg.getLocalizationText(data3.selectorItemTxt))
				end

				function uList.luaSelectedChanged(list)
					ClientTextUtils.setText(placeHolderUSDFText, pg.getLocalizationText(uList.selectedItem.selectorItemTxt))
					selectorUSelector:ClosePopup()

					settingItemValue = uList.selectedItem.id

					pg.global.prefsCacheUtils:setString(curSettingItemKey, settingItemValue)
					self:settingChangeCallback(data2.id, uList.selectedItem.id)
				end

				local selectorItems = {}

				for idx, selectorItemTxt in ipairs(data2.widgetTxt) do
					table.insert(selectorItems, {
						id = idx,
						selectorItemTxt = SettingSelectorTextData[selectorItemTxt].name
					})
				end

				uList:SetList(selectorItems)
				uList:SelectItem(settingItemValue - 1)
			end
		elseif data2.tIndex == 1 then
			local objRef = button2:GetComponent("ObjectReference")
			local textTitleUSDFText = objRef:GetRefValue("textTitleUSDFText")
			local sliderUSlider = objRef:GetRefValue("sliderUSlider")
			local textValueUSDFText = objRef:GetRefValue("textValueUSDFText")

			sliderUSlider:SetMinWithoutNotify(data2.widgetParam[1])
			sliderUSlider:SetMaxWithoutNotify(data2.widgetParam[2])

			sliderUSlider.value = tonumber(settingItemValue)

			sliderUSlider:SetSliderHotkeyStep(1)
			ClientTextUtils.setText(textValueUSDFText, sliderUSlider.value)

			function sliderUSlider.luaValueChanged(value)
				ClientTextUtils.setText(textValueUSDFText, math.floor(value))
				pg.global.prefsCacheUtils:setString(curSettingItemKey, math.floor(value))
			end

			ClientTextUtils.setText(textTitleUSDFText, pg.getLocalizationText(data2.name))
		end
	end

	listUList:SetList(settingItems)
end

function SettingComponent:settingChangeCallback(settingId, val)
	if settingId == pg.game.chat.settingType.Word then
		self.ctrl.chatComponent.wordSizeSetting = val

		local data = self.view.messageListUList.itemData

		for i = 0, data.Count - 1 do
			data[i].size = 0
		end

		self.view.messageListUList:RefreshList()
	end
end

return SettingComponent
