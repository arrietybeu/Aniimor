-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCarBuffPanel\\HomeCarBuffPanelView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeCarBuffPanelView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomeCarBuffPanelView = Class.LightClass("HomeCarBuffPanelView", UIView)

function HomeCarBuffPanelView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	self.listUList = objectReference:GetRefValue("listUList")
	self.txtStateUSDFText = objectReference:GetRefValue("txtStateUSDFText")
end

function HomeCarBuffPanelView:registerObjects()
	return
end

function HomeCarBuffPanelView:initView()
	return
end

return HomeCarBuffPanelView
