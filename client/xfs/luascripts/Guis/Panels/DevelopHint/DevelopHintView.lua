-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DevelopHint\\DevelopHintView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local DevelopHintView = Class.LightClass("DevelopHintView", UIView)

function DevelopHintView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.txtHintUText = self.objectReference:GetRefValue("txtHintUText")
end

function DevelopHintView:registerObjects()
	return
end

function DevelopHintView:initView()
	return
end

return DevelopHintView
