-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DirectPurchase\\DirectPurchaseView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local DirectPurchaseView = Class.LightClass("DirectPurchaseView", UIView)

function DirectPurchaseView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.titleUSDFText = objectReference:GetRefValue("title")
	self.listUList = objectReference:GetRefValue("listUList")
	self.rewardDescUSDFText = objectReference:GetRefValue("rewardDescUSDFText")
	self.nextTimeUWidget = objectReference:GetRefValue("nextTimeUWidget")
	self.nextTimeUButton = objectReference:GetRefValue("nextTimeUButton")
	self.nextTimeUSDFText = objectReference:GetRefValue("nextTimeUSDFText")
	self.cancelBtn = objectReference:GetRefValue("cancelBtn")
	self.confirmBtn = objectReference:GetRefValue("confirmBtn")
end

return DirectPurchaseView
