-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Quest\\QuestModel.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("QuestModel")
local UIModel = require("Guis.UIModel")
local lume = require("Core.Common.lume")
local QuestConst = require("Common.Const.QuestConst")
local QuestMain = require("Data.quest_main")
local QuestChapter = require("Data.quest_chapter")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local QuestCommonUtils = require("Common.Utils.QuestCommonUtils")
local PlayerTitleData = require("Data.player_title_data")
local QuestCatalogConfig = require("Data.quest_catalog")
local QuestClueCatalogConfig = require("Data.quest_clue_catalog")
local MapBlockConfigData = require("Data.map_block_config_data")
local MapAreaConfigData = require("Data.map_area_config_data")
local NationConfigData = require("Data.nation_config_data")
local QuestChapterProgressRewardData = require("Data.quest_chapter_progress_reward_data")
local json = require("json")
local Class = require("Core.Framework.Class")
local QuestModel = Class.LightClass("QuestModel", UIModel)

QuestModel.MainStoryType = {
	Chapter = 1,
	Animal = 3,
	Regonial = 2
}
QuestModel.VXAniName = {
	Chapter_Story_Item_In = {
		"VX_Node_MainStory_TabTaskItem_In",
		0.05
	},
	Chapter_Area_Item_In = {
		"VX_Node_AreaStory_TabTaskItem_In",
		0.05
	},
	Quest_Objective_Item_In = {
		"VX_Node_MainStory_TaskItem_In",
		0.05
	}
}

