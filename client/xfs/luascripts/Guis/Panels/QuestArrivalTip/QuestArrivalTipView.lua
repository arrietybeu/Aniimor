-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\QuestArrivalTip\\QuestArrivalTipView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local QuestArrivalTipView = Class.LightClass("QuestArrivalTipView", UIView)

function QuestArrivalTipView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootAnimation = self.objectReference:GetRefValue("rootAnimation")
	self.textUBaseText = self.objectReference:GetRefValue("textUBaseText")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.widgetUWidget = self.objectReference:GetRefValue("widgetUWidget")
	self.safeBoxMobileUWidget = self.objectReference:GetRefValue("safeBoxMobileUWidget")
end

function QuestArrivalTipView:registerObjects()
	return
end

function QuestArrivalTipView:initView()
	return
end

return QuestArrivalTipView
