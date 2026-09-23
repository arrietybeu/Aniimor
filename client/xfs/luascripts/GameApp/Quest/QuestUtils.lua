-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Quest\\QuestUtils.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("QuestModel")
local Bitset = require("Common.Bitset")
local Utils = require("Common.Utils.Utils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local QuestMain = require("Data.quest_main")
local AddressDataConst = require("Const.AddressDataConst")
local ClientSwitch = require("Common.ClientSwitch")
local SceneUtils = require("Common.Utils.SceneUtils")
local QuestConst = require("Common.Const.QuestConst")
local UIConst = require("Const.UIConst")
local QuestsConfigData = require("Data.Quest.quest_base")
local QuestMainRevertData = require("Data.quest_main_revert")
local StoryPageQuestGroupData = require("Data.story_page_quest_group")
local QuestMainSectionChapterIdData = require("Data.quest_main_section_chapter_id")
local EntityQuestData = require("Data.Quest.quest_entity_revert_data")
local QuestEntityData = require("Data.Quest.quest_entity_data")
local QuestStaticToInteractData = require("Data.Quest.quest_static_to_interact_data")
local QuestToplogoToChatData = require("Data.Quest.quest_toplogo_to_chat_data")
local PuppetData = require("Data.puppet_data")
local SceneTargetPositionRevertData = require("Common.Data.Scene.scene_target_position_revert_data")
local PlayerTitleData = require("Data.player_title_data")
local SpecialTrainRevertData = require("Data.quest_special_train_revert")
local SpecialTrainTypeData = require("Data.special_train_type_data")
local SpecialTrainChapterData = require("Data.special_train_chapter_data")
local SpecialTrainEntryData = require("Data.special_train_entry_data")
local SpecialTrainChapterRevertData = require("Data.special_train_chapter_quest_revert_data")
local CustomTriggerData = require("Data.custom_trigger_data")
local ClientUtils = require("Utils.ClientUtils")
local TriggerConst = require("Common.Const.TriggerConst")
local TriggerUtils = require("Common.Utils.TriggerUtils")
local Const = require("Common.Const.Const")
local MessageName = require("Const.MessageName")
local QuestPathfindingData = require("Data.Quest.quest_pathfinding_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local QuestPOIAssociationMarkData = require("Data.quest_poi_association_mark_data")
local QuestCommonUtils = require("Common.Utils.QuestCommonUtils")
local Time = require("Core.Common.Time")
local QuestShowStyle = require("Data.quest_task_type")
local QuestChapter = require("Data.quest_chapter")
local QuestRecommendLvStyle = require("Data.quest_recommend_level_data")
local QuestClueCatalogConfig = require("Data.quest_clue_catalog")
local QuestTrackingGroupData = require("Data.quest_tracking_group_data")
local QuestTrackingGroupRevert = require("Data.quest_tracking_group_revert")
local TimeTokenUtils = require("Common.Utils.TimeTokenUtils")
local DialogueGraphConfig = require("Data.dialogue_graph_data")
local TitleLevelConfig = require("Data.title_level_data")
local ClientConst = require("Const.ClientConst")
local GuideUtils = require("Utils.GuideUtils")
local CommonSwitch = require("Common.CommonSwitch")
local ItemSourceData = require("Data.item_source_data")
local SysConfigData = require("Data.sys_config_data")
local TriggerNameData = require("Data.trigger_name_data")
local Vector3 = Vector3
local QuestUtils = {}

QuestUtils.TargetPosType = {
	SCENE_BASIC_POINT_DATA = 6,
	SCENE_MARK_POINT_DATA = 5,
	SPAWNER = 1
}
QuestUtils.QUEST_POI_ASSOCIATION_SOURCE = {
	RELATED_SANDBOX = 2,
	TARGET_SANDBOX = 1,
	NONE = 0,
	TARGET_ENTITY = 3
}

function QuestUtils.getAllAcceptedQuestsData()
	local questsInfo = pg.me.acceptedQuestMap

	return questsInfo
end

function QuestUtils.getTargetAcceptedQuestData(questType)
	local res = {}

	for questId, qData in pairs(pg.me.acceptedQuestMap) do
		local qdd = QuestsConfigData[questId]

		if qdd and qdd.questType == questType then
			res[questId] = qData
		end
	end

	return res
end

function QuestUtils.getQuestData(questId)
	if pg.me == nil then
		return nil
	end

	local qData = pg.me.acceptedQuestMap[questId]

	if qData ~= nil then
		return qData
	end

	return pg.me.pendingQuestMap[questId]
end

function QuestUtils.getQuestCallId(questId)
	if pg.me == nil or pg.me.questCallIds == nil then
		return 0
	end

	return pg.me.questCallIds[questId] or 0
end

function QuestUtils.getAllCanShowArrowQuests()
	if pg.me == nil then
		return nil
	end

	local temp = {}

	for questId, sv in pairs(pg.me.acceptedQuestMap) do
		if QuestUtils.canQusetShowArrowFlag(questId) then
			table.insert(temp, sv)
		end
	end

	for questId, sv in pairs(pg.me.pendingQuestMap) do
		if QuestUtils.canQusetShowArrowFlag(questId) then
			table.insert(temp, sv)
		end
	end

	return temp
end

function QuestUtils.canQusetShowArrowFlag(questId)
	if QuestUtils.isQuestVisible(questId) then
		return QuestUtils.isQuestTracing(questId) or QuestUtils.isRootQuestTracing(questId) or QuestUtils.isQuestManualClaimable(questId) or QuestUtils.isQuestManualCommit(questId)
	else
		return QuestUtils.canQuestObjShowArrowFlag(questId)
	end
end

function QuestUtils.canQuestShowPathfindingFlag(questId)
	local canShowPathfindingDatas = {}
	local parentQuestId = QuestUtils.getParentQuestId(questId) or questId
	local curSubQuests = QuestUtils.getAllSubQuests(parentQuestId)
	local hasUnfinedObj = false
	local objId = 0

	if curSubQuests ~= nil then
		for i, id in pairs(curSubQuests) do
			local subQuestId = tonumber(id)
			local subQuestConfig = QuestUtils.getQuestConfig(subQuestId)
			local subQuestData = QuestUtils.getQuestData(subQuestId)

			if subQuestConfig and subQuestConfig.objectives then
				local hasFlag = false

				for k, v in pairs(subQuestConfig.objectives) do
					if v.pathfindingID and v.showPath and QuestCommonUtils.getQuestState(pg.me, subQuestId) and QuestCommonUtils.getQuestState(pg.me, subQuestId) > QuestConst.QUEST_STATE.INIT then
						hasFlag = true
						objId = k
					end

					if subQuestData and QuestUtils.isQuestVisible(subQuestId) and not QuestUtils.isQuestDataObjFined(subQuestData, k) then
						hasUnfinedObj = true
					end
				end

				local isManualCommitCompleted = subQuestData ~= nil and QuestUtils.isQuestVisible(subQuestId) and QuestCommonUtils.getQuestState(pg.me, subQuestId) == QuestConst.QUEST_STATE.COMPLETED and QuestUtils.isQuestManualCommit(subQuestId)

				if isManualCommitCompleted then
					hasUnfinedObj = true
				end

				if (hasFlag or isManualCommitCompleted) and subQuestData then
					local curQuestData = {}

					curQuestData = subQuestData
					curQuestData.objId = objId

					table.insert(canShowPathfindingDatas, curQuestData)
				end
			end
		end
	end

	return #canShowPathfindingDatas > 0 and hasUnfinedObj, canShowPathfindingDatas
end

function QuestUtils.canShowPlayDialogue(questId)
	local flag, dialogueId = false, 0
	local questConfig = QuestUtils.getQuestConfig(questId)
	local isShowPathfinding, _ = QuestUtils.canQuestShowPathfindingFlag(questId)

	if questConfig and questConfig.objectives and not isShowPathfinding then
		for j = 1, #questConfig.objectivesIDs do
			local objId = questConfig.objectivesIDs[j]
			local objectData = questConfig.objectives[objId]
			local isFined = QuestUtils.isQuestObjFined(questId, objId)

			if objectData and objectData.paramVals and not isFined and objectData.paramVals[TriggerConst.CUSTOM_TRIGGER_NAME_POS] == "UNLOCK_DIALOGUE_GRAPH" and not objectData.pathfindingID then
				dialogueId = tonumber(objectData.paramVals[TriggerConst.CUSTOM_TRIGGER_TARGET_POS]) or 0
				flag = dialogueId > 0

				return flag, dialogueId
			end
		end
	end

	return flag, dialogueId
end

function QuestUtils.isRunCondNotMet(questId)
	local questConfig = QuestUtils.getQuestConfig(questId)

	if not questConfig or not questConfig.runCond then
		return false
	end

	local questData = QuestUtils.getQuestData(questId)

	if not questData or questData.state ~= QuestConst.QUEST_STATE.RECEIVED or questData.runState ~= false then
		return false
	end

	return true
end

function QuestUtils.getTimeTokenKeyFromCond(condTable)
	for key, condData in pairs(condTable) do
		if Utils.isTable(condData) then
			if condData[TriggerConst.CUSTOM_TRIGGER_NAME_POS] == TriggerNameData[TriggerConst.TRIGGER_TARGET_TIME_TOKEN] then
				return key
			elseif Utils.isTable(condData[1]) then
				for idx, singleCond in ipairs(condData) do
					if Utils.isTable(singleCond) and singleCond[TriggerConst.CUSTOM_TRIGGER_NAME_POS] == TriggerNameData[TriggerConst.TRIGGER_TARGET_TIME_TOKEN] then
						return idx
					end
				end
			end
		elseif condData == TriggerNameData[TriggerConst.TRIGGER_TARGET_TIME_TOKEN] then
			return key
		end
	end

	return nil
end

function QuestUtils.getTokenIdFromTriggerConds(questId, condKey, timeTokenKey)
	local _, triggerConds = QuestCommonUtils.getQuestTriggerConfigOld(questId)

	if not triggerConds or not triggerConds[condKey] or not triggerConds[condKey][timeTokenKey] then
		return nil
	end

	local condDict = triggerConds[condKey][timeTokenKey]

	return tonumber(condDict[TriggerConst.CUSTOM_TRIGGER_TARGET_POS])
end

function QuestUtils.getRunCondTimeTokenId(questId)
	if not QuestUtils.isRunCondNotMet(questId) then
		return nil
	end

	local questConfig = QuestUtils.getQuestConfig(questId)
	local timeTokenKey = QuestUtils.getTimeTokenKeyFromCond(questConfig.runCond)

	if not timeTokenKey then
		return nil
	end

	return QuestUtils.getTokenIdFromTriggerConds(questId, "runCond", timeTokenKey)
end

function QuestUtils.hasRunCondTimeToken(questId, objectives)
	objectives = objectives or QuestUtils.getReceivedQuestObjectives(questId)

	if not objectives or #objectives == 0 then
		return false
	end

	for _, obj in ipairs(objectives) do
		if QuestUtils.getRunCondTimeTokenId(obj.questId) then
			return true
		end
	end

	return false
end

function QuestUtils.hasTimeTokenRestriction(questId)
	if QuestUtils.getRunCondTimeTokenId(questId) then
		return true
	end

	if QuestUtils.getCloseCondTimeTokenId(questId) then
		return true
	end

	return false
end

function QuestUtils.getRunCondTimeTokenConditionText(tokenId)
	local tokenData = TimeTokenUtils.getConfig(tokenId)

	if not tokenData or not tokenData.conditionTxt then
		return nil
	end

	return pg.getLocalizationText(tokenData.conditionTxt)
end

function QuestUtils.getTimeTokenInfo(questId, tokenId, suffixKey)
	if not tokenId then
		return nil
	end

	local triggerTime = TimeTokenUtils.getTriggerTime(tokenId)

	if not triggerTime then
		return nil
	end

	local now = Time.secondCache

	if now < triggerTime then
		local remaining = triggerTime - now

		if remaining <= 0 then
			return nil
		end

		local timeStr = LuaUIUtils.timeStampToUtcString(triggerTime, UIConst.TargetTimeType.MonthDay, true)

		if not timeStr or timeStr == "" then
			return nil
		end

		return tokenId, pg.getFormatText(pg.getGameString(suffixKey), timeStr)
	else
		if not TimeTokenUtils.isConditionMet(pg.me, tokenId) then
			local text = QuestUtils.getRunCondTimeTokenConditionText(tokenId)

			if not text then
				return nil
			end

			return tokenId, text
		end

		return nil
	end
end

function QuestUtils.getRunCondTimeTokenInfo(questId)
	local tokenId = QuestUtils.getRunCondTimeTokenId(questId)

	if not tokenId then
		return nil
	end

	return QuestUtils.getTimeTokenInfo(questId, tokenId, "QUEST_TIME_TOKEN_OVER")
end

function QuestUtils.getCloseCondTimeTokenInfo(questId)
	local tokenId = QuestUtils.getCloseCondTimeTokenId(questId)

	if not tokenId then
		return nil
	end

	return QuestUtils.getTimeTokenInfo(questId, tokenId, "QUEST_TIME_TOKEN_CLOSE_OVER")
end

function QuestUtils.getCloseCondTimeTokenId(questId)
	local rootQuestId = QuestUtils.getRootQuestId(questId)

	if not rootQuestId or rootQuestId == 0 then
		rootQuestId = questId
	end

	local questConfig = QuestUtils.getQuestConfig(rootQuestId)

	if not questConfig or not questConfig.closeCond then
		return nil
	end

	local questData = QuestUtils.getQuestData(rootQuestId)

	if not questData or questData.state ~= QuestConst.QUEST_STATE.RECEIVED then
		return nil
	end

	local timeTokenKey = QuestUtils.getTimeTokenKeyFromCond(questConfig.closeCond)

	if not timeTokenKey then
		return nil
	end

	return QuestUtils.getTokenIdFromTriggerConds(rootQuestId, "closeCond", timeTokenKey)
end

function QuestUtils.hasCloseCondTimeToken(questId)
	local tokenId = QuestUtils.getCloseCondTimeTokenId(questId)

	return tokenId ~= nil
end

function QuestUtils.canTraceItemSource(questId)
	if questId == nil then
		return false
	end

	local flag, sourceId = false, 0
	local questConfig = QuestUtils.getQuestConfig(questId)

	if questConfig == nil then
		return false
	end

	if questConfig and questConfig.runCond then
		local runCond = questConfig.runCond
		local questData = QuestUtils.getQuestData(questId)

		if QuestUtils.isRunCondNotMet(questId) and QuestUtils.hasRunCondTimeToken(questId) then
			return false, 0
		end

		if questData and questData.state == QuestConst.QUEST_STATE.RECEIVED and not questData.runState or QuestUtils.isArkScene() and runCond then
			if QuestUtils.isArkScene() and runCond then
				sourceId = QuestConst.SWITCH_DAY_NIGHT_SOURCE_ID.ARK

				return true, sourceId
			else
				if pg.timePeriod ~= Const.TimePeriod.Night then
					sourceId = QuestConst.SWITCH_DAY_NIGHT_SOURCE_ID.NIGHT
				else
					sourceId = QuestConst.SWITCH_DAY_NIGHT_SOURCE_ID.DAY
				end

				if sourceId and sourceId > 0 then
					return true, sourceId
				end
			end
		end
	end

	if questConfig and questConfig.objectives then
		for j = 1, #questConfig.objectivesIDs do
			local objId = questConfig.objectivesIDs[j]
			local objectData = questConfig.objectives[objId]
			local isFined = QuestUtils.isQuestObjFined(questId, objId)

			if objectData and objectData.sourceId and not isFined then
				sourceId = objectData.sourceId or 0
				flag = sourceId > 0

				if flag and not QuestUtils.isValidClueSeekSourceId(sourceId) then
					flag = false
				end

				if flag then
					return flag, sourceId
				end
			end
		end
	end

	return flag, sourceId
end

function QuestUtils.getClueSeekActiveTrackingEntry(sourceId)
	local itemSourceConfig = ItemSourceData[sourceId]

	if itemSourceConfig and itemSourceConfig.param and itemSourceConfig.param[1] then
		return QuestUtils.getActiveTrackingGroupEntry(itemSourceConfig.param[1])
	end

	return nil
end

function QuestUtils.isValidClueSeekSourceId(sourceId)
	local itemSourceConfig = ItemSourceData[sourceId]

	if not itemSourceConfig or itemSourceConfig.type ~= LuaUIUtils.ITEM_SOURCE_JUMP_QUEST_PAGE then
		return true
	end

	return QuestUtils.getClueSeekActiveTrackingEntry(sourceId) ~= nil
end

function QuestUtils.filterSourceType(isShowSourceBtn, sourceId)
	if not isShowSourceBtn or not sourceId then
		return isShowSourceBtn
	end

	local srcConfig = ItemSourceData[sourceId]

	if srcConfig and srcConfig.type == LuaUIUtils.ITEM_SOURCE_JUMP_QUEST_PAGE then
		return false
	end

	return isShowSourceBtn
end

function QuestUtils.doClueSeekQuickJump(clueSeekID)
	local matchedEntry = QuestUtils.getClueSeekActiveTrackingEntry(clueSeekID)

	if matchedEntry then
		local eventName, eventParam = QuestUtils.getTrackingGroupEntryEvent(matchedEntry)

		if eventName then
			pg.me:doEventByData({
				eventName,
				eventParam
			})
		end
	end
end

function QuestUtils.isTrackingGroupEntryActive(entry)
	if not QuestUtils.isQuestInState(entry.questId, QuestConst.QUEST_STATE.RECEIVED) then
		return false
	end

	if QuestUtils.isQuestOfClueQuestType(entry.questId) then
		return QuestUtils.isClueReveal(entry.questId)
	end

	return true
end

function QuestUtils.getActiveTrackingGroupEntry(groupId)
	local entries = QuestTrackingGroupRevert and QuestTrackingGroupRevert[groupId]

	if not entries then
		return nil
	end

	for _, entry in ipairs(entries) do
		if QuestUtils.isTrackingGroupEntryActive(entry) then
			return entry
		end
	end

	return nil
end

function QuestUtils.isTrackingGroupId(groupId)
	local isHasGroupId = QuestTrackingGroupRevert and QuestTrackingGroupRevert[groupId]

	return isHasGroupId
end

function QuestUtils.getTrackingGroupEntryDisplayName(entry)
	if not entry then
		return ""
	end

	local data = QuestTrackingGroupData[entry.id]

	if not data then
		return ""
	end

	local name = ""

	if QuestUtils.isQuestOfClueQuestType(entry.questId) then
		local questConfig = QuestUtils.getQuestConfig(entry.questId)

		name = questConfig and pg.getLocalizationText(questConfig.name)
	else
		local chapterId, sectionId = QuestUtils.getQuestGroupChapterInfo(entry.questId)

		name = QuestUtils.getQuestSectionName(chapterId, sectionId)
	end

	return pg.getFormatText(pg.getLocalizationText(data.buttonTxt), name)
end

function QuestUtils.getTrackingGroupEntryEvent(entry)
	if not entry then
		return nil, nil
	end

	local data = QuestTrackingGroupData[entry.id]

	if not data or not data.event then
		return nil, nil
	end

	return data.event[1], data.event[2]
end

function QuestUtils.getTrackingGroupEntryQuestId(entry)
	if not entry then
		return nil, nil
	end

	local data = QuestTrackingGroupData[entry.id]

	if not data or not data.questId then
		return nil
	end

	return data.questId
end

function QuestUtils.getQuestJumpClueQuestId(id)
	if id then
		for m, n in pairs(QuestClueCatalogConfig) do
			for j = 1, #n.quests do
				local quest = n.quests[j]
				local questGroupId = quest.questId
				local reveal = QuestUtils.isClueReveal(questGroupId)

				if reveal and questGroupId and QuestUtils.isQuestInState(questGroupId, QuestConst.QUEST_STATE.RECEIVED) then
					local groupId = QuestUtils.getQuestConfig(questGroupId).groupId

					if groupId and groupId == tonumber(id) then
						return questGroupId
					end
				end
			end
		end
	end
end

function QuestUtils.getQuestCategory(questId)
	local questConfig = QuestUtils.getQuestConfig(questId)

	if questConfig == nil or questConfig.category == nil then
		return QuestConst.QUEST_CATEGORY.SINGLE
	end

	return questConfig.category
end

function QuestUtils.isQuestCategory(questId, category)
	category = category or QuestConst.QUEST_CATEGORY.SINGLE

	return QuestUtils.getQuestCategory(questId) == category
end

function QuestUtils.getQuestDeliverType(questId)
	local questConfig = QuestUtils.getQuestConfig(questId)

	if questConfig == nil or questConfig.deliverType == nil then
		return QuestConst.QUEST_DELIVER_TYPE.AUTO
	end

	return questConfig.deliverType
end

function QuestUtils.isQuestDeliverType(questId, deliverType)
	deliverType = deliverType or QuestConst.QUEST_DELIVER_TYPE.AUTO

	return QuestUtils.getQuestDeliverType(questId) == deliverType
end

function QuestUtils.getQuestClaimType(questId)
	local questConfig = QuestUtils.getQuestConfig(questId)

	if questConfig == nil or questConfig.claimType == nil then
		return QuestConst.QUEST_CLAIM_TYPE.AUTO
	end

	return questConfig.claimType
end

function QuestUtils.isQuestClaimType(questId, claimType)
	claimType = claimType or QuestConst.QUEST_CLAIM_TYPE.AUTO

	return QuestUtils.getQuestClaimType(questId) == claimType
end

function QuestUtils.needQuitTeam(questId)
	local need = false

	if pg.me and pg.me:isInTeam() and QuestUtils.isQuestCategory(questId) and not pg.me.isQuestInSelfSpace then
		need = true
	end

	return need
end

function QuestUtils.needQuitOtherHomeland(questId)
	local need = false

	if questId == nil or questId < 1 then
		return need
	end

	local questConfig = QuestUtils.getQuestConfig(questId)

	if questConfig and pg.me and pg.me.space and QuestUtils.isQuestCategory(questId) and Utils.getSpaceType(pg.me.space.sceneId) == Const.SPACE_TYPE_HOMELAND and not pg.me:isInSelfHomeland() then
		need = true
	end

	return need
end

function QuestUtils.isReDoQuestComplete(questId)
	local need = false
	local questConfig = QuestUtils.getQuestConfig(questId)

	if questConfig and pg.me and QuestCommonUtils.getQuestState(pg.me, questId) == QuestConst.QUEST_STATE.COMPLETED and questConfig.comActionObjcvIDs then
		need = true
	end

	return need
end

function QuestUtils.canQuestObjShowArrowFlag(questId)
	local questConfig = QuestUtils.getQuestConfig(questId)

	if questConfig and questConfig.objectives then
		for k, v in pairs(questConfig.objectives) do
			if v.pathfindingID then
				return true
			end
		end
	end

	return false
end

function QuestUtils.getTracingQuestId()
	if pg.me == nil then
		return 0
	end

	local curThrTracing = 0
	local curTraceQuest = pg.me.curTraceQuest

	if curTraceQuest ~= 0 and QuestUtils.getTracingStoryQuestId() ~= curTraceQuest then
		curThrTracing = pg.me.curTraceQuest
	end

	return curThrTracing
end

function QuestUtils.getTracingStoryQuestId()
	if pg.me == nil then
		return 0
	end

	return pg.me.curTraceStoryQuest
end

function QuestUtils.getTracingQuest()
	if pg.me.curTraceTempQuest ~= nil and pg.me.curTraceTempQuest ~= -1 then
		if pg.me.curTraceTempQuest == 0 then
			return nil
		end

		return QuestUtils.getQuestData(pg.me.curTraceTempQuest)
	end

	local curTraceQuest = pg.me.curTraceQuest

	if curTraceQuest ~= nil and curTraceQuest ~= 0 then
		local subQuests = QuestUtils.getAllRecvSubQuests(curTraceQuest, true)

		return QuestUtils.getQuestData(curTraceQuest), subQuests
	end
end

function QuestUtils.getAllRecvSubQuests(questId)
	local subQuests = {}
	local curSubQuests = QuestUtils.getChildQuests(questId)

	if curSubQuests ~= nil then
		for i = 1, #curSubQuests do
			local subQusetId = curSubQuests[i]

			if QuestUtils.isQuestVisible(subQusetId) then
				local subQuestData = QuestUtils.getQuestData(subQusetId)

				if subQuestData and (subQuestData.state == QuestConst.QUEST_STATE.RECEIVED or subQuestData.state == QuestConst.QUEST_STATE.COMPLETED) then
					table.insert(subQuests, subQuestData)
				end
			end
		end
	end

	return subQuests
end

function QuestUtils.getAllSubQuests(questId)
	local questConfig = QuestUtils.getQuestConfig(questId)

	if questConfig == nil or questConfig.subQuests == nil then
		return {}
	end

	return questConfig.subQuests.all
end

function QuestUtils.getAllDescendantQuests(questId, result)
	result = result or {}

	local subQuests = QuestUtils.getAllSubQuests(questId)

	if subQuests ~= nil then
		for i = 1, #subQuests do
			local id = subQuests[i]

			table.insert(result, id)
			QuestUtils.getAllDescendantQuests(id, result)
		end
	end

	return result
end

function QuestUtils.isQuestTracing(questId)
	if questId == nil or questId == 0 then
		return false
	end

	local questData = QuestUtils.getQuestData(questId)

	if questData == nil then
		return false
	end

	return QuestUtils.isQuestDataTracing(questData)
end

function QuestUtils.isQuestDataTracing(questData)
	if questData == nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("任务数据不存在！")
		end

		return false
	end

	return questData.configId == pg.me.curTraceTempQuest or questData.configId == pg.me.curTraceQuest or questData.configId == pg.me.curTraceStoryQuest or questData.configId == pg.me.curTraceSecondQuest
end

function QuestUtils.isInCourseScene()
	return pg.me.curTraceTempQuest ~= nil and pg.me.curTraceTempQuest ~= 0 and pg.me.curTraceTempQuest ~= -1
end

function QuestUtils.isRootQuestTracing(questId)
	local rootQuestId = QuestUtils.getRootQuestId(questId)

	return QuestUtils.isQuestTracing(rootQuestId)
end

function QuestUtils.isCurQuestTracing(questId)
	return QuestUtils.isQuestTracing(questId) or QuestUtils.isRootQuestTracing(questId)
end

function QuestUtils.isQuestManualClaimable(questId)
	local questConfig = QuestUtils.getQuestConfig(questId)

	if not questConfig then
		return false
	end

	if not ToBool(QuestsConfigData[questId].receiveNpc) then
		return false
	end

	return QuestCommonUtils.getQuestState(pg.me, questId) == QuestConst.QUEST_STATE.UNRECEIVE and QuestUtils.isQuestClaimType(questId, QuestConst.QUEST_CLAIM_TYPE.NPC)
end

function QuestUtils.getReceiveNpcName(questId, questConfig)
	questConfig = questConfig or QuestUtils.getQuestConfig(questId)

	if not questConfig or not ToBool(questConfig.receiveNpc) then
		return nil
	end

	if not pg.me or not pg.me.space then
		return nil
	end

	local sceneId = QuestUtils.getSceneIdByQuestEntity(questId, questConfig.receiveNpc, QuestConst.QUEST_STATE.UNRECEIVE)
	local sceneData = SceneUtils.getSceneEntityData(sceneId)

	if not sceneData then
		return nil
	end

	local entityData = sceneData[questConfig.receiveNpc]

	if not entityData then
		return nil
	end

	local puppetId = entityData.idInType

	if not puppetId then
		return nil
	end

	local puppetCfg = PuppetData[puppetId]

	if not puppetCfg or not puppetCfg.name then
		return nil
	end

	return pg.getLocalizationText(puppetCfg.name)
end

function QuestUtils.getPathfindingIdsByStaticId(staticId, sceneId)
	if not staticId or not sceneId then
		return nil
	end

	local sceneData = SceneTargetPositionRevertData[sceneId]

	if not sceneData or not sceneData.entityIds then
		return nil
	end

	return sceneData.entityIds[staticId]
end

function QuestUtils.getChatInteractInfosByStaticId(staticId)
	if not staticId then
		return nil
	end

	return QuestStaticToInteractData[staticId]
end

function QuestUtils.getChatToplogoStaticId(staticId, chatInfo)
	local toplogoStaticId = chatInfo and chatInfo.toplogoStaticId

	if not toplogoStaticId or toplogoStaticId == 0 then
		return staticId
	end

	return toplogoStaticId
end

function QuestUtils.getChatInteractInfosByToplogoStaticId(toplogoStaticId)
	if not toplogoStaticId then
		return nil
	end

	return QuestToplogoToChatData[toplogoStaticId]
end

function QuestUtils.getPathfindingIdByQuestAndState(pathfindingIds, questId, state)
	if not pathfindingIds or not questId or not state then
		return nil
	end

	if state == QuestConst.QUEST_STATE.UNRECEIVE then
		state = QuestConst.QUEST_STATE.RECEIVED
	end

	for _, pathfindingId in pairs(pathfindingIds) do
		local questMap = QuestPathfindingData[pathfindingId]

		if questMap and questMap[questId] then
			for _, info in pairs(questMap[questId]) do
				if info.state == state then
					return pathfindingId
				end
			end
		end
	end

	return nil
end

function QuestUtils.getSceneIdByQuestEntity(questId, staticId, state)
	if not questId or not staticId or not state then
		return nil
	end

	local entityList = QuestEntityData[questId]

	if not entityList then
		return nil
	end

	for _, info in pairs(entityList) do
		if info.staticId == staticId and info.state == state and info.sceneId then
			return info.sceneId
		end
	end

	return nil
end

function QuestUtils.pathfindingToReceiveNpc(questId)
	if not questId then
		return
	end

	local questConfig = QuestUtils.getQuestConfig(questId)

	if not questConfig or not ToBool(questConfig.receiveNpc) then
		return
	end

	local sceneId = QuestUtils.getSceneIdByQuestEntity(questId, questConfig.receiveNpc, QuestConst.QUEST_STATE.UNRECEIVE)

	if not sceneId then
		return
	end

	local pathfindingIds = QuestUtils.getPathfindingIdsByStaticId(questConfig.receiveNpc, sceneId)

	if not pathfindingIds then
		return
	end

	local pathfindingId = QuestUtils.getPathfindingIdByQuestAndState(pathfindingIds, questId, QuestConst.QUEST_STATE.UNRECEIVE)

	if pathfindingId and pathfindingId > 0 then
		QuestUtils.pathfindingToTargetPosition(sceneId, pathfindingId, questId)
	end
end

function QuestUtils.isQuestManualCommit(questId)
	if not QuestsConfigData[questId] then
		return false
	end

	if not ToBool(QuestsConfigData[questId].deliverNpc) then
		return false
	end

	local questState = QuestCommonUtils.getQuestState(pg.me, questId)

	return (questState == QuestConst.QUEST_STATE.RECEIVED or questState == QuestConst.QUEST_STATE.COMPLETED) and QuestUtils.isQuestDeliverType(questId, QuestConst.QUEST_DELIVER_TYPE.NPC)
end

function QuestUtils.getCurSelPage()
	local curSelPage = pg.game.quest:getCurTab()

	return curSelPage
end

function QuestUtils.isPageContainQuest(questId)
	return QuestUtils.getCurSelPage() == QuestUtils.getPageType(questId)
end

function QuestUtils.isEmptyPageContainQuest(questId)
	return QuestConst.QUEST_HUD_PAGE_TYPE.EMPTY == QuestUtils.getPageType(questId)
end

function QuestUtils.isParentSyncFinQuest(questId)
	local questConfig = QuestsConfigData[questId]

	if questConfig == nil then
		return false
	end

	return questConfig.isParentSyncFin or false
end

function QuestUtils.getCurSideQuestShowType(questId)
	return QuestUtils.getTaskType(questId)
end

function QuestUtils.getTaskType(questId)
	local questShowStyle = QuestShowStyle[questId]

	if questShowStyle and questShowStyle.styleType == QuestConst.QUEST_SHOW_TYPE.MANUAL_STYLE then
		return {
			styleType = questShowStyle.styleType,
			taskType = questShowStyle.taskType,
			questIcon = questShowStyle.mapMarkPoint,
			pageType = questShowStyle.pageType
		}
	elseif questShowStyle and questShowStyle.styleType == QuestConst.QUEST_SHOW_TYPE.OTHER_STYLE then
		local deliverDesc = questShowStyle.deliverDesc or pg.getGameString("SPECIAL_TRAIN_HUD_TEXT3")
		local deliverIcon = questShowStyle.deliverIcon or AddressDataConst.BRANCH_OPTION_ICON

		return {
			styleType = questShowStyle.styleType,
			deliverIcon = deliverIcon,
			deliverDesc = deliverDesc,
			taskType = questShowStyle.taskType or QuestConst.QUEST_PAGE_STYLE.BLUE,
			pageType = questShowStyle.pageType
		}
	end

	return {
		styleType = QuestConst.QUEST_SHOW_TYPE.OTHER_STYLE,
		deliverIcon = AddressDataConst.BRANCH_OPTION_ICON,
		deliverDesc = pg.getGameString("SPECIAL_TRAIN_HUD_TEXT3"),
		taskType = QuestConst.QUEST_PAGE_STYLE.BLUE,
		pageType = QuestConst.QUEST_HUD_PAGE_TYPE.NULL
	}
end

function QuestUtils.getChatShowType()
	return {
		styleType = QuestConst.QUEST_SHOW_TYPE.OTHER_STYLE,
		deliverIcon = AddressDataConst.BRANCH_OPTION_ICON,
		deliverDesc = pg.getGameString("SPECIAL_TRAIN_HUD_TEXT3"),
		taskType = QuestConst.QUEST_PAGE_STYLE.BLUE,
		pageType = QuestConst.QUEST_HUD_PAGE_TYPE.EMPTY
	}
end

function QuestUtils.getPageType(questId)
	local questShowStyle = QuestShowStyle[questId]

	if questShowStyle then
		return questShowStyle.pageType
	end

	return QuestConst.QUEST_HUD_PAGE_TYPE.QUEST
end

function QuestUtils.getPageDefaultType(pageType)
	local curPageType = pageType or QuestUtils.getCurSelPage()

	if curPageType == QuestConst.QUEST_HUD_PAGE_TYPE.STORY then
		return QuestConst.QUEST_PAGE_STYLE.YELLOW
	elseif curPageType == QuestConst.QUEST_HUD_PAGE_TYPE.GROW then
		return QuestConst.QUEST_PAGE_STYLE.PURPLE
	else
		return QuestConst.QUEST_PAGE_STYLE.BLUE
	end
end

function QuestUtils.getQuestMarkPriority(questType)
	local priority = QuestConst.QUEST_TYPE.MAX - questType

	return priority
end

function QuestUtils.getRecommendLevelVisible(context, recommendLevel)
	local isShowInHud = context.recommendLevelVisible[recommendLevel]

	if isShowInHud == nil then
		local _, visible = QuestUtils.getObjectRecommendLevelStyle(recommendLevel)

		isShowInHud = visible
		context.recommendLevelVisible[recommendLevel] = visible
	end

	return isShowInHud
end

function QuestUtils.tryUpdateMaxRecommendLevel(context, objConfig, isCandidate)
	local recommendLevel = objConfig and objConfig.recommendLv

	if isCandidate and recommendLevel and QuestUtils.getRecommendLevelVisible(context, recommendLevel) and recommendLevel > context.maxRecommendLv then
		context.maxRecommendLv = recommendLevel
	end
end

function QuestUtils.appendReceivedObjective(objectives, context, objectiveInfo, isUnfinished)
	objectives[#objectives + 1] = objectiveInfo

	if isUnfinished then
		context.unfinishedObjectives[objectiveInfo] = true
	end
end

function QuestUtils.isReceivedObjectiveFined(objData, isQuestSubmitted, isSpecialTrainRewardReceived)
	local isObjDataFined = objData ~= nil and objData.isComplete or false

	return isSpecialTrainRewardReceived and (isObjDataFined or isQuestSubmitted) or false
end

function QuestUtils.getQuestStateWithSubmitted(questId)
	local questData = QuestUtils.getQuestData(questId)
	local isQuestSubmitted = QuestUtils.isQuestSubmitted(questId)
	local questState = questData and questData.state

	if questState == nil and isQuestSubmitted then
		questState = QuestConst.QUEST_STATE.SUBMITED
	end

	return questData, questState, isQuestSubmitted
end

function QuestUtils.processSingleQuestObjectives(currentQuestId, currentQuestConfig, excludeFined, objectives, context)
	local questData, questState, isQuestSubmitted = QuestUtils.getQuestStateWithSubmitted(currentQuestId)
	local isReceived = questState == QuestConst.QUEST_STATE.RECEIVED
	local isCompleted = questState == QuestConst.QUEST_STATE.COMPLETED
	local isSubmittedState = questState == QuestConst.QUEST_STATE.SUBMITED
	local isUnReceive = questState == QuestConst.QUEST_STATE.UNRECEIVE
	local claimType = currentQuestConfig.claimType or QuestConst.QUEST_CLAIM_TYPE.AUTO
	local isQuestCanReceive = ToBool(currentQuestConfig.receiveNpc) and isUnReceive and claimType == QuestConst.QUEST_CLAIM_TYPE.NPC

	if isQuestCanReceive then
		local npcName = QuestUtils.getReceiveNpcName(currentQuestId, currentQuestConfig)
		local targetDesc = ""

		if npcName then
			targetDesc = string.format(pg.getGameString("QUEST_UNRECEIVE_DIALOGUE_TARGET_TEXT"), npcName)
		end

		local objectiveInfo = {
			showRecommend = false,
			isOr = false,
			isFined = false,
			isReceiveNpcTarget = true,
			questId = currentQuestId,
			objId = QuestConst.QUEST_DEFAULT_OBJ_ID,
			objConfig = {
				displayType = 0,
				desc = targetDesc
			}
		}

		QuestUtils.appendReceivedObjective(objectives, context, objectiveInfo, true)

		return
	end

	if not currentQuestConfig.objectivesIDs or not QuestUtils.isQuestConfigVisible(currentQuestConfig) then
		return
	end

	local isShowBlackListQuest = isUnReceive and QuestUtils.isInQuestBlackList(currentQuestId)
	local objShowState = isReceived or isCompleted or isSubmittedState or isShowBlackListQuest

	if not objShowState then
		return
	end

	local isComActionNoFinish = isCompleted and currentQuestConfig.comActionObjcvIDs ~= nil
	local isMultiObjAndState = #currentQuestConfig.objectivesIDs > 1
	local canShowFinedMultiObjective = isMultiObjAndState and not isSubmittedState and not isQuestSubmitted
	local isManualCommitConfig = isCompleted and ToBool(currentQuestConfig.deliverNpc) and QuestUtils.isQuestDeliverType(currentQuestId, QuestConst.QUEST_DELIVER_TYPE.NPC)
	local canShowManualCommitObjective = isManualCommitConfig and not isSubmittedState and not isQuestSubmitted
	local isRecommendObjShowState = questData ~= nil and (isReceived or isCompleted)
	local isSpecialTrainQuest = currentQuestConfig.questType == QuestConst.QUEST_TYPE.SPECIAL_TRAIN
	local isSpecialTrainRewardReceived = not isSpecialTrainQuest
	local isSpecialTrainRewardCalculated = not isSpecialTrainQuest
	local isOr
	local isOrCalculated = false

	for j = 1, #currentQuestConfig.objectivesIDs do
		local objId = currentQuestConfig.objectivesIDs[j]
		local objData = questData ~= nil and questData.objectives and questData.objectives[objId] or nil
		local objConfig = currentQuestConfig.objectives[objId]
		local isManualShow = objConfig and objConfig.isManualShow
		local isObjFined = false

		if not isManualShow then
			if not isSpecialTrainRewardCalculated then
				isSpecialTrainRewardReceived = QuestUtils.getSpecialTrainQuestRewardFlags(currentQuestId)
				isSpecialTrainRewardCalculated = true
			end

			isObjFined = QuestUtils.isReceivedObjectiveFined(objData, isQuestSubmitted, isSpecialTrainRewardReceived)
		end

		local isRecommendCandidate = isRecommendObjShowState and not isManualShow and (not isObjFined or excludeFined or isComActionNoFinish or isMultiObjAndState)

		QuestUtils.tryUpdateMaxRecommendLevel(context, objConfig, isRecommendCandidate)

		if objShowState and not isManualShow and (not isObjFined or excludeFined or isComActionNoFinish or isShowBlackListQuest or canShowFinedMultiObjective or canShowManualCommitObjective) then
			if not isOrCalculated then
				isOr = QuestUtils.isNewOrQuest(currentQuestId, currentQuestConfig)
				isOrCalculated = true
			end

			local objectiveInfo = {
				showRecommend = false,
				questId = currentQuestId,
				objId = objId,
				objData = objData,
				objConfig = objConfig,
				isFined = isObjFined and not isComActionNoFinish,
				isOr = isOr
			}

			QuestUtils.appendReceivedObjective(objectives, context, objectiveInfo, not isObjFined)
		end
	end
end

function QuestUtils.collectReceivedQuestObjectives(questId, excludeFined, objectives, context)
	local questConfig = QuestUtils.getQuestConfig(questId)

	if questConfig == nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("%d Quest Config is nil!", questId)
		end

		return
	end

	local quests = questConfig.subQuests and questConfig.subQuests.all or {
		questId
	}

	for i = 1, #quests do
		local currentQuestId = quests[i]
		local currentQuestConfig = QuestUtils.getQuestConfig(currentQuestId)

		if currentQuestConfig ~= nil then
			if currentQuestConfig.subQuests ~= nil then
				QuestUtils.collectReceivedQuestObjectives(currentQuestId, excludeFined, objectives, context)
			else
				QuestUtils.processSingleQuestObjectives(currentQuestId, currentQuestConfig, excludeFined, objectives, context)
			end
		end
	end
end

function QuestUtils.getReceivedQuestObjectives(questId, excludeFined)
	local objectives = {}
	local context = {
		maxRecommendLv = 0,
		recommendLevelVisible = {},
		unfinishedObjectives = {}
	}

	QuestUtils.collectReceivedQuestObjectives(questId, excludeFined, objectives, context)
	table.sort(objectives, function(a, b)
		return
	end)

	local firstUnfinishedIndex
	local maxRecommendLv = context.maxRecommendLv

	for i = 1, #objectives do
		local objective = objectives[i]
		local objConfig = objective.objConfig
		local recommendLevel = objConfig and objConfig.recommendLv

		if recommendLevel and recommendLevel == maxRecommendLv and QuestUtils.getRecommendLevelVisible(context, recommendLevel) then
			objective.showRecommend = true
		end

		if firstUnfinishedIndex == nil and context.unfinishedObjectives[objective] then
			firstUnfinishedIndex = i
		end
	end

	return objectives, firstUnfinishedIndex, maxRecommendLv
end

function QuestUtils.getReceivedQuestTargetObjective(questId, excludeFined)
	local questConfig = QuestUtils.getQuestConfig(questId)
	local questData = QuestUtils.getQuestData(questId)

	if questConfig ~= nil and questConfig.objectivesIDs ~= nil and QuestUtils.isQuestVisible(questId) then
		for j = 1, #questConfig.objectivesIDs do
			local objId = questConfig.objectivesIDs[j]
			local objData = questData ~= nil and questData.objectives ~= nil and questData.objectives[objId] or nil
			local isFined = QuestUtils.isQuestObjFined(questId, objId)

			if isFined and excludeFined or QuestUtils.isQuestDataInState(questData, QuestConst.QUEST_STATE.RECEIVED) then
				local objConfig = questConfig.objectives[objId]
				local objectiveInfo = {
					questId = questId,
					objId = objId,
					objData = objData,
					objConfig = objConfig,
					isFined = isFined
				}

				return objectiveInfo
			end
		end
	end
end

function QuestUtils.getReceivedQuestObjcvSandBoxID(questId, excludeFined)
	local questConfig = QuestUtils.getQuestConfig(questId)
	local questData = QuestUtils.getQuestData(questId)

	if questConfig ~= nil and questConfig.objectivesIDs ~= nil then
		for j = 1, #questConfig.objectivesIDs do
			local objId = questConfig.objectivesIDs[j]
			local isFined = QuestUtils.isQuestObjFined(questId, objId)

			if isFined and excludeFined or QuestUtils.isQuestDataInState(questData, QuestConst.QUEST_STATE.RECEIVED) then
				local objConfig = questConfig.objectives[objId]

				if objConfig.pathfindingID then
					local targetPositionConfig = QuestUtils.getSceneTargetPostionConfig(objConfig.pathfindingID, questId, objId)

					return targetPositionConfig and targetPositionConfig.sandboxId or nil
				end
			end
		end
	end
end

function QuestUtils.getReceivedQuestObjcvAreaId(questId, excludeFined)
	local questConfig = QuestUtils.getQuestConfig(questId)
	local questData = QuestUtils.getQuestData(questId)

	if questConfig ~= nil and questConfig.objectivesIDs ~= nil then
		for j = 1, #questConfig.objectivesIDs do
			local objId = questConfig.objectivesIDs[j]
			local isFined = QuestUtils.isQuestObjFined(questId, objId)

			if isFined and excludeFined or QuestUtils.isQuestDataInState(questData, QuestConst.QUEST_STATE.RECEIVED) then
				local objConfig = questConfig.objectives[objId]

				if objConfig.pathfindingID then
					local targetPositionConfig = QuestUtils.getSceneTargetPostionConfig(objConfig.pathfindingID, questId, objId)

					return targetPositionConfig and targetPositionConfig.areaId or nil
				end
			end
		end
	end
end

function QuestUtils.getSceneTargetPostionConfig(pathfindingID, questId, objcvId)
	local pathfindingQuestsInfo = QuestPathfindingData[pathfindingID]
	local pathfindingQuestInfo = pathfindingQuestsInfo and pathfindingQuestsInfo[questId] or nil

	if pathfindingQuestInfo then
		local sceneId

		for i = 1, #pathfindingQuestInfo do
			local info = pathfindingQuestInfo[i]

			if info.objId == objcvId then
				sceneId = info.sceneId

				break
			end
		end

		if sceneId then
			local sceneAllTargetPositionData = SceneUtils.getSceneTargetPositionData(sceneId)

			return sceneAllTargetPositionData and sceneAllTargetPositionData[pathfindingID]
		end
	end
end

function QuestUtils.getQuestObjcvTargetPositionConfig(questId, objId)
	local questConfig = QuestUtils.getQuestConfig(questId)
	local objConfig = questConfig and questConfig.objectives and questConfig.objectives[objId]

	if not objConfig or not objConfig.pathfindingID then
		return nil
	end

	return QuestUtils.getSceneTargetPostionConfig(objConfig.pathfindingID, questId, objId)
end

function QuestUtils.collectRecvObjcvCandidates(questId)
	local candidates = {}

	local function collect(qId)
		local qConfig = QuestUtils.getQuestConfig(qId)

		if qConfig == nil then
			return
		end

		if not QuestUtils.isQuestOfClueQuestType(qId) then
			return
		end

		local quests = qConfig.subQuests and qConfig.subQuests.all or {
			qId
		}

		for i = 1, #quests do
			local subId = quests[i]
			local subConfig = QuestUtils.getQuestConfig(subId)

			if subConfig ~= nil then
				if subConfig.subQuests ~= nil then
					collect(subId)
				elseif subConfig.objectivesIDs then
					local subData = QuestUtils.getQuestData(subId)

					if subData and QuestUtils.isQuestDataInState(subData, QuestConst.QUEST_STATE.RECEIVED) and QuestUtils.isClueReveal(subId) then
						for j = 1, #subConfig.objectivesIDs do
							local objId = subConfig.objectivesIDs[j]
							local isFined = QuestUtils.isQuestObjFined(subId, objId)

							if not isFined then
								local objConfig = subConfig.objectives[objId]

								if objConfig.pathfindingID then
									local cfg = QuestUtils.getSceneTargetPostionConfig(objConfig.pathfindingID, subId, objId)

									if cfg and cfg.position and cfg.scene then
										table.insert(candidates, {
											scene = cfg.scene,
											position = cfg.position,
											objId = objId,
											questId = subId
										})
									end
								end
							end
						end
					end
				end
			end
		end
	end

	collect(questId)

	return candidates
end

function QuestUtils.getNearestFromCandidates(candidates, getPosFn, refPos)
	if #candidates == 0 then
		return nil
	end

	local playerPos = refPos or pg.me and pg.me:getPosition() or nil
	local nearest = candidates[1]
	local nearestDist

	for _, c in ipairs(candidates) do
		local pos = getPosFn and getPosFn(c) or c.position
		local dist

		if playerPos and pos then
			dist = Vector3.Distance(pos, playerPos)
		end

		if nearestDist == nil or dist and dist < nearestDist then
			nearestDist = dist
			nearest = c
		end
	end

	return nearest
end

function QuestUtils.getNearestRecvObjcvFromGroup(groupQuestId)
	local candidates = QuestUtils.collectRecvObjcvCandidates(groupQuestId)
	local nearest = QuestUtils.getNearestFromCandidates(candidates)

	if nearest then
		return nearest.scene, nearest.position, nearest.objId, nearest.questId
	end
end

function QuestUtils.getReceivedQuestObjcvPosition(questId, excludeFined)
	return QuestUtils.getNearestRecvObjcvFromGroup(questId, excludeFined)
end

function QuestUtils.isNewOrQuest(questId, questConfig)
	questConfig = questConfig or QuestUtils.getQuestConfig(questId)

	if questConfig == nil or questConfig.postQuests == nil or questConfig.postQuests.And == nil then
		if questConfig and not questConfig.isParentSyncFin then
			return true
		end

		return false
	end

	local count = 0

	for i = 1, #questConfig.postQuests.And do
		local postQuestId = questConfig.postQuests.And[i]
		local postQuestConfig = QuestUtils.getQuestConfig(postQuestId)

		if postQuestConfig ~= nil and postQuestConfig.preQuests ~= nil and table.contains(postQuestConfig.preQuests.Or, questId) then
			local orCount = 0

			for i = 1, #postQuestConfig.preQuests.Or do
				local temp = postQuestConfig.preQuests.Or[i]

				if Utils.isTable(temp) then
					for i, v in pairs(temp) do
						if QuestUtils.isQuestVisible(v) then
							orCount = orCount + 1
						end
					end
				elseif QuestUtils.isQuestVisible(temp) then
					orCount = orCount + 1
				end
			end

			count = orCount

			break
		end
	end

	if questConfig.parentQuest then
		local postQuestConfig = QuestUtils.getQuestConfig(questConfig.parentQuest)

		if postQuestConfig ~= nil and postQuestConfig.subQuests and QuestUtils.isQuestVisible(questId) and not QuestUtils.isHasQuestSuccessNode(questId) then
			count = count + 1
		end
	end

	return count > 0
end

function QuestUtils.isHasQuestSuccessNode(questId)
	local flag = false
	local postQuestId
	local questConfig = QuestUtils.getQuestConfig(questId)

	if questConfig and questConfig.isParentSyncFin then
		flag = true

		return flag
	end

	if questConfig and not questConfig.postQuests then
		flag = false

		return flag
	end

	if questConfig and questConfig.postQuests then
		for i, id in ipairs(questConfig.postQuests.And) do
			local questConfig = QuestUtils.getQuestConfig(id)

			if questConfig and QuestUtils.isQuestVisible(id) then
				if not questConfig.isParentSyncFin then
					flag = QuestUtils.isHasQuestSuccessNode(id)

					if flag then
						return flag
					end
				else
					flag = true

					return flag
				end
			end
		end
	end

	return flag
end

function QuestUtils.getQuestObjectiveDesc(questId, objectiveId)
	local questConfig = QuestUtils.getQuestConfig(questId)
	local questdata = QuestUtils.getQuestData(questId)
	local objConfig = questConfig.objectives[objectiveId]
	local objData = questdata ~= nil and questdata.objectives ~= nil and questdata.objectives[objectiveId] or 0

	return pg.getLocalizationText(objConfig.desc, tostring(objData.currentCnt))
end

function QuestUtils.getQuestObjectiveTargetVal(questId, objectiveId)
	local questConfig = QuestUtils.getQuestConfig(questId)
	local objConfig = questConfig.objectives[objectiveId]

	if objConfig then
		return objConfig.paramVals[5]
	end
end

function QuestUtils.getQuestConfig(questId)
	if questId and questId > 0 and QuestsConfigData[questId] == nil then
		if pg.me.isGuidancePlayer then
			return
		end

		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("questconfig is nil! questid = %d，try update quest_base and use new account %s", questId, debug.traceback())
		end

		return
	end

	return QuestsConfigData[questId]
end

function QuestUtils.isWorldRumor(questId)
	local questConfig = QuestUtils.getQuestConfig(questId)

	return questConfig and questConfig.isWorldRumor
end

function QuestUtils.canShowQuestTracking(questId)
	if questId == nil or questId == 0 then
		return false
	end

	if QuestUtils.isRunCondNotMet(questId) then
		return false
	end

	if QuestUtils.needQuitTeam(questId) or QuestUtils.needQuitOtherHomeland(questId) then
		return false
	end

	return true
end

function QuestUtils.getQuestTargetInfo(questData, includeInvisible)
	if questData == nil or pg.me == nil or pg.me.space == nil then
		return nil
	end

	local sceneId = pg.me.space.sceneId
	local mainSceneId = pg.game.map:convertSceneId(sceneId)
	local mainTargetPostionData = SceneUtils.getSceneTargetPositionData(mainSceneId)

	if mainTargetPostionData == nil then
		return nil
	end

	local questId = questData.configId
	local questConfig = QuestUtils.getQuestConfig(questId)

	if questConfig == nil then
		return nil
	end

	local sceneData = SceneUtils.getSceneEntityData(mainSceneId)

	if questData.state == QuestConst.QUEST_STATE.UNRECEIVE then
		if questConfig.receiveNpc == nil or not QuestUtils.isQuestVisible(questId) or sceneData == nil then
			return nil
		end

		local sceneEnt = sceneData[questConfig.receiveNpc]

		if sceneEnt == nil then
			return nil
		end

		local targetsInfo = {}

		targetsInfo.questId = questId
		targetsInfo.state = questData.state
		targetsInfo.posInfo = {
			{
				npcStaticId = questConfig.receiveNpc,
				pos = sceneEnt.position,
				sceneId = sceneId
			}
		}

		return targetsInfo
	elseif questData.state == QuestConst.QUEST_STATE.COMPLETED then
		if questConfig.deliverNpc == nil or not QuestUtils.isQuestVisible(questId) or sceneData == nil then
			return nil
		end

		local sceneEnt = sceneData[questConfig.deliverNpc]

		if sceneEnt == nil then
			return nil
		end

		local targetsInfo = {}

		targetsInfo.questId = questId
		targetsInfo.state = questData.state
		targetsInfo.posInfo = {
			{
				npcStaticId = questConfig.deliverNpc,
				pos = sceneEnt.position,
				sceneId = sceneId
			}
		}

		return targetsInfo
	elseif questData.state == QuestConst.QUEST_STATE.RECEIVED then
		if questConfig.objectivesIDs == nil then
			return nil
		end

		if not QuestUtils.isQuestVisible(questId) and includeInvisible ~= true then
			return nil
		end

		local targetsInfo

		for j = 1, #questConfig.objectivesIDs do
			local objId = questConfig.objectivesIDs[j]
			local objectiveConfig = questConfig.objectives[objId]
			local objectiveData = QuestUtils.getQuestObjData(questData.configId, objId)
			local isFined = true

			if objectiveData then
				isFined = objectiveData.isComplete
			end

			local pathId = objectiveConfig.pathfindingID

			if not isFined and pathId ~= nil and pathId ~= 0 and objectiveData then
				local showPath = objectiveConfig.showPath
				local targetPosConfig = QuestUtils.getSceneTargetPostionConfig(pathId, questId, objId)
				local pos, circleRadius, sceneId = QuestUtils.getTargetConfigPosition(targetPosConfig)

				if pos ~= nil then
					if targetsInfo == nil then
						targetsInfo = {
							questId = questId,
							state = questData.state,
							posInfo = {}
						}
					end

					local temp = {
						objId = objId,
						pos = pos,
						circleRadius = circleRadius,
						posConfig = targetPosConfig,
						pathId = pathId,
						showPath = showPath
					}

					table.insert(targetsInfo.posInfo, temp)
				end
			end
		end

		return targetsInfo
	end

	return nil
end

function QuestUtils.getTargetConfigPosition(targetPosConfig)
	if targetPosConfig == nil then
		return nil
	end

	local pos = targetPosConfig.position
	local sceneId = targetPosConfig.scene
	local circleRadius = targetPosConfig.circleRadius

	if pos ~= nil then
		return pos, circleRadius, sceneId
	end
end

function QuestUtils.isSpecialTrainQuest(questId)
	if questId == nil or questId == 0 then
		return false
	end

	return QuestUtils.isQuestOfQuestType(questId, QuestConst.QUEST_TYPE.SPECIAL_TRAIN)
end

function QuestUtils.isQuestObjFined(questId, objId)
	local baseFined = QuestUtils.isQuestSubmitted(questId)

	if baseFined then
		if QuestUtils.isSpecialTrainQuest(questId) then
			return baseFined and QuestUtils.getSpecialTrainQuestRewardFlags(questId)
		end

		return baseFined
	end

	local questData = QuestUtils.getQuestData(questId)

	return QuestUtils.isQuestDataObjFined(questData, objId)
end

function QuestUtils.isQuestDataObjFined(questData, objId)
	if questData == nil or questData.objectives == nil or questData.objectives[objId] == nil then
		return false
	end

	local baseFined = questData.objectives[objId].isComplete

	if QuestUtils.isSpecialTrainQuest(questData.configId) then
		return baseFined and QuestUtils.getSpecialTrainQuestRewardFlags(questData.configId)
	end

	return baseFined
end

function QuestUtils.isMultiObjAndState(questId)
	local questConfig = QuestUtils.getQuestConfig(questId)

	if questConfig == nil or questConfig.objectivesIDs == nil then
		return false
	end

	return #questConfig.objectivesIDs > 1
end

function QuestUtils.getQuestObjData(questId, objId)
	local questData = QuestUtils.getQuestData(questId)

	return QuestUtils.getQuestDataObjData(questData, objId)
end

function QuestUtils.getQuestDataObjData(questData, objId)
	if questData ~= nil and questData.objectives ~= nil then
		return questData.objectives[objId]
	end
end

function QuestUtils.isQuestDataComActionObjcFined(questId, comActionObjId)
	local ca = pg.me and pg.me.questCompleteActions and pg.me.questCompleteActions[questId]

	if ca == nil or ca.comActionObjcvs == nil or ca.comActionObjcvs[comActionObjId] == nil then
		return true
	end

	return ca.comActionObjcvs[comActionObjId].isComplete
end

function QuestUtils.getQuestDataObjVal(questId, objId)
	local objData = QuestUtils.getQuestObjData(questId, objId)

	return objData and objData.currentCnt or 0
end

function QuestUtils.getQuestObjConfig(questId, objId)
	if questId == nil or objId == nil then
		return nil
	end

	local questConfig = QuestUtils.getQuestConfig(questId)

	return questConfig ~= nil and questConfig.objectives[objId] or nil
end

function QuestUtils.getQuestName(questId)
	local questConfig = QuestUtils.getQuestConfig(questId)

	return questConfig ~= nil and questConfig.title or nil
end

function QuestUtils.getQuestDesc(questId)
	local questConfig = QuestUtils.getQuestConfig(questId)

	return questConfig ~= nil and questConfig.desc or nil
end

function QuestUtils.getEntityQuestDialogInfo(entity)
	local questInfo_StaticId = EntityQuestData.staticIds[entity.staticId or 0]
	local questInfo_TemplateId

	if Utils.isEnvObj(entity) then
		questInfo_TemplateId = EntityQuestData.envObjTemplateIds[entity.templateId or 0]
	else
		local petPrototypeId = entity:getConfigData().petPrototypeId

		questInfo_TemplateId = EntityQuestData.petProtoTypeIds[petPrototypeId or 0]
	end

	if questInfo_StaticId == nil and questInfo_TemplateId == nil then
		return nil
	end

	local entityQuestInfo = {}

	if questInfo_StaticId then
		for i = 1, #questInfo_StaticId do
			local temp = questInfo_StaticId[i]

			if QuestCommonUtils.getQuestState(pg.me, temp.questId) == temp.state then
				local dialogId, isDeliver = QuestUtils.getDialogIDByState(temp.questId, temp.state)

				if dialogId then
					table.insert(entityQuestInfo, {
						questId = temp.questId,
						state = temp.state,
						dialogId = dialogId,
						isDeliver = isDeliver
					})
				else
					local dialogueGraphId, isDialogueDeliver = QuestUtils.getDialogueGraphIDByState(temp.questId, temp.state)

					if dialogueGraphId then
						table.insert(entityQuestInfo, {
							questId = temp.questId,
							state = temp.state,
							dialogueGraphId = dialogueGraphId,
							isDeliver = isDialogueDeliver
						})
					end
				end
			end
		end
	end

	if questInfo_TemplateId then
		for i = 1, #questInfo_TemplateId do
			local temp = questInfo_TemplateId[i]

			if QuestUtils.isQuestInState(temp.questId, temp.state) then
				local dialogId, isDeliver = QuestUtils.getDialogIDByState(temp.questId, temp.state)

				if dialogId then
					table.insert(entityQuestInfo, {
						questId = temp.questId,
						state = temp.state,
						dialogId = dialogId,
						isDeliver = isDeliver
					})
				else
					local dialogueGraphId, isDialogueDeliver = QuestUtils.getDialogueGraphIDByState(temp.questId, temp.state)

					if dialogueGraphId then
						table.insert(entityQuestInfo, {
							questId = temp.questId,
							state = temp.state,
							dialogueGraphId = dialogueGraphId,
							isDeliver = isDialogueDeliver
						})
					end
				end
			end
		end
	end

	local function Sort(a, b)
		return a.state > b.state
	end

	table.sort(entityQuestInfo, Sort)

	return entityQuestInfo
end

function QuestUtils.getDialogIDByState(questId, state)
	local questConfig = QuestUtils.getQuestConfig(questId)

	if state == QuestConst.QUEST_STATE.UNRECEIVE then
		return questConfig.receiveDialog, false
	elseif state == QuestConst.QUEST_STATE.COMPLETED then
		return questConfig.deliverDialog, true
	end
end

function QuestUtils.getDialogueGraphIDByState(questId, state)
	local questConfig = QuestUtils.getQuestConfig(questId)

	if state == QuestConst.QUEST_STATE.UNRECEIVE then
		return questConfig.recvDialogueGraph, false
	elseif state == QuestConst.QUEST_STATE.COMPLETED then
		return questConfig.deliverDialogueGraph, true
	end
end

function QuestUtils.checkEntityHasTracingQuest(staticId)
	if staticId == nil or staticId == 0 then
		return false
	end

	local entityQuestData_StaticId = EntityQuestData.staticIds and EntityQuestData.staticIds[staticId]

	if entityQuestData_StaticId == nil then
		return false
	end

	for k, v in pairs(entityQuestData_StaticId) do
		local questId = v.questId
		local questData = QuestUtils.getQuestData(questId)

		if questData ~= nil and questData.state == v.state and QuestUtils.isQuestDataTracing(questData) then
			return true
		end
	end

	return false
end

function QuestUtils.isEntityHasRelatedQuest(entity)
	local entityQuestData_StaticId = EntityQuestData.staticIds and EntityQuestData.staticIds[entity.staticId or 0]

	if entityQuestData_StaticId ~= nil then
		return true
	end

	if Utils.isEnvObj(entity) then
		local entityQuestData_TemplateId = EntityQuestData.envObjTemplateIds and EntityQuestData.envObjTemplateIds[entity.templateId or 0]

		if entityQuestData_TemplateId ~= nil then
			return true
		end
	else
		local entityQuestData_TemplateId = EntityQuestData.templateIds and EntityQuestData.templateIds[entity.templateId or 0]

		if entityQuestData_TemplateId ~= nil then
			return true
		end

		local petPrototypeId = entity:getConfigData().petPrototypeId
		local entityQuestData_PetPrototypeId = EntityQuestData.envObjTemplateIds and EntityQuestData.envObjTemplateIds[petPrototypeId or 0]

		if entityQuestData_PetPrototypeId ~= nil then
			return true
		end
	end

	return false
end

function QuestUtils.isEntityHasConsumeQuest(entity)
	local entityQuestData_StaticId = EntityQuestData.staticIds and EntityQuestData.staticIds[entity.staticId or 0]

	if QuestUtils.entityQuestObjcvHasConsumeQuest(entityQuestData_StaticId) then
		return true
	end

	if Utils.isEnvObj(entity) then
		local entityQuestData_TemplateId = EntityQuestData.envObjTemplateIds and EntityQuestData.envObjTemplateIds[entity.templateId or 0]

		if QuestUtils.entityQuestObjcvHasConsumeQuest(entityQuestData_TemplateId) then
			return true
		end
	else
		local entityQuestData_TemplateId = EntityQuestData.templateIds and EntityQuestData.templateIds[entity.templateId or 0]

		if QuestUtils.entityQuestObjcvHasConsumeQuest(entityQuestData_TemplateId) then
			return true
		end

		local petPrototypeId = entity:getConfigData().petPrototypeId
		local entityQuestData_PetPrototypeId = EntityQuestData.envObjTemplateIds and EntityQuestData.envObjTemplateIds[petPrototypeId or 0]

		if QuestUtils.entityQuestObjcvHasConsumeQuest(entityQuestData_PetPrototypeId) then
			return true
		end
	end

	return false
end

function QuestUtils.entityQuestObjcvHasConsumeQuest(data)
	if data == nil then
		return false
	end

	for i = 1, #data do
		local temp = data[i]
		local objConfig = QuestUtils.getQuestObjConfig(temp.questId, temp.objId)

		if objConfig ~= nil and QuestUtils.isQuestInState(temp.questId, temp.state) and not QuestUtils.isQuestObjFined(temp.questId, temp.objId) and (objConfig.paramVals[1] == "ITEM_CONSUME" or objConfig.paramVals[1] == "PET_CONSUME") then
			return true
		end
	end

	return false
end

function QuestUtils.getRootQuestId(questId)
	local questConfig = QuestUtils.getQuestConfig(questId)

	if not questConfig then
		return 0
	end

	local isParentQuest = QuestUtils.isParentQuest(questId)
	local parentQuestId = isParentQuest and questId or questConfig.parentQuest

	while parentQuestId ~= nil do
		questConfig = QuestUtils.getQuestConfig(parentQuestId)

		if not questConfig or questConfig.parentQuest == nil then
			break
		end

		parentQuestId = questConfig.parentQuest
	end

	return parentQuestId
end

function QuestUtils.getParentQuestId(questId)
	if QuestUtils.isParentQuest(questId) then
		return questId
	end

	local questConfig = QuestUtils.getQuestConfig(questId)

	if questConfig ~= nil then
		return questConfig.parentQuest
	end
end

function QuestUtils.isParentQuest(questId)
	if not questId or questId == 0 then
		return false
	end

	local questConfig = QuestUtils.getQuestConfig(questId)

	if questConfig ~= nil then
		return questConfig.subQuests ~= nil
	else
		return false
	end
end

function QuestUtils.getChildQuests(questId)
	local questConfig = QuestUtils.getQuestConfig(questId)

	if questConfig ~= nil and questConfig.subQuests ~= nil then
		return questConfig.subQuests.all
	end
end

function QuestUtils.isAssessmentTask(questId)
	local questGroupId = QuestUtils.getParentQuestId(questId)

	if questGroupId == nil then
		return false
	end

	local assessment = false

	for i, v in pairs(PlayerTitleData) do
		if v.quest == questGroupId then
			assessment = true

			break
		end
	end

	return assessment
end

function QuestUtils.isChildQuest(questId)
	local questConfig = QuestUtils.getQuestConfig(questId)

	if questConfig ~= nil then
		return questConfig.parentQuest ~= nil
	end

	return false
end

function QuestUtils.canQuestDataClaim(questData)
	return QuestUtils.isQuestDataInState(questData, QuestConst.QUEST_STATE.UNRECEIVE)
end

function QuestUtils.isQuestFinished(questId)
	local questData = QuestUtils.getQuestData(questId)

	if questData ~= nil then
		return QuestUtils.isQuestDataFinished(questData)
	else
		return QuestUtils.isQuestSubmitted(questId)
	end
end

function QuestUtils.isQuestDataFinished(questData)
	return QuestUtils.isQuestDataInState(questData, QuestConst.QUEST_STATE.COMPLETED)
end

function QuestUtils.isQuestDataFailed(questData)
	return QuestUtils.isQuestDataInState(questData, QuestConst.QUEST_STATE.FAILED)
end

function QuestUtils.isQuestSubmitted(questId)
	if not pg.me or questId == nil or questId == 0 then
		return false
	end

	return Bitset.getBit(pg.me.questAwardFlags, questId)
end

function QuestUtils.isQuestInState(questId, state)
	if pg.me == nil then
		return false
	end

	return QuestCommonUtils.getQuestState(pg.me, questId) == state
end

function QuestUtils.getQuestState(questId)
	local questData = QuestUtils.getQuestData(questId)

	if questData == nil then
		return nil
	end

	return questData.state
end

function QuestUtils.isQuestDataInState(questData, state)
	if questData == nil then
		return false
	end

	return questData.state == state
end

function QuestUtils.isQuestVisible(questId)
	local questConfig = QuestUtils.getQuestConfig(questId)

	if questConfig == nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("isQuestVisible： 任务配置不存在！", questId)
		end

		return false
	end

	return QuestUtils.isQuestConfigVisible(questConfig)
end

function QuestUtils.isQuestConfigVisible(questConfig)
	if questConfig == nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("isQuestVisible： 任务配置不存在！")
		end

		return false
	end

	local curGuideCourseId = pg.me.curGuideCourseId

	if curGuideCourseId ~= nil and curGuideCourseId ~= 0 and questConfig.questType ~= QuestConst.QUEST_TYPE.COURSE then
		return false
	end

	return questConfig.visible or false
end

function QuestUtils.getTracingFinishedQuestType()
	local tracingQuest = QuestUtils.getTracingQuest()

	if tracingQuest == nil then
		return 0
	end

	local questConfig = QuestUtils.getQuestConfig(tracingQuest.configId)

	return questConfig.questType - 1
end

function QuestUtils.questManualJump(jumpType, id)
	if jumpType == nil or id == nil or id[1] == nil or id[1] <= 0 then
		return
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_QUEST_PANEL) then
		pg.global.ui.quest:selectTabByMainType(jumpType, id[1])

		if jumpType == QuestConst.QUEST_MANUAL_JUMP_TYPE.QUEST then
			-- block empty
		end
	elseif jumpType == QuestConst.QUEST_MANUAL_JUMP_TYPE.QUEST then
		local chapterId = QuestUtils.getQuestChapterIdBySectionId(id[1])
		local questGroupId = QuestUtils.getQuestMainGroupId(chapterId, id[1])

		pg.global.ui:open(UIConst.UI_ID_QUEST_PANEL, {
			questId = questGroupId
		})
	elseif jumpType == QuestConst.QUEST_MANUAL_JUMP_TYPE.CLUE then
		local questId = QuestUtils.getQuestJumpClueQuestId(id[1])

		pg.global.ui:open(UIConst.UI_ID_QUEST_PANEL, {
			questId = questId
		})
	end
end

function QuestUtils.getFirstUnfinishedManualSection(idList)
	if not Utils.isTable(idList) then
		return nil
	end

	local firstSectionId, firstGroupId

	for _, sectionId in ipairs(idList) do
		if sectionId and tonumber(sectionId) and tonumber(sectionId) > 0 then
			local chapterId = QuestUtils.getQuestChapterIdBySectionId(sectionId)
			local questGroupId = chapterId and QuestUtils.getQuestMainGroupId(chapterId, sectionId)

			if questGroupId and questGroupId > 0 then
				if firstSectionId == nil then
					firstSectionId, firstGroupId = sectionId, questGroupId
				end

				if QuestUtils.isQuestInState(questGroupId, QuestConst.QUEST_STATE.RECEIVED) then
					return sectionId, questGroupId
				end
			end
		end
	end

	return firstSectionId, firstGroupId
end

function QuestUtils.hasSectionConfig(sectionId)
	local id = tonumber(sectionId)

	return id and QuestMainSectionChapterIdData[id] ~= nil
end

function QuestUtils.getFirstSectionQuestIdByChapterId(chapterId)
	local chapterData = QuestMain[chapterId]

	if chapterData then
		for _, sectionCfg in pairs(chapterData) do
			return sectionCfg.questGroupId
		end
	end

	return nil
end

function QuestUtils.questManualJumpAndTrace(id)
	if not Utils.isTable(id) or #id == 0 then
		return
	end

	local firstId = id[1]
	local isSection = QuestUtils.hasSectionConfig(firstId)

	if isSection then
		for _, sectionId in ipairs(id) do
			if not QuestUtils.hasSectionConfig(sectionId) and LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("QuestUtils.questManualJumpAndTrace invalid sectionId=%s, not found in quest_main_section_chapter_id", sectionId)
			end
		end

		local sectionId, questGroupId = QuestUtils.getFirstUnfinishedManualSection(id)

		if sectionId == nil or questGroupId == nil then
			return
		end

		if pg.global.ui:checkUIOpen(UIConst.UI_ID_QUEST_PANEL) then
			pg.global.ui.quest:selectTabByMainType(QuestConst.QUEST_MANUAL_JUMP_TYPE.QUEST, sectionId)
		else
			pg.global.ui:open(UIConst.UI_ID_QUEST_PANEL, {
				questId = questGroupId
			}, function()
				if pg.global.ui and pg.global.ui.quest then
					pg.global.ui.quest:selectTabByMainType(QuestConst.QUEST_MANUAL_JUMP_TYPE.QUEST, sectionId)
				end
			end)
		end

		pg.game.quest:forceTracedQuest(questGroupId)
	end
end

function QuestUtils.getFirstObjectiveData(rootQuestId, objectives)
	objectives = objectives or QuestUtils.getReceivedQuestObjectives(rootQuestId, false)

	if not objectives or #objectives == 0 then
		return nil
	end

	return objectives[1]
end

function QuestUtils.doQuestHudVAction(rootQuestId)
	local objcvData = QuestUtils.getFirstObjectiveData(rootQuestId)

	if not objcvData or not objcvData.questId then
		return
	end

	local questId = objcvData.questId
	local isQuitHomeland = QuestUtils.needQuitOtherHomeland(questId)
	local isShowPathfinding, _ = QuestUtils.canQuestShowPathfindingFlag(questId)
	local isShowPlayDialogue, dialogueId = QuestUtils.canShowPlayDialogue(questId)
	local isShowSourceBtn, sourceId = QuestUtils.canTraceItemSource(questId)
	local isQuitTip = QuestUtils.needQuitTeam(questId) or isQuitHomeland or QuestUtils.isInQuestBlackList(questId)
	local isReDoQuestComplete = QuestUtils.isReDoQuestComplete(questId)
	local isReceiveNpcTarget = objcvData.isReceiveNpcTarget
	local isStoryTab = QuestUtils.getPageType(rootQuestId) == QuestConst.QUEST_HUD_PAGE_TYPE.STORY
	local isLevelUpQuest = SysConfigData.NEED_SWITCH_LEVEL_UP_QUEST_IDS and table.contains(SysConfigData.NEED_SWITCH_LEVEL_UP_QUEST_IDS, questId)
	local isSwitchPageQuest = SysConfigData.NEED_SWITCH_GROW_QUEST_ID and table.contains(SysConfigData.NEED_SWITCH_GROW_QUEST_ID, questId)
	local runTokenId, runTokenText

	if QuestUtils.isRunCondNotMet(questId) then
		runTokenId, runTokenText = QuestUtils.getRunCondTimeTokenInfo(questId)
	end

	if runTokenId then
		ClientUtils.showBubbleMessageRaw(runTokenText, 3)

		return
	end

	if isQuitTip then
		if QuestUtils.isInQuestBlackList(questId) or QuestCommonUtils.getQuestState(pg.me, questId) == QuestConst.QUEST_STATE.UNRECEIVE then
			local tipsText = string.match(pg.getGameString("QUEST_CANNOT_PROGRESS_TARGET_TEXT"), "%%s%s*(.+)")

			ClientUtils.showBubbleMessageRaw(tipsText, 3)
		else
			local tipsText = isQuitHomeland and pg.getGameString("QUEST_CANNOT_DO_IN_OTHER_HOME") or pg.getGameString("QUEST_CANNOT_DO_IN_OTHER_WORLD")

			ClientUtils.showBubbleMessageRaw(tipsText, 3)
		end
	elseif isReceiveNpcTarget then
		QuestUtils.pathfindingToReceiveNpc(questId)
	elseif isReDoQuestComplete then
		local comActionDialogueId = QuestUtils.getComActionObjcvDialogueId(questId)

		if comActionDialogueId and comActionDialogueId > 0 then
			QuestUtils.tryPlayDialogueGraph(comActionDialogueId, questId)
		else
			pg.me:reDoQuestCompleteActions(questId)
		end
	elseif isSwitchPageQuest and isStoryTab then
		QuestUtils.switchHudPageType(QuestConst.QUEST_HUD_PAGE_TYPE.GROW)

		if pg.global.ui and pg.global.ui.tips and pg.global.ui.tips.quest then
			pg.global.ui.tips.quest:switchQuestPageType(QuestConst.QUEST_HUD_PAGE_TYPE.GROW)
		end
	elseif isLevelUpQuest and isStoryTab then
		pg.me:doEventByData({
			"appearHelp",
			{
				209
			}
		})
	elseif not isShowSourceBtn and isShowPathfinding then
		QuestUtils.addQuestPathingNavEffect(questId)
	elseif isShowPlayDialogue and dialogueId and dialogueId > 0 then
		pg.game.dialogue:playDialogueGraph(dialogueId)
	elseif isShowSourceBtn and sourceId and sourceId > 0 then
		local data = {
			clueSeekID = sourceId
		}

		table.merge(data, ItemSourceData[sourceId])
		LuaUIUtils.clueSeek(data, nil)
	end
end

function QuestUtils.questManualForce(questId, autoV)
	if questId == nil or questId == 0 then
		return
	end

	if QuestUtils.isQuestOfClueQuestType(questId) then
		QuestUtils.clueQuestTrace(questId, true)

		return
	end

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_QUEST_PANEL) then
		pg.global.ui:close(UIConst.UI_ID_QUEST_PANEL)
	end

	local rootQuestId = QuestUtils.getRootQuestId(questId)

	if rootQuestId == nil or rootQuestId == 0 then
		rootQuestId = QuestUtils.getParentQuestId(questId)
	end

	if rootQuestId == nil or rootQuestId == 0 then
		return
	end

	if not QuestUtils.isQuestInState(rootQuestId, QuestConst.QUEST_STATE.RECEIVED) then
		return
	end

	pg.me:traceQuest(rootQuestId, true)

	local pageType = QuestUtils.getPageType(rootQuestId)

	QuestUtils.switchHudPageType(pageType, true)

	if pg.global.ui and pg.global.ui.tips and pg.global.ui.tips.quest then
		pg.global.ui.tips.quest:switchQuestPageType(pageType)
	end

	if autoV == 1 then
		QuestUtils.doQuestHudVAction(rootQuestId)
	end
end

function QuestUtils.getMainQuestChapterConfig(questId)
	return QuestMainRevertData[questId]
end

function QuestUtils.getQuestGroupChapterInfo(questId)
	if questId == nil or questId == 0 then
		return 0, 0
	end

	local isParentQuest = QuestUtils.isParentQuest(questId)
	local questGroupId = isParentQuest and questId or QuestUtils.getRootQuestId(questId)
	local chapterInfo = QuestMainRevertData[questGroupId]

	if chapterInfo == nil then
		return 0, 0
	end

	return chapterInfo.chapterId, chapterInfo.sectionId
end

function QuestUtils.isCurtainQuest(questId)
	local chapterInfo = QuestMainRevertData[questId]

	if chapterInfo == nil then
		return false
	end

	local scetionInfo = QuestMain[chapterInfo.chapterId] and QuestMain[chapterInfo.chapterId][chapterInfo.sectionId]

	return scetionInfo ~= nil
end

function QuestUtils.getChapterName(chapterId)
	if chapterId == nil or chapterId == 0 then
		return ""
	end

	local chapterInfo = QuestChapter[chapterId]

	if chapterInfo == nil then
		return ""
	end

	return chapterInfo.chapterName and pg.getLocalizationText(chapterInfo.chapterName)
end

function QuestUtils.getCurtainQuestName(questId)
	if questId == nil or questId == 0 then
		return ""
	end

	local isParentQuest = QuestUtils.isParentQuest(questId)
	local questGroupId = isParentQuest and questId or QuestUtils.getRootQuestId(questId)
	local chapterInfo = QuestMainRevertData[questGroupId]

	if chapterInfo == nil then
		return ""
	end

	return QuestUtils.getQuestSectionName(chapterInfo.chapterId, chapterInfo.sectionId)
end

function QuestUtils.getQuestSectionName(chapterId, sectionId)
	if chapterId == nil or chapterId == 0 or sectionId == nil or sectionId == 0 then
		return ""
	end

	local scetionInfo = QuestMain[chapterId][sectionId]

	return scetionInfo.sectionName and pg.getLocalizationText(scetionInfo.sectionName)
end

function QuestUtils.gotoClueQuestId(chapterId, sectionId)
	if chapterId == nil or chapterId == 0 or sectionId == nil or sectionId == 0 then
		return nil
	end

	local scetionInfo = QuestMain[chapterId][sectionId]

	return scetionInfo and scetionInfo.gotoClueQuestId
end

function QuestUtils.getChapterSectionIds(chapterId)
	if chapterId == nil or chapterId == 0 then
		return {}
	end

	local chapterData = QuestMain[chapterId]

	if not chapterData then
		return {}
	end

	local ids = {}

	for _, sectionCfg in pairs(chapterData) do
		if sectionCfg.questGroupId then
			table.insert(ids, sectionCfg.questGroupId)
		end

		if sectionCfg.gotoClueQuestId then
			table.insert(ids, sectionCfg.gotoClueQuestId)
		end
	end

	return ids
end

function QuestUtils.hasChapterAnyQuestReceived(chapterId)
	local ids = QuestUtils.getChapterSectionIds(chapterId)

	for _, id in ipairs(ids) do
		if QuestUtils.isQuestOfClueQuestType(id) then
			if (QuestUtils.isQuestInState(id, QuestConst.QUEST_STATE.RECEIVED) or QuestUtils.isQuestFinished(id)) and QuestUtils.isClueReveal(id) then
				return true
			end
		elseif QuestUtils.isQuestInState(id, QuestConst.QUEST_STATE.RECEIVED) or QuestUtils.isQuestFinished(id) then
			return true
		end
	end

	return false
end

QuestUtils.QuestType2IconMap = {
	[QuestConst.QUEST_TYPE.SIDE] = {
		[0] = AddressDataConst.QUEST_ICON_BRANCH_RECEIVE,
		AddressDataConst.QUEST_ICON_BRANCH_SUBMIT,
		AddressDataConst.QUEST_ICON_BRANCH_UNDERWAY
	},
	[QuestConst.QUEST_TYPE.COURSE] = {
		[0] = AddressDataConst.QUEST_ICON_COURSE_RECEIVE,
		AddressDataConst.QUEST_ICON_COURSE_SUBMIT,
		AddressDataConst.QUEST_ICON_COURSE_UNDERWAY
	},
	[QuestConst.QUEST_TYPE.MAIN] = {
		[0] = AddressDataConst.QUEST_ICON_MAIN_RECEIVE,
		AddressDataConst.QUEST_ICON_MAIN_SUBMIT,
		AddressDataConst.QUEST_ICON_MAIN_UNDERWAY
	},
	[QuestConst.QUEST_TYPE.SPECIAL_TRAIN] = {
		[0] = AddressDataConst.QUEST_ICON_TRAIN_RECEIVE,
		AddressDataConst.QUEST_ICON_TRAIN_SUBMIT,
		AddressDataConst.QUEST_ICON_TRAIN_UNDERWAY
	},
	[QuestConst.QUEST_TYPE.HOMELAND] = {
		[0] = AddressDataConst.QUEST_ICON_BRANCH_RECEIVE,
		AddressDataConst.QUEST_ICON_BRANCH_SUBMIT,
		AddressDataConst.QUEST_ICON_BRANCH_UNDERWAY
	},
	[QuestConst.QUEST_TYPE.CLUE] = {
		[0] = AddressDataConst.QUEST_ICON_BRANCH_RECEIVE,
		AddressDataConst.QUEST_ICON_BRANCH_SUBMIT,
		AddressDataConst.QUEST_ICON_BRANCH_UNDERWAY
	}
}

function QuestUtils.getQuestTypeIcon(questId)
	local questIcon
	local taskType = QuestUtils.getCurSideQuestShowType(questId)

	if taskType and taskType.styleType == QuestConst.QUEST_SHOW_TYPE.MANUAL_STYLE then
		questIcon = taskType.questIcon
	elseif taskType and taskType.styleType == QuestConst.QUEST_SHOW_TYPE.OTHER_STYLE then
		questIcon = taskType.deliverIcon
	end

	return questIcon or AddressDataConst.QUEST_ICON_MAIN_RECEIVE
end

function QuestUtils.isQuestIconOtherStyleType(questId)
	local flag = false
	local questShowStyle = QuestShowStyle[questId]

	if questShowStyle then
		flag = questShowStyle.styleType == QuestConst.QUEST_SHOW_TYPE.OTHER_STYLE
	end

	return flag
end

function QuestUtils.getQuestType(questId)
	local questConfig = QuestUtils.getQuestConfig(questId)

	if not questConfig then
		return nil
	end

	return questConfig.questType
end

function QuestUtils.isMainQuestType(questId)
	if questId == nil or questId == 0 then
		return false
	end

	local questConfig = QuestUtils.getQuestConfig(questId)

	if not questConfig then
		return false
	end

	return questConfig.questType == QuestConst.QUEST_TYPE.MAIN
end

function QuestUtils.isQuestOfQuestType(questId, questType)
	if questId == nil or questId == 0 then
		return false
	end

	local questConfig = QuestUtils.getQuestConfig(questId)

	return QuestUtils.isQuestDataOfQuestType(questConfig, questType)
end

function QuestUtils.isQuestOfClueQuestType(questId)
	if questId == nil or questId == 0 then
		return false
	end

	local questConfig = QuestUtils.getQuestConfig(questId)

	return QuestUtils.isQuestDataOfQuestType(questConfig, QuestConst.QUEST_TYPE.CLUE)
end

function QuestUtils.getQuestLocalizedTextField(questId, fieldName)
	local questConfig = QuestUtils.getQuestConfig(questId)

	if not questConfig then
		return ""
	end

	if not questConfig[fieldName] then
		local parentQuestConfig = QuestUtils.getQuestConfig(questConfig.parentQuest)

		if not parentQuestConfig or not parentQuestConfig[fieldName] then
			return nil
		end

		return pg.getLocalizationText(parentQuestConfig[fieldName])
	end

	return pg.getLocalizationText(questConfig[fieldName])
end

function QuestUtils.isQuestDataOfQuestType(questConfig, questType)
	if questConfig == nil then
		return false
	end

	return questConfig.questType == questType
end

function QuestUtils.isSpecialTrainMainQuest(questId)
	local data = SpecialTrainRevertData[questId]

	return data and data.isMainQuest or false
end

function QuestUtils.isSpecialTrainCompulsoryQuest(questId)
	local data = SpecialTrainRevertData[questId]

	return data and data.mainSubType == QuestConst.TRAIN_COMPULSORY_SUB_TYPE.COMPULSORY or false
end

function QuestUtils.isSpecialTrainChallengeQuest(questId)
	local data = SpecialTrainRevertData[questId]

	return data and data.mainSubType == QuestConst.TRAIN_COMPULSORY_SUB_TYPE.CHALLENGE or false
end

function QuestUtils.getQuestInteractDescAndIcon(questId)
	local questConfig = QuestUtils.getQuestConfig(questId)

	if not questConfig then
		return "", ""
	end

	local deliverDesc = questConfig.deliverDesc

	if deliverDesc == nil or deliverDesc == "" then
		deliverDesc = QuestUtils.getCurtainQuestName(questId)
	end

	return deliverDesc, QuestUtils.getQuestTypeIcon(questId)
end

function QuestUtils.addQuestPathingNavEffect(questId)
	local targetInfo, nearId, objId = QuestUtils.getCurTracingQuestCanAddNavId(questId)

	if targetInfo == nil or targetInfo == 0 then
		return
	end

	if LuaUIUtils.checkTeleportLimit(targetInfo.scene) then
		return
	end

	if nearId and nearId > 0 then
		facade:sendMsgToUI(MessageName.QUEST_ON_TAB_SWITCH, {
			questId = nearId
		})
	end

	local markId = tonumber(string.format("%s%s", nearId, objId))

	pg.game.map:manualTraceQuestMark(Const.MAP_MARK_QUEST, markId, true)
	QuestUtils.navigateToTarget(targetInfo, markId)
end

function QuestUtils.pathfindingToTargetPosition(scene, pathfindingId, questId)
	if scene == nil or pathfindingId == nil then
		return
	end

	if LuaUIUtils.checkTeleportLimit(scene) then
		return
	end

	local targetScenePositionData = SceneUtils.getSceneTargetPositionData(scene)
	local targetScenePosition = targetScenePositionData and targetScenePositionData[pathfindingId] or nil

	if targetScenePosition then
		local targetInfo = {
			scene = scene,
			position = targetScenePosition.position
		}
		local combineId = QuestUtils.getCombinedId(questId, QuestConst.QUEST_DEFAULT_OBJ_ID)
		local arg = {
			arg5 = 1,
			arg4 = 1,
			arg1 = 1,
			arg2 = questId,
			arg3 = QuestConst.QUEST_STATE.UNRECEIVE,
			arg6 = targetInfo.scene,
			arg7 = QuestConst.QUEST_DEFAULT_OBJ_ID
		}
		local markId = pg.game.map:addOrUpdateTempMark(targetInfo.scene, targetInfo.position[1], targetInfo.position[2], targetInfo.position[3], combineId, Const.MAP_MARK_QUEST, arg)

		targetInfo.markId = markId

		pg.game.quest:addDialogueQuestTargetsInfo(questId, targetInfo)
		pg.game.map:manualTraceQuestMark(Const.MAP_MARK_QUEST, markId, true)
		QuestUtils.navigateToTarget(targetInfo, combineId)
	end
end

function QuestUtils.tryPlayDialogueGraph(dialogueId, questId)
	if dialogueId == nil or dialogueId <= 0 or questId == nil or questId <= 0 then
		return
	end

	local state = QuestUtils.canPlayDialogueGraph(dialogueId)

	if state == QuestConst.QUEST_TRACK_POS_STATE.CAN then
		pg.me:reDoQuestCompleteActions(questId)
	elseif state == QuestConst.QUEST_TRACK_POS_STATE.NO_CAN then
		local scene, targetPosition = QuestUtils.getDialogueGraphTargetPosition(dialogueId)

		QuestUtils.pathfindingToTargetPosition(scene, targetPosition, questId)
	else
		pg.me:reDoQuestCompleteActions(questId)
	end
end

function QuestUtils.isShowQuestDialogueGraphMark(questId)
	if questId == nil or questId <= 0 then
		return false
	end

	local dialogueId = QuestUtils.getComActionObjcvDialogueId(questId)

	if dialogueId and dialogueId > 0 then
		local state = QuestUtils.canPlayDialogueGraph(dialogueId)

		if state == QuestConst.QUEST_TRACK_POS_STATE.NO_CAN then
			return true
		end
	end
end

function QuestUtils.canPlayDialogueGraph(dialogueGraphId)
	local dgc = DialogueGraphConfig[dialogueGraphId]

	if dgc == nil or pg.me == nil then
		return QuestConst.QUEST_TRACK_POS_STATE.NULL
	end

	if dgc.sceneId ~= nil then
		local curSceneId = pg.me.space.sceneId

		if dgc.sceneId ~= curSceneId then
			return QuestConst.QUEST_TRACK_POS_STATE.NULL
		end

		if dgc.targetPosition ~= nil then
			local targetScenePositionData = SceneUtils.getSceneTargetPositionData(dgc.sceneId)
			local targetScenePosition = targetScenePositionData and targetScenePositionData[dgc.targetPosition] or nil

			if targetScenePosition then
				local curPos = pg.me:getPosition()
				local distance = Vector3.SqrMagnitude(targetScenePosition.position - curPos)

				if distance > ClientConst.DIALOGUE_GRAPH_PLAY_APPROXIMATELY_EPS then
					return QuestConst.QUEST_TRACK_POS_STATE.NO_CAN
				end
			end
		end
	end

	return QuestConst.QUEST_TRACK_POS_STATE.CAN
end

function QuestUtils.getDialogueGraphTargetPosition(dialogueGraphId)
	local dgc = DialogueGraphConfig[dialogueGraphId]

	if dgc ~= nil then
		return dgc.sceneId, dgc.targetPosition
	end

	return nil
end

function QuestUtils.getQuestChapterIdBySectionId(sectionId)
	local data = QuestMainSectionChapterIdData[sectionId]

	if data ~= nil then
		return data.chapterId
	end
end

function QuestUtils.getQuestIdBySectionId(sectionId)
	local data = QuestMainSectionChapterIdData[sectionId]

	if data ~= nil then
		return data.questGroupId
	end
end

function QuestUtils.getQuestMainGroupId(chapterId, sectionId)
	local data = QuestMain[chapterId][sectionId]

	if data ~= nil then
		return data.questGroupId
	end
end

function QuestUtils.getCurTracingQuestCanAddNavId(questId)
	local distance = 1000
	local nearestQuestId = 0
	local objId = 0
	local nearQuestTargetInfo = {}
	local isShowPathfinding, canShowPathfindingDatas = QuestUtils.canQuestShowPathfindingFlag(questId)

	if not isShowPathfinding then
		return nearQuestTargetInfo, nearestQuestId, objId
	end

	local targetInfo, targetDistance

	for _, questData in pairs(canShowPathfindingDatas) do
		local questTargetInfo = QuestUtils.getQuestTargetInfo(questData, true)

		if questTargetInfo ~= nil then
			targetInfo, targetDistance = QuestUtils.getNearQuestPathingNavData(questTargetInfo.posInfo)

			if targetDistance < distance then
				nearQuestTargetInfo = targetInfo
				objId = questData.objId
				nearestQuestId = questData.configId
			end

			distance = targetDistance < distance and targetDistance or distance
		end
	end

	return nearQuestTargetInfo, nearestQuestId, objId
end

function QuestUtils.getNearQuestPathingNavData(posInfos)
	if not posInfos then
		return
	end

	local targetInfo = {}
	local distance = 999
	local tempDistance = 0

	if #posInfos > 0 then
		for i = 1, #posInfos do
			local tempInfo = posInfos[i]

			if tempInfo and tempInfo.pos then
				tempDistance = Vector3.Distance(tempInfo.pos, pg.me:getPosition())

				if tempDistance ~= distance then
					targetInfo = tempInfo.posConfig
				end

				distance = tempDistance < distance and tempDistance or distance
			end
		end
	end

	return targetInfo, distance
end

function QuestUtils.removeQuestPathingNavEffect(questId, successCallback)
	if pg.game and pg.game.navEffect and questId then
		pg.game.navEffect:unPath(questId, successCallback)
	end
end

function QuestUtils.getQuestMarkInfo(questId, objId, key)
	local result = {
		desc = "",
		subDesc = "",
		title = ""
	}

	if not questId then
		return result
	end

	local cfg = QuestUtils.getQuestConfig(questId)

	if not cfg then
		return result
	end

	if cfg.questType == QuestConst.QUEST_TYPE.CLUE then
		return QuestUtils.getClueQuestMarkInfo(questId, objId, result)
	end

	return QuestUtils.getNormalQuestMarkInfo(questId, result, key)
end

function QuestUtils.getClueQuestMarkInfo(questId, objId, result)
	result.title = QuestUtils.getQuestLocalizedTextField(questId, "name")
	result.desc = QuestUtils.getQuestLocalizedTextField(questId, "fullDesc")
	result.subDesc = "\n"

	local objectivesData, _ = QuestUtils.getReceivedQuestTargetObjective(questId, false)

	if objectivesData then
		local desc = QuestUtils.formatObjectiveDesc(objectivesData, questId, objId)

		result.subDesc = string.format("%s\n", desc)
	end

	result.rewardTable = LuaUIUtils.getRewardItemByDropId(QuestsConfigData[questId].rewardId)

	return result
end

function QuestUtils.getNormalQuestMarkInfo(questId, result, key)
	local isParentQuest = QuestUtils.isParentQuest(questId)
	local rootQuestId = isParentQuest and questId or QuestUtils.getRootQuestId(questId)

	if not rootQuestId then
		return result
	end

	local revertData = QuestMainRevertData[rootQuestId]

	if revertData then
		QuestUtils.fillMainQuestMarkInfo(rootQuestId, revertData, result)
	else
		QuestUtils.fillNormalQuestMarkInfo(questId, result)
	end

	return result[key] or result
end

function QuestUtils.fillMainQuestMarkInfo(rootQuestId, revertData, result)
	local questMainData = QuestMain[revertData.chapterId][revertData.sectionId]

	result.image = questMainData.imagePanel
	result.title = pg.getLocalizationText(questMainData.sectionName)
	result.desc = pg.getLocalizationText(questMainData.startDesc)

	local objectives, _ = QuestUtils.getReceivedQuestObjectives(rootQuestId, false)

	result.subDesc = QuestUtils.formatObjectivesList(objectives)
	result.rewardTable = LuaUIUtils.getRewardItemByDropId(QuestsConfigData[rootQuestId].rewardId)
	result.chapter = revertData.chapterId
	result.section = revertData.chapterTypeId
end

function QuestUtils.fillNormalQuestMarkInfo(questId, result)
	local cfg = QuestUtils.getQuestConfig(questId)

	result.title = pg.getLocalizationText(cfg.title)
	result.desc = pg.getLocalizationText(cfg.desc)
	result.subDesc = pg.getLocalizationText(cfg.desc)
	result.rewardTable = LuaUIUtils.getRewardItemByDropId(QuestsConfigData[questId].rewardId)
end

function QuestUtils.formatObjectiveDesc(objectivesData, questId, objId)
	local val = objectivesData.objData and objectivesData.objData.currentCnt or 0
	local desc = ClientTextUtils.getLocalizationText(objectivesData.objConfig.desc, val)

	if objectivesData and objectivesData.objConfig and objectivesData.objConfig.showCanSelect then
		desc = QuestUtils.questObjectiveCanSelect(desc)
	end

	desc = string.format(" - %s", desc)

	local displayType = objectivesData.objConfig.displayType or 1
	local totalTargetVal = QuestUtils.getQuestObjectiveTargetVal(questId, objId)

	if objectivesData and objectivesData.objData and objectivesData.objData.isComplete then
		val = totalTargetVal
	end

	if displayType == QuestConst.QUEST_OBJCV_DISPLAY_TYPE.SHOW_COUNTING then
		local countingStr = string.format("[%s/%s]", val, totalTargetVal)

		desc = ClientTextUtils.concatByLanguage(desc, countingStr)
	end

	return desc
end

function QuestUtils.formatObjectivesList(objectives)
	local str = "\n"

	for _, data in pairs(objectives) do
		str = str .. "\n" .. QuestUtils.formatObjectiveDesc(data, data.questId, data.objId)
	end

	return str
end

function QuestUtils.getCombinedId(questId, objId)
	local combinedNumber

	if objId then
		combinedNumber = tonumber(tostring(questId) .. tostring(objId))
	else
		combinedNumber = questId
	end

	return combinedNumber
end

function QuestUtils.containsNested(preQuests, questId)
	if preQuests == nil then
		return false
	end

	for _, value in pairs(preQuests) do
		if value == questId then
			return true
		elseif Utils.isTable(value) and QuestUtils.containsNested(value, questId) then
			return true
		end
	end

	return false
end

function QuestUtils.isQuestAssociationPOIMark(questId, spawnerId, objId)
	if not pg.me then
		return false
	end

	if not spawnerId then
		return false
	end

	return QuestUtils.getQuestAssociationSpawnerSource(questId, objId, spawnerId) ~= QuestUtils.QUEST_POI_ASSOCIATION_SOURCE.NONE
end

function QuestUtils.getQuestAssociationSpawnerSource(questId, objId, spawnerId)
	if spawnerId == nil then
		return QuestUtils.QUEST_POI_ASSOCIATION_SOURCE.NONE
	end

	local targetPositionConfig, questSandBoxId

	if objId ~= nil then
		targetPositionConfig = QuestUtils.getQuestObjcvTargetPositionConfig(questId, objId)
		questSandBoxId = targetPositionConfig and tonumber(targetPositionConfig.sandboxId)
	else
		questSandBoxId = QuestUtils.getReceivedQuestObjcvSandBoxID(questId)
	end

	if questSandBoxId == spawnerId then
		return QuestUtils.QUEST_POI_ASSOCIATION_SOURCE.TARGET_SANDBOX
	end

	local questPOIAssociationMarkConfig = questSandBoxId and QuestPOIAssociationMarkData[questSandBoxId]
	local relateId = questPOIAssociationMarkConfig and tonumber(questPOIAssociationMarkConfig.RelateSandbox)

	if relateId and relateId > 0 and relateId == spawnerId then
		return QuestUtils.QUEST_POI_ASSOCIATION_SOURCE.RELATED_SANDBOX
	end

	local entityId = targetPositionConfig and tonumber(targetPositionConfig.entity)

	if entityId and entityId > 0 and entityId == spawnerId then
		return QuestUtils.QUEST_POI_ASSOCIATION_SOURCE.TARGET_ENTITY
	end

	return QuestUtils.QUEST_POI_ASSOCIATION_SOURCE.NONE
end

function QuestUtils.getQuestAssociationSpawnerIds(questId, objId)
	local result = {}
	local targetPositionConfig, questSandBoxId

	if objId ~= nil then
		targetPositionConfig = QuestUtils.getQuestObjcvTargetPositionConfig(questId, objId)
		questSandBoxId = targetPositionConfig and tonumber(targetPositionConfig.sandboxId)
	else
		questSandBoxId = QuestUtils.getReceivedQuestObjcvSandBoxID(questId)
	end

	if questSandBoxId and questSandBoxId > 0 then
		result[#result + 1] = questSandBoxId

		local questPOIAssociationMarkConfig = QuestPOIAssociationMarkData[questSandBoxId]

		if questPOIAssociationMarkConfig and questPOIAssociationMarkConfig.RelateSandbox then
			local relateId = tonumber(questPOIAssociationMarkConfig.RelateSandbox)

			if relateId and relateId > 0 and relateId ~= questSandBoxId then
				result[#result + 1] = relateId
			end
		end
	end

	local entityId = targetPositionConfig and tonumber(targetPositionConfig.entity)

	if entityId and entityId > 0 and entityId ~= result[1] and entityId ~= result[2] then
		result[#result + 1] = entityId
	end

	return result
end

function QuestUtils.getClueQuestTitle(clueId)
	return QuestUtils.getQuestLocalizedTextField(clueId, "name")
end

function QuestUtils.isClueReveal(clueId)
	if not pg.me then
		return false
	end

	return Bitset.getBit(pg.me.clueQuestRevealFlags, clueId)
end

function QuestUtils.isArkScene()
	local space = pg.me and pg.me.space

	if space and pg.game.map and pg.game.map:convertSceneId(space.sceneId) == Const.SCENE_ID.ARK then
		return true
	end

	return false
end

function QuestUtils.clueQuestTrace(questId, isTrace)
	if not pg.me then
		return false
	end

	local sceneId, _, _, leafQuestId = QuestUtils.getReceivedQuestObjcvPosition(questId, true)
	local markQuestId = leafQuestId or questId

	if isTrace then
		if sceneId then
			pg.game.map:openMapAndLocateMark(sceneId, Const.MAP_MARK_CLUE, markQuestId, true, nil, nil, true)
		end
	else
		pg.game.map:manualUnTraceQuestMark(markQuestId)
	end

	facade:SendMessageCommand(MessageName.QUEST_ON_CLUE_STATE_CHANGE, {
		questId = questId
	})
end

function QuestUtils.getClueMarkStatus(questId)
	if not questId or questId == 0 then
		return Const.MAP_MARK_STATUS_HIDE
	end

	local showMark
	local state = QuestUtils.getQuestState(questId)

	if state and state > QuestConst.QUEST_STATE.COMPLETED or not QuestUtils.isClueReveal(questId) then
		-- block empty
	elseif QuestUtils.isClueReveal(questId) then
		local config = QuestUtils.getQuestConfig(questId)

		showMark = config and config.isMapShow and true or pg.game.map:checkTrackMarkExists(questId)
	end

	return showMark and Const.MAP_MARK_STATUS_UNLOCKED or Const.MAP_MARK_STATUS_HIDE
end

function QuestUtils.getIconByNumber(number, color)
	if color == QuestConst.NUMBER_COLOR.BLUE then
		if number == "Dot" then
			return "<sprite name=UI_CharB_Dot>"
		end

		return string.format("<sprite name=UI_CharB_%d>", number)
	elseif color == QuestConst.NUMBER_COLOR.YELLOW then
		if number == "Dot" then
			return "<sprite name=UI_CharY_Dot>"
		end

		return string.format("<sprite name=UI_CharY_%d>", number)
	elseif color == QuestConst.NUMBER_COLOR.GREEN then
		if number == "Dot" then
			return "<sprite name=UI_CharG_Dot>"
		end

		return string.format("<sprite name=UI_CharG_%d>", number)
	end
end

function QuestUtils.getTimeIcon(color)
	local timestamp = Time.getSecond()
	local dateTable = os.date("*t", timestamp)
	local year, month, day = "", "", ""
	local dot = QuestUtils.getIconByNumber("Dot", color)
	local yearStr = tostring(dateTable.year)

	for i = 1, #yearStr do
		local digit = tonumber(yearStr:sub(i, i))

		year = year .. QuestUtils.getIconByNumber(digit, color)
	end

	local monthStr = string.format("%02d", dateTable.month)

	for i = 1, #monthStr do
		local digit = tonumber(monthStr:sub(i, i))

		month = month .. QuestUtils.getIconByNumber(digit, color)
	end

	local dayStr = string.format("%02d", dateTable.day)

	for i = 1, #dayStr do
		local digit = tonumber(dayStr:sub(i, i))

		day = day .. QuestUtils.getIconByNumber(digit, color)
	end

	return string.format("%s%s%s%s%s", year, dot, month, dot, day)
end

function QuestUtils.getSortIndex(parentQuestId)
	local chapterId, sectionId = QuestUtils.getQuestGroupChapterInfo(parentQuestId)

	if chapterId == 0 or sectionId == 0 then
		return -1
	end

	local sectionInfo = QuestMain[chapterId][sectionId]

	return sectionInfo ~= nil and sectionInfo.sort or -1
end

function QuestUtils.mapTraceQuest(curQuestId, isTrace)
	local questId = QuestUtils.getRootQuestId(curQuestId)

	if questId and questId > 0 then
		pg.me:traceQuest(questId, isTrace)

		if isTrace then
			local pageType = QuestUtils.getPageType(questId)

			QuestUtils.switchHudPageType(pageType)
			QuestUtils.addQuestPathingNavEffect(curQuestId)
		end
	end
end

function QuestUtils.switchHudPageType(pageType, noPlayVX)
	if pg.game and pg.game.quest and pageType and pageType > 0 then
		pg.game.quest:setCurTab(pageType, noPlayVX)
	end
end

local QUEST_HUD_LAST_TAB_KEY = "QUEST_HUD_LAST_TAB"

function QuestUtils.getLastHudPageType()
	if not pg.global or not pg.global.prefsCacheUtils then
		return QuestConst.QUEST_HUD_PAGE_TYPE.STORY
	end

	return pg.global.prefsCacheUtils:getInt(QUEST_HUD_LAST_TAB_KEY, QuestConst.QUEST_HUD_PAGE_TYPE.STORY, ClientConst.CACHE_TYPE_FLAG.USER)
end

function QuestUtils.saveLastHudPageType(pageType)
	if not pg.global or not pg.global.prefsCacheUtils then
		return
	end

	if pageType == nil or pageType <= QuestConst.QUEST_HUD_PAGE_TYPE.EMPTY or pageType > QuestConst.QUEST_HUD_PAGE_TYPE.QUEST then
		return
	end

	pg.global.prefsCacheUtils:setInt(QUEST_HUD_LAST_TAB_KEY, pageType, ClientConst.CACHE_TYPE_FLAG.USER)
end

function QuestUtils.getObjectRecommendLevelStyle(recommendLevel)
	local playerLevel = pg.me.level
	local isShowInHud = false
	local showStyle = 0
	local lvDifference = recommendLevel - playerLevel
	local minRecommendLvConfig = QuestRecommendLvStyle[1]

	if minRecommendLvConfig and lvDifference <= tonumber(minRecommendLvConfig.lvDifference) then
		showStyle = minRecommendLvConfig.showType
		isShowInHud = minRecommendLvConfig.isShowInHud and minRecommendLvConfig.isShowInHud == 1
	else
		for i, v in ipairs(QuestRecommendLvStyle) do
			if lvDifference <= tonumber(v.lvDifference) then
				showStyle = v.showType
				isShowInHud = v.isShowInHud and v.isShowInHud == 1

				break
			end
		end
	end

	return showStyle, isShowInHud
end

function QuestUtils.getSecondTracingQuestId()
	if pg.me == nil then
		return 0
	end

	return pg.me.curTraceSecondQuest
end

function QuestUtils.traceSecondTracingQuest(questId)
	local parentQuest = QuestUtils.getParentQuestId(questId)

	if parentQuest and parentQuest > 0 then
		pg.me:traceQuest(parentQuest, true)
	end

	local pageType = QuestUtils.getPageType(questId)

	if not pageType or pageType == QuestConst.QUEST_HUD_PAGE_TYPE.EMPTY then
		pageType = QuestConst.QUEST_HUD_PAGE_TYPE.STORY
	end

	QuestUtils.switchHudPageType(pageType)
end

function QuestUtils.cleanupSpecialTrainSourceMark(questId)
	if not questId or questId == 0 then
		return
	end

	local specialCfg = QuestUtils.getSpecialTrainConfig(questId)

	if not specialCfg then
		return
	end

	QuestUtils.clearItemSourceTraceMark(specialCfg.goTo)
	QuestUtils.clearItemSourceTraceMark(specialCfg.preGoTo)
end

function QuestUtils.clearItemSourceTraceMark(goTo)
	if not goTo or goTo[1] ~= 1 then
		return
	end

	local sourceData = ItemSourceData[goTo[2]]

	if not sourceData then
		return
	end

	local spawnerId

	if sourceData.type == LuaUIUtils.ITEM_SOURCE_TYPE_MAP_POS then
		spawnerId = sourceData.buttonTxt and math.abs(sourceData.buttonTxt) or nil
	elseif sourceData.type == LuaUIUtils.ITEM_SOURCE_TYPE_MAP_MARK then
		spawnerId = sourceData.sourceMarkPoint and sourceData.sourceMarkPoint[1] or nil
	end

	if not spawnerId or not pg.game.map then
		return
	end

	pg.game.map:removeTempMark(nil, spawnerId)
	pg.game.map:manualUnTraceQuestMark(spawnerId)
end

function QuestUtils.openSpecialTrainAndTraceType(trainType)
	local open1 = pg.global.ui:checkUIOpen(UIConst.UI_ID_PET_FERTILITY)
	local open2 = pg.global.ui:checkUIOpen(UIConst.UI_ID_PET_FERTILITY_CHOOSE_BALL)
	local checkRet = not open1 and not open2

	if not checkRet and LoggerManager.checkLogger(LoggerConst.WARN) then
		logger:warn("QuestUtils.openSpecialTrainAndTraceType wrong while hatchUI state - [UI_162=%s]; [UI_177=%s]", open1, open2)
	end

	if (trainType < QuestConst.QUEST_TRAIN_SUB_TYPE.COMPULSORY or trainType > QuestConst.QUEST_TRAIN_SUB_TYPE.FIGHT) and LoggerManager.checkLogger(LoggerConst.WARN) then
		logger:warn("QuestUtils.openSpecialTrainAndTraceType invalid trainType=%s, not in special_train_type_data.lua", trainType)
	end

	trainType = trainType or QuestConst.QUEST_TRAIN_SUB_TYPE.COMPULSORY

	if checkRet then
		if pg.global.ui:checkUIOpen(UIConst.UI_ID_OPEN_SPECIAL_TRAIN_PANEL) then
			pg.global.ui.SpecialTrainNew:jumpToTrainTypeAndTrace(trainType)
		else
			pg.global.ui:open(UIConst.UI_ID_OPEN_SPECIAL_TRAIN_PANEL, {
				autoTrace = true,
				trainType = trainType
			}, nil, nil, {
				textureHeight = 1400,
				textureWidth = 1400
			})
		end
	end

	QuestUtils.switchHudPageType(QuestConst.QUEST_HUD_PAGE_TYPE.GROW)
end

function QuestUtils.getCurChapterId()
	return pg.me and pg.me.specialTrainMapMap and pg.me.specialTrainMapMap:getCurChapterId()
end

function QuestUtils.curSpecialNeedInterruptQuest()
	local specialQuestConfig = {}
	local maxSortValue = 0
	local needInterruptQuestId = 0
	local specialTrainMap = pg.me and pg.me.specialTrainMapMap and pg.me.specialTrainMapMap[QuestUtils.getCurChapterId()] or {}
	local mainTaskIds = SpecialTrainChapterData[QuestUtils.getCurChapterId()].mainTaskId

	for j, taskId in ipairs(mainTaskIds) do
		local curQuestId = specialTrainMap[taskId] and specialTrainMap[taskId].curQuestId

		if curQuestId and curQuestId > 0 then
			specialQuestConfig = QuestUtils.getSpecialTrainConfig(curQuestId)

			if specialQuestConfig and specialQuestConfig.sort and maxSortValue < specialQuestConfig.sort then
				maxSortValue = specialQuestConfig.sort
				needInterruptQuestId = curQuestId

				break
			end
		end
	end

	return needInterruptQuestId
end

function QuestUtils.manualTrackSecondTracingQuest()
	local showDoublePage = QuestUtils.isShowDoublePage()

	if showDoublePage then
		local isAllSpecialTrainFinish, questId = QuestUtils.isHaveSpecialTrainNoFinish()
		local parentQuest = QuestUtils.getRootQuestId(questId)

		if parentQuest > 0 then
			pg.me:traceQuest(parentQuest, true)

			return parentQuest
		end
	end

	return 0
end

function QuestUtils.getMaxChapterId()
	local maxChapterId = 0

	for i, v in pairs(SpecialTrainChapterRevertData) do
		local chapterStateInfo = QuestUtils.getChapterState(i)

		if chapterStateInfo and chapterStateInfo.isInStarTitleQuest or chapterStateInfo.isChapterRewarded then
			maxChapterId = i

			return maxChapterId
		end

		maxChapterId = maxChapterId < i and i or maxChapterId
	end

	return maxChapterId
end

function QuestUtils.isFinishAllSpecialTrain()
	local flag = true
	local compulsoryQuestList = SpecialTrainChapterRevertData[QuestUtils.getMaxChapterId()][QuestConst.TRAIN_CHAPTER_COURSE_TYPE.COMPULSORY]

	for i, questId in pairs(compulsoryQuestList) do
		local questData = QuestUtils.getQuestData(questId)

		if not questData or QuestUtils.getQuestState(questId) and QuestUtils.getQuestState(questId) < QuestConst.QUEST_STATE.SUBMITED then
			flag = false

			return flag
		end
	end

	local electiveQuestList = SpecialTrainChapterRevertData[QuestUtils.getMaxChapterId()][QuestConst.TRAIN_CHAPTER_COURSE_TYPE.ELECTIVE]

	for i, questId in pairs(electiveQuestList) do
		local questData = QuestUtils.getQuestData(questId)

		if not questData or QuestUtils.getQuestState(questId) and QuestUtils.getQuestState(questId) < QuestConst.QUEST_STATE.SUBMITED then
			flag = false

			return flag
		end
	end

	return flag
end

function QuestUtils.isHaveSpecialTrainNoFinish()
	local flag = false
	local specialTrainMap = {}
	local questId = 0

	for i = QuestUtils.getCurChapterId(), 0, -1 do
		specialTrainMap = pg.me and pg.me.specialTrainMapMap and pg.me.specialTrainMapMap[i] or {}

		local mainTaskIds = SpecialTrainChapterData[i].mainTaskId
		local challengeMainTaskIds = SpecialTrainChapterData[i].challengeMainTaskId
		local totalIds = {}

		if mainTaskIds then
			table.mergeList(totalIds, mainTaskIds)
		end

		if challengeMainTaskIds then
			table.mergeList(totalIds, challengeMainTaskIds)
		end

		for j, taskId in ipairs(totalIds) do
			questId = specialTrainMap[taskId] and specialTrainMap[taskId].curQuestId

			if questId and questId > 0 then
				flag = not QuestUtils.isQuestSubmittedOrFinished(questId)

				if flag then
					return flag, questId
				end
			end
		end

		if not flag then
			local sideTaskIds = SpecialTrainChapterData[i].sideTaskId

			if sideTaskIds then
				for j, taskId in ipairs(sideTaskIds) do
					questId = specialTrainMap[taskId] and specialTrainMap[taskId].curQuestId

					if questId and questId > 0 then
						flag = not QuestUtils.isQuestSubmittedOrFinished(questId)

						if flag then
							return flag, questId
						end
					end
				end
			end
		end
	end

	return flag, questId
end

function QuestUtils.getSpecialTrainNoRewardQuestId(canTraceFunc)
	for i = QuestUtils.getCurChapterId(), 0, -1 do
		local chapterConfig = SpecialTrainChapterData[i]

		if chapterConfig then
			local specialTrainMap = pg.me and pg.me.specialTrainMapMap and pg.me.specialTrainMapMap[i] or {}
			local mainTaskIds = {}

			if chapterConfig.mainTaskId then
				table.mergeList(mainTaskIds, chapterConfig.mainTaskId)
			end

			if chapterConfig.challengeMainTaskId then
				table.mergeList(mainTaskIds, chapterConfig.challengeMainTaskId)
			end

			local questId = QuestUtils.findSpecialTrainNoRewardQuestId(specialTrainMap, mainTaskIds, canTraceFunc)

			if questId > 0 then
				return questId
			end

			questId = QuestUtils.findSpecialTrainNoRewardQuestId(specialTrainMap, chapterConfig.sideTaskId, canTraceFunc)

			if questId > 0 then
				return questId
			end
		end
	end

	return 0
end

function QuestUtils.findSpecialTrainNoRewardQuestId(specialTrainMap, taskIds, canTraceFunc)
	if type(taskIds) ~= "table" then
		return 0
	end

	for _, taskId in ipairs(taskIds) do
		local questId = specialTrainMap[taskId] and specialTrainMap[taskId].curQuestId

		if questId and questId > 0 and (not QuestUtils.isQuestSubmittedOrFinished(questId) or not QuestUtils.getSpecialTrainQuestRewardFlags(questId)) and (canTraceFunc == nil or canTraceFunc(questId)) then
			return questId
		end
	end

	return 0
end

function QuestUtils.getChapterConfig(chapterId)
	if SpecialTrainChapterData[chapterId] == nil then
		return
	end

	return SpecialTrainChapterData[chapterId]
end

function QuestUtils.isVersionCapChapter(chapterId)
	if chapterId == nil or chapterId <= 1 then
		return false
	end

	local chapterConfig = QuestUtils.getChapterConfig(chapterId - 1)

	if not chapterConfig or not chapterConfig.requiredTitleId then
		return false
	end

	local titleConfig = PlayerTitleData[chapterConfig.requiredTitleId]

	return titleConfig ~= nil and titleConfig.quest == nil
end

function QuestUtils.isVersionCapChapterFinished(chapterId)
	local isVersionCapChapter = QuestUtils.isVersionCapChapter(chapterId)

	return isVersionCapChapter and QuestUtils.isQuestFinished(SysConfigData.SPECIALTRAIN_GRASS_ENDING_QUEST_JUMP)
end

function QuestUtils.isVersionCapChapterCanUpTitle(chapterId)
	local questId = QuestUtils.getChapterCourseQuestId(chapterId)

	return QuestUtils.isVersionCapChapter(chapterId) and questId ~= nil and questId > 0 and not QuestUtils.isQuestSubmittedOrFinished(questId)
end

function QuestUtils.getSpecialTrainQuestTitleName(questId)
	if questId == nil or questId == 0 then
		return ""
	end

	local subQuestId = questId
	local isParentQuest = QuestUtils.isParentQuest(questId)

	if isParentQuest then
		local subQuestIds = QuestUtils.getChildQuests(questId)

		if subQuestIds and subQuestIds[1] then
			subQuestId = subQuestIds[1]
		end
	end

	local data = SpecialTrainRevertData[subQuestId]

	return data and pg.getLocalizationText(data.taskName)
end

function QuestUtils.getTabPageList()
	local tabPageList = {
		{
			pageType = QuestConst.QUEST_HUD_PAGE_TYPE.STORY
		}
	}
	local isShowQuestGrowPage = QuestUtils.isShowDoublePage()

	if isShowQuestGrowPage then
		tabPageList[#tabPageList + 1] = {
			pageType = QuestConst.QUEST_HUD_PAGE_TYPE.GROW
		}
	end

	if pg.me and pg.me.hadAcceptedTraceQuest then
		tabPageList[#tabPageList + 1] = {
			pageType = QuestConst.QUEST_HUD_PAGE_TYPE.QUEST
		}
	end

	return tabPageList
end

function QuestUtils.getTabPageMaxIndex()
	return #QuestUtils.getTabPageList()
end

function QuestUtils.getTabPageListInterrupt(questId)
	return {
		{
			pageType = QuestUtils.getPageType(questId),
			questId = questId
		}
	}
end

function QuestUtils.getPageByIndex(index)
	local tabPageList = QuestUtils.getTabPageList()

	return tabPageList[index].pageType or QuestConst.QUEST_HUD_PAGE_TYPE.STORY
end

function QuestUtils.getIndexByPage(pageType)
	local index = 1
	local tabPageList = QuestUtils.getTabPageList()

	for i, v in pairs(tabPageList) do
		if v.pageType == pageType then
			index = i

			return index
		end
	end

	return index
end

function QuestUtils.getPageTraceQuestId(pageType)
	local pageQuestId = 0
	local curPageType = pageType or QuestUtils.getCurSelPage()

	if curPageType == QuestConst.QUEST_HUD_PAGE_TYPE.STORY then
		pageQuestId = QuestUtils.getTracingStoryQuestId()
	elseif curPageType == QuestConst.QUEST_HUD_PAGE_TYPE.GROW then
		pageQuestId = QuestUtils.getSecondTracingQuestId()
	elseif curPageType == QuestConst.QUEST_HUD_PAGE_TYPE.QUEST then
		pageQuestId = QuestUtils.getTracingQuestId()
	end

	return pageQuestId
end

function QuestUtils.getStoryQuestGroupIdList()
	return StoryPageQuestGroupData[1] or {}
end

function QuestUtils.hasTraceableStoryQuest()
	if pg.me == nil then
		return false
	end

	local groupIds = QuestUtils.getStoryQuestGroupIdList()
	local unFinishedGroupIds = {}

	for i = 1, #groupIds do
		local groupId = groupIds[i]

		if not QuestUtils.isQuestSubmittedOrFinished(groupId) then
			unFinishedGroupIds[groupId] = true
		end
	end

	if next(unFinishedGroupIds) == nil then
		return false
	end

	local questMaps = {
		pg.me.acceptedQuestMap,
		pg.me.pendingQuestMap
	}

	for i = 1, #questMaps do
		local questMap = questMaps[i]

		if questMap ~= nil then
			for questId, questData in pairs(questMap) do
				local state = questData and questData.state

				if state ~= nil and state >= QuestConst.QUEST_STATE.INIT and state < QuestConst.QUEST_STATE.SUBMITED then
					local rootQuestId = QuestUtils.getRootQuestId(questId) or questId

					if unFinishedGroupIds[rootQuestId] then
						return true
					end
				end
			end
		end
	end

	return false
end

function QuestUtils.isStoryTracingAllFinished()
	if pg.me == nil then
		return false
	end

	if QuestUtils.getTracingStoryQuestId() ~= 0 then
		return false
	end

	return not QuestUtils.hasTraceableStoryQuest()
end

function QuestUtils.isShowDoublePage()
	local isShowQuestGrowPage = QuestUtils.isShowQuestGrowPage()

	return isShowQuestGrowPage and not QuestUtils.isInCourseScene()
end

function QuestUtils.isShowQuestGrowPage()
	local isSpecialTrainOpen = pg.me and pg.me.isSpecialTrainOpen and LuaUIUtils.checkFuncCanOpen(Const.FUNCTION_IDS.SPECIAL_TRAIN)

	return isSpecialTrainOpen
end

function QuestUtils.getQuestRevertConfig(questId)
	return SpecialTrainRevertData[questId]
end

function QuestUtils.getSpecialTrainConfig(questId)
	local specialRevertConf = QuestUtils.getQuestRevertConfig(questId)

	if specialRevertConf then
		local taskType, taskId, stageId = specialRevertConf.taskType, specialRevertConf.taskId, specialRevertConf.stageId
		local taskConf = SpecialTrainEntryData[taskId]

		return taskConf and taskConf[stageId]
	end
end

function QuestUtils.getCurShowQuest(chapterId, taskId)
	if not chapterId or not taskId or taskId == 0 then
		return 0
	end

	local specialTrainTypeMap = pg.me.specialTrainMapMap[chapterId] or {}
	local specialTrainEntryData = QuestUtils.isHaveNumKey(specialTrainTypeMap) and specialTrainTypeMap[taskId] or {}

	return specialTrainEntryData.curQuestId or 0
end

function QuestUtils.isHaveNumKey(specialTrainTypeMap)
	local flag = false

	for k, v in pairs(specialTrainTypeMap) do
		if type(k) == "number" then
			flag = true

			return flag
		end
	end

	return false
end

function QuestUtils.getChapterMainTaskList(chapterId)
	local chapterMainList = {}

	if not chapterId then
		return chapterMainList
	end

	local chapterConfig = SpecialTrainChapterData[chapterId]

	if not chapterConfig then
		return chapterMainList
	end

	local curQuestId = 0
	local totalIds = {}
	local mainTaskIds = chapterConfig.mainTaskId
	local challengeMainTaskIds = chapterConfig.challengeMainTaskId

	if mainTaskIds then
		table.mergeList(totalIds, mainTaskIds)
	end

	if challengeMainTaskIds then
		table.mergeList(totalIds, challengeMainTaskIds)
	end

	for i = 1, #totalIds do
		curQuestId = QuestUtils.getCurShowQuest(chapterId, totalIds[i])

		local revertConfig = QuestUtils.getQuestRevertConfig(curQuestId)

		if revertConfig and curQuestId > 0 then
			table.insert(chapterMainList, {
				sortIndex = 1,
				isMain = true,
				chapterId = chapterId,
				pageType = revertConfig.taskType,
				taskId = totalIds[i],
				questId = curQuestId
			})
		end
	end

	return chapterMainList
end

function QuestUtils.getChapterSideTaskList(chapterId)
	local chapterSideList = {}

	if not chapterId then
		return chapterSideList
	end

	local curQuestId = 0
	local chapterConfig = SpecialTrainChapterData[chapterId]

	if not chapterConfig then
		return chapterSideList
	end

	local sideTaskId = chapterConfig.sideTaskId

	if not sideTaskId then
		return chapterSideList
	end

	for i = 1, #sideTaskId do
		curQuestId = QuestUtils.getCurShowQuest(chapterId, sideTaskId[i])

		local revertConfig = QuestUtils.getQuestRevertConfig(curQuestId)

		if revertConfig and curQuestId > 0 then
			table.insert(chapterSideList, {
				sortIndex = 4,
				chapterId = chapterId,
				pageType = revertConfig.taskType,
				taskId = sideTaskId[i],
				questId = curQuestId
			})
		end
	end

	return chapterSideList
end

function QuestUtils.openTraceSecondQuestFunc(questId)
	local questConfig = QuestUtils.getSpecialTrainConfig(questId)

	if not questConfig.goTo or not questConfig.goTo[1] then
		return
	end

	if questConfig.goToCondition and questConfig.goToCondition[1] and not ClientUtils.checkCondition(questConfig.goToCondition[1]) then
		local node = pg.getLocalizationText(CustomTriggerData[questConfig.goToCondition[1]].note)

		pg.global.ui.tips:showTextTip(node)

		return
	end

	local guideId = questConfig.guideId
	local goTo = questConfig.goTo

	if questConfig.preGuideId ~= nil and not GuideUtils.isGuidePlayed(questConfig.preGuideId) then
		guideId = questConfig.preGuideId
		goTo = questConfig.preGoTo or questConfig.goTo
	end

	if goTo == nil then
		return
	end

	LuaUIUtils.goToFromEvent({
		type = goTo[1],
		id = goTo[2],
		guideId = guideId
	})
end

function QuestUtils.isChapterLockState(chapterId)
	return chapterId > QuestUtils.getCurChapterId()
end

function QuestUtils.getChapterNumber(chapterType)
	local chapterName = SpecialTrainChapterData[chapterType].chapterName

	return pg.getLocalizationText(chapterName)
end

function QuestUtils.getChapterTotalNum()
	local totalNum = 0

	for i, v in pairs(SpecialTrainChapterData) do
		if i > 0 then
			totalNum = totalNum + 1
		end
	end

	return totalNum
end

function QuestUtils.getSelectChapterIndex()
	local index = 0
	local totalNum = QuestUtils.getChapterTotalNum()

	for i = 1, totalNum do
		local chapterId = QuestUtils.getChapterIdByIndex(i)

		if chapterId <= QuestUtils.getCurChapterId() then
			index = i
		end
	end

	return index
end

function QuestUtils.getChapterMaxIndex()
	local index = QuestUtils.getSelectChapterIndex()
	local chapterId = QuestUtils.getChapterIdByIndex(index)
	local chapterStateInfo = QuestUtils.getChapterState(chapterId)
	local totalNum = QuestUtils.getChapterTotalNum()

	for i = 1, totalNum do
		if chapterStateInfo and chapterStateInfo.isChapterRewarded and chapterStateInfo.isInStarTitleQuest and index <= i then
			index = i

			break
		end
	end

	return index
end

function QuestUtils.getChapterCourseQuestList(chapterId, CourseType)
	return SpecialTrainChapterRevertData[chapterId][CourseType]
end

function QuestUtils.isCompulsoryFinish(chapterId)
	local flag = true

	for i, v in pairs(QuestUtils.getChapterCourseQuestList(chapterId, QuestConst.TRAIN_CHAPTER_COURSE_TYPE.COMPULSORY)) do
		if not QuestUtils.isQuestSubmittedOrFinished(v) then
			flag = false

			break
		end
	end

	return flag
end

function QuestUtils.getChapterState(chapterId)
	local chapterStateInfo = {
		isInStarTitleQuest = false,
		isStarTitleQuestViewed = false,
		canGetChapterReward = false,
		isChapterViewed = false,
		isChapterRewarded = false
	}

	if pg.me and pg.me.specialTrainMapMap then
		local chapterList = pg.me.specialTrainMapMap[chapterId]

		if chapterList then
			if chapterId == 0 then
				chapterStateInfo.isChapterRewarded = QuestUtils.isCompulsoryFinish(QuestConst.TRAIN_PHASE.NEWBIE)
				chapterStateInfo.isInStarTitleQuest = type(chapterList.isInStarTitleQuest) == "boolean" and chapterList.isInStarTitleQuest or false
			else
				chapterStateInfo.isChapterViewed = type(chapterList.isChapterViewed) == "boolean" and chapterList.isChapterViewed or false
				chapterStateInfo.isChapterRewarded = type(chapterList.isChapterRewarded) == "boolean" and chapterList.isChapterRewarded or false
				chapterStateInfo.isInStarTitleQuest = type(chapterList.isInStarTitleQuest) == "boolean" and chapterList.isInStarTitleQuest or false
				chapterStateInfo.canGetChapterReward = type(chapterList.canGetChapterReward) == "boolean" and chapterList.canGetChapterReward or false
				chapterStateInfo.isStarTitleQuestViewed = type(chapterList.isStarTitleQuestViewed) == "boolean" and chapterList.isStarTitleQuestViewed or false
			end
		end
	end

	return chapterStateInfo
end

function QuestUtils.getChapterCourseQuestId(chapterId)
	local questId = 0
	local chapterConfig = QuestUtils.getChapterConfig(chapterId)

	if chapterConfig and chapterConfig.requestTaskId then
		questId = QuestUtils.getParentQuestId(chapterConfig.requestTaskId)
	end

	return questId
end

function QuestUtils.getChapterIdByIndex(index)
	local chapterId = QuestConst.TRAIN_PHASE.CHAPTER

	for i, v in pairs(SpecialTrainChapterData) do
		if i == index then
			chapterId = i

			break
		end
	end

	return chapterId
end

function QuestUtils.getChapterStar(chapterId)
	local star = 0
	local chapterConfig = QuestUtils.getChapterConfig(chapterId)

	if chapterConfig and chapterConfig.requiredTitleId then
		star = chapterConfig.requiredTitleId
	end

	return star
end

function QuestUtils.getCurChapterStarTitleName()
	return LuaUIUtils.getStarTitleName(QuestUtils.getChapterStar(QuestUtils.getCurChapterId()), true)
end

function QuestUtils.getCurChapterPromoteHudTitle()
	return string.format(pg.getGameString("SPECIAL_TRAIN_PROMOTE_HUD_TITLE"), QuestUtils.getCurChapterStarTitleName())
end

function QuestUtils.isCanUpgradeStar(chapterId)
	local questId = QuestUtils.getChapterCourseQuestId(chapterId)

	if questId and questId > 0 then
		local isFinishCond = QuestUtils.isQuestSubmittedOrFinished(questId)
		local isUpTitleFinishCond = LuaUIUtils.getPlayerStar() >= QuestUtils.getChapterStar(chapterId)

		return isFinishCond and not isUpTitleFinishCond
	end
end

function QuestUtils.isOnlyCanUpgradeStar(chapterId)
	local questId = QuestUtils.getChapterCourseQuestId(chapterId)

	if questId and questId > 0 then
		local isFinishCond = QuestUtils.isQuestSubmittedOrFinished(questId)
		local isUpTitleFinishCond = LuaUIUtils.getPlayerStar() >= QuestUtils.getChapterStar(chapterId)

		return isFinishCond and not isUpTitleFinishCond
	end
end

function QuestUtils.getAssessmentIdByUpgrade(questId)
	local isParentQuest = QuestUtils.isParentQuest(questId)
	local questGroupId = isParentQuest and questId or QuestUtils.getRootQuestId(questId)
	local assessmentQuestId = 0

	for i = 0, #PlayerTitleData do
		local v = PlayerTitleData[i]

		if v.specialTrain == questGroupId then
			assessmentQuestId = v.quest

			break
		end
	end

	return assessmentQuestId
end

function QuestUtils.getAssessmentStar(questId)
	local assessStar = 0

	if not questId or questId == 0 then
		return assessStar
	end

	local isParentQuest = QuestUtils.isParentQuest(questId)
	local questGroupId = isParentQuest and questId or QuestUtils.getRootQuestId(questId)

	for i = 0, #PlayerTitleData do
		local v = PlayerTitleData[i]

		if v.quest == questGroupId then
			assessStar = i

			break
		end
	end

	return assessStar
end

function QuestUtils.getChapterLeveCond(chapterId)
	local tips, name, icon, level

	if SpecialTrainChapterData[chapterId] == nil then
		return
	end

	local taskConditions = SpecialTrainChapterData[chapterId].taskConditions

	for i, v in pairs(taskConditions) do
		if not ClientUtils.checkCondition(v) then
			local customTriggerConfig = CustomTriggerData[v]

			if customTriggerConfig then
				tips = pg.getLocalizationText(customTriggerConfig.note)

				for index, conditionData in ipairs(customTriggerConfig.condition) do
					local triggerType = TriggerUtils.getTriggerType(conditionData)

					if triggerType == TriggerConst.TRIGGER_TARGET_PLAYER_LEVEL then
						level = conditionData[TriggerConst.CUSTOM_TRIGGER_NUM_POS]
					elseif triggerType == TriggerConst.TRIGGER_TARGET_PLAYER_TITLE then
						local starTitle = conditionData[TriggerConst.CUSTOM_TRIGGER_NUM_POS]

						name = LuaUIUtils.getStarTitleName(starTitle, true)
						icon = LuaUIUtils.getStarIcon(starTitle)
					end
				end
			end
		end
	end

	return tips, name, icon, level
end

function QuestUtils.getSpecialTrainHudInfo(hudType, questId)
	local title, content, hint

	if QuestConst.SPECIAL_QUEST_HUD_STATE.CHAPTER_REWARD == hudType then
		if QuestUtils.getChapterMaxIndex() > 0 then
			local chapterNumber = QuestUtils.getChapterNumber(QuestUtils.getChapterMaxIndex())

			title = string.format(pg.getGameString("SPECIAL_TRAIN_HUD_TEXT1"), chapterNumber)
			content = pg.getGameString("SPECIAL_TRAIN_HUD_TEXT2")
			hint = pg.getGameString("SPECIAL_TRAIN_HUD_TEXT3")
		end
	elseif QuestConst.SPECIAL_QUEST_HUD_STATE.CHAPTER_INTERRUPT == hudType then
		title = QuestUtils.getSpecialTrainQuestTitleName(questId)
		content = QuestUtils.getSpecialTrainQuestTitleName(questId)
		hint = pg.getGameString("SPECIAL_TRAIN_HUD_TEXT3")
	elseif QuestConst.SPECIAL_QUEST_HUD_STATE.CHAPTER_LOCKED == hudType then
		if QuestUtils.getChapterMaxIndex() > 0 then
			local chapterNumber = QuestUtils.getChapterNumber(QuestUtils.getChapterMaxIndex())
			local tips, name, icon, level = QuestUtils.getChapterLeveCond(QuestUtils.getChapterMaxIndex())

			title = string.format(pg.getGameString("SPECIAL_TRAIN_HUD_TEXT5"), chapterNumber)
			content = tips
			hint = pg.getGameString("SPECIAL_TRAIN_HUD_TEXT6")
		end
	elseif QuestConst.SPECIAL_QUEST_HUD_STATE.ALL_FINISH == hudType then
		title = pg.getGameString("SPECIAL_TRAIN_HUD_TEXT7")
		content = pg.getGameString("SPECIAL_TRAIN_HUD_TEXT8")
	elseif QuestConst.SPECIAL_QUEST_HUD_STATE.QUEST_TRACE == hudType then
		local secondQuestData, questConfig = pg.global.ui.SpecialTrainNew:isCanShowTraceSecondQuestFunc(questId)

		if secondQuestData.isCanGetReward == nil then
			-- block empty
		end

		local canGet = secondQuestData.isCanGetReward

		if secondQuestData.rewardFlags == nil then
			-- block empty
		end

		local hasGet = secondQuestData.rewardFlags

		hint = pg.getLocalizationText(questConfig.goToTxt)

		if canGet and not hasGet then
			hint = pg.getGameString("QUEST_TRACK_GET_REWARD")
		end

		title = QuestUtils.getSpecialTrainQuestTitleName(questId)
		content = QuestUtils.getSpecialTrainQuestTitleName(questId)
		hint = pg.getGameString("SPECIAL_TRAIN_HUD_TEXT6")
	elseif QuestConst.SPECIAL_QUEST_HUD_STATE.CHAPTER_ADVANCE == hudType then
		title = QuestUtils.getCurChapterPromoteHudTitle()
		hint = pg.getGameString("SPECIAL_TRAIN_PROMOTE_LOCKED_GOPOS")
	elseif QuestConst.SPECIAL_QUEST_HUD_STATE.CHAPTER_WAIT == hudType then
		title = QuestUtils.getCurChapterPromoteHudTitle()
		content = pg.getGameString("SPECIAL_TRAIN_PROMOTE_WAIT_HUD")
		hint = pg.getGameString("SPECIAL_TRAIN_PROMOTE_WAIT_GOPOS")
	elseif QuestConst.SPECIAL_QUEST_HUD_STATE.CHAPTER_ASSESSMENT == hudType then
		local starTitleName = QuestUtils.getCurChapterStarTitleName()

		title = QuestUtils.getCurChapterPromoteHudTitle()
		content = string.format(pg.getGameString("SPECIAL_TRAIN_PROMOTE_UNLOCKED_HUD"), starTitleName)
		hint = pg.getGameString("SPECIAL_TRAIN_TITLE_UP_TEXT")
	elseif QuestConst.SPECIAL_QUEST_HUD_STATE.CHAPTER_MAIN_FINISH == hudType then
		title = pg.getGameString("SPECIAL_TRAIN_TITLE_UP_TEXT")
		content = pg.getGameString("SPECIAL_TRAIN_TITLE_UP_TEXT_DESC")
		hint = pg.getGameString("SPECIAL_TRAIN_PROMOTE_UNLOCKED_GOPOS")
	end

	return title, content, hint
end

function QuestUtils.isShowSpecialChapterItem(ignoreTracingQuest)
	local isFinishAllSpecialTrain = QuestUtils.isFinishAllSpecialTrain()
	local chapterId = QuestUtils.getCurChapterId()
	local chapterStateData = QuestUtils.getChapterState(chapterId)
	local isInStarTitleQuest = QuestUtils.isInStarTitleQuest()
	local flag = false

	if isFinishAllSpecialTrain or chapterStateData.canGetChapterReward or isInStarTitleQuest then
		local questId = QuestUtils.getSecondTracingQuestId()

		if not ignoreTracingQuest and questId > 0 and questId ~= QuestUtils.getInStarTitleQuestId() and QuestUtils.isQuestInState(questId, QuestConst.QUEST_STATE.RECEIVED) then
			return false
		end

		if isInStarTitleQuest and QuestUtils.isVersionCapChapter(chapterId) and not QuestUtils.isVersionCapChapterCanUpTitle(chapterId) then
			return false
		end

		flag = true
	end

	return flag
end

function QuestUtils.getSpecialChapterObjectives()
	local objectives = {}
	local objective = {}
	local chapterId = QuestUtils.getCurChapterId()
	local chapterStateData = QuestUtils.getChapterState(chapterId)

	if QuestUtils.isFinishAllSpecialTrain() then
		local title, content, hint = QuestUtils.getSpecialTrainHudInfo(QuestConst.SPECIAL_QUEST_HUD_STATE.ALL_FINISH)

		objective.chapterId = chapterId
		objective.content = content
		objective.hudType = QuestConst.SPECIAL_QUEST_HUD_STATE.ALL_FINISH
		objective.pageType = QuestConst.QUEST_HUD_PAGE_TYPE.GROW
		objective.hint = hint
		objective.title = title
	elseif chapterStateData.canGetChapterReward then
		local title, content, hint = QuestUtils.getSpecialTrainHudInfo(QuestConst.SPECIAL_QUEST_HUD_STATE.CHAPTER_REWARD)

		objective.chapterId = chapterId
		objective.content = content
		objective.hudType = QuestConst.SPECIAL_QUEST_HUD_STATE.CHAPTER_REWARD
		objective.pageType = QuestConst.QUEST_HUD_PAGE_TYPE.GROW
		objective.hint = hint
		objective.title = title
	elseif QuestUtils.isInStarTitleQuest() then
		if QuestUtils.isCanUpgradeStar(chapterId) then
			local title, content, hint = QuestUtils.getSpecialTrainHudInfo(QuestConst.SPECIAL_QUEST_HUD_STATE.CHAPTER_ASSESSMENT)

			objective.chapterId = chapterId
			objective.content = content
			objective.hudType = QuestConst.SPECIAL_QUEST_HUD_STATE.CHAPTER_ASSESSMENT
			objective.hint = hint
			objective.title = title
		elseif QuestUtils.isChapterAdvance() then
			local questId = QuestUtils.getChapterCourseQuestId(chapterId)

			if questId and questId > 0 then
				local title, content, hint = QuestUtils.getSpecialTrainHudInfo(QuestConst.SPECIAL_QUEST_HUD_STATE.CHAPTER_ADVANCE)
				local tempObjects = QuestUtils.getReceivedQuestObjectives(questId, true)

				for i = 1, #tempObjects do
					objective = {}
					objective = tempObjects[i]
					objective.chapterId = chapterId
					objective.hudType = QuestConst.SPECIAL_QUEST_HUD_STATE.CHAPTER_ADVANCE
					objective.title = title

					table.insert(objectives, objective)
				end
			end
		end
	end

	if not QuestUtils.isInStarTitleQuest() or not QuestUtils.isChapterAdvance() then
		table.insert(objectives, objective)
	end

	return objectives
end

local EMPTY_TRACING_TEXT_KEYS = {
	[QuestConst.QUEST_HUD_PAGE_TYPE.STORY] = {
		hint = "NOT_IN_TRACE_QUEST_V",
		content = "QUEST_TO_BE_CONTINUED_DESC",
		title = "QUEST_TO_BE_CONTINUED_TITLE"
	},
	[QuestConst.QUEST_HUD_PAGE_TYPE.GROW] = {
		hint = "QUEST_HUD_SPECIAL_TRACK_TEXT",
		content = "QUEST_HUD_SPECIAL_TRACK_TEXT",
		title = "NOT_IN_TRACE_QUEST_TITLE"
	},
	[QuestConst.QUEST_HUD_PAGE_TYPE.QUEST] = {
		hint = "NOT_IN_TRACE_QUEST_V",
		content = "NOT_IN_TRACE_QUEST_DESC",
		title = "NOT_IN_TRACE_QUEST_TITLE"
	}
}

local function getEmptyTracingTextKeys(pageType)
	return EMPTY_TRACING_TEXT_KEYS[pageType] or EMPTY_TRACING_TEXT_KEYS[QuestConst.QUEST_HUD_PAGE_TYPE.QUEST]
end

function QuestUtils.getEmptyTracingTitle(pageType)
	return pg.getGameString(getEmptyTracingTextKeys(pageType).title)
end

function QuestUtils.getEmptyTracingText(pageType)
	pageType = pageType or QuestConst.QUEST_HUD_PAGE_TYPE.QUEST

	local textKeys = getEmptyTracingTextKeys(pageType)
	local list = {}
	local objective = {}

	objective.content = pg.getGameString(textKeys.content)
	objective.hudType = pageType
	objective.hint = pg.getGameString(textKeys.hint)
	objective.title = pg.getGameString(textKeys.title)
	objective.pageType = pageType
	objective.isEmptyTracing = true

	table.insert(list, objective)

	return list
end

function QuestUtils.isChapterAdvance()
	local flag = false
	local chapterStateData = QuestUtils.getChapterStateData()

	if chapterStateData then
		local isSubmitted = QuestUtils.isQuestSubmittedOrFinished(chapterStateData.questId)

		if not isSubmitted then
			flag = true
		end
	end

	return flag
end

function QuestUtils.getChapterStateData()
	local chapterId = QuestUtils.getCurChapterId()
	local chapterStateInfo = QuestUtils.getChapterState(chapterId)

	if not chapterStateInfo or not chapterStateInfo.isInStarTitleQuest then
		return nil
	end

	local questId = QuestUtils.getChapterCourseQuestId(chapterId)

	if not questId or questId == 0 then
		return nil
	end

	local star = QuestUtils.getChapterStar(chapterId)

	if not star then
		return nil
	end

	return {
		questId = questId,
		star = star
	}
end

function QuestUtils.isInStarTitleQuest()
	local flag = false
	local chapterId = QuestUtils.getCurChapterId()
	local chapterStateInfo = QuestUtils.getChapterState(chapterId)

	if chapterStateInfo and chapterStateInfo.isInStarTitleQuest then
		flag = true
	end

	return flag
end

function QuestUtils.getInStarTitleQuestId()
	local advanceId = 0
	local chapterId = QuestUtils.getCurChapterId()

	if chapterId then
		advanceId = QuestUtils.getChapterCourseQuestId(chapterId)
	end

	return advanceId
end

function QuestUtils.isQuestSubmittedOrFinished(questId)
	return QuestUtils.isQuestInState(questId, QuestConst.QUEST_STATE.SUBMITED) or QuestUtils.isQuestSubmitted(questId)
end

function QuestUtils.isPromotionQuest(questId)
	local flag = false
	local parentQuestId = QuestUtils.getParentQuestId(questId)

	if QuestUtils.getInStarTitleQuestId() == parentQuestId then
		flag = true
	end

	return flag
end

function QuestUtils.checkCanUpGradeStarSpecialTrain(star, isIgnoreLevel)
	return Utils.getTitleAssessInfo(star, nil, nil, isIgnoreLevel)
end

function QuestUtils.getSpecialTrainQuestRewardFlags(questId)
	local revertConfig = QuestUtils.getQuestRevertConfig(questId)

	if revertConfig then
		local specialTrainTypeMap = pg.me.specialTrainMapMap[revertConfig.chapterId] or {}
		local specialTrainEntryData = QuestUtils.isHaveNumKey(specialTrainTypeMap) and specialTrainTypeMap[revertConfig.taskId] or {}

		if Bitset.getBit(specialTrainEntryData.rewardFlags, revertConfig.stageId) then
			return true
		end
	end

	return false
end

function QuestUtils.questObjectiveCanSelect(desc)
	return ClientTextUtils.concatByLanguage(pg.getGameString("QUEST_CAN_SELECT_TEXT"), desc)
end

function QuestUtils.navigateToTarget(targetInfo, markId)
	if not targetInfo or not targetInfo.scene or targetInfo.scene <= 0 or not markId then
		return
	end

	if pg.game and pg.game.navEffect then
		if pg.game.map:convertSceneId(targetInfo.scene) ~= pg.game.map:convertSceneId(pg.me.space.sceneId) then
			pg.global.ui:open(UIConst.UI_ID_MAP, {
				forceSceneId = targetInfo.scene,
				onMarkLoaded = function(spawnerId, spawnerTable, markCache)
					if spawnerId == tonumber(markId) then
						pg.global.ui.map:scaleFromOutside(1)
						pg.global.ui.map:diffSceneTrack(spawnerId, spawnerTable)
						markCache.button:OnClickSimulate()

						pg.global.ui.map.onMarkLoaded = nil
					end
				end
			})
		else
			local isDiffArea, isolatedIslandLinkPos, oriEndPos, isolatedIslandLinkPosAlter = pg.game.map:calDestinationPosition(targetInfo.position)

			pg.game.map:compareDistanceAtPlayerPos(isDiffArea, oriEndPos, isolatedIslandLinkPos, targetInfo.scene, function(overrideStartPosInfo)
				pg.game.navEffect:path(targetInfo.scene, overrideStartPosInfo.endPos, markId, function()
					pg.game.quest:addNavPathfindingQuest(markId)
				end, nil, overrideStartPosInfo, nil, isolatedIslandLinkPos)
			end, isolatedIslandLinkPosAlter)
		end
	end
end

function QuestUtils.getComActionObjcvDialogueId(questId)
	local dialogueId = 0
	local questConfig = QuestUtils.getQuestConfig(questId)

	if questConfig and pg.me and QuestCommonUtils.getQuestState(pg.me, questId) == QuestConst.QUEST_STATE.COMPLETED and questConfig.comActionObjcvIDs then
		local comActionObjcvIDs = questConfig.comActionObjcvIDs

		for i, v in pairs(comActionObjcvIDs) do
			if i == 1 then
				local objId = questConfig.comActionObjcvIDs[i]
				local objectData = questConfig.comActionObjcvs[objId]

				if objectData and objectData.paramVals and objectData.paramVals[TriggerConst.CUSTOM_TRIGGER_NAME_POS] == "UNLOCK_DIALOGUE_GRAPH" then
					dialogueId = tonumber(objectData.paramVals[TriggerConst.CUSTOM_TRIGGER_TARGET_POS]) or 0

					return dialogueId
				end
			end

			break
		end
	end
end

function QuestUtils.getTitleLevelConfig(star)
	local titleLevelConfig = TitleLevelConfig[star]

	if titleLevelConfig then
		return titleLevelConfig
	end
end

function QuestUtils.getLevelTipList(star)
	local list = {}
	local titleLevelConfig = QuestUtils.getTitleLevelConfig(star)
	local item = {}

	if titleLevelConfig then
		if titleLevelConfig.minLevel then
			item.playLevel = true
			item.minLevel = titleLevelConfig.minLevel
			item.maxLevel = titleLevelConfig.maxLevel
			list[#list + 1] = item
		end

		item = {}

		if titleLevelConfig.petMinLevel then
			item.minLevel = pg.getLocalizationText(titleLevelConfig.petMinLevel)
			item.maxLevel = pg.getLocalizationText(titleLevelConfig.petMaxLevel)
			list[#list + 1] = item
		end

		return list
	end
end

function QuestUtils.isInQuestBlackList(questId)
	if questId == nil or questId <= 0 then
		return false
	end

	return CommonSwitch.QUEST_BLACKLIST[questId]
end

function QuestUtils.isQuestGroupForbidByBlacklist(groupQuestId, objectives)
	objectives = objectives or QuestUtils.getReceivedQuestObjectives(groupQuestId)

	if not objectives or #objectives == 0 then
		return false
	end

	for _, obj in ipairs(objectives) do
		if not QuestUtils.isInQuestBlackList(obj.questId) then
			return false
		end
	end

	return true
end

function QuestUtils.isSubQuestManualClaimable(questId)
	if questId == nil or questId <= 0 then
		return false
	end

	return not QuestUtils.isParentQuest(questId) and QuestUtils.isQuestManualClaimable(questId)
end

return QuestUtils
