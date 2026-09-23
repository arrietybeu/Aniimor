-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandFurnitureComposeDetail\\HomelandFurnitureComposeDetailView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandFurnitureComposeDetailView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandFurnitureComposeDetailView = Class.LightClass("HomelandFurnitureComposeDetailView", UIView)

function HomelandFurnitureComposeDetailView:findObjects()
	return
end

function HomelandFurnitureComposeDetailView:registerObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.listDetailsUList = objectReference:GetRefValue("listDetailsUList")
	self.listFurnitureUList = objectReference:GetRefValue("listFurnitureUList")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
	self.btnEditComposeNameUButton = objectReference:GetRefValue("btnEditComposeNameUButton")
	self.txtComposeNameUSDFText = objectReference:GetRefValue("txtComposeNameUSDFText")
	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.txtIDUSDFText = objectReference:GetRefValue("txtIDUSDFText")
	self.btnCopyIDUButton = objectReference:GetRefValue("btnCopyIDUButton")
	self.btnPhotoUButton = objectReference:GetRefValue("btnPhotoUButton")
	self.txtGoUSDFText = objectReference:GetRefValue("txtGoUSDFText")
	self.txtTitleDescUSDFText = objectReference:GetRefValue("txtTitleDescUSDFText")
	self.btnDescUButton = objectReference:GetRefValue("btnDescUButton")
	self.txtDescUSDFText = objectReference:GetRefValue("txtDescUSDFText")
	self.btn3thUButton = objectReference:GetRefValue("btn3thUButton")
	self.btn2ndUButton = objectReference:GetRefValue("btn2ndUButton")
	self.txtPreviewUSDFText = objectReference:GetRefValue("txtPreviewUSDFText")
	self.btn1stUButton = objectReference:GetRefValue("btn1stUButton")
	self.txtSaveUSDFText = objectReference:GetRefValue("txtSaveUSDFText")
	self.switchUWidget = objectReference:GetRefValue("switchUWidget")
	self.iconUWidget = objectReference:GetRefValue("iconUWidget")
	self.iconEditUImage = objectReference:GetRefValue("iconEditUImage")
	self.imgPicUImage = objectReference:GetRefValue("imgPicUImage")
end

function HomelandFurnitureComposeDetailView:initView()
	return
end

return HomelandFurnitureComposeDetailView
