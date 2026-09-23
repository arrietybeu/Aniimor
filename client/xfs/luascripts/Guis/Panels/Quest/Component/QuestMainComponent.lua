-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Quest\\Component\\QuestMainComponent.lua

local LuaUIUtils = require("Utils.LuaUIUtils")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local DropData = require("Data.drop_data")
local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local QuestConst = require("Common.Const.QuestConst")
local Utils = require("Common.Utils.Utils")
local UIConst = require("Const.UIConst")
local TimerManager = require("Core.Timer.TimerManager")
local ItemSourceData = require("Data.item_source_data")
local RedDotConst = require("Const.RedDotConst")
local QuestMainComponent = Class.LightClass("QuestMainComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local ANIName = {
	ANI_SECTION_LEFT_IN = "VX_Node_Story_Chapter_LeftIn",
	ANI_SECTION_LEFT_OUT = "VX_Node_Story_Chapter_LeftOut",
	ANI_SECTION_NORMAL_IN = "VX_Node_Story_Chapter_PreviousLine_In",
	ANI_SECTION_RIGHT_IN = "VX_Node_Story_Chapter_RightIn",
	ANI_ATB_IN = "VX_Pb_Quest_HandBook_In",
	ANI_SECTION_RIGHT_OUT = "VX_Node_Story_Chapter_RightOut",
	ANI_PANEL_IN = "VX_Pb_Quest_In",
	ANI_SECTION_NORMAL_LOOP = "VX_Node_Story_Chapter_Loop"
}
local DETAIL_TYPE = {
	SECTION = 2,
	CHAPTER = 1,
	CLUE_TIP = 4,
	CLUE = 3
}

QuestMainComponent.BG_NORAML_EMPTY = "$UI_Img_Quest_BgImage.png"
QuestMainComponent.BG_CLUE_EMPTY = "$UI_Img_Quest_ClueBgImage.png"

function QuestMainComponent:ctor(ctrl)
	UIComponent.ctor(self, ctrl)
	self.view:initMainStoryPanel()
	self:addListener()
	self:init()
end

function QuestMainComponent:init()
	return
end

function QuestMainComponent:onInputDeviceChanged(deviceType)
	return
end

function QuestMainComponent:addListener()
	function self.view.chapterTypeList.luaRenderItem(button, index, data)
		self:onRenderChapterTypeItem(button, index, data)
	end

	function self.view.taskObjectiveList.luaRenderItem(button, index, data)
		self:onRenderQuestObjectiveItem(button, index, data)
	end

	function self.view.rewardList.luaRenderItem(rewardBtn, index, subData)
		LuaUIUtils.renderRewards(rewardBtn, index, subData)
	end

	function self.view.skillRewardList.luaRenderItem(button, _, data)
		self:onRenderRewardSkillItem(button, data)
	end

	function self.view.skillPointRewardList.luaRenderItem(button, _, data)
		self:onRenderRewardSkillPointItem(button, data)
	end

	function self.view.trackingBtn.luaClick()
		self:traceQuestByType(true)
	end

	function self.view.untrackingBtn.luaClick()
		self:traceQuestByType(false)
	end

	function self.view.sourceBtn.luaClick()
		self:onclickSourceBtn()
	end

	function self.view.filterBtn.luaClick()
		self:onclickFilterBtn()
	end

	function self.view.filterDeleteBtn.luaClick()
		self:onclickFilterDeleteBtn()
	end

	function self.view.btnAlreadyTrackingUButton.luaClick()
		self:traceQuestByType(true, true)
		self.ctrl:dismiss()
	end

	function self.view.adventureGotoClueBtn.luaClick()
		self:onclickAdventureGotoClue()
	end

	function self.view.clueBtnFoldUpUButton.luaClick()
		self:onclickClueFoldUp()
	end
end

function QuestMainComponent:onQuestTraceChange(data)
	local questId = 0

	if data.questId then
		questId = data.questId
	elseif data ~= nil and data.questData ~= nil then
		questId = data.questData.configId
	end

	if self.curQuestId ~= nil and self.curQuestId == questId then
		self:refreshTracingState(self.curQuestId)
	end

	for i = 1, #self.chacheItemList do
		local cacheItemData = self.chacheItemList[i]

		if cacheItemData.questId == questId then
			if cacheItemData.isClue then
				self:onRenderClueItem(cacheItemData.btn, cacheItemData.index, cacheItemData.data)
			else
				self:onRenderSectionItem(cacheItemData.btn, cacheItemData.index, cacheItemData.data)
			end
		end
	end
end

function QuestMainComponent:onVisibleChange(visible)
	if visible and self.view and self.chacheItemList then
		for i = 1, #self.chacheItemList do
			local cacheItemData = self.chacheItemList[i]

			if cacheItemData and cacheItemData.isClue then
				self:onRenderClueItem(cacheItemData.btn, cacheItemData.index, cacheItemData.data)

				if self.curQuestId and self.curQuestId > 0 and self.curQuestId == cacheItemData.questId then
					self:refreshTracingState(self.curQuestId)
				end
			end
		end

		self:refreshSourceBtn()
	end
end

function QuestMainComponent:onShow(mainType, selectQuestId)
	self.chacheItemList = {}
	self.curChapterType = nil
	self.curChapterData = nil
	self.curSectionData = nil
	self.curQuestId = nil
	self.curDetailType = nil
	self.curSubQuestId = nil
	self.curSourceId = nil
	self.isGotoClueClicked = false
	self.mainType = mainType

	if self.autoSelectChapterTimer then
		self:killTimer(self.autoSelectChapterTimer)

		self.autoSelectChapterTimer = nil
	end

	self.view.mainPanel:TryChangePage("Type", 0)
	self.view.mainPanel:TryChangePage("TaskManual", mainType - 1)

	self.allSubTypes, self.selectInfo = self.model:getAllChapterTypes(mainType, selectQuestId)
	self.autoSelectEmptyChapterId = self.selectInfo ~= nil and self.selectInfo.sectionId == nil and self.selectInfo.chapterId or nil

	local hasSubTypes = #self.allSubTypes > 0

	if hasSubTypes then
		local selectIndex = self.selectInfo and self.selectInfo.index or nil

		self.view.chapterTypeList:SetList(self.allSubTypes)

		if selectIndex ~= nil then
			TimerManager.addSpecificFrameCb(2, false, function()
				if self.view then
					self.view.chapterTypeList:GoToIndex(selectIndex, true)
				end
			end)
		end
	end

	if mainType == QuestConst.MainType.Adventure or mainType == QuestConst.MainType.Clue then
		local ret, intro = self.model:getMapAreaFilterIntro()

		if ret then
			ClientTextUtils.setText(self.view.filterBtnTxt, intro)
		else
			ClientTextUtils.setText(self.view.filterBtnTxt, "")
		end

		self.view.filterBtn:TryChangePage("FiltrateState", ret and 1 or 0)

		if hasSubTypes then
			self.view.mainPanel:TryChangePage("Empty", 0)
		else
			self.view.mainPanel:TryChangePage("Empty", ret and 2 or 1)
		end
	else
		self.view.mainPanel:TryChangePage("Empty", hasSubTypes and 0 or 1)
	end

	if hasSubTypes then
		self.view.rootAni:Play(ANIName.ANI_PANEL_IN)
	else
		self.view.mainPanel:TryChangePage("Forbid", 0)
		self.view.clueBtnUWidget:SetActive(false)
		LuaUIUtils.setUIViewVisible(self.view.clueCountdownUWidget, false)

		local imagePanel = mainType == QuestConst.MainType.Clue and QuestMainComponent.BG_CLUE_EMPTY or QuestMainComponent.BG_NORAML_EMPTY

		self.view.mainBg:SetUrlWithCallback(imagePanel, nil)
	end
end

