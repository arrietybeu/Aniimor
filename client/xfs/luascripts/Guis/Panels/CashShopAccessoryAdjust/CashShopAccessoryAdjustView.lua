-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashShopAccessoryAdjust\\CashShopAccessoryAdjustView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CashShopAccessoryAdjustView = Class.LightClass("CashShopAccessoryAdjustView", UIView)

function CashShopAccessoryAdjustView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.adjustUComponent = objectReference:GetRefValue("adjustUComponent")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.btnBuySaveUButton = objectReference:GetRefValue("btnBuySaveUButton")
	self.iconUImage = objectReference:GetRefValue("iconUImage")
	self.textUBaseText = objectReference:GetRefValue("textUBaseText")
	self.listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")
	self.layoutBoxCurrencyUWidget = objectReference:GetRefValue("layoutBoxCurrencyUWidget")
	self.txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
	self.tMPUBaseText = objectReference:GetRefValue("tMPUBaseText")
end

function CashShopAccessoryAdjustView:registerObjects()
	return
end

function CashShopAccessoryAdjustView:initView()
	return
end

return CashShopAccessoryAdjustView
