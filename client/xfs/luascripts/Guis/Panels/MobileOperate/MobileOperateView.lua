-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MobileOperate\\MobileOperateView.lua

local logger = require("Core.Log.LoggerManager").getLogger("MobileOperateView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local MobileOperateView = Class.LightClass("MobileOperateView", UIView)

function MobileOperateView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.joyStickUJoyStick = objectReference:GetRefValue("joyStickUJoyStick")
	self.cameraCtrlUWidget = objectReference:GetRefValue("cameraCtrlUWidget")
	self.clickObject = objectReference:GetRefValue("clickObject")
	self.safeMobileBoxUWidget = objectReference:GetRefValue("safeMobileBoxUWidget")
end

function MobileOperateView:registerObjects()
	return
end

function MobileOperateView:initView()
	return
end

return MobileOperateView
