-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RogVentureReward\\RogVentureRewardView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local RogVentureRewardView = Class.LightClass("RogVentureRewardView", UIView)

function RogVentureRewardView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.list = self.objectReference:GetRefValue("list")
	self.btnClose = self.objectReference:GetRefValue("btnClose")
end

return RogVentureRewardView
