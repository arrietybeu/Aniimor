-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RogUltimateUpgrade\\RogUltimateUpgradeView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local RogUltimateUpgradeView = Class.LightClass("RogUltimateUpgradeView", UIView)

function RogUltimateUpgradeView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listBuff = objectReference:GetRefValue("listBuff")
	self.btnConfirm = objectReference:GetRefValue("btnConfirm")
	self.titleTipUBaseText = objectReference:GetRefValue("titleTipUBaseText")
	self.titleUBaseText = objectReference:GetRefValue("titleUBaseText")
end

return RogUltimateUpgradeView
