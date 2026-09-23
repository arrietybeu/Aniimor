-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AvatarImportConfirm\\AvatarImportConfirmView.lua

local logger = require("Core.Log.LoggerManager").getLogger("AvatarImportConfirmView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local AvatarImportConfirmView = Class.LightClass("AvatarImportConfirmView", UIView)

function AvatarImportConfirmView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.idUSDFText = self.objectReference:GetRefValue("idUSDFText")
	self.confirmUButton = self.objectReference:GetRefValue("confirmUButton")
	self.cancelUButton = self.objectReference:GetRefValue("cancelUButton")
	self.nameUBaseText = self.objectReference:GetRefValue("nameUBaseText")
	self.idUBaseText = self.objectReference:GetRefValue("idUBaseText")
	self.maskRayBoxTrans = self.objectReference:GetRefValue("maskRayBoxTrans")
	self.titleUSDFText = self.objectReference:GetRefValue("titleUSDFText")
end

function AvatarImportConfirmView:registerObjects()
	return
end

function AvatarImportConfirmView:initView()
	return
end

return AvatarImportConfirmView
