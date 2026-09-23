-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SpecialTrainNew\\SpecialTrainNewCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local QuestConst = require("Common.Const.QuestConst")
local MessageName = require("Const.MessageName")
local RedDotConst = require("Const.RedDotConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local ClientUtils = require("Utils.ClientUtils")
local SpecialTrainNewCtrl = Class.LightClass("SpecialTrainNewCtrl", UICtrl)
local logger = LoggerManager.getLogger("SpecialTrainNewCtrl")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local CustomTriggerData = require("Data.custom_trigger_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local PetDetailTipComponent = require("Guis.Panels.SpecialTrainNew.Component.PetDetailTipComponent")
local SegmentProgressListComponent = require("Guis.Helper.SegmentProgressListComponent")
local PetProtoTypeData = require("Data.pet_prototype_data")
local ItemData = require("Data.item_data")
local ClientConst = require("Const.ClientConst")
local SysConfigData = require("Data.sys_config_data")
local Const = require("Common.Const.Const")
local GuideUtils = require("Utils.GuideUtils")
local AddressDataConst = require("Const.AddressDataConst")
local TriggerConst = require("Common.Const.TriggerConst")

SpecialTrainNewCtrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	},
	[MessageName.QUEST_ON_TRACE_CHANGE] = {
		"onQuestTraceChange",
		true
	},
	[MessageName.RED_DOT_SPECIAL_TRAIN_TREE] = {
		"onQuestTabChange",
		true
	}
}

local templateId = 1023300
local SpecialQuestItemInAniSpan = 0.02
local CHAPTER_TIPS_TIME = 86400
local CHAPTER_TIPS_CLOSE_TIME = 10
local CHAPTER_INDEX_FIRST = 1
local LINK_LAYER = 9
local BADGE_FLY_PROGRESS_FALLBACK_TIME = 3

function SpecialTrainNewCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.detailComponent = PetDetailTipComponent.new(self)
	self.curQuestId = 0
	self.targetIdx = -1
	self.playProgressAni = true
	self.isMobile = IS_MOBILE
	self.breakPlayProgressAni = {}
	self.lastAnimChapterId = 0
	self.lastPage = 0
	self.openTrainType = info and info.trainType
	self.openAutoTrace = info and info.autoTrace
end

function SpecialTrainNewCtrl:addListener()
	function self.view.listLeftTabUList.luaRenderItem(button, index, data)
		self:renderTabItem(button, index, data)
	end

	function self.view.requiredTabUButton.luaClick()
		self.selectedTrainType = nil

		self:setTypePageName()

		self.view.requiredTabUButton.isSelected = true
		self.curPage = QuestConst.QUEST_TRAIN_SUB_TYPE.COMPULSORY
		self.curQuestId = 0

		self:setCenterInfo()
		self:refreshRightDetail()
		self.view.listLeftTabUList:RefreshList()
	end

	function self.view.listCenterUList.luaRenderItem(button, index, data)
		self:renderItemInfo(button, index, data, true)
	end

	self.badgeProgressComponent = SegmentProgressListComponent.new(self, nil, {
		waitFinishEvent = false,
		list = self.view.rewardListUList,
		getProgress = function(button)
			local itemComs = self.view:getBadgeRewardItemComs(button)

			return itemComs.progress, itemComs.progress
		end,
		getTarget = function(data)
			return data.badgeCollectNum
		end,
		renderOther = function(button, index, data, visualTotal)
			self:onRefreshBadgeRewardItem(button, index, data, visualTotal)
		end,
		renderFinalOther = function(visualTotal)
			self:setBigRewardInfo(visualTotal)
		end,
		finalProgress = self.view.progressUProgress,
		finalEventTarget = self.view.progressUProgress,
		finalTarget = self.model:getBadgeMaxNum(),
		onProgressChanged = function(currentTotal)
			self.badgeProgressVisualTotal = currentTotal

			self:setBadgeProgressText(currentTotal)
		end,
		onSegmentComplete = function(button, index, data, currentTotal, isReached, isFinal)
			if not isReached then
				return
			end

			if isFinal then
				self:setBigRewardInfo(currentTotal)
			elseif button and NotNil(button) then
				self:onRefreshBadgeRewardItem(button, index, data, currentTotal)
			end
		end
	})

	function self.view.finalBadgeReward.luaClick(button, index, data)
		self:onClickBigRewardInfo(button, index, data)
	end

	function self.view.chapterTipsBtn.luaClick(button, index, data)
		self:setChapterTips(false)
	end

	function self.view.btnBack.luaClick(button, index, data)
		local _, curIndex = self.view.root:TryGetCurrentPage("Details")

		if curIndex == 1 then
			self.view.root:TryChangePage("Details", 0)

			PetResearchUtils.inDetailLoading = nil
		else
			self:dismiss()
		end
	end

	local exitBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.view.objectReference.gameObject, "SpecialTrainNewCtrl")

	exitBinding.actionPath = "Common/Cancel"
	exitBinding.isVirtual = true

	function exitBinding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self.view.btnBack.luaClick()
		end
	end

	if IS_MOBILE then
		self.view.ImgPet:SetActive(true)
		LuaUIUtils.setUIViewVisible(self.view.rawImgPetRawImagePro, false)
	else
		self.view.ImgPet:SetActive(false)
		LuaUIUtils.setUIViewVisible(self.view.rawImgPetRawImagePro, true)
		self.uiScene:setRawImageProRef(self.view.rawImgPetRawImagePro)
	end

	self:bindGamepadScrollUList(self.view.listCenterUList, 150, true)
end

function SpecialTrainNewCtrl:initInfo()
	self.view.root:TryChangePage("Details", 0)

	self.curChapterIndex = QuestUtils.getChapterMaxIndex()
	self.preChapterIndex = self.curChapterIndex
	self.curPage = self.model:getSelectPageIndex() or QuestConst.QUEST_TRAIN_SUB_TYPE.COMPULSORY

	if self.openTrainType and self.openTrainType >= QuestConst.QUEST_TRAIN_SUB_TYPE.COMPULSORY and self.openTrainType <= QuestConst.QUEST_TRAIN_SUB_TYPE.FIGHT then
		self.curPage = self.openTrainType
	end

	self.curChapterId = QuestUtils.getChapterIdByIndex(self.curChapterIndex) or QuestConst.TRAIN_PHASE.CHAPTER
	self.chapterTotalNum = QuestUtils.getChapterMaxIndex()
	self.titleName = LuaUIUtils.getFuncName(Const.FUNCTION_IDS.SPECIALTRAIN)
	CHAPTER_TIPS_TIME = SysConfigData.SPEICIAL_TRAIN_BUBBLE_COOLDOWN or CHAPTER_TIPS_TIME
	CHAPTER_TIPS_CLOSE_TIME = SysConfigData.SPEICIAL_TRAIN_BUBBLE_DURATION or CHAPTER_TIPS_CLOSE_TIME
end

function SpecialTrainNewCtrl:onShow()
	self:initInfo()
	self:showPanel()
end

function SpecialTrainNewCtrl:showPanel()
	self:setRequiredPageName()
	self:unlockSpecialTrainVX()
	self:setTypePageName()
	self:setTopChapterInfo()
	self:setCenterInfo()
	self:setBadgeRewardInfo()
	self:refreshRightDetail()

	if self.openAutoTrace then
		self:jumpToTrainTypeAndTrace(self.curPage)

		self.openTrainType = nil
		self.openAutoTrace = nil
	end
end

function SpecialTrainNewCtrl:jumpToTrainTypeAndTrace(trainType)
	if self.view and pg.me.isOpenedTrainInterface then
		trainType = trainType or QuestConst.QUEST_TRAIN_SUB_TYPE.COMPULSORY

		if self.curPage ~= trainType then
			self.curPage = trainType
			self.curQuestId = 0

			self:setCenterInfo()
			self:refreshRightDetail()
			self.view.listLeftTabUList:RefreshList()
		end

		self.view.requiredTabUButton.isSelected = self:isCompulsoryPage()

		local list = self.model:getChapterPageInfo(self.curChapterId, self.curPage)
		local traceId

		for _, item in ipairs(list or EMPTY_TABLE) do
			if item.questId and tonumber(item.questId) and tonumber(item.questId) > 0 and not QuestUtils.isQuestFinished(item.questId) then
				traceId = item.questId

				break
			end
		end

		if traceId then
			QuestUtils.traceSecondTracingQuest(traceId)
		end
	end
end

function SpecialTrainNewCtrl:onDestroy()
	self:cancelWaitBadgeFlyProgress()

	self.playProgressAni = false
	self.curQuestId = 0
	self.curChapterId = 0
	self.curChapterIndex = 0
	self.preferenceComponent = nil
	self.breakPlayProgressAni = {}
	self.detailComponent = nil
	self.preTraceQuestId = nil
	self.curTraceQuestId = nil
	self.preChapterIndex = 0

	pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
	pg.global.ui:close(UIConst.UI_ID_SPECIAL_TRAIN_CHAPTER_TIP_PANEL)
	UICtrl.onDestroy(self)
end

function SpecialTrainNewCtrl:close()
	if pg.me ~= nil and self._isOpen then
		pg.me:tryClientTrigger(TriggerConst.TRIGGER_CLOSE_INTERFACE, self.uid, 1)
	end

	self:closeImmediately()
end

function SpecialTrainNewCtrl:closePanel()
	local _, curIndex = self.view.root:TryGetCurrentPage("Details")

	if curIndex == 1 then
		self.view.root:TryChangePage("Details", 0)

		PetResearchUtils.inDetailLoading = nil
	else
		self:dismiss()
	end
end

function SpecialTrainNewCtrl:switchChapter(offset)
	self.curChapterIndex = self.curChapterIndex + offset
	self.preChapterIndex = self.curChapterIndex
	self.curChapterId = QuestUtils.getChapterIdByIndex(self.curChapterIndex)

	local curChapterName = QuestUtils.getChapterNumber(self.curChapterId)

	self.curSelectChapterId = self.curSelectChapterId > 0 and self.curChapterId or 0

	LuaUIUtils.setUIViewVisible(self.view.nextBtnLeftUButton, self.curChapterIndex > 1)
	LuaUIUtils.setUIViewVisible(self.view.nextBtnRightUButton, self.curChapterIndex < self.chapterTotalNum)
	self:setCenterInfo()
	self:updateChapterNavRedDot()
end

function SpecialTrainNewCtrl:setTopChapterInfo()
	LuaUIUtils.setUIViewVisible(self.view.nextBtnLeftUButton, self.curChapterIndex > 1)
	LuaUIUtils.setUIViewVisible(self.view.nextBtnRightUButton, self.curChapterIndex < self.chapterTotalNum)

	function self.view.nextBtnLeftUButton.luaClick(button, index, data)
		if self.curChapterIndex <= 1 then
			return
		end

		self:switchChapter(-1)
	end

	function self.view.nextBtnRightUButton.luaClick(button, index, data)
		if self.curChapterIndex >= self.chapterTotalNum then
			return
		end

		self:switchChapter(1)
	end

	self:updateChapterNavRedDot()
