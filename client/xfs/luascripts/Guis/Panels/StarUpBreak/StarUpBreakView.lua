-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\StarUpBreak\\StarUpBreakView.lua

local logger = require("Core.Log.LoggerManager").getLogger("StarUpBreakView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local StarUpBreakView = Class.LightClass("StarUpBreakView", UIView)

function StarUpBreakView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.txtBreakUSDFText = objectReference:GetRefValue("txtBreakUSDFText")
	self.starGradeUWidget = objectReference:GetRefValue("starGradeUWidget")
	self.txtTipsUSDFText = objectReference:GetRefValue("txtTipsUSDFText")
	self.listAttributeUList = objectReference:GetRefValue("listAttributeUList")
end

function StarUpBreakView:registerObjects()
	return
end

function StarUpBreakView:initView()
	return
end

return StarUpBreakView
