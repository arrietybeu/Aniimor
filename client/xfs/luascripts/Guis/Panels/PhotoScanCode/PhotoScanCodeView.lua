-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PhotoScanCode\\PhotoScanCodeView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PhotoScanCodeView")
local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIView = require("Guis.UIView")
local PhotoScanCodeView = Class.LightClass("PhotoScanCodeView", UIView)

function PhotoScanCodeView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnPasteUButton = objectReference:GetRefValue("btnPasteUButton")
	self.btnUseUButton = objectReference:GetRefValue("btnUseUButton")
	self.inputField = objectReference:GetRefValue("inputField")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.placeHolderUBaseText = objectReference:GetRefValue("placeHolderUBaseText")
	self.titleUBaseText = objectReference:GetRefValue("titleUBaseText")
	self.btnScanUButton = objectReference:GetRefValue("btnScanUButton")
end

function PhotoScanCodeView:registerObjects()
	return
end

function PhotoScanCodeView:initView()
	self:refreshText(false)
end

function PhotoScanCodeView:refreshText(isPhotographyStudio)
	local titleKey = isPhotographyStudio and "PHOTO_STUDIO_SCAN_IMPORT" or "PHOTO_SCAN_IMPORT"
	local placeHolderKey = isPhotographyStudio and "PHOTO_STUDIO_SCAN_INPUT" or "PHOTO_SCAN_INPUT"

	ClientTextUtils.setText(self.titleUBaseText, pg.getGameString(titleKey))
	ClientTextUtils.setText(self.placeHolderUBaseText, pg.getGameString(placeHolderKey))
end

return PhotoScanCodeView
