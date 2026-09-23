-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Vietnamese18Warning\\Vietnamese18WarningView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local Vietnamese18WarningView = Class.LightClass("Vietnamese18WarningView", UIView)

function Vietnamese18WarningView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btn = objectReference:GetRefValue("btnUButton")
	self.btnRectTransform = objectReference:GetRefValue("btnRectTransform")
end

return Vietnamese18WarningView
