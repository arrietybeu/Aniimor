-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RankReward\\RankRewardView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local RankRewardView = Class.LightClass("RankRewardView", UIView)

function RankRewardView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.titleUSDFText = objectReference:GetRefValue("titleUSDFText")
	self.listTab3thUList = objectReference:GetRefValue("listTab3thUList")
	self.txtDetailsUSDFText = objectReference:GetRefValue("txtDetailsUSDFText")
	self.listUList = objectReference:GetRefValue("listUList")
	self.tabUWidget = objectReference:GetRefValue("tabUWidget")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
end

return RankRewardView
