-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PiecesItemTip\\PiecesItemTipView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PiecesItemTipView = Class.LightClass("PiecesItemTipView", UIView)

function PiecesItemTipView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.close = objectReference:GetRefValue("close")
	self.name = objectReference:GetRefValue("name")
	self.num = objectReference:GetRefValue("num")
	self.ownNum = objectReference:GetRefValue("ownNumItem")
	self.ownName = objectReference:GetRefValue("ownName")
	self.detail = objectReference:GetRefValue("detail")
	self.scrollDetail = objectReference:GetRefValue("scrollDetail")
	self.worldDetail = self.scrollDetail.content:GetComponent("UBaseText")
	self.icon = objectReference:GetRefValue("icon")
	self.uIPbTipsSpecialItemAnimation = objectReference:GetRefValue("icon")
	self.iconPropUImage = objectReference:GetRefValue("iconPropUImage")
	self.iconProp4UImage = objectReference:GetRefValue("iconProp4UImage")
	self.iconProp5UImage = objectReference:GetRefValue("iconProp5UImage")
	self.iconProp2UImage = objectReference:GetRefValue("iconProp2UImage")
	self.iconProp1UImage = objectReference:GetRefValue("iconProp1UImage")
	self.contentAnimation = objectReference:GetRefValue("contentAnimation")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.cmp = objectReference:GetRefValue("root")
	self.scanTransform = objectReference:GetRefValue("scanTransform")
	self.detail.supportRichText = true
	self.blurEffect = objectReference:GetRefValue("blurEffect")
end

function PiecesItemTipView:registerObjects()
	return
end

function PiecesItemTipView:initView()
	return
end

return PiecesItemTipView
