-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\LittleFireFestivalComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("LittleFireFestivalComponent")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local RedDotConst = require("Const.RedDotConst")
local ActivityConst = require("Common.Const.ActivityConst")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local EventContainerComponent = require("Guis.Panels.Event.Component.EventContainerComponent")
local LittleFireFestivalComponent = Class.LightClass("LittleFireFestivalComponent", EventContainerComponent)

local function setTabHandsVisible(handLTransform, handRTransform)
	if handLTransform then
		handLTransform.localScale = Vector3.one
	end

	if handRTransform then
		handRTransform.localScale = Vector3.one
	end
end

function LittleFireFestivalComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	self.objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.eventTitleUContainer = self.objectReference:GetRefValue("eventTitleUContainer")
	self.rewardUList = self.objectReference:GetRefValue("rewardUList")
	self.tab1UButton = self.objectReference:GetRefValue("tab1UButton")
	self.tab2UButton = self.objectReference:GetRefValue("tab2UButton")
	self.tab1Animation = self.tab1UButton and self.tab1UButton:GetComponent("Animation")
	self.tab2Animation = self.tab2UButton and self.tab2UButton:GetComponent("Animation")
	self.tab1HandLTransform = self.tab1UButton and self.tab1UButton.transform:Find("Widget/Icon/HandL")
	self.tab1HandRTransform = self.tab1UButton and self.tab1UButton.transform:Find("Widget/Icon/HandR")
	self.tab2HandLTransform = self.tab2UButton and self.tab2UButton.transform:Find("Widget/Icon/HandL")
	self.tab2HandRTransform = self.tab2UButton and self.tab2UButton.transform:Find("Widget/Icon/HandR")

	local tab1BgSelTransform = self.tab1UButton and self.tab1UButton.transform:Find("Widget/BgSel")
	local tab2BgSelTransform = self.tab2UButton and self.tab2UButton.transform:Find("Widget/BgSel")

	self.tab1BgSelUImage = tab1BgSelTransform and tab1BgSelTransform:GetComponent("UImage")
	self.tab2BgSelUImage = tab2BgSelTransform and tab2BgSelTransform:GetComponent("UImage")
	self.progressUProgress = self.objectReference:GetRefValue("progressUProgress")
	self.totalNumTitleqUBaseText = self.objectReference:GetRefValue("totalNumTitleqUBaseText")
	self.totalNumTxt = self.objectReference:GetRefValue("totalNumTxt")
	self.btn1UButton = self.objectReference:GetRefValue("btn1UButton")
	self.btn2UButton = self.objectReference:GetRefValue("btn2UButton")
end

function LittleFireFestivalComponent:addListener()
	if self.tab1UButton then
		function self.tab1UButton.luaClick()
			self:onClickTab(1)
		end
	end

	if self.tab2UButton then
		function self.tab2UButton.luaClick()
			self:onClickTab(2)
		end
	end

	if self.btn1UButton then
		function self.btn1UButton.luaClick()
			self:onClickManualEntry(1)
		end
	end

	if self.btn2UButton then
		function self.btn2UButton.luaClick()
			self:onClickManualEntry(2)
		end
	end

	if self.rewardUList then
		function self.rewardUList.luaRenderItem(button, index, data)
			self:renderRewardItem(button, index, data)
		end
	end
end

function LittleFireFestivalComponent:onContentReady()
	self:onClickTab(1)
end

function LittleFireFestivalComponent:refreshPage()
	local eventTimeCfg = Utils.getEventTimeConfig(self.eventId)
	local eventEndDayTime = eventTimeCfg and eventTimeCfg.tabEndDayTime

	self:setEventTitle(self.eventTitleUContainer, eventEndDayTime)
	self:refreshTxt()
	self:refreshRewardList()
	self:refreshProgress()
	self:refreshRedDot()
end

function LittleFireFestivalComponent:refreshRedDot()
	local personalStyle = ClientActivityUtils.getLittleFirePersonProgressRedDotStyle(true)
	local globalStyle = ClientActivityUtils.getLittleFirePersonProgressRedDotStyle(false)
	local manualTaskStyle = ClientActivityUtils.getLittleFirePersonManualTaskRedDotStyle()

	pg.global.setRedDot(string.format(RedDotConst.RedDotPath.EVENT_LITTLE_FIRE_PERSON_PROGRESS_TAB, 1), self.tab1UButton, personalStyle ~= RedDotConst.RedDotStyle.NONE, personalStyle)
	pg.global.setRedDot(string.format(RedDotConst.RedDotPath.EVENT_LITTLE_FIRE_PERSON_PROGRESS_TAB, 2), self.tab2UButton, globalStyle ~= RedDotConst.RedDotStyle.NONE, globalStyle)
	pg.global.setRedDot(RedDotConst.RedDotPath.EVENT_LITTLE_FIRE_PERSON_MANUAL_ENTRY, self.btn2UButton, manualTaskStyle ~= RedDotConst.RedDotStyle.NONE, manualTaskStyle)
	self:refreshCommonNodeRedDot()
