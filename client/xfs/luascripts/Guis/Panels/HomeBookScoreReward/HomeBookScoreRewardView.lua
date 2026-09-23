-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeBookScoreReward\\HomeBookScoreRewardView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomeBookScoreRewardView = Class.LightClass("HomeBookScoreRewardView", UIView)

function HomeBookScoreRewardView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
	self.iconCampUImage = objectReference:GetRefValue("iconCampUImage")
	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.txtScoreTitleUSDFText = objectReference:GetRefValue("txtScoreTitleUSDFText")
	self.txtScoreNumUSDFText = objectReference:GetRefValue("txtScoreNumUSDFText")
	self.listRewardUList = objectReference:GetRefValue("listRewardUList")
end

function HomeBookScoreRewardView:registerObjects()
	return
end

function HomeBookScoreRewardView:initView()
	return
end

return HomeBookScoreRewardView
