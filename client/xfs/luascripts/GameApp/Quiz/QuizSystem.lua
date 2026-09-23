-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Quiz\\QuizSystem.lua

local Class = require("Core.Framework.Class")
local SystemBase = require("GameApp.Core.SystemBase")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local SingleQuizComponent = require("GameApp.Quiz.Component.SingleQuizComponent")
local QuizSystem = Class.LightClass("QuizSystem", SystemBase)

function QuizSystem:onCtor()
	SystemBase.onCtor(self)

	self.singleQuiz = SingleQuizComponent.new()
end

function QuizSystem:onConnected()
	if pg.global.ui and pg.global.ui:checkUIVisible(UIConst.UI_ID_QUIZ) then
		pg.global.ui:close(UIConst.UI_ID_QUIZ)
	end
end

function QuizSystem:onDestroy()
	SystemBase.onDestroy(self)

	if self.singleQuiz then
		self.singleQuiz:destroy()
	end
end

return QuizSystem
