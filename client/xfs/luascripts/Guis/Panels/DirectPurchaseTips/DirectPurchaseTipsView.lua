-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DirectPurchaseTips\\DirectPurchaseTipsView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local DirectPurchaseTipsView = Class.LightClass("DirectPurchaseTipsView", UIView)

function DirectPurchaseTipsView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.titleUSDFText = objectReference:GetRefValue("titleUSDFText")
	self.tipsUSDFText = objectReference:GetRefValue("tipsUSDFText")
	self.btnUButton = objectReference:GetRefValue("btnUButton")
	self.progressUProgress = objectReference:GetRefValue("progressUProgress")
end

return DirectPurchaseTipsView
