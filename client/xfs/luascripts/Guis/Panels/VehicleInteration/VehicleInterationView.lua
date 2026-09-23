-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\VehicleInteration\\VehicleInterationView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local VehicleInterationView = Class.LightClass("VehicleInterationView", UIView)

function VehicleInterationView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.seatListUList = self.objectReference:GetRefValue("seatListUList")
	self.interListUList = self.objectReference:GetRefValue("interListUList")
	self.bg = self.objectReference:GetRefValue("bg")
	self.numUBaseText = self.objectReference:GetRefValue("numUBaseText")
	self.btnExitObjectReference = self.objectReference:GetRefValue("btnExit")
	self.panelTimeRectTransform = self.objectReference:GetRefValue("panelTime")
	self.detailUWidget = self.objectReference:GetRefValue("detailUWidget")
end

function VehicleInterationView:registerObjects()
	return
end

function VehicleInterationView:initView()
	return
end

return VehicleInterationView