end

function SpecialTrainNewCtrl:updateChapterNavRedDot()
	local hasLeftReward = self:checkChapterRangeHasReward(1, self.curChapterIndex - 1)
	local hasRightReward = self:checkChapterRangeHasReward(self.curChapterIndex + 1, self.chapterTotalNum)
	local leftTreePath = RedDotConst.RedDotPath.SPECIAL_TRAIN_TAB_TREE .. "nav_left_" .. self.curChapterIndex
	local rightTreePath = RedDotConst.RedDotPath.SPECIAL_TRAIN_TAB_TREE .. "nav_right_" .. self.curChapterIndex

	pg.global.setRedDot(leftTreePath, self.view.nextBtnLeftUButton, hasLeftReward, RedDotConst.RedDotStyle.REWARD)
	pg.global.setRedDot(rightTreePath, self.view.nextBtnRightUButton, hasRightReward, RedDotConst.RedDotStyle.REWARD)
end

function SpecialTrainNewCtrl:checkChapterRangeHasReward(startIndex, endIndex)
	if endIndex < startIndex then
		return false
	end

	for index = startIndex, endIndex do
		local chapterId = QuestUtils.getChapterIdByIndex(index)
		local isCanUpgradeTitle = not QuestUtils.isVersionCapChapterFinished(chapterId) and QuestUtils.isCanUpgradeStar(chapterId)
		local questCanGetReward = self.model:redDot_GetQuestPageState(QuestConst.QUEST_TRAIN_SUB_TYPE.COMPULSORY, chapterId)

		if chapterId and chapterId > 0 then
			local isCanGetReward = self.model:isCanGetChapterReward(chapterId)
			local chapterStateInfo = QuestUtils.getChapterState(chapterId)

			if isCanGetReward and not chapterStateInfo.isChapterRewarded or questCanGetReward or isCanUpgradeTitle then
				return true
			end
		end
	end

	return false
end

function SpecialTrainNewCtrl:isCompulsoryPage()
	return self.curPage == QuestConst.QUEST_TRAIN_SUB_TYPE.COMPULSORY
end

function SpecialTrainNewCtrl:setRequiredPageName()
	local coms = self.view:getTabItemComs(self.view.requiredTabUButton)

	if coms == nil then
		return
	end

	local name = self.model:getTypePageName(QuestConst.QUEST_TRAIN_SUB_TYPE.COMPULSORY)

	if name then
		ClientTextUtils.setText(coms.name, name)
		ClientTextUtils.setText(coms.nameS, name)

		self.curQuestId = 0
		self.view.requiredTabUButton.isSelected = self:isCompulsoryPage()
	end

	local isCanUpgradeTitle = self.model:redDot_GetUptitleState()
	local chapterStateInfo = QuestUtils.getChapterState(self.curChapterId)
	local isCanGetReward = self.model:isCanGetChapterReward(self.curChapterId)
	local showRedDot = self.model:redDot_GetQuestPageState(QuestConst.QUEST_TRAIN_SUB_TYPE.COMPULSORY) or isCanGetReward and not chapterStateInfo.isChapterRewarded
	local treePath = RedDotConst.RedDotPath.SPECIAL_TRAIN_TAB_TREE .. self.curChapterId .. QuestConst.QUEST_TRAIN_SUB_TYPE.COMPULSORY
	local redDotConstStyle = RedDotConst.RedDotStyle.REWARD

	if not showRedDot and isCanUpgradeTitle then
		redDotConstStyle = RedDotConst.RedDotStyle.POINT
	end

	pg.global.setRedDot(treePath, self.view.requiredTabUButton, showRedDot or isCanUpgradeTitle, redDotConstStyle)
end

function SpecialTrainNewCtrl:setTypePageName()
	local dataList = self.model:getLeftPageList()

	if dataList then
		self.view.listLeftTabUList:SetList(dataList)
	end

	self:setRequiredPageName()
end

function SpecialTrainNewCtrl:renderTabItem(button, index, data)
	if data == nil then
		return
	end

	local coms = self.view:getTabItemComs(button)

	if coms == nil then
		return
	end

	local typePageConfig = self.model:getTypePageConfig(data.trainType)

	button.isSelected = self.curPage == data.trainType

	ClientTextUtils.setText(coms.name, data.name)
	ClientTextUtils.setText(coms.nameS, data.name)
	coms.line:SetActiveFastest(index ~= 0)

	function coms.button.luaClick()
		if self.curPage ~= data.trainType then
			self.view.requiredTabUButton.isSelected = false
			self.curPage = data.trainType
			self.curQuestId = 0

			self:setCenterInfo()
			self:refreshRightDetail()
			self.view.listLeftTabUList:RefreshList()
		end
	end

	local chapterStateInfo = QuestUtils.getChapterState(self.curChapterId)
	local isCanGetReward = self.model:isCanGetChapterReward(self.curChapterId) and data.trainType == QuestConst.QUEST_TRAIN_SUB_TYPE.COMPULSORY
	local showRedDot = self.model:redDot_GetQuestPageState(data.trainType) or isCanGetReward and not chapterStateInfo.isChapterRewarded
	local treePath = RedDotConst.RedDotPath.SPECIAL_TRAIN_TAB_TREE .. self.curChapterId .. data.trainType

	pg.global.setRedDot(treePath, button, showRedDot, RedDotConst.RedDotStyle.REWARD)
end

function SpecialTrainNewCtrl:onQuestTabChange()
	if self.view then
		self.view.listLeftTabUList:RefreshList()
	end
end

function SpecialTrainNewCtrl:setCenterInfo()
	if self:isCompulsoryPage() then
		self:setChapterItemInfo()
	else
		self:setElectiveItemInfo()
	end

	local questItemList = self.model:getChapterPageInfo(self.curChapterId, self.curPage)

	self.view.root:TryChangePage("ListType", self:isCompulsoryPage() and 0 or 1)

	local chapterStateInfo = QuestUtils.getChapterState(self.curChapterId)

	if chapterStateInfo and not chapterStateInfo.isChapterViewed and pg.me.isOpenedTrainInterface then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("onClickGetChapterItemRewardShowView")
		end

		pg.global.ui:open(UIConst.UI_ID_SPECIAL_TRAIN_CHAPTER_TIP_PANEL, {
			openType = 1,
			chapterId = self.curChapterId
		}, function()
			pg.me:firstViewSpeicalTrainChapter(self.curChapterId)
		end, function()
			self.view.root:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		end)
	end

	if #questItemList > 0 then
		self.view.listCenterUList:SetList(questItemList)
		self.view.listCenterUList:GoToPos(Vector2.zero, true)
	end

	ClientTextUtils.setText(self.view.topTitleMPUBaseText, self.titleName)

	self.playChangeAni = false
	self.totalQuestCount = #questItemList
end

function SpecialTrainNewCtrl:renderItemInfo(button, index, data)
	if data == nil then
		return
	end

	if data.tIndex == QuestConst.TRAIN_QUEST_TEMPLATE_TYPE.TITLE then
		button:TryChangePage("Type", data.taskId == 0 and 0 or 1)
	elseif data.tIndex == QuestConst.TRAIN_QUEST_TEMPLATE_TYPE.MORE then
		local objectReference = button:GetComponent("ObjectReference")
		local btnGoUButton = objectReference:GetRefValue("btnGoUButton")
		local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
		local tipText = objectReference:GetRefValue("tipText")

		ClientTextUtils.setText(txtNameUBaseText, pg.getGameString("SPECIAL_TRAIN_CHAPTER_UNLOCK_TEXT"))
		ClientTextUtils.setText(tipText, string.format(pg.getGameString("SPECIAL_TRAIN_SIDE_UNLOCK_TIP"), self.model:getTypePageName(data.pageType)))

		function btnGoUButton.luaClick()
			if self:isCompulsoryPage() then
				-- block empty
			else
				self.curPage = QuestConst.QUEST_TRAIN_SUB_TYPE.COMPULSORY

				self:onQuestTabChange()
				self:setCenterInfo()
			end
		end
	else
		self:renderQuestItemInfo(button, index, data)
	end
end

function SpecialTrainNewCtrl:setChapterItemInfo()
	local chapterItemsComs = self.view:getChapterItemComs(self.view.chapterItemUButton)
	local chapterConfig = QuestUtils.getChapterConfig(self.curChapterId)
	local chapterData = self.model:getChapterData(self.curChapterId)

	if chapterItemsComs == nil then
		return
	end

	local curProgressText = ""

	if chapterConfig then
		if pg.game.setting:getShowDebugId() then
			ClientTextUtils.setText(chapterItemsComs.chapterTitle, string.format("%d-%s-%s", self.curChapterId, pg.getLocalizationText(chapterConfig.chapterName), pg.getLocalizationText(chapterConfig.chapterTitleDes)))
		else
			ClientTextUtils.setText(chapterItemsComs.chapterTitle, pg.getLocalizationText(chapterConfig.chapterTitleDes) or "")
		end

		local desc = ClientTextUtils.getLocalizationText(chapterConfig.chapterTitleDes)

		ClientTextUtils.setText(chapterItemsComs.detail, "")

		chapterItemsComs.iconUImage.url = chapterConfig.bannerImg

		ClientTextUtils.setText(chapterItemsComs.tagText, QuestUtils.getChapterNumber(self.curChapterId))

		local compulsoryList = self.model:getChapterCompulsoryList(self.curChapterId)
		local totalFinishNum = chapterConfig.mustTaskNum
		local curFinishNum = self.model:finishGotRewardCompulsoryNum(self.curChapterId)

		function chapterItemsComs.stageList.luaRenderItem(button1, index, data)
			button1:TryChangePage("Stage", curFinishNum < data.stage and 0 or 1)
		end

		chapterItemsComs.stageList:SetList(compulsoryList)

		local num = string.format("[%s/%s]", curFinishNum, totalFinishNum)
		local text = string.format(pg.getGameString("SPECIAL_TRAIN_FINISH_COMPULSORY"), num)

		ClientTextUtils.setText(chapterItemsComs.mainDescText, text)
		ClientTextUtils.setText(chapterItemsComs.number, "")

		chapterItemsComs.chapterItem.isSelected = self.curSelectChapterId == self.curChapterId

		function chapterItemsComs.rewardList.luaRenderItem(button, index, data)
			LuaUIUtils.renderRewards(button, index, data)

			self.curSelectChapterId = self.curChapterId
			self.curQuestId = 0

			self:refreshRightDetail()

			function button.luaNavFocused()
				if button then
					self:refreshCanSeeRewardState(true)
				end
			end
		end

		self:setChapterRewardList()

		local chapterStateInfo = QuestUtils.getChapterState(self.curChapterId)
		local isCanGetReward = self.model:isCanGetChapterReward(self.curChapterId)

		if chapterStateInfo.isChapterRewarded then
			self.view.chapterItemUButton:TryChangePage("ChapterState", 2)
		elseif isCanGetReward then
			self.view.chapterItemUButton:TryChangePage("ChapterState", 1)

			local coms = self.view:getBtnComs(chapterItemsComs.btnGetUButton)

			if coms then
				ClientTextUtils.setText(coms.nameText, pg.getGameString("CHARACTER_LEVEL_CLAIM"))
			end
		else
			self.view.chapterItemUButton:TryChangePage("ChapterState", 0)
			ClientTextUtils.setText(chapterItemsComs.txtIngUSDFText, pg.getGameString("ECOLOGICAL_CHAPTER_AWARD_ONGOING"))
			self:setChapterTips(true)
		end

		function chapterItemsComs.chapterItem.luaClick()
			self.curSelectChapterId = self.curChapterId
			self.curQuestId = 0

			self:resetQuestItemInfo(1)
			self:refreshRightDetail()
		end

		function chapterItemsComs.btnGetUButton.luaClick()
			self:onClickGetChapterItemReward(self.curChapterId)
		end

		local showRedDot = not chapterStateInfo.isChapterRewarded and isCanGetReward
		local treePath = string.format("%s%s%s%s", RedDotConst.RedDotPath.SPECIAL_TRAIN_TAB_TREE, self.curChapterId, QuestConst.TRAIN_CHAPTER_COURSE_TYPE.COMPULSORY, 1)

		pg.global.setRedDot(treePath, chapterItemsComs.btnGetUButton, showRedDot, RedDotConst.RedDotStyle.REWARD)

		if chapterConfig.chapterGuideId and not GuideUtils.isGuidePlayed(chapterConfig.chapterGuideId) then
			pg.game.guide:clientStartGuide(chapterConfig.chapterGuideId)
		end

		function chapterItemsComs.chapterItem.luaNavFocused()
			if chapterItemsComs.chapterItem then
				chapterItemsComs.chapterItem:OnClickSimulate()
			end
		end
	end
