-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpChose\\PvpChoseView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PvpChoseView = Class.LightClass("PvpChoseView", UIView)

function PvpChoseView:findObjects()
	self.component = self.transform:GetComponent("UComponent")
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.cutTo = self.objectReference:GetRefValue("cutTo")
	self.player1 = self.objectReference:GetRefValue("player1")
	self.player2 = self.objectReference:GetRefValue("player2")
	self.name1 = self.objectReference:GetRefValue("name1")
	self.name2 = self.objectReference:GetRefValue("name2")
	self.list1 = self.objectReference:GetRefValue("list1")
	self.list2 = self.objectReference:GetRefValue("list2")
	self.btnConfirm = self.objectReference:GetRefValue("btnConfirm")
	self.readyTip = self.objectReference:GetRefValue("readyTip")
	self.readyCountDown = self.objectReference:GetRefValue("readyCountDown")
	self.rankIcon1 = self.objectReference:GetRefValue("rankIcon1")
	self.rankIcon2 = self.objectReference:GetRefValue("rankIcon2")
	self.keyList = self.objectReference:GetRefValue("keyList")
end

function PvpChoseView:registerObjects()
	return
end

function PvpChoseView:initView()
	return
end

function PvpChoseView:initDefaultPits(defaultList)
	return
end

function PvpChoseView:instantiatePetItem(item, index, isLeft)
	return
end

return PvpChoseView
