-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlayerLvReward\\PlayerLvRewardView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PlayerLvRewardView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PlayerLvRewardView = Class.LightClass("PlayerLvRewardView", UIView)

function PlayerLvRewardView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnBack = self.objectReference:GetRefValue("btnBack")
	self.lvList = self.objectReference:GetRefValue("lvList")
end

function PlayerLvRewardView:registerObjects()
	return
end

function PlayerLvRewardView:initView()
	return
end

return PlayerLvRewardView