end

function SpecialTrainNewCtrl:setElectiveItemInfo()
	local electiveItemsComs = self.view:getChapterItemComs(self.view.electiveTitleUButton)
	local typePageConfig = self.model:getTypePageConfig(self.curPage)

	if electiveItemsComs == nil then
		return
	end

	if typePageConfig then
		ClientTextUtils.setText(electiveItemsComs.chapterTitle, pg.getLocalizationText(typePageConfig.typeName) or "")

		electiveItemsComs.iconUImage.url = typePageConfig.bannerImg

		local desc = ClientTextUtils.getLocalizationText(typePageConfig.des)

		ClientTextUtils.setText(electiveItemsComs.detail, pg.getGameString("SPECIAL_TRAIN_CAN_GET_QUEST_BY_EXPLORE"))
		ClientTextUtils.setText(electiveItemsComs.tagText, pg.getGameString("SPECIAL_TRAIN_RECOMMED_TYPE"))

		electiveItemsComs.chapterItem.isSelected = self.curSelectChapterId == self.curPage

		function electiveItemsComs.chapterItem.luaClick()
			self.curSelectChapterId = self.curChapterId
			self.curQuestId = 0

			self:resetQuestItemInfo(1)
			self:refreshRightDetail()
		end

		function electiveItemsComs.chapterItem.luaNavFocused()
			if electiveItemsComs.chapterItem then
				electiveItemsComs.chapterItem:OnClickSimulate()
			end
		end
	end
end

function SpecialTrainNewCtrl:setChapterRewardList()
	local chapterItemsComs = self.view:getChapterItemComs(self.view.chapterItemUButton)
	local chapterConfig = QuestUtils.getChapterConfig(self.curChapterId)
	local chapterData = self.model:getChapterData(self.curChapterId)
	local chapterStateInfo = QuestUtils.getChapterState(self.curChapterId)
	local isCanGetReward = self.model:isCanGetChapterReward(self.curChapterId)

	if chapterData == nil or chapterItemsComs == nil then
		return
	end

	local rewardItems = {}
	local temp = LuaUIUtils.getRewardItemByDropId(chapterConfig.rewardId)

	if temp ~= nil and #temp > 0 then
		for i = 1, #temp do
			temp[i].buttonItem = self.view.chapterItemUButton
			temp[i].chapterId = self.curChapterId
			temp[i].hasGet = chapterStateInfo.isChapterRewarded
			temp[i].canGet = isCanGetReward
			temp[i].showRedDot = temp[i].canGet and not temp[i].hasGet

			table.insert(rewardItems, temp[i])
		end
	end

	chapterItemsComs.rewardList:SetList(rewardItems)
end

function SpecialTrainNewCtrl:onClickGetChapterItemReward(chapterId)
	pg.game.audio:triggerEvent("SFX_UI_SpecialTraining_Achieve01")

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("onClickGetChapterItemReward")
	end

	pg.me:getSpecialTrainChapterReward(chapterId, function(ret)
		local function openCb()
			return
		end

		local function closeCb()
			self.view.root:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
			self:setCenterInfo()

			if self.view then
				self:setRequiredPageName()
			end
		end

		if ret then
			pg.global.ui:open(UIConst.UI_ID_SPECIAL_TRAIN_CHAPTER_TIP_PANEL, {
				openType = 2,
				chapterId = chapterId,
				closeCallback = closeCb
			}, openCb)

			self.curChapterIndex = QuestUtils.getChapterMaxIndex()
			self.curChapterId = QuestUtils.getChapterIdByIndex(self.curChapterIndex)
			self.chapterTotalNum = QuestUtils.getChapterMaxIndex()

			self:setTopChapterInfo()

			if self.view then
				self:setRequiredPageName()
			end
		end
	end)
end

function SpecialTrainNewCtrl:setChapterImageInfo(chapterConfig)
	self.view.scrollText:SetActive(true)

	self.view.imgPic1UImage.url = chapterConfig.chapterImg or ""

	local material = self.curChapterIndex == CHAPTER_INDEX_FIRST and AddressDataConst.QUEST_SPECIAL_TRAIN_REQUIRE_IN_MAT or AddressDataConst.QUEST_SPECIAL_TRAIN_REQUIRE_COM_MAT

	self.view.imgPic1UImage:SetMaterial(material)
	self.view.badgeBgUImage:SetActive(chapterConfig.chapterBadgeImg and chapterConfig.chapterBadgeImg ~= "")

	self.view.badgeUImage.url = chapterConfig.chapterBadgeImg or ""
end

function SpecialTrainNewCtrl:setChapterUpTitleInfo()
	local questId = QuestUtils.getChapterCourseQuestId(self.curChapterId)
	local assessmentId = QuestUtils.getAssessmentIdByUpgrade(questId)
	local star = QuestUtils.getChapterStar(self.curChapterId)
	local info = QuestUtils.checkCanUpGradeStarSpecialTrain(star, true)
	local isFinishCond = QuestUtils.isQuestSubmittedOrFinished(questId)
	local isUpTitleFinishCond = star <= LuaUIUtils.getPlayerStar()
	local chapterStateInfo = QuestUtils.getChapterState(self.curChapterId)
	local isVersionCapChapter = QuestUtils.isVersionCapChapter(self.curChapterId)
	local titleState = 0

	if isFinishCond then
		if QuestUtils.isVersionCapChapterFinished(self.curChapterId) then
			titleState = QuestConst.TRAIN_DETAIL_INFO_COMPULSORY_TYPE.VERSION_CAPPED
		elseif not isUpTitleFinishCond then
			titleState = isVersionCapChapter and QuestConst.TRAIN_DETAIL_INFO_COMPULSORY_TYPE.FINAL_ASSESSMENT or QuestConst.TRAIN_DETAIL_INFO_COMPULSORY_TYPE.UP_TITLE
		elseif not chapterStateInfo.canGetChapterReward then
			titleState = QuestConst.TRAIN_DETAIL_INFO_COMPULSORY_TYPE.FINISH
		end
	end

	if titleState == QuestConst.TRAIN_DETAIL_INFO_COMPULSORY_TYPE.UP_TITLE and not chapterStateInfo.isStarTitleQuestViewed and not isVersionCapChapter then
		self.view.rightCardUComponent:TryChangePage("PlayerTitle", 0)

		titleState = QuestConst.TRAIN_DETAIL_INFO_COMPULSORY_TYPE.GOTO_TITLE

		pg.me:viewSpecialTrainStarTitleQuest(self.curChapterId)
		self:startTimer(function()
			self.view.rightCardUComponent:TryChangePage("PlayerTitle", 1)
			self:setUpTitleInfo(assessmentId, star)
		end, 0.6)
	else
		self.view.rightCardUComponent:TryChangePage("PlayerTitle", titleState)
	end

	if titleState == QuestConst.TRAIN_DETAIL_INFO_COMPULSORY_TYPE.GOTO_TITLE then
		self:setCommonChapterImageInfo("chapterDes", true)
		self:setGotoTitleInfo(questId, star)
	elseif titleState == QuestConst.TRAIN_DETAIL_INFO_COMPULSORY_TYPE.UP_TITLE then
		self:setCommonChapterImageInfo("chapterDes")
		self.view.scrollText:SetActive(false)
		self:setUpTitleInfo(assessmentId, star)
	elseif titleState == QuestConst.TRAIN_DETAIL_INFO_COMPULSORY_TYPE.FINISH then
		self:setCommonChapterImageInfo("chapterDesUpstar", true)
		ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getGameString("PETSHAPE_HABITAT_FINISHED"))
	elseif titleState == QuestConst.TRAIN_DETAIL_INFO_COMPULSORY_TYPE.VERSION_CAPPED then
		self:setCommonChapterImageInfo("chapterDesUpstar", true)
		ClientTextUtils.setText(self.view.allTextUSDFText, pg.getGameString("SPECIAL_TRAIN_COMPULSORY_CAPPED"))

		local animPlayedKey = string.format("SPECIAL_TRAIN_REQUIRED_STORY_TITLE_DONE_PLAYED_%s", pg.me.uid)

		if not pg.global.prefsCacheUtils:getBool(animPlayedKey, false) then
			pg.global.prefsCacheUtils:setBool(animPlayedKey, true)
		end
	elseif titleState == QuestConst.TRAIN_DETAIL_INFO_COMPULSORY_TYPE.FINAL_ASSESSMENT then
		self:setCommonChapterImageInfo("chapterDes")
		self.view.scrollText:SetActive(false)
		self:setUpFinalTitleInfo(SysConfigData.SPECIALTRAIN_GRASS_ENDING_QUEST_JUMP, star)
	end