function QuestModel:getAllChapterTypes(mainType, selectIdQuestId)
	if selectIdQuestId ~= nil then
		local chapterId, sectionId = QuestUtils.getQuestGroupChapterInfo(selectIdQuestId)

		selectIdQuestId = chapterId and chapterId > 0 and sectionId and sectionId > 0 and QuestUtils.getQuestMainGroupId(chapterId, sectionId) or selectIdQuestId
	end

	local selectInfo
	local allChapterTypeInfo = {}
	local selectedAreaIds

	if mainType == QuestConst.MainType.Clue then
		for i, v in pairs(QuestClueCatalogConfig) do
			local subTypes = {}
			local chapterFirstQuestId = 0

			for j = 1, #v.quests do
				local quest = v.quests[j]
				local reveal = QuestUtils.isClueReveal(quest.questId)

				if reveal and QuestUtils.isWorldRumor(quest.questId) then
					if selectedAreaIds == nil then
						selectedAreaIds = pg.game.map:getMapAreaSelectedSetting()
					end

					local location = self:getClueLocationId(quest.questId)
					local canAreaShow = self:checkAreaCanShow(mainType, selectedAreaIds, location)

					if canAreaShow then
						table.insert(subTypes, {
							tIndex = 2,
							chapterType = v.chapterType,
							subTypeName = v.subTypeName,
							quest = quest
						})

						local curListId = quest.listId or 0
						local curIndex = #allChapterTypeInfo + #subTypes

						if selectIdQuestId ~= nil and selectIdQuestId == quest.questId then
							selectInfo = {
								mainType = mainType,
								chapterType = v.chapterType,
								questId = quest.questId,
								listId = curListId,
								index = curIndex
							}
						else
							local selectListId = selectInfo ~= nil and selectInfo.listId or 0

							if selectInfo == nil or selectListId < curListId or QuestUtils.isQuestTracing(quest.questId) then
								selectInfo = {
									mainType = mainType,
									chapterType = v.chapterType,
									questId = quest.questId,
									listId = curListId,
									index = curIndex
								}
							end
						end

						chapterFirstQuestId = quest.questId
					end
				end
			end

			if #subTypes > 0 then
				table.insert(allChapterTypeInfo, {
					tIndex = 1,
					chapterType = v.chapterType,
					chapterTypeName = v.subTypeName,
					questId = chapterFirstQuestId
				})
				table.sort(subTypes, function(a, b)
					local cfg_a = QuestUtils.getQuestConfig(a.quest.questId)
					local cfg_b = QuestUtils.getQuestConfig(b.quest.questId)
					local groupId_a = cfg_a and cfg_a.groupId or 0
					local groupId_b = cfg_b and cfg_b.groupId or 0

					if groupId_a == groupId_b then
						return a.quest.questId < b.quest.questId
					end

					return groupId_a < groupId_b
				end)

				if selectInfo and selectInfo.chapterType == v.chapterType then
					for k, st in ipairs(subTypes) do
						if st.quest.questId == selectInfo.questId then
							selectInfo.index = #allChapterTypeInfo + k - 1

							break
						end
					end
				end

				lume.append(allChapterTypeInfo, subTypes)
			end
		end
	else
		for i, v in pairs(QuestCatalogConfig) do
			local chapterFirstQuestId = 0
			local chapterType = v.chapterType

			if v.mainType == mainType then
				local allChapters = {}

				for i = 1, #v.chapters do
					local chapterId = v.chapters[i]
					local chapterConfig = self:getChapterInfo(chapterId)
					local allSections = {}
					local hasSectionFilteredByArea = false
					local sections = QuestMain[chapterId] or {}
					local isAdventure = mainType == QuestConst.MainType.Adventure

					for sectionId, v in pairs(sections) do
						local isUnlock = self:isMainSectionUnlock(chapterId, sectionId, mainType)
						local isFinished = self:isMainSectionFinished(chapterId, sectionId)
						local canShow = isUnlock and not isFinished

						if canShow then
							local canAreaShow = true

							if mainType == QuestConst.MainType.Adventure then
								if selectedAreaIds == nil then
									selectedAreaIds = pg.game.map:getMapAreaSelectedSetting()
								end

								if selectedAreaIds ~= nil and #selectedAreaIds > 0 then
									local sectionConfig = self:getSectionInfo(chapterId, sectionId)
									local location = sectionConfig and sectionConfig.location or nil

									canAreaShow = self:checkAreaCanShow(mainType, selectedAreaIds, location)
								end
							end

							if canAreaShow then
								local tIndex = chapterConfig.showChapterName ~= 1 and 2 or 0

								table.insert(allSections, {
									tIndex = tIndex,
									chapterType = chapterType,
									chapterId = chapterId,
									sectionId = sectionId,
									sort = v.sort
								})

								local isTracing = self:isSectionTracing(chapterId, sectionId)

								if selectIdQuestId ~= nil and selectIdQuestId == v.questGroupId then
									local index = #allChapterTypeInfo + table.getCount(allChapters)

									selectInfo = {
										matched = true,
										chapterType = chapterType,
										chapterId = chapterId,
										sectionId = sectionId,
										index = index,
										tracing = isTracing
									}
								elseif selectInfo and selectInfo.matched then
									-- block empty
								elseif selectInfo == nil or selectInfo.sectionId and sectionId < selectInfo.sectionId and not selectInfo.tracing or isTracing then
									local index = #allChapterTypeInfo + table.getCount(allChapters)

									selectInfo = {
										chapterType = chapterType,
										chapterId = chapterId,
										sectionId = sectionId,
										index = index,
										tracing = isTracing
									}
								end
							else
								hasSectionFilteredByArea = true
							end

							chapterFirstQuestId = v.questGroupId
						end
					end

					local allRewardClaimed = self:isChapterProgressRewardAllClaimed(chapterId)
					local hasAcceptedSection = self:isChapterHasAcceptedSection(chapterId)
					local isAreaFilterActive = selectedAreaIds ~= nil and #selectedAreaIds > 0

					if #allSections > 0 or not hasSectionFilteredByArea and not allRewardClaimed and hasAcceptedSection and not isAreaFilterActive then
						if #allSections > 0 then
							local function sortFunc(a, b)
								return a.sort < b.sort
							end

							table.sort(allSections, sortFunc)
						end

						if chapterConfig.showChapterName ~= 1 then
							if #allSections > 0 then
								lume.append(allChapters, allSections)
							else
								local chapterInfo = {
									tIndex = 0,
									chapterType = chapterType,
									chapterId = chapterId,
									sections = {}
								}

								table.insert(allChapters, chapterInfo)

								if selectInfo == nil then
									local curIndex = #allChapterTypeInfo + table.getCount(allChapters) - 1

									selectInfo = {
										chapterType = chapterType,
										chapterId = chapterId,
										index = curIndex
									}
								end
							end
						else
							if chapterFirstQuestId == 0 and chapterConfig.showChapterName == 1 then
								chapterFirstQuestId = QuestUtils.getFirstSectionQuestIdByChapterId(chapterId)

								if selectInfo == nil then
									local curIndex = #allChapterTypeInfo + table.getCount(allChapters)

									selectInfo = {
										chapterType = chapterType,
										chapterId = chapterId,
										index = curIndex
									}
								end
							end

							local chapterInfo = {
								tIndex = 0,
								chapterType = chapterType,
								chapterId = chapterId,
								sections = allSections
							}

							table.insert(allChapters, chapterInfo)
						end
					end
				end

				if #allChapters > 0 then
					table.insert(allChapterTypeInfo, {
						tIndex = 1,
						chapterType = chapterType,
						chapterTypeName = v.chapterTypeName,
						questId = chapterFirstQuestId
					})
					lume.append(allChapterTypeInfo, allChapters)
				end
			end
		end
	end

	return allChapterTypeInfo, selectInfo
