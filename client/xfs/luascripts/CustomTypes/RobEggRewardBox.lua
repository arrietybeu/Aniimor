-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\RobEggRewardBox.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local RobEggRewardBox = class.LiteClass("RobEggRewardBox", CustomDict)

function RobEggRewardBox:clear()
	self.id = 0
	self.timestamp = 0
	self.achievedTime = 0
end

return RobEggRewardBox
