-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonBuffInfoTip\\CommonBuffInfoTipView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CommonBuffInfoTipView = Class.LightClass("CommonBuffInfoTipView", UIView)

function CommonBuffInfoTipView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootCmp = self.objectReference:GetRefValue("rootCmp")
	self.buffNameUText = self.objectReference:GetRefValue("buffNameUText")
	self.buffNumUText = self.objectReference:GetRefValue("buffNumUText")
	self.buffDetailUText = self.objectReference:GetRefValue("buffDetailUText")
	self.iconUImage = self.objectReference:GetRefValue("iconUImage")
	self.skillBuffUContainer = self.objectReference:GetRefValue("skillBuffUContainer")
	self.ecsBuffUContainer = self.objectReference:GetRefValue("ecsBuffUContainer")
end

function CommonBuffInfoTipView:registerObjects()
	return
end

function CommonBuffInfoTipView:initView()
	return
end

return CommonBuffInfoTipView