function QuestMainComponent:onRenderChapterTypeItem(btn, index, data)
	local itemComs

	if data.tIndex == 1 then
		local objectReference = btn:GetComponent("ObjectReference")
		local titleTxt = objectReference:GetRefValue("titleTxt")

		ClientTextUtils.setTextWithId(titleTxt, data.chapterTypeName)

		if data.questId and data.questId > 0 then
			local taskType = QuestUtils.getCurSideQuestShowType(data.questId)

			btn:TryChangePage("TaskType", taskType.taskType)
		end

		return
	elseif data.tIndex == 2 then
		if data.quest then
			self:onRenderClueItem(btn, index, data)
		else
			self:onRenderSectionItem(btn, index, data)
		end

		return
	end

	itemComs = self.view:getChapterTabItem(btn)

	function btn.luaClick(playAni)
		if btn.isSelected then
			return
		end

		if self.curSectionBtn ~= nil then
			self.curSectionBtn.isSelected = false
			self.curSectionBtn = nil
		end

		btn.isSelected = true
		self.curChapterBtn = btn

		self:onClickChapterItem(data)
	end

	if data.sections and #data.sections == 0 and self.autoSelectEmptyChapterId ~= nil and self.autoSelectEmptyChapterId == data.chapterId then
		self.autoSelectEmptyChapterId = nil
		self.autoSelectChapterTimer = self:startTimer(function()
			self.autoSelectChapterTimer = nil

			btn.luaClick()
		end, 0.1)
	end

	local chapterData = self.model:getChapterInfo(data.chapterId)

	ClientTextUtils.setTextWithId(itemComs.tabNameTxt, chapterData.chapterName)

	function itemComs.tabList.luaRenderItem(button, subIndex, subData)
		self:onRenderSectionItem(button, subIndex, subData)
	end

	itemComs.tabList:SetList(data.sections)

	local questId = QuestUtils.getFirstSectionQuestIdByChapterId(data.chapterId)

	if questId and questId > 0 then
		local taskType = QuestUtils.getCurSideQuestShowType(questId)

		btn:TryChangePage("TaskType", taskType.taskType)
	end

	btn:TryChangePage("ChapterType", data.chapterType)

	btn.name = tostring(data.chapterType)

	local chapterId = data.chapterId
	local treePath = string.format(RedDotConst.RedDotPath.QUEST_CHAPTER_REWARD_ITEM, self.mainType, chapterId)

	pg.global.setPreViewRedDot(treePath, btn, function()
		if self.model:isChapterProgressRewardCanClaim(chapterId) then
			return RedDotConst.RedDotStyle.REWARD
		else
			return RedDotConst.RedDotStyle.NONE
		end
	end)
end

function QuestMainComponent:playAllItemInAni(tabList, chapterType)
	local btns = tabList:GetAllButtons()
	local ani, aniInfo

	for i = 0, btns.Length - 1 do
		local btn = btns[i]

		if chapterType == self.model.MainStoryType.Chapter then
			local itemComs = self.view:getMainQuestChapterItemComs(btn)

			ani = itemComs.ani
			aniInfo = self.model.VXAniName.Chapter_Story_Item_In
		else
			local itemComs = self.view:getMainQuestReginalAniItemComs(btn)

			ani = itemComs.ani
			aniInfo = self.model.VXAniName.Chapter_Area_Item_In
		end

		self:playItemInAni(i, btn, ani, aniInfo)
	end
end

function QuestMainComponent:playItemInAni(index, btn, ani, aniInfo, skipAni)
	index = index or 0

	if skipAni then
		LuaUIUtils.setUIViewVisible(btn, true)

		return
	end

	LuaUIUtils.setUIViewVisible(btn, false)
	self:startTimer(function()
		LuaUIUtils.setUIViewVisible(btn, true)
		ani:Play(aniInfo[1])
	end, index * aniInfo[2] + 0.1)
end

function QuestMainComponent:refreshChapterTypeTracingState(btn, chapterType)
	if btn.isSelected then
		btn:TryChangePage("Track", 0)
	else
		local isTracing = self.model:isMainChapterTypeTracing(chapterType)

		btn:TryChangePage("Track", isTracing and 1 or 0)
	end
end

function QuestMainComponent:onRenderSectionItem(btn, index, data)
	local itemComs = self.view:getMainQuestChapterItemComs(btn)
	local sectionConfig = self.model:getSectionInfo(data.chapterId, data.sectionId)
	local questId = sectionConfig.questGroupId
	local sectionDisplayName = sectionConfig.sectionName
	local isUnReceive = false

	if self.mainType == QuestConst.MainType.Adventure then
		local isReceive = QuestUtils.getQuestState(questId) == QuestConst.QUEST_STATE.RECEIVED

		if not isReceive then
			ClientTextUtils.setTextWithId(itemComs.clueTxt, sectionDisplayName)

			isUnReceive = true
		end
	end

	if not isUnReceive then
		ClientTextUtils.setTextWithId(itemComs.nameTxt, sectionDisplayName)
	end

	itemComs.closeTag:SetActive(false)

	if QuestUtils.hasCloseCondTimeToken(questId) then
		itemComs.closeTag:SetActive(true)
		ClientTextUtils.setText(itemComs.closeTagText, pg.getGameString("QUEST_TIME_TOKEN_TIME_LIMITED"))
	end

	local location = self.model:getSectionLocation(data.chapterId, data.sectionId)

	btn:TryChangePage("Clue", location ~= nil and 0 or 1)

	if location ~= nil then
		if not isUnReceive then
			ClientTextUtils.setTextWithId(itemComs.locationTxt, location.areaName)
		else
			ClientTextUtils.setText(itemComs.locationTxt, "")
			btn:TryChangePage("Clue", 1)
		end
	else
		ClientTextUtils.setTextWithId(itemComs.clueTxt, sectionConfig.sectionName)
	end

	local isTracing = QuestUtils.isQuestTracing(questId) or QuestUtils.isRootQuestTracing(questId)
	local isQuitHomeland = QuestUtils.needQuitOtherHomeland(questId)
	local forbid = QuestUtils.needQuitTeam(questId) or isQuitHomeland or QuestUtils.isQuestGroupForbidByBlacklist(questId) or QuestUtils.hasRunCondTimeToken(questId)

	btn:TryChangePage("Track", isTracing and not forbid and 1 or 0)
	btn:TryChangePage("Forbid", forbid and 1 or 0)

	if questId > 0 and isTracing and not forbid then
		local taskType = QuestUtils.getCurSideQuestShowType(questId)

		btn:TryChangePage("QuestIcon", taskType.taskType)
	end

	self:setForbidTipsText(questId, forbid)

	local isNew = self.model:isMainChapterHasNewQuset(data.chapterId, true)

	btn:ShowRedDot(isNew)

	function btn.luaClick(playAni)
		if btn.isSelected then
			return
		end

		if self.curChapterBtn ~= nil then
			self.curChapterBtn.isSelected = false
			self.curChapterBtn = nil
		end

		if self.curSectionBtn ~= nil then
			self.curSectionBtn.isSelected = false
			self.curSectionBtn = nil
		end

		self:onClickSectionItem(data)

		btn.isSelected = true
		self.curSectionBtn = btn

		self.model:recordMainSelectInfo(data.chapterType, data.chapterId)
	end

	if self.selectInfo ~= nil and self.selectInfo.chapterId == data.chapterId and (self.selectInfo.sectionId == nil or self.selectInfo.sectionId == data.sectionId) then
		self.selectInfo = nil

		btn.luaClick()
	end

	local chacheItemData = {
		btn = btn,
		index = index,
		data = data,
		questId = questId
	}

	table.insert(self.chacheItemList, chacheItemData)

	if questId and questId > 0 then
		local taskType = QuestUtils.getCurSideQuestShowType(questId)

		btn:TryChangePage("TaskType", taskType.taskType)
	end

	btn.name = tostring(data.sectionId)
end

