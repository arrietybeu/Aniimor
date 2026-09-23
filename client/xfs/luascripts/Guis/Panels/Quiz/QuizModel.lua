-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Quiz\\QuizModel.lua

local UIModel = require("Guis.UIModel")
local Class = require("Core.Framework.Class")
local SingleQuizData = require("Data.quiz_one_config_data")
local QuizBankData = require("Data.quiz_bank_config_data")
local QuizModel = Class.LightClass("QuizModel", UIModel)

QuizModel.MODE = {
	STORY = 3,
	MULTI = 2,
	SINGLE = 1
}
QuizModel.OPTION_TITLE = {
	"A",
	"B",
	"C",
	"D"
}
QuizModel.OPTION_KEY = {
	"Raw/GamepadDPadLeft",
	"Raw/GamepadDPadRight",
	"Raw/GamepadDPadUp",
	"Raw/GamepadDPadDown"
}

function QuizModel:getQuizMode(quizId)
	local quizData = SingleQuizData[quizId]

	if not quizData then
		return nil
	end

	if quizData.type ~= QuizModel.MODE.SINGLE and quizData.type ~= QuizModel.MODE.MULTI and quizData.type ~= QuizModel.MODE.STORY then
		return nil
	end

	return quizData.type
end

function QuizModel:getQuizFrontEndTimes(quizId)
	local quizData = SingleQuizData[quizId]

	if not quizData then
		return nil, nil
	end

	local readyTime = quizData.readyTime + 1
	local answerTime = quizData.answerTime
	local settleTime = quizData.settleTime + 1

	return readyTime, answerTime, settleTime
end

function QuizModel:getQuestionInfo(questionId, optionOrder)
	local bankData = QuizBankData[questionId]

	if not bankData then
		return nil
	end

	local questionInfo = {
		question = pg.getLocalizationText(bankData.question) or "error title",
		picture = bankData.questionIcon,
		options = {}
	}

	for index, optionId in pairs(optionOrder) do
		questionInfo.options[index] = {
			title = QuizModel.OPTION_TITLE[index] or "error option title",
			text = pg.getLocalizationText(bankData["option" .. optionId]) or "error",
			keyBind = QuizModel.OPTION_KEY[index] or ""
		}
	end

	return questionInfo
end

function QuizModel:getOptionDialogue(quizId, questionId, optionId)
	local mode = self:getQuizMode(quizId)

	if not mode then
		return nil
	end

	if mode ~= QuizModel.MODE.STORY then
		return nil
	end

	local bankData = QuizBankData[questionId]

	if not bankData then
		return nil
	end

	if not optionId or optionId < 0 or optionId > 4 then
		return nil
	end

	if optionId == 0 then
		return bankData.timeOverDialogue
	else
		return bankData["optionDialogue" .. optionId]
	end
end

return QuizModel
