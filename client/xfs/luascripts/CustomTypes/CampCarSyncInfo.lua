-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\CampCarSyncInfo.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local CampCarSyncInfo = Class.LiteClass("CampCarSyncInfo", CustomDict)

function CampCarSyncInfo:packData(campCar)
	self.likeCnt = campCar.likeCnt
	self.CampCarLoadValue = campCar.CampCarLoadValue or 0
	self.furnitureComfortValue = campCar.furnitureComfortValue or 0
	self.petComfortValue = campCar.petComfortValue or 0
end

return CampCarSyncInfo
