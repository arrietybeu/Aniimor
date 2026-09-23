-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\ResearchPointMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local ResearchPointMap = Class.LiteClass("ResearchPointMap", CustomDict)

function ResearchPointMap:getTotalPoint()
	local point = 0

	for subType, typeInfo in self:items() do
		point = point + typeInfo.researchPoint
	end

	return point
end

function ResearchPointMap:hasParams(biSource, biParams)
	local typeInfo = self[biSource]

	if typeInfo == nil then
		return false
	end

	for _, param in ipairs(typeInfo.biParamsList) do
		if table.equal(param, biParams) then
			return true
		end
	end

	return false
end

return ResearchPointMap
