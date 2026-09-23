-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Quest\\QuestView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local QuestView = Class.LightClass("QuestView", UIView)

function QuestView:findObjects()
	return
end

function QuestView:registerObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.closeBtn = objectReference:GetRefValue("closeBtn")
	self.mainComponent = objectReference:GetRefValue("mainComponent")
	self.mainBg = objectReference:GetRefValue("mainBg")
	self.keyListUList = objectReference:GetRefValue("keyListUList")
	self.root = objectReference:GetRefValue("root")
	self.topBarLeftHotKeyContent = objectReference:GetRefValue("topBarLeftHotKeyContent")
	self.topBarRightHotKeyContent = objectReference:GetRefValue("topBarRightHotKeyContent")
	self.mainStoryOR = objectReference:GetRefValue("mainStoryOR")
	self.rawImageUIBlurEffect = objectReference:GetRefValue("rawImageUIBlurEffect")
	self.tabList = objectReference:GetRefValue("tabList")
	self.rootAni = objectReference:GetRefValue("rootAni")
	self.knowledgeBtn = objectReference:GetRefValue("knowledgeBtn")
end

function QuestView:initView()
	return
end

function QuestView:initMainStoryPanel()
	if self.mainPanel ~= nil then
		return
	end

	self.rewardList = self.mainStoryOR:GetRefValue("rewardList")
	self.trackingBtn = self.mainStoryOR:GetRefValue("trackingBtn")
	self.taskObjectiveList = self.mainStoryOR:GetRefValue("taskObjectiveList")
	self.mainPanel = self.mainStoryOR:GetRefValue("mainPanel")
	self.untrackingBtn = self.mainStoryOR:GetRefValue("untrackingBtn")
	self.nextBtn = self.mainStoryOR:GetRefValue("nextBtn")
	self.preBtn = self.mainStoryOR:GetRefValue("preBtn")
	self.questDescTxt = self.mainStoryOR:GetRefValue("questDescTxt")
	self.titleTxt = self.mainStoryOR:GetRefValue("titleTxt")
	self.chapterTypeList = self.mainStoryOR:GetRefValue("chapterTypeList")
	self.chapterTxt = self.mainStoryOR:GetRefValue("chapterTxt")
	self.evaluationUnTrack = self.mainStoryOR:GetRefValue("evaluationUnTrack")
	self.evaluationUnTrackTips = self.mainStoryOR:GetRefValue("evaluationUnTrackTips")
	self.examineListUWidget = self.mainStoryOR:GetRefValue("examineListUWidget")
	self.skillRewardList = self.mainStoryOR:GetRefValue("skillRewardList")
	self.skillPointRewardList = self.mainStoryOR:GetRefValue("skillPointRewardList")
	self.sourceBtn = self.mainStoryOR:GetRefValue("sourceBtn")
	self.sourceBtnTxt = self.mainStoryOR:GetRefValue("sourceBtnTxt")
	self.questLocationTxt = self.mainStoryOR:GetRefValue("questLocationTxt")
	self.filterBtn = self.mainStoryOR:GetRefValue("filterBtn")
	self.filterBtnTxt = self.mainStoryOR:GetRefValue("filterBtnTxt")
	self.filterDeleteBtn = self.mainStoryOR:GetRefValue("filterDeleteBtn")
	self.btnAlreadyTrackingUButton = self.mainStoryOR:GetRefValue("btnAlreadyTrackingUButton")
	self.forbidText = self.mainStoryOR:GetRefValue("forbidText")
	self.chapterRewardTtile = self.mainStoryOR:GetRefValue("chapterRewardTtile")
	self.chapterRewardViewUButton = self.mainStoryOR:GetRefValue("chapterRewardViewUButton")
	self.chapterRewardProgress = self.mainStoryOR:GetRefValue("chapterRewardProgress")
	self.chapterRewardListUList = self.mainStoryOR:GetRefValue("chapterRewardListUList")
	self.chapterTextUSDFText = self.mainStoryOR:GetRefValue("chapterTextUSDFText")
	self.locationInfoUSDFText = self.mainStoryOR:GetRefValue("locationInfoUSDFText")
	self.titleInfoUSDFText = self.mainStoryOR:GetRefValue("titleInfoUSDFText")
	self.taskUSDFText = self.mainStoryOR:GetRefValue("taskUSDFText")
	self.listUList = self.mainStoryOR:GetRefValue("listUList")
	self.list1UList = self.mainStoryOR:GetRefValue("list1UList")
	self.skillListUList = self.mainStoryOR:GetRefValue("skillListUList")
	self.layoutExamineUWidget = self.mainStoryOR:GetRefValue("layoutExamineUWidget")
	self.skillPointListUList = self.mainStoryOR:GetRefValue("skillPointListUList")
	self.chapterUWidget = self.mainStoryOR:GetRefValue("chapterUWidget")
	self.btnClueUButton = self.mainStoryOR:GetRefValue("btnClueUButton")
	self.clueBgUImage = self.mainStoryOR:GetRefValue("clueBgUImage")
	self.clueTargetUImage = self.mainStoryOR:GetRefValue("clueTargetIconUImage")
	self.clueChapterText = self.mainStoryOR:GetRefValue("clueChapterText")
	self.clueLocationInfoText = self.mainStoryOR:GetRefValue("clueLocationInfoText")
	self.clueTitleInfoText = self.mainStoryOR:GetRefValue("clueTitleInfoText")
	self.clueTaskText = self.mainStoryOR:GetRefValue("clueTaskText")
	self.clueTargetIconUImage = self.mainStoryOR:GetRefValue("clueTargetIconUImage")
	self.clueTargetUSDFText = self.mainStoryOR:GetRefValue("clueTargetUSDFText")
	self.clueKeyRewardUSDFText = self.mainStoryOR:GetRefValue("clueKeyRewardUSDFText")
	self.clueTargetUList = self.mainStoryOR:GetRefValue("clueTargetUList")
	self.clueBtnFoldUpUButton = self.mainStoryOR:GetRefValue("clueBtnFoldUpUButton")
	self.clueBtnFoldKeyUContainer = self.mainStoryOR:GetRefValue("clueBtnFoldKeyUContainer")
	self.adventureGotoClueBtn = self.mainStoryOR:GetRefValue("adventureGotoClueBtn")
	self.targetUWidget = self.mainStoryOR:GetRefValue("targetUWidget")
	self.closeQuestTipBtn = self.mainStoryOR:GetRefValue("closeQuestTipBtn")
	self.clueCountdownUWidget = self.mainStoryOR:GetRefValue("clueCountdownUWidget")
	self.clueBtnUWidget = self.mainStoryOR:GetRefValue("clueBtnUWidget")
	self.clueUWidget = self.mainStoryOR:GetRefValue("clueUWidget")
	self.targetUSDFText = self.mainStoryOR:GetRefValue("targetUSDFText")
	self.targetUImage = self.mainStoryOR:GetRefValue("targetUImage")
	self.blurStaticUWidget = self.mainStoryOR:GetRefValue("blurStaticUWidget")
