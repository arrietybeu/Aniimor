-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeGashaponRule\\HomeGashaponRuleView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomeGashaponRuleView = Class.LightClass("HomeGashaponRuleView", UIView)

function HomeGashaponRuleView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.closeUButton = objectReference:GetRefValue("closeUButton")
	self.txtTltleUSDFText = objectReference:GetRefValue("txtTltleUSDFText")
	self.scrollRectUScrollRect = objectReference:GetRefValue("scrollRectUScrollRect")
end

function HomeGashaponRuleView:registerObjects()
	return
end

function HomeGashaponRuleView:initView()
	return
end

return HomeGashaponRuleView
