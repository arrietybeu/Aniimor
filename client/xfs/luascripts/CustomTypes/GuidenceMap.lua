-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\GuidenceMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local GuidenceItem = require("CustomTypes.GuidenceItem")
local GuidenceItemData = require("Data.guidence_item_data")
local Const = require("Common.Const.Const")
local ToBool = ToBool
local GuidenceMap = class.LiteClass("GuidenceMap", CustomDict)

function GuidenceMap:unlockHelpItem(guidenceId)
	local isallowed, targetList = self:_checkIsAllowedUnlocked(guidenceId)

	if not isallowed then
		return false
	else
		targetList:insert(GuidenceItem({
			guidenceId = guidenceId,
			timeStamp = math.floor(Time.secondCache)
		}))

		return true
	end
end

function GuidenceMap:_checkIsAllowedUnlocked(guidenceId)
	local guidanceType = GuidenceItemData[guidenceId].type

	if not guidanceType then
		return false
	end

	if guidanceType >= Const.GUIDANCE_TYPE_MAX or guidanceType <= Const.GUIDANCE_TYPE_ALL then
		return false
	end

	local targetList = self[guidanceType]

	if targetList == nil then
		self[guidanceType] = {}
		targetList = self[guidanceType]
	end

	return not ToBool(targetList[guidenceId]), targetList
end

return GuidenceMap
