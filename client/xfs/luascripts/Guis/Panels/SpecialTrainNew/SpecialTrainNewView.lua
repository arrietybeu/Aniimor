-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SpecialTrainNew\\SpecialTrainNewView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local SpecialTrainNewView = Class.LightClass("SpecialTrainNewView", UIView)

function SpecialTrainNewView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.objectReference = objectReference
	self.topTitleMPUBaseText = objectReference:GetRefValue("topTitleMPUBaseText")
	self.listLeftTabUList = objectReference:GetRefValue("listLeftTabUList")
	self.sortTransform = objectReference:GetRefValue("sortTransform")
	self.PreferenceTxtName = objectReference:GetRefValue("PreferenceTxtName")
	self.rightCardUComponent = objectReference:GetRefValue("rightCardUComponent")
	self.btnMoreUButton = objectReference:GetRefValue("btnMoreUButton")
	self.moreTextUSDFText = objectReference:GetRefValue("moreTextUSDFText")
	self.curProgressUBaseText = objectReference:GetRefValue("curProgressUBaseText")
	self.rewardListUList = objectReference:GetRefValue("rewardListUList")
	self.finalRewardUComponent = objectReference:GetRefValue("finalRewardUComponent")
	self.progressUProgress = objectReference:GetRefValue("progressUProgress")
	self.finishTxt = objectReference:GetRefValue("finishTxt")
	self.btnBack = objectReference:GetRefValue("btnBack")
	self.finalBadgeReward = objectReference:GetRefValue("finalBadgeReward")
	self.detailRoot = objectReference:GetRefValue("detailRoot")
	self.rawImgPetRawImagePro = objectReference:GetRefValue("rawImgPetRawImagePro")
	self.mainUWidget = objectReference:GetRefValue("mainUWidget")
	self.flyNodeUWidget = objectReference:GetRefValue("flyNodeUWidget")
	self.medalAnimation = objectReference:GetRefValue("medalAnimation")
	self.medalUWidget = objectReference:GetRefValue("medalUWidget")
	self.txtNumUBaseText = objectReference:GetRefValue("txtNumUBaseText")
	self.root = objectReference:GetRefValue("root")
	self.nextBtnLeftUButton = objectReference:GetRefValue("btnLeftUButton")
	self.nextBtnRightUButton = objectReference:GetRefValue("btnRightUButton")
	self.exchangeFlyNodeUWidget = objectReference:GetRefValue("exchangeFlyNodeUWidget")
	self.exchangeMedal = objectReference:GetRefValue("exchangeMedal")
	self.exchangeRewardUList = objectReference:GetRefValue("exchangeRewardUList")
	self.exchangeCurprogress = objectReference:GetRefValue("exchangeCurprogress")
	self.exchangeTextTip = objectReference:GetRefValue("exchangeTextTip")
	self.textNewUBaseText = objectReference:GetRefValue("textNewUBaseText")
	self.rewardUButton = objectReference:GetRefValue("rewardUButton")
	self.textXNewUBaseText = objectReference:GetRefValue("textXNewUBaseText")
	self.chapterItemUButton = objectReference:GetRefValue("chapterItemUButton")
	self.electiveStoryUWidget = objectReference:GetRefValue("electiveStoryUWidget")
	self.electiveTitleUButton = objectReference:GetRefValue("electiveTitleUButton")
	self.listCenterUList = objectReference:GetRefValue("listCenter2UList")
	self.recycleRewardPanelAnimation = objectReference:GetRefValue("recycleRewardPanelAnimation")
	self.panelAnimation = objectReference:GetRefValue("panelAnimation")
	self.chapterTipsUWidget = objectReference:GetRefValue("chapterTipsUWidget")
	self.chapterTextTips = objectReference:GetRefValue("chapterTextTips")
	self.chapterTipsBtn = objectReference:GetRefValue("chapterTipsBtn")
	self.ImgPet = objectReference:GetRefValue("ImgPet")
	self.requiredTabUButton = objectReference:GetRefValue("requiredTabUButton")
	self.rightCardAnimation = objectReference:GetRefValue("rightCardAnimation")
	self.scrollText = objectReference:GetRefValue("scrollText")
	self.txtContent2UBaseText = objectReference:GetRefValue("txtContent2UBaseText")
	self.txtTitle2UBaseText = objectReference:GetRefValue("txtTitle2UBaseText")
	self.txtContent3USDFText = objectReference:GetRefValue("txtContent3USDFText")
	self.btnTrackUButton = objectReference:GetRefValue("btnGoToUButton")
	self.btnViewUButton = objectReference:GetRefValue("btnViewUButton")
	self.buttonUButton = objectReference:GetRefValue("buttonUButton")
	self.imgPicUImage = objectReference:GetRefValue("imgPicUImage")
	self.imgPic1UImage = objectReference:GetRefValue("imgPic1UImage")
	self.txtContentUBaseText = objectReference:GetRefValue("txtContentUBaseText")
	self.textNameUSDFText = objectReference:GetRefValue("textNameUSDFText")
	self.txtReachUSDFText = objectReference:GetRefValue("txtReachUSDFText")
	self.layoutBoxUWidget = objectReference:GetRefValue("layoutBoxUWidget")
	self.badgeUImage = objectReference:GetRefValue("badgeUImage")
	self.badgeBgUImage = objectReference:GetRefValue("badgeBgUImage")
	self.btnExamineUButton = objectReference:GetRefValue("btnExamineUButton")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.listUList = objectReference:GetRefValue("listUList")
	self.personalUImage = objectReference:GetRefValue("personalUImage")
	self.personal1UImage = objectReference:GetRefValue("personal1UImage")
	self.btnUpUButton = objectReference:GetRefValue("btnUpUButton")
	self.titleUpText = objectReference:GetRefValue("titleUpText")
	self.titleUpTips = objectReference:GetRefValue("titleUpTips")
	self.upPersonalUImage = objectReference:GetRefValue("personalUImage")
	self.upPersonal1UImage = objectReference:GetRefValue("personal1UImage")
	self.upPersonaltext = objectReference:GetRefValue("upPersonaltext")
	self.upPersonal1text = objectReference:GetRefValue("upPersonal1text")
	self.nationLevelUButton = objectReference:GetRefValue("nationLevelUButton")
	self.textTtileUSDFText = objectReference:GetRefValue("textTtileUSDFText")
	self.tipTextUSDFText = objectReference:GetRefValue("tipTextUSDFText")
	self.projectionUImage = objectReference:GetRefValue("projectionUImage")
	self.bgUImage = objectReference:GetRefValue("bgUImage")
	self.numUSDFText = objectReference:GetRefValue("numUSDFText")
	self.levelTipUList = objectReference:GetRefValue("levelTipUList")
	self.levelTipUSDFText = objectReference:GetRefValue("levelTipUSDFText")
	self.bScrollText = objectReference:GetRefValue("bScrollText")
	self.bTxtContent2UBaseText = objectReference:GetRefValue("bTxtContent2UBaseText")
	self.bTxtTitle2UBaseText = objectReference:GetRefValue("bTxtTitle2UBaseText")
	self.bTxtContent3USDFText = objectReference:GetRefValue("bTxtContent3USDFText")
	self.bBtnTrackUButton = objectReference:GetRefValue("bBtnGoToUButton")
	self.bBtnViewUButton = objectReference:GetRefValue("bBtnViewUButton")
	self.bButtonUButton = objectReference:GetRefValue("bButtonUButton")
	self.bBtnExamineUButton = objectReference:GetRefValue("bBtnExamineUButton")
	self.bImgPicUImage = objectReference:GetRefValue("bImgPicUImage")
	self.bImgPic1UImage = objectReference:GetRefValue("bImgPic1UImage")
	self.bTxtContentUBaseText = objectReference:GetRefValue("bTxtContentUBaseText")
	self.bTxtReachUSDFText = objectReference:GetRefValue("bTxtReachUSDFText")
	self.bLayoutBoxUWidget = objectReference:GetRefValue("bLayoutBoxUWidget")
	self.allTextUSDFText = objectReference:GetRefValue("allTextUSDFText")
	self.allTextTitleUSDFText = objectReference:GetRefValue("allTextTitleUSDFText")
