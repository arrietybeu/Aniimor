-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TotemWorship\\TotemWorshipView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TotemWorshipView = Class.LightClass("TotemWorshipView", UIView)

function TotemWorshipView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnClose = self.objectReference:GetRefValue("btnClose")
	self.levelNum = self.objectReference:GetRefValue("levelNum")
	self.fullLevelNum = self.objectReference:GetRefValue("fullLevelNum")
	self.fullLevelNum2 = self.objectReference:GetRefValue("fullLevelNum2")
	self.progressGroup = self.objectReference:GetRefValue("progressGroup")
	self.rewardList = self.objectReference:GetRefValue("rewardList")
	self.submitBtn1 = self.objectReference:GetRefValue("submitBtn1")
	self.submitBtn2 = self.objectReference:GetRefValue("submitBtn2")
	self.itemConsume = self.objectReference:GetRefValue("itemConsume")
end

function TotemWorshipView:registerObjects()
	self.widgetRoot = self.transform:Find("Widget"):GetComponent("UWidget")
end

function TotemWorshipView:initView()
	return
end

return TotemWorshipView
