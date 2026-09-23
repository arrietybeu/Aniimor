-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SeasonCalendar\\SeasonCalendarView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local SeasonCalendarView = Class.LightClass("SeasonCalendarView", UIView)

function SeasonCalendarView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.listModuleUList = objectReference:GetRefValue("listModuleUList")
	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.staticUIBlurEffect = objectReference:GetRefValue("staticUIBlurEffect")
end

function SeasonCalendarView:registerObjects()
	return
end

function SeasonCalendarView:initView()
	return
end

return SeasonCalendarView
