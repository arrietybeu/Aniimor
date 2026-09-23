-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RogEventVenture\\RogEventVentureView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local RogEventVentureView = Class.LightClass("RogEventVentureView", UIView)

function RogEventVentureView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootComponent = self.objectReference:GetRefValue("rootComponent")
	self.listReward = self.objectReference:GetRefValue("listReward")
	self.btnStart = self.objectReference:GetRefValue("btnStart")
	self.btnStop = self.objectReference:GetRefValue("btnStop")
	self.txtMoney = self.objectReference:GetRefValue("txtMoney")
	self.txtNumber = self.objectReference:GetRefValue("txtNumber")
	self.rootAnim = self.objectReference:GetRefValue("rootAnim")
	self.animSurprise = self.objectReference:GetRefValue("animSurprise")
	self.btnClose = self.objectReference:GetRefValue("btnClose")
end

return RogEventVentureView
