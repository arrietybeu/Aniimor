-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AvatarMain\\AvatarMainView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local AvatarMainView = Class.LightClass("AvatarMainView", UIView)

function AvatarMainView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.backUButton = self.objectReference:GetRefValue("backUButton")
	self.presetUList = self.objectReference:GetRefValue("presetUList")
	self.tipsUText = self.objectReference:GetRefValue("tipsUText")
	self.nextUButton = self.objectReference:GetRefValue("nextUButton")
	self.maskRayBoxTrans = self.objectReference:GetRefValue("maskRayBoxTrans")
	self.tab1UButton = self.objectReference:GetRefValue("tab1UButton")
	self.tab2UButton = self.objectReference:GetRefValue("tab2UButton")
	self.root = self.objectReference:GetRefValue("root")
	self.btnFusionUButton = self.objectReference:GetRefValue("btnFusionUButton")
	self.backgroundSelectorUSelector = self.objectReference:GetRefValue("backgroundSelectorUSelector")
	self.safeBoxMobileTransform = self.objectReference:GetRefValue("safeBoxMobileTransform")
	self.tMPUSDFText = self.objectReference:GetRefValue("tMPUSDFText")
end

function AvatarMainView:registerObjects()
	return
end

function AvatarMainView:initView()
	return
end

return AvatarMainView
