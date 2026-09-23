-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityChooseBallPopup\\PetFertilityChooseBallPopupView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetFertilityChooseBallPopupView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetFertilityChooseBallPopupView = Class.LightClass("PetFertilityChooseBallPopupView", UIView)

function PetFertilityChooseBallPopupView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.listBallUList = self.objectReference:GetRefValue("listBallUList")
	self.txtDetailsUSDFText = self.objectReference:GetRefValue("txtDetailsUSDFText")
	self.tipsUWidget = self.objectReference:GetRefValue("tipsUWidget")
	self.txtTipsUSDFText = self.objectReference:GetRefValue("txtTipsUSDFText")
	self.btnCancelUButton = self.objectReference:GetRefValue("btnCancelUButton")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
	self.btnConfirmUSDFText = self.objectReference:GetRefValue("btnConfirmUSDFText")
	self.btnCloseUButton = self.objectReference:GetRefValue("btnCloseUButton")
	self.btnCloseUButton2 = self.objectReference:GetRefValue("btnCloseUButton2")
	self.txtTltleUSDFText = self.objectReference:GetRefValue("txtTltleUSDFText")
end

function PetFertilityChooseBallPopupView:initView()
	return
end

return PetFertilityChooseBallPopupView
