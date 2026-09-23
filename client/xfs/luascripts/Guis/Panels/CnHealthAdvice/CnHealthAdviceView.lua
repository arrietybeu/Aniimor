-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CnHealthAdvice\\CnHealthAdviceView.lua

local logger = require("Core.Log.LoggerManager").getLogger("CnHealthAdviceView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CnHealthAdviceView = Class.LightClass("CnHealthAdviceView", UIView)

function CnHealthAdviceView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.appDesc = self.objectReference:GetRefValue("appDesc")
	self.rootComponent = self.transform:GetComponent("UComponent")
end

function CnHealthAdviceView:registerObjects()
	return
end

function CnHealthAdviceView:initView()
	return
end

return CnHealthAdviceView
