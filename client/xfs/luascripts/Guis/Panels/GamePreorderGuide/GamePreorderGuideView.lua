-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GamePreorderGuide\\GamePreorderGuideView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local GamePreorderGuideView = Class.LightClass("GamePreorderGuideView", UIView)

function GamePreorderGuideView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.btnViewUButton = self.objectReference:GetRefValue("btnViewUButton")
	self.btnGoUButton = self.objectReference:GetRefValue("btnGoUButton")
	self.txtTitleUSDFText = self.objectReference:GetRefValue("txtTitleUSDFText")
	self.txtDetailsUSDFText = self.objectReference:GetRefValue("txtDetailsUSDFText")

	local preorderButtonReference = self.btnViewUButton.transform:GetComponent("ObjectReference")

	self.txtPreorderUText = preorderButtonReference:GetRefValue("txtNameUText")

	local continueButtonReference = self.btnGoUButton.transform:GetComponent("ObjectReference")

	self.txtContinueUText = continueButtonReference:GetRefValue("txtNameUText")
end

return GamePreorderGuideView
