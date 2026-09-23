-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudBreak\\HudBreakView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HudBreakView = Class.LightClass("HudBreakView", UIView)

function HudBreakView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.damageValue = self.objectReference:GetRefValue("damageValue")
	self.panel = self.objectReference:GetRefValue("panel")
	self.chainText = self.objectReference:GetRefValue("chainText")
	self.bonusText = self.objectReference:GetRefValue("bonusText")
	self.fullBonusText = self.objectReference:GetRefValue("fullBonusText")
	self.chainAnim = self.objectReference:GetRefValue("chainAnim")
	self.animPlayer = self.objectReference:GetRefValue("animPlayer")
	self.enemyBreakPlayer = self.objectReference:GetRefValue("enemyBreakPlayer")
	self.selfBreakPlayer = self.objectReference:GetRefValue("selfBreakPlayer")
end

function HudBreakView:registerObjects()
	return
end

function HudBreakView:initView()
	return
end

return HudBreakView
