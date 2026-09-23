-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ThrowPanel\\ThrowPanelView.lua

local logger = require("Core.Log.LoggerManager").getLogger("ThrowPanelView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ThrowPanelView = Class.LightClass("ThrowPanelView", UIView)

function ThrowPanelView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootWidget = objectReference:GetRefValue("rootWidget")
	self.rootAnimation = objectReference:GetRefValue("rootAnimation")
	self.catchAimObjectReference = objectReference:GetRefValue("catchAimObjectReference")

	if self.catchAimObjectReference then
		local gameObject

		if self.catchAimObjectReference.gameObject then
			gameObject = self.catchAimObjectReference.gameObject
		elseif self.catchAimObjectReference.transform then
			gameObject = self.catchAimObjectReference.transform.gameObject
		end

		if gameObject then
			gameObject:SetActiveEx(false)
		end
	end
end

function ThrowPanelView:registerObjects()
	return
end

function ThrowPanelView:initView()
	return
end

return ThrowPanelView
