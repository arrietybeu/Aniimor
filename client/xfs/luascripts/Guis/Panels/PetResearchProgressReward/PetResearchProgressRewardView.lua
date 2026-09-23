-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchProgressReward\\PetResearchProgressRewardView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetResearchProgressRewardView = Class.LightClass("PetResearchProgressRewardView", UIView)

function PetResearchProgressRewardView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.reward1 = self.objectReference:GetRefValue("reward1")
	self.reward2 = self.objectReference:GetRefValue("reward2")
	self.reward3 = self.objectReference:GetRefValue("reward3")
	self.researchText1 = self.objectReference:GetRefValue("researchText1")
	self.researchText2 = self.objectReference:GetRefValue("researchText2")
	self.researchText3 = self.objectReference:GetRefValue("researchText3")
	self.researchList2 = self.objectReference:GetRefValue("researchList2")
	self.researchList3 = self.objectReference:GetRefValue("researchList3")
	self.researchList1 = self.objectReference:GetRefValue("researchList1")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.btnResProgressUButton = self.objectReference:GetRefValue("btnResProgressUButton")
	self.progressUText = self.objectReference:GetRefValue("progressUText")
	self.btnGetAllRewardUButton = self.objectReference:GetRefValue("btnGetAllRewardUButton")
	self.progress1 = self.objectReference:GetRefValue("progress1")
	self.progress2 = self.objectReference:GetRefValue("progress2")
	self.progress3 = self.objectReference:GetRefValue("progress3")
	self.backTitleText = self.objectReference:GetRefValue("backTitleText")
	self.bottomKeyListUList = self.objectReference:GetRefValue("bottomKeyListUList")
	self.reward4 = self.objectReference:GetRefValue("reward4")
	self.researchList4 = self.objectReference:GetRefValue("researchList4")
	self.progress4 = self.objectReference:GetRefValue("progress4")
	self.researchText4 = self.objectReference:GetRefValue("researchText4")
end

function PetResearchProgressRewardView:registerObjects()
	return
end

function PetResearchProgressRewardView:initView()
	return
end

return PetResearchProgressRewardView
