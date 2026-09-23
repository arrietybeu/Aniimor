-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpFriend\\PvpFriendView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PvpFriendView = Class.LightClass("PvpFriendView", UIView)

function PvpFriendView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnCloseOuter = self.objectReference:GetRefValue("btnCloseOuter")
	self.btnCloseInner = self.objectReference:GetRefValue("btnCloseInner")
	self.listFriends = self.objectReference:GetRefValue("listFriends")
	self.btnDisplay = self.objectReference:GetRefValue("btnDisplay")
	self.rootComponent = self.transform:GetComponent("UComponent")
end

function PvpFriendView:registerObjects()
	return
end

function PvpFriendView:initView()
	return
end

return PvpFriendView
