-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Reporter\\ReporterView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ReporterView = Class.LightClass("ReporterView", UIView)

function ReporterView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.component = self.transform:GetComponent("UComponent")
	self.pbPropSubmit = self.objectReference:GetRefValue("pbPropSubmit")
	self.keyList = self.objectReference:GetRefValue("keyList")
end

function ReporterView:registerObjects()
	return
end

function ReporterView:initView()
	return
end

return ReporterView
