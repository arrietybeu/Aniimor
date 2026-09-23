-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonCustomInfoTip\\CommonCustomInfoTipView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CommonCustomInfoTipView = Class.LightClass("CommonCustomInfoTipView", UIView)

function CommonCustomInfoTipView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootCmp = self.objectReference:GetRefValue("rootCmp")
	self.buffNameUText = self.objectReference:GetRefValue("buffNameUText")
	self.buffNumUText = self.objectReference:GetRefValue("buffNumUText")
	self.buffDetailUText = self.objectReference:GetRefValue("buffDetailUText")
	self.iconUImage = self.objectReference:GetRefValue("iconUImage")
end

function CommonCustomInfoTipView:registerObjects()
	return
end

function CommonCustomInfoTipView:initView()
	return
end

return CommonCustomInfoTipView
