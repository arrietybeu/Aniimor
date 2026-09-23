-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ConfigTopping\\ConfigToppingView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ConfigToppingView = Class.LightClass("ConfigToppingView", UIView)

function ConfigToppingView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.areaDelRectTransform = self.objectReference:GetRefValue("areaDelRectTransform")
end

function ConfigToppingView:registerObjects()
	return
end

function ConfigToppingView:initView()
	return
end

return ConfigToppingView
