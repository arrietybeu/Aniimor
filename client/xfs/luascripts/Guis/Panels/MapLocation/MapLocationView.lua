-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MapLocation\\MapLocationView.lua

local UIView = require("Guis.UIView")
local Class = require("Core.Framework.Class")
local MapLocationView = Class.LightClass("MapLocationView", UIView)

function MapLocationView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.xInput = self.objectReference:GetRefValue("xInput")
	self.zInput = self.objectReference:GetRefValue("yInput")
	self.btnCancelUButton = self.objectReference:GetRefValue("btnCancelUButton")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.root = self.objectReference:GetRefValue("root")
	self.keyHandler = self.objectReference:GetRefValue("keyHandler")
	self.content = self.objectReference:GetRefValue("contentUWidget")
	self.downKeyUWidget = self.objectReference:GetRefValue("downKeyUWidget")
end

return MapLocationView
