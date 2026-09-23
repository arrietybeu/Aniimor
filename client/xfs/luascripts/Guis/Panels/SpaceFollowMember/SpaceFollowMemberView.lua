-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SpaceFollowMember\\SpaceFollowMemberView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local SpaceFollowMemberView = Class.LightClass("SpaceFollowMemberView", UIView)

function SpaceFollowMemberView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnCancelUButton = objectReference:GetRefValue("btnCancelUButton")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.listFollowerUList = objectReference:GetRefValue("listFollowerUList")
	self.textTimeUSDFText = objectReference:GetRefValue("textTimeUSDFText")
end

return SpaceFollowMemberView
