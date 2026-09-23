-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientQuestComponent.lua

local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local LoggerManager = require("Core.Log.LoggerManager")
local CallbackHandler = require("Core.Common.CallbackHandler")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local QuestConst = require("Common.Const.QuestConst")
local ClientQuestComponent = class.Component("ClientQuestComponent")

function ClientQuestComponent:ctor()
	return
end

function ClientQuestComponent:start()
	return
end

function ClientQuestComponent:RPC_SC_SendQuestObjectiveChange(questId, objectiveId, isComplete)
	if pg.game and pg.game.quest then
		pg.game.quest:onObjectiveChange(questId, objectiveId, isComplete)
	end
end

function ClientQuestComponent:RPC_SC_SendQuestComActionObjectiveChange(questId)
	if QuestUtils.isQuestVisible(questId) then
		facade:sendMsgToUI(MessageName.QUEST_ON_COM_ACTION_OBJECTIVE_CHANGED, {
			questId = questId
		})
	end
end

function ClientQuestComponent:RPC_SC_SendQuestRunStateChange(questId, isRun)
	if pg.game and pg.game.quest then
		pg.game.quest:onQuestRunStateChange(questId, isRun)
	end
end

function ClientQuestComponent:acceptQuest(id, callback)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("clientAcceptQuest id = %d  ", id)
	end

	self:serverMsg("RPC_CS_AcceptQuest", id, function(retStatus, questId)
		self:callbackOnAcceptQuest(retStatus, questId)

		if callback then
			callback(retStatus, questId)
		end
	end)
end

function ClientQuestComponent:callbackOnAcceptQuest(retStatus, id)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("callbackOnAcceptQuest id = %d  %s ", id, tostring(retStatus.status))
	end

	if retStatus.status then
		pg.game.quest:onClaimQuest(id)
	end
end

