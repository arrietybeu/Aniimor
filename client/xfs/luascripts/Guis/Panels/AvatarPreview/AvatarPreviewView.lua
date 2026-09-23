-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AvatarPreview\\AvatarPreviewView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local AvatarPreviewView = Class.LightClass("AvatarPreviewView", UIView)

function AvatarPreviewView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.backUButton = self.objectReference:GetRefValue("backUButton")
	self.tabUList = self.objectReference:GetRefValue("tabUList")
	self.selectUList = self.objectReference:GetRefValue("selectUList")
	self.actionUList = self.objectReference:GetRefValue("actionUList")
	self.nextUButton = self.objectReference:GetRefValue("nextUButton")
	self.infoIconUImage = self.objectReference:GetRefValue("infoIconUImage")
	self.infoNameUText = self.objectReference:GetRefValue("infoNameUText")
	self.maskRayBoxTrans = self.objectReference:GetRefValue("maskRayBoxTrans")
	self.titleShadowUSDFText = self.objectReference:GetRefValue("titleShadowUSDFText")
	self.informationUWidget = self.objectReference:GetRefValue("informationUWidget")
	self.backgroundSelectorUSelector = self.objectReference:GetRefValue("backgroundSelectorUSelector")
end

function AvatarPreviewView:registerObjects()
	return
end

function AvatarPreviewView:initView()
	return
end

return AvatarPreviewView
