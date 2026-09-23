-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FriendGroupSetup\\FriendGroupSetupView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local FriendGroupSetupView = Class.LightClass("FriendGroupSetupView", UIView)

function FriendGroupSetupView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.bgCloseUButton = objectReference:GetRefValue("bgCloseUButton")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.btnDismissUButton = objectReference:GetRefValue("btnDismissUButton")
	self.btnDismissTextUSDFText = self.btnDismissUButton.transform:GetComponent("ObjectReference"):GetRefValue("txtNameUText")
	self.memberListUList = objectReference:GetRefValue("memberListUList")
	self.textGroupNumUSDFText = objectReference:GetRefValue("textGroupNumUSDFText")
	self.btnEditUButton = objectReference:GetRefValue("btnEditUButton")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.textSubTitleUSDFText = objectReference:GetRefValue("textSubTitleUSDFText")
	self.textMemberTitleUSDFText = objectReference:GetRefValue("textMemberTitleUSDFText")
	self.textTitleUSDFText = objectReference:GetRefValue("textTitleUSDFText")
end

return FriendGroupSetupView
