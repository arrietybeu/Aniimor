-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetChangeFormSmall\\PetChangeFormSmallView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetChangeFormSmallView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetChangeFormSmallView = Class.LightClass("PetChangeFormSmallView", UIView)

function PetChangeFormSmallView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.popupObjectReference = self.objectReference:GetRefValue("popupObjectReference")
	self.petDetailsObjectReference = self.objectReference:GetRefValue("petDetailsObjectReference")
	self.rootWidget = self.objectReference:GetRefValue("rootWidget")
	self.blurPopUWidget = self.objectReference:GetRefValue("blurPopUWidget")
end

function PetChangeFormSmallView:registerObjects()
	return
end

function PetChangeFormSmallView:initView()
	return
end

return PetChangeFormSmallView
