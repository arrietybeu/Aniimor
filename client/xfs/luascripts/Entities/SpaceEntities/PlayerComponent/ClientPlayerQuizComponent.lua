-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerQuizComponent.lua

local class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local ClientPlayerQuizComponent = class.Component("ClientPlayerQuizComponent")

function ClientPlayerQuizComponent:RPC_SC_SendQuizResult(isRight, answerId, hasNext)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_SendQuizResult, isRight=%s, answerId=%s, hasNext=%s", isRight, answerId, hasNext)
	end

	facade:SendMessageCommand(MessageName.QUIZ_ANSWER_CHECK, {
		isRight = isRight,
		answerId = answerId,
		hasNext = hasNext
	})
end

function ClientPlayerQuizComponent:RPC_SC_SendQuizQuestion(questionId, optionOrder, isContinue)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_SendQuizQuestion, questionId=%s, optionOrder=%s, isContinue=%s", questionId, inspect(optionOrder), isContinue)
	end

	facade:SendMessageCommand(MessageName.QUIZ_QUESTION_MATCHED, {
		questionId = questionId,
		optionOrder = optionOrder,
		isContinue = isContinue
	})
end

function ClientPlayerQuizComponent:RPC_SC_SendLastQuestion(questionId, optionOrder)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_SendLastQuestion, questionId=%s, optionOrder=%s", questionId, inspect(optionOrder))
	end

	facade:SendMessageCommand(MessageName.PREV_QUIZ_QUESTION_MATCHED_AGAIN, {
		questionId = questionId,
		optionOrder = optionOrder
	})
end

function ClientPlayerQuizComponent:RPC_SC_SendQuizSubmitted(isTrue)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_SendQuizSubmitted, isTrue=%s", isTrue)
	end

	facade:SendMessageCommand(MessageName.QUIZ_RESULT, {
		isTrue = isTrue
	})
end

function ClientPlayerQuizComponent:RPC_SC_QuizPanelActive(quizId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_QuizPanelActive, quizId=%s", quizId)
	end

	pg.global.ui:open(UIConst.UI_ID_QUIZ, {
		quizId = quizId
	})
end

function ClientPlayerQuizComponent:startQuiz()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("startQuiz")
	end

	pg.me:serverMsg("RPC_CS_QuizTimer", false)
end

function ClientPlayerQuizComponent:continueQuiz()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("startQuiz")
	end

	pg.me:serverMsg("RPC_CS_QuizTimer", true)
end

function ClientPlayerQuizComponent:stopQuiz()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("stopQuiz")
	end

	pg.me:serverMsg("RPC_CS_StopQuiz")
end

function ClientPlayerQuizComponent:answerQuiz(answerId, noNeedResult)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("answerQuiz answerId=%s, noNeedResult=%s", answerId, noNeedResult)
	end

	pg.me:serverMsg("RPC_CS_QuizAnswer", answerId, noNeedResult)
end

function ClientPlayerQuizComponent:quizSettlement(quizId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("quizSettlement quizId=%s", quizId)
	end

	pg.me:serverMsg("RPC_CS_QuizSettlement", quizId)
end

function ClientPlayerQuizComponent:clientQuizResult(result)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("clientQuizResult result=%s", result)
	end

	pg.me:serverMsg("RPC_CS_RequestQuizResult", result)
end

function ClientPlayerQuizComponent:clientQuizAgain()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("clientQuizAgain")
	end

	pg.me:serverMsg("RPC_CS_RequestQuizAgain")
end

return ClientPlayerQuizComponent
