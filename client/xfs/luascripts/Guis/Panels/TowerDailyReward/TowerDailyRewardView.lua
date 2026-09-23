-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerDailyReward\\TowerDailyRewardView.lua

local logger = require("Core.Log.LoggerManager").getLogger("TowerDailyRewardView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TowerDailyRewardView = Class.LightClass("TowerDailyRewardView", UIView)

function TowerDailyRewardView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.titleUBaseText = objectReference:GetRefValue("titleUBaseText")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	self.rewardPreviewUList = objectReference:GetRefValue("rewardPreviewUList")
	self.rewardUBaseText = objectReference:GetRefValue("rewardUBaseText")
	self.curRewardUList = objectReference:GetRefValue("curRewardUList")
	self.getRewardUButton = objectReference:GetRefValue("getRewardUButton")
	self.receivedUBaseText = objectReference:GetRefValue("receivedUBaseText")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
end

function TowerDailyRewardView:registerObjects()
	local getRewardObjectReference = self.getRewardUButton:GetComponent("ObjectReference")

	self.getRewardUText = getRewardObjectReference:GetRefValue("txtNameUText")
end

function TowerDailyRewardView:initView()
	return
end

return TowerDailyRewardView
