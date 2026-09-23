-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PetResearch\\TraitResearchInfo.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local TraitResearchInfo = class.LiteClass("TraitResearchInfo", CustomDict)

function TraitResearchInfo:dump()
	return string.format("st=%s, reward=%s", Const.PET_RESEARCH.REPR_STATUS_EX[self.status], tostring(self.isRewarded))
end

return TraitResearchInfo