end

function QuestModel:checkAreaCanShow(mainType, selectedAreaIds, locationId)
	if mainType ~= QuestConst.MainType.Adventure and mainType ~= QuestConst.MainType.Clue then
		return true
	end

	if selectedAreaIds == nil or #selectedAreaIds == 0 then
		return true
	end

	if locationId == nil or locationId == 0 then
		return false
	end

	local locationConfig = MapBlockConfigData[locationId]
	local canShow = false

	for countyId, mapAreaIds in pairs(selectedAreaIds) do
		if countyId == locationConfig.countryId then
			canShow = table.getCount(mapAreaIds) == 0

			for mapAreaId, smallMapAreaIds in pairs(mapAreaIds) do
				if mapAreaId == locationConfig.mapAreaId then
					canShow = table.getCount(smallMapAreaIds) == 0
					canShow = canShow or smallMapAreaIds[locationId]
				end
			end
		end
	end

	return canShow
end

function QuestModel:getMapAreaFilterIntro()
	self.countryAreaList = pg.game.map:getMapAreaSelectedSetting()

	if next(self.countryAreaList) then
		local intro = "%s-%s·%d"
		local countTryName, mapAreaName, smallMapAreaCount

		for k, v in pairs(self.countryAreaList) do
			local countryConfig = NationConfigData[k]

			if countryConfig == nil then
				return false
			end

			countTryName = pg.getLocalizationText(countryConfig.name)

			for sk, sv in pairs(v) do
				if MapAreaConfigData[sk] then
					mapAreaName = pg.getLocalizationText(MapAreaConfigData[sk].areaName)
				end

				smallMapAreaCount = table.getCount(sv)
			end
		end

		if mapAreaName == nil then
			return true, string.format("%s", countTryName)
		elseif smallMapAreaCount == 0 or smallMapAreaCount == nil then
			return true, string.format("%s-%s", countTryName, mapAreaName)
		else
			return true, string.format("%s-%s·%d", countTryName or "", mapAreaName or "", smallMapAreaCount or 0)
		end
	end

	return false
end

function QuestModel:isClueUnlock(questId)
	local questData = QuestUtils.getQuestData(questId)

	if questData ~= nil and QuestUtils.isQuestDataInState(questData, QuestConst.QUEST_STATE.RECEIVED) then
		return true
	end

	return false
