-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TeamRoomDungeonSelect\\TeamRoomDungeonSelectView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TeamRoomDungeonSelectView = Class.LightClass("TeamRoomDungeonSelectView", UIView)

function TeamRoomDungeonSelectView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.listUList = objectReference:GetRefValue("listUList")
	self.bgCloseUButton = objectReference:GetRefValue("bgCloseUButton")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.txtTipsUSDFText = objectReference:GetRefValue("txtTipsUSDFText")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.textTitleUSDFText = objectReference:GetRefValue("textTitleUSDFText")
	self.txtConfirmUSDFText = objectReference:GetRefValue("txtConfirmUSDFText")
end

return TeamRoomDungeonSelectView
