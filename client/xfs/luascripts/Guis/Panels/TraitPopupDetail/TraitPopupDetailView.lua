-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TraitPopupDetail\\TraitPopupDetailView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TraitPopupDetailView = Class.LightClass("TraitPopupDetailView", UIView)

function TraitPopupDetailView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.bgBtnUButton = self.objectReference:GetRefValue("bgBtnUButton")
	self.petUImage = self.objectReference:GetRefValue("petUImage")
	self.iconUImage = self.objectReference:GetRefValue("iconUImage")
	self.title1UText = self.objectReference:GetRefValue("title1UText")
	self.detailUText = self.objectReference:GetRefValue("detailUText")
	self.title2UText = self.objectReference:GetRefValue("title2UText")
	self.numberUText = self.objectReference:GetRefValue("numberUText")
	self.btnViewUButton = self.objectReference:GetRefValue("btnViewUButton")
end

function TraitPopupDetailView:registerObjects()
	return
end

function TraitPopupDetailView:initView()
	return
end

return TraitPopupDetailView
