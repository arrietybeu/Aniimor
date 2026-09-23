-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotoShow\\PhotoShowView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PhotoShowView = Class.LightClass("PhotoShowView", UIView)

function PhotoShowView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.photoUImage = self.objectReference:GetRefValue("photoUImage")
	self.titleUText = self.objectReference:GetRefValue("titleUText")
	self.detailUText = self.objectReference:GetRefValue("detailUText")
	self.iconUImage = self.objectReference:GetRefValue("iconUImage")
	self.frontUWidget = self.objectReference:GetRefValue("frontUWidget")
	self.btnSaveUButton = self.objectReference:GetRefValue("btnSaveUButton")
	self.btnShareUButton = self.objectReference:GetRefValue("btnShareUButton")
	self.btnScaleUButton = self.objectReference:GetRefValue("btnScaleUButton")
	self.btnHideUIUButton = self.objectReference:GetRefValue("btnHideUIUButton")
	self.bgBtnUButton = self.objectReference:GetRefValue("bgBtnUButton")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.timeUText = self.objectReference:GetRefValue("timeUText")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
end

function PhotoShowView:registerObjects()
	return
end

function PhotoShowView:initView()
	return
end

return PhotoShowView