end

function QuestModel:isClueFinished(questId)
	return QuestUtils.isQuestSubmitted(questId)
end

function QuestModel:getChapterTypesInfo(questId)
	local temp = {}
	local chapterId, sectionId = QuestUtils.getQuestGroupChapterInfo(questId)
	local tracingChapterType, tracingChapterId, hasNewChapterType, hasNewChapterId, firstChapterType, firstChapterId

	for i, v in pairs(QuestChapter) do
		if self:isMainChapterTypeUnlock(i) then
			local chapterTypeName, icon

			for k, v in pairs(QuestChapter[i]) do
				if (firstChapterType == nil or k < firstChapterId) and self:isMainChapterUnlock(k) and not self:isMainChapterFinished(k) then
					firstChapterType = i
					firstChapterId = k
				end

				if tracingChapterType == nil and self:isMainChapterTracing(k) then
					tracingChapterType = i
					tracingChapterId = k
				elseif self:isMainChapterHasNewQuset(k) then
					hasNewChapterType = i
					hasNewChapterId = k
				end

				if v.chapterTypeName then
					chapterTypeName = v.chapterTypeName
				end

				if v.imageType then
					icon = v.imageType
				end
			end

			table.insert(temp, {
				chapterType = i,
				chapterTypeName = chapterTypeName,
				icon = icon
			})
		end
	end

	table.sort(temp, function(a, b)
		return a.chapterType < b.chapterType
	end)

	local selectInfo

	if tracingChapterType ~= nil then
		selectInfo = {
			type = tracingChapterType,
			id = tracingChapterId
		}
	elseif hasNewChapterType ~= nil then
		selectInfo = {
			type = hasNewChapterType,
			id = hasNewChapterId
		}
	elseif self.lastSelectMainChapterType ~= nil then
		selectInfo = {
			type = self.lastSelectMainChapterType,
			id = self.lastSelectMainChapterId
		}
	else
		selectInfo = {
			type = firstChapterType,
			id = firstChapterId
		}
	end

	if chapterId and chapterId > 0 then
		selectInfo = {
			type = firstChapterType,
			id = chapterId
		}
	end

	return temp, selectInfo
end

function QuestModel:getChapterInfo(chapterId)
	return QuestChapter[chapterId]
end

function QuestModel:getSectionInfo(chapterId, sectionId)
	return QuestMain[chapterId][sectionId]
end

function QuestModel:getClueCatalogConfig(listId)
	return QuestClueCatalogConfig[listId]
end

function QuestModel:getChapterLocation(chapterType, chapterId)
	local chapterInfo = QuestChapter[chapterType][chapterId]

	if chapterInfo ~= nil and chapterInfo.location ~= nil then
		return MapBlockConfigData[chapterInfo.location]
	end
end

function QuestModel:getSectionLocation(chapterId, sectionId)
	local sectionConfig = self:getSectionInfo(chapterId, sectionId)

	if sectionConfig and sectionConfig.location then
		return MapBlockConfigData[sectionConfig.location]
	end
end

function QuestModel:getClueLocation(questId)
	local areaId = self:getClueLocationId(questId)

	if areaId then
		return MapBlockConfigData[areaId]
	end
end

function QuestModel:getClueLocationId(clueQuestId)
	return QuestUtils.getReceivedQuestObjcvAreaId(clueQuestId)
end

function QuestModel:isMainChapterTypeUnlock(chapterType)
	local chapters = QuestChapter[chapterType]

	for i, v in pairs(chapters) do
		if i ~= "tIndex" and self:isMainChapterUnlock(i) and not self:isMainChapterFinished(i) then
			return true
		end
	end

	return false
end

