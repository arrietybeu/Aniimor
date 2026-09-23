-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\QuestCourse\\QuestCourseModel.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Bitset = require("Common.Bitset")
local UIModel = require("Guis.UIModel")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local RedDotConst = require("Const.RedDotConst")
local ItemData = require("Data.item_data")
local DropData = require("Data.drop_data")
local GuideCourseData = require("Data.guide_course_data")
local GuideCourseInfoData = require("Data.guide_course_info_data")
local GuideCourseGradeData = require("Data.guide_course_grade_data")
local logger = LoggerManager.getLogger("QuestCourseModel")
local Class = require("Core.Framework.Class")
local QuestCourseModel = Class.LightClass("QuestCourseModel", UIModel)

function QuestCourseModel:getAllCourseGradeConfig()
	local temp = {}

	for i, v in ipairs(GuideCourseGradeData) do
		table.insert(temp, {
			id = i
		})
	end

	return temp
end

function QuestCourseModel:getCourseGradeConfig(grade)
	return Utils.deepCopyTable(GuideCourseGradeData[grade])
end

function QuestCourseModel:getCourseGradeLevelConfig(grade, level)
	local gradeConfig = GuideCourseGradeData[grade]

	return gradeConfig ~= nil and gradeConfig[level] or nil
end

function QuestCourseModel:setForceUnlockCourseId(courseId)
	self.forceUnlockCourseId = courseId
end

function QuestCourseModel:isCourseReallyUnlock(courseId)
	return courseId ~= nil and pg.me.unlockCourseIds ~= nil and pg.me.unlockCourseIds[courseId] == true
end

function QuestCourseModel:isForceUnlockCourse(courseId)
	return courseId ~= nil and courseId == self.forceUnlockCourseId
end

function QuestCourseModel:isCourseUnlock(courseId)
	return self:isCourseReallyUnlock(courseId) or self:isForceUnlockCourse(courseId)
end

function QuestCourseModel:getGradeCourseList(grade)
	local courseList = GuideCourseInfoData[grade]

	if courseList == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("当前等级没有课程信息 ", grade)
		end

		return
	end

	local temp = {}

	for i = 1, #courseList do
		local courseId = courseList[i]

		if self:isCourseUnlock(courseId) then
			table.insert(temp, {
				id = courseId
			})
		end
	end

	return temp
end

function QuestCourseModel:getCourseConfig(courseId)
	return GuideCourseData[courseId]
end

function QuestCourseModel:getCourseData(courseId)
	local courseConfig = self:getCourseConfig(courseId)

	if courseConfig == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("教学课程配置不存在！", courseId)
		end

		return
	end

	local courGradeCourse = self:getCourseGradeData(courseConfig.grade)

	if courGradeCourse == nil then
		return
	end

	return courGradeCourse[courseId]
end

function QuestCourseModel:getCourseGradeData(grade)
	local guideCourse = pg.me.guideCourse

	return guideCourse[grade]
end

function QuestCourseModel:getCourseGradeCompleteCnt(grade)
	local courGradeCourse = self:getCourseGradeData(grade)

	return courGradeCourse ~= nil and courGradeCourse.courseCompleteCnt or 0
end

function QuestCourseModel:getCourseGradeCnt(grade)
	local courseList = GuideCourseInfoData[grade]

	if courseList == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("当前等级没有课程信息 ", grade)
		end

		return
	end

	return #courseList
end

function QuestCourseModel:canGetCourseGradeLevelReward(grade, level)
	return self:canCourseGradeLevelReward(grade, level) and not self:isCourseGradeLevelReward(grade, level)
end

function QuestCourseModel:canCourseGradeLevelReward(grade, level)
	local gradeLevelConfig = self:getCourseGradeLevelConfig(grade, level)

	if gradeLevelConfig == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("当前等级的课程分级奖励配置不存在 grade level", grade, level)
		end

		return false
	end

	local completeCnt = self:getCourseGradeCompleteCnt(grade)

	return completeCnt >= gradeLevelConfig.num
end

function QuestCourseModel:isCourseGradeLevelReward(grade, level)
	local courGradeCourse = self:getCourseGradeData(grade)

	if courGradeCourse == nil or courGradeCourse.levelAwardFlags == nil then
		return false
	end

	if Bitset.getBit(courGradeCourse.levelAwardFlags, level) then
		return true
	end

	return false
end

function QuestCourseModel:canGetCourseReward(courseId)
	return self:isCourseComplete(courseId) and not self:isCourseReward(courseId)
end

function QuestCourseModel:isCourseComplete(courseId)
	local courseData = self:getCourseData(courseId)

	return courseData ~= nil and courseData.passCnt > 0
end

function QuestCourseModel:isCourseReward(courseId)
	local courseData = self:getCourseData(courseId)

	return courseData ~= nil and courseData.rewardFlag
end

function QuestCourseModel:redDot_GetCoursePath(grade, courseId)
	return string.format(RedDotConst.RedDotPath.QUEST_COURSE_ITEM, grade, courseId)
end

