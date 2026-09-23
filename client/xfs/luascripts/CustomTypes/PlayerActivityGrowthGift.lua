-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PlayerActivityGrowthGift.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local PlayerActivityGrowthGift = class.LiteClass("PlayerActivityGrowthGift", CustomDict)

function PlayerActivityGrowthGift:canTabOpen(startTime, endTime)
	if self.recvCollectAllWards == 1 then
		return false
	end

	return true
end

function PlayerActivityGrowthGift:canOpen(startTime, endTime)
	if self.recvCollectAllWards == 1 then
		return false
	end

	return true
end

return PlayerActivityGrowthGift