end

function SpecialTrainNewCtrl:setGotoTitleInfo(questId, star)
	function self.view.listUList.luaRenderItem(button, index, data)
		self:renderUpgradeQuestItem(button, index, data)
	end

	local objectives, firstUnfinishedIndex = QuestUtils.getReceivedQuestObjectives(questId, true)

	self.view.listUList:SetList(objectives)

	local coms = self.view:getBtnComs(self.view.btnExamineUButton)

	if coms then
		ClientTextUtils.setText(coms.nameText, pg.getGameString("SPECIAL_TRAIN_GOTO_UPTITLE"))
	end

	self.view.nationLevelUButton:SetActive(false)
	self:setCommonStarTitleDisplay(star)

	local titleText = string.format(pg.getGameString("SPECIAL_TRAIN_COMPULSORY_TITLE_LIMIT"), LuaUIUtils.getStarNeedLevel(star))
	local isVersionCapChapter = QuestUtils.isVersionCapChapter(self.curChapterId)

	if isVersionCapChapter then
		titleText = pg.getGameString("SPECIALTRAIN_GRASS_ENDING_QUEST_ACTION")
	end

	ClientTextUtils.setText(self.view.tipTextUSDFText, titleText)
end

function SpecialTrainNewCtrl:setCommonUpTitleAction(assessmentId)
	function self.view.btnUpUButton.luaClick(button, index, data)
		QuestUtils.traceSecondTracingQuest(assessmentId)
		pg.game.quest:setCurSelectQuestId(assessmentId)
		pg.global.ui.hudV2:openQuest()
		self:dismiss()
	end

	local showRedDot = not QuestUtils.isVersionCapChapterFinished(self.curChapterId) and QuestUtils.isCanUpgradeStar(self.curChapterId)
	local treePath = RedDotConst.RedDotPath.SPECIAL_TRAIN_TAB_TREE .. assessmentId

	pg.global.setRedDot(treePath, self.view.btnUpUButton, showRedDot, RedDotConst.RedDotStyle.POINT)
end

function SpecialTrainNewCtrl:setUpTitleInfo(assessmentId, star)
	self:setCommonStarTitleDisplay(star, true)
	self:setCommonUpTitleAction(assessmentId)

	function self.view.levelTipUList.luaRenderItem(button, index, data)
		local objectReference = button.transform:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local textUSDFText = objectReference:GetRefValue("textUSDFText")
		local text1USDFText = objectReference:GetRefValue("text1USDFText")
		local tipsText = data.playLevel and "SPECIAL_TRAIN_COMPULSORY_UP_LEVEL" or "SPECIAL_TRAIN_COMPULSORY_UP_PET_LEVEL"

		ClientTextUtils.setText(txtNameUSDFText, pg.getGameString(tipsText))
		ClientTextUtils.setText(textUSDFText, data.minLevel)
		ClientTextUtils.setText(text1USDFText, data.maxLevel)
	end

	local levelTipList = QuestUtils.getLevelTipList(star)

	self.view.levelTipUList:SetList(levelTipList)
	ClientTextUtils.setText(self.view.levelTipUSDFText, pg.getGameString("SPECIAL_TRAIN_COMPULSORY_UP_TIPS"))
	ClientTextUtils.setText(self.view.titleUpTips, pg.getGameString("SPECIAL_TRAIN_COMPULSORY_FINISH_TIPS"))
	ClientTextUtils.setText(self.view.titleUpText, pg.getGameString("SPECIAL_TRAIN_UPTITLE"))
end

function SpecialTrainNewCtrl:setUpFinalTitleInfo(assessmentId, star)
	self.view.bgUImage.url = LuaUIUtils.getStarIcon(star)

	ClientTextUtils.setText(self.view.textNameUSDFText, pg.getGameString("SPECIALTRAIN_GRASS_ENDING_QUEST_TITLE"))
	self:setCommonUpTitleAction(assessmentId)
	ClientTextUtils.setText(self.view.levelTipUSDFText, pg.getGameString("SPECIALTRAIN_GRASS_ENDING_QUEST_REWARD"))
	ClientTextUtils.setText(self.view.titleUpText, pg.getGameString("SPECIALTRAIN_GRASS_ENDING_QUEST_GOTO"))
end

function SpecialTrainNewCtrl:setCommonChapterImageInfo(desKey, isShowText)
	local chapterConfig = QuestUtils.getChapterConfig(self.curChapterId)

	if chapterConfig then
		if isShowText then
			self.view.scrollText:SetActive(true)
			ClientTextUtils.setText(self.view.scrollText.content, ClientTextUtils.getLocalizationText(chapterConfig[desKey]))
			self:bindScrollTextHyperlink(self.view.scrollText)
		end

		self:setChapterImageInfo(chapterConfig)
	end
end

function SpecialTrainNewCtrl:setCommonStarTitleDisplay(star, isUpTitle)
	self.view.bgUImage.url = LuaUIUtils.getStarIcon(star)

	ClientTextUtils.setText(self.view.numUSDFText, LuaUIUtils.getStarTitleNameForIcon(star))

	local tipsKey = isUpTitle and "SPECIAL_TRAIN_COMPULSORY_NEXT_IS" or "SPECIAL_TRAIN_COMPULSORY_TITLE_TIPS"
	local titleText = string.format(pg.getGameString(tipsKey), LuaUIUtils.getStarTitleName(star, true))
	local isVersionCapChapter = QuestUtils.isVersionCapChapter(self.curChapterId)

	if isVersionCapChapter then
		titleText = pg.getGameString("SPECIALTRAIN_GRASS_ENDING_QUEST_TITLE")
	end

	ClientTextUtils.setText(self.view.textNameUSDFText, titleText)
	self.view.textTtileUSDFText:SetActive(false)
end

function SpecialTrainNewCtrl:setElectiveTitleInfo()
	local typePageConfig = self.model:getTypePageConfig(self.curPage)

	if typePageConfig then
		self.view.bScrollText:SetActive(true)
		ClientTextUtils.setText(self.view.bScrollText.content, ClientTextUtils.getLocalizationText(typePageConfig.des))
		self:bindScrollTextHyperlink(self.view.bScrollText)

		self.view.bImgPic1UImage.url = typePageConfig.chapterImg or ""

		self.view.bImgPic1UImage:SetMaterial(typePageConfig.infoImgMaterial)

		local coms = self.view:getBtnComs(self.view.bBtnExamineUButton)

		if coms then
			ClientTextUtils.setText(coms.nameText, pg.getFormatText(pg.getGameString("SPECIAL_TRAIN_GOTO_MASTER_ROAD"), ClientTextUtils.getLocalizationText(typePageConfig.typeName)))
		end
	end

	local coms = self.view:getBtnComs(self.view.bBtnExamineUButton)

	if not coms then
		return
	end

	function self.view.bBtnExamineUButton.luaClick(button, index, data)
		LuaUIUtils.openPlayerEnhance({
			defaultTab = 1,
			defaultMode = 4,
			badgeTabIndex = typePageConfig.matchRoadType
		})
	end
end

function SpecialTrainNewCtrl:renderUpgradeQuestItem(button, index, data)
	local coms = self.view:getCourseItemComs(button)
	local questId = data.questId
	local isFined = data.isFined
	local desc = data.objConfig.desc
	local count = 0
	local questData = QuestUtils.getQuestData(questId)
	local totalTargetVal = QuestUtils.getQuestObjectiveTargetVal(questId, data.objId)
	local targetVal

	if isFined then
		targetVal = totalTargetVal
	else
		targetVal = data.objData and data.objData.currentCnt or 0
	end

	count = string.format("[%s/%s]", targetVal, totalTargetVal)

	ClientTextUtils.setText(coms.textUBaseText, count)

	desc = ClientTextUtils.getLocalizationText(desc, targetVal)

	local displayType = data.objConfig.displayType or 1

	if displayType == QuestConst.QUEST_OBJCV_DISPLAY_TYPE.SHOW_COUNTING then
		local countingStr = string.format("[%s/%s]", targetVal, totalTargetVal)

		desc = ClientTextUtils.concatByLanguage(desc, countingStr)
	end

	if data.objConfig.showCanSelect then
		desc = QuestUtils.questObjectiveCanSelect(desc)
	end

	if data.objData and data.objData.isComplete then
		button:TryChangePage("State", 1)
	else
		button:TryChangePage("State", 0)
	end

	if pg.game.setting:getShowDebugId() then
		ClientTextUtils.setText(coms.desc, string.format("%d-%d-%s", questId, data.objId, desc))
	else
		ClientTextUtils.setText(coms.desc, desc)
	end

	button.name = string.format("%d-%d", questId, data.objId)
end

function SpecialTrainNewCtrl:setChapterTips(flag)
	if flag then
		local tipTime = pg.global.prefsCacheUtils:getInt("chapterTipsTime", 0, ClientConst.CACHE_TYPE_FLAG.USER)

		if tipTime == 0 or os.time() - tipTime > CHAPTER_TIPS_TIME then
			pg.global.prefsCacheUtils:setInt("chapterTipsTime", os.time(), ClientConst.CACHE_TYPE_FLAG.USER)
			self.view.chapterTipsUWidget:SetActive(flag)
			ClientTextUtils.setText(self.view.chapterTextTips, pg.getGameString("SPECIAL_TRAIN_BUBBLE_C1"))
			self:startTimer(function()
				self.view.chapterTipsUWidget:SetActive(false)
			end, CHAPTER_TIPS_CLOSE_TIME)
		end
	else
		pg.global.prefsCacheUtils:setInt("chapterTipsTime", os.time(), ClientConst.CACHE_TYPE_FLAG.USER)
		self.view.chapterTipsUWidget:SetActive(false)
	end
end

