-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTransmogStarUpgrade\\PetTransmogStarUpgradeView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PetTransmogStarUpgradeView = Class.LightClass("PetTransmogStarUpgradeView", UIView)

function PetTransmogStarUpgradeView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.backGroundClose = objectReference:GetRefValue("backGroundClose")
	self.listStar = objectReference:GetRefValue("listStar")
	self.txtName = objectReference:GetRefValue("txtName")
	self.rootComponent = objectReference:GetRefValue("rootComponent")
	self.textSub = objectReference:GetRefValue("textSub")
end

function PetTransmogStarUpgradeView:registerObjects()
	return
end

function PetTransmogStarUpgradeView:initView()
	return
end

return PetTransmogStarUpgradeView
