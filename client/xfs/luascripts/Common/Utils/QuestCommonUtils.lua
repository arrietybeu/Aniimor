-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\QuestCommonUtils.lua

local QuestConst = require("Common.Const.QuestConst")
local QuestBase = require("Data.Quest.quest_base")
local Bitset = require("Common.Bitset")
local TriggerConst = require("Common.Const.TriggerConst")
local TriggerData = require("Data.trigger_data")
local SpecialTrainEntryData = require("Data.special_train_entry_data")
local SpecialTrainChapterQuestRevertData = require("Data.special_train_chapter_quest_revert_data")
local QuestCommonUtils = {}
local getBit = Bitset.getBit
local QUEST_STATE = QuestConst.QUEST_STATE

function QuestCommonUtils.getQuestCategory(questId)
	local qdd = QuestBase[questId]

	if not qdd then
		return QuestConst.QUEST_CATEGORY.SINGLE
	end

	if qdd.category == nil then
		return QuestConst.QUEST_CATEGORY.SINGLE
	end

	return qdd.category
end

function QuestCommonUtils.getQuestData(player, questId)
	local qdd = QuestBase[questId]

	if not qdd then
		return
	end

	local qData = player.acceptedQuestMap[questId]

	if qData ~= nil then
		return qdd, qData
	end

	local initialQuestMap = player.initialQuestMap

	if initialQuestMap ~= nil and initialQuestMap[questId] ~= nil then
		return qdd, initialQuestMap[questId]
	end

	return qdd, player.pendingQuestMap[questId]
end

local CUSTOM_TRIGGER_NAME_POS = TriggerConst.CUSTOM_TRIGGER_NAME_POS
local _questTriggerTypes = {}
local _questTriggerConds = {}

function QuestCommonUtils.getQuestTriggerConfigOld(questId)
	local triggerTypes = _questTriggerTypes[questId]

	if triggerTypes then
		return triggerTypes, _questTriggerConds[questId]
	end

	local qdd = QuestBase[questId]

	if qdd == nil then
		return nil
	end

	triggerTypes = {}

	local triggerConds = {}
	local qddobjectives = qdd.objectives

	if qddobjectives then
		local objectives = {}
		local objectivesCond = {}

		for key, objective in pairs(qddobjectives) do
			local condDict = objective.paramVals

			if condDict then
				objectives[key] = TriggerData[condDict[CUSTOM_TRIGGER_NAME_POS]].trigger
				objectivesCond[key] = condDict
			end
		end

		triggerTypes.objectives = objectives
		triggerConds.objectives = objectivesCond
		objectivesCond.triggerType = TriggerConst.TRIGGER_REGTYPE_QUEST_OBJECTIVE
	end

	local qddclaimCond = qdd.claimCond

	if qddclaimCond and qddclaimCond.condition then
		local claimCond = {}
		local claimCondsCond = {}

		for key, condDict in pairs(qddclaimCond.condition) do
			claimCond[key] = TriggerData[condDict[CUSTOM_TRIGGER_NAME_POS]].trigger
			claimCondsCond[key] = condDict
		end

		triggerTypes.claimCond = claimCond
		triggerConds.claimCond = claimCondsCond
		claimCondsCond.triggerType = TriggerConst.TRIGGER_REGTYPE_QUEST_CLAIMCOND
	end

	local qddrunCond = qdd.runCond

	if qddrunCond and qddrunCond.condition then
		local runCond = {}
		local runCondsCond = {}

		for key, condDict in pairs(qddrunCond.condition) do
			runCond[key] = TriggerData[condDict[CUSTOM_TRIGGER_NAME_POS]].trigger
			runCondsCond[key] = condDict
		end

		triggerTypes.runCond = runCond
		triggerConds.runCond = runCondsCond
		runCondsCond.triggerType = TriggerConst.TRIGGER_REGTYPE_QUEST_RUNCOND
	end

	local qddComActionObjcvs = qdd.comActionObjcvs

	if qddComActionObjcvs then
		local comActionObjcvs = {}
		local comActionObjcvsCond = {}

		for key, condDict in pairs(qddComActionObjcvs) do
			local paramVals = condDict.paramVals

			comActionObjcvs[key] = TriggerData[paramVals[CUSTOM_TRIGGER_NAME_POS]].trigger
			comActionObjcvsCond[key] = paramVals
		end

		triggerTypes.comActionObjcvs = comActionObjcvs
		triggerConds.comActionObjcvs = comActionObjcvsCond
		comActionObjcvsCond.triggerType = TriggerConst.TRIGGER_REGTYPE_QUEST_COM_ACTION_OBJECTIVE
	end

	local qddCloseCond = qdd.closeCond

	if qddCloseCond and qddCloseCond.condition then
		local closeCond = {}
		local closeCondsCond = {}

		for key, condDict in pairs(qddCloseCond.condition) do
			closeCond[key] = TriggerData[condDict[CUSTOM_TRIGGER_NAME_POS]].trigger
			closeCondsCond[key] = condDict
		end

		triggerTypes.closeCond = closeCond
		triggerConds.closeCond = closeCondsCond
		closeCondsCond.triggerType = TriggerConst.TRIGGER_REGTYPE_QUEST_CLOSECOND
	end

	_questTriggerTypes[questId] = triggerTypes
	_questTriggerConds[questId] = triggerConds

	return triggerTypes, triggerConds
