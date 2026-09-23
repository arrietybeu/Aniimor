-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\VitalityV0\\VitalityV0View.lua

local logger = require("Core.Log.LoggerManager").getLogger("VitalityV0View")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local VitalityV0View = Class.LightClass("VitalityV0View", UIView)

function VitalityV0View:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnClose = self.objectReference:GetRefValue("btnClose")
	self.btnClose2 = self.objectReference:GetRefValue("btnClose2")
	self.listUList = self.objectReference:GetRefValue("listUList")
	self.currencyItem = self.objectReference:GetRefValue("currencyItem")
end

function VitalityV0View:registerObjects()
	return
end

function VitalityV0View:initView()
	return
end

return VitalityV0View
