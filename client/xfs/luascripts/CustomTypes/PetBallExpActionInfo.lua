-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PetBallExpActionInfo.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local lume = require("Core.Common.lume")
local PetBallData = require("Data.pet_ball_data")
local PetData = require("Data.pet_data")
local PetBallExpActionInfo = class.LiteClass("PetBallExpActionInfo", CustomDict)

function PetBallExpActionInfo:getRemainTime(curCountRemainTime)
	local interval, count = Utils.getExpActionTime(self.itemId), Utils.getExpActionCount(self.itemId)
	local remainTime = (self.itemCount * count - self.finishCount) * interval

	if curCountRemainTime ~= nil then
		remainTime = lume.clamp(remainTime - interval + curCountRemainTime, 0, remainTime)
	end

	return remainTime
end

return PetBallExpActionInfo
