-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonItemTip\\CommonItemTipView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CommonItemTipView = Class.LightClass("CommonItemTipView", UIView)

function CommonItemTipView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.scrollInfo = self.objectReference:GetRefValue("scrollInfo")
	self.rootCmp = self.transform:GetComponent("UPopupForm")
	self.gamepadVirtualCloseBtnUButton = self.objectReference:GetRefValue("gamepadVirtualCloseBtnUButton")
end

function CommonItemTipView:registerObjects()
	return
end

function CommonItemTipView:initView()
	return
end

return CommonItemTipView
