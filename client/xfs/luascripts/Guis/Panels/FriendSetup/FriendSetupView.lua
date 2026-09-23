-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FriendSetup\\FriendSetupView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local FriendSetupView = Class.LightClass("FriendSetupView", UIView)

function FriendSetupView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.bgCloseUButton = objectReference:GetRefValue("bgCloseUButton")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.setupListUList = objectReference:GetRefValue("setupListUList")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.btnConfirmTextUSDFText = self.btnConfirmUButton.transform:GetComponent("ObjectReference"):GetRefValue("txtNameUText")
	self.nameInputField = objectReference:GetRefValue("nameInputField")
	self.searchInputField = objectReference:GetRefValue("searchInputField")
	self.txtLimitUSDFText = objectReference:GetRefValue("txtLimitUSDFText")
	self.textTitleUSDFText = objectReference:GetRefValue("textTitleUSDFText")
	self.textTopTitleUSDFText = objectReference:GetRefValue("textTopTitleUSDFText")
	self.placeHolderUSDFText = objectReference:GetRefValue("placeHolderUSDFText")
	self.groupNameHolderUSDFText = objectReference:GetRefValue("groupNameHolderUSDFText")
	self.btnSearchUButton = objectReference:GetRefValue("btnSearchUButton")
end

return FriendSetupView
