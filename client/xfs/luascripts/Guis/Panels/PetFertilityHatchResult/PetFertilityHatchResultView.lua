-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityHatchResult\\PetFertilityHatchResultView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetFertilityHatchResultView = Class.LightClass("PetFertilityHatchResultView", UIView)

function PetFertilityHatchResultView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.name = self.objectReference:GetRefValue("name")
	self.leftPanel = self.objectReference:GetRefValue("leftPanel")
	self.level = self.objectReference:GetRefValue("level")
	self.elementList = self.objectReference:GetRefValue("elementList")
	self.propList = self.objectReference:GetRefValue("propList")
	self.passionUComponent = self.objectReference:GetRefValue("passionUComponent")
	self.featureIcon = self.objectReference:GetRefValue("featureIcon")
	self.featureName = self.objectReference:GetRefValue("featureName")
	self.featureDesc = self.objectReference:GetRefValue("featureDesc")
	self.listGiftUList = self.objectReference:GetRefValue("listGiftUList")
	self.btnCancelUButton = self.objectReference:GetRefValue("btnCancelUButton")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
end

function PetFertilityHatchResultView:initView()
	return
end

return PetFertilityHatchResultView
