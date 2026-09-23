-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ElementStrengthenDetails\\ElementStrengthenDetailsView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ElementStrengthenDetailsView = Class.LightClass("ElementStrengthenDetailsView", UIView)

function ElementStrengthenDetailsView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.btnCloseUButton2 = self.objectReference:GetRefValue("btnCloseUButton2")
	self.txtTltleUSDFText = self.objectReference:GetRefValue("txtTltleUSDFText")
	self.listAttriUList = self.objectReference:GetRefValue("listAttriUList")
	self.txtTipsUSDFText = self.objectReference:GetRefValue("txtTipsUSDFText")
end

return ElementStrengthenDetailsView
