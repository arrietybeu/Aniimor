-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandFurnitureDesign\\HomelandFurnitureDesignView.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandFurnitureDesignView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HomelandFurnitureDesignView = Class.LightClass("HomelandFurnitureDesignView", UIView)

function HomelandFurnitureDesignView:findObjects()
	return
end

function HomelandFurnitureDesignView:registerObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
	self.listTabUList = objectReference:GetRefValue("listTabUList")
	self.listTabIconUList = objectReference:GetRefValue("listTabIconUList")
	self.txtEmptyUSDFText = objectReference:GetRefValue("txtEmptyUSDFText")
	self.txtNullUSDFText = objectReference:GetRefValue("txtNullUSDFText")
	self.btnImportUButton = objectReference:GetRefValue("btnImportUButton")
	self.txtImportUSDFText = objectReference:GetRefValue("txtImportUSDFText")
	self.selectorUSelector = objectReference:GetRefValue("selectorUSelector")
	self.txtAddUSDFText = objectReference:GetRefValue("txtAddUSDFText")
	self.txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	self.listDesignUList = objectReference:GetRefValue("listDesignUList")
	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.listDetailsUList = objectReference:GetRefValue("listDetailsUList")
	self.txtDecoUSDFText = objectReference:GetRefValue("txtDecoUSDFText")
	self.btnCopyIDUButton = objectReference:GetRefValue("btnCopyIDUButton")
	self.txtCodeUSDFText = objectReference:GetRefValue("txtCodeUSDFText")
	self.txtIDUSDFText = objectReference:GetRefValue("txtIDUSDFText")
	self.btnViewUButton = objectReference:GetRefValue("btnViewUButton")
	self.txtDetailUSDFText = objectReference:GetRefValue("txtDetailUSDFText")
end

function HomelandFurnitureDesignView:initView()
	return
end

return HomelandFurnitureDesignView