function SpecialTrainNewCtrl:renderQuestItemInfo(button, index, data)
	local questItemsComs = self.view:getQuestItemComs(button)
	local questConfig = QuestUtils.getSpecialTrainConfig(data.questId)
	local questData = self.model:getSpecialTrainData(data.questId)

	if questItemsComs == nil or questData == nil or questConfig == nil then
		return
	end

	if self.playChangeAni and index == self.targetIdx then
		if questData.isCanGetReward then
			UIUtils.PlayAnimation(questItemsComs.widgetAnim, "VX_Ani_Train_CenterItem_Refresh03")
		else
			UIUtils.PlayAnimation(questItemsComs.widgetAnim, "VX_Ani_Train_CenterItem_Refresh01")
		end

		self.playChangeAni = false
		self.curQuestId = data.questId
	end

	questItemsComs.questItem.isSelected = self.curQuestId == data.questId

	function questItemsComs.questItem.luaClick()
		if self.curQuestId ~= questData.questId then
			self:resetQuestItemInfo(1)

			self.curSelectChapterId = 0

			self:setChapterTitleItemSelected(false)
		end

		self.curQuestId = questData.questId
		questItemsComs.questItem.isSelected = true
		self.preSelQuestItem = questItemsComs.questItem

		self:refreshRightDetail()
	end

	function questItemsComs.questItem.luaNavFocused()
		if questItemsComs.questItem then
			questItemsComs.questItem:OnClickSimulate()
		end
	end

	function questItemsComs.btnGetUButton.luaClick(isNavigationAutoSelect)
		if not isNavigationAutoSelect then
			self:getQuestItemReward(button, index, data)
		end
	end

	local curProgressText = ""

	if questConfig and questData then
		if questData.curProgress and questData.curProgress > 0 then
			curProgressText = questData.curProgress
		end

		button:TryChangePage("TrainType", 2)

		local desc = ClientTextUtils.getLocalizationText(questConfig.taskDes, curProgressText)

		if self:isCompulsoryPage() then
			local isSpecialTrainMain = QuestUtils.isSpecialTrainCompulsoryQuest(data.questId)

			if isSpecialTrainMain or QuestUtils.isSpecialTrainChallengeQuest(data.questId) then
				if isSpecialTrainMain then
					button:TryChangePage("TrainType", 0)
				else
					button:TryChangePage("TrainType", 1)
				end
			end
		end

		if pg.game.setting:getShowDebugId() then
			desc = string.format("%d-%s", questData.questId, desc)
		end

		if questData.displayType == QuestConst.QUEST_OBJCV_DISPLAY_TYPE.SHOW_COUNTING then
			local countingStr = string.format("[%s/%s]", questData.curProgress, questData.tagVar)

			desc = ClientTextUtils.concatByLanguage(desc, countingStr)
		end

		ClientTextUtils.setText(questItemsComs.questTitle, desc)

		function questItemsComs.listBadgeUList.luaRenderItem(button1, index, data)
			return
		end

		if questConfig.badgeNum < 1 then
			questItemsComs.listBadgeUList:SetList({})
		else
			questItemsComs.listBadgeUList:SetList(self.model:getQuestItemBadgeList(questConfig.badgeNum))
		end

		function questItemsComs.stageList.luaRenderItem(button1, index, data)
			if not data.isMain then
				button1:TryChangePage("Stage", (questData.stage > data.stage or questData.stage == data.stage and questData.rewardFlags) and 1 or 0)
			end
		end

		if data.isMain then
			questItemsComs.stageList:SetList({})
		else
			questItemsComs.stageList:SetList(self.model:getQuestPhaseList(questData.taskId))
		end

		local isTrack = pg.me.curTraceSecondQuest ~= nil and QuestUtils.getParentQuestId(data.questId) == pg.me.curTraceSecondQuest

		if isTrack then
			self.preTraceQuestId = data.questId
		end

		if questData.isCanGetReward then
			button:TryChangePage("State", 2)

			local coms = self.view:getBtnComs(questItemsComs.btnGetUButton)

			if coms then
				ClientTextUtils.setText(coms.nameText, pg.getGameString("CHARACTER_LEVEL_CLAIM"))
			end
		elseif questData.rewardFlags then
			button:TryChangePage("State", 1)
		elseif isTrack then
			button:TryChangePage("State", 3)
			ClientTextUtils.setText(questItemsComs.txtIngUSDFText, pg.getGameString("SPECIAL_TRAIN_IN_TRACK"))
		else
			button:TryChangePage("State", 0)

			local coms = self.view:getBtnComs(questItemsComs.btnTrack)

			if coms then
				ClientTextUtils.setText(coms.nameText, pg.getGameString("SPECIAL_TRAIN_TRACK"))
			end
		end

		questItemsComs.recommendUImage:SetActive(false)

		if self:isCompulsoryPage() then
			local isSpecialTrainMain = QuestUtils.isSpecialTrainCompulsoryQuest(data.questId)

			if isSpecialTrainMain or QuestUtils.isSpecialTrainChallengeQuest(data.questId) then
				if isSpecialTrainMain then
					button:TryChangePage("Recommend", 2)
				else
					button:TryChangePage("Recommend", 3)
				end
			else
				button:TryChangePage("Recommend", 0)
			end
		end

		if questConfig.recommendTask and questConfig.recommendTask > 0 then
			if not self:isCompulsoryPage() then
				questItemsComs.recommendUImage:SetActive(true)
				button:TryChangePage("Recommend", 1)
			end
		elseif not self:isCompulsoryPage() then
			button:TryChangePage("Recommend", 0)
		end

		self:refreshCanSeeRewardState(false)

		function questItemsComs.rewardList.luaRenderItem(button, index, data)
			LuaUIUtils.renderRewards(button, index, data)

			function button.luaNavFocused()
				if button then
					self:refreshCanSeeRewardState(true)
				end
			end
		end

		self:setSetItemRewardList(button, index, data)

		function questItemsComs.btnTrack.luaClick()
			self.curTraceQuestId = data.questId

			QuestUtils.traceSecondTracingQuest(questData.questId)
			self:handleTrackButtonClick(questData.questId)
			self:dismiss()
		end

		function questItemsComs.vxRewardGeneral.luaStartFly()
			pg.game.audio:triggerEvent("SFX_UI_SpecialTraining_Achieve02")
		end

		function questItemsComs.vxRewardGeneral.luaEndFly()
			if self.view == nil then
				return
			end

			local isGetBadgeMaxReward = self.model:isGetBadgeMaxReward()

			if isGetBadgeMaxReward then
				-- block empty
			elseif self.view.medalUWidget then
				self.view.medalUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
			end

			pg.game.audio:triggerEvent("SFX_UI_SpecialTraining_Achieve03")
			self:flushBadgeFlyProgress()
		end

		local treePath = string.format(RedDotConst.RedDotPath.SPECIAL_TRAIN_TAB_TREE_ITEM, questData.taskId or 0)

		if questData.isCanGetReward == nil then
			-- block empty
		end

		local canGet = questData.isCanGetReward

		if questData.rewardFlags == nil then
			-- block empty
		end

		local hasGet = questData.rewardFlags

		pg.global.setRedDot(treePath, questItemsComs.btnGetUButton, canGet and not hasGet, RedDotConst.RedDotStyle.REWARD)
	end
end

function SpecialTrainNewCtrl:setSetItemRewardList(button, index, data)
	local questItemsComs = self.view:getQuestItemComs(button)
	local questConfig = QuestUtils.getSpecialTrainConfig(data.questId)
	local questData = self.model:getSpecialTrainData(data.questId)

	if questData == nil or questItemsComs == nil then
		return
	end

	local rewardItems = {}
	local temp = LuaUIUtils.getRewardItemByDropId(questConfig.rewardId)

	if temp ~= nil and #temp > 0 then
		for i = 1, #temp do
			temp[i].trainType = questData.trainType
			temp[i].taskId = questData.taskId
			temp[i].buttonItem = button
			temp[i].questId = questData.questId
			temp[i].hasGet = questData.rewardFlags
			temp[i].canGet = questData.isCanGetReward
			temp[i].showRedDot = temp[i].canGet and not temp[i].hasGet

			table.insert(rewardItems, temp[i])
		end
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("奖励配置不存在或者显示奖励没配！ rewardId", questData.rewardId)
	end

	questItemsComs.rewardList:SetList(rewardItems)
end

function SpecialTrainNewCtrl:getQuestItemReward(button, index, data)
	local questData = self.model:getSpecialTrainData(data.questId)

	if questData == nil then
		return
	end

	local canGet, hasGet = questData.isCanGetReward, questData.rewardFlags

	if canGet and not hasGet then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("getQuestItemReward")
		end

		self:onClickGetQuestItemReward(button, index, questData.taskId, data.questId)
	elseif self.breakPlayProgressAni[questData.taskId] then
		self:animRefreshQuestItem(questData.taskId)
	end
end

function SpecialTrainNewCtrl:onClickGetQuestItemReward(button, index, taskId, questId)
	if button == nil or taskId == nil or questId == nil then
		return
	end

	pg.game.audio:triggerEvent("SFX_UI_SpecialTraining_Achieve01")

	self.breakPlayProgressAni[taskId] = true

	local questList = self.model:getAllCanGetSpecialTrainRewardList(self.curChapterId, self.curPage)
	local flyIdxList = {}
	local allData = self.view.listCenterUList.itemData

	if allData then
		for idx, itemD in pairs(allData) do
			if itemD and self.model:redDot_CheckHasQuestCanGet(itemD) then
				table.insert(flyIdxList, idx)
			end
		end
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("onClickGetQuestItemReward")
	end

	pg.me:getSpecialTrainEntryReward(questList, QuestConst.SPECIAL_TRAIN_REWARD_SRC_TYPE.HANDBOOK, function(ret)
		self:beginWaitBadgeFlyProgress()

		local hasBadgeFly = false

		if #flyIdxList > 0 then
			for i, idx in ipairs(flyIdxList) do
				hasBadgeFly = self:flyBadgeSequence(idx, 1) or hasBadgeFly

				if i == #flyIdxList and self.view and self.view.listCenterUList then
					self:setCenterInfo()
				end
			end
		else
			hasBadgeFly = self:flyBadgeSequence(index, 1)
		end

		if not hasBadgeFly then
			self:flushBadgeFlyProgress()
		end

		self:refreshRightDetail()

		if self.view then
			self:setRequiredPageName()
		end
	end)
end

function SpecialTrainNewCtrl:resetQuestItemInfo(infoType)
	if infoType == 1 and not IsNil(self.preSelQuestItem) then
		self.preSelQuestItem.isSelected = false
	end
end

function SpecialTrainNewCtrl:animRefreshQuestItem(taskId)
	self.taskId = taskId or 0
	self.playProgressAni = true
	self.playChangeAni = true

	self:changeQuestItemPhase()

	self.breakPlayProgressAni[taskId] = false
end

function SpecialTrainNewCtrl:refreshQuestItem(taskId)
	local allData = self.view.listCenterUList.itemData
	local targetIdx

	for idx, data in pairs(allData) do
		if data.taskId == taskId then
			targetIdx = idx

			break
		end
	end

	self.playAni = false

	if targetIdx then
		self.view.listCenterUList:RefreshElement(targetIdx)
	end

	self.targetIdx = targetIdx
end

function SpecialTrainNewCtrl:refreshQuestItemByQuestId(questId)
	if not questId then
		return
	end

	local allData = self.view.listCenterUList.itemData

	for idx, data in pairs(allData) do
		if data.questId == questId then
			self.view.listCenterUList:RefreshElement(idx)

			return
		end
	end
end

