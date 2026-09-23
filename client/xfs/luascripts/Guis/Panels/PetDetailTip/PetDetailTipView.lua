-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetDetailTip\\PetDetailTipView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetDetailTipView = Class.LightClass("PetDetailTipView", UIView)

function PetDetailTipView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.imgOrientationUImage = self.objectReference:GetRefValue("imgOrientationUImage")
	self.txtNumUBaseText = self.objectReference:GetRefValue("txtNumUBaseText")
	self.txtNameUBaseText = self.objectReference:GetRefValue("txtNameUBaseText")
	self.txtDetailsUBaseText = self.objectReference:GetRefValue("txtDetailsUBaseText")
	self.listElementUList = self.objectReference:GetRefValue("listElementUList")
	self.txtRecommendUBaseText = self.objectReference:GetRefValue("txtRecommendUBaseText")
	self.listRecommendUList = self.objectReference:GetRefValue("listRecommendUList")
	self.hpNumberUBaseText = self.objectReference:GetRefValue("hpNumberUBaseText")
	self.attackNumberUBaseText = self.objectReference:GetRefValue("attackNumberUBaseText")
	self.defendNumberUBaseText = self.objectReference:GetRefValue("defendNumberUBaseText")
	self.quickNumberUBaseText = self.objectReference:GetRefValue("quickNumberUBaseText")
	self.magicDefendNumberUBaseText = self.objectReference:GetRefValue("magicDefendNumberUBaseText")
	self.magicAttackNumberUBaseText = self.objectReference:GetRefValue("magicAttackNumberUBaseText")
	self.hpUWidget = self.objectReference:GetRefValue("hpUWidget")
	self.attackUWidget = self.objectReference:GetRefValue("attackUWidget")
	self.defendUWidget = self.objectReference:GetRefValue("defendUWidget")
	self.quickUWidget = self.objectReference:GetRefValue("quickUWidget")
	self.magicDefendUWidget = self.objectReference:GetRefValue("magicDefendUWidget")
	self.magicAttackUWidget = self.objectReference:GetRefValue("magicAttackUWidget")
	self.hpRateUWidget = self.objectReference:GetRefValue("hpRateUWidget")
	self.magicAttackRateUWidget = self.objectReference:GetRefValue("magicAttackRateUWidget")
	self.magicDefendRateUWidget = self.objectReference:GetRefValue("magicDefendRateUWidget")
	self.quickRateUWidget = self.objectReference:GetRefValue("quickRateUWidget")
	self.defendRateUWidget = self.objectReference:GetRefValue("defendRateUWidget")
	self.attackRateUWidget = self.objectReference:GetRefValue("attackRateUWidget")
	self.imgPetUImage = self.objectReference:GetRefValue("imgPetUImage")
	self.featureTxtTitle = self.objectReference:GetRefValue("featureTxtTitle")
	self.featureListUList = self.objectReference:GetRefValue("featureListUList")
	self.skillTxtTitle = self.objectReference:GetRefValue("skillTxtTitle")
	self.listSkillUList = self.objectReference:GetRefValue("listSkillUList")
	self.skillUniqueUButton = self.objectReference:GetRefValue("skillUniqueUButton")
	self.uniqueSkillName = self.objectReference:GetRefValue("uniqueSkillName")
	self.uniqueIconSkillUImage = self.objectReference:GetRefValue("uniqueIconSkillUImage")
	self.skillExploreUButton = self.objectReference:GetRefValue("skillExploreUButton")
	self.iconExploreSkillUImage = self.objectReference:GetRefValue("iconExploreSkillUImage")
	self.iconExploreSkillName = self.objectReference:GetRefValue("iconExploreSkillName")
	self.txtTitle2UBaseText = self.objectReference:GetRefValue("txtTitle2UBaseText")
	self.actionTxtTitle = self.objectReference:GetRefValue("actionTxtTitle")
	self.listAbilityUList = self.objectReference:GetRefValue("listAbilityUList")
	self.listSpecificUList = self.objectReference:GetRefValue("listSpecificUList")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.rawImageRawImagePro = self.objectReference:GetRefValue("rawImgPetRawImagePro")
	self.line1UWidget = self.objectReference:GetRefValue("line1UWidget")
	self.line2UWidget = self.objectReference:GetRefValue("line2UWidget")
	self.btnPetManualDisplayUButton = self.objectReference:GetRefValue("btnPetManualDisplayUButton")
	self.btnPetManualUButton = self.objectReference:GetRefValue("btnPetManualUButton")
	self.titleUWidget = self.objectReference:GetRefValue("titleUWidget")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.titlePetList = self.objectReference:GetRefValue("titlePetList")
	self.txtTitleUBaseText = self.objectReference:GetRefValue("txtTitleUBaseText")
end

local tabComs = {}

function PetDetailTipView:getItemComs(btn)
	if tabComs[btn] == nil then
		local objectReference = btn.transform:GetComponent("ObjectReference")

		tabComs[btn] = {}
		tabComs[btn].itemObj = objectReference
		tabComs[btn].button = objectReference:GetRefValue("button")
		tabComs[btn].image = objectReference:GetRefValue("image")
		tabComs[btn].name = objectReference:GetRefValue("name")
	end

	return tabComs[btn]
end

function PetDetailTipView:registerObjects()
	return
end

function PetDetailTipView:initView()
	return
end

function PetDetailTipView:setResearchProgress()
	return
end

function PetDetailTipView:onDestroy()
	for k in next, tabComs do
		tabComs[k] = nil
	end
end

return PetDetailTipView
