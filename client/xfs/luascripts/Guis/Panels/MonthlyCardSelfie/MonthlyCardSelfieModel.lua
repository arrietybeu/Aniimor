-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MonthlyCardSelfie\\MonthlyCardSelfieModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local MonthlyCardSelfieModel = Class.LightClass("MonthlyCardSelfieModel", UIModel)

function MonthlyCardSelfieModel:ctor()
	self.rewardList = nil
	self.remainDays = 0
	self.cumulativeDays = 0
end

return MonthlyCardSelfieModel
