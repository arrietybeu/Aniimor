-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AreaActivity\\AreaActivityView.lua

local logger = require("Core.Log.LoggerManager").getLogger("AreaActivityView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local AreaActivityView = Class.LightClass("AreaActivityView", UIView)

function AreaActivityView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.tMPUBaseText = objectReference:GetRefValue("tMPUBaseText")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	self.titleTxt = objectReference:GetRefValue("titleTxt")
	self.emoUImage = objectReference:GetRefValue("emoUImage")
	self.describeUBaseText = objectReference:GetRefValue("describeUBaseText")
	self.nextUButton = objectReference:GetRefValue("nextUButton")
	self.previousUButton = objectReference:GetRefValue("previousUButton")
	self.taskUList = objectReference:GetRefValue("taskUList")
	self.btnGotoUButton = objectReference:GetRefValue("btnGotoUButton")
	self.getAllBtn = objectReference:GetRefValue("getAllBtn")
	self.bigBubbleUWidget = objectReference:GetRefValue("bigBubbleUWidget")
	self.lslandsUImage = objectReference:GetRefValue("lslandsUImage")
	self.rootAnimation = objectReference:GetRefValue("rootAnimation")
	self.bigBubbleDownTxt = objectReference:GetRefValue("bigBubbleDownTxt")
	self.rewardListUList = objectReference:GetRefValue("rewardListUList")
end

function AreaActivityView:registerObjects()
	return
end

function AreaActivityView:initView()
	return
end

return AreaActivityView
