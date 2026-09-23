-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientGuidanceComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local Time = require("Core.Common.Time")
local logger = LoggerManager.getLogger("Guidance")
local CallbackHandler = require("Core.Common.CallbackHandler")
local GuidenceConfData = require("Data.sys_config_data")
local GuideCourseData = require("Data.guide_course_data")
local GuideCourseInfoData = require("Data.guide_course_info_data")
local ClientUtils = require("Utils.ClientUtils")
local UIConst = require("Const.UIConst")
local lume = require("Core.Common.lume")
local ClientGuidanceComponent = class.Component("ClientGuidanceComponent")

function ClientGuidanceComponent:ctor()
	self.helpRecentNum = GuidenceConfData.helpRecentNum
	self.intervalTimeSeconds = GuidenceConfData.helpDuration * 3600 * 24
end

function ClientGuidanceComponent:destory()
	return
end

function ClientGuidanceComponent:getAllRecentlyUnlockedIds()
	local curTimeStampSecondUTC = math.floor(Time.secondCache)
	local allRecentlyUnlocked = {}
	local tmp = {}

	for _, tab in ipairs(Const.GUIDANCE_TYPE) do
		local sourceList = self.unlockedGuidenceMap[tab]
		local startIndex = math.max(1, #sourceList - self.helpRecentNum + 1)

		for i = startIndex, #sourceList do
			tmp[#tmp + 1] = sourceList[i]
		end
	end

	local function _timeStampCompare(a, b)
		return a.timeStamp > b.timeStamp
	end

	table.sort(tmp, _timeStampCompare)

	for i = 1, self.helpRecentNum do
		if i > #tmp then
			break
		end

		local unlockedTimeStamp = tmp[i].timeStamp

		if not unlockedTimeStamp or not (curTimeStampSecondUTC - unlockedTimeStamp <= self.intervalTimeSeconds) then
			break
		end

		allRecentlyUnlocked[#allRecentlyUnlocked + 1] = tmp[i].guidenceId
	end

	return allRecentlyUnlocked
end

function ClientGuidanceComponent:getSubTabRecentlyUnlockedIds(tab)
	local isLegalTab = false

	for _, v in ipairs(Const.GUIDANCE_TYPE) do
		if tab == v then
			isLegalTab = true

			break
		end
	end

	if not isLegalTab then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("getSubTabRecentlyUnlockedIds failed, Invaild tab. " .. self:repr(), tab)
		end

		return
	end

	local curTimeStampSecondUTC = math.floor(Time.secondCache)
	local subRecentlyUnlocked = {}
	local sourceList = self.unlockedGuidenceMap[tab]
	local len = #sourceList

	for i = 0, self.helpRecentNum - 1 do
		if len - i < 1 then
			break
		end

		local unlockedTimeStamp = sourceList[len - i].timeStamp

		if not unlockedTimeStamp or not (curTimeStampSecondUTC - unlockedTimeStamp <= self.intervalTimeSeconds) then
			break
		end

		subRecentlyUnlocked[#subRecentlyUnlocked + 1] = sourceList[len - i].guidenceId
	end

	return subRecentlyUnlocked
end

function ClientGuidanceComponent:RPC_SC_OpenGuidExitInterface()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("RPC_SC_OpenGuidExitInterface")
	end

	local curGuideCourseId = pg.me.curGuideCourseId
	local nextGrade = 0
	local showNextGuide = false
	local nextUnlock = false

	if not curGuideCourseId then
		showNextGuide = false
	end

	local data = GuideCourseData[curGuideCourseId]

	if not data then
		showNextGuide = false
	end

	local nextGuideId
	local curGrade = data.grade

	if data then
		showNextGuide, nextGuideId, nextUnlock, nextGrade = self:findNextGuideId(curGuideCourseId)
	end

	if not nextGuideId then
		showNextGuide = false
	end

	pg.global.showConfirmMsgRaw(pg.getGameString("QUIT_COURSE_TITLE"), pg.getGameString("QUIT_COURSE_WARNING"), function()
		ClientUtils.playTeleportDissolveEffectAndTeleportByFunc(function()
			pg.me:serverMsg("RPC_CS_QuitSpace")

			pg.game.quest.isCallbackCourse = true
		end)
	end, nil)
end

function ClientGuidanceComponent:RPC_SC_AppearHelp(helpId, helpIdsMultiPlatform)
	if type(helpIdsMultiPlatform) == "table" and lume.tableLength(helpIdsMultiPlatform) ~= 0 then
		local curPlatform = pg.global.ui.uiMgr:CheckPlatform()

		if helpIdsMultiPlatform[curPlatform] then
			helpId = helpIdsMultiPlatform[curPlatform]
		end
	end

	pg.global.ui:open(UIConst.UI_ID_FUNC_MENU_UNLOCK, {
		helpId = helpId
	})
end

function ClientGuidanceComponent:RPC_SC_AppearHelpSimple(helpId)
	pg.global.ui.tips:showHelpTips({
		helpId = helpId
	})
end

function ClientGuidanceComponent:findNextGuideId(curGuideCourseId)
	local showNextGuide = false
	local nextGuideId
	local nextGrade = 0
	local nextUnlock = false
	local mergeTable = {}

	for i = 1, #GuideCourseInfoData do
		for j = 1, #GuideCourseInfoData[i] do
			mergeTable[#mergeTable + 1] = GuideCourseInfoData[i][j]
		end
	end

	local index

	for i = 1, #mergeTable do
		if mergeTable[i] == curGuideCourseId then
			index = i

			break
		end
	end

	if not index then
		return showNextGuide, nextGuideId, nextUnlock, nextGrade
	end

	for i = index + 1, #mergeTable do
		local gradeD = GuideCourseData[mergeTable[i]]
		local gcData = pg.me.guideCourse[gradeD.grade] or {}
		local gcDData = gcData[mergeTable[i]]

		nextGuideId = mergeTable[i]
		showNextGuide = true
		nextGrade = gradeD.grade

		local unLock = self:isCourseUnlock(gradeD)

		nextUnlock = unLock

		break
	end

	return showNextGuide, nextGuideId, nextUnlock, nextGrade
end

function ClientGuidanceComponent:isCourseUnlock(courseConfig)
	local flag = true

	if courseConfig.condition ~= nil and courseConfig.condition ~= 0 then
		for i, v in pairs(courseConfig.condition) do
			if not pg.me.triggerMap:isCompleteOrMeetCondition(v) then
				flag = false

				return flag
			end
		end
	end

	return flag
end

function ClientGuidanceComponent:RPC_SC_GuidanceCurs_Change(guideId)
	pg.game.guide:startGuides(guideId)
end

function ClientGuidanceComponent:RPC_SC_GuidanceRecords_Add(guideId, count)
	pg.game.guide:finishGuide(guideId, Const.GUIDE_FINISH_REASON.SERVER_FINISH)
end

function ClientGuidanceComponent:RPC_SC_GuidanceRecords_Change(ov, nv, guideId)
	if ov < nv then
		pg.game.guide:finishGuide(guideId, Const.GUIDE_FINISH_REASON.SERVER_FINISH)
	end
end

function ClientGuidanceComponent:startCourse(courseId, extraArgs)
	pg.game.quest.extraArgs = extraArgs

	self:serverMsg("RPC_CS_StartCourse", courseId)
end

function ClientGuidanceComponent:unlockCourse(courseId)
	self:serverMsg("RPC_CS_UnlockCourse", courseId)
end

function ClientGuidanceComponent:getCourseLevelReward(grade, level, callback)
	self:serverMsg("RPC_CS_GetCourseLevelReward", grade, level, CallbackHandler(self, "getCourseLevelRewardCallback", callback))
end

function ClientGuidanceComponent:getCourseLevelRewardCallback(callback, retStatus)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("getCourseLevelRewardCallback")
	end

	if callback ~= nil then
		callback(retStatus)
	end
end

function ClientGuidanceComponent:getCourseReward(courseId, callback)
	self:serverMsg("RPC_CS_GetCourseReward", courseId, CallbackHandler(self, "onGetCourseRewardCallback", callback))
end

function ClientGuidanceComponent:onGetCourseRewardCallback(callback, retStatus)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("onGetCourseRewardCallback")
	end

	if callback ~= nil then
		callback(retStatus)
	end
end

function ClientGuidanceComponent:getCourseCompleteCnt(grade)
	if not grade then
		return 0
	end

	local gcData = pg.me.guideCourse[grade] or {}

	return gcData.courseCompleteCnt
end

function ClientGuidanceComponent:getGuidanceCompleteCnt(guidanceId)
	if not pg.me.guidanceRecords[guidanceId] then
		return
	end

	local count = pg.me.guidanceRecords[guidanceId] or 0

	return count
end

return ClientGuidanceComponent