end

local _questTriggerTypeList = {}
local _emptyTriggerTypeList = {}

function QuestCommonUtils.getQuestTriggerConfig(questId, triggerType)
	local triggerTypes = _questTriggerTypeList[questId]

	if triggerTypes ~= nil then
		return triggerTypes[triggerType], QuestCommonUtils.getQuestPlayerData(pg.me, questId)
	end

	local qdd = QuestBase[questId]

	if qdd == nil then
		_questTriggerTypeList[questId] = _emptyTriggerTypeList

		return
	end

	triggerTypes = {}

	local name = "objectives"
	local qddobjectives = qdd[name]

	if qddobjectives then
		for key, objective in pairs(qddobjectives) do
			local condDict = objective.paramVals

			if condDict then
				local triggerType = TriggerData[condDict[CUSTOM_TRIGGER_NAME_POS]].trigger
				local typeConds = triggerTypes[triggerType]

				if not typeConds then
					typeConds = {}
					triggerTypes[triggerType] = typeConds
				end

				local objectives = typeConds[name]

				if not objectives then
					objectives = {
						TriggerConst.TRIGGER_REGTYPE_QUEST_OBJECTIVE
					}
					typeConds[name] = objectives
				end

				objectives[#objectives + 1] = key
				objectives[#objectives + 1] = condDict
			end
		end
	end

	name = "claimCond"

	local qddclaimCond = qdd[name]

	if qddclaimCond and qddclaimCond.condition then
		for key, condDict in pairs(qddclaimCond.condition) do
			local triggerType = TriggerData[condDict[CUSTOM_TRIGGER_NAME_POS]].trigger
			local typeConds = triggerTypes[triggerType]

			if not typeConds then
				typeConds = {}
				triggerTypes[triggerType] = typeConds
			end

			local claimCond = typeConds[name]

			if not claimCond then
				claimCond = {
					TriggerConst.TRIGGER_REGTYPE_QUEST_CLAIMCOND
				}
				typeConds[name] = claimCond
			end

			claimCond[#claimCond + 1] = key
			claimCond[#claimCond + 1] = condDict
		end
	end

	name = "runCond"

	local qddrunCond = qdd[name]

	if qddrunCond and qddrunCond.condition then
		for key, condDict in pairs(qddrunCond.condition) do
			local triggerType = TriggerData[condDict[CUSTOM_TRIGGER_NAME_POS]].trigger
			local typeConds = triggerTypes[triggerType]

			if not typeConds then
				typeConds = {}
				triggerTypes[triggerType] = typeConds
			end

			local runCond = typeConds[name]

			if not runCond then
				runCond = {
					TriggerConst.TRIGGER_REGTYPE_QUEST_RUNCOND
				}
				typeConds[name] = runCond
			end

			runCond[#runCond + 1] = key
			runCond[#runCond + 1] = condDict
		end
	end

	name = "comActionObjcvs"

	local qddComActionObjcvs = qdd[name]

	if qddComActionObjcvs then
		for key, objective in pairs(qddComActionObjcvs) do
			local condDict = objective.paramVals

			if condDict then
				local triggerType = TriggerData[condDict[CUSTOM_TRIGGER_NAME_POS]].trigger
				local typeConds = triggerTypes[triggerType]

				if not typeConds then
					typeConds = {}
					triggerTypes[triggerType] = typeConds
				end

				local comActionObjcvs = typeConds[name]

				if not comActionObjcvs then
					comActionObjcvs = {
						TriggerConst.TRIGGER_REGTYPE_QUEST_COM_ACTION_OBJECTIVE
					}
					typeConds[name] = comActionObjcvs
				end

				comActionObjcvs[#comActionObjcvs + 1] = key
				comActionObjcvs[#comActionObjcvs + 1] = condDict
			end
		end
	end

	name = "closeCond"

	local qddCloseCond = qdd[name]

	if qddCloseCond and qddCloseCond.condition then
		for key, condDict in pairs(qddCloseCond.condition) do
			local triggerType = TriggerData[condDict[CUSTOM_TRIGGER_NAME_POS]].trigger
			local typeConds = triggerTypes[triggerType]

			if not typeConds then
				typeConds = {}
				triggerTypes[triggerType] = typeConds
			end

			local closeCond = typeConds[name]

			if not closeCond then
				closeCond = {
					TriggerConst.TRIGGER_REGTYPE_QUEST_CLOSECOND
				}
				typeConds[name] = closeCond
			end

			closeCond[#closeCond + 1] = key
			closeCond[#closeCond + 1] = condDict
		end
	end

	if next(triggerTypes) then
		_questTriggerTypeList[questId] = triggerTypes

		return triggerTypes[triggerType], QuestCommonUtils.getQuestPlayerData(pg.me, questId)
	else
		_questTriggerTypeList[questId] = _emptyTriggerTypeList

		return
	end
end

function QuestCommonUtils.getQuestRuntimeCondition(player, questId, qData, name, key)
	local cond

	if name == "closeCond" then
		local closeData = player.questCloseConditions and player.questCloseConditions[questId]

		cond = closeData and closeData.closeCond and closeData.closeCond[key]
	elseif name == "comActionObjcvs" then
		local ca = player.questCompleteActions and player.questCompleteActions[questId]

		cond = ca and ca.comActionObjcvs and ca.comActionObjcvs[key]
	elseif qData ~= nil and qData[name] ~= nil then
		cond = qData[name][key]
	elseif name == "claimCond" then
		local condFlags = player.initialQuestClaimCondFlags and player.initialQuestClaimCondFlags[questId]

		if condFlags then
			return true, condFlags[key] == 1
		end
	end

	if cond ~= nil then
		return true, cond.isComplete == true
	end

	return false, false
end

function QuestCommonUtils.clearQuestTriggerConfigCache()
	_questTriggerTypes = {}
	_questTriggerConds = {}
	_questTriggerTypeList = {}
end

function QuestCommonUtils.getQuestPlayerData(player, questId)
	local qData = player.acceptedQuestMap[questId]

	if qData ~= nil then
		return qData
	end

	local initialQuestMap = player.initialQuestMap

	if initialQuestMap ~= nil and initialQuestMap[questId] ~= nil then
		return initialQuestMap[questId]
	end

	return player.pendingQuestMap[questId]
end

function QuestCommonUtils.getQuestState(player, questId)
	local qdd, qData = QuestCommonUtils.getQuestData(player, questId)

	if qdd == nil then
		return QUEST_STATE.INVALID, qData ~= nil
	end

	if qData ~= nil then
		return qData.state, qData ~= nil
	end

	if getBit(player.questAwardFlags, questId) then
		return QUEST_STATE.SUBMITED, qData ~= nil
	end

	if getBit(player.questCloseFlags, questId) then
		return QUEST_STATE.CLOSE, qData ~= nil
	end

	return QUEST_STATE.INIT, qData ~= nil
end

function QuestCommonUtils.questAccepted(player, questId)
	local state = QuestCommonUtils.getQuestState(player, questId)

	return state == QuestConst.QUEST_STATE.RECEIVED or state == QuestConst.QUEST_STATE.COMPLETED or state == QuestConst.QUEST_STATE.SUBMITED
end

function QuestCommonUtils.questCompleted(player, questId)
	local state = QuestCommonUtils.getQuestState(player, questId)

	return state == QuestConst.QUEST_STATE.COMPLETED or state == QuestConst.QUEST_STATE.SUBMITED
end

function QuestCommonUtils.questInAccept(player, questId)
	local state = QuestCommonUtils.getQuestState(player, questId)

	if state == QuestConst.QUEST_STATE.RECEIVED then
		return true
	end

	return false
end

function QuestCommonUtils.questInComplete(player, questId)
	local state = QuestCommonUtils.getQuestState(player, questId)

	if state == QuestConst.QUEST_STATE.COMPLETED then
		return true
	end

	return false
end

function QuestCommonUtils.questInSubmit(player, questId)
	local state = QuestCommonUtils.getQuestState(player, questId)

	if state == QuestConst.QUEST_STATE.SUBMITED then
		return true
	end

	return false
end

function QuestCommonUtils.questSubmited(player, questId)
	if getBit(player.questAwardFlags, questId) then
		return true
	end

	return false
end

function QuestCommonUtils.questAcceptedOrComplete(player, questId)
	local state = QuestCommonUtils.getQuestState(player, questId)

	return state == QuestConst.QUEST_STATE.RECEIVED or state == QuestConst.QUEST_STATE.COMPLETED
end

function QuestCommonUtils.questCompleteAndNotSubmit(player, questId)
	local state = QuestCommonUtils.getQuestState(player, questId)

	if state == QuestConst.QUEST_STATE.COMPLETED and not getBit(player.questAwardFlags, questId) then
		return true
	end

	return false
end

function QuestCommonUtils.questInClueReveal(player, questId)
	return getBit(player.clueQuestRevealFlags, questId)
end

function QuestCommonUtils.getSpecialTrainParentQuestId(questId)
	return math.floor(questId / 100) * 100
end

function QuestCommonUtils.getSpecialTrainQuestGroupAndProcess(questId)
	local trainGroup = math.floor(questId % 1000000 / 100)
	local trainProcess = math.floor(questId % 100)

	return trainGroup, trainProcess
end

function QuestCommonUtils.getSpecialTrainQuestGroup(questId)
	return math.floor(questId % 1000000 / 100)
end

function QuestCommonUtils.getMaxTaskGroupProcess(questId)
	local trainGroup = math.floor(questId % 1000000 / 100)
	local specialTrainEntryData = SpecialTrainEntryData[trainGroup]

	if not specialTrainEntryData then
		return nil, 0
	end

	return trainGroup, #specialTrainEntryData
end

function QuestCommonUtils.getSpecialTrainChapterMainQuestCompleteCount(player, chapterId)
	local chapterRevertData = SpecialTrainChapterQuestRevertData[chapterId]

	if not chapterRevertData then
		return 0
	end

	local completeCount = 0

	for _, parentQuestId in pairs(chapterRevertData[QuestConst.TRAIN_CHAPTER_COURSE_TYPE.COMPULSORY_MUST] or {}) do
		if getBit(player.questAwardFlags, parentQuestId) then
			local trainGroup, maxProcess = QuestCommonUtils.getMaxTaskGroupProcess(parentQuestId)

			if trainGroup and player.specialTrainMapMap:isEntryRewarded(chapterId, trainGroup, maxProcess) then
				completeCount = completeCount + 1
			end
		end
	end

	return completeCount
end

return QuestCommonUtils
