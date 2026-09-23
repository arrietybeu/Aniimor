-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DialogueModule\\DialogFunction\\DialogFunctionView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local DialogFunctionView = Class.LightClass("DialogFunctionView", UIView)

function DialogFunctionView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.returnBtn = self.objectReference:GetRefValue("returnBtn")
	self.contentList = self.objectReference:GetRefValue("contentList")
end

function DialogFunctionView:registerObjects()
	return
end

function DialogFunctionView:initView()
	return
end

return DialogFunctionView
