-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\QuestCourse\\QuestCourseCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("QuestMainComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local RedDotConst = require("Const.RedDotConst")
local QuestCourseCtrl = Class.LightClass("QuestCourseCtrl", UICtrl)
local COURSE_GRADE_ITEM_ANIMATION_INTERVAL = 0.04
local COURSE_GRADE_ANIMATION_END_DELAY = 0.2
local CONTROLLER_NAME = "TypeSpecial"

QuestCourseCtrl.messages = {
	[MessageName.QUEST_ON_STATE_CHANGE] = {
		"onQuestStateChange",
		true
	},
	[MessageName.QUEST_ON_ADD] = {
		"onAddNewQuest",
		true
	},
	[MessageName.QUEST_ON_TRACE_CHANGE] = {
		"onQuestTraceChange",
		true
	},
	[MessageName.QUEST_ON_SUBMIT] = {
		"onQuestSubmit",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function QuestCourseCtrl:init()
	return
end

function QuestCourseCtrl:onOpen(info)
	self.targetCourseId = info and info.courseId or nil
	self.forceUnlockCourseId = info and info.forceUnlockCourseId or nil
	self.fromMarkShare = info and info.fromMarkShare == true

	self.model:setForceUnlockCourseId(self.forceUnlockCourseId)
end

function QuestCourseCtrl:onInputDeviceChanged(deviceType)
	return
end

function QuestCourseCtrl:addListener()
	function self.view.courseUList.luaRenderItem(button, index, data)
		self:onRefreshCourseGradeItem(button, index, data)
	end

	function self.view.courseDetailList.luaRenderItem(button, index, data)
		self:onRefreshCourseDetailItem(button, index, data)
	end

	function self.view.rewardUList.luaRenderItem(button, index, data)
		self:onRefreshCourseDetailIRewardItem(button, index, data)
	end

	function self.view.closeBtn.luaClick()
		self:closePanel()
	end

	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:AddLuaFocusCursorMovedListener("QuestCourse", function()
			self:refreshConsoleBarState()
		end)
	end
end

function QuestCourseCtrl:refreshConsoleBarState()
	if CS.XGUI.Navigation.NavManager.Instance then
		local navGroupName = CS.XGUI.Navigation.NavManager.Instance.CurrentFocusedGroupName
		local canSelect = navGroupName == "ClassList" or navGroupName == "RewardList"

		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("canSelect", canSelect)
	end
end

function QuestCourseCtrl:onShow()
	local courseGrades = self.model:getAllCourseGradeConfig()

	self.maxGrade = #courseGrades
	self.curGrade = 1
	self.curSelectGrade = 1
	self.courseGradeButtons = {}

	self:setButtonsInteractable(false)
	self.view.courseUList:SetList(courseGrades)

	local entranceDuration = self.view.courseUList.luaPreInterval + #courseGrades * COURSE_GRADE_ITEM_ANIMATION_INTERVAL + COURSE_GRADE_ANIMATION_END_DELAY

	self.enableInteractableTimer = self:startTimer(function()
		self.enableInteractableTimer = nil

		if self.view == nil then
			return
		end

		self:setButtonsInteractable(true)

		local _, page = self.view.mainCom:TryGetCurrentPage("Tab")

		if page == 0 and self.courseGradeButtons[1] ~= nil and CS.XGUI.Navigation.NavManager.Instance then
			CS.XGUI.Navigation.NavManager.Instance:FocusItem(self.courseGradeButtons[1])
		end
	end, entranceDuration)

	local targetCourseConfig = self.targetCourseId and self.model:getCourseConfig(self.targetCourseId) or nil

	if targetCourseConfig == nil then
		return
	end

	local targetGrade = targetCourseConfig.grade
	local targetGradeConfig = self.model:getCourseGradeConfig(targetGrade)

	if targetGradeConfig == nil then
		return
	end

	self:openCourseGradeDetail(targetGrade, targetGradeConfig, self.targetCourseId)
	self.view.courseUList:GoToIndex(targetGrade - 1, true)
end

function QuestCourseCtrl:onRefreshCourseGradeItem(button, index, data)
	local itemComs = self.view:getCourseGradeItemComs(button)

	itemComs.com:TryChangePage(CONTROLLER_NAME, 0)

	local curGrade = index + 1
	local courses = self.model:getCourseGradeConfig(curGrade)
	local detailData = courses[1]

	self.courseGradeButtons[curGrade] = button
	button.interactable = self.isButtonInteractable

	function button.luaClick()
		self:openCourseGradeDetail(curGrade, courses)
	end

	ClientTextUtils.setText(itemComs.courseTypeNameTxt, pg.getLocalizationText(detailData.name))
	self:refreshCompletedProgress(curGrade, itemComs.com, itemComs.courseFinTxt, itemComs.courseTotalTxt, itemComs.courseProgressSlider)
	pg.global.setPreViewRedDot(string.format(RedDotConst.RedDotPath.QUEST_COURSE_GRADE, curGrade), button, function()
		return self.model:redDot_GetGradeState(curGrade)
	end)
	button:TryChangePage("Type", index)
end

function QuestCourseCtrl:openCourseGradeDetail(curGrade, data, targetCourseId)
	self.curSelectGrade = curGrade

	self.view.mainCom:TryChangePage("Tab", 1)
	self:onClickCourseGradeItem(curGrade, data, targetCourseId)
	self.model:redDot_SetCourseGradeRead(curGrade)
end

function QuestCourseCtrl:setButtonsInteractable(interactable)
	self.isButtonInteractable = interactable

	for _, button in ipairs(self.courseGradeButtons or EMPTY_TABLE) do
		button.interactable = interactable
	end
end

function QuestCourseCtrl:onClickCourseGradeItem(curGrade, data, targetCourseId)
	self.curGrade = curGrade

	local courseList = self.model:getGradeCourseList(curGrade)

	if courseList == nil then
		return
	end

	self.model:sortCourseList(courseList)

	local requestGrade = curGrade

	self.view.beginnerNode:SetUrlWithCallback("$UI_Node_GuideBeginner_Beginner.prefab", function(content)
		if content == nil or self.view == nil or self.model == nil or requestGrade ~= self.curSelectGrade then
			return
		end

		local objectReference = content.transform:GetComponent("ObjectReference")
		local courseUComponent = objectReference:GetRefValue("courseUComponent")
		local courseTypeNameTxt = objectReference:GetRefValue("courseTypeNameTxt")
		local courses = self.model:getCourseGradeConfig(requestGrade)

		if courses == nil or courses[1] == nil then
			return
		end

		local detailData = courses[1]

		courseUComponent.interactable = false

		courseUComponent:TryChangePage(CONTROLLER_NAME, 1)
		courseUComponent:TryChangePage("Type", requestGrade - 1)
		ClientTextUtils.setText(courseTypeNameTxt, pg.getLocalizationText(detailData.name))
	end)
	self.view.courseDetailList:SetList(courseList)

	if targetCourseId ~= nil then
		for index, courseData in ipairs(courseList) do
			if courseData.id == targetCourseId then
				self:startFrameTimer(function()
					if self.view and self.view.courseDetailList then
						self.view.courseDetailList:GoToIndex(index - 1, true)
					end
				end, 1)

				break
			end
		end
	end

	local courseGradeConfig = self.model:getCourseGradeConfig(curGrade)

	if courseGradeConfig == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("当前教学课程等级配置为空", curGrade)
		end

		return
	end

	local hadFinedCount = self.model:getCourseGradeCompleteCnt(self.curGrade)
	local totalCount = self.model:getCourseGradeCnt(self.curGrade)

	ClientTextUtils.setText(self.view.courseFinTxt, tostring(hadFinedCount))
	ClientTextUtils.setText(self.view.courseTotalTxt, tostring(totalCount))
	self.view.rewardUList:SetList(data)
end

function QuestCourseCtrl:onRefreshCourseDetailIRewardItem(button, index, data)
	local itemComs = self.view:getCourseDetailRewardItemComs(button)

	ClientTextUtils.setText(itemComs.textTitle, tostring(data.num or 0))

	local rewardItems = LuaUIUtils.getRewardItemByDropId(data.reward)

	if rewardItems ~= nil and #rewardItems > 0 then
		local level = index + 1
		local hasGet = self.model:isCourseGradeLevelReward(self.curGrade, level)
		local canGet = self.model:canCourseGradeLevelReward(self.curGrade, level)
		local extraFunc

		if canGet and not hasGet then
			function extraFunc()
				local claimGrade = self.curGrade

				pg.me:getCourseLevelReward(claimGrade, level, function(ret)
					if ret ~= 0 then
						if LoggerManager.checkLogger(LoggerConst.ERROR) then
							logger:error("领取失败！")
						end

						return
					end

					if self.view ~= nil and self.curGrade == claimGrade then
						self:refreshCourseGradeContent(claimGrade)
					end

					local gradeConfig = self.model:getCourseGradeConfig(claimGrade) or {}

					for rewardLevel = 1, #gradeConfig do
						pg.global.refreshRedDotState(self.model:redDot_GetGradeLevelRewardPath(claimGrade, rewardLevel))
					end
				end)
			end
		end

		itemComs.rewardBtn.templateKey = "normal"
		rewardItems[1].hasGet = hasGet
		rewardItems[1].canGet = canGet
		rewardItems[1].showRedDot = canGet and not hasGet
		rewardItems[1].extraFunc = extraFunc

		LuaUIUtils.renderRewards(itemComs.rewardBtn, nil, rewardItems[1])
		pg.global.setPreViewRedDot(self.model:redDot_GetGradeLevelRewardPath(self.curGrade, level), itemComs.rewardBtn, function()
			return self.model:canGetCourseGradeLevelReward(self.curGrade, level) and RedDotConst.RedDotStyle.REWARD or RedDotConst.RedDotStyle.NONE
		end)

		local finCount = self.model:getCourseGradeCompleteCnt(self.curGrade)
		local requireCount = data.num or 0

		if requireCount <= finCount then
			itemComs.progress.value = 1
		else
			itemComs.progress.value = 0
		end
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("奖励配置不存在或者显示奖励没配！ rewardId", data.reward)
	end
end

function QuestCourseCtrl:onRefreshCourseDetailItem(button, index, data)
	local itemComs = self.view:getCourseItemComs(button)
	local courseConfig = self.model:getCourseConfig(data.id)

	if courseConfig == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("当前的教学课程配置不存在 ", data.id)
		end

		return
	end

	local isCourseUnlock = self.model:isCourseUnlock(data.id)
	local titleTxt = pg.getLocalizationText(courseConfig.title)

	ClientTextUtils.setText(itemComs.nameTxt, titleTxt)

	if pg.game.setting:getShowDebugId() then
		ClientTextUtils.setText(itemComs.nameTxt, titleTxt .. tostring(data.id))
	end

	itemComs.bgImg.url = courseConfig.pic

	local canGetReward = self.model:canGetCourseReward(data.id)
	local courseRedDotPath = self.model:redDot_GetCoursePath(courseConfig.grade, data.id)

	local function getCourseRedDotStyle()
		return self.model:redDot_GetCourseState(data.id)
	end

	pg.global.setPreViewRedDot(courseRedDotPath, itemComs.claimBtn, getCourseRedDotStyle)
	pg.global.setPreViewRedDot(courseRedDotPath, itemComs.startBtn, getCourseRedDotStyle)

	itemComs.startBtn.visualInteractable = isCourseUnlock

	local function switchBtnState(type)
		if type == 1 then
			LuaUIUtils.setUIViewVisible(itemComs.startBtn, false)
			LuaUIUtils.setUIViewVisible(itemComs.claimBtn, true)
		else
			LuaUIUtils.setUIViewVisible(itemComs.claimBtn, false)
			LuaUIUtils.setUIViewVisible(itemComs.startBtn, true)
		end
	end

	local function addBtnHandler(state)
		if state then
			function itemComs.claimBtn.luaClick()
				if canGetReward then
					local claimGrade = courseConfig.grade

					pg.me:getCourseReward(data.id, function(ret)
						if ret ~= 0 then
							if LoggerManager.checkLogger(LoggerConst.ERROR) then
								logger:error("领取失败！")
							end

							return
						end

						if self.view ~= nil and self.curGrade == claimGrade then
							self:refreshCourseGradeContent(claimGrade)
						end

						pg.global.refreshRedDotState(courseRedDotPath)
						pg.global.refreshRedDotState(string.format(RedDotConst.RedDotPath.QUEST_COURSE_GRADE, claimGrade))
					end)
				end
			end
		else
			function itemComs.startBtn.luaClick()
				if not isCourseUnlock then
					return
				end

				if pg.me:isInTeam(true) then
					pg.global.ui.tips:showTextTip(pg.getGameString("ENTER_COURSE_TEAM"))

					return
				end

				if pg.me.curGuideCourseId ~= 0 then
					pg.global.ui.tips:showTextTip(pg.getGameString("ALREADY_IN_COURSE"))

					return
				end

				local blackList = UIConst.QUEST_COURSE_BLACK_LIST

				for i = 1, #blackList do
					pg.global.ui:close(blackList[i])
				end

				ClientUtils.playTeleportDissolveEffectAndTeleportByFunc(function()
					pg.me:startCourse(data.id)
				end)
				self:dismiss()
			end
		end
	end

	local hadFined = self.model:isCourseComplete(data.id)

	if hadFined then
		if canGetReward then
			switchBtnState(1)
			ClientTextUtils.setText(itemComs.claimBtnTxt, pg.getGameString("COURSE_ACCEPT"))
			addBtnHandler(true)
			button:TryChangePage("main", 0)
		else
			switchBtnState(0)
			ClientTextUtils.setText(itemComs.startBtnTxt, pg.getGameString("COURSE_ENTER_AGAIN"))
			addBtnHandler(false)
			button:TryChangePage("main", 1)
		end
	else
		switchBtnState(0)
		ClientTextUtils.setText(itemComs.startBtnTxt, pg.getGameString("COURSE_LEARN"))
		addBtnHandler(false)
		button:TryChangePage("main", 0)
	end

	function itemComs.rewardUList.luaRenderItem(button, index, subData)
		local rewardBtn = button
		local hasGet = self.model:isCourseReward(data.id)
		local canGet = self.model:isCourseComplete(data.id)

		subData.hasGet = hasGet
		subData.canGet = canGet

		LuaUIUtils.renderRewards(rewardBtn, index, subData)
	end

	local rewardItems = LuaUIUtils.getRewardItemByDropId(courseConfig.reward)

	itemComs.rewardUList:SetList(rewardItems ~= nil and rewardItems or {})

	data.rewardItems = rewardItems
	itemComs.data = data
	button.name = tostring(data.id)
end

function QuestCourseCtrl:onDestroy()
	if CS.XGUI.Navigation.NavManager.Instance then
		CS.XGUI.Navigation.NavManager.Instance:RemoveLuaFocusCursorMovedListener("QuestCourse")
	end
end

function QuestCourseCtrl:closePanel()
	if self.fromMarkShare then
		self:dismiss()

		return
	end

	local _, page = self.view.mainCom:TryGetCurrentPage("Tab")

	if page == 1 then
		self.view.mainCom:TryChangePage("Tab", 0)

		return
	end

	self:dismiss()
end

function QuestCourseCtrl:refreshCompletedProgress(curSelectGrade, ucom, curTxt, totalTxt, slider)
	local finCount = self.model:getCourseGradeCompleteCnt(curSelectGrade)
	local totalCount = self.model:getCourseGradeCnt(curSelectGrade)

	ucom:TryChangePage("State", totalCount <= finCount and 1 or 0)
	ClientTextUtils.setText(curTxt, finCount)
	ClientTextUtils.setText(totalTxt, totalCount)

	slider.value = self.model:getGradeFinishProgress(curSelectGrade)
end

function QuestCourseCtrl:refreshCourseGradeContent(grade)
	if self.view == nil or self.model == nil then
		return
	end

	local courseGradeConfig = self.model:getCourseGradeConfig(grade)

	if courseGradeConfig == nil then
		return
	end

	self.curGrade = grade
	self.curSelectGrade = grade

	self.view.courseUList:RefreshList()
	self:onClickCourseGradeItem(grade, courseGradeConfig)
end

return QuestCourseCtrl
