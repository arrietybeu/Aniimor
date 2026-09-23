-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\InviteFriend\\InviteFriendView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local InviteFriendView = Class.LightClass("InviteFriendView", UIView)

function InviteFriendView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.friendList = objectReference:GetRefValue("friendList")
	self.searchUTMPInputField = objectReference:GetRefValue("searchUTMPInputField")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.btnClose1UButton = objectReference:GetRefValue("btnClose1UButton")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
end

function InviteFriendView:registerObjects()
	return
end

function InviteFriendView:initView()
	return
end

return InviteFriendView
