-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerWeeklyReward\\TowerWeeklyRewardView.lua

local logger = require("Core.Log.LoggerManager").getLogger("TowerWeeklyRewardView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TowerWeeklyRewardView = Class.LightClass("TowerWeeklyRewardView", UIView)

function TowerWeeklyRewardView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	self.textKillCountUBaseText = objectReference:GetRefValue("textKillCountUBaseText")
	self.weekUCountDown = objectReference:GetRefValue("weekUCountDown")
	self.progressUProgress = objectReference:GetRefValue("progressUProgress")
	self.reward1UButton = objectReference:GetRefValue("reward1UButton")
	self.reward2UButton = objectReference:GetRefValue("reward2UButton")
	self.reward3UButton = objectReference:GetRefValue("reward3UButton")
	self.reward4UButton = objectReference:GetRefValue("reward4UButton")
	self.reward5UButton = objectReference:GetRefValue("reward5UButton")
	self.reward6UButton = objectReference:GetRefValue("reward6UButton")
	self.btnClaimAllUButton = objectReference:GetRefValue("btnClaimAllUButton")
	self.bossKillUButton = objectReference:GetRefValue("bossKillUButton")
	self.staticUIBlurEffect = objectReference:GetRefValue("staticUIBlurEffect")
end

function TowerWeeklyRewardView:registerObjects()
	return
end

function TowerWeeklyRewardView:initView()
	return
end

return TowerWeeklyRewardView
