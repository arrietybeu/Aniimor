-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CaptureBall\\CaptureBallView.lua

local logger = require("Core.Log.LoggerManager").getLogger("CaptureBallView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local CaptureBallView = Class.LightClass("CaptureBallView", UIView)

function CaptureBallView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.mobileUContainer = objectReference:GetRefValue("mobileUContainer")
	self.pcUContainer = objectReference:GetRefValue("pcUContainer")
	self.catchAimObjectReference = objectReference:GetRefValue("catchAimObjectReference")
end

function CaptureBallView:registerObjects()
	return
end

function CaptureBallView:initView()
	return
end

return CaptureBallView
