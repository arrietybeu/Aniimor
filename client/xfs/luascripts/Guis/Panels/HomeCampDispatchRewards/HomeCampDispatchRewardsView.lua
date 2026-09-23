-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCampDispatchRewards\\HomeCampDispatchRewardsView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeCampDispatchRewardsView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomeCampDispatchRewardsView = Class.LightClass("HomeCampDispatchRewardsView", UIView)

function HomeCampDispatchRewardsView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listRewardUList = objectReference:GetRefValue("listRewardUList")
	self.backGroundCloseUButton = objectReference:GetRefValue("backGroundCloseUButton")
	self.txtAreaUSDFText = objectReference:GetRefValue("txtAreaUSDFText")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.btnAgainUButton = objectReference:GetRefValue("btnAgainUButton")
	self.againText = objectReference:GetRefValue("againText")
end

function HomeCampDispatchRewardsView:registerObjects()
	return
end

function HomeCampDispatchRewardsView:initView()
	return
end

return HomeCampDispatchRewardsView
