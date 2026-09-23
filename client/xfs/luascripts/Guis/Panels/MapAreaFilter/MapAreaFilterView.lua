-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MapAreaFilter\\MapAreaFilterView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local MapAreaFilterView = Class.LightClass("MapAreaFilterView", UIView)

function MapAreaFilterView:findObjects()
	return
end

function MapAreaFilterView:registerObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.closeBtn = objectReference:GetRefValue("closeBtn")
	self.resetBtn = objectReference:GetRefValue("resetBtn")
	self.countryList = objectReference:GetRefValue("countryList")
	self.mapAreaList = objectReference:GetRefValue("mapAreaList")
	self.smallMapAreaList = objectReference:GetRefValue("smallMapAreaList")
	self.confirmBtn = objectReference:GetRefValue("confirmBtn")
	self.countryCom = objectReference:GetRefValue("countryCom")
	self.mapAreaCom = objectReference:GetRefValue("mapAreaCom")
	self.smallMapAreaCom = objectReference:GetRefValue("smallMapAreaCom")
end

function MapAreaFilterView:initView()
	return
end

return MapAreaFilterView
