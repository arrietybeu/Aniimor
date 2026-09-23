-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Quiz\\Component\\SingleQuizComponent.lua

local Class = require("Core.Framework.Class")
local SingleQuizData = require("Data.quiz_one_config_data")
local PlayableConst = require("Common.Const.PlayableConst")
local TimerManager = require("Core.Timer.TimerManager")
local HotkeyConst = require("Const.HotkeyConst")
local DialogueGraphConst = require("Const.DialogueGraphConst")
local Const = require("Common.Const.Const")
local SingleQuizComponent = Class.LiteClass("SingleQuizComponent")

function SingleQuizComponent:ctor()
	self.quizCutscene = nil
	self.lastTimeline = nil
end

function SingleQuizComponent:destroy()
	return
end

function SingleQuizComponent:cleanupQuiz()
	self:stopQuizTimeline()
end

function SingleQuizComponent:startDialog(quizId, success)
	if not SingleQuizData[quizId] then
		return
	end

	local dialogueId = success and SingleQuizData[quizId].successDialogue or SingleQuizData[quizId].failDialogue

	if not dialogueId then
		return
	end

	pg.game.communication:startNpcDialog(dialogueId)
end

function SingleQuizComponent:playPlayerSettleAnim(quizId, isRight)
	if not SingleQuizData[quizId] then
		return
	end

	local function getRandomState(right)
		local states = right and SingleQuizData[quizId].stateRight or SingleQuizData[quizId].stateWrong

		if not states or #states <= 0 then
			return nil
		end

		return states[math.random(#states)]
	end

	local anim = getRandomState(isRight)

	if not anim then
		return
	end

	TimerManager.addTimer(0.5, function()
		if #anim <= 3 then
			pg.me:playCfgAnimation({
				anim[1],
				anim[2],
				anim[3],
				{
					true
				}
			})
		else
			pg.me:playCfgAnimation(anim)
		end
	end)
	pg.me.eModel:RegisterSleEndCallback(Const.COMPONENT_IDX_PLAYABLE, function()
		pg.me:stopLayerAnimation(PlayableConst.AnimationLayer.LAYER_FULLBODY, 0.2)
		pg.me:playAnimation(PlayableConst.Idle)
	end)
end

function SingleQuizComponent:playQuizTimeline(quizId)
	if not SingleQuizData[quizId] then
		return
	end

	local tl = SingleQuizData[quizId].timeline

	if not tl or type(tl) ~= "table" or #tl <= 0 then
		return
	end

	local function getRandomTimeline()
		if #tl == 1 then
			self.lastTimeline = tl[1]

			return self.lastTimeline
		end

		local newTimeline

		repeat
			newTimeline = tl[math.random(#tl)]
		until newTimeline ~= self.lastTimeline

		self.lastTimeline = newTimeline

		return newTimeline
	end

	local player = pg.me
	local extraData = {}

	function extraData.startCallback(cutsceneItem)
		return
	end

	function extraData.endCallback(cutsceneItem)
		return
	end

	function extraData.eventCallback(cutsceneItem, eventName)
		return
	end

	local timeline = getRandomTimeline()

	self.quizCutscene = pg.game.cutscene:playCutscene("quizTimeline", timeline, player:getPosition(), player:getRotation(), nil, nil, extraData)
end

function SingleQuizComponent:stopQuizTimeline()
	if self.quizCutscene then
		pg.game.cutscene:stopCutscene(self.quizCutscene.id)

		self.quizCutscene = nil
	end
end

return SingleQuizComponent
