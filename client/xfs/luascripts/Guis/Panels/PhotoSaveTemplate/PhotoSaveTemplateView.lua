-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotoSaveTemplate\\PhotoSaveTemplateView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PhotoSaveTemplateView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PhotoSaveTemplateView = Class.LightClass("PhotoSaveTemplateView", UIView)

function PhotoSaveTemplateView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.titleInputUTMPInputField = self.objectReference:GetRefValue("titleInputUTMPInputField")
	self.contentInputUTMPInputField = self.objectReference:GetRefValue("contentInputUTMPInputField")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
	self.btnCancelUButton = self.objectReference:GetRefValue("btnCancelUButton")
	self.photoUImage = self.objectReference:GetRefValue("photoUImage")
	self.titleLimitUBaseText = self.objectReference:GetRefValue("titleLimitUBaseText")
	self.contentLimitUBaseText = self.objectReference:GetRefValue("contentLimitUBaseText")
end

function PhotoSaveTemplateView:registerObjects()
	return
end

function PhotoSaveTemplateView:initView()
	return
end

return PhotoSaveTemplateView
