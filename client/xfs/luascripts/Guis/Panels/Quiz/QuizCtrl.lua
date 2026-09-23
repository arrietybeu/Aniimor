-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Quiz\\QuizCtrl.lua

local UICtrl = require("Guis.UICtrl")
local SingleQuizComponent = require("Guis.Panels.Quiz.Component.SingleQuizComponent")
local UIConst = require("Const.UIConst")
local Class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local QuizCtrl = Class.LightClass("QuizCtrl", UICtrl)

QuizCtrl.messages = {
	[MessageName.QUIZ_QUESTION_MATCHED] = {
		"onQuizQuestionMatched",
		true
	},
	[MessageName.PREV_QUIZ_QUESTION_MATCHED_AGAIN] = {
		"onPrevQuizQuestionMatchedAgain",
		true
	},
	[MessageName.QUIZ_ANSWER_CHECK] = {
		"onQuizAnswerCheck",
		true
	},
	[MessageName.QUIZ_RESULT] = {
		"onQuizResult",
		true
	}
}

function QuizCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.info = info
	self.quizId = self.info.quizId
	self.mode = self.model:getQuizMode(self.quizId)

	if not self.mode then
		self:closePanel()

		return
	end

	self:init()
end

function QuizCtrl:addListener()
	function self.view.btnQuitUButton.luaClick()
		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("QUIZ_QUIT"), function()
			self:closePanel()
		end)
	end

	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.root.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("QUIZ_QUIT"), function()
				self:closePanel()
			end)
		end
	end
end

function QuizCtrl:closePanel()
	pg.global.ui:close(UIConst.UI_ID_QUIZ)
end

function QuizCtrl:init()
	if self.mode == self.model.MODE.SINGLE or self.mode == self.model.MODE.STORY then
		self.view.root:TryChangePage("Mode", 0)
	else
		self.view.root:TryChangePage("Mode", 1)
	end

	if self.mode == self.model.MODE.SINGLE or self.mode == self.model.MODE.STORY then
		self.quizComponent = SingleQuizComponent.new(self)
	elseif self.mode == self.model.MODE.MULTI then
		-- block empty
	end
end

function QuizCtrl:onQuizQuestionMatched(info)
	if self.quizComponent then
		self.quizComponent:onQuizQuestionMatched(info)
	end
end

function QuizCtrl:onPrevQuizQuestionMatchedAgain(info)
	if self.quizComponent then
		self.quizComponent:onPrevQuizQuestionMatchedAgain(info)
	end
end

function QuizCtrl:onQuizAnswerCheck(info)
	if self.quizComponent then
		self.quizComponent:onQuizAnswerCheck(info)
	end
end

function QuizCtrl:onQuizResult(info)
	if self.quizComponent then
		self.quizComponent:onQuizResult(info)
	end
end

function QuizCtrl:onShow()
	return
end

function QuizCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function QuizCtrl:onHide()
	return
end

function QuizCtrl:onDestroy()
	if self.quizComponent then
		self.quizComponent:clear()

		self.quizComponent = nil
	end

	UICtrl.onDestroy(self)
end

return QuizCtrl
