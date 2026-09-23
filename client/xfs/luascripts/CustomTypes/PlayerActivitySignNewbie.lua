-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PlayerActivitySignNewbie.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local PlayerActivitySignNewbie = class.LiteClass("PlayerActivitySignNewbie", CustomDict)

function PlayerActivitySignNewbie:getContinueTotalSignNum()
	return self.continueTotalSignNum
end

function PlayerActivitySignNewbie:canTabOpen(startTime, endTime)
	if not self.activityBase:isGoing() and self.opened == 1 then
		return false
	end

	return true
end

function PlayerActivitySignNewbie:canOpen(startTime, endTime)
	if not self.activityBase:isGoing() and self.opened == 1 then
		return false
	end

	return true
end

return PlayerActivitySignNewbie
