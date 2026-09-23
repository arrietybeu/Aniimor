-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PetResearch\\EvolveResearchInfo.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local EvolveResearchInfo = class.LiteClass("EvolveResearchInfo", CustomDict)

function EvolveResearchInfo:dump()
	local cond_normal = {}
	local cond_item = {}

	for condId, status in self.normalConditionStatus:items() do
		cond_normal[condId] = Const.PET_RESEARCH.REPR_STATUS_EX[status]
	end

	for condId, status in self.itemConditionStatus:items() do
		cond_item[condId] = Const.PET_RESEARCH.REPR_STATUS_EX[status]
	end

	return string.format("st=%s, normal=%s, item=%s", Const.PET_RESEARCH.REPR_STATUS_EX[self.status], table.tostring(cond_normal), table.tostring(cond_item))
end

return EvolveResearchInfo
