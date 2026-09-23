-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FuncMenu\\FuncMenuModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local FuncMenuModel = Class.LightClass("FuncMenuModel", UIModel)
local FuncMenuData = require("Data.func_menu_data")
local FuncMenuListData = require("Data.func_menu_list_data")
local FuncMenuBottomListData = require("Data.func_menu_common_use_data")
local CommonSwitch = require("Common.CommonSwitch")
local SceneData = require("Data.scene_data")
local FuncIdConfigData = require("Data.func_index_config_data")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local Const = require("Common.Const.Const")
local MonthCardUtils = require("GameApp.MonthCard.MonthCardUtils")
local ClientConst = require("Const.ClientConst")
local SURVEY_FUNC_ID = 184

function FuncMenuModel:isFuncSwitchOpen(funcName)
	if funcName == nil then
		return true
	end

	if funcName == "CASHSHOP" then
		return CommonSwitch.ShopMall_All == true
	end

	if funcName == "battlepass" then
		return ClientCashShopUtils.canOpenBattlePass()
	end

	if funcName == "service" then
		return pg.global.sdkManager:canOpenHelpCenter() and CommonSwitch[funcName] ~= false
	end

	return CommonSwitch[funcName] ~= false
end

function FuncMenuModel:checkFuncExtraCondition(funcId)
	if funcId == Const.FUNCTION_IDS.MONTH_CARD_PREORDER then
		return MonthCardUtils.isPreorderGuideEnabled() and MonthCardUtils.isPreorderGuideTriggerMatched()
	end

	return true
end

function FuncMenuModel:getCurConfigId()
	local configId = 1

	if pg.me.space and SceneData[pg.me.space.sceneId].funcListId then
		configId = SceneData[pg.me.space.sceneId].funcListId
	end

	return configId
end

function FuncMenuModel:getFixedFuncList()
	local configId = self:getCurConfigId()
	local fixedFuncList = {}
	local hasSurvey = false

	for _, id in ipairs(FuncMenuData[configId].defaultWidget) do
		local funcName = FuncMenuListData[id].functionName

		if self:isFuncSwitchOpen(funcName) and self:checkFuncExtraCondition(id) then
			fixedFuncList[#fixedFuncList + 1] = Utils.deepCopyTable(FuncMenuListData[id])
			fixedFuncList[#fixedFuncList].id = id

			if id == SURVEY_FUNC_ID then
				hasSurvey = true
			end
		end
	end

	if not hasSurvey and pg.global.ui.Survey.model:getSurveyItemNum() and FuncMenuListData[SURVEY_FUNC_ID] then
		local surveyFuncName = FuncMenuListData[SURVEY_FUNC_ID].functionName

		if self:isFuncSwitchOpen(surveyFuncName) then
			fixedFuncList[#fixedFuncList + 1] = Utils.deepCopyTable(FuncMenuListData[SURVEY_FUNC_ID])
			fixedFuncList[#fixedFuncList].id = SURVEY_FUNC_ID
		end
	end

	return fixedFuncList
end

function FuncMenuModel:getBottomFuncListData()
	local configId = self:getCurConfigId()
	local bottomListData = {}

	for index, id in ipairs(FuncMenuData[configId].defaultFunction) do
		local item = FuncMenuBottomListData[id]
		local funcName = item.functionName or item["function"]
		local tIndex = 0

		if funcName == "service" then
			tIndex = 1
		elseif funcName == "VIP" then
			tIndex = pg.global.prefsCacheUtils:getBool(ClientConst.PrefKey.FuncMenuVipEnterClicked, false, ClientConst.CACHE_TYPE_FLAG.USER) and 1 or 2
		end

		local showLock = false

		if self:isFuncSwitchOpen(funcName) and (funcName == nil or pg.me:checkFunctionUnlock(funcName) or showLock) then
			local data = Utils.deepCopyTable(item)

			data.id = id
			bottomListData[#bottomListData + 1] = data
			data.tIndex = tIndex
		end
	end

	return bottomListData
end

return FuncMenuModel
