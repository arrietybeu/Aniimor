-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCarModify\\HomeCarModifyView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomeCarModifyView = Class.LightClass("HomeCarModifyView", UIView)

function HomeCarModifyView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.itemList = objectReference:GetRefValue("itemList")
	self.itemTitle = objectReference:GetRefValue("itemTitle")
	self.confirmBtn = objectReference:GetRefValue("confirmBtn")
	self.btnBack = objectReference:GetRefValue("btnBack")
	self.tabList = objectReference:GetRefValue("tabList")
	self.listPointUList = objectReference:GetRefValue("listPointUList")
end

return HomeCarModifyView
