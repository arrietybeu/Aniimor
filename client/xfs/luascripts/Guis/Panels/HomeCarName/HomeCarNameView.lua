-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCarName\\HomeCarNameView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomeCarNameView = Class.LightClass("HomeCarNameView", UIView)

function HomeCarNameView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.inputField = self.objectReference:GetRefValue("inputField")
	self.txtTips = self.objectReference:GetRefValue("txtTips")
	self.btnRandom = self.objectReference:GetRefValue("btnRandom")
	self.btnEnter = self.objectReference:GetRefValue("btnEnter")
	self.rootComponent = self.transform:GetComponent("UComponent")
end

return HomeCarNameView
