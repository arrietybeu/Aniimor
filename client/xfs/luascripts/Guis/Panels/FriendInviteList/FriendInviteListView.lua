-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FriendInviteList\\FriendInviteListView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local FriendInviteListView = Class.LightClass("FriendInviteListView", UIView)

function FriendInviteListView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.listUList = self.objectReference:GetRefValue("listUList")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.btnCancelUButton = self.objectReference:GetRefValue("btnCancelUButton")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
end

function FriendInviteListView:registerObjects()
	return
end

function FriendInviteListView:initView()
	return
end

return FriendInviteListView
