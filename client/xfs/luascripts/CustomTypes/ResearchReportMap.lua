-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\ResearchReportMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local ResearchReportMap = class.LiteClass("ResearchReportMap", CustomDict)

function ResearchReportMap:getTotalPoint()
	local total = 0

	for _, v in self:items() do
		total = total + v.researchPoint
	end

	return total
end

function ResearchReportMap:getBiEntries()
	local res = {}

	for k, v in self:items() do
		res[#res + 1] = {
			k,
			v.count,
			v.researchPoint
		}
	end

	return res
end

return ResearchReportMap
