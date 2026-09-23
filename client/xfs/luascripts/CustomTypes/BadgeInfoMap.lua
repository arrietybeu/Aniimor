-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\BadgeInfoMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local lume = require("Core.Common.lume")
local BadgeCollectionData = require("Data.badge_collection_data")
local BadgeInfoData = require("Data.badge_info_data")
local BadgeCollectionConst = require("Common.Const.BadgeCollectionConst")
local BadgeInfoMap = class.LiteClass("BadgeInfoMap", CustomDict)
local math_floor = math.floor

function BadgeInfoMap:isOpenAllBadge()
	for i = 1, BadgeCollectionConst.Count do
		local data = self[i]

		if data and data.curQuality ~= 0 and not data.isOpen then
			return false
		end
	end

	return true
end

function BadgeInfoMap:updateMoneySum(oldValue, newValue)
	local changeValue = newValue - oldValue

	if newValue == self.moneySum then
		return
	elseif newValue >= self.moneySum then
		self.moneySum = newValue
	elseif changeValue > 0 then
		self.moneySum = self.moneySum + changeValue
	end
end

function BadgeInfoMap:randomQuality(badgeId)
	self[badgeId] = self[badgeId] or {}

	local badge = self[badgeId]
	local weightSum = BadgeInfoData.randomWeight or 0
	local badgeData = BadgeCollectionData
	local value = math_floor(lume.random(0, weightSum)) + 1

	weightSum = 0

	for i, data in pairs(badgeData) do
		weightSum = weightSum + data.unlockWeight

		if value <= weightSum then
			badge.randomQuality = i
			badge.curQuality = badge.randomQuality

			break
		end
	end

	if not badgeData[badge.randomQuality] then
		return
	end

	local revert = badgeData[badge.randomQuality].revert

	if revert then
		value = math_floor(lume.random(0, 100)) + 1

		if value <= revert then
			badge.isRevert = true
			badge.curQuality = self:getRevertQuality(badge.curQuality)
		end
	end
end

function BadgeInfoMap:getRevertQuality(quality)
	local list = BadgeInfoData.list or {}

	for i, data in ipairs(list) do
		if list[i + 1] == quality then
			return data
		end
	end

	return quality
end

function BadgeInfoMap:getUpgradeCost(badgeId)
	self[badgeId] = self[badgeId] or {}

	local badge = self[badgeId]

	if badge.isOpen == true then
		return BadgeCollectionConst.UpdateType.OPEN
	end

	local badgeData = BadgeCollectionData[badge.curQuality]

	if not badgeData then
		return BadgeCollectionConst.UpdateType.NODATA
	end

	local value = math_floor(lume.random(0, BadgeCollectionConst.BadgeRateMax)) + 1

	if value > badgeData.UpWeight then
		return BadgeCollectionConst.UpdateType.FAIL
	end

	if badgeData.nextLevel == nil then
		return BadgeCollectionConst.UpdateType.MAXLEVEL
	end

	badge.curQuality = badgeData.nextLevel

	return BadgeCollectionConst.UpdateType.SUCCESS
end

return BadgeInfoMap
