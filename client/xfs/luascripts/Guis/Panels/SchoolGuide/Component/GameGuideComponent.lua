-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SchoolGuide\\Component\\GameGuideComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("GameGuideComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local SchoolGuideConst = require("Common.Const.SchoolGuideConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local NoticeDef = require("Common.NoticeDef")
local Time = require("Core.Common.Time")
local GameEventData = require("Data.game_event_data")
local LevelRewardLinkedData = require("Data.level_reward_linked_data")
local ChestData = require("Data.chest_data")
local DropData = require("Data.drop_data")
local Utils = require("Common.Utils.Utils")
local ItemSourceData = require("Data.item_source_data")
local GameGuideComponent = Class.LightClass("GameGuideComponent", UIComponent)

function GameGuideComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.secondLevelTabUList = objectReference:GetRefValue("secondLevelTabUList")
	self.upWidget = objectReference:GetRefValue("upWidget")
	self.upTxt = objectReference:GetRefValue("upTxt")
	self.imoListUList = objectReference:GetRefValue("imoListUList")
	self.doubleDescribeUWidget = objectReference:GetRefValue("doubleDescribeUWidget")
	self.filterUWidget = objectReference:GetRefValue("filterUWidget")
	self.upRemainTimesTxt = objectReference:GetRefValue("upRemainTimesTxt")
	self.upUCountDown = objectReference:GetRefValue("upUCountDown")
end

function GameGuideComponent:initView()
	function self.secondLevelTabUList.luaRenderItem(button, index, data)
		self:renderSecondTab(button, index, data)
	end

	function self.imoListUList.luaRenderItem(button, index, data)
		if data.tIndex == self.model.IMO_LIST_ITEM_TINDEX.IMO then
			self:renderImoList(button, index, data)
		elseif data.tIndex == self.model.IMO_LIST_ITEM_TINDEX.MOCK_DIFF then
			self:renderMockDifficulty(button, index, data)
		end
	end
end

function GameGuideComponent:onDestroy()
	self.mainTabType = nil
	self.secondTabType = nil

	UIComponent.onDestroy(self)
end

function GameGuideComponent:enter(tabType, groupIndex)
	self.mainTabType = tabType

	local secondTabList = self.model:getSecondTabList(self.mainTabType)

	self.secondLevelTabUList:SetList(secondTabList)
	self.filterUWidget:SetActive(false)

	local targetIndex = self:_getSecondTabIndexByGroup(secondTabList, groupIndex)
	local res, firstTab = self.secondLevelTabUList:TryGetChildAt(targetIndex)

	if res then
		firstTab:OnClickSimulate()
	else
		self.secondTabType = nil

		self:refreshUI()
		self.imoListUList:SetList({})
	end

	self.view.widget:TryChangePage("Challenge", self.mainTabType == SchoolGuideConst.EventType.BattleChallenge and "Tower" or "Imo")
end

function GameGuideComponent:_getSecondTabIndexByGroup(secondTabList, groupIndex)
	if not groupIndex or not secondTabList then
		return 0
	end

	for i, data in ipairs(secondTabList) do
		if data.stageTypeGroup == groupIndex then
			return i - 1
		end
	end

	return 0
end

function GameGuideComponent:exit()
	self.view.widget:TryChangePage("Challenge", "Imo")
end

function GameGuideComponent:refreshUI()
	local commonList = self.model:getCommonList(self.mainTabType, self.secondTabType)

	self.view.widget:TryChangePage("Empty", commonList and #commonList > 0 and "Normal" or "Empty")

	if commonList and #commonList > 0 then
		self.imoListUList:SetList(commonList)
	end

	if self.mainTabType == SchoolGuideConst.EventType.BattleChallenge then
		if self.secondTabType == SchoolGuideConst.SecondPageType.MOCK then
			local isOpen, eventId = ActivityUtils.isOprActivityUpOpenByType(ActivityConst.EventType.MockBattle)

			self.doubleDescribeUWidget:SetActive(isOpen)

			if isOpen then
				local eventData = GameEventData[eventId]

				LuaUIUtils.setCountDownTime(self.upUCountDown, Utils.getConfigTimeOfArea(eventData, "tabEndDayTime"), UIConst.TimeType.Short)
				ClientTextUtils.setText(self.upTxt, pg.getGameString("SCHOOL_GUIDE_TRAIN_UP_TIP"))

				local remainCnt, totalCnt = ClientActivityUtils.getRogueRewardUpConfig()

				ClientTextUtils.setText(self.upRemainTimesTxt, string.format("%s/%s", remainCnt, totalCnt))
			end
		else
			self.doubleDescribeUWidget:SetActive(false)
		end
	else
		self.doubleDescribeUWidget:SetActive(false)
	end
end

function GameGuideComponent:renderSecondTab(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textUBaseText = objectReference:GetRefValue("textUBaseText")
	local describeUBaseText = objectReference:GetRefValue("describeUBaseText")
	local upWidget = objectReference:GetRefValue("upWidget")

	button:TryChangePage("IconType", data.iconType)
	ClientTextUtils.setText(textUBaseText, pg.getLocalizationText(data.tabTitle))
	ClientTextUtils.setText(describeUBaseText, pg.getLocalizationText(data.tabDescribe))

	if data.secondTabType == SchoolGuideConst.SecondPageType.MOCK then
		upWidget:SetActive(ActivityUtils.isOprActivityUpOpenByType(ActivityConst.EventType.MockBattle))
	else
		upWidget:SetActive(false)
	end

	function button.luaClick()
		if self.secondTabType == data.secondTabType then
			return
		end

		self.secondLevelTabUList:DeselectAll()
		self.secondLevelTabUList:SelectItem(index)

		self.secondTabType = data.secondTabType

		self:refreshUI()
	end
end

function GameGuideComponent:isLeaderSecondTab()
	local secondTabType = self.secondTabType

	return secondTabType == SchoolGuideConst.SecondPageType.LEADER or secondTabType == SchoolGuideConst.SecondPageType.LEADER_EVOLUTION or secondTabType == SchoolGuideConst.SecondPageType.LEADER_ASSIST or secondTabType == SchoolGuideConst.SecondPageType.LEADER_POTENTIAL
end

function GameGuideComponent:renderImoList(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local goUButton = objectReference:GetRefValue("goUButton")
	local bossCurrencyTxt = objectReference:GetRefValue("bossCurrencyTxt")
	local bossCurrencyIcon = objectReference:GetRefValue("bossCurrencyIcon")
	local leaderCurrencyIcon = objectReference:GetRefValue("leaderCurrencyIcon")
	local leaderCurrencyTxt = objectReference:GetRefValue("leaderCurrencyTxt")
	local mockPetIcon = objectReference:GetRefValue("mockPetIcon")
	local mockCurrencyIcon = objectReference:GetRefValue("mockCurrencyIcon")
	local mockCurrencyTxt = objectReference:GetRefValue("mockCurrencyTxt")
	local titleUBaseText = objectReference:GetRefValue("titleUBaseText")
	local describeUBaseText = objectReference:GetRefValue("describeUBaseText")
	local elementUButton = objectReference:GetRefValue("elementUButton")
	local downDesTxt = objectReference:GetRefValue("downDesTxt")
	local listRewardUList = objectReference:GetRefValue("listRewardUList")
	local bossLockIconUImage = objectReference:GetRefValue("bossLockIconUImage")
	local bossLockTxt = objectReference:GetRefValue("bossLockTxt")
	local leaderLockIconUImage = objectReference:GetRefValue("leaderLockIconUImage")
	local leaderLockTxt = objectReference:GetRefValue("leaderLockTxt")
	local mockLockIcon = objectReference:GetRefValue("mockLockIcon")
	local mockLockTxt = objectReference:GetRefValue("mockLockTxt")
	local mockLockInfoBtn = objectReference:GetRefValue("mockLockInfoBtn")
	local petHeadUImage = objectReference:GetRefValue("petHeadUImage")
	local rogueStarList = objectReference:GetRefValue("rogueStarList")
	local bossLockGo = objectReference:GetRefValue("bossLockGo")
	local leaderLockGo = objectReference:GetRefValue("leaderLockGo")
	local txtGoBtn1 = objectReference:GetRefValue("txtGoBtn1")
	local txtGoBtn2 = objectReference:GetRefValue("txtGoBtn2")
	local txtGoBtn3 = objectReference:GetRefValue("txtGoBtn3")
	local txtLv = objectReference:GetRefValue("txtLv")
	local txtLock = objectReference:GetRefValue("txtLock")
	local txtLock2 = objectReference:GetRefValue("txtLock2")
	local btnInfo1 = objectReference:GetRefValue("btnInfo1")
	local btnInfo2 = objectReference:GetRefValue("btnInfo2")
	local btnInfo3 = objectReference:GetRefValue("btnInfo3")
	local descLayoutBoxTransform = objectReference:GetRefValue("descLayoutBoxTransform")
	local descLineTransform = objectReference:GetRefValue("descLineTransform")

	function listRewardUList.luaRenderItem(b, i, rewardItemData)
		LuaUIUtils.renderRewardItem(b, rewardItemData)
	end

	local listTypeState

	listTypeState = data.isBoss and "Boss" or self.secondTabType == SchoolGuideConst.SecondPageType.MOCK and "Holographic" or "Leader"

	button:TryChangePage("ListType", listTypeState)
	button:TryChangePage("ListState", data.lock and "Lock" or "Normal")
	button:TryChangePage("Lv", "on")

	if data.lock then
		if data.isBoss then
			function bossLockGo.luaClick()
				LuaUIUtils.sendCustomLog(Const.BILogName.SCHOOL_GUIDE_MOCK, {
					pet_id = data.markStaticId
				})
				self:focusMark(data.sceneId, data.traceId)
			end
		elseif self:isLeaderSecondTab() then
			function leaderLockGo.luaClick()
				LuaUIUtils.sendCustomLog(Const.BILogName.SCHOOL_GUIDE_MOCK, {
					pet_id = data.markStaticId
				})
				self:focusMark(data.sceneId, data.traceId)
			end
		elseif self.secondTabType == SchoolGuideConst.SecondPageType.MOCK then
			function mockLockInfoBtn.luaClick()
				pg.global.showBubbleMessageById(NoticeDef.SCHOOL_GUIDE_MOCK_LOCK)
			end

			mockLockIcon.url = data.icon
		end

		local hasTips = data.stageBossTip

		btnInfo1.gameObject:SetActiveEx(hasTips)
		btnInfo2.gameObject:SetActiveEx(hasTips)
		btnInfo3.gameObject:SetActiveEx(hasTips)

		if hasTips then
			function btnInfo1.luaRenderTooltip(button, panel)
				local objectReference = panel:GetComponent("ObjectReference")
				local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

				ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.stageBossTip))
			end

			function btnInfo2.luaRenderTooltip(button, panel)
				local objectReference = panel:GetComponent("ObjectReference")
				local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

				ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.stageBossTip))
			end

			function btnInfo3.luaRenderTooltip(button, panel)
				local objectReference = panel:GetComponent("ObjectReference")
				local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

				ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.stageBossTip))
			end
		end
	else
		function goUButton.luaClick()
			if self.secondTabType == SchoolGuideConst.SecondPageType.MOCK then
				LuaUIUtils.sendCustomLog(Const.BILogName.SCHOOL_GUIDE_MOCK, {
					level_id = data.levelId
				})
				pg.global.ui:open(UIConst.UI_ID_TOWER_LEVEL_DETAIL, {
					levelId = data.levelId
				})
			elseif data.isBoss or self:isLeaderSecondTab() then
				LuaUIUtils.sendCustomLog(Const.BILogName.SCHOOL_GUIDE_MOCK, {
					pet_id = data.markStaticId
				})
				self:focusMark(data.sceneId, data.traceId)
			end
		end

		if data.isBoss then
			ClientTextUtils.setText(bossCurrencyTxt, data.currencyNum)

			bossCurrencyIcon.url = data.currencyIcon
		elseif self:isLeaderSecondTab() then
			ClientTextUtils.setText(leaderCurrencyTxt, data.currencyNum)

			leaderCurrencyIcon.url = data.currencyIcon
		elseif self.secondTabType == SchoolGuideConst.SecondPageType.MOCK then
			mockCurrencyIcon.url = data.currencyIcon

			ClientTextUtils.setText(mockCurrencyTxt, data.currencyNum)
		end
	end

	petHeadUImage.url = data.icon

	rogueStarList:SetActive(self.secondTabType == SchoolGuideConst.SecondPageType.MOCK)

	if self.secondTabType == SchoolGuideConst.SecondPageType.MOCK then
		function rogueStarList.luaRenderItem(starBtn, _, starData)
			starBtn:TryChangePage("finish", starData.finish and 1 or 0)
		end

		local temp = {}

		for i = 1, data.totalStarNum do
			table.insert(temp, {
				finish = i <= data.starNum
			})
		end

		rogueStarList:SetList(temp)
	end

	ClientTextUtils.setText(titleUBaseText, pg.getLocalizationText(data.title))

	if self.secondTabType == SchoolGuideConst.SecondPageType.MOCK then
		ClientTextUtils.setText(describeUBaseText, pg.getLocalizationText(data.describe))
	else
		local linkedData = LevelRewardLinkedData[data.markStaticId]
		local materials = linkedData and linkedData.materials

		ClientTextUtils.setText(describeUBaseText, materials and pg.getLocalizationText(materials) or "")
	end

	ClientTextUtils.setText(txtGoBtn1, pg.getGameString("SCHOOL_GUIDE_HEAD_GOTO_BUTTON"))
	ClientTextUtils.setText(txtGoBtn2, pg.getGameString("SCHOOL_GUIDE_HEAD_GOTO_BUTTON"))
	ClientTextUtils.setText(txtGoBtn3, pg.getGameString("SCHOOL_GUIDE_HEAD_GOTO_BUTTON"))
	ClientTextUtils.setText(txtLock, pg.getGameString("SCHOOL_GUIDE_HEAD_NOT_FOUND"))
	ClientTextUtils.setText(txtLock2, pg.getGameString("SCHOOL_GUIDE_HEAD_NOT_FOUND"))
	ClientTextUtils.setText(leaderLockTxt, pg.getGameString("SCHOOL_GUIDE_HEAD_NOT_FOUND"))
	ClientTextUtils.setText(bossLockTxt, pg.getGameString("SCHOOL_GUIDE_HEAD_NOT_FOUND"))
	ClientTextUtils.setText(mockLockTxt, pg.getGameString("SCHOOL_GUIDE_CRAFT_LOCK"))
	elementUButton:SetActive(data.element ~= nil)

	if data.element then
		LuaUIUtils.setElementButtonNew(elementUButton, data.element)
	end

	if data.downDes ~= "" then
		downDesTxt:SetActive(true)
		ClientTextUtils.setText(downDesTxt, pg.getLocalizationText(data.downDes))
	else
		downDesTxt:SetActive(false)
	end

	local rewardItems = data.rewardItems

	if rewardItems then
		listRewardUList:SetList(rewardItems)
	end

	local isLeaderOrBoss = self:isLeaderSecondTab() or data.isBoss

	if isLeaderOrBoss and txtLv and data.idInType then
		LuaUIUtils.requestMapPuppetLevel(data.idInType, function(level)
			local playerLevel = pg.me.level or 0
			local levelText = pg.getFormatText(pg.getGameString("SCHOOL_GUIDE_HEAD_LEVEL"), level)

			if playerLevel < level then
				levelText = pg.getFormatText(pg.getGameString("SCHOOL_GUIDE_HEAD_LEVEL_RED"), levelText)
			end

			ClientTextUtils.setText(txtLv, levelText)
		end)
	end

	if data.isBoss then
		descLayoutBoxTransform.gameObject:SetActiveEx(true)
		descLineTransform.gameObject:SetActiveEx(true)

		local remain, max = self:getChallengeLimit(data.markStaticId)

		ClientTextUtils.setText(describeUBaseText, pg.getFormatText(pg.getGameString("SCHOOL_GUIDE_BOSS_WEEK_LIMIT"), remain, max))
	else
		descLayoutBoxTransform.gameObject:SetActiveEx(false)
		descLineTransform.gameObject:SetActiveEx(false)
	end
