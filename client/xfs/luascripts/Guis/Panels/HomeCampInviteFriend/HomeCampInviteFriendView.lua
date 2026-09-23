-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCampInviteFriend\\HomeCampInviteFriendView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeCampInviteFriendView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomeCampInviteFriendView = Class.LightClass("HomeCampInviteFriendView", UIView)

function HomeCampInviteFriendView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.searchUTMPInputField = objectReference:GetRefValue("searchUTMPInputField")
	self.listUList = objectReference:GetRefValue("listUList")
	self.bgCloseUButton = objectReference:GetRefValue("bgCloseUButton")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.uIPbChatFriendlPopupUComponent = objectReference:GetRefValue("uIPbChatFriendlPopupUComponent")
	self.listTab3thUList = objectReference:GetRefValue("listTab3thUList")
	self.tabUWidget = objectReference:GetRefValue("tabUWidget")
	self.groupChatListUList = objectReference:GetRefValue("groupChatListUList")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.placeHolderUSDFText = objectReference:GetRefValue("placeHolderUSDFText")
end

function HomeCampInviteFriendView:registerObjects()
	return
end

function HomeCampInviteFriendView:initView()
	return
end

return HomeCampInviteFriendView
