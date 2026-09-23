-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CreateRoleTimeline\\CreateRoleTimelineView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CreateRoleTimelineView = Class.LightClass("CreateRoleTimelineView", UIView)

function CreateRoleTimelineView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.root = objectReference:GetRefValue("root")
	self.btn1UButton = objectReference:GetRefValue("btn1UButton")
	self.btn2UButton = objectReference:GetRefValue("btn2UButton")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")
	self.leftDownTitleUSDFText = objectReference:GetRefValue("leftDownTitleUSDFText")
end

function CreateRoleTimelineView:registerObjects()
	return
end

function CreateRoleTimelineView:initView()
	return
end

return CreateRoleTimelineView
