-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SelectLanguage\\SelectLanguageCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientConst = require("Const.ClientConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local SelectLanguageModel = require("Guis.Panels.SelectLanguage.SelectLanguageModel")
local SelectLanguageView = require("Guis.Panels.SelectLanguage.SelectLanguageView")
local SelectLanguageCtrl = Class.LightClass("SelectLanguageCtrl", UICtrl)

SelectLanguageCtrl.modelClz = SelectLanguageModel
SelectLanguageCtrl.viewClz = SelectLanguageView

function SelectLanguageCtrl:addListener()
	function self.view.listUList.luaRenderItem(button, index, data)
		self:onRenderLanguageItem(button, index, data)
	end

	function self.view.listUList.luaClick(button, data)
		self:onLanguageClick(button, data)
	end

	function self.view.btnContinueUButton.luaClick()
		self:onContinueClick()
	end
end

function SelectLanguageCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	local settingInfo

	settingInfo, self.languageOptions, self.selectedOption = self.model:getLanguageOptions()

	for index, option in ipairs(self.languageOptions) do
		if option == self.selectedOption then
			table.remove(self.languageOptions, index)
			table.insert(self.languageOptions, 1, option)

			break
		end
	end

	self.selectedButton = nil

	ClientTextUtils.setText(self.view.txtTitleUSDFText, pg.getLocalizationText(settingInfo.name))
	ClientTextUtils.setText(self.view.txtTipsUSDFText, pg.getGameString("CHOOSE_LANGUAGE"))
	ClientTextUtils.setText(self.view.btnContinueTextUSDFText, pg.getGameString("COMMON_CONFIRM"))
	self.view.listUList:SetList(self.languageOptions)
end

function SelectLanguageCtrl:onRenderLanguageItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

	ClientTextUtils.setText(txtNameUSDFText, data.label)

	local selected = data.value == self.selectedOption.value

	button.isSelected = selected

	if selected then
		self.selectedButton = button
	end
end

function SelectLanguageCtrl:onLanguageClick(button, data)
	if self.selectedButton and self.selectedButton ~= button then
		self.selectedButton.isSelected = false
	end

	self.selectedButton = button
	self.selectedButton.isSelected = true
	self.selectedOption = data
end

function SelectLanguageCtrl:onContinueClick()
	if not self.selectedOption then
		error("SelectLanguage has no selected language")
	end

	local confirmText = pg.getFormatText(pg.getGameString("CHOOSE_LANGUAGE_CONFIRM"), self.selectedOption.label)

	pg.global.showConfirmMsgRaw(pg.getGameString("PET_EXCHANGE_CONFIRM_SELECT"), confirmText, function()
		self:applySelectedLanguage()
	end)
end

function SelectLanguageCtrl:applySelectedLanguage()
	local selectedLanguage = self.selectedOption.value

	pg.game.setting:setLanguage(selectedLanguage)
	pg.game.audio:setLanguage(pg.game.audio:getMatchedAudioLanguage(selectedLanguage))
	pg.global.prefsCacheUtils:setBoolImmediately(ClientConst.PrefKey.LanguageSelectionConfirmed, true)
	self:close()
end

function SelectLanguageCtrl:onDestroy()
	UICtrl.onDestroy(self)

	self.languageOptions = nil
	self.selectedOption = nil
	self.selectedButton = nil
end

return SelectLanguageCtrl