end

function LittleFireFestivalComponent:onBeforeExitPage()
	return
end

function LittleFireFestivalComponent:_getActivityData()
	return ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.LittleFirePerson)
end

function LittleFireFestivalComponent:refreshTxt()
	local tab1Obj = self.tab1UButton:GetComponent("ObjectReference")
	local tab1Txt = tab1Obj and tab1Obj:GetRefValue("txtNameUBaseText")

	if tab1Txt then
		ClientTextUtils.setText(tab1Txt, pg.getGameString("FIRE_PERSONAL_PROGRESS"))
	end

	local tab2Obj = self.tab2UButton:GetComponent("ObjectReference")
	local tab2Txt = tab2Obj and tab2Obj:GetRefValue("txtNameUBaseText")

	if tab2Txt then
		ClientTextUtils.setText(tab2Txt, pg.getGameString("FIRE_WORLD_PROGRESS"))
	end

	if self.totalNumTitleqUBaseText then
		ClientTextUtils.setText(self.totalNumTitleqUBaseText, self.isPersonal and pg.getGameString("FIRE_PERSONAL_PROGRESS") or pg.getGameString("FIRE_WORLD_PROGRESS"))
	end

	local btn1Ref = self.btn1UButton:GetComponent("ObjectReference")
	local btn1Txt1 = btn1Ref and btn1Ref:GetRefValue("title1UBaseText")
	local btn1Txt2 = btn1Ref and btn1Ref:GetRefValue("title2UBaseText")

	if btn1Txt1 then
		ClientTextUtils.setText(btn1Txt1, pg.getGameString("FIRE_PLAY"))
	end

	if btn1Txt2 then
		local curNum, totalNum = ClientActivityUtils.getLittleFireSparkDailyProgress()

		ClientTextUtils.setText(btn1Txt2, pg.getFormatText(pg.getGameString("FIRE_DAILY_LIMIT"), curNum, totalNum))
	end

	local btn2Ref = self.btn2UButton:GetComponent("ObjectReference")
	local btn2Txt1 = btn2Ref and btn2Ref:GetRefValue("title1UBaseText")
	local btn2Txt2 = btn2Ref and btn2Ref:GetRefValue("title2UBaseText")

	if btn2Txt1 then
		ClientTextUtils.setText(btn2Txt1, pg.getGameString("FIRE_TASK"))
	end

	if btn2Txt2 then
		ClientTextUtils.setText(btn2Txt2, pg.getGameString("FIRE_TASK_REWARD"))
	end
end

function LittleFireFestivalComponent:refreshProgress()
	local activityData = self:_getActivityData()

	if not activityData then
		logger:warn("LittleFirePerson activityData not found")

		return
	end

	local currentNote = self.model:getLittleFireProgress(self.eventId, self.isPersonal) or 0
	local totalNote = ClientActivityUtils.getCommonMaxProgress(self.eventId, self.isPersonal) or 0
	local normalizedValue = totalNote > 0 and currentNote / totalNote or 0

	if self.progressUProgress then
		self.progressUProgress.normalizedValue = normalizedValue
	end

	if self.totalNumTxt then
		local currentNoteText = LuaUIUtils.formatShortNumber(currentNote, 0)

		ClientTextUtils.setText(self.totalNumTxt, currentNoteText)
	end
end

function LittleFireFestivalComponent:refreshRewardList()
	if not self.rewardUList then
		return
	end

	local rewardList = self.model:getLittleFireRewardTask(self.eventId, self.isPersonal)

	self.rewardUList:SetList(rewardList)
end

