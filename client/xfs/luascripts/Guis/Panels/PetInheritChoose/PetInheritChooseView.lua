-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetInheritChoose\\PetInheritChooseView.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetInheritChooseView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetInheritChooseView = Class.LightClass("PetInheritChooseView", UIView)

function PetInheritChooseView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.petListTransform = objectReference:GetRefValue("petListTransform")
	self.petInfoPanelTransform = objectReference:GetRefValue("petInfoPanelTransform")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.imgPetURawImage = objectReference:GetRefValue("imgPetURawImage")
	self.root = objectReference:GetRefValue("root")
	self.titleTMPUSDFText = objectReference:GetRefValue("titleTMPUSDFText")
	self.txtTipsUSDFText = objectReference:GetRefValue("txtTipsUSDFText")
	self.btnRulesUButton = objectReference:GetRefValue("btnRulesUButton")
	self.autoFilterBtnUContainer = objectReference:GetRefValue("autoFilterBtnUContainer")
end

function PetInheritChooseView:registerObjects()
	return
end

function PetInheritChooseView:initView()
	return
end

return PetInheritChooseView
