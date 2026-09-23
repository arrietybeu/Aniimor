-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FirstPetShow\\FirstPetShowView.lua

local UIView = require("Guis.UIView")
local Class = require("Core.Framework.Class")
local FirstPetShowView = Class.LightClass("FirstPetShowView", UIView)

function FirstPetShowView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.elementListUList = self.objectReference:GetRefValue("elementListUList")
	self.txtDetailUText = self.objectReference:GetRefValue("txtDetailUText")
	self.txtNumUText = self.objectReference:GetRefValue("txtNumUText")
	self.panelUWidget = self.objectReference:GetRefValue("panelUWidget")
	self.rawImageURawImage = self.objectReference:GetRefValue("rawImageURawImage")
	self.name1 = self.objectReference:GetRefValue("name1")
	self.name2 = self.objectReference:GetRefValue("name2")
	self.animation = self.objectReference:GetRefValue("animation")
	self.rayBoxDragEventListener = self.objectReference:GetRefValue("rayBoxDragEventListener")
	self.manualPetSkillUButton = self.objectReference:GetRefValue("manualPetSkillUButton")
	self.exploreSkillIconUImage = self.objectReference:GetRefValue("exploreSkillIconUImage")
	self.attributeIconUImage = self.objectReference:GetRefValue("attributeIconUImage")
	self.qualityIconUImage = self.objectReference:GetRefValue("qualityIconUImage")
	self.btnPetQualityUButton = self.objectReference:GetRefValue("btnPetQualityUButton")
	self.skillNameUSDFText = self.objectReference:GetRefValue("skillNameUSDFText")
	self.battleTypeIcon = self.objectReference:GetRefValue("battleTypeIcon")
	self.levelText = self.objectReference:GetRefValue("levelText")
	self.openTip = self.objectReference:GetRefValue("openTip")
	self.battleTypeName = self.objectReference:GetRefValue("battleTypeName")
	self.petImage = self.objectReference:GetRefValue("petImage")
	self.variantName1 = self.objectReference:GetRefValue("variantName1")
	self.variantName2 = self.objectReference:GetRefValue("variantName2")
	self.formName = self.objectReference:GetRefValue("formName")
	self.formWidget = self.objectReference:GetRefValue("formWidget")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.listKeyUList = self.objectReference:GetRefValue("listKeyUList")
	self.textUSDFText = self.objectReference:GetRefValue("textUSDFText")
	self.shineCardUContainer = self.objectReference:GetRefValue("shineCardUContainer")
	self.vXPbHudPetFirstPar03UContainer = self.objectReference:GetRefValue("vXPbHudPetFirstPar03UContainer")
	self.vXPbHudPetFirstPar04UContainer = self.objectReference:GetRefValue("vXPbHudPetFirstPar04UContainer")
	self.vXPbHudPetFirstBlackFlashUContainer = self.objectReference:GetRefValue("vXPbHudPetFirstBlackFlashUContainer")
	self.textCloseUSDFText = self.objectReference:GetRefValue("textCloseUSDFText")
end

function FirstPetShowView:initView()
	return
end

return FirstPetShowView
