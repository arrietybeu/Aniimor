-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityResult\\PetFertilityResultView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetFertilityResultView = Class.LightClass("PetFertilityResultView", UIView)

function PetFertilityResultView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.continueButtonUButton = self.objectReference:GetRefValue("continueButtonUButton")
	self.root = self.objectReference:GetRefValue("root")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
	self.panelResultUComponent = self.objectReference:GetRefValue("panelResultUComponent")
	self.fuyuEggUImage = self.objectReference:GetRefValue("fuyuEggUImage")
end

function PetFertilityResultView:initView()
	return
end

return PetFertilityResultView
