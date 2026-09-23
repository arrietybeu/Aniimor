-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCarCampSwitch\\HomeCarCampSwitchCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeCarCampSwitchCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local HomeChangeStationComponent = require("Guis.Panels.HomeStationManage.Component.HomeChangeStationComponent")
local HomeCarCampSwitchCtrl = Class.LightClass("HomeCarCampSwitchCtrl", UICtrl)

HomeCarCampSwitchCtrl.messages = {}

function HomeCarCampSwitchCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.homeChangeStationComponent = HomeChangeStationComponent.new(self, self.view.containerUContainer)
end

function HomeCarCampSwitchCtrl:addListener()
	return
end

function HomeCarCampSwitchCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function HomeCarCampSwitchCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self.homeChangeStationComponent:refreshPageInfo()
end

function HomeCarCampSwitchCtrl:onShow()
	return
end

function HomeCarCampSwitchCtrl:onHide()
	return
end

return HomeCarCampSwitchCtrl
