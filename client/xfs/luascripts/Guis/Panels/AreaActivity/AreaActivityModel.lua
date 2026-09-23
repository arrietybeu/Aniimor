-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AreaActivity\\AreaActivityModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("AreaActivityModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local EventAreaActivityData = require("Data.event_area_activity_data")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local EventTaskData = require("Data.event_task_data")
local AreaActivityModel = Class.LightClass("AreaActivityModel", UIModel)

function AreaActivityModel:checkSubTaskAvailable(eventPhase, curSubTaskIndex)
	if not eventPhase or not curSubTaskIndex then
		return false
	end

	local areaTaskData = EventAreaActivityData[eventPhase]

	if not areaTaskData then
		return false
	end

	local totalCnt = #areaTaskData.petResearchTaskGroupId
	local targetIndex = curSubTaskIndex

	if totalCnt < targetIndex then
		targetIndex = 0
	elseif targetIndex < 0 then
		targetIndex = totalCnt
	end

	return true, targetIndex
end

return AreaActivityModel
