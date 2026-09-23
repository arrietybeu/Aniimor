-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Survey\\SurveyModel.lua

local UIModel = require("Guis.UIModel")
local Class = require("Core.Framework.Class")
local SurveyModel = Class.LightClass("SurveyModel", UIModel)
local GlobalSurveyContentData = require("Data.global_survey_content_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local RedDotConst = require("Const.RedDotConst")
local Const = require("Common.Const.Const")

function SurveyModel:actor()
	return
end

function SurveyModel:parseDataServer(surveyMap)
	self.surveyList = {}

	local contTb = {}

	for i, v in pairs(surveyMap) do
		local temp = {}

		contTb = GlobalSurveyContentData[tonumber(v.questionId or 1)]

		if contTb then
			temp.questionId = v.questionId or 1
			temp.surveyId = i
			temp.title = v.title or contTb.title
			temp.url = v.url or contTb.url
			temp.content = v.content or contTb.content
			temp.reward = v.reward or {}
			temp.time = v.endTime or 0
			self.surveyList[#self.surveyList + 1] = temp
		else
			temp.questionId = v.questionId or 1
			temp.surveyId = i
			temp.title = v.title
			temp.url = v.url
			temp.content = v.content or ""
			temp.reward = v.reward or {}
			temp.time = v.endTime or 0
			self.surveyList[#self.surveyList + 1] = temp
		end
	end

	table.sort(self.surveyList, function(a, b)
		return a.surveyId < b.surveyId
	end)
end

function SurveyModel:getSurveyList()
	return self.surveyList
end

function SurveyModel:getItemByQuestionId(questionId)
	local data = {}

	for i, v in pairs(self.surveyList) do
		if questionId == v.questionId then
			data = v

			return data
		end
	end

	return data
end

function SurveyModel:getSurveyItemNum()
	return self.surveyList and #self.surveyList > 0
end

function SurveyModel:redDot_GetSinglePointDotState(surveyId)
	local surveyIsDisplayMap = pg.me.surveyIsDisplayMap

	if surveyIsDisplayMap and surveyIsDisplayMap[surveyId] then
		return false
	end

	return true
end

function SurveyModel:redDot_GetPointDotState()
	if not self.surveyList then
		return false
	end

	for i, v in pairs(self.surveyList) do
		if self:redDot_GetSinglePointDotState(v.surveyId) then
			return true
		end
	end

	return false
end

function SurveyModel:redDot_GetSurveyState()
	if self:redDot_GetPointDotState() then
		return RedDotConst.RedDotStyle.REWARD
	end

	return RedDotConst.RedDotStyle.NONE
end

return SurveyModel
