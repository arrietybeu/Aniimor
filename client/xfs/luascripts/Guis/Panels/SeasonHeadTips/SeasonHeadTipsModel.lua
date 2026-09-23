-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SeasonHeadTips\\SeasonHeadTipsModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local Utils = require("Common.Utils.Utils")
local SeasonActivityData = require("Data.season_activity_data")
local SeasonHeadTipsModel = Class.LightClass("SeasonHeadTipsModel", UIModel)

function SeasonHeadTipsModel:getCalendarGroups()
	return {}
end

function SeasonHeadTipsModel:getCurrentSeasonActivityField(fieldName)
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

function SeasonHeadTipsModel:getSubPopDesc()
	return self:getCurrentSeasonActivityField("subPopDesc")
end

return SeasonHeadTipsModel
