-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SelectLanguage\\SelectLanguageModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ClientConst = require("Const.ClientConst")
local ClientSettingUtils = require("Utils.ClientSettingUtils")
local SettingFuncListData = require("Data.setting_func_list_data")
local SystemLanguageMapData = require("Data.system_language_map_data")
local SelectLanguageModel = Class.LightClass("SelectLanguageModel", UIModel)

function SelectLanguageModel:getLanguageSettingInfo()
	for _, settingInfo in pairs(SettingFuncListData) do
		if settingInfo.funcType == "language" then
			return settingInfo
		end
	end

	error("setting_func_list_data missing funcType=language")
end

function SelectLanguageModel:getLanguageOptions()
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

return SelectLanguageModel
