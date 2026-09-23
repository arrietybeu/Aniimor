-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandSeasonCelebrationInvite\\HomelandSeasonCelebrationInviteView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandSeasonCelebrationInviteView = Class.LightClass("HomelandSeasonCelebrationInviteView", UIView)

function HomelandSeasonCelebrationInviteView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.searchUTMPInputField = objectReference:GetRefValue("searchUTMPInputField")
	self.listUList = objectReference:GetRefValue("listUList")
	self.bgCloseUButton = objectReference:GetRefValue("bgCloseUButton")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")

	local confirmObjectReference = self.btnConfirmUButton:GetComponent("ObjectReference")

	self.txtNameUSDFText = confirmObjectReference:GetRefValue("txtNameUText")
	self.rootUComponent = objectReference:GetRefValue("uIPbChatFriendlPopupUComponent")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.inputHolderUSDFText = objectReference:GetRefValue("inputHolderUSDFText")
	self.btnDeleteUButton = objectReference:GetRefValue("btnDeleteUButton")
	self.keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")
end

function HomelandSeasonCelebrationInviteView:registerObjects()
	return
end

function HomelandSeasonCelebrationInviteView:initView()
	return
end

return HomelandSeasonCelebrationInviteView
