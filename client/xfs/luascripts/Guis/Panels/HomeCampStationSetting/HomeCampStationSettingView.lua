-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCampStationSetting\\HomeCampStationSettingView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeCampStationSettingView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomeCampStationSettingView = Class.LightClass("HomeCampStationSettingView", UIView)

function HomeCampStationSettingView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.btnClose2UButton = objectReference:GetRefValue("btnClose2UButton")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.listUList = objectReference:GetRefValue("listUList")
end

function HomeCampStationSettingView:registerObjects()
	return
end

function HomeCampStationSettingView:initView()
	return
end

return HomeCampStationSettingView
