-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SubtitlesPanel\\SubtitlesPanelCtrl.lua

local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local NpcDialogueData = require("Data.npc_dialogue_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local SubtitlesPanelCtrl = Class.LightClass("SubtitlesPanelCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")

function SubtitlesPanelCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function SubtitlesPanelCtrl:addListener()
	return
end

function SubtitlesPanelCtrl:onShow()
	return
end

function SubtitlesPanelCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	local index = info and info[2]

	if index == nil then
		self:showSubtitles(info)
	else
		self:showAsideContent(info[1], index, info[3])
	end
end

function SubtitlesPanelCtrl:onDestroy()
	UICtrl.onDestroy(self)
	self:removeMoveNextTimer()
end

function SubtitlesPanelCtrl:showSubtitles(info)
	if info == nil then
		return
	end

	local dialogueId = info[1]

	if dialogueId == nil then
		return
	end

	ClientTextUtils.setText(self.view.infoTxt, LuaUIUtils.getReplacedDialogueText(NpcDialogueData[dialogueId][1].chat))
end

function SubtitlesPanelCtrl:showAsideContent(dialogueId, index, extraInfo)
	if dialogueId == nil then
		pg.game.communication:finishNpcDialog()

		return
	end

	if NpcDialogueData[dialogueId] == nil or NpcDialogueData[dialogueId][index] == nil then
		pg.game.communication:finishNpcDialog()

		return
	end

	ClientTextUtils.setText(self.view.infoTxt, LuaUIUtils.getReplacedDialogueText(NpcDialogueData[dialogueId][index].chat))

	local duration = extraInfo and extraInfo.duration or NpcDialogueData[dialogueId][index].duration

	duration = duration or 3

	self:removeMoveNextTimer()

	if duration ~= -1 then
		if pg.game.communication.isInDialogueGraphControl then
			self:startMoveNextTimer(duration, extraInfo and extraInfo.callback)
		else
			self:startMoveNextTimer(duration, function()
				self:showAsideContent(dialogueId, index + 1, extraInfo)
			end)
		end
	end
end

function SubtitlesPanelCtrl:startMoveNextTimer(duration, callback)
	if not callback then
		return
	end

	self.moveNextTimer = self:startTimer(function()
		callback()
	end, duration, false)
end

function SubtitlesPanelCtrl:removeMoveNextTimer()
	if self.moveNextTimer then
		self:killTimer(self.moveNextTimer)

		self.moveNextTimer = nil
	end
end

return SubtitlesPanelCtrl