function QuestModel:getChaptersByType(chapterType)
	local temp = {}
	local chapters = QuestChapter[chapterType]

	for i, v in pairs(chapters) do
		if self:isMainChapterUnlock(i) and not self:isMainChapterFinished(i) then
			local index = chapterType == QuestModel.MainStoryType.Chapter and 0 or 1

			table.insert(temp, {
				tIndex = 0,
				chapterType = chapterType,
				chapterId = i,
				chapter = v
			})
		end
	end

	local function sortFunc(a, b)
		return a.chapter.sort < b.chapter.sort
	end

	table.sort(temp, sortFunc)

	return temp
end

function QuestModel:recordMainSelectInfo(chapterType, chapterId)
	self.lastSelectMainChapterType = chapterType
	self.lastSelectMainChapterId = chapterId
end

function QuestModel:isMainChapterTypeTracing(chapterType)
	local chapters = QuestChapter[chapterType]

	for i, v in pairs(chapters) do
		if self:isMainChapterTracing(i) then
			return true
		end
	end

	return false
end

function QuestModel:isMainChapterUnlock(chapterId)
	local sections = QuestMain[chapterId]

	if sections == nil then
		return false
	end

	for k, v in pairs(sections) do
		local questId = v.questGroupId
		local questData = QuestUtils.getQuestData(questId)

		if questData ~= nil and QuestUtils.isQuestDataInState(questData, QuestConst.QUEST_STATE.RECEIVED) or QuestUtils.isQuestSubmitted(questId) then
			return true
		end
	end

	return false
end

function QuestModel:isMainChapterTracing(chapterId)
	local sections = QuestMain[chapterId]

	for k, v in pairs(sections) do
		local questId = v.questGroupId
		local questData = QuestUtils.getQuestData(questId)

		if questData and QuestUtils.isQuestDataTracing(questData) then
			return true
		end
	end

	return false
end

function QuestModel:isSectionTracing(chapterId, sectionId)
	local sectionConfig = self:getSectionInfo(chapterId, sectionId)

	if sectionConfig then
		local questId = sectionConfig.questGroupId
		local questData = QuestUtils.getQuestData(questId)

		if questData and QuestUtils.isQuestDataTracing(questData) then
			return true
		end
	end

	return false
end

function QuestModel:isQuestInMainChapter(chapterId, questId)
	local sections = QuestMain[chapterId]

	for k, v in pairs(sections) do
		if v.questGroupId == questId then
			return true
		end
	end

	return false
end

function QuestModel:isMainChapterHasNewQuset(chapterId, resetFlag)
	local sections = QuestMain[chapterId]

	if sections == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("没有配置section信息！", chapterId)
		end

		return false
	end

	for k, v in pairs(sections) do
		local questId = v.questGroupId
		local questData = QuestUtils.getQuestData(questId)

		if questData and questData.hasNew == true then
			if resetFlag == true then
				questData.hasNew = nil
			end

			return true
		end

		return false
	end
end

function QuestModel:getMainChapterSections(chapterId)
	local temp = {}
	local maxSection = 0
	local sections = QuestMain[chapterId]

	for i, v in pairs(sections) do
		if self:isMainSectionUnlock(chapterId, i) and not self:isMainSectionFinished(chapterId, i) then
			table.insert(temp, {
				chapterId = chapterId,
				sectionId = i,
				sectionInfo = v
			})

			maxSection = maxSection + 1
		end
	end

	table.sort(temp, function(a, b)
		return a.sectionInfo.sort < b.sectionInfo.sort
	end)

	return temp, maxSection
end

function QuestModel:isMainSectionUnlock(chapterId, sectionId, mainType)
	local sectionInfo = QuestMain[chapterId][sectionId]

	if sectionInfo == nil then
		return false
	end

	if QuestUtils.isQuestInState(sectionInfo.questGroupId, QuestConst.QUEST_STATE.RECEIVED) or QuestUtils.isQuestFinished(sectionInfo.questGroupId) or QuestUtils.isQuestSubmitted(sectionInfo.questGroupId) then
		return true
	end

	if mainType == QuestConst.MainType.Adventure then
		return QuestUtils.hasChapterAnyQuestReceived(chapterId)
	end

	return false
