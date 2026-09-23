-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FriendIntimacy\\FriendIntimacyView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local FriendIntimacyView = Class.LightClass("FriendIntimacyView", UIView)

function FriendIntimacyView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.avatarUButton = objectReference:GetRefValue("avatarUButton")
	self.textNameUSDFText = objectReference:GetRefValue("textNameUSDFText")
	self.iconLikabilityUImage = objectReference:GetRefValue("iconLikabilityUImage")
	self.intimacyListUList = objectReference:GetRefValue("intimacyListUList")
	self.infoUButton = objectReference:GetRefValue("infoUButton")

	local infoObjectReference = self.infoUButton:GetComponent("ObjectReference")

	self.infoTextUSDFText = infoObjectReference:GetRefValue("textUSDFText")
	self.btnBgCloseUButton = objectReference:GetRefValue("btnBgCloseUButton")
	self.IntimacyUSDFText = objectReference:GetRefValue("IntimacyUSDFText")
	self.numGetUSDFText = objectReference:GetRefValue("numGetUSDFText")
end

return FriendIntimacyView
