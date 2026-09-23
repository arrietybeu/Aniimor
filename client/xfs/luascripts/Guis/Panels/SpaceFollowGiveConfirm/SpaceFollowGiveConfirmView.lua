-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SpaceFollowGiveConfirm\\SpaceFollowGiveConfirmView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local SpaceFollowGiveConfirmView = Class.LightClass("SpaceFollowGiveConfirmView", UIView)

function SpaceFollowGiveConfirmView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.textDetailUSDFText = objectReference:GetRefValue("textDetailUSDFText")
	self.txtTimeUSDFText = objectReference:GetRefValue("txtTimeUSDFText")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.btnCancelUButton = objectReference:GetRefValue("btnCancelUButton")
end

return SpaceFollowGiveConfirmView