function QuestMainComponent:onRenderClueItem(btn, index, data)
	local itemComs = self.view:getMainQuestChapterItemComs(btn)
	local questId = data.quest.questId
	local questConfig = QuestUtils.getQuestConfig(questId)

	if questConfig == nil then
		return
	end

	ClientTextUtils.setTextWithId(itemComs.nameTxt, questConfig.name)
	itemComs.closeTag:SetActive(false)

	if QuestUtils.hasCloseCondTimeToken(questId) then
		itemComs.closeTag:SetActive(true)
		ClientTextUtils.setText(itemComs.closeTagText, pg.getGameString("QUEST_TIME_TOKEN_TIME_LIMITED"))
	end

	local location = self.model:getClueLocation(questId)

	btn:TryChangePage("Clue", location ~= nil and 0 or 1)

	if location ~= nil then
		ClientTextUtils.setTextWithId(itemComs.locationTxt, location.areaName)
	else
		ClientTextUtils.setTextWithId(itemComs.clueTxt, questConfig.name)
	end

	local isTracing = pg.game.map:checkTrackMarkExists(questId)
	local isQuitHomeland = QuestUtils.needQuitOtherHomeland(questId)
	local forbid = QuestUtils.needQuitTeam(questId) or isQuitHomeland or QuestUtils.isQuestGroupForbidByBlacklist(questId) or QuestUtils.hasRunCondTimeToken(questId)

	btn:TryChangePage("Track", isTracing and not forbid and 1 or 0)
	btn:TryChangePage("Forbid", forbid and 1 or 0)
	self:setForbidTipsText(questId, forbid)

	if questId and questId > 0 then
		local taskType = QuestUtils.getCurSideQuestShowType(questId)

		btn:TryChangePage("TaskType", taskType.taskType)
	else
		btn:TryChangePage("TaskType", 1)
	end

	if questId > 0 and isTracing and not forbid then
		local taskType = QuestUtils.getCurSideQuestShowType(questId)

		btn:TryChangePage("QuestIcon", taskType.taskType)
	end

	function btn.luaClick(playAni)
		if btn.isSelected then
			return
		end

		btn.isSelected = true

		self.model:setClueRedPointState(questId)

		local cluePath = string.format(RedDotConst.RedDotPath.QUEST_CLUE_TAB_ITEM, questId)

		pg.global.setRedDot(cluePath, btn, false, RedDotConst.RedDotStyle.NEW)
		self:onRefreshCluePanel(index, data)
	end

	local cluePath = string.format(RedDotConst.RedDotPath.QUEST_CLUE_TAB_ITEM, questId)

	pg.global.setRedDot(cluePath, btn, self.model:getClueRedPointState(questId), RedDotConst.RedDotStyle.NEW)

	if self.selectInfo ~= nil and self.selectInfo.questId == questId then
		self.selectInfo = nil

		btn.luaClick()
	end

	local chacheItemData = {
		isClue = true,
		btn = btn,
		index = index,
		data = data,
		questId = questId
	}

	table.insert(self.chacheItemList, chacheItemData)

	btn.name = string.format("%d-%d", questId, questConfig.groupId or 0)
end

function QuestMainComponent:onClickChapterItem(data)
	self.curDetailType = DETAIL_TYPE.CHAPTER

	self.view.mainPanel:TryChangePage("Type", 1)
	self.view.mainPanel:TryChangePage("Select", 1)

	self.curChapterData = data

	local chapterData = self.model:getChapterInfo(data.chapterId)

	ClientTextUtils.setTextWithId(self.view.chapterTextUSDFText, chapterData.chapterName)
	ClientTextUtils.setTextWithId(self.view.titleInfoUSDFText, "")
	ClientTextUtils.setTextWithId(self.view.taskUSDFText, chapterData.chapterDesc)
	self.view.mainPanel:TryChangePage("Clue", 1)

	if chapterData.imagePanel then
		self.view.mainBg:SetUrlWithCallback(chapterData.imagePanel, nil)
	end

	self:refreshChapterProgressReward(data.chapterId)
	self.view.clueBtnUWidget:SetActive(false)
	LuaUIUtils.setUIViewVisible(self.view.clueCountdownUWidget, false)
	self.view.mainPanel:TryChangePage("Forbid", 0)
end

