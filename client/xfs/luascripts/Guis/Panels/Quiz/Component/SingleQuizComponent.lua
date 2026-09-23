-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Quiz\\Component\\SingleQuizComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local SingleQuizComponent = Class.LightClass("SingleQuizComponent", UIComponent)
local UICtrl = require("Guis.UICtrl")
local ClientUtils = require("Utils.ClientUtils")

SingleQuizComponent.OPTION_ANGLE_DEGREE = {
	[2] = {
		[1] = 0.05,
		[2] = 0.55
	},
	[3] = {
		0.97,
		0.63,
		0.1
	},
	[4] = {
		0.97,
		0.63,
		0.1,
		0.5
	}
}
SingleQuizComponent.FIXED_REMAIN_TIME_LIMIT = 3

function SingleQuizComponent:findObjects()
	self.readyTime, self.answerTime, self.settleTime = self.model:getQuizFrontEndTimes(self.ctrl.quizId)

	if not self.readyTime or not self.answerTime or not self.settleTime then
		self.ctrl:closePanel()

		return
	end
end

function SingleQuizComponent:playOptionDialogue(dialogueId)
	if not dialogueId then
		return
	end

	pg.game.dialogue:playDialogueGraph(dialogueId)
end

function SingleQuizComponent:initView()
	self:readyStage()
end

function SingleQuizComponent:readyStage(prevAgain)
	pg.game.quiz.singleQuiz:stopQuizTimeline()
	pg.game.quiz.singleQuiz:playQuizTimeline(self.ctrl.quizId)
	self.view.root:TryChangePage("Start", 0)
	self.view.root:TryChangePage("State", 0)
	self.view.root:TryChangePage("Option", 0)

	self.triggered4 = false
	self.triggered3 = false
	self.triggered2 = false
	self.view.countDownUCountDown.luaFinished = nil

	function self.view.countDownUCountDown.luaCountDownUpdate(time)
		if time < 4 and not self.triggered4 then
			self.triggered4 = true

			pg.game.audio:triggerEvent("SFX_UI_QA30D_321_03")
		elseif time < 3 and not self.triggered3 then
			self.triggered3 = true

			pg.game.audio:triggerEvent("SFX_UI_QA30D_321_02")
		elseif time < 2 and not self.triggered2 then
			self.triggered2 = true

			pg.game.audio:triggerEvent("SFX_UI_QA30D_321_01")
		end
	end

	function self.view.countDownUCountDown.luaRemainOneSecond()
		if prevAgain then
			self:answerStage(prevAgain.questionId, prevAgain.optionOrder)
		else
			pg.me:startQuiz()
		end
	end

	ClientUtils.setL10nUCountDownTextFunc(self.view.countDownUCountDown)
	self.view.countDownUCountDown:Play(self.readyTime)
end

function SingleQuizComponent:answerStage(questionId, optionOrder)
	self.view.root:TryChangePage("Start", 1)
	self.view.root:TryChangePage("State", 0)
	self.view.root:TryChangePage("Option", 0)

	self.hasAnswered = false

	self:muteAnswer(false)
	self:renderQuestion(questionId, optionOrder)

	self.answerTimeTriggered = false

	function self.view.countDownUCountDown.luaCountDownUpdate(time)
		if time < SingleQuizComponent.FIXED_REMAIN_TIME_LIMIT and not self.answerTimeTriggered then
			self.answerTimeTriggered = true

			if self.hasAnswered then
				return
			end

			self.hasAnswered = true

			self:muteAnswer(true)

			local optionDialogueId = self.model:getOptionDialogue(self.ctrl.quizId, questionId, 0)

			pg.me:answerQuiz(0, optionDialogueId ~= nil)
			self:playOptionDialogue(optionDialogueId)
		end
	end

	self.view.countDownUCountDown.luaFinished = nil
	self.view.countDownUCountDown.luaRemainOneSecond = nil

	ClientUtils.setL10nUCountDownTextFunc(self.view.countDownUCountDown)
	self.view.countDownUCountDown:Play(self.answerTime)
	pg.game.audio:triggerEvent("SFX_UI_QA30D_Start")
end

function SingleQuizComponent:settleStage(isRight, answerId, hasNext)
	pg.game.audio:triggerEvent(isRight and "SFX_UI_QA30D_Correct" or "SFX_UI_QA30D_Wrong")
	self.view.root:TryChangePage("Start", 2)
	self:renderSettleQuestion(isRight, answerId)
	pg.game.quiz.singleQuiz:playPlayerSettleAnim(self.ctrl.quizId, isRight)

	function self.view.countDownWaitUCountDown.luaRemainOneSecond()
		if hasNext then
			self:readyStage()
		else
			pg.me:quizSettlement(self.ctrl.quizId)
		end
	end

	self.view.countDownWaitUCountDown.luaFinished = nil
	self.view.countDownWaitUCountDown.luaCountDownUpdate = nil

	ClientUtils.setL10nUCountDownTextFunc(self.view.countDownWaitUCountDown)
	self.view.countDownWaitUCountDown:Play(self.settleTime)
end

