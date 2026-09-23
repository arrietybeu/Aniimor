-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\EventFriend\\EventFriendView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local EventFriendView = Class.LightClass("EventFriendView", UIView)

function EventFriendView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.bgCloseUButton = self.objectReference:GetRefValue("bgCloseUButton")
	self.friendUList = self.objectReference:GetRefValue("friendUList")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.textUBaseText = self.objectReference:GetRefValue("textUBaseText")
	self.txtEmptyUBaseText = self.objectReference:GetRefValue("txtEmptyUBaseText")
end

return EventFriendView