function ClientQuestComponent:submitQuest(id, isNpc, entityId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("submitQuest id = %d  ", id)
	end

	self:serverMsg("RPC_CS_SubmitQuest", id, isNpc, entityId, function()
		pg.game.quest:onSubmitQuest(id)
	end)
end

function ClientQuestComponent:abandonQuest(id)
	self:serverMsg("RPC_CS_AbandonQuest", id, CallbackHandler(self, "callbackOnAbandonQuest"))
end

function ClientQuestComponent:callbackOnAbandonQuest(retStatus, id)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("callbackOnAbandonQuest id = %d status = %s ", id, tostring(retStatus.status))
	end

	if retStatus.status then
		pg.game.quest:onAbandonQuest(id)
	end
end

function ClientQuestComponent:RPC_SC_SendQuestStateInfo(questId, state)
	pg.game.quest:onQuestStateChange(questId, state)
end

function ClientQuestComponent:RPC_SC_openNpcPhoneUI(npcId, dialogueId, questId)
	local msg = {}

	msg.npcId = npcId
	msg.dialogueId = dialogueId
	msg.questId = questId

	pg.global.ui.tips:showNpcCallMultiple(msg)
	facade:sendMsgToUI(MessageName.NPC_INCOMING_CALL, msg)
end

function ClientQuestComponent:traceQuest(questId, isTrace)
	self:serverMsg("RPC_CS_TraceQuest", questId, isTrace)

	if questId and isTrace then
		local questData = QuestUtils.getQuestData(questId)

		if questData ~= nil then
			if pg.me and questId == pg.me.curTraceQuest then
				if questId == QuestUtils.getTracingStoryQuestId() then
					facade:SendMessageCommand(MessageName.QUEST_ON_TRACE_CHANGE, {
						questData = questData,
						type = QuestConst.QUEST_TRACE_TYPE.STORY
					})
				else
					facade:SendMessageCommand(MessageName.QUEST_ON_TRACE_CHANGE, {
						questData = questData,
						type = QuestConst.QUEST_TRACE_TYPE.QUEST
					})
				end
			elseif pg.me and questId == pg.me.curTraceSecondQuest then
				facade:SendMessageCommand(MessageName.QUEST_ON_TRACE_CHANGE, {
					isNew = true,
					questData = questData,
					type = QuestConst.QUEST_TRACE_TYPE.SEC
				})
			end
		end
	end
end

function ClientQuestComponent:on_curTraceQuest_changed(oldVal, newVal)
	if oldVal ~= 0 then
		local questData = QuestUtils.getQuestData(oldVal)

		if questData ~= nil and QuestUtils.getPageType(oldVal) ~= QuestConst.QUEST_HUD_PAGE_TYPE.STORY then
			facade:SendMessageCommand(MessageName.QUEST_ON_TRACE_CHANGE, {
				questData = questData,
				type = QuestConst.QUEST_TRACE_TYPE.QUEST
			})
		end
	end

	if newVal ~= 0 then
		local questData = QuestUtils.getQuestData(newVal)

		if questData ~= nil and QuestUtils.getPageType(newVal) ~= QuestConst.QUEST_HUD_PAGE_TYPE.STORY then
			facade:SendMessageCommand(MessageName.QUEST_ON_TRACE_CHANGE, {
				questData = questData,
				type = QuestConst.QUEST_TRACE_TYPE.QUEST
			})
		end
	end

	if QuestUtils.getPageType(newVal) and QuestUtils.getPageType(newVal) ~= QuestConst.QUEST_HUD_PAGE_TYPE.STORY then
		pg.game.quest:onQuestTraceChange(newVal, oldVal)
	end
end

function ClientQuestComponent:on_curTraceStoryQuest_changed(oldVal, newVal)
	local isNotified = false

	if oldVal ~= 0 then
		local questData = QuestUtils.getQuestData(oldVal)

		if questData ~= nil then
			facade:SendMessageCommand(MessageName.QUEST_ON_TRACE_CHANGE, {
				questData = questData,
				type = QuestConst.QUEST_TRACE_TYPE.STORY
			})

			isNotified = true
		end
	end

	if newVal ~= 0 then
		local questData = QuestUtils.getQuestData(newVal)

		if questData ~= nil then
			facade:SendMessageCommand(MessageName.QUEST_ON_TRACE_CHANGE, {
				questData = questData,
				type = QuestConst.QUEST_TRACE_TYPE.STORY
			})

			isNotified = true
		end
	end

	if not isNotified and newVal == 0 and QuestUtils.isStoryTracingAllFinished() then
		facade:SendMessageCommand(MessageName.QUEST_ON_TRACE_CHANGE, {
			type = QuestConst.QUEST_TRACE_TYPE.STORY
		})
	end

	pg.game.quest:onQuestTraceChange(newVal, oldVal)
end

function ClientQuestComponent:on_curTraceTempQuest_changed(oldVal, newVal)
	if oldVal > 0 then
		local questData = QuestUtils.getQuestData(oldVal)

		if questData ~= nil then
			facade:SendMessageCommand(MessageName.QUEST_ON_TRACE_CHANGE, {
				questData = questData,
				type = QuestConst.QUEST_TRACE_TYPE.TEMP
			})
		end
	end

	if newVal > 0 then
		local questData = QuestUtils.getQuestData(newVal)

		if questData ~= nil then
			facade:SendMessageCommand(MessageName.QUEST_ON_TRACE_CHANGE, {
				questData = questData,
				type = QuestConst.QUEST_TRACE_TYPE.TEMP
			})
		end
	end

	if oldVal <= 0 and newVal <= 0 then
		facade:SendMessageCommand(MessageName.QUEST_ON_TRACE_CHANGE, {
			type = QuestConst.QUEST_TRACE_TYPE.TEMP
		})
	end

	pg.game.quest:onQuestTraceChange(newVal, oldVal)
end

function ClientQuestComponent:on_curTraceSecondQuest_changed(oldVal, newVal)
	if oldVal > 0 then
		local questData = QuestUtils.getQuestData(oldVal)

		if questData ~= nil then
			facade:SendMessageCommand(MessageName.QUEST_ON_TRACE_CHANGE, {
				questData = questData,
				type = QuestConst.QUEST_TRACE_TYPE.SEC
			})
		end
	end

	if newVal > 0 then
		local questData = QuestUtils.getQuestData(newVal)

		if questData ~= nil then
			facade:SendMessageCommand(MessageName.QUEST_ON_TRACE_CHANGE, {
				isNew = true,
				questData = questData,
				type = QuestConst.QUEST_TRACE_TYPE.SEC
			})
		end
	end

	if oldVal <= 0 and newVal <= 0 then
		facade:SendMessageCommand(MessageName.QUEST_ON_TRACE_CHANGE, {
			type = QuestConst.QUEST_TRACE_TYPE.SEC
		})
	end

	pg.game.quest:onQuestTraceChange(newVal, oldVal)
end

function ClientQuestComponent:RPC_SC_ClueQuestRevealFlagChanged(clueQuestId, isReveal)
	pg.game.quest:onClueQuestRevealFlagChanged(clueQuestId, isReveal)
end

function ClientQuestComponent:RPC_SC_ClearSideQuestAiTip()
	if pg.global.ui and pg.global.ui.tips and pg.game.quest then
		QuestUtils.switchHudPageType(QuestConst.QUEST_HUD_PAGE_TYPE.STORY)

		if pg.global.ui.tips.quest then
			pg.global.ui.tips.quest:switchQuestPageType(QuestConst.QUEST_HUD_PAGE_TYPE.STORY)
		end
	end
end

function ClientQuestComponent:RPC_SC_ToFillQuestFirstTrace(questId)
	return
end

function ClientQuestComponent:setSideQuestAiTip(isInTip)
	self:serverMsg("RPC_CS_SetSideQuestAiTip", isInTip)
end

function ClientQuestComponent:reDoQuestCompleteActions(questId)
	self:serverMsg("RPC_CS_ReDoQuestCompleteActions", questId)
end

function ClientQuestComponent:getChapterQuestProgressReward(configId, rewardIndex, callback)
	self:serverMsg("RPC_CS_GetChapterQuestProgressReward", configId, function(retStatus)
		if callback ~= nil then
			callback(retStatus)
		end
	end)
end

function ClientQuestComponent:RPC_SC_TimeTokenReached(tokenId)
	if pg.game and pg.game.quest then
		pg.game.quest:onTimeTokenReached(tokenId)
	end
end

return ClientQuestComponent
