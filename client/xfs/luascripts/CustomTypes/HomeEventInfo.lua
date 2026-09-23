-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\HomeEventInfo.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local Time = require("Core.Common.Time")
local TimeUtils = require("Common.Utils.TimeUtils")
local HomeEventTypeData = require("Data.home_event_type_data")
local HomeEventTextData = require("Data.home_event_text_data")
local HomeEventInfo = class.LiteClass("HomeEventInfo", CustomDict)

function HomeEventInfo:getEventTypeData()
	local textData = HomeEventTextData[self.textId]

	if textData then
		return HomeEventTypeData[textData.eventType]
	end
end

function HomeEventInfo:dump()
	return {
		insId = self.eventInsId,
		textId = self.textId,
		targetIds = self.targetIds:getRawTable(),
		createTs = TimeUtils.timeStampToUtcString(self.createTs),
		solvedTs = self.solvedTs > 0 and TimeUtils.timeStampToUtcString(self.solvedTs) or nil
	}
end

return HomeEventInfo
