-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\StarUpFinalBreak\\StarUpFinalBreakView.lua

local logger = require("Core.Log.LoggerManager").getLogger("StarUpFinalBreakView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local StarUpFinalBreakView = Class.LightClass("StarUpFinalBreakView", UIView)

function StarUpFinalBreakView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootUComp = objectReference:GetRefValue("rootUComp")
	self.txtTipsUSDFText = objectReference:GetRefValue("txtTipsUSDFText")
	self.listObtainUList = objectReference:GetRefValue("listObtainUList")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
end

function StarUpFinalBreakView:registerObjects()
	return
end

function StarUpFinalBreakView:initView()
	return
end

return StarUpFinalBreakView