function SpecialTrainNewCtrl:refreshTrackedItems()
	local prevId = self.preTraceQuestId
	local currId = self.curTraceQuestId

	if currId then
		self.preTraceQuestId = currId
		self.curTraceQuestId = nil
	end

	self.playAni = false

	self:refreshQuestItemByQuestId(prevId)

	if currId and currId ~= prevId then
		self:refreshQuestItemByQuestId(currId)
	end
end

function SpecialTrainNewCtrl:refreshRightDetail()
	local isSelQuestItem = self.curQuestId and self.curQuestId ~= 0
	local isSelectChapter = self.curSelectChapterId and self.curSelectChapterId ~= 0
	local state = QuestConst.TRAIN_DETAIL_INFO_TYPE.CHAPTER_INFO

	if isSelectChapter and not isSelQuestItem then
		state = QuestConst.TRAIN_DETAIL_INFO_TYPE.CHAPTER_INFO
	else
		state = isSelQuestItem and QuestConst.TRAIN_DETAIL_INFO_TYPE.QUEST_INFO or QuestConst.TRAIN_DETAIL_INFO_TYPE.CHAPTER_INFO
	end

	self.view.rightCardUComponent:TryChangePage("Type", state)
	self.view.rightCardUComponent:TryChangePage("Reach", 0)
	self:setRightInfo(state)

	self.preRightState = state

	self:setBigRewardInfo()
end

function SpecialTrainNewCtrl:setRightInfo(state)
	self.view.btnViewUButton:SetActive(false)
	self.view.btnTrackUButton:SetActive(false)
	self:setChapterTitleItemSelected(false)

	if state == QuestConst.TRAIN_DETAIL_INFO_TYPE.FINAL_REWARD then
		function self.view.btnMoreUButton.luaClick()
			self.view.root:TryChangePage("Details", 1)
			pg.game.audio:triggerEvent("SFX_UI_SpecialTraining_OpenAward")
			self.detailComponent:onShow()
			self.detailComponent:refreshResearchBtn()
		end

		ClientTextUtils.setText(self.view.moreTextUSDFText, pg.getGameString("CONSOLE_BAR_VIEW"))

		if self.isMobile then
			self.view.ImgPet:SetActive(true)
			LuaUIUtils.setUIViewVisible(self.view.rawImgPetRawImagePro, false)
		else
			self.view.ImgPet:SetActive(false)
			LuaUIUtils.setUIViewVisible(self.view.rawImgPetRawImagePro, true)
			self:setPetRTInfo()
		end

		ClientTextUtils.setText(self.view.txtNumUBaseText, ClientTextUtils.concatByLanguage("", self.model:getBadgeMaxNum()))
	elseif state == QuestConst.TRAIN_DETAIL_INFO_TYPE.QUEST_INFO then
		local questConfig = QuestUtils.getSpecialTrainConfig(self.curQuestId)
		local questData = self.model:getSpecialTrainData(self.curQuestId)

		if not questConfig or not questData then
			return
		end

		if self:isCompulsoryPage() then
			self:setQuestDetailRightInfo(questConfig, questData, {
				txtTitle2UBaseText = self.view.txtTitle2UBaseText,
				txtContent2UBaseText = self.view.txtContent2UBaseText,
				scrollText = self.view.scrollText,
				descText = self.view.txtContent3USDFText,
				btnTrack = self.view.btnTrackUButton,
				btnView = self.view.btnViewUButton,
				btnButton = self.view.buttonUButton,
				imgPicUImage = self.view.imgPicUImage,
				reachUSDFText = self.view.txtReachUSDFText,
				layoutBoxUWidget = self.view.layoutBoxUWidget,
				imgPic1UImage = self.view.imgPic1UImage
			})
		else
			self:setQuestDetailRightInfo(questConfig, questData, {
				txtTitle2UBaseText = self.view.bTxtTitle2UBaseText,
				txtContent2UBaseText = self.view.bTxtContent2UBaseText,
				scrollText = self.view.bScrollText,
				descText = self.view.bTxtContent3USDFText,
				btnTrack = self.view.bBtnTrackUButton,
				btnView = self.view.bBtnViewUButton,
				btnButton = self.view.bButtonUButton,
				imgPicUImage = self.view.bImgPicUImage,
				reachUSDFText = self.view.bTxtReachUSDFText,
				layoutBoxUWidget = self.view.bLayoutBoxUWidget,
				imgPic1UImage = self.view.bImgPic1UImage
			})
		end
	elseif state == QuestConst.TRAIN_DETAIL_INFO_TYPE.CHAPTER_INFO then
		self:setChapterTitleItemSelected(true)

		if self:isCompulsoryPage() then
			self.view.electiveStoryUWidget:SetActive(false)
			self:setChapterUpTitleInfo()

			if not self._isPlayingMainAnim and (self.lastAnimChapterId ~= self.curChapterId or self.lastPage ~= self.curPage) and pg.me.isOpenedTrainInterface then
				self.lastAnimChapterId = self.curChapterId
				self.lastPage = self.curPage

				if self.curChapterId == CHAPTER_INDEX_FIRST then
					UIUtils.PlayAnimation(self.view.rightCardAnimation, "VX_Ani_Train_RightCard_RequiredStory_Reset", function()
						UIUtils.PlayAnimation(self.view.rightCardAnimation, "VX_Ani_Train_RightCard_RequiredStory_In")
					end)
				else
					UIUtils.PlayAnimation(self.view.rightCardAnimation, "VX_Ani_Train_RightCard_RequiredStory_Reset", function()
						UIUtils.PlayAnimation(self.view.rightCardAnimation, "VX_Ani_Train_RightCard_RequiredStory_In02")
					end)
				end
			end
		else
			self.view.electiveStoryUWidget:SetActive(true)

			if not self._isPlayingMainAnim then
				if self.preRightState == QuestConst.TRAIN_DETAIL_INFO_TYPE.FINAL_REWARD then
					UIUtils.PlayAnimation(self.view.rightCardAnimation, "VX_Ani_Train_RightCard_ElectiveStory_Reset", function()
						UIUtils.PlayAnimation(self.view.rightCardAnimation, "VX_Ani_Train_RightCard_Change01")
					end)
				elseif self.lastPage ~= self.curPage then
					self.lastPage = self.curPage

					UIUtils.PlayAnimation(self.view.rightCardAnimation, "VX_Ani_Train_RightCard_ElectiveStory_Reset", function()
						UIUtils.PlayAnimation(self.view.rightCardAnimation, "VX_Ani_Train_RightCard_ElectiveStory_In")
					end)
				end
			end

			self:setElectiveTitleInfo()
		end
	end
end

function SpecialTrainNewCtrl:onRichTextLinkClick(action, content, infoText)
	LuaUIUtils.clickHyperText(action, content, infoText)
end

function SpecialTrainNewCtrl:bindScrollTextHyperlink(scrollRect)
	if IsNil(scrollRect) or IsNil(scrollRect.content) then
		return
	end

	local contentText = scrollRect.content:GetComponent("USDFText")

	if IsNil(contentText) then
		return
	end

	function contentText.luaOnHyperlinkClick(action, content)
		self:onRichTextLinkClick(action, content, contentText)
	end
end

function SpecialTrainNewCtrl:setChapterTitleItemSelected(flag)
	local chapterItemsComs

	if self:isCompulsoryPage() then
		chapterItemsComs = self.view:getChapterItemComs(self.view.chapterItemUButton)
	else
		chapterItemsComs = self.view:getChapterItemComs(self.view.electiveTitleUButton)
	end

	if chapterItemsComs then
		chapterItemsComs.chapterItem.isSelected = flag
	end
end

function SpecialTrainNewCtrl:setBadgeRewardInfo()
	local isGetBadgeMaxReward = self.model:isGetBadgeMaxReward()

	self.view.root:TryChangePage("Recycle", isGetBadgeMaxReward and 1 or 0)

	if isGetBadgeMaxReward then
		self:setBottomRewardExchangeInfo()
	else
		self:setBottomRewardInfo()
	end
end

function SpecialTrainNewCtrl:setBadgeProgressText(currentTotal)
	local displayValue = math.max(0, math.floor((currentTotal or 0) + 0.0001))

	self.badgeProgressDisplayValue = displayValue

	local progressText = "<b>" .. displayValue .. "</b>"

	ClientTextUtils.setText(self.view.curProgressUBaseText, progressText, "/", self.model:getBadgeMaxNum())
end

function SpecialTrainNewCtrl:testBadgeProgress(fromValue, toValue, delay)
	if not self.badgeProgressComponent then
		return false, "badgeProgressComponent is not ready"
	end

	local maxBadgeNum = self.model:getBadgeMaxNum()

	fromValue = math.max(0, math.min(maxBadgeNum, tonumber(fromValue) or 0))
	toValue = math.max(0, math.min(maxBadgeNum, tonumber(toValue) or maxBadgeNum))

	if toValue <= fromValue then
		return false, "toValue must be greater than fromValue"
	end

	self.badgeProgressTestState = {
		fromValue = fromValue,
		toValue = toValue
	}

	local success, err = self.badgeProgressComponent:testProgress(fromValue, toValue, delay, self.model:getBadgeListTab(1))

	if not success then
		self.badgeProgressTestState = nil
	end

	return success, err
end

function SpecialTrainNewCtrl:resetBadgeProgressTest()
	self.badgeProgressTestState = nil

	self:setBadgeRewardInfo()

	return true
end

