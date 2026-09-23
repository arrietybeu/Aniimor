-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RogEventRevival\\RogEventRevivalView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local RogEventRevivalView = Class.LightClass("RogEventRevivalView", UIView)

function RogEventRevivalView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootComponent = self.objectReference:GetRefValue("rootComponent")
	self.listPet = self.objectReference:GetRefValue("listPet")
	self.btnClose = self.objectReference:GetRefValue("btnClose")
	self.btnReset = self.objectReference:GetRefValue("btnReset")
	self.txtMoney = self.objectReference:GetRefValue("txtMoney")
end

return RogEventRevivalView