end

local leftTabComs = {}

function SpecialTrainNewView:getTabItemComs(btn)
	if leftTabComs[btn] == nil then
		local objectReference = btn.transform:GetComponent("ObjectReference")

		leftTabComs[btn] = {}
		leftTabComs[btn].tabItemObj = objectReference
		leftTabComs[btn].button = btn
		leftTabComs[btn].name = objectReference:GetRefValue("txtNameNmlUSDFText")
		leftTabComs[btn].nameS = objectReference:GetRefValue("txtNameSelUSDFText")
		leftTabComs[btn].line = objectReference:GetRefValue("lineUWidget")
	end

	return leftTabComs[btn]
end

local questItemsComs = {}

function SpecialTrainNewView:getQuestItemComs(btn)
	if questItemsComs[btn] == nil then
		local objectReference = btn.transform:GetComponent("ObjectReference")

		questItemsComs[btn] = {}
		questItemsComs[btn].questItemObj = objectReference
		questItemsComs[btn].rootAni = objectReference:GetRefValue("rootAni")
		questItemsComs[btn].widgetAnim = objectReference:GetRefValue("vxAniAnimation")
		questItemsComs[btn].questItem = objectReference:GetRefValue("questItem")
		questItemsComs[btn].unlockCondition = objectReference:GetRefValue("unlockConditionUBaseText")
		questItemsComs[btn].questTitle = objectReference:GetRefValue("txtTitleUBaseText")
		questItemsComs[btn].detail = objectReference:GetRefValue("txtDetailsUBaseText")
		questItemsComs[btn].rewardList = objectReference:GetRefValue("listRewardUList")
		questItemsComs[btn].stageList = objectReference:GetRefValue("listStageUList")
		questItemsComs[btn].number = objectReference:GetRefValue("txtNumUBaseText")
		questItemsComs[btn].btnTrack = objectReference:GetRefValue("btnTrackUButton")
		questItemsComs[btn].btnGetUButton = objectReference:GetRefValue("btnGetUButton")
		questItemsComs[btn].vxRewardGeneral = objectReference:GetRefValue("vxRewardGeneral")
		questItemsComs[btn].listBadgeUList = objectReference:GetRefValue("listBadgeUList")
		questItemsComs[btn].recommendUImage = objectReference:GetRefValue("recommendUImage")
		questItemsComs[btn].txtIngUSDFText = objectReference:GetRefValue("txtIngUSDFText")
	end

	return questItemsComs[btn]
