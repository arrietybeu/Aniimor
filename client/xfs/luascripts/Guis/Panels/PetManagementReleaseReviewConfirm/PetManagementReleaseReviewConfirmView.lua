-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetManagementReleaseReviewConfirm\\PetManagementReleaseReviewConfirmView.lua

local UIView = require("Guis.UIView")
local Class = require("Core.Framework.Class")
local PetManagementReleaseReviewConfirmView = Class.LightClass("PetManagementReleaseReviewConfirmView", UIView)

function PetManagementReleaseReviewConfirmView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.btnCancelUButton = self.objectReference:GetRefValue("btnCancelUButton")
	self.txtNumUSDFText = self.objectReference:GetRefValue("txtNumUSDFText")
	self.listPetUList = self.objectReference:GetRefValue("listPetUList")
	self.listRewardUList = self.objectReference:GetRefValue("listRewardUList")
	self.tipsUWidget = self.objectReference:GetRefValue("tipsUWidget")
	self.txtTipsUSDFText = self.objectReference:GetRefValue("txtTipsUSDFText")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
	self.txtTipsWarnUSDFText = self.objectReference:GetRefValue("txtTipsWarnUSDFText")
end

return PetManagementReleaseReviewConfirmView