end

local mainStoryTabComs = {}

function QuestView:getChapterTabItem(btn)
	if mainStoryTabComs[btn] == nil then
		mainStoryTabComs[btn] = {}

		local objOR = btn:GetComponent("ObjectReference")

		mainStoryTabComs[btn].tabNameTxt = objOR:GetRefValue("tabNameTxt")
		mainStoryTabComs[btn].tabBtn = objOR:GetRefValue("tabBtn")
		mainStoryTabComs[btn].tabList = objOR:GetRefValue("tabList")
		mainStoryTabComs[btn].iconImg = objOR:GetRefValue("iconImg")
		mainStoryTabComs[btn].shadowIconImg = objOR:GetRefValue("shadowIconImg")
	end

	return mainStoryTabComs[btn]
end

local questChapterItemsComs = {}

function QuestView:getMainQuestChapterItemComs(btn)
	if questChapterItemsComs[btn] == nil then
		questChapterItemsComs[btn] = {}

		local objOR = btn:GetComponent("ObjectReference")

		questChapterItemsComs[btn].nameTxt = objOR:GetRefValue("nameTxt")
		questChapterItemsComs[btn].numTxt = objOR:GetRefValue("numberTxt")
		questChapterItemsComs[btn].ani = objOR:GetRefValue("ani")
		questChapterItemsComs[btn].locationTxt = objOR:GetRefValue("locationTxt")
		questChapterItemsComs[btn].clueTxt = objOR:GetRefValue("clueTxt")
		questChapterItemsComs[btn].closeTag = objOR:GetRefValue("closeTag")
		questChapterItemsComs[btn].closeTagText = objOR:GetRefValue("closeTagText")
	end

	return questChapterItemsComs[btn]
end

function QuestView:getMainQuestReginalAniItemComs(btn)
	if questChapterItemsComs[btn] == nil then
		questChapterItemsComs[btn] = {}

		local objOR = btn:GetComponent("ObjectReference")

		questChapterItemsComs[btn].nameTxt = objOR:GetRefValue("nameTxt")
		questChapterItemsComs[btn].photoBgImg = objOR:GetRefValue("photoBgImg")
		questChapterItemsComs[btn].petHeadImg = objOR:GetRefValue("petHeadImg")
		questChapterItemsComs[btn].ani = objOR:GetRefValue("ani")
	end

	return questChapterItemsComs[btn]
