-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeStationManage\\HomeStationManageView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeStationManageView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomeStationManageView = Class.LightClass("HomeStationManageView", UIView)

function HomeStationManageView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.stationManageUContainer = objectReference:GetRefValue("stationManageUContainer")
	self.stationSearchUContainer = objectReference:GetRefValue("stationSearchUContainer")
	self.campSwitchUContainer = objectReference:GetRefValue("campSwitchUContainer")
	self.listTabUList = objectReference:GetRefValue("listTabUList")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
end

function HomeStationManageView:registerObjects()
	return
end

function HomeStationManageView:initView()
	return
end

return HomeStationManageView
