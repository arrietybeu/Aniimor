-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetEvolvePetShow\\PetEvolvePetShowView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetEvolvePetShowView = Class.LightClass("PetEvolvePetShowView", UIView)

function PetEvolvePetShowView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.numberUText = self.objectReference:GetRefValue("numberUText")
	self.petNameUText = self.objectReference:GetRefValue("petNameUText")
	self.listUList = self.objectReference:GetRefValue("listUList")
	self.textCloseUText = self.objectReference:GetRefValue("textCloseUText")
	self.buttonCloseUButton = self.objectReference:GetRefValue("buttonCloseUButton")
	self.exploreText = self.objectReference:GetRefValue("exploreText")
	self.detailUText = self.objectReference:GetRefValue("detailUText")
	self.qualityIconUImage = self.objectReference:GetRefValue("qualityIconUImage")
	self.btnPetQualityUButton = self.objectReference:GetRefValue("btnPetQualityUButton")
	self.battleTypeIcon = self.objectReference:GetRefValue("battleTypeIcon")
	self.battleTypeUSDFText = self.objectReference:GetRefValue("battleTypeUSDFText")
	self.exploreSkillIconUImage = self.objectReference:GetRefValue("exploreSkillIconUImage")
	self.attributeIconUImage = self.objectReference:GetRefValue("attributeIconUImage")
	self.variantName1 = self.objectReference:GetRefValue("variantName1")
	self.variantName2 = self.objectReference:GetRefValue("variantName2")
	self.formName = self.objectReference:GetRefValue("formName")
	self.listTagUList = self.objectReference:GetRefValue("listTagUList")
	self.keyBUButton = self.objectReference:GetRefValue("keyBUButton")
	self.btnTipsUSDFText = self.objectReference:GetRefValue("btnTipsUSDFText")
	self.uIPbManualEvolvePetShowNewAnimation = self.objectReference:GetRefValue("uIPbManualEvolvePetShowNewAnimation")
	self.keyListConsoleBar = self.objectReference:GetRefValue("keyListConsoleBar")
end

function PetEvolvePetShowView:registerObjects()
	return
end

function PetEvolvePetShowView:initView()
	return
end

return PetEvolvePetShowView