function QuestCourseModel:redDot_IsCourseNew(courseId)
	if not self:isCourseReallyUnlock(courseId) or self:isCourseComplete(courseId) then
		return false
	end

	local courseConfig = self:getCourseConfig(courseId)

	if courseConfig == nil then
		return false
	end

	local path = self:redDot_GetCoursePath(courseConfig.grade, courseId)

	return pg.me:getRedDotRecord(Const.CLIENT_KEY.QUEST_COURSE_RED_DOT, path, true)
end

function QuestCourseModel:redDot_SetCourseRead(courseId)
	local courseConfig = self:getCourseConfig(courseId)

	if courseConfig == nil then
		return
	end

	local path = self:redDot_GetCoursePath(courseConfig.grade, courseId)

	pg.me:setRedDotRecord(Const.CLIENT_KEY.QUEST_COURSE_RED_DOT, path, false)
end

function QuestCourseModel:redDot_SetCourseGradeRead(grade)
	local courseList = GuideCourseInfoData[grade] or {}

	for _, courseId in ipairs(courseList) do
		if self:redDot_IsCourseNew(courseId) then
			self:redDot_SetCourseRead(courseId)
			pg.global.refreshRedDotState(self:redDot_GetCoursePath(grade, courseId))
		end
	end

	pg.global.refreshRedDotState(string.format(RedDotConst.RedDotPath.QUEST_COURSE_GRADE, grade))
end

function QuestCourseModel:redDot_SetAllCourseRead()
	for grade = 1, #GuideCourseInfoData do
		local courseList = GuideCourseInfoData[grade] or {}

		for _, courseId in ipairs(courseList) do
			if self:redDot_IsCourseNew(courseId) then
				self:redDot_SetCourseRead(courseId)
				pg.global.refreshRedDotState(self:redDot_GetCoursePath(grade, courseId))
			end
		end
	end
end

function QuestCourseModel:redDot_GetCourseState(courseId)
	if self:canGetCourseReward(courseId) then
		return RedDotConst.RedDotStyle.REWARD
	end

	if self:redDot_IsCourseNew(courseId) then
		return RedDotConst.RedDotStyle.NEW
	end

	return RedDotConst.RedDotStyle.NONE
end

function QuestCourseModel:sortCourseList(courseList)
	for index, courseData in ipairs(courseList) do
		courseData.sortIndex = index

		if self:canGetCourseReward(courseData.id) then
			courseData.sortPriority = 1
		elseif self:redDot_IsCourseNew(courseData.id) then
			courseData.sortPriority = 2
		elseif not self:isCourseComplete(courseData.id) then
			courseData.sortPriority = 3
		else
			courseData.sortPriority = 4
		end
	end

	table.sort(courseList, function(left, right)
		if left.sortPriority == right.sortPriority then
			return left.sortIndex < right.sortIndex
		end

		return left.sortPriority < right.sortPriority
	end)
end

function QuestCourseModel:redDot_GetGradeLevelRewardPath(grade, level)
	return string.format(RedDotConst.RedDotPath.QUEST_COURSE_GRADE_LEVEL_REWARD, grade, level)
end

function QuestCourseModel:redDot_GetGradeState(grade)
	local gradeConfig = GuideCourseGradeData[grade] or {}

	for level = 1, #gradeConfig do
		if self:canGetCourseGradeLevelReward(grade, level) then
			return RedDotConst.RedDotStyle.REWARD
		end
	end

	local result = RedDotConst.RedDotStyle.NONE
	local courseList = self:getGradeCourseList(grade) or {}

	for _, courseData in ipairs(courseList) do
		local style = self:redDot_GetCourseState(courseData.id)

		if style == RedDotConst.RedDotStyle.REWARD then
			return RedDotConst.RedDotStyle.REWARD
		elseif style == RedDotConst.RedDotStyle.NEW then
			result = RedDotConst.RedDotStyle.NEW
		end
	end

	return result
end

function QuestCourseModel:redDot_GetState()
	local result = RedDotConst.RedDotStyle.NONE

	for grade = 1, #GuideCourseGradeData do
		local style = self:redDot_GetGradeState(grade)

		if style == RedDotConst.RedDotStyle.REWARD then
			return RedDotConst.RedDotStyle.REWARD
		elseif style == RedDotConst.RedDotStyle.NEW then
			result = RedDotConst.RedDotStyle.NEW
		end
	end

	return result
end

function QuestCourseModel:getGradeFinishProgress(grade)
	local finCount = self:getCourseGradeCompleteCnt(grade)
	local gradeConfig = self:getCourseGradeConfig(grade)
	local rewardCount = #gradeConfig
	local ratioSpan = 1 / rewardCount
	local totalRatio = 0
	local lastNum = 0

	for i = 1, #gradeConfig do
		local num = gradeConfig[i].num

		if num <= finCount then
			totalRatio = totalRatio + ratioSpan
		else
			totalRatio = totalRatio + (finCount - lastNum) / num * ratioSpan

			break
		end

		lastNum = num
	end

	return totalRatio
end

function QuestCourseModel:getRewardItems(rewardId)
	if rewardId == nil then
		return nil
	end

	local rewardConfig = DropData[rewardId]

	return rewardConfig ~= nil and rewardConfig.displayReward or nil
end

function QuestCourseModel:getItemConfig(itemId)
	return ItemData[itemId]
end

return QuestCourseModel
