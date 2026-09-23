-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FriendshipUp\\FriendshipUpView.lua

local logger = require("Core.Log.LoggerManager").getLogger("FriendshipUpView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local FriendshipUpView = Class.LightClass("FriendshipUpView", UIView)

function FriendshipUpView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.bgCloseUButton = objectReference:GetRefValue("bgCloseUButton")
	self.txtTipsUBaseText = objectReference:GetRefValue("txtTipsUBaseText")
	self.txtMyNameUBaseText = objectReference:GetRefValue("txtMyNameUBaseText")
	self.txtFriendNameUBaseText = objectReference:GetRefValue("txtFriendNameUBaseText")
	self.iconLikabilityBeforeUImage = objectReference:GetRefValue("iconLikabilityBeforeUImage")
	self.iconLikabilityAfterUImage = objectReference:GetRefValue("iconLikabilityAfterUImage")
	self.rawImageURawImage = objectReference:GetRefValue("rawImageURawImage")
	self.uIPopLikabilityUpUComponent = objectReference:GetRefValue("uIPopLikabilityUpUComponent")
	self.txtFriendNameChangeUSDFText = objectReference:GetRefValue("txtFriendNameChangeUSDFText")
	self.friendNameCoverUSDFText = objectReference:GetRefValue("friendNameCoverUSDFText")
	self.btnOpenUButton = objectReference:GetRefValue("btnOpenUButton")
	self.txtMyNameChangeUSDFText = objectReference:GetRefValue("txtMyNameChangeUSDFText")
	self.myNameCoverUSDFText = objectReference:GetRefValue("myNameCoverUSDFText")
	self.staticUIBlurEffect = objectReference:GetRefValue("staticUIBlurEffect")

	local openReference = self.btnOpenUButton:GetComponent("ObjectReference")

	self.openBtnTextUText = openReference:GetRefValue("txtNameUText")
end

function FriendshipUpView:registerObjects()
	return
end

function FriendshipUpView:initView()
	return
end

return FriendshipUpView
