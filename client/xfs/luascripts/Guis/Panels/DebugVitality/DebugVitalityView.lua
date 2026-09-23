-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DebugVitality\\DebugVitalityView.lua

local logger = require("Core.Log.LoggerManager").getLogger("DebugVitalityView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local DebugVitalityView = Class.LightClass("DebugVitalityView", UIView)

function DebugVitalityView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnClose = self.objectReference:GetRefValue("btnClose")
	self.itemList = self.objectReference:GetRefValue("itemList")
end

function DebugVitalityView:registerObjects()
	return
end

function DebugVitalityView:initView()
	return
end

return DebugVitalityView