function SingleQuizComponent:renderQuestion(questionId, optionOrder)
	local questionInfo = self.model:getQuestionInfo(questionId, optionOrder)

	if not questionInfo then
		return
	end

	ClientTextUtils.setText(self.view.txtQuestionUSDFText, questionInfo.question)

	if questionInfo.picture then
		self.view.picUWidget.gameObject:SetActiveEx(true)

		self.view.imgPicUImage.url = questionInfo.picture
	else
		self.view.imgPicUImage.url = nil

		self.view.picUWidget.gameObject:SetActiveEx(false)
	end

	function self.view.listOptionUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local optionTitle = objectReference:GetRefValue("optionTitle")
		local optionContent = objectReference:GetRefValue("optionContent")
		local hotKeyContent = objectReference:GetRefValue("keyHotKeyContent")

		ClientTextUtils.setText(optionTitle, data.title)
		ClientTextUtils.setText(optionContent, data.text)

		button.isSelected = false

		button:TryChangePage("State", 0)

		local function buttonClick()
			if IsNil(self.view) then
				return
			end

			if self.hasAnswered then
				return
			end

			self.hasAnswered = true
			self.answerTimeTriggered = true
			button.isSelected = true

			self:muteAnswer(true)
			self.view.countDownUCountDown:Stop()

			local optionDialogueId = self.model:getOptionDialogue(self.ctrl.quizId, questionId, optionOrder[index + 1])

			pg.me:answerQuiz(index + 1, optionDialogueId ~= nil)

			if optionDialogueId then
				self:playOptionDialogue(optionDialogueId)

				self.view.countDownWaitUCountDown.luaFinished = nil
			end

			self.view.root:TryChangePage("Option", index + 1)

			if SingleQuizComponent.OPTION_ANGLE_DEGREE[#questionInfo.options] then
				self.view.sliderUSlider.value = SingleQuizComponent.OPTION_ANGLE_DEGREE[#questionInfo.options][index + 1] or 1
			else
				self.view.sliderUSlider.value = 1
			end
		end

		button.luaClick = buttonClick

		if hotKeyContent then
			UICtrl:bindHotKeyPerform(data.keyBind, buttonClick, button.gameObject, data.keyBind)
			hotKeyContent:SetHotKeyPaths(data.keyBind)
		end
	end

	self.view.listOptionUList:SetList(questionInfo.options)
end

function SingleQuizComponent:renderSettleQuestion(isRight, answerId)
	local btns = self.view.listOptionUList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		if btns[i].isSelected then
			btns[i]:TryChangePage("State", i + 1 == answerId and 1 or 2)
		else
			btns[i]:TryChangePage("State", i + 1 == answerId and 1 or 0)
		end
	end

	self.view.root:TryChangePage("State", isRight and 1 or 2)
	self.view.root:TryChangePage("Option", 0)
end

function SingleQuizComponent:onQuizQuestionMatched(info)
	self.view.countDownUCountDown:Stop()
	self.view.countDownWaitUCountDown:Stop()

	if info.isContinue then
		self:readyStage({
			questionId = info.questionId,
			optionOrder = info.optionOrder
		})
	else
		self:answerStage(info.questionId, info.optionOrder)
	end
end

function SingleQuizComponent:onPrevQuizQuestionMatchedAgain(info)
	self.view.countDownUCountDown:Stop()
	self.view.countDownWaitUCountDown:Stop()
	self:readyStage({
		questionId = info.questionId,
		optionOrder = info.optionOrder
	})
end

function SingleQuizComponent:onQuizAnswerCheck(info)
	self.view.countDownUCountDown:Stop()
	self.view.countDownWaitUCountDown:Stop()
	self:settleStage(info.isRight, info.answerId, info.hasNext)
end

function SingleQuizComponent:onQuizResult(info)
	self.view.countDownUCountDown:Stop()
	self.view.countDownWaitUCountDown:Stop()
	pg.game.quiz.singleQuiz:cleanupQuiz(self.quizDialogueIds)
	pg.game.quiz.singleQuiz:startDialog(self.ctrl.quizId, info.isTrue)
	self.ctrl:closePanel()
end

function SingleQuizComponent:muteAnswer(mute)
	self.view.muteTransform.gameObject:SetActiveEx(mute)
end

function SingleQuizComponent:clear()
	pg.game.quiz.singleQuiz:cleanupQuiz(self.quizDialogueIds)

	if not self.view then
		return
	end

	self.view.countDownUCountDown.luaFinished = nil
	self.view.countDownUCountDown.luaRemainOneSecond = nil
	self.view.countDownUCountDown.luaCountDownUpdate = nil

	self.view.countDownUCountDown:Stop()

	self.view.countDownWaitUCountDown.luaFinished = nil
	self.view.countDownWaitUCountDown.luaRemainOneSecond = nil
	self.view.countDownWaitUCountDown.luaCountDownUpdate = nil

	self.view.countDownWaitUCountDown:Stop()

	self.timeRecord = nil

	pg.me:stopQuiz()
end

function SingleQuizComponent:onDestroy()
	self:clear()
	UIComponent.onDestroy(self)
end

return SingleQuizComponent