end

local chapterItemsComs = {}

function SpecialTrainNewView:getChapterItemComs(btn)
	if chapterItemsComs[btn] == nil then
		local objectReference = btn.transform:GetComponent("ObjectReference")

		chapterItemsComs[btn] = {}
		chapterItemsComs[btn].chapterItemObj = objectReference
		chapterItemsComs[btn].chapterItem = objectReference:GetRefValue("chapterItem")
		chapterItemsComs[btn].chapterTitle = objectReference:GetRefValue("txtTitleUBaseText")
		chapterItemsComs[btn].detail = objectReference:GetRefValue("txtDetailsUBaseText")
		chapterItemsComs[btn].rewardList = objectReference:GetRefValue("listRewardUList")
		chapterItemsComs[btn].stageList = objectReference:GetRefValue("listSliderUList")
		chapterItemsComs[btn].number = objectReference:GetRefValue("textNumUBaseText")
		chapterItemsComs[btn].iconUImage = objectReference:GetRefValue("iconUImage")
		chapterItemsComs[btn].tagText = objectReference:GetRefValue("tagText")
		chapterItemsComs[btn].txtIngUSDFText = objectReference:GetRefValue("txtIngUSDFText")
		chapterItemsComs[btn].btnGetUButton = objectReference:GetRefValue("btnGetUButton")
		chapterItemsComs[btn].mainDescText = objectReference:GetRefValue("textChapterUSDFText")
	end

	return chapterItemsComs[btn]
