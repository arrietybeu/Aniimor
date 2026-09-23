-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\CampCarDispatchInfo.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local CampCarDispatchInfo = Class.LiteClass("CampCarDispatchInfo", CustomDict)

function CampCarDispatchInfo:isDispatching()
	return self.endTs > 0 or self.isFinished
end

function CampCarDispatchInfo:canCreatePet()
	return self.endTs == 0
end

function CampCarDispatchInfo:checkIsFinished()
	return self.isFinished
end

return CampCarDispatchInfo
