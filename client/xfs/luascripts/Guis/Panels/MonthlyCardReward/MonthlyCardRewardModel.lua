-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MonthlyCardReward\\MonthlyCardRewardModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local MonthlyCardRewardModel = Class.LightClass("MonthlyCardRewardModel", UIModel)

function MonthlyCardRewardModel:ctor()
	self.storedDays = 0
	self.storedRewards = nil
	self.cumulativeDays = 0
end

return MonthlyCardRewardModel