end

function QuestModel:isMainChapterFinished(chapterId)
	local chapterInfo = QuestMain[chapterId]

	if chapterInfo == nil then
		return false
	end

	for k, v in pairs(chapterInfo) do
		if not self:isMainSectionFinished(chapterId, k) and self:isMainSectionUnlock(chapterId, k) then
			return false
		end
	end

	return true
end

function QuestModel:isMainSectionFinished(chapterId, sectionId)
	local sectionInfo = QuestMain[chapterId][sectionId]

	if sectionInfo == nil or sectionInfo.questGroupId == nil then
		return false
	end

	if not QuestUtils.isQuestFinished(sectionInfo.questGroupId) and not QuestUtils.isQuestSubmitted(sectionInfo.questGroupId) then
		return false
	end

	return true
end

function QuestModel:isAssessmentTask(questId)
	local isParentQuest = QuestUtils.isParentQuest(questId)
	local questGroupId = isParentQuest and questId or QuestUtils.getRootQuestId(questId)
	local assessment = false

	for i, v in pairs(PlayerTitleData) do
		if v.quest == questGroupId then
			assessment = true

			break
		end
	end

	return assessment
end

function QuestModel:getAssessmentTaskReward(questId)
	local isParentQuest = QuestUtils.isParentQuest(questId)
	local questGroupId = isParentQuest and questId or QuestUtils.getRootQuestId(questId)
	local assessStar = 0

	for i, v in pairs(PlayerTitleData) do
		if v.quest == questGroupId then
			assessStar = i + 1

			break
		end
	end

	local cData = PlayerTitleData[assessStar]

	if cData == nil then
		return
	end

	local reward = {}

	reward.assessStar = assessStar

	pg.global.ui.playerLvReward.model:parseStarReward(reward)

	return reward
end

function QuestModel:getCanTrackMainChapterQuestId()
	local chapters = self:getChaptersByType(QuestModel.MainStoryType.Chapter)

	if chapters then
		for i = 1, #chapters do
			local chapter = chapters[i].chapterId
			local sections = QuestMain[chapter]

			if sections == nil then
				return 0
			end

			for k, v in pairs(sections) do
				local questId = v.questGroupId
				local questData = QuestUtils.getQuestData(questId)

				if questData ~= nil and QuestUtils.isQuestDataInState(questData, QuestConst.QUEST_STATE.RECEIVED) and not QuestUtils.isQuestFinished(questId) and not QuestUtils.isAssessmentTask(questId) then
					return questId
				end
			end
		end
	end

	return 0
end

local QUEST_CLUE_SEEN_PREFS_KEY = "quest_clue_seen_ids"
local QUEST_CLUE_BUBBLE_BASELINE_PREFS_KEY = "quest_clue_bubble_baseline_ids"

function QuestModel:loadPrefsIdSet(prefsKey)
	local set = {}
	local raw = pg.global.prefsCacheUtils:getString(prefsKey)

	if raw and raw ~= "" then
		local ok, list = pcall(json.decode, raw)

		if ok and type(list) == "table" then
			for _, id in ipairs(list) do
				if id and id > 0 then
					set[id] = true
				end
			end
		end
	end

	return set
end

