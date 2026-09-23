-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerSeasonWeeklyReward\\TowerSeasonWeeklyRewardView.lua

local logger = require("Core.Log.LoggerManager").getLogger("TowerSeasonWeeklyRewardView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TowerSeasonWeeklyRewardView = Class.LightClass("TowerSeasonWeeklyRewardView", UIView)
local ClientTextUtils = require("Utils.ClientTextUtils")

function TowerSeasonWeeklyRewardView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootComponent = objectReference:GetRefValue("rootComponent")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
	self.listTabUList = objectReference:GetRefValue("listTabUList")
	self.listRewardUList = objectReference:GetRefValue("listRewardUList")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.btnReceiveUButton = objectReference:GetRefValue("btnReceiveUButton")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.adaptationRectTransform = objectReference:GetRefValue("adaptationRectTransform")
end

function TowerSeasonWeeklyRewardView:registerObjects()
	return
end

function TowerSeasonWeeklyRewardView:initView()
	ClientTextUtils.setText(self.tMPUSDFText, pg.getGameString("Rogue_Week_Reward"))
end

return TowerSeasonWeeklyRewardView
