-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Login\\Component\\SelectLanguageComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientConst = require("Const.ClientConst")
local ClientSettingUtils = require("Utils.ClientSettingUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local SettingFuncListData = require("Data.setting_func_list_data")
local SystemLanguageMapData = require("Data.system_language_map_data")
local SelectLanguageComponent = Class.LightClass("SelectLanguageComponent", UIComponent)

function SelectLanguageComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnContinueUButton = objectReference:GetRefValue("btnContinueUButton")
	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.txtTipsUSDFText = objectReference:GetRefValue("txtTipsUSDFText")
	self.listUList = objectReference:GetRefValue("listUList")

	local buttonObjectReference = self.btnContinueUButton:GetComponent("ObjectReference")

	self.btnContinueTextUSDFText = buttonObjectReference:GetRefValue("txtNameUText")
end

function SelectLanguageComponent:initView()
	function self.listUList.luaRenderItem(button, index, data)
		self:onRenderLanguageItem(button, index, data)
	end

	function self.listUList.luaClick(button, data)
		self:onLanguageClick(button, data)
	end

	function self.btnContinueUButton.luaClick()
		self:onContinueClick()
	end
end

function SelectLanguageComponent:getLanguageSettingInfo()
	for _, settingInfo in pairs(SettingFuncListData) do
		if settingInfo.funcType == "language" then
			return settingInfo
		end
	end

	error("setting_func_list_data missing funcType=language")
end

function SelectLanguageComponent:getLanguageOptions()
	local settingInfo = self:getLanguageSettingInfo()
	local languageOptions = ClientSettingUtils.getOptionsData({
		info = settingInfo
	})
	local systemLanguage = CS.UnityEngine.Application.systemLanguage:ToString()
	local systemLanguageConfig = SystemLanguageMapData[systemLanguage]
	local defaultLanguage = systemLanguageConfig and ClientConst.LANGUAGE_TYPE_DESC_MAP[systemLanguageConfig.gameLanguage]

	for _, option in ipairs(languageOptions) do
		if option.value == defaultLanguage then
			return settingInfo, languageOptions, option
		end
	end

	local english = ClientConst.LANGUAGE_TYPE_DESC_MAP[ClientConst.LANGUAGE_TYPE_MAP.en]

	for _, option in ipairs(languageOptions) do
		if option.value == english then
			return settingInfo, languageOptions, option
		end
	end

	error("setting_func_list_data language options missing English")
end

function SelectLanguageComponent:onShow()
	local settingInfo

	settingInfo, self.languageOptions, self.selectedOption = self:getLanguageOptions()

	for index, option in ipairs(self.languageOptions) do
		if option == self.selectedOption then
			table.remove(self.languageOptions, index)
			table.insert(self.languageOptions, 1, option)

			break
		end
	end

	self.selectedButton = nil
	self.txtTitleUSDFText.disabledLocalization = true
	self.txtTipsUSDFText.disabledLocalization = true
	self.btnContinueTextUSDFText.disabledLocalization = true

	ClientTextUtils.setText(self.txtTitleUSDFText, pg.getLocalizationText(settingInfo.name))
	ClientTextUtils.setText(self.txtTipsUSDFText, pg.getGameString("CHOOSE_LANGUAGE"))
	ClientTextUtils.setText(self.btnContinueTextUSDFText, pg.getGameString("COMMON_CONFIRM"))
	self.listUList:SetList(self.languageOptions)
end

function SelectLanguageComponent:onRenderLanguageItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

	txtNameUSDFText.disabledLocalization = true

	ClientTextUtils.setText(txtNameUSDFText, data.label)

	local selected = data.value == self.selectedOption.value

	button.isSelected = selected

	if selected then
		self.selectedButton = button
	end
end

function SelectLanguageComponent:onLanguageClick(button, data)
	if self.selectedButton and self.selectedButton ~= button then
		self.selectedButton.isSelected = false
	end

	self.selectedButton = button
	self.selectedButton.isSelected = true
	self.selectedOption = data
end

function SelectLanguageComponent:onContinueClick()
	if not self.selectedOption then
		error("SelectLanguage has no selected language")
	end

	local confirmText = pg.getFormatText(pg.getGameString("CHOOSE_LANGUAGE_CONFIRM"), self.selectedOption.label)

	pg.global.showConfirmMsgRaw(pg.getGameString("PET_EXCHANGE_CONFIRM_SELECT"), confirmText, function()
		self:applySelectedLanguage()
	end)
end

function SelectLanguageComponent:applySelectedLanguage()
	local selectedLanguage = self.selectedOption.value

	pg.game.setting:setLanguage(selectedLanguage)
	pg.game.audio:setLanguage(pg.game.audio:getMatchedAudioLanguage(selectedLanguage))
	pg.global.prefsCacheUtils:setBoolImmediately(ClientConst.PrefKey.LanguageSelectionConfirmed, true)
	self:hide()
	self.ctrl:onLanguageSelectionConfirmed(self.view)
end

function SelectLanguageComponent:onDestroy()
	self.languageOptions = nil
	self.selectedOption = nil
	self.selectedButton = nil
end

return SelectLanguageComponent
