-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RacingDungeon\\RacingDungeonView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local RacingDungeonView = Class.LightClass("RacingDungeonView", UIView)

function RacingDungeonView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.countDownText = self.objectReference:GetRefValue("countDownText")
	self.resultText1 = self.objectReference:GetRefValue("resultText1")
	self.resultText2 = self.objectReference:GetRefValue("resultText2")
	self.resultText3 = self.objectReference:GetRefValue("resultText3")
	self.evaluateWidget = self.objectReference:GetRefValue("evaluateWidget")
	self.container = self.objectReference:GetRefValue("container")
end

function RacingDungeonView:registerObjects()
	return
end

function RacingDungeonView:initView()
	return
end

return RacingDungeonView
