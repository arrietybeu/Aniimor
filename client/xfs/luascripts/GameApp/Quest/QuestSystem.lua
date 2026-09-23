-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Quest\\QuestSystem.lua

local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local QuestConstConfig = require("Data.quest_const")
local MessageName = require("Const.MessageName")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local SystemBase = require("GameApp.Core.SystemBase")
local QuestConst = require("Common.Const.QuestConst")
local QuestEntityData = require("Data.Quest.quest_entity_data")
local QuestMainData = require("Data.quest_main")
local LoggerConst = require("Core.Log.LoggerConst")
local ClientUtils = require("Utils.ClientUtils")
local Time = require("Core.Common.Time")
local SceneUtils = require("Common.Utils.SceneUtils")
local EventConst = require("Const.EventConst")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("QuestSystem")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local QuestSystem = Class.LightClass("QuestSystem", SystemBase)

function QuestSystem:onCtor()
	self:InitQuestChainData()
	self:startTimer(function()
		self:refreshActivityState()
	end, 10, true)
end

function QuestSystem:InitQuestChainData()
	if self.chainInited then
		return
	end

	self.SUB_ACTIVITY_CHAPTER_CHAIN = {
		1,
		2,
		3,
		120,
		121,
		124
	}
	self.activityStarted = {}
	self.activityEnded = {}
	self.SUB_ACTIVITY_CHAPTER_IDS = {}
	self.ACTIVITY_QUEST_CHAIN = {}

	local allQuestList = {}

	for _, chapterId in ipairs(self.SUB_ACTIVITY_CHAPTER_CHAIN) do
		self.SUB_ACTIVITY_CHAPTER_IDS[chapterId] = true

		local quests = QuestMainData[chapterId]

		if quests then
			for _, questInfo in pairs(quests) do
				local questId = questInfo.questGroupId
				local originSort = questInfo.sort or 0
				local newSort = chapterId * 100 + originSort

				table.insert(allQuestList, {
					id = questId,
					sort = newSort
				})
			end
		end
	end

	table.sort(allQuestList, function(a, b)
		return a.sort < b.sort
	end)

	for i = 1, #allQuestList - 1 do
		local currentId = allQuestList[i].id
		local nextId = allQuestList[i + 1].id

		self.ACTIVITY_QUEST_CHAIN[currentId] = nextId
	end

	if #allQuestList > 0 then
		self.ACTIVITY_QUEST_CHAIN[allQuestList[#allQuestList].id] = nil
	end

	self.chainInited = true
end

function QuestSystem:getNextStoryQuestId(questId)
	return self.ACTIVITY_QUEST_CHAIN[questId]
end

function QuestSystem:ActivityStart(id)
	if UNITY_PS5 then
		PlatformBridgeLuaFacade.StartActivity(id, 0, nil)
	end
end

function QuestSystem:ActivityEnd(id)
	if UNITY_PS5 then
		PlatformBridgeLuaFacade.CompleteActivity(id, 0, nil)
	end
end

function QuestSystem:getChapterBoundaryQuestGroupId(chapterId)
	local chapterInfo = QuestMainData[chapterId]

	if chapterInfo == nil then
		return nil, nil
	end

	local firstQuestGroupId, firstSort, lastQuestGroupId, lastSort
	local questGroups = {}

	for _, sectionInfo in pairs(chapterInfo) do
		if sectionInfo and sectionInfo.questGroupId and sectionInfo.questGroupId > 0 then
			local sort = tonumber(sectionInfo.sort) or 0

			table.insert(questGroups, {
				questGroupId = sectionInfo.questGroupId,
				sort = sort
			})

			if firstSort == nil or sort < firstSort then
				firstSort = sort
				firstQuestGroupId = sectionInfo.questGroupId
			end

			if lastSort == nil or lastSort < sort then
				lastSort = sort
				lastQuestGroupId = sectionInfo.questGroupId
			end
		end
	end

	if chapterId == 1 and #questGroups >= 2 then
		table.sort(questGroups, function(a, b)
			return a.sort < b.sort
		end)

		firstQuestGroupId = questGroups[2].questGroupId
	end

	return firstQuestGroupId, lastQuestGroupId
end

function QuestSystem:onActivityQuestEnd(questId)
	if questId == nil or questId == 0 then
		return
	end

	local questChapter = QuestUtils.getMainQuestChapterConfig(questId)
	local _, lastQuestGroupId = self:getChapterBoundaryQuestGroupId(questChapter.chapterId)

	if questId == lastQuestGroupId and self.SUB_ACTIVITY_CHAPTER_IDS[questChapter.chapterId] and not self.activityEnded[questChapter.chapterId] then
		self.activityEnded[questChapter.chapterId] = true

		self:ActivityEnd(questChapter.chapterId)
	end
end

function QuestSystem:onActivityQuestStart(questId)
	if questId == nil or questId == 0 then
		return
	end

	local questChapter = QuestUtils.getMainQuestChapterConfig(questId)
	local firstQuestGroupId, _ = self:getChapterBoundaryQuestGroupId(questChapter.chapterId)

	if questId == firstQuestGroupId and self.SUB_ACTIVITY_CHAPTER_IDS[questChapter.chapterId] and not self.activityStarted[questChapter.chapterId] then
		self.activityStarted[questChapter.chapterId] = true

		self:ActivityStart(questChapter.chapterId)
	end
end

function QuestSystem:ensureActivityStarted(questId)
	local questChapter = QuestUtils.getMainQuestChapterConfig(questId)
	local firstQuestGroupId, _ = self:getChapterBoundaryQuestGroupId(questChapter.chapterId)

	if firstQuestGroupId == questId then
		self:onActivityQuestStart(questId)
	end
end

function QuestSystem:refreshActivityState()
	self:InitQuestChainData()

	if self.curActivityQuestId == nil or self.curActivityQuestId == 0 then
		self.curActivityQuestId = pg.me and QuestUtils.getTracingStoryQuestId() or 0

		if self.curActivityQuestId and self.curActivityQuestId ~= 0 then
			self:ensureActivityStarted(self.curActivityQuestId)
		end
	end

	local questId = pg.me and QuestUtils.getTracingStoryQuestId() or 0

	if questId == 0 then
		return
	end

	if questId == self.curActivityQuestId then
		if self.activityQuestWaitingCheck == nil then
			if QuestUtils.isQuestSubmitted(questId) then
				-- block empty
			else
				self.activityQuestWaitingCheck = questId
			end
		elseif self.activityQuestWaitingCheck == questId and QuestUtils.isQuestSubmitted(self.activityQuestWaitingCheck) then
			self:onActivityQuestEnd(self.activityQuestWaitingCheck)

			self.activityQuestWaitingCheck = nil
		end

		return
	end

	if QuestUtils.isQuestSubmitted(self.curActivityQuestId) == false then
		return
	end

	local nextQuestId = self:getNextStoryQuestId(self.curActivityQuestId)

	if nextQuestId and nextQuestId ~= questId then
		return
	end

	local oldQuestId = self.curActivityQuestId or 0

	self.curActivityQuestId = questId

	self:onActivityQuestEnd(oldQuestId)
	self:onActivityQuestStart(questId)

	self.activityQuestWaitingCheck = questId
end

function QuestSystem:onInit()
	self.curSelectQuestId = pg.me and QuestUtils.getTracingStoryQuestId() or 0
	self.curTab = QuestConst.QUEST_HUD_PAGE_TYPE.STORY
	self.isCallbackCourse = false
	self.newQuestFlag = {}
	self.allQuestTargetsInfo = {}
	self.addQuestPathInfo = {}
	self.isHideTransitionAni = false
	self.dialogueQuestTargetsInfo = {}
	self.clueQuestTargetsInfo = {}
	self.curActivityQuestId = self.curSelectQuestId
	self.activityQuestWaitingCheck = nil
end

function QuestSystem:onPlayerEnterScene()
	if pg.me then
		if pg.me.initPlayerPipeline then
			pg.me:initPlayerPipeline()
		end

		self:reTriggerEvents()
	end
end

function QuestSystem:onDisconnected()
	self.serverDisconnected = true
end

function QuestSystem:onConnected()
	self.serverDisconnected = false

	if pg.global.ui and pg.global.ui.tips and pg.global.ui.tips.quest then
		pg.global.ui.tips.quest:refreshResidualTraceList()
	end

	if pg.me ~= nil and pg.me.isInScene and pg.game.loading:isFinished() and not pg.game.dialogue:isPlayingDialogueGraph() and not pg.game.dialogue:isPreparingToPlayDialogueGraph() then
		self:reTriggerEvents()
	end
end

function QuestSystem:onPlayerLeaveScene()
	if pg.me and pg.me.resetReTriggerEvents and self.serverDisconnected then
		pg.me:resetReTriggerEvents()
	end
end

function QuestSystem:onBackToLogin()
	if pg.me then
		pg.me:resetReTriggerEvents()
	end
end

function QuestSystem:reTriggerEvents()
	if pg.me and pg.me.notifyReTriggerEvents then
		pg.me:notifyReTriggerEvents()
	end
end

function QuestSystem:onSceneLoaded(sceneId, sceneName)
	if self.isCallbackCourse then
		self.isCallbackCourse = nil

		if self.extraArgs and self.extraArgs.muteBackToCoursePanel then
			-- block empty
		else
			pg.global.ui:open(UIConst.UI_ID_QUEST_COURSE)
		end
	end
end

function QuestSystem:setCurTab(curTab, playVX)
	if not pg.me then
		return
	end

	local isTabChanged = self.curTab ~= curTab

	self.curTab = curTab

	QuestUtils.saveLastHudPageType(curTab)

	if playVX then
		facade:sendMsgToUI(MessageName.QUEST_ON_TAB_SWITCH)
	end

	if playVX or isTabChanged then
		self:initQuestHudMark(true)
	end
end

function QuestSystem:getCurTab()
	if not self.curTabRestored and pg.me then
		self.curTabRestored = true
		self.curTab = QuestUtils.getLastHudPageType()
	end

	return self.curTab
end

function QuestSystem:setHideTransitionAni(flag)
	self.isHideTransitionAni = flag
end

function QuestSystem:getHideTransitionAni()
	return self.isHideTransitionAni
end

function QuestSystem:setCurSelectQuestId(questId)
	self.curSelectQuestId = questId
end

function QuestSystem:getCurSelectQuestId()
	return self.curSelectQuestId
end

function QuestSystem:onClaimQuest(id)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("领取任务  questID:%d", id)
	end
end

function QuestSystem:onSubmitQuest(id)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("提交任务  questID:%d", id)
	end

	facade:SendMessageCommand(MessageName.QUEST_ON_SUBMIT, {
		questId = id
	})
end

function QuestSystem:onAbandonQuest(id)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("放弃任务  questID:%d", id)
	end
end

function QuestSystem:onQuestStateChange(questId, state)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		-- block empty
	end

	local questConfig = QuestUtils.getQuestConfig(questId)

	if questConfig == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("%d任务配置不存在！", questId)
		end

		return
	end

	facade:SendMessageCommand(MessageName.QUEST_ON_STATE_CHANGE, {
		questId = questId,
		state = state
	})
	facade:SendMessageCommand(MessageName.QUEST_ON_CLUE_STATE_CHANGE, {
		questId = questId,
		state = state
	})
	facade:sendMsgToUI(MessageName.UPDATE_INTERACT_VIEW, {})

	if pg.global.platform:isPS() then
		self:refreshActivityState()
	end

	if state == QuestConst.QUEST_STATE.UNRECEIVE then
		self:onQuestCanClaim(questConfig)
	elseif state == QuestConst.QUEST_STATE.RECEIVED then
		self:onQuestClaim(questConfig, state)
	elseif state == QuestConst.QUEST_STATE.COMPLETED then
		self:onQuestCanDeliver(questConfig)
	elseif state == QuestConst.QUEST_STATE.SUBMITED then
		self:onQuestFinished(questConfig)
	elseif state == QuestConst.QUEST_STATE.CLOSE then
		self:onQuestClosed(questConfig)
	end

	if (state == QuestConst.QUEST_STATE.COMPLETED or state == QuestConst.QUEST_STATE.SUBMITED) and QuestUtils.isSpecialTrainQuest(questId) then
		QuestUtils.cleanupSpecialTrainSourceMark(questId)
	end

	self:refreshEntTopLogoQuestFlag(questId)
	pg.game.entityCount:markEntityTracingQuestDirty()
end

function QuestSystem:onQuestCanClaim(questConfig)
	self:refreshQuestHudMark(questConfig.id)
end

function QuestSystem:onQuestClaim(questConfig, state)
	self:cleanupReceiveNpcPathfinding(questConfig.id)

	if QuestUtils.isQuestVisible(questConfig.id) and QuestUtils.isChildQuest(questConfig.id) then
		pg.game.audio:triggerEvent("ui_task_hudrefresh")

		if questConfig.questType == QuestConst.QUEST_TYPE.MAIN or questConfig.questType == QuestConst.QUEST_TYPE.SIDE then
			local parentQuestData = QuestUtils.getQuestData(questConfig.parentQuest)

			if parentQuestData then
				parentQuestData.hasNew = true
			end
		end

		self.newQuestFlag[questConfig.questType] = true
	end

	self:refreshQuestHudMark(questConfig.id)
end

function QuestSystem:onQuestCanDeliver(questConfig)
	self:refreshQuestHudMark(questConfig.id)

	if questConfig.delvDialogue ~= nil then
		pg.game.dialogueSystem:playDialogue(questConfig.delvDialogue, function(ret, dialogueName)
			if ret then
				self:submitQuest(questConfig.id)
			elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("%s剧情播放失败，不能触发提交任务%d！", dialogueName, questConfig.id)
			end
		end)
	end
end

function QuestSystem:onQuestFinished(questConfig)
	self:removeTargetQuestMark(questConfig.id)
	self:removeDialogueQuestTargetsInfo()
	self:removeTargetClueQuestMark(questConfig.id)
	self:refreshEntTopLogoQuestFlag(questConfig.id)
	self:removeAllQuestPathfinding()
end

function QuestSystem:onQuestClosed(questConfig)
	self:removeTargetQuestMark(questConfig.id)
	self:cleanupReceiveNpcPathfinding(questConfig.id)
	self:refreshEntTopLogoQuestFlag(questConfig.id)
end

function QuestSystem:onObjectiveChange(questId, objectiveId, isFined)
	if QuestUtils.isQuestVisible(questId) then
		facade:sendMsgToUI(MessageName.QUEST_ON_OBJECTIVE_CHANGED, {
			questId = questId,
			objectiveId = objectiveId,
			isFined = isFined
		})

		if isFined then
			facade:SendMessageCommand(MessageName.QUEST_ON_OBJECTIVE_FINISHED, {
				questId = questId,
				objectiveId = objectiveId
			})
			self:refreshQuestHudMark(questId)
		end
	end

	self:refreshEntTopLogoQuestFlag(questId)
end

function QuestSystem:refreshEntTopLogoQuestFlag(questId)
	local questEntData = QuestEntityData[questId]

	if questEntData == nil then
		return
	end

	local questData = QuestUtils.getQuestData(questId)

	local function emitQuestTopLogo(ent, canShow)
		local questComponent = ent.getToplogoComponent and ent:getToplogoComponent(UIConst.TOPLOGO_COMPONENT.QUEST)

		if canShow and ent.ensureToplogoComponent then
			questComponent = ent:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.QUEST, "quest_state")
		end

		if questComponent then
			ent.eventEmitter:emit(EventConst.TOPLOGO_QUEST, {
				canShow = canShow
			})
		end
	end

	for i = 1, #questEntData do
		local data = questEntData[i]

		if data.state == nil or questData then
			if data.staticId then
				local ent = pg.me.space:getEntityByStaticId(data.staticId)

				if ent then
					emitQuestTopLogo(ent, data.state == questData.state)
				end
			elseif data.petProtoTypeId then
				local entities = pg.getEntitiesByPetPrototypeId(data.petProtoTypeId)

				if entities then
					for k, ent in pairs(entities) do
						emitQuestTopLogo(ent, data.state == questData.state)
					end
				end
			elseif data.templateId then
				local entities = pg.getEntitiesByTemplateId(data.templateId)

				if entities then
					for k, ent in pairs(entities) do
						emitQuestTopLogo(ent, data.state == questData.state)
					end
				end
			end
		end
	end
end

function QuestSystem:onQuestTraceChange(tracingQuestId, untracingQuestId)
	pg.game.audio:triggerEvent("ui_task_hudrefresh")
	self:refreshTracingQuestMapMark(tracingQuestId, untracingQuestId)

	if tracingQuestId > 0 and not QuestUtils.isInCourseScene() then
		-- block empty
	end

	pg.game.entityCount:markEntityTracingQuestDirty()
end

function QuestSystem:onQuestRunStateChange(questId, isRun)
	if not isRun then
		self:removeQuestPathfindingByQuestId(questId)
	end

	self:refreshQuestHudMark(questId)

	local msg = {}

	msg.questId = questId
	msg.isRun = isRun

	facade:sendMsgToUI(MessageName.QUEST_ON_RUN_STATE_CHANGE, msg)
end

function QuestSystem:onTimeTokenReached(tokenId)
	local questId = QuestUtils.getPageTraceQuestId()

	if questId and questId ~= 0 and pg.global.ui.tips and pg.global.ui.tips.quest then
		pg.global.ui.tips.quest:onQuestRunStateChanged({
			questId = questId
		})
	end
end

function QuestSystem:onClueQuestRevealFlagChanged(clueQuestId, isReveal)
	self:refreshClueQuestHudMark(clueQuestId)

	local msg = {}

	msg.questId = clueQuestId

	facade:sendMsgToUI(MessageName.QUEST_ON_CLUE_STATE_CHANGE, msg)
end

function QuestSystem:doTheQuest(questData)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("doTheQuest  questID:%d", questData.id)
	end

	local state = questData.state

	if state == QuestConst.QUEST_STATE.INIT then
		self:doTheOpenedQuest(questData)
	elseif state == QuestConst.QUEST_STATE.UNRECEIVE then
		self:doTheCanClaimQuest(questData)
	elseif state == QuestConst.QUEST_STATE.RECEIVED then
		self:doTheInProgressQuest(questData)
	elseif state == QuestConst.QUEST_STATE.COMPLETED then
		self:doTheFinishedQuest(questData)
	elseif state == QuestConst.QUEST_STATE.FAILED then
		self:doTheFailedQuest(questData)
	elseif state == QuestConst.QUEST_STATE.SUBMITED then
		-- block empty
	end
end

function QuestSystem:doTheOpenedQuest(questData)
	return
end

function QuestSystem:doTheCanClaimQuest(questData)
	return
end

function QuestSystem:doTheInProgressQuest(questData)
	return
end

function QuestSystem:doTheFinishedQuest(questData)
	return
end

function QuestSystem:doTheFailedQuest(questData)
	return
end

function QuestSystem:acceptQuest(questId)
	pg.me:acceptQuest(questId)
end

function QuestSystem:submitQuest(questId)
	pg.me:deliveryQuest(questId)
end

function QuestSystem:abandonQuest(questId)
	pg.me:abandonQuest(questId)
end

function QuestSystem:initQuestHudMark(isSwitchTab)
	self:removeAllQuestHudMark()

	if pg.game.map and pg.game.map.populateSceneMarkPointOverlap then
		pg.game.map:populateSceneMarkPointOverlap()
	end

	local acceptedQuests = QuestUtils.getAllAcceptedQuestsData()

	for _, sv in pairs(acceptedQuests) do
		self:addQuestMark(sv, isSwitchTab)
	end
end

function QuestSystem:addQuestMark(questData, isSwitchTab)
	if questData == nil then
		return
	end

	if questData.configId and not QuestUtils.canShowQuestTracking(questData.configId) then
		return
	end

	local targetsInfo = QuestUtils.getQuestTargetInfo(questData, true)

	if targetsInfo == nil then
		return nil
	end

	local questId = targetsInfo.questId
	local questConfig = QuestUtils.getQuestConfig(questId)

	if questConfig == nil then
		return nil
	end

	local visible = questConfig.visible

	if not visible then
		return nil
	end

	local rootQuestId = QuestUtils.getRootQuestId(questId)
	local isCurtain = QuestUtils.isCurtainQuest(rootQuestId)
	local isClueQuest = QuestUtils.isQuestOfClueQuestType(questId)

	if not isCurtain and not isClueQuest then
		return nil
	end

	local questState = targetsInfo.state
	local targetCount = #targetsInfo.posInfo
	local isAddMark = false
	local hasQuestMark = false

	for i = 1, targetCount do
		local targetInfo = targetsInfo.posInfo[i]
		local pos = targetInfo.pos
		local sceneId = targetInfo.sceneId

		if not sceneId and targetInfo.posConfig then
			sceneId = targetInfo.posConfig.scene
		end

		if sceneId then
			local markType = Const.MAP_MARK_QUEST
			local showPath = targetInfo.showPath
			local circleRadius = targetInfo.circleRadius
			local arg = {
				arg1 = targetInfo.objId,
				arg2 = questId,
				arg3 = questState,
				arg5 = circleRadius,
				arg6 = sceneId,
				arg7 = targetInfo.objId
			}
			local combineId = QuestUtils.getCombinedId(questId, targetInfo.objId)

			if QuestUtils.isPageContainQuest(questId) and QuestUtils.isCurQuestTracing(questId) or not isClueQuest and QuestUtils.isEmptyPageContainQuest(questId) then
				local markId = pg.game.map:addOrUpdateTempMark(sceneId, pos[1], pos[2], pos[3], combineId, markType, arg)

				if (QuestUtils.isQuestTracing(questId) or QuestUtils.isRootQuestTracing(questId)) and pg.game.map:convertSceneId(sceneId) == pg.game.map:convertSceneId(pg.me.space.sceneId) then
					pg.game.map:manualTraceQuestMark(markType, markId, showPath)
				end

				targetsInfo.posInfo[i].markId = markId
				isAddMark = true
				hasQuestMark = true
			elseif not isSwitchTab and isClueQuest and QuestUtils.isClueReveal(questId) then
				local markId = pg.game.map:addOrUpdateTempMark(sceneId, pos[1], pos[2], pos[3], questId, Const.MAP_MARK_CLUE, arg)

				targetsInfo.posInfo[i].markId = markId
				isAddMark = true
			end
		end
	end

	if hasQuestMark then
		self.allQuestTargetsInfo[questId] = targetsInfo
	elseif isClueQuest and isAddMark then
		self.clueQuestTargetsInfo[questId] = targetsInfo
	end
end

function QuestSystem:refreshQuestHudMark(questId)
	local oldTargetsInfo = self.allQuestTargetsInfo[questId]

	if oldTargetsInfo ~= nil and oldTargetsInfo.posInfo then
		local targetCount = #oldTargetsInfo.posInfo

		for i = 1, targetCount do
			local targetInfo = oldTargetsInfo.posInfo[i]

			self:removeTargetMark(targetInfo)
		end

		self.allQuestTargetsInfo[questId] = nil
	end

	local questData = QuestUtils.getQuestData(questId)

	self:addQuestMark(questData)
end

function QuestSystem:refreshClueQuestHudMark(questId)
	local oldTargetsInfo = self.clueQuestTargetsInfo[questId]

	if oldTargetsInfo ~= nil and oldTargetsInfo.posInfo then
		local targetCount = #oldTargetsInfo.posInfo

		for i = 1, targetCount do
			local targetInfo = oldTargetsInfo.posInfo[i]

			self:removeTargetMark(targetInfo)
		end

		self.clueQuestTargetsInfo[questId] = nil
	end

	local questData = QuestUtils.getQuestData(questId)

	self:addQuestMark(questData)
end

function QuestSystem:refreshTracingQuestMapMark(tracingQuestId, untracingQuestId)
	if untracingQuestId > 0 then
		local targetsInfo = self.allQuestTargetsInfo[untracingQuestId]

		if targetsInfo and targetsInfo.posInfo then
			for _, v in pairs(targetsInfo.posInfo) do
				if v.markId then
					pg.game.map:manualUnTraceQuestMark(v.markId)
				end
			end

			self:removeAllQuestPathfinding()
			self:removeAllQuestHudMark()
		else
			local subQuests = QuestUtils.getAllDescendantQuests(untracingQuestId)

			if subQuests ~= nil then
				for i = 1, #subQuests do
					local id = subQuests[i]
					local targetsInfo = self.allQuestTargetsInfo[id]

					if targetsInfo and targetsInfo.posInfo then
						for _, v in pairs(targetsInfo.posInfo) do
							if v.markId then
								pg.game.map:manualUnTraceQuestMark(v.markId)
							end
						end
					end
				end
			end

			self:removeAllQuestPathfinding()
			self:removeAllQuestHudMark()
		end
	end

	if tracingQuestId > 0 then
		local targetsInfo = self.allQuestTargetsInfo[tracingQuestId]

		if targetsInfo and targetsInfo.posInfo then
			for _, v in pairs(targetsInfo.posInfo) do
				if v.markId then
					pg.game.map:manualTraceQuestMark(Const.MAP_MARK_QUEST, v.markId, v.showPath)
				end
			end
		else
			local subQuests = QuestUtils.getAllDescendantQuests(tracingQuestId)

			if subQuests ~= nil then
				for i = 1, #subQuests do
					local id = subQuests[i]
					local targetsInfo = self.allQuestTargetsInfo[id]

					if targetsInfo and targetsInfo.posInfo then
						for _, v in pairs(targetsInfo.posInfo) do
							if v.markId then
								pg.game.map:manualTraceQuestMark(Const.MAP_MARK_QUEST, v.markId, v.showPath)
							end
						end
					else
						local questData = QuestUtils.getQuestData(id)

						if questData then
							self:addQuestMark(questData)
						end
					end
				end
			end
		end
	end

	self:removeDialogueQuestTargetsInfo()
end

function QuestSystem:removeTargetQuestMark(questId)
	local targetsInfo = self.allQuestTargetsInfo[questId]

	if targetsInfo == nil or targetsInfo.posInfo == nil then
		return
	end

	local targetCount = #targetsInfo.posInfo

	for i = 1, targetCount do
		local targetInfo = targetsInfo.posInfo[i]

		self:removeTargetMark(targetInfo)
	end

	self.allQuestTargetsInfo[questId] = nil
end

function QuestSystem:removeTargetClueQuestMark(questId)
	local targetsInfo = self.clueQuestTargetsInfo[questId]

	if targetsInfo == nil or targetsInfo.posInfo == nil then
		return
	end

	local targetCount = #targetsInfo.posInfo

	for i = 1, targetCount do
		local targetInfo = targetsInfo.posInfo[i]

		self:removeTargetMark(targetInfo)
	end

	self.clueQuestTargetsInfo[questId] = nil
end

function QuestSystem:removeTargetQuestObjMark(questId, objId)
	local targetsInfo = self.allQuestTargetsInfo[questId]

	if targetsInfo == nil then
		return
	end

	local targetCount = #targetsInfo.posInfo

	for i = 1, targetCount do
		local targetInfo = targetsInfo.posInfo[i]

		if targetInfo.objId ~= nil and targetInfo.objId == objId then
			self:removeTargetMark(targetInfo)

			break
		end
	end
end

function QuestSystem:removeTargetMark(targetInfo)
	if targetInfo.markId == nil then
		return
	end

	local sceneId = targetInfo.sceneId

	if not sceneId and targetInfo.posConfig then
		sceneId = targetInfo.posConfig.scene
	end

	if sceneId then
		pg.game.map:removeTempMark(sceneId, targetInfo.markId)

		targetInfo.markId = nil
	end
end

function QuestSystem:removeAllQuestHudMark()
	for k, v in pairs(self.allQuestTargetsInfo) do
		self:removeTargetQuestMark(k)
	end

	table.clear(self.allQuestTargetsInfo)
end

function QuestSystem:addDialogueQuestTargetsInfo(questId, targetsInfo)
	self.dialogueQuestTargetsInfo[questId] = targetsInfo
end

function QuestSystem:removeDialogueQuestTargetsInfo()
	for k, v in pairs(self.dialogueQuestTargetsInfo) do
		if v.scene and v.markId then
			pg.game.map:removeTempMark(v.scene, v.markId)
		end
	end

	table.clear(self.dialogueQuestTargetsInfo)
end

function QuestSystem:addNavPathfindingQuest(questId)
	table.insert(self.addQuestPathInfo, questId)
end

function QuestSystem:removeAllQuestPathfinding()
	for k, v in pairs(self.addQuestPathInfo) do
		QuestUtils.removeQuestPathingNavEffect(v)
	end

	table.clear(self.addQuestPathInfo)
end

function QuestSystem:removeQuestPathfindingByQuestId(questId)
	local targetsInfo = self.allQuestTargetsInfo[questId]

	if not targetsInfo then
		local questData = QuestUtils.getQuestData(questId)

		targetsInfo = questData and QuestUtils.getQuestTargetInfo(questData, true) or nil
	end

	if not targetsInfo or not targetsInfo.posInfo then
		return
	end

	local combinedIds = {}

	for _, targetInfo in pairs(targetsInfo.posInfo) do
		if targetInfo.objId then
			local combineId = QuestUtils.getCombinedId(questId, targetInfo.objId)

			combinedIds[combineId] = true

			QuestUtils.removeQuestPathingNavEffect(combineId)
		end
	end

	for i = #self.addQuestPathInfo, 1, -1 do
		if combinedIds[self.addQuestPathInfo[i]] then
			table.remove(self.addQuestPathInfo, i)
		end
	end
end

function QuestSystem:cleanupReceiveNpcPathfinding(questId)
	if not questId then
		return
	end

	local combineId = QuestUtils.getCombinedId(questId, QuestConst.QUEST_DEFAULT_OBJ_ID)

	QuestUtils.removeQuestPathingNavEffect(combineId)

	local targetInfo = self.dialogueQuestTargetsInfo[questId]

	if targetInfo then
		if targetInfo.scene and targetInfo.markId then
			pg.game.map:removeTempMark(targetInfo.scene, targetInfo.markId)
		end

		self.dialogueQuestTargetsInfo[questId] = nil
	end
end

function QuestSystem:hadNewQuest()
	return table.getCount(self.newQuestFlag) > 0
end

function QuestSystem:hadNewQuestFlag(qusetType)
	return self.newQuestFlag[qusetType] == true
end

function QuestSystem:resetNewQuestFlag(qusetType)
	self.newQuestFlag[qusetType] = nil
end

function QuestSystem:onClear()
	self.curSelectQuestId = 0
	self.isHideTransitionAni = false
	self.curTab = 1
	self.curTabRestored = nil

	table.clear(self.newQuestFlag)
	table.clear(self.allQuestTargetsInfo)
	table.clear(self.addQuestPathInfo)
	table.clear(self.dialogueQuestTargetsInfo)
	table.clear(self.clueQuestTargetsInfo)
end

function QuestSystem:onDestroy()
	return
end

function QuestSystem:forceTracedQuest(questId)
	local rootQuestId = QuestUtils.getRootQuestId(questId)

	if rootQuestId == nil or rootQuestId == 0 then
		rootQuestId = QuestUtils.getParentQuestId(questId)
	end

	if rootQuestId and QuestUtils.isQuestInState(rootQuestId, QuestConst.QUEST_STATE.RECEIVED) then
		pg.me:traceQuest(rootQuestId, true)

		local pageType = QuestUtils.getPageType(rootQuestId)

		QuestUtils.switchHudPageType(pageType)

		if pg.global.ui and pg.global.ui.tips and pg.global.ui.tips.quest then
			pg.global.ui.tips.quest:switchQuestPageType(pageType)
		end
	end
end

return QuestSystem
