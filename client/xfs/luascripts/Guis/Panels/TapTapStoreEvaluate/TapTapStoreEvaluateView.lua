-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TapTapStoreEvaluate\\TapTapStoreEvaluateView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TapTapStoreEvaluateView = Class.LightClass("TapTapStoreEvaluateView", UIView)

function TapTapStoreEvaluateView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.titleText = objectReference:GetRefValue("titleText")
	self.contextText = objectReference:GetRefValue("contextText")
	self.cancelBtn = objectReference:GetRefValue("cancelBtn")
	self.confirmBtn = objectReference:GetRefValue("confirmBtn")
	self.listUList = objectReference:GetRefValue("listUList")
	self.cancelText = self.cancelBtn:GetComponent("ObjectReference"):GetRefValue("txtNameUText")
	self.confirmText = self.confirmBtn:GetComponent("ObjectReference"):GetRefValue("txtNameUText")
end

return TapTapStoreEvaluateView
