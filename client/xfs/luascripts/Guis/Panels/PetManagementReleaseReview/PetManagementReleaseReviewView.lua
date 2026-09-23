-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetManagementReleaseReview\\PetManagementReleaseReviewView.lua

local UIView = require("Guis.UIView")
local Class = require("Core.Framework.Class")
local PetManagementReleaseReviewView = Class.LightClass("PetManagementReleaseReviewView", UIView)

function PetManagementReleaseReviewView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.listRewardUList = self.objectReference:GetRefValue("listRewardUList")
	self.txtTipsUSDFText = self.objectReference:GetRefValue("txtTipsUSDFText")
	self.listPetUList = self.objectReference:GetRefValue("listPetUList")
	self.petInfoPanelUComponent = self.objectReference:GetRefValue("petInfoPanelUComponent")
	self.widgetTipsUWidget = self.objectReference:GetRefValue("widgetTipsUWidget")
	self.bgBlurUIBlurEffect = self.objectReference:GetRefValue("bgBlurUIBlurEffect")
end

return PetManagementReleaseReviewView
