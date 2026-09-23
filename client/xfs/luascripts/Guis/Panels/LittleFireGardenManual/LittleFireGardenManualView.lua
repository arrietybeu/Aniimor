-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LittleFireGardenManual\\LittleFireGardenManualView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local LittleFireGardenManualView = Class.LightClass("LittleFireGardenManualView", UIView)

function LittleFireGardenManualView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.leftTabUList = objectReference:GetRefValue("leftTabUList")
	self.tips1UBaseText = objectReference:GetRefValue("tips1UBaseText")
	self.tips2UBaseText = objectReference:GetRefValue("tips2UBaseText")
	self.rankHead1UButton = objectReference:GetRefValue("rankHead1UButton")
	self.rankHead2UButton = objectReference:GetRefValue("rankHead2UButton")
	self.rankHead3UButton = objectReference:GetRefValue("rankHead3UButton")
	self.listRankUList = objectReference:GetRefValue("listRankUList")
	self.taskList = objectReference:GetRefValue("taskList")
	self.iconUImage = objectReference:GetRefValue("iconUImage")
	self.titleEmptyUBaseText = objectReference:GetRefValue("titleEmptyUBaseText")
	self.friendBtnUButton = objectReference:GetRefValue("friendBtnUButton")
	self.closeUButton = objectReference:GetRefValue("closeUButton")
end

function LittleFireGardenManualView:registerObjects()
	return
end

function LittleFireGardenManualView:initView()
	return
end

return LittleFireGardenManualView
