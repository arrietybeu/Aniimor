-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SeasonCalendar\\SeasonCalendarModel.lua

local Time = require("Core.Common.Time")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ActivityConst = require("Common.Const.ActivityConst")
local Const = require("Common.Const.Const")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local Utils = require("Common.Utils.Utils")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local SeasonIntroductionData = require("Data.event_season_introduction_data")
local SeasonTreeActivityData = require("Data.event_season_tree_activity_data")
local ItemSourceData = require("Data.item_source_data")
local SeasonActivityData = require("Data.season_activity_data")
local MODULE_TYPE_COMMON_FIRST = 0
local MODULE_TYPE_SEASON_CATCH = 4
local TREE_ACTIVITY_STATE_FUTURE = 0
local TREE_ACTIVITY_STATE_CURRENT = 1
local TREE_ACTIVITY_STATE_PAST = 2
local TREE_ACTIVITY_STATE_FIRST_PAST = 3
local TREE_ACTIVITY_STATE_FIRST_CURRENT = 4
local TEMPLATE_TWO_BUTTON_CONFIGS = {
	{
		imageUrl = "$UI_Img_Event_Season_Overview_Btn_Tower.png",
		buttonRefName = "button1UButton",
		sourceId = 507,
		titleKey = "SEASON_GUIDE1"
	},
	{
		imageUrl = "$UI_Img_Event_Season_Overview_Btn_Egg.png",
		buttonRefName = "button2UButton",
		sourceId = 712,
		titleKey = "SEASON_GUIDE2"
	},
	{
		imageUrl = "$UI_Img_Event_Season_Overview_Btn_Bossmod.png",
		buttonRefName = "button3UButton",
		sourceId = 713,
		titleKey = "SEASON_GUIDE3"
	},
	{
		imageUrl = "$UI_Img_Event_Season_Overview_Btn_Home.png",
		buttonRefName = "button4UButton",
		sourceId = 8159,
		titleKey = "SEASON_GUIDE4"
	}
}
local SeasonCalendarModel = Class.LightClass("SeasonCalendarModel", UIModel)

function SeasonCalendarModel:getOpenActivityIdByType(activityType)
	local isOpen, activityId = ActivityUtils.isOprActivityTabOpenByType(activityType, pg.me)

	if not isOpen or not activityId or not ClientActivityUtils.isGameEventTabOpen(activityId) then
		return nil
	end

	return activityId
end

function SeasonCalendarModel:isSeasonIntroductionActivityOpen()
	return self:getOpenActivityIdByType(ActivityConst.EventType.SeasonIntroduction) ~= nil
end

