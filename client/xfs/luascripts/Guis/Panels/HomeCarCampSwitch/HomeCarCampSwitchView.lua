-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCarCampSwitch\\HomeCarCampSwitchView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeCarCampSwitchView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomeCarCampSwitchView = Class.LightClass("HomeCarCampSwitchView", UIView)

function HomeCarCampSwitchView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.containerUContainer = objectReference:GetRefValue("containerUContainer")
end

function HomeCarCampSwitchView:registerObjects()
	return
end

function HomeCarCampSwitchView:initView()
	return
end

return HomeCarCampSwitchView