function QuestModel:savePrefsIdSet(prefsKey, set)
	local list = {}

	for id, _ in pairs(set) do
		list[#list + 1] = id
	end

	pg.global.prefsCacheUtils:setString(prefsKey, json.encode(list))
end

function QuestModel:loadClueSeenFromPrefs()
	self.clueSeenSet = self:loadPrefsIdSet(QUEST_CLUE_SEEN_PREFS_KEY)
end

function QuestModel:loadClueBubbleBaselineFromPrefs()
	self.clueBubbleBaselineSet = self:loadPrefsIdSet(QUEST_CLUE_BUBBLE_BASELINE_PREFS_KEY)
end

function QuestModel:setClueRedPointState(questId)
	if not questId or questId <= 0 then
		return
	end

	if self.clueSeenSet == nil then
		self:loadClueSeenFromPrefs()
	end

	if self.clueSeenSet[questId] then
		return
	end

	self.clueSeenSet[questId] = true

	self:savePrefsIdSet(QUEST_CLUE_SEEN_PREFS_KEY, self.clueSeenSet)
end

function QuestModel:getClueRedPointState(questId)
	if not questId or questId <= 0 then
		return false
	end

	if not QuestUtils.isClueReveal(questId) then
		return false
	end

	if self.clueSeenSet == nil then
		self:loadClueSeenFromPrefs()
	end

	return not self.clueSeenSet[questId]
end

function QuestModel:redDot_GetClueState()
	if self.clueSeenSet == nil then
		self:loadClueSeenFromPrefs()
	end

	for _, v in pairs(QuestClueCatalogConfig) do
		for j = 1, #v.quests do
			local quest = v.quests[j]

			if quest and quest.questId and QuestUtils.isClueReveal(quest.questId) and QuestUtils.isWorldRumor(quest.questId) and not self.clueSeenSet[quest.questId] then
				return true
			end
		end
	end

	return false
end

function QuestModel:getNewClueCount()
	if self.clueBubbleBaselineSet == nil then
		self:loadClueBubbleBaselineFromPrefs()
	end

	local cnt = 0

	for _, v in pairs(QuestClueCatalogConfig) do
		for j = 1, #v.quests do
			local quest = v.quests[j]

			if quest and quest.questId and QuestUtils.isClueReveal(quest.questId) and QuestUtils.isWorldRumor(quest.questId) and not self.clueBubbleBaselineSet[quest.questId] then
				cnt = cnt + 1
			end
		end
	end

	return cnt
end

function QuestModel:markAllRevealedCluesSeen()
	if self.clueSeenSet == nil then
		self:loadClueSeenFromPrefs()
	end

	local changed = false

	for _, v in pairs(QuestClueCatalogConfig) do
		for j = 1, #v.quests do
			local quest = v.quests[j]

			if quest and quest.questId and QuestUtils.isClueReveal(quest.questId) and QuestUtils.isWorldRumor(quest.questId) and not self.clueSeenSet[quest.questId] then
				self.clueSeenSet[quest.questId] = true
				changed = true
			end
		end
	end

	if changed then
		self:savePrefsIdSet(QUEST_CLUE_SEEN_PREFS_KEY, self.clueSeenSet)
	end
end

function QuestModel:saveClueBubbleBaseline()
	if self.clueBubbleBaselineSet == nil then
		self:loadClueBubbleBaselineFromPrefs()
	end

	for _, v in pairs(QuestClueCatalogConfig) do
		for j = 1, #v.quests do
			local quest = v.quests[j]

			if quest and quest.questId and QuestUtils.isClueReveal(quest.questId) and QuestUtils.isWorldRumor(quest.questId) then
				self.clueBubbleBaselineSet[quest.questId] = true
			end
		end
	end

	self:savePrefsIdSet(QUEST_CLUE_BUBBLE_BASELINE_PREFS_KEY, self.clueBubbleBaselineSet)
end

function QuestModel:getChapterProgressRewardConf(chapterId)
	local configId, config

	for i, v in pairs(QuestChapterProgressRewardData) do
		if chapterId and chapterId == tonumber(v.chapter) then
			configId = i
			config = v

			break
		end
	end

	return configId, config
end

function QuestModel:getChapterProgressRewardInfo(chapterId)
	local configId, config = self:getChapterProgressRewardConf(chapterId)

	if not config or configId == 0 then
		return nil
	end

	local sectionCount = #config.sectionId
	local curFinishCount = 0
	local chapterNameList = {}

	for i = 1, sectionCount do
		local sectionId = config.sectionId[i]
		local questId = QuestUtils.getQuestIdBySectionId(sectionId)
		local chapterId = QuestUtils.getQuestChapterIdBySectionId(sectionId)
		local sectionName = QuestUtils.getQuestSectionName(chapterId, sectionId)
		local isFined = QuestCommonUtils.getQuestState(pg.me, questId) == QuestConst.QUEST_STATE.SUBMITED

		table.insert(chapterNameList, {
			name = sectionName,
			isFined = isFined
		})

		if isFined then
			curFinishCount = curFinishCount + 1
		end
	end

	local curProgress = math.floor(curFinishCount / sectionCount * 100 + 0.5)
	local playerProgress = pg.me.chapterQuestRewardProgress
	local rewardList = {}

	for i = 1, #config.rewardProgress do
		local rewardIndex = i
		local claimed = false

		if playerProgress and playerProgress[configId] then
			claimed = playerProgress[configId][rewardIndex] or false
		end

		local rawId = config.rewardId[i]
		local canClaim = curProgress >= config.rewardProgress[i] and not claimed
		local prevThreshold = i > 1 and config.rewardProgress[i - 1] or 0

		table.insert(rewardList, {
			progressThreshold = config.rewardProgress[i],
			prevThreshold = prevThreshold,
			rewardId = rawId,
			claimed = claimed,
			canClaim = canClaim,
			rewardIndex = rewardIndex
		})
	end

	return {
		configId = configId,
		sectionCount = sectionCount,
		curFinishCount = curFinishCount,
		curProgress = curProgress,
		rewardList = rewardList,
		chapterNameList = chapterNameList
	}
end

function QuestModel:isChapterProgressRewardCanClaim(chapterId)
	local configId, config = self:getChapterProgressRewardConf(chapterId)

	if not config then
		return false
	end

	local sectionCount = #config.sectionId
	local curFinishCount = 0

	for i = 1, sectionCount do
		local sectionId = config.sectionId[i]
		local questId = QuestUtils.getQuestIdBySectionId(sectionId)
		local isFined = QuestCommonUtils.getQuestState(pg.me, questId) == QuestConst.QUEST_STATE.SUBMITED

		if isFined then
			curFinishCount = curFinishCount + 1
		end
	end

	local curProgress = math.floor(curFinishCount / sectionCount * 100 + 0.5)
	local playerProgress = pg.me.chapterQuestRewardProgress

	for i = 1, #config.rewardProgress do
		local rewardIndex = i
		local claimed = false

		if playerProgress and playerProgress[configId] then
			claimed = playerProgress[configId][rewardIndex] or false
		end

		if curProgress >= config.rewardProgress[i] and not claimed then
			return true
		end
	end

	return false
end

function QuestModel:isChapterProgressRewardAllClaimed(chapterId)
	local configId, config = self:getChapterProgressRewardConf(chapterId)

	if not config then
		return true
	end

	local playerProgress = pg.me.chapterQuestRewardProgress

	for i = 1, #config.rewardProgress do
		local rewardIndex = i
		local claimed = false

		if playerProgress and playerProgress[configId] then
			claimed = playerProgress[configId][rewardIndex] or false
		end

		if not claimed then
			return false
		end
	end

	return true
end

function QuestModel:isChapterHasAcceptedSection(chapterId)
	local sections = QuestMain[chapterId] or {}

	for sectionId, v in pairs(sections) do
		if QuestCommonUtils.questAccepted(pg.me, v.questGroupId) then
			return true
		end
	end

	return false
end

function QuestModel:isAnyChapterProgressRewardCanClaimByMainType(mainType)
	for i, v in pairs(QuestCatalogConfig) do
		if v.mainType == mainType then
			for j = 1, #v.chapters do
				local chapterId = v.chapters[j]

				if self:isChapterProgressRewardCanClaim(chapterId) then
					return true
				end
			end
		end
	end

	return false
end

return QuestModel
