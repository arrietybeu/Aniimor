-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\SweepData.lua

local Class = require("Core.Framework.Class")
local SweepData = Class.LiteClass("SweepData")

function SweepData:ctor(position, rotation, lastTime)
	self.position = position
	self.rotation = rotation
	self.lastTime = lastTime
end

return SweepData
