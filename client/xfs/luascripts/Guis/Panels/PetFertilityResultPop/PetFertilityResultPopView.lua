-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityResultPop\\PetFertilityResultPopView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetFertilityResultPopView = Class.LightClass("PetFertilityResultPopView", UIView)

function PetFertilityResultPopView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.passionUComponent = self.objectReference:GetRefValue("passionUComponent")
	self.iconUImage = self.objectReference:GetRefValue("iconUImage")
	self.featureName = self.objectReference:GetRefValue("featureName")
	self.featureDesc = self.objectReference:GetRefValue("featureDesc")
	self.panelEggUComponent = self.objectReference:GetRefValue("panelEggUComponent")
	self.eggName = self.objectReference:GetRefValue("eggName")
	self.listGiftUList = self.objectReference:GetRefValue("listGiftUList")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
	self.uIPopPetFertilityResultUComponent = self.objectReference:GetRefValue("uIPopPetFertilityResultUComponent")
	self.btnCancelUButton = self.objectReference:GetRefValue("btnCancelUButton")
	self.fuyuEggUImage = self.objectReference:GetRefValue("fuyuEggUImage")
end

function PetFertilityResultPopView:initView()
	return
end

return PetFertilityResultPopView
