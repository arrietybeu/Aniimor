-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\HomeFoodSlotInfo.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local HomelandConfigData = require("Data.homeland_config_data")
local HomeFoodSlotInfo = class.LiteClass("HomeFoodSlotInfo", CustomDict)

function HomeFoodSlotInfo:isEmpty()
	local cur, max = self:getDisplayNum()

	return cur <= 0
end

function HomeFoodSlotInfo:isFull()
	local cur, max = self:getDisplayNum()

	return max <= cur
end

function HomeFoodSlotInfo:getDisplayNum()
	return self.itemNum, HomelandConfigData.foodItemMaxCount or 0
end

function HomeFoodSlotInfo:getCanAddNum(itemId, itemNum)
	if self.itemId ~= 0 and self.itemId ~= itemId then
		return 0
	end

	local cur, max = self:getDisplayNum()

	return math.min(max - cur, itemNum)
end

return HomeFoodSlotInfo