function QuestMainComponent:onClickSectionItem(data)
	self.lastSectionData = data
	self.curDetailType = DETAIL_TYPE.SECTION
	self.isGotoClueClicked = false

	local sectionConfig = self.model:getSectionInfo(data.chapterId, data.sectionId)

	self.curQuestId = sectionConfig.questGroupId

	local isUnReceive = false

	if self.mainType == QuestConst.MainType.Adventure then
		local isReceive = QuestUtils.getQuestState(self.curQuestId) == QuestConst.QUEST_STATE.RECEIVED

		if not isReceive then
			isUnReceive = true
		end
	end

	local isClueQuest = QuestUtils.isQuestOfClueQuestType(sectionConfig.gotoClueQuestId)

	if not isUnReceive or not isClueQuest then
		self.view.mainBg:SetUrlWithCallback(sectionConfig.imagePanel, nil)
	end

	if isUnReceive then
		if isClueQuest then
			local chapterQuestId = self.curQuestId

			self:onClueTipPanel(true, sectionConfig.gotoClueQuestId)
			self:refreshCloseQuestTip(chapterQuestId)
			self.view.mainBg:SetUrlWithCallback(sectionConfig.imagePanel, function()
				if self.view.clueUWidget then
					self.view.clueUWidget:SetActive(false)
					self.view.clueUWidget:SetActive(true)
				end
			end)
		else
			self.view.mainPanel:TryChangePage("Type", 0)
			self.view.mainPanel:TryChangePage("Select", 0)
			self:refreshCloseQuestTip(self.curQuestId)
			ClientTextUtils.setTextWithId(self.view.chapterTxt, sectionConfig.sectionName)
			ClientTextUtils.setText(self.view.questDescTxt, pg.getGameString("QUEST_SECTION_UNRECEIVE_TIP"))
			ClientTextUtils.setText(self.view.titleTxt, "")
			self.view.mainPanel:TryChangePage("HasReward", 1)
			self.view.mainPanel:TryChangePage("Clue", 1)
			self.view.taskObjectiveList:SetList({})
			self:refreshAdventureGotoClueBtn(data)
			self.view.mainPanel:TryChangePage("Tracking", 4)
			self.view.targetUWidget:SetActive(false)
			self.view.mainPanel:TryChangePage("SourceState", 0)
		end

		if self.curQuestId > 0 then
			local taskType = QuestUtils.getCurSideQuestShowType(self.curQuestId)

			self.view.mainPanel:TryChangePage("TaskType", taskType.taskType)
		end

		return
	end

	self.view.mainPanel:TryChangePage("Type", 0)
	self.view.mainPanel:TryChangePage("Select", 0)
	self.view.targetUWidget:SetActive(true)

	if self.view.targetUSDFText then
		ClientTextUtils.setText(self.view.targetUSDFText, pg.getGameString("QUEST_CLUE_TITLE_TEXT"))
	end

	local questConfig = QuestUtils.getQuestConfig(self.curQuestId)

	ClientTextUtils.setTextWithId(self.view.chapterTxt, sectionConfig.sectionName)

	local location = self.model:getSectionLocation(data.chapterId, data.sectionId)

	self.view.mainPanel:TryChangePage("Clue", location ~= nil and 0 or 1)

	if location ~= nil then
		ClientTextUtils.setTextWithId(self.view.questLocationTxt, location.areaName)
	end

	ClientTextUtils.setTextWithId(self.view.questDescTxt, sectionConfig.startDesc)

	local isFined = QuestUtils.isQuestFinished(self.curQuestId)

	self.view.targetUWidget:SetActive(true)
	ClientTextUtils.setText(self.view.targetUSDFText, pg.getGameString("QUEST_QUEST_TITLE_TEXT"))

	local ojectives, firstUnfinishedIndex = QuestUtils.getReceivedQuestObjectives(self.curQuestId)

	self.view.taskObjectiveList:SetList(ojectives)

	if firstUnfinishedIndex ~= nil then
		self.view.taskObjectiveList:GoToIndex(firstUnfinishedIndex - 1)
	end

	local desc = questConfig.desc

	if desc == nil and #ojectives ~= 0 then
		local subQuestConfig = QuestUtils.getQuestConfig(ojectives[1].questId)

		desc = subQuestConfig.desc
	end

	if desc ~= nil then
		ClientTextUtils.setTextWithId(self.view.titleTxt, desc)
	else
		ClientTextUtils.setTextWithId(self.view.titleTxt, "")
	end

	local isAssessmentTask = QuestUtils.isAssessmentTask(self.curQuestId)

	self.view.rewardList:SetActive(not isAssessmentTask)
	self.view.examineListUWidget:SetActive(isAssessmentTask)

	if isAssessmentTask then
		local rewardList = self.model:getAssessmentTaskReward(self.curQuestId)

		self.view.skillRewardList:SetList(rewardList.skReward)
		self.view.skillPointRewardList:SetList(rewardList.propReward)
		self.view.mainPanel:TryChangePage("HasReward", (#rewardList.skReward > 0 or #rewardList.propReward > 0) and 0 or 1)
	else
		local questConfig = QuestUtils.getQuestConfig(self.curQuestId)
		local rewardId = questConfig.rewardId
		local rewardItems = LuaUIUtils.getRewardItemByDropId(rewardId)

		rewardItems = rewardItems ~= nil and rewardItems or {}

		if isFined then
			for i = 1, #rewardItems do
				local rewardItem = rewardItems[i]

				rewardItem.hasGet = true
			end
		end

		self.view.rewardList:SetList(rewardItems)
		self.view.mainPanel:TryChangePage("HasReward", #rewardItems > 0 and 0 or 1)
	end

	local isQuitHomeland = QuestUtils.needQuitOtherHomeland(self.curQuestId)
	local forbid = QuestUtils.needQuitTeam(self.curQuestId) or isQuitHomeland or QuestUtils.isQuestGroupForbidByBlacklist(self.curQuestId, ojectives) or QuestUtils.hasRunCondTimeToken(self.curQuestId, ojectives)

	if not forbid then
		self.curSubQuestId = ojectives ~= nil and #ojectives > 0 and ojectives[1].questId or nil
		self.curSourceId = nil

		local isShowSourceBtn, sourceId = QuestUtils.canTraceItemSource(self.curSubQuestId)

		isShowSourceBtn = isShowSourceBtn and not isUnReceive
		isShowSourceBtn = QuestUtils.filterSourceType(isShowSourceBtn, sourceId)

		self.view.mainPanel:TryChangePage("SourceState", isShowSourceBtn and 1 or 0)

		if isShowSourceBtn then
			local sourceConfig = ItemSourceData[sourceId]

			if sourceConfig then
				ClientTextUtils.setTextWithId(self.view.sourceBtnTxt, sourceConfig.buttonTxt)
			end
		end
	else
		self.curSubQuestId = nil
		self.curSourceId = nil
	end

	self.view.mainPanel:TryChangePage("Forbid", forbid and 1 or 0)
	self:refreshTracingState(self.curQuestId, forbid)
	self.view.rootAni:Play(ANIName.ANI_ATB_IN)

	if self.curQuestId > 0 then
		local taskType = QuestUtils.getCurSideQuestShowType(self.curQuestId)

		self.view.mainPanel:TryChangePage("TaskType", taskType.taskType)
	end

	self:refreshCloseQuestTip(self.curQuestId)
	self:refreshAdventureGotoClueBtn(data, ojectives)
end

function QuestMainComponent:refreshAdventureGotoClueBtn(data, ojectives)
	local sectionConfig = self.model:getSectionInfo(data.chapterId, data.sectionId)
	local questId = sectionConfig.questGroupId
	local showGotoClue = false
	local isShowSourceBtn, sourceId

	if self.mainType == QuestConst.MainType.Adventure then
		local objcvData = QuestUtils.getFirstObjectiveData(questId, ojectives)

		if objcvData and objcvData.questId then
			isShowSourceBtn, sourceId = QuestUtils.canTraceItemSource(objcvData.questId)

			if isShowSourceBtn then
				local sourceConfig = ItemSourceData[sourceId]

				if sourceConfig and sourceConfig.type == 8 and Utils.isTable(sourceConfig.param) and sourceConfig.param[1] and sourceConfig.param[1] > 0 and QuestUtils.isTrackingGroupId(sourceConfig.param[1]) then
					showGotoClue = true
				end
			end
		end

		if showGotoClue and sourceId ~= nil then
			self.view.clueBtnUWidget:SetActive(true)

			local matchedEntry = QuestUtils.getClueSeekActiveTrackingEntry(sourceId)
			local questId = QuestUtils.getTrackingGroupEntryQuestId(matchedEntry)

			if questId then
				self.adventureGotoClueQuestId = questId

				local taskType = QuestUtils.getCurSideQuestShowType(questId)
				local taskTypeStyle = taskType.taskType

				if QuestUtils.isQuestOfClueQuestType(questId) then
					taskTypeStyle = 1
				end

				self.view.adventureGotoClueBtn:TryChangePage("TaskType", taskTypeStyle)
			end

			self.view.adventureGotoClueBtn:TryChangePage("IconType", 0)

			local textTip = QuestUtils.getTrackingGroupEntryDisplayName(matchedEntry)

			self:startTimer(function()
				local objOR = self.view.adventureGotoClueBtn:GetComponent("ObjectReference")
				local text = objOR:GetRefValue("textUSDFText")

				ClientTextUtils.setText(text, textTip)
			end, 0.03)

			showGotoClue = true
		end
	end

	self.view.clueBtnUWidget:SetActive(showGotoClue)
end

function QuestMainComponent:refreshCloseQuestTip(questId)
	if QuestUtils.hasCloseCondTimeToken(questId) then
		local _, closeText = QuestUtils.getCloseCondTimeTokenInfo(questId)
		local objOR = self.view.closeQuestTipBtn:GetComponent("ObjectReference")
		local text = objOR:GetRefValue("textUSDFText")

		ClientTextUtils.setText(text, closeText)
		self.view.closeQuestTipBtn:TryChangePage("IconType", 1)
		LuaUIUtils.setUIViewVisible(self.view.clueCountdownUWidget, true)
		self.view.clueCountdownUWidget:SetActive(true)
	else
		LuaUIUtils.setUIViewVisible(self.view.clueCountdownUWidget, false)
	end
end

function QuestMainComponent:onClueTipPanel(hindBtn, gotoClueQuestId)
	self.curDetailType = DETAIL_TYPE.CLUE_TIP

	self.view.mainPanel:TryChangePage("Type", 2)
	self.view.mainPanel:TryChangePage("Select", 0)
	LuaUIUtils.setUIViewVisible(self.view.nextBtn, false)
	LuaUIUtils.setUIViewVisible(self.view.preBtn, false)
	self.view.clueBtnUWidget:SetActive(false)
	self.view.blurStaticUWidget:SetActive(false)
	LuaUIUtils.setUIViewVisible(self.view.clueCountdownUWidget, false)

	local curQuestId = self.adventureGotoClueQuestId

	if hindBtn and gotoClueQuestId then
		self.isGotoClueClicked = true
		self.adventureGotoClueQuestId = gotoClueQuestId
		curQuestId = gotoClueQuestId
	end

	local questConfig = QuestUtils.getQuestConfig(curQuestId)

	ClientTextUtils.setTextWithId(self.view.clueChapterText, questConfig.name)

	if questConfig.shortDesc ~= nil then
		ClientTextUtils.setTextWithId(self.view.clueTitleInfoText, questConfig.shortDesc)
	else
		ClientTextUtils.setTextWithId(self.view.clueTitleInfoText, "")
	end

	local location = self.model:getClueLocation(curQuestId)

	self.view.mainPanel:TryChangePage("Clue", location ~= nil and 0 or 1)

	if location ~= nil then
		ClientTextUtils.setTextWithId(self.view.clueLocationInfoText, location.areaName)
	end

	ClientTextUtils.setTextWithId(self.view.clueTaskText, questConfig.fullDesc)
	ClientTextUtils.setText(self.view.clueTargetUSDFText, pg.getGameString("QUEST_CLUE_TITLE_TEXT"))

	local isFined = QuestUtils.isQuestFinished(curQuestId)

	if self.view.clueTargetUList then
		function self.view.clueTargetUList.luaRenderItem(button, subIndex, subData)
			self:onRenderQuestObjectiveItem(button, subIndex, subData)
		end
	end

	local ojectives, firstUnfinishedIndex = QuestUtils.getReceivedQuestObjectives(curQuestId, true)

	self.skipObjectiveItemAni = true

	self.view.clueTargetUList:SetList(ojectives)
	self:startTimer(function()
		self.skipObjectiveItemAni = nil
	end, 0.1)

	local isAssessmentTask = QuestUtils.isAssessmentTask(curQuestId)

	self.view.rewardList:SetActive(not isAssessmentTask)
	self.view.examineListUWidget:SetActive(isAssessmentTask)

	if isAssessmentTask then
		local rewardList = self.model:getAssessmentTaskReward(curQuestId)

		self.view.skillRewardList:SetList(rewardList.skReward)
		self.view.skillPointRewardList:SetList(rewardList.propReward)
		self.view.mainPanel:TryChangePage("HasReward", (#rewardList.skReward > 0 or #rewardList.propReward > 0) and 0 or 1)
	else
		local rewardId = questConfig.rewardId
		local rewardItems = LuaUIUtils.getRewardItemByDropId(rewardId)

		rewardItems = rewardItems ~= nil and rewardItems or {}

		if isFined then
			for i = 1, #rewardItems do
				local rewardItem = rewardItems[i]

				rewardItem.hasGet = true
			end
		end

		self.view.rewardList:SetList(rewardItems)
		self.view.mainPanel:TryChangePage("HasReward", #rewardItems > 0 and 0 or 1)
	end

	self.view.mainPanel:TryChangePage("SourceState", 0)

	local isQuitHomeland = QuestUtils.needQuitOtherHomeland(curQuestId)
	local forbid = QuestUtils.needQuitTeam(curQuestId) or isQuitHomeland or QuestUtils.isQuestGroupForbidByBlacklist(curQuestId, ojectives) or QuestUtils.hasRunCondTimeToken(curQuestId)

	if not forbid then
		for i = 1, #ojectives do
			local objcvData = ojectives[i]

			if objcvData and objcvData.questId then
				local isShowSourceBtn, sourceId = QuestUtils.canTraceItemSource(objcvData.questId)
				local isShowPathFlag = QuestUtils.canQuestObjShowArrowFlag(objcvData.questId)

				if isShowSourceBtn then
					self.view.mainPanel:TryChangePage("SourceState", isShowSourceBtn and 1 or 0)

					local sourceConfig = ItemSourceData[sourceId]

					if sourceConfig then
						ClientTextUtils.setText(self.view.sourceBtnTxt, pg.getLocalizationText(sourceConfig.buttonTxt))
					end

					self.curSubQuestId = objcvData.questId
					self.curSourceId = sourceId

					break
				end
			end
		end
	end

	self.view.mainPanel:TryChangePage("Forbid", forbid and 1 or 0)
	self:setForbidTipsText(curQuestId, forbid, ojectives)
	self:refreshTracingState(curQuestId, forbid)
	self.view.rootAni:Play(ANIName.ANI_ATB_IN)
	self.view.clueBtnUWidget:SetActive(false)
	LuaUIUtils.setUIViewVisible(self.view.clueBtnFoldUpUButton, not hindBtn)
end

function QuestMainComponent:onRefreshCluePanel(index, data)
	self.curDetailType = DETAIL_TYPE.CLUE
	self.isGotoClueClicked = false

	self.view.mainPanel:TryChangePage("Type", 0)
	self.view.mainPanel:TryChangePage("Select", 0)
	LuaUIUtils.setUIViewVisible(self.view.nextBtn, false)
	LuaUIUtils.setUIViewVisible(self.view.preBtn, false)
	self.view.clueBtnUWidget:SetActive(false)
	LuaUIUtils.setUIViewVisible(self.view.clueCountdownUWidget, false)

	self.curQuestId = data.quest.questId

	local questConfig = QuestUtils.getQuestConfig(self.curQuestId)

	ClientTextUtils.setTextWithId(self.view.chapterTxt, questConfig.name)

	if questConfig.shortDesc ~= nil then
		ClientTextUtils.setTextWithId(self.view.titleTxt, questConfig.shortDesc)
	else
		ClientTextUtils.setTextWithId(self.view.titleTxt, "")
	end

	local location = self.model:getClueLocation(self.curQuestId)

	self.view.mainPanel:TryChangePage("Clue", location ~= nil and 0 or 1)

	if location ~= nil then
		ClientTextUtils.setTextWithId(self.view.questLocationTxt, location.areaName)
	end

	ClientTextUtils.setTextWithId(self.view.questDescTxt, questConfig.fullDesc)

	local isFined = QuestUtils.isQuestFinished(self.curQuestId)

	self.view.targetUWidget:SetActive(true)
	ClientTextUtils.setText(self.view.targetUSDFText, pg.getGameString("QUEST_CLUE_TITLE_TEXT"))

	local ojectives, firstUnfinishedIndex = QuestUtils.getReceivedQuestObjectives(self.curQuestId)

	self.view.taskObjectiveList:SetList(ojectives)

	if firstUnfinishedIndex ~= nil then
		self.view.taskObjectiveList:GoToIndex(firstUnfinishedIndex - 1)
	end

	local isAssessmentTask = QuestUtils.isAssessmentTask(self.curQuestId)

	self.view.rewardList:SetActive(not isAssessmentTask)
	self.view.examineListUWidget:SetActive(isAssessmentTask)

	if isAssessmentTask then
		local rewardList = self.model:getAssessmentTaskReward(self.curQuestId)

		self.view.skillRewardList:SetList(rewardList.skReward)
		self.view.skillPointRewardList:SetList(rewardList.propReward)
		self.view.mainPanel:TryChangePage("HasReward", (#rewardList.skReward > 0 or #rewardList.propReward > 0) and 0 or 1)
	else
		local rewardId = questConfig.rewardId
		local rewardItems = LuaUIUtils.getRewardItemByDropId(rewardId)

		rewardItems = rewardItems ~= nil and rewardItems or {}

		if isFined then
			for i = 1, #rewardItems do
				local rewardItem = rewardItems[i]

				rewardItem.hasGet = true
			end
		end

		self.view.rewardList:SetList(rewardItems)
		self.view.mainPanel:TryChangePage("HasReward", #rewardItems > 0 and 0 or 1)
	end

	local clueCatalog = self.model:getClueCatalogConfig(questConfig.listId)

	self.view.mainBg:SetUrlWithCallback(clueCatalog.imagePanel, nil)

	local isQuitHomeland = QuestUtils.needQuitOtherHomeland(self.curQuestId)
	local forbid = QuestUtils.needQuitTeam(self.curQuestId) or isQuitHomeland or QuestUtils.isQuestGroupForbidByBlacklist(self.curQuestId, ojectives) or QuestUtils.hasRunCondTimeToken(self.curQuestId, ojectives)

	if not forbid then
		self.curSubQuestId = ojectives ~= nil and #ojectives > 0 and ojectives[1].questId or nil
		self.curSourceId = nil

		local isShowSourceBtn, sourceId = QuestUtils.canTraceItemSource(self.curSubQuestId)

		self.view.mainPanel:TryChangePage("SourceState", isShowSourceBtn and 1 or 0)

		if isShowSourceBtn then
			local sourceConfig = ItemSourceData[sourceId]

			if sourceConfig then
				ClientTextUtils.setTextWithId(self.view.sourceBtnTxt, sourceConfig.buttonTxt)
			end
		end
	end

	self.view.mainPanel:TryChangePage("Forbid", forbid and 1 or 0)
	self:setForbidTipsText(self.curQuestId, forbid, ojectives)
	self:refreshTracingState(self.curQuestId, forbid)
	self.view.rootAni:Play(ANIName.ANI_ATB_IN)

	if self.curQuestId > 0 then
		local taskType = QuestUtils.getCurSideQuestShowType(self.curQuestId)

		self.view.mainPanel:TryChangePage("TaskType", taskType.taskType)
	end

	self.view.clueBtnUWidget:SetActive(false)
end

function QuestMainComponent:refreshSourceBtn()
	if self.view == nil or self.curDetailType == nil or self.curDetailType == DETAIL_TYPE.CHAPTER then
		return
	end

	local isClueTip = self.curDetailType == DETAIL_TYPE.CLUE_TIP
	local questId = isClueTip and self.adventureGotoClueQuestId or self.curQuestId

	if questId == nil or questId <= 0 then
		return
	end

	self.curSubQuestId = nil
	self.curSourceId = nil

	if self.curDetailType == DETAIL_TYPE.SECTION and self.mainType == QuestConst.MainType.Adventure and QuestUtils.getQuestState(questId) ~= QuestConst.QUEST_STATE.RECEIVED then
		self.view.mainPanel:TryChangePage("SourceState", 0)

		return
	end

	local ojectives = QuestUtils.getReceivedQuestObjectives(questId, isClueTip)
	local isQuitHomeland = QuestUtils.needQuitOtherHomeland(questId)
	local hasTimeToken

	if isClueTip then
		hasTimeToken = QuestUtils.hasRunCondTimeToken(questId)
	else
		hasTimeToken = QuestUtils.hasRunCondTimeToken(questId, ojectives)
	end

	local forbid = QuestUtils.needQuitTeam(questId) or isQuitHomeland or QuestUtils.isQuestGroupForbidByBlacklist(questId, ojectives) or hasTimeToken

	if forbid then
		self.view.mainPanel:TryChangePage("SourceState", 0)

		return
	end

	local isShowSourceBtn, sourceId

	if isClueTip then
		for i = 1, #ojectives do
			local objcvData = ojectives[i]

			if objcvData and objcvData.questId then
				isShowSourceBtn, sourceId = QuestUtils.canTraceItemSource(objcvData.questId)

				if isShowSourceBtn then
					self.curSubQuestId = objcvData.questId
					self.curSourceId = sourceId

					break
				end
			end
		end
	else
		self.curSubQuestId = #ojectives > 0 and ojectives[1].questId or nil
		isShowSourceBtn, sourceId = QuestUtils.canTraceItemSource(self.curSubQuestId)

		if self.curDetailType == DETAIL_TYPE.SECTION then
			isShowSourceBtn = QuestUtils.filterSourceType(isShowSourceBtn, sourceId)
		end
	end

	self.view.mainPanel:TryChangePage("SourceState", isShowSourceBtn and 1 or 0)

	if isShowSourceBtn then
		local sourceConfig = ItemSourceData[sourceId]

		if sourceConfig then
			ClientTextUtils.setTextWithId(self.view.sourceBtnTxt, sourceConfig.buttonTxt)
		end
	end
end

function QuestMainComponent:refreshTracingState(questId, forbidTrack)
	if self.view == nil then
		return
	end

	forbidTrack = forbidTrack or false

	if forbidTrack then
		self.view.mainPanel:TryChangePage("Tracking", 4)

		return
	end

	local isFined = QuestUtils.isQuestFinished(questId)
	local questConfig = QuestUtils.getQuestConfig(questId)
	local isTracing = QuestUtils.isQuestTracing(questId)
	local isAssessmentTask = QuestUtils.isAssessmentTask(questId)
	local isAssessmentTaskTime = true

	if isAssessmentTask then
		local star = QuestUtils.getAssessmentStar(questId)

		if not Utils.checkUPStarTimeMatch(star) then
			isAssessmentTaskTime = false
		end
	end

	self.view.evaluationUnTrack:SetActive(false)

	if isFined then
		self.view.mainPanel:TryChangePage("Tracking", 4)
	elseif isTracing and isAssessmentTaskTime and (questConfig.questType == QuestConst.QUEST_TYPE.MAIN or questConfig.questType == QuestConst.QUEST_TYPE.SPECIAL_TRAIN) then
		self.view.mainPanel:TryChangePage("Tracking", 2)
	elseif isAssessmentTask then
		local star = QuestUtils.getAssessmentStar(questId)

		if Utils.checkUPStarTimeMatch(star) then
			self.view.mainPanel:TryChangePage("Tracking", isTracing and 3 or 0)
		else
			self.view.mainPanel:TryChangePage("Tracking", 4)

			local time = Utils.getUPStarFormatTime(star)

			self.view.evaluationUnTrack:SetActive(time ~= "")

			local text = pg.getFormatText(pg.getGameString("QUEST_ASSESSMENT_TIP"), time)

			ClientTextUtils.setText(self.view.evaluationUnTrackTips, text)
		end
	else
		local canShowTraceInfo = true

		if (self.mainType == QuestConst.MainType.Clue or self.mainType == QuestConst.MainType.Adventure) and QuestUtils.isQuestOfClueQuestType(questId) then
			local ojectives, firstUnfinishedIndex = QuestUtils.getReceivedQuestObjectives(questId)

			canShowTraceInfo = false

			for i = 1, #ojectives do
				local objcvData = ojectives[i]

				if objcvData and objcvData.questId then
					local isShowPathFlag = QuestUtils.canQuestObjShowArrowFlag(objcvData.questId)

					if isShowPathFlag and QuestUtils.isClueReveal(objcvData.questId) then
						canShowTraceInfo = isShowPathFlag

						break
					end
				end
			end
		end

		LuaUIUtils.setUIVisible(self.view.trackingBtn, canShowTraceInfo)
		LuaUIUtils.setUIVisible(self.view.untrackingBtn, canShowTraceInfo)

		if QuestUtils.isQuestOfClueQuestType(questId) and questId == self.adventureGotoClueQuestId then
			isTracing = pg.game.map:checkTrackMarkExists(questId)
		end

		if canShowTraceInfo then
			self.view.mainPanel:TryChangePage("Tracking", isTracing and 3 or 0)
		else
			self.view.mainPanel:TryChangePage("Tracking", 4)
		end
	end
end

function QuestMainComponent:onSectionPageChange(index)
	if self.sectionsInfo == nil or #self.sectionsInfo == 0 then
		return
	end

	local sectionId = index + 1

	if not self:playSectionItemAnimation(self.curSectionId, sectionId) then
		self.canSwitchPage = true

		return
	end

	self.canSwitchPage = false
	self.curSectionId = sectionId

	local sectionInfo = self.sectionsInfo[self.curSectionId].sectionInfo

	self.curQuestId = sectionInfo.questGroupId

	local ojectives, firstUnfinishedIndex = QuestUtils.getReceivedQuestObjectives(self.curQuestId)

	self.view.taskObjectiveList:SetList(ojectives)

	if firstUnfinishedIndex ~= nil then
		self.view.taskObjectiveList:GoToIndex(firstUnfinishedIndex - 1)
	end

	local questConfig = QuestUtils.getQuestConfig(sectionInfo.questGroupId)
	local rewardId = questConfig.rewardId
	local rewardItems = LuaUIUtils.getRewardItemByDropId(rewardId)

	rewardItems = rewardItems ~= nil and rewardItems or {}

	if QuestUtils.isQuestFinished(self.curQuestId) then
		for i = 1, #rewardItems do
			local rewardItem = rewardItems[i]

			rewardItem.hasGet = true
		end
	end

	self.view.rewardList:SetList(rewardItems)
	self:refreshTracingState(self.curQuestId)
end

function QuestMainComponent:playSectionItemAnimation(lastSectionId, newSectionId)
	local ret, btn = self.view.sectionInfoList:TryGetChildAt(newSectionId - 1)

	if btn == nil then
		return false
	end

	local coms = self.view:getMainQuestSectionItemComs(btn)
	local aniName

	if lastSectionId ~= nil then
		if lastSectionId < newSectionId then
			aniName = ANIName.ANI_SECTION_LEFT_OUT
		elseif newSectionId < lastSectionId then
			aniName = ANIName.ANI_SECTION_RIGHT_OUT
		end

		if aniName ~= nil then
			UIUtils.PlayAnimation(self.curSectionAni, aniName)
		end
	end

	if lastSectionId == nil then
		aniName = ANIName.ANI_SECTION_NORMAL_IN
	elseif lastSectionId < newSectionId then
		aniName = ANIName.ANI_SECTION_RIGHT_IN
	else
		aniName = ANIName.ANI_SECTION_LEFT_IN
	end

	UIUtils.PlayAnimation(coms.ani, aniName, function()
		UIUtils.PlayAnimation(coms.ani, ANIName.ANI_SECTION_NORMAL_LOOP)
	end)

	self.curSectionAni = coms.ani

	return true
end

function QuestMainComponent:onRenderQuestObjectiveItem(btn, index, data)
	local coms = self.view:getMainQuestQuestObjItemComs(btn)

	self:playItemInAni(index, btn, coms.ani, self.model.VXAniName.Quest_Objective_Item_In, self.skipObjectiveItemAni)

	local questId = data.questId
	local isFined = data.isFined
	local questData = QuestUtils.getQuestData(questId)

	if data.isReceiveNpcTarget then
		ClientTextUtils.setText(coms.contentTxt, data.objConfig.desc)
		coms.progress:SetActive(false)
		coms.btnPhone:SetActive(false)
		coms.tagUImage:SetActive(false)
		btn:TryChangePage("TaskState", 0)

		self.receiveNpcQuestId = data.questId

		return
	end

	local desc = data.objConfig.desc
	local totalTargetVal = QuestUtils.getQuestObjectiveTargetVal(questId, data.objId)
	local targetVal

	if isFined then
		targetVal = totalTargetVal
	else
		targetVal = data.objData and data.objData.currentCnt or 0
	end

	desc = ClientTextUtils.getLocalizationText(desc, targetVal)

	local isCn = ClientConfigAppCountry == "cn"

	if not isCn then
		desc = string.format(" %s", desc)
	end

	local displayType = data.objConfig.displayType or 1

	coms.progress:SetActive(displayType == QuestConst.QUEST_OBJCV_DISPLAY_TYPE.SHOW_PROGRESS)

	if displayType == QuestConst.QUEST_OBJCV_DISPLAY_TYPE.SHOW_COUNTING then
		local countingStr = string.format("[%s/%s]", targetVal, totalTargetVal)

		desc = ClientTextUtils.concatByLanguage(desc, countingStr)

		btn:TryChangePage("TaskState", 0)
	elseif displayType == QuestConst.QUEST_OBJCV_DISPLAY_TYPE.SHOW_PROGRESS then
		local progressValue = 0

		if totalTargetVal and totalTargetVal > 0 then
			progressValue = math.max(0, math.min(1, targetVal / totalTargetVal))
		end

		coms.progress.value = progressValue

		local countingStr = string.format("[%d%%]", progressValue * 100)

		desc = ClientTextUtils.concatByLanguage(desc, countingStr)

		btn:TryChangePage("TaskState", 1)
	end

	if data.objConfig.showCanSelect then
		desc = QuestUtils.questObjectiveCanSelect(desc)
	end

	if QuestUtils.isInQuestBlackList(questId) then
		desc = string.format(pg.getGameString("QUEST_CANNOT_PROGRESS_TARGET_TEXT"), desc)
	end

	if pg.game.setting:getShowDebugId() then
		ClientTextUtils.setText(coms.contentTxt, string.format("%d-%d-%s", questId, data.objId, desc))
	else
		ClientTextUtils.setText(coms.contentTxt, desc)
	end

	coms.btnPhone:SetActive(false)

	local callId = QuestUtils.getQuestCallId(questId)

	if callId > 0 then
		coms.btnPhone:SetActive(true)

		function coms.btnPhone.luaClick()
			pg.game.dialogue:playDialogueGraph(callId)
		end
	end

	coms.tagUImage:SetActive(false)

	local recommendLevel = data.objConfig.recommendLv

	if recommendLevel and recommendLevel > 0 then
		local showStyle, isShowInHud = QuestUtils.getObjectRecommendLevelStyle(recommendLevel)

		coms.tagUImage:SetActive(true)
		btn:TryChangePage("TagType", showStyle)
		ClientTextUtils.setText(coms.tagTextUSDFText, string.format(pg.getGameString("QUEST_RECOMMEND_LEVEL_MANUAL_TEXT"), recommendLevel))
	end

	btn:TryChangePage("Complete", 0)
	self:startTimer(function()
		if isFined then
			btn:TryChangePage("Complete", 1)
		end
	end, index * self.model.VXAniName.Quest_Objective_Item_In[2] + 0.5)

	btn.name = string.format("%d-%d", questId, data.objId)
end

function QuestMainComponent:getTraceQuestId()
	if self.isGotoClueClicked and self.adventureGotoClueQuestId and self.adventureGotoClueQuestId > 0 then
		return self.adventureGotoClueQuestId
	end

	return self.curQuestId
end

function QuestMainComponent:getPathfindingQuestId()
	local questId = self.curQuestId

	if questId == nil or not QuestUtils.isParentQuest(questId) then
		return questId
	end

	local ojectives, firstUnfinishedIndex = QuestUtils.getReceivedQuestObjectives(questId)

	if ojectives == nil or #ojectives == 0 then
		return questId
	end

	local objcvData = ojectives[firstUnfinishedIndex or 1]

	return objcvData and objcvData.questId or questId
end

function QuestMainComponent:traceQuestByType(isTrace, retracing)
	local traceQuestId = self:getTraceQuestId()

	if QuestUtils.isQuestOfClueQuestType(traceQuestId) then
		QuestUtils.clueQuestTrace(traceQuestId, isTrace)

		self.isTraceClue = isTrace

		self:refreshTracingState(traceQuestId)
	else
		self:onclickTraceBtn(retracing)
	end
end

function QuestMainComponent:onclickTraceBtn(retracing)
	if self.curQuestId == nil then
		return
	end

	local isTracing = QuestUtils.isQuestTracing(self.curQuestId)

	pg.game.quest:removeAllQuestPathfinding()

	if retracing then
		isTracing = false
	end

	if not isTracing then
		pg.game.quest:setHideTransitionAni(true)
	end

	pg.me:traceQuest(self.curQuestId, not isTracing)

	if not isTracing then
		QuestUtils.switchHudPageType(QuestUtils.getPageType(self.curQuestId), true)
	end

	local isShowSourceBtn, sourceId = QuestUtils.canTraceItemSource(self.curQuestId)

	if not isTracing then
		QuestUtils.addQuestPathingNavEffect(self:getPathfindingQuestId())
	end

	if isShowSourceBtn and not isTracing and sourceId and sourceId > 0 then
		local itemSourceConfig = ItemSourceData[sourceId]

		if itemSourceConfig and (itemSourceConfig.type == 2 or itemSourceConfig.type == 3) then
			local data = {}

			data.clueSeekID = sourceId

			table.merge(data, itemSourceConfig)
			LuaUIUtils.clueSeek(data, nil)
		end
	end

	if self.receiveNpcQuestId and QuestUtils.isSubQuestManualClaimable(self.receiveNpcQuestId) then
		QuestUtils.pathfindingToReceiveNpc(self.receiveNpcQuestId)
	end
end

function QuestMainComponent:onclickSourceBtn()
	local isShowSourceBtn, sourceId

	if self.curSourceId then
		sourceId = self.curSourceId
		isShowSourceBtn = true
	else
		isShowSourceBtn, sourceId = QuestUtils.canTraceItemSource(self.curSubQuestId)
	end

	if isShowSourceBtn then
		local data = {}

		data.clueSeekID = sourceId

		table.merge(data, ItemSourceData[sourceId])
		LuaUIUtils.clueSeek(data, function()
			self.ctrl:dismiss()
		end, self.view.sourceBtn)
	end
end

function QuestMainComponent:onclickAdventureGotoClue()
	self.isGotoClueClicked = true

	local isClueQuest = QuestUtils.isQuestOfClueQuestType(self.adventureGotoClueQuestId)

	if isClueQuest then
		self:onClueTipPanel()
	else
		local chapterId, sectionId = QuestUtils.getQuestGroupChapterInfo(self.adventureGotoClueQuestId)

		if sectionId and sectionId > 0 then
			self.ctrl:selectTabByMainType(QuestConst.QUEST_MANUAL_JUMP_TYPE.QUEST, sectionId)
		end
	end
end

function QuestMainComponent:onclickClueFoldUp()
	self.isGotoClueClicked = false

	if self.lastSectionData then
		self:onClickSectionItem(self.lastSectionData)
	end
end

function QuestMainComponent:onExit()
	return
end

function QuestMainComponent:onRenderRewardSkillItem(button, data)
	local oc = button:GetComponent("ObjectReference")
	local tLevel = oc:GetRefValue("txtLevel")
	local tName = oc:GetRefValue("txtName")
	local iIcon = oc:GetRefValue("icon")

	iIcon.url = data.icon

	button:TryChangePage("HideText", 1)
	button:TryChangePage("SkillLevel", 1)
	button:TryChangePage("SkillStage", 2)
	button:TryChangePage("SkillType", data.isRare and 1 or 0)

	function button.luaClick()
		if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP) then
			pg.global.ui:close(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP)
		else
			pg.global.ui:open(UIConst.UI_ID_COMMON_PLAYER_SKILL_TIP, {
				autoHor = true,
				targetRect = button,
				data = data
			})
		end
	end
end

function QuestMainComponent:onRenderRewardSkillPointItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iIcon = objectReference:GetRefValue("icon")
	local textNum = objectReference:GetRefValue("textNum")
	local txtName = objectReference:GetRefValue("txtName")

	iIcon.url = data.icon

	ClientTextUtils.setText(textNum, string.format("+%d", data.num))
	ClientTextUtils.setText(txtName, data.name)
end

function QuestMainComponent:onclickFilterBtn()
	pg.global.ui:open(UIConst.UI_ID_MAP_AREA_FILTER, {
		1,
		function(areaIds, isDirty)
			if not isDirty then
				return
			end

			self.selectedAreaIds = areaIds

			self:onShow(self.mainType)
		end
	})
end

function QuestMainComponent:onclickFilterDeleteBtn()
	self.selectedAreaIds = {}

	pg.game.map:saveMapAreaSelectedSetting(self.selectedAreaIds)
	self:onShow(self.mainType)
end

function QuestMainComponent:setForbidTipsText(questId, isForbid, objectives)
	if isForbid then
		local tipsText, runTokenId, runTokenText

		objectives = objectives or QuestUtils.getReceivedQuestObjectives(questId)

		if objectives then
			for _, obj in ipairs(objectives) do
				if obj.questId and QuestUtils.isRunCondNotMet(obj.questId) then
					runTokenId, runTokenText = QuestUtils.getRunCondTimeTokenInfo(obj.questId)

					if runTokenId then
						break
					end
				end
			end
		end

		if runTokenId then
			tipsText = runTokenText
		elseif QuestUtils.isQuestGroupForbidByBlacklist(questId, objectives) then
			tipsText = string.match(pg.getGameString("QUEST_CANNOT_PROGRESS_TARGET_TEXT"), "%%s%s*(.+)")
		else
			local isQuitHomeland = QuestUtils.needQuitOtherHomeland(questId)

			tipsText = isQuitHomeland and pg.getGameString("QUEST_CANNOT_DO_IN_OTHER_HOME") or pg.getGameString("QUEST_CANNOT_DO_IN_OTHER_WORLD")
		end

		ClientTextUtils.setText(self.view.forbidText, tipsText)
	end
end

function QuestMainComponent:refreshChapterProgressReward(chapterId)
	local progressInfo = self.model:getChapterProgressRewardInfo(chapterId)

	if not progressInfo then
		LuaUIUtils.setUIViewVisible(self.view.chapterUWidget, false)

		return
	end

	LuaUIUtils.setUIViewVisible(self.view.chapterUWidget, true)
	ClientTextUtils.setText(self.view.chapterRewardTtile, pg.getGameString("QUEST_CHAPTER_REWARD_TITLE"))
	ClientTextUtils.setText(self.view.chapterRewardProgress, string.format("%d%%", progressInfo.curProgress))

	function self.view.chapterRewardListUList.luaRenderItem(button, index, data)
		if data.tIndex == 0 then
			local objectReference = button:GetComponent("ObjectReference")
			local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
			local progressUProgress = objectReference:GetRefValue("progressUProgress")
			local itemGetUButton = objectReference:GetRefValue("itemGetUButton")

			LuaUIUtils.renderRewards(itemGetUButton, index, data)

			if data.showRedDot then
				function itemGetUButton.luaClick()
					if data.showRedDot then
						self:onClickGetChapterProgressReward(data.configId, data.rewardIndex)
					end
				end
			end

			local chapterId = self.curChapterData and self.curChapterData.chapterId
			local rewardTreePath = string.format(RedDotConst.RedDotPath.QUEST_CHAPTER_REWARD_REWARD, self.mainType, chapterId, data.rewardIndex)

			pg.global.setRedDot(rewardTreePath, itemGetUButton, data.showRedDot, RedDotConst.RedDotStyle.REWARD)
			ClientTextUtils.setText(txtNameUSDFText, string.format("%d%%", data.progressThreshold))

			local segmentProgress

			segmentProgress = progressInfo.curProgress >= data.progressThreshold and 1 or progressInfo.curProgress <= data.prevThreshold and 0 or (progressInfo.curProgress - data.prevThreshold) / (data.progressThreshold - data.prevThreshold)
			progressUProgress.value = segmentProgress
		end
	end

	function self.view.chapterRewardViewUButton.luaRenderTooltip(btn, popUp)
		local objectReference = popUp:GetComponent("ObjectReference")
		local listTagUList = objectReference:GetRefValue("listUList")

		listTagUList:SetRightStickScrollConsoleBar("CONSOLE_BAR_SCROLL", -1)

		function listTagUList.luaRenderItem(b, i, data)
			local ob = b:GetComponent("ObjectReference")
			local itemRootUButton = ob:GetRefValue("itemRootUButton")
			local txtTitleUSDFText = ob:GetRefValue("txtNameUSDFText")

			ClientTextUtils.setText(txtTitleUSDFText, pg.getFormatText(pg.getGameString("QUEST_COMPLETE_TO"), data.name))
			itemRootUButton:TryChangePage("State", data.isFined and 1 or 0)
		end

		listTagUList:SetList(progressInfo.chapterNameList)
	end

	local rewardItems = {}

	for i = 1, #progressInfo.rewardList do
		local rData = progressInfo.rewardList[i]
		local itemData

		if DropData[rData.rewardId] then
			local temp = LuaUIUtils.getRewardItemByDropId(rData.rewardId)

			if temp ~= nil and #temp > 0 then
				itemData = temp[1]
			end
		end

		if itemData then
			itemData.canGet = rData.canClaim
			itemData.hasGet = rData.claimed
			itemData.showRedDot = rData.canClaim
			itemData.rewardIndex = rData.rewardIndex
			itemData.configId = progressInfo.configId
			itemData.progressThreshold = rData.progressThreshold
			itemData.prevThreshold = rData.prevThreshold

			table.insert(rewardItems, itemData)
		end
	end

	self.view.chapterRewardListUList:SetList(rewardItems)
end

function QuestMainComponent:onChapterProgressRewardClaimed()
	local savedChapterId = self.curChapterData and self.curChapterData.chapterId

	self:refreshChapterProgressReward(savedChapterId)
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.QUEST_CHAPTER_REWARD_ITEM)
end

function QuestMainComponent:onClickGetChapterProgressReward(configId, rewardIndex)
	pg.me:getChapterQuestProgressReward(configId, rewardIndex, function(ret)
		self:onChapterProgressRewardClaimed()
	end)
end

return QuestMainComponent
