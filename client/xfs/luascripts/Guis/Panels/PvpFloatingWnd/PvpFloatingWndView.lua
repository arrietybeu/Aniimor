-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpFloatingWnd\\PvpFloatingWndView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PvpFloatingWndView = Class.LightClass("PvpFloatingWndView", UIView)

function PvpFloatingWndView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnMatch = self.objectReference:GetRefValue("btnMatch")
	self.txtName = self.objectReference:GetRefValue("txtName")
	self.timeCenter = self.objectReference:GetRefValue("timeCenter")
	self.timeTop = self.objectReference:GetRefValue("timeTop")
	self.timeBottom = self.objectReference:GetRefValue("timeBottom")
	self.timeLeft = self.objectReference:GetRefValue("timeLeft")
	self.timeRight = self.objectReference:GetRefValue("timeRight")
	self.selfRect = self.btnMatch:GetComponent("RectTransform")
end

function PvpFloatingWndView:registerObjects()
	return
end

function PvpFloatingWndView:initView()
	return
end

return PvpFloatingWndView