function SeasonCalendarModel:getModuleList()
	local activityId = self:getOpenActivityIdByType(ActivityConst.EventType.SeasonIntroduction)
	local configList = activityId and SeasonIntroductionData[activityId]

	if not configList then
		return {}
	end

	local moduleList = {}
	local seasonCatchCalendarData = self:getSeasonCatchCalendarData()

	for moduleId, config in pairs(configList) do
		local moduleData = Utils.deepCopyTable(config)

		moduleData.type = moduleData.type or MODULE_TYPE_COMMON_FIRST
		moduleData.id = moduleId

		if moduleData.type == MODULE_TYPE_SEASON_CATCH then
			moduleData.title = seasonCatchCalendarData and seasonCatchCalendarData.title
			moduleData.image = seasonCatchCalendarData and seasonCatchCalendarData.image or ""
		end

		moduleList[#moduleList + 1] = moduleData
	end

	table.sort(moduleList, function(left, right)
		local leftSort = left.sort or 0
		local rightSort = right.sort or 0

		if leftSort == rightSort then
			return left.id < right.id
		end

		return leftSort < rightSort
	end)

	return moduleList
end

function SeasonCalendarModel:getConfigTime(moduleData, fieldName)
	if not moduleData then
		return nil
	end

	return Utils.getConfigTimeOfArea(moduleData, fieldName)
end

function SeasonCalendarModel:getTemplateTwoButtonConfigs()
	return TEMPLATE_TWO_BUTTON_CONFIGS
end

function SeasonCalendarModel:getTreeActivityList(moduleData)
	local treeActivityTimeId = moduleData and moduleData.TreeActivityTime
	local configList = treeActivityTimeId and SeasonTreeActivityData[treeActivityTimeId]

	if not configList then
		return {}
	end

	local currentTime = Time.secondCache or Time.getSecond()
	local itemList = {}

	for index, config in ipairs(configList) do
		local itemData = Utils.deepCopyTable(config)
		local startTime = self:getConfigTime(itemData, "startTime")
		local endTime = self:getConfigTime(itemData, "endTime")
		local isFirstItem = index == 1

		itemData.state = self:_getTreeActivityState(currentTime, startTime, endTime, isFirstItem)
		itemData.timeText = self:_getTreeActivityTimeText(startTime, endTime, isFirstItem)
		itemData.index = index
		itemList[#itemList + 1] = itemData
	end

	return itemList
end

function SeasonCalendarModel:_getTreeActivityState(currentTime, startTime, endTime, isFirstItem)
	if not startTime or not endTime then
		return TREE_ACTIVITY_STATE_FUTURE
	end

	if currentTime < startTime then
		return isFirstItem and TREE_ACTIVITY_STATE_FIRST_CURRENT or TREE_ACTIVITY_STATE_FUTURE
	end

	if currentTime <= endTime then
		return isFirstItem and TREE_ACTIVITY_STATE_FIRST_CURRENT or TREE_ACTIVITY_STATE_CURRENT
	end

	return isFirstItem and TREE_ACTIVITY_STATE_FIRST_PAST or TREE_ACTIVITY_STATE_PAST
end

function SeasonCalendarModel:_getTreeActivityTimeText(startTime, endTime, isFirstItem)
	if not startTime or not isFirstItem and not endTime then
		return ""
	end

	local areaOffset = Const.TIME_AREA_OFFSET_UTCO[Utils.getServerArea()] or 0
	local startAreaTime = os.date("!*t", startTime + areaOffset)

	if isFirstItem then
		return string.format(pg.getGameString("SEASON_GUIDE_TIME"), startAreaTime.month, startAreaTime.day)
	end

	local endAreaTime = os.date("!*t", endTime + areaOffset)

	return string.format("%02d.%02d-%02d.%02d", startAreaTime.month, startAreaTime.day, endAreaTime.month, endAreaTime.day)
end

function SeasonCalendarModel:getOpenTimeText(moduleData)
	local startTime = self:getConfigTime(moduleData, "startTime")

	if not startTime then
		return ""
	end

	local areaOffset = Const.TIME_AREA_OFFSET_UTCO[Utils.getServerArea()] or 0
	local areaTime = os.date("!*t", startTime + areaOffset)

	return pg.getFormatText(pg.getGameString("SEASON_OPEN_DATE"), areaTime.month, areaTime.day)
end

function SeasonCalendarModel:getSourceData(sourceId)
	return sourceId and ItemSourceData[sourceId]
end

function SeasonCalendarModel:getCurrentSeasonActivityField(fieldName)
	local seasonStageInfo = Utils.getCurrentSeasonStage()
	local seasonActivityData = seasonStageInfo and SeasonActivityData[seasonStageInfo.seasonId]

	if not seasonActivityData then
		return nil
	end

	local seasonStageActivityData = seasonActivityData[seasonStageInfo.stageId]
	local fieldValue = seasonStageActivityData and seasonStageActivityData[fieldName]

	if fieldValue ~= nil and fieldValue ~= "" then
		return fieldValue
	end

	local firstStageActivityData = seasonActivityData[1]

	return firstStageActivityData and firstStageActivityData[fieldName]
end

function SeasonCalendarModel:_getCurrentSeasonActivityTime(fieldName)
	local fieldValue = self:getCurrentSeasonActivityField(fieldName)

	return Utils.getConfigTimeOfArea({
		[fieldName] = fieldValue
	}, fieldName)
end

function SeasonCalendarModel:getSeasonCatchCalendarData()
	local currentTime = Time.secondCache or Time.getSecond()
	local phaseOneStartTime = self:_getCurrentSeasonActivityTime("buttonStartTime1")
	local phaseTwoStartTime = self:_getCurrentSeasonActivityTime("buttonStartTime2")
	local phase

	if phaseTwoStartTime and phaseTwoStartTime <= currentTime then
		phase = 2
	elseif phaseOneStartTime and phaseOneStartTime <= currentTime then
		phase = 1
	end

	if not phase then
		return nil
	end

	return {
		title = self:getCurrentSeasonActivityField("buttonText" .. phase),
		image = self:getCurrentSeasonActivityField("calendarImage" .. phase) or ""
	}
end

return SeasonCalendarModel
