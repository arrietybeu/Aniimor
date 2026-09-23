-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchFrontPage\\PetResearchFrontPageView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetResearchFrontPageView = Class.LightClass("PetResearchFrontPageView", UIView)
local ClientTextUtils = require("Utils.ClientTextUtils")

function PetResearchFrontPageView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.sliderUSlider = self.objectReference:GetRefValue("sliderUSlider")
	self.catchNumberObjectReference = self.objectReference:GetRefValue("catchNumberObjectReference")
	self.catchNumberStarObjectReference = self.objectReference:GetRefValue("catchNumberStarObjectReference")
	self.countryNameUSDFText = self.objectReference:GetRefValue("countryNameUSDFText")
	self.textUBaseText = self.objectReference:GetRefValue("textUBaseText")
	self.btnStarItem1 = self.objectReference:GetRefValue("btnStarItem1")
	self.btnStarItem2 = self.objectReference:GetRefValue("btnStarItem2")
	self.btnStarItem3 = self.objectReference:GetRefValue("btnStarItem3")
	self.btnStarItem4 = self.objectReference:GetRefValue("btnStarItem4")
	self.btnStarItem5 = self.objectReference:GetRefValue("btnStarItem5")
	self.btnStarItem6 = self.objectReference:GetRefValue("btnStarItem6")
	self.skillListUList = self.objectReference:GetRefValue("skillListUList")
	self.rewardListUList = self.objectReference:GetRefValue("rewardListUList")
	self.researchPointUBaseText = self.objectReference:GetRefValue("researchPointUBaseText")
	self.btnSubmitStar = self.objectReference:GetRefValue("btnSubmitStar")
	self.btnStarPreview = self.objectReference:GetRefValue("btnStarPreview")
	self.btnCountryShow = self.objectReference:GetRefValue("btnCountryShow")
	self.cardUImage = self.objectReference:GetRefValue("cardUImage")
	self.btnQuestionUButton = self.objectReference:GetRefValue("btnQuestionUButton")
	self.previewText = self.objectReference:GetRefValue("previewText")
	self.submitBtnTxt = self.objectReference:GetRefValue("submitBtnTxt")
	self.btnGetRewardUButton = self.objectReference:GetRefValue("btnGetRewardUButton")
end

function PetResearchFrontPageView:registerObjects()
	self.caughtTextUText = self.catchNumberObjectReference:GetRefValue("textUText")
	self.shinyTextUText = self.catchNumberStarObjectReference:GetRefValue("textUText")
	self.btnQuestionUButton.tooltipId = pg.getGameString("PET_MANUAL_STAR_TIPS")

	ClientTextUtils.setText(self.previewText, pg.getGameString("PET_MANUAL_STAR_REWARD"))
end

function PetResearchFrontPageView:initView()
	return
end

return PetResearchFrontPageView