end

local electiveTitleComs = {}

function SpecialTrainNewView:getElectTitleComs(btn)
	if electiveTitleComs[btn] == nil then
		electiveTitleComs[btn] = {}

		local objectReference = btn.transform:GetComponent("ObjectReference")

		electiveTitleComs[btn].chapterItem = objectReference:GetRefValue("chapterItem")
		electiveTitleComs[btn].txtTitleUBaseText = objectReference:GetRefValue("txtTitleUBaseText")
		electiveTitleComs[btn].txtDetailsUBaseText = objectReference:GetRefValue("txtDetailsUBaseText")
		electiveTitleComs[btn].iconUImage = objectReference:GetRefValue("iconUImage")
	end

	return electiveTitleComs[btn]
end

local badgeRewardItemsComs = {}

function SpecialTrainNewView:getBadgeRewardItemComs(btn)
	if badgeRewardItemsComs[btn] == nil then
		badgeRewardItemsComs[btn] = {}

		local objectReference = btn.transform:GetComponent("ObjectReference")

		badgeRewardItemsComs[btn].progressNum = objectReference:GetRefValue("progressNum")
		badgeRewardItemsComs[btn].progress = objectReference:GetRefValue("progress")
		badgeRewardItemsComs[btn].rewardItemAnim = objectReference:GetRefValue("rewardItemAnim")
		badgeRewardItemsComs[btn].rewardItem = objectReference:GetRefValue("rewardItem")
		badgeRewardItemsComs[btn].progressItemObj = objectReference:GetRefValue("progressItemObj")
		badgeRewardItemsComs[btn].progressAnimation = objectReference:GetRefValue("progressAnimation")
		badgeRewardItemsComs[btn].finalRewardUButton = objectReference:GetRefValue("finalRewardUButton")
		badgeRewardItemsComs[btn].finalRewardAnimation = objectReference:GetRefValue("finalRewardAnimation")
	end

	return badgeRewardItemsComs[btn]
end

function SpecialTrainNewView:getDetailItemComs(btn)
	self.objectReference = btn:GetComponent("ObjectReference")
	self.imgOrientationUImage = self.objectReference:GetRefValue("imgOrientationUImage")
	self.txtNumUBaseText = self.objectReference:GetRefValue("txtNumUBaseText")
	self.txtNameUBaseText = self.objectReference:GetRefValue("txtNameUBaseText")
	self.txtDetailsUBaseText = self.objectReference:GetRefValue("txtDetailsUBaseText")
	self.listElementUList = self.objectReference:GetRefValue("listElementUList")
	self.txtRecommendUBaseText = self.objectReference:GetRefValue("txtRecommendUBaseText")
	self.listRecommendUList = self.objectReference:GetRefValue("listRecommendUList")
	self.hpNumberUBaseText = self.objectReference:GetRefValue("hpNumberUBaseText")
	self.attackNumberUBaseText = self.objectReference:GetRefValue("attackNumberUBaseText")
	self.defendNumberUBaseText = self.objectReference:GetRefValue("defendNumberUBaseText")
	self.quickNumberUBaseText = self.objectReference:GetRefValue("quickNumberUBaseText")
	self.magicDefendNumberUBaseText = self.objectReference:GetRefValue("magicDefendNumberUBaseText")
	self.magicAttackNumberUBaseText = self.objectReference:GetRefValue("magicAttackNumberUBaseText")
	self.hpUWidget = self.objectReference:GetRefValue("hpUWidget")
	self.attackUWidget = self.objectReference:GetRefValue("attackUWidget")
	self.defendUWidget = self.objectReference:GetRefValue("defendUWidget")
	self.quickUWidget = self.objectReference:GetRefValue("quickUWidget")
	self.magicDefendUWidget = self.objectReference:GetRefValue("magicDefendUWidget")
	self.magicAttackUWidget = self.objectReference:GetRefValue("magicAttackUWidget")
	self.imgPetUImage = self.objectReference:GetRefValue("imgPetUImage")
	self.featureTxtTitle = self.objectReference:GetRefValue("featureTxtTitle")
	self.featureListUList = self.objectReference:GetRefValue("featureListUList")
	self.skillTxtTitle = self.objectReference:GetRefValue("skillTxtTitle")
	self.listSkillUList = self.objectReference:GetRefValue("listSkillUList")
	self.skillUniqueUButton = self.objectReference:GetRefValue("skillUniqueUButton")
	self.uniqueSkillName = self.objectReference:GetRefValue("uniqueSkillName")
	self.uniqueIconSkillUImage = self.objectReference:GetRefValue("uniqueIconSkillUImage")
	self.skillExploreUButton = self.objectReference:GetRefValue("skillExploreUButton")
	self.iconExploreSkillUImage = self.objectReference:GetRefValue("iconExploreSkillUImage")
	self.iconExploreSkillName = self.objectReference:GetRefValue("iconExploreSkillName")
	self.txtTitle2UBaseText = self.objectReference:GetRefValue("txtTitle2UBaseText")
	self.actionTxtTitle = self.objectReference:GetRefValue("actionTxtTitle")
	self.listAbilityUList = self.objectReference:GetRefValue("listAbilityUList")
	self.listSpecificUList = self.objectReference:GetRefValue("listSpecificUList")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
