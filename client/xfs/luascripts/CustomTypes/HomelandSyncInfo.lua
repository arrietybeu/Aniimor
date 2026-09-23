-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\HomelandSyncInfo.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local HomelandSyncInfo = Class.LiteClass("HomelandSyncInfo", CustomDict)

function HomelandSyncInfo:packData(homeland)
	self.visitors = homeland.visitors:getRawTable()
end

return HomelandSyncInfo
