-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetSelect\\PetSelectView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetSelectView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetSelectView = Class.LightClass("PetSelectView", UIView)

function PetSelectView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.petListTransform = self.objectReference:GetRefValue("petListTransform")
	self.petInfoPanelTransform = self.objectReference:GetRefValue("petInfoPanelTransform")
	self.warningUBaseText = self.objectReference:GetRefValue("warningUBaseText")
	self.confirmBtn = self.objectReference:GetRefValue("confirmBtn")
	self.btnBack = self.objectReference:GetRefValue("btnBack")
	self.titleUBaseText = self.objectReference:GetRefValue("titleUBaseText")
	self.btnReleaseUButton = self.objectReference:GetRefValue("btnReleaseUButton")
end

function PetSelectView:registerObjects()
	return
end

function PetSelectView:initView()
	return
end

return PetSelectView
