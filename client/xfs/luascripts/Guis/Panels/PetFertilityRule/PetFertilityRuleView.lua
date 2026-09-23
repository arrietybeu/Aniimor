-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertilityRule\\PetFertilityRuleView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetFertilityRuleView = Class.LightClass("PetFertilityRuleView", UIView)

function PetFertilityRuleView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.listUList = self.objectReference:GetRefValue("listUList")
	self.btnLeftUButton = self.objectReference:GetRefValue("btnLeftUButton")
	self.btnRightUButton = self.objectReference:GetRefValue("btnRightUButton")
	self.root = self.objectReference:GetRefValue("root")
end

function PetFertilityRuleView:initView()
	return
end

return PetFertilityRuleView
