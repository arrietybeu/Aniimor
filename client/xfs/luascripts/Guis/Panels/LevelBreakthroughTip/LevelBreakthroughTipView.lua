-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LevelBreakthroughTip\\LevelBreakthroughTipView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local LevelBreakthroughTipView = Class.LightClass("LevelBreakthroughTipView", UIView)

function LevelBreakthroughTipView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnCancelUButton = self.objectReference:GetRefValue("btnCancelUButton")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.rewardItemList1UList = self.objectReference:GetRefValue("rewardItemList1UList")
	self.rewardItemList2UList = self.objectReference:GetRefValue("rewardItemList2UList")
end

function LevelBreakthroughTipView:initView()
	return
end

return LevelBreakthroughTipView
