-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandSeasonDailyTask\\HomelandSeasonDailyTaskView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandSeasonDailyTaskView = Class.LightClass("HomelandSeasonDailyTaskView", UIView)

function HomelandSeasonDailyTaskView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.txtSeasonNameUSDFText = objectReference:GetRefValue("txtSeasonNameUSDFText")
	self.listTaskUList = objectReference:GetRefValue("listTaskUList")
end

function HomelandSeasonDailyTaskView:registerObjects()
	return
end

function HomelandSeasonDailyTaskView:initView()
	return
end

return HomelandSeasonDailyTaskView