function SpecialTrainNewCtrl:setQuestDetailRightInfo(questConfig, questData, uiRefs)
	local scrollComs = self.view:getScrollContentComs(uiRefs.layoutBoxUWidget)
	local contentText = scrollComs and scrollComs.txtContent2 or uiRefs.txtContent2UBaseText
	local descText = scrollComs and scrollComs.txtContent3 or uiRefs.descText

	uiRefs.scrollText:SetActive(false)
	uiRefs.layoutBoxUWidget:SetActive(false)
	ClientTextUtils.setText(uiRefs.txtTitle2UBaseText, pg.getLocalizationText(questConfig.taskName))
	ClientTextUtils.setText(contentText, pg.getLocalizationText(questConfig.help))
	ClientTextUtils.setText(descText, pg.getLocalizationText(questConfig.desc))

	function uiRefs.txtTitle2UBaseText.luaOnHyperlinkClick(action, content)
		self:onRichTextLinkClick(action, content, uiRefs.txtTitle2UBaseText)
	end

	function contentText.luaOnHyperlinkClick(action, content)
		self:onRichTextLinkClick(action, content, contentText)
	end

	function descText.luaOnHyperlinkClick(action, content)
		self:onRichTextLinkClick(action, content, descText)
	end

	uiRefs.layoutBoxUWidget.transform:SetSiblingIndex(LINK_LAYER)

	if self:isCompulsoryPage() then
		local chapterConfig = QuestUtils.getChapterConfig(self.curChapterId)

		if chapterConfig then
			uiRefs.imgPicUImage.url = chapterConfig.infoImg
			uiRefs.imgPicUImage.material = nil
		end
	else
		local typePageConfig = self.model:getTypePageConfig(self.curPage)

		if typePageConfig then
			uiRefs.imgPicUImage.url = typePageConfig.infoImg
		end
	end

	local coms = self.view:getBtnComs(uiRefs.btnTrack)

	if not coms then
		return
	end

	uiRefs.btnView:SetActive(questConfig.taskTeach and questConfig.taskTeach > 0 and not questData.isCanGetReward)
	ClientTextUtils.setText(coms.nameText, pg.getLocalizationText(questConfig.goToTxt))

	function uiRefs.btnView.luaClick()
		if questConfig.taskTeach then
			local courText = pg.getLocalizationText(questData.taskTeachName)
			local tipText = pg.getFormatText(pg.getGameString("ENTER_COURSE_CHECK"), courText)

			pg.global.showConfirmMsgRaw(pg.getGameString("RELEASE_WARN"), tipText, function()
				pg.me:startCourse(questConfig.taskTeach)
				self:dismiss()
			end, nil)
		end
	end

	uiRefs.btnButton:SetActive(false)

	local isDisabled = true

	if questConfig.goToCondition and questConfig.goToCondition[1] then
		isDisabled = ClientUtils.checkCondition(questConfig.goToCondition[1])

		uiRefs.btnButton:SetActive(isDisabled)

		function uiRefs.btnButton.luaClick()
			self:handleTrackButtonClick()
		end

		local coms1 = self.view:getBtnComs(uiRefs.btnButton)

		if coms1 then
			ClientTextUtils.setText(coms1.nameText, pg.getLocalizationText(questConfig.goToTxt))
		end
	end

	uiRefs.btnTrack:SetActive(questConfig.goTo ~= nil and not questData.isCanGetReward and isDisabled)
	ClientTextUtils.setText(uiRefs.reachUSDFText, pg.getGameString("PETSHAPE_HABITAT_FINISHED"))

	if questData.isCanGetReward then
		self.view.rightCardUComponent:TryChangePage("Reach", 0)
	elseif questData.rewardFlags then
		self.view.rightCardUComponent:TryChangePage("Reach", 1)
	else
		self.view.rightCardUComponent:TryChangePage("Reach", 0)
	end

	function uiRefs.btnTrack.luaClick()
		self:handleTrackButtonClick()
	end
end

function SpecialTrainNewCtrl:handleTrackButtonClick(questId)
	local curQuestId = questId or self.curQuestId
	local questConfig = QuestUtils.getSpecialTrainConfig(curQuestId)
	local questData = self.model:getSpecialTrainData(curQuestId)

	if not questConfig or not questData then
		return
	end

	if questConfig.goToCondition and questConfig.goToCondition[1] and not ClientUtils.checkCondition(questConfig.goToCondition[1]) then
		local node = pg.getLocalizationText(CustomTriggerData[questConfig.goToCondition[1]].note)

		if node and node ~= "" then
			pg.global.ui.tips:showTextTip(node)
		end

		return
	end

	local guideId = questConfig.guideId
	local goTo = questConfig.goTo
	local preGoTo = false

	if pg.game.guide:checkEnableGuide() and questConfig.preGuideId ~= nil and not GuideUtils.isGuidePlayed(questConfig.preGuideId) then
		guideId = questConfig.preGuideId
		goTo = questConfig.preGoTo or questConfig.goTo
		preGoTo = true
	end

	if QuestUtils.getParentQuestId(questData.questId) ~= QuestUtils.getSecondTracingQuestId() then
		QuestUtils.traceSecondTracingQuest(questData.questId)
	end

	if goTo == nil then
		return
	end

	LuaUIUtils.goToFromEvent({
		type = goTo[1],
		id = goTo[2],
		guideId = guideId,
		callback2 = function()
			self.gotoView = true

			if preGoTo then
				self:dismiss()
			end
		end,
		callback3 = function()
			self:dismiss()
		end
	})
end

function SpecialTrainNewCtrl:setBottomRewardInfo()
	self.badgeProgressTestState = nil

	self:setBadgeProgressText(pg.me.curBadgeCnt)

	local rewardList = self.model:getBadgeListTab(1)
	local isPlayingProgress = self.badgeProgressComponent:refresh(rewardList, pg.me.curBadgeCnt)

	if not isPlayingProgress then
		local _, index = self.model:getCurPhaseBadgeNum(1)

		index = index > 4 and index - 4 or 0

		self.view.rewardListUList:GoToIndex(index or 0)
	end
end

function SpecialTrainNewCtrl:onRefreshBadgeRewardItem(button, index, data, visualTotal)
	local itemComs = self.view:getBadgeRewardItemComs(button)

	ClientTextUtils.setText(itemComs.progressNum, data.badgeCollectNum)

	local itemData = self.model:getBadgeDataByStageID(data.stageId)
	local isProgressTest = self.badgeProgressTestState ~= nil

	if isProgressTest and itemData.rewardState ~= self.model.REWARD_CAN_GOT then
		if visualTotal ~= nil and visualTotal + 0.0001 >= data.badgeCollectNum then
			itemData.rewardState = self.model.REWARD_RECEIVED
		else
			itemData.rewardState = self.model.REWARD_NORMAL
		end
	elseif itemData.rewardState == self.model.REWARD_RECEIVED and visualTotal ~= nil and visualTotal + 0.0001 < data.badgeCollectNum then
		itemData.rewardState = self.model.REWARD_NORMAL
	end

	button:TryChangePage("type", data.isFinal and 1 or 0)

	if data.isFinal then
		-- block empty
	else
		self:setBadgeRewardList(itemComs.rewardItem, button, itemData, isProgressTest)
	end
end

function SpecialTrainNewCtrl:setBadgeRewardList(rewardItem, button, data, isProgressTest)
	local subData = {}
	local temp = LuaUIUtils.getRewardItemByDropId(data.satgeRewardId)

	if temp ~= nil and #temp > 0 then
		subData.num = temp[1].num
		subData.id = temp[1].id
		subData.type = temp[1].type

		if temp[1].type == 1 then
			subData.petId = temp[1].petId
		end

		subData.tIndex = temp[1].tIndex
	end

	local extraFunc
	local hasGet = data.rewardState == self.model.REWARD_CAN_GOT
	local canGet = data.rewardState == self.model.REWARD_RECEIVED

	if canGet and not hasGet and not isProgressTest then
		function extraFunc()
			pg.me:getSpecialTrainBadgeReward(data.isFinal, function(ret)
				pg.game.audio:triggerEvent("SFX_UI_SpecialTraining_Achieve01")
				self:setBottomRewardInfo()
			end)
		end
	end

	subData.canGet = canGet
	subData.hasGet = hasGet
	subData.extraFunc = extraFunc

	local treePath = string.format(RedDotConst.RedDotPath.SPECIAL_TRAIN_BADGE_LIST_ITEM, data.satgeRewardId or 0)
	local showRedDot = canGet and not hasGet

	pg.global.setRedDot(treePath, button, showRedDot, RedDotConst.RedDotStyle.REWARD)
	LuaUIUtils.renderRewards(rewardItem, nil, subData)
	button:TryChangePage("State", 0)

	if canGet then
		button:TryChangePage("State", 2)
	elseif hasGet then
		button:TryChangePage("State", 1)
	end

	self:refreshCanSeeRewardState(false)

	function rewardItem.luaNavFocused()
		if rewardItem then
			self:refreshCanSeeRewardState(true)
		end
	end
end

function SpecialTrainNewCtrl:setPetRTInfo()
	self.uiScene:previewPetByTId(templateId, not pg.me.isOpenedTrainInterface)
end

function SpecialTrainNewCtrl:setBigRewardInfo(visualTotal)
	local data = self.model:getBadgeDataByStageID(0)

	if not data then
		return
	end

	local hasGet = data.rewardState == self.model.REWARD_CAN_GOT
	local canGet = data.rewardState == self.model.REWARD_RECEIVED
	local maxBadgeNum = self.model:getBadgeMaxNum()

	visualTotal = visualTotal or self.badgeProgressVisualTotal

	if self.badgeProgressTestState and not hasGet then
		canGet = visualTotal ~= nil and maxBadgeNum <= visualTotal + 0.0001
	elseif canGet and visualTotal ~= nil and maxBadgeNum > visualTotal + 0.0001 then
		canGet = false
	end

	ClientTextUtils.setText(self.view.finishTxt, maxBadgeNum)

	if canGet then
		self.view.finalBadgeReward:TryChangePage("State", 2)
	elseif hasGet then
		self.view.finalBadgeReward:TryChangePage("State", 1)
	else
		self.view.finalBadgeReward:TryChangePage("State", 0)
	end

	local _, curIndex = self.view.rightCardUComponent:TryGetCurrentPage("Type")

	if curIndex == 0 then
		self.view.finalBadgeReward.isSelected = true
	else
		self:refreshCanSeeRewardState(false)

		self.view.finalBadgeReward.isSelected = false
	end

	function self.view.finalBadgeReward.luaNavFocused()
		if self.view.finalBadgeReward then
			self:refreshCanSeeRewardState(true)
		end
	end

	local treePath = string.format(RedDotConst.RedDotPath.SPECIAL_TRAIN_BADGE_LIST_ITEM, data.satgeRewardId or 0)
	local showRedDot = canGet and not hasGet

	pg.global.setRedDot(treePath, self.view.finalBadgeReward, showRedDot, RedDotConst.RedDotStyle.REWARD)
	facade:sendMsgToUI(MessageName.RED_DOT_SPECIAL_TRAIN_TREE)
end

function SpecialTrainNewCtrl:onClickBigRewardInfo(button)
	local data = self.model:getBadgeDataByStageID(0)

	if not data then
		return
	end

	local hasGet = data.rewardState == self.model.REWARD_CAN_GOT
	local canGet = data.rewardState == self.model.REWARD_RECEIVED

	if canGet and self.badgeProgressVisualTotal ~= nil and self.badgeProgressVisualTotal + 0.0001 < self.model:getBadgeMaxNum() then
		canGet = false
	end

	if canGet and not hasGet then
		local butterflyVar = ClientUtils.getCustomVariableValue(Const.SPECIAL_TRAIN_BUTTERFLY_CUSTOM_VARIABLE_ID)

		if butterflyVar <= 0 then
			pg.me:requestSetCustomVariable(Const.SPECIAL_TRAIN_BUTTERFLY_CUSTOM_VARIABLE_ID, 1)

			local questId = SysConfigData.badgeMaxRewardQuestId

			if questId and questId > 0 then
				pg.game.quest:forceTracedQuest(questId)
			end
		else
			self:jumpToButterflyQuestManual()
		end
	else
		if not self.view.finalBadgeReward.isSelected then
			self.curQuestId = 0

			self:resetQuestItemInfo(1)
			self.view.rightCardUComponent:TryChangePage("Type", 0)

			self.preRightState = QuestConst.TRAIN_DETAIL_INFO_TYPE.FINAL_REWARD

			self:setRightInfo(QuestConst.TRAIN_DETAIL_INFO_TYPE.FINAL_REWARD)
		end

		self.view.finalBadgeReward.isSelected = true
	end
