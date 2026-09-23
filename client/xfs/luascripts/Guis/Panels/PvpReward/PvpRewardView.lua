-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpReward\\PvpRewardView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PvpRewardView = Class.LightClass("PvpRewardView", UIView)

function PvpRewardView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnRePlay = self.objectReference:GetRefValue("btnRePlay")
	self.btnLeave = self.objectReference:GetRefValue("btnLeave")
	self.timeLeave = self.objectReference:GetRefValue("timeLeave")
	self.playerDetail = self.objectReference:GetRefValue("playerDetail")
	self.panelAnimation = self.objectReference:GetRefValue("panelAnimation")
	self.playerList = self.objectReference:GetRefValue("playerList")
	self.name = self.playerDetail:GetRefValue("name")
	self.scoreNum = self.playerDetail:GetRefValue("scoreNum")
	self.scoreAddNum = self.playerDetail:GetRefValue("scoreAddNum")
	self.scoreNumFailure = self.playerDetail:GetRefValue("scoreNumFailure")
	self.scoreAddNumFailure = self.playerDetail:GetRefValue("scoreAddNumFailure")
	self.rootCmp = self.transform:GetComponent("UComponent")
end

function PvpRewardView:registerObjects()
	return
end

function PvpRewardView:initView()
	return
end

return PvpRewardView