end

function GameGuideComponent:getChallengeLimit(markStaticId)
	local useLimitMap = pg.me and pg.me.useLimitMap

	if not useLimitMap then
		return 0, 0
	end

	local levelLinkedData = LevelRewardLinkedData[markStaticId]
	local chestId = levelLinkedData and levelLinkedData.chestId

	if not chestId or chestId == 0 then
		return 0, 0
	end

	local chestData = ChestData[chestId]
	local rewardId = chestData and chestData.reward

	if not rewardId or rewardId == 0 then
		return 0, 0
	end

	local dropData = DropData[rewardId]
	local limitId = dropData and dropData.limitId

	if not limitId or limitId == 0 then
		return 0, 0
	end

	local totalCount = useLimitMap:getTotalCount(limitId)

	if not totalCount or totalCount <= 0 then
		return 0, 0
	end

	return useLimitMap:getRemainCount(limitId) or 0, totalCount
end

function GameGuideComponent:renderMockDifficulty(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textUBaseText = objectReference:GetRefValue("textUBaseText")

	button:TryChangePage("Difficulty", data.difficultyLv)
	ClientTextUtils.setText(textUBaseText, pg.getLocalizationText(data.title))
end

function GameGuideComponent:focusMark(sceneId, traceId)
	if not sceneId then
		pg.global.showBubbleMessageRaw(pg.getGameString("SCHOOL_GUIDE_TRACK_FAIL"))

		return
	end

	local sourceData = ItemSourceData[traceId]

	if sourceData then
		LuaUIUtils.clueSeek(sourceData)
	end
end

return GameGuideComponent
