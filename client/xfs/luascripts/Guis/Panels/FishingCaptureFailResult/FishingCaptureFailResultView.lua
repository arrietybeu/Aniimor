-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FishingCaptureFailResult\\FishingCaptureFailResultView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local FishingCaptureConst = require("Common.Const.FishingCaptureConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local FishingCaptureFailResultView = Class.LightClass("FishingCaptureFailResultView", UIView)

function FishingCaptureFailResultView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootWidget = objectReference:GetRefValue("rootWidget")
	self.rewardList = objectReference:GetRefValue("rewardList")
	self.backGroundCloseUButton = objectReference:GetRefValue("backGroundCloseUButton")
	self.panelRewardUWidget = objectReference:GetRefValue("panelRewardUWidget")
	self.titleTxt = objectReference:GetRefValue("titleTxt")
	self.textUBaseText = objectReference:GetRefValue("textUBaseText")
end

function FishingCaptureFailResultView:registerObjects()
	return
end

function FishingCaptureFailResultView:initView()
	return
end

return FishingCaptureFailResultView
