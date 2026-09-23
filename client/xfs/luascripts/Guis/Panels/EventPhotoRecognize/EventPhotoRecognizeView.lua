-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\EventPhotoRecognize\\EventPhotoRecognizeView.lua

local logger = require("Core.Log.LoggerManager").getLogger("EventPhotoRecognizeView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local EventPhotoRecognizeView = Class.LightClass("EventPhotoRecognizeView", UIView)

function EventPhotoRecognizeView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnClose = self.objectReference:GetRefValue("btnClose")
	self.photoUImage = self.objectReference:GetRefValue("photoUImage")
	self.locationText = self.objectReference:GetRefValue("locationText")
	self.timeUBaseText = self.objectReference:GetRefValue("timeUBaseText")
	self.recognizeText = self.objectReference:GetRefValue("recognizeText")
	self.clueUList = self.objectReference:GetRefValue("clueUList")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
end

function EventPhotoRecognizeView:registerObjects()
	return
end

function EventPhotoRecognizeView:initView()
	return
end

return EventPhotoRecognizeView