function LittleFireFestivalComponent:renderRewardItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
	local rewardNumUBaseText = objectReference:GetRefValue("rewardNumUBaseText")
	local award = data.taskAward
	local taskState = data.taskState
	local canReceive = taskState == ActivityConst.TaskState.Finihed_CanRecv
	local hasReceived = taskState == ActivityConst.TaskState.Received or taskState == ActivityConst.TaskState.Received_SendMail
	local rewards = LuaUIUtils.getRewardItemByDropId(award, hasReceived, canReceive)
	local targetNum = data.target

	pg.global.setRedDot(string.format(RedDotConst.RedDotPath.EVENT_LITTLE_FIRE_PERSON_PROGRESS_REWARD, index), button, canReceive, RedDotConst.RedDotStyle.REWARD)

	iconUImage.url = LuaUIUtils.getIconByItemId(rewards and rewards[1] and rewards[1].id)

	if rewardNumUBaseText then
		ClientTextUtils.setText(rewardNumUBaseText, rewards and rewards[1] and rewards[1].num)
	end

	if self.isPersonal then
		ClientTextUtils.setText(txtNameUBaseText, targetNum)
	else
		ClientTextUtils.setText(txtNameUBaseText, LuaUIUtils.formatShortNumber(targetNum, 0))
	end

	local state = 0

	if taskState == ActivityConst.TaskState.Finihed_CanRecv then
		state = 1
	elseif taskState == ActivityConst.TaskState.Received or taskState == ActivityConst.TaskState.Received_SendMail then
		state = 2
	end

	button:TryChangePage("State", state)

	if canReceive then
		function button.luaClick()
			self:receiveAllProgressRewards()
		end
	else
		function button.luaClick()
			self:showRewardItemTip(button, rewards)
		end
	end
end

function LittleFireFestivalComponent:showRewardItemTip(button, rewards)
	local firstItem = rewards and rewards[1]

	if not firstItem or not firstItem.id then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
		id = firstItem.id,
		num = firstItem.num,
		targetRect = button
	})
end

function LittleFireFestivalComponent:receiveAllProgressRewards()
	local rewardList = self.model:getLittleFireRewardTask(self.eventId, self.isPersonal)

	for _, taskInfo in ipairs(rewardList) do
		if taskInfo.taskState == ActivityConst.TaskState.Finihed_CanRecv and taskInfo.taskGroupId then
			pg.me:reqActReceiveGroupTaskReward(taskInfo.taskGroupId, self.eventId)

			return
		end
	end
end

function LittleFireFestivalComponent:onClickTab(tabIndex)
	local previousTabIndex = self.currentTabIndex

	if tabIndex == 1 then
		self.isPersonal = true

		self.rootUComponent:TryChangePage("colour", 0)
		logger:info("onClickTab: 个人进度")

		self.tab1UButton.isSelected = true
		self.tab2UButton.isSelected = false
	elseif tabIndex == 2 then
		self.isPersonal = false

		self.rootUComponent:TryChangePage("colour", 1)
		logger:info("onClickTab: 全服进度暂未开放")

		self.tab1UButton.isSelected = false
		self.tab2UButton.isSelected = true
	end

	if self.tab1BgSelUImage then
		self.tab1BgSelUImage.renderOpacity = tabIndex == 1 and 1 or 0
	end

	if self.tab2BgSelUImage then
		self.tab2BgSelUImage.renderOpacity = tabIndex == 2 and 1 or 0
	end

	if previousTabIndex and previousTabIndex ~= tabIndex and pg.game.input:isUsingGamepad() then
		local selectedTabAnimation, selectedHandLTransform, selectedHandRTransform

		if tabIndex == 1 then
			selectedTabAnimation = self.tab1Animation
			selectedHandLTransform = self.tab1HandLTransform
			selectedHandRTransform = self.tab1HandRTransform
		elseif tabIndex == 2 then
			selectedTabAnimation = self.tab2Animation
			selectedHandLTransform = self.tab2HandLTransform
			selectedHandRTransform = self.tab2HandRTransform
		end

		setTabHandsVisible(selectedHandLTransform, selectedHandRTransform)

		if selectedTabAnimation then
			UIUtils.PlayAnimation(selectedTabAnimation, "VX_Node_Event_TikTok_TabBar_Click", function()
				if self.currentTabIndex == tabIndex then
					setTabHandsVisible(selectedHandLTransform, selectedHandRTransform)
				end
			end)
		end
	end

	self.currentTabIndex = tabIndex

	self:refreshPage()
end

function LittleFireFestivalComponent:onClickManualEntry(tabIndex)
	pg.global.ui:open(UIConst.UI_ID_LITTLE_FIRE_GARDEN_MANUAL, {
		eventId = self.eventId,
		tab = tabIndex
	})
end

return LittleFireFestivalComponent
