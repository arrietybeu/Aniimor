-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Communication\\DialogueVoice.lua

local ClientConst = require("Const.ClientConst")
local DialogueConst = require("Const.DialogueConst")
local DialogueUtils = require("Utils.DialogueUtils")
local NpcDialogueData = require("Data.npc_dialogue_data")
local AudioConst = require("Const.AudioConst")
local EventConst = require("Const.EventConst")
local MessageName = require("Const.MessageName")
local M = {}

function M:isInDialogue()
	return self.curChatType ~= DialogueConst.ChatType.NONE
end

function M:isInNormalDialogue()
	return self.curChatType == DialogueConst.ChatType.DIALOGUE
end

function M:canAutoPlay()
	local playType = DialogueConst.ChatTypeToPlayTypeMap[self.curChatType]

	return playType == DialogueConst.PlayType.AUTO or playType == DialogueConst.PlayType.AUTO_UNBREAKABLE
end

function M:isDialogueUnbreakable()
	local playType = DialogueConst.ChatTypeToPlayTypeMap[self.curChatType]

	return playType == DialogueConst.PlayType.AUTO_UNBREAKABLE
end

function M:stopCombatDialogue(dialogId)
	if self.srcPriority ~= DialogueConst.SrcType.COMBAT then
		return
	end

	if dialogId ~= self.curDialogueId then
		return
	end

	self:finishNpcDialog()
end

function M:onDialogueGraphStart()
	if self.curChatType ~= DialogueConst.ChatType.NONE and not self.isInDialogueGraphControl then
		self:finishNpcDialog()
	end
end

function M:getEnableTypewriter()
	if self.srcPriority == DialogueConst.SrcType.COMBAT then
		return false
	end

	return true
end

function M:getEnableStopUI()
	if self.srcPriority == DialogueConst.SrcType.COMBAT then
		return false
	end

	local curTime = pg.me:getGameTime()

	if self.forbidClickTime > 0 and curTime <= self.curDialogueStartTime + self.forbidClickTime then
		return false
	end

	return true
end

function M:getForbidClickTime()
	return self.forbidClickTime or 0
end

function M:onDialoguePlayVoice(isMyAudio)
	local curVoiceName = self.overrideDialogVoice

	self.overrideDialogVoice = nil

	if curVoiceName == nil and self.curDialogueId and self.curDialogueIndex then
		curVoiceName = DialogueUtils.getAudioName(self.curDialogueId, self.curDialogueIndex)
	end

	self:stopDialogVoice()

	if curVoiceName ~= nil then
		self:playDialogVoice(curVoiceName, isMyAudio)
	end
end

function M:playDialogVoice(voice, isMyAudio)
	if voice ~= nil then
		local shouldSkip = false

		if isMyAudio then
			local protagonistVoice = pg.game.setting:getInt(ClientConst.PrefKey.ProtagonistVoice, 0)

			if protagonistVoice == 1 then
				shouldSkip = true
			end
		end

		if not shouldSkip then
			self.curDialogVoice = voice

			pg.game.audio:playEvent(voice, nil, AudioConst.AkCallbackType.AK_EndOfEvent, function(eventType, extraInfo)
				pg.global.eventEmitter:emit(EventConst.AUDIO_EVENT_FINISH, voice)
				facade:sendMsgToUI(MessageName.AUDIO_EVENT_FINISH, voice)
			end)
		end
	end
end

function M:stopDialogVoice(fadeTime)
	if self.curDialogVoice ~= nil then
		fadeTime = fadeTime or 0.2

		pg.game.audio:stopEvent(self.curDialogVoice, nil, fadeTime)

		self.curDialogVoice = nil
	end
end

return M
