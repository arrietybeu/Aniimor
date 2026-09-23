-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpLoading\\PvpLoadingView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PvpLoadingView = Class.LightClass("PvpLoadingView", UIView)

function PvpLoadingView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.player1 = self.objectReference:GetRefValue("player1")
	self.player2 = self.objectReference:GetRefValue("player2")
	self.name1 = self.objectReference:GetRefValue("name1")
	self.name2 = self.objectReference:GetRefValue("name2")
	self.progress = self.objectReference:GetRefValue("progress")
	self.rankIcon1 = self.objectReference:GetRefValue("rankIcon1")
	self.rankIcon2 = self.objectReference:GetRefValue("rankIcon2")
end

function PvpLoadingView:registerObjects()
	return
end

function PvpLoadingView:initView()
	return
end

return PvpLoadingView