end

function SpecialTrainNewCtrl:jumpToButterflyQuestManual()
	local questId = SysConfigData.badgeMaxRewardQuestId

	if questId and questId > 0 then
		local questGroupId = QuestUtils.isParentQuest(questId) and questId or QuestUtils.getRootQuestId(questId)

		if questGroupId and questGroupId > 0 then
			if not pg.global.ui:checkUIOpen(UIConst.UI_ID_QUEST_PANEL) then
				pg.global.ui:open(UIConst.UI_ID_QUEST_PANEL, {
					questId = questGroupId
				})
			end

			pg.game.quest:forceTracedQuest(questId)
		end
	end
end

function SpecialTrainNewCtrl:setBottomRewardExchangeInfo()
	local exchangeInfo = self.model:getExchangeInfo()
	local canExchange = exchangeInfo.canExchangeNum > 0
	local curBadgeCnt = "<b>" .. exchangeInfo.canExchangeCount .. "</b>"

	ClientTextUtils.setText(self.view.exchangeCurprogress, curBadgeCnt)

	function self.view.exchangeRewardUList.luaRenderItem(button1, index, data)
		local objectReference = button1.transform:GetComponent("ObjectReference")
		local progress = objectReference:GetRefValue("progress")

		if canExchange then
			progress.value = 1
		else
			progress.value = exchangeInfo.curRemaining < data.stage and 0 or 1
		end
	end

	self.view.exchangeRewardUList:SetList(exchangeInfo.rewardList)
	ClientTextUtils.setText(self.view.exchangeTextTip, string.format(pg.getGameString("SPECIAL_TRAIN_BADGE RECYCLE"), exchangeInfo.progressMax))
	self.view.textXNewUBaseText:SetActive(exchangeInfo.canExchangeNum > 0)
	self.view.textNewUBaseText:SetActive(false)

	if canExchange then
		ClientTextUtils.setText(self.view.textXNewUBaseText, string.format("X%s", exchangeInfo.canExchangeNum))
	end

	self:renderExchangeRewardItem(exchangeInfo.rewardId, canExchange)

	local treePath = string.format(RedDotConst.RedDotPath.SPECIAL_TRAIN_BADGE_LIST_ITEM, exchangeInfo.rewardId)

	pg.global.setRedDot(treePath, self.view.rewardUButton, canExchange, RedDotConst.RedDotStyle.REWARD)
end

function SpecialTrainNewCtrl:renderExchangeRewardItem(rewardId, canExchange)
	local objectReference = self.view.rewardUButton.transform:GetComponent("ObjectReference")
	local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
	local txtNumUBaseText = objectReference:GetRefValue("txtNumUText")
	local subData = {}
	local temp = LuaUIUtils.getRewardItemByDropId(rewardId)

	if temp ~= nil and #temp > 0 then
		subData.num = temp[1].num
		subData.id = temp[1].id
		subData.type = temp[1].type

		if temp[1].type == 1 then
			subData.petId = temp[1].petId
		end

		subData.tIndex = temp[1].tIndex
	end

	itemIconUImage.url = LuaUIUtils.getIconByItemId(subData.id)

	ClientTextUtils.setText(txtNumUBaseText, subData.num)

	local itemConfig = ItemData[subData.id]

	if itemConfig then
		self.view.rewardUButton:TryChangePage("Quality", itemConfig.quality)
	end

	self.view.rewardUButton.draggable = false

	function self.view.rewardUButton.luaClick()
		if canExchange then
			pg.me:getSpecialTrainBadgeContinuousReward(function(ret)
				self.exchangeRewardAni = true

				pg.game.audio:triggerEvent("SFX_UI_SpecialTraining_Achieve01")
				self:setBottomRewardExchangeInfo()
			end)
		else
			LuaUIUtils.onRewardItemClick(self.view.rewardUButton, subData)
		end
	end
end

function SpecialTrainNewCtrl:unlockSpecialTrainVX()
	if not pg.me.isOpenedTrainInterface then
		self.view.rightCardUComponent:TryChangePage("First", 1)
		pg.game.audio:triggerEvent("SFX_UI_SpecialTraining_Srart")
		self:startTimer(function()
			pg.me:firstOpenSpecialTrainInterface()
			pg.me:firstViewSpeicalTrainChapter(self.curChapterId)
		end, 2.3)
		UIUtils.PlayAnimation(self.view.panelAnimation, "VX_Ani_Train_Main_FirstIn", function()
			return
		end)
	else
		self._isPlayingMainAnim = true

		UIUtils.PlayAnimation(self.view.panelAnimation, "VX_Ani_Train_Main_In01", function()
			self._isPlayingMainAnim = false
		end)
	end
end

function SpecialTrainNewCtrl:exchangeProgressAddVX()
	UIUtils.PlayAnimation(self.view.recycleRewardPanelAnimation, "VX_Ani_Train_MainPanelNew_RecycleReward_Refresh", function()
		return
	end)
end

function SpecialTrainNewCtrl:cancelWaitBadgeFlyProgress()
	self.waitBadgeFlyProgress = false

	if self.badgeFlyProgressFallbackTimer then
		self:killTimer(self.badgeFlyProgressFallbackTimer)

		self.badgeFlyProgressFallbackTimer = nil
	end
end

function SpecialTrainNewCtrl:beginWaitBadgeFlyProgress()
	self:cancelWaitBadgeFlyProgress()

	self.waitBadgeFlyProgress = true
	self.badgeFlyProgressFallbackTimer = self:startTimer(function()
		self.badgeFlyProgressFallbackTimer = nil

		self:flushBadgeFlyProgress()
	end, BADGE_FLY_PROGRESS_FALLBACK_TIME)
end

function SpecialTrainNewCtrl:flushBadgeFlyProgress()
	if not self.waitBadgeFlyProgress then
		return
	end

	self:cancelWaitBadgeFlyProgress()

	if self.view then
		self:setBadgeRewardInfo()
	end
end

function SpecialTrainNewCtrl:flyBadgeSequence(idx, index)
	if not self.view or not self.view.listCenterUList then
		return false
	end

	local flag, button = self.view.listCenterUList:TryGetChildAt(idx)
	local data = self.view.listCenterUList:GetData(idx)

	if not flag or not button or not data then
		return false
	end

	local questConfig = QuestUtils.getSpecialTrainConfig(data.questId)

	if not questConfig or index > questConfig.badgeNum then
		return false
	end

	local coinCount = 1
	local objectReference = button:GetComponent("ObjectReference")
	local sourGeneral = objectReference:GetRefValue("listBadgeUList")
	local vxRewardGeneral = objectReference:GetRefValue("vxRewardGeneral")

	if not sourGeneral or not vxRewardGeneral then
		return false
	end

	local isGetBadgeMaxReward = self.model:isGetBadgeMaxReward()

	if isGetBadgeMaxReward then
		vxRewardGeneral.subParent = self.view.exchangeFlyNodeUWidget.transform
		vxRewardGeneral.targetPosition = self.view.exchangeFlyNodeUWidget.transform.position
	else
		vxRewardGeneral.subParent = self.view.flyNodeUWidget.transform
		vxRewardGeneral.targetPosition = self.view.flyNodeUWidget.transform.position
	end

	vxRewardGeneral.sourcePosition = sourGeneral.position

	vxRewardGeneral:PlayCoin(coinCount)

	for _ = 1, coinCount do
		pg.game.audio:playEvent("SFX_UI_SubmitPoint")
	end

	self:startTimer(function()
		self:flyBadgeSequence(idx, index + 1)
	end, 0.03)

	return true
end

function SpecialTrainNewCtrl:onHandleOnCloseUI(uid)
	if self.view and uid == UIConst.UI_ID_COMMON_OBTAIN and self.playChangeAni then
		if self.exchangeRewardAni then
			self.exchangeRewardAni = false

			self:exchangeProgressAddVX()
		end

		self:changeQuestItemPhase()
	end
end

function SpecialTrainNewCtrl:changeQuestItemPhase()
	if self.view and self.taskId and self.taskId > 0 then
		self:refreshQuestItem(self.taskId)
	end
end

function SpecialTrainNewCtrl:onQuestTraceChange(data)
	if self.view and pg.me.isOpenedTrainInterface then
		self:refreshTrackedItems()
	end
end

function SpecialTrainNewCtrl:refreshCanSeeRewardState(flag)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ConsoleBar_A_Reward", flag)
end

function SpecialTrainNewCtrl:onVisibleChange(visible)
	if self.uiScene and not self.isMobile then
		self.uiScene:entActive(visible)
	end

	if visible and self.gotoView then
		self.gotoView = false

		if self.view and self.curChapterId and self.curChapterId > 0 then
			self:setTopChapterInfo()
			self:setCenterInfo()

			if not self.isMobile then
				self.uiScene:playPetIdle()
			end
		end
	end
end

function SpecialTrainNewCtrl:refreshCurList()
	if self.view then
		if self.isParentSyncFin and self.isCompulsoryQuest then
			self.isParentSyncFin = false
			self.isCompulsoryQuest = false
			self.curPage = self.model:getSelectPageIndex() or QuestConst.QUEST_TRAIN_SUB_TYPE.COMPULSORY
			self.chapterTotalNum = QuestUtils.getChapterMaxIndex()

			self:setTypePageName()
			self:setTopChapterInfo()
		else
			self:setRequiredPageName()
		end

		self:refreshRightDetail()
	end
end

function SpecialTrainNewCtrl:isCanShowTraceSecondQuestFunc(questId)
	local questData = self.model:getSpecialTrainData(questId)
	local questConfig = QuestUtils.getSpecialTrainConfig(questId)

	if questData.isCanGetReward == nil then
		-- block empty
	end

	local canGet = questData.isCanGetReward

	if questData.rewardFlags == nil then
		-- block empty
	end

	local hasGet = questData.rewardFlags

	if canGet and not hasGet then
		return questData, questConfig
	elseif questConfig then
		if not questConfig.goTo or not questConfig.goTo[1] then
			return
		end

		if questConfig.goToCondition and questConfig.goToCondition[1] and not ClientUtils.checkCondition(questConfig.goToCondition[1]) then
			return
		end
	end

	return questData, questConfig
end

return SpecialTrainNewCtrl
