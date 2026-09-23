-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpBattle\\PvpBattleView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PvpBattleView = Class.LightClass("PvpBattleView", UIView)

function PvpBattleView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.countDownOf = self.objectReference:GetRefValue("countDownOf")
	self.resultRect = self.objectReference:GetRefValue("resultRect")
	self.petList1 = self.objectReference:GetRefValue("petList1")
	self.name1 = self.objectReference:GetRefValue("name1")
	self.petList2 = self.objectReference:GetRefValue("petList2")
	self.name2 = self.objectReference:GetRefValue("name2")
	self.btRemandTime = self.objectReference:GetRefValue("btRemandTime")
	self.switchCountList = self.objectReference:GetRefValue("switchCountList")
	self.videoBG = self.objectReference:GetRefValue("videoBG")
	self.component = self.transform:GetComponent("UComponent")
end

function PvpBattleView:registerObjects()
	return
end

function PvpBattleView:initView()
	return
end

return PvpBattleView
