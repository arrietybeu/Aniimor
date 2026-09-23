-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ResourceClean\\ResourceCleanView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ResourceCleanView = Class.LightClass("ResourceCleanView", UIView)

function ResourceCleanView:findObjects()
	local rootObjectReference = self.transform:GetComponent("ObjectReference")

	self.popupUWidget = rootObjectReference:GetRefValue("popupUWidget")

	local objectReference = self.popupUWidget.transform:GetComponent("ObjectReference")

	self.titleText = objectReference:GetRefValue("titleText")
	self.rightUpCornerCloseBtn = objectReference:GetRefValue("rightUpCornerCloseBtn")
	self.cancelBtn = objectReference:GetRefValue("cancelBtn")
	self.confirmBtn = objectReference:GetRefValue("confirmBtn")
	self.listUList = objectReference:GetRefValue("listUList")
	self.txtTipsUSDFText = objectReference:GetRefValue("txtTipsUSDFText")
end

return ResourceCleanView
