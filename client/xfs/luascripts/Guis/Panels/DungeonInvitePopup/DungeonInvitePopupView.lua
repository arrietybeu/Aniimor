-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DungeonInvitePopup\\DungeonInvitePopupView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local DungeonInvitePopupView = Class.LightClass("DungeonInvitePopupView", UIView)

function DungeonInvitePopupView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.listUList = self.objectReference:GetRefValue("listUList")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.btnCancelUButton = self.objectReference:GetRefValue("btnCancelUButton")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
end

function DungeonInvitePopupView:registerObjects()
	return
end

function DungeonInvitePopupView:initView()
	return
end

return DungeonInvitePopupView
