-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CatchRogueResult\\CatchRogueResultView.lua

local logger = require("Core.Log.LoggerManager").getLogger("CatchRogueResultView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CatchRogueResultView = Class.LightClass("CatchRogueResultView", UIView)

function CatchRogueResultView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootWidget = self.objectReference:GetRefValue("rootWidget")
	self.petList = self.objectReference:GetRefValue("petList")
	self.rewardList = self.objectReference:GetRefValue("rewardList")
	self.backGroundCloseUButton = self.objectReference:GetRefValue("backGroundCloseUButton")
	self.panelPetUWidget = self.objectReference:GetRefValue("panelPetUWidget")
	self.panelRewardUWidget = self.objectReference:GetRefValue("panelRewardUWidget")
	self.petEmptyTxt = self.objectReference:GetRefValue("petEmptyTxt")
end

function CatchRogueResultView:registerObjects()
	return
end

function CatchRogueResultView:initView()
	return
end

return CatchRogueResultView