end

local mainQuestSectionItemsComs = {}

function QuestView:getMainQuestSectionItemComs(btn)
	if mainQuestSectionItemsComs[btn] == nil then
		mainQuestSectionItemsComs[btn] = {}

		local objectReference = btn.transform:GetComponent("ObjectReference")

		mainQuestSectionItemsComs[btn].sectionInfoTxt = objectReference:GetRefValue("sectionInfoTxt")
		mainQuestSectionItemsComs[btn].nameTxt = objectReference:GetRefValue("nameTxt")
		mainQuestSectionItemsComs[btn].tipTxt = objectReference:GetRefValue("tipTxt")
		mainQuestSectionItemsComs[btn].bgImg = objectReference:GetRefValue("bgImg")
		mainQuestSectionItemsComs[btn].petBgImg = objectReference:GetRefValue("petBgImg")
		mainQuestSectionItemsComs[btn].preChapterTxt = objectReference:GetRefValue("preChapterTxt")
		mainQuestSectionItemsComs[btn].nextChapterTxt = objectReference:GetRefValue("nextChapterTxt")
		mainQuestSectionItemsComs[btn].ani = objectReference:GetRefValue("ani")
	end

	return mainQuestSectionItemsComs[btn]
end

local mainQuestQuestObjItemsComs = {}

function QuestView:getMainQuestQuestObjItemComs(btn)
	if mainQuestQuestObjItemsComs[btn] == nil then
		mainQuestQuestObjItemsComs[btn] = {}

		local objectReference = btn.transform:GetComponent("ObjectReference")

		mainQuestQuestObjItemsComs[btn].contentTxt = objectReference:GetRefValue("contentTxt")
		mainQuestQuestObjItemsComs[btn].ani = objectReference:GetRefValue("ani")
		mainQuestQuestObjItemsComs[btn].btnPhone = objectReference:GetRefValue("btnPhone")
		mainQuestQuestObjItemsComs[btn].btnPhoneTxt = objectReference:GetRefValue("btnPhoneTxt")
		mainQuestQuestObjItemsComs[btn].progress = objectReference:GetRefValue("progressUProgress")
		mainQuestQuestObjItemsComs[btn].tagUImage = objectReference:GetRefValue("tagUImage")
		mainQuestQuestObjItemsComs[btn].tagTextUSDFText = objectReference:GetRefValue("textUSDFText")
	end

	return mainQuestQuestObjItemsComs[btn]
end

local questExamineRewardItemComs = {}

function QuestView:getMainQuestExamineRewardItemComs(btn)
	if questExamineRewardItemComs[btn] == nil then
		questExamineRewardItemComs[btn] = {}

		local objectReference = btn:GetComponent("ObjectReference")

		questExamineRewardItemComs[btn].name = objectReference:GetRefValue("name")
		questExamineRewardItemComs[btn].num = objectReference:GetRefValue("num")
		questExamineRewardItemComs[btn].btnExclamation = objectReference:GetRefValue("btnExclamation")
	end

	return questExamineRewardItemComs[btn]
end

local rewardMainItemsComs = {}

function QuestView:getQuestMainRewardItemComs(btn)
	if rewardMainItemsComs[btn] == nil then
		rewardMainItemsComs[btn] = {}

		local objectReference = btn.transform:GetComponent("ObjectReference")

		rewardMainItemsComs[btn].consoleSelected = objectReference:GetRefValue("consoleSelected")
		rewardMainItemsComs[btn].numTxt = objectReference:GetRefValue("txtNameUText")
		rewardMainItemsComs[btn].iconImg = objectReference:GetRefValue("iconUImage")
	end

	return rewardMainItemsComs[btn]
end

function QuestView:onDestroy()
	for k in next, mainStoryTabComs do
		mainStoryTabComs[k] = nil
	end

	for k in next, questChapterItemsComs do
		questChapterItemsComs[k] = nil
	end

	for k in next, mainQuestSectionItemsComs do
		mainQuestSectionItemsComs[k] = nil
	end

	for k in next, mainQuestQuestObjItemsComs do
		mainQuestQuestObjItemsComs[k] = nil
	end

	for k in next, questExamineRewardItemComs do
		questExamineRewardItemComs[k] = nil
	end

	for k in next, rewardMainItemsComs do
		rewardMainItemsComs[k] = nil
	end
end

return QuestView
