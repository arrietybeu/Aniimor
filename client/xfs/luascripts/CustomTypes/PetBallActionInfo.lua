-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PetBallActionInfo.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local Time = require("Core.Common.Time")
local PetBallData = require("Data.pet_ball_data")
local PetData = require("Data.pet_data")
local PetBallActionInfo = class.LiteClass("PetBallActionInfo", CustomDict)

return PetBallActionInfo
