-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchFrontPageV2\\PetResearchFrontPageV2View.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetResearchFrontPageV2View")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetResearchFrontPageV2View = Class.LightClass("PetResearchFrontPageV2View", UIView)

function PetResearchFrontPageV2View:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.sliderUSlider = self.objectReference:GetRefValue("sliderUSlider")
	self.countryNameUSDFText = self.objectReference:GetRefValue("countryNameUSDFText")
	self.txtExp = self.objectReference:GetRefValue("txtExp")
	self.rewardListUList = self.objectReference:GetRefValue("rewardListUList")
	self.researchPointUBaseText = self.objectReference:GetRefValue("researchPointUBaseText")
	self.btnSubmitStar = self.objectReference:GetRefValue("btnSubmitStar")
	self.btnStarPreview = self.objectReference:GetRefValue("btnStarPreview")
	self.btnAreaSwitch = self.objectReference:GetRefValue("btnCountryShow")
	self.cardUImage = self.objectReference:GetRefValue("cardUImage")
	self.btnQuestionUButton = self.objectReference:GetRefValue("btnQuestionUButton")
	self.previewText = self.objectReference:GetRefValue("previewText")
	self.submitBtnTxt = self.objectReference:GetRefValue("submitBtnTxt")
	self.btnGetRewardUButton = self.objectReference:GetRefValue("btnGetRewardUButton")
	self.txtLevelUSDFText = self.objectReference:GetRefValue("txtLevelUSDFText")
	self.normalCountTxt = self.objectReference:GetRefValue("normalCountTxt")
	self.shinyCountTxt = self.objectReference:GetRefValue("shinyCountTxt")
	self.btnInvestigateUButton = self.objectReference:GetRefValue("btnInvestigateUButton")
	self.btnResearchUButton = self.objectReference:GetRefValue("btnResearchUButton")
	self.btnInfoUButton = self.objectReference:GetRefValue("btnInfoUButton")
	self.maxUWidget = self.objectReference:GetRefValue("maxUWidget")
	self.backgroundUImage = self.objectReference:GetRefValue("backgroundUImage")
	self.imgPicUImage = self.objectReference:GetRefValue("imgPicUImage")
	self.propTextUSDFText = self.objectReference:GetRefValue("propTextUSDFText")
end

function PetResearchFrontPageV2View:registerObjects()
	return
end

function PetResearchFrontPageV2View:initView()
	self.btnQuestionUButton.tooltipId = pg.getGameString("PET_MANUAL_LEVEL")
end

return PetResearchFrontPageV2View
