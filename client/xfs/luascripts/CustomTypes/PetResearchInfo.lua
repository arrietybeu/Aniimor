-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PetResearchInfo.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local PetResearchInfo = class.LiteClass("PetResearchInfo", CustomDict)

function PetResearchInfo:isUnlock()
	return self.status == Const.PET_RESEARCH.STATUS_DONE
end

function PetResearchInfo:dump()
	return string.format("st=%s", Const.PET_RESEARCH.REPR_STATUS[self.status])
end

return PetResearchInfo
