-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\CatchReportMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local CatchReportMap = class.LiteClass("CatchReportMap", CustomDict)

function CatchReportMap:getTotalMoney()
	local total = 0

	for _, v in self:items() do
		total = total + v.moneyNum
	end

	return total
end

function CatchReportMap:getTotalItemRewards()
	local rewards = {}

	for _, v in self:items() do
		if v.itemRewardMap then
			for reward, count in pairs(v.itemRewardMap) do
				rewards[reward] = (rewards[reward] or 0) + count
			end
		end
	end

	return rewards
end

function CatchReportMap:getBiEntries()
	local res = {}

	for k, v in self:items() do
		res[#res + 1] = {
			k,
			v.count,
			v.moneyNum
		}
	end

	return res
end

return CatchReportMap