end

local courseItemsComs = {}

function SpecialTrainNewView:getCourseItemComs(btn)
	if courseItemsComs[btn] == nil then
		courseItemsComs[btn] = {}

		local objectReference = btn.transform:GetComponent("ObjectReference")

		courseItemsComs[btn].rootBtn = objectReference:GetRefValue("rootBtn")
		courseItemsComs[btn].desc = objectReference:GetRefValue("txtNameUSDFText")
	end

	return courseItemsComs[btn]
end

local btnComs = {}

function SpecialTrainNewView:getBtnComs(btn)
	if btnComs[btn] == nil then
		local objectReference = btn:GetComponent("ObjectReference")

		btnComs[btn] = {}
		btnComs[btn].keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")
		btnComs[btn].nameText = objectReference:GetRefValue("txtNameUText")
	end

	return btnComs[btn]
end

local scrollContentComs = {}

function SpecialTrainNewView:getScrollContentComs(layoutBoxUWidget)
	if IsNil(layoutBoxUWidget) then
		return nil
	end

	local parent = layoutBoxUWidget.transform.parent
	local scrollRect = NotNil(parent) and parent:GetComponent("UScrollRect") or nil

	if IsNil(scrollRect) or IsNil(scrollRect.content) then
		return nil
	end

	local content = scrollRect.content
	local coms = scrollContentComs[layoutBoxUWidget]

	if coms == nil or coms.content ~= content or IsNil(coms.txtContent2) then
		local contentTrans = content.transform
		local txtContent2 = contentTrans:Find("TxtContent2")
		local txtContent3 = contentTrans:Find("TxtContent3")

		coms = {
			scrollRect = scrollRect,
			content = content,
			txtContent2 = NotNil(txtContent2) and txtContent2:GetComponent("USDFText") or nil,
			txtContent3 = NotNil(txtContent3) and txtContent3:GetComponent("USDFText") or nil
		}
		scrollContentComs[layoutBoxUWidget] = coms
	end

	return coms
end

function SpecialTrainNewView:registerObjects()
	return
end

function SpecialTrainNewView:initView()
	return
end

function SpecialTrainNewView:onDestroy()
	for k in next, leftTabComs do
		leftTabComs[k] = nil
	end

	for k in next, questItemsComs do
		questItemsComs[k] = nil
	end

	for k in next, chapterItemsComs do
		chapterItemsComs[k] = nil
	end

	for k in next, electiveTitleComs do
		electiveTitleComs[k] = nil
	end

	for k in next, badgeRewardItemsComs do
		badgeRewardItemsComs[k] = nil
	end

	for k in next, courseItemsComs do
		courseItemsComs[k] = nil
	end

	for k in next, btnComs do
		btnComs[k] = nil
	end

	for k in next, scrollContentComs do
		scrollContentComs[k] = nil
	end
end

return SpecialTrainNewView
