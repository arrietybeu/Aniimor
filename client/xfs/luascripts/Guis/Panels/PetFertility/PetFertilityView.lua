-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetFertility\\PetFertilityView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetFertilityView = Class.LightClass("PetFertilityView", UIView)

function PetFertilityView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.root = objectReference:GetRefValue("root")
	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.panelHatchUComponent = objectReference:GetRefValue("panelHatchUComponent")
	self.unFocusBtn = objectReference:GetRefValue("unFocusBtn")
end

function PetFertilityView:initView()
	return
end

return PetFertilityView
