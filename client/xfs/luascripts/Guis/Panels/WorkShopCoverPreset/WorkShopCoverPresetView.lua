-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\WorkShopCoverPreset\\WorkShopCoverPresetView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local WorkShopCoverPresetView = Class.LightClass("WorkShopCoverPresetView", UIView)

function WorkShopCoverPresetView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.backUButton = self.objectReference:GetRefValue("backUButton")
	self.consoleKeyUList = self.objectReference:GetRefValue("consoleKeyUList")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.maskRayBoxTrans = self.objectReference:GetRefValue("maskRayBoxTrans")
	self.presetTitleUBaseText = self.objectReference:GetRefValue("presetTitleUBaseText")
	self.presetNumUBaseText = self.objectReference:GetRefValue("presetNumUBaseText")
	self.presetUList = self.objectReference:GetRefValue("presetUList")
	self.coverPresetUButton = self.objectReference:GetRefValue("coverPresetUButton")
end

function WorkShopCoverPresetView:registerObjects()
	return
end

function WorkShopCoverPresetView:initView()
	return
end

return WorkShopCoverPresetView
