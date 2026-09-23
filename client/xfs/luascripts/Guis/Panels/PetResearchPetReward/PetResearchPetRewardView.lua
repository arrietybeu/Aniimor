-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchPetReward\\PetResearchPetRewardView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetResearchPetRewardView = Class.LightClass("PetResearchPetRewardView", UIView)
local ClientTextUtils = require("Utils.ClientTextUtils")

function PetResearchPetRewardView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.iconUImage = self.objectReference:GetRefValue("iconUImage")
	self.btnItem1 = self.objectReference:GetRefValue("btnItem1")
	self.btnItem2 = self.objectReference:GetRefValue("btnItem2")
	self.btnItem3 = self.objectReference:GetRefValue("btnItem3")
	self.btnItem4 = self.objectReference:GetRefValue("btnItem4")
	self.btnItem5 = self.objectReference:GetRefValue("btnItem5")
	self.progressUProgress = self.objectReference:GetRefValue("progressUProgress")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.btnGetRewardUButton = self.objectReference:GetRefValue("btnGetRewardUButton")
	self.listUList = self.objectReference:GetRefValue("listUList")
	self.arrowUWidget = self.objectReference:GetRefValue("arrowUWidget")
	self.btnSurveyUButton = self.objectReference:GetRefValue("btnSurveyUButton")
	self.btnTopicUButton = self.objectReference:GetRefValue("btnTopicUButton")
	self.surveyPoint = self.objectReference:GetRefValue("surveyPoint")
	self.topicPoint = self.objectReference:GetRefValue("topicPoint")
	self.littleIcon = self.objectReference:GetRefValue("littleIcon")
	self.colorAccessoryUButton = self.objectReference:GetRefValue("colorAccessoryUButton")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
end

function PetResearchPetRewardView:registerObjects()
	local objectReference = self.btnGetRewardUButton:GetComponent("ObjectReference")

	self.getAllRewardName = objectReference:GetRefValue("txtNameUText")
end

function PetResearchPetRewardView:initView()
	ClientTextUtils.setText(self.getAllRewardName, pg.getGameString("PET_RESEARCH_GET_ALL_PET_REWARD"))
end

return PetResearchPetRewardView
