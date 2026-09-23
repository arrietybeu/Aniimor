-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetChangeForm\\PetChangeFormView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetChangeFormView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetChangeFormView = Class.LightClass("PetChangeFormView", UIView)

function PetChangeFormView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.popupObjectReference = self.objectReference:GetRefValue("popupObjectReference")
	self.petDetailsObjectReference = self.objectReference:GetRefValue("petDetailsObjectReference")
	self.rootWidget = self.objectReference:GetRefValue("rootWidget")
end

function PetChangeFormView:registerObjects()
	return
end

function PetChangeFormView:initView()
	return
end

return PetChangeFormView
