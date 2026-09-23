-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotoDownloadTemplate\\PhotoDownloadTemplateView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PhotoDownloadTemplateView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PhotoDownloadTemplateView = Class.LightClass("PhotoDownloadTemplateView", UIView)

function PhotoDownloadTemplateView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.photoUImage = objectReference:GetRefValue("photoUImage")
	self.adaptationBoxUXAdaptionRect = objectReference:GetRefValue("adaptationBoxUXAdaptionRect")
	self.textNameUBaseText = objectReference:GetRefValue("textNameUBaseText")
	self.textDescUBaseText = objectReference:GetRefValue("textDescUBaseText")
	self.textUidUBaseText = objectReference:GetRefValue("textUidUBaseText")
	self.textCreatorUBaseText = objectReference:GetRefValue("textCreatorUBaseText")
	self.qRImgURawImage = objectReference:GetRefValue("qRImgURawImage")
	self.widgetRectTransform = objectReference:GetRefValue("widgetRectTransform")
	self.textPosUBaseText = objectReference:GetRefValue("textPosUBaseText")
	self.bgURound = objectReference:GetRefValue("bgURound")
	self.textPhotoCodeUBaseText = objectReference:GetRefValue("textPhotoCodeUBaseText")
	self.btnCopyUButton = objectReference:GetRefValue("btnCopyUButton")
	self.btnCopy1UButton = objectReference:GetRefValue("btnCopy1UButton")
	self.btnSaveUButton = objectReference:GetRefValue("btnSaveUButton")
	self.listBtnUList = objectReference:GetRefValue("listBtnUList")
end

function PhotoDownloadTemplateView:registerObjects()
	return
end

function PhotoDownloadTemplateView:initView()
	return
end

return PhotoDownloadTemplateView
