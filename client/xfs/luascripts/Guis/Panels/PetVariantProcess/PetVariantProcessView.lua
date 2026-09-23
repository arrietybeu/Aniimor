-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetVariantProcess\\PetVariantProcessView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetVariantProcessView = Class.LightClass("PetVariantProcessView", UIView)

function PetVariantProcessView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.backGroundCloseUButton = objectReference:GetRefValue("backGroundCloseUButton")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
end

function PetVariantProcessView:initView()
	ClientTextUtils.setText(self.txtNameUSDFText, pg.getGameString("Left_Click_Close"))
end

return PetVariantProcessView
