-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetConfirm\\PetConfirmView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetConfirmView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetConfirmView = Class.LightClass("PetConfirmView", UIView)

function PetConfirmView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.cancelUButton = self.objectReference:GetRefValue("cancelUButton")
	self.confirmUButton = self.objectReference:GetRefValue("confirmUButton")
	self.titleUBaseText = self.objectReference:GetRefValue("titleUBaseText")
	self.detailsUBaseText = self.objectReference:GetRefValue("detailsUBaseText")
	self.txtTipsUBaseText = self.objectReference:GetRefValue("txtTipsUBaseText")
	self.rawPetRawImagePro = self.objectReference:GetRefValue("rawPetRawImagePro")
end

function PetConfirmView:registerObjects()
	return
end

function PetConfirmView:initView()
	return
end

return PetConfirmView
