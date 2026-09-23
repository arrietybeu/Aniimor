-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BossRushReward\\BossRushRewardView.lua

local logger = require("Core.Log.LoggerManager").getLogger("BossRushRewardView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local BossRushRewardView = Class.LightClass("BossRushRewardView", UIView)

function BossRushRewardView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.rewardUList = self.objectReference:GetRefValue("rewardUList")
end

function BossRushRewardView:registerObjects()
	return
end

function BossRushRewardView:initView()
	return
end

return BossRushRewardView
