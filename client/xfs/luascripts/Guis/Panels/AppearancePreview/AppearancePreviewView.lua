-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AppearancePreview\\AppearancePreviewView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local AppearancePreviewView = Class.LightClass("AppearancePreviewView", UIView)

function AppearancePreviewView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.consoleKeyUList = self.objectReference:GetRefValue("consoleKeyUList")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.rootUWidget = self.objectReference:GetRefValue("rootUWidget")
	self.verticalUButton = self.objectReference:GetRefValue("verticalUButton")
	self.horizontalUButton = self.objectReference:GetRefValue("horizontalUButton")
	self.maskRayBoxTrans = self.objectReference:GetRefValue("maskRayBoxTrans")
end

function AppearancePreviewView:registerObjects()
	return
end

function AppearancePreviewView:initView()
	return
end

return AppearancePreviewView
