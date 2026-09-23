-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\SuperBigEggInfo.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local SuperBigEggInfo = class.LiteClass("SuperBigEggInfo", CustomDict)

function SuperBigEggInfo:canPick()
	return self.expireOpenTime > 0 and Time.secondCache > self.expireOpenTime
end

return SuperBigEggInfo
